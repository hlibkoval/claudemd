---
name: settings-doc
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, environment variables, permission modes, managed/enterprise settings, and auto mode configuration.

## Quick Reference

### Settings Scopes and Files

| Scope | File location | Affects | Shared? |
|:------|:-------------|:--------|:--------|
| Managed | Server-managed, MDM plist/registry, or system `managed-settings.json` | All users on machine | Yes (IT-deployed) |
| User | `~/.claude/settings.json` | You, all projects | No |
| Project | `.claude/settings.json` | All repo collaborators | Yes (git) |
| Local | `.claude/settings.local.json` | You, this project | No (gitignored) |

Precedence (highest first): Managed → CLI args → Local → Project → User. Array settings (e.g. `permissions.allow`) merge across all scopes; scalar values override.

### Managed Settings Delivery Mechanisms

| Mechanism | Delivery | Priority | Platforms |
|:----------|:---------|:---------|:----------|
| Server-managed | Claude.ai admin console | Highest | All |
| plist / registry | macOS `com.anthropic.claudecode`, Windows `HKLM\SOFTWARE\Policies\ClaudeCode` | High | macOS, Windows |
| File-based | macOS `/Library/Application Support/ClaudeCode/managed-settings.json`, Linux/WSL `/etc/claude-code/managed-settings.json`, Windows `C:\Program Files\ClaudeCode\managed-settings.json` | Medium | All |
| Windows user registry | `HKCU\SOFTWARE\Policies\ClaudeCode` | Lowest | Windows only |

File-based managed settings support a `managed-settings.d/` drop-in directory (files merged alphabetically; use numeric prefixes like `10-telemetry.json` to control order).

### Permission Modes

| Mode | What runs without asking | Best for |
|:-----|:------------------------|:---------|
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands | Iterating on code you're reviewing |
| `plan` | Reads only (proposes changes, doesn't apply) | Exploring a codebase before changing |
| `auto` | Everything, with background classifier checks | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down CI and scripts |
| `bypassPermissions` | Everything | Isolated containers/VMs only |

Switch modes with `Shift+Tab` in the CLI, or set `permissions.defaultMode` in settings. The `--permission-mode` flag overrides for one session. As of v2.1.142, `auto` is ignored from project/local settings (use `~/.claude/settings.json`).

### Permission Rule Syntax

Rules follow `Tool` or `Tool(specifier)`. Evaluation order: **deny → ask → allow**. First match wins.

| Rule | Effect |
|:-----|:-------|
| `Bash` | Matches all Bash commands (removes tool from context as a deny rule) |
| `Bash(npm run *)` | Matches commands starting with `npm run ` |
| `Bash(git * main)` | Matches `git checkout main`, `git push origin main`, etc. |
| `Read(./.env)` | Matches reading the `.env` file in the project root |
| `Read(~/.zshrc)` | Matches reading home-directory file |
| `Read(//**/.env)` | Matches any `.env` anywhere on the filesystem |
| `Edit(/src/**)` | Matches edits under `<project>/src/` |
| `WebFetch(domain:example.com)` | Matches fetch requests to example.com |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `Agent(Explore)` | Matches the Explore subagent |
| `Skill(commit)` | Matches the `commit` skill |

Path anchors for Read/Edit rules: `//path` = absolute, `~/path` = home-relative, `/path` = project-root-relative, `path` or `./path` = cwd-relative.

### Key `settings.json` Keys (Selected)

| Key | Description |
|:----|:------------|
| `permissions.allow/ask/deny` | Permission rule arrays |
| `permissions.defaultMode` | Default permission mode |
| `permissions.additionalDirectories` | Extra directories for file access |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to block bypassPermissions |
| `env` | Environment variables applied to every session |
| `model` | Override default model (takes effect on next session) |
| `apiKeyHelper` | Script to generate auth value (refreshed via `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`) |
| `hooks` | Lifecycle hook definitions |
| `autoMode` | Auto mode classifier configuration (`environment`, `allow`, `soft_deny`, `hard_deny`) |
| `sandbox.enabled` | Enable OS-level bash sandboxing |
| `sandbox.network.allowedDomains` | Domains allowed in sandboxed commands |
| `allowManagedPermissionRulesOnly` | (Managed only) Block user/project permission rules |
| `allowManagedHooksOnly` | (Managed only) Block non-managed hooks |
| `forceRemoteSettingsRefresh` | (Managed only) Block startup until fresh remote settings fetched |
| `requiredMinimumVersion` | (Managed only) Minimum version to start |
| `requiredMaximumVersion` | (Managed only) Maximum version allowed to start |
| `strictPluginOnlyCustomization` | (Managed only) Block skills/agents/hooks/MCP from user/project sources |
| `claudeMd` | (Managed only) Org-wide CLAUDE.md instructions |
| `disableAutoMode` | Set to `"disable"` to prevent auto mode |
| `disableAgentView` | Set to `true` to disable background agents |
| `effortLevel` | Persist effort level across sessions (`low`, `medium`, `high`, `xhigh`) |
| `language` | Claude's preferred response language |
| `worktree.baseRef` | Ref new worktrees branch from (`"fresh"` or `"head"`) |
| `autoUpdatesChannel` | Release channel: `"stable"` or `"latest"` (default) |
| `minimumVersion` | Prevent auto-update below this version |
| `policyHelper` | (Managed, MDM/file only) Executable to compute managed settings dynamically |

### Managed-Only Settings (no effect in user/project settings)

`allowAllClaudeAiMcps`, `allowedChannelPlugins`, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowManagedPermissionRulesOnly`, `blockedMarketplaces`, `channelsEnabled`, `claudeMd`, `forceRemoteSettingsRefresh`, `pluginTrustMessage`, `sandbox.filesystem.allowManagedReadPathsOnly`, `sandbox.network.allowManagedDomainsOnly`, `strictKnownMarketplaces`, `strictPluginOnlyCustomization`, `wslInheritsWindowsSettings`

### Sandbox Settings

Sandboxing is under `"sandbox": { ... }` in `settings.json`. Key fields:

| Key | Description |
|:----|:------------|
| `enabled` | Enable bash sandboxing (default: `false`) |
| `failIfUnavailable` | Exit if sandbox can't start (default: `false`) |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: `true`) |
| `excludedCommands` | Commands to run outside the sandbox |
| `filesystem.allowWrite` | Paths sandboxed commands can write |
| `filesystem.denyRead` | Paths sandboxed commands cannot read |
| `network.allowedDomains` | Allowed outbound domains (wildcards supported) |
| `network.deniedDomains` | Blocked outbound domains (takes precedence) |
| `network.allowManagedDomainsOnly` | (Managed only) Only managed-settings domains respected |

### Auto Mode Configuration (`autoMode`)

The `autoMode` block configures the classifier used by auto mode. All entries are prose, not regex.

| Field | Description |
|:------|:------------|
| `environment` | Trusted repos, buckets, domains. Include `"$defaults"` to inherit built-ins |
| `allow` | Exceptions to soft_deny rules. Include `"$defaults"` to inherit built-ins |
| `soft_deny` | Destructive actions blocked unless user explicitly requests them |
| `hard_deny` | Unconditionally blocked actions (user intent cannot override) |

Omitting `"$defaults"` replaces the entire built-in list. The classifier does not read `autoMode` from shared project settings (`.claude/settings.json`).

CLI inspection commands:
- `claude auto-mode defaults` — print built-in rules as JSON
- `claude auto-mode config` — print effective config with your settings applied
- `claude auto-mode critique` — get AI feedback on custom rules

### Key Environment Variables (Selected)

| Variable | Description |
|:---------|:------------|
| `ANTHROPIC_API_KEY` | API key; overrides subscription when set |
| `ANTHROPIC_MODEL` | Model override for the session |
| `ANTHROPIC_BASE_URL` | Route requests through a proxy or gateway |
| `CLAUDE_CODE_USE_BEDROCK` / `_VERTEX` / `_FOUNDRY` | Switch to cloud providers |
| `CLAUDE_CODE_EFFORT_LEVEL` | `low`, `medium`, `high`, `xhigh`, `max`, or `auto` |
| `CLAUDE_CODE_ENABLE_AUTO_MODE` | Set to `1` to enable auto mode on Bedrock/Vertex/Foundry |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | `1` = disable, `0` = force on |
| `CLAUDE_CODE_DISABLE_AGENT_VIEW` | Set to `1` to disable background agents |
| `CLAUDE_CODE_DISABLE_THINKING` | Set to `1` to force-disable extended thinking |
| `CLAUDE_CODE_NO_FLICKER` / `tui` setting | Enable fullscreen rendering |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess environments |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | Refresh interval for `apiKeyHelper` credentials |
| `CLAUDE_CONFIG_DIR` | Override config directory (default `~/.claude`) |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout (default 120,000ms) |
| `BASH_MAX_TIMEOUT_MS` | Max bash command timeout (default 600,000ms) |
| `API_TIMEOUT_MS` | API request timeout (default 600,000ms) |
| `DISABLE_AUTOUPDATER` | Set to `1` to disable background auto-updates |
| `DISABLE_TELEMETRY` / `DO_NOT_TRACK` | Opt out of telemetry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set to `1` to enable OpenTelemetry export |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget |
| `MCP_TIMEOUT` | MCP server startup timeout (default 30,000ms) |
| `CLAUDE_CODE_DISABLE_WORKFLOWS` | Set to `1` to disable dynamic workflows |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Equivalent to disabling autoupdater, feedback, error reporting, and telemetry |

### Verifying Active Settings

Run `/status` inside Claude Code. The `Setting sources` line lists each settings layer loaded. Managed settings show the delivery channel, e.g. `Enterprise managed settings (remote)`, `(plist)`, `(HKLM)`, `(HKCU)`, or `(file)`. Use `/permissions` to view and manage active permission rules.

### Settings Precedence for Arrays

Array settings like `permissions.allow`, `permissions.deny`, `sandbox.filesystem.allowWrite` **concatenate and deduplicate** across scopes rather than overriding. This means a managed `deny` list and a user `deny` list both apply.

### Server-Managed Settings Notes

- Available for Claude for Teams/Enterprise only (requires `api.anthropic.com` access)
- Applied at authentication time; refreshed hourly during active sessions
- Security approval dialogs shown for hooks, shell-command settings, and custom env vars
- Not available on Bedrock, Vertex AI, Foundry, or custom `ANTHROPIC_BASE_URL`
- `managed-mcp.json` cannot be distributed via server-managed settings (use `allowedMcpServers`/`deniedMcpServers` instead)

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — Full settings reference: configuration scopes, all `settings.json` keys, permission rules, sandbox settings, attribution, worktree config, precedence
- [Set up Claude Code for your organization](references/claude-code-admin-setup.md) — Admin deployment decision map: API providers, settings delivery mechanisms, enforcement controls, usage visibility, data handling
- [Configure permissions](references/claude-code-permissions.md) — Permission rules syntax, modes, tool-specific patterns, managed settings, hooks, working directories
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — Server-managed delivery, caching, fail-closed enforcement, security approval dialogs, audit logging
- [Environment variables](references/claude-code-env-vars.md) — Complete env var reference: how to set them, precedence, full variable listing
- [Choose a permission mode](references/claude-code-permission-modes.md) — Each mode explained: acceptEdits, plan, auto, dontAsk, bypassPermissions; switching modes; protected paths
- [Configure auto mode](references/claude-code-auto-mode-config.md) — `autoMode` settings block: defining trusted infrastructure, overriding block/allow rules, CLI inspection commands

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Set up Claude Code for your organization: https://code.claude.com/docs/en/admin-setup.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
