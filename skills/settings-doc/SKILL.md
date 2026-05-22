---
name: settings-doc
description: Complete official documentation for Claude Code settings, permissions, environment variables, and admin configuration — settings scopes and precedence, all settings.json keys, permission modes (default/acceptEdits/plan/auto/dontAsk/bypassPermissions), permission rule syntax, managed settings delivery mechanisms, server-managed settings, environment variable reference, and auto mode configuration.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, environment variables, and organization administration.

## Quick Reference

### Configuration Scopes and Precedence

| Priority | Scope | Location | Who it affects |
| :--- | :--- | :--- | :--- |
| 1 (highest) | **Managed** | Server, MDM/plist/registry, or system `managed-settings.json` | All users (IT-deployed) |
| 2 | **Command line args** | `--settings` flag, CLI flags | Session only |
| 3 | **Local** | `.claude/settings.local.json` | You, this project only |
| 4 | **Project** | `.claude/settings.json` | All collaborators (committed) |
| 5 (lowest) | **User** | `~/.claude/settings.json` | You, all projects |

Array settings (e.g. `permissions.allow`, `sandbox.filesystem.allowWrite`) **merge across scopes** — they concatenate and deduplicate rather than replace.

### Settings File Locations

| Feature | User | Project | Local |
| :--- | :--- | :--- | :--- |
| Settings | `~/.claude/settings.json` | `.claude/settings.json` | `.claude/settings.local.json` |
| Subagents | `~/.claude/agents/` | `.claude/agents/` | — |
| MCP servers | `~/.claude.json` | `.mcp.json` | `~/.claude.json` (per-project) |
| Plugins | `~/.claude/settings.json` | `.claude/settings.json` | `.claude/settings.local.json` |
| CLAUDE.md | `~/.claude/CLAUDE.md` | `CLAUDE.md` or `.claude/CLAUDE.md` | `CLAUDE.local.md` |

### Managed Settings Delivery Mechanisms

| Mechanism | Priority | Platforms | Location |
| :--- | :--- | :--- | :--- |
| Server-managed (Claude admin console) | Highest | All | Via `api.anthropic.com` |
| plist / registry policy | High | macOS, Windows | macOS: `com.anthropic.claudecode` plist; Windows: `HKLM\SOFTWARE\Policies\ClaudeCode` |
| File-based managed | Medium | All | macOS: `/Library/Application Support/ClaudeCode/`; Linux/WSL: `/etc/claude-code/`; Windows: `C:\Program Files\ClaudeCode\` |
| Windows user registry | Lowest | Windows only | `HKCU\SOFTWARE\Policies\ClaudeCode` |

Drop-in fragments go in `managed-settings.d/` alongside `managed-settings.json`; files are merged alphabetically, with later files taking precedence for scalars.

### Key settings.json Fields (Selected)

| Key | Description | Example |
| :--- | :--- | :--- |
| `model` | Default model (read once at startup; use `/model` to switch mid-session) | `"claude-sonnet-4-6"` |
| `permissions` | Object with `allow`, `ask`, `deny`, `defaultMode`, `additionalDirectories` | See below |
| `hooks` | Lifecycle hook definitions | See hooks-doc skill |
| `env` | Environment variables applied to every session | `{"FOO": "bar"}` |
| `apiKeyHelper` | Script to generate auth token (`X-Api-Key`) | `"/bin/generate_key.sh"` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) | `"stable"` |
| `availableModels` | Restrict `/model` picker | `["sonnet", "haiku"]` |
| `cleanupPeriodDays` | Session file retention (default: 30, min: 1) | `20` |
| `companyAnnouncements` | Startup announcements (cycled randomly) | `["Welcome!"]` |
| `disableAllHooks` | Disable all hooks and custom status lines | `true` |
| `disableAutoMode` | Set to `"disable"` to prevent auto mode | `"disable"` |
| `editorMode` | `"normal"` or `"vim"` | `"vim"` |
| `effortLevel` | Persist effort: `"low"`, `"medium"`, `"high"`, `"xhigh"` | `"xhigh"` |
| `language` | Claude's preferred response language | `"japanese"` |
| `minimumVersion` | Floor version for auto-updates | `"2.1.100"` |
| `outputStyle` | System prompt output style (applied on restart/clear) | `"Explanatory"` |
| `sandbox` | Sandboxing config object | See sandbox section |
| `spinnerTipsEnabled` | Show tips while Claude works (default: `true`) | `false` |
| `tui` | `"fullscreen"` or `"default"` renderer | `"fullscreen"` |
| `worktree.*` | Worktree creation and isolation settings | See worktree section |

### Permission Settings

| Key | Description | Example |
| :--- | :--- | :--- |
| `permissions.allow` | Rules to auto-approve tool use | `["Bash(npm run *)"]` |
| `permissions.ask` | Rules to prompt for confirmation | `["Bash(git push *)"]` |
| `permissions.deny` | Rules to block tool use | `["WebFetch", "Read(./.env)"]` |
| `permissions.defaultMode` | Starting permission mode | `"acceptEdits"` |
| `permissions.additionalDirectories` | Extra working directories for file access | `["../docs/"]` |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to block bypass mode | `"disable"` |
| `permissions.skipDangerousModePermissionPrompt` | Skip bypass mode confirmation prompt | `true` |

Rules evaluate in order: **deny → ask → allow**. The first matching rule wins. A bare tool name as a deny rule (e.g. `Bash`) removes it from Claude's context entirely.

### Permission Rule Syntax

| Pattern | Effect |
| :--- | :--- |
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run ` |
| `Bash(git * main)` | Matches commands like `git checkout main` |
| `Read(./.env)` | Matches reading the `.env` file |
| `Read(~/.zshrc)` | Matches reading a home-directory file |
| `Read(//Users/alice/*)` | Absolute path (double slash = filesystem root) |
| `Edit(/src/**)` | Project-root relative (`/path` = project-relative) |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer__*` | All tools from the `puppeteer` MCP server |
| `Agent(Explore)` | The Explore subagent |

A single `*` matches any sequence including spaces. Space before `*` enforces a word boundary: `Bash(ls *)` matches `ls -la` but not `lsof`. The `:*` suffix is equivalent to a trailing ` *`.

### Permission Modes

| Mode | What auto-approves | Best for |
| :--- | :--- | :--- |
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands | Iterating on code you're reviewing |
| `plan` | Reads only (Claude proposes, doesn't edit) | Exploring before changing |
| `auto` | Everything via background classifier checks | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down CI and scripts |
| `bypassPermissions` | Everything (circuit breaker for `rm -rf /` only) | Isolated containers/VMs only |

Switch modes mid-session with `Shift+Tab` (CLI) or the mode selector in VS Code/Desktop. Set a default with `permissions.defaultMode`. Auto mode requires Anthropic API + supported models (Sonnet 4.6, Opus 4.6, Opus 4.7); not available on Bedrock/Vertex/Foundry.

Auto mode classifier default blocks include: `curl | bash`, production deploys, mass cloud deletion, IAM grants, force push to main. It trusts your working directory and repo remotes by default.

### Sandbox Settings (selected)

| Key | Description |
| :--- | :--- |
| `sandbox.enabled` | Enable OS-level bash sandboxing (default: false) |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `sandbox.excludedCommands` | Commands to run outside sandbox |
| `sandbox.filesystem.allowWrite` | Additional paths where sandboxed commands can write |
| `sandbox.filesystem.denyRead` | Paths sandboxed commands cannot read |
| `sandbox.network.allowedDomains` | Domains for outbound traffic (supports `*.example.com`) |
| `sandbox.network.deniedDomains` | Blocked domains (merged from all scopes, takes precedence) |

Sandbox path prefixes: `/` = absolute, `~/` = home-relative, `./` or no prefix = project-root relative (in project settings) or `~/.claude` relative (in user settings).

### Worktree Settings

| Key | Description |
| :--- | :--- |
| `worktree.baseRef` | `"fresh"` (from `origin/<default>`) or `"head"` (from local HEAD) |
| `worktree.symlinkDirectories` | Directories to symlink from main repo into worktrees |
| `worktree.sparsePaths` | Sparse-checkout directories per worktree |
| `worktree.bgIsolation` | `"worktree"` (default) or `"none"` for background session isolation |

### Managed-Only Settings

These keys are ignored in user or project settings — they only apply from managed settings:

`allowedChannelPlugins`, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowManagedPermissionRulesOnly`, `blockedMarketplaces`, `channelsEnabled`, `claudeMd`, `forceRemoteSettingsRefresh`, `parentSettingsBehavior`, `pluginTrustMessage`, `policyHelper`, `sandbox.filesystem.allowManagedReadPathsOnly`, `sandbox.network.allowManagedDomainsOnly`, `strictKnownMarketplaces`, `strictPluginOnlyCustomization`, `wslInheritsWindowsSettings`

### Key Environment Variables (Selected)

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key; overrides subscription login when set |
| `ANTHROPIC_MODEL` | Override model for the session |
| `ANTHROPIC_BASE_URL` | Proxy/gateway endpoint |
| `API_TIMEOUT_MS` | API request timeout (default: 600000ms) |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout (default: 120000ms) |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout model can set (default: 600000ms) |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen rendering (equivalent to `tui: "fullscreen"`) |
| `CLAUDE_CODE_DISABLE_THINKING` | Force-disable extended thinking |
| `CLAUDE_CODE_EFFORT_LEVEL` | Effort level: `low`, `medium`, `high`, `xhigh`, `max`, `auto` |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set to `1` to enable OpenTelemetry export |
| `DISABLE_AUTOUPDATER` | Set to `1` to disable background auto-updates |
| `DISABLE_TELEMETRY` | Set to `1` to opt out of telemetry |
| `DISABLE_PROMPT_CACHING` | Set to `1` to disable prompt caching |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Set to `1` to disable auto memory |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess environments |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server for network connections |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget |
| `MCP_TIMEOUT` | MCP server startup timeout (default: 30000ms) |
| `DEBUG` | Set to `1` to enable debug mode |

Set env vars in `settings.json` under the `env` key to apply them to every session without editing shell profiles.

### Auto Mode Configuration (`autoMode` setting)

Configure trusted infrastructure so the classifier stops blocking routine internal operations:

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp and all repos under it",
      "Trusted cloud buckets: s3://acme-build-artifacts",
      "Trusted internal domains: *.corp.example.com"
    ],
    "soft_deny": ["$defaults", "Never run terraform apply outside the infra directory"],
    "hard_deny": ["$defaults", "Never send repo contents to third-party APIs"],
    "allow": ["$defaults", "Deploying to staging is allowed"]
  }
}
```

Include `"$defaults"` to inherit built-in rules at that position. Omitting it replaces the entire list. Read from user settings, local project settings, and managed settings — **not** from shared project settings (`.claude/settings.json`).

Use `claude auto-mode defaults` to see built-in rules, `claude auto-mode config` to see the effective config, and `claude auto-mode critique` for AI feedback on your custom rules.

### Server-Managed Settings

Available for Claude for Teams and Enterprise plans. Configure at **Admin Settings > Claude Code > Managed settings** in Claude.ai. Settings reach devices at authentication and refresh hourly. Supports all `settings.json` keys except those restricted to OS-level delivery (`policyHelper`, `wslInheritsWindowsSettings`). A `managed-mcp.json` file cannot be distributed through server-managed settings.

Set `forceRemoteSettingsRefresh: true` to block CLI startup until fresh settings are fetched (fail-closed enforcement).

### Verify Active Settings

Run `/status` inside Claude Code to see active settings sources. The `Setting sources` line shows each loaded layer (e.g., `Enterprise managed settings (remote)`, `(plist)`, `(HKLM)`, `(file)`). A layer only appears when it has at least one key.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — all settings.json keys, scopes, precedence, plugin settings, sandbox and worktree configuration, attribution, file suggestion, hook configuration, policy helper
- [Set up Claude Code for your organization](references/claude-code-admin-setup.md) — admin decision map: API provider selection, managed settings delivery, enforcement controls, usage visibility, data handling
- [Configure permissions](references/claude-code-permissions.md) — permission system, modes, rule syntax, tool-specific rules (Bash, PowerShell, Read, Edit, WebFetch, MCP, Agent), hooks, working directories, managed-only settings
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — server delivery setup, fetch and caching behavior, security approval dialogs, fail-closed enforcement, audit logging
- [Environment variables](references/claude-code-env-vars.md) — full reference for all environment variables controlling Claude Code behavior
- [Choose a permission mode](references/claude-code-permission-modes.md) — detailed mode descriptions, how to switch modes, auto mode classifier details, protected paths
- [Configure auto mode](references/claude-code-auto-mode-config.md) — autoMode settings block, trusted infrastructure definition, override block/allow rules, CLI inspection subcommands

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Set up Claude Code for your organization: https://code.claude.com/docs/en/admin-setup.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
