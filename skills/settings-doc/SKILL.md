---
name: settings-doc
description: Complete documentation for Claude Code settings, permissions, environment variables, and server-managed settings -- configuration scopes (managed/user/project/local, when to use each, what uses scopes), settings files (settings.json schema, user/project/local/managed locations, macOS plist/Windows registry/file-based managed settings, managed-settings.json paths per OS), available settings (apiKeyHelper, autoMemoryDirectory, cleanupPeriodDays, companyAnnouncements, env, attribution, includeCoAuthoredBy, includeGitInstructions, permissions, hooks, disableAllHooks, allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars, allowManagedPermissionRulesOnly, allowManagedMcpServersOnly, model, availableModels, modelOverrides, effortLevel, otelHeadersHelper, statusLine, fileSuggestion, respectGitignore, outputStyle, forceLoginMethod, forceLoginOrgUUID, enableAllProjectMcpServers, enabledMcpjsonServers, disabledMcpjsonServers, allowedMcpServers, deniedMcpServers, strictKnownMarketplaces, blockedMarketplaces, pluginTrustMessage, awsAuthRefresh, awsCredentialExport, alwaysThinkingEnabled, plansDirectory, showTurnDuration, spinnerVerbs, language, autoUpdatesChannel, spinnerTipsEnabled, spinnerTipsOverride, terminalProgressBarEnabled, prefersReducedMotion, fastModePerSessionOptIn, teammateMode, feedbackSurveyRate), worktree settings (symlinkDirectories, sparsePaths), permission settings (allow/ask/deny arrays, additionalDirectories, defaultMode, disableBypassPermissionsMode), permission rule syntax (Tool/Tool(specifier) format, wildcard patterns, Bash/Read/Edit/WebFetch/MCP/Agent rules, gitignore path patterns //~/./), sandbox settings (enabled, autoAllowBashIfSandboxed, excludedCommands, allowUnsandboxedCommands, filesystem.allowWrite/denyWrite/denyRead, network.allowUnixSockets/allowAllUnixSockets/allowLocalBinding/allowedDomains/allowManagedDomainsOnly/httpProxyPort/socksProxyPort, enableWeakerNestedSandbox, enableWeakerNetworkIsolation, path prefixes), attribution settings (commit/pr), file suggestion settings (custom command for @ autocomplete), hook configuration (allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars), settings precedence (managed > CLI args > local project > shared project > user, array merging behavior), permission modes (default/acceptEdits/plan/dontAsk/bypassPermissions), managed-only settings (disableBypassPermissionsMode, allowManagedPermissionRulesOnly, allowManagedHooksOnly, allowManagedMcpServersOnly, blockedMarketplaces, sandbox.network.allowManagedDomainsOnly, strictKnownMarketplaces, allow_remote_sessions), environment variables (ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_BASE_URL, ANTHROPIC_MODEL, ANTHROPIC_SMALL_FAST_MODEL, CLAUDE_CODE_USE_BEDROCK/VERTEX/FOUNDRY, model override vars, BASH_DEFAULT_TIMEOUT_MS, BASH_MAX_TIMEOUT_MS, BASH_MAX_OUTPUT_LENGTH, MCP_TIMEOUT, MCP_TOOL_TIMEOUT, MAX_MCP_OUTPUT_TOKENS, HTTP_PROXY/HTTPS_PROXY/NO_PROXY, CLAUDE_CODE_ENABLE_TELEMETRY, DISABLE_AUTOUPDATER, CLAUDE_CONFIG_DIR, CLAUDE_ENV_FILE, CLAUDE_CODE_SHELL, and 80+ more), server-managed settings (requirements, admin console setup, settings delivery, fetch/caching behavior, security approval dialogs, access control, platform availability, audit logging, security considerations, endpoint-managed vs server-managed comparison). Load when discussing Claude Code settings, settings.json, configuration, permissions, permission rules, permission modes, allow/deny rules, managed settings, server-managed settings, environment variables, env vars, sandbox settings, sandbox configuration, sandbox path prefixes, settings precedence, settings scopes, /config command, /permissions command, /status command, managed-settings.json, plist, registry policies, MDM deployment, worktree settings, attribution settings, file suggestion, hook configuration settings, MCP server settings, plugin trust, company announcements, spinner customization, effort level, model override, available models, force login, auto-updates channel, or any settings.json field names.
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, environment variables, and server-managed settings.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared with team? |
|:------|:---------|:---------------|:-------------------|
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | All users on the machine | Yes (deployed by IT) |
| **User** | `~/.claude/settings.json` | You, across all projects | No |
| **Project** | `.claude/settings.json` | All collaborators on this repository | Yes (committed to git) |
| **Local** | `.claude/settings.local.json` | You, in this repository only | No (gitignored) |

### Settings Files Locations

| Scope | Settings | Subagents | MCP servers | CLAUDE.md |
|:------|:---------|:----------|:------------|:----------|
| User | `~/.claude/settings.json` | `~/.claude/agents/` | `~/.claude.json` | `~/.claude/CLAUDE.md` |
| Project | `.claude/settings.json` | `.claude/agents/` | `.mcp.json` | `CLAUDE.md` or `.claude/CLAUDE.md` |
| Local | `.claude/settings.local.json` | -- | `~/.claude.json` (per-project) | -- |

**Managed settings delivery mechanisms:**

| Mechanism | Platform | Location |
|:----------|:---------|:---------|
| Server-managed | All | Claude.ai admin console (fetched via API) |
| MDM/plist | macOS | `com.anthropic.claudecode` managed preferences domain |
| Registry (admin) | Windows | `HKLM\SOFTWARE\Policies\ClaudeCode` `Settings` value |
| Registry (user) | Windows | `HKCU\SOFTWARE\Policies\ClaudeCode` (lowest policy priority) |
| File-based | macOS | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| File-based | Linux/WSL | `/etc/claude-code/managed-settings.json` |
| File-based | Windows | `C:\Program Files\ClaudeCode\managed-settings.json` |

### Settings Precedence (Highest to Lowest)

1. **Managed settings** -- cannot be overridden, including by CLI args. Within managed tier: server-managed > MDM/OS-level > `managed-settings.json` > HKCU registry. Only one managed source is used; they do not merge.
2. **Command line arguments** -- temporary session overrides
3. **Local project** (`.claude/settings.local.json`)
4. **Shared project** (`.claude/settings.json`)
5. **User settings** (`~/.claude/settings.json`)

Array-valued settings (like `permissions.allow`, `sandbox.filesystem.allowWrite`) merge (concatenate and deduplicate) across scopes rather than replacing.

### Available Settings (settings.json)

| Key | Description |
|:----|:------------|
| `apiKeyHelper` | Custom script to generate auth value (sent as X-Api-Key and Bearer headers) |
| `autoMemoryDirectory` | Custom directory for auto memory storage (not accepted in project settings) |
| `cleanupPeriodDays` | Session cleanup period in days (default: 30). `0` disables persistence entirely |
| `companyAnnouncements` | Startup announcement strings (array, randomly cycled) |
| `env` | Environment variables applied to every session |
| `attribution` | Customize git commit/PR attribution (object with `commit` and `pr` keys) |
| `includeCoAuthoredBy` | Deprecated: use `attribution`. Co-authored-by byline in commits (default: true) |
| `includeGitInstructions` | Include built-in git workflow instructions in system prompt (default: true) |
| `permissions` | Permission rules object (`allow`, `ask`, `deny` arrays, `defaultMode`, etc.) |
| `hooks` | Hook configurations for lifecycle events |
| `disableAllHooks` | Disable all hooks and custom status line |
| `allowManagedHooksOnly` | Managed only: block user/project/plugin hooks |
| `allowedHttpHookUrls` | URL pattern allowlist for HTTP hooks (supports `*` wildcard) |
| `httpHookAllowedEnvVars` | Env var name allowlist for HTTP hook header interpolation |
| `allowManagedPermissionRulesOnly` | Managed only: only managed permission rules apply |
| `allowManagedMcpServersOnly` | Managed only: only managed MCP allowlist applies |
| `model` | Override default model |
| `availableModels` | Restrict models selectable via `/model`, `--model`, etc. |
| `modelOverrides` | Map Anthropic model IDs to provider-specific IDs (e.g., Bedrock ARNs) |
| `effortLevel` | Persist effort level: `"low"`, `"medium"`, or `"high"` |
| `otelHeadersHelper` | Script for dynamic OpenTelemetry headers |
| `statusLine` | Custom status line config (object with `type` and `command`) |
| `fileSuggestion` | Custom script for `@` file autocomplete |
| `respectGitignore` | Whether `@` file picker respects `.gitignore` (default: true) |
| `outputStyle` | Output style name to adjust system prompt |
| `forceLoginMethod` | Restrict login to `claudeai` or `console` |
| `forceLoginOrgUUID` | Auto-select org during login (requires `forceLoginMethod`) |
| `enableAllProjectMcpServers` | Auto-approve all project `.mcp.json` servers |
| `enabledMcpjsonServers` | Specific MCP servers from `.mcp.json` to approve |
| `disabledMcpjsonServers` | Specific MCP servers from `.mcp.json` to reject |
| `allowedMcpServers` | Managed: MCP server allowlist |
| `deniedMcpServers` | Managed: MCP server denylist (takes precedence over allowlist) |
| `strictKnownMarketplaces` | Managed: marketplace allowlist |
| `blockedMarketplaces` | Managed: marketplace blocklist (checked before download) |
| `pluginTrustMessage` | Managed: custom message appended to plugin trust warning |
| `awsAuthRefresh` | Custom script to modify `.aws` directory |
| `awsCredentialExport` | Custom script outputting JSON with AWS credentials |
| `alwaysThinkingEnabled` | Enable extended thinking by default |
| `plansDirectory` | Custom plans directory (default: `~/.claude/plans`) |
| `showTurnDuration` | Show turn duration messages (default: true) |
| `spinnerVerbs` | Custom spinner verbs (object with `mode` and `verbs`) |
| `language` | Preferred response language (e.g., `"japanese"`) |
| `autoUpdatesChannel` | `"stable"` (one week old) or `"latest"` (default) |
| `spinnerTipsEnabled` | Show spinner tips (default: true) |
| `spinnerTipsOverride` | Custom spinner tips (object with `excludeDefault` and `tips`) |
| `terminalProgressBarEnabled` | Terminal progress bar (default: true) |
| `prefersReducedMotion` | Reduce UI animations for accessibility |
| `fastModePerSessionOptIn` | Require per-session `/fast` to enable fast mode |
| `teammateMode` | Agent team display: `"auto"`, `"in-process"`, or `"tmux"` |
| `feedbackSurveyRate` | Session quality survey probability (0-1) |
| `worktree.symlinkDirectories` | Directories to symlink from main repo into worktrees |
| `worktree.sparsePaths` | Directories to sparse-checkout in worktrees |

### Permission Settings

| Key | Description |
|:----|:------------|
| `permissions.allow` | Array of rules to allow tool use without prompting |
| `permissions.ask` | Array of rules to prompt for confirmation |
| `permissions.deny` | Array of rules to block tool use |
| `additionalDirectories` | Additional working directories Claude can access |
| `defaultMode` | Default permission mode |
| `disableBypassPermissionsMode` | Set to `"disable"` to prevent bypass mode and `--dangerously-skip-permissions` |

### Permission Modes

| Mode | Description |
|:-----|:------------|
| `default` | Prompts for permission on first use of each tool |
| `acceptEdits` | Auto-accepts file edit permissions for the session |
| `plan` | Read-only: Claude can analyze but not modify files or run commands |
| `dontAsk` | Auto-denies tools unless pre-approved via rules |
| `bypassPermissions` | Skips all permission prompts (use only in isolated environments) |

### Permission Rule Syntax

Format: `Tool` or `Tool(specifier)`. Evaluation order: **deny > ask > allow** (first match wins).

| Rule pattern | Effect |
|:-------------|:-------|
| `Bash` or `Bash(*)` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Bash(* --version)` | Commands ending with ` --version` |
| `Read(./.env)` | Read `.env` in current directory |
| `Edit(/src/**/*.ts)` | Edit TypeScript files under project `src/` |
| `Read(//Users/alice/secrets/**)` | Absolute path read |
| `Read(~/Documents/*.pdf)` | Home-relative read |
| `WebFetch(domain:example.com)` | Fetch requests to domain |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `mcp__puppeteer` or `mcp__puppeteer__*` | All tools from MCP server |
| `Agent(Explore)` | Specific subagent |

**Read/Edit path pattern types** (follows gitignore spec):

| Pattern | Meaning | Example |
|:--------|:--------|:--------|
| `//path` | Absolute path from filesystem root | `Read(//Users/alice/secrets/**)` |
| `~/path` | Path from home directory | `Read(~/Documents/*.pdf)` |
| `/path` | Relative to project root | `Edit(/src/**/*.ts)` |
| `path` or `./path` | Relative to current directory | `Read(*.env)` |

Note: `*` matches within a single directory, `**` matches recursively across directories. The space before `*` in Bash rules matters: `Bash(ls *)` matches `ls -la` but not `lsof`.

### Sandbox Settings

Nested under `"sandbox"` in settings.json:

| Key | Description | Default |
|:----|:------------|:--------|
| `enabled` | Enable bash sandboxing | `false` |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed | `true` |
| `excludedCommands` | Commands that run outside sandbox | -- |
| `allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch | `true` |
| `filesystem.allowWrite` | Additional writable paths (merged across scopes) | -- |
| `filesystem.denyWrite` | Paths blocked for writing (merged across scopes) | -- |
| `filesystem.denyRead` | Paths blocked for reading (merged across scopes) | -- |
| `network.allowUnixSockets` | Unix socket paths accessible in sandbox | -- |
| `network.allowAllUnixSockets` | Allow all Unix socket connections | `false` |
| `network.allowLocalBinding` | Allow binding to localhost ports (macOS) | `false` |
| `network.allowedDomains` | Domains allowed for outbound traffic (supports wildcards) | -- |
| `network.allowManagedDomainsOnly` | Managed only: only managed domain allowlists apply | `false` |
| `network.httpProxyPort` | Custom HTTP proxy port for sandbox | -- |
| `network.socksProxyPort` | Custom SOCKS5 proxy port for sandbox | -- |
| `enableWeakerNestedSandbox` | Weaker sandbox for unprivileged Docker (Linux/WSL2) | `false` |
| `enableWeakerNetworkIsolation` | macOS: allow system TLS trust service in sandbox | `false` |

**Sandbox path prefixes** (for `filesystem.allowWrite`, `denyWrite`, `denyRead`):

| Prefix | Meaning |
|:-------|:--------|
| `//` | Absolute path from filesystem root |
| `~/` | Relative to home directory |
| `/` | Relative to the settings file's directory |
| `./` or none | Relative path (resolved by sandbox runtime) |

### Managed-Only Settings

Settings only effective in managed settings (server-managed, MDM, or managed-settings.json):

| Setting | Description |
|:--------|:------------|
| `disableBypassPermissionsMode` | Set to `"disable"` to prevent bypass mode |
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply |
| `allowManagedHooksOnly` | Only managed and SDK hooks load |
| `allowManagedMcpServersOnly` | Only managed MCP allowlist applies |
| `blockedMarketplaces` | Marketplace blocklist (blocked before download) |
| `sandbox.network.allowManagedDomainsOnly` | Only managed domain allowlists apply |
| `strictKnownMarketplaces` | Marketplace allowlist for user additions |
| `allow_remote_sessions` | Allow Remote Control and web sessions (default: true) |

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key for Claude SDK |
| `ANTHROPIC_AUTH_TOKEN` | Auth token (Bearer header only) |
| `ANTHROPIC_BASE_URL` | Custom API endpoint |
| `ANTHROPIC_MODEL` | Override default model |
| `ANTHROPIC_SMALL_FAST_MODEL` | Override small/fast model |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock (`1` to enable) |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI (`1` to enable) |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry (`1` to enable) |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Maximum bash timeout (default: 600000) |
| `BASH_MAX_OUTPUT_LENGTH` | Max bash output characters |
| `MCP_TIMEOUT` | MCP server startup timeout in ms (default: 10000) |
| `MCP_TOOL_TIMEOUT` | MCP tool execution timeout in ms (default: 300000) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens for MCP tool output (default: 25000) |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server URLs |
| `NO_PROXY` | Proxy bypass list |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry |
| `DISABLE_AUTOUPDATER` | Disable all auto-updates |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `CLAUDE_ENV_FILE` | Load env vars from a file |
| `CLAUDE_CODE_SHELL` | Override shell used for bash commands |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Max output tokens per response |
| `MAX_THINKING_TOKENS` | Max extended thinking tokens |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable non-essential network traffic |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Override model for subagents |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set reasoning effort: `low`, `medium`, `high` |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Enable agent teams feature |

The full environment variables reference contains 90+ variables covering authentication, model configuration, Bedrock/Vertex/Foundry setup, bash behavior, MCP settings, proxy/network, telemetry, UI customization, and more. See the reference file for the complete list.

### Server-Managed Settings

Server-managed settings deliver configuration from Anthropic's servers via the Claude.ai admin console, without requiring MDM infrastructure.

**Requirements:** Claude for Teams or Enterprise plan, Claude Code 2.1.38+ (Teams) or 2.1.30+ (Enterprise), network access to `api.anthropic.com`.

**Setup:** Admin Settings > Claude Code > Managed settings in Claude.ai. Supports all `settings.json` fields plus managed-only settings.

**Delivery:** Fetched at startup and polled hourly. Cached settings apply immediately on subsequent launches. Settings apply uniformly to all org users (no per-group configs yet). MCP server configs cannot be distributed via server-managed settings.

**Precedence:** When both server-managed and endpoint-managed settings exist, server-managed takes precedence and endpoint-managed settings are not used.

**Security approval dialogs:** Users must approve settings containing shell commands, custom env vars, or hook configs. In non-interactive mode (`-p` flag), dialogs are skipped.

**Not available with:** Bedrock, Vertex AI, Foundry, custom `ANTHROPIC_BASE_URL`, or LLM gateways.

### Useful Commands

| Command | Purpose |
|:--------|:--------|
| `/config` | Open Settings UI (interactive REPL) |
| `/permissions` | View and manage permission rules |
| `/status` | See active settings sources and their origins |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) -- configuration scopes (managed/user/project/local with guidance on when to use each), settings files (all locations, managed delivery mechanisms, JSON schema), complete available settings table, worktree settings, permission settings with rule syntax, sandbox settings with path prefixes, attribution settings, file suggestion settings, hook configuration, settings precedence with array merging, subagent configuration, plugin configuration, ignorePatterns deprecation, excluding sensitive files, system prompt notes, /config and /status commands
- [Configure permissions](references/claude-code-permissions.md) -- permission system (tool types, approval behavior), permission modes (default/acceptEdits/plan/dontAsk/bypassPermissions), permission rule syntax (Tool/Tool(specifier) format, wildcard patterns, word boundaries), tool-specific rules (Bash with wildcard details and security warnings, Read/Edit with gitignore-style path patterns and prefix types, WebFetch domain matching, MCP server/tool matching, Agent rules), extending permissions with hooks, working directories (--add-dir, /add-dir, additionalDirectories), permissions and sandboxing interaction, managed-only settings table, settings precedence for permissions, example configurations
- [Server-managed settings](references/claude-code-server-managed-settings.md) -- requirements, server-managed vs endpoint-managed comparison, admin console setup steps, settings delivery (precedence within managed tier, fetch/caching behavior including first-launch and subsequent-launch flows), security approval dialogs (shell commands, env vars, hooks), access control (Primary Owner, Owner roles), current limitations, platform availability (not available with Bedrock/Vertex/Foundry/custom base URL), audit logging, security considerations (cached file tampering, API unavailability, org switching, non-default base URL), ConfigChange hooks for runtime detection
- [Environment variables](references/claude-code-env-vars.md) -- complete reference of 90+ environment variables organized by category: authentication (API keys, auth tokens, org/account UUIDs), model configuration (default model overrides for Sonnet/Opus/Haiku, small/fast model, effort level), Amazon Bedrock setup (region, profile, credential helpers), Google Vertex AI setup (project, region), Microsoft Foundry setup (resource, base URL, API key), bash behavior (timeout, output length, shell, working directory), MCP settings (timeout, tool timeout, output tokens, OAuth), proxy/network (HTTP_PROXY, HTTPS_PROXY, NO_PROXY, client certs), telemetry and error reporting, auto-updates and plugins, UI customization (terminal title, simple mode, reduced motion, prompt suggestions), advanced settings (config dir, env file, tmpdir, auto-compact, background tasks, cron, feedback survey)

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
