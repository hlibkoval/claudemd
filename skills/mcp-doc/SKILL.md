---
name: mcp-doc
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for the Model Context Protocol (MCP) in Claude Code: connecting servers, transports, scopes, authentication, managed configuration, organization controls, and a step-by-step quickstart.

## Quick Reference

### Transport Types

| Transport | Type value | Use for |
|:----------|:-----------|:--------|
| HTTP (streamable-http) | `http` / `streamable-http` | Remote cloud-based services (recommended) |
| SSE | `sse` | Remote servers (deprecated; prefer HTTP) |
| Stdio | `stdio` | Local processes with direct system access |
| WebSocket | `ws` | Remote servers that push events unprompted |

### `claude mcp` CLI Commands

| Command | Description |
|:--------|:------------|
| `claude mcp add --transport http <name> <url>` | Add a remote HTTP server |
| `claude mcp add --transport sse <name> <url>` | Add a remote SSE server (deprecated) |
| `claude mcp add [--transport stdio] <name> -- <cmd> [args...]` | Add a local stdio server (`--` separates server args) |
| `claude mcp add-json <name> '<json>'` | Add server from JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS/WSL only) |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Show details for a specific server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset `.mcp.json` project approval choices |
| `claude mcp serve` | Run Claude Code itself as an MCP stdio server |
| `/mcp` | (In-session) Check status, authenticate, manage servers |

### Installation Scopes

| Scope | Stored in | Available to | Default? |
|:------|:----------|:-------------|:---------|
| `local` | `~/.claude.json` (per-project entry) | Only you, current project | Yes |
| `project` | `.mcp.json` in project root | Everyone who clones the project | No |
| `user` | `~/.claude.json` (top-level `mcpServers`) | Only you, all projects | No |

Use `--scope local|project|user` on `claude mcp add`. Precedence (highest first): local → project → user → plugin-provided → claude.ai connectors. Same-name duplicates resolve to the highest-precedence source; the entire entry is used, fields are not merged.

### `.mcp.json` Server Entry Fields

| Field | Type | Description |
|:------|:-----|:------------|
| `type` | string | `"http"` / `"streamable-http"`, `"sse"`, `"stdio"`, `"ws"` |
| `url` | string | Endpoint URL (HTTP/SSE/WebSocket) |
| `command` | string | Executable to launch (stdio) |
| `args` | array | Arguments for the command (stdio) |
| `env` | object | Environment variables passed to the server |
| `headers` | object | Static request headers (HTTP/SSE/WebSocket) |
| `headersHelper` | string | Shell command that outputs `{"Header": "value"}` JSON at connect time |
| `oauth` | object | OAuth settings: `clientId`, `callbackPort`, `scopes`, `authServerMetadataUrl` |
| `timeout` | number | Per-tool-call wall-clock timeout in milliseconds (≥1000; overrides `MCP_TOOL_TIMEOUT`) |
| `alwaysLoad` | boolean | If `true`, load all tools upfront regardless of tool-search setting (requires v2.1.121+) |

### Environment Variable Expansion in `.mcp.json`

| Syntax | Behavior |
|:-------|:---------|
| `${VAR}` | Expands to the value of `VAR`; fails if unset with no default |
| `${VAR:-default}` | Expands to `VAR` if set, otherwise uses `default` |

Supported in: `command`, `args`, `env`, `url`, `headers`.

### OAuth Authentication

| Topic | Detail |
|:------|:-------|
| When triggered | Server responds `401 Unauthorized` or `403 Forbidden` |
| Flow | Use `/mcp` in-session → select server → Authenticate → browser sign-in |
| Token storage | Securely stored; refreshed automatically |
| Fixed callback port | `--callback-port <port>` on `claude mcp add` |
| Pre-configured credentials | `--client-id <id> --client-secret --callback-port <port>` |
| CI / env var | `MCP_CLIENT_SECRET=<secret> claude mcp add ...` |
| Custom auth metadata URL | `oauth.authServerMetadataUrl` in `.mcp.json` |
| Restrict OAuth scopes | `oauth.scopes` as a space-separated string (RFC 6749 §3.3) |
| Dynamic headers | `headersHelper` — shell command returning JSON headers |

`headersHelper` receives `CLAUDE_CODE_MCP_SERVER_NAME` and `CLAUDE_CODE_MCP_SERVER_URL` in its environment. Runs fresh on each connection; no caching.

### Tool Search (`ENABLE_TOOL_SEARCH`)

| Value | Behavior |
|:------|:---------|
| (unset) | All MCP tools deferred (on-demand). Falls back to upfront load on Vertex AI or non-first-party `ANTHROPIC_BASE_URL` |
| `true` | Always defer, even on Vertex AI / proxies (may fail on unsupported models) |
| `auto` | Threshold mode: load upfront if tools fit within 10% of context window |
| `auto:N` | Threshold mode with custom N% (0–100) |
| `false` | All tools loaded upfront; no deferral |

Supported models: Sonnet 4+, Opus 4+. Not supported on Haiku models. On Vertex AI: Sonnet 4.5+ and Opus 4.5+.

To exempt a specific server from deferral, set `"alwaysLoad": true` in its config. Individual tools can also declare `"anthropic/alwaysLoad": true` in their `_meta` object.

### MCP Output Limits

| Setting | Default | Description |
|:--------|:--------|:------------|
| Warning threshold | 10,000 tokens | Claude Code shows a warning |
| Max output tokens | 25,000 tokens | Default cap (`MAX_MCP_OUTPUT_TOKENS` env var to override) |
| Per-tool override | up to 500,000 chars | Set `_meta["anthropic/maxResultSizeChars"]` in `tools/list` response |

`MAX_MCP_OUTPUT_TOKENS` does not apply to tools that declare `anthropic/maxResultSizeChars` for text content, but still applies to image data.

### Connection Status Indicators

| Status | Meaning |
|:-------|:--------|
| `✓ Connected` | Ready to use |
| `! Needs authentication` | Reachable but requires OAuth sign-in or token |
| `✗ Failed to connect` | Server didn't respond |
| `✗ Connection error` | Connection attempt threw an error |
| `⏸ Pending approval` | Project-scoped `.mcp.json` server awaiting approval |

Automatic reconnection (HTTP/SSE): up to 5 attempts with exponential backoff (1s start, doubling). Stdio servers are not auto-reconnected.

### MCP Prompts as Commands

MCP server prompts appear as `/mcp__<servername>__<promptname>` commands. Pass arguments space-separated after the command name. Server and prompt names are normalized (spaces become underscores).

### MCP Resources via @ Mentions

Reference MCP resources in prompts as `@server:protocol://resource/path`. Resources appear alongside files in the `@` autocomplete menu and are fetched as conversation attachments.

### Environment Variables for MCP

| Variable | Description |
|:---------|:------------|
| `MCP_TIMEOUT` | Startup timeout in milliseconds (default 30,000ms) |
| `MCP_TOOL_TIMEOUT` | Default per-tool-call timeout (~28 hours if unset) |
| `MAX_MCP_OUTPUT_TOKENS` | Cap on tool output tokens (default 25,000) |
| `ENABLE_TOOL_SEARCH` | Control tool deferral (see table above) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set to `false` to disable claude.ai connectors in Claude Code |
| `CLAUDE_PROJECT_DIR` | Set in spawned stdio server's environment; resolves to project root |

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers via `.mcp.json` at the plugin root or inline in `plugin.json`. Use `${CLAUDE_PLUGIN_ROOT}` for bundled files, `${CLAUDE_PLUGIN_DATA}` for persistent state, `${CLAUDE_PROJECT_DIR}` for the project root. Servers start automatically when the plugin is enabled; run `/reload-plugins` after enabling/disabling a plugin mid-session.

### Managed MCP Configuration (Org Admins)

| Pattern | Configure with |
|:--------|:--------------|
| Disable MCP entirely | `managed-mcp.json` with empty `mcpServers: {}` |
| Fixed deployment | `managed-mcp.json` with the desired servers |
| Approved catalog | `allowedMcpServers` + `allowManagedMcpServersOnly: true` |
| Plugin servers only | `strictPluginOnlyCustomization` with `mcp` in the list |
| Soft allowlist | `allowedMcpServers` without `allowManagedMcpServersOnly` |
| Denylist only | `deniedMcpServers` |

**`managed-mcp.json` system paths:**

| Platform | Path |
|:---------|:-----|
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux / WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

When `managed-mcp.json` is present, users cannot add other servers. Claude.ai connectors are also suppressed unless `allowAllClaudeAiMcps: true` is set in a managed settings source (requires v2.1.149+).

**Allowlist/denylist matching keys:**

| Key | Matches | Notes |
|:----|:--------|:------|
| `serverUrl` | Remote URL, exact or `*` wildcards | For HTTP/SSE; wildcard hostname match is case-insensitive |
| `serverCommand` | Exact command + args array | For stdio; every argument must match in order |
| `serverName` | User-assigned label, exact match | Weak control — not a security boundary on its own |

Evaluation order: merge lists → check denylist (always wins) → check allowlist. `allowManagedMcpServersOnly: true` locks the allowlist to managed sources; denylist always merges from all sources.

**Error messages users see:**

| Situation | Message |
|:----------|:--------|
| `managed-mcp.json` present, user runs `claude mcp add` | `Cannot add MCP server: enterprise MCP configuration is active and has exclusive control over MCP servers` |
| Server on denylist | `Cannot add MCP server "<name>": server is explicitly blocked by enterprise policy` |
| Server not on allowlist | `Cannot add MCP server "<name>": not allowed by enterprise policy` |
| Previously configured server now blocked | Silently disappears from `/mcp` and `claude mcp list` |

### Common Troubleshooting

| Symptom | Check / Fix |
|:--------|:------------|
| `/mcp` shows no servers | Wrong project directory (local scope is tied to the directory you added it from); wrong config file path |
| `Failed to connect` / `Connection error` | For HTTP: `curl -I <url>` to test reachability; 401/403 → authenticate; 404/405 → URL is reachable (MCP may require POST only). For stdio: run the command directly in your terminal |
| Connection timed out at startup | Increase `MCP_TIMEOUT` (e.g., `MCP_TIMEOUT=60000 claude`) |
| `Server already exists` | Remove the existing entry first with `claude mcp remove <name> [--scope <scope>]` |
| Server connects but no tools | Missing env var (e.g., API key); pass with `--env KEY=value` on `claude mcp add` or in `.mcp.json` `env` |
| `.mcp.json` changes not taking effect | Claude Code reads it at session start; exit and restart. Check `/mcp` for parse warnings. If previously rejected: run `claude mcp reset-project-choices` |
| OAuth sign-in fails | Run `/mcp` → select server → Authenticate again; copy URL manually if browser doesn't open |

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — Full reference: transports, scopes, authentication, tool search, output limits, elicitation, resources, MCP prompts, plugin-provided servers, managed configuration
- [Control MCP server access for your organization](references/claude-code-managed-mcp.md) — Admin controls: managed-mcp.json, allowlists, denylists, patterns, user-facing errors, monitoring usage
- [Connect to MCP servers (Quickstart)](references/claude-code-mcp-quickstart.md) — Step-by-step walkthrough: add a server, check status, authenticate, change scope, edit .mcp.json directly, troubleshooting

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
- Control MCP server access for your organization: https://code.claude.com/docs/en/managed-mcp.md
- Connect to MCP servers (Quickstart): https://code.claude.com/docs/en/mcp-quickstart.md
