---
name: plugins-doc
description: Complete documentation for Claude Code plugins -- creating plugins (manifest, skills, agents, hooks, MCP servers, LSP servers, settings.json), plugin directory structure, plugin.json schema (name, version, description, author, homepage, repository, license, keywords, component paths), environment variables (CLAUDE_PLUGIN_ROOT), testing with --plugin-dir, /reload-plugins, converting standalone .claude/ configs to plugins, plugin installation scopes (user, project, local, managed), CLI commands (install, uninstall, enable, disable, update), discovering and installing plugins from marketplaces, official Anthropic marketplace, code intelligence LSP plugins (pyright, typescript, rust-analyzer, clangd, gopls, etc.), external integration plugins (GitHub, Slack, Linear, Figma, Sentry, etc.), marketplace management (/plugin marketplace add/update/remove/list), marketplace sources (GitHub, git URL, local path, remote URL), creating and distributing marketplaces, marketplace.json schema (name, owner, plugins, metadata.pluginRoot, plugin sources: relative path, github, url, git-subdir, npm, pip), strict mode, version resolution and release channels, managed marketplace restrictions (strictKnownMarketplaces, hostPattern, pathPattern), plugin caching and file resolution, auto-updates, team marketplace configuration (extraKnownMarketplaces, enabledPlugins), debugging and validation (claude plugin validate, claude --debug, /plugin Errors tab). Load when discussing plugins, plugin development, plugin installation, plugin marketplaces, distributing plugins, LSP integration, or the /plugin command.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for creating, installing, distributing, and managing Claude Code plugins.

## Quick Reference

Plugins extend Claude Code with skills, agents, hooks, MCP servers, and LSP servers. They are self-contained directories distributed through marketplaces.

### Plugin vs Standalone

| Approach | Skill names | Best for |
|:---------|:------------|:---------|
| Standalone (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| Plugins (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teams, community distribution, reusable across projects |

### Plugin Directory Structure

```
my-plugin/
  .claude-plugin/
    plugin.json           # Manifest (only file in this dir)
  commands/               # Skill Markdown files (legacy)
  skills/                 # Skills with SKILL.md structure
    my-skill/
      SKILL.md
  agents/                 # Subagent Markdown files
  hooks/
    hooks.json            # Hook configuration
  settings.json           # Default settings (currently only "agent" key)
  .mcp.json               # MCP server definitions
  .lsp.json               # LSP server configurations
  scripts/                # Hook and utility scripts
```

All component directories go at the plugin root -- never inside `.claude-plugin/`.

### Plugin Manifest (`plugin.json`)

Only `name` is required if you include a manifest. The manifest itself is optional (Claude Code auto-discovers components in default locations).

| Field | Type | Required | Description |
|:------|:-----|:---------|:------------|
| `name` | string | Yes | Unique identifier (kebab-case), used as skill namespace |
| `version` | string | No | Semantic version (MAJOR.MINOR.PATCH) |
| `description` | string | No | Shown in plugin manager |
| `author` | object | No | `{name, email, url}` |
| `homepage` | string | No | Documentation URL |
| `repository` | string | No | Source code URL |
| `license` | string | No | SPDX identifier |
| `keywords` | array | No | Discovery tags |
| `commands` | string/array | No | Additional command paths |
| `agents` | string/array | No | Additional agent paths |
| `skills` | string/array | No | Additional skill paths |
| `hooks` | string/array/object | No | Hook config paths or inline |
| `mcpServers` | string/array/object | No | MCP config paths or inline |
| `lspServers` | string/array/object | No | LSP config paths or inline |
| `outputStyles` | string/array | No | Output style paths |

Custom paths supplement default directories (they do not replace them). All paths must be relative and start with `./`.

### Environment Variables

`${CLAUDE_PLUGIN_ROOT}` -- absolute path to the plugin directory. Use in hooks, MCP servers, and scripts to ensure correct paths regardless of installation location.

### Hook Configuration in Plugins

Place hooks in `hooks/hooks.json` (same format as settings.json hooks). The command receives hook input as JSON on stdin.

Available events: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `UserPromptSubmit`, `Notification`, `Stop`, `SubagentStart`, `SubagentStop`, `SessionStart`, `SessionEnd`, `TeammateIdle`, `TaskCompleted`, `PreCompact`.

Hook types: `command` (shell), `prompt` (LLM evaluation), `agent` (agentic verifier).

### LSP Server Configuration

LSP plugins provide code intelligence (diagnostics, go-to-definition, find references, hover info).

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": { ".go": "go" }
  }
}
```

Required fields: `command`, `extensionToLanguage`. Optional: `args`, `transport` (`stdio`/`socket`), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`.

Users must install the language server binary separately.

### Default Settings (`settings.json`)

Plugins can ship a `settings.json` at the plugin root. Currently only the `agent` key is supported, which activates a plugin agent as the main thread:

```json
{ "agent": "security-reviewer" }
```

### Testing Plugins

```bash
# Load plugin during development
claude --plugin-dir ./my-plugin

# Load multiple plugins
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

Use `/reload-plugins` to pick up changes without restarting (LSP changes still require restart).

### Converting Standalone to Plugin

1. Create `my-plugin/.claude-plugin/plugin.json` with name/description/version
2. Copy `commands/`, `agents/`, `skills/` from `.claude/` to plugin root
3. Move hooks from `settings.json` to `hooks/hooks.json`
4. Test with `claude --plugin-dir ./my-plugin`

---

## Installing and Managing Plugins

### Installation Scopes

| Scope | Settings file | Use case |
|:------|:-------------|:---------|
| `user` (default) | `~/.claude/settings.json` | Personal, all projects |
| `project` | `.claude/settings.json` | Team-shared via VCS |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-deployed, read-only |

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude plugin install <plugin> [-s scope]` | Install from marketplace |
| `claude plugin uninstall <plugin> [-s scope]` | Remove plugin (aliases: `remove`, `rm`) |
| `claude plugin enable <plugin> [-s scope]` | Enable a disabled plugin |
| `claude plugin disable <plugin> [-s scope]` | Disable without uninstalling |
| `claude plugin update <plugin> [-s scope]` | Update to latest version |
| `claude plugin validate .` | Validate plugin/marketplace JSON |

Install format: `plugin-name@marketplace-name` (e.g., `formatter@my-marketplace`).

### Interactive UI (`/plugin`)

Tabs: **Discover** (browse available), **Installed** (manage installed), **Marketplaces** (add/remove/update), **Errors** (loading errors). Cycle with Tab/Shift+Tab.

### Official Marketplace Plugins

**Code intelligence (LSP):**

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

**External integrations:** `github`, `gitlab`, `atlassian`, `asana`, `linear`, `notion`, `figma`, `vercel`, `firebase`, `supabase`, `slack`, `sentry`.

**Development workflows:** `commit-commands`, `pr-review-toolkit`, `agent-sdk-dev`, `plugin-dev`.

### Applying Changes

Use `/reload-plugins` after install/enable/disable to activate changes without restarting. LSP server changes require a full restart.

---

## Marketplaces

A marketplace is a catalog of plugins defined in `.claude-plugin/marketplace.json`.

### Adding Marketplaces

| Source | Command |
|:-------|:--------|
| GitHub repo | `/plugin marketplace add owner/repo` |
| Git URL | `/plugin marketplace add https://gitlab.com/company/plugins.git` |
| Git URL with ref | `/plugin marketplace add https://gitlab.com/company/plugins.git#v1.0.0` |
| Local path | `/plugin marketplace add ./my-marketplace` |
| Remote URL | `/plugin marketplace add https://example.com/marketplace.json` |

Shortcuts: `/plugin market` = `/plugin marketplace`; `rm` = `remove`.

### Marketplace Management

| Command | Description |
|:--------|:------------|
| `/plugin marketplace list` | List configured marketplaces |
| `/plugin marketplace update <name>` | Refresh plugin listings |
| `/plugin marketplace remove <name>` | Remove marketplace (uninstalls its plugins) |

### Auto-Updates

Official marketplaces auto-update by default. Toggle per-marketplace via `/plugin` > Marketplaces > choose marketplace > Enable/Disable auto-update. Environment variables: `DISABLE_AUTOUPDATER` (disables all updates), `FORCE_AUTOUPDATE_PLUGINS=true` (keep plugin updates when Claude Code updates are disabled).

### Creating a Marketplace

`marketplace.json` required fields:

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Marketplace identifier (kebab-case), shown in install commands |
| `owner` | object | `{name, email?}` |
| `plugins` | array | Plugin entries |

Optional: `metadata.description`, `metadata.version`, `metadata.pluginRoot` (base directory for relative source paths).

### Plugin Entry Fields

Required: `name`, `source`. Optional: `description`, `version`, `author`, `homepage`, `repository`, `license`, `keywords`, `category`, `tags`, `strict`, `commands`, `agents`, `hooks`, `mcpServers`, `lspServers`.

### Plugin Sources

| Source | Format | Notes |
|:-------|:-------|:------|
| Relative path | `"./plugins/my-plugin"` | Local directory in marketplace repo |
| `github` | `{source: "github", repo, ref?, sha?}` | GitHub repository |
| `url` | `{source: "url", url, ref?, sha?}` | Any git repo (URL must end `.git`) |
| `git-subdir` | `{source: "git-subdir", url, path, ref?, sha?}` | Subdirectory in a git repo (sparse clone) |
| `npm` | `{source: "npm", package, version?, registry?}` | npm package |
| `pip` | `{source: "pip", package, version?, registry?}` | pip package |

### Strict Mode

| Value | Behavior |
|:------|:---------|
| `true` (default) | `plugin.json` is authoritative; marketplace entry supplements |
| `false` | Marketplace entry is the entire definition; `plugin.json` components cause conflict |

### Team Marketplace Configuration

Add to `.claude/settings.json` for automatic prompting:

```json
{
  "extraKnownMarketplaces": {
    "company-tools": {
      "source": { "source": "github", "repo": "your-org/claude-plugins" }
    }
  },
  "enabledPlugins": {
    "formatter@company-tools": true
  }
}
```

### Managed Marketplace Restrictions (`strictKnownMarketplaces`)

Set in managed settings. Values:

| Value | Behavior |
|:------|:---------|
| Undefined | No restrictions |
| Empty `[]` | Complete lockdown |
| List of sources | Only matching marketplaces allowed |

Source types: `{source: "github", repo, ref?, path?}`, `{source: "url", url}`, `{source: "hostPattern", hostPattern}` (regex on host), `{source: "pathPattern", pathPattern}` (regex on filesystem path).

### Version Resolution

Set version in `plugin.json` or `marketplace.json` (not both -- `plugin.json` wins silently). For release channels, use two marketplaces pinned to different refs with different versions in `plugin.json` at each ref.

---

## Plugin Caching

Marketplace plugins are copied to `~/.claude/plugins/cache`. Plugins cannot reference files outside their directory (paths like `../shared` break after install). Use symlinks for shared files -- they are followed during the copy.

## Debugging

| Tool | Purpose |
|:-----|:--------|
| `claude --debug` or `/debug` | See plugin loading details, errors, registration |
| `claude plugin validate .` or `/plugin validate .` | Validate plugin/marketplace JSON |
| `/plugin` Errors tab | View plugin loading errors |

### Common Issues

| Issue | Solution |
|:------|:---------|
| Plugin not loading | Validate JSON syntax with `claude plugin validate` |
| Commands not appearing | Ensure `commands/` at root, not in `.claude-plugin/` |
| Hooks not firing | Run `chmod +x script.sh`; verify event name (case-sensitive) |
| MCP server fails | Use `${CLAUDE_PLUGIN_ROOT}` for all paths |
| LSP binary not found | Install the language server binary separately |
| Files not found after install | Use symlinks for external dependencies |
| Git operations timeout | Set `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` (ms) |
| Skills not appearing after install | Clear cache: `rm -rf ~/.claude/plugins/cache`, restart, reinstall |

### Submitting to Official Marketplace

Use the in-app submission forms:
- Claude.ai: `claude.ai/settings/plugins/submit`
- Console: `platform.claude.com/plugins/submit`

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) -- creating plugins with skills, agents, hooks, MCP servers, LSP servers; plugin structure; quickstart; testing with --plugin-dir; converting standalone configs; sharing and submitting plugins
- [Plugins reference](references/claude-code-plugins-reference.md) -- complete technical specs: plugin manifest schema, component schemas (skills, agents, hooks, MCP, LSP), installation scopes, CLI commands, environment variables, caching and file resolution, directory structure, debugging, version management
- [Discover and install plugins](references/claude-code-discover-plugins.md) -- finding and installing plugins from marketplaces; official marketplace categories (code intelligence, external integrations, development workflows, output styles); adding marketplaces (GitHub, git, local, URL); managing installed plugins; team marketplace configuration; auto-updates; troubleshooting
- [Plugin marketplaces](references/claude-code-plugin-marketplaces.md) -- creating and distributing marketplaces; marketplace.json schema; plugin sources (relative, github, url, git-subdir, npm, pip); strict mode; hosting and distribution; private repositories; managed marketplace restrictions (strictKnownMarketplaces); version resolution and release channels; validation and testing

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Plugin marketplaces: https://code.claude.com/docs/en/plugin-marketplaces.md
