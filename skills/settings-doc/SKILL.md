---
name: settings-doc
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, environment variables, permission modes, server-managed settings, admin setup, and auto mode configuration.

## Quick Reference

### Configuration Scopes

| Scope | Location | Shared with team? | Priority |
| :--- | :--- | :--- | :--- |
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | Yes (deployed by IT) | Highest |
| **Local** | `.claude/settings.local.json` | No (gitignored) | 2nd |
| **Project** | `.claude/settings.json` | Yes (committed to git) | 3rd |
| **User** | `~/.claude/settings.json` | No | Lowest |

Command-line arguments slot between Managed and Local. Permission rules **merge** across all scopes (rather than override); deny rules from any scope win.

### Settings File Locations Summary

| File | Who it affects |
| :--- | :--- |
| `~/.claude/settings.json` | You, every project |
| `.claude/settings.json` | Everyone on this project |
| `.claude/settings.local.json` | You, this project only |
| Managed settings | All users in organization |
| `~/.claude.json` | OAuth session, MCP servers, per-project state (NOT `settings.json`) |
| `.mcp.json` | Project-scoped MCP servers |

### Managed Settings Delivery Mechanisms

| Mechanism | Platform | Priority |
| :--- | :--- | :--- |
| Server-managed (Claude.ai admin console) | All | Highest |
| macOS plist `com.anthropic.claudecode` | macOS | High |
| Windows HKLM registry `HKLM\SOFTWARE\Policies\ClaudeCode` | Windows | High |
| File `managed-settings.json` (macOS: `/Library/Application Support/ClaudeCode/`, Linux/WSL: `/etc/claude-code/`, Windows: `C:\Program Files\ClaudeCode\`) | All | Medium |
| Windows HKCU registry | Windows only | Lowest |

Drop-in directory `managed-settings.d/*.json` supported alongside `managed-settings.json`; files merged alphabetically with numeric prefixes for order control.

### Permission Modes

| Mode | What runs without asking | Best for |
| :--- | :--- | :--- |
| `default` | Reads only | Sensitive work, getting started |
| `acceptEdits` | Reads + file edits + `mkdir`/`touch`/`mv`/`cp` | Iterating on code |
| `plan` | Reads only (no file edits) | Exploring before changing |
| `auto` | Everything, with background safety checks | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down CI/scripts |
| `bypassPermissions` | Everything | Isolated containers/VMs only |

Switch modes with `Shift+Tab` (CLI), `--permission-mode <mode>` flag, or `permissions.defaultMode` in settings.

### Permission Rules Overview

Rules use the format `Tool` or `Tool(specifier)`. Evaluation order: **deny first, then ask, then allow**. First match wins regardless of specificity.

| Rule example | Effect |
| :--- | :--- |
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run ` |
| `Read(./.env)` | Matches reading `.env` in current directory |
| `Read(~/secrets/**)` | Matches any file under `~/secrets/` |
| `Edit(/src/**/*.ts)` | Matches editing TypeScript files under project's `src/` |
| `WebFetch(domain:example.com)` | Matches fetch requests to `example.com` |
| `mcp__github__get_*` | Matches all `get_` tools from the `github` MCP server |
| `Agent(Explore)` | Matches the Explore subagent |

**Path anchor syntax for Read/Edit rules:**

| Pattern | Meaning |
| :--- | :--- |
| `//path` | Absolute path from filesystem root |
| `~/path` | Path from home directory |
| `/path` | Path relative to project root |
| `path` or `./path` | Path relative to current directory |

**Note:** A bare deny like `Bash` removes the tool from Claude's context entirely. A scoped deny like `Bash(rm *)` leaves the tool available but blocks matching calls.

### Key settings.json Options (selected)

| Key | Description | Example |
| :--- | :--- | :--- |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `permissions.allow` | Allow rules array | `["Bash(npm run *)"]` |
| `permissions.deny` | Deny rules array | `["WebFetch", "Read(./.env)"]` |
| `permissions.defaultMode` | Default permission mode | `"acceptEdits"` |
| `permissions.additionalDirectories` | Extra directories for file access | `["../docs/"]` |
| `env` | Environment variables for every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle hook commands | see hooks-doc |
| `apiKeyHelper` | Script to generate auth value | `"/bin/gen_key.sh"` |
| `autoUpdatesChannel` | Release channel: `"stable"` or `"latest"` | `"stable"` |
| `autoCompactEnabled` | Auto-compact when context approaches limit | `false` |
| `fileCheckpointingEnabled` | Snapshot files before edits for `/rewind` | `false` |
| `alwaysThinkingEnabled` | Enable extended thinking by default | `true` |
| `theme` | UI color theme | `"dark"`, `"light"`, `"auto"` |
| `verbose` | Show full tool output | `true` |
| `tui` | Terminal renderer: `"fullscreen"` or `"default"` | `"fullscreen"` |
| `editorMode` | Input key bindings: `"normal"` or `"vim"` | `"vim"` |
| `language` | Claude's preferred response language | `"japanese"` |
| `cleanupPeriodDays` | Days before session files are deleted (default 30) | `20` |
| `companyAnnouncements` | Startup messages for users | `["Welcome!"]` |
| `availableModels` | Restrict selectable models | `["sonnet", "haiku"]` |
| `minimumVersion` | Soft floor for auto-updates | `"2.1.100"` |
| `requiredMinimumVersion` | Hard floor — blocks startup if older | `"2.1.150"` |
| `requiredMaximumVersion` | Ceiling — blocks startup if newer (managed only) | `"2.1.150"` |
| `forceLoginMethod` | Restrict login to `claudeai` or `console` | `"claudeai"` |
| `forceLoginOrgUUID` | Require login to belong to specific org UUID | `"xxxx-..."` |
| `sandbox.enabled` | Enable OS-level bash sandboxing | `true` |
| `worktree.baseRef` | Branch new worktrees from `"fresh"` or `"head"` | `"head"` |
| `attribution.commit` | Git commit attribution text | `""` to disable |
| `attribution.pr` | Pull request attribution text | `""` to disable |
| `skillOverrides` | Per-skill visibility: `"on"`, `"name-only"`, `"off"` | `{"deploy": "off"}` |
| `statusLine` | Custom status line command | `{"type": "command", "command": "~/.claude/statusline.sh"}` |
| `autoMode` | Auto mode classifier config (environment, allow, soft_deny, hard_deny) | `{"soft_deny": ["$defaults", "Never run terraform apply"]}` |

### Managed-Only Settings (ignored in user/project settings)

| Key | Purpose |
| :--- | :--- |
| `allowManagedPermissionRulesOnly` | Block user/project `allow`/`ask`/`deny` rules |
| `allowManagedMcpServersOnly` | Only managed allowlist MCP servers respected |
| `allowManagedHooksOnly` | Only managed hooks and SDK hooks load |
| `allowAllClaudeAiMcps` | Load claude.ai connectors alongside managed-mcp.json |
| `allowedMcpServers` | Allowlist of MCP servers users can configure |
| `deniedMcpServers` | Blocklist of MCP servers (takes precedence) |
| `channelsEnabled` | Allow channels for the organization |
| `blockedMarketplaces` | Blocklist of plugin marketplace sources |
| `strictKnownMarketplaces` | Allowlist of plugin marketplace sources |
| `strictPluginOnlyCustomization` | Block skills/agents/hooks/MCP from user+project sources |
| `claudeMd` | Org-wide CLAUDE.md-style instructions |
| `forceRemoteSettingsRefresh` | Block startup until remote settings fetched |
| `wslInheritsWindowsSettings` | WSL reads Windows policy chain |
| `parentSettingsBehavior` | `"first-wins"` or `"merge"` for SDK-embedded managed settings |
| `policyHelper` | Admin executable that computes managed settings dynamically |

### Sandbox Settings Summary

| Key | Description |
| :--- | :--- |
| `sandbox.enabled` | Enable bash sandboxing (macOS, Linux, WSL2) |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `sandbox.excludedCommands` | Commands that run outside sandbox |
| `sandbox.filesystem.allowWrite` | Paths sandboxed commands can write |
| `sandbox.filesystem.denyRead` | Paths sandboxed commands cannot read |
| `sandbox.network.allowedDomains` | Allowed outbound domains (supports wildcards) |
| `sandbox.network.deniedDomains` | Blocked outbound domains |

### Key Environment Variables (selected)

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key (overrides subscription) |
| `ANTHROPIC_MODEL` | Model to use |
| `ANTHROPIC_BASE_URL` | Override API endpoint (proxy/gateway) |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override Bedrock endpoint |
| `ANTHROPIC_VERTEX_BASE_URL` | Override Vertex AI endpoint |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Full base URL for Foundry resource |
| `API_TIMEOUT_MS` | API request timeout in ms (default: 600000) |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max bash command timeout (default: 600000) |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set to `1` to enable OpenTelemetry |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Set to `1` to disable auto memory |
| `CLAUDE_CODE_DISABLE_BUNDLED_SKILLS` | Set to `1` to disable bundled skills |
| `CLAUDE_CODE_NO_FLICKER` | Set to `1` to enable fullscreen renderer |
| `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN` | Set to `1` to disable fullscreen renderer |
| `CLAUDE_CODE_EFFORT_LEVEL` | Effort level: `low`, `medium`, `high`, `xhigh` |
| `CLAUDE_CODE_MAX_TURNS` | Cap number of agentic turns |
| `CLAUDE_CODE_ENABLE_AUTO_MODE` | Enable auto mode on Bedrock/Vertex/Foundry |
| `DISABLE_AUTOUPDATER` | Disable auto-update entirely |
| `DISABLE_TELEMETRY` | Opt out of telemetry |
| `MAX_THINKING_TOKENS` | Set to `0` to disable extended thinking |
| `CLAUDECODE` | Set to `1` in subprocesses Claude spawns |

Environment variables take precedence over settings fields for the same behavior.

### Auto Mode Configuration

The `autoMode` settings block tells the classifier what your organization trusts. Read from user settings, managed settings, and `--settings` flag only — not from shared project `.claude/settings.json`.

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp",
      "Trusted domains: *.corp.example.com"
    ],
    "soft_deny": ["$defaults", "Never run terraform apply"],
    "hard_deny": ["Never access production databases directly"]
  }
}
```

Include `"$defaults"` in any array to inherit the built-in rules at that position.

### Server-Managed Settings

Requires Claude for Teams or Enterprise plan. Settings delivered from Anthropic servers at authentication and refreshed hourly. Configure at Claude.ai → Admin Settings → Claude Code → Managed settings.

Supports all `settings.json` fields plus managed-only settings. Use for organizations without MDM, or users on unmanaged devices.

### Admin Enforcement Controls

| Control | Key settings |
| :--- | :--- |
| Permission lockdown | `allowManagedPermissionRulesOnly`, `permissions.disableBypassPermissionsMode: "disable"` |
| Disable bypass mode | `permissions.disableBypassPermissionsMode: "disable"` |
| Disable auto mode | `permissions.disableAutoMode: "disable"` |
| Sandboxing | `sandbox.enabled: true`, `sandbox.failIfUnavailable: true` |
| MCP control | `allowedMcpServers`, `deniedMcpServers`, `allowManagedMcpServersOnly` |
| Marketplace control | `strictKnownMarketplaces`, `blockedMarketplaces` |
| Hook restrictions | `allowManagedHooksOnly`, `allowedHttpHookUrls` |
| Version enforcement | `requiredMinimumVersion`, `requiredMaximumVersion` |
| Org CLAUDE.md | `claudeMd` key or file at managed policy path |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) — complete settings reference: scopes, all settings.json keys, permission rules, sandbox, worktree, attribution, and global config settings
- [Admin Setup Guide](references/claude-code-admin-setup.md) — decision map for deploying Claude Code in organizations: API providers, managed settings delivery, enforcement controls, monitoring, and data handling
- [Configure Permissions](references/claude-code-permissions.md) — permission system details: rule syntax, tool-specific rules (Bash, Read/Edit, WebFetch, MCP, Agent, Cd), managed settings, sandboxing interaction
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) — configure Claude Code via the Claude.ai admin console without MDM infrastructure
- [Environment Variables](references/claude-code-env-vars.md) — complete reference for all environment variables that control Claude Code behavior
- [Permission Modes](references/claude-code-permission-modes.md) — how to switch modes, what each mode allows, auto mode requirements, bypassPermissions warnings
- [Configure Auto Mode](references/claude-code-auto-mode-config.md) — auto mode classifier configuration: trusted infrastructure, rule overrides, CLI subcommands to inspect config

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Admin Setup Guide: https://code.claude.com/docs/en/admin-setup.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment Variables: https://code.claude.com/docs/en/env-vars.md
- Permission Modes: https://code.claude.com/docs/en/permission-modes.md
- Configure Auto Mode: https://code.claude.com/docs/en/auto-mode-config.md
