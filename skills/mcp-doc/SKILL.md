---
name: mcp-doc
description: Complete official documentation for connecting Claude Code to external tools via the Model Context Protocol (MCP) — installing servers (HTTP, SSE, stdio), scopes, authentication (OAuth 2.0, headers, headersHelper), JSON config, import from Claude Desktop, claude.ai connectors, plugin MCP servers, tool search, MCP resources, prompts, output limits, elicitation, and managed/enterprise MCP configuration.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools and data sources through the Model Context Protocol (MCP).

## Quick Reference

### Transport Types

| Transport | Command flag | Use case |
| :--- | :--- | :--- |
| HTTP (recommended) | `--transport http` | Remote cloud services; supports reconnection |
| SSE (deprecated) | `--transport sse` | Legacy remote servers; use HTTP instead |
| stdio | `--transport stdio` (default) | Local processes needing direct system access |

### Adding MCP Servers

```bash
# HTTP server
claude mcp add --transport http <name> <url>

# HTTP with auth header
claude mcp add --transport http <name> <url> --header "Authorization: Bearer token"

# SSE (deprecated)
claude mcp add --transport sse <name> <url>

# stdio (local process) — options must come BEFORE name, command after --
claude mcp add --transport stdio --env KEY=value <name> -- npx -y some-package

# From JSON
claude mcp add-json <name> '<json-config>'

# Import from Claude Desktop (macOS and WSL only)
claude mcp add-from-claude-desktop
```

### Managing Servers

```bash
claude mcp list           # List all configured servers
claude mcp get <name>     # Details for a specific server
claude mcp remove <name>  # Remove a server
/mcp                      # In-session: status, auth, tool counts
```

The `/mcp` panel shows tool counts per server and flags servers with no tools. The reserved name `workspace` is skipped at load time.

### Scope

| Scope | Flag | Stored in | Shared |
| :--- | :--- | :--- | :--- |
| `local` (default) | `--scope local` | `~/.claude.json` (per project path) | No |
| `project` | `--scope project` | `.mcp.json` in project root | Yes, via VCS |
| `user` | `--scope user` | `~/.claude.json` (all projects) | No |

**Precedence** (highest first): local → project → user → plugin-provided → claude.ai connectors. Duplicates matched by name (scopes) or endpoint (plugins/connectors).

Note: MCP "local" scope stores in `~/.claude.json`, not `.claude/settings.local.json`.

### .mcp.json Format

```json
{
  "mcpServers": {
    "my-server": {
      "command": "/path/to/server",
      "args": [],
      "env": {}
    },
    "http-server": {
      "type": "http",
      "url": "https://mcp.example.com/mcp"
    }
  }
}
```

**Environment variable expansion in `.mcp.json`:**

| Syntax | Behavior |
| :--- | :--- |
| `${VAR}` | Expands to env var value (error if unset) |
| `${VAR:-default}` | Expands to `VAR` or `default` if unset |

Expansion works in: `command`, `args`, `env`, `url`, `headers`.

Project-scoped servers require approval before use; reset with `claude mcp reset-project-choices`.

### OAuth 2.0 Authentication

```bash
# Add server, then authenticate interactively
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
/mcp   # follow browser login flow

# Fixed callback port (when redirect URI must be pre-registered)
claude mcp add --transport http --callback-port 8080 my-server https://mcp.example.com/mcp

# Pre-configured OAuth credentials
claude mcp add --transport http --client-id your-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp

# Via env var for CI
MCP_CLIENT_SECRET=your-secret claude mcp add --transport http \
  --client-id your-id --client-secret --callback-port 8080 my-server https://mcp.example.com/mcp
```

**OAuth config in `.mcp.json`:**

```json
{
  "mcpServers": {
    "my-server": {
      "type": "http",
      "url": "https://mcp.example.com/mcp",
      "oauth": {
        "clientId": "your-client-id",
        "callbackPort": 8080,
        "authServerMetadataUrl": "https://auth.example.com/.well-known/openid-configuration",
        "scopes": "channels:read chat:write"
      }
    }
  }
}
```

- `authServerMetadataUrl`: Override OAuth discovery; requires v2.1.64+
- `scopes`: Space-separated string (RFC 6749 §3.3); takes precedence over server-advertised scopes

### Dynamic Headers (headersHelper)

For non-OAuth auth (Kerberos, short-lived tokens, SSO):

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
- 10-second timeout; runs fresh on each connection
- Env vars available: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`
- Dynamic headers override static `headers` with the same name
- Runs after workspace trust dialog for project/local scope

### Connection and Reconnection

- **HTTP/SSE**: Auto-reconnects with exponential backoff — up to 5 attempts, starting at 1s, doubling each time
- **Initial connection**: Up to 3 retries on transient errors (5xx, connection refused, timeout); auth/404 errors not retried
- **stdio**: No auto-reconnect (local processes)
- **Status**: Pending in `/mcp` during reconnect; marked failed after max attempts

### Environment Variables

| Variable | Purpose |
| :--- | :--- |
| `MCP_TIMEOUT` | MCP server startup timeout in ms (e.g. `MCP_TIMEOUT=10000`) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens per tool output (default 25,000; warning at 10,000) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set to `false` to disable claude.ai connector servers |
| `ENABLE_TOOL_SEARCH` | Control tool search behavior (see Tool Search section) |
| `MCP_CONNECTION_NONBLOCKING` | Set to `1` for non-blocking server connections at startup |

### Tool Search

Tool search defers MCP tool definitions to keep context usage low. Only tool names load at session start; schemas load on demand.

| `ENABLE_TOOL_SEARCH` value | Behavior |
| :--- | :--- |
| (unset) | All tools deferred; falls back to upfront on Vertex AI or non-first-party base URL |
| `true` | All tools deferred everywhere |
| `auto` | Threshold mode: load upfront if within 10% of context window |
| `auto:<N>` | Threshold mode with custom percentage (0–100) |
| `false` | All tools loaded upfront, no deferral |

Requires Sonnet 4+ or Opus 4+. Haiku models do not support tool search.

**Exempt a server from deferral:**

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

`alwaysLoad: true` requires v2.1.121+. Individual tools can also use `"anthropic/alwaysLoad": true` in their `_meta`.

**Disable `ToolSearch` tool specifically:**

```json
{
  "permissions": {
    "deny": ["ToolSearch"]
  }
}
```

### MCP Output Limits

| Setting | Default | Override |
| :--- | :--- | :--- |
| Warning threshold | 10,000 tokens | `MAX_MCP_OUTPUT_TOKENS` |
| Default max | 25,000 tokens | `MAX_MCP_OUTPUT_TOKENS` |
| Per-tool max | — | `_meta["anthropic/maxResultSizeChars"]` in `tools/list` (max 500,000 chars) |

The `anthropic/maxResultSizeChars` annotation applies to text content only; image data still uses `MAX_MCP_OUTPUT_TOKENS`.

### MCP Resources

Reference MCP resources using `@` mentions:

```text
@server:protocol://resource/path

# Examples
@github:issue://123
@postgres:schema://users
@docs:file://api/authentication
```

Resources appear in autocomplete alongside files and are fetched as attachments automatically.

### MCP Prompts as Commands

MCP prompts appear as slash commands in the format `/mcp__servername__promptname`:

```text
/mcp__github__list_prs
/mcp__github__pr_review 456
/mcp__jira__create_issue "Bug in login flow" high
```

### Elicitation

MCP servers can request structured input mid-task:

- **Form mode**: Claude Code shows a dialog with server-defined fields
- **URL mode**: Browser URL for auth/approval flows

Auto-respond without dialog: use the [`Elicitation` hook](/en/hooks#elicitation).

### Plugin-Provided MCP Servers

Plugins bundle MCP servers in `.mcp.json` at plugin root or inline in `plugin.json`. They start automatically when the plugin is enabled; run `/reload-plugins` to connect/disconnect during a session.

Plugin env vars: `${CLAUDE_PLUGIN_ROOT}` (bundled files), `${CLAUDE_PLUGIN_DATA}` (persistent state).

### Claude Code as an MCP Server

```bash
claude mcp serve   # Start Claude Code as a stdio MCP server
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

Use `which claude` to find the full path. Without it you'll see `spawn claude ENOENT`.

### Managed MCP Configuration (Enterprise)

**Option 1: Exclusive control with `managed-mcp.json`**

Deploy to system-wide paths (requires admin privileges):

| OS | Path |
| :--- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux/WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

Uses same format as `.mcp.json`. Users cannot add/modify servers when this file exists.

**Option 2: Policy-based with allowlists/denylists** (in managed settings):

```json
{
  "allowedMcpServers": [
    { "serverName": "github" },
    { "serverCommand": ["npx", "-y", "approved-package"] },
    { "serverUrl": "https://mcp.company.com/*" }
  ],
  "deniedMcpServers": [
    { "serverName": "dangerous-server" },
    { "serverUrl": "https://*.untrusted.com/*" }
  ]
}
```

Each entry uses exactly one of: `serverName`, `serverCommand` (exact array match), or `serverUrl` (wildcard `*` support).

| Setting | `undefined` | `[]` | List |
| :--- | :--- | :--- | :--- |
| `allowedMcpServers` | No restrictions | Complete lockdown | Only matching servers allowed |
| `deniedMcpServers` | Nothing blocked | Nothing blocked | Listed servers blocked |

Denylist takes absolute precedence over allowlist. Options 1 and 2 can be combined.

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — installing servers, scopes, authentication, JSON config, Claude Desktop import, claude.ai connectors, plugin MCP servers, tool search, resources, prompts, output limits, elicitation, and managed configuration

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
