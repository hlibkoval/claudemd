---
name: mcp-doc
user-invocable: false
---

# MCP (Model Context Protocol) Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools and data sources via MCP.

## Quick Reference

### CLI Commands

| Command | Description |
|---|---|
| `claude mcp add --transport http <name> <url>` | Add a remote HTTP server |
| `claude mcp add --transport sse <name> <url>` | Add a remote SSE server (deprecated) |
| `claude mcp add [--transport stdio] <name> -- <cmd> [args...]` | Add a local stdio server |
| `claude mcp add-json <name> '<json>'` | Add a server from JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS/WSL only) |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Get details for a specific server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset approval choices for project-scoped servers |
| `claude mcp serve` | Start Claude Code itself as an MCP server |
| `/mcp` | Check server status and authenticate inside Claude Code |

### Scopes

| Scope | Stored in | Loads in | Shared |
|---|---|---|---|
| `local` (default) | `~/.claude.json` | Current project only | No |
| `project` | `.mcp.json` in project root | Current project only | Yes (via VCS) |
| `user` | `~/.claude.json` | All projects | No |

Scope precedence (highest first): local → project → user → plugin-provided → claude.ai connectors.

### Transport Types

| Transport | `type` field | Use case |
|---|---|---|
| HTTP (recommended) | `http` or `streamable-http` | Cloud-based remote services |
| SSE | `sse` | Remote servers (deprecated, use HTTP) |
| stdio | `stdio` | Local processes needing system access |

### Key Environment Variables

| Variable | Purpose |
|---|---|
| `MCP_TIMEOUT` | Server startup timeout in ms (e.g. `MCP_TIMEOUT=10000`) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens per MCP tool output (default: 25,000; warning at 10,000) |
| `ENABLE_TOOL_SEARCH` | Control tool search behavior (see below) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set to `false` to disable claude.ai MCP servers |
| `CLAUDE_PROJECT_DIR` | Set in stdio server environment — the project root path |
| `MCP_CLIENT_SECRET` | Pass OAuth client secret non-interactively |

### Tool Search (`ENABLE_TOOL_SEARCH`)

| Value | Behavior |
|---|---|
| (unset) | All MCP tools deferred (default); falls back to upfront on Vertex AI or custom `ANTHROPIC_BASE_URL` |
| `true` | All MCP tools deferred, forces beta header even on Vertex AI |
| `auto` | Threshold mode: load upfront if within 10% of context window, defer otherwise |
| `auto:N` | Custom threshold percentage (0–100) |
| `false` | All MCP tools loaded upfront, no deferral |

Requires Sonnet 4+ or Opus 4+ (Haiku not supported). On Vertex AI: Sonnet 4.5+ or Opus 4.5+.

### `.mcp.json` Server Configuration Schema

```json
{
  "mcpServers": {
    "server-name": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": { "Authorization": "Bearer ${API_KEY}" },
      "alwaysLoad": false,
      "oauth": {
        "clientId": "...",
        "callbackPort": 8080,
        "authServerMetadataUrl": "https://auth.example.com/.well-known/openid-configuration",
        "scopes": "read write"
      },
      "headersHelper": "/path/to/script.sh"
    }
  }
}
```

For stdio servers: use `"command"`, `"args"`, and `"env"` fields instead of `"url"`.

Environment variable expansion (`${VAR}` and `${VAR:-default}`) is supported in `command`, `args`, `env`, `url`, and `headers`.

### OAuth Authentication

1. Add server: `claude mcp add --transport http <name> <url>`
2. Authenticate: run `/mcp` in Claude Code, follow browser flow
3. Tokens are stored securely and refreshed automatically

For pre-configured OAuth credentials (when server doesn't support dynamic client registration):
```bash
claude mcp add --transport http \
  --client-id your-client-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

Use `--callback-port` to fix the OAuth callback port for pre-registered redirect URIs.

Use `headersHelper` in `.mcp.json` for non-OAuth custom auth (Kerberos, SSO, short-lived tokens). The helper must write a JSON object of string key-value pairs to stdout and has a 10-second timeout. Claude Code sets `CLAUDE_CODE_MCP_SERVER_NAME` and `CLAUDE_CODE_MCP_SERVER_URL` in the helper's environment.

### MCP Resources (@ mentions)

Reference MCP resources with `@server:protocol://resource/path` syntax, e.g.:
- `@github:issue://123`
- `@docs:file://api/authentication`

Type `@` in a prompt to see autocomplete of available resources.

### MCP Prompts as Commands

MCP prompts appear as `/mcp__servername__promptname` commands. Execute with optional space-separated args:
- `/mcp__github__list_prs`
- `/mcp__github__pr_review 456`

### Output Limits

| Setting | Default |
|---|---|
| Warning threshold | 10,000 tokens |
| Max output (`MAX_MCP_OUTPUT_TOKENS`) | 25,000 tokens |
| Per-tool override (`_meta["anthropic/maxResultSizeChars"]`) | Up to 500,000 chars |

### Reconnection

HTTP/SSE servers: automatic exponential backoff — up to 5 attempts, starting at 1s and doubling each time. After 5 failures, marked as failed (retry from `/mcp`). Stdio servers are not reconnected automatically. Initial connection retried up to 3 times on transient errors (5xx, connection refused, timeout).

### `alwaysLoad`

Set `alwaysLoad: true` in a server's config (or `"anthropic/alwaysLoad": true` in a tool's `_meta`) to load that server's tools into context at session start, bypassing tool search deferral. Blocks session startup until the server connects (up to the 5-second timeout). Requires Claude Code v2.1.121+.

### Managed MCP Configuration (Enterprise)

**Option 1 — Exclusive control** (`managed-mcp.json`): Deploy to system path (e.g. `/etc/claude-code/managed-mcp.json` on Linux). Uses the same format as `.mcp.json`. Users cannot add any other servers.

**Option 2 — Policy-based** (`allowedMcpServers` / `deniedMcpServers` in managed settings): Allow/block by `serverName`, `serverCommand` (exact array match), or `serverUrl` (wildcard `*` supported). Denylist takes absolute precedence.

System paths for `managed-mcp.json`:
- macOS: `/Library/Application Support/ClaudeCode/managed-mcp.json`
- Linux/WSL: `/etc/claude-code/managed-mcp.json`
- Windows: `C:\Program Files\ClaudeCode\managed-mcp.json`

### Plugin-provided MCP Servers

Plugins can bundle MCP servers in `.mcp.json` at the plugin root or inline in `plugin.json`. Available template variables: `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`, `${CLAUDE_PROJECT_DIR}`. Run `/reload-plugins` after enabling/disabling a plugin to connect/disconnect its servers.

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — Full guide covering installation, scopes, authentication, tool search, managed configuration, and enterprise controls

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
