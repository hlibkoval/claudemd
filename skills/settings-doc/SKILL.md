---
name: settings-doc
description: Complete official documentation for Claude Code settings — configuration scopes, settings.json keys, permission modes, permission rule syntax, environment variables, managed settings, server-managed settings, admin setup, and auto mode configuration.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, and configuration.

## Quick Reference

### Configuration Scopes and File Locations

| Scope | File | Who it affects | Shared? |
| :--- | :--- | :--- | :--- |
| **Managed** | Server, plist/registry, or system `managed-settings.json` | All users on the machine | Yes (IT-deployed) |
| **User** | `~/.claude/settings.json` | You, across all projects | No |
| **Project** | `.claude/settings.json` | All collaborators | Yes (committed to git) |
| **Local** | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |

**Precedence (highest to lowest):** Managed > CLI args > Local > Project > User

Array settings (e.g. `permissions.allow`, `sandbox.filesystem.allowWrite`) **merge** across scopes — entries are concatenated, not replaced.

### Managed Settings Delivery Mechanisms

| Mechanism | Delivery | Platform |
| :--- | :--- | :--- |
| Server-managed | Claude.ai admin console (Teams/Enterprise) | All |
| plist / registry | macOS `com.anthropic.claudecode`, Windows `HKLM\SOFTWARE\Policies\ClaudeCode` | macOS, Windows |
| File-based | macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`; Linux/WSL: `/etc/claude-code/managed-settings.json`; Windows: `C:\Program Files\ClaudeCode\managed-settings.json` | All |
| Windows user registry | `HKCU\SOFTWARE\Policies\ClaudeCode` (lowest; writable without elevation) | Windows only |

Drop-in directory at `managed-settings.d/` alongside the file-based path. Files sorted alphabetically; numeric prefixes recommended (e.g. `10-telemetry.json`).

### Key settings.json Fields

| Key | Description | Example |
| :--- | :--- | :--- |
| `agent` | Run main thread as named subagent | `"code-reviewer"` |
| `alwaysThinkingEnabled` | Enable extended thinking by default | `true` |
| `apiKeyHelper` | Script to generate auth value (`X-Api-Key`) | `"/bin/gen_key.sh"` |
| `attribution` | Customize git commit/PR attribution | `{"commit": "...", "pr": ""}` |
| `autoMemoryEnabled` | Enable/disable auto memory | `false` |
| `autoMode` | Configure auto mode classifier rules | `{"environment": [...]}` |
| `autoUpdatesChannel` | `"stable"` or `"latest"` (default) | `"stable"` |
| `availableModels` | Restrict selectable models | `["sonnet", "haiku"]` |
| `cleanupPeriodDays` | Days before session files are deleted (default: 30) | `20` |
| `companyAnnouncements` | Messages shown at startup | `["Welcome..."]` |
| `defaultShell` | `"bash"` (default) or `"powershell"` | `"powershell"` |
| `disableAllHooks` | Disable all hooks and custom status line | `true` |
| `disableAutoMode` | `"disable"` prevents auto mode | `"disable"` |
| `editorMode` | `"normal"` or `"vim"` | `"vim"` |
| `effortLevel` | `"low"`, `"medium"`, `"high"`, `"xhigh"` | `"xhigh"` |
| `enableAllProjectMcpServers` | Auto-approve all `.mcp.json` servers | `true` |
| `env` | Environment variables for every session | `{"FOO": "bar"}` |
| `forceLoginMethod` | `claudeai` or `console` | `"claudeai"` |
| `forceLoginOrgUUID` | Require login to specific org UUID(s) | `"xxxx-..."` |
| `forceRemoteSettingsRefresh` | Block startup until settings fetched | `true` |
| `hooks` | Lifecycle hooks; see hooks-doc skill | See hooks docs |
| `includeGitInstructions` | Include built-in git workflow instructions (default: `true`) | `false` |
| `language` | Claude's response language | `"japanese"` |
| `minimumVersion` | Floor for auto-updates | `"2.1.100"` |
| `model` | Default model override | `"claude-sonnet-4-6"` |
| `permissions` | See Permission Settings table below | — |
| `preferredNotifChannel` | Notification method | `"terminal_bell"` |
| `sandbox` | Sandboxing config; see Sandbox Settings table | — |
| `showClearContextOnPlanAccept` | Show clear-context on plan accept | `true` |
| `showThinkingSummaries` | Show extended thinking summaries | `true` |
| `tui` | `"fullscreen"` or `"default"` renderer | `"fullscreen"` |
| `viewMode` | Default transcript view: `"default"`, `"verbose"`, `"focus"` | `"verbose"` |
| `voice` | Voice dictation settings | `{"enabled": true, "mode": "tap"}` |

### Permission Settings (`permissions.*`)

| Key | Description | Example |
| :--- | :--- | :--- |
| `allow` | Rules to allow tool use without prompting | `["Bash(npm run *)"]` |
| `ask` | Rules to always prompt before tool use | `["Bash(git push *)"]` |
| `deny` | Rules to block tool use | `["WebFetch", "Read(./.env)"]` |
| `additionalDirectories` | Extra working directories for file access | `["../docs/"]` |
| `defaultMode` | Default permission mode at startup | `"acceptEdits"` |
| `disableBypassPermissionsMode` | `"disable"` to block bypass mode | `"disable"` |
| `skipDangerousModePermissionPrompt` | Skip bypass mode confirmation prompt | `true` |

### Permission Rule Syntax

Rules follow the format `Tool` or `Tool(specifier)`. Evaluated **deny → ask → allow**; first match wins.

| Pattern | Effect |
| :--- | :--- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Bash(* --version)` | Any command ending with ` --version` |
| `Read(./.env)` | Reading `.env` in current directory |
| `Read(//Users/alice/secrets/**)` | Absolute path (use `//` prefix) |
| `Read(/src/**)` | Project-root-relative path (use `/` prefix) |
| `Edit(~/.zshrc)` | Home-directory-relative path |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `Agent(my-agent)` | Specific subagent |

Bash: `*` matches any chars including spaces; space before `*` enforces word boundary. Compound commands are split and each subcommand matched independently. Process wrappers `timeout`, `time`, `nice`, `nohup`, `stdbuf`, and bare `xargs` are stripped before matching.

Read/Edit patterns use gitignore spec: `//path` = absolute; `~/path` = home-relative; `/path` = project-root-relative; `path` or `./path` = cwd-relative.

### Permission Modes

| Mode | What auto-runs | Best for |
| :--- | :--- | :--- |
| `default` | Reads only | Sensitive work, getting started |
| `acceptEdits` | Reads, file edits, common filesystem commands | Iterating on code |
| `plan` | Reads only (Claude proposes before acting) | Exploring before changing |
| `auto` | Everything with background safety classifier | Long tasks, reduced fatigue |
| `dontAsk` | Only pre-approved tools; everything else denied | CI/locked-down scripts |
| `bypassPermissions` | Everything (no safety checks) | Isolated containers/VMs only |

Switch mid-session with `Shift+Tab` (cycles default → acceptEdits → plan). Set permanently: `permissions.defaultMode` in settings. Start with: `claude --permission-mode <mode>`.

Protected paths (never auto-approved except in `bypassPermissions`): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except commands/agents/skills/worktrees), `.gitconfig`, `.gitmodules`, shell rc files, `.mcp.json`, `.claude.json`.

### Auto Mode Classifier

Auto mode (v2.1.83+) routes tool calls through a safety classifier. Requirements: Max/Team/Enterprise/API plan; supported model (Sonnet 4.6, Opus 4.6, or Opus 4.7); Anthropic API only (not Bedrock/Vertex/Foundry). Team/Enterprise admins must enable it in admin settings.

**Blocked by default:** `curl | bash`, sending data to external endpoints, production deploys, mass cloud deletion, IAM changes, force push to main, irreversible file destruction.

**Allowed by default:** local file ops, dependency installs from lock files, reading `.env` for matching APIs, read-only HTTP, pushing to current/Claude-created branch.

Configure trusted infrastructure in `autoMode.environment`:

```json
{
  "autoMode": {
    "environment": [
      "Source control: github.example.com/acme-corp",
      "Trusted buckets: s3://acme-build-artifacts",
      "Trusted domains: *.corp.example.com"
    ]
  }
}
```

Not read from shared project settings (`.claude/settings.json`).

### Sandbox Settings (`sandbox.*`)

| Key | Description | Example |
| :--- | :--- | :--- |
| `enabled` | Enable bash sandboxing | `true` |
| `failIfUnavailable` | Exit if sandbox can't start | `true` |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: `true`) | `true` |
| `excludedCommands` | Commands that run outside sandbox | `["docker *"]` |
| `allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch | `false` |
| `filesystem.allowWrite` | Additional write paths | `["/tmp/build", "~/.kube"]` |
| `filesystem.denyWrite` | Blocked write paths | `["/etc"]` |
| `filesystem.denyRead` | Blocked read paths | `["~/.aws/credentials"]` |
| `filesystem.allowRead` | Re-allow reads within `denyRead` regions | `["."]` |
| `network.allowedDomains` | Allowed outbound domains (wildcards supported) | `["github.com", "*.npmjs.org"]` |
| `network.deniedDomains` | Blocked domains (takes precedence over allowed) | `["sensitive.example.com"]` |
| `network.allowUnixSockets` | Unix socket paths (macOS only) | `["~/.ssh/agent-socket"]` |
| `network.allowLocalBinding` | Allow binding to localhost ports (macOS only) | `true` |
| `network.httpProxyPort` | HTTP proxy port (bring your own proxy) | `8080` |

Sandbox path prefixes: `/path` = absolute; `~/path` = home-relative; `./path` or no prefix = project-relative (in project settings) or `~/.claude`-relative (in user settings).

### Managed-Only Settings

These keys only take effect when placed in managed settings; ignored in user/project settings:

`allowedChannelPlugins`, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowManagedPermissionRulesOnly`, `blockedMarketplaces`, `channelsEnabled`, `forceRemoteSettingsRefresh`, `pluginTrustMessage`, `sandbox.filesystem.allowManagedReadPathsOnly`, `sandbox.network.allowManagedDomainsOnly`, `strictKnownMarketplaces`, `wslInheritsWindowsSettings`

### Key Environment Variables

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key (overrides subscription in non-interactive mode) |
| `ANTHROPIC_BASE_URL` | Override API endpoint for proxy/gateway |
| `ANTHROPIC_MODEL` | Override default model |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set to `1` to enable OpenTelemetry |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout (default: 600000) |
| `DISABLE_AUTOUPDATER` | Set to `1` to disable auto-updates |
| `DISABLE_TELEMETRY` | Set to `1` to opt out of telemetry |
| `DISABLE_PROMPT_CACHING` | Set to `1` to disable prompt caching |
| `DISABLE_AUTO_COMPACT` | Set to `1` to disable auto-compaction |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget |
| `MCP_TIMEOUT` | MCP server startup timeout (default: 30000ms) |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy configuration |

See the [full environment variables reference](references/claude-code-env-vars.md) for 100+ variables.

### Worktree Settings

| Key | Description | Example |
| :--- | :--- | :--- |
| `worktree.symlinkDirectories` | Symlink these dirs from main repo into worktrees | `["node_modules", ".cache"]` |
| `worktree.sparsePaths` | Check out only these dirs via sparse-checkout | `["packages/my-app"]` |

### Plugin Settings

| Key | Description |
| :--- | :--- |
| `enabledPlugins` | `{"plugin@marketplace": true/false}` — enable/disable plugins per scope |
| `extraKnownMarketplaces` | Register additional marketplace sources for the project/team |
| `strictKnownMarketplaces` | (Managed only) Allowlist of permitted marketplace sources |
| `blockedMarketplaces` | (Managed only) Blocklist of marketplace sources |

### Verify Active Settings

Run `/status` inside Claude Code to see which settings sources are active and their origins (`(remote)`, `(plist)`, `(HKLM)`, `(HKCU)`, `(file)`).

Run `/permissions` to view all active permission rules and which settings file each comes from.

### Global Config Settings (stored in `~/.claude.json`, not settings.json)

| Key | Description |
| :--- | :--- |
| `autoConnectIde` | Auto-connect to running IDE at startup (default: `false`) |
| `autoInstallIdeExtension` | Auto-install IDE extension from VS Code terminal (default: `true`) |
| `externalEditorContext` | Prepend Claude's last response in external editor (default: `false`) |

### Admin Setup Decision Map

| Decision | Reference |
| :--- | :--- |
| API provider (Teams, Console, Bedrock, Vertex, Foundry) | [admin-setup](references/claude-code-admin-setup.md) |
| How settings reach devices (server, MDM, file) | [server-managed-settings](references/claude-code-server-managed-settings.md) |
| What to enforce (permissions, sandbox, MCP, plugins, hooks) | [permissions](references/claude-code-permissions.md) |
| Usage visibility (OTel, analytics, cost tracking) | Monitoring/Analytics docs |
| Data handling | Data usage/Security docs |

## Full Documentation

For the complete official documentation, see the reference files:

- [Settings reference](references/claude-code-settings.md) — all settings.json keys, configuration scopes, file locations, precedence rules, permission settings, sandbox settings, attribution, file suggestion, and plugin configuration
- [Permissions](references/claude-code-permissions.md) — permission system, rule syntax, tool-specific patterns, permission modes, working directories, managed policies, and sandboxing interaction
- [Permission modes](references/claude-code-permission-modes.md) — all modes (default, acceptEdits, plan, auto, dontAsk, bypassPermissions), how to switch, auto mode classifier behavior, and protected paths
- [Environment variables](references/claude-code-env-vars.md) — complete reference for all environment variables that control Claude Code behavior
- [Server-managed settings](references/claude-code-server-managed-settings.md) — server-delivered policy, fetch/caching behavior, fail-closed startup, security approval dialogs, and limitations
- [Admin setup](references/claude-code-admin-setup.md) — decision map for administrators: API provider, settings delivery, enforcement, usage monitoring, and data handling
- [Auto mode configuration](references/claude-code-auto-mode-config.md) — configure trusted infrastructure for the auto mode classifier, override block/allow rules, inspect effective config

## Sources

- Settings reference: https://code.claude.com/docs/en/settings.md
- Permissions: https://code.claude.com/docs/en/permissions.md
- Permission modes: https://code.claude.com/docs/en/permission-modes.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Admin setup: https://code.claude.com/docs/en/admin-setup.md
- Auto mode configuration: https://code.claude.com/docs/en/auto-mode-config.md
