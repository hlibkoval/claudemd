---
name: mcp-doc
description: Complete official documentation for connecting Claude Code to external tools and data sources via the Model Context Protocol (MCP) — adding servers, scopes, authentication, OAuth, tool search, output limits, resources, prompts, and managed enterprise configuration.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools via the Model Context Protocol (MCP).

## Quick Reference

### Adding MCP Servers

| Transport | Command | Notes |
| :--- | :--- | :--- |
| HTTP (recommended) | `claude mcp add --transport http <name> <url>` | Preferred for cloud/remote servers |
| SSE (deprecated) | `claude mcp add --transport sse <name> <url>` | Use HTTP instead where available |
| stdio (local) | `claude mcp add --transport stdio <name> -- <command> [args...]` | Local processes with system access |

**All options (`--transport`, `--env`, `--scope`, `--header`) must come before the server name. Use `--` to separate the server name from the command.**

```bash
# HTTP with auth header
claude mcp add --transport http github https://api.githubcopilot.com/mcp/ \
  --header "Authorization: Bearer YOUR_TOKEN"

# stdio with env var
claude mcp add --transport stdio --env AIRTABLE_API_KEY=KEY airtable \
  -- npx -y airtable-mcp-server
```

In `.mcp.json` and `claude mcp add-json`, `type` accepts `streamable-http` as an alias for `http`.

### Management Commands

```bash
claude mcp list                          # List all configured servers
claude mcp get <name>                    # Details for a specific server
claude mcp remove <name>                 # Remove a server
claude mcp add-json <name> '<json>'      # Add server from JSON config
claude mcp add-from-claude-desktop       # Import from Claude Desktop (macOS/WSL only)
/mcp                                     # Within Claude Code: status, auth, tool count
```

The server name `workspace` is reserved and will be skipped with a warning if used.

### Installation Scopes

| Scope | Loads in | Shared | Stored in |
| :--- | :--- | :--- | :--- |
| `local` (default) | Current project | No | `~/.claude.json` |
| `project` | Current project | Yes (via VCS) | `.mcp.json` in project root |
| `user` | All projects | No | `~/.claude.json` |

```bash
claude mcp add --transport http stripe --scope local https://mcp.stripe.com
claude mcp add --transport http paypal --scope project https://mcp.paypal.com/mcp
claude mcp add --transport http hubspot --scope user https://mcp.hubspot.com/anthropic
```

Project-scoped servers in `.mcp.json` require approval before use. Reset approvals with `claude mcp reset-project-choices`.

### Scope Hierarchy (highest wins)

1. Local scope
2. Project scope
3. User scope
4. Plugin-provided servers
5. claude.ai connectors

Scopes 1-3 match by name; plugins and connectors match by endpoint URL.

### Environment Variable Expansion in `.mcp.json`

| Syntax | Behavior |
| :--- | :--- |
| `${VAR}` | Expands to value of `VAR` (fails if unset) |
| `${VAR:-default}` | Expands to `VAR`, or `default` if unset |

Supported in: `command`, `args`, `env`, `url`, `headers`.

Special plugin variables: `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`, `${CLAUDE_PROJECT_DIR}`.

For user/project `.mcp.json`, `CLAUDE_PROJECT_DIR` requires a default: `${CLAUDE_PROJECT_DIR:-.}`.

### OAuth Authentication

Claude Code supports OAuth 2.0 for remote servers. A server is flagged for auth when it returns `401` or `403`.

```bash
# Add server, then authenticate via /mcp
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
/mcp   # follow browser login flow
```

**Pre-configured OAuth credentials** (when dynamic client registration is unsupported):

```bash
claude mcp add --transport http \
  --client-id your-client-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

| Flag | Purpose |
| :--- | :--- |
| `--callback-port PORT` | Fix OAuth callback port for pre-registered redirect URIs |
| `--client-id ID` | Pre-configured OAuth client ID |
| `--client-secret` | Prompts for client secret (masked); or set `MCP_CLIENT_SECRET` env var |

**Advanced OAuth config (in `.mcp.json` `oauth` object):**

| Field | Purpose |
| :--- | :--- |
| `authServerMetadataUrl` | Override OAuth discovery URL (requires v2.1.64+) |
| `scopes` | Pin requested scopes (space-separated, RFC 6749 format) |
| `clientId` | Pre-configured client ID |
| `callbackPort` | Fixed callback port |

### Dynamic Headers (`headersHelper`)

For non-OAuth authentication (Kerberos, short-lived tokens, SSO):

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

- Command must write a JSON object of string key-value pairs to stdout
- 10-second timeout; runs fresh on each connection (no caching)
- Env vars set: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`
- Requires workspace trust acceptance when defined at project/local scope

### Reconnection and Reliability

- HTTP/SSE servers: auto-reconnect with exponential backoff (up to 5 attempts, starting 1s, doubling)
- Initial connection retries (v2.1.121+): up to 3 attempts on transient errors (5xx, timeout, refused)
- Auth/404 errors are not retried
- Stdio servers: not reconnected automatically (local processes)
- Set `MCP_TIMEOUT` env var for startup timeout: `MCP_TIMEOUT=10000 claude`

### Dynamic Tool Updates

Claude Code supports MCP `list_changed` notifications — tools, prompts, and resources update without reconnecting.

### Tool Search (Context Management)

MCP tools are deferred by default to keep context usage low. Claude searches for tools when needed.

| `ENABLE_TOOL_SEARCH` value | Behavior |
| :--- | :--- |
| (unset) | Deferred; falls back to upfront on Vertex AI or non-first-party `ANTHROPIC_BASE_URL` |
| `true` | All tools deferred; sends beta header even on Vertex AI |
| `auto` | Threshold: load upfront if within 10% of context window, else defer |
| `auto:<N>` | Threshold with custom percentage (0-100) |
| `false` | All tools loaded upfront (no deferral) |

**Exempt a server from deferral** (always load into context):

```json
{
  "mcpServers": {
    "core-tools": {
      "type": "http",
      "url": "https://mcp.example.com/mcp",
      "alwaysLoad": true
    }
  }
}
```

`alwaysLoad` requires v2.1.121+. Individual tools can use `"anthropic/alwaysLoad": true` in their `_meta` object. Setting `alwaysLoad: true` blocks startup until connected (capped at 5s), even when `MCP_CONNECTION_NONBLOCKING=1`.

Disable `ToolSearch` tool via permissions:

```json
{ "permissions": { "deny": ["ToolSearch"] } }
```

Tool descriptions and server instructions are truncated at 2KB each.

Requires Sonnet 4+ or Opus 4+ (Haiku models do not support tool search).

### MCP Output Limits

| Setting | Default | Description |
| :--- | :--- | :--- |
| Warning threshold | 10,000 tokens | Claude Code warns when output exceeds this |
| Default max | 25,000 tokens | Default `MAX_MCP_OUTPUT_TOKENS` |
| Hard ceiling (per-tool annotation) | 500,000 chars | Maximum for `anthropic/maxResultSizeChars` |

```bash
export MAX_MCP_OUTPUT_TOKENS=50000
```

Per-tool override in `tools/list` response:

```json
{
  "name": "get_schema",
  "description": "Returns the full database schema",
  "_meta": {
    "anthropic/maxResultSizeChars": 200000
  }
}
```

`anthropic/maxResultSizeChars` applies to text content only; image data still uses `MAX_MCP_OUTPUT_TOKENS`.

### MCP Resources

Reference server resources using `@` mentions:

```
@server:protocol://resource/path
@github:issue://123
@postgres:schema://users
```

Type `@` in prompts to see available resources in autocomplete (fuzzy search supported).

### MCP Prompts as Commands

MCP server prompts appear as `/mcp__servername__promptname` slash commands:

```
/mcp__github__list_prs
/mcp__github__pr_review 456
/mcp__jira__create_issue "Bug in login flow" high
```

Server and prompt names are normalized (spaces become underscores).

### MCP Elicitation

Servers can request structured input mid-task via elicitation dialogs (no config required):

- **Form mode**: Server-defined form fields shown as a dialog
- **URL mode**: Browser URL opened for authentication/approval

Auto-respond with the [`Elicitation` hook](/en/hooks#elicitation).

### Claude Code as MCP Server

```bash
claude mcp serve   # Expose Claude Code's tools to other MCP clients
```

In `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "claude-code": {
      "type": "stdio",
      "command": "/full/path/to/claude",
      "args": ["mcp", "serve"],
      "env": {}
    }
  }
}
```

### Claude.ai MCP Connectors

Claude.ai connectors auto-sync to Claude Code when logged in. Manage at `claude.ai/customize/connectors`.

- A local server takes precedence over a claude.ai connector at the same URL
- Disable with: `ENABLE_CLAUDEAI_MCP_SERVERS=false claude`

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers via `.mcp.json` at plugin root or inline in `plugin.json`. They start automatically when the plugin is enabled. Run `/reload-plugins` to connect/disconnect after enabling/disabling a plugin.

### Managed MCP Configuration (Enterprise)

**Option 1: Exclusive control** — deploy `managed-mcp.json` (same format as `.mcp.json`):

| Platform | Path |
| :--- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux/WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

Users cannot add/modify any servers when this file is present.

**Option 2: Policy-based** — use `allowedMcpServers` / `deniedMcpServers` in managed settings:

Each entry uses exactly one of: `serverName`, `serverCommand` (exact array match), or `serverUrl` (wildcard `*` supported).

| List | Behavior when undefined | Behavior when `[]` | Behavior when populated |
| :--- | :--- | :--- | :--- |
| `allowedMcpServers` | No restrictions | Complete lockdown | Only matching servers allowed |
| `deniedMcpServers` | Nothing blocked | Nothing blocked | Matching servers blocked (takes precedence over allowlist) |

URL patterns: hostname matching is case-insensitive; path matching is case-sensitive. `*` matches any character sequence.

Both options can be combined. Denylist always takes absolute precedence.

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — installing servers, scopes, auth, tool search, output limits, resources, prompts, managed configuration

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
