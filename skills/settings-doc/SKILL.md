---
name: settings-doc
description: Complete official Claude Code documentation for configuration — settings.json files and scopes, permission rules, permission modes, server-managed and MDM-deployed policies, and the full environment variable reference.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for configuring Claude Code: settings files, permissions, permission modes, managed (org-wide) settings, and environment variables.

## Quick Reference

### Settings file locations and precedence

Settings are loaded from multiple sources and merged. Higher precedence wins for scalar values; arrays (e.g. `permissions.allow`, `sandbox.filesystem.allowWrite`) are concatenated and deduplicated across all sources.

| # | Source | Path / Mechanism | Notes |
|---|---|---|---|
| 1 (highest) | Managed settings | Server-managed > MDM/OS policy > `managed-settings.json` (+ `managed-settings.d/`) > HKCU registry | One managed source only; cannot be overridden, even by CLI flags |
| 2 | CLI arguments | `--permission-mode`, `--add-dir`, etc. | Per-session overrides |
| 3 | Local project | `.claude/settings.local.json` | Personal, gitignored |
| 4 | Shared project | `.claude/settings.json` | Team-shared, checked in |
| 5 (lowest) | User | `~/.claude/settings.json` | Personal global |

Other config: `~/.claude.json` holds OAuth session, MCP user/local servers, per-project trust, and "global config" keys (`editorMode`, `autoConnectIde`, etc). Project MCP servers live in `.mcp.json`.

Managed file-based deployment paths:
- macOS: `/Library/Application Support/ClaudeCode/`
- Linux/WSL: `/etc/claude-code/`
- Windows: `C:\Program Files\ClaudeCode\` (legacy `C:\ProgramData\ClaudeCode\` removed in v2.1.75)

Run `/status` inside Claude Code to see which sources are active.

### Selected `settings.json` keys

The full list is in the reference; these are the most commonly used and recently added keys.

| Key | Purpose |
|---|---|
| `permissions` | `allow`/`ask`/`deny`/`additionalDirectories`/`defaultMode`/`disableBypassPermissionsMode`/`disableAutoMode` |
| `env` | Environment variables applied to every session |
| `hooks` | Lifecycle hook configuration (see hooks-doc) |
| `model` | Default model override (e.g. `"claude-sonnet-4-6"`) |
| `apiKeyHelper` | Shell script that prints an API key |
| `cleanupPeriodDays` | Session transcript retention (default 30; min 1) |
| `disableAllHooks` | Kill switch for all hooks and custom statusline |
| `enabledPlugins` | Map of `"plugin@marketplace": true/false` |
| `enabledMcpjsonServers` / `disabledMcpjsonServers` | Approve or reject project `.mcp.json` servers |
| `enableAllProjectMcpServers` | Auto-approve every server in project `.mcp.json` |
| `outputStyle` | Output style name (see features-doc) |
| `statusLine` | Custom status line command |
| `companyAnnouncements` | Strings shown at startup (cycled at random) |
| `attribution` | Customize git commit / PR attribution |
| `includeCoAuthoredBy` | (Deprecated; use `attribution`) |
| `includeGitInstructions` | Include built-in commit/PR instructions in system prompt |
| `language` | Preferred response language |
| `availableModels` | Restrict the `/model` picker |
| `modelOverrides` | Map model IDs to provider-specific IDs (e.g. Bedrock ARNs) |
| `effortLevel` | Persist `low`/`medium`/`high` effort |
| `autoUpdatesChannel` | `"stable"` or `"latest"` |
| `minimumVersion` | **Floor for the auto-updater**; prevents downgrades when staying on current while waiting for stable to catch up. Used with `autoUpdatesChannel` |
| `viewMode` | **Default transcript view on startup**: `"default"`, `"verbose"`, or `"focus"`. Overrides the sticky Ctrl+O selection |
| `forceLoginMethod` / `forceLoginOrgUUID` | Restrict login to Claude.ai or Console, optionally to a specific org |

Managed-only examples: `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowManagedPermissionRulesOnly`, `allowedHttpHookUrls`, `httpHookAllowedEnvVars`, `allowedMcpServers`/`deniedMcpServers`, `strictKnownMarketplaces`/`blockedMarketplaces`, `forceRemoteSettingsRefresh`, `disableAutoMode`, `pluginTrustMessage`, `channelsEnabled`, `allowedChannelPlugins`, `disableSkillShellExecution`.

### Permission rule syntax

Format: `Tool` or `Tool(specifier)`. Evaluation order: **deny -> ask -> allow** (first match wins).

| Pattern | Effect |
|---|---|
| `Bash` or `Bash(*)` | All Bash commands |
| `Bash(npm run build)` | Exact command |
| `Bash(npm run *)` | Prefix match (space matters: `ls *` not `lsof`) |
| `Bash(ls:*)` | Equivalent trailing-wildcard form (only at end) |
| `Read(./.env)` / `Read(./secrets/**)` | File path / glob |
| `WebFetch(domain:example.com)` | Domain match |
| `mcp__<server>__<tool>` | Specific MCP tool |

### Permission modes

Set via `permissions.defaultMode` in settings, `--permission-mode` CLI flag, or Shift+Tab to cycle.

| Mode | What runs without asking | When to use |
|---|---|---|
| `default` | Reads only | Sensitive work, getting started |
| `acceptEdits` | Reads + file edits + filesystem bash (`mkdir`, `touch`, `rm`, `mv`, `cp`, `sed`) inside working dir | Iterating on code you'll review later |
| `plan` | Reads only; no edits or commands | Exploring before changing |
| `auto` | Everything, with background safety classifier | Long tasks; needs opt-in via `--enable-auto-mode` |
| `dontAsk` | Only pre-approved tools (no prompts) | Locked-down CI / scripts |
| `bypassPermissions` | Everything except writes to protected paths | Containers/VMs only; requires `--dangerously-skip-permissions` |

Protected paths (always prompt or are blocked even in `bypassPermissions`): `.git`, `.claude` (except `commands/`, `agents/`, `skills/`), `.vscode`, `.idea`, `.husky`. Admins can disable risky modes with `permissions.disableBypassPermissionsMode` / `permissions.disableAutoMode` set to `"disable"`.

### Key environment variables

Auth and provider:

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | API key sent as `X-Api-Key`; overrides subscription |
| `ANTHROPIC_AUTH_TOKEN` | Custom `Authorization: Bearer ...` value |
| `ANTHROPIC_BASE_URL` | Override API endpoint (proxy/gateway) |
| `ANTHROPIC_MODEL` | Default model setting |
| `ANTHROPIC_BEDROCK_BASE_URL` / `ANTHROPIC_VERTEX_PROJECT_ID` / `ANTHROPIC_FOUNDRY_*` | Provider routing |
| `CLAUDE_CODE_USE_BEDROCK` / `CLAUDE_CODE_USE_VERTEX` | Switch provider |

Behavior toggles:

| Variable | Purpose |
|---|---|
| `CLAUDECODE` | Set to `1` in shells Claude Code spawns; detect-from-script |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Shorthand for disabling autoupdater + telemetry + error reporting + feedback |
| `DISABLE_TELEMETRY` / `CLAUDE_CODE_ENABLE_TELEMETRY` | OpenTelemetry off / on |
| `DISABLE_AUTOUPDATER` | Disable in-place updates |
| `CLAUDE_CODE_DISABLE_CLAUDE_MDS` | Skip loading any CLAUDE.md memory files |
| `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` | Strip built-in commit/PR system prompt block |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Don't write session transcripts |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Auto-compaction trigger percentage (1–100) |
| `MAX_THINKING_TOKENS` / `CLAUDE_CODE_DISABLE_THINKING` | Extended thinking budget / disable |
| `BASH_DEFAULT_TIMEOUT_MS` / `BASH_MAX_TIMEOUT_MS` / `BASH_MAX_OUTPUT_LENGTH` | Bash tool tuning |
| `API_TIMEOUT_MS` | Per-request timeout |
| `CLAUDE_PROJECT_DIR` | Set by Claude Code; project root for use inside hooks |
| `CLAUDE_PLUGIN_ROOT` / `CLAUDE_PLUGIN_DATA` | Plugin install + persistent data dirs |

### Server-managed settings

- Delivered from Anthropic's servers via the Claude.ai admin console (Team / Enterprise).
- Same JSON schema as file-based managed settings.
- Within the managed tier the precedence is: server-managed > MDM/OS-level policy > `managed-settings.d/*` + `managed-settings.json` > HKCU registry. Tiers do not merge.
- `forceRemoteSettingsRefresh: true` makes the CLI fail closed if it cannot fetch fresh policy at startup.
- Settings are cached locally and refreshed in the background; org admins can audit delivery.

## Full Documentation

For the complete official documentation, see the reference files:

- [Settings reference](references/claude-code-settings.md) — Full list of `settings.json` keys, scopes (user / project / managed), file locations on every OS, precedence rules, plugin and subagent configuration.
- [Configure permissions](references/claude-code-permissions.md) — Permission tiers, allow/ask/deny rules, rule syntax for Bash/Read/Edit/WebFetch/MCP/Agent, working directories, sandboxing interaction, managed-only settings, and auto mode classifier configuration.
- [Choose a permission mode](references/claude-code-permission-modes.md) — Detailed walkthrough of `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, and `bypassPermissions`, how to switch them in CLI/VS Code/JetBrains/Desktop/Web, and the protected-path list.
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — Setting up and delivering policies from the Claude.ai admin console: requirements, access control, fetch and caching behavior, fail-closed startup, audit logging, and platform availability.
- [Environment variables](references/claude-code-env-vars.md) — Complete reference for every environment variable that controls Claude Code behavior, grouped by feature area.

## Sources

- Settings reference: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
