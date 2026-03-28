---
name: settings-doc
description: Complete documentation for Claude Code settings, permissions, permission modes, environment variables, and server-managed settings. Covers settings.json (all available settings keys including permissions, sandbox, attribution, hooks, model, autoMode, worktree, fileSuggestion, spinnerVerbs, language, and 50+ other keys), configuration scopes (managed/user/project/local with precedence rules), settings files (user ~/.claude/settings.json, project .claude/settings.json, local .claude/settings.local.json, managed via server/MDM/OS-level/file-based with drop-in managed-settings.d/ directory), global config settings in ~/.claude.json (autoConnectIde, editorMode, showTurnDuration, terminalProgressBarEnabled, teammateMode), permission system (tiered approval for read-only/bash/file-modification, allow/ask/deny rules evaluated deny->ask->allow, /permissions command), permission rule syntax (Tool and Tool(specifier) format, wildcards with * in Bash rules, Read/Edit rules following gitignore spec with //path ~/path /path ./path patterns, WebFetch domain matching, MCP server/tool matching, Agent subagent rules), permission modes (default, acceptEdits, plan, auto, bypassPermissions, dontAsk -- switching via Shift+Tab/CLI flag/settings/VS Code/Desktop/Web, plan mode for research-then-propose, auto mode with classifier model reviewing actions and blocking unsafe operations, dontAsk for pre-approved-only, bypassPermissions for containers), auto mode classifier configuration (autoMode.environment for trusted infrastructure, autoMode.allow and autoMode.soft_deny for overriding built-in rules, claude auto-mode defaults/config/critique commands, what auto mode blocks and allows by default, subagent evaluation, fallback behavior), managed settings (server-managed via Claude.ai admin console with hourly polling, endpoint-managed via MDM/OS policies, managed-only keys allowManagedPermissionRulesOnly/allowManagedHooksOnly/allowManagedMcpServersOnly/allowedChannelPlugins/blockedMarketplaces/sandbox.network.allowManagedDomainsOnly/sandbox.filesystem.allowManagedReadPathsOnly/strictKnownMarketplaces, security approval dialogs, settings delivery and caching, platform availability), sandbox settings (enabled, filesystem allowWrite/denyWrite/denyRead/allowRead with path prefixes, network allowedDomains/allowUnixSockets/allowLocalBinding, excludedCommands, enableWeakerNestedSandbox), environment variables (ANTHROPIC_API_KEY, ANTHROPIC_BASE_URL, ANTHROPIC_MODEL, CLAUDE_CODE_USE_BEDROCK/VERTEX/FOUNDRY, CLAUDE_CODE_ENABLE_TELEMETRY, CLAUDE_CODE_DISABLE_* flags, BASH_DEFAULT_TIMEOUT_MS, MAX_THINKING_TOKENS, proxy vars HTTP_PROXY/HTTPS_PROXY/NO_PROXY, MCP_TIMEOUT, and 80+ other env vars), and settings precedence (managed > CLI args > local > project > user with array merging across scopes). Load when discussing Claude Code settings, settings.json, configuration, permissions, permission rules, allow/deny rules, permission modes, auto mode, plan mode, bypassPermissions, dontAsk mode, acceptEdits mode, managed settings, server-managed settings, MDM policies, environment variables, env vars, ANTHROPIC_API_KEY, ANTHROPIC_BASE_URL, sandbox settings, sandbox configuration, /config command, /permissions command, /status command, settings precedence, settings scopes, defaultMode, disableBypassPermissionsMode, autoMode classifier, hook configuration settings, MCP server settings, or any settings/configuration/permissions/env-var topic for Claude Code.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, permission modes, environment variables, and server-managed settings.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared with team? |
|:------|:---------|:---------------|:-------------------|
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | All users on the machine | Yes (deployed by IT) |
| **User** | `~/.claude/settings.json` | You, across all projects | No |
| **Project** | `.claude/settings.json` | All collaborators on this repo | Yes (committed to git) |
| **Local** | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |

### Settings Precedence (highest to lowest)

1. **Managed settings** (server-managed > MDM/OS-level > file-based)
2. **Command line arguments**
3. **Local project settings** (`.claude/settings.local.json`)
4. **Shared project settings** (`.claude/settings.json`)
5. **User settings** (`~/.claude/settings.json`)

Array-valued settings (like `permissions.allow`, `sandbox.filesystem.allowWrite`) merge across scopes -- they are concatenated and deduplicated, not replaced.

### Permission Modes

| Mode | What Claude can do without asking | Best for |
|:-----|:----------------------------------|:---------|
| `default` | Read files | Getting started, sensitive work |
| `acceptEdits` | Read and edit files | Iterating on code you're reviewing |
| `plan` | Read files (no edits) | Exploring a codebase, planning a refactor |
| `auto` | All actions, with background safety checks | Long-running tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down environments |
| `bypassPermissions` | All actions, no checks | Isolated containers and VMs only |

Switch modes with `Shift+Tab` (CLI), mode selector (VS Code/Desktop/Web), or `--permission-mode <mode>` at startup. Set `defaultMode` in settings.

### Permission Rule Evaluation

Rules evaluate in order: **deny -> ask -> allow**. The first matching rule wins, so deny rules always take precedence.

| Rule format | Effect |
|:------------|:-------|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run` |
| `Read(./.env)` | Matches reading the `.env` file |
| `Edit(/src/**/*.ts)` | Matches editing `.ts` files under `src/` (project-relative) |
| `Read(~/.zshrc)` | Matches reading home directory's `.zshrc` |
| `Read(//Users/alice/secrets/**)` | Matches absolute path (double-slash prefix) |
| `WebFetch(domain:example.com)` | Matches fetch requests to example.com |
| `mcp__puppeteer__puppeteer_navigate` | Matches specific MCP tool |
| `Agent(Explore)` | Matches the Explore subagent |

Read/Edit rules follow gitignore spec: `//path` = absolute, `~/path` = home, `/path` = project root, `./path` or `path` = current directory. `*` matches single directory, `**` matches recursively.

### Key Settings (settings.json)

| Key | Description |
|:----|:------------|
| `permissions.allow` | Array of permission rules to allow without prompting |
| `permissions.deny` | Array of rules to block tool use |
| `permissions.ask` | Array of rules requiring confirmation |
| `permissions.defaultMode` | Default permission mode (`default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`) |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to prevent bypass mode |
| `permissions.additionalDirectories` | Extra working directories for Claude |
| `model` | Override the default model |
| `availableModels` | Restrict which models users can select |
| `effortLevel` | Persist effort level: `"low"`, `"medium"`, `"high"` |
| `env` | Environment variables applied to every session |
| `hooks` | Custom commands at lifecycle events |
| `sandbox.enabled` | Enable bash sandboxing |
| `sandbox.filesystem.allowWrite` | Additional writable paths in sandbox |
| `sandbox.filesystem.denyRead` | Paths blocked from reading in sandbox |
| `sandbox.network.allowedDomains` | Allowed domains for outbound network |
| `autoMode.environment` | Trusted infrastructure descriptions for auto mode classifier |
| `autoMode.allow` | Override auto mode allow rules (replaces defaults) |
| `autoMode.soft_deny` | Override auto mode block rules (replaces defaults) |
| `disableAutoMode` | Set to `"disable"` to prevent auto mode |
| `language` | Preferred response language |
| `outputStyle` | Output style for system prompt |
| `statusLine` | Custom status line configuration |
| `attribution.commit` | Git commit attribution text |
| `attribution.pr` | PR description attribution text |
| `apiKeyHelper` | Custom script to generate auth value |
| `companyAnnouncements` | Startup announcements for users |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) |
| `cleanupPeriodDays` | Session retention period (default: 30) |
| `worktree.symlinkDirectories` | Directories to symlink in worktrees |
| `worktree.sparsePaths` | Sparse-checkout paths for worktrees |
| `fileSuggestion` | Custom `@` file autocomplete script |
| `forceLoginMethod` | Restrict login to `claudeai` or `console` |
| `includeGitInstructions` | Include built-in git instructions (default: `true`) |
| `alwaysThinkingEnabled` | Enable extended thinking by default |
| `defaultShell` | `"bash"` (default) or `"powershell"` |
| `spinnerVerbs` | Customize spinner action verbs |

### Global Config Settings (~/.claude.json)

| Key | Description |
|:----|:------------|
| `autoConnectIde` | Auto-connect to IDE from external terminal |
| `autoInstallIdeExtension` | Auto-install IDE extension (default: `true`) |
| `editorMode` | Key binding mode: `"normal"` or `"vim"` |
| `showTurnDuration` | Show turn duration after responses (default: `true`) |
| `terminalProgressBarEnabled` | Show terminal progress bar (default: `true`) |
| `teammateMode` | Agent team display: `auto`, `in-process`, `tmux` |

### Managed-Only Settings

These settings are only effective in managed settings:

| Setting | Description |
|:--------|:------------|
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply |
| `allowManagedHooksOnly` | Only managed and SDK hooks load |
| `allowManagedMcpServersOnly` | Only managed MCP server allowlist applies |
| `allowedChannelPlugins` | Allowlist of channel plugins |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `sandbox.network.allowManagedDomainsOnly` | Only managed domain allowlists apply |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed read paths apply |
| `strictKnownMarketplaces` | Restrict which marketplaces users can add |
| `channelsEnabled` | Enable channels for Team/Enterprise users |

### Auto Mode Classifier Configuration

The `autoMode` block tells the classifier which infrastructure your organization trusts. Read from user settings, `.claude/settings.local.json`, and managed settings -- NOT from shared project settings.

```json
{
  "autoMode": {
    "environment": [
      "Source control: github.example.com/acme-corp and all repos under it",
      "Trusted cloud buckets: s3://acme-build-artifacts",
      "Trusted internal domains: *.corp.example.com"
    ]
  }
}
```

Inspect and validate with CLI commands:
- `claude auto-mode defaults` -- built-in rules
- `claude auto-mode config` -- effective merged config
- `claude auto-mode critique` -- AI feedback on custom rules

Setting `allow` or `soft_deny` **replaces the entire default list** for that section. Always start from `claude auto-mode defaults` output.

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key (overrides subscription when set) |
| `ANTHROPIC_BASE_URL` | Override API endpoint for proxy/gateway |
| `ANTHROPIC_MODEL` | Model setting to use |
| `ANTHROPIC_AUTH_TOKEN` | Custom Authorization header value |
| `ANTHROPIC_CUSTOM_HEADERS` | Custom headers (newline-separated) |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry (`1`) |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable updates, telemetry, error reporting |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory (`1`) |
| `CLAUDE_CODE_DISABLE_FAST_MODE` | Disable fast mode (`1`) |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | Disable background tasks (`1`) |
| `CLAUDE_CODE_SIMPLE` | Minimal system prompt, basic tools only (`1`) |
| `CLAUDE_CODE_SHELL` | Override shell detection |
| `CLAUDE_CODE_SHELL_PREFIX` | Command prefix for all bash commands |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level: `low`, `medium`, `high`, `max`, `auto` |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess environments (`1`) |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Auto-compaction trigger percentage (1-100) |
| `CLAUDE_CONFIG_DIR` | Custom config/data directory |
| `CLAUDE_ENV_FILE` | Shell script sourced before each Bash command |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout |
| `BASH_MAX_TIMEOUT_MS` | Maximum bash command timeout |
| `MAX_THINKING_TOKENS` | Override thinking token budget |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens in MCP responses (default: 25000) |
| `MCP_TIMEOUT` | MCP server startup timeout (ms) |
| `MCP_TOOL_TIMEOUT` | MCP tool execution timeout (ms) |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server for network connections |
| `NO_PROXY` | Domains/IPs to bypass proxy |
| `DISABLE_AUTOUPDATER` | Disable automatic updates (`1`) |
| `DISABLE_TELEMETRY` | Opt out of Statsig telemetry (`1`) |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching (`1`) |
| `CLAUDECODE` | Set to `1` in Claude-spawned shells (detection) |

### Server-Managed Settings

Delivered from Anthropic's servers via the Claude.ai admin console. Requires Team or Enterprise plan, Claude Code v2.1.38+, and access to `api.anthropic.com`.

- Settings fetched at startup and polled hourly
- Cached settings apply immediately on subsequent launches
- Cannot be overridden by any other settings level
- When both server-managed and endpoint-managed settings exist, server-managed wins
- Shell commands, custom env vars, and hooks require user security approval dialog
- Access limited to Primary Owner and Owner roles
- MCP server configurations not yet supported via server-managed settings

### Managed Settings File Locations

| Platform | File path |
|:---------|:----------|
| macOS (plist) | `com.anthropic.claudecode` managed preferences domain |
| macOS (file) | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux/WSL (file) | `/etc/claude-code/managed-settings.json` |
| Windows (registry) | `HKLM\SOFTWARE\Policies\ClaudeCode` (REG_SZ `Settings` value) |
| Windows (file) | `C:\Program Files\ClaudeCode\managed-settings.json` |

Drop-in directory `managed-settings.d/` alongside the base file supports independent policy fragments. Files sorted alphabetically; use numeric prefixes (e.g., `10-telemetry.json`, `20-security.json`).

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) -- full settings.json reference, all available settings keys, configuration scopes, settings precedence, sandbox settings, attribution, file suggestion, hook configuration
- [Configure Permissions](references/claude-code-permissions.md) -- permission system, permission rules syntax, tool-specific rules (Bash, Read, Edit, WebFetch, MCP, Agent), managed-only settings, auto mode classifier, working directories, hooks for permissions
- [Choose a Permission Mode](references/claude-code-permission-modes.md) -- all permission modes, switching modes across CLI/VS Code/Desktop/Web, plan mode, auto mode with classifier details, dontAsk mode, bypassPermissions mode
- [Environment Variables](references/claude-code-env-vars.md) -- complete reference for all environment variables controlling Claude Code behavior
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) -- centralized server-delivered settings, admin console configuration, settings delivery and caching, security considerations

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Choose a Permission Mode: https://code.claude.com/docs/en/permission-modes.md
- Environment Variables: https://code.claude.com/docs/en/env-vars.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
