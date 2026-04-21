---
name: plugins-doc
description: Complete official documentation for Claude Code plugins — creating plugins, the plugin manifest schema, component reference (skills, agents, hooks, MCP/LSP servers, monitors), discovering and installing plugins, creating and distributing marketplaces, plugin dependency version constraints, CLI commands, and debugging.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

Plugins are self-contained directories that extend Claude Code with skills, agents, hooks, MCP servers, LSP servers, monitors, and executables. They can be shared via marketplaces and installed across projects and teams.

### Standalone vs plugin

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` dir) | `/hello` | Personal, per-project, quick experiments |
| **Plugin** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing, multi-project reuse, distribution |

### Minimal plugin structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json        ← manifest (name is required)
├── skills/
│   └── my-skill/
│       └── SKILL.md
├── agents/                ← optional
├── hooks/hooks.json       ← optional
├── .mcp.json              ← optional
├── .lsp.json              ← optional
├── monitors/monitors.json ← optional
├── bin/                   ← executables added to PATH
└── settings.json          ← optional default settings
```

Only `plugin.json` goes inside `.claude-plugin/`. All other directories belong at the plugin root.

### Test locally

```bash
claude --plugin-dir ./my-plugin
# Multiple plugins:
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

Run `/reload-plugins` inside a session to pick up changes without restarting.

### plugin.json manifest schema

Required field: `name` (kebab-case, no spaces). All others optional.

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Plugin identifier and skill namespace (e.g. skills appear as `/name:skill`) |
| `version` | string | Semantic version (`MAJOR.MINOR.PATCH`) |
| `description` | string | Shown in plugin manager |
| `author` | object | `name`, `email`, `url` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier |
| `keywords` | array | Discovery tags |
| `skills` | string\|array | Custom skill dir path(s); replaces default `skills/` |
| `commands` | string\|array | Custom flat `.md` skill files; replaces default `commands/` |
| `agents` | string\|array | Custom agent file path(s) |
| `hooks` | string\|array\|object | Hook config path(s) or inline config |
| `mcpServers` | string\|array\|object | MCP config path(s) or inline config |
| `lspServers` | string\|array\|object | LSP config path(s) or inline |
| `outputStyles` | string\|array | Output style file/dir path(s) |
| `monitors` | string\|array | Monitor config path(s) or inline array |
| `userConfig` | object | Values prompted at enable time; available as `${user_config.KEY}` |
| `channels` | array | Message channel declarations (Telegram, Slack, etc.) |
| `dependencies` | array | Other plugins this plugin requires |

Custom paths must be relative and start with `./`. When a path is specified for `skills`, `commands`, `agents`, or `outputStyles`, the default directory is not scanned. Include the default in an array to keep it: `"skills": ["./skills/", "./extras/"]`.

### Environment variables in configs

| Variable | Resolves to |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin installation dir (changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent dir surviving updates (`~/.claude/plugins/data/{id}/`) |
| `${user_config.KEY}` | User-provided value declared in `userConfig` |

### Components reference

**Skills** — `skills/<name>/SKILL.md` (or flat `.md` in `commands/`). Namespaced `/plugin-name:skill-name`. See [Agent Skills docs](../skills-doc/SKILL.md).

**Agents** — `agents/<name>.md`. Frontmatter fields: `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation` (`"worktree"` only). `hooks`, `mcpServers`, and `permissionMode` are NOT supported for plugin agents.

**Hooks** — `hooks/hooks.json`. Same lifecycle events as user-defined hooks:

| Event | When |
| :--- | :--- |
| `SessionStart` / `SessionEnd` | Session begins / terminates |
| `UserPromptSubmit` | Before Claude processes prompt |
| `PreToolUse` / `PostToolUse` / `PostToolUseFailure` | Before/after/fail tool call |
| `PermissionRequest` / `PermissionDenied` | Permission dialog / denial |
| `SubagentStart` / `SubagentStop` | Subagent spawned / finished |
| `TaskCreated` / `TaskCompleted` | Task lifecycle |
| `Stop` / `StopFailure` | Turn ends normally / API error |
| `TeammateIdle` | Agent team teammate about to idle |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded |
| `ConfigChange` / `CwdChanged` / `FileChanged` | Config/dir/file change |
| `WorktreeCreate` / `WorktreeRemove` | Worktree lifecycle |
| `PreCompact` / `PostCompact` | Context compaction |
| `Elicitation` / `ElicitationResult` | MCP elicitation |
| `Notification` | Claude sends notification |

Hook types: `command`, `http`, `prompt`, `agent`.

**MCP servers** — `.mcp.json` or inline in `plugin.json`. Start automatically when plugin is enabled.

**LSP servers** — `.lsp.json`. Provides go-to-definition, diagnostics, find references. Required fields: `command`, `extensionToLanguage`. Optional: `args`, `transport`, `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`. Binary must be separately installed.

Official LSP plugins (from official marketplace): `pyright-lsp`, `typescript-lsp`, `rust-analyzer-lsp`, `gopls-lsp`, `clangd-lsp`, `csharp-lsp`, `jdtls-lsp`, `kotlin-lsp`, `lua-lsp`, `php-lsp`, `swift-lsp`.

**Monitors** — `monitors/monitors.json` (array). Require Claude Code v2.1.105+. Run a persistent shell command; each stdout line is delivered to Claude as a notification.

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier within plugin |
| `command` | Yes | Persistent background shell command |
| `description` | Yes | Shown in task panel |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

**settings.json** — Default plugin settings. Only `agent` and `subagentStatusLine` keys are currently supported. `agent` activates a plugin agent as the main thread.

**bin/** — Executables added to the Bash tool's PATH while the plugin is enabled.

### Installation scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` (default) | `~/.claude/settings.json` | Personal, all projects |
| `project` | `.claude/settings.json` | Team, shared via VCS |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled, read-only |

### Plugin CLI commands

```bash
claude plugin install <plugin>[@marketplace] [--scope user|project|local]
claude plugin uninstall <plugin> [--keep-data]
claude plugin enable <plugin>
claude plugin disable <plugin>
claude plugin update <plugin>
claude plugin list [--json] [--available]
claude plugin validate [path]
claude plugin marketplace add <source> [--scope] [--sparse <paths...>]
claude plugin marketplace list [--json]
claude plugin marketplace update [name]
claude plugin marketplace remove <name>
```

In-session slash commands: `/plugin install`, `/plugin marketplace add`, `/reload-plugins`, `/plugin validate`.

### Marketplaces

A marketplace is a git repo (or hosted file) containing `.claude-plugin/marketplace.json`.

**marketplace.json required fields:** `name` (kebab-case), `owner.name`, `plugins` (array with `name` + `source`).

**Plugin source types:**

| Type | Example |
| :--- | :--- |
| Relative path | `"./plugins/my-plugin"` |
| GitHub | `{"source": "github", "repo": "owner/repo", "ref": "v1.0", "sha": "..."}` |
| Git URL | `{"source": "url", "url": "https://gitlab.com/team/plugin.git"}` |
| Git subdirectory | `{"source": "git-subdir", "url": "...", "path": "tools/plugin"}` |
| npm | `{"source": "npm", "package": "@org/plugin", "version": "^2.0.0"}` |

Relative paths only work with Git-based marketplace adds (not URL-based). Use `${CLAUDE_PLUGIN_ROOT}` in all hook/MCP paths; never use absolute paths or `../` traversal.

**Team configuration** (`extraKnownMarketplaces` in `.claude/settings.json`):

```json
{
  "extraKnownMarketplaces": {
    "my-team-tools": {
      "source": { "source": "github", "repo": "your-org/claude-plugins" }
    }
  }
}
```

**Strict mode** in marketplace plugin entries: `strict: true` (default) merges marketplace entry with plugin's `plugin.json`; `strict: false` means the marketplace entry is the complete definition.

**Container pre-population**: set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a pre-built plugins dir. Set `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` to increase git timeout (default 120000 ms). Set `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE=1` to preserve stale cache on git pull failure.

**Managed marketplace restrictions**: `strictKnownMarketplaces` in managed settings — `[]` blocks all, or an allowlist of sources.

### Plugin dependencies

Declared in `plugin.json` `dependencies` array. Entries are plugin names (bare string) or objects:

| Field | Description |
| :--- | :--- |
| `name` | Plugin name (required) |
| `version` | semver range (e.g. `~2.1.0`, `^2.0`, `>=1.4`) |
| `marketplace` | Different marketplace to resolve from |

Tag convention for version resolution: `{plugin-name}--v{version}` (e.g. `secrets-vault--v2.1.0`).

Conflict resolution: when multiple plugins constrain the same dependency, Claude Code intersects their ranges. `range-conflict` error if ranges cannot be combined; `dependency-version-unsatisfied` if installed version is outside range; `no-matching-tag` if no git tag matches.

Requires Claude Code v2.1.110+.

### Common issues

| Issue | Cause | Fix |
| :--- | :--- | :--- |
| Skills/agents/hooks missing | Components inside `.claude-plugin/` | Move to plugin root |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` |
| Hooks not firing | Script not executable | `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin paths |
| LSP `Executable not found in $PATH` | Language server binary missing | Install required binary |
| Relative path fails in URL marketplace | URL marketplace doesn't clone files | Use git-based marketplace or external sources |

### Migrating standalone config to a plugin

Copy `.claude/commands/` → `plugin/commands/`, `.claude/agents/` → `plugin/agents/`, hooks from `settings.json` → `hooks/hooks.json`. Create `.claude-plugin/plugin.json` with `name`, `description`, `version`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — quickstart, plugin structure, adding skills/agents/LSP/monitors, testing locally, debugging, sharing, converting from standalone config
- [Plugins reference](references/claude-code-plugins-reference.md) — complete technical reference: manifest schema, all component specs, environment variables, caching, directory structure, CLI commands, debugging tools, versioning
- [Discover and install plugins](references/claude-code-discover-plugins.md) — official marketplace, adding marketplaces from GitHub/Git/URL/local, installing plugins, managing scopes, auto-updates, team marketplace config, troubleshooting
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace.json schema, plugin source types, hosting on GitHub/Git, private repos, team setup, container pre-population, managed restrictions, release channels, troubleshooting
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring version constraints in `dependencies`, tagging releases, conflict resolution, error types

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
