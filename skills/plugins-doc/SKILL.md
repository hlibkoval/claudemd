---
name: plugins-doc
description: Complete documentation for Claude Code plugins -- covering plugin creation (manifest, skills, agents, hooks, MCP servers, LSP servers, settings.json, directory structure), quickstart (--plugin-dir, /reload-plugins, $ARGUMENTS), plugin structure (commands/ agents/ skills/ hooks/ output-styles/ .mcp.json .lsp.json settings.json at plugin root, .claude-plugin/plugin.json manifest), plugin manifest schema (name required, version/description/author/homepage/repository/license/keywords metadata, commands/agents/skills/hooks/mcpServers/outputStyles/lspServers/userConfig/channels component paths), userConfig (prompted at enable, ${user_config.KEY} substitution, sensitive values in keychain, CLAUDE_PLUGIN_OPTION_<KEY> env vars), channels (server field binding to mcpServers, per-channel userConfig), environment variables (${CLAUDE_PLUGIN_ROOT} for bundled files, ${CLAUDE_PLUGIN_DATA} for persistent state surviving updates at ~/.claude/plugins/data/{id}/), path behavior (custom paths replace defaults, relative ./paths, arrays for multiple), plugin caching (marketplace plugins copied to ~/.claude/plugins/cache, no path traversal outside plugin root, symlinks honored), plugin installation scopes (user ~/.claude/settings.json default, project .claude/settings.json shared via VCS, local .claude/settings.local.json gitignored, managed read-only), LSP servers (.lsp.json or inline in plugin.json, command/extensionToLanguage required, transport/env/initializationOptions/settings optional, official plugins for Python/TypeScript/Rust/Go/C++/Java/Kotlin/PHP/Lua/Swift/C#), settings.json (agent key activates custom agent as main thread), CLI commands (claude plugin install/uninstall/enable/disable/update with --scope flag, uninstall --keep-data), debugging (claude --debug, /plugin validate, common issues table, hook/MCP/LSP troubleshooting), version management (semver MAJOR.MINOR.PATCH, bump version for cache updates), discovering plugins (/plugin command with Discover/Installed/Marketplaces/Errors tabs, official marketplace claude-plugins-official auto-available, /plugin install name@marketplace, installation scopes user/project/local/managed, /reload-plugins), marketplace management (/plugin marketplace add/list/update/remove, GitHub owner/repo, Git URLs with #ref, local paths, remote URLs, auto-updates with DISABLE_AUTOUPDATER/FORCE_AUTOUPDATE_PLUGINS), team marketplaces (extraKnownMarketplaces in .claude/settings.json, enabledPlugins), code intelligence plugins (LSP plugins for diagnostics and navigation, pyright-lsp/typescript-lsp/rust-analyzer-lsp/gopls-lsp etc.), external integration plugins (github/gitlab/atlassian/asana/linear/notion/figma/vercel/firebase/supabase/slack/sentry), creating marketplaces (.claude-plugin/marketplace.json, name/owner/plugins required, metadata.pluginRoot, plugin entries with name/source required, source types: relative path/github/url/git-subdir/npm, strict mode true/false, version resolution), hosting marketplaces (GitHub recommended, GitLab/Bitbucket, private repos with credential helpers and tokens, CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS), managed marketplace restrictions (strictKnownMarketplaces in managed settings, hostPattern/pathPattern regex matching, empty array lockdown), pre-populating plugins (CLAUDE_CODE_PLUGIN_SEED_DIR for containers, read-only seed with layered paths), release channels (stable/latest via different refs), converting standalone to plugin (migration steps from .claude/ to plugin structure), security (plugins execute arbitrary code, trust before installing). Load when discussing Claude Code plugins, plugin creation, plugin manifest, plugin.json, marketplace.json, /plugin command, plugin install, plugin uninstall, plugin marketplace, plugin marketplace add, plugin discovery, plugin distribution, plugin hooks, plugin MCP servers, plugin LSP servers, plugin skills, plugin agents, plugin settings.json, plugin userConfig, plugin channels, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, --plugin-dir, /reload-plugins, plugin validate, plugin scopes, enabledPlugins, extraKnownMarketplaces, strictKnownMarketplaces, plugin cache, plugin versioning, semver for plugins, plugin seed directory, CLAUDE_CODE_PLUGIN_SEED_DIR, code intelligence plugins, LSP plugins, marketplace creation, marketplace schema, plugin sources, strict mode, release channels, converting to plugin, or any plugin-related topic for Claude Code.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins -- covering plugin creation, distribution via marketplaces, installation, and the full technical reference.

## Quick Reference

### Plugin vs Standalone

| Approach | Skill names | Best for |
|:---------|:------------|:---------|
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific, experiments |
| **Plugin** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with team, community distribution, reuse across projects |

### Plugin Directory Structure

```
my-plugin/
  .claude-plugin/
    plugin.json            # Manifest (only file in .claude-plugin/)
  commands/                # Legacy skill .md files (at root, NOT inside .claude-plugin/)
  agents/                  # Subagent .md files
  skills/                  # Agent Skills with <name>/SKILL.md
  hooks/
    hooks.json             # Hook configuration
  output-styles/           # Output style definitions
  scripts/                 # Hook and utility scripts
  settings.json            # Default settings (currently only "agent" key)
  .mcp.json                # MCP server definitions
  .lsp.json                # LSP server configurations
```

### Plugin Manifest (plugin.json)

Only `name` is required. Manifest is optional if components use default locations.

**Required:**

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique identifier (kebab-case). Used as namespace prefix for skills/agents |

**Metadata:**

| Field | Type | Description |
|:------|:-----|:------------|
| `version` | string | Semver (`MAJOR.MINOR.PATCH`). Must bump for cache updates |
| `description` | string | Shown in plugin manager |
| `author` | object | `{ "name": "...", "email": "..." }` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier (MIT, Apache-2.0) |
| `keywords` | array | Discovery tags |

**Component paths (replace defaults when set):**

| Field | Type | Description |
|:------|:-----|:------------|
| `commands` | string or array | Custom command files/directories |
| `agents` | string or array | Custom agent files |
| `skills` | string or array | Custom skill directories |
| `hooks` | string, array, or object | Hook config paths or inline config |
| `mcpServers` | string, array, or object | MCP config paths or inline config |
| `lspServers` | string, array, or object | LSP server configurations |
| `outputStyles` | string or array | Custom output style files/directories |
| `userConfig` | object | User-configurable values prompted at enable time |
| `channels` | array | Channel declarations for message injection |

All paths must be relative and start with `./`. To keep the default directory and add more, include the default in the array: `"commands": ["./commands/", "./extras/deploy.md"]`.

### Environment Variables

| Variable | Purpose | Lifetime |
|:---------|:--------|:---------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin install directory | Changes on update (bundled files) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent state at `~/.claude/plugins/data/{id}/` | Survives updates, deleted on uninstall |

Both are substituted inline in skill/agent content, hook commands, and MCP/LSP configs. Also exported as environment variables to subprocesses.

### User Configuration (userConfig)

```json
{
  "userConfig": {
    "api_endpoint": { "description": "Team API endpoint", "sensitive": false },
    "api_token": { "description": "API auth token", "sensitive": true }
  }
}
```

- Non-sensitive values: stored in `settings.json` under `pluginConfigs[<id>].options`
- Sensitive values: stored in system keychain (~2KB total limit)
- Available as `${user_config.KEY}` in MCP/LSP configs, hook commands, skill/agent content (non-sensitive only)
- Exported as `CLAUDE_PLUGIN_OPTION_<KEY>` env vars

### Channels

Declare message channels bound to plugin MCP servers:

```json
{
  "channels": [
    { "server": "telegram", "userConfig": { "bot_token": { "description": "...", "sensitive": true } } }
  ]
}
```

`server` must match a key in the plugin's `mcpServers`.

### Plugin Components

**Skills:** `skills/<name>/SKILL.md` with frontmatter (`name`, `description`). Auto-discovered, model-invoked based on context.

**Agents:** `agents/<name>.md` with frontmatter (`name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation`). Only valid `isolation` value is `"worktree"`. Security: `hooks`, `mcpServers`, `permissionMode` not supported for plugin agents.

**Hooks:** `hooks/hooks.json` or inline in `plugin.json`. Same format as user hooks. Hook types: `command`, `http`, `prompt`, `agent`.

| Event | When it fires |
|:------|:-------------|
| `SessionStart` | Session begins or resumes |
| `UserPromptSubmit` | Prompt submitted, before processing |
| `PreToolUse` | Before tool call (can block) |
| `PostToolUse` | After tool call succeeds |
| `PostToolUseFailure` | After tool call fails |
| `PermissionRequest` | Permission dialog appears |
| `Notification` | Claude Code sends notification |
| `SubagentStart` / `SubagentStop` | Subagent lifecycle |
| `TaskCreated` / `TaskCompleted` | Task lifecycle |
| `Stop` / `StopFailure` | Turn ends |
| `TeammateIdle` | Agent team teammate going idle |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded |
| `ConfigChange` | Config file changed during session |
| `CwdChanged` | Working directory changed |
| `FileChanged` | Watched file changed (matcher specifies filenames) |
| `WorktreeCreate` / `WorktreeRemove` | Worktree lifecycle |
| `PreCompact` / `PostCompact` | Context compaction |
| `Elicitation` / `ElicitationResult` | MCP elicitation |
| `SessionEnd` | Session terminates |

**MCP Servers:** `.mcp.json` at plugin root or inline. Auto-start when plugin enabled. Use `${CLAUDE_PLUGIN_ROOT}` for paths.

**LSP Servers:** `.lsp.json` at plugin root or inline. Required fields: `command`, `extensionToLanguage`. Optional: `args`, `transport` (stdio/socket), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`. Binary must be installed separately.

**Settings:** `settings.json` at plugin root. Only `agent` key supported -- activates a plugin agent as the main thread.

### Installation Scopes

| Scope | Settings file | Use case |
|:------|:-------------|:---------|
| `user` (default) | `~/.claude/settings.json` | Personal, all projects |
| `project` | `.claude/settings.json` | Team, shared via VCS |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Read-only, admin-controlled |

### CLI Commands

| Command | Purpose |
|:--------|:--------|
| `claude plugin install <plugin> [-s scope]` | Install from marketplace |
| `claude plugin uninstall <plugin> [-s scope] [--keep-data]` | Remove plugin (aliases: `remove`, `rm`) |
| `claude plugin enable <plugin> [-s scope]` | Enable disabled plugin |
| `claude plugin disable <plugin> [-s scope]` | Disable without uninstalling |
| `claude plugin update <plugin> [-s scope]` | Update to latest version |
| `claude plugin validate` | Validate plugin.json, frontmatter, hooks.json |

### In-Session Commands

| Command | Purpose |
|:--------|:--------|
| `/plugin` | Open plugin manager (Discover / Installed / Marketplaces / Errors tabs) |
| `/plugin install <name>@<marketplace>` | Install plugin |
| `/plugin marketplace add <source>` | Add marketplace |
| `/plugin marketplace list` | List marketplaces |
| `/plugin marketplace update <name>` | Refresh marketplace |
| `/plugin marketplace remove <name>` | Remove marketplace (uninstalls its plugins) |
| `/reload-plugins` | Reload all plugins without restarting |

### Testing Locally

```
claude --plugin-dir ./my-plugin
```

Local `--plugin-dir` takes precedence over same-name installed plugins. Can load multiple: `claude --plugin-dir ./a --plugin-dir ./b`. Use `/reload-plugins` after edits.

### Marketplace Sources

Add marketplaces from:
- **GitHub:** `/plugin marketplace add owner/repo`
- **Git URLs:** `/plugin marketplace add https://gitlab.com/org/repo.git` (append `#ref` for branch/tag)
- **Local paths:** `/plugin marketplace add ./my-marketplace`
- **Remote URLs:** `/plugin marketplace add https://example.com/marketplace.json`

### Marketplace Schema (marketplace.json)

Located at `.claude-plugin/marketplace.json`. Required fields: `name` (kebab-case), `owner` (`{ "name": "..." }`), `plugins` (array).

**Plugin entry required fields:** `name`, `source`

**Plugin source types:**

| Source | Format | Notes |
|:-------|:-------|:------|
| Relative path | `"./plugins/my-plugin"` | Within marketplace repo, must start with `./` |
| `github` | `{ "source": "github", "repo": "owner/repo", "ref?": "...", "sha?": "..." }` | |
| `url` | `{ "source": "url", "url": "https://...", "ref?": "...", "sha?": "..." }` | Any git URL |
| `git-subdir` | `{ "source": "git-subdir", "url": "...", "path": "tools/plugin", "ref?": "...", "sha?": "..." }` | Sparse clone for monorepos |
| `npm` | `{ "source": "npm", "package": "@org/pkg", "version?": "...", "registry?": "..." }` | |

**Strict mode:** `true` (default) merges marketplace + plugin.json components. `false` means marketplace entry is the entire definition (plugin.json must not declare components).

### Auto-Updates

Official marketplaces: auto-update enabled by default. Third-party: disabled by default. Toggle per-marketplace in `/plugin` > Marketplaces. Disable all: `DISABLE_AUTOUPDATER=true`. Keep plugin updates while disabling CLI updates: also set `FORCE_AUTOUPDATE_PLUGINS=true`.

### Team / Managed Configuration

**Team marketplaces:** Add `extraKnownMarketplaces` and `enabledPlugins` to `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "company-tools": { "source": { "source": "github", "repo": "org/plugins" } }
  },
  "enabledPlugins": { "formatter@company-tools": true }
}
```

**Managed restrictions (`strictKnownMarketplaces`):**

| Value | Behavior |
|:------|:---------|
| Undefined | No restrictions |
| `[]` | Complete lockdown |
| List of sources | Only matching marketplaces allowed |

Supports `github`, `url`, `hostPattern` (regex), `pathPattern` (regex) source types. Set in managed settings (cannot be overridden).

### Container Pre-Population

Set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a pre-built plugins directory. Read-only, auto-updates disabled. Layer multiple with `:` separator. Structure mirrors `~/.claude/plugins/` (includes `known_marketplaces.json`, `marketplaces/`, `cache/`).

### Private Repository Auth

Manual install: uses existing git credential helpers. Auto-updates: set `GITHUB_TOKEN`/`GH_TOKEN`, `GITLAB_TOKEN`/`GL_TOKEN`, or `BITBUCKET_TOKEN` in environment. Git timeout: `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` (default 120s).

### Official Marketplace Categories

| Category | Plugins |
|:---------|:--------|
| **Code intelligence** (LSP) | pyright-lsp, typescript-lsp, rust-analyzer-lsp, gopls-lsp, clangd-lsp, jdtls-lsp, kotlin-lsp, lua-lsp, php-lsp, swift-lsp, csharp-lsp |
| **External integrations** | github, gitlab, atlassian, asana, linear, notion, figma, vercel, firebase, supabase, slack, sentry |
| **Dev workflows** | commit-commands, pr-review-toolkit, agent-sdk-dev, plugin-dev |
| **Output styles** | explanatory-output-style, learning-output-style |

### Version Management

Use semver (`MAJOR.MINOR.PATCH`). Set in `plugin.json` or `marketplace.json` (plugin.json wins if both set). Must bump version for users to see updates. Pre-release: `2.0.0-beta.1`.

### Debugging

- `claude --debug` shows plugin loading details
- `claude plugin validate` or `/plugin validate` checks plugin.json, frontmatter, hooks.json
- `/plugin` > Errors tab shows loading errors
- Common fix: ensure directories at plugin root, not inside `.claude-plugin/`
- Hook scripts need `chmod +x` and `${CLAUDE_PLUGIN_ROOT}` paths
- Event names are case-sensitive (`PostToolUse`, not `postToolUse`)

### Converting Standalone to Plugin

1. Create `my-plugin/.claude-plugin/plugin.json` with name, description, version
2. Copy `.claude/commands/` to `my-plugin/commands/`, `.claude/agents/` to `my-plugin/agents/`, `.claude/skills/` to `my-plugin/skills/`
3. Copy hooks from `settings.json` to `my-plugin/hooks/hooks.json`
4. Test with `claude --plugin-dir ./my-plugin`

### Submitting to Official Marketplace

- Claude.ai: `claude.ai/settings/plugins/submit`
- Console: `platform.claude.com/plugins/submit`

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) -- Plugin creation guide covering when to use plugins vs standalone, quickstart (manifest, skills, $ARGUMENTS, --plugin-dir), plugin structure overview (commands/ agents/ skills/ hooks/ .mcp.json .lsp.json settings.json), adding skills/LSP servers/default settings, organizing complex plugins, testing locally (--plugin-dir, /reload-plugins, multiple plugins), debugging, sharing and submission, converting standalone configs to plugins (migration steps and what changes)

- [Plugins reference](references/claude-code-plugins-reference.md) -- Complete technical reference covering plugin components (skills, agents with frontmatter fields, hooks with all lifecycle events and types, MCP servers, LSP servers with all config fields), installation scopes (user/project/local/managed), plugin manifest schema (required/metadata/component path fields), userConfig (sensitive/non-sensitive storage, ${user_config.KEY} substitution, keychain, env vars), channels (server binding, per-channel userConfig), path behavior rules, environment variables (${CLAUDE_PLUGIN_ROOT} and ${CLAUDE_PLUGIN_DATA} with persistent data directory pattern), plugin caching and file resolution (path traversal limitations, symlinks), plugin directory structure and file locations reference, CLI commands (install/uninstall/enable/disable/update with options), debugging and development tools (--debug, common issues, hook/MCP/LSP troubleshooting, directory structure mistakes), version management (semver, pre-release)

- [Discover and install plugins](references/claude-code-discover-plugins.md) -- Plugin discovery and installation covering official Anthropic marketplace (auto-available, /plugin install, code intelligence LSP plugins with binary requirements, external integrations, dev workflows, output styles), adding marketplaces (GitHub owner/repo, Git URLs with #ref, local paths, remote URLs), installing plugins (/plugin install with scopes), managing installed plugins (enable/disable/uninstall, /reload-plugins), managing marketplaces (interactive UI and CLI, auto-updates with DISABLE_AUTOUPDATER/FORCE_AUTOUPDATE_PLUGINS), team marketplaces (extraKnownMarketplaces, enabledPlugins), security warnings, troubleshooting (/plugin not recognized, common issues, code intelligence issues)

- [Create and distribute a marketplace](references/claude-code-plugin-marketplaces.md) -- Marketplace creation and distribution covering walkthrough (local marketplace with skill), marketplace schema (name/owner/plugins required, metadata.pluginRoot), plugin entries (required/optional fields, component config), plugin sources (relative path, github, url, git-subdir, npm with all fields), strict mode (true merges, false marketplace-only), hosting (GitHub recommended, other Git, private repos with credential helpers and tokens), team requirements (extraKnownMarketplaces, enabledPlugins), container pre-population (CLAUDE_CODE_PLUGIN_SEED_DIR), managed marketplace restrictions (strictKnownMarketplaces with hostPattern/pathPattern), version resolution and release channels, validation (claude plugin validate), troubleshooting (marketplace loading, validation errors, installation failures, auth, timeouts, relative paths in URL marketplaces, files not found after install)

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Create and distribute a marketplace: https://code.claude.com/docs/en/plugin-marketplaces.md
