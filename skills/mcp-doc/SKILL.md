---
name: mcp-doc
user-invocable: false
description: Complete official documentation for MCP (Model Context Protocol) in Claude Code — connecting servers, scopes, authentication, tool search, managed configuration, and more.
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools via the Model Context Protocol (MCP).

## Quick Reference

### `claude mcp` CLI Commands

| Command | Description |
| :--- | :--- |
| `claude mcp add --transport http <name> <url>` | Add a remote HTTP server (recommended) |
| `claude mcp add --transport sse <name> <url>` | Add a remote SSE server (deprecated) |
| `claude mcp add [--transport stdio] <name> -- <cmd> [args]` | Add a local stdio server |
| `claude mcp add-json <name> '<json>'` | Add a server from raw JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS/WSL only) |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Show details for a specific server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset approval choices for project-scoped servers |
| `/mcp` (in Claude Code) | Check server status, authenticate, manage OAuth |

### `claude mcp add` Flags

| Flag | Description |
| :--- | :--- |
| `--transport http\|sse\|stdio` | Transport type (default: stdio) |
| `--scope local\|project\|user` | Configuration scope (default: local) |
| `--env KEY=value` | Pass environment variable to the server |
| `--header "Key: Value"` | Add a request header (HTTP/SSE) |
| `--callback-port <PORT>` | Fix the OAuth callback port |
| `--client-id <ID>` | Pre-configured OAuth client ID |
| `--client-secret` | Prompt for OAuth client secret (masked) |

### Installation Scopes

| Scope | Stored in | Loads in | Shared with team |
| :--- | :--- | :--- | :--- |
| `local` (default) | `~/.claude.json` | Current project only | No |
| `project` | `.mcp.json` in project root | Current project only | Yes (via VCS) |
| `user` | `~/.claude.json` | All your projects | No |

Precedence (highest first): local → project → user → plugin-provided → claude.ai connectors.

### Server Configuration in `.mcp.json`

```json
{
  "mcpServers": {
    "my-http-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": { "Authorization": "Bearer ${API_KEY}" },
      "alwaysLoad": true
    },
    "my-stdio-server": {
      "command": "/path/to/server",
      "args": ["--flag"],
      "env": { "KEY": "value" }
    }
  }
}
```

Environment variable expansion: `${VAR}` and `${VAR:-default}` work in `command`, `args`, `env`, `url`, and `headers`.

### OAuth Authentication

| Scenario | Approach |
| :--- | :--- |
| Standard OAuth 2.0 | `claude mcp add`, then `/mcp` to authenticate in browser |
| Fixed callback port | Add `--callback-port <PORT>` |
| Pre-configured credentials | Add `--client-id <ID> --client-secret --callback-port <PORT>` |
| Override metadata discovery | Set `oauth.authServerMetadataUrl` in `.mcp.json` |
| Restrict scopes | Set `oauth.scopes` (space-separated) in `.mcp.json` |
| Custom auth (Kerberos, SSO) | Set `headersHelper` command in `.mcp.json` |

`headersHelper` must output a JSON object of string headers to stdout. Env vars `CLAUDE_CODE_MCP_SERVER_NAME` and `CLAUDE_CODE_MCP_SERVER_URL` are available to the helper.

### Tool Search (`ENABLE_TOOL_SEARCH`)

Controls whether MCP tool schemas are deferred until needed (keeps context usage low).

| Value | Behavior |
| :--- | :--- |
| (unset) | All MCP tools deferred on demand; falls back to upfront on Vertex AI / non-first-party `ANTHROPIC_BASE_URL` |
| `true` | All MCP tools deferred everywhere |
| `auto` | Threshold mode: upfront if tools fit within 10% of context window |
| `auto:<N>` | Threshold mode with custom percentage (0–100) |
| `false` | All MCP tools loaded upfront |

Requires Sonnet 4+ or Opus 4+ (Haiku does not support tool search). Set `alwaysLoad: true` on a server config to always load that server's tools upfront regardless of setting.

### MCP Output Token Limits

| Setting | Value |
| :--- | :--- |
| Warning threshold | 10,000 tokens |
| Default max (`MAX_MCP_OUTPUT_TOKENS`) | 25,000 tokens |
| Per-tool override | `_meta["anthropic/maxResultSizeChars"]` in `tools/list` (max 500,000 chars) |

### MCP Prompts as Commands

MCP prompts appear as `/mcp__<servername>__<promptname>` commands. Arguments are passed space-separated: `/mcp__github__pr_review 456`.

### MCP Resources via @ Mentions

Reference format: `@server:protocol://resource/path`. Resources appear in autocomplete when typing `@`.

### Reconnection Behavior

HTTP/SSE servers: automatic reconnection with exponential backoff (up to 5 attempts, starting at 1 second, doubling each time). Stdio servers are not reconnected automatically.

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers via `.mcp.json` at plugin root or inline in `plugin.json`. Use `${CLAUDE_PLUGIN_ROOT}` for bundled files and `${CLAUDE_PLUGIN_DATA}` for persistent state. Run `/reload-plugins` to connect/disconnect plugin servers after enabling/disabling a plugin mid-session.

### Managed MCP Configuration (Enterprise)

**Option 1 — Exclusive control** (`managed-mcp.json`): Deploys a fixed server list; users cannot add any other servers.

| Platform | Path |
| :--- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux / WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

**Option 2 — Policy-based** (`allowedMcpServers` / `deniedMcpServers` in managed settings): Users can add servers within restrictions. Each entry uses exactly one of: `serverName`, `serverCommand` (exact array match), or `serverUrl` (wildcard `*` supported). Denylist takes absolute precedence.

### Environment Variables

| Variable | Purpose |
| :--- | :--- |
| `MCP_TIMEOUT` | Server startup timeout in ms (e.g., `MCP_TIMEOUT=10000`) |
| `MAX_MCP_OUTPUT_TOKENS` | Max output tokens per tool call (default 25,000) |
| `ENABLE_TOOL_SEARCH` | Tool search mode (see table above) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set `false` to disable claude.ai connector sync |
| `MCP_CONNECTION_NONBLOCKING` | Set `1` to connect servers in background (except `alwaysLoad` servers) |
| `MCP_CLIENT_SECRET` | Client secret for OAuth (skips interactive prompt) |

### Use Claude Code as an MCP Server

```bash
claude mcp serve
```

Exposes Claude Code's built-in tools (View, Edit, LS, etc.) to any MCP client via stdio.

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — Full guide: installation, scopes, authentication, tool search, managed config, elicitation, resources, and more

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
