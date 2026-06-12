---
name: mcp-doc
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for the Model Context Protocol (MCP) in Claude Code — connecting servers, managing scopes, authentication, managed/enterprise controls, and the quickstart walkthrough.

## Quick Reference

### Installing MCP Servers

```bash
# Remote HTTP server (recommended for cloud services)
claude mcp add --transport http <name> <url>

# Remote HTTP with auth header
claude mcp add --transport http <name> <url> --header "Authorization: Bearer <token>"

# Local stdio server (double-dash separates server command)
claude mcp add --env KEY=value --transport stdio <name> -- npx -y <package>

# From JSON config
claude mcp add-json <name> '<json>'

# Import from Claude Desktop (macOS/WSL only)
claude mcp add-from-claude-desktop
```

### Managing Servers

| Command | Description |
| :------ | :---------- |
| `claude mcp list` | List all configured servers with status |
| `claude mcp get <name>` | Get details for a specific server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset `.mcp.json` approval decisions |
| `/mcp` (in session) | View, authenticate, and manage servers interactively |

### Server Status Indicators

| Status | Meaning |
| :----- | :------ |
| `✓ Connected` | Ready to use |
| `! Needs authentication` | OAuth browser sign-in required |
| `✗ Failed to connect` | Server didn't respond |
| `✗ Connection error` | Connection threw an error |
| `⏸ Pending approval` | Project-scoped server awaiting approval |

### Transport Types

| Transport | Config type field | Best for |
| :-------- | :---------------- | :------- |
| HTTP (streamable-http) | `http` or `streamable-http` | Remote cloud services; supports OAuth |
| SSE | `sse` | Remote servers (deprecated; prefer HTTP) |
| Stdio | `stdio` | Local processes needing filesystem/system access |
| WebSocket | `ws` | Remote servers that push events; header-only auth |

### MCP Installation Scopes

| Scope | Stored in | Loads in | Shared |
| :---- | :-------- | :------- | :----- |
| `local` (default) | `~/.claude.json` under project path | Current project only | No |
| `project` | `.mcp.json` in project root | Current project only | Yes, via version control |
| `user` | `~/.claude.json` top-level `mcpServers` | All projects | No |

Use `--scope local|project|user` on `claude mcp add`. Scope precedence (highest first): local → project → user → plugin-provided → claude.ai connectors.

### `.mcp.json` Format

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
      "args": ["-y", "my-mcp-package"],
      "env": { "KEY": "${VAR:-default}" }
    }
  }
}
```

Environment variable expansion: `${VAR}` and `${VAR:-default}` work in `command`, `args`, `env`, `url`, and `headers`.

### Authentication (OAuth 2.0)

Claude Code marks a server as needing auth when it returns `401`/`403`. Use `/mcp` in-session to complete the browser OAuth flow.

| Flag | Purpose |
| :--- | :------ |
| `--callback-port <port>` | Fix the OAuth callback port to match a pre-registered redirect URI |
| `--client-id <id>` | Provide a pre-configured OAuth client ID |
| `--client-secret` | Prompt for (or read `MCP_CLIENT_SECRET` env var for) the client secret |

Override OAuth metadata discovery with `oauth.authServerMetadataUrl` in `.mcp.json`. Restrict scopes with `oauth.scopes` (space-separated, RFC 6749 format).

### Dynamic Headers (`headersHelper`)

For non-OAuth auth (Kerberos, short-lived tokens, internal SSO), set `headersHelper` to a shell command that writes a JSON object of headers to stdout. Runs at each connection (session start and reconnect). Timeout: 10 seconds.

Environment variables available to the helper:

| Variable | Value |
| :------- | :---- |
| `CLAUDE_CODE_MCP_SERVER_NAME` | Name of the MCP server |
| `CLAUDE_CODE_MCP_SERVER_URL` | URL of the MCP server |

### MCP Tool Search (Context Efficiency)

Tool search is enabled by default. Tool definitions are deferred and loaded on demand, keeping context usage low. Control with `ENABLE_TOOL_SEARCH`:

| Value | Behavior |
| :---- | :------- |
| (unset) | All MCP tools deferred; falls back to upfront on Vertex AI or non-first-party `ANTHROPIC_BASE_URL` |
| `true` | Force deferral everywhere, even on Vertex AI |
| `auto` | Load upfront if schemas fit within 10% of context window; defer overflow |
| `auto:N` | Same as `auto` with a custom N% threshold |
| `false` | All tools loaded upfront, no deferral |

Use `alwaysLoad: true` in a server's `.mcp.json` entry to exempt one server from deferral. Set `"anthropic/alwaysLoad": true` in a tool's `_meta` to always load just that tool.

Disable the `ToolSearch` tool explicitly via `permissions.deny: ["ToolSearch"]` in settings.

### Output Limits

| Setting | Default | Description |
| :------ | :------ | :---------- |
| Warning threshold | 10,000 tokens | Displayed when a tool output exceeds this |
| `MAX_MCP_OUTPUT_TOKENS` env var | 25,000 tokens | Max allowed output (applies to tools without their own limit) |
| `_meta["anthropic/maxResultSizeChars"]` in tool definition | up to 500,000 chars | Per-tool override set by server authors |

### Environment Variables for MCP

| Variable | Effect |
| :------- | :----- |
| `MCP_TIMEOUT` | Server startup timeout in ms (default: 30,000) |
| `MCP_TOOL_TIMEOUT` | Per-tool wall-clock timeout in ms (default: ~28 hours) |
| `MAX_MCP_OUTPUT_TOKENS` | Max output tokens for tools without their own limit |
| `ENABLE_TOOL_SEARCH` | Control tool search behavior (see table above) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set to `false` to disable claude.ai connectors in Claude Code |
| `CLAUDE_PROJECT_DIR` | Set in stdio server's environment; points to project root |

### MCP Resources and Prompts

Reference MCP resources in prompts with `@server:protocol://resource/path`. Type `@` to see autocomplete.

MCP prompts become slash commands: `/mcp__servername__promptname [args...]`.

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers in `.mcp.json` at the plugin root or inline in `plugin.json`. Plugin MCP tool names follow the pattern: `mcp__plugin_<plugin-name>_<server-name>__<tool-name>`.

Use `${CLAUDE_PLUGIN_ROOT}` for bundled files, `${CLAUDE_PLUGIN_DATA}` for persistent state, `${CLAUDE_PROJECT_DIR}` for project root.

### Using Claude Code as an MCP Server

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

### Elicitation

MCP servers can request structured user input mid-task. Claude Code shows a dialog automatically — no configuration needed. Use the `Elicitation` hook to auto-respond without a dialog.

### Automatic Reconnection

HTTP and SSE servers reconnect automatically on disconnect: up to 5 attempts, exponential backoff starting at 1 second. After 5 failures, the server is marked failed and can be retried from `/mcp`. Stdio servers are not auto-reconnected.

---

## Managed MCP (Enterprise/Admin)

### Control Patterns

| Pattern | What it does | Configuration |
| :------ | :----------- | :------------ |
| Disable MCP | No servers load anywhere | `managed-mcp.json` with empty `mcpServers: {}` |
| Fixed deployment | Every user gets same servers, no additions | `managed-mcp.json` with desired servers |
| Approved catalog | Allowlist + users add what they want | `allowedMcpServers` + `allowManagedMcpServersOnly: true` |
| Plugin servers only | Only plugin servers, no user-added | `strictPluginOnlyCustomization` with `mcp` |
| Soft allowlist | Allowlist users can broaden | `allowedMcpServers` without `allowManagedMcpServersOnly` |
| Denylist only | Block known-bad, allow rest | `deniedMcpServers` |

### `managed-mcp.json` Paths

| Platform | Path |
| :------- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux/WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

Uses the same format as `.mcp.json`. When deployed, users cannot add, modify, or use any other MCP servers (including plugin-provided servers). Claude.ai connectors are also suppressed unless `allowAllClaudeAiMcps: true` is set in managed settings.

### Allowlist/Denylist Matching

`allowedMcpServers` and `deniedMcpServers` are arrays of match objects:

| Key | Matches | Notes |
| :-- | :------ | :---- |
| `serverUrl` | Remote server URL; supports `*` wildcards | Case-insensitive hostname matching |
| `serverCommand` | Exact command + args array for stdio servers | Must match every argument in order |
| `serverName` | User-assigned label; exact match only | Not a security control on its own |

Empty array `[]` vs unset:
- `allowedMcpServers: []` — no servers allowed
- `allowedMcpServers` unset — all servers allowed
- `deniedMcpServers: []` — no servers blocked (same as unset)

Set `allowManagedMcpServersOnly: true` to prevent users from broadening the allowlist via their own settings. Denylists always merge from all sources.

### URL Wildcard Examples

| Pattern | Matches |
| :------ | :------ |
| `https://mcp.example.com/*` | All paths on a specific domain |
| `https://mcp.example.com` | Also all paths (no path = any path) |
| `https://*.example.com/*` | Any subdomain of example.com |
| `http://localhost:*/*` | Any port on localhost |
| `*://mcp.example.com/*` | Any scheme to a specific domain |

### What Users See When Blocked

| Restriction | Message shown to user |
| :---------- | :-------------------- |
| `managed-mcp.json` active, user tries `claude mcp add` | `Cannot add MCP server: enterprise MCP configuration is active and has exclusive control over MCP servers` |
| Server on denylist, user tries `claude mcp add` | `Cannot add MCP server "<name>": server is explicitly blocked by enterprise policy` |
| Server not on allowlist, user tries `claude mcp add` | `Cannot add MCP server "<name>": not allowed by enterprise policy` |
| Previously configured server now blocked by policy | Server silently disappears from `/mcp` and `claude mcp list` |

### Monitoring MCP Usage

With OpenTelemetry configured, set `OTEL_LOG_TOOL_DETAILS=1` to include MCP server and tool names in tool events. See the Monitoring docs for the full event schema.

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — Full MCP reference: transports, scopes, authentication, tool search, output limits, elicitation, resources, prompts, plugin MCP servers
- [Control MCP server access for your organization](references/claude-code-managed-mcp.md) — Managed MCP configuration, allowlists, denylists, enterprise patterns, monitoring
- [MCP Quickstart](references/claude-code-mcp-quickstart.md) — Step-by-step walkthrough: add a server, verify connection, change scope, local servers, OAuth sign-in, troubleshooting

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
- Control MCP server access for your organization: https://code.claude.com/docs/en/managed-mcp.md
- MCP Quickstart: https://code.claude.com/docs/en/mcp-quickstart.md
