---
name: plugins-doc
description: Complete official documentation for Claude Code plugins — creating plugins, plugin manifest schema, component reference (skills, agents, hooks, MCP servers, LSP servers, monitors, themes), plugin directory structure, CLI commands, discovering and installing plugins, marketplace creation and distribution, plugin dependency version constraints.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

### Standalone vs Plugin

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugins** (`.claude-plugin/plugin.json` directory) | `/plugin-name:hello` | Sharing with team, distributing, versioned releases, reusable across projects |

### Plugin Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          ← Only manifest here
├── skills/                  ← Skills as <name>/SKILL.md
├── commands/                ← Skills as flat .md files (use skills/ for new plugins)
├── agents/                  ← Subagent definitions
├── hooks/hooks.json         ← Hook configurations
├── .mcp.json                ← MCP server definitions
├── .lsp.json                ← LSP server configurations
├── monitors/monitors.json   ← Background monitors
├── themes/                  ← Color themes (experimental)
├── output-styles/           ← Output style definitions
├── bin/                     ← Executables added to Bash PATH
└── settings.json            ← Default settings (agent, subagentStatusLine only)
```

WARNING: All component directories must be at the plugin root, not inside `.claude-plugin/`.

### Plugin Manifest Schema (`plugin.json`)

**Required** (if manifest present):

| Field | Type | Description |
| :---- | :--- | :---------- |
| `name` | string | Unique kebab-case identifier; used as skill namespace |

**Metadata fields:**

| Field | Type | Description |
| :---- | :--- | :---------- |
| `version` | string | Semver. If set, users only get updates on bumps. If omitted, uses git commit SHA |
| `description` | string | Brief explanation of plugin purpose |
| `author` | object | `{name, email, url}` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX license identifier |
| `keywords` | array | Discovery tags |

**Component path fields:**

| Field | Type | Behavior |
| :---- | :--- | :------- |
| `skills` | string\|array | Additional skill dirs (adds to default `skills/`) |
| `commands` | string\|array | Flat .md skill files/dirs (replaces default `commands/`) |
| `agents` | string\|array | Agent files (replaces default `agents/`) |
| `hooks` | string\|array\|object | Hook config paths or inline config |
| `mcpServers` | string\|array\|object | MCP config paths or inline config |
| `lspServers` | string\|array\|object | LSP server configurations |
| `outputStyles` | string\|array | Output style files/dirs (replaces default `output-styles/`) |
| `experimental.themes` | string\|array | Color theme files/dirs (replaces default `themes/`) |
| `experimental.monitors` | string\|array | Background monitor configs |
| `userConfig` | object | Values prompted at enable time |
| `channels` | array | Message channel declarations (each bound to an MCP server) |
| `dependencies` | array | Other plugins this plugin requires |
| `settings` | object | Inline default settings (overridden by `settings.json` at plugin root) |

### `userConfig` Schema

```json
{
  "userConfig": {
    "api_token": {
      "type": "string",
      "title": "API token",
      "description": "Authentication token",
      "sensitive": true,
      "required": true
    }
  }
}
```

| Field | Required | Description |
| :---- | :------- | :---------- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label in configuration dialog |
| `description` | Yes | Help text |
| `sensitive` | No | Masks input; stores in keychain, not settings.json |
| `required` | No | Validation fails when empty |
| `default` | No | Value when user provides nothing |
| `multiple` | No | For `string`: allow array of strings |
| `min`/`max` | No | Bounds for `number` type |

Values available as `${user_config.KEY}` in MCP/LSP/hook/monitor configs and as `CLAUDE_PLUGIN_OPTION_<KEY>` env vars.

### Environment Variables

| Variable | Description |
| :------- | :---------- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin installation directory. Changes on update. Wrap in quotes in shell commands: `"${CLAUDE_PLUGIN_ROOT}"` |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state that survives updates. Resolves to `~/.claude/plugins/data/{id}/` |
| `${CLAUDE_PROJECT_DIR}` | Project root (same as the `CLAUDE_PROJECT_DIR` variable hooks receive) |

### Plugin Components Reference

**Skills:**
- Location: `skills/<name>/SKILL.md` (or `commands/<name>.md` for flat style)
- Namespaced as `/plugin-name:skill-name`
- Claude invokes automatically based on task context

**Agents:**
- Location: `agents/` directory
- Frontmatter: `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation`
- Valid `isolation` value: `"worktree"` only
- NOT supported for plugin agents: `hooks`, `mcpServers`, `permissionMode`

**Hooks** — same events as user-defined hooks, loaded from `hooks/hooks.json`:

| Event | When |
| :---- | :--- |
| `SessionStart` | Session begins or resumes |
| `Setup` | `--init-only` or `--init`/`--maintenance` in `-p` mode |
| `PreToolUse` | Before a tool call; can block |
| `PostToolUse` | After a tool call succeeds |
| `PostToolUseFailure` | After a tool call fails |
| `PostToolBatch` | After a full batch of parallel tool calls |
| `Stop` | When Claude finishes responding |
| `SessionEnd` | When a session terminates |
| (and all other standard hook events) | See hooks-doc for full list |

Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`

**MCP Servers** — defined in `.mcp.json` or inline in `plugin.json`:
- Start automatically when plugin is enabled
- Use `${CLAUDE_PLUGIN_ROOT}` for paths to bundled binaries

**LSP Servers** — defined in `.lsp.json` or inline in `plugin.json`:

| Field | Required | Description |
| :---- | :------- | :---------- |
| `command` | Yes | LSP binary to execute (must be in PATH) |
| `extensionToLanguage` | Yes | Maps file extensions to language IDs |
| `args` | No | Command-line arguments |
| `transport` | No | `stdio` (default) or `socket` |
| `env` | No | Environment variables |
| `initializationOptions` | No | Server init options |
| `restartOnCrash` | No | Auto-restart on crash |
| `maxRestarts` | No | Max restart attempts |

**Monitors** — defined in `monitors/monitors.json` (requires v2.1.105+):

| Field | Required | Description |
| :---- | :------- | :---------- |
| `name` | Yes | Unique identifier within the plugin |
| `command` | Yes | Shell command run as persistent background process |
| `description` | Yes | Short summary of what is being watched |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

**Themes** — JSON files in `themes/` (experimental):
```json
{
  "name": "Dracula",
  "base": "dark",
  "overrides": { "claude": "#bd93f9", "error": "#ff5555" }
}
```

### Plugin Installation Scopes

| Scope | Settings file | Use case |
| :---- | :------------ | :------- |
| `user` | `~/.claude/settings.json` | Personal plugins across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled, read-only |

### CLI Commands

```bash
claude plugin install <plugin>[@marketplace] [--scope user|project|local]
claude plugin uninstall <plugin>[@marketplace] [--scope] [--keep-data] [--prune]
claude plugin enable <plugin>[@marketplace] [--scope]
claude plugin disable <plugin>[@marketplace] [--scope]
claude plugin update <plugin>[@marketplace] [--scope]
claude plugin list [--json] [--available]
claude plugin details <name>
claude plugin tag [--push] [--dry-run] [--force]
claude plugin prune [--scope] [--dry-run] [-y]
claude plugin validate [path]
```

In-session slash commands: `/plugin`, `/reload-plugins`

### Plugin Caching

- Marketplace plugins are copied to `~/.claude/plugins/cache/`
- Plugins cannot reference files outside their directory
- Symlinks within the plugin directory are preserved
- Symlinks to sibling plugins in the same marketplace are dereferenced (content copied)
- Symlinks outside the marketplace are skipped

### Version Management

Version is resolved from (first match wins):
1. `version` in `plugin.json`
2. `version` in the marketplace entry
3. Git commit SHA of the plugin source
4. `unknown` for npm sources or local non-git directories

| Approach | How | Best for |
| :------- | :-- | :------- |
| Explicit version | Set `"version"` in `plugin.json`; bump on each release | Published plugins with stable release cycles |
| Commit-SHA version | Omit `version` entirely | Internal/active development |

### Marketplace Schema (`marketplace.json`)

```json
{
  "name": "my-marketplace",
  "owner": { "name": "Team Name" },
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin",
      "description": "..."
    }
  ]
}
```

**Plugin source types:**

| Source | Format | Notes |
| :----- | :----- | :---- |
| Relative path | `"./my-plugin"` string | Must start with `./`; only works with git-based marketplaces |
| `github` | `{source, repo, ref?, sha?}` | `repo`: `owner/repo` format |
| `url` | `{source, url, ref?, sha?}` | Full git URL |
| `git-subdir` | `{source, url, path, ref?, sha?}` | Sparse-clones subdirectory |
| `npm` | `{source, package, version?, registry?}` | Installed via `npm install` |

**Strict mode** (plugin entry field `strict`):
- `true` (default): `plugin.json` is authority; marketplace entry supplements it
- `false`: marketplace entry is the entire definition; `plugin.json` components cause a conflict

### Add Marketplaces

```shell
/plugin marketplace add anthropics/claude-code          # GitHub owner/repo
/plugin marketplace add https://gitlab.com/org/repo.git # Git URL
/plugin marketplace add ./my-local-marketplace           # Local path
/plugin marketplace add https://example.com/marketplace.json  # Remote URL
```

### Team Configuration

Add to `.claude/settings.json` to auto-prompt team members:
```json
{
  "extraKnownMarketplaces": {
    "my-team-tools": {
      "source": { "source": "github", "repo": "your-org/claude-plugins" }
    }
  },
  "enabledPlugins": {
    "formatter@my-team-tools": true
  }
}
```

### Plugin Dependencies

Declare in `plugin.json`:
```json
{
  "dependencies": [
    "audit-logger",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```

Version constraint fields: `name` (required), `version` (semver range), `marketplace` (cross-marketplace).

Tag releases for version resolution:
```bash
claude plugin tag --push   # creates {plugin-name}--v{version} git tag
```

**Constraint interaction:** Claude Code intersects ranges from all installed plugins requiring the same dependency; resolves to highest version satisfying all constraints.

**Dependency errors:**

| Error | Fix |
| :---- | :-- |
| `dependency-unsatisfied` | Run `claude plugin install` shown in error |
| `range-conflict` | Uninstall/update a conflicting plugin |
| `dependency-version-unsatisfied` | Re-run `claude plugin install <dependency>@<marketplace>` |
| `no-matching-tag` | Ensure upstream has tagged releases using `{name}--v{version}` convention |

### Official Marketplace LSP Plugins

| Plugin | Language server | Install command |
| :----- | :-------------- | :-------------- |
| `pyright-lsp` | Pyright (Python) | `pip install pyright` or `npm install -g pyright` |
| `typescript-lsp` | TypeScript Language Server | `npm install -g typescript-language-server typescript` |
| `rust-analyzer-lsp` | rust-analyzer | See rust-analyzer docs |

Install LSP plugins from the official marketplace, then install the binary separately.

### Common Debug Issues

| Issue | Cause | Solution |
| :---- | :---- | :------- |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` |
| Skills not appearing | Wrong directory structure | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Script not executable | `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin paths |
| LSP `Executable not found` | Language server not installed | Install the binary |

Testing locally:
```bash
claude --plugin-dir ./my-plugin          # load from directory
claude --plugin-dir ./my-plugin.zip      # load from zip (v2.1.128+)
claude --plugin-url https://example.com/my-plugin.zip  # load from URL
```

### Persistent Data Directory Pattern

Install npm dependencies once, reuse across sessions:
```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "diff -q \"${CLAUDE_PLUGIN_ROOT}/package.json\" \"${CLAUDE_PLUGIN_DATA}/package.json\" >/dev/null 2>&1 || (cd \"${CLAUDE_PLUGIN_DATA}\" && cp \"${CLAUDE_PLUGIN_ROOT}/package.json\" . && npm install) || rm -f \"${CLAUDE_PLUGIN_DATA}/package.json\""
      }]
    }]
  }
}
```

### Pre-populating Plugins for Containers

```bash
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin marketplace add your-org/plugins
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin install my-tool@your-plugins
# At runtime:
export CLAUDE_CODE_PLUGIN_SEED_DIR=/opt/claude-seed
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — quickstart, plugin structure, adding skills/agents/LSP servers/monitors, testing locally, migrating from standalone, submitting to marketplace
- [Plugins reference](references/claude-code-plugins-reference.md) — complete schemas for all components, manifest fields, environment variables, CLI commands, debugging tools, version management
- [Discover and install plugins](references/claude-code-discover-plugins.md) — official marketplace, adding marketplaces from various sources, installing/managing plugins, code intelligence plugins, troubleshooting
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace schema, plugin source types, hosting, private repos, managed restrictions, release channels, versioning, container seed dirs
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring dependencies, version constraint syntax, tagging releases, conflict resolution, pruning orphaned dependencies

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
