---
name: plugins-doc
description: Complete documentation for Claude Code plugins -- creating, installing, distributing, and managing plugins and marketplaces. Covers plugin manifest schema (plugin.json with name/version/description/author/homepage/repository/license/keywords, component paths for commands/agents/skills/hooks/mcpServers/lspServers/outputStyles, userConfig for prompted values with sensitive keychain storage, channels for message injection), plugin directory structure (commands/ agents/ skills/ hooks/ output-styles/ at root, NOT inside .claude-plugin/, .mcp.json .lsp.json settings.json at root), plugin components (skills with SKILL.md, agents with frontmatter, hooks via hooks/hooks.json or inline in plugin.json with all lifecycle events, MCP servers via .mcp.json or inline, LSP servers via .lsp.json or inline with required command/extensionToLanguage and optional args/transport/env/initializationOptions/settings/restartOnCrash/maxRestarts), environment variables (${CLAUDE_PLUGIN_ROOT} for bundled files, ${CLAUDE_PLUGIN_DATA} for persistent state surviving updates at ~/.claude/plugins/data/{id}/), plugin installation scopes (user in ~/.claude/settings.json default, project in .claude/settings.json for team, local in .claude/settings.local.json gitignored, managed read-only), plugin caching (marketplace plugins copied to ~/.claude/plugins/cache, no path traversal outside root, symlinks honored), creating plugins (quickstart with plugin.json + skills/ + SKILL.md, $ARGUMENTS for dynamic input, --plugin-dir for local testing, /reload-plugins for live updates, claude --debug for troubleshooting), converting standalone .claude/ configs to plugins (copy commands/agents/skills, migrate hooks from settings.json to hooks/hooks.json), CLI commands (claude plugin install/uninstall/enable/disable/update with --scope and --keep-data flags), discovering plugins (/plugin UI with Discover/Installed/Marketplaces/Errors tabs, /plugin install plugin@marketplace, /plugin marketplace add/list/update/remove, official marketplace claude-plugins-official auto-available), marketplace sources (owner/repo for GitHub, full URL for GitLab/Bitbucket/self-hosted, local paths, remote URLs, #ref for branch/tag), official marketplace categories (code intelligence LSP plugins for C/C++/C#/Go/Java/Kotlin/Lua/PHP/Python/Rust/Swift/TypeScript, external integrations github/gitlab/atlassian/asana/linear/notion/figma/vercel/firebase/supabase/slack/sentry, development workflows, output styles), auto-updates (per-marketplace toggle, DISABLE_AUTOUPDATER, FORCE_AUTOUPDATE_PLUGINS), team marketplace config (extraKnownMarketplaces in .claude/settings.json, enabledPlugins), creating marketplaces (marketplace.json schema with name/owner/plugins array, metadata.pluginRoot, plugin entries with name/source/description/version/author, plugin sources: relative path/github/url/git-subdir/npm, strict mode true default vs false for marketplace authority), hosting marketplaces (GitHub recommended, GitLab/Bitbucket, private repos with GITHUB_TOKEN/GITLAB_TOKEN/BITBUCKET_TOKEN for auto-updates), managed marketplace restrictions (strictKnownMarketplaces in managed settings with exact matching/hostPattern/pathPattern), pre-populating plugins for containers (CLAUDE_CODE_PLUGIN_SEED_DIR), version management (semver MAJOR.MINOR.PATCH, version in plugin.json or marketplace.json, plugin.json wins), release channels (stable/latest via different marketplace refs), validation (claude plugin validate, /plugin validate), debugging (claude --debug, common issues table, hook/MCP/LSP troubleshooting), settings.json with agent key for default agent activation, CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS for git timeout. Load when discussing plugins, plugin creation, plugin installation, plugin marketplaces, plugin manifest, plugin.json, marketplace.json, /plugin command, plugin install, plugin uninstall, plugin scopes, plugin distribution, LSP plugins, code intelligence plugins, plugin hooks, plugin MCP servers, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, --plugin-dir, /reload-plugins, extraKnownMarketplaces, enabledPlugins, strictKnownMarketplaces, plugin-dev, plugin validation, plugin caching, plugin sources, userConfig, plugin channels, plugin settings.json, plugin seed directory, or any plugin-related topic for Claude Code.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code's plugin system -- creating, installing, distributing, and managing plugins and plugin marketplaces.

## Quick Reference

Plugins extend Claude Code with skills, agents, hooks, MCP servers, and LSP servers. They are self-contained directories that can be shared across projects and teams via marketplaces.

### When to Use Plugins vs Standalone

| Approach | Skill names | Best for |
|:---------|:------------|:---------|
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugins** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with team/community, reusable across projects, versioned |

### Plugin Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json           # Manifest (only file in .claude-plugin/)
├── commands/                  # Skill Markdown files (legacy; use skills/)
├── agents/                    # Subagent Markdown files
├── skills/                    # Skills with <name>/SKILL.md structure
├── output-styles/             # Output style definitions
├── hooks/
│   └── hooks.json             # Hook configuration
├── settings.json              # Default settings (only "agent" key supported)
├── .mcp.json                  # MCP server definitions
├── .lsp.json                  # LSP server configurations
└── scripts/                   # Hook and utility scripts
```

All component directories must be at the plugin root, NOT inside `.claude-plugin/`.

### Plugin Manifest Schema (plugin.json)

**Required:** `name` (kebab-case, no spaces) -- used as skill namespace prefix.

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique identifier, skill namespace prefix |
| `version` | string | Semver (MAJOR.MINOR.PATCH) |
| `description` | string | Brief plugin purpose |
| `author` | object | `{name, email?, url?}` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier (MIT, Apache-2.0) |
| `keywords` | array | Discovery tags |

**Component path fields** (replace default directories when specified):

| Field | Type | Default location |
|:------|:-----|:-----------------|
| `commands` | string/array | `commands/` |
| `agents` | string/array | `agents/` |
| `skills` | string/array | `skills/` |
| `hooks` | string/array/object | `hooks/hooks.json` |
| `mcpServers` | string/array/object | `.mcp.json` |
| `lspServers` | string/array/object | `.lsp.json` |
| `outputStyles` | string/array | `output-styles/` |
| `userConfig` | object | User-prompted values at enable time |
| `channels` | array | Channel declarations for message injection |

All custom paths must be relative and start with `./`.

### User Configuration (userConfig)

```json
{
  "userConfig": {
    "api_endpoint": { "description": "API endpoint", "sensitive": false },
    "api_token": { "description": "API token", "sensitive": true }
  }
}
```

Values available as `${user_config.KEY}` in MCP/LSP configs, hook commands, and (non-sensitive only) skill/agent content. Also exported as `CLAUDE_PLUGIN_OPTION_<KEY>` environment variables. Sensitive values stored in system keychain (~2 KB total limit).

### Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin install directory (changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for state surviving updates (`~/.claude/plugins/data/{id}/`) |

Both are substituted inline in skill/agent content, hook commands, and MCP/LSP configs. Also exported as env vars to subprocesses.

### Plugin Components

**Skills**: Directories under `skills/` with `SKILL.md` files. Auto-discovered and invokable as `/plugin-name:skill-name`.

**Agents**: Markdown files in `agents/` with frontmatter (`name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation`). Only `isolation: "worktree"` is valid. `hooks`, `mcpServers`, `permissionMode` not supported for plugin agents.

**Hooks**: Configure in `hooks/hooks.json` or inline in `plugin.json`. Four hook types: `command`, `http`, `prompt`, `agent`.

Supported lifecycle events: `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PermissionRequest`, `PostToolUse`, `PostToolUseFailure`, `Notification`, `SubagentStart`, `SubagentStop`, `Stop`, `StopFailure`, `TeammateIdle`, `TaskCompleted`, `InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `FileChanged`, `WorktreeCreate`, `WorktreeRemove`, `PreCompact`, `PostCompact`, `Elicitation`, `ElicitationResult`, `SessionEnd`.

**MCP Servers**: Configure in `.mcp.json` or inline in `plugin.json`. Start automatically when plugin is enabled. Use `${CLAUDE_PLUGIN_ROOT}` for bundled files.

**LSP Servers**: Configure in `.lsp.json` or inline in `plugin.json`.

| LSP Field | Required | Description |
|:----------|:---------|:------------|
| `command` | Yes | LSP binary to execute (must be in PATH) |
| `extensionToLanguage` | Yes | Maps file extensions to language IDs |
| `args` | No | Command-line arguments |
| `transport` | No | `stdio` (default) or `socket` |
| `env` | No | Environment variables |
| `initializationOptions` | No | Server init options |
| `settings` | No | Workspace configuration |
| `restartOnCrash` | No | Auto-restart on crash |
| `maxRestarts` | No | Max restart attempts |

**Settings**: `settings.json` at plugin root. Only `agent` key supported -- activates a plugin agent as the main thread.

### Installation Scopes

| Scope | Settings file | Use case |
|:------|:-------------|:---------|
| `user` (default) | `~/.claude/settings.json` | Personal, all projects |
| `project` | `.claude/settings.json` | Team-shared via git |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Read-only, admin-controlled |

### CLI Commands

| Command | Purpose |
|:--------|:--------|
| `claude plugin install <plugin> [--scope]` | Install from marketplace |
| `claude plugin uninstall <plugin> [--scope] [--keep-data]` | Remove plugin |
| `claude plugin enable <plugin> [--scope]` | Enable disabled plugin |
| `claude plugin disable <plugin> [--scope]` | Disable without uninstalling |
| `claude plugin update <plugin> [--scope]` | Update to latest version |
| `claude plugin validate .` | Validate plugin/marketplace |
| `claude --plugin-dir ./path` | Load plugin for local testing |
| `claude --debug` | See plugin loading details |

**In-session commands**: `/plugin` (interactive UI), `/plugin install`, `/plugin marketplace add/list/update/remove`, `/reload-plugins`.

### Discovering and Installing Plugins

**Official marketplace** (`claude-plugins-official`): auto-available, browse at [claude.com/plugins](https://claude.com/plugins).

**Official marketplace categories:**

| Category | Examples |
|:---------|:---------|
| Code intelligence (LSP) | `pyright-lsp`, `typescript-lsp`, `rust-analyzer-lsp`, `gopls-lsp`, `clangd-lsp`, `csharp-lsp`, `jdtls-lsp`, `kotlin-lsp`, `lua-lsp`, `php-lsp`, `swift-lsp` |
| External integrations | `github`, `gitlab`, `atlassian`, `asana`, `linear`, `notion`, `figma`, `vercel`, `firebase`, `supabase`, `slack`, `sentry` |
| Dev workflows | `commit-commands`, `pr-review-toolkit`, `agent-sdk-dev`, `plugin-dev` |
| Output styles | `explanatory-output-style`, `learning-output-style` |

**Adding marketplaces:**

```
/plugin marketplace add owner/repo                    # GitHub
/plugin marketplace add https://gitlab.com/org/repo.git  # Git URL
/plugin marketplace add https://gitlab.com/org/repo.git#v1.0  # Pinned ref
/plugin marketplace add ./local-dir                    # Local path
/plugin marketplace add https://example.com/marketplace.json  # Remote URL
```

### Marketplace Schema (marketplace.json)

Located at `.claude-plugin/marketplace.json`.

**Required fields:** `name` (kebab-case), `owner` (`{name, email?}`), `plugins` (array).

**Optional:** `metadata.description`, `metadata.version`, `metadata.pluginRoot` (base dir for relative source paths).

**Plugin entry required fields:** `name`, `source`.

**Plugin source types:**

| Source | Format | Key fields |
|:-------|:-------|:-----------|
| Relative path | `"./plugins/my-plugin"` | Must start with `./` |
| GitHub | `{source: "github", repo: "owner/repo"}` | `ref?`, `sha?` |
| Git URL | `{source: "url", url: "https://..."}` | `ref?`, `sha?` |
| Git subdirectory | `{source: "git-subdir", url, path}` | Sparse clone for monorepos |
| npm | `{source: "npm", package: "@org/pkg"}` | `version?`, `registry?` |

**Strict mode** (`strict` field, default `true`): when true, `plugin.json` is authority and marketplace can supplement. When false, marketplace entry is the entire definition.

### Auto-Updates

- Official marketplaces: auto-update enabled by default
- Third-party: disabled by default, toggle via `/plugin` > Marketplaces
- `DISABLE_AUTOUPDATER`: disables all auto-updates
- `FORCE_AUTOUPDATE_PLUGINS=true`: keep plugin auto-updates when DISABLE_AUTOUPDATER is set

### Team and Managed Configuration

**Team marketplaces** (in `.claude/settings.json`):
```json
{
  "extraKnownMarketplaces": {
    "team-tools": { "source": { "source": "github", "repo": "org/plugins" } }
  },
  "enabledPlugins": { "formatter@team-tools": true }
}
```

**Managed restrictions** (`strictKnownMarketplaces` in managed settings):

| Value | Behavior |
|:------|:---------|
| Undefined | No restrictions |
| `[]` | Complete lockdown |
| List of sources | Only matching marketplaces allowed |

Supports `source: "hostPattern"` with `hostPattern` regex and `source: "pathPattern"` with `pathPattern` regex.

### Private Repository Auth for Auto-Updates

| Provider | Environment variable |
|:---------|:--------------------|
| GitHub | `GITHUB_TOKEN` or `GH_TOKEN` |
| GitLab | `GITLAB_TOKEN` or `GL_TOKEN` |
| Bitbucket | `BITBUCKET_TOKEN` |

### Container Pre-Population

Set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a directory mirroring `~/.claude/plugins` structure. Read-only, auto-updates disabled for seed marketplaces. Separate multiple paths with `:` (Unix) or `;` (Windows).

### Plugin Caching

Marketplace plugins are copied to `~/.claude/plugins/cache`. No path traversal outside plugin root (use symlinks for external files). `${CLAUDE_PLUGIN_DATA}` deleted on uninstall from last scope (use `--keep-data` to preserve).

### Common Debugging Issues

| Issue | Solution |
|:------|:---------|
| Plugin not loading | Run `claude plugin validate` or `/plugin validate` |
| Commands not appearing | Ensure `commands/` at root, not inside `.claude-plugin/` |
| Hooks not firing | `chmod +x script.sh`, verify event name is case-sensitive |
| MCP server fails | Use `${CLAUDE_PLUGIN_ROOT}` for all plugin paths |
| LSP binary not found | Install the language server binary (check `/plugin` Errors tab) |
| Git timeout | Set `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` (ms, default 120000) |
| Plugin skills not appearing | Clear cache: `rm -rf ~/.claude/plugins/cache`, reinstall |

### Submitting to Official Marketplace

- Claude.ai: [claude.ai/settings/plugins/submit](https://claude.ai/settings/plugins/submit)
- Console: [platform.claude.com/plugins/submit](https://platform.claude.com/plugins/submit)

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) -- Plugin creation guide covering when to use plugins vs standalone configuration, quickstart walkthrough (manifest, skills, $ARGUMENTS, --plugin-dir testing), plugin structure overview (commands/ agents/ skills/ hooks/ .mcp.json .lsp.json settings.json directories), developing complex plugins (adding skills with SKILL.md, LSP servers with .lsp.json, default settings with agent key, organizing complex plugins, testing with --plugin-dir and /reload-plugins, debugging), sharing and submitting plugins, converting standalone .claude/ configurations to plugins (migration steps and what changes)

- [Plugins reference](references/claude-code-plugins-reference.md) -- Complete technical reference covering plugin components (skills, agents with supported frontmatter fields, hooks with all lifecycle events and hook types, MCP servers with ${CLAUDE_PLUGIN_ROOT}, LSP servers with full config schema), installation scopes (user/project/local/managed), plugin manifest schema (required name field, metadata fields, component path fields with replacement behavior, userConfig with sensitive keychain storage, channels with per-channel userConfig), environment variables (${CLAUDE_PLUGIN_ROOT} and ${CLAUDE_PLUGIN_DATA} with persistent data directory patterns), plugin caching and file resolution (path traversal limitations, symlink workaround), plugin directory structure (standard layout, file locations reference), CLI commands (install/uninstall/enable/disable/update with all options), debugging and development tools (common issues, hook/MCP/LSP troubleshooting, directory structure mistakes), version management (semver format, best practices)

- [Discover and install plugins](references/claude-code-discover-plugins.md) -- Plugin discovery and installation guide covering how marketplaces work (add then install), official Anthropic marketplace (claude-plugins-official, auto-available, code intelligence LSP plugins table, external integrations, dev workflows, output styles), demo marketplace (anthropics/claude-code), adding marketplaces (GitHub owner/repo, Git URLs with #ref, local paths, remote URLs), installing plugins (/plugin install with scopes, interactive UI), managing installed plugins (enable/disable/uninstall, --scope flag, /reload-plugins), managing marketplaces (interactive UI and CLI commands, auto-updates with DISABLE_AUTOUPDATER and FORCE_AUTOUPDATE_PLUGINS), team marketplace configuration (extraKnownMarketplaces in .claude/settings.json), security considerations, troubleshooting (/plugin command not recognized, common issues, code intelligence issues)

- [Create and distribute a marketplace](references/claude-code-plugin-marketplaces.md) -- Marketplace creation and distribution guide covering walkthrough (local marketplace with quality-review skill), marketplace.json schema (required name/owner/plugins, optional metadata with pluginRoot, reserved names), plugin entries (required name/source, optional metadata and component fields, strict mode), plugin sources (relative paths, GitHub repos, Git URLs, git-subdir for sparse monorepo cloning, npm packages with registry support), hosting (GitHub recommended, other git services, private repos with token auth for auto-updates), team configuration (extraKnownMarketplaces, enabledPlugins), container pre-population (CLAUDE_CODE_PLUGIN_SEED_DIR with layered paths, read-only seed behavior), managed marketplace restrictions (strictKnownMarketplaces with exact/hostPattern/pathPattern matching), version resolution and release channels (stable/latest via different refs), validation and testing (claude plugin validate), troubleshooting (marketplace loading, validation errors table, installation failures, private auth, git timeouts with CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS, relative path failures in URL-based marketplaces, file-not-found after installation)

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
