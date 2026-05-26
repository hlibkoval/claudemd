---
name: plugins-doc
description: Complete official documentation for Claude Code plugins — plugin creation (manifest schema, plugin.json fields, directory structure, skills/agents/hooks/MCP/LSP/monitors/themes components), discovering and installing plugins from marketplaces, creating and distributing marketplaces (marketplace.json schema, all source types), plugin dependency version constraints, and the plugin hint protocol for CLIs.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

### Plugin vs Standalone Configuration

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugins** (`.claude-plugin/plugin.json` directory) | `/plugin-name:hello` | Sharing with teams, distributing to community, versioned releases |

### Plugin Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Manifest (optional)
├── skills/                  # Skills as <name>/SKILL.md
├── commands/                # Skills as flat .md files (legacy)
├── agents/                  # Subagent definitions
├── hooks/hooks.json         # Hook configurations
├── .mcp.json                # MCP server definitions
├── .lsp.json                # LSP server configurations
├── monitors/monitors.json   # Background monitor configurations
├── themes/                  # Color theme definitions
├── output-styles/           # Output style definitions
├── bin/                     # Executables added to PATH
└── settings.json            # Default settings (agent, subagentStatusLine only)
```

**Warning**: Only `plugin.json` goes inside `.claude-plugin/`. All other directories (skills/, agents/, hooks/, etc.) must be at the plugin root.

### plugin.json Schema — Key Fields

**Required** (if manifest present): `name`

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique identifier; becomes skill namespace (e.g., `my-plugin:hello`) |
| `displayName` | string | Human-readable name in UI (v2.1.143+); falls back to `name` |
| `version` | string | Semantic version. If set, users only update when you bump it. Omit to use git SHA |
| `description` | string | Brief explanation of plugin purpose |
| `author` | object | `name`, `email`, `url` fields |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier (MIT, Apache-2.0) |
| `keywords` | array | Discovery tags |
| `dependencies` | array | Other plugins required; string names or `{name, version, marketplace}` objects |

**Component path fields** (override default locations):

| Field | Default location | Behavior |
| :--- | :--- | :--- |
| `skills` | `skills/` | Adds to default (default always scanned) |
| `commands` | `commands/` | Replaces default |
| `agents` | `agents/` | Replaces default |
| `hooks` | `hooks/hooks.json` | Merged from multiple sources |
| `mcpServers` | `.mcp.json` | Merged |
| `lspServers` | `.lsp.json` | Merged |
| `outputStyles` | `output-styles/` | Replaces default |
| `experimental.themes` | `themes/` | Replaces default |
| `experimental.monitors` | `monitors/monitors.json` | Replaces default |

**userConfig field** — prompts user at enable time:

```json
{
  "userConfig": {
    "api_token": {
      "type": "string",
      "title": "API token",
      "description": "Authentication token",
      "sensitive": true
    }
  }
}
```

Available as `${user_config.KEY}` in MCP/LSP/hook/monitor configs. Exported as `CLAUDE_PLUGIN_OPTION_<KEY>` to subprocesses. Types: `string`, `number`, `boolean`, `directory`, `file`.

### Environment Variables Available in Plugin Configs

| Variable | Resolves to |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Persistent data directory for the plugin (`~/.claude/plugins/data/{id}/`) |
| `${CLAUDE_PROJECT_DIR}` | Project root (same as hooks' `CLAUDE_PROJECT_DIR`) |

`CLAUDE_PLUGIN_ROOT` changes on update; `CLAUDE_PLUGIN_DATA` persists across versions.

### Testing Plugins Locally

```bash
claude --plugin-dir ./my-plugin          # Load from directory
claude --plugin-dir ./my-plugin.zip      # Load from zip (v2.1.128+)
claude --plugin-url https://example.com/my-plugin.zip  # Load from URL
```

Multiple plugins: repeat the flag. When a `--plugin-dir` plugin has the same name as an installed plugin, local copy wins for that session.

Use `/reload-plugins` to pick up changes without restarting.

### Plugin Installation Scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` (default) | `~/.claude/settings.json` | Personal, all projects |
| `project` | `.claude/settings.json` | Team-shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled, read-only |

### CLI Commands Reference

| Command | Description |
| :--- | :--- |
| `claude plugin install <plugin>[@marketplace] [--scope]` | Install a plugin |
| `claude plugin uninstall <plugin> [--keep-data] [--prune]` | Remove a plugin |
| `claude plugin enable <plugin>` | Enable a disabled plugin |
| `claude plugin disable <plugin>` | Disable without uninstalling |
| `claude plugin update <plugin>` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin details <name>` | Show component inventory and token cost |
| `claude plugin validate [path] [--strict]` | Validate plugin or marketplace JSON |
| `claude plugin tag [--push] [--dry-run]` | Create release git tag for version resolution |
| `claude plugin prune [--dry-run] [-y]` | Remove orphaned auto-installed dependencies |

### Marketplace Schema

**marketplace.json location**: `.claude-plugin/marketplace.json`

```json
{
  "name": "my-marketplace",
  "owner": { "name": "Team Name", "email": "team@example.com" },
  "plugins": [
    { "name": "my-plugin", "source": "./plugins/my-plugin", "description": "..." }
  ]
}
```

**Plugin source types**:

| Source type | Example | Notes |
| :--- | :--- | :--- |
| Relative path | `"./plugins/my-plugin"` | Only works with git-based marketplaces, not URL-based |
| `github` | `{"source": "github", "repo": "owner/repo", "ref": "v2.0", "sha": "..."}` | |
| `url` | `{"source": "url", "url": "https://gitlab.com/team/plugin.git"}` | Any git host |
| `git-subdir` | `{"source": "git-subdir", "url": "...", "path": "tools/plugin"}` | Sparse clone |
| `npm` | `{"source": "npm", "package": "@org/plugin", "version": "2.1.0"}` | |

**Adding marketplaces**:
```bash
/plugin marketplace add owner/repo          # GitHub
/plugin marketplace add https://gitlab.com/org/repo.git
/plugin marketplace add ./local-marketplace
/plugin marketplace add https://example.com/marketplace.json
```

### Plugin Dependency Version Constraints

Declare in `plugin.json`:
```json
{
  "dependencies": [
    "audit-logger",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```

Version field accepts any semver range (`~2.1.0`, `^2.0`, `>=1.4`, `=2.1.0`). Resolution uses git tags in `{plugin-name}--v{version}` format. Create with `claude plugin tag --push`.

Cross-marketplace dependencies require `allowCrossMarketplaceDependenciesOn` in the root marketplace's `marketplace.json`.

### Version Management

Resolution order (first that is set wins):
1. `version` in `plugin.json`
2. `version` in marketplace entry
3. Git commit SHA (for git-backed sources)
4. `"unknown"` (npm or non-git local)

If `version` is set, users only receive updates when it changes. Omit for commit-SHA-based auto-updates.

### Background Monitors

Declared in `monitors/monitors.json` (requires v2.1.105+):
```json
[
  {
    "name": "error-log",
    "command": "tail -F ./logs/error.log",
    "description": "Application error log",
    "when": "on-skill-invoke:debug"
  }
]
```

`when`: `"always"` (default) or `"on-skill-invoke:<skill-name>"`. Each stdout line delivered to Claude as a notification.

### Plugin Hint Protocol (for CLI maintainers)

Write to stderr when `CLAUDECODE` env var is set:
```
<claude-code-hint v="1" type="plugin" value="example-cli@claude-plugins-official" />
```

Requirements: tag must be on its own line; plugin must be in an official Anthropic marketplace. Claude Code strips the line from output (not counted toward tokens), shows user a one-time install prompt. Prompt frequency: once per plugin, once per session.

### Common Debugging

| Issue | Solution |
| :--- | :--- |
| Plugin not loading | Run `claude plugin validate` or `/plugin validate` |
| Skills not appearing | Check `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Check script is executable (`chmod +x`); event names are case-sensitive |
| MCP server fails | Use `${CLAUDE_PLUGIN_ROOT}` for all plugin-relative paths |
| LSP binary not found | Install the language server binary separately (e.g., `npm install -g typescript-language-server`) |

Debug with `claude --debug` for plugin loading details. In-session: `/plugin` > **Errors** tab.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — quickstart, plugin structure, adding skills/LSP/monitors/settings, testing locally, migrating from standalone config, submitting to community marketplace
- [Plugins reference](references/claude-code-plugins-reference.md) — complete component schemas (skills, agents, hooks, MCP, LSP, monitors, themes), manifest schema with all fields, environment variables, plugin caching and file resolution, directory structure, all CLI commands, debugging tools
- [Discover and install plugins](references/claude-code-discover-plugins.md) — official marketplace, community marketplace, adding marketplaces from all sources, install/manage/update/remove, team marketplace config, auto-updates, LSP plugin table
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace.json schema, all plugin source types, hosting (GitHub, private repos, containers/seed dirs), managed marketplace restrictions, version resolution and release channels, troubleshooting
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring dependencies, version ranges, cross-marketplace dependencies, git tag convention, constraint interaction, enable/disable with dependencies, pruning orphaned dependencies
- [Recommend your plugin from your CLI](references/claude-code-plugin-hints.md) — plugin hint protocol, emit format, placement strategies, hint tag format/requirements

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
- Recommend your plugin from your CLI: https://code.claude.com/docs/en/plugin-hints.md
