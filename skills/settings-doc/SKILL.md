---
name: settings-doc
user-invocable: false
description: >
  Complete official documentation for Claude Code settings, permissions,
  environment variables, permission modes, server-managed settings, and
  enterprise admin setup. Covers settings.json keys, scope hierarchy,
  permission rule syntax, auto mode configuration, and deployment guidance.
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, environment variables, permission modes, server-managed settings, and enterprise admin deployment.

## Quick Reference

### Settings file locations

| Scope | File | Shared? |
| :---- | :--- | :------ |
| Managed (highest) | Server-managed, MDM plist/registry, or system `managed-settings.json` | Yes (deployed by IT) |
| User | `~/.claude/settings.json` | No |
| Project | `.claude/settings.json` | Yes (git) |
| Local (lowest) | `.claude/settings.local.json` | No (gitignored) |

System managed-settings.json paths: macOS `/Library/Application Support/ClaudeCode/`, Linux/WSL `/etc/claude-code/`, Windows `C:\Program Files\ClaudeCode\`.

Precedence order (highest to lowest): Managed > CLI args > Local > Project > User.

Permission rules **merge** across scopes (deny from any scope wins); other settings use highest-precedence-wins.

### Key settings.json fields

| Key | Purpose | Example |
| :-- | :------ | :------ |
| `permissions.allow` | Auto-approve tool calls | `["Bash(npm run test *)"]` |
| `permissions.deny` | Block tool calls | `["Bash(curl *)", "Read(./.env)"]` |
| `permissions.ask` | Always prompt for confirmation | `["Bash(git push *)"]` |
| `permissions.defaultMode` | Starting permission mode | `"acceptEdits"` |
| `permissions.additionalDirectories` | Extra working dirs for file access | `["../docs/"]` |
| `permissions.disableBypassPermissionsMode` | Block bypass-permissions mode | `"disable"` |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `env` | Environment variables for all sessions | `{"FOO": "bar"}` |
| `hooks` | Lifecycle hook commands | see hooks-doc |
| `autoMode` | Auto mode classifier config | `{"environment": [...]}` |
| `apiKeyHelper` | Script to generate API key | `"/bin/gen_key.sh"` |
| `enableAllProjectMcpServers` | Auto-approve all project MCP servers | `true` |
| `disabledMcpjsonServers` | Reject specific MCP servers | `["filesystem"]` |
| `enabledMcpjsonServers` | Approve specific MCP servers | `["github"]` |
| `theme` | UI color theme | `"dark"`, `"light"`, `"auto"` |
| `verbose` | Show full tool output | `true` |
| `editorMode` | Input key binding mode | `"vim"` |
| `tui` | Terminal renderer | `"fullscreen"` or `"default"` |
| `autoCompactEnabled` | Auto-compact at context limit | `true` |
| `fileCheckpointingEnabled` | Snapshot files before edits | `true` |
| `autoMemoryEnabled` | Enable auto memory | `true` |
| `autoUpdatesChannel` | Update release channel | `"stable"` or `"latest"` |
| `cleanupPeriodDays` | Session file retention days | `30` |
| `includeGitInstructions` | Include git workflow in system prompt | `true` |
| `language` | Claude response language | `"japanese"` |
| `outputStyle` | Output style / system prompt flavor | `"Explanatory"` |
| `statusLine` | Custom status line command | `{"type":"command","command":"~/.claude/statusline.sh"}` |
| `worktree.baseRef` | Branch new worktrees from | `"fresh"` or `"head"` |
| `fallbackModel` | Fallback model chain | `["claude-sonnet-4-6","claude-haiku-4-5"]` |
| `effortLevel` | Persist effort level | `"xhigh"` |
| `companyAnnouncements` | Startup announcements for org | `["Welcome to Acme Corp!"]` |

### Managed-only settings (ignored in user/project files)

| Key | Effect |
| :-- | :----- |
| `allowManagedPermissionRulesOnly` | Only managed allow/ask/deny rules apply |
| `allowManagedMcpServersOnly` | Only managed MCP allowlist is respected |
| `allowManagedHooksOnly` | Only managed hooks load |
| `allowManagedPermissionRulesOnly` | Block user/project permission rule additions |
| `strictKnownMarketplaces` | Allowlist of plugin marketplace sources |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `strictPluginOnlyCustomization` | Lock skills/agents/hooks/MCPs to plugins only |
| `channelsEnabled` | Allow channels for the org |
| `claudeMd` | Org-wide CLAUDE.md instructions |
| `forceRemoteSettingsRefresh` | Fail-closed: block startup if fetch fails |
| `forceLoginMethod` | Restrict login to `claudeai` or `console` |
| `forceLoginOrgUUID` | Require specific org UUID |
| `requiredMinimumVersion` | Block startup below this version |
| `requiredMaximumVersion` | Block startup above this version |
| `allowAllClaudeAiMcps` | Load claude.ai connectors alongside managed-mcp.json |
| `wslInheritsWindowsSettings` | WSL reads Windows policy chain |
| `policyHelper` | Admin executable to compute managed settings dynamically |

### Permission rule syntax

Format: `Tool` or `Tool(specifier)`

| Rule | Effect |
| :--- | :----- |
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run ` |
| `Read(./.env)` | Matches reading the `.env` file |
| `WebFetch(domain:example.com)` | Matches fetch to example.com |
| `mcp__github__get_*` | All `get_` tools from the github MCP server |
| `Agent(Explore)` | Matches the Explore subagent |
| `*` | Matches every tool (deny/ask only) |

Evaluation order: **deny** first, then **ask**, then **allow**. First match wins; specificity does not override order. Deny rules from any scope cannot be overridden by allow rules from other scopes.

Bash rules strip common process wrappers (`timeout`, `time`, `nice`, `nohup`, `stdbuf`, bare `xargs`) before matching. Compound commands (`&&`, `||`, `;`, `|`) require each sub-command to match independently.

Read/Edit path anchors:

| Pattern | Anchor |
| :------ | :----- |
| `//path` | Absolute from filesystem root |
| `~/path` | From home directory |
| `/path` | Relative to project root |
| `path` or `./path` | Relative to cwd |

### Permission modes

Set via `permissions.defaultMode`, `--permission-mode`, or `Shift+Tab` in CLI.

| Mode | Auto-approves | Best for |
| :--- | :------------ | :------- |
| `default` | Reads only | Normal use, sensitive work |
| `acceptEdits` | Reads + file edits + common filesystem cmds | Iterating on code |
| `plan` | Reads only; no source edits | Exploring before changing |
| `auto` | Everything, with classifier safety checks | Long tasks, fewer prompts |
| `dontAsk` | Only pre-approved tools | Locked-down CI/scripts |
| `bypassPermissions` | Everything (use in containers only) | Isolated VMs/containers |

`auto` mode requirements: Claude Opus 4.6+ or Sonnet 4.6 (Anthropic API); Opus 4.7/4.8 on Bedrock/Vertex/Foundry (plus `CLAUDE_CODE_ENABLE_AUTO_MODE=1`). On Team/Enterprise, admins must enable it in Claude Code admin settings.

Protected paths (never auto-approved except in `bypassPermissions`): `.git`, `.claude`, `.vscode`, `.idea`, `.husky`, `.bashrc`, `.zshrc`, `.gitconfig`, `.mcp.json`, and others — see the full list in the reference.

### Auto mode classifier configuration

The `autoMode` settings block tells the classifier which infrastructure is trusted. Only read from user settings, local project settings, managed settings, and `--settings` flag — NOT from shared `.claude/settings.json`.

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp",
      "Trusted buckets: s3://acme-builds",
      "Trusted domains: *.corp.example.com"
    ],
    "allow": ["$defaults", "Deploying to staging is allowed"],
    "soft_deny": ["$defaults", "Never run DB migrations outside migrations CLI"],
    "hard_deny": ["$defaults", "Never send repo contents to third-party review APIs"]
  }
}
```

Include `"$defaults"` in each array to inherit built-in rules. Omitting it replaces the entire default list. Inspect effective config with `claude auto-mode config`; print defaults with `claude auto-mode defaults`.

Auto mode precedence inside the classifier: `hard_deny` > `soft_deny` (can be overridden by explicit user intent or `allow`) > `allow`.

### Server-managed settings delivery

Available for Teams/Enterprise plans. Settings delivered from Claude.ai admin console at auth time, refreshed hourly.

Priority chain (first non-empty wins): Server-managed > plist/HKLM registry > file-based > HKCU registry.

Server-managed settings do NOT work with Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`.

To enforce fail-closed (block startup if fetch fails): `"forceRemoteSettingsRefresh": true`.

Verify active settings: run `/status` in Claude Code — look for `Enterprise managed settings (remote|plist|HKLM|HKCU|file)`.

### Key environment variables

| Variable | Purpose |
| :------- | :------ |
| `ANTHROPIC_API_KEY` | API key (overrides subscription login) |
| `ANTHROPIC_MODEL` | Override default model |
| `ANTHROPIC_BASE_URL` | Proxy/gateway endpoint |
| `API_TIMEOUT_MS` | API request timeout (default: 600000ms) |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash command timeout (default: 120000ms) |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout (default: 600000ms) |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set to `1` to enable OpenTelemetry |
| `CLAUDE_CODE_MAX_TURNS` | Cap agentic turn count |
| `CLAUDE_CODE_NO_FLICKER` | Set to `1` for fullscreen renderer |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Set to `1` to disable auto memory |
| `CLAUDE_CODE_EFFORT_LEVEL` | Effort level: `low`, `medium`, `high`, `xhigh` |
| `CLAUDE_CODE_ENABLE_AUTO_MODE` | Set to `1` for auto mode on Bedrock/Vertex/Foundry |
| `MAX_THINKING_TOKENS` | Extended thinking token budget |
| `DISABLE_AUTOUPDATER` | Disable auto-updates |
| `DISABLE_TELEMETRY` | Disable telemetry |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable autoupdater + telemetry + error reporting |

Variables set in shell take precedence over the `env` key in `settings.json`. Many vars have corresponding `settings.json` fields; the env var wins when both are set.

### Admin deployment decision map

1. **API provider**: Claude for Teams/Enterprise (recommended), Console API key, Bedrock, Vertex, or Foundry
2. **Settings delivery**: Server-managed (Teams/Enterprise) or endpoint-managed (MDM plist/registry/file)
3. **What to enforce**: permission rules, sandboxing, MCP allowlists, plugin marketplace restrictions, hooks lockdown, version floor/ceiling
4. **Usage visibility**: OpenTelemetry (all providers), Analytics dashboard (Anthropic only), Cost tracking (Anthropic only)
5. **Data handling**: Training opt-out on Teams/Enterprise/API/cloud providers; ZDR available for Enterprise

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) — Complete settings.json reference: all keys, scope hierarchy, precedence, permission rule syntax, worktree settings, global config settings
- [Admin Setup Guide](references/claude-code-admin-setup.md) — Decision map for administrators: API providers, managed settings delivery, enforcement options, usage visibility, data handling
- [Configure Permissions](references/claude-code-permissions.md) — Permission system, rule syntax, tool-specific rules (Bash, PowerShell, Read/Edit, WebFetch, MCP, Agent, Cd), working directories, managed settings
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) — Server-delivered policy via Claude.ai admin console: setup, caching, fail-closed enforcement, security considerations
- [Environment Variables](references/claude-code-env-vars.md) — All environment variables that control Claude Code behavior, with precedence notes
- [Permission Modes](references/claude-code-permission-modes.md) — All six permission modes, how to switch them, protected paths, auto mode requirements and classifier behavior
- [Configure Auto Mode](references/claude-code-auto-mode-config.md) — autoMode settings block: environment/allow/soft_deny/hard_deny fields, CLI subcommands, reviewing denials

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Admin Setup Guide: https://code.claude.com/docs/en/admin-setup.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment Variables: https://code.claude.com/docs/en/env-vars.md
- Permission Modes: https://code.claude.com/docs/en/permission-modes.md
- Configure Auto Mode: https://code.claude.com/docs/en/auto-mode-config.md
