---
name: plugins-doc
user-invocable: false
description: >
  Complete official documentation for Claude Code plugins: creating plugins,
  plugin manifest schema, distributing via marketplaces, discovering and
  installing plugins, plugin dependencies with version constraints, and the
  plugin hint protocol for CLIs. Use when working with or answering questions
  about Claude Code plugins, plugin.json manifests, skills-directory plugins,
  marketplace configuration, or the claude plugin CLI commands.
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins: creating, configuring, and distributing plugins, as well as discovering and installing them.

## Quick Reference

### Standalone vs Plugin

| Approach | Skill names | Best for |
|:---------|:------------|:---------|
| Standalone (`.claude/` directory) | `/hello` | Personal, project-specific, quick experiments |
| Plugin (self-contained directory with `.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with team, distributing, versioned releases |

### Plugin Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Manifest (optional — only file that goes here)
├── skills/                  # Skills as <name>/SKILL.md
├── commands/                # Skills as flat .md files (legacy; prefer skills/)
├── agents/                  # Subagent definitions
├── hooks/
│   └── hooks.json           # Hook configurations
├── .mcp.json                # MCP server definitions
├── .lsp.json                # LSP server configurations
├── monitors/
│   └── monitors.json        # Background monitor configurations
├── themes/                  # Color theme JSON files (experimental)
├── output-styles/           # Output style definitions
├── bin/                     # Executables added to Bash tool PATH
└── settings.json            # Default plugin settings (agent, subagentStatusLine only)
```

**Common mistake**: Only `plugin.json` goes inside `.claude-plugin/`. All other directories must be at the plugin root.

### plugin.json Manifest Schema

#### Required fields

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique identifier (kebab-case). Used as skill namespace prefix. |

#### Metadata fields

| Field | Type | Description |
|:------|:-----|:------------|
| `displayName` | string | Human-readable name for UI (v2.1.143+) |
| `version` | string | Semver. If set, users only get updates when bumped. If omitted, git commit SHA is used. |
| `description` | string | Brief plugin purpose |
| `author` | object | `{ "name", "email", "url" }` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier |
| `keywords` | array | Discovery tags |
| `defaultEnabled` | boolean | Whether plugin starts enabled on install (default: `true`; v2.1.154+) |

#### Component path fields

| Field | Type | Behavior |
|:------|:-----|:---------|
| `skills` | string\|array | Adds to default `skills/` (both are scanned) |
| `commands` | string\|array | Replaces default `commands/` |
| `agents` | string\|array | Replaces default `agents/` |
| `hooks` | string\|array\|object | Inline config or path(s) |
| `mcpServers` | string\|array\|object | Inline config or path(s) |
| `lspServers` | string\|array\|object | Inline config or path(s) |
| `outputStyles` | string\|array | Replaces default `output-styles/` |
| `experimental.themes` | string\|array | Replaces default `themes/` |
| `experimental.monitors` | string\|array | Replaces default `monitors/monitors.json` |
| `userConfig` | object | User-configurable values prompted at enable time |
| `dependencies` | array | Other plugins required (name strings or `{ name, version, marketplace }`) |

### Environment Variables Available in Plugin Configs

| Variable | Description |
|:---------|:------------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin installation directory (changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory surviving updates (`~/.claude/plugins/data/{id}/`) |
| `${CLAUDE_PROJECT_DIR}` | Project root (same as `CLAUDE_PROJECT_DIR` in hooks) |
| `${user_config.KEY}` | User-supplied config values from `userConfig` field |

### Skills-Directory Plugins

Any folder under a skills directory containing `.claude-plugin/plugin.json` loads as `<name>@skills-dir`. Scaffold with:

```bash
claude plugin init my-tool
```

| Skills directory | Scope | Notes |
|:----------------|:------|:------|
| `~/.claude/skills/` | personal | Available in every project |
| `<cwd>/.claude/skills/` | project | Loads only after workspace trust; monitors do not load |

### Plugin Installation Scopes

| Scope | Settings file | Use case |
|:------|:-------------|:---------|
| `user` | `~/.claude/settings.json` | Personal plugins across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Read-only, set by admins |

### CLI Commands Reference

| Command | Description |
|:--------|:------------|
| `claude plugin init <name>` | Scaffold plugin at `~/.claude/skills/<name>/` |
| `claude plugin install <plugin>[@marketplace]` | Install plugin (default: user scope) |
| `claude plugin uninstall <plugin> [--keep-data] [--prune]` | Remove plugin |
| `claude plugin enable <plugin>` | Enable disabled plugin (also enables dependencies) |
| `claude plugin disable <plugin>` | Disable plugin (fails if another plugin depends on it) |
| `claude plugin update <plugin>` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin details <name>` | Show components and token cost estimate |
| `claude plugin validate [path] [--strict]` | Validate plugin/marketplace JSON |
| `claude plugin tag [--push] [--dry-run]` | Create release git tag for version resolution |
| `claude plugin prune [--dry-run] [-y]` | Remove orphaned auto-installed dependencies |
| `claude plugin marketplace add <source>` | Add marketplace (GitHub `owner/repo`, git URL, local path, remote URL) |
| `claude plugin marketplace list` | List configured marketplaces |
| `claude plugin marketplace remove <name>` | Remove marketplace (also uninstalls its plugins) |
| `claude plugin marketplace update [name]` | Refresh marketplace listings |

### Testing Plugins Locally

```bash
# Load from directory
claude --plugin-dir ./my-plugin

# Load from zip archive (v2.1.128+)
claude --plugin-dir ./my-plugin.zip

# Load from hosted URL
claude --plugin-url https://example.com/my-plugin.zip

# Load multiple plugins
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

After changes: run `/reload-plugins` inside a session.

### Marketplace File Schema (`.claude-plugin/marketplace.json`)

```json
{
  "name": "my-marketplace",
  "owner": { "name": "Your Name", "email": "you@example.com" },
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin",
      "description": "What it does",
      "version": "1.0.0"
    }
  ]
}
```

#### Plugin source types

| Type | Format | Notes |
|:-----|:-------|:------|
| Relative path | `"./plugins/my-plugin"` | Only works with git-based marketplaces |
| GitHub | `{ "source": "github", "repo": "owner/repo", "ref"?, "sha"? }` | |
| Git URL | `{ "source": "url", "url": "https://...", "ref"?, "sha"? }` | |
| Git subdirectory | `{ "source": "git-subdir", "url": "...", "path": "tools/plugin", "ref"?, "sha"? }` | Sparse clone |
| npm | `{ "source": "npm", "package": "@org/plugin", "version"?, "registry"? }` | |

### Version Management

Version resolution order (first wins):
1. `version` in plugin's `plugin.json`
2. `version` in marketplace entry
3. Git commit SHA (for git-backed sources)
4. `unknown` (npm or non-git local)

| Strategy | How | Update behavior |
|:---------|:----|:----------------|
| Explicit version | Set `"version"` in `plugin.json` | Users get updates only when you bump the field |
| Commit-SHA | Omit `version` from both | Every commit is a new version |

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

Semver ranges: `~2.1.0` (patch), `^2.0` (minor), `>=1.4`, `=2.1.0`.

Tag releases for version resolution: `claude plugin tag --push` creates `{plugin-name}--v{version}` tags.

### Plugin Hints Protocol (for CLI authors)

CLIs with an official marketplace plugin can emit a hint to prompt installation. Gate on `CLAUDECODE` env var, write to stderr:

```
<claude-code-hint v="1" type="plugin" value="example-cli@claude-plugins-official" />
```

- The hint must be on its own line
- Only works for plugins in official Anthropic marketplaces (`claude-plugins-official`)
- Claude Code strips the line before sending output to the model
- Each plugin is prompted at most once per user

### Monitors

Background monitors start automatically when the plugin is active. Declared in `monitors/monitors.json`:

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier within the plugin |
| `command` | Yes | Shell command run as persistent background process |
| `description` | Yes | What is being watched |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

Requires Claude Code v2.1.105+. Run only in interactive CLI sessions.

### Managed Marketplace Restrictions (`strictKnownMarketplaces`)

| Value | Behavior |
|:------|:---------|
| Undefined (default) | No restrictions |
| `[]` (empty array) | Complete lockdown — users cannot add any marketplace |
| List of sources | Only matching marketplaces allowed |

Source patterns: exact `github`/`url` matches, `hostPattern` regex, `pathPattern` regex.

### Container Pre-population

Set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a pre-populated plugins directory at build time:

```bash
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin marketplace add your-org/plugins
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin install my-tool@your-plugins
```

Seed directories are read-only; auto-updates are disabled for seed marketplaces.

### Common Debugging

| Issue | Cause | Fix |
|:------|:------|:----|
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` |
| Skills not appearing | Wrong directory (inside `.claude-plugin/`) | Move to plugin root |
| Hooks not firing | Script not executable | `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin paths |
| LSP `Executable not found in $PATH` | Language server not installed | Install the binary separately |
| `dependency-unsatisfied` | Dependency not installed or disabled | Run `claude plugin install <dep>` |
| `range-conflict` | Incompatible version constraints | Uninstall/update conflicting plugin |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — Plugin quickstart, standalone vs plugin, plugin structure, adding agents/LSP/monitors/hooks, testing locally, converting existing config, submitting to community marketplace
- [Plugins reference](references/claude-code-plugins-reference.md) — Complete technical specs: manifest schema, component schemas, CLI commands, environment variables, caching, directory structure, debugging
- [Discover and install plugins](references/claude-code-discover-plugins.md) — Official marketplace overview, code intelligence plugins, community marketplace, adding/installing/managing plugins and marketplaces
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace.json schema, plugin sources, hosting, private repositories, managed restrictions, version/release channels, container pre-population
- [Plugin dependencies](references/claude-code-plugin-dependencies.md) — Declaring version constraints, cross-marketplace dependencies, git tag convention, constraint intersection, enabling/disabling with dependencies
- [Plugin hints](references/claude-code-plugin-hints.md) — Hint protocol for CLIs to recommend plugin installation, hint format, requirements, emission patterns

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Plugin dependencies: https://code.claude.com/docs/en/plugin-dependencies.md
- Plugin hints: https://code.claude.com/docs/en/plugin-hints.md
