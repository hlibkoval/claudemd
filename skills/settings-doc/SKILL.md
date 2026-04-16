---
name: settings-doc
description: Complete official documentation for Claude Code settings — settings.json hierarchy and scopes, available fields, permission rules and modes, server-managed deployment, and the full environment variable reference.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for configuring Claude Code: the `settings.json` format, permission system, permission modes, server-delivered managed settings, and every environment variable that controls Claude Code behavior.

## Quick Reference

### Configuration scopes and precedence

From highest to lowest precedence. Higher scopes cannot be overridden by lower ones. Array-valued settings merge (concatenate + dedupe) across scopes; scalars follow precedence.

| Scope | Location | Who it affects |
|---|---|---|
| **Managed** | Server-delivered, plist/registry, or `managed-settings.json` | All users on the machine (deployed by IT) |
| **CLI args** | `--permission-mode`, `--allowedTools`, etc. | Single session |
| **Local** | `.claude/settings.local.json` | You, in this repo (gitignored) |
| **Project** | `.claude/settings.json` | All collaborators on the repo |
| **User** | `~/.claude/settings.json` | You, across all projects |

Within the managed tier: server-managed > MDM/OS policies > file-based (`managed-settings.d/*.json` + `managed-settings.json`) > HKCU registry. Sources do not merge across tiers.

Run `/status` to see which sources are active. Run `/config` for a tabbed settings UI.

### Settings file locations

| File | Purpose |
|---|---|
| `~/.claude/settings.json` | User settings |
| `.claude/settings.json` | Project settings (committed) |
| `.claude/settings.local.json` | Project-local overrides (gitignored) |
| `~/.claude.json` | Global config (theme, OAuth, MCP, project state) — not `settings.json` schema |
| `.mcp.json` | Project-scoped MCP servers |
| macOS: `/Library/Application Support/ClaudeCode/managed-settings.json` | File-based managed |
| Linux/WSL: `/etc/claude-code/managed-settings.json` | File-based managed |
| Windows: `C:\Program Files\ClaudeCode\managed-settings.json` | File-based managed (legacy `ProgramData` path removed in v2.1.75) |

Add `"$schema": "https://json.schemastore.org/claude-code-settings.json"` to `settings.json` for editor autocomplete.

### Key top-level settings.json fields

| Field | Purpose |
|---|---|
| `permissions` | `allow`, `ask`, `deny` arrays; `defaultMode`; `additionalDirectories`; `disableBypassPermissionsMode`; `disableAutoMode` |
| `env` | Environment variables applied to every session |
| `hooks` | Lifecycle event commands (see hooks-doc) |
| `sandbox` | OS-level filesystem/network isolation config |
| `autoMode` | Classifier config for auto mode: `environment`, `allow`, `soft_deny` |
| `model` | Override default model (e.g. `claude-sonnet-4-6`) |
| `effortLevel` | `low` / `medium` / `high` — persisted by `/effort` |
| `outputStyle` | System prompt adjustment (e.g. `"Explanatory"`) |
| `statusLine` | Custom status-line command |
| `fileSuggestion` | Custom `@`-autocomplete command |
| `attribution` | Customize `commit` and `pr` git attribution (replaces `includeCoAuthoredBy`) |
| `cleanupPeriodDays` | Session file retention (default 30, min 1) |
| `apiKeyHelper` | Script emitting an auth token for `X-Api-Key` / `Bearer` |
| `autoUpdatesChannel` | `"latest"` (default) or `"stable"` |
| `includeGitInstructions` | Toggle built-in git system prompt |
| `enabledPlugins` / `extraKnownMarketplaces` | Plugin configuration |
| `worktree.symlinkDirectories` / `worktree.sparsePaths` | Reduce worktree disk usage |

### Permission rule syntax

Format: `Tool` or `Tool(specifier)`. Evaluated in order: **deny > ask > allow**. First match wins.

| Rule | Effect |
|---|---|
| `Bash` or `Bash(*)` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Bash(* install)` | Commands ending with ` install` |
| `Bash(git * main)` | `git <anything> main` |
| `Read(./.env)` | Current-dir `.env` |
| `Read(~/.zshrc)` | Home-relative |
| `Edit(//tmp/scratch.txt)` | Absolute (double slash) |
| `Edit(/src/**)` | Project-root-relative (single slash) |
| `WebFetch(domain:example.com)` | Fetches to example.com |
| `mcp__server__tool` | Specific MCP tool |
| `Agent(Explore)` | Block/allow a subagent |

Bash wrappers `timeout`, `time`, `nice`, `nohup`, `stdbuf`, bare `xargs` are stripped before matching. Compound commands (`&&`, `||`, `;`, `|`, newlines) must match each subcommand. Arg-constraining patterns like `Bash(curl http://github.com/*)` are fragile — prefer `WebFetch` allowlist + deny Bash network tools, or use `PreToolUse` hooks.

Read/Edit deny rules only apply to Claude's file tools, not Bash subprocesses. For OS-level enforcement use the sandbox.

### Permission modes

Set via `--permission-mode`, `Shift+Tab` cycle, or `permissions.defaultMode`.

| Mode | Auto-approves | Best for |
|---|---|---|
| `default` | Reads only | Sensitive work, first pass |
| `acceptEdits` | Reads + edits + `mkdir`/`touch`/`rm`/`rmdir`/`mv`/`cp`/`sed` in working dir | Iterating on code you'll review later |
| `plan` | Reads only; no edits/commands | Exploring before changing |
| `auto` | Everything, with classifier safety check | Long tasks (research preview) |
| `dontAsk` | Only pre-approved tools; ask rules deny | Locked-down CI |
| `bypassPermissions` | Everything except protected paths | Isolated containers/VMs |

Auto mode requires Team/Enterprise/API plan, Sonnet 4.6 or Opus 4.6, Anthropic API (not Bedrock/Vertex/Foundry). Enable with `--enable-auto-mode`. Blocks 3x consecutive or 20x total cause fallback to prompts.

**Protected paths** (never auto-approved in any mode): `.git`, `.vscode`, `.idea`, `.husky`, most of `.claude` (except `commands`/`agents`/`skills`/`worktrees`), plus dotfiles like `.gitconfig`, `.bashrc`, `.zshrc`, `.mcp.json`, `.claude.json`.

### Managed-only settings

Only read from managed settings; ignored elsewhere.

| Setting | Effect |
|---|---|
| `allowManagedPermissionRulesOnly` | Only managed `allow`/`ask`/`deny` apply |
| `allowManagedHooksOnly` | Only managed + SDK + force-enabled plugin hooks load |
| `allowManagedMcpServersOnly` | Only managed `allowedMcpServers` apply |
| `allowedMcpServers` / `deniedMcpServers` | MCP allowlist/denylist (deny wins) |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed `allowRead` paths respected |
| `sandbox.network.allowManagedDomainsOnly` | Only managed `allowedDomains` respected |
| `strictKnownMarketplaces` | Plugin marketplace allowlist |
| `blockedMarketplaces` | Plugin marketplace blocklist |
| `forceRemoteSettingsRefresh` | Fail-closed startup if server fetch fails |
| `channelsEnabled` / `allowedChannelPlugins` | Channel message delivery |
| `pluginTrustMessage` | Appended text on plugin trust prompt |

`disableBypassPermissionsMode` and `disableAutoMode` work from any scope but are typically placed in managed settings.

### Server-managed settings

Delivered from Anthropic via the Claude.ai admin console to Team/Enterprise accounts. Requires v2.1.38+ (Teams) or v2.1.30+ (Enterprise) and network access to `api.anthropic.com`. Fetched at startup and polled hourly.

| Behavior | Detail |
|---|---|
| Precedence | Highest tier; checked before endpoint-managed. First non-empty source wins, sources do not merge |
| Caching | Cached settings apply immediately on subsequent launches; fetch happens in the background |
| Fail-closed | Set `forceRemoteSettingsRefresh: true` to block startup until fresh fetch succeeds |
| Security approval | Users approve on first launch when config contains hooks, shell commands, or non-safelisted env vars (skipped in `-p` mode) |
| Not available on | Bedrock, Vertex, Foundry, custom `ANTHROPIC_BASE_URL` |
| Roles | Only Primary Owner and Owner can edit |
| Limits | Organization-wide only (no per-group); MCP servers not distributable |

### Key environment variables

Full list in the reference file. Highlights:

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | Overrides subscription auth |
| `ANTHROPIC_AUTH_TOKEN` | Custom `Authorization: Bearer` value |
| `ANTHROPIC_BASE_URL` | Route API through a proxy/gateway |
| `ANTHROPIC_MODEL` | Default model |
| `ANTHROPIC_BETAS` | Extra `anthropic-beta` headers |
| `CLAUDE_CODE_OAUTH_TOKEN` | Non-interactive OAuth auth |
| `CLAUDE_CODE_USE_BEDROCK` / `_VERTEX` / `_FOUNDRY` | Third-party provider selection |
| `CLAUDE_CODE_EFFORT_LEVEL` | `low`/`medium`/`high`/`max`/`auto` |
| `MAX_THINKING_TOKENS` | Thinking budget (`0` disables) |
| `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` | Required for `MAX_THINKING_TOKENS` to take effect on 4.6 models |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry |
| `DISABLE_TELEMETRY` / `DISABLE_ERROR_REPORTING` / `DISABLE_AUTOUPDATER` | Opt-outs (bundled in `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`) |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude` location |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Ephemeral session (no transcript) |
| `CLAUDE_CODE_SIMPLE` / `--bare` | Minimal system prompt, basic tools only |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip credentials from child processes |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Earlier auto-compaction threshold |
| `API_TIMEOUT_MS` / `BASH_DEFAULT_TIMEOUT_MS` / `BASH_MAX_TIMEOUT_MS` | Timeouts |
| `HTTP_PROXY` / `HTTPS_PROXY` / `NO_PROXY` | Network proxying |
| `CLAUDECODE` | Set to `1` in shells Claude spawns (detect from scripts) |

Env vars can also be set under `env` in `settings.json` to apply to every session.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — Complete `settings.json` reference: scopes, file locations, available settings (including worktree, attribution, file suggestion, hooks, plugins), permission settings, sandbox settings, subagent and plugin configuration.
- [Configure permissions](references/claude-code-permissions.md) — Permission system tiers, `allow`/`ask`/`deny` rules, rule syntax for Bash/Read/Edit/WebFetch/MCP/Agent, wildcard and process-wrapper handling, hook integration, working directories, sandbox interaction, managed-only settings, and the auto mode classifier configuration.
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — Centralized configuration delivered through the Claude.ai admin console: requirements, setup steps, security approval dialogs, caching and fetch behavior, fail-closed startup, platform availability, and audit logging.
- [Environment variables](references/claude-code-env-vars.md) — Complete reference of every env var controlling Claude Code: auth, models, providers, telemetry, proxies, timeouts, plugins, debugging, feature flags, and OpenTelemetry.
- [Choose a permission mode](references/claude-code-permission-modes.md) — Detailed guide to each mode (`default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`), how to switch modes across CLI/VS Code/JetBrains/Desktop/Web, classifier behavior and fallback, and protected paths.

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
