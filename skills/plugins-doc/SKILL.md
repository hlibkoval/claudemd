---
name: plugins-doc
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins — self-contained directories of components (skills, agents, hooks, MCP servers, LSP servers, monitors, themes) that extend Claude Code and can be shared through marketplaces.

## Quick Reference

### Standalone vs Plugin

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugins** (directory + optional `.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teammates, community distribution, reuse across projects |

### Plugin Directory Structure

| Directory / File | Location | Purpose |
| :--- | :--- | :--- |
| `.claude-plugin/plugin.json` | Plugin root | Manifest (optional but recommended) |
| `skills/` | Plugin root | Skills as `<name>/SKILL.md` subdirectories |
| `commands/` | Plugin root | Skills as flat Markdown files (legacy; prefer `skills/`) |
| `agents/` | Plugin root | Subagent definitions |
| `hooks/hooks.json` | Plugin root | Event handlers |
| `.mcp.json` | Plugin root | MCP server configurations |
| `.lsp.json` | Plugin root | LSP server configurations |
| `monitors/monitors.json` | Plugin root | Background monitor configurations |
| `output-styles/` | Plugin root | Output style definitions |
| `themes/` | Plugin root | Color theme JSON files |
| `bin/` | Plugin root | Executables added to Bash tool `PATH` |
| `settings.json` | Plugin root | Default settings (only `agent` and `subagentStatusLine` keys) |

**Warning**: Only `plugin.json` belongs inside `.claude-plugin/`. All other directories must be at the plugin root.

A single `SKILL.md` at the plugin root (no `skills/` directory, no `skills` manifest field) is loaded as a single-skill plugin. The frontmatter `name` field controls the invocation name; the directory basename is used as a fallback.

### Plugin Manifest Schema (`plugin.json`)

**Required field:**

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique kebab-case identifier; becomes the skill namespace |

**Metadata fields:**

| Field | Type | Description |
| :--- | :--- | :--- |
| `displayName` | string | Human-readable name for UI (v2.1.143+); may contain spaces |
| `version` | string | Explicit semver; if set, users only get updates when bumped |
| `description` | string | Brief plugin purpose |
| `author` | object | `name`, `email`, `url` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier, e.g. `"MIT"` |
| `keywords` | array | Discovery tags |
| `defaultEnabled` | boolean | `false` to install disabled (v2.1.154+; default `true`) |

**Component path fields** (all paths relative to plugin root, must start with `./`):

| Field | Type | Behavior |
| :--- | :--- | :--- |
| `skills` | string\|array | Adds to the default `skills/` scan |
| `commands` | string\|array | Replaces default `commands/` scan |
| `agents` | string\|array | Replaces default `agents/` scan |
| `hooks` | string\|array\|object | Path(s) or inline config; merged |
| `mcpServers` | string\|array\|object | Path(s) or inline config; merged |
| `lspServers` | string\|array\|object | Path(s) or inline config; merged |
| `outputStyles` | string\|array | Replaces default `output-styles/` scan |
| `experimental.themes` | string\|array | Replaces default `themes/` scan |
| `experimental.monitors` | string\|array | Background monitors (v2.1.105+) |
| `userConfig` | object | Prompted at enable time; available as `${user_config.KEY}` |
| `channels` | array | Message injection channels (each binds to an MCP server) |
| `dependencies` | array | Other plugins required; string or `{name, version, marketplace}` |

**`userConfig` option fields:**

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label in the config dialog |
| `description` | Yes | Help text |
| `sensitive` | No | Mask input; store in keychain instead of `settings.json` |
| `required` | No | Fail validation if empty |
| `default` | No | Value when user provides nothing |
| `multiple` | No | Allow array of strings (string type only) |
| `min`/`max` | No | Bounds for number type |

### Environment Variables in Plugin Configs

| Variable | Resolves to |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory (changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for state across updates (`~/.claude/plugins/data/{id}/`) |
| `${CLAUDE_PROJECT_DIR}` | Project root (same as hook `CLAUDE_PROJECT_DIR`) |
| `${user_config.KEY}` | Value from `userConfig.KEY` (non-sensitive only in skill/agent content) |

Use exec form (`args: []`) or quote `"${CLAUDE_PLUGIN_ROOT}"` in shell-form commands to handle paths with spaces.

### Plugin Installation Scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` | `~/.claude/settings.json` | Personal, all projects (default) |
| `project` | `.claude/settings.json` | Team, shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled, read-only |

### CLI Commands Reference

| Command | Description |
| :--- | :--- |
| `claude plugin init <name> [--with skills hooks mcp lsp agents output-style channel]` | Scaffold a new plugin in `~/.claude/skills/<name>/` |
| `claude plugin install <plugin>[@marketplace] [--scope user\|project\|local]` | Install a plugin |
| `claude plugin uninstall <plugin> [--keep-data] [--prune] [-y]` | Remove a plugin |
| `claude plugin prune [--dry-run] [-y] [--scope]` | Remove orphaned auto-installed dependencies (v2.1.121+) |
| `claude plugin enable <plugin> [--scope]` | Enable a disabled plugin (also enables dependencies) |
| `claude plugin disable <plugin> [--scope]` | Disable without uninstalling (blocked if another plugin depends on it) |
| `claude plugin update <plugin> [--scope]` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin details <name>` | Show component inventory and projected token cost |
| `claude plugin tag [--push] [--dry-run] [-f]` | Create a release git tag in `{plugin-name}--v{version}` format |
| `claude plugin validate [path] [--strict]` | Validate `plugin.json`, skill/agent frontmatter, hooks |
| `claude plugin marketplace add <source> [--scope] [--sparse]` | Add a marketplace |
| `claude plugin marketplace list [--json]` | List configured marketplaces |
| `claude plugin marketplace remove <name> [--scope]` | Remove a marketplace |
| `claude plugin marketplace update [name]` | Refresh marketplace catalog |

Interactive session commands: `/plugin`, `/plugin list`, `/reload-plugins`.

### Skills-Directory Plugins

Any folder under a skills directory containing `.claude-plugin/plugin.json` loads automatically as `<name>@skills-dir` — no marketplace install needed.

| Skills directory | Scope | Loads |
| :--- | :--- | :--- |
| `~/.claude/skills/` | personal | All projects |
| `<cwd>/.claude/skills/` | project | After workspace trust is accepted |

Project-scope `@skills-dir` plugins: MCP servers require per-server approval; LSP servers require workspace trust; background monitors do not load.

### Version Management

Version is resolved from the first set:
1. `version` in `plugin.json`
2. `version` in the marketplace entry
3. Git commit SHA of the plugin's source
4. `unknown` (npm sources or non-git local directories)

| Approach | How | Update behavior |
| :--- | :--- | :--- |
| **Explicit version** | `"version": "2.1.0"` in `plugin.json` | Users get updates only when you bump the field |
| **Commit-SHA version** | Omit `version` everywhere | Every new commit is a new version |

### Marketplace File (`marketplace.json`) — Key Fields

Location: `.claude-plugin/marketplace.json` in the marketplace repository.

**Top-level required:** `name` (kebab-case, unique per user), `owner` (`{name, email?}`), `plugins` (array).

**Optional top-level:** `description`, `version`, `metadata.pluginRoot` (base path for relative plugin sources), `allowCrossMarketplaceDependenciesOn` (array of other marketplace names whose plugins may be auto-installed as dependencies).

**Plugin entry required:** `name`, `source`.

**Plugin source types:**

| Source type | `source` value | Key fields |
| :--- | :--- | :--- |
| Relative path | `"./path"` | Works only with git-based marketplace add |
| GitHub | `{"source": "github", "repo": "owner/repo"}` | `ref`, `sha` |
| Git URL | `{"source": "url", "url": "https://..."}` | `ref`, `sha` |
| Git subdirectory | `{"source": "git-subdir", "url": "...", "path": "..."}` | `ref`, `sha` |
| npm | `{"source": "npm", "package": "@org/pkg"}` | `version`, `registry` |

When both `ref` and `sha` are set on git sources, `sha` is the effective pin.

**Marketplace sources** (where to fetch `marketplace.json`): GitHub `owner/repo`, git URL, local path, or remote URL. Added with `/plugin marketplace add` or `extraKnownMarketplaces`.

### Marketplace Discovery Commands

| Command | Description |
| :--- | :--- |
| `/plugin marketplace add anthropics/claude-plugins-official` | Already registered automatically at first launch |
| `/plugin marketplace add anthropics/claude-plugins-community` | Add the community marketplace |
| `/plugin install <name>@claude-plugins-official` | Install from official marketplace |
| `/plugin install <name>@claude-community` | Install from community marketplace |

### Plugin Dependencies

Declare in `dependencies` array in `plugin.json`:

```
"dependencies": [
  "audit-logger",
  { "name": "secrets-vault", "version": "~2.1.0" },
  { "name": "other-tool", "marketplace": "other-market" }
]
```

Version field accepts semver ranges: `~2.1.0`, `^2.0`, `>=1.4`, `=2.1.0`. Resolved against `{plugin-name}--v{version}` git tags. Enabling a plugin also enables its dependencies; disabling is blocked if another enabled plugin depends on it.

Dependency errors: `dependency-unsatisfied`, `range-conflict`, `dependency-version-unsatisfied`, `no-matching-tag`.

### Monitors

Declared in `monitors/monitors.json` (array), or inline in `plugin.json` under `experimental.monitors`. Requires v2.1.105+.

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique within plugin; prevents duplicate processes |
| `command` | Yes | Shell command run as persistent background process |
| `description` | Yes | Short summary shown in task panel |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

Each stdout line is delivered to Claude as a notification. Monitors run only in interactive CLI sessions, unsandboxed. Disabling a plugin mid-session does not stop running monitors.

### Plugin Hints (CLI Recommendation)

CLIs that have a plugin in the official marketplace can prompt users to install it by writing to stderr when `CLAUDECODE=1` is set:

```
<claude-code-hint v="1" type="plugin" value="example-cli@claude-plugins-official" />
```

Requirements: must be on its own line; must reference a plugin in an official Anthropic marketplace. Claude Code strips the line before it reaches the model. Each plugin is prompted at most once per session and once ever.

### Common Debugging Checklist

| Issue | Cause | Fix |
| :--- | :--- | :--- |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate ./my-plugin` |
| Skills not appearing | Wrong directory structure | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Script not executable | `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin-relative paths |
| LSP `Executable not found` | Language server binary missing | Install the binary (e.g. `npm install -g typescript-language-server typescript`) |
| Path errors | Absolute paths used | All paths must be relative and start with `./` |

Use `claude --debug` to see plugin loading details. Use `/plugin` Errors tab for LSP and hook errors.

### Container / CI: Pre-populate Plugins

Set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a pre-built plugins directory (mirrors `~/.claude/plugins`). Layer multiple directories with `:` (Unix) or `;` (Windows). Seed is read-only; auto-updates disabled for seed marketplaces.

Set `CLAUDE_CODE_PLUGIN_CACHE_DIR` at build time to install directly into the seed path:
```bash
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/seed claude plugin install my-tool@your-plugins
```

### Managed Marketplace Restrictions

Admins control allowed marketplaces via `strictKnownMarketplaces` in managed settings:
- Empty array `[]`: complete lockdown
- List of source objects: exact-match allowlist
- `{"source": "hostPattern", "hostPattern": "^github\\.example\\.com$"}`: regex on host
- `{"source": "pathPattern", "pathPattern": "^/opt/approved/"}`: regex on filesystem path

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — Quickstart, plugin structure overview, adding skills/LSP/monitors/settings, testing locally, migrating from standalone config, submitting to community marketplace
- [Plugins reference](references/claude-code-plugins-reference.md) — Complete schemas for all components (skills, agents, hooks, MCP, LSP, monitors, themes), manifest fields, installation scopes, skills-directory plugins, CLI command reference, debugging tools, version management
- [Discover and install plugins](references/claude-code-discover-plugins.md) — Official and community marketplaces, LSP plugin table, managing installed plugins, marketplace add/remove/update, configure team marketplaces, security, troubleshooting
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — Marketplace file schema, plugin source types, hosting on GitHub/GitLab/private repos, container pre-population, managed restrictions, release channels, version resolution, troubleshooting
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — Declaring dependencies with semver ranges, cross-marketplace dependencies, git tag convention, constraint intersection, enable/disable with dependencies, pruning orphaned dependencies
- [Recommend your plugin from your CLI](references/claude-code-plugin-hints.md) — Hint protocol, emit marker from Node/Python/Go/Shell, `CLAUDECODE` vs `CLAUDE_CODE_CHILD_SESSION`, hint format and requirements, getting into the official marketplace

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
- Recommend your plugin from your CLI: https://code.claude.com/docs/en/plugin-hints.md
