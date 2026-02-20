---
name: settings
description: Reference documentation for Claude Code settings, permissions, and configuration — covers settings.json files, scopes (managed/user/project/local), permission rules and modes, environment variables, sandbox settings, server-managed settings, managed policies, plugin and MCP configuration, and the full available settings table.
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for configuring Claude Code through settings files, permissions, and environment variables.

## Quick Reference

### Configuration Scopes

| Scope       | Location                             | Who it affects             | Shared? |
|:------------|:-------------------------------------|:---------------------------|:--------|
| **Managed** | System `managed-settings.json`       | All users on machine       | Yes (IT)|
| **User**    | `~/.claude/settings.json`            | You, all projects          | No      |
| **Project** | `.claude/settings.json`              | All collaborators          | Yes     |
| **Local**   | `.claude/settings.local.json`        | You, this project only     | No      |

**Precedence** (highest to lowest): Managed > CLI args > Local > Project > User

### Managed Settings Locations

| Platform    | Path                                                       |
|:------------|:-----------------------------------------------------------|
| macOS       | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux / WSL | `/etc/claude-code/managed-settings.json`                   |
| Windows     | `C:\Program Files\ClaudeCode\managed-settings.json`        |

### Key Settings (`settings.json`)

| Key                          | Description                                                     |
|:-----------------------------|:----------------------------------------------------------------|
| `permissions`                | Allow/ask/deny rules, defaultMode, additionalDirectories        |
| `env`                        | Environment variables applied to every session                  |
| `hooks`                      | Custom commands at lifecycle events                             |
| `model`                      | Override default model                                          |
| `availableModels`            | Restrict model selection via `/model`                           |
| `sandbox`                    | Bash sandboxing config (enabled, network, excludedCommands)     |
| `attribution`                | Customize git commit / PR attribution                           |
| `enabledPlugins`             | Enable/disable plugins (`"name@marketplace": true/false`)       |
| `extraKnownMarketplaces`     | Additional plugin marketplaces for the repo                     |
| `language`                   | Preferred response language                                     |
| `outputStyle`                | Output style to adjust system prompt                            |
| `apiKeyHelper`               | Script to generate auth value                                   |
| `statusLine`                 | Custom status line command                                      |
| `companyAnnouncements`       | Startup announcements for users                                 |
| `autoUpdatesChannel`         | `"stable"` or `"latest"` (default)                              |

### Permission Modes

| Mode                | Description                                               |
|:--------------------|:----------------------------------------------------------|
| `default`           | Prompts on first use of each tool                         |
| `acceptEdits`       | Auto-accepts file edit permissions                        |
| `plan`              | Read-only: no modifications or commands                   |
| `dontAsk`           | Auto-denies unless pre-approved                           |
| `bypassPermissions` | Skips all prompts (isolated environments only)            |

### Permission Rule Syntax

Rules: `Tool` or `Tool(specifier)`. Evaluation order: **deny > ask > allow**.

| Rule                           | Effect                                   |
|:-------------------------------|:-----------------------------------------|
| `Bash`                         | All Bash commands                        |
| `Bash(npm run *)`              | Commands starting with `npm run`         |
| `Read(./.env)`                 | Reading `.env` in current dir            |
| `Edit(/src/**/*.ts)`           | Edits in `<settings-file-dir>/src/`      |
| `Read(~/.zshrc)`               | Home directory `.zshrc`                  |
| `Read(//Users/alice/file)`     | Absolute path (note double slash)        |
| `WebFetch(domain:example.com)` | Fetch requests to example.com            |
| `mcp__server__tool`            | Specific MCP tool                        |
| `Task(Explore)`                | Specific subagent                        |

Read/Edit patterns follow gitignore spec. `*` matches single dir, `**` matches recursively.

### Managed-Only Settings

| Setting                           | Description                                        |
|:----------------------------------|:---------------------------------------------------|
| `disableBypassPermissionsMode`    | Prevent `bypassPermissions` mode                   |
| `allowManagedPermissionRulesOnly` | Block user/project permission rules                |
| `allowManagedHooksOnly`           | Block user/project/plugin hooks                    |
| `strictKnownMarketplaces`         | Restrict plugin marketplace additions              |

### Server-Managed Settings

For orgs without MDM. Settings delivered from Anthropic's servers via Claude.ai admin console.

- Requires Teams or Enterprise plan
- Fetched at startup, polled hourly
- Same precedence as endpoint-managed settings (highest tier)
- When both exist, server-managed takes precedence over endpoint-managed
- Configure at: Claude.ai > Admin Settings > Claude Code > Managed settings

### Key Environment Variables

| Variable                        | Purpose                                              |
|:--------------------------------|:-----------------------------------------------------|
| `ANTHROPIC_API_KEY`             | API key for model requests                           |
| `ANTHROPIC_MODEL`               | Override default model                               |
| `CLAUDE_CODE_USE_BEDROCK`       | Use Amazon Bedrock                                   |
| `CLAUDE_CODE_USE_VERTEX`        | Use Google Vertex AI                                 |
| `CLAUDE_CODE_USE_FOUNDRY`       | Use Microsoft Foundry                                |
| `CLAUDE_CODE_ENABLE_TELEMETRY`  | Enable OpenTelemetry                                 |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Max output tokens (default 32k, max 64k)             |
| `MAX_THINKING_TOKENS`           | Override thinking token budget                       |
| `CLAUDE_CODE_EFFORT_LEVEL`      | `low` / `medium` / `high` (Opus 4.6 only)           |
| `CLAUDE_CODE_SIMPLE`            | Minimal system prompt, Bash/Read/Edit only           |
| `DISABLE_TELEMETRY`             | Opt out of Statsig telemetry                         |
| `HTTP_PROXY` / `HTTPS_PROXY`    | Proxy server for network connections                 |

### Sandbox Settings (under `sandbox` key)

| Key                           | Description                                        |
|:------------------------------|:---------------------------------------------------|
| `enabled`                     | Enable bash sandboxing (default: false)            |
| `autoAllowBashIfSandboxed`    | Auto-approve bash when sandboxed (default: true)   |
| `excludedCommands`            | Commands that bypass sandbox                       |
| `network.allowedDomains`      | Allowed domains for outbound traffic               |
| `network.allowUnixSockets`    | Accessible Unix socket paths                       |
| `network.allowLocalBinding`   | Allow binding to localhost (macOS, default: false)  |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) — settings files, scopes, available settings table, permissions config, sandbox settings, attribution, environment variables, tools, and bash behavior
- [Configure Permissions](references/claude-code-permissions.md) — permission system, modes, rule syntax, tool-specific rules (Bash, Read, Edit, WebFetch, MCP, Task), managed settings, working directories, and sandboxing interaction
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) — centralized server-delivered configuration for organizations without MDM, delivery mechanics, caching, security considerations

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
