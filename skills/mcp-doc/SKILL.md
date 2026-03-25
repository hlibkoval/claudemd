---
name: mcp-doc
description: Complete documentation for Claude Code MCP (Model Context Protocol) integration -- connecting to external tools and data sources via MCP servers. Covers transport types (HTTP recommended, SSE deprecated, stdio for local), installation commands (claude mcp add with --transport http/sse/stdio, --env, --scope, --header flags, option ordering with -- separator), installation scopes (local default in ~/.claude.json, project in .mcp.json checked into git, user in ~/.claude.json cross-project), scope hierarchy and precedence (local > project > user), managing servers (claude mcp list/get/remove, /mcp interactive command), JSON configuration (claude mcp add-json, .mcp.json format with mcpServers object), environment variable expansion in .mcp.json (${VAR} and ${VAR:-default} syntax in command/args/env/url/headers), importing from Claude Desktop (claude mcp add-from-claude-desktop on macOS/WSL), Claude.ai MCP servers (auto-available when logged in with Claude.ai account, ENABLE_CLAUDEAI_MCP_SERVERS=false to disable), Claude Code as MCP server (claude mcp serve for stdio, Claude Desktop config), OAuth 2.0 authentication (/mcp to authenticate, token storage and refresh, --callback-port for fixed port, --client-id and --client-secret for pre-configured credentials, MCP_CLIENT_SECRET env var for CI, authServerMetadataUrl override, CIMD auto-discovery), dynamic headers (headersHelper command in .mcp.json for Kerberos/SSO/short-lived tokens, JSON stdout, 10s timeout), plugin-provided MCP servers (.mcp.json at plugin root or inline in plugin.json, ${CLAUDE_PLUGIN_ROOT}/${CLAUDE_PLUGIN_DATA}, automatic lifecycle, /reload-plugins), MCP output limits (10000 token warning, MAX_MCP_OUTPUT_TOKENS default 25000), elicitation (form mode and URL mode for structured input from servers mid-task, Elicitation hook for auto-response), MCP resources (@ mention with @server:protocol://path, autocomplete, multiple references), MCP Tool Search (auto-enabled when tools exceed 10% context, ENABLE_TOOL_SEARCH with true/auto/auto:N/false values, deferred loading, server instructions for discoverability, tool_reference block model requirement), MCP prompts as commands (/mcp__servername__promptname format, arguments space-separated), dynamic tool updates (list_changed notifications), push messages with channels (claude/channel capability, --channels flag), managed MCP configuration (managed-mcp.json for exclusive control at /Library/Application Support/ClaudeCode/ or /etc/claude-code/ or C:\Program Files\ClaudeCode\, policy-based allowedMcpServers/deniedMcpServers in managed settings with serverName/serverCommand/serverUrl matching, URL wildcards, command exact matching, denylist absolute precedence), MCP_TIMEOUT for startup timeout, project-scoped approval (claude mcp reset-project-choices), Windows npx cmd /c wrapper. Load when discussing MCP, Model Context Protocol, MCP servers, claude mcp add, claude mcp remove, claude mcp list, .mcp.json, MCP configuration, MCP scopes, MCP authentication, OAuth MCP, MCP resources, MCP prompts, MCP Tool Search, ENABLE_TOOL_SEARCH, managed-mcp.json, allowedMcpServers, deniedMcpServers, MCP elicitation, headersHelper, claude mcp serve, MCP output limits, MAX_MCP_OUTPUT_TOKENS, MCP_TIMEOUT, plugin MCP servers, MCP channels, connecting external tools, or any MCP-related topic for Claude Code.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for Claude Code's MCP (Model Context Protocol) integration -- connecting to external tools, databases, and APIs through MCP servers.

## Quick Reference

Claude Code connects to hundreds of external tools and data sources through [MCP](https://modelcontextprotocol.io/introduction), an open standard for AI-tool integrations. MCP servers give Claude access to issue trackers, monitoring tools, databases, design tools, and more.

### Transport Types

| Transport | Flag | Use case | Status |
|:----------|:-----|:---------|:-------|
| **HTTP** | `--transport http` | Remote cloud services (Notion, Sentry, GitHub, etc.) | Recommended |
| **SSE** | `--transport sse` | Remote servers using Server-Sent Events | Deprecated; use HTTP |
| **stdio** | `--transport stdio` | Local processes needing direct system access | For local tools/scripts |

### Adding MCP Servers

```
# HTTP (remote)
claude mcp add --transport http <name> <url>
claude mcp add --transport http notion https://mcp.notion.com/mcp

# HTTP with auth header
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"

# stdio (local)
claude mcp add --transport stdio --env KEY=value <name> -- <command> [args...]
claude mcp add --transport stdio --env AIRTABLE_API_KEY=KEY airtable \
  -- npx -y airtable-mcp-server
```

All options (`--transport`, `--env`, `--scope`, `--header`) must come before the server name. The `--` separator comes after the server name and before the command/args for stdio servers.

### Installation Scopes

| Scope | Storage | Shared | Best for |
|:------|:--------|:-------|:---------|
| `local` (default) | `~/.claude.json` under project path | No | Personal dev servers, sensitive credentials |
| `project` | `.mcp.json` at project root | Yes (via git) | Team-shared tools and services |
| `user` | `~/.claude.json` globally | No (cross-project) | Personal utilities across all projects |

Precedence: local > project > user. Use `--scope local`, `--scope project`, or `--scope user` when adding.

### Managing Servers

| Command | Purpose |
|:--------|:--------|
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Show details for a server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset project-scope approval choices |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS/WSL) |
| `claude mcp add-json <name> '<json>'` | Add server from JSON config |
| `claude mcp serve` | Start Claude Code as a stdio MCP server |
| `/mcp` | Interactive server status, authenticate OAuth |

### .mcp.json Format (Project Scope)

```json
{
  "mcpServers": {
    "server-name": {
      "type": "http",
      "url": "https://api.example.com/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

Environment variable expansion is supported: `${VAR}` expands to the variable's value, `${VAR:-default}` uses a default if unset. Expansion works in `command`, `args`, `env`, `url`, and `headers` fields.

### OAuth 2.0 Authentication

Many remote servers require OAuth. The flow is: add the server, then run `/mcp` inside Claude Code to authenticate in your browser.

| Option | Purpose |
|:-------|:--------|
| `--callback-port <port>` | Fix the OAuth callback port to match a pre-registered redirect URI |
| `--client-id <id>` | Provide a pre-configured OAuth client ID |
| `--client-secret` | Prompt for client secret (stored in system keychain) |
| `MCP_CLIENT_SECRET` env var | Pass secret non-interactively for CI |
| `authServerMetadataUrl` | Override OAuth metadata discovery URL (in `.mcp.json` `oauth` object) |

Tokens are stored securely and refreshed automatically. Use "Clear authentication" in `/mcp` to revoke.

### Dynamic Headers (headersHelper)

For non-OAuth auth (Kerberos, SSO, short-lived tokens), use `headersHelper` in `.mcp.json`:

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

The command must output a JSON object of string key-value pairs to stdout. It runs in a shell with a 10-second timeout, fresh on each connection.

### MCP Resources

Reference server resources using `@` mentions: `@server:protocol://resource/path`. Resources appear in the autocomplete menu alongside files. Multiple references are supported in a single prompt.

### MCP Prompts as Commands

Server prompts appear as commands with the format `/mcp__servername__promptname`. Pass arguments space-separated after the command.

### MCP Tool Search

When many MCP servers are configured, Tool Search defers tool loading and discovers them on demand to save context.

| `ENABLE_TOOL_SEARCH` | Behavior |
|:----------------------|:---------|
| (unset) | Enabled by default; disabled with non-first-party `ANTHROPIC_BASE_URL` |
| `true` | Always enabled |
| `auto` | Activates when MCP tools exceed 10% of context |
| `auto:<N>` | Activates at custom threshold (e.g., `auto:5` for 5%) |
| `false` | Disabled; all tools loaded upfront |

Requires models supporting `tool_reference` blocks (Sonnet 4+, Opus 4+; not Haiku). Can also be disabled via `disallowedTools: ["MCPSearch"]` in settings.

For MCP server authors: add clear server instructions describing what tasks your tools handle and when Claude should search for them.

### Push Messages with Channels

MCP servers can push messages into sessions using the `claude/channel` capability. Enable with `--channels` flag at startup. See Channels documentation for details.

### Output Limits

| Setting | Value |
|:--------|:------|
| Warning threshold | 10,000 tokens |
| Default max | 25,000 tokens |
| Override | `MAX_MCP_OUTPUT_TOKENS` env var |

### Elicitation

MCP servers can request structured input mid-task. Two modes: **form mode** (dialog with server-defined fields) and **URL mode** (browser-based auth/approval). Use the `Elicitation` hook to auto-respond. No user configuration needed.

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers via `.mcp.json` at the plugin root or inline in `plugin.json`. Plugin servers start automatically when the plugin is enabled. Use `${CLAUDE_PLUGIN_ROOT}` for bundled files and `${CLAUDE_PLUGIN_DATA}` for persistent state. Run `/reload-plugins` to connect/disconnect after enable/disable.

### Claude Code as MCP Server

Start Claude Code as a stdio MCP server for other applications:

```
claude mcp serve
```

Exposes Claude Code's tools (View, Edit, LS, etc.) to any MCP client. The client is responsible for user confirmation of tool calls.

### Claude.ai MCP Servers

When logged in with a Claude.ai account, servers configured at `claude.ai/settings/connectors` are automatically available. Disable with `ENABLE_CLAUDEAI_MCP_SERVERS=false`.

### Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `MCP_TIMEOUT` | MCP server startup timeout in ms (e.g., `MCP_TIMEOUT=10000 claude`) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens for MCP tool output (default 25000) |
| `ENABLE_TOOL_SEARCH` | Control tool search behavior (see table above) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set `false` to disable Claude.ai MCP servers |
| `MCP_CLIENT_SECRET` | OAuth client secret for non-interactive setup |

### Managed MCP Configuration

Two options for organizational control:

**Option 1: Exclusive control** -- Deploy `managed-mcp.json` to a system-wide path. Users cannot add, modify, or use any other MCP servers.

| OS | Path |
|:---|:-----|
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux/WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

**Option 2: Policy-based** -- Use `allowedMcpServers` and `deniedMcpServers` in managed settings. Supports matching by `serverName`, `serverCommand` (exact array match for stdio), or `serverUrl` (wildcards with `*`).

| Setting | Undefined | Empty `[]` | With entries |
|:--------|:----------|:-----------|:-------------|
| `allowedMcpServers` | No restrictions | Complete lockdown | Only matching servers allowed |
| `deniedMcpServers` | No blocks | No blocks | Matched servers blocked |

Denylist takes absolute precedence over allowlist. Options 1 and 2 can be combined.

### Windows Note

On native Windows (not WSL), stdio servers using `npx` require a `cmd /c` wrapper:

```
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) -- MCP overview and use cases, transport types (HTTP recommended, SSE deprecated, stdio for local), adding servers (claude mcp add with --transport/--env/--scope/--header, option ordering and -- separator), managing servers (list/get/remove, /mcp interactive), dynamic tool updates (list_changed notifications), push messages with channels (claude/channel capability, --channels flag), scope tips and MCP_TIMEOUT/MAX_MCP_OUTPUT_TOKENS, Windows npx cmd /c wrapper, plugin-provided MCP servers (.mcp.json or inline plugin.json, ${CLAUDE_PLUGIN_ROOT}/${CLAUDE_PLUGIN_DATA}, automatic lifecycle, /reload-plugins), installation scopes (local default in ~/.claude.json, project in .mcp.json with git sharing and approval, user cross-project, scope hierarchy local > project > user), environment variable expansion in .mcp.json (${VAR} and ${VAR:-default} in command/args/env/url/headers), practical examples (Sentry, GitHub, PostgreSQL), OAuth 2.0 authentication (/mcp browser flow, --callback-port, --client-id/--client-secret, MCP_CLIENT_SECRET for CI, authServerMetadataUrl override, CIMD auto-discovery), dynamic headers (headersHelper for Kerberos/SSO/tokens, JSON stdout, 10s timeout, shell execution), JSON configuration (claude mcp add-json, stdio/HTTP examples, OAuth credentials in JSON), importing from Claude Desktop (claude mcp add-from-claude-desktop, macOS/WSL only), Claude.ai MCP servers (auto-available, ENABLE_CLAUDEAI_MCP_SERVERS), Claude Code as MCP server (claude mcp serve, Claude Desktop config), output limits (10000 token warning, MAX_MCP_OUTPUT_TOKENS default 25000), elicitation (form mode/URL mode, Elicitation hook), MCP resources (@ mention with @server:protocol://path, autocomplete, multiple references), MCP Tool Search (ENABLE_TOOL_SEARCH with true/auto/auto:N/false, deferred loading, server instructions, tool_reference model requirement, disallowedTools MCPSearch), MCP prompts as commands (/mcp__servername__promptname, arguments), managed MCP configuration (managed-mcp.json exclusive control at OS-specific paths, policy-based allowedMcpServers/deniedMcpServers with serverName/serverCommand/serverUrl matching, URL wildcards, command exact matching, denylist precedence, combining options)

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
