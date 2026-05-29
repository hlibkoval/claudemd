---
name: plugins-doc
user-invocable: false
description: Complete official documentation for Claude Code plugins — creating, distributing, discovering, and referencing the full plugin system.
---

# Claude Code Plugins Documentation

This skill provides the complete official documentation for the Claude Code plugin system.

## Quick Reference

### Standalone vs Plugin

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| Standalone (`.claude/`) | `/hello` | Personal, project-specific, quick experiments |
| Plugin (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing, multi-project, versioned releases |

### Plugin Directory Structure

| Directory | Location | Purpose |
| :--- | :--- | :--- |
| `.claude-plugin/` | Plugin root | `plugin.json` manifest only |
| `skills/` | Plugin root | Skills as `<name>/SKILL.md` |
| `commands/` | Plugin root | Skills as flat `.md` files (legacy) |
| `agents/` | Plugin root | Subagent definitions |
| `hooks/` | Plugin root | `hooks.json` event handlers |
| `.mcp.json` | Plugin root | MCP server configs |
| `.lsp.json` | Plugin root | LSP server configs |
| `monitors/` | Plugin root | `monitors.json` background monitors |
| `bin/` | Plugin root | Executables added to Bash tool PATH |
| `settings.json` | Plugin root | Default settings (only `agent` and `subagentStatusLine` keys supported) |

**Warning:** Only `plugin.json` goes inside `.claude-plugin/`. All other directories must be at the plugin root.

### Plugin Manifest (`plugin.json`) — Key Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes (if manifest present) | Unique kebab-case identifier; used as skill namespace |
| `displayName` | No | Human-readable name for UI (v2.1.143+) |
| `version` | No | Semver string; omit to use git commit SHA as version |
| `description` | No | Shown in plugin manager |
| `author` | No | `{ name, email, url }` |
| `homepage` | No | Documentation URL |
| `repository` | No | Source code URL |
| `license` | No | SPDX identifier |
| `keywords` | No | Array of discovery tags |
| `defaultEnabled` | No | `false` to install disabled (v2.1.154+) |
| `skills` | No | Additional skill directories (adds to default `skills/`) |
| `commands` | No | Custom command paths (replaces default `commands/`) |
| `agents` | No | Custom agent paths (replaces default `agents/`) |
| `hooks` | No | Hooks config path or inline object |
| `mcpServers` | No | MCP config path or inline object |
| `lspServers` | No | LSP config path or inline object |
| `userConfig` | No | User-prompted config values at enable time |
| `dependencies` | No | Array of required plugin names/constraints |
| `experimental.themes` | No | Color theme directories |
| `experimental.monitors` | No | Background monitor config |

### Environment Variables Available in Plugin Commands

| Variable | Description |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to the installed plugin directory (ephemeral — changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent data directory that survives updates (`~/.claude/plugins/data/{id}/`) |
| `${CLAUDE_PROJECT_DIR}` | The project root Claude Code was launched from |
| `${user_config.KEY}` | User config values from `userConfig` field |

### Plugin Installation Scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` | `~/.claude/settings.json` | Personal, all projects (default) |
| `project` | `.claude/settings.json` | Team plugins via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled, read-only |

### CLI Plugin Commands

| Command | Description |
| :--- | :--- |
| `claude plugin install <name>@<market> [--scope]` | Install a plugin |
| `claude plugin uninstall <name> [--keep-data] [--prune]` | Remove a plugin |
| `claude plugin enable <name> [--scope]` | Enable a disabled plugin |
| `claude plugin disable <name> [--scope]` | Disable without uninstalling |
| `claude plugin update <name> [--scope]` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin details <name>` | Show component inventory and token cost |
| `claude plugin prune [--dry-run] [-y]` | Remove orphaned auto-installed dependencies |
| `claude plugin tag [--push] [--dry-run]` | Create a release git tag |
| `claude plugin validate [path]` | Validate plugin or marketplace JSON |
| `/reload-plugins` | Reload all plugins without restarting |

### Plugin Marketplace CLI Commands

| Command | Description |
| :--- | :--- |
| `claude plugin marketplace add <source> [--scope] [--sparse]` | Add a marketplace |
| `claude plugin marketplace list [--json]` | List configured marketplaces |
| `claude plugin marketplace remove <name> [--scope]` | Remove a marketplace |
| `claude plugin marketplace update [name]` | Refresh marketplace listings |

### Marketplace Sources (in `marketplace.json` plugin entries)

| Source type | Example | Notes |
| :--- | :--- | :--- |
| Relative path | `"./plugins/my-plugin"` | Only works with git-based marketplaces |
| `github` | `{ "source": "github", "repo": "owner/repo" }` | Optional `ref`, `sha` |
| `url` | `{ "source": "url", "url": "https://..." }` | Git URL, optional `ref`, `sha` |
| `git-subdir` | `{ "source": "git-subdir", "url": "...", "path": "tools/plugin" }` | Sparse clone of monorepo subdir |
| `npm` | `{ "source": "npm", "package": "@org/plugin" }` | Optional `version`, `registry` |

### Version Management

| Strategy | How | Update behavior |
| :--- | :--- | :--- |
| Explicit version | Set `"version": "2.1.0"` in `plugin.json` | Users get updates only when you bump the field |
| Commit-SHA version | Omit `version` entirely | Users get updates on every new commit |

**Important:** If `version` is set in `plugin.json`, pushing new commits without bumping it has no effect. Use `{plugin-name}--v{version}` git tag convention for dependency version resolution.

### Hook Events (supported in plugin `hooks/hooks.json`)

| Event | When it fires |
| :--- | :--- |
| `SessionStart` / `SessionEnd` | Session begins/terminates |
| `UserPromptSubmit` | Before Claude processes a prompt |
| `PreToolUse` / `PostToolUse` | Before/after a tool call |
| `PostToolUseFailure` | After a tool call fails |
| `PostToolBatch` | After a full batch of parallel tool calls |
| `Stop` | When Claude finishes responding |
| `SubagentStart` / `SubagentStop` | When a subagent spawns/finishes |
| `FileChanged` | When a watched file changes on disk |
| `CwdChanged` | When the working directory changes |
| `PreCompact` / `PostCompact` | Before/after context compaction |
| `InstructionsLoaded` | When a CLAUDE.md or rules file loads |
| `ConfigChange` | When a configuration file changes |
| `WorktreeCreate` / `WorktreeRemove` | Worktree lifecycle |
| `Elicitation` / `ElicitationResult` | MCP elicitation flow |

Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`

### LSP Server Config Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `command` | Yes | LSP binary to execute (must be in PATH) |
| `extensionToLanguage` | Yes | Maps file extensions to language IDs |
| `args` | No | Command-line arguments |
| `transport` | No | `stdio` (default) or `socket` |
| `env` | No | Environment variables for the server |
| `initializationOptions` | No | Passed during server initialization |
| `settings` | No | Passed via `workspace/didChangeConfiguration` |
| `restartOnCrash` | No | Auto-restart if server crashes |
| `maxRestarts` | No | Max restart attempts |

### Available Official LSP Plugins

| Plugin | Language | Binary required |
| :--- | :--- | :--- |
| `pyright-lsp` | Python | `pyright-langserver` |
| `typescript-lsp` | TypeScript | `typescript-language-server` |
| `rust-analyzer-lsp` | Rust | `rust-analyzer` |
| `gopls-lsp` | Go | `gopls` |
| `clangd-lsp` | C/C++ | `clangd` |
| `csharp-lsp` | C# | `csharp-ls` |
| `jdtls-lsp` | Java | `jdtls` |
| `kotlin-lsp` | Kotlin | `kotlin-language-server` |
| `lua-lsp` | Lua | `lua-language-server` |
| `php-lsp` | PHP | `intelephense` |
| `swift-lsp` | Swift | `sourcekit-lsp` |

### Monitor Config Fields (`monitors/monitors.json`)

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier within the plugin |
| `command` | Yes | Shell command run as persistent background process |
| `description` | Yes | Short summary shown in task panel |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

### Plugin Dependency Version Constraints

```json
{
  "dependencies": [
    "audit-logger",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```

Tag releases as `{plugin-name}--v{version}` using `claude plugin tag --push`. Constraints use Node semver range syntax (`~`, `^`, `>=`, `=`).

### Plugin Hint Protocol (CLI/SDK authors)

To prompt Claude Code users to install your official marketplace plugin, write a self-closing tag to stderr when the `CLAUDECODE` env var is set:

```
<claude-code-hint v="1" type="plugin" value="your-plugin@claude-plugins-official" />
```

Requirements: tag must be on its own line; only works for plugins in an official Anthropic marketplace; shown at most once per plugin per session.

### Community Marketplace

```shell
/plugin marketplace add anthropics/claude-plugins-community
/plugin install <plugin-name>@claude-community
```

To submit: use [claude.ai/settings/plugins/submit](https://claude.ai/settings/plugins/submit). Run `claude plugin validate` before submitting.

### Testing Locally

```bash
claude --plugin-dir ./my-plugin
claude --plugin-dir ./my-plugin.zip     # v2.1.128+
claude --plugin-url https://example.com/my-plugin.zip
```

Use multiple flags to load several plugins at once. Run `/reload-plugins` to pick up changes without restarting.

### Common Debugging Issues

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` |
| Skills not appearing | Wrong directory structure | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Script not executable | `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin paths |
| LSP `Executable not found` | Language server not installed | Install required binary |
| Path errors | Absolute paths used | All paths must be relative and start with `./` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — Creating plugins with skills, agents, hooks, and MCP servers; quickstart, structure overview, testing locally, migration from standalone
- [Plugins reference](references/claude-code-plugins-reference.md) — Complete technical reference: manifest schema, component specs, CLI commands, environment variables, debugging, versioning
- [Discover and install plugins](references/claude-code-discover-plugins.md) — Installing from marketplaces, official and community marketplaces, managing installed plugins, LSP plugin catalog
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — Marketplace file format, plugin sources, hosting, private repos, managed restrictions, version channels, troubleshooting
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — Declaring version constraints, tagging releases, cross-marketplace dependencies, resolving dependency errors
- [Recommend your plugin from your CLI](references/claude-code-plugin-hints.md) — Plugin hint protocol for CLI/SDK authors to prompt installation from official marketplace

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
- Recommend your plugin from your CLI: https://code.claude.com/docs/en/plugin-hints.md
