---
name: settings-doc
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, environment variables, permission modes, managed settings, and admin deployment.

## Quick Reference

### Settings Scopes and Files

| Scope | File | Who it affects | Shared? |
|:------|:-----|:---------------|:--------|
| Managed | Server, plist/registry, or `managed-settings.json` | All users on the machine | Yes (deployed by IT) |
| User | `~/.claude/settings.json` | You, across all projects | No |
| Project | `.claude/settings.json` | All collaborators | Yes (committed to git) |
| Local | `.claude/settings.local.json` | You, in this repo only | No |

**Precedence (highest to lowest):** Managed > CLI args > Local > Project > User

Array settings (e.g. `permissions.allow`, `sandbox.filesystem.allowWrite`) **merge** across scopes instead of overriding.

### Managed Settings Delivery Mechanisms

| Mechanism | Delivery | Priority | Platforms |
|:----------|:---------|:---------|:----------|
| Server-managed | Claude.ai admin console | Highest | All |
| plist / registry | macOS `com.anthropic.claudecode` plist; `HKLM\SOFTWARE\Policies\ClaudeCode` | High | macOS, Windows |
| File-based | `/Library/Application Support/ClaudeCode/` (macOS), `/etc/claude-code/` (Linux/WSL), `C:\Program Files\ClaudeCode\` (Windows) | Medium | All |
| Windows user registry | `HKCU\SOFTWARE\Policies\ClaudeCode` | Lowest | Windows only |

File-based managed settings support a drop-in directory `managed-settings.d/` for merging multiple policy fragments. Use numeric prefixes (e.g. `10-telemetry.json`) to control merge order.

Server-managed settings require Claude for Teams or Enterprise. Other providers use file-based or OS-level mechanisms.

### Key `settings.json` Fields

| Key | Description | Example |
|:----|:------------|:--------|
| `permissions` | Allow/ask/deny rules, defaultMode, additionalDirectories | See permissions table |
| `env` | Environment variables for every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle hook commands | See hooks-doc |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `effortLevel` | Persist effort level across sessions | `"xhigh"` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) | `"stable"` |
| `apiKeyHelper` | Script to generate auth value | `"/bin/gen_key.sh"` |
| `autoMode` | Configure auto mode classifier rules | See autoMode section |
| `sandbox` | OS-level bash sandboxing | `{"enabled": true}` |
| `attribution` | Customize git commit/PR attribution | `{"commit": "...", "pr": ""}` |
| `language` | Claude's preferred response language | `"japanese"` |
| `enabledPlugins` | Enable/disable plugins by name | `{"pkg@mkt": true}` |
| `extraKnownMarketplaces` | Add plugin marketplace sources | See plugin settings |
| `companyAnnouncements` | Startup messages for users | `["Welcome!"]` |
| `claudeMd` | Managed CLAUDE.md instructions (managed only) | `"Always run lint"` |
| `minimumVersion` | Floor for auto-updates | `"2.1.100"` |
| `tui` | TUI renderer: `"fullscreen"` or `"default"` | `"fullscreen"` |
| `outputStyle` | System prompt output style | `"Explanatory"` |
| `cleanupPeriodDays` | Session file retention days (default: 30) | `20` |
| `worktree.*` | Worktree creation settings | See worktree settings |

**Settings that only take effect on restart:** `model`, `outputStyle`

**Verify active settings:** run `/status` inside Claude Code. The Status tab shows a `Setting sources` line listing all loaded layers.

### Permission Settings

| Key | Description |
|:----|:------------|
| `permissions.allow` | Array of rules to allow without prompting |
| `permissions.ask` | Array of rules to always prompt for |
| `permissions.deny` | Array of rules to block entirely |
| `permissions.defaultMode` | Starting permission mode |
| `permissions.additionalDirectories` | Extra directories for file access |
| `permissions.disableBypassPermissionsMode` | Set `"disable"` to prevent bypass mode |
| `permissions.skipDangerousModePermissionPrompt` | Skip confirmation before bypass mode |

### Permission Rule Syntax

Format: `Tool` or `Tool(specifier)`  
Evaluation order: **deny first, then ask, then allow**. First match wins.

| Rule | Effect |
|:-----|:-------|
| `Bash` | All bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Bash(git * main)` | Commands like `git checkout main` |
| `Read(./.env)` | Reading the `.env` file |
| `Edit(/src/**)` | Edits under `<project>/src/` |
| `Read(~/.zshrc)` | Home-relative path |
| `Read(//etc/*)` | Absolute path (double-slash) |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer__*` | All tools from puppeteer MCP server |
| `Agent(Explore)` | Explore subagent |
| `Skill(review-pr *)` | Skills matching prefix |

A bare tool name (`Bash`) as a deny rule removes the tool from Claude's context entirely. A scoped rule (`Bash(rm *)`) leaves the tool available but blocks matching calls.

### Read/Edit Path Anchors

| Pattern | Meaning |
|:--------|:--------|
| `//path` | Absolute path from filesystem root |
| `~/path` | Relative to home directory |
| `/path` | Relative to project root |
| `path` or `./path` | Relative to current directory |

### Permission Modes

| Mode | What runs without asking | Best for |
|:-----|:------------------------|:---------|
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands | Iterating on code |
| `plan` | Reads only (no edits) | Exploring before changing |
| `auto` | Everything, with background safety checks | Long tasks, reducing prompts |
| `dontAsk` | Only pre-approved tools | Locked-down CI and scripts |
| `bypassPermissions` | Everything (no checks) | Isolated containers/VMs only |

Switch modes mid-session with `Shift+Tab`. Set default via `permissions.defaultMode` in settings.  
`auto` from project/local settings (`.claude/settings.json`, `.claude/settings.local.json`) is ignored since v2.1.142 — set it in `~/.claude/settings.json` instead.

### Managed-Only Settings (no effect in user/project settings)

| Setting | Purpose |
|:--------|:--------|
| `allowAllClaudeAiMcps` | Load claude.ai connectors alongside managed-mcp.json |
| `allowedChannelPlugins` | Allowlist which channel plugins can push messages |
| `allowManagedHooksOnly` | Block all non-managed hooks |
| `allowManagedMcpServersOnly` | Only managed MCP servers respected |
| `allowManagedPermissionRulesOnly` | Block user/project permission rules |
| `blockedMarketplaces` | Blocklist marketplace sources |
| `channelsEnabled` | Allow channels for the org |
| `claudeMd` | Organization-wide CLAUDE.md instructions |
| `forceRemoteSettingsRefresh` | Block startup until remote settings fetched |
| `strictKnownMarketplaces` | Allowlist marketplace sources |
| `strictPluginOnlyCustomization` | Lock skills/agents/hooks/MCP to plugins only |
| `wslInheritsWindowsSettings` | WSL reads Windows policy chain |
| `policyHelper` | Dynamic policy from an executable (MDM/file only) |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed allowRead paths respected |
| `sandbox.network.allowManagedDomainsOnly` | Only managed allowedDomains respected |

### Sandbox Settings (under `sandbox` key)

| Key | Description |
|:----|:------------|
| `enabled` | Enable bash sandboxing (macOS, Linux, WSL2) |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `excludedCommands` | Commands that run outside the sandbox |
| `allowUnsandboxedCommands` | Allow the `dangerouslyDisableSandbox` escape hatch (default: true) |
| `filesystem.allowWrite` | Paths sandboxed commands can write |
| `filesystem.denyWrite` | Paths sandboxed commands cannot write |
| `filesystem.denyRead` | Paths sandboxed commands cannot read |
| `filesystem.allowRead` | Re-allow reading within denyRead regions |
| `network.allowedDomains` | Domains allowed for outbound traffic (wildcards supported) |
| `network.deniedDomains` | Domains blocked for outbound traffic |
| `network.allowUnixSockets` | Unix socket paths accessible (macOS only) |
| `network.allowLocalBinding` | Allow binding to localhost ports (macOS only) |
| `failIfUnavailable` | Exit at startup if sandbox required but unavailable |

Sandbox path prefixes: `/` = absolute, `~/` = home-relative, `./` or no prefix = project-relative (or `~/.claude` for user settings).

### Worktree Settings (under `worktree` key)

| Key | Description | Default |
|:----|:------------|:--------|
| `worktree.baseRef` | Branch new worktrees branch from: `"fresh"` (origin/default) or `"head"` (local HEAD) | `"fresh"` |
| `worktree.symlinkDirectories` | Directories to symlink from main repo into worktrees | none |
| `worktree.sparsePaths` | Directories to check out via sparse-checkout | none |
| `worktree.bgIsolation` | Background session isolation: `"worktree"` or `"none"` (v2.1.143+) | `"worktree"` |

### Auto Mode Configuration (under `autoMode` key)

Not read from shared project settings. Use user, local, or managed settings.

| Field | Purpose |
|:------|:--------|
| `environment` | Prose descriptions of trusted repos, buckets, domains |
| `allow` | Exceptions to soft_deny rules |
| `soft_deny` | Destructive actions user intent can override |
| `hard_deny` | Unconditional security boundaries |

Include `"$defaults"` in any array to inherit built-in rules at that position. Omitting `"$defaults"` **replaces** the entire default list.

Precedence inside the classifier: `hard_deny` > `soft_deny` > `allow` > explicit user intent.

CLI subcommands: `claude auto-mode defaults`, `claude auto-mode config`, `claude auto-mode critique`.

Auto mode is off by default on Bedrock, Vertex AI, and Foundry — enable with `CLAUDE_CODE_ENABLE_AUTO_MODE=1`.

### Server-Managed Settings

Requires Claude for Teams or Enterprise (v2.1.38+ for Teams, v2.1.30+ for Enterprise).

- Configure at **Admin Settings > Claude Code > Managed settings** in Claude.ai
- Delivered at authentication time; polled hourly during sessions
- Settings restricted to OS-level policy sources (`policyHelper`, `wslInheritsWindowsSettings`) are NOT honored — use MDM or file-based delivery instead
- `managed-mcp.json` cannot be distributed via server-managed settings

Security dialogs appear for shell command settings, custom env vars, and hooks before users accept them.

### Key Environment Variables

Set in shell or under the `env` key in `settings.json`.

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key (overrides subscription when set) |
| `ANTHROPIC_MODEL` | Override default model |
| `ANTHROPIC_BASE_URL` | Route requests through a proxy/gateway |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level (low/medium/high/xhigh/max/auto) |
| `CLAUDE_CODE_ENABLE_AUTO_MODE` | Enable auto mode on Bedrock/Vertex/Foundry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry data collection |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_DISABLE_THINKING` | Force-disable extended thinking |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude` config directory |
| `DISABLE_AUTOUPDATER` | Disable background auto-updates |
| `DISABLE_TELEMETRY` | Opt out of telemetry |
| `DO_NOT_TRACK` | Opt out of telemetry (cross-tool standard) |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max bash command timeout (default: 600000) |
| `API_TIMEOUT_MS` | API request timeout (default: 600000) |
| `MAX_THINKING_TOKENS` | Extended thinking token budget |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Skip writing session transcripts to disk |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess environments |
| `MCP_TIMEOUT` | MCP server startup timeout (default: 30000) |
| `HTTP_PROXY` / `HTTPS_PROXY` | HTTP/HTTPS proxy servers |
| `OTEL_METRICS_EXPORTER` | OpenTelemetry metrics exporter |

**Env var precedence:** environment variables override settings file fields. Some are overridden by CLI flags or in-session commands (e.g. `--model` overrides `ANTHROPIC_MODEL`).

### Global Config Settings (`~/.claude.json`, not `settings.json`)

| Key | Description |
|:----|:------------|
| `autoConnectIde` | Auto-connect to IDE when launching from external terminal |
| `autoInstallIdeExtension` | Auto-install VS Code/JetBrains extension |
| `externalEditorContext` | Prepend previous response when opening external editor |
| `teammateDefaultModel` | Default model for agent team teammates |

### Plugin Settings (`settings.json`)

| Key | Description |
|:----|:------------|
| `enabledPlugins` | `{"plugin-name@marketplace": true/false}` |
| `extraKnownMarketplaces` | Add marketplace sources with named entries |
| `strictKnownMarketplaces` | Managed only — allowlist marketplace sources |
| `blockedMarketplaces` | Managed only — blocklist marketplace sources |

Marketplace source types: `github`, `git`, `url`, `npm`, `file`, `directory`, `hostPattern`, `pathPattern`, `settings` (inline).

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) — Configuration scopes, settings files, all available settings keys, permission settings, sandbox settings, worktree settings, attribution, plugin configuration, precedence rules, and global config
- [Set up Claude Code for your organization](references/claude-code-admin-setup.md) — Admin deployment decision map: API provider selection, managed settings delivery, policy enforcement controls, usage monitoring, and data handling
- [Configure permissions](references/claude-code-permissions.md) — Permission system, permission modes, rule syntax, tool-specific patterns (Bash, PowerShell, Read/Edit, WebFetch, MCP, Agent), hooks-based extension, working directories, sandboxing interaction, and managed-only settings
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — Server delivery setup, fetch/caching behavior, security approval dialogs, fail-closed enforcement, platform availability, and audit logging
- [Environment variables](references/claude-code-env-vars.md) — Full reference for all environment variables controlling Claude Code behavior, with precedence notes
- [Choose a permission mode](references/claude-code-permission-modes.md) — Mode details, how to switch modes, auto mode requirements and classifier behavior, protected paths
- [Configure auto mode](references/claude-code-auto-mode-config.md) — autoMode settings block, trusted infrastructure definition, override rules, CLI inspection subcommands, reviewing denials

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Set up Claude Code for your organization: https://code.claude.com/docs/en/admin-setup.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
