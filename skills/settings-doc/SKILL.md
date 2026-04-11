---
name: settings-doc
description: Complete documentation for Claude Code settings, permissions, permission modes, environment variables, and server-managed (enterprise) configuration. Covers settings.json keys, scope precedence, allow/ask/deny rules, permission rule syntax, sandbox config, managed-only policy keys, and the full env var reference.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code configuration: settings files, permission rules, permission modes, server-managed settings, and environment variables.

## Quick Reference

### Settings scopes (highest to lowest precedence)

| Scope | Location | Shared? |
| :--- | :--- | :--- |
| **Managed** | Server-managed, MDM/plist/registry, or `managed-settings.json` | Yes (deployed by IT) |
| **CLI args** | `--permission-mode`, `--allowedTools`, etc. | Session only |
| **Local** | `.claude/settings.local.json` | No (gitignored) |
| **Project** | `.claude/settings.json` | Yes (committed) |
| **User** | `~/.claude/settings.json` | No |

Array settings (e.g. `permissions.allow`, `sandbox.filesystem.allowWrite`) merge and de-dupe across scopes; scalars follow precedence. Deny at any level overrides allow at any other level.

### Managed settings delivery mechanisms

- **Server-managed** (Teams/Enterprise): configured in Claude.ai admin console, fetched at startup and hourly
- **macOS MDM**: `com.anthropic.claudecode` managed preferences domain
- **Windows**: `HKLM\SOFTWARE\Policies\ClaudeCode` (admin) or `HKCU\...` (user)
- **File-based**: `managed-settings.json` in `/Library/Application Support/ClaudeCode/` (macOS), `/etc/claude-code/` (Linux/WSL), `C:\Program Files\ClaudeCode\` (Windows). Supports drop-in `managed-settings.d/*.json` (alphabetical merge).

### Permission modes

| Mode | What runs without asking | Best for |
| :--- | :--- | :--- |
| `default` | Reads only | Sensitive work, first runs |
| `acceptEdits` | Reads, file edits, `mkdir`/`touch`/`mv`/`cp`/`sed`/`rm`/`rmdir` in cwd | Iterating on code |
| `plan` | Reads only (no edits or commands) | Exploring codebase |
| `auto` | Everything, with classifier safety checks (Team/Enterprise/API only) | Long tasks |
| `dontAsk` | Only pre-approved tools (CI) | Locked-down scripts |
| `bypassPermissions` | Everything except protected paths | Isolated containers/VMs only |

Cycle modes with `Shift+Tab`. Set default with `permissions.defaultMode`. Block `bypassPermissions` via `permissions.disableBypassPermissionsMode: "disable"`.

### Permission rule syntax

Rules follow `Tool` or `Tool(specifier)`. Evaluation order: **deny -> ask -> allow** (first match wins).

| Rule | Effect |
| :--- | :--- |
| `Bash` or `Bash(*)` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Bash(* install)` | Commands ending with ` install` |
| `Bash(git * main)` | e.g. `git checkout main`, `git merge main` |
| `Read(./.env)` | The `.env` file at cwd |
| `Edit(/src/**/*.ts)` | Project-root-relative edits |
| `Read(//Users/alice/**)` | Absolute path (note double-slash) |
| `Read(~/.zshrc)` | Home-relative |
| `WebFetch(domain:example.com)` | Fetches to example.com |
| `mcp__puppeteer__*` | All tools from the `puppeteer` MCP server |
| `Agent(Explore)` | The Explore subagent |

Read/Edit patterns follow gitignore semantics:

| Prefix | Meaning |
| :--- | :--- |
| `//path` | Absolute from filesystem root |
| `~/path` | Home directory |
| `/path` | Project root (NOT absolute) |
| `path` or `./path` | Current working directory |

Bash wildcards: `Bash(ls *)` requires a space before `*` and matches `ls -la` but not `lsof`. `Bash(ls*)` has no word boundary. The `:*` suffix equals trailing `*`. Bash patterns constraining arguments are fragile (protocols, redirects, variables defeat them) — prefer `WebFetch(domain:...)` or PreToolUse hooks for URL filtering.

### Permission settings keys

| Key | Description |
| :--- | :--- |
| `allow` | Array of rules to allow without prompt |
| `ask` | Array of rules to prompt for confirmation |
| `deny` | Array of rules to block (takes precedence) |
| `additionalDirectories` | Extra working directories for file access |
| `defaultMode` | Starting permission mode |
| `disableBypassPermissionsMode` | `"disable"` blocks bypass mode |
| `disableAutoMode` | `"disable"` blocks auto mode |
| `skipDangerousModePermissionPrompt` | Skip confirmation before bypass mode |

### Key settings.json fields

| Key | Purpose |
| :--- | :--- |
| `permissions` | allow/ask/deny/defaultMode/additionalDirectories |
| `env` | Environment variables applied to every session |
| `hooks` | Custom shell commands on lifecycle events |
| `model` | Override default model |
| `availableModels` | Restrict model picker |
| `autoMode` | Auto-mode classifier environment/allow/soft_deny |
| `apiKeyHelper` | Script generating auth header value |
| `sandbox` | Bash sandbox enabled/filesystem/network config |
| `statusLine` | Custom status line command |
| `outputStyle` | Output style name |
| `enabledPlugins` | Map `plugin@marketplace -> bool` |
| `extraKnownMarketplaces` | Additional plugin marketplaces |
| `attribution` | Custom commit/PR attribution |
| `includeCoAuthoredBy` | (deprecated) use `attribution` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` |
| `cleanupPeriodDays` | Session file retention (min 1, default 30) |
| `companyAnnouncements` | Strings shown at startup |
| `forceLoginMethod` / `forceLoginOrgUUID` | Constrain login |
| `disableAllHooks` | Kill-switch for hooks and status line |
| `agent` | Run main thread as named subagent |
| `effortLevel` | `"low"`, `"medium"`, `"high"` persisted effort |
| `alwaysThinkingEnabled` | Extended thinking on by default |
| `showThinkingSummaries` | Show thinking summaries in interactive sessions |
| `language` | Preferred response/dictation language |
| `plansDirectory` | Where plan files are stored |
| `fileSuggestion` | Custom `@` autocomplete command |
| `autoMemoryDirectory` | Auto-memory storage path |

### Managed-only settings (no effect outside managed scope)

- `allowManagedPermissionRulesOnly` — only managed allow/ask/deny apply
- `allowManagedHooksOnly` — block user/project/plugin hooks
- `allowManagedMcpServersOnly` — only managed MCP allowlist applies
- `allowedMcpServers` / `deniedMcpServers` / `disabledMcpjsonServers` / `enabledMcpjsonServers`
- `sandbox.filesystem.allowManagedReadPathsOnly`
- `sandbox.network.allowManagedDomainsOnly`
- `forceRemoteSettingsRefresh` — fail-closed startup if remote fetch fails
- `strictKnownMarketplaces` / `blockedMarketplaces`
- `allowedChannelPlugins` / `channelsEnabled`
- `pluginTrustMessage`

### Sandbox config (`sandbox.*`)

| Key | Purpose |
| :--- | :--- |
| `enabled` | Enable bash sandbox (macOS/Linux/WSL2) |
| `failIfUnavailable` | Exit at startup if sandbox unavailable |
| `autoAllowBashIfSandboxed` | Auto-approve sandboxed bash (default `true`) |
| `excludedCommands` | Commands that run outside the sandbox |
| `allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch |
| `filesystem.allowWrite` / `denyWrite` / `allowRead` / `denyRead` | Path lists (merged across scopes) |
| `network.allowedDomains` | Outbound domain allowlist (wildcards OK) |
| `network.allowUnixSockets` / `allowAllUnixSockets` | Unix socket access |
| `network.allowLocalBinding` | Bind localhost ports (macOS only) |
| `network.httpProxyPort` / `socksProxyPort` | BYO proxy |

Sandbox paths use standard conventions: `/tmp/build` is absolute, `./path` is project-relative. Path lists merge with `Read`/`Edit` permission rules.

### Protected paths (never auto-approved in any mode)

Directories: `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`).
Files: `.gitconfig`, `.gitmodules`, `.bashrc`, `.bash_profile`, `.zshrc`, `.zprofile`, `.profile`, `.ripgreprc`, `.mcp.json`, `.claude.json`.

### Auto-mode classifier (`autoMode`)

Read from user settings, `.claude/settings.local.json`, and managed settings — NOT from shared project settings.

- `autoMode.environment` — prose rules describing trusted repos/buckets/domains
- `autoMode.allow` — prose exceptions to block rules (replaces default list when set)
- `autoMode.soft_deny` — prose block rules (replaces default list when set)

Precedence inside classifier: `soft_deny` -> `allow` -> explicit user intent. Setting `allow` or `soft_deny` replaces the entire default list, so always start by copying the output of `claude auto-mode defaults`. Use `claude auto-mode config` to inspect effective rules and `claude auto-mode critique` for feedback.

### Global config (stored in `~/.claude.json`, not settings.json)

`autoConnectIde`, `autoInstallIdeExtension`, `editorMode`, `showTurnDuration`, `terminalProgressBarEnabled`, `teammateMode`.

### Worktree settings

- `worktree.symlinkDirectories` — e.g. `["node_modules", ".cache"]`
- `worktree.sparsePaths` — sparse-checkout paths for large monorepos

### Environment variables (selected)

Authentication & API:
- `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_BASE_URL`, `ANTHROPIC_CUSTOM_HEADERS`, `ANTHROPIC_BETAS`
- `CLAUDE_CODE_OAUTH_TOKEN`, `CLAUDE_CODE_OAUTH_REFRESH_TOKEN`, `CLAUDE_CODE_OAUTH_SCOPES`
- `ANTHROPIC_BEDROCK_BASE_URL`, `AWS_BEARER_TOKEN_BEDROCK`, `ANTHROPIC_VERTEX_PROJECT_ID`, `ANTHROPIC_VERTEX_BASE_URL`, `ANTHROPIC_FOUNDRY_API_KEY`, `ANTHROPIC_FOUNDRY_BASE_URL`

Model & thinking:
- `ANTHROPIC_MODEL`, `ANTHROPIC_DEFAULT_{HAIKU,SONNET,OPUS}_MODEL`, `ANTHROPIC_CUSTOM_MODEL_OPTION`
- `CLAUDE_CODE_EFFORT_LEVEL`, `CLAUDE_CODE_DISABLE_THINKING`, `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING`, `MAX_THINKING_TOKENS`
- `CLAUDE_CODE_MAX_OUTPUT_TOKENS`, `CLAUDE_CODE_DISABLE_1M_CONTEXT`

Bash/tool behavior:
- `BASH_DEFAULT_TIMEOUT_MS`, `BASH_MAX_TIMEOUT_MS`, `BASH_MAX_OUTPUT_LENGTH`
- `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY`, `CLAUDE_CODE_MAX_RETRIES`, `API_TIMEOUT_MS`
- `CLAUDE_CODE_GLOB_HIDDEN`, `CLAUDE_CODE_GLOB_NO_IGNORE`, `CLAUDE_CODE_GLOB_TIMEOUT_SECONDS`
- `CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS`
- `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR`

Feature kill-switches:
- `CLAUDE_CODE_DISABLE_CLAUDE_MDS`, `CLAUDE_CODE_DISABLE_AUTO_MEMORY`, `CLAUDE_CODE_DISABLE_FILE_CHECKPOINTING`
- `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS`, `CLAUDE_CODE_DISABLE_CRON`, `CLAUDE_CODE_DISABLE_FAST_MODE`
- `CLAUDE_CODE_DISABLE_ATTACHMENTS`, `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS`
- `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` (equivalent to setting `DISABLE_AUTOUPDATER`, `DISABLE_FEEDBACK_COMMAND`, `DISABLE_ERROR_REPORTING`, `DISABLE_TELEMETRY`)
- `CLAUDE_CODE_DISABLE_TERMINAL_TITLE`, `CLAUDE_CODE_DISABLE_MOUSE`

Detection & debugging:
- `CLAUDECODE` (set to `1` in shells Claude spawns; not in hooks/statusLine)
- `CLAUDE_CODE_DEBUG_LOGS_DIR`, `CLAUDE_CODE_DEBUG_LOG_LEVEL`

Telemetry / OTel:
- `CLAUDE_CODE_ENABLE_TELEMETRY`, `OTEL_*`, `CLAUDE_CODE_OTEL_FLUSH_TIMEOUT_MS`

TLS / certs:
- `CLAUDE_CODE_CERT_STORE`, `CLAUDE_CODE_CLIENT_CERT`, `CLAUDE_CODE_CLIENT_KEY`, `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE`

See `references/claude-code-env-vars.md` for the complete alphabetical list with exact semantics.

### Example settings.json

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": ["Bash(npm run lint)", "Bash(npm run test *)"],
    "deny": ["Bash(curl *)", "Read(./.env)", "Read(./.env.*)", "Read(./secrets/**)"],
    "defaultMode": "acceptEdits"
  },
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp"
  }
}
```

### Inspection commands

- `/config` — tabbed settings UI in the REPL
- `/permissions` — view effective permission rules and denied actions
- `/status` — show which settings sources are active (managed source, file paths, errors)
- `claude auto-mode defaults|config|critique` — inspect and validate auto-mode classifier rules

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — Complete settings.json reference: scopes, all available keys, permission/sandbox/attribution/file-suggestion/hook/plugin subsections, precedence, and the full settings file delivery mechanisms
- [Configure permissions](references/claude-code-permissions.md) — Permission system, rule syntax, tool-specific rules (Bash/Read/Edit/WebFetch/MCP/Agent), hooks extension, working directories, sandbox interaction, managed settings, and auto-mode classifier configuration
- [Permission modes](references/claude-code-permission-modes.md) — `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`: switching, defaults, auto-mode requirements and fallback behavior, protected paths
- [Server-managed settings](references/claude-code-server-managed-settings.md) — Centralized configuration via Claude.ai admin console for Teams/Enterprise: delivery, caching, fail-closed startup, security approval dialogs, platform availability
- [Environment variables](references/claude-code-env-vars.md) — Complete alphabetical reference of every `ANTHROPIC_*`, `CLAUDE_CODE_*`, `BASH_*`, `OTEL_*`, and `DISABLE_*` environment variable

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Permission modes: https://code.claude.com/docs/en/permission-modes.md
- Server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
