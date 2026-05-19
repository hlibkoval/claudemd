---
name: plugins-doc
description: Complete official documentation for Claude Code plugins — creating plugins (manifest schema, skills, agents, hooks, MCP/LSP servers, monitors, themes, userConfig, channels, bin/, settings.json), discovering and installing plugins (official and custom marketplaces, scopes, auto-update, team config), the plugins reference (component specs, CLI commands, environment variables, caching, version management), creating and distributing marketplaces (marketplace.json schema, plugin sources, managed restrictions, release channels, pre-populating containers), and constraining plugin dependency versions (semver constraints, cross-marketplace deps, tagging releases, pruning orphans).
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins and the plugin ecosystem.

## Quick Reference

### Plugin vs Standalone Configuration

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific customizations |
| **Plugins** (directories with `.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teammates, distributing to community, reusable across projects |

### Plugin Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json       ← Only manifest here
├── skills/               ← Plugin root (NOT inside .claude-plugin/)
├── commands/
├── agents/
├── hooks/hooks.json
├── .mcp.json
├── .lsp.json
├── monitors/monitors.json
├── output-styles/
├── themes/
├── bin/                  ← Executables added to PATH
└── settings.json         ← Only "agent" and "subagentStatusLine" keys supported
```

### plugin.json Manifest — Key Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | **Required.** Unique identifier (kebab-case); used as skill namespace prefix |
| `displayName` | string | Human-readable name shown in UI (v2.1.143+) |
| `version` | string | Explicit semver. If set, users only get updates when you bump it; omit to use git commit SHA |
| `description` | string | Brief plugin purpose |
| `author` | object | `{name, email, url}` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier (e.g. `MIT`) |
| `keywords` | array | Discovery tags |
| `skills` | string\|array | Custom skill directories (adds to default `skills/`) |
| `commands` | string\|array | Flat `.md` skill files (replaces default `commands/`) |
| `agents` | string\|array | Agent files (replaces default `agents/`) |
| `hooks` | string\|array\|object | Hook config paths or inline config |
| `mcpServers` | string\|array\|object | MCP config paths or inline config |
| `lspServers` | string\|array\|object | LSP server configurations |
| `outputStyles` | string\|array | Output style files (replaces default `output-styles/`) |
| `experimental.themes` | string\|array | Color theme files (replaces default `themes/`) |
| `experimental.monitors` | string\|array | Background monitor configurations |
| `userConfig` | object | Prompts users for config values at enable time |
| `channels` | array | Message channels that inject content (e.g. Telegram, Slack) |
| `dependencies` | array | Other plugins this plugin requires |

### Plugin Components Summary

| Component | Default Location | Description |
| :--- | :--- | :--- |
| Skills | `skills/<name>/SKILL.md` | Slash commands, user-invocable or auto-invoked |
| Commands | `commands/*.md` | Flat Markdown skills (legacy; prefer `skills/`) |
| Agents | `agents/*.md` | Subagent definitions with own prompt and tools |
| Hooks | `hooks/hooks.json` | Event handlers (same events as user hooks) |
| MCP servers | `.mcp.json` | Start automatically when plugin is active |
| LSP servers | `.lsp.json` | Real-time code intelligence |
| Monitors | `monitors/monitors.json` | Background watchers; each stdout line sent to Claude |
| Themes | `themes/*.json` | Color themes appearing in `/theme` |
| Executables | `bin/` | Added to Bash tool's PATH when plugin is active |

### Plugin Installation Scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` | `~/.claude/settings.json` | Personal plugins, all projects (default) |
| `project` | `.claude/settings.json` | Team plugins via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Read-only, administrator-controlled |

### Key CLI Commands

```bash
# Install / remove
claude plugin install plugin-name@marketplace-name
claude plugin install plugin-name@marketplace-name --scope project
claude plugin uninstall plugin-name@marketplace-name
claude plugin uninstall plugin-name@marketplace-name --prune   # also remove orphaned deps

# Enable / disable
claude plugin enable plugin-name@marketplace-name
claude plugin disable plugin-name@marketplace-name

# Update / list / details
claude plugin update plugin-name@marketplace-name
claude plugin list
claude plugin list --json --available
claude plugin details plugin-name@marketplace-name

# Validate plugin structure
claude plugin validate .

# Marketplace management
claude plugin marketplace add owner/repo
claude plugin marketplace add owner/repo@v2.0          # pin to branch/tag
claude plugin marketplace add https://gitlab.com/org/plugins.git
claude plugin marketplace add ./local-marketplace
claude plugin marketplace list
claude plugin marketplace update marketplace-name
claude plugin marketplace remove marketplace-name

# Tag a release (from plugin directory)
claude plugin tag --push
claude plugin tag --dry-run

# Prune orphaned auto-installed dependencies
claude plugin prune
claude plugin prune --dry-run
```

### In-Session Commands

```
/plugin                          open plugin manager (Discover / Installed / Marketplaces / Errors tabs)
/plugin install name@marketplace
/plugin enable name@marketplace
/plugin disable name@marketplace
/plugin uninstall name@marketplace
/plugin marketplace add source
/plugin marketplace update name
/plugin marketplace remove name
/plugin marketplace list
/plugin validate .
/reload-plugins                  reload all plugins without restarting
```

### Environment Variables Available in Plugin Configs

| Variable | Resolves to |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin installation directory (ephemeral — changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent data directory `~/.claude/plugins/data/{id}/` (survives updates) |
| `${CLAUDE_PROJECT_DIR}` | Project root (same as `CLAUDE_PROJECT_DIR` in hooks) |
| `${user_config.KEY}` | User-provided values from `userConfig` prompts |

### userConfig Field Schema

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label shown in configuration dialog |
| `description` | Yes | Help text |
| `sensitive` | No | Masks input; stores in system keychain instead of `settings.json` |
| `required` | No | Validation fails if empty |
| `default` | No | Value used when user provides nothing |
| `multiple` | No | Allow array of strings (`string` type) |
| `min` / `max` | No | Bounds for `number` type |

Non-sensitive values available as `${user_config.KEY}` in configs and as `CLAUDE_PLUGIN_OPTION_<KEY>` env vars for subprocesses. Sensitive values stored in system keychain (shared ~2KB limit).

### Monitor Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier within the plugin |
| `command` | Yes | Shell command run as persistent background process |
| `description` | Yes | Shown in task panel and notification summaries |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

Monitors require v2.1.105+. Only run in interactive CLI sessions. Disabling a plugin mid-session does not stop already-running monitors.

### Hook Events (Plugin Hooks)

Plugin hooks use `hooks/hooks.json` and support the same events as user hooks:

`SessionStart`, `Setup`, `UserPromptSubmit`, `UserPromptExpansion`, `PreToolUse`, `PermissionRequest`, `PermissionDenied`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Notification`, `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `Stop`, `StopFailure`, `TeammateIdle`, `InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `FileChanged`, `WorktreeCreate`, `WorktreeRemove`, `PreCompact`, `PostCompact`, `Elicitation`, `ElicitationResult`, `SessionEnd`

Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`

### LSP Server Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `command` | Yes | LSP binary to execute (must be in PATH) |
| `extensionToLanguage` | Yes | Maps file extensions to language identifiers |
| `args` | No | Command-line arguments |
| `transport` | No | `stdio` (default) or `socket` |
| `env` | No | Environment variables |
| `initializationOptions` | No | Options passed during initialization |
| `settings` | No | Passed via `workspace/didChangeConfiguration` |
| `workspaceFolder` | No | Workspace folder path |
| `startupTimeout` | No | Max time to wait for startup (ms) |
| `shutdownTimeout` | No | Max time to wait for shutdown (ms) |
| `restartOnCrash` | No | Auto-restart if server crashes |
| `maxRestarts` | No | Maximum restart attempts |

### Official LSP Plugins (from marketplace)

| Language | Plugin | Binary required |
| :--- | :--- | :--- |
| C/C++ | `clangd-lsp` | `clangd` |
| C# | `csharp-lsp` | `csharp-ls` |
| Go | `gopls-lsp` | `gopls` |
| Java | `jdtls-lsp` | `jdtls` |
| Kotlin | `kotlin-lsp` | `kotlin-language-server` |
| Lua | `lua-lsp` | `lua-language-server` |
| PHP | `php-lsp` | `intelephense` |
| Python | `pyright-lsp` | `pyright-langserver` |
| Rust | `rust-analyzer-lsp` | `rust-analyzer` |
| Swift | `swift-lsp` | `sourcekit-lsp` |
| TypeScript | `typescript-lsp` | `typescript-language-server` |

### Plugin Caching and File Resolution

Marketplace plugins are copied to `~/.claude/plugins/cache` — they cannot reference files outside their directory. Symlinks within the plugin are preserved; symlinks targeting sibling plugins in the same marketplace are dereferenced (content copied). Symlinks targeting outside the marketplace are skipped.

Old version directories remain on disk for ~7 days after update (grace period for running sessions).

### Version Management

Version is resolved from the first set:
1. `version` in `plugin.json`
2. `version` in the marketplace entry
3. Git commit SHA of plugin source
4. `unknown` (npm or non-git local)

| Approach | How | Update behavior |
| :--- | :--- | :--- |
| **Explicit version** | Set `"version": "2.1.0"` in `plugin.json` | Users get updates only when you bump this field |
| **Commit-SHA version** | Omit `version` from both | Users get updates on every new commit |

### Marketplace Schema (`marketplace.json`)

```json
{
  "name": "my-marketplace",
  "owner": { "name": "Dev Team", "email": "dev@example.com" },
  "description": "...",
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin",
      "description": "...",
      "version": "1.0.0"
    }
  ]
}
```

Reserved marketplace names (Anthropic only): `claude-code-marketplace`, `claude-code-plugins`, `claude-plugins-official`, `anthropic-marketplace`, `anthropic-plugins`, `agent-skills`, `anthropic-agent-skills`, `knowledge-work-plugins`, `life-sciences`.

### Plugin Sources (in marketplace.json)

| Source type | `source` field | Key fields |
| :--- | :--- | :--- |
| Relative path | `"./plugins/my-plugin"` | Must start with `./`; only works with git-based marketplace |
| GitHub | `{"source": "github", "repo": "owner/repo"}` | `ref`, `sha` optional |
| Git URL | `{"source": "url", "url": "https://..."}` | `ref`, `sha` optional |
| Git subdir | `{"source": "git-subdir", "url": "...", "path": "tools/plugin"}` | `ref`, `sha` optional; sparse clone |
| npm | `{"source": "npm", "package": "@org/plugin"}` | `version`, `registry` optional |

### Team Marketplace Configuration (`.claude/settings.json`)

```json
{
  "extraKnownMarketplaces": {
    "company-tools": {
      "source": { "source": "github", "repo": "your-org/claude-plugins" },
      "autoUpdate": true
    }
  },
  "enabledPlugins": {
    "code-formatter@company-tools": true
  }
}
```

### Managed Marketplace Restrictions (`strictKnownMarketplaces`)

| Value | Behavior |
| :--- | :--- |
| Undefined (default) | No restrictions |
| `[]` empty array | Complete lockdown — users cannot add any marketplaces |
| List of sources | Users can only add marketplaces matching the allowlist |

Source types for allowlist: `github` (exact `repo` match), `url` (exact URL match), `hostPattern` (regex on host), `pathPattern` (regex on filesystem path).

### Container Pre-population

```bash
# Build seed directory
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin marketplace add your-org/plugins
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin install my-tool@your-plugins

# At runtime
export CLAUDE_CODE_PLUGIN_SEED_DIR=/opt/claude-seed
```

Seed directories are read-only; auto-updates are disabled for seed marketplaces. Multiple seed paths separated by `:` (Unix) or `;` (Windows).

### Plugin Dependencies and Version Constraints

Declare in `plugin.json`:

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
| `name` | Plugin name; resolves within same marketplace by default |
| `version` | Semver range: `~2.1.0`, `^2.0`, `>=1.4`, `=2.1.0` |
| `marketplace` | Different marketplace (requires `allowCrossMarketplaceDependenciesOn` allowlist) |

Tag releases with the `{plugin-name}--v{version}` convention using `claude plugin tag --push`. Requires v2.1.110+.

**Constraint interaction**: When multiple plugins constrain the same dependency, Claude Code intersects ranges and resolves to the highest satisfying version. Conflicts (`range-conflict`) disable the installing plugin.

**Enable/disable cascades** (v2.1.143+): enabling a plugin also enables its dependencies; disabling is blocked if another enabled plugin still requires it.

### Dependency Errors

| Error | Meaning | Fix |
| :--- | :--- | :--- |
| `dependency-unsatisfied` | Dependency not installed or disabled | Run shown `claude plugin install` command |
| `range-conflict` | Ranges cannot be combined | Uninstall/update one conflicting plugin or widen constraint |
| `dependency-version-unsatisfied` | Installed version outside declared range | Re-run `claude plugin install <dep>@<marketplace>` |
| `no-matching-tag` | No `{name}--v*` tag satisfies range | Check upstream tagging or relax range |

### Converting Standalone Config to Plugin

| Standalone (`.claude/`) | Plugin |
| :--- | :--- |
| Files in `.claude/commands/` | Files in `plugin-name/commands/` |
| Hooks in `settings.json` | Hooks in `hooks/hooks.json` |
| Only available in one project | Shareable via marketplaces |
| Short skill names like `/hello` | Namespaced like `/my-plugin:hello` |

### Debugging

- `claude --debug` — shows plugin loading details, MCP initialization, skill/agent/hook registration
- `/plugin` Errors tab — plugin load errors and LSP issues
- `claude plugin validate .` or `/plugin validate .` — checks `plugin.json`, frontmatter, `hooks/hooks.json`
- `/doctor` — surfaces dependency and version warnings

### Common Issues

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` |
| Skills not appearing | Wrong directory structure | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Script not executable | `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin-relative paths |
| LSP `Executable not found in $PATH` | Language server not installed | Install required binary |
| Plugin skills not showing after install | Stale cache | `rm -rf ~/.claude/plugins/cache`, restart, reinstall |

### Auto-update Environment Variables

| Variable | Effect |
| :--- | :--- |
| `DISABLE_AUTOUPDATER=1` | Disable both Claude Code and plugin auto-updates |
| `FORCE_AUTOUPDATE_PLUGINS=1` | Re-enable plugin updates when `DISABLE_AUTOUPDATER` is set |
| `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE=1` | Keep stale marketplace cache when git pull fails |
| `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS=300000` | Increase git operation timeout (default 120s) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — plugin quickstart, manifest, plugin structure, skills, agents, LSP servers, monitors, default settings, testing locally, migrating from standalone config
- [Plugins reference](references/claude-code-plugins-reference.md) — complete component schemas, CLI commands, environment variables, caching, file resolution, version management
- [Discover and install plugins](references/claude-code-discover-plugins.md) — official marketplace, adding marketplaces, installing/managing plugins and marketplaces, auto-update, team configuration, security, troubleshooting
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace.json schema, plugin sources, hosting, private repos, managed restrictions, release channels, container pre-population, validation
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring dependencies, semver constraints, cross-marketplace deps, tagging releases, constraint interaction, enable/disable cascades, pruning orphans

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
