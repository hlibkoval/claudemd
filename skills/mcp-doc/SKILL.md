---
name: mcp-doc
description: Complete official documentation for MCP (Model Context Protocol) in Claude Code — transports (HTTP, SSE, stdio), installation scopes (local/project/user), CLI commands, OAuth 2.0 authentication, dynamic headers, tool search, output limits, MCP resources, prompts-as-commands, managed MCP configuration, allowlists/denylists, and enterprise policy controls.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools and services via the Model Context Protocol (MCP).

## Quick Reference

### What MCP Is

MCP (Model Context Protocol) is an open standard for AI-tool integrations. Claude Code uses it to connect to external tools, databases, and APIs. Use MCP servers when you would otherwise copy data into chat from another tool.

### Transport Types

| Transport | CLI flag | Notes |
| :--- | :--- | :--- |
| HTTP (Streamable HTTP) | `--transport http` | Recommended for remote servers; `streamable-http` is a valid alias in JSON config |
| SSE | `--transport sse` | Deprecated; use HTTP where available |
| stdio | `--transport stdio` (default) | Local process; `CLAUDE_PROJECT_DIR` injected into server environment |

### CLI Commands

```bash
claude mcp add --transport http <name> <url>               # add remote HTTP server
claude mcp add --transport http <name> <url> \
  --header "Authorization: Bearer token"                   # with auth header
claude mcp add --transport stdio <name> -- <command> [args]  # add local stdio server
  --env KEY=value                                           # pass env var to server
  --scope local|project|user                               # set scope (default: local)
claude mcp add-json <name> '<json>'                        # add from JSON config
claude mcp add-from-claude-desktop                         # import from Claude Desktop (macOS/WSL)
claude mcp list                                            # list configured servers
claude mcp get <name>                                      # show server details
claude mcp remove <name>                                   # remove server
claude mcp reset-project-choices                           # reset project-scope approvals
/mcp                                                       # in-session: status panel + OAuth auth
```

**Option ordering for stdio:** all flags (`--transport`, `--env`, `--scope`) must appear before the server name; `--` separates the server name from the command and its arguments.

### Installation Scopes

| Scope | Loads in | Shared with team | Stored in |
| :--- | :--- | :--- | :--- |
| `local` (default) | Current project only | No | `~/.claude.json` |
| `project` | Current project only | Yes, via `.mcp.json` in repo | `.mcp.json` |
| `user` | All your projects | No | `~/.claude.json` |

Precedence when the same server is defined in multiple places: local > project > user > plugin-provided > claude.ai connectors.

### `.mcp.json` Format

```json
{
  "mcpServers": {
    "server-name": {
      "type": "http",
      "url": "https://mcp.example.com/mcp",
      "headers": { "Authorization": "Bearer ${API_KEY}" },
      "timeout": 600000,
      "alwaysLoad": true
    },
    "local-server": {
      "type": "stdio",
      "command": "/path/to/server",
      "args": ["--flag"],
      "env": { "KEY": "${VAR:-default}" }
    }
  }
}
```

Environment variable expansion supported in `command`, `args`, `env`, `url`, `headers`: `${VAR}` and `${VAR:-default}`.

### OAuth 2.0 Authentication

| Scenario | Approach |
| :--- | :--- |
| Standard OAuth (automatic discovery) | Run `/mcp` after adding server; Claude detects 401/403 |
| Fixed callback port | `--callback-port PORT` |
| Pre-configured credentials | `--client-id <id> --client-secret --callback-port PORT` |
| Restrict scopes | `"oauth": {"scopes": "scope1 scope2"}` in `.mcp.json` |
| Custom auth metadata URL | `"oauth": {"authServerMetadataUrl": "..."}` in `.mcp.json` (v2.1.64+) |
| Dynamic headers (non-OAuth) | `"headersHelper": "/path/to/script.sh"` in `.mcp.json` |

`headersHelper` script must output a JSON object of string key-value pairs; runs at connection time with `CLAUDE_CODE_MCP_SERVER_NAME` and `CLAUDE_CODE_MCP_SERVER_URL` in environment.

### Tool Search (MCP Tool Deferral)

Tool search is on by default. Tool schemas are deferred and only loaded when Claude needs them, keeping context usage low.

| `ENABLE_TOOL_SEARCH` value | Behavior |
| :--- | :--- |
| (unset) | All tools deferred; falls back to upfront on Vertex AI or non-first-party `ANTHROPIC_BASE_URL` |
| `true` | All tools deferred, even on Vertex AI |
| `auto` | Load upfront if ≤10% of context window; defer overflow |
| `auto:N` | Threshold mode with custom percentage N |
| `false` | All tools loaded upfront |

Requires Sonnet 4+ or Opus 4+ (not Haiku). On Vertex AI: Sonnet 4.5+ or Opus 4.5+.

To exempt a specific server from deferral: set `"alwaysLoad": true` in `.mcp.json` (v2.1.121+). Individual tools can use `"anthropic/alwaysLoad": true` in their `_meta`.

### Output Limits

| Setting | Default | Notes |
| :--- | :--- | :--- |
| Warning threshold | 10,000 tokens | Warning displayed when exceeded |
| Max output (`MAX_MCP_OUTPUT_TOKENS`) | 25,000 tokens | Applies to tools without `anthropic/maxResultSizeChars` |
| Per-tool limit | Set in `_meta["anthropic/maxResultSizeChars"]` | Up to 500,000 chars; text only (images still use token limit) |

### MCP Resources (@ mentions)

Reference MCP server resources using `@server:protocol://resource/path` syntax in prompts. Type `@` to see available resources in autocomplete. Multiple resources can be referenced in one prompt.

### MCP Prompts as Commands

MCP-exposed prompts appear as `/mcp__servername__promptname` commands. Execute with arguments space-separated: `/mcp__github__pr_review 456`.

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers in `.mcp.json` at plugin root or inline in `plugin.json`. Use `${CLAUDE_PLUGIN_ROOT}` for plugin files, `${CLAUDE_PLUGIN_DATA}` for persistent state, `${CLAUDE_PROJECT_DIR}` for project root. Run `/reload-plugins` after enabling/disabling a plugin to connect/disconnect its servers.

### Reconnection Behavior

HTTP/SSE servers reconnect on disconnect with exponential backoff (up to 5 attempts, starting at 1 second, doubling each time). Initial connection is retried up to 3 times on transient errors (5xx, connection refused, timeout). Stdio servers are not auto-reconnected.

### Environment Variables

| Variable | Effect |
| :--- | :--- |
| `MCP_TIMEOUT` | Server startup timeout in ms (e.g., `MCP_TIMEOUT=10000`) |
| `MAX_MCP_OUTPUT_TOKENS` | Max output tokens per tool call |
| `ENABLE_TOOL_SEARCH` | Control tool deferral mode |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set to `false` to disable claude.ai connectors |
| `CLAUDE_PROJECT_DIR` | Injected into stdio server environment; use `${CLAUDE_PROJECT_DIR:-.}` in `.mcp.json` expansion |

## Managed MCP (Enterprise)

### Control Patterns

| Pattern | What it does | Configure |
| :--- | :--- | :--- |
| **Disable MCP** | No servers load anywhere | `managed-mcp.json` with empty `mcpServers: {}` |
| **Fixed deployment** | Every user gets the same servers; can't add others | `managed-mcp.json` with the servers you want |
| **Approved catalog** | Users add from an approved list only | `allowedMcpServers` + `allowManagedMcpServersOnly: true` |
| **Plugin servers only** | Servers only from plugins | `strictPluginOnlyCustomization` with `mcp` |
| **Soft allowlist** | Allowlist users can widen in their own settings | `allowedMcpServers` without `allowManagedMcpServersOnly` |
| **Denylist only** | Block known-bad servers | `deniedMcpServers` |

### `managed-mcp.json` Paths

| Platform | Path |
| :--- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux and WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

Same format as `.mcp.json`. When present, users cannot add, modify, or use any other MCP servers. Deploy via MDM (Jamf, Intune, Group Policy) or any process with administrator privileges.

### Allowlist / Denylist Match Keys

| Key | Matches | Notes |
| :--- | :--- | :--- |
| `serverUrl` | Remote server URL; `*` wildcards supported anywhere | Use for HTTP/SSE servers |
| `serverCommand` | Exact command array including all arguments | Use for stdio servers |
| `serverName` | User-assigned label; exact match only | Weak — use with URL or command entries |

`allowedMcpServers: []` (empty array) blocks all servers. Unset = all allowed. Denylists always merge from all settings sources; allowlists merge unless `allowManagedMcpServersOnly: true`.

### Evaluation Order

1. Merge lists (managed allowlist only if `allowManagedMcpServersOnly: true`)
2. Check denylist — match blocks unconditionally
3. Check allowlist — remote servers need `serverUrl` match; stdio servers need `serverCommand` match; `serverName` only counts when no stricter entries exist for that type

### User-Visible Messages

| Situation | Message |
| :--- | :--- |
| `managed-mcp.json` present, user runs `claude mcp add` | `Cannot add MCP server: enterprise MCP configuration is active and has exclusive control over MCP servers` |
| Server on denylist | `Cannot add MCP server "<name>": server is explicitly blocked by enterprise policy` |
| Server not on allowlist | `Cannot add MCP server "<name>": not allowed by enterprise policy` |
| Previously configured server now blocked | Server silently disappears from `/mcp` — no warning |

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — transports, scopes, CLI commands, OAuth, tool search, output limits, resources, prompts, plugin MCP servers, channels, and elicitation
- [Control MCP server access for your organization](references/claude-code-managed-mcp.md) — managed-mcp.json, allowlists, denylists, enterprise patterns, and monitoring MCP usage

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
- Control MCP server access for your organization: https://code.claude.com/docs/en/managed-mcp.md
