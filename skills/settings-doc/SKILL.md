---
name: settings-doc
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, environment variables, permission modes, server-managed settings, auto mode configuration, and admin setup.

## Quick Reference

### Configuration Scopes and File Locations

| Scope | File | Who it affects | Shared? |
|:------|:-----|:---------------|:--------|
| **Managed** | Server-managed, plist/registry, or system `managed-settings.json` | All users on the machine | Yes (deployed by IT) |
| **User** | `~/.claude/settings.json` | You, across all projects | No |
| **Project** | `.claude/settings.json` | All collaborators on this repo | Yes (committed to git) |
| **Local** | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |

**Precedence** (highest to lowest): Managed > Command line args > Local project > Shared project > User

**Array settings** (e.g., `permissions.allow`, `permissions.deny`, `sandbox.filesystem.allowWrite`) **merge across scopes** — they are concatenated and deduplicated, not replaced.

**Managed settings delivery mechanisms** (in precedence order):
1. Server-managed (Claude.ai admin console) — Teams/Enterprise only
2. macOS plist: `com.anthropic.claudecode` / Windows registry: `HKLM\SOFTWARE\Policies\ClaudeCode`
3. File-based: `/Library/Application Support/ClaudeCode/` (macOS), `/etc/claude-code/` (Linux/WSL), `C:\Program Files\ClaudeCode\` (Windows)
4. Windows user registry: `HKCU\SOFTWARE\Policies\ClaudeCode`

### Key settings.json Fields (Selected)

| Key | Description |
|:----|:------------|
| `permissions` | Permission rules: `allow`, `ask`, `deny`, `defaultMode`, `additionalDirectories` |
| `env` | Environment variables applied to every session |
| `hooks` | Lifecycle hook configuration |
| `model` | Default model override |
| `apiKeyHelper` | Script to generate auth credentials |
| `autoMode` | Auto mode classifier configuration |
| `sandbox` | Sandboxing settings |
| `enabledPlugins` | Plugin enable/disable map |
| `extraKnownMarketplaces` | Additional plugin marketplaces |
| `companyAnnouncements` | Startup announcements for users |
| `minimumVersion` | Floor preventing downgrade below a version |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) |
| `availableModels` | Restrict model selection via `/model` |
| `defaultShell` | `"bash"` (default) or `"powershell"` |
| `disableAllHooks` | Disable all hooks and custom status lines |
| `disableAutoMode` | `"disable"` to prevent auto mode |
| `disableBypassPermissionsMode` | `"disable"` to block bypass permissions mode |
| `cleanupPeriodDays` | Session transcript retention days (default: 30) |
| `language` | Claude's preferred response language |
| `editorMode` | `"normal"` or `"vim"` for input prompt |
| `effortLevel` | Persist effort level: `"low"`, `"medium"`, `"high"`, `"xhigh"` |
| `tui` | `"fullscreen"` or `"default"` renderer |
| `outputStyle` | System prompt output style |
| `autoMemoryEnabled` | Enable/disable auto memory (default: true) |
| `spinnerTipsEnabled` | Show tips while Claude works (default: true) |
| `showThinkingSummaries` | Show extended thinking summaries |
| `syntaxHighlightingDisabled` | Disable syntax highlighting |
| `preferredNotifChannel` | Notification method: `"auto"`, `"terminal_bell"`, `"iterm2"`, etc. |
| `attribution` | Git commit and PR attribution customization |
| `worktree.*` | Worktree creation settings |
| `strictKnownMarketplaces` | (Managed only) Allowlist of marketplace sources |
| `strictPluginOnlyCustomization` | (Managed only) Restrict customization to plugins/managed only |
| `allowManagedPermissionRulesOnly` | (Managed only) Block user/project permission rules |
| `allowManagedHooksOnly` | (Managed only) Block user/project hooks |
| `forceRemoteSettingsRefresh` | (Managed only) Block startup until settings fetched |
| `claudeMd` | (Managed only) Org-wide CLAUDE.md instructions |
| `forceLoginMethod` | (Managed only) `"claudeai"` or `"console"` |
| `forceLoginOrgUUID` | (Managed only) Require specific org UUID |
| `policyHelper` | (Managed only, MDM/file only) Dynamic settings script |
| `wslInheritsWindowsSettings` | (Managed only) Extend Windows policy to WSL |

### Permission Modes

| Mode | What runs without asking | Best for |
|:-----|:------------------------|:---------|
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands | Iterating on code |
| `plan` | Reads only (no edits, proposes plan) | Exploring before changing |
| `auto` | Everything, with background safety checks | Long tasks, fewer interrupts |
| `dontAsk` | Only pre-approved tools | Locked-down CI/scripts |
| `bypassPermissions` | Everything (use in isolated containers only) | Containers/VMs only |

Switch modes: `Shift+Tab` in CLI to cycle; `--permission-mode <mode>` at startup; or set `permissions.defaultMode` in settings.

`auto` mode requires Claude Code v2.1.83+, Opus 4.6+ or Sonnet 4.6 (Anthropic API), or Opus 4.7+ (Bedrock/Vertex/Foundry with `CLAUDE_CODE_ENABLE_AUTO_MODE=1`). On Teams/Enterprise, an admin must enable it.

### Permission Rule Syntax

Format: `Tool` or `Tool(specifier)`. Rules evaluated in order: **deny → ask → allow**. First match wins.

| Rule | Effect |
|:-----|:-------|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run` |
| `Read(./.env)` | Matches reading `.env` in the current directory |
| `Read(//Users/alice/secrets/**)` | Absolute path (note double slash) |
| `Read(~/Documents/*.pdf)` | Home-relative path |
| `Edit(/src/**/*.ts)` | Project-root-relative path |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `Agent(Explore)` | Specific subagent |

**Path prefixes for Read/Edit rules:**
- `//path` — absolute from filesystem root
- `~/path` — relative to home directory
- `/path` — relative to project root
- `path` or `./path` — relative to current directory

A bare tool name as a deny rule (e.g., `Bash`) removes the tool from Claude's context entirely. A scoped deny rule (e.g., `Bash(rm *)`) leaves the tool available but blocks matching calls.

### Permission Settings Block

```json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Bash(git commit *)"],
    "ask": ["Bash(git push *)"],
    "deny": ["WebFetch", "Bash(curl *)", "Read(./.env)"],
    "defaultMode": "acceptEdits",
    "additionalDirectories": ["../docs/"],
    "disableBypassPermissionsMode": "disable"
  }
}
```

### Sandbox Settings

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "excludedCommands": ["docker *"],
    "filesystem": {
      "allowWrite": ["/tmp/build", "~/.kube"],
      "denyRead": ["~/.aws/credentials"]
    },
    "network": {
      "allowedDomains": ["github.com", "*.npmjs.org"],
      "deniedDomains": ["sensitive.example.com"],
      "allowUnixSockets": ["/var/run/docker.sock"],
      "allowLocalBinding": true
    }
  }
}
```

Sandbox path prefixes: `/` = absolute; `~/` = home-relative; `./` or no prefix = project-root-relative (project settings) or `~/.claude`-relative (user settings).

### Managed-Only Settings

These keys are only honored in managed settings (ignored elsewhere):

`allowAllClaudeAiMcps`, `allowedChannelPlugins`, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowManagedPermissionRulesOnly`, `blockedMarketplaces`, `channelsEnabled`, `claudeMd`, `forceRemoteSettingsRefresh`, `parentSettingsBehavior`, `pluginTrustMessage`, `pluginSuggestionMarketplaces`, `sandbox.filesystem.allowManagedReadPathsOnly`, `sandbox.network.allowManagedDomainsOnly`, `strictKnownMarketplaces`, `strictPluginOnlyCustomization`, `wslInheritsWindowsSettings`, `policyHelper` (MDM/file only)

### Auto Mode Configuration

Configure which infrastructure the auto mode classifier trusts:

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
    "soft_deny": ["$defaults", "Never run migrations outside the migrations CLI"],
    "hard_deny": ["$defaults", "Never send repo contents to third-party APIs"]
  }
}
```

Include `"$defaults"` to extend built-in rules. Omitting it **replaces** the entire built-in list for that field — use with caution.

Precedence inside classifier: `hard_deny` > `soft_deny` > explicit user intent > `allow`.

CLI subcommands: `claude auto-mode defaults`, `claude auto-mode config`, `claude auto-mode critique`.

The classifier does **not** read `autoMode` from shared project settings (`.claude/settings.json`).

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key for authentication |
| `ANTHROPIC_MODEL` | Override default model |
| `ANTHROPIC_BASE_URL` | Override API endpoint (proxy/gateway) |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude` directory |
| `CLAUDE_CODE_ENABLE_AUTO_MODE` | Enable auto mode on Bedrock/Vertex/Foundry |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level (`low`/`medium`/`high`/`xhigh`) |
| `CLAUDE_CODE_DISABLE_THINKING` | Force-disable extended thinking |
| `MAX_THINKING_TOKENS` | Override thinking token budget |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout (default: 600000) |
| `API_TIMEOUT_MS` | API request timeout (default: 600000) |
| `DISABLE_AUTOUPDATER` | Disable background auto-updates |
| `DISABLE_TELEMETRY` / `DO_NOT_TRACK` | Opt out of telemetry |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen rendering |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry data collection |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess envs |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Skip writing session transcripts |
| `CLAUDECODE` | Set to `1` in Claude-spawned subprocesses |
| `CLAUDE_SESSION_ID` | Current session ID (in subprocesses) |
| `CLAUDE_ENV_FILE` | Path to shell script run before each Bash command |
| `DEBUG` | Enable debug mode |

Set env vars in shell or under `"env"` in any `settings.json` file. Shell env vars take precedence over settings file values for the same variable.

### Server-Managed Settings

Available for Teams/Enterprise plans. Delivered from Claude.ai admin console (Admin Settings > Claude Code > Managed settings). Requires `api.anthropic.com` access; not available with Bedrock/Vertex/Foundry/custom `ANTHROPIC_BASE_URL`.

- Settings fetched at startup and polled hourly
- Hooks, custom env vars, and shell-command settings require user approval on first delivery (security dialog)
- `forceRemoteSettingsRefresh: true` blocks startup until fresh settings arrive; CLI exits if fetch fails
- To verify: run `/status` and look for `Enterprise managed settings (remote)`

### Admin Deployment Decision Map

| Decision | Key settings |
|:---------|:-------------|
| Enforce permission rules org-wide | `permissions.deny`, `allowManagedPermissionRulesOnly` |
| Block bypass permissions | `permissions.disableBypassPermissionsMode: "disable"` |
| Lock hooks to managed only | `allowManagedHooksOnly: true` |
| Sandbox with network domains | `sandbox.enabled`, `sandbox.network.allowedDomains` |
| Restrict MCP servers | `allowedMcpServers`, `deniedMcpServers`, `allowManagedMcpServersOnly` |
| Restrict plugin marketplaces | `strictKnownMarketplaces`, `blockedMarketplaces` |
| Lock customization to plugins | `strictPluginOnlyCustomization` |
| Org-wide CLAUDE.md | `claudeMd` key in managed settings |
| Force org login | `forceLoginMethod`, `forceLoginOrgUUID` |
| Version floor | `minimumVersion` |

Verify managed settings are active: `/status` shows `Setting sources` listing each loaded layer.

### Worktree Settings

| Key | Description |
|:----|:------------|
| `worktree.baseRef` | `"fresh"` (default, from remote default branch) or `"head"` (from local HEAD) |
| `worktree.symlinkDirectories` | Dirs to symlink from main repo (e.g., `["node_modules"]`) |
| `worktree.sparsePaths` | Dirs for sparse-checkout in each worktree |
| `worktree.bgIsolation` | `"worktree"` (default) or `"none"` for background session isolation |

### Attribution Settings

```json
{
  "attribution": {
    "commit": "Generated with AI\n\nCo-Authored-By: AI <ai@example.com>",
    "pr": ""
  }
}
```

Empty string hides attribution. `attribution` supersedes the deprecated `includeCoAuthoredBy`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — settings scopes, all settings.json keys, permission rules, sandbox config, plugin config, precedence
- [Configure permissions](references/claude-code-permissions.md) — permission system, rule syntax, tool-specific patterns, working directories, managed settings
- [Choose a permission mode](references/claude-code-permission-modes.md) — mode details, switching modes, auto mode requirements, bypassPermissions, protected paths
- [Configure auto mode](references/claude-code-auto-mode-config.md) — trusted infrastructure, block/allow rules, CLI subcommands, reviewing denials
- [Environment variables](references/claude-code-env-vars.md) — full reference for all environment variables
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — server delivery, caching, fail-closed enforcement, security dialogs
- [Set up Claude Code for your organization](references/claude-code-admin-setup.md) — admin decision map, API providers, managed settings delivery, enforcement options

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Set up Claude Code for your organization: https://code.claude.com/docs/en/admin-setup.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
