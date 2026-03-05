---
name: plugins-doc
description: Complete documentation for Claude Code plugins — creating plugins (manifest, skills, agents, hooks, MCP/LSP servers, settings.json), plugin directory structure, discovering and installing plugins from marketplaces, marketplace creation and distribution, plugin sources (GitHub, git, npm, pip, relative paths), CLI commands (install, uninstall, enable, disable, update), installation scopes (user, project, local, managed), plugin caching, strict mode, version management, auto-updates, managed marketplace restrictions (strictKnownMarketplaces), team marketplace configuration, debugging, and troubleshooting. Load when discussing plugin development, plugin installation, marketplaces, plugin distribution, or the /plugin command.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins: creating plugins, discovering and installing them, the plugin reference, and marketplace creation/distribution.

## Quick Reference

Plugins extend Claude Code with skills, agents, hooks, MCP servers, and LSP servers. They live in self-contained directories with a `.claude-plugin/plugin.json` manifest. Plugin components are namespaced (e.g., `/my-plugin:hello`) to prevent conflicts.

### When to Use Plugins vs Standalone

| Approach | Skill names | Best for |
|:---------|:------------|:---------|
| Standalone (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| Plugins (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing, distributing, versioned releases, reuse across projects |

### Plugin Directory Structure

| Directory/File | Location | Purpose |
|:---------------|:---------|:--------|
| `.claude-plugin/` | Plugin root | Contains `plugin.json` manifest only |
| `commands/` | Plugin root | Skills as Markdown files (legacy; use `skills/`) |
| `skills/` | Plugin root | Agent Skills with `SKILL.md` files |
| `agents/` | Plugin root | Custom agent definitions |
| `hooks/` | Plugin root | Hook configurations (`hooks.json`) |
| `.mcp.json` | Plugin root | MCP server definitions |
| `.lsp.json` | Plugin root | LSP server configurations |
| `settings.json` | Plugin root | Default settings (currently only `agent` key supported) |

Components must be at the plugin root, NOT inside `.claude-plugin/`.

### Plugin Manifest (`plugin.json`) Fields

**Required:**

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique identifier (kebab-case, no spaces); used as namespace prefix |

**Metadata (optional):**

| Field | Type | Description |
|:------|:-----|:------------|
| `version` | string | Semantic version (`MAJOR.MINOR.PATCH`) |
| `description` | string | Brief explanation of plugin purpose |
| `author` | object | `{name, email, url}` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX license identifier |
| `keywords` | array | Discovery tags |

**Component paths (optional):**

| Field | Type | Description |
|:------|:-----|:------------|
| `commands` | string or array | Additional command files/directories |
| `agents` | string or array | Additional agent files |
| `skills` | string or array | Additional skill directories |
| `hooks` | string, array, or object | Hook config paths or inline config |
| `mcpServers` | string, array, or object | MCP config paths or inline config |
| `lspServers` | string, array, or object | LSP server configs |
| `outputStyles` | string or array | Additional output style files/directories |

Custom paths supplement default directories -- they do not replace them. All paths must be relative and start with `./`.

### Environment Variable

`${CLAUDE_PLUGIN_ROOT}` -- absolute path to the plugin directory. Use in hooks, MCP servers, and scripts to ensure correct paths regardless of installation location.

### Plugin Components

**Hook events available in plugins:** `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `UserPromptSubmit`, `Notification`, `Stop`, `SubagentStart`, `SubagentStop`, `SessionStart`, `SessionEnd`, `TeammateIdle`, `TaskCompleted`, `PreCompact`

**Hook types:** `command`, `prompt`, `agent`

**LSP server required fields:** `command` (binary to execute), `extensionToLanguage` (maps file extensions to language identifiers)

**LSP server optional fields:** `args`, `transport` (`stdio` or `socket`), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`

### Installation Scopes

| Scope | Settings file | Use case |
|:------|:-------------|:---------|
| `user` | `~/.claude/settings.json` | Personal plugins across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific plugins, gitignored |
| `managed` | Managed settings | Read-only, update only |

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude plugin install <plugin> [-s scope]` | Install from marketplace |
| `claude plugin uninstall <plugin> [-s scope]` | Remove plugin (aliases: `remove`, `rm`) |
| `claude plugin enable <plugin> [-s scope]` | Enable a disabled plugin |
| `claude plugin disable <plugin> [-s scope]` | Disable without uninstalling |
| `claude plugin update <plugin> [-s scope]` | Update to latest version |
| `claude plugin validate .` | Validate plugin/marketplace JSON |

Plugin argument format: `plugin-name` or `plugin-name@marketplace-name`.

### Marketplace Basics

A marketplace is a catalog of plugins defined by `.claude-plugin/marketplace.json`. The official Anthropic marketplace (`claude-plugins-official`) is automatically available.

**Marketplace commands:**

| Command | Description |
|:--------|:------------|
| `/plugin marketplace add <source>` | Add marketplace (GitHub `owner/repo`, git URL, local path, or remote URL) |
| `/plugin marketplace list` | List configured marketplaces |
| `/plugin marketplace update <name>` | Refresh plugin listings |
| `/plugin marketplace remove <name>` | Remove marketplace (uninstalls its plugins) |
| `/reload-plugins` | Reload all active plugins without restarting |

### Marketplace Schema Required Fields

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Marketplace identifier (kebab-case) |
| `owner` | object | `{name, email?}` -- maintainer information |
| `plugins` | array | List of plugin entries |

### Plugin Sources (in `marketplace.json`)

| Source | Format | Key fields |
|:-------|:-------|:-----------|
| Relative path | `"./plugins/my-plugin"` | Must start with `./`; only works with git-based marketplaces |
| GitHub | `{source: "github", repo, ref?, sha?}` | `repo` in `owner/repo` format |
| Git URL | `{source: "url", url, ref?, sha?}` | URL must end with `.git` |
| Git subdirectory | `{source: "git-subdir", url, path, ref?, sha?}` | Sparse clone for monorepos |
| npm | `{source: "npm", package, version?, registry?}` | Installed via `npm install` |
| pip | `{source: "pip", package, version?, registry?}` | Installed via pip |

### Strict Mode

| Value | Behavior |
|:------|:---------|
| `true` (default) | `plugin.json` is authority; marketplace entry supplements |
| `false` | Marketplace entry is the entire definition; `plugin.json` components cause conflict |

### Team Marketplace Configuration

Add to `.claude/settings.json` to auto-prompt team members:

```json
{
  "extraKnownMarketplaces": {
    "team-tools": {
      "source": { "source": "github", "repo": "your-org/claude-plugins" }
    }
  },
  "enabledPlugins": {
    "formatter@team-tools": true
  }
}
```

### Managed Marketplace Restrictions (`strictKnownMarketplaces`)

Set in managed settings to restrict which marketplaces users can add:

| Value | Behavior |
|:------|:---------|
| Undefined (default) | No restrictions |
| `[]` | Complete lockdown -- no new marketplaces |
| List of sources | Only matching marketplaces allowed |

Supports `github`, `url`, `hostPattern`, and `pathPattern` source types.

### Auto-Updates

Official marketplaces auto-update by default. Toggle per marketplace via `/plugin` > Marketplaces. Set `DISABLE_AUTOUPDATER=true` to disable all auto-updates. Set `FORCE_AUTOUPDATE_PLUGINS=true` alongside it to keep plugin auto-updates while disabling Claude Code updates.

### Private Repository Auth (for background auto-updates)

| Provider | Environment variables |
|:---------|:---------------------|
| GitHub | `GITHUB_TOKEN` or `GH_TOKEN` |
| GitLab | `GITLAB_TOKEN` or `GL_TOKEN` |
| Bitbucket | `BITBUCKET_TOKEN` |

### Official Marketplace Code Intelligence Plugins

| Language | Plugin | Binary required |
|:---------|:-------|:---------------|
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

### Plugin Caching

Marketplace plugins are copied to `~/.claude/plugins/cache`. Paths referencing files outside the plugin directory will not work after installation. Use symlinks to include external files -- they are honored during copying.

### Debugging

- Use `claude --debug` (or `/debug` in TUI) to see plugin loading details
- Use `claude plugin validate` or `/plugin validate` to check manifest/marketplace JSON
- Check `/plugin` Errors tab for loading errors
- Common fix: ensure components are at plugin root, not inside `.claude-plugin/`

### Git Timeout

Default git operation timeout is 120 seconds. Override with `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` (milliseconds).

### Submitting to Official Marketplace

- Claude.ai: claude.ai/settings/plugins/submit
- Console: platform.claude.com/plugins/submit

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) -- creating plugins with skills, agents, hooks, MCP/LSP servers, plugin structure, testing locally, converting standalone config to plugins, sharing and distributing
- [Plugins reference](references/claude-code-plugins-reference.md) -- complete technical reference: manifest schema, component specifications, installation scopes, CLI commands, environment variables, caching, debugging, version management
- [Discover and install plugins](references/claude-code-discover-plugins.md) -- finding plugins from marketplaces, official marketplace catalog, adding marketplaces (GitHub, git, local, URL), installing/managing plugins, team marketplace configuration, auto-updates, security, troubleshooting
- [Plugin marketplaces](references/claude-code-plugin-marketplaces.md) -- creating marketplace.json, marketplace schema, plugin entries, plugin sources, strict mode, hosting, distribution, private repos, managed restrictions (strictKnownMarketplaces), version resolution, release channels, validation, troubleshooting

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Plugin marketplaces: https://code.claude.com/docs/en/plugin-marketplaces.md
