---
name: settings-doc
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for configuring Claude Code, including settings files, permission rules, permission modes, environment variables, and enterprise managed settings.

## Quick Reference

### Configuration Scopes & File Locations

| Scope | File | Applies to | Shared? |
| :--- | :--- | :--- | :--- |
| **Managed** | `managed-settings.json` / server / MDM | All users on machine | Yes (deployed by IT) |
| **User** | `~/.claude/settings.json` | You, all projects | No |
| **Project** | `.claude/settings.json` | All collaborators | Yes (git) |
| **Local** | `.claude/settings.local.json` | You, this project | No (gitignored) |

**Precedence (highest to lowest):** Managed → CLI args → Local → Project → User

Array settings (like `permissions.allow`) **concatenate and deduplicate** across scopes rather than override.

### Managed Settings Delivery Mechanisms

| Mechanism | Location | Platforms |
| :--- | :--- | :--- |
| Server-managed | Claude.ai admin console → API | All (Teams/Enterprise only) |
| macOS plist | `com.anthropic.claudecode` managed prefs | macOS |
| Windows registry | `HKLM\SOFTWARE\Policies\ClaudeCode` | Windows |
| File-based | macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`; Linux/WSL: `/etc/claude-code/managed-settings.json`; Windows: `C:\Program Files\ClaudeCode\managed-settings.json` | All |
| Drop-in directory | `managed-settings.d/*.json` alongside file-based | All |

Within the managed tier, precedence is: server-managed > MDM/plist > file-based > HKCU (Windows only). Only one managed source is used per tier; sources do not merge across tiers.

### Permission Modes

| Mode | What runs without asking | Best for |
| :--- | :--- | :--- |
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands | Iterating on code |
| `plan` | Reads only (Claude proposes plan first) | Exploring before changing |
| `auto` | Everything, with background classifier checks | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down CI/scripts |
| `bypassPermissions` | Everything (no prompts at all) | Isolated containers/VMs only |

Switch modes with `Shift+Tab` in the CLI, or set `permissions.defaultMode` in settings. Note: `auto` is ignored when set in `.claude/settings.json` or `.claude/settings.local.json` (use `~/.claude/settings.json`).

**Protected paths** (never auto-approved except in `bypassPermissions`): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `commands/`, `agents/`, `skills/`, `worktrees/`), plus dotfiles like `.gitconfig`, `.bashrc`, `.zshrc`, `.mcp.json`.

### Permission Rule Syntax

Format: `Tool` or `Tool(specifier)`

Evaluation order: **deny first → ask → allow** (first match wins). A bare tool name as a deny rule removes the tool from Claude's context entirely; a scoped rule like `Bash(rm *)` leaves the tool available and blocks matching calls.

| Rule | Matches |
| :--- | :--- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Bash(git * main)` | Commands like `git checkout main` |
| `Read(./.env)` | Reading `.env` in current directory |
| `Read(//**/.env)` | Any `.env` anywhere on filesystem |
| `Edit(/src/**)` | Edits under `<project>/src/` |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__github__*` | All tools from the `github` MCP server |
| `Agent(my-agent)` | The `my-agent` subagent |

**Read/Edit path anchoring:**
- `//path` — absolute from filesystem root
- `~/path` — relative to home directory
- `/path` — relative to project root
- `path` or `./path` — relative to current directory

**Wildcard `*`** matches any sequence including spaces. A space before `*` (like `Bash(ls *)`) enforces a word boundary. Compound commands: each subcommand is checked independently.

**Bash read-only commands** (never need a prompt in any mode): `ls`, `cat`, `echo`, `pwd`, `head`, `tail`, `grep`, `find`, `wc`, `which`, `diff`, `stat`, `du`, `cd`, read-only `git`.

### Key settings.json Settings

| Key | Description | Example |
| :--- | :--- | :--- |
| `permissions.allow` | Rules to allow without prompting | `["Bash(npm run *)"]` |
| `permissions.deny` | Rules to deny | `["Read(./.env)"]` |
| `permissions.ask` | Rules to prompt for confirmation | `["Bash(git push *)"]` |
| `permissions.defaultMode` | Default permission mode | `"acceptEdits"` |
| `permissions.additionalDirectories` | Extra working directories | `["../docs/"]` |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `env` | Environment variables for every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle hooks (see hooks-doc) | — |
| `apiKeyHelper` | Script to generate auth token | `"/bin/gen_key.sh"` |
| `autoUpdatesChannel` | Update channel: `"stable"` or `"latest"` | `"stable"` |
| `cleanupPeriodDays` | Session file retention (default 30) | `20` |
| `effortLevel` | Effort level: `low/medium/high/xhigh` | `"high"` |
| `language` | Claude's response language | `"japanese"` |
| `tui` | UI renderer: `"default"` or `"fullscreen"` | `"fullscreen"` |
| `editorMode` | Key bindings: `"normal"` or `"vim"` | `"vim"` |
| `outputStyle` | System prompt output style | `"Explanatory"` |
| `skillOverrides` | Per-skill visibility: `"on"/"name-only"/"user-invocable-only"/"off"` | `{"deploy": "off"}` |
| `autoMemoryEnabled` | Enable/disable auto memory | `false` |
| `autoMode` | Configure auto mode classifier rules | See auto-mode-config ref |

### Managed-Only Settings (no effect in user/project settings)

| Key | Purpose |
| :--- | :--- |
| `allowManagedPermissionRulesOnly` | Block user/project from defining allow/ask/deny rules |
| `allowManagedHooksOnly` | Only managed hooks and SDK hooks load |
| `allowManagedMcpServersOnly` | Only allowedMcpServers from managed settings apply |
| `allowedChannelPlugins` | Allowlist for channel plugins |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `channelsEnabled` | Allow channels for the organization |
| `claudeMd` | Org-managed CLAUDE.md instructions |
| `forceRemoteSettingsRefresh` | Block startup until remote settings fetched |
| `pluginTrustMessage` | Custom message on plugin trust warning |
| `strictKnownMarketplaces` | Allowlist of permitted marketplace sources |
| `strictPluginOnlyCustomization` | Block skills/agents/hooks/MCP from user/project sources |
| `wslInheritsWindowsSettings` | WSL reads Windows policy chain too |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed allowRead paths apply |
| `sandbox.network.allowManagedDomainsOnly` | Only managed allowedDomains apply |

### Global Config Settings (stored in `~/.claude.json`, not settings.json)

| Key | Description |
| :--- | :--- |
| `autoConnectIde` | Auto-connect to IDE when launched externally |
| `autoInstallIdeExtension` | Auto-install IDE extension in VS Code |
| `externalEditorContext` | Prepend last response when opening external editor |
| `teammateDefaultModel` | Default model for agent team members |

### Worktree Settings

| Key | Description |
| :--- | :--- |
| `worktree.baseRef` | `"fresh"` (default, from remote) or `"head"` (from local HEAD) |
| `worktree.symlinkDirectories` | Dirs to symlink into worktrees (e.g. `["node_modules"]`) |
| `worktree.sparsePaths` | Sparse-checkout paths per worktree |
| `worktree.bgIsolation` | `"worktree"` (default) or `"none"` for background session isolation |

### Sandbox Settings (under `sandbox` key)

| Key | Description |
| :--- | :--- |
| `enabled` | Enable Bash sandboxing (macOS, Linux, WSL2) |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `excludedCommands` | Commands that run outside the sandbox |
| `filesystem.allowWrite` | Additional paths sandboxed commands can write |
| `filesystem.denyRead` | Paths sandboxed commands cannot read |
| `network.allowedDomains` | Domains allowed for outbound traffic (supports `*.`) |
| `network.deniedDomains` | Blocked domains (takes precedence over allowedDomains) |
| `network.allowLocalBinding` | Allow binding to localhost ports (macOS only) |

### Key Environment Variables

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key (overrides subscription when set) |
| `ANTHROPIC_MODEL` | Override default model |
| `ANTHROPIC_BASE_URL` | Route requests through proxy/gateway |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max bash command timeout (default: 600000) |
| `API_TIMEOUT_MS` | API request timeout (default: 600000) |
| `DISABLE_AUTOUPDATER` | Disable auto-updates |
| `DISABLE_TELEMETRY` / `DO_NOT_TRACK` | Opt out of telemetry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry data collection |
| `CLAUDE_CODE_DISABLE_THINKING` | Force-disable extended thinking |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level: `low/medium/high/xhigh/max/auto` |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen rendering |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `DISABLE_AUTO_COMPACT` | Disable automatic context compaction |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Skip writing session transcripts to disk |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess environments |
| `CLAUDE_ENV_FILE` | Shell script sourced before each Bash command |
| `CLAUDECODE` | Set to `1` in Claude-spawned subprocesses |

Environment variables set in the shell take precedence over the same behavior configured via `settings.json` `env` key.

### Server-Managed Settings (Claude.ai Admin Console)

Requires Teams or Enterprise plan. Settings delivered at auth time and refreshed hourly.

- Configure at: Claude.ai > Admin Settings > Claude Code > Managed settings
- Supports all `settings.json` keys except OS-level-only ones (`policyHelper`, `wslInheritsWindowsSettings`)
- Cannot distribute MCP server configurations via this method
- Security dialog shown to users when hooks or custom env vars are present
- `forceRemoteSettingsRefresh: true` blocks startup until fresh fetch succeeds

**Verify delivery:** User runs `/status` → look for `Enterprise managed settings (remote)` line.

### Admin Deployment Decisions

| Decision | Options |
| :--- | :--- |
| API provider | Teams/Enterprise, Console, Bedrock, Vertex, Foundry |
| Settings delivery | Server-managed (no MDM needed), plist/registry (MDM), file-based |
| Permission lockdown | `allowManagedPermissionRulesOnly`, `disableBypassPermissionsMode` |
| MCP server control | `allowedMcpServers`, `deniedMcpServers`, `allowManagedMcpServersOnly` |
| Plugin control | `strictKnownMarketplaces`, `blockedMarketplaces`, `strictPluginOnlyCustomization` |
| Sandboxing | `sandbox.enabled`, `sandbox.network.allowedDomains` |
| Usage visibility | OpenTelemetry (`CLAUDE_CODE_ENABLE_TELEMETRY`), analytics dashboard |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — complete settings reference: all keys, scopes, precedence, sandbox, attribution, plugin configuration, and `$schema` support
- [Set up Claude Code for your organization](references/claude-code-admin-setup.md) — admin decision map: API providers, settings delivery, enforcement controls, usage visibility, and data handling
- [Configure permissions](references/claude-code-permissions.md) — permission system, rule syntax, tool-specific patterns (Bash, PowerShell, Read/Edit, WebFetch, MCP, Agent), hooks, working directories, sandboxing interaction, and managed-only settings
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — server delivery via Claude.ai admin console: setup, caching, fail-closed startup, security dialogs, and security considerations
- [Environment variables](references/claude-code-env-vars.md) — full reference for all environment variables, how to set them, and precedence rules
- [Choose a permission mode](references/claude-code-permission-modes.md) — mode details (default, acceptEdits, plan, auto, dontAsk, bypassPermissions), how to switch, auto mode classifier behavior, and protected paths
- [Configure auto mode](references/claude-code-auto-mode-config.md) — configure the auto mode classifier with trusted infrastructure, override block/allow rules, and inspect effective config

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Set up Claude Code for your organization: https://code.claude.com/docs/en/admin-setup.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
