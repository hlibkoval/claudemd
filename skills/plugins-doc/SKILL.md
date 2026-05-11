---
name: plugins-doc
description: Complete official documentation for Claude Code plugins — creating plugins, plugin manifest schema, plugin directory structure, installing and discovering plugins via marketplaces, distributing plugins, plugin components (skills, agents, hooks, MCP/LSP servers, monitors, themes), CLI commands, and dependency version constraints.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for the Claude Code plugin system.

## Quick Reference

### Standalone vs Plugin

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugins** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teams, distributing to community, versioned releases |

### Creating a Plugin (Quickstart)

```bash
mkdir my-plugin && mkdir my-plugin/.claude-plugin
```

`my-plugin/.claude-plugin/plugin.json`:
```json
{
  "name": "my-plugin",
  "description": "What this plugin does",
  "version": "1.0.0",
  "author": { "name": "Your Name" }
}
```

`my-plugin/skills/hello/SKILL.md`:
```markdown
---
description: Greet the user
---
Greet the user warmly.
```

Test locally:
```bash
claude --plugin-dir ./my-plugin
# then invoke: /my-plugin:hello
```

Run `/reload-plugins` to pick up changes without restarting. `--plugin-dir` can be specified multiple times for multiple plugins.

To test a pre-packaged zip: `claude --plugin-url https://example.com/my-plugin.zip`

### Plugin Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Manifest (optional; name is the only required field if present)
├── skills/                  # Skills as <name>/SKILL.md
├── commands/                # Skills as flat .md files (legacy; use skills/ for new plugins)
├── agents/                  # Subagent definitions
├── output-styles/           # Output style definitions
├── themes/                  # Color theme definitions (experimental)
├── monitors/
│   └── monitors.json        # Background monitors (experimental; requires v2.1.105+)
├── hooks/
│   └── hooks.json           # Hook configuration
├── bin/                     # Executables added to Bash tool's PATH
├── settings.json            # Default settings (only `agent` and `subagentStatusLine` keys)
├── .mcp.json                # MCP server definitions
└── .lsp.json                # LSP server configurations
```

**Warning**: Only `plugin.json` goes inside `.claude-plugin/`. All other directories (skills/, agents/, hooks/, etc.) must be at the plugin root.

### Plugin Manifest Fields (`plugin.json`)

#### Required
| Field | Description |
| :--- | :--- |
| `name` | Unique identifier (kebab-case). Used as skill namespace (`/name:skill`) |

#### Metadata
| Field | Description |
| :--- | :--- |
| `version` | Semver string. If set, users only get updates when you bump it. If omitted, git commit SHA is used |
| `description` | Shown in plugin manager |
| `author` | Object with `name`, `email`, `url` |
| `homepage` | Documentation URL |
| `repository` | Source code URL |
| `license` | SPDX identifier (e.g. `"MIT"`) |
| `keywords` | Array of discovery tags |
| `$schema` | JSON Schema URL for editor autocomplete (ignored at load time) |

#### Component Path Fields
| Field | Type | Notes |
| :--- | :--- | :--- |
| `skills` | string\|array | Adds to default `skills/` (default always scanned) |
| `commands` | string\|array | Replaces default `commands/` |
| `agents` | string\|array | Replaces default `agents/` |
| `hooks` | string\|array\|object | Inline or path |
| `mcpServers` | string\|array\|object | Inline or path |
| `lspServers` | string\|array\|object | Inline or path |
| `outputStyles` | string\|array | Replaces default `output-styles/` |
| `experimental.themes` | string\|array | Replaces default `themes/` |
| `experimental.monitors` | string\|array | Path or inline array |
| `userConfig` | object | User-prompted config at enable time |
| `channels` | array | Channel declarations for message injection |
| `dependencies` | array | Other plugins this plugin requires |

### Environment Variables in Plugin Configs

| Variable | Description |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin installation directory (ephemeral; changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent data directory (`~/.claude/plugins/data/{id}/`); survives updates |

Available in: skill/agent content, hook commands, monitor commands, MCP/LSP configs. Also exported to subprocesses.

### User Configuration (`userConfig`)

Prompts the user when plugin is enabled. Values accessible as `${user_config.KEY}` and `CLAUDE_PLUGIN_OPTION_<KEY>` env vars.

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label in config dialog |
| `description` | Yes | Help text |
| `sensitive` | No | Masks input; stores in system keychain |
| `required` | No | Validation fails if empty |
| `default` | No | Value when user provides nothing |
| `multiple` | No | For `string` type: allow array of strings |
| `min` / `max` | No | Bounds for `number` type |

### Plugin Components

#### Agents (`agents/`)

```markdown
---
name: agent-name
description: When to invoke this agent
model: sonnet
effort: medium
maxTurns: 20
disallowedTools: Write, Edit
---
Agent system prompt...
```

Supported fields: `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation` (only valid value: `"worktree"`). Not supported for plugin agents: `hooks`, `mcpServers`, `permissionMode`.

#### Hooks (`hooks/hooks.json` or inline)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh" }]
      }
    ]
  }
}
```

Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`

Hook events include: `SessionStart`, `Setup`, `UserPromptSubmit`, `UserPromptExpansion`, `PreToolUse`, `PermissionRequest`, `PermissionDenied`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Notification`, `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `Stop`, `StopFailure`, `TeammateIdle`, `InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `FileChanged`, `WorktreeCreate`, `WorktreeRemove`, `PreCompact`, `PostCompact`, `Elicitation`, `ElicitationResult`, `SessionEnd`

#### Background Monitors (`monitors/monitors.json` or inline)

Requires Claude Code v2.1.105+. Each stdout line from the command is delivered to Claude as a notification. Run only in interactive CLI sessions; skipped where Monitor tool is unavailable.

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
| `name` | Yes | Unique within plugin; prevents duplicate processes |
| `command` | Yes | Shell command run as persistent background process |
| `description` | Yes | Shown in task panel and notification summaries |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

#### LSP Servers (`.lsp.json` or inline)

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": { ".go": "go" }
  }
}
```

| Field | Required | Description |
| :--- | :--- | :--- |
| `command` | Yes | LSP binary (must be in PATH) |
| `extensionToLanguage` | Yes | Maps file extensions to language IDs |
| `args` | No | Command-line arguments |
| `transport` | No | `stdio` (default) or `socket` |
| `env` | No | Environment variables |
| `initializationOptions` | No | Passed during server init |
| `settings` | No | Via `workspace/didChangeConfiguration` |
| `restartOnCrash` | No | Auto-restart if server crashes |
| `maxRestarts` | No | Max restart attempts |
| `startupTimeout` | No | Max ms to wait for startup |
| `shutdownTimeout` | No | Max ms to wait for shutdown |

Official LSP plugins in the marketplace: `pyright-lsp`, `typescript-lsp`, `rust-analyzer-lsp`, `gopls-lsp`, `clangd-lsp`, `csharp-lsp`, `jdtls-lsp`, `kotlin-lsp`, `lua-lsp`, `php-lsp`, `swift-lsp`

### Plugin Installation Scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` (default) | `~/.claude/settings.json` | Personal, all projects |
| `project` | `.claude/settings.json` | Team plugins via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-installed, read-only |

### Plugin CLI Commands

```bash
claude plugin install <plugin>[@marketplace] [--scope user|project|local]
claude plugin uninstall <plugin> [--scope] [--keep-data] [--prune] [-y]
claude plugin enable <plugin> [--scope]
claude plugin disable <plugin> [--scope]
claude plugin update <plugin> [--scope]
claude plugin list [--json] [--available]
claude plugin tag [--push] [--dry-run] [-f]
claude plugin prune [--scope] [--dry-run] [-y]   # requires v2.1.121+
claude plugin validate [path]
```

In-session commands: `/plugin install`, `/plugin disable`, `/plugin enable`, `/plugin uninstall`, `/reload-plugins`

### Plugin Caching

Marketplace plugins are copied to `~/.claude/plugins/cache/`. Plugins cannot reference files outside their directory (no `../` paths). Use symlinks for shared files across plugins.

`${CLAUDE_PLUGIN_DATA}` resolves to `~/.claude/plugins/data/{id}/` — use for persistent state (node_modules, caches) that survives plugin updates.

### Version Management

Version resolution order:
1. `version` in `plugin.json`
2. `version` in marketplace entry
3. Git commit SHA of plugin source
4. `"unknown"` (npm or non-git local)

Two strategies:
- **Explicit version** (`"version": "2.1.0"` in `plugin.json`): users only get updates when you bump the field
- **Commit-SHA version** (omit `version`): every new commit is a new version (best for active development)

### Discovering and Installing Plugins

```shell
/plugin            # open plugin manager (Discover / Installed / Marketplaces / Errors tabs)
/plugin marketplace add anthropics/claude-code    # add from GitHub
/plugin marketplace add https://gitlab.com/co/plugins.git  # git URL
/plugin marketplace add ./my-marketplace          # local path
/plugin marketplace add https://example.com/marketplace.json  # remote URL
/plugin install plugin-name@marketplace-name
/plugin marketplace list
/plugin marketplace update [name]
/plugin marketplace remove <name>
```

### Creating a Marketplace (`marketplace.json`)

At `.claude-plugin/marketplace.json`:

```json
{
  "name": "my-marketplace",
  "owner": { "name": "Your Name" },
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin",
      "description": "What it does",
      "version": "1.0.0"
    }
  ]
}
```

#### Plugin Source Types

| Source | Format | Notes |
| :--- | :--- | :--- |
| Relative path | `"./plugins/my-plugin"` | Must start with `./`; only works with git-hosted marketplaces |
| GitHub | `{ "source": "github", "repo": "owner/repo", "ref": "v2", "sha": "abc..." }` | |
| Git URL | `{ "source": "url", "url": "https://...", "ref": "main", "sha": "abc..." }` | |
| Git subdir | `{ "source": "git-subdir", "url": "...", "path": "tools/plugin", "ref": "...", "sha": "..." }` | Sparse clone |
| npm | `{ "source": "npm", "package": "@org/plugin", "version": "2.1.0", "registry": "..." }` | |

#### Team/Project Marketplace Configuration (`.claude/settings.json`)

```json
{
  "extraKnownMarketplaces": {
    "company-tools": {
      "source": { "source": "github", "repo": "your-org/claude-plugins" }
    }
  },
  "enabledPlugins": {
    "formatter@company-tools": true
  }
}
```

#### Managed Marketplace Restrictions (`strictKnownMarketplaces`)

| Value | Behavior |
| :--- | :--- |
| Undefined | No restrictions |
| `[]` | Complete lockdown |
| Array of sources | Allowlist — only matching marketplaces can be added |

Source types for allowlist: `github` (repo + optional ref), `url` (exact URL), `hostPattern` (regex on host), `pathPattern` (regex on path).

#### Marketplace Strict Mode

| `strict` | Behavior |
| :--- | :--- |
| `true` (default) | `plugin.json` is authoritative; marketplace entry can add more components |
| `false` | Marketplace entry is the entire definition; plugin must not also declare components in `plugin.json` |

### Plugin Dependency Constraints (requires v2.1.110+)

In `plugin.json`:
```json
{
  "dependencies": [
    "audit-logger",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```

| Field | Description |
| :--- | :--- |
| `name` | Plugin name (required) |
| `version` | Semver range (`~2.1.0`, `^2.0`, `>=1.4`, `=2.1.0`) |
| `marketplace` | Different marketplace to resolve from (requires `allowCrossMarketplaceDependenciesOn` in root marketplace) |

Tag releases for version resolution: `claude plugin tag --push` (creates `{plugin-name}--v{version}` git tags).

Dependency errors: `dependency-unsatisfied`, `range-conflict`, `dependency-version-unsatisfied`, `no-matching-tag`

### Debugging

```bash
claude --debug                  # see plugin loading details
claude plugin validate .        # validate plugin.json, frontmatter, hooks.json
/plugin validate                # same from within Claude Code
```

Common issues:
| Issue | Solution |
| :--- | :--- |
| Plugin not loading | Run `claude plugin validate`; check `plugin.json` syntax |
| Skills not appearing | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Check script is executable (`chmod +x`); verify event name is case-sensitive |
| MCP server fails | Use `${CLAUDE_PLUGIN_ROOT}` for all plugin paths |
| LSP binary not found | Install the language server binary and ensure it's in `$PATH` |

Environment variables for marketplace behavior:
- `CLAUDE_CODE_PLUGIN_SEED_DIR` — pre-populated plugins directory for containers/CI
- `CLAUDE_CODE_PLUGIN_CACHE_DIR` — override cache location at build time
- `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE=1` — keep stale cache on git pull failure (for offline environments)
- `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` — git operation timeout in ms (default: 120000)

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — creating plugins with skills, agents, hooks, MCP/LSP servers; quickstart, plugin structure, converting existing configs
- [Plugins reference](references/claude-code-plugins-reference.md) — complete technical reference: manifest schema, component specs, CLI commands, environment variables, caching, debugging
- [Discover and install plugins](references/claude-code-discover-plugins.md) — browsing marketplaces, installing plugins, official marketplace, LSP plugins table, managing plugins
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace.json schema, plugin sources, hosting, private repos, managed restrictions, version channels
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring dependencies, semver ranges, tagging releases, constraint intersection, pruning orphaned deps

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
