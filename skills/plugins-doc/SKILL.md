---
name: plugins-doc
description: Complete official documentation for the Claude Code plugin system — creating plugins, plugin manifest schema, component types (skills, agents, hooks, MCP servers, LSP servers, monitors, themes), discovering and installing plugins, marketplace creation and distribution, plugin dependencies and version constraints, installation scopes, CLI commands, debugging, and environment variables.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for the Claude Code plugin system.

## Quick Reference

### Plugin vs Standalone Configuration

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugins** (directory with `.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with team/community, versioned releases, reusable across projects |

### Plugin Directory Structure

```
my-plugin/
├── .claude-plugin/           # Contains only plugin.json
│   └── plugin.json
├── skills/                   # Skills with <name>/SKILL.md structure
├── commands/                 # Skills as flat .md files (legacy; prefer skills/)
├── agents/                   # Subagent definitions
├── hooks/
│   └── hooks.json            # Hook event handlers
├── .mcp.json                 # MCP server configurations
├── .lsp.json                 # LSP server configurations
├── monitors/
│   └── monitors.json         # Background monitor configurations
├── themes/                   # Color theme definitions
├── output-styles/            # Output style definitions
├── bin/                      # Executables added to Bash tool PATH
└── settings.json             # Default settings (only agent/subagentStatusLine)
```

**Common mistake:** Components (`skills/`, `agents/`, `hooks/`, etc.) must be at the plugin root — NOT inside `.claude-plugin/`. Only `plugin.json` goes inside `.claude-plugin/`.

### Plugin Manifest (`plugin.json`) Schema

```json
{
  "name": "plugin-name",
  "version": "1.2.0",
  "description": "Brief plugin description",
  "author": { "name": "Author", "email": "author@example.com", "url": "https://..." },
  "homepage": "https://docs.example.com/plugin",
  "repository": "https://github.com/author/plugin",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2"],
  "skills": "./custom/skills/",
  "commands": ["./custom/commands/special.md"],
  "agents": ["./custom/agents/reviewer.md"],
  "hooks": "./config/hooks.json",
  "mcpServers": "./mcp-config.json",
  "lspServers": "./.lsp.json",
  "experimental": {
    "themes": "./themes/",
    "monitors": "./monitors.json"
  },
  "dependencies": [
    "helper-lib",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ],
  "userConfig": {
    "api_token": {
      "type": "string",
      "title": "API token",
      "description": "Your API token",
      "sensitive": true
    }
  }
}
```

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes (if manifest exists) | Unique identifier, kebab-case. Used as skill namespace prefix. |
| `version` | No | Semantic version. If omitted, falls back to git commit SHA for updates. |
| `description` | No | Shown in plugin manager |
| `author` | No | Attribution |
| `dependencies` | No | Other plugins this plugin requires (with optional semver constraints) |
| `userConfig` | No | Values prompted at enable time; available as `${user_config.KEY}` |
| `channels` | No | Message channels binding to an MCP server (Telegram, Slack, Discord style) |

**Path fields behavior:**
- `skills`: ADDS to default `skills/` (both are scanned)
- `commands`, `agents`, `outputStyles`, `experimental.themes`, `experimental.monitors`: REPLACE default directories
- `hooks`, `mcpServers`, `lspServers`: have their own merge rules

### Environment Variables in Plugin Configs

| Variable | Resolves to | Use for |
| :--- | :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory | Scripts, binaries, config files bundled with plugin |
| `${CLAUDE_PLUGIN_DATA}` | `~/.claude/plugins/data/{id}/` | Persistent state surviving updates (node_modules, caches) |
| `${CLAUDE_PROJECT_DIR}` | Project root | Project-local scripts or config files |

In shell-form hooks/monitors, always quote: `"${CLAUDE_PLUGIN_ROOT}"`. In exec-form hooks, pass as `args` element without quoting.

### Development and Testing

```bash
# Test plugin locally (no install needed)
claude --plugin-dir ./my-plugin

# Test from a zip archive (requires v2.1.128+)
claude --plugin-dir ./my-plugin.zip

# Test from a hosted URL
claude --plugin-url https://example.com/my-plugin.zip

# Load multiple plugins
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two

# Reload without restarting
/reload-plugins

# Validate plugin manifest and components
claude plugin validate .
/plugin validate .

# Debug loading issues
claude --debug
```

When `--plugin-dir` plugin has same name as an installed plugin, local copy takes precedence for that session.

### Plugin Installation Scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` (default) | `~/.claude/settings.json` | Personal plugins across all projects |
| `project` | `.claude/settings.json` | Team plugins shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled, read-only |

### CLI Plugin Commands

```bash
# Install / uninstall
claude plugin install <plugin>[@marketplace] [--scope user|project|local]
claude plugin uninstall <plugin>[@marketplace] [--scope user] [--keep-data] [--prune]

# Enable / disable (without uninstalling)
claude plugin enable <plugin>[@marketplace] [--scope ...]
claude plugin disable <plugin>[@marketplace] [--scope ...]

# Update
claude plugin update <plugin>[@marketplace] [--scope ...]

# List and inspect
claude plugin list [--json] [--available]
claude plugin details <name>

# Prune orphaned auto-installed dependencies
claude plugin prune [--scope ...] [--dry-run] [-y]

# Tag a release
claude plugin tag [--push] [--dry-run] [-f]
```

### CLI Marketplace Commands

```bash
# Add marketplace sources
claude plugin marketplace add owner/repo                        # GitHub shorthand
claude plugin marketplace add https://gitlab.com/org/repo.git  # Git URL
claude plugin marketplace add ./my-local-marketplace           # Local path
claude plugin marketplace add https://example.com/marketplace.json  # Remote URL
claude plugin marketplace add owner/repo@v2.0                  # Pin to ref
claude plugin marketplace add owner/monorepo --sparse .claude-plugin plugins  # Monorepo

# Manage
claude plugin marketplace list [--json]
claude plugin marketplace update [marketplace-name]
claude plugin marketplace remove <marketplace-name>
```

### Plugin Components Reference

#### Hooks

Plugin hooks use `hooks/hooks.json` (or inline in `plugin.json`). Supported events:

| Key events | When |
| :--- | :--- |
| `SessionStart` / `SessionEnd` | Session begins / terminates |
| `PreToolUse` / `PostToolUse` | Before/after a tool call (PreToolUse can block) |
| `UserPromptSubmit` | Before Claude processes a prompt |
| `Stop` | When Claude finishes responding |
| `FileChanged` | When a watched file changes (matcher = filenames to watch) |
| `SubagentStart` / `SubagentStop` | Subagent spawned / finished |
| `WorktreeCreate` / `WorktreeRemove` | Worktree lifecycle |
| `PreCompact` / `PostCompact` | Context compaction lifecycle |
| `CwdChanged` | Working directory changed |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded |

Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "\"${CLAUDE_PLUGIN_ROOT}\"/scripts/format.sh" }]
      }
    ]
  }
}
```

#### Monitors (requires v2.1.105+)

Background processes that deliver stdout lines to Claude as notifications.

```json
[
  {
    "name": "error-log",
    "command": "tail -F ./logs/error.log",
    "description": "Application error log",
    "when": "always"
  },
  {
    "name": "deploy-status",
    "command": "\"${CLAUDE_PLUGIN_ROOT}\"/scripts/poll.sh",
    "description": "Deployment status",
    "when": "on-skill-invoke:debug"
  }
]
```

`when` values: `"always"` (default, starts at session start) or `"on-skill-invoke:<skill-name>"`.

#### LSP Servers

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": { ".go": "go" }
  }
}
```

Optional LSP fields: `transport` (`stdio`/`socket`), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`.

**Official LSP plugins:** `pyright-lsp`, `typescript-lsp`, `rust-analyzer-lsp`, `gopls-lsp`, `clangd-lsp`, `csharp-lsp`, `jdtls-lsp`, `kotlin-lsp`, `lua-lsp`, `php-lsp`, `swift-lsp`

#### Agents

```markdown
---
name: agent-name
description: What this agent does and when to invoke it
model: sonnet
effort: medium
maxTurns: 20
disallowedTools: Write, Edit
---

System prompt for the agent.
```

Supported agent frontmatter: `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation` (only valid value: `"worktree"`). NOT supported in plugin agents: `hooks`, `mcpServers`, `permissionMode`.

### Marketplace Schema

```json
{
  "name": "my-marketplace",
  "owner": { "name": "Team Name", "email": "team@example.com" },
  "description": "Brief marketplace description",
  "metadata": { "pluginRoot": "./plugins" },
  "allowCrossMarketplaceDependenciesOn": ["acme-shared"],
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

**Plugin source types:**

| Source | Format | Notes |
| :--- | :--- | :--- |
| Relative path | `"./plugins/my-plugin"` | Must start with `./`; only works with Git-based marketplaces |
| `github` | `{ "source": "github", "repo": "owner/repo", "ref": "v2.0", "sha": "..." }` | |
| `url` | `{ "source": "url", "url": "https://gitlab.com/org/repo.git", "ref": "...", "sha": "..." }` | |
| `git-subdir` | `{ "source": "git-subdir", "url": "...", "path": "tools/plugin", "ref": "...", "sha": "..." }` | Sparse clone |
| `npm` | `{ "source": "npm", "package": "@org/plugin", "version": "^2.0", "registry": "https://..." }` | |

**Strict mode:** `"strict": true` (default) = `plugin.json` is authority; marketplace can supplement. `"strict": false` = marketplace entry is the entire definition.

### Plugin Dependency Version Constraints

Declare in `plugin.json`:

```json
{
  "dependencies": [
    "audit-logger",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```

Tag releases for version resolution: `claude plugin tag --push` creates `{plugin-name}--v{version}` tags.

**Dependency error codes:**

| Error | Meaning | Fix |
| :--- | :--- | :--- |
| `dependency-unsatisfied` | Dependency not installed or disabled | Run `claude plugin install <dep>` |
| `range-conflict` | Incompatible version ranges across plugins | Uninstall/update conflicting plugin |
| `dependency-version-unsatisfied` | Installed version outside declared range | Re-resolve: `claude plugin install <dep>@<marketplace>` |
| `no-matching-tag` | No git tag satisfies the range | Check upstream tags or relax range |

### Version Management

Version is resolved from first match:
1. `version` in `plugin.json`
2. `version` in marketplace entry
3. Git commit SHA of plugin source
4. `unknown` (npm or non-git local)

| Approach | How | Best for |
| :--- | :--- | :--- |
| Explicit version | Set `"version"` in `plugin.json` | Published plugins with stable release cycles |
| Commit-SHA version | Omit `version` entirely | Internal/team plugins under active development |

### Plugin Caching

Marketplace plugins are copied to `~/.claude/plugins/cache` — not used in-place. Plugins cannot reference files outside their directory. Previous version directories are cleaned up ~7 days after update.

Symlinks within a marketplace: symlinks to files within the plugin's own directory are preserved; symlinks to sibling plugins in the same marketplace are dereferenced (content copied); symlinks outside the marketplace are skipped for security.

### Container/CI Pre-Population

```bash
# Build seed directory
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin marketplace add your-org/plugins
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin install my-tool@your-plugins

# At runtime, point at seed
export CLAUDE_CODE_PLUGIN_SEED_DIR=/opt/claude-seed
```

Seed directories are read-only; auto-updates are disabled for seed marketplaces.

### Managed Marketplace Restrictions (Enterprise)

Set `strictKnownMarketplaces` in managed settings to control which marketplaces users can add:
- `undefined` = no restrictions
- `[]` = complete lockdown
- List of sources = allowlist (exact match for github/url; regex for `hostPattern`/`pathPattern`)

### Common Debugging

| Issue | Likely cause | Fix |
| :--- | :--- | :--- |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` |
| Skills not appearing | Wrong directory (inside `.claude-plugin/`) | Move to plugin root |
| Hooks not firing | Script not executable | `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` in path | Use variable for all plugin paths |
| LSP `Executable not found in $PATH` | Language server binary missing | Install the binary separately |
| Path errors | Absolute paths used | All paths must be relative and start with `./` |

### Env Vars for Plugin System

| Variable | Effect |
| :--- | :--- |
| `CLAUDE_CODE_PLUGIN_SEED_DIR` | Pre-populated plugin directory for containers |
| `CLAUDE_CODE_PLUGIN_CACHE_DIR` | Override plugin cache location |
| `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE=1` | Retain stale clone when git pull fails (offline environments) |
| `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` | Git operation timeout in ms (default 120000) |
| `DISABLE_AUTOUPDATER` + `FORCE_AUTOUPDATE_PLUGINS=1` | Disable Claude Code updates but keep plugin updates |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — quickstart, plugin structure, skills/agents/hooks/LSP/monitors, testing locally, migrating from standalone config
- [Plugins reference](references/claude-code-plugins-reference.md) — complete component schemas, manifest schema, CLI commands, environment variables, caching, debugging
- [Discover and install plugins](references/claude-code-discover-plugins.md) — official marketplace, adding marketplaces, installing/managing plugins, scopes, auto-updates, team configuration
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace schema, plugin sources, hosting, private repos, version channels, managed restrictions, CLI marketplace commands
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring dependencies, version constraints, tagging releases, cross-marketplace dependencies, resolving errors

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
