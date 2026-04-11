---
name: mcp-doc
description: Complete documentation for connecting Claude Code to external tools and data sources via the Model Context Protocol (MCP). Covers installing MCP servers (HTTP, SSE, stdio), configuration scopes, OAuth authentication, plugin-provided servers, managed MCP policies, tool search, resources, prompts, elicitation, and using Claude Code itself as an MCP server.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools via the Model Context Protocol (MCP).

## Quick Reference

### Transport types

| Transport | When to use | Add command |
| --- | --- | --- |
| `http` (recommended for remote) | Cloud-based services | `claude mcp add --transport http <name> <url>` |
| `sse` (deprecated) | Legacy remote servers | `claude mcp add --transport sse <name> <url>` |
| `stdio` | Local processes / custom scripts | `claude mcp add --transport stdio <name> -- <cmd> [args...]` |

**Option ordering rule:** all flags (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. Then `--` separates the name from the command and its args.

### Core CLI commands

| Command | Purpose |
| --- | --- |
| `claude mcp add [opts] <name> ...` | Add a server |
| `claude mcp add-json <name> '<json>'` | Add a server from a raw JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS / WSL only) |
| `claude mcp list` | List configured servers |
| `claude mcp get <name>` | Show details for one server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp serve` | Run Claude Code itself as a stdio MCP server |
| `claude mcp reset-project-choices` | Reset approval choices for `.mcp.json` servers |
| `/mcp` (inside Claude Code) | Check status, authenticate, manage servers |

### Installation scopes

| Scope | Loads in | Shared with team | Stored in |
| --- | --- | --- | --- |
| `local` (default) | Current project only | No | `~/.claude.json` |
| `project` | Current project only | Yes (via VCS) | `.mcp.json` at project root |
| `user` | All your projects | No | `~/.claude.json` |

**Precedence** (highest to lowest): local > project > user > plugin-provided > claude.ai connectors. Scopes match duplicates by name; plugins/connectors match by endpoint.

Project-scoped servers require user approval before first use (security gate).

### Environment variable expansion in `.mcp.json`

Supported syntax:

- `${VAR}` - value of environment variable `VAR`
- `${VAR:-default}` - `VAR` if set, otherwise `default`

Expandable fields: `command`, `args`, `env`, `url`, `headers`. Missing required vars fail the config parse.

### Key environment variables

| Variable | Purpose |
| --- | --- |
| `MCP_TIMEOUT` | Server startup timeout in ms (e.g. `MCP_TIMEOUT=10000`) |
| `MAX_MCP_OUTPUT_TOKENS` | Raise per-tool output cap (default 25,000; warning fires at 10,000) |
| `ENABLE_TOOL_SEARCH` | Control MCP tool search behavior (see table below) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set `false` to disable importing claude.ai connectors |
| `MCP_CLIENT_SECRET` | Pass OAuth client secret non-interactively |

### `ENABLE_TOOL_SEARCH` modes

| Value | Behavior |
| --- | --- |
| (unset) | All MCP tools deferred; falls back to upfront load for non-first-party `ANTHROPIC_BASE_URL` |
| `true` | All MCP tools deferred, including for proxied hosts |
| `auto` | Load upfront if tools fit within 10% of context window, defer the overflow |
| `auto:<N>` | Threshold mode with custom percentage (0-100) |
| `false` | All MCP tools loaded upfront, no deferral |

Tool search requires Sonnet 4+ or Opus 4+ (Haiku does not support it). Server authors should write concise (< 2 KB) server instructions that describe when Claude should search for their tools.

### JSON server config schema (core fields)

```json
{
  "mcpServers": {
    "my-server": {
      "type": "http",            // "http" | "sse" | "stdio"
      "url": "https://...",      // HTTP/SSE only
      "headers": { "Authorization": "Bearer ${TOKEN}" },
      "command": "/path/to/bin", // stdio only
      "args": ["--flag"],        // stdio only
      "env": { "KEY": "value" },
      "oauth": {
        "clientId": "...",
        "callbackPort": 8080,
        "authServerMetadataUrl": "https://.../.well-known/openid-configuration"
      },
      "headersHelper": "/opt/bin/get-headers.sh"
    }
  }
}
```

### OAuth flags (HTTP / SSE only)

| Flag | Purpose |
| --- | --- |
| `--callback-port <port>` | Fix OAuth callback port to `http://localhost:PORT/callback` |
| `--client-id <id>` | Pre-configured OAuth client ID |
| `--client-secret` | Prompt for client secret (masked input); or set `MCP_CLIENT_SECRET` env var |

Tokens are stored in the OS keychain (macOS) or credentials file. Use "Clear authentication" in `/mcp` to revoke.

### Dynamic auth headers (`headersHelper`)

Runs a shell command on each connection; stdout must be a JSON object of string key/value pairs. 10-second timeout, no caching. Claude Code sets `CLAUDE_CODE_MCP_SERVER_NAME` and `CLAUDE_CODE_MCP_SERVER_URL` when executing the helper. Requires workspace trust acceptance for project/local scope.

### Plugin-provided MCP servers

Plugins can ship MCP servers in `.mcp.json` at the plugin root, or inline under `mcpServers` in `plugin.json`. They start automatically when the plugin is enabled. Use:

- `${CLAUDE_PLUGIN_ROOT}` for bundled plugin files
- `${CLAUDE_PLUGIN_DATA}` for persistent state that survives plugin updates
- `/reload-plugins` to connect/disconnect servers after enabling or disabling a plugin mid-session

### Managed / enterprise configuration

Two mutually-exclusive approaches:

1. **`managed-mcp.json` (exclusive control)** - same format as `.mcp.json`, deployed to:
   - macOS: `/Library/Application Support/ClaudeCode/managed-mcp.json`
   - Linux / WSL: `/etc/claude-code/managed-mcp.json`
   - Windows: `C:\Program Files\ClaudeCode\managed-mcp.json`

   Users cannot add, modify, or use any other MCP servers.

2. **Allowlists / denylists** via managed settings (`allowedMcpServers` / `deniedMcpServers`). Each entry must have exactly one of:
   - `serverName` - match configured server name
   - `serverCommand` - exact array match of stdio command + args
   - `serverUrl` - URL pattern with `*` wildcards (e.g. `https://*.internal.corp/*`)

   If any `serverCommand` entries exist, stdio servers **must** match one. If any `serverUrl` entries exist, remote servers **must** match one. Command restrictions never apply to remote servers.

### MCP resources and prompts

- **Resources**: reference with `@server:protocol://resource/path` (e.g. `@github:issue://123`). Type `@` for autocomplete.
- **Prompts**: surface as slash commands `/mcp__servername__promptname`, with space-separated args (e.g. `/mcp__jira__create_issue "Bug" high`).

### Output size control (for server authors)

Set `_meta["anthropic/maxResultSizeChars"]` on a tool in `tools/list` to raise its persist-to-disk threshold. Hard ceiling: 500,000 characters. Applies to text content only; image data is still bounded by `MAX_MCP_OUTPUT_TOKENS`.

### Elicitation

Servers can request structured input mid-task. Claude Code shows a form dialog (field inputs) or opens a URL (browser auth flow) automatically, no configuration needed. To auto-respond, use the `Elicitation` hook.

### Dynamic tool updates

MCP `list_changed` notifications are honored: servers can update their tools, prompts, and resources without disconnect/reconnect.

### Windows gotcha

On native Windows (not WSL), stdio servers using `npx` must be wrapped:

```bash
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

Without `cmd /c` you get "Connection closed" errors.

## Full Documentation

For the complete official documentation, see the reference file:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) - full guide: transports, scopes, OAuth, plugin-provided servers, managed configuration, tool search, resources, prompts, elicitation, and running Claude Code as an MCP server.

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
