---
name: plugins-doc
description: Complete documentation for Claude Code plugins -- creating, distributing, installing, and managing plugins. Covers plugin creation (quickstart, plugin manifest .claude-plugin/plugin.json, plugin structure overview, directory layout with commands/agents/skills/hooks/.mcp.json/.lsp.json/settings.json/output-styles, adding skills/agents/hooks/MCP servers/LSP servers, testing with --plugin-dir, /reload-plugins, debugging with --debug, converting standalone .claude/ to plugins), plugin manifest schema (required name field, metadata fields version/description/author/homepage/repository/license/keywords, component path fields commands/agents/skills/hooks/mcpServers/outputStyles/lspServers/userConfig/channels, path behavior rules replace-default/relative-to-root/array-for-multiple, user configuration with sensitive values and ${user_config.KEY} substitution, channels for message injection), environment variables (${CLAUDE_PLUGIN_ROOT} for bundled files, ${CLAUDE_PLUGIN_DATA} for persistent state across updates, data directory location ~/.claude/plugins/data/{id}/), plugin installation scopes (user/project/local/managed with settings file locations), plugin caching (cache at ~/.claude/plugins/cache, path traversal limitations, symlinks for external dependencies), CLI commands (plugin install/uninstall/enable/disable/update with --scope flag), debugging (claude --debug, claude plugin validate, /plugin validate, common issues table, hook troubleshooting, MCP server troubleshooting, directory structure mistakes), version management (semver MAJOR.MINOR.PATCH, bump before distributing), discover and install plugins (official Anthropic marketplace claude-plugins-official, /plugin UI with Discover/Installed/Marketplaces/Errors tabs, code intelligence LSP plugins for Python/TypeScript/Rust/Go/C++/Java/Kotlin/PHP/Swift/Lua/C#, external integrations GitHub/GitLab/Slack/Jira/Linear/Notion/Figma/Vercel/Firebase/Supabase/Sentry, development workflow plugins, output style plugins), marketplace management (add from GitHub owner/repo, git URLs, local paths, remote URLs, specific branch/tag with #ref, marketplace list/update/remove, auto-updates toggle, DISABLE_AUTOUPDATER, FORCE_AUTOUPDATE_PLUGINS), team configuration (extraKnownMarketplaces in .claude/settings.json, enabledPlugins), plugin marketplaces (marketplace.json schema with name/owner/plugins, marketplace metadata.description/metadata.version/metadata.pluginRoot, plugin entries with name/source/description/version/author/homepage/category/tags/strict, plugin sources relative-path/github/url/git-subdir/npm with ref/sha pinning, strict mode true vs false for authority control, hosting on GitHub/GitLab/Bitbucket, private repos with credential helpers and GITHUB_TOKEN/GITLAB_TOKEN/BITBUCKET_TOKEN, CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS, CLAUDE_CODE_PLUGIN_SEED_DIR for containers, managed marketplace restrictions with strictKnownMarketplaces allowlist/hostPattern/pathPattern, version resolution and release channels, validation with claude plugin validate), hook lifecycle events (SessionStart/UserPromptSubmit/PreToolUse/PermissionRequest/PermissionDenied/PostToolUse/PostToolUseFailure/Notification/SubagentStart/SubagentStop/TaskCreated/TaskCompleted/Stop/StopFailure/TeammateIdle/InstructionsLoaded/ConfigChange/CwdChanged/FileChanged/WorktreeCreate/WorktreeRemove/PreCompact/PostCompact/Elicitation/ElicitationResult/SessionEnd), hook types (command/http/prompt/agent), LSP server configuration (command/extensionToLanguage required, args/transport/env/initializationOptions/settings/workspaceFolder/startupTimeout/shutdownTimeout/restartOnCrash/maxRestarts optional), and troubleshooting (marketplace not loading, validation errors, installation failures, private repo auth, git timeouts, relative paths in URL marketplaces, files not found after installation). Load when discussing Claude Code plugins, plugin creation, plugin.json manifest, plugin marketplaces, marketplace.json, plugin installation, /plugin command, plugin scopes, plugin distribution, plugin debugging, LSP plugins, code intelligence plugins, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, plugin hooks, plugin MCP servers, plugin caching, extraKnownMarketplaces, enabledPlugins, strictKnownMarketplaces, plugin sources, plugin versioning, plugin auto-updates, plugin seed directory, or any plugin-related topic for Claude Code.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins -- creating, distributing, installing, and managing plugins and plugin marketplaces.

## Quick Reference

### Plugin Directory Structure

```
my-plugin/
  .claude-plugin/
    plugin.json            # Plugin manifest (only file in this dir)
  commands/                # Skill Markdown files (legacy; use skills/)
  agents/                  # Subagent Markdown files
  skills/                  # Agent Skills with <name>/SKILL.md
  output-styles/           # Output style definitions
  hooks/
    hooks.json             # Hook configuration
  .mcp.json                # MCP server definitions
  .lsp.json                # LSP server configurations
  settings.json            # Default settings (only "agent" key supported)
  scripts/                 # Hook and utility scripts
```

All component directories go at the plugin root -- never inside `.claude-plugin/`.

### Plugin Manifest (plugin.json) Required Fields

| Field | Type | Description | Example |
|:------|:-----|:------------|:--------|
| `name` | string | Unique identifier (kebab-case, no spaces); used as namespace prefix | `"deployment-tools"` |

### Plugin Manifest Optional Metadata

| Field | Type | Description |
|:------|:-----|:------------|
| `version` | string | Semver version (MAJOR.MINOR.PATCH) |
| `description` | string | Brief explanation of plugin purpose |
| `author` | object | `{ "name": "...", "email": "..." }` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier (e.g., `"MIT"`) |
| `keywords` | array | Discovery tags |

### Component Path Fields

| Field | Type | Default Location | Notes |
|:------|:-----|:-----------------|:------|
| `commands` | string or array | `commands/` | Custom paths replace default dir |
| `agents` | string or array | `agents/` | Custom paths replace default dir |
| `skills` | string or array | `skills/` | Custom paths replace default dir |
| `hooks` | string, array, or object | `hooks/hooks.json` | Merged, not replaced |
| `mcpServers` | string, array, or object | `.mcp.json` | Merged, not replaced |
| `lspServers` | string, array, or object | `.lsp.json` | Merged, not replaced |
| `outputStyles` | string or array | `output-styles/` | Custom paths replace default dir |
| `userConfig` | object | -- | User-configurable values prompted at enable time |
| `channels` | array | -- | Channel declarations for message injection |

All paths must be relative to plugin root and start with `./`. Include default dir in array to keep it: `"commands": ["./commands/", "./extras/cmd.md"]`.

### Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin installation directory (changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state (survives updates); at `~/.claude/plugins/data/{id}/` |

Both are substituted inline in skill/agent content, hook commands, and MCP/LSP server configs. Both are also exported as environment variables to subprocesses.

### User Configuration (userConfig)

```json
{
  "userConfig": {
    "api_endpoint": { "description": "Your API endpoint", "sensitive": false },
    "api_token": { "description": "API token", "sensitive": true }
  }
}
```

- Available as `${user_config.KEY}` in MCP/LSP configs, hook commands, and (non-sensitive only) skill/agent content
- Exported as `CLAUDE_PLUGIN_OPTION_<KEY>` environment variables
- Sensitive values stored in system keychain (~2 KB limit)

### Installation Scopes

| Scope | Settings File | Use Case |
|:------|:-------------|:---------|
| `user` (default) | `~/.claude/settings.json` | Personal, all projects |
| `project` | `.claude/settings.json` | Team-shared via VCS |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings file | Admin-controlled (read-only) |

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude plugin install <name> [-s scope]` | Install from marketplace |
| `claude plugin uninstall <name> [-s scope] [--keep-data]` | Remove plugin (aliases: `remove`, `rm`) |
| `claude plugin enable <name> [-s scope]` | Enable a disabled plugin |
| `claude plugin disable <name> [-s scope]` | Disable without uninstalling |
| `claude plugin update <name> [-s scope]` | Update to latest version |
| `claude plugin validate .` | Validate plugin/marketplace JSON |
| `claude --plugin-dir ./path` | Load plugin locally for testing |
| `claude --debug` | Show plugin loading details |

### In-Session Commands

| Command | Description |
|:--------|:------------|
| `/plugin` | Open plugin manager UI (Discover / Installed / Marketplaces / Errors tabs) |
| `/plugin install <name>@<marketplace>` | Install a plugin |
| `/plugin marketplace add <source>` | Add a marketplace |
| `/plugin marketplace list` | List configured marketplaces |
| `/plugin marketplace update <name>` | Refresh marketplace listings |
| `/plugin marketplace remove <name>` | Remove a marketplace |
| `/plugin validate .` | Validate plugin/marketplace |
| `/reload-plugins` | Reload all plugins without restarting |

### Marketplace Sources

| Source | Format | Add Command |
|:-------|:-------|:------------|
| GitHub repo | `owner/repo` | `/plugin marketplace add owner/repo` |
| Git URL | Full HTTPS or SSH URL | `/plugin marketplace add https://gitlab.com/org/repo.git` |
| Git ref | Append `#ref` | `/plugin marketplace add https://gitlab.com/org/repo.git#v1.0.0` |
| Local path | Directory or JSON file | `/plugin marketplace add ./my-marketplace` |
| Remote URL | Direct URL to marketplace.json | `/plugin marketplace add https://example.com/marketplace.json` |

### Marketplace Schema (marketplace.json)

```json
{
  "name": "marketplace-name",
  "owner": { "name": "Team Name", "email": "team@example.com" },
  "metadata": { "description": "...", "version": "...", "pluginRoot": "./plugins" },
  "plugins": [
    {
      "name": "plugin-name",
      "source": "./plugins/plugin-name",
      "description": "...",
      "version": "1.0.0"
    }
  ]
}
```

File location: `.claude-plugin/marketplace.json` in repository root.

### Plugin Source Types (in marketplace.json)

| Source | Format | Key Fields |
|:-------|:-------|:-----------|
| Relative path | `"source": "./path"` | Must start with `./` |
| GitHub | `{ "source": "github", "repo": "owner/repo" }` | Optional `ref`, `sha` |
| Git URL | `{ "source": "url", "url": "https://..." }` | Optional `ref`, `sha` |
| Git subdirectory | `{ "source": "git-subdir", "url": "...", "path": "..." }` | Sparse clone; optional `ref`, `sha` |
| npm | `{ "source": "npm", "package": "@scope/pkg" }` | Optional `version`, `registry` |

### Strict Mode (marketplace plugin entries)

| Value | Behavior |
|:------|:---------|
| `true` (default) | `plugin.json` is authority; marketplace entry supplements and merges |
| `false` | Marketplace entry is entire definition; `plugin.json` components cause conflict |

### LSP Server Configuration (.lsp.json)

**Required fields:**

| Field | Description |
|:------|:------------|
| `command` | LSP binary to execute (must be in PATH) |
| `extensionToLanguage` | Maps file extensions to language identifiers |

**Optional fields:** `args`, `transport` (`stdio` or `socket`), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`

### Official LSP Plugins

| Plugin | Language | Binary Required |
|:-------|:---------|:----------------|
| `pyright-lsp` | Python | `pyright-langserver` |
| `typescript-lsp` | TypeScript | `typescript-language-server` |
| `rust-analyzer-lsp` | Rust | `rust-analyzer` |
| `gopls-lsp` | Go | `gopls` |
| `clangd-lsp` | C/C++ | `clangd` |
| `jdtls-lsp` | Java | `jdtls` |
| `kotlin-lsp` | Kotlin | `kotlin-language-server` |
| `php-lsp` | PHP | `intelephense` |
| `swift-lsp` | Swift | `sourcekit-lsp` |
| `lua-lsp` | Lua | `lua-language-server` |
| `csharp-lsp` | C# | `csharp-ls` |

### Hook Lifecycle Events (Plugin Hooks)

| Event | When |
|:------|:-----|
| `SessionStart` | Session begins or resumes |
| `UserPromptSubmit` | Prompt submitted, before processing |
| `PreToolUse` | Before tool call; can block |
| `PermissionRequest` | Permission dialog appears |
| `PermissionDenied` | Tool call denied by classifier |
| `PostToolUse` | After tool call succeeds |
| `PostToolUseFailure` | After tool call fails |
| `Notification` | Claude Code sends notification |
| `SubagentStart` / `SubagentStop` | Subagent spawned / finished |
| `TaskCreated` / `TaskCompleted` | Task lifecycle |
| `Stop` | Claude finishes responding |
| `StopFailure` | Turn ends due to API error |
| `TeammateIdle` | Agent team teammate about to go idle |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded |
| `ConfigChange` | Configuration file changes |
| `CwdChanged` | Working directory changes |
| `FileChanged` | Watched file changes (matcher specifies filenames) |
| `WorktreeCreate` / `WorktreeRemove` | Worktree lifecycle |
| `PreCompact` / `PostCompact` | Before/after context compaction |
| `Elicitation` / `ElicitationResult` | MCP elicitation lifecycle |
| `SessionEnd` | Session terminates |

**Hook types:** `command`, `http`, `prompt`, `agent`

### Team Configuration

**Auto-prompt marketplace installation** (in `.claude/settings.json`):

```json
{
  "extraKnownMarketplaces": {
    "team-tools": {
      "source": { "source": "github", "repo": "org/claude-plugins" }
    }
  },
  "enabledPlugins": {
    "formatter@team-tools": true
  }
}
```

### Managed Marketplace Restrictions (strictKnownMarketplaces)

| Value | Behavior |
|:------|:---------|
| Undefined | No restrictions |
| `[]` | Complete lockdown -- no marketplaces |
| List of sources | Allowlist only |

Source types: `{ "source": "github", "repo": "..." }`, `{ "source": "url", "url": "..." }`, `{ "source": "hostPattern", "hostPattern": "^regex$" }`, `{ "source": "pathPattern", "pathPattern": "^/opt/" }`

### Auto-Update Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `DISABLE_AUTOUPDATER` | Disable all auto-updates (Claude Code + plugins) |
| `FORCE_AUTOUPDATE_PLUGINS` | Keep plugin auto-updates when DISABLE_AUTOUPDATER is set |
| `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` | Git operation timeout in ms (default: 120000) |
| `CLAUDE_CODE_PLUGIN_SEED_DIR` | Pre-populated plugins directory for containers |

### Private Repository Tokens (for auto-updates)

| Provider | Environment Variable |
|:---------|:---------------------|
| GitHub | `GITHUB_TOKEN` or `GH_TOKEN` |
| GitLab | `GITLAB_TOKEN` or `GL_TOKEN` |
| Bitbucket | `BITBUCKET_TOKEN` |

### Plugin vs Standalone Comparison

| Aspect | Standalone (`.claude/`) | Plugin |
|:-------|:------------------------|:-------|
| Skill names | `/hello` | `/plugin-name:hello` |
| Sharing | Manual copy | Marketplace install |
| Scope | Single project | Reusable across projects |
| Best for | Personal workflows, experiments | Team sharing, distribution |

### Common Debugging Checklist

1. Run `claude --debug` to see plugin loading messages
2. Run `claude plugin validate .` or `/plugin validate .` to check manifest and components
3. Ensure component directories are at plugin root, not inside `.claude-plugin/`
4. Verify hook scripts are executable (`chmod +x`)
5. Use `${CLAUDE_PLUGIN_ROOT}` for all plugin file paths
6. Check `/plugin` Errors tab for loading errors
7. Run `/reload-plugins` after changes

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) -- Plugin creation guide covering quickstart, structure, skills, agents, hooks, MCP servers, LSP servers, testing, debugging, sharing, and migration from standalone configuration
- [Plugins reference](references/claude-code-plugins-reference.md) -- Complete technical reference including manifest schema, component specifications, CLI commands, environment variables, caching, installation scopes, debugging tools, and version management
- [Discover and install plugins](references/claude-code-discover-plugins.md) -- Guide to finding and installing plugins from marketplaces, managing installed plugins, adding/removing marketplaces, auto-updates, team configuration, and troubleshooting
- [Plugin marketplaces](references/claude-code-plugin-marketplaces.md) -- Creating and distributing marketplaces, marketplace.json schema, plugin sources (relative/github/git/npm), strict mode, hosting, private repos, managed restrictions, version resolution, release channels, and validation

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Plugin marketplaces: https://code.claude.com/docs/en/plugin-marketplaces.md
