---
name: settings-doc
description: Complete documentation for Claude Code settings, configuration, permissions, environment variables, and server-managed settings -- settings.json structure and all available keys (permissions, hooks, env, model, sandbox, attribution, fileSuggestion, plugins, worktree, statusLine, outputStyle, language, spinnerVerbs, companyAnnouncements, cleanupPeriodDays, autoMemoryDirectory, availableModels, modelOverrides, effortLevel, forceLoginMethod, enableAllProjectMcpServers, channelsEnabled, apiKeyHelper, awsAuthRefresh, awsCredentialExport, plansDirectory, alwaysThinkingEnabled, fastModePerSessionOptIn, teammateMode, feedbackSurveyRate, voiceEnabled, autoUpdatesChannel), global config settings in ~/.claude.json (autoConnectIde, autoInstallIdeExtension, editorMode, showTurnDuration, terminalProgressBarEnabled), configuration scopes (managed, user, project, local), settings file locations (~/claude/settings.json, .claude/settings.json, .claude/settings.local.json, managed-settings.json, MDM/plist, Windows registry), settings precedence (managed > CLI args > local > project > user), array merging across scopes, permission system (allow/ask/deny rules, evaluation order deny > ask > allow), permission modes (default, acceptEdits, plan, dontAsk, bypassPermissions), permission rule syntax (Tool, Tool(specifier), wildcard *, word boundary, compound commands), tool-specific permission rules (Bash wildcards and word boundaries, Read/Edit gitignore patterns with //path ~/path /path ./path, WebFetch domain matching, MCP server and tool matching, Agent subagent matching), working directories (--add-dir, /add-dir, additionalDirectories), managed-only settings (disableBypassPermissionsMode, allowManagedPermissionRulesOnly, allowManagedHooksOnly, allowManagedMcpServersOnly, blockedMarketplaces, sandbox.network.allowManagedDomainsOnly, sandbox.filesystem.allowManagedReadPathsOnly, strictKnownMarketplaces), sandbox settings (enabled, autoAllowBashIfSandboxed, excludedCommands, allowUnsandboxedCommands, filesystem allowWrite/denyWrite/denyRead/allowRead, network allowedDomains/allowUnixSockets/allowLocalBinding/httpProxyPort/socksProxyPort, path prefixes / ~/ ./), plugin configuration (enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces, blockedMarketplaces, marketplace source types github/git/url/npm/file/directory/hostPattern/settings), server-managed settings (admin console, Teams/Enterprise, settings delivery and caching, security approval dialogs, platform availability, audit logging, comparison with endpoint-managed settings), environment variables reference (ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_BASE_URL, ANTHROPIC_MODEL, CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, CLAUDE_CODE_USE_FOUNDRY, CLAUDE_CODE_ENABLE_TELEMETRY, CLAUDE_CODE_MAX_OUTPUT_TOKENS, MAX_THINKING_TOKENS, BASH_DEFAULT_TIMEOUT_MS, MCP_TIMEOUT, HTTP_PROXY, HTTPS_PROXY, and 90+ more), hook configuration (allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars). Load when discussing Claude Code settings, configuration, settings.json, permissions, permission rules, allow/deny rules, permission modes, bypassPermissions, managed settings, server-managed settings, enterprise policy, sandbox configuration, sandbox settings, environment variables, env vars for Claude Code, ANTHROPIC_API_KEY, ANTHROPIC_MODEL, ANTHROPIC_BASE_URL, plugin settings, marketplace configuration, working directories, additionalDirectories, settings precedence, /config, /permissions, /status, settings scopes, project settings, user settings, local settings, managed-settings.json, MDM deployment, configuration files, or any settings/configuration topic for Claude Code.
user-invocable: false
---

# Settings & Configuration Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, environment variables, and server-managed settings.

## Quick Reference

### Configuration Scopes

| Scope | Location | Affects | Shared? |
|:------|:---------|:--------|:--------|
| Managed | Server-managed, plist/registry, or `managed-settings.json` | All users on machine | Yes (deployed by IT) |
| User | `~/.claude/settings.json` | You, across all projects | No |
| Project | `.claude/settings.json` | All collaborators | Yes (committed to git) |
| Local | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |

### Settings Precedence (highest to lowest)

1. **Managed settings** -- cannot be overridden by anything (within managed: server-managed > MDM/OS-level > managed-settings.json > HKCU)
2. **Command line arguments** -- temporary session overrides
3. **Local project settings** -- `.claude/settings.local.json`
4. **Shared project settings** -- `.claude/settings.json`
5. **User settings** -- `~/.claude/settings.json`

Array-valued settings (like `permissions.allow`, `sandbox.filesystem.allowWrite`) are concatenated and deduplicated across scopes, not replaced.

### Managed Settings File Locations

| Platform | Path |
|:---------|:-----|
| macOS (file) | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| macOS (MDM) | `com.anthropic.claudecode` managed preferences domain |
| Linux/WSL | `/etc/claude-code/managed-settings.json` |
| Windows (file) | `C:\Program Files\ClaudeCode\managed-settings.json` |
| Windows (registry) | `HKLM\SOFTWARE\Policies\ClaudeCode` with `Settings` REG_SZ value |

### Available settings.json Keys

| Key | Description |
|:----|:------------|
| `permissions` | Permission rules (`allow`, `ask`, `deny` arrays), `additionalDirectories`, `defaultMode`, `disableBypassPermissionsMode` |
| `hooks` | Lifecycle hook configurations (see hooks-doc skill) |
| `env` | Environment variables applied to every session |
| `model` | Override default model |
| `availableModels` | Restrict which models users can select |
| `modelOverrides` | Map Anthropic model IDs to provider-specific model IDs |
| `effortLevel` | Persist effort level: `"low"`, `"medium"`, `"high"` |
| `sandbox` | Sandboxing configuration (see sandbox section below) |
| `attribution` | Customize git commit/PR attribution (`commit`, `pr` subkeys) |
| `outputStyle` | Adjust system prompt output style |
| `language` | Preferred response language |
| `statusLine` | Custom status line command |
| `fileSuggestion` | Custom `@` file autocomplete command |
| `respectGitignore` | Whether `@` file picker respects `.gitignore` (default: true) |
| `apiKeyHelper` | Script to generate auth value for model requests |
| `autoMemoryDirectory` | Custom directory for auto memory storage |
| `cleanupPeriodDays` | Inactive session deletion threshold (default: 30) |
| `companyAnnouncements` | Startup announcements array |
| `enabledPlugins` | Plugin enable/disable map (`"plugin@marketplace": true/false`) |
| `extraKnownMarketplaces` | Additional marketplace definitions |
| `enableAllProjectMcpServers` | Auto-approve all project `.mcp.json` servers |
| `enabledMcpjsonServers` | Specific MCP servers to approve |
| `disabledMcpjsonServers` | Specific MCP servers to reject |
| `forceLoginMethod` | Restrict login to `"claudeai"` or `"console"` |
| `forceLoginOrgUUID` | Auto-select org during login |
| `alwaysThinkingEnabled` | Enable extended thinking by default |
| `plansDirectory` | Custom plan file storage path |
| `agent` | Run main thread as a named subagent |
| `voiceEnabled` | Enable push-to-talk voice dictation |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) |
| `spinnerVerbs` | Customize spinner verbs (`mode`: `"replace"`/`"append"`, `verbs` array) |
| `spinnerTipsEnabled` | Show tips in spinner (default: true) |
| `spinnerTipsOverride` | Custom spinner tips (`tips` array, `excludeDefault` boolean) |
| `prefersReducedMotion` | Reduce UI animations |
| `fastModePerSessionOptIn` | Require per-session fast mode opt-in |
| `teammateMode` | Agent team display: `"auto"`, `"in-process"`, `"tmux"` |
| `feedbackSurveyRate` | Session quality survey probability (0-1) |
| `disableAllHooks` | Disable all hooks and custom status line |
| `includeGitInstructions` | Include git workflow instructions in system prompt (default: true) |
| `worktree.symlinkDirectories` | Directories to symlink in worktrees |
| `worktree.sparsePaths` | Sparse checkout paths for worktrees |

**Global config settings** (stored in `~/.claude.json`, not `settings.json`):

| Key | Description |
|:----|:------------|
| `autoConnectIde` | Auto-connect to running IDE from external terminal |
| `autoInstallIdeExtension` | Auto-install IDE extension from VS Code terminal |
| `editorMode` | Key binding mode: `"normal"` or `"vim"` |
| `showTurnDuration` | Show turn duration messages (default: true) |
| `terminalProgressBarEnabled` | Show terminal progress bar (default: true) |

### Permission System

**Permission modes** (set via `defaultMode` in settings):

| Mode | Description |
|:-----|:------------|
| `default` | Prompts for permission on first use of each tool |
| `acceptEdits` | Auto-accepts file edit permissions for the session |
| `plan` | Analyze only -- no file modifications or commands |
| `dontAsk` | Auto-denies tools unless pre-approved via rules |
| `bypassPermissions` | Skips permission prompts (still prompts for `.git`, `.claude`, `.vscode`, `.idea` writes) |

**Rule evaluation order:** deny > ask > allow (first match wins).

**Permission rule syntax:** `Tool` or `Tool(specifier)`

| Pattern | Example | Matches |
|:--------|:--------|:--------|
| Tool name only | `Bash` | All uses of the tool |
| Exact command | `Bash(npm run build)` | That exact command |
| Wildcard | `Bash(npm run *)` | Commands starting with `npm run ` |
| File path | `Read(./.env)` | Reading `.env` in current directory |
| Domain | `WebFetch(domain:example.com)` | Fetch requests to example.com |
| MCP server | `mcp__puppeteer` | All tools from `puppeteer` server |
| MCP tool | `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| Agent | `Agent(Explore)` | The Explore subagent |

**Read/Edit path patterns** follow gitignore specification:

| Pattern | Meaning | Example |
|:--------|:--------|:--------|
| `//path` | Absolute path from filesystem root | `Read(//Users/alice/secrets/**)` |
| `~/path` | Relative to home directory | `Read(~/Documents/*.pdf)` |
| `/path` | Relative to project root | `Edit(/src/**/*.ts)` |
| `path` or `./path` | Relative to current directory | `Read(*.env)` |

Note: `*` matches files in a single directory; `**` matches recursively across directories.

**Bash wildcard word boundary:** `Bash(ls *)` (with space before `*`) matches `ls -la` but not `lsof`. `Bash(ls*)` (no space) matches both.

### Managed-Only Settings

These settings are only effective in managed settings and cannot be set in user/project settings:

| Setting | Description |
|:--------|:------------|
| `disableBypassPermissionsMode` | Set to `"disable"` to prevent `bypassPermissions` mode |
| `allowManagedPermissionRulesOnly` | When true, only managed permission rules apply |
| `allowManagedHooksOnly` | When true, only managed and SDK hooks load |
| `allowManagedMcpServersOnly` | When true, only managed MCP allowlist applies |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `sandbox.network.allowManagedDomainsOnly` | When true, only managed domain allowlist applies |
| `sandbox.filesystem.allowManagedReadPathsOnly` | When true, only managed `allowRead` paths apply |
| `strictKnownMarketplaces` | Allowlist of marketplace sources users can add |
| `channelsEnabled` | Allow channels for Team/Enterprise users |

### Sandbox Settings

Nested under `"sandbox"` key in settings.json:

| Key | Description | Default |
|:----|:------------|:--------|
| `enabled` | Enable bash sandboxing | false |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed | true |
| `excludedCommands` | Commands that run outside sandbox | -- |
| `allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch | true |
| `filesystem.allowWrite` | Additional writable paths | -- |
| `filesystem.denyWrite` | Paths where writes are blocked | -- |
| `filesystem.denyRead` | Paths where reads are blocked | -- |
| `filesystem.allowRead` | Re-allow reading within `denyRead` regions | -- |
| `network.allowedDomains` | Domains for outbound traffic (supports `*.example.com`) | -- |
| `network.allowUnixSockets` | Unix socket paths accessible in sandbox | -- |
| `network.allowAllUnixSockets` | Allow all Unix socket connections | false |
| `network.allowLocalBinding` | Allow binding to localhost ports (macOS only) | false |
| `network.httpProxyPort` | HTTP proxy port for sandbox | -- |
| `network.socksProxyPort` | SOCKS5 proxy port for sandbox | -- |
| `enableWeakerNestedSandbox` | Weaker sandbox for unprivileged Docker (Linux/WSL2) | false |
| `enableWeakerNetworkIsolation` | Allow macOS TLS trust service in sandbox | false |

**Sandbox path prefixes:** `/` = absolute, `~/` = home-relative, `./` or no prefix = project-relative (for project settings) or `~/.claude`-relative (for user settings).

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key for direct authentication |
| `ANTHROPIC_AUTH_TOKEN` | Pre-built auth header value |
| `ANTHROPIC_BASE_URL` | Custom API endpoint |
| `ANTHROPIC_MODEL` | Override model selection |
| `ANTHROPIC_SMALL_FAST_MODEL` | Model for background tasks |
| `CLAUDE_CODE_USE_BEDROCK` | Enable Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Enable Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Enable Microsoft Foundry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry export |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Max output tokens per turn |
| `MAX_THINKING_TOKENS` | Max extended thinking tokens |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout |
| `BASH_MAX_TIMEOUT_MS` | Maximum bash command timeout |
| `BASH_MAX_OUTPUT_LENGTH` | Max bash output characters |
| `MCP_TIMEOUT` | MCP server startup timeout |
| `MCP_TOOL_TIMEOUT` | MCP tool execution timeout |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy configuration |
| `NO_PROXY` | Proxy bypass list |
| `DISABLE_AUTOUPDATER` | Disable auto-updates |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `CLAUDE_CODE_SHELL` | Override shell for bash tool |

For the full list of 100+ environment variables, see the env vars reference doc.

### Server-Managed Settings

Available for Claude for Teams and Enterprise plans. Configured via Admin Settings > Claude Code > Managed settings on Claude.ai.

| Feature | Detail |
|:--------|:-------|
| Delivery | Fetched at startup, polled hourly |
| Caching | Cached settings apply immediately on subsequent launches |
| Precedence | Highest tier (overrides endpoint-managed when both present) |
| Access control | Primary Owner and Owner roles |
| Security dialogs | Required for shell commands, custom env vars, and hooks |
| Non-interactive mode | `-p` flag skips security dialogs |
| Limitations | Uniform to all org users; MCP configs not supported |
| Platform | Requires `api.anthropic.com`; not available with Bedrock/Vertex/Foundry |

### Plugin Configuration

| Setting | Scope | Purpose |
|:--------|:------|:--------|
| `enabledPlugins` | User/Project/Local | Map of `"plugin@marketplace": bool` |
| `extraKnownMarketplaces` | Any settings file | Define additional marketplace sources |
| `strictKnownMarketplaces` | Managed only | Allowlist of permitted marketplace sources |
| `blockedMarketplaces` | Managed only | Blocklist of marketplace sources |
| `pluginTrustMessage` | Managed only | Custom message appended to plugin trust warning |

**Marketplace source types:** `github`, `git`, `url`, `npm`, `file`, `directory`, `hostPattern`, `settings` (inline).

### Useful Commands

| Command | Purpose |
|:--------|:--------|
| `/config` | Open settings interface |
| `/permissions` | View and manage permission rules |
| `/status` | View active settings sources and origins |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) -- complete settings reference including all available settings.json keys, configuration scopes (managed/user/project/local), settings file locations and delivery mechanisms (MDM, plist, registry, managed-settings.json), settings precedence and merging, permission settings structure, permission rule syntax, sandbox settings with filesystem and network configuration, attribution settings, file suggestion settings, hook configuration (allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars), plugin configuration (enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces with all marketplace source types), worktree settings, global config settings in ~/.claude.json, subagent configuration, verifying active settings with /status
- [Configure permissions](references/claude-code-permissions.md) -- permission system deep dive including tiered permission model (read-only/bash/file modification), permission modes (default, acceptEdits, plan, dontAsk, bypassPermissions), permission rule syntax (Tool, Tool(specifier), wildcards), tool-specific rules for Bash (word boundary, compound commands, security limitations), Read/Edit (gitignore patterns, //path ~/path /path ./path, Windows normalization), WebFetch (domain matching), MCP (server and tool matching), Agent (subagent matching), extending permissions with hooks, working directories (--add-dir, /add-dir, additionalDirectories), permissions and sandboxing interaction, managed-only settings, settings precedence for permissions, example configurations
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) -- server-managed settings for Teams/Enterprise, requirements and setup, admin console configuration, comparison with endpoint-managed settings, settings delivery (fetch at startup, hourly polling, caching behavior), security approval dialogs, access control (Primary Owner, Owner roles), platform availability limitations, audit logging, security considerations (cached file tampering, API unavailability, org switching, custom ANTHROPIC_BASE_URL)
- [Environment variables](references/claude-code-env-vars.md) -- complete reference of 100+ environment variables covering authentication (ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_BASE_URL), model selection (ANTHROPIC_MODEL, ANTHROPIC_DEFAULT_*_MODEL, ANTHROPIC_SMALL_FAST_MODEL), provider configuration (CLAUDE_CODE_USE_BEDROCK/VERTEX/FOUNDRY), telemetry and monitoring (CLAUDE_CODE_ENABLE_TELEMETRY, OTEL_METRICS_EXPORTER), bash tool behavior (BASH_DEFAULT_TIMEOUT_MS, BASH_MAX_TIMEOUT_MS, BASH_MAX_OUTPUT_LENGTH), MCP settings (MCP_TIMEOUT, MCP_TOOL_TIMEOUT, MAX_MCP_OUTPUT_TOKENS), proxy configuration (HTTP_PROXY, HTTPS_PROXY, NO_PROXY), feature flags (DISABLE_AUTOUPDATER, DISABLE_TELEMETRY, CLAUDE_CODE_DISABLE_AUTO_MEMORY), and many more

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
