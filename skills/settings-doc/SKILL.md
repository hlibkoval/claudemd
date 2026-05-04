---
name: settings-doc
description: Complete official documentation for configuring Claude Code — settings files, scopes and precedence, all settings keys, permissions and permission modes, environment variables, server-managed settings, auto mode configuration, and enterprise admin setup.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for configuring Claude Code behavior through settings files, environment variables, permissions, and managed enterprise policies.

## Quick Reference

### Settings File Locations

| Scope | File | Shared? |
| :--- | :--- | :--- |
| **User** | `~/.claude/settings.json` | No |
| **Project** | `.claude/settings.json` | Yes (committed) |
| **Local** | `.claude/settings.local.json` | No (gitignored) |
| **Managed (file)** | macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`<br>Linux/WSL: `/etc/claude-code/managed-settings.json`<br>Windows: `C:\Program Files\ClaudeCode\managed-settings.json` | Deployed by IT |
| **Managed (OS policy)** | macOS: `com.anthropic.claudecode` plist<br>Windows: `HKLM\SOFTWARE\Policies\ClaudeCode` | Deployed by IT |
| **Server-managed** | Claude.ai admin console | All org users |

### Settings Precedence (highest to lowest)

1. **Managed** (server-managed > plist/registry > file-based > HKCU Windows) — cannot be overridden
2. **Command line arguments** — session overrides
3. **Local** (`.claude/settings.local.json`)
4. **Project** (`.claude/settings.json`)
5. **User** (`~/.claude/settings.json`)

Array settings (e.g., `permissions.allow`, `sandbox.filesystem.allowWrite`) **merge** across scopes rather than replace.

### Key settings.json Fields

| Key | Description | Example |
| :--- | :--- | :--- |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `permissions` | Allow/ask/deny rules and modes (see below) | — |
| `env` | Environment variables applied every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle event hooks | See hooks-doc |
| `defaultShell` | Shell for `!` commands: `"bash"` or `"powershell"` | `"bash"` |
| `editorMode` | Input key bindings: `"normal"` or `"vim"` | `"vim"` |
| `language` | Claude's preferred response language | `"japanese"` |
| `autoUpdatesChannel` | `"latest"` (default) or `"stable"` | `"stable"` |
| `minimumVersion` | Minimum allowed CLI version | `"2.1.100"` |
| `tui` | UI renderer: `"default"` or `"fullscreen"` | `"fullscreen"` |
| `apiKeyHelper` | Script to generate auth token | `"/bin/gen-key.sh"` |
| `cleanupPeriodDays` | Session file retention in days (default 30) | `20` |
| `companyAnnouncements` | Startup messages for users | `["Welcome!"]` |
| `statusLine` | Custom status line command | `{"type":"command","command":"~/.claude/statusline.sh"}` |
| `attribution` | Git commit and PR attribution text | `{"commit":"...","pr":""}` |
| `sandbox` | OS-level Bash sandboxing config (see below) | — |
| `enabledPlugins` | Plugin enable/disable by `name@marketplace` | `{"fmt@tools": true}` |
| `extraKnownMarketplaces` | Additional plugin marketplace sources | — |
| `autoMode` | Auto mode classifier config (see below) | — |
| `effortLevel` | Thinking effort: `"low"`, `"medium"`, `"high"`, `"xhigh"` | `"xhigh"` |
| `availableModels` | Restrict `/model` picker choices | `["sonnet","haiku"]` |
| `disableAutoMode` | Set `"disable"` to prevent auto mode | `"disable"` |
| `forceLoginMethod` | `"claudeai"` or `"console"` | `"claudeai"` |
| `forceLoginOrgUUID` | Require login to specific org UUID(s) | `"xxxx-xxxx-..."` |

### Permission Settings

```json
{
  "permissions": {
    "allow":  ["Bash(npm run *)", "Read(~/.zshrc)"],
    "ask":    ["Bash(git push *)"],
    "deny":   ["Bash(curl *)", "Read(./.env)", "Read(./secrets/**)"],
    "defaultMode": "acceptEdits",
    "additionalDirectories": ["../docs/"],
    "disableBypassPermissionsMode": "disable",
    "skipDangerousModePermissionPrompt": false
  }
}
```

**Rule evaluation order: deny → ask → allow. First match wins.**

### Permission Rule Syntax

| Rule | Effect |
| :--- | :--- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Bash(git * main)` | Commands like `git checkout main` |
| `Read(./.env)` | Reading `.env` in current directory |
| `Read(//abs/path)` | Absolute path (`//` prefix) |
| `Edit(/src/**)` | Files under `<project>/src/` |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__github__*` | Any tool from the `github` MCP server |
| `Agent(Explore)` | The Explore subagent |

### Permission Modes

Set with `defaultMode` in settings or `--permission-mode` flag. Cycle with `Shift+Tab` in CLI.

| Mode | What runs without asking | Best for |
| :--- | :--- | :--- |
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands | Iterating on code |
| `plan` | Reads only (Claude writes a plan, no edits) | Exploring before changing |
| `auto` | Everything, with background safety classifier | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down CI/scripts |
| `bypassPermissions` | Everything (no checks) | Isolated containers/VMs only |

**Auto mode requirements:** Claude Code v2.1.83+; Max/Team/Enterprise/API plan; supported model (Sonnet 4.6, Opus 4.6, or Opus 4.7); Anthropic API only (not Bedrock/Vertex/Foundry).

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
      "deniedDomains": ["uploads.github.com"],
      "allowLocalBinding": true
    }
  }
}
```

**Sandbox path prefixes:** `/path` = absolute; `~/path` = home-relative; `./path` or bare = project-relative.

### Auto Mode Configuration

Configure the auto mode classifier's trusted infrastructure (in user settings, local settings, or managed settings — not shared project settings):

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp",
      "Trusted buckets: s3://acme-builds",
      "Trusted internal domains: *.corp.example.com"
    ],
    "allow": ["$defaults", "Deploying to staging is allowed"],
    "soft_deny": ["$defaults", "Never run db migrations outside the migrations CLI"]
  }
}
```

Include `"$defaults"` to inherit built-in rules. Omitting it replaces the entire default list.

CLI commands: `claude auto-mode defaults` / `claude auto-mode config` / `claude auto-mode critique`

### Managed-Only Settings (only effective in managed settings)

| Setting | Description |
| :--- | :--- |
| `allowManagedPermissionRulesOnly` | Only managed `allow`/`ask`/`deny` rules apply |
| `allowManagedHooksOnly` | Only managed/SDK hooks load |
| `allowManagedMcpServersOnly` | Only managed MCP servers respected |
| `allowedMcpServers` | Allowlist of MCP servers users may configure |
| `deniedMcpServers` | Denylist of blocked MCP servers |
| `strictKnownMarketplaces` | Restrict plugin marketplace sources |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `channelsEnabled` | Allow channel message delivery |
| `allowedChannelPlugins` | Allowlist of channel plugins |
| `forceRemoteSettingsRefresh` | Block startup until remote settings fetched |
| `pluginTrustMessage` | Custom plugin trust warning text |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed `allowRead` paths respected |
| `sandbox.network.allowManagedDomainsOnly` | Only managed `allowedDomains` respected |
| `wslInheritsWindowsSettings` | WSL reads from Windows policy chain |

### Key Environment Variables

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key (overrides subscription when set) |
| `ANTHROPIC_MODEL` | Override default model |
| `ANTHROPIC_BASE_URL` | Route requests through a proxy/gateway |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CONFIG_DIR` | Override config directory (default `~/.claude`) |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set to `1` to enable OpenTelemetry export |
| `BASH_DEFAULT_TIMEOUT_MS` | Default Bash timeout (default 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max Bash timeout (default 600000) |
| `DISABLE_AUTOUPDATER` | Set to `1` to disable auto-updates |
| `DISABLE_TELEMETRY` | Set to `1` to opt out of telemetry |
| `DISABLE_AUTO_COMPACT` | Set to `1` to disable auto-compaction |
| `MAX_THINKING_TOKENS` | Override extended thinking budget |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level: `low`/`medium`/`high`/`xhigh` |
| `CLAUDE_CODE_NO_FLICKER` | Set to `1` to enable fullscreen rendering |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocesses |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable autoupdater, error reporting, telemetry |
| `MCP_TIMEOUT` | MCP server startup timeout in ms (default 30000) |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server for network connections |

All env vars can also be set under the `env` key in `settings.json`.

### Server-Managed Settings (Enterprise/Teams)

Delivered from Claude.ai admin console: **Admin Settings > Claude Code > Managed settings**.

- Available on Claude for Teams and Enterprise plans only
- Requires Claude Code v2.1.38+ (Teams) or v2.1.30+ (Enterprise)
- Settings delivered at auth time, polled hourly during sessions
- Not available on Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`
- Security dialogs shown to users before applying hooks or custom env vars

### Admin Setup Decision Map

| Decision | Key settings |
| :--- | :--- |
| API provider (Claude/Bedrock/Vertex/Foundry) | Auth and billing choice |
| Settings delivery mechanism | Server-managed vs. plist/registry vs. file-based |
| What to enforce | `permissions.deny`, `sandbox.enabled`, `allowManagedPermissionRulesOnly` |
| Usage visibility | `CLAUDE_CODE_ENABLE_TELEMETRY`, analytics dashboard |
| Data handling | Zero Data Retention, security posture |

Verify managed settings are active: run `/status` inside Claude Code — look for `Enterprise managed settings (remote|plist|HKLM|HKCU|file)`.

### Worktree Settings

| Key | Description |
| :--- | :--- |
| `worktree.symlinkDirectories` | Dirs to symlink into each worktree (e.g., `["node_modules"]`) |
| `worktree.sparsePaths` | Dirs for sparse-checkout in each worktree |

### Global Config Settings (stored in `~/.claude.json`, not `settings.json`)

| Key | Description |
| :--- | :--- |
| `autoConnectIde` | Auto-connect to running IDE on start |
| `autoInstallIdeExtension` | Auto-install IDE extension (default `true`) |
| `externalEditorContext` | Prepend last response when opening external editor |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — all settings keys, scopes, file locations, precedence, sandbox, permissions, attribution, plugin, and hook configuration
- [Configure permissions](references/claude-code-permissions.md) — permission system, rule syntax, tool-specific patterns (Bash, Read/Edit, WebFetch, MCP, Agent), working directories, managed settings, and sandboxing interaction
- [Choose a permission mode](references/claude-code-permission-modes.md) — available modes, how to switch, acceptEdits, plan, auto, dontAsk, and bypassPermissions modes in detail, protected paths
- [Configure auto mode](references/claude-code-auto-mode-config.md) — defining trusted infrastructure, overriding block/allow rules, inspecting effective config, reviewing denials
- [Environment variables](references/claude-code-env-vars.md) — complete reference for all environment variables controlling Claude Code behavior
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — admin console setup, delivery and caching, fail-closed enforcement, security dialogs, platform availability
- [Set up Claude Code for your organization](references/claude-code-admin-setup.md) — API provider selection, settings delivery mechanisms, enforcement decisions, usage visibility, data handling

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Set up Claude Code for your organization: https://code.claude.com/docs/en/admin-setup.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
