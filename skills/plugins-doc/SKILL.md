---
name: plugins-doc
description: Complete documentation for Claude Code plugins -- covering plugin creation (manifest, skills, agents, hooks, MCP servers, LSP servers, settings.json, directory structure, quickstart, migration from standalone .claude/ configs), plugins reference (full manifest schema with required/metadata/component-path fields, userConfig for prompted values with sensitive keychain storage, channels for message injection, environment variables CLAUDE_PLUGIN_ROOT and CLAUDE_PLUGIN_DATA with persistent data directory and dependency install patterns, plugin caching and file resolution, plugin directory structure and file locations, CLI commands plugin install/uninstall/enable/disable/update with --scope and --keep-data, debugging with --debug and plugin validate, common issues and error messages, hook/MCP/LSP troubleshooting, version management with semver, installation scopes user/project/local/managed, LSP server configuration with extensionToLanguage/transport/initializationOptions/settings/restartOnCrash), discovering and installing plugins (official Anthropic marketplace claude-plugins-official, code intelligence LSP plugins for Python/TypeScript/Rust/Go/C++/Java/Kotlin/Swift/PHP/Lua/C#, external integrations github/gitlab/atlassian/asana/linear/notion/figma/vercel/firebase/supabase/slack/sentry, development workflow plugins, output styles, adding marketplaces from GitHub/Git/local/URL, installing with scopes, managing installed plugins, /reload-plugins, auto-updates with DISABLE_AUTOUPDATER and FORCE_AUTOUPDATE_PLUGINS, team marketplaces via extraKnownMarketplaces, security trust model, troubleshooting), and plugin marketplaces (marketplace.json schema with name/owner/plugins/metadata fields, plugin entries with source/category/tags/strict, plugin sources relative-path/github/url/git-subdir/npm with ref/sha pinning, strict mode true vs false, hosting on GitHub/GitLab/private repos with auth tokens, managed marketplace restrictions via strictKnownMarketplaces with hostPattern/pathPattern, CLAUDE_CODE_PLUGIN_SEED_DIR for containers, version resolution and release channels, validation with plugin validate, troubleshooting installation/auth/timeout/relative-path failures). Load when discussing Claude Code plugins, plugin creation, plugin manifest plugin.json, plugin directory structure, plugin components (skills agents hooks MCP LSP in plugins), plugin installation, plugin marketplaces, marketplace.json, plugin distribution, /plugin command, --plugin-dir, /reload-plugins, plugin scopes, plugin debugging, plugin validate, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, userConfig, plugin channels, LSP plugins, code intelligence plugins, plugin sources, plugin caching, extraKnownMarketplaces, strictKnownMarketplaces, enabledPlugins, plugin auto-updates, or any plugin-related topic for Claude Code.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code plugins -- covering plugin creation, the full plugins reference, discovering and installing plugins, and plugin marketplaces.

## Quick Reference

### When to Use Plugins vs Standalone Configuration

| Approach | Skill names | Best for |
|:---------|:------------|:---------|
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugins** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teammates, community distribution, versioned releases, reuse across projects |

### Plugin Directory Structure

```
my-plugin/
+-- .claude-plugin/
|   +-- plugin.json            # Manifest (only file inside .claude-plugin/)
+-- commands/                  # Skill Markdown files (legacy)
+-- skills/                    # Skills with <name>/SKILL.md structure
+-- agents/                    # Subagent Markdown files
+-- hooks/
|   +-- hooks.json             # Hook configuration
+-- output-styles/             # Output style definitions
+-- settings.json              # Default settings (currently only "agent" key)
+-- .mcp.json                  # MCP server definitions
+-- .lsp.json                  # LSP server configurations
+-- scripts/                   # Hook and utility scripts
```

Components must be at the plugin root, NOT inside `.claude-plugin/`. Only `plugin.json` goes inside `.claude-plugin/`.

### Plugin Manifest (plugin.json)

**Required fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique identifier (kebab-case). Used as skill namespace prefix |

**Metadata fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `version` | string | Semver version (MAJOR.MINOR.PATCH) |
| `description` | string | Brief explanation of plugin purpose |
| `author` | object | `{name, email, url}` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX identifier (e.g., `MIT`) |
| `keywords` | array | Discovery tags |

**Component path fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `commands` | string or array | Custom command files/directories (replaces default `commands/`) |
| `agents` | string or array | Custom agent files (replaces default `agents/`) |
| `skills` | string or array | Custom skill directories (replaces default `skills/`) |
| `hooks` | string, array, or object | Hook config paths or inline config |
| `mcpServers` | string, array, or object | MCP config paths or inline config |
| `lspServers` | string, array, or object | LSP server configurations |
| `outputStyles` | string or array | Custom output style files/directories |
| `userConfig` | object | User-configurable values prompted at enable time |
| `channels` | array | Channel declarations for message injection |

Custom paths for commands/agents/skills/outputStyles **replace** the default directory. To keep defaults and add more, include the default in the array: `"commands": ["./commands/", "./extras/deploy.md"]`.

All paths must be relative and start with `./`.

### Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin installation directory. Changes on update |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state. Survives updates. Resolves to `~/.claude/plugins/data/{id}/` |

Both are substituted inline in skill/agent content, hook commands, and MCP/LSP configs. Also exported as environment variables to subprocesses.

**Persistent data pattern** (install deps once, reinstall when manifest changes):

```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "diff -q \"${CLAUDE_PLUGIN_ROOT}/package.json\" \"${CLAUDE_PLUGIN_DATA}/package.json\" >/dev/null 2>&1 || (cd \"${CLAUDE_PLUGIN_DATA}\" && cp \"${CLAUDE_PLUGIN_ROOT}/package.json\" . && npm install) || rm -f \"${CLAUDE_PLUGIN_DATA}/package.json\""
      }]
    }]
  }
}
```

### User Configuration (userConfig)

Declares values Claude Code prompts the user for when the plugin is enabled:

```json
{
  "userConfig": {
    "api_endpoint": { "description": "Your team's API endpoint", "sensitive": false },
    "api_token": { "description": "API authentication token", "sensitive": true }
  }
}
```

- Available as `${user_config.KEY}` in MCP/LSP configs, hook commands, and non-sensitive values in skill/agent content
- Exported as `CLAUDE_PLUGIN_OPTION_<KEY>` environment variables
- Non-sensitive values stored in `settings.json` under `pluginConfigs[<plugin-id>].options`
- Sensitive values stored in system keychain (approx. 2 KB total limit)

### Channels

Declare message channels that inject content into conversations, bound to an MCP server:

```json
{
  "channels": [{
    "server": "telegram",
    "userConfig": {
      "bot_token": { "description": "Telegram bot token", "sensitive": true },
      "owner_id": { "description": "Your Telegram user ID", "sensitive": false }
    }
  }]
}
```

The `server` field must match a key in the plugin's `mcpServers`.

### Plugin Components

**Skills:** `skills/<name>/SKILL.md` with frontmatter (`name`, `description`). Auto-discovered. Can include supporting files.

**Agents:** `agents/*.md` with frontmatter supporting `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation` (only `"worktree"`). Security: `hooks`, `mcpServers`, and `permissionMode` are NOT supported for plugin agents.

**Hooks:** `hooks/hooks.json` or inline in plugin.json. Same lifecycle events as user-defined hooks.

Hook events: `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PermissionRequest`, `PostToolUse`, `PostToolUseFailure`, `Notification`, `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `Stop`, `StopFailure`, `TeammateIdle`, `InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `FileChanged`, `WorktreeCreate`, `WorktreeRemove`, `PreCompact`, `PostCompact`, `Elicitation`, `ElicitationResult`, `SessionEnd`.

Hook types: `command` (shell), `http` (POST), `prompt` (LLM eval), `agent` (agentic verifier).

**MCP servers:** `.mcp.json` or inline. Auto-start when plugin is enabled. Use `${CLAUDE_PLUGIN_ROOT}` for paths.

**LSP servers:** `.lsp.json` or inline. Required fields: `command`, `extensionToLanguage`. Optional: `args`, `transport` (`stdio`/`socket`), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`. The language server binary must be installed separately.

**Settings:** `settings.json` at plugin root. Currently only `agent` key supported -- activates a plugin agent as the main thread.

### Plugin Installation Scopes

| Scope | Settings file | Use case |
|:------|:-------------|:---------|
| `user` | `~/.claude/settings.json` | Personal, across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific, gitignored |
| `managed` | Managed settings | Admin-controlled (read-only, update only) |

### CLI Commands

```
claude plugin install <plugin> [-s user|project|local]
claude plugin uninstall <plugin> [-s scope] [--keep-data]
claude plugin enable <plugin> [-s scope]
claude plugin disable <plugin> [-s scope]
claude plugin update <plugin> [-s scope]
claude plugin validate .
```

Aliases for uninstall: `remove`, `rm`.

### Testing Locally

```bash
claude --plugin-dir ./my-plugin
```

Multiple plugins: `claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two`

When `--plugin-dir` plugin has the same name as an installed marketplace plugin, the local copy takes precedence (except managed force-enabled plugins).

Reload changes without restarting: `/reload-plugins`

### Official Marketplace Plugins

**Code intelligence (LSP):**

| Language | Plugin | Binary required |
|:---------|:-------|:----------------|
| C/C++ | `clangd-lsp` | `clangd` |
| C# | `csharp-lsp` | `csharp-ls` |
| Go | `gopls-lsp` | `gopls` |
| Java | `jdtls-lsp` | `jdtls` |
| Kotlin | `kotlin-lsp` | `kotlin-language-server` |
| Lua | `lua-lsp` | `lua-language-server` |
| PHP | `php-lsp` | `intelephense` |
| Python | `pyright-lsp` | `pyright-langserver` |
| Rust | `rust-analyzer-lsp` | `rust-analyzer` |
| Swift | `swift-lsp` | `sourcekit-lsp` |
| TypeScript | `typescript-lsp` | `typescript-language-server` |

LSP provides automatic diagnostics after edits and code navigation (go to definition, find references, hover info, symbols, implementations, call hierarchy).

**External integrations:** `github`, `gitlab`, `atlassian` (Jira/Confluence), `asana`, `linear`, `notion`, `figma`, `vercel`, `firebase`, `supabase`, `slack`, `sentry`

**Development workflows:** `commit-commands`, `pr-review-toolkit`, `agent-sdk-dev`, `plugin-dev`

**Output styles:** `explanatory-output-style`, `learning-output-style`

### Adding Marketplaces

```shell
/plugin marketplace add owner/repo                       # GitHub
/plugin marketplace add https://gitlab.com/company/plugins.git  # Git URL
/plugin marketplace add https://gitlab.com/company/plugins.git#v1.0.0  # Pinned ref
/plugin marketplace add ./my-marketplace                 # Local path
/plugin marketplace add https://example.com/marketplace.json    # Remote URL
```

Manage: `/plugin marketplace list`, `/plugin marketplace update <name>`, `/plugin marketplace remove <name>`

Shortcut: `/plugin market` instead of `/plugin marketplace`.

### Marketplace Schema (marketplace.json)

Located at `.claude-plugin/marketplace.json`.

**Required fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Marketplace identifier (kebab-case). Users see it when installing plugins |
| `owner` | object | `{name, email?}` |
| `plugins` | array | List of plugin entries |

**Optional:** `metadata.description`, `metadata.version`, `metadata.pluginRoot` (base directory for relative source paths).

**Plugin entry required fields:** `name`, `source`.

**Plugin sources:**

| Source | Type | Key fields |
|:-------|:-----|:-----------|
| Relative path | string (`"./my-plugin"`) | Must start with `./`. Works only with Git-based marketplaces |
| `github` | object | `repo` (required), `ref?`, `sha?` |
| `url` | object | `url` (required), `ref?`, `sha?` |
| `git-subdir` | object | `url` (required), `path` (required), `ref?`, `sha?`. Sparse clone |
| `npm` | object | `package` (required), `version?`, `registry?` |

**Strict mode:** `strict: true` (default) -- plugin.json is authority, marketplace supplements. `strict: false` -- marketplace entry is the entire definition.

### Team and Managed Configuration

**Team marketplaces** via `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "company-tools": {
      "source": { "source": "github", "repo": "your-org/claude-plugins" }
    }
  },
  "enabledPlugins": {
    "code-formatter@company-tools": true
  }
}
```

**Auto-updates:** Official marketplaces auto-update by default. Toggle per-marketplace via `/plugin` > Marketplaces. Disable all: `DISABLE_AUTOUPDATER=true`. Keep plugin updates while disabling Claude Code updates: `FORCE_AUTOUPDATE_PLUGINS=true`.

**Managed marketplace restrictions** via `strictKnownMarketplaces` in managed settings:

| Value | Behavior |
|:------|:---------|
| Undefined | No restrictions |
| Empty array `[]` | Complete lockdown |
| List of sources | Allowlist only |

Supports `github`, `url`, `hostPattern` (regex on host), and `pathPattern` (regex on filesystem path) source types.

**Container pre-population:** Set `CLAUDE_CODE_PLUGIN_SEED_DIR` to a directory mirroring `~/.claude/plugins` structure. Read-only, seed entries take precedence. Multiple paths separated by `:` (Unix) or `;` (Windows).

**Private repositories:** Use existing git credential helpers for manual operations. For auto-updates, set `GITHUB_TOKEN`/`GH_TOKEN`, `GITLAB_TOKEN`/`GL_TOKEN`, or `BITBUCKET_TOKEN`.

**Git timeout:** `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` (default 120000ms).

### Debugging

Run `claude --debug` to see plugin loading details. Run `claude plugin validate .` or `/plugin validate .` to check plugin.json, frontmatter, and hooks.json for errors.

**Common issues:**

| Issue | Solution |
|:------|:---------|
| Plugin not loading | Run `claude plugin validate` or `/plugin validate` |
| Commands not appearing | Check directories are at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Ensure script is executable (`chmod +x`), check event name (case-sensitive), verify `${CLAUDE_PLUGIN_ROOT}` paths |
| MCP server fails | Verify `${CLAUDE_PLUGIN_ROOT}` in all paths, check server binary, use `--debug` |
| LSP executable not found | Install the language server binary |
| Files not found after install | Plugins are cached; use `${CLAUDE_PLUGIN_ROOT}` or symlinks for external files |

### Version Management

Semver format: MAJOR.MINOR.PATCH. Version can be set in `plugin.json` or `marketplace.json` (plugin.json takes priority). Always bump version before distributing changes -- caching prevents updates if version is unchanged.

### Plugin Submission

Submit to the official marketplace via:
- Claude.ai: `claude.ai/settings/plugins/submit`
- Console: `platform.claude.com/plugins/submit`

## Full Documentation

For the complete official documentation, see the reference files:

- [Create Plugins](references/claude-code-plugins.md) -- When to use plugins vs standalone, quickstart (manifest, skills, $ARGUMENTS, --plugin-dir), plugin structure overview (commands/agents/skills/hooks/.mcp.json/.lsp.json/settings.json), adding skills with SKILL.md frontmatter, adding LSP servers, shipping default settings with agent key, organizing complex plugins, testing locally with --plugin-dir and /reload-plugins, debugging plugin issues, sharing and versioning, submitting to official marketplace, converting existing .claude/ configurations to plugins (migration steps, what changes)
- [Plugins Reference](references/claude-code-plugins-reference.md) -- Plugin components reference (skills, agents with frontmatter fields, hooks with lifecycle events and types, MCP servers, LSP servers with all configuration fields), installation scopes (user/project/local/managed), complete manifest schema (required fields, metadata fields, component path fields with replacement semantics, userConfig with sensitive keychain storage and ${user_config.KEY} substitution, channels with per-channel userConfig), path behavior rules, environment variables (CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA with persistent data directory pattern), plugin caching and file resolution (path traversal limitations, symlinks), standard directory layout, file locations reference, CLI commands reference (install/uninstall/enable/disable/update with options), debugging and development tools (--debug, common issues table, error messages, hook/MCP/LSP troubleshooting, directory structure mistakes), version management (semver, CHANGELOG.md)
- [Discover and Install Plugins](references/claude-code-discover-plugins.md) -- How marketplaces work, official Anthropic marketplace (claude-plugins-official, /plugin Discover tab), code intelligence LSP plugins table with binaries, what Claude gains from LSP (automatic diagnostics, code navigation), external integrations list, development workflow plugins, output styles, demo marketplace (anthropics/claude-code), adding marketplaces from GitHub/Git/local/URL, installing plugins with scopes, managing installed plugins (enable/disable/uninstall, /reload-plugins), marketplace management (list/update/remove), auto-updates (DISABLE_AUTOUPDATER, FORCE_AUTOUPDATE_PLUGINS), team marketplaces via extraKnownMarketplaces and enabledPlugins, security trust model, troubleshooting (/plugin not recognized, common issues, code intelligence issues)
- [Plugin Marketplaces](references/claude-code-plugin-marketplaces.md) -- Marketplace overview and walkthrough, marketplace.json schema (required fields name/owner/plugins, owner fields, optional metadata, pluginRoot), plugin entries (required name/source, optional metadata and component config fields), plugin sources (relative paths, github, url/git, git-subdir with sparse clone, npm with registry), strict mode (true default vs false), advanced plugin entries example, hosting and distribution (GitHub recommended, other git hosts, private repos with credential helpers and auth tokens GITHUB_TOKEN/GITLAB_TOKEN/BITBUCKET_TOKEN), team configuration (extraKnownMarketplaces, enabledPlugins), container pre-population (CLAUDE_CODE_PLUGIN_SEED_DIR with read-only layered paths), managed marketplace restrictions (strictKnownMarketplaces with hostPattern/pathPattern), version resolution and release channels, validation with plugin validate, troubleshooting (marketplace not loading, validation errors table, installation failures, private auth, git timeouts with CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS, relative paths in URL marketplaces, files not found after install)

## Sources

- Create Plugins: https://code.claude.com/docs/en/plugins.md
- Plugins Reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and Install Plugins: https://code.claude.com/docs/en/discover-plugins.md
- Plugin Marketplaces: https://code.claude.com/docs/en/plugin-marketplaces.md
