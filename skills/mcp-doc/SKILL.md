---
name: mcp-doc
description: Complete official documentation for connecting Claude Code to external tools and data sources via the Model Context Protocol (MCP) — installing servers, scopes, authentication, OAuth, managed configuration, tool search, resources, prompts, and output limits.
user-invocable: false
---

# MCP (Model Context Protocol) Documentation

This skill provides the complete official documentation for connecting Claude Code to tools and data sources via MCP.

## Quick Reference

MCP lets Claude Code connect to external tools, databases, and APIs. Three transport types are supported: HTTP (recommended for remote), SSE (deprecated), and stdio (local processes).

### CLI commands

| Command | Description |
| :--- | :--- |
| `claude mcp add --transport http <name> <url>` | Add a remote HTTP server |
| `claude mcp add --transport sse <name> <url>` | Add a remote SSE server (deprecated) |
| `claude mcp add [--transport stdio] <name> -- <cmd> [args...]` | Add a local stdio server |
| `claude mcp add-json <name> '<json>'` | Add a server from raw JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS/WSL only) |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Show details for a server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset approval choices for project-scoped servers |
| `claude mcp serve` | Run Claude Code itself as an MCP server (stdio) |
| `/mcp` | Within Claude Code: check status, authenticate, manage servers |

### Common add flags

| Flag | Purpose |
| :--- | :--- |
| `--transport http\|sse\|stdio` | Transport type (default: stdio) |
| `--scope local\|project\|user` | Where to store the config (default: `local`) |
| `--env KEY=value` | Set an environment variable for the server |
| `--header "Key: Value"` | Add an HTTP header (useful for Bearer tokens) |
| `--client-id <id>` | Pre-configured OAuth client ID |
| `--client-secret` | Prompt for OAuth client secret (masked) |
| `--callback-port <port>` | Fix the OAuth callback port to match a registered redirect URI |

### Scope summary

| Scope | Loads in | Shared | Stored in |
| :--- | :--- | :--- | :--- |
| `local` (default) | Current project only | No | `~/.claude.json` |
| `project` | Current project only | Yes (via `.mcp.json`) | `.mcp.json` in project root |
| `user` | All projects | No | `~/.claude.json` |

Precedence (highest to lowest): local → project → user → plugin-provided → claude.ai connectors. Duplicates matched by name (manual scopes) or endpoint (plugins/connectors).

### .mcp.json format

```json
{
  "mcpServers": {
    "my-server": {
      "command": "...",
      "args": [],
      "env": {}
    }
  }
}
```

Supports environment variable expansion in `command`, `args`, `env`, `url`, and `headers`:
- `${VAR}` — expand env var
- `${VAR:-default}` — expand with fallback

### Server config fields (JSON)

| Field | Type | Description |
| :--- | :--- | :--- |
| `type` | `"http"` / `"sse"` / `"stdio"` | Transport type |
| `url` | string | URL for HTTP/SSE servers |
| `command` | string | Executable for stdio servers |
| `args` | string[] | Arguments for stdio servers |
| `env` | object | Environment variables passed to server |
| `headers` | object | Static HTTP headers |
| `headersHelper` | string | Shell command that outputs JSON headers at connect time |
| `oauth` | object | OAuth config (`clientId`, `callbackPort`, `scopes`, `authServerMetadataUrl`) |
| `alwaysLoad` | boolean | Always load tools into context, bypassing tool search deferral |

### Authentication

OAuth 2.0 is supported for HTTP servers. Use `/mcp` in Claude Code to complete browser-based login. Tokens are stored securely and auto-refreshed.

| OAuth option | Description |
| :--- | :--- |
| `oauth.scopes` | Space-separated scope string (RFC 6749 §3.3) to pin requested scopes |
| `oauth.authServerMetadataUrl` | Override discovery; must use `https://`; requires v2.1.64+ |
| `oauth.clientId` + `--client-secret` | Pre-configured credentials for servers without Dynamic Client Registration |
| `--callback-port <port>` | Fix callback port to match a registered redirect URI |
| `headersHelper` | Script for non-OAuth auth (Kerberos, short-lived tokens, SSO) |

`headersHelper` environment: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`. Runs in a shell with 10-second timeout.

### Tool search (MCP Tool Search)

Defers MCP tool definitions until needed, keeping context usage low. Enabled by default (disabled by default on Vertex AI and non-first-party `ANTHROPIC_BASE_URL`). Requires Sonnet 4+ or Opus 4+; Haiku does not support tool search.

| `ENABLE_TOOL_SEARCH` value | Behavior |
| :--- | :--- |
| (unset) | All tools deferred; falls back to upfront loading on Vertex AI / non-first-party base URL |
| `true` | All tools deferred everywhere |
| `auto` | Threshold mode: load upfront if fits within 10% of context window |
| `auto:<N>` | Threshold mode with custom percentage (0–100) |
| `false` | All tools loaded upfront |

Exempt a specific server from deferral: set `"alwaysLoad": true` in its config. Individual tools can set `"anthropic/alwaysLoad": true` in their `_meta` object.

To disable the ToolSearch tool entirely via permissions:
```json
{ "permissions": { "deny": ["ToolSearch"] } }
```

### Output limits

| Setting | Default | Description |
| :--- | :--- | :--- |
| Warning threshold | 10,000 tokens | Claude Code warns when tool output exceeds this |
| `MAX_MCP_OUTPUT_TOKENS` env var | 25,000 tokens | Max allowed output; applies to tools without their own limit |
| `_meta["anthropic/maxResultSizeChars"]` | — | Per-tool override (up to 500,000 chars); does not affect image output |

### MCP resources

Reference resources in prompts with `@server:protocol://resource/path`. Resources appear in the `@` autocomplete menu alongside files. Multiple resources can be referenced in a single prompt.

### MCP prompts as commands

MCP server prompts appear as `/mcp__servername__promptname` commands. Pass arguments space-separated: `/mcp__github__pr_review 456`.

### Reconnection behavior

HTTP/SSE servers reconnect automatically with exponential backoff (up to 5 attempts, starting at 1 second, doubling each time). Stdio servers are not auto-reconnected. Initial connection retries up to 3 times on transient errors (5xx, connection refused, timeout) — not on auth or 404 errors. Requires v2.1.121+.

### Plugin-provided MCP servers

Plugins can bundle MCP servers via `.mcp.json` at the plugin root or inline in `plugin.json`. Use `${CLAUDE_PLUGIN_ROOT}` for bundled files, `${CLAUDE_PLUGIN_DATA}` for persistent state. Run `/reload-plugins` after enabling/disabling a plugin mid-session.

### Claude.ai connectors

MCP servers configured at [claude.ai/customize/connectors](https://claude.ai/customize/connectors) are automatically available in Claude Code when logged in with a Claude.ai account. Disable with `ENABLE_CLAUDEAI_MCP_SERVERS=false`.

### Managed MCP configuration (IT/org admins)

**Option 1: Exclusive control** — deploy `managed-mcp.json` to:
- macOS: `/Library/Application Support/ClaudeCode/managed-mcp.json`
- Linux/WSL: `/etc/claude-code/managed-mcp.json`
- Windows: `C:\Program Files\ClaudeCode\managed-mcp.json`

When this file exists, users cannot add/modify any MCP servers. Uses standard `.mcp.json` format.

**Option 2: Allowlists/denylists** — configure `allowedMcpServers` and `deniedMcpServers` in managed settings. Each entry uses exactly one of: `serverName`, `serverCommand` (exact array match), or `serverUrl` (supports `*` wildcards). Denylist takes absolute precedence. `allowedMcpServers: []` = complete lockdown.

### MCP elicitation

MCP servers can request structured input mid-task. Claude Code shows a dialog (form fields or browser URL) automatically — no configuration needed. Use the `Elicitation` hook to auto-respond without a dialog.

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — installing servers (HTTP, SSE, stdio), managing scopes, authentication (OAuth, headers, headersHelper), tool search, output limits, resources, prompts, managed configuration, and running Claude Code as an MCP server

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
