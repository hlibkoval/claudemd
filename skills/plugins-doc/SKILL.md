---
name: plugins-doc
description: Complete documentation for Claude Code plugins -- creating, configuring, distributing, and troubleshooting plugins. Covers plugin manifest schema (plugin.json fields, name, version, description, author, homepage, repository, license, keywords, component paths, userConfig, channels), plugin directory structure (commands/, agents/, skills/, hooks/, bin/, output-styles/, .mcp.json, .lsp.json, settings.json), plugin components (skills, agents, hooks, MCP servers, LSP servers), environment variables (CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, persistent data directory), plugin installation scopes (user, project, local, managed), plugin CLI commands (install, uninstall, enable, disable, update), plugin caching and file resolution, path traversal limitations, symlinks, testing plugins locally (--plugin-dir, /reload-plugins), debugging (claude --debug, common issues), version management (semver, MAJOR.MINOR.PATCH), converting standalone configurations to plugins, marketplace creation (marketplace.json schema, owner, plugins array, metadata, pluginRoot), marketplace distribution (GitHub, GitLab, local, URL), plugin sources (relative path, github, url, git-subdir, npm), strict mode, plugin discovery and installation (/plugin command, Discover tab, Installed tab, Marketplaces tab, Errors tab), official Anthropic marketplace (claude-plugins-official), code intelligence plugins (LSP: pyright-lsp, typescript-lsp, rust-analyzer-lsp, clangd-lsp, gopls-lsp, swift-lsp, kotlin-lsp, php-lsp, java-lsp, lua-lsp, csharp-lsp), external integration plugins (github, gitlab, slack, atlassian, linear, notion, figma, vercel, firebase, supabase, sentry, asana), auto-updates (DISABLE_AUTOUPDATER, FORCE_AUTOUPDATE_PLUGINS), team marketplace configuration (extraKnownMarketplaces, enabledPlugins), managed marketplace restrictions (strictKnownMarketplaces, hostPattern, pathPattern), container pre-population (CLAUDE_CODE_PLUGIN_SEED_DIR, CLAUDE_CODE_PLUGIN_CACHE_DIR), release channels, marketplace CLI commands (marketplace add, list, remove, update), marketplace validation (claude plugin validate), hook types (command, http, prompt, agent), hook events (SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, PermissionDenied, Notification, SubagentStart, SubagentStop, TaskCreated, TaskCompleted, Stop, StopFailure, TeammateIdle, InstructionsLoaded, ConfigChange, CwdChanged, FileChanged, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd), plugin submission to official marketplace. Load when discussing Claude Code plugins, plugin.json, plugin manifest, plugin marketplace, marketplace.json, plugin install, plugin uninstall, plugin enable, plugin disable, /plugin command, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, plugin hooks, plugin MCP servers, plugin LSP servers, plugin agents, plugin skills, plugin commands, plugin distribution, plugin caching, plugin scopes, plugin debugging, plugin validation, plugin testing, --plugin-dir, /reload-plugins, extraKnownMarketplaces, enabledPlugins, strictKnownMarketplaces, plugin sources, plugin seed directory, plugin auto-updates, strict mode, code intelligence plugins, or any Claude Code plugin-related topic.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins -- creating, configuring, distributing, and troubleshooting plugins and plugin marketplaces.

## Quick Reference

### Plugin vs Standalone

| Approach | Skill names | Best for |
|:---------|:------------|:---------|
| Standalone (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| Plugin (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Team sharing, community distribution, versioned releases, reuse across projects |

### Plugin Directory Structure

```
my-plugin/
  .claude-plugin/
    plugin.json           # Manifest (only file in .claude-plugin/)
  commands/               # Markdown command files (legacy; prefer skills/)
  agents/                 # Subagent markdown files
  skills/                 # Agent Skills (name/SKILL.md)
  hooks/
    hooks.json            # Hook configurations
  output-styles/          # Output style definitions
  bin/                    # Executables added to Bash tool PATH
  .mcp.json               # MCP server definitions
  .lsp.json               # LSP server configurations
  settings.json           # Default settings (currently only "agent" key)
  scripts/                # Hook and utility scripts
```

**Common mistake**: commands/, agents/, skills/, hooks/ go at the plugin root, NOT inside `.claude-plugin/`.

### Plugin Manifest (plugin.json)

**Required fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique identifier (kebab-case). Used as skill namespace prefix |

**Metadata fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `version` | string | Semver version (MAJOR.MINOR.PATCH) |
| `description` | string | Brief explanation of plugin purpose |
| `author` | object | `{name, email?, url?}` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX license identifier |
| `keywords` | array | Discovery tags |

**Component path fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `commands` | string or array | Custom command files/directories (replaces default `commands/`) |
| `agents` | string or array | Custom agent files (replaces default `agents/`) |
| `skills` | string or array | Custom skill directories (replaces default `skills/`) |
| `hooks` | string, array, or object | Hook config paths or inline config |
| `mcpServers` | string, array, or object | MCP config paths or inline config |
| `lspServers` | string, array, or object | LSP config paths or inline config |
| `outputStyles` | string or array | Custom output style files/directories |
| `userConfig` | object | User-configurable values prompted at enable time |
| `channels` | array | Channel declarations for message injection |

**Path rules**: Custom paths replace defaults. Paths must be relative, starting with `./`. To keep the default directory and add more, include the default in the array.

### Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin installation directory. Changes on update |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state (survives updates). Resolves to `~/.claude/plugins/data/{id}/` |

Both are substituted inline in skill/agent content, hook commands, and MCP/LSP server configs. Also exported as environment variables to subprocesses.

### User Configuration (userConfig)

Declare prompted values in plugin.json. Available as `${user_config.KEY}` in MCP/LSP configs, hook commands, and (non-sensitive only) skill/agent content. Exported as `CLAUDE_PLUGIN_OPTION_<KEY>` env vars.

- Non-sensitive values: stored in `settings.json` under `pluginConfigs`
- Sensitive values: stored in system keychain (approx 2 KB total limit)

### Installation Scopes

| Scope | Settings file | Use case |
|:------|:-------------|:---------|
| `user` (default) | `~/.claude/settings.json` | Personal plugins, all projects |
| `project` | `.claude/settings.json` | Team plugins via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings (read-only) | Admin-controlled plugins |

### Plugin CLI Commands

| Command | Description |
|:--------|:-----------|
| `claude plugin install <plugin> [-s scope]` | Install from marketplace |
| `claude plugin uninstall <plugin> [-s scope] [--keep-data]` | Remove plugin (aliases: `remove`, `rm`) |
| `claude plugin enable <plugin> [-s scope]` | Enable a disabled plugin |
| `claude plugin disable <plugin> [-s scope]` | Disable without uninstalling |
| `claude plugin update <plugin> [-s scope]` | Update to latest version |
| `claude plugin validate .` | Validate plugin.json and component files |

### Plugin Components

**Skills**: `skills/<name>/SKILL.md` -- model-invoked. Claude auto-uses based on task context.

**Agents**: `agents/<name>.md` -- frontmatter supports `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation`. Does NOT support `hooks`, `mcpServers`, or `permissionMode`.

**Hooks**: `hooks/hooks.json` or inline in plugin.json.

| Hook type | Behavior |
|:----------|:---------|
| `command` | Execute shell commands/scripts |
| `http` | POST event JSON to a URL |
| `prompt` | Evaluate a prompt with an LLM |
| `agent` | Run an agentic verifier with tools |

**Hook events**: SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PermissionDenied, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, TaskCreated, TaskCompleted, Stop, StopFailure, TeammateIdle, InstructionsLoaded, ConfigChange, CwdChanged, FileChanged, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd

**MCP servers**: `.mcp.json` at plugin root or inline in plugin.json. Servers start automatically when plugin is enabled.

**LSP servers**: `.lsp.json` at plugin root or inline in plugin.json.

| Required field | Description |
|:---------------|:------------|
| `command` | LSP binary to execute (must be in PATH) |
| `extensionToLanguage` | Maps file extensions to language identifiers |

Optional: `args`, `transport` (stdio/socket), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`

### Testing Locally

```bash
claude --plugin-dir ./my-plugin          # Load plugin for one session
claude --plugin-dir ./a --plugin-dir ./b # Load multiple plugins
```

Use `/reload-plugins` to pick up changes without restarting. A `--plugin-dir` plugin with the same name as an installed marketplace plugin takes precedence (except force-enabled managed plugins).

### Debugging

Run `claude --debug` to see plugin loading details. Use `claude plugin validate` or `/plugin validate` to check manifests.

| Issue | Solution |
|:------|:---------|
| Plugin not loading | Run `claude plugin validate` to check plugin.json |
| Commands not appearing | Ensure directories are at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Run `chmod +x script.sh`; verify event names are case-sensitive |
| MCP server fails | Use `${CLAUDE_PLUGIN_ROOT}` for all plugin paths |
| Path errors | All paths must be relative, starting with `./` |
| LSP binary not found | Install the language server binary separately |

### Version Management

Format: `MAJOR.MINOR.PATCH` (semver). Bump version before distributing changes. Claude Code uses the version to detect updates -- unchanged version means users won't see changes due to caching.

### Converting Standalone to Plugin

1. Create plugin directory with `.claude-plugin/plugin.json`
2. Copy `commands/`, `agents/`, `skills/` from `.claude/` to plugin root
3. Move hooks from `settings.json` to `hooks/hooks.json`
4. Test with `claude --plugin-dir ./my-plugin`

### Plugin Caching

Marketplace plugins are copied to `~/.claude/plugins/cache`. Each version is a separate directory; old versions are removed after 7 days. Plugins cannot reference files outside their directory. Use symlinks for external dependencies (symlinks are followed during copy).

---

### Marketplace Schema (marketplace.json)

Located at `.claude-plugin/marketplace.json`.

**Required fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Marketplace identifier (kebab-case) |
| `owner` | object | `{name (required), email (optional)}` |
| `plugins` | array | List of plugin entries |

**Optional metadata:**

| Field | Description |
|:------|:------------|
| `metadata.description` | Brief marketplace description |
| `metadata.version` | Marketplace version |
| `metadata.pluginRoot` | Base directory prepended to relative plugin source paths |

### Plugin Entry Fields (in marketplace.json)

**Required**: `name` (string), `source` (string or object)

**Optional**: `description`, `version`, `author`, `homepage`, `repository`, `license`, `keywords`, `category`, `tags`, `strict`, `commands`, `agents`, `hooks`, `mcpServers`, `lspServers`

### Plugin Sources

| Source | Type | Required fields |
|:-------|:-----|:---------------|
| Relative path | string (`"./my-plugin"`) | -- |
| GitHub | object | `repo` (owner/repo format) |
| Git URL | object (`source: "url"`) | `url` |
| Git subdirectory | object (`source: "git-subdir"`) | `url`, `path` |
| npm | object (`source: "npm"`) | `package` |

All except relative path support optional `ref` (branch/tag) and `sha` (commit pin). npm supports `version` and `registry`.

**Relative paths** resolve from the marketplace root (directory containing `.claude-plugin/`), not from the JSON file.

### Strict Mode

| Value | Behavior |
|:------|:---------|
| `true` (default) | plugin.json is authority; marketplace entry supplements |
| `false` | Marketplace entry is entire definition; plugin.json must not declare components |

### Marketplace Distribution

| Method | How to add |
|:-------|:-----------|
| GitHub | `/plugin marketplace add owner/repo` |
| Git URL | `/plugin marketplace add https://gitlab.com/company/plugins.git` |
| Local path | `/plugin marketplace add ./my-marketplace` |
| Remote URL | `/plugin marketplace add https://example.com/marketplace.json` |

Pin to branch/tag: `owner/repo@v2.0` or `https://...git#ref`

### Marketplace CLI Commands

| Command | Description |
|:--------|:-----------|
| `claude plugin marketplace add <source> [--scope] [--sparse]` | Add a marketplace |
| `claude plugin marketplace list [--json]` | List all configured marketplaces |
| `claude plugin marketplace remove <name>` | Remove marketplace (alias: `rm`) |
| `claude plugin marketplace update [name]` | Refresh marketplace(s) from source |

### Official Marketplace and Code Intelligence

The official Anthropic marketplace (`claude-plugins-official`) is available automatically.

**Code intelligence (LSP) plugins:**

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

### Auto-Updates

Official marketplaces: auto-update enabled by default. Third-party: disabled by default. Toggle per-marketplace in `/plugin` > Marketplaces.

| Variable | Effect |
|:---------|:-------|
| `DISABLE_AUTOUPDATER` | Disable all automatic updates |
| `FORCE_AUTOUPDATE_PLUGINS=1` | Keep plugin auto-updates while disabling Claude Code updates |

For private repo auto-updates, set `GITHUB_TOKEN`, `GITLAB_TOKEN`, or `BITBUCKET_TOKEN`.

### Team Marketplace Configuration

In `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "team-tools": {
      "source": { "source": "github", "repo": "your-org/plugins" }
    }
  },
  "enabledPlugins": {
    "formatter@team-tools": true
  }
}
```

### Managed Marketplace Restrictions (strictKnownMarketplaces)

Set in managed settings to control which marketplaces users can add:

| Value | Behavior |
|:------|:---------|
| Undefined | No restrictions |
| `[]` | Complete lockdown |
| List of sources | Only matching marketplaces allowed |

Source types: `github` (exact repo match), `url` (exact URL), `hostPattern` (regex on host), `pathPattern` (regex on filesystem path).

### Container Pre-Population

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_PLUGIN_SEED_DIR` | Read-only seed directory for pre-built plugins. Multiple paths separated by `:` |
| `CLAUDE_CODE_PLUGIN_CACHE_DIR` | Override plugin cache location (useful during image build) |
| `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE` | Set to `1` to keep stale marketplace cache on pull failure |
| `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` | Git operation timeout in ms (default 120000) |

### Submitting to Official Marketplace

- Claude.ai: claude.ai/settings/plugins/submit
- Console: platform.claude.com/plugins/submit

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) -- Guide for creating plugins with skills, agents, hooks, and MCP servers
- [Plugins reference](references/claude-code-plugins-reference.md) -- Complete technical reference including manifest schema, CLI commands, component specifications, and debugging tools
- [Discover and install plugins](references/claude-code-discover-plugins.md) -- Finding and installing plugins from marketplaces, managing installed plugins, and configuring team marketplaces
- [Plugin marketplaces](references/claude-code-plugin-marketplaces.md) -- Creating and distributing marketplace catalogs, marketplace schema, plugin sources, hosting, and troubleshooting

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Plugin marketplaces: https://code.claude.com/docs/en/plugin-marketplaces.md
