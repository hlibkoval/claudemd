---
name: mcp-doc
description: Complete documentation for connecting Claude Code to external tools via MCP (Model Context Protocol). Covers MCP server installation (HTTP, SSE, stdio transports), server management CLI commands (add, list, get, remove), installation scopes (local, project, user), scope precedence, .mcp.json project configuration with environment variable expansion, OAuth 2.0 authentication (dynamic client registration, pre-configured credentials, callback port, metadata override), dynamic headers via headersHelper, JSON configuration (add-json), importing from Claude Desktop (add-from-claude-desktop), Claude.ai connector servers (ENABLE_CLAUDEAI_MCP_SERVERS), using Claude Code as an MCP server (mcp serve), MCP output limits (MAX_MCP_OUTPUT_TOKENS, anthropic/maxResultSizeChars annotation), elicitation requests (form mode, URL mode), MCP resources (@ mentions), MCP prompts as commands (/mcp__server__prompt), Tool Search (ENABLE_TOOL_SEARCH, deferred tool loading, threshold mode), dynamic tool updates (list_changed notifications), push messages with channels (claude/channel capability), plugin-provided MCP servers (CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA), managed MCP configuration (managed-mcp.json, allowedMcpServers, deniedMcpServers, serverName, serverCommand, serverUrl restrictions), Windows npx workaround (cmd /c), and MCP_TIMEOUT configuration. Load when discussing MCP, Model Context Protocol, MCP servers, mcp add, mcp remove, mcp list, mcp get, mcp serve, .mcp.json, MCP scopes, MCP authentication, OAuth MCP, MCP elicitation, MCP resources, MCP prompts, Tool Search, ENABLE_TOOL_SEARCH, MAX_MCP_OUTPUT_TOKENS, managed MCP, allowedMcpServers, deniedMcpServers, managed-mcp.json, MCP channels, headersHelper, MCP output limits, MCP plugin servers, add-from-claude-desktop, or any MCP-related topic for Claude Code.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools and data sources through the Model Context Protocol (MCP).

## Quick Reference

### Transport Types

| Transport | Flag | Use case | Example |
|:----------|:-----|:---------|:--------|
| HTTP (recommended) | `--transport http` | Remote cloud services | `claude mcp add --transport http notion https://mcp.notion.com/mcp` |
| SSE (deprecated) | `--transport sse` | Legacy remote servers | `claude mcp add --transport sse asana https://mcp.asana.com/sse` |
| stdio | `--transport stdio` | Local processes | `claude mcp add --transport stdio --env KEY=val myserver -- npx -y pkg` |

### CLI Commands

| Command | Description |
|:--------|:-----------|
| `claude mcp add [opts] <name> [-- cmd args...]` | Add a server (options before name, `--` before command) |
| `claude mcp add-json <name> '<json>'` | Add server from JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS/WSL only) |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Show details for a server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset project-scope approval decisions |
| `claude mcp serve` | Run Claude Code itself as an MCP server |
| `/mcp` | In-session: view status, authenticate, manage servers |

### Installation Scopes

| Scope | Flag | Storage | Visibility |
|:------|:-----|:--------|:-----------|
| Local (default) | `--scope local` | `~/.claude.json` (per-project path) | Private, current project only |
| Project | `--scope project` | `.mcp.json` in project root (commit to VCS) | Shared with team |
| User | `--scope user` | `~/.claude.json` (global section) | Private, all projects |

**Precedence:** local > project > user. Local also overrides Claude.ai connector entries.

### .mcp.json Format

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

**Environment variable expansion** in `.mcp.json`: `${VAR}` or `${VAR:-default}`. Supported in `command`, `args`, `env`, `url`, and `headers`. Missing vars with no default cause a parse error.

### OAuth Authentication

| Method | Usage |
|:-------|:------|
| Dynamic client registration | Default -- just add server, then `/mcp` to authenticate |
| Pre-configured credentials | `--client-id ID --client-secret` (secret prompted with masked input) |
| Fixed callback port | `--callback-port PORT` (matches pre-registered redirect URI `http://localhost:PORT/callback`) |
| CI / env var secret | `MCP_CLIENT_SECRET=secret claude mcp add ...` |
| Metadata override | Set `oauth.authServerMetadataUrl` in JSON config to bypass default discovery |

**Tips:** tokens stored in system keychain (macOS) or credentials file. Use `/mcp` > "Clear authentication" to revoke.

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

- Command must output JSON object of string key-value pairs to stdout
- 10-second timeout; runs on each connection (no caching)
- Overrides static `headers` with same name
- Environment: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`

### Output Limits

| Setting | Default | Description |
|:--------|:--------|:-----------|
| Warning threshold | 10,000 tokens | Warning displayed when exceeded |
| `MAX_MCP_OUTPUT_TOKENS` | 25,000 tokens | Maximum allowed per tool call |
| `anthropic/maxResultSizeChars` | -- | Per-tool annotation (up to 500,000 chars); raises persist-to-disk threshold |

Results exceeding the persist threshold are saved to disk and replaced with a file reference.

### Tool Search

| `ENABLE_TOOL_SEARCH` | Behavior |
|:----------------------|:---------|
| (unset) | All MCP tools deferred (falls back to upfront for non-first-party `ANTHROPIC_BASE_URL`) |
| `true` | All MCP tools deferred, including non-first-party hosts |
| `auto` | Upfront if fits within 10% of context window, deferred otherwise |
| `auto:<N>` | Custom threshold percentage (0-100) |
| `false` | All MCP tools loaded upfront |

Requires Sonnet 4+ or Opus 4+. Haiku does not support tool search. Disable the tool with `"permissions": {"deny": ["ToolSearch"]}`.

### Elicitation

MCP servers can request structured input mid-task:

- **Form mode**: interactive dialog with server-defined fields
- **URL mode**: opens browser for authentication/approval
- Auto-respond via the `Elicitation` hook

### MCP Resources

Reference resources with `@server:protocol://path` in prompts. Resources appear in `@` autocomplete alongside files.

### MCP Prompts as Commands

Server-exposed prompts available as `/mcp__servername__promptname`. Arguments passed space-separated.

### Plugin-Provided MCP Servers

Plugins define servers in `.mcp.json` at plugin root or inline in `plugin.json`. Environment variables: `${CLAUDE_PLUGIN_ROOT}` for bundled files, `${CLAUDE_PLUGIN_DATA}` for persistent state. Use `/reload-plugins` to connect/disconnect after enabling/disabling plugins mid-session.

### Claude.ai Connector Servers

Servers configured at `claude.ai/settings/connectors` are automatically available when logged in with a Claude.ai account. Disable with `ENABLE_CLAUDEAI_MCP_SERVERS=false`.

### Managed MCP Configuration

| Option | Mechanism | Effect |
|:-------|:----------|:-------|
| Exclusive control | `managed-mcp.json` file | Only managed servers allowed; users cannot add any |
| Allowlist | `allowedMcpServers` in managed settings | Users may add servers matching entries only |
| Denylist | `deniedMcpServers` in managed settings | Matching servers blocked (overrides allowlist) |

**managed-mcp.json locations:**

- macOS: `/Library/Application Support/ClaudeCode/managed-mcp.json`
- Linux/WSL: `/etc/claude-code/managed-mcp.json`
- Windows: `C:\Program Files\ClaudeCode\managed-mcp.json`

**Restriction entry types** (each entry has exactly one):

| Field | Matches |
|:------|:--------|
| `serverName` | Configured server name |
| `serverCommand` | Exact command + args array (stdio only) |
| `serverUrl` | URL pattern with `*` wildcards (remote only) |

**Allowlist values:** `undefined` = no restrictions; `[]` = complete lockdown; list = only matching servers allowed.

### Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `MCP_TIMEOUT` | Server startup timeout in ms (e.g., `MCP_TIMEOUT=10000 claude`) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens per MCP tool output (default 25,000) |
| `ENABLE_TOOL_SEARCH` | Control tool search behavior |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Enable/disable Claude.ai connector servers |

### Windows Note

On native Windows (not WSL), `npx`-based stdio servers require the `cmd /c` wrapper:

```bash
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) -- Full MCP guide covering transports, scopes, authentication, managed configuration, tool search, elicitation, resources, prompts, and practical examples

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
