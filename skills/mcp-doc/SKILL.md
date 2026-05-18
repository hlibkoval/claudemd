---
name: mcp-doc
description: Complete official documentation for connecting Claude Code to external tools via MCP (Model Context Protocol) — installing servers, transport types, scopes, OAuth authentication, managed configuration, tool search, MCP resources and prompts, channels, output limits, and using Claude Code as an MCP server.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools via the Model Context Protocol (MCP).

## Quick Reference

### Transport Types

| Transport | CLI flag | Type alias | Use case |
| :--- | :--- | :--- | :--- |
| HTTP (recommended) | `--transport http` | `streamable-http` in JSON | Cloud/remote services |
| SSE (deprecated) | `--transport sse` | `sse` | Legacy remote servers |
| Stdio | `--transport stdio` | `stdio` | Local processes, system access |

### Adding Servers

```bash
# HTTP server
claude mcp add --transport http <name> <url>
claude mcp add --transport http notion https://mcp.notion.com/mcp
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"

# SSE server (deprecated)
claude mcp add --transport sse asana https://mcp.asana.com/sse

# Stdio server
claude mcp add --transport stdio --env AIRTABLE_API_KEY=KEY airtable \
  -- npx -y airtable-mcp-server

# From JSON config
claude mcp add-json <name> '<json>'

# Import from Claude Desktop (macOS and WSL only)
claude mcp add-from-claude-desktop
```

**Option ordering:** All flags (`--transport`, `--env`, `--scope`, `--header`) must come before the server name. Use `--` to separate server name from command+args.

### Managing Servers

```bash
claude mcp list          # List all configured servers
claude mcp get <name>    # Get server details
claude mcp remove <name> # Remove a server
/mcp                     # Check status in Claude Code
```

The server name `workspace` is reserved — Claude Code skips it and warns you to rename.

### Installation Scopes

| Scope | Storage | Shared with team | Loads in |
| :--- | :--- | :--- | :--- |
| `local` (default) | `~/.claude.json` | No | Current project only |
| `project` | `.mcp.json` in project root | Yes, via version control | Current project only |
| `user` | `~/.claude.json` | No | All your projects |

```bash
claude mcp add --transport http stripe --scope local https://mcp.stripe.com
claude mcp add --transport http paypal --scope project https://mcp.paypal.com/mcp
claude mcp add --transport http hubspot --scope user https://mcp.hubspot.com/anthropic
```

Project-scoped servers (`.mcp.json`) require approval before use. Reset choices with `claude mcp reset-project-choices`.

### Scope Hierarchy (Precedence, Highest First)

1. Local scope
2. Project scope
3. User scope
4. Plugin-provided servers
5. claude.ai connectors

### Environment Variable Expansion in `.mcp.json`

| Syntax | Meaning |
| :--- | :--- |
| `${VAR}` | Expand environment variable `VAR` |
| `${VAR:-default}` | Use `VAR` if set, else `default` |

Expansion works in: `command`, `args`, `env`, `url`, `headers`.

### Environment Variables

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_PROJECT_DIR` | Project root, set in spawned stdio server's environment |
| `MCP_TIMEOUT` | Server startup timeout in ms (e.g., `MCP_TIMEOUT=10000`) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens per MCP tool output (default 25,000; warning at 10,000) |
| `ENABLE_TOOL_SEARCH` | Control tool search behavior (see table below) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set to `false` to disable claude.ai MCP servers |
| `MCP_CONNECTION_NONBLOCKING` | Set to `1` to connect servers in background at startup |

### OAuth Authentication

Claude Code marks a server as needing auth when it returns `401 Unauthorized` or `403 Forbidden`. Use `/mcp` to complete the OAuth 2.0 flow.

| Flag | Purpose |
| :--- | :--- |
| `--callback-port <port>` | Fix OAuth callback port for pre-registered redirect URIs |
| `--client-id <id>` | Pre-configured OAuth client ID |
| `--client-secret` | Prompt for client secret (masked); or set `MCP_CLIENT_SECRET` env var |

**Override OAuth discovery:** Set `authServerMetadataUrl` in the `oauth` object in `.mcp.json` (requires v2.1.64+).

**Restrict OAuth scopes:** Set `oauth.scopes` to a space-separated string of scopes (RFC 6749 §3.3 format).

**Dynamic headers (non-OAuth auth):** Use `headersHelper` field — a shell command that writes a JSON object of string headers to stdout. Runs fresh on each connection with `CLAUDE_CODE_MCP_SERVER_NAME` and `CLAUDE_CODE_MCP_SERVER_URL` env vars set.

### Connection Behavior

- **Dynamic tool updates:** Claude Code supports MCP `list_changed` notifications — no reconnect needed.
- **Auto-reconnect (HTTP/SSE):** Exponential backoff, up to 5 attempts, starting at 1s, doubling each time. After 5 failures, marked as failed; retry manually from `/mcp`. At startup: up to 3 retries for transient errors (5xx, connection refused, timeout). Auth and not-found errors not retried.
- **Stdio servers:** Not reconnected automatically (local processes).

### Tool Search (`ENABLE_TOOL_SEARCH`)

| Value | Behavior |
| :--- | :--- |
| (unset) | All MCP tools deferred, loaded on demand. Falls back to upfront on Vertex AI or non-first-party `ANTHROPIC_BASE_URL` |
| `true` | All MCP tools deferred, beta header sent even on Vertex AI/proxies |
| `auto` | Threshold mode: load upfront if tools fit within 10% of context window, defer otherwise |
| `auto:N` | Threshold mode with custom N% (0–100) |
| `false` | All MCP tools loaded upfront, no deferral |

Tool search requires Sonnet 4+ or Opus 4+. Haiku models do not support it. On Vertex AI: Sonnet 4.5+ or Opus 4.5+.

**Exempt a server from deferral:** Set `"alwaysLoad": true` in that server's config. Tools marked with `"anthropic/alwaysLoad": true` in their `_meta` are also always loaded. Requires v2.1.121+.

**Per-tool output size annotation:** Set `_meta["anthropic/maxResultSizeChars"]` in `tools/list` response (max 500,000 characters). Applies to text content; image data always subject to `MAX_MCP_OUTPUT_TOKENS`.

**Deny `ToolSearch` tool:**
```json
{ "permissions": { "deny": ["ToolSearch"] } }
```

### MCP Resources

Reference MCP resources with `@server:protocol://resource/path` syntax in prompts. Type `@` to see available resources from all connected servers alongside files in autocomplete.

### MCP Prompts as Commands

MCP server prompts appear as slash commands in the format `/mcp__servername__promptname`. Pass arguments space-separated after the command name.

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers in `.mcp.json` at the plugin root or inline in `plugin.json`. They start automatically when the plugin is enabled. Run `/reload-plugins` to connect/disconnect after enabling/disabling during a session.

Plugin MCP environment variables:
- `${CLAUDE_PLUGIN_ROOT}` — bundled plugin files
- `${CLAUDE_PLUGIN_DATA}` — persistent state surviving updates
- `${CLAUDE_PROJECT_DIR}` — stable project root

### Use Claude Code as an MCP Server

```bash
claude mcp serve   # Start as stdio MCP server
```

Add to `claude_desktop_config.json` to use in Claude Desktop:
```json
{
  "mcpServers": {
    "claude-code": { "type": "stdio", "command": "claude", "args": ["mcp", "serve"], "env": {} }
  }
}
```

If `claude` is not in PATH, use the full path from `which claude`.

### Channels

An MCP server can push messages directly into your session by declaring the `claude/channel` capability. Opt in at startup with the `--channels` flag. See the Channels and Channels reference docs.

### Elicitation

MCP servers can request structured input mid-task. Claude Code shows an interactive dialog automatically — no configuration required. Use the `Elicitation` hook to auto-respond. Two modes:
- **Form mode:** Server-defined form fields
- **URL mode:** Browser-based flow

### Managed MCP Configuration (Enterprise)

**Option 1 — Exclusive control via `managed-mcp.json`:**

| Platform | Path |
| :--- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux / WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

Uses same format as `.mcp.json`. When present, users cannot add/modify servers.

**Option 2 — Policy-based allowlists/denylists in managed settings:**

Each entry uses exactly one of:
- `serverName` — match by configured name
- `serverCommand` — exact command+args array (stdio servers)
- `serverUrl` — URL pattern with `*` wildcard support (case-insensitive hostnames, case-sensitive paths)

Denylist takes absolute precedence. A server passes if it matches any name, command, or URL entry (unless denied).

| Setting | `undefined` | `[]` | List |
| :--- | :--- | :--- | :--- |
| `allowedMcpServers` | No restrictions | Complete lockdown | Allowlist |
| `deniedMcpServers` | No servers blocked | No servers blocked | Explicit blocklist |

Options 1 and 2 can be combined — allowlists/denylists still apply to filter managed servers.

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — full guide to installing, configuring, and managing MCP servers, OAuth authentication, tool search, resources, prompts, and managed configuration

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
