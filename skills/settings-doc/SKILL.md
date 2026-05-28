---
name: settings-doc
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, environment variables, permission modes, admin setup, server-managed settings, and auto mode configuration.

## Quick Reference

### Configuration Scopes

| Scope | File | Shared? | Priority |
|:------|:-----|:--------|:---------|
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | Yes (IT-deployed) | 1 (highest) |
| **Command line** | `--settings <file-or-json>` | No | 2 |
| **Local** | `.claude/settings.local.json` | No (gitignored) | 3 |
| **Project** | `.claude/settings.json` | Yes (git) | 4 |
| **User** | `~/.claude/settings.json` | No | 5 (lowest) |

Array-valued settings (e.g., `permissions.allow`, `sandbox.filesystem.allowWrite`) **merge across all scopes** — they concatenate and deduplicate rather than override.

### Managed Settings Delivery Mechanisms

| Mechanism | Location | Platform |
|:----------|:---------|:---------|
| Server-managed | Claude.ai admin console | All (Teams/Enterprise) |
| plist | `com.anthropic.claudecode` managed preferences domain | macOS |
| Registry (HKLM) | `HKLM\SOFTWARE\Policies\ClaudeCode` | Windows |
| Registry (HKCU) | `HKCU\SOFTWARE\Policies\ClaudeCode` | Windows (lowest priority) |
| File-based | `/Library/Application Support/ClaudeCode/managed-settings.json` (macOS) | macOS |
| File-based | `/etc/claude-code/managed-settings.json` (Linux/WSL) | Linux/WSL |
| File-based | `C:\Program Files\ClaudeCode\managed-settings.json` (Windows) | Windows |

Drop-in directory: `managed-settings.d/*.json` alongside `managed-settings.json`; files merged alphabetically on top of base.

### Key settings.json Fields (Selected)

| Key | Description | Example |
|:----|:------------|:--------|
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `permissions` | Allow/deny/ask rules + defaultMode | See permissions table |
| `env` | Environment variables for every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle hook definitions | See hooks-doc |
| `autoMode` | Auto mode classifier configuration | `{"environment": ["$defaults", "..."]}` |
| `apiKeyHelper` | Script to generate API key dynamically | `"/bin/gen_key.sh"` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) | `"stable"` |
| `availableModels` | Restrict `/model` picker | `["sonnet", "haiku"]` |
| `cleanupPeriodDays` | Session file retention (default: 30) | `20` |
| `companyAnnouncements` | Messages shown at startup | `["Welcome!"]` |
| `defaultShell` | `"bash"` (default) or `"powershell"` | `"powershell"` |
| `disableAllHooks` | Disable all hooks | `true` |
| `editorMode` | `"normal"` or `"vim"` | `"vim"` |
| `effortLevel` | Persist effort: `low`/`medium`/`high`/`xhigh` | `"xhigh"` |
| `enableAllProjectMcpServers` | Auto-approve all `.mcp.json` servers | `true` |
| `language` | Claude response language | `"japanese"` |
| `minimumVersion` | Floor for auto-update | `"2.1.100"` |
| `outputStyle` | System-prompt output style | `"Explanatory"` |
| `sandbox` | Sandboxing configuration | See sandbox table |
| `tui` | `"fullscreen"` or `"default"` renderer | `"fullscreen"` |
| `worktree.*` | Worktree creation settings | See worktree table |

### Permission Settings

| Key | Description |
|:----|:------------|
| `permissions.allow` | Array of tool rules to allow without prompting |
| `permissions.deny` | Array of tool rules to always block |
| `permissions.ask` | Array of tool rules to always prompt for |
| `permissions.additionalDirectories` | Extra directories for file access |
| `permissions.defaultMode` | Default permission mode at startup |
| `permissions.disableBypassPermissionsMode` | Set `"disable"` to prevent bypass mode |
| `permissions.skipDangerousModePermissionPrompt` | Skip bypass mode confirmation |

### Permission Rule Syntax

Format: `Tool` or `Tool(specifier)`

| Rule | Effect |
|:-----|:-------|
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Bash(git * main)` | e.g., `git checkout main`, `git push origin main` |
| `Read(./.env)` | Reading `.env` in project root |
| `Read(~/.zshrc)` | Reading home-dir file |
| `Read(//etc/secrets/**)` | Absolute path (double-slash prefix) |
| `Edit(/src/**/*.ts)` | Project-relative edit rule |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `Agent(Explore)` | Specific subagent |

**Evaluation order:** deny → ask → allow. First match wins. Deny rules that use bare tool name (e.g., `Bash`) remove the tool from Claude's context entirely.

### Permission Modes

| Mode | What runs without asking | Best for |
|:-----|:------------------------|:---------|
| `default` | Reads only | Standard use |
| `acceptEdits` | Reads, file edits, common filesystem commands | Code iteration |
| `plan` | Reads only (no edits) | Exploring before changing |
| `auto` | Everything with background safety checks | Long tasks (Anthropic API only) |
| `dontAsk` | Only pre-approved tools | CI/locked-down scripts |
| `bypassPermissions` | Everything (circuit-breaker for `rm -rf /` only) | Isolated containers/VMs only |

Set via `permissions.defaultMode` in settings, `--permission-mode` flag, or `Shift+Tab` in CLI. `auto` and `bypassPermissions` require explicit enablement.

### Managed-Only Settings (ignored outside managed scope)

| Setting | Description |
|:--------|:------------|
| `allowAllClaudeAiMcps` | Load claude.ai connectors alongside managed-mcp.json |
| `allowedChannelPlugins` | Allowlist for channel plugin messages |
| `allowManagedHooksOnly` | Block all non-managed hooks |
| `allowManagedMcpServersOnly` | Only managed-settings MCP servers allowed |
| `allowManagedPermissionRulesOnly` | Prevent user/project permission rules |
| `blockedMarketplaces` | Block marketplace sources |
| `channelsEnabled` | Allow/block channels for org |
| `claudeMd` | Org-wide CLAUDE.md instructions |
| `forceRemoteSettingsRefresh` | Block startup until server settings fetched |
| `parentSettingsBehavior` | `"first-wins"` or `"merge"` for SDK-supplied policy |
| `policyHelper` | Admin executable for dynamic managed settings |
| `strictKnownMarketplaces` | Allowlist of permitted marketplace sources |
| `strictPluginOnlyCustomization` | Lock skills/agents/hooks/mcp to plugins only |
| `wslInheritsWindowsSettings` | WSL reads Windows policy chain |

### Sandbox Settings (`sandbox.*`)

| Key | Description |
|:----|:------------|
| `sandbox.enabled` | Enable OS-level sandboxing (default: false) |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `sandbox.excludedCommands` | Commands that bypass the sandbox |
| `sandbox.filesystem.allowWrite` | Additional writable paths |
| `sandbox.filesystem.denyWrite` | Blocked write paths |
| `sandbox.filesystem.denyRead` | Blocked read paths |
| `sandbox.filesystem.allowRead` | Re-allowed read paths (overrides denyRead) |
| `sandbox.network.allowedDomains` | Allowed outbound domains (wildcards supported) |
| `sandbox.network.deniedDomains` | Blocked outbound domains |
| `sandbox.network.allowLocalBinding` | Allow localhost port binding (macOS) |
| `sandbox.failIfUnavailable` | Exit if sandbox can't start |

### Worktree Settings (`worktree.*`)

| Key | Description | Default |
|:----|:------------|:--------|
| `worktree.baseRef` | `"fresh"` (branch from remote default) or `"head"` | `"fresh"` |
| `worktree.symlinkDirectories` | Dirs to symlink into each worktree | none |
| `worktree.sparsePaths` | Dirs for sparse-checkout in worktrees | none |
| `worktree.bgIsolation` | `"worktree"` or `"none"` for bg session isolation | `"worktree"` |

### Auto Mode Configuration (`autoMode.*`)

The `autoMode` settings block tells the classifier which infrastructure is trusted. Not read from shared project settings (`.claude/settings.json`).

| Key | Description |
|:----|:------------|
| `autoMode.environment` | Prose list of trusted repos, buckets, domains. Include `"$defaults"` to extend built-ins |
| `autoMode.allow` | Exceptions to soft-deny rules. Include `"$defaults"` to keep built-ins |
| `autoMode.soft_deny` | Destructive actions blocked unless explicit user intent. Include `"$defaults"` |
| `autoMode.hard_deny` | Unconditional blocks; no user intent or allow override. Include `"$defaults"` |

Inspect config: `claude auto-mode defaults` | `claude auto-mode config` | `claude auto-mode critique`

### Key Environment Variables (Selected)

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key for authentication |
| `ANTHROPIC_MODEL` | Override model |
| `ANTHROPIC_BASE_URL` | Route through proxy/gateway |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `CLAUDECODE` | Set to `1` in subprocesses spawned by Claude Code |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_DISABLE_THINKING` | Force-disable extended thinking |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort: `low`/`medium`/`high`/`xhigh`/`max` |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry (`1`) |
| `CLAUDE_CODE_MAX_TURNS` | Cap agentic turns |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen renderer |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocesses |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Maximum bash timeout (default: 600000) |
| `API_TIMEOUT_MS` | API request timeout (default: 600000) |
| `DISABLE_AUTOUPDATER` | Disable auto-updates |
| `DISABLE_TELEMETRY` | Opt out of telemetry |
| `DO_NOT_TRACK` | Cross-tool telemetry opt-out |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget |
| `MCP_TIMEOUT` | MCP server startup timeout (default: 30000) |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server for network connections |

### Server-Managed Settings

Delivered from the Claude.ai admin console (Teams/Enterprise only). Requirements: Claude Code v2.1.38+ (Teams) or v2.1.30+ (Enterprise), network access to `api.anthropic.com`.

- Settings fetch at startup and poll hourly during active sessions
- Cached settings apply on subsequent launches; fresh fetch in background
- `forceRemoteSettingsRefresh: true` causes CLI to exit if fetch fails
- Security approval dialogs shown for hooks, env vars, and shell commands
- Not available on Bedrock, Vertex AI, Foundry, or custom `ANTHROPIC_BASE_URL`

### Verify Active Settings

Run `/status` inside Claude Code. The `Setting sources` line lists active layers. Managed settings show delivery channel, e.g., `Enterprise managed settings (remote)`, `(plist)`, `(HKLM)`, `(file)`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) — Full settings reference: scopes, all available keys, permission rules, sandbox, worktree, attribution, and plugin configuration
- [Admin Setup Guide](references/claude-code-admin-setup.md) — Deployment decision map for administrators: API providers, settings delivery, enforcement, monitoring, and data handling
- [Configure Permissions](references/claude-code-permissions.md) — Permission system, rule syntax (Bash, Read/Edit, WebFetch, MCP, Agent), tool-specific patterns, managed-only settings, and working directories
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) — Server delivery configuration, caching behavior, fail-closed enforcement, and security considerations
- [Environment Variables](references/claude-code-env-vars.md) — Complete reference for all environment variables controlling Claude Code behavior
- [Permission Modes](references/claude-code-permission-modes.md) — All permission modes, how to switch them, auto mode requirements, and protected paths
- [Configure Auto Mode](references/claude-code-auto-mode-config.md) — autoMode settings block, trusted infrastructure definition, override rules, and CLI inspection commands

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Admin Setup Guide: https://code.claude.com/docs/en/admin-setup.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment Variables: https://code.claude.com/docs/en/env-vars.md
- Permission Modes: https://code.claude.com/docs/en/permission-modes.md
- Configure Auto Mode: https://code.claude.com/docs/en/auto-mode-config.md
