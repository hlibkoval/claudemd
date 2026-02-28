---
name: mcp-doc
description: Complete documentation for connecting Claude Code to external tools via MCP (Model Context Protocol) — installing servers (HTTP, SSE, stdio), scopes (local/project/user), OAuth authentication, managed MCP configuration, allowlists/denylists, plugin-provided MCP, Tool Search, resources, prompts, and using Claude Code as an MCP server.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools via the Model Context Protocol (MCP).

## Quick Reference

MCP servers give Claude Code access to external tools, databases, and APIs. Three transport types are supported: HTTP (recommended for remote), SSE (deprecated), and stdio (local processes).

### CLI Commands

| Command | Description |
|:--------|:-----------|
| `claude mcp add --transport http <name> <url>` | Add remote HTTP server |
| `claude mcp add --transport sse <name> <url>` | Add remote SSE server (deprecated) |
| `claude mcp add [opts] <name> -- <cmd> [args...]` | Add local stdio server |
| `claude mcp add-json <name> '<json>'` | Add server from JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Get details for a server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset project-scope approval choices |
| `claude mcp serve` | Start Claude Code as an MCP server |
| `/mcp` | Check server status / authenticate (inside Claude Code) |

Options (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. Use `--` to separate server name from the command/args passed to the MCP server.

### Installation Scopes

| Scope | Storage | Sharing | Use case |
|:------|:--------|:--------|:---------|
| `local` (default) | `~/.claude.json` (per-project path) | Private | Personal dev servers, sensitive credentials |
| `project` | `.mcp.json` at project root | VCS-committed | Team-shared servers |
| `user` | `~/.claude.json` | Private, all projects | Cross-project personal utilities |

Precedence: local > project > user.

### OAuth Authentication

1. Add server: `claude mcp add --transport http <name> <url>`
2. Authenticate: `/mcp` inside Claude Code, follow browser flow
3. Pre-configured OAuth: use `--client-id`, `--client-secret`, `--callback-port` flags
4. Non-interactive: set `MCP_CLIENT_SECRET` env var

### Environment Variables

| Variable | Effect |
|:---------|:-------|
| `MCP_TIMEOUT` | Server startup timeout in ms (e.g., `MCP_TIMEOUT=10000 claude`) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens per tool output (default: 25,000; warning at 10,000) |
| `ENABLE_TOOL_SEARCH` | Tool search mode: `auto` (default), `auto:<N>`, `true`, `false` |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set `false` to disable Claude.ai MCP servers |

### Env Variable Expansion in `.mcp.json`

Supported in `command`, `args`, `env`, `url`, `headers`:

- `${VAR}` -- expands to value of `VAR`
- `${VAR:-default}` -- uses `default` if `VAR` is unset

### Tool Search

Automatically enabled when MCP tool descriptions exceed 10% of context. Tools are loaded on-demand instead of upfront. Configure via `ENABLE_TOOL_SEARCH`:

| Value | Behavior |
|:------|:---------|
| `auto` | Activates at 10% context threshold (default) |
| `auto:<N>` | Custom threshold percentage |
| `true` | Always enabled |
| `false` | Disabled; all tools loaded upfront |

Requires Sonnet 4+ or Opus 4+. Disable the search tool via `"deny": ["MCPSearch"]`.

### MCP Resources

Reference resources with `@server:protocol://resource/path` in prompts. Resources appear in `@` autocomplete alongside files.

### MCP Prompts as Commands

MCP prompts appear as `/mcp__servername__promptname` commands. Pass arguments space-separated after the command.

### Plugin-Provided MCP Servers

Plugins define servers in `.mcp.json` at plugin root or inline in `plugin.json`. Use `${CLAUDE_PLUGIN_ROOT}` for plugin-relative paths. Servers start/stop with plugin enable/disable (requires Claude Code restart).

### Managed MCP (Enterprise)

**Option 1 -- Exclusive control** (`managed-mcp.json`):

| Platform | Path |
|:---------|:-----|
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux/WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

Users cannot add/modify servers when this file exists.

**Option 2 -- Policy-based** (`allowedMcpServers` / `deniedMcpServers` in managed settings):

| Restriction type | Field | Applies to |
|:-----------------|:------|:-----------|
| By name | `serverName` | All server types |
| By command | `serverCommand` (exact array match) | stdio servers |
| By URL pattern | `serverUrl` (supports `*` wildcards) | Remote servers |

Denylist takes absolute precedence over allowlist. Empty allowlist `[]` = complete lockdown.

### Using Claude Code as an MCP Server

```bash
claude mcp serve
```

Exposes Claude Code tools (View, Edit, LS, etc.) to external MCP clients via stdio transport.

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) -- full MCP documentation covering installation, transports, scopes, authentication, JSON config, managed MCP, Tool Search, resources, prompts, and practical examples

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
