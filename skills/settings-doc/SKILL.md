---
name: settings-doc
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, environment variables, permission modes, auto mode configuration, server-managed settings, and admin setup.

## Quick Reference

### Configuration scopes and file locations

| Scope       | File location                                             | Who it affects                         | Shared? |
| :---------- | :-------------------------------------------------------- | :------------------------------------- | :------ |
| **Managed** | Server, plist/registry, or system `managed-settings.json` | All users on the machine               | Yes (IT-deployed) |
| **User**    | `~/.claude/settings.json`                                 | You, across all projects               | No      |
| **Project** | `.claude/settings.json`                                   | All collaborators on this repo         | Yes (git) |
| **Local**   | `.claude/settings.local.json`                             | You, in this repo only                 | No (gitignored) |

Precedence (highest to lowest): Managed > Command-line args > Local > Project > User

**Array settings** (e.g., `permissions.allow`, `sandbox.filesystem.allowWrite`) merge and deduplicate across scopes rather than override.

### Managed settings delivery mechanisms

| Mechanism             | Location                                                                                 | Priority |
| :-------------------- | :--------------------------------------------------------------------------------------- | :------- |
| Server-managed        | Claude.ai admin console → all platforms                                                  | Highest  |
| plist / registry      | macOS: `com.anthropic.claudecode` plist; Windows: `HKLM\SOFTWARE\Policies\ClaudeCode`   | High     |
| File-based managed    | macOS: `/Library/Application Support/ClaudeCode/`; Linux/WSL: `/etc/claude-code/`; Windows: `C:\Program Files\ClaudeCode\` | Medium |
| Windows user registry | `HKCU\SOFTWARE\Policies\ClaudeCode`                                                      | Lowest   |

Drop-in directory `managed-settings.d/` alongside `managed-settings.json` lets separate teams add policy fragments. Files are sorted alphabetically and deep-merged on top of the base file.

### Key `settings.json` fields (selected)

| Key | Description | Example |
| :-- | :---------- | :------ |
| `agent` | Run main thread as a named subagent | `"code-reviewer"` |
| `apiKeyHelper` | Shell script generating an auth token (sent as `X-Api-Key`) | `/bin/gen_key.sh` |
| `attribution` | Customize git commit / PR attribution text | `{"commit": "...", "pr": ""}` |
| `autoMemoryEnabled` | Enable/disable auto memory (default: `true`) | `false` |
| `autoMode` | Configure auto mode classifier rules | `{"soft_deny": ["$defaults", "..."]}` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) | `"stable"` |
| `availableModels` | Restrict which models users can select | `["sonnet", "haiku"]` |
| `cleanupPeriodDays` | Days before session files are deleted (default: 30) | `20` |
| `companyAnnouncements` | Messages shown at startup (cycled randomly) | `["Welcome to Acme Corp!"]` |
| `defaultShell` | `"bash"` (default) or `"powershell"` | `"powershell"` |
| `disableAllHooks` | Disable all hooks and custom status line | `true` |
| `disableAutoMode` | Set to `"disable"` to prevent auto mode | `"disable"` |
| `editorMode` | Input prompt key bindings: `"normal"` or `"vim"` | `"vim"` |
| `effortLevel` | Persist effort level: `"low"`, `"medium"`, `"high"`, `"xhigh"` | `"xhigh"` |
| `enableAllProjectMcpServers` | Auto-approve all `.mcp.json` MCP servers | `true` |
| `env` | Environment variables applied to every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle hooks (see hooks-doc) | See hooks-doc |
| `language` | Claude's preferred response language | `"japanese"` |
| `minimumVersion` | Org-wide minimum version floor | `"2.1.100"` |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `outputStyle` | System-prompt output style | `"Explanatory"` |
| `permissions` | Permission rules — see permission settings below | |
| `sandbox` | OS-level sandboxing — see sandbox settings below | |
| `skillOverrides` | Per-skill visibility: `"on"`, `"name-only"`, `"user-invocable-only"`, `"off"` | `{"deploy": "off"}` |
| `spinnerTipsEnabled` | Show tips in spinner (default: `true`) | `false` |
| `statusLine` | Custom status line command | `{"type": "command", "command": "~/.claude/status.sh"}` |
| `tui` | Terminal UI renderer: `"fullscreen"` or `"default"` | `"fullscreen"` |
| `viewMode` | Default transcript view: `"default"`, `"verbose"`, `"focus"` | `"verbose"` |

Settings that reload live (no restart): `permissions`, `hooks`, `apiKeyHelper`, most keys.
Settings that require restart: `model`, `outputStyle`.

### Permission settings (`permissions.*`)

| Key | Description | Example |
| :-- | :---------- | :------ |
| `allow` | Rules to allow without prompting | `["Bash(npm run *)", "Read(~/.zshrc)"]` |
| `ask` | Rules to always prompt for | `["Bash(git push *)"]` |
| `deny` | Rules to block entirely | `["WebFetch", "Bash(curl *)", "Read(./.env)"]` |
| `additionalDirectories` | Extra directories for file access | `["../docs/"]` |
| `defaultMode` | Default permission mode on startup | `"acceptEdits"` |
| `disableBypassPermissionsMode` | `"disable"` to block `bypassPermissions` mode | `"disable"` |
| `skipDangerousModePermissionPrompt` | Skip confirmation before `bypassPermissions` | `true` |

**Rule evaluation order: deny → ask → allow. First match wins. Deny rules take precedence.**

### Permission rule syntax

| Pattern | Meaning |
| :------ | :------ |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` (space before `*` enforces word boundary) |
| `Read(./.env)` | Reading `.env` in current directory |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer__navigate` | Specific MCP tool |
| `Agent(Explore)` | Specific subagent |
| `//path` | Absolute path from filesystem root |
| `~/path` | Path from home directory |
| `/path` | Path relative to project root |
| `path` or `./path` | Path relative to current directory |

`*` matches any sequence including spaces; `**` matches recursively across directories. Deny and allow rules evaluate symlinks at both the link path and its target.

### Permission modes

| Mode | What runs without asking | Best for |
| :--- | :----------------------- | :------- |
| `default` | Reads only | Sensitive work, getting started |
| `acceptEdits` | Reads, file edits, common filesystem commands (`mkdir`, `touch`, `mv`, `cp`, etc.) | Iterating on code |
| `plan` | Reads only — Claude proposes but does not edit | Exploring a codebase |
| `auto` | Everything, with background classifier safety checks | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | CI pipelines, locked-down scripts |
| `bypassPermissions` | Everything (no prompts) | Isolated containers/VMs only |

Switch mid-session with `Shift+Tab` (cycles `default` → `acceptEdits` → `plan`). Set at startup with `--permission-mode <mode>`. Set as default with `permissions.defaultMode` in settings.

**Protected paths** (never auto-approved except in `bypassPermissions`): `.git`, `.vscode`, `.idea`, `.husky`, most `.claude/` files, `.gitconfig`, `.bashrc`, `.zshrc`, `.mcp.json`, `.claude.json`.

### Auto mode classifier configuration (`autoMode.*`)

Only read from user settings, local settings, managed settings, or `--settings`. Not read from shared project `.claude/settings.json`.

| Key | Description |
| :-- | :---------- |
| `environment` | Prose descriptions of trusted infrastructure (repos, buckets, domains) |
| `allow` | Prose exceptions to soft-deny rules |
| `soft_deny` | Prose rules blocking destructive actions (user intent can override) |
| `hard_deny` | Prose rules that block unconditionally |

Include `"$defaults"` in any array to inherit and extend built-in rules. Omitting it **replaces the entire default list**.

Inspect with `claude auto-mode defaults`, `claude auto-mode config`, `claude auto-mode critique`.

**Auto mode requirements**: Max, Team, Enterprise, or API plan; Sonnet 4.6 / Opus 4.6 / Opus 4.7 model; Anthropic API only (not Bedrock/Vertex/Foundry). On Team/Enterprise an admin must enable it in the admin console.

### Sandbox settings (`sandbox.*`)

| Key | Description | Example |
| :-- | :---------- | :------ |
| `enabled` | Enable bash sandboxing (macOS, Linux, WSL2) | `true` |
| `failIfUnavailable` | Exit at startup if sandbox can't start | `true` |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: `true`) | `true` |
| `excludedCommands` | Commands that run outside sandbox | `["docker *"]` |
| `allowUnsandboxedCommands` | Allow escape hatch (default: `true`) | `false` |
| `filesystem.allowWrite` | Paths sandboxed commands can write | `["/tmp/build", "~/.kube"]` |
| `filesystem.denyWrite` | Paths sandboxed commands cannot write | `["/etc"]` |
| `filesystem.denyRead` | Paths sandboxed commands cannot read | `["~/.aws/credentials"]` |
| `filesystem.allowRead` | Re-allow reading within `denyRead` regions | `["."]` |
| `network.allowedDomains` | Allowed outbound domains (supports `*.example.com`) | `["github.com", "*.npmjs.org"]` |
| `network.deniedDomains` | Blocked outbound domains | `["sensitive.cloud.example.com"]` |
| `network.allowLocalBinding` | Allow binding to localhost (macOS) | `true` |
| `network.httpProxyPort` | HTTP proxy port (bring your own proxy) | `8080` |

**Sandbox path prefixes**: `/` = absolute; `~/` = home-relative; `./` or no prefix = project-relative (project settings) or `~/.claude`-relative (user settings).

### Managed-only settings

These keys only take effect when placed in managed settings; user/project settings ignore them:

`allowedChannelPlugins`, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowManagedPermissionRulesOnly`, `blockedMarketplaces`, `channelsEnabled`, `claudeMd`, `forceRemoteSettingsRefresh`, `parentSettingsBehavior`, `pluginTrustMessage`, `policyHelper`, `sandbox.filesystem.allowManagedReadPathsOnly`, `sandbox.network.allowManagedDomainsOnly`, `strictKnownMarketplaces`, `wslInheritsWindowsSettings`

### Server-managed settings

- Available for Teams and Enterprise plans (Claude Code v2.1.38+ / v2.1.30+)
- Configure at **Admin Settings → Claude Code → Managed settings** in Claude.ai
- Delivered at auth time, refreshed hourly; cached for offline resilience
- Cannot deliver MCP server configs or OS-level-only keys (`policyHelper`, `wslInheritsWindowsSettings`)
- `forceRemoteSettingsRefresh: true` blocks startup until fresh settings arrive (fail-closed)
- Security approval dialogs shown for hooks, shell commands, and custom env vars
- Not available when using Bedrock, Vertex, Foundry, or a custom `ANTHROPIC_BASE_URL`
- Verify with `/status` → look for `Enterprise managed settings (remote)` or `(plist)`, `(HKLM)`, `(HKCU)`, `(file)`

### Key environment variables (selected)

| Variable | Purpose |
| :------- | :------ |
| `ANTHROPIC_API_KEY` | API key (overrides subscription auth) |
| `ANTHROPIC_MODEL` | Default model |
| `ANTHROPIC_BASE_URL` | Override API endpoint (proxy/gateway) |
| `API_TIMEOUT_MS` | API request timeout (default: 600000ms) |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout (default: 120000ms) |
| `BASH_MAX_TIMEOUT_MS` | Maximum bash command timeout (default: 600000ms) |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude` config directory |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set to `1` to enable OpenTelemetry export |
| `CLAUDE_CODE_NO_FLICKER` | Set to `1` to enable fullscreen rendering |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level: `low`, `medium`, `high`, `xhigh` |
| `CLAUDE_CODE_DISABLE_THINKING` | Set to `1` to force-disable extended thinking |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Set to `1` to strip credentials from subprocess envs |
| `CLAUDE_ENV_FILE` | Shell script sourced before each Bash command |
| `DISABLE_AUTOUPDATER` | Set to `1` to disable background auto-updates |
| `DISABLE_TELEMETRY` or `DO_NOT_TRACK` | Opt out of telemetry |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget |
| `MCP_TIMEOUT` | MCP server startup timeout (default: 30000ms) |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server for network connections |
| `DEBUG` | Set to `1` to enable debug mode |

Environment variables take precedence over `settings.json` fields for the same behavior. Set variables in `settings.json` under the `env` key to apply them to every session.

### Plugin settings in `settings.json`

| Key | Description |
| :-- | :---------- |
| `enabledPlugins` | `{"plugin@marketplace": true/false}` — controls enabled plugins per scope |
| `extraKnownMarketplaces` | Named marketplace entries to pre-register for team members |
| `strictKnownMarketplaces` | (Managed only) Allowlist of permitted marketplace sources |
| `blockedMarketplaces` | (Managed only) Blocklist of forbidden marketplace sources |

### Worktree settings (`worktree.*`)

| Key | Description | Example |
| :-- | :---------- | :------ |
| `worktree.baseRef` | Branch new worktrees from: `"fresh"` (origin default, default) or `"head"` (local HEAD) | `"head"` |
| `worktree.symlinkDirectories` | Directories to symlink into each worktree | `["node_modules"]` |
| `worktree.sparsePaths` | Directories to check out via sparse-checkout | `["packages/my-app"]` |
| `worktree.bgIsolation` | Background session isolation: `"worktree"` (default) or `"none"` | `"none"` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Settings Reference](references/claude-code-settings.md) — all settings keys, scopes, file locations, plugin config, sandbox, worktree, attribution, precedence rules
- [Admin Setup Guide](references/claude-code-admin-setup.md) — deployment decision map for organizations: API provider, delivery mechanism, enforcement, usage monitoring, data handling
- [Permissions](references/claude-code-permissions.md) — permission rule syntax, tool-specific patterns (Bash, PowerShell, Read/Edit, WebFetch, MCP, Agent), hooks integration, working directories, sandboxing interaction, managed policies
- [Permission Modes](references/claude-code-permission-modes.md) — all six modes in detail, how to switch, auto mode classifier behavior, protected paths
- [Auto Mode Configuration](references/claude-code-auto-mode-config.md) — defining trusted infrastructure, overriding block/allow rules, CLI subcommands, reviewing denials
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) — admin console setup, delivery and caching, fail-closed enforcement, security approval dialogs, audit logging
- [Environment Variables](references/claude-code-env-vars.md) — full reference for all environment variables Claude Code reads

## Sources

- Settings Reference: https://code.claude.com/docs/en/settings.md
- Admin Setup Guide: https://code.claude.com/docs/en/admin-setup.md
- Permissions: https://code.claude.com/docs/en/permissions.md
- Permission Modes: https://code.claude.com/docs/en/permission-modes.md
- Auto Mode Configuration: https://code.claude.com/docs/en/auto-mode-config.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment Variables: https://code.claude.com/docs/en/env-vars.md
