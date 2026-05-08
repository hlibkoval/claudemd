---
name: plugins-doc
description: Complete official documentation for Claude Code plugins — creating plugins, plugin manifest schema, plugin components (skills, agents, hooks, MCP/LSP servers, monitors, themes), discovering and installing plugins, marketplaces, plugin sources, installation scopes, version management, dependency constraints, CLI commands, and troubleshooting.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

### Standalone vs Plugin

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` dir) | `/hello` | Personal workflows, single-project customizations |
| **Plugin** (dir with `.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teams, distributing, reusable across projects |

### Plugin Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json       # Manifest (optional — only file that goes here)
├── skills/               # Skills as <name>/SKILL.md
├── commands/             # Skills as flat .md files (legacy; prefer skills/)
├── agents/               # Subagent definitions
├── hooks/hooks.json      # Event handlers
├── .mcp.json             # MCP server configurations
├── .lsp.json             # LSP server configurations
├── monitors/monitors.json # Background monitors
├── themes/               # Color themes (experimental)
├── output-styles/        # Output style definitions
├── bin/                  # Executables added to Bash tool PATH
└── settings.json         # Default settings (agent, subagentStatusLine only)
```

### Plugin Manifest (`plugin.json`) Schema

**Location**: `.claude-plugin/plugin.json` — the manifest is optional; if omitted, components are auto-discovered.

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes (if manifest exists) | Unique kebab-case identifier; becomes skill namespace prefix |
| `version` | No | Semver string. Omit to use git commit SHA as version |
| `description` | No | Brief description shown in plugin manager |
| `author` | No | Object with `name`, `email`, `url` |
| `homepage` | No | Documentation URL |
| `repository` | No | Source code URL |
| `license` | No | SPDX license identifier |
| `keywords` | No | Array of discovery tags |
| `skills` | No | Custom path(s) to skills directory (replaces default `skills/`) |
| `commands` | No | Custom path(s) to flat .md skills (replaces default `commands/`) |
| `agents` | No | Custom path(s) to agent files (replaces default `agents/`) |
| `hooks` | No | Hook config path(s) or inline config |
| `mcpServers` | No | MCP config path(s) or inline config |
| `lspServers` | No | LSP config path(s) or inline config |
| `outputStyles` | No | Output style path(s) (replaces default `output-styles/`) |
| `experimental.themes` | No | Color theme path(s) (replaces default `themes/`) |
| `experimental.monitors` | No | Background monitor path(s) or inline array |
| `userConfig` | No | User-configurable values prompted at enable time |
| `channels` | No | Message channel declarations bound to MCP servers |
| `dependencies` | No | Other plugins this plugin requires (with optional semver constraints) |

### Environment Variables for Plugin Paths

| Variable | Description |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin's installation directory. Use in hooks, MCP/LSP configs, monitor commands |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state that survives updates (`~/.claude/plugins/data/{id}/`) |

### Plugin Components Summary

| Component | Default location | Key notes |
| :--- | :--- | :--- |
| Skills | `skills/<name>/SKILL.md` | Namespaced as `/plugin-name:skill-name` |
| Commands (legacy) | `commands/*.md` | Flat markdown files; use `skills/` for new plugins |
| Agents | `agents/*.md` | Supports `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation` (only `"worktree"`). No `hooks`, `mcpServers`, or `permissionMode` |
| Hooks | `hooks/hooks.json` | Same event types as user-defined hooks |
| MCP servers | `.mcp.json` | Start automatically when plugin enabled |
| LSP servers | `.lsp.json` | Requires language server binary installed separately |
| Monitors | `monitors/monitors.json` | Requires Claude Code v2.1.105+; runs in interactive sessions only |
| Themes | `themes/*.json` | `base` + `overrides` color token map; experimental |
| Executables | `bin/` | Added to Bash tool `PATH` while plugin enabled |
| Settings | `settings.json` | Only `agent` and `subagentStatusLine` keys supported |

### Hook Events Reference

| Event | When it fires |
| :--- | :--- |
| `SessionStart` | Session begins or resumes |
| `Setup` | `--init-only` or `--init`/`--maintenance` in `-p` mode |
| `UserPromptSubmit` | User submits a prompt |
| `UserPromptExpansion` | User command expands into prompt (can block) |
| `PreToolUse` | Before a tool call (can block) |
| `PermissionRequest` | Permission dialog appears |
| `PermissionDenied` | Tool call denied by auto mode classifier |
| `PostToolUse` | After tool call succeeds |
| `PostToolUseFailure` | After tool call fails |
| `PostToolBatch` | After parallel tool batch resolves |
| `Notification` | Claude Code sends a notification |
| `SubagentStart` / `SubagentStop` | Subagent spawned / finishes |
| `TaskCreated` / `TaskCompleted` | Task created / completed |
| `Stop` / `StopFailure` | Claude finishes / turn ends due to API error |
| `TeammateIdle` | Agent team teammate about to go idle |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded |
| `ConfigChange` | Configuration file changes during session |
| `CwdChanged` | Working directory changes |
| `FileChanged` | Watched file changes on disk |
| `WorktreeCreate` / `WorktreeRemove` | Worktree created / removed |
| `PreCompact` / `PostCompact` | Before / after context compaction |
| `Elicitation` / `ElicitationResult` | MCP server requests user input / user responds |
| `SessionEnd` | Session terminates |

### Installation Scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` (default) | `~/.claude/settings.json` | Personal, all projects |
| `project` | `.claude/settings.json` | Team, shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled, read-only |

### Official Marketplace LSP Plugins

| Language | Plugin | Binary required |
| :--- | :--- | :--- |
| C/C++ | `clangd-lsp` | `clangd` |
| C# | `csharp-lsp` | `csharp-ls` |
| Go | `gopls-lsp` | `gopls` |
| Java | `jdtls-lsp` | `jdtls` |
| Kotlin | `kotlin-lsp` | `kotlin-language-server` |
| Lua | `lua-lsp` | `lua-language-server` |
| PHP | `php-lsp` | `intelephense` |
| Python | `pyright-lsp` | `pyright-langserver` |
| Rust | `rust-analyzer-lsp` | `rust-analyzer` |
| Swift | `swift-lsp` | `sourcekit-lsp` |
| TypeScript | `typescript-lsp` | `typescript-language-server` |

### Plugin CLI Commands

| Command | Description |
| :--- | :--- |
| `claude plugin install <plugin> [--scope user|project|local]` | Install a plugin |
| `claude plugin uninstall <plugin> [--keep-data] [--prune]` | Remove a plugin |
| `claude plugin enable <plugin>` | Enable a disabled plugin |
| `claude plugin disable <plugin>` | Disable without uninstalling |
| `claude plugin update <plugin>` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin prune [--dry-run] [-y]` | Remove orphaned auto-installed dependencies (v2.1.121+) |
| `claude plugin tag [--push] [--dry-run] [--force]` | Create release git tag |
| `claude plugin validate [path]` | Validate plugin JSON/frontmatter |
| `claude plugin marketplace add <source>` | Add a marketplace |
| `claude plugin marketplace remove <name>` | Remove a marketplace |
| `claude plugin marketplace update [name]` | Refresh marketplace listings |
| `claude plugin marketplace list [--json]` | List configured marketplaces |

In-session equivalents: `/plugin install`, `/plugin marketplace add`, `/reload-plugins`, etc.

### Marketplace `marketplace.json` Schema

```json
{
  "name": "my-marketplace",
  "owner": { "name": "Your Name" },
  "description": "...",
  "plugins": [
    {
      "name": "plugin-name",
      "source": "./plugins/plugin-name",
      "description": "...",
      "version": "1.0.0"
    }
  ]
}
```

### Plugin Sources (in `marketplace.json`)

| Source type | Format | Key fields |
| :--- | :--- | :--- |
| Relative path | `"./my-plugin"` | Must start with `./`; only works with git-based marketplaces |
| GitHub | `{ "source": "github", "repo": "owner/repo" }` | `repo`, `ref?`, `sha?` |
| Git URL | `{ "source": "url", "url": "https://..." }` | `url`, `ref?`, `sha?` |
| Git subdirectory | `{ "source": "git-subdir", "url": "...", "path": "..." }` | `url`, `path`, `ref?`, `sha?` |
| npm | `{ "source": "npm", "package": "@org/pkg" }` | `package`, `version?`, `registry?` |

### Version Management

- **Explicit version**: set `"version": "2.1.0"` in `plugin.json`. Users only receive updates when you bump this field.
- **Commit-SHA version**: omit `version` from both `plugin.json` and marketplace entry. Every commit is a new version.
- `plugin.json` `version` always wins over marketplace entry `version`.

### Plugin Dependency Constraints

Declared in `plugin.json` `dependencies` array:

```json
{ "dependencies": ["audit-logger", { "name": "secrets-vault", "version": "~2.1.0" }] }
```

- Bare string: tracks latest version from marketplace.
- Object with `version`: semver range (tilde, caret, comparator, etc.).
- Object with `marketplace`: cross-marketplace dependency (requires `allowCrossMarketplaceDependenciesOn` in root marketplace).
- Tag releases as `{plugin-name}--v{version}` using `claude plugin tag --push`.
- Requires Claude Code v2.1.110+.

### `userConfig` Field

```json
{
  "userConfig": {
    "api_token": {
      "type": "string",
      "title": "API token",
      "description": "...",
      "sensitive": true
    }
  }
}
```

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label in configuration dialog |
| `description` | Yes | Help text |
| `sensitive` | No | Masks input; stores in system keychain |
| `required` | No | Fail validation if empty |
| `default` | No | Value when user provides nothing |
| `multiple` | No | Allow array of strings (string type only) |
| `min` / `max` | No | Bounds for number type |

Values available as `${user_config.KEY}` in configs and as `CLAUDE_PLUGIN_OPTION_<KEY>` env vars.

### Common Debugging

| Issue | Solution |
| :--- | :--- |
| Plugin not loading | `claude plugin validate` or `/plugin validate` |
| Skills not appearing | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | `chmod +x script.sh`; check event name case (e.g., `PostToolUse`) |
| MCP server fails | Use `${CLAUDE_PLUGIN_ROOT}` for all plugin paths |
| LSP binary not found | Install language server (`npm install -g typescript-language-server typescript`) |
| Path errors | All paths must be relative and start with `./` |

Run `claude --debug` to see plugin loading details.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — quickstart, plugin structure, adding skills/agents/hooks/MCP/LSP/monitors, testing locally, migrating from standalone, sharing and submitting plugins
- [Plugins reference](references/claude-code-plugins-reference.md) — complete technical specifications: component schemas, manifest schema, environment variables, installation scopes, CLI commands, debugging tools, version management
- [Discover and install plugins](references/claude-code-discover-plugins.md) — official marketplace, LSP plugins, browsing/installing/managing plugins, marketplace management, auto-updates, team configuration, security, troubleshooting
- [Plugin marketplaces](references/claude-code-plugin-marketplaces.md) — creating marketplace files, all source types, hosting on GitHub/GitLab/npm, private repos, pre-populating containers, managed restrictions, release channels, validation
- [Plugin dependencies](references/claude-code-plugin-dependencies.md) — version constraints, declaring dependencies, cross-marketplace dependencies, tagging releases, constraint intersection, pruning orphaned dependencies

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Plugin marketplaces: https://code.claude.com/docs/en/plugin-marketplaces.md
- Plugin dependencies: https://code.claude.com/docs/en/plugin-dependencies.md
