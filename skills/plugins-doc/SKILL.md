---
name: plugins-doc
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins: creating plugins, distributing them through marketplaces, discovering and installing plugins, managing dependencies, and the plugin hints protocol.

## Quick Reference

### Standalone Configuration vs. Plugins

| Approach | Skill names | Best for |
|:---------|:------------|:---------|
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugins** (self-contained directories + optional manifest) | `/plugin-name:hello` | Sharing with teams, distributing to community, reuse across projects |

### Plugin Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Manifest (optional; only file here)
├── skills/                  # Skills as <name>/SKILL.md
├── commands/                # Skills as flat .md files (legacy)
├── agents/                  # Subagent definitions
├── hooks/
│   └── hooks.json           # Hook configuration
├── .mcp.json                # MCP server definitions
├── .lsp.json                # LSP server configurations
├── monitors/
│   └── monitors.json        # Background monitor configurations
├── output-styles/           # Output style definitions
├── themes/                  # Color theme definitions (experimental)
├── bin/                     # Executables added to Bash tool's PATH
└── settings.json            # Default settings (agent, subagentStatusLine only)
```

WARNING: All component directories (`skills/`, `agents/`, `hooks/`, etc.) must be at the plugin root, NOT inside `.claude-plugin/`. Only `plugin.json` belongs in `.claude-plugin/`.

### plugin.json Manifest Schema

| Field | Type | Required | Description |
|:------|:-----|:---------|:------------|
| `name` | string | Yes | Unique kebab-case identifier; becomes skill namespace |
| `displayName` | string | No | Human-readable name shown in UI (v2.1.143+) |
| `version` | string | No | Semver version. Omit to use git commit SHA as version |
| `description` | string | No | Brief description shown in plugin manager |
| `author` | object | No | `{name, email, url}` attribution |
| `homepage` | string | No | Documentation URL |
| `repository` | string | No | Source code URL |
| `license` | string | No | SPDX identifier (e.g., `MIT`) |
| `keywords` | array | No | Discovery tags |
| `defaultEnabled` | boolean | No | `false` = installs disabled; user must opt in (v2.1.154+) |
| `skills` | string\|array | No | Custom skill directories (adds to default `skills/`) |
| `commands` | string\|array | No | Custom command files/dirs (replaces default `commands/`) |
| `agents` | string\|array | No | Custom agent files (replaces default `agents/`) |
| `hooks` | string\|array\|object | No | Hook config paths or inline config |
| `mcpServers` | string\|array\|object | No | MCP config paths or inline config |
| `lspServers` | string\|array\|object | No | LSP server configs |
| `outputStyles` | string\|array | No | Output style files/dirs |
| `experimental.themes` | string\|array | No | Color theme files/dirs |
| `experimental.monitors` | string\|array | No | Background monitor configs |
| `userConfig` | object | No | User-configurable values prompted at enable time |
| `channels` | array | No | Message channel declarations (Telegram, Slack, etc.) |
| `dependencies` | array | No | Other plugins this plugin requires |

All component paths must be relative and start with `./`.

### Environment Variables Available in Plugin Configs

| Variable | Description |
|:---------|:------------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to the plugin's installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state that survives updates (`~/.claude/plugins/data/{id}/`) |
| `${CLAUDE_PROJECT_DIR}` | The project root where Claude Code was launched |
| `${user_config.KEY}` | Values from `userConfig` declared in the manifest |

### CLI Commands Reference

| Command | Description |
|:--------|:------------|
| `claude plugin init <name>` | Scaffold a new plugin in `~/.claude/skills/<name>/` |
| `claude plugin install <plugin>[@marketplace]` | Install a plugin (default scope: user) |
| `claude plugin uninstall <plugin>` | Remove an installed plugin |
| `claude plugin enable <plugin>` | Enable a disabled plugin (also enables its dependencies) |
| `claude plugin disable <plugin>` | Disable a plugin (blocked if another plugin depends on it) |
| `claude plugin update <plugin>` | Update to latest version |
| `claude plugin list` | List installed plugins |
| `claude plugin details <name>` | Show component inventory and token cost |
| `claude plugin validate [path]` | Validate plugin manifest and component files |
| `claude plugin tag [--push]` | Create release git tag (`{plugin-name}--v{version}`) |
| `claude plugin prune` | Remove orphaned auto-installed dependencies |

All commands accept `--scope user|project|local` (default: `user`).

### Installation Scopes

| Scope | Settings file | Use case |
|:------|:-------------|:---------|
| `user` | `~/.claude/settings.json` | Personal plugins across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Read-only, admin-controlled |

### Plugin Sources (in marketplace.json)

| Source | Type | Fields |
|:-------|:-----|:-------|
| Relative path | `"./my-plugin"` string | Must start with `./` |
| `github` | object | `repo` (required), `ref?`, `sha?` |
| `url` | object | `url` (required), `ref?`, `sha?` |
| `git-subdir` | object | `url`, `path` (both required), `ref?`, `sha?` |
| `npm` | object | `package` (required), `version?`, `registry?` |

### Version Management

Version is resolved from the first set:
1. `version` in plugin's `plugin.json`
2. `version` in the marketplace entry
3. Git commit SHA of the plugin's source
4. `unknown` (npm sources or non-git local dirs)

If `version` is set, users only receive updates when you bump it. Omit `version` to auto-update on every commit.

### marketplace.json Required Fields

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Marketplace identifier (kebab-case). Users see this in `/plugin install name@marketplace` |
| `owner` | object | `{name, email?}` — maintainer info |
| `plugins` | array | List of plugin entries, each with `name` and `source` |

### Plugin Dependency Constraints

Declare in `dependencies` in `plugin.json`:

```json
{
  "dependencies": [
    "audit-logger",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```

Semver ranges supported: `~2.1.0`, `^2.0`, `>=1.4`, `=2.1.0`. Tag releases as `{plugin-name}--v{version}` via `claude plugin tag --push`.

### Dependency Error Reference

| Error | Meaning | Fix |
|:------|:--------|:----|
| `dependency-unsatisfied` | Dependency not installed or disabled | Run `claude plugin install <dependency>` |
| `range-conflict` | Ranges from multiple plugins cannot be combined | Uninstall/update conflicting plugin or widen constraint |
| `dependency-version-unsatisfied` | Installed version is outside declared range | Re-resolve: `claude plugin install <dependency>@<marketplace>` |
| `no-matching-tag` | No git tag satisfies the range | Check upstream tags or relax range |

### Plugin Hints Protocol (for CLI maintainers)

Gate on `CLAUDECODE` env var, then write to stderr:

```text
<claude-code-hint v="1" type="plugin" value="example-cli@claude-plugins-official" />
```

The tag must occupy its own line. Only plugins in official Anthropic marketplaces (`claude-plugins-official`) are acted upon. Claude Code shows a one-time install prompt; the tag is always stripped from model output.

### Skills-Directory Plugins

`claude plugin init my-tool` creates `~/.claude/skills/my-tool/` with a manifest, loading automatically as `my-tool@skills-dir` with no marketplace or install step. Personal-scope (`~/.claude/skills/`) loads everywhere; project-scope (`.claude/skills/`) requires workspace trust.

### Monitors (Background Watchers)

`monitors/monitors.json` — array of monitor entries started automatically when the plugin is active (requires v2.1.105+):

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier within the plugin |
| `command` | Yes | Shell command run as a persistent background process |
| `description` | Yes | Summary shown in task panel |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

### Hook Events (plugin hooks/hooks.json)

Plugin hooks support the same events as user hooks: `SessionStart`, `Setup`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `FileChanged`, `WorktreeCreate`, `WorktreeRemove`, `PreCompact`, `PostCompact`, `Elicitation`, `ElicitationResult`, `SessionEnd`, and more.

Hook types: `command`, `http`, `mcp_tool`, `prompt`, `agent`.

### Managed Marketplace Restrictions

`strictKnownMarketplaces` in managed settings controls which marketplaces users can add:

| Value | Behavior |
|:------|:---------|
| Undefined | No restrictions |
| `[]` | Complete lockdown |
| Array of sources | Allowlist — only matching marketplaces permitted |

Allowlist source types: `github` (with `repo`), `url`, `hostPattern` (regex on host), `pathPattern` (regex on path).

### Common Troubleshooting

| Issue | Cause | Solution |
|:------|:------|:---------|
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` |
| Skills not appearing | Wrong directory structure | Ensure `skills/` is at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Script not executable | `chmod +x script.sh`; verify shebang line |
| MCP server fails | Missing path variable | Use `${CLAUDE_PLUGIN_ROOT}` for all plugin paths |
| LSP `Executable not found` | Language server not installed | Install binary: e.g., `npm install -g typescript-language-server typescript` |
| Relative paths fail in URL marketplace | URL marketplace only fetches `marketplace.json` | Use GitHub/npm/git URL sources instead |
| Marketplace updates fail offline | Wipes stale clone on `git pull` failure | Set `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE=1` |

### Available LSP Plugins (Official Marketplace)

| Language | Plugin | Binary required |
|:---------|:-------|:----------------|
| Python | `pyright-lsp` | `pyright-langserver` |
| TypeScript | `typescript-lsp` | `typescript-language-server` |
| Rust | `rust-analyzer-lsp` | `rust-analyzer` |
| Go | `gopls-lsp` | `gopls` |
| C/C++ | `clangd-lsp` | `clangd` |
| Java | `jdtls-lsp` | `jdtls` |
| C# | `csharp-lsp` | `csharp-ls` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create Plugins](references/claude-code-plugins.md) — Quickstart, plugin structure, skills/agents/hooks/MCP/LSP/monitors, testing locally, migrating standalone configs, submitting to community marketplace
- [Plugins Reference](references/claude-code-plugins-reference.md) — Complete technical specifications: manifest schema, component schemas, CLI commands, environment variables, caching, debugging
- [Discover and Install Plugins](references/claude-code-discover-plugins.md) — Official marketplace, community marketplace, adding marketplaces, install/manage, security, troubleshooting
- [Create and Distribute a Plugin Marketplace](references/claude-code-plugin-marketplaces.md) — marketplace.json schema, plugin sources, hosting on GitHub/GitLab/npm, managed restrictions, version resolution, release channels
- [Plugin Dependencies](references/claude-code-plugin-dependencies.md) — Version constraints, cross-marketplace dependencies, tagging releases, enabling/disabling with dependencies, pruning orphans
- [Plugin Hints](references/claude-code-plugin-hints.md) — CLI hint protocol for recommending plugins from your own CLI tools

## Sources

- Create Plugins: https://code.claude.com/docs/en/plugins.md
- Plugins Reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and Install Plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and Distribute a Plugin Marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Plugin Dependencies: https://code.claude.com/docs/en/plugin-dependencies.md
- Plugin Hints: https://code.claude.com/docs/en/plugin-hints.md
