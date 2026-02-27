---
name: settings-doc
description: Reference documentation for Claude Code settings and configuration — settings.json options, configuration scopes (managed/user/project/local), permissions system, permission modes, permission rule syntax for Bash/Read/Edit/WebFetch/MCP/Task tools, managed settings delivery, server-managed settings, environment variables, sandbox settings, and settings precedence.
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, and server-managed settings.

## Quick Reference

### Configuration Scopes

| Scope       | Location                                                     | Who it affects               | Shared? |
|:------------|:-------------------------------------------------------------|:-----------------------------|:--------|
| **Managed** | Server-managed, plist/registry, or `managed-settings.json`   | All users on machine         | Yes (IT) |
| **User**    | `~/.claude/settings.json`                                    | You, across all projects     | No      |
| **Project** | `.claude/settings.json`                                      | All collaborators            | Yes (git) |
| **Local**   | `.claude/settings.local.json`                                | You, this project only       | No (gitignored) |

### Settings Precedence (highest to lowest)

1. **Managed** (server-managed > MDM/OS-level > `managed-settings.json`)
2. **Command line arguments**
3. **Local project** (`.claude/settings.local.json`)
4. **Shared project** (`.claude/settings.json`)
5. **User** (`~/.claude/settings.json`)

### Key Settings (`settings.json`)

| Key | Description |
|:----|:------------|
| `permissions` | Allow/ask/deny rules, `defaultMode`, `additionalDirectories`, `disableBypassPermissionsMode` |
| `hooks` | Custom commands at lifecycle events |
| `env` | Environment variables applied to every session |
| `model` | Override default model |
| `sandbox` | Sandbox config: `enabled`, `autoAllowBashIfSandboxed`, `excludedCommands`, `network.*` |
| `outputStyle` | Adjust system prompt style |
| `language` | Preferred response language |
| `apiKeyHelper` | Custom script for auth value generation |
| `statusLine` | Custom status line command |
| `fileSuggestion` | Custom `@` file autocomplete command |
| `attribution` | Customize git commit/PR attribution (`commit`, `pr`) |
| `companyAnnouncements` | Startup announcements for users |
| `availableModels` | Restrict models users can select via `/model` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) |
| `enabledPlugins` | Enable/disable plugins: `"name@marketplace": true/false` |
| `extraKnownMarketplaces` | Additional marketplace sources |

### Permission Modes

| Mode                | Description |
|:--------------------|:------------|
| `default`           | Standard: prompts for permission on first use |
| `acceptEdits`       | Auto-accepts file edit permissions for session |
| `plan`              | Read-only: Claude can analyze but not modify |
| `dontAsk`           | Auto-denies unless pre-approved via allow rules |
| `bypassPermissions` | Skips all prompts (isolated environments only) |

### Permission Rule Syntax

Rules follow `Tool` or `Tool(specifier)`. Evaluation order: **deny > ask > allow** (first match wins).

| Rule | Effect |
|:-----|:-------|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run` |
| `Bash(* --version)` | Matches commands ending with `--version` |
| `Read(./.env)` | Matches reading `.env` in current dir |
| `Edit(/src/**/*.ts)` | Edits in `<project>/src/` recursively |
| `Read(~/.zshrc)` | Reads home dir `.zshrc` |
| `Read(//Users/alice/secrets/**)` | Absolute path (note double `/`) |
| `WebFetch(domain:example.com)` | Matches fetch requests to domain |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `Task(Explore)` | Matches the Explore subagent |

**Path pattern types** (Read/Edit, follows gitignore spec):

| Pattern | Meaning |
|:--------|:--------|
| `//path` | Absolute from filesystem root |
| `~/path` | Relative to home directory |
| `/path` | Relative to project root |
| `path` or `./path` | Relative to current directory |

**Wildcard note**: `*` matches single directory level, `**` matches recursively.

### Managed-Only Settings

| Setting | Description |
|:--------|:------------|
| `disableBypassPermissionsMode` | Set to `"disable"` to prevent bypass mode |
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply |
| `allowManagedHooksOnly` | Only managed and SDK hooks allowed |
| `allowManagedMcpServersOnly` | Only managed MCP server allowlist applies |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `sandbox.network.allowManagedDomainsOnly` | Only managed domain allowlists apply |
| `strictKnownMarketplaces` | Allowlist of plugin marketplaces users can add |
| `allow_remote_sessions` | Allow/prevent remote and web sessions (default: `true`) |

### Managed Settings File Locations

| Platform    | Path |
|:------------|:-----|
| macOS       | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux / WSL | `/etc/claude-code/managed-settings.json` |
| Windows     | `C:\Program Files\ClaudeCode\managed-settings.json` |

### Server-Managed Settings

Delivered from Anthropic's servers via the Claude.ai admin console. Requires Teams or Enterprise plan and Claude Code v2.1.30+. Settings fetched at startup and polled hourly. Cached settings apply immediately on subsequent launches.

**Precedence**: Server-managed > endpoint-managed (MDM) > file-based managed settings. Only one managed source is used; sources do not merge.

**Security approval required for**: shell command settings, custom environment variables, hook configurations. Users must approve or Claude Code exits.

**Not available with**: Bedrock, Vertex AI, Foundry, or custom `ANTHROPIC_BASE_URL` endpoints.

### Sandbox Settings

| Key | Description |
|:----|:------------|
| `sandbox.enabled` | Enable bash sandboxing (default: `false`) |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: `true`) |
| `sandbox.excludedCommands` | Commands that run outside sandbox |
| `sandbox.allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch (default: `true`) |
| `sandbox.network.allowedDomains` | Domains for outbound traffic (supports `*.example.com`) |
| `sandbox.network.allowUnixSockets` | Unix socket paths accessible in sandbox |
| `sandbox.network.allowLocalBinding` | Allow binding to localhost (macOS only, default: `false`) |
| `sandbox.network.allowManagedDomainsOnly` | (Managed only) Restrict to managed domain allowlist |

### Tools Available to Claude

| Tool | Permission | Description |
|:-----|:-----------|:------------|
| `Bash` | Yes | Shell commands |
| `Read` | No | Read files |
| `Edit` / `Write` | Yes | Modify/create files |
| `Glob` / `Grep` | No | File pattern matching / content search |
| `WebFetch` / `WebSearch` | Yes | Fetch URLs / web search |
| `Task` | No | Run subagent |
| `Skill` | Yes | Execute a skill |
| `NotebookEdit` | Yes | Modify Jupyter cells |
| `LSP` | No | Code intelligence via language servers |

### Commonly Used Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key for model requests |
| `ANTHROPIC_MODEL` | Override model selection |
| `ANTHROPIC_BASE_URL` | Custom API endpoint |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable updates, telemetry, error reporting |
| `MAX_THINKING_TOKENS` | Override thinking token budget (0 to disable) |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Context % (1-100) at which auto-compaction triggers |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server configuration |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) — configuration scopes, settings.json options, permission settings, sandbox settings, attribution, environment variables, tools reference, and bash tool behavior
- [Configure Permissions](references/claude-code-permissions.md) — permission system, modes, rule syntax, tool-specific rules (Bash/Read/Edit/WebFetch/MCP/Task), working directories, sandboxing interaction, and managed-only settings
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) — centralized configuration via Claude.ai admin console, delivery mechanism, caching, security approval dialogs, and platform availability

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
