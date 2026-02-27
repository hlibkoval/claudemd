---
name: plugins
description: Reference documentation for Claude Code plugins — creating plugin manifests, adding skills/agents/hooks/MCP/LSP servers to plugins, plugin directory structure, installation scopes, CLI commands, marketplace creation and distribution, plugin sources, and troubleshooting.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for the Claude Code plugin system.

## Quick Reference

Plugins are self-contained directories that extend Claude Code with skills, agents, hooks, MCP servers, and LSP servers. They support namespaced sharing across projects and distribution via marketplaces.

### Standalone vs Plugin

| Approach | Skill names | Best for |
|:---------|:------------|:---------|
| Standalone (`.claude/`) | `/hello` | Personal workflows, single-project, quick iteration |
| Plugin (dir with `.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teams, multi-project reuse, marketplace distribution |

### Plugin Directory Structure

```text
my-plugin/
├── .claude-plugin/
│   └── plugin.json       # manifest (only file here)
├── commands/             # legacy markdown commands
├── agents/               # subagent .md files
├── skills/               # Agent Skills (name/SKILL.md)
├── hooks/
│   └── hooks.json
├── settings.json         # default settings (only "agent" key supported)
├── .mcp.json             # MCP server config
└── .lsp.json             # LSP server config
```

**Common mistake**: Only `plugin.json` goes in `.claude-plugin/`. All other dirs must be at plugin root.

### Plugin Manifest (`plugin.json`)

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Brief description",
  "author": { "name": "Your Name", "email": "you@example.com" },
  "homepage": "https://docs.example.com",
  "repository": "https://github.com/user/plugin",
  "license": "MIT",
  "keywords": ["tag1", "tag2"]
}
```

`name` is the only required field. It sets the skill namespace (e.g. `my-plugin:hello`).

Component path fields (all optional, supplement defaults, paths must start with `./`):

| Field | Type | Default location |
|:------|:-----|:----------------|
| `commands` | string\|array | `commands/` |
| `agents` | string\|array | `agents/` |
| `skills` | string\|array | `skills/` |
| `hooks` | string\|array\|object | `hooks/hooks.json` |
| `mcpServers` | string\|array\|object | `.mcp.json` |
| `lspServers` | string\|array\|object | `.lsp.json` |
| `outputStyles` | string\|array | — |

Use `${CLAUDE_PLUGIN_ROOT}` in hooks and MCP configs for plugin-relative paths (resolves correctly after installation to cache).

### Testing Locally

```bash
claude --plugin-dir ./my-plugin
# Multiple plugins:
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

### CLI Commands

```bash
claude plugin install plugin-name@marketplace-name [--scope user|project|local]
claude plugin uninstall plugin-name@marketplace-name
claude plugin enable plugin-name@marketplace-name
claude plugin disable plugin-name@marketplace-name
claude plugin update plugin-name@marketplace-name
claude plugin validate .
```

### Installation Scopes

| Scope | Settings file | Use case |
|:------|:-------------|:---------|
| `user` (default) | `~/.claude/settings.json` | Personal, all projects |
| `project` | `.claude/settings.json` | Team, shared via VCS |
| `local` | `.claude/settings.local.json` | Project-local, gitignored |
| `managed` | managed settings | Admin-controlled, read-only |

Plugin cache: `~/.claude/plugins/cache` (installed plugins are copied here; paths outside plugin dir are not accessible).

### Marketplace File (`marketplace.json`)

Location: `.claude-plugin/marketplace.json` in marketplace repo root.

```json
{
  "name": "my-tools",
  "owner": { "name": "Your Name", "email": "you@example.com" },
  "metadata": { "description": "...", "pluginRoot": "./plugins" },
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin",
      "description": "What this plugin does",
      "version": "1.0.0"
    }
  ]
}
```

### Plugin Sources

| Source | Format | Notes |
|:-------|:-------|:------|
| Relative path | `"./plugins/my-plugin"` | Works with git-based marketplaces only |
| GitHub | `{"source": "github", "repo": "owner/repo", "ref": "v1.0", "sha": "..."}` | |
| Git URL | `{"source": "url", "url": "https://example.com/plugin.git", "ref": "main"}` | |
| npm | `{"source": "npm", "package": "@org/plugin", "version": "2.0.0"}` | |
| pip | `{"source": "pip", "package": "my-plugin"}` | |

### Adding Marketplaces

```bash
/plugin marketplace add owner/repo          # GitHub
/plugin marketplace add https://gitlab.com/org/plugins.git
/plugin marketplace add ./local-marketplace
/plugin marketplace add https://example.com/marketplace.json
```

### Team Configuration (`.claude/settings.json`)

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

### LSP Plugins (Official Marketplace)

| Language | Plugin | Binary |
|:---------|:-------|:-------|
| Python | `pyright-lsp` | `pyright-langserver` |
| TypeScript | `typescript-lsp` | `typescript-language-server` |
| Rust | `rust-analyzer-lsp` | `rust-analyzer` |
| Go | `gopls-lsp` | `gopls` |
| C/C++ | `clangd-lsp` | `clangd` |
| Java | `jdtls-lsp` | `jdtls` |

Install language server binary first, then install plugin from marketplace.

### Common Troubleshooting

| Issue | Cause | Fix |
|:------|:------|:----|
| Components missing | Wrong dir location | Move out of `.claude-plugin/` to plugin root |
| Hook not firing | Script not executable | `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin paths |
| Plugin skills not appearing | Cache stale | `rm -rf ~/.claude/plugins/cache` then reinstall |
| Relative path sources fail | URL-based marketplace | Switch to git-based marketplace or use GitHub source |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — quickstart, plugin structure, skills/agents/hooks/MCP/LSP in plugins, migrating from standalone config
- [Plugins reference](references/claude-code-plugins-reference.md) — manifest schema, component specs, CLI commands, directory layout, debugging tools, versioning
- [Discover and install plugins](references/claude-code-discover-plugins.md) — official marketplace, adding marketplaces, installing/managing plugins, team configuration
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace schema, plugin sources, hosting, release channels, troubleshooting

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
