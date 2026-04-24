---
name: settings-doc
description: Complete official documentation for Claude Code settings — configuration scopes, settings.json keys, permission rules and modes, environment variables, managed/server-managed settings, admin setup, sandbox configuration, and auto mode configuration.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, environment variables, and managed configuration.

## Quick Reference

Claude Code is configured through a layered scope system. Settings in `settings.json` control permissions, environment, hooks, plugins, and more. Managed settings from IT/admins override everything else.

### Configuration scopes and precedence

| Priority | Scope | Location | Shared? |
| :--- | :--- | :--- | :--- |
| 1 (highest) | **Managed** | Server-managed, MDM/OS plist/registry, or managed-settings.json | Yes — deployed by IT |
| 2 | **Command line** | `--permission-mode`, etc. | Session only |
| 3 | **Local** | `.claude/settings.local.json` | No (gitignored) |
| 4 | **Project** | `.claude/settings.json` | Yes — committed to git |
| 5 (lowest) | **User** | `~/.claude/settings.json` | No |

Array settings (e.g., `permissions.allow`, `sandbox.filesystem.allowWrite`) **merge across all scopes** — lower scopes add entries without overriding higher-scope entries.

### Managed settings delivery mechanisms

| Mechanism | Platform | Path | Priority within managed tier |
| :--- | :--- | :--- | :--- |
| Server-managed (Claude.ai admin console) | All | — | Highest |
| macOS plist (`com.anthropic.claudecode`) | macOS | MDM-deployed | High |
| Windows HKLM registry (`HKLM\SOFTWARE\Policies\ClaudeCode`) | Windows | Group Policy / Intune | High |
| File-based `managed-settings.json` | All | macOS: `/Library/Application Support/ClaudeCode/`; Linux/WSL: `/etc/claude-code/`; Windows: `C:\Program Files\ClaudeCode\` | Medium |
| Windows HKCU registry | Windows only | `HKCU\SOFTWARE\Policies\ClaudeCode` | Lowest |

Drop-in directory `managed-settings.d/*.json` is supported alongside `managed-settings.json` (files sorted alphabetically and merged on top). Only one managed source is used; sources do not merge across tiers.

### Other config file locations

| File | Purpose |
| :--- | :--- |
| `~/.claude.json` | OAuth session, MCP server configs (user/local), per-project state, preferences |
| `.mcp.json` | Project-scoped MCP servers |
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Local overrides (gitignored) |

Run `/status` to see which settings sources are active. Run `/config` to open the interactive settings UI.

### Key settings.json options

| Key | Description | Example |
| :--- | :--- | :--- |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `permissions` | Allow/ask/deny rules, defaultMode, sandbox config | See table below |
| `env` | Environment variables applied every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle hook commands | See hooks-doc |
| `language` | Claude's preferred response language | `"japanese"` |
| `autoMode` | Trusted infrastructure for auto mode classifier | See auto mode config |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) | `"stable"` |
| `minimumVersion` | Prevent downgrade below this version | `"2.1.100"` |
| `enabledPlugins` | Enable/disable plugins by `"name@marketplace"` | `{"fmt@team": true}` |
| `extraKnownMarketplaces` | Register additional plugin marketplaces for the repo | See plugins-doc |
| `cleanupPeriodDays` | Days before session files are deleted (default: 30) | `20` |
| `companyAnnouncements` | Messages shown to users at startup | `["Welcome!"]` |
| `outputStyle` | Adjust system prompt output style | `"Explanatory"` |
| `statusLine` | Custom status line script | `{"type": "command", "command": "~/.claude/statusline.sh"}` |
| `fileSuggestion` | Custom `@` file autocomplete command | `{"type": "command", "command": "~/.claude/file-suggestion.sh"}` |
| `attribution` | Git commit and PR attribution text | `{"commit": "...", "pr": ""}` |
| `forceLoginMethod` | Restrict login to `claudeai` or `console` | `"claudeai"` |
| `forceLoginOrgUUID` | Require login to a specific org UUID | `"xxxxxxxx-..."` |
| `tui` | Terminal UI renderer: `"fullscreen"` or `"default"` | `"fullscreen"` |
| `effortLevel` | Persist effort level: `"low"`, `"medium"`, `"high"`, `"xhigh"` | `"xhigh"` |
| `defaultShell` | Default shell: `"bash"` or `"powershell"` | `"powershell"` |
| `sandbox` | Sandboxing configuration | See sandbox table |
| `sshConfigs` | Pre-configured SSH connections for Desktop | `[{"id": "dev", "name": "Dev VM", "sshHost": "user@dev.example.com"}]` |
| `worktree.symlinkDirectories` | Dirs to symlink into worktrees | `["node_modules"]` |
| `worktree.sparsePaths` | Sparse-checkout paths for worktrees | `["packages/my-app"]` |

**Global config settings** (stored in `~/.claude.json`, not `settings.json`):

| Key | Description |
| :--- | :--- |
| `editorMode` | Input key bindings: `"normal"` or `"vim"` |
| `autoConnectIde` | Auto-connect to IDE when launched from external terminal |
| `autoInstallIdeExtension` | Auto-install IDE extension (default: `true`) |
| `autoScrollEnabled` | Follow new output in fullscreen rendering (default: `true`) |
| `showTurnDuration` | Show turn duration messages (default: `true`) |
| `teammateMode` | Agent team display: `"auto"`, `"in-process"`, `"tmux"` |

### Permission settings

| Key | Description | Example |
| :--- | :--- | :--- |
| `permissions.allow` | Rules that allow tool use without prompting | `["Bash(npm run *)"]` |
| `permissions.ask` | Rules that prompt for confirmation | `["Bash(git push *)"]` |
| `permissions.deny` | Rules that block tool use | `["WebFetch", "Read(./.env)"]` |
| `permissions.defaultMode` | Default permission mode | `"acceptEdits"` |
| `permissions.additionalDirectories` | Extra working directories for file access | `["../docs/"]` |
| `permissions.disableBypassPermissionsMode` | Prevent bypass mode: `"disable"` | `"disable"` |
| `permissions.skipDangerousModePermissionPrompt` | Skip bypass mode confirmation prompt | `true` |

**Rule evaluation order: deny → ask → allow. The first matching rule wins.**

### Permission rule syntax

| Pattern | Effect |
| :--- | :--- |
| `Bash` | All bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Bash(git * main)` | Commands like `git checkout main` |
| `Read(./.env)` | Reading `.env` in current directory |
| `Read(//Users/alice/secrets/**)` | Absolute path (note double slash) |
| `Read(~/Documents/*.pdf)` | Home-relative path |
| `Edit(/src/**/*.ts)` | Project-root-relative path |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer` | Any tool from the puppeteer MCP server |
| `Agent(Explore)` | The Explore subagent |

Read/Edit path prefixes: `//path` = absolute, `~/path` = home-relative, `/path` = project-root-relative, `./path` or bare = cwd-relative.

Built-in read-only Bash commands (`ls`, `cat`, `grep`, `find`, `git status`, etc.) never require a permission prompt.

### Permission modes

| Mode | What auto-approves | Best for |
| :--- | :--- | :--- |
| `default` | Read-only operations | Getting started, sensitive work |
| `acceptEdits` | Reads + file edits + common filesystem commands | Iterating on code |
| `plan` | Read-only (Claude can't modify files) | Exploring before changing |
| `auto` | Everything (background classifier checks) | Long tasks, reducing prompts |
| `dontAsk` | Only pre-approved tools from allow rules | Locked-down CI and scripts |
| `bypassPermissions` | Everything except protected paths | Isolated containers/VMs only |

Switch modes with `Shift+Tab` in CLI, or `--permission-mode <mode>` at startup. Set `permissions.defaultMode` in settings for a persistent default.

**Auto mode requirements**: Claude Code v2.1.83+, Max/Team/Enterprise/API plan, supported model (Sonnet 4.6, Opus 4.6, Opus 4.7), Anthropic API only (not Bedrock/Vertex/Foundry), and admin must enable it for Team/Enterprise.

**Protected paths** (never auto-approved in any mode): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`), `.gitconfig`, `.gitmodules`, shell rc files, `.mcp.json`, `.claude.json`.

### Managed-only settings (only read from managed settings)

| Setting | Effect |
| :--- | :--- |
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply; user/project rules ignored |
| `allowManagedHooksOnly` | Only managed hooks, SDK hooks, and managed-plugin hooks load |
| `allowManagedMcpServersOnly` | Only `allowedMcpServers` from managed settings applies |
| `allowedMcpServers` | Allowlist of MCP servers users can configure |
| `deniedMcpServers` | Denylist of MCP servers (takes precedence over allowlist) |
| `blockedMarketplaces` | Blocklist of plugin marketplace sources |
| `strictKnownMarketplaces` | Allowlist of marketplace sources (empty = lockdown) |
| `channelsEnabled` | Allow channels for Team/Enterprise users |
| `allowedChannelPlugins` | Allowlist of channel plugins (requires `channelsEnabled: true`) |
| `forceRemoteSettingsRefresh` | Block startup until remote settings fetched; exit on failure |
| `pluginTrustMessage` | Custom message appended to plugin trust warning |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed `filesystem.allowRead` paths respected |
| `sandbox.network.allowManagedDomainsOnly` | Only managed `allowedDomains` apply; others auto-blocked |
| `wslInheritsWindowsSettings` | WSL reads Windows policy chain (HKLM/file-based only) |

### Sandbox settings (under `permissions.sandbox`)

| Key | Description | Default |
| :--- | :--- | :--- |
| `enabled` | Enable bash sandboxing (macOS, Linux, WSL2) | `false` |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed | `true` |
| `excludedCommands` | Commands that run outside the sandbox | `[]` |
| `allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch | `true` |
| `failIfUnavailable` | Exit if sandbox can't start (managed deployments) | `false` |
| `filesystem.allowWrite` | Paths sandbox can write to | — |
| `filesystem.denyWrite` | Paths sandbox cannot write to | — |
| `filesystem.denyRead` | Paths sandbox cannot read | — |
| `filesystem.allowRead` | Re-allow reads within `denyRead` regions | — |
| `network.allowedDomains` | Allowed outbound domains (supports wildcards) | — |
| `network.deniedDomains` | Blocked outbound domains (merges from all sources) | — |
| `network.allowUnixSockets` | Unix socket paths (macOS only) | — |
| `network.allowLocalBinding` | Allow localhost port binding (macOS only) | `false` |
| `network.httpProxyPort` | HTTP proxy port (bring your own) | — |
| `network.socksProxyPort` | SOCKS5 proxy port | — |

Sandbox path prefixes: `/` = absolute, `~/` = home-relative, `./` or no prefix = project-root-relative (project settings) or `~/.claude`-relative (user settings).

### Auto mode configuration (`autoMode` setting)

| Field | Description |
| :--- | :--- |
| `environment` | Prose descriptions of trusted repos, buckets, domains. Include `"$defaults"` to keep built-in defaults |
| `allow` | Prose exception rules (override `soft_deny`). Include `"$defaults"` to keep built-in exceptions |
| `soft_deny` | Prose block rules. Include `"$defaults"` to keep built-in blocks |

The classifier reads `autoMode` from user settings, local settings, managed settings, and `--settings` flag. It does NOT read from shared project settings (`.claude/settings.json`).

DANGER: omitting `"$defaults"` from any list replaces the entire built-in list for that section. Always include `"$defaults"` unless you intend to fully own the list.

Inspect effective config: `claude auto-mode config` | `claude auto-mode defaults` | `claude auto-mode critique`

### Key environment variables

| Variable | Description |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key (overrides subscription when set) |
| `ANTHROPIC_BASE_URL` | Override API endpoint (proxy/gateway) |
| `ANTHROPIC_MODEL` | Override model |
| `CLAUDE_CODE_USE_BEDROCK` / `_USE_VERTEX` / `_USE_FOUNDRY` | Select cloud provider |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry export (set to `1`) |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Skip writing session transcripts to disk |
| `DISABLE_AUTOUPDATER` | Disable background auto-updates |
| `DISABLE_UPDATES` | Block all updates including manual `claude update` |
| `DISABLE_AUTO_COMPACT` | Disable auto-compaction (manual `/compact` still works) |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess environments |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash timeout (default: 120000ms) |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout (default: 600000ms) |
| `MCP_TIMEOUT` | MCP server startup timeout (default: 30000ms) |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Equivalent to disabling autoupdater, feedback, error reporting, and telemetry |
| `HTTP_PROXY` / `HTTPS_PROXY` / `NO_PROXY` | Proxy configuration |
| `OTEL_METRICS_EXPORTER` | OpenTelemetry metrics exporter |

Environment variables can also be set in `settings.json` under the `env` key to apply them to every session.

### Server-managed settings (Claude.ai admin console)

- Available for Claude for Teams and Enterprise plans
- Delivered at authentication time, refreshed hourly
- Configure at **Admin Settings > Claude Code > Managed settings**
- Supports all `settings.json` keys including hooks, env vars, and managed-only settings
- `forceRemoteSettingsRefresh: true` blocks startup until settings freshly fetched
- Not available when using Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`
- Security approval dialogs shown for shell commands, custom env vars, and hooks
- Audit log events available via compliance API

### Admin setup decisions (quick reference)

| Decision | Options |
| :--- | :--- |
| API provider | Claude for Teams/Enterprise (recommended), Claude Console, Bedrock, Vertex AI, Foundry |
| Settings delivery | Server-managed (Claude.ai console), plist/registry (MDM), file-based managed-settings.json |
| Permission enforcement | `allowManagedPermissionRulesOnly`, `permissions.deny`, sandboxing |
| Usage visibility | OpenTelemetry (`CLAUDE_CODE_ENABLE_TELEMETRY=1`), Analytics dashboard (Anthropic plans only) |
| Data handling | Zero Data Retention available on Enterprise |

Verify managed settings delivery with `/status` — look for `Enterprise managed settings (remote|plist|HKLM|HKCU|file)`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — complete settings.json key reference, configuration scopes, file locations, precedence, sandbox config, attribution settings, file suggestion, hook configuration
- [Set up Claude Code for your organization](references/claude-code-admin-setup.md) — admin decision map covering API providers, managed settings delivery, policy enforcement, usage visibility, and data handling
- [Configure permissions](references/claude-code-permissions.md) — permission system, modes, rule syntax, tool-specific patterns (Bash, Read, Edit, WebFetch, MCP, Agent), working directories, hooks interaction, managed settings
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — Claude.ai admin console delivery, fetch/caching behavior, fail-closed enforcement, security approval dialogs, audit logging
- [Environment variables](references/claude-code-env-vars.md) — complete reference for all environment variables controlling Claude Code behavior
- [Choose a permission mode](references/claude-code-permission-modes.md) — detailed guide to default, acceptEdits, plan, auto, dontAsk, and bypassPermissions modes; how to switch modes; protected paths
- [Configure auto mode](references/claude-code-auto-mode-config.md) — defining trusted infrastructure, overriding block/allow rules, inspecting effective config, reviewing denials

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Set up Claude Code for your organization: https://code.claude.com/docs/en/admin-setup.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
