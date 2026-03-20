---
name: settings-doc
description: Complete documentation for Claude Code settings, permissions, environment variables, and server-managed settings -- configuration scopes (managed/user/project/local, precedence hierarchy, settings.json locations, managed-settings.json delivery via MDM/plist/registry/file/server), available settings (apiKeyHelper, autoMemoryDirectory, cleanupPeriodDays, companyAnnouncements, env, attribution, includeGitInstructions, permissions, hooks, disableAllHooks, allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars, allowManagedPermissionRulesOnly, allowManagedMcpServersOnly, model, availableModels, modelOverrides, effortLevel, otelHeadersHelper, statusLine, fileSuggestion, respectGitignore, outputStyle, agent, forceLoginMethod, forceLoginOrgUUID, enableAllProjectMcpServers, enabledMcpjsonServers, disabledMcpjsonServers, channelsEnabled, allowedMcpServers, deniedMcpServers, strictKnownMarketplaces, blockedMarketplaces, pluginTrustMessage, awsAuthRefresh, awsCredentialExport, alwaysThinkingEnabled, plansDirectory, spinnerVerbs, language, voiceEnabled, autoUpdatesChannel, spinnerTipsEnabled, spinnerTipsOverride, prefersReducedMotion, fastModePerSessionOptIn, teammateMode, feedbackSurveyRate), global config settings (showTurnDuration, terminalProgressBarEnabled), worktree settings (symlinkDirectories, sparsePaths), permission settings (allow/ask/deny arrays, additionalDirectories, defaultMode, disableBypassPermissionsMode), permission rule syntax (Tool and Tool(specifier) format, wildcards, Bash/Read/Edit/WebFetch/MCP/Agent patterns), permission modes (default, acceptEdits, plan, dontAsk, bypassPermissions), managed-only settings (disableBypassPermissionsMode, allowManagedPermissionRulesOnly, allowManagedHooksOnly, allowManagedMcpServersOnly, blockedMarketplaces, sandbox.network.allowManagedDomainsOnly, sandbox.filesystem.allowManagedReadPathsOnly, strictKnownMarketplaces, allow_remote_sessions), sandbox settings (enabled, autoAllowBashIfSandboxed, excludedCommands, allowUnsandboxedCommands, filesystem.allowWrite/denyWrite/denyRead/allowRead/allowManagedReadPathsOnly, network.allowUnixSockets/allowAllUnixSockets/allowLocalBinding/allowedDomains/allowManagedDomainsOnly/httpProxyPort/socksProxyPort, enableWeakerNestedSandbox, enableWeakerNetworkIsolation), attribution settings (commit/pr), file suggestion settings (custom command for @ autocomplete), hook configuration (allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars), plugin configuration (enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces, blockedMarketplaces), server-managed settings (admin console on Claude.ai, requirements, fetch/caching behavior, security approval dialogs, access control, limitations, precedence, platform availability, audit logging, security considerations), environment variables (ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_BASE_URL, ANTHROPIC_MODEL, CLAUDE_CODE_USE_BEDROCK/VERTEX/FOUNDRY, proxy/mTLS vars, DISABLE_TELEMETRY, DISABLE_ERROR_REPORTING, sandbox/bash/MCP timeout vars, model override vars, feature toggle vars). Load when discussing Claude Code settings, configuration, settings.json, managed-settings.json, permissions, permission rules, allow/deny/ask rules, permission modes, bypassPermissions, environment variables, env vars, configuration scopes, settings precedence, server-managed settings, MDM policies, sandbox settings, worktree settings, attribution settings, plugin settings, marketplace restrictions, hook configuration, file suggestion, apiKeyHelper, defaultMode, or any settings.json key.
user-invocable: false
---

# Settings, Permissions & Environment Variables Documentation

This skill provides the complete official documentation for configuring Claude Code through settings files, permissions, environment variables, and server-managed settings.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared? |
|:------|:---------|:---------------|:--------|
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | All users on the machine | Yes (deployed by IT) |
| **User** | `~/.claude/settings.json` | You, across all projects | No |
| **Project** | `.claude/settings.json` | All collaborators | Yes (committed to git) |
| **Local** | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |

**Managed settings file locations:**

| Platform | Path |
|:---------|:-----|
| macOS | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux/WSL | `/etc/claude-code/managed-settings.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-settings.json` |

**MDM/OS-level policy locations:**

| Platform | Mechanism |
|:---------|:----------|
| macOS | `com.anthropic.claudecode` managed preferences domain |
| Windows (admin) | `HKLM\SOFTWARE\Policies\ClaudeCode` registry key with `Settings` REG_SZ containing JSON |
| Windows (user) | `HKCU\SOFTWARE\Policies\ClaudeCode` (lowest policy priority) |

### Settings Precedence (highest to lowest)

1. **Managed** (server-managed > MDM/OS-level > `managed-settings.json` > HKCU; only one source used, no merging)
2. **Command line arguments**
3. **Local project** (`.claude/settings.local.json`)
4. **Shared project** (`.claude/settings.json`)
5. **User** (`~/.claude/settings.json`)

Array-valued settings (e.g., `permissions.allow`, `sandbox.filesystem.allowWrite`) are **concatenated and deduplicated** across scopes, not replaced.

Use `/status` to see active settings sources and `/config` to open the settings UI.

### Available Settings (settings.json)

| Key | Description |
|:----|:------------|
| `apiKeyHelper` | Shell script to generate auth value (sent as `X-Api-Key` and `Authorization: Bearer`) |
| `autoMemoryDirectory` | Custom auto memory storage path (not accepted in project settings) |
| `cleanupPeriodDays` | Days before inactive sessions are deleted (default: 30; `0` disables persistence) |
| `companyAnnouncements` | Startup announcements (array; cycled randomly) |
| `env` | Environment variables applied to every session |
| `attribution` | Customize git commit/PR attribution (keys: `commit`, `pr`; empty string hides) |
| `includeGitInstructions` | Include built-in git workflow instructions in system prompt (default: `true`) |
| `permissions` | Permission rules (`allow`, `ask`, `deny` arrays, `additionalDirectories`, `defaultMode`, `disableBypassPermissionsMode`) |
| `hooks` | Custom commands at lifecycle events |
| `disableAllHooks` | Disable all hooks and custom status line |
| `allowManagedHooksOnly` | (Managed only) Block user/project/plugin hooks |
| `allowedHttpHookUrls` | URL pattern allowlist for HTTP hooks (supports `*` wildcard) |
| `httpHookAllowedEnvVars` | Env var allowlist for HTTP hook header interpolation |
| `allowManagedPermissionRulesOnly` | (Managed only) Block user/project permission rules |
| `allowManagedMcpServersOnly` | (Managed only) Only managed `allowedMcpServers` are respected |
| `model` | Override default model |
| `availableModels` | Restrict models in `/model` picker |
| `modelOverrides` | Map Anthropic model IDs to provider-specific IDs (e.g., Bedrock ARNs) |
| `effortLevel` | Persist effort level: `"low"`, `"medium"`, `"high"` |
| `otelHeadersHelper` | Script for dynamic OpenTelemetry headers |
| `statusLine` | Custom status line config |
| `fileSuggestion` | Custom command for `@` file autocomplete |
| `respectGitignore` | Whether `@` picker respects `.gitignore` (default: `true`) |
| `outputStyle` | Output style for system prompt adjustment |
| `agent` | Run main thread as a named subagent |
| `forceLoginMethod` | Restrict login to `claudeai` or `console` |
| `forceLoginOrgUUID` | Auto-select organization during login |
| `enableAllProjectMcpServers` | Auto-approve all project `.mcp.json` servers |
| `enabledMcpjsonServers` | Specific `.mcp.json` servers to approve |
| `disabledMcpjsonServers` | Specific `.mcp.json` servers to reject |
| `channelsEnabled` | (Managed only) Allow channels for Team/Enterprise |
| `allowedMcpServers` | (Managed) MCP server allowlist |
| `deniedMcpServers` | (Managed) MCP server denylist (takes precedence) |
| `strictKnownMarketplaces` | (Managed only) Plugin marketplace allowlist |
| `blockedMarketplaces` | (Managed only) Plugin marketplace blocklist |
| `pluginTrustMessage` | (Managed only) Custom message on plugin trust warning |
| `awsAuthRefresh` | Script to refresh AWS credentials |
| `awsCredentialExport` | Script that outputs JSON with AWS credentials |
| `alwaysThinkingEnabled` | Enable extended thinking by default |
| `plansDirectory` | Where plan files are stored (default: `~/.claude/plans`) |
| `spinnerVerbs` | Custom spinner verbs (`mode`: `"replace"` or `"append"`, `verbs`: array) |
| `language` | Preferred response language (e.g., `"japanese"`) |
| `voiceEnabled` | Enable push-to-talk voice dictation |
| `autoUpdatesChannel` | `"stable"` (week-old, skips regressions) or `"latest"` (default) |
| `spinnerTipsEnabled` | Show spinner tips (default: `true`) |
| `spinnerTipsOverride` | Custom spinner tips (`tips` array, `excludeDefault` boolean) |
| `prefersReducedMotion` | Reduce UI animations for accessibility |
| `fastModePerSessionOptIn` | Require per-session fast mode opt-in |
| `teammateMode` | Agent team display: `"auto"`, `"in-process"`, or `"tmux"` |
| `feedbackSurveyRate` | Survey probability 0--1 (set to `0` to suppress) |

**Global config settings** (stored in `~/.claude.json`, not `settings.json`):

| Key | Description |
|:----|:------------|
| `showTurnDuration` | Show turn duration messages (default: `true`) |
| `terminalProgressBarEnabled` | Show terminal progress bar (default: `true`) |

**Worktree settings:**

| Key | Description |
|:----|:------------|
| `worktree.symlinkDirectories` | Directories to symlink into worktrees (avoids duplication) |
| `worktree.sparsePaths` | Directories for git sparse-checkout in worktrees |

### Permission System

**Permission modes** (set via `defaultMode` in settings or `/permissions`):

| Mode | Description |
|:-----|:------------|
| `default` | Prompts for permission on first use of each tool |
| `acceptEdits` | Auto-accepts file edit permissions for the session |
| `plan` | Analyze only; no file modifications or commands |
| `dontAsk` | Auto-denies tools unless pre-approved via `/permissions` or `allow` rules |
| `bypassPermissions` | Skips prompts except writes to `.git`, `.claude`, `.vscode`, `.idea` |

**Rule evaluation order:** deny -> ask -> allow. First matching rule wins.

**Permission rule syntax:** `Tool` or `Tool(specifier)`

| Pattern | Effect |
|:--------|:-------|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run ` |
| `Bash(npm run build)` | Matches exact command |
| `Bash(* --version)` | Matches commands ending with `--version` |
| `Read(./.env)` | Matches reading `.env` relative to cwd |
| `Edit(/src/**/*.ts)` | Matches editing TS files under project `src/` |
| `Read(//Users/alice/secrets/**)` | Matches absolute path |
| `Read(~/Documents/*.pdf)` | Matches home-relative path |
| `WebFetch(domain:example.com)` | Matches fetch requests to domain |
| `mcp__puppeteer__puppeteer_navigate` | Matches specific MCP tool |
| `mcp__puppeteer` | Matches all tools from MCP server |
| `Agent(Explore)` | Matches the Explore subagent |

**Read/Edit path patterns** (follow gitignore spec):

| Pattern | Meaning |
|:--------|:--------|
| `//path` | Absolute from filesystem root |
| `~/path` | Relative to home directory |
| `/path` | Relative to project root |
| `path` or `./path` | Relative to current directory |

`*` matches within a single directory; `**` matches recursively across directories.

**Bash wildcard notes:** Space before `*` enforces word boundary (`Bash(ls *)` matches `ls -la` but not `lsof`). Claude Code is aware of shell operators so `Bash(safe-cmd *)` won't permit `safe-cmd && other-cmd`.

### Managed-Only Settings

Settings only effective when set in managed settings:

| Setting | Description |
|:--------|:------------|
| `disableBypassPermissionsMode` | Set to `"disable"` to prevent `bypassPermissions` mode |
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply |
| `allowManagedHooksOnly` | Only managed and SDK hooks are allowed |
| `allowManagedMcpServersOnly` | Only managed MCP server allowlist is respected |
| `blockedMarketplaces` | Blocklist of marketplace sources (blocked before download) |
| `sandbox.network.allowManagedDomainsOnly` | Only managed domain allowlist is respected |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed `allowRead` paths are respected |
| `strictKnownMarketplaces` | Plugin marketplace allowlist |
| `allow_remote_sessions` | Allow Remote Control and web sessions (default: `true`) |

### Sandbox Settings

All under the `sandbox` key in settings.json:

| Key | Description |
|:----|:------------|
| `enabled` | Enable bash sandboxing (default: `false`) |
| `autoAllowBashIfSandboxed` | Auto-approve sandboxed bash commands (default: `true`) |
| `excludedCommands` | Commands that run outside sandbox |
| `allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch (default: `true`) |
| `filesystem.allowWrite` | Additional writable paths for sandboxed commands |
| `filesystem.denyWrite` | Paths where sandboxed commands cannot write |
| `filesystem.denyRead` | Paths where sandboxed commands cannot read |
| `filesystem.allowRead` | Re-allow reading within `denyRead` regions |
| `filesystem.allowManagedReadPathsOnly` | (Managed only) Only managed `allowRead` applies |
| `network.allowedDomains` | Allowed domains for outbound traffic (supports `*.example.com`) |
| `network.allowManagedDomainsOnly` | (Managed only) Only managed domain list applies |
| `network.allowUnixSockets` | Unix socket paths accessible in sandbox |
| `network.allowAllUnixSockets` | Allow all Unix socket connections (default: `false`) |
| `network.allowLocalBinding` | Allow binding to localhost ports, macOS only (default: `false`) |
| `network.httpProxyPort` | Custom HTTP proxy port for sandbox |
| `network.socksProxyPort` | Custom SOCKS5 proxy port for sandbox |
| `enableWeakerNestedSandbox` | Weaker sandbox for unprivileged Docker (Linux/WSL2 only) |
| `enableWeakerNetworkIsolation` | (macOS only) Allow system TLS trust service in sandbox |

**Sandbox path prefixes:**

| Prefix | Meaning |
|:-------|:--------|
| `/` | Absolute from filesystem root |
| `~/` | Relative to home directory |
| `./` or none | Relative to project root (project settings) or `~/.claude` (user settings) |

### Server-Managed Settings

Server-managed settings deliver configuration from Anthropic's servers. Available for Claude for Teams and Enterprise.

**Requirements:** Teams plan (v2.1.38+) or Enterprise plan (v2.1.30+), network access to `api.anthropic.com`.

**Configuration:** Admin Settings > Claude Code > Managed settings on Claude.ai. Supports all `settings.json` keys plus managed-only settings.

**Delivery:** Fetched at startup and polled hourly. Cached settings apply immediately on subsequent launches. Updates apply without restart (except OpenTelemetry).

**Precedence:** Server-managed > endpoint-managed (MDM/file). When server-managed settings are present, endpoint-managed settings are not used.

**Access control:** Primary Owner and Owner roles only.

**Security approval dialogs** required for: shell command settings, custom environment variables, hook configurations. Non-interactive mode (`-p` flag) skips dialogs.

**Not available with:** Bedrock, Vertex, Foundry, custom `ANTHROPIC_BASE_URL`.

**Limitations (beta):** Uniform settings for all users (no per-group). MCP server configs cannot be distributed via server-managed settings.

### Key Environment Variables

**Authentication and API:**

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key (overrides subscription auth) |
| `ANTHROPIC_AUTH_TOKEN` | Custom `Authorization` header value |
| `ANTHROPIC_BASE_URL` | Override API endpoint for proxy/gateway |
| `ANTHROPIC_MODEL` | Model setting to use |
| `ANTHROPIC_CUSTOM_HEADERS` | Custom request headers (newline-separated) |

**Provider selection:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |

**Model configuration:**

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Override default Sonnet model |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Override default Opus model |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Override default Haiku model |
| `ANTHROPIC_CUSTOM_MODEL_OPTION` | Add custom model to `/model` picker |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Max output tokens per request |
| `MAX_THINKING_TOKENS` | Extended thinking token budget |

**Feature toggles:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory (`1`) |
| `CLAUDE_CODE_DISABLE_FAST_MODE` | Disable fast mode |
| `CLAUDE_CODE_DISABLE_1M_CONTEXT` | Disable 1M context window |
| `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` | Disable adaptive reasoning |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | Disable background tasks |
| `CLAUDE_CODE_DISABLE_CRON` | Disable scheduled tasks |
| `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` | Remove built-in git workflow instructions |
| `CLAUDE_CODE_DISABLE_TERMINAL_TITLE` | Disable terminal title updates |
| `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION` | Set to `false` to disable prompt suggestions |
| `CLAUDE_CODE_ENABLE_TASKS` | Enable task tracking in non-interactive mode |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Enable agent teams |
| `CLAUDE_CODE_EFFORT_LEVEL` | Effort level: `low`, `medium`, `high`, `max`, `auto` |
| `CLAUDE_CODE_SIMPLE` | Minimal system prompt and tools only |

**Telemetry and diagnostics:**

| Variable | Purpose |
|:---------|:--------|
| `DISABLE_TELEMETRY` | Opt out of Statsig telemetry |
| `DISABLE_ERROR_REPORTING` | Opt out of Sentry error reporting |
| `DISABLE_FEEDBACK_COMMAND` | Disable `/feedback` command |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` | Disable session quality surveys |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable all non-essential traffic |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry data collection |

**Network and proxy:**

| Variable | Purpose |
|:---------|:--------|
| `HTTPS_PROXY` | HTTPS proxy server |
| `HTTP_PROXY` | HTTP proxy server |
| `NO_PROXY` | Domains/IPs to bypass proxy |
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate for mTLS |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key for mTLS |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted key |
| `CLAUDE_CODE_PROXY_RESOLVES_HOSTS` | Let proxy handle DNS resolution |

**Bash tool:**

| Variable | Purpose |
|:---------|:--------|
| `BASH_DEFAULT_TIMEOUT_MS` | Default timeout for bash commands |
| `BASH_MAX_TIMEOUT_MS` | Maximum timeout model can set |
| `BASH_MAX_OUTPUT_LENGTH` | Max characters before middle-truncation |
| `CLAUDE_CODE_SHELL` | Override detected shell |
| `CLAUDE_CODE_SHELL_PREFIX` | Command prefix wrapping all bash commands |
| `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR` | Return to original cwd after each command |
| `CLAUDECODE` | Set to `1` in Claude-spawned shell environments |
| `CLAUDE_ENV_FILE` | Shell script sourced before each Bash command |

**MCP:**

| Variable | Purpose |
|:---------|:--------|
| `MCP_TIMEOUT` | MCP server startup timeout (ms) |
| `MCP_TOOL_TIMEOUT` | MCP tool execution timeout (ms) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens in MCP responses (default: 25000) |
| `ENABLE_TOOL_SEARCH` | Control MCP tool search |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Enable/disable claude.ai MCP servers |

**Other notable variables:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CONFIG_DIR` | Custom config/data directory |
| `CLAUDE_CODE_TMPDIR` | Override temp directory |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Context capacity % for auto-compaction trigger (1--100) |
| `CLAUDE_CODE_AUTO_COMPACT_WINDOW` | Context capacity in tokens for auto-compaction |
| `CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS` | Override default token limit for file reads |
| `DISABLE_AUTOUPDATER` | Disable automatic updates |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching for all models |
| `USE_BUILTIN_RIPGREP` | Set to `0` to use system `rg` |

All environment variables can also be set in `settings.json` under the `env` key.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) -- configuration scopes (managed/user/project/local, when to use each, how they interact), settings files (settings.json locations, managed settings delivery via server/MDM/plist/registry/file, ~/.claude.json config), available settings table (apiKeyHelper, autoMemoryDirectory, cleanupPeriodDays, companyAnnouncements, env, attribution, includeGitInstructions, permissions, hooks, disableAllHooks, allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars, allowManagedPermissionRulesOnly, allowManagedMcpServersOnly, model, availableModels, modelOverrides, effortLevel, otelHeadersHelper, statusLine, fileSuggestion, respectGitignore, outputStyle, agent, forceLoginMethod, forceLoginOrgUUID, enableAllProjectMcpServers, enabledMcpjsonServers, disabledMcpjsonServers, channelsEnabled, allowedMcpServers, deniedMcpServers, strictKnownMarketplaces, blockedMarketplaces, pluginTrustMessage, awsAuthRefresh, awsCredentialExport, alwaysThinkingEnabled, plansDirectory, spinnerVerbs, language, voiceEnabled, autoUpdatesChannel, spinnerTipsEnabled, spinnerTipsOverride, prefersReducedMotion, fastModePerSessionOptIn, teammateMode, feedbackSurveyRate), global config settings (showTurnDuration, terminalProgressBarEnabled), worktree settings (symlinkDirectories, sparsePaths), permission settings (allow/ask/deny, additionalDirectories, defaultMode, disableBypassPermissionsMode), permission rule syntax, sandbox settings (enabled, autoAllowBashIfSandboxed, excludedCommands, allowUnsandboxedCommands, filesystem paths, network domains/sockets/proxy, enableWeakerNestedSandbox, enableWeakerNetworkIsolation, path prefixes), attribution settings (commit/pr with git trailers), file suggestion settings (custom command for @ autocomplete), hook configuration (allowManagedHooksOnly, URL/env var allowlists), settings precedence (managed > CLI > local > project > user, array merging), plugin configuration (enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces with exact matching and host patterns, blockedMarketplaces), subagent configuration, system prompt notes, excluding sensitive files
- [Configure Permissions](references/claude-code-permissions.md) -- permission system (tool types, approval tiers), /permissions command, permission modes (default, acceptEdits, plan, dontAsk, bypassPermissions), permission rule syntax (Tool and Tool(specifier) format), wildcard patterns for Bash (word boundary behavior, shell operator awareness, compound command handling), tool-specific rules (Bash wildcards, Read/Edit gitignore-style patterns with //absolute ~/home /project-relative ./cwd-relative prefixes, WebFetch domain matching, MCP server/tool matching, Agent subagent matching), extending permissions with hooks (PreToolUse allow/deny/ask), working directories (--add-dir, /add-dir, additionalDirectories), permissions and sandboxing interaction (complementary layers, defense-in-depth), managed settings (managed-only settings table), settings precedence for permissions, example configurations
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) -- overview (centralized config via Claude.ai admin console, Teams and Enterprise), requirements (plan versions, network access), server-managed vs endpoint-managed comparison, configuration steps (admin console, JSON, save/deploy), verify delivery (/permissions, security approval dialog), access control (Primary Owner, Owner), current limitations (uniform settings, no MCP distribution), settings delivery (precedence, fetch/caching behavior, first launch vs subsequent launches, auto-apply without restart), security approval dialogs (shell commands, custom env vars, hooks, non-interactive -p flag skips), platform availability (not available with Bedrock/Vertex/Foundry/custom base URL), audit logging (compliance API), security considerations (client-side control, cache tampering, API unavailability, org switching, ConfigChange hooks)
- [Environment Variables](references/claude-code-env-vars.md) -- complete reference table of all environment variables (ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_BASE_URL, ANTHROPIC_CUSTOM_HEADERS, ANTHROPIC_CUSTOM_MODEL_OPTION, ANTHROPIC_DEFAULT_*_MODEL, ANTHROPIC_FOUNDRY_*, ANTHROPIC_MODEL, AWS_BEARER_TOKEN_BEDROCK, BASH_DEFAULT_TIMEOUT_MS, BASH_MAX_OUTPUT_LENGTH, BASH_MAX_TIMEOUT_MS, CLAUDECODE, CLAUDE_AUTOCOMPACT_PCT_OVERRIDE, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR, CLAUDE_CODE_DISABLE_* feature toggles, CLAUDE_CODE_ENABLE_* feature toggles, CLAUDE_CODE_CLIENT_CERT/KEY/KEY_PASSPHRASE for mTLS, CLAUDE_CODE_SHELL/SHELL_PREFIX, CLAUDE_CODE_SIMPLE, CLAUDE_CODE_USE_BEDROCK/VERTEX/FOUNDRY, CLAUDE_CONFIG_DIR, CLAUDE_ENV_FILE, DISABLE_TELEMETRY/ERROR_REPORTING/AUTOUPDATER/PROMPT_CACHING, HTTP_PROXY/HTTPS_PROXY/NO_PROXY, MCP_TIMEOUT/MCP_TOOL_TIMEOUT/MAX_MCP_OUTPUT_TOKENS, VERTEX_REGION_* overrides, and more)

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment Variables: https://code.claude.com/docs/en/env-vars.md
