---
name: mcp-doc
description: Complete documentation for Claude Code MCP (Model Context Protocol) integration -- installing MCP servers (HTTP, SSE, stdio transports), `claude mcp add` command syntax and option ordering, MCP server scopes (local, project, user), `.mcp.json` project configuration with environment variable expansion, OAuth 2.0 authentication (dynamic registration, pre-configured credentials, --client-id, --client-secret, --callback-port, authServerMetadataUrl), importing servers from Claude Desktop, Claude.ai MCP servers (ENABLE_CLAUDEAI_MCP_SERVERS), using Claude Code as an MCP server (`claude mcp serve`), MCP output limits (MAX_MCP_OUTPUT_TOKENS, 25000 default, 10000 token warning), MCP resources (@ mentions, @server:protocol://path), MCP Tool Search (ENABLE_TOOL_SEARCH, auto threshold, tool_reference blocks), MCP prompts as commands (/mcp__server__prompt), managed MCP configuration (managed-mcp.json, allowedMcpServers, deniedMcpServers, serverName/serverCommand/serverUrl restrictions), plugin-provided MCP servers, dynamic tool updates (list_changed notifications), MCP_TIMEOUT, scope hierarchy and precedence, JSON server configuration (`claude mcp add-json`). Load when discussing MCP servers, Model Context Protocol, connecting Claude Code to external tools, MCP configuration, MCP scopes, MCP authentication, OAuth for MCP, MCP tool search, MCP resources, MCP prompts, managed MCP, MCP allowlists, MCP denylists, `.mcp.json`, `claude mcp add`, `claude mcp serve`, MCP output limits, or MCP server management.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools via MCP (Model Context Protocol).

## Quick Reference

MCP is an open standard for AI-tool integrations. Claude Code connects to MCP servers to access external tools, databases, and APIs.

### Installing MCP Servers

Three transport types are supported:

| Transport | Command | Use case |
|:----------|:--------|:---------|
| HTTP (recommended) | `claude mcp add --transport http <name> <url>` | Remote cloud services |
| SSE (deprecated) | `claude mcp add --transport sse <name> <url>` | Legacy remote servers |
| stdio | `claude mcp add <name> -- <command> [args...]` | Local processes, custom scripts |

Option ordering: all flags (`--transport`, `--env`, `--scope`, `--header`) must come before the server name. The `--` separator precedes the command/args for stdio servers.

### Adding Authentication Headers

```
claude mcp add --transport http <name> <url> --header "Authorization: Bearer <token>"
```

### MCP Server Scopes

| Scope | Flag | Storage | Visibility |
|:------|:-----|:--------|:-----------|
| **Local** (default) | `--scope local` | `~/.claude.json` (under project path) | You only, current project |
| **Project** | `--scope project` | `.mcp.json` in project root (version controlled) | Entire team |
| **User** | `--scope user` | `~/.claude.json` | You only, all projects |

Precedence: local > project > user. Project-scoped servers require approval on first use; reset with `claude mcp reset-project-choices`.

### Managing Servers

| Command | Purpose |
|:--------|:--------|
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Show details for a server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp add-json <name> '<json>'` | Add server from JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS/WSL only) |
| `/mcp` | Check server status, authenticate, manage servers inside Claude Code |

### Environment Variable Expansion in .mcp.json

Supported in `command`, `args`, `env`, `url`, and `headers` fields:

| Syntax | Behavior |
|:-------|:---------|
| `${VAR}` | Expands to value of `VAR` |
| `${VAR:-default}` | Uses `default` if `VAR` is unset |

### OAuth 2.0 Authentication

For remote servers requiring auth, use `/mcp` inside Claude Code to trigger browser-based OAuth flow. Tokens are stored securely and refreshed automatically.

**Pre-configured OAuth credentials** (when dynamic registration is not supported):

| Flag | Purpose |
|:-----|:--------|
| `--client-id` | OAuth client ID from server's developer portal |
| `--client-secret` | Prompts for secret with masked input (stored in system keychain) |
| `--callback-port` | Fixed port for redirect URI matching (e.g., `http://localhost:PORT/callback`) |

For CI environments, set `MCP_CLIENT_SECRET` env var to skip interactive prompt.

**Override metadata discovery**: set `authServerMetadataUrl` in the `oauth` object of `.mcp.json` to bypass standard `/.well-known/oauth-authorization-server` discovery (requires v2.1.64+).

### Claude Code as an MCP Server

```
claude mcp serve
```

Exposes Claude Code's tools (View, Edit, LS, etc.) to other MCP clients. Add to Claude Desktop config:

```json
{
  "mcpServers": {
    "claude-code": {
      "type": "stdio",
      "command": "claude",
      "args": ["mcp", "serve"],
      "env": {}
    }
  }
}
```

If `claude` is not in PATH, use the full path (find with `which claude`).

### MCP Output Limits

| Setting | Default | Purpose |
|:--------|:--------|:--------|
| Warning threshold | 10,000 tokens | Displays warning when tool output exceeds this |
| `MAX_MCP_OUTPUT_TOKENS` | 25,000 tokens | Maximum allowed MCP tool output |

### MCP Resources

Reference MCP resources with `@` mentions: `@server:protocol://resource/path`. Resources appear in autocomplete alongside files. Multiple resources can be referenced in a single prompt.

### MCP Tool Search

Automatically enabled when MCP tool descriptions exceed 10% of context window. Tools are loaded on-demand instead of upfront.

| `ENABLE_TOOL_SEARCH` value | Behavior |
|:---------------------------|:---------|
| (unset) | Enabled by default; disabled for non-first-party `ANTHROPIC_BASE_URL` |
| `true` | Always enabled |
| `auto` | Activates at 10% context threshold |
| `auto:<N>` | Custom threshold (e.g., `auto:5` for 5%) |
| `false` | Disabled, all tools loaded upfront |

Requires Sonnet 4+ or Opus 4+. Disable the search tool via `"deny": ["MCPSearch"]` in permissions.

### MCP Prompts as Commands

MCP prompts appear as `/mcp__servername__promptname` commands. Pass arguments space-separated after the command.

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers via `.mcp.json` at plugin root or `mcpServers` in `plugin.json`. Plugin servers start automatically when the plugin is enabled and use `${CLAUDE_PLUGIN_ROOT}` for relative paths.

### Dynamic Tool Updates

MCP servers can send `list_changed` notifications to dynamically update available tools without reconnecting.

### Managed MCP Configuration (Enterprise)

**Option 1 -- Exclusive control (`managed-mcp.json`)**:

Deploy to system directory to take exclusive control over all MCP servers:

| Platform | Path |
|:---------|:-----|
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux/WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

Uses same format as `.mcp.json`. Users cannot add/modify servers when this file exists.

**Option 2 -- Policy-based control (allowlists/denylists)**:

Set `allowedMcpServers` and `deniedMcpServers` in managed settings. Each entry matches by exactly one of:

| Field | Matches |
|:------|:--------|
| `serverName` | Configured server name |
| `serverCommand` | Exact command + args array for stdio servers |
| `serverUrl` | URL pattern with `*` wildcards for remote servers |

Denylist takes absolute precedence over allowlist.

| `allowedMcpServers` value | Effect |
|:--------------------------|:-------|
| `undefined` | No restrictions |
| `[]` | Complete lockdown |
| List of entries | Only matching servers allowed |

Options 1 and 2 can be combined: managed-mcp.json provides servers, allowlists/denylists filter which are loaded.

### Claude.ai MCP Servers

Servers configured in Claude.ai are automatically available in Claude Code when logged in with a Claude.ai account. Disable with `ENABLE_CLAUDEAI_MCP_SERVERS=false`.

### Environment Variables Summary

| Variable | Purpose |
|:---------|:--------|
| `MCP_TIMEOUT` | Server startup timeout in ms (e.g., `MCP_TIMEOUT=10000`) |
| `MAX_MCP_OUTPUT_TOKENS` | Maximum MCP tool output tokens (default 25000) |
| `ENABLE_TOOL_SEARCH` | Control tool search behavior |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Enable/disable Claude.ai MCP servers (default true) |
| `MCP_CLIENT_SECRET` | OAuth client secret for CI (skips interactive prompt) |

### Windows Note

On native Windows (not WSL), stdio servers using `npx` require the `cmd /c` wrapper:

```
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) -- installing MCP servers (HTTP/SSE/stdio), server scopes (local/project/user), .mcp.json configuration with env var expansion, OAuth 2.0 authentication (dynamic registration, pre-configured credentials, callback port, metadata override), JSON configuration, importing from Claude Desktop, Claude.ai servers, using Claude Code as MCP server, output limits, MCP resources, MCP Tool Search, MCP prompts, managed MCP configuration (managed-mcp.json, allowlists/denylists), plugin-provided servers, dynamic tool updates

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
