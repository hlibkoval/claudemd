---
name: plugins-doc
user-invocable: false
description: Complete official documentation for Claude Code plugins — creating, installing, distributing, and managing plugins with skills, agents, hooks, MCP servers, LSP servers, monitors, and marketplaces.
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

### Standalone vs Plugin Configuration

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugins** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teams, distributing to community, reuse across projects |

### Plugin Directory Structure

| Directory | Location | Purpose |
| :--- | :--- | :--- |
| `.claude-plugin/` | Plugin root | Contains `plugin.json` manifest only |
| `skills/` | Plugin root | Skills as `<name>/SKILL.md` directories |
| `commands/` | Plugin root | Skills as flat `.md` files (legacy; prefer `skills/`) |
| `agents/` | Plugin root | Subagent definitions |
| `hooks/` | Plugin root | Event handlers in `hooks.json` |
| `.mcp.json` | Plugin root | MCP server configurations |
| `.lsp.json` | Plugin root | LSP server configurations |
| `monitors/` | Plugin root | Background monitors in `monitors.json` |
| `bin/` | Plugin root | Executables added to Bash tool's `PATH` |
| `settings.json` | Plugin root | Default settings (only `agent` and `subagentStatusLine` keys supported) |

**Common mistake**: Never put `commands/`, `agents/`, `skills/`, or `hooks/` inside `.claude-plugin/`. Only `plugin.json` goes there.

### Plugin Manifest (`plugin.json`) Schema

**Required:** `name` (kebab-case, no spaces) — only required field if manifest is present.

**Metadata fields:**

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique identifier; becomes skill namespace prefix |
| `version` | string | Semantic version (e.g., `1.2.0`) |
| `description` | string | Brief plugin purpose |
| `author` | object | `{name, email, url}` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier (e.g., `MIT`) |
| `keywords` | array | Discovery tags |

**Component path fields** (all paths relative to plugin root, starting with `./`):

| Field | Type | Description |
| :--- | :--- | :--- |
| `skills` | string\|array | Custom skill directories (replaces default `skills/`) |
| `commands` | string\|array | Custom flat `.md` skill files or directories |
| `agents` | string\|array | Custom agent files |
| `hooks` | string\|array\|object | Hook config paths or inline config |
| `mcpServers` | string\|array\|object | MCP config paths or inline config |
| `lspServers` | string\|array\|object | LSP server configs |
| `monitors` | string\|array | Background monitor configurations |
| `outputStyles` | string\|array | Output style files/directories |
| `userConfig` | object | User-configurable values prompted at enable time |
| `channels` | array | Message channel declarations (Telegram, Slack, Discord) |
| `dependencies` | array | Other plugins this plugin requires |

### Environment Variables

| Variable | Description |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin install directory (changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent data directory that survives updates (`~/.claude/plugins/data/{id}/`) |

Both variables work in skill/agent content, hook commands, monitor commands, and MCP/LSP server configs. Both are also exported to subprocesses.

### User Configuration (`userConfig`)

Declares fields Claude Code prompts for when the plugin is enabled.

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label shown in configuration dialog |
| `description` | Yes | Help text |
| `sensitive` | No | Masks input; stores in system keychain (not `settings.json`) |
| `required` | No | Validation fails when empty |
| `default` | No | Value when user provides nothing |
| `multiple` | No | Allow array of strings (for `string` type) |
| `min`/`max` | No | Bounds for `number` type |

Values accessible as `${user_config.KEY}` in configs and exported as `CLAUDE_PLUGIN_OPTION_<KEY>` env vars.

### Hook Events

| Event | When it fires |
| :--- | :--- |
| `SessionStart` | When a session begins or resumes |
| `UserPromptSubmit` | When you submit a prompt, before Claude processes it |
| `UserPromptExpansion` | When a typed command expands, before reaching Claude. Can block |
| `PreToolUse` | Before a tool call executes. Can block it |
| `PermissionRequest` | When a permission dialog appears |
| `PermissionDenied` | When a tool call is denied. Return `{retry: true}` to allow retry |
| `PostToolUse` | After a tool call succeeds |
| `PostToolUseFailure` | After a tool call fails |
| `Notification` | When Claude Code sends a notification |
| `SubagentStart` / `SubagentStop` | When a subagent spawns / finishes |
| `TaskCreated` / `TaskCompleted` | When a task is created / completed |
| `Stop` | When Claude finishes responding |
| `StopFailure` | When turn ends due to API error |
| `TeammateIdle` | When an agent team teammate is about to go idle |
| `InstructionsLoaded` | When a CLAUDE.md or rules file is loaded |
| `ConfigChange` | When a config file changes during a session |
| `CwdChanged` | When the working directory changes |
| `FileChanged` | When a watched file changes on disk |
| `WorktreeCreate` / `WorktreeRemove` | When a worktree is created / removed |
| `PreCompact` / `PostCompact` | Before / after context compaction |
| `Elicitation` / `ElicitationResult` | MCP server user-input request / response |
| `SessionEnd` | When a session terminates |

**Hook types:** `command`, `http`, `prompt`, `agent`

### Monitors (`monitors/monitors.json`)

Background processes that deliver stdout lines to Claude as notifications. Requires Claude Code v2.1.105+.

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier within plugin |
| `command` | Yes | Shell command run as persistent background process |
| `description` | Yes | Short summary of what is being watched |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

### LSP Server Config Fields

**Required:** `command`, `extensionToLanguage`

**Optional:** `args`, `transport` (`stdio`/`socket`), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`

**Official LSP plugins from marketplace:**

| Plugin | Language Server |
| :--- | :--- |
| `pyright-lsp` | Pyright (Python) |
| `typescript-lsp` | TypeScript Language Server |
| `rust-analyzer-lsp` | rust-analyzer |
| `gopls-lsp` | gopls (Go) |
| `clangd-lsp` | clangd (C/C++) |
| `csharp-lsp` | csharp-ls |
| `jdtls-lsp` | jdtls (Java) |
| `kotlin-lsp` | kotlin-language-server |
| `lua-lsp` | lua-language-server |
| `php-lsp` | intelephense |
| `swift-lsp` | sourcekit-lsp |

### Plugin Installation Scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` | `~/.claude/settings.json` | Personal plugins across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled, read-only |

### CLI Commands

```bash
# Plugin management
claude plugin install <plugin>[@marketplace] [--scope user|project|local]
claude plugin uninstall <plugin>[@marketplace] [--scope user] [--keep-data]
claude plugin enable <plugin>[@marketplace] [--scope user]
claude plugin disable <plugin>[@marketplace] [--scope user]
claude plugin update <plugin>[@marketplace] [--scope user]
claude plugin list [--json] [--available]
claude plugin validate [path]

# Marketplace management
claude plugin marketplace add <source> [--scope user|project|local] [--sparse <paths...>]
claude plugin marketplace list [--json]
claude plugin marketplace remove <name>
claude plugin marketplace update [name]
```

In-session equivalents use `/plugin` and `/plugin marketplace` prefixes. Run `/reload-plugins` after changes to pick up updates without restarting.

### Marketplace (`marketplace.json`) Schema

Location: `.claude-plugin/marketplace.json`

**Required fields:** `name` (kebab-case), `owner` (`{name, email?}`), `plugins` array

**Plugin entry required fields:** `name`, `source`

**Plugin sources:**

| Type | Format | Notes |
| :--- | :--- | :--- |
| Relative path | `"./my-plugin"` | Must start with `./`; only works with Git-based marketplaces |
| GitHub | `{source: "github", repo: "owner/repo", ref?, sha?}` | |
| Git URL | `{source: "url", url: "...", ref?, sha?}` | |
| Git subdirectory | `{source: "git-subdir", url: "...", path: "...", ref?, sha?}` | Sparse clone for monorepos |
| npm | `{source: "npm", package: "...", version?, registry?}` | |

**`strict` mode:** `true` (default) = `plugin.json` is authority, marketplace supplements it. `false` = marketplace entry is the full definition.

### Plugin Dependencies

Declare in `plugin.json` `dependencies` array:

```json
"dependencies": [
  "audit-logger",
  { "name": "secrets-vault", "version": "~2.1.0" },
  { "name": "shared-lib", "marketplace": "other-marketplace" }
]
```

Cross-marketplace dependencies require the root marketplace to list the target in `allowCrossMarketplaceDependenciesOn`. Versions resolve against git tags using convention `{plugin-name}--v{version}`.

**Dependency errors:**

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `dependency-unsatisfied` | Dependency not installed or disabled | Run `claude plugin install` shown in error |
| `range-conflict` | Constraints from multiple plugins cannot be combined | Uninstall/update one conflicting plugin |
| `dependency-version-unsatisfied` | Installed version outside declared range | Re-run `claude plugin install <dependency>` |
| `no-matching-tag` | No tag satisfies the range | Check upstream has tagged releases using convention |

### Debugging

- Run `claude --debug` to see plugin loading details
- Use `/plugin` interface — **Errors** tab shows load errors
- Validate with `claude plugin validate` or `/plugin validate`
- Run `/reload-plugins` to pick up changes without restarting

**Common issues:**

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` |
| Skills not appearing | Wrong directory structure | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Script not executable | Run `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin paths |
| LSP `Executable not found` | Language server not installed | Install the required binary |

### Plugin Caching

Marketplace plugins are copied to `~/.claude/plugins/cache`. Plugins cannot reference files outside their directory via `../` traversal. Use symlinks for shared files. Previous versions are orphaned and removed after 7 days.

**Environment variables for caching:**
- `CLAUDE_CODE_PLUGIN_SEED_DIR` — pre-populated plugins directory for containers/CI
- `CLAUDE_CODE_PLUGIN_CACHE_DIR` — override cache location during builds
- `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE=1` — retain stale cache on git pull failure
- `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` — override 120-second git timeout (in ms)

### Managed Marketplace Restrictions (`strictKnownMarketplaces`)

Set in managed settings to control which marketplaces users can add:
- Undefined → no restrictions
- `[]` → complete lockdown
- Array of source objects → allowlist (supports `github`, `url`, `hostPattern`, `pathPattern` sources)

### Testing Locally

```bash
claude --plugin-dir ./my-plugin
# Load multiple plugins
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

`--plugin-dir` plugins take precedence over same-named installed marketplace plugins for that session.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — quickstart, plugin structure, skills, LSP, monitors, default settings, local testing, debugging, converting standalone configs, and submitting to the official marketplace
- [Plugins reference](references/claude-code-plugins-reference.md) — complete technical specifications: manifest schema, component schemas, environment variables, CLI commands, file locations, debugging tools, and versioning
- [Discover and install plugins](references/claude-code-discover-plugins.md) — browsing the official Anthropic marketplace, adding marketplaces, installing/managing plugins and marketplaces, scopes, auto-updates, team configuration, and troubleshooting
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace file format, plugin sources, strict mode, hosting on GitHub/GitLab, private repos, container seed dirs, managed marketplace restrictions, release channels, and troubleshooting
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring version constraints, cross-marketplace dependencies, tagging conventions, constraint intersection rules, and resolving dependency errors

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
