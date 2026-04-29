---
name: plugins-doc
description: Complete official documentation for Claude Code plugins — creating plugins with skills/agents/hooks/MCP/LSP servers/monitors/themes, the plugin manifest schema, discovering and installing plugins, marketplace creation and distribution, plugin dependency version constraints, and CLI commands for plugin management.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for the Claude Code plugin system.

## Quick Reference

Plugins are self-contained directories that extend Claude Code with skills, agents, hooks, MCP servers, LSP servers, monitors, and themes. They can be shared via marketplaces and installed at user, project, or local scope.

### Standalone vs plugin

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, single-project customizations |
| **Plugin** (directory with `.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teams, distributing via marketplace, versioned releases |

### Plugin directory structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json        # Manifest (only file that goes here)
├── skills/                # Skills as <name>/SKILL.md directories
├── commands/              # Skills as flat .md files (legacy; prefer skills/)
├── agents/                # Subagent definitions
├── hooks/
│   └── hooks.json         # Hook configuration
├── .mcp.json              # MCP server definitions
├── .lsp.json              # LSP server configurations
├── monitors/
│   └── monitors.json      # Background monitor configurations
├── themes/                # Color theme JSON files
├── output-styles/         # Output style definitions
├── bin/                   # Executables added to Bash PATH
└── settings.json          # Default settings (only agent/subagentStatusLine keys supported)
```

**Warning**: Only `plugin.json` goes inside `.claude-plugin/`. All other directories must be at the plugin root.

### Plugin manifest schema (`plugin.json`)

`name` is the only required field when a manifest is present. The manifest itself is optional — Claude Code auto-discovers components from default locations.

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique identifier (kebab-case). Used as skill namespace prefix. |
| `version` | string | Semantic version. If set, users only get updates when you bump it. If omitted, git commit SHA is used. |
| `description` | string | Brief explanation of plugin purpose |
| `author` | object | `name`, `email`, `url` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier (e.g. `MIT`) |
| `keywords` | array | Discovery tags |
| `$schema` | string | JSON Schema URL for editor autocomplete; ignored at load time |
| `skills` | string/array | Custom skill directories (replaces default `skills/`) |
| `commands` | string/array | Custom flat `.md` files or directories |
| `agents` | string/array | Custom agent files |
| `hooks` | string/array/object | Hook config paths or inline config |
| `mcpServers` | string/array/object | MCP config paths or inline config |
| `lspServers` | string/array/object | LSP server configurations |
| `outputStyles` | string/array | Custom output style files |
| `themes` | string/array | Color theme files (replaces default `themes/`) |
| `monitors` | string/array | Background monitor configurations |
| `userConfig` | object | User-configurable values prompted at enable time |
| `channels` | array | Message channel declarations (Telegram, Slack, Discord) |
| `dependencies` | array | Other plugins this plugin requires |

### Environment variables in plugin configs

| Variable | Description |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin installation directory. Changes on update. |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory that survives plugin updates (`~/.claude/plugins/data/{id}/`). Created automatically. |
| `${user_config.KEY}` | User-configured values from `userConfig`. Also exported as `CLAUDE_PLUGIN_OPTION_<KEY>`. |

### User configuration (`userConfig`)

Declares values Claude Code prompts users for when the plugin is enabled.

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label shown in the config dialog |
| `description` | Yes | Help text shown beneath the field |
| `sensitive` | No | If `true`, masks input and stores in system keychain (~2 KB limit) |
| `required` | No | Validation fails if field is empty |
| `default` | No | Value used when user provides nothing |
| `multiple` | No | For `string` type, allow an array of strings |
| `min`/`max` | No | Bounds for `number` type |

Values available as `${user_config.KEY}` in hook commands, MCP/LSP configs, and monitor commands. Non-sensitive values also substituted in skill/agent content.

### Plugin installation scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` | `~/.claude/settings.json` | Personal plugins across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled, read-only |

### CLI commands

| Command | Description |
| :--- | :--- |
| `claude plugin install <plugin> [--scope user\|project\|local]` | Install a plugin |
| `claude plugin uninstall <plugin> [--keep-data] [--prune]` | Remove a plugin |
| `claude plugin enable <plugin>` | Enable a disabled plugin |
| `claude plugin disable <plugin>` | Disable without uninstalling |
| `claude plugin update <plugin>` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin prune [--dry-run] [-y]` | Remove orphaned auto-installed dependencies (v2.1.121+) |
| `claude plugin tag [--push] [--dry-run]` | Create release git tag for version resolution |
| `claude plugin validate .` | Validate plugin manifest and component files |

### Marketplace CLI commands

| Command | Description |
| :--- | :--- |
| `claude plugin marketplace add <source> [--scope] [--sparse]` | Add a marketplace |
| `claude plugin marketplace list [--json]` | List configured marketplaces |
| `claude plugin marketplace update [name]` | Refresh marketplace listings |
| `claude plugin marketplace remove <name>` | Remove a marketplace (also uninstalls its plugins) |

In-session commands use `/plugin` prefix (e.g. `/plugin install`, `/plugin marketplace add`).

### Marketplace sources (for plugin `source` field in `marketplace.json`)

| Source type | Example | Notes |
| :--- | :--- | :--- |
| Relative path | `"./plugins/my-plugin"` | Must start with `./`. Only works with git-hosted marketplaces. |
| `github` | `{"source": "github", "repo": "owner/repo", "ref?": "...", "sha?": "..."}` | |
| `url` | `{"source": "url", "url": "https://...", "ref?": "...", "sha?": "..."}` | |
| `git-subdir` | `{"source": "git-subdir", "url": "...", "path": "tools/plugin", "ref?": "...", "sha?": "..."}` | Sparse clone; good for monorepos |
| `npm` | `{"source": "npm", "package": "@org/plugin", "version?": "...", "registry?": "..."}` | |

### Hook events (for plugins)

Plugins use `hooks/hooks.json` (same format as user hooks). All events:

| Event | When it fires |
| :--- | :--- |
| `SessionStart` | Session begins or resumes |
| `Setup` | With `--init-only` or `--init`/`--maintenance` in `-p` mode |
| `UserPromptSubmit` | When user submits a prompt, before Claude processes it |
| `UserPromptExpansion` | When a user-typed command expands into a prompt (can block) |
| `PreToolUse` | Before a tool executes (can block) |
| `PermissionRequest` | When a permission dialog appears |
| `PermissionDenied` | When a tool call is denied by auto mode classifier |
| `PostToolUse` | After a tool succeeds |
| `PostToolUseFailure` | After a tool fails |
| `PostToolBatch` | After a full batch of parallel tool calls, before next model call |
| `Notification` | When Claude Code sends a notification |
| `SubagentStart` | When a subagent is spawned |
| `SubagentStop` | When a subagent finishes |
| `TaskCreated` | When a task is being created via `TaskCreate` |
| `TaskCompleted` | When a task is being marked as completed |
| `Stop` | When Claude finishes responding |
| `StopFailure` | When the turn ends due to an API error |
| `TeammateIdle` | When an agent team teammate is about to go idle |
| `InstructionsLoaded` | When a CLAUDE.md or `.claude/rules/*.md` file is loaded |
| `ConfigChange` | When a configuration file changes during a session |
| `CwdChanged` | When the working directory changes |
| `FileChanged` | When a watched file changes on disk (matcher = filename pattern) |
| `WorktreeCreate` | When a worktree is being created (replaces default git behavior) |
| `WorktreeRemove` | When a worktree is being removed |
| `PreCompact` | Before context compaction |
| `PostCompact` | After context compaction completes |
| `Elicitation` | When an MCP server requests user input during a tool call |
| `ElicitationResult` | After a user responds to an MCP elicitation |
| `SessionEnd` | When a session terminates |

Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`.

### Monitors

Background processes that deliver stdout lines to Claude as notifications. Require Claude Code v2.1.105+.

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique within plugin; prevents duplicate processes on reload |
| `command` | Yes | Shell command run as persistent background process |
| `description` | Yes | Shown in task panel and notification summaries |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

Supports `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`, `${user_config.*}`, and env vars. Location: `monitors/monitors.json` or inline in `plugin.json`.

### Themes

Plugins can ship color themes (appear in `/theme`). Format: JSON file in `themes/` with a `base` preset and sparse `overrides` map.

```json
{
  "name": "Dracula",
  "base": "dark",
  "overrides": {
    "claude": "#bd93f9",
    "error": "#ff5555",
    "success": "#50fa7b"
  }
}
```

Selecting a plugin theme persists `custom:<plugin-name>:<slug>` in user config. Plugin themes are read-only; `Ctrl+E` copies to `~/.claude/themes/` for editing.

### Plugin dependency version constraints

Declare dependencies in `plugin.json`:

```json
{
  "dependencies": [
    "audit-logger",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```

Dependency fields:

| Field | Description |
| :--- | :--- |
| `name` | Plugin name. Required. |
| `version` | Semver range (`~2.1.0`, `^2.0`, `>=1.4`, `=2.1.0`). Resolved against `{plugin-name}--v{version}` git tags. |
| `marketplace` | Override to resolve from a different marketplace (must be in `allowCrossMarketplaceDependenciesOn`). |

Tag releases with: `claude plugin tag --push` (creates `{plugin-name}--v{version}` tag).

Dependency errors:

| Error | Meaning | Resolution |
| :--- | :--- | :--- |
| `dependency-unsatisfied` | Dependency not installed or disabled | Run install command shown in error |
| `range-conflict` | Version ranges are incompatible | Uninstall or update one conflicting plugin |
| `dependency-version-unsatisfied` | Installed version outside declared range | Re-run `claude plugin install <dep>@<marketplace>` |
| `no-matching-tag` | No tag satisfying the range | Check upstream tags or relax range |

### Version management

Version is resolved in this order:
1. `version` in `plugin.json`
2. `version` in the marketplace entry
3. Git commit SHA (for git-backed sources: `github`, `url`, `git-subdir`, relative paths)
4. `"unknown"` (npm or non-git local sources)

Set explicit `version` for stable release cycles. Omit for commit-SHA versioning (every commit is a new version). If both `plugin.json` and the marketplace entry set `version`, `plugin.json` wins.

### Official marketplace plugins

**Code intelligence (LSP):**

| Plugin | Language server |
| :--- | :--- |
| `pyright-lsp` | Python (Pyright) |
| `typescript-lsp` | TypeScript Language Server |
| `rust-analyzer-lsp` | rust-analyzer |
| `gopls-lsp` | Go |
| `clangd-lsp` | C/C++ |
| `csharp-lsp` | C# |
| `jdtls-lsp` | Java |
| `kotlin-lsp` | Kotlin |
| `lua-lsp` | Lua |
| `php-lsp` | PHP |
| `swift-lsp` | Swift |

Install the language server binary first; then install the plugin. If you see `Executable not found in $PATH`, install the binary.

**External integrations (MCP):** `github`, `gitlab`, `atlassian`, `asana`, `linear`, `notion`, `figma`, `vercel`, `firebase`, `supabase`, `slack`, `sentry`

**Development workflows:** `commit-commands`, `pr-review-toolkit`, `agent-sdk-dev`, `plugin-dev`

**Output styles:** `explanatory-output-style`, `learning-output-style`

### Testing plugins locally

```bash
claude --plugin-dir ./my-plugin
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

Use `/reload-plugins` to pick up changes without restarting. Use `claude --debug` to see plugin loading details. When `--plugin-dir` and an installed plugin share a name, the local copy takes precedence.

### Common debugging issues

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` or `/plugin validate` |
| Skills not appearing | Wrong directory structure | Move `skills/` to plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Script not executable | `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin paths |
| LSP `Executable not found` | Language server not installed | Install binary (e.g. `npm install -g typescript-language-server`) |
| Path errors | Absolute paths used | All paths must be relative and start with `./` |

### Managed marketplace restrictions (`strictKnownMarketplaces`)

| Value | Behavior |
| :--- | :--- |
| Undefined (default) | No restrictions; users can add any marketplace |
| `[]` (empty array) | Complete lockdown; no new marketplaces |
| List of sources | Only matching marketplaces allowed |

Supports `github`, `url`, `hostPattern` (regex on host), and `pathPattern` (regex on path) source types. Pair with `extraKnownMarketplaces` to auto-register allowed marketplaces.

### Container pre-population

Set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a pre-built plugins directory to skip runtime cloning. To layer multiple seed directories, separate paths with `:` (Unix) or `;` (Windows). Structure mirrors `~/.claude/plugins`. Seed entries are read-only; auto-updates are disabled for seed marketplaces. Set `CLAUDE_CODE_PLUGIN_CACHE_DIR` at build time to install directly to the seed path.

Additional environment variables:
- `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE=1` — keep stale marketplace cache on `git pull` failure (useful for offline environments)
- `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS=<ms>` — override the default 120s git operation timeout

### Marketplace schema quick reference

```json
{
  "name": "company-tools",
  "owner": { "name": "DevTools Team", "email": "devtools@example.com" },
  "plugins": [
    {
      "name": "code-formatter",
      "source": "./plugins/formatter",
      "description": "...",
      "version": "2.1.0"
    }
  ]
}
```

Optional marketplace-level fields: `description`, `version`, `metadata.pluginRoot`, `allowCrossMarketplaceDependenciesOn`.

Plugin entry `strict` field: `true` (default) — `plugin.json` is authority, marketplace entry supplements. `false` — marketplace entry is the entire definition; plugin must not have its own component declarations in `plugin.json`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — quickstart, plugin structure, adding skills/agents/LSP/monitors/hooks/MCP servers, default settings, testing locally, debugging, migrating from standalone configuration, and distributing plugins
- [Plugins reference](references/claude-code-plugins-reference.md) — complete technical specifications: all component schemas, plugin manifest schema, user configuration, channels, environment variables, persistent data directory, plugin caching and file resolution, directory structure, CLI commands reference, debugging tools, version management
- [Discover and install plugins](references/claude-code-discover-plugins.md) — official marketplace, code intelligence plugins, external integrations, adding marketplaces from GitHub/Git/local/URL, installing plugins, managing scopes, configure team marketplaces, auto-updates, security, troubleshooting
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace file schema, plugin entries, plugin sources (github/url/git-subdir/npm/relative), strict mode, hosting on GitHub and private repos, team configuration, container pre-population, managed marketplace restrictions, version resolution and release channels, CLI marketplace commands, troubleshooting
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring dependencies with semver ranges in `plugin.json`, cross-marketplace dependencies, tagging releases, constraint intersection, pruning orphaned auto-installed dependencies, dependency error reference

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
