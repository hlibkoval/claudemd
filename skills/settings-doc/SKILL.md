---
name: settings-doc
description: Complete official documentation for Claude Code settings, permissions, permission modes, server-managed settings, and environment variables — configuration scopes, settings.json keys, permission rule syntax, sandbox settings, managed policies, auto mode classifier, and the full env var reference.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, permission modes, server-managed settings, and environment variables.

## Quick Reference

### Configuration scopes

| Scope       | Location                                  | Who it affects               | Shared? |
| :---------- | :---------------------------------------- | :--------------------------- | :------ |
| **Managed** | Server, plist/registry, or file-based     | All users on the machine     | Yes (IT) |
| **User**    | `~/.claude/settings.json`                 | You, across all projects     | No |
| **Project** | `.claude/settings.json`                   | All collaborators            | Yes (git) |
| **Local**   | `.claude/settings.local.json`             | You, in this project only    | No |

Precedence (highest to lowest): **Managed > CLI args > Local > Project > User**. Managed settings cannot be overridden. Array settings merge across scopes (concatenated, deduplicated).

### Settings file locations by feature

| Feature         | User                      | Project                            | Local                          |
| :-------------- | :------------------------ | :--------------------------------- | :----------------------------- |
| **Settings**    | `~/.claude/settings.json` | `.claude/settings.json`            | `.claude/settings.local.json`  |
| **MCP servers** | `~/.claude.json`          | `.mcp.json`                        | `~/.claude.json` (per-project) |
| **CLAUDE.md**   | `~/.claude/CLAUDE.md`     | `CLAUDE.md` or `.claude/CLAUDE.md` | `CLAUDE.local.md`              |
| **Subagents**   | `~/.claude/agents/`       | `.claude/agents/`                  | None                           |

### Key settings.json fields

| Key | Purpose |
| :-- | :------ |
| `permissions` | `allow`, `ask`, `deny` arrays plus `defaultMode`, `additionalDirectories` |
| `hooks` | Lifecycle hooks (PreToolUse, PostToolUse, SessionStart, etc.) |
| `env` | Environment variables applied to every session |
| `model` | Override default model (e.g., `"claude-sonnet-4-6"`) |
| `sandbox` | Enable OS-level filesystem + network isolation for Bash |
| `enabledPlugins` | Enable/disable plugins (`"name@marketplace": true`) |
| `extraKnownMarketplaces` | Add plugin marketplaces for team use |
| `autoMode` | Configure the auto mode classifier (`environment`, `allow`, `soft_deny`) |
| `attribution` | Customize git commit and PR attribution text |
| `companyAnnouncements` | Messages displayed to users at startup |
| `language` | Preferred response language (e.g., `"japanese"`) |
| `outputStyle` | Adjust system prompt output style |
| `tui` | `"fullscreen"` for alt-screen renderer, `"default"` for classic |
| `statusLine` | Custom status line command |
| `fileSuggestion` | Custom `@` file autocomplete command |

### Managed-only settings

These keys are only read from managed settings (no effect in user/project):

`allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowManagedPermissionRulesOnly`, `blockedMarketplaces`, `channelsEnabled`, `allowedChannelPlugins`, `forceRemoteSettingsRefresh`, `pluginTrustMessage`, `sandbox.filesystem.allowManagedReadPathsOnly`, `sandbox.network.allowManagedDomainsOnly`, `strictKnownMarketplaces`

### Managed settings delivery mechanisms

| Mechanism | Platform |
| :-------- | :------- |
| **Server-managed** | Claude.ai admin console (Teams/Enterprise) |
| **MDM (plist)** | macOS via `com.anthropic.claudecode` domain |
| **MDM (registry)** | Windows via `HKLM\SOFTWARE\Policies\ClaudeCode` |
| **File-based** | macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`; Linux/WSL: `/etc/claude-code/managed-settings.json`; Windows: `C:\Program Files\ClaudeCode\managed-settings.json` |

Drop-in directory: `managed-settings.d/*.json` alongside the base file; merged alphabetically on top.

### Permission system

Rules evaluated in order: **deny > ask > allow**. First match wins.

| Rule format | Effect |
| :---------- | :----- |
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run` |
| `Read(./.env)` | Matches reading `.env` |
| `Edit(/src/**/*.ts)` | Matches edits under project `src/` |
| `WebFetch(domain:example.com)` | Matches fetch to example.com |
| `mcp__server__tool` | Matches specific MCP tool |
| `Agent(Explore)` | Matches the Explore subagent |

Path prefixes for Read/Edit rules: `//path` = absolute, `~/path` = home, `/path` = project root, `./path` or bare `path` = cwd-relative. `*` matches one directory level, `**` matches recursively.

Bash patterns: space before `*` enforces word boundary (`Bash(ls *)` matches `ls -la` but not `lsof`). Claude Code strips process wrappers (`timeout`, `time`, `nice`, `nohup`, `stdbuf`) before matching. Compound commands are matched per-subcommand.

Read-only Bash commands that run without prompts: `ls`, `cat`, `head`, `tail`, `grep`, `find`, `wc`, `diff`, `stat`, `du`, `cd`, and read-only `git` forms.

### Permission modes

| Mode | Auto-approved | Best for |
| :--- | :------------ | :------- |
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, `mkdir`/`touch`/`rm`/`mv`/`cp`/`sed` | Code iteration |
| `plan` | Reads only (no edits allowed) | Codebase exploration |
| `auto` | Everything (with classifier safety checks) | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down CI/scripts |
| `bypassPermissions` | Everything except protected paths | Isolated containers/VMs only |

Switch modes: `Shift+Tab` in CLI, mode indicator in VS Code, `--permission-mode <mode>` at startup, or `defaultMode` in settings. Admins can block `auto` via `disableAutoMode` or `bypassPermissions` via `disableBypassPermissionsMode`.

Protected paths (never auto-approved): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`), plus `.gitconfig`, `.gitmodules`, shell rc files, `.mcp.json`, `.claude.json`.

### Auto mode classifier

Requires: Max/Team/Enterprise/API plan, Claude Sonnet 4.6+ or Opus 4.6+, Anthropic API only.

Configure trusted infrastructure via `autoMode.environment` in user, local, or managed settings (not shared project settings):

```json
{
  "autoMode": {
    "environment": [
      "Source control: github.example.com/acme-corp",
      "Trusted cloud buckets: s3://acme-builds",
      "Trusted internal domains: *.corp.example.com"
    ]
  }
}
```

CLI inspection: `claude auto-mode defaults`, `claude auto-mode config`, `claude auto-mode critique`.

Setting `allow` or `soft_deny` replaces the entire default list -- always copy defaults first with `claude auto-mode defaults`.

### Sandbox settings

| Key | Purpose |
| :-- | :------ |
| `sandbox.enabled` | Enable sandboxing |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed (default: true) |
| `sandbox.excludedCommands` | Commands to run outside sandbox |
| `sandbox.filesystem.allowWrite` | Additional writable paths |
| `sandbox.filesystem.denyRead` | Blocked read paths |
| `sandbox.network.allowedDomains` | Outbound domain allowlist |
| `sandbox.network.allowLocalBinding` | Allow localhost port binding (macOS) |

Sandbox path prefixes: `/path` = absolute, `~/path` = home, `./path` or bare = project root (project settings) or `~/.claude` (user settings).

### Key environment variables

| Variable | Purpose |
| :------- | :------ |
| `ANTHROPIC_API_KEY` | API key (overrides subscription) |
| `ANTHROPIC_BASE_URL` | Override API endpoint |
| `ANTHROPIC_MODEL` | Model to use |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_DISABLE_CLAUDE_MDS` | Skip loading CLAUDE.md files |
| `CLAUDE_CODE_SIMPLE` | Minimal system prompt, basic tools only |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen rendering |
| `CLAUDE_CONFIG_DIR` | Override config directory (default: `~/.claude`) |
| `DISABLE_TELEMETRY` | Opt out of Statsig telemetry |
| `DISABLE_AUTOUPDATER` | Disable auto-updates |
| `DISABLE_AUTO_COMPACT` | Disable auto-compaction |
| `MAX_THINKING_TOKENS` | Override thinking token budget |
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash timeout (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Max bash timeout (default: 600000) |
| `API_TIMEOUT_MS` | API request timeout (default: 600000) |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy configuration |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from subprocess environments |

Any env var can also be set in `settings.json` under the `env` key.

### Server-managed settings

- Available for Teams and Enterprise plans
- Configured in Claude.ai Admin Settings > Claude Code > Managed settings
- Clients fetch at startup and poll hourly
- Cached settings apply immediately on subsequent launches
- `forceRemoteSettingsRefresh: true` blocks startup until fresh fetch succeeds
- Shell commands, custom env vars, and hooks in managed settings require user security approval dialog (skipped in `-p` non-interactive mode)
- Not available with Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`
- Within managed tier: server-managed > MDM/plist/registry > file-based; only one source used (no cross-tier merge)

### Verify active settings

Run `/status` inside Claude Code to see which settings sources are active and where they come from. Run `/permissions` to view all permission rules and their origins.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) -- Configuration scopes, settings.json format, all available settings keys (model, permissions, hooks, env, sandbox, plugins, attribution, worktree, etc.), global config settings (~/.claude.json), permission rule syntax, sandbox configuration, settings precedence, and plugin marketplace configuration.
- [Configure permissions](references/claude-code-permissions.md) -- Permission system tiers, managing allow/ask/deny rules, permission modes overview, complete rule syntax for Bash, Read, Edit, WebFetch, MCP, and Agent tools, working directories, hooks for permission evaluation, auto mode classifier configuration, managed-only settings, and how permissions interact with sandboxing.
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) -- Server-managed vs endpoint-managed settings, admin console setup, settings delivery and caching, fail-closed enforcement, security approval dialogs, platform availability, and audit logging.
- [Environment variables](references/claude-code-env-vars.md) -- Complete reference of all environment variables controlling Claude Code behavior: API keys, model selection, provider routing (Bedrock/Vertex/Foundry), telemetry, sandbox, proxy, thinking tokens, MCP, prompt caching, and many more.
- [Choose a permission mode](references/claude-code-permission-modes.md) -- Detailed guide to each permission mode (default, acceptEdits, plan, auto, dontAsk, bypassPermissions), how to switch modes, auto mode requirements and classifier behavior, protected paths, and mode-specific auto-approvals.

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
