---
name: settings-doc
description: Complete documentation for Claude Code settings, permissions, permission modes, environment variables, and server-managed settings. Covers settings.json configuration (user, project, local, managed scopes), settings precedence, available settings keys (model, permissions, hooks, sandbox, attribution, plugins, autoMode, worktree, and more), global config settings (~/.claude.json), permission system (allow/ask/deny rules, rule evaluation order, tool-specific patterns for Bash, Read, Edit, WebFetch, MCP, Agent), permission modes (default, acceptEdits, plan, auto, dontAsk, bypassPermissions), auto mode classifier configuration (environment, allow, soft_deny, trusted infrastructure), protected paths, managed-only settings (allowManagedHooksOnly, allowManagedPermissionRulesOnly, forceRemoteSettingsRefresh, channelsEnabled, and others), server-managed settings (admin console setup, fetch/caching behavior, fail-closed enforcement, security approval dialogs, platform availability), environment variables reference (ANTHROPIC_API_KEY, ANTHROPIC_BASE_URL, ANTHROPIC_MODEL, CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, sandbox variables, MCP variables, telemetry variables, and 100+ others), sandbox settings (filesystem paths, network domains, proxy ports), working directories and additionalDirectories, configuration verification with /status, and example configurations. Load when discussing settings.json, permissions, permission modes, auto mode, bypassPermissions, acceptEdits, plan mode, dontAsk mode, managed settings, server-managed settings, environment variables, ANTHROPIC_API_KEY, ANTHROPIC_BASE_URL, ANTHROPIC_MODEL, sandbox settings, permission rules, allow/deny rules, defaultMode, settings precedence, settings scopes, managed-only settings, forceRemoteSettingsRefresh, autoMode classifier, protected paths, working directories, additionalDirectories, env vars, CLAUDE_CODE_* variables, or any Claude Code configuration topic.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for configuring Claude Code through settings files, permissions, permission modes, environment variables, and server-managed settings.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared? |
|:------|:---------|:---------------|:--------|
| Managed | Server-managed, plist/registry, or `managed-settings.json` | All users on machine | Yes (deployed by IT) |
| User | `~/.claude/settings.json` | You, across all projects | No |
| Project | `.claude/settings.json` | All collaborators | Yes (committed to git) |
| Local | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |

### Settings Precedence (highest to lowest)

1. **Managed settings** -- cannot be overridden, including by CLI arguments
2. **Command line arguments** -- temporary session overrides
3. **Local project settings** (`.claude/settings.local.json`)
4. **Shared project settings** (`.claude/settings.json`)
5. **User settings** (`~/.claude/settings.json`)

Array-valued settings (e.g., `permissions.allow`, `sandbox.filesystem.allowWrite`) are concatenated and deduplicated across scopes, not replaced.

### Settings Files Locations

| Type | Location |
|:-----|:---------|
| User settings | `~/.claude/settings.json` |
| Project settings (shared) | `.claude/settings.json` |
| Project settings (local) | `.claude/settings.local.json` |
| Global config | `~/.claude.json` |
| MCP servers (project) | `.mcp.json` |
| Managed (macOS) | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Managed (Linux/WSL) | `/etc/claude-code/managed-settings.json` |
| Managed (Windows) | `C:\Program Files\ClaudeCode\managed-settings.json` |
| Managed (macOS plist) | `com.anthropic.claudecode` managed preferences domain |
| Managed (Windows registry) | `HKLM\SOFTWARE\Policies\ClaudeCode` `Settings` value |

Drop-in directory: `managed-settings.d/` alongside `managed-settings.json` for fragmentary policy files (merged alphabetically).

### Key settings.json Fields

| Key | Description |
|:----|:-----------|
| `permissions` | Allow/ask/deny rules, `defaultMode`, `additionalDirectories`, `disableBypassPermissionsMode` |
| `model` | Override default model |
| `env` | Environment variables applied to every session |
| `hooks` | Custom commands at lifecycle events |
| `sandbox` | Bash sandboxing config (filesystem, network) |
| `autoMode` | Auto mode classifier configuration (`environment`, `allow`, `soft_deny`) |
| `attribution` | Customize git commit and PR attribution |
| `language` | Preferred response language |
| `outputStyle` | Adjust system prompt style |
| `enabledPlugins` | Enable/disable plugins |
| `extraKnownMarketplaces` | Additional plugin marketplace sources |
| `availableModels` | Restrict selectable models |
| `companyAnnouncements` | Startup announcements for users |
| `worktree` | Worktree settings (`symlinkDirectories`, `sparsePaths`) |
| `fileSuggestion` | Custom `@` autocomplete command |
| `statusLine` | Custom status line command |

### Permission System

Rules evaluated in order: **deny -> ask -> allow**. First match wins; deny always takes precedence.

| Rule type | Effect |
|:----------|:-------|
| Allow | Tool runs without manual approval |
| Ask | Prompts for confirmation |
| Deny | Blocks the tool entirely |

### Permission Rule Syntax

| Pattern | Meaning | Example |
|:--------|:--------|:--------|
| `Tool` | Match all uses of a tool | `Bash`, `Read`, `WebFetch` |
| `Tool(specifier)` | Match specific uses | `Bash(npm run build)` |
| `Tool(glob *)` | Wildcard matching | `Bash(npm run *)`, `Bash(* --version)` |

**Tool-specific patterns:**

| Tool | Pattern | Example |
|:-----|:--------|:--------|
| Bash | Glob wildcards with `*` | `Bash(git commit *)` |
| Read/Edit | Gitignore-style paths | `Edit(/src/**/*.ts)`, `Read(~/.zshrc)` |
| WebFetch | Domain specifier | `WebFetch(domain:example.com)` |
| MCP | Server and tool names | `mcp__puppeteer__puppeteer_navigate` |
| Agent | Subagent names | `Agent(Explore)`, `Agent(Plan)` |

**Read/Edit path prefixes:**

| Prefix | Meaning |
|:-------|:--------|
| `//path` | Absolute path from filesystem root |
| `~/path` | Relative to home directory |
| `/path` | Relative to project root |
| `path` or `./path` | Relative to current directory |

### Permission Modes

| Mode | Auto-approved actions | Best for |
|:-----|:---------------------|:---------|
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads and file edits | Iterating on code you're reviewing |
| `plan` | Reads only (no edits) | Exploring a codebase before changing it |
| `auto` | Everything, with background safety checks | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down CI and scripts |
| `bypassPermissions` | Everything except protected paths | Isolated containers and VMs only |

**Switching modes:**

- CLI: `Shift+Tab` to cycle, or `--permission-mode <mode>` at startup
- VS Code: click mode indicator at bottom of prompt box
- Default: set `permissions.defaultMode` in settings.json

**Auto mode requirements:** Team/Enterprise/API plan, Claude Sonnet 4.6 or Opus 4.6, Anthropic API only. Admin must enable in Claude Code admin settings.

### Auto Mode Classifier Configuration

| Field | Purpose | Replaces defaults? |
|:------|:--------|:-------------------|
| `autoMode.environment` | Trusted repos, buckets, domains (prose) | No -- leaves `allow`/`soft_deny` defaults intact |
| `autoMode.allow` | Exceptions to block rules (prose) | Yes -- replaces entire default allow list |
| `autoMode.soft_deny` | Block rules (prose) | Yes -- replaces entire default soft_deny list |

**Inspect commands:**

```
claude auto-mode defaults   # built-in rules
claude auto-mode config     # effective merged config
claude auto-mode critique   # AI feedback on custom rules
```

### Protected Paths (never auto-approved)

**Directories:** `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`)

**Files:** `.gitconfig`, `.gitmodules`, `.bashrc`, `.bash_profile`, `.zshrc`, `.zprofile`, `.profile`, `.ripgreprc`, `.mcp.json`, `.claude.json`

### Managed-Only Settings

These keys are only read from managed settings; placing them in user/project settings has no effect.

| Setting | Description |
|:--------|:-----------|
| `allowedChannelPlugins` | Allowlist of channel plugins |
| `allowManagedHooksOnly` | Block user/project/plugin hooks |
| `allowManagedMcpServersOnly` | Only admin-defined MCP servers respected |
| `allowManagedPermissionRulesOnly` | Block user/project permission rules |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `channelsEnabled` | Allow channels for Team/Enterprise |
| `forceRemoteSettingsRefresh` | Block startup until remote settings fetched |
| `pluginTrustMessage` | Custom plugin trust warning message |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed `allowRead` paths respected |
| `sandbox.network.allowManagedDomainsOnly` | Only managed allowed domains respected |
| `strictKnownMarketplaces` | Allowlist of plugin marketplaces |

### Sandbox Settings

| Key | Description |
|:----|:-----------|
| `sandbox.enabled` | Enable bash sandboxing |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `sandbox.excludedCommands` | Commands that run outside sandbox |
| `sandbox.filesystem.allowWrite` | Additional writable paths |
| `sandbox.filesystem.denyWrite` | Paths where writes are blocked |
| `sandbox.filesystem.denyRead` | Paths where reads are blocked |
| `sandbox.filesystem.allowRead` | Re-allow reads within denyRead regions |
| `sandbox.network.allowedDomains` | Domains allowed for outbound traffic |
| `sandbox.network.allowUnixSockets` | Unix socket paths accessible in sandbox |
| `sandbox.network.allowLocalBinding` | Allow binding to localhost ports (macOS only) |

### Server-Managed Settings

Server-managed settings are delivered from Anthropic's servers via the Claude.ai admin console. Available for Teams and Enterprise plans.

| Aspect | Detail |
|:-------|:-------|
| Requirements | Teams/Enterprise plan, v2.1.30+ (Enterprise) or v2.1.38+ (Teams), network access to `api.anthropic.com` |
| Configure | Claude.ai > Admin Settings > Claude Code > Managed settings |
| Delivery | Fetched at startup, polled hourly |
| Caching | Cached settings apply immediately; fresh settings fetched in background |
| Fail-closed | Set `forceRemoteSettingsRefresh: true` to block startup if fetch fails |
| Precedence | Same as endpoint-managed; first non-empty source wins (server checked first) |
| Access control | Primary Owner and Owner roles |
| Limitations | Uniform for all users (no per-group), MCP servers cannot be distributed |

**Security approval dialogs** are required for shell commands, custom env vars, and hook configurations in managed settings. Skipped in non-interactive mode (`-p`).

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key (overrides subscription) |
| `ANTHROPIC_BASE_URL` | Override API endpoint (proxy/gateway) |
| `ANTHROPIC_MODEL` | Override model selection |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable autoupdater, feedback, error reporting, telemetry |
| `MAX_THINKING_TOKENS` | Override thinking token budget |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Maximum bash timeout (default: 600000) |
| `API_TIMEOUT_MS` | API request timeout (default: 600000) |
| `DISABLE_AUTOUPDATER` | Disable automatic updates |
| `DISABLE_TELEMETRY` | Opt out of Statsig telemetry |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `CLAUDE_CODE_SIMPLE` | Minimal system prompt, basic tools only |
| `MCP_TIMEOUT` | MCP server startup timeout (default: 30000) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens per MCP tool output (default: 25000) |
| `ENABLE_TOOL_SEARCH` | Control MCP tool search behavior |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server for network connections |

### Verification

Run `/status` inside Claude Code to see which settings sources are active and their origins. Run `/permissions` to view effective permission rules.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) -- Complete configuration reference including settings.json fields, scopes, precedence, sandbox settings, plugin settings, attribution, and file suggestion
- [Configure Permissions](references/claude-code-permissions.md) -- Permission system, rule syntax, tool-specific patterns, permission modes overview, auto mode classifier, managed-only settings, and working directories
- [Permission Modes](references/claude-code-permission-modes.md) -- Detailed guide to each permission mode (default, acceptEdits, plan, auto, dontAsk, bypassPermissions), switching modes, auto mode classifier behavior, and protected paths
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) -- Server-delivered settings for organizations, admin console setup, fetch/caching behavior, fail-closed enforcement, security approval dialogs, and audit logging
- [Environment Variables](references/claude-code-env-vars.md) -- Complete reference for 100+ environment variables controlling API keys, model selection, cloud providers, sandbox, MCP, telemetry, proxy, and feature flags

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Permission Modes: https://code.claude.com/docs/en/permission-modes.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment Variables: https://code.claude.com/docs/en/env-vars.md
