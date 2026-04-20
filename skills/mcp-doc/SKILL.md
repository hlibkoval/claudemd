---
name: mcp-doc
description: Complete official documentation for Claude Code MCP integration — connecting to MCP servers (HTTP, SSE, stdio), installation scopes, OAuth authentication, managed configuration, tool search, resources, prompts, elicitation, output limits, and using Claude Code as an MCP server.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools via the Model Context Protocol (MCP).

## Quick Reference

MCP servers give Claude Code access to external tools, databases, and APIs through the [Model Context Protocol](https://modelcontextprotocol.io/introduction). Connect a server when you find yourself copying data into chat from another tool.

### Adding MCP servers

| Transport | Command | Use case |
| :-------- | :------ | :------- |
| **HTTP** (recommended) | `claude mcp add --transport http <name> <url>` | Remote cloud services |
| **SSE** (deprecated) | `claude mcp add --transport sse <name> <url>` | Legacy remote servers |
| **stdio** | `claude mcp add <name> -- <command> [args...]` | Local processes, custom scripts |
| **JSON config** | `claude mcp add-json <name> '<json>'` | Complex configurations |

Option ordering: all flags (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. The `--` separates the name from the command/args passed to the server.

### Management commands

| Command | Description |
| :------ | :---------- |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Get details for a specific server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop |
| `claude mcp reset-project-choices` | Reset project-scope approval choices |
| `/mcp` | Check server status / authenticate (in session) |

### Installation scopes

| Scope | Flag | Loads in | Shared with team | Stored in |
| :---- | :--- | :------- | :--------------- | :-------- |
| **Local** (default) | `--scope local` | Current project only | No | `~/.claude.json` (under project path) |
| **Project** | `--scope project` | Current project only | Yes (via `.mcp.json`) | `.mcp.json` at project root |
| **User** | `--scope user` | All your projects | No | `~/.claude.json` |

Precedence (highest first): Local > Project > User > Plugin-provided > claude.ai connectors. Duplicates matched by name (scopes) or endpoint (plugins/connectors).

### Environment variable expansion in `.mcp.json`

Supported syntax: `${VAR}` and `${VAR:-default}`. Works in `command`, `args`, `env`, `url`, and `headers` fields. Undefined variables with no default cause a parse failure.

### OAuth authentication

1. Add the server: `claude mcp add --transport http <name> <url>`
2. Authenticate via `/mcp` in session (opens browser)
3. Tokens are stored securely and refreshed automatically

Key OAuth flags and fields:

| Flag / Field | Purpose |
| :----------- | :------ |
| `--client-id` | Pre-configured OAuth client ID |
| `--client-secret` | Prompts for client secret (masked input) |
| `--callback-port <port>` | Fixed OAuth callback port (matches registered redirect URI) |
| `MCP_CLIENT_SECRET` env var | Set secret non-interactively (CI) |
| `oauth.authServerMetadataUrl` | Override metadata discovery URL (`.mcp.json`) |
| `oauth.scopes` | Pin requested scopes (space-separated, `.mcp.json`) |

### Dynamic headers (`headersHelper`)

Run a command at connection time to generate authentication headers (Kerberos, SSO, short-lived tokens):

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

Requirements: command must write JSON `{"Header": "value"}` to stdout, 10-second timeout, dynamic headers override static ones. Environment variables `CLAUDE_CODE_MCP_SERVER_NAME` and `CLAUDE_CODE_MCP_SERVER_URL` are set for the helper.

### Output limits

| Setting | Default | Description |
| :------ | :------ | :---------- |
| Warning threshold | 10,000 tokens | Warning displayed when exceeded |
| `MAX_MCP_OUTPUT_TOKENS` | 25,000 tokens | Maximum allowed output (env var) |
| `anthropic/maxResultSizeChars` | Up to 500,000 chars | Per-tool annotation in `tools/list` `_meta` |

`anthropic/maxResultSizeChars` applies independently of `MAX_MCP_OUTPUT_TOKENS` for text content. Image data is always subject to the token limit.

### Tool Search

Enabled by default. MCP tool schemas are deferred and discovered on demand, keeping context usage low. Requires Sonnet 4+ or Opus 4+ (Haiku not supported).

| `ENABLE_TOOL_SEARCH` value | Behavior |
| :------------------------- | :------- |
| (unset) | All MCP tools deferred; falls back to upfront for non-first-party `ANTHROPIC_BASE_URL` |
| `true` | All deferred, including non-first-party hosts |
| `auto` | Upfront if tools fit within 10% of context window, deferred otherwise |
| `auto:<N>` | Custom threshold percentage (0-100) |
| `false` | All tools loaded upfront, no deferral |

Disable the ToolSearch tool specifically via `permissions.deny: ["ToolSearch"]` in settings.

### MCP Timeout

Set `MCP_TIMEOUT` env var to configure server startup timeout in milliseconds (e.g., `MCP_TIMEOUT=10000 claude` for 10 seconds).

### Automatic reconnection

HTTP/SSE servers: up to 5 reconnection attempts with exponential backoff (starts at 1 second, doubles each time). Server shows as pending in `/mcp` during reconnection. Stdio servers are not reconnected automatically.

### Elicitation

MCP servers can request structured input mid-task. Two modes: **form** (dialog with server-defined fields) and **URL** (browser flow). Use the `Elicitation` hook to auto-respond. No user configuration needed.

### MCP resources

Reference resources from connected MCP servers with `@server:protocol://resource/path` syntax. Resources appear in `@` autocomplete alongside files.

### MCP prompts as commands

MCP server prompts become slash commands: `/mcp__servername__promptname [args...]`. Type `/` to discover them.

### Plugin-provided MCP servers

Plugins can bundle MCP servers in `.mcp.json` at the plugin root or inline in `plugin.json`. Plugin servers start automatically when the plugin is enabled. Use `${CLAUDE_PLUGIN_ROOT}` for bundled files and `${CLAUDE_PLUGIN_DATA}` for persistent state. Run `/reload-plugins` to connect/disconnect after enabling/disabling a plugin mid-session.

### Channels (push messages)

MCP servers can push messages into your session by declaring the `claude/channel` capability. Enable with the `--channels` flag at startup.

### Claude Code as an MCP server

Expose Claude Code's tools (View, Edit, LS, etc.) to other MCP clients:

```bash
claude mcp serve
```

### Managed MCP configuration (enterprise)

| Option | Mechanism | Effect |
| :----- | :-------- | :----- |
| **Exclusive control** | `managed-mcp.json` at system path | Only managed servers allowed; users cannot add their own |
| **Policy-based** | `allowedMcpServers` / `deniedMcpServers` in managed settings | Users add their own within policy constraints |

System paths for `managed-mcp.json`:
- macOS: `/Library/Application Support/ClaudeCode/managed-mcp.json`
- Linux/WSL: `/etc/claude-code/managed-mcp.json`
- Windows: `C:\Program Files\ClaudeCode\managed-mcp.json`

Policy restriction types: `serverName` (by name), `serverCommand` (exact command array match for stdio), `serverUrl` (URL pattern with `*` wildcards for remote). Denylist takes absolute precedence over allowlist.

### Claude.ai MCP servers

Servers configured at [claude.ai/settings/connectors](https://claude.ai/settings/connectors) are automatically available in Claude Code when logged in with a Claude.ai account. Disable with `ENABLE_CLAUDEAI_MCP_SERVERS=false`.

### Windows note

On native Windows (not WSL), stdio servers using `npx` require the `cmd /c` wrapper:

```bash
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — full guide covering MCP server installation (HTTP, SSE, stdio, JSON), scopes (local, project, user), OAuth authentication (dynamic client registration, pre-configured credentials, callback ports, metadata overrides, scope pinning), dynamic headers, environment variable expansion, plugin-provided servers, managed configuration, tool search, output limits, elicitation, resources, prompts as commands, channels, and using Claude Code as an MCP server.

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
