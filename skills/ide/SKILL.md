---
name: IDE Integrations
description: Reference documentation for Claude Code IDE integrations — VS Code extension, JetBrains plugin, Desktop app (Code tab), and Chrome browser extension. Use when configuring IDE settings, keyboard shortcuts, diff review, permission modes, session management, browser automation, or connecting Claude Code to an editor.
user-invocable: false
---

# IDE Integrations Documentation

This skill covers how Claude Code integrates with VS Code, JetBrains IDEs, the Desktop app, and Chrome.

## VS Code Extension

**Prerequisites**: VS Code 1.98.0+ (also works with Cursor). Install from Extensions marketplace: search "Claude Code".

### Key Shortcuts

| Shortcut                  | Platform       | Action                                      |
|:--------------------------|:---------------|:--------------------------------------------|
| `Cmd+Esc` / `Ctrl+Esc`   | Mac / Win+Lin  | Toggle focus between editor and Claude       |
| `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | Mac / Win+Lin | Open new conversation tab        |
| `Option+K` / `Alt+K`     | Mac / Win+Lin  | Insert @-mention for current selection       |
| `Cmd+N` / `Ctrl+N`       | Mac / Win+Lin  | New conversation (Claude must be focused)    |
| `Shift+Enter`            | All            | Multi-line input without sending             |

### Prompt Box Features

- **@-mentions**: type `@filename` for fuzzy-matched file references; `@folder/` for directories; `@file.ts#5-10` for line ranges
- **@terminal:name**: reference terminal output by terminal title
- **@browser**: trigger Chrome browser actions (requires Chrome extension)
- **Permission modes**: `default`, `plan`, `acceptEdits`, `bypassPermissions` -- set via `claudeCode.initialPermissionMode`
- **`/` command menu**: attach files, switch models, toggle extended thinking, access MCP, hooks, plugins, memory
- **Past conversations**: dropdown at top of panel; Local and Remote tabs

### Extension Settings

| Setting                           | Default   | Description                                         |
|:----------------------------------|:----------|:----------------------------------------------------|
| `selectedModel`                   | `default` | Model for new conversations                         |
| `useTerminal`                     | `false`   | Launch in terminal mode instead of graphical panel   |
| `initialPermissionMode`           | `default` | `default`, `plan`, `acceptEdits`, `bypassPermissions` |
| `autosave`                        | `true`    | Auto-save files before Claude reads/writes them      |
| `useCtrlEnterToSend`              | `false`   | Require Ctrl/Cmd+Enter to send                       |
| `respectGitIgnore`                | `true`    | Exclude .gitignore patterns from file searches       |
| `allowDangerouslySkipPermissions` | `false`   | Bypass all permission prompts                        |

### Extension vs CLI

| Feature             | CLI        | VS Code Extension                        |
|:--------------------|:-----------|:-----------------------------------------|
| Commands and skills | All        | Subset (type `/` to see available)       |
| MCP server config   | Yes        | No (configure via CLI, use in extension) |
| Checkpoints         | Yes        | Yes                                      |
| `!` bash shortcut   | Yes        | No                                       |
| Tab completion      | Yes        | No                                       |

### Checkpoints (Rewind)

Hover over any message to reveal the rewind button with three options:
- **Fork conversation from here** -- new branch, keep code changes
- **Rewind code to here** -- revert files, keep conversation history
- **Fork conversation and rewind code** -- new branch and revert files

## JetBrains Plugin

Supports IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand.

### Features

- **Quick launch**: `Cmd+Esc` / `Ctrl+Esc`
- **File references**: `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Win+Lin) to insert @File#L1-99
- **Diff viewing**: changes displayed in IDE diff viewer
- **Selection context**: current selection/tab auto-shared with Claude
- **Diagnostic sharing**: lint/syntax errors auto-shared

### Installation & Usage

- Install from [JetBrains Marketplace](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-)
- From IDE terminal: run `claude` -- all integration features active
- From external terminal: run `claude` then `/ide` to connect

### Plugin Settings (Settings > Tools > Claude Code)

- **Claude command**: custom path (e.g., `claude`, `/usr/local/bin/claude`, `npx @anthropic/claude`)
- **WSL**: set `wsl -d Ubuntu -- bash -lic "claude"` as command
- **ESC key**: if ESC doesn't interrupt, uncheck "Move focus to the editor with Escape" in Settings > Tools > Terminal
- **Remote Development**: install plugin on remote host via Settings > Plugin (Host)

## Desktop App (Code Tab)

macOS and Windows only. Requires Pro, Max, Teams, or Enterprise subscription. No third-party providers, no Linux, no agent teams/`delegate` mode, no inline code suggestions.

### Session Configuration

Before sending a message, configure:
1. **Environment**: Local, Remote (cloud), or SSH
2. **Project folder**: select directory or repository
3. **Model**: locked once session starts
4. **Permission mode**: Ask, Code, Plan, or Act

### Permission Modes

| Mode     | Key                 | Behavior                                           |
|:---------|:--------------------|:---------------------------------------------------|
| **Ask**  | `default`           | Approval required for each edit and command         |
| **Code** | `acceptEdits`       | Auto-accept file edits, ask before terminal commands|
| **Plan** | `plan`              | Analyze and plan only, no file/command changes      |
| **Act**  | `bypassPermissions` | No prompts (sandboxed environments only)            |

### Session Management

- **Parallel sessions**: each gets its own Git worktree (stored in `<project-root>/.claude/worktrees/`)
- **Remote sessions**: run on Anthropic cloud, continue after closing app; support multiple repos
- **SSH sessions**: connect to remote machines; support permission modes, connectors, plugins, MCP
- **Continue in**: move sessions to web or IDE via the VS Code icon in session toolbar
- **Diff review**: click the `+N -N` indicator to open diff viewer; click any line to comment

### Extending Claude Code in Desktop

- **Connectors**: click `+` > Connectors for GitHub, Slack, Linear, Google Calendar, Notion, etc.
- **Plugins**: click `+` > Plugins to browse/install from marketplaces
- **Skills**: type `/` or click `+` > Slash commands

### CLI Flag Equivalents

| CLI Flag                          | Desktop Equivalent                              |
|:----------------------------------|:------------------------------------------------|
| `--model sonnet`                  | Model dropdown before starting session          |
| `--resume`, `--continue`          | Click session in sidebar                        |
| `--permission-mode`               | Mode selector next to send button               |
| `--dangerously-skip-permissions`  | Settings > Claude Code > "Allow bypass permissions mode" |
| `--add-dir`                       | `+` button in remote sessions                   |

## Chrome Integration (Beta)

### Prerequisites

- Google Chrome or Microsoft Edge
- [Claude in Chrome extension](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) v1.0.36+
- Claude Code v2.0.73+; direct Anthropic plan required

### Usage

- **CLI**: `claude --chrome` or `/chrome` within a session
- **VS Code**: type `@browser` followed by instructions in prompt box
- **Enable by default**: run `/chrome` and select "Enabled by default"

### Capabilities

Live debugging (console errors, DOM state), web app testing, authenticated web apps (Google Docs, Gmail, Notion -- uses your login state), data extraction, form filling, task automation, session recording as GIF.

### Troubleshooting

| Error                                | Fix                                                             |
|:-------------------------------------|:----------------------------------------------------------------|
| "Browser extension is not connected" | Restart Chrome and Claude Code, run `/chrome` to reconnect      |
| "Extension not detected"             | Install/enable extension in `chrome://extensions`               |
| "No tab available"                   | Ask Claude to create a new tab and retry                        |
| "Receiving end does not exist"       | Run `/chrome` > "Reconnect extension" (service worker went idle)|

## Full Documentation

For the complete official documentation, see the reference files:

- [VS Code Extension](references/claude-code-vs-code.md) -- installation, settings, shortcuts, plugins, git workflows, third-party providers
- [JetBrains Plugin](references/claude-code-jetbrains.md) -- installation, configuration, remote development, WSL
- [Desktop App](references/claude-code-desktop.md) -- sessions, permission modes, diff review, connectors, SSH, enterprise config
- [Desktop Quickstart](references/claude-code-desktop-quickstart.md) -- install guide and first session walkthrough
- [Chrome Integration](references/claude-code-chrome.md) -- browser automation, example workflows, troubleshooting

## Sources

- VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains: https://code.claude.com/docs/en/jetbrains.md
- Desktop: https://code.claude.com/docs/en/desktop.md
- Desktop Quickstart: https://code.claude.com/docs/en/desktop-quickstart.md
- Chrome: https://code.claude.com/docs/en/chrome.md
