---
name: settings-doc
description: Complete official documentation for Claude Code settings — settings.json configuration, scopes and precedence, permissions, permission modes, server-managed settings, sandbox configuration, environment variables, and plugin/marketplace settings.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, and environment variables.

## Quick Reference

### Configuration scopes

Settings apply in order of precedence (highest wins):

| Scope       | Location                                                            | Shared?                | Override behavior          |
| :---------- | :------------------------------------------------------------------ | :--------------------- | :------------------------- |
| **Managed** | Server-managed, MDM/plist/registry, or `managed-settings.json`      | Yes (deployed by IT)   | Cannot be overridden       |
| **CLI args** | `--permission-mode`, `--model`, etc.                               | No (session only)      | Overrides local and below  |
| **Local**   | `.claude/settings.local.json`                                       | No (gitignored)        | Overrides project and user |
| **Project** | `.claude/settings.json`                                             | Yes (committed to git) | Overrides user             |
| **User**    | `~/.claude/settings.json`                                           | No                     | Baseline defaults          |

Array-valued settings (like `permissions.allow` or `sandbox.filesystem.allowWrite`) are concatenated and deduplicated across scopes, not replaced.

### Settings files overview

| File                         | Purpose                                                     |
| :--------------------------- | :---------------------------------------------------------- |
| `~/.claude/settings.json`    | Personal global settings                                    |
| `.claude/settings.json`      | Team-shared project settings (committed)                    |
| `.claude/settings.local.json`| Personal project overrides (gitignored)                     |
| `~/.claude.json`             | App state, theme, OAuth, per-project trust, MCP servers     |
| `managed-settings.json`      | Organization-wide policies (cannot be overridden)           |

Managed settings file locations: macOS `/Library/Application Support/ClaudeCode/`, Linux/WSL `/etc/claude-code/`, Windows `C:\Program Files\ClaudeCode\`. Drop-in fragments in `managed-settings.d/` are merged alphabetically on top of the base file.

### Key settings.json fields

| Key                         | Description                                                           |
| :-------------------------- | :-------------------------------------------------------------------- |
| `permissions`               | `allow`, `ask`, `deny` arrays; `defaultMode`; `additionalDirectories` |
| `env`                       | Environment variables applied to every session                        |
| `hooks`                     | Lifecycle event hooks (see hooks-doc)                                 |
| `model`                     | Override default model                                                |
| `sandbox`                   | Bash sandboxing config (filesystem, network)                          |
| `agent`                     | Run main thread as a named subagent                                   |
| `autoMode`                  | Configure auto mode classifier (`environment`, `allow`, `soft_deny`)  |
| `attribution`               | Customize git commit and PR attribution                               |
| `companyAnnouncements`      | Startup messages for users                                            |
| `language`                  | Preferred response language                                           |
| `outputStyle`               | Custom output style                                                   |
| `tui`                       | `"fullscreen"` or `"default"` renderer                                |
| `effortLevel`               | Persist effort level: `low`, `medium`, `high`, `xhigh`                |
| `availableModels`           | Restrict which models users can select                                |
| `statusLine`                | Custom status line command                                            |
| `fileSuggestion`            | Custom `@` file autocomplete command                                  |
| `enabledPlugins`            | Map of `"plugin@marketplace": true/false`                             |
| `extraKnownMarketplaces`    | Additional marketplace sources for the project                        |
| `strictKnownMarketplaces`   | (Managed only) Allowlist of permitted marketplaces                    |
| `blockedMarketplaces`       | (Managed only) Blocklist of marketplace sources                       |

Add `"$schema": "https://json.schemastore.org/claude-code-settings.json"` for editor autocomplete.

### Global config settings (in ~/.claude.json, not settings.json)

| Key                       | Description                                      |
| :------------------------ | :----------------------------------------------- |
| `autoConnectIde`          | Auto-connect to IDE from external terminal       |
| `autoInstallIdeExtension` | Auto-install IDE extension (default: true)        |
| `autoScrollEnabled`       | Follow new output in fullscreen (default: true)   |
| `editorMode`              | `"normal"` or `"vim"`                             |
| `showTurnDuration`        | Show turn duration messages (default: true)        |
| `teammateMode`            | Agent team display: `auto`, `in-process`, `tmux`  |

### Permission modes

| Mode                | Prompts for            | Best for                         |
| :------------------ | :--------------------- | :------------------------------- |
| `default`           | Edits and commands     | Getting started, sensitive work  |
| `acceptEdits`       | Commands only          | Code iteration with post-review  |
| `plan`              | Same as default        | Exploration before changes       |
| `auto`              | Nothing (classifier)   | Long tasks, reducing prompt fatigue |
| `dontAsk`           | Nothing (auto-denies)  | Locked-down CI/scripts           |
| `bypassPermissions` | Protected paths only   | Isolated containers/VMs only     |

Switch modes: `Shift+Tab` in CLI, mode selector in VS Code/Desktop, `--permission-mode <mode>` at startup, or `permissions.defaultMode` in settings.

### Auto mode requirements

- Plan: Max, Team, Enterprise, or API (not Pro)
- Admin must enable in Claude Code admin settings (Team/Enterprise)
- Model: Sonnet 4.6, Opus 4.6, or Opus 4.7 (Team/Enterprise/API); Opus 4.7 only (Max)
- Provider: Anthropic API only (not Bedrock, Vertex, or Foundry)

### Permission rule syntax

Format: `Tool` or `Tool(specifier)`. Evaluated in order: deny first, then ask, then allow.

| Rule                           | Effect                                   |
| :----------------------------- | :--------------------------------------- |
| `Bash`                         | Matches all Bash commands                |
| `Bash(npm run *)`              | Matches commands starting with `npm run` |
| `Read(./.env)`                 | Matches reading `.env` in project root   |
| `Read(~/.ssh/**)`              | Matches reads under home `.ssh/`         |
| `Read(//tmp/file)`             | Matches absolute path `/tmp/file`        |
| `Edit(/src/**/*.ts)`           | Matches edits under project `src/`       |
| `WebFetch(domain:example.com)` | Matches fetch to example.com             |
| `mcp__server__tool`            | Matches specific MCP tool                |
| `Agent(Explore)`               | Matches the Explore subagent             |

Read/Edit patterns follow gitignore spec: `*` matches within a directory, `**` matches recursively. `//path` = absolute, `~/path` = home-relative, `/path` = project-relative, `./path` or bare = cwd-relative.

Bash rules: `*` matches any characters including spaces. `Bash(ls *)` (space before `*`) enforces word boundary. Claude Code strips process wrappers (`timeout`, `time`, `nice`, `nohup`, `stdbuf`) before matching. Compound commands are matched per-subcommand.

### Protected paths (never auto-approved in any mode)

Directories: `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`)

Files: `.gitconfig`, `.gitmodules`, `.bashrc`, `.bash_profile`, `.zshrc`, `.zprofile`, `.profile`, `.ripgreprc`, `.mcp.json`, `.claude.json`

### Sandbox settings

Enable with `sandbox.enabled: true`. Key sub-keys:

| Key                            | Purpose                                         |
| :----------------------------- | :---------------------------------------------- |
| `enabled`                      | Enable bash sandboxing (default: false)          |
| `autoAllowBashIfSandboxed`     | Auto-approve bash when sandboxed (default: true) |
| `excludedCommands`             | Commands that run outside sandbox                |
| `filesystem.allowWrite`        | Additional writable paths                        |
| `filesystem.denyWrite`         | Paths blocked from writing                       |
| `filesystem.denyRead`          | Paths blocked from reading                       |
| `filesystem.allowRead`         | Re-allow reads within denyRead regions           |
| `network.allowedDomains`       | Allowed outbound domains (supports `*`)          |
| `network.deniedDomains`        | Blocked domains (takes precedence over allowed)  |
| `network.allowLocalBinding`    | Allow localhost port binding (macOS, default: false) |

Path prefixes: `/` = absolute, `~/` = home-relative, `./` or bare = project-relative (in project settings) or `~/.claude`-relative (in user settings).

### Managed-only settings

These keys are only read from managed settings and have no effect in user/project files:

`allowedChannelPlugins`, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowManagedPermissionRulesOnly`, `blockedMarketplaces`, `channelsEnabled`, `forceRemoteSettingsRefresh`, `pluginTrustMessage`, `sandbox.filesystem.allowManagedReadPathsOnly`, `sandbox.network.allowManagedDomainsOnly`, `strictKnownMarketplaces`

### Server-managed settings

Centrally configure Claude Code via the Claude.ai admin console (Team and Enterprise plans). Settings are fetched at startup and polled hourly. Cached settings persist through network failures.

- Requires Claude Code v2.1.38+ (Teams) or v2.1.30+ (Enterprise)
- Access: Admin Settings > Claude Code > Managed settings
- Roles: Primary Owner and Owner
- Set `forceRemoteSettingsRefresh: true` for fail-closed startup (blocks until fresh settings arrive)
- Security dialogs shown for hooks, env vars, and shell command settings
- Not available with Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`

Within managed tier, precedence is: server-managed > MDM/OS-level policies > file-based. Only one managed source is used (no cross-tier merging).

### Key environment variables

| Variable                              | Purpose                                           |
| :------------------------------------ | :------------------------------------------------ |
| `ANTHROPIC_API_KEY`                   | API key (overrides subscription)                  |
| `ANTHROPIC_BASE_URL`                  | Override API endpoint (proxy/gateway)             |
| `ANTHROPIC_MODEL`                     | Override model selection                          |
| `CLAUDE_CODE_USE_BEDROCK`             | Use Amazon Bedrock                                |
| `CLAUDE_CODE_USE_VERTEX`              | Use Google Vertex AI                              |
| `CLAUDE_CODE_USE_FOUNDRY`             | Use Microsoft Foundry                             |
| `CLAUDE_CODE_ENABLE_TELEMETRY`        | Enable OpenTelemetry collection                   |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY`     | Disable auto memory                               |
| `CLAUDE_CODE_DISABLE_CLAUDE_MDS`      | Skip all CLAUDE.md loading                        |
| `CLAUDE_CODE_SIMPLE`                  | Minimal system prompt, basic tools only           |
| `CLAUDE_CODE_NO_FLICKER`              | Enable fullscreen rendering                       |
| `CLAUDE_CODE_EFFORT_LEVEL`            | Set effort: `low`, `medium`, `high`, `xhigh`, `max` |
| `DISABLE_TELEMETRY`                   | Opt out of Statsig telemetry                      |
| `DISABLE_AUTOUPDATER`                 | Disable automatic updates                         |
| `DISABLE_AUTO_COMPACT`                | Disable auto-compaction                           |
| `MAX_THINKING_TOKENS`                 | Override thinking token budget                    |
| `BASH_DEFAULT_TIMEOUT_MS`             | Bash command timeout (default: 120000)            |
| `BASH_MAX_TIMEOUT_MS`                 | Max bash timeout (default: 600000)                |
| `CLAUDE_CONFIG_DIR`                   | Override config directory (default: `~/.claude`)  |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB`    | Strip credentials from subprocess environments    |
| `HTTP_PROXY` / `HTTPS_PROXY`         | Proxy configuration                               |
| `CLAUDE_CODE_OAUTH_TOKEN`             | OAuth access token for automated auth             |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY`     | Skip writing session history to disk              |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable telemetry, updates, error reporting  |

Env vars can also be set in `settings.json` under the `env` key to apply across sessions.

### Verify active settings

Run `/status` to see which settings sources are active and their origins. Run `/permissions` to view effective permission rules.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — complete configuration reference covering scopes, settings.json fields, global config, worktree settings, permission settings, sandbox settings, attribution, file suggestion, hook configuration, plugin/marketplace configuration, settings precedence, and verification.
- [Configure permissions](references/claude-code-permissions.md) — permission system, rule syntax for Bash/Read/Edit/WebFetch/MCP/Agent tools, wildcard patterns, compound commands, process wrappers, read-only commands, managed-only settings, auto mode classifier configuration, working directories, permission-sandbox interaction, and example configurations.
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — centralized settings delivery via Claude.ai admin console, fetch and caching behavior, fail-closed startup, security approval dialogs, audit logging, platform availability, and security considerations.
- [Environment variables](references/claude-code-env-vars.md) — full reference of all environment variables controlling Claude Code behavior, including API keys, model configuration, provider selection, telemetry, proxy, timeouts, and feature toggles.
- [Choose a permission mode](references/claude-code-permission-modes.md) — detailed guide to each permission mode (default, acceptEdits, plan, auto, dontAsk, bypassPermissions), switching modes, auto mode requirements and classifier behavior, protected paths, and mode-specific behaviors.

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
