---
name: mcp-doc
description: Complete documentation for Claude Code MCP (Model Context Protocol) integration -- connecting to external tools and data sources via MCP servers. Covers transport types (HTTP, SSE, stdio), installing and managing servers (claude mcp add/list/get/remove), installation scopes (local, project, user), scope hierarchy and precedence, .mcp.json project configuration with environment variable expansion (${VAR}, ${VAR:-default}), OAuth 2.0 authentication (dynamic client registration, pre-configured credentials, --client-id, --client-secret, --callback-port, authServerMetadataUrl override), dynamic headers via headersHelper, adding servers from JSON (claude mcp add-json), importing from Claude Desktop (claude mcp add-from-claude-desktop), using Claude.ai connector servers (ENABLE_CLAUDEAI_MCP_SERVERS), using Claude Code as an MCP server (claude mcp serve), MCP output limits (MAX_MCP_OUTPUT_TOKENS, default 25000, warning at 10000), elicitation requests (form mode, URL mode, Elicitation hook), MCP resources (@ mention references), MCP prompts as /commands (/mcp__server__prompt), Tool Search (ENABLE_TOOL_SEARCH, deferred tool loading, auto threshold mode), dynamic tool updates (list_changed notifications), push messages with channels (claude/channel capability, --channels flag), plugin-provided MCP servers (.mcp.json or plugin.json, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, automatic lifecycle), managed MCP configuration (managed-mcp.json for exclusive control, allowedMcpServers/deniedMcpServers policy-based control with serverName/serverCommand/serverUrl matching), MCP_TIMEOUT environment variable, Windows cmd /c wrapper for npx, and practical examples (Sentry, GitHub, PostgreSQL). Load when discussing MCP servers, Model Context Protocol, claude mcp add, MCP transport types, .mcp.json, MCP scopes, MCP authentication, OAuth for MCP, headersHelper, claude mcp serve, MCP output tokens, MCP elicitation, MCP resources, MCP prompts, Tool Search, ENABLE_TOOL_SEARCH, managed-mcp.json, allowedMcpServers, deniedMcpServers, MCP tool search, MCP channels, plugin MCP servers, or any MCP-related topic for Claude Code.
user-invocable: false
---

# MCP (Model Context Protocol) Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools and data sources via the Model Context Protocol (MCP).

## Quick Reference

### Transport Types

| Transport | Flag | Use Case | Status |
|:----------|:-----|:---------|:-------|
| HTTP (Streamable HTTP) | `--transport http` | Remote cloud services (recommended) | Current |
| SSE (Server-Sent Events) | `--transport sse` | Remote cloud services | Deprecated (use HTTP) |
| stdio | `--transport stdio` | Local processes, custom scripts | Current |

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude mcp add --transport http <name> <url>` | Add a remote HTTP server |
| `claude mcp add --transport sse <name> <url>` | Add a remote SSE server |
| `claude mcp add [opts] <name> -- <cmd> [args...]` | Add a local stdio server |
| `claude mcp add-json <name> '<json>'` | Add server from JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Get details for a specific server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset project-scope approval choices |
| `claude mcp serve` | Run Claude Code as an MCP server |
| `/mcp` | Check server status / authenticate (in-session) |

**Option ordering:** All flags (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. Use `--` to separate server name from the command/args passed to the MCP server.

### Installation Scopes

| Scope | Flag | Storage | Visibility |
|:------|:-----|:--------|:-----------|
| Local (default) | `--scope local` | `~/.claude.json` (under project path) | Private, current project only |
| Project | `--scope project` | `.mcp.json` at project root (commit to VCS) | Shared with team |
| User | `--scope user` | `~/.claude.json` | Private, all projects |

**Precedence:** local > project > user. Local config also overrides Claude.ai connector entries.

### .mcp.json Format

```json
{
  "mcpServers": {
    "server-name": {
      "command": "/path/to/server",
      "args": [],
      "env": {}
    }
  }
}
```

**Environment variable expansion** (in `command`, `args`, `env`, `url`, `headers`):
- `${VAR}` -- expands to value of `VAR` (fails if unset)
- `${VAR:-default}` -- expands to `VAR` if set, otherwise `default`

### Authentication

**OAuth 2.0 (HTTP/SSE servers):**
1. Add the server: `claude mcp add --transport http <name> <url>`
2. Authenticate: run `/mcp` in-session and follow browser flow
3. Tokens are stored securely and refreshed automatically

**Pre-configured OAuth credentials:**

```bash
claude mcp add --transport http \
  --client-id your-client-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

| Flag | Purpose |
|:-----|:--------|
| `--client-id` | OAuth app client ID |
| `--client-secret` | Prompts for secret with masked input (or set `MCP_CLIENT_SECRET` env var) |
| `--callback-port` | Fixed port for redirect URI (`http://localhost:PORT/callback`) |

**Override OAuth metadata discovery** with `authServerMetadataUrl` in the `oauth` object of `.mcp.json` config (requires v2.1.64+).

**Dynamic headers (headersHelper):**

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
- 10-second timeout; runs on each connection
- Environment: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`
- Dynamic headers override static `headers` with the same name

### Environment Variables

| Variable | Purpose | Default |
|:---------|:--------|:--------|
| `MCP_TIMEOUT` | Server startup timeout in ms | (system default) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens per MCP tool output | 25,000 |
| `ENABLE_TOOL_SEARCH` | Tool search behavior | (see table below) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Enable/disable Claude.ai connector servers | `true` |
| `MCP_CLIENT_SECRET` | OAuth client secret (non-interactive) | -- |

### Tool Search (ENABLE_TOOL_SEARCH)

| Value | Behavior |
|:------|:---------|
| (unset) | All MCP tools deferred and loaded on demand; falls back to upfront loading for non-first-party `ANTHROPIC_BASE_URL` |
| `true` | All MCP tools deferred, including non-first-party hosts |
| `auto` | Threshold mode: upfront if fits within 10% of context window, deferred otherwise |
| `auto:<N>` | Custom threshold percentage (0-100), e.g. `auto:5` |
| `false` | All MCP tools loaded upfront, no deferral |

Requires Sonnet 4+ or Opus 4+. Haiku models do not support tool search. Disable the ToolSearch tool via `"permissions": {"deny": ["ToolSearch"]}` in settings.

### MCP Output Limits

- Warning displayed when any tool output exceeds 10,000 tokens
- Default maximum: 25,000 tokens
- Configurable: `MAX_MCP_OUTPUT_TOKENS=50000 claude`

### MCP Resources

Reference resources from connected servers using `@` mentions:

```
@server:protocol://resource/path
```

Resources appear in the `@` autocomplete menu alongside files.

### MCP Prompts as Commands

MCP prompts appear as `/mcp__servername__promptname` commands. Pass arguments space-separated after the command name.

### Elicitation

MCP servers can request structured input mid-task. Two modes:
- **Form mode**: Interactive dialog with server-defined fields
- **URL mode**: Browser-based authentication/approval flow

Auto-respond via the `Elicitation` hook.

### Push Messages (Channels)

MCP servers declaring `claude/channel` capability can push messages into sessions. Opt in with `--channels` flag at startup. See Channels documentation for details.

### Dynamic Tool Updates

Servers sending `list_changed` notifications trigger automatic capability refresh without reconnection.

### Using Claude Code as an MCP Server

```bash
claude mcp serve
```

Exposes Claude Code's tools (View, Edit, LS, etc.) to other MCP clients. Claude Desktop config:

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

Use `which claude` to find the full executable path if `claude` is not in PATH.

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers via `.mcp.json` at the plugin root or inline in `plugin.json`:

```json
{
  "mcpServers": {
    "plugin-tool": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/tool-server",
      "args": [],
      "env": {}
    }
  }
}
```

- `${CLAUDE_PLUGIN_ROOT}` -- path to plugin files
- `${CLAUDE_PLUGIN_DATA}` -- persistent data directory
- Automatic lifecycle: connect on session start, `/reload-plugins` to reconnect
- Supports stdio, SSE, and HTTP transports

### Managed MCP Configuration (Enterprise)

**Option 1: Exclusive control (managed-mcp.json)**

Deploy to system directory (requires admin privileges):
- macOS: `/Library/Application Support/ClaudeCode/managed-mcp.json`
- Linux/WSL: `/etc/claude-code/managed-mcp.json`
- Windows: `C:\Program Files\ClaudeCode\managed-mcp.json`

Users cannot add/modify servers when this file exists. Same format as `.mcp.json`.

**Option 2: Policy-based control (allowlists/denylists)**

In managed settings file:

| Setting | Default | Effect |
|:--------|:--------|:-------|
| `allowedMcpServers` | `undefined` | No restrictions (all allowed) |
| `allowedMcpServers: []` | -- | Complete lockdown (none allowed) |
| `deniedMcpServers` | `undefined` | Nothing blocked |

Each entry supports one restriction type:
- `{ "serverName": "name" }` -- match by configured name
- `{ "serverCommand": ["cmd", "arg1", ...] }` -- exact command match (stdio only)
- `{ "serverUrl": "https://*.example.com/*" }` -- URL pattern with wildcards (remote only)

**Denylist always takes precedence** over allowlist. Options 1 and 2 can be combined.

### Windows Note

On native Windows (not WSL), stdio servers using `npx` require the `cmd /c` wrapper:

```bash
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

### Claude.ai Connector Servers

MCP servers configured at [claude.ai/settings/connectors](https://claude.ai/settings/connectors) are automatically available in Claude Code when logged in with a Claude.ai account. Disable with `ENABLE_CLAUDEAI_MCP_SERVERS=false`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) -- Full MCP integration guide covering transports, scopes, authentication, tool search, managed configuration, and more

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
