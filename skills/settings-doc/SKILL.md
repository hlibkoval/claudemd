---
name: settings-doc
description: Complete documentation for Claude Code settings, permissions, and server-managed settings -- configuration scopes (managed/user/project/local), settings.json fields, permission system (modes, rule syntax, tool-specific rules for Bash/Read/Edit/WebFetch/MCP/Agent), sandbox settings, environment variables, available tools, managed-only settings, server-managed settings delivery, and settings precedence. Load when discussing Claude Code configuration, permissions, allow/deny rules, environment variables, sandbox setup, or enterprise managed settings.
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, and server-managed settings.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared? |
|:------|:---------|:---------------|:--------|
| Managed | Server-managed, plist/registry, or `managed-settings.json` | All users on machine | Yes (deployed by IT) |
| User | `~/.claude/` | You, across all projects | No |
| Project | `.claude/` in repo | All collaborators | Yes (committed to git) |
| Local | `.claude/*.local.*` files | You, in this repo only | No (gitignored) |

### Settings Files

| Level | File |
|:------|:-----|
| User | `~/.claude/settings.json` |
| Project (shared) | `.claude/settings.json` |
| Project (local) | `.claude/settings.local.json` |
| Managed (server) | Via Claude.ai admin console |
| Managed (macOS plist) | `com.anthropic.claudecode` managed preferences |
| Managed (Windows reg) | `HKLM\SOFTWARE\Policies\ClaudeCode` |
| Managed (file, macOS) | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Managed (file, Linux) | `/etc/claude-code/managed-settings.json` |
| Other config | `~/.claude.json` (preferences, OAuth, MCP servers, caches) |

### Settings Precedence (highest to lowest)

1. **Managed settings** (server-managed > MDM/plist > managed-settings.json)
2. **Command line arguments**
3. **Local project** (`.claude/settings.local.json`)
4. **Shared project** (`.claude/settings.json`)
5. **User** (`~/.claude/settings.json`)

Array settings (e.g., `permissions.allow`, `sandbox.filesystem.allowWrite`) merge (concatenate + deduplicate) across scopes rather than replacing.

### Key settings.json Fields

| Key | Description |
|:----|:------------|
| `permissions` | Allow/ask/deny rules, `defaultMode`, `additionalDirectories`, `disableBypassPermissionsMode` |
| `hooks` | Lifecycle event hooks |
| `env` | Environment variables applied to every session |
| `model` | Override default model |
| `availableModels` | Restrict selectable models |
| `sandbox` | Sandbox configuration (see Sandbox Settings below) |
| `apiKeyHelper` | Script to generate auth value |
| `companyAnnouncements` | Startup announcements for users |
| `attribution` | Customize git commit / PR attribution |
| `outputStyle` | System prompt style adjustment |
| `language` | Preferred response language |
| `forceLoginMethod` | Restrict to `claudeai` or `console` login |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) |
| `enabledPlugins` | `"plugin@marketplace": true/false` |
| `extraKnownMarketplaces` | Additional marketplace sources for the repo |
| `fileSuggestion` | Custom `@` file autocomplete command |
| `statusLine` | Custom status line command |
| `alwaysThinkingEnabled` | Enable extended thinking by default |
| `cleanupPeriodDays` | Session cleanup period (default: 30) |
| `teammateMode` | Agent team display: `auto`, `in-process`, or `tmux` |
| `fastModePerSessionOptIn` | Require per-session fast mode opt-in |

### Permission System

**Permission modes** (set via `defaultMode` in settings or `/config`):

| Mode | Description |
|:-----|:------------|
| `default` | Standard prompts on first use |
| `acceptEdits` | Auto-accept file edit permissions |
| `plan` | Read-only analysis, no modifications |
| `dontAsk` | Auto-deny unless pre-approved via allow rules |
| `bypassPermissions` | Skip all prompts (isolated environments only) |

**Rule evaluation order:** deny > ask > allow (first match wins).

**Rule syntax:** `Tool` or `Tool(specifier)`

| Rule | Effect |
|:-----|:-------|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Glob wildcard; space before `*` enforces word boundary |
| `Read(./.env)` | Matches reading `.env` in current dir |
| `Edit(/src/**/*.ts)` | Gitignore-style path relative to project root |
| `Read(//Users/alice/secrets/**)` | Absolute path (note `//` prefix) |
| `Read(~/Documents/*.pdf)` | Home-relative path |
| `WebFetch(domain:example.com)` | Domain match for web fetches |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `mcp__puppeteer` | All tools from an MCP server |
| `Agent(Explore)` | Specific subagent |

**Read/Edit path prefixes:**

| Prefix | Meaning |
|:-------|:--------|
| `//path` | Absolute from filesystem root |
| `~/path` | Relative to home directory |
| `/path` | Relative to project root |
| `path` or `./path` | Relative to current directory |

### Sandbox Settings

Configured under `sandbox` key in settings.json:

| Key | Description |
|:----|:------------|
| `enabled` | Enable bash sandboxing (default: false) |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `excludedCommands` | Commands that bypass sandbox |
| `allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch (default: true) |
| `filesystem.allowWrite` | Additional writable paths |
| `filesystem.denyWrite` | Blocked write paths |
| `filesystem.denyRead` | Blocked read paths |
| `network.allowedDomains` | Allowed outbound domains (supports wildcards) |
| `network.allowUnixSockets` | Allowed Unix socket paths |
| `network.allowLocalBinding` | Allow binding to localhost (macOS only) |
| `network.allowManagedDomainsOnly` | (Managed only) Restrict domains to managed allowlist |

Sandbox path prefixes: `//` = absolute, `~/` = home, `/` = relative to settings file dir, `./` = relative.

### Managed-Only Settings

These settings are only effective in managed settings:

| Setting | Description |
|:--------|:------------|
| `disableBypassPermissionsMode` | Set to `"disable"` to prevent bypass mode |
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply |
| `allowManagedHooksOnly` | Only managed and SDK hooks allowed |
| `allowManagedMcpServersOnly` | Only managed MCP server allowlist applies |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `sandbox.network.allowManagedDomainsOnly` | Only managed domain allowlist applies |
| `strictKnownMarketplaces` | Allowlist of permitted plugin marketplaces |
| `allow_remote_sessions` | Allow Remote Control and web sessions (default: true) |

### Server-Managed Settings

Delivered from Anthropic's servers via Claude.ai admin console. Requirements: Claude for Teams/Enterprise, Claude Code >= 2.1.38 (Teams) or >= 2.1.30 (Enterprise), network access to `api.anthropic.com`.

**Delivery:** fetched at startup + hourly polling. Cached settings apply immediately on subsequent launches. When both server-managed and endpoint-managed settings exist, server-managed takes precedence.

**Security dialogs required for:** shell command settings, custom env vars, hook configurations. Users must approve or Claude Code exits (skipped in non-interactive `-p` mode).

**Not available with:** Bedrock, Vertex AI, Microsoft Foundry, custom `ANTHROPIC_BASE_URL`.

**Current limitations:** settings apply uniformly (no per-group config); MCP servers cannot be distributed via server-managed settings.

### Available Tools

| Tool | Permission | Description |
|:-----|:-----------|:------------|
| Read | No | Read file contents |
| Glob | No | Find files by pattern |
| Grep | No | Search file contents |
| Bash | Yes | Execute shell commands |
| Edit | Yes | Targeted file edits |
| Write | Yes | Create/overwrite files |
| NotebookEdit | Yes | Modify Jupyter cells |
| WebFetch | Yes | Fetch URL content |
| WebSearch | Yes | Web search with domain filtering |
| Agent | No | Run subagent for complex tasks |
| Skill | Yes | Execute a skill |
| LSP | No | Code intelligence via language servers |
| AskUserQuestion | No | Multiple-choice questions |
| TaskCreate/List/Get/Update | No | Task management |
| TaskOutput | No | Retrieve background task output |
| KillShell | No | Kill background bash shell |
| MCPSearch | No | Search/load MCP tools |
| ExitPlanMode | Yes | Prompt user to exit plan mode |

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key for Claude SDK |
| `ANTHROPIC_MODEL` | Override default model |
| `CLAUDE_CODE_USE_BEDROCK` | Use AWS Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Max output tokens |
| `BASH_DEFAULT_TIMEOUT_MS` | Bash command timeout |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout |
| `BASH_MAX_OUTPUT_LENGTH` | Max bash output length |
| `MCP_TIMEOUT` | MCP server timeout |
| `MCP_TOOL_TIMEOUT` | MCP tool execution timeout |
| `MAX_THINKING_TOKENS` | Max extended thinking tokens |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | Disable background tasks |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level |
| `CLAUDE_CODE_SHELL` | Override shell used for Bash |
| `CLAUDE_CONFIG_DIR` | Override config directory |
| `DISABLE_AUTOUPDATER` | Disable auto-updates |
| `HTTP_PROXY` / `HTTPS_PROXY` / `NO_PROXY` | Proxy configuration |

All environment variables can also be set via the `env` key in `settings.json`.

### Bash Tool Behavior

- Working directory persists across commands
- Environment variables do NOT persist between commands (each runs in fresh shell)
- To persist env vars: (1) activate before starting Claude, (2) set `CLAUDE_ENV_FILE`, or (3) use a `SessionStart` hook writing to `$CLAUDE_ENV_FILE`

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) -- configuration scopes, settings.json fields, permission settings, sandbox settings, plugin configuration, environment variables, available tools, and bash tool behavior
- [Configure Permissions](references/claude-code-permissions.md) -- permission system, modes, rule syntax, tool-specific rules (Bash/Read/Edit/WebFetch/MCP/Agent), working directories, sandboxing interaction, managed-only settings, and settings precedence
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) -- server-delivered configuration for Teams/Enterprise, setup, delivery behavior, caching, security dialogs, platform availability, and security considerations

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
