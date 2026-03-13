---
name: settings-doc
description: Complete documentation for Claude Code settings and permissions -- configuration scopes (managed, user, project, local), settings files (settings.json, settings.local.json, managed-settings.json, .claude.json), all available settings keys (apiKeyHelper, cleanupPeriodDays, companyAnnouncements, env, attribution, permissions, hooks, model, availableModels, modelOverrides, outputStyle, sandbox, statusLine, fileSuggestion, language, autoUpdatesChannel, teammateMode, plansDirectory, forceLoginMethod, enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces, blockedMarketplaces), permission system (allow/ask/deny rules, evaluation order, permission modes -- default/acceptEdits/plan/dontAsk/bypassPermissions), permission rule syntax (tool specifiers, wildcards, Bash/Read/Edit/WebFetch/MCP/Agent rules, gitignore path patterns), sandbox settings (enabled, autoAllowBashIfSandboxed, excludedCommands, filesystem allowWrite/denyWrite/denyRead, network allowedDomains/allowUnixSockets/allowLocalBinding, path prefixes), settings precedence (managed > CLI > local project > shared project > user, array merging), managed-only settings (disableBypassPermissionsMode, allowManagedPermissionRulesOnly, allowManagedHooksOnly, allowManagedMcpServersOnly, blockedMarketplaces, strictKnownMarketplaces, sandbox.network.allowManagedDomainsOnly, allow_remote_sessions), server-managed settings (Teams/Enterprise, admin console on Claude.ai, fetch/caching behavior, security approval dialogs, platform availability), environment variables (ANTHROPIC_API_KEY, ANTHROPIC_MODEL, ANTHROPIC_SMALL_FAST_MODEL, CLAUDE_CODE_MAX_TURNS, CLAUDE_CODE_USE_BEDROCK/VERTEX/FOUNDRY, DISABLE_PROMPT_CACHING, MCP_TIMEOUT, and many more), hook configuration (allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars), plugin settings (enabledPlugins, extraKnownMarketplaces, marketplace source types), attribution settings (commit/pr customization). Load when discussing Claude Code settings, configuration, settings.json, permissions, allow/deny rules, permission modes, bypassPermissions, sandbox configuration, managed settings, server-managed settings, environment variables, ANTHROPIC_* variables, CLAUDE_CODE_* variables, enterprise policy enforcement, MDM deployment, settings precedence, permission rule syntax, working directories, /config command, /permissions command, /status command, or any settings key names.
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, and server-managed settings.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared? |
|:------|:---------|:---------------|:--------|
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | All users on machine | Yes (IT deployed) |
| **User** | `~/.claude/settings.json` | You, across all projects | No |
| **Project** | `.claude/settings.json` | All collaborators | Yes (committed to git) |
| **Local** | `.claude/settings.local.json` | You, this project only | No (gitignored) |

### Settings Files

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User-level global settings |
| `.claude/settings.json` | Project-level shared settings |
| `.claude/settings.local.json` | Project-level personal overrides |
| `managed-settings.json` | System-wide managed settings (macOS: `/Library/Application Support/ClaudeCode/`, Linux/WSL: `/etc/claude-code/`, Windows: `C:\Program Files\ClaudeCode\`) |
| `~/.claude.json` | Preferences, OAuth, MCP configs, per-project state, caches |
| `.mcp.json` | Project-scoped MCP server configurations |

Add `"$schema": "https://json.schemastore.org/claude-code-settings.json"` for editor autocomplete.

### Settings Precedence (highest to lowest)

1. **Managed settings** (server-managed > MDM/OS-level > managed-settings.json) -- cannot be overridden
2. **Command line arguments** -- temporary session overrides
3. **Local project settings** (`.claude/settings.local.json`)
4. **Shared project settings** (`.claude/settings.json`)
5. **User settings** (`~/.claude/settings.json`)

Array settings (like `permissions.allow`, `sandbox.filesystem.allowWrite`) merge across scopes (concatenated and deduplicated). If denied at any level, no other level can allow it.

### Available Settings Keys

| Key | Description |
|:----|:------------|
| `apiKeyHelper` | Script to generate auth value (sent as `X-Api-Key` and `Authorization: Bearer`) |
| `autoMemoryDirectory` | Custom directory for auto memory storage (not accepted in project settings) |
| `cleanupPeriodDays` | Inactive session deletion threshold (default: 30; 0 = delete all, disable persistence) |
| `companyAnnouncements` | Startup announcements (array, randomly cycled) |
| `env` | Environment variables applied to every session |
| `attribution` | Customize git commit/PR attribution (`commit` and `pr` keys) |
| `includeCoAuthoredBy` | Deprecated: use `attribution`. Co-authored-by in commits (default: true) |
| `includeGitInstructions` | Include built-in git workflow instructions (default: true) |
| `permissions` | Permission rules (allow/ask/deny arrays, additionalDirectories, defaultMode) |
| `hooks` | Custom commands at lifecycle events |
| `disableAllHooks` | Disable all hooks and custom status line |
| `model` | Override default model |
| `availableModels` | Restrict models users can select via `/model` |
| `modelOverrides` | Map Anthropic model IDs to provider-specific IDs (e.g., Bedrock ARNs) |
| `outputStyle` | Adjust system prompt output style |
| `statusLine` | Custom status line command |
| `fileSuggestion` | Custom `@` file autocomplete command |
| `respectGitignore` | Whether `@` picker respects `.gitignore` (default: true) |
| `forceLoginMethod` | Restrict login to `claudeai` or `console` |
| `forceLoginOrgUUID` | Auto-select organization during login |
| `enableAllProjectMcpServers` | Auto-approve all project `.mcp.json` servers |
| `enabledMcpjsonServers` | Specific `.mcp.json` servers to approve |
| `disabledMcpjsonServers` | Specific `.mcp.json` servers to reject |
| `allowedMcpServers` | Managed allowlist of MCP servers |
| `deniedMcpServers` | Managed denylist of MCP servers |
| `otelHeadersHelper` | Script for dynamic OpenTelemetry headers |
| `language` | Preferred response language |
| `autoUpdatesChannel` | `"stable"` (week-old, skip regressions) or `"latest"` (default) |
| `alwaysThinkingEnabled` | Enable extended thinking by default |
| `plansDirectory` | Where plan files are stored (default: `~/.claude/plans`) |
| `showTurnDuration` | Show turn duration messages (default: true) |
| `spinnerVerbs` | Custom spinner verbs (`mode`: `"replace"` or `"append"`, `verbs` array) |
| `spinnerTipsEnabled` | Show tips in spinner (default: true) |
| `spinnerTipsOverride` | Custom spinner tips (`tips` array, `excludeDefault` boolean) |
| `terminalProgressBarEnabled` | Terminal progress bar (default: true) |
| `prefersReducedMotion` | Reduce UI animations for accessibility |
| `fastModePerSessionOptIn` | Require per-session fast mode opt-in |
| `teammateMode` | Agent team display: `auto`, `in-process`, or `tmux` |
| `enabledPlugins` | Plugin enable/disable map (`"name@marketplace": true/false`) |
| `extraKnownMarketplaces` | Additional plugin marketplaces for the repo |
| `strictKnownMarketplaces` | Managed-only allowlist of marketplaces |
| `blockedMarketplaces` | Managed-only blocklist of marketplaces |
| `pluginTrustMessage` | Managed-only custom message for plugin trust warning |
| `awsAuthRefresh` | AWS credential refresh script |
| `awsCredentialExport` | AWS credential export script |

### Permission System

Tool types and default approval:

| Tool type | Example | Approval required | "Don't ask again" scope |
|:----------|:--------|:------------------|:------------------------|
| Read-only | File reads, Grep | No | N/A |
| Bash commands | Shell execution | Yes | Permanently per project + command |
| File modification | Edit/write files | Yes | Until session end |

### Permission Modes

| Mode | Description |
|:-----|:------------|
| `default` | Prompts for permission on first use of each tool |
| `acceptEdits` | Auto-accepts file edit permissions for the session |
| `plan` | Analyze only -- no file modifications or commands |
| `dontAsk` | Auto-denies unless pre-approved via `/permissions` or `permissions.allow` |
| `bypassPermissions` | Skips all prompts (containers/VMs only; disable with `disableBypassPermissionsMode`) |

### Permission Rule Syntax

Rules follow `Tool` or `Tool(specifier)` format. Evaluation order: **deny > ask > allow** (first match wins).

**Bash rules** -- support `*` wildcards at any position:

| Rule | Matches |
|:-----|:--------|
| `Bash` | All Bash commands |
| `Bash(npm run build)` | Exact command |
| `Bash(npm run *)` | Commands starting with `npm run ` (space before `*` = word boundary) |
| `Bash(npm*)` | Commands starting with `npm` (no boundary -- matches `npmx` too) |
| `Bash(* --version)` | Commands ending with ` --version` |

Claude Code is aware of shell operators (`&&`) -- prefix match rules won't permit chained commands.

**Read and Edit rules** -- follow gitignore specification:

| Pattern | Meaning | Example |
|:--------|:--------|:--------|
| `//path` | Absolute path from filesystem root | `Read(//Users/alice/secrets/**)` |
| `~/path` | Path from home directory | `Read(~/Documents/*.pdf)` |
| `/path` | Relative to project root | `Edit(/src/**/*.ts)` |
| `path` or `./path` | Relative to current directory | `Read(*.env)` |

`*` matches within a single directory; `**` matches recursively across directories.

**Other tool rules:**

| Rule | Effect |
|:-----|:-------|
| `WebFetch(domain:example.com)` | Matches fetch requests to domain |
| `mcp__puppeteer` | All tools from the puppeteer MCP server |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `Agent(Explore)` | Matches the Explore subagent |
| `Skill(commit)` | Matches a specific skill |

### Sandbox Settings

| Key | Description | Default |
|:----|:------------|:--------|
| `sandbox.enabled` | Enable bash sandboxing | `false` |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed | `true` |
| `sandbox.excludedCommands` | Commands that run outside sandbox | -- |
| `sandbox.allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch | `true` |
| `sandbox.filesystem.allowWrite` | Additional writable paths (merges across scopes) | -- |
| `sandbox.filesystem.denyWrite` | Blocked write paths (merges across scopes) | -- |
| `sandbox.filesystem.denyRead` | Blocked read paths (merges across scopes) | -- |
| `sandbox.network.allowedDomains` | Allowed outbound domains (supports `*.example.com`) | -- |
| `sandbox.network.allowUnixSockets` | Allowed Unix socket paths | -- |
| `sandbox.network.allowAllUnixSockets` | Allow all Unix sockets | `false` |
| `sandbox.network.allowLocalBinding` | Allow binding to localhost (macOS only) | `false` |
| `sandbox.network.allowManagedDomainsOnly` | Managed-only: ignore non-managed domain rules | `false` |
| `sandbox.enableWeakerNestedSandbox` | Weaker sandbox for unprivileged Docker (Linux/WSL2) | `false` |
| `sandbox.enableWeakerNetworkIsolation` | Allow system TLS trust (macOS; needed for gh/gcloud/terraform) | `false` |

Sandbox path prefixes: `//` = absolute, `~/` = home, `/` = relative to settings file directory, `./` or bare = relative.

### Managed-Only Settings

These settings are only effective in managed settings and cannot be overridden:

| Setting | Description |
|:--------|:------------|
| `disableBypassPermissionsMode` | `"disable"` prevents `bypassPermissions` mode and `--dangerously-skip-permissions` |
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply |
| `allowManagedHooksOnly` | Only managed and SDK hooks load |
| `allowManagedMcpServersOnly` | Only managed MCP allowlist applies |
| `blockedMarketplaces` | Blocklist checked before download |
| `strictKnownMarketplaces` | Allowlist of marketplaces users can add |
| `sandbox.network.allowManagedDomainsOnly` | Only managed domain rules apply |
| `allow_remote_sessions` | Allow Remote Control and web sessions (default: true) |

### Server-Managed Settings

Server-managed settings allow centralized configuration through the Claude.ai admin console, without MDM infrastructure. Available for Teams and Enterprise plans.

| Aspect | Detail |
|:-------|:-------|
| Requirements | Teams/Enterprise plan, Claude Code >= 2.1.38 (Teams) or >= 2.1.30 (Enterprise) |
| Configure at | Claude.ai > Admin Settings > Claude Code > Managed settings |
| Delivery | Fetched at startup, polled hourly, cached locally |
| Precedence | Highest tier (overrides endpoint-managed when both present) |
| Access control | Primary Owner and Owner roles only |
| Limitations | Uniform to all org users (no per-group); no MCP server configs |
| Platform | Requires direct `api.anthropic.com` access (not available with Bedrock/Vertex/Foundry/custom endpoints) |

Security approval dialogs are shown for shell command settings, custom env vars not on the safe allowlist, and hook configurations. In non-interactive mode (`-p` flag), dialogs are skipped.

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key for Claude SDK |
| `ANTHROPIC_AUTH_TOKEN` | Custom `Authorization: Bearer` header value |
| `ANTHROPIC_MODEL` | Override primary model |
| `ANTHROPIC_SMALL_FAST_MODEL` | Override small/fast model |
| `ANTHROPIC_BASE_URL` | Custom API base URL |
| `CLAUDE_CODE_MAX_TURNS` | Max agentic turns in non-interactive mode |
| `CLAUDE_CODE_USE_BEDROCK` | Enable Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Enable Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Enable Microsoft Foundry |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable non-essential network traffic |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | Cache duration for apiKeyHelper |
| `CLAUDE_CODE_SKIP_*_AUTH` | Skip auth for Bedrock/Vertex/Foundry |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching |
| `HTTP_PROXY` / `HTTPS_PROXY` | Corporate proxy configuration |
| `MCP_TIMEOUT` | MCP server startup timeout (ms, default: 10000) |
| `MCP_TOOL_TIMEOUT` | MCP tool execution timeout (ms, default: 300000) |
| `CLAUDE_CODE_GIT_TIMEOUT_MS` | Git operations timeout (ms, default: 10000) |
| `SLASH_COMMAND_TOOL_CHAR_BUDGET` | Override skill description budget |

See the full reference doc for the complete environment variables table (90+ variables).

### Useful Commands

| Command | Purpose |
|:--------|:--------|
| `/config` | Open the Settings interface |
| `/permissions` | View and manage permission rules |
| `/status` | See active settings sources and their origins |
| `/model` | Switch models (respects `availableModels`) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) -- configuration scopes, settings files and locations, all available settings keys with examples, permission settings structure, permission rule syntax, sandbox settings, attribution settings, file suggestion settings, hook configuration, settings precedence and array merging, environment variables (90+ variables), plugin configuration (enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces with all source types), subagent configuration, system prompt notes
- [Configure permissions](references/claude-code-permissions.md) -- permission system tiers, permission modes (default/acceptEdits/plan/dontAsk/bypassPermissions), permission rule syntax, tool-specific rules (Bash wildcards, Read/Edit gitignore patterns, WebFetch domain matching, MCP server/tool matching, Agent rules), hooks extension, working directories, sandboxing interaction, managed-only settings, settings precedence for permissions, example configurations
- [Server-managed settings](references/claude-code-server-managed-settings.md) -- requirements, server vs endpoint comparison, admin console configuration steps, access control, current limitations, fetch and caching behavior, security approval dialogs, platform availability, audit logging, security considerations and tamper scenarios

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
