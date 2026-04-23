---
name: mcp-doc
description: Complete official documentation for connecting Claude Code to tools via the Model Context Protocol (MCP) — adding/managing servers, scopes, authentication, tool search, output limits, managed configuration, and using Claude Code as an MCP server.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools via MCP.

## Quick Reference

MCP (Model Context Protocol) lets Claude Code connect to external tools, databases, and APIs. Servers are added via `claude mcp add` and appear as tools in every session.

### CLI commands

| Command | Description |
| :--- | :--- |
| `claude mcp add --transport http <name> <url>` | Add a remote HTTP server (recommended) |
| `claude mcp add --transport sse <name> <url>` | Add a remote SSE server (deprecated) |
| `claude mcp add [options] <name> -- <cmd> [args...]` | Add a local stdio server |
| `claude mcp add-json <name> '<json>'` | Add a server from a JSON config blob |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS/WSL only) |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Show details for a specific server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset project-scope approval choices |
| `claude mcp serve` | Run Claude Code itself as an MCP server |
| `/mcp` | In-session: check server status, authenticate via OAuth |

**Option ordering**: All flags (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. Use `--` to separate server name from the command passed to the server.

### Common flags

| Flag | Description |
| :--- | :--- |
| `--transport http\|sse\|stdio` | Transport type (default: stdio) |
| `--scope local\|project\|user` | Where to store the config (default: local) |
| `--env KEY=value` | Set environment variables for the server |
| `--header "Key: Value"` | Add HTTP request headers |
| `--callback-port <port>` | Fix the OAuth callback port |
| `--client-id <id>` | Pre-configured OAuth client ID |
| `--client-secret` | Prompt for OAuth client secret (masked) |

### MCP installation scopes

| Scope | Loads in | Shared with team | Stored in |
| :--- | :--- | :--- | :--- |
| `local` (default) | Current project only | No | `~/.claude.json` |
| `project` | Current project only | Yes, via version control | `.mcp.json` in project root |
| `user` | All your projects | No | `~/.claude.json` |

**Precedence** (highest wins): local → project → user → plugin-provided → claude.ai connectors. Scopes match by name; plugins/connectors match by endpoint URL.

### Environment variable expansion in `.mcp.json`

Supported in `command`, `args`, `env`, `url`, and `headers`:

- `${VAR}` — value of `VAR`
- `${VAR:-default}` — value of `VAR`, or `default` if unset

### OAuth authentication

Run `/mcp` inside Claude Code and follow the browser login flow. Tokens are stored securely and refreshed automatically. Use "Clear authentication" in the `/mcp` menu to revoke.

**Pre-configured credentials** (when server doesn't support dynamic client registration):

```bash
claude mcp add --transport http \
  --client-id your-client-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

**Override OAuth metadata discovery** — set `authServerMetadataUrl` in the server's `oauth` object in `.mcp.json` (requires v2.1.64+):

```json
{ "oauth": { "authServerMetadataUrl": "https://auth.example.com/.well-known/openid-configuration" } }
```

**Restrict OAuth scopes** — set `oauth.scopes` to a space-separated string (RFC 6749 §3.3 format). Takes precedence over server-advertised scopes.

**Dynamic headers** (`headersHelper`) — for non-OAuth auth schemes. Runs a shell command at connection time; output must be a JSON object of string key-value pairs. Available env vars: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL`.

### MCP tool search

Tool search defers MCP tool definitions and loads only tool names at session start, keeping context usage low.

| `ENABLE_TOOL_SEARCH` value | Behavior |
| :--- | :--- |
| (unset) | All tools deferred; falls back to upfront loading for non-first-party `ANTHROPIC_BASE_URL` |
| `true` | All tools deferred, including non-first-party base URLs |
| `auto` | Threshold mode: upfront if within 10% of context window, deferred otherwise |
| `auto:<N>` | Threshold mode with custom percentage (0–100) |
| `false` | All tools loaded upfront |

Requires Sonnet 4+ or Opus 4+. Haiku does not support tool search.

To disable the `ToolSearch` tool specifically, add `"ToolSearch"` to `permissions.deny` in settings.json.

### MCP output limits

| Setting | Default | Notes |
| :--- | :--- | :--- |
| Warning threshold | 10,000 tokens | Displays warning when exceeded |
| Default maximum | 25,000 tokens | Applies to tools without a declared limit |
| `MAX_MCP_OUTPUT_TOKENS` env var | — | Override the per-tool default maximum |
| `anthropic/maxResultSizeChars` in `tools/list` | — | Per-tool ceiling (up to 500,000 chars); overrides env var for text content |

### MCP resources and prompts

- Reference MCP resources with `@server:protocol://resource/path` mentions
- MCP prompts become slash commands: `/mcp__servername__promptname [args]`

### Dynamic tool updates and reconnection

- Servers that send `list_changed` notifications are refreshed automatically
- HTTP/SSE servers reconnect with exponential backoff (up to 5 attempts, starting at 1s, doubling each time)
- After 5 failed attempts, the server is marked failed; retry from `/mcp`
- Stdio servers are not automatically reconnected

### Channels (push messages into sessions)

MCP servers can push external events (CI results, alerts, chat messages) directly into a session. Requires the server to declare the `claude/channel` capability and enabling with `--channels` at startup.

### Plugin-provided MCP servers

Plugins can bundle MCP servers in `.mcp.json` at the plugin root or inline in `plugin.json`. Plugin servers start automatically, appear in `/mcp`, and use `${CLAUDE_PLUGIN_ROOT}` and `${CLAUDE_PLUGIN_DATA}` for paths.

### Using Claude Code as an MCP server

```bash
claude mcp serve
```

Add to `claude_desktop_config.json` with `"command": "claude"` and `"args": ["mcp", "serve"]`. Exposes Claude's built-in tools (View, Edit, LS, etc.) to the MCP client.

### Windows (native, not WSL)

Wrap `npx` commands with `cmd /c`:

```bash
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

### Managed MCP configuration (enterprise)

**Option 1 — Exclusive control** (`managed-mcp.json`): deploy a fixed set; users cannot add others.

System paths:
- macOS: `/Library/Application Support/ClaudeCode/managed-mcp.json`
- Linux/WSL: `/etc/claude-code/managed-mcp.json`
- Windows: `C:\Program Files\ClaudeCode\managed-mcp.json`

**Option 2 — Policy-based** (`allowedMcpServers` / `deniedMcpServers` in managed settings): users can add servers within policy constraints.

Each entry uses exactly one of: `serverName`, `serverCommand` (exact array match), or `serverUrl` (supports `*` wildcards).

- Denylist takes absolute precedence over allowlist
- Empty allowlist `[]` = complete lockdown
- `undefined` allowlist = no restrictions

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — full guide covering what you can do with MCP, popular servers, installing and managing servers (HTTP/SSE/stdio), scopes, environment variable expansion, OAuth authentication, dynamic headers, tool search, output limits, MCP elicitation, resources, prompts, channels, plugin-provided servers, using Claude Code as an MCP server, and enterprise managed configuration.

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
