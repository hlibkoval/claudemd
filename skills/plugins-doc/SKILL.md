---
name: plugins-doc
description: Complete documentation for Claude Code plugins -- creating, structuring, testing, distributing, and managing plugins. Covers plugin manifest schema (plugin.json fields, required/optional metadata, component paths, userConfig, channels), plugin components (skills, agents, hooks, MCP servers, LSP servers, bin/, settings.json, output-styles), plugin directory structure and file locations, environment variables (CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA), plugin installation scopes (user, project, local, managed), CLI commands (plugin install/uninstall/enable/disable/update), debugging and troubleshooting, version management (semver), plugin caching and file resolution, converting standalone config to plugins, namespaced skill invocation, marketplace creation and distribution (marketplace.json schema, plugin sources: relative path, github, url, git-subdir, npm), marketplace management (add/list/remove/update, auto-updates), official Anthropic marketplace, code intelligence LSP plugins (pyright, typescript, rust-analyzer, clangd, gopls, and more), external integration plugins (github, gitlab, slack, jira, etc.), team marketplace configuration (extraKnownMarketplaces, enabledPlugins), managed marketplace restrictions (strictKnownMarketplaces, hostPattern, pathPattern), strict mode, release channels, plugin seed directories for containers (CLAUDE_CODE_PLUGIN_SEED_DIR, CLAUDE_CODE_PLUGIN_CACHE_DIR), private repository authentication, and validation/testing workflows. Load when discussing plugins, plugin creation, plugin.json, plugin manifest, plugin components, marketplace, plugin marketplace, plugin install, plugin distribution, LSP plugins, code intelligence plugins, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, plugin hooks, plugin MCP servers, plugin agents, plugin skills, plugin commands, plugin settings, plugin scopes, plugin caching, plugin validation, plugin debugging, extraKnownMarketplaces, enabledPlugins, strictKnownMarketplaces, plugin seed, plugin auto-update, or any plugins-related topic for Claude Code.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins -- self-contained extensions that add skills, agents, hooks, MCP servers, and LSP servers to Claude Code.

## Quick Reference

### Plugin vs Standalone

| Approach | Skill names | Best for |
|:---------|:-----------|:---------|
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, single-project customizations |
| **Plugins** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing, distribution, reuse across projects |

### Plugin Directory Structure

| Directory/File | Location | Purpose |
|:---------------|:---------|:--------|
| `.claude-plugin/plugin.json` | Plugin root | Manifest (optional -- name derived from dir if omitted) |
| `commands/` | Plugin root | Skill Markdown files (legacy; use `skills/` for new) |
| `skills/` | Plugin root | Agent Skills with `<name>/SKILL.md` structure |
| `agents/` | Plugin root | Subagent Markdown files |
| `hooks/hooks.json` | Plugin root | Hook configuration |
| `.mcp.json` | Plugin root | MCP server definitions |
| `.lsp.json` | Plugin root | Language server configurations |
| `bin/` | Plugin root | Executables added to Bash tool's PATH |
| `output-styles/` | Plugin root | Output style definitions |
| `settings.json` | Plugin root | Default settings (currently only `agent` key supported) |

### Plugin Manifest Schema (plugin.json)

**Required field:** `name` (kebab-case, no spaces) -- used as skill namespace prefix.

**Metadata fields:**

| Field | Type | Description |
|:------|:-----|:-----------|
| `name` | string | Unique identifier and namespace prefix |
| `version` | string | Semantic version (`MAJOR.MINOR.PATCH`) |
| `description` | string | Brief explanation of plugin purpose |
| `author` | object | `{name, email?, url?}` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX license identifier |
| `keywords` | array | Discovery tags |

**Component path fields:**

| Field | Type | Description |
|:------|:-----|:-----------|
| `commands` | string or array | Custom command files/dirs (replaces default `commands/`) |
| `agents` | string or array | Custom agent files (replaces default `agents/`) |
| `skills` | string or array | Custom skill dirs (replaces default `skills/`) |
| `hooks` | string, array, or object | Hook config paths or inline config |
| `mcpServers` | string, array, or object | MCP config paths or inline config |
| `lspServers` | string, array, or object | LSP config paths or inline config |
| `outputStyles` | string or array | Custom output style files/dirs |
| `userConfig` | object | User-configurable values prompted at enable time |
| `channels` | array | Channel declarations for message injection |

**Path rules:** All paths relative to plugin root, starting with `./`. Custom paths for commands/agents/skills/outputStyles replace defaults. To keep defaults and add more, include the default in the array.

### User Configuration (userConfig)

```json
{
  "userConfig": {
    "api_endpoint": { "description": "Your API endpoint", "sensitive": false },
    "api_token": { "description": "API auth token", "sensitive": true }
  }
}
```

Values available as `${user_config.KEY}` in MCP/LSP configs, hook commands, skill/agent content (non-sensitive only). Also exported as `CLAUDE_PLUGIN_OPTION_<KEY>` env vars. Sensitive values stored in system keychain.

### Channels

```json
{
  "channels": [
    { "server": "telegram", "userConfig": { "bot_token": { "description": "Bot token", "sensitive": true } } }
  ]
}
```

The `server` field must match a key in the plugin's `mcpServers`.

### Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin installation directory (changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state (survives updates) at `~/.claude/plugins/data/{id}/` |

Both are substituted inline in skill/agent content, hook commands, MCP/LSP configs, and exported as env vars to subprocesses.

### Plugin Installation Scopes

| Scope | Settings file | Use case |
|:------|:-------------|:---------|
| `user` | `~/.claude/settings.json` | Personal, all projects (default) |
| `project` | `.claude/settings.json` | Team, shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled, read-only |

### CLI Commands

| Command | Description |
|:--------|:-----------|
| `claude plugin install <plugin> [-s scope]` | Install from marketplace |
| `claude plugin uninstall <plugin> [-s scope] [--keep-data]` | Remove (aliases: `remove`, `rm`) |
| `claude plugin enable <plugin> [-s scope]` | Enable disabled plugin |
| `claude plugin disable <plugin> [-s scope]` | Disable without uninstalling |
| `claude plugin update <plugin> [-s scope]` | Update to latest version |
| `claude plugin validate .` | Validate plugin/marketplace JSON |

### LSP Server Configuration

```json
{
  "language-name": {
    "command": "lsp-binary",
    "args": ["serve"],
    "extensionToLanguage": { ".ext": "language" }
  }
}
```

**Required:** `command`, `extensionToLanguage`. **Optional:** `args`, `transport` (`stdio`/`socket`), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`.

### Official Code Intelligence Plugins

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

### Hook Events (Plugin Hooks)

Plugin hooks in `hooks/hooks.json` respond to all lifecycle events. Hook types: `command`, `http`, `prompt`, `agent`.

### Marketplace Schema (marketplace.json)

**Required fields:** `name` (kebab-case), `owner` (`{name, email?}`), `plugins` (array).

**Optional:** `metadata.description`, `metadata.version`, `metadata.pluginRoot`.

**Plugin entry required:** `name`, `source`.

### Plugin Sources in Marketplace

| Source | Format | Key fields |
|:-------|:-------|:-----------|
| Relative path | `"./plugins/my-plugin"` | -- |
| GitHub | `{source: "github", repo, ref?, sha?}` | `repo` required |
| Git URL | `{source: "url", url, ref?, sha?}` | `url` required |
| Git subdirectory | `{source: "git-subdir", url, path, ref?, sha?}` | `url`, `path` required |
| npm | `{source: "npm", package, version?, registry?}` | `package` required |

### Strict Mode

| Value | Behavior |
|:------|:---------|
| `true` (default) | `plugin.json` is authority; marketplace entry supplements |
| `false` | Marketplace entry is entire definition; conflicts with `plugin.json` components cause load failure |

### Marketplace Management Commands

| Command | Description |
|:--------|:-----------|
| `/plugin marketplace add <source>` | Add from GitHub (`owner/repo`), git URL, local path, or remote URL |
| `/plugin marketplace list` | List all configured marketplaces |
| `/plugin marketplace update [name]` | Refresh from source (all if name omitted) |
| `/plugin marketplace remove <name>` | Remove marketplace and its installed plugins |
| `/reload-plugins` | Reload all active plugins without restarting |

### Team Marketplace Configuration

```json
{
  "extraKnownMarketplaces": {
    "company-tools": { "source": { "source": "github", "repo": "your-org/plugins" } }
  },
  "enabledPlugins": {
    "plugin-name@marketplace-name": true
  }
}
```

### Managed Marketplace Restrictions (strictKnownMarketplaces)

| Value | Behavior |
|:------|:---------|
| Undefined | No restrictions |
| `[]` | Complete lockdown -- no new marketplaces |
| List of sources | Only matching marketplaces allowed |

Source types: `github` (`repo`, `ref?`), `url` (`url`), `hostPattern` (`hostPattern` regex), `pathPattern` (`pathPattern` regex).

### Container/CI Plugin Seeding

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_PLUGIN_SEED_DIR` | Read-only pre-populated plugins directory (colon-separated for multiple) |
| `CLAUDE_CODE_PLUGIN_CACHE_DIR` | Redirect plugin cache during build |
| `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE` | Set to `1` to keep stale cache on pull failure (offline environments) |
| `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` | Git operation timeout in ms (default 120000) |

### Debugging Checklist

| Issue | Solution |
|:------|:---------|
| Plugin not loading | `claude plugin validate` or `/plugin validate`; check `plugin.json` syntax |
| Commands not appearing | Ensure dirs at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | `chmod +x` scripts; verify event name case; check matcher |
| MCP server fails | Use `${CLAUDE_PLUGIN_ROOT}` for all paths |
| LSP binary not found | Install binary; check `/plugin` Errors tab |
| Path errors | All paths relative, starting with `./` |
| Plugin not updating | Bump `version` in `plugin.json`; cache uses version for dedup |

### Submitting to Official Marketplace

- Claude.ai: [claude.ai/settings/plugins/submit](https://claude.ai/settings/plugins/submit)
- Console: [platform.claude.com/plugins/submit](https://platform.claude.com/plugins/submit)

## Full Documentation

For the complete official documentation, see the reference files:

- [Create Plugins](references/claude-code-plugins.md) -- Creating plugins, quickstart, plugin structure, adding skills/agents/hooks/MCP/LSP, testing locally, converting standalone configs
- [Plugins Reference](references/claude-code-plugins-reference.md) -- Complete technical specs: manifest schema, component schemas, CLI commands, installation scopes, environment variables, caching, debugging, version management
- [Discover and Install Plugins](references/claude-code-discover-plugins.md) -- Browsing marketplaces, installing/managing plugins, official marketplace, code intelligence plugins, team configuration, troubleshooting
- [Plugin Marketplaces](references/claude-code-plugin-marketplaces.md) -- Creating and distributing marketplaces, marketplace.json schema, plugin sources, hosting, private repos, managed restrictions, release channels, container seeding, validation

## Sources

- Create Plugins: https://code.claude.com/docs/en/plugins.md
- Plugins Reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and Install Plugins: https://code.claude.com/docs/en/discover-plugins.md
- Plugin Marketplaces: https://code.claude.com/docs/en/plugin-marketplaces.md
