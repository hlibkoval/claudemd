---
name: settings-doc
description: Complete documentation for Claude Code settings, permissions, permission modes, environment variables, and server-managed settings. Covers settings.json structure (user/project/local/managed scopes, precedence hierarchy, available settings keys including permissions, sandbox, attribution, hooks, plugins, worktree, file suggestion, auto mode classifier), configuration scopes (managed/user/project/local with interaction rules), settings files (user ~/.claude/settings.json, project .claude/settings.json, local .claude/settings.local.json, managed via server/MDM/file with drop-in directories), global config in ~/.claude.json (editorMode, autoConnectIde, showTurnDuration, terminalProgressBarEnabled, teammateMode), permission system (tiered approval for read-only/bash/file-modification, allow/ask/deny rules evaluated deny-first, /permissions UI), permission modes (default, acceptEdits, plan, auto, dontAsk, bypassPermissions with Shift+Tab cycling and --permission-mode flag and defaultMode setting), permission rule syntax (Tool and Tool(specifier) format, wildcard patterns with * and word boundaries, Bash/Read/Edit/WebFetch/MCP/Agent tool-specific rules, gitignore-style path patterns with //absolute ~/home /project-relative ./cwd-relative), auto mode (background classifier, trusted infrastructure via autoMode.environment, soft_deny/allow rule customization, claude auto-mode defaults/config/critique CLI, subagent evaluation, fallback thresholds, cost and latency), plan mode (research-then-propose workflow, /plan prefix, approve-and-switch options), dontAsk mode (pre-approved tools only), bypassPermissions mode (container/VM use only, --dangerously-skip-permissions), working directories (--add-dir, /add-dir, additionalDirectories, loaded config from add-dir), sandbox settings (enabled, filesystem allowWrite/denyWrite/denyRead/allowRead with path prefixes, network allowedDomains/allowUnixSockets/allowLocalBinding, excludedCommands, proxy ports), managed settings (server-managed via Claude.ai admin console, endpoint-managed via MDM/plist/registry/file, managed-only keys like allowManagedHooksOnly/allowManagedPermissionRulesOnly/channelsEnabled/strictKnownMarketplaces, managed-settings.d drop-in directory), server-managed settings (public beta for Teams/Enterprise, fetch and caching behavior, security approval dialogs, access control, platform availability, audit logging), environment variables (ANTHROPIC_API_KEY, ANTHROPIC_BASE_URL, ANTHROPIC_MODEL, CLAUDE_CODE_USE_BEDROCK/VERTEX/FOUNDRY, CLAUDE_CODE_ENABLE_TELEMETRY, MAX_THINKING_TOKENS, sandbox/MCP/proxy/OTel vars, DISABLE_* toggles), plugin configuration (enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces with source types), and settings verification (/status, /permissions, /config, claude auto-mode commands). Load when discussing settings.json, permissions, permission modes, environment variables, managed settings, server-managed settings, sandbox configuration, auto mode classifier, permission rules, configuration scopes, settings precedence, env vars, ANTHROPIC_API_KEY, ANTHROPIC_BASE_URL, bypassPermissions, acceptEdits, dontAsk, plan mode, or any Claude Code configuration topic.
user-invocable: false
---

# Settings and Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, permission modes, environment variables, and server-managed settings.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared? |
|:------|:---------|:---------------|:--------|
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | All users on machine | Yes (deployed by IT) |
| **User** | `~/.claude/settings.json` | You, across all projects | No |
| **Project** | `.claude/settings.json` | All collaborators | Yes (committed to git) |
| **Local** | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |

**Precedence (highest to lowest):** Managed > CLI arguments > Local > Project > User. If denied at any level, no other level can allow it.

### Settings Files

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User settings (all projects) |
| `.claude/settings.json` | Project settings (shared with team) |
| `.claude/settings.local.json` | Local project settings (gitignored) |
| `~/.claude.json` | Global config (preferences, OAuth, MCP servers, per-project state) |
| `managed-settings.json` | Managed settings: macOS `/Library/Application Support/ClaudeCode/`, Linux `/etc/claude-code/`, Windows `C:\Program Files\ClaudeCode\` |

**Drop-in directory:** `managed-settings.d/*.json` alongside `managed-settings.json` -- merged alphabetically on top of the base file. Use numeric prefixes (e.g., `10-telemetry.json`).

**MDM/OS-level policies:** macOS `com.anthropic.claudecode` managed preferences domain; Windows `HKLM\SOFTWARE\Policies\ClaudeCode` registry key (`Settings` REG_SZ with JSON).

### Permission Modes

| Mode | What Claude can do without asking | Best for |
|:-----|:----------------------------------|:---------|
| `default` | Read files | Getting started, sensitive work |
| `acceptEdits` | Read and edit files | Iterating on code you're reviewing |
| `plan` | Read files (no edits allowed) | Exploring a codebase, planning |
| `auto` | All actions, background classifier checks | Long-running tasks, reducing prompts |
| `dontAsk` | Only pre-approved tools | Locked-down environments |
| `bypassPermissions` | All actions, no checks | Isolated containers/VMs only |

**Switch modes:** `Shift+Tab` in CLI, `--permission-mode <mode>`, or `defaultMode` in settings. VS Code: click mode indicator. Desktop: mode selector next to send button.

**Auto mode requirements:** Team, Enterprise, or API plan; Claude Sonnet 4.6 or Opus 4.6; `--enable-auto-mode` at startup.

### Permission Rule Syntax

Rules follow `Tool` or `Tool(specifier)` format. Evaluated: **deny > ask > allow** (first match wins).

| Rule | Effect |
|:-----|:-------|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run` |
| `Bash(npm run build)` | Matches exact command |
| `Read(./.env)` | Matches reading `.env` in current directory |
| `Edit(/src/**/*.ts)` | Matches editing `.ts` files under project `src/` |
| `Read(//Users/alice/secrets/**)` | Absolute path (note `//` prefix) |
| `Read(~/.zshrc)` | Home directory path |
| `WebFetch(domain:example.com)` | Matches fetch requests to domain |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `Agent(Explore)` | Matches specific subagent |

**Wildcard behavior:** Space before `*` enforces word boundary -- `Bash(ls *)` matches `ls -la` but not `lsof`. `Bash(ls*)` matches both.

**Read/Edit path patterns** follow gitignore spec: `//path` = absolute, `~/path` = home, `/path` = project-relative, `path` or `./path` = cwd-relative. `*` matches single directory, `**` matches recursively.

### Key Settings (settings.json)

| Key | Description |
|:----|:------------|
| `permissions.allow` | Array of permission rules to allow |
| `permissions.deny` | Array of permission rules to deny |
| `permissions.ask` | Array of permission rules requiring confirmation |
| `permissions.defaultMode` | Default permission mode |
| `permissions.additionalDirectories` | Additional working directories |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to block bypass mode |
| `model` | Override default model |
| `env` | Environment variables for every session |
| `hooks` | Lifecycle event hooks |
| `sandbox` | Sandbox configuration (see below) |
| `autoMode` | Auto mode classifier configuration |
| `language` | Preferred response language |
| `outputStyle` | Output style adjustment |
| `agent` | Run main thread as named subagent |
| `enabledPlugins` | Plugin enable/disable map |
| `extraKnownMarketplaces` | Additional plugin marketplaces |
| `attribution` | Git commit and PR attribution |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) |
| `companyAnnouncements` | Startup announcements for users |
| `availableModels` | Restrict which models users can select |

### Global Config (~/. claude.json)

| Key | Description |
|:----|:------------|
| `editorMode` | `"normal"` or `"vim"` |
| `autoConnectIde` | Auto-connect to running IDE |
| `showTurnDuration` | Show turn duration messages |
| `terminalProgressBarEnabled` | Terminal progress bar |
| `teammateMode` | Agent team display: `auto`, `in-process`, `tmux` |

### Sandbox Settings

| Key | Description |
|:----|:------------|
| `sandbox.enabled` | Enable bash sandboxing |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `sandbox.excludedCommands` | Commands that run outside sandbox |
| `sandbox.filesystem.allowWrite` | Additional writable paths |
| `sandbox.filesystem.denyWrite` | Paths where writes blocked |
| `sandbox.filesystem.denyRead` | Paths where reads blocked |
| `sandbox.filesystem.allowRead` | Re-allow reads within denyRead regions |
| `sandbox.network.allowedDomains` | Allowed outbound domains (supports wildcards) |
| `sandbox.network.allowUnixSockets` | Accessible Unix socket paths |
| `sandbox.network.allowLocalBinding` | Allow binding to localhost (macOS only) |

**Sandbox path prefixes:** `/` = absolute, `~/` = home, `./` or no prefix = project-relative (in project settings) or `~/.claude`-relative (in user settings).

### Managed-Only Settings

These keys are only read from managed settings; placing them in user/project settings has no effect:

| Setting | Description |
|:--------|:------------|
| `allowManagedHooksOnly` | Only managed and SDK hooks allowed |
| `allowManagedMcpServersOnly` | Only managed MCP allowlist applies |
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply |
| `channelsEnabled` | Allow channels for Team/Enterprise |
| `allowedChannelPlugins` | Allowlist of channel plugins |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `strictKnownMarketplaces` | Allowlist of user-addable marketplaces |
| `pluginTrustMessage` | Custom plugin trust warning message |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed allowRead paths |
| `sandbox.network.allowManagedDomainsOnly` | Only managed allowed domains |

### Auto Mode Classifier Configuration

Set in user settings, `.claude/settings.local.json`, or managed settings (not shared project settings):

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

**Fields:** `environment` (prose descriptions of trusted infrastructure), `allow` (exception rules), `soft_deny` (block rules). Setting `allow` or `soft_deny` **replaces** the entire default list -- always start from `claude auto-mode defaults` output.

**CLI commands:** `claude auto-mode defaults` (built-in rules), `claude auto-mode config` (effective config), `claude auto-mode critique` (AI review of custom rules).

### Server-Managed Settings

Available for Teams/Enterprise plans. Claude Code fetches from Anthropic servers at startup and polls hourly.

| Aspect | Detail |
|:-------|:-------|
| **Requirements** | Teams/Enterprise plan, v2.1.38+ (Teams) or v2.1.30+ (Enterprise) |
| **Admin console** | Claude.ai > Admin Settings > Claude Code > Managed settings |
| **Access control** | Primary Owner and Owner roles |
| **Precedence** | Highest tier; checked before endpoint-managed settings |
| **Caching** | Cached locally; persists through network failures |
| **Security dialogs** | Shell commands, custom env vars, and hooks require user approval (skipped with `-p` flag) |
| **Not available** | Bedrock, Vertex, Foundry, custom `ANTHROPIC_BASE_URL` |

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
| `MAX_THINKING_TOKENS` | Extended thinking budget (0 = disable) |
| `CLAUDE_CODE_EFFORT_LEVEL` | Effort level: `low`, `medium`, `high`, `max`, `auto` |
| `CLAUDE_CODE_SHELL` | Override shell detection |
| `CLAUDE_CONFIG_DIR` | Override config directory (default `~/.claude`) |
| `DISABLE_AUTOUPDATER` | Disable auto-updates |
| `DISABLE_TELEMETRY` | Opt out of Statsig telemetry |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable updates, feedback, error reporting, telemetry |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout |
| `BASH_MAX_TIMEOUT_MS` | Maximum bash command timeout |
| `API_TIMEOUT_MS` | API request timeout (default: 600000) |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server for network connections |
| `CLAUDE_CODE_SIMPLE` | Minimal system prompt, basic tools only |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen rendering |
| `ENABLE_TOOL_SEARCH` | MCP tool search: `true`, `auto`, `auto:N`, `false` |
| `MAX_MCP_OUTPUT_TOKENS` | MCP tool response token limit (default: 25000) |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_DISABLE_CLAUDE_MDS` | Prevent loading any CLAUDE.md files |
| `CLAUDECODE` | Set to `1` in Claude Code-spawned shells |

Set env vars in your shell or in `settings.json` under the `env` key.

### Verification Commands

| Command | Purpose |
|:--------|:--------|
| `/status` | See active settings sources and their origins |
| `/permissions` | View and manage permission rules |
| `/config` | Open settings interface |
| `claude auto-mode defaults` | View built-in auto mode rules |
| `claude auto-mode config` | View effective auto mode config |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) -- Settings files, available settings keys, scopes, precedence, sandbox, plugins, attribution
- [Configure permissions](references/claude-code-permissions.md) -- Permission system, rule syntax, tool-specific rules, managed settings, auto mode classifier
- [Server-managed settings](references/claude-code-server-managed-settings.md) -- Centralized configuration via Claude.ai admin console for Teams/Enterprise
- [Environment variables](references/claude-code-env-vars.md) -- Complete reference for all environment variables
- [Permission modes](references/claude-code-permission-modes.md) -- Switching modes, auto mode, plan mode, dontAsk, bypassPermissions

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Permission modes: https://code.claude.com/docs/en/permission-modes.md
