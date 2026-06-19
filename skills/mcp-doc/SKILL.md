---
name: mcp-doc
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools and data sources via the Model Context Protocol (MCP), managing MCP server access for organizations, and a quickstart walkthrough for first-time setup.

## Quick Reference

### Transport Types

| Transport | CLI flag | Use for |
| :--- | :--- | :--- |
| `http` (aka `streamable-http` in JSON) | `--transport http` | Cloud/hosted services; supports OAuth |
| `sse` | `--transport sse` | **Deprecated** — use HTTP instead |
| `stdio` | default / omitted | Local processes; direct system access |
| `ws` | JSON only (`type: "ws"`) | Persistent push events from remote server |

### Core CLI Commands

```bash
# Add servers
claude mcp add --transport http <name> <url>
claude mcp add --transport http <name> <url> --header "Authorization: Bearer <token>"
claude mcp add [--transport stdio] <name> -- <command> [args...]
claude mcp add-json <name> '<json>'
claude mcp add-from-claude-desktop        # macOS and WSL only

# Manage servers
claude mcp list
claude mcp get <name>
claude mcp remove <name>
claude mcp reset-project-choices          # reset .mcp.json approval choices

# Scope flags
--scope local    # default: you only, current project (stored in ~/.claude.json)
--scope project  # shared via .mcp.json in project root
--scope user     # you only, all projects (stored in ~/.claude.json)
```

### Installation Scopes

| Scope | Loads in | Shared with team | Stored in |
| :--- | :--- | :--- | :--- |
| `local` (default) | Current project only | No | `~/.claude.json` (per-project entry) |
| `project` | Current project only | Yes, via `.mcp.json` in VCS | `.mcp.json` in project root |
| `user` | All projects | No | `~/.claude.json` (top-level `mcpServers`) |

Precedence (highest first): local > project > user > plugin-provided > claude.ai connectors

### .mcp.json Format

```json
{
  "mcpServers": {
    "my-http-server": {
      "type": "http",
      "url": "https://mcp.example.com/mcp",
      "headers": { "Authorization": "Bearer ${API_KEY}" }
    },
    "my-stdio-server": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "some-mcp-package"],
      "env": { "KEY": "${VAR:-default}" }
    }
  }
}
```

Environment variable expansion in `.mcp.json`: `${VAR}` and `${VAR:-default}` work in `command`, `args`, `env`, `url`, and `headers`.

### OAuth Authentication

Run `/mcp` inside a session, select the server, and choose **Authenticate** to complete the browser sign-in flow.

| Flag | Purpose |
| :--- | :--- |
| `--callback-port <port>` | Fix the OAuth redirect port for pre-registered redirect URIs |
| `--client-id <id>` | Pre-configured OAuth client ID |
| `--client-secret` | Prompts for client secret (masked); set `MCP_CLIENT_SECRET` env var for CI |

OAuth tokens are stored in the system keychain and refreshed automatically. To revoke: choose "Clear authentication" in `/mcp`.

Advanced OAuth fields in `.mcp.json` (inside an `oauth` object):

| Field | Description |
| :--- | :--- |
| `authServerMetadataUrl` | Override OAuth metadata discovery URL (requires `https://`) |
| `scopes` | Space-separated scope string to pin; overrides server-advertised scopes |
| `clientId` | Pre-configured client ID |
| `callbackPort` | Fixed callback port |

### Dynamic Headers (`headersHelper`)

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

The helper command must write a JSON object of string key-value pairs to stdout. It runs in a shell with a 10-second timeout on each connection. Available env vars: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`.

### Key Environment Variables

| Variable | Default | Description |
| :--- | :--- | :--- |
| `MCP_TIMEOUT` | 30000 ms | Server startup timeout |
| `MCP_TOOL_TIMEOUT` | ~28 hours | Per-tool-call wall-clock limit (per-server `timeout` field overrides this) |
| `MAX_MCP_OUTPUT_TOKENS` | 25000 tokens | Max tokens per MCP tool output; warning at 10,000 |
| `ENABLE_TOOL_SEARCH` | (unset) | Controls MCP tool deferral (see below) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | `true` | Set to `false` to suppress claude.ai connectors |

### Tool Search (MCP Context Scaling)

By default, MCP tools are deferred and loaded on demand rather than all upfront, keeping context usage low.

| `ENABLE_TOOL_SEARCH` value | Behavior |
| :--- | :--- |
| (unset) | All tools deferred; falls back to upfront on Vertex AI or non-first-party `ANTHROPIC_BASE_URL` |
| `true` | Always defer, even on Vertex AI / proxies |
| `auto` | Threshold mode: load upfront if tools fit within 10% of context window |
| `auto:N` | Threshold mode with custom N% (0–100) |
| `false` | All tools loaded upfront, no deferral |

To exempt one server from deferral, set `"alwaysLoad": true` in its `.mcp.json` entry. To exempt a single tool, include `"anthropic/alwaysLoad": true` in the tool's `_meta` object (set by the server author).

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers in `.mcp.json` at the plugin root or inline in `plugin.json`. Servers start automatically when the plugin is enabled; run `/reload-plugins` to connect/disconnect mid-session.

Plugin MCP tool names follow the pattern: `mcp__plugin_<plugin-name>_<server-name>__<tool-name>`

Plugin env var placeholders: `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`, `${CLAUDE_PROJECT_DIR}`

### MCP Resources and Prompts

- Reference resources in prompts: `@server:protocol://resource/path`
- MCP prompts appear as slash commands: `/mcp__servername__promptname [args...]`

### Using Claude Code as an MCP Server

```bash
claude mcp serve
```

Add to `claude_desktop_config.json` with `"type": "stdio"`, `"command": "claude"`, `"args": ["mcp", "serve"]`.

### MCP Output Limits

- Warning at 10,000 tokens; hard cap at 25,000 tokens (configurable via `MAX_MCP_OUTPUT_TOKENS`)
- Server authors can raise the per-tool threshold by setting `_meta["anthropic/maxResultSizeChars"]` (up to 500,000 chars) in the tool's `tools/list` response

### MCP Elicitation

MCP servers can request structured mid-task input via elicitation. Dialogs appear automatically — no user configuration needed. Auto-respond with the `Elicitation` hook. See the hooks-doc skill for the hook schema.

### Connection Status Indicators (`claude mcp list` / `/mcp`)

| Status | Meaning |
| :--- | :--- |
| `✓ Connected` | Ready |
| `! Connected · tools fetch failed` | Connected but tool listing failed — run `claude mcp get <name>` |
| `! Needs authentication` | OAuth sign-in required — use `/mcp` |
| `✗ Failed to connect` | Server didn't respond |
| `✗ Connection error` | Connection attempt threw an error |
| `⏸ Pending approval` | Project-scoped server awaiting approval |

HTTP/SSE servers reconnect automatically (exponential backoff, up to 5 attempts). Stdio servers are not auto-reconnected.

---

## Managed MCP (Org/Enterprise Control)

### Restriction Patterns

| Pattern | What it does | How to configure |
| :--- | :--- | :--- |
| Disable MCP | No servers load | `managed-mcp.json` with empty `mcpServers: {}` |
| Fixed deployment | Users get exactly these servers, can't add others | `managed-mcp.json` with server list |
| Approved catalog | Users add from approved list only | `allowedMcpServers` + `allowManagedMcpServersOnly: true` |
| Plugin servers only | Only plugin-provided servers allowed | `strictPluginOnlyCustomization` with `mcp` |
| Soft allowlist | Allowlist users can broaden in their own settings | `allowedMcpServers` without `allowManagedMcpServersOnly` |
| Denylist only | Block known-bad servers | `deniedMcpServers` |
| No restrictions | Default — users add anything | No managed config |

### `managed-mcp.json` Paths

| Platform | Path |
| :--- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux / WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

Uses the same format as `.mcp.json`. Credentials must NOT be stored here — use `${VAR}` expansion, OAuth, or `headersHelper`.

### Allowlist / Denylist Matching Keys

| Key | Matches | Notes |
| :--- | :--- | :--- |
| `serverUrl` | Remote server URL; supports `*` wildcards | HTTP and SSE servers |
| `serverCommand` | Exact command + args array | Stdio servers; must match exactly |
| `serverName` | User-assigned label | Exact match only; not a security control on its own |

`allowedMcpServers: []` (empty array) blocks all servers. `allowedMcpServers` unset allows all.

Denylist always wins over allowlist. When `allowManagedMcpServersOnly: true`, only the managed-tier allowlist applies (user/project allowlists are ignored; denylists still merge from all sources).

### What Users See When Blocked

| Situation | User sees |
| :--- | :--- |
| `managed-mcp.json` present; user runs `claude mcp add` | `Cannot add MCP server: enterprise MCP configuration is active and has exclusive control over MCP servers` |
| Server on denylist; user runs `claude mcp add` | `Cannot add MCP server "<name>": server is explicitly blocked by enterprise policy` |
| Server not on allowlist; user runs `claude mcp add` | `Cannot add MCP server "<name>": not allowed by enterprise policy` |
| Previously configured server now blocked by policy | Server silently disappears from `/mcp` with no warning |

To allow claude.ai connectors alongside `managed-mcp.json`, set `"allowAllClaudeAiMcps": true` in a managed settings source (requires v2.1.149+).

### Monitoring MCP Usage

Set `OTEL_LOG_TOOL_DETAILS=1` with OpenTelemetry export configured to record which MCP servers and tools users invoke.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — Full MCP reference: transports, scopes, OAuth, tool search, plugin servers, resources, prompts, output limits, elicitation
- [Control MCP server access for your organization](references/claude-code-managed-mcp.md) — Managed MCP: exclusive control, allowlists/denylists, enterprise patterns, monitoring
- [Connect to MCP servers (quickstart)](references/claude-code-mcp-quickstart.md) — Step-by-step walkthrough: add a server, check status, troubleshoot common errors

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
- Control MCP server access for your organization: https://code.claude.com/docs/en/managed-mcp.md
- Connect to MCP servers (quickstart): https://code.claude.com/docs/en/mcp-quickstart.md
