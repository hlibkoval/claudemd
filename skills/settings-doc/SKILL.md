---
name: settings-doc
description: Complete official documentation for Claude Code settings — settings.json, permissions, permission modes, server-managed settings, environment variables, sandbox configuration, and managed policies.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, permission modes, and environment variables.

## Quick Reference

### Configuration scopes

Settings are resolved top-down; the first match wins. Managed settings cannot be overridden.

| Scope       | Location                                                              | Shared?                |
| :---------- | :-------------------------------------------------------------------- | :--------------------- |
| **Managed** | Server-managed, plist/registry, or `managed-settings.json`           | Yes (deployed by IT)   |
| **CLI args** | `--permission-mode`, `--model`, etc.                                 | No (session only)      |
| **Local**   | `.claude/settings.local.json`                                        | No (gitignored)        |
| **Project** | `.claude/settings.json`                                              | Yes (committed)        |
| **User**    | `~/.claude/settings.json`                                            | No (personal global)   |

Array-valued settings (like `permissions.allow`, `sandbox.filesystem.allowWrite`) **merge** across scopes rather than replacing.

### Settings files locations

| Feature          | User                      | Project                            | Local                          |
| :--------------- | :------------------------ | :--------------------------------- | :----------------------------- |
| **Settings**     | `~/.claude/settings.json` | `.claude/settings.json`            | `.claude/settings.local.json`  |
| **MCP servers**  | `~/.claude.json`          | `.mcp.json`                        | `~/.claude.json` (per-project) |
| **CLAUDE.md**    | `~/.claude/CLAUDE.md`     | `CLAUDE.md` or `.claude/CLAUDE.md` | `CLAUDE.local.md`              |
| **Subagents**    | `~/.claude/agents/`       | `.claude/agents/`                  | None                           |
| **Plugins**      | `~/.claude/settings.json` | `.claude/settings.json`            | `.claude/settings.local.json`  |

### Managed settings file locations

| Platform    | Path                                               |
| :---------- | :------------------------------------------------- |
| **macOS**   | `/Library/Application Support/ClaudeCode/`         |
| **Linux/WSL** | `/etc/claude-code/`                              |
| **Windows** | `C:\Program Files\ClaudeCode\`                     |

Managed settings also support a `managed-settings.d/` drop-in directory (files sorted alphabetically, merged on top of `managed-settings.json`).

### Key settings.json fields

| Key                         | Description                                                              |
| :-------------------------- | :----------------------------------------------------------------------- |
| `permissions`               | `allow`, `ask`, `deny` arrays plus `defaultMode`, `additionalDirectories` |
| `env`                       | Environment variables applied to every session                           |
| `hooks`                     | Lifecycle hooks (PreToolUse, PostToolUse, etc.)                          |
| `model`                     | Override default model                                                   |
| `sandbox`                   | Bash sandboxing: filesystem and network restrictions                     |
| `agent`                     | Run main thread as a named subagent                                      |
| `attribution`               | Customize git commit/PR attribution text                                 |
| `autoMode`                  | Configure auto mode classifier (environment, allow, soft_deny)           |
| `enabledPlugins`            | Enable/disable plugins (`"name@marketplace": true`)                      |
| `extraKnownMarketplaces`   | Additional plugin marketplace sources                                    |
| `strictKnownMarketplaces`  | (Managed only) Allowlist of marketplaces users can add                   |
| `companyAnnouncements`      | Startup announcements for users                                          |
| `language`                  | Preferred response language                                              |
| `availableModels`           | Restrict which models users can select                                   |
| `tui`                       | `"fullscreen"` for alt-screen renderer or `"default"`                    |
| `effortLevel`               | Persist effort level: `"low"`, `"medium"`, `"high"`, `"xhigh"`          |
| `outputStyle`               | Custom output style                                                      |

Use `$schema: "https://json.schemastore.org/claude-code-settings.json"` for IDE autocomplete.

### Permission rule syntax

Rules follow the format `Tool` or `Tool(specifier)`. Evaluated in order: **deny first, then ask, then allow**. First match wins.

| Rule                            | Effect                                    |
| :------------------------------ | :---------------------------------------- |
| `Bash`                          | Matches all Bash commands                 |
| `Bash(npm run *)`               | Matches commands starting with `npm run`  |
| `Read(./.env)`                  | Matches reading `.env` in project root    |
| `Edit(/src/**/*.ts)`            | Matches editing TS files under `src/`     |
| `WebFetch(domain:example.com)`  | Matches fetch requests to example.com     |
| `mcp__puppeteer__*`             | Matches all tools from puppeteer server   |
| `Agent(Explore)`                | Matches the Explore subagent              |

**Wildcard rules**: `*` matches any sequence of characters including spaces. `Bash(ls *)` (space before `*`) enforces a word boundary; `Bash(ls*)` does not. Compound commands are matched per-subcommand.

**Read/Edit path prefixes**:

| Prefix   | Meaning                          | Example                               |
| :------- | :------------------------------- | :------------------------------------ |
| `//`     | Absolute path from fs root       | `Read(//Users/alice/secrets/**)`      |
| `~/`     | Relative to home directory       | `Read(~/Documents/*.pdf)`             |
| `/`      | Relative to project root         | `Edit(/src/**/*.ts)`                  |
| `./`     | Relative to current directory    | `Read(./*.env)`                       |

### Permission modes

| Mode                | Auto-approved actions                                          | Best for                        |
| :------------------ | :------------------------------------------------------------- | :------------------------------ |
| `default`           | Reads only                                                     | Getting started, sensitive work |
| `acceptEdits`       | Reads, file edits, filesystem commands (mkdir, touch, mv, etc.) | Iterating on code you review    |
| `plan`              | Reads only (Claude proposes but does not edit)                 | Exploring before changing       |
| `auto`              | Everything, with background classifier safety checks           | Long tasks, reducing prompts    |
| `dontAsk`           | Only pre-approved tools                                        | Locked-down CI and scripts      |
| `bypassPermissions` | Everything except protected paths                              | Isolated containers/VMs only    |

Switch modes: `Shift+Tab` in CLI, mode selector in VS Code/Desktop, `--permission-mode <mode>` at startup, or `defaultMode` in settings.

**Protected paths** (never auto-approved in any mode): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`), plus `.gitconfig`, `.bashrc`, `.zshrc`, `.mcp.json`, etc.

### Auto mode

Requires: Max/Team/Enterprise/API plan, Sonnet 4.6+/Opus 4.6+/Opus 4.7, Anthropic API only. Admin must enable on Team/Enterprise.

Configure trusted infrastructure via `autoMode.environment` in user, local, or managed settings (not shared project settings):

```json
{
  "autoMode": {
    "environment": [
      "Source control: github.example.com/acme-corp",
      "Trusted cloud buckets: s3://acme-build-artifacts",
      "Trusted internal domains: *.corp.example.com"
    ]
  }
}
```

Inspect defaults: `claude auto-mode defaults` | `claude auto-mode config` | `claude auto-mode critique`.

Setting `allow` or `soft_deny` **replaces** the entire default list for that section. Always copy defaults first with `claude auto-mode defaults`.

### Sandbox settings

Enable with `sandbox.enabled: true`. Key sub-keys:

| Key                                | Description                                                        |
| :--------------------------------- | :----------------------------------------------------------------- |
| `enabled`                          | Enable bash sandboxing                                             |
| `autoAllowBashIfSandboxed`         | Auto-approve bash when sandboxed (default: true)                   |
| `excludedCommands`                 | Commands that run outside sandbox                                  |
| `filesystem.allowWrite`            | Additional writable paths                                          |
| `filesystem.denyWrite`             | Paths blocked from writing                                         |
| `filesystem.denyRead`              | Paths blocked from reading                                         |
| `filesystem.allowRead`             | Re-allow reading within denyRead regions                           |
| `network.allowedDomains`           | Domains allowed for outbound traffic                               |
| `network.deniedDomains`            | Domains blocked (takes precedence over allowedDomains)             |
| `network.allowLocalBinding`        | Allow binding to localhost ports (macOS only)                      |

Sandbox path prefixes: `/` = absolute, `~/` = home-relative, `./` or bare = project-relative.

### Managed-only settings

These keys are only effective in managed settings:

| Key                                     | Purpose                                                      |
| :-------------------------------------- | :----------------------------------------------------------- |
| `allowManagedPermissionRulesOnly`       | Block user/project permission rules                          |
| `allowManagedHooksOnly`                 | Only managed/SDK/force-enabled plugin hooks                  |
| `allowManagedMcpServersOnly`            | Only managed MCP server allowlist applies                    |
| `strictKnownMarketplaces`              | Allowlist of plugin marketplaces                             |
| `blockedMarketplaces`                   | Blocklist of marketplace sources                             |
| `channelsEnabled`                       | Enable channels for Team/Enterprise                          |
| `allowedChannelPlugins`                 | Allowlist of channel plugins                                 |
| `forceRemoteSettingsRefresh`            | Block startup until remote settings fetched                  |
| `pluginTrustMessage`                    | Custom plugin trust warning text                             |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Only managed allowRead paths apply                    |
| `sandbox.network.allowManagedDomainsOnly`      | Only managed allowedDomains apply                     |

### Server-managed settings

- Configured at **Admin Settings > Claude Code > Managed settings** on claude.ai
- Requires Team or Enterprise plan, Claude Code v2.1.30+
- Fetched at startup, polled hourly
- Highest precedence within managed tier (server > MDM > file-based)
- Not available with Bedrock, Vertex, Foundry, or custom `ANTHROPIC_BASE_URL`

Use `forceRemoteSettingsRefresh: true` for fail-closed enforcement (CLI exits if fetch fails).

### Key environment variables

| Variable                              | Purpose                                                       |
| :------------------------------------ | :------------------------------------------------------------ |
| `ANTHROPIC_API_KEY`                   | API key (overrides subscription)                              |
| `ANTHROPIC_BASE_URL`                  | Override API endpoint (proxy/gateway)                         |
| `ANTHROPIC_MODEL`                     | Override model selection                                      |
| `CLAUDE_CODE_USE_BEDROCK`             | Use Amazon Bedrock                                            |
| `CLAUDE_CODE_USE_VERTEX`              | Use Google Vertex AI                                          |
| `CLAUDE_CODE_USE_FOUNDRY`             | Use Microsoft Foundry                                         |
| `CLAUDE_CODE_ENABLE_TELEMETRY`        | Enable OpenTelemetry collection                               |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable autoupdater, telemetry, error reporting          |
| `CLAUDE_CODE_DISABLE_THINKING`        | Force-disable extended thinking                               |
| `DISABLE_AUTO_COMPACT`                | Disable automatic context compaction                          |
| `DISABLE_TELEMETRY`                   | Opt out of Statsig telemetry                                  |
| `MAX_THINKING_TOKENS`                 | Override thinking token budget                                |
| `BASH_DEFAULT_TIMEOUT_MS`             | Default bash command timeout (default: 120000)                |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS`       | Max output tokens per request                                 |
| `HTTP_PROXY` / `HTTPS_PROXY`         | Proxy server configuration                                    |
| `CLAUDE_CONFIG_DIR`                   | Override config directory (default: `~/.claude`)              |

Set env vars in the shell or in `settings.json` under the `env` key to apply to every session.

### Useful commands

| Command         | Purpose                                     |
| :-------------- | :------------------------------------------ |
| `/config`       | Open settings UI                            |
| `/permissions`  | View and manage permission rules            |
| `/status`       | See active settings sources and diagnostics |
| `/model`        | Switch model                                |
| `/effort`       | Set effort level                            |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code settings](references/claude-code-settings.md) — configuration scopes, settings.json fields (full table of all keys), settings precedence, sandbox settings, attribution, file suggestion, hook configuration, plugin and marketplace settings, worktree settings, and subagent/plugin configuration.
- [Configure permissions](references/claude-code-permissions.md) — permission system, rule syntax (Bash, Read, Edit, WebFetch, MCP, Agent), wildcard behavior, compound commands, process wrappers, read-only commands, working directories, hooks for permission evaluation, managed-only settings, auto mode classifier configuration, and example configurations.
- [Configure server-managed settings](references/claude-code-server-managed-settings.md) — server-delivered settings for Teams/Enterprise, admin console setup, settings delivery and caching, fail-closed enforcement, security approval dialogs, access control, platform availability, and security considerations.
- [Environment variables](references/claude-code-env-vars.md) — complete reference of all environment variables controlling Claude Code behavior, including API keys, model selection, provider configuration, telemetry, sandboxing, UI, timeouts, and OpenTelemetry exporter variables.
- [Choose a permission mode](references/claude-code-permission-modes.md) — available permission modes (default, acceptEdits, plan, auto, dontAsk, bypassPermissions), how to switch modes across CLI/VS Code/JetBrains/Desktop/Web, auto mode classifier details, protected paths, and fallback behavior.

## Sources

- Claude Code settings: https://code.claude.com/docs/en/settings.md
- Configure permissions: https://code.claude.com/docs/en/permissions.md
- Configure server-managed settings: https://code.claude.com/docs/en/server-managed-settings.md
- Environment variables: https://code.claude.com/docs/en/env-vars.md
- Choose a permission mode: https://code.claude.com/docs/en/permission-modes.md
