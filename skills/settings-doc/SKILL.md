---
name: settings-doc
description: Complete official documentation for Claude Code settings and permissions — configuration scopes (user/project/local/managed), all settings.json keys, permission rules and modes, environment variables, server-managed settings, auto mode configuration, sandbox settings, admin deployment decisions, and settings precedence.
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code configuration, permissions, and deployment settings.

## Quick Reference

### Configuration Scopes and File Locations

| Scope | Location | Shared? | Who it affects |
| :--- | :--- | :--- | :--- |
| **Managed** | Server, MDM/plist, registry, or `managed-settings.json` | Yes (IT-deployed) | All users on device |
| **User** | `~/.claude/settings.json` | No | You, all projects |
| **Project** | `.claude/settings.json` | Yes (git) | All collaborators |
| **Local** | `.claude/settings.local.json` | No | You, this project only |

**Precedence** (highest → lowest): Managed → Command-line args → Local → Project → User

Array settings (e.g. `permissions.allow`, `sandbox.filesystem.allowWrite`) **merge and deduplicate** across all scopes rather than override.

### Managed Settings Delivery Mechanisms

| Mechanism | Location | Platform |
| :--- | :--- | :--- |
| Server-managed | Claude.ai admin console | All |
| plist | `com.anthropic.claudecode` | macOS |
| Registry (HKLM) | `HKLM\SOFTWARE\Policies\ClaudeCode` | Windows |
| File-based | macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`; Linux/WSL: `/etc/claude-code/managed-settings.json`; Windows: `C:\Program Files\ClaudeCode\managed-settings.json` | All |
| Registry (HKCU) | `HKCU\SOFTWARE\Policies\ClaudeCode` | Windows (lowest priority) |

Drop-in directory `managed-settings.d/` is merged alongside the base `managed-settings.json` (alphabetical order, later overrides earlier for scalars, arrays concatenated).

### Permission Modes

| Mode | What runs without asking | Best for |
| :--- | :--- | :--- |
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands | Iterating on code |
| `plan` | Reads only (no edits) | Exploring before changing |
| `auto` | Everything, with background safety checks | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down CI/scripts |
| `bypassPermissions` | Everything | Isolated containers/VMs only |

Set via `permissions.defaultMode` in settings, `--permission-mode` flag, or `Shift+Tab` in the CLI. As of v2.1.142, `auto` is ignored when set in project or local settings.

### Permission Rule Syntax

Rules follow `Tool` or `Tool(specifier)` format. Evaluation order: **deny → ask → allow** (first match wins).

| Rule | Effect |
| :--- | :--- |
| `Bash` | All bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Bash(git * main)` | Git commands referencing `main` |
| `Read(./.env)` | Reading `.env` in current dir |
| `Read(//**/.env)` | Any `.env` anywhere on filesystem |
| `Edit(/src/**)` | Edits under project `src/` |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer__puppeteer_navigate` | A specific MCP tool |
| `Agent(my-agent)` | A named subagent |

Read/Edit path pattern anchors: `//path` = absolute; `~/path` = home-relative; `/path` = project-root-relative; `path` or `./path` = cwd-relative.

### Minimal settings.json Example

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": ["Bash(npm run lint)", "Bash(npm run test *)"],
    "deny": ["Bash(curl *)", "Read(./.env)", "Read(./secrets/**)"]
  },
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1"
  }
}
```

### Key settings.json Options (Selected)

| Key | Description | Example |
| :--- | :--- | :--- |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `permissions.defaultMode` | Default permission mode | `"acceptEdits"` |
| `permissions.allow/ask/deny` | Permission rule arrays | `["Bash(git *)"]` |
| `permissions.additionalDirectories` | Extra working dirs for file access | `["../docs/"]` |
| `permissions.disableBypassPermissionsMode` | Prevent bypass mode | `"disable"` |
| `env` | Session environment variables | `{"FOO": "bar"}` |
| `hooks` | Lifecycle hook commands | see hooks-doc |
| `autoMemoryEnabled` | Enable/disable auto memory | `false` |
| `apiKeyHelper` | Script to generate auth value | `"/bin/gen_key.sh"` |
| `sandbox.enabled` | Enable bash sandboxing | `true` |
| `sandbox.network.allowedDomains` | Allowed outbound domains | `["github.com"]` |
| `minimumVersion` | Org-wide minimum CLI version | `"2.1.100"` |
| `allowManagedPermissionRulesOnly` | Block user/project allow/deny rules | `true` (managed only) |
| `allowManagedHooksOnly` | Block non-managed hooks | `true` (managed only) |
| `forceLoginOrgUUID` | Require specific org at login | `"uuid-here"` |
| `companyAnnouncements` | Startup messages for users | `["Welcome!"]` |
| `claudeMd` | Org-wide CLAUDE.md content | `"Always lint."` (managed only) |
| `language` | Claude's response language | `"japanese"` |
| `tui` | Terminal UI renderer | `"fullscreen"` |
| `editorMode` | Input key bindings | `"vim"` |
| `effortLevel` | Thinking effort across sessions | `"xhigh"` |
| `autoMode` | Auto mode classifier config | `{"environment": [...]}` |
| `worktree.baseRef` | Worktree branch base | `"head"` |
| `attribution.commit` | Git commit attribution text | `""` (to hide) |
| `skillOverrides` | Per-skill visibility overrides | `{"foo": "off"}` |
| `policyHelper` | Dynamic managed settings script | `{"path": "/usr/local/bin/..."}` |
| `parentSettingsBehavior` | SDK managed settings merge mode | `"merge"` |

### Global Config Settings (~/.claude.json, NOT settings.json)

| Key | Description |
| :--- | :--- |
| `autoConnectIde` | Auto-connect to IDE on startup |
| `autoInstallIdeExtension` | Auto-install VS Code extension |
| `externalEditorContext` | Show last response when opening external editor |
| `teammateDefaultModel` | Default model for agent teammates |

### Sandbox Settings (under `sandbox`)

| Key | Description |
| :--- | :--- |
| `enabled` | Enable bash sandboxing (macOS, Linux, WSL2) |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `excludedCommands` | Commands that run outside the sandbox |
| `filesystem.allowWrite` | Additional write-allowed paths |
| `filesystem.denyRead` | Paths to block reads |
| `network.allowedDomains` | Allowed outbound domains (supports wildcards) |
| `network.deniedDomains` | Blocked domains (takes precedence over allowed) |
| `network.allowManagedDomainsOnly` | Only managed allowedDomains apply (managed only) |
| `bwrapPath` | Custom bwrap binary path (managed only, Linux/WSL2) |

Sandbox path prefixes: `/` = absolute, `~/` = home, `./` or no prefix = project-root (in project settings) or `~/.claude` (in user settings).

### Worktree Settings (under `worktree`)

| Key | Values | Description |
| :--- | :--- | :--- |
| `baseRef` | `"fresh"` (default), `"head"` | Branch origin for new worktrees |
| `symlinkDirectories` | array of dirs | Symlink from main repo to save disk space |
| `sparsePaths` | array of paths | Sparse-checkout dirs in worktrees |
| `bgIsolation` | `"worktree"` (default), `"none"` | Background session isolation mode (v2.1.143+) |

### Managed-Only Settings

These keys are **ignored** if placed in user, project, or local settings:

`allowedChannelPlugins`, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowManagedPermissionRulesOnly`, `blockedMarketplaces`, `channelsEnabled`, `claudeMd`, `forceRemoteSettingsRefresh`, `pluginTrustMessage`, `sandbox.filesystem.allowManagedReadPathsOnly`, `sandbox.network.allowManagedDomainsOnly`, `strictKnownMarketplaces`, `wslInheritsWindowsSettings`, `parentSettingsBehavior`, `policyHelper`

### Auto Mode Configuration (`autoMode` block)

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp",
      "Cloud storage: s3://acme-build-artifacts"
    ],
    "soft_deny": ["$defaults", "Never run terraform apply"],
    "hard_deny": [],
    "allow": []
  }
}
```

- `environment`: trusted repos, buckets, domains (classifier uses this to define "external")
- `soft_deny`: prose rules for risky-but-overridable actions
- `hard_deny`: prose rules the classifier always blocks
- `allow`: exceptions to soft_deny rules
- Include `"$defaults"` to inherit built-in rules at that position
- `autoMode` is NOT read from shared project settings (`.claude/settings.json`)

### Environment Variables (Selected)

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key (overrides subscription when set) |
| `ANTHROPIC_MODEL` | Default model |
| `ANTHROPIC_BASE_URL` | Override API endpoint |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout (default: 600000) |
| `CLAUDE_CODE_DISABLE_THINKING` | Force-disable extended thinking |
| `CLAUDE_CODE_EFFORT_LEVEL` | Effort level (`low`/`medium`/`high`/`xhigh`) |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_NO_FLICKER` | Use fullscreen alt-screen renderer |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable telemetry, autoupdater, error reporting |
| `DISABLE_AUTOUPDATER` | Disable auto-updates |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OTEL telemetry |
| `OTEL_METRICS_EXPORTER` | OTEL exporter type |
| `MAX_THINKING_TOKENS` | Thinking token budget |
| `CLAUDECODE` | Set to `1` in shells Claude spawns |

Any env var can also be set in `settings.json` under the `env` key for persistent/team-wide application.

### Server-Managed Settings Setup

Requirements: Claude for Teams or Enterprise plan, Claude Code v2.1.38+ (Teams) or v2.1.30+ (Enterprise), network access to `api.anthropic.com`.

1. Go to Claude.ai → **Admin Settings > Claude Code > Managed settings**
2. Enter JSON (same format as `settings.json`)
3. Settings are delivered at authentication time and refreshed hourly

Use `forceRemoteSettingsRefresh: true` to block startup until remote settings load (fail-closed).

### Verifying Active Settings

Run `/status` inside Claude Code. The **Setting sources** line lists each loaded layer. If managed settings are active, the entry shows the delivery channel, e.g. `Enterprise managed settings (remote)`, `(plist)`, `(HKLM)`, or `(file)`.

### Excluding Sensitive Files

```json
{
  "permissions": {
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Read(./config/credentials.json)"
    ]
  }
}
```

### Plugin Settings in settings.json

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

`strictKnownMarketplaces` (managed only) allowlists marketplace sources; an empty array locks down all marketplace additions.

## Full Documentation

For the complete official documentation, see the reference files:

- [Settings](references/claude-code-settings.md) — Full settings.json reference: all keys, scopes, sandbox, worktree, permission, attribution, file suggestion, and hook configuration
- [Permissions](references/claude-code-permissions.md) — Permission system, rule syntax, tool-specific rules, working directories, managed-only settings, and sandbox interaction
- [Permission Modes](references/claude-code-permission-modes.md) — Mode descriptions, how to switch modes in CLI/VS Code/JetBrains/Desktop, protected paths, and per-mode behavior
- [Environment Variables](references/claude-code-env-vars.md) — Complete environment variable reference for all Claude Code behavior controls
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) — Web-based admin console delivery, requirements, limitations, and fail-closed enforcement
- [Auto Mode Config](references/claude-code-auto-mode-config.md) — Classifier configuration, trusted infrastructure, block/allow rule overrides, and denial review
- [Admin Setup](references/claude-code-admin-setup.md) — Decision map for org administrators: API provider, settings delivery, enforcement controls, usage visibility, data handling

## Sources

- Settings: https://code.claude.com/docs/en/settings.md
- Permissions: https://code.claude.com/docs/en/permissions.md
- Permission Modes: https://code.claude.com/docs/en/permission-modes.md
- Environment Variables: https://code.claude.com/docs/en/env-vars.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
- Auto Mode Config: https://code.claude.com/docs/en/auto-mode-config.md
- Admin Setup: https://code.claude.com/docs/en/admin-setup.md
