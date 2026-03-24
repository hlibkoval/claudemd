---
name: plugins-doc
description: Complete documentation for Claude Code plugins -- creating, installing, distributing, and managing plugins. Covers plugin manifest schema (plugin.json required and optional fields, name, version, description, author, homepage, repository, license, keywords, component path fields for commands/agents/skills/hooks/mcpServers/lspServers/outputStyles), plugin directory structure (standard layout, .claude-plugin/ for manifest only, commands/ agents/ skills/ hooks/ .mcp.json .lsp.json settings.json at plugin root), plugin components (skills with SKILL.md, agents with frontmatter, hooks with hooks.json or inline, MCP servers with .mcp.json or inline, LSP servers with .lsp.json or inline), environment variables (${CLAUDE_PLUGIN_ROOT} for plugin install dir, ${CLAUDE_PLUGIN_DATA} for persistent data dir surviving updates), persistent data directory pattern (diff+copy manifest for dependency caching), plugin installation scopes (user/project/local/managed), CLI commands (plugin install/uninstall/enable/disable/update with --scope and --keep-data flags), testing locally (--plugin-dir flag, /reload-plugins, loading multiple plugins), debugging (claude --debug, /debug, claude plugin validate, /plugin validate, common issues table), version management (semver MAJOR.MINOR.PATCH, version in plugin.json or marketplace.json), standalone vs plugin comparison (when to use each), quickstart (create manifest, add skill, test with --plugin-dir, $ARGUMENTS for dynamic input), converting standalone to plugin (migration steps, what changes), plugin settings (settings.json with agent key to activate default agent), LSP server configuration (command, extensionToLanguage required; args, transport, env, initializationOptions, settings, workspaceFolder, startupTimeout, shutdownTimeout, restartOnCrash, maxRestarts optional), available LSP plugins (pyright-lsp, typescript-lsp, rust-lsp and 8 more), hook event types (SessionStart through SessionEnd, 21 events), hook types (command, http, prompt, agent), plugin caching and file resolution (marketplace plugins cached at ~/.claude/plugins/cache, path traversal limitations, symlinks for external deps), discover and install plugins (/plugin command with Discover/Installed/Marketplaces/Errors tabs), official Anthropic marketplace (claude-plugins-official, auto-available, code intelligence plugins, external integrations, development workflows, output styles), adding marketplaces (GitHub owner/repo, Git URLs, local paths, remote URLs, branch/tag with #ref), installing plugins (/plugin install name@marketplace, scope selection), managing plugins (/plugin disable/enable/uninstall, /reload-plugins), managing marketplaces (/plugin marketplace add/list/update/remove, auto-updates, DISABLE_AUTOUPDATER, FORCE_AUTOUPDATE_PLUGINS), team marketplace configuration (extraKnownMarketplaces in .claude/settings.json, enabledPlugins), plugin marketplaces (marketplace.json schema with name/owner/plugins, plugin entries with source/category/tags/strict, plugin sources: relative path/github/url/git-subdir/npm with ref/sha pinning), marketplace hosting (GitHub recommended, other git hosts, private repos with GITHUB_TOKEN/GITLAB_TOKEN/BITBUCKET_TOKEN, local testing), strict mode (true for plugin.json authority, false for marketplace authority), managed marketplace restrictions (strictKnownMarketplaces with exact match/hostPattern/pathPattern), version resolution and release channels (stable/latest refs, managed settings per group), pre-populating plugins for containers (CLAUDE_CODE_PLUGIN_SEED_DIR), validation and testing (claude plugin validate, /plugin validate), code intelligence plugins (clangd-lsp, csharp-lsp, gopls-lsp, jdtls-lsp, kotlin-lsp, lua-lsp, php-lsp, pyright-lsp, rust-analyzer-lsp, swift-lsp, typescript-lsp), troubleshooting (plugin not loading, commands not appearing, hooks not firing, MCP server fails, path errors, LSP executable not found, marketplace not loading, files not found after install, git timeout CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS). Load when discussing Claude Code plugins, plugin system, creating plugins, installing plugins, plugin manifest, plugin.json, marketplace, marketplace.json, plugin marketplaces, plugin distribution, plugin install, plugin uninstall, plugin enable, plugin disable, /plugin command, plugin scopes, plugin hooks, plugin MCP servers, plugin LSP servers, plugin agents, plugin skills, plugin commands, plugin settings, plugin caching, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, --plugin-dir, /reload-plugins, plugin validate, plugin debugging, plugin troubleshooting, extraKnownMarketplaces, enabledPlugins, strictKnownMarketplaces, plugin sources, plugin versioning, strict mode, code intelligence plugins, LSP plugins, official marketplace, plugin submission, or any plugin-related topic for Claude Code.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins -- creating, installing, distributing, and managing plugin extensions.

## Quick Reference

### Standalone vs Plugin

| Approach | Skill names | Best for |
|:---------|:------------|:---------|
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugin** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teams, community distribution, reusable across projects |

### Plugin Directory Structure

| Directory/File | Location | Purpose |
|:---------------|:---------|:--------|
| `.claude-plugin/` | Plugin root | Contains `plugin.json` manifest only |
| `commands/` | Plugin root | Skill Markdown files (legacy; use `skills/` for new) |
| `agents/` | Plugin root | Subagent Markdown files |
| `skills/` | Plugin root | Agent Skills with `<name>/SKILL.md` structure |
| `hooks/hooks.json` | Plugin root | Hook configuration |
| `.mcp.json` | Plugin root | MCP server definitions |
| `.lsp.json` | Plugin root | LSP server configurations |
| `settings.json` | Plugin root | Default settings (only `agent` key supported) |

**Important**: All component directories go at the plugin root, never inside `.claude-plugin/`. Only `plugin.json` goes inside `.claude-plugin/`.

### Plugin Manifest (plugin.json)

**Required**: `name` (kebab-case, used as namespace prefix for skills)

**Metadata fields**:

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique identifier, kebab-case |
| `version` | string | Semver (`MAJOR.MINOR.PATCH`) |
| `description` | string | Brief explanation |
| `author` | object | `{name, email?, url?}` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier (e.g., `MIT`) |
| `keywords` | array | Discovery tags |

**Component path fields**:

| Field | Type | Description |
|:------|:-----|:------------|
| `commands` | string or array | Additional command files/directories |
| `agents` | string or array | Additional agent files |
| `skills` | string or array | Additional skill directories |
| `hooks` | string, array, or object | Hook config paths or inline config |
| `mcpServers` | string, array, or object | MCP config paths or inline config |
| `lspServers` | string, array, or object | LSP server configs |
| `outputStyles` | string or array | Output style files/directories |

Custom paths supplement default directories -- they do not replace them. All paths must be relative to plugin root and start with `./`.

### Environment Variables

| Variable | Description |
|:---------|:------------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin install directory; changes on update |
| `${CLAUDE_PLUGIN_DATA}` | Persistent data directory surviving updates (`~/.claude/plugins/data/{id}/`) |

Both are substituted inline in skill content, agent content, hook commands, MCP/LSP configs, and exported as env vars to hook and server subprocesses.

### Plugin Installation Scopes

| Scope | Settings file | Use case |
|:------|:-------------|:---------|
| `user` | `~/.claude/settings.json` | Personal, all projects (default) |
| `project` | `.claude/settings.json` | Team, shared via git |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled (read-only, update only) |

### CLI Commands

| Command | Description | Key flags |
|:--------|:------------|:----------|
| `claude plugin install <plugin>` | Install from marketplace | `--scope user/project/local` |
| `claude plugin uninstall <plugin>` | Remove plugin | `--scope`, `--keep-data` |
| `claude plugin enable <plugin>` | Enable disabled plugin | `--scope` |
| `claude plugin disable <plugin>` | Disable without uninstalling | `--scope` |
| `claude plugin update <plugin>` | Update to latest version | `--scope user/project/local/managed` |
| `claude plugin validate` | Check plugin.json, frontmatter, hooks | |

Plugin argument format: `plugin-name` or `plugin-name@marketplace-name`.

### Interactive Commands

| Command | Purpose |
|:--------|:--------|
| `/plugin` | Open plugin manager (Discover/Installed/Marketplaces/Errors tabs) |
| `/plugin install name@marketplace` | Install a plugin |
| `/plugin disable name@marketplace` | Disable a plugin |
| `/plugin enable name@marketplace` | Enable a plugin |
| `/plugin uninstall name@marketplace` | Remove a plugin |
| `/plugin marketplace add <source>` | Add a marketplace |
| `/plugin marketplace list` | List configured marketplaces |
| `/plugin marketplace update <name>` | Refresh listings |
| `/plugin marketplace remove <name>` | Remove a marketplace |
| `/plugin validate .` | Validate plugin/marketplace |
| `/reload-plugins` | Reload all plugins without restarting |

### Adding Marketplaces

| Source type | Command |
|:------------|:--------|
| GitHub repo | `/plugin marketplace add owner/repo` |
| Git URL | `/plugin marketplace add https://gitlab.com/company/plugins.git` |
| Specific branch/tag | `/plugin marketplace add https://gitlab.com/company/plugins.git#v1.0.0` |
| Local path | `/plugin marketplace add ./my-marketplace` |
| Remote URL | `/plugin marketplace add https://example.com/marketplace.json` |

### Marketplace Schema (marketplace.json)

**Required fields**: `name` (kebab-case), `owner` (`{name, email?}`), `plugins` (array)

**Optional metadata**: `metadata.description`, `metadata.version`, `metadata.pluginRoot` (base dir for relative source paths)

### Plugin Entry Fields (in marketplace.json)

**Required**: `name`, `source`

**Marketplace-specific optional**: `category`, `tags`, `strict`

All fields from plugin.json manifest are also accepted (description, version, author, commands, agents, hooks, mcpServers, lspServers, etc.).

### Plugin Sources (in marketplace.json)

| Source | Format | Required fields |
|:-------|:-------|:----------------|
| Relative path | `"./plugins/my-plugin"` (string) | none (must start with `./`) |
| GitHub | object | `source: "github"`, `repo` |
| Git URL | object | `source: "url"`, `url` |
| Git subdirectory | object | `source: "git-subdir"`, `url`, `path` |
| npm | object | `source: "npm"`, `package` |

All object sources except npm support optional `ref` (branch/tag) and `sha` (40-char commit hash) for pinning. npm supports optional `version` and `registry`.

### Strict Mode

| Value | Behavior |
|:------|:---------|
| `true` (default) | `plugin.json` is authority; marketplace entry supplements with additional components |
| `false` | Marketplace entry is the entire definition; `plugin.json` must not declare components |

### LSP Server Configuration

**Required fields**: `command` (binary in PATH), `extensionToLanguage` (maps file extensions to language IDs)

**Optional fields**: `args`, `transport` (`stdio` default or `socket`), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`

### Official Code Intelligence Plugins

| Language | Plugin | Binary required |
|:---------|:-------|:----------------|
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

Plugin hooks respond to all standard lifecycle events: SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, Stop, StopFailure, TeammateIdle, TaskCompleted, InstructionsLoaded, ConfigChange, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd.

Hook types: `command` (shell), `http` (POST to URL), `prompt` (single-turn LLM), `agent` (multi-turn verifier with tools).

### Plugin Agent Frontmatter

Supported fields: `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation` (`"worktree"` only). Not supported for security: `hooks`, `mcpServers`, `permissionMode`.

### Auto-Update Configuration

| Variable | Effect |
|:---------|:-------|
| `DISABLE_AUTOUPDATER` | Disables all auto-updates (Claude Code + plugins) |
| `FORCE_AUTOUPDATE_PLUGINS=true` | Keep plugin auto-updates even when DISABLE_AUTOUPDATER is set |

### Private Repository Tokens

| Provider | Environment variables |
|:---------|:--------------------|
| GitHub | `GITHUB_TOKEN` or `GH_TOKEN` |
| GitLab | `GITLAB_TOKEN` or `GL_TOKEN` |
| Bitbucket | `BITBUCKET_TOKEN` |

### Managed Marketplace Restrictions (strictKnownMarketplaces)

| Value | Behavior |
|:------|:---------|
| Undefined | No restrictions |
| Empty array `[]` | Complete lockdown, no new marketplaces |
| List of sources | Only matching marketplaces allowed |

Source types: exact `github` (repo, ref?, path?), exact `url`, `hostPattern` (regex), `pathPattern` (regex).

### Container Pre-Population

Set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a directory mirroring `~/.claude/plugins/` structure (`known_marketplaces.json`, `marketplaces/<name>/...`, `cache/<marketplace>/<plugin>/<version>/...`). Separate multiple seed directories with `:` on Unix. Seed is read-only; auto-updates disabled for seed marketplaces.

### Testing Locally

```
claude --plugin-dir ./my-plugin          # Load plugin for testing
claude --plugin-dir ./p1 --plugin-dir ./p2  # Load multiple plugins
```

When a `--plugin-dir` plugin shares a name with an installed marketplace plugin, the local copy takes precedence (except managed force-enabled plugins). Use `/reload-plugins` inside a session to pick up changes without restarting.

### Debugging Checklist

| Issue | Cause | Solution |
|:------|:------|:---------|
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` or `/plugin validate` |
| Commands not appearing | Wrong directory structure | Ensure `commands/` at root, not in `.claude-plugin/` |
| Hooks not firing | Script not executable | `chmod +x script.sh`; verify event name is case-sensitive |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin paths |
| Path errors | Absolute paths used | All paths must be relative, start with `./` |
| LSP not found | Binary not installed | Install the language server binary |
| Files not found after install | Paths outside plugin dir | Plugins are cached; use symlinks for external deps |
| Git timeout | Slow network/large repo | Set `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` (milliseconds) |

### Plugin Submission

Submit to the official Anthropic marketplace via:
- Claude.ai: `claude.ai/settings/plugins/submit`
- Console: `platform.claude.com/plugins/submit`

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) -- creating plugins with skills, agents, hooks, MCP and LSP servers; plugin manifest quickstart; plugin structure overview; adding skills, LSP servers, default settings; organizing complex plugins; testing locally with --plugin-dir; debugging plugin issues; sharing and submitting plugins; converting standalone configurations to plugins; migration steps and what changes
- [Plugins reference](references/claude-code-plugins-reference.md) -- complete technical reference for plugin system; plugin components reference (skills, agents, hooks, MCP servers, LSP servers); plugin installation scopes; plugin manifest schema (required fields, metadata fields, component path fields, path behavior rules, environment variables, persistent data directory); plugin caching and file resolution; plugin directory structure and file locations; CLI commands reference (install, uninstall, enable, disable, update); debugging and development tools (common issues, hook/MCP/directory troubleshooting); version management and distribution
- [Discover and install plugins](references/claude-code-discover-plugins.md) -- finding and installing plugins from marketplaces; official Anthropic marketplace; code intelligence plugins (11 LSP plugins); external integrations (GitHub, GitLab, Jira, Slack, etc.); development workflow plugins; output style plugins; adding marketplaces (GitHub, Git, local, URL); installing and managing plugins; managing marketplaces; auto-update configuration; team marketplace configuration (extraKnownMarketplaces, enabledPlugins); security considerations; troubleshooting
- [Plugin marketplaces](references/claude-code-plugin-marketplaces.md) -- creating and distributing plugin marketplaces; marketplace.json schema (required fields, owner, optional metadata, pluginRoot); plugin entries (source, category, tags, strict mode); plugin sources (relative path, github, url, git-subdir, npm with pinning); hosting on GitHub and other git services; private repository authentication; managed marketplace restrictions (strictKnownMarketplaces with hostPattern/pathPattern); version resolution and release channels; pre-populating plugins for containers (CLAUDE_CODE_PLUGIN_SEED_DIR); validation and testing; troubleshooting

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Plugin marketplaces: https://code.claude.com/docs/en/plugin-marketplaces.md
