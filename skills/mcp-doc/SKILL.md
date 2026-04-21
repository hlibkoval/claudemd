---
name: mcp-doc
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools via the Model Context Protocol (MCP).

## Quick Reference

### CLI Commands

| Command | Description |
|---|---|
| `claude mcp add --transport http <name> <url>` | Add a remote HTTP server (recommended) |
| `claude mcp add --transport sse <name> <url>` | Add a remote SSE server (deprecated) |
| `claude mcp add --transport stdio <name> -- <cmd>` | Add a local stdio server |
| `claude mcp add-json <name> '<json>'` | Add a server from JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Get details for a specific server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset project-scope approval choices |
| `claude mcp serve` | Start Claude Code itself as an MCP server |
| `/mcp` | (in session) Check server status, authenticate OAuth |

### `claude mcp add` Options

| Flag | Description |
|---|---|
| `--transport http\|sse\|stdio` | Transport type (default: stdio) |
| `--scope local\|project\|user` | Config scope (default: local) |
| `--env KEY=value` | Set environment variable for server |
| `--header "Key: Value"` | Add request header (HTTP/SSE) |
| `--callback-port <port>` | Fix OAuth callback port |
| `--client-id <id>` | Pre-configured OAuth client ID |
| `--client-secret` | Prompt for OAuth client secret (masked) |

### Scope Summary

| Scope | Loads in | Shared | Stored in |
|---|---|---|---|
| `local` (default) | Current project only | No | `~/.claude.json` |
| `project` | Current project only | Yes (via `.mcp.json`) | `.mcp.json` in project root |
| `user` | All your projects | No | `~/.claude.json` |

### Scope Precedence (highest to lowest)

1. Local scope
2. Project scope
3. User scope
4. Plugin-provided servers
5. Claude.ai connectors

### Environment Variables

| Variable | Default | Description |
|---|---|---|
| `MCP_TIMEOUT` | — | MCP server startup timeout in ms (e.g., `10000`) |
| `MAX_MCP_OUTPUT_TOKENS` | 25000 | Max tokens per MCP tool output (warning at 10,000) |
| `ENABLE_TOOL_SEARCH` | (unset) | Tool search mode: `true`, `auto`, `auto:<N>`, `false` |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | `true` | Set to `false` to disable Claude.ai connector servers |
| `MCP_CLIENT_SECRET` | — | OAuth client secret for CI (skips interactive prompt) |

### Tool Search Modes (`ENABLE_TOOL_SEARCH`)

| Value | Behavior |
|---|---|
| (unset) | All MCP tools deferred; falls back to upfront for non-first-party `ANTHROPIC_BASE_URL` |
| `true` | All MCP tools deferred, including for non-first-party base URLs |
| `auto` | Threshold mode: load upfront if within 10% of context window, defer otherwise |
| `auto:<N>` | Threshold mode with custom percentage (0–100) |
| `false` | All MCP tools loaded upfront, no deferral |

### `.mcp.json` Format

```json
{
  "mcpServers": {
    "my-server": {
      "command": "/path/to/server",
      "args": ["--flag"],
      "env": { "KEY": "${ENV_VAR:-default}" }
    }
  }
}
```

Env var expansion syntax in `.mcp.json`: `${VAR}` and `${VAR:-default}`. Supported in `command`, `args`, `env`, `url`, and `headers`.

### OAuth Config in `.mcp.json`

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
        "scopes": "channels:read chat:write"
      }
    }
  }
}
```

### `headersHelper` (dynamic auth)

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

The helper must write a JSON object of string key-value pairs to stdout. Runs with a 10-second timeout. Env vars available: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`.

### Per-Tool Output Size (`anthropic/maxResultSizeChars`)

MCP server authors can set a per-tool override in `tools/list` response:

```json
{
  "name": "get_schema",
  "description": "Returns the full database schema",
  "_meta": {
    "anthropic/maxResultSizeChars": 200000
  }
}
```

Ceiling: 500,000 characters. Applies to text content; image content still subject to `MAX_MCP_OUTPUT_TOKENS`.

### Managed MCP (Enterprise)

| Option | Location | Effect |
|---|---|---|
| `managed-mcp.json` | macOS: `/Library/Application Support/ClaudeCode/`; Linux/WSL: `/etc/claude-code/`; Windows: `C:\Program Files\ClaudeCode\` | Exclusive control — users cannot add/modify servers |
| `allowedMcpServers` in managed settings | Managed settings file | Allowlist by `serverName`, `serverCommand`, or `serverUrl` |
| `deniedMcpServers` in managed settings | Managed settings file | Denylist; takes absolute precedence over allowlist |

### MCP Resource References

Use `@server:protocol://resource/path` syntax in prompts to reference MCP resources. Type `@` to see autocomplete. Resources are fetched automatically and included as attachments.

### MCP Prompts as Commands

MCP prompts appear as `/mcp__servername__promptname` commands. Pass arguments space-separated after the command name.

### Reconnection Behavior

HTTP/SSE servers: automatic reconnect with exponential backoff — up to 5 attempts, starting at 1-second delay, doubling each time. Stdio servers: not auto-reconnected (local processes).

### Plugin-Provided MCP Servers

Plugins bundle MCP servers via `.mcp.json` at plugin root or inline in `plugin.json`. Use `${CLAUDE_PLUGIN_ROOT}` for bundled files and `${CLAUDE_PLUGIN_DATA}` for persistent state. Run `/reload-plugins` to connect/disconnect after enabling/disabling a plugin mid-session.

### Windows (Native) — Stdio Servers

Wrap `npx` commands with `cmd /c` to avoid "Connection closed" errors:

```
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — Full guide: installing, scoping, authenticating, and managing MCP servers in Claude Code

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
