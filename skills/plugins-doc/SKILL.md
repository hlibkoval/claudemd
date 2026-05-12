---
name: plugins-doc
description: Complete official documentation for Claude Code plugins — creating plugins, plugin manifest schema, components (skills, agents, hooks, MCP servers, LSP servers, monitors, themes), plugin installation scopes, discovering and installing plugins, marketplace creation and distribution, plugin dependency version constraints, CLI commands, debugging, and environment variables.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

### Standalone vs. Plugin

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/`) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugin** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with team, distributing to community, reuse across projects |

### Plugin Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Manifest (optional; only file that goes here)
├── skills/                  # Skills as <name>/SKILL.md
├── commands/                # Skills as flat .md files (legacy)
├── agents/                  # Subagent definitions
├── hooks/
│   └── hooks.json
├── bin/                     # Executables added to Bash tool PATH
├── monitors/
│   └── monitors.json
├── themes/                  # Color themes
├── output-styles/
├── settings.json            # Default settings (agent/subagentStatusLine only)
├── .mcp.json
└── .lsp.json
```

Only `plugin.json` goes inside `.claude-plugin/`. All other directories must be at the plugin root.

### Plugin Manifest Schema (`plugin.json`)

`name` is the only required field when a manifest is present. The manifest itself is optional — Claude Code auto-discovers components in default locations and derives the plugin name from the directory.

**Metadata fields:**

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Required. Unique kebab-case identifier; used as skill namespace |
| `version` | string | Optional. Semver string. Set this to pin updates; omit to use git commit SHA |
| `description` | string | Brief explanation |
| `author` | object | `name`, `email`, `url` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier (e.g. `MIT`) |
| `keywords` | array | Discovery tags |
| `$schema` | string | JSON Schema URL (ignored at load time) |

**Component path fields:**

| Field | Type | Replaces or adds |
| :--- | :--- | :--- |
| `skills` | string\|array | Adds to default `skills/` |
| `commands` | string\|array | Replaces default `commands/` |
| `agents` | string\|array | Replaces default `agents/` |
| `hooks` | string\|array\|object | Own merge rules |
| `mcpServers` | string\|array\|object | Own merge rules |
| `lspServers` | string\|array\|object | Own merge rules |
| `outputStyles` | string\|array | Replaces default `output-styles/` |
| `experimental.themes` | string\|array | Replaces default `themes/` |
| `experimental.monitors` | string\|array | Replaces default `monitors/monitors.json` |
| `userConfig` | object | User-configurable values prompted at enable time |
| `channels` | array | Message channel declarations (Telegram, Slack, Discord style) |
| `dependencies` | array | Other plugins this plugin requires |

All custom paths must be relative to the plugin root and start with `./`.

### Environment Variables

| Variable | Description |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin's installation directory. Ephemeral — changes on update |
| `${CLAUDE_PLUGIN_DATA}` | Persistent data directory (`~/.claude/plugins/data/{id}/`). Survives updates |
| `${CLAUDE_PROJECT_DIR}` | Project root directory |

All three are also exported as environment variables to hook, MCP, and LSP subprocesses.

### User Configuration (`userConfig`)

Prompts users for values when the plugin is enabled. Values available as `${user_config.KEY}` in hook/MCP/LSP configs, and as `CLAUDE_PLUGIN_OPTION_<KEY>` env vars.

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label in dialog |
| `description` | Yes | Help text |
| `sensitive` | No | If `true`, masked input, stored in keychain not settings.json |
| `required` | No | Validation fails when empty |
| `default` | No | Default value |
| `multiple` | No | For `string`, allow array of values |
| `min` / `max` | No | Bounds for `number` type |

### Plugin Installation Scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` (default) | `~/.claude/settings.json` | Personal, across all projects |
| `project` | `.claude/settings.json` | Team plugins via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Read-only, admin-controlled |

### Plugin Components

**Agents** — frontmatter fields supported in plugin agents: `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation` (only `"worktree"`). Not supported for security: `hooks`, `mcpServers`, `permissionMode`.

**Hook events:**

| Event | When |
| :--- | :--- |
| `SessionStart` | Session begins or resumes |
| `Setup` | With `--init-only` / `--init` / `--maintenance` in `-p` mode |
| `UserPromptSubmit` | Before Claude processes a prompt |
| `UserPromptExpansion` | Command expands to prompt; can block expansion |
| `PreToolUse` | Before a tool call; can block |
| `PermissionRequest` | Permission dialog appears |
| `PermissionDenied` | Tool denied; return `{retry: true}` to allow retry |
| `PostToolUse` | After tool call succeeds |
| `PostToolUseFailure` | After tool call fails |
| `PostToolBatch` | After parallel batch resolves |
| `Notification` | Claude Code sends a notification |
| `SubagentStart` / `SubagentStop` | Subagent lifecycle |
| `TaskCreated` / `TaskCompleted` | Task lifecycle |
| `Stop` / `StopFailure` | Turn ends |
| `TeammateIdle` | Agent team teammate goes idle |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded |
| `ConfigChange` | Configuration file changes |
| `CwdChanged` | Working directory changes |
| `FileChanged` | Watched file changes; `matcher` specifies filenames |
| `WorktreeCreate` / `WorktreeRemove` | Worktree lifecycle |
| `PreCompact` / `PostCompact` | Context compaction |
| `Elicitation` / `ElicitationResult` | MCP server elicitation |
| `SessionEnd` | Session terminates |

**Hook types:** `command`, `http`, `mcp_tool`, `prompt`, `agent`

**LSP servers** — required fields: `command`, `extensionToLanguage`. Optional: `args`, `transport`, `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`.

**Monitors** — run persistent background shell commands; each stdout line delivered to Claude as a notification. Requires Claude Code v2.1.105+.

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique within plugin |
| `command` | Yes | Shell command run as persistent process |
| `description` | Yes | Shown in task panel |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

**Themes** — JSON files in `themes/` with `name`, `base` (`"dark"` or `"light"`), and `overrides` map of color tokens. Experimental component.

### Official Marketplace LSP Plugins

| Plugin | Language server | Install |
| :--- | :--- | :--- |
| `pyright-lsp` | Pyright (Python) | `pip install pyright` or `npm install -g pyright` |
| `typescript-lsp` | TypeScript Language Server | `npm install -g typescript-language-server typescript` |
| `rust-analyzer-lsp` | rust-analyzer | See rust-analyzer docs |

### Version Management

Version resolution order:
1. `version` in plugin's `plugin.json`
2. `version` in marketplace entry
3. Git commit SHA (for git-backed sources)
4. `unknown` (npm sources or non-git local dirs)

| Approach | How | Update behavior |
| :--- | :--- | :--- |
| Explicit version | Set `"version": "2.1.0"` in `plugin.json` | Updates only when you bump the version |
| Commit-SHA version | Omit `version` | Updates on every new commit |

### CLI Commands

| Command | Description |
| :--- | :--- |
| `claude plugin install <plugin> [--scope user\|project\|local]` | Install a plugin |
| `claude plugin uninstall <plugin> [--keep-data] [--prune]` | Remove a plugin |
| `claude plugin enable <plugin>` | Enable a disabled plugin |
| `claude plugin disable <plugin>` | Disable without uninstalling |
| `claude plugin update <plugin>` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin details <name>` | Show component inventory and token cost |
| `claude plugin prune [--dry-run] [-y]` | Remove orphaned auto-installed dependencies (requires v2.1.121+) |
| `claude plugin tag [--push] [--dry-run] [-f]` | Create a release git tag for version resolution |
| `claude plugin validate` | Validate plugin.json, frontmatter, hooks.json |

Inside Claude Code: `/reload-plugins` reloads all active plugins without restarting.

### Testing Locally

```bash
# Load a local plugin directory
claude --plugin-dir ./my-plugin

# Load multiple plugins
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two

# Load a packaged plugin from a URL
claude --plugin-url https://example.com/my-plugin.zip
```

When a `--plugin-dir` plugin has the same name as an installed marketplace plugin, the local copy takes precedence (except force-enabled managed plugins).

### Plugin Caching

Marketplace plugins are copied to `~/.claude/plugins/cache`. Implications:
- Plugins cannot reference files outside their directory (e.g. `../shared-utils`)
- Previous version directories stay for ~7 days after update (grace period for concurrent sessions)
- Symlinks within the plugin directory are preserved; symlinks to sibling plugins in the same marketplace are dereferenced (content copied); symlinks outside the marketplace are skipped

### Discovering and Installing Plugins

- Official marketplace (`claude-plugins-official`) is available by default — browse in `/plugin` Discover tab or at [claude.com/plugins](https://claude.com/plugins)
- Install: `/plugin install <name>@marketplace-name`
- Update marketplace listing: `/plugin marketplace update marketplace-name`

### Marketplace Sources

| Source | Format | Notes |
| :--- | :--- | :--- |
| GitHub | `owner/repo` or `{ "source": "github", "repo": "owner/repo", "ref"?, "sha"? }` | Recommended |
| Git URL | `{ "source": "url", "url": "...", "ref"?, "sha"? }` | GitLab, Bitbucket, self-hosted |
| Git subdirectory | `{ "source": "git-subdir", "url": "...", "path": "...", "ref"?, "sha"? }` | Sparse clone of monorepo subdir |
| npm | `{ "source": "npm", "package": "...", "version"?, "registry"? }` | npm registry |
| Relative path | `"./plugins/my-plugin"` | Same-repo plugins; only works with Git-based marketplaces |

### Plugin Dependencies

Declare in `plugin.json`:
```json
{
  "dependencies": [
    "audit-logger",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```

Dependency version fields: `name` (required), `version` (semver range), `marketplace` (for cross-marketplace deps, must be allowed by `allowCrossMarketplaceDependenciesOn`).

Tag convention for version resolution: `{plugin-name}--v{version}`. Use `claude plugin tag --push`.

Constraint intersection: multiple plugins constraining the same dependency get the highest version satisfying all ranges. Conflicts (`range-conflict`) disable the newer plugin.

**Dependency error types:**

| Error | Meaning | Fix |
| :--- | :--- | :--- |
| `dependency-unsatisfied` | Dependency not installed or disabled | Run `claude plugin install` shown in error |
| `range-conflict` | Ranges cannot be combined | Uninstall/update conflicting plugin or widen constraint |
| `dependency-version-unsatisfied` | Installed version outside declared range | Re-resolve: `claude plugin install <dep>@<marketplace>` |
| `no-matching-tag` | No git tag satisfying the range | Check upstream tags or relax range |

### Common Debugging Issues

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` |
| Skills not appearing | Wrong directory structure | Ensure `skills/` at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Script not executable | `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin paths |
| Path errors | Absolute paths used | All paths must be relative starting with `./` |
| LSP `Executable not found` | Language server binary not installed | Install the required binary |

### Strict Mode (Marketplace)

| Value | Behavior |
| :--- | :--- |
| `true` (default) | `plugin.json` is authority; marketplace entry supplements |
| `false` | Marketplace entry is entire definition; plugin repo has no `plugin.json` with component declarations |

### Environment Variables for Marketplace/CI

| Variable | Description |
| :--- | :--- |
| `CLAUDE_CODE_PLUGIN_SEED_DIR` | Pre-populated plugin dir for containers; read-only |
| `CLAUDE_CODE_PLUGIN_CACHE_DIR` | Override plugin cache location during build |
| `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE=1` | Retain stale marketplace clone on git pull failure |
| `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` | Git operation timeout in ms (default: 120000) |

### Submit to Official Marketplace

- Claude.ai: [claude.ai/settings/plugins/submit](https://claude.ai/settings/plugins/submit)
- Console: [platform.claude.com/plugins/submit](https://platform.claude.com/plugins/submit)

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — quickstart, plugin structure, skills, LSP servers, monitors, default settings, testing locally, debugging, sharing, converting standalone configs to plugins
- [Plugins reference](references/claude-code-plugins-reference.md) — complete technical specifications: manifest schema, component schemas, environment variables, plugin caching, directory structure, CLI commands, debugging tools, version management
- [Discover and install plugins](references/claude-code-discover-plugins.md) — official marketplace, adding marketplace sources, installing/managing plugins, team marketplace configuration, security, troubleshooting
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace.json schema, plugin sources, hosting (GitHub, private repos, containers), release channels, managed restrictions, troubleshooting
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring dependencies, version constraints, cross-marketplace dependencies, git tag convention, constraint intersection, error resolution

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
