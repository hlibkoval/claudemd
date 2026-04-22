---
name: plugins-doc
description: Complete official documentation for Claude Code plugins — creating plugins, plugin manifest schema, plugin components (skills, agents, hooks, MCP servers, LSP servers, monitors), installation scopes, discovering and installing plugins, marketplace creation and distribution, plugin dependency version constraints, CLI commands, debugging, and managed marketplace restrictions.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

Plugins are self-contained directories that extend Claude Code with custom skills, agents, hooks, MCP servers, LSP servers, and monitors. They support versioned distribution through marketplaces and namespaced skill invocation (e.g., `/my-plugin:hello`).

### Standalone configuration vs plugins

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, single-project, quick experiments |
| **Plugins** (directories with `.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teams, distributing to community, versioned releases |

### Plugin directory structure

| Directory / File | Location | Purpose |
| :--- | :--- | :--- |
| `.claude-plugin/plugin.json` | Plugin root | Manifest (optional — Claude auto-discovers without it) |
| `skills/` | Plugin root | Skills as `<name>/SKILL.md` directories |
| `commands/` | Plugin root | Skills as flat `.md` files (legacy; prefer `skills/`) |
| `agents/` | Plugin root | Subagent definitions |
| `hooks/hooks.json` | Plugin root | Hook configurations |
| `.mcp.json` | Plugin root | MCP server definitions |
| `.lsp.json` | Plugin root | LSP server configurations |
| `monitors/monitors.json` | Plugin root | Background monitor configurations |
| `bin/` | Plugin root | Executables added to Bash tool's `PATH` |
| `settings.json` | Plugin root | Default settings (only `agent` and `subagentStatusLine` keys supported) |
| `output-styles/` | Plugin root | Output style definitions |

**Common mistake**: Do NOT put `commands/`, `agents/`, `skills/`, or `hooks/` inside `.claude-plugin/`. Only `plugin.json` goes in `.claude-plugin/`.

### Plugin manifest schema (`plugin.json`)

`name` is the only required field when a manifest is present.

**Metadata fields:**

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique identifier (kebab-case). Used as skill namespace prefix. |
| `version` | string | Semantic version (e.g., `"2.1.0"`) |
| `description` | string | Brief plugin purpose |
| `author` | object | `{name, email?, url?}` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier (e.g., `"MIT"`) |
| `keywords` | array | Discovery tags |

**Component path fields:**

| Field | Type | Description |
| :--- | :--- | :--- |
| `skills` | string\|array | Custom skill directories (replaces default `skills/`) |
| `commands` | string\|array | Custom flat `.md` skill files or directories |
| `agents` | string\|array | Custom agent files |
| `hooks` | string\|array\|object | Hook config paths or inline config |
| `mcpServers` | string\|array\|object | MCP config paths or inline config |
| `lspServers` | string\|array\|object | LSP server configurations |
| `monitors` | string\|array | Background monitor configurations |
| `outputStyles` | string\|array | Output style files/directories |
| `userConfig` | object | User-configurable values prompted at enable time |
| `channels` | array | Channel declarations (Telegram, Slack, Discord style) |
| `dependencies` | array | Other plugins this plugin requires, with optional semver constraints |

**`userConfig` field schema** (each key is an option):

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label shown in configuration dialog |
| `description` | Yes | Help text shown beneath the field |
| `sensitive` | No | If `true`, masks input and stores in secure storage |
| `required` | No | If `true`, validation fails when empty |
| `default` | No | Value used when user provides nothing |
| `multiple` | No | For `string` type, allow an array of strings |
| `min` / `max` | No | Bounds for `number` type |

Values available as `${user_config.KEY}` in configs; exported as `CLAUDE_PLUGIN_OPTION_<KEY>` to subprocesses.

### Environment variables in plugin configs

| Variable | Description |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to the plugin's installation directory. Changes on plugin update. |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state that survives updates (`~/.claude/plugins/data/{id}/`). Created automatically. |

### Plugin installation scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` | `~/.claude/settings.json` | Personal plugins across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Read-only, admin-controlled |

### Hook events (plugin hooks)

Plugin hooks support the same events as user-defined hooks. Key events:

| Event | When it fires |
| :--- | :--- |
| `SessionStart` | When a session begins or resumes |
| `PreToolUse` | Before a tool call executes. Can block it |
| `PostToolUse` | After a tool call succeeds |
| `PostToolUseFailure` | After a tool call fails |
| `Stop` | When Claude finishes responding |
| `SubagentStart` / `SubagentStop` | When a subagent spawns or finishes |
| `FileChanged` | When a watched file changes on disk |
| `SessionEnd` | When a session terminates |
| `PreCompact` / `PostCompact` | Before/after context compaction |

Hook types: `command`, `http`, `prompt`, `agent`.

### Monitors

Background monitors run a shell command for the session lifetime and deliver each stdout line to Claude as a notification.

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Identifier unique within the plugin |
| `command` | Yes | Shell command run as persistent background process |
| `description` | Yes | Short summary; shown in task panel |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

Requires Claude Code v2.1.105 or later. Monitors run only in interactive CLI sessions.

### Plugin agents (frontmatter fields)

Plugin agents support: `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation` (only `"worktree"` valid).

Plugin agents do **not** support `hooks`, `mcpServers`, or `permissionMode`.

### LSP server configuration fields

**Required:**

| Field | Description |
| :--- | :--- |
| `command` | LSP binary to execute (must be in PATH) |
| `extensionToLanguage` | Maps file extensions to language identifiers |

**Optional:** `args`, `transport` (`stdio` or `socket`), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`.

**Official LSP plugins (from marketplace):**

| Plugin | Language server | Binary required |
| :--- | :--- | :--- |
| `pyright-lsp` | Pyright (Python) | `pyright-langserver` |
| `typescript-lsp` | TypeScript Language Server | `typescript-language-server` |
| `rust-analyzer-lsp` | rust-analyzer | `rust-analyzer` |
| `gopls-lsp` | gopls (Go) | `gopls` |
| `clangd-lsp` | clangd (C/C++) | `clangd` |
| `kotlin-lsp` | Kotlin Language Server | `kotlin-language-server` |

### Testing plugins locally

```bash
claude --plugin-dir ./my-plugin
# Load multiple plugins
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

Use `/reload-plugins` to pick up changes without restarting. Validate with `claude plugin validate .` or `/plugin validate .`.

### CLI commands reference

| Command | Description |
| :--- | :--- |
| `claude plugin install <plugin> [--scope user\|project\|local]` | Install plugin from a marketplace |
| `claude plugin uninstall <plugin> [--scope] [--keep-data]` | Remove an installed plugin |
| `claude plugin enable <plugin> [--scope]` | Enable a disabled plugin |
| `claude plugin disable <plugin> [--scope]` | Disable without uninstalling |
| `claude plugin update <plugin> [--scope]` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin validate [path]` | Validate plugin/marketplace JSON and frontmatter |
| `claude plugin marketplace add <source>` | Add a marketplace |
| `claude plugin marketplace list [--json]` | List configured marketplaces |
| `claude plugin marketplace update [name]` | Refresh marketplace listings |
| `claude plugin marketplace remove <name>` | Remove a marketplace (also uninstalls its plugins) |

### Marketplace schema

**marketplace.json required fields:**

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Marketplace identifier (kebab-case, no spaces) |
| `owner` | object | `{name: string, email?: string}` |
| `plugins` | array | List of plugin entries |

**Plugin source types:**

| Source type | Example / Fields | Notes |
| :--- | :--- | :--- |
| Relative path (string) | `"./plugins/my-plugin"` | Must start with `./`. Works only for git-based marketplace distribution. |
| `github` | `{source: "github", repo: "owner/repo", ref?, sha?}` | Most common for public plugins |
| `url` | `{source: "url", url: "https://...", ref?, sha?}` | Any git host |
| `git-subdir` | `{source: "git-subdir", url, path, ref?, sha?}` | Subdirectory of a monorepo; sparse clone |
| `npm` | `{source: "npm", package: "@org/plugin", version?, registry?}` | npm package |

**Strict mode** (`strict` field in plugin entry):
- `true` (default): `plugin.json` is the authority; marketplace entry supplements it
- `false`: marketplace entry is the entire definition; useful when marketplace operator curates component exposure

### Plugin dependency version constraints

Declare in `dependencies` array of `plugin.json`:

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
| `version` | Semver range (e.g., `~2.1.0`, `^2.0`, `>=1.4`, `=2.1.0`) |
| `marketplace` | Different marketplace to resolve from (requires allowlist) |

Tag releases as `{plugin-name}--v{version}` for version resolution to work.

**Dependency error codes:**

| Error | Meaning | Resolution |
| :--- | :--- | :--- |
| `range-conflict` | Installed plugins need incompatible version ranges | Uninstall/update conflicting plugin |
| `dependency-version-unsatisfied` | Installed version outside declared range | Re-run `claude plugin install <dep>@<marketplace>` |
| `no-matching-tag` | No tag matching the range exists | Check upstream tags or relax constraint |

### Managed marketplace restrictions

Admins set `strictKnownMarketplaces` in managed settings:

| Value | Behavior |
| :--- | :--- |
| Undefined (default) | No restrictions |
| `[]` (empty array) | No new marketplaces allowed |
| List of sources | Only matching marketplaces allowed |

Supported allowlist entry types: `github` (with `repo`, optional `ref`/`path`), `url` (exact URL), `hostPattern` (regex on host), `pathPattern` (regex on filesystem path).

Pair with `extraKnownMarketplaces` to automatically make allowed marketplaces available to users.

### Debugging common issues

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` |
| Skills not appearing | Wrong directory structure | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Script not executable | Run `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use the variable for all plugin-relative paths |
| LSP `Executable not found` | Language server binary not installed | Install the required binary |
| Path errors | Absolute paths used | All paths must be relative and start with `./` |

Run `claude --debug` for detailed plugin loading output. Check the `/plugin` Errors tab in interactive mode.

### Container/CI: pre-populate plugins

Set `CLAUDE_CODE_PLUGIN_SEED_DIR` to point at a pre-built plugin directory (mirrors `~/.claude/plugins`). Seed directories are read-only; auto-update is disabled for seed marketplaces. Layer multiple seeds by separating paths with `:` (Unix) or `;` (Windows).

Build-time setup:
```bash
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin marketplace add your-org/plugins
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin install my-tool@your-plugins
```

Then set `CLAUDE_CODE_PLUGIN_SEED_DIR=/opt/claude-seed` at runtime.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — quickstart, when to use plugins vs standalone, plugin structure, adding skills/LSP/monitors/settings, testing locally, migrating existing configurations, and submitting to the official marketplace.
- [Plugins reference](references/claude-code-plugins-reference.md) — complete technical specs: all components (skills, agents, hooks, MCP servers, LSP servers, monitors), full manifest schema, userConfig, channels, environment variables, persistent data directory, plugin caching, file locations, CLI commands, debugging tools, versioning.
- [Discover and install plugins](references/claude-code-discover-plugins.md) — official Anthropic marketplace, available plugin categories (code intelligence, external integrations, development workflows, output styles), add/install/manage marketplaces, team marketplace configuration, auto-updates, security, troubleshooting.
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — full marketplace schema, plugin sources (relative path, GitHub, git URL, git-subdir, npm), strict mode, hosting (GitHub, GitLab, private repos), team configuration, pre-populating containers, managed marketplace restrictions, version/release channels, validation, troubleshooting.
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring dependencies with version constraints in `plugin.json`, cross-marketplace dependencies, git tag conventions for version resolution, constraint intersection rules, dependency error resolution.

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
