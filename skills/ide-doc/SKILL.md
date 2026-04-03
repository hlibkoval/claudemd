---
name: ide-doc
description: Complete documentation for Claude Code IDE and desktop integrations -- Desktop app (macOS/Windows), VS Code extension, JetBrains plugin, Chrome browser extension, and computer use. Covers installation, configuration, permission modes, diff review, app preview, PR monitoring, parallel sessions with worktree isolation, scheduled tasks, connectors, SSH/remote sessions, Dispatch, enterprise configuration, keyboard shortcuts, VS Code extension settings, JetBrains plugin settings, Chrome browser automation, computer use (screen control, app permissions, safety), and troubleshooting. Load when discussing Claude Code Desktop, VS Code extension, JetBrains plugin, Chrome integration, computer use, IDE integration, desktop app, permission modes in Desktop, diff view, app preview, PR monitoring, parallel sessions, worktrees, scheduled tasks, connectors, SSH sessions, remote sessions, Dispatch, enterprise desktop config, VS Code shortcuts, JetBrains setup, browser automation, screen control, or any IDE/desktop-related topic for Claude Code.
user-invocable: false
---

# IDE & Desktop Integration Documentation

This skill provides the complete official documentation for Claude Code IDE integrations (Desktop app, VS Code, JetBrains, Chrome, and computer use).

## Quick Reference

### Supported Surfaces

| Surface | Platforms | Install |
|:--------|:----------|:--------|
| Desktop app (Code tab) | macOS, Windows | [claude.com/download](https://claude.com/download) |
| VS Code extension | macOS, Windows, Linux | Extension ID: `anthropic.claude-code` |
| JetBrains plugin | macOS, Windows, Linux | [JetBrains Marketplace](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-) |
| Chrome extension | Chrome, Edge | [Chrome Web Store](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) |
| Computer use (CLI) | macOS only | Built-in MCP server, enable via `/mcp` |
| Computer use (Desktop) | macOS, Windows | Settings > General > Computer use toggle |

### Desktop App Tabs

| Tab | Purpose |
|:----|:--------|
| **Chat** | General conversation, no file access |
| **Cowork** | Autonomous background agent in cloud VM (requires Apple Silicon on macOS) |
| **Code** | Interactive coding assistant with local file access |

### Permission Modes

| Mode | Settings Key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Asks before edits and commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits, asks for commands |
| Plan mode | `plan` | Analyzes and plans without modifying files |
| Auto | `auto` | Background safety checks, reduces prompts (Team/Enterprise/API, Sonnet 4.6/Opus 4.6) |
| Bypass permissions | `bypassPermissions` | No prompts, use only in sandboxes |
| dontAsk | `dontAsk` | CLI only |

### Desktop App Features

| Feature | Description |
|:--------|:-----------|
| Diff view | Visual side-by-side review with inline comments; submit with Cmd/Ctrl+Enter |
| App preview | Embedded browser for dev servers; config in `.claude/launch.json` |
| Auto-verify | Screenshots and checks after edits (on by default) |
| PR monitoring | CI status bar with auto-fix and auto-merge toggles (requires `gh` CLI) |
| Parallel sessions | Sidebar tabs with automatic Git worktree isolation |
| Scheduled tasks | Recurring runs (manual/hourly/daily/weekdays/weekly); local or remote |
| Connectors | Google Calendar, Slack, GitHub, Linear, Notion, etc. |
| Dispatch | Tasks from phone via Cowork tab, appear as Code sessions |
| Computer use | Open apps, control screen (Pro/Max plans) |

### Desktop Environments

| Environment | Description |
|:------------|:-----------|
| Local | Direct access to local files |
| Remote | Anthropic cloud, persists when app closed, supports multiple repos |
| SSH | Connect to remote machines; Claude Code must be installed on remote |

### Preview Server Configuration (`.claude/launch.json`)

| Field | Type | Description |
|:------|:-----|:-----------|
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments for executable |
| `port` | number | Server port (default: 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables |
| `autoPort` | boolean | `true` = auto-find free port; `false` = fail on conflict |
| `program` | string | Script to run with `node` directly |
| `args` | string[] | Arguments for `program` |
| `autoVerify` | boolean | Auto-verify changes after edits (top-level field, default: true) |

### Scheduled Task Types

| Type | Runs On | Requires Machine On | Access |
|:-----|:--------|:--------------------|:-------|
| Local (Desktop) | Your machine | Yes | Local files and tools |
| Remote (Cloud) | Anthropic cloud | No | Fresh repo clone |
| `/loop` (CLI) | Your machine | Yes (session-scoped) | Inherits from session |

### VS Code Extension

#### Prerequisites
- VS Code 1.98.0 or higher
- Also works with Cursor

#### Key Shortcuts

| Command | Mac | Windows/Linux |
|:--------|:----|:-------------|
| Focus Input (toggle editor/Claude) | `Cmd+Esc` | `Ctrl+Esc` |
| Open in New Tab | `Cmd+Shift+Esc` | `Ctrl+Shift+Esc` |
| New Conversation | `Cmd+N` | `Ctrl+N` |
| Insert @-Mention Reference | `Option+K` | `Alt+K` |

#### Extension Settings

| Setting | Default | Description |
|:--------|:--------|:-----------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | CLI-style interface |
| `initialPermissionMode` | `default` | Startup mode: `default`, `plan`, `acceptEdits`, `auto`, `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` or `panel` |
| `autosave` | `true` | Auto-save before reads/writes |
| `useCtrlEnterToSend` | `false` | Ctrl/Cmd+Enter to send |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns |
| `disableLoginPrompt` | `false` | Skip auth prompts (third-party providers) |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto and Bypass to mode selector |
| `claudeProcessWrapper` | - | Executable path for Claude process |

#### Built-in IDE MCP Server

The extension runs a local MCP server (`ide`) on `127.0.0.1` with random port and per-activation auth token.

| Tool | Purpose | Writes |
|:-----|:--------|:-------|
| `mcp__ide__getDiagnostics` | Returns VS Code Problems panel diagnostics | No |
| `mcp__ide__executeCode` | Runs Python in active Jupyter notebook kernel (requires confirm) | Yes |

#### URI Handler

`vscode://anthropic.claude-code/open` with optional `prompt` and `session` query parameters.

### JetBrains Plugin

#### Supported IDEs
IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand

#### Key Shortcuts

| Action | Mac | Windows/Linux |
|:-------|:----|:-------------|
| Open Claude Code | `Cmd+Esc` | `Ctrl+Esc` |
| Insert file reference | `Cmd+Option+K` | `Alt+Ctrl+K` |

#### Plugin Settings (Settings > Tools > Claude Code)
- **Claude command**: custom path (e.g., `claude`, `/usr/local/bin/claude`, `npx @anthropic/claude`)
- **Enable Option+Enter for multi-line**: macOS only
- **Enable automatic updates**: auto-install plugin updates
- WSL: set `wsl -d Ubuntu -- bash -lic "claude"` as command
- Remote Development: install plugin on remote host via Settings > Plugin (Host)

### Chrome Integration (Beta)

#### Prerequisites
- Google Chrome or Microsoft Edge
- Claude in Chrome extension v1.0.36+
- Claude Code v2.0.73+
- Direct Anthropic plan (not available through Bedrock/Vertex/Foundry)

#### Capabilities
- Live debugging (console errors, DOM state)
- Design verification, web app testing
- Authenticated web apps (Google Docs, Gmail, Notion, etc.)
- Data extraction, form filling, task automation
- Session recording as GIFs

#### CLI Usage
```
claude --chrome
```
Or run `/chrome` inside a session. Enable by default via `/chrome` > "Enabled by default".

In VS Code, use `@browser` in prompt box (no flag needed).

#### Troubleshooting

| Error | Fix |
|:------|:----|
| "Browser extension is not connected" | Restart Chrome and Claude Code, run `/chrome` to reconnect |
| "Extension not detected" | Install/enable in `chrome://extensions` |
| "No tab available" | Ask Claude to create a new tab |
| "Receiving end does not exist" | Run `/chrome` > "Reconnect extension" |

### Computer Use

#### Capabilities
- Build and validate native apps (Swift, macOS, iOS Simulator)
- End-to-end UI testing without test harness
- Debug visual/layout issues with screenshots
- Drive GUI-only tools

#### Tool Priority Order
1. MCP server / Connector (if available)
2. Bash (shell commands)
3. Chrome extension (browser work)
4. Computer use (everything else)

#### App Permission Tiers (Desktop)

| Tier | Allowed Actions | Applies To |
|:-----|:---------------|:-----------|
| View only | See in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, no typing | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

#### Safety Guardrails
- Per-app approval per session
- Sentinel warnings for shell/filesystem/system apps
- Terminal excluded from screenshots
- Global `Esc` key aborts immediately
- Lock file prevents concurrent sessions

#### CLI vs Desktop Computer Use

| Feature | Desktop | CLI |
|:--------|:--------|:----|
| Platforms | macOS, Windows | macOS only |
| Enable | Settings > General toggle | `/mcp` > enable `computer-use` |
| Plan requirement | Pro or Max | Pro or Max |
| Denied apps list | Configurable in Settings | Not available |

### Enterprise Configuration (Desktop)

| Control | Location |
|:--------|:---------|
| Code in desktop/web | Admin console |
| Remote Control | Admin console |
| Disable Bypass permissions | Admin console |
| `permissions.disableBypassPermissionsMode` | Managed settings |
| `disableAutoMode` | Managed settings |
| `autoMode` | User/local/managed settings |
| MDM (macOS) | `com.anthropic.Claude` preference domain |
| MDM (Windows) | `SOFTWARE\Policies\Claude` registry |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- Full Desktop app reference: permission modes, diff view, app preview, PR monitoring, parallel sessions, computer use, scheduled tasks, connectors, SSH/remote sessions, Dispatch, enterprise config, CLI comparison, troubleshooting
- [Get Started with the Desktop App](references/claude-code-desktop-quickstart.md) -- Desktop quickstart: installation, first session, Code tab walkthrough
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) -- VS Code extension: installation, prompt box, @-mentions, plan review, shortcuts, settings, plugins, Chrome integration, MCP, checkpoints, troubleshooting
- [JetBrains IDEs](references/claude-code-jetbrains.md) -- JetBrains plugin: supported IDEs, installation, configuration, remote development, WSL, troubleshooting
- [Use Claude Code with Chrome](references/claude-code-chrome.md) -- Chrome browser integration: setup, capabilities, example workflows, site permissions, troubleshooting
- [Let Claude Use Your Computer from the CLI](references/claude-code-computer-use.md) -- Computer use in CLI: enabling, macOS permissions, per-app approval, safety, example workflows, Desktop comparison

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get Started with the Desktop App: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude Use Your Computer from the CLI: https://code.claude.com/docs/en/computer-use.md
