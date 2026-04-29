---
name: settings-doc
description: Complete official documentation for Claude Code settings — configuration scopes, settings files, all available settings keys, environment variables, permission system, permission rule syntax, permission modes (default/acceptEdits/plan/auto/dontAsk/bypassPermissions), auto mode configuration, server-managed settings, admin setup, and sandboxing settings.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, and configuration.

## Quick Reference

### Configuration scopes and file locations

| Scope | File location | Who it affects | Shared with team? |
| :--- | :--- | :--- | :--- |
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | All users on the machine | Yes (deployed by IT) |
| **User** | `~/.claude/settings.json` | You, across all projects | No |
| **Project** | `.claude/settings.json` | All collaborators | Yes (committed to git) |
| **Local** | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |

**Precedence** (highest to lowest): Managed → Command-line args → Local → Project → User

Array settings (like `permissions.allow`) merge across scopes rather than replace — lower-priority scopes can add entries without overriding higher-priority ones.

Other config:
- `~/.claude.json` — OAuth session, MCP server configs, per-project state
- `.mcp.json` — project-scoped MCP servers
- `~/.claude/agents/`, `.claude/agents/` — subagent definitions

### Key settings in `settings.json`

| Key | Description | Example |
| :--- | :--- | :--- |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `apiKeyHelper` | Script to generate auth value | `"/bin/generate_key.sh"` |
| `permissions` | See permission settings table | — |
| `env` | Environment variables for every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle hook commands | See hooks docs |
| `defaultShell` | Shell for bash commands: `"bash"` or `"powershell"` | `"bash"` |
| `editorMode` | Key binding mode: `"normal"` or `"vim"` | `"vim"` |
| `language` | Claude's preferred response language | `"japanese"` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) | `"stable"` |
| `minimumVersion` | Minimum allowed CLI version | `"2.1.100"` |
| `tui` | Terminal renderer: `"default"` or `"fullscreen"` | `"fullscreen"` |
| `cleanupPeriodDays` | Days to retain session files (default 30) | `20` |
| `companyAnnouncements` | Messages shown at startup | `["Welcome to Acme!"]` |
| `alwaysThinkingEnabled` | Enable extended thinking by default | `true` |
| `effortLevel` | Persist effort: `"low"`, `"medium"`, `"high"`, `"xhigh"` | `"xhigh"` |
| `autoMode` | Auto mode classifier config; see auto mode section | — |
| `sandbox` | Sandboxing config; see sandbox section | — |
| `attribution` | Git commit/PR attribution strings | `{"commit": "...", "pr": ""}` |
| `fileSuggestion` | Custom command for `@` file autocomplete | `{"type": "command", "command": "~/.claude/file-suggest.sh"}` |
| `outputStyle` | Configure a custom output style | `"Explanatory"` |
| `statusLine` | Custom status line command | `{"type": "command", "command": "~/.claude/statusline.sh"}` |
| `voice` | Voice dictation settings | `{"enabled": true, "mode": "tap"}` |
| `teammateMode` | Agent team display: `"auto"`, `"in-process"`, `"tmux"` | `"in-process"` |
| `plansDirectory` | Where plan files are stored | `"./plans"` |
| `forceLoginMethod` | `"claudeai"` or `"console"` | `"claudeai"` |
| `forceLoginOrgUUID` | Require login to a specific org UUID | `"xxxx-xxxx-..."` |
| `availableModels` | Restrict models selectable via `/model` | `["sonnet", "haiku"]` |
| `skipWebFetchPreflight` | Skip WebFetch domain safety check (for Bedrock/Vertex/Foundry) | `true` |
| `viewMode` | Default transcript view: `"default"`, `"verbose"`, `"focus"` | `"verbose"` |
| `enabledPlugins` | Enable/disable plugins by `"name@marketplace"` key | `{"formatter@acme": true}` |
| `extraKnownMarketplaces` | Additional marketplace sources for the team | See plugins docs |

**Managed-only settings** (no effect in user/project settings):
`allowManagedPermissionRulesOnly`, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowedChannelPlugins`, `channelsEnabled`, `forceRemoteSettingsRefresh`, `blockedMarketplaces`, `strictKnownMarketplaces`, `pluginTrustMessage`, `sandbox.filesystem.allowManagedReadPathsOnly`, `sandbox.network.allowManagedDomainsOnly`, `wslInheritsWindowsSettings`

**Global config** (stored in `~/.claude.json`, not `settings.json`):
`autoConnectIde`, `autoInstallIdeExtension`, `externalEditorContext`

**Worktree settings:**

| Key | Description | Example |
| :--- | :--- | :--- |
| `worktree.symlinkDirectories` | Dirs to symlink into worktrees (avoid duplicating) | `["node_modules"]` |
| `worktree.sparsePaths` | Dirs to sparse-checkout in worktrees | `["packages/my-app"]` |

### Permission settings

| Key | Description | Example |
| :--- | :--- | :--- |
| `permissions.allow` | Tool use rules to allow | `["Bash(git diff *)"]` |
| `permissions.ask` | Rules to always confirm | `["Bash(git push *)"]` |
| `permissions.deny` | Rules to block | `["WebFetch", "Read(./.env)"]` |
| `permissions.additionalDirectories` | Extra directories for file access | `["../docs/"]` |
| `permissions.defaultMode` | Default permission mode | `"acceptEdits"` |
| `permissions.disableBypassPermissionsMode` | Prevent bypass mode: `"disable"` | `"disable"` |
| `permissions.skipDangerousModePermissionPrompt` | Skip bypass confirmation | `true` |

**Rule evaluation order**: deny → ask → allow (first match wins)

### Permission rule syntax

Format: `Tool` or `Tool(specifier)`

| Rule | Effect |
| :--- | :--- |
| `Bash` | All bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Bash(git * main)` | git commands ending in `main` |
| `Read(./.env)` | Reading the `.env` file |
| `Edit(/src/**)` | Edits in project's `src/` (recursive) |
| `WebFetch(domain:example.com)` | Fetch to example.com |
| `mcp__puppeteer` | Any tool from puppeteer MCP server |
| `Agent(Explore)` | The Explore subagent |

**Read/Edit path prefixes:**
- `//path` — absolute path from filesystem root
- `~/path` — relative to home directory
- `/path` — relative to project root
- `path` or `./path` — relative to current directory

**Compound commands**: each sub-command must match a rule independently. Bash patterns support `*` for any sequence (including spaces). Word boundary: `Bash(ls *)` matches `ls -la` but not `lsof`; `Bash(ls*)` matches both.

**Read-only Bash commands** (never prompt, any mode): `ls`, `cat`, `head`, `tail`, `grep`, `find`, `wc`, `diff`, `stat`, `du`, `cd`, read-only `git`.

### Permission modes

Set with `--permission-mode <mode>` or `permissions.defaultMode` in settings. Cycle modes with Shift+Tab in CLI.

| Mode | What runs without prompting | Best for |
| :--- | :--- | :--- |
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands | Iterating on code |
| `plan` | Reads only (Claude proposes, doesn't modify) | Exploring before changing |
| `auto` | Everything, with background classifier checks | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools from `permissions.allow` | Locked-down CI |
| `bypassPermissions` | Everything except protected paths | Containers/VMs only |

**Protected paths** (always prompt in every mode): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`)

**Auto mode requirements**: Max/Team/Enterprise/API plan; admin must enable on Team/Enterprise; Sonnet 4.6+, Opus 4.6+, or Opus 4.7 model; Anthropic API only (not Bedrock/Vertex/Foundry).

**Auto mode blocked by default**: downloading and executing code, sending data to external endpoints, production deploys/migrations, mass cloud deletion, IAM changes, force push/push to main.

To disable auto mode: set `permissions.disableAutoMode: "disable"` in managed settings.

### Auto mode configuration (`autoMode`)

Not read from shared project settings (`.claude/settings.json`) — use user, local, or managed settings.

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp and all repos under it",
      "Trusted domains: *.corp.example.com",
      "Trusted buckets: s3://acme-builds"
    ],
    "allow": ["$defaults", "Deploying to staging namespace is allowed"],
    "soft_deny": ["$defaults", "Never run DB migrations outside the migrations CLI"]
  }
}
```

Include `"$defaults"` to inherit built-in rules. Omitting it replaces the entire list for that section.

CLI subcommands: `claude auto-mode defaults`, `claude auto-mode config`, `claude auto-mode critique`

### Sandbox settings

All under `"sandbox": { ... }` in `settings.json`:

| Key | Description | Default |
| :--- | :--- | :--- |
| `enabled` | Enable bash sandboxing | `false` |
| `failIfUnavailable` | Exit if sandbox can't start | `false` |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed | `true` |
| `excludedCommands` | Commands that run outside sandbox | `[]` |
| `allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch | `true` |
| `filesystem.allowWrite` | Paths sandboxed commands can write | `[]` |
| `filesystem.denyWrite` | Paths sandboxed commands cannot write | `[]` |
| `filesystem.denyRead` | Paths sandboxed commands cannot read | `[]` |
| `filesystem.allowRead` | Re-allow reads within denyRead regions | `[]` |
| `network.allowedDomains` | Outbound domains allowed (supports wildcards) | — |
| `network.deniedDomains` | Outbound domains blocked (takes precedence) | — |
| `network.allowLocalBinding` | Allow binding to localhost ports (macOS) | `false` |
| `network.allowUnixSockets` | Unix socket paths accessible (macOS only) | — |
| `network.httpProxyPort` | Bring your own HTTP proxy port | — |
| `network.socksProxyPort` | Bring your own SOCKS5 proxy port | — |

Sandbox path prefixes: `/` = absolute, `~/` = home-relative, `./` or no prefix = project/user-config relative.

### Managed settings delivery mechanisms

| Mechanism | Location | Priority |
| :--- | :--- | :--- |
| Server-managed (admin console) | Claude.ai admin console | Highest |
| macOS plist | `com.anthropic.claudecode` managed preferences | High |
| Windows HKLM registry | `HKLM\SOFTWARE\Policies\ClaudeCode` | High |
| File-based: macOS | `/Library/Application Support/ClaudeCode/managed-settings.json` | Medium |
| File-based: Linux/WSL | `/etc/claude-code/managed-settings.json` | Medium |
| File-based: Windows | `C:\Program Files\ClaudeCode\managed-settings.json` | Medium |
| Windows HKCU registry | `HKCU\SOFTWARE\Policies\ClaudeCode` | Lowest |

File-based settings support a drop-in directory at `managed-settings.d/` (sorted alphabetically, merged on top of base file).

**Server-managed settings** require Teams/Enterprise plan and `api.anthropic.com` access. Settings are fetched at startup and polled hourly. Set `forceRemoteSettingsRefresh: true` to block startup until fresh fetch succeeds.

**Server-managed limitations**: uniform for all users (no per-group), cannot distribute MCP server configs.

**Security approval dialogs**: users must approve shell command settings, custom env vars, and hook configurations before they're applied.

### Key environment variables

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key for authentication |
| `ANTHROPIC_MODEL` | Model to use |
| `ANTHROPIC_BASE_URL` | Override API endpoint |
| `CLAUDE_CONFIG_DIR` | Override config directory (default `~/.claude`) |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry collection |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Skip writing session transcripts to disk |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable autoupdater, feedback, error reporting, telemetry |
| `BASH_DEFAULT_TIMEOUT_MS` | Default timeout for bash commands (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max timeout for bash commands (default: 600000) |
| `DISABLE_AUTOUPDATER` | Disable background auto-updates |
| `DISABLE_UPDATES` | Block all updates including manual `claude update` |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget |
| `CLAUDE_CODE_EFFORT_LEVEL` | Effort level: `low`, `medium`, `high`, `xhigh`, `auto` |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Max output tokens per request |
| `DISABLE_AUTO_COMPACT` | Disable auto-compaction |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess environments |
| `CLAUDE_CODE_SHELL` | Override shell detection |
| `CLAUDE_CODE_SHELL_PREFIX` | Prefix to wrap all bash commands |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server for network connections |
| `CLAUDE_CODE_OAUTH_TOKEN` | OAuth access token for Claude.ai auth |
| `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` | Load CLAUDE.md from `--add-dir` directories |
| `CLAUDECODE` | Set to `1` in shells Claude Code spawns (detect Claude-spawned environment) |

Full env var reference: see [claude-code-env-vars.md](references/claude-code-env-vars.md).

### Verify active settings

Run `/status` inside Claude Code to see which settings sources are active and where they come from. Run `/permissions` to view effective permission rules.

### Admin setup decision map

| Decision | Key settings |
| :--- | :--- |
| Permission rules | `permissions.allow`, `permissions.deny` |
| Permission lockdown | `allowManagedPermissionRulesOnly`, `permissions.disableBypassPermissionsMode` |
| Sandboxing | `sandbox.enabled`, `sandbox.network.allowedDomains` |
| MCP control | `allowedMcpServers`, `deniedMcpServers`, `allowManagedMcpServersOnly` |
| Plugin marketplace control | `strictKnownMarketplaces`, `blockedMarketplaces` |
| Hook restrictions | `allowManagedHooksOnly`, `allowedHttpHookUrls` |
| Version floor | `minimumVersion` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Settings](references/claude-code-settings.md) — configuration scopes, settings files, all available settings keys, permissions, sandbox, attribution, file suggestion, hook configuration, plugin configuration, settings precedence
- [Admin setup](references/claude-code-admin-setup.md) — deployment decision map: choosing API provider, managed settings delivery mechanisms, what to enforce, usage visibility, data handling
- [Permissions](references/claude-code-permissions.md) — permission system, permission modes, rule syntax, tool-specific rules (Bash/Read/Edit/WebFetch/MCP/Agent), hooks, working directories, sandboxing interaction, managed settings
- [Server-managed settings](references/claude-code-server-managed-settings.md) — configuring from the Claude.ai admin console, fetch/caching behavior, fail-closed startup, security approval dialogs, audit logging, security considerations
- [Environment variables](references/claude-code-env-vars.md) — complete reference for all environment variables controlling Claude Code behavior
- [Permission modes](references/claude-code-permission-modes.md) — detailed reference for all modes (default/acceptEdits/plan/auto/dontAsk/bypassPermissions), switching modes, auto mode requirements and classifier behavior, protected paths
- [Configure auto mode](references/claude-code-auto-mode-config.md) — autoMode.environment, autoMode.allow, autoMode.soft_deny, CLI subcommands for inspecting config, reviewing denials

## Sources

- Settings: https://code.claude.com/docs/en/settings.md
- Admin setup: https://code.claude.com/docs/en/admin-setup.md
- Permissions: https://code.claude.com/docs/en/permissions.md
- Server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Permission modes: https://code.claude.com/docs/en/permission-modes.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
