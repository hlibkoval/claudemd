---
name: settings-doc
description: Complete documentation for Claude Code settings, permissions, permission modes, environment variables, and server-managed settings. Covers configuration scopes (managed, user, project, local), settings.json schema and all available keys, settings precedence, permission system (allow/ask/deny rules, rule syntax, tool-specific rules for Bash/Read/Edit/WebFetch/MCP/Agent), permission modes (default, acceptEdits, plan, auto, dontAsk, bypassPermissions), auto mode classifier configuration (environment, allow, soft_deny), protected paths, managed-only settings, server-managed settings (delivery, caching, fail-closed enforcement, security approval dialogs, access control), sandbox settings (filesystem, network, path prefixes), environment variables (ANTHROPIC_API_KEY, ANTHROPIC_BASE_URL, CLAUDE_CODE_* variables, DISABLE_* variables, OTEL_* variables, MCP_* variables, provider-specific variables), working directories, additional directories configuration, and settings file locations (managed-settings.json, MDM/OS-level policies, plist, registry). Load when discussing settings, configuration, permissions, permission modes, auto mode, bypassPermissions, dontAsk, acceptEdits, plan mode, allow rules, deny rules, permission rules, managed settings, server-managed settings, environment variables, env vars, sandbox settings, sandbox configuration, settings precedence, settings.json, settings.local.json, managed-settings.json, configuration scopes, ANTHROPIC_API_KEY, ANTHROPIC_BASE_URL, CLAUDE_CODE environment variables, protected paths, working directories, additional directories, auto mode classifier, autoMode, or any settings-related topic for Claude Code.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings -- configuration files, permissions, permission modes, environment variables, and server-managed settings.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared? |
|:------|:---------|:--------------|:--------|
| Managed | Server-managed, plist/registry, or `managed-settings.json` | All users on machine | Yes (deployed by IT) |
| User | `~/.claude/settings.json` | You, across all projects | No |
| Project | `.claude/settings.json` | All collaborators | Yes (committed to git) |
| Local | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |

### Settings Precedence (Highest to Lowest)

1. **Managed settings** (server-managed > MDM/OS-level > file-based)
2. **Command line arguments**
3. **Local project settings** (`.claude/settings.local.json`)
4. **Shared project settings** (`.claude/settings.json`)
5. **User settings** (`~/.claude/settings.json`)

Array settings (like `permissions.allow`) merge across scopes (concatenated and deduplicated).

### Settings Files Locations

| Type | Location |
|:-----|:---------|
| User settings | `~/.claude/settings.json` |
| Project settings | `.claude/settings.json` |
| Local settings | `.claude/settings.local.json` |
| Global config | `~/.claude.json` (preferences, OAuth, MCP servers, per-project state) |
| Project MCP | `.mcp.json` |
| Managed (macOS) | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Managed (Linux/WSL) | `/etc/claude-code/managed-settings.json` |
| Managed (Windows) | `C:\Program Files\ClaudeCode\managed-settings.json` |
| Managed (macOS plist) | `com.anthropic.claudecode` managed preferences domain |
| Managed (Windows registry) | `HKLM\SOFTWARE\Policies\ClaudeCode` (REG_SZ `Settings` value) |
| Drop-in directory | `managed-settings.d/*.json` alongside `managed-settings.json` |

### Permission Modes

| Mode | What runs without asking | Best for |
|:-----|:------------------------|:---------|
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads and file edits | Iterating on code you're reviewing |
| `plan` | Reads only (no edits allowed) | Exploring before changing |
| `auto` | Everything, with background safety checks | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down CI and scripts |
| `bypassPermissions` | Everything except protected paths | Isolated containers/VMs only |

**Switching modes:** `Shift+Tab` in CLI, mode indicator in VS Code/Desktop, `--permission-mode <mode>` at startup, or `defaultMode` in settings.

### Permission Rule Syntax

Rules follow format `Tool` or `Tool(specifier)`. Evaluated in order: **deny > ask > allow**.

| Rule | Effect |
|:-----|:-------|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run` |
| `Bash(npm run build)` | Matches exact command |
| `Read(./.env)` | Matches reading `.env` in current dir |
| `Edit(/src/**/*.ts)` | Edits in `<project>/src/` recursively |
| `Read(~/.zshrc)` | Reads home dir `.zshrc` |
| `Read(//Users/alice/file)` | Absolute path (note `//` prefix) |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `Agent(Explore)` | Matches the Explore subagent |

**Read/Edit path patterns** follow gitignore spec: `//path` = absolute, `~/path` = home, `/path` = project-relative, `path` or `./path` = cwd-relative. Use `*` for single-directory match, `**` for recursive.

**Bash wildcard note:** `Bash(ls *)` (space before `*`) matches `ls -la` but NOT `lsof`. `Bash(ls*)` matches both.

### Permission System

| Tool type | Example | Approval required | "Don't ask again" behavior |
|:----------|:--------|:-----------------|:--------------------------|
| Read-only | File reads, Grep | No | N/A |
| Bash commands | Shell execution | Yes | Permanently per project dir and command |
| File modification | Edit/write files | Yes | Until session end |

### Protected Paths (Never Auto-Approved)

**Directories:** `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`)

**Files:** `.gitconfig`, `.gitmodules`, `.bashrc`, `.bash_profile`, `.zshrc`, `.zprofile`, `.profile`, `.ripgreprc`, `.mcp.json`, `.claude.json`

### Auto Mode Requirements

- **Plan:** Team, Enterprise, or API (not Pro or Max)
- **Admin:** Must enable in Claude Code admin settings (Team/Enterprise)
- **Model:** Claude Sonnet 4.6 or Opus 4.6 only
- **Provider:** Anthropic API only (not Bedrock, Vertex, Foundry)

### Auto Mode Classifier Configuration

```json
{
  "autoMode": {
    "environment": [
      "Source control: github.example.com/acme-corp",
      "Trusted cloud buckets: s3://acme-build-artifacts",
      "Trusted internal domains: *.corp.example.com"
    ]
  }
}
```

Read from user settings, `.claude/settings.local.json`, and managed settings only (NOT shared project settings). Setting `allow` or `soft_deny` **replaces the entire default list** for that section. Run `claude auto-mode defaults` first, then edit.

| Subcommand | Purpose |
|:-----------|:--------|
| `claude auto-mode defaults` | Print built-in rules |
| `claude auto-mode config` | Show effective config |
| `claude auto-mode critique` | AI feedback on custom rules |

### Managed-Only Settings

These keys only work in managed settings (no effect in user/project):

| Setting | Description |
|:--------|:-----------|
| `allowedChannelPlugins` | Allowlist of channel plugins |
| `allowManagedHooksOnly` | Block user/project/plugin hooks |
| `allowManagedMcpServersOnly` | Only managed MCP allowlist applies |
| `allowManagedPermissionRulesOnly` | Block user/project permission rules |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `channelsEnabled` | Allow channels for Team/Enterprise |
| `forceRemoteSettingsRefresh` | Block startup until remote settings fetched |
| `pluginTrustMessage` | Custom message on plugin trust warning |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed `allowRead` paths apply |
| `sandbox.network.allowManagedDomainsOnly` | Only managed allowed domains apply |
| `strictKnownMarketplaces` | Restrict which marketplaces users can add |

### Key Settings (settings.json)

| Key | Description |
|:----|:-----------|
| `permissions` | Allow/ask/deny rules, defaultMode, additionalDirectories |
| `env` | Environment variables applied to every session |
| `hooks` | Lifecycle hook configuration |
| `model` | Override default model |
| `autoMode` | Auto mode classifier configuration |
| `sandbox` | Sandbox configuration (enabled, filesystem, network) |
| `attribution` | Git commit and PR attribution text |
| `agent` | Run main thread as a named subagent |
| `language` | Preferred response language |
| `outputStyle` | Output style for system prompt |
| `statusLine` | Custom status line command |
| `companyAnnouncements` | Startup announcements for users |
| `availableModels` | Restrict which models users can select |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) |
| `disableAutoMode` | `"disable"` to prevent auto mode |
| `disableBypassPermissionsMode` | `"disable"` to block bypass mode |
| `enableAllProjectMcpServers` | Auto-approve project MCP servers |
| `apiKeyHelper` | Script to generate auth value |
| `fileSuggestion` | Custom `@` file autocomplete command |

### Sandbox Settings

| Key | Description |
|:----|:-----------|
| `sandbox.enabled` | Enable bash sandboxing |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `sandbox.excludedCommands` | Commands that run outside sandbox |
| `sandbox.filesystem.allowWrite` | Additional writable paths |
| `sandbox.filesystem.denyWrite` | Paths denied for writing |
| `sandbox.filesystem.denyRead` | Paths denied for reading |
| `sandbox.filesystem.allowRead` | Re-allow reading within denyRead regions |
| `sandbox.network.allowedDomains` | Domains allowed for outbound traffic |
| `sandbox.network.allowUnixSockets` | Unix socket paths accessible in sandbox |
| `sandbox.network.allowLocalBinding` | Allow binding to localhost ports (macOS only) |

**Sandbox path prefixes:** `/` = absolute, `~/` = home, `./` or no prefix = project-relative (or `~/.claude` for user settings).

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key (overrides subscription) |
| `ANTHROPIC_BASE_URL` | Override API endpoint |
| `ANTHROPIC_MODEL` | Model setting to use |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable autoupdater, feedback, error reporting, telemetry |
| `CLAUDE_CODE_SIMPLE` | Minimal system prompt, basic tools only |
| `CLAUDE_CODE_DISABLE_CLAUDE_MDS` | Prevent loading CLAUDE.md files |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Max output tokens per request |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Context capacity % for auto-compaction (1-100) |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout |
| `MAX_THINKING_TOKENS` | Override extended thinking budget |
| `DISABLE_AUTOUPDATER` | Disable automatic updates |
| `DISABLE_TELEMETRY` | Opt out of Statsig telemetry |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server for network connections |
| `MCP_TIMEOUT` | MCP server startup timeout (ms) |
| `MCP_TOOL_TIMEOUT` | MCP tool execution timeout (ms) |
| `CLAUDECODE` | Set to `1` in shells spawned by Claude Code |

### Server-Managed Settings

| Requirement | Detail |
|:------------|:-------|
| Plan | Claude for Teams or Enterprise |
| Version | 2.1.38+ (Teams) or 2.1.30+ (Enterprise) |
| Network | Access to `api.anthropic.com` |
| Access | Primary Owner or Owner role |

**Delivery:** Settings fetched at startup and polled hourly. Cached settings apply immediately on subsequent launches.

**Precedence:** Server-managed and endpoint-managed settings share the highest tier. Server-managed checked first; if any keys delivered, endpoint-managed ignored entirely.

**Fail-closed:** Set `forceRemoteSettingsRefresh: true` to block startup until remote settings fetched; CLI exits on failure.

**Security dialogs:** Shell commands, custom env vars, and hooks in managed settings require user approval (skipped in non-interactive `-p` mode).

**Not available with:** Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`.

### Global Config Settings (~/.claude.json)

| Key | Description |
|:----|:-----------|
| `autoConnectIde` | Auto-connect to IDE from external terminal |
| `autoInstallIdeExtension` | Auto-install IDE extension in VS Code |
| `editorMode` | `"normal"` or `"vim"` |
| `showTurnDuration` | Show turn duration messages |
| `teammateMode` | Agent team display: `auto`, `in-process`, `tmux` |

### Working Directories

- `--add-dir <path>` at startup or `/add-dir` during session
- `additionalDirectories` in settings for persistence
- Additional dirs load skills and limited plugin settings, but NOT subagents, commands, hooks, or other settings
- Set `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` to load CLAUDE.md from additional dirs

### Useful Commands

| Command | Purpose |
|:--------|:--------|
| `/config` | Open settings interface |
| `/permissions` | View and manage permission rules |
| `/status` | See active settings sources |
| `Shift+Tab` | Cycle permission modes |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) -- Configuration scopes, settings.json schema, all available settings keys, settings precedence, permission settings, sandbox settings, attribution, plugin configuration, worktree settings
- [Configure Permissions](references/claude-code-permissions.md) -- Permission system, permission rules syntax, tool-specific rules, managed settings, managed-only settings, auto mode classifier configuration, working directories, sandboxing interaction
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) -- Server-delivered settings for organizations, admin console setup, delivery and caching behavior, fail-closed enforcement, security approval dialogs, platform availability
- [Environment Variables](references/claude-code-env-vars.md) -- Complete reference for all environment variables controlling Claude Code behavior (API keys, model config, telemetry, proxy, MCP, sandbox, provider-specific)
- [Permission Modes](references/claude-code-permission-modes.md) -- Available modes (default, acceptEdits, plan, auto, dontAsk, bypassPermissions), switching modes across interfaces, auto mode classifier details, protected paths

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment Variables: https://code.claude.com/docs/en/env-vars.md
- Permission Modes: https://code.claude.com/docs/en/permission-modes.md
