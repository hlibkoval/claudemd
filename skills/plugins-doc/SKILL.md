---
name: plugins-doc
description: Complete official documentation for Claude Code plugins — creating plugins, plugin manifest schema, plugin components (skills, agents, hooks, MCP/LSP servers, monitors, themes), discovering and installing plugins, creating and distributing marketplaces, plugin dependencies, and CLI reference.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

Plugins are self-contained directories that extend Claude Code with skills, agents, hooks, MCP servers, LSP servers, monitors, and themes. They can be shared via marketplaces.

### Standalone vs plugin

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` dir) | `/hello` | Personal, project-specific, short names |
| **Plugin** (dir with `.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing, versioned releases, multi-project reuse |

### Plugin directory structure

```
my-plugin/
├── .claude-plugin/plugin.json   ← manifest (optional; only file here)
├── skills/<name>/SKILL.md       ← skills (new style)
├── commands/<name>.md           ← skills (flat legacy style)
├── agents/<name>.md             ← subagent definitions
├── hooks/hooks.json             ← event handlers
├── .mcp.json                    ← MCP server configs
├── .lsp.json                    ← LSP server configs
├── monitors/monitors.json       ← background monitors
├── themes/<name>.json           ← color themes
├── output-styles/               ← output style definitions
├── bin/                         ← executables added to PATH
└── settings.json                ← default settings (agent, subagentStatusLine only)
```

### plugin.json manifest schema

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | **Required if manifest present.** Kebab-case unique identifier; used as skill namespace |
| `version` | string | Optional semver. If set, users only get updates when bumped. Omit to use git commit SHA |
| `description` | string | Shown in plugin manager |
| `author` | object | `name`, `email`, `url` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier (e.g. `"MIT"`) |
| `keywords` | array | Discovery tags |
| `skills` | string\|array | Custom skill directories (replaces default `skills/`) |
| `commands` | string\|array | Custom flat .md skill files/dirs (replaces default `commands/`) |
| `agents` | string\|array | Custom agent files (replaces default `agents/`) |
| `hooks` | string\|array\|object | Hook config paths or inline config |
| `mcpServers` | string\|array\|object | MCP config paths or inline config |
| `lspServers` | string\|array\|object | LSP server configs |
| `monitors` | string\|array | Monitor configs path or inline array |
| `outputStyles` | string\|array | Output style files/dirs |
| `themes` | string\|array | Color theme files/dirs |
| `userConfig` | object | Values prompted at enable time (see below) |
| `channels` | array | Message channel declarations (Telegram, Slack, Discord) |
| `dependencies` | array | Other plugins this plugin requires; supports semver constraints |

### userConfig fields

Declare values Claude Code prompts for at plugin enable time:

```json
{
  "userConfig": {
    "api_token": {
      "type": "string",
      "title": "API token",
      "description": "Authentication token",
      "sensitive": true,
      "required": true
    }
  }
}
```

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label in dialog |
| `description` | Yes | Help text |
| `sensitive` | No | Masks input; stores in keychain (~2 KB limit) |
| `required` | No | Fails validation if empty |
| `default` | No | Used when user provides nothing |
| `multiple` | No | Allow array of strings (string type) |
| `min`/`max` | No | Bounds for number type |

Values available as `${user_config.KEY}` in hooks/MCP/LSP/monitor configs, and as `CLAUDE_PLUGIN_OPTION_<KEY>` env vars.

### Environment variables

| Variable | Points to |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory (changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent plugin data dir (`~/.claude/plugins/data/{id}/`); survives updates |

Use `${CLAUDE_PLUGIN_ROOT}` for bundled scripts/configs; use `${CLAUDE_PLUGIN_DATA}` for installed deps and generated files.

### Plugin hook events

Plugin hooks use the same events as user hooks:

| Event | When it fires |
| :--- | :--- |
| `SessionStart` | Session begins or resumes |
| `UserPromptSubmit` | Prompt submitted before Claude processes it |
| `PreToolUse` | Before a tool call executes |
| `PostToolUse` | After a tool call succeeds |
| `PostToolBatch` | After a full batch of parallel tool calls |
| `Stop` | When Claude finishes responding |
| `SubagentStart` / `SubagentStop` | Subagent spawned/finished |
| `FileChanged` | Watched file changes |
| `WorktreeCreate` / `WorktreeRemove` | Worktree created/removed |
| `PreCompact` / `PostCompact` | Before/after context compaction |
| `SessionEnd` | Session terminates |
| (and others — see hooks-doc skill) | |

Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`

### Monitors

Background monitors run a shell command for the session lifetime and deliver each stdout line to Claude as a notification.

```json
[
  {
    "name": "error-log",
    "command": "tail -F ./logs/error.log",
    "description": "Application error log",
    "when": "on-skill-invoke:debug"
  }
]
```

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique within plugin |
| `command` | Yes | Shell command run as persistent background process |
| `description` | Yes | Summary shown in task panel |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

Requires Claude Code v2.1.105+. Only runs in interactive CLI sessions.

### LSP server fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `command` | Yes | LSP binary to execute (must be in PATH) |
| `extensionToLanguage` | Yes | Maps file extensions to language IDs |
| `args` | No | CLI arguments |
| `transport` | No | `stdio` (default) or `socket` |
| `env` | No | Environment variables |
| `initializationOptions` | No | Passed at server init |
| `settings` | No | Passed via `workspace/didChangeConfiguration` |
| `startupTimeout` | No | Max ms to wait for startup |
| `restartOnCrash` | No | Auto-restart on crash |
| `maxRestarts` | No | Max restart attempts |

Official LSP plugins (install binary separately):

| Plugin | Language server | Binary required |
| :--- | :--- | :--- |
| `pyright-lsp` | Pyright | `pyright-langserver` |
| `typescript-lsp` | TypeScript Language Server | `typescript-language-server` |
| `rust-analyzer-lsp` | rust-analyzer | `rust-analyzer` |
| `gopls-lsp` | gopls | `gopls` |
| `clangd-lsp` | clangd | `clangd` |

### Plugin installation scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` | `~/.claude/settings.json` | Personal, all projects (default) |
| `project` | `.claude/settings.json` | Team plugins via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Read-only, admin-controlled |

### CLI commands reference

```bash
claude plugin install <plugin>[@marketplace] [--scope user|project|local]
claude plugin uninstall <plugin> [--scope] [--keep-data]
claude plugin enable <plugin> [--scope]
claude plugin disable <plugin> [--scope]
claude plugin update <plugin> [--scope]
claude plugin list [--json] [--available]
claude plugin tag [--push] [--dry-run] [-f]
claude plugin validate .
claude plugin marketplace add <source> [--scope] [--sparse <paths...>]
claude plugin marketplace list [--json]
claude plugin marketplace remove <name>
claude plugin marketplace update [name]
```

In-session commands: `/plugin`, `/plugin install`, `/plugin disable`, `/reload-plugins`, `/plugin marketplace add`

### Plugin version resolution

Version resolved from first match:
1. `version` in plugin's `plugin.json`
2. `version` in marketplace entry
3. Git commit SHA (for git-backed sources)
4. `"unknown"` (npm or non-git local)

### Marketplace plugin sources

| Source type | Format | Notes |
| :--- | :--- | :--- |
| Relative path | `"./plugins/my-plugin"` | Within marketplace repo; requires git-based marketplace |
| `github` | `{ "source": "github", "repo": "owner/repo", "ref"?, "sha"? }` | |
| `url` | `{ "source": "url", "url": "https://...", "ref"?, "sha"? }` | Any git host |
| `git-subdir` | `{ "source": "git-subdir", "url": "...", "path": "subdir", "ref"?, "sha"? }` | Sparse clone |
| `npm` | `{ "source": "npm", "package": "@org/pkg", "version"?, "registry"? }` | |

### Marketplace schema (marketplace.json)

Required fields: `name` (kebab-case, unique), `owner.name`, `plugins` array.

Each plugin entry: `name` + `source` required; optional: `description`, `version`, `author`, `homepage`, `repository`, `license`, `keywords`, `category`, `tags`, `strict`, component path fields.

`strict: false` — marketplace entry is the entire definition; plugin repo need not have `plugin.json`.

### Plugin dependencies

Declare in `plugin.json`:
```json
{
  "dependencies": [
    "audit-logger",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```

Supports semver ranges (`~2.1.0`, `^2.0`, `>=1.4`, `=2.1.0`). Resolved against git tags `{plugin-name}--v{version}`. Create tags with `claude plugin tag --push`.

Cross-marketplace deps require `allowCrossMarketplaceDependenciesOn` in root `marketplace.json`.

### Common debugging

| Issue | Solution |
| :--- | :--- |
| Plugin not loading | Run `/plugin validate` or `claude plugin validate .` |
| Skills missing | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Check script is executable (`chmod +x`); event names are case-sensitive |
| MCP server fails | Use `${CLAUDE_PLUGIN_ROOT}` for all plugin paths |
| LSP binary not found | Install binary; check `/plugin` Errors tab |
| Path errors | All custom paths must be relative, start with `./` |

`claude --debug` shows plugin loading details. `/plugin` → Errors tab shows load errors.

### Official marketplace plugins (categories)

- **Code intelligence**: `pyright-lsp`, `typescript-lsp`, `rust-analyzer-lsp`, `gopls-lsp`, `clangd-lsp`, `csharp-lsp`, `jdtls-lsp`, `kotlin-lsp`, `lua-lsp`, `php-lsp`, `swift-lsp`
- **External integrations**: `github`, `gitlab`, `atlassian`, `asana`, `linear`, `notion`, `figma`, `vercel`, `firebase`, `supabase`, `slack`, `sentry`
- **Development workflows**: `commit-commands`, `pr-review-toolkit`, `agent-sdk-dev`, `plugin-dev`
- **Output styles**: `explanatory-output-style`, `learning-output-style`

Add official marketplace: auto-available as `claude-plugins-official`. Demo marketplace: `/plugin marketplace add anthropics/claude-code`

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — quickstart, plugin structure, skills, LSP servers, monitors, default settings, testing locally, migrating from standalone config, submitting to the official marketplace
- [Plugins reference](references/claude-code-plugins-reference.md) — complete component schemas, plugin manifest schema, environment variables, plugin caching, directory structure, CLI commands, debugging tools, version management
- [Discover and install plugins](references/claude-code-discover-plugins.md) — official marketplace, adding marketplaces (GitHub, git, local, URL), installing plugins, managing installed plugins, team marketplace configuration, auto-updates, security, troubleshooting
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace.json schema, plugin sources, hosting on GitHub/git services, private repos, team configuration, container pre-population, managed marketplace restrictions, release channels, validation
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring dependencies with semver ranges, cross-marketplace deps, tagging releases, constraint resolution, dependency error codes

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
