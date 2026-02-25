---
name: settings
description: Reference documentation for Claude Code settings — configuration scopes, settings.json options, permissions (allow/ask/deny rules, rule syntax, modes, managed-only policies), sandbox configuration, environment variables, plugin settings, attribution, file suggestion, tools, bash behavior, and server-managed settings delivery.
user-invocable: false
---

# Settings Documentation

This skill provides the complete official documentation for Claude Code settings, permissions, and server-managed settings.

## Quick Reference

### Configuration Scopes

| Scope       | Location                                               | Affects                | Shared? |
|:------------|:-------------------------------------------------------|:-----------------------|:--------|
| **Managed** | Server-managed, MDM/plist/registry, `managed-settings.json` | All users on machine   | Yes     |
| **User**    | `~/.claude/settings.json`                              | You, all projects      | No      |
| **Project** | `.claude/settings.json`                                | All collaborators      | Yes     |
| **Local**   | `.claude/settings.local.json`                          | You, this project only | No      |

**Precedence** (highest to lowest): Managed > CLI args > Local > Project > User.

### Feature Locations

| Feature       | User                      | Project                              | Local                          |
|:--------------|:--------------------------|:-------------------------------------|:-------------------------------|
| Settings      | `~/.claude/settings.json` | `.claude/settings.json`              | `.claude/settings.local.json`  |
| Subagents     | `~/.claude/agents/`       | `.claude/agents/`                    | --                             |
| MCP servers   | `~/.claude.json`          | `.mcp.json`                          | `~/.claude.json` (per-project) |
| Plugins       | `~/.claude/settings.json` | `.claude/settings.json`              | `.claude/settings.local.json`  |
| CLAUDE.md     | `~/.claude/CLAUDE.md`     | `CLAUDE.md` or `.claude/CLAUDE.md`   | `CLAUDE.local.md`              |

### Key settings.json Options

| Key                          | Description                                                    |
|:-----------------------------|:---------------------------------------------------------------|
| `permissions`                | Allow/ask/deny rules (see below)                               |
| `env`                        | Environment variables applied to every session                 |
| `hooks`                      | Custom commands at lifecycle events                            |
| `model`                      | Override the default model                                     |
| `availableModels`            | Restrict model selection in `/model`                           |
| `sandbox`                    | Sandbox configuration (see below)                              |
| `attribution`                | Customize git commit and PR attribution                        |
| `apiKeyHelper`               | Script to generate auth value                                  |
| `outputStyle`                | Adjust system prompt output style                              |
| `language`                   | Claude's preferred response language                           |
| `companyAnnouncements`       | Startup announcements (cycled randomly)                        |
| `enabledPlugins`             | Enable/disable plugins (`"name@marketplace": bool`)            |
| `extraKnownMarketplaces`     | Additional plugin marketplace sources                          |
| `fileSuggestion`             | Custom `@` file autocomplete command                           |
| `statusLine`                 | Custom status line display                                     |
| `cleanupPeriodDays`          | Session cleanup threshold (default: 30)                        |
| `autoUpdatesChannel`         | `"stable"` or `"latest"` (default)                             |
| `plansDirectory`             | Where plan files are stored                                    |
| `alwaysThinkingEnabled`      | Enable extended thinking by default                            |
| `forceLoginMethod`           | `"claudeai"` or `"console"`                                    |
| `teammateMode`               | Agent team display: `auto`, `in-process`, or `tmux`            |

### Permission Settings

| Key                       | Description                                           |
|:--------------------------|:------------------------------------------------------|
| `allow`                   | Rules to allow tool use without prompting              |
| `ask`                     | Rules to prompt for confirmation                       |
| `deny`                    | Rules to block tool use                                |
| `additionalDirectories`   | Extra working directories Claude can access            |
| `defaultMode`             | Default permission mode                                |
| `disableBypassPermissionsMode` | Set `"disable"` to prevent bypass mode            |

**Rule syntax**: `Tool` or `Tool(specifier)`. Evaluated: deny first, then ask, then allow.

| Pattern                        | Matches                                   |
|:-------------------------------|:------------------------------------------|
| `Bash`                         | All Bash commands                         |
| `Bash(npm run *)`              | Commands starting with `npm run`          |
| `Read(./.env)`                 | The `.env` file                           |
| `Read(~/.zshrc)`               | Home directory `.zshrc`                   |
| `Read(//Users/alice/secrets/**)` | Absolute path                           |
| `Edit(/src/**/*.ts)`           | Relative to project root                  |
| `WebFetch(domain:example.com)` | Fetch requests to example.com             |
| `mcp__server__tool`            | Specific MCP tool                         |
| `Task(Explore)`                | Specific subagent                         |

### Permission Modes

| Mode                | Description                                              |
|:--------------------|:---------------------------------------------------------|
| `default`           | Prompts on first use of each tool                        |
| `acceptEdits`       | Auto-accepts file edits for the session                  |
| `plan`              | Analyze only, no modifications                           |
| `dontAsk`           | Auto-denies unless pre-approved                          |
| `bypassPermissions` | Skips all prompts (isolated environments only)           |

### Sandbox Settings (under `sandbox` key)

| Key                              | Description                                          |
|:---------------------------------|:-----------------------------------------------------|
| `enabled`                        | Enable bash sandboxing (default: false)              |
| `autoAllowBashIfSandboxed`       | Auto-approve bash when sandboxed (default: true)     |
| `excludedCommands`               | Commands that run outside sandbox                    |
| `allowUnsandboxedCommands`       | Allow `dangerouslyDisableSandbox` escape (default: true) |
| `network.allowedDomains`         | Domains for outbound traffic (wildcards supported)   |
| `network.allowUnixSockets`       | Unix socket paths accessible in sandbox              |
| `network.allowLocalBinding`      | Allow binding to localhost (macOS only)              |
| `network.allowManagedDomainsOnly`| Managed-only: ignore user/project domain rules       |

### Managed-Only Settings

These only work in managed settings (cannot be overridden):

| Setting                             | Description                                        |
|:------------------------------------|:---------------------------------------------------|
| `disableBypassPermissionsMode`      | Prevent `--dangerously-skip-permissions`           |
| `allowManagedPermissionRulesOnly`   | Only managed permission rules apply                |
| `allowManagedHooksOnly`             | Only managed and SDK hooks load                    |
| `allowManagedMcpServersOnly`        | Only managed MCP allowlist applies                 |
| `strictKnownMarketplaces`           | Restrict which plugin marketplaces users can add   |
| `blockedMarketplaces`               | Blocklist of marketplace sources                   |
| `sandbox.network.allowManagedDomainsOnly` | Only managed domain rules apply              |
| `allow_remote_sessions`             | Control remote/web session access                  |

### Managed Settings Delivery

| Method                  | Location                                                           |
|:------------------------|:-------------------------------------------------------------------|
| Server-managed          | Claude.ai Admin Settings (Teams/Enterprise)                        |
| macOS MDM               | `com.anthropic.claudecode` managed preferences                     |
| Windows registry        | `HKLM\SOFTWARE\Policies\ClaudeCode`                               |
| File-based (macOS)      | `/Library/Application Support/ClaudeCode/managed-settings.json`    |
| File-based (Linux/WSL)  | `/etc/claude-code/managed-settings.json`                           |
| File-based (Windows)    | `C:\Program Files\ClaudeCode\managed-settings.json`               |

### Verify Settings

Run `/status` to see active settings and their sources. Run `/permissions` to view effective permission rules.

### Tools Available to Claude

| Tool             | Permission Required | Description                        |
|:-----------------|:--------------------|:-----------------------------------|
| Read, Glob, Grep | No                  | File reads, pattern matching       |
| Bash             | Yes                 | Shell commands                     |
| Edit, Write      | Yes                 | File modifications                 |
| WebFetch         | Yes                 | URL content fetching               |
| WebSearch        | Yes                 | Web searches                       |
| Task             | No                  | Subagent for multi-step tasks      |
| Skill            | Yes                 | Execute a skill                    |
| NotebookEdit     | Yes                 | Modify Jupyter notebook cells      |
| LSP              | No                  | Code intelligence via language servers |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Settings](references/claude-code-settings.md) -- complete settings reference: scopes, settings.json options, permissions, sandbox, attribution, environment variables, plugin configuration, tools, bash behavior
- [Configure Permissions](references/claude-code-permissions.md) -- permission system, rule syntax, tool-specific patterns (Bash, Read, Edit, WebFetch, MCP, Task), modes, managed policies, working directories, sandboxing interaction
- [Server-Managed Settings](references/claude-code-server-managed-settings.md) -- centralized configuration via Claude.ai admin console, settings delivery, caching, security approval dialogs, platform availability, audit logging

## Sources

- Claude Code Settings: https://code.claude.com/docs/en/settings.md
- Configure Permissions: https://code.claude.com/docs/en/permissions.md
- Server-Managed Settings: https://code.claude.com/docs/en/server-managed-settings.md
