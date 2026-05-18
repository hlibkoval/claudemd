---
name: settings-doc
description: Complete official documentation for Claude Code settings and configuration — settings files, scopes, precedence, all available settings keys, permission modes, permission rule syntax, environment variables, managed/server-managed settings, admin deployment, and auto mode configuration.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, permission modes, environment variables, managed settings, admin setup, and auto mode configuration.

## Quick Reference

### Configuration Scopes and Files

| Scope | Location | Who it affects | Shared? |
| :--- | :--- | :--- | :--- |
| **Managed** | Server-managed, plist/registry, or system `managed-settings.json` | All users on machine | Yes (IT-deployed) |
| **User** | `~/.claude/settings.json` | You, all projects | No |
| **Project** | `.claude/settings.json` | All collaborators | Yes (committed) |
| **Local** | `.claude/settings.local.json` | You, this repo only | No (gitignored) |

Precedence (highest to lowest): Managed > Command line args > Local > Project > User

**Array settings** (e.g. `permissions.allow`, `sandbox.filesystem.allowWrite`) **merge across scopes** — entries concatenate rather than override.

### Managed Settings Delivery Mechanisms

| Mechanism | Platform | Priority |
| :--- | :--- | :--- |
| Server-managed (Claude admin console) | All | Highest |
| plist (`com.anthropic.claudecode`) | macOS | High |
| Registry (`HKLM\SOFTWARE\Policies\ClaudeCode`) | Windows | High |
| File (`/Library/Application Support/ClaudeCode/managed-settings.json` / `/etc/claude-code/` / `C:\Program Files\ClaudeCode\`) | All | Medium |
| HKCU registry | Windows | Lowest |

Drop-in directory `managed-settings.d/*.json` is also supported alongside the base file (sorted alphabetically, deep-merged).

### Key settings.json Fields

| Key | Description | Example |
| :--- | :--- | :--- |
| `agent` | Run main thread as a named subagent | `"code-reviewer"` |
| `allowedHttpHookUrls` | Allowlist URL patterns for HTTP hooks | `["https://hooks.example.com/*"]` |
| `allowedMcpServers` | (Managed) Allowlist of MCP servers | `[{"serverName": "github"}]` |
| `allowManagedHooksOnly` | (Managed) Only managed hooks load | `true` |
| `allowManagedMcpServersOnly` | (Managed) Only managed MCP servers apply | `true` |
| `allowManagedPermissionRulesOnly` | (Managed) Only managed permission rules apply | `true` |
| `alwaysThinkingEnabled` | Enable extended thinking by default | `true` |
| `apiKeyHelper` | Script to generate auth value for model requests | `"/bin/gen_key.sh"` |
| `attribution` | Customize git commit and PR attribution | `{"commit": "...", "pr": ""}` |
| `autoMemoryEnabled` | Enable/disable auto memory | `false` |
| `autoMode` | Configure auto mode classifier rules | `{"environment": [...]}` |
| `autoUpdatesChannel` | Update channel: `"stable"` or `"latest"` | `"stable"` |
| `availableModels` | Restrict which models users can select | `["sonnet", "haiku"]` |
| `channelsEnabled` | (Managed) Allow channels for the org | `true` |
| `claudeMd` | (Managed) Org-wide CLAUDE.md instructions | `"Always run lint first."` |
| `claudeMdExcludes` | Glob patterns of CLAUDE.md files to skip | `["**/vendor/**/CLAUDE.md"]` |
| `cleanupPeriodDays` | Session file retention days (default: 30) | `20` |
| `companyAnnouncements` | Startup announcements to cycle through | `["Welcome to Acme!"]` |
| `defaultShell` | Default shell for input-box commands | `"powershell"` |
| `deniedMcpServers` | (Managed) Denylist of MCP servers | `[{"serverName": "filesystem"}]` |
| `disableAgentView` | Disable background agents/agent view | `true` |
| `disableAllHooks` | Disable all hooks and custom status line | `true` |
| `disableAutoMode` | Set `"disable"` to prevent auto mode | `"disable"` |
| `disabledMcpjsonServers` | List of .mcp.json MCP servers to reject | `["filesystem"]` |
| `disableRemoteControl` | Disable Remote Control | `true` |
| `disableSkillShellExecution` | (Managed) Disable shell execution in skills | `true` |
| `editorMode` | Key binding mode: `"normal"` or `"vim"` | `"vim"` |
| `effortLevel` | Persist effort level: `"low"` / `"medium"` / `"high"` / `"xhigh"` | `"xhigh"` |
| `enableAllProjectMcpServers` | Auto-approve all project .mcp.json servers | `true` |
| `enabledMcpjsonServers` | List of .mcp.json servers to approve | `["memory", "github"]` |
| `env` | Environment variables for every session | `{"FOO": "bar"}` |
| `fastModePerSessionOptIn` | Fast mode off by default each session | `true` |
| `feedbackSurveyRate` | Probability (0–1) survey appears | `0.05` |
| `fileSuggestion` | Custom command for @ file autocomplete | `{"type": "command", "command": "~/.claude/file-suggestion.sh"}` |
| `forceLoginMethod` | Restrict login to `"claudeai"` or `"console"` | `"claudeai"` |
| `forceLoginOrgUUID` | Require login to specific org UUID(s) | `"xxxx-xxxx-..."` |
| `forceRemoteSettingsRefresh` | (Managed) Block startup until remote settings fetched | `true` |
| `hooks` | Configure hooks at lifecycle events | See hooks-doc |
| `includeGitInstructions` | Include built-in git workflow instructions | `false` |
| `language` | Claude's preferred response language | `"japanese"` |
| `minimumVersion` | Floor for auto-updates (org-wide minimum) | `"2.1.100"` |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `modelOverrides` | Map model IDs to provider-specific IDs | `{"claude-opus-4-6": "arn:..."}` |
| `outputStyle` | Configure output style | `"Explanatory"` |
| `parentSettingsBehavior` | (Managed) SDK-supplied managed settings behavior: `"first-wins"` or `"merge"` | `"merge"` |
| `permissions` | Permission rules (see below) | — |
| `plansDirectory` | Where plan files are stored | `"./plans"` |
| `policyHelper` | (MDM/system only) Script to compute managed settings dynamically | `{"path": "/usr/local/bin/policy"}` |
| `preferredNotifChannel` | Notification method (auto/terminal_bell/iterm2/etc.) | `"terminal_bell"` |
| `respectGitignore` | @ file picker respects .gitignore | `false` |
| `skillListingBudgetFraction` | Fraction of context window for skill listing | `0.02` |
| `skillOverrides` | Per-skill visibility: `"on"` / `"name-only"` / `"off"` | `{"deploy": "off"}` |
| `skipWebFetchPreflight` | Skip WebFetch domain safety check | `true` |
| `spinnerTipsEnabled` | Show tips in spinner | `false` |
| `statusLine` | Configure custom status line | `{"type": "command", "command": "~/.claude/statusline.sh"}` |
| `strictKnownMarketplaces` | (Managed) Allowlist marketplace sources | `[{"source": "github", "repo": "acme/plugins"}]` |
| `syntaxHighlightingDisabled` | Disable syntax highlighting | `true` |
| `tui` | TUI renderer: `"fullscreen"` or `"default"` | `"fullscreen"` |
| `viewMode` | Default transcript view: `"default"` / `"verbose"` / `"focus"` | `"verbose"` |
| `voice` | Voice dictation settings | `{"enabled": true, "mode": "tap"}` |
| `wslInheritsWindowsSettings` | (Windows Managed) WSL reads Windows policy chain | `true` |

### Permission Settings (under `permissions` key)

| Key | Description | Example |
| :--- | :--- | :--- |
| `allow` | Array of rules to allow tool use | `["Bash(git diff *)"]` |
| `ask` | Array of rules to require confirmation | `["Bash(git push *)"]` |
| `deny` | Array of rules to deny tool use | `["WebFetch", "Read(./.env)"]` |
| `additionalDirectories` | Extra working directories | `["../docs/"]` |
| `defaultMode` | Default permission mode | `"acceptEdits"` |
| `disableBypassPermissionsMode` | Set `"disable"` to prevent bypass mode | `"disable"` |
| `skipDangerousModePermissionPrompt` | Skip bypass permissions confirmation | `true` |

### Permission Rule Syntax

Format: `Tool` or `Tool(specifier)`. Rules evaluated: **deny → ask → allow** (first match wins).

| Rule | Effect |
| :--- | :--- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Bash commands starting with `npm run` |
| `Bash(git * main)` | Commands like `git checkout main` |
| `Read(./.env)` | Reading the `.env` file |
| `Read(~/.zshrc)` | Home directory file |
| `Edit(/src/**/*.ts)` | TypeScript files under project `/src/` |
| `Read(//Users/alice/secrets/**)` | Absolute path (double slash = absolute) |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer__*` | All tools from puppeteer MCP server |
| `Agent(Explore)` | The Explore subagent |

**Path prefix rules for Read/Edit:**

| Prefix | Meaning |
| :--- | :--- |
| `//path` | Absolute from filesystem root |
| `~/path` | Relative to home directory |
| `/path` | Relative to project root |
| `./path` or bare | Relative to current directory |

### Permission Modes

| Mode | What runs without asking | Best for |
| :--- | :--- | :--- |
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands | Iterating on code |
| `plan` | Reads only (writes a plan, does not edit) | Exploring a codebase |
| `auto` | Everything, with background safety checks | Long tasks |
| `dontAsk` | Only pre-approved tools | Locked-down CI |
| `bypassPermissions` | Everything | Isolated containers/VMs only |

Switch modes: `Shift+Tab` in CLI, or `--permission-mode <mode>` at startup.

### Sandbox Settings (under `sandbox` key)

| Key | Description |
| :--- | :--- |
| `sandbox.enabled` | Enable bash sandboxing |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `sandbox.excludedCommands` | Commands that run outside sandbox |
| `sandbox.filesystem.allowWrite` | Paths sandbox can write |
| `sandbox.filesystem.denyWrite` | Paths sandbox cannot write |
| `sandbox.filesystem.denyRead` | Paths sandbox cannot read |
| `sandbox.filesystem.allowRead` | Re-allow reading within denyRead regions |
| `sandbox.network.allowedDomains` | Domains allowed for outbound traffic |
| `sandbox.network.deniedDomains` | Blocked domains (takes precedence over allowed) |
| `sandbox.network.allowManagedDomainsOnly` | (Managed) Only managed allowedDomains apply |

### Worktree Settings

| Key | Description | Example |
| :--- | :--- | :--- |
| `worktree.baseRef` | Branch source: `"fresh"` (origin default) or `"head"` (local HEAD) | `"head"` |
| `worktree.symlinkDirectories` | Directories to symlink into worktrees | `["node_modules"]` |
| `worktree.sparsePaths` | Directories for sparse checkout | `["packages/my-app"]` |

### Global Config Settings (stored in `~/.claude.json`, NOT `settings.json`)

| Key | Description |
| :--- | :--- |
| `autoConnectIde` | Auto-connect to running IDE on startup |
| `autoInstallIdeExtension` | Auto-install IDE extension in VS Code terminal |
| `externalEditorContext` | Prepend last response when opening external editor |
| `teammateDefaultModel` | Default model for agent team teammates |

### Auto Mode Configuration (`autoMode` settings block)

The classifier reads `autoMode` from user settings, local project settings, and managed settings (NOT shared project settings). Entries from each scope combine.

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp",
      "Trusted buckets: s3://acme-build-artifacts",
      "Trusted domains: *.corp.example.com"
    ],
    "allow": ["$defaults", "Deploying to staging is allowed"],
    "soft_deny": ["$defaults", "Never run terraform apply"],
    "hard_deny": ["$defaults", "Never send repo contents to third-party APIs"]
  }
}
```

**Important:** Omitting `"$defaults"` from any array **replaces** the entire built-in default list for that section. Always include it unless you intend to own the full list.

Classifier precedence: `hard_deny` > `soft_deny` > `allow` (exceptions to soft_deny) > explicit user intent.

CLI commands: `claude auto-mode defaults` (print defaults), `claude auto-mode config` (effective config), `claude auto-mode critique` (AI review of custom rules).

### Server-Managed Settings Key Facts

- Requires Claude for Teams or Enterprise plan + network access to `api.anthropic.com`
- Delivered at authentication time, polled hourly during active sessions
- Configure at: Admin Settings > Claude Code > Managed settings in claude.ai
- NOT available on Bedrock, Vertex AI, Foundry, or custom `ANTHROPIC_BASE_URL`
- Settings that execute shell commands, custom env vars, and hooks trigger a **security approval dialog** before applying
- `forceRemoteSettingsRefresh: true` makes CLI exit (rather than continue) if fetch fails at startup
- MCP server configurations cannot be distributed through server-managed settings
- `policyHelper` and `wslInheritsWindowsSettings` require OS-level policy delivery, not server-managed

### Key Environment Variables

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key (overrides subscription) |
| `ANTHROPIC_MODEL` | Model to use |
| `ANTHROPIC_BASE_URL` | Override API endpoint |
| `CLAUDE_CODE_USE_BEDROCK` / `USE_VERTEX` / `USE_FOUNDRY` | Select cloud provider |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level: `low/medium/high/xhigh/max/auto` |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_DISABLE_THINKING` | Force-disable extended thinking |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen rendering |
| `CLAUDE_CODE_OAUTH_TOKEN` | OAuth access token for automated environments |
| `CLAUDE_CODE_MAX_TURNS` | Cap agentic turns |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess environments |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry collection |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout (default: 600000) |
| `DISABLE_AUTOUPDATER` | Disable background auto-updates |
| `DISABLE_TELEMETRY` / `DO_NOT_TRACK` | Opt out of telemetry |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget |
| `MCP_TIMEOUT` | MCP server startup timeout (default: 30000) |
| `OTEL_METRICS_EXPORTER` | OpenTelemetry metrics exporter |

Env vars can also be set permanently via the `env` key in `settings.json`.

### Admin Deployment Decision Map

| Decision | Key settings / references |
| :--- | :--- |
| API provider | Anthropic (Teams/Enterprise/Console), Bedrock, Vertex, Foundry |
| Settings delivery mechanism | Server-managed, plist/registry, file-based |
| Permission enforcement | `allowManagedPermissionRulesOnly`, `disableBypassPermissionsMode` |
| Sandbox enforcement | `sandbox.enabled`, `sandbox.network.allowedDomains` |
| MCP server control | `allowedMcpServers`, `deniedMcpServers`, `allowManagedMcpServersOnly` |
| Plugin marketplace control | `strictKnownMarketplaces`, `blockedMarketplaces` |
| Hook restrictions | `allowManagedHooksOnly`, `allowedHttpHookUrls` |
| Version floor | `minimumVersion` |
| Verify active settings | Run `/status` — shows `Setting sources` with delivery channel |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — all settings keys, scopes, precedence, file locations, permission settings, sandbox settings, worktree settings, attribution, plugin configuration
- [Configure permissions](references/claude-code-permissions.md) — permission system, rule syntax, tool-specific patterns (Bash, Read, Edit, WebFetch, MCP, Agent), working directories, managed settings, sandboxing interaction
- [Choose a permission mode](references/claude-code-permission-modes.md) — all six modes, switching modes across interfaces, auto mode requirements, protected paths
- [Environment variables](references/claude-code-env-vars.md) — complete reference for all environment variables
- [Set up Claude Code for your organization](references/claude-code-admin-setup.md) — admin deployment decision map, API providers, delivery mechanisms, enforcement options, usage visibility, data handling
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — server-managed delivery, admin console setup, security dialogs, caching, fail-closed startup, limitations
- [Configure auto mode](references/claude-code-auto-mode-config.md) — autoMode settings block, trusted infrastructure, block/allow rule overrides, CLI inspection commands

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Set up Claude Code for your organization: https://code.claude.com/docs/en/admin-setup.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
