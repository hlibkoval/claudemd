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

Drop-in directory `managed-settings.d/*.json` is also supported (sorted alphabetically, merged on top of the base file).

Other config in `~/.claude.json`: OAuth session, per-project state, MCP server configs. Project-scoped MCP servers go in `.mcp.json`.

**When edits take effect:** Most keys (permissions, hooks, env) reload live without restart. `model` and `outputStyle` apply on next restart or `/clear`.

### Key `settings.json` Options

| Key | Description | Example |
|:----|:------------|:--------|
| `model` | Override default model (restart to apply) | `"claude-sonnet-4-6"` |
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
| `outputStyle` | System prompt output style (applies on restart/`/clear`) | `"Explanatory"` |
| `statusLine` | Custom status line command | `{"type":"command","command":"~/.claude/sl.sh"}` |
| `autoMemoryEnabled` | Enable/disable auto memory (default: `true`) | `false` |
| `autoMemoryDirectory` | Custom directory for auto memory storage | `"~/my-memory-dir"` |
| `cleanupPeriodDays` | Session file retention days (default: 30, min 1) | `20` |
| `companyAnnouncements` | Startup messages shown to users | `["Welcome!"]` |
| `minimumVersion` | Floor for auto-updates | `"2.1.100"` |
| `disableAllHooks` | Disable all hooks and custom status line | `true` |
| `disableAutoMode` | Set to `"disable"` to prevent auto mode activation | `"disable"` |
| `disableWorkflows` | Disable dynamic workflows | `true` |
| `disableAgentView` | Disable background agents and agent view | `true` |
| `includeGitInstructions` | Include git workflow in system prompt (default: `true`) | `false` |
| `skipWebFetchPreflight` | Skip WebFetch domain safety check | `true` |
| `attribution` | Git commit/PR attribution text | `{"commit":"...", "pr":""}` |
| `fileSuggestion` | Custom `@` file autocomplete command | `{"type":"command","command":"..."}` |
| `plansDirectory` | Where plan files are stored | `"./plans"` |
| `viewMode` | Default transcript view: `"default"`, `"verbose"`, `"focus"` | `"verbose"` |
| `preferredNotifChannel` | Notification method | `"terminal_bell"` |
| `spinnerTipsEnabled` | Show tips while Claude works (default: `true`) | `false` |
| `showThinkingSummaries` | Show extended thinking summaries | `true` |
| `agent` | Run main thread as a named subagent | `"code-reviewer"` |
| `autoMode` | Auto mode classifier config (see below) | — |
| `forceLoginMethod` | Restrict login to `claudeai` or `console` | `"claudeai"` |
| `forceLoginOrgUUID` | Require login to belong to a specific org UUID | `"xxxx-..."` |

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
| `Edit(/src/**/*.ts)` | Project-root-relative path match |
| `WebFetch(domain:example.com)` | Match fetches to domain |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `Agent(Explore)` | Control subagent use |

Path anchors in Read/Edit rules: `//path` = absolute, `~/path` = home-relative, `/path` = project-root-relative, `path` or `./path` = cwd-relative.

Wildcard `*` matches any sequence including spaces. Space before `*` enforces a word boundary: `Bash(ls *)` matches `ls -la` but not `lsof`. Compound commands are checked per-subcommand. A bare tool name as a deny rule removes the tool from Claude's context entirely.

### Permission Modes

Set via `permissions.defaultMode`, `--permission-mode`, or `Shift+Tab` cycling in the CLI.

| Mode | What runs without asking | Best for |
|:-----|:------------------------|:---------|
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common fs commands | Iterating on code |
| `plan` | Reads only (no edits; proposes plan) | Exploring before changing |
| `auto` | Everything with background safety checks | Long tasks, less prompt fatigue |
| `dontAsk` | Only pre-approved tools | CI/scripts with known tool set |
| `bypassPermissions` | Everything (circuit breaker for `rm -rf /`) | Containers/VMs only |

`auto` mode: requires Anthropic API (not Bedrock/Vertex/Foundry), Claude Opus 4.6+ or Sonnet 4.6, v2.1.83+, and admin enablement on Team/Enterprise. Uses a classifier that blocks irreversible/external actions by default. Ignored from project/local settings to prevent repos from granting themselves auto mode — set in `~/.claude/settings.json` instead.

**What auto mode blocks by default:** `curl | bash`, sending sensitive data to external endpoints, production deploys/migrations, force-push or push to `main`, mass deletion, granting IAM/repo permissions.

**What auto mode allows by default:** local file ops in working dir, installing dependencies from lock files, read-only HTTP requests, pushing to the branch you started on.

### Protected Paths (never auto-approved except in `bypassPermissions`)

Directories: `.git`, `.vscode`, `.idea`, `.husky`, `.cargo`, `.claude` (except `commands/`, `agents/`, `skills/`, `worktrees/`).
Files: `.gitconfig`, `.gitmodules`, `.bashrc`, `.bash_profile`, `.zshrc`, `.zprofile`, `.profile`, `.ripgreprc`, `.mcp.json`, `.claude.json`.

### Sandbox Settings

Nested under `"sandbox"`:

| Key | Description |
|:----|:------------|
| `enabled` | Enable bash sandboxing (macOS, Linux, WSL2) |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: `true`) |
| `excludedCommands` | Commands to run outside sandbox |
| `failIfUnavailable` | Exit if sandbox can't start |
| `filesystem.allowWrite` | Additional writable paths (merged across scopes) |
| `filesystem.denyWrite` | Blocked write paths |
| `filesystem.denyRead` | Blocked read paths |
| `filesystem.allowRead` | Re-allow within denyRead regions |
| `network.allowedDomains` | Allowed outbound domains (supports wildcards) |
| `network.deniedDomains` | Blocked domains (merged from all scopes) |
| `network.allowUnixSockets` | Unix socket paths (macOS only) |
| `network.allowLocalBinding` | Allow localhost port binding (macOS only) |
| `network.httpProxyPort` | HTTP proxy port for custom proxy |
| `network.socksProxyPort` | SOCKS5 proxy port for custom proxy |

Sandbox path prefixes: `/path` = absolute, `~/path` = home-relative, `./path` or bare path = project-relative (project settings) or `~/.claude`-relative (user settings).

### Worktree Settings

| Key | Description |
|:----|:------------|
| `worktree.baseRef` | Branch source: `"fresh"` (origin default) or `"head"` (local HEAD) |
| `worktree.symlinkDirectories` | Dirs to symlink into worktrees (e.g. `["node_modules"]`) |
| `worktree.sparsePaths` | Sparse-checkout paths for large monorepos |
| `worktree.bgIsolation` | Background isolation: `"worktree"` (default) or `"none"` |

### Plugin Settings

| Key | Description |
|:----|:------------|
| `enabledPlugins` | `{"plugin@marketplace": true/false}` — enable/disable plugins |
| `extraKnownMarketplaces` | Register additional marketplace sources for team |
| `strictKnownMarketplaces` | (Managed only) Allowlist of permitted marketplace sources |
| `blockedMarketplaces` | (Managed only) Blocklist of marketplace sources |
| `strictPluginOnlyCustomization` | (Managed only) Block user/project skills, agents, hooks, MCP; `true` or array of surface names |
| `pluginTrustMessage` | (Managed only) Custom message appended to plugin trust warning |
| `pluginSuggestionMarketplaces` | (Managed only) Marketplace names whose plugins may appear as install suggestions |

### Managed-Only Settings

These keys only take effect in managed settings; user/project settings ignore them:

`allowAllClaudeAiMcps`, `allowedChannelPlugins`, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowManagedPermissionRulesOnly`, `allowedMcpServers`, `deniedMcpServers`, `blockedMarketplaces`, `channelsEnabled`, `claudeMd`, `claudeMdExcludes` (does apply at any scope for user/project files, but org policy files cannot be excluded), `forceRemoteSettingsRefresh`, `parentSettingsBehavior`, `pluginTrustMessage`, `pluginSuggestionMarketplaces`, `policyHelper`, `sandbox.filesystem.allowManagedReadPathsOnly`, `sandbox.network.allowManagedDomainsOnly`, `strictKnownMarketplaces`, `strictPluginOnlyCustomization`, `wslInheritsWindowsSettings`

### Server-Managed Settings

Available on Teams/Enterprise plans (v2.1.38+ for Teams, v2.1.30+ for Enterprise). Configure at **Admin Settings > Claude Code > Managed settings** on claude.ai.

- Fetched at startup and polled hourly during active sessions
- Cached locally; survives network failures on subsequent launches
- Takes highest precedence; cannot be overridden by users
- Not available when using Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`
- Set `forceRemoteSettingsRefresh: true` to block startup if fetch fails (fail-closed)
- Security dialogs shown to users before applying hooks, shell-command settings, or custom env vars
- Cannot distribute `managed-mcp.json` through server-managed settings; use `allowedMcpServers`/`deniedMcpServers` instead

### Managed Settings Delivery Mechanisms

| Mechanism | Platform | Priority |
|:----------|:---------|:---------|
| Server-managed (Claude.ai admin console) | All | Highest |
| plist (`com.anthropic.claudecode`) | macOS | High |
| Registry (`HKLM\SOFTWARE\Policies\ClaudeCode`) | Windows | High |
| `managed-settings.json` file | All | Medium |
| HKCU registry | Windows | Lowest |

Only one managed source is used per device (no cross-tier merging). Within file-based tier, `managed-settings.d/*.json` drop-ins merge on top of `managed-settings.json` alphabetically.

To extend Windows registry/file policy to WSL, set `wslInheritsWindowsSettings: true` in the HKLM key or system `managed-settings.json`.

### Auto Mode Configuration (`autoMode` key)

Tells the classifier which infrastructure is trusted. Not read from shared project settings (`.claude/settings.json`).

| Field | Description |
|:------|:------------|
| `environment` | Prose descriptions of trusted repos, buckets, domains. Include `"$defaults"` to keep built-in trust |
| `allow` | Exceptions to soft_deny rules. Include `"$defaults"` to inherit built-in exceptions |
| `soft_deny` | Destructive actions that user's explicit intent can override |
| `hard_deny` | Unconditional security boundaries that user intent cannot override |

Include `"$defaults"` in any array to inherit built-in rules at that position. Omitting it replaces the entire default list for that section — potentially removing force-push, `curl | bash`, and data-exfiltration blocks.

CLI inspection: `claude auto-mode defaults` (print built-in rules), `claude auto-mode config` (print effective config), `claude auto-mode critique` (AI feedback on custom rules).

### Key Environment Variables

Set in shell or under `"env"` in `settings.json`. Env vars generally override the corresponding `settings.json` field; CLI flags override env vars for the session.

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key (overrides subscription when set) |
| `ANTHROPIC_MODEL` | Override model for session |
| `ANTHROPIC_BASE_URL` | Route requests through proxy/gateway |
| `ANTHROPIC_BETAS` | Comma-separated extra `anthropic-beta` header values |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CONFIG_DIR` | Override config dir (default: `~/.claude`) |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set to `1` to enable OpenTelemetry |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort: `low`, `medium`, `high`, `xhigh`, `max` |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash timeout (default: 120000 ms) |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout model can set (default: 600000 ms) |
| `API_TIMEOUT_MS` | API request timeout (default: 600000 ms) |
| `DISABLE_TELEMETRY` / `DO_NOT_TRACK` | Opt out of telemetry |
| `DISABLE_AUTOUPDATER` | Disable auto-updates (manual `claude update` still works) |
| `DISABLE_UPDATES` | Block all updates including manual |
| `DISABLE_COMPACT` | Disable all compaction |
| `DISABLE_AUTO_COMPACT` | Disable automatic compaction only |
| `MAX_THINKING_TOKENS` | Override extended thinking budget |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Don't write session transcripts to disk |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen rendering (equivalent to `tui: "fullscreen"`) |
| `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN` | Force classic main-screen renderer |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_DISABLE_WORKFLOWS` | Disable dynamic workflows |
| `CLAUDE_CODE_DISABLE_AGENT_VIEW` | Disable background agents and agent view |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | Refresh interval for `apiKeyHelper` credentials |
| `CLAUDE_CODE_DISABLE_THINKING` | Force-disable extended thinking regardless of model |
| `CLAUDE_CODE_DISABLE_FAST_MODE` | Disable fast mode |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Context capacity percentage (1-100) at which auto-compaction triggers |
| `MCP_TIMEOUT` | MCP server startup timeout (default: 30000 ms) |
| `MCP_TOOL_TIMEOUT` | MCP tool execution timeout (default: ~28 hours) |
| `CLAUDECODE` | Set to `1` in subprocesses spawned by Claude Code |
| `CLAUDE_CODE_SESSION_ID` | Current session ID in subprocesses |
| `CLAUDE_ENV_FILE` | Script sourced before each Bash command |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy for network connections |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess envs (reduces prompt injection risk) |

OTel variables: `OTEL_METRICS_EXPORTER`, `OTEL_LOGS_EXPORTER`, `OTEL_EXPORTER_OTLP_ENDPOINT`, `OTEL_EXPORTER_OTLP_HEADERS`, `OTEL_LOG_TOOL_CONTENT`, `OTEL_LOG_USER_PROMPTS`, etc.

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
