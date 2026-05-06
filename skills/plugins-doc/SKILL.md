---
name: plugins-doc
description: Complete official documentation for Claude Code plugins — plugin manifest schema, directory structure, components (skills, agents, hooks, MCP servers, LSP servers, monitors, themes), CLI commands (install, uninstall, enable, disable, update, list, prune, tag), marketplace creation and distribution, plugin sources, version management, user configuration, dependency constraints, installation scopes, environment variables (CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA), and plugin caching.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

### Standalone vs Plugin

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugins** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teams, distributing, versioned releases, reusable across projects |

### Plugin Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Manifest (optional)
├── skills/                  # Skills as <name>/SKILL.md directories
├── commands/                # Skills as flat .md files (legacy; prefer skills/)
├── agents/                  # Subagent definitions
├── hooks/hooks.json         # Hook configurations
├── .mcp.json                # MCP server definitions
├── .lsp.json                # LSP server configurations
├── monitors/monitors.json   # Background monitor configurations
├── output-styles/           # Output style definitions
├── themes/                  # Color theme definitions
├── bin/                     # Executables added to Bash tool PATH
└── settings.json            # Default settings (agent, subagentStatusLine only)
```

**Common mistake**: All component directories must be at the plugin root, NOT inside `.claude-plugin/`. Only `plugin.json` belongs in `.claude-plugin/`.

### Plugin Manifest Schema (`.claude-plugin/plugin.json`)

`name` is the only required field when a manifest is present. The manifest itself is optional — without it, Claude Code auto-discovers components from default locations and uses the directory name as the plugin name.

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Required. Unique identifier (kebab-case). Used as skill namespace prefix |
| `version` | string | Optional. Semver. Omit to use git commit SHA for auto-versioning |
| `description` | string | Shown in the plugin manager |
| `author` | object | `{name, email?, url?}` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier (e.g. `"MIT"`) |
| `keywords` | array | Discovery tags |
| `skills` | string\|array | Custom skill directory paths (replaces default `skills/`) |
| `commands` | string\|array | Custom flat `.md` skill file paths (replaces default `commands/`) |
| `agents` | string\|array | Custom agent file paths (replaces default `agents/`) |
| `hooks` | string\|array\|object | Hook config paths or inline config |
| `mcpServers` | string\|array\|object | MCP config paths or inline config |
| `lspServers` | string\|array\|object | LSP config paths or inline config |
| `outputStyles` | string\|array | Output style paths |
| `themes` | string\|array | Color theme paths |
| `monitors` | string\|array | Background monitor config paths or inline array |
| `userConfig` | object | User-configurable values prompted at enable time |
| `channels` | array | Channel declarations for message injection |
| `dependencies` | array | Other plugins this plugin requires |

### Environment Variables

| Variable | Points to |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin's installation directory (changes on update; treat as ephemeral) |
| `${CLAUDE_PLUGIN_DATA}` | Plugin's persistent data directory (survives updates, deleted on uninstall) |
| `CLAUDE_PLUGIN_OPTION_<KEY>` | User config values exported to plugin subprocesses |

`${CLAUDE_PLUGIN_DATA}` resolves to `~/.claude/plugins/data/{id}/`. Use it for `node_modules`, caches, and state that should persist across plugin versions.

### Plugin Components

#### Skills

- Location: `skills/<name>/SKILL.md` (or flat `.md` files in `commands/`)
- Namespaced: `/plugin-name:skill-name`
- Auto-discovered and model-invoked based on task context

#### Agents

- Location: `agents/<name>.md`
- Frontmatter fields: `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation`
- Only valid `isolation` value: `"worktree"`
- NOT supported for plugin agents: `hooks`, `mcpServers`, `permissionMode`

#### Hooks (`hooks/hooks.json`)

Same event system as user-defined hooks. Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`.

| Hook Event | Fires when |
| :--- | :--- |
| `SessionStart` | Session begins or resumes |
| `Setup` | `--init-only` or `--init`/`--maintenance` in `-p` mode |
| `UserPromptSubmit` | Prompt submitted before Claude processes it |
| `UserPromptExpansion` | Slash command expands, can block |
| `PreToolUse` | Before tool call, can block |
| `PermissionRequest` | Permission dialog appears |
| `PermissionDenied` | Tool call denied; return `{retry: true}` to allow model retry |
| `PostToolUse` | After tool call succeeds |
| `PostToolUseFailure` | After tool call fails |
| `PostToolBatch` | After full batch of parallel tool calls |
| `Notification` | Claude Code sends a notification |
| `SubagentStart` / `SubagentStop` | Subagent spawned / finished |
| `TaskCreated` / `TaskCompleted` | Task create/complete via `TaskCreate` |
| `Stop` / `StopFailure` | Claude finishes responding / API error |
| `TeammateIdle` | Agent team teammate about to go idle |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded |
| `ConfigChange` | Config file changes during session |
| `CwdChanged` | Working directory changes |
| `FileChanged` | Watched file changes (matcher = literal filenames) |
| `WorktreeCreate` / `WorktreeRemove` | Worktree created / removed |
| `PreCompact` / `PostCompact` | Before / after context compaction |
| `Elicitation` / `ElicitationResult` | MCP server requests / receives user input |
| `SessionEnd` | Session terminates |

#### MCP Servers (`.mcp.json`)

Start automatically when plugin is enabled. Use `${CLAUDE_PLUGIN_ROOT}` in command paths.

#### LSP Servers (`.lsp.json`)

Required `.lsp.json` fields: `command`, `extensionToLanguage`. Optional: `args`, `transport`, `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`.

Available official LSP plugins: `pyright-lsp`, `typescript-lsp`, `rust-analyzer-lsp`, `gopls-lsp`, `clangd-lsp`, `csharp-lsp`, `jdtls-lsp`, `kotlin-lsp`, `lua-lsp`, `php-lsp`, `swift-lsp`.

#### Monitors (`monitors/monitors.json`)

Background processes started automatically. Every stdout line delivered to Claude as notification. Requires Claude Code v2.1.105+.

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier within plugin |
| `command` | Yes | Shell command run as persistent background process |
| `description` | Yes | Short summary shown in task panel |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

#### Themes (`themes/`)

JSON files with `name`, `base` (preset: `"dark"` or `"light"`), and `overrides` (sparse map of color tokens). Appear in `/theme`. Read-only; `Ctrl+E` copies to `~/.claude/themes/` for editing.

### User Configuration (`userConfig`)

Declared values prompted at enable time. Each key supports:

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label shown in config dialog |
| `description` | Yes | Help text |
| `sensitive` | No | Masks input; stores in system keychain |
| `required` | No | Validation fails when empty |
| `default` | No | Value when user provides nothing |
| `multiple` | No | For `string`, allow array of strings |
| `min` / `max` | No | Bounds for `number` type |

Values available as `${user_config.KEY}` in MCP/LSP configs, hooks, and monitors. Exported as `CLAUDE_PLUGIN_OPTION_<KEY>` env vars.

### Installation Scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` | `~/.claude/settings.json` | Personal, all projects (default) |
| `project` | `.claude/settings.json` | Team plugins shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled, read-only |

### CLI Commands

| Command | Description |
| :--- | :--- |
| `claude plugin install <plugin> [--scope user\|project\|local]` | Install from marketplace |
| `claude plugin uninstall <plugin> [--keep-data] [--prune]` | Remove plugin |
| `claude plugin enable <plugin>` | Enable a disabled plugin |
| `claude plugin disable <plugin>` | Disable without uninstalling |
| `claude plugin update <plugin>` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin prune [--dry-run] [-y]` | Remove orphaned auto-installed dependencies (v2.1.121+) |
| `claude plugin tag [--push] [--dry-run] [-f]` | Create release git tag |
| `claude plugin validate [path]` | Validate plugin/marketplace JSON |
| `claude plugin marketplace add <source>` | Add a marketplace |
| `claude plugin marketplace list` | List configured marketplaces |
| `claude plugin marketplace remove <name>` | Remove a marketplace (also uninstalls its plugins) |
| `claude plugin marketplace update [name]` | Refresh marketplace listings |

Interactive UI: `/plugin` (tabs: Discover, Installed, Marketplaces, Errors). In-session: `/reload-plugins` to apply changes without restart.

### Testing Locally

```bash
claude --plugin-dir ./my-plugin
# Multiple plugins:
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

Local `--plugin-dir` plugins take precedence over same-named installed plugins. Use `/reload-plugins` to pick up changes mid-session.

### Debugging

| Issue | Cause | Fix |
| :--- | :--- | :--- |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` or `/plugin validate` |
| Skills not appearing | Wrong directory structure | Move `skills/`, `commands/` to plugin root (not inside `.claude-plugin/`) |
| Hooks not firing | Script not executable | `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin paths |
| Path errors | Absolute paths used | All paths must be relative, starting with `./` |
| LSP `Executable not found` | Language server not installed | Install the binary (e.g. `npm install -g typescript-language-server`) |

Use `claude --debug` to see plugin loading details.

### Marketplace Schema (`.claude-plugin/marketplace.json`)

Required: `name`, `owner` (`{name, email?}`), `plugins` (array).

| Plugin source type | `source` field | Key fields |
| :--- | :--- | :--- |
| Relative path | `"./plugins/my-plugin"` | Must start with `./`; only works with git-based marketplaces |
| GitHub | `{source: "github", repo: "owner/repo"}` | `ref?`, `sha?` |
| Git URL | `{source: "url", url: "https://..."}` | `ref?`, `sha?` |
| Git subdirectory | `{source: "git-subdir", url: "...", path: "..."}` | `ref?`, `sha?`; sparse checkout |
| npm | `{source: "npm", package: "@org/pkg"}` | `version?`, `registry?` |

### Version Management

Version is resolved from the first available source:
1. `version` in `plugin.json`
2. `version` in the marketplace entry
3. Git commit SHA (for git-based sources)
4. `"unknown"` (npm or non-git local)

Setting `version` pins users — they only receive updates when you bump the field. Omit `version` to auto-version by commit SHA.

### Dependency Constraints (`plugin.json`)

```json
{
  "dependencies": [
    "audit-logger",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```

Dependency object fields: `name` (required), `version` (semver range), `marketplace` (for cross-marketplace deps).

Tag releases with: `claude plugin tag --push` (creates `{plugin-name}--v{version}` git tags). Requires v2.1.110+.

| Dependency error | Meaning | Fix |
| :--- | :--- | :--- |
| `dependency-unsatisfied` | Dependency not installed or disabled | Run `claude plugin install <dep>` |
| `range-conflict` | Version ranges cannot be combined | Uninstall/update a conflicting plugin |
| `dependency-version-unsatisfied` | Installed version outside declared range | Re-run `claude plugin install <dep>@<marketplace>` |
| `no-matching-tag` | No git tag satisfying range | Check upstream tags or relax range |

### Pre-populating Plugins (Containers/CI)

```bash
# Build seed directory
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin marketplace add your-org/plugins
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin install my-tool@your-plugins
# Runtime: set CLAUDE_CODE_PLUGIN_SEED_DIR=/opt/claude-seed
```

Seed directories are read-only; auto-updates are disabled for seed marketplaces.

### Useful Environment Variables

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_PLUGIN_SEED_DIR` | Pre-populated plugins directory for containers (`:` separated) |
| `CLAUDE_CODE_PLUGIN_CACHE_DIR` | Override plugin cache location during build |
| `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE=1` | Retain stale cache on `git pull` failure (offline environments) |
| `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` | Git operation timeout in ms (default: 120000) |
| `DISABLE_AUTOUPDATER` | Disable all automatic updates |
| `FORCE_AUTOUPDATE_PLUGINS=1` | Keep plugin auto-updates when `DISABLE_AUTOUPDATER` is set |

### Managed Marketplace Restrictions (`strictKnownMarketplaces`)

| Value | Behavior |
| :--- | :--- |
| Undefined (default) | No restrictions; users can add any marketplace |
| `[]` | Complete lockdown; users cannot add new marketplaces |
| List of sources | Users can only add marketplaces matching the allowlist exactly |

Supports `github`, `url`, `hostPattern` (regex on host), and `pathPattern` (regex on path) source types.

### Submit to Official Marketplace

- Claude.ai: [claude.ai/settings/plugins/submit](https://claude.ai/settings/plugins/submit)
- Console: [platform.claude.com/plugins/submit](https://platform.claude.com/plugins/submit)

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — quickstart, plugin structure overview, adding skills/LSP servers/monitors/agents/hooks, default settings, testing locally, debugging, sharing, converting standalone config to plugins
- [Plugins reference](references/claude-code-plugins-reference.md) — complete component schemas, manifest schema, user configuration, channels, environment variables, caching, directory structure, CLI commands reference, debugging tools, version management
- [Discover and install plugins](references/claude-code-discover-plugins.md) — official marketplace, LSP plugin catalog, external integrations, managing installed plugins, marketplace management, auto-updates, team marketplace configuration, security, troubleshooting
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace schema, plugin sources (GitHub, git URL, git-subdir, npm, relative path), hosting, private repositories, pre-populating containers, managed restrictions, version resolution, release channels, validation, CLI marketplace commands, troubleshooting
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring dependencies, cross-marketplace dependencies, tagging releases, constraint intersection, pruning orphaned dependencies, error resolution

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
