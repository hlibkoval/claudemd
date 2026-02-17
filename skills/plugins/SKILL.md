---
name: plugins
description: Reference documentation for Claude Code plugins — creating, distributing, discovering, and installing plugins that bundle skills, agents, hooks, MCP servers, and LSP servers. Use when creating a plugin, writing plugin.json manifests, setting up plugin marketplaces, distributing plugins, installing plugins, or understanding plugin directory structure and component specifications.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

Plugins are self-contained directories that bundle skills, agents, hooks, MCP servers, and LSP servers for distribution and reuse.

### Plugin Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json           # Only manifest here!
├── commands/                  # Legacy skills (markdown files)
├── skills/                    # Agent Skills (name/SKILL.md)
├── agents/                    # Subagent definitions
├── hooks/
│   └── hooks.json             # Hook configuration
├── .mcp.json                  # MCP servers
├── .lsp.json                  # LSP servers
└── scripts/                   # Hook/utility scripts
```

### plugin.json Required Fields

| Field  | Type   | Description                               |
|:-------|:-------|:------------------------------------------|
| `name` | string | Unique identifier (kebab-case, no spaces) |

### plugin.json Metadata Fields

| Field         | Type   | Description              |
|:--------------|:-------|:-------------------------|
| `version`     | string | Semantic version         |
| `description` | string | Brief explanation         |
| `author`      | object | `{name, email, url}`     |
| `homepage`    | string | Documentation URL        |
| `repository`  | string | Source code URL           |
| `license`     | string | License identifier       |
| `keywords`    | array  | Discovery tags           |

### Component Path Fields

| Field          | Type                  | Default location   |
|:---------------|:----------------------|:-------------------|
| `commands`     | string or array       | `commands/`        |
| `agents`       | string or array       | `agents/`          |
| `skills`       | string or array       | `skills/`          |
| `hooks`        | string, array, object | `hooks/hooks.json` |
| `mcpServers`   | string, array, object | `.mcp.json`        |
| `lspServers`   | string, array, object | `.lsp.json`        |
| `outputStyles` | string or array       | —                  |

### Installation Scopes

| Scope     | Settings file                 | Use case                        |
|:----------|:------------------------------|:--------------------------------|
| `user`    | `~/.claude/settings.json`     | Personal, all projects (default)|
| `project` | `.claude/settings.json`       | Team, shared via VCS            |
| `local`   | `.claude/settings.local.json` | Project-specific, gitignored    |
| `managed` | `managed-settings.json`       | Org-wide (read-only, update)    |

### CLI Commands

```bash
claude --plugin-dir ./my-plugin              # Test locally
claude plugin install name@marketplace       # Install
claude plugin uninstall name                 # Remove (aliases: remove, rm)
claude plugin enable name                    # Enable disabled plugin
claude plugin disable name                   # Disable without uninstalling
claude plugin update name                    # Update to latest version
```

All commands accept `-s, --scope <scope>` (`user`, `project`, `local`).

### Marketplace Entry Format (marketplace.json)

```json
{
  "name": "my-marketplace",
  "plugins": [
    {
      "name": "plugin-name",
      "description": "What it does",
      "version": "1.0.0",
      "source": "./plugins/plugin-name"
    }
  ]
}
```

### Key Environment Variables

| Variable               | Description                              |
|:-----------------------|:-----------------------------------------|
| `${CLAUDE_PLUGIN_ROOT}`| Absolute path to plugin directory        |
| `$CLAUDE_PROJECT_DIR`  | Project root for hook scripts            |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create Plugins](references/claude-code-plugins.md) — creating plugins, quickstart, plugin structure, converting standalone config to plugins
- [Plugins Reference](references/claude-code-plugins-reference.md) — complete technical specs: manifest schema, component specs, CLI commands, debugging tools, versioning
- [Discover & Install Plugins](references/claude-code-discover-plugins.md) — browsing marketplaces, installing, enabling/disabling, configuring team plugins
- [Plugin Marketplaces](references/claude-code-plugin-marketplaces.md) — creating and distributing plugin marketplaces, marketplace.json format, hosting options

## Sources

- Create Plugins: https://code.claude.com/docs/en/plugins.md
- Plugins Reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover & Install Plugins: https://code.claude.com/docs/en/discover-plugins.md
- Plugin Marketplaces: https://code.claude.com/docs/en/plugin-marketplaces.md
