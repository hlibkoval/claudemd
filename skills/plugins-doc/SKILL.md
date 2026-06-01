---
name: plugins-doc
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins: creating, discovering, distributing, and configuring plugins and marketplaces.

## Quick Reference

### Standalone vs Plugin

| Approach | Skill names | Best for |
|:---------|:------------|:---------|
| Standalone (`.claude/` directory) | `/hello` | Personal workflows, single-project customizations |
| Plugin (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with team/community, versioned releases, multi-project reuse |

### Plugin Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json       ← ONLY manifest here
├── skills/               ← Skills as <name>/SKILL.md
├── commands/             ← Skills as flat .md files (legacy; prefer skills/)
├── agents/               ← Subagent definitions
├── hooks/hooks.json      ← Event handlers
├── .mcp.json             ← MCP server configs
├── .lsp.json             ← LSP server configs
├── monitors/monitors.json← Background monitors
├── themes/               ← Color themes (experimental)
├── output-styles/        ← Output style definitions
├── bin/                  ← Executables added to PATH
└── settings.json         ← Default settings (agent, subagentStatusLine only)
```

### plugin.json — Required and Common Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier (kebab-case); becomes skill namespace |
| `displayName` | No | Human-readable name in UI (v2.1.143+) |
| `version` | No | Explicit semver; if omitted, git commit SHA is used |
| `description` | No | Short description shown in plugin manager |
| `author` | No | `{ name, email, url }` |
| `homepage` | No | Documentation URL |
| `repository` | No | Source code URL |
| `license` | No | SPDX identifier (e.g. `"MIT"`) |
| `keywords` | No | Array of discovery tags |
| `defaultEnabled` | No | `false` to ship disabled (v2.1.154+) |
| `dependencies` | No | Other plugins required; supports semver constraints |
| `userConfig` | No | Values prompted at enable time |
| `experimental.monitors` | No | Background monitors array or path |
| `experimental.themes` | No | Color theme files/dirs |

**Component path fields** (all accept string or array; paths must be relative and start with `./`):

| Field | Replaces or adds to default? |
|:------|:-----------------------------|
| `skills` | Adds to `skills/` (default always scanned) |
| `commands` | Replaces `commands/` |
| `agents` | Replaces `agents/` |
| `hooks` | Own merge rules |
| `mcpServers` | Own merge rules |
| `lspServers` | Own merge rules |
| `outputStyles` | Replaces `output-styles/` |

### Environment Variables in Plugin Configs

| Variable | Value |
|:---------|:------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin install dir (changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent state dir (`~/.claude/plugins/data/{id}/`); survives updates |
| `${CLAUDE_PROJECT_DIR}` | Project root (same as hooks' `CLAUDE_PROJECT_DIR`) |
| `${user_config.KEY}` | User-supplied config value (declared in `userConfig`) |

### Plugin Installation Scopes

| Scope | Settings file | Use case |
|:------|:-------------|:---------|
| `user` (default) | `~/.claude/settings.json` | Personal, all projects |
| `project` | `.claude/settings.json` | Team, via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | managed-settings.json | Admin-enforced, read-only |

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude plugin init <name>` | Scaffold a new plugin in `~/.claude/skills/<name>/` |
| `claude plugin install <plugin>[@marketplace]` | Install a plugin |
| `claude plugin uninstall <plugin>` | Remove a plugin |
| `claude plugin enable <plugin>` | Enable a disabled plugin (also enables dependencies) |
| `claude plugin disable <plugin>` | Disable without uninstalling (blocked if another plugin depends on it) |
| `claude plugin update <plugin>` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin details <name>` | Show component inventory and token cost |
| `claude plugin prune` | Remove orphaned auto-installed dependencies |
| `claude plugin tag [--push]` | Create release git tag for version resolution |
| `claude plugin validate [path]` | Validate plugin or marketplace JSON |
| `claude plugin marketplace add <source>` | Add a marketplace |
| `claude plugin marketplace list` | List configured marketplaces |
| `claude plugin marketplace remove <name>` | Remove a marketplace |
| `claude plugin marketplace update [name]` | Refresh marketplace listings |

**In-session commands:** `/plugin`, `/reload-plugins`, `/plugin install`, `/plugin enable`, `/plugin disable`, `/plugin uninstall`, `/plugin marketplace add`

### Development Workflow

1. Create plugin dir with `.claude-plugin/plugin.json`
2. Add skills in `skills/<name>/SKILL.md`
3. Test locally: `claude --plugin-dir ./my-plugin`
4. Or test from zip: `claude --plugin-dir ./my-plugin.zip` (v2.1.128+)
5. Or test from URL: `claude --plugin-url https://example.com/my-plugin.zip`
6. Iterate: `/reload-plugins` picks up changes without restart
7. Multiple plugins: repeat `--plugin-dir` or `--plugin-url` flags

### Version Management

| Approach | How | Update behavior |
|:---------|:----|:----------------|
| Explicit version | Set `"version"` in `plugin.json` | Users get updates only when you bump the field |
| Commit-SHA version | Omit `version` everywhere | Every new commit is a new version |

Tag format for dependency resolution: `{plugin-name}--v{version}` (use `claude plugin tag --push`).

### Marketplace File (`marketplace.json`)

Location: `.claude-plugin/marketplace.json` in the marketplace repository.

**Required fields:** `name`, `owner` (`{ name, email? }`), `plugins` (array)

**Plugin source types:**

| Type | Example `source` value | Notes |
|:-----|:-----------------------|:------|
| Relative path | `"./plugins/my-plugin"` | Only works with git-based marketplace installs |
| GitHub | `{ "source": "github", "repo": "owner/repo", "ref"?, "sha"? }` | |
| Git URL | `{ "source": "url", "url": "https://…", "ref"?, "sha"? }` | |
| Git subdir | `{ "source": "git-subdir", "url": "…", "path": "tools/plugin", "ref"?, "sha"? }` | Sparse clone |
| npm | `{ "source": "npm", "package": "@scope/pkg", "version"?, "registry"? }` | |

### Plugin Dependencies

Declare in `dependencies` array in `plugin.json`:

```json
"dependencies": [
  "audit-logger",
  { "name": "secrets-vault", "version": "~2.1.0" }
]
```

- Semver ranges: `~2.1.0`, `^2.0`, `>=1.4`, `=2.1.0`
- Cross-marketplace deps require `allowCrossMarketplaceDependenciesOn` in the root marketplace
- Enabling a plugin auto-enables its dependencies; disabling is blocked if another plugin needs it
- Clean up orphaned deps: `claude plugin prune` (v2.1.121+)

**Common dependency errors:**

| Error | Fix |
|:------|:----|
| `dependency-unsatisfied` | Run `claude plugin install <dep>@<marketplace>` |
| `range-conflict` | Uninstall/update a conflicting plugin or widen constraint |
| `dependency-version-unsatisfied` | Re-resolve: `claude plugin install <dep>@<marketplace>` |
| `no-matching-tag` | Check upstream has `{name}--v*` tags or relax range |

### Plugin Hints (CLI Recommendation)

CLIs in the official marketplace can prompt users to install a companion plugin. Write a `<claude-code-hint />` tag to stderr when `CLAUDECODE=1`:

```
<claude-code-hint v="1" type="plugin" value="example-cli@claude-plugins-official" />
```

Requirements: tag on its own line; `value` must reference `claude-plugins-official`. Claude Code strips it before the model sees the output.

### Skills-Directory Plugins

Any folder under `~/.claude/skills/` or `<cwd>/.claude/skills/` with a `.claude-plugin/plugin.json` loads automatically as `<name>@skills-dir` — no marketplace needed.

| Context | Scope | Restrictions |
|:--------|:------|:-------------|
| `~/.claude/skills/` | Personal | None |
| `<cwd>/.claude/skills/` | Project (after trust) | No background monitors; MCP/LSP need per-server approval |

Disable: `claude plugin disable my-tool@skills-dir`

### Official Anthropic Marketplaces

| Marketplace | How to access | Description |
|:-----------|:-------------|:------------|
| `claude-plugins-official` | Auto-available; `/plugin` Discover tab | Curated by Anthropic |
| `claude-community` (`anthropics/claude-plugins-community`) | `/plugin marketplace add anthropics/claude-plugins-community` | Third-party, screened |
| Demo (`anthropics/claude-code`) | `/plugin marketplace add anthropics/claude-code` | Example plugins |

Submit to community: [claude.ai/settings/plugins/submit](https://claude.ai/settings/plugins/submit) or [platform.claude.com/plugins/submit](https://platform.claude.com/plugins/submit). Run `claude plugin validate` before submitting.

### Managed Restrictions

| Setting | Effect |
|:--------|:-------|
| `strictKnownMarketplaces: []` | Block all new marketplace additions |
| `strictKnownMarketplaces: [{ source, ... }]` | Allowlist specific marketplaces |
| `blockedMarketplaces` | Block specific marketplace sources |
| `CLAUDE_CODE_PLUGIN_SEED_DIR` | Pre-populate plugins for containers/CI |
| `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE=1` | Keep cache on `git pull` failure (offline use) |
| `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` | Override 120s git timeout (in ms) |

### Common Mistakes and Fixes

| Issue | Cause | Fix |
|:------|:------|:----|
| Skills/agents/hooks missing | Directories inside `.claude-plugin/` instead of plugin root | Move to plugin root |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` |
| Hooks not firing | Script not executable | `chmod +x script.sh` |
| MCP server path errors | Using absolute paths | Use `${CLAUDE_PLUGIN_ROOT}/...` |
| LSP `Executable not found` | Language server not installed | Install the binary (e.g. `npm install -g typescript-language-server`) |
| After update, hook/MCP uses old path | Mid-session update | `/reload-plugins` (monitors need session restart) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create Plugins](references/claude-code-plugins.md) — Plugin vs standalone, quickstart, structure, skills, LSP, monitors, default settings, testing, sharing, migrating from standalone
- [Plugins Reference](references/claude-code-plugins-reference.md) — Complete manifest schema, component specs (skills, agents, hooks, MCP, LSP, monitors, themes), installation scopes, skills-dir plugins, CLI commands, debugging, versioning
- [Discover and Install Plugins](references/claude-code-discover-plugins.md) — Official marketplace, community marketplace, browsing and installing, managing installed plugins, marketplace management, auto-updates, team marketplaces, security, troubleshooting
- [Create and Distribute a Marketplace](references/claude-code-plugin-marketplaces.md) — Marketplace file schema, plugin entries, source types, hosting (GitHub, git, private repos), managed restrictions, version resolution, release channels, container seeding
- [Plugin Dependencies](references/claude-code-plugin-dependencies.md) — Declare version constraints, cross-marketplace deps, git tag convention, constraint intersection, enable/disable with dependencies, pruning orphans, error resolution
- [Plugin Hints](references/claude-code-plugin-hints.md) — Emit hint tags from your CLI to recommend official marketplace plugins to Claude Code users

## Sources

- Create Plugins: https://code.claude.com/docs/en/plugins.md
- Plugins Reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and Install Plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and Distribute a Marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Plugin Dependencies: https://code.claude.com/docs/en/plugin-dependencies.md
- Plugin Hints: https://code.claude.com/docs/en/plugin-hints.md
