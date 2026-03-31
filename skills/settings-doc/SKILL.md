---
name: settings-doc
description: Complete documentation for Claude Code settings, permissions, permission modes, environment variables, and server-managed settings. Covers settings.json structure (user ~/.claude/settings.json, project .claude/settings.json, local .claude/settings.local.json, managed settings via server-managed/MDM/file-based), configuration scopes (managed > CLI args > local > project > user), all available settings keys (apiKeyHelper, autoMemoryDirectory, cleanupPeriodDays, companyAnnouncements, env, attribution, permissions, autoMode, disableAutoMode, hooks, model, availableModels, modelOverrides, effortLevel, sandbox, statusLine, fileSuggestion, outputStyle, agent, language, voiceEnabled, autoUpdatesChannel, spinnerVerbs, spinnerTipsEnabled, worktree.symlinkDirectories, worktree.sparsePaths, and more), global config settings in ~/.claude.json (autoConnectIde, editorMode, showTurnDuration, terminalProgressBarEnabled, teammateMode), permission settings (allow/ask/deny arrays, additionalDirectories, defaultMode, disableBypassPermissionsMode), permission rule syntax (Tool or Tool(specifier) format, glob wildcards with * in Bash rules, Read/Edit gitignore-style patterns with //absolute ~/home /project-relative ./cwd-relative paths, WebFetch domain: rules, MCP server/tool rules, Agent subagent rules), permission modes (default, acceptEdits, plan, auto, bypassPermissions, dontAsk -- switching via Shift+Tab in CLI, mode selector in VS Code/Desktop/web, --permission-mode flag, defaultMode setting), auto mode (classifier model, background safety checks, trusted infrastructure via autoMode.environment/allow/soft_deny, what gets blocked/allowed by default, subagent handling, fallback behavior, claude auto-mode defaults/config/critique commands), plan mode (research without editing, /plan prefix, approval options), sandbox settings (enabled, filesystem allowWrite/denyWrite/denyRead/allowRead paths, network allowedDomains, excludedCommands), plugin configuration (enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces, blockedMarketplaces), environment variables (ANTHROPIC_API_KEY, ANTHROPIC_BASE_URL, ANTHROPIC_MODEL, CLAUDE_CODE_USE_BEDROCK/VERTEX/FOUNDRY, CLAUDE_CODE_ENABLE_TELEMETRY, MAX_THINKING_TOKENS, BASH_DEFAULT_TIMEOUT_MS, DISABLE_AUTOUPDATER, HTTP_PROXY/HTTPS_PROXY, and 80+ more), server-managed settings (Claude.ai admin console delivery, Teams/Enterprise plans, hourly polling, security approval dialogs, endpoint-managed vs server-managed comparison, caching behavior, platform availability), managed-only settings (allowManagedPermissionRulesOnly, allowManagedHooksOnly, allowManagedMcpServersOnly, sandbox.network.allowManagedDomainsOnly, sandbox.filesystem.allowManagedReadPathsOnly, strictKnownMarketplaces, blockedMarketplaces, allowedChannelPlugins), hook configuration settings (allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars, disableAllHooks), settings precedence and merging behavior (deny at any level blocks, arrays concatenate and deduplicate), /config command, /permissions command, /status to verify active settings. Load when discussing Claude Code settings, settings.json, permissions, permission modes, permission rules, allow/deny rules, environment variables, env vars, managed settings, server-managed settings, enterprise policy, sandbox configuration, auto mode configuration, plan mode, bypassPermissions, dontAsk mode, plugin settings, marketplace settings, configuration scopes, settings precedence, or any settings/permissions/env-vars topic for Claude Code.
user-invocable: false
---

# Settings, Permissions & Environment Variables Documentation

This skill provides the complete official documentation for configuring Claude Code through settings files, permissions, permission modes, environment variables, and server-managed settings.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared? |
|:------|:---------|:---------------|:--------|
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | All users on machine | Yes (deployed by IT) |
| **User** | `~/.claude/settings.json` | You, across all projects | No |
| **Project** | `.claude/settings.json` | All collaborators | Yes (committed to git) |
| **Local** | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |

**Precedence (highest to lowest):** Managed > CLI arguments > Local > Project > User. If denied at any level, no other level can allow it. Array settings (like `permissions.allow`) concatenate and deduplicate across scopes.

### Settings Files

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User-wide settings |
| `.claude/settings.json` | Project settings (shared via git) |
| `.claude/settings.local.json` | Local project overrides (gitignored) |
| `~/.claude.json` | Preferences, OAuth, MCP servers, per-project state |
| Managed settings | Server-managed, MDM/plist/registry, or file-based at system paths |

Managed settings file locations: macOS `/Library/Application Support/ClaudeCode/managed-settings.json`, Linux/WSL `/etc/claude-code/managed-settings.json`, Windows `C:\Program Files\ClaudeCode\managed-settings.json`. Drop-in directory `managed-settings.d/*.json` supported alongside the base file (sorted alphabetically, deep-merged).

Add `"$schema": "https://json.schemastore.org/claude-code-settings.json"` to enable autocomplete and validation.

### Key Settings (settings.json)

| Key | Description |
|:----|:------------|
| `permissions` | Permission rules: `allow`, `ask`, `deny` arrays, `defaultMode`, `disableBypassPermissionsMode`, `additionalDirectories` |
| `env` | Environment variables applied to every session |
| `hooks` | Custom commands at lifecycle events |
| `model` | Override default model |
| `availableModels` | Restrict selectable models |
| `modelOverrides` | Map model IDs to provider-specific IDs |
| `effortLevel` | Persist effort level: `"low"`, `"medium"`, `"high"` |
| `autoMode` | Configure auto mode classifier: `environment`, `allow`, `soft_deny` arrays |
| `sandbox` | Sandbox config: `enabled`, `filesystem.*`, `network.*` |
| `attribution` | Customize git commit/PR attribution (`commit`, `pr` keys) |
| `language` | Preferred response language |
| `outputStyle` | Adjust system prompt style |
| `agent` | Run main thread as a named subagent |
| `statusLine` | Custom status line command |
| `fileSuggestion` | Custom `@` file autocomplete command |
| `companyAnnouncements` | Startup announcements for users |
| `enabledPlugins` | Enable/disable plugins: `"name@marketplace": true/false` |
| `extraKnownMarketplaces` | Define additional plugin marketplaces |
| `worktree.symlinkDirectories` | Symlink dirs into worktrees |
| `worktree.sparsePaths` | Sparse-checkout paths for worktrees |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) |
| `cleanupPeriodDays` | Session cleanup threshold (default: 30) |
| `apiKeyHelper` | Script to generate auth value |
| `forceLoginMethod` | `"claudeai"` or `"console"` |
| `disableAutoMode` | `"disable"` to prevent auto mode |
| `disableAllHooks` | Disable all hooks and custom status line |
| `includeGitInstructions` | Include built-in git instructions (default: `true`) |

Global config in `~/.claude.json`: `autoConnectIde`, `autoInstallIdeExtension`, `editorMode` (`"normal"`/`"vim"`), `showTurnDuration`, `terminalProgressBarEnabled`, `teammateMode`.

### Permission Modes

| Mode | What Claude does without asking | Best for |
|:-----|:-------------------------------|:---------|
| `default` | Read files | Getting started, sensitive work |
| `acceptEdits` | Read and edit files | Iterating on code you review |
| `plan` | Read files (no edits) | Exploring, planning refactors |
| `auto` | All actions with background safety checks | Long-running tasks, reducing prompt fatigue |
| `bypassPermissions` | All actions, no checks | Isolated containers/VMs only |
| `dontAsk` | Only pre-approved tools | Locked-down environments |

**Switching modes:** `Shift+Tab` (CLI cycle), `--permission-mode <mode>` (startup), `defaultMode` in settings, mode selector (VS Code/Desktop/web).

Auto mode requires Team/Enterprise/API plan and Claude Sonnet 4.6 or Opus 4.6. Classifier runs on Sonnet 4.6. Extra token cost from classifier calls. Configure trusted infrastructure via `autoMode.environment`. Inspect defaults with `claude auto-mode defaults`, effective config with `claude auto-mode config`, get feedback with `claude auto-mode critique`.

### Permission Rule Syntax

Rules follow `Tool` or `Tool(specifier)` format. Evaluated in order: **deny > ask > allow** (first match wins).

| Rule | Effect |
|:-----|:-------|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run ` |
| `Bash(npm run build)` | Exact command match |
| `Read(./.env)` | Read `.env` in current directory |
| `Edit(/src/**/*.ts)` | Edit TypeScript files under project `src/` |
| `Read(//Users/alice/secrets/**)` | Absolute path (note `//` prefix) |
| `Read(~/Documents/*.pdf)` | Home-relative path |
| `WebFetch(domain:example.com)` | Fetch requests to domain |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `mcp__puppeteer` | All tools from MCP server |
| `Agent(Explore)` | Specific subagent |

**Read/Edit path patterns** follow gitignore spec:
- `//path` -- absolute from filesystem root
- `~/path` -- relative to home
- `/path` -- relative to project root
- `path` or `./path` -- relative to current directory
- `*` matches single directory, `**` matches recursively

**Bash wildcard behavior:** Space before `*` enforces word boundary: `Bash(ls *)` matches `ls -la` but not `lsof`; `Bash(ls*)` matches both. Claude Code is aware of shell operators so `Bash(safe-cmd *)` does not permit `safe-cmd && other-cmd`.

### Sandbox Settings

| Key | Description |
|:----|:------------|
| `sandbox.enabled` | Enable bash sandboxing |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `sandbox.excludedCommands` | Commands that run outside sandbox |
| `sandbox.filesystem.allowWrite` | Additional writable paths |
| `sandbox.filesystem.denyWrite` | Paths blocked from writing |
| `sandbox.filesystem.denyRead` | Paths blocked from reading |
| `sandbox.filesystem.allowRead` | Re-allow reading within denyRead regions |
| `sandbox.network.allowedDomains` | Allowed outbound domains (supports `*.example.com`) |
| `sandbox.network.allowManagedDomainsOnly` | Managed-only: only managed domains respected |

Sandbox path prefixes: `/path` (absolute), `~/path` (home), `./path` or no prefix (project-relative in project settings, `~/.claude`-relative in user settings). Note: this differs from Read/Edit rules which use `//` for absolute.

### Managed-Only Settings

These settings only take effect in managed settings:

| Setting | Purpose |
|:--------|:--------|
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply |
| `allowManagedHooksOnly` | Only managed and SDK hooks load |
| `allowManagedMcpServersOnly` | Only managed MCP allowlist respected |
| `allowedChannelPlugins` | Allowlist of channel plugins |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `sandbox.network.allowManagedDomainsOnly` | Only managed domains for network access |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed read paths respected |
| `strictKnownMarketplaces` | Allowlist of addable marketplaces |

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key (overrides subscription) |
| `ANTHROPIC_BASE_URL` | Override API endpoint (proxy/gateway) |
| `ANTHROPIC_MODEL` | Model setting to use |
| `ANTHROPIC_CUSTOM_HEADERS` | Custom request headers |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry |
| `CLAUDE_CODE_SIMPLE` | Minimal system prompt, basic tools only |
| `CLAUDE_CODE_EFFORT_LEVEL` | Effort: `low`, `medium`, `high`, `max`, `auto` |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_SHELL` | Override shell detection |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen rendering |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Auto-compaction threshold (1-100) |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Max output tokens |
| `MAX_THINKING_TOKENS` | Extended thinking token budget |
| `MAX_MCP_OUTPUT_TOKENS` | Max MCP tool output (default: 25000) |
| `MCP_TIMEOUT` | MCP server startup timeout (ms) |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout |
| `BASH_MAX_TIMEOUT_MS` | Maximum bash timeout the model can set |
| `ENABLE_TOOL_SEARCH` | MCP tool search: `true`/`false`/`auto`/`auto:N` |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy configuration |
| `DISABLE_AUTOUPDATER` | Disable auto-updates |
| `DISABLE_TELEMETRY` | Opt out of Statsig telemetry |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable updates, feedback, errors, telemetry |
| `CLAUDE_CODE_DISABLE_FAST_MODE` | Disable fast mode |
| `CLAUDE_CODE_DISABLE_CRON` | Disable scheduled tasks |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Enable agent teams |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |
| `CLAUDECODE` | Set to `1` in Claude-spawned shells |
| `CLAUDE_CONFIG_DIR` | Custom config directory |
| `CLAUDE_ENV_FILE` | Shell script sourced before each Bash command |

See the full env vars reference for 80+ additional variables covering model overrides, Bedrock/Vertex/Foundry regions, proxy settings, debugging flags, and more.

### Server-Managed Settings

For Teams/Enterprise plans without MDM infrastructure. Delivered from Anthropic's servers via Claude.ai admin console (Admin Settings > Claude Code > Managed settings).

| Aspect | Detail |
|:-------|:-------|
| Requirements | Teams or Enterprise plan, Claude Code v2.1.38+ (Teams) or v2.1.30+ (Enterprise) |
| Delivery | Fetched at startup, polled hourly |
| Precedence | Highest tier (overrides endpoint-managed when both present) |
| Caching | Cached settings apply immediately on subsequent launches |
| Security dialogs | Shell commands, custom env vars, and hooks require user approval |
| Access control | Primary Owner and Owner roles only |
| Limitations | Uniform for all users (no per-group), no MCP server configs |

Platform availability: requires direct connection to `api.anthropic.com`. Not available with Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`.

### Useful Commands

| Command | Purpose |
|:--------|:--------|
| `/config` | Open settings UI |
| `/permissions` | View and manage permission rules |
| `/status` | Verify active settings sources |
| `claude auto-mode defaults` | Print built-in auto mode rules |
| `claude auto-mode config` | Show effective auto mode config |
| `claude auto-mode critique` | Get AI feedback on custom rules |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) -- Complete settings reference including configuration scopes (managed/user/project/local), settings.json structure, all available settings keys, global config settings in ~/.claude.json, worktree settings, permission settings (allow/ask/deny arrays, defaultMode, additionalDirectories), permission rule syntax with examples, sandbox settings (filesystem paths, network domains, proxy ports), attribution settings, file suggestion settings, hook configuration (allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars), settings precedence and merging behavior, plugin configuration (enabledPlugins, extraKnownMarketplaces with all source types, strictKnownMarketplaces with exact matching), managing plugins, environment variables overview, /config and /status commands
- [Configure permissions](references/claude-code-permissions.md) -- Permission system (tool types and approval behavior), managing permissions with /permissions, permission modes overview, permission rule syntax (Tool/Tool(specifier) format), wildcard patterns, tool-specific rules for Bash (glob wildcards, word boundary, shell operator awareness, compound commands), Read/Edit (gitignore-style patterns with //absolute ~/home /project-relative ./cwd-relative paths, Windows normalization), WebFetch (domain: syntax), MCP (server and tool patterns), Agent (subagent rules), extending permissions with hooks (PreToolUse allow/deny/ask control, blocking hooks vs allow rules), working directories (--add-dir, /add-dir, additionalDirectories), how permissions interact with sandboxing, managed settings and managed-only settings table, auto mode classifier configuration (autoMode.environment/allow/soft_deny, prose rules, precedence, claude auto-mode defaults/config/critique), settings precedence for permissions, example configurations
- [Server-managed settings](references/claude-code-server-managed-settings.md) -- Centralized configuration via Claude.ai admin console for Teams/Enterprise, requirements, server-managed vs endpoint-managed comparison, configuration steps, settings delivery (precedence, fetch/caching behavior, security approval dialogs), access control, current limitations, platform availability, audit logging, security considerations (tampered cache, deleted cache, API unavailable scenarios), ConfigChange hooks for detection
- [Environment variables](references/claude-code-env-vars.md) -- Complete reference for 80+ environment variables: API keys and auth (ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_BASE_URL, ANTHROPIC_CUSTOM_HEADERS), model configuration (ANTHROPIC_MODEL, ANTHROPIC_DEFAULT_*_MODEL variants, ANTHROPIC_CUSTOM_MODEL_OPTION), cloud providers (CLAUDE_CODE_USE_BEDROCK/VERTEX/FOUNDRY, AWS/Vertex/Foundry auth variables), behavior controls (CLAUDE_CODE_SIMPLE, CLAUDE_CODE_EFFORT_LEVEL, CLAUDE_CODE_DISABLE_* flags for auto memory, fast mode, cron, background tasks, mouse, terminal title), context and tokens (CLAUDE_AUTOCOMPACT_PCT_OVERRIDE, CLAUDE_CODE_MAX_OUTPUT_TOKENS, MAX_THINKING_TOKENS, CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS), MCP settings (MAX_MCP_OUTPUT_TOKENS, MCP_TIMEOUT, MCP_TOOL_TIMEOUT, ENABLE_TOOL_SEARCH, ENABLE_CLAUDEAI_MCP_SERVERS), proxy and network (HTTP_PROXY, HTTPS_PROXY, NO_PROXY), telemetry and updates (DISABLE_AUTOUPDATER, DISABLE_TELEMETRY, CLAUDE_CODE_ENABLE_TELEMETRY), shell and bash (CLAUDE_CODE_SHELL, BASH_DEFAULT_TIMEOUT_MS, BASH_MAX_TIMEOUT_MS, BASH_MAX_OUTPUT_LENGTH, CLAUDE_ENV_FILE), security (CLAUDE_CODE_SUBPROCESS_ENV_SCRUB), experimental features (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS, CLAUDE_CODE_NO_FLICKER)
- [Permission modes](references/claude-code-permission-modes.md) -- Detailed guide for each permission mode: switching modes (Shift+Tab CLI, VS Code mode selector, Desktop mode selector, web/mobile dropdown, --permission-mode flag, defaultMode setting), available modes comparison table, plan mode (research without editing, /plan prefix, approval options after planning), auto mode (requirements, classifier model, cost, latency, action evaluation order, how allow rules are dropped on entry, classifier inputs, subagent handling with spawn-time and return checks, default block/allow lists, fallback behavior with denial thresholds), dontAsk mode (fully non-interactive, pre-approved tools only), bypassPermissions mode (skip all checks, protected directories still prompt, --dangerously-skip-permissions flag), permission approach comparison table, customizing further with permission rules and hooks

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Permission modes: https://code.claude.com/docs/en/permission-modes.md
