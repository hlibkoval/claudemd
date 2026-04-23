---
name: settings-doc
description: Complete official documentation for Claude Code settings, permissions, environment variables, and permission modes — configuration scopes, settings.json keys, permission rule syntax, sandbox settings, auto mode, server-managed settings, and all environment variables.
user-invocable: false
---

# Settings & Permissions Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, permission modes, environment variables, auto mode configuration, and server-managed settings.

## Quick Reference

### Configuration scopes

| Scope | Location | Shared? |
| :---- | :------- | :------ |
| **Managed** | Server-delivered, plist/registry, or `managed-settings.json` | Yes (IT-deployed, highest priority) |
| **User** | `~/.claude/settings.json` | No (personal, all projects) |
| **Project** | `.claude/settings.json` | Yes (committed to git) |
| **Local** | `.claude/settings.local.json` | No (gitignored, this repo only) |

Precedence (highest to lowest): Managed > CLI args > Local > Project > User. Array-valued settings (like `permissions.allow`) are **concatenated** across scopes, not replaced.

### Key settings.json fields

| Key | Description | Example |
| :-- | :---------- | :------ |
| `permissions.allow` | Rules to allow tool use without prompt | `["Bash(npm run *)"]` |
| `permissions.deny` | Rules to deny tool use | `["Read(./.env)"]` |
| `permissions.ask` | Rules to always prompt for | `["Bash(git push *)"]` |
| `permissions.defaultMode` | Default permission mode | `"acceptEdits"` |
| `permissions.additionalDirectories` | Extra working directories | `["../docs/"]` |
| `permissions.disableBypassPermissionsMode` | Block bypass mode | `"disable"` |
| `model` | Override model | `"claude-sonnet-4-6"` |
| `env` | Env vars applied every session | `{"FOO": "bar"}` |
| `hooks` | Lifecycle hooks configuration | See hooks-doc |
| `sandbox.enabled` | Enable bash sandboxing | `true` |
| `autoMode` | Auto mode classifier config | `{"environment": [...]}` |
| `enabledPlugins` | Enable/disable plugins by name | `{"tool@market": true}` |
| `extraKnownMarketplaces` | Add plugin marketplaces | `{"name": {"source": {...}}}` |
| `language` | Claude's response language | `"japanese"` |
| `apiKeyHelper` | Script to generate auth token | `"/bin/gen-key.sh"` |
| `cleanupPeriodDays` | Days before session files deleted (default 30) | `20` |
| `companyAnnouncements` | Startup messages for users | `["Welcome to Acme!"]` |
| `includeGitInstructions` | Include git workflow in system prompt | `false` |
| `autoUpdatesChannel` | Update channel: `"stable"` or `"latest"` | `"stable"` |
| `minimumVersion` | Floor version for auto-updates | `"2.1.100"` |
| `effortLevel` | Persist effort level across sessions | `"xhigh"` |
| `tui` | Terminal renderer: `"fullscreen"` or `"default"` | `"fullscreen"` |

**JSON schema for autocomplete:**
```json
{ "$schema": "https://json.schemastore.org/claude-code-settings.json" }
```

### Permission modes

| Mode | What auto-approves | Best for |
| :--- | :----------------- | :------- |
| `default` | Reads only | Sensitive work, getting started |
| `acceptEdits` | Reads, file edits, common fs commands (`mkdir`, `mv`, etc.) | Iterating on code |
| `plan` | Reads only (no writes/commands) | Exploring before editing |
| `auto` | Everything with classifier safety checks | Long tasks, reducing fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down CI |
| `bypassPermissions` | Everything except protected paths | Isolated containers/VMs only |

Switch modes mid-session with `Shift+Tab` (CLI) or at startup with `--permission-mode <mode>`.

**Protected paths** (always prompt regardless of mode): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`), `.gitconfig`, `.gitmodules`, `.bashrc`, `.zshrc`, `.mcp.json`, `.claude.json`.

Disable modes in managed settings:
```json
{
  "permissions": {
    "disableBypassPermissionsMode": "disable"
  },
  "disableAutoMode": "disable"
}
```

### Permission rule syntax

Rules format: `Tool` or `Tool(specifier)`. Evaluation order: **deny → ask → allow** (first match wins).

| Rule | Effect |
| :--- | :----- |
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Bash(git * main)` | git commands ending in `main` |
| `Read(./.env)` | Reading `.env` in current dir |
| `Read(~/Documents/*.pdf)` | Reading from home dir |
| `Edit(/src/**)` | Edits under project-root `/src/` |
| `Edit(//tmp/scratch.txt)` | Absolute path edit |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |
| `mcp__puppeteer` | Any tool from puppeteer MCP server |
| `Agent(Explore)` | The Explore subagent |

**Bash wildcard notes:** `*` matches any chars including spaces. `Bash(ls *)` enforces a word boundary (matches `ls -la` but not `lsof`). Shell operators (`&&`, `||`, `;`, `|`) are understood — a rule must match each sub-command independently. Process wrappers `timeout`, `time`, `nice`, `nohup`, `stdbuf`, and bare `xargs` are stripped before matching.

**Read/Edit path prefixes:**
- `//path` — absolute from filesystem root
- `~/path` — relative to home directory
- `/path` — relative to project root
- `path` or `./path` — relative to current directory

### Sandbox settings

Configure under `"sandbox": {}` in settings.json:

| Key | Description |
| :-- | :---------- |
| `enabled` | Enable bash sandboxing (macOS, Linux, WSL2) |
| `autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `excludedCommands` | Commands that run outside the sandbox |
| `filesystem.allowWrite` | Paths sandboxed commands can write |
| `filesystem.denyWrite` | Paths sandboxed commands cannot write |
| `filesystem.denyRead` | Paths sandboxed commands cannot read |
| `filesystem.allowRead` | Re-allow reading within denyRead regions |
| `network.allowedDomains` | Domains to allow (supports wildcards) |
| `network.deniedDomains` | Domains to block (takes precedence over allowed) |
| `network.allowUnixSockets` | Unix socket paths (macOS only) |
| `network.allowLocalBinding` | Allow binding to localhost ports (macOS only) |

Sandbox path prefix conventions: `/tmp/build` = absolute, `~/path` = home-relative, `./path` = project-relative.

### Auto mode configuration

Auto mode routes tool calls through a classifier. Configure trusted infrastructure so it stops blocking internal operations:

```json
{
  "autoMode": {
    "environment": [
      "Source control: github.example.com/acme-corp and all repos under it",
      "Trusted buckets: s3://acme-build-artifacts",
      "Trusted domains: *.corp.example.com"
    ]
  }
}
```

**Important:** Setting `environment`, `allow`, or `soft_deny` **replaces** (not extends) that section's defaults. Run `claude auto-mode defaults` to get the defaults before editing, then copy and modify them. Run `claude auto-mode config` to verify effective rules.

The `autoMode` block is **not read from shared project settings** (`.claude/settings.json`) to prevent a checked-in repo from injecting allow rules. Use user settings, local settings, or managed settings.

### Managed-only settings

These keys only take effect in managed settings (ignored in user/project settings):

| Setting | Effect |
| :------ | :----- |
| `allowManagedPermissionRulesOnly` | Block user/project allow/ask/deny rules |
| `allowManagedHooksOnly` | Block non-managed hooks |
| `allowManagedMcpServersOnly` | Only managed MCP servers apply |
| `allowedMcpServers` / `deniedMcpServers` | MCP server allowlist/denylist |
| `strictKnownMarketplaces` | Restrict which plugin marketplaces users can add |
| `blockedMarketplaces` | Block specific marketplace sources |
| `channelsEnabled` | Allow channels for Team/Enterprise users |
| `allowedChannelPlugins` | Allowlist of channel plugins |
| `forceRemoteSettingsRefresh` | Block startup until remote settings fetched |
| `pluginTrustMessage` | Custom plugin trust warning message |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed allowRead paths apply |
| `sandbox.network.allowManagedDomainsOnly` | Only managed allowedDomains apply |

### Server-managed settings

For Teams/Enterprise: configure via **Admin Settings > Claude Code > Managed settings** in Claude.ai. Requires Claude Code v2.1.38+ (Teams) or v2.1.30+ (Enterprise). Settings are fetched at startup and polled hourly.

**Precedence within managed tier:** server-managed > MDM/OS-level > file-based (`managed-settings.d/*.json` merged into `managed-settings.json`) > HKCU registry. Only one managed source is used per tier.

**File-based managed settings locations:**
- macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`
- Linux/WSL: `/etc/claude-code/managed-settings.json`
- Windows: `C:\Program Files\ClaudeCode\managed-settings.json`

Drop-in directory `managed-settings.d/` merges alphabetically on top of `managed-settings.json`. Use numeric prefixes (`10-telemetry.json`) to control order.

**Fail-closed startup:**
```json
{ "forceRemoteSettingsRefresh": true }
```
Blocks CLI startup until settings are freshly fetched; exits if fetch fails.

### Plugin settings

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

Marketplace source types: `github` (uses `repo`), `git` (uses `url`), `url` (uses `url`), `npm` (uses `package`), `file` (uses `path`), `directory` (uses `path`), `settings` (inline), `hostPattern` (regex).

### Global config settings (~/.claude.json only)

These appear in `/config` but must NOT go in `settings.json`:

| Key | Description |
| :-- | :---------- |
| `editorMode` | Input binding: `"normal"` or `"vim"` |
| `autoConnectIde` | Auto-connect to IDE on external terminal |
| `autoInstallIdeExtension` | Auto-install IDE extension (default: true) |
| `autoScrollEnabled` | Follow new output in fullscreen mode |
| `showTurnDuration` | Show turn duration after responses |
| `teammateMode` | Agent team display: `"auto"`, `"in-process"`, `"tmux"` |

### Worktree settings

| Key | Description |
| :-- | :---------- |
| `worktree.symlinkDirectories` | Dirs to symlink into each worktree (e.g. `["node_modules"]`) |
| `worktree.sparsePaths` | Dirs for sparse checkout in each worktree |

### Attribution settings

```json
{
  "attribution": {
    "commit": "Generated with AI\n\nCo-Authored-By: AI <ai@example.com>",
    "pr": ""
  }
}
```

Empty string for `commit` or `pr` hides attribution. Supersedes the deprecated `includeCoAuthoredBy`.

### Key environment variables (selected)

| Variable | Purpose |
| :------- | :------ |
| `ANTHROPIC_API_KEY` | API key (overrides subscription in interactive mode after approval) |
| `ANTHROPIC_BASE_URL` | Override API endpoint (proxy/gateway) |
| `ANTHROPIC_MODEL` | Override model |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout model can set (default: 600000) |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry (`1`) |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable autoupdater, feedback, error reporting, telemetry |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess environments |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Skip writing session transcripts to disk |
| `CLAUDE_CODE_SIMPLE` | Minimal system prompt, basic tools only |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `CLAUDE_CODE_USE_BEDROCK` / `_VERTEX` / `_FOUNDRY` | Use third-party provider |
| `DISABLE_AUTOUPDATER` | Disable auto-updates |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching (all models) |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max`, `auto` |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server for network connections |
| `CLAUDECODE` | Set to `1` in shells Claude Code spawns (detect from scripts) |

See [full env vars reference](references/claude-code-env-vars.md) for the complete list.

### Verify active settings

Run `/status` inside Claude Code to see which settings sources are active and where each comes from (remote, plist, HKLM, HKCU, or file).

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — configuration scopes, settings files, all settings.json keys, permission settings, sandbox settings, attribution, plugin configuration, and environment variables overview
- [Configure permissions](references/claude-code-permissions.md) — permission system, rule syntax, tool-specific patterns (Bash, Read, Edit, WebFetch, MCP, Agent), working directories, sandboxing interaction, managed settings
- [Choose a permission mode](references/claude-code-permission-modes.md) — all modes (default, acceptEdits, plan, auto, dontAsk, bypassPermissions), switching modes, protected paths, auto mode details
- [Configure auto mode](references/claude-code-auto-mode-config.md) — autoMode settings block, defining trusted infrastructure, overriding block/allow rules, CLI inspection subcommands
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — server delivery vs endpoint delivery, admin console setup, fetch/caching behavior, security approval dialogs, fail-closed enforcement
- [Environment variables](references/claude-code-env-vars.md) — complete reference for all environment variables controlling Claude Code behavior

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
- Configure auto mode: https://code.claude.com/docs/en/auto-mode-config.md
