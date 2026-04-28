---
name: plugins-doc
description: Complete official documentation for the Claude Code plugin system — creating plugins, plugin manifest schema, plugin components (skills, agents, hooks, MCP servers, LSP servers, monitors, themes), discovering and installing plugins, plugin marketplaces, dependency version constraints, CLI commands, and troubleshooting.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for the Claude Code plugin system.

## Quick Reference

Plugins are self-contained directories that extend Claude Code with skills, agents, hooks, MCP servers, LSP servers, monitors, and themes. They can be shared via marketplaces or loaded locally with `--plugin-dir`.

### Standalone vs plugin configuration

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/`) | `/hello` | Personal or project-specific; quick experiments |
| **Plugins** (dir with `.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with team/community; versioned releases; multiple projects |

### Plugin directory structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json        # Manifest (optional — name is the only required field if present)
├── skills/                # Skill dirs with <name>/SKILL.md
├── commands/              # Skills as flat .md files (legacy; prefer skills/)
├── agents/                # Subagent .md files
├── hooks/
│   └── hooks.json         # Hook configuration
├── monitors/
│   └── monitors.json      # Background monitor config
├── output-styles/         # Output style definitions
├── themes/                # Color theme JSON files
├── bin/                   # Executables added to Bash tool PATH
├── .mcp.json              # MCP server definitions
├── .lsp.json              # LSP server configurations
└── settings.json          # Default settings (only agent and subagentStatusLine keys supported)
```

Only `plugin.json` goes inside `.claude-plugin/`. All other directories are at the plugin root.

### Plugin manifest schema (`plugin.json`)

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Required. Unique kebab-case identifier; becomes skill namespace (e.g. `/my-plugin:hello`) |
| `version` | string | Explicit semver. If set, users only receive updates when bumped. Omit to use git commit SHA |
| `description` | string | Shown in plugin manager |
| `author` | object | `name`, `email`, `url` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | e.g. `"MIT"` |
| `keywords` | array | Discovery tags |
| `skills` | string\|array | Custom skill directory paths (replaces default `skills/`) |
| `commands` | string\|array | Custom flat .md skill paths (replaces default `commands/`) |
| `agents` | string\|array | Custom agent file paths |
| `hooks` | string\|array\|object | Hook config paths or inline config |
| `mcpServers` | string\|array\|object | MCP config paths or inline config |
| `lspServers` | string\|array\|object | LSP config paths or inline config |
| `outputStyles` | string\|array | Output style paths |
| `themes` | string\|array | Theme file/directory paths |
| `monitors` | string\|array | Monitor config paths or inline array |
| `userConfig` | object | User-configurable values prompted at enable time |
| `channels` | array | Channel declarations for message injection |
| `dependencies` | array | Other plugins this plugin requires, optionally with semver constraints |

Custom paths replace defaults. To keep the default directory and add more, use an array: `"skills": ["./skills/", "./extras/"]`. All custom paths must be relative and start with `./`.

### Environment variables in plugin configs

| Variable | Description |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin's installation directory (changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory that survives updates (`~/.claude/plugins/data/{id}/`) |
| `${user_config.KEY}` | User-configured values from `userConfig`; also exported as `CLAUDE_PLUGIN_OPTION_<KEY>` |

Both variables are substituted in skill content, agent content, hook commands, monitor commands, and MCP/LSP server configs, and are exported to subprocesses.

### User configuration (`userConfig`)

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
| :--- | :--- | :--- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label in configuration dialog |
| `description` | Yes | Help text |
| `sensitive` | No | Masks input; stores in system keychain instead of settings.json |
| `required` | No | Validation fails when empty |
| `default` | No | Value when user provides nothing |
| `multiple` | No | For `string`: allow array of strings |
| `min`/`max` | No | Bounds for `number` type |

### Plugin agents (frontmatter fields)

Plugin agents support: `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation` (only valid value: `"worktree"`). Not supported for security reasons: `hooks`, `mcpServers`, `permissionMode`.

### Hooks in plugins

Place in `hooks/hooks.json` or inline in `plugin.json`. Format is identical to user-defined hooks. Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`.

Hook events include: `SessionStart`, `UserPromptSubmit`, `UserPromptExpansion`, `PreToolUse`, `PermissionRequest`, `PermissionDenied`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Notification`, `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `Stop`, `StopFailure`, `TeammateIdle`, `InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `FileChanged`, `WorktreeCreate`, `WorktreeRemove`, `PreCompact`, `PostCompact`, `Elicitation`, `ElicitationResult`, `SessionEnd`.

### Monitors

Declared in `monitors/monitors.json` as a JSON array. Each monitor runs a shell command for the session lifetime; every stdout line is delivered to Claude as a notification.

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier within the plugin |
| `command` | Yes | Shell command run as a persistent background process |
| `description` | Yes | Short summary; shown in task panel |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

Requires Claude Code v2.1.105 or later. Monitors run only in interactive CLI sessions.

### LSP server config fields

Required: `command`, `extensionToLanguage`. Optional: `args`, `transport` (`stdio` or `socket`), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`.

Available official LSP plugins: `pyright-lsp`, `typescript-lsp`, `rust-analyzer-lsp`, `gopls-lsp`, `clangd-lsp`, `csharp-lsp`, `jdtls-lsp`, `kotlin-lsp`, `lua-lsp`, `php-lsp`, `swift-lsp`.

### Themes

Shipped as JSON files in `themes/`. Each has `name`, `base` (preset name), and `overrides` (sparse map of color tokens). Plugin themes are read-only in `/theme`; press `Ctrl+E` to copy to `~/.claude/themes/` for editing.

### Plugin installation scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` (default) | `~/.claude/settings.json` | Personal, all projects |
| `project` | `.claude/settings.json` | Team-shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled, read-only |

### Plugin caching

Marketplace plugins are copied to `~/.claude/plugins/cache`. Plugins cannot reference files outside their directory (`../shared-utils` will not work). Use symlinks for external file access. Previous version directories are removed 7 days after an update.

### Version management

Version resolution order:
1. `version` in `plugin.json`
2. `version` in marketplace entry
3. Git commit SHA (for git-based sources)
4. `unknown` (npm or local non-git)

Explicit version: bump on every release or users won't get updates. Commit-SHA: every new commit is a new version (useful for active development).

### CLI commands

| Command | Description |
| :--- | :--- |
| `claude plugin install <plugin>[@marketplace]` | Install a plugin |
| `claude plugin uninstall <plugin>` | Remove a plugin (`--keep-data`, `--prune`, `-y`) |
| `claude plugin enable <plugin>` | Enable a disabled plugin |
| `claude plugin disable <plugin>` | Disable without uninstalling |
| `claude plugin update <plugin>` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin prune [--dry-run] [-y]` | Remove orphaned auto-installed dependencies (v2.1.121+) |
| `claude plugin tag [--push] [--dry-run] [-f]` | Create release git tag from plugin root |
| `claude plugin validate .` | Validate plugin.json, frontmatter, hooks.json |

All install/uninstall/enable/disable/update commands accept `-s, --scope <scope>`.

### Marketplace management commands

| Command | Description |
| :--- | :--- |
| `claude plugin marketplace add <source>` | Add a marketplace (GitHub `owner/repo`, git URL, local path, remote URL) |
| `claude plugin marketplace list [--json]` | List configured marketplaces |
| `claude plugin marketplace remove <name>` | Remove marketplace (also uninstalls its plugins) |
| `claude plugin marketplace update [name]` | Refresh marketplace listings |

In-session equivalents: `/plugin marketplace add`, `/plugin`, `/reload-plugins`.

### Marketplace schema

`marketplace.json` required fields: `name` (kebab-case, unique), `owner` (object with `name`), `plugins` (array).

Plugin entry required fields: `name`, `source`. Plugin source types:

| Type | Format | Notes |
| :--- | :--- | :--- |
| Relative path | `"./my-plugin"` | Within marketplace repo; requires git-based marketplace |
| `github` | `{"source":"github","repo":"owner/repo","ref?":"...","sha?":"..."}` | |
| `url` | `{"source":"url","url":"https://...","ref?":"...","sha?":"..."}` | Any git host |
| `git-subdir` | `{"source":"git-subdir","url":"...","path":"...","ref?":"...","sha?":"..."}` | Sparse clone; efficient for monorepos |
| `npm` | `{"source":"npm","package":"@org/pkg","version?":"...","registry?":"..."}` | |

### Dependency version constraints

Declare in `plugin.json` `dependencies` array:

```json
"dependencies": [
  "audit-logger",
  { "name": "secrets-vault", "version": "~2.1.0" }
]
```

`version` accepts any semver range (`~2.1.0`, `^2.0`, `>=1.4`, `=2.1.0`). Requires Claude Code v2.1.110+.

Version resolution uses git tags named `{plugin-name}--v{version}`. Create with `claude plugin tag --push` from the plugin directory.

Cross-marketplace dependencies require `allowCrossMarketplaceDependenciesOn` in the root marketplace's `marketplace.json`.

Dependency errors:

| Error | Meaning | Fix |
| :--- | :--- | :--- |
| `dependency-unsatisfied` | Dependency not installed or disabled | Run the install command shown in the error |
| `range-conflict` | Multiple plugins need incompatible versions | Uninstall/update one conflicting plugin |
| `dependency-version-unsatisfied` | Installed version outside declared range | Re-run `claude plugin install <dep>@<marketplace>` |
| `no-matching-tag` | No `{name}--v*` tag satisfying the range | Check upstream tags or relax range |

### Common troubleshooting

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` |
| Skills not appearing | Wrong directory structure | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Script not executable | `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use the variable for all plugin paths |
| LSP `Executable not found in $PATH` | Language server binary not installed | Install the binary (e.g., `npm install -g typescript-language-server`) |

Debug with `claude --debug` to see plugin loading details, skill/agent registration, and MCP server initialization.

### Managed marketplace restrictions (`strictKnownMarketplaces`)

| Value | Behavior |
| :--- | :--- |
| Undefined (default) | No restrictions |
| `[]` | Complete lockdown — no new marketplaces |
| List of sources | Users can only add listed marketplaces |

Source types for allowlist: `github` (with `repo`, optional `ref`/`path`), `url` (exact URL), `hostPattern` (regex on host), `pathPattern` (regex on path).

### Container pre-population

Set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a directory mirroring `~/.claude/plugins` (with `known_marketplaces.json`, `marketplaces/`, `cache/`). Seed directories are read-only; auto-updates are disabled for seed marketplaces. Build with `CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/seed claude plugin install ...`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — creating plugins with skills, agents, hooks, MCP servers, LSP servers, and monitors; quickstart; plugin structure; testing with `--plugin-dir`; converting standalone configs to plugins
- [Plugins reference](references/claude-code-plugins-reference.md) — complete technical specifications: manifest schema, component schemas, CLI commands, environment variables, caching, directory structure, debugging, and version management
- [Discover and install plugins](references/claude-code-discover-plugins.md) — browsing the official marketplace, adding marketplaces, installing plugins, managing installed plugins, scopes, auto-updates, team marketplace configuration, security, and troubleshooting
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace file schema, plugin sources, hosting options, private repositories, container pre-population, managed marketplace restrictions, version resolution, release channels, validation, and CLI management commands
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring dependencies with version ranges, cross-marketplace dependencies, tagging releases, constraint intersection, pruning orphaned dependencies, and resolving dependency errors

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
