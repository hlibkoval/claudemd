---
name: mcp-doc
description: Complete official documentation for connecting Claude Code to external tools via the Model Context Protocol (MCP) — adding HTTP/SSE/stdio servers, scopes, OAuth authentication, managed configuration, tool search, MCP resources, prompts, output limits, and using Claude Code as an MCP server.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools and data sources via the Model Context Protocol (MCP).

## Quick Reference

### Adding MCP Servers

| Transport | Command | Best for |
| :--- | :--- | :--- |
| HTTP (recommended) | `claude mcp add --transport http <name> <url>` | Remote cloud services |
| SSE (deprecated) | `claude mcp add --transport sse <name> <url>` | Legacy remote servers |
| stdio | `claude mcp add [options] <name> -- <command> [args...]` | Local processes, system access |

**Option ordering**: all flags (`--transport`, `--env`, `--scope`, `--header`) must come before the server name; `--` separates the server name from the command passed to the MCP server.

**JSON config**: `type` field accepts `streamable-http` as an alias for `http` (the MCP spec name).

### Managing Servers

```bash
claude mcp list              # list all configured servers
claude mcp get <name>        # get details for a specific server
claude mcp remove <name>     # remove a server
claude mcp add-json <name> '<json>'           # add from JSON config
claude mcp add-from-claude-desktop            # import from Claude Desktop (macOS/WSL)
claude mcp reset-project-choices              # reset project-scope approval choices
/mcp                         # within Claude Code: view status, authenticate, manage
```

The reserved name `workspace` is skipped at load time with a warning — rename it.

### Scope Reference

| Scope | Flag | Stored in | Shared with team | Loads in |
| :--- | :--- | :--- | :--- | :--- |
| Local (default) | `--scope local` | `~/.claude.json` | No | Current project only |
| Project | `--scope project` | `.mcp.json` in project root | Yes, via version control | Current project only |
| User | `--scope user` | `~/.claude.json` | No | All projects |

**Precedence** (highest first): Local > Project > User > Plugin-provided > Claude.ai connectors. Duplicates matched by name (scoped servers) or endpoint (plugins/connectors).

### Useful CLI Flags

| Flag | Description |
| :--- | :--- |
| `--env KEY=value` | Set environment variables for the server |
| `--header "Key: val"` | Add static request header (HTTP/SSE) |
| `--scope` | Set storage scope: `local`, `project`, `user` |
| `--callback-port <port>` | Fix OAuth callback port for pre-registered redirect URIs |
| `--client-id <id>` | Pre-configured OAuth client ID |
| `--client-secret` | Prompt for OAuth client secret (masked); set via `MCP_CLIENT_SECRET` env var for CI |

### Environment Variables

| Variable | Effect |
| :--- | :--- |
| `MCP_TIMEOUT=10000` | Server startup timeout in ms (e.g., `MCP_TIMEOUT=10000 claude`) |
| `MAX_MCP_OUTPUT_TOKENS=50000` | Raise max MCP tool output tokens (default 25,000; warning at 10,000) |
| `ENABLE_CLAUDEAI_MCP_SERVERS=false` | Disable synced Claude.ai MCP servers |
| `ENABLE_TOOL_SEARCH` | Control tool search deferral (see table below) |
| `MCP_CLIENT_SECRET` | Provide OAuth client secret non-interactively |

### Tool Search (`ENABLE_TOOL_SEARCH`)

Enabled by default — defers tool schema loading until Claude needs them, keeping context usage low. Requires Sonnet 4+ or Opus 4+; not supported on Haiku.

| Value | Behavior |
| :--- | :--- |
| (unset) | All MCP tools deferred on demand; falls back to upfront on Vertex AI / non-first-party `ANTHROPIC_BASE_URL` |
| `true` | Force deferral everywhere including Vertex AI |
| `auto` | Threshold mode: load upfront if tools fit within 10% of context window |
| `auto:<N>` | Threshold mode with custom percentage (0–100) |
| `false` | Load all tools upfront, no deferral |

**Exempt a server from deferral**: set `"alwaysLoad": true` in the server's config entry (requires v2.1.121+). Individual tools can also be always-loaded by setting `"anthropic/alwaysLoad": true` in the tool's `_meta`.

**Disable the ToolSearch tool**: add `"ToolSearch"` to the `permissions.deny` list in `settings.json`.

### OAuth Authentication

1. Add the server: `claude mcp add --transport http sentry https://mcp.sentry.dev/mcp`
2. Run `/mcp` in Claude Code and follow the browser login flow
3. Tokens stored securely and refreshed automatically; use "Clear authentication" in `/mcp` to revoke

**Fixed callback port** (for pre-registered redirect URIs):
```bash
claude mcp add --transport http --callback-port 8080 my-server https://mcp.example.com/mcp
```

**Pre-configured OAuth credentials** (when server doesn't support Dynamic Client Registration):
```bash
claude mcp add --transport http \
  --client-id your-client-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

**Restrict OAuth scopes** (space-separated string in `oauth.scopes`):
```json
{ "oauth": { "scopes": "channels:read chat:write search:read" } }
```

**Override OAuth metadata discovery** (`authServerMetadataUrl`, requires v2.1.64+):
```json
{ "oauth": { "authServerMetadataUrl": "https://auth.example.com/.well-known/openid-configuration" } }
```

### Dynamic Headers (`headersHelper`)

For custom auth schemes (Kerberos, short-lived tokens, internal SSO). The command must write a JSON object of string key-value pairs to stdout; runs in a shell with a 10-second timeout.

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

Claude Code sets `CLAUDE_CODE_MCP_SERVER_NAME` and `CLAUDE_CODE_MCP_SERVER_URL` for the helper. Dynamic headers override static `headers` with the same name.

### Environment Variable Expansion in `.mcp.json`

| Syntax | Behavior |
| :--- | :--- |
| `${VAR}` | Expands to value of `VAR` |
| `${VAR:-default}` | Expands to `VAR` if set, else `default` |

Works in `command`, `args`, `env`, `url`, and `headers` fields.

### Connection Behavior

- **Dynamic tool updates**: MCP `list_changed` notifications auto-refresh tools/prompts/resources without reconnecting
- **Automatic reconnection** (HTTP/SSE only): exponential backoff, up to 5 attempts (1s, 2s, 4s, 8s, 16s); after 5 failures server is marked failed, retry manually from `/mcp`. Initial connection retried 3 times on transient errors (5xx, connection refused, timeout) as of v2.1.121
- **Stdio servers**: local processes, not auto-reconnected

### MCP Output Limits

| Setting | Default |
| :--- | :--- |
| Warning threshold | 10,000 tokens |
| Max tokens (`MAX_MCP_OUTPUT_TOKENS`) | 25,000 tokens |
| Hard ceiling for `anthropic/maxResultSizeChars` | 500,000 characters |

**Per-tool override** (for MCP server authors): set `_meta["anthropic/maxResultSizeChars"]` in the tool's `tools/list` response. Does not apply to image content — for images, raise `MAX_MCP_OUTPUT_TOKENS`.

```json
{
  "name": "get_schema",
  "description": "Returns the full database schema",
  "_meta": { "anthropic/maxResultSizeChars": 200000 }
}
```

### MCP Resources (@ Mentions)

Reference resources as `@server:protocol://resource/path`:
```
Can you analyze @github:issue://123 and suggest a fix?
Compare @postgres:schema://users with @docs:file://database/user-model
```

Type `@` to autocomplete; resources are fuzzy-searchable. Content fetched and attached automatically.

### MCP Prompts (Commands)

MCP prompts appear in Claude Code as `/mcp__servername__promptname`:
```
/mcp__github__list_prs
/mcp__github__pr_review 456
/mcp__jira__create_issue "Bug in login flow" high
```

### Push Messages via Channels

An MCP server can push messages into a session (CI results, alerts, chat). Declare the `claude/channel` capability and start Claude with `--channels`. See the Channels and Channels reference docs.

### Using Claude Code as an MCP Server

```bash
claude mcp serve   # start Claude Code as a stdio MCP server
```

Add to Claude Desktop's `claude_desktop_config.json`:
```json
{
  "mcpServers": {
    "claude-code": {
      "type": "stdio",
      "command": "claude",
      "args": ["mcp", "serve"],
      "env": {}
    }
  }
}
```

Use `which claude` to find the full path if `claude` isn't in PATH (avoids `spawn claude ENOENT`).

### MCP Elicitation

MCP servers can request structured input mid-task. Claude Code displays an interactive dialog automatically — no configuration needed. Two modes:
- **Form mode**: fill in fields and submit
- **URL mode**: complete auth flow in browser, then confirm in CLI

To auto-respond without a dialog, use the `Elicitation` hook in settings.

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers in `.mcp.json` at the plugin root or inline in `plugin.json`. They start automatically when the plugin is enabled; use `/reload-plugins` to connect/disconnect during a session.

**Plugin environment variables**:

| Variable | Value |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Path to plugin installation |
| `${CLAUDE_PLUGIN_DATA}` | Persistent plugin data directory |

### Claude.ai Connector Sync

Logged-in Claude.ai users: MCP servers added at `claude.ai/customize/connectors` are automatically available in Claude Code. Locally added servers take precedence over matching connectors by URL. Disable with `ENABLE_CLAUDEAI_MCP_SERVERS=false`.

### Managed MCP Configuration (Enterprise)

**Option 1 — Exclusive control** (`managed-mcp.json`): deploy to a system-wide path; users cannot add, modify, or use any other servers.

| OS | Path |
| :--- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux / WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

**Option 2 — Policy-based control** (`allowedMcpServers` / `deniedMcpServers` in managed settings):

| Entry field | Matches |
| :--- | :--- |
| `serverName` | Configured server name |
| `serverCommand` | Exact command + args array (stdio servers) |
| `serverUrl` | Remote URL with `*` wildcard support |

- `allowedMcpServers: undefined` — no restrictions; `[]` — complete lockdown
- `deniedMcpServers` entries take absolute precedence over the allowlist
- When allowlist has `serverCommand` entries, stdio servers must match a command (name alone not sufficient)
- When allowlist has `serverUrl` entries, remote servers must match a URL pattern
- Hostname matching is case-insensitive; paths are case-sensitive

Both options can be combined: `managed-mcp.json` takes exclusive control and allowlists/denylists still filter which managed servers load.

### Practical Examples

```bash
# Sentry (HTTP + OAuth)
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp

# GitHub with Bearer token
claude mcp add --transport http github https://api.githubcopilot.com/mcp/ \
  --header "Authorization: Bearer YOUR_GITHUB_PAT"

# PostgreSQL via stdio
claude mcp add --transport stdio db -- npx -y @bytebase/dbhub \
  --dsn "postgresql://readonly:pass@prod.db.com:5432/analytics"

# Airtable with env var
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server

# Stripe (local scope, default)
claude mcp add --transport http stripe https://mcp.stripe.com

# PayPal (project scope, shared via .mcp.json)
claude mcp add --transport http paypal --scope project https://mcp.paypal.com/mcp

# HubSpot (user scope, all projects)
claude mcp add --transport http hubspot --scope user https://mcp.hubspot.com/anthropic
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — full reference: installing servers, scopes, OAuth, managed configuration, tool search, resources, prompts, output limits, and using Claude Code as an MCP server

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
