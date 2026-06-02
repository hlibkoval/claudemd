---
name: settings-doc
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, environment variables, permission modes, server-managed settings, admin setup, and auto mode configuration.

## Quick Reference

### Configuration Scopes and Files

| Scope | File | Who it affects | Shared? |
|:------|:-----|:---------------|:--------|
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | All users on machine | Yes (IT-deployed) |
| **User** | `~/.claude/settings.json` | You, all projects | No |
| **Project** | `.claude/settings.json` | All repo collaborators | Yes (git) |
| **Local** | `.claude/settings.local.json` | You, this project only | No (gitignored) |

**Settings precedence (highest to lowest):**
1. Managed settings (server-managed > plist/MDM > file-based > HKCU registry)
2. Command line arguments / `--settings`
3. Local project settings (`.claude/settings.local.json`)
4. Shared project settings (`.claude/settings.json`)
5. User settings (`~/.claude/settings.json`)

Array-valued settings (e.g., `permissions.allow`, `sandbox.filesystem.allowWrite`) **merge and deduplicate** across scopes rather than override.

### Managed Settings File Locations

| Platform | Path |
|:---------|:-----|
| macOS | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux / WSL | `/etc/claude-code/managed-settings.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-settings.json` |
| Windows (plist) | `com.anthropic.claudecode` MDM preference domain |
| Windows (registry) | `HKLM\SOFTWARE\Policies\ClaudeCode` |

Drop-in directory support: place `*.json` files in `managed-settings.d/` alongside `managed-settings.json`. Files are merged alphabetically; use numeric prefixes (e.g., `10-telemetry.json`) to control order.

### Key `settings.json` Fields

| Key | Description | Example |
|:----|:------------|:--------|
| `agent` | Run main thread as named subagent | `"code-reviewer"` |
| `alwaysThinkingEnabled` | Enable extended thinking by default | `true` |
| `apiKeyHelper` | Script to generate auth token | `"/bin/gen_key.sh"` |
| `attribution` | Git commit / PR attribution text | `{"commit": "...", "pr": ""}` |
| `autoMemoryEnabled` | Enable/disable auto memory | `false` |
| `autoMode` | Auto mode classifier configuration (not read from project settings) | `{"soft_deny": ["$defaults", "Never run terraform apply"]}` |
| `autoScrollEnabled` | Follow new output in fullscreen | `false` |
| `autoUpdatesChannel` | Update release channel: `"stable"` or `"latest"` | `"stable"` |
| `availableModels` | Restrict selectable models | `["sonnet", "haiku"]` |
| `cleanupPeriodDays` | Session file retention in days (default: 30) | `20` |
| `companyAnnouncements` | Startup announcements (cycled randomly) | `["Welcome to Acme!"]` |
| `defaultShell` | Shell for input-box commands: `"bash"` or `"powershell"` | `"powershell"` |
| `disableAllHooks` | Disable all hooks and custom status line | `true` |
| `disableAutoMode` | Set `"disable"` to prevent auto mode | `"disable"` |
| `disableWorkflows` | Disable dynamic workflows | `true` |
| `editorMode` | Input prompt key binding: `"normal"` or `"vim"` | `"vim"` |
| `effortLevel` | Persisted effort level: `"low"`, `"medium"`, `"high"`, `"xhigh"` | `"xhigh"` |
| `enableAllProjectMcpServers` | Auto-approve all project MCP servers | `true` |
| `env` | Environment variables for every session | `{"FOO": "bar"}` |
| `feedbackSurveyRate` | Session survey probability 0–1 (0 = off) | `0.05` |
| `hooks` | Hook configuration (see hooks-doc) | See hooks docs |
| `includeGitInstructions` | Include built-in git workflow instructions | `false` |
| `language` | Claude's preferred response language | `"japanese"` |
| `minimumVersion` | Prevent updates below this version | `"2.1.100"` |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `modelOverrides` | Map model IDs to provider-specific IDs | `{"claude-opus-4-6": "arn:aws:..."}` |
| `outputStyle` | Output style preset | `"Explanatory"` |
| `permissions` | Permission rules — see table below | |
| `preferredNotifChannel` | Notification method: `"auto"`, `"terminal_bell"`, `"iterm2"`, etc. | `"terminal_bell"` |
| `skipWebFetchPreflight` | Skip WebFetch domain safety check (for Bedrock/Vertex) | `true` |
| `spinnerTipsEnabled` | Show tips while Claude works | `false` |
| `statusLine` | Custom status line script | `{"type": "command", "command": "~/.claude/statusline.sh"}` |
| `syntaxHighlightingDisabled` | Disable syntax highlighting | `true` |
| `tui` | Terminal renderer: `"fullscreen"` or `"default"` | `"fullscreen"` |
| `viewMode` | Default transcript view: `"default"`, `"verbose"`, `"focus"` | `"verbose"` |
| `voice` | Voice dictation settings | `{"enabled": true, "mode": "tap"}` |

### Permission Settings

| Key | Description | Example |
|:----|:------------|:--------|
| `permissions.allow` | Tools/patterns allowed without prompt | `["Bash(npm run *)", "Read(~/.zshrc)"]` |
| `permissions.ask` | Tools/patterns requiring confirmation | `["Bash(git push *)"]` |
| `permissions.deny` | Tools/patterns that are blocked | `["WebFetch", "Read(./.env)"]` |
| `permissions.additionalDirectories` | Extra directories for file access | `["../docs/"]` |
| `permissions.defaultMode` | Default permission mode | `"acceptEdits"` |
| `permissions.disableBypassPermissionsMode` | Set `"disable"` to block bypass mode | `"disable"` |

**Permission rule syntax:** `Tool` or `Tool(specifier)`. Evaluated in order: deny → ask → allow. First match wins.

| Rule | Effect |
|:-----|:-------|
| `Bash` | All bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Read(./.env)` | Reading `.env` in current directory |
| `Read(//Users/alice/secrets/**)` | Absolute path (note double slash) |
| `Edit(/src/**/*.ts)` | Files relative to project root |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer__*` | All tools from the puppeteer MCP server |
| `Agent(Explore)` | The Explore subagent |

### Permission Modes

| Mode | What runs without prompting | Best for |
|:-----|:----------------------------|:---------|
| `default` | Reads only | Sensitive work, getting started |
| `acceptEdits` | Reads, file edits, common filesystem commands | Iterating on code |
| `plan` | Reads only (no edits; Claude proposes a plan) | Exploring before changing |
| `auto` | Everything, with background classifier checks | Long tasks, reducing fatigue |
| `dontAsk` | Only pre-approved tools (via allow rules) | Locked-down CI |
| `bypassPermissions` | Everything (no prompts at all) | Isolated containers/VMs only |

Switch modes with `Shift+Tab` in CLI, or set `permissions.defaultMode` in settings. Pass `--permission-mode <mode>` at startup.

**Protected paths** (never auto-approved except in `bypassPermissions`): `.git`, `.vscode`, `.idea`, `.husky`, `.cargo`, `.claude` (except `commands/`, `agents/`, `skills/`, `worktrees/`), plus `.gitconfig`, `.bashrc`, `.zshrc`, `.mcp.json`, `.claude.json`.

### Sandbox Settings (`sandbox.*`)

| Key | Description |
|:----|:------------|
| `sandbox.enabled` | Enable OS-level bash sandboxing |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `sandbox.excludedCommands` | Commands that run outside sandbox |
| `sandbox.filesystem.allowWrite` | Paths sandboxed commands can write |
| `sandbox.filesystem.denyWrite` | Paths sandboxed commands cannot write |
| `sandbox.filesystem.denyRead` | Paths sandboxed commands cannot read |
| `sandbox.network.allowedDomains` | Allowed outbound domains (supports wildcards) |
| `sandbox.network.deniedDomains` | Blocked outbound domains (takes precedence) |
| `sandbox.network.allowUnixSockets` | Unix socket paths (macOS only) |
| `sandbox.network.allowLocalBinding` | Allow binding to localhost (macOS only) |

**Sandbox path prefixes:** `/` = absolute, `~/` = home-relative, `./` or no prefix = project-relative (project settings) or `~/.claude`-relative (user settings).

### Worktree Settings (`worktree.*`)

| Key | Description | Default |
|:----|:------------|:--------|
| `worktree.baseRef` | Branch source: `"fresh"` (remote default) or `"head"` (local HEAD) | `"fresh"` |
| `worktree.symlinkDirectories` | Directories to symlink into each worktree | none |
| `worktree.sparsePaths` | Directories for sparse checkout in worktrees | none |
| `worktree.bgIsolation` | Background session isolation: `"worktree"` or `"none"` | `"worktree"` |

### Managed-Only Settings

These keys are **only read from managed settings**; placing them in user or project settings has no effect:

| Key | Purpose |
|:----|:--------|
| `allowAllClaudeAiMcps` | Load claude.ai connectors alongside managed-mcp.json |
| `allowedChannelPlugins` | Allowlist for channel plugins |
| `allowManagedHooksOnly` | Block user/project hooks; only managed and SDK hooks load |
| `allowManagedMcpServersOnly` | Only managed MCP server allowlist applies |
| `allowManagedPermissionRulesOnly` | Block user/project allow/ask/deny rules |
| `blockedMarketplaces` | Marketplace denylist |
| `channelsEnabled` | Enable channels for the organization |
| `claudeMd` | Organization-wide CLAUDE.md instructions |
| `forceRemoteSettingsRefresh` | Block startup until server settings are fetched |
| `policyHelper` | Executable that computes managed settings dynamically |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed read paths respected |
| `sandbox.network.allowManagedDomainsOnly` | Only managed domains allowed |
| `strictKnownMarketplaces` | Allowlist for plugin marketplace sources |
| `strictPluginOnlyCustomization` | Block user/project skills, agents, hooks, MCP |
| `wslInheritsWindowsSettings` | Extend Windows policy to WSL |

### Global Config Settings (stored in `~/.claude.json`, NOT `settings.json`)

| Key | Description |
|:----|:------------|
| `autoConnectIde` | Auto-connect to running IDE on startup |
| `autoInstallIdeExtension` | Auto-install IDE extension in VS Code |
| `externalEditorContext` | Prepend Claude's response in external editor |
| `teammateDefaultModel` | Default model for agent team teammates |

### Server-Managed Settings

Delivered from Claude.ai admin console (Admin Settings > Claude Code > Managed settings). Requires Claude for Teams/Enterprise.

**Delivery hierarchy (first non-empty wins):**
1. Server-managed (via admin console) — highest
2. plist/MDM policy
3. File-based (`managed-settings.json` / `managed-settings.d/*.json`)
4. HKCU registry (Windows only) — lowest

**Caching behavior:** fetched at startup, polled hourly. Cached settings persist through network failures. Use `forceRemoteSettingsRefresh: true` for fail-closed enforcement.

**Security approval dialogs:** shell-command settings, custom env vars, and hook configurations require user approval before applying.

**Limitations:** does not support per-group configs, cannot distribute `managed-mcp.json` (use `allowedMcpServers`/`deniedMcpServers` keys instead), and `policyHelper`/`wslInheritsWindowsSettings` require OS-level deployment.

### Auto Mode Configuration (`autoMode.*`)

Configure the auto mode classifier's trusted environment. Only read from user settings, local project settings, managed settings, or `--settings` — not from shared project `.claude/settings.json`.

| Field | Purpose |
|:------|:--------|
| `autoMode.environment` | Prose descriptions of trusted repos, buckets, domains |
| `autoMode.allow` | Exceptions to soft-deny rules |
| `autoMode.soft_deny` | Destructive actions user intent can override |
| `autoMode.hard_deny` | Unconditional security boundaries |

Use `"$defaults"` in any array to include built-in rules at that position. Omitting `"$defaults"` replaces the entire default list.

**CLI subcommands:**
- `claude auto-mode defaults` — print built-in rules as JSON
- `claude auto-mode config` — print effective config with settings applied
- `claude auto-mode critique` — AI feedback on custom rules

**Classifier precedence inside auto mode:** `hard_deny` → `soft_deny` → `allow` exceptions → explicit user intent in conversation.

### Key Environment Variables

Set in shell, or under the `env` key in `settings.json`. Environment variables take precedence over equivalent settings keys.

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key (overrides subscription login) |
| `ANTHROPIC_MODEL` | Override default model |
| `ANTHROPIC_BASE_URL` | Proxy/gateway endpoint |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override Bedrock endpoint |
| `ANTHROPIC_VERTEX_BASE_URL` | Override Vertex endpoint |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `API_TIMEOUT_MS` | API request timeout (default: 600000) |
| `BASH_DEFAULT_TIMEOUT_MS` | Bash command default timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Bash command max timeout (default: 600000) |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set to `1` to enable OpenTelemetry export |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_DISABLE_WORKFLOWS` | Disable dynamic workflows |
| `CLAUDE_CODE_DISABLE_AGENT_VIEW` | Disable background agents / agent view |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen (alt-screen) rendering |
| `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN` | Disable fullscreen rendering |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Skip writing session transcripts to disk |
| `CLAUDE_CODE_MAX_TURNS` | Cap agentic turn count |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess envs |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude` config directory |
| `DISABLE_AUTOUPDATER` | Disable background auto-updates |
| `DISABLE_UPDATES` | Block all updates (including manual) |
| `DISABLE_TELEMETRY` / `DO_NOT_TRACK` | Opt out of telemetry |
| `DISABLE_COMPACT` | Disable all compaction |
| `DISABLE_AUTO_COMPACT` | Disable automatic compaction only |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget |
| `HTTP_PROXY` / `HTTPS_PROXY` | HTTP/HTTPS proxy for network connections |
| `MCP_TIMEOUT` | MCP server startup timeout (default: 30000) |
| `MCP_TOOL_TIMEOUT` | MCP tool execution timeout |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level: `low`, `medium`, `high`, `xhigh` |

### Verify Active Settings

Run `/status` inside Claude Code to see which settings sources are active. The `Setting sources` line lists each loaded layer. With managed settings, the source appears in parentheses: `(remote)`, `(plist)`, `(HKLM)`, `(HKCU)`, or `(file)`.

### Admin Setup Decision Map

| Decision | Reference |
|:---------|:----------|
| API provider (Claude.ai / Bedrock / Vertex / Foundry) | `claude-code-admin-setup.md` |
| Settings delivery mechanism (server / MDM / file) | `claude-code-server-managed-settings.md` |
| What to enforce (permissions, sandbox, MCP, plugins) | `claude-code-permissions.md` |
| Usage monitoring (OpenTelemetry, analytics) | Monitoring docs |
| Data handling and compliance | Data usage docs |

## Full Documentation

For the complete official documentation, see the reference files:

- [Settings](references/claude-code-settings.md) — Full settings reference: scopes, files, all available keys, sandbox, worktree, attribution, plugin, and hook configuration; settings precedence
- [Permissions](references/claude-code-permissions.md) — Permission system, rule syntax, tool-specific patterns (Bash, Read/Edit, WebFetch, MCP, Agent), permission modes, working directories, sandboxing interaction, managed-only settings
- [Permission Modes](references/claude-code-permission-modes.md) — Detailed guide to default, acceptEdits, plan, auto, dontAsk, and bypassPermissions modes; protected paths; how to switch modes
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) — Admin console configuration, delivery and caching behavior, fail-closed enforcement, security approval dialogs, audit logging, limitations
- [Environment Variables](references/claude-code-env-vars.md) — Complete reference for all environment variables, precedence rules, how to set in shell vs. settings files
- [Admin Setup](references/claude-code-admin-setup.md) — Decision map for administrators: API provider, settings delivery, enforcement controls, usage visibility, data handling
- [Auto Mode Config](references/claude-code-auto-mode-config.md) — Configure the auto mode classifier: trusted environment, allow/deny rule overrides, CLI inspection subcommands, reviewing denials

## Sources

- Settings: https://code.claude.com/docs/en/settings.md
- Permissions: https://code.claude.com/docs/en/permissions.md
- Permission Modes: https://code.claude.com/docs/en/permission-modes.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment Variables: https://code.claude.com/docs/en/env-vars.md
- Admin Setup: https://code.claude.com/docs/en/admin-setup.md
- Auto Mode Config: https://code.claude.com/docs/en/auto-mode-config.md
