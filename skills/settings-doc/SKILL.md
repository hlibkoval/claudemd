---
name: settings-doc
description: Complete official documentation for Claude Code settings, permissions, permission modes, environment variables, and admin setup — configuration scopes, settings.json keys, permission rules, modes (default/acceptEdits/plan/auto/dontAsk/bypassPermissions), managed settings, server-managed settings, auto mode configuration, and the full environment variable reference.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, permission modes, environment variables, and admin setup.

## Quick Reference

### Configuration Scopes and Files

| Scope       | File location                          | Who it affects                         | Shared?              |
| :---------- | :------------------------------------- | :------------------------------------- | :------------------- |
| **Managed** | MDM/registry/`managed-settings.json`   | All users (deployed by IT)             | Yes (enforced)       |
| **User**    | `~/.claude/settings.json`              | You, across all projects               | No                   |
| **Project** | `.claude/settings.json`                | All collaborators in the repo          | Yes (committed)      |
| **Local**   | `.claude/settings.local.json`          | You, in this repository only           | No (gitignored)      |

Precedence (highest first): Managed > CLI args > Local > Project > User.

Array settings (e.g. `permissions.allow`, `sandbox.filesystem.allowWrite`) **merge** across scopes — lower scopes add entries but cannot remove managed ones.

### Managed Settings Delivery Mechanisms

| Mechanism             | Delivery path                                                                       | Priority | Platforms      |
| :-------------------- | :---------------------------------------------------------------------------------- | :------- | :------------- |
| Server-managed        | Claude.ai admin console                                                             | Highest  | All            |
| plist / registry      | macOS `com.anthropic.claudecode` plist; Windows `HKLM\SOFTWARE\Policies\ClaudeCode` | High     | macOS, Windows |
| File-based managed    | macOS `/Library/Application Support/ClaudeCode/`; Linux `/etc/claude-code/`; Windows `C:\Program Files\ClaudeCode\` | Medium | All |
| Windows user registry | `HKCU\SOFTWARE\Policies\ClaudeCode`                                                 | Lowest   | Windows only   |

File-based managed settings support a drop-in directory `managed-settings.d/` — files are sorted alphabetically and merged on top of `managed-settings.json`.

### Key settings.json Fields

| Key                               | Description                                                                                    | Example                          |
| :-------------------------------- | :--------------------------------------------------------------------------------------------- | :------------------------------- |
| `agent`                           | Run main thread as a named subagent                                                            | `"code-reviewer"`                |
| `allowedHttpHookUrls`             | URL allowlist for HTTP hooks (supports `*` wildcard)                                           | `["https://hooks.example.com/*"]`|
| `allowManagedHooksOnly`           | Managed-only: block all user/project hooks                                                     | `true`                           |
| `allowManagedPermissionRulesOnly` | Managed-only: only managed permission rules apply                                              | `true`                           |
| `alwaysThinkingEnabled`           | Enable extended thinking by default                                                            | `true`                           |
| `apiKeyHelper`                    | Script to generate auth value (sent as `X-Api-Key` / `Authorization: Bearer`)                 | `"/bin/generate_key.sh"`         |
| `attribution`                     | Customize git commit and PR attribution text                                                   | `{"commit": "...", "pr": ""}`    |
| `autoMemoryEnabled`               | Enable/disable auto memory (default: `true`)                                                   | `false`                          |
| `autoMode`                        | Configure auto mode classifier rules (`environment`, `allow`, `soft_deny`, `hard_deny`)        | See auto mode section            |
| `autoUpdatesChannel`              | Release channel: `"stable"` or `"latest"` (default)                                           | `"stable"`                       |
| `availableModels`                 | Restrict models selectable via `/model` or `--model`                                           | `["sonnet", "haiku"]`            |
| `cleanupPeriodDays`               | Days before session files are deleted at startup (default: 30)                                 | `20`                             |
| `companyAnnouncements`            | Startup announcements (cycled randomly)                                                        | `["Welcome to Acme Corp!"]`      |
| `defaultShell`                    | Shell for `!` commands: `"bash"` (default) or `"powershell"`                                  | `"powershell"`                   |
| `disableAllHooks`                 | Disable all hooks and custom status line                                                       | `true`                           |
| `disableAutoMode`                 | Set to `"disable"` to prevent auto mode activation                                             | `"disable"`                      |
| `disableSkillShellExecution`      | Disable inline shell execution in skills from user/project/plugin sources                      | `true`                           |
| `editorMode`                      | Key binding: `"normal"` or `"vim"` (default: `"normal"`)                                       | `"vim"`                          |
| `effortLevel`                     | Persist effort level: `"low"`, `"medium"`, `"high"`, `"xhigh"`                                | `"xhigh"`                        |
| `enableAllProjectMcpServers`      | Auto-approve all MCP servers in `.mcp.json`                                                    | `true`                           |
| `env`                             | Environment variables applied to every session                                                 | `{"FOO": "bar"}`                 |
| `forceLoginMethod`                | Restrict login to `"claudeai"` or `"console"`                                                  | `"claudeai"`                     |
| `forceLoginOrgUUID`               | Require login to a specific org UUID                                                           | `"xxxxxxxx-..."`                 |
| `forceRemoteSettingsRefresh`      | Managed-only: block startup until server settings fetched                                      | `true`                           |
| `hooks`                           | Configure hook commands for lifecycle events                                                   | See hooks-doc                    |
| `language`                        | Claude's preferred response language                                                           | `"japanese"`                     |
| `minimumVersion`                  | Floor for auto-updates (prevents downgrades below this version)                                | `"2.1.100"`                      |
| `model`                           | Override default model                                                                         | `"claude-sonnet-4-6"`            |
| `permissions`                     | Permission allow/deny/ask rules and mode settings                                              | See permissions section          |
| `sandbox`                         | Sandboxing configuration                                                                       | See sandbox section              |
| `statusLine`                      | Custom status line command                                                                     | `{"type": "command", "command": "~/.claude/statusline.sh"}` |
| `tui`                             | Terminal UI renderer: `"fullscreen"` or `"default"`                                            | `"fullscreen"`                   |

Full settings reference: [`$schema`](https://json.schemastore.org/claude-code-settings.json)

### Permission Settings

```json
{
  "permissions": {
    "allow":  ["Bash(npm run *)", "Read(~/.zshrc)"],
    "ask":    ["Bash(git push *)"],
    "deny":   ["Bash(curl *)", "Read(./.env)", "Read(./secrets/**)"],
    "defaultMode": "acceptEdits",
    "additionalDirectories": ["../docs/"],
    "disableBypassPermissionsMode": "disable"
  }
}
```

Rules evaluated: **deny first, then ask, then allow**. First matching rule wins.

### Permission Rule Syntax

| Rule                           | Effect                                          |
| :----------------------------- | :---------------------------------------------- |
| `Bash`                         | Matches all Bash commands                       |
| `Bash(npm run *)`              | Commands starting with `npm run`                |
| `Read(./.env)`                 | Reading `.env` in current directory             |
| `WebFetch(domain:example.com)` | Fetch requests to example.com                  |
| `mcp__puppeteer`               | Any tool from the `puppeteer` MCP server        |
| `Agent(Explore)`               | The Explore subagent                            |

Path patterns: `//path` = absolute; `~/path` = from home; `/path` = relative to project root; `path` or `./path` = relative to cwd. Note: `*` matches single directory, `**` matches recursively.

### Permission Modes

| Mode                | What runs without prompting                                     | Best for                                |
| :------------------ | :-------------------------------------------------------------- | :-------------------------------------- |
| `default`           | Reads only                                                      | Getting started, sensitive work         |
| `acceptEdits`       | Reads, file edits, common filesystem commands                   | Iterating on code                       |
| `plan`              | Reads only (Claude proposes but doesn't execute edits)          | Exploring before changing               |
| `auto`              | Everything, with background classifier safety checks            | Long tasks, reducing prompt fatigue     |
| `dontAsk`           | Only pre-approved tools (all else auto-denied)                  | CI and locked-down scripts              |
| `bypassPermissions` | Everything (circuit breaker for `rm -rf /` and `rm -rf ~`)     | Isolated containers/VMs only           |

Switch modes: `Shift+Tab` in CLI; `--permission-mode <mode>` at startup; `permissions.defaultMode` in settings.

**Auto mode requirements:** Claude Code v2.1.83+; Max/Team/Enterprise/API plan (not Pro); admin must enable on Team/Enterprise; Sonnet 4.6, Opus 4.6, or Opus 4.7; Anthropic API only (not Bedrock/Vertex/Foundry).

### Auto Mode Classifier Configuration

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp",
      "Trusted cloud buckets: s3://acme-builds",
      "Trusted internal domains: *.corp.example.com"
    ],
    "allow":     ["$defaults", "Deploying to staging is allowed"],
    "soft_deny": ["$defaults", "Never run terraform apply outside the migrations CLI"],
    "hard_deny": ["$defaults", "Never send repo contents to third-party APIs"]
  }
}
```

Include `"$defaults"` to inherit built-in rules. Omitting it **replaces** the entire default list. Read from user settings, `settings.local.json`, managed settings, and `--settings` flag — **not** from shared project settings. Inspect effective config: `claude auto-mode config`; print defaults: `claude auto-mode defaults`.

### Sandbox Settings

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "excludedCommands": ["docker *"],
    "filesystem": {
      "allowWrite": ["/tmp/build", "~/.kube"],
      "denyRead":   ["~/.aws/credentials"]
    },
    "network": {
      "allowedDomains": ["github.com", "*.npmjs.org"],
      "deniedDomains":  ["sensitive.cloud.example.com"],
      "allowLocalBinding": true
    }
  }
}
```

Sandbox path prefixes: `/` = absolute; `~/` = from home; `./` or no prefix = relative to project root (project settings) or `~/.claude` (user settings).

### Managed-Only Settings

These keys are **only read from managed settings** (no effect in user/project settings):

| Setting                             | Purpose                                                              |
| :---------------------------------- | :------------------------------------------------------------------- |
| `allowedChannelPlugins`             | Allowlist channel plugins that may push messages                     |
| `allowManagedHooksOnly`             | Block all user, project, and non-managed plugin hooks                |
| `allowManagedMcpServersOnly`        | Only managed MCP server allowlist applies                            |
| `allowManagedPermissionRulesOnly`   | Only managed permission rules apply (no user/project allow/deny)     |
| `blockedMarketplaces`               | Blocklist marketplace sources (checked before any download)          |
| `channelsEnabled`                   | Allow channels for the organization                                  |
| `claudeMd`                          | Organization-wide CLAUDE.md instructions                             |
| `forceRemoteSettingsRefresh`        | Block startup until server settings fetched; exit on failure         |
| `pluginTrustMessage`                | Custom message appended to plugin trust warning                      |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed `allowRead` paths respected                |
| `sandbox.network.allowManagedDomainsOnly`      | Only managed `allowedDomains` and WebFetch rules respected  |
| `strictKnownMarketplaces`           | Allowlist marketplace sources users may add                          |
| `wslInheritsWindowsSettings`        | WSL reads Windows registry/file managed settings                     |
| `policyHelper`                      | Script to compute managed settings dynamically at startup            |

### Plugin Settings

```json
{
  "enabledPlugins": {
    "formatter@acme-tools": true,
    "deployer@acme-tools": true
  },
  "extraKnownMarketplaces": {
    "acme-tools": {
      "source": { "source": "github", "repo": "acme-corp/claude-plugins" }
    }
  }
}
```

`enabledPlugins`: format is `"plugin-name@marketplace-name": true/false`. Project settings take precedence over user settings; local settings override project for per-machine opt-out.

### Server-Managed Settings

- Requires Claude for Teams or Enterprise plan; Claude Code v2.1.38+ (Teams) or v2.1.30+ (Enterprise)
- Configure at **Admin Settings > Claude Code > Managed settings** on Claude.ai
- Delivered at auth time, polled hourly; cached for subsequent startups
- First-source-wins: if server-managed settings deliver any keys, endpoint-managed (MDM/file) settings are ignored
- Not available on Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`
- Security dialogs shown for shell commands, custom env vars, and hooks (skipped in `-p` mode)
- Set `forceRemoteSettingsRefresh: true` for fail-closed enforcement (CLI exits if fetch fails)

### Key Environment Variables

| Variable                             | Purpose                                                                              |
| :----------------------------------- | :----------------------------------------------------------------------------------- |
| `ANTHROPIC_API_KEY`                  | API key; overrides subscription in interactive mode after one-time approval          |
| `ANTHROPIC_BASE_URL`                 | Override API endpoint for proxy/gateway routing                                      |
| `ANTHROPIC_MODEL`                    | Override model for the session                                                       |
| `BASH_DEFAULT_TIMEOUT_MS`            | Default timeout for bash commands (default: 120000ms)                                |
| `BASH_MAX_TIMEOUT_MS`                | Max timeout the model can set (default: 600000ms)                                    |
| `CLAUDE_CONFIG_DIR`                  | Override config directory (default: `~/.claude`)                                     |
| `CLAUDE_CODE_USE_BEDROCK`            | Use Amazon Bedrock                                                                   |
| `CLAUDE_CODE_USE_VERTEX`             | Use Google Vertex AI                                                                 |
| `CLAUDE_CODE_USE_FOUNDRY`            | Use Microsoft Foundry                                                                |
| `CLAUDE_CODE_ENABLE_TELEMETRY`       | Set to `1` to enable OpenTelemetry collection                                        |
| `CLAUDE_CODE_DISABLE_THINKING`       | Set to `1` to force-disable extended thinking                                        |
| `CLAUDE_CODE_MAX_TURNS`              | Cap agentic turns (equivalent to `--max-turns`)                                      |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB`   | Strip credentials from subprocess environments                                       |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY`    | Set to `1` to skip writing session transcripts to disk                               |
| `CLAUDE_CODE_NO_FLICKER`             | Set to `1` to enable fullscreen TUI renderer                                         |
| `CLAUDE_CODE_EFFORT_LEVEL`           | Set effort: `low`, `medium`, `high`, `xhigh`, `max`, `auto`                          |
| `DISABLE_AUTOUPDATER`                | Set to `1` to disable background auto-updates                                        |
| `DISABLE_TELEMETRY` / `DO_NOT_TRACK` | Set to `1` to opt out of telemetry                                                   |
| `DISABLE_COMPACT`                    | Set to `1` to disable all compaction (auto and manual)                               |
| `DISABLE_AUTO_COMPACT`               | Set to `1` to disable automatic compaction only                                      |
| `HTTP_PROXY` / `HTTPS_PROXY`         | Proxy server for network connections                                                 |
| `MAX_THINKING_TOKENS`                | Override extended thinking token budget                                              |
| `MCP_TIMEOUT`                        | MCP server startup timeout (default: 30000ms)                                        |
| `OTEL_METRICS_EXPORTER`              | OpenTelemetry metrics exporter (e.g. `otlp`)                                         |

Environment variables can also be set in `settings.json` under the `env` key to apply to every session.

### Verify Active Settings

Run `/status` inside Claude Code to see which settings sources are active and their origin (`remote`, `plist`, `HKLM`, `HKCU`, `file`). Use `/permissions` to view effective permission rules.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — configuration scopes, all settings.json keys, permission rules, sandbox settings, attribution, file suggestion, hook configuration, plugin settings, precedence
- [Configure permissions](references/claude-code-permissions.md) — permission system, rule syntax, tool-specific patterns, working directories, managed settings, managed-only settings
- [Choose a permission mode](references/claude-code-permission-modes.md) — all modes in detail, switching modes, acceptEdits, plan mode, auto mode classifier, dontAsk, bypassPermissions, protected paths
- [Configure auto mode](references/claude-code-auto-mode-config.md) — autoMode settings block, defining trusted infrastructure, overriding block/allow rules, CLI subcommands, reviewing denials
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — admin console setup, delivery and caching, fail-closed enforcement, security dialogs, limitations
- [Set up Claude Code for your organization](references/claude-code-admin-setup.md) — deployment decision map, API providers, managed settings delivery, enforcement controls, usage visibility, data handling
- [Environment variables](references/claude-code-env-vars.md) — complete reference for all environment variables

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Set up Claude Code for your organization: https://code.claude.com/docs/en/admin-setup.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
