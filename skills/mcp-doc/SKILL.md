---
name: mcp-doc
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools and data sources via the Model Context Protocol (MCP).

## Quick Reference

### Transport Types

| Transport | CLI flag | When to use |
| :--- | :--- | :--- |
| **HTTP** (`streamable-http`) | `--transport http` | Recommended for cloud-based remote servers |
| **SSE** | `--transport sse` | Deprecated; use HTTP where available |
| **stdio** | `--transport stdio` (default) | Local processes needing direct system access |

### Installing Servers — Core CLI Commands

```bash
# HTTP server
claude mcp add --transport http <name> <url>
claude mcp add --transport http notion https://mcp.notion.com/mcp
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"

# SSE server (deprecated)
claude mcp add --transport sse asana https://mcp.asana.com/sse

# stdio server (options must come BEFORE the server name; -- separates server name from command)
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server

# Add from raw JSON
claude mcp add-json <name> '<json>'

# Import from Claude Desktop (macOS and WSL only)
claude mcp add-from-claude-desktop

# Manage
claude mcp list
claude mcp get <name>
claude mcp remove <name>
claude mcp reset-project-choices   # reset approval choices for project-scoped servers
/mcp                               # in-session: check status, auth, tool counts
```

### MCP Scopes

| Scope | Default? | Loads in | Shared with team | Stored in |
| :--- | :--- | :--- | :--- | :--- |
| **local** | Yes | Current project | No | `~/.claude.json` |
| **project** | No | Current project | Yes (via `.mcp.json`) | `.mcp.json` in project root |
| **user** | No | All projects | No | `~/.claude.json` |

Use `--scope local|project|user` on any `claude mcp add` command. Project scope creates/updates `.mcp.json` at project root (commit to source control). Claude Code prompts for approval before using project-scoped servers.

### Scope Hierarchy (highest to lowest precedence)

1. Local scope
2. Project scope
3. User scope
4. Plugin-provided servers
5. claude.ai connectors

Scopes 1–3 match by name. Plugins and connectors match by endpoint URL/command.

### Environment Variable Expansion in `.mcp.json`

| Syntax | Behavior |
| :--- | :--- |
| `${VAR}` | Expands to value of `VAR`; error if unset and no default |
| `${VAR:-default}` | Expands to `VAR` if set, else `default` |

Expansion applies in: `command`, `args`, `env`, `url`, `headers`.

### `.mcp.json` Schema

```json
{
  "mcpServers": {
    "my-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": { "Authorization": "Bearer ${API_KEY}" }
    },
    "local-server": {
      "command": "/path/to/server",
      "args": ["--flag"],
      "env": { "KEY": "value" }
    }
  }
}
```

The `type` field accepts `streamable-http` as an alias for `http` (MCP specification name).

### stdio: `CLAUDE_PROJECT_DIR`

Claude Code sets `CLAUDE_PROJECT_DIR` in the spawned stdio server's environment pointing to the project root. Read it with `process.env.CLAUDE_PROJECT_DIR` (Node) or `os.environ["CLAUDE_PROJECT_DIR"]` (Python). When referencing it in `.mcp.json` `command`/`args` via `${VAR}` expansion, use `${CLAUDE_PROJECT_DIR:-.}` as a default. Plugin-provided servers substitute it directly without needing a default.

### OAuth 2.0 Authentication

Triggered when a remote server returns `401` or `403`. Use `/mcp` to complete the browser flow.

| Scenario | How |
| :--- | :--- |
| Standard OAuth | `claude mcp add --transport http <name> <url>` then `/mcp` |
| Fixed callback port (pre-registered redirect URI) | Add `--callback-port <PORT>` |
| Pre-configured client ID + secret | Add `--client-id your-id --client-secret --callback-port PORT` |
| Pass secret via env (CI) | `MCP_CLIENT_SECRET=your-secret claude mcp add ...` |
| Override OAuth metadata discovery URL | Set `authServerMetadataUrl` in `oauth` object of `.mcp.json` (requires v2.1.64+) |
| Restrict OAuth scopes | Set `oauth.scopes` (space-separated string, RFC 6749 §3.3) in `.mcp.json` |

OAuth tokens are stored securely; use "Clear authentication" in `/mcp` to revoke. If the browser redirect fails, paste the callback URL from the browser's address bar into the CLI prompt.

Discovery order: RFC 9728 (`/.well-known/oauth-protected-resource`) → RFC 8414 (`/.well-known/oauth-authorization-server`). `authServerMetadataUrl` overrides this chain. If the server uses Client ID Metadata Document (CIMD), it is discovered automatically.

### Dynamic Headers (`headersHelper`)

For non-OAuth auth schemes (Kerberos, short-lived tokens, SSO). Set `headersHelper` to a shell command in the server's `.mcp.json` entry. The command must write a JSON object of string key-value pairs to stdout. Runs fresh on each connection (no caching). Timeout: 10 seconds.

Environment variables available to the helper:

| Variable | Value |
| :--- | :--- |
| `CLAUDE_CODE_MCP_SERVER_NAME` | Name of the MCP server |
| `CLAUDE_CODE_MCP_SERVER_URL` | URL of the MCP server |

Dynamic headers override static `headers` with the same name. Requires workspace trust when defined at project or local scope.

### MCP Output Limits

| Setting | Default | How to change |
| :--- | :--- | :--- |
| Warning threshold | 10,000 tokens | Display only; no config |
| Max output tokens | 25,000 tokens | `MAX_MCP_OUTPUT_TOKENS=<n> claude` |
| Per-tool text limit | Inherits `MAX_MCP_OUTPUT_TOKENS` | Set `_meta["anthropic/maxResultSizeChars"]` in `tools/list` (max 500,000 chars); no effect on image content |

Results that exceed the threshold are persisted to disk and replaced with a file reference in the conversation.

### Tool Search (`ENABLE_TOOL_SEARCH`)

Defers MCP tool definitions until Claude needs them, keeping context usage low. Enabled by default (disabled by default on Vertex AI and when `ANTHROPIC_BASE_URL` points to a non-first-party host).

Requires Sonnet 4+ or Opus 4+ (not Haiku). On Vertex AI: Sonnet 4.5+ or Opus 4.5+.

| Value | Behavior |
| :--- | :--- |
| (unset) | All MCP tools deferred on demand; falls back to upfront on Vertex AI / custom base URL |
| `true` | Force deferral even on Vertex AI / proxies (fails on unsupported models/proxies) |
| `auto` | Upfront if tools fit within 10% of context window, deferred otherwise |
| `auto:N` | Like `auto` but with N% threshold (0–100) |
| `false` | All MCP tools loaded upfront, no deferral |

To deny the `ToolSearch` tool specifically:

```json
{ "permissions": { "deny": ["ToolSearch"] } }
```

For MCP server authors: server instructions help Claude understand when to search for your tools (similar to skill descriptions). Tool descriptions and server instructions are truncated at 2KB each.

### `alwaysLoad` — Exempt a Server from Deferral

```json
{
  "mcpServers": {
    "core-tools": { "type": "http", "url": "https://mcp.example.com/mcp", "alwaysLoad": true }
  }
}
```

Every tool from that server loads into context at session start regardless of `ENABLE_TOOL_SEARCH`. Also blocks startup until the server connects (capped at 5-second timeout). Available on all server types; requires Claude Code v2.1.121+. Individual tools can be marked always-loaded with `"anthropic/alwaysLoad": true` in the tool's `_meta` object.

### MCP Resources — @ Mentions

Reference resources with `@server:protocol://resource/path` in prompts:

```
@github:issue://123
@docs:file://api/authentication
@postgres:schema://users
```

Type `@` in a prompt to see resource autocomplete alongside files. Resources are automatically fetched and included as attachments.

### MCP Prompts as Commands

MCP prompts become slash commands in the format `/mcp__servername__promptname`. Arguments are space-separated. Server and prompt names are normalized (spaces become underscores):

```
/mcp__github__list_prs
/mcp__github__pr_review 456
/mcp__jira__create_issue "Bug in login flow" high
```

### Using Claude Code as an MCP Server

```bash
claude mcp serve    # Start Claude as a stdio MCP server
```

Add to Claude Desktop `claude_desktop_config.json`:

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

Use `which claude` to find the full path (required if `claude` is not in PATH). The MCP client is responsible for user confirmation of individual tool calls.

### Managed MCP Configuration (Enterprise)

#### Option 1: `managed-mcp.json` — Exclusive Control

Deploy to a system-wide path (requires admin privileges). Users cannot add or modify servers when this file is present.

| OS | Path |
| :--- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux / WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

Uses the same `{ "mcpServers": { ... } }` format as `.mcp.json`.

#### Option 2: Allowlists / Denylists in Managed Settings

```json
{
  "allowedMcpServers": [
    { "serverName": "github" },
    { "serverCommand": ["npx", "-y", "@modelcontextprotocol/server-filesystem"] },
    { "serverUrl": "https://mcp.company.com/*" },
    { "serverUrl": "https://*.internal.corp/*" }
  ],
  "deniedMcpServers": [
    { "serverName": "dangerous-server" },
    { "serverUrl": "https://*.untrusted.com/*" }
  ]
}
```

Each entry must have exactly one of `serverName`, `serverCommand`, or `serverUrl`.

| Field | Behavior |
| :--- | :--- |
| `serverCommand` | Exact array match (command + all args in order) |
| `serverUrl` | Wildcard `*` matches any character sequence; hostname match is case-insensitive; paths are case-sensitive |
| Allowlist = `undefined` | No restrictions |
| Allowlist = `[]` | Complete lockdown — no MCP servers allowed |
| Denylist | Takes absolute precedence over allowlist |

When the allowlist contains any `serverCommand` entries, stdio servers must match one; name alone is insufficient. When it contains any `serverUrl` entries, remote servers must match one. Options 1 and 2 can be combined: `managed-mcp.json` has exclusive control, but allowlists/denylists still filter which managed servers are loaded.

### Plugin-Provided MCP Servers

Plugins can define MCP servers in `.mcp.json` at the plugin root or inline in `plugin.json`. They start automatically at session startup. Use `/reload-plugins` after enabling/disabling a plugin mid-session to connect/disconnect its servers.

Plugin-specific environment variables:

| Variable | Purpose |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Path to bundled plugin files |
| `${CLAUDE_PLUGIN_DATA}` | Persistent data directory (survives updates) |
| `${CLAUDE_PROJECT_DIR}` | Stable project root |

### Connection Management

| Feature | Details |
| :--- | :--- |
| **Dynamic tool updates** | `list_changed` notifications automatically refresh tools/prompts/resources without reconnect |
| **Automatic reconnection** (HTTP/SSE) | Up to 5 attempts with exponential backoff (starts at 1s, doubles each time); shown as pending in `/mcp`; stdio servers are not auto-reconnected |
| **Initial connection retry** (v2.1.121+) | Up to 3 retries on transient errors (5xx, refused, timeout); auth/not-found errors not retried |
| **Push messages (channels)** | Server declares `claude/channel` capability; opt in with `--channels` at startup; see Channels docs |
| **Reserved server name** | `workspace` is reserved; servers with this name are skipped with a warning |
| **Startup wait** | If a needed server is still connecting, Claude waits inside the `ToolSearch` call (or `WaitForMcpServers` when tool search is disabled) |

### Elicitation

MCP servers can request structured input mid-task. Two modes:
- **Form mode**: Claude Code shows a dialog with server-defined fields.
- **URL mode**: Claude Code opens a browser URL; confirm in CLI after completing the flow.

To auto-respond without a dialog, use the `Elicitation` hook. No client-side configuration required.

### claude.ai Connectors

Available only when authenticated via a Claude.ai subscription. Not loaded with `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, `apiKeyHelper`, or third-party providers (Bedrock/Vertex). Manage at `claude.ai/customize/connectors`. Check active auth method with `/status`. Disable with:

```bash
ENABLE_CLAUDEAI_MCP_SERVERS=false claude
```

A locally configured server takes precedence over a claude.ai connector pointing at the same URL.

### Useful Environment Variables

| Variable | Purpose |
| :--- | :--- |
| `MCP_TIMEOUT` | Server startup timeout in ms (e.g., `MCP_TIMEOUT=10000`) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens for MCP tool output (default 25,000) |
| `ENABLE_TOOL_SEARCH` | Control tool search behavior (`true`/`false`/`auto`/`auto:N`) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set `false` to disable claude.ai MCP connectors |
| `MCP_CLIENT_SECRET` | Pass OAuth client secret non-interactively in CI |

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — full MCP guide covering installation, scopes, OAuth, tool search, managed config, plugin servers, resources, prompts, channels, and more

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
