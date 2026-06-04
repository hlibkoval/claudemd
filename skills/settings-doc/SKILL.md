---
name: settings-doc
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code configuration: settings files, permission rules, permission modes, environment variables, server-managed settings, and admin deployment.

## Quick Reference

### Configuration Scopes

| Scope | File / Location | Who it affects | Shared? |
|:------|:----------------|:---------------|:--------|
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | All users on the machine | Yes (IT-deployed) |
| **User** | `~/.claude/settings.json` | You, all projects | No |
| **Project** | `.claude/settings.json` | All collaborators | Yes (git) |
| **Local** | `.claude/settings.local.json` | You, this project | No (gitignored) |

Precedence (highest first): Managed > CLI args > Local > Project > User.
Array settings (e.g. `permissions.allow`, `sandbox.filesystem.allowWrite`) **merge** across scopes — they are concatenated and deduplicated, not replaced.

### Settings File Locations

| Scope | Path (Unix) | Path (Windows) |
|:------|:------------|:---------------|
| User | `~/.claude/settings.json` | `%USERPROFILE%\.claude\settings.json` |
| Project (shared) | `.claude/settings.json` | same |
| Project (local) | `.claude/settings.local.json` | same |
| Managed (file) — macOS | `/Library/Application Support/ClaudeCode/managed-settings.json` | — |
| Managed (file) — Linux/WSL | `/etc/claude-code/managed-settings.json` | — |
| Managed (file) — Windows | — | `C:\Program Files\ClaudeCode\managed-settings.json` |
| Managed (plist) — macOS | `com.anthropic.claudecode` preference domain | — |
| Managed (registry) — Windows | — | `HKLM\SOFTWARE\Policies\ClaudeCode` |

Drop-in directory: `managed-settings.d/*.json` alongside the base file; merged alphabetically on top, arrays concatenated.

### Key settings.json Fields (Quick Lookup)

| Key | Description |
|:----|:------------|
| `permissions` | `allow`, `ask`, `deny` rule arrays; `defaultMode`; `additionalDirectories` |
| `env` | Environment variables applied to every session |
| `hooks` | Lifecycle hook configuration |
| `model` | Default model override |
| `effortLevel` | Persisted effort level (`low`, `medium`, `high`, `xhigh`) |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) |
| `availableModels` | Restrict models in `/model` picker |
| `apiKeyHelper` | Script to generate auth value |
| `sandbox` | OS-level Bash sandboxing (see sandbox table below) |
| `worktree.*` | Worktree isolation settings |
| `attribution` | Git commit/PR attribution strings |
| `language` | Claude's preferred response language |
| `tui` | `"fullscreen"` or `"default"` renderer |
| `editorMode` | `"normal"` or `"vim"` |
| `cleanupPeriodDays` | Session file retention (default: 30) |
| `companyAnnouncements` | Array of startup messages |
| `skillOverrides` | Per-skill visibility: `"on"`, `"name-only"`, `"user-invocable-only"`, `"off"` |
| `disableAllHooks` | Disable all hooks |
| `disableAutoMode` | Set to `"disable"` to block auto mode |
| `disableBypassPermissionsMode` in `permissions` | Set to `"disable"` to block bypass mode |
| `enabledPlugins` | `"plugin@marketplace": true/false` |
| `extraKnownMarketplaces` | Add custom marketplace sources |
| `claudeMd` | (Managed only) Org-wide CLAUDE.md content |
| `forceLoginMethod` | `"claudeai"` or `"console"` to restrict auth |
| `forceLoginOrgUUID` | Require specific org UUID(s) |
| `minimumVersion` | Floor version for auto-updates |
| `policyHelper` | Admin executable to compute managed settings dynamically |
| `parentSettingsBehavior` | `"first-wins"` (default) or `"merge"` for embedder settings |

### Global Config Settings (stored in ~/.claude.json, NOT settings.json)

| Key | Description |
|:----|:------------|
| `autoConnectIde` | Auto-connect to IDE on startup |
| `autoInstallIdeExtension` | Auto-install VS Code extension |
| `externalEditorContext` | Prepend last response in external editor |
| `teammateDefaultModel` | Default model for agent team members |

### Permission Rule Syntax

Format: `Tool` or `Tool(specifier)`. Evaluated: **deny → ask → allow**. First match wins.

| Rule | Effect |
|:-----|:-------|
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Bash(git * main)` | Any git command ending with `main` |
| `Read(./.env)` | Reading `.env` in current directory |
| `Read(/src/**)` | Reading `<project>/src/**` |
| `Read(//tmp/file)` | Reading absolute path `/tmp/file` |
| `Edit(/docs/**)` | Editing files under `<project>/docs/` |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__github__*` | All tools from the `github` MCP server |
| `Agent(Explore)` | The Explore subagent |
| `Skill(commit)` | The `commit` skill |

Deny a bare tool name (e.g. `Bash`) removes it from Claude's context entirely; scoped denies (e.g. `Bash(rm *)`) block matching calls but leave the tool available.

### Permission Modes

| Mode | What runs without asking | Best for |
|:-----|:-------------------------|:---------|
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem cmds | Iterating on code |
| `plan` | Reads only (no edits) | Exploring before changing |
| `auto` | Everything, with background safety checks | Long tasks |
| `dontAsk` | Only pre-approved tools | Locked-down CI |
| `bypassPermissions` | Everything (no checks) | Isolated containers only |

Set with `--permission-mode <mode>` or `permissions.defaultMode` in settings.
**Note:** `defaultMode: "auto"` is ignored in project and local settings (`.claude/settings.json`, `.claude/settings.local.json`) to prevent a repo from granting itself auto mode.

### Sandbox Settings (under `sandbox` key)

| Key | Description |
|:----|:------------|
| `enabled` | Enable Bash sandboxing (macOS, Linux, WSL2) |
| `failIfUnavailable` | Exit if sandbox can't start when enabled |
| `autoAllowBashIfSandboxed` | Auto-approve sandboxed Bash (default: true) |
| `excludedCommands` | Commands that bypass the sandbox |
| `allowUnsandboxedCommands` | Allow the `dangerouslyDisableSandbox` escape hatch (default: true) |
| `filesystem.allowWrite` | Paths sandboxed commands may write (merged across scopes) |
| `filesystem.denyWrite` | Paths blocked from writing |
| `filesystem.denyRead` | Paths blocked from reading |
| `filesystem.allowRead` | Re-allow read within denyRead regions |
| `network.allowedDomains` | Outbound domain allowlist (wildcard: `*.example.com`) |
| `network.deniedDomains` | Outbound domain denylist (takes precedence) |
| `network.allowUnixSockets` | (macOS) Unix socket paths accessible |
| `network.allowLocalBinding` | (macOS) Allow binding to localhost ports |
| `network.httpProxyPort` | Bring-your-own HTTP proxy port |

Sandbox path prefixes: `/` = absolute, `~/` = home-relative, `./` or no prefix = project-relative (or `~/.claude`-relative for user settings).

### Worktree Settings (under `worktree` key)

| Key | Description |
|:----|:------------|
| `worktree.baseRef` | `"fresh"` (default, from remote) or `"head"` (from local HEAD) |
| `worktree.symlinkDirectories` | Directories to symlink into worktrees (e.g. `["node_modules"]`) |
| `worktree.sparsePaths` | Sparse-checkout paths per worktree |
| `worktree.bgIsolation` | `"worktree"` (default) or `"none"` for background sessions |

### Managed-Only Settings

These settings are **only effective in managed settings** (ignored in user/project files):

| Setting | Effect |
|:--------|:-------|
| `allowAllClaudeAiMcps` | Load claude.ai connectors alongside managed-mcp.json |
| `allowManagedHooksOnly` | Block user/project hooks; only managed hooks load |
| `allowManagedMcpServersOnly` | Only managed MCP servers allowed |
| `allowManagedPermissionRulesOnly` | Only managed allow/ask/deny rules apply |
| `blockedMarketplaces` | Denylist of plugin marketplace sources |
| `channelsEnabled` | Allow channels for the org |
| `claudeMd` | Org-wide CLAUDE.md instruction string |
| `forceRemoteSettingsRefresh` | Block startup until remote settings are fresh |
| `strictKnownMarketplaces` | Allowlist of marketplace sources (empty array = lockdown) |
| `strictPluginOnlyCustomization` | Block skills/agents/hooks/MCP from user and project sources |
| `wslInheritsWindowsSettings` | WSL reads Windows policy chain |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed read-allow paths respected |
| `sandbox.network.allowManagedDomainsOnly` | Only managed domain allowlist respected |
| `policyHelper` | Dynamic policy helper executable (MDM/file-based only) |
| `parentSettingsBehavior` | Controls embedder managed settings interaction |

### Admin Deployment: How Settings Reach Devices

| Mechanism | Priority | Platforms | Best for |
|:----------|:---------|:----------|:---------|
| Server-managed (claude.ai admin console) | Highest | All | No-MDM orgs; unmanaged devices |
| plist / HKLM registry | High | macOS, Windows | MDM-enrolled devices |
| File-based (`managed-settings.json`) | Medium | All | Any org with file deployment |
| HKCU registry | Lowest | Windows only | Convenience, not enforcement |

Server-managed settings require Teams or Enterprise plan. They refresh at auth time and hourly during active sessions.

### Admin Policy Controls (summary)

| Control | Key settings |
|:--------|:-------------|
| Permission rules | `permissions.allow`, `permissions.deny` |
| Lock down all permission rules | `allowManagedPermissionRulesOnly`, `permissions.disableBypassPermissionsMode` |
| Sandboxing | `sandbox.enabled`, `sandbox.network.allowedDomains` |
| MCP server control | `allowedMcpServers`, `deniedMcpServers`, `allowManagedMcpServersOnly` |
| Plugin marketplace control | `strictKnownMarketplaces`, `blockedMarketplaces` |
| Customization lockdown | `strictPluginOnlyCustomization: ["skills", "hooks", "agents", "mcp"]` |
| Hook restrictions | `allowManagedHooksOnly`, `allowedHttpHookUrls` |
| Version floor | `minimumVersion` |
| Disable agent view | `disableAgentView` |
| Force login method/org | `forceLoginMethod`, `forceLoginOrgUUID` |

### Auto Mode Configuration (`autoMode` key)

```json
{
  "autoMode": {
    "environment": ["$defaults", "github.example.com/acme-corp", "s3://acme-artifacts"],
    "soft_deny": ["$defaults", "Never run terraform apply"],
    "hard_deny": ["$defaults"],
    "allow": ["$defaults"]
  }
}
```

`"$defaults"` splices in built-in rules at that position. `autoMode` is not read from shared project settings (`.claude/settings.json`). Use `claude auto-mode show` / `claude auto-mode explain <command>` to inspect effective config.

### Key Environment Variables

| Variable | Purpose |
|:---------|:---------|
| `ANTHROPIC_API_KEY` | API key auth |
| `ANTHROPIC_MODEL` | Override default model |
| `ANTHROPIC_BASE_URL` | Proxy/gateway endpoint |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude` directory |
| `CLAUDE_CODE_USE_BEDROCK` / `USE_VERTEX` / `USE_FOUNDRY` | Provider selection |
| `BASH_DEFAULT_TIMEOUT_MS` | Bash command timeout (default: 120000) |
| `API_TIMEOUT_MS` | API request timeout (default: 600000) |
| `CLAUDE_CODE_EFFORT_LEVEL` | Effort level override (`low`/`medium`/`high`/`xhigh`/`max`) |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry |
| `DISABLE_TELEMETRY` / `DO_NOT_TRACK` | Opt out of telemetry |
| `DISABLE_AUTOUPDATER` | Disable background auto-updates |
| `DISABLE_AUTO_COMPACT` | Disable auto-compaction |
| `CLAUDE_CODE_DISABLE_THINKING` | Force-disable extended thinking |
| `MAX_THINKING_TOKENS` | Override thinking token budget |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess env |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Skip writing session transcripts |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_ENV_FILE` | Script sourced before each Bash command |
| `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` | Load CLAUDE.md from `--add-dir` dirs |
| `CLAUDE_CODE_NO_FLICKER` / `tui` setting | Enable fullscreen renderer |
| `DEBUG` | Enable debug mode (logs to `~/.claude/debug/`) |

Set env vars in `settings.json` under `env` to apply them persistently. Shell-set variables take precedence over the `env` setting.

### Verify Active Settings

Run `/status` inside Claude Code. The `Setting sources` line lists every loaded layer (e.g. `Enterprise managed settings (remote)`, `(plist)`, `(HKLM)`, `(file)`, `User settings`, `Project local settings`). A layer only appears when it has at least one key set.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) — All settings.json keys, scopes, precedence, sandbox, worktree, permission rules, attribution, file suggestion, hook configuration, and plugin settings
- [Set Up Claude Code for Your Organization](references/claude-code-admin-setup.md) — Admin deployment decision map: API provider, settings delivery mechanism, policy controls, usage visibility, data handling
- [Configure Permissions](references/claude-code-permissions.md) — Permission system, rule syntax, tool-specific patterns (Bash, Read/Edit, WebFetch, MCP, Agent), managed-only settings, working directories
- [Configure Server-Managed Settings](references/claude-code-server-managed-settings.md) — Claude.ai admin console setup, fail-closed enforcement, limitations vs. endpoint-managed
- [Environment Variables](references/claude-code-env-vars.md) — Complete variable reference, precedence, setting via settings.json
- [Choose a Permission Mode](references/claude-code-permission-modes.md) — Mode descriptions, switching modes (CLI, VS Code, Desktop, Web), auto mode requirements, protected paths
- [Configure Auto Mode](references/claude-code-auto-mode-config.md) — autoMode settings block, trusted infrastructure, block/allow overrides, CLI subcommands

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Set Up Claude Code for Your Organization: https://code.claude.com/docs/en/admin-setup.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Configure Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment Variables: https://code.claude.com/docs/en/env-vars.md
- Choose a Permission Mode: https://code.claude.com/docs/en/permission-modes.md
- Configure Auto Mode: https://code.claude.com/docs/en/auto-mode-config.md
