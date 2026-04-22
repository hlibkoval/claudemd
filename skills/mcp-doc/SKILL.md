---
name: mcp-doc
description: Complete official documentation for connecting Claude Code to external tools and data sources via the Model Context Protocol (MCP) — server installation, scopes, OAuth authentication, managed configuration, tool search, resources, prompts, and output limits.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools via MCP.

## Quick Reference

### Adding MCP servers

| Transport | Command | Use when |
| :-------- | :------ | :------- |
| HTTP (recommended) | `claude mcp add --transport http <name> <url>` | Remote cloud services |
| SSE (deprecated) | `claude mcp add --transport sse <name> <url>` | Legacy remote servers |
| stdio | `claude mcp add --transport stdio <name> -- <cmd> [args...]` | Local processes, custom scripts |

**Important:** All options (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. Use `--` to separate the server name from the command passed to a stdio server.

**Common flags:**

| Flag | Purpose |
| :--- | :------ |
| `--scope local` | Current project only, private to you (default) |
| `--scope project` | Shared via `.mcp.json` in project root |
| `--scope user` | Available across all your projects |
| `--env KEY=value` | Set environment variables for the server |
| `--header "K: V"` | Add request headers (HTTP/SSE) |
| `--transport http\|sse\|stdio` | Transport type |

**Management commands:**

```
claude mcp list               # List all configured servers
claude mcp get <name>         # Details for a specific server
claude mcp remove <name>      # Remove a server
claude mcp add-json <name> '<json>'           # Add from JSON config
claude mcp add-from-claude-desktop            # Import from Claude Desktop (macOS/WSL only)
claude mcp reset-project-choices              # Reset .mcp.json approval choices
/mcp                          # (in Claude Code) Check server status / authenticate
```

**Windows (native, non-WSL):** wrap `npx` with `cmd /c` to avoid "Connection closed" errors:
```
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

---

### MCP installation scopes

| Scope | Loads in | Shared with team | Stored in |
| :---- | :------- | :--------------- | :-------- |
| Local (default) | Current project only | No | `~/.claude.json` |
| Project | Current project only | Yes, via version control | `.mcp.json` in project root |
| User | All your projects | No | `~/.claude.json` |

**Scope precedence (highest to lowest):** Local → Project → User → Plugin-provided → Claude.ai connectors

Project-scoped `.mcp.json` supports environment variable expansion: `${VAR}` and `${VAR:-default}` in `command`, `args`, `env`, `url`, and `headers`.

---

### OAuth authentication for remote servers

1. Add the server: `claude mcp add --transport http <name> <url>`
2. Run `/mcp` in Claude Code and follow the browser login flow
3. Tokens are stored securely and refreshed automatically; use "Clear authentication" in `/mcp` to revoke

**Pre-configured OAuth credentials** (when dynamic client registration is unsupported):
```
claude mcp add --transport http \
  --client-id your-client-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```
Or set the secret via env: `MCP_CLIENT_SECRET=your-secret claude mcp add ...`

**OAuth config fields in `.mcp.json`:**

| Field | Purpose |
| :---- | :------ |
| `oauth.clientId` | Pre-registered client ID |
| `oauth.callbackPort` | Fixed callback port for registered redirect URI |
| `oauth.authServerMetadataUrl` | Override OAuth discovery URL (requires v2.1.64+, must be `https://`) |
| `oauth.scopes` | Space-separated scope string to pin (RFC 6749 §3.3 format) |

**Dynamic headers** (non-OAuth auth like Kerberos, short-lived tokens): set `headersHelper` in `.mcp.json` to a command that writes a JSON object of headers to stdout. Env vars available: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`.

---

### Plugin-provided MCP servers

Plugins can bundle MCP servers defined in `.mcp.json` at the plugin root or inline in `plugin.json`. They start automatically when a plugin is enabled. Run `/reload-plugins` if you enable/disable a plugin mid-session.

**Plugin env vars:** `${CLAUDE_PLUGIN_ROOT}` for bundled files, `${CLAUDE_PLUGIN_DATA}` for persistent state.

---

### MCP output limits

| Setting | Default | How to change |
| :------ | :------ | :------------ |
| Warning threshold | 10,000 tokens | Display only; not configurable |
| Max output tokens | 25,000 tokens | `MAX_MCP_OUTPUT_TOKENS=<n> claude` |
| Per-tool override | Up to 500,000 chars | Set `_meta["anthropic/maxResultSizeChars"]` in `tools/list` response |

The per-tool `anthropic/maxResultSizeChars` annotation applies to text content only; image data is always subject to `MAX_MCP_OUTPUT_TOKENS`.

---

### Tool search (MCP context scaling)

MCP tool definitions are deferred by default — only tool names load at session start; schemas are fetched on demand. Controls:

| `ENABLE_TOOL_SEARCH` value | Behavior |
| :------------------------- | :------- |
| (unset) | All MCP tools deferred; falls back to upfront loading for non-first-party `ANTHROPIC_BASE_URL` |
| `true` | All MCP tools deferred, including non-first-party base URLs |
| `auto` | Threshold mode: load upfront if within 10% of context window |
| `auto:<N>` | Threshold mode with custom percentage (0–100) |
| `false` | All MCP tools loaded upfront |

Requires Sonnet 4 / Opus 4 or later; Haiku models do not support tool search. Disable the `ToolSearch` tool via `permissions.deny` in settings if needed.

For MCP server authors: write clear `server instructions` explaining what tasks your tools handle — these guide tool search discovery.

---

### MCP resources and prompts

**Resources** — reference via `@server:protocol://resource/path` in prompts (e.g., `@github:issue://123`). Type `@` to autocomplete available resources. Resources are fetched and attached automatically.

**Prompts** — exposed as slash commands with format `/mcp__servername__promptname`. Pass arguments space-separated: `/mcp__github__pr_review 456`. Prompt names are normalized (spaces → underscores).

---

### Managed MCP configuration (org/admin)

**Option 1 — Exclusive control via `managed-mcp.json`:** users cannot add any other servers.

System paths:
- macOS: `/Library/Application Support/ClaudeCode/managed-mcp.json`
- Linux/WSL: `/etc/claude-code/managed-mcp.json`
- Windows: `C:\Program Files\ClaudeCode\managed-mcp.json`

File format is identical to `.mcp.json` (`{ "mcpServers": { ... } }`).

**Option 2 — Policy-based control via allowlists/denylists** in the managed settings file:

| Field | Restriction type | Match key |
| :---- | :--------------- | :-------- |
| `allowedMcpServers` | Whitelist | `serverName`, `serverCommand` (exact array), or `serverUrl` (wildcard) |
| `deniedMcpServers` | Blacklist (absolute precedence) | Same keys |

- `allowedMcpServers: undefined` = no restrictions; `[]` = complete lockdown
- When `serverCommand` entries exist, stdio servers must match a command entry (name alone is insufficient)
- When `serverUrl` entries exist, remote servers must match a URL pattern (name alone is insufficient)
- URL wildcards: `*` matches any sequence, e.g., `https://*.example.com/*`
- Options 1 and 2 can be combined; denylists still apply to managed servers

---

### Reconnection and dynamic updates

- **HTTP/SSE servers:** auto-reconnect with exponential backoff (up to 5 attempts, starting at 1 s, doubling). Server shows as pending in `/mcp` during reconnection; marked failed after 5 attempts.
- **Stdio servers:** not auto-reconnected (local processes).
- **Dynamic tool updates:** Claude Code handles MCP `list_changed` notifications to refresh tools/prompts/resources without disconnecting.

---

### Claude Code as an MCP server

```bash
claude mcp serve    # Start Claude Code as a stdio MCP server
```

Claude Desktop config (`claude_desktop_config.json`):
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

---

### Claude.ai connectors in Claude Code

MCP servers configured at [claude.ai/customize/connectors](https://claude.ai/customize/connectors) are automatically available in Claude Code when logged in with a Claude.ai account. Disable with `ENABLE_CLAUDEAI_MCP_SERVERS=false claude`.

---

### MCP elicitation

Servers can request structured input mid-task. Claude Code shows either a form dialog or opens a browser URL. No configuration needed on the client side. To auto-respond, use the [`Elicitation` hook](/en/hooks#elicitation).

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — full coverage of server installation, scopes, OAuth, managed configuration, tool search, resources, prompts, output limits, elicitation, and running Claude Code as an MCP server

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
