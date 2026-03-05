---
name: mcp-doc
description: Complete documentation for connecting Claude Code to external tools via Model Context Protocol (MCP) — installing servers (HTTP, SSE, stdio), scopes (local, project, user), OAuth authentication, managed MCP configuration, plugin-provided MCP servers, MCP resources & prompts, tool search, output limits, and JSON configuration. Load when discussing MCP setup, MCP servers, MCP scopes, MCP authentication, or managed MCP policies.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools via the Model Context Protocol (MCP).

## Quick Reference

MCP (Model Context Protocol) is an open standard for AI-tool integrations. MCP servers give Claude Code access to external tools, databases, and APIs.

### Installing MCP Servers

Three transport types are supported:

| Transport | Command | Use case |
|:----------|:--------|:---------|
| HTTP (recommended) | `claude mcp add --transport http <name> <url>` | Remote cloud services |
| SSE (deprecated) | `claude mcp add --transport sse <name> <url>` | Legacy remote servers |
| stdio | `claude mcp add <name> -- <command> [args...]` | Local processes, custom scripts |

Options (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. Use `--` to separate the server name from the command/args for stdio servers.

### Managing Servers

```bash
claude mcp list                  # List all configured servers
claude mcp get <name>            # Get details for a server
claude mcp remove <name>         # Remove a server
/mcp                             # Check server status (in Claude Code)
```

### Scopes

| Scope | Flag | Storage | Visibility |
|:------|:-----|:--------|:-----------|
| Local (default) | `--scope local` | `~/.claude.json` (per-project path) | Private, current project only |
| Project | `--scope project` | `.mcp.json` (project root, version-controlled) | Shared with team |
| User | `--scope user` | `~/.claude.json` | Private, all projects |

**Precedence**: local > project > user (higher scope overrides lower when names collide).

### OAuth Authentication

1. Add an HTTP server: `claude mcp add --transport http <name> <url>`
2. Run `/mcp` in Claude Code and follow the browser login flow
3. Tokens are stored securely and refreshed automatically

**Fixed callback port**: `--callback-port <port>` to match a pre-registered redirect URI.

**Pre-configured credentials**: `--client-id <id> --client-secret` when the server does not support dynamic client registration.

**Override metadata discovery**: Set `authServerMetadataUrl` in the `oauth` object of `.mcp.json` to bypass standard `/.well-known/oauth-authorization-server` discovery.

### JSON Configuration

```bash
claude mcp add-json <name> '<json>'
```

Supported fields: `type` (http/stdio/sse), `url`, `command`, `args`, `env`, `headers`, `oauth`.

### Environment Variable Expansion in `.mcp.json`

| Syntax | Behavior |
|:-------|:---------|
| `${VAR}` | Expands to the value of `VAR` |
| `${VAR:-default}` | Uses `VAR` if set, otherwise `default` |

Expansion works in: `command`, `args`, `env`, `url`, `headers`.

### Import from Claude Desktop

```bash
claude mcp add-from-claude-desktop   # Interactive selection (macOS and WSL only)
```

### Claude.ai MCP Servers

Servers configured at `claude.ai/settings/connectors` are automatically available in Claude Code when logged in with a Claude.ai account. Disable with `ENABLE_CLAUDEAI_MCP_SERVERS=false`.

### Claude Code as MCP Server

```bash
claude mcp serve   # Start Claude Code as a stdio MCP server
```

Exposes Claude Code's tools (Read, Edit, LS, etc.) to other MCP clients.

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers via `.mcp.json` at plugin root or inline in `plugin.json` under `mcpServers`. Plugin servers start automatically when the plugin is enabled and appear in `/mcp`. Use `${CLAUDE_PLUGIN_ROOT}` for plugin-relative paths.

### MCP Resources

Reference MCP resources with `@server:protocol://resource/path` in prompts. Type `@` to browse available resources from connected servers.

### MCP Prompts as Commands

MCP server prompts appear as `/mcp__servername__promptname` commands. Type `/` to discover them. Pass arguments space-separated after the command.

### MCP Tool Search

Automatically defers MCP tool loading when tool definitions exceed 10% of context window.

| `ENABLE_TOOL_SEARCH` value | Behavior |
|:---------------------------|:---------|
| `auto` (default) | Activates when MCP tools exceed 10% of context |
| `auto:<N>` | Custom threshold (e.g., `auto:5` for 5%) |
| `true` | Always enabled |
| `false` | Disabled, all tools loaded upfront |

Requires Sonnet 4+ or Opus 4+ (Haiku not supported). Disable the search tool specifically with `permissions.deny: ["MCPSearch"]`.

### Output Limits

| Setting | Default | Environment variable |
|:--------|:--------|:---------------------|
| Warning threshold | 10,000 tokens | `MAX_MCP_OUTPUT_TOKENS` |
| Maximum limit | 25,000 tokens | `MAX_MCP_OUTPUT_TOKENS` |

### Managed MCP Configuration (Enterprise)

**Option 1 -- Exclusive control** (`managed-mcp.json`):

| Platform | Path |
|:---------|:-----|
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux / WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

Deploys a fixed set of servers; users cannot add or modify MCP servers.

**Option 2 -- Policy-based control** (in managed settings):

| Setting | Behavior |
|:--------|:---------|
| `allowedMcpServers` undefined | No restrictions (default) |
| `allowedMcpServers: []` | Complete lockdown |
| `allowedMcpServers: [...]` | Only matching servers allowed |
| `deniedMcpServers: [...]` | Matching servers blocked (takes absolute precedence over allowlist) |

Each entry uses exactly one of: `serverName`, `serverCommand` (exact array match for stdio), or `serverUrl` (wildcard `*` supported for remote servers).

### Useful Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `MCP_TIMEOUT` | Server startup timeout in ms (e.g., `MCP_TIMEOUT=10000`) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens for MCP tool output (default 25000) |
| `ENABLE_TOOL_SEARCH` | Control tool search behavior |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Enable/disable Claude.ai MCP servers |

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) -- installing servers (HTTP, SSE, stdio), scopes, OAuth authentication, JSON configuration, importing from Desktop, Claude Code as MCP server, plugin MCP servers, resources, prompts, tool search, output limits, and managed MCP configuration

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
