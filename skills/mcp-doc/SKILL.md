---
name: mcp-doc
description: Complete documentation for Claude Code MCP (Model Context Protocol) integration -- installing and configuring MCP servers (HTTP, SSE, stdio), transport types, installation scopes (local, project, user), OAuth authentication (dynamic registration, pre-configured credentials, callback ports, metadata override), CLI commands (add, add-json, remove, list, get, serve, add-from-claude-desktop), .mcp.json project configuration with environment variable expansion, plugin-provided MCP servers, managed MCP configuration (managed-mcp.json, allowlists/denylists with serverName/serverCommand/serverUrl), MCP resources and @ mentions, MCP Tool Search for scaling, MCP prompts as commands, output limits (MAX_MCP_OUTPUT_TOKENS), importing servers from Claude Desktop, using Claude.ai MCP servers, and using Claude Code itself as an MCP server. Load when discussing MCP setup, MCP server configuration, MCP authentication, MCP tools, /mcp command, or connecting Claude Code to external tools and services.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools via the Model Context Protocol (MCP).

## Quick Reference

MCP (Model Context Protocol) is an open standard for AI-tool integrations. MCP servers give Claude Code access to external tools, databases, and APIs. Claude Code supports three transport types for connecting to MCP servers.

### Transport Types

| Transport | Flag | Use case | Example |
|:----------|:-----|:---------|:--------|
| HTTP (Streamable HTTP) | `--transport http` | Remote cloud services (recommended) | `claude mcp add --transport http notion https://mcp.notion.com/mcp` |
| SSE (Server-Sent Events) | `--transport sse` | Remote servers (deprecated; use HTTP) | `claude mcp add --transport sse asana https://mcp.asana.com/sse` |
| stdio | `--transport stdio` | Local processes needing direct system access | `claude mcp add --transport stdio db -- npx -y @bytebase/dbhub --dsn "..."` |

Options (`--transport`, `--env`, `--scope`, `--header`) must come before the server name. Use `--` to separate the server name from the command/args for stdio servers.

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude mcp add [options] <name> <url>` | Add HTTP/SSE server |
| `claude mcp add [options] <name> -- <cmd> [args]` | Add stdio server |
| `claude mcp add-json <name> '<json>'` | Add server from JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS/WSL) |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Get details for a server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset project-scope approval choices |
| `claude mcp serve` | Start Claude Code itself as an MCP server |
| `/mcp` | In-session: check status, authenticate, manage servers |

### Installation Scopes

| Scope | Storage | Shared | Description |
|:------|:--------|:-------|:------------|
| `local` (default) | `~/.claude.json` (project path) | No | Private to you, current project only |
| `project` | `.mcp.json` in project root | Yes (commit to VCS) | Team-shared, all members get same tools |
| `user` | `~/.claude.json` | No | Private to you, all projects |
| managed | `managed-mcp.json` in system dir | Admin-deployed | Organization-wide, read-only |

Precedence: local > project > user.

### Project-Scope `.mcp.json` Format

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

Supports environment variable expansion: `${VAR}` and `${VAR:-default}` in `command`, `args`, `env`, `url`, and `headers` fields.

### JSON Config Format (`add-json`)

```bash
# HTTP server
claude mcp add-json weather-api '{"type":"http","url":"https://api.weather.com/mcp","headers":{"Authorization":"Bearer token"}}'

# stdio server
claude mcp add-json local-tool '{"type":"stdio","command":"/path/to/cli","args":["--flag"],"env":{"KEY":"val"}}'
```

### OAuth Authentication

Many remote MCP servers require OAuth 2.0. Use `/mcp` in Claude Code to authenticate via browser. Tokens are stored securely and refreshed automatically.

| Scenario | Command |
|:---------|:--------|
| Dynamic client registration | `claude mcp add --transport http myserver https://mcp.example.com/mcp` |
| Fixed callback port | Add `--callback-port 8080` |
| Pre-configured credentials | Add `--client-id <id> --client-secret` |
| Client secret via env var | `MCP_CLIENT_SECRET=secret claude mcp add --transport http --client-id <id> --client-secret ...` |
| Override metadata discovery | Set `oauth.authServerMetadataUrl` in `.mcp.json` config |

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers via `.mcp.json` at the plugin root or inline in `plugin.json`. Plugin servers start automatically when the plugin is enabled and appear in `/mcp`. Use `${CLAUDE_PLUGIN_ROOT}` for plugin-relative paths.

### Claude.ai MCP Servers

Servers added at claude.ai/settings/connectors are automatically available when logged in with a Claude.ai account. Disable with `ENABLE_CLAUDEAI_MCP_SERVERS=false`.

### Using Claude Code as an MCP Server

```bash
claude mcp serve
```

Exposes Claude Code's tools (View, Edit, LS, etc.) to other MCP clients such as Claude Desktop.

### MCP Resources (@ Mentions)

Type `@` to see resources from connected servers. Reference format: `@server:protocol://resource/path`. Resources are fetched and included as attachments.

### MCP Prompts as Commands

MCP server prompts appear as `/mcp__servername__promptname` commands. Pass arguments space-separated after the command.

### MCP Tool Search

Automatically activates when MCP tool definitions exceed 10% of context window. Tools are loaded on-demand instead of upfront.

| `ENABLE_TOOL_SEARCH` | Behavior |
|:----------------------|:---------|
| `auto` (default) | Activates when MCP tools exceed 10% of context |
| `auto:<N>` | Custom threshold (e.g., `auto:5` for 5%) |
| `true` | Always enabled |
| `false` | Disabled, all tools loaded upfront |

Requires Sonnet 4+ or Opus 4+. Disable via `disallowedTools: ["MCPSearch"]` in settings.

### Output Limits

| Setting | Default | Description |
|:--------|:--------|:------------|
| Warning threshold | 10,000 tokens | Warning displayed when exceeded |
| Max output | 25,000 tokens | Hard limit on MCP tool output |
| `MAX_MCP_OUTPUT_TOKENS` | env var | Override the max limit |
| `MCP_TIMEOUT` | env var | Startup timeout in ms (e.g., `MCP_TIMEOUT=10000`) |

### Dynamic Tool Updates

Claude Code supports MCP `list_changed` notifications, automatically refreshing available tools when a server updates its capabilities.

### Managed MCP Configuration

**Option 1 -- Exclusive control (`managed-mcp.json`)**

Deploy to system directory to take exclusive control over all MCP servers:

| Platform | Path |
|:---------|:-----|
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux/WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

Uses the same format as `.mcp.json`. Users cannot add/modify servers when this file exists.

**Option 2 -- Policy-based control (allowlists/denylists)**

Set in managed settings to restrict which servers users can add:

| Setting | Undefined | Empty `[]` | With entries |
|:--------|:----------|:-----------|:-------------|
| `allowedMcpServers` | No restrictions | Complete lockdown | Only matching servers allowed |
| `deniedMcpServers` | Nothing blocked | Nothing blocked | Listed servers blocked |

Restriction types: `serverName` (by name), `serverCommand` (exact command array match for stdio), `serverUrl` (URL pattern with `*` wildcards for remote servers). Denylist takes absolute precedence over allowlist.

### Windows Note

On native Windows (not WSL), stdio servers using `npx` require the `cmd /c` wrapper:

```bash
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) -- installing MCP servers (HTTP, SSE, stdio), transport options, scopes, OAuth authentication, JSON configuration, importing from Claude Desktop, Claude.ai servers, using Claude Code as an MCP server, MCP resources, Tool Search, MCP prompts, output limits, managed MCP configuration, allowlists/denylists

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
