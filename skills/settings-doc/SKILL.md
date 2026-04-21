---
name: settings-doc
description: Complete official documentation for Claude Code settings, permissions, permission modes, environment variables, and server-managed settings — configuration scopes, settings.json keys, permission rule syntax, sandbox settings, managed policies, and the full environment variable reference.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings and configuration.

## Quick Reference

### Configuration scopes and file locations

| Scope | Location | Shared with team? | Priority |
| :---- | :------- | :----------------- | :------- |
| **Managed** | Server, MDM/plist, registry, or `managed-settings.json` | Yes (IT-deployed) | 1 (highest) |
| **Command line** | `--permission-mode`, etc. | No | 2 |
| **Local** | `.claude/settings.local.json` | No (gitignored) | 3 |
| **Project** | `.claude/settings.json` | Yes (committed) | 4 |
| **User** | `~/.claude/settings.json` | No | 5 (lowest) |

Managed settings file paths by platform:

| Platform | Path |
| :------- | :--- |
| macOS | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux/WSL | `/etc/claude-code/managed-settings.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-settings.json` |

Drop-in fragments go in `managed-settings.d/` alongside the base file. Files are merged alphabetically; use numeric prefixes like `10-telemetry.json` to control merge order.

### Key settings.json options

| Key | Description | Example |
| :-- | :---------- | :------ |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `env` | Env vars applied to every session | `{"FOO": "bar"}` |
| `permissions` | Allow/ask/deny rules + permission mode | See below |
| `hooks` | Lifecycle hook commands | See hooks-doc |
| `apiKeyHelper` | Script to generate auth token | `"/bin/gen_key.sh"` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) | `"stable"` |
| `cleanupPeriodDays` | Session file retention days (default: 30) | `20` |
| `companyAnnouncements` | Startup announcements (cycled randomly) | `["Welcome!"]` |
| `defaultShell` | `"bash"` (default) or `"powershell"` | `"powershell"` |
| `disableAllHooks` | Disable all hooks and custom status line | `true` |
| `effortLevel` | Persist effort level: `low`/`medium`/`high`/`xhigh` | `"xhigh"` |
| `enableAllProjectMcpServers` | Auto-approve all project `.mcp.json` servers | `true` |
| `language` | Claude's preferred response language | `"japanese"` |
| `minimumVersion` | Floor version for auto-updates | `"2.1.100"` |
| `outputStyle` | Custom output style name | `"Explanatory"` |
| `prefersReducedMotion` | Reduce UI animations | `true` |
| `respectGitignore` | `@` picker respects `.gitignore` (default: `true`) | `false` |
| `statusLine` | Custom status line command | `{"type":"command","command":"~/.claude/statusline.sh"}` |
| `tui` | `"fullscreen"` or `"default"` renderer | `"fullscreen"` |
| `viewMode` | Default transcript view: `default`/`verbose`/`focus` | `"verbose"` |
| `voiceEnabled` | Enable push-to-talk voice dictation | `true` |
| `alwaysThinkingEnabled` | Enable extended thinking by default | `true` |
| `showThinkingSummaries` | Show thinking summaries in interactive mode | `true` |
| `includeGitInstructions` | Include built-in git instructions (default: `true`) | `false` |
| `attribution` | Customize git commit/PR attribution | `{"commit":"...","pr":""}` |
| `fileSuggestion` | Custom `@` file autocomplete command | `{"type":"command","command":"~/.claude/file-suggestion.sh"}` |
| `plansDirectory` | Where plan files are stored | `"./plans"` |
| `autoMemoryDirectory` | Custom auto memory storage directory | `"~/my-memory-dir"` |
| `autoMode` | Auto mode classifier config (env/allow/soft_deny) | `{"environment":["..."]}` |
| `disableAutoMode` | Prevent auto mode: `"disable"` | `"disable"` |
| `awaySummaryEnabled` | Session recap after time away | `true` |
| `spinnerTipsEnabled` | Show tips in spinner (default: `true`) | `false` |
| `feedbackSurveyRate` | Survey probability 0–1 | `0.05` |
| `availableModels` | Restrict selectable models | `["sonnet","haiku"]` |
| `forceLoginMethod` | `claudeai` or `console` | `"claudeai"` |
| `forceLoginOrgUUID` | Require specific org UUID at login | `"xxxx-..."` |

### Managed-only settings (no effect in user/project settings)

| Key | Description |
| :-- | :---------- |
| `allowedChannelPlugins` | Allowlist of channel plugins; requires `channelsEnabled: true` |
| `allowManagedHooksOnly` | Block all non-managed hooks |
| `allowManagedMcpServersOnly` | Only `allowedMcpServers` from managed settings apply |
| `allowManagedPermissionRulesOnly` | Block user/project allow/ask/deny rules |
| `blockedMarketplaces` | Block marketplace sources before download |
| `channelsEnabled` | Allow channels for Team/Enterprise users |
| `forceRemoteSettingsRefresh` | Block startup until server settings fetched; exit on failure |
| `pluginTrustMessage` | Custom text appended to plugin trust warning |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed `allowRead` paths respected |
| `sandbox.network.allowManagedDomainsOnly` | Only managed `allowedDomains` + WebFetch rules respected |
| `strictKnownMarketplaces` | Allowlist of marketplaces users may add |

### Permission settings (under `permissions` key)

| Key | Description | Example |
| :-- | :---------- | :------ |
| `allow` | Tool use allowed without prompt | `["Bash(npm run *)", "Read(~/.zshrc)"]` |
| `ask` | Prompt for confirmation | `["Bash(git push *)"]` |
| `deny` | Block tool use | `["WebFetch", "Read(./.env)"]` |
| `additionalDirectories` | Extra working directories for file access | `["../docs/"]` |
| `defaultMode` | Default permission mode | `"acceptEdits"` |
| `disableBypassPermissionsMode` | Prevent bypass mode: `"disable"` | `"disable"` |
| `skipDangerousModePermissionPrompt` | Skip bypass mode confirmation prompt | `true` |

### Permission rule syntax

Rules follow `Tool` or `Tool(specifier)`. Evaluation order: **deny first, then ask, then allow**. First match wins.

| Pattern | Effect |
| :------ | :----- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Bash(git * main)` | e.g. `git checkout main`, `git push origin main` |
| `Read(./.env)` | Read the `.env` file |
| `Read(//Users/alice/secrets/**)` | Absolute path read |
| `Read(~/Documents/*.pdf)` | Home-relative read |
| `Edit(/src/**/*.ts)` | Project-root-relative edit |
| `WebFetch(domain:example.com)` | Fetch to example.com |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `Agent(Explore)` | Specific subagent |

Read/Edit path prefixes: `//path` = absolute, `~/path` = home-relative, `/path` = project-root-relative, `path` or `./path` = cwd-relative.

### Permission modes

Set via `permissions.defaultMode`, `--permission-mode` flag, or `Shift+Tab` to cycle in CLI.

| Mode | What runs without asking | Best for |
| :--- | :----------------------- | :------- |
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands | Iterating on code |
| `plan` | Reads only (Claude writes plan, not code) | Exploring before changing |
| `auto` | Everything with background classifier checks | Long tasks, reduced prompts |
| `dontAsk` | Only pre-approved tools + read-only Bash | Locked-down CI/scripts |
| `bypassPermissions` | Everything except protected paths | Isolated containers/VMs only |

Auto mode requires Claude Code v2.1.83+, Max/Team/Enterprise/API plan, and specific models (Sonnet 4.6, Opus 4.6, or Opus 4.7). Not available on Pro or third-party providers.

Protected paths (never auto-approved in any mode): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`), and key dotfiles (`.gitconfig`, `.bashrc`, `.zshrc`, `.mcp.json`, etc.).

### Sandbox settings (under `sandbox` key)

| Key | Description | Example |
| :-- | :---------- | :------ |
| `enabled` | Enable bash sandboxing | `true` |
| `failIfUnavailable` | Exit at startup if sandbox can't start | `true` |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: `true`) | `true` |
| `excludedCommands` | Commands that run outside sandbox | `["docker *"]` |
| `allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape (default: `true`) | `false` |
| `filesystem.allowWrite` | Paths sandbox can write to | `["/tmp/build", "~/.kube"]` |
| `filesystem.denyWrite` | Paths sandbox cannot write | `["/etc"]` |
| `filesystem.denyRead` | Paths sandbox cannot read | `["~/.aws/credentials"]` |
| `filesystem.allowRead` | Re-allow reading within `denyRead` regions | `["."]` |
| `network.allowedDomains` | Outbound domains allowed (supports wildcards) | `["github.com", "*.npmjs.org"]` |
| `network.deniedDomains` | Outbound domains blocked | `["sensitive.cloud.example.com"]` |
| `network.allowUnixSockets` | Unix sockets accessible (macOS only) | `["~/.ssh/agent-socket"]` |
| `network.allowLocalBinding` | Allow localhost port binding (macOS only) | `true` |
| `network.httpProxyPort` | Bring-your-own HTTP proxy port | `8080` |

Sandbox path prefixes: `/` = absolute, `~/` = home-relative, `./` or no prefix = project-root-relative (or `~/.claude` for user settings).

Arrays merge across all scopes (user + project + managed are concatenated and deduplicated, not replaced).

### Worktree settings

| Key | Description | Example |
| :-- | :---------- | :------ |
| `worktree.symlinkDirectories` | Directories to symlink into each worktree | `["node_modules", ".cache"]` |
| `worktree.sparsePaths` | Paths for git sparse-checkout in worktrees | `["packages/my-app"]` |

### Plugin settings

| Key | Description | Example |
| :-- | :---------- | :------ |
| `enabledPlugins` | Enable/disable plugins by `name@marketplace` | `{"formatter@acme-tools": true}` |
| `extraKnownMarketplaces` | Register additional marketplaces for team | `{"acme-tools": {"source": {...}}}` |
| `strictKnownMarketplaces` | (Managed only) Allowlist of addable marketplaces | `[{"source":"github","repo":"..."}]` |
| `blockedMarketplaces` | (Managed only) Block specific marketplace sources | `[{"source":"github","repo":"..."}]` |

Marketplace source types: `github`, `git`, `url`, `npm`, `file`, `directory`, `hostPattern`, `settings` (inline).

### Attribution settings (under `attribution` key)

| Key | Description |
| :-- | :---------- |
| `commit` | Attribution text for git commits (empty string = hide) |
| `pr` | Attribution text for pull request descriptions (empty string = hide) |

### Global config settings (in `~/.claude.json`, not `settings.json`)

| Key | Description | Example |
| :-- | :---------- | :------ |
| `autoConnectIde` | Auto-connect to IDE from external terminal | `true` |
| `autoInstallIdeExtension` | Auto-install IDE extension in VS Code | `false` |
| `autoScrollEnabled` | Follow new output in fullscreen (default: `true`) | `false` |
| `editorMode` | Input key bindings: `"normal"` or `"vim"` | `"vim"` |
| `showTurnDuration` | Show turn duration after responses | `false` |
| `teammateMode` | Agent team display: `auto`/`in-process`/`tmux` | `"in-process"` |

### Server-managed settings

Delivers settings from Anthropic's servers via the Claude.ai admin console. Available for Teams and Enterprise plans. Claude Code fetches settings at startup and polls hourly.

- Configure at: Claude.ai > Admin Settings > Claude Code > Managed settings
- Format: same JSON as `settings.json`; all settings keys supported including managed-only ones
- Server-managed takes priority over file-based managed settings (sources do not merge)
- `forceRemoteSettingsRefresh: true` blocks startup until settings are freshly fetched
- Not available when using Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`

### Key environment variables (selected)

| Variable | Purpose |
| :------- | :------ |
| `ANTHROPIC_API_KEY` | API key (overrides subscription when set) |
| `ANTHROPIC_BASE_URL` | Override API endpoint / proxy |
| `ANTHROPIC_MODEL` | Override default model |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry (`1`) |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Skip writing session transcripts to disk |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess environments |
| `DISABLE_AUTOUPDATER` | Disable automatic updates |
| `DISABLE_AUTO_COMPACT` | Disable automatic context compaction |
| `DISABLE_TELEMETRY` | Opt out of Statsig telemetry |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget |
| `BASH_DEFAULT_TIMEOUT_MS` | Bash command timeout (default: 120000ms) |
| `BASH_MAX_TIMEOUT_MS` | Maximum bash timeout (default: 600000ms) |
| `MCP_TIMEOUT` | MCP server startup timeout (default: 30000ms) |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | Disable background task functionality |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level: `low`/`medium`/`high`/`xhigh`/`max`/`auto` |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Context % to trigger compaction (1–100) |
| `HTTP_PROXY` / `HTTPS_PROXY` | HTTP/HTTPS proxy server |
| `CLAUDECODE` | Set to `1` in shells spawned by Claude Code |

Any environment variable can also be set in `settings.json` under the `env` key to apply to every session.

Run `/status` to see which settings sources are active and where each value comes from.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — configuration scopes, settings files, all settings.json keys, permission settings, sandbox settings, attribution, plugin configuration, environment variables overview
- [Configure permissions](references/claude-code-permissions.md) — permission system, rule syntax, tool-specific patterns, working directories, managed settings, auto mode classifier configuration
- [Choose a permission mode](references/claude-code-permission-modes.md) — all six modes (default, acceptEdits, plan, auto, dontAsk, bypassPermissions), how to switch, auto mode requirements and classifier behavior, protected paths
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — admin console setup, delivery and caching, fail-closed enforcement, security approval dialogs, security considerations
- [Environment variables](references/claude-code-env-vars.md) — complete reference for all environment variables that control Claude Code behavior

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
