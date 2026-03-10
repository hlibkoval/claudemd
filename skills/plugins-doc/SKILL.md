---
name: plugins-doc
description: Complete documentation for Claude Code plugins -- creating plugins (manifest, skills, agents, hooks, MCP servers, LSP servers, settings.json), plugin directory structure, plugin.json schema (name, version, description, author, component paths, environment variables), discovering and installing plugins from marketplaces, plugin installation scopes (user, project, local, managed), managing installed plugins, creating and distributing plugin marketplaces (marketplace.json schema, plugin sources, strict mode, version management, release channels, managed marketplace restrictions), CLI commands (install, uninstall, enable, disable, update), official marketplace categories (code intelligence, external integrations, development workflows, output styles), plugin caching and file resolution, debugging and troubleshooting. Load when discussing plugin creation, plugin installation, plugin distribution, marketplace configuration, /plugin command, plugin.json, marketplace.json, LSP server setup, plugin scopes, or plugin development.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

Plugins are self-contained directories that extend Claude Code with custom skills, agents, hooks, MCP servers, and LSP servers. They can be shared via marketplaces, installed across projects, and versioned independently.

### When to Use Plugins vs Standalone Configuration

| Approach | Skill names | Best for |
|:---------|:------------|:---------|
| Standalone (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| Plugins (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with team, community distribution, cross-project reuse |

### Plugin Directory Structure

```
my-plugin/
  .claude-plugin/
    plugin.json          # Manifest (only file in this directory)
  commands/              # Skill markdown files (legacy; use skills/ for new)
  agents/                # Subagent markdown files
  skills/                # Skills with <name>/SKILL.md structure
  hooks/
    hooks.json           # Hook configuration
  .mcp.json              # MCP server definitions
  .lsp.json              # LSP server configurations
  settings.json          # Default settings (currently only "agent" key)
  scripts/               # Hook and utility scripts
```

Components go at the plugin root, never inside `.claude-plugin/`.

### Plugin Manifest (`plugin.json`)

**Required field**: `name` (kebab-case, no spaces) -- used as namespace for skills.

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique identifier and skill namespace prefix |
| `version` | string | Semantic version (`MAJOR.MINOR.PATCH`) |
| `description` | string | Shown in plugin manager |
| `author` | object | `{name, email?, url?}` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX license identifier |
| `keywords` | array | Discovery tags |
| `commands` | string/array | Additional command file/directory paths |
| `agents` | string/array | Additional agent file paths |
| `skills` | string/array | Additional skill directory paths |
| `hooks` | string/array/object | Hook config paths or inline config |
| `mcpServers` | string/array/object | MCP config paths or inline config |
| `lspServers` | string/array/object | LSP config paths or inline config |
| `outputStyles` | string/array | Output style paths |

Custom paths supplement default directories (they do not replace them). All paths must be relative and start with `./`.

### Environment Variable

`${CLAUDE_PLUGIN_ROOT}` -- absolute path to plugin directory. Use in hooks, MCP servers, and scripts for correct paths regardless of installation location.

### Plugin Components

**Skills**: directories under `skills/` containing `SKILL.md` with YAML frontmatter (`name`, `description`). Claude invokes automatically based on context.

**Agents**: markdown files in `agents/` with YAML frontmatter (`name`, `description`). Appear in `/agents` interface.

**Hooks**: configured in `hooks/hooks.json` or inline in `plugin.json`. Three hook types: `command` (shell), `prompt` (single-turn LLM), `agent` (multi-turn with tools).

**MCP servers**: configured in `.mcp.json` or inline in `plugin.json`. Start automatically when plugin is enabled.

**LSP servers**: configured in `.lsp.json` or inline in `plugin.json`. Require language server binary installed separately.

**Settings**: `settings.json` at plugin root. Currently supports only `agent` key to set a default agent.

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

| Required field | Description |
|:---------------|:------------|
| `command` | LSP binary to execute (must be in PATH) |
| `extensionToLanguage` | Maps file extensions to language identifiers |

Optional: `args`, `transport` (`stdio`/`socket`), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`.

### Hook Events (Plugin Context)

| Event | Hook types supported |
|:------|:--------------------|
| PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, Stop, SubagentStop, TaskCompleted, UserPromptSubmit | command, http, prompt, agent |
| SessionStart, SessionEnd, ConfigChange, InstructionsLoaded, Notification, PreCompact, SubagentStart, TeammateIdle, WorktreeCreate, WorktreeRemove | command only |

### Installation Scopes

| Scope | Settings file | Use case |
|:------|:-------------|:---------|
| `user` (default) | `~/.claude/settings.json` | Personal plugins, all projects |
| `project` | `.claude/settings.json` | Team plugins shared via VCS |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-deployed, read-only |

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude plugin install <plugin> [-s scope]` | Install from marketplace |
| `claude plugin uninstall <plugin> [-s scope]` | Remove (aliases: `remove`, `rm`) |
| `claude plugin enable <plugin> [-s scope]` | Enable a disabled plugin |
| `claude plugin disable <plugin> [-s scope]` | Disable without uninstalling |
| `claude plugin update <plugin> [-s scope]` | Update to latest version |
| `claude plugin validate .` | Validate plugin/marketplace JSON |
| `/plugin` | Interactive UI (Discover, Installed, Marketplaces, Errors tabs) |
| `/reload-plugins` | Reload plugins without restarting |

Plugin format: `plugin-name` or `plugin-name@marketplace-name`.

### Testing Plugins Locally

```bash
claude --plugin-dir ./my-plugin
# Load multiple:
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

### Plugin Caching

Marketplace plugins are copied to `~/.claude/plugins/cache`. Paths referencing files outside the plugin directory will not work after installation. Use symlinks for external dependencies (they are followed during copy).

### Marketplace Overview

A marketplace is a catalog (`marketplace.json`) listing plugins and where to find them.

**Official marketplace**: `claude-plugins-official` -- automatically available. Browse via `/plugin` Discover tab.

**Demo marketplace**: `anthropics/claude-code` -- add manually with `/plugin marketplace add anthropics/claude-code`.

### Marketplace Commands

| Command | Description |
|:--------|:------------|
| `/plugin marketplace add <source>` | Add from GitHub (`owner/repo`), git URL, local path, or URL |
| `/plugin marketplace list` | List all configured marketplaces |
| `/plugin marketplace update <name>` | Refresh plugin listings |
| `/plugin marketplace remove <name>` | Remove (also uninstalls its plugins) |

Shortcut: `/plugin market` instead of `/plugin marketplace`.

### Marketplace Sources

| Source type | Format | Notes |
|:------------|:-------|:------|
| GitHub | `owner/repo` | Most common |
| Git URL | `https://gitlab.com/company/plugins.git` | Any git host; append `#ref` for branch/tag |
| Local path | `./my-marketplace` | Directory with `.claude-plugin/marketplace.json` |
| Remote URL | `https://example.com/marketplace.json` | Relative-path plugins will not work |

### Marketplace Schema (`marketplace.json`)

Location: `.claude-plugin/marketplace.json` in repo root.

| Required field | Type | Description |
|:---------------|:-----|:------------|
| `name` | string | Marketplace identifier (kebab-case) |
| `owner` | object | `{name, email?}` |
| `plugins` | array | Plugin entries |

Optional: `metadata.description`, `metadata.version`, `metadata.pluginRoot` (base directory for relative source paths).

### Plugin Entry Fields (in marketplace.json)

| Required | Type | Description |
|:---------|:-----|:------------|
| `name` | string | Plugin identifier |
| `source` | string/object | Where to fetch the plugin |

Optional: `description`, `version`, `author`, `homepage`, `repository`, `license`, `keywords`, `category`, `tags`, `strict`, `commands`, `agents`, `hooks`, `mcpServers`, `lspServers`.

### Plugin Source Types (marketplace entries)

| Source | Type | Required fields |
|:-------|:-----|:----------------|
| Relative path | string (`"./plugins/my-plugin"`) | -- |
| `github` | object | `repo`; optional `ref`, `sha` |
| `url` | object | `url` (must end `.git`); optional `ref`, `sha` |
| `git-subdir` | object | `url`, `path`; optional `ref`, `sha` |
| `npm` | object | `package`; optional `version`, `registry` |
| `pip` | object | `package`; optional `version`, `registry` |

### Strict Mode

| Value | Behavior |
|:------|:---------|
| `true` (default) | `plugin.json` is the authority; marketplace entry supplements |
| `false` | Marketplace entry is the entire definition; `plugin.json` component fields cause conflict |

### Team Configuration

Add to `.claude/settings.json` for automatic marketplace prompts:

```json
{
  "extraKnownMarketplaces": {
    "company-tools": {
      "source": { "source": "github", "repo": "your-org/plugins" }
    }
  },
  "enabledPlugins": {
    "formatter@company-tools": true
  }
}
```

### Managed Marketplace Restrictions (`strictKnownMarketplaces`)

Set in managed settings to restrict which marketplaces users can add:

| Value | Behavior |
|:------|:---------|
| Undefined (default) | No restrictions |
| Empty `[]` | Complete lockdown |
| List of sources | Only matching marketplaces allowed |

Supports exact matching (`github`, `url`) and pattern matching (`hostPattern`, `pathPattern`).

### Auto-Updates

Official marketplaces: auto-update enabled by default. Third-party/local: disabled by default. Toggle per-marketplace via `/plugin` > Marketplaces. Environment variables: `DISABLE_AUTOUPDATER`, `FORCE_AUTOUPDATE_PLUGINS=true`.

### Version Management

Semantic versioning (`MAJOR.MINOR.PATCH`). Set version in `plugin.json` or `marketplace.json` (not both). Bumping the version triggers cache updates for users.

### Release Channels

Create separate marketplaces pointing to different refs (e.g., `stable` and `latest` branches) and assign to user groups via managed settings.

### Private Repositories

Manual install: uses existing git credential helpers. Auto-updates: requires environment tokens (`GITHUB_TOKEN`/`GH_TOKEN`, `GITLAB_TOKEN`/`GL_TOKEN`, `BITBUCKET_TOKEN`).

### Official Marketplace Categories

| Category | Examples |
|:---------|:---------|
| Code intelligence (LSP) | `pyright-lsp`, `typescript-lsp`, `rust-analyzer-lsp`, `gopls-lsp`, `clangd-lsp`, etc. |
| External integrations | `github`, `gitlab`, `atlassian`, `slack`, `figma`, `vercel`, `sentry`, etc. |
| Development workflows | `commit-commands`, `pr-review-toolkit`, `agent-sdk-dev`, `plugin-dev` |
| Output styles | `explanatory-output-style`, `learning-output-style` |

### Submitting to Official Marketplace

- Claude.ai: claude.ai/settings/plugins/submit
- Console: platform.claude.com/plugins/submit

### Common Debugging Steps

1. Run `claude --debug` or `/debug` to see plugin loading details
2. Validate JSON with `claude plugin validate .` or `/plugin validate`
3. Check that component directories are at plugin root, not inside `.claude-plugin/`
4. Verify scripts are executable (`chmod +x`)
5. Ensure all paths use `${CLAUDE_PLUGIN_ROOT}` variable
6. Check `/plugin` Errors tab for LSP/loading issues

### Git Timeout

Override with `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` (default 120s):

```bash
export CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS=300000  # 5 minutes
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) -- quickstart, plugin structure, adding skills/agents/hooks/MCP/LSP, settings.json, testing locally, debugging, sharing, converting standalone configs to plugins
- [Plugins reference](references/claude-code-plugins-reference.md) -- complete technical reference: plugin manifest schema, component specifications, installation scopes, CLI commands, debugging tools, version management, plugin caching
- [Discover and install plugins](references/claude-code-discover-plugins.md) -- official marketplace, adding marketplaces (GitHub, git, local, URL), installing/managing plugins, installation scopes, team marketplace configuration, auto-updates, security, troubleshooting
- [Create and distribute a marketplace](references/claude-code-plugin-marketplaces.md) -- marketplace.json schema, plugin sources (relative, GitHub, git, git-subdir, npm, pip), strict mode, hosting and distribution, managed marketplace restrictions, version resolution, release channels, validation, troubleshooting

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
