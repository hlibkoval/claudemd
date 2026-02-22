---
name: settings
description: Reference documentation for Claude Code settings, configuration scopes, settings.json options, permission rules, sandbox settings, environment variables, managed settings, server-managed settings, and settings precedence. Use when configuring Claude Code behavior, setting permissions, understanding configuration hierarchy, or managing enterprise settings policies.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, and server-managed settings.

## Quick Reference

### Configuration Scopes

| Scope       | Location                             | Who it affects             | Shared? |
|:------------|:-------------------------------------|:---------------------------|:--------|
| **Managed** | System-level `managed-settings.json` | All users on the machine   | Yes (IT)|
| **User**    | `~/.claude/settings.json`            | You, across all projects   | No      |
| **Project** | `.claude/settings.json`              | All collaborators          | Yes     |
| **Local**   | `.claude/settings.local.json`        | You, in this project only  | No      |

### Settings Precedence (highest to lowest)

1. **Managed** -- cannot be overridden
2. **Command line arguments** -- session overrides
3. **Local project** -- `.claude/settings.local.json`
4. **Shared project** -- `.claude/settings.json`
5. **User** -- `~/.claude/settings.json`

### Key settings.json Fields

| Key                          | Description                                                        |
|:-----------------------------|:-------------------------------------------------------------------|
| `permissions`                | Allow/ask/deny rules, defaultMode, additionalDirectories           |
| `hooks`                      | Custom commands at lifecycle events                                 |
| `env`                        | Environment variables applied every session                        |
| `model`                      | Override default model                                             |
| `availableModels`            | Restrict model selection via `/model`                              |
| `sandbox`                    | Sandbox configuration (enabled, network, filesystem)               |
| `attribution`                | Customize git commit / PR attribution                              |
| `apiKeyHelper`               | Script to generate auth value                                      |
| `companyAnnouncements`       | Startup messages for users                                         |
| `outputStyle`                | Adjust system prompt style                                         |
| `language`                   | Preferred response language                                        |
| `autoUpdatesChannel`         | `"stable"` or `"latest"` (default)                                 |
| `statusLine`                 | Custom status line command                                         |
| `fileSuggestion`             | Custom `@` file autocomplete command                               |
| `enableAllProjectMcpServers` | Auto-approve project MCP servers                                   |
| `forceLoginMethod`           | Restrict login to `claudeai` or `console`                          |
| `teammateMode`               | Agent teams display: `auto`, `in-process`, `tmux`                  |

### Permission Settings

| Key                      | Description                                                 |
|:-------------------------|:------------------------------------------------------------|
| `permissions.allow`      | Rules to auto-approve tool use                              |
| `permissions.ask`        | Rules to prompt for confirmation                            |
| `permissions.deny`       | Rules to block tool use                                     |
| `permissions.defaultMode`| Default permission mode (`default`, `acceptEdits`, `plan`, `dontAsk`, `bypassPermissions`) |
| `permissions.additionalDirectories` | Extra working directories                        |
| `permissions.disableBypassPermissionsMode` | `"disable"` to block `--dangerously-skip-permissions` |

Rule evaluation order: **deny -> ask -> allow**. First match wins.

### Permission Rule Syntax

| Pattern                        | Matches                                  |
|:-------------------------------|:-----------------------------------------|
| `Bash`                         | All bash commands                        |
| `Bash(npm run *)`              | Commands starting with `npm run `        |
| `Read(./.env)`                 | Reading `.env` in current dir            |
| `Edit(/src/**/*.ts)`           | Editing TS files under `src/`            |
| `Read(//absolute/path)`        | Absolute filesystem path (double slash)  |
| `Read(~/path)`                 | Path from home directory                 |
| `WebFetch(domain:example.com)` | Fetch requests to example.com            |
| `mcp__server__tool`            | Specific MCP tool                        |
| `Task(AgentName)`              | Specific subagent                        |

### Managed-Only Settings

| Setting                           | Description                                              |
|:----------------------------------|:---------------------------------------------------------|
| `disableBypassPermissionsMode`    | Prevent `bypassPermissions` mode                         |
| `allowManagedPermissionRulesOnly` | Block user/project permission rules                      |
| `allowManagedHooksOnly`           | Block user/project/plugin hooks                          |
| `strictKnownMarketplaces`         | Restrict which plugin marketplaces users can add         |

### Managed Settings File Locations

| Platform      | Path                                                      |
|:--------------|:----------------------------------------------------------|
| macOS         | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux / WSL   | `/etc/claude-code/managed-settings.json`                  |
| Windows       | `C:\Program Files\ClaudeCode\managed-settings.json`       |

### Server-Managed Settings

For orgs without MDM: configure via **Claude.ai > Admin Settings > Claude Code > Managed settings**. Requires Teams or Enterprise plan. Settings are fetched at startup and polled hourly. Cached settings persist through network failures. When both server-managed and endpoint-managed settings exist, server-managed takes precedence.

### Sandbox Settings (under `sandbox` key)

| Key                           | Description                                            |
|:------------------------------|:-------------------------------------------------------|
| `enabled`                     | Enable bash sandboxing (default: false)                |
| `autoAllowBashIfSandboxed`    | Auto-approve sandboxed commands (default: true)        |
| `excludedCommands`            | Commands that bypass the sandbox                       |
| `allowUnsandboxedCommands`    | Allow `dangerouslyDisableSandbox` escape (default: true)|
| `network.allowedDomains`      | Outbound domain allowlist (supports `*.example.com`)   |
| `network.allowUnixSockets`    | Unix socket paths accessible in sandbox                |
| `network.allowLocalBinding`   | Allow localhost port binding (macOS only)              |

### Key Environment Variables

| Variable                                | Purpose                                         |
|:----------------------------------------|:------------------------------------------------|
| `ANTHROPIC_API_KEY`                     | API key for Claude SDK                          |
| `ANTHROPIC_MODEL`                       | Model override                                  |
| `CLAUDE_CODE_ENABLE_TELEMETRY`          | Enable OpenTelemetry                            |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable telemetry, error reporting, updates  |
| `CLAUDE_CODE_EFFORT_LEVEL`              | `low` / `medium` / `high` (Opus 4.6 only)      |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS`         | Max output tokens (default: 32000, max: 64000)  |
| `CLAUDE_CODE_USE_BEDROCK`               | Use Amazon Bedrock                              |
| `CLAUDE_CODE_USE_VERTEX`                | Use Google Vertex AI                            |
| `CLAUDE_CODE_USE_FOUNDRY`               | Use Microsoft Foundry                           |
| `HTTP_PROXY` / `HTTPS_PROXY`            | Proxy configuration                             |
| `NODE_EXTRA_CA_CERTS`                   | Custom CA certificate path                      |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) -- complete settings reference: scopes, settings.json fields, permission settings, sandbox settings, environment variables, plugin configuration, tools, and bash behavior
- [Configure Permissions](references/claude-code-permissions.md) -- permission system, rule syntax, tool-specific patterns, permission modes, managed settings, and working directories
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) -- centralized configuration via Claude.ai admin console, delivery behavior, caching, security considerations, and platform availability

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
