---
name: settings-doc
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings: configuration scopes, all settings.json keys, permission rules, permission modes, environment variables, managed settings, server-managed settings, and auto mode configuration.

## Quick Reference

### Configuration Scopes and File Locations

| Scope | File | Who it affects | Shared? |
|:------|:-----|:--------------|:--------|
| **Managed** | `managed-settings.json`, MDM plist, or registry | All users on machine | Yes (IT-deployed) |
| **User** | `~/.claude/settings.json` | You, all projects | No |
| **Project** | `.claude/settings.json` | All collaborators | Yes (git) |
| **Local** | `.claude/settings.local.json` | You, this project | No (gitignored) |

Precedence (highest to lowest): Managed → CLI args → Local → Project → User. Array settings (like `permissions.allow`) **merge and deduplicate** across all scopes instead of overriding.

### Managed Settings Delivery Mechanisms

| Mechanism | Path | Priority | Platforms |
|:----------|:-----|:---------|:----------|
| Server-managed | Claude.ai admin console | Highest | All |
| plist / registry | macOS: `com.anthropic.claudecode` / Windows: `HKLM\SOFTWARE\Policies\ClaudeCode` | High | macOS, Windows |
| File-based | macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`; Linux/WSL: `/etc/claude-code/managed-settings.json`; Windows: `C:\Program Files\ClaudeCode\managed-settings.json` | Medium | All |
| Windows user registry | `HKCU\SOFTWARE\Policies\ClaudeCode` | Lowest | Windows only |

### Permission Modes

| Mode | What runs without asking | Best for |
|:-----|:------------------------|:---------|
| `default` | Reads only | Sensitive work, getting started |
| `acceptEdits` | Reads, file edits, common FS commands (`mkdir`, `touch`, `mv`, `cp`, `rm`, `sed`) | Iterating on code |
| `plan` | Reads only (no edits) | Exploring before changing |
| `auto` | Everything with background classifier checks | Long tasks, reducing prompts |
| `dontAsk` | Only pre-approved tools | Locked-down CI / scripts |
| `bypassPermissions` | Everything | Isolated containers/VMs only |

Switch mid-session with `Shift+Tab` (CLI), or set persistent default in settings:
```json
{ "permissions": { "defaultMode": "acceptEdits" } }
```

Auto mode requires Claude Code v2.1.83+, Opus 4.6+ or Sonnet 4.6 (Anthropic API), and admin enablement on Team/Enterprise plans. On Bedrock/Vertex/Foundry requires `CLAUDE_CODE_ENABLE_AUTO_MODE=1`.

### Permission Rule Syntax

Rules format: `Tool` or `Tool(specifier)`. Evaluation order: **deny → ask → allow** (first match wins).

| Rule example | Effect |
|:------------|:-------|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Read(./.env)` | Reading the `.env` file (project-relative) |
| `Read(~/.zshrc)` | Reading from home directory |
| `Read(//etc/passwd)` | Reading absolute path |
| `Edit(/src/**)` | Edits under project's src/ |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `Agent(Explore)` | Specific subagent |

`*` matches any sequence including spaces; space before `*` enforces word boundary. Rules evaluate compound commands per subcommand. Deny rules with bare tool name (e.g., `Bash`) remove it entirely; scoped rules (e.g., `Bash(rm *)`) block matching calls.

### Core settings.json Keys (Selected)

| Key | Description |
|:----|:------------|
| `permissions.allow/ask/deny` | Permission rules arrays |
| `permissions.defaultMode` | Starting permission mode |
| `permissions.additionalDirectories` | Extra directories for file access |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to block bypass mode |
| `env` | Environment variables for all sessions |
| `hooks` | Lifecycle event hook configuration |
| `model` | Override default model |
| `apiKeyHelper` | Script to generate auth tokens |
| `autoMode` | Auto mode classifier configuration |
| `companyAnnouncements` | Startup messages |
| `cleanupPeriodDays` | Session file retention (default: 30) |
| `language` | Claude's preferred response language |
| `outputStyle` | Adjust system prompt style |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) |
| `minimumVersion` | Floor for auto-update version pinning |
| `requiredMinimumVersion` | Hard floor — blocks startup if below |
| `requiredMaximumVersion` | Hard ceiling — blocks startup if above |
| `availableModels` | Restrict `/model` picker choices |

### Managed-Only Settings (Ignored in User/Project Scopes)

| Setting | Effect |
|:--------|:-------|
| `allowManagedPermissionRulesOnly` | Only managed `allow/ask/deny` rules apply |
| `allowManagedMcpServersOnly` | Only `allowedMcpServers` from managed settings |
| `allowManagedHooksOnly` | Only managed and SDK hooks load |
| `allowManagedPermissionRulesOnly` | Block user/project permission rules |
| `channelsEnabled` | Enable channels for org |
| `forceRemoteSettingsRefresh` | Block startup until remote settings fetched |
| `strictKnownMarketplaces` | Allowlist of plugin marketplace sources |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `strictPluginOnlyCustomization` | Block non-plugin skills/agents/hooks/MCP |
| `claudeMd` | Org-wide CLAUDE.md instructions |
| `wslInheritsWindowsSettings` | WSL reads Windows managed settings |
| `parentSettingsBehavior` | How SDK-supplied policy merges with admin tier |
| `policyHelper` | Executable to compute managed settings dynamically |
| `disableAutoMode` | Set to `"disable"` to block auto mode org-wide |
| `forceLoginMethod` | `"claudeai"` or `"console"` to restrict auth |
| `forceLoginOrgUUID` | Require login to specific org UUID(s) |

### Sandbox Settings (under `sandbox`)

| Key | Description |
|:----|:------------|
| `sandbox.enabled` | Enable OS-level sandboxing (macOS, Linux, WSL2) |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve Bash when sandboxed (default: true) |
| `sandbox.excludedCommands` | Commands to run outside sandbox |
| `sandbox.filesystem.allowWrite` | Additional writable paths |
| `sandbox.filesystem.denyRead` | Blocked read paths |
| `sandbox.network.allowedDomains` | Allowed outbound domains (supports wildcards) |
| `sandbox.network.deniedDomains` | Blocked outbound domains |

Sandbox filesystem path prefixes: `/` = absolute, `~/` = home-relative, `./` = project-relative (project settings) or `~/.claude`-relative (user settings).

### Worktree Settings (under `worktree`)

| Key | Description |
|:----|:------------|
| `worktree.baseRef` | `"fresh"` (default, from remote) or `"head"` (from local HEAD) |
| `worktree.symlinkDirectories` | Directories to symlink into worktrees |
| `worktree.sparsePaths` | Sparse-checkout directories |
| `worktree.bgIsolation` | `"worktree"` (default) or `"none"` |

### Attribution Settings (under `attribution`)

| Key | Description |
|:----|:------------|
| `attribution.commit` | Git commit attribution text (empty string = hide) |
| `attribution.pr` | PR description attribution (empty string = hide) |

### Auto Mode Configuration (`autoMode` key)

The `autoMode` settings block configures the classifier that reviews actions in auto mode. Only read from user settings, local settings, managed settings, and `--settings` flag — never from shared project settings.

| Field | Description |
|:------|:------------|
| `environment` | Prose descriptions of trusted repos, buckets, and domains |
| `allow` | Exceptions to soft block rules |
| `soft_deny` | Destructive patterns user intent can override |
| `hard_deny` | Unconditional security boundaries |

Include `"$defaults"` in any array to inherit the built-in rules at that position. Omitting it replaces the entire default list for that section.

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp and all repos under it"
    ]
  }
}
```

CLI subcommands: `claude auto-mode defaults` (print built-ins), `claude auto-mode config` (print effective config), `claude auto-mode critique` (AI review of custom rules).

### Key Environment Variables (Selected)

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key for Anthropic API authentication |
| `ANTHROPIC_MODEL` | Override default model |
| `ANTHROPIC_BASE_URL` | Route requests through proxy or gateway |
| `CLAUDE_CODE_USE_BEDROCK` / `_VERTEX` / `_FOUNDRY` | Use alternative API provider |
| `CLAUDE_CODE_ENABLE_AUTO_MODE` | Enable auto mode on Bedrock/Vertex/Foundry |
| `CLAUDE_CODE_DISABLE_THINKING` | Force-disable extended thinking |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level (`low`/`medium`/`high`/`xhigh`/`max`) |
| `CLAUDE_CODE_MAX_TURNS` | Cap agentic turns |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry data collection |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable autoupdater, telemetry, error reporting |
| `DISABLE_AUTOUPDATER` | Disable background auto-updates |
| `DISABLE_TELEMETRY` / `DO_NOT_TRACK` | Opt out of telemetry |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout (default: 120000) |
| `API_TIMEOUT_MS` | API request timeout (default: 600000) |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude` config directory |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess environments |
| `CLAUDE_CODE_OAUTH_TOKEN` | OAuth token for automated authentication |
| `HTTP_PROXY` / `HTTPS_PROXY` | Network proxy settings |

Environment variables take precedence over `settings.json` fields with the same behavior. Variables set in `settings.json` under the `env` key apply every time `claude` runs across all settings scopes.

### Server-Managed Settings (Claude.ai Admin Console)

Available on Teams and Enterprise plans only. Settings delivered at authentication time and refreshed hourly. Not available on Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`.

Configure at: **Claude.ai > Admin Settings > Claude Code > Managed settings**

Key behaviors:
- Takes highest precedence; cannot be overridden by user/project settings
- Requires explicit user approval for shell commands, custom env vars, and hooks
- Falls back to cached settings on network failure (unless `forceRemoteSettingsRefresh: true`)
- `managed-mcp.json` files cannot be distributed via server-managed settings; use `allowedMcpServers`/`deniedMcpServers` instead

### Verify Active Settings

Run `/status` inside Claude Code. The Status tab shows a `Setting sources` line listing active layers. A managed settings entry shows the delivery channel in parentheses: `(remote)`, `(plist)`, `(HKLM)`, `(HKCU)`, or `(file)`.

### Inline Shell Execution in Skills (Security Note)

The `disableSkillShellExecution` setting (managed only) disables inline shell execution tokens in skill files: an exclamation mark followed by a backtick-wrapped command, or a fenced code block fence followed by an exclamation mark. When set to `true`, those tokens are replaced with `[shell command execution disabled by policy]` for user/project/plugin skills.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — All settings.json keys, scope system, permission rules, sandbox, worktree, attribution, precedence
- [Admin setup](references/claude-code-admin-setup.md) — Organization deployment decision map: API providers, managed settings delivery, enforcement controls, usage visibility, data handling
- [Configure permissions](references/claude-code-permissions.md) — Permission rules syntax, tool-specific rules, managed-only settings, working directories, hooks integration
- [Server-managed settings](references/claude-code-server-managed-settings.md) — Claude.ai admin console delivery, security dialogs, caching behavior, fail-closed enforcement
- [Environment variables](references/claude-code-env-vars.md) — Full reference for all environment variables controlling Claude Code behavior
- [Permission modes](references/claude-code-permission-modes.md) — All six modes, switching methods, auto mode requirements, protected paths
- [Configure auto mode](references/claude-code-auto-mode-config.md) — autoMode.environment/allow/soft_deny/hard_deny, CLI subcommands, reviewing denials

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Admin setup: https://code.claude.com/docs/en/admin-setup.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Permission modes: https://code.claude.com/docs/en/permission-modes.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
