---
name: settings-doc
description: Complete official documentation for Claude Code settings — configuration scopes, settings.json keys, permission rules and modes, managed settings, server-managed settings, environment variables, auto mode configuration, and admin deployment. Use when working with settings files, permission rules, managed policy, env vars, permission modes, or org-wide deployment.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, permission modes, environment variables, and admin deployment.

## Quick Reference

### Configuration scopes

| Scope | Location | Shared with team? | Override priority |
| :--- | :--- | :--- | :--- |
| **Managed** | Server-managed, MDM/plist/registry, or system `managed-settings.json` | Yes (deployed by IT) | Highest — cannot be overridden |
| **Local** | `.claude/settings.local.json` | No | Overrides project and user |
| **Project** | `.claude/settings.json` | Yes (git) | Overrides user |
| **User** | `~/.claude/settings.json` | No | Lowest |

Command-line arguments (`--settings`, `--permission-mode`) slot between Managed and Local.

Array-valued settings (e.g. `permissions.allow`, `sandbox.filesystem.allowWrite`) **concatenate and deduplicate** across scopes rather than override. Exceptions: `fallbackModel` (highest-precedence file wins) and `availableModels` (managed value replaces lower-precedence entries).

### Managed settings delivery mechanisms

| Mechanism | Path / location | Priority |
| :--- | :--- | :--- |
| Server-managed (claude.ai admin console) | Delivered at auth time | Highest |
| macOS MDM plist | `com.anthropic.claudecode` managed preferences | High |
| Windows HKLM registry | `HKLM\SOFTWARE\Policies\ClaudeCode` (JSON in `Settings` value) | High |
| File-based — macOS | `/Library/Application Support/ClaudeCode/managed-settings.json` | Medium |
| File-based — Linux/WSL | `/etc/claude-code/managed-settings.json` | Medium |
| File-based — Windows | `C:\Program Files\ClaudeCode\managed-settings.json` | Medium |
| Windows HKCU registry | `HKCU\SOFTWARE\Policies\ClaudeCode` | Lowest managed |

Drop-in directory `managed-settings.d/` alongside `managed-settings.json` is supported; files are merged alphabetically, later files override earlier ones for scalars, arrays concatenate.

Within the managed tier only one source is used (no cross-tier merge). Server-managed settings take precedence over endpoint-managed settings; if server delivers any keys at all, endpoint sources are ignored.

### Key settings.json fields

| Key | Description | Example |
| :--- | :--- | :--- |
| `permissions` | Allow/deny/ask rules, defaultMode, sandbox, etc. | See below |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `availableModels` | Restrict selectable models | `["sonnet", "haiku"]` |
| `enforceAvailableModels` | Constrain default model to allowlist too (v2.1.175+) | `true` |
| `fallbackModel` | Fallback chain when primary is overloaded | `["claude-sonnet-4-6", "claude-haiku-4-5"]` |
| `advisorModel` | Model for the advisor tool | `"opus"` |
| `agent` | Run main thread as a named subagent | `"code-reviewer"` |
| `effortLevel` | Persist effort level: `low`, `medium`, `high`, `xhigh` | `"xhigh"` |
| `alwaysThinkingEnabled` | Enable extended thinking by default | `true` |
| `autoCompactEnabled` | Auto-compact when context nears limit (default: `true`) | `false` |
| `fileCheckpointingEnabled` | Snapshot files for `/rewind` (default: `true`) | `false` |
| `autoMode` | Configure auto mode classifier rules | `{"environment": [...]}` |
| `disableAutoMode` | Prevent auto mode activation | `"disable"` |
| `autoUpdatesChannel` | `"latest"` (default) or `"stable"` | `"stable"` |
| `minimumVersion` | Floor for auto-update and `claude update` | `"2.1.100"` |
| `requiredMinimumVersion` | Hard minimum — blocks startup if below | `"2.1.150"` |
| `requiredMaximumVersion` | Hard maximum — blocks startup if above (managed only) | `"2.1.150"` |
| `hooks` | Lifecycle hook definitions | See hooks-doc |
| `env` | Environment variables for every session | `{"FOO": "bar"}` |
| `apiKeyHelper` | Script to generate auth token | `"/bin/gen-key.sh"` |
| `theme` | UI color theme | `"dark"` / `"auto"` |
| `editorMode` | Input key binding mode: `"normal"` or `"vim"` | `"vim"` |
| `language` | Claude's preferred response language | `"japanese"` |
| `outputStyle` | System prompt output style | `"Explanatory"` |
| `tui` | Renderer: `"fullscreen"` or `"default"` | `"fullscreen"` |
| `verbose` | Show full tool output | `true` |
| `statusLine` | Custom status line command | `{"type": "command", "command": "~/.claude/statusline.sh"}` |
| `companyAnnouncements` | Messages shown at startup | `["Welcome to Acme Corp!"]` |
| `claudeMd` | Org-wide CLAUDE.md text (managed only) | `"Always run make lint before committing."` |
| `claudeMdExcludes` | Glob patterns to skip CLAUDE.md files | `["**/vendor/**/CLAUDE.md"]` |
| `cleanupPeriodDays` | Session file retention days (default: 30) | `20` |
| `worktree.baseRef` | Branch new worktrees from: `"fresh"` or `"head"` | `"head"` |
| `worktree.symlinkDirectories` | Dirs to symlink into worktrees | `["node_modules"]` |
| `worktree.bgIsolation` | Background session isolation: `"worktree"` or `"none"` | `"none"` |
| `sandbox` | Sandboxing configuration | See sandbox section |
| `attribution` | Git commit and PR attribution strings | `{"commit": "...", "pr": ""}` |
| `enabledPlugins` | Enable/disable plugins per scope | `{"myplugin@mktplace": true}` |
| `extraKnownMarketplaces` | Register team marketplaces | See plugins-doc |
| `strictKnownMarketplaces` | Managed allowlist of marketplace sources | See plugins-doc |
| `strictPluginOnlyCustomization` | Block user/project skills, agents, hooks, MCP (managed only) | `["skills", "hooks"]` |
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply (managed only) | `true` |
| `allowManagedMcpServersOnly` | Only managed MCP server allowlist applies (managed only) | `true` |
| `allowManagedHooksOnly` | Only managed/SDK/approved-plugin hooks load (managed only) | `true` |
| `allowedMcpServers` | Allowlist of MCP servers (managed only) | `[{"serverName": "github"}]` |
| `deniedMcpServers` | Denylist of MCP servers (managed only) | `[{"serverName": "filesystem"}]` |
| `forceLoginMethod` | Restrict login to `claudeai` or `console` | `"claudeai"` |
| `forceLoginOrgUUID` | Require login to specific org UUID(s) | `"xxxx-xxxx-..."` |
| `forceRemoteSettingsRefresh` | Block startup until remote settings fetched (managed only) | `true` |
| `parentSettingsBehavior` | How embedder settings interact with admin tier (v2.1.133+) | `"merge"` |
| `policyHelper` | Admin executable that computes managed settings dynamically | `{"path": "/usr/local/bin/claude-policy"}` |
| `disableAgentView` | Disable background agent view | `true` |
| `disableBundledSkills` | Remove bundled skills/workflows | `true` |
| `disableSkillShellExecution` | Block inline shell in skills (managed use) | `true` |
| `disableRemoteControl` | Disable Remote Control feature (v2.1.128+) | `true` |
| `disableAllHooks` | Disable all hooks and custom status line | `true` |
| `disableDeepLinkRegistration` | Prevent claude-cli:// protocol handler registration | `"disable"` |
| `disableBypassPermissionsMode` (under `permissions`) | Block bypassPermissions mode | `"disable"` |
| `disableAutoMode` (under `permissions`) | Block auto mode | `"disable"` |
| `preferredNotifChannel` | Notification method | `"terminal_bell"` |
| `agentPushNotifEnabled` | Mobile push when task finishes (v2.1.119+) | `true` |
| `inputNeededNotifEnabled` | Mobile push when input needed (v2.1.119+) | `true` |
| `skipWebFetchPreflight` | Skip WebFetch domain safety check | `true` |
| `sshConfigs` | Pre-configured SSH connections for Desktop | `[{"id": "dev-vm", "name": "Dev VM", "sshHost": "user@dev.example.com"}]` |
| `wslInheritsWindowsSettings` | WSL reads Windows managed settings (Windows managed only) | `true` |

Settings read once at session start (require restart to change): `model`, `outputStyle`.

### Permission settings

| Key | Description | Example |
| :--- | :--- | :--- |
| `permissions.allow` | Allow rules — skip prompt | `["Bash(npm run *)", "Read(~/.zshrc)"]` |
| `permissions.ask` | Ask rules — force confirmation | `["Bash(git push *)"]` |
| `permissions.deny` | Deny rules — block entirely | `["WebFetch", "Bash(curl *)", "Read(./.env)"]` |
| `permissions.defaultMode` | Default permission mode | `"acceptEdits"` |
| `permissions.additionalDirectories` | Extra directories for file access | `["../docs/"]` |
| `permissions.disableBypassPermissionsMode` | Block bypassPermissions mode | `"disable"` |
| `permissions.skipDangerousModePermissionPrompt` | Skip bypass-permissions confirmation | `true` |

### Permission rule syntax

Format: `Tool` or `Tool(specifier)`. Rules evaluated: deny first, then ask, then allow. First match wins.

| Rule | Effect |
| :--- | :--- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Bash(git * main)` | Commands matching `git <anything> main` |
| `Read(./.env)` | Reading the `.env` file |
| `Read(~/.zshrc)` | Reading home `.zshrc` |
| `Read(//**/.env)` | Any `.env` anywhere on filesystem |
| `Edit(/src/**/*.ts)` | Edits under project `src/` |
| `WebFetch(domain:example.com)` | Fetch to example.com |
| `WebFetch(domain:*.example.com)` | Fetch to any subdomain |
| `mcp__github__get_*` | Any `get_` tool from the github MCP server |
| `mcp__*` | All MCP tools (deny/ask only) |
| `Agent(Explore)` | The Explore subagent |
| `*` | All tools (deny/ask only) |

Read/Edit path anchors: `//path` = absolute; `~/path` = home-relative; `/path` = project-root-relative; `path` or `./path` = cwd-relative. `*` matches within one segment; `**` matches across directories.

Bash compound commands: rules match each subcommand independently. Shell operators `&&`, `||`, `;`, `|` split into subcommands.

Bash process wrappers stripped before matching: `timeout`, `time`, `nice`, `nohup`, `stdbuf`, bare `xargs`. Read-only built-ins (`ls`, `cat`, `grep`, `find`, etc.) run without prompts.

### Permission modes

| Mode | What runs without asking | Set via |
| :--- | :--- | :--- |
| `default` | Reads only | Shift+Tab cycle |
| `acceptEdits` | Reads, file edits, common filesystem commands | Shift+Tab |
| `plan` | Reads only (no edits) | Shift+Tab or `/plan` prefix |
| `auto` | Everything, with background classifier safety checks | Shift+Tab (requires admin enable on Teams/Enterprise) |
| `dontAsk` | Only pre-approved tools | `--permission-mode dontAsk` |
| `bypassPermissions` | Everything (containers/VMs only) | `--permission-mode bypassPermissions` |

Set persistent default: `permissions.defaultMode` in settings.

`auto` mode is ignored when set in `.claude/settings.json` or `.claude/settings.local.json` (cannot be self-granted by a repo). Set it in `~/.claude/settings.json` or managed settings.

### Auto mode classifier configuration

The `autoMode` settings block (user, local, or managed settings — NOT shared project settings):

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp and all repos under it",
      "Trusted cloud buckets: s3://acme-build-artifacts",
      "Trusted internal domains: *.corp.example.com"
    ],
    "allow": ["$defaults", "Deploying to staging is allowed"],
    "soft_deny": ["$defaults", "Never run database migrations outside the migrations CLI"],
    "hard_deny": ["$defaults", "Never send repository contents to third-party code-review APIs"]
  }
}
```

Include `"$defaults"` in each array to inherit built-in rules. Omitting it replaces the entire default list for that section. Entries are natural-language prose. CLI tools: `claude auto-mode defaults`, `claude auto-mode config`, `claude auto-mode critique`.

### Sandbox settings (under `sandbox`)

| Key | Description |
| :--- | :--- |
| `enabled` | Enable OS-level bash sandboxing (macOS, Linux, WSL2) |
| `failIfUnavailable` | Exit at startup if sandbox can't start |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `excludedCommands` | Commands that run outside the sandbox |
| `allowUnsandboxedCommands` | Allow the dangerouslyDisableSandbox escape hatch (default: true) |
| `filesystem.allowWrite` | Paths where sandboxed commands may write |
| `filesystem.denyWrite` | Paths where sandboxed commands may not write |
| `filesystem.denyRead` | Paths where sandboxed commands may not read |
| `filesystem.allowRead` | Re-allow reading within `denyRead` regions |
| `filesystem.allowManagedReadPathsOnly` | Only managed `allowRead` paths respected (managed only) |
| `network.allowedDomains` | Domains allowed for outbound traffic |
| `network.deniedDomains` | Domains blocked for outbound traffic |
| `network.allowManagedDomainsOnly` | Only managed allowed domains (managed only) |
| `network.allowUnixSockets` | Unix socket paths allowed (macOS only) |
| `network.allowAllUnixSockets` | Allow all Unix sockets (Linux/WSL2 use this) |
| `network.allowLocalBinding` | Allow binding to localhost ports (macOS only) |
| `network.httpProxyPort` / `network.socksProxyPort` | Bring-your-own proxy ports |

Sandbox path prefixes: `/` = absolute; `~/` = home-relative; `./` or no prefix = project-root (project settings) or `~/.claude` (user settings).

### Key environment variables

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key (overrides subscription even when logged in) |
| `ANTHROPIC_MODEL` | Override model for session |
| `ANTHROPIC_BASE_URL` | Route requests through a proxy or gateway |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_ENABLE_AUTO_MODE` | Enable auto mode on Bedrock/Vertex/Foundry |
| `CLAUDE_CODE_EFFORT_LEVEL` | Effort level: `low`, `medium`, `high`, `xhigh`, `max`, `auto` |
| `MAX_THINKING_TOKENS` | Extended thinking token budget; `0` disables (Anthropic API) |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | Credential refresh interval for `apiKeyHelper` |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_DISABLE_BUNDLED_SKILLS` | Disable bundled skills/workflows |
| `CLAUDE_CODE_DISABLE_AGENT_VIEW` | Disable background agent view |
| `CLAUDE_CODE_DISABLE_WORKFLOWS` | Disable dynamic workflows |
| `CLAUDE_CODE_NO_FLICKER` / `tui` setting | Enable fullscreen renderer |
| `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN` | Force classic main-screen renderer |
| `CLAUDE_CODE_DISABLE_FILE_CHECKPOINTING` | Disable file checkpointing |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry data collection |
| `DISABLE_AUTOUPDATER` | Disable background auto-updates |
| `DISABLE_AUTO_COMPACT` | Disable automatic compaction |
| `DISABLE_TELEMETRY` / `DO_NOT_TRACK` | Opt out of telemetry |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess environments |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Maximum bash timeout (default: 600000) |
| `API_TIMEOUT_MS` | API request timeout (default: 600000) |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `CLAUDE_CODE_SAFE_MODE` | Start with plugins/hooks/skills disabled for troubleshooting |
| `CLAUDECODE` | Set to `1` in subprocesses Claude spawns (detect Claude environment) |
| `CLAUDE_CODE_CHILD_SESSION` | Set to `1` only in direct Bash/hook subprocesses (v2.1.172+) |
| `HTTP_PROXY` / `HTTPS_PROXY` | HTTP/HTTPS proxy for network connections |

Set env vars persistently via the `env` key in settings.json. Shell env vars override settings.json env vars for most keys. Exception: `ANTHROPIC_MODEL` overrides `model` setting, and `CLAUDE_CODE_EFFORT_LEVEL` overrides `effortLevel` setting and `/effort` command.

### Server-managed settings

Available on Claude for Teams and Enterprise (v2.1.38+ for Teams, v2.1.30+ for Enterprise). Configured in the Claude.ai admin console at **Admin Settings > Claude Code > Managed settings**.

- Settings are fetched at startup and polled hourly during active sessions
- Require network access to `api.anthropic.com`
- Not available on Bedrock, Vertex AI, Foundry, or custom `ANTHROPIC_BASE_URL`
- Shell command settings, custom env vars, and hooks require user approval dialog
- Security-sensitive invalid fields fail closed; all other invalid entries are stripped and remaining valid settings still apply
- Set `forceRemoteSettingsRefresh: true` to block startup until fresh settings are fetched

### Admin deployment decision map

| Decision | Key settings |
| :--- | :--- |
| Choose API provider | Claude for Teams/Enterprise, Console, Bedrock, Vertex, Foundry |
| Deliver managed settings | Server-managed (Teams/Enterprise) or file-based/plist/registry (any provider) |
| Enforce permissions | `permissions.allow`, `permissions.deny`, `allowManagedPermissionRulesOnly` |
| Disable bypass mode | `permissions.disableBypassPermissionsMode: "disable"` |
| Sandbox execution | `sandbox.enabled`, `sandbox.network.allowedDomains` |
| Restrict MCP servers | `allowedMcpServers`, `deniedMcpServers`, `allowManagedMcpServersOnly` |
| Restrict plugins/marketplaces | `strictKnownMarketplaces`, `blockedMarketplaces` |
| Lock customization to plugins | `strictPluginOnlyCustomization` |
| Restrict hooks | `allowManagedHooksOnly`, `allowedHttpHookUrls` |
| Org-wide CLAUDE.md | `claudeMd` in managed settings |
| Version floor/ceiling | `requiredMinimumVersion`, `requiredMaximumVersion` |
| Require org login | `forceLoginOrgUUID`, `forceLoginMethod` |
| Track usage | OpenTelemetry (`CLAUDE_CODE_ENABLE_TELEMETRY`), analytics dashboard |

Verify active settings: run `/status` and check the **Status** tab `Setting sources` line. `Enterprise managed settings (remote|plist|HKLM|HKCU|file)` confirms managed settings are in effect. Run `claude doctor` for validation errors.

### Global config settings (stored in `~/.claude.json`, not `settings.json`)

| Key | Description |
| :--- | :--- |
| `autoConnectIde` | Auto-connect to IDE when launched from external terminal |
| `autoInstallIdeExtension` | Auto-install Claude Code VS Code extension |
| `externalEditorContext` | Prepend last response when opening external editor with Ctrl+G |
| `teammateDefaultModel` | Default model for agent team teammates |

### Worktree settings

| Key | Description |
| :--- | :--- |
| `worktree.baseRef` | `"fresh"` (default, from `origin/<default-branch>`) or `"head"` (current local HEAD) |
| `worktree.symlinkDirectories` | Dirs to symlink from main repo into worktrees |
| `worktree.sparsePaths` | Sparse-checkout paths for large monorepos |
| `worktree.bgIsolation` | `"worktree"` (default) or `"none"` for background session file isolation |

## Full Documentation

For the complete official documentation, see the reference files:

- [Settings reference](references/claude-code-settings.md) — All settings.json keys, scope system, file locations, precedence rules, permission settings, sandbox settings, plugin settings, worktree settings, and policy helper
- [Admin setup guide](references/claude-code-admin-setup.md) — Deployment decision map for administrators: API providers, managed settings delivery, enforcement controls, usage visibility, data handling
- [Permissions](references/claude-code-permissions.md) — Permission system, rule syntax, tool-specific patterns (Bash, PowerShell, Read/Edit, WebFetch, MCP, Agent, Cd), managed settings, working directories, sandbox interaction
- [Server-managed settings](references/claude-code-server-managed-settings.md) — Claude.ai admin console configuration, delivery and caching behavior, fail-closed enforcement, security approval dialogs, audit logging
- [Environment variables](references/claude-code-env-vars.md) — Complete reference for all environment variables, precedence rules, how to set them in shell vs settings files
- [Permission modes](references/claude-code-permission-modes.md) — acceptEdits, plan, auto, dontAsk, bypassPermissions modes; switching modes; protected paths; auto mode classifier behavior
- [Configure auto mode](references/claude-code-auto-mode-config.md) — autoMode settings block, defining trusted infrastructure, overriding block/allow rules, CLI inspection subcommands

## Sources

- Settings reference: https://code.claude.com/docs/en/settings.md
- Admin setup guide: https://code.claude.com/docs/en/admin-setup.md
- Permissions: https://code.claude.com/docs/en/permissions.md
- Server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Permission modes: https://code.claude.com/docs/en/permission-modes.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
