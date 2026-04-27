---
name: settings-doc
description: Complete official documentation for configuring Claude Code — settings files, scopes and precedence, all settings keys, environment variables, permission rules and modes, managed/enterprise settings, server-managed settings, auto mode configuration, and admin deployment decisions.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for configuring Claude Code.

## Quick Reference

### Settings file locations

| Scope | File | Shared? |
| :--- | :--- | :--- |
| Managed (highest) | Managed settings (server, MDM, plist/registry, or file) | Yes — enforced by IT |
| User | `~/.claude/settings.json` | No |
| Project | `.claude/settings.json` | Yes — committed to git |
| Local | `.claude/settings.local.json` | No — gitignored |
| Global config | `~/.claude.json` | No — OAuth, MCP, per-project state |

**Precedence (highest → lowest):** Managed > CLI flags > Local > Project > User

Array settings (`permissions.allow`, `sandbox.filesystem.allowWrite`, etc.) **merge** across scopes rather than overriding.

### Managed settings delivery mechanisms

| Mechanism | Platform | Priority |
| :--- | :--- | :--- |
| Server-managed (Claude.ai admin console) | All | Highest |
| macOS plist (`com.anthropic.claudecode`) | macOS | High |
| Windows registry `HKLM\SOFTWARE\Policies\ClaudeCode` | Windows | High |
| File: `/Library/Application Support/ClaudeCode/managed-settings.json` | macOS | Medium |
| File: `/etc/claude-code/managed-settings.json` | Linux/WSL | Medium |
| File: `C:\Program Files\ClaudeCode\managed-settings.json` | Windows | Medium |
| Windows registry `HKCU\SOFTWARE\Policies\ClaudeCode` | Windows | Lowest |

Drop-in directory: `managed-settings.d/*.json` alongside the base file, merged alphabetically on top of it. Use numeric prefixes (e.g. `10-telemetry.json`) to control merge order.

### Key settings reference (`settings.json`)

| Key | Description | Example |
| :--- | :--- | :--- |
| `agent` | Run main thread as a named subagent | `"code-reviewer"` |
| `apiKeyHelper` | Shell script to generate API auth value | `"/bin/generate_key.sh"` |
| `attribution` | Git commit/PR attribution (`commit`, `pr` keys) | `{"commit": "AI", "pr": ""}` |
| `autoMode` | Auto mode classifier config (`environment`, `allow`, `soft_deny`) | see auto mode section |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) | `"stable"` |
| `availableModels` | Restrict `/model` picker | `["sonnet", "haiku"]` |
| `cleanupPeriodDays` | Session file retention (default 30, min 1) | `20` |
| `companyAnnouncements` | Startup messages (cycled at random) | `["Welcome!"]` |
| `defaultShell` | `"bash"` (default) or `"powershell"` | `"powershell"` |
| `disableAutoMode` | Set `"disable"` to prevent auto mode | `"disable"` |
| `editorMode` | `"normal"` (default) or `"vim"` | `"vim"` |
| `effortLevel` | Effort level: `"low"`, `"medium"`, `"high"`, `"xhigh"` | `"xhigh"` |
| `enableAllProjectMcpServers` | Auto-approve all `.mcp.json` servers | `true` |
| `env` | Environment variables applied to every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle hook commands | see hooks docs |
| `language` | Claude's preferred response language | `"japanese"` |
| `minimumVersion` | Prevent updates below this version | `"2.1.100"` |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `permissions` | Allow/ask/deny rules, defaultMode, additionalDirectories | see below |
| `sandbox` | Sandboxing settings | see below |
| `tui` | `"fullscreen"` or `"default"` renderer | `"fullscreen"` |
| `voice` | Voice dictation settings (`enabled`, `mode`, `autoSubmit`) | `{"enabled": true}` |

### Permission settings

```json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Read(~/.zshrc)"],
    "ask":   ["Bash(git push *)"],
    "deny":  ["WebFetch", "Bash(curl *)", "Read(./.env)", "Read(./secrets/**)"],
    "additionalDirectories": ["../docs/"],
    "defaultMode": "acceptEdits",
    "disableBypassPermissionsMode": "disable"
  }
}
```

**Rule evaluation order:** deny → ask → allow. First match wins.

### Permission rule syntax

| Rule | Effect |
| :--- | :--- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Bash(git * main)` | Commands like `git checkout main` |
| `Read(./.env)` | Reading `.env` in project root |
| `Edit(/src/**)` | Edits under `<project>/src/` |
| `Read(~/.zshrc)` | Home directory file |
| `Read(//tmp/file)` | Absolute path |
| `WebFetch(domain:example.com)` | Fetch to example.com |
| `mcp__puppeteer` | All tools from puppeteer MCP server |
| `mcp__puppeteer__navigate` | Specific MCP tool |
| `Agent(Explore)` | Explore subagent |

**Read/Edit path prefixes:** `//path` = absolute, `~/path` = home, `/path` = project root, `./path` or `path` = relative to cwd.

### Permission modes

| Mode | What runs without prompting | `defaultMode` value |
| :--- | :--- | :--- |
| Default | Reads only | `"default"` |
| Accept Edits | Reads, file edits, common filesystem commands | `"acceptEdits"` |
| Plan | Reads only (no edits, no commands) | `"plan"` |
| Auto | Everything, with background classifier safety checks | `"auto"` |
| Don't Ask | Only pre-approved tools (`permissions.allow`) | `"dontAsk"` |
| Bypass Permissions | Everything except protected paths | `"bypassPermissions"` |

Switch mid-session with `Shift+Tab`, at startup with `--permission-mode <mode>`, or set `permissions.defaultMode` in settings.

**Protected paths (never auto-approved in any mode):** `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `commands/`, `agents/`, `skills/`, `worktrees/`), `.gitconfig`, `.gitmodules`, shell rc files, `.mcp.json`, `.claude.json`.

### Auto mode configuration

Auto mode uses a classifier model. Configure it in user/local/managed settings (not shared project settings):

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp and all repos under it",
      "Trusted cloud buckets: s3://acme-build-artifacts",
      "Trusted internal domains: *.corp.example.com"
    ],
    "allow":    ["$defaults", "Deploying to staging is allowed"],
    "soft_deny": ["$defaults", "Never run terraform apply outside the migrations CLI"]
  }
}
```

Include `"$defaults"` to inherit built-in rules at that position. Omitting it **replaces** the entire default list.

CLI inspection commands:
```bash
claude auto-mode defaults   # Print built-in rules
claude auto-mode config     # Print effective rules with your settings applied
claude auto-mode critique   # Get AI feedback on your custom rules
```

### Sandbox settings

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

Sandbox path prefixes: `/` = absolute, `~/` = home, `./` or no prefix = project root (project settings) or `~/.claude` (user settings).

### Managed-only settings

These keys are only respected when placed in managed settings (ignored in user/project settings):

| Key | Effect |
| :--- | :--- |
| `allowedChannelPlugins` | Allowlist of channel plugins |
| `allowManagedHooksOnly` | Block all non-managed hooks |
| `allowManagedMcpServersOnly` | Only managed MCP servers respected |
| `allowManagedPermissionRulesOnly` | Block user/project permission rules |
| `blockedMarketplaces` | Blocklist of plugin marketplace sources |
| `channelsEnabled` | Enable channels for Team/Enterprise |
| `forceRemoteSettingsRefresh` | Fail-closed: exit if remote fetch fails at startup |
| `pluginTrustMessage` | Custom plugin trust warning text |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed `allowRead` paths respected |
| `sandbox.network.allowManagedDomainsOnly` | Only managed `allowedDomains` respected |
| `strictKnownMarketplaces` | Allowlist of permitted marketplace sources |
| `wslInheritsWindowsSettings` | WSL inherits Windows policy sources |

### Worktree settings

| Key | Description | Example |
| :--- | :--- | :--- |
| `worktree.symlinkDirectories` | Dirs to symlink into worktrees (save disk) | `["node_modules"]` |
| `worktree.sparsePaths` | Sparse-checkout paths per worktree | `["packages/my-app"]` |

### Global config settings (`~/.claude.json` only)

| Key | Description |
| :--- | :--- |
| `autoConnectIde` | Auto-connect to running IDE on external terminal start |
| `autoInstallIdeExtension` | Auto-install Claude Code IDE extension in VS Code |
| `externalEditorContext` | Prepend last response as context in external editor |

### Plugin settings (`settings.json`)

```json
{
  "enabledPlugins": {
    "formatter@acme-tools": true,
    "analyzer@security-plugins": false
  },
  "extraKnownMarketplaces": {
    "acme-tools": {
      "source": { "source": "github", "repo": "acme-corp/claude-plugins" }
    }
  }
}
```

### Attribution settings

```json
{
  "attribution": {
    "commit": "Generated with AI\n\nCo-Authored-By: AI <ai@example.com>",
    "pr": ""
  }
}
```

Empty string hides attribution. Takes precedence over deprecated `includeCoAuthoredBy`.

### File suggestion settings

```json
{
  "fileSuggestion": {
    "type": "command",
    "command": "~/.claude/file-suggestion.sh"
  }
}
```

Script receives `{"query": "src/comp"}` on stdin, outputs newline-separated file paths.

### Key environment variables

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key for authentication |
| `ANTHROPIC_BASE_URL` | Override API endpoint (proxy/gateway) |
| `ANTHROPIC_MODEL` | Model to use |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout (default: 600000) |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set to `1` to enable OpenTelemetry export |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess environments |
| `DISABLE_AUTOUPDATER` | Disable background auto-updates |
| `DISABLE_TELEMETRY` | Opt out of Statsig telemetry |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget |
| `MCP_TIMEOUT` | MCP server startup timeout (default: 30000 ms) |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server for network connections |

See the [full environment variables reference](references/claude-code-env-vars.md) for the complete list of ~100+ variables.

### Verify active settings

Run `/status` inside Claude Code to see which settings sources are active. The output labels each managed source as `(remote)`, `(plist)`, `(HKLM)`, `(HKCU)`, or `(file)`. Run `/permissions` to view effective permission rules and their source files.

### Server-managed settings (admin console)

1. Open Claude.ai **Admin Settings > Claude Code > Managed settings**
2. Enter JSON configuration (all `settings.json` keys supported)
3. Save — clients receive updates at next startup or hourly polling

Security approval dialogs appear on first delivery for shell-command settings, custom env vars, and hooks. In non-interactive mode (`-p`), dialogs are skipped.

**Limitations:** Settings apply uniformly to all org users; per-group config not yet supported. MCP server configurations cannot be distributed via server-managed settings.

### Admin deployment decision map

| Decision | Key settings |
| :--- | :--- |
| Choose API provider | Authentication, Bedrock, Vertex, Foundry |
| Settings delivery mechanism | Server-managed vs. MDM plist/registry vs. file-based |
| Permission enforcement | `permissions.deny`, `allowManagedPermissionRulesOnly`, `disableBypassPermissionsMode` |
| Sandboxing | `sandbox.enabled`, `sandbox.network.allowedDomains` |
| MCP server control | `allowedMcpServers`, `deniedMcpServers`, `allowManagedMcpServersOnly` |
| Plugin marketplace control | `strictKnownMarketplaces`, `blockedMarketplaces` |
| Hook restrictions | `allowManagedHooksOnly`, `allowedHttpHookUrls` |
| Version floor | `minimumVersion` |

Verify with: `claude /status` (look for `Enterprise managed settings` line with source in parentheses).

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — configuration scopes and precedence, all settings keys, permission settings and rule syntax, sandbox settings, attribution, file suggestion, hook configuration, plugin settings, subagent configuration, and environment variables overview
- [Environment variables](references/claude-code-env-vars.md) — complete reference for all ~100+ environment variables that control Claude Code behavior
- [Configure permissions](references/claude-code-permissions.md) — permission system, rule syntax (Bash, Read, Edit, WebFetch, MCP, Agent), working directories, sandboxing interaction, managed settings, and settings precedence
- [Choose a permission mode](references/claude-code-permission-modes.md) — all six modes (default, acceptEdits, plan, auto, dontAsk, bypassPermissions), how to switch modes, auto mode requirements and classifier behavior, and protected paths
- [Set up Claude Code for your organization](references/claude-code-admin-setup.md) — admin deployment decision map covering API providers, settings delivery mechanisms, enforcement controls, usage visibility, and data handling
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — server-managed vs. endpoint-managed settings, admin console setup, fetch and caching behavior, fail-closed enforcement, security approval dialogs, and audit logging
- [Configure auto mode](references/claude-code-auto-mode-config.md) — `autoMode.environment`, `allow`, and `soft_deny` fields, `"$defaults"` inheritance, CLI inspection commands (`auto-mode defaults`, `config`, `critique`), and reviewing denials

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Set up Claude Code for your organization: https://code.claude.com/docs/en/admin-setup.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
