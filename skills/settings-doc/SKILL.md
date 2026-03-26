---
name: settings-doc
description: Complete documentation for Claude Code settings, permissions, permission modes, server-managed settings, and environment variables. Covers settings files (user ~/.claude/settings.json, project .claude/settings.json, local .claude/settings.local.json, managed settings via server/MDM/file), settings precedence (managed > CLI args > local > project > user), all available settings keys (apiKeyHelper, permissions, hooks, sandbox, model, env, autoMode, attribution, plugins, and more), global config settings (~/.claude.json for autoConnectIde, editorMode, etc.), permission system (allow/ask/deny rules evaluated deny-first, Tool(specifier) syntax, wildcards with *, Bash/Read/Edit/WebFetch/MCP/Agent rule patterns), permission modes (default, acceptEdits, plan, auto, bypassPermissions, dontAsk -- switching via Shift+Tab/CLI/settings/VS Code/Desktop/web), auto mode (classifier-based safety checks, environment/allow/soft_deny configuration, blocked/allowed defaults, subagent handling, fallback behavior, Team plan + Sonnet 4.6/Opus 4.6 required), managed settings (server-managed via Claude.ai admin, MDM/plist/registry, file-based managed-settings.json with drop-in directory, managed-only keys like allowManagedPermissionRulesOnly/allowManagedHooksOnly/allowManagedMcpServersOnly), sandbox settings (enabled, filesystem allowWrite/denyWrite/denyRead/allowRead paths, network allowedDomains/allowUnixSockets, path prefixes), server-managed settings (Teams/Enterprise, configure via admin console, fetch/caching, security approval dialogs, access control, platform availability, audit logging), environment variables (ANTHROPIC_API_KEY, ANTHROPIC_BASE_URL, ANTHROPIC_MODEL, CLAUDE_CODE_USE_BEDROCK/VERTEX/FOUNDRY, CLAUDE_CODE_ENABLE_TELEMETRY, DISABLE_AUTOUPDATER, MAX_THINKING_TOKENS, and 80+ more). Load when discussing Claude Code settings, configuration, settings.json, permissions, permission rules, permission modes, auto mode, plan mode, bypassPermissions, managed settings, server-managed settings, environment variables, sandbox configuration, env vars, defaultMode, settings precedence, or any settings/permissions/configuration topic.
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, permission modes, server-managed settings, and environment variables.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared? |
|:------|:---------|:---------------|:--------|
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | All users on machine | Yes (deployed by IT) |
| **User** | `~/.claude/settings.json` | You, across all projects | No |
| **Project** | `.claude/settings.json` | All collaborators | Yes (committed to git) |
| **Local** | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |

### Settings Precedence (highest to lowest)

1. **Managed settings** (server-managed > MDM/OS policies > file-based > HKCU registry)
2. **Command line arguments**
3. **Local project settings** (`.claude/settings.local.json`)
4. **Shared project settings** (`.claude/settings.json`)
5. **User settings** (`~/.claude/settings.json`)

Array settings (like `permissions.allow`, `sandbox.filesystem.allowWrite`) merge across scopes (concatenated and deduplicated).

### Managed Settings File Locations

| OS | Path |
|:---|:-----|
| macOS (MDM) | `com.anthropic.claudecode` managed preferences domain |
| macOS (file) | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux/WSL (file) | `/etc/claude-code/managed-settings.json` |
| Windows (registry) | `HKLM\SOFTWARE\Policies\ClaudeCode` (REG_SZ `Settings` value) |
| Windows (file) | `C:\Program Files\ClaudeCode\managed-settings.json` |

File-based managed settings support a `managed-settings.d/` drop-in directory (merged alphabetically after `managed-settings.json`).

### Key Settings (settings.json)

| Key | Description |
|:----|:------------|
| `permissions` | Allow/ask/deny rules, `defaultMode`, `disableBypassPermissionsMode`, `additionalDirectories` |
| `autoMode` | Configure auto mode classifier: `environment`, `allow`, `soft_deny` arrays (not read from shared project settings) |
| `disableAutoMode` | `"disable"` to prevent auto mode activation |
| `hooks` | Custom commands at lifecycle events |
| `sandbox` | `enabled`, filesystem paths, network domains |
| `model` | Override default model |
| `availableModels` | Restrict selectable models |
| `modelOverrides` | Map model IDs to provider-specific IDs |
| `effortLevel` | `"low"`, `"medium"`, `"high"` |
| `env` | Environment variables applied to every session |
| `apiKeyHelper` | Custom script for auth value generation |
| `attribution` | Customize git commit/PR attribution (`commit`, `pr` keys) |
| `language` | Preferred response language |
| `defaultShell` | `"bash"` (default) or `"powershell"` |
| `outputStyle` | Adjust system prompt style |
| `agent` | Run main thread as named subagent |
| `statusLine` | Custom status line command |
| `fileSuggestion` | Custom `@` file autocomplete command |
| `cleanupPeriodDays` | Session cleanup period (default: 30) |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) |
| `forceLoginMethod` | `"claudeai"` or `"console"` |
| `enableAllProjectMcpServers` | Auto-approve all project MCP servers |
| `companyAnnouncements` | Startup announcements for users |

### Global Config Settings (~/.claude.json)

| Key | Description |
|:----|:------------|
| `autoConnectIde` | Auto-connect to running IDE (default: `false`) |
| `autoInstallIdeExtension` | Auto-install IDE extension (default: `true`) |
| `editorMode` | `"normal"` or `"vim"` |
| `showTurnDuration` | Show turn duration messages (default: `true`) |
| `terminalProgressBarEnabled` | Terminal progress bar (default: `true`) |

### Managed-Only Settings

| Setting | Description |
|:--------|:------------|
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply |
| `allowManagedHooksOnly` | Only managed and SDK hooks load |
| `allowManagedMcpServersOnly` | Only managed MCP allowlist applies |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `sandbox.network.allowManagedDomainsOnly` | Only managed domain allowlists apply |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed `allowRead` paths apply |
| `strictKnownMarketplaces` | Controls which marketplaces users can add |
| `channelsEnabled` | Allow channels for Team/Enterprise users |

### Permission System

Rules evaluated in order: **deny -> ask -> allow**. First match wins.

| Tool type | Example | Approval required | "Don't ask again" scope |
|:----------|:--------|:------------------|:------------------------|
| Read-only | File reads, Grep | No | N/A |
| Bash commands | Shell execution | Yes | Permanent per project + command |
| File modification | Edit/write files | Yes | Until session end |

### Permission Rule Syntax

| Pattern | Example | Matches |
|:--------|:--------|:--------|
| `Tool` | `Bash` | All uses of tool |
| `Tool(exact)` | `Bash(npm run build)` | Exact command |
| `Tool(prefix *)` | `Bash(npm run *)` | Commands starting with prefix (word boundary) |
| `Tool(prefix*)` | `Bash(ls*)` | Commands starting with prefix (no word boundary) |
| `Tool(* suffix)` | `Bash(* --help)` | Commands ending with suffix |
| Read/Edit absolute | `Read(//Users/alice/secrets/**)` | Absolute filesystem path |
| Read/Edit home | `Read(~/Documents/*.pdf)` | Relative to home directory |
| Read/Edit project | `Edit(/src/**/*.ts)` | Relative to project root |
| Read/Edit cwd | `Read(*.env)` | Relative to current directory |
| WebFetch domain | `WebFetch(domain:example.com)` | Requests to domain |
| MCP server | `mcp__puppeteer` | All tools from MCP server |
| MCP tool | `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| Agent | `Agent(Explore)` | Specific subagent |

### Permission Modes

| Mode | What Claude can do without asking | Best for |
|:-----|:----------------------------------|:---------|
| `default` | Read files | Getting started, sensitive work |
| `acceptEdits` | Read and edit files | Iterating on code you review |
| `plan` | Read files (no edits) | Exploring codebase, planning |
| `auto` | All actions (classifier checks) | Long-running tasks, reducing prompts |
| `bypassPermissions` | All actions (no checks) | Isolated containers/VMs only |
| `dontAsk` | Only pre-approved tools | Locked-down environments |

Switch modes: `Shift+Tab` (CLI), `--permission-mode <mode>`, `defaultMode` in settings, mode selector (VS Code/Desktop/web).

### Auto Mode

- Requires Team plan + Claude Sonnet 4.6 or Opus 4.6
- Classifier model: Claude Sonnet 4.6 (always)
- Admin must enable in Claude Code admin settings
- Enable at startup: `--enable-auto-mode`
- Decision order: allow/deny rules -> read-only/edit auto-approve -> classifier -> block with reason
- On entering auto mode, blanket allow rules for Bash/Agent are dropped
- Fallback: after 3 consecutive or 20 total blocks, reverts to prompting
- Configure trusted infrastructure via `autoMode.environment` (prose descriptions)
- `autoMode.allow` and `autoMode.soft_deny` replace defaults entirely (use `claude auto-mode defaults` first)
- Inspect: `claude auto-mode defaults`, `claude auto-mode config`, `claude auto-mode critique`

### Sandbox Settings

| Key | Description |
|:----|:------------|
| `sandbox.enabled` | Enable bash sandboxing |
| `sandbox.failIfUnavailable` | Exit if sandbox unavailable |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: `true`) |
| `sandbox.excludedCommands` | Commands that run outside sandbox |
| `sandbox.filesystem.allowWrite` | Additional writable paths |
| `sandbox.filesystem.denyWrite` | Blocked write paths |
| `sandbox.filesystem.denyRead` | Blocked read paths |
| `sandbox.filesystem.allowRead` | Re-allow reads within denyRead regions |
| `sandbox.network.allowedDomains` | Allowed outbound domains (wildcards supported) |
| `sandbox.network.allowUnixSockets` | Allowed Unix socket paths |
| `sandbox.network.allowLocalBinding` | Allow localhost binding (macOS only) |

Sandbox path prefixes: `/` = absolute, `~/` = home, `./` or bare = project root (project settings) or `~/.claude` (user settings).

### Server-Managed Settings

- Available for Teams and Enterprise plans
- Configure via Claude.ai Admin Settings > Claude Code > Managed settings
- Clients fetch at startup + poll hourly
- Cached settings persist through network failures
- Security approval dialogs required for hooks, custom env vars, shell commands
- When both server-managed and endpoint-managed exist, server-managed wins
- Not available with Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`
- Access control: Primary Owner and Owner roles

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key (overrides subscription) |
| `ANTHROPIC_BASE_URL` | Override API endpoint |
| `ANTHROPIC_MODEL` | Model setting to use |
| `ANTHROPIC_CUSTOM_HEADERS` | Custom request headers |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry (`1`) |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable updates, telemetry, feedback, error reporting |
| `CLAUDE_CODE_SIMPLE` | Minimal system prompt, basic tools only (`1`) |
| `CLAUDE_CODE_SHELL` | Override shell detection |
| `CLAUDE_CODE_EFFORT_LEVEL` | `low`, `medium`, `high`, `max`, or `auto` |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory (`1`) |
| `CLAUDE_CODE_DISABLE_FAST_MODE` | Disable fast mode (`1`) |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | Disable background tasks (`1`) |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocesses (`1`) |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Auto-compaction trigger percentage (1-100) |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Max output tokens per request |
| `MAX_THINKING_TOKENS` | Override extended thinking budget |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout |
| `BASH_MAX_TIMEOUT_MS` | Maximum bash command timeout |
| `DISABLE_AUTOUPDATER` | Disable auto-updates (`1`) |
| `DISABLE_TELEMETRY` | Opt out of Statsig telemetry (`1`) |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching (`1`) |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server configuration |
| `MCP_TIMEOUT` | MCP server startup timeout (ms) |
| `MAX_MCP_OUTPUT_TOKENS` | Max MCP tool response tokens (default: 25000) |
| `CLAUDECODE` | Set to `1` in Claude-spawned shells |
| `CLAUDE_CONFIG_DIR` | Custom config/data directory |
| `CLAUDE_ENV_FILE` | Shell script sourced before each bash command |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) -- Configuration scopes (managed/user/project/local), settings files and locations, all available settings keys with descriptions and examples, global config settings (~/.claude.json), worktree settings, permission settings (allow/ask/deny arrays, defaultMode, disableBypassPermissionsMode, additionalDirectories), permission rule syntax (Tool/Tool(specifier) format, wildcards), sandbox settings (enabled, filesystem paths with allowWrite/denyWrite/denyRead/allowRead, network allowedDomains/allowUnixSockets/allowLocalBinding, path prefixes, proxy ports), attribution settings (commit/pr customization), file suggestion settings (custom @ autocomplete command), hook configuration (allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars), settings precedence (managed > CLI > local > project > user, array merging), plugin configuration (enabledPlugins, extraKnownMarketplaces with source types, strictKnownMarketplaces for managed policy), subagent configuration, environment variables overview, tools reference, excluding sensitive files
- [Configure permissions](references/claude-code-permissions.md) -- Permission system (tiered tool types), managing permissions (/permissions command, allow/ask/deny rules, deny-first evaluation), permission modes (default/acceptEdits/plan/auto/dontAsk/bypassPermissions), permission rule syntax (Tool/Tool(specifier), wildcards, word boundaries), tool-specific rules (Bash wildcards and compound commands, Read/Edit gitignore patterns with //path ~/path /path ./path, WebFetch domain matching, MCP server/tool patterns, Agent rules), extending permissions with hooks (PreToolUse allow/deny/prompt, blocking hooks vs allow rules), working directories (--add-dir, /add-dir, additionalDirectories), permissions and sandboxing interaction, managed settings (managed-only keys: allowManagedPermissionRulesOnly, allowManagedHooksOnly, allowManagedMcpServersOnly, blockedMarketplaces, sandbox.network.allowManagedDomainsOnly, sandbox.filesystem.allowManagedReadPathsOnly, strictKnownMarketplaces), auto mode classifier configuration (autoMode.environment for trusted infrastructure, autoMode.allow and autoMode.soft_deny override defaults, prose-based rules, inspect with claude auto-mode defaults/config/critique), settings precedence, example configurations
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) -- Server-managed settings overview (Teams/Enterprise, public beta), requirements (plan, version, network), comparison with endpoint-managed settings, configuration steps (admin console, JSON settings, save/deploy), verifying delivery, access control (Primary Owner, Owner), current limitations (uniform per-org, no MCP server configs), settings delivery (precedence over endpoint-managed, fetch/caching behavior, first launch vs cached), security approval dialogs (hooks, custom env vars, shell commands, non-interactive -p flag skip), platform availability (not available with Bedrock/Vertex/Foundry/custom base URL), audit logging, security considerations (cached file tampering, API unavailability, org switching)
- [Environment variables](references/claude-code-env-vars.md) -- Complete reference of 80+ environment variables controlling API keys and auth (ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_BASE_URL, ANTHROPIC_CUSTOM_HEADERS), model configuration (ANTHROPIC_MODEL, ANTHROPIC_DEFAULT_*_MODEL, ANTHROPIC_CUSTOM_MODEL_OPTION), cloud providers (CLAUDE_CODE_USE_BEDROCK/VERTEX/FOUNDRY, skip auth flags, region overrides), bash behavior (BASH_DEFAULT_TIMEOUT_MS, BASH_MAX_TIMEOUT_MS, BASH_MAX_OUTPUT_LENGTH), telemetry and updates (CLAUDE_CODE_ENABLE_TELEMETRY, DISABLE_AUTOUPDATER, DISABLE_TELEMETRY, DISABLE_ERROR_REPORTING), feature flags (CLAUDE_CODE_DISABLE_FAST_MODE, CLAUDE_CODE_DISABLE_AUTO_MEMORY, CLAUDE_CODE_DISABLE_BACKGROUND_TASKS, CLAUDE_CODE_SIMPLE), MCP (MCP_TIMEOUT, MAX_MCP_OUTPUT_TOKENS, ENABLE_TOOL_SEARCH, MCP_CLIENT_SECRET), proxy (HTTP_PROXY, HTTPS_PROXY, NO_PROXY), and many more
- [Choose a permission mode](references/claude-code-permission-modes.md) -- Switching modes (Shift+Tab CLI cycle, --permission-mode flag, defaultMode setting, VS Code/Desktop/web mode selectors), available modes comparison table, plan mode (research and propose without editing, /plan prefix, plan approval options with auto/acceptEdits/manual), auto mode (Team plan required, Sonnet 4.6/Opus 4.6, classifier model and cost/latency, action evaluation order with allow/deny rules then auto-approve then classifier, blanket allow rule dropping, subagent handling with spawn-time and return-time checks, default blocks and allows, fallback after 3 consecutive or 20 total blocks), dontAsk mode (auto-deny unless pre-allowed), bypassPermissions mode (no checks, --dangerously-skip-permissions equivalent), permission approach comparison table, customizing with permission rules and hooks

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
