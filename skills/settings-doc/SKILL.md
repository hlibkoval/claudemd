---
name: settings-doc
user-invocable: false
description: >
  Complete official documentation for Claude Code settings, permissions,
  environment variables, permission modes, auto mode configuration, server-managed
  settings, and organization admin setup. Load when answering questions about
  configuring Claude Code behavior, permission rules, managed settings deployment,
  or environment variable options.
---

# Claude Code Settings & Configuration Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, environment variables, permission modes, auto mode, server-managed settings, and organization admin setup.

## Quick Reference

### Configuration scopes and file locations

| Scope | File | Shared? |
|:------|:-----|:--------|
| Managed | Server, plist/registry, or `/etc/claude-code/managed-settings.json` | Yes (IT-deployed) |
| User | `~/.claude/settings.json` | No |
| Project | `.claude/settings.json` | Yes (committed) |
| Local | `.claude/settings.local.json` | No (gitignored) |

**Precedence order** (highest to lowest): Managed > CLI args > Local > Project > User

Array settings (e.g. `permissions.allow`, `sandbox.filesystem.allowWrite`) **merge** across scopes rather than override. The one exception is `fallbackModel`, where the highest-precedence file wins the whole chain.

### Key settings.json fields

| Key | Purpose | Example |
|:----|:--------|:--------|
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `permissions` | Allow/ask/deny rules, defaultMode, sandbox | see below |
| `env` | Environment variables for every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle event commands | see hooks-doc |
| `apiKeyHelper` | Script to generate auth credentials | `"/bin/gen_key.sh"` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) | `"stable"` |
| `availableModels` | Restrict model picker | `["sonnet", "haiku"]` |
| `defaultShell` | `"bash"` (default) or `"powershell"` | `"powershell"` |
| `editorMode` | `"normal"` (default) or `"vim"` | `"vim"` |
| `effortLevel` | Persist effort level: `low/medium/high/xhigh` | `"xhigh"` |
| `language` | Claude's response language | `"japanese"` |
| `companyAnnouncements` | Messages shown at startup | `["Welcome!"]` |
| `claudeMd` | Managed-only org-wide instructions | `"Always lint before commit."` |
| `disableBundledSkills` | Remove bundled skills/workflows | `true` |
| `disableAutoMode` | Set `"disable"` to block auto mode | `"disable"` |
| `tui` | `"fullscreen"` or `"default"` renderer | `"fullscreen"` |
| `autoMemoryEnabled` | Enable/disable auto memory | `false` |
| `cleanupPeriodDays` | Days to keep session files (default 30) | `20` |
| `worktree.baseRef` | `"fresh"` (default) or `"head"` | `"head"` |
| `fallbackModel` | Fallback model chain on overload | `["claude-sonnet-4-6", "claude-haiku-4-5"]` |
| `sandbox` | OS-level sandboxing config | see sandbox section |
| `attribution` | Git commit/PR attribution text | `{"commit": "", "pr": ""}` |
| `policyHelper` | MDM-only: dynamic settings executable | `{"path": "/usr/local/bin/policy"}` |
| `requiredMinimumVersion` | Managed-only: block old versions | `"2.1.150"` |
| `requiredMaximumVersion` | Managed-only: block new versions | `"2.1.150"` |
| `strictPluginOnlyCustomization` | Managed-only: lock customization to plugins | `["skills", "hooks"]` |
| `forceLoginMethod` | Managed: `"claudeai"` or `"console"` | `"claudeai"` |
| `forceLoginOrgUUID` | Managed: require specific org UUID | `"xxxx-..."` |

### Permission settings

```json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Read(~/.zshrc)"],
    "ask":   ["Bash(git push *)"],
    "deny":  ["WebFetch", "Bash(curl *)", "Read(./.env)"],
    "defaultMode": "acceptEdits",
    "additionalDirectories": ["../docs/"],
    "disableBypassPermissionsMode": "disable",
    "skipDangerousModePermissionPrompt": false
  }
}
```

**Rule evaluation order**: deny first, then ask, then allow. First match wins regardless of specificity.

### Permission rule syntax

| Rule | Matches |
|:-----|:--------|
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Bash(git * main)` | e.g. `git checkout main`, `git log main` |
| `Read(./.env)` | Reading `.env` in current dir |
| `Read(~/.zshrc)` | Absolute home-relative path |
| `Edit(//tmp/file)` | Absolute path (double slash) |
| `Edit(/src/**)` | Project-root relative |
| `WebFetch(domain:example.com)` | Fetches to example.com |
| `mcp__github__get_*` | All `get_` tools on github MCP server |
| `Agent(Explore)` | Explore subagent |
| `Cd(~/code/**)` | `/cd` to any dir under `~/code` |
| `mcp__*` (deny only) | All MCP tools |
| `*` (deny only) | All tools |

**Read/Edit path anchors**: `//path` = absolute, `~/path` = home-relative, `/path` = project root, `path` or `./path` = current dir (gitignore-style, bare names match at any depth).

### Permission modes

| Mode | What runs without asking | Set via |
|:-----|:------------------------|:--------|
| `default` | Reads only | default |
| `acceptEdits` | Reads, file edits, `mkdir`/`touch`/`rm`/`mv`/`cp`/`sed` in working dir | Shift+Tab |
| `plan` | Reads only (no edits) | Shift+Tab |
| `auto` | Everything, with background classifier checks | Shift+Tab |
| `dontAsk` | Only pre-approved tools | `--permission-mode dontAsk` |
| `bypassPermissions` | Everything (isolated env only) | `--permission-mode bypassPermissions` |

Set default mode in settings: `"permissions": {"defaultMode": "acceptEdits"}`

**Protected paths** (never auto-approved except in bypassPermissions): `.git`, `.vscode`, `.idea`, `.claude`, `.husky`, `.cargo`, `.devcontainer`, `.yarn`, `.mvn`, shell rc files, `.gitconfig`, `.mcp.json`, etc.

### Auto mode configuration

Auto mode requires: Anthropic API + Opus 4.6+ or Sonnet 4.6 (on Bedrock/Vertex/Foundry: Opus 4.7+, requires `CLAUDE_CODE_ENABLE_AUTO_MODE=1`). On Team/Enterprise, admin must enable it.

Configure trusted infrastructure via `autoMode.environment`. Use `"$defaults"` to include built-in rules:

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp",
      "Trusted cloud buckets: s3://acme-build-artifacts",
      "Trusted internal domains: *.corp.example.com"
    ],
    "allow":     ["$defaults", "Deploying to staging is allowed"],
    "soft_deny": ["$defaults", "Never run migrations outside migrations CLI"],
    "hard_deny": ["$defaults", "Never send repo contents to third-party APIs"]
  }
}
```

**Precedence inside classifier**: `hard_deny` > `soft_deny` > `allow` > explicit user intent.

Inspect with: `claude auto-mode defaults` / `claude auto-mode config` / `claude auto-mode critique`

### Sandbox settings

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
      "allowLocalBinding": true
    }
  }
}
```

Sandbox path prefixes: `/` = absolute, `~/` = home, `./` or no prefix = project-relative (for project settings) or `~/.claude`-relative (for user settings).

### Managed settings delivery mechanisms

| Mechanism | Location | Platform |
|:----------|:---------|:---------|
| Server-managed | Claude.ai admin console (Teams/Enterprise only) | All |
| plist | `com.anthropic.claudecode` managed preferences | macOS |
| Registry (HKLM) | `HKLM\SOFTWARE\Policies\ClaudeCode` | Windows |
| File-based | macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`<br>Linux/WSL: `/etc/claude-code/managed-settings.json`<br>Windows: `C:\Program Files\ClaudeCode\managed-settings.json` | All |

Drop-in directory: `managed-settings.d/*.json` alongside the base file; files sorted alphabetically and deep-merged.

**Server-managed** fetches at startup and polls hourly. Use `forceRemoteSettingsRefresh: true` for fail-closed startup. Not available on Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`.

### Managed-only settings

These keys only take effect in managed settings (no effect in user/project settings):

`allowAllClaudeAiMcps`, `allowedChannelPlugins`, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowManagedPermissionRulesOnly`, `blockedMarketplaces`, `channelsEnabled`, `claudeMd`, `forceRemoteSettingsRefresh`, `parentSettingsBehavior`, `pluginTrustMessage`, `sandbox.filesystem.allowManagedReadPathsOnly`, `sandbox.network.allowManagedDomainsOnly`, `strictKnownMarketplaces`, `strictPluginOnlyCustomization`, `wslInheritsWindowsSettings`, `requiredMinimumVersion`, `requiredMaximumVersion`

### Key environment variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key (overrides subscription login) |
| `ANTHROPIC_MODEL` | Model override |
| `ANTHROPIC_BASE_URL` | Custom API endpoint / proxy |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CONFIG_DIR` | Override config directory (default `~/.claude`) |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set `1` to enable OpenTelemetry export |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Set `1` to disable auto memory |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disables autoupdater, feedback, error reporting, telemetry |
| `CLAUDE_CODE_MAX_TURNS` | Cap agentic turns |
| `CLAUDE_CODE_EFFORT_LEVEL` | `low/medium/high/xhigh/max/auto` |
| `CLAUDE_CODE_ENABLE_AUTO_MODE` | Set `1` for auto mode on Bedrock/Vertex/Foundry |
| `MAX_THINKING_TOKENS` | Override extended thinking budget |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash timeout (default 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout (default 600000) |
| `API_TIMEOUT_MS` | API request timeout (default 600000) |
| `DISABLE_AUTOUPDATER` | Set `1` to disable background updates |
| `DISABLE_TELEMETRY` / `DO_NOT_TRACK` | Opt out of telemetry |
| `DISABLE_COMPACT` | Set `1` to disable all context compaction |
| `CLAUDE_CODE_SAFE_MODE` | Start with no CLAUDE.md/skills/plugins/hooks loaded |
| `CLAUDECODE` | Set to `1` in subprocesses spawned by Claude Code |
| `CLAUDE_CODE_SESSION_ID` | Current session ID (set in subprocesses) |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server |
| `OTEL_METRICS_EXPORTER` | OTel metrics exporter config |

Set env vars persistently in `settings.json` under the `env` key.

### Verify active settings

Run `/status` inside Claude Code to see which settings sources are active. Look for the `Setting sources` line; managed settings show the delivery channel, e.g. `Enterprise managed settings (remote)`, `(plist)`, `(HKLM)`, `(file)`. Run `/doctor` or `claude doctor` for validation errors.

### Global config settings (stored in `~/.claude.json`, not `settings.json`)

`autoConnectIde`, `autoInstallIdeExtension`, `externalEditorContext`, `teammateDefaultModel`

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) — Complete settings reference: scopes, all settings keys, permission rules, sandbox, worktree, attribution, hooks configuration, precedence
- [Admin Setup Guide](references/claude-code-admin-setup.md) — Decision map for org administrators: API provider choice, managed settings delivery, enforcement controls, usage visibility, data handling
- [Configure Permissions](references/claude-code-permissions.md) — Permission system tiers, rule syntax, tool-specific rules (Bash, Read/Edit, WebFetch, MCP, Agent, Cd), managed policies, working directories, sandboxing interaction
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) — Claude.ai admin console delivery, fetch/caching behavior, security approval dialogs, fail-closed startup, audit logging
- [Environment Variables](references/claude-code-env-vars.md) — Full reference for all environment variables controlling Claude Code behavior
- [Permission Modes](references/claude-code-permission-modes.md) — All modes (default, acceptEdits, plan, auto, dontAsk, bypassPermissions), how to switch, protected paths, auto mode requirements and classifier behavior
- [Configure Auto Mode](references/claude-code-auto-mode-config.md) — autoMode settings block, trusted infrastructure prose rules, override hard/soft deny and allow lists, CLI inspection subcommands

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Admin Setup Guide: https://code.claude.com/docs/en/admin-setup.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment Variables: https://code.claude.com/docs/en/env-vars.md
- Permission Modes: https://code.claude.com/docs/en/permission-modes.md
- Configure Auto Mode: https://code.claude.com/docs/en/auto-mode-config.md
