---
name: settings-doc
description: Complete documentation for Claude Code settings and configuration -- settings.json (configuration scopes: managed/user/project/local, available settings table with all keys, permissions settings with allow/ask/deny arrays, sandbox settings with filesystem/network controls, worktree settings, attribution settings, file suggestion settings, hook configuration settings, plugin configuration with enabledPlugins/extraKnownMarketplaces/strictKnownMarketplaces/blockedMarketplaces, settings precedence hierarchy, array merging across scopes, /config and /status commands), permissions (permission system with tool types, permission modes: default/acceptEdits/plan/dontAsk/bypassPermissions, permission rule syntax with Tool/Tool(specifier) format, wildcard patterns for Bash, gitignore-style patterns for Read/Edit with //absolute/~/home/relative prefixes, WebFetch domain rules, MCP tool rules, Agent subagent rules, Skill permission rules, deny>ask>allow evaluation order, managed-only settings: disableBypassPermissionsMode/allowManagedPermissionRulesOnly/allowManagedHooksOnly/allowManagedMcpServersOnly/blockedMarketplaces/strictKnownMarketplaces/allow_remote_sessions/sandbox.network.allowManagedDomainsOnly, working directories with --add-dir, permission interaction with sandboxing, extending permissions with hooks), server-managed settings (admin console setup, requirements, settings delivery with fetch/caching behavior, security approval dialogs, access control roles, comparison with endpoint-managed settings, platform availability limitations, audit logging, security considerations), environment variables (complete reference of all ANTHROPIC_*, CLAUDE_CODE_*, and other env vars controlling API keys, model selection, provider configuration for Bedrock/Vertex/Foundry, shell behavior, telemetry, proxy, MCP, prompt caching, sandbox, auto-update, and more). Load when discussing Claude Code settings, settings.json, configuration, permissions, permission rules, allow/deny rules, permission modes, bypassPermissions, managed settings, server-managed settings, MDM, plist, registry, enterprise deployment, sandbox settings, env vars, environment variables, ANTHROPIC_API_KEY, ANTHROPIC_MODEL, CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, CLAUDE_CODE_USE_FOUNDRY, configuration scopes, settings precedence, /config, /status, /permissions, plugin settings, enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces, blockedMarketplaces, marketplace restrictions, hook configuration, attribution settings, worktree settings, file suggestion settings, additionalDirectories, defaultMode, disableBypassPermissionsMode, allowManagedPermissionRulesOnly, or configuring Claude Code behavior.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for configuring Claude Code -- settings files, permissions, server-managed settings, and environment variables.

## Quick Reference

Claude Code is configured through JSON settings files at multiple scopes, environment variables, and CLI flags. Use `/config` to open the settings UI and `/status` to verify active settings sources.

### Configuration Scopes

| Scope | Location | Who it affects | Shared with team? |
|:------|:---------|:---------------|:-------------------|
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | All users on machine | Yes (deployed by IT) |
| **User** | `~/.claude/settings.json` | You, across all projects | No |
| **Project** | `.claude/settings.json` | All collaborators | Yes (committed to git) |
| **Local** | `.claude/settings.local.json` | You, in this project only | No (gitignored) |

### Settings Precedence (highest to lowest)

1. **Managed** -- cannot be overridden by anything (within managed: server-managed > MDM/OS > `managed-settings.json`)
2. **CLI arguments** -- temporary session overrides
3. **Local project** (`.claude/settings.local.json`)
4. **Shared project** (`.claude/settings.json`)
5. **User** (`~/.claude/settings.json`)

Array settings (e.g., `permissions.allow`, `sandbox.filesystem.allowWrite`) merge across scopes (concatenated and deduplicated).

### Settings Files at Each Scope

| Feature | User | Project | Local |
|:--------|:-----|:--------|:------|
| Settings | `~/.claude/settings.json` | `.claude/settings.json` | `.claude/settings.local.json` |
| Subagents | `~/.claude/agents/` | `.claude/agents/` | -- |
| MCP servers | `~/.claude.json` | `.mcp.json` | `~/.claude.json` (per-project) |
| CLAUDE.md | `~/.claude/CLAUDE.md` | `CLAUDE.md` or `.claude/CLAUDE.md` | -- |

### Managed Settings Delivery

| Mechanism | Path / Location |
|:----------|:----------------|
| Server-managed | Claude.ai Admin > Claude Code > Managed settings |
| macOS plist | `com.anthropic.claudecode` managed preferences |
| Windows registry | `HKLM\SOFTWARE\Policies\ClaudeCode` (REG_SZ `Settings`) |
| macOS file | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux/WSL file | `/etc/claude-code/managed-settings.json` |
| Windows file | `C:\Program Files\ClaudeCode\managed-settings.json` |

### Available Settings (Key Fields)

| Key | Description |
|:----|:------------|
| `permissions` | Permission rules (`allow`, `ask`, `deny` arrays, `defaultMode`, `additionalDirectories`, `disableBypassPermissionsMode`) |
| `env` | Environment variables applied to every session |
| `model` | Override the default model |
| `availableModels` | Restrict models users can select |
| `modelOverrides` | Map Anthropic model IDs to provider-specific IDs |
| `effortLevel` | Persist effort level across sessions (`"low"`, `"medium"`, `"high"`) |
| `hooks` | Lifecycle hook definitions |
| `sandbox` | Sandbox configuration (filesystem, network controls) |
| `enabledPlugins` | Map of `"plugin@marketplace": true/false` |
| `extraKnownMarketplaces` | Pre-register marketplaces for team members |
| `strictKnownMarketplaces` | (Managed only) Allowlist of permitted marketplaces |
| `blockedMarketplaces` | (Managed only) Blocklist of marketplace sources |
| `attribution` | Customize git commit and PR attribution text |
| `apiKeyHelper` | Script to generate auth value for model requests |
| `statusLine` | Custom status line configuration |
| `fileSuggestion` | Custom `@` file autocomplete script |
| `language` | Preferred response language |
| `autoUpdatesChannel` | `"stable"` or `"latest"` release channel |
| `cleanupPeriodDays` | Session retention period (default: 30 days) |
| `companyAnnouncements` | Announcements shown at startup |
| `autoMemoryDirectory` | Custom auto memory storage path |
| `forceLoginMethod` | Restrict login to `claudeai` or `console` |
| `plansDirectory` | Custom path for plan files |
| `worktree.symlinkDirectories` | Directories to symlink into worktrees |
| `worktree.sparsePaths` | Sparse-checkout paths for worktrees |
| `disableAllHooks` | Disable all hooks and custom status line |
| `allowManagedHooksOnly` | (Managed only) Block user/project/plugin hooks |
| `allowedHttpHookUrls` | URL allowlist for HTTP hooks |
| `httpHookAllowedEnvVars` | Env var allowlist for HTTP hook headers |
| `includeGitInstructions` | Include built-in git workflow instructions (default: `true`) |
| `respectGitignore` | Whether `@` file picker respects `.gitignore` (default: `true`) |
| `outputStyle` | Adjust system prompt output style |
| `teammateMode` | Agent team display: `auto`, `in-process`, or `tmux` |
| `spinnerVerbs` | Customize spinner action verbs |
| `spinnerTipsEnabled` | Show tips in spinner (default: `true`) |
| `spinnerTipsOverride` | Custom spinner tip strings |
| `feedbackSurveyRate` | Session quality survey probability (0--1) |
| `fastModePerSessionOptIn` | Require per-session fast mode opt-in |
| `alwaysThinkingEnabled` | Enable extended thinking by default |
| `showTurnDuration` | Show turn duration messages |
| `prefersReducedMotion` | Reduce UI animations for accessibility |
| `terminalProgressBarEnabled` | Terminal progress bar (default: `true`) |

### Permission System

| Tool type | Example | Approval required | "Don't ask again" behavior |
|:----------|:--------|:------------------|:---------------------------|
| Read-only | File reads, Grep | No | N/A |
| Bash commands | Shell execution | Yes | Permanently per project+command |
| File modification | Edit/write | Yes | Until session end |

Rules are evaluated in order: **deny > ask > allow**. First matching rule wins.

### Permission Modes

| Mode | Description |
|:-----|:------------|
| `default` | Standard: prompts for permission on first use |
| `acceptEdits` | Auto-accepts file edit permissions for the session |
| `plan` | Claude can analyze but not modify files or run commands |
| `dontAsk` | Auto-denies tools unless pre-approved via `/permissions` or `allow` rules |
| `bypassPermissions` | Skips all permission prompts (isolated environments only) |

### Permission Rule Syntax

Format: `Tool` or `Tool(specifier)`. Quick examples:

| Rule | Effect |
|:-----|:-------|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run ` |
| `Bash(* --version)` | Matches commands ending with ` --version` |
| `Read(./.env)` | Matches reading `.env` in current directory |
| `Edit(/src/**/*.ts)` | Matches editing TypeScript files under project `src/` |
| `Read(//Users/alice/secrets/**)` | Absolute path match |
| `Read(~/Documents/*.pdf)` | Home-relative match |
| `WebFetch(domain:example.com)` | Matches fetch requests to example.com |
| `mcp__puppeteer__puppeteer_navigate` | Matches specific MCP tool |
| `mcp__puppeteer` | Matches all tools from puppeteer MCP server |
| `Agent(Explore)` | Matches the Explore subagent |

**Read/Edit path prefixes** (gitignore-style):

| Prefix | Meaning | Example |
|:-------|:--------|:--------|
| `//path` | Absolute from filesystem root | `Read(//Users/alice/secrets/**)` |
| `~/path` | Relative to home directory | `Read(~/Documents/*.pdf)` |
| `/path` | Relative to project root | `Edit(/src/**/*.ts)` |
| `path` or `./path` | Relative to current directory | `Read(*.env)` |

**Bash wildcard note:** `Bash(ls *)` (space before `*`) requires a word boundary, matching `ls -la` but not `lsof`. `Bash(ls*)` matches both.

### Managed-Only Settings

| Setting | Description |
|:--------|:------------|
| `disableBypassPermissionsMode` | Set to `"disable"` to prevent `bypassPermissions` mode |
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply |
| `allowManagedHooksOnly` | Only managed and SDK hooks allowed |
| `allowManagedMcpServersOnly` | Only managed `allowedMcpServers` respected |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `strictKnownMarketplaces` | Allowlist of permitted marketplaces |
| `sandbox.network.allowManagedDomainsOnly` | Only managed domain allowlists respected |
| `allow_remote_sessions` | Allow Remote Control and web sessions (default: `true`) |

### Sandbox Settings

| Key | Description |
|:----|:------------|
| `sandbox.enabled` | Enable bash sandboxing (default: `false`) |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: `true`) |
| `sandbox.excludedCommands` | Commands that run outside sandbox |
| `sandbox.allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch (default: `true`) |
| `sandbox.filesystem.allowWrite` | Additional writable paths (merged across scopes + Edit allow rules) |
| `sandbox.filesystem.denyWrite` | Blocked write paths (merged across scopes + Edit deny rules) |
| `sandbox.filesystem.denyRead` | Blocked read paths (merged across scopes + Read deny rules) |
| `sandbox.network.allowedDomains` | Allowed domains for outbound traffic (supports `*.example.com`) |
| `sandbox.network.allowManagedDomainsOnly` | (Managed only) Only managed domain lists respected |
| `sandbox.network.allowUnixSockets` | Allowed Unix socket paths |
| `sandbox.network.allowAllUnixSockets` | Allow all Unix sockets (default: `false`) |
| `sandbox.network.allowLocalBinding` | Allow binding to localhost (macOS only, default: `false`) |

**Sandbox path prefixes:** `//` = absolute, `~/` = home, `/` = relative to settings file directory, `./` or bare = relative.

### Server-Managed Settings

Server-managed settings deliver configuration from Anthropic's servers to Claude Code clients via the Claude.ai admin console. Requirements: Claude for Teams or Enterprise plan, Claude Code v2.1.38+ (Teams) or v2.1.30+ (Enterprise), and access to `api.anthropic.com`.

| Behavior | Details |
|:---------|:--------|
| Fetch timing | At startup + hourly polling |
| First launch (no cache) | Async fetch; brief unenforced window if fetch fails |
| Subsequent launches | Cached settings apply immediately; fresh fetch in background |
| Updates | Applied automatically without restart (except OTel config) |
| Precedence | Highest tier; overrides endpoint-managed settings when both present |
| Access control | Primary Owner and Owner roles |
| Platform | Requires direct `api.anthropic.com` access; not available with Bedrock, Vertex, Foundry, or custom base URLs |

**Security approval dialogs** are shown for: shell command settings, custom environment variables not on the safe allowlist, and hook configurations. In non-interactive mode (`-p` flag), dialogs are skipped.

**Current limitations:** settings apply uniformly to all users (no per-group configurations); MCP server configurations cannot be distributed via server-managed settings.

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key for Claude SDK |
| `ANTHROPIC_AUTH_TOKEN` | Auth token (takes precedence over API key) |
| `ANTHROPIC_MODEL` | Override model selection |
| `ANTHROPIC_SMALL_FAST_MODEL` | Override model for lightweight tasks |
| `ANTHROPIC_BASE_URL` | Custom API base URL |
| `CLAUDE_CODE_USE_BEDROCK` | Set to `1` to use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Set to `1` to use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Set to `1` to use Microsoft Foundry |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Set to `1` to disable auto memory |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable telemetry, update checks, tips |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry export |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Override max output tokens |
| `CLAUDE_CODE_SHELL` | Override shell for Bash tool |
| `CLAUDE_CODE_TMPDIR` | Override temporary directory |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude` config directory |
| `HTTP_PROXY` / `HTTPS_PROXY` | HTTP/HTTPS proxy URL |
| `NO_PROXY` | Comma-separated bypass list for proxies |
| `BASH_DEFAULT_TIMEOUT_MS` | Bash command timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Maximum bash timeout (default: 600000) |
| `BASH_MAX_OUTPUT_LENGTH` | Max characters retained from bash output |
| `MCP_TIMEOUT` | MCP server initialization timeout |
| `MCP_TOOL_TIMEOUT` | MCP tool execution timeout |
| `DISABLE_AUTOUPDATER` | Set to `1` to disable auto-updates |
| `DISABLE_PROMPT_CACHING` | Set to `1` to disable prompt caching |
| `SLASH_COMMAND_TOOL_CHAR_BUDGET` | Override skill description character budget |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level (`low`, `medium`, `high`) |
| `CLAUDE_CODE_PLAN_MODE_REQUIRED` | Force plan mode for all sessions |
| `MAX_THINKING_TOKENS` | Override max extended thinking tokens |

Environment variables can also be set via the `env` key in `settings.json` to apply to every session.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) -- configuration scopes (managed/user/project/local with when-to-use guidance), settings files (all JSON locations, managed delivery via server/MDM/plist/registry/file), complete available settings table (apiKeyHelper, autoMemoryDirectory, cleanupPeriodDays, companyAnnouncements, env, attribution, includeCoAuthoredBy, includeGitInstructions, permissions, hooks, disableAllHooks, allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars, allowManagedPermissionRulesOnly, allowManagedMcpServersOnly, model, availableModels, modelOverrides, effortLevel, otelHeadersHelper, statusLine, fileSuggestion, respectGitignore, outputStyle, forceLoginMethod, forceLoginOrgUUID, enableAllProjectMcpServers, enabledMcpjsonServers, disabledMcpjsonServers, allowedMcpServers, deniedMcpServers, strictKnownMarketplaces, blockedMarketplaces, pluginTrustMessage, awsAuthRefresh, awsCredentialExport, alwaysThinkingEnabled, plansDirectory, showTurnDuration, spinnerVerbs, language, autoUpdatesChannel, spinnerTipsEnabled, spinnerTipsOverride, terminalProgressBarEnabled, prefersReducedMotion, fastModePerSessionOptIn, teammateMode, feedbackSurveyRate), worktree settings (symlinkDirectories, sparsePaths), permission settings (allow/ask/deny arrays, additionalDirectories, defaultMode, disableBypassPermissionsMode), permission rule syntax, sandbox settings (enabled, autoAllowBashIfSandboxed, excludedCommands, filesystem paths, network domains/sockets/proxy, path prefixes), attribution settings (commit/PR customization), file suggestion settings, hook configuration (allowManagedHooksOnly, URL/env var restrictions), settings precedence (five-level hierarchy with array merging), /status verification, plugin configuration (enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces with all seven source types, blockedMarketplaces), subagent configuration, system prompt, excluding sensitive files
- [Configure permissions](references/claude-code-permissions.md) -- permission system (tool types, approval matrix), /permissions command, permission modes (default/acceptEdits/plan/dontAsk/bypassPermissions), permission rule syntax (Tool/Tool(specifier) format), wildcard patterns for Bash (word boundary behavior, shell operator awareness, URL pattern limitations), Read/Edit rules (gitignore-style with //absolute/~/home/relative/project-root prefixes, * vs ** globbing), WebFetch domain rules, MCP tool rules (server-level and tool-level), Agent subagent rules, extending permissions with hooks (PreToolUse), working directories (--add-dir, /add-dir, additionalDirectories), permissions and sandboxing interaction (defense-in-depth, filesystem/network restriction merging), managed-only settings table (disableBypassPermissionsMode, allowManagedPermissionRulesOnly, allowManagedHooksOnly, allowManagedMcpServersOnly, blockedMarketplaces, strictKnownMarketplaces, sandbox.network.allowManagedDomainsOnly, allow_remote_sessions), settings precedence for permissions, example configurations
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) -- requirements (plan tier, version, network), server-managed vs endpoint-managed comparison, admin console setup (define JSON, save/deploy), verify settings delivery, access control (Primary Owner, Owner), current limitations (no per-group, no MCP servers), settings delivery (precedence over endpoint-managed, fetch/caching behavior for first launch and subsequent launches), security approval dialogs (shell commands, custom env vars, hooks, non-interactive -p flag behavior), platform availability (not available with Bedrock/Vertex/Foundry/custom base URLs), audit logging, security considerations (tampered cache, deleted cache, API unavailable, different org, non-default base URL), ConfigChange hooks
- [Environment variables reference](references/claude-code-env-vars.md) -- complete table of all environment variables: authentication (ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_CUSTOM_HEADERS), model selection (ANTHROPIC_MODEL, ANTHROPIC_SMALL_FAST_MODEL, ANTHROPIC_DEFAULT_*_MODEL), provider configuration (CLAUDE_CODE_USE_BEDROCK/VERTEX/FOUNDRY, ANTHROPIC_FOUNDRY_*, AWS_BEARER_TOKEN_BEDROCK, VERTEX_REGION_*), shell and execution (CLAUDE_CODE_SHELL, CLAUDE_CODE_SHELL_PREFIX, BASH_DEFAULT_TIMEOUT_MS, BASH_MAX_TIMEOUT_MS, BASH_MAX_OUTPUT_LENGTH), output (CLAUDE_CODE_MAX_OUTPUT_TOKENS, CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS, MAX_THINKING_TOKENS), memory and context (CLAUDE_CODE_DISABLE_AUTO_MEMORY, CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD, CLAUDE_AUTOCOMPACT_PCT_OVERRIDE, CLAUDE_CODE_AUTO_COMPACT_WINDOW), telemetry (CLAUDE_CODE_ENABLE_TELEMETRY, DISABLE_TELEMETRY, DISABLE_ERROR_REPORTING, CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC), proxy (HTTP_PROXY, HTTPS_PROXY, NO_PROXY, CLAUDE_CODE_PROXY_RESOLVES_HOSTS), MCP (MCP_TIMEOUT, MCP_TOOL_TIMEOUT, MAX_MCP_OUTPUT_TOKENS, MCP_CLIENT_SECRET, MCP_OAUTH_CALLBACK_PORT, ENABLE_CLAUDEAI_MCP_SERVERS), updates (DISABLE_AUTOUPDATER, FORCE_AUTOUPDATE_PLUGINS, CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS), caching (DISABLE_PROMPT_CACHING, DISABLE_PROMPT_CACHING_HAIKU/OPUS/SONNET), features (CLAUDE_CODE_DISABLE_FAST_MODE, CLAUDE_CODE_EFFORT_LEVEL, CLAUDE_CODE_PLAN_MODE_REQUIRED, CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION, CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS, SLASH_COMMAND_TOOL_CHAR_BUDGET), configuration paths (CLAUDE_CONFIG_DIR, CLAUDE_ENV_FILE, CLAUDE_CODE_TMPDIR), identity (CLAUDE_CODE_ACCOUNT_UUID, CLAUDE_CODE_ORGANIZATION_UUID, CLAUDE_CODE_USER_EMAIL, CLAUDE_CODE_TEAM_NAME, CLAUDE_CODE_TASK_LIST_ID)

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables reference: https://code.claude.com/docs/en/env-vars.md
