---
name: plugins-doc
description: Complete documentation for Claude Code plugins — creating plugins (plugin manifest, directory structure, skills/agents/hooks/MCP/LSP components), discovering and installing plugins from marketplaces, plugin marketplaces (creating, hosting, distributing, marketplace.json schema), and the full plugins technical reference (manifest schema, component specifications, CLI commands, environment variables, debugging). Covers plugin.json fields (name, version, description, author, homepage, repository, license, keywords, component paths), plugin components (skills, agents, hooks with event types and hook types, MCP servers, LSP servers with configuration fields), installation scopes (user, project, local, managed), environment variables (${CLAUDE_PLUGIN_ROOT}, ${CLAUDE_PLUGIN_DATA}), persistent data directory pattern, plugin caching and file resolution, path traversal limitations, CLI commands (plugin install/uninstall/enable/disable/update with options), debugging tools (claude --debug, /plugin validate, common issues table), version management (semver), marketplace schema (name, owner, plugins array, metadata, pluginRoot), plugin sources (relative path, github, url, git-subdir, npm, pip with fields), strict mode, marketplace hosting (GitHub, GitLab, private repos with auth tokens), team marketplace configuration (extraKnownMarketplaces, enabledPlugins), managed marketplace restrictions (strictKnownMarketplaces with hostPattern/pathPattern), auto-updates (DISABLE_AUTOUPDATER, FORCE_AUTOUPDATE_PLUGINS), container pre-population (CLAUDE_CODE_PLUGIN_SEED_DIR), version resolution and release channels, marketplace validation and troubleshooting, official marketplace categories (code intelligence LSP plugins, external integrations, development workflows, output styles), converting standalone configurations to plugins, and /reload-plugins. Load when discussing Claude Code plugins, creating plugins, plugin.json, plugin manifests, plugin components, plugin hooks, plugin MCP servers, plugin LSP servers, plugin installation, plugin scopes, plugin marketplaces, marketplace.json, discovering plugins, /plugin command, plugin install, plugin uninstall, plugin enable, plugin disable, plugin update, plugin validate, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, plugin caching, plugin directory structure, plugin sources, marketplace hosting, extraKnownMarketplaces, enabledPlugins, strictKnownMarketplaces, managed marketplace restrictions, plugin auto-updates, plugin seed directory, release channels, strict mode, /reload-plugins, official marketplace, LSP plugins, code intelligence plugins, or extending Claude Code with plugins.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins, including creating plugins, discovering and installing plugins, plugin marketplaces, and the full technical reference.

## Quick Reference

Plugins extend Claude Code with custom skills, agents, hooks, MCP servers, and LSP servers. A plugin is a self-contained directory with a `.claude-plugin/plugin.json` manifest and component directories at the plugin root. Plugin skills are namespaced as `/plugin-name:skill-name` to prevent conflicts.

### When to Use Plugins vs Standalone

| Approach | Skill names | Best for |
|:---------|:------------|:---------|
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugins** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teams, community distribution, reuse across projects |

### Plugin Directory Structure

```
my-plugin/
  .claude-plugin/
    plugin.json           # Manifest (only this goes here)
  commands/               # Skill markdown files (legacy; use skills/)
  agents/                 # Subagent markdown files
  skills/                 # Skills with <name>/SKILL.md structure
  hooks/
    hooks.json            # Hook configuration
  .mcp.json               # MCP server definitions
  .lsp.json               # LSP server configurations
  settings.json           # Default settings (only "agent" key supported)
  scripts/                # Hook and utility scripts
```

Components must be at the plugin root, not inside `.claude-plugin/`.

### Plugin Manifest (`plugin.json`)

The manifest is optional. If omitted, components are auto-discovered from default locations and the name is derived from the directory name.

**Required fields (if manifest present):**

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique identifier (kebab-case, no spaces) |

**Metadata fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `version` | string | Semantic version (MAJOR.MINOR.PATCH) |
| `description` | string | Brief explanation of plugin purpose |
| `author` | object | `{ name, email?, url? }` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX license identifier |
| `keywords` | array | Discovery tags |

**Component path fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `commands` | string or array | Additional command files/directories |
| `agents` | string or array | Additional agent files |
| `skills` | string or array | Additional skill directories |
| `hooks` | string, array, or object | Hook config paths or inline config |
| `mcpServers` | string, array, or object | MCP config paths or inline config |
| `lspServers` | string, array, or object | LSP server configs |
| `outputStyles` | string or array | Output style files/directories |

Custom paths supplement default directories -- they do not replace them. All paths must be relative and start with `./`.

### Plugin Components

**Skills**: directories with `SKILL.md` in `skills/` or markdown files in `commands/`. Auto-discovered on install.

**Agents**: markdown files in `agents/` with name/description frontmatter. Appear in `/agents`.

**Hooks**: configured in `hooks/hooks.json` or inline in `plugin.json`.

Available hook events:

| Event | When |
|:------|:-----|
| `PreToolUse` | Before Claude uses any tool |
| `PostToolUse` | After Claude successfully uses any tool |
| `PostToolUseFailure` | After tool execution fails |
| `PermissionRequest` | When a permission dialog is shown |
| `UserPromptSubmit` | When user submits a prompt |
| `Notification` | When Claude Code sends notifications |
| `Stop` | When Claude attempts to stop |
| `SubagentStart` | When a subagent is started |
| `SubagentStop` | When a subagent attempts to stop |
| `SessionStart` | At the beginning of sessions |
| `SessionEnd` | At the end of sessions |
| `TeammateIdle` | When an agent team teammate is about to go idle |
| `TaskCompleted` | When a task is being marked as completed |
| `PreCompact` | Before conversation history is compacted |
| `PostCompact` | After conversation history is compacted |

Hook types: `command` (shell commands), `prompt` (LLM evaluation), `agent` (agentic verifier with tools).

**MCP servers**: configured in `.mcp.json` or inline in `plugin.json`. Start automatically when plugin is enabled.

**LSP servers**: configured in `.lsp.json` or inline in `plugin.json`. Provide code intelligence (diagnostics, go to definition, find references).

LSP required fields: `command` (binary to execute), `extensionToLanguage` (maps file extensions to language IDs).

LSP optional fields: `args`, `transport` (`stdio`/`socket`), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`.

### Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin installation directory. Changes on update. |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state that survives updates. Resolves to `~/.claude/plugins/data/{id}/`. Deleted on uninstall from last scope (unless `--keep-data`). |

Both are substituted inline in skill content, agent content, hook commands, and MCP/LSP configs, and exported as environment variables to hook processes and server subprocesses.

### Installation Scopes

| Scope | Settings file | Use case |
|:------|:--------------|:---------|
| `user` | `~/.claude/settings.json` | Personal, all projects (default) |
| `project` | `.claude/settings.json` | Team, shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Read-only, update only |

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude plugin install <plugin> [-s scope]` | Install from marketplace |
| `claude plugin uninstall <plugin> [-s scope] [--keep-data]` | Remove plugin (aliases: `remove`, `rm`) |
| `claude plugin enable <plugin> [-s scope]` | Enable a disabled plugin |
| `claude plugin disable <plugin> [-s scope]` | Disable without uninstalling |
| `claude plugin update <plugin> [-s scope]` | Update to latest version |
| `claude plugin validate .` | Validate plugin/marketplace structure |

In-session: `/plugin install`, `/plugin uninstall`, `/plugin enable`, `/plugin disable`, `/plugin validate`, `/reload-plugins`.

### Testing Locally

```bash
claude --plugin-dir ./my-plugin
```

Local `--plugin-dir` plugins with the same name as installed marketplace plugins take precedence for that session (except managed force-enabled plugins). Use `/reload-plugins` to pick up changes without restarting. Load multiple plugins with repeated `--plugin-dir` flags.

### Debugging

Use `claude --debug` or `/debug` to see plugin loading details. Use `/plugin validate` to check `plugin.json`, frontmatter, and `hooks/hooks.json`.

| Issue | Solution |
|:------|:---------|
| Plugin not loading | Run `/plugin validate`; check `plugin.json` |
| Commands not appearing | Ensure `commands/` at root, not in `.claude-plugin/` |
| Hooks not firing | Check script is executable (`chmod +x`), uses `${CLAUDE_PLUGIN_ROOT}` |
| MCP server fails | Use `${CLAUDE_PLUGIN_ROOT}` for all paths |
| LSP executable not found | Install the language server binary |

### Discovering and Installing Plugins

**Official marketplace** (`claude-plugins-official`): automatically available. Browse with `/plugin` Discover tab. Install with `/plugin install plugin-name@claude-plugins-official`.

**Adding marketplaces:**

| Source | Command |
|:-------|:--------|
| GitHub | `/plugin marketplace add owner/repo` |
| Git URL | `/plugin marketplace add https://gitlab.com/company/plugins.git` |
| Local path | `/plugin marketplace add ./my-marketplace` |
| Remote URL | `/plugin marketplace add https://example.com/marketplace.json` |

Append `#ref` to git URLs for specific branches/tags.

**Official marketplace categories:**

| Category | Examples |
|:---------|:---------|
| Code intelligence (LSP) | `pyright-lsp`, `typescript-lsp`, `rust-analyzer-lsp`, `gopls-lsp`, `clangd-lsp` |
| External integrations | `github`, `gitlab`, `atlassian`, `slack`, `figma`, `sentry`, `vercel` |
| Development workflows | `commit-commands`, `pr-review-toolkit`, `plugin-dev` |
| Output styles | `explanatory-output-style`, `learning-output-style` |

**Auto-updates**: toggle per-marketplace in `/plugin` > Marketplaces. Official marketplaces auto-update by default. Disable all auto-updates with `DISABLE_AUTOUPDATER`. Keep plugin updates while disabling CLI updates with `FORCE_AUTOUPDATE_PLUGINS=true`.

### Plugin Marketplaces

**Creating a marketplace**: place `.claude-plugin/marketplace.json` in your repository root.

**Marketplace schema required fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Marketplace identifier (kebab-case) |
| `owner` | object | `{ name, email? }` |
| `plugins` | array | List of plugin entries |

**Optional metadata**: `metadata.description`, `metadata.version`, `metadata.pluginRoot` (base directory for relative source paths).

**Plugin entry required fields**: `name` (kebab-case), `source` (string or object).

**Plugin sources:**

| Source | Format | Key fields |
|:-------|:-------|:-----------|
| Relative path | `"./plugins/my-plugin"` | -- |
| GitHub | `{ "source": "github", "repo": "owner/repo", "ref?", "sha?" }` | `repo` required |
| Git URL | `{ "source": "url", "url": "https://...", "ref?", "sha?" }` | `url` required |
| Git subdirectory | `{ "source": "git-subdir", "url": "...", "path": "...", "ref?", "sha?" }` | `url`, `path` required |
| npm | `{ "source": "npm", "package": "@org/pkg", "version?", "registry?" }` | `package` required |
| pip | `{ "source": "pip", "package": "pkg", "version?", "registry?" }` | `package` required |

**Strict mode** (`strict` field): `true` (default) means `plugin.json` is authority, marketplace supplements. `false` means marketplace entry is the entire definition; `plugin.json` must not declare components.

**Team configuration**: add `extraKnownMarketplaces` and `enabledPlugins` to `.claude/settings.json` to auto-prompt team members.

**Managed restrictions**: `strictKnownMarketplaces` in managed settings restricts which marketplaces users can add. Supports exact matching (`github`, `url` sources) and regex patterns (`hostPattern`, `pathPattern`).

**Container pre-population**: set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a directory mirroring `~/.claude/plugins` structure. Read-only; auto-updates disabled for seed marketplaces.

**Private repos**: use existing git credential helpers for manual operations. For background auto-updates, set `GITHUB_TOKEN`/`GH_TOKEN`, `GITLAB_TOKEN`/`GL_TOKEN`, or `BITBUCKET_TOKEN`.

**Git timeout**: override the default 120s timeout with `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` (in milliseconds).

### Converting Standalone to Plugin

1. Create plugin directory with `.claude-plugin/plugin.json`
2. Copy `commands/`, `agents/`, `skills/` from `.claude/`
3. Move hooks from `settings.json` to `hooks/hooks.json` (same format)
4. Test with `claude --plugin-dir ./my-plugin`

### Submitting to Official Marketplace

Use the in-app submission forms:
- Claude.ai: `claude.ai/settings/plugins/submit`
- Console: `platform.claude.com/plugins/submit`

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) -- when to use plugins vs standalone, quickstart (creating manifest, adding skills, testing with --plugin-dir, skill arguments with $ARGUMENTS), plugin structure overview (directory layout, component locations), developing complex plugins (adding skills with SKILL.md frontmatter, LSP servers with .lsp.json, default settings with settings.json agent key, organizing complex plugins), testing locally (--plugin-dir, /reload-plugins, loading multiple plugins), debugging (structure checks, component testing), sharing (documentation, versioning, marketplaces, official marketplace submission), converting standalone configurations to plugins (migration steps, what changes)
- [Plugins reference](references/claude-code-plugins-reference.md) -- plugin components reference (skills in skills/ and commands/, agents with frontmatter, hooks with all event types and hook types, MCP servers with .mcp.json config and ${CLAUDE_PLUGIN_ROOT}, LSP servers with all config fields and available plugins table), installation scopes (user/project/local/managed with settings files), plugin manifest schema (complete schema with required/metadata/component path fields, path behavior rules), environment variables (${CLAUDE_PLUGIN_ROOT} and ${CLAUDE_PLUGIN_DATA} with persistent data directory pattern and SessionStart hook example), plugin caching and file resolution (path traversal limitations, symlinks), plugin directory structure (standard layout, file locations reference), CLI commands reference (install/uninstall/enable/disable/update with all options), debugging and development tools (debug commands, common issues table, hook troubleshooting, MCP server troubleshooting, directory structure mistakes), distribution and versioning reference (semver, version management best practices)
- [Discover and install plugins](references/claude-code-discover-plugins.md) -- how marketplaces work, official Anthropic marketplace, official marketplace categories (code intelligence LSP plugins with binary requirements table, external integrations, development workflows, output styles), demo marketplace walkthrough, adding marketplaces (GitHub, Git hosts, local paths, remote URLs, branch/tag refs), installing plugins (scopes, interactive UI, CLI), managing installed plugins (enable/disable/uninstall, /reload-plugins), managing marketplaces (interactive interface, CLI commands for list/update/remove), auto-update configuration (per-marketplace toggle, DISABLE_AUTOUPDATER, FORCE_AUTOUPDATE_PLUGINS), team marketplace configuration (extraKnownMarketplaces in .claude/settings.json), security considerations, troubleshooting (/plugin not recognized, marketplace not loading, plugin installation failures, code intelligence issues)
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) -- marketplace overview and distribution workflow, walkthrough (creating local marketplace with directory structure, skill, plugin manifest, marketplace.json), marketplace schema (required fields name/owner/plugins, optional metadata, pluginRoot), plugin entries (required name/source, optional metadata and component fields), plugin sources (relative paths, GitHub with ref/sha pinning, Git URLs, git-subdir for monorepos, npm with version/registry, pip), strict mode (true vs false behavior), hosting and distribution (GitHub recommended, other Git hosts, private repos with auth tokens, local testing), team configuration (extraKnownMarketplaces, enabledPlugins), container pre-population (CLAUDE_CODE_PLUGIN_SEED_DIR with behavior details), managed marketplace restrictions (strictKnownMarketplaces with hostPattern/pathPattern, how restrictions work), version resolution and release channels (setting up stable/latest channels, assigning to user groups), validation and testing (claude plugin validate), troubleshooting (marketplace not loading, validation errors table, installation failures, private repo auth, git timeouts with CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS, relative path failures in URL-based marketplaces, files not found after installation)

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
