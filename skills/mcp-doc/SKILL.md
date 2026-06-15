---
name: mcp-doc
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for the Model Context Protocol (MCP) in Claude Code — connecting servers, managing scopes, authenticating, controlling access for organizations, and troubleshooting.

## Quick Reference

### Transport Types

| Transport | CLI flag | JSON `type` | Use for |
| :--- | :--- | :--- | :--- |
| HTTP (recommended) | `--transport http` | `http` or `streamable-http` | Hosted cloud services |
| SSE (deprecated) | `--transport sse` | `sse` | Legacy remote servers |
| stdio | (default) | `stdio` | Local processes on your machine |
| WebSocket | n/a (JSON only) | `ws` | Servers that push events unprompted |

### Core CLI Commands

```bash
# Add servers
claude mcp add --transport http <name> <url>
claude mcp add --transport http <name> <url> --header "Authorization: Bearer <token>"
claude mcp add [--transport stdio] <name> -- <command> [args...]
claude mcp add-json <name> '<json>'
claude mcp add-from-claude-desktop       # macOS and WSL only

# Manage servers
claude mcp list
claude mcp get <name>
claude mcp remove <name>
claude mcp reset-project-choices

# Within a Claude Code session
/mcp
```

### Installation Scopes

| Scope | CLI flag | Stored in | Available to |
| :--- | :--- | :--- | :--- |
| `local` (default) | `--scope local` | `~/.claude.json` (under project path) | You, current project only |
| `project` | `--scope project` | `.mcp.json` in project root | Team (commit to version control) |
| `user` | `--scope user` | `~/.claude.json` (top-level `mcpServers`) | You, all projects |

**Scope precedence (highest wins):** local → project → user → plugin-provided → claude.ai connectors. Duplicates matched by name (scopes) or endpoint (plugins/connectors).

### .mcp.json Format

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
      "args": ["-y", "my-mcp-package"],
      "env": { "DB_URL": "${DB_URL:-postgres://localhost/dev}" }
    }
  }
}
```

Environment variable expansion in `.mcp.json`: `${VAR}` (required) and `${VAR:-default}` (with fallback). Works in `command`, `args`, `env`, `url`, and `headers`.

### Key Environment Variables and Settings

| Variable / Setting | Effect |
| :--- | :--- |
| `MCP_TIMEOUT` | Server startup timeout in ms (default: 30 000) |
| `MCP_TOOL_TIMEOUT` | Per-tool execution wall-clock limit in ms (default: ~28 hours) |
| `MAX_MCP_OUTPUT_TOKENS` | Warning threshold and max output tokens (warning at 10 000; cap at 25 000) |
| `ENABLE_CLAUDEAI_MCP_SERVERS=false` | Disable automatic claude.ai connectors |
| `ENABLE_TOOL_SEARCH` | Control tool search deferral (see below) |
| `timeout` (per-server in `.mcp.json`) | Per-call override for `MCP_TOOL_TIMEOUT`; min 1 000 ms; requires v2.1.162+ |
| `alwaysLoad` (per-server in `.mcp.json`) | Load server's tools into context at startup; bypasses tool search deferral |
| `CLAUDE_PROJECT_DIR` | Set in stdio server's environment by Claude Code; resolves to project root |

### Tool Search (ENABLE_TOOL_SEARCH)

Tool search is **on by default** — tool definitions are deferred and loaded on demand to keep context usage low. Disabled by default on Vertex AI and non-first-party `ANTHROPIC_BASE_URL`.

| Value | Behavior |
| :--- | :--- |
| (unset) | All tools deferred; falls back to upfront loading on Vertex AI / proxy |
| `true` | Force deferral even on Vertex AI and proxies |
| `auto` | Threshold mode: load upfront if tools fit within 10% of context window |
| `auto:N` | Threshold mode with custom N% threshold |
| `false` | Load all tools upfront, no deferral |

Disable the `ToolSearch` tool specifically via `permissions.deny: ["ToolSearch"]` in settings.

### OAuth Authentication

OAuth fires when a remote server returns `401` or `403`. To authenticate: run `/mcp` inside a session, select the server, choose Authenticate.

| Scenario | How |
| :--- | :--- |
| Fixed callback port | `--callback-port PORT` on `claude mcp add` |
| Pre-configured client ID | `--client-id <id> --client-secret` on `claude mcp add` |
| Custom OAuth metadata URL | `oauth.authServerMetadataUrl` in `.mcp.json` (requires v2.1.64+) |
| Restrict OAuth scopes | `oauth.scopes` in `.mcp.json` (space-separated string) |
| Dynamic headers (non-OAuth) | `headersHelper` field in `.mcp.json`; command outputs JSON headers to stdout |

### Dynamic Headers (headersHelper)

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

Script must write a JSON object of string key-value pairs to stdout. Runs with a 10-second timeout on each connection. Env vars `CLAUDE_CODE_MCP_SERVER_NAME` and `CLAUDE_CODE_MCP_SERVER_URL` are set for the helper.

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers in `.mcp.json` at plugin root or inline in `plugin.json`. Plugin MCP servers start automatically when the plugin is enabled; run `/reload-plugins` after enable/disable.

**Tool name format for plugin servers:** `mcp__plugin_<plugin-name>_<server-name>__<tool-name>` (non-alphanumeric chars → `_`).

**Available plugin path variables:** `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`, `${CLAUDE_PROJECT_DIR}`.

### Using Claude Code as an MCP Server

```bash
claude mcp serve    # expose Claude Code's tools over stdio
```

Add to `claude_desktop_config.json` as a `stdio` server with `"command": "claude"` and `"args": ["mcp", "serve"]`.

### MCP Resources and Prompts

**Resources** (@ mentions): type `@server:protocol://resource/path` in a prompt to attach a resource. Resources appear in autocomplete after `@`.

**Prompts** (slash commands): MCP prompts appear as `/mcp__servername__promptname`. Pass arguments space-separated: `/mcp__github__pr_review 456`.

### Connection Status Indicators

| Status | Meaning |
| :--- | :--- |
| `✓ Connected` | Ready to use |
| `! Needs authentication` | OAuth sign-in required — use `/mcp` |
| `✗ Failed to connect` | Server didn't respond |
| `✗ Connection error` | Connection threw an error |
| `⏸ Pending approval` | Project-scoped server awaiting your approval |

HTTP/SSE servers reconnect automatically with exponential backoff (up to 5 retries, starting at 1 s doubling). Stdio servers are not auto-reconnected.

### Managed MCP (Organization Control)

| Pattern | Configuration |
| :--- | :--- |
| Disable MCP entirely | `managed-mcp.json` with `{ "mcpServers": {} }` |
| Fixed server set | `managed-mcp.json` with the servers you want (exclusive control) |
| Approved catalog | `allowedMcpServers` + `allowManagedMcpServersOnly: true` |
| Denylist only | `deniedMcpServers` in managed settings |

**managed-mcp.json paths:**

| Platform | Path |
| :--- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux / WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

**Allowlist / denylist matching:**

| Key | Matches | Wildcards |
| :--- | :--- | :--- |
| `serverUrl` | Remote server URL | `*` anywhere |
| `serverCommand` | Exact command + all args in order | None |
| `serverName` | User-assigned label | None (exact only) |

Denylist always takes precedence. Once any `serverUrl` entry exists in the allowlist, remote servers must match a URL (name alone is not enough). Same logic applies to `serverCommand` for stdio servers.

**Key managed settings:**

| Setting | Effect |
| :--- | :--- |
| `allowedMcpServers` | Allowlist entries; empty array blocks all |
| `deniedMcpServers` | Denylist entries; merges from all sources |
| `allowManagedMcpServersOnly: true` | Lock allowlist to managed sources only |
| `allowAllClaudeAiMcps: true` | Load claude.ai connectors alongside `managed-mcp.json` (requires v2.1.149+) |

**User-visible error messages when blocked:**

- `managed-mcp.json` present: `Cannot add MCP server: enterprise MCP configuration is active and has exclusive control over MCP servers`
- Denylist match: `Cannot add MCP server "<name>": server is explicitly blocked by enterprise policy`
- Not on allowlist: `Cannot add MCP server "<name>": not allowed by enterprise policy`
- Previously configured server now blocked: silently disappears from `/mcp` with no warning

### Troubleshooting

| Symptom | Fix |
| :--- | :--- |
| `/mcp` shows no servers | Re-add from current project dir; check config file paths (`~/.claude.json`, `.mcp.json`) |
| `Failed to connect` / `Connection error` | For HTTP: `curl -I <url>`; for stdio: run the command directly in terminal |
| Timeout at startup | Increase with `MCP_TIMEOUT=60000 claude` |
| Server already exists | `claude mcp remove <name>` first; use `--scope` if in multiple scopes |
| No tools appear after connect | Server started but missing env vars (API key); add with `--env KEY=value` |
| `.mcp.json` changes ignored | Exit and restart session; run `claude mcp reset-project-choices` if previously rejected |
| OAuth sign-in fails | Re-run `/mcp` → Authenticate; copy URL manually if browser doesn't open |

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — Full MCP reference: transports, scopes, auth, plugin servers, tool search, resources, prompts, output limits, elicitation
- [Control MCP server access for your organization](references/claude-code-managed-mcp.md) — managed-mcp.json, allowlists, denylists, org patterns, monitoring MCP usage
- [Connect to MCP servers (quickstart)](references/claude-code-mcp-quickstart.md) — Step-by-step walkthrough: add, verify, scope, troubleshoot

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
- Control MCP server access for your organization: https://code.claude.com/docs/en/managed-mcp.md
- Connect to MCP servers (quickstart): https://code.claude.com/docs/en/mcp-quickstart.md
