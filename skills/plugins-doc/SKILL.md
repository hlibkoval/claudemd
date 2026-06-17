---
name: plugins-doc
user-invocable: false
description: Complete official documentation for Claude Code plugins — creating, installing, distributing, and managing plugins and marketplaces.
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins.

## Quick Reference

### Standalone vs. Plugin

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| Standalone (`.claude/`) | `/hello` | Personal workflows, single-project customizations |
| Plugin (self-contained dir) | `/plugin-name:hello` | Sharing with teams, versioned releases, multi-project reuse |

### Plugin Directory Structure

| Directory / File | Location | Purpose |
| :--- | :--- | :--- |
| `.claude-plugin/plugin.json` | Plugin root | Manifest (optional if using default locations) |
| `skills/` | Plugin root | Skills as `<name>/SKILL.md` directories |
| `commands/` | Plugin root | Skills as flat `.md` files (legacy; prefer `skills/`) |
| `agents/` | Plugin root | Subagent definitions |
| `hooks/hooks.json` | Plugin root | Event handlers |
| `.mcp.json` | Plugin root | MCP server configurations |
| `.lsp.json` | Plugin root | LSP server configurations |
| `monitors/monitors.json` | Plugin root | Background monitor configs |
| `themes/` | Plugin root | Color theme JSON files |
| `output-styles/` | Plugin root | Output style definitions |
| `bin/` | Plugin root | Executables added to Bash tool's PATH |
| `settings.json` | Plugin root | Default settings (only `agent` and `subagentStatusLine` keys supported) |

WARNING: Only `plugin.json` goes inside `.claude-plugin/`. All other directories must be at the plugin root.

### `plugin.json` Manifest Fields

**Required** (if manifest present):

| Field | Description |
| :--- | :--- |
| `name` | Unique kebab-case identifier; becomes skill namespace |

**Common optional fields:**

| Field | Description |
| :--- | :--- |
| `displayName` | Human-readable name for UI (v2.1.143+) |
| `version` | Explicit semver; omit to use git commit SHA |
| `description` | Brief plugin description |
| `author` | `{ name, email, url }` |
| `homepage` | Documentation URL |
| `repository` | Source code URL |
| `license` | SPDX identifier |
| `keywords` | Discovery tags array |
| `defaultEnabled` | Whether plugin starts enabled (default `true`; v2.1.154+) |
| `dependencies` | Array of `"plugin-name"` or `{ name, version, marketplace }` |
| `userConfig` | Prompts user for values at enable time |
| `channels` | MCP-backed message channels |

**Component path fields** (override defaults):

| Field | Behavior |
| :--- | :--- |
| `skills` | Adds to default `skills/` scan |
| `commands` | Replaces default `commands/` scan |
| `agents` | Replaces default `agents/` scan |
| `hooks` | Inline or path; merged from multiple sources |
| `mcpServers` | Inline or path; merged from multiple sources |
| `lspServers` | Inline or path; merged from multiple sources |
| `outputStyles` | Replaces default `output-styles/` |
| `experimental.themes` | Replaces default `themes/` |
| `experimental.monitors` | Background monitors config |

### Environment Variables Available in Plugin Configs

| Variable | Description |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin's installation directory (ephemeral; changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state across updates (`~/.claude/plugins/data/{id}/`) |
| `${CLAUDE_PROJECT_DIR}` | Project root directory |
| `${user_config.KEY}` | User-supplied config values from `userConfig` field |

### CLI Commands

| Command | Description |
| :--- | :--- |
| `claude plugin init <name>` | Scaffold plugin at `~/.claude/skills/<name>/` |
| `claude plugin install <plugin>[@marketplace]` | Install plugin (default scope: `user`) |
| `claude plugin uninstall <plugin>` | Remove plugin; aliases: `remove`, `rm` |
| `claude plugin enable <plugin>` | Enable a disabled plugin (also enables its dependencies) |
| `claude plugin disable <plugin>` | Disable without uninstalling (blocked if another plugin depends on it) |
| `claude plugin update <plugin>` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin details <name>` | Show component inventory and token cost |
| `claude plugin validate [path]` | Validate `plugin.json`, skill/agent frontmatter, `hooks.json` |
| `claude plugin tag [--push]` | Create release git tag `{plugin-name}--v{version}` |
| `claude plugin prune` | Remove orphaned auto-installed dependencies (v2.1.121+) |
| `claude plugin marketplace add <source>` | Add marketplace |
| `claude plugin marketplace list` | List configured marketplaces |
| `claude plugin marketplace remove <name>` | Remove marketplace (also uninstalls its plugins) |
| `claude plugin marketplace update [name]` | Refresh marketplace listings |

### Installation Scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` (default) | `~/.claude/settings.json` | Personal, all projects |
| `project` | `.claude/settings.json` | Team-shared via version control |
| `local` | `.claude/settings.local.json` | Project-local, gitignored |
| `managed` | Managed settings | Admin-controlled, read-only |

### Plugin Sources (in `marketplace.json`)

| Source type | Format | Notes |
| :--- | :--- | :--- |
| Relative path | `"./plugins/my-plugin"` | Must start with `./`; only works in git-based marketplaces |
| `github` | `{ source: "github", repo: "owner/repo", ref?, sha? }` | |
| `url` | `{ source: "url", url: "https://...", ref?, sha? }` | Any git host |
| `git-subdir` | `{ source: "git-subdir", url, path, ref?, sha? }` | Sparse clone for monorepos |
| `npm` | `{ source: "npm", package: "@scope/name", version?, registry? }` | |

### Hook Events (Plugin Hooks)

Plugin hooks respond to the same events as user-defined hooks. Key events:

| Event | When |
| :--- | :--- |
| `SessionStart` | Session begins or resumes |
| `PreToolUse` | Before tool call (can block) |
| `PostToolUse` | After tool call succeeds |
| `PostToolUseFailure` | After tool call fails |
| `UserPromptSubmit` | Before Claude processes a prompt |
| `Stop` | When Claude finishes responding |
| `FileChanged` | When a watched file changes |
| `SubagentStart` / `SubagentStop` | Subagent lifecycle |

Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`.

### Plugin Agent Frontmatter Fields

| Field | Description |
| :--- | :--- |
| `name` | Agent identifier |
| `description` | When Claude should invoke it |
| `model` | Model to use |
| `effort` | Effort level |
| `maxTurns` | Max conversation turns |
| `tools` / `disallowedTools` | Tool allow/deny lists |
| `skills` / `memory` / `background` / `isolation` | Additional options |

Note: `hooks`, `mcpServers`, and `permissionMode` are NOT supported for plugin agents. The only valid `isolation` value is `"worktree"`.

### LSP Server Config Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `command` | Yes | LSP binary to execute |
| `extensionToLanguage` | Yes | Maps file extensions to language IDs |
| `args` | No | Command-line arguments |
| `transport` | No | `stdio` (default) or `socket` |
| `env` | No | Environment variables |
| `diagnostics` | No | Push diagnostics after edits (default `true`) |

### Monitor Config Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier within the plugin |
| `command` | Yes | Persistent shell command |
| `description` | Yes | Short summary shown in task panel |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

### `userConfig` Option Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label in configuration dialog |
| `description` | Yes | Help text |
| `sensitive` | No | Masks input; stores in system keychain |
| `required` / `default` | No | Validation and default value |
| `multiple` | No | Allow array of strings (string type only) |
| `min` / `max` | No | Bounds for number type |

### Version Management

Version resolution order (first wins):
1. `version` in `plugin.json`
2. `version` in marketplace entry
3. Git commit SHA (for git-backed sources)
4. `unknown` (npm or non-git local)

If `version` is set explicitly, bump it on every release — pushing new commits without bumping has no effect for existing users.

### Dependency Version Constraints

Declare in `plugin.json`:
```json
{
  "dependencies": [
    "audit-logger",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```

Tag releases for version resolution: `claude plugin tag --push` creates a `{plugin-name}--v{version}` git tag.

| Error | Meaning |
| :--- | :--- |
| `dependency-unsatisfied` | Dependency not installed or disabled |
| `range-conflict` | Version ranges from multiple plugins cannot be combined |
| `dependency-version-unsatisfied` | Installed version outside declared range |
| `no-matching-tag` | No git tag satisfies the range |

### Plugin Hints (CLI → Claude Code)

CLI tools in the official marketplace can recommend themselves by writing a self-closing tag to stderr when `CLAUDECODE=1`:

```
<claude-code-hint v="1" type="plugin" value="example-cli@claude-plugins-official" />
```

Only plugins in official Anthropic marketplaces (`claude-plugins-official`) are acted on. The tag is stripped from output before reaching the model.

### Official Marketplaces

| Marketplace | How to add | Contents |
| :--- | :--- | :--- |
| `claude-plugins-official` | Auto-registered on first interactive launch | Curated by Anthropic; includes LSP plugins, integrations, dev workflows |
| `claude-plugins-community` | `/plugin marketplace add anthropics/claude-plugins-community` | Third-party plugins passing Anthropic's screening |
| Demo (`claude-code-plugins`) | `/plugin marketplace add anthropics/claude-code` | Example plugins |

### Skills-Directory Plugins

Any folder under `~/.claude/skills/` or `<cwd>/.claude/skills/` containing `.claude-plugin/plugin.json` auto-loads as `<name>@skills-dir`. Scaffold with `claude plugin init <name>`. No marketplace or install step needed.

### Managed Marketplace Restrictions

`strictKnownMarketplaces` in managed settings controls which marketplaces users can add:
- Undefined (default): no restrictions
- Empty array `[]`: complete lockdown
- Array of sources: allowlist

### Pre-populate Plugins for Containers

Set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a directory mirroring `~/.claude/plugins/`. Seed entries take precedence over user config; auto-updates are disabled for seed marketplaces (read-only). Build with `CLAUDE_CODE_PLUGIN_CACHE_DIR` pointing at the target path.

### Debugging

| Issue | Solution |
| :--- | :--- |
| Plugin not loading | `claude plugin validate ./my-plugin` or `/plugin validate` |
| Skills not appearing | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | `chmod +x script.sh`; check event names are case-correct |
| MCP server fails | Use `${CLAUDE_PLUGIN_ROOT}` for all plugin paths |
| LSP binary not found | Install the binary; check the `/plugin` Errors tab |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — Creating plugins with skills, agents, hooks, MCP/LSP servers; quickstart; plugin structure; migration from standalone
- [Plugins reference](references/claude-code-plugins-reference.md) — Complete technical spec: manifest schema, component configs, CLI commands, env vars, caching, debugging
- [Discover and install plugins](references/claude-code-discover-plugins.md) — Finding and installing plugins from marketplaces; managing installed plugins and marketplaces; security
- [Create and distribute a marketplace](references/claude-code-plugin-marketplaces.md) — Building and hosting marketplace catalogs; plugin sources; version channels; managed restrictions; container seeding
- [Plugin dependencies](references/claude-code-plugin-dependencies.md) — Declaring version constraints; tagging releases; cross-marketplace deps; resolving dependency errors
- [Plugin hints](references/claude-code-plugin-hints.md) — Recommending plugins from CLI tools via the `claude-code-hint` marker protocol

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Plugin dependencies: https://code.claude.com/docs/en/plugin-dependencies.md
- Plugin hints: https://code.claude.com/docs/en/plugin-hints.md
