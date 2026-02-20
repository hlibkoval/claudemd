---
name: plugins
description: Reference documentation for Claude Code plugins — creating plugins, plugin manifest schema, plugin components (skills, agents, hooks, MCP servers, LSP servers), discovering and installing plugins from marketplaces, creating and distributing marketplaces, CLI commands, debugging, distribution, and versioning.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for the Claude Code plugin system.

## Quick Reference

Plugins are self-contained directories that extend Claude Code with skills, agents, hooks, MCP servers, and LSP servers. They can be shared via marketplaces.

### Plugin vs Standalone

| Approach       | Skill names              | Best for                                          |
|:---------------|:-------------------------|:--------------------------------------------------|
| Standalone     | `/hello`                 | Personal workflows, single project, quick experiments |
| Plugin         | `/plugin-name:hello`     | Sharing with team/community, reusable across projects |

### Plugin Directory Structure

| Directory / File     | Location    | Purpose                                               |
|:---------------------|:------------|:------------------------------------------------------|
| `.claude-plugin/`    | Plugin root | Contains `plugin.json` manifest only                  |
| `commands/`          | Plugin root | Skills as Markdown files (legacy; use `skills/`)      |
| `agents/`            | Plugin root | Subagent Markdown files                               |
| `skills/`            | Plugin root | Agent Skills with `SKILL.md` files                    |
| `hooks/hooks.json`   | Plugin root | Hook configurations                                   |
| `.mcp.json`          | Plugin root | MCP server configurations                             |
| `.lsp.json`          | Plugin root | LSP server configurations                             |
| `settings.json`      | Plugin root | Default settings (currently only `agent` key)         |

Components go at the plugin root, **not** inside `.claude-plugin/`.

### Plugin Manifest (`plugin.json`)

| Field         | Type          | Required | Description                                  |
|:--------------|:--------------|:---------|:---------------------------------------------|
| `name`        | string        | Yes      | Unique identifier (kebab-case, no spaces)    |
| `version`     | string        | No       | Semantic version (`MAJOR.MINOR.PATCH`)       |
| `description` | string        | No       | Brief explanation of plugin purpose          |
| `author`      | object        | No       | `{name, email?, url?}`                       |
| `homepage`    | string        | No       | Documentation URL                            |
| `repository`  | string        | No       | Source code URL                              |
| `license`     | string        | No       | SPDX license identifier                     |
| `keywords`    | array         | No       | Discovery tags                               |
| `commands`    | string\|array | No       | Additional command files/dirs                |
| `agents`      | string\|array | No       | Additional agent files                       |
| `skills`      | string\|array | No       | Additional skill directories                 |
| `hooks`       | string\|object| No       | Hook config paths or inline config           |
| `mcpServers`  | string\|object| No       | MCP config paths or inline config            |
| `lspServers`  | string\|object| No       | LSP server configs                           |
| `outputStyles`| string\|array | No       | Output style files/directories               |

Custom paths supplement default directories -- they do not replace them. All paths must be relative and start with `./`.

### Installation Scopes

| Scope     | Settings file                 | Use case                          |
|:----------|:------------------------------|:----------------------------------|
| `user`    | `~/.claude/settings.json`     | Personal, all projects (default)  |
| `project` | `.claude/settings.json`       | Team, shared via VCS              |
| `local`   | `.claude/settings.local.json` | Project-specific, gitignored      |
| `managed` | `managed-settings.json`       | Admin-controlled (read-only)      |

### CLI Commands

```bash
# Install / uninstall
claude plugin install <plugin>[@marketplace] [--scope user|project|local]
claude plugin uninstall <plugin>[@marketplace] [--scope ...]

# Enable / disable
claude plugin enable <plugin>[@marketplace] [--scope ...]
claude plugin disable <plugin>[@marketplace] [--scope ...]

# Update / validate / debug
claude plugin update <plugin>[@marketplace] [--scope ...]
claude plugin validate .
claude --debug
```

### Marketplace Management

```bash
# TUI
/plugin                                      # Open plugin manager (Discover, Installed, Marketplaces, Errors tabs)

# Add marketplaces
/plugin marketplace add owner/repo           # GitHub
/plugin marketplace add https://gitlab.com/org/repo.git  # Git URL
/plugin marketplace add ./local-dir          # Local path

# Manage
/plugin marketplace list
/plugin marketplace update <name>
/plugin marketplace remove <name>
```

### Plugin Sources (in marketplace.json)

| Source type   | Format                             | Notes                              |
|:--------------|:-----------------------------------|:-----------------------------------|
| Relative path | `"./plugins/my-plugin"`            | Within marketplace repo            |
| GitHub        | `{source: "github", repo: "o/r"}` | Optional `ref`, `sha`             |
| Git URL       | `{source: "url", url: "...git"}`  | Optional `ref`, `sha`             |
| npm           | `{source: "npm", package: "..."}`  | Optional `version`, `registry`    |
| pip           | `{source: "pip", package: "..."}`  | Optional `version`, `registry`    |

### Environment Variable

`${CLAUDE_PLUGIN_ROOT}` -- absolute path to the plugin directory. Use in hooks, MCP servers, and scripts.

### Testing Locally

```bash
claude --plugin-dir ./my-plugin
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

### Common Issues

| Issue                               | Solution                                                        |
|:------------------------------------|:----------------------------------------------------------------|
| Plugin not loading                  | Validate JSON: `claude plugin validate .`                       |
| Commands not appearing              | Move `commands/` to plugin root, not inside `.claude-plugin/`   |
| Hooks not firing                    | `chmod +x script.sh`, use `${CLAUDE_PLUGIN_ROOT}` for paths    |
| MCP server fails                    | Use `${CLAUDE_PLUGIN_ROOT}` variable for all paths              |
| LSP `Executable not found in $PATH` | Install the language server binary                              |
| Files not found after install       | Plugins are cached; no `../` paths. Use symlinks if needed      |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create Plugins](references/claude-code-plugins.md) — quickstart, plugin structure, adding skills/agents/hooks/MCP/LSP, testing, migration from standalone
- [Plugins Reference](references/claude-code-plugins-reference.md) — complete manifest schema, component specs, CLI commands, debugging, versioning
- [Discover and Install Plugins](references/claude-code-discover-plugins.md) — browsing marketplaces, installing plugins, managing scopes, official marketplace, auto-updates
- [Plugin Marketplaces](references/claude-code-plugin-marketplaces.md) — creating marketplace.json, hosting, distribution, plugin sources, strict mode, team configuration, troubleshooting

## Sources

- Create Plugins: https://code.claude.com/docs/en/plugins.md
- Plugins Reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and Install Plugins: https://code.claude.com/docs/en/discover-plugins.md
- Plugin Marketplaces: https://code.claude.com/docs/en/plugin-marketplaces.md
