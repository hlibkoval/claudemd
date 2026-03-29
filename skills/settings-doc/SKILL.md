---
name: settings-doc
description: Complete documentation for Claude Code settings, permissions, permission modes, environment variables, and server-managed settings. Covers settings.json structure (available settings keys with descriptions, configuration scopes user/project/local/managed, settings precedence, managed settings delivery via server/MDM/file-based with drop-in directories, global config settings in ~/.claude.json, worktree settings symlinkDirectories/sparsePaths, permission settings allow/ask/deny/additionalDirectories/defaultMode/disableBypassPermissionsMode, permission rule syntax Tool(specifier) with wildcards for Bash/Read/Edit/WebFetch/MCP/Agent rules, sandbox settings enabled/filesystem allowWrite/denyWrite/denyRead/allowRead with path prefixes/network allowedDomains/allowUnixSockets/allowLocalBinding/httpProxyPort/socksProxyPort/excludedCommands/autoAllowBashIfSandboxed/failIfUnavailable/allowUnsandboxedCommands/enableWeakerNestedSandbox/enableWeakerNetworkIsolation, attribution settings commit/pr, file suggestion settings, hook configuration allowManagedHooksOnly/allowedHttpHookUrls/httpHookAllowedEnvVars, plugin configuration enabledPlugins/extraKnownMarketplaces/strictKnownMarketplaces with source types github/git/directory/hostPattern/url/npm/file/settings, subagent configuration), permissions system (tiered permission system read-only/bash/file-modification, /permissions management, permission modes default/acceptEdits/plan/auto/dontAsk/bypassPermissions, permission rule syntax with tool-specific rules for Bash wildcards/Read Edit gitignore patterns with //path ~/path /path ./path prefixes/WebFetch domain matching/MCP server and tool matching/Agent subagent rules, hooks extending permissions with PreToolUse/PermissionRequest, working directories --add-dir/additionalDirectories, permissions and sandboxing interaction, managed settings with managed-only settings allowManagedPermissionRulesOnly/allowManagedHooksOnly/allowManagedMcpServersOnly/allowedChannelPlugins/blockedMarketplaces/sandbox.network.allowManagedDomainsOnly/sandbox.filesystem.allowManagedReadPathsOnly/strictKnownMarketplaces, auto mode classifier configuration autoMode.environment/allow/soft_deny with prose rules and precedence and CLI commands auto-mode defaults/config/critique, settings precedence managed > CLI > local > project > user), permission modes (switching modes via Shift+Tab CLI/VS Code mode indicator/Desktop selector/Web dropdown, available modes comparison table, plan mode for research and proposals with /plan prefix, auto mode with classifier model on Sonnet 4.6 and Team plan requirement and cost/latency implications and action evaluation order and subagent handling and default blocks/allows and fallback behavior, dontAsk mode for pre-approved tools only, bypassPermissions mode for isolated environments with --dangerously-skip-permissions, permission approaches comparison table), environment variables (ANTHROPIC_API_KEY/ANTHROPIC_BASE_URL/ANTHROPIC_MODEL and model override variables, CLAUDE_CODE_* variables for features/behavior/telemetry/proxy/shell/effort/context/tasks/plugins/sandbox/auth, AWS/Bedrock/Vertex/Foundry variables, BASH_* timeout and output variables, DISABLE_* and ENABLE_* feature toggles, MCP_* timeout and OAuth variables, proxy variables HTTP_PROXY/HTTPS_PROXY/NO_PROXY, MAX_THINKING_TOKENS, CLAUDE_ENV_FILE, CLAUDE_CONFIG_DIR), server-managed settings (requirements Teams/Enterprise plan and version 2.1.30+, server vs endpoint managed settings comparison, admin console configuration at Claude.ai Admin Settings, settings delivery with precedence and fetch/caching behavior and security approval dialogs, access control Primary Owner/Owner roles, current limitations uniform settings only and no MCP server configs, platform availability not available with third-party providers, audit logging, security considerations with tamper scenarios). Load when discussing Claude Code settings, settings.json, configuration, permissions, permission rules, permission modes, auto mode, plan mode, bypassPermissions, dontAsk, managed settings, server-managed settings, environment variables, env vars, sandbox settings, sandbox configuration, sandbox filesystem, sandbox network, sandbox domains, working directories, settings precedence, settings scopes, managed-settings.json, MDM policies, /config, /permissions, /status, permission rule syntax, Bash permission patterns, Read/Edit permission patterns, WebFetch permissions, MCP permissions, Agent permissions, allow rules, deny rules, ask rules, autoMode configuration, auto mode classifier, trusted infrastructure, company announcements, attribution settings, file suggestion, hook configuration, allowManagedHooksOnly, allowedHttpHookUrls, strictKnownMarketplaces, extraKnownMarketplaces, enabledPlugins, plugin configuration, worktree settings, ANTHROPIC_API_KEY, ANTHROPIC_BASE_URL, ANTHROPIC_MODEL, CLAUDE_CODE_ENABLE_TELEMETRY, DISABLE_AUTOUPDATER, or any settings/permissions/env-vars topic for Claude Code.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, permission modes, environment variables, and server-managed settings.

## Quick Reference

### Settings File Locations

| Scope | File | Who it affects | Shared? |
|:------|:-----|:---------------|:--------|
| **Managed** | Server-managed, plist/registry, or `/etc/claude-code/managed-settings.json` (Linux) | All users | Yes (deployed by IT) |
| **User** | `~/.claude/settings.json` | You, across all projects | No |
| **Project** | `.claude/settings.json` | All collaborators | Yes (committed to git) |
| **Local** | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |

Managed settings file paths by OS: macOS `/Library/Application Support/ClaudeCode/`, Linux `/etc/claude-code/`, Windows `C:\Program Files\ClaudeCode\`. Drop-in directory `managed-settings.d/` merges alphabetically on top of `managed-settings.json`.

### Settings Precedence (Highest to Lowest)

1. **Managed** (server-managed > MDM/OS-level > file-based)
2. **Command line arguments**
3. **Local** (`.claude/settings.local.json`)
4. **Project** (`.claude/settings.json`)
5. **User** (`~/.claude/settings.json`)

Array settings (like `permissions.allow`, `sandbox.filesystem.allowWrite`) **merge** across scopes (concatenated and deduplicated), not replaced.

### Key settings.json Fields

| Key | Description |
|:----|:------------|
| `permissions` | `allow`, `ask`, `deny` arrays, `defaultMode`, `additionalDirectories`, `disableBypassPermissionsMode` |
| `autoMode` | `environment`, `allow`, `soft_deny` arrays of prose rules for auto mode classifier |
| `hooks` | Lifecycle event hooks (see hooks-doc) |
| `env` | Environment variables applied to every session |
| `model` | Override default model (e.g., `"claude-sonnet-4-6"`) |
| `availableModels` | Restrict models users can select via `/model` |
| `sandbox` | `enabled`, `filesystem.*`, `network.*`, `excludedCommands`, etc. |
| `outputStyle` | Adjust system prompt output style |
| `agent` | Run main thread as a named subagent |
| `language` | Claude's preferred response language |
| `apiKeyHelper` | Script to generate auth value |
| `companyAnnouncements` | Startup announcements for users |
| `attribution` | Customize git commit/PR attribution (`commit`, `pr` keys) |
| `statusLine` | Custom status line command |
| `fileSuggestion` | Custom `@` file autocomplete command |
| `cleanupPeriodDays` | Session retention period (default: 30) |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) |
| `effortLevel` | `"low"`, `"medium"`, `"high"` |
| `disableAutoMode` | `"disable"` to prevent auto mode |
| `disableAllHooks` | `true` to disable all hooks |
| `includeGitInstructions` | Include built-in git workflow instructions (default: `true`) |

### Permission Modes

| Mode | What Claude can do without asking | Best for |
|:-----|:----------------------------------|:---------|
| `default` | Read files | Getting started, sensitive work |
| `acceptEdits` | Read and edit files | Iterating on code you're reviewing |
| `plan` | Read files (no edits) | Exploring a codebase, planning |
| `auto` | All actions, with background safety checks | Long-running tasks, reducing prompts |
| `bypassPermissions` | All actions, no checks | Isolated containers/VMs only |
| `dontAsk` | Only pre-approved tools | Locked-down environments |

Switch modes: `Shift+Tab` (CLI), mode indicator (VS Code), mode selector (Desktop/Web), `--permission-mode <mode>` flag, or `defaultMode` in settings.

Auto mode requires Team plan + Claude Sonnet 4.6 or Opus 4.6. Classifier runs on Sonnet 4.6. Use `claude auto-mode defaults` / `config` / `critique` to inspect and customize.

### Permission Rule Syntax

Rules follow `Tool` or `Tool(specifier)` format. Evaluated: **deny > ask > allow** (first match wins).

| Rule | Effect |
|:-----|:-------|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run` |
| `Bash(npm run build)` | Exact command match |
| `Read(./.env)` | Matches reading `.env` in current directory |
| `Edit(/src/**/*.ts)` | Edits in `<project>/src/` recursively |
| `Read(~/.zshrc)` | Reads home directory `.zshrc` |
| `Read(//Users/alice/file)` | Absolute path (`//` prefix) |
| `WebFetch(domain:example.com)` | Fetch requests to domain |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `Agent(Explore)` | Matches the Explore subagent |

Read/Edit rules follow gitignore spec: `//path` = absolute, `~/path` = home, `/path` = project root, `path` or `./path` = current directory. `*` matches single directory, `**` matches recursively.

### Sandbox Settings

| Key | Description |
|:----|:------------|
| `sandbox.enabled` | Enable bash sandboxing (default: false) |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `sandbox.excludedCommands` | Commands that bypass the sandbox |
| `sandbox.failIfUnavailable` | Exit if sandbox cannot start |
| `sandbox.filesystem.allowWrite` | Additional writable paths |
| `sandbox.filesystem.denyWrite` | Blocked write paths |
| `sandbox.filesystem.denyRead` | Blocked read paths |
| `sandbox.filesystem.allowRead` | Re-allow reads within denyRead regions |
| `sandbox.network.allowedDomains` | Allowed outbound domains (supports wildcards) |
| `sandbox.network.allowLocalBinding` | Allow binding to localhost (macOS only) |
| `sandbox.network.allowUnixSockets` | Unix socket paths for sandbox |
| `sandbox.network.allowManagedDomainsOnly` | (Managed only) Only managed domains allowed |
| `sandbox.filesystem.allowManagedReadPathsOnly` | (Managed only) Only managed read paths |

Sandbox path prefixes: `/` = absolute, `~/` = home, `./` or no prefix = project root (project settings) or `~/.claude` (user settings).

### Managed-Only Settings

| Setting | Description |
|:--------|:------------|
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply |
| `allowManagedHooksOnly` | Only managed and SDK hooks load |
| `allowManagedMcpServersOnly` | Only managed MCP allowlist applies |
| `allowedChannelPlugins` | Allowlist of channel plugins |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `sandbox.network.allowManagedDomainsOnly` | Only managed domains for network |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed read paths |
| `strictKnownMarketplaces` | Allowlist of plugin marketplaces |
| `channelsEnabled` | Enable channels for Team/Enterprise |

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key (overrides subscription) |
| `ANTHROPIC_BASE_URL` | Override API endpoint (proxy/gateway) |
| `ANTHROPIC_MODEL` | Model setting to use |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry (`1`) |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable updates, telemetry, error reporting |
| `CLAUDE_CODE_SIMPLE` | Minimal system prompt, basic tools only (`1`) |
| `CLAUDE_CODE_EFFORT_LEVEL` | `low`, `medium`, `high`, `max`, or `auto` |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_SHELL` | Override shell detection |
| `CLAUDE_ENV_FILE` | Script sourced before each Bash command |
| `CLAUDE_CONFIG_DIR` | Custom config/data directory |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout |
| `MAX_THINKING_TOKENS` | Override thinking token budget |
| `DISABLE_AUTOUPDATER` | Disable auto-updates (`1`) |
| `DISABLE_TELEMETRY` | Opt out of Statsig telemetry (`1`) |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server for connections |
| `MCP_TIMEOUT` / `MCP_TOOL_TIMEOUT` | MCP server startup / tool execution timeout |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory (`1`) |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocesses (`1`) |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Enable agent teams (`1`) |

### Server-Managed Settings

- **Requirements**: Teams or Enterprise plan, Claude Code v2.1.30+ (Enterprise) or v2.1.38+ (Teams)
- **Configure**: Claude.ai > Admin Settings > Claude Code > Managed settings
- **Delivery**: fetched at startup, polled hourly, cached locally
- **Precedence**: highest tier (overrides all other settings including CLI args)
- **When both present**: server-managed takes precedence over endpoint-managed
- **Access control**: Primary Owner and Owner roles only
- **Security dialogs**: hooks, custom env vars, and shell commands require user approval (skipped in `-p` mode)
- **Limitations**: uniform for all users (no per-group), no MCP server configs
- **Not available with**: Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) -- Complete settings reference including configuration scopes (managed/user/project/local), settings.json structure with all available settings keys and examples, global config settings (~/.claude.json), worktree settings, permission settings with rule syntax, sandbox settings with filesystem/network configuration and path prefixes, attribution settings, file suggestion settings, hook configuration (allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars), settings precedence and merging behavior, plugin configuration (enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces with all source types), subagent configuration, /config and /status commands
- [Configure Permissions](references/claude-code-permissions.md) -- Permission system (tiered tool approval), /permissions management UI, permission modes overview, permission rule syntax (Tool and Tool(specifier) format, wildcard patterns, Bash/Read/Edit/WebFetch/MCP/Agent tool-specific rules), extending permissions with PreToolUse and PermissionRequest hooks, working directories (--add-dir, additionalDirectories), permissions and sandboxing interaction, managed settings with managed-only settings table, auto mode classifier configuration (autoMode.environment/allow/soft_deny, CLI commands defaults/config/critique), settings precedence for permissions
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) -- Server-managed settings overview (public beta, Teams/Enterprise), requirements and version compatibility, server vs endpoint managed settings comparison, admin console configuration steps with examples (permissions, hooks, autoMode), settings delivery (precedence, fetch/caching behavior, security approval dialogs), access control roles, current limitations, platform availability, audit logging, security considerations and tamper scenarios
- [Environment Variables](references/claude-code-env-vars.md) -- Complete reference for all environment variables: ANTHROPIC_* (API key, base URL, model, auth, custom headers, provider-specific), CLAUDE_CODE_* (features, behavior, telemetry, proxy, shell, effort, context, tasks, plugins, sandbox, auth, agent teams), AWS/Bedrock/Vertex/Foundry variables, BASH_* timeout and output limits, DISABLE_*/ENABLE_* feature toggles, MCP_* timeout and OAuth, proxy variables, MAX_THINKING_TOKENS, CLAUDE_ENV_FILE, CLAUDE_CONFIG_DIR
- [Permission Modes](references/claude-code-permission-modes.md) -- How to switch modes (Shift+Tab CLI, VS Code/Desktop/Web UI, --permission-mode flag, defaultMode setting), available modes comparison (default, acceptEdits, plan, auto, bypassPermissions, dontAsk), plan mode for research and proposals (/plan prefix, approval flow), auto mode details (Team plan requirement, Sonnet 4.6 classifier, cost/latency, action evaluation order, subagent handling, default blocks and allows, fallback behavior), dontAsk for pre-approved tools, bypassPermissions for isolated environments, permission approaches comparison table

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment Variables: https://code.claude.com/docs/en/env-vars.md
- Permission Modes: https://code.claude.com/docs/en/permission-modes.md
