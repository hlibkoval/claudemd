---
name: settings-doc
description: Complete official documentation for Claude Code settings and configuration — settings files, scopes, precedence, all settings keys, permissions and permission modes, environment variables, managed settings, admin setup, and auto mode configuration.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, and configuration.

## Quick Reference

### Configuration scopes and file locations

| Scope | Location | Shared with team? | Who it affects |
| :--- | :--- | :--- | :--- |
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | Yes (deployed by IT) | All users on the machine |
| **User** | `~/.claude/settings.json` | No | You, across all projects |
| **Project** | `.claude/settings.json` | Yes (committed to git) | All collaborators |
| **Local** | `.claude/settings.local.json` | No (gitignored) | You, in this repository only |

Precedence (highest to lowest): Managed → CLI args → Local → Project → User.

Array settings (e.g. `permissions.allow`, `sandbox.filesystem.allowWrite`) merge and deduplicate across all scopes rather than replacing.

### Settings file quick example

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": ["Bash(npm run lint)", "Bash(npm run test *)"],
    "deny": ["Bash(curl *)", "Read(./.env)", "Read(./.env.*)"]
  },
  "env": { "CLAUDE_CODE_ENABLE_TELEMETRY": "1" }
}
```

### Key settings keys (settings.json)

| Key | Description | Example |
| :--- | :--- | :--- |
| `agent` | Run main thread as a named subagent | `"code-reviewer"` |
| `allowedChannelPlugins` | (Managed) Allowlist of channel plugins that may push messages | `[{"marketplace": "...", "plugin": "telegram"}]` |
| `allowedHttpHookUrls` | Allowlist of URL patterns for HTTP hooks | `["https://hooks.example.com/*"]` |
| `allowedMcpServers` | (Managed) Allowlist of MCP servers | `[{"serverName": "github"}]` |
| `allowManagedHooksOnly` | (Managed) Block all non-managed hooks | `true` |
| `allowManagedMcpServersOnly` | (Managed) Only managed MCP servers apply | `true` |
| `allowManagedPermissionRulesOnly` | (Managed) Block user/project permission rules | `true` |
| `alwaysThinkingEnabled` | Enable extended thinking by default | `true` |
| `apiKeyHelper` | Shell script to generate auth value | `"/bin/gen_key.sh"` |
| `attribution` | Customize git commit and PR attribution | `{"commit": "AI-generated", "pr": ""}` |
| `autoMemoryDirectory` | Custom directory for auto memory storage (not accepted in project settings) | `"~/my-memory-dir"` |
| `autoMode` | Configure auto mode classifier rules (not read from shared project settings) | `{"soft_deny": ["$defaults", "..."]}` |
| `autoScrollEnabled` | In fullscreen rendering, follow new output to the bottom. Default: `true` | `false` |
| `autoUpdatesChannel` | Release channel: `"stable"` or `"latest"` | `"stable"` |
| `availableModels` | Restrict selectable models (does not affect Default option) | `["sonnet", "haiku"]` |
| `awaySummaryEnabled` | Show session recap after returning to terminal. Same as `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` | `true` |
| `awsAuthRefresh` | Custom script that modifies the `.aws` directory for Bedrock credential refresh | `"aws sso login --profile myprofile"` |
| `awsCredentialExport` | Custom script that outputs JSON with AWS credentials | `"/bin/generate_aws_grant.sh"` |
| `blockedMarketplaces` | (Managed) Blocklist of marketplace sources | `[{"source": "github", "repo": "untrusted/plugins"}]` |
| `channelsEnabled` | (Managed) Allow channels for Team/Enterprise users | `true` |
| `cleanupPeriodDays` | Days before session files are deleted (default 30, minimum 1) | `20` |
| `companyAnnouncements` | Startup announcements for users (cycled randomly if multiple) | `["Welcome..."]` |
| `defaultShell` | Default shell for input-box shell commands: `"bash"` or `"powershell"` | `"powershell"` |
| `deniedMcpServers` | (Managed) Denylist of MCP servers | `[{"serverName": "filesystem"}]` |
| `disableAllHooks` | Disable all hooks and custom status line | `true` |
| `disableAutoMode` | Set `"disable"` to prevent auto mode | `"disable"` |
| `disableDeepLinkRegistration` | Set `"disable"` to prevent registering the `claude-cli://` protocol handler | `"disable"` |
| `disabledMcpjsonServers` | Reject specific MCP servers from `.mcp.json` | `["filesystem"]` |
| `disableSkillShellExecution` | Disable inline shell execution in skills/commands from user/project/plugin sources | `true` |
| `editorMode` | Key binding mode: `"normal"` or `"vim"` | `"vim"` |
| `effortLevel` | Persist effort level across sessions | `"xhigh"` |
| `enableAllProjectMcpServers` | Auto-approve all `.mcp.json` servers | `true` |
| `enabledMcpjsonServers` | List of specific `.mcp.json` servers to approve | `["memory", "github"]` |
| `env` | Environment variables for every session | `{"FOO": "bar"}` |
| `fastModePerSessionOptIn` | When `true`, fast mode does not persist across sessions | `true` |
| `feedbackSurveyRate` | Probability (0–1) for session quality surveys. Set `0` to suppress entirely | `0.05` |
| `fileSuggestion` | Custom command for `@` file path autocomplete | `{"type": "command", "command": "~/.claude/file-suggestion.sh"}` |
| `forceLoginMethod` | Restrict login to `claudeai` or `console` | `"claudeai"` |
| `forceLoginOrgUUID` | Require login to a specific org UUID (string or array of UUIDs) | `"xxxxxxxx-..."` |
| `forceRemoteSettingsRefresh` | (Managed) Block startup until settings freshly fetched | `true` |
| `hooks` | Custom lifecycle event commands | See hooks docs |
| `httpHookAllowedEnvVars` | Allowlist of env var names HTTP hooks may interpolate into headers | `["MY_TOKEN", "HOOK_SECRET"]` |
| `includeGitInstructions` | Include built-in git workflow instructions (default: `true`) | `false` |
| `language` | Claude's preferred response language | `"japanese"` |
| `minimumVersion` | Floor for auto-updates | `"2.1.100"` |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `modelOverrides` | Map model IDs to provider-specific IDs | `{"claude-opus-4-6": "arn:..."}` |
| `otelHeadersHelper` | Script to generate dynamic OpenTelemetry headers | `"/bin/generate_otel_headers.sh"` |
| `outputStyle` | Configure output style | `"Explanatory"` |
| `permissions` | Permission rules (see table below) | |
| `plansDirectory` | Where plan files are stored (relative to project root). Default: `~/.claude/plans` | `"./plans"` |
| `pluginTrustMessage` | (Managed) Custom message appended to plugin trust warning | `"Plugins from our marketplace are vetted"` |
| `preferredNotifChannel` | Notification method: `"auto"`, `"terminal_bell"`, `"iterm2"`, `"kitty"`, `"ghostty"`, `"notifications_disabled"` | `"terminal_bell"` |
| `prefersReducedMotion` | Reduce or disable UI animations for accessibility | `true` |
| `prUrlTemplate` | URL template for PR badge in footer | `"https://reviews.example.com/{owner}/{repo}/pull/{number}"` |
| `respectGitignore` | Control whether `@` file picker respects `.gitignore` (default: `true`) | `false` |
| `showClearContextOnPlanAccept` | Show "clear context" option on plan accept screen (default: `false`) | `true` |
| `showThinkingSummaries` | Show extended thinking summaries in interactive sessions (default: `false`) | `true` |
| `showTurnDuration` | Show turn duration messages (default: `true`) | `false` |
| `skipWebFetchPreflight` | Skip WebFetch domain safety check | `true` |
| `spinnerTipsEnabled` | Show tips in spinner (default: `true`) | `false` |
| `spinnerTipsOverride` | Override spinner tips with custom strings | `{"excludeDefault": true, "tips": ["Use internal tool X"]}` |
| `spinnerVerbs` | Customize action verbs in spinner and turn duration messages | `{"mode": "append", "verbs": ["Pondering"]}` |
| `sshConfigs` | SSH connections for Desktop environment dropdown (managed and user settings only) | `[{"id": "dev-vm", "name": "Dev VM", "sshHost": "user@dev.example.com"}]` |
| `statusLine` | Custom status line command | `{"type": "command", "command": "~/.claude/statusline.sh"}` |
| `strictKnownMarketplaces` | (Managed) Allowlist of permitted marketplace sources | `[{"source": "github", "repo": "acme-corp/plugins"}]` |
| `teammateMode` | Agent team display mode: `"auto"`, `"in-process"`, or `"tmux"` | `"in-process"` |
| `terminalProgressBarEnabled` | Show terminal progress bar (default: `true`) | `false` |
| `tui` | Terminal UI renderer: `"fullscreen"` or `"default"` | `"fullscreen"` |
| `useAutoModeDuringPlan` | Plan mode uses auto mode semantics (default: `true`, not from shared project settings) | `false` |
| `viewMode` | Default transcript view: `"default"`, `"verbose"`, or `"focus"` | `"verbose"` |
| `voice` | Voice dictation settings: `enabled`, `mode` (`"hold"` or `"tap"`), `autoSubmit` | `{"enabled": true, "mode": "tap"}` |
| `voiceEnabled` | Legacy alias for `voice.enabled`. Prefer the `voice` object | `true` |
| `wslInheritsWindowsSettings` | (Windows managed) Extend Windows policy to WSL | `true` |

### Permission settings (under `permissions` key)

| Key | Description | Example |
| :--- | :--- | :--- |
| `allow` | Rules to allow without prompting | `["Bash(git diff *)"]` |
| `ask` | Rules to always prompt for | `["Bash(git push *)"]` |
| `deny` | Rules to always block | `["WebFetch", "Read(./.env)"]` |
| `additionalDirectories` | Extra directories for file access | `["../docs/"]` |
| `defaultMode` | Default permission mode | `"acceptEdits"` |
| `disableBypassPermissionsMode` | Set `"disable"` to block bypass mode (works from any scope) | `"disable"` |
| `skipDangerousModePermissionPrompt` | Skip bypass-mode confirmation prompt (ignored in project settings) | `true` |

### Permission rule syntax

Rules follow the format `Tool` or `Tool(specifier)`. Evaluation order: deny → ask → allow. First match wins.

| Pattern | Effect |
| :--- | :--- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Bash(git * main)` | Commands like `git checkout main` |
| `Read(./.env)` | Reading the `.env` file |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer` | All tools from the puppeteer MCP server |
| `Agent(Explore)` | The Explore subagent |

Read/Edit path patterns: `//path` = absolute, `~/path` = home-relative, `/path` = project-relative, `path` or `./path` = cwd-relative.

Bash rules: `*` matches any sequence including spaces. Space before `*` enforces word boundary (`Bash(ls *)` matches `ls -la` but not `lsof`). Recognized process wrappers (`timeout`, `time`, `nice`, `nohup`, `stdbuf`, bare `xargs`) are stripped before matching. Compound commands must be matched subcommand-by-subcommand.

### Permission modes

| Mode | What runs without asking | Best for |
| :--- | :--- | :--- |
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands | Iterating on code |
| `plan` | Reads only (no edits) | Exploring before changing |
| `auto` | Everything, with background classifier checks | Long tasks, reducing prompts |
| `dontAsk` | Only pre-approved tools | Locked-down CI and scripts |
| `bypassPermissions` | Everything | Isolated containers/VMs only |

Switch with `Shift+Tab` in the CLI or `--permission-mode <mode>` flag. Set persistent default via `permissions.defaultMode` in settings.

Auto mode requirements: Max (Opus 4.7 only)/Team/Enterprise/API plan; supported model (Sonnet 4.6, Opus 4.6, or Opus 4.7 on Team/Enterprise/API; Opus 4.7 only on Max); Anthropic API only (not Bedrock/Vertex/Foundry); admin-enabled on Team/Enterprise.

Auto mode uses a classifier that blocks: `curl | bash`, sending sensitive data externally, production deploys/migrations, mass cloud deletion, IAM permission grants, force-push/push to `main`, and irreversible file destruction. Boundaries stated in conversation also block matching actions.

### Sandbox settings (under `sandbox` key)

| Key | Description |
| :--- | :--- |
| `enabled` | Enable bash sandboxing (macOS, Linux, WSL2) |
| `failIfUnavailable` | Exit if sandbox cannot start (for managed deployments) |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: `true`) |
| `excludedCommands` | Commands that run outside the sandbox |
| `allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape (default: `true`) |
| `filesystem.allowWrite` | Paths sandboxed commands can write (merged across all scopes) |
| `filesystem.denyWrite` | Paths sandboxed commands cannot write |
| `filesystem.denyRead` | Paths sandboxed commands cannot read |
| `filesystem.allowRead` | Re-allow read within denyRead regions |
| `filesystem.allowManagedReadPathsOnly` | (Managed) Only managed `allowRead` paths apply |
| `network.allowedDomains` | Domains allowed for outbound traffic |
| `network.deniedDomains` | Domains blocked (takes precedence over `allowedDomains`) |
| `network.allowManagedDomainsOnly` | (Managed) Only managed `allowedDomains` apply |
| `network.allowUnixSockets` | (macOS) Unix socket paths accessible in sandbox |
| `network.allowAllUnixSockets` | Allow all Unix socket connections |
| `network.allowLocalBinding` | Allow binding to localhost ports (macOS only) |
| `network.allowMachLookup` | Additional XPC/Mach service names (macOS only) |
| `network.httpProxyPort` | HTTP proxy port for sandbox |
| `network.socksProxyPort` | SOCKS5 proxy port for sandbox |
| `enableWeakerNestedSandbox` | (Linux/WSL2) Weaker sandbox for unprivileged Docker. Reduces security. |
| `enableWeakerNetworkIsolation` | (macOS) Allow `com.apple.trustd.agent` TLS trust service. Reduces security. |

Sandbox path prefixes: `/path` = absolute, `~/path` = home-relative, `./path` or bare = project-relative (project settings) or `~/.claude`-relative (user settings).

### Worktree settings

| Key | Description | Example |
| :--- | :--- | :--- |
| `worktree.symlinkDirectories` | Directories to symlink into each worktree | `["node_modules", ".cache"]` |
| `worktree.sparsePaths` | Paths to check out via sparse-checkout | `["packages/my-app"]` |

### Attribution settings (under `attribution` key)

| Key | Description |
| :--- | :--- |
| `commit` | Attribution for git commits (supports git trailers). Empty string hides. |
| `pr` | Attribution for pull request descriptions. Empty string hides. |

### Plugin settings (under settings.json)

| Key | Description |
| :--- | :--- |
| `enabledPlugins` | Map of `"plugin@marketplace": true/false` |
| `extraKnownMarketplaces` | Register additional marketplaces for team use (auto-installs on trust) |
| `strictKnownMarketplaces` | (Managed) Allowlist of permitted marketplace sources |
| `blockedMarketplaces` | (Managed) Blocklist of marketplace sources |

`strictKnownMarketplaces` uses direct source objects; `extraKnownMarketplaces` uses named marketplaces with nested source. Combine both in managed settings to restrict and pre-register simultaneously.

### Global config settings (stored in `~/.claude.json`, not settings.json)

| Key | Description |
| :--- | :--- |
| `autoConnectIde` | Auto-connect to running IDE on startup (default: `false`) |
| `autoInstallIdeExtension` | Auto-install IDE extension in VS Code terminal (default: `true`) |
| `externalEditorContext` | Prepend last response as context in external editor (default: `false`) |

### Managed settings delivery mechanisms

| Mechanism | Location | Priority | Platforms |
| :--- | :--- | :--- | :--- |
| Server-managed | Claude.ai admin console | Highest | All |
| plist/registry | macOS `com.anthropic.claudecode` plist / Windows `HKLM\SOFTWARE\Policies\ClaudeCode` | High | macOS, Windows |
| File-based | `/Library/Application Support/ClaudeCode/` (macOS), `/etc/claude-code/` (Linux/WSL), `C:\Program Files\ClaudeCode\` (Windows) | Medium | All |
| Windows user registry | `HKCU\SOFTWARE\Policies\ClaudeCode` | Lowest | Windows only |

Server-managed settings require Teams/Enterprise plan and `api.anthropic.com` access. Not available on Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`.

File-based managed settings also support a `managed-settings.d/` drop-in directory: files sorted alphabetically and merged on top of `managed-settings.json`. Arrays concatenate and deduplicate; scalars: later wins; objects: deep-merged. Use numeric prefixes (e.g. `10-telemetry.json`) to control merge order.

Within the managed tier: server-managed > MDM/OS-level > file-based > HKCU. Only one managed source is used; sources do not merge across tiers (except file-based tier which merges base + drop-ins).

### Managed-only settings (only effective in managed settings)

`allowedChannelPlugins`, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowManagedPermissionRulesOnly`, `blockedMarketplaces`, `channelsEnabled`, `forceRemoteSettingsRefresh`, `pluginTrustMessage`, `sandbox.filesystem.allowManagedReadPathsOnly`, `sandbox.network.allowManagedDomainsOnly`, `strictKnownMarketplaces`, `wslInheritsWindowsSettings`

Note: `disableBypassPermissionsMode` is typically placed in managed settings but works from any scope.

### Auto mode configuration (`autoMode` key)

| Field | Description |
| :--- | :--- |
| `environment` | Prose descriptions of trusted repos, buckets, domains. Include `"$defaults"` to keep built-in list. |
| `allow` | Prose exception rules overriding `soft_deny` blocks. Include `"$defaults"` to keep built-in exceptions. |
| `soft_deny` | Prose block rules. Include `"$defaults"` to keep built-in blocks. Omitting `"$defaults"` discards all built-in blocks. |

Warning: Omitting `"$defaults"` from `soft_deny` discards all built-in block rules (force push, data exfiltration, `curl | bash`, production deploys, etc.).

`autoMode` is NOT read from shared project settings (`.claude/settings.json`) — only from user, local, managed, and `--settings` flag. CLI: `claude auto-mode defaults`, `claude auto-mode config`, `claude auto-mode critique`.

### Key environment variables

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key (overrides subscription login) |
| `ANTHROPIC_BASE_URL` | Override API endpoint (proxy/gateway) |
| `ANTHROPIC_MODEL` | Override model selection |
| `ANTHROPIC_BETAS` | Comma-separated additional `anthropic-beta` header values |
| `ANTHROPIC_CUSTOM_HEADERS` | Custom headers (`Name: Value`, newline-separated) |
| `API_TIMEOUT_MS` | API request timeout in ms (default: 600000) |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Maximum bash command timeout (default: 600000) |
| `BASH_MAX_OUTPUT_LENGTH` | Maximum characters in bash output before truncation |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry (required before OTel config) |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Skip writing session transcripts to disk |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess environments |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable autoupdater, feedback, error reporting, telemetry |
| `CLAUDE_CODE_DISABLE_CLAUDE_MDS` | Prevent loading any CLAUDE.md memory files |
| `CLAUDE_CODE_DISABLE_THINKING` | Force-disable extended thinking |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level (`low`, `medium`, `high`, `xhigh`, `max`, `auto`) |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Maximum output tokens for most requests |
| `CLAUDE_CODE_MAX_RETRIES` | Override number of API retry attempts (default: 10) |
| `CLAUDE_CODE_SHELL` | Override automatic shell detection |
| `CLAUDE_CODE_SHELL_PREFIX` | Command prefix to wrap all bash commands (for logging/auditing) |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `DISABLE_AUTOUPDATER` | Disable background auto-updates |
| `DISABLE_AUTO_COMPACT` | Disable automatic compaction only |
| `DISABLE_COMPACT` | Disable all compaction (auto and manual) |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching for all models |
| `DISABLE_TELEMETRY` | Opt out of Statsig telemetry |
| `DISABLE_UPDATES` | Block all updates including manual `claude update` |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server for network connections |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Context capacity percentage (1–100) at which auto-compaction triggers |
| `CLAUDE_CODE_DISABLE_FAST_MODE` | Disable fast mode |
| `CLAUDE_ENV_FILE` | Shell script run before each Bash command (for virtualenv/conda) |
| `OTEL_LOG_RAW_API_BODIES` | Emit API request/response JSON as log events |
| `OTEL_LOG_TOOL_CONTENT` | Include tool input/output in OTel span events |

See the full environment variables reference for the complete list of 100+ variables.

### Admin deployment decisions

| Decision | Key settings |
| :--- | :--- |
| Permission rules | `permissions.allow`, `permissions.deny` |
| Permission lockdown | `allowManagedPermissionRulesOnly`, `permissions.disableBypassPermissionsMode` |
| Sandboxing | `sandbox.enabled`, `sandbox.network.allowedDomains` |
| MCP server control | `allowedMcpServers`, `deniedMcpServers`, `allowManagedMcpServersOnly` |
| Plugin marketplace control | `strictKnownMarketplaces`, `blockedMarketplaces` |
| Hook restrictions | `allowManagedHooksOnly`, `allowedHttpHookUrls` |
| Version floor | `minimumVersion` |
| Fail-closed startup | `forceRemoteSettingsRefresh` |
| Org-wide instructions | Deploy `CLAUDE.md` to managed policy path |
| Restrict auto mode | `disableAutoMode: "disable"` |
| Restrict login | `forceLoginMethod`, `forceLoginOrgUUID` |

Verify managed settings are active: run `/status` inside Claude Code and look for `Enterprise managed settings (remote|plist|HKLM|HKCU|file)`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Settings reference](references/claude-code-settings.md) — all settings keys, scopes, file locations, plugin settings, sandbox settings, attribution, hook configuration, settings precedence, and system prompt notes
- [Admin setup guide](references/claude-code-admin-setup.md) — decision map for org deployments: choosing API provider, settings delivery mechanisms, enforcement controls, usage visibility, and data handling
- [Permissions reference](references/claude-code-permissions.md) — permission system, permission rule syntax, tool-specific rules (Bash, PowerShell, Read/Edit, WebFetch, MCP, Agent), working directories, sandbox interaction, and managed settings
- [Permission modes reference](references/claude-code-permission-modes.md) — all modes (default/acceptEdits/plan/auto/dontAsk/bypassPermissions), switching modes, auto mode requirements and classifier behavior, protected paths
- [Server-managed settings](references/claude-code-server-managed-settings.md) — configuring settings via Claude.ai admin console, delivery/caching/precedence, security approval dialogs, fail-closed enforcement, audit logging
- [Auto mode configuration](references/claude-code-auto-mode-config.md) — defining trusted infrastructure, overriding block/allow rules, CLI subcommands for inspecting config, reviewing denials
- [Environment variables reference](references/claude-code-env-vars.md) — complete reference for all environment variables controlling Claude Code behavior

## Sources

- Settings reference: https://code.claude.com/docs/en/settings.md
- Admin setup guide: https://code.claude.com/docs/en/admin-setup.md
- Permissions reference: https://code.claude.com/docs/en/permissions.md
- Server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables reference: https://code.claude.com/docs/en/env-vars.md
- Permission modes reference: https://code.claude.com/docs/en/permission-modes.md
- Auto mode configuration: https://code.claude.com/docs/en/auto-mode-config.md
