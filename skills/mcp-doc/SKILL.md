---
name: mcp-doc
description: Complete documentation for connecting Claude Code to external tools via the Model Context Protocol (MCP) -- installing MCP servers (HTTP, SSE, stdio transports), managing servers (list, get, remove, /mcp), installation scopes (local, project via .mcp.json, user), scope hierarchy and precedence, environment variable expansion in .mcp.json, OAuth 2.0 authentication (dynamic registration, pre-configured credentials, --client-id, --client-secret, --callback-port, authServerMetadataUrl override), adding servers from JSON (add-json), importing from Claude Desktop (add-from-claude-desktop), using Claude.ai MCP servers (ENABLE_CLAUDEAI_MCP_SERVERS), using Claude Code as an MCP server (mcp serve), MCP output limits (MAX_MCP_OUTPUT_TOKENS), elicitation requests (form mode, URL mode, Elicitation hook), MCP resources (@ mentions), MCP Tool Search (ENABLE_TOOL_SEARCH, auto thresholds, MCPSearch tool), MCP prompts as commands (/mcp__server__prompt), plugin-provided MCP servers (.mcp.json at plugin root, inline in plugin.json, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA), dynamic tool updates (list_changed notifications), push messages with channels (claude/channel capability), managed MCP configuration (managed-mcp.json exclusive control, allowedMcpServers/deniedMcpServers policy with serverName/serverCommand/serverUrl matching, URL wildcards), and practical examples (Sentry, GitHub, PostgreSQL). Load when discussing MCP servers, Model Context Protocol, connecting tools to Claude Code, claude mcp add, .mcp.json, MCP scopes, MCP authentication, OAuth for MCP, MCP resources, MCP prompts, MCP Tool Search, managed MCP, allowedMcpServers, deniedMcpServers, managed-mcp.json, MCP elicitation, MCP output tokens, claude mcp serve, plugin MCP servers, MCP channels, or any integration of external tools with Claude Code.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools via the Model Context Protocol (MCP).

## Quick Reference

MCP is an open standard for AI-tool integrations. MCP servers give Claude Code access to external tools, databases, and APIs.

### Installing MCP Servers

Three transport types are supported:

| Transport | Command | Use case |
|:----------|:--------|:---------|
| **HTTP** (recommended) | `claude mcp add --transport http <name> <url>` | Remote cloud services |
| **SSE** (deprecated) | `claude mcp add --transport sse <name> <url>` | Legacy remote servers |
| **stdio** | `claude mcp add <name> -- <command> [args...]` | Local processes |

All options (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. The `--` separates the name from the command/args passed to the server.

```bash
# HTTP with auth header
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"

# stdio with environment variable
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server
```

Windows (not WSL) requires `cmd /c` wrapper for `npx`-based servers:

```bash
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

### Managing Servers

| Command | Description |
|:--------|:------------|
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Get details for a server |
| `claude mcp remove <name>` | Remove a server |
| `/mcp` (in session) | Check status, authenticate, manage servers |

### Installation Scopes

| Scope | Storage | Shared | Use for |
|:------|:--------|:-------|:--------|
| **local** (default) | `~/.claude.json` under project path | No | Personal/experimental configs, sensitive credentials |
| **project** | `.mcp.json` in project root | Yes, via source control | Team-shared servers |
| **user** | `~/.claude.json` | No | Personal tools across all projects |

Set scope with `--scope local`, `--scope project`, or `--scope user`.

**Precedence:** local > project > user (same-name conflicts resolved in this order).

Project-scoped servers from `.mcp.json` require approval on first use. Reset with `claude mcp reset-project-choices`.

### Environment Variable Expansion in .mcp.json

Supported syntax: `${VAR}` and `${VAR:-default}`. Works in `command`, `args`, `env`, `url`, and `headers` fields.

```json
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

### OAuth Authentication

Claude Code supports OAuth 2.0 for remote MCP servers. Add the server, then run `/mcp` and follow the browser login flow.

| Option | Flag | Purpose |
|:-------|:-----|:--------|
| Fixed callback port | `--callback-port <port>` | Match a pre-registered redirect URI |
| Pre-configured client ID | `--client-id <id>` | Server does not support dynamic registration |
| Client secret | `--client-secret` | Prompts for masked input (or set `MCP_CLIENT_SECRET` env var) |

```bash
claude mcp add --transport http \
  --client-id your-client-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

Override metadata discovery with `authServerMetadataUrl` in the `oauth` object of `.mcp.json` (requires v2.1.64+).

### Adding Servers from JSON

```bash
claude mcp add-json weather-api '{"type":"http","url":"https://api.weather.com/mcp","headers":{"Authorization":"Bearer token"}}'
```

### Importing from Claude Desktop

```bash
claude mcp add-from-claude-desktop   # interactive server picker (macOS and WSL only)
```

### Using Claude.ai MCP Servers

Servers configured in Claude.ai are automatically available when logged in with a Claude.ai account. Disable with `ENABLE_CLAUDEAI_MCP_SERVERS=false`.

### Claude Code as an MCP Server

```bash
claude mcp serve   # expose Claude Code tools to other MCP clients via stdio
```

### MCP Output Limits

| Setting | Default |
|:--------|:--------|
| Warning threshold | 10,000 tokens |
| Maximum output | 25,000 tokens |

Adjust with `MAX_MCP_OUTPUT_TOKENS`:

```bash
export MAX_MCP_OUTPUT_TOKENS=50000
```

### Elicitation

MCP servers can request structured input mid-task. Two modes: **form** (interactive dialog with fields) and **URL** (browser-based flow). Use the `Elicitation` hook to auto-respond.

### MCP Resources

Reference resources from MCP servers using `@server:protocol://resource/path` in prompts:

```text
Can you analyze @github:issue://123 and suggest a fix?
```

Resources are fetched and included as attachments. Type `@` in the prompt to browse available resources.

### MCP Tool Search

Dynamically loads MCP tools on demand when tool definitions would exceed a context threshold. Prevents large tool sets from consuming the context window.

| `ENABLE_TOOL_SEARCH` value | Behavior |
|:----------------------------|:---------|
| (unset) | Enabled by default; disabled for non-first-party `ANTHROPIC_BASE_URL` |
| `true` | Always enabled |
| `auto` | Activates when MCP tools exceed 10% of context |
| `auto:<N>` | Custom threshold (e.g., `auto:5` for 5%) |
| `false` | Disabled; all MCP tools loaded upfront |

Requires Sonnet 4+ or Opus 4+. Disable the search tool itself via `"permissions": {"deny": ["MCPSearch"]}`.

### MCP Prompts as Commands

Server prompts appear as `/mcp__servername__promptname` commands. Pass arguments space-separated:

```text
/mcp__github__pr_review 456
```

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers via `.mcp.json` at the plugin root or inline in `plugin.json`. Plugin servers start automatically when the plugin is enabled. Use `${CLAUDE_PLUGIN_ROOT}` for bundled files and `${CLAUDE_PLUGIN_DATA}` for persistent state. Run `/reload-plugins` to connect/disconnect after enabling/disabling a plugin mid-session.

### Dynamic Tool Updates and Channels

Servers can send `list_changed` notifications to dynamically update available tools. Servers declaring the `claude/channel` capability can push messages into sessions (enable with `--channels` flag at startup).

### Managed MCP Configuration

Two approaches for organizational control:

**Option 1 -- Exclusive control (`managed-mcp.json`):**

Deploy to a system-wide path; users cannot add or modify MCP servers beyond what is defined.

| Platform | Path |
|:---------|:-----|
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux/WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

**Option 2 -- Policy-based control (allowlists/denylists):**

Set `allowedMcpServers` and/or `deniedMcpServers` in managed settings. Each entry restricts by one of:

| Field | Matches |
|:------|:--------|
| `serverName` | Configured server name |
| `serverCommand` | Exact command + args array (stdio only) |
| `serverUrl` | URL pattern with `*` wildcards (remote only) |

Denylist always takes precedence over allowlist.

| `allowedMcpServers` value | Effect |
|:--------------------------|:-------|
| `undefined` (default) | No restrictions |
| `[]` (empty array) | Complete lockdown |
| List of entries | Only matching servers allowed |

Options 1 and 2 can be combined: `managed-mcp.json` provides exclusive control, while allowlists/denylists further filter which managed servers load.

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `MCP_TIMEOUT` | Server startup timeout in ms (e.g., `MCP_TIMEOUT=10000`) |
| `MAX_MCP_OUTPUT_TOKENS` | Maximum output token limit per MCP tool call |
| `ENABLE_TOOL_SEARCH` | Control MCP Tool Search behavior |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Enable/disable Claude.ai MCP servers (default `true`) |
| `MCP_CLIENT_SECRET` | OAuth client secret for non-interactive setup |

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) -- installing MCP servers (HTTP, SSE, stdio transports with examples), option ordering, managing servers (list, get, remove, /mcp), dynamic tool updates (list_changed), push messages with channels, installation scopes (local, project, user), scope hierarchy and precedence, environment variable expansion in .mcp.json (${VAR} and ${VAR:-default} syntax), practical examples (Sentry, GitHub, PostgreSQL), OAuth 2.0 authentication (dynamic registration, pre-configured credentials with --client-id/--client-secret/--callback-port, MCP_CLIENT_SECRET env var, authServerMetadataUrl override), adding servers from JSON (add-json), importing from Claude Desktop (add-from-claude-desktop, macOS/WSL only), using Claude.ai MCP servers (ENABLE_CLAUDEAI_MCP_SERVERS), using Claude Code as an MCP server (mcp serve, Claude Desktop config), MCP output limits and warnings (MAX_MCP_OUTPUT_TOKENS, default 25000 tokens), elicitation requests (form mode, URL mode, Elicitation hook), MCP resources (@ mentions, autocomplete), MCP Tool Search (ENABLE_TOOL_SEARCH, auto thresholds, MCPSearch disallowedTools, server instructions for discoverability), MCP prompts as commands (/mcp__server__prompt), plugin-provided MCP servers (.mcp.json at plugin root, inline plugin.json, CLAUDE_PLUGIN_ROOT/CLAUDE_PLUGIN_DATA variables, lifecycle, /reload-plugins), managed MCP configuration (managed-mcp.json exclusive control with system-wide paths, policy-based control with allowedMcpServers/deniedMcpServers using serverName/serverCommand/serverUrl matching, URL wildcards, command exact matching, denylist precedence, combining both options), Windows npx wrapper requirement

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
