---
name: mcp-doc
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to external tools via the Model Context Protocol (MCP): adding and managing servers, scopes, authentication, org-level access control, and tool search.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude mcp add --transport http <name> <url>` | Add a remote HTTP server |
| `claude mcp add --transport sse <name> <url>` | Add a remote SSE server (deprecated) |
| `claude mcp add [--transport stdio] <name> -- <cmd> [args...]` | Add a local stdio server |
| `claude mcp add-json <name> '<json>'` | Add a server from raw JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS/WSL) |
| `claude mcp list` | List all configured servers and status |
| `claude mcp get <name>` | Show details for a specific server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset .mcp.json approval choices |
| `claude mcp serve` | Run Claude Code itself as an MCP server |
| `/mcp` (in-session) | View status, authenticate, reconnect servers |

### Transport Types

| Transport | Type value | Use for | Auth support |
|:----------|:-----------|:--------|:-------------|
| HTTP (streamable-http) | `http` / `streamable-http` | Cloud services (recommended) | OAuth, headers |
| SSE | `sse` | Legacy remote servers (deprecated) | Headers |
| stdio | `stdio` | Local processes, scripts, system tools | Env vars |
| WebSocket | `ws` | Persistent bidirectional event-push servers | Headers only (no OAuth) |

### Installation Scopes

| Scope | `--scope` flag | Stored in | Shared? |
|:------|:--------------|:----------|:--------|
| Local (default) | `local` | `~/.claude.json` under this project | No |
| Project | `project` | `.mcp.json` in project root | Yes, via version control |
| User | `user` | `~/.claude.json` top-level | No (all your projects) |

Precedence (highest wins): local > project > user > plugin-provided > claude.ai connectors.

### Connection Status Indicators

| Status | Meaning |
|:-------|:--------|
| `✓ Connected` | Ready to use |
| `! Needs authentication` | Requires browser OAuth sign-in |
| `✗ Failed to connect` | Server didn't respond |
| `✗ Connection error` | Connection threw an error |
| `⏸ Pending approval` | Project-scoped server awaiting your approval |

### .mcp.json Format

```json
{
  "mcpServers": {
    "my-http-server": {
      "type": "http",
      "url": "https://mcp.example.com/mcp",
      "headers": { "Authorization": "Bearer ${API_KEY}" }
    },
    "my-stdio-server": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "some-mcp-package"],
      "env": { "KEY": "value" }
    }
  }
}
```

Environment variable expansion in `.mcp.json`: `${VAR}` and `${VAR:-default}` work in `command`, `args`, `env`, `url`, and `headers`.

### OAuth Authentication Options

| Flag / field | Description |
|:-------------|:------------|
| `--header "Authorization: Bearer TOKEN"` | Static token (no browser sign-in) |
| `/mcp` then Authenticate | Browser OAuth flow |
| `--callback-port PORT` | Fix the OAuth redirect port |
| `--client-id ID --client-secret` | Pre-configured OAuth credentials |
| `oauth.authServerMetadataUrl` | Override OAuth discovery URL (v2.1.64+) |
| `oauth.scopes` | Pin requested OAuth scopes (space-separated) |
| `headersHelper` | Shell command that outputs JSON headers at connect time |

### MCP Tool Search (ENABLE_TOOL_SEARCH)

Enabled by default. Defers tool definitions until Claude needs them, keeping context usage low.

| Value | Behavior |
|:------|:---------|
| (unset) | All MCP tools deferred; falls back to upfront load on Vertex AI / non-first-party base URL |
| `true` | All MCP tools deferred; forces deferral even on Vertex AI |
| `auto` | Threshold mode: load upfront if schemas fit within 10% of context window |
| `auto:N` | Threshold mode with custom percentage N (0–100) |
| `false` | All MCP tools loaded upfront, no deferral |

Set `alwaysLoad: true` in a server's config entry to always load that server's tools upfront.

### MCP Output Limits

| Config | Default | Description |
|:-------|:--------|:------------|
| `MAX_MCP_OUTPUT_TOKENS` env var | 25,000 tokens | Max output tokens per tool call |
| Warning threshold | 10,000 tokens | Warning shown in UI |
| `anthropic/maxResultSizeChars` in `_meta` | Up to 500,000 chars | Per-tool override set by server author |

### Managed MCP (Enterprise Admin)

| Pattern | How to configure |
|:--------|:----------------|
| Disable MCP entirely | `managed-mcp.json` with empty `mcpServers: {}` |
| Fixed server set | `managed-mcp.json` with the desired servers |
| Approved catalog (hard allowlist) | `allowedMcpServers` + `allowManagedMcpServersOnly: true` |
| Soft allowlist (user-extendable) | `allowedMcpServers` without `allowManagedMcpServersOnly` |
| Denylist only | `deniedMcpServers` |

`managed-mcp.json` system paths:

| Platform | Path |
|:---------|:-----|
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux / WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

Allowlist / denylist entry keys: `serverUrl` (wildcard `*` supported), `serverCommand` (exact match), `serverName` (exact, not a security control alone). Denylist always takes precedence and merges from all settings sources.

### Key Environment Variables

| Variable | Description |
|:---------|:------------|
| `MCP_TIMEOUT` | Server startup timeout in ms (default 30 s) |
| `MCP_TOOL_TIMEOUT` | Per-tool execution timeout in ms |
| `MAX_MCP_OUTPUT_TOKENS` | Max tool output tokens (default 25,000) |
| `ENABLE_TOOL_SEARCH` | Control tool search behavior (see table above) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set to `false` to disable claude.ai connectors |
| `CLAUDE_PROJECT_DIR` | Set in stdio server's env; points to project root |
| `OTEL_LOG_TOOL_DETAILS` | Set to `1` to log MCP server/tool names in telemetry |

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — Full reference: transports, scopes, authentication, OAuth, tool search, resources, prompts, plugin MCP servers, output limits, elicitation
- [Control MCP server access for your organization](references/claude-code-managed-mcp.md) — Admin guide: managed-mcp.json, allowlists, denylists, policies, and monitoring MCP usage
- [Connect to MCP servers (Quickstart)](references/claude-code-mcp-quickstart.md) — Step-by-step walkthrough: add a server, check status, change scope, troubleshoot common errors

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
- Control MCP server access for your organization: https://code.claude.com/docs/en/managed-mcp.md
- Connect to MCP servers (Quickstart): https://code.claude.com/docs/en/mcp-quickstart.md
