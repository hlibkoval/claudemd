---
name: settings
description: Reference documentation for Claude Code settings, permissions, and server-managed settings — configuration scopes, settings.json fields, permission rules (allow/deny/ask), permission modes, sandbox configuration, and centralized managed settings for organizations.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for configuring Claude Code via settings files, permissions, and server-managed policies.

## Quick Reference

### Configuration Scopes

| Scope       | Location                             | Affects                             | Shared?                |
|:------------|:-------------------------------------|:------------------------------------|:-----------------------|
| **Managed** | System `managed-settings.json`       | All users on the machine            | Yes (deployed by IT)   |
| **User**    | `~/.claude/settings.json`            | You, across all projects            | No                     |
| **Project** | `.claude/settings.json`              | All collaborators in this repo      | Yes (committed to git) |
| **Local**   | `.claude/settings.local.json`        | You, in this repository only        | No (gitignored)        |

**Precedence** (highest to lowest): Managed > CLI args > Local > Project > User

### Key `settings.json` Fields

| Key | Description | Example |
|:----|:------------|:--------|
| `permissions` | Allow/ask/deny rules + defaultMode | see below |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `availableModels` | Restrict selectable models | `["sonnet", "haiku"]` |
| `env` | Environment variables for every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle hook commands | see hooks docs |
| `disableAllHooks` | Disable all hooks and custom status line | `true` |
| `language` | Claude's preferred response language | `"japanese"` |
| `outputStyle` | Adjust system prompt style | `"Explanatory"` |
| `cleanupPeriodDays` | Delete inactive sessions after N days (0 = immediately) | `20` |
| `companyAnnouncements` | Startup announcements cycled at random | `["Welcome!"]` |
| `attribution` | Customize git commit / PR attribution | `{"commit": "...", "pr": ""}` |
| `forceLoginMethod` | Restrict login to `claudeai` or `console` | `"claudeai"` |
| `enableAllProjectMcpServers` | Auto-approve all `.mcp.json` servers | `true` |
| `alwaysThinkingEnabled` | Enable extended thinking by default | `true` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) | `"stable"` |
| `teammateMode` | Agent team display: `auto`, `in-process`, `tmux` | `"in-process"` |
| `plansDirectory` | Where plan files are stored (relative to project root) | `"./plans"` |

### Permission Settings (`permissions` key)

| Key | Description | Example |
|:----|:------------|:--------|
| `allow` | Rules that skip approval | `["Bash(npm run *)"]` |
| `ask` | Rules that prompt for confirmation | `["Bash(git push *)"]` |
| `deny` | Rules that block tool use | `["Read(./.env)"]` |
| `additionalDirectories` | Extra directories Claude can access | `["../docs/"]` |
| `defaultMode` | Default permission mode | `"acceptEdits"` |
| `disableBypassPermissionsMode` | Prevent bypass mode | `"disable"` |

**Rule evaluation order**: deny wins > ask > allow. First match wins.

### Permission Modes (`defaultMode`)

| Mode | Description |
|:-----|:------------|
| `default` | Prompt on first use of each tool |
| `acceptEdits` | Auto-accept file edits for session |
| `plan` | Analyze only — no file edits or commands |
| `dontAsk` | Auto-deny unless pre-approved |
| `bypassPermissions` | Skip all prompts (isolated environments only) |

### Permission Rule Syntax

```
Tool                          # all uses of a tool
Tool(specifier)               # specific uses

Bash(npm run *)               # commands starting with "npm run "
Bash(git commit *)            # commands starting with "git commit "
Read(./.env)                  # reading .env in current directory
Read(~/Documents/*.pdf)       # files in home directory
Read(//Users/alice/secrets/)  # absolute path (double slash)
Edit(/src/**)                 # relative to settings file location
WebFetch(domain:example.com)  # fetch to specific domain
mcp__puppeteer                # all tools from puppeteer MCP server
Task(Explore)                 # Explore subagent
```

Space before `*` enforces a word boundary: `Bash(ls *)` matches `ls -la` but not `lsof`.

### Sandbox Settings (`sandbox` key)

| Key | Default | Description |
|:----|:--------|:------------|
| `enabled` | `false` | Enable bash sandboxing (macOS/Linux/WSL2) |
| `autoAllowBashIfSandboxed` | `true` | Auto-approve bash when sandboxed |
| `excludedCommands` | — | Commands that run outside sandbox |
| `network.allowedDomains` | — | Allowed outbound domains (supports `*`) |
| `network.allowLocalBinding` | `false` | Allow binding to localhost ports (macOS) |
| `network.allowUnixSockets` | — | Unix socket paths accessible in sandbox |

### Managed-Only Settings

| Setting | Description |
|:--------|:------------|
| `disableBypassPermissionsMode` | Set to `"disable"` to prevent bypass mode |
| `allowManagedPermissionRulesOnly` | `true` = only managed permission rules apply |
| `allowManagedHooksOnly` | `true` = only managed and SDK hooks load |
| `strictKnownMarketplaces` | Allowlist of plugin marketplaces users can add |

**Managed settings file locations**:
- macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`
- Linux/WSL: `/etc/claude-code/managed-settings.json`
- Windows: `C:\Program Files\ClaudeCode\managed-settings.json`

### Server-Managed Settings (Public Beta)

For organizations without MDM/endpoint management. Configure in Claude.ai admin console under **Admin Settings > Claude Code > Managed settings**. Requires Claude for Teams/Enterprise and Claude Code v2.1.38+.

Settings are fetched at startup and polled hourly. Certain settings (hooks, custom env vars, shell commands) trigger a security approval dialog. Not available when using Bedrock, Vertex AI, or custom `ANTHROPIC_BASE_URL`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Settings](references/claude-code-settings.md) — complete settings reference including all fields, scopes, sandbox, plugin, and attribution configuration
- [Permissions](references/claude-code-permissions.md) — permission rule syntax, modes, working directories, tool-specific rules, managed-only settings
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) — centralized org settings via Claude.ai admin console, delivery behavior, security dialogs

## Sources

- Settings: https://code.claude.com/docs/en/settings.md
- Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
