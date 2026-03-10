---
name: settings-doc
description: Complete documentation for Claude Code settings, permissions, and server-managed settings -- configuration scopes (managed/user/project/local), settings.json structure, available settings keys, permission system (modes, rule syntax, tool-specific rules, wildcard patterns, Read/Edit/WebFetch/MCP/Agent rules), sandbox settings (filesystem/network isolation, path prefixes, domain allowlists), environment variables, plugin configuration, attribution settings, file suggestion settings, hook configuration, settings precedence, managed-only settings (disableBypassPermissionsMode, allowManagedPermissionRulesOnly, allowManagedHooksOnly, allowManagedMcpServersOnly), server-managed settings (delivery, caching, security dialogs, audit logging), and tools available to Claude. Load when discussing Claude Code configuration, settings.json, permissions, permission rules, allow/deny/ask rules, permission modes, sandbox configuration, managed settings, server-managed settings, environment variables, working directories, or the /config command.
user-invocable: false
---

# Settings, Permissions & Configuration Documentation

This skill provides the complete official documentation for Claude Code settings files, permission system, sandbox configuration, environment variables, and server-managed settings.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared with team? |
|:------|:---------|:---------------|:-------------------|
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | All users on the machine | Yes (deployed by IT) |
| **User** | `~/.claude/` directory | You, across all projects | No |
| **Project** | `.claude/` in repository | All collaborators | Yes (committed to git) |
| **Local** | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |

### Settings Files

| Scope | File |
|:------|:-----|
| User | `~/.claude/settings.json` |
| Project (shared) | `.claude/settings.json` |
| Project (local) | `.claude/settings.local.json` |
| Managed (server) | Delivered from Anthropic servers via Claude.ai admin console |
| Managed (macOS) | `com.anthropic.claudecode` plist or `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Managed (Linux/WSL) | `/etc/claude-code/managed-settings.json` |
| Managed (Windows) | `HKLM\SOFTWARE\Policies\ClaudeCode` registry or `C:\Program Files\ClaudeCode\managed-settings.json` |
| Other config | `~/.claude.json` (preferences, OAuth, MCP servers, per-project state) |

JSON schema for validation: `https://json.schemastore.org/claude-code-settings.json`

### Settings Precedence (highest to lowest)

1. **Managed settings** (server-managed > MDM/OS-level > `managed-settings.json` > HKCU registry). Cannot be overridden by anything, including CLI arguments. Only one managed source is used; they do not merge.
2. **Command line arguments** -- temporary session overrides
3. **Local project settings** (`.claude/settings.local.json`)
4. **Shared project settings** (`.claude/settings.json`)
5. **User settings** (`~/.claude/settings.json`)

Array-valued settings (e.g. `permissions.allow`, `sandbox.filesystem.allowWrite`) are **concatenated and deduplicated** across scopes, not replaced.

### Available Settings (Key Fields)

| Key | Description |
|:----|:------------|
| `permissions` | Allow/ask/deny rules, `defaultMode`, `additionalDirectories`, `disableBypassPermissionsMode` |
| `hooks` | Lifecycle hook definitions (see hooks-doc) |
| `env` | Environment variables applied to every session |
| `model` | Override default model |
| `availableModels` | Restrict selectable models via `/model` |
| `sandbox` | Sandbox config: `enabled`, `autoAllowBashIfSandboxed`, `excludedCommands`, filesystem/network rules |
| `attribution` | Customize git commit/PR attribution (`commit`, `pr` keys) |
| `outputStyle` | Adjust system prompt style |
| `language` | Preferred response language |
| `companyAnnouncements` | Startup announcements for users |
| `statusLine` | Custom status line command |
| `fileSuggestion` | Custom `@` file autocomplete command |
| `enabledPlugins` | Enable/disable plugins (`"name@marketplace": true/false`) |
| `extraKnownMarketplaces` | Additional marketplace sources for the repository |
| `apiKeyHelper` | Script to generate auth value |
| `forceLoginMethod` | Restrict login to `claudeai` or `console` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) |
| `defaultMode` | Default permission mode |
| `includeGitInstructions` | Include built-in git workflow instructions (default: `true`) |
| `disableAllHooks` | Disable all hooks and custom status line |
| `showTurnDuration` | Show turn duration after responses |
| `spinnerVerbs` | Customize spinner action verbs |
| `alwaysThinkingEnabled` | Enable extended thinking by default |
| `teammateMode` | Agent team display: `auto`, `in-process`, or `tmux` |

### Permission System

Rules are evaluated in order: **deny > ask > allow**. The first matching rule wins.

#### Permission Modes

| Mode | Description |
|:-----|:------------|
| `default` | Prompts for permission on first use of each tool |
| `acceptEdits` | Auto-accepts file edit permissions for the session |
| `plan` | Analyze only, no file modifications or command execution |
| `dontAsk` | Auto-denies tools unless pre-approved via `/permissions` or `permissions.allow` |
| `bypassPermissions` | Skips all prompts (containers/VMs only; can be disabled by managed settings) |

#### Permission Rule Syntax

Format: `Tool` or `Tool(specifier)`. `Bash(*)` is equivalent to `Bash`.

| Rule | Effect |
|:-----|:-------|
| `Bash(npm run *)` | Matches commands starting with `npm run ` |
| `Bash(* --version)` | Matches commands ending with ` --version` |
| `Read(./.env)` | Matches reading `.env` in current directory |
| `Edit(/src/**/*.ts)` | Edits in `<project>/src/` recursively |
| `Read(~/.zshrc)` | Reads home directory `.zshrc` |
| `Read(//Users/alice/secrets/**)` | Absolute path (note `//` prefix) |
| `WebFetch(domain:example.com)` | Matches fetch requests to example.com |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `mcp__puppeteer` | All tools from puppeteer server |
| `Agent(Explore)` | Matches the Explore subagent |

**Read/Edit path prefixes** follow gitignore spec: `//path` = absolute, `~/path` = home, `/path` = project root, `path` or `./path` = current directory. `*` matches within one directory, `**` matches recursively.

**Bash wildcard note**: space before `*` matters. `Bash(ls *)` matches `ls -la` but not `lsof`. `Bash(ls*)` matches both.

### Sandbox Settings

| Key | Description |
|:----|:------------|
| `sandbox.enabled` | Enable bash sandboxing (default: false) |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `sandbox.excludedCommands` | Commands that run outside sandbox |
| `sandbox.allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch (default: true) |
| `sandbox.filesystem.allowWrite` | Additional writable paths (merged across scopes) |
| `sandbox.filesystem.denyWrite` | Paths where writes are blocked |
| `sandbox.filesystem.denyRead` | Paths where reads are blocked |
| `sandbox.network.allowedDomains` | Allowed outbound domains (supports `*.example.com`) |
| `sandbox.network.allowLocalBinding` | Allow binding to localhost (macOS only) |
| `sandbox.network.allowUnixSockets` | Unix socket paths accessible in sandbox |
| `sandbox.network.allowManagedDomainsOnly` | (Managed only) Ignore non-managed domain allowlists |

**Sandbox path prefixes**: `//` = absolute, `~/` = home, `/` = relative to settings file directory, `./` = relative.

### Managed-Only Settings

These settings only take effect in managed settings:

| Setting | Description |
|:--------|:------------|
| `disableBypassPermissionsMode` | `"disable"` prevents `bypassPermissions` mode and `--dangerously-skip-permissions` |
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply |
| `allowManagedHooksOnly` | Only managed and SDK hooks are loaded |
| `allowManagedMcpServersOnly` | Only managed MCP server allowlist applies |
| `blockedMarketplaces` | Blocklist of marketplace sources (checked before download) |
| `strictKnownMarketplaces` | Allowlist of marketplaces users can add |
| `sandbox.network.allowManagedDomainsOnly` | Only managed domain allowlists apply |
| `allow_remote_sessions` | Allow Remote Control and web sessions (default: true) |

### Server-Managed Settings

Centrally configure Claude Code through the Claude.ai admin console without MDM infrastructure. Settings are delivered from Anthropic's servers at authentication time.

**Requirements**: Claude for Teams or Enterprise plan, Claude Code v2.1.38+ (Teams) or v2.1.30+ (Enterprise), network access to `api.anthropic.com`.

**Delivery**: fetched at startup, polled hourly. Cached settings apply immediately on subsequent launches. When both server-managed and endpoint-managed settings are present, server-managed takes precedence.

**Security dialogs**: Shell commands, custom env vars, and hook configs in managed settings require user approval. In non-interactive (`-p`) mode, dialogs are skipped.

**Access control**: only Primary Owner and Owner roles can manage settings.

**Limitations (beta)**: settings apply uniformly to all users (no per-group); MCP server configs cannot be distributed via server-managed settings.

**Not available with**: Bedrock, Vertex AI, Foundry, custom API endpoints, or LLM gateways.

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key for Claude SDK |
| `ANTHROPIC_MODEL` | Override model selection |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry collection |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Max output tokens (default: 32000, max: 64000) |
| `MAX_THINKING_TOKENS` | Override thinking token budget (0 to disable) |
| `CLAUDE_CODE_EFFORT_LEVEL` | `low`, `medium`, `high` effort for supported models |
| `CLAUDE_CODE_SHELL` | Override shell detection |
| `CLAUDE_ENV_FILE` | Path to shell script sourced before each bash command |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable autoupdater, bug reports, error reporting, telemetry |
| `CLAUDE_CODE_DISABLE_FAST_MODE` | Disable fast mode |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_SIMPLE` | Minimal system prompt, basic tools only |
| `DISABLE_AUTOUPDATER` | Disable automatic updates |
| `DISABLE_TELEMETRY` | Opt out of Statsig telemetry |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server for network connections |
| `MCP_TIMEOUT` | MCP server startup timeout (ms) |
| `MCP_TOOL_TIMEOUT` | MCP tool execution timeout (ms) |

### Tools Available to Claude

| Tool | Description | Permission |
|:-----|:------------|:-----------|
| Agent | Spawns a subagent | No |
| Bash | Shell command execution | Yes |
| Edit | Targeted file edits | Yes |
| Write | Create/overwrite files | Yes |
| Read | Read file contents | No |
| Glob | Pattern-based file search | No |
| Grep | Pattern search in file contents | No |
| WebFetch | Fetch URL content | Yes |
| WebSearch | Web search | Yes |
| Skill | Execute a skill | Yes |
| NotebookEdit | Modify Jupyter cells | Yes |
| LSP | Code intelligence via language servers | No |
| TaskCreate/TaskList/TaskUpdate/TaskGet | Task tracking | No |
| CronCreate/CronDelete/CronList | Scheduled tasks | No |
| ToolSearch | Search and load deferred MCP tools | No |

### Bash Tool Behavior

- **Working directory persists** across commands
- **Environment variables do NOT persist** between commands (each runs in a fresh shell)
- To persist env vars: activate before starting Claude, set `CLAUDE_ENV_FILE`, or use a `SessionStart` hook writing to `$CLAUDE_ENV_FILE`

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) -- configuration scopes, settings.json structure, all available settings keys, permission settings, sandbox settings, attribution, file suggestion, hook configuration, settings precedence, plugin configuration, environment variables, tools available to Claude, and bash tool behavior
- [Configure permissions](references/claude-code-permissions.md) -- permission system, permission modes, rule syntax (Bash/Read/Edit/WebFetch/MCP/Agent), wildcard patterns, tool-specific rules, working directories, managed-only settings, settings precedence, and example configurations
- [Server-managed settings](references/claude-code-server-managed-settings.md) -- centralized configuration via Claude.ai admin console, requirements, delivery and caching, security dialogs, access control, platform availability, audit logging, and security considerations

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
