---
name: plugins-doc
user-invocable: false
description: Complete official documentation for the Claude Code plugin system — creating, installing, distributing, and referencing plugins.
---

# Plugins Documentation

This skill provides the complete official documentation for the Claude Code plugin system.

## Quick Reference

### Plugin vs. Standalone Configuration

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| Standalone (`.claude/`) | `/hello` | Personal workflows, project-specific, quick experiments |
| Plugin (self-contained dir) | `/plugin-name:hello` | Sharing with team/community, versioned releases, reusable across projects |

### Plugin Directory Structure

| Directory | Location | Purpose |
| :--- | :--- | :--- |
| `.claude-plugin/` | Plugin root | Contains `plugin.json` manifest (optional) |
| `skills/` | Plugin root | Skills as `<name>/SKILL.md` directories |
| `commands/` | Plugin root | Skills as flat Markdown files (use `skills/` for new plugins) |
| `agents/` | Plugin root | Custom agent definitions |
| `hooks/` | Plugin root | Event handlers in `hooks.json` |
| `.mcp.json` | Plugin root | MCP server configurations |
| `.lsp.json` | Plugin root | LSP server configurations |
| `monitors/` | Plugin root | Background monitor configs in `monitors.json` |
| `bin/` | Plugin root | Executables added to Bash tool's PATH |
| `settings.json` | Plugin root | Default settings (only `agent` and `subagentStatusLine` keys supported) |
| `themes/` | Plugin root | Color theme definitions (experimental) |

**Warning**: Only `plugin.json` belongs inside `.claude-plugin/`. All other directories must be at the plugin root.

### plugin.json Manifest — Key Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Required. Unique identifier (kebab-case). Becomes the skill namespace prefix. |
| `displayName` | string | Human-readable name shown in UI (v2.1.143+) |
| `version` | string | Optional. If set, users only receive updates when bumped. Omit to use git commit SHA. |
| `description` | string | Brief explanation of plugin purpose |
| `author` | object | `{ name, email?, url? }` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier |
| `keywords` | array | Discovery tags |
| `defaultEnabled` | boolean | Whether plugin starts enabled after install (default: `true`; v2.1.154+) |
| `skills` | string\|array | Custom skill dirs (adds to default `skills/`) |
| `commands` | string\|array | Custom flat .md skill files/dirs (replaces default `commands/`) |
| `agents` | string\|array | Custom agent files (replaces default `agents/`) |
| `hooks` | string\|array\|object | Hook config paths or inline config |
| `mcpServers` | string\|array\|object | MCP config paths or inline config |
| `lspServers` | string\|array\|object | LSP server configs |
| `outputStyles` | string\|array | Output style files/dirs |
| `experimental.themes` | string\|array | Color theme files/dirs |
| `experimental.monitors` | string\|array | Background monitor configs |
| `userConfig` | object | User-configurable values prompted at enable time |
| `channels` | array | Message channel declarations (Telegram, Slack, Discord style) |
| `dependencies` | array | Other plugins this plugin requires, optionally with semver constraints |

### userConfig Field Options

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label shown in configuration dialog |
| `description` | Yes | Help text |
| `sensitive` | No | If `true`, stores in secure storage |
| `required` | No | If `true`, validation fails when empty |
| `default` | No | Value used when user provides nothing |
| `multiple` | No | For `string` type, allow an array of strings |
| `min`/`max` | No | Bounds for `number` type |

User config values are available as `${user_config.KEY}` in MCP/LSP/hook/monitor configs, and as `CLAUDE_PLUGIN_OPTION_<KEY>` env vars in subprocesses.

### Environment Variables Available in Plugin Configs

| Variable | Description |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to the plugin's installation directory. Changes on update. |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state that survives updates (`~/.claude/plugins/data/{id}/`) |
| `${CLAUDE_PROJECT_DIR}` | Project root (same as the `CLAUDE_PROJECT_DIR` hooks receive) |

### Plugin CLI Commands

| Command | Description |
| :--- | :--- |
| `claude plugin init <name>` | Scaffold a new plugin in `~/.claude/skills/<name>/` |
| `claude plugin install <plugin>[@marketplace]` | Install a plugin |
| `claude plugin uninstall <plugin>` | Remove a plugin (`--keep-data` to preserve data dir, `--prune` for orphaned deps) |
| `claude plugin prune` | Remove orphaned auto-installed dependencies |
| `claude plugin enable <plugin>` | Enable a disabled plugin (also enables its dependencies) |
| `claude plugin disable <plugin>` | Disable without uninstalling (fails if another plugin depends on it) |
| `claude plugin update <plugin>` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin details <name>` | Show component inventory and token cost estimate |
| `claude plugin tag [--push]` | Create a release git tag for version resolution |
| `claude plugin validate [path]` | Validate manifest, frontmatter, and hooks syntax |

### Plugin Scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` | `~/.claude/settings.json` | Personal plugins across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled, read-only |

### Marketplace Schema — Required Fields

| Field | Description |
| :--- | :--- |
| `name` | Marketplace identifier (kebab-case). Users install via `plugin-name@this-name`. |
| `owner` | Object with `name` (required) and `email` (optional) |
| `plugins` | Array of plugin entries |

### Plugin Source Types (in marketplace.json)

| Source | Type | Key fields |
| :--- | :--- | :--- |
| Relative path | string `"./my-plugin"` | Must start with `./`. Only works with Git-based marketplaces. |
| `github` | object | `repo` (owner/repo), `ref?`, `sha?` |
| `url` | object | `url` (git URL), `ref?`, `sha?` |
| `git-subdir` | object | `url`, `path`, `ref?`, `sha?` |
| `npm` | object | `package`, `version?`, `registry?` |

### Version Resolution Order

1. `version` in the plugin's `plugin.json`
2. `version` in the plugin's marketplace entry
3. Git commit SHA of the plugin source
4. `"unknown"` for npm sources or local non-git dirs

### Dependencies — Constraint Syntax

Declare in `plugin.json` `dependencies` array:
- Bare string `"plugin-name"` — tracks latest
- Object `{ "name": "plugin-name", "version": "~2.1.0" }` — semver range (npm semver syntax)
- Object `{ "name": "plugin-name", "marketplace": "other-market" }` — cross-marketplace (requires `allowCrossMarketplaceDependenciesOn` in marketplace.json)

Tag releases with the convention `{plugin-name}--v{version}` using `claude plugin tag --push`.

### Dependency Error Reference

| Error | Meaning | Fix |
| :--- | :--- | :--- |
| `dependency-unsatisfied` | Dependency not installed or disabled | `claude plugin install <dep>@<marketplace>` |
| `range-conflict` | Version ranges cannot be combined | Uninstall/update conflicting plugin or widen constraint |
| `dependency-version-unsatisfied` | Installed version outside declared range | Re-resolve: `claude plugin install <dep>@<marketplace>` |
| `no-matching-tag` | No `{name}--v*` tag satisfies the range | Check upstream tags or relax range |

### LSP Servers — Required Fields

| Field | Description |
| :--- | :--- |
| `command` | LSP binary to execute (must be in PATH) |
| `extensionToLanguage` | Maps file extensions to language identifiers |

Optional LSP fields: `args`, `transport` (`stdio`/`socket`), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `maxRestarts`, `diagnostics` (default `true`).

### Background Monitors — Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier within the plugin |
| `command` | Yes | Shell command run as persistent background process |
| `description` | Yes | Short summary of what is being watched |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

Requires Claude Code v2.1.105+. Runs only in interactive CLI sessions.

### Plugin Hints (Recommend from CLI)

Write a self-closing tag to stderr when `CLAUDECODE` env var is set:

```
<claude-code-hint v="1" type="plugin" value="your-plugin@claude-plugins-official" />
```

Requirements: must be on its own line; `value` must reference a plugin in an Anthropic-controlled marketplace. Claude Code shows a one-time install prompt (once per plugin, once per session).

### Skills-Directory Plugins

Any folder under a skills directory with a `.claude-plugin/plugin.json` loads as `<name>@skills-dir`. Scaffold with `claude plugin init <name>`. Personal scope (`~/.claude/skills/`) loads in all projects; project scope (`.claude/skills/`) requires workspace trust.

### Common Debugging Issues

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` |
| Skills not appearing | Wrong dir structure | `skills/` must be at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Script not executable | `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin paths |
| LSP `Executable not found` | Language server not installed | Install the binary first |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — Quickstart, plugin structure, developing and sharing plugins, converting standalone configs
- [Plugins reference](references/claude-code-plugins-reference.md) — Complete technical specs: manifest schema, components, CLI commands, environment variables, caching, debugging
- [Discover and install plugins](references/claude-code-discover-plugins.md) — Browsing marketplaces, installing plugins, managing installed plugins and marketplaces
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace.json schema, plugin sources, hosting, version resolution, managed restrictions
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — Declaring dependencies, version constraints, tagging releases, resolving errors
- [Recommend your plugin from your CLI](references/claude-code-plugin-hints.md) — The `<claude-code-hint>` protocol for CLIs to suggest plugin installs

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
- Recommend your plugin from your CLI: https://code.claude.com/docs/en/plugin-hints.md
