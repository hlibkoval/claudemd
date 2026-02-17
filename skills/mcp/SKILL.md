---
name: mcp
description: Reference documentation for Claude Code MCP (Model Context Protocol) integration — connecting to external tools, configuring MCP servers (HTTP, SSE, stdio), managing scopes, authentication, plugin MCP servers, managed configurations, tool search, resources, and prompts.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools via the Model Context Protocol (MCP).

## Quick Reference

MCP servers give Claude Code access to external tools, databases, and APIs through the [Model Context Protocol](https://modelcontextprotocol.io/introduction).

### Adding Servers

```bash
# HTTP (recommended for remote servers)
claude mcp add --transport http <name> <url>

# SSE (deprecated — use HTTP instead)
claude mcp add --transport sse <name> <url>

# Stdio (local processes)
claude mcp add --transport stdio <name> -- <command> [args...]
claude mcp add --transport stdio --env API_KEY=xxx myserver -- npx -y my-mcp-server

# From JSON config
claude mcp add-json <name> '<json>'

# Import from Claude Desktop (macOS / WSL only)
claude mcp add-from-claude-desktop
```

**Option ordering**: All flags (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. `--` separates the name from the command/args passed to the server.

### Managing Servers

```bash
claude mcp list                        # List all servers
claude mcp get <name>                  # Server details
claude mcp remove <name>              # Remove a server
claude mcp reset-project-choices      # Reset .mcp.json approval prompts
/mcp                                   # In-session: status, auth, reconnect
```

### Installation Scopes

| Scope     | Flag             | Stored in               | Visibility                  |
|:----------|:-----------------|:------------------------|:----------------------------|
| `local`   | `--scope local`  | `~/.claude.json`        | You only, current project (default) |
| `project` | `--scope project`| `.mcp.json` (repo root) | Team (commit to VCS)        |
| `user`    | `--scope user`   | `~/.claude.json`        | You, all projects           |

**Precedence**: local > project > user (same-name conflicts).

### .mcp.json Format

```json
{
  "mcpServers": {
    "my-server": {
      "command": "/path/to/server",
      "args": [],
      "env": {}
    }
  }
}
```

Supports environment variable expansion: `${VAR}` and `${VAR:-default}` in `command`, `args`, `env`, `url`, and `headers`.

### Authentication (OAuth 2.0)

1. Add server: `claude mcp add --transport http <name> <url>`
2. Authenticate: run `/mcp` inside Claude Code, follow browser flow
3. Tokens are stored securely and refreshed automatically

**Pre-configured OAuth** (when dynamic registration is unsupported):

```bash
claude mcp add --transport http \
  --client-id <id> --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

Set `MCP_CLIENT_SECRET` env var to skip the interactive secret prompt. Client secret is stored in system keychain (macOS) or credentials file.

### Plugin MCP Servers

Plugins can bundle MCP servers via `.mcp.json` at the plugin root or inline in `plugin.json` using `mcpServers`. Use `${CLAUDE_PLUGIN_ROOT}` for plugin-relative paths. Plugin servers start when the plugin is enabled; restart Claude Code after MCP config changes.

### MCP Resources

Reference MCP resources with `@` mentions: `@server:protocol://path`

```
> Analyze @github:issue://123 and suggest a fix
> Compare @postgres:schema://users with @docs:file://database/user-model
```

### MCP Prompts as Commands

MCP prompts appear as `/mcp__servername__promptname` commands:

```
> /mcp__github__list_prs
> /mcp__github__pr_review 456
```

### Tool Search

Automatically defers MCP tool loading when tool definitions exceed 10% of the context window.

| `ENABLE_TOOL_SEARCH` | Behavior                                         |
|:---------------------|:-------------------------------------------------|
| `auto`               | Activate at 10% of context (default)             |
| `auto:<N>`           | Activate at custom N% threshold                  |
| `true`               | Always enabled                                   |
| `false`              | Disabled, all tools loaded upfront               |

Requires Sonnet 4+ or Opus 4+ (not Haiku). Disable via `disallowedTools: ["MCPSearch"]`.

### Output Limits

| Setting                | Default       | Description                    |
|:-----------------------|:--------------|:-------------------------------|
| Warning threshold      | 10,000 tokens | Displays a warning             |
| `MAX_MCP_OUTPUT_TOKENS`| 25,000 tokens | Maximum allowed output         |
| `MCP_TIMEOUT`          | (varies)      | Server startup timeout (ms)    |

### Managed MCP (Enterprise)

**Option 1 — Exclusive control** via `managed-mcp.json` (system-wide, admin-only paths):

| Platform    | Path                                                       |
|:------------|:-----------------------------------------------------------|
| macOS       | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux / WSL | `/etc/claude-code/managed-mcp.json`                        |
| Windows     | `C:\Program Files\ClaudeCode\managed-mcp.json`             |

Users cannot add/modify servers when this file exists. Same format as `.mcp.json`.

**Option 2 — Policy-based** via managed settings `allowedMcpServers` / `deniedMcpServers`:

- Restrict by `serverName`, `serverCommand` (exact array match), or `serverUrl` (wildcard `*` supported).
- Denylist takes absolute precedence over allowlist.
- Empty allowlist `[]` = complete lockdown. Undefined = no restrictions.
- Both options can be combined.

### Using Claude Code as an MCP Server

Run `claude mcp serve` to expose Claude Code's tools (View, Edit, LS, etc.) to other MCP clients. Configure in Claude Desktop with `{"type":"stdio","command":"claude","args":["mcp","serve"]}`.

### Windows Note

On native Windows (not WSL), wrap `npx` with `cmd /c`: `-- cmd /c npx -y @some/package`.

## Full Documentation

For the complete official documentation, see the reference files:

- [MCP Integration Guide](references/claude-code-mcp.md) — transports, scopes, authentication, OAuth, plugin MCP servers, resources, prompts, tool search, managed configuration, and practical examples

## Sources

- MCP Integration: https://code.claude.com/docs/en/mcp.md
