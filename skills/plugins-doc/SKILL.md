---
name: plugins-doc
description: Complete documentation for Claude Code plugins -- creating, distributing, installing, and managing plugins. Covers plugin manifest schema (plugin.json fields: name, version, description, author, homepage, repository, license, keywords, commands, agents, skills, hooks, mcpServers, lspServers, outputStyles, userConfig, channels, settings.json agent key), plugin directory structure (.claude-plugin/plugin.json, commands/, agents/, skills/, hooks/, output-styles/, .mcp.json, .lsp.json, settings.json), quickstart (create manifest, add skill, test with --plugin-dir, $ARGUMENTS placeholder, /reload-plugins), plugin components (skills with SKILL.md, agents with frontmatter, hooks with hooks.json or inline, MCP servers with .mcp.json or inline, LSP servers with .lsp.json or inline), hook lifecycle events (SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, TaskCreated, TaskCompleted, Stop, StopFailure, TeammateIdle, InstructionsLoaded, ConfigChange, CwdChanged, FileChanged, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd), hook types (command, http, prompt, agent), environment variables (${CLAUDE_PLUGIN_ROOT}, ${CLAUDE_PLUGIN_DATA}, persistent data directory ~/.claude/plugins/data/{id}/), plugin installation scopes (user, project, local, managed), CLI commands (plugin install/uninstall/enable/disable/update with --scope flag, --keep-data), plugin caching (~/.claude/plugins/cache, path traversal limitations, symlinks), version management (semver MAJOR.MINOR.PATCH, version in plugin.json or marketplace.json, plugin.json takes priority), converting standalone .claude/ configs to plugins (migration steps, hooks from settings.json to hooks/hooks.json), debugging (claude --debug, claude plugin validate, /plugin validate, common issues table), LSP server configuration (command, extensionToLanguage required; args, transport, env, initializationOptions, settings, workspaceFolder, startupTimeout, shutdownTimeout, restartOnCrash, maxRestarts optional), available LSP plugins (pyright-lsp, typescript-lsp, rust-lsp, clangd-lsp, gopls-lsp, csharp-lsp, jdtls-lsp, kotlin-lsp, lua-lsp, php-lsp, swift-lsp), code intelligence (automatic diagnostics, code navigation), plugin marketplaces (marketplace.json schema: name, owner, plugins array, metadata.pluginRoot), marketplace plugin entries (name, source, description, version, author, strict mode), plugin sources (relative path, github, url, git-subdir, npm with package/version/registry), hosting marketplaces (GitHub, GitLab, private repos with GITHUB_TOKEN/GITLAB_TOKEN/BITBUCKET_TOKEN), marketplace management (/plugin marketplace add/list/update/remove, auto-updates, DISABLE_AUTOUPDATER, FORCE_AUTOUPDATE_PLUGINS), team marketplaces (extraKnownMarketplaces, enabledPlugins in .claude/settings.json), managed marketplace restrictions (strictKnownMarketplaces with hostPattern/pathPattern), release channels (stable/latest refs with different marketplace entries), pre-populating plugins for containers (CLAUDE_CODE_PLUGIN_SEED_DIR, seed directory structure), discovering plugins (/plugin interface with Discover/Installed/Marketplaces/Errors tabs, official Anthropic marketplace claude-plugins-official, demo marketplace anthropics/claude-code), official marketplace categories (code intelligence LSP plugins, external integrations MCP plugins, development workflow plugins, output style plugins), submitting to official marketplace (claude.ai/settings/plugins/submit, platform.claude.com/plugins/submit), validation and testing (claude plugin validate, /plugin validate, common validation errors), troubleshooting (marketplace not loading, installation failures, private repo auth, git timeouts CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS, relative paths in URL-based marketplaces, files not found after installation, plugin skills not appearing cache clear). Load when discussing Claude Code plugins, plugin creation, plugin manifest, plugin.json, marketplace.json, plugin distribution, plugin marketplaces, plugin installation, plugin scopes, plugin CLI commands, LSP plugins, code intelligence plugins, MCP server plugins, hook plugins, plugin debugging, plugin validation, plugin caching, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, extraKnownMarketplaces, strictKnownMarketplaces, enabledPlugins, plugin auto-updates, plugin seed directory, --plugin-dir, /reload-plugins, plugin namespace, strict mode, plugin sources, or any plugins-related topic for Claude Code.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins -- creating, distributing, installing, and managing plugins and plugin marketplaces.

## Quick Reference

### Plugin Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest (only file in this dir)
├── commands/                 # Legacy skills as Markdown files
├── agents/                   # Subagent definitions
├── skills/                   # Agent Skills (name/SKILL.md)
├── output-styles/            # Output style definitions
├── hooks/
│   └── hooks.json            # Hook configuration
├── settings.json             # Default settings (currently only "agent" key)
├── .mcp.json                 # MCP server definitions
├── .lsp.json                 # LSP server configurations
└── scripts/                  # Hook and utility scripts
```

Components must be at the plugin root, NOT inside `.claude-plugin/`.

### Plugin Manifest (plugin.json)

| Field | Type | Required | Description |
|:------|:-----|:---------|:------------|
| `name` | string | Yes | Unique identifier (kebab-case), used as namespace prefix |
| `version` | string | No | Semver (`MAJOR.MINOR.PATCH`) |
| `description` | string | No | Brief explanation of plugin purpose |
| `author` | object | No | `{name, email, url}` |
| `homepage` | string | No | Documentation URL |
| `repository` | string | No | Source code URL |
| `license` | string | No | SPDX identifier (e.g., `MIT`) |
| `keywords` | array | No | Discovery tags |

**Component path fields** (replace default directories when set):

| Field | Type | Default Location |
|:------|:-----|:-----------------|
| `commands` | string/array | `commands/` |
| `agents` | string/array | `agents/` |
| `skills` | string/array | `skills/` |
| `hooks` | string/array/object | `hooks/hooks.json` |
| `mcpServers` | string/array/object | `.mcp.json` |
| `lspServers` | string/array/object | `.lsp.json` |
| `outputStyles` | string/array | `output-styles/` |
| `userConfig` | object | -- |
| `channels` | array | -- |

### Environment Variables

| Variable | Purpose | Persistence |
|:---------|:--------|:------------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin install directory | Changes on update |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state (`~/.claude/plugins/data/{id}/`) | Survives updates |

Both are substituted inline in skill/agent content, hook commands, MCP/LSP configs, and exported as env vars to subprocesses.

### Plugin Installation Scopes

| Scope | Settings File | Use Case |
|:------|:-------------|:---------|
| `user` | `~/.claude/settings.json` | Personal, across all projects (default) |
| `project` | `.claude/settings.json` | Team, shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled (read-only, update only) |

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude plugin install <plugin> [-s scope]` | Install from marketplace |
| `claude plugin uninstall <plugin> [-s scope] [--keep-data]` | Remove (aliases: `remove`, `rm`) |
| `claude plugin enable <plugin> [-s scope]` | Enable a disabled plugin |
| `claude plugin disable <plugin> [-s scope]` | Disable without uninstalling |
| `claude plugin update <plugin> [-s scope]` | Update to latest version |
| `claude plugin validate .` | Validate plugin/marketplace JSON |

Plugin format: `plugin-name` or `plugin-name@marketplace-name`.

### In-Session Commands

| Command | Purpose |
|:--------|:--------|
| `/plugin` | Open plugin manager (Discover/Installed/Marketplaces/Errors tabs) |
| `/plugin install <name>@<marketplace>` | Install a plugin |
| `/plugin marketplace add <source>` | Add a marketplace |
| `/plugin marketplace list` | List configured marketplaces |
| `/plugin marketplace update <name>` | Refresh marketplace listings |
| `/plugin marketplace remove <name>` | Remove a marketplace |
| `/reload-plugins` | Reload all plugins without restarting |

### Hook Lifecycle Events (Plugin Hooks)

| Event | When It Fires |
|:------|:-------------|
| `SessionStart` | Session begins or resumes |
| `UserPromptSubmit` | Prompt submitted, before processing |
| `PreToolUse` | Before tool call executes (can block) |
| `PermissionRequest` | Permission dialog appears |
| `PostToolUse` | After tool call succeeds |
| `PostToolUseFailure` | After tool call fails |
| `Notification` | Claude Code sends a notification |
| `SubagentStart` | Subagent spawned |
| `SubagentStop` | Subagent finishes |
| `TaskCreated` | Task created via TaskCreate |
| `TaskCompleted` | Task marked completed |
| `Stop` | Claude finishes responding |
| `StopFailure` | Turn ends due to API error |
| `TeammateIdle` | Agent team teammate about to go idle |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded |
| `ConfigChange` | Configuration file changes |
| `CwdChanged` | Working directory changes |
| `FileChanged` | Watched file changes on disk |
| `WorktreeCreate` | Worktree being created |
| `WorktreeRemove` | Worktree being removed |
| `PreCompact` | Before context compaction |
| `PostCompact` | After context compaction |
| `Elicitation` | MCP server requests user input |
| `ElicitationResult` | User responds to MCP elicitation |
| `SessionEnd` | Session terminates |

**Hook types**: `command` (shell), `http` (POST), `prompt` (LLM eval), `agent` (agentic verifier).

### LSP Server Configuration

**Required fields**: `command` (binary to execute), `extensionToLanguage` (maps extensions to language IDs).

**Optional fields**: `args`, `transport` (`stdio`/`socket`), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`.

**Official LSP plugins**:

| Plugin | Language | Binary |
|:-------|:---------|:-------|
| `pyright-lsp` | Python | `pyright-langserver` |
| `typescript-lsp` | TypeScript | `typescript-language-server` |
| `rust-analyzer-lsp` | Rust | `rust-analyzer` |
| `clangd-lsp` | C/C++ | `clangd` |
| `gopls-lsp` | Go | `gopls` |
| `csharp-lsp` | C# | `csharp-ls` |
| `jdtls-lsp` | Java | `jdtls` |
| `kotlin-lsp` | Kotlin | `kotlin-language-server` |
| `lua-lsp` | Lua | `lua-language-server` |
| `php-lsp` | PHP | `intelephense` |
| `swift-lsp` | Swift | `sourcekit-lsp` |

### User Configuration (userConfig)

Declare values prompted at enable time. Available as `${user_config.KEY}` in MCP/LSP configs, hook commands, and (non-sensitive only) skill/agent content. Exported as `CLAUDE_PLUGIN_OPTION_<KEY>` env vars. Sensitive values stored in system keychain (~2 KB total limit).

### Channels

Declare message channels that inject content into conversations. Each channel binds to an MCP server the plugin provides. Per-channel `userConfig` prompts for tokens/IDs at enable time.

### Marketplace Schema (marketplace.json)

| Field | Type | Required | Description |
|:------|:-----|:---------|:------------|
| `name` | string | Yes | Marketplace identifier (kebab-case) |
| `owner` | object | Yes | `{name, email?}` |
| `plugins` | array | Yes | List of plugin entries |
| `metadata.description` | string | No | Brief marketplace description |
| `metadata.pluginRoot` | string | No | Base directory for relative plugin paths |

### Plugin Entry Fields (in marketplace.json)

| Field | Type | Required | Description |
|:------|:-----|:---------|:------------|
| `name` | string | Yes | Plugin identifier (kebab-case) |
| `source` | string/object | Yes | Where to fetch the plugin |
| `description` | string | No | Brief plugin description |
| `version` | string | No | Plugin version (plugin.json takes priority) |
| `strict` | boolean | No | `true` (default): plugin.json is authority; `false`: marketplace entry is entire definition |

### Plugin Sources

| Source | Format | Key Fields |
|:-------|:-------|:-----------|
| Relative path | `"./plugins/my-plugin"` | Must start with `./` |
| GitHub | `{source: "github", repo: "owner/repo"}` | `ref?`, `sha?` |
| Git URL | `{source: "url", url: "https://..."}` | `ref?`, `sha?` |
| Git subdirectory | `{source: "git-subdir", url, path}` | Sparse clone; `ref?`, `sha?` |
| npm | `{source: "npm", package: "@org/pkg"}` | `version?`, `registry?` |

### Marketplace Sources (for /plugin marketplace add)

| Source Type | Command |
|:------------|:--------|
| GitHub | `/plugin marketplace add owner/repo` |
| Git URL | `/plugin marketplace add https://gitlab.com/org/repo.git` |
| Git ref | `/plugin marketplace add https://...git#v1.0.0` |
| Local path | `/plugin marketplace add ./my-marketplace` |
| Remote URL | `/plugin marketplace add https://example.com/marketplace.json` |

### Team Marketplace Configuration

In `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "company-tools": {
      "source": { "source": "github", "repo": "org/plugins" }
    }
  },
  "enabledPlugins": {
    "formatter@company-tools": true
  }
}
```

### Managed Marketplace Restrictions (strictKnownMarketplaces)

| Value | Behavior |
|:------|:---------|
| Undefined | No restrictions |
| `[]` | Complete lockdown |
| List of sources | Allowlist only |

Source types: `github` (exact `repo` match), `url` (exact match), `hostPattern` (regex on host), `pathPattern` (regex on filesystem path).

### Auto-Updates

| Variable | Effect |
|:---------|:-------|
| `DISABLE_AUTOUPDATER` | Disables all auto-updates (Claude Code + plugins) |
| `FORCE_AUTOUPDATE_PLUGINS=1` | Re-enables plugin auto-updates when autoupdater disabled |

Official marketplaces auto-update by default; third-party/local do not.

### Pre-Populating Plugins for Containers

Set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a directory mirroring `~/.claude/plugins/` structure. Separate multiple paths with `:`. Seed is read-only; auto-updates disabled for seed marketplaces.

### Private Repository Authentication

| Provider | Environment Variables |
|:---------|:---------------------|
| GitHub | `GITHUB_TOKEN` or `GH_TOKEN` |
| GitLab | `GITLAB_TOKEN` or `GL_TOKEN` |
| Bitbucket | `BITBUCKET_TOKEN` |

Manual operations use git credential helpers. Background auto-updates require env tokens.

### Common Debugging Steps

1. Run `claude --debug` to see plugin loading details
2. Run `claude plugin validate .` or `/plugin validate` to check manifests
3. Check `/plugin` Errors tab for loading errors
4. Verify components are at plugin root, not inside `.claude-plugin/`
5. Ensure hook scripts are executable (`chmod +x`)
6. Use `${CLAUDE_PLUGIN_ROOT}` for all paths in hooks and MCP configs
7. Clear cache if needed: `rm -rf ~/.claude/plugins/cache`

### Git Timeout Configuration

Set `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` to increase the default 120-second timeout for git operations (value in milliseconds).

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) -- When to use plugins vs standalone config, quickstart (manifest, skills, testing with --plugin-dir, $ARGUMENTS), plugin structure overview (directories at root not in .claude-plugin/), adding skills/LSP servers/default settings to plugins, organizing complex plugins, testing locally (--plugin-dir, /reload-plugins, multiple plugins), debugging (structure, validation, debug tools), sharing plugins, submitting to official marketplace (claude.ai/settings/plugins/submit, platform.claude.com/plugins/submit), converting standalone .claude/ configs to plugins (migration steps, hooks from settings.json to hooks/hooks.json, what changes when migrating)

- [Plugins reference](references/claude-code-plugins-reference.md) -- Plugin components reference (skills in skills/, agents in agents/ with frontmatter fields, hooks in hooks/hooks.json with lifecycle events and hook types, MCP servers in .mcp.json, LSP servers in .lsp.json with required/optional fields and available plugins), installation scopes (user/project/local/managed), plugin manifest schema (all fields, required vs metadata vs component path fields, path behavior rules, userConfig with sensitive/non-sensitive storage, channels), environment variables (CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, persistent data directory pattern with SessionStart dependency install), plugin caching (path traversal limitations, symlinks), directory structure (standard layout, file locations reference), CLI commands reference (install/uninstall/enable/disable/update with options), debugging and development tools (--debug, common issues table, example error messages, hook/MCP/directory troubleshooting checklists), version management (semver, version bumping, caching implications)

- [Discover and install plugins](references/claude-code-discover-plugins.md) -- Official Anthropic marketplace (claude-plugins-official, browse at claude.com/plugins), code intelligence plugins (LSP plugins table with languages/binaries, automatic diagnostics, code navigation), external integration plugins (github, gitlab, atlassian, linear, slack, sentry, etc.), development workflow plugins, output style plugins, demo marketplace (anthropics/claude-code), adding marketplaces (GitHub owner/repo, git URLs with branch/tag, local paths, remote URLs), installing plugins (/plugin install with scope selection), managing installed plugins (disable/enable/uninstall, /reload-plugins), managing marketplaces (interactive UI, CLI commands list/update/remove), auto-updates (per-marketplace toggle, DISABLE_AUTOUPDATER, FORCE_AUTOUPDATE_PLUGINS), team marketplaces (extraKnownMarketplaces in .claude/settings.json), security warnings, troubleshooting (/plugin command not recognized, marketplace not loading, installation failures, code intelligence issues)

- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) -- Walkthrough creating a local marketplace (directory structure, skill, plugin manifest, marketplace.json, add and install), marketplace.json schema (required fields name/owner/plugins, reserved marketplace names, optional metadata, metadata.pluginRoot), plugin entries (required name/source, optional metadata/component fields), plugin sources (relative paths, github, url/git, git-subdir sparse clone, npm with package/version/registry), advanced plugin entries with inline hooks/mcpServers, strict mode (true merges, false is exclusive), hosting on GitHub/GitLab/private repos (credential helpers, GITHUB_TOKEN/GITLAB_TOKEN/BITBUCKET_TOKEN for auto-updates), team marketplace setup (extraKnownMarketplaces, enabledPlugins), pre-populating for containers (CLAUDE_CODE_PLUGIN_SEED_DIR, seed directory structure, read-only behavior, path resolution), managed marketplace restrictions (strictKnownMarketplaces with hostPattern/pathPattern, exact matching, common configurations), version resolution and release channels (stable/latest refs, managed settings assignment), validation and testing (claude plugin validate, /plugin validate), troubleshooting (marketplace not loading, validation errors table, installation failures, private repo auth, git timeouts CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS, relative paths in URL-based marketplaces, files not found after installation)

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
