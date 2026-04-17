---
name: plugins-doc
description: Complete official documentation for Claude Code plugins — creating plugins, plugin manifest schema, plugin components (skills, agents, hooks, MCP, LSP, monitors), dependency version constraints, discovering and installing plugins from marketplaces, creating and distributing marketplaces, CLI commands, and debugging.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for the Claude Code plugin system.

## Quick Reference

### Standalone vs plugin

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugin** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing across projects and teams, marketplace distribution |

Start standalone, then convert to a plugin when ready to share.

### Plugin directory structure

```
my-plugin/
  .claude-plugin/
    plugin.json          # Manifest (only file in this dir)
  skills/                # Skills as <name>/SKILL.md
  commands/              # Skills as flat .md files
  agents/                # Subagent definitions
  hooks/
    hooks.json           # Hook configurations
  monitors/
    monitors.json        # Background monitor configs
  bin/                   # Executables added to Bash PATH
  output-styles/         # Output style definitions
  settings.json          # Default settings (agent, subagentStatusLine)
  .mcp.json              # MCP server definitions
  .lsp.json              # LSP server configurations
```

All component directories go at the plugin root, never inside `.claude-plugin/`.

### plugin.json manifest fields

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `name` | string | Yes | Unique identifier (kebab-case). Used as skill namespace prefix |
| `version` | string | No | Semantic version (`MAJOR.MINOR.PATCH`) |
| `description` | string | No | Brief explanation of plugin purpose |
| `author` | object | No | `{name, email?, url?}` |
| `homepage` | string | No | Documentation URL |
| `repository` | string | No | Source code URL |
| `license` | string | No | SPDX license identifier |
| `keywords` | array | No | Discovery tags |
| `skills` | string/array | No | Custom skill directory paths (replaces default `skills/`) |
| `commands` | string/array | No | Custom command file/directory paths |
| `agents` | string/array | No | Custom agent file paths |
| `hooks` | string/array/object | No | Hook config paths or inline config |
| `mcpServers` | string/array/object | No | MCP config paths or inline config |
| `lspServers` | string/array/object | No | LSP server configurations |
| `monitors` | string/array | No | Background monitor configurations |
| `userConfig` | object | No | User-configurable values prompted at enable time |
| `channels` | array | No | Channel declarations for message injection |
| `dependencies` | array | No | Other plugins this plugin requires (optionally with semver constraints) |

### Plugin components

| Component | Default location | Purpose |
| :--- | :--- | :--- |
| Skills | `skills/` | `<name>/SKILL.md` directories |
| Commands | `commands/` | Flat `.md` skill files (use `skills/` for new plugins) |
| Agents | `agents/` | Subagent markdown files |
| Hooks | `hooks/hooks.json` | Event handlers (`command`, `http`, `prompt`, `agent` types) |
| MCP servers | `.mcp.json` | MCP server definitions (auto-start when plugin enabled) |
| LSP servers | `.lsp.json` | Language server configs for code intelligence |
| Monitors | `monitors/monitors.json` | Background processes delivering stdout to Claude as notifications |
| Executables | `bin/` | Added to Bash tool PATH while plugin enabled |
| Settings | `settings.json` | Default config (`agent`, `subagentStatusLine` keys only) |
| Output styles | `output-styles/` | Output style definitions |

### Environment variables in plugins

| Variable | Purpose |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin install directory (changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state (survives updates) at `~/.claude/plugins/data/{id}/` |
| `${user_config.KEY}` | User-configured values from `userConfig` |

All three are substituted inline in skill/agent content, hook commands, monitor commands, and MCP/LSP configs.

### Hook events (plugin hooks)

Plugin hooks respond to the same lifecycle events as user hooks. Key events:

| Event | When it fires |
| :--- | :--- |
| `SessionStart` | Session begins or resumes |
| `PreToolUse` | Before a tool call (can block) |
| `PostToolUse` | After a tool call succeeds |
| `Stop` | Claude finishes responding |
| `FileChanged` | Watched file changes on disk (matcher specifies filenames) |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded into context |
| `ConfigChange` | Configuration file changes during session |

See the full reference for the complete list of 25+ events.

### Monitor schema

```json
[
  {
    "name": "unique-id",
    "command": "tail -F ./logs/error.log",
    "description": "Application error log",
    "when": "always"
  }
]
```

`when` options: `"always"` (default, starts at session start) or `"on-skill-invoke:<skill-name>"` (starts on first skill dispatch).

### LSP server schema

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": { ".go": "go" }
  }
}
```

Required: `command`, `extensionToLanguage`. Optional: `args`, `transport` (`stdio`/`socket`), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`.

### Dependency version constraints

Declare in `dependencies` array of `plugin.json`:

```json
{
  "dependencies": [
    "audit-logger",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```

- `version` accepts semver ranges: `~2.1.0`, `^2.0`, `>=1.4`, `=2.1.0`
- Tag releases as `{plugin-name}--v{version}` on the marketplace repo
- Multiple plugins constraining the same dependency: ranges are intersected
- Errors: `range-conflict`, `dependency-version-unsatisfied`, `no-matching-tag`

### Plugin installation scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` | `~/.claude/settings.json` | Personal plugins, all projects (default) |
| `project` | `.claude/settings.json` | Team plugins, shared via VCS |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled (read-only) |

### CLI commands

| Command | Description |
| :--- | :--- |
| `claude plugin install <plugin> [-s scope]` | Install a plugin |
| `claude plugin uninstall <plugin> [-s scope] [--keep-data]` | Remove a plugin |
| `claude plugin enable <plugin> [-s scope]` | Enable a disabled plugin |
| `claude plugin disable <plugin> [-s scope]` | Disable without uninstalling |
| `claude plugin update <plugin> [-s scope]` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin validate .` | Validate plugin manifest and components |
| `claude plugin marketplace add <source> [--scope] [--sparse]` | Add a marketplace |
| `claude plugin marketplace list [--json]` | List marketplaces |
| `claude plugin marketplace update [name]` | Refresh marketplace data |
| `claude plugin marketplace remove <name>` | Remove a marketplace |

### In-session commands

| Command | Purpose |
| :--- | :--- |
| `/plugin` | Open plugin manager (Discover, Installed, Marketplaces, Errors tabs) |
| `/plugin install <name>@<marketplace>` | Install a plugin |
| `/reload-plugins` | Reload all plugins without restarting |
| `/plugin validate .` | Validate a plugin directory |

### Marketplace sources

| Source | `source` value | Key fields |
| :--- | :--- | :--- |
| Relative path | `"./plugins/my-plugin"` | Must start with `./` |
| GitHub | `{ "source": "github", "repo": "owner/repo" }` | Optional: `ref`, `sha` |
| Git URL | `{ "source": "url", "url": "https://..." }` | Optional: `ref`, `sha` |
| Git subdirectory | `{ "source": "git-subdir", "url": "...", "path": "..." }` | Sparse clone for monorepos |
| npm | `{ "source": "npm", "package": "@org/pkg" }` | Optional: `version`, `registry` |

### marketplace.json required fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Marketplace identifier (kebab-case) |
| `owner` | object | `{name, email?}` |
| `plugins` | array | List of plugin entries (each needs `name` + `source`) |

Optional: `metadata.description`, `metadata.version`, `metadata.pluginRoot` (base dir prepended to relative source paths).

### Team and managed marketplace configuration

Configure in `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "company-tools": {
      "source": { "source": "github", "repo": "your-org/plugins" }
    }
  },
  "enabledPlugins": {
    "formatter@company-tools": true
  }
}
```

Use `strictKnownMarketplaces` in managed settings to restrict which marketplaces users can add. Values: undefined (no restrictions), empty array (complete lockdown), or list of allowed sources (supports `hostPattern` and `pathPattern` regex matching).

### Testing plugins locally

```bash
claude --plugin-dir ./my-plugin           # Load one plugin
claude --plugin-dir ./p1 --plugin-dir ./p2  # Load multiple
```

Local `--plugin-dir` overrides same-named installed plugins (except managed force-enabled). Use `/reload-plugins` to pick up changes without restarting.

### Debugging checklist

| Issue | Solution |
| :--- | :--- |
| Plugin not loading | Run `claude plugin validate` or `claude --debug` |
| Skills not appearing | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Check script is executable, event name is case-sensitive, matcher is correct |
| MCP server fails | Use `${CLAUDE_PLUGIN_ROOT}` for all paths |
| Path errors | All manifest paths must be relative, starting with `./` |
| LSP binary not found | Install the language server binary separately |

### Container/CI pre-population

Set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a pre-built `~/.claude/plugins` directory containing `known_marketplaces.json`, `marketplaces/`, and `cache/`. Seed directory is read-only; auto-updates disabled for seed marketplaces.

### Key environment variables

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_PLUGIN_SEED_DIR` | Pre-populate plugins for containers (colon-separated paths) |
| `CLAUDE_CODE_PLUGIN_CACHE_DIR` | Override default plugin cache location |
| `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE` | Keep stale cache when git pull fails (offline envs) |
| `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` | Git operation timeout in ms (default 120000) |
| `FORCE_AUTOUPDATE_PLUGINS` | Keep plugin auto-updates when `DISABLE_AUTOUPDATER` is set |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — full guide to creating plugins with skills, agents, hooks, MCP servers, LSP servers, and monitors; quickstart; plugin structure; converting standalone configs to plugins; testing and debugging.
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring version constraints in plugin.json, tagging releases, constraint intersection, and resolving dependency errors.
- [Plugins reference](references/claude-code-plugins-reference.md) — complete technical specs: manifest schema, all component schemas (skills, agents, hooks, MCP, LSP, monitors), environment variables, persistent data directory, plugin caching, installation scopes, CLI commands, debugging tools, version management.
- [Discover and install plugins](references/claude-code-discover-plugins.md) — finding and installing plugins from marketplaces, official marketplace, code intelligence plugins, managing installed plugins, adding marketplaces from GitHub/Git/local/URL, team marketplace configuration, auto-updates, troubleshooting.
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace.json schema, plugin sources (relative path, GitHub, Git URL, git-subdir, npm), hosting and distribution, private repos, strict mode, managed marketplace restrictions, release channels, container pre-population, troubleshooting.

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
