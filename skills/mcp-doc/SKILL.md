---
name: mcp-doc
description: Complete documentation for Claude Code MCP (Model Context Protocol) integration -- connecting to external tools via MCP servers, installing servers (HTTP, SSE, stdio transports), MCP scopes (local, project, user), scope precedence, managing servers (claude mcp add/list/get/remove), environment variable expansion in .mcp.json, OAuth 2.0 authentication (dynamic registration, pre-configured credentials, --client-id, --client-secret, --callback-port, authServerMetadataUrl), importing from Claude Desktop, using Claude.ai MCP servers (ENABLE_CLAUDEAI_MCP_SERVERS), using Claude Code as an MCP server (claude mcp serve), MCP output limits (MAX_MCP_OUTPUT_TOKENS), elicitation (form and URL modes, Elicitation hook), MCP resources (@ mentions), MCP Tool Search (ENABLE_TOOL_SEARCH, auto threshold, tool_reference blocks), MCP prompts as /mcp__server__prompt commands, plugin-provided MCP servers (.mcp.json, plugin.json mcpServers, CLAUDE_PLUGIN_ROOT), managed MCP configuration (managed-mcp.json exclusive control, allowedMcpServers/deniedMcpServers policy with serverName/serverCommand/serverUrl matching), dynamic tool updates (list_changed notifications), project-scoped .mcp.json approval and reset, MCP_TIMEOUT, /mcp command, Windows cmd /c wrapper for npx. Load when discussing MCP, Model Context Protocol, MCP servers, claude mcp add, MCP tools, MCP scopes, .mcp.json, managed-mcp.json, MCP authentication, OAuth for MCP, MCP resources, MCP prompts, MCP Tool Search, ENABLE_TOOL_SEARCH, MAX_MCP_OUTPUT_TOKENS, MCP_TIMEOUT, MCP elicitation, plugin MCP servers, MCP allowlist, MCP denylist, allowedMcpServers, deniedMcpServers, claude mcp serve, MCP output limits, /mcp command, or connecting Claude Code to external tools.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools via the Model Context Protocol (MCP).

## Quick Reference

MCP is an open standard for AI-tool integrations. Claude Code connects to MCP servers that provide access to databases, APIs, issue trackers, monitoring tools, and more.

### Transports

| Transport | Command | Use case |
|:----------|:--------|:---------|
| **HTTP** (recommended) | `claude mcp add --transport http <name> <url>` | Remote cloud services |
| **SSE** (deprecated) | `claude mcp add --transport sse <name> <url>` | Legacy remote servers |
| **stdio** | `claude mcp add <name> -- <command> [args...]` | Local processes needing system access |

Options (`--transport`, `--env`, `--scope`, `--header`) must come before the server name. `--` separates server name from the command/args for stdio servers.

### Server Management Commands

| Command | Purpose |
|:--------|:--------|
| `claude mcp add` | Add a server (see transports above) |
| `claude mcp add-json <name> '<json>'` | Add a server from JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS/WSL) |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Show details for a server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset project-scope approval choices |
| `claude mcp serve` | Run Claude Code itself as an MCP server |
| `/mcp` | In-session: view status, authenticate, clear auth |

### Installation Scopes

| Scope | Storage | Visibility | Flag |
|:------|:--------|:-----------|:-----|
| **Local** (default) | `~/.claude.json` (under project path) | You, current project only | `--scope local` |
| **Project** | `.mcp.json` in project root (version-controlled) | All team members | `--scope project` |
| **User** | `~/.claude.json` | You, all projects | `--scope user` |

Precedence: local > project > user. Servers with the same name at multiple scopes resolve to the highest-priority scope.

### Environment Variable Expansion in .mcp.json

Supported in `command`, `args`, `env`, `url`, and `headers` fields:

| Syntax | Behavior |
|:-------|:---------|
| `${VAR}` | Expands to value of `VAR`; fails if unset |
| `${VAR:-default}` | Expands to `VAR` if set, otherwise uses `default` |

### OAuth 2.0 Authentication

Remote servers requiring auth use OAuth 2.0. Run `/mcp` in Claude Code and follow the browser login flow.

| Flag | Purpose |
|:-----|:--------|
| `--client-id` | Pre-configured OAuth client ID |
| `--client-secret` | Prompts for secret (masked input); or set `MCP_CLIENT_SECRET` env var |
| `--callback-port <port>` | Fix the OAuth redirect port (must match registered redirect URI) |

Override metadata discovery with `authServerMetadataUrl` in the `oauth` object of `.mcp.json` config (requires v2.1.64+).

Tokens stored securely in system keychain (macOS) or credentials file. Use "Clear authentication" in `/mcp` to revoke.

### Claude.ai MCP Servers

MCP servers added in Claude.ai are automatically available in Claude Code when logged in with a Claude.ai account. Disable with `ENABLE_CLAUDEAI_MCP_SERVERS=false`.

### Using Claude Code as an MCP Server

```bash
claude mcp serve
```

Exposes Claude Code's tools (View, Edit, LS, etc.) to other MCP clients. Add to Claude Desktop config with `"command": "claude", "args": ["mcp", "serve"]`.

### MCP Output Limits

| Setting | Default | Purpose |
|:--------|:--------|:--------|
| Warning threshold | 10,000 tokens | Displays warning when exceeded |
| `MAX_MCP_OUTPUT_TOKENS` | 25,000 tokens | Maximum allowed output |

### Elicitation

MCP servers can request structured input mid-task. Two modes: **form** (dialog with fields) and **URL** (browser flow). Auto-respond via the `Elicitation` hook. No user configuration required.

### MCP Resources

Type `@` in your prompt to reference MCP resources alongside files. Format: `@server:protocol://resource/path`. Resources are fetched and included as attachments.

### MCP Tool Search

Automatically enabled when MCP tool descriptions exceed 10% of context window. Tools are deferred and discovered on demand.

| `ENABLE_TOOL_SEARCH` value | Behavior |
|:---------------------------|:---------|
| (unset) | Enabled by default; disabled for non-first-party `ANTHROPIC_BASE_URL` |
| `true` | Always enabled |
| `auto` | Activates at 10% context threshold |
| `auto:<N>` | Activates at custom threshold (e.g., `auto:5` for 5%) |
| `false` | Disabled; all MCP tools loaded upfront |

Requires Sonnet 4+ or Opus 4+ (Haiku does not support tool search). Disable with `disallowedTools: ["MCPSearch"]`.

### MCP Prompts as Commands

MCP servers expose prompts as `/mcp__servername__promptname` commands. Pass arguments space-separated after the command.

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers via `.mcp.json` at the plugin root or `mcpServers` in `plugin.json`. Use `${CLAUDE_PLUGIN_ROOT}` for plugin-relative paths. Plugin servers start automatically when the plugin is enabled; run `/reload-plugins` to connect/disconnect mid-session.

### Managed MCP Configuration

Two enterprise options for centralized control:

**Option 1 -- Exclusive control (`managed-mcp.json`)**

Deploy to system directory (requires admin privileges):
- macOS: `/Library/Application Support/ClaudeCode/managed-mcp.json`
- Linux/WSL: `/etc/claude-code/managed-mcp.json`
- Windows: `C:\Program Files\ClaudeCode\managed-mcp.json`

Users cannot add, modify, or use any servers beyond those in this file.

**Option 2 -- Policy-based control (allowlists/denylists)**

Set `allowedMcpServers` and/or `deniedMcpServers` in managed settings. Each entry matches by exactly one of:

| Match type | Field | Applies to |
|:-----------|:------|:-----------|
| Name | `serverName` | Any server |
| Command | `serverCommand` (exact array match) | stdio servers |
| URL pattern | `serverUrl` (wildcards with `*`) | HTTP/SSE servers |

Denylist always takes precedence over allowlist. Both options can be combined: `managed-mcp.json` has exclusive control, and allowlists/denylists further filter which managed servers load.

| `allowedMcpServers` value | Effect |
|:--------------------------|:-------|
| `undefined` (default) | No restrictions |
| `[]` (empty array) | Complete lockdown |
| List of entries | Only matching servers allowed |

### Useful Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `MCP_TIMEOUT` | Server startup timeout in ms (e.g., `MCP_TIMEOUT=10000`) |
| `MAX_MCP_OUTPUT_TOKENS` | Maximum MCP tool output tokens (default: 25,000) |
| `ENABLE_TOOL_SEARCH` | Control tool search behavior |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Enable/disable Claude.ai MCP servers (`true`/`false`) |
| `MCP_CLIENT_SECRET` | OAuth client secret (skips interactive prompt) |

### Windows Note

On native Windows (not WSL), stdio servers using `npx` require the `cmd /c` wrapper:

```bash
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) -- MCP overview, popular servers, installing servers (HTTP, SSE, stdio transports), managing servers, dynamic tool updates, scopes (local, project, user) with precedence and storage locations, environment variable expansion in .mcp.json, practical examples (Sentry, GitHub, PostgreSQL), OAuth 2.0 authentication (dynamic registration, pre-configured credentials, --client-id/--client-secret/--callback-port, authServerMetadataUrl override), adding servers from JSON, importing from Claude Desktop, using Claude.ai MCP servers, using Claude Code as an MCP server (claude mcp serve), output limits and MAX_MCP_OUTPUT_TOKENS, elicitation (form and URL modes), MCP resources with @ mentions, MCP Tool Search (ENABLE_TOOL_SEARCH, auto threshold, tool_reference support), MCP prompts as commands, plugin-provided MCP servers, managed MCP configuration (managed-mcp.json exclusive control, allowedMcpServers/deniedMcpServers policy-based control with serverName/serverCommand/serverUrl matching)

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
