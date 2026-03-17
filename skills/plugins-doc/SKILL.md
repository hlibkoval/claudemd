---
name: plugins-doc
description: Complete documentation for Claude Code plugins -- creating plugins (plugin manifest, plugin.json schema, required/metadata/component-path fields, quickstart walkthrough), plugin structure (skills, agents, hooks, MCP servers, LSP servers, settings.json, commands), testing plugins (--plugin-dir flag, /reload-plugins, debugging with --debug, common issues), converting standalone config to plugins, plugin installation scopes (user/project/local/managed), plugin caching and file resolution (path traversal limitations, symlinks), environment variables (${CLAUDE_PLUGIN_ROOT}), CLI commands (plugin install/uninstall/enable/disable/update with --scope), LSP server configuration (.lsp.json, required/optional fields, available plugins for Python/TypeScript/Rust/Go/C++/Java/etc, code intelligence capabilities), hook types (command/prompt/agent) and events (PreToolUse/PostToolUse/PostToolUseFailure/PermissionRequest/UserPromptSubmit/Notification/Stop/SubagentStart/SubagentStop/SessionStart/SessionEnd/TeammateIdle/TaskCompleted/PreCompact), MCP server configuration (.mcp.json), version management (semver, MAJOR.MINOR.PATCH), discovering and installing plugins (/plugin command, Discover/Installed/Marketplaces/Errors tabs), official Anthropic marketplace (claude-plugins-official, code intelligence plugins, external integrations, development workflows, output styles), adding marketplaces (GitHub/Git URLs/local paths/remote URLs, /plugin marketplace add), managing marketplaces (list/update/remove, auto-updates, DISABLE_AUTOUPDATER, FORCE_AUTOUPDATE_PLUGINS), team marketplace configuration (extraKnownMarketplaces in .claude/settings.json, enabledPlugins), plugin security, creating marketplaces (marketplace.json schema, required fields name/owner/plugins, optional metadata, pluginRoot), plugin entries (source/category/tags/strict fields, component configuration), plugin sources (relative paths, github, url, git-subdir, npm, pip with pinning via ref/sha/version), strict mode (true/false behavior), hosting marketplaces (GitHub/GitLab/Bitbucket, private repos with credential helpers and tokens), managed marketplace restrictions (strictKnownMarketplaces, hostPattern, pathPattern), version resolution and release channels, validation and testing (claude plugin validate), troubleshooting (marketplace not loading, installation failures, private repo auth, git timeouts CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS, relative path issues, files not found after install, code intelligence issues). Load when discussing Claude Code plugins, creating plugins, plugin.json, plugin manifest, plugin structure, .claude-plugin directory, plugin marketplaces, marketplace.json, discovering plugins, installing plugins, /plugin command, plugin scopes, plugin CLI commands, plugin install/uninstall/enable/disable/update, LSP plugins, language server plugins, code intelligence, .lsp.json, plugin hooks, hooks.json, plugin MCP servers, .mcp.json, plugin settings.json, plugin caching, ${CLAUDE_PLUGIN_ROOT}, --plugin-dir, /reload-plugins, plugin debugging, converting to plugins, sharing plugins, distributing plugins, plugin sources (github/npm/pip/git-subdir/url), strict mode, plugin versioning, plugin auto-updates, extraKnownMarketplaces, enabledPlugins, strictKnownMarketplaces, managed marketplace restrictions, team plugin configuration, official marketplace, claude-plugins-official, plugin validation, plugin troubleshooting, or extending Claude Code with plugins.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins -- creating, distributing, discovering, and installing plugins, including marketplaces, CLI commands, and the full plugin reference.

## Quick Reference

Plugins let you extend Claude Code with custom skills, agents, hooks, MCP servers, and LSP servers, packaged for sharing across projects and teams. Each plugin lives in its own directory with a `.claude-plugin/plugin.json` manifest.

### When to Use Plugins vs Standalone Config

| Approach | Skill names | Best for |
|:---------|:------------|:---------|
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, single-project customizations, quick experiments |
| **Plugins** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teams, community distribution, versioned releases, reuse across projects |

### Plugin Directory Structure

```
my-plugin/
  .claude-plugin/
    plugin.json          # Manifest (only file in this dir)
  commands/              # Skill Markdown files (legacy)
  skills/                # Skills with SKILL.md structure
  agents/                # Subagent Markdown files
  hooks/
    hooks.json           # Hook configuration
  .mcp.json              # MCP server definitions
  .lsp.json              # LSP server configurations
  settings.json          # Default settings (currently only "agent" key)
  scripts/               # Hook and utility scripts
```

All component directories go at the plugin root, not inside `.claude-plugin/`.

### Plugin Manifest (plugin.json)

**Required:** `name` (kebab-case, no spaces) -- used for namespacing all components.

**Metadata:** `version`, `description`, `author` (name/email/url), `homepage`, `repository`, `license`, `keywords`.

**Component paths:** `commands`, `agents`, `skills`, `hooks`, `mcpServers`, `outputStyles`, `lspServers` -- all accept string, array, or (for hooks/mcpServers/lspServers) inline object. Custom paths supplement default directories, never replace them. All paths must be relative and start with `./`.

The manifest is optional. If omitted, Claude Code auto-discovers components in default locations and derives the plugin name from the directory name.

### Plugin Components

| Component | Location | Format |
|:----------|:---------|:-------|
| Skills | `skills/<name>/SKILL.md` | YAML frontmatter + markdown |
| Commands | `commands/*.md` | Simple markdown (legacy) |
| Agents | `agents/*.md` | YAML frontmatter + markdown |
| Hooks | `hooks/hooks.json` or inline in plugin.json | JSON with event matchers |
| MCP Servers | `.mcp.json` or inline in plugin.json | Standard MCP config |
| LSP Servers | `.lsp.json` or inline in plugin.json | JSON mapping language to server config |
| Settings | `settings.json` | Currently only `agent` key supported |

### Hook Events

`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `UserPromptSubmit`, `Notification`, `Stop`, `SubagentStart`, `SubagentStop`, `SessionStart`, `SessionEnd`, `TeammateIdle`, `TaskCompleted`, `PreCompact`

Hook types: `command` (shell), `prompt` (LLM eval with `$ARGUMENTS`), `agent` (agentic verifier with tools).

### LSP Server Configuration

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": { ".go": "go" }
  }
}
```

**Required:** `command`, `extensionToLanguage`. **Optional:** `args`, `transport` (stdio/socket), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`.

Users must install the language server binary separately.

### Available LSP Plugins (Official Marketplace)

| Language | Plugin | Binary |
|:---------|:-------|:-------|
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

### Environment Variable

`${CLAUDE_PLUGIN_ROOT}` -- absolute path to plugin directory. Use in hooks, MCP servers, and scripts for correct paths regardless of installation location.

### Installation Scopes

| Scope | Settings file | Use case |
|:------|:-------------|:---------|
| `user` | `~/.claude/settings.json` | Personal, across all projects (default) |
| `project` | `.claude/settings.json` | Team, shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Organization-wide (read-only, update only) |

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude plugin install <plugin> [-s scope]` | Install from marketplace |
| `claude plugin uninstall <plugin> [-s scope]` | Remove plugin (aliases: `remove`, `rm`) |
| `claude plugin enable <plugin> [-s scope]` | Enable disabled plugin |
| `claude plugin disable <plugin> [-s scope]` | Disable without uninstalling |
| `claude plugin update <plugin> [-s scope]` | Update to latest version |
| `claude plugin validate .` | Validate plugin/marketplace JSON |

Plugin argument format: `plugin-name` or `plugin-name@marketplace-name`.

### Testing Locally

```bash
claude --plugin-dir ./my-plugin
```

Multiple plugins: `claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two`. A local `--plugin-dir` plugin with the same name as an installed marketplace plugin takes precedence for that session. Run `/reload-plugins` to pick up changes without restarting.

### Marketplace Overview

A marketplace is a catalog of plugins defined by `.claude-plugin/marketplace.json`. The official Anthropic marketplace (`claude-plugins-official`) is available automatically.

**Adding marketplaces:**

| Source | Command |
|:-------|:--------|
| GitHub | `/plugin marketplace add owner/repo` |
| Git URL | `/plugin marketplace add https://gitlab.com/company/plugins.git` |
| Git + ref | Append `#v1.0.0` to the URL |
| Local path | `/plugin marketplace add ./my-marketplace` |
| Remote URL | `/plugin marketplace add https://example.com/marketplace.json` |

**Managing:** `/plugin marketplace list`, `/plugin marketplace update <name>`, `/plugin marketplace remove <name>`.

### Marketplace Schema (marketplace.json)

**Required:** `name` (kebab-case), `owner` (object with `name`, optional `email`), `plugins` (array).

**Optional:** `metadata.description`, `metadata.version`, `metadata.pluginRoot` (base directory for relative source paths).

### Plugin Sources in Marketplace

| Source | Format | Notes |
|:-------|:-------|:------|
| Relative path | `"./plugins/my-plugin"` | Local dir within marketplace repo |
| `github` | `{ "source": "github", "repo": "owner/repo", "ref?", "sha?" }` | GitHub repository |
| `url` | `{ "source": "url", "url": "https://...", "ref?", "sha?" }` | Any git URL |
| `git-subdir` | `{ "source": "git-subdir", "url": "...", "path": "...", "ref?", "sha?" }` | Subdirectory in a monorepo (sparse clone) |
| `npm` | `{ "source": "npm", "package": "@org/pkg", "version?", "registry?" }` | npm package |
| `pip` | `{ "source": "pip", "package": "pkg", "version?", "registry?" }` | pip package |

### Strict Mode

| Value | Behavior |
|:------|:---------|
| `true` (default) | `plugin.json` is authority; marketplace entry supplements and both merge |
| `false` | Marketplace entry is entire definition; `plugin.json` components cause a conflict error |

### Team Configuration

Add to `.claude/settings.json`:

- `extraKnownMarketplaces` -- register marketplaces so team members are prompted to install them
- `enabledPlugins` -- specify which plugins should be enabled by default

### Managed Marketplace Restrictions

`strictKnownMarketplaces` in managed settings controls which marketplaces users can add:

| Value | Behavior |
|:------|:---------|
| Undefined | No restrictions |
| `[]` | Complete lockdown |
| List of sources | Only matching marketplaces allowed (supports `github`, `url`, `hostPattern`, `pathPattern`) |

### Auto-Updates

Official marketplaces auto-update by default. Toggle per-marketplace via `/plugin` > Marketplaces. Control with environment variables: `DISABLE_AUTOUPDATER` (disables all), `FORCE_AUTOUPDATE_PLUGINS=true` (keeps plugin updates when autoupdater is disabled).

### Plugin Caching

Marketplace plugins are copied to `~/.claude/plugins/cache`. Paths referencing files outside the plugin directory (e.g., `../shared-utils`) will not work. Use symlinks to include external dependencies.

### Version Management

Follow semver (`MAJOR.MINOR.PATCH`). Set version in `plugin.json` or `marketplace.json` (plugin.json takes priority). Bump the version before distributing changes -- users will not see updates without a version bump due to caching.

### Private Repository Access

Manual operations use existing git credential helpers. Background auto-updates require environment tokens: `GITHUB_TOKEN`/`GH_TOKEN`, `GITLAB_TOKEN`/`GL_TOKEN`, or `BITBUCKET_TOKEN`.

### Debugging

Run `claude --debug` or `/debug` to see plugin loading details, manifest errors, component registration, and MCP initialization.

### Common Issues

| Issue | Solution |
|:------|:---------|
| Plugin not loading | Validate JSON with `claude plugin validate` |
| Commands not appearing | Ensure `commands/` at root, not inside `.claude-plugin/` |
| Hooks not firing | `chmod +x script.sh`; check event name case-sensitivity |
| MCP server fails | Use `${CLAUDE_PLUGIN_ROOT}` for all paths |
| LSP binary not found | Install the language server binary separately |
| Git operations timeout | Set `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` (default 120s) |
| Files not found after install | Plugin cache does not copy external files; use symlinks |
| Relative paths fail in URL marketplace | Use GitHub/npm/git sources instead, or host via git |

### Submitting to Official Marketplace

- Claude.ai: claude.ai/settings/plugins/submit
- Console: platform.claude.com/plugins/submit

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) -- quickstart walkthrough (manifest, skills, testing with --plugin-dir, $ARGUMENTS), when to use plugins vs standalone config, plugin structure overview (all component directories), adding skills/agents/hooks/MCP/LSP to plugins, ship default settings (settings.json with agent key), organizing complex plugins, testing locally (--plugin-dir, /reload-plugins, debugging), converting standalone .claude/ config to plugins (migration steps, what changes), submitting to official marketplace, next steps for users and developers
- [Plugins reference](references/claude-code-plugins-reference.md) -- complete technical reference: component specifications (skills, agents, hooks with all events and types, MCP servers, LSP servers with all config fields), installation scopes (user/project/local/managed), plugin manifest schema (required/metadata/component-path fields, path behavior rules, ${CLAUDE_PLUGIN_ROOT}), plugin caching and file resolution (path traversal, symlinks), full directory structure and file locations, CLI commands reference (install/uninstall/enable/disable/update with all options), debugging and development tools (--debug, common issues with solutions, error messages, hook/MCP/LSP troubleshooting, directory structure mistakes), version management (semver, best practices)
- [Discover and install plugins](references/claude-code-discover-plugins.md) -- official Anthropic marketplace (code intelligence plugins with language/binary table, external integrations, development workflows, output styles), demo marketplace walkthrough, adding marketplaces (GitHub/Git/local/URL sources), installing plugins (scopes, /plugin UI with Discover/Installed/Marketplaces/Errors tabs), managing plugins (enable/disable/uninstall, /reload-plugins), managing marketplaces (interactive UI, CLI commands, auto-updates with DISABLE_AUTOUPDATER and FORCE_AUTOUPDATE_PLUGINS), team marketplace config (extraKnownMarketplaces), security considerations, troubleshooting (/plugin not recognized, marketplace not loading, installation failures, code intelligence issues)
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) -- marketplace creation walkthrough, marketplace.json schema (required fields, owner, optional metadata with pluginRoot), plugin entries (required/optional fields, component configuration), plugin sources (relative paths, github, url, git-subdir, npm, pip with all pinning options), strict mode (true/false behavior and when to use each), hosting (GitHub/GitLab/Bitbucket, private repos with credential helpers and tokens per provider), team configuration (extraKnownMarketplaces, enabledPlugins), managed marketplace restrictions (strictKnownMarketplaces with hostPattern/pathPattern, how restrictions work), version resolution and release channels, validation and testing, troubleshooting (marketplace not loading, validation errors, installation failures, private repo auth, git timeouts, relative path issues, files not found)

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
