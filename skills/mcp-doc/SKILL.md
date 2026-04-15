---
name: mcp-doc
description: Complete official documentation for connecting Claude Code to external tools and data sources via the Model Context Protocol (MCP) — covers installing servers (HTTP, SSE, stdio), configuration scopes, OAuth, JSON config, plugin-bundled servers, output limits, tool search, MCP prompts/resources, managed enterprise configuration, and using Claude Code itself as an MCP server.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools via the Model Context Protocol (MCP).

## Quick Reference

MCP is an open standard that lets Claude Code talk to external tools, databases, and APIs through "MCP servers". Servers expose **tools**, **resources**, and **prompts**.

### Transports

| Transport | Use case | Add command |
| :-------- | :------- | :---------- |
| `http` | Recommended for remote/cloud servers | `claude mcp add --transport http <name> <url>` |
| `sse` | Deprecated; use `http` where possible | `claude mcp add --transport sse <name> <url>` |
| `stdio` | Local subprocess (CLI tools, custom scripts) | `claude mcp add --transport stdio <name> -- <command> [args...]` |

**Option ordering rule**: All flags (`--transport`, `--env`, `--scope`, `--header`) MUST come before the server name. The `--` separator goes between the name and the command/args.

**Windows note**: On native Windows (not WSL), local `npx` servers must be wrapped in `cmd /c`, e.g. `-- cmd /c npx -y @some/package`.

### Installation scopes

| Scope     | Loads in              | Shared with team           | Stored in                    |
| :-------- | :-------------------- | :------------------------- | :--------------------------- |
| `local` (default) | Current project only | No                  | `~/.claude.json` (per project) |
| `project` | Current project only  | Yes, via version control   | `.mcp.json` in project root  |
| `user`    | All your projects     | No                         | `~/.claude.json`             |

Pass with `--scope local|project|user`. `local` was previously `project`; `user` was previously `global`.

### Precedence (highest first)

1. Local scope
2. Project scope
3. User scope
4. Plugin-provided servers
5. claude.ai connectors

Scopes match by name. Plugins/connectors match by endpoint (URL or command).

### Common management commands

| Command | Purpose |
| :------ | :------ |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Show details for one server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp add-json <name> '<json>'` | Add server from JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS / WSL only) |
| `claude mcp serve` | Run Claude Code itself as a stdio MCP server |
| `claude mcp reset-project-choices` | Clear approval prompts for project-scope servers |
| `/mcp` (in session) | Check status, authenticate (OAuth), manage |

### `.mcp.json` shape (project scope)

```json
{
  "mcpServers": {
    "my-server": {
      "type": "http",
      "url": "https://mcp.example.com/mcp",
      "headers": { "Authorization": "Bearer ${API_KEY}" }
    },
    "local-tool": {
      "command": "/path/to/server",
      "args": ["--flag"],
      "env": { "DB_URL": "${DB_URL}" }
    }
  }
}
```

### Environment variable expansion

Supported in `command`, `args`, `env`, `url`, and `headers`:

- `${VAR}` — value of `VAR`
- `${VAR:-default}` — `VAR` or `default` if unset

Parse fails if a required variable has no default and is unset.

### OAuth authentication

- Use `/mcp` to authenticate with HTTP/SSE servers requiring OAuth 2.0
- `--callback-port <PORT>` — fix the OAuth callback port to match a pre-registered redirect URI (`http://localhost:PORT/callback`)
- `--client-id <ID>` — pre-configured OAuth client ID
- `--client-secret` — prompts for client secret (masked); or set `MCP_CLIENT_SECRET` env var for CI
- `authServerMetadataUrl` (in `oauth` block) — override OAuth metadata discovery (must be `https://`, requires v2.1.64+)
- Tokens stored in OS keychain (macOS) or credentials file
- Flags only apply to HTTP/SSE; no effect on stdio

### Custom-auth header helper

For non-OAuth schemes (Kerberos, SSO, short-lived tokens), set `headersHelper` to a command that prints a JSON object of header key/value pairs to stdout:

```json
{
  "mcpServers": {
    "internal": {
      "type": "http",
      "url": "https://mcp.internal.example.com",
      "headersHelper": "/opt/bin/get-mcp-auth-headers.sh"
    }
  }
}
```

Runs in a shell with a 10-second timeout; runs fresh on every connection (no caching). Helper can read `CLAUDE_CODE_MCP_SERVER_NAME` and `CLAUDE_CODE_MCP_SERVER_URL` env vars. Project/local-scope helpers only run after the workspace trust dialog is accepted.

### Plugin-provided MCP servers

Plugins can bundle MCP servers in `.mcp.json` at plugin root, or inline under `mcpServers` in `plugin.json`. They start automatically when the plugin is enabled. Use `/reload-plugins` after enabling/disabling mid-session.

Plugin-only env vars:
- `${CLAUDE_PLUGIN_ROOT}` — bundled plugin files
- `${CLAUDE_PLUGIN_DATA}` — persistent state directory (survives plugin updates)

### Output limits

| Setting | Default | Purpose |
| :------ | :------ | :------ |
| Warning threshold | 10,000 tokens | Claude Code warns when a tool's output exceeds this |
| `MAX_MCP_OUTPUT_TOKENS` env var | 25,000 tokens | Hard limit for tools that don't declare their own |
| `_meta["anthropic/maxResultSizeChars"]` | — | Per-tool override (text only); hard ceiling 500,000 chars |

Image-content tools are always subject to `MAX_MCP_OUTPUT_TOKENS`. Text-content tools that set `anthropic/maxResultSizeChars` use that value regardless of the env var.

### Tool Search (deferred MCP tool loading)

Keeps context usage low by deferring tool definitions until needed. Requires Sonnet 4+/Opus 4+ (Haiku does not support `tool_reference` blocks).

| `ENABLE_TOOL_SEARCH` value | Behavior |
| :------------------------- | :------- |
| (unset) | Defer all MCP tools; falls back to upfront load if `ANTHROPIC_BASE_URL` is non-first-party |
| `true` | Defer all, even on non-first-party `ANTHROPIC_BASE_URL` |
| `auto` | Threshold mode: load upfront if tools fit in 10% of context, defer overflow |
| `auto:<N>` | Custom threshold percentage (0-100), e.g. `auto:5` |
| `false` | Load all MCP tools upfront, no deferral |

Disable just the search tool with `permissions.deny: ["ToolSearch"]` in settings.

Server-author tip: write clear "server instructions" (Claude Code truncates instructions and tool descriptions at 2KB each) so Tool Search can find your tools.

### MCP resources (@ mentions)

Reference resources via `@server:protocol://resource/path`, e.g. `@github:issue://123` or `@docs:file://api/authentication`. Resources show up in the `@` autocomplete alongside files and are fetched as attachments when referenced.

### MCP prompts as slash commands

Prompts from connected servers appear as `/mcp__<servername>__<promptname>`. Pass space-separated arguments after the command, e.g. `/mcp__github__pr_review 456`. Server and prompt names are normalized (spaces become underscores).

### Elicitation

MCP servers can request structured input mid-task. Two modes:
- **Form mode**: dialog with server-defined fields
- **URL mode**: opens a browser URL, then confirm in the CLI

Use the `Elicitation` hook to auto-respond without showing a dialog.

### Dynamic tool updates

Claude Code honors MCP `list_changed` notifications: servers can update their tools, prompts, and resources at runtime without a reconnect.

### Channels (push messages)

A server can declare the `claude/channel` capability and be enabled with `--channels` at startup to push messages into your session (CI results, alerts, chat, webhook events).

### Use Claude Code as an MCP server

`claude mcp serve` runs Claude Code itself as a stdio MCP server, exposing its tools (View, Edit, LS, etc.) to other MCP clients like Claude Desktop. The host client is responsible for tool-call confirmation. Use the absolute path from `which claude` in your client config to avoid `spawn claude ENOENT`.

### Use claude.ai connectors

If logged in with a Claude.ai account, MCP servers added at `claude.ai/settings/connectors` are available automatically. Disable with `ENABLE_CLAUDEAI_MCP_SERVERS=false`.

### Other useful env vars

| Env var | Purpose |
| :------ | :------ |
| `MCP_TIMEOUT` | MCP server startup timeout in ms (e.g. `MCP_TIMEOUT=10000`) |
| `MAX_MCP_OUTPUT_TOKENS` | Per-tool output limit |
| `ENABLE_TOOL_SEARCH` | Tool Search behavior (see table above) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set `false` to disable claude.ai connectors |
| `MCP_CLIENT_SECRET` | OAuth client secret (skips interactive prompt) |

### Managed enterprise configuration

Two options for IT-controlled MCP:

**Option 1 — `managed-mcp.json` (exclusive control)**: deploy a fixed set of servers; users cannot add or modify any MCP servers. System paths:

| OS | Path |
| :- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux / WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

File uses the standard `.mcp.json` format.

**Option 2 — allowlists/denylists in managed settings**: users can add their own servers, restricted by `allowedMcpServers` / `deniedMcpServers`. Each entry must have **exactly one** of:

| Field | Matches |
| :---- | :------ |
| `serverName` | Configured server name |
| `serverCommand` | Exact command + args array (stdio servers) |
| `serverUrl` | Remote URL with `*` wildcards |

Behavior summary:
- `allowedMcpServers` undefined = no restrictions; `[]` = full lockdown; populated = must match
- `deniedMcpServers` always takes precedence over allowlist
- When command entries exist, stdio servers MUST match a command (cannot pass by name alone)
- When URL entries exist, remote servers MUST match a URL pattern
- Options 1 and 2 can be combined: managed servers themselves are still filtered by allow/deny

URL wildcard examples: `https://mcp.company.com/*`, `https://*.example.com/*`, `http://localhost:*/*`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — full guide covering popular MCP servers, installing via HTTP/SSE/stdio, scopes (local/project/user), env var expansion in `.mcp.json`, OAuth (callback ports, pre-configured credentials, metadata override), `headersHelper` for custom auth, plugin-bundled servers, importing from Claude Desktop, claude.ai connectors, running Claude Code as an MCP server, output limits and `MAX_MCP_OUTPUT_TOKENS`, Tool Search, MCP resources via `@` mentions, MCP prompts as `/mcp__server__prompt` commands, elicitation, channels, and managed enterprise configuration via `managed-mcp.json` and allow/deny lists.

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
