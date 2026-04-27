---
name: mcp-doc
description: Complete official documentation for connecting Claude Code to external tools via the Model Context Protocol (MCP) — installing servers, scopes, authentication (OAuth 2.0, headers, headersHelper), managed MCP configuration, tool search, MCP resources, prompts, output limits, and using Claude Code itself as an MCP server.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools via MCP.

## Quick Reference

Claude Code connects to MCP servers to read and act on external tools, databases, and APIs directly in the conversation. Install a server with `claude mcp add`, then reference its tools, resources, and prompts naturally.

### Installing MCP servers

| Transport | Command | Notes |
| :--- | :--- | :--- |
| HTTP (recommended) | `claude mcp add --transport http <name> <url>` | Preferred for cloud services |
| SSE (deprecated) | `claude mcp add --transport sse <name> <url>` | Use HTTP where available |
| stdio (local process) | `claude mcp add --transport stdio <name> -- <cmd> [args]` | Direct system access |

All options (`--transport`, `--env`, `--scope`, `--header`) must appear **before** the server name. Use `--` to separate the server name from the command and its arguments.

```bash
# HTTP example
claude mcp add --transport http notion https://mcp.notion.com/mcp

# HTTP with auth header
claude mcp add --transport http github https://api.githubcopilot.com/mcp/ \
  --header "Authorization: Bearer YOUR_TOKEN"

# stdio example with env var
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server
```

### Managing servers

```bash
claude mcp list               # List all configured servers
claude mcp get <name>         # Show details for one server
claude mcp remove <name>      # Remove a server
/mcp                          # Check status inside Claude Code
```

### Scope reference

| Scope | Flag | Loads in | Shared | Stored in |
| :--- | :--- | :--- | :--- | :--- |
| Local (default) | `--scope local` | Current project | No | `~/.claude.json` |
| Project | `--scope project` | Current project | Yes, via git | `.mcp.json` |
| User | `--scope user` | All projects | No | `~/.claude.json` |

Precedence (highest to lowest): Local → Project → User → Plugin-provided → claude.ai connectors.

### Scope commands

```bash
claude mcp add --transport http stripe --scope local https://mcp.stripe.com
claude mcp add --transport http paypal --scope project https://mcp.paypal.com/mcp
claude mcp add --transport http hubspot --scope user https://mcp.hubspot.com/anthropic
claude mcp reset-project-choices   # Reset approval prompts for .mcp.json servers
```

### Environment variable expansion in `.mcp.json`

Supported in `command`, `args`, `env`, `url`, and `headers`:

```json
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": { "Authorization": "Bearer ${API_KEY}" }
    }
  }
}
```

Syntax: `${VAR}` (required) or `${VAR:-default}` (with fallback).

### OAuth 2.0 authentication

```bash
# Add server, then authenticate interactively
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
/mcp    # follow browser login

# Fixed callback port (required when redirect URI is pre-registered)
claude mcp add --transport http --callback-port 8080 my-server https://mcp.example.com/mcp

# Pre-configured OAuth credentials
claude mcp add --transport http --client-id YOUR_ID --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp

# CI: pass secret via env var
MCP_CLIENT_SECRET=your-secret claude mcp add --transport http \
  --client-id YOUR_ID --client-secret --callback-port 8080 my-server https://mcp.example.com/mcp
```

Authentication tokens are stored securely and refreshed automatically. Use "Clear authentication" in `/mcp` to revoke.

### Advanced OAuth options (in `.mcp.json`)

```json
{
  "mcpServers": {
    "my-server": {
      "type": "http",
      "url": "https://mcp.example.com/mcp",
      "oauth": {
        "authServerMetadataUrl": "https://auth.example.com/.well-known/openid-configuration",
        "scopes": "channels:read chat:write search:read",
        "clientId": "your-client-id",
        "callbackPort": 8080
      }
    }
  }
}
```

- `authServerMetadataUrl` — bypass default discovery (requires v2.1.64+)
- `scopes` — pin the scopes requested during authorization (space-separated string per RFC 6749)
- `clientId` / `callbackPort` — pre-configured credentials for servers without dynamic client registration

### Dynamic headers (`headersHelper`)

Run a shell command at connection time to generate request headers. Useful for Kerberos, short-lived tokens, or internal SSO:

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

The command must write a JSON object of string key-value pairs to stdout. Runs with a 10-second timeout. Available env vars: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`.

### Add from JSON or import from Claude Desktop

```bash
# Add from raw JSON config
claude mcp add-json <name> '<json>'

# Import servers configured in Claude Desktop (macOS and WSL only)
claude mcp add-from-claude-desktop
```

### MCP output limits

| Setting | Default | Description |
| :--- | :--- | :--- |
| Warning threshold | 10,000 tokens | Warning displayed when output exceeds this |
| Default max | 25,000 tokens | Hard limit applied to most tools |
| `MAX_MCP_OUTPUT_TOKENS` | 25,000 | Override the default max via env var |
| `anthropic/maxResultSizeChars` | up to 500,000 chars | Per-tool override set by server authors in `tools/list` response |

```bash
export MAX_MCP_OUTPUT_TOKENS=50000
claude
```

### Tool search (MCP context scaling)

Tool search is enabled by default: only tool names load at session start; definitions are fetched on demand.

| `ENABLE_TOOL_SEARCH` value | Behavior |
| :--- | :--- |
| (unset) | All tools deferred; falls back on Vertex AI / non-first-party `ANTHROPIC_BASE_URL` |
| `true` | Force defer everywhere, including Vertex AI |
| `auto` | Threshold mode: load upfront if within 10% of context window |
| `auto:<N>` | Custom threshold percentage (0–100) |
| `false` | Disable tool search; all tools loaded upfront |

Requires Sonnet 4 or later, or Opus 4 or later. Haiku models do not support tool search.

Disable `ToolSearch` via permissions:
```json
{ "permissions": { "deny": ["ToolSearch"] } }
```

### MCP resources (@ mentions)

Reference server resources with `@server:protocol://resource/path`:

```text
Can you analyze @github:issue://123 and suggest a fix?
Compare @postgres:schema://users with @docs:file://database/user-model
```

Type `@` in a prompt to see autocomplete with available resources.

### MCP prompts as commands

MCP prompts appear as `/mcp__servername__promptname` commands:

```text
/mcp__github__list_prs
/mcp__github__pr_review 456
/mcp__jira__create_issue "Bug in login flow" high
```

### Use Claude Code as an MCP server

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

If `claude` is not in PATH, use the full path from `which claude`.

### Automatic reconnection and dynamic updates

- HTTP/SSE servers reconnect automatically with exponential backoff (up to 5 attempts, starting at 1 second, doubling each time). After 5 failures the server is marked failed; retry manually from `/mcp`.
- Stdio servers are local processes and are not reconnected automatically.
- Claude Code supports MCP `list_changed` notifications, so tool/prompt/resource lists update without reconnecting.

### Push messages via channels

MCP servers can push events into your session (CI results, alerts, chat messages) by declaring the `claude/channel` capability. Enable with the `--channels` flag at startup. See the Channels docs for details.

### Plugin-provided MCP servers

Plugins can bundle MCP servers in `.mcp.json` at the plugin root or inline in `plugin.json`. They start automatically when the plugin is enabled. Run `/reload-plugins` to connect or disconnect plugin MCP servers mid-session.

```json
{
  "mcpServers": {
    "database-tools": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"],
      "env": { "DB_URL": "${DB_URL}" }
    }
  }
}
```

Use `${CLAUDE_PLUGIN_ROOT}` for bundled files and `${CLAUDE_PLUGIN_DATA}` for persistent state.

### Managed MCP configuration (enterprise)

**Option 1 — Exclusive control (`managed-mcp.json`):** Deploy a fixed server list; users cannot add or modify servers.

| Platform | Path |
| :--- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux / WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

**Option 2 — Allowlists / denylists (in managed settings):** Users can add their own servers within policy constraints.

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

Each entry uses exactly one of: `serverName`, `serverCommand` (exact array match), or `serverUrl` (wildcard `*` supported). Denylist takes absolute precedence. An empty `allowedMcpServers: []` locks out all user-configured servers.

### Elicitation

MCP servers can request structured mid-task input via elicitation dialogs (form mode or URL-based browser flow). No configuration needed — dialogs appear automatically. Auto-respond using the `Elicitation` hook.

### Useful environment variables

| Variable | Effect |
| :--- | :--- |
| `MCP_TIMEOUT` | Server startup timeout in ms (e.g. `MCP_TIMEOUT=10000`) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens for tool output (default 25,000) |
| `ENABLE_TOOL_SEARCH` | Control tool search behavior (see table above) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set to `false` to disable claude.ai connectors in Claude Code |

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — full guide covering MCP server installation (HTTP, SSE, stdio), scope management, dynamic updates, automatic reconnection, push channels, plugin MCP servers, scope hierarchy, environment variable expansion, OAuth 2.0 authentication, dynamic headers, JSON config, Claude Desktop import, claude.ai connectors, Claude Code as an MCP server, output limits and the `anthropic/maxResultSizeChars` annotation, elicitation, MCP resources, tool search, MCP prompts as commands, and managed/enterprise MCP configuration

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
