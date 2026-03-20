---
name: plugins-doc
description: Complete documentation for Claude Code plugins -- creating plugins (quickstart, plugin structure, manifest, plugin.json schema with name/version/description/author/homepage/repository/license/keywords/commands/agents/skills/hooks/mcpServers/lspServers/outputStyles fields, component path fields, path behavior rules), plugin components (skills in skills/ or commands/ directories, agents in agents/, hooks in hooks/hooks.json with PostToolUse/PreToolUse/SessionStart/Stop/SubagentStart/SubagentStop/Notification/UserPromptSubmit/PermissionRequest/PostToolUseFailure/StopFailure/TeammateIdle/TaskCompleted/InstructionsLoaded/ConfigChange/WorktreeCreate/WorktreeRemove/PreCompact/PostCompact/Elicitation/ElicitationResult/SessionEnd events and command/http/prompt/agent types, MCP servers in .mcp.json, LSP servers in .lsp.json with command/extensionToLanguage/args/transport/env/initializationOptions/settings fields), environment variables (CLAUDE_PLUGIN_ROOT for bundled files, CLAUDE_PLUGIN_DATA for persistent state surviving updates), plugin directory structure (standard layout, file locations reference), testing locally (--plugin-dir flag, /reload-plugins, multiple plugins), debugging (claude --debug, /debug, common issues, plugin validate), installation scopes (user/project/local/managed), plugin caching and file resolution (cache at ~/.claude/plugins/cache, path traversal limitations, symlinks for external deps), CLI commands (plugin install/uninstall/enable/disable/update with --scope and --keep-data options), version management (semver MAJOR.MINOR.PATCH), converting standalone .claude/ configs to plugins, settings.json for default plugin settings (agent key), discovering and installing plugins (official Anthropic marketplace claude-plugins-official, /plugin UI with Discover/Installed/Marketplaces/Errors tabs, code intelligence LSP plugins for Python/TypeScript/Rust/Go/C/C++/C#/Java/Kotlin/Lua/PHP/Swift, external integration plugins github/gitlab/atlassian/asana/linear/notion/figma/vercel/firebase/supabase/slack/sentry, development workflow plugins commit-commands/pr-review-toolkit/agent-sdk-dev/plugin-dev, output style plugins), adding marketplaces (GitHub owner/repo, Git URLs with HTTPS/SSH, local paths, remote URLs, branch/tag pinning with #ref), installing plugins (/plugin install plugin@marketplace, user/project/local/managed scopes), managing plugins (enable/disable/uninstall, /reload-plugins), managing marketplaces (list/update/remove, auto-updates, DISABLE_AUTOUPDATER, FORCE_AUTOUPDATE_PLUGINS), team marketplaces (extraKnownMarketplaces in .claude/settings.json, enabledPlugins), plugin marketplaces (marketplace.json schema with name/owner/plugins/metadata fields, plugin entries with name/source/description/version/author/homepage/repository/license/keywords/category/tags/strict, plugin sources: relative path/github/url/git-subdir/npm/pip with ref/sha pinning, strict mode true vs false, hosting on GitHub/GitLab/other git, private repos with GITHUB_TOKEN/GITLAB_TOKEN/BITBUCKET_TOKEN, pre-populating for containers with CLAUDE_CODE_PLUGIN_SEED_DIR, managed marketplace restrictions with strictKnownMarketplaces allowlist/hostPattern/pathPattern, version resolution and release channels, validation with plugin validate, troubleshooting marketplace/plugin issues, CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS for git timeouts). Load when discussing Claude Code plugins, creating plugins, plugin manifest, plugin.json, plugin components, plugin skills, plugin agents, plugin hooks, plugin MCP servers, plugin LSP servers, CLAUDE_PLUGIN_ROOT, CLAUDE_PLUGIN_DATA, plugin directory structure, --plugin-dir, /reload-plugins, plugin install, plugin uninstall, plugin marketplace, marketplace.json, plugin sources, plugin distribution, plugin versioning, code intelligence plugins, pyright-lsp, typescript-lsp, rust-analyzer-lsp, strictKnownMarketplaces, extraKnownMarketplaces, enabledPlugins, plugin scopes, plugin caching, plugin validate, plugin troubleshooting, /plugin command, settings.json agent key, plugin auto-updates, or converting standalone configs to plugins.
user-invocable: false
---

# Plugins Documentation

This skill provides the complete official documentation for Claude Code's plugin system: creating, installing, distributing, and managing plugins and plugin marketplaces.

## Quick Reference

Plugins extend Claude Code with skills, agents, hooks, MCP servers, and LSP servers. They are self-contained directories that can be shared across projects and teams via marketplaces.

### Plugins vs Standalone Configuration

| Approach | Skill names | Best for |
|:---------|:------------|:---------|
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific customizations, quick experiments |
| **Plugins** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teammates, distributing to community, versioned releases, reusable across projects |

### Plugin Directory Structure

```
my-plugin/
  .claude-plugin/
    plugin.json            # Manifest (only file in this directory)
  commands/                # Skill Markdown files (legacy; use skills/)
  agents/                  # Subagent Markdown files
  skills/                  # Skills with <name>/SKILL.md structure
  hooks/
    hooks.json             # Hook configuration
  settings.json            # Default settings (only "agent" key supported)
  .mcp.json                # MCP server definitions
  .lsp.json                # LSP server configurations
  scripts/                 # Hook and utility scripts
```

Components must be at the plugin root, NOT inside `.claude-plugin/`. Only `plugin.json` belongs in `.claude-plugin/`.

### Plugin Manifest (plugin.json)

The manifest is optional. If omitted, Claude Code auto-discovers components in default locations and derives the name from the directory.

**Required field:**

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique identifier (kebab-case, no spaces); used as skill namespace prefix |

**Metadata fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `version` | string | Semantic version (MAJOR.MINOR.PATCH) |
| `description` | string | Brief explanation of plugin purpose |
| `author` | object | `{name, email?, url?}` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX license identifier |
| `keywords` | array | Discovery tags |

**Component path fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `commands` | string or array | Additional command files/directories |
| `agents` | string or array | Additional agent files |
| `skills` | string or array | Additional skill directories |
| `hooks` | string, array, or object | Hook config paths or inline config |
| `mcpServers` | string, array, or object | MCP config paths or inline config |
| `lspServers` | string, array, or object | LSP server configs |
| `outputStyles` | string or array | Output style files/directories |

Custom paths supplement defaults -- they do not replace them. All paths must be relative and start with `./`.

### Environment Variables

| Variable | Purpose | Survives updates? |
|:---------|:--------|:------------------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin's installation directory; use for bundled scripts, binaries, config | No |
| `${CLAUDE_PLUGIN_DATA}` | Persistent directory for plugin state (`~/.claude/plugins/data/{id}/`); use for node_modules, venvs, caches | Yes |

Both are substituted inline in skill content, agent content, hook commands, and MCP/LSP server configs. Both are also exported as env vars to hook processes and server subprocesses.

### Plugin Components

**Skills:** `skills/<name>/SKILL.md` or `commands/<name>.md`. Auto-discovered when installed.

**Agents:** `agents/<name>.md` with frontmatter (`name`, `description`). Appear in `/agents`.

**Hooks:** `hooks/hooks.json` or inline in `plugin.json`. Respond to lifecycle events:

| Event | When it fires |
|:------|:--------------|
| `SessionStart` | Session begins or resumes |
| `UserPromptSubmit` | Prompt submitted, before processing |
| `PreToolUse` | Before tool call executes (can block) |
| `PermissionRequest` | Permission dialog appears |
| `PostToolUse` | After tool call succeeds |
| `PostToolUseFailure` | After tool call fails |
| `Notification` | Claude Code sends a notification |
| `SubagentStart` | Subagent spawned |
| `SubagentStop` | Subagent finishes |
| `Stop` | Claude finishes responding |
| `StopFailure` | Turn ends due to API error |
| `TeammateIdle` | Agent team teammate about to go idle |
| `TaskCompleted` | Task being marked as completed |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded into context |
| `ConfigChange` | Configuration file changes during session |
| `WorktreeCreate` | Worktree being created |
| `WorktreeRemove` | Worktree being removed |
| `PreCompact` | Before context compaction |
| `PostCompact` | After context compaction completes |
| `Elicitation` | MCP server requests user input |
| `ElicitationResult` | User responds to MCP elicitation |
| `SessionEnd` | Session terminates |

Hook types: `command` (shell), `http` (POST), `prompt` (LLM evaluation), `agent` (agentic verifier).

**MCP servers:** `.mcp.json` or inline in `plugin.json`. Start automatically when plugin is enabled.

**LSP servers:** `.lsp.json` or inline in `plugin.json`. Required fields: `command`, `extensionToLanguage`. Optional: `args`, `transport` (stdio/socket), `env`, `initializationOptions`, `settings`, `workspaceFolder`, `startupTimeout`, `shutdownTimeout`, `restartOnCrash`, `maxRestarts`.

### Installation Scopes

| Scope | Settings file | Use case |
|:------|:-------------|:---------|
| `user` | `~/.claude/settings.json` | Personal plugins across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific plugins, gitignored |
| `managed` | Managed settings | Managed plugins (read-only, update only) |

### CLI Commands

| Command | Description | Key options |
|:--------|:------------|:------------|
| `claude plugin install <plugin>` | Install from marketplace | `--scope user/project/local` |
| `claude plugin uninstall <plugin>` | Remove plugin (aliases: `remove`, `rm`) | `--scope`, `--keep-data` |
| `claude plugin enable <plugin>` | Enable disabled plugin | `--scope` |
| `claude plugin disable <plugin>` | Disable without uninstalling | `--scope` |
| `claude plugin update <plugin>` | Update to latest version | `--scope` (includes `managed`) |
| `claude plugin validate .` | Validate plugin manifest, frontmatter, hooks | |

Plugin argument format: `plugin-name` or `plugin-name@marketplace-name`.

### Testing Locally

```bash
claude --plugin-dir ./my-plugin
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

Run `/reload-plugins` to pick up changes without restarting. Local `--plugin-dir` plugins override installed plugins of the same name (except managed force-enabled plugins).

### Official Marketplace

The `claude-plugins-official` marketplace is automatically available. Browse via `/plugin` > Discover tab.

**Code intelligence LSP plugins:**

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

LSP plugins provide automatic diagnostics (errors/warnings after edits) and code navigation (go to definition, find references, hover info).

**External integrations:** `github`, `gitlab`, `atlassian`, `asana`, `linear`, `notion`, `figma`, `vercel`, `firebase`, `supabase`, `slack`, `sentry`.

### Adding Marketplaces

| Source | Command |
|:-------|:--------|
| GitHub | `/plugin marketplace add owner/repo` |
| Git URL (HTTPS) | `/plugin marketplace add https://gitlab.com/company/plugins.git` |
| Git URL (SSH) | `/plugin marketplace add git@gitlab.com:company/plugins.git` |
| Specific ref | Append `#ref` (e.g., `#v1.0.0`) |
| Local path | `/plugin marketplace add ./my-marketplace` |
| Remote URL | `/plugin marketplace add https://example.com/marketplace.json` |

Shortcut: `/plugin market` instead of `/plugin marketplace`.

### Marketplace Schema (marketplace.json)

Located at `.claude-plugin/marketplace.json`.

**Required fields:** `name` (kebab-case), `owner` (`{name, email?}`), `plugins` (array).

**Optional:** `metadata.description`, `metadata.version`, `metadata.pluginRoot` (base directory for relative plugin source paths).

### Plugin Sources in marketplace.json

| Source type | `source` field | Key fields |
|:------------|:---------------|:-----------|
| Relative path | `"./plugins/my-plugin"` (string) | Must start with `./` |
| GitHub | `{source: "github", repo: "owner/repo"}` | Optional: `ref`, `sha` |
| Git URL | `{source: "url", url: "https://..."}` | Optional: `ref`, `sha` |
| Git subdirectory | `{source: "git-subdir", url, path}` | Sparse clone; optional: `ref`, `sha` |
| npm | `{source: "npm", package: "@org/pkg"}` | Optional: `version`, `registry` |
| pip | `{source: "pip", package: "pkg"}` | Optional: `version`, `registry` |

### Strict Mode

| `strict` value | Behavior |
|:---------------|:---------|
| `true` (default) | `plugin.json` is authority; marketplace entry can supplement with additional components |
| `false` | Marketplace entry is entire definition; conflicting `plugin.json` components cause load failure |

### Team & Enterprise Configuration

**Team marketplaces** -- add to `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "team-tools": {
      "source": {"source": "github", "repo": "your-org/plugins"}
    }
  },
  "enabledPlugins": {
    "formatter@team-tools": true
  }
}
```

**Managed marketplace restrictions** (`strictKnownMarketplaces` in managed settings):

| Value | Behavior |
|:------|:---------|
| Undefined | No restrictions |
| Empty array `[]` | Complete lockdown -- no new marketplaces |
| List of sources | Only matching marketplaces allowed |

Source types for allowlist: `{source: "github", repo}`, `{source: "url", url}`, `{source: "hostPattern", hostPattern: "^regex$"}`, `{source: "pathPattern", pathPattern: "^regex$"}`.

### Auto-Updates

Toggle per-marketplace via `/plugin` > Marketplaces. Official marketplaces auto-update by default; third-party disabled by default.

| Variable | Effect |
|:---------|:-------|
| `DISABLE_AUTOUPDATER` | Disables all auto-updates (Claude Code + plugins) |
| `FORCE_AUTOUPDATE_PLUGINS=true` | Keep plugin auto-updates while disabling Claude Code updates |

### Private Repositories

Manual install uses git credential helpers. Background auto-updates need environment tokens:

| Provider | Variable |
|:---------|:---------|
| GitHub | `GITHUB_TOKEN` or `GH_TOKEN` |
| GitLab | `GITLAB_TOKEN` or `GL_TOKEN` |
| Bitbucket | `BITBUCKET_TOKEN` |

### Container Pre-Population

Set `CLAUDE_CODE_PLUGIN_SEED_DIR` pointing to a pre-built `~/.claude/plugins` directory copy. Supports multiple paths separated by `:` (Unix) or `;` (Windows). Seed directory is read-only; auto-updates disabled for seed marketplaces.

### Plugin Caching

Marketplace plugins are copied to `~/.claude/plugins/cache`. Paths referencing files outside the plugin directory will not work after installation. Use symlinks for external dependencies.

### Debugging

- `claude --debug` or `/debug` -- shows plugin loading details, errors, registration
- `/plugin` > Errors tab -- view plugin loading errors
- `claude plugin validate .` or `/plugin validate .` -- check manifest, frontmatter, hooks.json

**Common issues:**

| Issue | Solution |
|:------|:---------|
| Plugin not loading | Run `plugin validate`; check `plugin.json` syntax |
| Components missing | Ensure directories are at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | `chmod +x script.sh`; verify event name is case-sensitive; check hook type |
| MCP server fails | Use `${CLAUDE_PLUGIN_ROOT}` for all paths |
| Path errors | All paths must be relative, starting with `./` |
| LSP binary not found | Install the language server binary separately |
| Skills not appearing | Clear cache: `rm -rf ~/.claude/plugins/cache`, restart, reinstall |
| Git timeout | Set `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` (default 120000ms) |

### Submitting to Official Marketplace

- **Claude.ai**: claude.ai/settings/plugins/submit
- **Console**: platform.claude.com/plugins/submit

## Full Documentation

For the complete official documentation, see the reference files:

- [Create plugins](references/claude-code-plugins.md) -- when to use plugins vs standalone (comparison table), quickstart (prerequisites, creating manifest, adding skills, testing with --plugin-dir, $ARGUMENTS for dynamic skills), plugin structure overview (directories at root not in .claude-plugin, components table), developing complex plugins (adding Skills with SKILL.md, adding LSP servers with .lsp.json, shipping default settings with settings.json agent key, organizing complex plugins, testing locally with --plugin-dir and /reload-plugins, debugging with --debug), sharing plugins (documentation, versioning, marketplace distribution, official marketplace submission via Claude.ai or Console), converting standalone .claude/ configs to plugins (migration steps, what changes table)
- [Plugins reference](references/claude-code-plugins-reference.md) -- plugin components reference (skills in skills/ or commands/, agents in agents/, hooks in hooks/hooks.json with all lifecycle events and hook types command/http/prompt/agent, MCP servers in .mcp.json, LSP servers in .lsp.json with all config fields), installation scopes (user/project/local/managed), plugin manifest schema (required name field, metadata fields version/description/author/homepage/repository/license/keywords, component path fields commands/agents/skills/hooks/mcpServers/outputStyles/lspServers, path behavior rules), environment variables (CLAUDE_PLUGIN_ROOT and CLAUDE_PLUGIN_DATA with persistent data directory patterns and SessionStart npm install example), plugin caching and file resolution (cache location, path traversal limitations, symlinks), plugin directory structure (standard layout, file locations reference table), CLI commands reference (install/uninstall/enable/disable/update with all options), debugging and development tools (--debug, common issues table, hook/MCP/directory troubleshooting), version management (semver format, best practices, caching warning)
- [Discover and install plugins](references/claude-code-discover-plugins.md) -- how marketplaces work (add then install), official Anthropic marketplace (claude-plugins-official, code intelligence LSP plugins table with languages/binaries, what Claude gains from LSP, external integration plugins, development workflow plugins, output style plugins), demo marketplace walkthrough, adding marketplaces (GitHub owner/repo, Git URLs HTTPS/SSH, branch/tag pinning, local paths, remote URLs), installing plugins (/plugin install with scopes, interactive UI), managing plugins (enable/disable/uninstall, --scope, /reload-plugins), managing marketplaces (interactive UI, CLI list/update/remove, auto-updates with DISABLE_AUTOUPDATER and FORCE_AUTOUPDATE_PLUGINS), team marketplaces (extraKnownMarketplaces in .claude/settings.json), security warnings, troubleshooting (/plugin command not recognized, marketplace not loading, installation failures, files not found, skills not appearing, code intelligence issues)
- [Plugin marketplaces](references/claude-code-plugin-marketplaces.md) -- overview (creating, hosting, distributing), walkthrough creating local marketplace, marketplace.json schema (required name/owner/plugins, reserved names, owner fields, optional metadata with pluginRoot), plugin entries (required name/source, optional metadata and component fields), plugin sources (relative paths, github with repo/ref/sha, url with url/ref/sha, git-subdir with url/path/ref/sha for sparse clone, npm with package/version/registry, pip with package/version/registry), strict mode (true default vs false), hosting (GitHub recommended, other git, private repos with credential helpers and GITHUB_TOKEN/GITLAB_TOKEN/BITBUCKET_TOKEN, testing locally, team marketplace via extraKnownMarketplaces/enabledPlugins, container pre-population with CLAUDE_CODE_PLUGIN_SEED_DIR and seed behavior, managed restrictions with strictKnownMarketplaces allowlist/hostPattern/pathPattern), version resolution and release channels (stable/latest via separate marketplaces and managed settings), validation and testing (plugin validate), troubleshooting (marketplace not loading, validation errors table, installation failures, private repo auth, git timeouts with CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS, relative paths in URL-based marketplaces, files not found after install)

## Sources

- Create plugins: https://code.claude.com/docs/en/plugins.md
- Plugins reference: https://code.claude.com/docs/en/plugins-reference.md
- Discover and install plugins: https://code.claude.com/docs/en/discover-plugins.md
- Plugin marketplaces: https://code.claude.com/docs/en/plugin-marketplaces.md
