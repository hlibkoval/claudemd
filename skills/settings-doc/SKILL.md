---
name: settings-doc
description: Complete official documentation for Claude Code settings, permissions, environment variables, permission modes, auto mode configuration, server-managed settings, and admin deployment — including all settings.json keys, scope hierarchy, managed-only settings, permission rule syntax, sandbox configuration, and the full environment variable reference.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for configuring Claude Code, managing permissions, and deploying organization-wide policy.

## Quick Reference

### Configuration Scopes and Files

| Scope       | File(s)                                             | Who it affects                  | Shared? |
| :---------- | :-------------------------------------------------- | :------------------------------ | :------ |
| **Managed** | Server, plist/registry, or `managed-settings.json`  | All users on the machine        | Yes (IT) |
| **User**    | `~/.claude/settings.json`                           | You, across all projects        | No      |
| **Project** | `.claude/settings.json`                             | All collaborators in this repo  | Yes (VC) |
| **Local**   | `.claude/settings.local.json`                       | You, in this repo only          | No      |

**Precedence (highest to lowest):** Managed → CLI args → Local → Project → User

Array settings (`permissions.allow`, `sandbox.filesystem.allowWrite`, etc.) **merge** across scopes rather than override.

### Managed Settings Delivery Mechanisms

| Mechanism              | Location                                                              | Priority | Platforms      |
| :--------------------- | :-------------------------------------------------------------------- | :------- | :------------- |
| Server-managed         | Claude.ai admin console                                               | Highest  | All            |
| plist / registry       | macOS: `com.anthropic.claudecode`; Windows: `HKLM\...\ClaudeCode`    | High     | macOS, Windows |
| File-based             | macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`; Linux/WSL: `/etc/claude-code/managed-settings.json`; Windows: `C:\Program Files\ClaudeCode\managed-settings.json` | Medium | All |
| Windows user registry  | `HKCU\SOFTWARE\Policies\ClaudeCode`                                  | Lowest   | Windows only   |

Drop-in directory `managed-settings.d/*.json` alongside `managed-settings.json`: files sorted alphabetically, merged on top of the base file.

### Key settings.json Fields

| Key | Description | Example |
| :-- | :---------- | :------ |
| `permissions.allow` | Allow tool use without prompting | `["Bash(npm run *)", "Read(~/.zshrc)"]` |
| `permissions.deny` | Deny tool use | `["WebFetch", "Bash(curl *)", "Read(./.env)"]` |
| `permissions.ask` | Prompt for confirmation | `["Bash(git push *)"]` |
| `permissions.defaultMode` | Default permission mode | `"acceptEdits"` |
| `permissions.additionalDirectories` | Extra working dirs for file access | `["../docs/"]` |
| `permissions.disableBypassPermissionsMode` | Prevent bypass mode | `"disable"` |
| `env` | Environment variables for every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle hook commands | See hooks-doc |
| `model` | Default model | `"claude-sonnet-4-6"` |
| `apiKeyHelper` | Script to generate auth value | `"/bin/gen_key.sh"` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) | `"stable"` |
| `availableModels` | Restrict `/model` picker | `["sonnet", "haiku"]` |
| `minimumVersion` | Floor for auto-update | `"2.1.100"` |
| `cleanupPeriodDays` | Session file retention (default 30) | `20` |
| `companyAnnouncements` | Startup messages | `["Welcome!"]` |
| `language` | Claude's response language | `"japanese"` |
| `editorMode` | `"normal"` or `"vim"` | `"vim"` |
| `effortLevel` | Persisted effort: `"low"`, `"medium"`, `"high"`, `"xhigh"` | `"xhigh"` |
| `tui` | `"fullscreen"` or `"default"` | `"fullscreen"` |
| `disableAllHooks` | Disable all hooks | `true` |
| `alwaysThinkingEnabled` | Enable extended thinking by default | `true` |
| `autoMemoryEnabled` | Enable/disable auto memory | `false` |
| `enabledPlugins` | Plugin on/off by `"name@marketplace"` | `{"formatter@acme": true}` |
| `extraKnownMarketplaces` | Add plugin marketplaces for the team | See plugins-doc |
| `claudeMd` | Managed CLAUDE.md injected org-wide | `"Always run make lint before committing."` |
| `forceLoginMethod` | `"claudeai"` or `"console"` | `"claudeai"` |
| `forceLoginOrgUUID` | Require specific org login | `"uuid-string"` |
| `skillOverrides` | Per-skill visibility: `"on"`, `"name-only"`, `"off"` | `{"deploy": "off"}` |
| `autoMode` | Configure auto mode classifier | See auto-mode section |

### Permission Modes

| Mode | What runs without asking | Set with |
| :--- | :----------------------- | :------- |
| `default` | Reads only | `Shift+Tab` (default) |
| `acceptEdits` | Reads, file edits, common filesystem cmds | `Shift+Tab` once |
| `plan` | Reads only (no edits; proposes plan) | `Shift+Tab` twice or `/plan` |
| `auto` | Everything, with background classifier | `Shift+Tab` (when eligible) |
| `dontAsk` | Only pre-approved tools | `--permission-mode dontAsk` |
| `bypassPermissions` | Everything (no safety checks) | `--dangerously-skip-permissions` |

Auto mode requirements: Max/Team/Enterprise/API plan; supported model (Sonnet 4.6, Opus 4.6, Opus 4.7); Anthropic API only; Team/Enterprise admins must enable it.

### Permission Rule Syntax

Format: `Tool` or `Tool(specifier)`. Evaluation order: **deny → ask → allow** (first match wins).

| Rule | Effect |
| :--- | :----- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Bash(git * main)` | Commands like `git checkout main` |
| `Read(./.env)` | Reading `.env` in current directory |
| `Read(//Users/alice/secrets/**)` | Absolute path (note double slash) |
| `Edit(/src/**/*.ts)` | Edits under project `src/` |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer__navigate` | Specific MCP tool |
| `Agent(my-agent)` | Specific subagent |

Path anchors in Read/Edit rules:
- `//path` — absolute from filesystem root
- `~/path` — relative to home directory
- `/path` — relative to project root
- `path` or `./path` — relative to current directory

### Sandbox Settings (`sandbox.*`)

| Key | Description | Default |
| :-- | :---------- | :------ |
| `sandbox.enabled` | Enable OS-level bash isolation | `false` |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed | `true` |
| `sandbox.failIfUnavailable` | Exit if sandbox can't start | `false` |
| `sandbox.excludedCommands` | Commands to run unsandboxed | `["docker *"]` |
| `sandbox.filesystem.allowWrite` | Extra writable paths | `["/tmp/build"]` |
| `sandbox.filesystem.denyRead` | Blocked read paths | `["~/.aws/credentials"]` |
| `sandbox.network.allowedDomains` | Allowed outbound domains | `["github.com"]` |
| `sandbox.network.deniedDomains` | Blocked outbound domains | `["sensitive.example.com"]` |

### Managed-Only Settings (no effect in user/project settings)

| Setting | Description |
| :------ | :---------- |
| `allowManagedPermissionRulesOnly` | Only managed `allow`/`ask`/`deny` rules apply |
| `allowManagedMcpServersOnly` | Only managed MCP servers respected |
| `allowManagedHooksOnly` | Only managed/SDK hooks load |
| `allowedMcpServers` | MCP server allowlist |
| `deniedMcpServers` | MCP server denylist |
| `strictKnownMarketplaces` | Plugin marketplace allowlist |
| `blockedMarketplaces` | Plugin marketplace blocklist |
| `channelsEnabled` | Allow channels for the org |
| `forceRemoteSettingsRefresh` | Block startup until settings fetched |
| `claudeMd` | Org-wide CLAUDE.md injected into every session |
| `pluginTrustMessage` | Custom message before plugin install |
| `allowedChannelPlugins` | Allowlist of channel plugins |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed read-allow paths honored |
| `sandbox.network.allowManagedDomainsOnly` | Only managed allowed domains honored |
| `wslInheritsWindowsSettings` | WSL reads Windows policy chain |
| `policyHelper` | Executable to compute managed settings dynamically |

### Auto Mode Configuration (`autoMode.*`)

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp",
      "Trusted buckets: s3://acme-builds, gs://acme-datasets",
      "Trusted internal domains: *.corp.example.com"
    ],
    "allow": ["$defaults", "Deploying to staging is allowed"],
    "soft_deny": ["$defaults", "Never run migrations outside the migrations CLI"],
    "hard_deny": ["$defaults", "Never send repo contents to third-party APIs"]
  }
}
```

- Include `"$defaults"` to inherit built-in rules at that position; omitting it replaces the entire list.
- `hard_deny` blocks unconditionally; `soft_deny` can be overridden by explicit user intent or `allow` exceptions.
- CLI: `claude auto-mode defaults` / `claude auto-mode config` / `claude auto-mode critique`

### Worktree Settings (`worktree.*`)

| Key | Description | Example |
| :-- | :---------- | :------ |
| `worktree.baseRef` | `"fresh"` (from remote default branch) or `"head"` (from local HEAD) | `"head"` |
| `worktree.symlinkDirectories` | Dirs to symlink into each worktree | `["node_modules"]` |
| `worktree.sparsePaths` | Sparse-checkout dirs per worktree | `["packages/app"]` |

### Attribution Settings (`attribution.*`)

| Key | Description |
| :-- | :---------- |
| `attribution.commit` | Commit attribution text (empty string to hide) |
| `attribution.pr` | PR attribution text (empty string to hide) |

### Selected Environment Variables

| Variable | Purpose |
| :------- | :------ |
| `ANTHROPIC_API_KEY` | API key for direct API access |
| `ANTHROPIC_MODEL` | Override default model |
| `ANTHROPIC_BASE_URL` | Route through proxy/gateway |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CONFIG_DIR` | Override config dir (default `~/.claude`) |
| `CLAUDE_CODE_DISABLE_THINKING` | Force-disable extended thinking |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort: `low`, `medium`, `high`, `xhigh` |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen TUI |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `DISABLE_AUTOUPDATER` | Disable background auto-updates |
| `DISABLE_TELEMETRY` / `DO_NOT_TRACK` | Opt out of telemetry |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash timeout (default 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout (default 600000) |
| `MAX_THINKING_TOKENS` | Extended thinking token budget |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry export |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocesses |
| `CLAUDE_CODE_SHELL_PREFIX` | Prefix wrapping all shell commands |
| `CLAUDE_ENV_FILE` | Script sourced before each Bash command |
| `MCP_TIMEOUT` | MCP server startup timeout (default 30000ms) |

See [Environment variables reference](references/claude-code-env-vars.md) for the full list of 200+ variables.

### Verify Active Settings

Run `/status` inside Claude Code to see which settings sources are active. Managed settings show as `Enterprise managed settings (remote|plist|HKLM|HKCU|file)`.

Run `/permissions` to view all effective permission rules and their source files.

## Full Documentation

For the complete official documentation, see the reference files:

- [Settings](references/claude-code-settings.md) — All settings.json keys, scopes, precedence, sandbox, attribution, plugin, and worktree settings
- [Permissions](references/claude-code-permissions.md) — Permission rule syntax, tool-specific rules, working directories, managed-only settings
- [Permission Modes](references/claude-code-permission-modes.md) — acceptEdits, plan, auto, dontAsk, bypassPermissions; protected paths
- [Environment Variables](references/claude-code-env-vars.md) — Complete reference for all environment variables
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) — Admin console delivery, security dialogs, caching, fail-closed startup
- [Auto Mode Config](references/claude-code-auto-mode-config.md) — Configuring the auto mode classifier with trusted infrastructure
- [Admin Setup](references/claude-code-admin-setup.md) — Decision map for org deployment: API provider, policy delivery, enforcement, monitoring

## Sources

- Settings: https://code.claude.com/docs/en/settings.md
- Permissions: https://code.claude.com/docs/en/permissions.md
- Permission Modes: https://code.claude.com/docs/en/permission-modes.md
- Environment Variables: https://code.claude.com/docs/en/env-vars.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
- Auto Mode Config: https://code.claude.com/docs/en/auto-mode-config.md
- Admin Setup: https://code.claude.com/docs/en/admin-setup.md
