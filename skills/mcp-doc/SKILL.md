---
name: mcp-doc
description: Complete official documentation for connecting Claude Code to external tools via MCP — adding servers (HTTP, SSE, stdio), scopes, OAuth authentication, managed configuration, plugin-provided servers, tool search, resources, prompts, elicitation, and output limits.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools via the Model Context Protocol (MCP).

## Quick Reference

MCP servers give Claude Code access to external tools, databases, and APIs through the [Model Context Protocol](https://modelcontextprotocol.io/introduction). Connect a server when you find yourself copying data from another tool into chat.

### Adding servers

| Transport | Command | Use case |
| :-------- | :------ | :------- |
| **HTTP** (recommended) | `claude mcp add --transport http <name> <url>` | Remote cloud services |
| **SSE** (deprecated) | `claude mcp add --transport sse <name> <url>` | Legacy remote servers |
| **stdio** | `claude mcp add <name> -- <command> [args...]` | Local processes, custom scripts |

Option ordering: all flags (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. `--` separates the name from the command/args for stdio servers.

Add from JSON directly:

```bash
claude mcp add-json <name> '<json>'
```

Import from Claude Desktop (macOS/WSL only):

```bash
claude mcp add-from-claude-desktop
```

### Managing servers

| Command | Action |
| :------ | :----- |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Show details for a server |
| `claude mcp remove <name>` | Remove a server |
| `/mcp` | Check status / authenticate (in-session) |

### Installation scopes

| Scope | Flag | Loads in | Shared | Stored in |
| :---- | :--- | :------- | :----- | :-------- |
| **Local** (default) | `--scope local` | Current project only | No | `~/.claude.json` (under project path) |
| **Project** | `--scope project` | Current project only | Yes (via `.mcp.json`) | `.mcp.json` at project root |
| **User** | `--scope user` | All your projects | No | `~/.claude.json` |

Precedence (highest first): Local > Project > User > Plugin-provided > claude.ai connectors.

### `.mcp.json` environment variable expansion

Supported in `command`, `args`, `env`, `url`, and `headers` fields:

- `${VAR}` -- expands to value of `VAR`
- `${VAR:-default}` -- uses `default` if `VAR` is unset

### OAuth authentication

1. Add the server: `claude mcp add --transport http <name> <url>`
2. Run `/mcp` in-session and follow the browser login flow

Key flags for pre-configured OAuth:

| Flag | Purpose |
| :--- | :------ |
| `--client-id <id>` | Pre-registered OAuth client ID |
| `--client-secret` | Prompts for client secret (stored in system keychain) |
| `--callback-port <port>` | Fixed port for OAuth redirect URI (`http://localhost:PORT/callback`) |

Set `MCP_CLIENT_SECRET` env var to skip the interactive secret prompt (CI use).

Advanced OAuth configuration (in `.mcp.json` `oauth` object):

| Field | Purpose |
| :---- | :------ |
| `authServerMetadataUrl` | Override default OAuth metadata discovery URL (requires `https://`) |
| `scopes` | Pin requested OAuth scopes (space-separated string per RFC 6749) |
| `callbackPort` | Fixed callback port |
| `clientId` | Pre-registered client ID |

### Dynamic headers (`headersHelper`)

Run a command at connection time to generate request headers (for Kerberos, short-lived tokens, internal SSO):

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

Requirements: command must output JSON `{"Header": "value"}` to stdout; 10-second timeout; dynamic headers override static ones with the same name.

Environment variables set for the helper: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`.

### Plugin-provided MCP servers

Plugins can bundle MCP servers in `.mcp.json` at the plugin root or inline in `plugin.json`. Plugin servers start automatically when the plugin is enabled.

Available variables: `${CLAUDE_PLUGIN_ROOT}` (bundled files), `${CLAUDE_PLUGIN_DATA}` (persistent state).

Run `/reload-plugins` to connect/disconnect plugin MCP servers after enabling/disabling a plugin mid-session.

### Claude Code as an MCP server

```bash
claude mcp serve
```

Exposes Claude Code's tools (View, Edit, LS, etc.) to other MCP clients like Claude Desktop.

### MCP Tool Search

Enabled by default. Tool definitions are deferred and loaded on demand to keep context usage low.

| `ENABLE_TOOL_SEARCH` value | Behavior |
| :------------------------- | :------- |
| (unset) | All MCP tools deferred and loaded on demand (falls back to upfront for non-first-party hosts) |
| `true` | Force deferred mode even for non-first-party `ANTHROPIC_BASE_URL` |
| `auto` | Upfront if tools fit within 10% of context window, deferred otherwise |
| `auto:<N>` | Custom threshold percentage (0-100) |
| `false` | All tools loaded upfront, no deferral |

Requires Sonnet 4+ or Opus 4+. Haiku models do not support tool search.

### Output limits

| Setting | Default | Description |
| :------ | :------ | :---------- |
| Warning threshold | 10,000 tokens | Warning displayed when any MCP tool output exceeds this |
| `MAX_MCP_OUTPUT_TOKENS` | 25,000 tokens | Maximum allowed MCP output tokens (env var) |
| `anthropic/maxResultSizeChars` | -- | Per-tool annotation in `_meta` of `tools/list` response (up to 500,000 chars); overrides `MAX_MCP_OUTPUT_TOKENS` for text content |

### Elicitation

MCP servers can request structured input mid-task. Two modes:

- **Form mode**: dialog with fields defined by the server
- **URL mode**: opens browser for authentication/approval

Use the `Elicitation` hook to auto-respond without showing a dialog.

### MCP resources

Reference resources from connected servers with `@server:protocol://resource/path` syntax. Resources appear in the `@` autocomplete menu alongside files.

### MCP prompts as commands

Server prompts appear as `/mcp__servername__promptname` slash commands. Arguments are passed space-separated after the command.

### Automatic reconnection

HTTP/SSE servers: up to 5 attempts with exponential backoff (starting 1s, doubling). Stdio servers are not reconnected automatically.

### Channels (push messages)

MCP servers declaring the `claude/channel` capability can push messages into sessions. Opt in with `--channels` at startup. See Channels documentation for details.

### Managed MCP configuration (enterprise)

**Option 1: Exclusive control** -- deploy `managed-mcp.json` to a system directory to lock down all MCP servers:

| Platform | Path |
| :------- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux/WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

**Option 2: Policy-based control** -- use `allowedMcpServers` and `deniedMcpServers` in managed settings. Each entry matches by exactly one of:

| Restriction type | Field | Matches |
| :--------------- | :---- | :------ |
| By name | `serverName` | Configured server name |
| By command | `serverCommand` | Exact command + args array (stdio only) |
| By URL pattern | `serverUrl` | URL with `*` wildcards (remote only) |

Denylist takes absolute precedence over allowlist. Options 1 and 2 can be combined.

### Environment variables

| Variable | Purpose |
| :------- | :------ |
| `MCP_TIMEOUT` | Server startup timeout in ms (e.g., `MCP_TIMEOUT=10000 claude`) |
| `MAX_MCP_OUTPUT_TOKENS` | Maximum output tokens for MCP tools (default 25,000) |
| `ENABLE_TOOL_SEARCH` | Control tool search behavior (see table above) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set to `false` to disable claude.ai MCP servers |
| `MCP_CLIENT_SECRET` | Pass OAuth client secret non-interactively |

### Windows note

On native Windows (not WSL), stdio servers using `npx` require the `cmd /c` wrapper:

```bash
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) -- full guide covering installing MCP servers (HTTP, SSE, stdio), scopes (local, project, user), environment variable expansion, OAuth authentication (dynamic registration, pre-configured credentials, fixed callback ports, metadata override, scope pinning), dynamic headers, JSON configuration, importing from Claude Desktop, claude.ai connectors, using Claude Code as an MCP server, output limits, elicitation, resources, tool search, prompts as commands, plugin-provided servers, channels, and managed enterprise configuration.

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
