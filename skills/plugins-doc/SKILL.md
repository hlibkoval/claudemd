---
name: plugins-doc
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

### Standalone vs Plugin

| Approach | Skill names | Best for |
|:---------|:------------|:---------|
| **Standalone** (`.claude/` directory) | `/hello` | Personal, project-specific, quick experiments |
| **Plugin** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teammates, distribution, reuse across projects |

### Plugin Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json        ← only manifest here
├── skills/                ← <name>/SKILL.md directories
├── commands/              ← flat .md files (legacy; prefer skills/)
├── agents/                ← subagent definitions
├── hooks/
│   └── hooks.json
├── bin/                   ← executables added to PATH
├── .mcp.json
├── .lsp.json
├── monitors/
│   └── monitors.json
├── settings.json          ← default settings (agent/subagentStatusLine only)
└── themes/                ← color theme JSON files (experimental)
```

**Common mistake**: Never put `skills/`, `agents/`, `hooks/`, or `commands/` inside `.claude-plugin/`. Only `plugin.json` goes there.

### Plugin Manifest (`plugin.json`) Schema

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes (if manifest present) | Unique kebab-case identifier; used as skill namespace |
| `displayName` | No | Human-readable name for UI (v2.1.143+) |
| `version` | No | Semver string; omit to use git commit SHA as version |
| `description` | No | Brief description shown in plugin manager |
| `author` | No | Object with `name`, `email`, `url` |
| `homepage` | No | Documentation URL |
| `repository` | No | Source code URL |
| `license` | No | SPDX identifier (e.g. `MIT`) |
| `keywords` | No | Array of discovery tags |
| `skills` | No | Extra skill directories (adds to default `skills/`) |
| `commands` | No | Custom command paths (replaces default `commands/`) |
| `agents` | No | Custom agent paths (replaces default `agents/`) |
| `hooks` | No | Hooks config path/object (inline or file) |
| `mcpServers` | No | MCP server config path/object |
| `lspServers` | No | LSP server config path/object |
| `outputStyles` | No | Output style paths (replaces default `output-styles/`) |
| `experimental.themes` | No | Color theme paths (replaces default `themes/`) |
| `experimental.monitors` | No | Background monitor config |
| `userConfig` | No | User-configurable values prompted at enable time |
| `channels` | No | Message channel declarations (bound to MCP servers) |
| `dependencies` | No | Array of required plugin names or `{name, version, marketplace}` objects |

### Path Behavior Rules

- `skills`: **adds to** default `skills/` directory
- `commands`, `agents`, `outputStyles`, `experimental.themes`, `experimental.monitors`: **replace** their default directory
- `hooks`, `mcpServers`, `lspServers`: have their own merge rules (multiple sources combined)
- All manifest paths must be relative and start with `./`

### Environment Variables in Plugins

| Variable | Description |
|:---------|:------------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin's installation directory (ephemeral, changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent data directory surviving updates (`~/.claude/plugins/data/{id}/`) |
| `${CLAUDE_PROJECT_DIR}` | Project root directory |

Available in: skill/agent content, hook commands, monitor commands, MCP/LSP configs. Also exported as env vars to subprocesses.

### Plugin Installation Scopes

| Scope | Settings file | Use case |
|:------|:-------------|:---------|
| `user` (default) | `~/.claude/settings.json` | Personal, all projects |
| `project` | `.claude/settings.json` | Team, shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | managed settings | Admin-controlled, read-only |

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude plugin install <name>@<marketplace> [--scope user\|project\|local]` | Install a plugin |
| `claude plugin uninstall <name> [--keep-data] [--prune]` | Remove a plugin |
| `claude plugin enable/disable <name>` | Toggle without uninstalling |
| `claude plugin update <name>` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin details <name>` | Show component inventory and token cost |
| `claude plugin validate [path] [--strict]` | Validate plugin/marketplace JSON |
| `claude plugin prune [--dry-run] [-y]` | Remove orphaned auto-installed deps |
| `claude plugin tag [--push] [--dry-run]` | Create release git tag |
| `claude plugin marketplace add <source>` | Add a marketplace |
| `claude plugin marketplace list` | List configured marketplaces |
| `claude plugin marketplace update [name]` | Refresh marketplace listings |
| `claude plugin marketplace remove <name>` | Remove a marketplace |

### Testing Locally

```bash
# Load a local plugin directory
claude --plugin-dir ./my-plugin

# Load a .zip archive (v2.1.128+)
claude --plugin-dir ./my-plugin.zip

# Load from a URL
claude --plugin-url https://example.com/my-plugin.zip

# Multiple plugins
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

Run `/reload-plugins` during a session to pick up changes without restarting.

### Version Management

| Approach | How | Update behavior | Best for |
|:---------|:----|:----------------|:---------|
| **Explicit version** | Set `"version": "2.1.0"` in `plugin.json` | Update only when field is bumped | Stable release cycles |
| **Commit-SHA version** | Omit `version` from `plugin.json` and marketplace entry | Every new commit is a new version | Internal/active development |

Version resolution order: `plugin.json` version → marketplace entry version → git commit SHA → `unknown`.

### User Configuration (`userConfig`)

Declares values that Claude Code prompts for at enable time. Each key supports:

| Field | Required | Description |
|:------|:---------|:------------|
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label in config dialog |
| `description` | Yes | Help text |
| `sensitive` | No | If `true`, stores in system keychain, not settings.json |
| `required` | No | Fails validation if empty |
| `default` | No | Value when user provides nothing |
| `multiple` | No | Allow array of strings (string type only) |
| `min`/`max` | No | Bounds for number type |

Values accessible as `${user_config.KEY}` in configs and `CLAUDE_PLUGIN_OPTION_<KEY>` env vars.

### Monitors

Background processes that deliver stdout lines to Claude as notifications. Require v2.1.105+.

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier within plugin |
| `command` | Yes | Shell command run as persistent background process |
| `description` | Yes | Summary shown in task panel |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

Supports `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`, `${CLAUDE_PROJECT_DIR}`, `${user_config.*}` substitutions.

### LSP Servers

| Field | Required | Description |
|:------|:---------|:------------|
| `command` | Yes | LSP binary to execute (must be in PATH) |
| `extensionToLanguage` | Yes | Maps file extensions to language identifiers |
| `args` | No | Command-line arguments |
| `transport` | No | `stdio` (default) or `socket` |
| `env` | No | Environment variables |
| `initializationOptions` | No | Options passed at initialization |
| `settings` | No | Settings via `workspace/didChangeConfiguration` |
| `restartOnCrash` | No | Auto-restart if server crashes |
| `maxRestarts` | No | Max restart attempts |

Available official LSP plugins: `pyright-lsp` (Python), `typescript-lsp` (TypeScript), `rust-analyzer-lsp` (Rust), `gopls-lsp` (Go), `clangd-lsp` (C/C++), and others via the official marketplace.

### Marketplace Structure

`marketplace.json` at `.claude-plugin/marketplace.json`:

```json
{
  "name": "my-marketplace",
  "owner": { "name": "Team Name" },
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin",
      "description": "Plugin description"
    }
  ]
}
```

### Plugin Sources in `marketplace.json`

| Source type | Format | Notes |
|:------------|:-------|:------|
| Relative path | `"./my-plugin"` | Local dir in same repo; requires git-based marketplace |
| `github` | `{"source": "github", "repo": "owner/repo", "ref"?: "...", "sha"?: "..."}` | |
| `url` | `{"source": "url", "url": "https://...", "ref"?: "...", "sha"?: "..."}` | Git URL |
| `git-subdir` | `{"source": "git-subdir", "url": "...", "path": "...", "ref"?: "...", "sha"?: "..."}` | Sparse clone |
| `npm` | `{"source": "npm", "package": "@org/pkg", "version"?: "...", "registry"?: "..."}` | |

### Adding Marketplaces

```shell
# GitHub shorthand
/plugin marketplace add anthropics/claude-code

# Git URL (GitLab, etc.)
/plugin marketplace add https://gitlab.com/company/plugins.git

# Pin to branch/tag
/plugin marketplace add anthropics/claude-code@v2.0

# Local directory
/plugin marketplace add ./my-marketplace
```

### Official Anthropic Marketplaces

| Marketplace | Add command | Notes |
|:------------|:------------|:------|
| `claude-plugins-official` | Pre-installed | Curated by Anthropic |
| `claude-community` | `/plugin marketplace add anthropics/claude-plugins-community` | Third-party reviewed plugins |
| `claude-code-plugins` (demo) | `/plugin marketplace add anthropics/claude-code` | Example plugins |

### Plugin Dependency Version Constraints

Declare in `plugin.json` `dependencies` array. Each entry is a string (name only) or object:

| Field | Description |
|:------|:------------|
| `name` | Plugin name (resolves in same marketplace) |
| `version` | Semver range (e.g. `~2.1.0`, `^2.0`, `>=1.4`) |
| `marketplace` | Other marketplace to resolve from (requires `allowCrossMarketplaceDependenciesOn`) |

Tag releases with `claude plugin tag --push` to create `{plugin-name}--v{version}` git tags.

### Plugin Hint Protocol (CLI Integration)

CLIs can emit a hint to prompt Claude Code users to install a plugin. Write to stderr when `CLAUDECODE` env var is set:

```
<claude-code-hint v="1" type="plugin" value="example-cli@claude-plugins-official" />
```

Requirements: must be on its own line; plugin must be in an official Anthropic marketplace. Prompt shown once per plugin per session. Only works for plugins in `claude-plugins-official`.

### Debugging

| Technique | Description |
|:----------|:------------|
| `claude --debug` | Shows plugin loading details, manifest errors, registration |
| `/plugin validate [path]` | Validate plugin.json and component frontmatter |
| `/plugin validate --strict` | Treat warnings as errors |
| `claude plugin details <name>` | Show token cost breakdown |
| `/plugin` Errors tab | View plugin loading errors |
| `/reload-plugins` | Reload without restarting session |

### Common Issues

| Issue | Cause | Solution |
|:------|:-------|:---------|
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` |
| Skills not appearing | Wrong directory structure | Ensure `skills/` at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Script not executable | `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin paths |
| LSP `Executable not found` | Language server not installed | Install the binary separately |
| Path errors | Absolute paths used | All paths must be relative, starting with `./` |

### Migrating Standalone Config to a Plugin

| Standalone | Plugin |
|:-----------|:-------|
| `.claude/commands/` | `plugin-name/commands/` |
| `.claude/agents/` | `plugin-name/agents/` |
| `.claude/skills/` | `plugin-name/skills/` |
| Hooks in `settings.json` | `hooks/hooks.json` |
| Single project only | Shareable via `/plugin install` |

### Submitting to Community Marketplace

Run `claude plugin validate` first, then submit via:
- Claude.ai: `claude.ai/settings/plugins/submit`
- Console: `platform.claude.com/plugins/submit`

Approved plugins appear in `anthropics/claude-plugins-community` catalog (may take up to 24h after approval).

## Full Documentation

For the complete official documentation, see the reference files:

- [Create Plugins](references/claude-code-plugins.md) — Quickstart, plugin structure, skills/agents/hooks/LSP/monitors, testing locally, sharing, migrating from standalone config
- [Plugins Reference](references/claude-code-plugins-reference.md) — Complete technical specs: manifest schema, component schemas, CLI commands, environment variables, caching, debugging
- [Discover and Install Plugins](references/claude-code-discover-plugins.md) — Official marketplace, community marketplace, installing/managing plugins and marketplaces, auto-updates, team configuration
- [Create and Distribute a Plugin Marketplace](references/claude-code-plugin-marketplaces.md) — Marketplace file format, plugin sources, hosting, private repos, version channels, managed restrictions, container seeding
- [Constrain Plugin Dependency Versions](references/claude-code-plugin-dependencies.md) — Declaring version constraints, cross-marketplace dependencies, release tagging, conflict resolution
- [Recommend Your Plugin from Your CLI](references/claude-code-plugin-hints.md) — Hint protocol for CLI tools to prompt Claude Code users to install a plugin

## Sources

- Create Plugins: https://code.claude.com/docs/en/plugins.md
- Plugins Reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and Install Plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and Distribute a Plugin Marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain Plugin Dependency Versions: https://code.claude.com/docs/en/plugin-dependencies.md
- Recommend Your Plugin from Your CLI: https://code.claude.com/docs/en/plugin-hints.md
