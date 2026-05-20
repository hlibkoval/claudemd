---
name: plugins-doc
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

### Standalone vs plugin configuration

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, single-project customizations |
| **Plugins** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teammates, multi-project reuse, marketplace distribution |

### Plugin directory structure

| Directory / File | Location | Purpose |
| :--- | :--- | :--- |
| `.claude-plugin/plugin.json` | Plugin root | Manifest (optional if using default locations) |
| `skills/` | Plugin root | Skills as `<name>/SKILL.md` directories |
| `commands/` | Plugin root | Skills as flat `.md` files (use `skills/` for new plugins) |
| `agents/` | Plugin root | Subagent definitions |
| `hooks/hooks.json` | Plugin root | Event hook configuration |
| `.mcp.json` | Plugin root | MCP server definitions |
| `.lsp.json` | Plugin root | LSP server configurations |
| `monitors/monitors.json` | Plugin root | Background monitor configurations |
| `themes/` | Plugin root | Color theme definitions |
| `output-styles/` | Plugin root | Output style definitions |
| `bin/` | Plugin root | Executables added to Bash tool's `PATH` |
| `settings.json` | Plugin root | Default settings (only `agent` and `subagentStatusLine` supported) |

**Important**: Only `plugin.json` goes inside `.claude-plugin/`. All other directories must be at the plugin root.

### Plugin manifest schema (`plugin.json`)

**Required** (only `name` if manifest is present):

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique identifier (kebab-case). Namespaces skills: `/my-plugin:skill-name` |

**Metadata fields:**

| Field | Type | Description |
| :--- | :--- | :--- |
| `displayName` | string | Human-readable name shown in UI (v2.1.143+) |
| `version` | string | Semver version. Omit to use git commit SHA (auto-version on every commit) |
| `description` | string | Brief explanation of plugin purpose |
| `author` | object | `{ name, email, url }` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier (e.g., `"MIT"`) |
| `keywords` | array | Discovery tags |

**Component path fields** (all relative to plugin root, must start with `./`):

| Field | Type | Behavior |
| :--- | :--- | :--- |
| `skills` | string\|array | Adds to default `skills/` (default always scanned too) |
| `commands` | string\|array | Replaces default `commands/` |
| `agents` | string\|array | Replaces default `agents/` |
| `hooks` | string\|array\|object | Custom hooks path or inline config |
| `mcpServers` | string\|array\|object | MCP config path or inline |
| `lspServers` | string\|array\|object | LSP config path or inline |
| `outputStyles` | string\|array | Replaces default `output-styles/` |
| `experimental.themes` | string\|array | Replaces default `themes/` |
| `experimental.monitors` | string\|array | Background monitor config |
| `userConfig` | object | Prompts user for values at enable time |
| `channels` | array | Message channel declarations (Telegram, Slack, Discord style) |
| `dependencies` | array | Other plugins this plugin requires (with optional semver constraints) |

**Environment variables** available in hook commands, MCP/LSP configs, monitor commands, and skill/agent content:

| Variable | Description |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to the plugin's installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state (survives updates); resolves to `~/.claude/plugins/data/{id}/` |
| `${CLAUDE_PROJECT_DIR}` | The project root directory |

### User configuration (`userConfig`)

Declare values that Claude Code prompts the user for when the plugin is enabled:

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | One of `string`, `number`, `boolean`, `directory`, `file` |
| `title` | Yes | Label shown in the configuration dialog |
| `description` | Yes | Help text shown beneath the field |
| `sensitive` | No | If `true`, masks input and stores in secure storage |
| `required` | No | If `true`, validation fails when empty |
| `default` | No | Value used when the user provides nothing |
| `multiple` | No | For `string` type, allow an array of strings |
| `min` / `max` | No | Bounds for `number` type |

Values are available as `${user_config.KEY}` in configs and as `CLAUDE_PLUGIN_OPTION_<KEY>` env vars.

### Hook events supported in plugins

Plugin hooks use the same events as user-defined hooks. See [hooks-doc] for the full event table. Hook types available: `command`, `http`, `mcp_tool`, `prompt`, `agent`.

### Agent frontmatter (plugin agents)

Supported: `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation` (only `"worktree"` valid). **Not supported** for plugin agents: `hooks`, `mcpServers`, `permissionMode`.

### LSP server fields

**Required**: `command`, `extensionToLanguage`

**Optional**: `args`, `transport` (`stdio` or `socket`), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`

### Monitor fields

**Required**: `name`, `command`, `description`

**Optional**: `when` — `"always"` (default) or `"on-skill-invoke:<skill-name>"`

Monitors run only in interactive CLI sessions. Require Claude Code v2.1.105+.

### Version management

Version resolution order (first set wins):
1. `version` in `plugin.json`
2. `version` in the marketplace entry
3. Git commit SHA of the plugin's source
4. `unknown` (for npm sources or non-git local directories)

| Approach | How | Best for |
| :--- | :--- | :--- |
| **Explicit version** | Set `"version": "2.1.0"` in `plugin.json` | Published plugins with stable release cycles |
| **Commit-SHA version** | Omit `version` from both `plugin.json` and marketplace entry | Internal/team plugins under active development |

### Installation scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` | `~/.claude/settings.json` | Personal, across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Read-only, admin-controlled |

### CLI plugin commands

| Command | Description |
| :--- | :--- |
| `claude plugin install <plugin> [--scope user\|project\|local]` | Install a plugin |
| `claude plugin uninstall <plugin> [--keep-data] [--prune]` | Remove a plugin |
| `claude plugin enable <plugin>` | Enable a disabled plugin (also enables its dependencies) |
| `claude plugin disable <plugin>` | Disable a plugin (blocked if another enabled plugin depends on it) |
| `claude plugin update <plugin>` | Update to the latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin details <name>` | Show component inventory and token cost |
| `claude plugin prune [--dry-run] [-y]` | Remove orphaned auto-installed dependencies |
| `claude plugin tag [--push] [--dry-run]` | Create a release git tag for version resolution |
| `claude plugin validate [--strict]` | Validate `plugin.json`, frontmatter, and `hooks.json` |

### Testing plugins locally

```bash
# Load a local plugin directory
claude --plugin-dir ./my-plugin

# Load a .zip archive (requires v2.1.128+)
claude --plugin-dir ./my-plugin.zip

# Load from a hosted URL
claude --plugin-url https://example.com/my-plugin.zip

# Load multiple plugins
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

Run `/reload-plugins` to pick up changes without restarting.

### Interactive plugin UI commands

| Command | Description |
| :--- | :--- |
| `/plugin` | Open plugin manager (Discover / Installed / Marketplaces / Errors tabs) |
| `/plugin install <name>@<marketplace>` | Install a plugin |
| `/plugin uninstall <name>@<marketplace>` | Remove a plugin |
| `/plugin enable <name>@<marketplace>` | Enable a plugin |
| `/plugin disable <name>@<marketplace>` | Disable a plugin |
| `/plugin marketplace add <source>` | Add a marketplace |
| `/plugin marketplace list` | List configured marketplaces |
| `/plugin marketplace update [name]` | Refresh marketplace listings |
| `/plugin marketplace remove <name>` | Remove a marketplace |
| `/reload-plugins` | Reload all active plugins mid-session |

### Marketplace schema (`marketplace.json`)

**Required fields**: `name` (kebab-case, no spaces), `owner` (`{ name, email? }`), `plugins` (array)

**Optional fields**: `description`, `version`, `metadata.pluginRoot`, `allowCrossMarketplaceDependenciesOn`

**Plugin entry required fields**: `name`, `source`

**Plugin source types**:

| Type | Format | Notes |
| :--- | :--- | :--- |
| Relative path | `"./plugins/my-plugin"` | Only works with git-based marketplaces |
| `github` | `{ source: "github", repo: "owner/repo", ref?, sha? }` | |
| `url` | `{ source: "url", url: "...", ref?, sha? }` | Any git host |
| `git-subdir` | `{ source: "git-subdir", url: "...", path: "...", ref?, sha? }` | Sparse clone of monorepo subdirectory |
| `npm` | `{ source: "npm", package: "...", version?, registry? }` | |

**Strict mode** (`strict` field on plugin entry):
- `true` (default): `plugin.json` is the authority; marketplace entry supplements it
- `false`: marketplace entry is the entire definition; `plugin.json` must not declare components

### Plugin dependency version constraints

Declare in `plugin.json` `dependencies` array:

```json
{ "name": "secrets-vault", "version": "~2.1.0" }
```

| Field | Description |
| :--- | :--- |
| `name` | Plugin name to depend on |
| `version` | Semver range (e.g., `~2.1.0`, `^2.0`, `>=1.4`) |
| `marketplace` | Different marketplace to resolve from (requires `allowCrossMarketplaceDependenciesOn`) |

Tag releases with `claude plugin tag --push` which creates `{plugin-name}--v{version}` git tags.

**Constraint conflict errors**:

| Error | Meaning | Fix |
| :--- | :--- | :--- |
| `dependency-unsatisfied` | Dependency not installed or disabled | `claude plugin install <dep>` |
| `range-conflict` | Ranges cannot be combined | Uninstall/update conflicting plugin or widen constraint |
| `dependency-version-unsatisfied` | Installed version outside declared range | `claude plugin install <dep>@<marketplace>` |
| `no-matching-tag` | No `{name}--v*` tag satisfying range | Tag upstream releases or relax range |

### Official Anthropic marketplaces

| Marketplace | How to add | Purpose |
| :--- | :--- | :--- |
| `claude-plugins-official` | Pre-installed (auto-available) | Curated plugins by Anthropic |
| `claude-community` | `/plugin marketplace add anthropics/claude-plugins-community` | Community third-party submissions |
| Demo (`claude-code-plugins`) | `/plugin marketplace add anthropics/claude-code` | Example plugins |

Submit plugins to community marketplace at claude.ai/settings/plugins/submit or platform.claude.com/plugins/submit.

### Managed marketplace restrictions (`strictKnownMarketplaces`)

| Value | Behavior |
| :--- | :--- |
| Undefined (default) | No restrictions |
| `[]` (empty array) | Complete lockdown — no new marketplaces |
| Array of sources | Only listed marketplaces allowed |

Source types in allowlist: exact GitHub/URL entries, `hostPattern` (regex on host), `pathPattern` (regex on filesystem path).

### Plugin caching

- Marketplace plugins are copied to `~/.claude/plugins/cache` (not used in-place)
- Previous versions are retained for ~7 days after update then cleaned up
- Plugins cannot reference files outside their directory (`../` paths do not work)
- Symlinks within the plugin directory are preserved; symlinks to sibling marketplace plugins are dereferenced and content copied

### Environment variables for plugin behavior

| Variable | Description |
| :--- | :--- |
| `CLAUDE_CODE_PLUGIN_SEED_DIR` | Pre-populated plugin directory for containers/CI |
| `CLAUDE_CODE_PLUGIN_CACHE_DIR` | Override default plugin cache location |
| `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE=1` | Keep stale cache when `git pull` fails (offline environments) |
| `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` | Override 120s git operation timeout (in milliseconds) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — Quickstart, plugin structure, skills/agents/hooks/LSP/monitors, local testing, migration from standalone config
- [Plugins reference](references/claude-code-plugins-reference.md) — Complete technical specs: manifest schema, CLI commands, component schemas, debugging tools, versioning
- [Discover and install plugins](references/claude-code-discover-plugins.md) — Marketplaces, install scopes, official marketplace plugin catalog, managing plugins
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — Marketplace schema, plugin sources, hosting, private repos, managed restrictions, version channels
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — Dependency declarations, version ranges, cross-marketplace deps, tagging, conflict resolution

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
