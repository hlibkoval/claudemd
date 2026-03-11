---
name: ide-doc
description: Complete documentation for Claude Code IDE integrations and the desktop app -- Desktop app (Code tab, visual diff review, live app preview, PR monitoring with auto-fix/auto-merge, parallel sessions with Git worktree isolation, scheduled tasks, connectors, SSH sessions, remote/cloud sessions, enterprise configuration, permission modes, launch.json preview config, device management), VS Code extension (installation, prompt box, @-mentions with line ranges, permission modes, plan review, checkpoints/rewind, multiple conversations, terminal mode, plugin management, Chrome browser automation, commands/shortcuts, extension settings, third-party providers, MCP server management, git worktrees, CLI interop), JetBrains plugin (IntelliJ/PyCharm/WebStorm/GoLand/PhpStorm/Android Studio, diff viewing, selection context, file reference shortcuts, diagnostic sharing, ESC key config, remote development, WSL configuration), and Chrome browser extension (live debugging, design verification, web app testing, authenticated web apps, data extraction, task automation, GIF recording, site permissions, --chrome flag). Load when discussing Claude Code in VS Code, JetBrains, Desktop app, Chrome browser integration, IDE setup, extension installation, diff view, preview servers, session management, worktrees in Desktop, scheduled tasks, connectors, or any IDE-specific configuration.
user-invocable: false
---

# IDE Integrations & Desktop App Documentation

This skill provides the complete official documentation for using Claude Code across different environments: the Desktop app, VS Code extension, JetBrains plugin, and Chrome browser integration.

## Quick Reference

### Platform Overview

| Platform | Install method | Key features |
|:---------|:---------------|:-------------|
| **Desktop app** | Download from claude.ai | Visual diff review, live preview, PR monitoring, parallel sessions, scheduled tasks, connectors, SSH/remote |
| **VS Code** | Extension marketplace | Inline diffs, @-mentions with line ranges, plan review, checkpoints, multiple tabs, Chrome automation |
| **JetBrains** | Plugin marketplace | Diff viewing, selection context, file references, diagnostic sharing |
| **Chrome** | Chrome Web Store extension | Browser automation, live debugging, form filling, data extraction, GIF recording |

### Desktop App

The Code tab in the Claude Desktop app provides a graphical interface for Claude Code with capabilities beyond the CLI.

#### Permission Modes (Desktop)

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| **Ask permissions** | `default` | Asks before edits/commands; shows diffs for accept/reject |
| **Auto accept edits** | `acceptEdits` | Auto-accepts file edits; still asks for terminal commands |
| **Plan mode** | `plan` | Analyzes and plans without modifying files or running commands |
| **Bypass permissions** | `bypassPermissions` | No prompts (enable in Settings; containers/VMs only) |

The `dontAsk` mode is CLI-only.

#### Desktop-Exclusive Features

| Feature | Description |
|:--------|:------------|
| **Visual diff review** | File-by-file diff viewer with line-level commenting (Cmd/Ctrl+Enter to submit) |
| **Review code** | Click "Review code" in diff toolbar for Claude to self-review changes |
| **Live app preview** | Embedded browser for dev servers; auto-verify checks changes after each edit |
| **PR monitoring** | CI status bar with auto-fix (fixes failing checks) and auto-merge (squash merge on pass) |
| **Parallel sessions** | Each session gets its own Git worktree in `<project>/.claude/worktrees/` |
| **Scheduled tasks** | Recurring sessions (manual/hourly/daily/weekdays/weekly) with catch-up on missed runs |
| **Connectors** | GUI for adding GitHub, Slack, Linear, Notion, Calendar integrations (MCP under the hood) |
| **SSH sessions** | Run Claude on remote machines via SSH (user@host or ~/.ssh/config entry) |
| **Remote sessions** | Run on Anthropic cloud; continues even if app is closed; supports multi-repo |
| **Continue in** | Move session to web or open in IDE |

#### Preview Server Config (`.claude/launch.json`)

```json
{
  "version": "0.0.1",
  "autoVerify": true,
  "configurations": [
    {
      "name": "my-app",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"],
      "port": 3000
    }
  ]
}
```

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments for the command |
| `port` | number | Server port (default: 3000) |
| `cwd` | string | Working directory relative to project root; `${workspaceFolder}` for explicit root |
| `env` | object | Additional env vars (don't put secrets here) |
| `autoPort` | boolean | `true` = find free port; `false` = fail on conflict; unset = ask |
| `program` | string | Script to run with `node` directly (alternative to runtimeExecutable) |
| `args` | string[] | Arguments for `program` |

#### Scheduled Tasks

| Frequency | Behavior |
|:----------|:---------|
| Manual | Only runs on "Run now" click |
| Hourly | Every hour (up to 10 min stagger offset) |
| Daily | At chosen time (default 9:00 AM local) |
| Weekdays | Daily but skips Saturday/Sunday |
| Weekly | At chosen day and time |

Task files live at `~/.claude/scheduled-tasks/<task-name>/SKILL.md`. Tasks only fire while the app is open and computer is awake. Missed runs get one catch-up run (most recent missed time within 7 days).

#### Desktop CLI Flag Equivalents

| CLI flag | Desktop equivalent |
|:---------|:-------------------|
| `--model sonnet` | Model dropdown next to send button |
| `--resume` / `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (enable in Settings) |
| `--add-dir` | **+** button in remote sessions for multi-repo |

#### Desktop Limitations

- No third-party providers (Bedrock/Vertex/Foundry) -- Desktop connects to Anthropic API directly
- No Linux support -- macOS and Windows only
- No agent teams -- use CLI or Agent SDK
- No inline code suggestions / autocomplete
- Cowork tab requires Apple Silicon on macOS

### VS Code Extension

#### Requirements

- VS Code 1.98.0+
- Anthropic account (or third-party provider config)

Install: search "Claude Code" in Extensions view, or `vscode:extension/anthropic.claude-code` / `cursor:extension/anthropic.claude-code`.

#### Key Shortcuts

| Command | Shortcut | Description |
|:--------|:---------|:------------|
| Focus Input | `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| Open in New Tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | New conversation as editor tab |
| New Conversation | `Cmd+N` / `Ctrl+N` | Start new conversation (Claude focused) |
| Insert @-Mention | `Option+K` / `Alt+K` | Insert file ref with line numbers (editor focused) |

#### Prompt Box Features

- **Permission modes**: click mode indicator -- normal, Plan, auto-accept
- **Command menu**: `/` to open -- attach files, switch models, toggle thinking, `/usage`
- **@-mentions**: `@filename` with fuzzy match; `@src/components/` for folders (trailing slash)
- **Selection context**: highlighted code auto-shared; `Option+K`/`Alt+K` inserts `@file.ts#5-10`
- **Multi-line input**: `Shift+Enter`
- **Terminal references**: `@terminal:name` to include terminal output
- **Remote sessions**: resume claude.ai sessions via Past Conversations > Remote tab

#### Extension Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | Launch in terminal mode instead of panel |
| `initialPermissionMode` | `default` | Default: `default`, `plan`, `acceptEdits`, `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Ctrl/Cmd+Enter to send |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party providers) |
| `allowDangerouslySkipPermissions` | `false` | Bypass all permission prompts |

#### Checkpoints (Rewind)

Hover over any message for the rewind button. Three options:
- **Fork conversation from here**: new branch, keep code changes
- **Rewind code to here**: revert files, keep conversation history
- **Fork conversation and rewind code**: new branch + revert files

#### Plugin Management

Type `/plugins` to open plugin dialog. Install/toggle/search plugins. Choose scope: Install for you (user), Install for this project (project), Install locally (local).

#### Chrome Automation in VS Code

Requires Claude in Chrome extension v1.0.36+. Use `@browser` in prompt box:
```
@browser go to localhost:3000 and check the console for errors
```

#### Third-Party Providers in VS Code

1. Enable `disableLoginPrompt` in VS Code settings
2. Configure provider in `~/.claude/settings.json` (Bedrock/Vertex/Foundry)

#### CLI in VS Code

- Run `claude` in integrated terminal for full CLI access
- Use `/ide` from external terminal to connect to VS Code
- Share conversation history: `claude --resume` in terminal picks up extension sessions
- VS Code extension includes the CLI but for terminal use, install CLI separately

### JetBrains Plugin

#### Supported IDEs

IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand

#### Features

| Feature | Shortcut |
|:--------|:---------|
| Quick launch | `Cmd+Esc` / `Ctrl+Esc` |
| Insert file reference | `Cmd+Option+K` / `Alt+Ctrl+K` |
| Diff viewing | Automatic in IDE diff viewer |
| Selection context | Auto-shared from current selection/tab |
| Diagnostic sharing | IDE errors (lint, syntax) auto-shared |

Install from [JetBrains Marketplace](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-). Restart IDE after install.

#### Plugin Settings (Settings > Tools > Claude Code)

- **Claude command**: custom command path (e.g., `claude`, `/usr/local/bin/claude`, `npx @anthropic/claude`)
- **Enable Option+Enter for multi-line** (macOS): Option+Enter inserts newlines
- **Enable automatic updates**: auto-check and install plugin updates

#### Special Configurations

- **Remote Development**: install plugin on remote host via Settings > Plugin (Host)
- **WSL**: may need terminal config, networking mode, and firewall adjustments; set Claude command to `wsl -d Ubuntu -- bash -lic "claude"`
- **ESC key**: if ESC doesn't interrupt Claude, go to Settings > Tools > Terminal and uncheck "Move focus to the editor with Escape"

### Chrome Browser Integration (Beta)

#### Prerequisites

- Google Chrome or Microsoft Edge
- Claude in Chrome extension v1.0.36+
- Claude Code v2.0.73+
- Direct Anthropic plan (not available via Bedrock/Vertex/Foundry)

#### Getting Started

```bash
claude --chrome        # start with Chrome enabled
```

Or run `/chrome` inside an existing session. Enable by default via `/chrome` > "Enabled by default".

#### Capabilities

| Capability | Description |
|:-----------|:------------|
| Live debugging | Read console errors/DOM state, then fix code |
| Design verification | Build UI, open in browser to verify against mockup |
| Web app testing | Test forms, check regressions, verify user flows |
| Authenticated apps | Interact with Google Docs, Gmail, Notion using existing logins |
| Data extraction | Pull structured data from pages, save as CSV/JSON |
| Task automation | Automate data entry, form filling, multi-site workflows |
| GIF recording | Record browser interactions as shareable GIFs |

#### Site Permissions

Inherited from Chrome extension settings. Manage in extension settings to control which sites Claude can browse, click, and type on.

#### Troubleshooting Chrome

| Error | Fix |
|:------|:----|
| "Extension not detected" | Check chrome://extensions; restart Chrome and Claude Code; run `/chrome` > Reconnect |
| "Browser not responding" | Dismiss any JS dialogs blocking the page; create new tab; restart extension |
| Connection drops | Run `/chrome` > "Reconnect extension" (service worker went idle) |
| Named pipe conflicts (Windows) | Restart Claude Code; close other Chrome sessions |

Native messaging host config paths -- Chrome: `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/` (macOS), `~/.config/google-chrome/NativeMessagingHosts/` (Linux). Edge: replace `Google/Chrome` with `Microsoft Edge` or `microsoft-edge`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- Desktop app full reference: permission modes, diff review, preview servers, PR monitoring, parallel sessions, scheduled tasks, connectors, SSH/remote sessions, enterprise config, CLI comparison, troubleshooting
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) -- Desktop quickstart: installation (macOS/Windows), Code/Chat/Cowork tabs, first session walkthrough, permission modes, skills, preview, PR monitoring, scheduled tasks
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) -- VS Code extension: installation, prompt box, @-mentions, permission modes, checkpoints, plugin management, Chrome automation, commands/shortcuts, settings, third-party providers, MCP servers, git workflows, troubleshooting
- [JetBrains IDEs](references/claude-code-jetbrains.md) -- JetBrains plugin: supported IDEs, features, installation, configuration, remote development, WSL setup, troubleshooting
- [Use Claude Code with Chrome](references/claude-code-chrome.md) -- Chrome integration: capabilities, prerequisites, CLI/VS Code setup, example workflows, site permissions, troubleshooting

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
