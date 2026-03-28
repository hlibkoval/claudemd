---
name: mcp-doc
description: Complete documentation for Claude Code MCP (Model Context Protocol) integration -- connecting to external tools, databases, and APIs via MCP servers. Covers MCP server installation (HTTP, SSE, stdio transports with claude mcp add), server management (list, get, remove, /mcp status), installation scopes (local default in ~/.claude.json, project in .mcp.json for version control, user in ~/.claude.json cross-project), scope precedence (local > project > user), environment variable expansion in .mcp.json (${VAR} and ${VAR:-default} syntax in command/args/env/url/headers), OAuth 2.0 authentication (browser flow, /mcp authenticate, token storage, fixed callback port with --callback-port, pre-configured credentials with --client-id and --client-secret, MCP_CLIENT_SECRET env var, authServerMetadataUrl override, CIMD support), dynamic headers with headersHelper (shell command producing JSON, 10s timeout, CLAUDE_CODE_MCP_SERVER_NAME/URL env vars), plugin-provided MCP servers (automatic lifecycle, ${CLAUDE_PLUGIN_ROOT} and ${CLAUDE_PLUGIN_DATA}, /reload-plugins), importing from Claude Desktop (claude mcp add-from-claude-desktop), Claude.ai connector servers (automatic availability, ENABLE_CLAUDEAI_MCP_SERVERS=false to disable), using Claude Code as MCP server (claude mcp serve, Claude Desktop config), MCP output limits (10000 token warning, MAX_MCP_OUTPUT_TOKENS default 25000), MCP elicitation (form mode and URL mode, Elicitation hook for auto-response), MCP resources (@ mentions with @server:protocol://path format, fuzzy search), MCP prompts as commands (/mcp__server__prompt format, arguments), Tool Search (deferred tool loading, ENABLE_TOOL_SEARCH with true/false/auto/auto:N values, MCPSearch tool, 2KB description limit), managed MCP configuration (managed-mcp.json for exclusive control at system paths, allowedMcpServers/deniedMcpServers for policy-based control with serverName/serverCommand/serverUrl matching, wildcard URL patterns, denylist precedence), dynamic tool updates via list_changed notifications, push messages with channels, adding servers from JSON (claude mcp add-json), MCP_TIMEOUT for startup timeout, practical examples (Sentry, GitHub, PostgreSQL). Load when discussing Claude Code MCP, Model Context Protocol, MCP servers, claude mcp add, claude mcp list, claude mcp remove, claude mcp serve, .mcp.json, managed-mcp.json, MCP scopes, MCP authentication, OAuth for MCP, MCP resources, MCP prompts, MCP elicitation, headersHelper, MCP tool search, ENABLE_TOOL_SEARCH, MAX_MCP_OUTPUT_TOKENS, MCP_TIMEOUT, allowedMcpServers, deniedMcpServers, MCP channels, plugin MCP servers, Claude Desktop import, Claude.ai MCP connectors, MCP add-json, MCP output limits, or any MCP-related topic for Claude Code.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools, databases, and APIs through the Model Context Protocol (MCP).

## Quick Reference

### Installing MCP Servers

| Transport | Command | Use case |
|:----------|:--------|:---------|
| **HTTP** (recommended) | `claude mcp add --transport http <name> <url>` | Remote cloud services |
| **SSE** (deprecated) | `claude mcp add --transport sse <name> <url>` | Legacy remote servers |
| **stdio** | `claude mcp add <name> -- <command> [args...]` | Local processes, custom scripts |

Options (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. Use `--` to separate the server name from the command/args for stdio servers.

**Add with authentication header:**

```
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

**Add with environment variables (stdio):**

```
claude mcp add --transport stdio --env API_KEY=value myserver -- npx -y some-package
```

### Server Management Commands

| Command | Purpose |
|:--------|:--------|
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Get details for a specific server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp add-json <name> '<json>'` | Add server from JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS/WSL) |
| `claude mcp serve` | Run Claude Code as an MCP server |
| `claude mcp reset-project-choices` | Reset project-scope approval choices |
| `/mcp` | Check server status, authenticate, manage within Claude Code |

### Installation Scopes

| Scope | Flag | Storage | Sharing |
|:------|:-----|:--------|:--------|
| **local** (default) | `--scope local` | `~/.claude.json` (per-project path) | Private, current project only |
| **project** | `--scope project` | `.mcp.json` at project root | Checked into version control, shared with team |
| **user** | `--scope user` | `~/.claude.json` | Private, all projects |

**Precedence:** local > project > user. Local config also overrides Claude.ai connector entries.

### Environment Variable Expansion in .mcp.json

Supported syntax: `${VAR}` and `${VAR:-default}`. Expansion works in `command`, `args`, `env`, `url`, and `headers` fields. Missing variables without defaults cause a parse failure.

### OAuth Authentication

1. Add server: `claude mcp add --transport http <name> <url>`
2. Authenticate: run `/mcp` in Claude Code, follow browser flow
3. Tokens stored securely and refreshed automatically

**Pre-configured OAuth credentials:**

```
claude mcp add --transport http \
  --client-id your-client-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

- `--callback-port` fixes the OAuth callback port (for pre-registered redirect URIs)
- `--client-secret` prompts for masked input (or reads `MCP_CLIENT_SECRET` env var)
- `authServerMetadataUrl` in `.mcp.json` oauth object overrides metadata discovery
- CIMD (Client ID Metadata Document) discovered automatically

### Dynamic Headers (headersHelper)

For non-OAuth auth (Kerberos, short-lived tokens, internal SSO):

```json
{
  "mcpServers": {
    "internal-api": {
      "type": "http",
      "url": "https://mcp.internal.example.com",
      "headersHelper": "/opt/bin/get-mcp-auth-headers.sh"
    }
  }
}
```

- Command must write JSON object of string key-value pairs to stdout
- 10-second timeout, runs fresh on each connection
- Dynamic headers override static `headers` with the same name
- Environment variables set: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`

### Tool Search (ENABLE_TOOL_SEARCH)

| Value | Behavior |
|:------|:---------|
| (unset) | All MCP tools deferred and loaded on demand. Falls back to upfront when `ANTHROPIC_BASE_URL` is non-first-party |
| `true` | All MCP tools deferred, including for non-first-party hosts |
| `auto` | Threshold mode: upfront if within 10% of context window, deferred otherwise |
| `auto:<N>` | Custom threshold percentage (0-100) |
| `false` | All MCP tools loaded upfront, no deferral |

Requires Sonnet 4+ or Opus 4+. Haiku does not support tool search. Disable MCPSearch tool via `permissions.deny: ["MCPSearch"]`.

### MCP Output Limits

| Setting | Default | Purpose |
|:--------|:--------|:--------|
| Warning threshold | 10,000 tokens | Displays warning when tool output exceeds this |
| `MAX_MCP_OUTPUT_TOKENS` | 25,000 tokens | Maximum allowed MCP tool output |
| `MCP_TIMEOUT` | (ms) | MCP server startup timeout (e.g., `MCP_TIMEOUT=10000 claude`) |

### MCP Resources and Prompts

**Resources:** Reference with `@server:protocol://resource/path` in prompts. Fuzzy-searchable via `@` autocomplete.

**Prompts as commands:** MCP prompts appear as `/mcp__servername__promptname`. Pass arguments space-separated after the command.

### MCP Elicitation

Servers can request structured input mid-task:
- **Form mode**: interactive dialog with server-defined fields
- **URL mode**: browser flow for auth or approval
- Auto-respond via `Elicitation` hook

### Plugin-Provided MCP Servers

Plugins bundle MCP servers via `.mcp.json` at plugin root or inline in `plugin.json`. Servers auto-start when plugin is enabled. Use `${CLAUDE_PLUGIN_ROOT}` for paths. Manage with `/reload-plugins`.

### Claude.ai Connector Servers

MCP servers configured at `claude.ai/settings/connectors` are automatically available in Claude Code (Claude.ai login required). Disable with `ENABLE_CLAUDEAI_MCP_SERVERS=false`.

### Using Claude Code as MCP Server

```
claude mcp serve
```

Exposes Claude Code's tools (View, Edit, LS, etc.) to other MCP clients. Add to Claude Desktop config with `{"type":"stdio","command":"claude","args":["mcp","serve"]}`.

### Managed MCP Configuration

**Option 1 -- Exclusive control (managed-mcp.json):**

| Platform | Path |
|:---------|:-----|
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux/WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

Deploys a fixed set of MCP servers. Users cannot add or modify servers. Same format as `.mcp.json`.

**Option 2 -- Policy-based control (managed settings):**

| Setting | Undefined | Empty `[]` | List of entries |
|:--------|:----------|:-----------|:----------------|
| `allowedMcpServers` | No restrictions | Complete lockdown | Only matching servers allowed |
| `deniedMcpServers` | No servers blocked | No servers blocked | Matching servers blocked |

Entry types: `serverName` (by name), `serverCommand` (exact command array match for stdio), `serverUrl` (wildcard URL pattern for remote servers).

**Denylist takes absolute precedence** over allowlist. Options 1 and 2 can be combined.

### Windows Note

On native Windows (not WSL), stdio servers using `npx` require a `cmd /c` wrapper:

```
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) -- MCP overview, popular servers, installing MCP servers (HTTP/SSE/stdio transports, option ordering), server management commands, dynamic tool updates via list_changed, push messages with channels, scope tips (local/project/user with --scope flag), environment variable expansion in .mcp.json, practical examples (Sentry monitoring, GitHub code reviews, PostgreSQL queries), OAuth 2.0 authentication (browser flow, fixed callback port, pre-configured credentials with --client-id/--client-secret/--callback-port, MCP_CLIENT_SECRET env var, authServerMetadataUrl override, CIMD auto-discovery), dynamic headers with headersHelper (shell command to stdout JSON, CLAUDE_CODE_MCP_SERVER_NAME/URL env vars, 10s timeout), adding servers from JSON (claude mcp add-json), importing from Claude Desktop (macOS/WSL), Claude.ai connector servers (ENABLE_CLAUDEAI_MCP_SERVERS), using Claude Code as MCP server (claude mcp serve, Claude Desktop config), MCP output limits (MAX_MCP_OUTPUT_TOKENS, warning threshold), elicitation (form mode, URL mode, Elicitation hook), MCP resources (@ mention with @server:protocol://path), Tool Search (ENABLE_TOOL_SEARCH values true/false/auto/auto:N, MCPSearch tool, 2KB description limit, model requirements), MCP prompts as commands (/mcp__server__prompt), plugin-provided MCP servers (automatic lifecycle, CLAUDE_PLUGIN_ROOT/DATA, transport types), MCP installation scopes (local/project/user with storage locations and precedence), environment variable expansion syntax, managed MCP configuration (managed-mcp.json exclusive control at system paths, allowedMcpServers/deniedMcpServers policy-based control with serverName/serverCommand/serverUrl matching, wildcard URL patterns, exact command matching, denylist precedence, combined options), Windows cmd /c wrapper for npx

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
