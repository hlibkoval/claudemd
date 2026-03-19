---
name: plugins-doc
description: Complete documentation for Claude Code plugins -- creating plugins (plugin.json manifest, skills/commands/agents/hooks/MCP/LSP components, plugin directory structure, quickstart walkthrough), plugin manifest schema (name, version, description, author, homepage, repository, license, keywords, component path fields, path behavior rules), environment variables (${CLAUDE_PLUGIN_ROOT}, ${CLAUDE_PLUGIN_DATA}, persistent data directory pattern), plugin installation scopes (user/project/local/managed), plugin caching and file resolution (cache location, path traversal limitations, symlinks), CLI commands (plugin install/uninstall/enable/disable/update with --scope and --keep-data flags), debugging and development tools (claude --debug, /debug, common issues table, hook/MCP/LSP troubleshooting, directory structure mistakes, plugin validate), version management (semver, MAJOR.MINOR.PATCH, caching behavior), testing plugins locally (--plugin-dir flag, /reload-plugins, multiple plugins), converting standalone config to plugins (migration steps, what changes), LSP servers (.lsp.json, required/optional fields, available plugins, extensionToLanguage, transport, restartOnCrash), shipping default settings (settings.json, agent key), plugin components reference (skills, agents, hooks with all event types and hook types, MCP servers, LSP servers), hook lifecycle events (SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, Stop, StopFailure, TeammateIdle, TaskCompleted, InstructionsLoaded, ConfigChange, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd), discovering and installing plugins (/plugin command, Discover/Installed/Marketplaces/Errors tabs, official Anthropic marketplace, demo marketplace, code intelligence plugins with LSP binaries, external integration plugins, development workflow plugins, output style plugins), adding marketplaces (GitHub owner/repo, Git URLs with SSH/HTTPS, local paths, remote URLs, branch/tag pinning), installing plugins (scopes, /plugin install, interactive UI), managing plugins (/plugin disable/enable/uninstall, /reload-plugins), managing marketplaces (list/update/remove, auto-updates, DISABLE_AUTOUPDATER, FORCE_AUTOUPDATE_PLUGINS), team marketplace configuration (extraKnownMarketplaces, enabledPlugins in .claude/settings.json), creating marketplaces (marketplace.json schema with name/owner/plugins, plugin entries with source/name/description/version, plugin sources: relative paths/GitHub/Git URL/git-subdir/npm/pip, advanced entries with commands/agents/hooks/mcpServers, strict mode true/false), hosting marketplaces (GitHub recommended, other git hosts, private repos with credential helpers and auth tokens, local testing), pre-populating plugins for containers (CLAUDE_CODE_PLUGIN_SEED_DIR, seed directory structure, read-only behavior, seed precedence), managed marketplace restrictions (strictKnownMarketplaces with empty array lockdown/source allowlist/hostPattern/pathPattern regex matching), version resolution and release channels (stable/latest refs, managed settings assignment), marketplace validation and testing (claude plugin validate, common validation errors and warnings), marketplace troubleshooting (not loading, validation errors, installation failures, auth failures, git timeouts with CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS, relative paths in URL marketplaces, files not found after installation), code intelligence troubleshooting (binary not found, high memory, false positives in monorepos). Load when discussing Claude Code plugins, creating plugins, plugin.json, plugin manifest, plugin components, plugin skills, plugin agents, plugin hooks, plugin MCP servers, plugin LSP servers, .lsp.json, plugin directory structure, plugin installation, plugin scopes, plugin marketplace, marketplace.json, creating a marketplace, hosting a marketplace, discovering plugins, /plugin command, plugin install, plugin uninstall, plugin enable, plugin disable, plugin update, plugin validate, --plugin-dir, /reload-plugins, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, persistent data directory, plugin caching, plugin file resolution, plugin debugging, plugin troubleshooting, plugin versioning, semver, converting to plugins, migration, standalone vs plugin, plugin settings.json, plugin environment variables, hook lifecycle events in plugins, strict mode, marketplace schema, plugin sources, npm plugin source, pip plugin source, git-subdir source, extraKnownMarketplaces, enabledPlugins, strictKnownMarketplaces, managed marketplace restrictions, marketplace auto-updates, DISABLE_AUTOUPDATER, FORCE_AUTOUPDATE_PLUGINS, CLAUDE_CODE_PLUGIN_SEED_DIR, seed directory, code intelligence plugins, LSP plugins, pyright-lsp, typescript-lsp, rust-analyzer-lsp, external integration plugins, output style plugins, plugin security, or extending Claude Code with plugins.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins -- creating, distributing, installing, and managing plugins and plugin marketplaces.

## Quick Reference

Plugins extend Claude Code with skills, agents, hooks, MCP servers, and LSP servers. They are self-contained directories with a `.claude-plugin/plugin.json` manifest. Skills are namespaced as `/plugin-name:skill-name` to prevent conflicts.

### When to Use Plugins vs Standalone

| Approach | Skill names | Best for |
|:---------|:------------|:---------|
| Standalone (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| Plugins (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with team/community, reusable across projects, versioned releases |

### Plugin Directory Structure

```
my-plugin/
  .claude-plugin/
    plugin.json          # Manifest (only file in this dir)
  commands/              # Skill markdown files (legacy)
  skills/                # Skills with <name>/SKILL.md structure
  agents/                # Subagent markdown files
  hooks/
    hooks.json           # Hook configuration
  .mcp.json              # MCP server definitions
  .lsp.json              # LSP server configurations
  settings.json          # Default settings (only "agent" key supported)
  scripts/               # Hook and utility scripts
```

Components must be at the plugin root, NOT inside `.claude-plugin/`. Only `plugin.json` belongs in `.claude-plugin/`.

### Plugin Manifest Schema (plugin.json)

The manifest is optional. If omitted, components are auto-discovered in default locations and the name derives from the directory name.

**Required fields (if manifest exists):**

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique identifier (kebab-case, no spaces). Used as skill namespace prefix |

**Metadata fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `version` | string | Semantic version (MAJOR.MINOR.PATCH) |
| `description` | string | Brief explanation of plugin purpose |
| `author` | object | `{name, email?, url?}` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX license identifier (MIT, Apache-2.0, etc.) |
| `keywords` | array | Discovery tags |

**Component path fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `commands` | string or array | Additional command files/directories |
| `agents` | string or array | Additional agent files |
| `skills` | string or array | Additional skill directories |
| `hooks` | string, array, or object | Hook config paths or inline config |
| `mcpServers` | string, array, or object | MCP config paths or inline config |
| `lspServers` | string, array, or object | LSP config paths or inline config |
| `outputStyles` | string or array | Additional output style files/directories |

Custom paths supplement default directories -- they do not replace them. All paths must be relative and start with `./`.

### Environment Variables

| Variable | Description |
|:---------|:------------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin installation directory. Changes on update -- files written here do not survive updates |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state that survives updates (`~/.claude/plugins/data/{id}/`). Created on first reference |

Both are substituted inline in skill content, agent content, hook commands, and MCP/LSP server configs, and exported to hook processes and server subprocesses.

**Persistent data pattern:** Compare the bundled manifest against a copy in the data directory and reinstall when they differ. This detects dependency-changing updates reliably.

### Plugin Hook Events

Plugin hooks respond to the same lifecycle events as user-defined hooks:

| Event | When it fires |
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
| `Stop` | Claude finishes responding |
| `StopFailure` | Turn ends due to API error |
| `TeammateIdle` | Agent team teammate going idle |
| `TaskCompleted` | Task being marked completed |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded |
| `ConfigChange` | Configuration file changes during session |
| `WorktreeCreate` | Worktree being created |
| `WorktreeRemove` | Worktree being removed |
| `PreCompact` | Before context compaction |
| `PostCompact` | After context compaction |
| `Elicitation` | MCP server requests user input |
| `ElicitationResult` | User responds to MCP elicitation |
| `SessionEnd` | Session terminates |

**Hook types:** `command` (shell commands), `http` (POST request), `prompt` (LLM evaluation), `agent` (agentic verifier with tools).

### LSP Server Configuration (.lsp.json)

**Required fields:**

| Field | Description |
|:------|:------------|
| `command` | LSP binary to execute (must be in PATH) |
| `extensionToLanguage` | Maps file extensions to language identifiers |

**Optional fields:** `args`, `transport` (stdio/socket), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`.

**Available LSP plugins (official marketplace):**

| Plugin | Language | Binary required |
|:-------|:---------|:---------------|
| `pyright-lsp` | Python | `pyright-langserver` |
| `typescript-lsp` | TypeScript | `typescript-language-server` |
| `rust-analyzer-lsp` | Rust | `rust-analyzer` |
| `clangd-lsp` | C/C++ | `clangd` |
| `gopls-lsp` | Go | `gopls` |
| `swift-lsp` | Swift | `sourcekit-lsp` |
| `kotlin-lsp` | Kotlin | `kotlin-language-server` |

### Plugin Installation Scopes

| Scope | Settings file | Use case |
|:------|:-------------|:---------|
| `user` (default) | `~/.claude/settings.json` | Personal plugins, all projects |
| `project` | `.claude/settings.json` | Team plugins via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings (read-only) | Organization-wide, update only |

### CLI Commands

| Command | Purpose |
|:--------|:--------|
| `claude plugin install <plugin> [-s scope]` | Install from marketplace |
| `claude plugin uninstall <plugin> [-s scope] [--keep-data]` | Remove plugin (aliases: `remove`, `rm`) |
| `claude plugin enable <plugin> [-s scope]` | Enable a disabled plugin |
| `claude plugin disable <plugin> [-s scope]` | Disable without uninstalling |
| `claude plugin update <plugin> [-s scope]` | Update to latest version |
| `claude plugin validate` | Validate plugin.json, frontmatter, hooks.json |
| `claude --plugin-dir ./path` | Load local plugin for development |
| `/reload-plugins` | Reload all plugins mid-session |
| `/plugin` | Interactive plugin manager (Discover/Installed/Marketplaces/Errors tabs) |

### Plugin Caching

Marketplace plugins are copied to `~/.claude/plugins/cache` rather than used in-place. Paths referencing files outside the plugin root (e.g., `../shared-utils`) will not work. Use symlinks for external dependencies -- they are followed during the copy process.

### Discovering and Installing Plugins

The official Anthropic marketplace (`claude-plugins-official`) is available automatically. Browse with `/plugin` Discover tab or install directly:

```
/plugin install plugin-name@claude-plugins-official
```

**Official plugin categories:** code intelligence (LSP), external integrations (GitHub, GitLab, Jira, Slack, etc.), development workflows (commit-commands, pr-review-toolkit, etc.), output styles.

### Marketplace Configuration

**Adding marketplaces:**

| Source | Command |
|:-------|:--------|
| GitHub | `/plugin marketplace add owner/repo` |
| Git URL | `/plugin marketplace add https://gitlab.com/company/plugins.git` |
| Git with ref | `/plugin marketplace add https://...git#v1.0.0` |
| Local path | `/plugin marketplace add ./my-marketplace` |
| Remote URL | `/plugin marketplace add https://example.com/marketplace.json` |

**Auto-updates:** Official marketplaces auto-update by default. Toggle per-marketplace in `/plugin` > Marketplaces. `DISABLE_AUTOUPDATER` disables all auto-updates. `FORCE_AUTOUPDATE_PLUGINS=true` keeps plugin auto-updates while disabling Claude Code auto-updates.

### Creating a Marketplace (marketplace.json)

Place at `.claude-plugin/marketplace.json` in your repository root.

**Required fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Marketplace identifier (kebab-case). Users see this in install commands |
| `owner` | object | `{name, email?}` |
| `plugins` | array | List of plugin entries |

**Plugin entry required fields:** `name` (string), `source` (string or object).

**Plugin source types:**

| Source | Format | Notes |
|:-------|:-------|:------|
| Relative path | `"./plugins/my-plugin"` | Within marketplace repo. Must start with `./` |
| GitHub | `{source: "github", repo: "owner/repo", ref?, sha?}` | |
| Git URL | `{source: "url", url: "https://...", ref?, sha?}` | |
| Git subdirectory | `{source: "git-subdir", url, path, ref?, sha?}` | Sparse clone for monorepos |
| npm | `{source: "npm", package: "@org/pkg", version?, registry?}` | |
| pip | `{source: "pip", package, version?, registry?}` | |

**Strict mode** (`strict` field in plugin entries): `true` (default) means `plugin.json` is the authority and marketplace supplements it. `false` means the marketplace entry is the entire definition.

### Team Marketplace Setup

Add to `.claude/settings.json` for auto-discovery:

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

### Managed Marketplace Restrictions (strictKnownMarketplaces)

Set in managed settings to control which marketplaces users can add:

| Value | Behavior |
|:------|:---------|
| Undefined | No restrictions |
| Empty array `[]` | Complete lockdown -- no new marketplaces |
| List of sources | Only matching marketplaces allowed |

Source matchers: exact `github`/`url` match, `hostPattern` (regex on host), `pathPattern` (regex on filesystem path).

### Container Pre-population (CLAUDE_CODE_PLUGIN_SEED_DIR)

Pre-populate plugins at image build time. Set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a directory mirroring `~/.claude/plugins` structure (`known_marketplaces.json`, `marketplaces/`, `cache/`). Read-only at runtime. Multiple paths separated by `:` (Unix) or `;` (Windows).

### Testing Locally

```
claude --plugin-dir ./my-plugin
```

Local `--plugin-dir` plugins override installed plugins of the same name (except managed force-enabled). Use `/reload-plugins` to pick up changes without restarting. Load multiple plugins with repeated `--plugin-dir` flags.

### Debugging

Run `claude --debug` or `/debug` to see plugin loading details, errors, and component registration. Check `/plugin` Errors tab for runtime issues.

| Issue | Solution |
|:------|:---------|
| Plugin not loading | Run `claude plugin validate` to check manifest and frontmatter |
| Commands not appearing | Ensure directories are at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Check script is executable (`chmod +x`) and uses `${CLAUDE_PLUGIN_ROOT}` |
| MCP server fails | Use `${CLAUDE_PLUGIN_ROOT}` for all paths; check `claude --debug` logs |
| LSP binary not found | Install the language server binary; check `/plugin` Errors tab |
| Git operations time out | Set `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` (default 120000ms) |

### Version Management

Use semantic versioning (MAJOR.MINOR.PATCH). Version must be bumped before distributing changes -- Claude Code uses the version for update detection and cache paths. Version in `plugin.json` takes priority over `marketplace.json`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) -- when to use plugins vs standalone (comparison table), quickstart walkthrough (manifest, skill, testing with --plugin-dir, $ARGUMENTS), plugin structure overview (directory layout, component locations), developing complex plugins (adding skills with SKILL.md frontmatter, LSP servers with .lsp.json, shipping default settings.json with agent key, organizing complex plugins), testing locally (--plugin-dir, /reload-plugins, multiple plugins), debugging plugin issues (structure checks, validation, debug tools), sharing plugins (documentation, versioning, marketplace distribution), submitting to official marketplace (claude.ai and platform.claude.com submission forms), converting standalone config to plugins (migration steps for commands/agents/skills/hooks, what changes table)
- [Plugins reference](references/claude-code-plugins-reference.md) -- plugin components reference (skills file format and integration, agents location and structure, hooks configuration with all lifecycle events and hook types, MCP server configuration with environment variables, LSP server configuration with all required/optional fields and available plugins table), plugin installation scopes (user/project/local/managed with settings files), plugin manifest schema (complete schema with all required/metadata/component-path fields, path behavior rules, environment variables ${CLAUDE_PLUGIN_ROOT}/${CLAUDE_PLUGIN_DATA} with persistent data directory pattern and SessionStart install hook example), plugin caching and file resolution (cache location, path traversal limitations, symlinks), plugin directory structure (standard layout, file locations reference table), CLI commands reference (install/uninstall/enable/disable/update with all flags), debugging and development tools (--debug output, common issues table, hook/MCP/LSP troubleshooting, directory structure mistakes, debug checklist), version management (semver format, best practices, caching behavior warning)
- [Discover and install plugins](references/claude-code-discover-plugins.md) -- how marketplaces work (two-step process), official Anthropic marketplace (code intelligence plugins with LSP binary table, LSP diagnostic and navigation capabilities, external integration plugins, development workflow plugins, output style plugins), demo marketplace walkthrough (add/browse/install/use), adding marketplaces (GitHub owner/repo, Git URLs with HTTPS/SSH and branch pinning, local paths, remote URLs), installing plugins (scopes, interactive UI, /plugin install), managing plugins (disable/enable/uninstall, --scope, /reload-plugins), managing marketplaces (interactive UI, CLI list/update/remove, auto-updates with DISABLE_AUTOUPDATER and FORCE_AUTOUPDATE_PLUGINS), team marketplace configuration (extraKnownMarketplaces in .claude/settings.json), security considerations, troubleshooting (/plugin not recognized, marketplace not loading, plugin installation failures, files not found, plugin skills not appearing, code intelligence issues)
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) -- marketplace overview (creation/hosting/distribution flow), walkthrough creating a local marketplace (directory structure, skill, plugin manifest, marketplace.json, install and test), marketplace.json schema (required fields name/owner/plugins, owner fields, optional metadata with pluginRoot), plugin entries (required name/source, optional standard/component fields), plugin sources (relative paths, GitHub, Git URL, git-subdir sparse clone, npm with registry, pip, pinning with ref/sha), advanced plugin entries (multiple commands/agents, inline hooks/mcpServers, ${CLAUDE_PLUGIN_ROOT}), strict mode (true vs false behavior), hosting marketplaces (GitHub recommended, other git hosts, private repos with credential helpers and auth tokens for auto-updates, local testing), team marketplace configuration (extraKnownMarketplaces, enabledPlugins), container pre-population (CLAUDE_CODE_PLUGIN_SEED_DIR structure, multi-path layering, read-only behavior, seed precedence, path resolution), managed marketplace restrictions (strictKnownMarketplaces with empty array lockdown, source allowlist, hostPattern regex, pathPattern regex, how restrictions work), version resolution and release channels (stable/latest refs, managed settings assignment), validation and testing (claude plugin validate, /plugin validate), troubleshooting (marketplace not loading, validation errors table, installation failures, private repo auth, git timeouts with CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS, relative paths in URL marketplaces, files not found after installation)

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
