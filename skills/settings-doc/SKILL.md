---
name: settings-doc
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, environment variables, permission modes, server-managed settings, auto mode configuration, and admin setup.

## Quick Reference

### Configuration Scopes and Precedence

| Priority | Scope | Location | Who it affects |
|:---------|:------|:---------|:---------------|
| 1 (highest) | **Managed** | Server, plist/registry, or `managed-settings.json` | All users (IT-deployed) |
| 2 | **CLI flags** | `--settings` or launch flags | Current session only |
| 3 | **Local** | `.claude/settings.local.json` | You, this project only |
| 4 | **Project** | `.claude/settings.json` | All collaborators (committed) |
| 5 (lowest) | **User** | `~/.claude/settings.json` | You, all projects |

Array settings (e.g., `permissions.allow`, `sandbox.filesystem.allowWrite`) **concatenate and deduplicate** across scopes rather than override.

### Settings Files Summary

| File | Scope |
|:-----|:------|
| `~/.claude/settings.json` | User — personal global settings |
| `.claude/settings.json` | Project — shared with team via git |
| `.claude/settings.local.json` | Local — gitignored personal overrides |
| `managed-settings.json` (system path) | Managed — admin-deployed, highest priority |

System paths for `managed-settings.json`: macOS `/Library/Application Support/ClaudeCode/`, Linux/WSL `/etc/claude-code/`, Windows `C:\Program Files\ClaudeCode\`.

Other config stored in `~/.claude.json`: OAuth session, per-project state, MCP server configs. Project-scoped MCP servers go in `.mcp.json`.

### Key `settings.json` Options

| Key | Description | Example |
|:----|:------------|:--------|
| `model` | Override default model (read once at startup) | `"claude-sonnet-4-6"` |
| `permissions` | Allow/ask/deny rules, defaultMode, sandbox | see below |
| `env` | Environment variables for every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle hook commands | see hooks-doc |
| `apiKeyHelper` | Script to generate auth token | `"/bin/gen_key.sh"` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) | `"stable"` |
| `availableModels` | Restrict `/model` picker | `["sonnet", "haiku"]` |
| `alwaysThinkingEnabled` | Enable extended thinking by default | `true` |
| `effortLevel` | Persist effort level across sessions | `"xhigh"` |
| `language` | Claude's preferred response language | `"japanese"` |
| `tui` | UI renderer: `"fullscreen"` or `"default"` | `"fullscreen"` |
| `editorMode` | Key bindings: `"normal"` or `"vim"` | `"vim"` |
| `outputStyle` | System prompt output style | `"Explanatory"` |
| `statusLine` | Custom status line command | `{"type":"command","command":"~/.claude/sl.sh"}` |
| `autoMemoryEnabled` | Enable/disable auto memory (default: `true`) | `false` |
| `cleanupPeriodDays` | Session file retention days (default: 30) | `20` |
| `companyAnnouncements` | Startup messages shown to users | `["Welcome!"]` |
| `minimumVersion` | Floor for auto-updates | `"2.1.100"` |
| `disableAllHooks` | Disable all hooks and custom status line | `true` |
| `includeGitInstructions` | Include git workflow in system prompt | `false` |
| `skipWebFetchPreflight` | Skip WebFetch domain safety check | `true` |
| `attribution` | Git commit/PR attribution text | `{"commit":"...", "pr":""}` |
| `fileSuggestion` | Custom `@` file autocomplete command | `{"type":"command","command":"..."}` |
| `plansDirectory` | Where plan files are stored | `"./plans"` |
| `viewMode` | Default transcript view: `"default"`, `"verbose"`, `"focus"` | `"verbose"` |
| `preferredNotifChannel` | Notification method (bell, iTerm2, etc.) | `"terminal_bell"` |

### Permission Settings

Nested under `"permissions"` in `settings.json`:

| Key | Description |
|:----|:------------|
| `allow` | Array of rules to auto-approve tool use |
| `ask` | Array of rules that always prompt for confirmation |
| `deny` | Array of rules to block tool use |
| `additionalDirectories` | Extra working directories for file access |
| `defaultMode` | Default permission mode on startup |
| `disableBypassPermissionsMode` | Set to `"disable"` to block bypass mode |
| `skipDangerousModePermissionPrompt` | Skip bypass mode confirmation prompt |

### Permission Rule Syntax

Format: `Tool` or `Tool(specifier)`. Evaluation order: **deny → ask → allow** (first match wins).

| Rule | Effect |
|:-----|:-------|
| `Bash` | Match all Bash commands (removes tool from context as deny) |
| `Bash(npm run *)` | Match commands starting with `npm run` |
| `Bash(git * main)` | Match commands like `git checkout main` |
| `Read(./.env)` | Match reading `.env` in current dir |
| `Read(~/.zshrc)` | Match reading from home directory |
| `Read(//Users/alice/secrets/**)` | Absolute path match |
| `Edit(/src/**/*.ts)` | Project-relative path match |
| `WebFetch(domain:example.com)` | Match fetches to domain |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `Agent(Explore)` | Control subagent use |

Wildcard `*` matches any sequence including spaces. Space before `*` enforces word boundary: `Bash(ls *)` matches `ls -la` but not `lsof`. Compound commands are checked per-subcommand.

### Permission Modes

Set via `permissions.defaultMode`, `--permission-mode`, or `Shift+Tab` cycling in CLI.

| Mode | What runs without asking | Best for |
|:-----|:------------------------|:---------|
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common fs commands | Iterating on code |
| `plan` | Reads only (no edits; proposes plan) | Exploring before changing |
| `auto` | Everything with background safety checks | Long tasks, less prompt fatigue |
| `dontAsk` | Only pre-approved tools | CI/scripts with known tool set |
| `bypassPermissions` | Everything (circuit breaker for `rm -rf /`) | Containers/VMs only |

`auto` mode: requires Anthropic API (not Bedrock/Vertex/Foundry), Claude Opus 4.6+ or Sonnet 4.6, and admin enablement on Team/Enterprise. Uses a classifier that blocks irreversible/external actions by default. Ignored from project/local settings to prevent repos from granting themselves auto mode.

### Protected Paths (never auto-approved except in `bypassPermissions`)

`.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except commands/agents/skills/worktrees), `.gitconfig`, `.gitmodules`, `.bashrc`, `.zshrc`, `.mcp.json`, `.claude.json`, and similar shell/config files.

### Sandbox Settings

Nested under `"sandbox"`:

| Key | Description |
|:----|:------------|
| `enabled` | Enable bash sandboxing (macOS, Linux, WSL2) |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: `true`) |
| `excludedCommands` | Commands to run outside sandbox |
| `filesystem.allowWrite` | Additional writable paths |
| `filesystem.denyWrite` | Blocked write paths |
| `filesystem.denyRead` | Blocked read paths |
| `filesystem.allowRead` | Re-allow within denyRead regions |
| `network.allowedDomains` | Allowed outbound domains (supports wildcards) |
| `network.deniedDomains` | Blocked domains (merged from all scopes) |
| `network.allowUnixSockets` | Unix socket paths (macOS only) |
| `network.allowLocalBinding` | Allow localhost port binding (macOS only) |
| `failIfUnavailable` | Exit if sandbox can't start |

### Worktree Settings

| Key | Description |
|:----|:------------|
| `worktree.baseRef` | Branch source: `"fresh"` (origin default) or `"head"` |
| `worktree.symlinkDirectories` | Dirs to symlink into worktrees (e.g. `node_modules`) |
| `worktree.sparsePaths` | Sparse-checkout paths for large monorepos |
| `worktree.bgIsolation` | Background isolation: `"worktree"` (default) or `"none"` |

### Plugin Settings

| Key | Description |
|:----|:------------|
| `enabledPlugins` | `{"plugin@marketplace": true/false}` — enable/disable plugins |
| `extraKnownMarketplaces` | Register additional marketplace sources for team |
| `strictKnownMarketplaces` | (Managed only) Allowlist of permitted marketplace sources |
| `blockedMarketplaces` | (Managed only) Blocklist of marketplace sources |
| `strictPluginOnlyCustomization` | (Managed only) Block user/project skills, agents, hooks, MCP |

### Managed-Only Settings

These keys only take effect in managed settings; user/project settings ignore them:

`allowAllClaudeAiMcps`, `allowedChannelPlugins`, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowManagedPermissionRulesOnly`, `allowedMcpServers`, `deniedMcpServers`, `blockedMarketplaces`, `channelsEnabled`, `claudeMd`, `forceRemoteSettingsRefresh`, `pluginTrustMessage`, `sandbox.filesystem.allowManagedReadPathsOnly`, `sandbox.network.allowManagedDomainsOnly`, `strictKnownMarketplaces`, `strictPluginOnlyCustomization`, `wslInheritsWindowsSettings`, `parentSettingsBehavior`, `policyHelper`

### Server-Managed Settings

Available on Teams/Enterprise plans. Delivered via Claude.ai admin console at **Admin Settings > Claude Code > Managed settings**.

- Fetched at startup and polled hourly during active sessions
- Cached locally; survives network failures on subsequent launches
- Takes highest precedence; cannot be overridden by users
- Not available when using Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`
- Set `forceRemoteSettingsRefresh: true` to block startup if fetch fails (fail-closed)

### Managed Settings Delivery Mechanisms

| Mechanism | Platform | Priority |
|:----------|:---------|:---------|
| Server-managed (Claude.ai admin console) | All | Highest |
| plist (`com.anthropic.claudecode`) | macOS | High |
| Registry (`HKLM\SOFTWARE\Policies\ClaudeCode`) | Windows | High |
| `managed-settings.json` file | All | Medium |
| HKCU registry | Windows | Lowest |

Only one managed source is used per device (no cross-tier merging). Within file-based tier, `managed-settings.d/*.json` drop-ins merge on top of `managed-settings.json` alphabetically.

### Auto Mode Configuration (`autoMode` key)

The `autoMode` settings block tells the classifier which infrastructure is trusted. Not read from shared project settings.

| Field | Description |
|:------|:------------|
| `environment` | Prose descriptions of trusted repos, buckets, domains |
| `allow` | Exceptions to soft_deny rules |
| `soft_deny` | Destructive actions user intent can override |
| `hard_deny` | Unconditional security boundaries |

Include `"$defaults"` in any array to inherit built-in rules at that position. Omitting `"$defaults"` replaces the entire default list.

CLI inspection: `claude auto-mode defaults`, `claude auto-mode config`, `claude auto-mode critique`.

### Key Environment Variables

Set in shell or under `"env"` in settings.json. Variables in settings take effect every session.

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key (overrides subscription when set) |
| `ANTHROPIC_MODEL` | Override model for session |
| `ANTHROPIC_BASE_URL` | Route requests through proxy/gateway |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CONFIG_DIR` | Override config dir (default: `~/.claude`) |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set to `1` to enable OpenTelemetry |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort: `low`, `medium`, `high`, `xhigh`, `max` |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout (default: 600000) |
| `API_TIMEOUT_MS` | API request timeout (default: 600000) |
| `DISABLE_TELEMETRY` / `DO_NOT_TRACK` | Opt out of telemetry |
| `DISABLE_AUTOUPDATER` | Disable auto-updates (manual `claude update` still works) |
| `DISABLE_UPDATES` | Block all updates including manual |
| `DISABLE_COMPACT` | Disable all compaction |
| `DISABLE_AUTO_COMPACT` | Disable automatic compaction only |
| `MAX_THINKING_TOKENS` | Override extended thinking budget |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Don't write session transcripts to disk |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen rendering |
| `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN` | Force classic main-screen renderer |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_DISABLE_WORKFLOWS` | Disable dynamic workflows |
| `CLAUDE_CODE_DISABLE_AGENT_VIEW` | Disable background agents and agent view |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | Refresh interval for `apiKeyHelper` credentials |
| `MCP_TIMEOUT` | MCP server startup timeout (default: 30000ms) |
| `MCP_TOOL_TIMEOUT` | MCP tool execution timeout (default: ~28 hours) |
| `CLAUDECODE` | Set to `1` in subprocesses spawned by Claude Code |
| `CLAUDE_CODE_SESSION_ID` | Current session ID in subprocesses |
| `CLAUDE_ENV_FILE` | Script sourced before each Bash command |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy for network connections |

OTel variables: `OTEL_METRICS_EXPORTER`, `OTEL_LOGS_EXPORTER`, `OTEL_EXPORTER_OTLP_ENDPOINT`, `OTEL_EXPORTER_OTLP_HEADERS`, etc.

Precedence: environment variables generally override settings.json fields; CLI flags override environment variables for the session.

### Verify Active Settings

Run `/status` inside Claude Code. The `Setting sources` line lists each loaded layer. Managed settings show the delivery channel in parentheses: `(remote)`, `(plist)`, `(HKLM)`, `(HKCU)`, or `(file)`. Run `/permissions` to see effective permission rules.

### Admin Setup Decision Map

| Decision | Key settings / references |
|:---------|:--------------------------|
| API provider | Anthropic, Bedrock, Vertex, Foundry |
| Settings delivery mechanism | Server-managed vs. MDM/plist/registry vs. file-based |
| Permission enforcement | `permissions.deny`, `allowManagedPermissionRulesOnly`, sandbox |
| MCP server control | `allowedMcpServers`, `deniedMcpServers`, `managed-mcp.json` |
| Plugin control | `strictKnownMarketplaces`, `blockedMarketplaces`, `strictPluginOnlyCustomization` |
| Usage monitoring | OpenTelemetry (`CLAUDE_CODE_ENABLE_TELEMETRY`), Analytics dashboard |
| Version floor | `minimumVersion` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — Complete settings.json reference, scope system, all setting keys, permission settings, sandbox, worktree, plugin, and attribution settings; settings precedence
- [Set up Claude Code for your organization](references/claude-code-admin-setup.md) — Admin deployment decision map: API provider, managed settings delivery, enforcement controls, usage visibility, data handling
- [Configure permissions](references/claude-code-permissions.md) — Permission system tiers, rule syntax, tool-specific patterns (Bash, Read/Edit, WebFetch, MCP, Agent), working directories, managed settings
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — Claude.ai admin console delivery, fetch/caching behavior, fail-closed enforcement, security dialogs, limitations
- [Environment variables](references/claude-code-env-vars.md) — Full reference for all environment variables controlling Claude Code behavior
- [Choose a permission mode](references/claude-code-permission-modes.md) — Mode descriptions, switching modes, auto mode requirements/classifier behavior, protected paths
- [Configure auto mode](references/claude-code-auto-mode-config.md) — `autoMode` settings block, trusted infrastructure, block/allow rule overrides, CLI inspection subcommands

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Set up Claude Code for your organization: https://code.claude.com/docs/en/admin-setup.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
