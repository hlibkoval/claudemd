---
name: mcp-doc
user-invocable: false
---

# MCP (Model Context Protocol) Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools via MCP, and for managing MCP server access in organizations.

## Quick Reference

### What MCP Does

MCP lets Claude Code connect to external tools, databases, and APIs. Use it when you find yourself copying data from another tool into chat — once connected, Claude reads and acts on that system directly.

### Transport Types

| Transport | `type` value | `claude mcp add` flag | Best for |
|:----------|:-------------|:----------------------|:---------|
| HTTP (recommended) | `http` or `streamable-http` | `--transport http` | Cloud services with OAuth |
| SSE (deprecated) | `sse` | `--transport sse` | Legacy remote servers |
| Stdio | `stdio` | `--transport stdio` (default) | Local processes, scripts |
| WebSocket | `ws` | JSON config only (`claude mcp add-json`) | Event-pushing remote servers |

### Adding Servers

```bash
# HTTP server
claude mcp add --transport http <name> <url>

# HTTP with auth header
claude mcp add --transport http <name> <url> --header "Authorization: Bearer TOKEN"

# Stdio server
claude mcp add --transport stdio --env KEY=value <name> -- <command> [args...]

# From JSON
claude mcp add-json <name> '{"type":"http","url":"https://..."}'

# Import from Claude Desktop (macOS/WSL only)
claude mcp add-from-claude-desktop
```

All options (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. Use `--` to separate server name from the server command and its arguments.

### Scopes

| Scope | Default | Stored in | Shared with team |
|:------|:--------|:----------|:-----------------|
| `local` | Yes | `~/.claude.json` (per-project) | No |
| `project` | No | `.mcp.json` in project root | Yes (via version control) |
| `user` | No | `~/.claude.json` (global) | No |

Scope precedence (highest first): local → project → user → plugin-provided → claude.ai connectors

### Managing Servers

```bash
claude mcp list              # list all configured servers
claude mcp get <name>        # show details for one server
claude mcp remove <name>     # remove a server
claude mcp reset-project-choices  # reset .mcp.json approval decisions
/mcp                         # interactive panel (status, auth, tool counts)
```

Project-scoped servers from `.mcp.json` require approval before first use. `/mcp` shows pending approval status.

### Environment Variables for MCP

| Variable | Effect |
|:---------|:-------|
| `MCP_TIMEOUT` | Startup timeout in ms (e.g. `MCP_TIMEOUT=10000 claude`) |
| `MCP_TOOL_TIMEOUT` | Per-tool execution timeout in ms (overridden by per-server `timeout` field) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens per tool output (default 25,000; warning at 10,000) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set to `false` to disable claude.ai connector sync |
| `ENABLE_TOOL_SEARCH` | Controls MCP tool deferral (see Tool Search section) |

### `.mcp.json` Config Format

```json
{
  "mcpServers": {
    "my-server": {
      "type": "http",
      "url": "https://mcp.example.com/mcp",
      "headers": { "Authorization": "Bearer ${API_KEY}" },
      "timeout": 600000,
      "alwaysLoad": false
    }
  }
}
```

Environment variable expansion is supported in `command`, `args`, `env`, `url`, and `headers`:
- `${VAR}` — expands to value of `VAR`
- `${VAR:-default}` — expands to `VAR` if set, otherwise `default`

### OAuth Authentication

Claude Code supports OAuth 2.0 for remote servers. A server is flagged for auth when it returns `401` or `403`.

```bash
# Add server, then run /mcp to complete browser login
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
# /mcp  →  follow browser flow
```

Advanced OAuth options:

| Option | Flag / Field | Description |
|:-------|:-------------|:------------|
| Fixed callback port | `--callback-port <port>` | Match a pre-registered redirect URI |
| Pre-configured credentials | `--client-id <id> --client-secret` | For servers without Dynamic Client Registration |
| Override discovery URL | `oauth.authServerMetadataUrl` in config | Bypass default RFC 9728/8414 discovery chain |
| Restrict scopes | `oauth.scopes` in config | Space-separated scope string |

Tokens stored in system keychain (macOS) or credentials file. Clear via `/mcp` → "Clear authentication".

### Dynamic Headers (`headersHelper`)

Use when authentication isn't OAuth (e.g. Kerberos, short-lived tokens):

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

The command must output a JSON object of string key-value pairs to stdout. Runs fresh on each connection with a 10-second timeout. Environment variables `CLAUDE_CODE_MCP_SERVER_NAME` and `CLAUDE_CODE_MCP_SERVER_URL` are available.

### Tool Search (MCP Tool Deferral)

Tool search is enabled by default. Tool definitions load lazily — only names load at startup, reducing context usage.

| `ENABLE_TOOL_SEARCH` value | Behavior |
|:---------------------------|:---------|
| (unset) | All MCP tools deferred; falls back to upfront on Vertex AI / non-first-party `ANTHROPIC_BASE_URL` |
| `true` | Force deferral everywhere (fails on unsupported models/proxies) |
| `auto` | Threshold mode: load upfront if fits within 10% of context window |
| `auto:N` | Threshold mode with custom N% threshold |
| `false` | All tools loaded upfront |

Requires Sonnet 4+ or Opus 4+ (not Haiku). On Vertex AI: Sonnet 4.5+ or Opus 4.5+.

To exempt a specific server from deferral, set `"alwaysLoad": true` in its config entry. Individual tools can set `"anthropic/alwaysLoad": true` in their `_meta` object.

### MCP Output Limits

| Setting | Default | How to change |
|:--------|:--------|:--------------|
| Warning threshold | 10,000 tokens | Not configurable |
| Max output tokens | 25,000 tokens | `MAX_MCP_OUTPUT_TOKENS=<n>` env var |
| Per-tool override | — | Set `_meta["anthropic/maxResultSizeChars"]` in tool's `tools/list` response (max 500,000 chars) |

The `anthropic/maxResultSizeChars` annotation applies to text content only; image data is still subject to `MAX_MCP_OUTPUT_TOKENS`.

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers via `.mcp.json` at plugin root or inline in `plugin.json`. Plugin servers start automatically when the plugin is enabled. Run `/reload-plugins` to connect/disconnect after enabling/disabling a plugin mid-session.

Available environment variables for plugin MCP configs:
- `${CLAUDE_PLUGIN_ROOT}` — path to bundled plugin files
- `${CLAUDE_PLUGIN_DATA}` — persistent data directory (survives plugin updates)
- `${CLAUDE_PROJECT_DIR}` — stable project root

### Stdio Server: CLAUDE_PROJECT_DIR

Stdio servers receive `CLAUDE_PROJECT_DIR` in their environment pointing to the project root. Access it via `process.env.CLAUDE_PROJECT_DIR` (Node) or `os.environ["CLAUDE_PROJECT_DIR"]` (Python). In `.mcp.json` `command`/`args`, reference it as `${CLAUDE_PROJECT_DIR:-.}`.

### Use Claude Code as an MCP Server

```bash
claude mcp serve    # exposes Claude Code tools (View, Edit, LS, etc.) via stdio
```

Add to `claude_desktop_config.json`:
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

### MCP Resources

Reference MCP resources in prompts with `@server:protocol://resource/path`:

```
Can you analyze @github:issue://123 and suggest a fix?
Compare @postgres:schema://users with @docs:file://database/user-model
```

Type `@` to see all available resources in the autocomplete menu.

### MCP Prompts as Commands

MCP servers can expose prompts that appear as slash commands:

```
/mcp__github__list_prs
/mcp__github__pr_review 456
/mcp__jira__create_issue "Bug in login flow" high
```

Format: `/mcp__<servername>__<promptname>`. Server and prompt names are normalized (spaces become underscores).

### MCP Elicitation

Servers can request structured input mid-task. Claude Code shows an interactive dialog automatically — no configuration required. To auto-respond without a dialog, use the `Elicitation` hook.

---

## Managed MCP (Organization Control)

### Control Patterns

| Pattern | What it does | Configure |
|:--------|:-------------|:----------|
| Disable MCP | No servers load anywhere | `managed-mcp.json` with empty server map |
| Fixed deployment | Every user gets the same servers, can't add others | `managed-mcp.json` with server list |
| Approved catalog | Users add from an approved list; others blocked | `allowedMcpServers` + `allowManagedMcpServersOnly: true` |
| Plugin servers only | Servers from plugins only, users can't add their own | `strictPluginOnlyCustomization` with `mcp` |
| Soft allowlist | Enforce allowlist users can broaden in their own settings | `allowedMcpServers` without `allowManagedMcpServersOnly` |
| Denylist only | Block known-bad servers, allow everything else | `deniedMcpServers` |

### `managed-mcp.json` File Paths

| Platform | Path |
|:---------|:-----|
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux / WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

Same format as `.mcp.json`. Deploy via MDM (Jamf), Group Policy, Intune, or any process with administrator privileges. Cannot be delivered through server-managed settings.

When `managed-mcp.json` is present: users cannot add other servers, plugin-provided servers are suppressed, and claude.ai connectors are suppressed unless `allowAllClaudeAiMcps: true` is set in a managed settings source (requires v2.1.149+).

### Allowlist / Denylist Matching

| Key | Matches | Use for |
|:----|:--------|:--------|
| `serverUrl` | Remote server URL, exact or with `*` wildcards | HTTP and SSE servers |
| `serverCommand` | Exact command + arguments (every arg, in order) | Stdio servers |
| `serverName` | User-assigned label, exact match only | Either type (not a security control alone) |

URL wildcard examples:
- `https://mcp.example.com/*` — all paths on a domain
- `https://*.example.com/*` — any subdomain
- `http://localhost:*/*` — any port on localhost
- `*://mcp.example.com/*` — any scheme

Evaluation order: merge lists → denylist check → allowlist check. A denylist match always wins.

When `allowManagedMcpServersOnly: true`: only the managed allowlist applies; user/project/local allowlists are ignored. Denylists still merge from all sources.

### What Users See When Blocked

| Restriction | Message |
|:------------|:--------|
| `managed-mcp.json` present + `claude mcp add` | `Cannot add MCP server: enterprise MCP configuration is active and has exclusive control over MCP servers` |
| Server on denylist + `claude mcp add` | `Cannot add MCP server "<name>": server is explicitly blocked by enterprise policy` |
| Server not on allowlist + `claude mcp add` | `Cannot add MCP server "<name>": not allowed by enterprise policy` |
| Previously configured server now blocked | Server silently disappears from `/mcp` and `claude mcp list` |

### Configuration Summary

| Surface | Controls | Delivery |
|:--------|:---------|:---------|
| `managed-mcp.json` | Fixed server set, exclusive control | MDM/GPO/fleet management with admin privileges |
| `allowedMcpServers` | Allowlist of permitted servers | Managed settings source for enforcement |
| `deniedMcpServers` | Denylist of blocked servers | Any settings file; always merges |
| `allowManagedMcpServersOnly` | Locks allowlist to managed sources only | Managed settings sources only |
| `allowAllClaudeAiMcps` | Loads claude.ai connectors alongside `managed-mcp.json` | Managed settings sources only |

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — Transports, installation, scopes, OAuth, tool search, output limits, resources, prompts, and using Claude Code as an MCP server
- [Control MCP server access for your organization](references/claude-code-managed-mcp.md) — managed-mcp.json, allowlists, denylists, user-facing error messages, and monitoring MCP usage

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
- Control MCP server access for your organization: https://code.claude.com/docs/en/managed-mcp.md
