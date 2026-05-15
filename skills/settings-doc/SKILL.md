---
name: settings-doc
description: Complete official documentation for Claude Code settings, permissions, environment variables, and configuration — scopes (managed/user/project/local), settings.json keys, permission rules and modes, sandbox configuration, server-managed settings, auto mode configuration, and the full environment variable reference.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings and configuration.

## Quick Reference

### Configuration Scopes

| Scope | Location | Shared? | Override priority |
| :--- | :--- | :--- | :--- |
| **Managed** | Server, MDM/plist/registry, or `managed-settings.json` | Yes (IT-deployed) | Highest — cannot be overridden |
| **Local** | `.claude/settings.local.json` | No (gitignored) | 2nd |
| **Project** | `.claude/settings.json` | Yes (committed) | 3rd |
| **User** | `~/.claude/settings.json` | No | Lowest |

Array settings (e.g. `permissions.allow`, `permissions.deny`) **merge** across all scopes rather than override.

### Settings Files and Managed Delivery Mechanisms

| Mechanism | Location | Priority |
| :--- | :--- | :--- |
| Server-managed (Claude.ai admin console) | Remote delivery | Highest |
| macOS plist | `com.anthropic.claudecode` managed preferences | High |
| Windows HKLM registry | `HKLM\SOFTWARE\Policies\ClaudeCode` | High |
| File-based managed | macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`<br />Linux/WSL: `/etc/claude-code/managed-settings.json`<br />Windows: `C:\Program Files\ClaudeCode\managed-settings.json` | Medium |
| Windows HKCU registry | `HKCU\SOFTWARE\Policies\ClaudeCode` | Lowest managed |

File-based managed settings support a `managed-settings.d/` drop-in directory. Files there are sorted alphabetically and merged on top of `managed-settings.json`; use numeric prefixes like `10-telemetry.json` to control order.

### Key settings.json Fields

| Key | Description | Example |
| :--- | :--- | :--- |
| `permissions` | See Permission settings table below | `{ "allow": [...], "deny": [...] }` |
| `env` | Environment variables applied every session | `{ "FOO": "bar" }` |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `hooks` | Lifecycle hook commands | see hooks-doc |
| `autoMode` | Auto mode classifier configuration | `{ "environment": ["$defaults", "..."] }` |
| `sandbox` | Bash command sandboxing | `{ "enabled": true }` |
| `agent` | Run main thread as named subagent | `"code-reviewer"` |
| `apiKeyHelper` | Script to generate auth value sent as `X-Api-Key` | `"/bin/generate_key.sh"` |
| `alwaysThinkingEnabled` | Enable extended thinking by default | `true` |
| `attribution` | Customize git commit/PR attribution | `{"commit": "...", "pr": ""}` |
| `autoMemoryDirectory` | Custom directory for auto memory storage | `"~/my-memory-dir"` |
| `autoMemoryEnabled` | Enable auto memory (default `true`) | `false` |
| `autoScrollEnabled` | Follow new output to bottom in fullscreen rendering | `false` |
| `autoUpdatesChannel` | Update release channel: `"stable"` or `"latest"` | `"stable"` |
| `availableModels` | Restrict selectable models | `["sonnet", "haiku"]` |
| `awaySummaryEnabled` | Show session recap after returning to terminal | `true` |
| `awsAuthRefresh` | Script to refresh AWS credentials | `"aws sso login --profile myprofile"` |
| `awsCredentialExport` | Script to output JSON with AWS credentials | `"/bin/generate_aws_grant.sh"` |
| `cleanupPeriodDays` | Session file retention in days (default 30, min 1) | `20` |
| `claudeMdExcludes` | Glob patterns of CLAUDE.md files to skip when loading | `["**/vendor/**/CLAUDE.md"]` |
| `companyAnnouncements` | Messages shown at startup (cycled randomly) | `["Welcome!"]` |
| `defaultShell` | Input-box shell: `"bash"` or `"powershell"` | `"powershell"` |
| `disableAgentView` | Turn off background agents and agent view | `true` |
| `disableAllHooks` | Disable all hooks and custom status line | `true` |
| `disableAutoMode` | Prevent auto mode activation: `"disable"` | `"disable"` |
| `disableDeepLinkRegistration` | Prevent `claude-cli://` protocol handler registration | `"disable"` |
| `disableRemoteControl` | Disable Remote Control feature | `true` |
| `disableSkillShellExecution` | Block shell execution in skill/command blocks | `true` |
| `editorMode` | Key binding mode: `"normal"` or `"vim"` | `"vim"` |
| `effortLevel` | Persistent effort level: `"low"`, `"medium"`, `"high"`, `"xhigh"` | `"xhigh"` |
| `enableAllProjectMcpServers` | Auto-approve all project `.mcp.json` MCP servers | `true` |
| `fastModePerSessionOptIn` | Require per-session opt-in for fast mode | `true` |
| `feedbackSurveyRate` | Survey probability 0–1; `0` suppresses entirely | `0.05` |
| `fileSuggestion` | Custom `@` file autocomplete command | `{"type": "command", "command": "~/.claude/file-suggestion.sh"}` |
| `forceLoginMethod` | Restrict login: `"claudeai"` or `"console"` | `"claudeai"` |
| `forceLoginOrgUUID` | Require specific org UUID(s) | `"xxxx-xxxx-..."` |
| `gcpAuthRefresh` | Script to refresh GCP Application Default Credentials | `"gcloud auth application-default login"` |
| `includeGitInstructions` | Include built-in git workflow instructions (default `true`) | `false` |
| `language` | Claude's preferred response language | `"japanese"` |
| `maxSkillDescriptionChars` | Per-skill char cap on description shown to Claude (default 1536) | `2048` |
| `minimumVersion` | Floor for auto-updates | `"2.1.100"` |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `modelOverrides` | Map Anthropic model IDs to provider-specific IDs | `{"claude-opus-4-6": "arn:..."}` |
| `otelHeadersHelper` | Script to generate dynamic OpenTelemetry headers | `"/bin/generate_otel_headers.sh"` |
| `outputStyle` | Adjust system prompt output style | `"Explanatory"` |
| `parentSettingsBehavior` | Embedding host managed settings vs admin tier: `"first-wins"` or `"merge"` | `"merge"` |
| `plansDirectory` | Custom plan file storage path (relative to project root) | `"./plans"` |
| `policyHelper` | Admin executable to compute managed settings dynamically | `{"path": "/usr/local/bin/claude-policy"}` |
| `preferredNotifChannel` | Notification method | `"terminal_bell"` |
| `prefersReducedMotion` | Reduce UI animations for accessibility | `true` |
| `prUrlTemplate` | URL template for PR badge (supports `{host}`, `{owner}`, `{repo}`, `{number}`) | `"https://reviews.example.com/{owner}/{repo}/pull/{number}"` |
| `respectGitignore` | Whether `@` file picker respects `.gitignore` patterns | `false` |
| `showClearContextOnPlanAccept` | Show "clear context" option on plan accept screen | `true` |
| `showThinkingSummaries` | Show extended thinking summaries in interactive sessions | `true` |
| `showTurnDuration` | Show turn duration messages (default `true`) | `false` |
| `skillListingBudgetFraction` | Fraction of context window for skill listing (default 0.01) | `0.02` |
| `skillOverrides` | Per-skill visibility: `"on"`, `"name-only"`, `"user-invocable-only"`, `"off"` | `{"deploy": "off"}` |
| `skipWebFetchPreflight` | Skip WebFetch domain safety check (useful for Bedrock/Vertex) | `true` |
| `spinnerTipsEnabled` | Show tips in spinner (default `true`) | `false` |
| `spinnerTipsOverride` | Override spinner tips with custom strings | `{"excludeDefault": true, "tips": ["Use tool X"]}` |
| `spinnerVerbs` | Customize spinner action verbs | `{"mode": "append", "verbs": ["Pondering"]}` |
| `sshConfigs` | SSH connections for Desktop environment dropdown | `[{"id": "dev-vm", "name": "Dev VM", "sshHost": "user@dev.example.com"}]` |
| `statusLine` | Custom status line command | `{"type": "command", "command": "~/.claude/statusline.sh"}` |
| `syntaxHighlightingDisabled` | Disable syntax highlighting | `true` |
| `teammateMode` | Agent team display: `"auto"`, `"in-process"`, or `"tmux"` | `"in-process"` |
| `terminalProgressBarEnabled` | Show terminal progress bar in supported terminals (default `true`) | `false` |
| `tui` | Terminal UI renderer: `"fullscreen"` or `"default"` | `"fullscreen"` |
| `useAutoModeDuringPlan` | Use auto mode semantics in plan mode (default `true`) | `false` |
| `viewMode` | Transcript view: `"default"`, `"verbose"`, `"focus"` | `"verbose"` |
| `voice` | Voice dictation settings: `enabled`, `mode` (`"hold"` or `"tap"`), `autoSubmit` | `{ "enabled": true, "mode": "tap" }` |
| `worktree.baseRef` | New worktree branching: `"fresh"` or `"head"` | `"head"` |
| `worktree.symlinkDirectories` | Directories to symlink into worktrees | `["node_modules"]` |
| `worktree.sparsePaths` | Directories for git sparse-checkout in each worktree | `["packages/my-app"]` |

### Global Config Settings (stored in `~/.claude.json`, not `settings.json`)

| Key | Description | Example |
| :--- | :--- | :--- |
| `autoConnectIde` | Auto-connect to running IDE when starting from external terminal (default `false`) | `true` |
| `autoInstallIdeExtension` | Auto-install IDE extension in VS Code terminal (default `true`) | `false` |
| `externalEditorContext` | Prepend Claude's previous response when opening external editor with `Ctrl+G` | `true` |
| `teammateDefaultModel` | Default model for agent team teammates | `"sonnet"` |

### Managed-Only Settings

These keys are **only read from managed settings** and are ignored if placed in user/project settings:

| Key | Effect |
| :--- | :--- |
| `allowedChannelPlugins` | Allowlist of channel plugins (requires `channelsEnabled: true`) |
| `allowManagedHooksOnly` | Only load managed and SDK hooks; block user/project hooks |
| `allowManagedMcpServersOnly` | Only `allowedMcpServers` from managed settings are respected |
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `channelsEnabled` | Allow channels for the organization |
| `claudeMd` | Org-wide CLAUDE.md instructions injected into every session |
| `forceRemoteSettingsRefresh` | Block startup until remote settings are freshly fetched |
| `parentSettingsBehavior` | How embedding host managed settings interact with admin tier: `"first-wins"` or `"merge"` |
| `pluginTrustMessage` | Custom message appended to plugin trust warning |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed `allowRead` paths respected |
| `sandbox.network.allowManagedDomainsOnly` | Only managed `allowedDomains` and WebFetch rules respected |
| `strictKnownMarketplaces` | Allowlist of permitted marketplace sources |
| `wslInheritsWindowsSettings` | WSL reads managed settings from Windows policy chain |

### Permission Settings

```json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Read(~/.zshrc)"],
    "ask": ["Bash(git push *)"],
    "deny": ["WebFetch", "Bash(curl *)", "Read(./.env)"],
    "additionalDirectories": ["../docs/"],
    "defaultMode": "acceptEdits",
    "disableBypassPermissionsMode": "disable",
    "skipDangerousModePermissionPrompt": true
  }
}
```

**Rule evaluation order:** deny → ask → allow. First matching rule wins.

### Permission Rule Syntax

| Pattern | Matches |
| :--- | :--- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Bash(* --version)` | Any command ending with `--version` |
| `Read(./.env)` | Reading `.env` in current directory |
| `Read(//Users/alice/secrets/**)` | Absolute path (note double slash for absolute) |
| `Read(/src/**)` | Path relative to project root |
| `Read(~/Documents/*.pdf)` | Path relative to home directory |
| `Edit(/docs/**)` | File edits in `<project>/docs/` |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer__navigate` | Specific MCP tool |
| `Agent(my-agent)` | Specific subagent |

**Read/Edit path anchors:** `//path` = absolute, `~/path` = home-relative, `/path` = project-root-relative, `path` or `./path` = cwd-relative.

### Permission Modes

| Mode | What runs without asking | Best for |
| :--- | :--- | :--- |
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem cmds (`mkdir`, `touch`, `mv`, `cp`, etc.) | Iterating on code |
| `plan` | Reads only (no edits, just plans) | Exploring a codebase |
| `auto` | Everything, with background classifier checks | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down CI |
| `bypassPermissions` | Everything (no checks) | Isolated containers/VMs only |

Set with `--permission-mode <mode>`, or persist with `permissions.defaultMode` in settings. Cycle modes with `Shift+Tab` in CLI.

**Auto mode requirements:** Max, Team, Enterprise, or API plan (not Pro); Claude Sonnet 4.6, Opus 4.6, or Opus 4.7; Anthropic API only (not Bedrock/Vertex/Foundry); admin must enable on Team/Enterprise.

**Protected paths** (never auto-approved except in `bypassPermissions`): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`), plus `.gitconfig`, `.gitmodules`, `.bashrc`, `.zshrc`, `.mcp.json`, `.claude.json`.

### Sandbox Settings

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "excludedCommands": ["docker *"],
    "filesystem": {
      "allowWrite": ["/tmp/build", "~/.kube"],
      "denyRead": ["~/.aws/credentials"]
    },
    "network": {
      "allowedDomains": ["github.com", "*.npmjs.org"],
      "deniedDomains": ["sensitive.cloud.example.com"],
      "allowUnixSockets": ["/var/run/docker.sock"],
      "allowLocalBinding": true
    }
  }
}
```

**Sandbox path prefixes:** `/` = absolute, `~/` = home-relative, `./` or no prefix = project-root (project settings) or `~/.claude` (user settings).

| Sandbox Key | Description |
| :--- | :--- |
| `enabled` | Enable sandboxing (macOS, Linux, WSL2). Default: `false` |
| `failIfUnavailable` | Exit on startup if sandbox cannot start. Default: `false` |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed. Default: `true` |
| `excludedCommands` | Commands that run outside the sandbox |
| `allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch. Default: `true` |
| `filesystem.allowWrite` | Paths where sandboxed commands can write (arrays merge across scopes) |
| `filesystem.denyWrite` | Paths where sandboxed commands cannot write |
| `filesystem.denyRead` | Paths where sandboxed commands cannot read |
| `filesystem.allowRead` | Re-allow reading within `denyRead` regions |
| `network.allowedDomains` | Allowed outbound domains (supports wildcards) |
| `network.deniedDomains` | Blocked outbound domains (takes precedence over allowed) |
| `network.allowUnixSockets` | Unix socket paths accessible in sandbox (macOS) |
| `network.allowAllUnixSockets` | Allow all Unix socket connections (Linux/WSL2) |
| `network.allowLocalBinding` | Allow binding to localhost ports (macOS) |
| `network.allowMachLookup` | Additional XPC/Mach service names (macOS, supports `*` prefix) |
| `network.httpProxyPort` | HTTP proxy port for bring-your-own proxy |
| `network.socksProxyPort` | SOCKS5 proxy port for bring-your-own proxy |
| `enableWeakerNestedSandbox` | Weaker sandbox for unprivileged Docker (Linux/WSL2). **Reduces security.** |
| `enableWeakerNetworkIsolation` | Allow system TLS trust service in sandbox (macOS). **Reduces security.** |
| `bwrapPath` | (Managed only, Linux/WSL2) Absolute path to `bwrap` binary |
| `socatPath` | (Managed only, Linux/WSL2) Absolute path to `socat` binary |

### Auto Mode Configuration (`autoMode`)

Configure the classifier's trust context in user settings, local project settings, or managed settings (NOT shared project settings):

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp",
      "Trusted cloud buckets: s3://acme-builds",
      "Trusted internal domains: *.corp.example.com"
    ],
    "allow": ["$defaults", "Deploying to staging is allowed"],
    "soft_deny": ["$defaults", "Never run database migrations outside the migrations CLI"],
    "hard_deny": ["$defaults", "Never send repository contents to third-party APIs"]
  }
}
```

**Classifier precedence:** `hard_deny` (unconditional) → `soft_deny` (user intent or `allow` can override) → `allow` (exceptions to soft blocks) → explicit user intent.

**Always include `"$defaults"`** in each array to inherit built-in rules. Omitting it replaces the entire built-in list for that field.

Inspect your effective config:
- `claude auto-mode defaults` — print built-in rules
- `claude auto-mode config` — print effective merged config
- `claude auto-mode critique` — AI feedback on your custom rules

### Server-Managed Settings

- Requires Claude for Teams or Enterprise plan
- Configured via Claude.ai admin console under **Admin Settings > Claude Code > Managed settings**
- Fetched at startup and polled hourly; cached through network failures
- Takes highest precedence; cannot be overridden by user/project settings
- **Not available** on Amazon Bedrock, Google Vertex AI, Microsoft Foundry, or custom `ANTHROPIC_BASE_URL`
- Use `forceRemoteSettingsRefresh: true` to block startup if fetch fails (fail-closed)
- Security dialogs shown before applying shell command settings, custom env vars, or hooks

### Admin Deployment Decision Map

| Decision | Key settings |
| :--- | :--- |
| API provider | Auth via `ANTHROPIC_API_KEY`, Bedrock, Vertex, or Foundry |
| Settings delivery | Server-managed (console) vs MDM plist/registry vs file-based |
| Permission lockdown | `allowManagedPermissionRulesOnly`, `permissions.disableBypassPermissionsMode` |
| Sandboxing | `sandbox.enabled`, `sandbox.network.allowedDomains` |
| MCP control | `allowedMcpServers`, `deniedMcpServers`, `allowManagedMcpServersOnly` |
| Plugin control | `strictKnownMarketplaces`, `blockedMarketplaces` |
| Hook restrictions | `allowManagedHooksOnly`, `allowedHttpHookUrls` |
| Version floor | `minimumVersion` |

### Key Environment Variables

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key (overrides subscription when set) |
| `ANTHROPIC_MODEL` | Default model |
| `ANTHROPIC_BASE_URL` | Override API endpoint (proxy/gateway) |
| `CLAUDE_CONFIG_DIR` | Override config directory (default `~/.claude`) |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_DISABLE_THINKING` | Force-disable extended thinking |
| `CLAUDE_CODE_EFFORT_LEVEL` | Effort level: `low`, `medium`, `high`, `xhigh`, `max`, `auto` |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen rendering (equivalent to `tui: "fullscreen"`) |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Skip writing session transcripts to disk |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess environments |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_MAX_TURNS` | Cap agentic turns |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Context % at which auto-compaction triggers (1–100) |
| `CLAUDE_CODE_SIMPLE` / `--bare` | Minimal system prompt, only Bash and file tools |
| `CLAUDE_CODE_DISABLE_AGENT_VIEW` | Turn off background agents and agent view |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | Disable all background task functionality |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry data collection |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | Credential refresh interval for `apiKeyHelper` |
| `BASH_DEFAULT_TIMEOUT_MS` | Default timeout for bash commands (default 120000ms) |
| `BASH_MAX_TIMEOUT_MS` | Maximum bash timeout (default 600000ms) |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget |
| `MCP_TIMEOUT` | MCP server startup timeout (default 30000ms) |
| `DISABLE_AUTOUPDATER` | Disable automatic background updates |
| `DISABLE_TELEMETRY` / `DO_NOT_TRACK` | Opt out of telemetry |
| `DISABLE_COMPACT` | Disable all compaction (automatic and manual `/compact`) |
| `DISABLE_AUTO_COMPACT` | Disable automatic compaction only |
| `CLAUDE_CODE_OAUTH_TOKEN` | OAuth access token for Claude.ai authentication |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Maximum output tokens for most requests |
| `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` | Max parallel read-only tools and subagents (default 10) |
| `TASK_MAX_OUTPUT_LENGTH` | Max chars in subagent output before truncation (default 32000) |
| `CLAUDECODE` | Set to `1` in shells Claude Code spawns; use to detect Claude-spawned subprocesses |

Environment variables can also be set in `settings.json` under the `env` key to apply them to every session.

### Verify Active Settings

Run `/status` inside Claude Code. The `Setting sources` line lists each loaded layer (e.g. `User settings`, `Project local settings`, `Enterprise managed settings (remote)`). A layer appears only if it has at least one key set.

### Example settings.json

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": ["Bash(npm run lint)", "Bash(npm run test *)"],
    "deny": ["Bash(curl *)", "Read(./.env)", "Read(./secrets/**)"],
    "defaultMode": "acceptEdits"
  },
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp"
  }
}
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Settings](references/claude-code-settings.md) — complete settings reference: scopes, settings.json keys, sandbox, permissions, worktree, attribution, plugin configuration, precedence rules
- [Configure permissions](references/claude-code-permissions.md) — permission system, rule syntax, tool-specific patterns, modes, working directories, managed policies
- [Choose a permission mode](references/claude-code-permission-modes.md) — available modes, switching modes, auto mode details, protected paths
- [Environment variables](references/claude-code-env-vars.md) — complete reference for all environment variables that control Claude Code behavior
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — server delivery via Claude.ai admin console, caching, fail-closed enforcement, security considerations
- [Configure auto mode](references/claude-code-auto-mode-config.md) — `autoMode` settings block, trusted infrastructure, classifier rule overrides, CLI subcommands
- [Set up Claude Code for your organization](references/claude-code-admin-setup.md) — admin deployment decision map: API providers, settings delivery mechanisms, enforcement controls, monitoring, data handling

## Sources

- Settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
- Set up Claude Code for your organization: https://code.claude.com/docs/en/admin-setup.md
