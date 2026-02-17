---
name: settings
description: Reference documentation for Claude Code settings — configuration scopes, settings.json options, permissions, permission modes, permission rule syntax, sandbox settings, environment variables, managed settings, server-managed settings, plugin configuration, and tools available to Claude.
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, and server-managed settings.

## Configuration Scopes

| Scope       | Location                             | Who it affects               | Shared? |
|:------------|:-------------------------------------|:-----------------------------|:--------|
| **Managed** | System `managed-settings.json`       | All users on the machine     | Yes (IT-deployed) |
| **User**    | `~/.claude/settings.json`            | You, across all projects     | No |
| **Project** | `.claude/settings.json`              | All repo collaborators       | Yes (committed) |
| **Local**   | `.claude/settings.local.json`        | You, in this repo only       | No (gitignored) |

### Precedence (highest to lowest)

1. **Managed** settings (cannot be overridden)
2. **Command line arguments**
3. **Local** project settings
4. **Project** shared settings
5. **User** settings

## Settings Files by Feature

| Feature       | User                      | Project                            | Local                          |
|:--------------|:--------------------------|:-----------------------------------|:-------------------------------|
| Settings      | `~/.claude/settings.json` | `.claude/settings.json`            | `.claude/settings.local.json`  |
| Subagents     | `~/.claude/agents/`       | `.claude/agents/`                  | --                             |
| MCP servers   | `~/.claude.json`          | `.mcp.json`                        | `~/.claude.json` (per-project) |
| CLAUDE.md     | `~/.claude/CLAUDE.md`     | `CLAUDE.md` / `.claude/CLAUDE.md`  | `CLAUDE.local.md`              |

## Key Settings (settings.json)

| Key                          | Description                                                                 |
|:-----------------------------|:----------------------------------------------------------------------------|
| `permissions`                | Allow/ask/deny rules, defaultMode, additionalDirectories                    |
| `env`                        | Environment variables applied to every session                              |
| `hooks`                      | Custom commands at lifecycle events                                         |
| `model`                      | Override the default model                                                  |
| `availableModels`            | Restrict which models users can select                                      |
| `sandbox`                    | Bash sandboxing configuration                                               |
| `attribution`                | Customize git commit / PR attribution text                                  |
| `language`                   | Preferred response language                                                 |
| `outputStyle`                | Adjust system prompt style                                                  |
| `companyAnnouncements`       | Messages displayed at startup                                               |
| `apiKeyHelper`               | Script to generate auth value                                               |
| `autoUpdatesChannel`         | `"stable"` or `"latest"` (default)                                          |
| `enableAllProjectMcpServers` | Auto-approve all MCP servers in `.mcp.json`                                 |
| `alwaysThinkingEnabled`      | Enable extended thinking by default                                         |
| `cleanupPeriodDays`          | Delete sessions older than N days (default: 30)                             |
| `forceLoginMethod`           | Restrict to `claudeai` or `console` login                                   |

Add `"$schema": "https://json.schemastore.org/claude-code-settings.json"` for IDE autocomplete.

## Permission System

### Permission Modes

| Mode                 | Description                                                    |
|:---------------------|:---------------------------------------------------------------|
| `default`            | Prompts for permission on first use of each tool               |
| `acceptEdits`        | Auto-accepts file edit permissions for the session             |
| `plan`               | Analyze only -- no file modifications or commands              |
| `delegate`           | Coordination-only for agent team leads                         |
| `dontAsk`            | Auto-denies tools unless pre-approved via allow rules          |
| `bypassPermissions`  | Skips all permission prompts (containers/VMs only)             |

### Rule Evaluation Order

**deny -> ask -> allow** (first match wins; deny always takes precedence)

### Permission Rule Syntax

| Rule                           | Effect                                         |
|:-------------------------------|:-----------------------------------------------|
| `Bash`                         | Matches all Bash commands                      |
| `Bash(npm run *)`              | Glob wildcard -- commands starting with `npm run` |
| `Bash(git * main)`             | Wildcard in middle                             |
| `Read(./.env)`                 | Matches reading `.env` in project root         |
| `Edit(/src/**/*.ts)`           | Gitignore-style -- relative to settings file   |
| `Read(~/.zshrc)`               | Home directory path                            |
| `Read(//usr/local/file)`       | Absolute filesystem path (note `//`)           |
| `WebFetch(domain:example.com)` | Domain-scoped web fetch                        |
| `mcp__server__tool`            | Specific MCP tool                              |
| `Task(AgentName)`              | Control subagent access                        |

**Path prefix rules for Read/Edit** (gitignore spec):
- `//path` -- absolute from filesystem root
- `~/path` -- relative to home directory
- `/path` -- relative to settings file location
- `path` or `./path` -- relative to current directory

**Bash wildcard note**: `Bash(ls *)` (space before `*`) enforces word boundary; `Bash(ls*)` does not.

## Sandbox Settings

| Key                           | Description                                                |
|:------------------------------|:-----------------------------------------------------------|
| `sandbox.enabled`             | Enable bash sandboxing (default: false)                    |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true)      |
| `sandbox.excludedCommands`    | Commands that run outside sandbox                          |
| `sandbox.network.allowedDomains` | Domains allowed for outbound traffic (supports `*.`)    |
| `sandbox.network.allowLocalBinding` | Allow binding to localhost ports (macOS only)        |

## Managed Settings

**File locations** (system-wide, require admin privileges):
- **macOS**: `/Library/Application Support/ClaudeCode/managed-settings.json`
- **Linux/WSL**: `/etc/claude-code/managed-settings.json`
- **Windows**: `C:\Program Files\ClaudeCode\managed-settings.json`

### Managed-Only Settings

| Setting                           | Description                                              |
|:----------------------------------|:---------------------------------------------------------|
| `disableBypassPermissionsMode`    | `"disable"` prevents `--dangerously-skip-permissions`    |
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply                      |
| `allowManagedHooksOnly`           | Only managed + SDK hooks are loaded                      |
| `strictKnownMarketplaces`         | Allowlist of plugin marketplaces users can add           |

## Server-Managed Settings

For organizations without MDM. Delivered from Anthropic's servers via Claude.ai admin console.

- **Requirements**: Teams or Enterprise plan, Claude Code >= 2.1.38 (Teams) / 2.1.30 (Enterprise)
- **Configure at**: Claude.ai > Admin Settings > Claude Code > Managed settings
- **Delivery**: Fetched at startup, polled hourly, cached locally
- **Precedence**: Same tier as endpoint-managed settings; when both present, server-managed wins
- **Limitation**: Settings apply uniformly to all users (no per-group yet); no MCP server distribution

### Security Approval Dialogs

Shell commands, custom env vars, and hook configurations in server-managed settings require explicit user approval (skipped in non-interactive `-p` mode).

## Key Environment Variables

| Variable                       | Purpose                                                        |
|:-------------------------------|:---------------------------------------------------------------|
| `ANTHROPIC_API_KEY`            | API key for Claude SDK                                         |
| `ANTHROPIC_MODEL`              | Override model selection                                       |
| `CLAUDE_CODE_USE_BEDROCK`      | Use Amazon Bedrock                                             |
| `CLAUDE_CODE_USE_VERTEX`       | Use Google Vertex AI                                           |
| `CLAUDE_CODE_USE_FOUNDRY`      | Use Microsoft Foundry                                          |
| `CLAUDE_CODE_EFFORT_LEVEL`     | `low`/`medium`/`high` (Opus 4.6 only)                         |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS`| Max output tokens (default: 32000, max: 64000)                 |
| `MAX_THINKING_TOKENS`          | Override thinking budget (0 to disable)                        |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | `1` to enable OpenTelemetry                                    |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disables updater, bug cmd, errors, telemetry    |
| `CLAUDE_CODE_SHELL`            | Override shell detection                                       |
| `CLAUDE_ENV_FILE`              | Path to script sourced before each Bash command                |
| `BASH_DEFAULT_TIMEOUT_MS`      | Default bash command timeout                                   |
| `HTTP_PROXY` / `HTTPS_PROXY`   | Proxy server configuration                                     |

## Tools Available to Claude

| Tool             | Permission? | Description                              |
|:-----------------|:------------|:-----------------------------------------|
| Read / Glob / Grep | No       | Read files, find by pattern, search      |
| Bash             | Yes         | Execute shell commands                   |
| Edit / Write     | Yes         | Modify or create files                   |
| WebFetch / WebSearch | Yes     | Fetch URLs, search the web               |
| Task             | No          | Spawn subagents                          |
| Skill            | Yes         | Execute a skill                          |
| LSP              | No          | Code intelligence via language servers   |

## Full Documentation

For the complete official documentation, see the reference files:

- [Settings](references/claude-code-settings.md) -- complete settings reference, all options, environment variables, tools, plugin/sandbox configuration
- [Permissions](references/claude-code-permissions.md) -- permission system, rule syntax, tool-specific patterns, modes, managed policies
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) -- centralized configuration via Anthropic servers for Teams/Enterprise

## Sources

- Settings: https://code.claude.com/docs/en/settings.md
- Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
