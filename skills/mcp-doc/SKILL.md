---
name: mcp-doc
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools via the Model Context Protocol (MCP) — including installing servers, authentication, scopes, managed configuration, and tool search.

## Quick Reference

### Transport Types

| Transport | `type` value | CLI flag | Use for |
| :--- | :--- | :--- | :--- |
| HTTP (Streamable) | `http` or `streamable-http` | `--transport http` | Cloud services; recommended |
| SSE | `sse` | `--transport sse` | Legacy remote servers (deprecated) |
| stdio | `stdio` | default / `--transport stdio` | Local processes |
| WebSocket | `ws` | JSON config only (`add-json`) | Event-pushing remote servers |

### CLI Commands

| Command | Description |
| :--- | :--- |
| `claude mcp add --transport http <name> <url>` | Add a remote HTTP server |
| `claude mcp add [--transport stdio] <name> -- <cmd> [args]` | Add a local stdio server |
| `claude mcp add-json <name> '<json>'` | Add server from JSON config |
| `claude mcp add-from-claude-desktop` | Import from Claude Desktop (macOS/WSL) |
| `claude mcp login <name>` | Run OAuth flow from shell (v2.1.186+) |
| `claude mcp logout <name>` | Clear stored OAuth credentials |
| `claude mcp list` | List all configured servers with status |
| `claude mcp get <name>` | Show details for a specific server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset `.mcp.json` approval choices |
| `/mcp` (in-session) | Check status, authenticate, manage servers |

### Installation Scopes

| Scope | CLI flag | Stored in | Available to |
| :--- | :--- | :--- | :--- |
| `local` (default) | `--scope local` | `~/.claude.json` (per-project) | Only you, current project |
| `project` | `--scope project` | `.mcp.json` in project root | Everyone (via version control) |
| `user` | `--scope user` | `~/.claude.json` (global) | Only you, all projects |

Precedence (highest to lowest): local > project > user > plugin-provided > claude.ai connectors

### Key Environment Variables

| Variable | Default | Purpose |
| :--- | :--- | :--- |
| `MCP_TIMEOUT` | 30000 ms | Server startup timeout |
| `MCP_TOOL_TIMEOUT` | ~28 hours | Per-tool-call execution timeout |
| `MAX_MCP_OUTPUT_TOKENS` | 25000 | Max tokens per tool output (warning at 10k) |
| `ENABLE_TOOL_SEARCH` | (unset) | Control MCP tool search deferral |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | true | Set to `false` to disable claude.ai connectors |

### `ENABLE_TOOL_SEARCH` Values

| Value | Behavior |
| :--- | :--- |
| (unset) | All MCP tools deferred on demand; loads upfront on Vertex AI or custom `ANTHROPIC_BASE_URL` |
| `true` | All tools deferred; forces the beta header everywhere |
| `auto` | Threshold mode: upfront if tools fit within 10% of context window |
| `auto:N` | Threshold with custom percentage (0–100) |
| `false` | All tools loaded upfront, no deferral |

### `.mcp.json` Server Entry Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `type` | string | `"http"`, `"streamable-http"`, `"sse"`, `"stdio"`, `"ws"` |
| `url` | string | Endpoint URL (HTTP/SSE/WebSocket) |
| `command` | string | Executable path (stdio) |
| `args` | array | Arguments to the command (stdio) |
| `env` | object | Environment variables passed to the server |
| `headers` | object | Static request headers (HTTP/SSE) |
| `headersHelper` | string | Shell command that returns headers as JSON (runs at connect time) |
| `timeout` | number | Per-tool-call wall-clock limit in milliseconds (overrides `MCP_TOOL_TIMEOUT`; min 1000) |
| `alwaysLoad` | boolean | Load tools into context upfront instead of deferring (v2.1.121+) |
| `oauth` | object | OAuth config: `clientId`, `clientSecret`, `callbackPort`, `authServerMetadataUrl`, `scopes` |

Environment variable expansion in `.mcp.json`: `${VAR}` and `${VAR:-default}` are supported in `command`, `args`, `env`, `url`, and `headers`.

### Plugin MCP Server Tool Name Format

Tools from a plugin-bundled MCP server are callable as:
```
mcp__plugin_<plugin-name>_<server-name>__<tool-name>
```
Characters outside `A-Z`, `a-z`, `0-9`, `_`, `-` are replaced with `_`.

### `claude.ai` Connector Variable

| Setting | Effect |
| :--- | :--- |
| `disableClaudeAiConnectors: true` | Disables all claude.ai connectors (any-source-true semantics) |

### Status Indicators (`claude mcp list` / `/mcp`)

| Status | Meaning |
| :--- | :--- |
| `✓ Connected` | Ready to use |
| `! Connected · tools fetch failed` | Connected but couldn't list tools |
| `! Needs authentication` | Reachable but requires sign-in |
| `✗ Failed to connect` | Server didn't respond |
| `✗ Connection error` | Connection threw an error |
| `⏸ Pending approval` | Project-scoped server awaiting your approval |

### Managed MCP (Admin Control Patterns)

| Pattern | Configuration |
| :--- | :--- |
| Disable MCP entirely | `managed-mcp.json` with empty `mcpServers: {}` |
| Fixed deployment | `managed-mcp.json` with the approved server set |
| Approved catalog | `allowedMcpServers` + `allowManagedMcpServersOnly: true` |
| Plugin servers only | `strictPluginOnlyCustomization` with `mcp` |
| Soft allowlist | `allowedMcpServers` without `allowManagedMcpServersOnly` |
| Denylist only | `deniedMcpServers` |

`managed-mcp.json` system paths:

| Platform | Path |
| :--- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux / WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

### Allow/Deny List Entry Keys

| Key | Matches | Wildcards |
| :--- | :--- | :--- |
| `serverUrl` | Remote server URL | `*` wildcards supported |
| `serverCommand` | Exact command + args array | Exact match only |
| `serverName` | User-assigned label | Exact match only (not a security control) |

Denylist always wins. An empty `allowedMcpServers: []` blocks all servers; unset allows all.

### MCP Resources via @ Mentions

Reference MCP resources using: `@server:protocol://resource/path`

Example: `@github:issue://123`

### MCP Prompts as Commands

MCP prompts appear as slash commands with the format: `/mcp__servername__promptname`

Pass arguments space-separated after the command.

### `anthropic/maxResultSizeChars` Tool Annotation

Set this in a tool's `_meta` object (in `tools/list` response) to raise that tool's output threshold above the default disk-persist threshold, up to 500,000 characters. Independent of `MAX_MCP_OUTPUT_TOKENS` for text content.

### `headersHelper` Environment Variables

| Variable | Value |
| :--- | :--- |
| `CLAUDE_CODE_MCP_SERVER_NAME` | Name of the MCP server |
| `CLAUDE_CODE_MCP_SERVER_URL` | URL of the MCP server |

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — Full MCP reference: transports, scopes, authentication, tool search, plugin servers, claude.ai connectors, resources, prompts, and output limits
- [Control MCP server access for your organization](references/claude-code-managed-mcp.md) — Admin guide: managed-mcp.json, allowlists, denylists, usage monitoring
- [Connect to MCP servers (quickstart)](references/claude-code-mcp-quickstart.md) — Step-by-step walkthrough for adding your first server, changing scopes, and troubleshooting

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
- Control MCP server access for your organization: https://code.claude.com/docs/en/managed-mcp.md
- Connect to MCP servers (quickstart): https://code.claude.com/docs/en/mcp-quickstart.md
