---
name: mcp-doc
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools and data sources via the Model Context Protocol (MCP), including server configuration, authentication, organization-level access controls, and a quickstart walkthrough.

## Quick Reference

### Transport Types

| Transport | `type` field | `claude mcp add` flag | Use for |
| :--- | :--- | :--- | :--- |
| HTTP (Streamable HTTP) | `http` or `streamable-http` | `--transport http` | Remote hosted services; supports OAuth |
| SSE (deprecated) | `sse` | `--transport sse` | Legacy remote servers |
| stdio | `stdio` | (default, omit flag) | Local processes; use `--` separator before command |
| WebSocket | `ws` | `claude mcp add-json` only | Persistent bidirectional, event-pushing servers |

### CLI Command Reference

| Command | Description |
| :--- | :--- |
| `claude mcp add --transport http <name> <url>` | Add a remote HTTP server |
| `claude mcp add [--transport stdio] <name> -- <cmd> [args...]` | Add a local stdio server |
| `claude mcp add --transport http <name> <url> --header "Authorization: Bearer <token>"` | Add server with static auth header |
| `claude mcp add --scope <local\|project\|user> ...` | Add at a specific scope |
| `claude mcp add-json <name> '<json>'` | Add server from JSON config |
| `claude mcp add-from-claude-desktop` | Import from Claude Desktop (macOS/WSL only) |
| `claude mcp list` | List all configured servers with status |
| `claude mcp get <name>` | Show details for a specific server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset `.mcp.json` project approval choices |
| `/mcp` | View, authenticate, and manage servers inside a session |

### Installation Scopes

| Scope | Stored in | Available to |
| :--- | :--- | :--- |
| `local` (default) | `~/.claude.json` under project path | Only you, current project only |
| `project` | `.mcp.json` in project root | Everyone via version control |
| `user` | `~/.claude.json` top-level `mcpServers` | Only you, all projects |

Precedence (highest first): local → project → user → plugin-provided → claude.ai connectors. Same-name duplicates use only the highest-precedence definition.

### Server Status Indicators (in `claude mcp list` / `/mcp`)

| Status | Meaning |
| :--- | :--- |
| `✓ Connected` | Ready to use |
| `! Connected · tools fetch failed` | Connected but tool list failed; run `claude mcp get <name>` |
| `! Needs authentication` | Requires OAuth browser sign-in via `/mcp` |
| `✗ Failed to connect` | Server didn't respond |
| `✗ Connection error` | Connection attempt threw an error |
| `⏸ Pending approval` | Project-scoped server awaiting your approval |

### Environment Variables

| Variable | Default | Description |
| :--- | :--- | :--- |
| `MCP_TIMEOUT` | 30000 (ms) | Startup connection timeout |
| `MCP_TOOL_TIMEOUT` | ~28 hours | Per-tool-call execution timeout |
| `MAX_MCP_OUTPUT_TOKENS` | 25000 | Max tokens per tool output; warning shown above 10,000 |
| `ENABLE_TOOL_SEARCH` | (unset) | Controls MCP tool deferral behavior (see Tool Search) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | `true` | Set `false` to disable claude.ai connectors |
| `CLAUDE_PROJECT_DIR` | project root | Injected into stdio server environments |

Per-server tool timeout: add `"timeout": <ms>` to the server's `.mcp.json` entry. Values below 1000 are ignored (falls through to `MCP_TOOL_TIMEOUT`).

### `.mcp.json` Server Entry Fields

**HTTP server:**
```json
{
  "type": "http",
  "url": "https://mcp.example.com/mcp",
  "headers": { "Authorization": "Bearer ${API_KEY}" },
  "headersHelper": "/path/to/script.sh",
  "oauth": { "clientId": "...", "callbackPort": 8080, "scopes": "read write", "authServerMetadataUrl": "..." },
  "alwaysLoad": false,
  "timeout": 60000
}
```

**Stdio server:**
```json
{
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "my-mcp-server"],
  "env": { "API_KEY": "${API_KEY}" }
}
```

**Environment variable expansion in `.mcp.json`:** `${VAR}` and `${VAR:-default}` work in `command`, `args`, `env`, `url`, and `headers`.

### OAuth Authentication

Claude Code supports OAuth 2.0 for remote MCP servers. A server is flagged for auth when it returns `401` or `403`.

| Scenario | How to configure |
| :--- | :--- |
| Standard OAuth (dynamic client registration) | Run `/mcp` → select server → Authenticate |
| Fixed callback port | `--callback-port <port>` |
| Pre-configured credentials | `--client-id <id> --client-secret --callback-port <port>` |
| CI/env var for secret | `MCP_CLIENT_SECRET=... claude mcp add ...` |
| Custom discovery URL | `oauth.authServerMetadataUrl` in `.mcp.json` |
| Restrict scopes | `oauth.scopes: "scope1 scope2"` in `.mcp.json` |
| Dynamic headers (non-OAuth) | `headersHelper` field; script writes JSON to stdout |

`headersHelper` environment: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`. Runs in a shell with 10-second timeout; re-runs on each connect.

### MCP Tool Search (Tool Deferral)

By default, MCP tool schemas are not loaded at session start — Claude discovers them on demand via a search step, keeping context usage low.

| `ENABLE_TOOL_SEARCH` value | Behavior |
| :--- | :--- |
| (unset) | Deferred on first-party; falls back to upfront on Vertex AI or non-first-party `ANTHROPIC_BASE_URL` |
| `true` | Always deferred, even on Vertex AI |
| `auto` | Upfront if fits within 10% of context window, else deferred |
| `auto:N` | Custom threshold percentage (0-100) |
| `false` | Always loaded upfront |

Set `"alwaysLoad": true` in a server's `.mcp.json` entry to exempt that server from deferral. Individual tools can also set `"anthropic/alwaysLoad": true` in their `_meta` object.

To disable `ToolSearch` as a tool: add `"deny": ["ToolSearch"]` to `permissions` in settings.

Tool search requires model support for `tool_reference` blocks. Haiku models do not support it. On Vertex AI, requires Sonnet 4.5+ or Opus 4.5+.

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers in `.mcp.json` at the plugin root or inline in `plugin.json`. They start automatically when the plugin is enabled. Run `/reload-plugins` to connect/disconnect after enabling/disabling a plugin mid-session.

Plugin MCP tool naming: `mcp__plugin_<plugin-name>_<server-name>__<tool-name>` (non-alphanumeric characters replaced with `_`).

Available env vars in plugin MCP configs: `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`, `${CLAUDE_PROJECT_DIR}`.

### MCP Resources and Prompts

**Resources** — reference with `@server:protocol://resource/path` syntax in prompts. Type `@` to see autocomplete.

**Prompts** — exposed by MCP servers as slash commands, format: `/mcp__servername__promptname [args...]`.

### Using Claude Code as an MCP Server

```bash
claude mcp serve
```

Add to `claude_desktop_config.json` with `"command": "claude", "args": ["mcp", "serve"]`. If `claude` is not in PATH, use the full path (`which claude`).

### Raise Per-Tool Output Limit (for MCP Server Authors)

Set `_meta["anthropic/maxResultSizeChars"]` in a tool's `tools/list` response entry to raise its threshold up to 500,000 chars for text content:

```json
{ "name": "get_schema", "_meta": { "anthropic/maxResultSizeChars": 200000 } }
```

### MCP Elicitation

MCP servers can request structured user input mid-task. Claude Code shows a dialog automatically — no configuration needed on the client side. To auto-respond without a dialog, use the `Elicitation` hook.

### Channels (Event Push)

An MCP server can push messages into your session by declaring the `claude/channel` capability. Opt in with `--channels` at startup. See the Channels reference for building your own.

### Reconnection Behavior

HTTP/SSE servers: automatic reconnect with exponential backoff (up to 5 attempts, starting at 1 second, doubling each time). After 5 failures the server is marked failed and can be retried from `/mcp`. Stdio servers are not reconnected automatically.

Initial connection: retried up to 3 times on transient errors (5xx, connection refused, timeout). Auth errors and 404s are not retried.

### Managed MCP Configuration (Admin Controls)

**Deployment patterns:**

| Pattern | Configuration |
| :--- | :--- |
| Disable MCP entirely | `managed-mcp.json` with empty `mcpServers: {}` |
| Fixed server set (exclusive) | `managed-mcp.json` with server definitions |
| Approved catalog (hard allowlist) | `allowedMcpServers` + `allowManagedMcpServersOnly: true` |
| Soft allowlist (users can broaden) | `allowedMcpServers` without `allowManagedMcpServersOnly` |
| Denylist only | `deniedMcpServers` |

**`managed-mcp.json` paths:**

| Platform | Path |
| :--- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux/WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

When `managed-mcp.json` is present, users cannot add other servers. Claude.ai connectors are also suppressed unless `allowAllClaudeAiMcps: true` is set in a managed settings source.

**Allowlist/denylist matching:**

| Key | Matches | Notes |
| :--- | :--- | :--- |
| `serverUrl` | Remote server URL, `*` wildcards supported | Hostname match is case-insensitive |
| `serverCommand` | Exact command + args array | Every argument must match exactly |
| `serverName` | User-assigned label | Not a security control; user can rename any server |

Evaluation order: merge lists → check denylist (blocks unconditionally) → check allowlist.

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — Full MCP reference: transports, scopes, authentication (OAuth, headers, headersHelper), tool search, plugin MCP servers, resources, prompts, channels, output limits, elicitation
- [Control MCP server access for your organization](references/claude-code-managed-mcp.md) — Admin controls: managed-mcp.json, allowlists/denylists, restriction patterns, monitoring MCP usage
- [Connect to MCP servers (quickstart)](references/claude-code-mcp-quickstart.md) — Step-by-step walkthrough: add and verify a server, scopes, local stdio servers, OAuth sign-in, editing .mcp.json directly, troubleshooting

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
- Control MCP server access for your organization: https://code.claude.com/docs/en/managed-mcp.md
- Connect to MCP servers (quickstart): https://code.claude.com/docs/en/mcp-quickstart.md
