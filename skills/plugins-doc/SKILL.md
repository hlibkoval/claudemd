---
name: plugins-doc
user-invocable: false
description: Complete official documentation for Claude Code plugins — creating, distributing, discovering, and managing plugins and marketplaces.
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

### Plugin vs Standalone Configuration

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugins** (self-contained dir with manifest) | `/plugin-name:hello` | Sharing with team, distributing, versioned releases, reuse across projects |

### Plugin Directory Structure

| Directory | Location | Purpose |
| :--- | :--- | :--- |
| `.claude-plugin/plugin.json` | Plugin root | Manifest (optional) |
| `skills/` | Plugin root | Skills as `<name>/SKILL.md` directories |
| `commands/` | Plugin root | Skills as flat Markdown files (use `skills/` for new plugins) |
| `agents/` | Plugin root | Custom agent definitions |
| `hooks/hooks.json` | Plugin root | Event handlers |
| `.mcp.json` | Plugin root | MCP server configurations |
| `.lsp.json` | Plugin root | LSP server configurations |
| `monitors/monitors.json` | Plugin root | Background monitor configs |
| `bin/` | Plugin root | Executables added to `PATH` |
| `settings.json` | Plugin root | Default settings (only `agent` and `subagentStatusLine` keys supported) |
| `themes/` | Plugin root | Color theme definitions (experimental) |

**Common mistake**: Never put `commands/`, `agents/`, `skills/`, or `hooks/` inside `.claude-plugin/`. Only `plugin.json` goes there.

### Minimal plugin.json Schema

```json
{
  "name": "my-plugin",
  "description": "Brief description",
  "version": "1.0.0",
  "author": { "name": "Your Name" }
}
```

**Required field**: only `name` (if manifest is present). Fields with the wrong type fail; unrecognized fields are silently ignored (warnings via `--strict`).

### Full plugin.json Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique identifier (kebab-case); used for skill namespace |
| `displayName` | string | Human-readable name shown in UI (v2.1.143+) |
| `version` | string | If set, users only get updates when bumped; omit to use git SHA |
| `description` | string | Brief plugin purpose |
| `author` | object | `name`, `email`, `url` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier |
| `keywords` | array | Discovery tags |
| `defaultEnabled` | boolean | If `false`, plugin installs disabled (v2.1.154+) |
| `skills` | string\|array | Adds to default `skills/` scan |
| `commands` | string\|array | Replaces default `commands/` |
| `agents` | string\|array | Replaces default `agents/` |
| `hooks` | string\|array\|object | Hook config paths or inline |
| `mcpServers` | string\|array\|object | MCP configs |
| `lspServers` | string\|array\|object | LSP configs |
| `outputStyles` | string\|array | Output style files/dirs |
| `experimental.themes` | string\|array | Color themes |
| `experimental.monitors` | string\|array | Background monitor configs |
| `userConfig` | object | Values prompted at enable time |
| `channels` | array | Message channel declarations |
| `dependencies` | array | Other plugins this plugin requires |

### Environment Variables in Plugins

| Variable | Description |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin install dir (changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent dir for state/deps that survives updates (`~/.claude/plugins/data/{id}/`) |
| `${CLAUDE_PROJECT_DIR}` | Project root (same as hooks' `CLAUDE_PROJECT_DIR`) |

### CLI Commands Reference

| Command | Description |
| :--- | :--- |
| `claude plugin init <name>` | Scaffold plugin at `~/.claude/skills/<name>/` |
| `claude plugin install <plugin>[@marketplace]` | Install from marketplace |
| `claude plugin uninstall <plugin>` | Remove plugin (`--keep-data`, `--prune`) |
| `claude plugin prune` | Remove orphaned auto-installed deps (v2.1.121+) |
| `claude plugin enable <plugin>` | Enable disabled plugin (enables dependencies too) |
| `claude plugin disable <plugin>` | Disable plugin (blocked if another plugin depends on it) |
| `claude plugin update <plugin>` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin details <name>` | Show component inventory + token cost estimate |
| `claude plugin tag [--push]` | Create release git tag (`{name}--v{version}`) |
| `claude plugin validate [path]` | Validate manifest and component files |
| `claude plugin marketplace add <source>` | Add marketplace |
| `claude plugin marketplace list` | List configured marketplaces |
| `claude plugin marketplace remove <name>` | Remove marketplace + its plugins |
| `claude plugin marketplace update [name]` | Refresh marketplace catalog |

### Installation Scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` (default) | `~/.claude/settings.json` | Personal, across all projects |
| `project` | `.claude/settings.json` | Team plugins via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled, read-only |

### Marketplace Schema (marketplace.json)

Located at `.claude-plugin/marketplace.json`. Required fields: `name`, `owner`, `plugins`.

**Plugin sources** in `marketplace.json`:

| Source | Type | Notes |
| :--- | :--- | :--- |
| Relative path `"./my-plugin"` | string | Local dir within marketplace repo; requires git-based add |
| `github` | object | `repo` (required), `ref?`, `sha?` |
| `url` | object | `url` (required), `ref?`, `sha?` |
| `git-subdir` | object | `url`, `path` (required), `ref?`, `sha?`; sparse checkout |
| `npm` | object | `package` (required), `version?`, `registry?` |

Version resolution order: (1) `version` in `plugin.json`, (2) `version` in marketplace entry, (3) git commit SHA.

### Hook Events in Plugins (from hooks/hooks.json)

Plugin hooks use `hooks/hooks.json` (same format as user hooks). Key events: `SessionStart`, `PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `Stop`, and many more. Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`.

### LSP Server Config Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `command` | Yes | LSP binary to execute |
| `extensionToLanguage` | Yes | Maps file extensions to language IDs |
| `args` | No | Command-line arguments |
| `transport` | No | `stdio` (default) or `socket` |
| `env` | No | Environment variables |
| `diagnostics` | No | Push diagnostics after edits (default `true`) |

### Background Monitors

Declared in `monitors/monitors.json` (array). Each entry:

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier within plugin |
| `command` | Yes | Shell command run as persistent background process |
| `description` | Yes | Summary shown in task panel |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

Requires Claude Code v2.1.105+. Only runs in interactive CLI sessions.

### userConfig Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label in dialog |
| `description` | Yes | Help text |
| `sensitive` | No | Mask input + store in keychain |
| `required` | No | Fail validation if empty |
| `default` | No | Value when user provides nothing |
| `multiple` | No | Allow array (string type only) |
| `min`/`max` | No | Bounds for number type |

Values available as `${user_config.KEY}` in MCP/LSP/hook/monitor configs; exported as `CLAUDE_PLUGIN_OPTION_<KEY>` env vars.

### Plugin Dependencies

Declared in `plugin.json` `dependencies` array. Entry: bare string (name only) or object with `name`, `version` (semver range), `marketplace`.

Tag releases as `{plugin-name}--v{version}` using `claude plugin tag --push`. Version resolution checks git tags on the marketplace repo.

| Error | Meaning |
| :--- | :--- |
| `dependency-unsatisfied` | Dependency not installed or disabled |
| `range-conflict` | Ranges from multiple plugins cannot be intersected |
| `dependency-version-unsatisfied` | Installed version outside declared range |
| `no-matching-tag` | No `{name}--v*` tag satisfies the range |

### Plugin Hints (CLI Recommendation)

CLIs in the official marketplace can emit a self-closing tag to stderr to prompt users to install a plugin:

```
<claude-code-hint v="1" type="plugin" value="example-cli@claude-plugins-official" />
```

Gate emission on `CLAUDECODE` env var (set in all Claude Code subprocesses) or `CLAUDE_CODE_CHILD_SESSION` (set only in tool-call subprocesses, v2.1.172+). Claude Code strips the tag from output before sending to the model. Prompt appears at most once per plugin per session.

### Plugin Relevance (Org Suggestions)

Add `relevance` block to a plugin's marketplace entry. Requires admin to allowlist marketplace via `pluginSuggestionMarketplaces` in managed settings.

| Signal | Description |
| :--- | :--- |
| `cwd` | Glob patterns matched against session working directory (only signal that fires at session start) |
| `cli` | Command names from shell commands run this session |
| `hosts` | Hostnames seen in `http://`/`https://` URLs in Bash commands |
| `filesRead` | Glob patterns matched against files Claude has read |
| `manifestDeps` | Regex patterns for manifest files + their contents |

### Testing Plugins Locally

```bash
# Load from directory
claude --plugin-dir ./my-plugin

# Load from zip (v2.1.128+)
claude --plugin-dir ./my-plugin.zip

# Load from URL
claude --plugin-url https://example.com/my-plugin.zip

# Multiple plugins
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

Use `/reload-plugins` to pick up changes without restarting.

### Debugging Common Issues

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` |
| Skills not appearing | Wrong directory structure | Ensure `skills/` at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Script not executable | `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin paths |
| LSP `Executable not found` | Language server not installed | Install binary separately |

### Skills-Directory Plugins

Any folder in a skills directory containing `.claude-plugin/plugin.json` loads as `<name>@skills-dir`. Created via `claude plugin init <name>`.

| Skills dir | Scope | When |
| :--- | :--- | :--- |
| `~/.claude/skills/` | personal | Every project |
| `<cwd>/.claude/skills/` | project | After workspace trust accepted |

### Managed Marketplace Restrictions

`strictKnownMarketplaces` in managed settings controls what users can add. Empty array = complete lockdown. List of sources = allowlist. Supports `hostPattern` and `pathPattern` for flexible matching.

Container/CI pre-population: set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a pre-built `~/.claude/plugins`-structured directory. Seed is read-only; auto-updates disabled for seed marketplaces.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — Authoring guide: quickstart, directory structure, skills, LSP servers, monitors, hooks, MCP, agents, conversion from standalone, distribution
- [Plugins reference](references/claude-code-plugins-reference.md) — Complete technical reference: full manifest schema, all component specs, CLI commands, debugging, versioning
- [Discover and install plugins](references/claude-code-discover-plugins.md) — Finding and installing plugins from official, community, and custom marketplaces
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — Building marketplace.json, plugin sources, hosting, private repos, managed restrictions, troubleshooting
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — Declaring dependencies, semver constraints, tagging releases, conflict resolution
- [Recommend your plugin from your CLI](references/claude-code-plugin-hints.md) — The `<claude-code-hint />` protocol for CLI tools to prompt plugin installation
- [Recommend plugins for your org](references/claude-code-plugin-relevance.md) — Adding `relevance` signals to marketplace entries for org-wide plugin suggestions

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
- Recommend your plugin from your CLI: https://code.claude.com/docs/en/plugin-hints.md
- Recommend plugins for your org: https://code.claude.com/docs/en/plugin-relevance.md
