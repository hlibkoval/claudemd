---
name: mcp-doc
description: Complete official documentation for connecting Claude Code to external tools via the Model Context Protocol (MCP) — server transports, installation scopes, OAuth authentication, managed configuration, tool search, resources, prompts, and output limits.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools via MCP.

## Quick Reference

### Installing MCP Servers

```bash
# HTTP server (recommended for remote services)
claude mcp add --transport http <name> <url>
claude mcp add --transport http notion https://mcp.notion.com/mcp

# HTTP with Bearer token
claude mcp add --transport http github https://api.githubcopilot.com/mcp/ \
  --header "Authorization: Bearer YOUR_TOKEN"

# SSE server (deprecated — prefer HTTP)
claude mcp add --transport sse <name> <url>

# Stdio server (local process)
claude mcp add --transport stdio --env KEY=value <name> -- <command> [args...]
claude mcp add --transport stdio --env AIRTABLE_API_KEY=KEY airtable \
  -- npx -y airtable-mcp-server
```

**Option ordering:** all flags (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. `--` separates the server name from the server's own command and arguments.

### Managing Servers

```bash
claude mcp list           # List all configured servers
claude mcp get <name>     # Details for a specific server
claude mcp remove <name>  # Remove a server
claude mcp add-json <name> '<json>'           # Add from JSON config
claude mcp add-from-claude-desktop            # Import from Claude Desktop (macOS/WSL only)
claude mcp reset-project-choices              # Reset project-scope approval choices
/mcp                      # Within Claude Code: status, auth, and management panel
```

The server name `workspace` is reserved — Claude Code skips it and shows a warning.

### Scopes

| Scope     | CLI flag          | Loads in             | Shared?  | Stored in                   |
| :-------- | :---------------- | :------------------- | :------- | :-------------------------- |
| `local`   | `--scope local`   | Current project only | No       | `~/.claude.json`            |
| `project` | `--scope project` | Current project only | Yes (VC) | `.mcp.json` in project root |
| `user`    | `--scope user`    | All your projects    | No       | `~/.claude.json`            |

**Precedence (highest first):** local → project → user → plugin-provided → claude.ai connectors. Duplicates matched by name (scopes) or endpoint (plugins/connectors).

### `.mcp.json` Format

```json
{
  "mcpServers": {
    "server-name": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": { "Authorization": "Bearer ${API_KEY}" }
    },
    "stdio-server": {
      "command": "${CLAUDE_PROJECT_DIR}/scripts/server",
      "args": ["--config", "config.json"],
      "env": { "KEY": "value" }
    }
  }
}
```

**Env var expansion:** `${VAR}` and `${VAR:-default}` work in `command`, `args`, `env`, `url`, and `headers`. Missing vars with no default cause a parse failure.

**`type` field:** `http` and `streamable-http` are aliases — configs copied from MCP server docs work without modification.

### OAuth Authentication

```bash
# Add server, then authenticate via /mcp
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
/mcp   # follow browser login

# Fixed callback port (for pre-registered redirect URIs)
claude mcp add --transport http --callback-port 8080 my-server https://mcp.example.com/mcp

# Pre-configured OAuth credentials
claude mcp add --transport http --client-id your-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp

# Via env var (CI/non-interactive)
MCP_CLIENT_SECRET=secret claude mcp add --transport http \
  --client-id your-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

Tokens stored in system keychain. Use "Clear authentication" in `/mcp` to revoke. OAuth only applies to HTTP and SSE transports.

**`oauth` config fields (in `.mcp.json`):**

| Field                  | Description                                                                    |
| :--------------------- | :----------------------------------------------------------------------------- |
| `clientId`             | Pre-configured OAuth client ID                                                 |
| `callbackPort`         | Fixed port for `http://localhost:PORT/callback` redirect URI                   |
| `authServerMetadataUrl`| Override OAuth discovery URL (requires v2.1.64+, must use `https://`)         |
| `scopes`               | Space-separated scope string to pin (RFC 6749 §3.3); takes precedence over server-advertised scopes |

### Dynamic Headers (`headersHelper`)

Run a script at connection time to generate auth headers (for Kerberos, short-lived tokens, etc.):

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

The command must print a JSON object of string key-value pairs to stdout. Runs in a shell with 10-second timeout. Dynamic headers override static `headers` with the same name. Available env vars: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`.

### Output Limits

| Setting                    | Default  | Override                                    |
| :------------------------- | :------- | :------------------------------------------ |
| Warning threshold          | 10,000 tokens | —                                      |
| Max output tokens          | 25,000   | `MAX_MCP_OUTPUT_TOKENS=<n>` env var         |
| Per-tool limit (server-side) | —      | `_meta["anthropic/maxResultSizeChars"]` in `tools/list` (max 500,000 chars) |

Per-tool annotation applies to text content only; image content always uses `MAX_MCP_OUTPUT_TOKENS`.

### Tool Search

Defers MCP tool definitions until needed to keep context usage low. Enabled by default (disabled by default on Vertex AI and non-first-party `ANTHROPIC_BASE_URL` hosts).

| `ENABLE_TOOL_SEARCH` value | Behavior                                                                 |
| :------------------------- | :----------------------------------------------------------------------- |
| (unset)                    | All tools deferred; falls back to upfront on Vertex AI / proxy hosts     |
| `true`                     | Force deferral; fails if backend lacks `tool_reference` support          |
| `auto`                     | Load upfront if schemas fit within 10% of context window, defer overflow |
| `auto:<N>`                 | Same, with custom `<N>`% threshold                                       |
| `false`                    | Load all tools upfront                                                   |

**Exempt a server from deferral** — set `alwaysLoad: true` in the server config (requires v2.1.121+). Can also set per-tool: `"_meta": {"anthropic/alwaysLoad": true}` in `tools/list`.

**Disable `ToolSearch` tool specifically:**
```json
{ "permissions": { "deny": ["ToolSearch"] } }
```

### Plugin-provided MCP Servers

Plugins can define MCP servers in `.mcp.json` at plugin root or inline in `plugin.json`. They start automatically when the plugin is enabled; run `/reload-plugins` after enabling/disabling a plugin mid-session.

Available path variables in plugin MCP config:

| Variable               | Resolves to                                        |
| :--------------------- | :------------------------------------------------- |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory                     |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data dir (survives updates)     |
| `${CLAUDE_PROJECT_DIR}` | Project root (no `:-` default needed in plugins)  |

### Managed MCP Configuration (Enterprise)

**Option 1 — Exclusive control via `managed-mcp.json`:** Deploys a fixed set; users cannot add others.

| Platform    | Path                                                   |
| :---------- | :----------------------------------------------------- |
| macOS       | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux / WSL | `/etc/claude-code/managed-mcp.json`                    |
| Windows     | `C:\Program Files\ClaudeCode\managed-mcp.json`         |

**Option 2 — Allowlists/denylists in managed settings:** Users can add servers within policy constraints.

Each entry specifies exactly one of:
- `serverName` — matches configured server name
- `serverCommand` — exact command array match for stdio servers
- `serverUrl` — URL pattern with `*` wildcard support

```json
{
  "allowedMcpServers": [
    { "serverName": "github" },
    { "serverCommand": ["npx", "-y", "approved-package"] },
    { "serverUrl": "https://mcp.company.com/*" }
  ],
  "deniedMcpServers": [
    { "serverUrl": "https://*.untrusted.com/*" }
  ]
}
```

**Allowlist semantics:** `undefined` = no restriction; `[]` = complete lockdown; list = only matching servers allowed. Denylist takes absolute precedence. Command entries restrict stdio servers; URL entries restrict remote servers. Hostname matching is case-insensitive; paths are case-sensitive.

### MCP Resources

Reference resources using `@server:protocol://resource/path` syntax in prompts. Type `@` to see autocomplete from all connected servers.

### MCP Prompts as Commands

MCP server prompts appear as slash commands: `/mcp__<servername>__<promptname>`. Pass arguments space-separated after the command name.

### Reconnection and Dynamic Updates

- HTTP/SSE servers auto-reconnect with exponential backoff: up to 5 attempts, starting at 1 second, doubling each time.
- Startup reconnection: up to 3 retries on transient errors (5xx, connection refused, timeout). Auth/404 errors are not retried.
- `list_changed` notifications: Claude Code automatically refreshes tools/prompts/resources without reconnecting.

### Use Claude Code as an MCP Server

```bash
claude mcp serve   # Start Claude Code as a stdio MCP server
```

Add to `claude_desktop_config.json` to use from Claude Desktop:
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

### `CLAUDE_PROJECT_DIR` in Stdio Servers

Claude Code sets `CLAUDE_PROJECT_DIR` in the spawned server's environment. Access it as `process.env.CLAUDE_PROJECT_DIR` (Node) or `os.environ["CLAUDE_PROJECT_DIR"]` (Python). In project/user `.mcp.json` `command`/`args`, use `${CLAUDE_PROJECT_DIR:-.}` as a default in case it isn't set.

### Env Vars Summary

| Variable                    | Effect                                                        |
| :-------------------------- | :------------------------------------------------------------ |
| `MCP_TIMEOUT`               | Server startup timeout in ms (e.g., `MCP_TIMEOUT=10000`)     |
| `MAX_MCP_OUTPUT_TOKENS`     | Max tool output tokens before truncation (default 25,000)     |
| `ENABLE_TOOL_SEARCH`        | Control tool search deferral behavior                         |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set to `false` to disable claude.ai connector servers       |
| `MCP_CLIENT_SECRET`         | OAuth client secret for non-interactive OAuth setup           |
| `MCP_CONNECTION_NONBLOCKING`| Set to `1` to connect non-`alwaysLoad` servers in background  |

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — server transports, installation scopes, OAuth, managed configuration, tool search, resources, prompts, output limits, and using Claude Code as an MCP server

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
