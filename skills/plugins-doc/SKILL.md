---
name: plugins-doc
description: Complete official documentation for Claude Code plugins — creating plugins, plugin manifest schema, plugin components (skills, agents, hooks, MCP servers, LSP servers, monitors, themes), discovering and installing plugins, creating marketplaces, plugin sources, version management, dependency constraints, and CLI commands.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

### Plugin Structure

```text
my-plugin/
├── .claude-plugin/
│   └── plugin.json        # manifest (optional)
├── skills/                # <name>/SKILL.md directories
├── commands/              # flat .md skill files (legacy)
├── agents/                # subagent definitions
├── hooks/
│   └── hooks.json
├── .mcp.json              # MCP server configs
├── .lsp.json              # LSP server configs
├── monitors/
│   └── monitors.json      # background monitors
├── output-styles/
├── themes/
├── bin/                   # executables added to PATH
└── settings.json          # default settings (agent/subagentStatusLine only)
```

**Common mistake**: `commands/`, `agents/`, `skills/`, `hooks/` must be at the plugin root — NOT inside `.claude-plugin/`.

### plugin.json Manifest Schema

```json
{
  "name": "plugin-name",
  "version": "1.2.0",
  "description": "Brief description",
  "author": { "name": "Name", "email": "email", "url": "url" },
  "homepage": "https://docs.example.com",
  "repository": "https://github.com/author/plugin",
  "license": "MIT",
  "keywords": ["keyword1"],
  "skills": "./custom/skills/",
  "commands": ["./custom/commands/special.md"],
  "agents": ["./custom/agents/reviewer.md"],
  "hooks": "./config/hooks.json",
  "mcpServers": "./mcp-config.json",
  "lspServers": "./.lsp.json",
  "monitors": "./monitors.json",
  "themes": "./themes/",
  "dependencies": [
    "helper-lib",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```

| Field | Required | Notes |
| :--- | :--- | :--- |
| `name` | Yes (if manifest exists) | Kebab-case; used as skill namespace prefix |
| `version` | No | Omit to use git commit SHA for versioning |
| `description` | No | Shown in plugin manager |
| `author` | No | Attribution |

### Test a Plugin Locally

```bash
claude --plugin-dir ./my-plugin

# Load multiple plugins
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

Inside Claude Code, run `/reload-plugins` to pick up changes without restarting.

### Skill Namespacing

Plugin skills are always namespaced: `/plugin-name:skill-name`. To change the prefix, update `name` in `plugin.json`.

### Environment Variables

| Variable | Description |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to the plugin's install directory (changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for state that survives updates (`~/.claude/plugins/data/{id}/`) |

Both are substituted inline in skill/agent content, hook commands, monitor commands, MCP/LSP configs, and exported to subprocesses.

### User Configuration

Declare user-configurable values in `plugin.json` under `userConfig`. Claude Code prompts for them when the plugin is enabled.

```json
{
  "userConfig": {
    "api_endpoint": {
      "type": "string",
      "title": "API endpoint",
      "description": "Your team's API endpoint"
    },
    "api_token": {
      "type": "string",
      "title": "API token",
      "description": "API auth token",
      "sensitive": true
    }
  }
}
```

| Field | Required | Options |
| :--- | :--- | :--- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, `file` |
| `title` | Yes | Shown in config dialog |
| `description` | Yes | Help text |
| `sensitive` | No | Stores in system keychain instead of settings.json |
| `required` | No | Validate non-empty |
| `default` | No | Value when user provides nothing |
| `multiple` | No | Allow array for `string` type |
| `min`/`max` | No | Bounds for `number` type |

Available as `${user_config.KEY}` in configs, and as `CLAUDE_PLUGIN_OPTION_<KEY>` env vars in subprocesses.

### Hooks in Plugins

Place hooks in `hooks/hooks.json` (or inline in `plugin.json`). Same lifecycle events as user hooks.

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

Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`.

### Background Monitors

`monitors/monitors.json` (or inline `monitors` key in `plugin.json`):

```json
[
  {
    "name": "error-log",
    "command": "tail -F ./logs/error.log",
    "description": "Application error log",
    "when": "always"
  }
]
```

| Field | Required | Notes |
| :--- | :--- | :--- |
| `name` | Yes | Unique within plugin |
| `command` | Yes | Shell command run as persistent background process |
| `description` | Yes | Shown in task panel |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

Requires Claude Code v2.1.105+. Runs only in interactive CLI sessions.

### LSP Servers

`.lsp.json` (or inline `lspServers` in `plugin.json`):

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": { ".go": "go" }
  }
}
```

| Field | Required | Notes |
| :--- | :--- | :--- |
| `command` | Yes | LSP binary (must be in PATH) |
| `extensionToLanguage` | Yes | Maps file extensions to language IDs |
| `args`, `transport`, `env`, `initializationOptions`, `settings` | No | Optional config |
| `restartOnCrash`, `maxRestarts`, `startupTimeout`, `shutdownTimeout` | No | Reliability settings |

Official LSP plugins from the marketplace: `pyright-lsp`, `typescript-lsp`, `rust-analyzer-lsp`, `gopls-lsp`, `clangd-lsp`, and more.

### Themes

Place JSON files in `themes/`. Selected as `custom:<plugin-name>:<slug>` in user config.

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

### Plugin Installation Scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` | `~/.claude/settings.json` | Personal plugins across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Read-only, admin-controlled |

### Discover and Install Plugins

```shell
# In-app plugin manager
/plugin

# Install from official marketplace
/plugin install github@claude-plugins-official

# Add a marketplace
/plugin marketplace add owner/repo
/plugin marketplace add https://gitlab.com/company/plugins.git
/plugin marketplace add ./my-local-marketplace

# After installing/changing plugins
/reload-plugins
```

### CLI Plugin Commands

```bash
claude plugin install <plugin> [--scope user|project|local]
claude plugin uninstall <plugin> [--keep-data] [--prune]
claude plugin enable <plugin>
claude plugin disable <plugin>
claude plugin update <plugin>
claude plugin list [--json] [--available]
claude plugin prune [--dry-run] [-y]
claude plugin tag [--push] [--dry-run]

claude plugin marketplace add <source> [--scope] [--sparse <paths...>]
claude plugin marketplace list [--json]
claude plugin marketplace remove <name>
claude plugin marketplace update [name]

claude plugin validate .
```

### Marketplace `marketplace.json` Schema

```json
{
  "name": "company-tools",
  "owner": { "name": "DevTools Team", "email": "dev@example.com" },
  "description": "...",
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

Plugin sources in `source` field:

| Source type | Example |
| :--- | :--- |
| Relative path | `"./plugins/my-plugin"` |
| GitHub | `{ "source": "github", "repo": "owner/repo", "ref": "v1.0", "sha": "..." }` |
| Git URL | `{ "source": "url", "url": "https://gitlab.com/team/plugin.git", "ref": "main" }` |
| Git subdirectory | `{ "source": "git-subdir", "url": "https://github.com/org/monorepo.git", "path": "tools/plugin" }` |
| npm | `{ "source": "npm", "package": "@org/plugin", "version": "^2.0.0", "registry": "..." }` |

### Version Management

Version is resolved from first available:
1. `version` in `plugin.json`
2. `version` in marketplace entry
3. Git commit SHA (for git-backed sources)
4. `"unknown"` (for npm or non-git local)

Setting `version` pins the plugin — users only get updates when you bump the field. Omit to use commit SHA (every commit = new version).

### Plugin Dependency Constraints

In `plugin.json`:

```json
{
  "name": "deploy-kit",
  "version": "3.1.0",
  "dependencies": [
    "audit-logger",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```

Version constraint uses semver ranges (`~2.1.0`, `^2.0`, `>=1.4`, `=2.1.0`). Tag releases as `{plugin-name}--v{version}` for resolution to work:

```bash
claude plugin tag --push
```

Dependency errors:

| Error | Meaning | Fix |
| :--- | :--- | :--- |
| `dependency-unsatisfied` | Dependency not installed/enabled | Install missing dependency |
| `range-conflict` | Incompatible version ranges across plugins | Uninstall one conflicting plugin |
| `dependency-version-unsatisfied` | Installed version outside declared range | Re-resolve with `claude plugin install` |
| `no-matching-tag` | No tagged release satisfies the range | Check tags or relax range |

### Debugging

```bash
claude --debug    # See plugin loading details, errors, registration

/plugin validate  # Check plugin.json, frontmatter, hooks.json for errors
/plugin           # View Errors tab for load errors
```

Common issues:

| Issue | Cause | Fix |
| :--- | :--- | :--- |
| Plugin not loading | Invalid `plugin.json` | Run `/plugin validate` |
| Skills not appearing | Wrong directory structure | Move `skills/` to plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Script not executable | `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin-relative paths |
| LSP `Executable not found` | Language server not installed | Install binary (e.g., `npm install -g typescript-language-server typescript`) |

### Convert Standalone Config to Plugin

1. Create `my-plugin/.claude-plugin/plugin.json` with `name`, `description`, `version`
2. Copy `.claude/commands/` → `my-plugin/commands/`
3. Copy `.claude/agents/` → `my-plugin/agents/`
4. Copy `.claude/skills/` → `my-plugin/skills/`
5. Copy hooks from `settings.json` → `my-plugin/hooks/hooks.json`
6. Test: `claude --plugin-dir ./my-plugin`

### Team Marketplace Setup

In `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "company-tools": {
      "source": { "source": "github", "repo": "your-org/claude-plugins" }
    }
  },
  "enabledPlugins": {
    "code-formatter@company-tools": true
  }
}
```

### Managed Marketplace Restrictions (Enterprise)

In managed settings, `strictKnownMarketplaces` controls which marketplaces users can add:
- `undefined` — no restrictions
- `[]` — complete lockdown
- List of sources — allowlist (supports `github`, `url`, `hostPattern`, `pathPattern`)

### Pre-populate Plugins for Containers

```bash
# Build seed directory
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin marketplace add your-org/plugins
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin install my-tool@your-plugins

# Use at runtime
export CLAUDE_CODE_PLUGIN_SEED_DIR=/opt/claude-seed
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — creating plugin manifests, adding skills/agents/hooks/MCP/LSP/monitors, testing locally, converting from standalone config, sharing
- [Plugins reference](references/claude-code-plugins-reference.md) — complete technical specifications: manifest schema, component configs, environment variables, userConfig, channels, path behavior, CLI commands, debugging, version management
- [Discover and install plugins](references/claude-code-discover-plugins.md) — official marketplace, LSP plugin table, adding marketplaces, installing/managing plugins, team marketplace setup, troubleshooting
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace.json schema, plugin sources (GitHub/git/npm/relative paths), hosting, private repos, container seed dirs, managed restrictions, version/release channels, troubleshooting
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring dependencies, semver ranges, cross-marketplace dependencies, tagging releases, constraint intersection, pruning orphans, error resolution

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
