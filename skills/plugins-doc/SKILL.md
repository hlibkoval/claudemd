---
name: plugins-doc
description: Complete official documentation for Claude Code plugins — creating plugins (manifest schema, skills, agents, hooks, MCP/LSP servers, monitors, themes), discovering and installing plugins from marketplaces, creating and distributing plugin marketplaces, constraining plugin dependency versions, and recommending plugins from CLIs via the hint protocol.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

### Plugin vs Standalone Configuration

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific customizations, quick experiments |
| **Plugins** (directories with `.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teammates, distributing to community, versioned releases, reusable across projects |

### Plugin Directory Structure

| Directory | Location | Purpose |
| :--- | :--- | :--- |
| `.claude-plugin/` | Plugin root | Contains `plugin.json` manifest only |
| `skills/` | Plugin root | Skills as `<name>/SKILL.md` directories |
| `commands/` | Plugin root | Skills as flat Markdown files (use `skills/` for new plugins) |
| `agents/` | Plugin root | Custom agent definitions |
| `hooks/` | Plugin root | Event handlers in `hooks.json` |
| `.mcp.json` | Plugin root | MCP server configurations |
| `.lsp.json` | Plugin root | LSP server configurations |
| `monitors/` | Plugin root | Background monitor configurations in `monitors.json` |
| `bin/` | Plugin root | Executables added to the Bash tool's `PATH` |
| `themes/` | Plugin root | Color theme definitions |
| `settings.json` | Plugin root | Default settings applied when plugin is enabled |

**Common mistake**: Do NOT put `commands/`, `agents/`, `skills/`, or `hooks/` inside `.claude-plugin/`. Only `plugin.json` goes there.

### Plugin Manifest Schema (`plugin.json`)

**Required field** (only if manifest is present): `name`

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique identifier (kebab-case). Used as namespace prefix for skills |
| `displayName` | string | Human-readable name shown in UI (v2.1.143+) |
| `version` | string | Semantic version. If set, users only get updates when bumped. If omitted, git commit SHA is used |
| `description` | string | Brief plugin purpose |
| `author` | object | `{ name, email?, url? }` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier (e.g., `MIT`) |
| `keywords` | array | Discovery tags |
| `skills` | string\|array | Custom skill directories (adds to default `skills/`) |
| `commands` | string\|array | Custom flat `.md` skill files (replaces default `commands/`) |
| `agents` | string\|array | Custom agent files (replaces default `agents/`) |
| `hooks` | string\|array\|object | Hook config paths or inline config |
| `mcpServers` | string\|array\|object | MCP config paths or inline config |
| `lspServers` | string\|array\|object | LSP config paths or inline config |
| `experimental.themes` | string\|array | Color theme files/directories |
| `experimental.monitors` | string\|array | Background monitor configurations |
| `userConfig` | object | User-configurable values prompted at enable time |
| `channels` | array | Message channel declarations (Telegram, Slack, Discord style) |
| `dependencies` | array | Other plugins this plugin requires, with optional semver constraints |

The manifest is optional — Claude Code auto-discovers components in default locations and derives the plugin name from the directory name.

### Environment Variables for Plugin Paths

| Variable | Resolves to |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin's installation directory. Changes on plugin update |
| `${CLAUDE_PLUGIN_DATA}` | Persistent data directory that survives updates (`~/.claude/plugins/data/{id}/`) |
| `${CLAUDE_PROJECT_DIR}` | Project root directory |

### Plugin Installation Scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` | `~/.claude/settings.json` | Personal plugins across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific plugins, gitignored |
| `managed` | Managed settings | Admin-installed, read-only |

### CLI Commands Reference

| Command | Description |
| :--- | :--- |
| `claude plugin install <plugin>[@marketplace] [--scope user\|project\|local]` | Install a plugin |
| `claude plugin uninstall <plugin> [--keep-data] [--prune]` | Remove a plugin |
| `claude plugin enable <plugin>` | Enable a disabled plugin |
| `claude plugin disable <plugin>` | Disable without uninstalling |
| `claude plugin update <plugin>` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin details <name>` | Show components and projected token cost |
| `claude plugin tag [--push] [--dry-run]` | Create a release git tag |
| `claude plugin validate [path]` | Validate plugin or marketplace JSON |
| `claude plugin prune [--dry-run] [-y]` | Remove orphaned auto-installed dependencies |
| `claude plugin marketplace add <source>` | Add a marketplace |
| `claude plugin marketplace list` | List configured marketplaces |
| `claude plugin marketplace remove <name>` | Remove a marketplace (also uninstalls its plugins) |
| `claude plugin marketplace update [name]` | Refresh marketplace listings |

In-session equivalents use `/plugin` prefix (e.g., `/plugin install`, `/reload-plugins`).

### Testing Plugins Locally

```bash
# Load a plugin directory for the session
claude --plugin-dir ./my-plugin

# Load a zipped plugin (v2.1.128+)
claude --plugin-dir ./my-plugin.zip

# Load from a remote URL
claude --plugin-url https://example.com/my-plugin.zip

# Multiple plugins
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

After making changes, run `/reload-plugins` inside the session to pick up updates without restarting.

### Hook Events Available to Plugins

Plugin `hooks/hooks.json` supports the same lifecycle events as user-defined hooks:

| Event | When it fires |
| :--- | :--- |
| `SessionStart` | Session begins or resumes |
| `PreToolUse` | Before a tool call executes (can block) |
| `PostToolUse` | After a tool call succeeds |
| `Stop` | When Claude finishes responding |
| `UserPromptSubmit` | When a prompt is submitted |
| `FileChanged` | When a watched file changes on disk |
| `CwdChanged` | When working directory changes |
| `SubagentStart` / `SubagentStop` | When subagents spawn/finish |
| `SessionEnd` | When session terminates |
| (+ 20 more) | See reference doc for full list |

Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`

### Plugin Agents Frontmatter Fields

| Field | Description |
| :--- | :--- |
| `name` | Agent name |
| `description` | When Claude should invoke it |
| `model` | Model to use (e.g., `sonnet`) |
| `effort` | `low`, `medium`, `high` |
| `maxTurns` | Maximum conversation turns |
| `tools` | Allowed tools |
| `disallowedTools` | Blocked tools |
| `skills` | Skills to load |
| `memory` | Memory configuration |
| `background` | Background execution |
| `isolation` | `"worktree"` only valid value |

Note: `hooks`, `mcpServers`, and `permissionMode` are NOT supported in plugin-shipped agents for security reasons.

### LSP Server Configuration Fields

**Required:**

| Field | Description |
| :--- | :--- |
| `command` | LSP binary to execute (must be in PATH) |
| `extensionToLanguage` | Maps file extensions to language identifiers |

**Optional:** `args`, `transport` (`stdio`/`socket`), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`

### Background Monitors

Monitors run a shell command for the lifetime of a session and deliver each stdout line to Claude as a notification. Declared in `monitors/monitors.json` or inline in `plugin.json`.

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier within the plugin |
| `command` | Yes | Shell command run as persistent background process |
| `description` | Yes | Short summary of what is being watched |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

Requires Claude Code v2.1.105+.

### Version Management

Version is resolved from the first of these that is set:
1. `version` field in `plugin.json`
2. `version` field in the plugin's marketplace entry
3. Git commit SHA of the plugin's source
4. `unknown` for npm sources or local non-git directories

| Approach | How | Best for |
| :--- | :--- | :--- |
| **Explicit version** | Set `"version": "2.1.0"` in `plugin.json` | Published plugins with stable release cycles |
| **Commit-SHA version** | Omit `version` entirely | Internal or actively-developed plugins |

### Marketplace Structure

```json
{
  "name": "my-marketplace",
  "owner": { "name": "Your Name" },
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin",
      "description": "What it does",
      "version": "1.0.0"
    }
  ]
}
```

Place at `.claude-plugin/marketplace.json` in your repository root.

### Plugin Source Types (in marketplace.json)

| Source | Example | Notes |
| :--- | :--- | :--- |
| Relative path | `"./plugins/my-plugin"` | Must start with `./`. Only works with git-based marketplaces |
| `github` | `{ "source": "github", "repo": "owner/repo", "ref?": "v1.0", "sha?": "..." }` | |
| `url` | `{ "source": "url", "url": "https://gitlab.com/team/plugin.git", "ref?": "...", "sha?": "..." }` | Any git URL |
| `git-subdir` | `{ "source": "git-subdir", "url": "...", "path": "tools/plugin", "ref?": "...", "sha?": "..." }` | Sparse clone for monorepos |
| `npm` | `{ "source": "npm", "package": "@org/plugin", "version?": "2.1.0", "registry?": "..." }` | Via npm install |

### Plugin Dependency Version Constraints

Declare in `plugin.json` `dependencies` array:

```json
{
  "dependencies": [
    "unversioned-dep",
    { "name": "my-dep", "version": "~2.1.0" }
  ]
}
```

Tag releases as `{plugin-name}--v{version}` using `claude plugin tag --push`.

| Error | Meaning | Fix |
| :--- | :--- | :--- |
| `dependency-unsatisfied` | Dependency not installed or disabled | Run the install command shown in error |
| `range-conflict` | Constraints from multiple plugins can't be combined | Uninstall/update one conflicting plugin |
| `dependency-version-unsatisfied` | Installed version outside declared range | Re-run `claude plugin install <dep>@<marketplace>` |
| `no-matching-tag` | No `{name}--v*` tag satisfies the range | Check upstream tags or relax the range |

### Plugin Hint Protocol (for CLI maintainers)

Write a self-closing hint tag to stderr when your CLI detects `CLAUDECODE=1`:

```
<claude-code-hint v="1" type="plugin" value="your-plugin@claude-plugins-official" />
```

Requirements: tag must be on its own line; `value` must reference a plugin in an official Anthropic marketplace. Claude Code shows a one-time install prompt, then never prompts for that plugin again.

| Attribute | Required | Description |
| :--- | :--- | :--- |
| `v` | Yes | Protocol version. `1` is the only supported value |
| `type` | Yes | Hint kind. `plugin` is the only supported value |
| `value` | Yes | `name@marketplace` form |

### Official Marketplace Plugin Categories

| Category | Examples |
| :--- | :--- |
| Code intelligence (LSP) | `pyright-lsp`, `typescript-lsp`, `rust-analyzer-lsp`, `gopls-lsp`, `clangd-lsp`, `csharp-lsp`, `jdtls-lsp`, `kotlin-lsp`, `lua-lsp`, `php-lsp`, `swift-lsp` |
| External integrations | `github`, `gitlab`, `atlassian`, `asana`, `linear`, `notion`, `figma`, `vercel`, `firebase`, `supabase`, `slack`, `sentry` |
| Development workflows | `commit-commands`, `pr-review-toolkit`, `agent-sdk-dev`, `plugin-dev` |
| Output styles | `explanatory-output-style`, `learning-output-style` |

### Debugging Common Issues

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` |
| Skills not appearing | Wrong directory structure | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Script not executable | Run `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin paths |
| LSP `Executable not found in $PATH` | Language server not installed | Install the binary separately |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — plugin quickstart, manifest creation, adding skills/agents/hooks/MCP/LSP/monitors, testing locally, converting standalone configs to plugins, submitting to community marketplace
- [Plugins reference](references/claude-code-plugins-reference.md) — complete technical specs: all component schemas, manifest fields, environment variables, plugin caching and file resolution, directory structure, CLI commands, debugging tools, version management
- [Discover and install plugins](references/claude-code-discover-plugins.md) — browsing official and community marketplaces, installing plugins, managing scopes, adding marketplace sources (GitHub, git, local, URL), auto-updates, team marketplace configuration, security, troubleshooting
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace JSON schema, plugin source types, hosting on GitHub/git services, private repositories, pre-populating plugins for containers, managed marketplace restrictions, version resolution and release channels, validation and testing
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring version constraints in `plugin.json`, cross-marketplace dependencies, tagging releases for version resolution, how constraints interact and are combined, enabling/disabling plugins with dependencies, pruning orphaned dependencies
- [Recommend your plugin from your CLI](references/claude-code-plugin-hints.md) — the `claude-code-hint` tag protocol, emitting hints from Node.js/Python/Go/shell, hint format and requirements, what the user sees, getting a plugin into the official marketplace

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
- Recommend your plugin from your CLI: https://code.claude.com/docs/en/plugin-hints.md
