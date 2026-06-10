---
name: mcp-doc
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for the Model Context Protocol (MCP) in Claude Code, including how to connect servers, manage scopes, authenticate, and control organization-wide access.

## Quick Reference

### Transport types

| Transport | Flag / JSON `type` | Best for |
| :--- | :--- | :--- |
| HTTP (streamable-http) | `--transport http` / `"type": "http"` | Hosted/cloud services; recommended default |
| SSE | `--transport sse` / `"type": "sse"` | Deprecated; use HTTP where available |
| Stdio | (default) / `"type": "stdio"` | Local processes needing filesystem/system access |
| WebSocket | `"type": "ws"` (JSON only) | Servers that push events unprompted |

### Core CLI commands

```bash
# Add servers
claude mcp add --transport http <name> <url>
claude mcp add --transport http <name> <url> --header "Authorization: Bearer TOKEN"
claude mcp add [--transport stdio] <name> -- <command> [args...]
claude mcp add-json <name> '<json>'
claude mcp add-from-claude-desktop        # macOS / WSL only

# Manage servers
claude mcp list
claude mcp get <name>
claude mcp remove <name>
claude mcp reset-project-choices

# Use Claude Code as an MCP server
claude mcp serve
```

### Scope table

| Scope | Flag | Stored in | Available to |
| :--- | :--- | :--- | :--- |
| `local` (default) | `--scope local` | `~/.claude.json` under current project | You, current project only |
| `project` | `--scope project` | `.mcp.json` in project root | All teammates (via version control) |
| `user` | `--scope user` | `~/.claude.json` top-level `mcpServers` | You, all projects |

Precedence when the same server name exists in multiple scopes (highest first): local → project → user → plugin-provided → claude.ai connectors.

### .mcp.json format

```json
{
  "mcpServers": {
    "my-http-server": {
      "type": "http",
      "url": "https://mcp.example.com/mcp",
      "headers": { "Authorization": "Bearer ${API_KEY}" }
    },
    "my-stdio-server": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "some-mcp-server"],
      "env": { "KEY": "value" }
    }
  }
}
```

Environment variable expansion in `.mcp.json`: `${VAR}` (required) and `${VAR:-default}` (with fallback). Applies to `command`, `args`, `env`, `url`, and `headers`.

### Key environment variables

| Variable | Effect |
| :--- | :--- |
| `MCP_TIMEOUT` | Server startup timeout in ms (default: 30 000) |
| `MCP_TOOL_TIMEOUT` | Per-tool execution timeout in ms (default: ~28 hours) |
| `MAX_MCP_OUTPUT_TOKENS` | Warning threshold + max output tokens (default: 25 000; warning at 10 000) |
| `ENABLE_TOOL_SEARCH` | `true` (all deferred), `auto` (threshold 10%), `auto:N` (custom %), `false` (all upfront) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set to `false` to disable claude.ai connectors in Claude Code |

### Authentication

- **OAuth 2.0**: Use `/mcp` inside a session, select the server, choose Authenticate. Tokens stored securely and refreshed automatically.
- **Static header token**: pass `--header "Authorization: Bearer TOKEN"` at add time.
- **Fixed callback port**: `--callback-port PORT` (use when server requires a pre-registered redirect URI).
- **Pre-configured OAuth credentials**: `--client-id ID --client-secret --callback-port PORT`; secret stored in system keychain, not config.
- **Dynamic headers** (`headersHelper`): runs a shell command at connect time, merges JSON key-value pairs into request headers. Set in `.mcp.json`.
- **Restrict OAuth scopes**: set `oauth.scopes` (space-separated string) in server config to pin what Claude Code requests.
- **Override discovery**: set `oauth.authServerMetadataUrl` to bypass default RFC 9728 / RFC 8414 discovery chain (requires v2.1.64+).

### Tool Search (MCP Tool Search)

Enabled by default. MCP tool schemas are deferred and fetched on demand; only tool names and server instructions load at session start. Controls:

- `alwaysLoad: true` in a server's config entry forces that server's tools into context upfront (requires v2.1.121+).
- Per-tool: set `"anthropic/alwaysLoad": true` in the tool's `_meta` object.
- Disable for a specific tool: deny `ToolSearch` in permissions settings.

### MCP output limits

- Warning when any tool output exceeds 10 000 tokens.
- Default cap: 25 000 tokens (controlled by `MAX_MCP_OUTPUT_TOKENS`).
- Server-side per-tool override: set `_meta["anthropic/maxResultSizeChars"]` in the tool's `tools/list` entry (up to 500 000 chars).

### Plugin-provided MCP servers

Plugins can bundle MCP servers via `.mcp.json` at the plugin root or inline in `plugin.json`. Available variables: `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`, `${CLAUDE_PROJECT_DIR}`. Lifecycle is tied to plugin enable/disable; run `/reload-plugins` to reconnect after changes.

### MCP resources and prompts

- Reference resources in prompts with `@server:protocol://resource/path`.
- MCP prompts appear as slash commands with the format `/mcp__servername__promptname`.

### Managed MCP (organization control)

| Pattern | Mechanism |
| :--- | :--- |
| Disable MCP entirely | `managed-mcp.json` with `{"mcpServers": {}}` |
| Fixed server set, exclusive control | `managed-mcp.json` with the approved servers |
| Approved catalog (allowlist) | `allowedMcpServers` + `allowManagedMcpServersOnly: true` |
| Soft allowlist (user can broaden) | `allowedMcpServers` without `allowManagedMcpServersOnly` |
| Block specific servers | `deniedMcpServers` |

`managed-mcp.json` paths: `/Library/Application Support/ClaudeCode/managed-mcp.json` (macOS), `/etc/claude-code/managed-mcp.json` (Linux/WSL), `C:\Program Files\ClaudeCode\managed-mcp.json` (Windows). Deployed via MDM/GPO/fleet tools.

Allowlist/denylist match keys: `serverUrl` (wildcards with `*`), `serverCommand` (exact args), `serverName` (exact, not a security control alone). Denylist always wins. Commands match exactly; URLs are case-insensitive on hostname, case-sensitive on path.

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — full MCP reference: transports, scopes, authentication, tool search, output limits, resources, prompts, plugin servers, managed config
- [Control MCP server access for your organization](references/claude-code-managed-mcp.md) — managed-mcp.json, allowlists, denylists, patterns, monitoring MCP usage
- [Connect to MCP servers (quickstart)](references/claude-code-mcp-quickstart.md) — step-by-step walkthrough: add, verify, use, troubleshoot; scope changes; editing .mcp.json directly

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
- Control MCP server access for your organization: https://code.claude.com/docs/en/managed-mcp.md
- Connect to MCP servers (quickstart): https://code.claude.com/docs/en/mcp-quickstart.md
