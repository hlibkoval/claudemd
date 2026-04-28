---
name: settings-doc
description: Complete official documentation for Claude Code settings, permissions, environment variables, permission modes, auto mode configuration, and admin/enterprise deployment — configuration scopes, settings.json keys, permission rule syntax, managed settings, and the full environment variable reference.
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code configuration, permissions, and environment variables.

## Quick Reference

### Configuration scopes and file locations

| Scope | Location | Who it affects | Shared? |
| :--- | :--- | :--- | :--- |
| **Managed** | Server, MDM/plist/registry, or managed-settings.json | All users on the machine | Yes (deployed by IT) |
| **User** | `~/.claude/settings.json` | You, across all projects | No |
| **Project** | `.claude/settings.json` | All collaborators on this repo | Yes (committed to git) |
| **Local** | `.claude/settings.local.json` | You, in this repository only | No (gitignored) |

**Precedence (highest to lowest):** Managed > CLI args > Local > Project > User

Array settings (e.g. `permissions.allow`, `sandbox.filesystem.allowWrite`) **merge** across scopes rather than overriding.

Verify active settings with `/status` inside Claude Code — shows each config layer and its origin.

### Key settings.json fields

| Key | Description | Example |
| :--- | :--- | :--- |
| `permissions.allow` | Tools/patterns to allow without prompting | `["Bash(npm run *)", "Read(~/.zshrc)"]` |
| `permissions.deny` | Tools/patterns to block | `["Bash(curl *)", "Read(./.env)"]` |
| `permissions.ask` | Tools/patterns to always prompt | `["Bash(git push *)"]` |
| `permissions.defaultMode` | Default permission mode | `"acceptEdits"` |
| `permissions.additionalDirectories` | Extra working directories for file access | `["../docs/"]` |
| `model` | Override default model | `"claude-sonnet-4-6"` |
| `env` | Env vars applied every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle hook commands | See hooks-doc |
| `sandbox.enabled` | Enable OS-level Bash isolation | `true` |
| `sandbox.network.allowedDomains` | Domains reachable from sandbox | `["github.com", "*.npmjs.org"]` |
| `autoMode` | Auto mode classifier config (environment/allow/soft_deny) | See auto-mode-config reference |
| `language` | Claude's preferred response language | `"japanese"` |
| `editorMode` | Input prompt key bindings | `"vim"` |
| `tui` | Terminal UI renderer | `"fullscreen"` |
| `autoUpdatesChannel` | Update channel: `"stable"` or `"latest"` | `"stable"` |
| `minimumVersion` | Minimum allowed CLI version | `"2.1.100"` |
| `apiKeyHelper` | Script to generate auth token | `"/bin/generate_temp_api_key.sh"` |
| `attribution` | Git commit/PR attribution text | `{"commit": "...", "pr": ""}` |
| `fileSuggestion` | Custom `@` file autocomplete command | `{"type": "command", "command": "~/.claude/file-suggestion.sh"}` |
| `companyAnnouncements` | Startup messages for users | `["Welcome to Acme Corp!"]` |
| `enabledPlugins` | Plugin enable/disable map | `{"formatter@acme": true}` |
| `extraKnownMarketplaces` | Additional plugin marketplaces for the project | See settings reference |

**Managed-only keys** (ignored in user/project settings):

`allowManagedPermissionRulesOnly`, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowedMcpServers`, `deniedMcpServers`, `strictKnownMarketplaces`, `blockedMarketplaces`, `channelsEnabled`, `allowedChannelPlugins`, `forceRemoteSettingsRefresh`, `pluginTrustMessage`, `sandbox.filesystem.allowManagedReadPathsOnly`, `sandbox.network.allowManagedDomainsOnly`, `wslInheritsWindowsSettings`

### Permission rule syntax

Rules follow the format `Tool` or `Tool(specifier)`. Evaluation order: **deny first, then ask, then allow.** The first match wins.

| Rule | Effect |
| :--- | :--- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Bash(git * main)` | Commands like `git checkout main` |
| `Read(./.env)` | Reading the `.env` file |
| `Read(~/.zshrc)` | Reading from home directory |
| `Edit(/src/**)` | Editing under project-root `src/` |
| `Edit(//tmp/scratch.txt)` | Editing absolute path `/tmp/scratch.txt` |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer` | Any tool from the puppeteer MCP server |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `Agent(Explore)` | The Explore subagent |

**Read/Edit path prefixes:**

| Prefix | Meaning |
| :--- | :--- |
| `//path` | Absolute path from filesystem root |
| `~/path` | Relative to home directory |
| `/path` | Relative to project root |
| `path` or `./path` | Relative to current directory |

**Note:** `Bash(curl http://github.com/ *)` is fragile — it won't match URL variations, options before URL, variables, etc. Prefer `WebFetch(domain:github.com)` + deny rules for `curl`.

Read-only Bash commands (`ls`, `cat`, `grep`, `find`, `git status`, etc.) run without prompting in every mode. This set is not configurable.

### Permission modes

| Mode | What runs without asking | Best for |
| :--- | :--- | :--- |
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads + file edits + common filesystem commands | Iterating on code |
| `plan` | Reads only (no writes/edits) | Exploring a codebase before changing |
| `auto` | Everything, with background classifier checks | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down CI and scripts |
| `bypassPermissions` | Everything except protected paths | Isolated containers/VMs only |

**Switch modes:** `Shift+Tab` cycles default/acceptEdits/plan in CLI. Set `permissions.defaultMode` in settings.json. Pass `--permission-mode` at startup.

**Protected paths** (never auto-approved in any mode): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`), plus `.gitconfig`, `.bashrc`, `.zshrc`, `.mcp.json`, `.claude.json` and similar dotfiles.

**Disable modes in managed settings:**
- `permissions.disableBypassPermissionsMode: "disable"` — blocks `bypassPermissions`
- `permissions.disableAutoMode: "disable"` — blocks auto mode

### Auto mode configuration

Auto mode routes each tool call through a classifier. Configure trusted infrastructure so it stops blocking internal operations:

```json
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp",
      "Trusted cloud buckets: s3://acme-build-artifacts",
      "Trusted internal domains: *.corp.example.com"
    ],
    "soft_deny": [
      "$defaults",
      "Never run database migrations outside the migrations CLI"
    ],
    "allow": [
      "$defaults",
      "Deploying to staging is allowed"
    ]
  }
}
```

Include `"$defaults"` to inherit built-in rules. Omitting it **replaces the entire list** — run `claude auto-mode defaults` to view defaults before doing this.

Auto mode requires: Max/Team/Enterprise/API plan, Anthropic API (not Bedrock/Vertex/Foundry), and Claude Sonnet 4.6+.

Inspect effective config: `claude auto-mode config`. Review denials: `/permissions` > Recently denied tab.

### Managed settings delivery

| Mechanism | Platform | Priority |
| :--- | :--- | :--- |
| Server-managed (Claude.ai admin console) | All | Highest |
| macOS plist (`com.anthropic.claudecode`) | macOS | High |
| Windows HKLM registry (`HKLM\SOFTWARE\Policies\ClaudeCode`) | Windows | High |
| File: macOS `/Library/Application Support/ClaudeCode/managed-settings.json` | macOS | Medium |
| File: Linux/WSL `/etc/claude-code/managed-settings.json` | Linux/WSL | Medium |
| File: Windows `C:\Program Files\ClaudeCode\managed-settings.json` | Windows | Medium |
| Windows HKCU registry | Windows | Lowest managed |

Server-managed settings require Teams/Enterprise plan and refresh hourly. Drop-in directory `managed-settings.d/` supported alongside the base file (sorted alphabetically, merged on top).

**Verify settings:** `/status` shows the active managed source — `(remote)`, `(plist)`, `(HKLM)`, `(HKCU)`, or `(file)`.

### Sandbox settings (key fields)

| Key | Description |
| :--- | :--- |
| `sandbox.enabled` | Enable OS-level isolation for Bash (macOS, Linux, WSL2) |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve Bash when sandboxed (default: true) |
| `sandbox.excludedCommands` | Commands to run outside the sandbox |
| `sandbox.filesystem.allowWrite` | Paths sandboxed commands can write |
| `sandbox.filesystem.denyRead` | Paths sandboxed commands cannot read |
| `sandbox.network.allowedDomains` | Domains reachable from sandbox (supports `*.example.com`) |
| `sandbox.network.deniedDomains` | Domains blocked from sandbox |
| `sandbox.failIfUnavailable` | Exit at startup if sandbox can't start |

Sandbox path prefixes: `/path` = absolute, `~/path` = home-relative, `./path` or no prefix = project/user-relative.

### Worktree settings

| Key | Description |
| :--- | :--- |
| `worktree.symlinkDirectories` | Dirs to symlink into each worktree (e.g. `["node_modules"]`) |
| `worktree.sparsePaths` | Dirs to sparse-checkout in each worktree |

### Attribution settings

| Key | Description |
| :--- | :--- |
| `attribution.commit` | Git commit attribution text (empty string = hide) |
| `attribution.pr` | PR description attribution text (empty string = hide) |

### Global config settings (stored in ~/.claude.json, not settings.json)

| Key | Description |
| :--- | :--- |
| `autoConnectIde` | Auto-connect to IDE when launched from external terminal |
| `autoInstallIdeExtension` | Auto-install IDE extension in VS Code terminal |
| `externalEditorContext` | Prepend previous response when opening external editor |

### Key environment variables

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | API key (overrides subscription login) |
| `ANTHROPIC_MODEL` | Model to use |
| `ANTHROPIC_BASE_URL` | Override API endpoint (proxy/gateway) |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CONFIG_DIR` | Override config directory (default `~/.claude`) |
| `BASH_DEFAULT_TIMEOUT_MS` | Default timeout for Bash commands (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max timeout for Bash commands (default: 600000) |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry metrics/logging (set to `1`) |
| `DISABLE_AUTOUPDATER` | Disable background auto-updates |
| `DISABLE_UPDATES` | Block all updates including manual `claude update` |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Skip writing session transcripts to disk |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess environments |
| `MAX_THINKING_TOKENS` | Override extended thinking budget |
| `CLAUDE_CODE_EFFORT_LEVEL` | Effort level: `low`/`medium`/`high`/`xhigh` |
| `DISABLE_AUTO_COMPACT` | Disable automatic context compaction |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server for network connections |
| `MCP_TIMEOUT` | Timeout for MCP server startup (default: 30000ms) |
| `CLAUDE_CODE_OAUTH_TOKEN` | OAuth access token for automated environments |

Full list of ~150+ variables is in the [environment variables reference](references/claude-code-env-vars.md).

### Enterprise admin decision map

| Decision | Key settings |
| :--- | :--- |
| Permission rules | `permissions.allow`, `permissions.deny` |
| Permission lockdown | `allowManagedPermissionRulesOnly`, `permissions.disableBypassPermissionsMode` |
| Sandboxing | `sandbox.enabled`, `sandbox.network.allowedDomains` |
| MCP server control | `allowedMcpServers`, `deniedMcpServers`, `allowManagedMcpServersOnly` |
| Plugin marketplace control | `strictKnownMarketplaces`, `blockedMarketplaces` |
| Hook restrictions | `allowManagedHooksOnly`, `allowedHttpHookUrls` |
| Version floor | `minimumVersion` |
| Authentication lockdown | `forceLoginMethod`, `forceLoginOrgUUID` |
| Fail-closed startup | `forceRemoteSettingsRefresh: true` |

Starter deployment templates (Jamf, Kandji, Intune, Group Policy): [github.com/anthropics/claude-code/tree/main/examples/mdm](https://github.com/anthropics/claude-code/tree/main/examples/mdm)

Example settings configurations: [github.com/anthropics/claude-code/tree/main/examples/settings](https://github.com/anthropics/claude-code/tree/main/examples/settings)

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — configuration scopes, all settings.json keys, global config, worktree/permission/sandbox/attribution/plugin/hook settings, precedence, and verifying active settings
- [Admin setup guide](references/claude-code-admin-setup.md) — decision map for enterprise deployments: API provider selection, managed settings delivery, enforcement controls, usage visibility, and data handling
- [Configure permissions](references/claude-code-permissions.md) — permission system, rule syntax, tool-specific patterns (Bash/Read/Edit/WebFetch/MCP/Agent), working directories, hooks integration, sandboxing interplay, and managed settings
- [Server-managed settings](references/claude-code-server-managed-settings.md) — server-delivered policy via Claude.ai admin console, delivery/caching behavior, fail-closed enforcement, security approval dialogs, and security considerations
- [Environment variables](references/claude-code-env-vars.md) — complete reference for all environment variables controlling Claude Code behavior
- [Choose a permission mode](references/claude-code-permission-modes.md) — available modes, switching methods (CLI/VS Code/Desktop/web), auto mode details, protected paths, and dontAsk/bypassPermissions usage
- [Configure auto mode](references/claude-code-auto-mode-config.md) — trusted infrastructure setup, overriding block/allow rules with `autoMode.environment`/`allow`/`soft_deny`, CLI inspection commands, and reviewing denials

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Admin setup guide: https://code.claude.com/docs/en/admin-setup.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
