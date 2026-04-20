---
name: plugins-doc
description: Complete official documentation for Claude Code plugins — creating plugins, plugin manifest schema, plugin components (skills, agents, hooks, MCP, LSP, monitors), discovering and installing plugins, plugin marketplaces, dependency version constraints, CLI commands, and debugging.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

A **plugin** is a self-contained directory that extends Claude Code with skills, agents, hooks, MCP servers, LSP servers, monitors, and more. Plugins are namespaced (e.g., `/my-plugin:hello`) so they never conflict with each other.

### When to use plugins vs standalone

| Approach               | Skill name format       | Best for                                                     |
| :--------------------- | :---------------------- | :----------------------------------------------------------- |
| **Standalone** (`.claude/`) | `/hello`           | Personal workflows, single-project customization             |
| **Plugin**             | `/plugin-name:hello`    | Sharing with teams, distribution via marketplaces, reuse     |

### Plugin directory structure

```
my-plugin/
  .claude-plugin/plugin.json   <- Manifest (only file in .claude-plugin/)
  skills/<name>/SKILL.md       <- Skills
  commands/<name>.md           <- Flat-file skills (legacy; prefer skills/)
  agents/<name>.md             <- Subagent definitions
  hooks/hooks.json             <- Hook configurations
  monitors/monitors.json       <- Background monitor configurations
  bin/                         <- Executables added to Bash tool PATH
  settings.json                <- Default settings (agent, subagentStatusLine)
  .mcp.json                    <- MCP server definitions
  .lsp.json                    <- LSP server configurations
```

Components must be at the plugin root, NOT inside `.claude-plugin/`.

### Plugin manifest (plugin.json)

The manifest is optional. If omitted, components are auto-discovered. `name` is the only required field when present.

| Field         | Type            | Description                                       |
| :------------ | :-------------- | :------------------------------------------------ |
| `name`        | string          | Unique identifier (kebab-case). Namespaces skills |
| `version`     | string          | Semantic version (`MAJOR.MINOR.PATCH`)            |
| `description` | string          | Brief plugin purpose                              |
| `author`      | object          | `{name, email?, url?}`                            |
| `homepage`    | string          | Documentation URL                                 |
| `repository`  | string          | Source code URL                                    |
| `license`     | string          | SPDX license identifier                           |
| `keywords`    | array           | Discovery tags                                    |
| `dependencies`| array           | Other plugins this plugin requires                |
| `userConfig`  | object          | User-configurable values prompted at enable time  |
| `channels`    | array           | Message channel declarations                      |

**Component path fields** (`skills`, `commands`, `agents`, `hooks`, `mcpServers`, `lspServers`, `outputStyles`, `monitors`): custom paths replace defaults. Include the default directory in an array to keep it: `"skills": ["./skills/", "./extras/"]`.

### Environment variables

| Variable               | Purpose                                                                     |
| :--------------------- | :-------------------------------------------------------------------------- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin installation directory. Changes on update          |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state (`~/.claude/plugins/data/{id}/`). Survives updates |
| `${user_config.*}`     | User-configurable values from `userConfig`. Available in MCP/LSP/hooks/monitors |

Both are substituted inline in skill content, agent content, hook commands, monitor commands, and MCP/LSP server configs. Also exported as env vars to subprocesses.

### Plugin components

**Skills**: `skills/<name>/SKILL.md` directories or `commands/<name>.md` flat files. Auto-discovered. See the skills-doc skill for authoring details.

**Agents**: `agents/<name>.md` files with frontmatter (`name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation`). Appear in `/agents`. Hooks, mcpServers, and permissionMode are NOT supported for plugin agents.

**Hooks**: `hooks/hooks.json` or inline in `plugin.json`. Same lifecycle events as user-defined hooks.

| Hook event           | When it fires                                          |
| :------------------- | :----------------------------------------------------- |
| `SessionStart`       | Session begins or resumes                              |
| `UserPromptSubmit`   | Prompt submitted, before processing                    |
| `PreToolUse`         | Before tool call (can block)                           |
| `PostToolUse`        | After tool call succeeds                               |
| `PostToolUseFailure` | After tool call fails                                  |
| `PermissionRequest`  | Permission dialog appears                              |
| `PermissionDenied`   | Tool call denied by classifier                         |
| `Stop`               | Claude finishes responding                             |
| `StopFailure`        | Turn ends due to API error                             |
| `Notification`       | Notification sent                                      |
| `SubagentStart/Stop` | Subagent spawned / finished                            |
| `TaskCreated`        | Task being created via TaskCreate                      |
| `TaskCompleted`      | Task being marked completed                            |
| `TeammateIdle`       | Agent team teammate about to go idle                   |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded into context            |
| `ConfigChange`       | Configuration file changes during session              |
| `CwdChanged`         | Working directory changes                              |
| `FileChanged`        | Watched file changes on disk                           |
| `WorktreeCreate/Remove` | Worktree created or removed                         |
| `PreCompact/PostCompact` | Before/after context compaction                    |
| `Elicitation`        | MCP server requests user input                         |
| `ElicitationResult`  | User responds to MCP elicitation                       |
| `SessionEnd`         | Session terminates                                     |

Hook types: `command`, `http`, `prompt`, `agent`.

**MCP servers**: `.mcp.json` or inline in `plugin.json`. Start automatically when the plugin is enabled.

**LSP servers**: `.lsp.json` or inline in `plugin.json`. Required fields: `command`, `extensionToLanguage`. Optional: `args`, `transport`, `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`. The language server binary must be installed separately.

**Monitors**: `monitors/monitors.json` or inline in `plugin.json`. Array of entries with `name`, `command`, `description` (required) and `when` (optional: `"always"` default or `"on-skill-invoke:<skill-name>"`). Each stdout line is delivered to Claude as a notification.

**bin/**: Executables here are added to the Bash tool's PATH while the plugin is active.

**settings.json**: Default settings applied when the plugin is enabled. Only `agent` and `subagentStatusLine` keys are supported. Setting `agent` activates a plugin subagent as the main thread.

### Installation scopes

| Scope     | Settings file                     | Use case                                |
| :-------- | :-------------------------------- | :-------------------------------------- |
| `user`    | `~/.claude/settings.json`        | Personal, all projects (default)        |
| `project` | `.claude/settings.json`          | Team, shared via version control        |
| `local`   | `.claude/settings.local.json`    | Personal, project-specific, gitignored  |
| `managed` | Managed settings                 | Admin-controlled (read-only, update only) |

### Plugin CLI commands

| Command                                  | Description                              |
| :--------------------------------------- | :--------------------------------------- |
| `claude plugin install <plugin> [-s scope]` | Install a plugin                       |
| `claude plugin uninstall <plugin> [-s scope] [--keep-data]` | Remove a plugin        |
| `claude plugin enable <plugin> [-s scope]`  | Enable a disabled plugin               |
| `claude plugin disable <plugin> [-s scope]` | Disable without uninstalling           |
| `claude plugin update <plugin> [-s scope]`  | Update to latest version               |
| `claude plugin list [--json] [--available]` | List installed plugins                 |
| `claude plugin validate`                 | Validate plugin structure               |

In-session: `/plugin install`, `/plugin uninstall`, `/reload-plugins`.

### Discover and install plugins

**Official marketplace** (`claude-plugins-official`): automatically available. Browse via `/plugin` Discover tab or [claude.com/plugins](https://claude.com/plugins).

**Add a marketplace**:
- GitHub: `/plugin marketplace add owner/repo`
- Git URL: `/plugin marketplace add https://gitlab.com/company/plugins.git`
- Local: `/plugin marketplace add ./my-marketplace`
- URL: `/plugin marketplace add https://example.com/marketplace.json`

Pin to branch/tag: append `#ref` to git URL or `@ref` to GitHub shorthand.

**Manage marketplaces**: `marketplace list`, `marketplace update [name]`, `marketplace remove name`.

**Auto-updates**: official marketplaces auto-update by default. Toggle per-marketplace via `/plugin` > Marketplaces. Disable all with `DISABLE_AUTOUPDATER`. Keep plugin auto-updates while disabling Claude Code auto-updates: `FORCE_AUTOUPDATE_PLUGINS=1`.

**Team marketplaces**: add `extraKnownMarketplaces` and `enabledPlugins` to `.claude/settings.json`.

### Plugin marketplaces

A marketplace is defined by `.claude-plugin/marketplace.json` in a repository.

**Required fields**: `name` (kebab-case), `owner` (`{name, email?}`), `plugins` (array).

**Plugin entry fields**: `name`, `source` (required); `description`, `version`, `author`, `homepage`, `category`, `tags`, `strict` (optional).

**Plugin sources**:

| Source type   | Format                                    | Notes                                   |
| :------------ | :---------------------------------------- | :-------------------------------------- |
| Relative path | `"./plugins/my-plugin"`                   | Within same repo. Must start with `./`  |
| `github`      | `{source: "github", repo: "owner/repo"}` | Optional `ref`, `sha`                   |
| `url`         | `{source: "url", url: "https://..."}`     | Git URL source. Optional `ref`, `sha`   |
| `git-subdir`  | `{source: "git-subdir", url, path}`       | Sparse clone of subdirectory            |
| `npm`         | `{source: "npm", package: "@org/pkg"}`    | Optional `version`, `registry`          |

**Strict mode** (`strict` field): `true` (default) = `plugin.json` is authority, marketplace supplements. `false` = marketplace entry is the entire definition.

**Managed restrictions**: `strictKnownMarketplaces` in managed settings controls which marketplaces users may add (undefined = no restriction, `[]` = complete lockdown, list = allowlist). Supports `github`, `url`, `hostPattern`, and `pathPattern` source types.

**Container pre-population**: set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a pre-populated `~/.claude/plugins` mirror. Seed is read-only; auto-updates disabled for seed marketplaces.

### Plugin caching

Marketplace plugins are copied to `~/.claude/plugins/cache`. Previous versions are kept 7 days (grace period for running sessions). Glob and Grep skip orphaned versions. Plugins cannot reference files outside their directory (use symlinks for external dependencies).

### Dependency version constraints

Declare in `dependencies` array of `plugin.json`:

```json
{
  "dependencies": [
    "audit-logger",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```

Version field accepts semver ranges (`~2.1.0`, `^2.0`, `>=1.4`, `=2.1.0`). Dependencies resolve against git tags named `{plugin-name}--v{version}`. Multiple plugins constraining the same dependency have their ranges intersected.

| Error                           | Meaning                                       | Fix                                             |
| :------------------------------ | :-------------------------------------------- | :---------------------------------------------- |
| `range-conflict`                | Version requirements cannot be combined        | Uninstall/update conflicting plugin or widen range |
| `dependency-version-unsatisfied`| Installed version outside declared range       | Reinstall dependency                            |
| `no-matching-tag`               | No tag satisfies the range                     | Check upstream tags or relax range              |

### Testing plugins locally

```bash
claude --plugin-dir ./my-plugin
```

Load multiple: `--plugin-dir ./one --plugin-dir ./two`. Local `--plugin-dir` overrides installed marketplace plugin of the same name. Use `/reload-plugins` to pick up changes without restarting.

### Common debugging issues

| Issue                     | Solution                                                     |
| :------------------------ | :----------------------------------------------------------- |
| Plugin not loading        | Run `claude plugin validate` or `/plugin validate`           |
| Skills not appearing      | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing          | Check script is executable (`chmod +x`), event name is case-sensitive |
| MCP server fails          | Use `${CLAUDE_PLUGIN_ROOT}` for all paths                   |
| LSP binary not found      | Install the language server binary separately                |
| Path errors               | All paths must be relative, starting with `./`               |

Use `claude --debug` for detailed plugin loading output.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — tutorial for creating plugins with skills, agents, hooks, MCP servers, LSP servers, and monitors; quickstart; plugin structure; converting standalone configs to plugins; testing locally.
- [Plugins reference](references/claude-code-plugins-reference.md) — complete technical reference covering plugin manifest schema, all component specifications (skills, agents, hooks, MCP, LSP, monitors), installation scopes, environment variables, persistent data directory, caching and file resolution, CLI commands, debugging tools, and version management.
- [Discover and install plugins](references/claude-code-discover-plugins.md) — finding and installing plugins from marketplaces; official marketplace and its categories (code intelligence, external integrations, development workflows, output styles); adding marketplaces from GitHub, Git, local paths, and URLs; managing installed plugins; auto-updates; team marketplace configuration; troubleshooting.
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — creating marketplace.json; marketplace schema; plugin entry fields; plugin sources (relative, GitHub, Git, git-subdir, npm); strict mode; hosting and distribution; private repos; managed marketplace restrictions; container pre-population; release channels; validation and testing; troubleshooting.
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring version constraints in plugin.json; semver ranges; tagging releases for version resolution; constraint intersection; resolving dependency errors.

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
