---
name: settings-doc
description: Complete official documentation for configuring Claude Code — settings files and scopes, all settings keys, environment variables, permissions and permission modes, managed/server-managed settings, admin setup, and auto mode configuration.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for configuring Claude Code: settings files and scopes, the full settings key reference, environment variables, permissions and permission modes, managed settings, server-managed settings, admin setup, and auto mode configuration.

## Quick Reference

### Configuration scopes and file locations

| Scope | Location | Shared with team? | Overrides |
| :--- | :--- | :--- | :--- |
| **Managed** | Server, plist/registry, or `managed-settings.json` | Yes (IT-deployed) | All other scopes |
| **Local** | `.claude/settings.local.json` | No (gitignored) | Project, User |
| **Project** | `.claude/settings.json` | Yes (committed) | User |
| **User** | `~/.claude/settings.json` | No | — |

Precedence (highest to lowest): Managed → CLI args → Local → Project → User.

**Array settings** (`permissions.allow`, `sandbox.filesystem.allowWrite`, etc.) **merge** across scopes — lower-priority scopes can add entries, not override.

**Managed settings file locations:**

| Platform | Path |
| :--- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux / WSL | `/etc/claude-code/managed-settings.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-settings.json` |

Drop-in directory: `managed-settings.d/*.json` in the same folder — files merged alphabetically on top of `managed-settings.json` (scalars overridden, arrays concatenated + deduped).

**Global config** (`~/.claude.json`): stores OAuth session, user/local MCP configs, per-project state. Do not put settings.json keys here.

### Key settings reference

| Key | Description | Example |
| :--- | :--- | :--- |
| `agent` | Run main thread as a named subagent | `"code-reviewer"` |
| `allowedHttpHookUrls` | Allowlist of URL patterns for HTTP hooks | `["https://hooks.example.com/*"]` |
| `allowManagedHooksOnly` | (Managed only) Block non-managed hooks | `true` |
| `allowManagedPermissionRulesOnly` | (Managed only) Block user/project permission rules | `true` |
| `alwaysThinkingEnabled` | Enable extended thinking by default | `true` |
| `apiKeyHelper` | Script to generate auth value | `"/bin/generate_key.sh"` |
| `attribution` | Customize git commit/PR attribution | `{"commit": "...", "pr": ""}` |
| `autoMemoryEnabled` | Enable/disable auto memory (default: `true`) | `false` |
| `autoMode` | Configure auto mode classifier rules | `{"environment": ["$defaults", "..."]}` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) | `"stable"` |
| `availableModels` | Restrict model choices in `/model` | `["sonnet", "haiku"]` |
| `cleanupPeriodDays` | Days before session files are deleted (default: 30) | `20` |
| `companyAnnouncements` | Startup announcements (cycled randomly) | `["Welcome to Acme!"]` |
| `defaultShell` | `"bash"` (default) or `"powershell"` | `"powershell"` |
| `disableAgentView` | Disable background agents / agent view | `true` |
| `disableAllHooks` | Disable all hooks and custom status line | `true` |
| `disableAutoMode` | Prevent auto mode from being used | `"disable"` |
| `disabledMcpjsonServers` | Reject specific `.mcp.json` servers | `["filesystem"]` |
| `editorMode` | Input key bindings: `"normal"` or `"vim"` | `"vim"` |
| `effortLevel` | Persist effort level across sessions | `"xhigh"` |
| `enableAllProjectMcpServers` | Auto-approve all project `.mcp.json` servers | `true` |
| `enabledMcpjsonServers` | Approve specific `.mcp.json` servers | `["memory", "github"]` |
| `env` | Environment variables applied every session | `{"FOO": "bar"}` |
| `fileSuggestion` | Custom script for `@` file autocomplete | `{"type": "command", "command": "~/.claude/file-suggestion.sh"}` |
| `forceLoginMethod` | `"claudeai"` or `"console"` | `"claudeai"` |
| `forceLoginOrgUUID` | Require login to specific org(s) | `"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"` |
| `forceRemoteSettingsRefresh` | (Managed only) Block startup until settings fetched | `true` |
| `hooks` | Lifecycle hook commands | See hooks-doc |
| `includeGitInstructions` | Include git workflow in system prompt (default: `true`) | `false` |
| `language` | Claude's preferred response language | `"japanese"` |
| `minimumVersion` | Floor for auto-updates / manual updates | `"2.1.100"` |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `modelOverrides` | Map Anthropic model IDs to provider-specific IDs | `{"claude-opus-4-6": "arn:aws:..."}` |
| `outputStyle` | System prompt output style | `"Explanatory"` |
| `permissions` | See permission settings table below | — |
| `plansDirectory` | Where plan files are stored | `"./plans"` |
| `policyHelper` | (MDM/file-based managed only) Dynamic managed settings executable | `{"path": "/usr/local/bin/claude-policy"}` |
| `preferredNotifChannel` | Notification method | `"terminal_bell"` |
| `sandbox` | Sandboxing config | See sandbox table below |
| `skillOverrides` | Per-skill visibility: `"on"`, `"name-only"`, `"user-invocable-only"`, `"off"` | `{"legacy-context": "name-only"}` |
| `skipWebFetchPreflight` | Skip WebFetch domain safety check | `true` |
| `statusLine` | Custom status line script | `{"type": "command", "command": "~/.claude/statusline.sh"}` |
| `syntaxHighlightingDisabled` | Disable syntax highlighting | `true` |
| `tui` | `"fullscreen"` (alt-screen) or `"default"` | `"fullscreen"` |
| `viewMode` | Default transcript view: `"default"`, `"verbose"`, `"focus"` | `"verbose"` |
| `voice` | Voice dictation settings | `{"enabled": true, "mode": "tap"}` |
| `wslInheritsWindowsSettings` | (Windows managed only) WSL reads Windows policy chain | `true` |

### Permission settings

| Key | Description | Example |
| :--- | :--- | :--- |
| `permissions.allow` | Array of tool rules to allow without prompting | `["Bash(npm run *)", "Read(~/.zshrc)"]` |
| `permissions.ask` | Array of tool rules to prompt for confirmation | `["Bash(git push *)"]` |
| `permissions.deny` | Array of tool rules to block | `["WebFetch", "Read(./.env)"]` |
| `permissions.additionalDirectories` | Additional working directories for file access | `["../docs/"]` |
| `permissions.defaultMode` | Default permission mode | `"acceptEdits"` |
| `permissions.disableBypassPermissionsMode` | Prevent `bypassPermissions` mode | `"disable"` |
| `permissions.skipDangerousModePermissionPrompt` | Skip bypass-mode confirmation prompt | `true` |

**Rule evaluation order:** deny → ask → allow. First match wins.

**Permission rule syntax:**

| Rule | Effect |
| :--- | :--- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Bash(git * main)` | Commands matching `git <anything> main` |
| `Read(./.env)` | Reading `.env` in current directory |
| `Read(//Users/alice/secrets/**)` | Absolute path (note double `//`) |
| `Edit(/src/**/*.ts)` | Edits under `<project-root>/src/` |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `Agent(Explore)` | Explore subagent |

### Permission modes

| Mode | What runs without asking | Set via |
| :--- | :--- | :--- |
| `default` | Reads only | Shift+Tab, `--permission-mode default` |
| `acceptEdits` | Reads + file edits + common filesystem cmds | Shift+Tab |
| `plan` | Reads only (no edits) | Shift+Tab, `/plan`, `--permission-mode plan` |
| `auto` | Everything, with background classifier checks | Shift+Tab (if eligible) |
| `dontAsk` | Only pre-approved tools | `--permission-mode dontAsk` |
| `bypassPermissions` | Everything (no checks) | `--permission-mode bypassPermissions` |

**Auto mode requirements:** Max/Team/Enterprise/API plan; admin-enabled on Team/Enterprise; Claude Sonnet 4.6, Opus 4.6, or Opus 4.7 (Team/Enterprise/API); Anthropic API only.

**Protected paths** (never auto-approved except in `bypassPermissions`): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `commands/`, `agents/`, `skills/`, `worktrees/`); `.gitconfig`, `.gitmodules`, shell rc files, `.mcp.json`, `.claude.json`.

**Set default mode:**
```json
{
  "permissions": {
    "defaultMode": "acceptEdits"
  }
}
```

### Sandbox settings

| Key | Description |
| :--- | :--- |
| `sandbox.enabled` | Enable bash sandboxing (macOS/Linux/WSL2) |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash commands when sandboxed (default: `true`) |
| `sandbox.excludedCommands` | Commands that run outside the sandbox |
| `sandbox.filesystem.allowWrite` | Paths sandboxed commands can write |
| `sandbox.filesystem.denyWrite` | Paths sandboxed commands cannot write |
| `sandbox.filesystem.denyRead` | Paths sandboxed commands cannot read |
| `sandbox.filesystem.allowRead` | Re-allow reading within `denyRead` regions |
| `sandbox.network.allowedDomains` | Allowed outbound domains (supports wildcards) |
| `sandbox.network.deniedDomains` | Blocked outbound domains |
| `sandbox.network.allowManagedDomainsOnly` | (Managed only) Only managed `allowedDomains` respected |
| `sandbox.bwrapPath` | (Managed only, Linux/WSL2) Path to `bwrap` binary |

**Path prefixes in sandbox settings:** `/` = absolute, `~/` = home-relative, `./` or bare = project-root-relative (in project settings) or `~/.claude`-relative (in user settings).

### Auto mode configuration (`autoMode`)

Configure the auto mode classifier in `~/.claude/settings.json`, `.claude/settings.local.json`, or managed settings (not shared project settings).

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp",
      "Trusted cloud buckets: s3://acme-build-artifacts",
      "Trusted internal domains: *.corp.example.com"
    ],
    "allow": ["$defaults", "Deploying to staging is allowed"],
    "soft_deny": ["$defaults", "Never run database migrations outside the migrations CLI"],
    "hard_deny": ["$defaults", "Never send repository contents to third-party code-review APIs"]
  }
}
```

**Classifier precedence:** hard_deny → soft_deny → allow → explicit user intent.

Include `"$defaults"` to inherit built-in rules at that position; omitting it replaces the entire list.

**CLI inspection:**
```bash
claude auto-mode defaults   # print built-in rules
claude auto-mode config     # print effective rules (with your settings applied)
claude auto-mode critique   # AI review of your custom rules
```

### Server-managed settings (Teams/Enterprise)

Configure at: Claude.ai → Admin Settings → Claude Code → Managed settings.

- Settings delivered at auth time; refreshed hourly
- Requires network access to `api.anthropic.com`
- Not available with Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`
- Shell commands, custom env vars, and hooks require user approval (security dialog)
- `forceRemoteSettingsRefresh: true` blocks startup until fresh settings are fetched

**Precedence within managed tier:** server-managed → MDM/OS-level → file-based → HKCU registry (Windows only). Only one managed source is used; they do not merge across tiers.

### Managed-only settings (only honored from managed tier)

`allowedChannelPlugins`, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowManagedPermissionRulesOnly`, `blockedMarketplaces`, `channelsEnabled`, `claudeMd`, `forceRemoteSettingsRefresh`, `pluginTrustMessage`, `sandbox.filesystem.allowManagedReadPathsOnly`, `sandbox.network.allowManagedDomainsOnly`, `strictKnownMarketplaces`, `wslInheritsWindowsSettings`.

Also: `policyHelper` and `bwrapPath`/`socatPath` are honored only from MDM or system `managed-settings.json` (not server-managed).

### Key environment variables

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key (overrides subscription when set) |
| `ANTHROPIC_BASE_URL` | Override API endpoint (proxy/gateway) |
| `ANTHROPIC_MODEL` | Override model |
| `BASH_DEFAULT_TIMEOUT_MS` | Default Bash timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max Bash timeout (default: 600000) |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry (`1`) |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen rendering (`1`) |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory (`1`) |
| `CLAUDE_CODE_DISABLE_THINKING` | Force-disable extended thinking (`1`) |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max`, `auto` |
| `DISABLE_AUTOUPDATER` | Disable background auto-updates (`1`) |
| `DISABLE_TELEMETRY` / `DO_NOT_TRACK` | Opt out of telemetry (`1`) |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching (`1`) |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server for network connections |

See the [full env var reference](references/claude-code-env-vars.md) for all ~200+ variables.

### Verify configuration

```bash
/status     # shows active settings sources and their origin
/permissions  # lists all permission rules and their source file
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — settings files, scopes, all settings keys, permission rules, sandbox, attribution, plugin configuration, environment variables overview
- [Configure permissions](references/claude-code-permissions.md) — permission system, rule syntax, tool-specific rules (Bash, Read/Edit, WebFetch, MCP, Agent), hooks integration, working directories, managed settings
- [Choose a permission mode](references/claude-code-permission-modes.md) — all modes, how to switch, acceptEdits, plan mode, auto mode, dontAsk, bypassPermissions, protected paths
- [Configure auto mode](references/claude-code-auto-mode-config.md) — trusted infrastructure, environment/allow/soft_deny/hard_deny fields, CLI inspection commands, reviewing denials
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — admin console setup, delivery, caching, fail-closed enforcement, security dialogs, audit logging
- [Set up Claude Code for your organization](references/claude-code-admin-setup.md) — admin decision map: API provider, settings delivery mechanisms, enforcement controls, usage monitoring, data handling
- [Environment variables](references/claude-code-env-vars.md) — complete reference for all environment variables

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Set up Claude Code for your organization: https://code.claude.com/docs/en/admin-setup.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
