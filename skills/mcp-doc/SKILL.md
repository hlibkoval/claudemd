---
name: mcp-doc
description: Complete documentation for connecting Claude Code to tools via the Model Context Protocol (MCP). Covers installing MCP servers (HTTP, SSE, stdio transports), managing servers (list, get, remove, /mcp command), installation scopes (local, project, user), scope hierarchy and precedence, .mcp.json project configuration with environment variable expansion (${VAR}, ${VAR:-default}), OAuth 2.0 authentication (dynamic client registration, pre-configured credentials, --client-id, --client-secret, --callback-port, authServerMetadataUrl override, CIMD discovery), dynamic headers with headersHelper, adding servers from JSON (claude mcp add-json), importing from Claude Desktop (claude mcp add-from-claude-desktop), using MCP servers from Claude.ai (ENABLE_CLAUDEAI_MCP_SERVERS), using Claude Code as an MCP server (claude mcp serve), MCP output limits (MAX_MCP_OUTPUT_TOKENS, 25000 default, 10000 warning threshold), MCP elicitation requests (form mode, URL mode, Elicitation hook), MCP resources (@ mentions, @server:protocol://resource/path), MCP prompts as commands (/mcp__servername__promptname), Tool Search (ENABLE_TOOL_SEARCH with true/false/auto/auto:N, deferred tool loading, tool_reference blocks, 2KB description limit), dynamic tool updates (list_changed notifications), push messages with channels (claude/channel capability, --channels flag), plugin-provided MCP servers (.mcp.json at plugin root or inline in plugin.json, ${CLAUDE_PLUGIN_ROOT}, ${CLAUDE_PLUGIN_DATA}, automatic lifecycle, /reload-plugins), managed MCP configuration (managed-mcp.json exclusive control at system paths, policy-based allowedMcpServers/deniedMcpServers with serverName/serverCommand/serverUrl matching, URL wildcards, denylist precedence), MCP_TIMEOUT environment variable, project-scope approval and reset-project-choices, and Windows cmd /c npx wrapper requirement. Load when discussing MCP, Model Context Protocol, MCP servers, MCP tools, MCP configuration, claude mcp add, claude mcp list, claude mcp remove, .mcp.json, managed-mcp.json, MCP authentication, OAuth for MCP, MCP scopes, MCP resources, MCP prompts, MCP elicitation, Tool Search, ENABLE_TOOL_SEARCH, MAX_MCP_OUTPUT_TOKENS, MCP_TIMEOUT, headersHelper, MCP channels, plugin MCP servers, allowedMcpServers, deniedMcpServers, or any MCP-related topic for Claude Code.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools via the Model Context Protocol (MCP).

## Quick Reference

### Installing MCP Servers

Three transport options for adding servers:

| Transport | Command | Use case |
|:----------|:--------|:---------|
| **HTTP** (recommended) | `claude mcp add --transport http <name> <url>` | Remote cloud services |
| **SSE** (deprecated) | `claude mcp add --transport sse <name> <url>` | Legacy remote servers |
| **stdio** | `claude mcp add <name> -- <command> [args...]` | Local processes, custom scripts |

Options (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. The `--` separates the server name from the command/args for stdio servers.

**HTTP with auth header:**

```
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

**stdio with env vars:**

```
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server
```

**Windows (native, not WSL):** Wrap npx commands with `cmd /c`:

```
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

### Managing Servers

| Command | Purpose |
|:--------|:--------|
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Get details for a specific server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp add-json <name> '<json>'` | Add server from JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS/WSL only) |
| `claude mcp reset-project-choices` | Reset project-scope approval choices |
| `claude mcp serve` | Run Claude Code itself as an MCP server |
| `/mcp` | Check server status, authenticate, manage within Claude Code |

### Installation Scopes

| Scope | Storage | Visibility | Use case |
|:------|:--------|:-----------|:---------|
| **local** (default) | `~/.claude.json` (under project path) | Private, current project only | Personal servers, sensitive credentials |
| **project** | `.mcp.json` in project root (version control) | Shared with team | Team-shared servers, collaboration |
| **user** | `~/.claude.json` | Private, all projects | Personal utilities across projects |

**Precedence:** local > project > user. Local config also overrides Claude.ai connectors.

Use `--scope local`, `--scope project`, or `--scope user` when adding servers.

### Environment Variable Expansion in .mcp.json

Supported syntax: `${VAR}` and `${VAR:-default}`

Expansion works in: `command`, `args`, `env`, `url`, `headers`

Missing variables without defaults cause a parse failure.

### OAuth 2.0 Authentication

**Basic flow:** Add HTTP server, then run `/mcp` and follow browser login.

**Fixed callback port** (for pre-registered redirect URIs):

```
claude mcp add --transport http --callback-port 8080 my-server https://mcp.example.com/mcp
```

**Pre-configured OAuth credentials** (when dynamic client registration is unsupported):

```
claude mcp add --transport http \
  --client-id your-client-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

`--client-secret` prompts for masked input. Set `MCP_CLIENT_SECRET` env var to skip the prompt in CI.

**Override OAuth metadata discovery:** Set `authServerMetadataUrl` in the `oauth` object of the server config in `.mcp.json` (requires v2.1.64+).

**Dynamic headers (headersHelper):** For non-OAuth auth (Kerberos, short-lived tokens, internal SSO):

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

Requirements: command must output JSON object of string key-value pairs to stdout, 10-second timeout, runs fresh on each connection. Dynamic headers override static `headers` with the same name. Requires workspace trust dialog acceptance at project/local scope.

### MCP Output Limits

| Setting | Default | Purpose |
|:--------|:--------|:--------|
| Warning threshold | 10,000 tokens | Displays warning when MCP tool output exceeds this |
| `MAX_MCP_OUTPUT_TOKENS` | 25,000 tokens | Maximum allowed MCP output tokens |
| `MCP_TIMEOUT` | (platform default) | MCP server startup timeout in ms |

### MCP Elicitation

Servers can request structured input mid-task:

| Mode | Behavior |
|:-----|:---------|
| **Form** | Interactive dialog with server-defined fields |
| **URL** | Opens browser for authentication/approval |

Auto-respond via the `Elicitation` hook. No user configuration needed.

### MCP Resources

Reference resources with `@` mentions: `@server:protocol://resource/path`

Resources appear in autocomplete alongside files. Multiple resources can be referenced in one prompt.

### MCP Prompts as Commands

MCP prompts appear as `/mcp__servername__promptname` commands. Arguments are passed space-separated.

### Tool Search

Defers MCP tool definitions until needed, keeping context usage low. Only tool names load at session start.

| `ENABLE_TOOL_SEARCH` value | Behavior |
|:---------------------------|:---------|
| (unset) | Enabled by default; disabled when `ANTHROPIC_BASE_URL` is non-first-party |
| `true` | Always enabled |
| `auto` | Activates when MCP tools exceed 10% of context |
| `auto:<N>` | Activates at custom threshold percentage |
| `false` | Disabled, all MCP tools loaded upfront |

Requires Sonnet 4+ or Opus 4+ (Haiku does not support tool_reference blocks). Disable MCPSearch tool via `disallowedTools` setting: `{"permissions": {"deny": ["MCPSearch"]}}`.

Server instructions (2KB limit) help Claude discover tools. Keep critical details near the start.

### Dynamic Tool Updates

Servers can send `list_changed` notifications to dynamically update available tools, prompts, and resources without reconnecting.

### Push Messages with Channels

MCP servers can push messages into sessions by declaring the `claude/channel` capability. Enable with `--channels` flag at startup. See Channels documentation for details.

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers via `.mcp.json` at plugin root or inline in `plugin.json`.

| Feature | Detail |
|:--------|:-------|
| Lifecycle | Auto-connect at session startup; `/reload-plugins` for mid-session changes |
| Variables | `${CLAUDE_PLUGIN_ROOT}` for bundled files, `${CLAUDE_PLUGIN_DATA}` for persistent state |
| Transports | stdio, SSE, HTTP |

### Using Claude Code as an MCP Server

```
claude mcp serve
```

Exposes Claude Code tools (View, Edit, LS, etc.) to other MCP clients. Add to Claude Desktop config as a stdio server with `"command": "claude", "args": ["mcp", "serve"]`.

### Claude.ai Connector MCP Servers

Servers configured at claude.ai/settings/connectors are automatically available in Claude Code when logged in with a Claude.ai account. Disable with `ENABLE_CLAUDEAI_MCP_SERVERS=false`.

### Managed MCP Configuration

**Option 1 -- Exclusive control (`managed-mcp.json`):**

Deployed to system-wide directories (requires admin privileges):

| OS | Path |
|:---|:-----|
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux/WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

Users cannot add, modify, or use any servers not defined in this file.

**Option 2 -- Policy-based control (allowlists/denylists):**

Set `allowedMcpServers` and `deniedMcpServers` in managed settings.

| Restriction type | Field | Applies to |
|:-----------------|:------|:-----------|
| By name | `serverName` | Any server |
| By exact command | `serverCommand` (array, exact match) | stdio servers |
| By URL pattern | `serverUrl` (supports `*` wildcards) | Remote servers (HTTP, SSE) |

Each entry must have exactly one of these fields.

**Allowlist behavior:**

| Value | Effect |
|:------|:-------|
| `undefined` | No restrictions |
| `[]` | Complete lockdown -- no MCP servers allowed |
| List of entries | Only matching servers permitted |

**Key rules:**
- Denylist takes absolute precedence over allowlist
- When command entries exist in allowlist, stdio servers must match a command entry (not just name)
- When URL entries exist in allowlist, remote servers must match a URL pattern (not just name)
- Options 1 and 2 can be combined: managed-mcp.json has exclusive control, allowlists/denylists filter which managed servers load

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) -- installing MCP servers (HTTP, SSE, stdio transports with examples), managing servers (list, get, remove, /mcp), dynamic tool updates (list_changed notifications), push messages with channels (claude/channel capability), installation scopes (local, project, user with precedence and storage locations), .mcp.json environment variable expansion (${VAR}, ${VAR:-default} in command/args/env/url/headers), practical examples (Sentry, GitHub, PostgreSQL), OAuth 2.0 authentication (dynamic client registration, pre-configured credentials with --client-id/--client-secret/--callback-port, MCP_CLIENT_SECRET env var, authServerMetadataUrl override, CIMD discovery), dynamic headers with headersHelper (JSON stdout, 10s timeout, workspace trust), adding from JSON (claude mcp add-json), importing from Claude Desktop (claude mcp add-from-claude-desktop), Claude.ai connector servers (ENABLE_CLAUDEAI_MCP_SERVERS), using Claude Code as MCP server (claude mcp serve), output limits (MAX_MCP_OUTPUT_TOKENS default 25000, warning at 10000), elicitation (form mode, URL mode, Elicitation hook), MCP resources (@ mentions), Tool Search (ENABLE_TOOL_SEARCH true/false/auto/auto:N, deferred loading, 2KB description limit, tool_reference blocks, Sonnet 4+/Opus 4+), MCP prompts as commands, managed MCP configuration (managed-mcp.json exclusive control at system paths, policy-based allowedMcpServers/deniedMcpServers with serverName/serverCommand/serverUrl matching and URL wildcards), plugin-provided MCP servers (.mcp.json or inline plugin.json, CLAUDE_PLUGIN_ROOT/CLAUDE_PLUGIN_DATA, automatic lifecycle, /reload-plugins), MCP_TIMEOUT, project-scope approval reset, Windows cmd /c wrapper

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
