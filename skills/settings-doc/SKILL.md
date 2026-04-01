---
name: settings-doc
description: Complete documentation for Claude Code settings and configuration -- settings.json (available settings keys, scopes, precedence, managed/user/project/local), permissions (permission system, modes, rule syntax for Bash/Read/Edit/WebFetch/MCP/Agent, managed-only settings, auto mode classifier, working directories, sandboxing interaction), permission modes (default, acceptEdits, plan, auto, dontAsk, bypassPermissions, switching modes, auto mode classifier and fallback), server-managed settings (admin console setup, fetch/caching, security dialogs, access control, platform availability, audit logging), environment variables (ANTHROPIC_API_KEY, ANTHROPIC_BASE_URL, CLAUDE_CODE_USE_BEDROCK/VERTEX/FOUNDRY, model overrides, telemetry OTEL_*, sandbox, proxy, MCP timeouts, disable flags), sandbox settings (filesystem allowWrite/denyWrite/denyRead/allowRead, network allowedDomains, path prefixes), plugin configuration (enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces), attribution settings, hook configuration (allowManagedHooksOnly, allowedHttpHookUrls, httpHookAllowedEnvVars). Load when discussing settings.json, configuration, permissions, permission modes, environment variables, managed settings, server-managed settings, sandbox config, plugin marketplace settings, auto mode, bypassPermissions, or any Claude Code configuration topic.
user-invocable: false
---

# Settings & Configuration Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, permission modes, server-managed settings, and environment variables.

## Quick Reference

### Settings File Locations

| Scope | File | Shared? | Overridable? |
|:------|:-----|:--------|:-------------|
| Managed (server) | Claude.ai Admin > Managed settings | Yes (org-wide) | No |
| Managed (MDM) | macOS plist `com.anthropic.claudecode` / Windows `HKLM\SOFTWARE\Policies\ClaudeCode` | Yes (IT-deployed) | No |
| Managed (file) | `/Library/Application Support/ClaudeCode/managed-settings.json` (macOS), `/etc/claude-code/managed-settings.json` (Linux) | Yes (IT-deployed) | No |
| User | `~/.claude/settings.json` | No | By project/managed |
| Project (shared) | `.claude/settings.json` | Yes (git) | By local/managed |
| Project (local) | `.claude/settings.local.json` | No (gitignored) | By managed |

### Settings Precedence (highest to lowest)

1. **Managed settings** -- cannot be overridden by anything
2. **Command line arguments** -- temporary session overrides
3. **Local project** (`.claude/settings.local.json`)
4. **Shared project** (`.claude/settings.json`)
5. **User** (`~/.claude/settings.json`)

Array settings (like `permissions.allow`, `sandbox.filesystem.allowWrite`) merge across scopes -- they concatenate and deduplicate rather than replace.

### Key Settings (settings.json)

| Key | Description |
|:----|:-----------|
| `permissions` | Permission rules (`allow`, `ask`, `deny` arrays), `defaultMode`, `additionalDirectories`, `disableBypassPermissionsMode` |
| `model` | Override default model (e.g., `"claude-sonnet-4-6"`) |
| `env` | Environment variables applied to every session |
| `hooks` | Custom commands at lifecycle events (see hooks docs) |
| `sandbox` | Sandbox configuration (filesystem/network restrictions) |
| `autoMode` | Auto mode classifier config (`environment`, `allow`, `soft_deny`) |
| `language` | Response language (e.g., `"japanese"`) |
| `outputStyle` | Output style adjustment |
| `enabledPlugins` | Plugin enable/disable map (`"name@marketplace": true/false`) |
| `extraKnownMarketplaces` | Additional plugin marketplace sources |
| `attribution` | Git commit and PR attribution customization |
| `companyAnnouncements` | Startup announcements for users |
| `availableModels` | Restrict models selectable via `/model` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) |
| `cleanupPeriodDays` | Session cleanup period (default: 30) |
| `effortLevel` | Persist effort level: `"low"`, `"medium"`, `"high"` |
| `fileSuggestion` | Custom `@` file autocomplete command |
| `statusLine` | Custom status line command |
| `worktree.symlinkDirectories` | Directories to symlink in worktrees |
| `worktree.sparsePaths` | Sparse checkout paths for worktrees |

### Permission Modes

| Mode | Auto-approved | Best for |
|:-----|:-------------|:---------|
| `default` | Read files | Getting started, sensitive work |
| `acceptEdits` | Read + edit files | Iterating on code you review |
| `plan` | Read files (no edits) | Exploring codebase, planning |
| `auto` | All (with classifier checks) | Long-running tasks, reducing prompts |
| `dontAsk` | Only pre-approved tools | Locked-down / CI environments |
| `bypassPermissions` | All (no checks) | Isolated containers/VMs only |

**Switching modes:** `Shift+Tab` in CLI, mode selector in VS Code/Desktop, `--permission-mode MODE` at startup, `defaultMode` in settings.

**Disabling modes:** Set `disableBypassPermissionsMode: "disable"` or `disableAutoMode: "disable"` in settings (most useful in managed settings).

### Permission Rule Syntax

Rules follow `Tool` or `Tool(specifier)` format. Evaluation order: **deny -> ask -> allow** (first match wins).

| Rule | Effect |
|:-----|:-------|
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Bash(npm run build)` | Exact command `npm run build` |
| `Read(./.env)` | Reading `.env` in current dir |
| `Edit(/src/**/*.ts)` | Editing TS files under project `src/` |
| `Read(//Users/alice/secrets/**)` | Absolute path pattern |
| `Read(~/Documents/*.pdf)` | Home-relative pattern |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `Agent(Explore)` | Specific subagent |

Read/Edit rules follow gitignore spec. Path prefixes: `//` = absolute, `~/` = home, `/` = project root, `./` or bare = current directory.

### Managed-Only Settings

These keys are only effective in managed settings:

| Setting | Purpose |
|:--------|:--------|
| `allowedChannelPlugins` | Allowlist of channel plugins |
| `allowManagedHooksOnly` | Block user/project/plugin hooks |
| `allowManagedMcpServersOnly` | Only admin-defined MCP servers allowed |
| `allowManagedPermissionRulesOnly` | Block user/project permission rules |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `channelsEnabled` | Enable channels for Team/Enterprise |
| `pluginTrustMessage` | Custom plugin trust warning message |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed `allowRead` paths |
| `sandbox.network.allowManagedDomainsOnly` | Only managed allowed domains |
| `strictKnownMarketplaces` | Allowlist of plugin marketplaces |

### Auto Mode Classifier Configuration

Set `autoMode` in user settings, `.claude/settings.local.json`, or managed settings (NOT shared project settings).

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

Inspect defaults: `claude auto-mode defaults`
Check effective config: `claude auto-mode config`
Validate custom rules: `claude auto-mode critique`

Setting `allow` or `soft_deny` **replaces** the entire default list for that section. Always copy defaults first via `claude auto-mode defaults`.

### Sandbox Settings (under `sandbox` key)

| Key | Description |
|:----|:-----------|
| `enabled` | Enable bash sandboxing (default: false) |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `excludedCommands` | Commands that run outside sandbox |
| `filesystem.allowWrite` | Additional writable paths |
| `filesystem.denyWrite` | Paths blocked from writing |
| `filesystem.denyRead` | Paths blocked from reading |
| `filesystem.allowRead` | Re-allow reading within denyRead regions |
| `network.allowedDomains` | Allowed outbound domains (supports wildcards) |
| `network.allowLocalBinding` | Allow binding to localhost (macOS, default: false) |

Sandbox path prefixes: `/path` = absolute, `~/path` = home, `./path` = project-relative (in project settings) or `~/.claude`-relative (in user settings).

### Server-Managed Settings

| Requirement | Details |
|:------------|:--------|
| Plan | Teams or Enterprise |
| Version | 2.1.38+ (Teams), 2.1.30+ (Enterprise) |
| Network | Access to `api.anthropic.com` |

Configure at: Claude.ai > Admin Settings > Claude Code > Managed settings. Clients fetch at startup and poll hourly.

Within managed tier, precedence: server-managed > MDM/OS-level > file-based. Sources do not merge across tiers (first non-empty wins).

Security dialogs appear for hooks, custom env vars, and shell command settings. Users must approve; rejection exits Claude Code. In non-interactive mode (`-p`), dialogs are skipped.

Not available with Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`.

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key (overrides subscription) |
| `ANTHROPIC_BASE_URL` | Override API endpoint (proxy/gateway) |
| `ANTHROPIC_MODEL` | Override model selection |
| `CLAUDE_CODE_USE_BEDROCK` | Use AWS Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable updates, telemetry, error reporting |
| `CLAUDE_CODE_SIMPLE` | Minimal system prompt, basic tools only |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `CLAUDE_CODE_SHELL` | Override shell detection |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Context compaction threshold (1-100) |
| `DISABLE_AUTOUPDATER` | Disable automatic updates |
| `DISABLE_TELEMETRY` | Opt out of Statsig telemetry |
| `MAX_THINKING_TOKENS` | Override extended thinking budget |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout |
| `MCP_TIMEOUT` | MCP server startup timeout |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy configuration |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocesses |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_DISABLE_CLAUDE_MDS` | Prevent loading CLAUDE.md files |

All env vars can also be set via `settings.json` under the `env` key.

### Common Configuration Patterns

**Deny sensitive files:**
```json
{
  "permissions": {
    "deny": ["Read(./.env)", "Read(./.env.*)", "Read(./secrets/**)"]
  }
}
```

**Allow specific commands, deny others:**
```json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Bash(git commit *)"],
    "deny": ["Bash(git push *)", "Bash(curl *)"]
  }
}
```

**Enable sandbox with network restrictions:**
```json
{
  "sandbox": {
    "enabled": true,
    "network": {
      "allowedDomains": ["github.com", "*.npmjs.org"]
    }
  }
}
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) -- Configuration scopes (managed/user/project/local), settings.json structure, all available settings keys, global config settings (~/.claude.json), worktree settings, permission settings and rule syntax, sandbox settings with path prefixes, attribution settings, file suggestion settings, hook configuration (allowManagedHooksOnly, HTTP hook URL and env var allowlists), settings precedence, plugin configuration (enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces with all source types), subagent configuration, environment variables overview
- [Configure Permissions](references/claude-code-permissions.md) -- Permission system (tool types, approval behavior), manage permissions with /permissions, permission modes overview, permission rule syntax (Bash wildcards, Read/Edit gitignore patterns, WebFetch domain matching, MCP tool patterns, Agent subagent rules), extending permissions with hooks, working directories (--add-dir, additionalDirectories, what config loads from added dirs), permissions and sandboxing interaction, managed settings and managed-only settings table, auto mode classifier configuration (environment, allow, soft_deny, prose rules, inspect defaults), settings precedence for permissions
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) -- Server-delivered centralized configuration for Teams/Enterprise, admin console setup, settings JSON format (permissions, hooks, autoMode examples), fetch and caching behavior, security approval dialogs, access control (Primary Owner, Owner roles), managed-only settings, settings delivery and precedence within managed tier, platform availability limitations, audit logging, security considerations (tampered cache, API unavailable, non-default base URL)
- [Environment Variables](references/claude-code-env-vars.md) -- Complete reference of all environment variables: API keys and auth (ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_BASE_URL), cloud providers (Bedrock, Vertex, Foundry vars), model configuration (ANTHROPIC_MODEL, ANTHROPIC_DEFAULT_*_MODEL), bash/tool control (BASH_DEFAULT_TIMEOUT_MS, BASH_MAX_TIMEOUT_MS), context management (CLAUDE_AUTOCOMPACT_PCT_OVERRIDE, CLAUDE_CODE_AUTO_COMPACT_WINDOW), feature flags (CLAUDE_CODE_DISABLE_*, DISABLE_*), telemetry and monitoring (OTEL_*, CLAUDE_CODE_ENABLE_TELEMETRY), proxy config (HTTP_PROXY, HTTPS_PROXY), MCP settings (MCP_TIMEOUT, MCP_TOOL_TIMEOUT, ENABLE_TOOL_SEARCH), SDK and automation vars
- [Permission Modes](references/claude-code-permission-modes.md) -- Detailed guide to all permission modes: switching modes (CLI Shift+Tab, VS Code selector, Desktop, web/mobile), default/acceptEdits/plan/auto/dontAsk/bypassPermissions mode details, plan mode workflow (research then approve), auto mode (classifier model, cost, latency, action evaluation order, subagent handling, default block/allow lists, fallback behavior), dontAsk for CI/locked-down envs, bypassPermissions for containers, comparison table across modes

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment Variables: https://code.claude.com/docs/en/env-vars.md
- Permission Modes: https://code.claude.com/docs/en/permission-modes.md
