---
name: settings-doc
description: Complete documentation for Claude Code settings, permissions, permission modes, server-managed settings, and environment variables. Covers configuration scopes (managed/user/project/local), settings.json structure and all available settings keys (apiKeyHelper, autoMemoryDirectory, cleanupPeriodDays, companyAnnouncements, env, attribution, permissions, autoMode, hooks, model, availableModels, modelOverrides, effortLevel, sandbox, statusLine, fileSuggestion, outputStyle, agent, worktree, spinnerVerbs, language, voiceEnabled, autoUpdatesChannel, feedbackSurveyRate, and more), settings files and delivery mechanisms (user ~/.claude/settings.json, project .claude/settings.json, local .claude/settings.local.json, managed via server/MDM/plist/registry/file-based managed-settings.json with drop-in managed-settings.d/), settings precedence (managed > CLI args > local > project > user, array settings merge across scopes), permission system (tiered tool approval, allow/ask/deny rules evaluated deny-first, /permissions command), permission rule syntax (Tool or Tool(specifier) format, Bash wildcard patterns with word boundary semantics, Read/Edit gitignore-spec patterns with //absolute ~/home /project-relative ./cwd-relative, WebFetch domain rules, MCP server/tool rules, Agent subagent rules), permission modes (default, acceptEdits, plan, auto, dontAsk, bypassPermissions -- switching via Shift+Tab in CLI or mode selector in VS Code/Desktop/Web, --permission-mode flag, defaultMode setting), auto mode (classifier model review, autoMode.environment for trusted infrastructure, autoMode.allow and autoMode.soft_deny prose rules, claude auto-mode defaults/config/critique commands, classifier evaluation order, subagent handling, fallback behavior), plan mode (read-only exploration, /plan prefix, plan acceptance options), sandbox settings (sandbox.enabled, filesystem allowWrite/denyWrite/denyRead/allowRead with path prefixes, network allowedDomains/allowManagedDomainsOnly, excludedCommands, failIfUnavailable, enableWeakerNestedSandbox), plugin configuration (enabledPlugins, extraKnownMarketplaces with source types github/git/url/npm/file/directory/hostPattern/settings, strictKnownMarketplaces and blockedMarketplaces for managed policy), managed-only settings (allowManagedPermissionRulesOnly, allowManagedHooksOnly, allowManagedMcpServersOnly, allowedChannelPlugins, blockedMarketplaces, sandbox.network.allowManagedDomainsOnly, sandbox.filesystem.allowManagedReadPathsOnly, strictKnownMarketplaces), hook configuration settings (allowedHttpHookUrls, httpHookAllowedEnvVars, disableAllHooks), server-managed settings (web-based admin console delivery, Teams/Enterprise plans, fetch and caching behavior, security approval dialogs, platform availability, audit logging, security considerations vs endpoint-managed), environment variables reference (ANTHROPIC_API_KEY, ANTHROPIC_MODEL, ANTHROPIC_BASE_URL, CLAUDE_CODE_USE_BEDROCK/VERTEX, proxy variables, CLAUDE_CODE_MAX_OUTPUT_TOKENS, MAX_THINKING_TOKENS, MCP_TIMEOUT, DISABLE_AUTOUPDATER, DISABLE_TELEMETRY, and 50+ more), global config settings (~/.claude.json for autoConnectIde, editorMode, showTurnDuration), working directories (--add-dir, /add-dir, additionalDirectories), hooks extending permissions (PreToolUse allow/deny/escalate, PermissionRequest hooks). Load when discussing Claude Code settings, configuration, settings.json, permissions, permission rules, permission modes, auto mode, plan mode, dontAsk mode, bypassPermissions, managed settings, server-managed settings, MDM policy, environment variables, sandbox configuration, plugin configuration, marketplace restrictions, or any configuration-related topic for Claude Code.
user-invocable: false
---

# Settings & Configuration Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, permission modes, server-managed settings, and environment variables.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared? |
|:------|:---------|:---------------|:--------|
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | All users on machine | Yes (deployed by IT) |
| **User** | `~/.claude/settings.json` | You, across all projects | No |
| **Project** | `.claude/settings.json` | All collaborators | Yes (committed to git) |
| **Local** | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |

**Precedence** (highest to lowest): Managed > CLI arguments > Local > Project > User. Array settings (like `permissions.allow`) merge across scopes rather than replacing.

Verify active settings with `/status`. Add the JSON Schema line for editor autocomplete:
```json
{ "$schema": "https://json.schemastore.org/claude-code-settings.json" }
```

### Managed Settings Delivery Mechanisms

| Mechanism | Location |
|:----------|:---------|
| **Server-managed** | Claude.ai admin console (Teams/Enterprise) |
| **macOS MDM** | `com.anthropic.claudecode` managed preferences domain |
| **Windows registry** | `HKLM\SOFTWARE\Policies\ClaudeCode` (admin) or `HKCU` (user) |
| **File-based** | macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`, Linux/WSL: `/etc/claude-code/managed-settings.json`, Windows: `C:\Program Files\ClaudeCode\managed-settings.json` |
| **Drop-in directory** | `managed-settings.d/*.json` alongside `managed-settings.json` (merged alphabetically, use numeric prefixes) |

Within the managed tier: server-managed > MDM/OS-level > file-based > HKCU registry. Only one managed source is used; sources do not merge across tiers.

### Available Settings (settings.json)

**Core settings:**

| Key | Description |
|:----|:------------|
| `permissions` | Permission rules (`allow`, `ask`, `deny` arrays), `defaultMode`, `additionalDirectories`, `disableBypassPermissionsMode` |
| `autoMode` | Auto mode classifier config: `environment`, `allow`, `soft_deny` arrays of prose rules |
| `hooks` | Lifecycle event hooks (PreToolUse, PostToolUse, etc.) |
| `env` | Environment variables applied to every session |
| `model` | Override the default model |
| `availableModels` | Restrict which models users can select |
| `modelOverrides` | Map Anthropic model IDs to provider-specific IDs (e.g., Bedrock ARNs) |
| `effortLevel` | Persist effort level across sessions: `"low"`, `"medium"`, or `"high"` |
| `sandbox` | Sandbox configuration (see Sandbox Settings section below) |
| `attribution` | Customize commit and PR attribution (`commit`, `pr` subkeys) |

**Behavior and UI settings:**

| Key | Description |
|:----|:------------|
| `language` | Response language (e.g., `"japanese"`); also sets voice dictation language |
| `outputStyle` | Output style for system prompt adjustment |
| `defaultShell` | Shell for `!` commands: `"bash"` (default) or `"powershell"` |
| `statusLine` | Custom status line command |
| `fileSuggestion` | Custom `@` file autocomplete command |
| `respectGitignore` | Whether `@` picker respects `.gitignore` (default: `true`) |
| `spinnerVerbs` | Custom spinner action verbs (`mode`: `"replace"` or `"append"`, `verbs` array) |
| `spinnerTipsEnabled` | Show tips in spinner (default: `true`) |
| `spinnerTipsOverride` | Custom spinner tips (`tips` array, `excludeDefault` boolean) |
| `prefersReducedMotion` | Reduce UI animations for accessibility |
| `voiceEnabled` | Enable push-to-talk voice dictation |
| `alwaysThinkingEnabled` | Enable extended thinking by default |
| `plansDirectory` | Where plan files are stored (default: `~/.claude/plans`) |
| `showClearContextOnPlanAccept` | Show "clear context" option on plan accept screen |
| `autoUpdatesChannel` | `"stable"` (week-old, skip regressions) or `"latest"` (default) |
| `feedbackSurveyRate` | Survey probability 0-1 (set `0` to suppress) |
| `agent` | Run main thread as a named subagent |
| `teammateMode` | Agent team display: `"auto"`, `"in-process"`, or `"tmux"` |

**Session and storage settings:**

| Key | Description |
|:----|:------------|
| `cleanupPeriodDays` | Inactive session deletion threshold (default: 30); `0` disables persistence entirely |
| `autoMemoryDirectory` | Custom auto-memory storage path (not allowed in project settings) |
| `apiKeyHelper` | Shell script to generate auth value |

**Login and account settings:**

| Key | Description |
|:----|:------------|
| `forceLoginMethod` | Restrict login: `"claudeai"` or `"console"` |
| `forceLoginOrgUUID` | Auto-select org during login (requires `forceLoginMethod`) |

**MCP settings:**

| Key | Description |
|:----|:------------|
| `enableAllProjectMcpServers` | Auto-approve all MCP servers from project `.mcp.json` |
| `enabledMcpjsonServers` | Specific MCP servers to approve from `.mcp.json` |
| `disabledMcpjsonServers` | Specific MCP servers to reject from `.mcp.json` |

**Hook configuration settings:**

| Key | Description |
|:----|:------------|
| `disableAllHooks` | Disable all hooks and custom status line |
| `allowManagedHooksOnly` | (Managed only) Block user/project/plugin hooks |
| `allowedHttpHookUrls` | URL pattern allowlist for HTTP hooks (supports `*` wildcard) |
| `httpHookAllowedEnvVars` | Env var allowlist for HTTP hook header interpolation |

**Worktree settings:**

| Key | Description |
|:----|:------------|
| `worktree.symlinkDirectories` | Directories to symlink from main repo into worktrees |
| `worktree.sparsePaths` | Directories to sparse-checkout in worktrees |

**Git settings (`includeGitInstructions`):** Set `false` to remove built-in commit/PR instructions from system prompt.

**Global config settings** (stored in `~/.claude.json`, not `settings.json`):

| Key | Description |
|:----|:------------|
| `autoConnectIde` | Auto-connect to running IDE from external terminal |
| `autoInstallIdeExtension` | Auto-install Claude Code IDE extension in VS Code |
| `editorMode` | Key binding mode: `"normal"` or `"vim"` |
| `showTurnDuration` | Show turn duration after responses |
| `terminalProgressBarEnabled` | Terminal progress bar in supported terminals |

### Permission System

Rules evaluated in order: **deny > ask > allow**. First matching rule wins.

| Tool type | Example | Approval required | "Don't ask again" behavior |
|:----------|:--------|:------------------|:---------------------------|
| Read-only | File reads, Grep | No | N/A |
| Bash commands | Shell execution | Yes | Permanently per project + command |
| File modification | Edit/write files | Yes | Until session end |

Manage with `/permissions`. Compound command approval saves a rule per subcommand (up to 5).

### Permission Rule Syntax

**Format:** `Tool` or `Tool(specifier)`

**Bash rules** -- glob patterns with `*`:

| Pattern | Matches |
|:--------|:--------|
| `Bash` or `Bash(*)` | All bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` (word boundary) |
| `Bash(npm*)` | Commands starting with `npm` (no word boundary) |
| `Bash(* --version)` | Commands ending with ` --version` |
| `Bash(git * main)` | Commands like `git checkout main` |

The space before `*` enforces a word boundary. Claude Code is aware of shell operators so `Bash(safe-cmd *)` does not permit `safe-cmd && other-cmd`.

**Read and Edit rules** -- gitignore-spec patterns:

| Pattern prefix | Meaning | Example |
|:---------------|:--------|:--------|
| `//path` | Absolute path from filesystem root | `Read(//Users/alice/secrets/**)` |
| `~/path` | Home directory relative | `Read(~/Documents/*.pdf)` |
| `/path` | Relative to **project root** | `Edit(/src/**/*.ts)` |
| `path` or `./path` | Relative to **current directory** | `Read(*.env)` |

`*` matches within one directory; `**` matches recursively. Note: `/Users/alice/file` is project-relative, not absolute -- use `//Users/alice/file` for absolute paths.

Read/Edit deny rules apply to Claude's built-in file tools only, not to Bash subprocesses. For OS-level enforcement, enable the sandbox.

**Other tool rules:**

| Rule | Effect |
|:-----|:-------|
| `WebFetch(domain:example.com)` | Fetch requests to that domain |
| `mcp__puppeteer` | All tools from the puppeteer MCP server |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `Agent(Explore)` | The Explore subagent |
| `Agent(my-custom-agent)` | A custom subagent |

### Permission Modes

| Mode | What Claude can do without asking | Best for |
|:-----|:----------------------------------|:---------|
| `default` | Read files | Getting started, sensitive work |
| `acceptEdits` | Read and edit files | Iterating on code you review |
| `plan` | Read files (no edits, proposes plans) | Exploring codebases, planning refactors |
| `auto` | All actions with background classifier checks | Long-running tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools (all else auto-denied) | Locked-down environments, CI pipelines |
| `bypassPermissions` | All actions, no checks | Isolated containers/VMs only |

**Switching modes:**
- **CLI**: `Shift+Tab` cycles through modes; `--permission-mode <mode>` at startup
- **VS Code**: Click mode indicator at bottom of prompt box
- **Desktop**: Mode selector next to send button
- **Web/mobile**: Mode dropdown next to prompt box
- **Setting**: `permissions.defaultMode` in settings.json

**Auto mode** requires a Team plan (Enterprise/API rolling out), Claude Sonnet 4.6 or Opus 4.6, and admin enablement. A separate classifier model reviews each action against block/allow rules. Cost: classifier calls count toward token usage. Latency: one round-trip per checked action.

Auto mode action evaluation order:
1. Allow/deny rules resolve immediately
2. Read-only actions and file edits in cwd auto-approved
3. Everything else goes to classifier
4. If blocked, Claude tries an alternative approach

On entering auto mode, blanket allow rules granting arbitrary code execution (e.g., `Bash(*)`, `Bash(python*)`, any `Agent` allow) are dropped; narrow rules like `Bash(npm test)` carry over.

Fallback: after 3 consecutive blocks or 20 total in a session, auto mode pauses and resumes prompting. Approving a prompted action resets counters.

**Plan mode** proposes changes without making them. Enter with `/plan` prefix or switch via `Shift+Tab`. When ready, approve with auto mode, accept edits, manual review, or continue planning.

**dontAsk mode** auto-denies everything not explicitly allowed. Even `ask` rules are denied rather than prompting.

**bypassPermissions mode** disables all checks. Admin-blockable via `permissions.disableBypassPermissionsMode: "disable"` in managed settings. Also triggered by `--dangerously-skip-permissions` flag.

### Auto Mode Classifier Configuration

The `autoMode` block tells the classifier which infrastructure is trusted. Read from user settings, `.claude/settings.local.json`, and managed settings -- not from shared project settings.

**`autoMode.environment`** (most organizations only need this):
```json
{
  "autoMode": {
    "environment": [
      "Organization: AcmeCorp. Primary use: software development",
      "Source control: github.example.com/acme-corp",
      "Trusted cloud buckets: s3://acme-builds, gs://acme-datasets",
      "Trusted internal domains: *.internal.example.com",
      "Key internal services: Jenkins at ci.example.com"
    ]
  }
}
```

Entries are prose (natural-language), not regex. Setting `environment` alone leaves default `allow` and `soft_deny` lists intact.

**`autoMode.allow`** and **`autoMode.soft_deny`**: Replace built-in rule lists entirely when set. Always start from `claude auto-mode defaults` output and edit -- never start from an empty list.

Precedence inside classifier: `soft_deny` blocks first, `allow` overrides as exceptions, explicit user intent overrides both.

**Inspect commands:**
- `claude auto-mode defaults` -- built-in rules
- `claude auto-mode config` -- effective merged config
- `claude auto-mode critique` -- AI feedback on custom rules

### Sandbox Settings

All under the `sandbox` key in settings.json:

| Key | Description |
|:----|:------------|
| `enabled` | Enable sandboxing (default: `false`) |
| `failIfUnavailable` | Exit on startup if sandbox cannot start |
| `autoAllowBashIfSandboxed` | Auto-approve sandboxed bash commands (default: `true`) |
| `excludedCommands` | Commands that run outside sandbox |
| `allowUnsandboxedCommands` | Set `false` to disable `dangerouslyDisableSandbox` escape hatch |
| `enableWeakerNestedSandbox` | For unprivileged Docker (Linux/WSL2 only, reduces security) |
| `enableWeakerNetworkIsolation` | Allow macOS TLS trust service in sandbox (for Go tools like `gh`) |

**Filesystem paths** (`sandbox.filesystem.*`):

| Key | Description |
|:----|:------------|
| `allowWrite` | Additional writable paths |
| `denyWrite` | Blocked write paths |
| `denyRead` | Blocked read paths |
| `allowRead` | Re-allow reads within `denyRead` regions |
| `allowManagedReadPathsOnly` | (Managed only) Ignore non-managed `allowRead` entries |

Path prefixes: `/` = absolute, `~/` = home-relative, `./` or bare = project-relative (project settings) or `~/.claude`-relative (user settings).

**Network settings** (`sandbox.network.*`):

| Key | Description |
|:----|:------------|
| `allowedDomains` | Domains bash commands can reach (supports wildcards like `*.npmjs.org`) |
| `allowManagedDomainsOnly` | (Managed only) Block non-allowed domains automatically |
| `allowUnixSockets` | Unix socket paths accessible in sandbox |
| `allowAllUnixSockets` | Allow all Unix socket connections |
| `allowLocalBinding` | Allow binding to localhost ports (macOS only) |
| `httpProxyPort` | Custom HTTP proxy port |
| `socksProxyPort` | Custom SOCKS5 proxy port |

### Managed-Only Settings

These settings are only effective in managed settings and cannot be overridden:

| Setting | Description |
|:--------|:------------|
| `allowManagedPermissionRulesOnly` | Block user/project permission rules |
| `allowManagedHooksOnly` | Block user/project/plugin hooks |
| `allowManagedMcpServersOnly` | Only admin-allowlisted MCP servers apply |
| `allowedChannelPlugins` | Channel plugin allowlist (requires `channelsEnabled: true`) |
| `blockedMarketplaces` | Marketplace blocklist (checked before download) |
| `sandbox.network.allowManagedDomainsOnly` | Only managed domain allowlists apply |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed `allowRead` paths apply |
| `strictKnownMarketplaces` | Marketplace addition allowlist |
| `disableAutoMode` | Set `"disable"` to prevent auto mode activation |
| `channelsEnabled` | Allow channels for Team/Enterprise users |
| `pluginTrustMessage` | Custom message appended to plugin trust warning |
| `companyAnnouncements` | Announcements displayed at startup |

### Plugin Configuration

**`enabledPlugins`**: Controls which plugins are active. Format: `"plugin-name@marketplace-name": true/false`

**`extraKnownMarketplaces`**: Defines additional marketplaces. Supported source types: `github`, `git`, `url`, `npm`, `file`, `directory`, `hostPattern`, `settings` (inline).

**`strictKnownMarketplaces`** (managed only): Allowlist of marketplaces users may add. Uses exact matching for source specs. `undefined` = no restrictions, `[]` = lockdown.

**`blockedMarketplaces`** (managed only): Blocklist checked before download.

### Server-Managed Settings

Delivered from Anthropic's servers via Claude.ai admin console. Requires Teams or Enterprise plan, Claude Code >= 2.1.38 (Teams) or >= 2.1.30 (Enterprise), and access to `api.anthropic.com`.

**Behavior:**
- Fetched at startup and polled hourly during active sessions
- Cached settings apply immediately on subsequent launches; fresh settings fetched in background
- Settings with shell commands, custom env vars, or hooks trigger a security approval dialog
- In non-interactive mode (`-p` flag), dialogs are skipped and settings applied automatically
- When both server-managed and endpoint-managed settings exist, server-managed takes precedence

**Access control:** Primary Owner and Owner roles can manage settings.

**Current limitations:** Settings apply uniformly (no per-group). MCP server configs cannot be distributed via server-managed settings.

**Not available with:** Bedrock, Vertex AI, Foundry, custom `ANTHROPIC_BASE_URL`, or LLM gateways.

### Environment Variables (Key Selection)

**API and model:**

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key for direct API usage |
| `ANTHROPIC_MODEL` | Override the model (e.g., `claude-sonnet-4-6`) |
| `ANTHROPIC_BASE_URL` | Override API base URL |
| `ANTHROPIC_AUTH_TOKEN` | Custom auth token (overrides API key and OAuth) |

**Provider selection:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_USE_BEDROCK` | Set `1` to use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Set `1` to use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Set `1` to use Microsoft Foundry |
| `AWS_REGION`, `AWS_PROFILE` | AWS config for Bedrock |
| `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID` | Vertex AI config |

**Token and output control:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Override max output tokens per turn |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget; `0` disables thinking |

**Feature toggles:**

| Variable | Purpose |
|:---------|:--------|
| `DISABLE_AUTOUPDATER` | Set `1` to disable auto-updates |
| `DISABLE_TELEMETRY` | Set `1` to opt out of Statsig telemetry |
| `DISABLE_ERROR_REPORTING` | Set `1` to opt out of Sentry error reporting |
| `DISABLE_COST_WARNINGS` | Set `1` to disable cost warnings |
| `DISABLE_PROMPT_CACHING` | Set `1` to disable prompt caching |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable all non-essential outbound traffic |
| `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` | Remove git instructions from system prompt |
| `IS_DEMO` | Enable demo mode (hide email/org, skip onboarding) |

**MCP configuration:**

| Variable | Purpose |
|:---------|:--------|
| `MCP_TIMEOUT` | MCP server startup timeout (ms) |
| `MCP_TOOL_TIMEOUT` | MCP tool execution timeout (ms) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens in MCP tool responses (default: 25000) |
| `ENABLE_TOOL_SEARCH` | Control MCP tool search behavior (`true`, `auto`, `auto:N`, `false`) |

**Proxy and network:**

| Variable | Purpose |
|:---------|:--------|
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server for network connections |
| `NO_PROXY` | Domains/IPs to bypass proxy |
| `CLAUDE_CODE_CLIENT_CERT` | Client certificate path for mTLS |
| `CLAUDE_CODE_CLIENT_KEY` | Client private key path for mTLS |

**Misc:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_SKIP_OTEL_METADATA` | Skip collecting metadata for OTEL spans |
| `CLAUDE_STREAM_IDLE_TIMEOUT_MS` | Streaming idle watchdog timeout (default: 90000ms) |
| `USE_BUILTIN_RIPGREP` | Set `0` to use system `rg` instead of bundled |
| `CLAUDE_CODE_USE_POWERSHELL_TOOL` | Set `1` to enable PowerShell tool on Windows |

For the complete list of 50+ environment variables, see the [full reference](references/claude-code-env-vars.md).

### Extending Permissions with Hooks

PreToolUse hooks run before permission prompts and can:
- **Deny** (exit code 2): blocks the tool call before permission rules are evaluated
- **Allow** (output `{"allow": true}`): skips the prompt, but deny/ask rules still apply after
- **Escalate** (output `{"escalate": true}`): forces a permission prompt

PermissionRequest hooks intercept the permission dialog itself and can answer on the user's behalf.

### Working Directories

Extend file access beyond the launch directory:
- `--add-dir <path>` at startup
- `/add-dir` during a session
- `additionalDirectories` in settings

Files in additional directories follow the same permission rules as the original working directory.

## Full Documentation

For the complete official documentation, see the reference files:

- [Settings](references/claude-code-settings.md) -- Complete configuration reference: configuration scopes (managed/user/project/local with precedence), settings files and delivery mechanisms (user/project/local/managed including server-managed, MDM/plist/registry, file-based managed-settings.json with drop-in managed-settings.d), all available settings keys table (apiKeyHelper, autoMemoryDirectory, cleanupPeriodDays, companyAnnouncements, env, attribution, permissions, autoMode, hooks, model, availableModels, modelOverrides, effortLevel, sandbox, statusLine, fileSuggestion, outputStyle, agent, language, voiceEnabled, autoUpdatesChannel, feedbackSurveyRate, spinnerVerbs, worktree, and more), global config settings (~/.claude.json), permission settings (allow/ask/deny arrays, defaultMode, additionalDirectories, disableBypassPermissionsMode), permission rule syntax (Tool/Tool(specifier), Bash wildcards, Read/Edit gitignore patterns), sandbox settings (enabled, filesystem allowWrite/denyWrite/denyRead/allowRead, network allowedDomains, excludedCommands, failIfUnavailable), attribution settings (commit/pr customization), file suggestion settings (custom @ autocomplete), hook configuration (allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars), settings precedence (managed > CLI > local > project > user with array merging), plugin configuration (enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces with all source types), /status verification, JSON Schema support, excluding sensitive files, subagent configuration, environment variables overview
- [Permissions](references/claude-code-permissions.md) -- Permission system (tiered tool approval table), managing permissions (/permissions command, allow/ask/deny rules, deny-first evaluation), permission modes table (default/acceptEdits/plan/auto/dontAsk/bypassPermissions), permission rule syntax (Tool(specifier) format, Bash wildcard patterns with word boundary semantics and shell operator awareness, compound command approval saving per-subcommand rules, Bash pattern security limitations with curl examples, Read/Edit gitignore-spec patterns with //absolute ~/home /project-relative ./cwd-relative prefixes and * vs ** matching, WebFetch domain rules, MCP server/tool rules, Agent subagent rules), extending permissions with hooks (PreToolUse allow/deny/escalate, blocking hook precedence over allow rules), working directories (--add-dir, /add-dir, additionalDirectories), permissions and sandboxing interaction (complementary layers, defense-in-depth), managed settings (managed-only settings table: allowManagedPermissionRulesOnly, allowManagedHooksOnly, allowManagedMcpServersOnly, allowedChannelPlugins, blockedMarketplaces, sandbox.network.allowManagedDomainsOnly, sandbox.filesystem.allowManagedReadPathsOnly, strictKnownMarketplaces), auto mode classifier configuration (autoMode.environment prose rules for trusted infrastructure, autoMode.allow and autoMode.soft_deny replacement lists with danger warnings, template for environment entries, claude auto-mode defaults/config/critique commands, precedence of soft_deny > allow > user intent), settings precedence (managed > CLI > local > project > user, deny at any level cannot be overridden), example configurations link
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) -- Server-managed settings overview (public beta, Teams/Enterprise), requirements (version 2.1.38+ Teams or 2.1.30+ Enterprise, api.anthropic.com access), server-managed vs endpoint-managed comparison, configuration via admin console (JSON format, permission deny lists, hooks, autoMode examples), verification with /permissions, access control (Primary Owner and Owner roles), current limitations (no per-group, no MCP server configs), settings delivery (precedence over endpoint-managed, fetch at startup with hourly polling, caching behavior for first and subsequent launches), security approval dialogs (shell commands, custom env vars, hooks require user approval, -p flag skips dialogs), platform availability (not available with Bedrock/Vertex/Foundry/custom base URL), audit logging (compliance API events), security considerations (client-side control, tampering scenarios, ConfigChange hooks for detection)
- [Environment Variables](references/claude-code-env-vars.md) -- Complete reference of 50+ environment variables: API and authentication (ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_MODEL, ANTHROPIC_BASE_URL, ANTHROPIC_SMALL_FAST_MODEL, CLAUDE_CODE_API_KEY_HELPER_TTL_MS), provider selection (CLAUDE_CODE_USE_BEDROCK/VERTEX/FOUNDRY, AWS_REGION, AWS_PROFILE, CLOUD_ML_REGION, ANTHROPIC_VERTEX_PROJECT_ID, VERTEX_REGION_* overrides), output and thinking (CLAUDE_CODE_MAX_OUTPUT_TOKENS, MAX_THINKING_TOKENS, CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING), feature toggles (DISABLE_AUTOUPDATER, DISABLE_TELEMETRY, DISABLE_ERROR_REPORTING, DISABLE_COST_WARNINGS, DISABLE_PROMPT_CACHING, IS_DEMO, FORCE_AUTOUPDATE_PLUGINS), MCP (MCP_TIMEOUT, MCP_TOOL_TIMEOUT, MAX_MCP_OUTPUT_TOKENS, ENABLE_TOOL_SEARCH, MCP_CLIENT_SECRET, MCP_OAUTH_CALLBACK_PORT, ENABLE_CLAUDEAI_MCP_SERVERS), proxy and network (HTTP_PROXY, HTTPS_PROXY, NO_PROXY, CLAUDE_CODE_CLIENT_CERT/KEY/KEY_PASSPHRASE), git and system (CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS, CLAUDE_CODE_GIT_REMOTE, CLAUDE_CODE_SKIP_OTEL_METADATA, USE_BUILTIN_RIPGREP), IDE (CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL), and more
- [Permission Modes](references/claude-code-permission-modes.md) -- How to switch modes (Shift+Tab in CLI, mode selectors in VS Code/Desktop/Web, --permission-mode flag, defaultMode setting), available modes comparison table (default/acceptEdits/plan/auto/dontAsk/bypassPermissions with what each allows and best use cases), plan mode (read-only exploration, /plan prefix, plan acceptance options with auto mode/accept edits/manual review/continue planning, clear context option), auto mode (Team plan requirement, Sonnet 4.6/Opus 4.6 requirement, admin enablement, classifier model overview, cost and latency, action evaluation order with allow/deny > read-only auto-approve > classifier, blanket allow rule dropping on entry, classifier input filtering, subagent handling at spawn and return, default blocks and allows lists, fallback after 3 consecutive or 20 total blocks), dontAsk mode (fully non-interactive, ask rules also denied), bypassPermissions mode (no checks, --dangerously-skip-permissions flag, admin disable option), comparison table across modes, customizing with permission rules and hooks (PreToolUse and PermissionRequest hooks)

## Sources

- Settings: https://code.claude.com/docs/en/settings.md
- Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment Variables: https://code.claude.com/docs/en/env-vars.md
- Permission Modes: https://code.claude.com/docs/en/permission-modes.md
