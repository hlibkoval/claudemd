---
name: settings-doc
description: Claude Code settings, permissions, and configuration reference. Covers settings.json fields, configuration scopes (user/project/managed), permission rules and modes, sandbox settings, server-managed settings, and environment variables. Load when configuring Claude Code behavior, setting up permissions or deny rules, or deploying managed policies.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, and managed configuration.

## Quick Reference

### Configuration Scopes

| Scope       | Location                                            | Who it affects              | Shared?        |
|:------------|:----------------------------------------------------|:----------------------------|:---------------|
| **Managed** | Server, plist/registry, or `managed-settings.json` | All users on the machine    | Yes (IT)       |
| **User**    | `~/.claude/settings.json`                           | You, across all projects    | No             |
| **Project** | `.claude/settings.json`                             | All repo collaborators      | Yes (git)      |
| **Local**   | `.claude/settings.local.json`                       | You, in this repo only      | No (gitignored)|

**Precedence** (highest to lowest): Managed > CLI args > Local > Project > User

### Settings Files by Feature

| Feature         | User                      | Project                            | Local                          |
|:----------------|:--------------------------|:-----------------------------------|:-------------------------------|
| Settings        | `~/.claude/settings.json` | `.claude/settings.json`            | `.claude/settings.local.json`  |
| Subagents       | `~/.claude/agents/`       | `.claude/agents/`                  | —                              |
| MCP servers     | `~/.claude.json`          | `.mcp.json`                        | `~/.claude.json` (per-project) |
| CLAUDE.md       | `~/.claude/CLAUDE.md`     | `CLAUDE.md` or `.claude/CLAUDE.md` | `CLAUDE.local.md`              |

### Key settings.json Fields

| Key                        | Description                                                          | Example                          |
|:---------------------------|:---------------------------------------------------------------------|:---------------------------------|
| `model`                    | Override default model                                               | `"claude-sonnet-4-6"`            |
| `availableModels`          | Restrict selectable models                                           | `["sonnet", "haiku"]`            |
| `language`                 | Claude's preferred response language                                 | `"japanese"`                     |
| `env`                      | Environment variables for every session                              | `{"FOO": "bar"}`                 |
| `permissions`              | Allow/ask/deny rules + defaultMode                                   | see below                        |
| `hooks`                    | Lifecycle hook commands                                              | see hooks skill                  |
| `disableAllHooks`          | Disable all hooks and custom status line                             | `true`                           |
| `apiKeyHelper`             | Script to generate auth value (X-Api-Key header)                     | `/bin/gen_key.sh`                |
| `cleanupPeriodDays`        | Days before inactive sessions are deleted (default: 30)              | `20`                             |
| `companyAnnouncements`     | Messages shown at startup                                            | `["Welcome!"]`                   |
| `outputStyle`              | Adjust system prompt style                                           | `"Explanatory"`                  |
| `autoUpdatesChannel`       | Release channel: `"stable"` or `"latest"` (default)                 | `"stable"`                       |
| `forceLoginMethod`         | Restrict login to `claudeai` or `console`                            | `"claudeai"`                     |
| `plansDirectory`           | Where plan files are stored (default: `~/.claude/plans`)             | `"./plans"`                      |
| `attribution`              | Git commit/PR attribution strings                                    | `{"commit": "...", "pr": ""}`    |
| `alwaysThinkingEnabled`    | Enable extended thinking by default                                  | `true`                           |
| `teammateMode`             | Agent team display: `auto`, `in-process`, or `tmux`                 | `"in-process"`                   |
| `respectGitignore`         | @ file picker respects .gitignore (default: `true`)                  | `false`                          |
| `enableAllProjectMcpServers` | Auto-approve all MCP servers from project `.mcp.json`              | `true`                           |

### Permission Settings

| Key                    | Description                                                     | Example                              |
|:-----------------------|:----------------------------------------------------------------|:-------------------------------------|
| `allow`                | Rules to allow tool use without prompting                       | `["Bash(npm run *)", "Read(~/.zshrc)"]` |
| `ask`                  | Rules to always prompt for confirmation                         | `["Bash(git push *)"]`               |
| `deny`                 | Rules to block tool use entirely                                | `["Bash(curl *)", "Read(./.env)"]`   |
| `additionalDirectories`| Extra working directories Claude can access                     | `["../docs/"]`                       |
| `defaultMode`          | Default permission mode                                         | `"acceptEdits"`                      |

### Permission Modes

| Mode                | Description                                                          |
|:--------------------|:---------------------------------------------------------------------|
| `default`           | Prompts on first use of each tool                                    |
| `acceptEdits`       | Auto-accepts file edit permissions for the session                   |
| `plan`              | Claude can analyze but not modify files or execute commands          |
| `dontAsk`           | Auto-denies tools unless pre-approved via rules                      |
| `bypassPermissions` | Skips all prompts (use only in isolated/sandboxed environments)      |

### Permission Rule Syntax

Rules follow `Tool` or `Tool(specifier)`. Evaluated: deny > ask > allow (first match wins).

| Rule                           | Effect                                         |
|:-------------------------------|:-----------------------------------------------|
| `Bash`                         | All Bash commands                              |
| `Bash(npm run *)`              | Commands starting with `npm run `              |
| `Read(./.env)`                 | Reading the `.env` file                        |
| `Read(~/Documents/*.pdf)`      | Files under home directory path                |
| `Edit(/src/**/*.ts)`           | Edits relative to project root                 |
| `Read(//Users/alice/secrets/**)`| Absolute filesystem path                      |
| `WebFetch(domain:example.com)` | Fetch requests to example.com                  |
| `mcp__puppeteer`               | Any tool from the puppeteer MCP server         |
| `Task(Explore)`                | The Explore subagent                           |
| `Skill(name)`                  | Specific skill (to allow/deny)                 |

### Sandbox Settings (under `sandbox`)

| Key                        | Description                                        | Default |
|:---------------------------|:---------------------------------------------------|:--------|
| `enabled`                  | Enable bash sandboxing                             | `false` |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed                   | `true`  |
| `excludedCommands`         | Commands to run outside sandbox                    | `[]`    |
| `network.allowedDomains`   | Outbound domain allowlist (supports wildcards)     | —       |
| `network.allowLocalBinding`| Allow binding to localhost ports (macOS only)      | `false` |
| `network.allowUnixSockets` | Unix socket paths accessible in sandbox            | —       |

### Managed-Only Settings

| Setting                           | Description                                                           |
|:----------------------------------|:----------------------------------------------------------------------|
| `disableBypassPermissionsMode`    | Set `"disable"` to block `bypassPermissions` mode                    |
| `allowManagedPermissionRulesOnly` | `true` = only managed `allow`/`ask`/`deny` rules apply               |
| `allowManagedHooksOnly`           | `true` = only managed and SDK hooks run                               |
| `allowManagedMcpServersOnly`      | `true` = only managed MCP allowlist applies                           |
| `blockedMarketplaces`             | Blocklist of plugin marketplace sources                               |
| `sandbox.network.allowManagedDomainsOnly` | `true` = only managed domain allowlist is used               |
| `strictKnownMarketplaces`         | Allowlist of plugin marketplaces users can add                        |
| `allow_remote_sessions`           | `false` to prevent Remote Control and web sessions (default: `true`)  |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) -- configuration scopes, settings.json fields, sandbox, attribution, plugin, and subagent settings
- [Configure Permissions](references/claude-code-permissions.md) -- permission system, modes, rule syntax, tool-specific rules, and managed-only settings
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) -- centrally deploying settings via Claude.ai admin console, delivery behavior, and security considerations

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
