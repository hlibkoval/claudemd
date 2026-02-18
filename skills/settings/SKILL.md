---
name: settings
description: Reference documentation for Claude Code settings, permissions, and managed configuration. Use when configuring settings.json, understanding configuration scopes and precedence, writing permission rules (allow/deny/ask), choosing permission modes, managing working directories, deploying organization-wide managed or server-managed settings, or controlling tool access.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, and server-managed settings.

## Quick Reference

### Configuration Scopes and Precedence

| Priority | Scope        | Location                             | Shared?                |
|:---------|:-------------|:-------------------------------------|:-----------------------|
| 1 (high) | **Managed**  | System-level `managed-settings.json` | Yes (deployed by IT)   |
| 2        | **CLI args** | Command-line flags                   | No (session only)      |
| 3        | **Local**    | `.claude/settings.local.json`        | No (gitignored)        |
| 4        | **Project**  | `.claude/settings.json`              | Yes (committed to git) |
| 5 (low)  | **User**     | `~/.claude/settings.json`            | No                     |

### Settings Files by Feature

| Feature     | User                      | Project                            | Local                          |
|:------------|:--------------------------|:-----------------------------------|:-------------------------------|
| Settings    | `~/.claude/settings.json` | `.claude/settings.json`            | `.claude/settings.local.json`  |
| Subagents   | `~/.claude/agents/`       | `.claude/agents/`                  | --                             |
| MCP servers | `~/.claude.json`          | `.mcp.json`                        | `~/.claude.json` (per-project) |
| CLAUDE.md   | `~/.claude/CLAUDE.md`     | `CLAUDE.md` / `.claude/CLAUDE.md`  | `CLAUDE.local.md`              |

### Key settings.json Fields

| Key                          | Description                                                             |
|:-----------------------------|:------------------------------------------------------------------------|
| `permissions`                | Allow/ask/deny rules, `defaultMode`, `additionalDirectories`            |
| `env`                        | Environment variables applied to every session                          |
| `hooks`                      | Custom commands at lifecycle events                                     |
| `model`                      | Override the default model                                              |
| `availableModels`            | Restrict which models users can select via `/model`                     |
| `attribution`                | Customize git commit / PR attribution text                              |
| `language`                   | Preferred response language (e.g. `"japanese"`)                         |
| `outputStyle`                | Adjust system prompt style                                              |
| `companyAnnouncements`       | Messages displayed at startup (cycled randomly)                         |
| `apiKeyHelper`               | Script run in `/bin/sh` to generate auth value                          |
| `autoUpdatesChannel`         | `"stable"` or `"latest"` (default)                                      |
| `enableAllProjectMcpServers` | Auto-approve all MCP servers in `.mcp.json`                             |
| `alwaysThinkingEnabled`      | Enable extended thinking by default                                     |
| `cleanupPeriodDays`          | Delete sessions inactive longer than N days (default: 30; 0 = all)     |
| `forceLoginMethod`           | Restrict to `"claudeai"` or `"console"` login                           |
| `disableAllHooks`            | Disable all hooks and custom status line                                |
| `plansDirectory`             | Where plan files are stored (default: `~/.claude/plans`)                |
| `teammateMode`               | Agent team display: `"auto"`, `"in-process"`, or `"tmux"`               |

Add `"$schema": "https://json.schemastore.org/claude-code-settings.json"` for IDE autocomplete.

### Permission Settings (`permissions` key)

| Key                          | Description                                              | Example                            |
|:-----------------------------|:---------------------------------------------------------|:-----------------------------------|
| `allow`                      | Rules to permit tool use without prompting               | `["Bash(npm run *)"]`              |
| `ask`                        | Rules to require confirmation                            | `["Bash(git push *)"]`             |
| `deny`                       | Rules to block tool use entirely                         | `["Bash(curl *)", "WebFetch"]`     |
| `additionalDirectories`      | Extra directories Claude can access                      | `["../docs/"]`                     |
| `defaultMode`                | Default permission mode (see below)                      | `"acceptEdits"`                    |
| `disableBypassPermissionsMode` | `"disable"` to block bypassPermissions mode            | `"disable"`                        |

### Permission Modes

| Mode                | Description                                               |
|:--------------------|:----------------------------------------------------------|
| `default`           | Prompts for permission on first use of each tool          |
| `acceptEdits`       | Auto-accepts file edit permissions for the session        |
| `plan`              | Read-only: analyze but not modify files or run commands   |
| `dontAsk`           | Auto-denies tools unless pre-approved via allow rules     |
| `delegate`          | Coordination-only for agent team leads                    |
| `bypassPermissions` | Skips all permission prompts (isolated environments only) |

### Permission Rule Syntax

Rules follow `Tool` or `Tool(specifier)`. Evaluation order: **deny > ask > allow** (first match wins).

| Rule                           | Effect                                                    |
|:-------------------------------|:----------------------------------------------------------|
| `Bash`                         | Matches all Bash commands                                 |
| `Bash(npm run *)`              | Glob -- commands starting with `npm run ` (word boundary) |
| `Bash(git * main)`             | Wildcard in middle, e.g. `git checkout main`              |
| `Read(./.env)`                 | Matches reading `.env` relative to current directory      |
| `Edit(/src/**/*.ts)`           | Gitignore-style -- relative to settings file location     |
| `Read(~/.zshrc)`               | Home directory path                                       |
| `Read(//usr/local/file)`       | Absolute filesystem path (double slash = fs root)         |
| `WebFetch(domain:example.com)` | Domain-scoped web fetch                                   |
| `mcp__puppeteer__navigate`     | Specific MCP tool (`server__tool`)                        |
| `Task(AgentName)`              | Control subagent access                                   |

**Path prefix rules for Read/Edit** (gitignore spec):
- `//path` -- absolute from filesystem root
- `~/path` -- relative to home directory
- `/path` -- relative to settings file location (NOT absolute)
- `path` or `./path` -- relative to current working directory

**Bash wildcard note**: `Bash(ls *)` (space before `*`) enforces word boundary; `Bash(ls*)` does not.

### Managed Settings

**File locations** (system-wide, require admin privileges):
- **macOS**: `/Library/Application Support/ClaudeCode/managed-settings.json`
- **Linux/WSL**: `/etc/claude-code/managed-settings.json`
- **Windows**: `C:\Program Files\ClaudeCode\managed-settings.json`

**Managed-only settings** (only effective in managed settings files):

| Setting                           | Description                                           |
|:----------------------------------|:------------------------------------------------------|
| `disableBypassPermissionsMode`    | `"disable"` prevents `--dangerously-skip-permissions` |
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply                   |
| `allowManagedHooksOnly`           | Only managed + SDK hooks are loaded                   |
| `strictKnownMarketplaces`         | Allowlist of plugin marketplaces users can add        |

### Server-Managed Settings (Beta)

For organizations without MDM. Configured via Claude.ai admin console (Admin Settings > Claude Code > Managed settings), delivered at startup and polled hourly.

- **Requirements**: Teams/Enterprise plan; Claude Code >= 2.1.38 (Teams) / 2.1.30 (Enterprise)
- **Precedence**: Same tier as endpoint-managed; when both present, server-managed wins
- **Limitations**: Uniform to all users (no per-group); no MCP server distribution; not available with third-party providers (Bedrock, Vertex, Foundry, custom `ANTHROPIC_BASE_URL`)
- **Security dialogs**: Shell commands, custom env vars, and hooks require explicit user approval on first load

## Full Documentation

For the complete official documentation, see the reference files:

- [Settings](references/claude-code-settings.md) -- configuration scopes, all settings fields, environment variables, and file locations
- [Permissions](references/claude-code-permissions.md) -- permission system, modes, rule syntax, tool-specific rules (Bash, Read/Edit, WebFetch, MCP, Task), working directories, and managed settings
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) -- server-delivered centralized configuration, security approval dialogs, caching behavior, and audit logging

## Sources

- Settings: https://code.claude.com/docs/en/settings.md
- Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
