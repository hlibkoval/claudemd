---
name: settings-doc
description: Complete documentation for Claude Code settings and configuration -- settings.json (user/project/local/managed scopes, precedence rules, available settings table with all keys), permissions (permission system tiers, modes default/acceptEdits/plan/dontAsk/bypassPermissions, rule syntax Tool/Tool(specifier), wildcard patterns, tool-specific rules for Bash/Read/Edit/WebFetch/MCP/Agent, deny>ask>allow evaluation order, working directories --add-dir, sandbox interaction, managed-only settings disableBypassPermissionsMode/allowManagedPermissionRulesOnly/allowManagedHooksOnly/allowManagedMcpServersOnly/blockedMarketplaces/sandbox.network.allowManagedDomainsOnly/sandbox.filesystem.allowManagedReadPathsOnly/strictKnownMarketplaces/allow_remote_sessions), sandbox settings (enabled, autoAllowBashIfSandboxed, excludedCommands, allowUnsandboxedCommands, filesystem allowWrite/denyWrite/denyRead/allowRead with path prefixes, network allowedDomains/allowUnixSockets/allowLocalBinding/httpProxyPort/socksProxyPort), server-managed settings (Claude.ai admin console, Teams/Enterprise, fetch/caching, security approval dialogs, platform availability, audit logging), environment variables (ANTHROPIC_API_KEY, ANTHROPIC_BASE_URL, ANTHROPIC_MODEL, CLAUDE_CODE_USE_BEDROCK/VERTEX/FOUNDRY, CLAUDE_CODE_SHELL, MCP_TIMEOUT, MAX_MCP_OUTPUT_TOKENS, ENABLE_TOOL_SEARCH, proxy vars, telemetry, and 90+ more), attribution settings, plugin configuration (enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces, blockedMarketplaces), worktree settings, file suggestion settings, hook configuration (allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars), global config settings (~/.claude.json). Load when discussing settings.json, configuration, permissions, permission rules, permission modes, managed settings, server-managed settings, sandbox settings, environment variables, env vars, ANTHROPIC_API_KEY, ANTHROPIC_BASE_URL, ANTHROPIC_MODEL, CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, CLAUDE_CODE_USE_FOUNDRY, bypassPermissions, dangerously-skip-permissions, settings precedence, managed-settings.json, permission deny rules, permission allow rules, Bash permissions, Read permissions, Edit permissions, WebFetch permissions, MCP permissions, Agent permissions, sandbox filesystem, sandbox network, allowedDomains, working directories, add-dir, attribution, plugins settings, enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces, worktree settings, hook configuration, allowManagedHooksOnly, companyAnnouncements, defaultMode, apiKeyHelper, or configuring Claude Code behavior.
user-invocable: false
---

# Settings & Configuration Documentation

This skill provides the complete official documentation for configuring Claude Code via settings files, permissions, environment variables, and server-managed settings.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared? |
|:------|:---------|:---------------|:--------|
| Managed | Server-managed, plist/registry, or `managed-settings.json` | All users on machine | Yes (deployed by IT) |
| User | `~/.claude/settings.json` | You, across all projects | No |
| Project | `.claude/settings.json` | All collaborators on repo | Yes (committed to git) |
| Local | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |

**Precedence (highest to lowest):** Managed > CLI arguments > Local > Project > User. Array settings (like `permissions.allow`, `sandbox.filesystem.allowWrite`) merge across scopes.

Run `/config` to open the settings UI. Run `/status` to see which settings sources are active.

### Settings Files

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings (all projects) |
| `.claude/settings.json` | Project settings (shared with team) |
| `.claude/settings.local.json` | Local project overrides (gitignored) |
| `~/.claude.json` | Preferences, OAuth, MCP configs, per-project state |
| `managed-settings.json` | Organization-wide policy (system directory) |

Managed settings file locations:

| Platform | Path |
|:---------|:-----|
| macOS | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux/WSL | `/etc/claude-code/managed-settings.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-settings.json` |

MDM/OS-level policies: macOS `com.anthropic.claudecode` managed preferences; Windows `HKLM\SOFTWARE\Policies\ClaudeCode` registry key. Within managed tier: server-managed > MDM/OS-level > managed-settings.json > HKCU registry (Windows).

Add `"$schema": "https://json.schemastore.org/claude-code-settings.json"` for autocomplete/validation in editors.

### Key Settings (settings.json)

| Key | Description |
|:----|:------------|
| `permissions` | Permission rules (`allow`, `ask`, `deny` arrays, `defaultMode`, `additionalDirectories`, `disableBypassPermissionsMode`) |
| `env` | Environment variables applied to every session |
| `hooks` | Custom commands at lifecycle events |
| `model` | Override default model |
| `availableModels` | Restrict which models users can select via `/model` |
| `modelOverrides` | Map model IDs to provider-specific IDs (e.g., Bedrock ARNs) |
| `effortLevel` | Persist effort level: `"low"`, `"medium"`, `"high"` |
| `sandbox` | Sandbox configuration (filesystem, network restrictions) |
| `attribution` | Customize git commit/PR attribution |
| `language` | Preferred response language |
| `outputStyle` | Output style for system prompt |
| `agent` | Run main thread as a named subagent |
| `apiKeyHelper` | Script to generate auth value |
| `statusLine` | Custom status line |
| `fileSuggestion` | Custom `@` file autocomplete script |
| `companyAnnouncements` | Startup announcements for users |
| `enabledPlugins` | Plugin enable/disable map (`"name@marketplace": true/false`) |
| `extraKnownMarketplaces` | Additional plugin marketplaces for the repo |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) |
| `cleanupPeriodDays` | Session cleanup threshold (default: 30; 0 disables persistence) |
| `autoMemoryDirectory` | Custom auto memory storage path |
| `forceLoginMethod` | `"claudeai"` or `"console"` |
| `teammateMode` | Agent team display: `"auto"`, `"in-process"`, `"tmux"` |
| `worktree.symlinkDirectories` | Directories to symlink into worktrees |
| `worktree.sparsePaths` | Sparse-checkout paths for worktrees |
| `spinnerVerbs` | Custom spinner verbs (`mode`: `"replace"` or `"append"`) |
| `spinnerTipsEnabled` | Show spinner tips (default: true) |
| `spinnerTipsOverride` | Custom spinner tips with `excludeDefault` flag |
| `prefersReducedMotion` | Reduce UI animations |
| `fastModePerSessionOptIn` | Require per-session fast mode opt-in |
| `feedbackSurveyRate` | Survey probability (0--1; 0 suppresses) |

### Permission System

Permission modes (set via `defaultMode`):

| Mode | Description |
|:-----|:------------|
| `default` | Standard: prompts on first use of each tool |
| `acceptEdits` | Auto-accepts file edit permissions for the session |
| `plan` | Read-only: analyze but not modify files or run commands |
| `dontAsk` | Auto-denies tools unless pre-approved via `/permissions` or `permissions.allow` |
| `bypassPermissions` | Skips prompts (except writes to `.git`, `.claude`, `.vscode`, `.idea`). Use only in isolated environments |

Rule evaluation order: **deny > ask > allow** (first matching rule wins).

Rule syntax: `Tool` or `Tool(specifier)`.

| Rule example | Effect |
|:-------------|:-------|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run ` |
| `Bash(* --version)` | Matches commands ending with `--version` |
| `Read(./.env)` | Matches reading `.env` in cwd |
| `Edit(/src/**/*.ts)` | Matches editing TS files under project `src/` |
| `Read(//Users/alice/secrets/**)` | Matches absolute path reads |
| `Read(~/.zshrc)` | Matches home-relative reads |
| `WebFetch(domain:example.com)` | Matches web fetch to domain |
| `mcp__puppeteer__puppeteer_navigate` | Matches specific MCP tool |
| `Agent(Explore)` | Matches the Explore subagent |

Read/Edit path patterns follow the gitignore spec: `//path` = absolute, `~/path` = home, `/path` = project root, `path` or `./path` = current directory. `*` matches within a directory, `**` matches recursively.

Warning: Read/Edit deny rules apply to Claude's built-in file tools, not to Bash subprocesses. Use the sandbox for OS-level enforcement.

Warning: Bash permission patterns constraining arguments are fragile (option reordering, variable expansion, etc.). For URL filtering, use `WebFetch(domain:...)` rules or PreToolUse hooks instead.

### Sandbox Settings

All under the `sandbox` key in settings.json:

| Key | Description | Default |
|:----|:------------|:--------|
| `enabled` | Enable bash sandboxing | `false` |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed | `true` |
| `excludedCommands` | Commands that run outside sandbox | `[]` |
| `allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch | `true` |
| `filesystem.allowWrite` | Additional writable paths (merged across scopes) | `[]` |
| `filesystem.denyWrite` | Paths blocked from writing | `[]` |
| `filesystem.denyRead` | Paths blocked from reading | `[]` |
| `filesystem.allowRead` | Re-allow reading within denyRead regions | `[]` |
| `network.allowedDomains` | Allowed outbound domains (supports wildcards) | `[]` |
| `network.allowUnixSockets` | Allowed Unix socket paths | `[]` |
| `network.allowAllUnixSockets` | Allow all Unix sockets | `false` |
| `network.allowLocalBinding` | Allow localhost port binding (macOS) | `false` |
| `network.httpProxyPort` | Custom HTTP proxy port | -- |
| `network.socksProxyPort` | Custom SOCKS5 proxy port | -- |

Sandbox path prefixes: `/path` = absolute, `~/path` = home, `./path` or no prefix = project root (for project settings) or `~/.claude` (for user settings). Note: this differs from Read/Edit rules where `/path` is project-relative.

### Managed-Only Settings

These settings only take effect in managed settings:

| Setting | Description |
|:--------|:------------|
| `disableBypassPermissionsMode` | `"disable"` to prevent bypass mode and `--dangerously-skip-permissions` |
| `allowManagedPermissionRulesOnly` | `true` to block user/project permission rules |
| `allowManagedHooksOnly` | `true` to block user/project/plugin hooks |
| `allowManagedMcpServersOnly` | `true` to restrict MCP servers to admin allowlist |
| `blockedMarketplaces` | Blocklist of plugin marketplace sources |
| `sandbox.network.allowManagedDomainsOnly` | `true` to restrict domains to managed allowlist |
| `sandbox.filesystem.allowManagedReadPathsOnly` | `true` to restrict `allowRead` paths to managed settings |
| `strictKnownMarketplaces` | Allowlist of plugin marketplaces users can add |
| `allow_remote_sessions` | `true`/`false` to control Remote Control and web sessions |

### Server-Managed Settings

Server-managed settings are delivered from Anthropic's servers via the Claude.ai admin console. Available for Claude for Teams and Enterprise.

- Requires Claude Code v2.1.38+ (Teams) or v2.1.30+ (Enterprise)
- Network access to `api.anthropic.com` required
- Settings fetched at startup, polled hourly
- Cached settings apply immediately on subsequent launches
- Takes precedence over endpoint-managed settings when both present
- Not available with Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`

Access control: Primary Owner and Owner roles can manage settings.

Security approval dialogs appear for shell command settings, custom env vars, and hook configurations. Non-interactive mode (`-p` flag) skips dialogs.

### Key Environment Variables

Set in your shell or in `settings.json` under the `env` key. Full list: 100+ variables.

**Authentication & API:**

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key for Claude API |
| `ANTHROPIC_AUTH_TOKEN` | Pre-authenticated session token |
| `ANTHROPIC_BASE_URL` | Custom API endpoint |
| `ANTHROPIC_MODEL` | Override model for session |
| `ANTHROPIC_SMALL_FAST_MODEL` | Model for background/fast-mode tasks |

**Cloud Providers:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_USE_BEDROCK` | `1` to use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | `1` to use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | `1` to use Microsoft Foundry |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Foundry endpoint URL |
| `ANTHROPIC_FOUNDRY_API_KEY` | Foundry API key |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Foundry resource name |

**Model Configuration:**

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Custom Sonnet model ID |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Custom Opus model ID |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Custom Haiku model ID |
| `ANTHROPIC_CUSTOM_MODEL_OPTION` | Add a custom model option to `/model` |
| `MAX_THINKING_TOKENS` | Max extended thinking tokens |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set reasoning effort: `low`, `medium`, `high` |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Max output tokens per response |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |

**Bash & Tools:**

| Variable | Purpose |
|:---------|:--------|
| `BASH_DEFAULT_TIMEOUT_MS` | Default Bash command timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Maximum allowed Bash timeout (default: 600000) |
| `BASH_MAX_OUTPUT_LENGTH` | Max Bash output characters (default: 1000000) |
| `CLAUDE_CODE_SHELL` | Override shell for Bash tool |
| `CLAUDE_CODE_SHELL_PREFIX` | Extra shell options (e.g., `-x` for debug) |
| `CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS` | Max tokens for file reads |
| `USE_BUILTIN_RIPGREP` | `1` to use bundled ripgrep |
| `SLASH_COMMAND_TOOL_CHAR_BUDGET` | Character budget for skill/command tools |

**MCP & Tools:**

| Variable | Purpose |
|:---------|:--------|
| `MCP_TIMEOUT` | MCP server startup timeout in ms |
| `MCP_TOOL_TIMEOUT` | Individual MCP tool call timeout in ms |
| `MAX_MCP_OUTPUT_TOKENS` | Max MCP output tokens (default: 25000) |
| `ENABLE_TOOL_SEARCH` | MCP tool search: `true`, `false`, `auto`, `auto:<N>` |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Enable Claude.ai MCP servers |

**Proxy & Network:**

| Variable | Purpose |
|:---------|:--------|
| `HTTP_PROXY` | HTTP proxy URL |
| `HTTPS_PROXY` | HTTPS proxy URL |
| `NO_PROXY` | Comma-separated proxy bypass list |
| `CLAUDE_CODE_CLIENT_CERT` | mTLS client certificate path |
| `CLAUDE_CODE_CLIENT_KEY` | mTLS client key path |

**Telemetry & Monitoring:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | `1` to enable OpenTelemetry |
| `DISABLE_TELEMETRY` | `1` to disable all telemetry |
| `DISABLE_ERROR_REPORTING` | `1` to disable error reporting |

**Behavior Control:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | `1` to disable auto memory |
| `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` | Disable built-in git instructions |
| `CLAUDE_CODE_PLAN_MODE_REQUIRED` | `1` to force plan mode |
| `CLAUDE_CODE_DISABLE_FAST_MODE` | Disable fast mode |
| `CLAUDE_CODE_NEW_INIT` | `true` for interactive `/init` flow |
| `CLAUDE_CODE_DISABLE_CRON` | Disable scheduled tasks |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | Disable background tasks |
| `CLAUDE_CODE_SIMPLE` | Simplified output (fewer decorations) |

**Session & Identity:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_ACCOUNT_UUID` | Account UUID for the session |
| `CLAUDE_CODE_ORGANIZATION_UUID` | Organization UUID |
| `CLAUDE_CODE_USER_EMAIL` | User email for the session |
| `CLAUDE_CODE_TEAM_NAME` | Team name for the session |
| `CLAUDE_CODE_TASK_LIST_ID` | Task list ID for scheduled tasks |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `CLAUDE_CODE_TMPDIR` | Override temp directory |
| `CLAUDE_ENV_FILE` | Path to an env file to load at startup |

**Updates & Misc:**

| Variable | Purpose |
|:---------|:--------|
| `DISABLE_AUTOUPDATER` | `1` to disable auto-updates |
| `FORCE_AUTOUPDATE_PLUGINS` | Force plugin auto-updates |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching |
| `DISABLE_COST_WARNINGS` | Disable cost warnings |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Override auto-compact threshold percentage |
| `CLAUDE_CODE_AUTO_COMPACT_WINDOW` | Override auto-compact context window check |

### Attribution Settings

| Key | Description |
|:----|:------------|
| `attribution.commit` | Commit attribution text (empty string hides it) |
| `attribution.pr` | PR description attribution (empty string hides it) |

The `attribution` setting takes precedence over the deprecated `includeCoAuthoredBy`.

### Hook Configuration Settings

| Key | Description |
|:----|:------------|
| `disableAllHooks` | Disable all hooks and custom status line |
| `allowManagedHooksOnly` | (Managed only) Block user/project/plugin hooks |
| `allowedHttpHookUrls` | URL patterns HTTP hooks may target (supports `*`; merged across scopes) |
| `httpHookAllowedEnvVars` | Env var names HTTP hooks may interpolate into headers (merged across scopes) |

### Plugin Configuration

| Key | Description |
|:----|:------------|
| `enabledPlugins` | Map of `"plugin@marketplace": true/false` |
| `extraKnownMarketplaces` | Named marketplace definitions (auto-install for team) |
| `strictKnownMarketplaces` | (Managed only) Allowlist of marketplace sources |
| `blockedMarketplaces` | (Managed only) Blocklist of marketplace sources |
| `pluginTrustMessage` | (Managed only) Custom message for plugin trust warning |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) -- configuration scopes (managed/user/project/local with precedence rules and when-to-use guidance), settings files (locations, managed delivery via server/MDM/plist/registry/file, ~/.claude.json), available settings table (all keys including apiKeyHelper, autoMemoryDirectory, cleanupPeriodDays, companyAnnouncements, env, attribution, permissions, hooks, model, availableModels, modelOverrides, effortLevel, sandbox, statusLine, fileSuggestion, outputStyle, agent, forceLoginMethod, enableAllProjectMcpServers, language, voiceEnabled, autoUpdatesChannel, spinnerVerbs, spinnerTipsEnabled, worktree settings, and more), global config settings (~/.claude.json keys), permission settings (allow/ask/deny arrays, defaultMode, additionalDirectories, disableBypassPermissionsMode), permission rule syntax (Tool/Tool(specifier), wildcards, tool-specific patterns), sandbox settings (enabled, autoAllowBashIfSandboxed, excludedCommands, filesystem paths, network domains/sockets/proxy, path prefix conventions), attribution settings (commit/pr customization), file suggestion settings (custom @-autocomplete script), hook configuration (allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars), settings precedence (managed > CLI > local > project > user, array merging), /status verification, plugin configuration (enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces with 7 source types and exact matching, blockedMarketplaces), subagent configuration, system prompt, excluding sensitive files
- [Configure permissions](references/claude-code-permissions.md) -- permission system (tiered tool types, approval behavior), /permissions command, permission modes (default/acceptEdits/plan/dontAsk/bypassPermissions with warnings), permission rule syntax (Tool/Tool(specifier) format, match-all, specifiers), wildcard patterns (glob with *, word boundary behavior, space semantics), tool-specific rules (Bash wildcards and compound commands, Read/Edit gitignore-spec patterns with //path/~/path//path/./path, WebFetch domain matching, MCP server and tool matching, Agent subagent matching), extending permissions with hooks (PreToolUse allow/deny, deny-first precedence preserved), working directories (--add-dir, /add-dir, additionalDirectories), permissions and sandboxing interaction (complementary layers, defense-in-depth), managed settings (managed-only settings table: disableBypassPermissionsMode, allowManagedPermissionRulesOnly, allowManagedHooksOnly, allowManagedMcpServersOnly, blockedMarketplaces, sandbox.network.allowManagedDomainsOnly, sandbox.filesystem.allowManagedReadPathsOnly, strictKnownMarketplaces, allow_remote_sessions), settings precedence (deny at any level blocks), example configurations
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) -- requirements (Teams/Enterprise, version minimums, api.anthropic.com access), server-managed vs endpoint-managed comparison, configuration steps (admin console, JSON editor, save/deploy), verify settings delivery, access control (Primary Owner, Owner roles), current limitations (uniform for all users, no MCP server configs), settings delivery (precedence over endpoint-managed, fetch/caching behavior, first-launch vs cached, hourly polling, auto-apply), security approval dialogs (shell commands, custom env vars, hooks, non-interactive -p flag), platform availability (not available with Bedrock/Vertex/Foundry/custom base URL), audit logging, security considerations (client-side control, tampered cache, API unavailable, different org, non-default base URL), ConfigChange hooks
- [Environment variables reference](references/claude-code-env-vars.md) -- complete reference for 100+ environment variables controlling authentication (ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_BASE_URL), cloud providers (CLAUDE_CODE_USE_BEDROCK/VERTEX/FOUNDRY, AWS/Foundry/Vertex config), model selection (ANTHROPIC_MODEL, ANTHROPIC_DEFAULT_SONNET/OPUS/HAIKU_MODEL, ANTHROPIC_CUSTOM_MODEL_OPTION, ANTHROPIC_SMALL_FAST_MODEL, MAX_THINKING_TOKENS), bash/tool behavior (BASH_DEFAULT_TIMEOUT_MS, BASH_MAX_TIMEOUT_MS, BASH_MAX_OUTPUT_LENGTH, CLAUDE_CODE_SHELL, CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS), MCP (MCP_TIMEOUT, MCP_TOOL_TIMEOUT, MAX_MCP_OUTPUT_TOKENS, ENABLE_TOOL_SEARCH, ENABLE_CLAUDEAI_MCP_SERVERS, MCP_CLIENT_SECRET), proxy/network (HTTP_PROXY, HTTPS_PROXY, NO_PROXY, mTLS certs), telemetry (CLAUDE_CODE_ENABLE_TELEMETRY, DISABLE_TELEMETRY, OTEL config), behavior control (CLAUDE_CODE_DISABLE_AUTO_MEMORY, CLAUDE_CODE_PLAN_MODE_REQUIRED, CLAUDE_CODE_DISABLE_FAST_MODE, CLAUDE_CODE_SIMPLE), session/identity (CLAUDE_CODE_ACCOUNT_UUID, CLAUDE_CONFIG_DIR, CLAUDE_ENV_FILE), updates/caching (DISABLE_AUTOUPDATER, DISABLE_PROMPT_CACHING), and more

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables reference: https://code.claude.com/docs/en/env-vars.md
