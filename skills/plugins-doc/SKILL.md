---
name: plugins-doc
description: Complete official documentation for Claude Code plugins — plugin structure, manifest schema, skills/agents/hooks/MCP/LSP/monitors in plugins, marketplace creation and distribution, plugin installation and discovery, dependency version constraints, CLI commands, and debugging.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

### Standalone vs Plugin Configuration

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugins** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teams, distributing to community, versioned releases |

### Plugin Directory Structure

| Directory / File | Location | Purpose |
| :--- | :--- | :--- |
| `.claude-plugin/plugin.json` | Plugin root | Plugin manifest (optional; only `plugin.json` goes here) |
| `skills/` | Plugin root | Skills as `<name>/SKILL.md` directories |
| `commands/` | Plugin root | Skills as flat Markdown files (legacy; use `skills/` for new plugins) |
| `agents/` | Plugin root | Subagent definitions |
| `hooks/hooks.json` | Plugin root | Event hook configuration |
| `.mcp.json` | Plugin root | MCP server configurations |
| `.lsp.json` | Plugin root | LSP server configurations |
| `monitors/monitors.json` | Plugin root | Background monitor configurations |
| `output-styles/` | Plugin root | Output style definitions |
| `themes/` | Plugin root | Color theme definitions (experimental) |
| `bin/` | Plugin root | Executables added to Bash tool `PATH` |
| `settings.json` | Plugin root | Default settings (only `agent` and `subagentStatusLine` supported) |

**Common mistake**: Never put `skills/`, `agents/`, `hooks/`, or other component directories inside `.claude-plugin/`. Only `plugin.json` belongs there.

### Plugin Manifest Schema (`.claude-plugin/plugin.json`)

**Required** (if manifest is present): `name`

**Metadata fields:**

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique identifier (kebab-case). Used as skill namespace: `/name:skill` |
| `version` | string | Semver. If set, users only get updates when you bump it. If omitted, git commit SHA is used |
| `description` | string | Brief plugin purpose |
| `author` | object | `{name, email, url}` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier (e.g., `"MIT"`) |
| `keywords` | array | Discovery tags |
| `$schema` | string | JSON Schema URL for editor validation (ignored at load time) |

**Component path fields** (all optional; replace defaults when set):

| Field | Type | Description |
| :--- | :--- | :--- |
| `skills` | string\|array | Custom skill directories (`<name>/SKILL.md`). Replaces default `skills/` |
| `commands` | string\|array | Custom flat `.md` skill files or directories. Replaces default `commands/` |
| `agents` | string\|array | Custom agent files. Replaces default `agents/` |
| `hooks` | string\|array\|object | Hook config paths or inline config |
| `mcpServers` | string\|array\|object | MCP config paths or inline config |
| `lspServers` | string\|array\|object | LSP server configurations |
| `outputStyles` | string\|array | Output style files/directories |
| `experimental.themes` | string\|array | Color theme files/directories |
| `experimental.monitors` | string\|array | Background monitor configurations |
| `userConfig` | object | User-configurable values prompted at enable time |
| `channels` | array | Message channel declarations (Telegram, Slack, Discord) |
| `dependencies` | array | Other plugins this plugin requires |

All custom paths must be relative to plugin root and start with `./`.

### Environment Variables in Plugin Configs

| Variable | Description |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin's installation directory. Ephemeral — changes on update |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state that survives updates. Created automatically |
| `${user_config.KEY}` | User-configured values from `userConfig` field |

`${CLAUDE_PLUGIN_DATA}` resolves to `~/.claude/plugins/data/{id}/`. Use it for `node_modules`, caches, and generated files.

### User Configuration (`userConfig`)

Declared in `plugin.json`; Claude Code prompts users when the plugin is enabled.

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label shown in configuration dialog |
| `description` | Yes | Help text shown beneath the field |
| `sensitive` | No | If `true`, masks input and stores in secure storage (not `settings.json`) |
| `required` | No | If `true`, validation fails when empty |
| `default` | No | Value when user provides nothing |
| `multiple` | No | For `string`: allow an array of strings |
| `min`/`max` | No | Bounds for `number` type |

Values exported as `CLAUDE_PLUGIN_OPTION_<KEY>` to subprocesses. Sensitive values go to system keychain (~2 KB limit).

### Plugin Agents (Frontmatter Fields)

| Field | Description |
| :--- | :--- |
| `name` | Agent name |
| `description` | When Claude should invoke this agent |
| `model` | Model to use (e.g., `sonnet`) |
| `effort` | `low`, `medium`, `high` |
| `maxTurns` | Maximum turn count |
| `disallowedTools` | Tools the agent cannot use |
| `tools` | Explicit tool allowlist |
| `skills` | Skills the agent can use |
| `memory` | Memory configuration |
| `background` | Background agent settings |
| `isolation` | Only `"worktree"` is valid |

**Not supported** for plugin agents: `hooks`, `mcpServers`, `permissionMode`.

### Hook Events Available to Plugins

Plugins support the same hook events as user-defined hooks. Key events:

| Event | Fires when | Can block? |
| :--- | :--- | :--- |
| `SessionStart` | Session begins/resumes | No |
| `PreToolUse` | Before tool call | Yes |
| `PostToolUse` | After tool call succeeds | No |
| `PostToolUseFailure` | After tool call fails | No |
| `Stop` | Claude finishes responding | Yes |
| `SessionEnd` | Session terminates | No |
| `FileChanged` | Watched file changes (matcher = filenames) | No |
| `WorktreeCreate` | Worktree being created | Yes |
| `WorktreeRemove` | Worktree being removed | No |

Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`.

Plugin hooks go in `hooks/hooks.json` or inline in `plugin.json`. Use `${CLAUDE_PLUGIN_ROOT}` for all script paths.

### LSP Servers

**Required fields:**

| Field | Description |
| :--- | :--- |
| `command` | LSP binary to execute (must be in PATH) |
| `extensionToLanguage` | Maps file extensions to language IDs |

**Optional fields:** `args`, `transport` (`stdio`/`socket`), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`.

**Available official LSP plugins** (install binary separately):

| Plugin | Language | Binary |
| :--- | :--- | :--- |
| `pyright-lsp` | Python | `pyright-langserver` |
| `typescript-lsp` | TypeScript | `typescript-language-server` |
| `rust-analyzer-lsp` | Rust | `rust-analyzer` |
| `gopls-lsp` | Go | `gopls` |
| `clangd-lsp` | C/C++ | `clangd` |

### Background Monitors

**Required fields:**

| Field | Description |
| :--- | :--- |
| `name` | Unique identifier within the plugin |
| `command` | Shell command run as persistent background process |
| `description` | Short summary shown in task panel |

**Optional fields:**

| Field | Description |
| :--- | :--- |
| `when` | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

Each stdout line from `command` is delivered to Claude as a notification. Monitors require Claude Code v2.1.105+. They run only in interactive CLI sessions.

### Plugin Installation Scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` | `~/.claude/settings.json` | Personal plugins across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled, read-only |

### CLI Commands Reference

```bash
# Plugin management
claude plugin install <plugin>[@marketplace] [--scope user|project|local]
claude plugin uninstall <plugin> [--scope] [--keep-data] [--prune] [-y]
claude plugin enable <plugin> [--scope]
claude plugin disable <plugin> [--scope]
claude plugin update <plugin> [--scope]
claude plugin list [--json] [--available]
claude plugin prune [--scope] [--dry-run] [-y]          # requires v2.1.121+
claude plugin tag [--push] [--dry-run] [-f]             # tag plugin releases
claude plugin validate [path]

# Marketplace management
claude plugin marketplace add <source> [--scope] [--sparse <paths...>]
claude plugin marketplace list [--json]
claude plugin marketplace remove <name>
claude plugin marketplace update [name]
```

**In-session commands:** `/plugin`, `/reload-plugins`, `/plugin install`, `/plugin marketplace add`, `/plugin validate`

**Dev/test flags:**
- `claude --plugin-dir ./my-plugin` — load plugin without installing
- `claude --plugin-url https://example.com/my-plugin.zip` — load from archive URL
- Multiple `--plugin-dir` flags supported

### Version Management

Version resolution order (first set wins):
1. `version` in `plugin.json`
2. `version` in marketplace entry
3. Git commit SHA (for `github`, `url`, `git-subdir`, relative-path sources)
4. `unknown` (for npm sources or non-git local dirs)

| Approach | How | Update behavior |
| :--- | :--- | :--- |
| Explicit version | Set `"version": "2.1.0"` in `plugin.json` | Users get updates only when you bump the field |
| Commit-SHA version | Omit `version` from both `plugin.json` and marketplace entry | Users get updates on every new commit |

### Marketplace (`marketplace.json`) Schema

**Location**: `.claude-plugin/marketplace.json` in the marketplace repository.

**Required fields**: `name`, `owner` (with `name`), `plugins` array.

**Plugin entry required fields**: `name`, `source`.

**Plugin source types:**

| Source | Format | Fields |
| :--- | :--- | :--- |
| Relative path | `"./my-plugin"` string | Must start with `./`. Only works with git-hosted marketplaces |
| `github` | object | `repo` (required), `ref`, `sha` |
| `url` | object | `url` (required), `ref`, `sha` |
| `git-subdir` | object | `url`, `path` (both required), `ref`, `sha` |
| `npm` | object | `package` (required), `version`, `registry` |

**Strict mode** (`strict` field in marketplace plugin entry):
- `true` (default): `plugin.json` is authority; marketplace entry supplements
- `false`: marketplace entry is the entire definition; plugin must not have `plugin.json` with component declarations

### Plugin Dependencies

Declare in `plugin.json` `dependencies` array:
```json
{ "name": "secrets-vault", "version": "~2.1.0" }
```

| Field | Description |
| :--- | :--- |
| `name` | Plugin name (resolves in same marketplace by default) |
| `version` | Semver range: `~2.1.0`, `^2.0`, `>=1.4`, `=2.1.0` |
| `marketplace` | Different marketplace to resolve in (must be in `allowCrossMarketplaceDependenciesOn`) |

Tag releases with: `claude plugin tag --push` (creates `{plugin-name}--v{version}` git tag).

Dependency errors:

| Error | Meaning | Fix |
| :--- | :--- | :--- |
| `dependency-unsatisfied` | Dependency not installed or disabled | Run `claude plugin install <dep>` |
| `range-conflict` | Version requirements cannot be combined | Uninstall one conflicting plugin |
| `dependency-version-unsatisfied` | Installed version outside declared range | Re-install dependency |
| `no-matching-tag` | No git tag satisfying the range | Check tags or relax range |

### Debugging

| Tool | Description |
| :--- | :--- |
| `claude --debug` | Shows plugin loading, manifest errors, component registration, MCP init |
| `claude plugin validate .` | Validates `plugin.json`, skill/agent frontmatter, `hooks/hooks.json` |
| `/plugin` Errors tab | View plugin loading errors in-session |
| `/reload-plugins` | Reload all plugins mid-session without restart |

**Common issues:**

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` |
| Skills not appearing | Wrong directory structure | Move `skills/` to plugin root (not inside `.claude-plugin/`) |
| Hooks not firing | Script not executable | `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin paths |
| LSP `Executable not found` | Language server binary missing | Install the binary (e.g., `npm install -g typescript-language-server`) |

### Plugin Caching

Marketplace plugins are copied to `~/.claude/plugins/cache` (not used in-place). Consequences:
- Plugins cannot reference files outside their directory (`../shared-utils` won't work)
- Use symlinks inside the plugin directory to reference external files
- Previous version directories are kept ~7 days after update then removed
- `claude --plugin-dir` loads plugins in-place without caching (for dev)

### Managed Marketplace Restrictions

Set `strictKnownMarketplaces` in managed settings to control which marketplaces users can add:

| Value | Behavior |
| :--- | :--- |
| Undefined (default) | No restrictions |
| `[]` (empty array) | Complete lockdown |
| List of sources | Allowlist with exact matching |
| `{"source": "hostPattern", "hostPattern": "^..."}` | Regex match on host |
| `{"source": "pathPattern", "pathPattern": "^/opt/..."}` | Regex match on filesystem path |

### Pre-populating Plugins for Containers

```bash
# Build seed directory
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin marketplace add your-org/plugins
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin install my-tool@your-plugins

# At runtime, point at seed
export CLAUDE_CODE_PLUGIN_SEED_DIR=/opt/claude-seed
```

Seed directories are read-only; auto-updates are disabled for seed marketplaces.

### Converting Standalone Config to Plugin

| Standalone (`.claude/`) | Plugin |
| :--- | :--- |
| Only available in one project | Shareable via marketplaces |
| `.claude/commands/` | `plugin-name/commands/` |
| Hooks in `settings.json` | `hooks/hooks.json` |
| Manual copy to share | Install with `/plugin install` |

Migration: Create `.claude-plugin/plugin.json`, copy `commands/`, `agents/`, `skills/`, convert hooks to `hooks/hooks.json`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — quickstart, plugin structure, skills/agents/LSP/monitors/settings, local testing, debug, migration from standalone config
- [Plugins reference](references/claude-code-plugins-reference.md) — complete schemas for manifest, all components, CLI commands, environment variables, caching, versioning
- [Discover and install plugins](references/claude-code-discover-plugins.md) — official marketplace, adding marketplaces from GitHub/git/local/URL, installing/managing plugins, LSP plugins, team marketplaces, security, troubleshooting
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace.json schema, plugin sources, hosting on GitHub/git/npm, private repos, release channels, managed restrictions, container pre-population, CLI marketplace commands, troubleshooting
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring dependencies, semver ranges, cross-marketplace dependencies, tagging releases, constraint intersection, pruning orphaned dependencies

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
