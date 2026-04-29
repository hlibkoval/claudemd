---
name: mcp-doc
description: Complete official documentation for connecting Claude Code to external tools via the Model Context Protocol (MCP) — installing servers, scopes, authentication, OAuth, managed configuration, tool search, resources, prompts, and output limits.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools and data sources via the Model Context Protocol (MCP).

## Quick Reference

### Add an MCP Server

```bash
# HTTP (recommended for remote servers)
claude mcp add --transport http <name> <url>

# HTTP with auth header
claude mcp add --transport http github https://api.githubcopilot.com/mcp/ \
  --header "Authorization: Bearer YOUR_TOKEN"

# SSE (deprecated — prefer HTTP)
claude mcp add --transport sse <name> <url>

# Stdio (local process)
claude mcp add --transport stdio --env KEY=value <name> -- <command> [args...]
```

**Important:** All options (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. `--` separates the server name from the command.

### Manage Servers

```bash
claude mcp list           # List all configured servers
claude mcp get <name>     # Get details for a server
claude mcp remove <name>  # Remove a server
claude mcp add-json <name> '<json>'             # Add from JSON config
claude mcp add-from-claude-desktop              # Import from Claude Desktop (macOS/WSL)
/mcp                      # Check status, authenticate OAuth servers
```

### Installation Scopes

| Scope | Default? | Loads in | Shared | Stored in |
| :--- | :--- | :--- | :--- | :--- |
| `local` | Yes | Current project | No | `~/.claude.json` |
| `project` | No | Current project | Yes (via `.mcp.json`) | `.mcp.json` in project root |
| `user` | No | All projects | No | `~/.claude.json` |

Use `--scope <local|project|user>` when adding a server. Project scope writes `.mcp.json` (designed for version control). Claude Code prompts for approval before using project-scoped servers.

**Scope precedence** (highest wins):
1. Local scope
2. Project scope
3. User scope
4. Plugin-provided servers
5. Claude.ai connectors

### `.mcp.json` Format

```json
{
  "mcpServers": {
    "my-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": { "Authorization": "Bearer ${API_KEY}" }
    }
  }
}
```

**Env var expansion** (`${VAR}`, `${VAR:-default}`) supported in: `command`, `args`, `env`, `url`, `headers`.

### Authenticate with Remote Servers (OAuth 2.0)

1. Add the server: `claude mcp add --transport http sentry https://mcp.sentry.dev/mcp`
2. Run `/mcp` in Claude Code and follow the browser login
3. Tokens are stored securely and refreshed automatically; use "Clear authentication" to revoke

**Fixed callback port** (for pre-registered redirect URIs):
```bash
claude mcp add --transport http --callback-port 8080 my-server https://mcp.example.com/mcp
```

**Pre-configured OAuth credentials** (when dynamic client registration is not supported):
```bash
claude mcp add --transport http \
  --client-id your-client-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

**Override OAuth metadata discovery** (in `.mcp.json`):
```json
{
  "mcpServers": {
    "my-server": {
      "type": "http",
      "url": "https://mcp.example.com/mcp",
      "oauth": {
        "authServerMetadataUrl": "https://auth.example.com/.well-known/openid-configuration"
      }
    }
  }
}
```

**Restrict OAuth scopes** (`oauth.scopes` — space-separated string, takes precedence over server-advertised scopes):
```json
"oauth": { "scopes": "channels:read chat:write search:read" }
```

### Dynamic Headers (Non-OAuth Auth)

Use `headersHelper` in `.mcp.json` for Kerberos, short-lived tokens, or internal SSO:

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

- The helper must write a JSON object of string key-value pairs to stdout
- 10-second timeout; runs fresh on each connection (no caching)
- Env vars available: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`
- Dynamic headers override static `headers` with the same name

### Connection Behavior

| Feature | Detail |
| :--- | :--- |
| Auto-reconnect | HTTP/SSE: exponential backoff, up to 5 attempts (1s, 2s, 4s, 8s, 16s); stdio not reconnected |
| Initial retry | Up to 3 retries on transient errors (5xx, timeout, connection refused); auth/not-found errors not retried |
| Dynamic tool updates | Supports `list_changed` notifications — tools refresh without disconnect |
| Push messages (channels) | MCP servers declaring `claude/channel` can push messages into sessions; enable with `--channels` |

### Output Limits

| Setting | Default | Env var |
| :--- | :--- | :--- |
| Warning threshold | 10,000 tokens | — |
| Hard limit (default) | 25,000 tokens | `MAX_MCP_OUTPUT_TOKENS` |
| Per-tool override | Up to 500,000 chars | `_meta["anthropic/maxResultSizeChars"]` in `tools/list` |

```bash
export MAX_MCP_OUTPUT_TOKENS=50000
claude
```

Tool-level override example (in MCP server's `tools/list` response):
```json
{
  "name": "get_schema",
  "_meta": { "anthropic/maxResultSizeChars": 200000 }
}
```

### Tool Search (Scale with Many Servers)

Tool search defers MCP tool loading — only names load at session start; definitions load on demand.

| `ENABLE_TOOL_SEARCH` | Behavior |
| :--- | :--- |
| (unset) | Deferred on first-party hosts; upfront on Vertex AI / non-first-party `ANTHROPIC_BASE_URL` |
| `true` | All MCP tools deferred everywhere |
| `auto` | Threshold: load upfront if within 10% of context window |
| `auto:<N>` | Threshold with custom percentage (0–100) |
| `false` | All MCP tools loaded upfront |

**Exempt a specific server** from deferral (always loads its tools):
```json
{ "mcpServers": { "core-tools": { "type": "http", "url": "...", "alwaysLoad": true } } }
```

- Per-tool: set `"anthropic/alwaysLoad": true` in the tool's `_meta` object
- Requires Claude Code v2.1.121+; supported models: Sonnet 4+, Opus 4+ (not Haiku)

Disable `ToolSearch` tool via permissions:
```json
{ "permissions": { "deny": ["ToolSearch"] } }
```

### MCP Resources

Reference MCP resources with `@` mentions (similar to files):

```
@server:protocol://resource/path
@github:issue://123
@postgres:schema://users
```

Type `@` to see available resources in autocomplete alongside files.

### MCP Prompts as Commands

MCP prompts appear as `/mcp__servername__promptname` commands. Type `/` to discover them.

```
/mcp__github__list_prs
/mcp__github__pr_review 456
/mcp__jira__create_issue "Bug in login flow" high
```

### Elicitation

MCP servers can request structured input mid-task. Claude Code shows a dialog automatically (no configuration needed). Use the [`Elicitation` hook](/en/hooks#elicitation) to auto-respond without a dialog.

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers in `.mcp.json` at the plugin root or inline in `plugin.json`. Plugin servers start automatically when the plugin is enabled. Run `/reload-plugins` to connect/disconnect during a session.

**Environment variables in plugin MCP configs:**
- `${CLAUDE_PLUGIN_ROOT}` — path to bundled plugin files
- `${CLAUDE_PLUGIN_DATA}` — persistent state directory (survives updates)

### Claude Code as an MCP Server

```bash
claude mcp serve   # Start Claude Code as a stdio MCP server
```

Add to `claude_desktop_config.json`:
```json
{
  "mcpServers": {
    "claude-code": { "type": "stdio", "command": "claude", "args": ["mcp", "serve"], "env": {} }
  }
}
```

### Use Claude.ai Connectors

If logged in with a Claude.ai account, MCP servers from [claude.ai/customize/connectors](https://claude.ai/customize/connectors) are automatically available. Disable with:
```bash
ENABLE_CLAUDEAI_MCP_SERVERS=false claude
```

### Managed MCP Configuration (Enterprise)

**Option 1 — Exclusive control** (`managed-mcp.json`): users cannot add other servers.

Deploy to system-wide path:
- macOS: `/Library/Application Support/ClaudeCode/managed-mcp.json`
- Linux/WSL: `/etc/claude-code/managed-mcp.json`
- Windows: `C:\Program Files\ClaudeCode\managed-mcp.json`

**Option 2 — Policy allowlists/denylists** (in managed settings):

```json
{
  "allowedMcpServers": [
    { "serverName": "github" },
    { "serverCommand": ["npx", "-y", "@modelcontextprotocol/server-filesystem"] },
    { "serverUrl": "https://mcp.company.com/*" }
  ],
  "deniedMcpServers": [
    { "serverUrl": "https://*.untrusted.com/*" }
  ]
}
```

| Restriction type | Matches by |
| :--- | :--- |
| `serverName` | Configured name |
| `serverCommand` | Exact command array (stdio only) |
| `serverUrl` | URL with wildcard `*` support |

- Denylist takes absolute precedence over allowlist
- Empty `allowedMcpServers: []` = complete lockdown
- Command restrictions only affect stdio servers; URL restrictions only affect remote servers

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — installing servers (HTTP/SSE/stdio), scopes, environment variable expansion, OAuth authentication, dynamic headers, output limits, tool search, resources, prompts, elicitation, plugin MCP servers, Claude as MCP server, Claude.ai connectors, and managed/enterprise MCP configuration

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
