---
name: settings-doc
description: Complete documentation for Claude Code settings, permissions, permission modes, environment variables, and server-managed settings. Covers configuration scopes (managed, user, project, local), settings.json structure, all available settings keys (agent, autoMode, attribution, hooks, model, outputStyle, permissions, sandbox, plugins, worktree, and more), global config settings (~/.claude.json), settings precedence (managed > CLI > local > project > user), settings files and delivery mechanisms (server-managed, MDM/OS-level, file-based managed-settings.json, drop-in directories), permission system (allow/ask/deny rules, deny > ask > allow evaluation order), permission rule syntax (Tool, Tool(specifier), wildcard patterns, word boundaries), tool-specific rules (Bash, Read, Edit, WebFetch, MCP, Agent), permission modes (default, acceptEdits, plan, auto, dontAsk, bypassPermissions), switching modes (Shift+Tab cycle, --permission-mode flag, defaultMode setting, VS Code/Desktop/Web selectors), auto mode (classifier model, environment/allow/soft_deny configuration, trusted infrastructure, default block/allow rules, subagent handling, fallback behavior, cost/latency), plan mode (read-only analysis, /plan prefix, plan approval options), bypassPermissions (protected directories, --dangerously-skip-permissions), dontAsk (pre-approved tools only), managed-only settings (allowManagedHooksOnly, allowManagedMcpServersOnly, allowManagedPermissionRulesOnly, channelsEnabled, strictKnownMarketplaces, blockedMarketplaces, sandbox managed-only keys), working directories (--add-dir, /add-dir, additionalDirectories, configuration not discovered from add-dir), sandbox settings (enabled, filesystem allowWrite/denyWrite/denyRead/allowRead, network allowedDomains/allowUnixSockets/allowLocalBinding, excludedCommands, autoAllowBashIfSandboxed, path prefixes), plugin configuration (enabledPlugins, extraKnownMarketplaces, marketplace source types), environment variables (ANTHROPIC_API_KEY, ANTHROPIC_BASE_URL, ANTHROPIC_MODEL, CLAUDE_CODE_USE_BEDROCK/VERTEX/FOUNDRY, CLAUDE_CODE_ENABLE_TELEMETRY, all CLAUDE_CODE_DISABLE_* flags, MCP_TIMEOUT, MAX_THINKING_TOKENS, proxy variables, OTel variables, and 100+ others), server-managed settings (admin console on Claude.ai, requirements, delivery/caching, security approval dialogs, access control, platform availability, audit logging, security considerations), settings verification (/status, /permissions, /config commands). Load when discussing Claude Code settings, configuration, permissions, permission modes, auto mode, plan mode, bypassPermissions, dontAsk, managed settings, server-managed settings, settings.json, settings precedence, environment variables, env vars, sandbox settings, permission rules, allow/deny rules, working directories, plugin configuration, enabledPlugins, extraKnownMarketplaces, ANTHROPIC_API_KEY, ANTHROPIC_MODEL, CLAUDE_CODE_USE_BEDROCK, or any settings/permissions/configuration topic for Claude Code.
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, permission modes, environment variables, and server-managed settings.

## Quick Reference

### Configuration Scopes

| Scope | Location | Who it affects | Shared? |
|:------|:---------|:---------------|:--------|
| **Managed** | Server-managed, plist/registry, or `managed-settings.json` | All users on machine | Yes (deployed by IT) |
| **User** | `~/.claude/settings.json` | You, across all projects | No |
| **Project** | `.claude/settings.json` | All collaborators | Yes (committed to git) |
| **Local** | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |

### Settings Precedence (highest to lowest)

1. **Managed settings** -- cannot be overridden, including by CLI args
2. **Command line arguments** -- temporary session overrides
3. **Local project** (`.claude/settings.local.json`)
4. **Shared project** (`.claude/settings.json`)
5. **User** (`~/.claude/settings.json`)

Array settings (e.g. `permissions.allow`, `sandbox.filesystem.allowWrite`) merge across scopes (concatenated and deduplicated).

### Key Settings (settings.json)

| Key | Description |
|:----|:-----------|
| `permissions` | allow/ask/deny rules, defaultMode, additionalDirectories, disableBypassPermissionsMode |
| `hooks` | Lifecycle event hooks (see hooks-doc) |
| `env` | Environment variables applied to every session |
| `model` | Override default model |
| `autoMode` | Configure auto mode classifier (environment, allow, soft_deny) |
| `sandbox` | Sandbox configuration (enabled, filesystem, network) |
| `agent` | Run main thread as a named subagent |
| `outputStyle` | Adjust system prompt style |
| `language` | Preferred response language |
| `attribution` | Customize git commit/PR attribution |
| `enabledPlugins` | Enable/disable plugins (`"name@marketplace": true/false`) |
| `extraKnownMarketplaces` | Additional plugin marketplace sources |
| `availableModels` | Restrict selectable models |
| `worktree` | symlinkDirectories, sparsePaths for git worktrees |
| `companyAnnouncements` | Messages displayed to users at startup |
| `cleanupPeriodDays` | Session cleanup age (default: 30) |
| `disableAllHooks` | Disable all hooks and custom status lines |
| `voiceEnabled` | Push-to-talk voice dictation |

### Permission Modes

| Mode | What Claude can do without asking | Best for |
|:-----|:----------------------------------|:---------|
| `default` | Read files | Getting started, sensitive work |
| `acceptEdits` | Read and edit files (except protected dirs) | Iterating on code you are reviewing |
| `plan` | Read files (no edits, no commands without approval) | Exploring a codebase, planning |
| `auto` | All actions with background classifier safety checks | Long-running tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down / CI environments |
| `bypassPermissions` | All actions (except protected dir writes) | Isolated containers/VMs only |

**Protected directories** (always prompt for writes): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`).

**Switch modes**: `Shift+Tab` in CLI, `--permission-mode <mode>`, `defaultMode` in settings, VS Code/Desktop mode selector.

### Permission Rule Syntax

Rules follow format `Tool` or `Tool(specifier)`. Evaluation order: **deny > ask > allow**.

| Rule | Effect |
|:-----|:-------|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run ` |
| `Bash(npm*)` | Matches `npm` and `npmx` (no word boundary) |
| `Read(./.env)` | Matches reading `.env` in current directory |
| `Edit(/src/**/*.ts)` | Matches editing TypeScript files under project `src/` |
| `Read(~/.zshrc)` | Matches reading home directory `.zshrc` |
| `Read(//Users/alice/file)` | Absolute path (double-slash prefix) |
| `WebFetch(domain:example.com)` | Matches fetch requests to example.com |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `Agent(Explore)` | Matches the Explore subagent |

Read/Edit rules follow gitignore spec: `//path` = absolute, `~/path` = home, `/path` = project root, `path` or `./path` = relative to cwd.

### Permission Settings

| Key | Description |
|:----|:-----------|
| `permissions.allow` | Array of rules to allow without prompting |
| `permissions.ask` | Array of rules requiring confirmation |
| `permissions.deny` | Array of rules to block |
| `permissions.defaultMode` | Default permission mode |
| `permissions.additionalDirectories` | Extra working directories for file access |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to block bypass mode |
| `permissions.skipDangerousModePermissionPrompt` | Skip bypass mode confirmation prompt |

### Auto Mode Configuration

```json
{
  "autoMode": {
    "environment": [
      "Source control: github.example.com/acme-corp",
      "Trusted cloud buckets: s3://acme-builds",
      "Trusted internal domains: *.corp.example.com"
    ],
    "allow": ["...copy defaults first, then add..."],
    "soft_deny": ["...copy defaults first, then add..."]
  }
}
```

**Important**: Setting `allow` or `soft_deny` replaces the entire default list. Run `claude auto-mode defaults` first, copy, then edit.

Not read from shared project settings (`.claude/settings.json`). Read from user settings, `.claude/settings.local.json`, and managed settings.

**CLI commands**: `claude auto-mode defaults` (view defaults), `claude auto-mode config` (effective config), `claude auto-mode critique` (review custom rules).

### Sandbox Settings

| Key | Description |
|:----|:-----------|
| `sandbox.enabled` | Enable bash sandboxing |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `sandbox.excludedCommands` | Commands that run outside sandbox |
| `sandbox.filesystem.allowWrite` | Extra writable paths |
| `sandbox.filesystem.denyWrite` | Denied write paths |
| `sandbox.filesystem.denyRead` | Denied read paths |
| `sandbox.filesystem.allowRead` | Re-allow reads within denyRead regions |
| `sandbox.network.allowedDomains` | Allowed outbound domains |
| `sandbox.network.allowUnixSockets` | Allowed Unix socket paths |
| `sandbox.network.allowLocalBinding` | Allow localhost port binding (macOS) |

Path prefixes: `/path` = absolute, `~/path` = home, `./path` = project-relative (in project settings) or `~/.claude`-relative (in user settings).

### Managed-Only Settings

These keys only take effect in managed settings:

| Setting | Description |
|:--------|:-----------|
| `allowManagedHooksOnly` | Only managed and SDK hooks allowed |
| `allowManagedMcpServersOnly` | Only managed MCP server allowlist applies |
| `allowManagedPermissionRulesOnly` | Only managed permission rules apply |
| `channelsEnabled` | Enable channels for Team/Enterprise |
| `allowedChannelPlugins` | Allowlist of channel plugins |
| `strictKnownMarketplaces` | Restrict which marketplaces users can add |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `pluginTrustMessage` | Custom message for plugin trust warning |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed allowRead paths apply |
| `sandbox.network.allowManagedDomainsOnly` | Only managed allowedDomains apply |

### Managed Settings Delivery

| Mechanism | Location |
|:----------|:---------|
| Server-managed | Claude.ai Admin Settings console |
| macOS MDM | `com.anthropic.claudecode` managed preferences |
| Windows registry | `HKLM\SOFTWARE\Policies\ClaudeCode` |
| File-based (macOS) | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| File-based (Linux/WSL) | `/etc/claude-code/managed-settings.json` |
| File-based (Windows) | `C:\Program Files\ClaudeCode\managed-settings.json` |

Drop-in directory: `managed-settings.d/*.json` alongside the base file (merged alphabetically).

### Server-Managed Settings

- Available for Teams and Enterprise plans
- Requires Claude Code v2.1.38+ (Teams) or v2.1.30+ (Enterprise)
- Configured in Claude.ai > Admin Settings > Claude Code > Managed settings
- Fetched at startup and polled hourly
- Cached settings apply immediately on subsequent launches
- Security approval dialogs for hooks, custom env vars, shell commands
- Non-interactive mode (`-p`) skips security dialogs
- Not available with Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key (overrides subscription) |
| `ANTHROPIC_BASE_URL` | Override API endpoint (proxy/gateway) |
| `ANTHROPIC_MODEL` | Model selection |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable autoupdater, telemetry, error reporting |
| `CLAUDE_CODE_DISABLE_CLAUDE_MDS` | Skip loading CLAUDE.md files |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_SIMPLE` | Minimal system prompt, basic tools only |
| `CLAUDE_CODE_EFFORT_LEVEL` | Effort level: low/medium/high/max/auto |
| `MAX_THINKING_TOKENS` | Override extended thinking budget |
| `DISABLE_AUTO_COMPACT` | Disable automatic compaction |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Context capacity % for auto-compaction trigger |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `CLAUDE_ENV_FILE` | Shell script sourced before each Bash command |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server configuration |
| `MCP_TIMEOUT` | MCP server startup timeout |
| `DISABLE_AUTOUPDATER` | Disable automatic updates |
| `DISABLE_TELEMETRY` | Opt out of Statsig telemetry |

See the full reference for 100+ additional environment variables covering model configuration, Bedrock/Vertex/Foundry settings, OpenTelemetry, plugins, IDE integration, and more.

### Verification Commands

| Command | Purpose |
|:--------|:--------|
| `/status` | View active settings sources and origins |
| `/permissions` | View and manage permission rules |
| `/config` | Open settings interface |
| `claude auto-mode defaults` | View default auto mode rules |
| `claude auto-mode config` | View effective auto mode config |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) -- Configuration scopes, settings.json structure, all available settings keys, permission settings, sandbox settings, plugin configuration, settings precedence, attribution, worktree settings
- [Configure Permissions](references/claude-code-permissions.md) -- Permission system, allow/ask/deny rules, permission rule syntax, tool-specific rules, working directories, managed settings, auto mode classifier configuration, sandboxing interaction
- [Choose a Permission Mode](references/claude-code-permission-modes.md) -- Permission modes (default, acceptEdits, plan, auto, dontAsk, bypassPermissions), switching modes, auto mode classifier details, plan mode workflow, comparison table
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) -- Server-delivered configuration for Teams/Enterprise, admin console setup, delivery and caching, security approval dialogs, audit logging, platform availability
- [Environment Variables](references/claude-code-env-vars.md) -- Complete reference for 100+ environment variables controlling API keys, model selection, cloud providers, tool behavior, telemetry, proxy, and more

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Choose a Permission Mode: https://code.claude.com/docs/en/permission-modes.md
- Configure Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment Variables: https://code.claude.com/docs/en/env-vars.md
