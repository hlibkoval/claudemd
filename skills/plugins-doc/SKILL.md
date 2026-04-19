---
name: plugins-doc
description: Complete official documentation for Claude Code plugins — creating plugins, plugin manifest schema, directory structure, component specifications, marketplaces, discovery and installation, dependency version constraints, and CLI commands.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for the Claude Code plugin system.

## Quick Reference

A **plugin** is a self-contained directory that extends Claude Code with custom skills, agents, hooks, MCP servers, LSP servers, monitors, and executables. Plugins are namespaced (`/plugin-name:skill-name`) to avoid conflicts, shared via marketplaces, and cached locally for security.

### Plugins vs standalone configuration

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, quick experiments |
| **Plugin** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with team, marketplace distribution, reuse across projects |

### Plugin directory structure

```text
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Manifest (only file inside .claude-plugin/)
├── skills/                  # Skills as <name>/SKILL.md directories
├── commands/                # Skills as flat .md files (legacy)
├── agents/                  # Subagent definitions
├── hooks/
│   └── hooks.json           # Hook configurations
├── monitors/
│   └── monitors.json        # Background monitor configurations
├── output-styles/           # Output style definitions
├── bin/                     # Executables added to Bash tool PATH
├── settings.json            # Default settings (agent, subagentStatusLine)
├── .mcp.json                # MCP server definitions
├── .lsp.json                # LSP server configurations
└── scripts/                 # Hook and utility scripts
```

All component directories go at the plugin root, NOT inside `.claude-plugin/`.

### Plugin manifest (`plugin.json`)

The manifest is optional. If omitted, Claude Code auto-discovers components in default locations.

**Required fields** (if manifest exists):

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique identifier (kebab-case). Used as skill namespace prefix |

**Metadata fields:**

| Field | Type | Description |
| :--- | :--- | :--- |
| `version` | string | Semantic version (MAJOR.MINOR.PATCH) |
| `description` | string | Brief explanation of plugin purpose |
| `author` | object | `{name, email?, url?}` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier |
| `keywords` | array | Discovery tags |

**Component path fields** (override defaults):

| Field | Type | Description |
| :--- | :--- | :--- |
| `skills` | string or array | Custom skill directories (replaces default `skills/`) |
| `commands` | string or array | Custom flat `.md` skill files or directories |
| `agents` | string or array | Custom agent files (replaces default `agents/`) |
| `hooks` | string, array, or object | Hook config paths or inline config |
| `mcpServers` | string, array, or object | MCP config paths or inline config |
| `lspServers` | string, array, or object | LSP server config paths or inline config |
| `monitors` | string or array | Background monitor configurations |
| `userConfig` | object | User-configurable values prompted at enable time |
| `channels` | array | Channel declarations for message injection |
| `dependencies` | array | Other plugins this plugin requires, optionally with semver constraints |

### Component reference

**Skills**: `skills/<name>/SKILL.md` directories. Auto-discovered. Claude invokes based on context.

**Agents**: `agents/*.md` files with frontmatter. Support `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation`. Plugin agents do NOT support `hooks`, `mcpServers`, or `permissionMode`.

**Hooks**: `hooks/hooks.json` or inline in `plugin.json`. Same lifecycle events as user hooks.

| Hook event | When it fires |
| :--- | :--- |
| `SessionStart` | Session begins or resumes |
| `UserPromptSubmit` | Prompt submitted, before processing |
| `PreToolUse` | Before a tool call (can block) |
| `PermissionRequest` | Permission dialog appears |
| `PermissionDenied` | Tool call denied by classifier |
| `PostToolUse` | After tool call succeeds |
| `PostToolUseFailure` | After tool call fails |
| `Notification` | Notification sent |
| `SubagentStart` / `SubagentStop` | Subagent lifecycle |
| `TaskCreated` / `TaskCompleted` | Task lifecycle |
| `Stop` | Claude finishes responding |
| `StopFailure` | Turn ends due to API error |
| `TeammateIdle` | Agent team teammate going idle |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded |
| `ConfigChange` | Config file changes during session |
| `CwdChanged` | Working directory changes |
| `FileChanged` | Watched file changes (matcher specifies filenames) |
| `WorktreeCreate` / `WorktreeRemove` | Worktree lifecycle |
| `PreCompact` / `PostCompact` | Context compaction lifecycle |
| `Elicitation` / `ElicitationResult` | MCP server user input |
| `SessionEnd` | Session terminates |

Hook types: `command`, `http`, `prompt`, `agent`.

**MCP servers**: `.mcp.json` at plugin root or inline. Auto-start when plugin is enabled.

**LSP servers**: `.lsp.json` at plugin root or inline. Required fields: `command`, `extensionToLanguage`. Optional: `args`, `transport`, `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`.

**Monitors**: `monitors/monitors.json` (array) or inline. Required fields: `name`, `command`, `description`. Optional: `when` (`"always"` default, or `"on-skill-invoke:<skill-name>"`). Requires v2.1.105+.

**Executables**: `bin/` directory. Files are added to the Bash tool's PATH while the plugin is active.

**Settings**: `settings.json` at plugin root. Only `agent` and `subagentStatusLine` keys supported.

### Environment variables

| Variable | Purpose |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin install dir. Changes on update |
| `${CLAUDE_PLUGIN_DATA}` | Persistent data dir (`~/.claude/plugins/data/{id}/`). Survives updates. Deleted on uninstall |
| `${user_config.KEY}` | User-configured values (from `userConfig`) |

All three are substituted in skill/agent content, hook commands, monitor commands, MCP/LSP configs, and exported to subprocesses.

### Installation scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` | `~/.claude/settings.json` | Personal, all projects (default) |
| `project` | `.claude/settings.json` | Team, shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled, read-only |

### CLI commands

| Command | Description |
| :--- | :--- |
| `claude plugin install <plugin> [-s scope]` | Install from marketplace |
| `claude plugin uninstall <plugin> [-s scope] [--keep-data]` | Remove (aliases: `remove`, `rm`) |
| `claude plugin enable <plugin> [-s scope]` | Re-enable disabled plugin |
| `claude plugin disable <plugin> [-s scope]` | Disable without uninstalling |
| `claude plugin update <plugin> [-s scope]` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin validate` | Validate manifest and components |

### Interactive commands

| Command | Description |
| :--- | :--- |
| `/plugin` | Open plugin manager (Discover, Installed, Marketplaces, Errors tabs) |
| `/plugin install <name>@<marketplace>` | Install a plugin |
| `/plugin disable <name>@<marketplace>` | Disable a plugin |
| `/plugin enable <name>@<marketplace>` | Enable a plugin |
| `/plugin uninstall <name>@<marketplace>` | Remove a plugin |
| `/reload-plugins` | Reload all active plugins without restarting |

### Marketplaces

A **marketplace** is a catalog of plugins defined by `.claude-plugin/marketplace.json`. Users add a marketplace, then install individual plugins from it.

**Marketplace sources** (how to add a marketplace):

| Source | Command example |
| :--- | :--- |
| GitHub | `/plugin marketplace add owner/repo` |
| Git URL | `/plugin marketplace add https://gitlab.com/org/repo.git` |
| Local path | `/plugin marketplace add ./my-marketplace` |
| Remote URL | `/plugin marketplace add https://example.com/marketplace.json` |

Append `@ref` (GitHub) or `#ref` (git URL) to pin to a branch or tag.

**Plugin sources** (where marketplace fetches each plugin):

| Source type | Fields |
| :--- | :--- |
| Relative path | String starting with `./` |
| `github` | `repo`, `ref?`, `sha?` |
| `url` | `url`, `ref?`, `sha?` |
| `git-subdir` | `url`, `path`, `ref?`, `sha?` |
| `npm` | `package`, `version?`, `registry?` |

**Marketplace schema required fields**: `name` (kebab-case), `owner` (`{name, email?}`), `plugins` (array).

**Team configuration**: add `extraKnownMarketplaces` and `enabledPlugins` to `.claude/settings.json` for auto-prompt on trust.

**Auto-updates**: official marketplaces auto-update by default. Toggle per marketplace via `/plugin` > Marketplaces. `DISABLE_AUTOUPDATER` disables all; `FORCE_AUTOUPDATE_PLUGINS=1` re-enables plugin updates only.

**Managed restrictions**: `strictKnownMarketplaces` in managed settings restricts which marketplaces users can add. Supports exact match, `hostPattern`, and `pathPattern`.

**Container pre-population**: set `CLAUDE_CODE_PLUGIN_SEED_DIR` to provide plugins at build time without runtime cloning. Supports layered paths separated by `:`.

### Dependency version constraints

Plugins can declare dependencies with semver constraints in `plugin.json`:

```json
"dependencies": [
  "audit-logger",
  { "name": "secrets-vault", "version": "~2.1.0" }
]
```

The `version` field accepts any Node `semver` range (`~`, `^`, `>=`, `=`, hyphen, comparator). Versions resolve against git tags named `{plugin-name}--v{version}`. Multiple plugins constraining the same dependency are intersected; conflicts disable the offending plugin.

Requires v2.1.110+.

### Official marketplace categories

| Category | Examples |
| :--- | :--- |
| **Code intelligence (LSP)** | `pyright-lsp`, `typescript-lsp`, `rust-analyzer-lsp`, `gopls-lsp`, `clangd-lsp`, `swift-lsp`, and more |
| **External integrations** | `github`, `gitlab`, `atlassian`, `linear`, `slack`, `figma`, `vercel`, `firebase`, `sentry` |
| **Development workflows** | `commit-commands`, `pr-review-toolkit`, `agent-sdk-dev`, `plugin-dev` |
| **Output styles** | `explanatory-output-style`, `learning-output-style` |

### Caching and file resolution

Marketplace plugins are copied to `~/.claude/plugins/cache`. Orphaned versions are removed after 7 days. Plugins cannot reference files outside their directory after installation. Use symlinks for external dependencies.

### Testing locally

```bash
claude --plugin-dir ./my-plugin          # Load one plugin
claude --plugin-dir ./a --plugin-dir ./b # Load multiple
```

Run `/reload-plugins` to pick up changes without restarting. Local `--plugin-dir` plugins override same-name marketplace plugins.

### Common issues

| Issue | Solution |
| :--- | :--- |
| Plugin not loading | Run `claude plugin validate` or `/plugin validate` |
| Skills not appearing | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | `chmod +x script.sh`; verify event name case; use `${CLAUDE_PLUGIN_ROOT}` |
| MCP server fails | Use `${CLAUDE_PLUGIN_ROOT}` for all plugin paths; run `claude --debug` |
| LSP binary not found | Install the language server binary (check `/plugin` Errors tab) |
| Files not found after install | Plugins are cached; paths to outside files break. Use symlinks |

### Converting standalone to plugin

1. Create `my-plugin/.claude-plugin/plugin.json` with `name`, `description`, `version`
2. Copy `skills/`, `agents/`, `commands/` to plugin root
3. Move hooks from `settings.json` to `hooks/hooks.json` (same format, wrapped in `{"hooks": {...}}`)
4. Test with `claude --plugin-dir ./my-plugin`

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — full tutorial on creating plugins: quickstart, adding skills/agents/hooks/MCP/LSP/monitors, plugin structure, local testing, debugging, converting standalone configs, and sharing
- [Plugins reference](references/claude-code-plugins-reference.md) — complete technical reference: manifest schema, component specifications (skills, agents, hooks, MCP, LSP, monitors), environment variables, persistent data directory, caching, directory structure, CLI commands, debugging, and version management
- [Discover and install plugins](references/claude-code-discover-plugins.md) — finding and installing plugins from marketplaces, official marketplace categories, managing installed plugins, marketplace management, auto-updates, team configuration, and troubleshooting
- [Plugin marketplaces](references/claude-code-plugin-marketplaces.md) — creating and distributing marketplaces: marketplace schema, plugin sources (relative path, GitHub, git URL, git-subdir, npm), hosting, private repos, strict mode, managed restrictions, version resolution, release channels, container pre-population, validation, and troubleshooting
- [Plugin dependencies](references/claude-code-plugin-dependencies.md) — declaring dependency version constraints with semver ranges, tagging releases for resolution, constraint intersection, and resolving dependency errors

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Plugin marketplaces: https://code.claude.com/docs/en/plugin-marketplaces.md
- Plugin dependencies: https://code.claude.com/docs/en/plugin-dependencies.md
