---
name: settings-doc
description: >
  Complete reference for Claude Code settings, permissions, environment variables,
  and managed configuration. Covers settings.json keys, configuration scopes and
  precedence, permission modes (default/acceptEdits/plan/auto/dontAsk/bypassPermissions),
  permission rule syntax, environment variables, server-managed settings, and sandbox
  configuration.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, permission modes, environment variables, and server-managed settings.

## Quick Reference

### Configuration Scopes and Precedence

| Priority | Scope | Location | Shared? |
|:---------|:------|:---------|:--------|
| 1 (highest) | **Managed** | Server, MDM, `managed-settings.json` | Yes (IT-deployed) |
| 2 | **CLI args** | `--permission-mode`, `--model`, etc. | No |
| 3 | **Local** | `.claude/settings.local.json` | No (gitignored) |
| 4 | **Project** | `.claude/settings.json` | Yes (committed) |
| 5 (lowest) | **User** | `~/.claude/settings.json` | No |

Array settings (e.g. `permissions.allow`, `sandbox.filesystem.allowWrite`) **concatenate and deduplicate** across scopes instead of overriding.

### Settings Files

| File | Purpose |
|:-----|:--------|
| `~/.claude/settings.json` | User-level settings across all projects |
| `.claude/settings.json` | Project settings (committed, team-shared) |
| `.claude/settings.local.json` | Local overrides (gitignored) |
| `managed-settings.json` | Managed policy (macOS: `/Library/Application Support/ClaudeCode/`, Linux/WSL: `/etc/claude-code/`, Windows: `C:\Program Files\ClaudeCode\`) |
| `~/.claude.json` | OAuth session, MCP servers, per-project state |
| `.mcp.json` | Project-scoped MCP servers |

### Key settings.json Fields

| Key | Description | Example |
|:----|:------------|:--------|
| `model` | Default model | `"claude-sonnet-4-6"` |
| `permissions.allow` | Allow these tool patterns | `["Bash(npm run *)"]` |
| `permissions.deny` | Deny these tool patterns | `["Bash(curl *)"]` |
| `permissions.ask` | Prompt for these patterns | `["Bash(git push *)"]` |
| `permissions.defaultMode` | Default permission mode | `"acceptEdits"` |
| `permissions.additionalDirectories` | Extra file-access directories | `["../docs/"]` |
| `env` | Session env vars | `{"FOO": "bar"}` |
| `hooks` | Lifecycle hooks (see hooks-doc) | — |
| `sandbox.enabled` | Enable OS-level sandbox | `true` |
| `outputStyle` | Adjust system prompt style | `"Explanatory"` |
| `alwaysThinkingEnabled` | Extended thinking default | `true` |
| `effortLevel` | Effort level (`low`/`medium`/`high`/`xhigh`) | `"xhigh"` |
| `language` | Response language | `"japanese"` |
| `autoUpdatesChannel` | Update channel (`stable`/`latest`) | `"stable"` |
| `minimumVersion` | Floor for auto-updates | `"2.1.100"` |
| `availableModels` | Restrict selectable models | `["sonnet", "haiku"]` |
| `statusLine` | Custom status line command | `{"type":"command","command":"~/.claude/statusline.sh"}` |
| `enabledPlugins` | Plugin enable/disable | `{"plugin@market": true}` |
| `extraKnownMarketplaces` | Add plugin sources | `{"acme": {"source": {...}}}` |
| `cleanupPeriodDays` | Session file retention (default: 30) | `20` |
| `companyAnnouncements` | Startup messages for users | `["Welcome to Acme!"]` |
| `attribution.commit` | Git commit attribution text | `"Generated with AI"` |
| `attribution.pr` | PR attribution text | `""` |
| `tui` | Terminal renderer (`default`/`fullscreen`) | `"fullscreen"` |
| `forceLoginMethod` | Restrict login (`claudeai`/`console`) | `"claudeai"` |
| `forceLoginOrgUUID` | Require specific org UUID | `"xxxx-xxxx-..."` |
| `disableAllHooks` | Disable all hooks | `true` |
| `worktree.symlinkDirectories` | Dirs to symlink in worktrees | `["node_modules"]` |
| `worktree.sparsePaths` | Sparse-checkout paths | `["packages/app"]` |

### Managed-Only Settings

These only take effect in managed settings files; they are ignored in user/project settings:

| Key | Effect |
|:----|:-------|
| `allowManagedPermissionRulesOnly` | Block user/project allow/ask/deny rules |
| `allowManagedHooksOnly` | Only managed + SDK hooks load |
| `allowManagedMcpServersOnly` | Only managed MCP servers respected |
| `strictKnownMarketplaces` | Allowlist for plugin marketplaces users can add |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `channelsEnabled` | Enable channels for Team/Enterprise |
| `allowedChannelPlugins` | Restrict channel plugin sources |
| `forceRemoteSettingsRefresh` | Block startup until fresh server settings |
| `pluginTrustMessage` | Append to plugin trust warning |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed allowRead paths respected |
| `sandbox.network.allowManagedDomainsOnly` | Only managed allowedDomains respected |

### Permission Modes

| Mode | What runs without prompting | Set via |
|:-----|:----------------------------|:--------|
| `default` | Reads only | `Shift+Tab` (start) |
| `acceptEdits` | Reads + file edits + `mkdir/touch/rm/mv/cp/sed` in working dir | `Shift+Tab` once |
| `plan` | Reads only — Claude proposes, does not edit | `Shift+Tab` twice or `/plan` |
| `auto` | Everything with classifier safety checks | Requires Max/Team/Enterprise; Sonnet 4.6+ |
| `dontAsk` | Only pre-approved tools in `allow` rules | `--permission-mode dontAsk` |
| `bypassPermissions` | Everything (protected paths still prompt) | `--dangerously-skip-permissions` |

**Protected paths** (never auto-approved): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`), `.gitconfig`, `.gitmodules`, rc files, `.mcp.json`, `.claude.json`.

### Permission Rule Syntax

Format: `Tool` or `Tool(specifier)`. Rules evaluate: **deny → ask → allow** (first match wins).

| Pattern | Matches |
|:--------|:--------|
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` (space enforces word boundary) |
| `Bash(git * main)` | Any git command ending with `main` |
| `Read(./.env)` | Reading `.env` in current dir |
| `Read(//Users/alice/secrets/**)` | Absolute path (double-slash = absolute) |
| `Read(~/Documents/*.pdf)` | Home-relative path |
| `Edit(/src/**/*.ts)` | Project-root-relative path |
| `WebFetch(domain:example.com)` | Fetch to example.com |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `mcp__puppeteer` | All tools from `puppeteer` MCP server |
| `Agent(Explore)` | Explore subagent |

Bash rules strip wrappers: `timeout`, `time`, `nice`, `nohup`, `stdbuf`, bare `xargs`. Compound commands (`&&`, `||`, `;`, `|`) must each match separately.

### Sandbox Settings (summary)

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "excludedCommands": ["docker *"],
    "filesystem": {
      "allowWrite": ["/tmp/build", "~/.kube"],
      "denyRead": ["~/.aws/credentials"]
    },
    "network": {
      "allowedDomains": ["github.com", "*.npmjs.org"],
      "allowLocalBinding": true
    }
  }
}
```

Path prefixes in sandbox filesystem rules: `/` = absolute, `~/` = home-relative, `./` or no prefix = project/user-relative.

### Key Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | API key (overrides subscription) |
| `ANTHROPIC_BASE_URL` | Override API endpoint |
| `ANTHROPIC_MODEL` | Override default model |
| `ANTHROPIC_BEDROCK_BASE_URL` | Bedrock endpoint override |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project for Vertex |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_ENABLE_TELEMETRY=1` | Enable OpenTelemetry |
| `CLAUDE_CODE_DISABLE_THINKING=1` | Force-disable extended thinking |
| `CLAUDE_CODE_EFFORT_LEVEL` | Effort level (`low`/`medium`/`high`/`xhigh`) |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1` | Strip credentials from subprocess env |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY=1` | Skip session transcript writes |
| `DISABLE_AUTOUPDATER=1` | Disable auto-updates |
| `DISABLE_AUTO_COMPACT=1` | Disable auto-compaction |
| `DISABLE_TELEMETRY=1` | Opt out of Statsig telemetry |
| `DISABLE_ERROR_REPORTING=1` | Opt out of Sentry |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` | Shortcut for above 4 |
| `MAX_THINKING_TOKENS` | Extended thinking budget |
| `BASH_DEFAULT_TIMEOUT_MS` | Bash command timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max Bash timeout (default: 600000) |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude` directory |
| `CLAUDE_CODE_OAUTH_TOKEN` | OAuth access token for auth |
| `CLAUDE_ENV_FILE` | Script sourced before each Bash command |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Context % to trigger compaction (1-100) |
| `ENABLE_TOOL_SEARCH` | MCP tool search (`true`/`auto`/`auto:N`/`false`) |
| `MAX_MCP_OUTPUT_TOKENS` | Max MCP response tokens (default: 25000) |
| `ENABLE_PROMPT_CACHING_1H=1` | Request 1-hour prompt cache TTL |
| `CLAUDECODE` | Set to `1` inside Claude-spawned shells |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy for network connections |
| `IS_DEMO=1` | Demo mode (hides email, org name) |
| `CLAUDE_CODE_REMOTE` | `true` in web cloud sessions |
| `CLAUDE_CODE_SIMPLE=1` | Minimal system prompt + basic tools only |

Full list: see [environment variables reference](references/claude-code-env-vars.md).

### Server-Managed Settings

Available on Team and Enterprise plans. Delivered from Claude.ai admin console → **Admin Settings > Claude Code > Managed settings**.

| Aspect | Detail |
|:-------|:-------|
| Delivery | Fetched at startup; hourly polling during sessions |
| Caching | Cached locally; applies immediately on next startup |
| Precedence | Checked first in managed tier; wins over endpoint-managed if non-empty |
| Fail-closed | Set `forceRemoteSettingsRefresh: true` to exit if fetch fails |
| Security dialogs | Hooks, custom env vars, and shell-command settings require user approval |
| Limitations | Uniform for all users (no per-group); MCP servers not distributable via server-managed |
| Not available | Bedrock, Vertex, Foundry, custom `ANTHROPIC_BASE_URL` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Settings](references/claude-code-settings.md) — All settings.json fields, scopes, files, plugin configuration, sandbox, sandbox path prefixes
- [Permissions](references/claude-code-permissions.md) — Permission rules, modes, managed settings, auto mode classifier, working directories, hooks integration
- [Permission modes](references/claude-code-permission-modes.md) — Detailed guide for each mode: acceptEdits, plan, auto, dontAsk, bypassPermissions
- [Environment variables](references/claude-code-env-vars.md) — Complete environment variable reference with full descriptions
- [Server-managed settings](references/claude-code-server-managed-settings.md) — Enterprise/Team server-delivered configuration, security dialogs, fail-closed, audit logging

## Sources

- Settings: https://code.claude.com/docs/en/settings.md
- Permissions: https://code.claude.com/docs/en/permissions.md
- Permission modes: https://code.claude.com/docs/en/permission-modes.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
