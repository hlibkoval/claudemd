---
name: plugins
description: Reference documentation for Claude Code plugins — creating, installing, distributing, and managing plugins that bundle skills, agents, hooks, MCP servers, and LSP servers. Covers plugin manifests, directory structure, marketplaces, plugin sources (GitHub, npm, git, pip), installation scopes, CLI commands, LSP configuration, caching, version management, team configuration, strict mode, and debugging.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for the Claude Code plugin system.

## Quick Reference

Plugins are self-contained directories that extend Claude Code with skills, agents, hooks, MCP servers, and LSP servers. They can be shared via marketplaces, installed across projects, and version-controlled independently.

### When to Use Plugins vs Standalone

| Approach      | Skill names              | Best for                                                   |
|:--------------|:-------------------------|:-----------------------------------------------------------|
| **Standalone** (`.claude/`) | `/hello`             | Personal workflows, single-project, quick experiments      |
| **Plugins**   | `/plugin-name:hello`     | Sharing with teams, reuse across projects, marketplace distribution |

### Plugin Directory Structure

```
my-plugin/
  .claude-plugin/
    plugin.json            # Manifest (only file in this dir)
  commands/                # Legacy skill Markdown files
  skills/                  # Agent Skills (name/SKILL.md)
  agents/                  # Subagent Markdown files
  hooks/
    hooks.json             # Hook configuration
  .mcp.json                # MCP server definitions
  .lsp.json                # LSP server configurations
  settings.json            # Default settings (only "agent" key supported)
  scripts/                 # Hook and utility scripts
```

Components go at the plugin root -- NOT inside `.claude-plugin/`.

### Plugin Manifest (`plugin.json`)

| Field         | Required | Type          | Description                                       |
|:--------------|:---------|:--------------|:--------------------------------------------------|
| `name`        | Yes      | string        | Unique identifier (kebab-case), used as namespace |
| `version`     | No       | string        | Semantic version (`MAJOR.MINOR.PATCH`)            |
| `description` | No       | string        | Brief plugin description                          |
| `author`      | No       | object        | `{name, email?, url?}`                            |
| `homepage`    | No       | string        | Documentation URL                                 |
| `repository`  | No       | string        | Source code URL                                    |
| `license`     | No       | string        | SPDX license identifier                           |
| `keywords`    | No       | array         | Discovery tags                                     |
| `commands`    | No       | string/array  | Additional command paths                           |
| `agents`      | No       | string/array  | Additional agent paths                             |
| `skills`      | No       | string/array  | Additional skill paths                             |
| `hooks`       | No       | string/array/object | Hook config paths or inline                  |
| `mcpServers`  | No       | string/array/object | MCP config paths or inline                   |
| `lspServers`  | No       | string/array/object | LSP config paths or inline                   |
| `outputStyles`| No       | string/array  | Output style paths                                 |

Custom paths supplement defaults -- they do not replace them. All paths must be relative and start with `./`.

### Installation Scopes

| Scope     | Settings file                   | Use case                                     |
|:----------|:--------------------------------|:---------------------------------------------|
| `user`    | `~/.claude/settings.json`      | Personal, all projects (default)             |
| `project` | `.claude/settings.json`        | Team, shared via version control             |
| `local`   | `.claude/settings.local.json`  | Project-specific, gitignored                 |
| `managed` | Managed settings               | Admin-controlled (read-only, update only)    |

### CLI Commands

| Command                      | Description                          | Key flags                    |
|:-----------------------------|:-------------------------------------|:-----------------------------|
| `claude plugin install <p>`  | Install from marketplace             | `-s, --scope <scope>`        |
| `claude plugin uninstall <p>`| Remove installed plugin              | `-s, --scope <scope>`        |
| `claude plugin enable <p>`   | Re-enable a disabled plugin          | `-s, --scope <scope>`        |
| `claude plugin disable <p>`  | Disable without uninstalling         | `-s, --scope <scope>`        |
| `claude plugin update <p>`   | Update to latest version             | `-s, --scope <scope>`        |
| `claude plugin validate .`   | Validate plugin/marketplace JSON     |                              |
| `claude --plugin-dir ./path` | Load plugin locally for testing      |                              |
| `claude --debug`             | Show plugin loading details          |                              |

Use `<plugin-name>@<marketplace-name>` format for plugin identifiers.

### Marketplace Schema

| Field     | Required | Description                                                |
|:----------|:---------|:-----------------------------------------------------------|
| `name`    | Yes      | Marketplace identifier (kebab-case)                        |
| `owner`   | Yes      | `{name, email?}` of maintainer                            |
| `plugins` | Yes      | Array of plugin entries                                    |
| `metadata`| No       | `{description?, version?, pluginRoot?}`                    |

### Plugin Source Types

| Source        | Format                                 | Notes                                       |
|:--------------|:---------------------------------------|:--------------------------------------------|
| Relative path | `"./plugins/my-plugin"`               | Within marketplace repo, must start with `./`|
| GitHub        | `{source:"github", repo:"owner/repo"}`| Optional `ref`, `sha`                       |
| Git URL       | `{source:"url", url:"...git"}`        | Optional `ref`, `sha`                       |
| npm           | `{source:"npm", package:"@org/pkg"}`  | Optional `version`, `registry`              |
| pip           | `{source:"pip", package:"pkg"}`       | Optional `version`, `registry`              |

### Environment Variables

| Variable                | Description                                |
|:------------------------|:-------------------------------------------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin directory          |

Use this in hooks, MCP servers, and scripts for correct paths regardless of installation location.

### Marketplace Management

```bash
# Add marketplaces
/plugin marketplace add owner/repo                    # GitHub
/plugin marketplace add https://gitlab.com/co/p.git   # Git URL
/plugin marketplace add ./local-dir                    # Local path

# Manage
/plugin marketplace list
/plugin marketplace update <name>
/plugin marketplace remove <name>
```

### Team Configuration

Add marketplace + plugins to `.claude/settings.json` so team members get prompted automatically:

```json
{
  "extraKnownMarketplaces": {
    "company-tools": {
      "source": { "source": "github", "repo": "org/plugins" }
    }
  },
  "enabledPlugins": {
    "my-plugin@company-tools": true
  }
}
```

### LSP Server Configuration (`.lsp.json`)

| Field                   | Required | Description                                    |
|:------------------------|:---------|:-----------------------------------------------|
| `command`               | Yes      | LSP binary to execute (must be in PATH)        |
| `extensionToLanguage`   | Yes      | Maps file extensions to language identifiers   |
| `args`                  | No       | Command-line arguments                          |
| `transport`             | No       | `stdio` (default) or `socket`                  |
| `env`                   | No       | Environment variables                           |
| `initializationOptions` | No       | Server initialization options                   |
| `restartOnCrash`        | No       | Auto-restart if server crashes                  |
| `maxRestarts`           | No       | Max restart attempts                            |

### Strict Mode (Marketplace)

| Value            | Behavior                                                                 |
|:-----------------|:-------------------------------------------------------------------------|
| `true` (default) | `plugin.json` is authority; marketplace supplements                      |
| `false`          | Marketplace entry is entire definition; conflicts with `plugin.json` fail|

### Caching

Marketplace plugins are copied to `~/.claude/plugins/cache`. Plugins cannot reference files outside their directory after installation. Use symlinks for external dependencies.

### Common Debugging Issues

| Issue                      | Cause                      | Solution                                                    |
|:---------------------------|:---------------------------|:------------------------------------------------------------|
| Plugin not loading         | Invalid `plugin.json`      | `claude plugin validate` or `/plugin validate`              |
| Components missing         | Wrong directory structure   | Components at root, NOT in `.claude-plugin/`                |
| Hooks not firing           | Script not executable      | `chmod +x script.sh`                                        |
| MCP server fails           | Missing plugin root var    | Use `${CLAUDE_PLUGIN_ROOT}` for all paths                   |
| LSP binary not found       | Server not installed       | Install the binary (e.g., `npm install -g typescript-language-server`) |
| Users not seeing updates   | Version not bumped         | Update `version` in `plugin.json` before distributing       |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create Plugins](references/claude-code-plugins.md) -- quickstart, plugin structure, adding skills/agents/hooks/MCP/LSP, testing locally, migration from standalone config
- [Plugins Reference](references/claude-code-plugins-reference.md) -- complete manifest schema, component specifications, CLI commands, debugging tools, directory structure, version management
- [Discover and Install Plugins](references/claude-code-discover-plugins.md) -- official marketplace, adding marketplaces (GitHub/Git/local/URL), installing and managing plugins, auto-updates, team configuration, troubleshooting
- [Plugin Marketplaces](references/claude-code-plugin-marketplaces.md) -- creating and hosting marketplaces, marketplace schema, plugin sources, strict mode, release channels, private repos, managed restrictions, validation

## Sources

- Create Plugins: https://code.claude.com/docs/en/plugins.md
- Plugins Reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and Install Plugins: https://code.claude.com/docs/en/discover-plugins.md
- Plugin Marketplaces: https://code.claude.com/docs/en/plugin-marketplaces.md
