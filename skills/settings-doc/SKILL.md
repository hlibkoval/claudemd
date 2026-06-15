---
name: settings-doc
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings — configuration scopes, settings files, permissions, permission modes, environment variables, auto mode configuration, and the admin setup decision map for organizations.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared with team? |
| :--- | :--- | :--- | :--- |
| **Managed** | Server-managed, plist/registry, or system `managed-settings.json` | All users on the machine | Yes (deployed by IT) |
| **User** | `~/.claude/settings.json` | You, across all projects | No |
| **Project** | `.claude/settings.json` | All collaborators on the repository | Yes (checked into git) |
| **Local** | `.claude/settings.local.json` | You, in this repository only | No (gitignored) |

Settings precedence (highest → lowest): **Managed > Command-line args > Local > Project > User**. Array-valued settings (permissions, sandbox paths) merge across scopes; scalar values from higher-priority scopes win. Two exceptions: `fallbackModel` (highest-precedence file wins entirely) and `availableModels` (a managed or policy value replaces lower-precedence entries).

### Settings File Locations

| Feature | User scope | Project scope | Local scope |
| :--- | :--- | :--- | :--- |
| Settings | `~/.claude/settings.json` | `.claude/settings.json` | `.claude/settings.local.json` |
| Subagents | `~/.claude/agents/` | `.claude/agents/` | — |
| MCP servers | `~/.claude.json` | `.mcp.json` | `~/.claude.json` (per-project) |
| Plugins | `~/.claude/settings.json` | `.claude/settings.json` | `.claude/settings.local.json` |
| CLAUDE.md | `~/.claude/CLAUDE.md` | `CLAUDE.md` or `.claude/CLAUDE.md` | `CLAUDE.local.md` |

On Windows, `~/.claude` resolves to `%USERPROFILE%\.claude`.

### Managed Settings Delivery Mechanisms

| Mechanism | Platform | Priority | Notes |
| :--- | :--- | :--- | :--- |
| Server-managed (admin console) | All | Highest | Requires Teams/Enterprise; refreshes hourly |
| plist (`com.anthropic.claudecode`) | macOS | High | Deploy via Jamf, Kandji, or MDM profiles |
| Registry (`HKLM\SOFTWARE\Policies\ClaudeCode`) | Windows | High | Deploy via Group Policy or Intune |
| File-based (`managed-settings.json`) | All | Medium | macOS: `/Library/Application Support/ClaudeCode/`; Linux/WSL: `/etc/claude-code/`; Windows: `C:\Program Files\ClaudeCode\` |
| Windows user registry (`HKCU\...`) | Windows | Lowest | Not a strong enforcement channel |

File-based managed settings also support a `managed-settings.d/` drop-in directory. Files merge alphabetically; use numeric prefixes like `10-telemetry.json`, `20-security.json` to control order.

### Key settings.json Fields

| Key | Description | Example |
| :--- | :--- | :--- |
| `model` | Override the default model | `"claude-sonnet-4-6"` |
| `permissions` | Allow/ask/deny rules + mode | see Permission Settings |
| `env` | Environment variables for every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle command hooks | see hooks-doc |
| `apiKeyHelper` | Script to generate auth value | `"/bin/gen-key.sh"` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) | `"stable"` |
| `cleanupPeriodDays` | Delete session files older than N days (default: 30) | `20` |
| `companyAnnouncements` | Messages shown at startup | `["Welcome!"]` |
| `language` | Claude's preferred response language | `"japanese"` |
| `outputStyle` | Output style to adjust system prompt | `"Explanatory"` |
| `tui` | `"fullscreen"` or `"default"` renderer | `"fullscreen"` |
| `editorMode` | `"normal"` or `"vim"` key bindings | `"vim"` |
| `effortLevel` | Persist effort level across sessions: `low`, `medium`, `high`, `xhigh` | `"xhigh"` |
| `alwaysThinkingEnabled` | Enable extended thinking by default | `true` |
| `autoMemoryEnabled` | Enable/disable auto memory | `false` |
| `autoMode` | Configure auto mode classifier rules | `{"environment": ["$defaults", "..."]}` |
| `disableAutoMode` | Set `"disable"` to prevent auto mode | `"disable"` |
| `disableAllHooks` | Disable all hooks and custom status line | `true` |
| `disableAgentView` | Disable background agents and agent view | `true` |
| `disableBundledSkills` | Remove bundled skills and workflows | `true` |
| `skillOverrides` | Per-skill visibility: `"on"`, `"name-only"`, `"user-invocable-only"`, `"off"` | `{"legacy-context": "off"}` |
| `fallbackModel` | Ordered chain of fallback models | `["claude-sonnet-4-6", "claude-haiku-4-5"]` |
| `availableModels` | Restrict selectable models | `["sonnet", "haiku"]` |
| `forceLoginMethod` | Restrict auth: `"claudeai"` or `"console"` | `"claudeai"` |
| `forceLoginOrgUUID` | Require login to a specific org UUID | `"xxxx-xxxx-xxxx"` |
| `requiredMinimumVersion` | Managed only. Block startup if version is older | `"2.1.150"` |
| `requiredMaximumVersion` | Managed only. Block startup if version is newer | `"2.1.150"` |
| `minimumVersion` | Prevent downgrades below this version | `"2.1.100"` |
| `claudeMd` | Managed only. Org-wide CLAUDE.md instructions | `"Always run make lint."` |
| `claudeMdExcludes` | Glob patterns for CLAUDE.md files to skip | `["**/vendor/**/CLAUDE.md"]` |
| `statusLine` | Custom status line command | `{"type": "command", "command": "~/.claude/statusline.sh"}` |
| `attribution` | Customize git commit/PR attribution | `{"commit": "Co-Authored-By: AI", "pr": ""}` |
| `worktree.baseRef` | `"fresh"` (default) or `"head"` for new worktrees | `"head"` |
| `sandbox` | Sandbox settings block | see Sandbox Settings |
| `sshConfigs` | SSH connections for Desktop dropdown | `[{"id": "dev-vm", "sshHost": "user@dev.example.com", "name": "Dev VM"}]` |

### Permission Settings

Nested under `"permissions"` in `settings.json`:

| Key | Description | Example |
| :--- | :--- | :--- |
| `allow` | Auto-approve matching tool uses | `["Bash(npm run *)"]` |
| `ask` | Prompt for confirmation on matching tool uses | `["Bash(git push *)"]` |
| `deny` | Block matching tool uses | `["WebFetch", "Bash(curl *)", "Read(./.env)"]` |
| `defaultMode` | Default permission mode | `"acceptEdits"` |
| `additionalDirectories` | Extra directories for file access | `["../docs/"]` |
| `disableBypassPermissionsMode` | Set `"disable"` to block bypass mode | `"disable"` |
| `skipDangerousModePermissionPrompt` | Skip confirm prompt for bypass mode | `true` |

**Permission rule evaluation order:** deny → ask → allow. First match wins regardless of specificity.

**Permission rule syntax:**

| Pattern | Effect |
| :--- | :--- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Bash(git * main)` | Commands matching `git <anything> main` |
| `Read(./.env)` | Reading the `.env` file |
| `Read(~/.zshrc)` | Home-directory file |
| `Read(//tmp/file)` | Absolute path file |
| `Edit(/src/**/*.ts)` | TypeScript files under project root |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__github__get_*` | All `get_*` tools from the github MCP server |
| `Agent(Explore)` | The Explore subagent |

### Permission Modes

| Mode | What runs without asking | Best for |
| :--- | :--- | :--- |
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, and common filesystem commands | Iterating on code you review afterward |
| `plan` | Reads only (Claude proposes, does not execute edits) | Exploring a codebase before changing it |
| `auto` | Everything, with background safety checks | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down CI scripts |
| `bypassPermissions` | Everything (no checks) | Isolated containers/VMs only |

Switch modes in the CLI with `Shift+Tab`, or set `defaultMode` in `permissions`. Note: `auto` from project or local settings is ignored (v2.1.142+).

**Protected paths** (never auto-approved except in bypassPermissions): `.git`, `.claude`, `.vscode`, `.idea`, `.husky`, shell rc files, `.mcp.json`, `.claude.json`, and others.

### Managed-Only Settings

These settings are only honored when placed in managed settings (server-managed, MDM, or system file). Placing them in user or project settings has no effect.

| Setting | Purpose |
| :--- | :--- |
| `allowManagedPermissionRulesOnly` | Only managed allow/ask/deny rules apply |
| `allowManagedMcpServersOnly` | Only managed MCP allowlist is respected |
| `allowManagedHooksOnly` | Only managed and SDK hooks load |
| `allowAllClaudeAiMcps` | Load claude.ai connectors alongside managed-mcp.json |
| `allowedMcpServers` / `deniedMcpServers` | MCP server allowlist / denylist |
| `channelsEnabled` | Allow channels for the org |
| `strictKnownMarketplaces` / `blockedMarketplaces` | Plugin marketplace controls |
| `strictPluginOnlyCustomization` | Lock skills/agents/hooks/MCP to plugins or managed only |
| `forceRemoteSettingsRefresh` | Block startup until fresh settings are fetched |
| `wslInheritsWindowsSettings` | Extend Windows policy to WSL |
| `allowedChannelPlugins` | Channel plugin allowlist |
| `parentSettingsBehavior` | `"first-wins"` (default) or `"merge"` for SDK-supplied managed settings |
| `policyHelper` | Path to executable that computes managed settings dynamically |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Lock sandbox read paths to managed settings |
| `sandbox.network.allowManagedDomainsOnly` | Lock sandbox network domains to managed settings |
| `claudeMd` | Org-wide CLAUDE.md content |
| `pluginTrustMessage` | Custom message appended to plugin trust warning |

### Sandbox Settings

Configure under the `"sandbox"` key:

| Key | Description |
| :--- | :--- |
| `enabled` | Enable OS-level sandboxing (macOS, Linux, WSL2) |
| `failIfUnavailable` | Exit if sandbox cannot start (for managed hard gates) |
| `autoAllowBashIfSandboxed` | Auto-approve Bash when sandboxed (default: true) |
| `excludedCommands` | Commands that run outside the sandbox |
| `allowUnsandboxedCommands` | Set `false` to block the escape hatch |
| `filesystem.allowWrite` | Paths sandboxed commands can write |
| `filesystem.denyWrite` / `denyRead` | Blocked paths |
| `filesystem.allowRead` | Re-allow reads within a `denyRead` region |
| `network.allowedDomains` | Domains allowed for outbound traffic (supports wildcards) |
| `network.deniedDomains` | Blocked domains (overrides allowedDomains) |
| `network.allowUnixSockets` | (macOS) Unix socket paths |
| `network.allowLocalBinding` | Allow binding to localhost ports (macOS) |

Sandbox path prefixes: `/` = absolute; `~/` = home; `./` or no prefix = project root (project settings) or `~/.claude` (user settings).

### Auto Mode Configuration (`autoMode` key)

Configure which repos, buckets, and services the auto-mode classifier treats as trusted. Set in user settings, local settings, or managed settings — not in shared project settings.

| Field | Purpose |
| :--- | :--- |
| `environment` | Prose descriptions of trusted infrastructure; include `"$defaults"` to keep built-in entries |
| `allow` | Exceptions to soft-deny rules; include `"$defaults"` to keep built-in exceptions |
| `soft_deny` | Destructive actions blocked unless user explicitly requests them |
| `hard_deny` | Unconditional security boundaries; user intent and allow rules do not override these |

Omitting `"$defaults"` replaces the entire default list for that field. Run `claude auto-mode defaults` to inspect built-ins, `claude auto-mode config` to see effective config, and `claude auto-mode critique` for AI feedback on custom rules.

### Key Environment Variables

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key for authentication |
| `ANTHROPIC_MODEL` | Override model for the session |
| `ANTHROPIC_BASE_URL` | Route requests through a proxy or gateway |
| `CLAUDE_CODE_ENABLE_TELEMETRY=1` | Enable OpenTelemetry export |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level: `low`, `medium`, `high`, `xhigh` |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` | Disable auto memory |
| `CLAUDE_CODE_DISABLE_BUNDLED_SKILLS=1` | Disable bundled skills and workflows |
| `CLAUDE_CODE_DISABLE_AGENT_VIEW=1` | Disable background agents |
| `CLAUDE_CODE_ENABLE_AUTO_MODE=1` | Enable auto mode on Bedrock, Vertex, Foundry |
| `CLAUDE_CODE_NO_FLICKER=1` | Enable fullscreen TUI renderer |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY=1` | Skip writing session transcripts |
| `DISABLE_AUTOUPDATER=1` | Disable background auto-updates |
| `DISABLE_TELEMETRY=1` | Opt out of telemetry |
| `DISABLE_AUTO_COMPACT=1` | Disable automatic compaction |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget |
| `BASH_DEFAULT_TIMEOUT_MS` | Bash command timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Maximum Bash timeout (default: 600000) |
| `API_TIMEOUT_MS` | API request timeout (default: 600000) |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude` configuration directory |
| `HTTPS_PROXY` / `HTTP_PROXY` / `NO_PROXY` | Proxy configuration |

Set env vars for all sessions via the `env` key in `settings.json`, or per-session in your shell. Environment variables take precedence over the equivalent `settings.json` field.

### Verify Active Settings

Run `/status` and check the **Setting sources** line on the Status tab. Sources appear as:
- `Enterprise managed settings (remote)` — server-managed
- `Enterprise managed settings (plist)` / `(HKLM)` / `(file)` — endpoint-managed
- `User settings`, `Project settings`, `Project local settings`

Run `claude doctor` to surface validation errors and invalid entries in any settings file.

### Admin Setup Decision Map

| Decision | Key settings |
| :--- | :--- |
| Choose API provider | Anthropic (Teams/Enterprise), Bedrock, Vertex, Foundry |
| Deliver managed settings | Server-managed (admin console), MDM plist/registry, file-based |
| Lock down tools | `permissions.allow`, `permissions.deny`, `allowManagedPermissionRulesOnly` |
| Sandbox Bash | `sandbox.enabled`, `sandbox.network.allowedDomains` |
| Control MCP servers | `allowedMcpServers`, `deniedMcpServers`, `allowManagedMcpServersOnly` |
| Control plugins | `strictKnownMarketplaces`, `blockedMarketplaces` |
| Pin versions | `requiredMinimumVersion`, `requiredMaximumVersion` |
| Monitor usage | OpenTelemetry (`CLAUDE_CODE_ENABLE_TELEMETRY=1`) |

Verify deployment: have a developer run `/status` and check that "Enterprise managed settings" appears.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) — Configuration scopes, settings files, all available settings keys, permissions, sandbox, worktree, attribution, plugin, and hook configuration
- [Admin Setup](references/claude-code-admin-setup.md) — Decision map for organizations: API providers, managed settings delivery, enforcement controls, usage monitoring, and data handling
- [Configure Permissions](references/claude-code-permissions.md) — Permission system, permission rule syntax, tool-specific rules (Bash, Read/Edit, WebFetch, MCP, Agent), working directories, managed settings
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) — Delivering settings from the Claude.ai admin console, caching behavior, security approval dialogs, fail-closed enforcement
- [Environment Variables](references/claude-code-env-vars.md) — Complete reference for all environment variables that control Claude Code behavior
- [Permission Modes](references/claude-code-permission-modes.md) — All permission modes (default, acceptEdits, plan, auto, dontAsk, bypassPermissions), how to switch, auto mode requirements, protected paths
- [Configure Auto Mode](references/claude-code-auto-mode-config.md) — Configuring the auto mode classifier: trusted infrastructure, custom block/allow rules, CLI inspection commands

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Admin Setup: https://code.claude.com/docs/en/admin-setup.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment Variables: https://code.claude.com/docs/en/env-vars.md
- Permission Modes: https://code.claude.com/docs/en/permission-modes.md
- Configure Auto Mode: https://code.claude.com/docs/en/auto-mode-config.md
