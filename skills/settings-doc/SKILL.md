---
name: settings-doc
user-invocable: false
---

# Settings & Configuration Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, environment variables, permission modes, server-managed settings, and auto mode configuration.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared? |
| :--- | :--- | :--- | :--- |
| **Managed** | Server, plist/registry, or `managed-settings.json` | All users on the machine | Yes (IT-deployed) |
| **User** | `~/.claude/settings.json` | You, across all projects | No |
| **Project** | `.claude/settings.json` | All collaborators | Yes (git) |
| **Local** | `.claude/settings.local.json` | You, this project only | No (gitignored) |

Precedence (highest first): Managed > CLI args > Local > Project > User

Array settings (`permissions.allow`, `permissions.deny`, sandbox paths) **merge** across scopes — they concatenate rather than override. Exceptions: `fallbackModel` (highest-precedence scope wins) and `availableModels` (managed value replaces lower-precedence entries).

### Managed Settings Delivery Mechanisms

| Mechanism | Platform | Priority |
| :--- | :--- | :--- |
| Server-managed (Claude.ai admin console) | All | Highest |
| plist (`com.anthropic.claudecode`) / HKLM registry | macOS / Windows | High |
| File: `/Library/Application Support/ClaudeCode/managed-settings.json` (macOS), `/etc/claude-code/` (Linux/WSL), `C:\Program Files\ClaudeCode\` (Windows) | All | Medium |
| HKCU registry | Windows only | Lowest |

Drop-in directory: place `*.json` fragments in `managed-settings.d/` alongside `managed-settings.json`. Files merge alphabetically on top of the base; use numeric prefixes like `10-telemetry.json` to control order.

### Key Settings Keys

| Key | Description | Default |
| :--- | :--- | :--- |
| `model` | Override default model | — |
| `theme` | UI color theme (`"dark"`, `"light"`, `"auto"`, daltonized, ANSI variants) | `"dark"` |
| `verbose` | Show full tool output | `false` |
| `autoCompactEnabled` | Auto-compact when context approaches limit | `true` |
| `fileCheckpointingEnabled` | Snapshot files before edits for `/rewind` | `true` |
| `autoMemoryEnabled` | Enable auto memory read/write | `true` |
| `autoMemoryDirectory` | Custom path for auto memory storage | — |
| `editorMode` | Input key bindings: `"normal"` or `"vim"` | `"normal"` |
| `effortLevel` | Effort level: `"low"`, `"medium"`, `"high"`, `"xhigh"` | — |
| `alwaysThinkingEnabled` | Enable extended thinking for all sessions | `false` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` | `"latest"` |
| `tui` | Terminal renderer: `"fullscreen"` or `"default"` | `"default"` |
| `outputStyle` | System-prompt output style | — |
| `language` | Claude's preferred response language | — |
| `spinnerTipsEnabled` | Show tips while Claude works | `true` |
| `preferredNotifChannel` | Notification method for task-complete/permission prompts | `"auto"` |
| `hooks` | Hook configurations (see hooks-doc skill) | — |
| `env` | Environment variables for every session | — |
| `cleanupPeriodDays` | Days before session files are deleted (min 1) | 30 |
| `companyAnnouncements` | Startup announcements to display to users | — |
| `attribution` | Customize git commit / PR attribution text | — |
| `apiKeyHelper` | Script to generate auth value (sent as X-Api-Key) | — |
| `autoMode` | Auto mode classifier config (environment/allow/soft_deny/hard_deny) | — |
| `statusLine` | Custom status line command | — |
| `fallbackModel` | Ordered chain of fallback models on overload | — |
| `plansDirectory` | Where plan files are stored | `~/.claude/plans` |
| `minimumVersion` | Floor for auto-updates (prevents downgrades) | — |
| `requiredMinimumVersion` | Hard floor: refuses to start below this version (managed only) | — |
| `requiredMaximumVersion` | Hard ceiling: refuses to start above this version (managed only) | — |

### Permission Settings

Nested under `permissions` in `settings.json`:

| Key | Description |
| :--- | :--- |
| `allow` | Array of permission rules to auto-approve |
| `ask` | Array of rules to prompt for confirmation |
| `deny` | Array of rules to block |
| `additionalDirectories` | Extra working directories for file access |
| `defaultMode` | Default permission mode on startup |
| `disableBypassPermissionsMode` | Set `"disable"` to block bypass-permissions mode |
| `skipDangerousModePermissionPrompt` | Skip bypass-mode confirmation prompt |

**Permission rule evaluation order**: deny first, then ask, then allow. A matching deny rule cannot be overridden by a more specific allow rule.

### Permission Rule Syntax

| Pattern | Effect |
| :--- | :--- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Bash(git * main)` | git commands ending in `main` |
| `Read(./.env)` | Reading `.env` in current directory |
| `Read(~/Documents/*.pdf)` | Files in home Documents |
| `Edit(/src/**)` | Edits under project root `src/` |
| `Read(//**/.env)` | Any `.env` anywhere on filesystem |
| `WebFetch(domain:example.com)` | Fetches to example.com |
| `WebFetch(domain:*.example.com)` | Any subdomain of example.com |
| `mcp__github__get_*` | All `get_` tools from github server |
| `Agent(Explore)` | Explore subagent |

**Path anchors for Read/Edit**: `//path` = absolute, `~/path` = home-relative, `/path` = project-root-relative, `path` or `./path` = cwd-relative.

**Tool name wildcards**: `"*"` denies every tool; `"mcp__*"` denies all MCP tools. Allow rules only accept tool-name globs after a literal `mcp__<server>__` prefix.

**Parameter matching** (deny/ask only): `Agent(model:opus)`, `Bash(run_in_background:true)`. Not supported for fields with their own specifier syntax (command, file_path, url, etc.).

### Permission Modes

| Mode | What runs without asking | Best for |
| :--- | :--- | :--- |
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands | Iterating on code |
| `plan` | Reads only (no edits, writes a plan) | Exploring before changing |
| `auto` | Everything, with background safety classifier | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down CI and scripts |
| `bypassPermissions` | Everything (no prompts, even protected paths) | Isolated containers/VMs only |

Switch modes with `Shift+Tab` in CLI, or set `permissions.defaultMode` in settings. `auto` is ignored in project/local settings — place it in `~/.claude/settings.json`.

**Protected paths** are never auto-approved in any mode except `bypassPermissions`: `.git`, `.config/git`, `.vscode`, `.idea`, `.husky`, `.cargo`, `.devcontainer`, `.yarn`, `.mvn`, `.claude` (except `.claude/worktrees`), plus shell config files, `package.json`-ecosystem files, and `.mcp.json`.

### Sandbox Settings

Nested under `sandbox` in `settings.json`:

| Key | Description |
| :--- | :--- |
| `enabled` | Enable OS-level bash sandboxing (macOS, Linux, WSL2) |
| `autoAllowBashIfSandboxed` | Auto-approve bash commands when sandboxed (default: true) |
| `excludedCommands` | Commands that run outside the sandbox |
| `allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch (default: true) |
| `filesystem.allowWrite` | Paths sandboxed commands can write (merged across scopes) |
| `filesystem.denyWrite` | Paths sandboxed commands cannot write |
| `filesystem.denyRead` | Paths sandboxed commands cannot read |
| `filesystem.allowRead` | Re-allow reads within denyRead regions |
| `network.allowedDomains` | Domains allowed for outbound traffic (wildcards supported) |
| `network.deniedDomains` | Domains blocked for outbound traffic |
| `network.allowLocalBinding` | Allow binding to localhost ports (macOS only) |
| `network.allowUnixSockets` | Unix socket paths accessible in sandbox (macOS only) |
| `network.allowAllUnixSockets` | Allow all Unix socket connections (Linux/WSL2) |

Sandbox path prefixes: `/` = absolute, `~/` = home-relative, `./` or no prefix = project-relative (project settings) or `~/.claude`-relative (user settings).

### Auto Mode Classifier Configuration

Configure via `autoMode` in `settings.json`. Not read from shared project settings (`.claude/settings.json`).

| Field | Description |
| :--- | :--- |
| `environment` | Prose list of trusted repos, buckets, domains, services |
| `allow` | Prose exceptions to soft-deny rules |
| `soft_deny` | Destructive actions that user intent can override |
| `hard_deny` | Unconditional security blocks (user intent cannot override) |

Include `"$defaults"` in any array to inherit the built-in rules at that position. **Warning**: omitting `"$defaults"` replaces the entire default list for that field.

CLI tools: `claude auto-mode defaults` (print built-ins), `claude auto-mode config` (print effective config), `claude auto-mode critique` (AI review of custom rules).

**Blocked by default**: `curl | bash`, sending data to external endpoints, production deploys, mass deletion, IAM changes, force push to main, `git reset --hard`, `terraform destroy`.

**Allowed by default**: local file edits, installing lock-file dependencies, read-only HTTP, pushing to the branch you started on.

### Server-Managed Settings

Available for Claude for Teams and Enterprise. Delivered from the Claude.ai admin console, fetched at startup and polled hourly.

**Security approval**: shell commands, custom env vars, and hooks in managed settings require user approval before being applied.

**Limitations**: no per-group configs, `managed-mcp.json` cannot be delivered via server (use `allowedMcpServers`/`deniedMcpServers` instead), `policyHelper` and `wslInheritsWindowsSettings` require OS-level delivery.

**Fail-closed startup**: set `forceRemoteSettingsRefresh: true` to block startup if the fetch fails (auto-perpetuates via cache).

**Managed-only settings** (ignored in user/project settings): `allowAllClaudeAiMcps`, `allowedChannelPlugins`, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowManagedPermissionRulesOnly`, `blockedMarketplaces`, `channelsEnabled`, `claudeMd`, `forceRemoteSettingsRefresh`, `pluginTrustMessage`, `sandbox.filesystem.allowManagedReadPathsOnly`, `sandbox.network.allowManagedDomainsOnly`, `strictKnownMarketplaces`, `strictPluginOnlyCustomization`, `wslInheritsWindowsSettings`.

### Key Environment Variables

Variables in `settings.json` under the `env` key take effect every session; shell variables override for that terminal.

**Auth & API routing**:

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key (bypasses subscription) |
| `ANTHROPIC_BASE_URL` | Proxy/gateway endpoint |
| `ANTHROPIC_MODEL` | Model override |
| `CLAUDE_CODE_USE_BEDROCK` / `_VERTEX` / `_FOUNDRY` | Use alternate provider |

**Behavior toggles**:

| Variable | Purpose |
| :--- | :--- |
| `DISABLE_AUTOUPDATER` | Disable auto-updates |
| `DISABLE_TELEMETRY` / `DO_NOT_TRACK` | Opt out of telemetry |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_DISABLE_BUNDLED_SKILLS` | Remove bundled skills/workflows |
| `CLAUDE_CODE_DISABLE_AGENT_VIEW` | Turn off background agents |
| `DISABLE_AUTO_COMPACT` | Disable auto-compaction |
| `MAX_THINKING_TOKENS` | Override extended thinking budget |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout model can set (default: 600000) |
| `API_TIMEOUT_MS` | API request timeout (default: 600000) |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry metrics |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level (`low`/`medium`/`high`/`xhigh`) |
| `CLAUDE_CODE_ENABLE_AUTO_MODE` | Enable auto mode on Bedrock/Vertex/Foundry |
| `CLAUDE_CODE_NO_FLICKER` / `tui: "fullscreen"` | Enable fullscreen TUI renderer |
| `CLAUDE_CODE_SAFE_MODE` | Start with all customizations disabled |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude` config directory |
| `CLAUDECODE` | Set to `1` in Claude-spawned subprocesses |
| `CLAUDE_CODE_CHILD_SESSION` | Set to `1` in tool/hook subprocesses (not MCP stdio) |

**Observability (OpenTelemetry)**:

Set `CLAUDE_CODE_ENABLE_TELEMETRY=1`, then configure standard OTEL exporters (`OTEL_METRICS_EXPORTER`, `OTEL_EXPORTER_OTLP_ENDPOINT`, etc.). Use `OTEL_LOG_TOOL_CONTENT=1` and `OTEL_LOG_USER_PROMPTS=1` to include tool/prompt content in traces (off by default).

### Global Config Settings (`~/.claude.json`)

Not part of `settings.json` — adding these there causes validation errors:

| Key | Description |
| :--- | :--- |
| `autoConnectIde` | Auto-connect to running IDE (default: false) |
| `autoInstallIdeExtension` | Auto-install IDE extension in VS Code (default: true) |
| `externalEditorContext` | Prepend last response when opening external editor |
| `teammateDefaultModel` | Default model for agent team teammates |

### Worktree Settings

Nested under `worktree` in `settings.json`:

| Key | Description |
| :--- | :--- |
| `worktree.baseRef` | `"fresh"` (from remote default branch) or `"head"` (from local HEAD) |
| `worktree.symlinkDirectories` | Dirs to symlink from main repo into worktrees |
| `worktree.sparsePaths` | Dirs to check out via sparse-checkout |
| `worktree.bgIsolation` | `"worktree"` (default) or `"none"` for background session isolation |

### Plugin Settings

| Key | Description |
| :--- | :--- |
| `enabledPlugins` | `"plugin@marketplace": true/false` |
| `extraKnownMarketplaces` | Additional marketplace definitions for the project |
| `strictKnownMarketplaces` | (Managed only) Allowlist of permitted marketplace sources |
| `blockedMarketplaces` | (Managed only) Blocked marketplace sources |

### Verify Active Settings

Run `/status` and check the **Status** tab → `Setting sources` line. Each active scope is listed; managed settings show the channel: `(remote)`, `(plist)`, `(HKLM)`, `(HKCU)`, or `(file)`. Run `/doctor` for validation errors.

The `$schema` key in `settings.json` enables editor autocomplete:
```
"$schema": "https://json.schemastore.org/claude-code-settings.json"
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — Full settings reference: scopes, precedence, all available keys, sandbox, attribution, hook configuration, plugin settings, worktree settings, policy helper
- [Org admin setup](references/claude-code-admin-setup.md) — Decision map for deploying Claude Code: API provider, settings delivery, enforcement, usage monitoring, data handling
- [Configure permissions](references/claude-code-permissions.md) — Permission system, rule syntax, tool-specific rules (Bash, Read/Edit, WebFetch, MCP, Agent, Cd), working directories, sandboxing interaction, managed settings
- [Server-managed settings](references/claude-code-server-managed-settings.md) — Claude.ai admin console delivery, caching, fail-closed startup, security approval dialogs, audit logging
- [Environment variables](references/claude-code-env-vars.md) — Complete variable reference: auth, routing, behavior toggles, MCP, OTel, provider-specific
- [Permission modes](references/claude-code-permission-modes.md) — All six modes in depth, switching mechanisms, auto mode classifier, protected paths, dontAsk/bypassPermissions
- [Configure auto mode](references/claude-code-auto-mode-config.md) — autoMode settings block, trusted infrastructure, override rules, CLI subcommands, reviewing denials

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Org admin setup: https://code.claude.com/docs/en/admin-setup.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Permission modes: https://code.claude.com/docs/en/permission-modes.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
