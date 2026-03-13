---
name: plugins-doc
description: Complete documentation for Claude Code plugins -- creating plugins (plugin manifest, plugin.json schema, quickstart, directory structure, components), plugin components (skills, agents, hooks, MCP servers, LSP servers, settings.json), plugin manifest schema (required/metadata/component path fields, environment variables, ${CLAUDE_PLUGIN_ROOT}), discovering and installing plugins (official marketplace, /plugin command, installation scopes user/project/local/managed, marketplace sources GitHub/GitLab/local/URL, auto-updates, /reload-plugins), managing plugins (enable/disable/uninstall, CLI commands plugin install/uninstall/enable/disable/update), plugin marketplaces (marketplace.json schema, plugin entries, plugin sources relative/github/url/git-subdir/npm/pip, strict mode, hosting and distribution, private repositories, managed marketplace restrictions strictKnownMarketplaces, version resolution, release channels, team marketplace configuration extraKnownMarketplaces/enabledPlugins), plugin caching and file resolution, LSP server configuration (.lsp.json, language server setup, code intelligence), debugging plugins (--debug, /plugin validate, common issues, hook/MCP troubleshooting), converting standalone configs to plugins, testing plugins locally (--plugin-dir flag, /reload-plugins), version management (semantic versioning), official marketplace plugins (code intelligence LSP plugins, external integrations, development workflows, output styles). Load when discussing Claude Code plugins, creating plugins, plugin.json, plugin manifests, plugin marketplaces, marketplace.json, discovering plugins, installing plugins, /plugin command, plugin scopes, plugin distribution, plugin development, plugin hooks, plugin MCP servers, plugin LSP servers, plugin skills, plugin agents, plugin settings, plugin caching, plugin debugging, plugin validation, plugin versioning, extraKnownMarketplaces, enabledPlugins, strictKnownMarketplaces, marketplace restrictions, --plugin-dir, /reload-plugins, plugin submission, or extending Claude Code with shared reusable extensions.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins -- creating, discovering, installing, distributing, and managing plugins and plugin marketplaces.

## Quick Reference

Plugins are self-contained directories that extend Claude Code with skills, agents, hooks, MCP servers, and LSP servers. They can be shared across projects and teams via marketplaces.

### When to Use Plugins vs Standalone Configuration

| Approach | Skill names | Best for |
|:---------|:------------|:---------|
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugins** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with team/community, reusable across projects, versioned releases |

### Plugin Directory Structure

```
my-plugin/
  .claude-plugin/
    plugin.json          # Manifest (only file in this dir)
  commands/              # Skill Markdown files (legacy)
  agents/                # Subagent Markdown files
  skills/                # Skills with <name>/SKILL.md structure
  hooks/
    hooks.json           # Hook configuration
  settings.json          # Default settings (currently only "agent" key)
  .mcp.json              # MCP server definitions
  .lsp.json              # LSP server configurations
  scripts/               # Hook and utility scripts
```

Components must be at the plugin root, NOT inside `.claude-plugin/`. Only `plugin.json` belongs in `.claude-plugin/`.

### Plugin Manifest (plugin.json)

**Required**: `name` (kebab-case, no spaces). Manifest is optional -- if omitted, Claude Code auto-discovers components in default locations.

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique identifier, used as skill namespace prefix |
| `version` | string | Semantic version (MAJOR.MINOR.PATCH) |
| `description` | string | Brief explanation of plugin purpose |
| `author` | object | `{name, email?, url?}` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX license identifier |
| `keywords` | array | Discovery tags |
| `commands` | string/array | Additional command files/directories |
| `agents` | string/array | Additional agent files |
| `skills` | string/array | Additional skill directories |
| `hooks` | string/array/object | Hook config paths or inline config |
| `mcpServers` | string/array/object | MCP config paths or inline config |
| `lspServers` | string/array/object | LSP server configs |
| `outputStyles` | string/array | Output style files/directories |

Custom paths supplement default directories -- they do not replace them. All paths must be relative and start with `./`.

### Environment Variables

`${CLAUDE_PLUGIN_ROOT}` -- absolute path to your plugin directory. Use in hooks, MCP servers, and scripts for portable paths.

### Plugin Components

**Skills**: `skills/<name>/SKILL.md` -- auto-discovered, Claude invokes based on context. See skills-doc for full details.

**Agents**: `agents/<name>.md` -- subagent definitions with frontmatter (name, description) and system prompt body. Appear in `/agents`.

**Hooks**: `hooks/hooks.json` or inline in plugin.json. Available events:

| Event | When |
|:------|:-----|
| `PreToolUse` | Before Claude uses a tool |
| `PostToolUse` | After successful tool use |
| `PostToolUseFailure` | After tool execution fails |
| `PermissionRequest` | Permission dialog shown |
| `UserPromptSubmit` | User submits a prompt |
| `Notification` | Claude Code sends notifications |
| `Stop` | Claude attempts to stop |
| `SubagentStart` / `SubagentStop` | Subagent lifecycle |
| `SessionStart` / `SessionEnd` | Session lifecycle |
| `TeammateIdle` | Agent team teammate about to go idle |
| `TaskCompleted` | Task being marked as completed |
| `PreCompact` | Before conversation history is compacted |

Hook types: `command` (shell), `prompt` (LLM eval), `agent` (agentic verifier with tools).

**MCP servers**: `.mcp.json` -- standard MCP server config, auto-start when plugin enabled.

**LSP servers**: `.lsp.json` -- language server config for code intelligence (diagnostics, go-to-definition, find references, hover info).

| Required LSP field | Description |
|:-------------------|:------------|
| `command` | LSP binary to execute (must be in PATH) |
| `extensionToLanguage` | Maps file extensions to language IDs |

Optional LSP fields: `args`, `transport` (stdio/socket), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`.

**Settings**: `settings.json` at plugin root. Currently only `agent` key is supported (activates a custom agent as main thread).

### Installation Scopes

| Scope | Settings file | Use case |
|:------|:-------------|:---------|
| `user` | `~/.claude/settings.json` | Personal plugins across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Read-only, update only |

### Plugin CLI Commands

| Command | Description |
|:--------|:------------|
| `claude plugin install <plugin> [-s scope]` | Install from marketplace |
| `claude plugin uninstall <plugin> [-s scope]` | Remove plugin (aliases: `remove`, `rm`) |
| `claude plugin enable <plugin> [-s scope]` | Enable a disabled plugin |
| `claude plugin disable <plugin> [-s scope]` | Disable without uninstalling |
| `claude plugin update <plugin> [-s scope]` | Update to latest version |
| `claude plugin validate .` | Validate plugin/marketplace JSON |

Interactive: `/plugin` opens tabbed UI with Discover, Installed, Marketplaces, and Errors tabs.

Plugin format: `plugin-name@marketplace-name` (e.g., `formatter@my-marketplace`).

### Marketplace Configuration

**marketplace.json** lives at `.claude-plugin/marketplace.json`. Required fields: `name`, `owner` (with `name`), `plugins` array.

Optional: `metadata.description`, `metadata.version`, `metadata.pluginRoot` (base directory for relative plugin sources).

### Plugin Sources in Marketplaces

| Source | Format | Notes |
|:-------|:-------|:------|
| Relative path | `"./plugins/my-plugin"` | Within marketplace repo, must start with `./` |
| GitHub | `{source: "github", repo: "owner/repo", ref?, sha?}` | |
| Git URL | `{source: "url", url: "https://...git", ref?, sha?}` | Any git host |
| Git subdirectory | `{source: "git-subdir", url, path, ref?, sha?}` | Sparse clone for monorepos |
| npm | `{source: "npm", package, version?, registry?}` | |
| pip | `{source: "pip", package, version?, registry?}` | |

### Strict Mode (Marketplace Plugin Entries)

| Value | Behavior |
|:------|:---------|
| `true` (default) | `plugin.json` is authority; marketplace entry supplements |
| `false` | Marketplace entry is entire definition; plugin.json components conflict |

### Adding Marketplaces

```
/plugin marketplace add owner/repo                    # GitHub
/plugin marketplace add https://gitlab.com/org/repo.git  # Any git
/plugin marketplace add ./local-dir                   # Local path
/plugin marketplace add https://example.com/marketplace.json  # URL
```

Append `#ref` to git URLs for specific branch/tag.

### Team Marketplace Configuration

In `.claude/settings.json`:

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

### Managed Marketplace Restrictions

`strictKnownMarketplaces` in managed settings controls which marketplaces users can add:

| Value | Behavior |
|:------|:---------|
| Undefined | No restrictions |
| Empty array `[]` | Complete lockdown |
| List of sources | Allowlist (exact match for github/url, regex for hostPattern/pathPattern) |

### Official Marketplace Plugins

| Category | Plugins |
|:---------|:--------|
| Code intelligence (LSP) | `clangd-lsp`, `csharp-lsp`, `gopls-lsp`, `jdtls-lsp`, `kotlin-lsp`, `lua-lsp`, `php-lsp`, `pyright-lsp`, `rust-analyzer-lsp`, `swift-lsp`, `typescript-lsp` |
| External integrations | `github`, `gitlab`, `atlassian`, `asana`, `linear`, `notion`, `figma`, `vercel`, `firebase`, `supabase`, `slack`, `sentry` |
| Development workflows | `commit-commands`, `pr-review-toolkit`, `agent-sdk-dev`, `plugin-dev` |
| Output styles | `explanatory-output-style`, `learning-output-style` |

### Testing and Debugging

Test locally with `--plugin-dir`:

```
claude --plugin-dir ./my-plugin
```

Local plugins override installed marketplace plugins of the same name (except managed force-enabled plugins). Use `/reload-plugins` to pick up changes without restarting. LSP changes require full restart.

Debug with `claude --debug` or `/debug` to see plugin loading details. Common issues:

| Issue | Solution |
|:------|:---------|
| Plugin not loading | Validate JSON with `claude plugin validate` |
| Commands not appearing | Ensure directories at plugin root, not in `.claude-plugin/` |
| Hooks not firing | `chmod +x` on scripts, verify event names are case-sensitive |
| MCP server fails | Use `${CLAUDE_PLUGIN_ROOT}` for all plugin paths |
| LSP not found | Install the language server binary (check `/plugin` Errors tab) |

### Auto-Updates

Official marketplaces auto-update by default. Toggle per-marketplace in `/plugin` > Marketplaces. Environment variables:

| Variable | Effect |
|:---------|:-------|
| `DISABLE_AUTOUPDATER` | Disable all auto-updates |
| `FORCE_AUTOUPDATE_PLUGINS=true` | Keep plugin auto-updates when `DISABLE_AUTOUPDATER` is set |
| `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` | Override 120s git timeout (milliseconds) |

### Plugin Caching

Marketplace plugins are copied to `~/.claude/plugins/cache`. Plugins cannot reference files outside their directory. Use symlinks for shared files (honored during copy).

### Submitting to Official Marketplace

- Claude.ai: claude.ai/settings/plugins/submit
- Console: platform.claude.com/plugins/submit

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) -- quickstart, plugin structure overview, adding skills/agents/hooks/MCP/LSP to plugins, shipping default settings, testing locally with --plugin-dir, debugging, sharing and submitting plugins, converting standalone configs to plugins, migration steps
- [Plugins reference](references/claude-code-plugins-reference.md) -- complete plugin manifest schema (required/metadata/component path fields), path behavior rules, environment variables, plugin components reference (skills, agents, hooks with event list and types, MCP servers, LSP servers with full config options), installation scopes, CLI commands reference (install/uninstall/enable/disable/update), plugin caching and file resolution, directory structure, debugging and development tools, common issues and error messages, hook/MCP/LSP troubleshooting, version management
- [Discover and install plugins](references/claude-code-discover-plugins.md) -- official Anthropic marketplace, code intelligence plugins (LSP per language), external integrations, development workflow plugins, output styles, adding marketplaces (GitHub/git/local/URL), installing plugins with scopes, managing installed plugins, /reload-plugins, marketplace management (list/update/remove), auto-updates configuration, team marketplace setup (extraKnownMarketplaces), security considerations, troubleshooting
- [Plugin marketplaces](references/claude-code-plugin-marketplaces.md) -- creating marketplace.json (schema, owner/metadata/plugin fields), plugin entries (required/optional fields, component configuration), plugin sources (relative/github/url/git-subdir/npm/pip with pinning), strict mode, hosting and distribution (GitHub/GitLab/private repos with auth tokens), team marketplace requirements, managed marketplace restrictions (strictKnownMarketplaces with hostPattern/pathPattern), version resolution and release channels, validation and testing, troubleshooting

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Plugin marketplaces: https://code.claude.com/docs/en/plugin-marketplaces.md
