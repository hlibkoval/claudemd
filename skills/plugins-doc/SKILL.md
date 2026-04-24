---
name: plugins-doc
description: Complete official documentation for the Claude Code plugin system — creating plugins, plugin manifest schema, plugin components (skills, agents, hooks, MCP servers, LSP servers, monitors, themes), discovering and installing plugins from marketplaces, creating and distributing marketplaces, plugin dependency version constraints, CLI commands, and debugging.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for the Claude Code plugin system.

## Quick Reference

Plugins extend Claude Code with custom skills, agents, hooks, MCP servers, LSP servers, monitors, and themes. A plugin is a directory with a `.claude-plugin/plugin.json` manifest and component subdirectories at the plugin root.

### Standalone configuration vs. plugins

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific customizations, quick experiments |
| **Plugins** (`.claude-plugin/plugin.json` directory) | `/plugin-name:hello` | Sharing with teammates, distributing to community, versioned releases, reusable across projects |

### Plugin directory structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json         # Manifest (optional; name is only required field)
├── skills/                 # Skills: <name>/SKILL.md directories
├── commands/               # Skills as flat .md files (legacy; prefer skills/)
├── agents/                 # Subagent Markdown definitions
├── hooks/
│   └── hooks.json          # Hook event handlers
├── monitors/
│   └── monitors.json       # Background monitors
├── themes/                 # Color theme JSON files
├── output-styles/          # Output style definitions
├── bin/                    # Executables added to Bash tool's PATH
├── settings.json           # Default settings (agent, subagentStatusLine only)
├── .mcp.json               # MCP server configurations
└── .lsp.json               # LSP server configurations
```

### plugin.json manifest schema

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Required. Kebab-case unique identifier; sets skill namespace (`/name:skill`) |
| `version` | string | Semantic version. If set, users only receive updates when bumped. If omitted, git commit SHA is used |
| `description` | string | Brief explanation of plugin purpose |
| `author` | object | `{name, email, url}` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX license identifier |
| `keywords` | array | Discovery tags |
| `skills` | string/array | Custom path(s) to skill directories (replaces default `skills/`) |
| `commands` | string/array | Custom path(s) to flat .md skill files (replaces default `commands/`) |
| `agents` | string/array | Custom path(s) to agent files |
| `hooks` | string/array/object | Hook config paths or inline config |
| `mcpServers` | string/array/object | MCP config paths or inline config |
| `lspServers` | string/array/object | LSP config paths or inline config |
| `outputStyles` | string/array | Output style files/directories |
| `themes` | string/array | Color theme files/directories |
| `monitors` | string/array | Background monitor configurations |
| `userConfig` | object | User-configurable values prompted at enable time |
| `channels` | array | Channel declarations (Telegram/Slack/Discord message injection) |
| `dependencies` | array | Other plugins this plugin requires, with optional semver constraints |

### userConfig field schema

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | One of `string`, `number`, `boolean`, `directory`, `file` |
| `title` | Yes | Label shown in the configuration dialog |
| `description` | Yes | Help text shown beneath the field |
| `sensitive` | No | If `true`, masks input and stores in secure storage |
| `required` | No | If `true`, validation fails when field is empty |
| `default` | No | Value used when user provides nothing |
| `multiple` | No | For `string` type, allow an array of strings |
| `min`/`max` | No | Bounds for `number` type |

Values are available as `${user_config.KEY}` in MCP/LSP/hook/monitor configs and exported as `CLAUDE_PLUGIN_OPTION_<KEY>` to subprocesses.

### Plugin environment variables

| Variable | Description |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to the plugin's installation directory. Changes on update |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state that survives updates (`~/.claude/plugins/data/{id}/`) |

### Hook events (plugin hooks)

Plugin hooks use the same events as user-defined hooks, declared in `hooks/hooks.json` or inline in `plugin.json`:

| Event | When it fires |
| :--- | :--- |
| `SessionStart` / `SessionEnd` | Session begins/terminates |
| `UserPromptSubmit` | Before Claude processes a prompt |
| `PreToolUse` / `PostToolUse` | Before/after a tool call |
| `PostToolBatch` | After a full batch of parallel tool calls |
| `SubagentStart` / `SubagentStop` | When a subagent is spawned/finishes |
| `Stop` / `StopFailure` | When Claude finishes responding / turn ends on API error |
| `FileChanged` | When a watched file changes (`matcher` specifies filenames) |
| `ConfigChange` | When a configuration file changes during a session |
| `CwdChanged` | When the working directory changes |
| `PreCompact` / `PostCompact` | Before/after context compaction |
| `WorktreeCreate` / `WorktreeRemove` | Worktree lifecycle |
| `InstructionsLoaded` | When a CLAUDE.md or rules file is loaded |
| `Elicitation` / `ElicitationResult` | MCP server user input request lifecycle |
| `TaskCreated` / `TaskCompleted` | Task lifecycle |
| `TeammateIdle` | Agent team teammate about to go idle |

Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`

### Monitors

Background monitors start automatically when the plugin is active. Defined in `monitors/monitors.json` (or inline in `plugin.json`):

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

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier within the plugin |
| `command` | Yes | Shell command run as a persistent background process |
| `description` | Yes | Short summary of what is being watched |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

Requires Claude Code v2.1.105 or later.

### LSP server schema

Configured in `.lsp.json` or inline in `plugin.json` under `lspServers`:

| Field | Required | Description |
| :--- | :--- | :--- |
| `command` | Yes | LSP binary to execute (must be in PATH) |
| `extensionToLanguage` | Yes | Maps file extensions to language identifiers |
| `args` | No | Command-line arguments |
| `transport` | No | `stdio` (default) or `socket` |
| `env` | No | Environment variables |
| `initializationOptions` | No | Options passed during initialization |
| `settings` | No | Passed via `workspace/didChangeConfiguration` |
| `restartOnCrash` | No | Whether to auto-restart if server crashes |
| `maxRestarts` | No | Maximum restart attempts |

### Official LSP plugins (from official marketplace)

| Plugin | Language server | Binary required |
| :--- | :--- | :--- |
| `pyright-lsp` | Pyright | `pyright-langserver` |
| `typescript-lsp` | TypeScript LS | `typescript-language-server` |
| `rust-analyzer-lsp` | rust-analyzer | `rust-analyzer` |
| `gopls-lsp` | gopls | `gopls` |
| `clangd-lsp` | clangd | `clangd` |
| `csharp-lsp` | csharp-ls | `csharp-ls` |
| `kotlin-lsp` | kotlin-language-server | `kotlin-language-server` |
| `jdtls-lsp` | jdtls | `jdtls` |

### Plugin installation scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` | `~/.claude/settings.json` | Personal plugins across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Read-only, admin-controlled |

### CLI commands

```bash
# Plugin management
claude plugin install <plugin>[@marketplace] [--scope user|project|local]
claude plugin uninstall <plugin>[@marketplace] [--scope] [--keep-data]
claude plugin enable <plugin>[@marketplace] [--scope]
claude plugin disable <plugin>[@marketplace] [--scope]
claude plugin update <plugin>[@marketplace] [--scope]
claude plugin list [--json] [--available]
claude plugin tag [--push] [--dry-run] [--force]

# Marketplace management
claude plugin marketplace add <source> [--scope] [--sparse <paths...>]
claude plugin marketplace list [--json]
claude plugin marketplace remove <name>
claude plugin marketplace update [name]
```

In-session equivalents: `/plugin install`, `/plugin marketplace add`, `/reload-plugins`, `/plugin validate`, etc.

### Marketplace sources (plugin.json / marketplace.json)

| Source type | Format | Notes |
| :--- | :--- | :--- |
| Relative path | `"./plugins/my-plugin"` | Only works in git-hosted marketplaces |
| `github` | `{source, repo, ref?, sha?}` | GitHub `owner/repo` format |
| `url` | `{source, url, ref?, sha?}` | Any git URL |
| `git-subdir` | `{source, url, path, ref?, sha?}` | Subdirectory of a git repo (sparse clone) |
| `npm` | `{source, package, version?, registry?}` | npm package |

### Version management

Version resolution order (first match wins):
1. `version` in `plugin.json`
2. `version` in the marketplace entry
3. Git commit SHA (for git-backed sources)
4. `unknown` (npm or non-git local)

If `version` is set, bump it on every release or users won't receive updates.

### Plugin dependency constraints

Declare in `dependencies` array in `plugin.json`:

```json
{
  "dependencies": [
    "audit-logger",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```

Accepts Node semver ranges (`~2.1.0`, `^2.0`, `>=1.4`, `=2.1.0`). Version resolution uses git tags in the format `{plugin-name}--v{version}`. Use `claude plugin tag --push` to create release tags.

Cross-marketplace dependencies require the root marketplace to declare `allowCrossMarketplaceDependenciesOn` in `marketplace.json`.

### Managed marketplace restrictions (strictKnownMarketplaces)

| Value | Behavior |
| :--- | :--- |
| Undefined (default) | No restrictions |
| Empty array `[]` | Complete lockdown — no new marketplaces |
| List of sources | Only listed marketplaces allowed |

Supports `github`, `url`, `hostPattern` (regex on host), and `pathPattern` (regex on filesystem path) source types.

### Common debugging issues

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` or `/plugin validate` |
| Skills not appearing | Wrong directory structure | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Script not executable | Run `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin paths |
| LSP `Executable not found` | Language server not installed | Install the required binary |
| Path errors | Absolute paths used | All paths must be relative and start with `./` |

### Testing plugins locally

```bash
# Load a plugin for a session
claude --plugin-dir ./my-plugin

# Load multiple plugins
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

Use `/reload-plugins` after making changes to pick up updates without restarting.

### Convert standalone configuration to a plugin

| Standalone (`.claude/`) | Plugin |
| :--- | :--- |
| Files in `.claude/commands/` | Files in `plugin-name/commands/` |
| Hooks in `settings.json` | Hooks in `hooks/hooks.json` |
| Only available in one project | Can be shared via marketplaces |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — guide to creating plugins: quickstart, plugin structure, adding skills/LSP servers/monitors/settings, testing locally, debugging, converting from standalone configuration
- [Plugins reference](references/claude-code-plugins-reference.md) — complete technical reference: all component schemas, CLI commands, manifest schema, environment variables, plugin caching, directory structure, version management, debugging tools
- [Discover and install plugins](references/claude-code-discover-plugins.md) — finding and installing plugins from marketplaces, official Anthropic marketplace, managing installed plugins, marketplace management, auto-updates, team configuration
- [Create and distribute a marketplace](references/claude-code-plugin-marketplaces.md) — creating marketplace.json, hosting on GitHub/git services, private repositories, managed marketplace restrictions, release channels, container pre-population, troubleshooting
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring version constraints, cross-marketplace dependencies, tagging releases, constraint intersection, resolving dependency errors

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
