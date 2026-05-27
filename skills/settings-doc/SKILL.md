---
name: settings-doc
description: Complete official documentation for Claude Code settings and configuration — settings files and scopes (user/project/local/managed), all settings.json keys, permission modes (default/acceptEdits/plan/auto/dontAsk/bypassPermissions), permission rule syntax, sandbox settings, environment variables, server-managed settings, admin deployment guide, and auto mode configuration.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, and configuration.

## Quick Reference

### Configuration Scopes

| Scope | Location | Shared? | Override priority |
| :--- | :--- | :--- | :--- |
| **Managed** | MDM/registry/`managed-settings.json`/server | Yes (by IT) | Highest — cannot be overridden |
| **Local** | `.claude/settings.local.json` | No (gitignored) | 3rd |
| **Project** | `.claude/settings.json` | Yes (committed) | 4th |
| **User** | `~/.claude/settings.json` | No | Lowest |

Array-valued settings (e.g. `permissions.allow`, `sandbox.filesystem.allowWrite`) **merge and deduplicate** across all scopes rather than replacing.

Settings that reload live (no restart needed): `permissions`, `hooks`, `apiKeyHelper`.
Settings that require restart: `model`, `outputStyle`.

### Managed Settings Delivery Mechanisms

| Mechanism | Priority | Platform | Notes |
| :--- | :--- | :--- | :--- |
| Server-managed (claude.ai admin console) | Highest | All | Requires Teams/Enterprise; no MDM needed |
| plist / HKLM registry | High | macOS, Windows | Requires admin; MDM-deployable |
| File-based (`managed-settings.json`) | Medium | All | `/Library/Application Support/ClaudeCode/` (macOS), `/etc/claude-code/` (Linux/WSL), `C:\Program Files\ClaudeCode\` (Windows) |
| Windows user registry (HKCU) | Lowest | Windows only | User-writable; treat as convenience, not enforcement |

Only one managed source is used — sources do not merge across tiers. Within the file-based tier, a `managed-settings.d/` drop-in directory is merged with the base file (alphabetically, later files win for scalars; arrays concatenated).

### Key settings.json Fields

| Key | Description | Example |
| :--- | :--- | :--- |
| `model` | Default model; overridden by `--model` or `ANTHROPIC_MODEL` | `"claude-sonnet-4-6"` |
| `permissions` | Object with `allow`, `ask`, `deny`, `defaultMode`, `additionalDirectories` | See below |
| `env` | Environment variables applied to every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle hook configuration | See hooks-doc |
| `apiKeyHelper` | Shell script to generate API auth token | `"/bin/get_key.sh"` |
| `autoUpdatesChannel` | `"latest"` (default) or `"stable"` | `"stable"` |
| `availableModels` | Restrict `/model` picker | `["sonnet", "haiku"]` |
| `cleanupPeriodDays` | Session file retention (default: 30, min: 1) | `20` |
| `companyAnnouncements` | Startup messages, cycled randomly | `["Welcome!"]` |
| `defaultShell` | `"bash"` (default) or `"powershell"` | `"powershell"` |
| `effortLevel` | Persisted effort: `"low"`, `"medium"`, `"high"`, `"xhigh"` | `"xhigh"` |
| `enableAllProjectMcpServers` | Auto-approve all `.mcp.json` servers | `true` |
| `language` | Claude's response language | `"japanese"` |
| `minimumVersion` | Prevent downgrade below this version | `"2.1.100"` |
| `outputStyle` | System prompt style; takes effect after `/clear` or restart | `"Explanatory"` |
| `sandbox` | Sandbox settings object | See sandbox table |
| `skillOverrides` | Per-skill visibility: `"on"`, `"name-only"`, `"off"` | `{"deploy": "off"}` |
| `tui` | `"fullscreen"` or `"default"` | `"fullscreen"` |
| `worktree.*` | Worktree configuration | See worktree table |
| `attribution` | Git commit/PR attribution strings | `{"commit": "...", "pr": ""}` |
| `autoMemoryEnabled` | Enable/disable auto memory (default: `true`) | `false` |
| `autoMemoryDirectory` | Custom auto memory directory | `"~/my-memory"` |
| `claudeMd` | (Managed only) Org-wide CLAUDE.md injected instructions | `"Always run lint."` |
| `claudeMdExcludes` | Glob patterns for CLAUDE.md files to skip | `["**/vendor/**/CLAUDE.md"]` |
| `disableAllHooks` | Disable all hooks and custom status line | `true` |
| `disableAutoMode` | Set to `"disable"` to prevent auto mode | `"disable"` |
| `editorMode` | Input key bindings: `"normal"` or `"vim"` | `"vim"` |
| `forceLoginMethod` | Restrict login to `"claudeai"` or `"console"` | `"claudeai"` |
| `forceLoginOrgUUID` | Require login to belong to specific org UUID(s) | `"xxxx-xxxx-..."` |
| `forceRemoteSettingsRefresh` | Block startup until remote settings fetched; exit on failure | `true` |
| `includeGitInstructions` | Include built-in git commit/PR instructions (default: `true`) | `false` |
| `policyHelper` | (Managed/MDM only) Executable that computes managed settings dynamically | `{"path": "/usr/local/bin/claude-policy"}` |
| `preferredNotifChannel` | Notification method: `"auto"`, `"terminal_bell"`, `"iterm2"`, etc. | `"terminal_bell"` |
| `skipWebFetchPreflight` | Skip WebFetch domain safety check (for Bedrock/Vertex/offline) | `true` |
| `statusLine` | Custom status line script | `{"type": "command", "command": "~/.claude/statusline.sh"}` |
| `strictPluginOnlyCustomization` | (Managed only) Lock skills/agents/hooks/mcp to plugins/managed only | `["skills", "hooks"]` |
| `strictKnownMarketplaces` | (Managed only) Plugin marketplace allowlist | `[{"source": "github", "repo": "acme/plugins"}]` |

### Permission Modes

| Mode | What runs without asking | Best for |
| :--- | :--- | :--- |
| `default` | Reads only | General use, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem cmds (`mkdir`, `rm`, `mv`, etc.) | Iterating on code |
| `plan` | Reads only (no edits) | Exploring before changing |
| `auto` | Everything with background classifier | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools (`permissions.allow`) | Locked-down CI |
| `bypassPermissions` | Everything (use in isolated containers/VMs only) | Automated containers |

Set mode: `Shift+Tab` to cycle CLI, `--permission-mode <mode>` flag, or `permissions.defaultMode` in settings.
Note: `auto` in `defaultMode` is ignored in project/local settings (`.claude/settings.json`/`.local.json`) — set in `~/.claude/settings.json` instead.

Protected paths (never auto-approved except in `bypassPermissions`): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`), `.gitconfig`, `.gitmodules`, `.bashrc`/`.zshrc`/`.profile`, `.ripgreprc`, `.mcp.json`, `.claude.json`.

### Permission Rule Syntax

Format: `Tool` or `Tool(specifier)`. Rules evaluated: **deny → ask → allow**. First match wins.

| Rule | Effect |
| :--- | :--- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Bash(git * main)` | git commands targeting main |
| `Read(./.env)` | Reading `.env` in current dir |
| `Read(//etc/secrets/**)` | Absolute path (double slash = absolute) |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `MCP(server:github)` | Any tool from the github MCP server |
| `Agent(task:*)` | All subagent spawns |

A bare deny rule (`"Bash"`) removes the tool from Claude's context entirely. A scoped deny (`"Bash(rm *)"`) leaves the tool available but blocks matching calls.

### Sandbox Settings (`sandbox.*`)

| Key | Description |
| :--- | :--- |
| `enabled` | Enable OS-level bash sandboxing (macOS, Linux, WSL2) |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: `true`) |
| `excludedCommands` | Commands that bypass the sandbox |
| `filesystem.allowWrite` | Additional writable paths (merged across scopes) |
| `filesystem.denyWrite` | Blocked write paths |
| `filesystem.denyRead` | Blocked read paths |
| `filesystem.allowRead` | Re-allow within `denyRead` regions |
| `network.allowedDomains` | Outbound domain allowlist (supports `*.example.com`) |
| `network.deniedDomains` | Outbound domain blocklist (takes precedence) |
| `network.allowLocalBinding` | Allow binding to localhost ports (macOS) |
| `network.allowUnixSockets` | Unix socket paths (macOS; use `allowAllUnixSockets` on Linux/WSL2) |

Path prefixes: `/` = absolute; `~/` = home-relative; `./` or no prefix = project-root-relative (in project settings) or `~/.claude`-relative (in user settings).

### Worktree Settings (`worktree.*`)

| Key | Description |
| :--- | :--- |
| `worktree.baseRef` | `"fresh"` (default, from `origin/<default>`) or `"head"` (from local HEAD) |
| `worktree.symlinkDirectories` | Dirs to symlink into each worktree (e.g. `["node_modules"]`) |
| `worktree.sparsePaths` | Sparse-checkout paths for large monorepos |
| `worktree.bgIsolation` | `"worktree"` (default) or `"none"` for background session isolation |

### Global Config Settings (`~/.claude.json`, not `settings.json`)

| Key | Description |
| :--- | :--- |
| `autoConnectIde` | Auto-connect to running IDE (default: `false`) |
| `autoInstallIdeExtension` | Auto-install IDE extension in VS Code terminal (default: `true`) |
| `externalEditorContext` | Prepend previous response in external editor (`Ctrl+G`) |
| `teammateDefaultModel` | Default model for agent team teammates |

### Auto Mode Classifier

Auto mode uses a classifier to review actions. Blocked by default: `curl | bash`, sending sensitive data externally, production deploys, mass cloud deletions, IAM changes, force push to main. Allowed by default: local file operations, installing declared dependencies, read-only HTTP, pushing to the current branch.

Configure trusted infrastructure via `autoMode.environment` in managed or user settings:

```json
{
  "autoMode": {
    "environment": ["Source control: github.example.com/acme-corp and all repos"],
    "soft_deny": ["$defaults", "Never run terraform apply"],
    "hard_deny": []
  }
}
```

Include `"$defaults"` in an array to inherit built-in rules at that position. `autoMode` is not read from shared project settings.

### Key Environment Variables

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key (overrides subscription login in interactive mode after approval) |
| `ANTHROPIC_MODEL` | Override active model; overridden by `--model` and `/model` |
| `ANTHROPIC_BASE_URL` | Route requests through proxy/gateway |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `BASH_DEFAULT_TIMEOUT_MS` | Bash command timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout model can set (default: 600000) |
| `API_TIMEOUT_MS` | API request timeout (default: 600000) |
| `CLAUDE_CODE_EFFORT_LEVEL` | Effort level; overrides `/effort` and `effortLevel` setting |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen rendering |
| `CLAUDE_CODE_DISABLE_THINKING` | Force-disable extended thinking |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Skip writing session transcripts |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `DISABLE_AUTOUPDATER` | Disable background auto-updates |
| `DISABLE_AUTO_COMPACT` | Disable automatic context compaction |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry data collection |
| `CLAUDECODE` | Set to `1` in subprocesses Claude spawns; detect inside hooks |
| `CLAUDE_CODE_SESSION_ID` | Current session ID (available in hooks and subprocesses) |
| `CLAUDE_CODE_REMOTE` | Set to `true` in cloud sessions |
| `DEBUG` | Enable debug mode (equivalent to `--debug`) |

Environment variables override settings.json fields when both set. Set variables in `settings.json` under `env` key to apply to all sessions or deploy to your team.

### Admin Deployment Decision Map

| Decision | Key settings |
| :--- | :--- |
| Lock permission rules to managed only | `allowManagedPermissionRulesOnly: true` |
| Disable bypass permissions mode | `permissions.disableBypassPermissionsMode: "disable"` |
| Disable auto mode | `permissions.disableAutoMode: "disable"` |
| Restrict MCP servers | `allowedMcpServers`, `deniedMcpServers`, `allowManagedMcpServersOnly` |
| Restrict plugin marketplaces | `strictKnownMarketplaces`, `blockedMarketplaces` |
| Lock skills/agents/hooks/MCP to plugins | `strictPluginOnlyCustomization: true` (or array) |
| Only managed hooks run | `allowManagedHooksOnly: true` |
| Restrict HTTP hook URLs | `allowedHttpHookUrls: ["https://hooks.example.com/*"]` |
| Force org login | `forceLoginMethod`, `forceLoginOrgUUID` |
| Set version floor | `minimumVersion: "2.1.100"` |
| Disable agent view | `disableAgentView: true` |
| Org-wide CLAUDE.md | `claudeMd: "Always run lint."` |
| Fail-closed startup | `forceRemoteSettingsRefresh: true` |
| Dynamic managed policy | `policyHelper: {"path": "/usr/local/bin/claude-policy"}` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Settings](references/claude-code-settings.md) — all settings.json keys, scopes, precedence, sandbox, permissions, attribution, plugin configuration, environment variables section
- [Admin setup guide](references/claude-code-admin-setup.md) — deployment decision map, managed settings delivery mechanisms, enforcement controls, usage visibility, data handling
- [Configure permissions](references/claude-code-permissions.md) — permission rule syntax, tool-specific patterns, managed-only settings, working directories, read-only commands
- [Server-managed settings](references/claude-code-server-managed-settings.md) — configure via claude.ai admin console, caching behavior, fail-closed startup, security approval dialogs, platform availability
- [Environment variables](references/claude-code-env-vars.md) — complete reference for all environment variables Claude Code reads
- [Permission modes](references/claude-code-permission-modes.md) — acceptEdits, plan, auto, dontAsk, bypassPermissions; classifier behavior; protected paths
- [Auto mode configuration](references/claude-code-auto-mode-config.md) — configure trusted infrastructure, allow/deny rules, environment entries for the auto mode classifier

## Sources

- Settings: https://code.claude.com/docs/en/settings.md
- Admin setup guide: https://code.claude.com/docs/en/admin-setup.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Permission modes: https://code.claude.com/docs/en/permission-modes.md
- Auto mode configuration: https://code.claude.com/docs/en/auto-mode-config.md
