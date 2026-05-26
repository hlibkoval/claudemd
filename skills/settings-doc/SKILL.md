---
name: settings-doc
description: Complete official documentation for Claude Code settings, permissions, permission modes, environment variables, server-managed settings, admin setup, and auto-mode configuration — all settings keys in settings.json, scope hierarchy (managed/user/project/local), permission rule syntax (allow/deny/ask), all 6 permission modes (default/acceptEdits/plan/auto/dontAsk/bypassPermissions), sandbox configuration, all environment variables, server-managed settings setup, and auto mode classifier configuration.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, and configuration.

## Quick Reference

### Configuration Scopes

| Scope | Location | Shared? | Priority |
| :--- | :--- | :--- | :--- |
| **Managed** | Server-managed, MDM/plist/registry, or `managed-settings.json` | Yes (admin-deployed) | Highest |
| **User** | `~/.claude/settings.json` | No | Lower |
| **Project** | `.claude/settings.json` | Yes (committed) | Lower |
| **Local** | `.claude/settings.local.json` | No (gitignored) | Lower |

Settings precedence (highest to lowest): Managed → CLI args → Local → Project → User.

Array settings (like `permissions.allow`) **merge** across all scopes rather than overriding.

### Settings Files

| File | Scope | Notes |
| :--- | :--- | :--- |
| `~/.claude/settings.json` | User | Personal preferences across all projects |
| `.claude/settings.json` | Project | Team-shared, commit to repo |
| `.claude/settings.local.json` | Local | Machine-specific, gitignored |
| `managed-settings.json` (system dirs) | Managed | Admin-deployed, cannot be overridden |
| `~/.claude.json` | Global config | OAuth, MCP servers, per-project state — do NOT put settings.json keys here |

Run `/status` to see which settings sources are active in the current session.

### Key Settings Reference

| Key | Description | Example |
| :--- | :--- | :--- |
| `model` | Override default model (read at startup; use `/model` to switch mid-session) | `"claude-sonnet-4-6"` |
| `permissions` | Allow/deny/ask rules, defaultMode, sandbox config | See below |
| `env` | Environment variables for every session and subprocesses | `{"FOO": "bar"}` |
| `hooks` | Lifecycle event hooks | See hooks-doc |
| `apiKeyHelper` | Script to generate API key (run in `/bin/sh`) | `"/bin/gen-key.sh"` |
| `autoUpdatesChannel` | `"stable"` (1 week old) or `"latest"` (default) | `"stable"` |
| `availableModels` | Restrict `/model` picker | `["sonnet", "haiku"]` |
| `language` | Claude's response language | `"japanese"` |
| `editorMode` | Key bindings: `"normal"` or `"vim"` | `"vim"` |
| `effortLevel` | Persisted effort level: `low/medium/high/xhigh` | `"xhigh"` |
| `outputStyle` | Adjust system prompt via output style | `"Explanatory"` |
| `tui` | `"fullscreen"` (alt-screen) or `"default"` | `"fullscreen"` |
| `cleanupPeriodDays` | Session file retention (default: 30, min: 1) | `20` |
| `companyAnnouncements` | Startup messages cycled at random | `["Welcome!"]` |
| `spinnerTipsEnabled` | Show tips while working (default: true) | `false` |
| `autoMemoryEnabled` | Enable auto memory (default: true) | `false` |
| `alwaysThinkingEnabled` | Enable extended thinking by default | `true` |
| `showThinkingSummaries` | Show thinking block stubs in interactive mode | `true` |
| `attribution` | Customize git commit/PR attribution | `{"commit": "...", "pr": ""}` |
| `statusLine` | Custom status line command | `{"type": "command", "command": "~/.claude/statusline.sh"}` |
| `plansDirectory` | Where plan files are stored | `"./plans"` |
| `minimumVersion` | Floor for auto-updates and `claude update` | `"2.1.100"` |
| `policyHelper` | Admin executable to compute managed settings dynamically (MDM/file only) | `{"path": "/usr/local/bin/claude-policy"}` |
| `skillOverrides` | Per-skill visibility: `"on"/"name-only"/"user-invocable-only"/"off"` | `{"legacy-ctx": "off"}` |
| `strictPluginOnlyCustomization` | Block user/project skills, agents, hooks, MCP — managed only | `["skills", "hooks"]` |
| `disableAutoMode` | Set `"disable"` to block auto mode | `"disable"` |
| `disableAllHooks` | Disable all hooks and custom status line | `true` |
| `forceLoginMethod` | Restrict login to `claudeai` or `console` | `"claudeai"` |
| `forceLoginOrgUUID` | Require specific org(s) at login | `"xxxx-xxxx..."` |
| `worktree.baseRef` | `"fresh"` (from remote default branch) or `"head"` | `"head"` |
| `worktree.symlinkDirectories` | Dirs to symlink into each worktree | `["node_modules"]` |
| `worktree.sparsePaths` | Sparse-checkout dirs per worktree | `["packages/my-app"]` |
| `parentSettingsBehavior` | `"first-wins"` (default) or `"merge"` for SDK-supplied managed settings | `"merge"` |

### Permission Settings

```json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Read(~/.zshrc)"],
    "deny":  ["Bash(curl *)", "Read(./.env)", "Read(./secrets/**)"],
    "ask":   ["Bash(git push *)"],
    "additionalDirectories": ["../docs/"],
    "defaultMode": "acceptEdits"
  }
}
```

| Key | Description |
| :--- | :--- |
| `allow` | Auto-approve matching tool calls |
| `deny` | Block matching tool calls |
| `ask` | Prompt for matching tool calls |
| `additionalDirectories` | Extra working dirs for file access (file access only, not full config) |
| `defaultMode` | Starting permission mode |
| `disableBypassPermissionsMode` | Set `"disable"` to block bypassPermissions mode |
| `skipDangerousModePermissionPrompt` | Skip confirmation before bypassPermissions |

### Permission Rule Syntax

Format: `Tool` or `Tool(specifier)`

| Pattern | Matches |
| :--- | :--- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Bash(git * main)` | Any git command ending with `main` |
| `Read(./.env)` | Reads of the `.env` file |
| `Read(//path/to/file)` | Absolute path (`//` = filesystem root) |
| `Read(~/Documents/*.pdf)` | Home-relative path |
| `Read(/src/**)` | Project-root-relative path |
| `WebFetch(domain:example.com)` | Fetch to example.com |
| `mcp__puppeteer__navigate` | Specific MCP tool |
| `Agent(Explore)` | Specific subagent |

Rules evaluate: **deny first → ask → allow**. First match wins. A bare `Bash` deny removes the tool entirely; `Bash(rm *)` leaves it available but blocks matching calls.

### Permission Modes

| Mode | Auto-approves | Set via |
| :--- | :--- | :--- |
| `default` | Reads only | Shift+Tab cycle |
| `acceptEdits` | Reads, file edits, common filesystem cmds | Shift+Tab |
| `plan` | Reads only (no edits) | Shift+Tab or `--permission-mode plan` |
| `auto` | Everything with classifier safety checks | Shift+Tab (if eligible) |
| `dontAsk` | Only pre-approved tools | `--permission-mode dontAsk` |
| `bypassPermissions` | Everything (circuit breaker for `rm -rf /`) | `--permission-mode bypassPermissions` |

Set default mode in settings:
```json
{ "permissions": { "defaultMode": "acceptEdits" } }
```

Auto mode requires: Claude Code v2.1.83+, Claude Sonnet/Opus 4.6+, Anthropic API (not Bedrock/Vertex/Foundry), admin-enabled on Team/Enterprise.

### Sandbox Settings (`sandbox.*`)

| Key | Description | Default |
| :--- | :--- | :--- |
| `enabled` | Enable bash sandboxing (macOS, Linux, WSL2) | `false` |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed | `true` |
| `excludedCommands` | Commands that bypass sandbox | `["docker *"]` |
| `allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape | `true` |
| `filesystem.allowWrite` | Paths sandbox can write | — |
| `filesystem.denyWrite` | Paths sandbox cannot write | — |
| `filesystem.denyRead` | Paths sandbox cannot read | — |
| `filesystem.allowRead` | Re-allow within denyRead regions | — |
| `network.allowedDomains` | Outbound domain allowlist (supports `*`) | — |
| `network.deniedDomains` | Outbound domain blocklist | — |
| `network.allowLocalBinding` | Allow localhost port binding (macOS) | `false` |
| `network.allowUnixSockets` | Unix socket paths (macOS) | — |
| `failIfUnavailable` | Exit if sandbox cannot start | `false` |

Sandbox path prefixes: `/` = absolute, `~/` = home-relative, `./` or no prefix = project-root-relative (in project settings) or `~/.claude`-relative (in user settings).

### Managed-Only Settings

These only take effect in managed settings (MDM/plist/registry, `managed-settings.json`, or server-managed). Ignored in user/project settings:

| Setting | Effect |
| :--- | :--- |
| `allowManagedPermissionRulesOnly` | Only managed allow/ask/deny rules apply |
| `allowManagedMcpServersOnly` | Only managed MCP allowlist respected |
| `allowManagedHooksOnly` | Only managed/SDK/force-enabled plugin hooks load |
| `strictKnownMarketplaces` | Allowlist plugin marketplace sources |
| `blockedMarketplaces` | Blocklist marketplace sources |
| `strictPluginOnlyCustomization` | Block user/project skills, agents, hooks, MCP |
| `channelsEnabled` | Allow channels for org |
| `forceRemoteSettingsRefresh` | Block startup until remote settings fetched |
| `allowAllClaudeAiMcps` | Load claude.ai connectors alongside managed-mcp.json |
| `claudeMd` | Org-wide CLAUDE.md injected as managed memory |
| `wslInheritsWindowsSettings` | WSL reads Windows managed settings |
| `policyHelper` | Admin executable to compute settings dynamically |

### Auto Mode Configuration (`autoMode`)

Configure the classifier's trusted infrastructure in `~/.claude/settings.json` (or managed settings). Not read from shared project settings.

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp",
      "Trusted buckets: s3://acme-build-artifacts"
    ],
    "soft_deny": ["$defaults", "Never run terraform apply"],
    "allow": ["$defaults", "Pushing to acme-corp/* repos is always OK"]
  }
}
```

Include `"$defaults"` to inherit built-in rules at that position. Use `claude auto-mode defaults` to see the full default rule lists.

### Server-Managed Settings

Delivered from Claude.ai admin console → **Admin Settings > Claude Code > Managed settings**. Requires Teams/Enterprise plan and Claude Code v2.1.38+ (Teams) or v2.1.30+ (Enterprise).

- Settings refresh at authentication and hourly during active sessions
- All `settings.json` keys supported except a small set requiring OS-level delivery
- Use `forceRemoteSettingsRefresh: true` to block startup until settings fetch succeeds

### Key Environment Variables

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key (overrides subscription) |
| `ANTHROPIC_MODEL` | Default model |
| `ANTHROPIC_BASE_URL` | Proxy/gateway endpoint |
| `ANTHROPIC_BEDROCK_BASE_URL` | Custom Bedrock endpoint |
| `ANTHROPIC_VERTEX_BASE_URL` | Custom Vertex AI endpoint |
| `API_TIMEOUT_MS` | API request timeout (default: 600000) |
| `BASH_DEFAULT_TIMEOUT_MS` | Bash command timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout model can set (default: 600000) |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set `1` to enable OpenTelemetry |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Set `1` to disable auto memory |
| `CLAUDE_CODE_DISABLE_THINKING` | Set `1` to force-disable extended thinking |
| `CLAUDE_CODE_EFFORT_LEVEL` | `low/medium/high/xhigh/max/auto` |
| `CLAUDE_CODE_NO_FLICKER` | Set `1` for fullscreen rendering |
| `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN` | Set `1` for classic renderer |
| `CLAUDE_CODE_MAX_TURNS` | Cap agentic turns |
| `DISABLE_AUTOUPDATER` | Set `1` to disable auto-updates |
| `DISABLE_TELEMETRY` | Set `1` to disable telemetry |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disables autoupdater, feedback, error reporting, telemetry |
| `MAX_THINKING_TOKENS` | Budget for extended thinking |
| `CLAUDE_CODE_OAUTH_TOKEN` | OAuth token for Claude.ai auth (alternative to `/login`) |

Set environment variables in `settings.json` under the `env` key for persistent team-wide application.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — all settings keys, scopes, precedence, permission/sandbox/attribution/worktree/plugin settings, policy helper
- [Configure permissions](references/claude-code-permissions.md) — permission system, rule syntax, tool-specific patterns, managed-only settings, working directories
- [Choose a permission mode](references/claude-code-permission-modes.md) — all 6 modes, switching, auto mode details, dontAsk, bypassPermissions, protected paths
- [Environment variables](references/claude-code-env-vars.md) — complete variable reference, precedence, how to set in shell or settings files
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — admin console setup, Teams/Enterprise requirements, fail-closed enforcement
- [Set up Claude Code for your organization](references/claude-code-admin-setup.md) — admin decision map, API providers, settings delivery mechanisms, enforcement controls
- [Configure auto mode](references/claude-code-auto-mode-config.md) — trusted infrastructure, rule overrides, CLI subcommands, reviewing denials

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Set up Claude Code for your organization: https://code.claude.com/docs/en/admin-setup.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
