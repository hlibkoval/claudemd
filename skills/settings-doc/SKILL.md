---
name: settings-doc
description: Complete documentation for Claude Code settings, permissions, environment variables, and server-managed settings -- configuration scopes (managed/user/project/local with precedence rules), settings files (settings.json locations, managed-settings.json, MDM/OS-level policies, plist, registry, ~/.claude.json), available settings (apiKeyHelper, autoMemoryDirectory, cleanupPeriodDays, companyAnnouncements, env, attribution, includeCoAuthoredBy, includeGitInstructions, permissions, hooks, disableAllHooks, allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars, allowManagedPermissionRulesOnly, allowManagedMcpServersOnly, model, availableModels, modelOverrides, effortLevel, otelHeadersHelper, statusLine, fileSuggestion, respectGitignore, outputStyle, agent, forceLoginMethod, forceLoginOrgUUID, enableAllProjectMcpServers, enabledMcpjsonServers, disabledMcpjsonServers, allowedMcpServers, deniedMcpServers, strictKnownMarketplaces, blockedMarketplaces, pluginTrustMessage, awsAuthRefresh, awsCredentialExport, alwaysThinkingEnabled, plansDirectory, spinnerVerbs, language, voiceEnabled, autoUpdatesChannel, spinnerTipsEnabled, spinnerTipsOverride, prefersReducedMotion, fastModePerSessionOptIn, teammateMode, feedbackSurveyRate), global config settings (showTurnDuration, terminalProgressBarEnabled), worktree settings (worktree.symlinkDirectories, worktree.sparsePaths), permission settings (allow, ask, deny, additionalDirectories, defaultMode, disableBypassPermissionsMode), permission rule syntax (Tool/Tool(specifier), wildcards, deny>ask>allow evaluation), sandbox settings (enabled, autoAllowBashIfSandboxed, excludedCommands, allowUnsandboxedCommands, filesystem.allowWrite/denyWrite/denyRead/allowRead/allowManagedReadPathsOnly, network.allowUnixSockets/allowAllUnixSockets/allowLocalBinding/allowedDomains/allowManagedDomainsOnly/httpProxyPort/socksProxyPort, enableWeakerNestedSandbox, enableWeakerNetworkIsolation, path prefixes //~/./), attribution settings (commit, pr), file suggestion settings (custom command for @ autocomplete), hook configuration (allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars), settings precedence (managed>CLI>local>project>user, array merging), verify active settings (/status), plugin settings (enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces marketplace source types github/git/url/npm/file/directory/hostPattern, blockedMarketplaces), subagent configuration, system prompt, excluding sensitive files, permission system (tool types read-only/bash/file-modification, /permissions command), permission modes (default, acceptEdits, plan, dontAsk, bypassPermissions), tool-specific permission rules (Bash wildcards/word-boundary/compound-commands/security-limitations, Read/Edit gitignore-spec patterns with //~/./path prefixes, WebFetch domain rules, MCP server/tool rules, Agent subagent rules), extend permissions with hooks (PreToolUse allow/deny/ask), working directories (--add-dir, /add-dir, additionalDirectories), permissions and sandboxing interaction (defense-in-depth, Read/Edit deny vs Bash subprocess, filesystem/network restrictions), managed-only settings (disableBypassPermissionsMode, allowManagedPermissionRulesOnly, allowManagedHooksOnly, allowManagedMcpServersOnly, blockedMarketplaces, sandbox.network.allowManagedDomainsOnly, sandbox.filesystem.allowManagedReadPathsOnly, strictKnownMarketplaces, allow_remote_sessions), settings precedence for permissions, server-managed settings (public beta, Teams/Enterprise, admin console configuration, settings delivery and caching, security approval dialogs, access control roles, platform availability, audit logging, security considerations, ConfigChange hooks), environment variables (ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_BASE_URL, ANTHROPIC_MODEL, ANTHROPIC_SMALL_FAST_MODEL, CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, CLAUDE_CODE_USE_FOUNDRY, CLAUDE_CODE_ENABLE_TELEMETRY, BASH_DEFAULT_TIMEOUT_MS, BASH_MAX_TIMEOUT_MS, BASH_MAX_OUTPUT_LENGTH, MCP_TIMEOUT, MCP_TOOL_TIMEOUT, MAX_THINKING_TOKENS, CLAUDE_CODE_MAX_OUTPUT_TOKENS, HTTP_PROXY, HTTPS_PROXY, NO_PROXY, DISABLE_AUTOUPDATER, DISABLE_TELEMETRY, CLAUDE_CODE_DISABLE_AUTO_MEMORY, CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS, CLAUDE_CODE_SHELL, CLAUDE_CONFIG_DIR, and 60+ more). Load when discussing Claude Code settings, settings.json, configuration, permissions, allow/deny/ask rules, permission modes, bypassPermissions, acceptEdits, dontAsk, plan mode, permission rule syntax, managed settings, managed-settings.json, MDM policies, plist, registry, server-managed settings, sandbox settings, sandbox configuration, filesystem sandbox, network sandbox, allowedDomains, allowWrite, denyRead, environment variables, ANTHROPIC_API_KEY, ANTHROPIC_MODEL, ANTHROPIC_BASE_URL, CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, HTTP_PROXY, env vars, plugin settings, enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces, blockedMarketplaces, marketplace restrictions, settings precedence, configuration scopes, /config command, /permissions command, /status command, attribution settings, worktree settings, file suggestion, hook configuration, allowManagedHooksOnly, subagent configuration, working directories, additionalDirectories, tool permissions, Read Edit Bash WebFetch MCP Agent permission rules, settings files, settings locations, security approval dialogs, or any Claude Code configuration topic.
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, environment variables, and server-managed settings.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared? |
|:------|:---------|:---------------|:--------|
| Managed | Server-managed, plist/registry, or `managed-settings.json` | All users on the machine | Yes (deployed by IT) |
| User | `~/.claude/settings.json` | You, across all projects | No |
| Project | `.claude/settings.json` | All collaborators on this repository | Yes (committed to git) |
| Local | `.claude/settings.local.json` | You, in this repository only | No (gitignored) |

**Precedence (highest to lowest):** Managed > CLI arguments > Local > Project > User

Array-valued settings (like `permissions.allow`, `sandbox.filesystem.allowWrite`) merge across scopes (concatenated and deduplicated), not replaced.

### Settings Files

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings (all projects) |
| `.claude/settings.json` | Project settings (shared with team) |
| `.claude/settings.local.json` | Local project settings (gitignored) |
| `~/.claude.json` | Preferences, OAuth, MCP servers (user/local), per-project state |
| `.mcp.json` | Project-scoped MCP servers |

**Managed settings delivery:**

| Mechanism | Location |
|:----------|:---------|
| Server-managed | Delivered from Anthropic servers via Claude.ai admin console |
| macOS MDM | `com.anthropic.claudecode` managed preferences domain |
| Windows registry | `HKLM\SOFTWARE\Policies\ClaudeCode` (admin) or `HKCU\...` (user) |
| macOS file | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux/WSL file | `/etc/claude-code/managed-settings.json` |
| Windows file | `C:\Program Files\ClaudeCode\managed-settings.json` |

Within managed tier: server-managed > MDM/OS-level > `managed-settings.json` > HKCU registry. Only one managed source is used; they do not merge.

### Available Settings (settings.json)

| Key | Description |
|:----|:------------|
| `apiKeyHelper` | Script to generate auth value (sent as X-Api-Key and Bearer) |
| `autoMemoryDirectory` | Custom auto memory storage path (not allowed in project settings) |
| `cleanupPeriodDays` | Session cleanup threshold in days (default: 30; 0 = disable persistence) |
| `companyAnnouncements` | Startup announcements array (cycled randomly) |
| `env` | Environment variables applied to every session |
| `attribution` | Customize git commit and PR attribution (`commit`, `pr` keys) |
| `includeGitInstructions` | Include built-in git workflow instructions in system prompt (default: true) |
| `permissions` | Permission rules (`allow`, `ask`, `deny` arrays, `defaultMode`, etc.) |
| `hooks` | Custom commands at lifecycle events |
| `disableAllHooks` | Disable all hooks and custom status line |
| `model` | Override default model |
| `availableModels` | Restrict model selection via `/model`, `--model`, Config |
| `modelOverrides` | Map Anthropic model IDs to provider-specific IDs |
| `effortLevel` | Persist effort level: `"low"`, `"medium"`, `"high"` |
| `statusLine` | Custom status line configuration |
| `fileSuggestion` | Custom `@` file autocomplete command |
| `respectGitignore` | Whether `@` file picker respects .gitignore (default: true) |
| `outputStyle` | Output style to adjust system prompt |
| `agent` | Run main thread as a named subagent |
| `forceLoginMethod` | Restrict login to `claudeai` or `console` |
| `forceLoginOrgUUID` | Auto-select organization during login |
| `enableAllProjectMcpServers` | Auto-approve all project MCP servers |
| `enabledMcpjsonServers` | Allowlist specific MCP servers from `.mcp.json` |
| `disabledMcpjsonServers` | Denylist specific MCP servers from `.mcp.json` |
| `language` | Preferred response language (also sets voice dictation language) |
| `voiceEnabled` | Enable push-to-talk voice dictation |
| `autoUpdatesChannel` | `"stable"` (one-week-old, regression-skipping) or `"latest"` (default) |
| `spinnerVerbs` | Custom spinner action verbs (`mode`: `"replace"` or `"append"`) |
| `spinnerTipsEnabled` | Show tips while working (default: true) |
| `spinnerTipsOverride` | Custom spinner tips (`tips` array, `excludeDefault` flag) |
| `prefersReducedMotion` | Reduce UI animations for accessibility |
| `plansDirectory` | Plan file storage directory (default: `~/.claude/plans`) |
| `alwaysThinkingEnabled` | Enable extended thinking by default |
| `fastModePerSessionOptIn` | Require per-session fast mode opt-in |
| `teammateMode` | Agent team display: `auto`, `in-process`, or `tmux` |
| `feedbackSurveyRate` | Session quality survey probability (0-1; 0 = suppress) |

**Global config settings** (stored in `~/.claude.json`, not `settings.json`):

| Key | Description |
|:----|:------------|
| `showTurnDuration` | Show turn duration messages (default: true) |
| `terminalProgressBarEnabled` | Show terminal progress bar (default: true) |

### Worktree Settings

| Key | Description |
|:----|:------------|
| `worktree.symlinkDirectories` | Directories to symlink into worktrees (avoids duplicating large dirs) |
| `worktree.sparsePaths` | Directories to check out via sparse-checkout (cone mode) |

### Permission Settings

| Key | Description |
|:----|:------------|
| `permissions.allow` | Rules to allow tool use without prompting |
| `permissions.ask` | Rules to always prompt for confirmation |
| `permissions.deny` | Rules to block tool use entirely |
| `permissions.additionalDirectories` | Extra working directories Claude can access |
| `permissions.defaultMode` | Default permission mode |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to prevent bypass mode |

### Permission Modes

| Mode | Description |
|:-----|:------------|
| `default` | Prompts for permission on first use of each tool |
| `acceptEdits` | Auto-accepts file edit permissions for the session |
| `plan` | Plan Mode: analyze but not modify files or execute commands |
| `dontAsk` | Auto-denies tools unless pre-approved via `/permissions` or `permissions.allow` |
| `bypassPermissions` | Skips all permission prompts (isolated environments only) |

### Permission Rule Syntax

Rules follow the format `Tool` or `Tool(specifier)`. Evaluation order: **deny > ask > allow** (first match wins).

| Rule Pattern | Effect |
|:-------------|:-------|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run ` |
| `Bash(npm run build)` | Matches exact command `npm run build` |
| `Read(./.env)` | Matches reading `.env` in current directory |
| `Edit(/src/**/*.ts)` | Matches editing TypeScript files under project `src/` |
| `WebFetch(domain:example.com)` | Matches fetch requests to example.com |
| `mcp__puppeteer__puppeteer_navigate` | Matches specific MCP tool |
| `mcp__puppeteer` | Matches all tools from the puppeteer MCP server |
| `Agent(Explore)` | Matches the Explore subagent |

**Bash wildcard note:** `Bash(ls *)` (space before `*`) matches `ls -la` but not `lsof`; `Bash(ls*)` (no space) matches both.

**Read/Edit path prefixes:**

| Prefix | Meaning | Example |
|:-------|:--------|:--------|
| `//path` | Absolute from filesystem root | `Read(//Users/alice/secrets/**)` |
| `~/path` | From home directory | `Read(~/Documents/*.pdf)` |
| `/path` | Relative to project root | `Edit(/src/**/*.ts)` |
| `path` or `./path` | Relative to current directory | `Read(*.env)` |

Read/Edit rules follow the gitignore specification. `*` matches files in a single directory; `**` matches recursively.

### Sandbox Settings

| Key | Description |
|:----|:------------|
| `sandbox.enabled` | Enable bash sandboxing (macOS, Linux, WSL2; default: false) |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `sandbox.excludedCommands` | Commands that run outside the sandbox |
| `sandbox.allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` parameter (default: true) |
| `sandbox.filesystem.allowWrite` | Additional writable paths (arrays merge across scopes) |
| `sandbox.filesystem.denyWrite` | Paths where writing is blocked |
| `sandbox.filesystem.denyRead` | Paths where reading is blocked |
| `sandbox.filesystem.allowRead` | Re-allow reading within `denyRead` regions (takes precedence) |
| `sandbox.network.allowedDomains` | Domains allowed for outbound traffic (supports wildcards) |
| `sandbox.network.allowUnixSockets` | Unix socket paths accessible in sandbox |
| `sandbox.network.allowLocalBinding` | Allow binding to localhost ports (macOS only; default: false) |
| `sandbox.network.httpProxyPort` | HTTP proxy port (bring your own proxy) |
| `sandbox.network.socksProxyPort` | SOCKS5 proxy port (bring your own proxy) |
| `sandbox.enableWeakerNestedSandbox` | Weaker sandbox for unprivileged Docker (Linux/WSL2; reduces security) |
| `sandbox.enableWeakerNetworkIsolation` | Allow TLS trust service in sandbox (macOS; reduces security) |

**Sandbox path prefixes:** `//` = absolute, `~/` = home, `/` = relative to settings file dir, `./` or no prefix = relative path.

### Managed-Only Settings

These settings are only effective in managed settings (cannot be set by users):

| Setting | Description |
|:--------|:------------|
| `disableBypassPermissionsMode` | Prevent `bypassPermissions` mode and `--dangerously-skip-permissions` |
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply |
| `allowManagedHooksOnly` | Only managed and SDK hooks are loaded |
| `allowManagedMcpServersOnly` | Only managed MCP server allowlist applies |
| `blockedMarketplaces` | Blocklist of marketplace sources (checked before download) |
| `sandbox.network.allowManagedDomainsOnly` | Only managed `allowedDomains` and `WebFetch` allow rules apply |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed `allowRead` paths apply |
| `strictKnownMarketplaces` | Allowlist of plugin marketplaces users can add |
| `allow_remote_sessions` | Allow Remote Control and web sessions (default: true) |

### Plugin Settings

| Key | Description |
|:----|:------------|
| `enabledPlugins` | Map of `"plugin@marketplace": true/false` |
| `extraKnownMarketplaces` | Auto-install marketplaces for team (named marketplace with nested source) |
| `strictKnownMarketplaces` | Managed-only allowlist for marketplace additions (direct source objects) |
| `blockedMarketplaces` | Managed-only blocklist of marketplace sources |
| `pluginTrustMessage` | Managed-only custom message appended to plugin trust warning |

Marketplace source types: `github` (repo), `git` (url), `url` (url), `npm` (package), `file` (path), `directory` (path), `hostPattern` (regex).

### Server-Managed Settings

Server-managed settings deliver configuration from Anthropic's servers via the Claude.ai admin console. Available for Teams and Enterprise plans.

| Aspect | Detail |
|:-------|:-------|
| Requirements | Teams/Enterprise plan, Claude Code v2.1.38+ (Teams) or v2.1.30+ (Enterprise), network access to `api.anthropic.com` |
| Precedence | Highest tier (ties with endpoint-managed); server-managed wins if both present |
| Fetch behavior | Fetched at startup, polled hourly; cached settings apply immediately on subsequent launches |
| Access control | Primary Owner and Owner roles only |
| Security dialogs | Shell commands, custom env vars, and hook configs require user approval (skipped in `-p` mode) |
| Platform availability | Not available with Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL` |
| Limitations (beta) | Settings apply uniformly to all users; MCP server configs cannot be distributed |

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key (overrides subscription when set) |
| `ANTHROPIC_AUTH_TOKEN` | Raw Authorization header value |
| `ANTHROPIC_BASE_URL` | Custom API endpoint URL |
| `ANTHROPIC_MODEL` | Override default model |
| `ANTHROPIC_SMALL_FAST_MODEL` | Override model for background tasks |
| `CLAUDE_CODE_USE_BEDROCK` | Set to `1` to use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Set to `1` to use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Set to `1` to use Microsoft Foundry |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Maximum bash command timeout (default: 600000) |
| `BASH_MAX_OUTPUT_LENGTH` | Max bash output characters |
| `MCP_TIMEOUT` | MCP server startup timeout |
| `MCP_TOOL_TIMEOUT` | MCP tool execution timeout |
| `MAX_THINKING_TOKENS` | Maximum extended thinking tokens |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Maximum output tokens per response |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server URLs |
| `NO_PROXY` | Proxy bypass patterns |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry export |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory updates |
| `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` | Remove git workflow instructions from system prompt |
| `CLAUDE_CODE_SHELL` | Override shell for bash commands |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude` config directory |
| `DISABLE_AUTOUPDATER` | Disable auto-updates |
| `DISABLE_TELEMETRY` | Disable telemetry |
| `SLASH_COMMAND_TOOL_CHAR_BUDGET` | Override skill description character budget |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable non-essential network traffic |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level (`low`, `medium`, `high`) |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Override auto-compaction threshold percentage |
| `CLAUDE_CODE_PLAN_MODE_REQUIRED` | Force plan mode for all sessions |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Enable agent teams feature |

Plus 50+ additional variables for authentication, model configuration, provider-specific settings, MCP, IDE integration, and internal behavior tuning. See the full environment variables reference for details.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) -- configuration scopes (managed/user/project/local, when to use each, how they interact, precedence), settings files (settings.json at user/project/local paths, managed-settings.json with MDM/plist/registry/file delivery, ~/.claude.json preferences, .mcp.json, JSON schema), complete available settings table (apiKeyHelper, autoMemoryDirectory, cleanupPeriodDays, companyAnnouncements, env, attribution, includeCoAuthoredBy, includeGitInstructions, permissions, hooks, disableAllHooks, allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars, allowManagedPermissionRulesOnly, allowManagedMcpServersOnly, model, availableModels, modelOverrides, effortLevel, otelHeadersHelper, statusLine, fileSuggestion, respectGitignore, outputStyle, agent, forceLoginMethod, forceLoginOrgUUID, enableAllProjectMcpServers, enabledMcpjsonServers, disabledMcpjsonServers, allowedMcpServers, deniedMcpServers, strictKnownMarketplaces, blockedMarketplaces, pluginTrustMessage, awsAuthRefresh, awsCredentialExport, alwaysThinkingEnabled, plansDirectory, spinnerVerbs, language, voiceEnabled, autoUpdatesChannel, spinnerTipsEnabled, spinnerTipsOverride, prefersReducedMotion, fastModePerSessionOptIn, teammateMode, feedbackSurveyRate), global config settings (showTurnDuration, terminalProgressBarEnabled), worktree settings (symlinkDirectories, sparsePaths), permission settings (allow/ask/deny arrays, additionalDirectories, defaultMode, disableBypassPermissionsMode), permission rule syntax (Tool/Tool(specifier) format, examples), sandbox settings (enabled, autoAllowBashIfSandboxed, excludedCommands, allowUnsandboxedCommands, filesystem allowWrite/denyWrite/denyRead/allowRead/allowManagedReadPathsOnly, network allowUnixSockets/allowAllUnixSockets/allowLocalBinding/allowedDomains/allowManagedDomainsOnly/httpProxyPort/socksProxyPort, enableWeakerNestedSandbox, enableWeakerNetworkIsolation, path prefixes), attribution settings (commit/pr keys, git trailers, defaults), file suggestion settings (custom command, stdin JSON protocol, stdout format), hook configuration (allowManagedHooksOnly, URL restrictions, env var restrictions), settings precedence (managed>CLI>local>project>user with array merging), verify settings with /status, plugin configuration (enabledPlugins, extraKnownMarketplaces with source types, strictKnownMarketplaces with seven source types and exact matching, blockedMarketplaces, comparison table), subagent configuration, system prompt, excluding sensitive files
- [Configure permissions](references/claude-code-permissions.md) -- permission system (tool types read-only/bash/file-modification with approval rules), /permissions command (allow/ask/deny rule management), permission modes (default/acceptEdits/plan/dontAsk/bypassPermissions with descriptions and warnings), permission rule syntax (Tool/Tool(specifier) format, match all uses, specifiers for fine-grained control), wildcard patterns (Bash glob with * at any position, word boundary with space before *, compound command handling with per-subcommand rules), tool-specific rules (Bash wildcards with security limitations for URL-constraining patterns, Read/Edit with gitignore-spec patterns and four path prefix types //~/./path, WebFetch domain rules, MCP server/tool patterns, Agent subagent rules), extend permissions with hooks (PreToolUse, allow does not bypass deny rules), working directories (--add-dir, /add-dir, additionalDirectories), permissions and sandboxing interaction (complementary layers, defense-in-depth, Read/Edit deny vs Bash subprocess distinction), managed settings (managed-only settings table: disableBypassPermissionsMode/allowManagedPermissionRulesOnly/allowManagedHooksOnly/allowManagedMcpServersOnly/blockedMarketplaces/sandbox.network.allowManagedDomainsOnly/sandbox.filesystem.allowManagedReadPathsOnly/strictKnownMarketplaces/allow_remote_sessions), settings precedence for permissions, example configurations link
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) -- public beta for Teams/Enterprise, requirements (plan, version, network), server-managed vs endpoint-managed comparison, admin console configuration steps (open console, define JSON settings, save and deploy), verify settings delivery (/permissions), access control (Primary Owner, Owner roles), current limitations (uniform settings, no MCP server configs), settings delivery (precedence, fetch and caching behavior for first/subsequent launches, settings updates without restart), security approval dialogs (shell commands, custom env vars, hooks; non-interactive -p flag skips), platform availability (not available with Bedrock/Vertex/Foundry/custom base URL), audit logging (compliance API), security considerations (client-side control, cached file tampering, API unavailability, different organization, non-default base URL, ConfigChange hooks for detection)
- [Environment variables](references/claude-code-env-vars.md) -- complete reference table of 90+ environment variables covering authentication (ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_FOUNDRY_API_KEY, AWS_BEARER_TOKEN_BEDROCK), API configuration (ANTHROPIC_BASE_URL, ANTHROPIC_CUSTOM_HEADERS, ANTHROPIC_FOUNDRY_BASE_URL, ANTHROPIC_FOUNDRY_RESOURCE), model selection (ANTHROPIC_MODEL, ANTHROPIC_SMALL_FAST_MODEL, ANTHROPIC_DEFAULT_SONNET_MODEL, ANTHROPIC_DEFAULT_OPUS_MODEL, ANTHROPIC_DEFAULT_HAIKU_MODEL, CLAUDE_CODE_SUBAGENT_MODEL), provider flags (CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, CLAUDE_CODE_USE_FOUNDRY, CLAUDE_CODE_SKIP_BEDROCK_AUTH, CLAUDE_CODE_SKIP_VERTEX_AUTH, CLAUDE_CODE_SKIP_FOUNDRY_AUTH), bash behavior (BASH_DEFAULT_TIMEOUT_MS, BASH_MAX_TIMEOUT_MS, BASH_MAX_OUTPUT_LENGTH, CLAUDE_CODE_SHELL, CLAUDE_CODE_SHELL_PREFIX, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR), output and tokens (CLAUDE_CODE_MAX_OUTPUT_TOKENS, CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS, MAX_THINKING_TOKENS, MAX_MCP_OUTPUT_TOKENS), MCP (MCP_TIMEOUT, MCP_TOOL_TIMEOUT, MCP_CLIENT_SECRET, MCP_OAUTH_CALLBACK_PORT, ENABLE_CLAUDEAI_MCP_SERVERS), proxy and network (HTTP_PROXY, HTTPS_PROXY, NO_PROXY, CLAUDE_CODE_PROXY_RESOLVES_HOSTS, CLAUDE_CODE_CLIENT_CERT, CLAUDE_CODE_CLIENT_KEY, CLAUDE_CODE_CLIENT_KEY_PASSPHRASE), telemetry (CLAUDE_CODE_ENABLE_TELEMETRY, DISABLE_TELEMETRY, DISABLE_ERROR_REPORTING, CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS), feature flags and disablers (DISABLE_AUTOUPDATER, DISABLE_PROMPT_CACHING, CLAUDE_CODE_DISABLE_AUTO_MEMORY, CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS, CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC, CLAUDE_CODE_DISABLE_BACKGROUND_TASKS, CLAUDE_CODE_DISABLE_CRON, CLAUDE_CODE_DISABLE_TERMINAL_TITLE, CLAUDE_CODE_DISABLE_FAST_MODE, CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY, CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING, CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS), session and identity (CLAUDE_CODE_ACCOUNT_UUID, CLAUDE_CODE_ORGANIZATION_UUID, CLAUDE_CODE_USER_EMAIL, CLAUDE_CODE_TEAM_NAME, CLAUDE_CODE_TASK_LIST_ID), paths and directories (CLAUDE_CONFIG_DIR, CLAUDE_CODE_TMPDIR, CLAUDE_ENV_FILE, CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD), compaction (CLAUDE_AUTOCOMPACT_PCT_OVERRIDE, CLAUDE_CODE_AUTO_COMPACT_WINDOW), misc (CLAUDECODE sentinel, SLASH_COMMAND_TOOL_CHAR_BUDGET, CLAUDE_CODE_EFFORT_LEVEL, CLAUDE_CODE_PLAN_MODE_REQUIRED, CLAUDE_CODE_SIMPLE, CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION, CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS, ENABLE_TOOL_SEARCH, USE_BUILTIN_RIPGREP, IS_DEMO, FORCE_AUTOUPDATE_PLUGINS, CLAUDE_CODE_NEW_INIT, CLAUDE_CODE_EXIT_AFTER_STOP_DELAY, CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS, CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS, CLAUDE_CODE_PLUGIN_SEED_DIR, CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL, CLAUDE_CODE_SKIP_FAST_MODE_NETWORK_ERRORS, DISABLE_BUG_COMMAND, DISABLE_COST_WARNINGS, DISABLE_INSTALLATION_CHECKS)

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
