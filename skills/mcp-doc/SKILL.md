---
name: mcp-doc
description: Complete documentation for Claude Code MCP (Model Context Protocol) server integration -- adding MCP servers (HTTP/SSE/stdio transports, claude mcp add syntax, option ordering, --transport flag), managing servers (claude mcp list/get/remove, /mcp command, dynamic tool updates, list_changed notifications), MCP installation scopes (local/project/user, scope hierarchy and precedence, .mcp.json project file, ~/.claude.json storage), environment variable expansion in .mcp.json (${VAR} and ${VAR:-default} syntax, supported locations), OAuth authentication (OAuth 2.0 flow, /mcp auth, --client-id, --client-secret, --callback-port, dynamic client registration, pre-configured credentials, MCP_CLIENT_SECRET env var, authServerMetadataUrl override), adding servers from JSON (claude mcp add-json), importing from Claude Desktop (claude mcp add-from-claude-desktop), Claude.ai MCP servers (ENABLE_CLAUDEAI_MCP_SERVERS), using Claude Code as MCP server (claude mcp serve, Claude Desktop config), MCP output limits (MAX_MCP_OUTPUT_TOKENS, 10000 token warning, 25000 default max), MCP elicitation (form mode, URL mode, Elicitation hook), MCP resources (@ mentions, @server:protocol://resource/path format, fuzzy search), MCP Tool Search (automatic tool deferral, ENABLE_TOOL_SEARCH env var, auto threshold, context window optimization, tool_reference blocks, server instructions), MCP prompts as commands (/mcp__servername__promptname format, argument passing), plugin-provided MCP servers (.mcp.json in plugin root, ${CLAUDE_PLUGIN_ROOT}, automatic lifecycle), managed MCP configuration (managed-mcp.json system paths, exclusive control, allowedMcpServers/deniedMcpServers policy, serverName/serverCommand/serverUrl matching, wildcard URL patterns, command exact matching, denylist precedence), Windows npx cmd /c wrapper, MCP_TIMEOUT startup timeout, project scope approval and reset-project-choices. Load when discussing MCP servers in Claude Code, adding/removing/configuring MCP servers, MCP transports, MCP authentication, OAuth for MCP, MCP scopes, .mcp.json configuration, managed MCP, MCP tool search, MCP resources, MCP prompts, MCP elicitation, claude mcp commands, MCP output tokens, MAX_MCP_OUTPUT_TOKENS, ENABLE_TOOL_SEARCH, managed-mcp.json, allowedMcpServers, deniedMcpServers, MCP server restrictions, or connecting Claude Code to external tools and APIs.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools via the Model Context Protocol (MCP).

## Quick Reference

MCP (Model Context Protocol) is an open standard for AI-tool integrations. Claude Code connects to MCP servers to access external tools, databases, and APIs.

### Adding MCP Servers

| Transport | Command | Use case |
|:----------|:--------|:---------|
| HTTP (recommended) | `claude mcp add --transport http <name> <url>` | Remote cloud services |
| SSE (deprecated) | `claude mcp add --transport sse <name> <url>` | Legacy remote servers |
| stdio | `claude mcp add <name> -- <command> [args...]` | Local processes, custom scripts |

All options (`--transport`, `--env`, `--scope`, `--header`) must come before the server name. The `--` separates the server name from the command/args passed to the MCP server.

Add authentication headers:

```
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

Add from JSON directly:

```
claude mcp add-json <name> '<json>'
```

Import from Claude Desktop (macOS and WSL only):

```
claude mcp add-from-claude-desktop
```

### Managing Servers

| Command | Description |
|:--------|:------------|
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Get details for a specific server |
| `claude mcp remove <name>` | Remove a server |
| `/mcp` | Check server status, authenticate, manage (inside Claude Code) |
| `claude mcp reset-project-choices` | Reset project-scope server approval choices |

### Installation Scopes

| Scope | Flag | Storage | Use case |
|:------|:-----|:--------|:---------|
| `local` (default) | `--scope local` | `~/.claude.json` under project path | Personal, per-project servers |
| `project` | `--scope project` | `.mcp.json` at project root (version-controlled) | Team-shared servers |
| `user` | `--scope user` | `~/.claude.json` | Personal servers across all projects |

Precedence: local > project > user.

Note: MCP "local scope" stores in `~/.claude.json`, which differs from general local settings (`.claude/settings.local.json`).

### Environment Variable Expansion in .mcp.json

Supported syntax: `${VAR}` and `${VAR:-default}`.

Expansion works in: `command`, `args`, `env`, `url`, `headers`.

```json
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

If a required variable is not set and has no default, config parsing fails.

### OAuth Authentication

Claude Code supports OAuth 2.0 for remote MCP servers.

**Basic flow**: Add server with `claude mcp add`, then run `/mcp` inside Claude Code to authenticate in browser.

**Pre-configured OAuth credentials** (when dynamic client registration is not supported):

| Flag | Purpose |
|:-----|:--------|
| `--client-id <id>` | OAuth app client ID |
| `--client-secret` | Prompts for secret (masked input) |
| `--callback-port <port>` | Fixed OAuth callback port (must match registered redirect URI) |

Client secret can also be set via `MCP_CLIENT_SECRET` env var for non-interactive use.

**Override OAuth metadata discovery**: Set `authServerMetadataUrl` in the `oauth` object of server config to bypass standard `/.well-known/oauth-authorization-server` discovery.

```json
{
  "mcpServers": {
    "my-server": {
      "type": "http",
      "url": "https://mcp.example.com/mcp",
      "oauth": {
        "authServerMetadataUrl": "https://auth.example.com/.well-known/openid-configuration"
      }
    }
  }
}
```

### MCP Tool Search

Automatically defers MCP tool loading when tool descriptions exceed 10% of context window. Claude discovers tools on-demand via a search tool.

| `ENABLE_TOOL_SEARCH` value | Behavior |
|:---------------------------|:---------|
| (unset) | Enabled by default; disabled when `ANTHROPIC_BASE_URL` is non-first-party |
| `true` | Always enabled |
| `auto` | Activates when MCP tools exceed 10% of context |
| `auto:<N>` | Custom threshold (e.g., `auto:5` for 5%) |
| `false` | Disabled, all tools loaded upfront |

Requires models supporting `tool_reference` blocks (Sonnet 4+, Opus 4+). Not supported on Haiku.

Disable the search tool specifically via settings:

```json
{
  "permissions": {
    "deny": ["MCPSearch"]
  }
}
```

### MCP Resources

Reference MCP resources with `@` mentions: `@server:protocol://resource/path`. Resources appear in the autocomplete menu alongside files and are fetched automatically as attachments.

### MCP Prompts as Commands

MCP prompts become slash commands: `/mcp__servername__promptname`. Pass arguments space-separated after the command.

### MCP Elicitation

Servers can request structured input mid-task via form mode (dialog with fields) or URL mode (browser authentication). Auto-respond using the `Elicitation` hook.

### Output Limits

| Setting | Value |
|:--------|:------|
| Warning threshold | 10,000 tokens |
| Default maximum | 25,000 tokens |
| Override | `MAX_MCP_OUTPUT_TOKENS` env var |

### Claude Code as MCP Server

```
claude mcp serve
```

Exposes Claude Code's tools (View, Edit, LS, etc.) to other MCP clients. Configure in Claude Desktop:

```json
{
  "mcpServers": {
    "claude-code": {
      "type": "stdio",
      "command": "claude",
      "args": ["mcp", "serve"]
    }
  }
}
```

If `claude` is not in PATH, use the full path from `which claude`.

### Plugin-Provided MCP Servers

Plugins bundle MCP servers in `.mcp.json` at the plugin root or inline in `plugin.json`. Plugin servers start automatically when the plugin is enabled, but MCP server changes require restarting Claude Code. Use `${CLAUDE_PLUGIN_ROOT}` for portable paths.

### Managed MCP Configuration

**Option 1: Exclusive control** -- Deploy `managed-mcp.json` to system path for full control (users cannot add/modify servers).

| Platform | Path |
|:---------|:-----|
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux/WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

**Option 2: Policy-based control** -- Use `allowedMcpServers` and `deniedMcpServers` in managed settings.

Each entry restricts by exactly one of:

| Match type | Field | Applies to |
|:-----------|:------|:-----------|
| Server name | `serverName` | Any server |
| Exact command | `serverCommand` | stdio servers (exact array match) |
| URL pattern | `serverUrl` | Remote servers (wildcards with `*`) |

Key rules:
- Denylist always takes precedence over allowlist
- `allowedMcpServers` undefined = no restrictions; empty `[]` = complete lockdown
- When command entries exist in allowlist, stdio servers must match a command (not just name)
- When URL entries exist in allowlist, remote servers must match a URL pattern (not just name)
- Options 1 and 2 can be combined

### Other Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `MCP_TIMEOUT` | MCP server startup timeout in ms (e.g., `MCP_TIMEOUT=10000 claude`) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set to `false` to disable Claude.ai MCP servers in Claude Code |
| `MAX_MCP_OUTPUT_TOKENS` | Maximum allowed MCP tool output tokens |
| `ENABLE_TOOL_SEARCH` | Control MCP tool search behavior |

### Windows Note

On native Windows (not WSL), local stdio servers using `npx` require the `cmd /c` wrapper:

```
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

### Dynamic Tool Updates

Claude Code supports MCP `list_changed` notifications, allowing servers to dynamically update available tools, prompts, and resources without reconnection.

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) -- adding MCP servers (HTTP/SSE/stdio transports, option ordering), managing servers (list/get/remove, /mcp, dynamic tool updates), installation scopes (local/project/user, precedence, .mcp.json format, env var expansion), practical examples (Sentry, GitHub, PostgreSQL), OAuth authentication (dynamic registration, pre-configured credentials, --client-id/--client-secret/--callback-port, authServerMetadataUrl override), adding from JSON (add-json), importing from Claude Desktop (add-from-claude-desktop), Claude.ai MCP servers (ENABLE_CLAUDEAI_MCP_SERVERS), Claude Code as MCP server (mcp serve), output limits (MAX_MCP_OUTPUT_TOKENS), elicitation (form/URL modes), MCP resources (@ mentions), MCP Tool Search (ENABLE_TOOL_SEARCH, auto threshold, tool_reference blocks), MCP prompts as commands, plugin-provided MCP servers (${CLAUDE_PLUGIN_ROOT}, lifecycle), managed MCP configuration (managed-mcp.json exclusive control, allowedMcpServers/deniedMcpServers policy, serverName/serverCommand/serverUrl matching, wildcard URL patterns, denylist precedence), Windows npx wrapper, MCP_TIMEOUT

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
