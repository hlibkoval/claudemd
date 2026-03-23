---
name: plugins-doc
description: Complete documentation for Claude Code plugins -- creating, distributing, discovering, and installing plugin extensions. Covers plugin manifest schema (.claude-plugin/plugin.json with name, version, description, author, homepage, repository, license, keywords, component paths), plugin directory structure (commands/, agents/, skills/, hooks/, .mcp.json, .lsp.json, settings.json), all plugin components (skills with SKILL.md, agents with frontmatter, hooks via hooks.json or inline, MCP servers via .mcp.json, LSP servers via .lsp.json, settings.json for default agent), environment variables (${CLAUDE_PLUGIN_ROOT}, ${CLAUDE_PLUGIN_DATA}), persistent data directory pattern, plugin caching and file resolution, installation scopes (user, project, local, managed), CLI commands (plugin install/uninstall/enable/disable/update with --scope and --keep-data flags), /plugin TUI with Discover/Installed/Marketplaces/Errors tabs, /reload-plugins, --plugin-dir for local testing, plugin validate, marketplace schema (marketplace.json with name, owner, plugins array, metadata.pluginRoot), plugin sources (relative path, github, url, git-subdir, npm), strict mode, marketplace hosting (GitHub, GitLab, private repos with token auth), auto-updates (DISABLE_AUTOUPDATER, FORCE_AUTOUPDATE_PLUGINS), team marketplace configuration (extraKnownMarketplaces, enabledPlugins in .claude/settings.json), managed marketplace restrictions (strictKnownMarketplaces with hostPattern and pathPattern), version management (semver, release channels with ref pinning), plugin seed directories (CLAUDE_CODE_PLUGIN_SEED_DIR for containers), official Anthropic marketplace (claude-plugins-official with LSP plugins, external integrations, dev workflows, output styles), converting standalone .claude/ configs to plugins, debugging (claude --debug, /plugin validate, common issues), hook types (command, http, prompt, agent), LSP configuration fields (command, extensionToLanguage, transport, initializationOptions, settings), code intelligence plugins (pyright-lsp, typescript-lsp, rust-analyzer-lsp, clangd-lsp, gopls-lsp, and more). Load when discussing plugins, plugin development, plugin installation, plugin marketplaces, marketplace creation, plugin distribution, plugin manifest, plugin.json, marketplace.json, /plugin command, plugin scopes, plugin sources, npm plugin source, git-subdir, strict mode, plugin caching, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, plugin auto-updates, extraKnownMarketplaces, enabledPlugins, strictKnownMarketplaces, plugin seed directory, LSP plugins, code intelligence plugins, plugin hooks, plugin MCP servers, plugin validation, plugin debugging, converting to plugins, --plugin-dir, /reload-plugins, plugin settings.json, plugin version management, release channels, or extending Claude Code with custom functionality.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins -- the extension system for packaging and distributing skills, agents, hooks, MCP servers, and LSP servers.

## Quick Reference

Plugins are self-contained directories that extend Claude Code with custom functionality. They bundle components (skills, agents, hooks, MCP/LSP servers) under a namespace and can be shared via marketplaces.

### When to Use Plugins vs Standalone

| Approach | Skill names | Best for |
|:---------|:------------|:---------|
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific customizations, quick experiments |
| **Plugins** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teammates, distributing to community, versioned releases, reusable across projects |

### Plugin Directory Structure

```
my-plugin/
  .claude-plugin/
    plugin.json            # Manifest (only file in this directory)
  commands/                # Skill Markdown files (legacy; use skills/ for new)
  agents/                  # Subagent Markdown files
  skills/                  # Skills with <name>/SKILL.md structure
  hooks/
    hooks.json             # Hook configuration
  .mcp.json                # MCP server definitions
  .lsp.json                # LSP server configurations
  settings.json            # Default settings (currently only "agent" key)
  scripts/                 # Hook and utility scripts
```

All component directories go at the plugin root, NOT inside `.claude-plugin/`.

### Plugin Manifest Schema (plugin.json)

**Required:** `name` (kebab-case, no spaces) -- used as namespace prefix for components.

**Metadata fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique identifier and skill namespace |
| `version` | string | Semantic version (MAJOR.MINOR.PATCH) |
| `description` | string | Brief plugin description |
| `author` | object | `{name, email?, url?}` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier (MIT, Apache-2.0, etc.) |
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
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin installation directory; changes on update |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state; survives updates (`~/.claude/plugins/data/{id}/`) |

Both are substituted inline in skill content, agent content, hook commands, and MCP/LSP configs, and exported as environment variables to subprocesses.

**Persistent data pattern** -- install dependencies once, reinstall when manifest changes:

```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "diff -q \"${CLAUDE_PLUGIN_ROOT}/package.json\" \"${CLAUDE_PLUGIN_DATA}/package.json\" >/dev/null 2>&1 || (cd \"${CLAUDE_PLUGIN_DATA}\" && cp \"${CLAUDE_PLUGIN_ROOT}/package.json\" . && npm install) || rm -f \"${CLAUDE_PLUGIN_DATA}/package.json\""
      }]
    }]
  }
}
```

### Plugin Components

**Skills:** directories with `SKILL.md` in `skills/`; support frontmatter with `name`, `description`.

**Agents:** Markdown files in `agents/` with frontmatter supporting `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation` (only `"worktree"`). Plugin agents do NOT support `hooks`, `mcpServers`, or `permissionMode`.

**Hooks:** defined in `hooks/hooks.json` or inline in `plugin.json`. Same format as user-defined hooks. Four types: `command`, `http`, `prompt`, `agent`.

**Hook events:** SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, Stop, StopFailure, TeammateIdle, TaskCompleted, InstructionsLoaded, ConfigChange, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd.

**MCP servers:** defined in `.mcp.json` or inline in `plugin.json`; start automatically when plugin is enabled.

**LSP servers:** defined in `.lsp.json` or inline in `plugin.json`. Required fields: `command`, `extensionToLanguage`. Optional: `args`, `transport` (stdio/socket), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`.

**Settings:** `settings.json` at plugin root. Currently only supports `"agent"` key to activate a plugin agent as the main thread.

### Installation Scopes

| Scope | Settings file | Use case |
|:------|:-------------|:---------|
| `user` | `~/.claude/settings.json` | Personal plugins across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled (read-only, update only) |

### CLI Commands

| Command | Description | Key options |
|:--------|:------------|:------------|
| `claude plugin install <plugin>` | Install from marketplace | `-s, --scope` (user/project/local) |
| `claude plugin uninstall <plugin>` | Remove plugin (aliases: `remove`, `rm`) | `-s, --scope`, `--keep-data` |
| `claude plugin enable <plugin>` | Enable a disabled plugin | `-s, --scope` |
| `claude plugin disable <plugin>` | Disable without uninstalling | `-s, --scope` |
| `claude plugin update <plugin>` | Update to latest version | `-s, --scope` (user/project/local/managed) |
| `claude plugin validate .` | Check plugin.json, frontmatter, hooks.json | |

Plugin argument format: `plugin-name` or `plugin-name@marketplace-name`.

### Interactive Plugin Management

`/plugin` opens a TUI with four tabs (cycle with Tab/Shift+Tab):
- **Discover** -- browse available plugins from all marketplaces
- **Installed** -- view/manage installed plugins grouped by scope
- **Marketplaces** -- add, remove, update marketplaces
- **Errors** -- view plugin loading errors

`/reload-plugins` reloads all active plugins without restarting (plugins, skills, agents, hooks, MCP servers, LSP servers).

### Local Testing

```bash
claude --plugin-dir ./my-plugin
```

Local `--plugin-dir` plugins with the same name as installed marketplace plugins take precedence (except managed force-enabled plugins). Load multiple plugins:

```bash
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

### Marketplace Schema (marketplace.json)

Location: `.claude-plugin/marketplace.json` in repository root.

**Required fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Marketplace identifier (kebab-case); used in install commands |
| `owner` | object | `{name (required), email?}` |
| `plugins` | array | List of plugin entries |

**Optional:** `metadata.description`, `metadata.version`, `metadata.pluginRoot` (base directory for relative source paths).

**Plugin entry required fields:** `name`, `source`.

**Plugin entry optional fields:** `description`, `version`, `author`, `homepage`, `repository`, `license`, `keywords`, `category`, `tags`, `strict`, plus component config fields (`commands`, `agents`, `hooks`, `mcpServers`, `lspServers`).

### Plugin Sources

| Source | Format | Required fields |
|:-------|:-------|:----------------|
| Relative path | `"./plugins/my-plugin"` | none (must start with `./`) |
| GitHub | `{source: "github", repo: "owner/repo"}` | `repo`; optional `ref`, `sha` |
| Git URL | `{source: "url", url: "https://..."}` | `url`; optional `ref`, `sha` |
| Git subdirectory | `{source: "git-subdir", url: "...", path: "..."}` | `url`, `path`; optional `ref`, `sha` |
| npm | `{source: "npm", package: "@org/plugin"}` | `package`; optional `version`, `registry` |

Relative paths only work with Git-based marketplaces (not URL-based).

### Strict Mode

| Value | Behavior |
|:------|:---------|
| `true` (default) | `plugin.json` is authority; marketplace entry supplements |
| `false` | Marketplace entry is entire definition; `plugin.json` must not declare components |

### Adding Marketplaces

```
/plugin marketplace add owner/repo                    # GitHub
/plugin marketplace add https://gitlab.com/co/repo.git  # Git URL
/plugin marketplace add ./my-marketplace               # Local path
/plugin marketplace add https://example.com/mkt.json   # Remote URL
```

Append `#ref` for specific branch/tag: `/plugin marketplace add https://gitlab.com/co/repo.git#v1.0.0`

### Auto-Updates

Official marketplaces auto-update by default; third-party/local do not. Toggle per-marketplace via `/plugin` > Marketplaces.

| Env variable | Effect |
|:-------------|:-------|
| `DISABLE_AUTOUPDATER` | Disables all auto-updates (Claude Code + plugins) |
| `FORCE_AUTOUPDATE_PLUGINS=true` | Keeps plugin auto-updates when DISABLE_AUTOUPDATER is set |

Private repo auto-updates require token env vars: `GITHUB_TOKEN`/`GH_TOKEN`, `GITLAB_TOKEN`/`GL_TOKEN`, `BITBUCKET_TOKEN`.

### Team Marketplace Configuration

In `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "company-tools": {
      "source": { "source": "github", "repo": "your-org/claude-plugins" }
    }
  },
  "enabledPlugins": {
    "formatter@company-tools": true,
    "deploy-tools@company-tools": true
  }
}
```

### Managed Marketplace Restrictions (strictKnownMarketplaces)

Set in managed settings to control which marketplaces users can add:

| Value | Behavior |
|:------|:---------|
| Undefined | No restrictions |
| `[]` | Complete lockdown |
| List of sources | Allowlist only |

Supports source types: `github` (with `repo`, optional `ref`/`path`), `url`, `hostPattern` (regex on host), `pathPattern` (regex on filesystem path).

### Plugin Seed Directory (Containers)

Set `CLAUDE_CODE_PLUGIN_SEED_DIR` to pre-populate plugins in container images. Mirrors `~/.claude/plugins` structure (`known_marketplaces.json`, `marketplaces/`, `cache/`). Read-only; auto-updates disabled. Separate multiple paths with `:` (Unix) or `;` (Windows).

### Official Marketplace Plugins

The `claude-plugins-official` marketplace is available by default. Categories:

**Code intelligence (LSP):** clangd-lsp, csharp-lsp, gopls-lsp, jdtls-lsp, kotlin-lsp, lua-lsp, php-lsp, pyright-lsp, rust-analyzer-lsp, swift-lsp, typescript-lsp. Require language server binary installed separately.

**External integrations:** github, gitlab, atlassian, asana, linear, notion, figma, vercel, firebase, supabase, slack, sentry.

**Development workflows:** commit-commands, pr-review-toolkit, agent-sdk-dev, plugin-dev.

**Output styles:** explanatory-output-style, learning-output-style.

### Plugin Caching

Marketplace plugins are copied to `~/.claude/plugins/cache`. Paths referencing files outside the plugin directory (e.g., `../shared-utils`) will not work. Use symlinks for shared files -- they are followed during the copy.

### Debugging

| Tool | Purpose |
|:-----|:--------|
| `claude --debug` | Plugin loading details, errors, registration |
| `/plugin validate` | Check plugin.json, frontmatter, hooks.json |
| `/plugin` > Errors tab | View plugin loading errors |

**Common issues:**

| Issue | Solution |
|:------|:---------|
| Plugin not loading | Run `/plugin validate`; check `plugin.json` syntax |
| Commands not appearing | Ensure `commands/` at plugin root, not in `.claude-plugin/` |
| Hooks not firing | `chmod +x script.sh`; check event name case; verify matcher |
| MCP server fails | Use `${CLAUDE_PLUGIN_ROOT}` for all plugin paths |
| LSP executable not found | Install the language server binary |
| Git operations timeout | Set `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` (milliseconds, default 120000) |

### Version Management

Semantic versioning (MAJOR.MINOR.PATCH). Set version in `plugin.json` or `marketplace.json` (plugin.json takes priority if both set). Bumping the version is required for users to receive updates due to caching.

For release channels, create separate marketplaces pointing to different `ref` values of the same repo (e.g., `stable` vs `latest` branches).

### Converting Standalone to Plugin

1. Create `my-plugin/.claude-plugin/plugin.json` with `name`, `description`, `version`
2. Copy `.claude/commands/` to `my-plugin/commands/`
3. Copy `.claude/agents/` to `my-plugin/agents/`
4. Copy `.claude/skills/` to `my-plugin/skills/`
5. Move hooks from `settings.json` to `my-plugin/hooks/hooks.json`
6. Test with `claude --plugin-dir ./my-plugin`

### Submitting to Official Marketplace

Use the in-app submission forms:
- Claude.ai: claude.ai/settings/plugins/submit
- Console: platform.claude.com/plugins/submit

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) -- quickstart guide, plugin structure overview, creating skills/agents/hooks/MCP/LSP in plugins, settings.json for default agent, local testing with --plugin-dir, debugging, sharing, converting standalone configs to plugins, submitting to official marketplace
- [Plugins reference](references/claude-code-plugins-reference.md) -- complete technical specifications: plugin manifest schema (all fields), component schemas (skills, agents, hooks, MCP servers, LSP servers), installation scopes, environment variables (CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA), persistent data directory pattern, plugin caching and file resolution, plugin directory structure and file locations, CLI commands reference (install/uninstall/enable/disable/update with all options), debugging and development tools, common issues and error messages, hook/MCP/LSP troubleshooting, version management
- [Discover and install plugins](references/claude-code-discover-plugins.md) -- marketplace concepts, official Anthropic marketplace (LSP plugins, external integrations, dev workflows, output styles), adding marketplaces (GitHub, Git URL, local path, remote URL), installing plugins with scopes, managing installed plugins, /plugin TUI, /reload-plugins, marketplace management, auto-updates (DISABLE_AUTOUPDATER, FORCE_AUTOUPDATE_PLUGINS), team marketplace configuration (extraKnownMarketplaces, enabledPlugins), security considerations, troubleshooting, code intelligence features
- [Plugin marketplaces](references/claude-code-plugin-marketplaces.md) -- creating and distributing marketplaces, marketplace.json schema (name, owner, plugins, metadata.pluginRoot), plugin entries (all fields, component config), plugin sources (relative path, github, url, git-subdir, npm with all options), strict mode, hosting (GitHub, GitLab, private repos with token auth), team configuration, managed marketplace restrictions (strictKnownMarketplaces with hostPattern/pathPattern), plugin seed directory (CLAUDE_CODE_PLUGIN_SEED_DIR for containers), version resolution and release channels, validation and testing, troubleshooting

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Plugin marketplaces: https://code.claude.com/docs/en/plugin-marketplaces.md
