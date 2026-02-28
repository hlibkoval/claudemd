---
name: settings-doc
description: Complete documentation for Claude Code settings, permissions, and server-managed settings — configuration scopes (managed/user/project/local), settings.json fields, permission rules and modes, sandbox settings, environment variables, settings precedence, managed-only settings, and enterprise policy delivery. Load when discussing settings files, permission configuration, deny/allow rules, environment variables, sandbox configuration, or managed settings deployment.
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, and server-managed settings.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared? |
|:------|:---------|:---------------|:--------|
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | All users on machine | Yes (IT) |
| **User** | `~/.claude/settings.json` | You, all projects | No |
| **Project** | `.claude/settings.json` | All collaborators | Yes (git) |
| **Local** | `.claude/settings.local.json` | You, this project | No (gitignored) |

### Settings Precedence (highest to lowest)

1. **Managed** (server-managed > MDM/plist > `managed-settings.json` > HKCU)
2. **Command line arguments**
3. **Local project** (`.claude/settings.local.json`)
4. **Shared project** (`.claude/settings.json`)
5. **User** (`~/.claude/settings.json`)

Array settings (e.g., `permissions.allow`) merge (concatenate + dedupe) across scopes.

### Key Settings (`settings.json`)

| Key | Description |
|:----|:-----------|
| `permissions` | Allow/ask/deny rules, `defaultMode`, `additionalDirectories` |
| `hooks` | Lifecycle event handlers (see hooks-doc) |
| `env` | Environment variables applied to every session |
| `model` | Override default model |
| `availableModels` | Restrict selectable models |
| `sandbox` | Sandbox configuration (see below) |
| `attribution` | Customize git commit/PR attribution (`commit`, `pr` keys) |
| `language` | Preferred response language |
| `outputStyle` | Adjust system prompt style |
| `statusLine` | Custom status line command |
| `fileSuggestion` | Custom `@` file autocomplete command |
| `companyAnnouncements` | Startup messages (cycled randomly) |
| `enabledPlugins` | Plugin enable/disable map (`"name@marketplace": true/false`) |
| `extraKnownMarketplaces` | Additional marketplace sources for the project |
| `apiKeyHelper` | Shell script for custom auth key generation |
| `cleanupPeriodDays` | Session cleanup threshold (default: 30) |
| `forceLoginMethod` | Restrict to `claudeai` or `console` login |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) |
| `teammateMode` | Agent team display: `auto`, `in-process`, `tmux` |

Schema: `"$schema": "https://json.schemastore.org/claude-code-settings.json"`

### Permission Modes

| Mode | Description |
|:-----|:-----------|
| `default` | Prompts for permission on first use |
| `acceptEdits` | Auto-accepts file edits for session |
| `plan` | Read-only: no file modifications or commands |
| `dontAsk` | Auto-denies unless pre-approved via allow rules |
| `bypassPermissions` | Skips all prompts (containers/VMs only) |

### Permission Rule Syntax

Rules: `Tool` or `Tool(specifier)`. Evaluation order: **deny > ask > allow** (first match wins).

| Rule | Effect |
|:-----|:-------|
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Read(./.env)` | Reading `.env` in current dir |
| `Edit(/src/**/*.ts)` | Edits in `<project>/src/` recursively |
| `Read(~/.zshrc)` | Home directory file |
| `Read(//Users/alice/secrets/**)` | Absolute path |
| `WebFetch(domain:example.com)` | Fetch to domain |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `Agent(Explore)` | Specific subagent |

Path prefixes (Read/Edit): `//` = absolute, `~/` = home, `/` = project root, `./` or bare = current directory. Patterns follow gitignore spec: `*` matches within directory, `**` matches recursively.

### Sandbox Settings

Nested under `"sandbox"` in settings.json:

| Key | Description |
|:----|:-----------|
| `enabled` | Enable bash sandboxing (default: false) |
| `autoAllowBashIfSandboxed` | Auto-approve sandboxed commands (default: true) |
| `excludedCommands` | Commands that bypass sandbox |
| `filesystem.allowWrite` | Additional writable paths |
| `filesystem.denyWrite` | Blocked write paths |
| `filesystem.denyRead` | Blocked read paths |
| `network.allowedDomains` | Allowed outbound domains (supports `*.example.com`) |
| `network.allowLocalBinding` | Allow localhost binding (macOS, default: false) |
| `network.allowUnixSockets` | Allowed Unix socket paths |

Path prefixes: `//` = absolute, `~/` = home, `/` = relative to settings file dir.

### Managed-Only Settings

| Setting | Description |
|:--------|:-----------|
| `disableBypassPermissionsMode` | `"disable"` to prevent `--dangerously-skip-permissions` |
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply |
| `allowManagedHooksOnly` | Only managed and SDK hooks load |
| `allowManagedMcpServersOnly` | Only managed MCP allowlist applies |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `strictKnownMarketplaces` | Allowlist of permitted marketplaces |
| `sandbox.network.allowManagedDomainsOnly` | Only managed domain allowlist applies |
| `allow_remote_sessions` | Enable/disable Remote Control and web sessions |

### Managed Settings Delivery

| Mechanism | Location |
|:----------|:---------|
| Server-managed | Claude.ai Admin > Claude Code > Managed settings |
| macOS MDM | `com.anthropic.claudecode` managed preferences domain |
| Windows GPO | `HKLM\SOFTWARE\Policies\ClaudeCode` registry key |
| macOS file | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux/WSL file | `/etc/claude-code/managed-settings.json` |
| Windows file | `C:\Program Files\ClaudeCode\managed-settings.json` |

Server-managed settings poll hourly, cache locally, and take precedence over endpoint-managed settings when both are present. Requires direct connection to `api.anthropic.com` (not available with Bedrock/Vertex/Foundry).

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key for Claude SDK |
| `ANTHROPIC_MODEL` | Override model selection |
| `ANTHROPIC_SMALL_FAST_MODEL` | Override small/fast model |
| `ANTHROPIC_BASE_URL` | Custom API endpoint |
| `CLAUDE_CODE_USE_BEDROCK` | `1` to use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | `1` to use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | `1` to use Microsoft Foundry |
| `BASH_DEFAULT_TIMEOUT_MS` | Bash command timeout (default: 120000) |
| `MAX_THINKING_TOKENS` | Max extended thinking tokens |
| `DISABLE_TELEMETRY` | `1` to disable Statsig metrics |
| `DISABLE_ERROR_REPORTING` | `1` to disable Sentry |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | `1` to disable all non-essential traffic |
| `MCP_TIMEOUT` | MCP server startup timeout (ms) |
| `ENABLE_TOOL_SEARCH` | Tool search: `auto`, `true`, `false` |

Verify active settings with `/status`. Manage permissions with `/permissions`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) -- complete settings reference: scopes, settings.json fields, permission rule syntax, sandbox settings, attribution, plugin config, environment variables, and precedence rules
- [Configure Permissions](references/claude-code-permissions.md) -- permission system, modes, rule syntax, tool-specific rules (Bash/Read/Edit/WebFetch/MCP/Agent), wildcards, managed-only settings, working directories, and sandboxing interaction
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) -- centralized configuration via Claude.ai admin console, delivery and caching behavior, security approval dialogs, platform availability, and audit logging

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
