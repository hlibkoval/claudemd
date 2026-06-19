---
name: settings-doc
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, environment variables, permission modes, server-managed settings, admin setup, and auto mode configuration.

## Quick Reference

### Configuration Scopes

| Scope | Location | Shared with team? | Priority |
| :--- | :--- | :--- | :--- |
| **Managed** | Server, plist/registry, or `managed-settings.json` | Yes (IT-deployed) | Highest |
| **Local** | `.claude/settings.local.json` | No | 3rd |
| **Project** | `.claude/settings.json` | Yes (git) | 4th |
| **User** | `~/.claude/settings.json` | No | Lowest |

Priority order: Managed > CLI args > Local > Project > User. Array settings (like `permissions.allow`) concatenate across scopes rather than override.

### Settings File Locations

| File | Applies to |
| :--- | :--- |
| `~/.claude/settings.json` | You, all projects |
| `.claude/settings.json` | Whole team, this project |
| `.claude/settings.local.json` | You, this project only (gitignored) |
| `managed-settings.json` | Org-wide (admin-deployed) |

Managed file paths: macOS `/Library/Application Support/ClaudeCode/`, Linux/WSL `/etc/claude-code/`, Windows `C:\Program Files\ClaudeCode\`.

### Key settings.json Fields

| Key | Description | Example |
| :--- | :--- | :--- |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `permissions` | Allow/ask/deny rules + defaultMode | see below |
| `env` | Environment variables for every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle hook definitions | see hooks-doc |
| `theme` | UI color theme | `"dark"`, `"light"` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` | `"stable"` |
| `autoCompactEnabled` | Auto-compact at context limit | `true` |
| `fileCheckpointingEnabled` | Enable `/rewind` checkpoints | `true` |
| `verbose` | Show full tool output | `false` |
| `editorMode` | `"normal"` or `"vim"` | `"vim"` |
| `effortLevel` | Persist effort level | `"xhigh"` |
| `language` | Claude's response language | `"japanese"` |
| `tui` | Renderer: `"fullscreen"` or `"default"` | `"fullscreen"` |
| `apiKeyHelper` | Script to generate auth value | `"/bin/gen-key.sh"` |
| `cleanupPeriodDays` | Days before session file deletion (default 30) | `20` |
| `statusLine` | Custom status line config | `{"type":"command","command":"~/.claude/statusline.sh"}` |
| `outputStyle` | Output style for system prompt | `"Explanatory"` |
| `attribution` | Git commit and PR attribution | `{"commit":"...","pr":""}` |
| `agent` | Run session as named subagent | `"code-reviewer"` |
| `fallbackModel` | Fallback model chain on overload | `["claude-sonnet-4-6","claude-haiku-4-5"]` |
| `availableModels` | Restrict selectable models | `["sonnet","haiku"]` |
| `minimumVersion` | Floor for auto-updates | `"2.1.100"` |
| `requiredMinimumVersion` | Hard floor — blocks startup if below | `"2.1.150"` |
| `requiredMaximumVersion` | Hard ceiling — blocks startup if above | `"2.1.150"` |
| `disableAutoMode` | Set `"disable"` to block auto mode | `"disable"` |
| `disableAllHooks` | Disable all hooks | `true` |
| `companyAnnouncements` | Startup messages for users | `["Welcome!"]` |
| `claudeMd` | Org-wide CLAUDE.md (managed only) | `"Always run make lint."` |
| `forceLoginMethod` | `"claudeai"` or `"console"` | `"claudeai"` |
| `forceLoginOrgUUID` | Require specific org UUID | `"xxxx-..."` |
| `autoMode` | Auto mode classifier config | see auto mode section |
| `sandbox` | OS-level sandbox settings | see sandbox section |

### Permission Settings

```json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Read(~/.zshrc)"],
    "ask":   ["Bash(git push *)"],
    "deny":  ["Bash(curl *)", "Read(./.env)"],
    "defaultMode": "acceptEdits",
    "additionalDirectories": ["../docs/"],
    "disableBypassPermissionsMode": "disable"
  }
}
```

### Permission Rule Syntax

| Rule | Effect |
| :--- | :--- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Read(./.env)` | Reading the `.env` file |
| `WebFetch(domain:example.com)` | Fetches to example.com |
| `Agent(Explore)` | Invocations of the Explore subagent |
| `mcp__github__get_*` | All `get_` tools from the github MCP server |
| `*` | Every tool (deny/ask only) |

Deny rules evaluated first, then ask, then allow. A broad deny cannot be overridden by a narrower allow.

### Permission Modes

| Mode | What runs without prompting | Best for |
| :--- | :--- | :--- |
| `default` | Reads only | Sensitive work |
| `acceptEdits` | Reads + file edits + common filesystem commands | Code iteration |
| `plan` | Reads only (Claude won't edit) | Exploration |
| `auto` | Everything, with background classifier | Long tasks |
| `dontAsk` | Only pre-approved tools | CI/scripts |
| `bypassPermissions` | Everything (no safety checks) | Containers/VMs only |

Set default: `"permissions": {"defaultMode": "acceptEdits"}`. Switch mid-session with `Shift+Tab` (CLI) or the mode selector (VS Code/Desktop/Web).

Auto mode requirements: all plans; admin must enable on Team/Enterprise; Opus 4.6+ or Sonnet 4.6 on Anthropic API; Opus 4.7+ on Bedrock/Vertex/Foundry with `CLAUDE_CODE_ENABLE_AUTO_MODE=1`.

### Sandbox Settings

| Key | Description |
| :--- | :--- |
| `sandbox.enabled` | Enable OS-level bash sandboxing |
| `sandbox.filesystem.allowWrite` | Paths bash can write |
| `sandbox.filesystem.denyRead` | Paths bash cannot read |
| `sandbox.network.allowedDomains` | Outbound domain allowlist |
| `sandbox.network.deniedDomains` | Outbound domain blocklist |
| `sandbox.excludedCommands` | Commands that run unsandboxed |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |

### Worktree Settings

| Key | Description |
| :--- | :--- |
| `worktree.baseRef` | `"fresh"` (default) or `"head"` |
| `worktree.symlinkDirectories` | Dirs to symlink into worktrees |
| `worktree.sparsePaths` | Sparse-checkout paths for worktrees |
| `worktree.bgIsolation` | `"worktree"` (default) or `"none"` |

### Managed-Only Settings

Only read from managed settings; ignored in user/project files:

`allowAllClaudeAiMcps`, `allowedChannelPlugins`, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowManagedPermissionRulesOnly`, `blockedMarketplaces`, `channelsEnabled`, `forceRemoteSettingsRefresh`, `pluginTrustMessage`, `sandbox.filesystem.allowManagedReadPathsOnly`, `sandbox.network.allowManagedDomainsOnly`, `strictKnownMarketplaces`, `strictPluginOnlyCustomization`, `wslInheritsWindowsSettings`

### Plugin Settings

```json
{
  "enabledPlugins": {
    "formatter@acme-tools": true,
    "analyzer@security-plugins": false
  },
  "extraKnownMarketplaces": {
    "acme-tools": {
      "source": { "source": "github", "repo": "acme-corp/claude-plugins" }
    }
  }
}
```

### Managed Settings Delivery

| Mechanism | Delivery | Priority | Platforms |
| :--- | :--- | :--- | :--- |
| Server-managed | Claude.ai admin console | Highest | All |
| plist / registry | macOS plist, Windows HKLM | High | macOS, Windows |
| File-based | `managed-settings.json` at system path | Medium | All |
| Windows user registry | HKCU | Lowest | Windows only |

Server-managed settings require Teams/Enterprise plan and network access to `api.anthropic.com`. Set `forceRemoteSettingsRefresh: true` to block startup when the fetch fails.

### Auto Mode Configuration (autoMode)

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp",
      "Trusted domains: *.corp.example.com",
      "Trusted buckets: s3://acme-build-artifacts"
    ],
    "allow": ["$defaults", "Deploying to staging namespace is allowed"],
    "soft_deny": ["$defaults", "Never run database migrations outside migrations CLI"],
    "hard_deny": ["$defaults", "Never send repo contents to third-party APIs"]
  }
}
```

Include `"$defaults"` to inherit built-in rules. Omitting it replaces the entire list. Precedence: `hard_deny` > `soft_deny` > `allow` > explicit user intent overrides soft blocks. The classifier does not read `autoMode` from shared project settings (`.claude/settings.json`).

CLI subcommands: `claude auto-mode defaults`, `claude auto-mode config`, `claude auto-mode critique`.

### Key Environment Variables

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key for direct API access |
| `ANTHROPIC_MODEL` | Override model for session |
| `ANTHROPIC_BASE_URL` | Route requests through proxy/gateway |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_ENABLE_AUTO_MODE` | Enable auto mode on Bedrock/Vertex/Foundry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry export |
| `MAX_THINKING_TOKENS` | Override extended thinking budget |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_DISABLE_WORKFLOWS` | Disable dynamic workflows |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout (default: 600000) |
| `API_TIMEOUT_MS` | API request timeout (default: 600000) |
| `DISABLE_AUTOUPDATER` | Disable background auto-updates |
| `DISABLE_TELEMETRY` | Opt out of telemetry |
| `DO_NOT_TRACK` | Opt out of telemetry (cross-tool convention) |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level (low/medium/high/xhigh/max) |
| `CLAUDE_CODE_DISABLE_BUNDLED_SKILLS` | Disable bundled skills and workflows |
| `CLAUDE_CONFIG_DIR` | Override config dir (default: `~/.claude`) |
| `CLAUDECODE` | Set to `1` in Claude-spawned subprocesses |
| `CLAUDE_CODE_CHILD_SESSION` | Set to `1` in directly spawned tool subprocesses |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen (alt-screen) renderer |
| `DISABLE_AUTO_COMPACT` | Disable auto-compaction |

Variables set in the shell take precedence over the same behavior configured via `settings.json`.

### Verify Settings

- `/status` → Settings tab shows active setting sources and delivery channel
- `/permissions` → View and manage all permission rules
- `claude doctor` → Diagnose invalid settings entries
- `/doctor` → Same as above, in-session

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — Complete settings reference: scopes, all available keys, sandbox, permissions, plugin, and attribution settings
- [Admin setup](references/claude-code-admin-setup.md) — Deployment decision guide for organizations: API providers, managed settings delivery, enforcement controls, monitoring
- [Configure permissions](references/claude-code-permissions.md) — Permission system, rule syntax, tool-specific patterns, managed-only settings, working directories
- [Server-managed settings](references/claude-code-server-managed-settings.md) — Deliver managed policy from the Claude.ai admin console without MDM
- [Environment variables](references/claude-code-env-vars.md) — Full reference for all environment variables that control Claude Code behavior
- [Choose a permission mode](references/claude-code-permission-modes.md) — All six modes, switching controls, auto mode details, protected paths
- [Configure auto mode](references/claude-code-auto-mode-config.md) — Define trusted infrastructure, override classifier rules, inspect effective config

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Admin setup: https://code.claude.com/docs/en/admin-setup.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
