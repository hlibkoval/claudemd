---
name: mcp-doc
description: Complete documentation for Claude Code MCP (Model Context Protocol) integration -- installing MCP servers (HTTP, SSE, stdio), managing servers (add, remove, list, get), configuration scopes (local, project, user), OAuth 2.0 authentication (dynamic client registration, pre-configured credentials, callback ports, metadata override, headersHelper), JSON configuration (add-json, environment variable expansion in .mcp.json), importing from Claude Desktop (add-from-claude-desktop), using Claude.ai connectors, running Claude Code as an MCP server (mcp serve), MCP output limits (MAX_MCP_OUTPUT_TOKENS, anthropic/maxResultSizeChars), elicitation requests (form mode, URL mode), MCP resources (@ mentions), MCP prompts as slash commands, Tool Search (ENABLE_TOOL_SEARCH, deferred tools, threshold mode), dynamic tool updates (list_changed), push messages via channels, plugin-provided MCP servers (.mcp.json in plugin root, CLAUDE_PLUGIN_ROOT), managed MCP configuration (managed-mcp.json, allowedMcpServers, deniedMcpServers, serverName, serverCommand, serverUrl restrictions), scope hierarchy and precedence, and Windows npx compatibility. Load when discussing MCP, Model Context Protocol, MCP servers, MCP tools, claude mcp add, claude mcp remove, MCP scopes, MCP OAuth, MCP authentication, .mcp.json, managed-mcp.json, MCP elicitation, MCP resources, MCP prompts, Tool Search, ENABLE_TOOL_SEARCH, MAX_MCP_OUTPUT_TOKENS, MCP output limits, headersHelper, MCP channels, plugin MCP servers, MCP configuration, or any MCP-related topic for Claude Code.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools and data sources via the Model Context Protocol (MCP).

## Quick Reference

### Transport Types

| Transport | Flag | Use case |
|:----------|:-----|:---------|
| HTTP (streamable) | `--transport http` | Recommended for remote/cloud servers |
| SSE | `--transport sse` | Deprecated; use HTTP where available |
| stdio | `--transport stdio` | Local processes needing direct system access |

### CLI Commands

| Command | Description |
|:--------|:-----------|
| `claude mcp add <name> ...` | Add an MCP server |
| `claude mcp add-json <name> '<json>'` | Add server from JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Get details for a server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset project-scope approval choices |
| `claude mcp serve` | Run Claude Code itself as an MCP server |
| `/mcp` | In-session: view status, authenticate, manage servers |

### Adding Servers

```bash
# HTTP (recommended for remote)
claude mcp add --transport http <name> <url>
claude mcp add --transport http notion https://mcp.notion.com/mcp

# HTTP with auth header
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"

# SSE (deprecated)
claude mcp add --transport sse <name> <url>

# stdio (local process) -- options before name, -- before command
claude mcp add --transport stdio --env KEY=value <name> -- <command> [args...]
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server
```

Option ordering: all flags (`--transport`, `--env`, `--scope`, `--header`) go before the server name. The `--` separates the name from the command/args passed to the server.

### Configuration Scopes

| Scope | Flag | Storage | Visibility |
|:------|:-----|:--------|:-----------|
| Local (default) | `--scope local` | `~/.claude.json` (per-project path) | Private, current project only |
| Project | `--scope project` | `.mcp.json` in project root | Shared via version control |
| User | `--scope user` | `~/.claude.json` | Private, all projects |

Precedence: local > project > user. Local config also overrides Claude.ai connectors.

### OAuth Authentication

| Method | Flags |
|:-------|:------|
| Dynamic client registration (default) | None needed |
| Fixed callback port | `--callback-port <port>` |
| Pre-configured credentials | `--client-id <id> --client-secret` |
| Client secret via env var | `MCP_CLIENT_SECRET=secret ...` |
| Override metadata discovery | `oauth.authServerMetadataUrl` in `.mcp.json` |

Use `/mcp` in Claude Code to trigger the browser login flow. Tokens are stored securely and refreshed automatically.

### Dynamic Headers (headersHelper)

For non-OAuth auth (Kerberos, short-lived tokens, internal SSO), use `headersHelper` in `.mcp.json`:

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

Requirements: command writes a JSON object of string key-value pairs to stdout, 10-second timeout, runs on each connection. Environment variables provided: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`.

### Environment Variable Expansion in .mcp.json

| Syntax | Behavior |
|:-------|:---------|
| `${VAR}` | Expands to value of `VAR` (fails if unset) |
| `${VAR:-default}` | Uses `default` if `VAR` is unset |

Supported in: `command`, `args`, `env`, `url`, `headers`.

### MCP Output Limits

| Setting | Default | Description |
|:--------|:--------|:-----------|
| Warning threshold | 10,000 tokens | Displays warning when exceeded |
| `MAX_MCP_OUTPUT_TOKENS` | 25,000 tokens | Maximum allowed output |
| `anthropic/maxResultSizeChars` | -- | Per-tool override in `tools/list` `_meta` (ceiling: 500,000 chars) |

Results exceeding the limit are persisted to disk and replaced with a file reference.

### Tool Search

| `ENABLE_TOOL_SEARCH` value | Behavior |
|:---------------------------|:---------|
| (unset) | All MCP tools deferred and loaded on demand; falls back to upfront for non-first-party `ANTHROPIC_BASE_URL` |
| `true` | All tools deferred, including non-first-party hosts |
| `auto` | Upfront if tools fit within 10% of context window, deferred otherwise |
| `auto:<N>` | Custom threshold percentage (0-100) |
| `false` | All tools loaded upfront |

Requires Sonnet 4+ or Opus 4+. Haiku models do not support tool search. Disable the ToolSearch tool via `permissions.deny: ["ToolSearch"]`.

### MCP Prompts as Commands

MCP server prompts appear as slash commands with the format `/mcp__servername__promptname`. Arguments are space-separated after the command.

### MCP Resources

Reference resources with `@server:protocol://resource/path` in prompts. Resources appear in the `@` autocomplete menu alongside files.

### Elicitation

MCP servers can request structured input mid-task via form mode (in-CLI dialog) or URL mode (browser flow). Auto-respond using the `Elicitation` hook.

### Plugin-Provided MCP Servers

Plugins define MCP servers in `.mcp.json` at plugin root or inline in `plugin.json`. Environment variables: `${CLAUDE_PLUGIN_ROOT}` for bundled files, `${CLAUDE_PLUGIN_DATA}` for persistent state. Servers start automatically when the plugin is enabled; use `/reload-plugins` to reconnect after changes.

### Managed MCP Configuration

| Option | File | Effect |
|:-------|:-----|:-------|
| Exclusive control | `managed-mcp.json` | Only managed servers; users cannot add any |
| Policy-based | `allowedMcpServers` / `deniedMcpServers` in managed settings | Users can add servers within policy constraints |

`managed-mcp.json` locations: macOS `/Library/Application Support/ClaudeCode/managed-mcp.json`, Linux `/etc/claude-code/managed-mcp.json`, Windows `C:\Program Files\ClaudeCode\managed-mcp.json`.

### Allowlist / Denylist Entry Types

| Field | Matches |
|:------|:--------|
| `serverName` | Configured server name |
| `serverCommand` | Exact command + args array (stdio only) |
| `serverUrl` | URL pattern with `*` wildcards (remote only) |

Denylist takes absolute precedence over allowlist. Each entry must have exactly one of the three fields. When command entries exist in allowlist, stdio servers must match a command entry. When URL entries exist, remote servers must match a URL pattern.

### Useful Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `MCP_TIMEOUT` | Server startup timeout in ms (e.g., `MCP_TIMEOUT=10000 claude`) |
| `MAX_MCP_OUTPUT_TOKENS` | Maximum MCP tool output tokens |
| `ENABLE_TOOL_SEARCH` | Control tool search behavior |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set `false` to disable Claude.ai MCP servers |
| `MCP_CLIENT_SECRET` | OAuth client secret via env var |

### Windows Note

On native Windows (not WSL), stdio servers using `npx` require the `cmd /c` wrapper:

```bash
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) -- Full MCP guide covering installation, transports, scopes, authentication, JSON config, output limits, elicitation, resources, prompts, Tool Search, managed configuration, and practical examples

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
