---
name: mcp-doc
description: Complete official documentation for connecting Claude Code to external tools via the Model Context Protocol (MCP) — installing servers (HTTP, SSE, stdio), scopes (local, project, user), OAuth and custom authentication, plugin-provided servers, managed configuration, tool search, resources, prompts, elicitation, output limits, and using Claude Code as an MCP server.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools via the Model Context Protocol.

## Quick Reference

MCP (Model Context Protocol) is an open standard for AI-tool integrations. MCP servers give Claude Code access to external tools, databases, and APIs so it can read and act on those systems directly.

### Transport types

| Transport | Flag | Use case | Example |
| :-------- | :--- | :------- | :------ |
| **HTTP** (recommended) | `--transport http` | Cloud-based remote servers | `claude mcp add --transport http notion https://mcp.notion.com/mcp` |
| **SSE** (deprecated) | `--transport sse` | Legacy remote servers | `claude mcp add --transport sse asana https://mcp.asana.com/sse` |
| **stdio** | `--transport stdio` | Local processes needing system access | `claude mcp add --transport stdio db -- npx -y @bytebase/dbhub --dsn "..."` |

Option ordering: all flags (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. Use `--` to separate the server name from the command+args for stdio servers.

Windows (native, not WSL): wrap `npx` commands with `cmd /c` to avoid "Connection closed" errors.

### Management commands

| Command | Purpose |
| :------ | :------ |
| `claude mcp add <name> ...` | Add a server |
| `claude mcp add-json <name> '<json>'` | Add from JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS/WSL only) |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Show details for one server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset approval choices for project-scoped servers |
| `/mcp` | In-session: check status, authenticate, manage servers |

### Installation scopes

| Scope | Flag | Loads in | Shared with team | Stored in |
| :---- | :--- | :------- | :--------------- | :-------- |
| **Local** (default) | `--scope local` | Current project only | No | `~/.claude.json` (under project path) |
| **Project** | `--scope project` | Current project only | Yes (via `.mcp.json` in project root) | `.mcp.json` |
| **User** | `--scope user` | All your projects | No | `~/.claude.json` |

Scope precedence (highest first): Local > Project > User > Plugin-provided > claude.ai connectors. Duplicates matched by name (user scopes) or endpoint (plugins/connectors).

### Environment variable expansion in `.mcp.json`

Supported syntax: `${VAR}` and `${VAR:-default}`. Expansion works in `command`, `args`, `env`, `url`, and `headers` fields. Missing variables without defaults cause a config parse failure.

### OAuth authentication

1. Add the server: `claude mcp add --transport http sentry https://mcp.sentry.dev/mcp`
2. Run `/mcp` in Claude Code and follow the browser login flow
3. Tokens are stored securely and refreshed automatically

Key OAuth flags and options:

| Flag / Field | Purpose |
| :----------- | :------ |
| `--client-id` | Pre-configured OAuth client ID |
| `--client-secret` | Prompt for client secret (masked input); or set `MCP_CLIENT_SECRET` env var |
| `--callback-port` | Fix the OAuth callback port (for pre-registered redirect URIs) |
| `oauth.scopes` | Pin requested OAuth scopes (space-separated string in `.mcp.json`) |
| `oauth.authServerMetadataUrl` | Override OAuth metadata discovery URL (must be `https://`) |

### Dynamic headers (`headersHelper`)

Run an arbitrary command at connection time to generate request headers (for Kerberos, short-lived tokens, internal SSO, etc.). The command must write a JSON object of string key-value pairs to stdout within 10 seconds. Dynamic headers override static `headers` with the same name. Environment variables available to the helper: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`.

### Plugin-provided MCP servers

Plugins can bundle MCP servers via `.mcp.json` at the plugin root or inline in `plugin.json`. Plugin servers start automatically when the plugin is enabled. Use `${CLAUDE_PLUGIN_ROOT}` for bundled files and `${CLAUDE_PLUGIN_DATA}` for persistent state. Run `/reload-plugins` to connect/disconnect plugin MCP servers mid-session.

### Automatic reconnection

HTTP/SSE servers: up to 5 attempts with exponential backoff (starting at 1 second, doubling each time). Shows as pending in `/mcp` during reconnection; marked failed after 5 attempts. Stdio servers are not reconnected automatically.

### Channels (push messages)

MCP servers can push messages into your session by declaring the `claude/channel` capability. Opt in with the `--channels` flag at startup.

### Output limits

| Setting | Default | Purpose |
| :------ | :------ | :------ |
| Warning threshold | 10,000 tokens | Displays a warning when MCP tool output exceeds this |
| `MAX_MCP_OUTPUT_TOKENS` | 25,000 tokens | Maximum allowed MCP output tokens (env var) |
| `anthropic/maxResultSizeChars` | (per-tool) | Tool-level annotation; ceiling 500,000 chars; independent of `MAX_MCP_OUTPUT_TOKENS` for text |

### MCP Tool Search

Enabled by default. MCP tools are deferred (only names loaded at session start) and discovered on demand via a search tool. Requires Sonnet 4+ or Opus 4+ (Haiku not supported).

| `ENABLE_TOOL_SEARCH` value | Behavior |
| :------------------------- | :------- |
| (unset) | All deferred; falls back to upfront if non-first-party `ANTHROPIC_BASE_URL` |
| `true` | All deferred, including non-first-party hosts |
| `auto` | Upfront if fits within 10% context window, deferred otherwise |
| `auto:<N>` | Custom threshold percentage (0-100) |
| `false` | All loaded upfront |

### MCP resources

Reference resources from connected servers using `@server:protocol://resource/path` in prompts. Type `@` to see available resources in autocomplete.

### MCP prompts as commands

MCP server prompts appear as `/mcp__servername__promptname` commands. Arguments are passed space-separated after the command.

### Elicitation

MCP servers can request structured input mid-task. Two modes: form (dialog with fields) and URL (browser flow). Auto-respond using the `Elicitation` hook. No configuration needed on the user side.

### Using Claude Code as an MCP server

```
claude mcp serve
```

Exposes Claude Code's tools (View, Edit, LS, etc.) to other MCP clients. The connecting client is responsible for user confirmation of tool calls.

### Managed MCP configuration

Two enterprise options:

| Option | Method | Effect |
| :----- | :----- | :----- |
| **Exclusive control** | Deploy `managed-mcp.json` to system directory | Users cannot add/modify any MCP servers; only managed servers load |
| **Policy-based** | `allowedMcpServers` / `deniedMcpServers` in managed settings | Users can add servers within policy constraints |

`managed-mcp.json` locations: macOS `/Library/Application Support/ClaudeCode/managed-mcp.json`, Linux/WSL `/etc/claude-code/managed-mcp.json`, Windows `C:\Program Files\ClaudeCode\managed-mcp.json`.

Policy entries match by `serverName`, `serverCommand` (exact array match), or `serverUrl` (wildcard `*` supported). Denylist takes absolute precedence over allowlist. Both options can be combined.

### Environment variables

| Variable | Purpose |
| :------- | :------ |
| `MCP_TIMEOUT` | Server startup timeout in ms (e.g., `MCP_TIMEOUT=10000 claude`) |
| `MAX_MCP_OUTPUT_TOKENS` | Max output tokens per MCP tool call (default 25,000) |
| `ENABLE_TOOL_SEARCH` | Control tool search behavior (see table above) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set to `false` to disable claude.ai MCP servers |
| `MCP_CLIENT_SECRET` | Pre-set OAuth client secret (skips interactive prompt) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — Full guide covering what you can do with MCP, popular servers, installing servers (HTTP/SSE/stdio), managing servers, scopes (local/project/user), environment variable expansion, OAuth authentication (dynamic client registration, pre-configured credentials, metadata override, scope pinning), dynamic headers via `headersHelper`, adding servers from JSON, importing from Claude Desktop, using claude.ai connectors, using Claude Code as an MCP server, output limits and `anthropic/maxResultSizeChars`, elicitation, resources, tool search, prompts as commands, plugin-provided servers, channels, automatic reconnection, and managed MCP configuration (exclusive control and policy-based allowlists/denylists).

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
