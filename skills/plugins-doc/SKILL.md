---
name: plugins-doc
description: Complete documentation for Claude Code plugins — creating, installing, distributing, and configuring plugins that bundle skills, agents, hooks, MCP servers, and LSP servers. Covers plugin.json manifest schema, marketplace.json schema, directory structure, CLI commands, plugin sources, installation scopes, environment variables, and debugging.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins: creating plugins, the plugin manifest and marketplace schemas, installing and managing plugins, and distributing plugins through marketplaces.

## Quick Reference

### What a plugin is

A plugin is a self-contained directory that extends Claude Code with skills, agents, hooks, MCP servers, and/or LSP servers. Plugins are namespaced (e.g. `/my-plugin:hello`) to prevent conflicts, versioned for distribution, and installed either via `--plugin-dir` (development) or through a marketplace.

### Standard plugin directory layout

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json        # Manifest (only file inside .claude-plugin/)
├── skills/                # <name>/SKILL.md directories
├── commands/              # Flat .md skill files (legacy; use skills/ for new plugins)
├── agents/                # Subagent .md files
├── output-styles/         # Output style definitions
├── hooks/
│   └── hooks.json         # Hook config
├── .mcp.json              # MCP server config
├── .lsp.json              # LSP server config
├── bin/                   # Executables added to Bash tool PATH
├── settings.json          # Default settings (only `agent` key supported)
└── scripts/               # Hook/utility scripts
```

**Common mistake:** only `plugin.json` goes inside `.claude-plugin/`. All other directories (`skills/`, `agents/`, `hooks/`, etc.) must be at the plugin root.

### Plugin manifest (`plugin.json`) — key fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Required. Kebab-case identifier; used as skill namespace. |
| `version` | string | Semantic version. Must be bumped for updates to propagate past the cache. |
| `description` | string | Shown in plugin manager UI. |
| `author` | object | `{name, email, url}` |
| `homepage` / `repository` / `license` / `keywords` | string/array | Metadata. |
| `skills` / `commands` / `agents` / `outputStyles` | string\|array | Custom paths (replace default dirs). Must start with `./`. |
| `hooks` / `mcpServers` / `lspServers` | string\|array\|object | Inline config or path(s). |
| `userConfig` | object | Values prompted at enable time; accessible as `${user_config.KEY}` and `CLAUDE_PLUGIN_OPTION_<KEY>`. Sensitive values go to keychain. |
| `channels` | array | Message channels (Telegram/Slack/Discord-style) bound to plugin MCP servers. |

The manifest is optional. If omitted, Claude Code auto-discovers components in default locations and uses the directory name as the plugin name.

### Component file locations

| Component | Default location | Notes |
| :--- | :--- | :--- |
| Manifest | `.claude-plugin/plugin.json` | Optional |
| Skills | `skills/<name>/SKILL.md` | Preferred |
| Commands | `commands/*.md` | Flat-file skills (legacy) |
| Agents | `agents/*.md` | Frontmatter-configured subagents |
| Output styles | `output-styles/` | |
| Hooks | `hooks/hooks.json` | |
| MCP servers | `.mcp.json` | |
| LSP servers | `.lsp.json` | |
| Executables | `bin/` | Added to Bash PATH while plugin enabled |
| Settings | `settings.json` | Only `agent` key currently supported |

### Plugin environment variables

- **`${CLAUDE_PLUGIN_ROOT}`** — absolute path to the plugin's installation directory. Changes on update, so files written here don't survive updates. Use for referencing bundled scripts, binaries, config files.
- **`${CLAUDE_PLUGIN_DATA}`** — persistent directory (`~/.claude/plugins/data/{id}/`) that survives updates. Use for `node_modules`, venvs, caches, generated code. Created on first reference; deleted when plugin is uninstalled from the last scope (unless `--keep-data`).

Both variables are substituted inline in skill content, agent content, hook commands, MCP/LSP configs, and exported as env vars to hook processes and MCP/LSP subprocesses.

### Plugin agents — allowed frontmatter

Plugin-shipped agents support: `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation` (only `"worktree"` allowed). For security, `hooks`, `mcpServers`, and `permissionMode` are **not** supported in plugin agents.

### Hook events supported in plugin hooks

Same lifecycle events as user hooks: `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PermissionRequest`, `PermissionDenied`, `PostToolUse`, `PostToolUseFailure`, `Notification`, `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `Stop`, `StopFailure`, `TeammateIdle`, `InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `FileChanged`, `WorktreeCreate`, `WorktreeRemove`, `PreCompact`, `PostCompact`, `Elicitation`, `ElicitationResult`, `SessionEnd`.

**Hook types:** `command`, `http`, `prompt`, `agent`.

### Installation scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` | `~/.claude/settings.json` | Personal, across all projects (default) |
| `project` | `.claude/settings.json` | Team-shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-installed, read-only |

### CLI commands

| Command | Purpose | Key flags |
| :--- | :--- | :--- |
| `claude plugin install <plugin>` | Install from marketplace | `--scope user\|project\|local` |
| `claude plugin uninstall <plugin>` | Remove plugin (aliases: `remove`, `rm`) | `--scope`, `--keep-data` |
| `claude plugin enable <plugin>` | Enable disabled plugin | `--scope` |
| `claude plugin disable <plugin>` | Disable without uninstalling | `--scope` |
| `claude plugin update <plugin>` | Update to latest version | `--scope user\|project\|local\|managed` |
| `claude --plugin-dir <path>` | Load plugin for one session (dev) | Repeat flag for multiple plugins |

### Interactive slash commands

- `/plugin` — open plugin manager (tabs: Discover, Installed, Marketplaces, Errors)
- `/plugin install <plugin>@<marketplace>`
- `/plugin marketplace add <source>` (GitHub `owner/repo`, git URL, local path, remote URL)
- `/plugin marketplace list | update | remove`
- `/reload-plugins` — pick up changes without restart
- `/plugin validate` — check manifest schemas

### Marketplace (`marketplace.json`) schema

Located at `.claude-plugin/marketplace.json`. Required: `name` (kebab-case, public-facing), `owner` (`{name, email?}`), `plugins` (array).

**Plugin entry:** requires `name` and `source`. Optional: any plugin manifest field (`description`, `version`, `author`, `homepage`, `repository`, `license`, `keywords`), plus marketplace-specific `category`, `tags`, `strict`.

**Plugin sources:**

| Source | Fields | Notes |
| :--- | :--- | :--- |
| Relative path | `"./my-plugin"` (string) | Must start with `./`. Only works for git-based marketplaces. |
| `github` | `repo`, `ref?`, `sha?` | `owner/repo` format |
| `url` | `url`, `ref?`, `sha?` | Any git URL |
| `git-subdir` | `url`, `path`, `ref?`, `sha?` | Sparse clone of monorepo subdir |
| `npm` | `package`, `version?`, `registry?` | Installed via `npm install` |

**Strict mode:** `strict: true` (default) means `plugin.json` is authoritative; marketplace entry supplements. `strict: false` means marketplace entry is the full definition (no `plugin.json` components allowed).

**Reserved marketplace names:** `claude-code-marketplace`, `claude-code-plugins`, `claude-plugins-official`, `anthropic-marketplace`, `anthropic-plugins`, `agent-skills`, `knowledge-work-plugins`, `life-sciences`.

### Plugin caching and path rules

- Marketplace plugins are copied to `~/.claude/plugins/cache` — they can't reference files outside the plugin directory via `../`.
- Each installed version is a separate directory; orphaned versions are cleaned up after 7 days.
- Use symlinks within the plugin dir to reach external files; symlinks are preserved in the cache.
- All manifest paths must be relative and start with `./`.

### Local development workflow

```bash
claude --plugin-dir ./my-plugin
# make edits
/reload-plugins
```

Multiple `--plugin-dir` flags load multiple plugins. Local `--plugin-dir` plugins override installed marketplace plugins of the same name for that session (except managed force-enabled plugins).

### Team marketplaces

Add `extraKnownMarketplaces` to `.claude/settings.json` so team members are prompted to install when they trust the folder:

```json
{
  "extraKnownMarketplaces": {
    "my-team-tools": {
      "source": { "source": "github", "repo": "your-org/claude-plugins" }
    }
  }
}
```

### Debugging tips

- `claude --debug` shows plugin load details, registration, and errors.
- `claude plugin validate` / `/plugin validate` checks manifest, skill/agent frontmatter, and `hooks/hooks.json`.
- Common fixes: move directories out of `.claude-plugin/`; `chmod +x` hook scripts; use `${CLAUDE_PLUGIN_ROOT}` for all plugin paths; ensure paths start with `./`; bump `version` so cache invalidates.

### Auto-update

- Official Anthropic marketplaces have auto-update enabled by default; third-party and local marketplaces do not.
- Toggle per-marketplace in `/plugin` > Marketplaces.
- `DISABLE_AUTOUPDATER=1` disables all auto-updates.
- `DISABLE_AUTOUPDATER=1` + `FORCE_AUTOUPDATE_PLUGINS=1` keeps plugin updates but disables Claude Code updates.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — tutorial for building a plugin, quickstart, plugin structure overview, adding skills/LSP/settings, migrating from standalone `.claude/` configuration.
- [Plugins reference](references/claude-code-plugins-reference.md) — complete technical specifications: component schemas, manifest schema, `userConfig`, `channels`, environment variables, caching behavior, CLI commands, debugging tools.
- [Discover and install plugins](references/claude-code-discover-plugins.md) — how marketplaces work, official Anthropic marketplace, adding marketplaces (GitHub/git/local/URL), installing plugins, managing plugins, auto-updates, team marketplaces.
- [Plugin marketplaces](references/claude-code-plugin-marketplaces.md) — creating and distributing marketplaces: `marketplace.json` schema, plugin sources (relative/github/url/git-subdir/npm), strict mode, hosting, troubleshooting.

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Plugin marketplaces: https://code.claude.com/docs/en/plugin-marketplaces.md
