---
name: plugins-doc
user-invocable: false
description: >
  Complete official documentation for the Claude Code plugin system — creating
  plugins, plugin manifest schema, marketplaces, discovering and installing
  plugins, plugin dependencies and version constraints, and the CLI hints
  protocol. Load when working with plugin.json, marketplace.json, plugin
  directory structure, plugin CLI commands, or distributing plugins.
---

# Claude Code Plugins Documentation

This skill provides the complete official documentation for the Claude Code plugin system.

## Quick Reference

### Plugin directory structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # manifest (optional)
├── skills/                  # <name>/SKILL.md directories
├── commands/                # flat .md skill files (legacy)
├── agents/                  # subagent .md files
├── hooks/
│   └── hooks.json
├── .mcp.json
├── .lsp.json
├── monitors/
│   └── monitors.json
├── themes/                  # experimental
├── output-styles/
├── bin/                     # executables added to PATH
└── settings.json            # default plugin settings
```

Only `plugin.json` goes inside `.claude-plugin/`. All other directories must be at the plugin root.

A plugin that ships exactly one skill can place `SKILL.md` at the plugin root instead of creating a `skills/` directory.

### plugin.json manifest — key fields

| Field            | Type    | Description                                                                      |
| :--------------- | :------ | :------------------------------------------------------------------------------- |
| `name`           | string  | Required. Unique kebab-case identifier; becomes the skill namespace              |
| `displayName`    | string  | Human-readable name shown in UI (v2.1.143+)                                      |
| `version`        | string  | Semantic version. If set, users only get updates when bumped. Omit to use git SHA |
| `description`    | string  | Brief plugin purpose                                                             |
| `author`         | object  | `{name, email, url}`                                                             |
| `homepage`       | string  | Documentation URL                                                                |
| `repository`     | string  | Source code URL                                                                  |
| `license`        | string  | License identifier (e.g. `"MIT"`)                                                |
| `keywords`       | array   | Discovery tags                                                                   |
| `defaultEnabled` | boolean | Whether plugin starts enabled after install (v2.1.154+). Default: `true`         |
| `dependencies`   | array   | Other plugins this plugin requires, with optional semver constraints             |
| `userConfig`     | object  | User-configurable values prompted at enable time                                 |
| `channels`       | array   | MCP-backed message channel declarations                                          |

### plugin.json component path fields

| Field                   | Type           | Description                                                                              |
| :---------------------- | :------------- | :--------------------------------------------------------------------------------------- |
| `skills`                | string\|array  | Additional skill directories (adds to default `skills/`)                                 |
| `commands`              | string\|array  | Flat .md skill files or directories (replaces default `commands/`)                       |
| `agents`                | string\|array  | Agent files (replaces default `agents/`)                                                 |
| `hooks`                 | string\|object | Hook config paths or inline config                                                       |
| `mcpServers`            | string\|object | MCP config paths or inline config                                                        |
| `lspServers`            | string\|object | LSP server configs                                                                       |
| `outputStyles`          | string\|array  | Output style files (replaces default)                                                    |
| `experimental.themes`   | string\|array  | Color theme files (replaces default `themes/`)                                           |
| `experimental.monitors` | string\|array  | Background monitor config (replaces default `monitors/monitors.json`)                    |

### Plugin installation scopes

| Scope     | Settings file                 | Use case                                      |
| :-------- | :---------------------------- | :-------------------------------------------- |
| `user`    | `~/.claude/settings.json`     | Personal plugins across all projects (default)|
| `project` | `.claude/settings.json`       | Team plugins shared via version control       |
| `local`   | `.claude/settings.local.json` | Project-specific, gitignored                  |
| `managed` | Managed settings              | Admin-controlled, read-only                   |

### Standalone vs plugin

| Approach         | Skill names        | Best for                                              |
| :--------------- | :----------------- | :---------------------------------------------------- |
| Standalone `.claude/` | `/hello`      | Personal workflows, single-project, quick experiments |
| Plugin           | `/plugin-name:hello` | Sharing, distributing, versioned, multi-project     |

### Plugin environment variables

| Variable               | Resolves to                                          |
| :--------------------- | :--------------------------------------------------- |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin's installation directory (changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory that survives updates (`~/.claude/plugins/data/{id}/`) |
| `${CLAUDE_PROJECT_DIR}` | Project root where Claude Code was launched          |
| `${user_config.KEY}`    | User-configurable value declared in `userConfig`     |

### Plugin CLI commands

| Command                               | Description                                    |
| :------------------------------------ | :--------------------------------------------- |
| `claude plugin init <name>`           | Scaffold a new plugin in `~/.claude/skills/`   |
| `claude plugin install <plugin>`      | Install from a marketplace                     |
| `claude plugin uninstall <plugin>`    | Remove (also deletes `${CLAUDE_PLUGIN_DATA}` by default) |
| `claude plugin enable <plugin>`       | Enable a disabled plugin (transitively enables dependencies) |
| `claude plugin disable <plugin>`      | Disable (fails if other enabled plugins depend on it) |
| `claude plugin update <plugin>`       | Update to latest version                       |
| `claude plugin list [--json]`         | List installed plugins                         |
| `claude plugin details <name>`        | Show component inventory and token cost        |
| `claude plugin prune`                 | Remove orphaned auto-installed dependencies    |
| `claude plugin tag [--push]`          | Create release git tag (`{name}--v{version}`)  |
| `claude plugin validate [path]`       | Validate manifest, skill/agent frontmatter, hooks |
| `/reload-plugins`                     | Reload all active plugins without restarting   |
| `--plugin-dir ./path`                 | Load a plugin for this session only            |
| `--plugin-url https://...`            | Load a zipped plugin from URL for this session |

### Skills-directory plugins

Any folder under a skills directory with a `.claude-plugin/plugin.json` is auto-loaded as `<name>@skills-dir`. Scaffold with `claude plugin init <name>`. No marketplace or install step required.

### marketplace.json — key fields

| Field     | Type   | Description                                                    |
| :-------- | :----- | :------------------------------------------------------------- |
| `name`    | string | Marketplace identifier (kebab-case). Users see it in install commands |
| `owner`   | object | `{name, email}` — `name` is required                          |
| `plugins` | array  | List of plugin entries with `name` + `source`                  |
| `description` | string | Brief marketplace description                              |
| `metadata.pluginRoot` | string | Base directory prepended to relative plugin source paths |
| `allowCrossMarketplaceDependenciesOn` | array | Marketplaces that plugin dependencies may come from |

### Plugin sources (in marketplace.json)

| Source type   | Format                                         | Notes                                      |
| :------------ | :--------------------------------------------- | :----------------------------------------- |
| Relative path | `"./plugins/my-plugin"`                        | Must start with `./`; only works in git-based marketplaces |
| `github`      | `{"source": "github", "repo": "owner/repo"}`  | Optional `ref`, `sha`                      |
| `url`         | `{"source": "url", "url": "https://..."}`      | Any git host; optional `ref`, `sha`        |
| `git-subdir`  | `{"source": "git-subdir", "url": "...", "path": "tools/plugin"}` | Sparse clone of monorepo subdir |
| `npm`         | `{"source": "npm", "package": "@org/plugin"}` | Optional `version`, `registry`             |

### Version management

- Set `version` in `plugin.json` to pin: users get updates only when you bump it.
- Omit `version` to use git commit SHA: every commit is a new version.
- Version resolution order: `plugin.json` version → marketplace entry version → git SHA.

### Dependency version constraints

Declare in `plugin.json`:
```json
{
  "dependencies": [
    "audit-logger",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```
Tag releases as `{plugin-name}--v{version}` using `claude plugin tag --push`. Semver ranges follow Node's `semver` package syntax.

### Plugin hints protocol

CLIs can prompt Claude Code users to install a plugin by writing a hint tag to stderr when the `CLAUDECODE` env var is set:

```
<claude-code-hint v="1" type="plugin" value="my-plugin@claude-plugins-official" />
```

The tag must be on its own line. Only works for plugins in official Anthropic marketplaces. Claude Code strips it from output before it reaches the model.

### Official marketplaces

| Marketplace               | Added automatically? | How to add manually                                     |
| :------------------------ | :------------------- | :------------------------------------------------------ |
| `claude-plugins-official` | Yes                  | `claude plugin marketplace add anthropics/claude-plugins-official` |
| `claude-community`        | No                   | `/plugin marketplace add anthropics/claude-plugins-community` |
| Demo (`claude-code-plugins`) | No                | `/plugin marketplace add anthropics/claude-code`        |

Submit to community marketplace via claude.ai or platform.claude.com. Validate first with `claude plugin validate`.

### Managed marketplace restrictions

Set `strictKnownMarketplaces` in managed settings:
- `[]` — no new marketplaces allowed
- List of sources — only matching sources allowed
- Supports `source: "hostPattern"` and `source: "pathPattern"` for regex matching

### Container pre-population

Set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a directory mirroring `~/.claude/plugins`. Build the seed with `CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/seed claude plugin install ...`. Seed is read-only; auto-updates are disabled for seed-managed marketplaces.

### Common troubleshooting

| Symptom                         | Cause / Fix                                                              |
| :------------------------------ | :----------------------------------------------------------------------- |
| Components missing after load   | Directories inside `.claude-plugin/` instead of plugin root             |
| Skills not appearing            | Wrong structure; run `claude plugin validate`                            |
| Hooks not firing                | Script not executable (`chmod +x`); check event name casing             |
| MCP server fails                | Missing `${CLAUDE_PLUGIN_ROOT}` in path; check `claude --debug`         |
| `Executable not found in $PATH` | Language server binary not installed                                     |
| Relative paths fail (URL marketplace) | Use git-based marketplace source instead                          |
| `dependency-unsatisfied`        | Install the missing dependency or enable if disabled                     |
| `range-conflict`                | Two plugins require incompatible versions; update or widen a constraint  |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — Plugin quickstart, structure overview, adding skills/LSP/monitors/hooks, testing locally, sharing and submitting to marketplaces, migrating from standalone config
- [Plugins reference](references/claude-code-plugins-reference.md) — Complete technical spec: manifest schema, component reference (skills, agents, hooks, MCP, LSP, monitors, themes), environment variables, CLI commands, caching, debugging
- [Discover and install plugins](references/claude-code-discover-plugins.md) — Official marketplace, community marketplace, add/install/manage plugins and marketplaces, auto-updates, team configuration, security
- [Plugin marketplaces](references/claude-code-plugin-marketplaces.md) — Create and host marketplaces, marketplace.json schema, plugin sources, version resolution, release channels, managed restrictions, container pre-population
- [Plugin dependencies](references/claude-code-plugin-dependencies.md) — Declare version constraints, cross-marketplace dependencies, tagging releases, constraint intersection, enable/disable with dependencies, pruning orphans
- [Plugin hints](references/claude-code-plugin-hints.md) — CLI hint protocol for recommending plugins from your own CLI tool

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Plugin marketplaces: https://code.claude.com/docs/en/plugin-marketplaces.md
- Plugin dependencies: https://code.claude.com/docs/en/plugin-dependencies.md
- Plugin hints: https://code.claude.com/docs/en/plugin-hints.md
