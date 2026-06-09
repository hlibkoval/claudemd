---
name: plugins-doc
user-invocable: false
description: Complete official documentation for the Claude Code plugin system — creating, discovering, distributing, and configuring plugins and marketplaces.
---

# Plugins Documentation

This skill provides the complete official documentation for the Claude Code plugin system.

## Quick Reference

### Standalone vs Plugin

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| Standalone (`.claude/`) | `/hello` | Personal, project-specific, quick experiments |
| Plugin | `/plugin-name:hello` | Sharing, versioned distribution, multiple projects |

### Plugin directory layout

| Path | Purpose |
| :--- | :--- |
| `.claude-plugin/plugin.json` | Manifest (optional; only file that belongs inside `.claude-plugin/`) |
| `skills/<name>/SKILL.md` | Skills |
| `commands/` | Skills as flat `.md` files (use `skills/` for new plugins) |
| `agents/` | Subagent definitions |
| `hooks/hooks.json` | Hook configurations |
| `.mcp.json` | MCP server definitions |
| `.lsp.json` | LSP server configurations |
| `monitors/monitors.json` | Background monitor configs |
| `themes/` | Color theme definitions |
| `output-styles/` | Output style definitions |
| `bin/` | Executables added to Bash tool PATH |
| `settings.json` | Default settings (only `agent` and `subagentStatusLine` keys supported) |

### plugin.json manifest — required field

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique kebab-case identifier; becomes skill namespace |

### plugin.json manifest — key optional fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `displayName` | string | Human-readable name for UI (v2.1.143+) |
| `version` | string | Semver string; if set, users only update when bumped |
| `description` | string | Brief explanation shown in plugin manager |
| `author` | object | `name`, `email`, `url` |
| `homepage` | string | Docs URL |
| `repository` | string | Source URL |
| `license` | string | SPDX identifier |
| `keywords` | array | Discovery tags |
| `defaultEnabled` | boolean | Whether plugin starts enabled after install (v2.1.154+, default true) |
| `dependencies` | array | Other plugins required; plain name string or `{name, version, marketplace}` |
| `userConfig` | object | User-configurable values prompted at enable time |
| `skills` / `commands` / `agents` / `hooks` / `mcpServers` / `lspServers` | string\|array\|object | Custom component paths |
| `experimental.monitors` | string\|array | Background monitor configs |
| `experimental.themes` | string\|array | Color theme files |

### userConfig field options

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label shown in dialog |
| `description` | Yes | Help text |
| `sensitive` | No | Masks input, stores in keychain |
| `required` | No | Fails validation when empty |
| `default` | No | Value when user provides nothing |
| `multiple` | No | Allow array of strings (string type only) |
| `min` / `max` | No | Bounds for number type |

User config values are available as `${user_config.KEY}` in MCP/LSP configs, hooks, and monitors; exported as `CLAUDE_PLUGIN_OPTION_<KEY>` environment variables.

### Environment variables in plugins

| Variable | Description |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin installation directory (use for bundled scripts/configs) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory surviving updates (`~/.claude/plugins/data/{id}/`) |
| `${CLAUDE_PROJECT_DIR}` | Project root (same as hooks' `CLAUDE_PROJECT_DIR`) |

### Plugin installation scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` | `~/.claude/settings.json` | Personal, all projects (default) |
| `project` | `.claude/settings.json` | Team, shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled, read-only |

### CLI commands

| Command | Description |
| :--- | :--- |
| `claude plugin init <name>` | Scaffold plugin at `~/.claude/skills/<name>/` |
| `claude plugin install <plugin>[@marketplace]` | Install plugin (default: user scope) |
| `claude plugin uninstall <plugin>` | Remove plugin (`--keep-data`, `--prune` options) |
| `claude plugin enable <plugin>` | Enable disabled plugin |
| `claude plugin disable <plugin>` | Disable without uninstalling |
| `claude plugin update <plugin>` | Update to latest version |
| `claude plugin list` | List installed plugins (`--json`, `--available`) |
| `claude plugin details <name>` | Show component inventory and token cost |
| `claude plugin tag [--push]` | Create `{name}--v{version}` release tag |
| `claude plugin prune` | Remove orphaned auto-installed dependencies |
| `claude plugin validate [path]` | Validate manifest and component files |
| `claude plugin marketplace add <source>` | Add marketplace |
| `claude plugin marketplace list` | List configured marketplaces |
| `claude plugin marketplace remove <name>` | Remove marketplace |
| `claude plugin marketplace update [name]` | Refresh marketplace listings |

### Testing locally

```bash
# Load plugin for this session
claude --plugin-dir ./my-plugin

# Load from zip (v2.1.128+)
claude --plugin-dir ./my-plugin.zip

# Load from URL
claude --plugin-url https://example.com/my-plugin.zip

# Reload without restart
/reload-plugins
```

### Skills-directory plugins

Any folder under a skills directory with `.claude-plugin/plugin.json` loads as `<name>@skills-dir`.

| Skills directory | Scope | Loads |
| :--- | :--- | :--- |
| `~/.claude/skills/` | personal | All projects |
| `<cwd>/.claude/skills/` | project | Only after workspace trust |

### Hook events (plugin hooks use same events as user hooks)

`SessionStart`, `Setup`, `UserPromptSubmit`, `UserPromptExpansion`, `PreToolUse`, `PermissionRequest`, `PermissionDenied`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Notification`, `MessageDisplay`, `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `Stop`, `StopFailure`, `TeammateIdle`, `InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `FileChanged`, `WorktreeCreate`, `WorktreeRemove`, `PreCompact`, `PostCompact`, `Elicitation`, `ElicitationResult`, `SessionEnd`

Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`

### Agent frontmatter fields (plugin agents)

`name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation` (only value: `"worktree"`). Note: `hooks`, `mcpServers`, and `permissionMode` are not supported for plugin-shipped agents.

### Monitors (v2.1.105+)

Background monitors start automatically, deliver each stdout line to Claude as a notification.

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique within plugin |
| `command` | Yes | Persistent shell command |
| `description` | Yes | Short summary |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

### LSP servers — required fields

| Field | Description |
| :--- | :--- |
| `command` | LSP binary (must be in PATH) |
| `extensionToLanguage` | Maps file extensions to language IDs |

### Marketplace file (`marketplace.json`) — required fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Marketplace identifier (kebab-case) |
| `owner` | object | Maintainer info (`name` required, `email` optional) |
| `plugins` | array | List of plugin entries |

Each plugin entry requires `name` and `source`. Source types:
- Relative path string starting with `./`
- `{ "source": "github", "repo": "owner/repo", "ref"?, "sha"? }`
- `{ "source": "url", "url": "...", "ref"?, "sha"? }`
- `{ "source": "git-subdir", "url": "...", "path": "...", "ref"?, "sha"? }`
- `{ "source": "npm", "package": "...", "version"?, "registry"? }`

### Version management

Version resolved from first available: `plugin.json` `version` → marketplace entry `version` → git commit SHA → `unknown`.

- Explicit version: bump to deliver updates; same string = no update
- Omit version: every new commit is a new version (good for active development)

### Dependency version constraints (v2.1.110+)

```json
"dependencies": [
  "audit-logger",
  { "name": "secrets-vault", "version": "~2.1.0" }
]
```

Tag releases as `{plugin-name}--v{version}` using `claude plugin tag --push`. Multiple constraints on same dependency are intersected; conflicts produce `range-conflict` error.

### Plugin hints (CLI-to-plugin recommendation)

When `CLAUDECODE=1` env var is set, a CLI can emit to stderr on its own line:

```
<claude-code-hint v="1" type="plugin" value="example-cli@claude-plugins-official" />
```

Claude Code strips the hint line before sending to model, checks it targets the official marketplace, and shows a one-time install prompt. Only works for plugins in official Anthropic marketplaces.

### Managed marketplace restrictions (`strictKnownMarketplaces`)

| Value | Behavior |
| :--- | :--- |
| Undefined | No restrictions |
| `[]` | Complete lockdown |
| List of sources | Allowlist only |

Source types for restrictions: `github`, `url`, `hostPattern` (regex on hostname), `pathPattern` (regex on filesystem path).

### Pre-populating plugins for containers

Set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a directory mirroring `~/.claude/plugins/`. Seed is read-only; auto-updates disabled for seed marketplaces. Build with `CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin install ...`.

### Common troubleshooting

| Issue | Solution |
| :--- | :--- |
| Plugin not loading | Run `claude plugin validate` to check manifest |
| Skills not appearing | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | `chmod +x script.sh`; verify event name is case-sensitive |
| MCP server fails | Use `${CLAUDE_PLUGIN_ROOT}` for all plugin paths |
| LSP `Executable not found` | Install the language server binary |
| Relative paths fail in URL marketplace | Switch to git-based marketplace or use external sources |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — Creating plugins with skills, agents, hooks, MCP servers; quickstart, structure, testing, distribution
- [Plugins reference](references/claude-code-plugins-reference.md) — Complete technical specifications: manifest schema, component specs, CLI commands, debugging tools
- [Discover and install plugins](references/claude-code-discover-plugins.md) — Finding and installing plugins from marketplaces; official, community, and demo marketplaces
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — Building and hosting marketplace files; plugin sources, versioning, managed restrictions
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — Declaring version-constrained dependencies; tagging releases, resolving conflicts
- [Recommend your plugin from your CLI](references/claude-code-plugin-hints.md) — Emitting `<claude-code-hint>` markers from CLIs to prompt plugin installation

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
- Recommend your plugin from your CLI: https://code.claude.com/docs/en/plugin-hints.md
