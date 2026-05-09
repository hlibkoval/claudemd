---
name: settings-doc
description: Complete official documentation for Claude Code settings — configuration scopes, settings.json keys, permission rules and modes, environment variables, managed/server-managed settings, auto mode configuration, and admin setup for organizations.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, environment variables, and organizational deployment.

## Quick Reference

### Configuration Scopes and File Locations

| Scope | Location | Shared? | Overrides |
| :--- | :--- | :--- | :--- |
| **Managed** | Server-managed, plist/registry, or `/etc/claude-code/managed-settings.json` | Yes (IT-deployed) | Everything |
| **User** | `~/.claude/settings.json` | No | Project + Local |
| **Project** | `.claude/settings.json` | Yes (git) | User |
| **Local** | `.claude/settings.local.json` | No (gitignored) | Project + User |

Precedence (highest to lowest): Managed → CLI args → Local → Project → User

Array settings (`permissions.allow`, `sandbox.filesystem.allowWrite`, etc.) **merge across scopes** — they do not override.

### Managed Settings Delivery Mechanisms

| Mechanism | Location | Priority | Platforms |
| :--- | :--- | :--- | :--- |
| Server-managed | Claude.ai admin console | Highest | All |
| plist / registry | `com.anthropic.claudecode` plist or `HKLM\SOFTWARE\Policies\ClaudeCode` | High | macOS, Windows |
| File-based | macOS: `/Library/Application Support/ClaudeCode/managed-settings.json` Linux/WSL: `/etc/claude-code/managed-settings.json` Windows: `C:\Program Files\ClaudeCode\managed-settings.json` | Medium | All |
| Windows user registry | `HKCU\SOFTWARE\Policies\ClaudeCode` | Lowest | Windows only |

Drop-in directory: `managed-settings.d/*.json` files alongside `managed-settings.json` are merged alphabetically on top.

### Key settings.json Fields (Partial — see reference for full list)

| Key | Description | Example |
| :--- | :--- | :--- |
| `permissions` | Allow/ask/deny rules, defaultMode, sandboxing | See below |
| `env` | Environment variables for every session | `{"FOO": "bar"}` |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `hooks` | Lifecycle hooks | See hooks-doc |
| `autoMode` | Auto mode classifier config | `{"environment": [...]}` |
| `apiKeyHelper` | Script to generate API key/auth token | `"/bin/gen_key.sh"` |
| `minimumVersion` | Floor for auto-updates | `"2.1.100"` |
| `allowedMcpServers` | (Managed) Allowlist of MCP servers | `[{"serverName": "github"}]` |
| `deniedMcpServers` | (Managed) Denylist of MCP servers | `[{"serverName": "filesystem"}]` |
| `allowManagedMcpServersOnly` | (Managed) Only managed MCP servers apply | `true` |
| `allowManagedPermissionRulesOnly` | (Managed) Only managed permission rules apply | `true` |
| `allowManagedHooksOnly` | (Managed) Only managed hooks load | `true` |
| `disableBypassPermissionsMode` | Disallow `--dangerously-skip-permissions` | `"disable"` |
| `disableAutoMode` | Disallow auto mode | `"disable"` |
| `forceRemoteSettingsRefresh` | (Managed) Exit if server settings fetch fails | `true` |
| `companyAnnouncements` | Messages shown at startup | `["Welcome to Acme!"]` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` | `"stable"` |
| `availableModels` | Restrict model picker choices | `["sonnet", "haiku"]` |
| `language` | Claude's preferred response language | `"japanese"` |
| `editorMode` | `"normal"` or `"vim"` for input prompt | `"vim"` |
| `tui` | `"fullscreen"` or `"default"` renderer | `"fullscreen"` |
| `attribution` | Git commit and PR attribution text | `{"commit": "...", "pr": ""}` |
| `statusLine` | Custom status line command | `{"type": "command", "command": "..."}` |
| `worktree.baseRef` | Worktree branch base: `"fresh"` or `"head"` | `"head"` |
| `worktree.symlinkDirectories` | Dirs to symlink into worktrees | `["node_modules"]` |
| `sandbox` | Sandbox configuration block | See sandbox section |
| `sshConfigs` | SSH connections for Desktop env dropdown | `[{"id": "dev-vm", ...}]` |
| `skillOverrides` | Per-skill visibility overrides | `{"deploy": "off"}` |
| `strictKnownMarketplaces` | (Managed) Allowlist of plugin marketplace sources | `[{"source": "github", ...}]` |
| `blockedMarketplaces` | (Managed) Blocklist of marketplace sources | `[{"source": "github", ...}]` |
| `enabledPlugins` | Enable/disable plugins by name@marketplace | `{"tool@market": true}` |
| `extraKnownMarketplaces` | Additional marketplaces for team | `{"acme-tools": {...}}` |

### Permission Settings

| Key | Description | Example |
| :--- | :--- | :--- |
| `permissions.allow` | Rules to allow without prompting | `["Bash(npm run *)"]` |
| `permissions.ask` | Rules to prompt for confirmation | `["Bash(git push *)"]` |
| `permissions.deny` | Rules to block | `["WebFetch", "Read(./.env)"]` |
| `permissions.defaultMode` | Default permission mode | `"acceptEdits"` |
| `permissions.additionalDirectories` | Extra working directories | `["../docs/"]` |
| `permissions.disableBypassPermissionsMode` | Prevent bypass mode | `"disable"` |
| `permissions.skipDangerousModePermissionPrompt` | Skip bypass mode confirmation | `true` |

Rules evaluate in order: **deny → ask → allow**. First match wins.

### Permission Rule Syntax

| Pattern | Effect |
| :--- | :--- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Bash(git * main)` | Commands like `git checkout main` |
| `Read(./.env)` | Reading `.env` in current dir |
| `Read(//Users/alice/secrets/**)` | Absolute path |
| `Read(~/Documents/*.pdf)` | Home-relative path |
| `Edit(/src/**/*.ts)` | Project-root relative |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer__*` | All tools from puppeteer server |
| `Agent(Explore)` | The Explore subagent |

Bash wildcards: `*` matches any sequence including spaces. Space before `*` (e.g. `Bash(ls *)`) enforces word boundary. Process wrappers `timeout`, `time`, `nice`, `nohup`, `stdbuf` are stripped before matching.

### Permission Modes

| Mode | What runs without prompting | Best for |
| :--- | :--- | :--- |
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common FS commands (`mkdir`, `touch`, `rm`, `mv`, `cp`, `sed`) in working dir | Iterating on code |
| `plan` | Reads only (Claude proposes changes, doesn't make them) | Exploring before editing |
| `auto` | Everything, with background classifier checks | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | CI/locked-down environments |
| `bypassPermissions` | Everything (no safety checks) | Isolated containers/VMs only |

Auto mode requirements: Claude Code v2.1.83+, Max/Team/Enterprise/API plan, supported model (Sonnet 4.6, Opus 4.6, Opus 4.7), Anthropic API only.

Switch modes: `Shift+Tab` to cycle in CLI, or `--permission-mode <mode>` at startup, or set `defaultMode` in settings.

### Protected Paths (never auto-approved except in bypassPermissions)

`.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except commands/agents/skills/worktrees subdirs), `.gitconfig`, `.gitmodules`, `.bashrc`, `.bash_profile`, `.zshrc`, `.zprofile`, `.profile`, `.ripgreprc`, `.mcp.json`, `.claude.json`

### Sandbox Settings

| Key | Description | Example |
| :--- | :--- | :--- |
| `sandbox.enabled` | Enable bash sandboxing | `true` |
| `sandbox.failIfUnavailable` | Exit if sandbox can't start | `true` |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) | `true` |
| `sandbox.excludedCommands` | Commands to run outside sandbox | `["docker *"]` |
| `sandbox.allowUnsandboxedCommands` | Allow escape hatch (default: true) | `false` |
| `sandbox.filesystem.allowWrite` | Paths sandboxed commands can write | `["/tmp/build", "~/.kube"]` |
| `sandbox.filesystem.denyWrite` | Paths sandboxed commands cannot write | `["/etc"]` |
| `sandbox.filesystem.denyRead` | Paths sandboxed commands cannot read | `["~/.aws/credentials"]` |
| `sandbox.filesystem.allowRead` | Re-allow reads within denyRead regions | `["."]` |
| `sandbox.network.allowedDomains` | Domains allowed for outbound traffic | `["github.com", "*.npmjs.org"]` |
| `sandbox.network.deniedDomains` | Domains blocked for outbound traffic | `["sensitive.example.com"]` |
| `sandbox.network.allowUnixSockets` | (macOS) Unix socket paths | `["~/.ssh/agent-socket"]` |
| `sandbox.network.allowLocalBinding` | (macOS) Allow binding to localhost ports | `true` |
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port | `8080` |
| `sandbox.network.allowManagedDomainsOnly` | (Managed) Only managed allowed domains apply | `true` |

Sandbox path prefixes: `/` = absolute, `~/` = home-relative, `./` or no prefix = project-root relative (project settings) or `~/.claude` relative (user settings).

### Managed-Only Settings

These keys are only read from managed settings; placing them in user/project settings has no effect:

`allowedChannelPlugins`, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowManagedPermissionRulesOnly`, `blockedMarketplaces`, `channelsEnabled`, `forceRemoteSettingsRefresh`, `parentSettingsBehavior`, `pluginTrustMessage`, `sandbox.filesystem.allowManagedReadPathsOnly`, `sandbox.network.allowManagedDomainsOnly`, `strictKnownMarketplaces`, `wslInheritsWindowsSettings`

### Auto Mode Configuration (autoMode settings block)

| Field | Description |
| :--- | :--- |
| `autoMode.environment` | Prose descriptions of trusted infra (repos, buckets, domains). Use `"$defaults"` to inherit built-in entries. |
| `autoMode.allow` | Prose exceptions to block rules. Use `"$defaults"` to keep built-in exceptions. |
| `autoMode.soft_deny` | Prose block rules. Use `"$defaults"` to keep built-in blocks. |

The classifier reads `autoMode` from user settings, local settings, managed settings, and `--settings` flag — NOT from shared project settings (`.claude/settings.json`).

Inspect config: `claude auto-mode defaults`, `claude auto-mode config`, `claude auto-mode critique`.

**Warning:** Omitting `"$defaults"` from any field replaces the entire built-in list for that field.

### Key Environment Variables (selected — see reference for full list)

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key (overrides subscription) |
| `ANTHROPIC_MODEL` | Model override |
| `ANTHROPIC_BASE_URL` | Override API endpoint |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `DISABLE_AUTOUPDATER=1` | Disable background auto-updates |
| `DISABLE_UPDATES=1` | Block all updates including manual |
| `DISABLE_TELEMETRY=1` | Opt out of telemetry |
| `CLAUDE_CODE_ENABLE_TELEMETRY=1` | Enable OpenTelemetry collection |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout (default: 120000) |
| `MAX_THINKING_TOKENS` | Extended thinking token budget |
| `CLAUDE_CODE_EFFORT_LEVEL` | Effort level: `low`, `medium`, `high`, `xhigh`, `max`, `auto` |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen rendering |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `DISABLE_AUTO_COMPACT=1` | Disable automatic context compaction |
| `DISABLE_COMPACT=1` | Disable all compaction |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1` | Strip credentials from subprocess environments |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY=1` | Skip writing session transcripts to disk |
| `CLAUDE_ENV_FILE` | Shell script sourced before each bash command |
| `HTTPS_PROXY` / `HTTP_PROXY` | Proxy server for network connections |

Any env var can also be set in `settings.json` under the `env` key.

### Global Config Settings (~/.claude.json, not settings.json)

| Key | Description |
| :--- | :--- |
| `autoConnectIde` | Auto-connect to IDE on startup (default: false) |
| `autoInstallIdeExtension` | Auto-install IDE extension from VS Code terminal (default: true) |
| `externalEditorContext` | Prepend last response as comments in external editor (default: false) |

### Admin Setup Decision Map

| Decision | Reference |
| :--- | :--- |
| API provider (Teams/Enterprise vs Bedrock/Vertex/Foundry) | authentication, third-party-integrations |
| Settings delivery (server-managed vs MDM vs file-based) | server-managed-settings, settings#settings-files |
| What to enforce (tools, sandbox, MCP, plugins, hooks) | permissions, sandboxing |
| Usage visibility (OTel, analytics, cost tracking) | monitoring-usage, analytics |
| Data handling (retention, ZDR, compliance) | data-usage, zero-data-retention |

Verify managed settings are active: `/status` shows source as `(remote)`, `(plist)`, `(HKLM)`, `(HKCU)`, or `(file)`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Settings](references/claude-code-settings.md) — configuration scopes, settings files, all available settings keys, permission settings, sandbox settings, attribution, file suggestion, hook configuration, and settings precedence
- [Permissions](references/claude-code-permissions.md) — permission system, modes, rule syntax (Bash, PowerShell, Read/Edit, WebFetch, MCP, Agent), working directories, sandboxing interaction, and managed-only settings
- [Permission modes](references/claude-code-permission-modes.md) — available modes, how to switch them, auto mode classifier behavior, dontAsk mode, bypassPermissions mode, and protected paths
- [Environment variables](references/claude-code-env-vars.md) — complete reference for all environment variables that control Claude Code behavior
- [Server-managed settings](references/claude-code-server-managed-settings.md) — configure centrally via Claude.ai admin console, delivery and caching behavior, fail-closed enforcement, security approval dialogs
- [Auto mode config](references/claude-code-auto-mode-config.md) — configure the classifier's trusted infrastructure, override block/allow rules, inspect effective config with CLI subcommands
- [Admin setup](references/claude-code-admin-setup.md) — organization deployment decision map: API provider, settings delivery, enforcement, usage visibility, and data handling

## Sources

- Settings: https://code.claude.com/docs/en/settings.md
- Permissions: https://code.claude.com/docs/en/permissions.md
- Permission modes: https://code.claude.com/docs/en/permission-modes.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Auto mode config: https://code.claude.com/docs/en/auto-mode-config.md
- Admin setup: https://code.claude.com/docs/en/admin-setup.md
