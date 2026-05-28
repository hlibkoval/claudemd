---
name: mcp-doc
description: Complete official documentation for connecting Claude Code to tools via MCP — installing servers (HTTP, SSE, stdio transports), scopes (local, project, user), authentication (OAuth 2.0, static headers, headersHelper), environment variable expansion, MCP tool search, managed/enterprise MCP restrictions (managed-mcp.json, allowlists, denylists), plugin-provided MCP servers, MCP resources and prompts, and using Claude Code itself as an MCP server.
user-invocable: false
---

# MCP Documentation

This skill provides the complete official documentation for connecting Claude Code to tools via the Model Context Protocol (MCP).

## Quick Reference

### CLI Commands

| Command | Description |
| :--- | :--- |
| `claude mcp add --transport http <name> <url>` | Add a remote HTTP server |
| `claude mcp add --transport sse <name> <url>` | Add a remote SSE server (deprecated) |
| `claude mcp add [--transport stdio] <name> -- <cmd> [args...]` | Add a local stdio server |
| `claude mcp add-json <name> '<json>'` | Add a server from raw JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop (macOS/WSL only) |
| `claude mcp list` | List all configured servers |
| `claude mcp get <name>` | Show details for a server |
| `claude mcp remove <name>` | Remove a server |
| `claude mcp reset-project-choices` | Reset project-scoped approval prompts |
| `claude mcp serve` | Run Claude Code itself as a stdio MCP server |
| `/mcp` | (In-session) Show server status, tool counts, OAuth flows |

All options (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. Use `--` to separate the server name from the command and its arguments when adding a stdio server.

### Scope Hierarchy

| Scope | Flag | Loads in | Shared | Stored in |
| :--- | :--- | :--- | :--- | :--- |
| Local (default) | `--scope local` | Current project only | No | `~/.claude.json` |
| Project | `--scope project` | Current project only | Yes (via VCS) | `.mcp.json` in project root |
| User | `--scope user` | All projects | No | `~/.claude.json` |
| Plugin-provided | — | Where plugin is enabled | Via plugin | Plugin definition |
| claude.ai connectors | — | When logged in via Claude.ai | Via Claude.ai admin | claude.ai account |

When the same server name is defined in more than one scope, the highest-precedence source wins (local > project > user > plugin > claude.ai connector). Fields are not merged across scopes.

### Server Configuration Fields (JSON)

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `http` (or alias `streamable-http`), `sse`, or `stdio` |
| `url` | HTTP/SSE | Server endpoint URL |
| `command` | Stdio | Executable to run |
| `args` | No | Command-line arguments array |
| `env` | No | Environment variables passed to the server |
| `headers` | HTTP/SSE | Static request headers (e.g. `Authorization`) |
| `headersHelper` | No | Shell command that outputs a JSON object of headers at connect time |
| `oauth` | No | OAuth config object: `clientId`, `callbackPort`, `authServerMetadataUrl`, `scopes` |
| `timeout` | No | Per-tool-call wall-clock timeout in milliseconds (overrides `MCP_TOOL_TIMEOUT`) |
| `alwaysLoad` | No | `true` to load tools upfront even when tool search is active (v2.1.121+) |

### Environment Variable Expansion in `.mcp.json`

Supported in `command`, `args`, `env`, `url`, and `headers` fields:

| Syntax | Behavior |
| :--- | :--- |
| `${VAR}` | Expands to value of `VAR`; fails if unset |
| `${VAR:-default}` | Expands to `VAR` if set, otherwise `default` |
| `${CLAUDE_PLUGIN_ROOT}` | Path to the plugin root (plugin-provided configs only) |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |
| `${CLAUDE_PROJECT_DIR}` | Stable project root (plugin configs); use `${CLAUDE_PROJECT_DIR:-.}` in user/project `.mcp.json` |

### Authentication Options

| Method | When to use | How |
| :--- | :--- | :--- |
| Static header | Fixed API key | `--header "Authorization: Bearer <token>"` |
| OAuth 2.0 | Cloud services with login flow | Run `/mcp` and follow browser flow |
| Fixed callback port | Pre-registered OAuth redirect URI | `--callback-port <port>` |
| Pre-configured OAuth credentials | Server requires manual client registration | `--client-id <id> --client-secret --callback-port <port>` |
| `headersHelper` | Kerberos, short-lived tokens, SSO | Shell script that writes JSON headers to stdout |
| `${VAR}` expansion | Secrets from user environment | Reference env vars in `.mcp.json` |

For `headersHelper`, Claude Code sets `CLAUDE_CODE_MCP_SERVER_NAME` and `CLAUDE_CODE_MCP_SERVER_URL` in the helper's environment. The helper runs on every connection (no caching). It runs in a shell with a 10-second timeout.

### OAuth Configuration Fields (`oauth` object)

| Field | Description |
| :--- | :--- |
| `clientId` | Pre-registered OAuth client ID |
| `callbackPort` | Fixed local port for the OAuth redirect (format: `http://localhost:PORT/callback`) |
| `authServerMetadataUrl` | Override the OAuth metadata discovery URL (must use `https://`; requires v2.1.64+) |
| `scopes` | Space-separated scope string to pin requested scopes (takes precedence over server-advertised scopes) |

### Key Environment Variables

| Variable | Default | Effect |
| :--- | :--- | :--- |
| `MCP_TIMEOUT` | — | Server startup timeout in ms (e.g. `MCP_TIMEOUT=10000`) |
| `MCP_TOOL_TIMEOUT` | — | Per-tool-call timeout in ms; per-server `timeout` field overrides this |
| `MAX_MCP_OUTPUT_TOKENS` | 25000 | Max tokens per tool output (warning at 10,000) |
| `ENABLE_TOOL_SEARCH` | (unset) | See Tool Search table below |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | `true` | Set to `false` to disable claude.ai connectors |

### MCP Tool Search

Enabled by default. Defers all MCP tool definitions until Claude searches for them, keeping context usage low.

| `ENABLE_TOOL_SEARCH` value | Behavior |
| :--- | :--- |
| (unset) | All tools deferred on demand; falls back to upfront on Vertex AI or non-first-party `ANTHROPIC_BASE_URL` |
| `true` | Force deferral even on Vertex AI / proxies; fails on unsupported models |
| `auto` | Threshold mode: load upfront if tools fit within 10% of context, defer otherwise |
| `auto:N` | Threshold mode with a custom `N`% threshold (0–100) |
| `false` | All tools loaded upfront, no deferral |

Requires Sonnet 4+ or Opus 4+ (on Vertex AI: Sonnet 4.5+ or Opus 4.5+). To exempt one server from deferral, set `"alwaysLoad": true` in its config. To deny `ToolSearch` entirely, add `"ToolSearch"` to `permissions.deny`.

### Output Limits

| Setting | Default | Notes |
| :--- | :--- | :--- |
| Warning threshold | 10,000 tokens | Displayed per tool output |
| Hard cap (`MAX_MCP_OUTPUT_TOKENS`) | 25,000 tokens | Applies to tools without `anthropic/maxResultSizeChars` |
| Per-tool annotation (`_meta["anthropic/maxResultSizeChars"]`) | — | Raises that tool's threshold up to 500,000 chars for text content; image data still uses token cap |

### MCP Prompts (Commands)

MCP servers can expose prompts that appear as in-session commands with the format `/mcp__<servername>__<promptname>`. Pass arguments space-separated after the command.

### MCP Resources (@ Mentions)

Reference resources exposed by MCP servers using `@server:protocol://resource/path`. Resources appear alongside files in the `@` autocomplete menu.

### Plugin-Provided MCP Servers

Plugins define MCP servers in `.mcp.json` at the plugin root or inline in `plugin.json`. Available plugin env vars: `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`, `${CLAUDE_PROJECT_DIR}`. After enabling or disabling a plugin mid-session, run `/reload-plugins` to connect or disconnect its servers.

### Reserved Server Name

The name `workspace` is reserved for internal use. A server configured with that name is skipped at load time with a warning.

### Managed / Enterprise MCP Control

For administrators needing centralized control. Full details in the [managed-mcp reference](references/claude-code-managed-mcp.md).

#### Control Patterns

| Pattern | What it does | Configuration |
| :--- | :--- | :--- |
| Disable MCP | No servers load anywhere | `managed-mcp.json` with empty `mcpServers: {}` |
| Fixed deployment | All users get the same servers; can't add others | `managed-mcp.json` with desired servers |
| Approved catalog | Users pick from approved list; anything else blocked | `allowedMcpServers` + `allowManagedMcpServersOnly: true` |
| Plugin servers only | Servers can only come from plugins | `strictPluginOnlyCustomization` with `mcp` |
| Soft allowlist | Enforce allowlist that users can broaden | `allowedMcpServers` without `allowManagedMcpServersOnly` |
| Denylist only | Block known-bad servers | `deniedMcpServers` |
| No restrictions | Users add anything | No managed MCP config deployed |

#### `managed-mcp.json` File Paths

| Platform | Path |
| :--- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-mcp.json` |
| Linux / WSL | `/etc/claude-code/managed-mcp.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-mcp.json` |

Delivered via MDM (Jamf, Intune, Group Policy, etc.). Cannot be deployed through server-managed settings.

#### Allowlist / Denylist Match Keys

| Key | Matches | Notes |
| :--- | :--- | :--- |
| `serverUrl` | Remote server URL (supports `*` wildcards) | Hostname match is case-insensitive; paths are case-sensitive |
| `serverCommand` | Exact command + all arguments in order | Must match every argument exactly |
| `serverName` | User-assigned label | Not a security control on its own; use with `serverUrl` or `serverCommand` |

Setting `allowedMcpServers` to an empty array `[]` blocks all servers. Leaving it unset allows all. `deniedMcpServers` always merges from every settings source; `allowedMcpServers` merges unless `allowManagedMcpServersOnly: true`.

#### Evaluation Order

1. Merge allowlist and denylist entries from all settings sources (or only managed sources if `allowManagedMcpServersOnly: true`)
2. Check denylist — a match blocks unconditionally
3. Check allowlist — remote servers need a `serverUrl` match; stdio servers need a `serverCommand` match; `serverName` only counts when no stricter entries exist

#### User-Facing Error Messages

| Situation | Message |
| :--- | :--- |
| `managed-mcp.json` present; user runs `claude mcp add` | `Cannot add MCP server: enterprise MCP configuration is active and has exclusive control over MCP servers` |
| Server matches denylist | `Cannot add MCP server "<name>": server is explicitly blocked by enterprise policy` |
| Server not on allowlist | `Cannot add MCP server "<name>": not allowed by enterprise policy` |
| Previously configured server now blocked | Server silently disappears from `/mcp` and `claude mcp list` |

#### Related Managed Settings

| Setting | Effect | Delivered via |
| :--- | :--- | :--- |
| `allowedMcpServers` | Allowlist of permitted servers | Any settings file; managed sources for enforcement |
| `deniedMcpServers` | Denylist of blocked servers | Any settings file |
| `allowManagedMcpServersOnly` | Locks allowlist to managed sources only | Managed settings sources only |
| `allowAllClaudeAiMcps` | Re-enables claude.ai connectors alongside `managed-mcp.json` (v2.1.149+) | Managed settings sources only |

## Full Documentation

For the complete official documentation, see the reference files:

- [Connect Claude Code to tools via MCP](references/claude-code-mcp.md) — installing servers, transports, scopes, authentication (OAuth, headersHelper), tool search, output limits, MCP prompts and resources, plugin-provided servers, using Claude Code as an MCP server
- [Control MCP server access for your organization](references/claude-code-managed-mcp.md) — managed-mcp.json, allowlists, denylists, enterprise control patterns, monitoring MCP usage

## Sources

- Connect Claude Code to tools via MCP: https://code.claude.com/docs/en/mcp.md
- Control MCP server access for your organization: https://code.claude.com/docs/en/managed-mcp.md
