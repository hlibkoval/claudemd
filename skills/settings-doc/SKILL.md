---
name: settings-doc
description: Complete documentation for Claude Code settings and permissions -- configuration scopes (managed, user, project, local), settings.json schema and all available settings keys, settings precedence (managed > CLI > local > project > user), settings files and their locations (server-managed, MDM/plist/registry, managed-settings.json, user settings, project settings, local project settings), the /config command, permission system (allow/ask/deny rules, evaluation order), permission modes (default, acceptEdits, plan, dontAsk, bypassPermissions), permission rule syntax (Tool, Tool(specifier), wildcards, gitignore-style path patterns for Read/Edit, WebFetch domain rules, MCP tool patterns, Agent rules), sandbox settings (enabled, filesystem allow/deny, network allowedDomains, excludedCommands, path prefixes), managed-only settings (disableBypassPermissionsMode, allowManagedPermissionRulesOnly, allowManagedHooksOnly, allowManagedMcpServersOnly, blockedMarketplaces, strictKnownMarketplaces, allow_remote_sessions, sandbox.network.allowManagedDomainsOnly), server-managed settings (public beta, Claude.ai admin console, fetch/caching behavior, security approval dialogs, platform availability, audit logging), environment variables (ANTHROPIC_MODEL, ANTHROPIC_BASE_URL, CLAUDE_CODE_USE_BEDROCK/VERTEX, CLAUDE_ENV_FILE, DISABLE_AUTOUPDATER, etc.), tool reference (Bash, Read, Edit, Write, Glob, Grep, Agent, WebFetch, WebSearch, MCP tools, LSP, NotebookEdit, Skill, Task tools), Bash tool behavior (working directory persistence, env var non-persistence, CLAUDE_ENV_FILE, SessionStart hooks), attribution settings, hook configuration settings, file suggestion settings, plugin settings (enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces), subagent configuration, array merging across scopes, /status command for verifying settings, excluding sensitive files. Load when discussing Claude Code settings, configuration, permissions, settings.json, permission rules, allow/deny rules, permission modes, managed settings, server-managed settings, enterprise deployment, sandbox configuration, environment variables, tool permissions, working directories, settings precedence, /config, /permissions, /status, MDM deployment, or any Claude Code configuration topic.
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, and server-managed settings.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared? |
|:------|:---------|:---------------|:--------|
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | All users on the machine | Yes (deployed by IT) |
| **User** | `~/.claude/settings.json` | You, across all projects | No |
| **Project** | `.claude/settings.json` | All collaborators | Yes (committed to git) |
| **Local** | `.claude/settings.local.json` | You, this project only | No (gitignored) |

Other config: `~/.claude.json` stores preferences (theme, notifications, editor mode), OAuth session, MCP servers (user/local scope), per-project state, and caches. Project-scoped MCP servers go in `.mcp.json`.

### Settings Precedence (highest to lowest)

1. **Managed settings** -- cannot be overridden, including by CLI args
   - Within managed tier: server-managed > MDM/OS-level > `managed-settings.json` > HKCU registry (Windows). Only one managed source is used; they do not merge.
2. **Command line arguments** -- temporary session overrides
3. **Local project settings** (`.claude/settings.local.json`)
4. **Shared project settings** (`.claude/settings.json`)
5. **User settings** (`~/.claude/settings.json`)

Array settings (e.g., `permissions.allow`, `sandbox.filesystem.allowWrite`) merge (concatenate + deduplicate) across scopes rather than replacing.

### Managed Settings Delivery Mechanisms

| Mechanism | Best for |
|:----------|:---------|
| **Server-managed** (Claude.ai admin console) | Orgs without MDM, unmanaged devices |
| **MDM/OS-level** (macOS plist, Windows registry) | Orgs with MDM/endpoint management |
| **File-based** (`managed-settings.json`) | macOS: `/Library/Application Support/ClaudeCode/`, Linux/WSL: `/etc/claude-code/`, Windows: `C:\Program Files\ClaudeCode\` |

### Available Settings (settings.json)

| Key | Description |
|:----|:------------|
| `apiKeyHelper` | Script to generate auth value for `X-Api-Key` / `Authorization: Bearer` headers |
| `cleanupPeriodDays` | Days before inactive sessions are deleted at startup (default: 30, 0 = delete all) |
| `companyAnnouncements` | Array of strings displayed at startup (randomly cycled) |
| `env` | Environment variables applied to every session |
| `attribution` | Customize git commit/PR attribution (`commit`, `pr` keys; empty string hides) |
| `includeCoAuthoredBy` | Deprecated: use `attribution`. Include co-authored-by in commits (default: true) |
| `includeGitInstructions` | Include built-in git workflow instructions in system prompt (default: true) |
| `permissions` | Permission rules (allow/ask/deny), additionalDirectories, defaultMode, disableBypassPermissionsMode |
| `hooks` | Lifecycle hook configuration (see hooks-doc skill) |
| `disableAllHooks` | Disable all hooks and custom status line |
| `allowManagedHooksOnly` | (Managed only) Block user/project/plugin hooks |
| `allowedHttpHookUrls` | URL patterns HTTP hooks may target (`*` wildcard). Merges across scopes |
| `httpHookAllowedEnvVars` | Env var names HTTP hooks may interpolate into headers. Merges across scopes |
| `allowManagedPermissionRulesOnly` | (Managed only) Block user/project permission rules |
| `allowManagedMcpServersOnly` | (Managed only) Only admin-defined MCP allowlist applies |
| `model` | Override default model |
| `availableModels` | Restrict models selectable via `/model`, `--model`, Config tool |
| `modelOverrides` | Map Anthropic model IDs to provider-specific IDs (e.g., Bedrock ARNs) |
| `otelHeadersHelper` | Script for dynamic OpenTelemetry headers |
| `statusLine` | Custom status line command |
| `fileSuggestion` | Custom `@` file autocomplete command (receives `{"query":"..."}` on stdin) |
| `respectGitignore` | Whether `@` file picker respects .gitignore (default: true) |
| `outputStyle` | Output style name to adjust system prompt |
| `forceLoginMethod` | `claudeai` or `console` to restrict login method |
| `forceLoginOrgUUID` | Auto-select org during login (requires forceLoginMethod) |
| `enableAllProjectMcpServers` | Auto-approve all project `.mcp.json` MCP servers |
| `enabledMcpjsonServers` | Specific MCP servers from `.mcp.json` to approve |
| `disabledMcpjsonServers` | Specific MCP servers from `.mcp.json` to reject |
| `allowedMcpServers` | (Managed) MCP server allowlist |
| `deniedMcpServers` | (Managed) MCP server denylist (takes precedence over allowlist) |
| `strictKnownMarketplaces` | (Managed) Marketplace allowlist |
| `blockedMarketplaces` | (Managed) Marketplace blocklist (checked before download) |
| `pluginTrustMessage` | (Managed) Custom message appended to plugin trust warning |
| `awsAuthRefresh` | Script to refresh AWS credentials |
| `awsCredentialExport` | Script outputting JSON with AWS credentials |
| `alwaysThinkingEnabled` | Enable extended thinking by default |
| `plansDirectory` | Where plan files are stored (default: `~/.claude/plans`) |
| `showTurnDuration` | Show turn duration messages (default: true) |
| `spinnerVerbs` | Custom spinner verbs (`mode`: `replace`/`append`, `verbs` array) |
| `language` | Claude's preferred response language |
| `autoUpdatesChannel` | `stable` (week-old, skip regressions) or `latest` (default) |
| `spinnerTipsEnabled` | Show tips in spinner (default: true) |
| `spinnerTipsOverride` | Custom spinner tips (`excludeDefault`, `tips` array) |
| `terminalProgressBarEnabled` | Terminal progress bar in supported terminals (default: true) |
| `prefersReducedMotion` | Reduce/disable UI animations for accessibility |
| `fastModePerSessionOptIn` | Require per-session `/fast` opt-in (default: false) |
| `teammateMode` | Agent team display: `auto`, `in-process`, or `tmux` |

Use `"$schema": "https://json.schemastore.org/claude-code-settings.json"` for editor autocomplete/validation.

### Permission System

| Tool type | Example | Approval required | "Yes, don't ask again" |
|:----------|:--------|:------------------|:-----------------------|
| Read-only | File reads, Grep | No | N/A |
| Bash commands | Shell execution | Yes | Permanently per project+command |
| File modification | Edit/write files | Yes | Until session end |

Rule evaluation order: **deny > ask > allow** (first match wins).

### Permission Modes

| Mode | Description |
|:-----|:------------|
| `default` | Prompts for permission on first use of each tool |
| `acceptEdits` | Auto-accepts file edit permissions for the session |
| `plan` | Claude can analyze but not modify files or execute commands |
| `dontAsk` | Auto-denies tools unless pre-approved via allow rules |
| `bypassPermissions` | Skips all prompts (containers/VMs only; disable with `disableBypassPermissionsMode`) |

### Permission Rule Syntax

Format: `Tool` or `Tool(specifier)`.

#### Bash rules

- `Bash` -- matches all Bash commands
- `Bash(npm run build)` -- exact command
- `Bash(npm run *)` -- wildcard (space before `*` enforces word boundary: `ls *` matches `ls -la` but not `lsof`)
- `Bash(* --version)` -- wildcard at start
- Claude is aware of shell operators; `Bash(safe-cmd *)` won't match `safe-cmd && other-cmd`

#### Read and Edit rules (gitignore-style paths)

| Pattern | Meaning | Example |
|:--------|:--------|:--------|
| `//path` | Absolute from filesystem root | `Read(//Users/alice/secrets/**)` |
| `~/path` | From home directory | `Read(~/Documents/*.pdf)` |
| `/path` | Relative to project root | `Edit(/src/**/*.ts)` |
| `path` or `./path` | Relative to current directory | `Read(*.env)` |

`*` matches files in a single directory; `**` matches recursively.

#### WebFetch rules

- `WebFetch(domain:example.com)` -- matches requests to that domain

#### MCP rules

- `mcp__puppeteer` -- all tools from puppeteer server
- `mcp__puppeteer__puppeteer_navigate` -- specific tool

#### Agent rules

- `Agent(Explore)`, `Agent(Plan)`, `Agent(my-custom-agent)` -- control subagent access

### Sandbox Settings

| Key | Description |
|:----|:------------|
| `sandbox.enabled` | Enable bash sandboxing (default: false) |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `sandbox.excludedCommands` | Commands that run outside sandbox |
| `sandbox.allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch (default: true) |
| `sandbox.filesystem.allowWrite` | Additional writable paths (merges across scopes + Edit allow rules) |
| `sandbox.filesystem.denyWrite` | Paths denied for writing (merges + Edit deny rules) |
| `sandbox.filesystem.denyRead` | Paths denied for reading (merges + Read deny rules) |
| `sandbox.network.allowedDomains` | Allowed outbound domains (supports `*.example.com`) |
| `sandbox.network.allowManagedDomainsOnly` | (Managed only) Only managed domains apply |
| `sandbox.network.allowUnixSockets` | Accessible Unix socket paths |
| `sandbox.network.allowAllUnixSockets` | Allow all Unix sockets (default: false) |
| `sandbox.network.allowLocalBinding` | Allow localhost port binding, macOS only (default: false) |
| `sandbox.network.httpProxyPort` | Custom HTTP proxy port |
| `sandbox.network.socksProxyPort` | Custom SOCKS5 proxy port |
| `sandbox.enableWeakerNestedSandbox` | Weaker sandbox for unprivileged Docker (Linux/WSL2, reduces security) |
| `sandbox.enableWeakerNetworkIsolation` | macOS: allow TLS trust service access for Go tools (reduces security) |

Sandbox path prefixes: `//` = absolute, `~/` = home, `/` = relative to settings file directory, `./` or bare = relative.

### Managed-Only Settings

These settings are effective only in managed settings (server-managed, MDM, or managed-settings.json):

| Setting | Description |
|:--------|:------------|
| `disableBypassPermissionsMode` | `"disable"` to prevent `bypassPermissions` mode and `--dangerously-skip-permissions` |
| `allowManagedPermissionRulesOnly` | Block user/project permission rules |
| `allowManagedHooksOnly` | Block user/project/plugin hooks |
| `allowManagedMcpServersOnly` | Only admin MCP allowlist applies |
| `blockedMarketplaces` | Marketplace blocklist (checked before download) |
| `strictKnownMarketplaces` | Marketplace allowlist |
| `sandbox.network.allowManagedDomainsOnly` | Only managed domains for network access |
| `allow_remote_sessions` | Allow Remote Control and web sessions (default: true) |

### Server-Managed Settings

Available for Claude for Teams and Claude for Enterprise (public beta). Requires Claude Code 2.1.38+ (Teams) or 2.1.30+ (Enterprise).

- Configure in Claude.ai: **Admin Settings > Claude Code > Managed settings**
- Clients fetch settings at startup, poll hourly
- Cached settings apply immediately on subsequent launches; persist through network failures
- Settings updates apply automatically without restart (except OTel config)
- Security approval dialogs required for shell commands, custom env vars, and hook configs
- In non-interactive mode (`-p` flag), security dialogs are skipped
- Not available with Bedrock, Vertex AI, Microsoft Foundry, or custom API endpoints
- Access: Primary Owner and Owner roles only
- Limitations: uniform for all org users (no per-group), no MCP server distribution

### Key Environment Variables

| Variable | Description |
|:---------|:------------|
| `ANTHROPIC_MODEL` | Override model selection |
| `ANTHROPIC_BASE_URL` | Custom API endpoint |
| `ANTHROPIC_AUTH_TOKEN` | Static auth token |
| `ANTHROPIC_API_KEY` | API key for authentication |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock (set to `1`) |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI (set to `1`) |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry (set to `1`) |
| `CLAUDE_ENV_FILE` | Script sourced before each Bash command |
| `CLAUDE_CODE_MAX_TOOL_TOKENS` | Max output tokens for tool results |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable non-essential network requests |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry tracing |
| `DISABLE_AUTOUPDATER` | Disable auto-updates |
| `FORCE_AUTOUPDATE_PLUGINS` | Keep plugin updates even when CLI updates disabled |
| `BASH_DEFAULT_TIMEOUT_MS` | Default timeout for bash commands |
| `BASH_MAX_OUTPUT_LENGTH` | Max characters in bash output before truncation |
| `BASH_MAX_TIMEOUT_MS` | Maximum allowed bash timeout |
| `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR` | Reset to project dir after each bash command (set to `1`) |

### Tool Reference

| Tool | Description | Requires approval |
|:-----|:------------|:------------------|
| Agent | Spawns a subagent | Yes |
| Bash | Executes shell commands | Yes |
| Edit | Modifies existing files | Yes |
| EnterWorktree | Creates and switches to a git worktree | No |
| ExitPlanMode | Presents plan and exits plan mode | Yes |
| ExitWorktree | Exits worktree session | No |
| Glob | Finds files by pattern | No |
| Grep | Searches file contents | No |
| ListMcpResourcesTool | Lists MCP server resources | No |
| LSP | Code intelligence via language servers | No |
| NotebookEdit | Modifies Jupyter notebook cells | Yes |
| Read | Reads file contents | No |
| ReadMcpResourceTool | Reads specific MCP resource by URI | No |
| Skill | Executes a skill | Yes |
| TaskCreate/Get/List/Output/Stop/Update | Task management tools | No |
| TodoWrite | Session task checklist (non-interactive/SDK) | No |
| ToolSearch | Searches deferred tools when tool search is enabled | No |
| WebFetch | Fetches URL content | Yes |
| WebSearch | Web searches | Yes |
| Write | Creates/overwrites files | Yes |

### Bash Tool Behavior

- Working directory persists between commands
- Environment variables do NOT persist between commands (each runs in fresh shell)
- Solutions for persistent env: (1) activate env before starting Claude, (2) set `CLAUDE_ENV_FILE` to a script sourced before each command, (3) use a SessionStart hook writing to `$CLAUDE_ENV_FILE`

### Useful Commands

| Command | Purpose |
|:--------|:--------|
| `/config` | Open Settings interface |
| `/permissions` | View/manage permission rules |
| `/status` | See active settings sources and origins |
| `/allowed-tools` | Configure tool permission rules |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) -- full settings reference: configuration scopes, all settings.json keys with descriptions and examples, permission settings, sandbox settings, attribution settings, file suggestion settings, hook configuration, settings precedence, plugin settings (enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces), subagent configuration, environment variables, tool reference, Bash tool behavior
- [Configure permissions](references/claude-code-permissions.md) -- permission system, permission modes, rule syntax (Bash wildcards, Read/Edit gitignore paths, WebFetch domains, MCP patterns, Agent rules), tool-specific rules, working directories, managed-only settings, permissions and sandboxing interaction, example configurations
- [Server-managed settings](references/claude-code-server-managed-settings.md) -- centralized configuration via Claude.ai admin console, requirements, server vs endpoint comparison, setup steps, settings delivery and caching, security approval dialogs, platform availability, access control, audit logging, security considerations

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
