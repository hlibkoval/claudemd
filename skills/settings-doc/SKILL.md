---
name: settings-doc
description: Complete documentation for Claude Code settings and configuration -- settings.json fields, configuration scopes (managed, user, project, local), settings precedence, permission system (modes, rule syntax, tool-specific rules for Bash/Read/Edit/WebFetch/MCP/Agent), sandbox settings, environment variables, managed settings (server-managed and endpoint-managed), managed-only settings, server-managed settings setup and delivery, attribution settings, file suggestion settings, hook configuration, plugin configuration, tools available to Claude, and Bash tool behavior. Load when discussing Claude Code configuration, settings.json, permissions, permission rules, permission modes, sandboxing settings, managed policies, server-managed settings, environment variables, or the /config and /permissions commands.
user-invocable: false
---

# Settings & Configuration Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, and server-managed settings.

## Quick Reference

Claude Code is configured through hierarchical JSON settings files, environment variables, and CLI flags. Settings follow a scope system with strict precedence: managed > CLI args > local > project > user.

### Configuration Scopes

| Scope | Location | Who it affects | Shared? |
|:------|:---------|:---------------|:--------|
| Managed | Server-managed, plist/registry, or `managed-settings.json` | All users on the machine | Yes (deployed by IT) |
| User | `~/.claude/settings.json` | You, across all projects | No |
| Project | `.claude/settings.json` | All collaborators | Yes (committed to git) |
| Local | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |

### Settings Precedence

1. **Managed** -- cannot be overridden (server-managed > MDM/OS policies > managed-settings.json)
2. **CLI arguments** -- temporary session overrides
3. **Local** (`.claude/settings.local.json`)
4. **Project** (`.claude/settings.json`)
5. **User** (`~/.claude/settings.json`)

Array settings (e.g., `permissions.allow`, `sandbox.filesystem.allowWrite`) merge across scopes -- they are concatenated and deduplicated, not replaced.

### Settings File Locations

| Type | Path |
|:-----|:-----|
| User settings | `~/.claude/settings.json` |
| Project settings (shared) | `.claude/settings.json` |
| Project settings (local) | `.claude/settings.local.json` |
| Managed (macOS) | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Managed (Linux/WSL) | `/etc/claude-code/managed-settings.json` |
| Managed (Windows) | `C:\Program Files\ClaudeCode\managed-settings.json` |
| MDM (macOS) | `com.anthropic.claudecode` managed preferences domain |
| MDM (Windows) | `HKLM\SOFTWARE\Policies\ClaudeCode` registry key |
| Other config | `~/.claude.json` (preferences, OAuth, MCP servers, caches) |

### Available Settings (settings.json)

| Key | Description |
|:----|:------------|
| `apiKeyHelper` | Script to generate auth value (sent as X-Api-Key and Bearer) |
| `cleanupPeriodDays` | Session cleanup threshold (default: 30) |
| `companyAnnouncements` | Startup announcements (cycled at random) |
| `env` | Environment variables applied to every session |
| `attribution` | Customize git commit/PR attribution (`commit`, `pr` subkeys) |
| `permissions` | Permission rules (`allow`, `ask`, `deny`, `additionalDirectories`, `defaultMode`, `disableBypassPermissionsMode`) |
| `hooks` | Hook configuration for lifecycle events |
| `disableAllHooks` | Disable all hooks and custom status line |
| `allowManagedHooksOnly` | (Managed only) Block user/project/plugin hooks |
| `allowedHttpHookUrls` | URL allowlist for HTTP hooks (supports `*` wildcard) |
| `httpHookAllowedEnvVars` | Env var allowlist for HTTP hook headers |
| `allowManagedPermissionRulesOnly` | (Managed only) Only managed permission rules apply |
| `allowManagedMcpServersOnly` | (Managed only) Only managed MCP allowlist applies |
| `model` | Override the default model |
| `availableModels` | Restrict which models users can select |
| `otelHeadersHelper` | Script for dynamic OpenTelemetry headers |
| `statusLine` | Custom status line configuration |
| `fileSuggestion` | Custom `@` file autocomplete command |
| `respectGitignore` | Whether `@` picker respects .gitignore (default: true) |
| `outputStyle` | Output style for system prompt adjustment |
| `forceLoginMethod` | Restrict login to `claudeai` or `console` |
| `forceLoginOrgUUID` | Auto-select org during login |
| `enableAllProjectMcpServers` | Auto-approve project MCP servers |
| `enabledMcpjsonServers` | Specific MCP servers to approve |
| `disabledMcpjsonServers` | Specific MCP servers to reject |
| `allowedMcpServers` | (Managed) MCP server allowlist |
| `deniedMcpServers` | (Managed) MCP server denylist |
| `strictKnownMarketplaces` | (Managed) Marketplace addition allowlist |
| `blockedMarketplaces` | (Managed) Marketplace blocklist |
| `pluginTrustMessage` | (Managed) Custom plugin trust warning message |
| `awsAuthRefresh` | Script modifying `.aws` dir for credential refresh |
| `awsCredentialExport` | Script outputting JSON with AWS credentials |
| `alwaysThinkingEnabled` | Enable extended thinking by default |
| `plansDirectory` | Where plan files are stored (default: `~/.claude/plans`) |
| `showTurnDuration` | Show turn duration after responses |
| `spinnerVerbs` | Customize spinner action verbs (`mode`, `verbs`) |
| `language` | Preferred response language |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) |
| `spinnerTipsEnabled` | Show spinner tips (default: true) |
| `spinnerTipsOverride` | Custom spinner tips (`tips`, `excludeDefault`) |
| `terminalProgressBarEnabled` | Terminal progress bar (default: true) |
| `prefersReducedMotion` | Reduce UI animations for accessibility |
| `fastModePerSessionOptIn` | Require per-session fast mode opt-in |
| `teammateMode` | Agent team display: `auto`, `in-process`, or `tmux` |

### Permission System

Rules are evaluated in order: **deny > ask > allow**. First matching rule wins.

#### Permission Modes

| Mode | Description |
|:-----|:------------|
| `default` | Prompts on first use of each tool |
| `acceptEdits` | Auto-accepts file edit permissions for session |
| `plan` | Analyze only -- no modifications or commands |
| `dontAsk` | Auto-denies unless pre-approved via rules |
| `bypassPermissions` | Skips all prompts (isolated environments only) |

#### Permission Rule Syntax

Format: `Tool` or `Tool(specifier)`

| Rule | Effect |
|:-----|:-------|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run` |
| `Read(./.env)` | Matches reading `.env` in current directory |
| `WebFetch(domain:example.com)` | Matches fetch to example.com |
| `Edit(/src/**/*.ts)` | Matches edits in project's `src/` recursively |
| `mcp__puppeteer__puppeteer_navigate` | Matches specific MCP tool |
| `Agent(Explore)` | Matches Explore subagent |

#### Read/Edit Path Patterns (gitignore spec)

| Pattern | Meaning | Example |
|:--------|:--------|:--------|
| `//path` | Absolute from filesystem root | `Read(//Users/alice/secrets/**)` |
| `~/path` | From home directory | `Read(~/Documents/*.pdf)` |
| `/path` | Relative to project root | `Edit(/src/**/*.ts)` |
| `path` or `./path` | Relative to current directory | `Read(*.env)` |

Note: `*` matches files in a single directory; `**` matches recursively.

#### Bash Wildcard Behavior

`Bash(ls *)` (space before `*`) enforces a word boundary -- matches `ls -la` but not `lsof`. `Bash(ls*)` matches both. Claude is aware of shell operators (`&&`) so prefix rules like `Bash(safe-cmd *)` will not permit `safe-cmd && other-cmd`.

### Sandbox Settings

Nested under `sandbox` in settings.json:

| Key | Description | Default |
|:----|:------------|:--------|
| `enabled` | Enable bash sandboxing | `false` |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed | `true` |
| `excludedCommands` | Commands that run outside sandbox | `[]` |
| `allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` param | `true` |
| `filesystem.allowWrite` | Additional writable paths (merged) | `[]` |
| `filesystem.denyWrite` | Paths blocked from writing (merged) | `[]` |
| `filesystem.denyRead` | Paths blocked from reading (merged) | `[]` |
| `network.allowedDomains` | Allowed outbound domains (wildcards ok) | `[]` |
| `network.allowManagedDomainsOnly` | (Managed) Only managed domain allowlist | `false` |
| `network.allowUnixSockets` | Unix socket paths for sandbox | `[]` |
| `network.allowAllUnixSockets` | Allow all Unix sockets | `false` |
| `network.allowLocalBinding` | Allow localhost binding (macOS) | `false` |
| `network.httpProxyPort` | Custom HTTP proxy port | -- |
| `network.socksProxyPort` | Custom SOCKS5 proxy port | -- |
| `enableWeakerNestedSandbox` | Weaker sandbox for Docker (Linux/WSL2) | `false` |
| `enableWeakerNetworkIsolation` | Allow macOS TLS trust service | `false` |

Sandbox path prefixes: `//` = absolute, `~/` = home, `/` = relative to settings file dir, `./` or none = relative.

### Managed-Only Settings

These settings only take effect in managed settings:

| Setting | Description |
|:--------|:------------|
| `disableBypassPermissionsMode` | Set to `"disable"` to prevent `bypassPermissions` mode |
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply |
| `allowManagedHooksOnly` | Only managed/SDK hooks allowed |
| `allowManagedMcpServersOnly` | Only managed MCP allowlist applies |
| `blockedMarketplaces` | Marketplace blocklist (checked before download) |
| `sandbox.network.allowManagedDomainsOnly` | Only managed domain allowlist applies |
| `strictKnownMarketplaces` | Marketplace addition allowlist |
| `allow_remote_sessions` | Allow Remote Control / web sessions (default: true) |

### Server-Managed Settings

Server-managed settings are delivered from Anthropic's servers via the Claude.ai admin console. Available for Teams and Enterprise plans.

**Requirements:** Teams/Enterprise plan, Claude Code >= 2.1.38 (Teams) or >= 2.1.30 (Enterprise), network access to `api.anthropic.com`.

**Setup:** Claude.ai > Admin Settings > Claude Code > Managed settings > define JSON > save.

**Delivery:** Fetched at startup and polled hourly. Cached settings apply immediately on subsequent launches.

**Precedence:** Server-managed and endpoint-managed settings share the highest tier. When both present, server-managed wins and endpoint-managed is not used.

**Security approval dialogs:** Shell command settings, custom env vars, and hook configs require user approval. In non-interactive mode (`-p` flag), dialogs are skipped.

**Limitations (beta):** Settings apply uniformly to all users (no per-group). MCP server configs cannot be distributed via server-managed settings.

**Not available with:** Bedrock, Vertex AI, Foundry, custom `ANTHROPIC_BASE_URL`, or LLM gateways.

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key for Claude SDK |
| `ANTHROPIC_AUTH_TOKEN` | Custom auth token (sent as Bearer) |
| `ANTHROPIC_MODEL` | Override model name |
| `ANTHROPIC_SMALL_FAST_MODEL` | Override small/fast model |
| `ANTHROPIC_BASE_URL` | Custom API base URL |
| `CLAUDE_CODE_USE_BEDROCK` | Set `1` to use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Set `1` to use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Set `1` to use Microsoft Foundry |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable automatic CLAUDE.md updates |
| `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` | Remove built-in git workflow instructions |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout |
| `BASH_MAX_TIMEOUT_MS` | Maximum bash command timeout |
| `BASH_MAX_OUTPUT_LENGTH` | Maximum bash output length |
| `MAX_THINKING_TOKENS` | Maximum extended thinking tokens |
| `MCP_TIMEOUT` | MCP server startup timeout |
| `MCP_TOOL_TIMEOUT` | MCP tool execution timeout |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy configuration |
| `NO_PROXY` | Proxy bypass list |
| `DISABLE_AUTOUPDATER` | Disable auto-updates |
| `DISABLE_TELEMETRY` | Disable telemetry |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level (`low`, `medium`, `high`) |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Override max output tokens |

### Tools Available to Claude

| Tool | Description | Permission |
|:-----|:------------|:-----------|
| AskUserQuestion | Multiple-choice questions | No |
| Bash | Shell commands | Yes |
| Edit | Targeted file edits | Yes |
| Read | Read file contents | No |
| Write | Create/overwrite files | Yes |
| Glob | Find files by pattern | No |
| Grep | Search file contents | No |
| WebFetch | Fetch URL content | Yes |
| WebSearch | Web search with domain filtering | Yes |
| Agent | Run sub-agent for complex tasks | No |
| Skill | Execute a skill | Yes |
| NotebookEdit | Modify Jupyter notebook cells | Yes |
| LSP | Code intelligence via language servers | No |
| TaskCreate/TaskGet/TaskList/TaskUpdate | Task management | No |
| TaskOutput | Retrieve background task output | No |
| KillShell | Kill background bash shell | No |
| MCPSearch | Search/load MCP tools | No |
| ExitPlanMode | Prompt user to exit plan mode | Yes |

### Bash Tool Behavior

- Working directory persists across commands
- Environment variables do NOT persist (each command runs in a fresh shell)
- Use `CLAUDE_ENV_FILE` to source an env setup script before each command
- Use `SessionStart` hooks to populate `$CLAUDE_ENV_FILE` for project-specific config
- Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to reset to project dir after each command

### Verify Active Settings

Run `/status` to see which settings sources are active and their origins (remote, plist, HKLM, file). `/permissions` shows effective permission rules.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) -- complete configuration reference: scopes, settings.json fields, permission settings, sandbox settings, attribution, file suggestion, hook configuration, plugin configuration, environment variables, tools available to Claude, Bash tool behavior
- [Configure permissions](references/claude-code-permissions.md) -- permission system, modes, rule syntax, tool-specific rules (Bash, Read, Edit, WebFetch, MCP, Agent), wildcard patterns, working directories, hooks integration, managed settings, settings precedence
- [Server-managed settings](references/claude-code-server-managed-settings.md) -- centralized configuration via Claude.ai admin console, setup steps, settings delivery and caching, security approval dialogs, access control, platform availability, audit logging, security considerations

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
