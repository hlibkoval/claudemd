---
name: mcp-doc
description: Complete documentation for Claude Code MCP (Model Context Protocol) integration -- connecting to external tools via MCP servers, installing servers (HTTP/SSE/stdio transports), `claude mcp add` command with --transport/--env/--scope/--header flags, MCP installation scopes (local/project/user with precedence rules), `.mcp.json` project config with environment variable expansion (${VAR}, ${VAR:-default}), managing servers (`claude mcp list`/`get`/`remove`, `/mcp` command), dynamic tool updates (list_changed notifications), plugin-provided MCP servers (.mcp.json or plugin.json mcpServers, ${CLAUDE_PLUGIN_ROOT}/${CLAUDE_PLUGIN_DATA}), OAuth 2.0 authentication (browser flow, /mcp authenticate, token storage, --callback-port, --client-id/--client-secret, authServerMetadataUrl override), `claude mcp add-json` for JSON config, importing from Claude Desktop (`claude mcp add-from-claude-desktop`), Claude.ai MCP servers (ENABLE_CLAUDEAI_MCP_SERVERS), using Claude Code as MCP server (`claude mcp serve`), MCP output limits (MAX_MCP_OUTPUT_TOKENS, 25000 default, 10000 warning threshold), elicitation requests (form mode, URL mode, Elicitation hook), MCP resources (@server:protocol://path mentions), MCP Tool Search (ENABLE_TOOL_SEARCH auto/auto:N/true/false, context threshold, tool_reference blocks, MCPSearch tool, server instructions), MCP prompts as commands (/mcp__server__prompt), managed MCP configuration (managed-mcp.json exclusive control, allowedMcpServers/deniedMcpServers policy-based control with serverName/serverCommand/serverUrl matching, URL wildcards, denylist precedence), practical examples (Sentry, GitHub, PostgreSQL). Load when discussing MCP servers, Model Context Protocol, claude mcp add, MCP transports, MCP scopes, .mcp.json, MCP authentication OAuth, MCP server management, plugin MCP servers, MCP resources, MCP prompts, MCP tool search, managed MCP, managed-mcp.json, allowedMcpServers, deniedMcpServers, MCP output tokens, elicitation, claude mcp serve, MCP JSON config, importing MCP from Claude Desktop, ENABLE_TOOL_SEARCH, MAX_MCP_OUTPUT_TOKENS, MCP environment variables, or connecting Claude Code to external tools and data sources.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools and data sources via the Model Context Protocol (MCP).

## Quick Reference

MCP is an open standard for AI-tool integrations. Claude Code connects to MCP servers that provide access to databases, APIs, issue trackers, monitoring tools, and more. Servers run locally (stdio) or remotely (HTTP, SSE).

### Installing MCP Servers

Three transport options, all configured via `claude mcp add`:

| Transport | Command | Use case |
|:----------|:--------|:---------|
| HTTP (recommended) | `claude mcp add --transport http <name> <url>` | Remote cloud services |
| SSE (deprecated) | `claude mcp add --transport sse <name> <url>` | Legacy remote servers |
| stdio | `claude mcp add <name> -- <command> [args...]` | Local processes, custom scripts |

All options (`--transport`, `--env`, `--scope`, `--header`) must come before the server name. The `--` separates Claude's flags from the server command and arguments.

Add authentication headers with `--header`:

```
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

Windows users: stdio servers using `npx` require `cmd /c` wrapper:

```
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

### Managing Servers

| Command | Purpose |
|:--------|:--------|
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Get details for a specific server |
| `claude mcp remove <name>` | Remove a server |
| `/mcp` | Check server status and authenticate (within Claude Code) |
| `claude mcp add-json <name> '<json>'` | Add server from JSON configuration |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS/WSL only) |
| `claude mcp reset-project-choices` | Reset approval choices for project-scoped servers |

### MCP Installation Scopes

| Scope | Flag | Storage | Visibility |
|:------|:-----|:--------|:-----------|
| Local (default) | `--scope local` | `~/.claude.json` under project path | You only, current project |
| Project | `--scope project` | `.mcp.json` at project root (version-controlled) | All team members |
| User | `--scope user` | `~/.claude.json` | You only, all projects |

**Precedence:** local > project > user (same-name conflicts resolved in this order).

Note: MCP "local scope" stores in `~/.claude.json` (home directory), which differs from general local settings that use `.claude/settings.local.json` (project directory).

### `.mcp.json` Project Configuration

Shared team config checked into version control:

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

**Environment variable expansion** in `.mcp.json`:

| Syntax | Behavior |
|:-------|:---------|
| `${VAR}` | Expands to value of `VAR`; fails if unset |
| `${VAR:-default}` | Expands to `VAR` if set, otherwise uses `default` |

Expansion works in `command`, `args`, `env`, `url`, and `headers` fields.

### OAuth 2.0 Authentication

For remote servers requiring authentication:

1. Add the server: `claude mcp add --transport http <name> <url>`
2. Run `/mcp` within Claude Code, follow browser login flow
3. Tokens stored securely, refreshed automatically

**Pre-configured OAuth credentials** (when dynamic registration is unsupported):

| Flag | Purpose |
|:-----|:--------|
| `--client-id <id>` | Pass registered OAuth client ID |
| `--client-secret` | Prompt for client secret (masked input) |
| `--callback-port <port>` | Fix OAuth callback port (must match registered redirect URI) |

Client secret stored in system keychain (macOS) or credentials file, not in config. Set `MCP_CLIENT_SECRET` env var to skip interactive prompt in CI.

Override OAuth metadata discovery with `authServerMetadataUrl` in the `oauth` object of `.mcp.json` config (requires Claude Code v2.1.64+).

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers via `.mcp.json` at plugin root or inline in `plugin.json` (`mcpServers` field). Plugin servers start automatically when the plugin is enabled. Run `/reload-plugins` to reconnect after enabling/disabling a plugin mid-session.

Available environment variables: `${CLAUDE_PLUGIN_ROOT}` (bundled files), `${CLAUDE_PLUGIN_DATA}` (persistent state surviving updates).

### Claude.ai MCP Servers

MCP servers configured at `claude.ai/settings/connectors` are automatically available when logged in with a Claude.ai account. Disable with `ENABLE_CLAUDEAI_MCP_SERVERS=false`.

### Claude Code as MCP Server

Expose Claude Code's tools (View, Edit, LS, etc.) to other MCP clients:

```
claude mcp serve
```

### MCP Output Limits

| Setting | Default | Description |
|:--------|:--------|:------------|
| Warning threshold | 10,000 tokens | Displays warning when any tool output exceeds this |
| `MAX_MCP_OUTPUT_TOKENS` | 25,000 tokens | Maximum allowed MCP output tokens |

### Elicitation

MCP servers can request structured input mid-task:

| Mode | Behavior |
|:-----|:---------|
| Form mode | Interactive dialog with server-defined fields |
| URL mode | Opens browser URL for authentication/approval |

Auto-respond with the `Elicitation` hook.

### MCP Resources

Reference MCP resources with `@` mentions: `@server:protocol://resource/path`. Resources appear in autocomplete alongside files, are fuzzy-searchable, and are fetched automatically as attachments.

### MCP Prompts as Commands

MCP server prompts become `/mcp__servername__promptname` commands. Arguments are passed space-separated. Prompts are dynamically discovered from connected servers.

### MCP Tool Search

Automatically enabled when MCP tool definitions exceed 10% of context window. Tools are deferred and discovered on demand via a search tool.

| `ENABLE_TOOL_SEARCH` value | Behavior |
|:----------------------------|:---------|
| (unset) | Enabled by default; disabled for non-first-party `ANTHROPIC_BASE_URL` |
| `true` | Always enabled |
| `auto` | Activates when MCP tools exceed 10% of context |
| `auto:<N>` | Activates at custom threshold (e.g., `auto:5` for 5%) |
| `false` | Disabled; all MCP tools loaded upfront |

Requires models supporting `tool_reference` blocks (Sonnet 4+, Opus 4+; not Haiku). Disable the MCPSearch tool specifically via `disallowedTools` setting.

For MCP server authors: add descriptive server instructions explaining what tasks your tools handle and when Claude should search for them.

### Managed MCP Configuration

Two approaches for organizational control:

**Option 1: Exclusive control (`managed-mcp.json`)**

Deploy to system-wide directory for complete lockdown:

| Platform | Path |
|:---------|:-----|
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux/WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

Uses same format as `.mcp.json`. Users cannot add, modify, or use any other servers.

**Option 2: Policy-based control (allowlists/denylists)**

Configure `allowedMcpServers` and `deniedMcpServers` in managed settings. Each entry uses exactly one matcher:

| Matcher | Applies to | Example |
|:--------|:-----------|:--------|
| `serverName` | Any server | `{"serverName": "github"}` |
| `serverCommand` | stdio servers (exact match) | `{"serverCommand": ["npx", "-y", "pkg"]}` |
| `serverUrl` | Remote servers (wildcards) | `{"serverUrl": "https://*.company.com/*"}` |

**Allowlist behavior:** `undefined` = no restrictions; `[]` = complete lockdown; list = only matching servers allowed. **Denylist takes absolute precedence** over allowlist. Options 1 and 2 can be combined.

### Dynamic Tool Updates

MCP servers can send `list_changed` notifications to dynamically update available tools, prompts, and resources without reconnecting.

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `MCP_TIMEOUT` | Server startup timeout in ms (e.g., `MCP_TIMEOUT=10000`) |
| `MAX_MCP_OUTPUT_TOKENS` | Max output tokens per MCP tool call |
| `ENABLE_TOOL_SEARCH` | Control tool search behavior |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Enable/disable Claude.ai MCP servers |
| `MCP_CLIENT_SECRET` | OAuth client secret for CI (skip interactive prompt) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) -- what MCP can do (issue trackers, monitoring, databases, designs, workflows), popular MCP servers, installing servers (HTTP/SSE/stdio transports with examples), option ordering, managing servers (list/get/remove, /mcp status), dynamic tool updates (list_changed), scopes (local/project/user with precedence and storage locations), environment variable expansion in .mcp.json (${VAR}, ${VAR:-default}, expansion locations), practical examples (Sentry, GitHub, PostgreSQL), OAuth 2.0 authentication (browser flow, pre-configured credentials with --client-id/--client-secret/--callback-port, authServerMetadataUrl override, CI env var), add-json for JSON config, importing from Claude Desktop, Claude.ai MCP servers (ENABLE_CLAUDEAI_MCP_SERVERS), Claude Code as MCP server (claude mcp serve), output limits and warnings (MAX_MCP_OUTPUT_TOKENS), elicitation requests (form mode, URL mode, Elicitation hook), MCP resources (@mentions, autocomplete), MCP Tool Search (ENABLE_TOOL_SEARCH values, auto threshold, server instructions, model requirements, MCPSearch disallowedTools), MCP prompts as commands (/mcp__server__prompt), plugin-provided MCP servers (.mcp.json or plugin.json, lifecycle, environment variables, transport types), managed MCP configuration (managed-mcp.json exclusive control with system paths, policy-based allowlists/denylists with serverName/serverCommand/serverUrl matchers, URL wildcards, command exact matching, denylist precedence, combined options), Windows npx cmd /c wrapper, scope tips (MCP_TIMEOUT, MAX_MCP_OUTPUT_TOKENS)

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
