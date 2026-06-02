---
name: mcp-doc
user-invocable: false
---

# MCP (Model Context Protocol) Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools and data sources via MCP, including server configuration, authentication, scopes, tool search, and enterprise access controls.

## Quick Reference

### Add an MCP Server

All options must come **before** the server name. The `--` separator separates the server name from the command.

```bash
# HTTP server (recommended for cloud services)
claude mcp add --transport http <name> <url>

# HTTP with auth header
claude mcp add --transport http <name> <url> --header "Authorization: Bearer TOKEN"

# SSE server (deprecated; use HTTP instead)
claude mcp add --transport sse <name> <url>

# Local stdio server
claude mcp add --transport stdio --env KEY=value <name> -- <command> [args...]

# WebSocket (via JSON; --transport does not accept ws)
claude mcp add-json <name> '{"type":"ws","url":"wss://..."}'

# From JSON config
claude mcp add-json <name> '<json>'

# Import from Claude Desktop (macOS / WSL only)
claude mcp add-from-claude-desktop
```

### Manage Servers

```bash
claude mcp list              # list all configured servers
claude mcp get <name>        # show details for a server
claude mcp remove <name>     # remove a server
claude mcp reset-project-choices  # reset .mcp.json approval choices
```

Within a session: `/mcp` — shows server status, tool counts, OAuth flows, reconnect.

### Connection Status Indicators

| Status | Meaning |
|:-------|:--------|
| `✓ Connected` | Ready to use |
| `! Needs authentication` | OAuth sign-in required — use `/mcp` |
| `✗ Failed to connect` | Server didn't respond; check URL/command |
| `✗ Connection error` | Connection attempt threw an error |
| `⏸ Pending approval` | Project-scoped server awaiting your approval |

### Scope Summary

| Scope | Default? | Stored in | Visible to |
|:------|:---------|:----------|:-----------|
| `local` | Yes | `~/.claude.json` (per-project entry) | Only you, current project |
| `project` | No | `.mcp.json` in project root | Everyone (commit to VCS) |
| `user` | No | `~/.claude.json` (top-level key) | Only you, all projects |

Specify with `--scope local|project|user`. Precedence order (highest wins): local → project → user → plugin → claude.ai connectors.

### Scope CLI Examples

```bash
claude mcp add --scope user --transport http <name> <url>
claude mcp add --scope project --transport http <name> <url>
```

### Environment Variable Expansion in `.mcp.json`

Supported in `command`, `args`, `env`, `url`, `headers`:

```json
{
  "mcpServers": {
    "api": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": { "Authorization": "Bearer ${API_KEY}" }
    }
  }
}
```

Syntax: `${VAR}` (required) or `${VAR:-default}` (with fallback).

### `.mcp.json` Format (Project Scope)

```json
{
  "mcpServers": {
    "http-server": {
      "type": "http",
      "url": "https://mcp.example.com/mcp"
    },
    "stdio-server": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "some-mcp-server"],
      "env": { "API_KEY": "${MY_API_KEY}" }
    }
  }
}
```

`type` field accepts `streamable-http` as an alias for `http`.

### Key Environment Variables

| Variable | Effect |
|:---------|:-------|
| `MCP_TIMEOUT` | Startup timeout in ms (default 30 s) |
| `MCP_TOOL_TIMEOUT` | Default per-tool execution timeout in ms |
| `MAX_MCP_OUTPUT_TOKENS` | Warning threshold and limit for tool output (default 25,000) |
| `ENABLE_TOOL_SEARCH` | Control deferred tool loading (see Tool Search) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set `false` to disable claude.ai connectors |
| `CLAUDE_PROJECT_DIR` | Injected into stdio server environment; project root path |

Per-server `timeout` field (ms) in `.mcp.json` overrides `MCP_TOOL_TIMEOUT` for that server only.

### OAuth Authentication Flow

1. `claude mcp add --transport http <name> <url>`
2. If server requires sign-in, `claude mcp list` shows `! Needs authentication`
3. In a session, run `/mcp`, select the server, choose **Authenticate**
4. Complete browser sign-in; token stored securely and auto-refreshed

#### Fixed Callback Port

```bash
claude mcp add --transport http --callback-port 8080 <name> <url>
```

#### Pre-configured OAuth Credentials

```bash
claude mcp add --transport http \
  --client-id <id> --client-secret --callback-port 8080 \
  <name> <url>
# or via env var: MCP_CLIENT_SECRET=<secret> claude mcp add ...
```

#### Restrict OAuth Scopes

```json
{
  "mcpServers": {
    "slack": {
      "type": "http",
      "url": "https://mcp.slack.com/mcp",
      "oauth": { "scopes": "channels:read chat:write" }
    }
  }
}
```

#### Override OAuth Discovery

```json
{ "oauth": { "authServerMetadataUrl": "https://auth.example.com/.well-known/openid-configuration" } }
```

Requires v2.1.64+.

### Dynamic Headers (`headersHelper`)

For non-OAuth auth (Kerberos, short-lived tokens, SSO):

```json
{
  "mcpServers": {
    "internal": {
      "type": "http",
      "url": "https://mcp.internal.example.com",
      "headersHelper": "/opt/bin/get-mcp-auth-headers.sh"
    }
  }
}
```

The script must write a JSON object of string key-value pairs to stdout. It runs in a shell with a 10-second timeout on each connection. Environment variables set: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`.

### MCP Tool Search

Tool search is **enabled by default**. MCP tool definitions are deferred; only names and server instructions load at session start. Claude discovers relevant tools on demand via `ToolSearch`.

| `ENABLE_TOOL_SEARCH` value | Behavior |
|:---------------------------|:---------|
| (unset) | All tools deferred; falls back to upfront on Vertex AI / non-first-party `ANTHROPIC_BASE_URL` |
| `true` | All tools deferred; sends beta header even on Vertex AI |
| `auto` | Load upfront if within 10% of context window, else defer |
| `auto:N` | Custom threshold percentage (0–100) |
| `false` | All tools loaded upfront |

Supported models: Sonnet 4+, Opus 4+ (not Haiku). On Vertex AI: Sonnet 4.5+ and Opus 4.5+.

#### Exempt a Server from Deferral

```json
{ "type": "http", "url": "...", "alwaysLoad": true }
```

Or annotate individual tools with `"anthropic/alwaysLoad": true` in the tool's `_meta` object. Requires v2.1.121+.

### MCP Output Limits

| Setting | Default | Notes |
|:--------|:--------|:------|
| Warning threshold | 10,000 tokens | Displays warning in UI |
| Hard limit (`MAX_MCP_OUTPUT_TOKENS`) | 25,000 tokens | Applies to all tools without `_meta` annotation |
| Per-tool annotation (`anthropic/maxResultSizeChars`) | Up to 500,000 chars | Set in server's `tools/list` response `_meta`; text only |

### MCP Resources

Reference MCP resources in prompts with `@`:

```
@github:issue://123
@docs:file://api/authentication
```

Type `@` to browse available resources from connected servers.

### MCP Prompts as Commands

MCP prompts appear as `/mcp__<servername>__<promptname>` commands:

```
/mcp__github__list_prs
/mcp__jira__create_issue "Bug title" high
```

### Plugin-Provided MCP Servers

Plugins bundle MCP servers in `.mcp.json` at plugin root or inline in `plugin.json`. They start automatically when the plugin is enabled. Run `/reload-plugins` after enabling/disabling a plugin to connect/disconnect its servers mid-session.

Plugin MCP env vars: `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`, `${CLAUDE_PROJECT_DIR}`.

### Use Claude Code as an MCP Server

```bash
claude mcp serve
```

Add to `claude_desktop_config.json`:

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

### Managed MCP (Enterprise)

Admins can control which servers users can connect to.

#### `managed-mcp.json` Paths

| Platform | Path |
|:---------|:-----|
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux / WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

Uses same format as `.mcp.json`. When deployed, users cannot add, modify, or use any other servers.

To **disable MCP entirely**: deploy `{ "mcpServers": {} }`.

#### Control Patterns

| Pattern | Configuration |
|:--------|:-------------|
| Disable MCP | `managed-mcp.json` with empty server map |
| Fixed deployment | `managed-mcp.json` with approved servers |
| Approved catalog | `allowedMcpServers` + `allowManagedMcpServersOnly: true` |
| Plugin servers only | `strictPluginOnlyCustomization` with `mcp` in the list |
| Soft allowlist | `allowedMcpServers` without `allowManagedMcpServersOnly` |
| Denylist only | `deniedMcpServers` |

#### Allowlist / Denylist Match Keys

| Key | Matches | Use for |
|:----|:--------|:--------|
| `serverUrl` | URL, exact or with `*` wildcards | HTTP/SSE servers |
| `serverCommand` | Exact command + args array | Stdio servers |
| `serverName` | User-assigned label (exact) | Weak fallback only |

Empty `allowedMcpServers: []` blocks all servers. Unset = all allowed. Denylists always merge from all settings sources.

URL wildcard examples: `https://mcp.example.com/*`, `https://*.example.com/*`, `http://localhost:*/*`.

#### User-Visible Restriction Messages

| Situation | What the user sees |
|:----------|:-------------------|
| `managed-mcp.json` present, user runs `claude mcp add` | `Cannot add MCP server: enterprise MCP configuration is active…` |
| Server on denylist, user runs `claude mcp add` | `Cannot add MCP server "<name>": server is explicitly blocked by enterprise policy` |
| Server not on allowlist, user runs `claude mcp add` | `Cannot add MCP server "<name>": not allowed by enterprise policy` |
| Previously configured server now blocked | Server silently disappears from `/mcp` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — Full MCP reference: transports, scopes, authentication, tool search, output limits, resources, prompts, and plugin servers
- [Connect to MCP servers (Quickstart)](references/claude-code-mcp-quickstart.md) — Step-by-step walkthrough: adding, verifying, and troubleshooting your first MCP server
- [Control MCP server access for your organization](references/claude-code-managed-mcp.md) — Enterprise managed MCP: `managed-mcp.json`, allowlists, denylists, monitoring, and restriction patterns

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
- Connect to MCP servers (Quickstart): https://code.claude.com/docs/en/mcp-quickstart.md
- Control MCP server access for your organization: https://code.claude.com/docs/en/managed-mcp.md
