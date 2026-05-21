---
name: plugins-doc
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for the Claude Code plugin system — creating, distributing, discovering, and managing plugins.

## Quick Reference

### Standalone Config vs Plugins

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` directory) | `/hello` | Personal, single-project, quick experiments |
| **Plugins** (`.claude-plugin/plugin.json` directory) | `/plugin-name:hello` | Team sharing, multi-project reuse, versioned distribution |

### Plugin Directory Layout

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          ← manifest (only file here)
├── skills/<name>/SKILL.md   ← skills (namespaced as /plugin-name:skill)
├── commands/                ← flat .md skills (legacy)
├── agents/                  ← subagent definitions
├── hooks/hooks.json         ← event handlers
├── .mcp.json                ← MCP server configs
├── .lsp.json                ← LSP server configs
├── monitors/monitors.json   ← background monitors
├── themes/                  ← color themes
├── bin/                     ← executables added to PATH
├── output-styles/           ← output style definitions
└── settings.json            ← default settings (agent + subagentStatusLine only)
```

**Warning**: Only `plugin.json` belongs in `.claude-plugin/`. All other directories go at the plugin root.

### plugin.json Manifest Schema

```json
{
  "name": "my-plugin",           // required; also the skill namespace
  "displayName": "My Plugin",    // optional; human-readable, v2.1.143+
  "version": "1.2.0",            // optional; omit to use git commit SHA
  "description": "...",
  "author": { "name": "...", "email": "..." },
  "homepage": "...",
  "repository": "...",
  "license": "MIT",
  "keywords": ["tag1"],
  "skills": "./custom/skills/",  // adds to default skills/
  "commands": "./custom/cmd.md", // replaces default commands/
  "agents": "./agents/",
  "hooks": "./config/hooks.json",
  "mcpServers": "./.mcp.json",
  "lspServers": "./.lsp.json",
  "experimental": {
    "themes": "./themes/",
    "monitors": "./monitors.json"
  },
  "userConfig": { ... },
  "dependencies": ["helper-lib", { "name": "vault", "version": "~2.1.0" }]
}
```

**Path behavior**: `skills` adds to the default `skills/` directory; `commands`, `agents`, `outputStyles`, `experimental.themes`, `experimental.monitors` replace their default directories.

### Environment Variables Available in Plugin Configs

| Variable | Purpose |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to the plugin's installation directory (use for bundled scripts) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent data directory that survives plugin updates (`~/.claude/plugins/data/{id}/`) |
| `${CLAUDE_PROJECT_DIR}` | Project root (same as hooks receive) |
| `${user_config.KEY}` | User-configurable values from `userConfig` in `plugin.json` |

### Plugin Installation Scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` (default) | `~/.claude/settings.json` | Personal, all projects |
| `project` | `.claude/settings.json` | Team, shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-deployed, read-only |

### Testing Locally

```bash
# Load plugin for a session (also accepts .zip archives, v2.1.128+)
claude --plugin-dir ./my-plugin
claude --plugin-dir ./my-plugin.zip

# Load from a remote ZIP (same trust rules as installed plugins)
claude --plugin-url https://example.com/my-plugin.zip

# Reload without restarting
/reload-plugins

# Validate plugin structure and manifest
claude plugin validate ./my-plugin
claude plugin validate ./my-plugin --strict   # warnings as errors
```

### CLI Plugin Commands

| Command | Description |
| :--- | :--- |
| `claude plugin install <plugin>[@marketplace]` | Install plugin (default scope: user) |
| `claude plugin uninstall <plugin>` | Remove plugin (aliases: `remove`, `rm`) |
| `claude plugin uninstall <plugin> --keep-data` | Remove without deleting data directory |
| `claude plugin uninstall <plugin> --prune` | Also remove orphaned auto-installed deps |
| `claude plugin enable <plugin>` | Enable a disabled plugin |
| `claude plugin disable <plugin>` | Disable without uninstalling |
| `claude plugin update <plugin>` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin details <name>` | Show component inventory and token cost estimate |
| `claude plugin tag [--push] [--dry-run]` | Create release git tag for version resolution |
| `claude plugin prune [--dry-run] [-y]` | Remove orphaned auto-installed dependencies (aliases: `autoremove`) |

### Marketplace CLI Commands

| Command | Description |
| :--- | :--- |
| `claude plugin marketplace add <source>` | Add a marketplace (GitHub `owner/repo`, git URL, local path, or remote URL) |
| `claude plugin marketplace add <source> --scope project` | Add at project scope |
| `claude plugin marketplace add owner/repo@v2.0` | Pin to a branch/tag |
| `claude plugin marketplace list [--json]` | List configured marketplaces |
| `claude plugin marketplace update [name]` | Refresh marketplace listings |
| `claude plugin marketplace remove <name>` | Remove marketplace (also uninstalls its plugins) |

### Known Marketplaces

| Marketplace | How to add | Notes |
| :--- | :--- | :--- |
| `claude-plugins-official` | Auto-available | Curated by Anthropic; browse at claude.com/plugins |
| `claude-community` | `/plugin marketplace add anthropics/claude-plugins-community` | Third-party, Anthropic-validated |
| `claude-code-plugins` (demo) | `/plugin marketplace add anthropics/claude-code` | Example plugins |

### marketplace.json Schema

```json
{
  "name": "my-marketplace",      // required; kebab-case; user-facing
  "owner": { "name": "...", "email": "..." },  // required
  "description": "...",
  "metadata": { "pluginRoot": "./plugins" },   // base path for relative sources
  "allowCrossMarketplaceDependenciesOn": ["other-marketplace"],
  "plugins": [
    {
      "name": "my-plugin",        // required; kebab-case
      "source": "./plugins/my-plugin",   // required; see sources below
      "description": "...",
      "version": "1.0.0",
      "strict": true              // default; false lets marketplace override plugin.json components
    }
  ]
}
```

### Plugin Sources in marketplace.json

| Source type | Example |
| :--- | :--- |
| Relative path (git-hosted marketplace only) | `"./plugins/my-plugin"` |
| GitHub repo | `{ "source": "github", "repo": "owner/repo", "ref": "v2.0", "sha": "abc123..." }` |
| Git URL | `{ "source": "url", "url": "https://gitlab.com/team/plugin.git", "ref": "main" }` |
| Git subdirectory | `{ "source": "git-subdir", "url": "https://github.com/org/monorepo.git", "path": "tools/plugin" }` |
| npm package | `{ "source": "npm", "package": "@org/plugin", "version": "2.1.0", "registry": "..." }` |

### Version Management

Version is resolved from the first of these that is set:
1. `version` in `plugin.json`
2. `version` in the marketplace entry
3. Git commit SHA of the plugin source
4. `unknown` (npm or non-git local)

**Explicit version** (`"version": "1.0.0"`): users only get updates when you bump the field. **Commit-SHA version** (omit `version`): every commit is a new version — best for active development.

### Plugin Dependencies

Declare in `plugin.json`:

```json
{
  "dependencies": [
    "audit-logger",
    { "name": "secrets-vault", "version": "~2.1.0" },
    { "name": "shared-lib", "marketplace": "other-marketplace" }
  ]
}
```

- Version field accepts any semver range (`^2.0`, `~2.1`, `>=1.4`, `=2.1.0`)
- Cross-marketplace deps require `allowCrossMarketplaceDependenciesOn` in `marketplace.json`
- Tag releases with `claude plugin tag --push` using the `{plugin-name}--v{version}` convention
- `claude plugin prune` removes auto-installed deps that no longer have any dependents

### Dependency Errors

| Error | Meaning | Fix |
| :--- | :--- | :--- |
| `dependency-unsatisfied` | Dep not installed or disabled | Run the `claude plugin install` command shown |
| `range-conflict` | Ranges for same dep are incompatible | Uninstall/update a conflicting plugin |
| `dependency-version-unsatisfied` | Installed dep version outside range | Re-run `claude plugin install <dep>@<marketplace>` |
| `no-matching-tag` | No tagged release satisfies range | Check upstream uses `{name}--v*` tagging convention |

### Hooks Available in Plugins

Plugin hooks use `hooks/hooks.json` (same event types as user hooks). Reference scripts with `"${CLAUDE_PLUGIN_ROOT}"`:

```json
{
  "hooks": {
    "PostToolUse": [
      { "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "\"${CLAUDE_PLUGIN_ROOT}\"/scripts/format.sh" }] }
    ]
  }
}
```

Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`

### Background Monitors

Declared in `monitors/monitors.json`. Each stdout line is delivered to Claude as a notification:

```json
[
  { "name": "error-log", "command": "tail -F ./logs/error.log", "description": "App errors" },
  { "name": "deploy", "command": "\"${CLAUDE_PLUGIN_ROOT}\"/poll.sh", "description": "Deploy status",
    "when": "on-skill-invoke:deploy" }
]
```

`when` field: `"always"` (default) starts at session start; `"on-skill-invoke:<skill-name>"` starts on first skill dispatch.

### userConfig — Prompt Users at Enable Time

```json
{
  "userConfig": {
    "api_endpoint": { "type": "string", "title": "API endpoint", "description": "Your team's API" },
    "api_token": { "type": "string", "title": "Token", "description": "Auth token", "sensitive": true }
  }
}
```

Types: `string`, `number`, `boolean`, `directory`, `file`. Sensitive values go to the system keychain. Non-sensitive available as `${user_config.KEY}` and `CLAUDE_PLUGIN_OPTION_<KEY>` env vars.

### Plugin Hints (CLI Integration)

CLIs with an official marketplace listing can prompt Claude Code users to install a plugin. Gate on `CLAUDECODE` env var and write to stderr:

```javascript
if (process.env.CLAUDECODE) {
  process.stderr.write('<claude-code-hint v="1" type="plugin" value="my-cli@claude-plugins-official" />\n')
}
```

Tag must be on its own line. Only works for plugins in official Anthropic marketplaces. Claude Code shows a one-time install prompt per plugin per session.

### Troubleshooting Common Issues

| Issue | Cause | Fix |
| :--- | :--- | :--- |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate ./my-plugin` |
| Skills not appearing | Wrong directory structure | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Script not executable | `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin-bundled paths |
| LSP `Executable not found in $PATH` | Language server binary missing | Install the binary (e.g., `npm install -g typescript-language-server`) |
| `dependency-unsatisfied` | Dep not installed | `claude plugin install <dep>@<marketplace>` |
| Relative path sources fail via URL marketplace | URL marketplaces don't clone files | Switch to GitHub/git-URL sources |

### Pre-populating Plugins for Containers

Set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a pre-built `~/.claude/plugins` copy. Multiple paths separated by `:` (Unix) or `;` (Windows). Seed directories are read-only — auto-updates are disabled. To build:

```bash
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin marketplace add your-org/plugins
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin install my-tool@your-plugins
# then set CLAUDE_CODE_PLUGIN_SEED_DIR=/opt/claude-seed at runtime
```

### Managed Marketplace Restrictions (`strictKnownMarketplaces`)

| Value | Behavior |
| :--- | :--- |
| Undefined (default) | No restrictions |
| `[]` | Complete lockdown |
| List of sources | Only matching marketplaces allowed |

Sources can be `{ "source": "github", "repo": "..." }`, `{ "source": "url", "url": "..." }`, `{ "source": "hostPattern", "hostPattern": "^github\\.example\\.com$" }`, or `{ "source": "pathPattern", "pathPattern": "^/opt/approved/" }`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — creating plugins with skills, agents, hooks, MCP servers, LSP servers, and monitors; plugin structure, local testing, and submission
- [Plugins reference](references/claude-code-plugins-reference.md) — complete technical specs: manifest schema, component schemas, environment variables, CLI commands, debugging, version management
- [Discover and install plugins](references/claude-code-discover-plugins.md) — browsing marketplaces, installing plugins, managing scopes, auto-updates, team configuration
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace schema, plugin sources, hosting, private repos, container seeding, managed restrictions, version channels
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring dependencies, semver constraints, tagging releases, cross-marketplace deps, pruning orphans
- [Recommend your plugin from your CLI](references/claude-code-plugin-hints.md) — hint protocol for CLI maintainers to prompt Claude Code plugin installs

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
- Recommend your plugin from your CLI: https://code.claude.com/docs/en/plugin-hints.md
