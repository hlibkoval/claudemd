---
name: mcp-doc
description: Complete official documentation for Model Context Protocol (MCP) in Claude Code — transports (HTTP, SSE, stdio), installation scopes (local/project/user), OAuth authentication, dynamic headers, JSON config, Claude Desktop import, claude.ai connectors, Claude Code as MCP server, tool search/deferral, resources, elicitation, prompts as commands, managed MCP (managed-mcp.json, allowlists, denylists, org restrictions).
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for Model Context Protocol (MCP) in Claude Code.

## Quick Reference

### Transport Types

| Transport | Command syntax | Use for |
| :--- | :--- | :--- |
| **HTTP** (recommended) | `claude mcp add --transport http <name> <url>` | Remote cloud services |
| **SSE** (deprecated) | `claude mcp add --transport sse <name> <url>` | Legacy remote servers |
| **stdio** | `claude mcp add [--transport stdio] <name> -- <cmd> [args...]` | Local processes needing system access |

In `.mcp.json`, `type: "streamable-http"` is an alias for `"http"`.

### Installation Scopes

| Scope | Loads in | Shared | Stored in |
| :--- | :--- | :--- | :--- |
| `local` (default) | Current project only | No | `~/.claude.json` (under project path) |
| `project` | Current project only | Yes, via `.mcp.json` in repo root | `.mcp.json` (commit to VCS) |
| `user` | All your projects | No | `~/.claude.json` |

Precedence (highest wins): local → project → user → plugin-provided → claude.ai connectors.

Specifying scope: `claude mcp add --scope <local|project|user> ...`

### Key Management Commands

```bash
claude mcp add --transport http <name> <url>          # add HTTP server
claude mcp add --transport http <name> <url> \
  --header "Authorization: Bearer <token>"            # with auth header
claude mcp add --transport stdio <name> -- <cmd>      # add stdio server
claude mcp add --env KEY=value <name> -- <cmd>        # with env var
claude mcp add-json <name> '<json>'                   # add from JSON
claude mcp add-from-claude-desktop                    # import from Desktop (macOS/WSL)
claude mcp list                                       # list all servers
claude mcp get <name>                                 # details for one server
claude mcp remove <name>                              # remove a server
claude mcp reset-project-choices                      # reset project-scope approvals
claude mcp serve                                      # run Claude Code as MCP server
/mcp                                                  # in-session panel: status, auth, reconnect
```

### Environment Variables for MCP

| Variable | Effect |
| :--- | :--- |
| `MCP_TIMEOUT` | Startup timeout in ms (e.g. `MCP_TIMEOUT=10000`) |
| `MCP_TOOL_TIMEOUT` | Per-server default tool execution timeout (ms) |
| `MAX_MCP_OUTPUT_TOKENS` | Warning threshold and default max (default: 25,000) |
| `ENABLE_TOOL_SEARCH` | Tool deferral control (see Tool Search table) |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set `false` to disable claude.ai connectors |

Per-server `timeout` in `.mcp.json` (ms) overrides `MCP_TOOL_TIMEOUT` for that server only.

### Environment Variable Expansion in `.mcp.json`

Supported in `command`, `args`, `env`, `url`, `headers`:

| Syntax | Meaning |
| :--- | :--- |
| `${VAR}` | Expand env var; fail if unset |
| `${VAR:-default}` | Expand env var; use `default` if unset |

Stdio servers receive `CLAUDE_PROJECT_DIR` pointing to the project root. In `.mcp.json` `command`/`args`, use `${CLAUDE_PROJECT_DIR:-.}` as the default.

### OAuth Authentication

Triggered automatically when server responds with `401` or `403`. Use `/mcp` to complete the browser flow.

| Flag | Purpose |
| :--- | :--- |
| `--callback-port <port>` | Fix OAuth callback port to a pre-registered redirect URI |
| `--client-id <id>` | Pre-configured OAuth client ID |
| `--client-secret` | Prompt for client secret (masked input) |
| `MCP_CLIENT_SECRET=<secret>` | Pass secret via env var (non-interactive) |

Set `authServerMetadataUrl` in the `oauth` object of `.mcp.json` to override discovery. Set `oauth.scopes` to pin the scopes requested. OAuth tokens are stored in the system keychain; use "Clear authentication" in `/mcp` to revoke.

### Dynamic Headers (Non-OAuth Auth)

Use `headersHelper` in `.mcp.json` to run a shell command that outputs a JSON object of header key-value pairs at connection time:

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

Helper receives `CLAUDE_CODE_MCP_SERVER_NAME` and `CLAUDE_CODE_MCP_SERVER_URL`. Runs fresh on each connection; 10-second timeout.

### Tool Search (Deferral)

Tool search is enabled by default: only tool names load at session start; schemas are fetched on demand via `ToolSearch`. Reduces context usage when many MCP servers are connected.

| `ENABLE_TOOL_SEARCH` value | Behavior |
| :--- | :--- |
| (unset) | Deferred (default); falls back to upfront on Vertex AI or non-first-party `ANTHROPIC_BASE_URL` |
| `true` | Force deferred everywhere (may fail on older Vertex models or unsupporting proxies) |
| `auto` | Threshold mode: upfront if tools fit within 10% of context window |
| `auto:N` | Threshold mode with custom N% (0–100) |
| `false` | All tools loaded upfront |

Requires models that support `tool_reference` blocks: Sonnet 4 or later, Opus 4 or later. Not supported on Haiku.

Set `alwaysLoad: true` on a server entry in `.mcp.json` to always load that server's tools upfront (requires v2.1.121+). Individual tools can set `"anthropic/alwaysLoad": true` in their `_meta` object.

### Output Limits

| Setting | Default |
| :--- | :--- |
| Warning threshold | 10,000 tokens |
| Maximum tokens (`MAX_MCP_OUTPUT_TOKENS`) | 25,000 |
| Per-tool override via `_meta["anthropic/maxResultSizeChars"]` | Up to 500,000 chars |

`anthropic/maxResultSizeChars` applies only to text content; image content is always subject to `MAX_MCP_OUTPUT_TOKENS`.

### MCP Prompts as Commands

MCP prompts appear as slash commands in the format `/mcp__<servername>__<promptname>`. Pass arguments space-separated after the command name. Server and prompt names are normalized (spaces become underscores).

### MCP Resources

Reference exposed resources via `@<server>:<protocol>://<path>` in prompts. Type `@` to see the autocomplete list.

### Plugin-Provided MCP Servers

Plugins can bundle MCP servers in `.mcp.json` at plugin root or inline in `plugin.json`. Use `${CLAUDE_PLUGIN_ROOT}` for bundled files, `${CLAUDE_PLUGIN_DATA}` for persistent state, `${CLAUDE_PROJECT_DIR}` for the project root. Plugin servers appear in `/mcp` with a plugin indicator. Run `/reload-plugins` to connect/disconnect after enabling/disabling a plugin mid-session.

### Claude Code as MCP Server

```bash
claude mcp serve          # start as stdio MCP server
```

Add to Claude Desktop's `claude_desktop_config.json` under `mcpServers` with `"command": "claude"` and `"args": ["mcp", "serve"]`.

### Reconnection Behavior

HTTP/SSE servers: exponential backoff, up to 5 attempts (1s, 2s, 4s, 8s, 16s), then marked failed. Initial connection: up to 3 retries on transient errors (5xx, connection refused, timeout). Use `/mcp` to retry manually. Stdio servers are not auto-reconnected.

---

## Managed MCP (Admin Control)

### Restriction Patterns

| Pattern | Configuration |
| :--- | :--- |
| Disable MCP entirely | `managed-mcp.json` with `{ "mcpServers": {} }` |
| Fixed server set | `managed-mcp.json` with desired servers |
| Approved catalog | `allowedMcpServers` + `allowManagedMcpServersOnly: true` |
| Plugin servers only | `strictPluginOnlyCustomization` with `mcp` in the list |
| Soft allowlist | `allowedMcpServers` without `allowManagedMcpServersOnly` |
| Denylist only | `deniedMcpServers` |

### managed-mcp.json Paths

| Platform | Path |
| :--- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux and WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

When present, `managed-mcp.json` grants exclusive control: users cannot add, modify, or use any other MCP servers. Claude.ai connectors are also suppressed unless `allowAllClaudeAiMcps: true` is set in a managed settings source (requires v2.1.149+).

### Allowlist/Denylist Match Keys

| Key | Matches | Use for |
| :--- | :--- | :--- |
| `serverUrl` | Remote server URL (exact or `*` wildcard) | HTTP and SSE servers |
| `serverCommand` | Exact command array including all args | Stdio servers |
| `serverName` | User-assigned label (exact, no wildcards) | Fallback only; not a security control |

`allowedMcpServers: []` blocks all servers. Unset = all servers allowed.  
Denylist always takes precedence over allowlist. Denylist entries merge from all settings sources.  
`allowManagedMcpServersOnly: true` locks the allowlist to managed sources only.

### URL Wildcard Patterns

| Pattern | Matches |
| :--- | :--- |
| `https://mcp.example.com/*` | All paths on that domain |
| `https://mcp.example.com` | Also all paths (no-path pattern matches any path) |
| `https://*.example.com/*` | Any subdomain |
| `http://localhost:*/*` | Any port on localhost |
| `*://mcp.example.com/*` | Any scheme |

Hostname matching is case-insensitive. Command matching is exact (all args in order).

### Error Messages Users See

| Situation | Message |
| :--- | :--- |
| `managed-mcp.json` present, user runs `claude mcp add` | `Cannot add MCP server: enterprise MCP configuration is active and has exclusive control over MCP servers` |
| Server on denylist, user runs `claude mcp add` | `Cannot add MCP server "<name>": server is explicitly blocked by enterprise policy` |
| Server not on allowlist, user runs `claude mcp add` | `Cannot add MCP server "<name>": not allowed by enterprise policy` |
| Previously configured server now blocked | Server silently disappears from `/mcp` and `claude mcp list` |

### Managed MCP Settings Summary

| Setting | Controls | Delivered via |
| :--- | :--- | :--- |
| `managed-mcp.json` | Fixed server set, exclusive control | MDM / GPO / fleet management (system path) |
| `allowedMcpServers` | Allowlist (merge unless `allowManagedMcpServersOnly`) | Any settings file; use managed source for enforcement |
| `deniedMcpServers` | Denylist (always merges from all sources) | Any settings file |
| `allowManagedMcpServersOnly` | Locks allowlist to managed sources | Managed settings sources only |
| `allowAllClaudeAiMcps` | Load claude.ai connectors alongside managed set | Managed settings sources only |

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — transports, scopes, OAuth, headersHelper, tool search, resources, elicitation, prompts as commands, plugin-provided servers, Claude Code as MCP server
- [Control MCP server access for your organization](references/claude-code-managed-mcp.md) — managed-mcp.json, allowlists, denylists, restriction patterns, user-facing errors, monitoring

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
- Control MCP server access for your organization: https://code.claude.com/docs/en/managed-mcp.md
