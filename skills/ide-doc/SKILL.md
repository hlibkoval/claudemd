---
name: ide-doc
description: Complete documentation for Claude Code IDE and desktop integrations -- Desktop app, VS Code extension, JetBrains plugin, Chrome browser extension, and computer use. Covers Desktop app features (visual diff review, live app preview, PR monitoring with auto-fix/auto-merge, parallel sessions with Git worktree isolation, Dispatch integration, scheduled tasks, connectors, computer use with per-app permissions, SSH sessions, remote sessions, enterprise configuration with MDM policies), VS Code extension (installation, prompt box, @-mentions with fuzzy matching, permission modes, plan mode, auto-accept, resume conversations, remote session resume, multiple tabs/windows, terminal mode, plugins UI, Chrome browser automation, commands/shortcuts, URI handler, extension settings, built-in IDE MCP server with getDiagnostics and executeCode tools, checkpoints/rewind, git worktrees), JetBrains plugin (IntelliJ/PyCharm/WebStorm/GoLand/PhpStorm/Android Studio, diff viewing, selection context, diagnostic sharing, remote development, WSL configuration), Chrome integration (browser automation, live debugging, web app testing, form filling, data extraction, session recording as GIF, site permissions, native messaging host), and computer use (macOS screen control, per-app approval tiers, accessibility/screen recording permissions, lock file, safety guardrails). Load when discussing Claude Code Desktop, VS Code extension, JetBrains plugin, Chrome integration, browser automation, computer use, IDE setup, diff view, app preview, PR monitoring, parallel sessions, scheduled tasks, connectors, Dispatch, SSH sessions, or any IDE integration topic.
user-invocable: false
---

# IDE & Desktop Integration Documentation

This skill provides the complete official documentation for using Claude Code across Desktop, VS Code, JetBrains, Chrome, and computer use.

## Quick Reference

### Supported Surfaces

| Surface | Platforms | Install |
|:--------|:----------|:--------|
| Desktop app (Code tab) | macOS, Windows | [Download](https://claude.com/download) |
| VS Code extension | macOS, Windows, Linux | [Install](vscode:extension/anthropic.claude-code) / [Cursor](cursor:extension/anthropic.claude-code) |
| JetBrains plugin | macOS, Windows, Linux | [JetBrains Marketplace](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-) |
| Chrome extension | Chrome, Edge | [Chrome Web Store](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) |
| Computer use (CLI) | macOS only | Enable via `/mcp` in session |

### Desktop App -- Key Features

| Feature | Description |
|:--------|:------------|
| Visual diff review | Side-by-side diffs with inline comments; submit all comments with Cmd/Ctrl+Enter |
| Live app preview | Embedded browser for dev servers; auto-verify screenshots after edits |
| PR monitoring | CI status bar with auto-fix and auto-merge toggles (requires `gh` CLI) |
| Parallel sessions | Automatic Git worktree isolation per session; stored in `.claude/worktrees/` |
| Computer use | macOS only, Pro/Max plans; per-app approval with view-only/click-only/full-control tiers |
| Dispatch | Tasks from Cowork tab spawn Code sessions; push notifications on completion |
| Scheduled tasks | Local or remote; manual/hourly/daily/weekdays/weekly frequency |
| Connectors | Google Calendar, Slack, GitHub, Linear, Notion, and more |
| SSH sessions | Connect to remote machines; Claude Code must be installed on remote host |
| Remote sessions | Run on Anthropic cloud; continue when app is closed; multi-repo support |

### Desktop Permission Modes

| Mode | Settings Key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Asks before every edit/command |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits; asks for commands |
| Plan mode | `plan` | Analyzes and plans without modifying files |
| Auto | `auto` | Background safety checks; Team/Enterprise/API plans; Sonnet 4.6+/Opus 4.6+ |
| Bypass permissions | `bypassPermissions` | No prompts; enable in Settings; sandboxed environments only |

### Desktop -- Preview Server Config (.claude/launch.json)

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (e.g., `npm`, `yarn`) |
| `runtimeArgs` | string[] | Args for the command (e.g., `["run", "dev"]`) |
| `port` | number | Port to listen on (default: 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Extra environment variables |
| `autoPort` | boolean | `true` = find free port; `false` = fail on conflict |
| `autoVerify` | boolean | Auto-screenshot and verify after edits (default: true, set at top level) |

### Desktop -- Scheduled Task Comparison

| Property | Cloud | Desktop (local) | `/loop` |
|:---------|:------|:----------------|:--------|
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Persistent across restarts | Yes | Yes | No |
| Access to local files | No (fresh clone) | Yes | Yes |
| Minimum interval | 1 hour | 1 minute | 1 minute |

### VS Code Extension

**Prerequisites:** VS Code 1.98.0+, Anthropic account (or third-party provider)

| Feature | Details |
|:--------|:--------|
| Open panel | Spark icon in Editor Toolbar, Activity Bar, Status Bar, or Command Palette |
| @-mentions | `@filename` with fuzzy matching; `@file.ts#5-10` for line ranges; `@terminal:name` for terminal output |
| Selection context | Auto-shared; press `Option+K` / `Alt+K` to insert @-mention reference |
| Permission modes | Normal, Plan, Auto-accept; set default via `claudeCode.initialPermissionMode` |
| Multiple sessions | Open in New Tab / Open in New Window from Command Palette |
| Terminal mode | Enable `claudeCode.useTerminal` setting |
| Plugins | Type `/plugins` to manage; install/enable/disable with scoping (user/project/local) |
| Chrome automation | `@browser` prefix in prompts; requires Chrome extension v1.0.36+ |
| Resume remote sessions | Past Conversations > Remote tab (Claude.ai subscription, GitHub repos only) |
| Checkpoints | Hover message for rewind: fork conversation, rewind code, or both |

### VS Code Commands & Shortcuts

| Command | Mac | Windows/Linux |
|:--------|:----|:--------------|
| Focus Input (toggle editor/Claude) | `Cmd+Esc` | `Ctrl+Esc` |
| Open in New Tab | `Cmd+Shift+Esc` | `Ctrl+Shift+Esc` |
| New Conversation | `Cmd+N` | `Ctrl+N` |
| Insert @-Mention Reference | `Option+K` | `Alt+K` |

**URI Handler:** `vscode://anthropic.claude-code/open` with optional `prompt` and `session` query params.

### VS Code Extension Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | CLI-style interface instead of graphical panel |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, `auto`, `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Ctrl/Cmd+Enter to send instead of Enter |
| `allowDangerouslySkipPermissions` | `false` | Show Auto and Bypass in mode selector |
| `claudeProcessWrapper` | -- | Executable path to launch Claude process |

### VS Code Built-in IDE MCP Server

| Tool (hook name) | What it does | Writes? |
|:-----------------|:-------------|:--------|
| `mcp__ide__getDiagnostics` | Returns VS Code Problems panel diagnostics | No |
| `mcp__ide__executeCode` | Runs Python in active Jupyter notebook kernel (requires confirmation) | Yes |

The server binds to `127.0.0.1` on a random port with a per-activation auth token stored in `~/.claude/ide/` (0600 permissions).

### JetBrains Plugin

**Supported IDEs:** IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand

| Feature | Shortcut |
|:--------|:---------|
| Open Claude Code | `Cmd+Esc` (Mac) / `Ctrl+Esc` (Win/Linux) |
| Insert file reference | `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Win/Linux) |
| Diff viewing | Displayed in IDE diff viewer |
| Selection context | Current selection/tab auto-shared |
| Diagnostic sharing | Lint/syntax errors auto-shared |

**Remote Development:** Install plugin in remote host via Settings > Plugin (Host).
**WSL:** May need additional configuration; see troubleshooting guide.

### Chrome Integration (Beta)

**Requirements:** Chrome or Edge, Chrome extension v1.0.36+, Claude Code v2.0.73+, direct Anthropic plan
**Not available** through third-party providers (Bedrock, Vertex, Foundry).

| Capability | Description |
|:-----------|:------------|
| Live debugging | Read console errors/DOM state, fix code |
| Design verification | Build UI, open in browser to verify |
| Web app testing | Form validation, visual regressions, user flows |
| Authenticated apps | Google Docs, Gmail, Notion (uses your login state) |
| Data extraction | Pull structured data from pages |
| Task automation | Form filling, multi-site workflows |
| Session recording | Record interactions as GIF |

**CLI:** `claude --chrome` or `/chrome` in-session. Enable by default via `/chrome` > "Enabled by default".
**VS Code:** `@browser <instruction>` in prompt box; no flag needed.

**Site permissions** inherited from Chrome extension settings.

### Computer Use (macOS Only)

**Requirements:** Pro or Max plan, Claude Code v2.1.85+, interactive session, macOS
**Enable:** `/mcp` > select `computer-use` > Enable (persists per project)
**macOS permissions:** Accessibility + Screen Recording

| App Tier | What Claude can do | Applies to |
|:---------|:-------------------|:-----------|
| View only | See app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, no typing | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

**Safety guardrails:**
- Per-app approval (session-scoped; 30 min in Dispatch sessions)
- Terminal excluded from screenshots
- Global `Esc` key abort
- Machine-wide lock (one session at a time)
- Sentinel warnings for apps with broad access (shell, filesystem, system settings)

### Desktop Enterprise Configuration

| Setting | Description |
|:--------|:------------|
| Admin console: Code in desktop | Enable/disable Code tab for organization |
| Admin console: Disable Bypass | Prevent bypass permissions mode |
| `permissions.disableBypassPermissionsMode` | `"disable"` in managed settings |
| `disableAutoMode` | `"disable"` to remove Auto from mode selector |
| `autoMode` | Customize auto mode classifier rules |
| MDM (macOS) | `com.anthropic.Claude` preference domain |
| Group Policy (Windows) | `SOFTWARE\Policies\Claude` registry |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- Full Desktop app reference: permission modes, parallel sessions, diff view, preview servers, computer use, scheduled tasks, connectors, enterprise config, SSH/remote sessions, CLI comparison
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) -- Desktop installation and first-session quickstart
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) -- VS Code extension: installation, prompt box, @-mentions, plugins, Chrome automation, commands, settings, MCP server, checkpoints, git integration
- [JetBrains IDEs](references/claude-code-jetbrains.md) -- JetBrains plugin: installation, features, configuration, remote development, WSL, troubleshooting
- [Use Claude Code with Chrome](references/claude-code-chrome.md) -- Chrome browser integration: setup, capabilities, example workflows, troubleshooting
- [Computer use from the CLI](references/claude-code-computer-use.md) -- Computer use: enable, per-app approval, safety, example workflows, Desktop vs CLI differences

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Computer use from the CLI: https://code.claude.com/docs/en/computer-use.md
