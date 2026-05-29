---
name: mcp-doc
user-invocable: false
---

# MCP (Model Context Protocol) Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools via MCP, and for administrator control over which MCP servers are permitted in an organization.

## Quick Reference

### What MCP Enables

Connect Claude Code to external tools so it can act on them directly instead of requiring you to paste data into chat:

- Implement features from issue trackers (JIRA, GitHub)
- Analyze monitoring data (Sentry, Statsig)
- Query databases (PostgreSQL, etc.)
- Integrate designs (Figma, Slack)
- Automate workflows (Gmail drafts, etc.)
- React to external events via MCP channel servers

Browse reviewed connectors at the [Anthropic Directory](https://claude.ai/directory).

---

### Installing MCP Servers

#### Transport Types

| Transport | Command | Use for |
|:----------|:--------|:--------|
| HTTP (recommended) | `claude mcp add --transport http <name> <url>` | Remote/cloud services |
| SSE (deprecated) | `claude mcp add --transport sse <name> <url>` | Legacy remote servers |
| stdio | `claude mcp add [options] <name> -- <command> [args...]` | Local processes, scripts |

In JSON configs, `streamable-http` is an alias for `http` (MCP spec name).

#### HTTP Example with Auth Header

```bash
claude mcp add --transport http github https://api.githubcopilot.com/mcp/ \
  --header "Authorization: Bearer YOUR_GITHUB_PAT"
```

#### stdio Example with Env Var

```bash
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server
```

**Important**: All options (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. `--` separates the server name from the command passed to the MCP server.

#### stdio Servers and `CLAUDE_PROJECT_DIR`

Claude Code sets `CLAUDE_PROJECT_DIR` in the spawned server's environment to the project root. Reference it inside your server process (e.g., `process.env.CLAUDE_PROJECT_DIR` in Node, `os.environ["CLAUDE_PROJECT_DIR"]` in Python). In `.mcp.json` `command`/`args`, use `${CLAUDE_PROJECT_DIR:-.}` as a default.

---

### Managing Servers

```bash
claude mcp list               # list all configured servers
claude mcp get <name>         # details for a specific server
claude mcp remove <name>      # remove a server
claude mcp add-json <name> '<json>'       # add from JSON config
claude mcp add-from-claude-desktop        # import from Claude Desktop (macOS/WSL)
claude mcp reset-project-choices          # reset .mcp.json approval choices
```

Within Claude Code: `/mcp` — view server status and tool counts, authenticate OAuth servers.

#### Server Status Indicators

| Status | Meaning |
|:-------|:--------|
| `⏸ Pending approval` | Project-scoped server awaiting your approval |
| `✗ Rejected` | Server was rejected |
| Tool count shown | Server connected; flag if no tools advertised |

The server name `workspace` is reserved — rename any server using it.

---

### Scopes

| Scope | Flag | Loads in | Shared | Stored in |
|:------|:-----|:---------|:-------|:----------|
| Local (default) | `--scope local` | Current project only | No | `~/.claude.json` |
| Project | `--scope project` | Current project only | Yes, via version control | `.mcp.json` in project root |
| User | `--scope user` | All your projects | No | `~/.claude.json` |

#### Scope Hierarchy (highest to lowest precedence)

1. Local scope
2. Project scope
3. User scope
4. Plugin-provided servers
5. claude.ai connectors

Same name = duplicate; same URL/command for plugins and connectors = duplicate. Entire definition from highest-precedence source wins; fields are not merged.

---

### `.mcp.json` Environment Variable Expansion

| Syntax | Behavior |
|:-------|:---------|
| `${VAR}` | Expands to value of `VAR` |
| `${VAR:-default}` | Expands to `VAR` if set, otherwise `default` |

Expansion works in: `command`, `args`, `env`, `url`, `headers`. Missing required variables with no default cause a parse failure.

---

### OAuth Authentication

Remote servers requiring auth are flagged when they return `401` or `403`. Use `/mcp` to complete the OAuth flow in your browser.

#### OAuth CLI Flags

| Flag | Purpose |
|:-----|:--------|
| `--callback-port <port>` | Fix OAuth callback port to match a pre-registered redirect URI |
| `--client-id <id>` | Pre-configured OAuth client ID |
| `--client-secret` | Prompt for client secret (masked); or set via `MCP_CLIENT_SECRET` env var |

#### OAuth Config Fields (in `.mcp.json`)

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
        "scopes": "channels:read chat:write search:read"
      }
    }
  }
}
```

- `authServerMetadataUrl` — override OAuth discovery (requires v2.1.64+); must use `https://`
- `scopes` — pin requested scopes (space-separated RFC 6749 format); takes precedence over server-advertised scopes

#### Dynamic Headers for Custom Auth

Use `headersHelper` to generate headers at connection time (runs each connection, 10-second timeout):

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

Helper must write a JSON object of string key-value pairs to stdout. Available env vars: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`.

---

### Reconnection and Reliability

- HTTP/SSE servers: auto-reconnect with exponential backoff — up to 5 attempts, starting 1 second, doubling each time
- Initial connection: up to 3 retries on transient errors (5xx, connection refused, timeout); auth/not-found errors not retried
- Stdio servers: not automatically reconnected (local processes)
- Dynamic tool updates: servers can send `list_changed` notifications; Claude Code refreshes tools without disconnect

---

### MCP Output Limits

| Setting | Default | Configure via |
|:--------|:--------|:--------------|
| Warning threshold | 10,000 tokens | Display only |
| Default max | 25,000 tokens | `MAX_MCP_OUTPUT_TOKENS` env var |
| Per-tool max | Up to 500,000 chars | `_meta["anthropic/maxResultSizeChars"]` in `tools/list` response |

`MAX_MCP_OUTPUT_TOKENS` applies to tools that don't declare their own limit. Image data is always subject to the token limit regardless of per-tool annotation.

---

### Tool Search (MCP Tool Deferral)

Enabled by default. Tool names load at session start; schemas load on demand via a `ToolSearch` call. Only tools actually used enter context.

| `ENABLE_TOOL_SEARCH` | Behavior |
|:---------------------|:---------|
| (unset) | All MCP tools deferred; falls back to upfront on Vertex AI or non-first-party `ANTHROPIC_BASE_URL` |
| `true` | Force deferral everywhere, including Vertex AI |
| `auto` | Load upfront if tools fit within 10% of context window; defer overflow |
| `auto:N` | Threshold mode with custom percentage (0–100) |
| `false` | All tools loaded upfront |

Requires Sonnet 4+ or Opus 4+ (Vertex AI: Sonnet 4.5+ or Opus 4.5+). Haiku does not support tool search.

**Exempt a server from deferral** — set `alwaysLoad: true` in its config (requires v2.1.121+). Also blocks startup until that server connects.

**Per-tool always-load** — set `"anthropic/alwaysLoad": true` in the tool's `_meta` object.

**Disable `ToolSearch` tool** via permissions:

```json
{ "permissions": { "deny": ["ToolSearch"] } }
```

---

### MCP Prompts as Commands

MCP servers can expose prompts available as `/mcp__servername__promptname` commands in Claude Code. Pass arguments space-separated: `/mcp__github__pr_review 456`.

---

### MCP Resources via @ Mentions

Reference MCP resources with `@server:protocol://resource/path`, e.g.:

```
Can you analyze @github:issue://123 and suggest a fix?
```

Type `@` to browse available resources in autocomplete alongside files.

---

### MCP Elicitation

MCP servers can request structured input mid-task. Claude Code shows a dialog automatically — no configuration needed:

- **Form mode**: fills fields defined by the server
- **URL mode**: opens a browser URL for authentication/approval

To auto-respond without a dialog, use the `Elicitation` hook.

---

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers via `.mcp.json` at plugin root or inline in `plugin.json`. When a plugin is enabled, its servers start automatically. Run `/reload-plugins` to connect/disconnect servers after enabling/disabling a plugin during a session.

**Plugin MCP env vars:**

| Variable | Resolves to |
|:---------|:------------|
| `${CLAUDE_PLUGIN_ROOT}` | Bundled plugin files |
| `${CLAUDE_PLUGIN_DATA}` | Persistent plugin state |
| `${CLAUDE_PROJECT_DIR}` | Project root |

---

### Use Claude Code as an MCP Server

```bash
claude mcp serve
```

Add to Claude Desktop's `claude_desktop_config.json`:

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

Use `which claude` to find the full path. The server exposes Claude's tools (View, Edit, LS, etc.) to the MCP client.

---

### Claude.ai Connectors in Claude Code

MCP servers added in claude.ai are available automatically when authenticated via a Claude.ai subscription. They are **not** loaded when `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, `apiKeyHelper`, or a third-party provider (Bedrock/Vertex) is active.

Disable with: `ENABLE_CLAUDEAI_MCP_SERVERS=false claude`

---

## Managed MCP Configuration (Admin)

### Control Patterns

| Pattern | What it does | Configure |
|:--------|:-------------|:----------|
| **Disable MCP** | No servers load anywhere | `managed-mcp.json` with empty server map |
| **Fixed deployment** | Every user gets same servers, can't add others | `managed-mcp.json` with desired servers |
| **Approved catalog** | Publish approved list; user adds what they want | `allowedMcpServers` + `allowManagedMcpServersOnly: true` |
| **Plugin servers only** | Servers from plugins only | `strictPluginOnlyCustomization` with `mcp` |
| **Soft allowlist** | Allowlist users can broaden | `allowedMcpServers` without `allowManagedMcpServersOnly` |
| **Denylist only** | Block known-bad servers | `deniedMcpServers` |
| **No restrictions** | Users add anything | Don't deploy managed MCP config |

### `managed-mcp.json` File Paths

| Platform | Path |
|:---------|:-----|
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux / WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

When present, only the servers it defines load. Users cannot add/modify/remove others. Claude.ai connectors are suppressed unless `allowAllClaudeAiMcps: true` is set in a managed settings source (v2.1.149+).

**Validate the config is in effect:**

1. `claude mcp list` shows only `managed-mcp.json` servers
2. `claude mcp add --transport http test https://example.com/mcp` should fail with the enterprise-policy error

**Disable MCP entirely** — deploy `managed-mcp.json` with `{ "mcpServers": {} }`.

---

### Allowlists and Denylists

`allowedMcpServers` and `deniedMcpServers` are lists of entries matching by:

| Key | Matches | Wildcard |
|:----|:--------|:---------|
| `serverUrl` | Remote server URL | `*` wildcards supported anywhere |
| `serverCommand` | Exact command + all args | None — must match exactly |
| `serverName` | User-assigned label | None — exact match only |

**Empty vs. unset:**

| Setting | Unset | `[]` | Populated |
|:--------|:------|:-----|:----------|
| `allowedMcpServers` | All allowed | None allowed | Only matching allowed |
| `deniedMcpServers` | None blocked | None blocked | Matching blocked |

**Evaluation order:**
1. Merge lists from all settings sources (unless `allowManagedMcpServersOnly: true`)
2. Check denylist — match = blocked, no override
3. Check allowlist — remote servers must match `serverUrl`; stdio must match `serverCommand`; `serverName` only counts when no stricter entries of the same transport type exist

**URL pattern examples:**

| Pattern | Allows |
|:--------|:-------|
| `https://mcp.example.com/*` | All paths on that domain |
| `https://mcp.example.com` | Same — no path matches any path |
| `https://*.example.com/*` | Any subdomain |
| `http://localhost:*/*` | Any port on localhost |
| `*://mcp.example.com/*` | Any scheme to that domain |

**`allowManagedMcpServersOnly: true`** — locks allowlist to managed settings sources only; user/project/local allowlists are ignored; denylists still merge from all sources.

---

### Configuration Summary

| Surface | Controls | Delivered via |
|:--------|:---------|:--------------|
| `managed-mcp.json` | Fixed server set, exclusive control | MDM, GPO, fleet management, admin-privileged write |
| `allowedMcpServers` | Allowlist | Any settings file; for enforcement use managed settings source |
| `deniedMcpServers` | Denylist | Any settings file; merges from all sources always |
| `allowManagedMcpServersOnly` | Locks allowlist to managed sources | Managed settings sources only |
| `allowAllClaudeAiMcps` | Loads claude.ai connectors alongside managed set | Managed settings sources only |

### User-Facing Error Messages

| Restriction | What the user sees |
|:------------|:------------------|
| `managed-mcp.json` present | `Cannot add MCP server: enterprise MCP configuration is active and has exclusive control over MCP servers` |
| Server on denylist | `Cannot add MCP server "<name>": server is explicitly blocked by enterprise policy` |
| Server not on allowlist | `Cannot add MCP server "<name>": not allowed by enterprise policy` |
| Previously configured server now blocked | Server silently disappears from `/mcp` and `claude mcp list` |

---

### Monitoring MCP Usage

Set `OTEL_LOG_TOOL_DETAILS=1` with OpenTelemetry export configured to record MCP server and tool names in tool events. See the Monitoring docs for exporter setup and full event schema.

---

## Environment Variables Quick Reference

| Variable | Effect |
|:---------|:-------|
| `MCP_TIMEOUT` | Server startup timeout in ms (e.g., `MCP_TIMEOUT=10000`) |
| `MCP_TOOL_TIMEOUT` | Per-server tool execution timeout in ms; overridden by per-server `timeout` field |
| `MAX_MCP_OUTPUT_TOKENS` | Max output tokens for MCP tools (default 25,000) |
| `ENABLE_TOOL_SEARCH` | `true`/`false`/`auto`/`auto:N` — control tool search/deferral |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set `false` to disable claude.ai connectors |
| `MCP_CLIENT_SECRET` | OAuth client secret for non-interactive use |
| `OTEL_LOG_TOOL_DETAILS` | Set `1` to include MCP server/tool names in telemetry |

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — Installing servers (HTTP/SSE/stdio), managing servers, scopes, env var expansion, OAuth auth, dynamic headers, output limits, tool search, elicitation, resources, prompts, plugin MCP servers, using Claude Code as an MCP server, and channels
- [Control MCP server access for your organization](references/claude-code-managed-mcp.md) — Managed MCP patterns, `managed-mcp.json`, allowlists, denylists, evaluation logic, user-facing error messages, and monitoring MCP usage

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
- Control MCP server access for your organization: https://code.claude.com/docs/en/managed-mcp.md
