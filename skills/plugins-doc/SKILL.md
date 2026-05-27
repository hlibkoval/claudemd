---
name: plugins-doc
description: Complete official documentation for the Claude Code plugin system — creating plugins (plugin.json manifest, skills, agents, hooks, MCP/LSP servers, monitors, themes), discovering and installing plugins from marketplaces, creating and distributing plugin marketplaces (marketplace.json schema, plugin sources, version management, release channels, managed restrictions, container seeding), plugin dependency version constraints (semver ranges, cross-marketplace deps, dependency resolution errors), and the CLI plugin hint protocol for recommending plugins from your own CLI.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for the Claude Code plugin system.

## Quick Reference

### Standalone vs Plugin

| Approach | Skill names | Best for |
| :--- | :--- | :--- |
| **Standalone** (`.claude/`) | `/hello` | Single-project, personal, quick experiments |
| **Plugin** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing, distribution, reuse across projects |

### Plugin Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # manifest (only file here)
├── skills/                  # <name>/SKILL.md directories
├── commands/                # flat .md skill files (legacy; prefer skills/)
├── agents/                  # subagent .md files
├── hooks/
│   └── hooks.json           # hook configuration
├── .mcp.json                # MCP server definitions
├── .lsp.json                # LSP server configurations
├── monitors/
│   └── monitors.json        # background monitor configs
├── themes/                  # color theme JSON files
├── output-styles/           # output style definitions
├── bin/                     # executables added to PATH
└── settings.json            # default settings (agent/subagentStatusLine only)
```

Only `plugin.json` belongs inside `.claude-plugin/`. All component directories live at the plugin root.

### plugin.json Manifest Schema

**Required:** `name` (only required field if manifest is present; manifest itself is optional)

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique kebab-case identifier; used as skill namespace |
| `displayName` | string | Human-readable name for UI (v2.1.143+); falls back to `name` |
| `version` | string | Semantic version; omit to use git commit SHA for versioning |
| `description` | string | Brief plugin purpose |
| `author` | object | `name`, `email`, `url` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier (e.g., `"MIT"`) |
| `keywords` | array | Discovery tags |

**Component path fields** (all optional):

| Field | Behavior | Type |
| :--- | :--- | :--- |
| `skills` | Adds to default `skills/` | string\|array |
| `commands` | Replaces default `commands/` | string\|array |
| `agents` | Replaces default `agents/` | string\|array |
| `hooks` | Merge rules apply | string\|array\|object |
| `mcpServers` | Merge rules apply | string\|array\|object |
| `lspServers` | Merge rules apply | string\|array\|object |
| `outputStyles` | Replaces default | string\|array |
| `experimental.themes` | Replaces default `themes/` | string\|array |
| `experimental.monitors` | Replaces default | string\|array |
| `userConfig` | Prompts user at enable time | object |
| `channels` | Message injection channels | array |
| `dependencies` | Other plugins required | array |

Unrecognized top-level fields are silently ignored (useful for dual-purpose manifests). Use `claude plugin validate --strict` to catch typos.

### Environment Variables in Plugin Configs

| Variable | Description |
| :--- | :--- |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin's installation directory (changes on update) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent data dir (`~/.claude/plugins/data/{id}/`); survives updates |
| `${CLAUDE_PROJECT_DIR}` | Working directory Claude was launched from |
| `${user_config.KEY}` | User-configured value from `userConfig` field |

In shell-form hooks and monitor commands, wrap `${CLAUDE_PLUGIN_ROOT}` in double quotes. Use exec form (`args` array) in hooks for path safety.

### userConfig Schema

Declared in `plugin.json` `userConfig`; prompts user at enable time.

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `string`, `number`, `boolean`, `directory`, or `file` |
| `title` | Yes | Label in config dialog |
| `description` | Yes | Help text |
| `sensitive` | No | Masks input; stores in system keychain |
| `required` | No | Fails validation if empty |
| `default` | No | Value when user provides nothing |
| `multiple` | No | Allow array of strings (string type) |
| `min` / `max` | No | Bounds for number type |

Sensitive values go to keychain (~2 KB total limit). Non-sensitive stored in `settings.json` under `pluginConfigs[<id>].options`. All exported as `CLAUDE_PLUGIN_OPTION_<KEY>` env vars.

### Plugin Components Summary

| Component | Default location | Key notes |
| :--- | :--- | :--- |
| Skills | `skills/<name>/SKILL.md` | Namespaced as `plugin-name:skill-name` |
| Commands | `commands/` | Flat .md files; use `skills/` for new plugins |
| Agents | `agents/` | Supports `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation: "worktree"` |
| Hooks | `hooks/hooks.json` | Same events as user hooks; types: `command`, `http`, `mcp_tool`, `prompt`, `agent` |
| MCP servers | `.mcp.json` | Start automatically; use `${CLAUDE_PLUGIN_ROOT}` for paths |
| LSP servers | `.lsp.json` | Binary must be separately installed |
| Monitors | `monitors/monitors.json` | Interactive sessions only; v2.1.105+ required |
| Themes | `themes/` | Experimental; JSON with `base` and `overrides` color tokens |
| Executables | `bin/` | Added to Bash tool's PATH |
| Settings | `settings.json` | `agent` and `subagentStatusLine` keys only |

### Hook Events (Plugin Hooks)

Plugin hooks support the same lifecycle events as user-defined hooks. Key events:

| Event | When |
| :--- | :--- |
| `SessionStart` | Session begins or resumes |
| `PreToolUse` | Before tool executes (can block) |
| `PostToolUse` | After tool succeeds |
| `PostToolBatch` | After a full parallel batch resolves |
| `Stop` | Claude finishes responding |
| `FileChanged` | Watched file changes on disk |
| `SubagentStart` / `SubagentStop` | Subagent spawned or finished |
| `PreCompact` / `PostCompact` | Before/after context compaction |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded |
| `CwdChanged` | Working directory changed |
| `WorktreeCreate` / `WorktreeRemove` | Worktree lifecycle |

Full event list: `SessionStart`, `Setup`, `UserPromptSubmit`, `UserPromptExpansion`, `PreToolUse`, `PermissionRequest`, `PermissionDenied`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Notification`, `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `Stop`, `StopFailure`, `TeammateIdle`, `InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `FileChanged`, `WorktreeCreate`, `WorktreeRemove`, `PreCompact`, `PostCompact`, `Elicitation`, `ElicitationResult`, `SessionEnd`.

### Monitors Schema

Declared in `monitors/monitors.json` (array) or inline via `experimental.monitors` in `plugin.json`.

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier within the plugin |
| `command` | Yes | Shell command run as persistent background process |
| `description` | Yes | Summary shown in task panel |
| `when` | No | `"always"` (default) or `"on-skill-invoke:<skill-name>"` |

### LSP Server Schema

| Field | Required | Description |
| :--- | :--- | :--- |
| `command` | Yes | LSP binary (must be in PATH) |
| `extensionToLanguage` | Yes | Maps file extensions to language IDs |
| `args` | No | CLI arguments |
| `transport` | No | `stdio` (default) or `socket` |
| `env` | No | Environment variables |
| `initializationOptions` | No | Options at initialization |
| `settings` | No | Passed via `workspace/didChangeConfiguration` |
| `restartOnCrash` | No | Auto-restart on crash |
| `maxRestarts` | No | Max restart attempts |

### Official LSP Plugins

| Plugin | Language server | Install |
| :--- | :--- | :--- |
| `pyright-lsp` | Pyright (Python) | `pip install pyright` |
| `typescript-lsp` | TypeScript Language Server | `npm install -g typescript-language-server typescript` |
| `rust-analyzer-lsp` | rust-analyzer | See rust-analyzer docs |

### Testing Plugins Locally

```bash
claude --plugin-dir ./my-plugin            # load from directory
claude --plugin-dir ./my-plugin.zip        # load from zip (v2.1.128+)
claude --plugin-url https://example.com/my-plugin.zip   # load from URL
```

Multiple plugins: repeat the flag. Local `--plugin-dir` plugin overrides installed plugin of same name for that session. Run `/reload-plugins` to pick up changes without restarting.

### CLI Plugin Commands

| Command | Description |
| :--- | :--- |
| `claude plugin install <plugin>[@marketplace]` | Install plugin (default: user scope) |
| `claude plugin uninstall <plugin>` | Remove plugin (`--keep-data`, `--prune` options) |
| `claude plugin enable <plugin>` | Enable disabled plugin (also enables dependencies) |
| `claude plugin disable <plugin>` | Disable plugin (blocked if another plugin depends on it) |
| `claude plugin update <plugin>` | Update to latest version |
| `claude plugin list [--json] [--available]` | List installed plugins |
| `claude plugin details <name>` | Show component inventory and token cost |
| `claude plugin prune` | Remove orphaned auto-installed dependencies |
| `claude plugin tag [--push]` | Create release git tag from plugin directory |
| `claude plugin validate [path]` | Validate plugin.json and component files |

### Plugin Installation Scopes

| Scope | Settings file | Use case |
| :--- | :--- | :--- |
| `user` (default) | `~/.claude/settings.json` | Personal, across all projects |
| `project` | `.claude/settings.json` | Team-shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Read-only, admin-controlled |

### Version Management

Version resolution order (first set wins):
1. `version` in plugin's `plugin.json`
2. `version` in plugin's marketplace entry
3. Git commit SHA of plugin's source

| Approach | How | Update behavior |
| :--- | :--- | :--- |
| Explicit version | `"version": "2.1.0"` in `plugin.json` | Updates only when field is bumped |
| Commit-SHA (default) | Omit `version` from both | Updates on every new commit |

### Discovering and Installing Plugins

```bash
# Official marketplace (always available)
/plugin install github@claude-plugins-official

# Community marketplace (add first)
/plugin marketplace add anthropics/claude-plugins-community
/plugin install <name>@claude-community

# Demo marketplace
/plugin marketplace add anthropics/claude-code
/plugin install commit-commands@claude-code-plugins
```

The `/plugin` UI has four tabs: **Discover**, **Installed**, **Marketplaces**, **Errors**.

### Marketplace File (marketplace.json)

Located at `.claude-plugin/marketplace.json`. Required fields:

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Marketplace identifier (kebab-case); users see this in install commands |
| `owner` | object | `name` (required), `email` (optional) |
| `plugins` | array | List of plugin entries |

Optional top-level: `description`, `version`, `metadata.pluginRoot`, `allowCrossMarketplaceDependenciesOn`.

### Plugin Source Types (in marketplace.json)

| Source | Format | Notes |
| :--- | :--- | :--- |
| Relative path | `"./plugins/my-plugin"` | Only works with git-based marketplace (not URL-based) |
| `github` | `{"source": "github", "repo": "owner/repo", "ref"?, "sha"?}` | |
| `url` | `{"source": "url", "url": "...", "ref"?, "sha"?}` | Any git host |
| `git-subdir` | `{"source": "git-subdir", "url": "...", "path": "...", "ref"?, "sha"?}` | Sparse clone for monorepos |
| `npm` | `{"source": "npm", "package": "@org/name", "version"?, "registry"?}` | |

### Marketplace CLI Commands

```bash
claude plugin marketplace add <source> [--scope] [--sparse <paths>]
claude plugin marketplace list [--json]
claude plugin marketplace remove <name>
claude plugin marketplace update [name]
```

### Managed Marketplace Restrictions (strictKnownMarketplaces)

| Value | Behavior |
| :--- | :--- |
| Undefined (default) | No restrictions |
| `[]` | Complete lockdown |
| List of sources | Only listed marketplaces allowed |

Source types for allowlist: `github` (repo + optional ref), `url` (exact URL), `hostPattern` (regex on host), `pathPattern` (regex on filesystem path).

### Container Plugin Seeding

Pre-populate plugins for containers via `CLAUDE_CODE_PLUGIN_SEED_DIR`. Use `CLAUDE_CODE_PLUGIN_CACHE_DIR` during build to install directly to seed path. Seed is read-only; auto-updates disabled for seed marketplaces.

```bash
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/seed claude plugin marketplace add org/plugins
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/seed claude plugin install my-tool@org-plugins
# Then at runtime:
# export CLAUDE_CODE_PLUGIN_SEED_DIR=/opt/seed
```

### Plugin Dependency Version Constraints

Declared in `plugin.json` `dependencies` array:

```json
{
  "dependencies": [
    "audit-logger",
    { "name": "secrets-vault", "version": "~2.1.0" }
  ]
}
```

| Field | Description |
| :--- | :--- |
| `name` | Plugin name (resolves in same marketplace by default) |
| `version` | Semver range: `~2.1.0`, `^2.0`, `>=1.4`, `=2.1.0` |
| `marketplace` | Different marketplace (requires `allowCrossMarketplaceDependenciesOn`) |

Tag releases as `{plugin-name}--v{version}` using `claude plugin tag --push`.

**Dependency errors:**

| Error | Fix |
| :--- | :--- |
| `dependency-unsatisfied` | Install the missing dependency |
| `range-conflict` | Uninstall/update a conflicting plugin or widen constraint |
| `dependency-version-unsatisfied` | Re-run `claude plugin install <dependency>` |
| `no-matching-tag` | Ensure upstream has tagged releases with the naming convention |

### Plugin Hint Protocol (CLI Recommendation)

CLIs in the official marketplace can prompt users to install their plugin. Gate on `CLAUDECODE` env var, then write to stderr:

```
<claude-code-hint v="1" type="plugin" value="example-cli@claude-plugins-official" />
```

Requirements: tag on its own line; must target an official Anthropic marketplace. Claude Code strips the line before the model sees output (no token cost). Prompts at most once per plugin per session.

### Common Debugging Issues

| Issue | Cause | Fix |
| :--- | :--- | :--- |
| Plugin not loading | Invalid `plugin.json` | Run `claude plugin validate` |
| Skills not appearing | Wrong directory structure | Move `skills/` to plugin root (not inside `.claude-plugin/`) |
| Hooks not firing | Script not executable | `chmod +x script.sh` |
| MCP server fails | Missing `${CLAUDE_PLUGIN_ROOT}` | Use variable for all plugin paths |
| Path errors | Absolute paths used | All paths must be relative and start with `./` |
| LSP binary not found | Language server not installed | Install binary (e.g., `npm install -g typescript-language-server`) |

### Converting Standalone Config to Plugin

| Standalone (`.claude/`) | Plugin |
| :--- | :--- |
| `.claude/commands/` | `plugin-name/commands/` |
| `.claude/skills/` | `plugin-name/skills/` |
| Hooks in `settings.json` | `hooks/hooks.json` |
| Manual copy to share | `/plugin install` from marketplace |

### Submitting to Community Marketplace

```
/plugin marketplace add anthropics/claude-plugins-community
```

Submit at: claude.ai/settings/plugins/submit or platform.claude.com/plugins/submit. Run `claude plugin validate` locally first. Review pipeline runs same check + safety screening. Official marketplace (`claude-plugins-official`) is curated by Anthropic separately.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) — plugin structure, quickstart, manifest, skills/agents/hooks/LSP/monitors, testing locally, converting standalone configs, distributing
- [Plugins reference](references/claude-code-plugins-reference.md) — complete technical schemas: plugin manifest, components, hooks events, environment variables, CLI commands, caching, directory structure, debugging
- [Discover and install plugins](references/claude-code-discover-plugins.md) — official/community marketplaces, LSP plugin catalog, installing/managing plugins, team marketplace config, troubleshooting
- [Create and distribute a plugin marketplace](references/claude-code-plugin-marketplaces.md) — marketplace.json schema, plugin sources, hosting, private repos, container seeding, managed restrictions, release channels, validation
- [Constrain plugin dependency versions](references/claude-code-plugin-dependencies.md) — declaring dependencies, semver ranges, cross-marketplace deps, tagging releases, constraint intersection, enabling/disabling with deps, pruning
- [Recommend your plugin from your CLI](references/claude-code-plugin-hints.md) — hint protocol, emission examples, format, requirements, official marketplace submission

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a plugin marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
- Constrain plugin dependency versions: https://code.claude.com/docs/en/plugin-dependencies.md
- Recommend your plugin from your CLI: https://code.claude.com/docs/en/plugin-hints.md
