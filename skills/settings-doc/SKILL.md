---
name: settings-doc
description: Complete documentation for Claude Code settings, permissions, permission modes, server-managed settings, and environment variables -- settings files (settings.json at user/project/local/managed scopes, ~/.claude/settings.json, .claude/settings.json, .claude/settings.local.json, managed-settings.json, MDM/plist/registry delivery), available settings (apiKeyHelper, autoMemoryDirectory, cleanupPeriodDays, companyAnnouncements, env, attribution, permissions, autoMode, disableAutoMode, hooks, disableAllHooks, allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars, allowManagedPermissionRulesOnly, allowManagedMcpServersOnly, model, availableModels, modelOverrides, effortLevel, otelHeadersHelper, statusLine, fileSuggestion, respectGitignore, outputStyle, agent, forceLoginMethod, forceLoginOrgUUID, enableAllProjectMcpServers, enabledMcpjsonServers, disabledMcpjsonServers, channelsEnabled, allowedMcpServers, deniedMcpServers, strictKnownMarketplaces, blockedMarketplaces, pluginTrustMessage, awsAuthRefresh, awsCredentialExport, alwaysThinkingEnabled, plansDirectory, spinnerVerbs, language, voiceEnabled, autoUpdatesChannel, spinnerTipsEnabled, spinnerTipsOverride, prefersReducedMotion, fastModePerSessionOptIn, teammateMode, feedbackSurveyRate), global config settings (~/.claude.json: autoConnectIde, autoInstallIdeExtension, editorMode, showTurnDuration, terminalProgressBarEnabled), worktree settings (symlinkDirectories, sparsePaths), permission settings (allow, ask, deny, additionalDirectories, defaultMode, disableBypassPermissionsMode), permission rule syntax (Tool(specifier), wildcards, Bash, Read, Edit, WebFetch domain, MCP, Agent rules), sandbox settings (enabled, autoAllowBashIfSandboxed, excludedCommands, allowUnsandboxedCommands, filesystem allowWrite/denyWrite/denyRead/allowRead/allowManagedReadPathsOnly, network allowUnixSockets/allowAllUnixSockets/allowLocalBinding/allowedDomains/allowManagedDomainsOnly/httpProxyPort/socksProxyPort, enableWeakerNestedSandbox, enableWeakerNetworkIsolation), attribution settings (commit, pr), file suggestion settings, hook configuration (allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars), settings precedence (managed > CLI args > local > project > user), permission system (tiered tool permissions, allow/ask/deny rules, deny-first evaluation), permission modes (default, acceptEdits, plan, auto, bypassPermissions, dontAsk, Shift+Tab cycling, --permission-mode flag, defaultMode setting), auto mode (classifier model, cost, latency, evaluation order, subagent handling, default blocks/allows, fallback behavior, autoMode.environment/allow/soft_deny configuration, claude auto-mode defaults/config/critique), plan mode (research and propose, /plan prefix, approve-and-start flow), managed-only settings (allowManagedPermissionRulesOnly, allowManagedHooksOnly, allowManagedMcpServersOnly, blockedMarketplaces, sandbox.network.allowManagedDomainsOnly, sandbox.filesystem.allowManagedReadPathsOnly, strictKnownMarketplaces), auto mode classifier configuration (environment, allow, soft_deny, prose rules, trusted infrastructure, claude auto-mode defaults/config/critique), server-managed settings (admin console delivery, Claude for Teams/Enterprise, hourly polling, security approval dialogs, platform availability, audit logging, settings precedence, fetch and caching, access control), environment variables (ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_BASE_URL, ANTHROPIC_MODEL, CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, CLAUDE_CODE_USE_FOUNDRY, CLAUDE_CODE_SHELL, BASH_DEFAULT_TIMEOUT_MS, DISABLE_AUTOUPDATER, DISABLE_TELEMETRY, HTTP_PROXY, HTTPS_PROXY, MCP_TIMEOUT, MAX_THINKING_TOKENS, and 80+ more), plugin configuration (enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces, blockedMarketplaces). Load when discussing Claude Code settings, configuration, settings.json, permissions, permission rules, permission modes, allow rules, deny rules, ask rules, managed settings, server-managed settings, enterprise settings, MDM, permission rule syntax, Bash permission wildcards, Read/Edit permission patterns, sandbox settings, sandbox configuration, environment variables, env vars, ANTHROPIC_API_KEY, ANTHROPIC_MODEL, ANTHROPIC_BASE_URL, proxy settings, HTTP_PROXY, auto mode, auto mode classifier, autoMode configuration, plan mode, bypassPermissions, dontAsk mode, acceptEdits, permission precedence, settings precedence, settings scopes, /config, /permissions, /status, defaultMode, working directories, additionalDirectories, attribution settings, hook configuration, worktree settings, plugin configuration, enabledPlugins, extraKnownMarketplaces, fileSuggestion, spinnerVerbs, cleanupPeriodDays, companyAnnouncements, or any settings/configuration/permissions topic for Claude Code.
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, permission modes, server-managed settings, and environment variables.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared? |
|:------|:---------|:---------------|:--------|
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | All org users | Yes (deployed by IT) |
| **User** | `~/.claude/settings.json` | You, all projects | No |
| **Project** | `.claude/settings.json` | All collaborators | Yes (committed to git) |
| **Local** | `.claude/settings.local.json` | You, this project only | No (gitignored) |

### Settings Precedence (highest to lowest)

1. **Managed settings** (server-managed > MDM/OS-level > managed-settings.json)
2. **Command line arguments**
3. **Local project** (`.claude/settings.local.json`)
4. **Shared project** (`.claude/settings.json`)
5. **User** (`~/.claude/settings.json`)

Array-valued settings (like `permissions.allow`, `sandbox.filesystem.allowWrite`) merge across scopes rather than replacing.

### Managed Settings File Locations

| Platform | Path |
|:---------|:-----|
| macOS (file) | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| macOS (MDM) | `com.anthropic.claudecode` managed preferences domain |
| Linux/WSL | `/etc/claude-code/managed-settings.json` |
| Windows (file) | `C:\Program Files\ClaudeCode\managed-settings.json` |
| Windows (registry) | `HKLM\SOFTWARE\Policies\ClaudeCode` key, `Settings` value |

### Key Settings (settings.json)

| Key | Description |
|:----|:------------|
| `permissions` | Allow/ask/deny rules, defaultMode, additionalDirectories, disableBypassPermissionsMode |
| `autoMode` | Auto mode classifier config: `environment`, `allow`, `soft_deny` arrays of prose rules |
| `hooks` | Lifecycle event hooks (see hooks-doc) |
| `env` | Environment variables applied to every session |
| `model` | Override default model |
| `availableModels` | Restrict models users can select via `/model` |
| `modelOverrides` | Map Anthropic model IDs to provider-specific IDs (e.g., Bedrock ARNs) |
| `effortLevel` | Persist effort level: `"low"`, `"medium"`, `"high"` |
| `sandbox` | Filesystem/network sandboxing config |
| `attribution` | Customize git commit and PR attribution |
| `agent` | Run main thread as a named subagent |
| `language` | Preferred response language |
| `companyAnnouncements` | Startup messages (array, cycled randomly) |
| `cleanupPeriodDays` | Session cleanup threshold (default: 30) |
| `apiKeyHelper` | Script to generate auth value |
| `outputStyle` | Output style name or path |
| `statusLine` | Custom status line config |
| `fileSuggestion` | Custom `@` file autocomplete command |
| `forceLoginMethod` | Restrict to `claudeai` or `console` |
| `enableAllProjectMcpServers` | Auto-approve all project `.mcp.json` servers |
| `disableAutoMode` | Set to `"disable"` to block auto mode |
| `disableAllHooks` | Disable all hooks and custom status line |
| `alwaysThinkingEnabled` | Extended thinking by default |
| `voiceEnabled` | Push-to-talk voice dictation |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) |
| `teammateMode` | Agent teams display: `"auto"`, `"in-process"`, `"tmux"` |
| `plansDirectory` | Where plan files are stored (default: `~/.claude/plans`) |
| `spinnerVerbs` | Custom spinner verbs (`{mode, verbs}`) |
| `spinnerTipsEnabled` | Show/hide spinner tips |
| `spinnerTipsOverride` | Custom spinner tips (`{excludeDefault, tips}`) |
| `channelsEnabled` | (Managed only) Allow channels |

### Global Config Settings (~/.claude.json)

These go in `~/.claude.json`, not `settings.json`:

| Key | Description |
|:----|:------------|
| `autoConnectIde` | Auto-connect to running IDE from external terminal |
| `autoInstallIdeExtension` | Auto-install Claude Code IDE extension in VS Code |
| `editorMode` | `"normal"` or `"vim"` |
| `showTurnDuration` | Show turn duration messages |
| `terminalProgressBarEnabled` | Show progress bar in supported terminals |

### Permission System

Rules are evaluated in order: **deny > ask > allow**. First matching rule wins.

| Tool type | Example | Approval required | "Don't ask again" behavior |
|:----------|:--------|:------------------|:---------------------------|
| Read-only | File reads, Grep | No | N/A |
| Bash commands | Shell execution | Yes | Permanently per project + command |
| File modification | Edit/write | Yes | Until session end |

### Permission Rule Syntax

Format: `Tool` or `Tool(specifier)`

| Rule | Effect |
|:-----|:-------|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Wildcard: commands starting with `npm run` |
| `Bash(git * main)` | Wildcard in middle: `git checkout main`, `git merge main` |
| `Read(./.env)` | Exact file relative to CWD |
| `Edit(/src/**/*.ts)` | Gitignore-style glob relative to project root |
| `Read(//Users/alice/secrets/**)` | Absolute path (double-slash prefix) |
| `Read(~/.zshrc)` | Home-relative path |
| `WebFetch(domain:example.com)` | Domain-scoped web fetch |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `mcp__puppeteer` | All tools from an MCP server |
| `Agent(Explore)` | Specific subagent |

**Read/Edit path prefixes**: `//path` = absolute, `~/path` = home, `/path` = project-root-relative, `path` or `./path` = CWD-relative. Follows gitignore spec: `*` matches in one directory, `**` matches recursively.

**Bash wildcard note**: `Bash(ls *)` (space before `*`) enforces word boundary -- matches `ls -la` but not `lsof`. `Bash(ls*)` matches both. Shell operators are handled: `Bash(safe-cmd *)` does not permit `safe-cmd && other-cmd`.

### Permission Modes

| Mode | What Claude can do without asking | Best for |
|:-----|:----------------------------------|:---------|
| `default` | Read files | Getting started, sensitive work |
| `acceptEdits` | Read and edit files | Iterating on code you review |
| `plan` | Read files (no edits, proposes plan) | Exploring codebases, planning refactors |
| `auto` | All actions, background safety classifier | Long-running tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down/CI environments |
| `bypassPermissions` | All actions, no checks | Isolated containers/VMs only |

**Switching modes**: `Shift+Tab` in CLI cycles through modes. `--permission-mode <mode>` at startup. `defaultMode` in settings for persistence.

**Auto mode** requires Team plan + Claude Sonnet 4.6 or Opus 4.6. Uses a classifier (runs on Sonnet 4.6) that checks each action against block/allow rules. Classifier calls count toward token usage.

**Auto mode evaluation order**: (1) allow/deny rules resolve first, (2) read-only + file edits in CWD auto-approved, (3) everything else goes to classifier, (4) if blocked, Claude retries alternative approach. Falls back to prompting after 3 consecutive or 20 total blocks.

### Auto Mode Classifier Configuration

| Field | Purpose |
|:------|:--------|
| `autoMode.environment` | Prose descriptions of trusted infrastructure (repos, buckets, domains, services) |
| `autoMode.allow` | Prose exceptions to block rules (replaces defaults if set) |
| `autoMode.soft_deny` | Prose block rules (replaces defaults if set) |

Read from user settings, `.claude/settings.local.json`, and managed settings only -- not from shared project settings.

**CLI inspection commands**:

| Command | Purpose |
|:--------|:--------|
| `claude auto-mode defaults` | Print built-in environment, allow, soft_deny rules |
| `claude auto-mode config` | Show effective config (your settings merged with defaults) |
| `claude auto-mode critique` | AI review of custom allow/soft_deny rules |

Setting `allow` or `soft_deny` replaces the entire default list for that section. Always start from `claude auto-mode defaults` output.

### Managed-Only Settings

These settings only take effect in managed settings:

| Setting | Description |
|:--------|:------------|
| `allowManagedPermissionRulesOnly` | Block user/project permission rules; only managed rules apply |
| `allowManagedHooksOnly` | Block user/project/plugin hooks; only managed + SDK hooks |
| `allowManagedMcpServersOnly` | Only managed `allowedMcpServers` respected |
| `blockedMarketplaces` | Blocklist checked before download |
| `sandbox.network.allowManagedDomainsOnly` | Only managed `allowedDomains` respected |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed `allowRead` paths respected |
| `strictKnownMarketplaces` | Restrict which marketplaces users can add |
| `channelsEnabled` | Allow channels for Team/Enterprise |

### Sandbox Settings

| Key | Description |
|:----|:------------|
| `sandbox.enabled` | Enable bash sandboxing (default: false) |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `sandbox.excludedCommands` | Commands that run outside sandbox |
| `sandbox.allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch (default: true) |
| `sandbox.filesystem.allowWrite` | Additional writable paths |
| `sandbox.filesystem.denyWrite` | Paths blocked for writing |
| `sandbox.filesystem.denyRead` | Paths blocked for reading |
| `sandbox.filesystem.allowRead` | Re-allow reading within denyRead regions |
| `sandbox.network.allowedDomains` | Domains allowed for outbound traffic (supports `*.example.com`) |
| `sandbox.network.allowUnixSockets` | Unix socket paths accessible in sandbox |
| `sandbox.network.allowLocalBinding` | Allow binding to localhost (macOS only) |
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port |
| `sandbox.network.socksProxyPort` | Custom SOCKS5 proxy port |

**Sandbox path prefixes**: `/path` = absolute, `~/path` = home-relative, `./path` or bare = project-root-relative (project settings) or `~/.claude`-relative (user settings).

### Server-Managed Settings

Available for Claude for Teams and Enterprise. Settings delivered from Anthropic's servers via the admin console at **Admin Settings > Claude Code > Managed settings**.

| Aspect | Detail |
|:-------|:-------|
| Requirements | Teams/Enterprise plan, Claude Code >=2.1.30 (Enterprise) or >=2.1.38 (Teams), network access to `api.anthropic.com` |
| Precedence | Highest tier; overrides endpoint-managed when both present |
| Delivery | Fetched at startup, polled hourly |
| Caching | Cached settings apply immediately on subsequent launches; persist through network failures |
| Access control | Primary Owner and Owner roles |
| Security dialogs | Shell commands, custom env vars, and hooks require user approval (skipped in `-p` mode) |
| Platform limits | Not available with Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL` |

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key for direct API usage |
| `ANTHROPIC_AUTH_TOKEN` | Pre-generated auth token (skips normal auth) |
| `ANTHROPIC_BASE_URL` | Custom API endpoint |
| `ANTHROPIC_MODEL` | Override model selection |
| `CLAUDE_CODE_USE_BEDROCK` | Enable Amazon Bedrock (`1`) |
| `CLAUDE_CODE_USE_VERTEX` | Enable Google Vertex AI (`1`) |
| `CLAUDE_CODE_USE_FOUNDRY` | Enable Microsoft Foundry (`1`) |
| `CLAUDE_CODE_SHELL` | Override shell (default: system shell) |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout |
| `BASH_MAX_TIMEOUT_MS` | Maximum bash timeout |
| `BASH_MAX_OUTPUT_LENGTH` | Max bash output characters |
| `MAX_THINKING_TOKENS` | Extended thinking token budget |
| `MCP_TIMEOUT` | MCP server startup timeout |
| `MCP_TOOL_TIMEOUT` | Per-tool MCP timeout |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy configuration |
| `NO_PROXY` | Domains to bypass proxy |
| `DISABLE_AUTOUPDATER` | Disable auto-updates |
| `DISABLE_TELEMETRY` | Disable telemetry |
| `DISABLE_ERROR_REPORTING` | Disable error reporting |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude` config directory |
| `CLAUDE_CODE_TMPDIR` | Override temp directory |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable automatic memory |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Max output tokens per response |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Context window % threshold for auto-compaction |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Override model for subagents |
| `CLAUDE_CODE_EFFORT_LEVEL` | Override effort level (`low`/`medium`/`high`) |
| `ENABLE_TOOL_SEARCH` | Enable deferred tool loading (`0` to disable) |
| `CLAUDE_CODE_PLAN_MODE_REQUIRED` | Force plan mode before edits (`1`) |
| `FORCE_AUTOUPDATE_PLUGINS` | Keep plugin auto-updates when `DISABLE_AUTOUPDATER` is set |

See the full list of 100+ environment variables in the reference docs below.

### Plugin Configuration (in settings.json)

| Key | Description |
|:----|:------------|
| `enabledPlugins` | `{"plugin@marketplace": true/false}` -- control which plugins are enabled |
| `extraKnownMarketplaces` | Define additional marketplaces for the repository |
| `strictKnownMarketplaces` | (Managed only) Allowlist of permitted marketplaces |
| `blockedMarketplaces` | (Managed only) Blocklist of blocked marketplace sources |

### Worktree Settings

| Key | Description |
|:----|:------------|
| `worktree.symlinkDirectories` | Directories to symlink from main repo to worktree |
| `worktree.sparsePaths` | Directories to checkout via sparse-checkout |

### Useful Commands

| Command | Purpose |
|:--------|:--------|
| `/config` | Open Settings interface |
| `/permissions` | View and manage permission rules |
| `/status` | See active settings sources and origins |
| `claude auto-mode defaults` | Print built-in auto mode rules |
| `claude auto-mode config` | Show effective auto mode config |
| `claude auto-mode critique` | AI review of custom auto mode rules |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) -- complete settings reference including configuration scopes, settings.json structure, available settings table (40+ keys), global config settings (~/.claude.json), worktree settings, permission settings, permission rule syntax, sandbox settings with filesystem/network isolation, attribution settings, file suggestion settings, hook configuration, settings precedence, plugin configuration (enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces), environment variables overview, tools reference pointer
- [Configure permissions](references/claude-code-permissions.md) -- permission system (tiered tool permissions, allow/ask/deny rules, deny-first evaluation, /permissions UI), permission modes overview (default, acceptEdits, plan, auto, dontAsk, bypassPermissions), permission rule syntax (Tool(specifier) format, wildcard patterns, Bash/Read/Edit/WebFetch/MCP/Agent tool-specific rules), extending permissions with hooks (PreToolUse decision control), working directories (--add-dir, /add-dir, additionalDirectories), permissions and sandboxing interaction, managed settings (managed-only settings table), auto mode classifier configuration (environment, allow, soft_deny prose rules, trusted infrastructure template, override rules, inspect and validate CLI commands), settings precedence for permission rules, example configurations
- [Server-managed settings](references/claude-code-server-managed-settings.md) -- centralized settings delivery from Anthropic servers for Teams/Enterprise, requirements, comparison with endpoint-managed settings, admin console configuration, settings delivery (precedence, fetch/caching behavior, security approval dialogs), platform availability limits, audit logging, security considerations (cache tampering, API unavailability, org switching)
- [Environment variables](references/claude-code-env-vars.md) -- complete reference for 100+ environment variables controlling authentication (ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN), API endpoints (ANTHROPIC_BASE_URL, provider-specific URLs), model selection (ANTHROPIC_MODEL, ANTHROPIC_SMALL_FAST_MODEL), cloud providers (CLAUDE_CODE_USE_BEDROCK/VERTEX/FOUNDRY), bash behavior (timeouts, output limits), context management (auto-compact, max output tokens, thinking tokens), MCP configuration (timeouts, OAuth), proxy settings (HTTP_PROXY, HTTPS_PROXY, NO_PROXY), telemetry and updates (DISABLE_TELEMETRY, DISABLE_AUTOUPDATER), shell and paths (CLAUDE_CODE_SHELL, CLAUDE_CONFIG_DIR, CLAUDE_CODE_TMPDIR), and feature flags
- [Permission modes](references/claude-code-permission-modes.md) -- detailed guide for each permission mode, switching modes (Shift+Tab cycling, CLI flags, VS Code/Desktop/JetBrains/web UI), plan mode (research-then-propose workflow, /plan prefix, approve-and-start flow with mode selection), auto mode (classifier mechanics, evaluation order, cost/latency, subagent handling, default blocks and allows, fallback behavior, admin enablement), dontAsk mode (pre-approved tools only), bypassPermissions mode (no checks, container-only), comparison table across modes, customization with permission rules and hooks

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Permission modes: https://code.claude.com/docs/en/permission-modes.md
