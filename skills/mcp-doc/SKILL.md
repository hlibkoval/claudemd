---
name: mcp-doc
description: Complete official documentation for connecting Claude Code to external tools via the Model Context Protocol (MCP) — adding servers, transport types, scopes, authentication, OAuth, managed configuration, tool search, MCP resources, prompts, and output limits.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools and services via the Model Context Protocol (MCP).

## Quick Reference

### Adding MCP servers

**HTTP server (recommended for remote services):**
```bash
claude mcp add --transport http <name> <url>
claude mcp add --transport http notion https://mcp.notion.com/mcp
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

In JSON configs (`type` field), `streamable-http` is accepted as an alias for `http`.

**SSE server (deprecated — prefer HTTP):**
```bash
claude mcp add --transport sse <name> <url>
```

**Stdio server (local processes):**
```bash
claude mcp add --transport stdio --env KEY=value <name> -- <command> [args...]
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server
```

All options (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. `--` separates the server name from the command.

`CLAUDE_PROJECT_DIR` is set in the spawned server's environment to the project root.

### Managing servers

| Command | Description |
| :--- | :--- |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Get details for a specific server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp add-json <name> '<json>'` | Add server from a JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS/WSL) |
| `claude mcp reset-project-choices` | Reset approval prompts for project-scoped servers |
| `/mcp` | Show server status, tool counts, and authenticate with OAuth servers |

The name `workspace` is reserved — Claude Code skips servers with that name and warns you to rename them.

**Dynamic tool updates**: Claude Code supports MCP `list_changed` notifications — servers can update available tools/prompts/resources without reconnecting.

**Automatic reconnection (HTTP/SSE)**: up to 5 attempts with exponential backoff starting at 1 second. After 5 failures the server is marked failed. Stdio servers are not reconnected automatically.

### Installation scopes

| Scope | Loads in | Shared with team | Stored in |
| :--- | :--- | :--- | :--- |
| `local` (default) | Current project only | No | `~/.claude.json` |
| `project` | Current project only | Yes, via version control | `.mcp.json` in project root |
| `user` | All your projects | No | `~/.claude.json` |

```bash
claude mcp add --transport http stripe --scope local https://mcp.stripe.com
claude mcp add --transport http paypal --scope project https://mcp.paypal.com/mcp
claude mcp add --transport http hubspot --scope user https://mcp.hubspot.com/anthropic
```

Project-scoped servers require approval before use. Plugin-provided and claude.ai connector servers are lower precedence.

**Scope precedence (highest to lowest):** local → project → user → plugin-provided → claude.ai connectors

### Environment variable expansion in `.mcp.json`

| Syntax | Behavior |
| :--- | :--- |
| `${VAR}` | Expands to value of `VAR` |
| `${VAR:-default}` | Expands to `VAR` if set, else `default` |

Expansion is supported in `command`, `args`, `env`, `url`, and `headers`.

### Plugin-provided MCP servers

Plugins bundle MCP servers in `.mcp.json` at the plugin root or inline in `plugin.json`. Available environment variables in plugin configs:

| Variable | Value |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Persistent data directory (survives updates) |
| `${CLAUDE_PROJECT_DIR}` | Stable project root |

Run `/reload-plugins` to connect/disconnect plugin MCP servers if a plugin is enabled/disabled mid-session.

### OAuth 2.0 authentication

```bash
# Add server then authenticate via /mcp
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
# Then in Claude Code:
/mcp
```

**Fixed callback port (for pre-registered redirect URIs):**
```bash
claude mcp add --transport http --callback-port 8080 my-server https://mcp.example.com/mcp
```

**Pre-configured OAuth credentials:**
```bash
claude mcp add --transport http \
  --client-id your-client-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

Set `MCP_CLIENT_SECRET=your-secret` env var to avoid the interactive prompt.

**Override OAuth metadata discovery** (`authServerMetadataUrl` in the `oauth` object; requires v2.1.64+):
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

**Restrict OAuth scopes** (`oauth.scopes` — space-separated string, RFC 6749 §3.3):
```json
"oauth": { "scopes": "channels:read chat:write search:read" }
```

### Dynamic headers (`headersHelper`)

Run a shell command on each connection to generate auth headers:
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

Requirements: command writes a JSON object of `string: string` pairs to stdout; runs in a shell with 10-second timeout; dynamic headers override static `headers` with the same name.

Helper env vars: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`.

### MCP Tool Search

Defers tool definitions so only names load at session start — minimizes context usage.

| `ENABLE_TOOL_SEARCH` value | Behavior |
| :--- | :--- |
| (unset) | All tools deferred; falls back to upfront on Vertex AI or non-first-party `ANTHROPIC_BASE_URL` |
| `true` | All tools deferred; forces beta header (fails if backend doesn't support it) |
| `auto` | Threshold mode: load upfront if tools fit within 10% of context window |
| `auto:<N>` | Threshold mode with custom percentage (0–100) |
| `false` | All tools loaded upfront, no deferral |

Requires models supporting `tool_reference` blocks: Sonnet 4+, Opus 4+. Haiku not supported.

**Exempt a server from deferral** (`alwaysLoad: true`; requires v2.1.121+):
```json
{
  "mcpServers": {
    "core-tools": { "type": "http", "url": "https://mcp.example.com/mcp", "alwaysLoad": true }
  }
}
```

Individual tools can also be always-loaded via `"anthropic/alwaysLoad": true` in the tool's `_meta` object.

**Disable ToolSearch tool entirely:**
```json
{ "permissions": { "deny": ["ToolSearch"] } }
```

### MCP output limits

| Setting | Default | Description |
| :--- | :--- | :--- |
| Warning threshold | 10,000 tokens | Shows warning when exceeded |
| Max output (`MAX_MCP_OUTPUT_TOKENS`) | 25,000 tokens | Applies to tools without own limit |
| Per-tool limit (`anthropic/maxResultSizeChars`) | (not set) | Hard ceiling 500,000 chars; text only |

```bash
export MAX_MCP_OUTPUT_TOKENS=50000
claude
```

Per-tool annotation in `tools/list` response:
```json
{ "name": "get_schema", "_meta": { "anthropic/maxResultSizeChars": 200000 } }
```

### MCP elicitation

Servers can request structured input mid-task. No configuration needed — dialogs appear automatically.

| Mode | Behavior |
| :--- | :--- |
| Form mode | Dialog with server-defined fields |
| URL mode | Opens browser for OAuth/approval flow |

To auto-respond without a dialog, use the `Elicitation` hook.

### MCP resources (@ mentions)

Reference server-exposed resources with `@server:protocol://resource/path`:
```
Can you analyze @github:issue://123 and suggest a fix?
Compare @postgres:schema://users with @docs:file://database/user-model
```

Type `@` in the prompt to see available resources in autocomplete. Resources are fuzzy-searchable.

### MCP prompts as slash commands

MCP prompts appear as `/mcp__servername__promptname`:
```
/mcp__github__list_prs
/mcp__github__pr_review 456
/mcp__jira__create_issue "Bug in login flow" high
```

### Push messages with channels

An MCP server can push messages into your session by declaring the `claude/channel` capability. Opt in with `--channels` at startup. See the Channels documentation for details.

### Use Claude Code as an MCP server

```bash
claude mcp serve
```

Configure in Claude Desktop (`claude_desktop_config.json`):
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

Use `which claude` to find the full executable path if `claude` is not on PATH.

### Use MCP servers from Claude.ai

Servers added at claude.ai/customize/connectors are automatically available in Claude Code when logged in with a Claude.ai account. A locally configured server takes precedence over a claude.ai connector pointing at the same URL.

Disable claude.ai MCP servers:
```bash
ENABLE_CLAUDEAI_MCP_SERVERS=false claude
```

### Managed MCP configuration (enterprise)

**Option 1 — Exclusive control (`managed-mcp.json`):**

Deploy path:
- macOS: `/Library/Application Support/ClaudeCode/managed-mcp.json`
- Linux/WSL: `/etc/claude-code/managed-mcp.json`
- Windows: `C:\Program Files\ClaudeCode\managed-mcp.json`

Uses same format as `.mcp.json`. When present, users cannot add/modify servers via `claude mcp add`.

**Option 2 — Policy-based control (allowlists/denylists in managed settings):**

Each entry uses exactly one of:

| Field | Matches |
| :--- | :--- |
| `serverName` | Configured server name |
| `serverCommand` | Exact command array (all args must match) |
| `serverUrl` | URL with `*` wildcard support |

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

`allowedMcpServers: []` = complete lockdown. Denylist takes absolute precedence. URL hostname matching is case-insensitive; paths are case-sensitive.

### Useful environment variables

| Variable | Effect |
| :--- | :--- |
| `MCP_TIMEOUT` | MCP server startup timeout in ms (e.g., `MCP_TIMEOUT=10000`) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens from any MCP tool output |
| `ENABLE_TOOL_SEARCH` | Control tool search deferral behavior |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set to `false` to disable claude.ai MCP servers |
| `MCP_CONNECTION_NONBLOCKING` | Set to `1` to connect non-blocking (except `alwaysLoad` servers) |
| `MCP_CLIENT_SECRET` | OAuth client secret (avoids interactive prompt) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — installing servers, transport types, scopes, authentication, OAuth, managed configuration, tool search, resources, prompts, output limits, and elicitation

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
