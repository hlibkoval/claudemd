---
name: mcp-doc
description: Complete documentation for connecting Claude Code to external tools via the Model Context Protocol (MCP) -- installing MCP servers (HTTP, SSE, stdio transports), `claude mcp add` CLI commands (add, add-json, add-from-claude-desktop, list, get, remove, reset-project-choices, serve), MCP installation scopes (local, project via .mcp.json, user), scope hierarchy and precedence, environment variable expansion in .mcp.json (${VAR}, ${VAR:-default}), OAuth 2.0 authentication (--client-id, --client-secret, --callback-port, authServerMetadataUrl, Dynamic Client Registration, CIMD), managed MCP configuration (managed-mcp.json exclusive control, allowedMcpServers/deniedMcpServers policy-based control with serverName/serverCommand/serverUrl matching), plugin-provided MCP servers (.mcp.json in plugin root, mcpServers in plugin.json, ${CLAUDE_PLUGIN_ROOT}, ${CLAUDE_PLUGIN_DATA}), MCP Tool Search (ENABLE_TOOL_SEARCH, auto threshold, MCPSearch tool, tool_reference blocks), MCP resources (@ mentions, @server:protocol://path), MCP prompts as /mcp__server__prompt commands, elicitation (form mode, URL mode, Elicitation hook), push messages with channels (claude/channel capability, --channels flag), dynamic tool updates (list_changed notifications), MCP output limits (MAX_MCP_OUTPUT_TOKENS, 10000-token warning, 25000-token default), using Claude Code as an MCP server (claude mcp serve), MCP_TIMEOUT for startup timeout, /mcp command for status and authentication, importing from Claude Desktop, using MCP servers from Claude.ai (ENABLE_CLAUDEAI_MCP_SERVERS), Windows cmd /c wrapper for npx. Load when discussing MCP, Model Context Protocol, MCP servers, claude mcp add, MCP configuration, .mcp.json, managed-mcp.json, MCP scopes, MCP authentication, OAuth for MCP, MCP Tool Search, ENABLE_TOOL_SEARCH, MCP resources, MCP prompts, MCP elicitation, MCP channels, MCP output limits, MAX_MCP_OUTPUT_TOKENS, MCP_TIMEOUT, claude mcp serve, plugin MCP servers, allowedMcpServers, deniedMcpServers, MCP server management, or any MCP-related topic for Claude Code.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools and data sources via the Model Context Protocol (MCP).

## Quick Reference

MCP is an open standard for AI-tool integrations. Claude Code connects to MCP servers that provide tools, resources, and prompts from external services like GitHub, Sentry, databases, and more.

### Transport Types

| Transport | Flag | Use case |
|:----------|:-----|:---------|
| HTTP (Streamable HTTP) | `--transport http` | Recommended for remote/cloud servers |
| SSE (Server-Sent Events) | `--transport sse` | Deprecated; use HTTP where available |
| stdio | `--transport stdio` | Local processes needing direct system access |

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude mcp add [options] <name> <url>` | Add HTTP/SSE server |
| `claude mcp add [options] <name> -- <command> [args...]` | Add stdio server |
| `claude mcp add-json <name> '<json>'` | Add server from JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Show details for a server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset project-scoped server approvals |
| `claude mcp serve` | Run Claude Code itself as an MCP server |
| `/mcp` | In-session: check status, authenticate, manage servers |

Options must come before the server name. The `--` separates the server name from the command/args for stdio servers.

### Common Options

| Option | Description |
|:-------|:------------|
| `--transport <type>` | `http`, `sse`, or `stdio` |
| `--scope <scope>` | `local` (default), `project`, or `user` |
| `--env KEY=value` | Set environment variable for the server |
| `--header "Name: value"` | Add HTTP header (e.g., auth tokens) |
| `--client-id <id>` | OAuth client ID for pre-configured credentials |
| `--client-secret` | Prompt for OAuth client secret (masked input) |
| `--callback-port <port>` | Fix OAuth callback port for pre-registered redirect URIs |
| `--channels` | Enable channel/push message support |

### Installation Scopes

| Scope | Storage location | Shareable | Description |
|:------|:-----------------|:----------|:------------|
| `local` (default) | `~/.claude.json` under project path | No | Private to you, current project only |
| `project` | `.mcp.json` in project root | Yes (VCS) | Shared with team via version control |
| `user` | `~/.claude.json` | No | Available across all your projects |

Precedence: local > project > user. When same-name servers exist at multiple scopes, local wins.

### Environment Variable Expansion in .mcp.json

Supported syntax in `command`, `args`, `env`, `url`, and `headers` fields:

| Syntax | Behavior |
|:-------|:---------|
| `${VAR}` | Expands to value of `VAR`; fails if unset |
| `${VAR:-default}` | Expands to `VAR` if set, otherwise uses `default` |

### OAuth Authentication

OAuth 2.0 is supported for HTTP/SSE servers. Use `/mcp` in-session to trigger the browser login flow.

| Scenario | Approach |
|:---------|:---------|
| Server supports Dynamic Client Registration | `claude mcp add --transport http <name> <url>` then `/mcp` |
| Server requires pre-configured credentials | Add `--client-id` and `--client-secret`; optionally `--callback-port` |
| Fixed redirect URI required | Add `--callback-port <port>` to match pre-registered `http://localhost:PORT/callback` |
| Override metadata discovery | Set `authServerMetadataUrl` in `oauth` object in `.mcp.json` |
| CI / non-interactive secret | Set `MCP_CLIENT_SECRET` env var before `claude mcp add ... --client-secret` |

Tokens are stored securely (system keychain on macOS). Use "Clear authentication" in `/mcp` to revoke. Claude Code also supports CIMD (Client ID Metadata Document) auto-discovery.

### MCP Tool Search

Dynamically loads MCP tools on-demand instead of preloading all tool definitions, saving context window space.

| `ENABLE_TOOL_SEARCH` value | Behavior |
|:---------------------------|:---------|
| (unset) | Enabled by default; disabled when `ANTHROPIC_BASE_URL` is non-first-party |
| `true` | Always enabled |
| `auto` | Activates when MCP tools exceed 10% of context |
| `auto:<N>` | Activates at custom threshold (e.g., `auto:5` for 5%) |
| `false` | Disabled; all MCP tools loaded upfront |

Requires models supporting `tool_reference` blocks (Sonnet 4+, Opus 4+; not Haiku). Disable the search tool specifically with `"permissions": {"deny": ["MCPSearch"]}` in settings. For MCP server authors: add clear server instructions describing capabilities so Tool Search can discover your tools effectively.

### MCP Output Limits

| Setting | Default | Description |
|:--------|:--------|:------------|
| Warning threshold | 10,000 tokens | Displays warning when tool output exceeds this |
| `MAX_MCP_OUTPUT_TOKENS` | 25,000 tokens | Maximum allowed output; increase for large datasets |

### Other Environment Variables

| Variable | Description |
|:---------|:------------|
| `MCP_TIMEOUT` | Server startup timeout in ms (e.g., `MCP_TIMEOUT=10000 claude`) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set to `false` to disable Claude.ai MCP servers in Claude Code |
| `MCP_CLIENT_SECRET` | OAuth client secret via env var (skips interactive prompt) |

### MCP Resources

Reference MCP resources using `@` mentions: `@server:protocol://resource/path`. Resources appear in the `@` autocomplete alongside files and are fetched automatically as attachments.

### MCP Prompts

MCP prompts become `/` commands with the format `/mcp__servername__promptname`. Arguments are passed space-separated after the command.

### Elicitation

MCP servers can request structured input mid-task. Two modes:
- **Form mode**: Interactive dialog with server-defined fields
- **URL mode**: Opens browser for authentication/approval

Auto-respond using the `Elicitation` hook. No configuration needed on the client side.

### Channels (Push Messages)

MCP servers declaring the `claude/channel` capability can push messages into your session. Enable with the `--channels` flag at startup. See the channels documentation for details.

### Dynamic Tool Updates

Claude Code supports MCP `list_changed` notifications, allowing servers to dynamically update their available tools, prompts, and resources without requiring disconnection and reconnection.

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers via `.mcp.json` at the plugin root or `mcpServers` in `plugin.json`. These start automatically when the plugin is enabled. Use `${CLAUDE_PLUGIN_ROOT}` for bundled files and `${CLAUDE_PLUGIN_DATA}` for persistent state. Run `/reload-plugins` to reconnect after enabling/disabling plugins mid-session.

### Managed MCP Configuration

For organizations requiring centralized control:

| Approach | File / Setting | Effect |
|:---------|:---------------|:-------|
| Exclusive control | `managed-mcp.json` in system directory | Only these servers are available; users cannot add others |
| Policy-based control | `allowedMcpServers` / `deniedMcpServers` in managed settings | Users can add servers within policy constraints |

**managed-mcp.json locations:**
- macOS: `/Library/Application Support/ClaudeCode/managed-mcp.json`
- Linux/WSL: `/etc/claude-code/managed-mcp.json`
- Windows: `C:\Program Files\ClaudeCode\managed-mcp.json`

**Policy restriction types** (each entry uses exactly one):

| Field | Matches |
|:------|:--------|
| `serverName` | Configured server name |
| `serverCommand` | Exact command + args array for stdio servers |
| `serverUrl` | URL pattern with `*` wildcards for remote servers |

Denylist takes absolute precedence over allowlist. An empty allowlist `[]` blocks all servers. When `managed-mcp.json` is present, users cannot add servers via `claude mcp add`, but allowlist/denylist still filters the managed servers. Options 1 and 2 can be combined.

### Using Claude Code as an MCP Server

Run `claude mcp serve` to expose Claude Code's tools (View, Edit, LS, etc.) as an MCP server via stdio. Add to Claude Desktop config:

```json
{
  "mcpServers": {
    "claude-code": {
      "type": "stdio",
      "command": "claude",
      "args": ["mcp", "serve"],
      "env": {}
    }
  }
}
```

Use `which claude` to find the full executable path if `claude` is not in PATH.

### Claude.ai MCP Servers

MCP servers added in Claude.ai are automatically available in Claude Code when logged in with a Claude.ai account. Disable with `ENABLE_CLAUDEAI_MCP_SERVERS=false`. Use `/mcp` to view and manage these servers.

### Platform Notes

**Windows (native, not WSL):** Wrap `npx` commands with `cmd /c` for stdio servers:
```
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

**Claude Desktop import:** `claude mcp add-from-claude-desktop` works on macOS and WSL only.

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) -- full MCP setup guide covering transport types (HTTP, SSE, stdio), CLI commands (add, add-json, add-from-claude-desktop, list, get, remove, serve), installation scopes (local, project, user) and precedence, .mcp.json format and environment variable expansion, OAuth 2.0 authentication (Dynamic Client Registration, CIMD, pre-configured credentials, --client-id, --client-secret, --callback-port, authServerMetadataUrl, MCP_CLIENT_SECRET), managed MCP configuration (managed-mcp.json, allowedMcpServers/deniedMcpServers with serverName/serverCommand/serverUrl matching), plugin-provided MCP servers, MCP Tool Search (ENABLE_TOOL_SEARCH, auto threshold, MCPSearch), MCP resources (@ mentions), MCP prompts as commands, elicitation (form/URL modes), channels and push messages, dynamic tool updates (list_changed), output limits (MAX_MCP_OUTPUT_TOKENS), using Claude Code as MCP server, Claude.ai MCP servers, practical examples (Sentry, GitHub, PostgreSQL)

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
