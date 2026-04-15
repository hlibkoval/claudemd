---
name: plugins-doc
description: Complete official documentation for Claude Code plugins, covering plugin creation, the plugin.json manifest schema, marketplace catalogs, plugin discovery and installation, and the CLI commands for managing them.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

### What is a plugin?

A plugin is a self-contained directory that bundles skills, agents, hooks, MCP servers, LSP servers, output styles, monitors, and/or executables for Claude Code. Plugins are namespaced (e.g. `/my-plugin:hello`) and distributed via marketplaces.

### Plugin directory layout

```
my-plugin/
  .claude-plugin/plugin.json   # manifest (only file here)
  skills/<name>/SKILL.md       # skills
  commands/<name>.md           # legacy flat skills
  agents/<name>.md             # subagents
  hooks/hooks.json             # event handlers
  .mcp.json                    # MCP servers
  .lsp.json                    # LSP servers
  output-styles/               # output styles
  monitors/monitors.json       # background monitors
  bin/                         # executables added to PATH
  settings.json                # default settings (agent, subagentStatusLine)
```

Only `plugin.json` belongs in `.claude-plugin/`. Everything else lives at the plugin root.

### plugin.json manifest schema

`name` is the only required field. Everything else is optional; component dirs are auto-discovered in default locations.

| Field          | Type                  | Purpose                                                       |
| :------------- | :-------------------- | :------------------------------------------------------------ |
| `name`         | string                | Required. Kebab-case identifier and namespace                 |
| `version`      | string                | Semantic version. Bump on every release or users won't update |
| `description`  | string                | Shown in the plugin manager                                   |
| `author`       | object                | `{name, email?, url?}`                                        |
| `homepage`     | string                | Documentation URL                                             |
| `repository`   | string                | Source code URL                                               |
| `license`      | string                | SPDX identifier                                               |
| `keywords`     | array                 | Discovery tags                                                |
| `skills`       | string\|array         | Custom paths replacing default `skills/`                      |
| `commands`     | string\|array         | Custom paths replacing default `commands/`                    |
| `agents`       | string\|array         | Custom paths replacing default `agents/`                      |
| `hooks`        | string\|array\|object | Hook config paths or inline                                   |
| `mcpServers`   | string\|array\|object | MCP config paths or inline                                    |
| `lspServers`   | string\|array\|object | LSP config paths or inline                                    |
| `outputStyles` | string\|array         | Custom output styles                                          |
| `monitors`     | string\|array\|object | Monitor configs                                               |
| `userConfig`   | object                | User-prompted values, available as `${user_config.KEY}`       |
| `channels`     | array                 | Message channels bound to a plugin MCP server                 |

All component paths must be relative and start with `./`. Custom paths replace defaults; to keep both, list both: `"skills": ["./skills/", "./extras/"]`.

### Plugin environment variables

| Variable                | Meaning                                                                                |
| :---------------------- | :------------------------------------------------------------------------------------- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin install dir. Changes on update — files written here don't survive |
| `${CLAUDE_PLUGIN_DATA}` | Persistent dir at `~/.claude/plugins/data/{id}/` that survives updates                  |

Both are substituted in skill content, agent content, hook commands, and MCP/LSP configs, and exported as env vars to subprocesses.

### marketplace.json schema

Lives at `.claude-plugin/marketplace.json` in the marketplace repo root.

| Field     | Type   | Required | Description                                                |
| :-------- | :----- | :------- | :--------------------------------------------------------- |
| `name`    | string | Yes      | Kebab-case marketplace identifier (public-facing)          |
| `owner`   | object | Yes      | `{name, email?}`                                            |
| `plugins` | array  | Yes      | Plugin entries                                             |
| `metadata.description` | string | No | Marketplace description                              |
| `metadata.version`     | string | No | Marketplace version                                  |
| `metadata.pluginRoot`  | string | No | Base dir prepended to relative plugin source paths   |

Each plugin entry needs `name` and `source`. It may also include any plugin manifest field, plus marketplace-specific `category`, `tags`, and `strict`.

### Plugin source types

| Source type   | Example                                                                          |
| :------------ | :------------------------------------------------------------------------------- |
| Relative path | `"source": "./plugins/my-plugin"` (only works when marketplace is added via Git) |
| `github`      | `{ "source": "github", "repo": "owner/repo", "ref"?, "sha"? }`                   |
| `url`         | `{ "source": "url", "url": "https://...", "ref"?, "sha"? }`                      |
| `git-subdir`  | `{ "source": "git-subdir", "url", "path", "ref"?, "sha"? }` (sparse clone)       |
| `npm`         | `{ "source": "npm", "package", "version"?, "registry"? }`                        |

### Strict mode (`strict` field on plugin entry)

| Value            | Behavior                                                                         |
| :--------------- | :------------------------------------------------------------------------------- |
| `true` (default) | `plugin.json` is the authority; marketplace entry can supplement                 |
| `false`          | Marketplace entry is the entire definition; conflicts with `plugin.json` are errors |

### Installation scopes

| Scope     | Settings file                       | Use case                         |
| :-------- | :---------------------------------- | :------------------------------- |
| `user`    | `~/.claude/settings.json` (default) | Personal across all projects     |
| `project` | `.claude/settings.json`             | Shared with team via VCS         |
| `local`   | `.claude/settings.local.json`       | Per-project, gitignored          |
| `managed` | Managed settings                    | Admin-installed, read-only       |

### Slash commands (interactive)

| Command                                       | Action                                  |
| :-------------------------------------------- | :-------------------------------------- |
| `/plugin`                                     | Open plugin manager (Discover/Installed/Marketplaces/Errors tabs) |
| `/plugin install <name>@<marketplace>`        | Install a plugin                        |
| `/plugin uninstall <name>@<marketplace>`      | Remove a plugin                         |
| `/plugin enable <name>@<marketplace>`         | Enable a disabled plugin                |
| `/plugin disable <name>@<marketplace>`        | Disable without uninstalling            |
| `/plugin marketplace add <source>`            | Register a marketplace                  |
| `/plugin marketplace list`                    | List marketplaces                       |
| `/plugin marketplace update [name]`           | Refresh marketplace catalog             |
| `/plugin marketplace remove <name>`           | Remove a marketplace (uninstalls plugins) |
| `/plugin validate .`                          | Validate marketplace/plugin             |
| `/reload-plugins`                             | Reload plugins/skills/agents/hooks without restart |

### CLI commands (non-interactive)

```
claude plugin install <name>@<marketplace> [-s scope]
claude plugin uninstall <name>@<marketplace> [-s scope] [--keep-data]
claude plugin enable <name>@<marketplace> [-s scope]
claude plugin disable <name>@<marketplace> [-s scope]
claude plugin update <name>@<marketplace> [-s scope]
claude plugin marketplace add <source> [--scope <scope>] [--sparse paths...]
claude plugin marketplace list [--json]
claude plugin marketplace remove <name>
claude plugin marketplace update [name]
claude plugin validate .
```

Test a local plugin without installing: `claude --plugin-dir ./my-plugin` (can be repeated).

### Hook types and lifecycle

Plugin hooks live in `hooks/hooks.json` (or inline in `plugin.json`) and respond to the same events as user hooks: `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PermissionRequest`, `PermissionDenied`, `PostToolUse`, `PostToolUseFailure`, `Notification`, `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `Stop`, `StopFailure`, `TeammateIdle`, `InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `FileChanged`, `WorktreeCreate`, `WorktreeRemove`, `PreCompact`, `PostCompact`, `Elicitation`, `ElicitationResult`, `SessionEnd`.

Hook types: `command`, `http`, `prompt`, `agent`.

### Plugin agents — supported frontmatter

`name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation` (only `"worktree"`). For security, `hooks`, `mcpServers`, and `permissionMode` are NOT supported on plugin-shipped agents.

### LSP servers (`.lsp.json`)

Required: `command`, `extensionToLanguage`. Optional: `args`, `transport` (`stdio`/`socket`), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`. The language server binary must be installed separately.

### Plugin caching

Marketplace plugins are copied to `~/.claude/plugins/cache/` per version. Path traversal outside the plugin root is blocked — use symlinks for shared files. Orphaned versions are GC'd 7 days after update/uninstall.

### Team distribution settings

In `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "team-tools": {
      "source": { "source": "github", "repo": "your-org/claude-plugins" }
    }
  },
  "enabledPlugins": {
    "code-formatter@team-tools": true
  }
}
```

For lockdown, set `strictKnownMarketplaces` in managed settings (empty `[]` blocks all additions).

### Common debugging

| Symptom                 | Cause                            | Fix                                                          |
| :---------------------- | :------------------------------- | :----------------------------------------------------------- |
| Plugin not loading      | Invalid `plugin.json`            | `claude plugin validate`                                     |
| Skills not appearing    | Components inside `.claude-plugin/` | Move to plugin root                                       |
| Hooks not firing        | Script not executable            | `chmod +x script.sh`                                         |
| MCP server fails        | Missing `${CLAUDE_PLUGIN_ROOT}`  | Use the variable for all bundled paths                       |
| Path errors             | Absolute paths used              | All paths must be relative and start with `./`               |
| LSP "executable not found" | Language server not installed | Install the binary separately                                |

Run `claude --debug` to see plugin loading details.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — Tutorial for building plugins, the standalone vs plugin tradeoff, and converting `.claude/` configs into plugins.
- [Plugins reference](references/claude-code-plugins-reference.md) — Complete technical reference: component schemas, plugin.json fields, environment variables, caching, CLI commands, debugging.
- [Discover and install plugins](references/claude-code-discover-plugins.md) — How to find, install, enable, disable, and update plugins from marketplaces, including the official Anthropic catalog.
- [Plugin marketplaces](references/claude-code-plugin-marketplaces.md) — How to author, host, and distribute marketplaces; marketplace.json schema, source types, strict mode, release channels, seed directories, and managed restrictions.

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Plugin marketplaces: https://code.claude.com/docs/en/plugin-marketplaces.md
