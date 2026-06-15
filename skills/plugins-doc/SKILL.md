---
name: plugins-doc
description: Complete official documentation for Claude Code plugins — creating, installing, distributing, and managing plugins with skills, agents, hooks, MCP servers, LSP servers, monitors, and marketplaces. Use when working with plugin.json manifests, plugin directory structure, plugin scopes, marketplace.json, plugin dependencies, version constraints, LSP plugins, or the plugin hint protocol.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for the Claude Code plugin system.

## Quick Reference

### Standalone vs plugin: when to use each

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| Standalone (`.claude/` directory) | `/hello` | Personal workflows, single-project customizations, quick experiments |
| Plugin (directory + optional manifest) | `/plugin-name:hello` | Sharing with teammates, distributing, reusable across projects |

### Plugin directory structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json        # manifest (optional)
├── skills/                # SKILL.md directories
├── commands/              # flat .md skill files (legacy)
├── agents/                # subagent definitions
├── hooks/
│   └── hooks.json         # hook event handlers
├── .mcp.json              # MCP server configs
├── .lsp.json              # LSP server configs
├── monitors/
│   └── monitors.json      # background monitors
├── output-styles/         # output style definitions
├── themes/                # color themes (experimental)
├── bin/                   # executables added to PATH
└── settings.json          # default settings (agent/subagentStatusLine only)
```

Only `plugin.json` goes inside `.claude-plugin/`. All other directories live at the plugin root.

A plugin with exactly one skill may place `SKILL.md` directly at the plugin root. A `name` frontmatter field gives it a stable invocation name; without it, the directory basename is used.

### plugin.json manifest schema

| Field | Type | Notes |
| :--- | :--- | :--- |
| `name` | string | Required. Unique kebab-case identifier; sets skill namespace |
| `displayName` | string | Human-readable UI name (v2.1.143+) |
| `version` | string | Semver. Omit to use git commit SHA (auto-updates on every commit) |
| `description` | string | Shown in plugin manager |
| `author` | object | `name`, `email`, `url` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source repo URL |
| `license` | string | SPDX identifier |
| `keywords` | array | Discovery tags |
| `defaultEnabled` | boolean | Whether plugin starts enabled after install (v2.1.154+, default: true) |
| `skills` | string\|array | Custom skill dirs (adds to default `skills/`) |
| `commands` | string\|array | Custom command files/dirs (replaces default `commands/`) |
| `agents` | string\|array | Custom agent files (replaces default `agents/`) |
| `hooks` | string\|array\|object | Hook config path or inline config |
| `mcpServers` | string\|array\|object | MCP config path or inline config |
| `lspServers` | string\|array\|object | LSP config path or inline config |
| `outputStyles` | string\|array | Output style files/dirs (replaces default) |
| `experimental.themes` | string\|array | Color theme files/dirs |
| `experimental.monitors` | string\|array | Background monitor configs |
| `userConfig` | object | Values prompted at enable time (see below) |
| `channels` | array | Message channel declarations |
| `dependencies` | array | Other plugins required (name or `{name, version, marketplace}`) |

Claude Code ignores unrecognized top-level fields, making `plugin.json` compatible with VS Code, npm `package.json`, and other manifest formats. Run `claude plugin validate --strict` to treat unknown fields as errors.

### Path behavior rules

- `skills`: adds to the default `skills/` (default always scanned)
- `commands`, `agents`, `outputStyles`, `experimental.themes`, `experimental.monitors`: replace the default directory
- All custom paths must be relative, starting with `./`

### Plugin installation scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` (default) | `~/.claude/settings.json` | Personal, all projects |
| `project` | `.claude/settings.json` | Team-shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled, read-only |

### Plugin environment variables

| Variable | Description |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to the plugin's install directory (changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent data directory that survives updates (`~/.claude/plugins/data/{id}/`) |
| `${CLAUDE_PROJECT_DIR}` | Project root (same as `CLAUDE_PROJECT_DIR` in hooks) |

Use `${CLAUDE_PLUGIN_DATA}` for `node_modules`, caches, or any state that should persist across plugin versions. The data directory is deleted on uninstall from the last scope (use `--keep-data` to preserve it).

### userConfig schema

Declared values are prompted when the plugin is enabled. Non-sensitive values are substituted as `${user_config.KEY}` in MCP/LSP/hook/monitor configs and exported as `CLAUDE_PLUGIN_OPTION_<KEY>`.

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label in the config dialog |
| `description` | Yes | Help text |
| `sensitive` | No | Masks input; stores in keychain (~2 KB total limit) |
| `required` | No | Fails validation when empty |
| `default` | No | Value when user provides nothing |
| `multiple` | No | Allow array of strings (string type only) |
| `min` / `max` | No | Bounds for number type |

### Plugin components quick reference

**Skills**: `skills/<name>/SKILL.md` at plugin root. Namespaced as `/plugin-name:skill-name`. Claude auto-invokes based on description.

**Agents**: `agents/*.md` at plugin root. Appear in `/agents`. Support `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation: "worktree"`. `hooks`, `mcpServers`, `permissionMode` not supported for plugin agents.

**Hooks**: `hooks/hooks.json`. Same event lifecycle as user-defined hooks (SessionStart, PreToolUse, PostToolUse, etc.). Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`.

**MCP servers**: `.mcp.json`. Start automatically when plugin is enabled. Use `${CLAUDE_PLUGIN_ROOT}` in command paths.

**LSP servers**: `.lsp.json`. Provides go-to-definition, find-references, diagnostics. Required fields: `command`, `extensionToLanguage`. Optional: `args`, `transport`, `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `maxRestarts`, `diagnostics`.

**Monitors**: `monitors/monitors.json`. Background processes started automatically. Each stdout line delivered to Claude as a notification. Required: `name`, `command`, `description`. Optional: `when` (`"always"` or `"on-skill-invoke:<skill-name>"`). Requires v2.1.105+.

**Themes** (experimental): JSON files in `themes/`. Fields: `name`, `base` (preset), `overrides` (color token map). Appear in `/theme`. Read-only; Ctrl+E copies to `~/.claude/themes/` for editing.

### CLI commands

| Command | Description |
| :--- | :--- |
| `claude plugin init <name>` | Scaffold a plugin in `~/.claude/skills/<name>/`. Aliases: `new`. Options: `--with skills\|agents\|hooks\|mcp\|lsp\|output-style\|channel`, `--description`, `--author`, `--force` |
| `claude plugin install <plugin>[@marketplace]` | Install from a marketplace. `--scope user\|project\|local` |
| `claude plugin uninstall <plugin>` | Remove. `--keep-data` preserves data dir. `--prune` removes orphan dependencies. Aliases: `remove`, `rm` |
| `claude plugin prune` | Remove auto-installed deps no longer required. `--dry-run`, `-y`. Requires v2.1.121+ |
| `claude plugin enable <plugin>` | Enable (also enables dependencies transitively) |
| `claude plugin disable <plugin>` | Disable (fails if another enabled plugin depends on it) |
| `claude plugin update <plugin>` | Update to latest version |
| `claude plugin list` | List installed plugins. `--json`, `--available` |
| `claude plugin details <name>` | Show components and projected token cost |
| `claude plugin tag` | Create release git tag (`{name}--v{version}` convention). `--push`, `--dry-run`, `--force` |
| `claude plugin validate [path]` | Validate manifest, frontmatter, hooks. `--strict` treats warnings as errors |
| `claude --plugin-dir <path>` | Load plugin for one session (also accepts `.zip`). Takes precedence over installed same-name plugin |
| `claude --plugin-url <url>` | Fetch and load a plugin `.zip` from a URL for one session |
| `/reload-plugins` | Pick up plugin changes without restarting |

### Skills-directory plugins

Any folder under a skills directory (`~/.claude/skills/` or `<cwd>/.claude/skills/`) with a `.claude-plugin/plugin.json` manifest loads as `<name>@skills-dir` automatically. No marketplace or install step.

- Personal scope (`~/.claude/skills/`): loads in every project, no restrictions
- Project scope (`<cwd>/.claude/skills/`): requires workspace trust. MCP servers need per-server approval; background monitors do not load

### Version management

Version resolved in order:
1. `version` in plugin's `plugin.json`
2. `version` in marketplace entry
3. Git commit SHA (if git-based source)
4. `unknown` (npm or non-git local)

If using explicit versions, bump `version` on every release — pushing new commits without bumping has no effect for existing users.

### Marketplace structure (`marketplace.json`)

Location: `.claude-plugin/marketplace.json` in the marketplace repository root.

**Required fields**: `name` (kebab-case, public-facing), `owner` (`name` required, `email` optional), `plugins` (array).

**Optional fields**: `description`, `version`, `metadata.pluginRoot` (base path prepended to relative plugin sources), `allowCrossMarketplaceDependenciesOn` (array of marketplace names whose plugins may be depended on).

**Plugin source types**:

| Source | Format | Key fields |
| :--- | :--- | :--- |
| Relative path | `"./plugins/my-plugin"` | Requires git-based marketplace add |
| `github` | `{"source": "github", "repo": "owner/repo"}` | `ref`, `sha` optional |
| `url` | `{"source": "url", "url": "..."}` | `ref`, `sha` optional |
| `git-subdir` | `{"source": "git-subdir", "url": "...", "path": "..."}` | Sparse clone for monorepos |
| `npm` | `{"source": "npm", "package": "@org/plugin"}` | `version`, `registry` optional |

When both `ref` and `sha` are set, `sha` pins the exact commit.

**Strict mode** (`strict` on plugin entry): `true` (default) — `plugin.json` is authority, marketplace entry supplements. `false` — marketplace entry is the entire definition.

### Add marketplaces

```
/plugin marketplace add anthropics/claude-code          # GitHub owner/repo
/plugin marketplace add https://gitlab.com/org/repo.git # Git URL
/plugin marketplace add ./my-marketplace                # Local path
/plugin marketplace add https://example.com/marketplace.json  # Remote URL
```

Add at project scope: `--scope project`. Use `--sparse <dirs>` for monorepos.

Official Anthropic marketplaces:
- `claude-plugins-official` — auto-registered; curated by Anthropic
- `claude-community` (`anthropics/claude-plugins-community`) — third-party, manually added

### Plugin dependency constraints

Declared in `plugin.json` `dependencies` array. Each entry is a name string or `{name, version, marketplace}` object.

`version` field accepts semver ranges: `~2.1.0`, `^2.0`, `>=1.4`, `=2.1.0`. Resolved against git tags in `{plugin-name}--v{version}` format. Multiple plugins constraining the same dependency have their ranges intersected.

Enable/disable with dependencies: enabling a plugin also enables its dependencies; disabling is blocked if another enabled plugin depends on the target (v2.1.143+).

| Dependency error | Meaning | Fix |
| :--- | :--- | :--- |
| `dependency-unsatisfied` | Not installed or disabled | `claude plugin install` the dep, or enable it |
| `range-conflict` | Ranges from two plugins can't be combined | Uninstall/update a conflicting plugin or widen range |
| `dependency-version-unsatisfied` | Installed version outside declared range | Re-run `claude plugin install <dep>@<marketplace>` |
| `no-matching-tag` | No `{name}--v*` tag satisfies range | Ask upstream to tag releases, or relax range |

### Plugin hint protocol

CLIs in the official marketplace can prompt Claude Code users to install their plugin by writing a `<claude-code-hint />` tag to stderr when `CLAUDECODE` or `CLAUDE_CODE_CHILD_SESSION` is set. Claude Code strips the line before the model sees it and shows a one-time install prompt (once per plugin, once per session).

Hint format: `<claude-code-hint v="1" type="plugin" value="example-cli@claude-plugins-official" />`

Requirements: tag must be on its own line; `value` must reference a plugin in an Anthropic-controlled marketplace.

### Debugging

| Issue | Solution |
| :--- | :--- |
| Plugin not loading | Run `claude plugin validate` or `/plugin validate`; check `plugin.json` syntax |
| Skills not appearing | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | `chmod +x` the script; verify event name is case-sensitive |
| MCP server fails | Use `${CLAUDE_PLUGIN_ROOT}` for all plugin paths |
| LSP `Executable not found` | Install the language server binary separately |
| Path errors | All paths must be relative and start with `./` |

Run `claude --debug` to see plugin loading details, component registration, and MCP server initialization.

### Plugin caching

Marketplace plugins are copied to `~/.claude/plugins/cache`. Plugins cannot reference files outside their directory. Use symlinks to share files within a marketplace — symlinks within the plugin's own directory are preserved; symlinks within the same marketplace are dereferenced (content copied); symlinks outside the marketplace are skipped.

### Pre-populate for containers / CI

Set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a pre-built plugins directory. The seed is read-only; auto-updates for seed marketplaces are disabled. Set `CLAUDE_CODE_PLUGIN_CACHE_DIR` during image build to install directly to the seed path.

### Managed marketplace restrictions

`strictKnownMarketplaces` in managed settings controls what marketplaces users can add: empty array = complete lockdown; list of source specs = allowlist. Supports `github`, `url`, `hostPattern` (regex on host), and `pathPattern` (regex on path) entries.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — Creating plugins with skills, agents, hooks, MCP servers; quickstart; plugin structure; testing; migration from standalone; sharing
- [Plugins reference](references/claude-code-plugins-reference.md) — Complete technical specifications: manifest schema, component schemas, CLI commands, environment variables, caching, directory structure, debugging
- [Discover and install plugins](references/claude-code-discover-plugins.md) — Official and community marketplaces; adding marketplaces; installing/managing plugins; LSP plugins; security
- [Create and distribute a marketplace](references/claude-code-plugin-marketplaces.md) — marketplace.json schema, plugin sources, hosting (GitHub/GitLab/npm), private repos, container pre-population, managed restrictions, version channels, troubleshooting
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — Declaring dependencies with semver ranges, cross-marketplace dependencies, git tag convention, constraint intersection, enable/disable behavior, pruning orphans
- [Recommend your plugin from your CLI](references/claude-code-plugin-hints.md) — Plugin hint protocol: emitting `<claude-code-hint />` tags, environment variable gating, hint format and requirements

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
- Recommend your plugin from your CLI: https://code.claude.com/docs/en/plugin-hints.md
