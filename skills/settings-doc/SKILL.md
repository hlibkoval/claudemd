---
name: settings-doc
description: Complete official documentation for Claude Code settings — configuration scopes, settings.json keys, permission rules and modes, environment variables, admin setup, server-managed settings, and auto mode configuration.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings and configuration.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared? |
| :--- | :--- | :--- | :--- |
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | All users on the machine | Yes (deployed by IT) |
| **User** | `~/.claude/settings.json` | You, across all projects | No |
| **Project** | `.claude/settings.json` | All collaborators on this repo | Yes (git) |
| **Local** | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |

Precedence (highest to lowest): Managed > Command line args > Local > Project > User

Array settings (like `permissions.allow`) **merge** across scopes rather than being replaced.

### Settings File Locations

| Feature | User | Project | Local |
| :--- | :--- | :--- | :--- |
| Settings | `~/.claude/settings.json` | `.claude/settings.json` | `.claude/settings.local.json` |
| Subagents | `~/.claude/agents/` | `.claude/agents/` | — |
| MCP servers | `~/.claude.json` | `.mcp.json` | `~/.claude.json` (per-project) |
| CLAUDE.md | `~/.claude/CLAUDE.md` | `CLAUDE.md` or `.claude/CLAUDE.md` | `CLAUDE.local.md` |

### Managed Settings File Paths

| Platform | Path |
| :--- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux / WSL | `/etc/claude-code/managed-settings.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-settings.json` |

Also supported: macOS plist (`com.anthropic.claudecode`), Windows registry (`HKLM\SOFTWARE\Policies\ClaudeCode`), and drop-in directory `managed-settings.d/*.json`.

### Key settings.json Options

| Key | Description | Example |
| :--- | :--- | :--- |
| `permissions` | Allow/ask/deny rules, defaultMode, additionalDirectories | See permission tables |
| `env` | Environment variables applied every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle event hooks | See hooks-doc |
| `model` | Override the default model | `"claude-sonnet-4-6"` |
| `effortLevel` | Persist effort level: `low`, `medium`, `high`, `xhigh` | `"xhigh"` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) | `"stable"` |
| `minimumVersion` | Floor for auto-updates | `"2.1.100"` |
| `availableModels` | Restrict `/model` picker | `["sonnet", "haiku"]` |
| `language` | Claude's preferred response language | `"japanese"` |
| `tui` | Terminal UI: `"fullscreen"` or `"default"` | `"fullscreen"` |
| `editorMode` | Key bindings: `"normal"` or `"vim"` | `"vim"` |
| `cleanupPeriodDays` | Session file retention (default 30, min 1) | `20` |
| `companyAnnouncements` | Messages shown at startup | `["Welcome!"]` |
| `attribution` | Git commit/PR attribution strings | `{"commit": "...", "pr": ""}` |
| `statusLine` | Custom status line script | `{"type": "command", "command": "..."}` |
| `sandbox` | OS-level bash isolation settings | See sandbox table |
| `autoMode` | Auto mode classifier configuration | See auto mode section |
| `apiKeyHelper` | Script to generate auth token | `"/bin/gen_key.sh"` |
| `forceLoginMethod` | `"claudeai"` or `"console"` | `"claudeai"` |
| `forceLoginOrgUUID` | Require specific org UUID(s) | `"xxxxxxxx-..."` |
| `defaultShell` | Shell for `!` commands: `"bash"` or `"powershell"` | `"powershell"` |
| `disableAllHooks` | Disable all hooks | `true` |
| `sshConfigs` | SSH connections for Desktop dropdown | `[{"id":"dev-vm",...}]` |
| `skillOverrides` | Override skill visibility: `"on"`, `"name-only"`, `"user-invocable-only"`, `"off"` | `{"legacy": "off"}` |

### Permission Settings

| Key | Description |
| :--- | :--- |
| `permissions.allow` | Rules to allow tool use without prompting |
| `permissions.ask` | Rules to always prompt before tool use |
| `permissions.deny` | Rules to block tool use |
| `permissions.defaultMode` | Starting mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `permissions.additionalDirectories` | Extra working directories for file access |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to block bypass mode |
| `permissions.skipDangerousModePermissionPrompt` | Skip confirmation for bypass mode |

### Permission Rule Syntax

Format: `Tool` or `Tool(specifier)`

| Rule | Effect |
| :--- | :--- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Bash(git * main)` | Commands matching pattern (e.g. `git push origin main`) |
| `Read(./.env)` | Reading `.env` in current directory |
| `Read(//Users/alice/*)` | Absolute path (double slash = filesystem root) |
| `Read(/src/**)` | Path relative to project root |
| `Edit(*.ts)` | Editing any `.ts` file in cwd |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer` | Any tool from the puppeteer MCP server |
| `Agent(Explore)` | The Explore subagent |

Evaluation order: **deny first, then ask, then allow**. First match wins.

Deny rules take precedence at all scopes — a managed deny cannot be overridden by user allow.

### Permission Modes

| Mode | What runs without prompting | Best for |
| :--- | :--- | :--- |
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, filesystem commands (`mkdir`, `touch`, `mv`, `cp`, `rm`, etc.) | Iterating on code |
| `plan` | Reads only (Claude proposes changes, doesn't make them) | Exploring before editing |
| `auto` | Everything, with background classifier checks | Long tasks, fewer interruptions |
| `dontAsk` | Only pre-approved tools | Locked-down CI |
| `bypassPermissions` | Everything (skip all checks) | Isolated containers/VMs only |

Switch mid-session with `Shift+Tab`, or set at startup: `claude --permission-mode plan`

**Auto mode requirements**: Max/Team/Enterprise/API plan, Anthropic API only, supported models (Sonnet 4.6, Opus 4.6, Opus 4.7), admin-enabled on Team/Enterprise.

### Sandbox Settings

| Key | Description |
| :--- | :--- |
| `sandbox.enabled` | Enable OS-level bash isolation |
| `sandbox.failIfUnavailable` | Exit if sandbox can't start |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default true) |
| `sandbox.excludedCommands` | Commands that run outside the sandbox |
| `sandbox.filesystem.allowWrite` | Paths sandboxed commands can write |
| `sandbox.filesystem.denyWrite` | Paths sandboxed commands cannot write |
| `sandbox.filesystem.denyRead` | Paths sandboxed commands cannot read |
| `sandbox.network.allowedDomains` | Domains allowed for outbound traffic |
| `sandbox.network.deniedDomains` | Domains blocked (overrides allowedDomains) |
| `sandbox.network.allowUnixSockets` | Unix socket paths (macOS only) |

Path prefixes: `/` = absolute, `~/` = home-relative, `./` or bare = project/user-relative.

### Managed-Only Settings

These keys are only read from managed settings; they have no effect in user/project settings:

| Key | Description |
| :--- | :--- |
| `allowManagedPermissionRulesOnly` | Only managed allow/ask/deny rules apply |
| `allowManagedHooksOnly` | Only managed/SDK hooks load |
| `allowManagedMcpServersOnly` | Only managed MCP servers respected |
| `allowedMcpServers` | Allowlist of configurable MCP servers |
| `deniedMcpServers` | Denylist of MCP servers (always blocked) |
| `strictKnownMarketplaces` | Allowlist of plugin marketplace sources |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `channelsEnabled` | Allow channels for the org |
| `allowedChannelPlugins` | Allowlist of channel plugins |
| `forceRemoteSettingsRefresh` | Block startup until settings freshly fetched |
| `pluginTrustMessage` | Custom message in plugin trust dialog |
| `wslInheritsWindowsSettings` | WSL reads Windows policy chain |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed `allowRead` paths respected |
| `sandbox.network.allowManagedDomainsOnly` | Only managed `allowedDomains` respected |

### Managed Settings Delivery Mechanisms

| Mechanism | Priority | Platforms |
| :--- | :--- | :--- |
| Server-managed (Claude.ai admin console) | Highest | All (Teams/Enterprise only) |
| plist / registry policy | High | macOS, Windows |
| File-based `managed-settings.json` | Medium | All |
| Windows user registry (HKCU) | Lowest | Windows only |

Server-managed settings: requires Teams/Enterprise, refreshed hourly. Set via **Admin Settings > Claude Code > Managed settings** on Claude.ai.

`forceRemoteSettingsRefresh: true` blocks startup until fresh settings are fetched (fail-closed).

### Auto Mode Configuration (autoMode)

Configure the auto mode classifier with `autoMode` in settings (not read from shared project settings):

| Field | Description |
| :--- | :--- |
| `autoMode.environment` | Prose descriptions of trusted infrastructure (repos, buckets, domains) |
| `autoMode.allow` | Override default allow exceptions in the classifier |
| `autoMode.soft_deny` | Override default block rules in the classifier |

Include `"$defaults"` in any array to inherit built-in rules at that position.

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp and all repos under it",
      "Trusted buckets: s3://acme-build-artifacts"
    ],
    "soft_deny": [
      "$defaults",
      "Never run database migrations outside the migrations CLI"
    ]
  }
}
```

CLI inspection: `claude auto-mode defaults`, `claude auto-mode config`, `claude auto-mode critique`

**Warning**: Omitting `"$defaults"` replaces the entire built-in list for that section.

### Key Environment Variables

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key (overrides subscription) |
| `ANTHROPIC_BASE_URL` | Override API endpoint (proxy/gateway) |
| `ANTHROPIC_MODEL` | Override model selection |
| `CLAUDE_CONFIG_DIR` | Override config directory (default `~/.claude`) |
| `CLAUDECODE` | Set to `1` in shells Claude Code spawns |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `DISABLE_AUTOUPDATER` | Disable auto-updates (manual update still works) |
| `DISABLE_TELEMETRY` | Opt out of telemetry |
| `DISABLE_AUTO_COMPACT` | Disable automatic compaction |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout (default: 600000) |
| `MAX_THINKING_TOKENS` | Extended thinking token budget |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry export |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Skip writing session history to disk |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess envs |
| `MCP_TIMEOUT` | MCP server startup timeout (default: 30000ms) |
| `API_TIMEOUT_MS` | API request timeout (default: 600000ms) |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server for network connections |

Set env vars in `settings.json` under the `env` key to apply them to every session.

### Admin Setup Decision Map

| Decision | Key settings |
| :--- | :--- |
| Choose API provider | Auth method and billing: Claude.ai, Console, Bedrock, Vertex, Foundry |
| Deliver managed settings | Server-managed, plist/registry, file-based, or Windows HKCU |
| Enforce permissions | `permissions.allow/deny`, `allowManagedPermissionRulesOnly`, `disableBypassPermissionsMode` |
| Sandbox execution | `sandbox.enabled`, `sandbox.network.allowedDomains` |
| Restrict MCP servers | `allowedMcpServers`, `deniedMcpServers`, `allowManagedMcpServersOnly` |
| Restrict plugins | `strictKnownMarketplaces`, `blockedMarketplaces` |
| Lock down hooks | `allowManagedHooksOnly`, `allowedHttpHookUrls` |
| Set version floor | `minimumVersion` |
| Monitor usage | OpenTelemetry via `CLAUDE_CODE_ENABLE_TELEMETRY` |

Verify: have a developer run `/status` to see which managed settings source is active.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — full settings reference, all keys, scopes, precedence, sandbox config, plugin settings, attribution, worktree settings
- [Configure permissions](references/claude-code-permissions.md) — permission rules, modes, tool-specific patterns, working directories, managed-only settings
- [Permission modes](references/claude-code-permission-modes.md) — detailed guide for each mode, switching, auto mode details, protected paths
- [Environment variables](references/claude-code-env-vars.md) — complete env var reference for all Claude Code behavior
- [Set up Claude Code for your organization](references/claude-code-admin-setup.md) — admin decision map, API providers, managed settings delivery, enforcement controls
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — Claude.ai admin console setup, delivery, caching, security considerations
- [Configure auto mode](references/claude-code-auto-mode-config.md) — trusted infrastructure, classifier rule overrides, CLI inspection subcommands

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Permission modes: https://code.claude.com/docs/en/permission-modes.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Set up Claude Code for your organization: https://code.claude.com/docs/en/admin-setup.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
