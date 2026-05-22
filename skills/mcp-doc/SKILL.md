---
name: mcp-doc
description: Complete official documentation for MCP (Model Context Protocol) in Claude Code — connecting to remote HTTP/SSE and local stdio servers, installation scopes (local/project/user), OAuth 2.0 authentication, dynamic headers, tool search (ENABLE_TOOL_SEARCH), output limits (MAX_MCP_OUTPUT_TOKENS), MCP prompts, resources, elicitation, channels, Claude Code as MCP server, plugin-provided MCP servers, and managed MCP configuration for organizations (managed-mcp.json, allowedMcpServers, deniedMcpServers).
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools via the Model Context Protocol (MCP), and for organizational control of MCP server access.

## Quick Reference

### CLI Commands

| Command | Description |
| :--- | :--- |
| `claude mcp add --transport http <name> <url>` | Add a remote HTTP server |
| `claude mcp add --transport sse <name> <url>` | Add a remote SSE server (deprecated) |
| `claude mcp add [--transport stdio] <name> -- <cmd> [args...]` | Add a local stdio server |
| `claude mcp add --scope <scope> ...` | Set scope: `local` (default), `project`, `user` |
| `claude mcp add --env KEY=val ...` | Pass environment variables to a stdio server |
| `claude mcp add --header "K: V" ...` | Pass static headers to an HTTP/SSE server |
| `claude mcp add-json <name> '<json>'` | Add a server from a JSON config blob |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS/WSL only) |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Show details for a server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset project-scope approval prompts |
| `claude mcp serve` | Run Claude Code itself as a stdio MCP server |
| `/mcp` | In-session: view status, authenticate, manage servers |

### Installation Scopes

| Scope | Stored in | Shared with team | Loads in |
| :--- | :--- | :--- | :--- |
| `local` (default) | `~/.claude.json` | No | Current project only |
| `project` | `.mcp.json` in project root | Yes (commit to VCS) | Current project only |
| `user` | `~/.claude.json` | No | All your projects |

Scope precedence (highest first): local > project > user > plugin-provided > claude.ai connectors.

### Transport Types

| Transport | `type` in JSON | Use for |
| :--- | :--- | :--- |
| HTTP (recommended) | `http` or `streamable-http` | Cloud/remote services |
| SSE | `sse` | Legacy remote services (deprecated) |
| Stdio | `stdio` | Local processes, scripts |

### Key Environment Variables

| Variable | Default | Description |
| :--- | :--- | :--- |
| `MCP_TIMEOUT` | — | Server startup timeout in milliseconds |
| `MCP_TOOL_TIMEOUT` | — | Per-tool execution timeout in milliseconds (overridden by per-server `timeout` field) |
| `MAX_MCP_OUTPUT_TOKENS` | 25,000 | Max tokens for MCP tool output (warning shown at 10,000) |
| `ENABLE_TOOL_SEARCH` | unset | Controls MCP tool deferral (see Tool Search table) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | `true` | Set `false` to disable claude.ai connector sync |
| `CLAUDE_PROJECT_DIR` | — | Set in spawned stdio server's environment; path to project root |

### Tool Search (`ENABLE_TOOL_SEARCH`) Values

| Value | Behavior |
| :--- | :--- |
| unset | All MCP tools deferred on demand; falls back to upfront loading on Vertex AI or non-first-party `ANTHROPIC_BASE_URL` |
| `true` | Force deferral everywhere, including Vertex AI |
| `auto` | Threshold mode: load upfront if tools fit within 10% of context window, defer otherwise |
| `auto:N` | Threshold mode with custom N% (0–100) |
| `false` | Load all MCP tools upfront; no deferral |

Requires Sonnet 4+ or Opus 4+ (Vertex AI: Sonnet 4.5+ / Opus 4.5+). Haiku does not support tool search.

### `.mcp.json` Server Config Fields

| Field | Description |
| :--- | :--- |
| `type` | `http`, `streamable-http`, `sse`, or `stdio` |
| `url` | Server URL (HTTP/SSE) |
| `command` | Executable path (stdio) |
| `args` | Argument list (stdio) |
| `env` | Environment variables passed to server |
| `headers` | Static HTTP headers (HTTP/SSE) |
| `headersHelper` | Shell command producing JSON headers at connect time |
| `timeout` | Per-tool execution timeout in milliseconds (hard wall-clock, overrides `MCP_TOOL_TIMEOUT`) |
| `alwaysLoad` | `true` — exempts server from tool search deferral (requires v2.1.121+) |
| `oauth` | OAuth config object: `clientId`, `callbackPort`, `authServerMetadataUrl`, `scopes` |

### Environment Variable Expansion in `.mcp.json`

Supported in `command`, `args`, `env`, `url`, and `headers`:

- `${VAR}` — expands to value of `VAR`; fails if unset and no default
- `${VAR:-default}` — expands to `VAR` if set, otherwise `default`

Plugin-provided configs also support `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`, and `${CLAUDE_PROJECT_DIR}`.

### OAuth Authentication

| Flag / Field | Description |
| :--- | :--- |
| `--callback-port PORT` | Fix OAuth redirect URI port (must match registered redirect URI) |
| `--client-id ID` | Pre-configured OAuth client ID |
| `--client-secret` | Prompts for client secret with masked input; or set via `MCP_CLIENT_SECRET` env var |
| `oauth.authServerMetadataUrl` | Override OAuth metadata discovery URL (requires v2.1.64+) |
| `oauth.scopes` | Space-separated scope string to pin during authorization |

Claude Code marks a server as needing auth when it responds with `401` or `403`. Use `/mcp` to complete the OAuth browser flow. Tokens are stored in the system keychain (macOS) or a credentials file.

Discovery order: RFC 9728 Protected Resource Metadata → RFC 8414 authorization server metadata.

### `headersHelper` for Dynamic Auth

Run a shell command at connection time; stdout must be a JSON object of string key-value pairs. Runs in a shell with a 10-second timeout. Receives `CLAUDE_CODE_MCP_SERVER_NAME` and `CLAUDE_CODE_MCP_SERVER_URL`.

### MCP Output Limits

| Setting | Value |
| :--- | :--- |
| Warning threshold | 10,000 tokens |
| Default max (`MAX_MCP_OUTPUT_TOKENS`) | 25,000 tokens |
| Per-tool annotation (`anthropic/maxResultSizeChars` in `_meta`) | Up to 500,000 characters for text content |

Tools that set `anthropic/maxResultSizeChars` in their `tools/list` `_meta` object bypass `MAX_MCP_OUTPUT_TOKENS` for text content. Image content is always subject to `MAX_MCP_OUTPUT_TOKENS`.

### MCP Prompts as Commands

MCP server prompts appear in Claude Code as slash commands with the format `/mcp__servername__promptname`. Pass arguments space-separated. Server and prompt names are normalized (spaces become underscores).

### MCP Resources via @ Mentions

Reference resources as `@server:protocol://resource/path`. Type `@` in a prompt to see autocomplete. Resources are fetched and attached automatically.

### Channels (Push Messages)

An MCP server can push messages into your session by declaring the `claude/channel` capability and enabling with `--channels` at startup. See the Channels and Channels reference docs for details.

### Reconnection Behavior

- HTTP/SSE servers: exponential backoff, up to 5 attempts (1s, 2s, 4s, 8s, 16s); initial connection retried up to 3 times on transient errors (5xx, connection refused, timeout). Auth/not-found errors not retried.
- Stdio servers: local processes, not reconnected automatically.

### Reserved Name

The server name `workspace` is reserved for internal use; Claude Code skips any server with that name at load time and shows a warning.

### Claude Code as an MCP Server

```bash
claude mcp serve
```

Exposes Claude Code's own tools (View, Edit, LS, etc.) to other MCP clients. Add to Claude Desktop via `claude_desktop_config.json` with `"command": "claude"` and `"args": ["mcp", "serve"]`. Use `which claude` to find the full path if needed.

---

## Managed MCP (Organizational Control)

### Restriction Patterns

| Pattern | Configure |
| :--- | :--- |
| Disable MCP entirely | `managed-mcp.json` with empty `mcpServers: {}` |
| Fixed server deployment | `managed-mcp.json` with the server list |
| Approved catalog | `allowedMcpServers` + `allowManagedMcpServersOnly: true` |
| Plugin servers only | `strictPluginOnlyCustomization` with `mcp` in the list |
| Soft allowlist | `allowedMcpServers` without `allowManagedMcpServersOnly` |
| Denylist only | `deniedMcpServers` |

### `managed-mcp.json` File Paths

| Platform | Path |
| :--- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux / WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

When `managed-mcp.json` is present, users cannot add, modify, or use any other MCP servers (including plugin-provided and claude.ai connectors). Delivered via MDM, GPO, or fleet management — cannot be set through server-managed settings.

### Allowlist / Denylist Match Keys

| Key | Matches | Use for |
| :--- | :--- | :--- |
| `serverUrl` | Remote server URL; supports `*` wildcards | HTTP and SSE servers |
| `serverCommand` | Exact command + arguments array | Stdio servers |
| `serverName` | User-assigned label; exact match only, no wildcards | Either type (not a security control on its own) |

`allowedMcpServers` unset = all allowed. Empty array `[]` = none allowed. Denylist always merges from all settings sources. Use `allowManagedMcpServersOnly: true` to prevent users from broadening the allowlist.

### Evaluation Order

1. Merge allowlist and denylist entries from all settings sources (if `allowManagedMcpServersOnly`, only managed allowlist is kept).
2. Check denylist — a match blocks unconditionally.
3. Check allowlist — if set, remote servers must match a `serverUrl` entry; stdio servers must match a `serverCommand` entry. `serverName` entries only count when no stricter entries of the same transport type exist.

### URL Wildcard Patterns

| Pattern | Matches |
| :--- | :--- |
| `https://mcp.example.com/*` | All paths on that domain |
| `https://mcp.example.com` | Also all paths (no path = any path) |
| `https://*.example.com/*` | Any subdomain |
| `http://localhost:*/*` | Any port on localhost |
| `*://mcp.example.com/*` | Any scheme to that domain |

Hostname matching is case-insensitive. Path matching is case-sensitive.

### Error Messages Users See

| Restriction | What the user sees |
| :--- | :--- |
| `managed-mcp.json` present + `claude mcp add` | `Cannot add MCP server: enterprise MCP configuration is active and has exclusive control over MCP servers` |
| Server on denylist + `claude mcp add` | `Cannot add MCP server "<name>": server is explicitly blocked by enterprise policy` |
| Server not on allowlist + `claude mcp add` | `Cannot add MCP server "<name>": not allowed by enterprise policy` |
| Previously configured server now blocked | Server silently disappears from `/mcp` and `claude mcp list` |

### Monitoring MCP Usage

Set `OTEL_LOG_TOOL_DETAILS=1` with OpenTelemetry export configured to include MCP server and tool names in tool events.

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — installing servers (HTTP/SSE/stdio), managing scopes, OAuth authentication, dynamic headers, tool search, output limits, elicitation, resources, prompts, channels, plugin-provided servers, and Claude Code as an MCP server
- [Control MCP server access for your organization](references/claude-code-managed-mcp.md) — managed-mcp.json deployment, allowlists, denylists, allowManagedMcpServersOnly, evaluation order, user-visible error messages, and usage monitoring

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
- Control MCP server access for your organization: https://code.claude.com/docs/en/managed-mcp.md
