---
name: plugins
description: Reference documentation for Claude Code plugins -- creating plugins, plugin manifest schema, plugin directory structure, component specifications (skills, agents, hooks, MCP servers, LSP servers), discovering and installing plugins, marketplace creation and distribution, CLI commands, installation scopes, caching, debugging, environment variables, team configuration, auto-updates, and version management.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

Plugins are self-contained directories that extend Claude Code with skills, agents, hooks, MCP servers, and LSP servers. They use namespaced skills (e.g., `/plugin-name:skill-name`) to avoid conflicts.

### When to Use Plugins vs Standalone

| Approach    | Skill names          | Best for                                              |
|:------------|:---------------------|:------------------------------------------------------|
| Standalone  | `/hello`             | Personal workflows, single-project, quick experiments |
| Plugins     | `/plugin-name:hello` | Sharing, multi-project reuse, versioned distribution  |

### Plugin Directory Structure

| Directory / File    | Location    | Purpose                                          |
|:--------------------|:------------|:-------------------------------------------------|
| `.claude-plugin/`   | Plugin root | Contains `plugin.json` manifest only             |
| `skills/`           | Plugin root | Agent Skills with `SKILL.md` files               |
| `commands/`         | Plugin root | Legacy skill markdown files                      |
| `agents/`           | Plugin root | Custom subagent definitions                      |
| `hooks/`            | Plugin root | Event handlers in `hooks.json`                   |
| `.mcp.json`         | Plugin root | MCP server configurations                        |
| `.lsp.json`         | Plugin root | LSP server configurations                        |
| `settings.json`     | Plugin root | Default settings (currently only `agent` key)    |

Components must be at the plugin root, NOT inside `.claude-plugin/`.

### Plugin Manifest (`plugin.json`) Fields

| Field         | Required | Type          | Description                                     |
|:--------------|:---------|:--------------|:------------------------------------------------|
| `name`        | Yes      | string        | Unique identifier (kebab-case, no spaces)       |
| `version`     | No       | string        | Semantic version (`MAJOR.MINOR.PATCH`)          |
| `description` | No       | string        | Brief explanation of plugin purpose             |
| `author`      | No       | object        | `{name, email?, url?}`                          |
| `homepage`    | No       | string        | Documentation URL                               |
| `repository`  | No       | string        | Source code URL                                  |
| `license`     | No       | string        | SPDX license identifier                         |
| `keywords`    | No       | array         | Discovery tags                                  |
| `commands`    | No       | string\|array | Additional command files/directories            |
| `agents`      | No       | string\|array | Additional agent files                          |
| `skills`      | No       | string\|array | Additional skill directories                    |
| `hooks`       | No       | string\|array\|object | Hook config paths or inline config      |
| `mcpServers`  | No       | string\|array\|object | MCP config paths or inline config       |
| `lspServers`  | No       | string\|array\|object | LSP server configurations               |
| `outputStyles`| No       | string\|array | Output style files/directories                  |

Custom paths supplement default directories -- they do not replace them. All paths must be relative and start with `./`.

### Installation Scopes

| Scope     | Settings file                  | Use case                                  |
|:----------|:-------------------------------|:------------------------------------------|
| `user`    | `~/.claude/settings.json`     | Personal, all projects (default)          |
| `project` | `.claude/settings.json`       | Team, shared via version control          |
| `local`   | `.claude/settings.local.json` | Project-specific, gitignored              |
| `managed` | Managed settings               | Organization-wide, read-only              |

### CLI Commands

| Command                     | Description                            | Aliases          |
|:----------------------------|:---------------------------------------|:-----------------|
| `claude plugin install`     | Install a plugin from a marketplace    |                  |
| `claude plugin uninstall`   | Remove an installed plugin             | `remove`, `rm`   |
| `claude plugin enable`      | Enable a disabled plugin               |                  |
| `claude plugin disable`     | Disable without uninstalling           |                  |
| `claude plugin update`      | Update to latest version               |                  |
| `claude plugin validate`    | Validate plugin or marketplace JSON    |                  |

All accept `-s, --scope <scope>` option (`user`, `project`, `local`).

### Marketplace Schema (`.claude-plugin/marketplace.json`)

| Field               | Required | Description                                      |
|:--------------------|:---------|:-------------------------------------------------|
| `name`              | Yes      | Marketplace identifier (kebab-case)              |
| `owner`             | Yes      | `{name, email?}`                                 |
| `plugins`           | Yes      | Array of plugin entries                          |
| `metadata.pluginRoot` | No    | Base directory for relative plugin source paths  |

### Plugin Source Types

| Source        | Format                             | Notes                                   |
|:--------------|:-----------------------------------|:----------------------------------------|
| Relative path | `"./my-plugin"` (string)          | Within the marketplace repo             |
| GitHub        | `{source: "github", repo, ref?, sha?}` | GitHub repository                  |
| Git URL       | `{source: "url", url, ref?, sha?}` | Any git host (URL must end `.git`)     |
| npm           | `{source: "npm", package, version?, registry?}` | Via `npm install`          |
| pip           | `{source: "pip", package, version?, registry?}` | Via pip                    |

### Environment Variables

| Variable               | Available in   | Description                      |
|:-----------------------|:---------------|:---------------------------------|
| `${CLAUDE_PLUGIN_ROOT}` | Hooks, MCP, scripts | Absolute path to plugin directory |

### Testing Locally

```bash
claude --plugin-dir ./my-plugin
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

### Debugging

Run `claude --debug` or `/debug` in TUI. Check `/plugin` Errors tab for loading issues.

| Issue                | Cause                        | Solution                                         |
|:---------------------|:-----------------------------|:-------------------------------------------------|
| Plugin not loading   | Invalid `plugin.json`        | `claude plugin validate` or `/plugin validate`   |
| Commands missing     | Wrong directory structure    | Components at root, not in `.claude-plugin/`     |
| Hooks not firing     | Script not executable        | `chmod +x script.sh`                             |
| MCP server fails     | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin paths            |
| Path errors          | Absolute paths used          | Paths must be relative, start with `./`          |
| LSP binary not found | Server not installed         | Install the language server binary               |

### Plugin Caching

Marketplace plugins are copied to `~/.claude/plugins/cache`. Paths referencing files outside the plugin directory will not work after installation. Use symlinks for external dependencies.

### Marketplace Management Commands

| Command                             | Description                           |
|:------------------------------------|:--------------------------------------|
| `/plugin marketplace add <source>`  | Add from GitHub, Git URL, local, URL  |
| `/plugin marketplace list`          | List configured marketplaces          |
| `/plugin marketplace update <name>` | Refresh plugin listings               |
| `/plugin marketplace remove <name>` | Remove a marketplace                  |

Shortcut: `/plugin market` works in place of `/plugin marketplace`.

### Team Configuration

Add to `.claude/settings.json` to auto-prompt team members:

```json
{
  "extraKnownMarketplaces": {
    "team-tools": {
      "source": { "source": "github", "repo": "org/plugins" }
    }
  },
  "enabledPlugins": {
    "formatter@team-tools": true
  }
}
```

### Official LSP Plugins

| Plugin              | Language   | Binary required              |
|:--------------------|:-----------|:-----------------------------|
| `clangd-lsp`        | C/C++      | `clangd`                     |
| `csharp-lsp`        | C#         | `csharp-ls`                  |
| `gopls-lsp`         | Go         | `gopls`                      |
| `jdtls-lsp`         | Java       | `jdtls`                      |
| `kotlin-lsp`        | Kotlin     | `kotlin-language-server`     |
| `lua-lsp`           | Lua        | `lua-language-server`        |
| `php-lsp`           | PHP        | `intelephense`               |
| `pyright-lsp`       | Python     | `pyright-langserver`         |
| `rust-analyzer-lsp` | Rust       | `rust-analyzer`              |
| `swift-lsp`         | Swift      | `sourcekit-lsp`              |
| `typescript-lsp`    | TypeScript | `typescript-language-server` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create Plugins](references/claude-code-plugins.md) -- creating plugins, plugin structure, skills/agents/hooks/MCP/LSP, testing, migration from standalone
- [Plugins Reference](references/claude-code-plugins-reference.md) -- complete manifest schema, CLI commands, component specs, debugging, versioning
- [Discover and Install Plugins](references/claude-code-discover-plugins.md) -- marketplaces, installing/managing plugins, official plugins, troubleshooting
- [Plugin Marketplaces](references/claude-code-plugin-marketplaces.md) -- creating marketplaces, marketplace schema, plugin sources, hosting, distribution, team setup

## Sources

- Create Plugins: https://code.claude.com/docs/en/plugins.md
- Plugins Reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and Install Plugins: https://code.claude.com/docs/en/discover-plugins.md
- Plugin Marketplaces: https://code.claude.com/docs/en/plugin-marketplaces.md
