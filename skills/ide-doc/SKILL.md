---
name: ide-doc
description: Complete documentation for Claude Code IDE and desktop integrations -- Desktop app (macOS/Windows), VS Code extension, JetBrains plugin, Chrome browser extension, and computer use. Covers Desktop features (diff view, app preview, PR monitoring, parallel sessions with worktree isolation, Dispatch, computer use, connectors, SSH/remote sessions, enterprise configuration, permission modes, launch.json), VS Code extension (installation, prompt box, @-mentions, permission modes, multiple conversations, terminal mode, plugin management, commands/shortcuts, extension settings, built-in IDE MCP server, checkpoints, git worktrees, third-party providers, URI handler), JetBrains plugin (IntelliJ, PyCharm, WebStorm, GoLand, PhpStorm, Android Studio, diff viewing, selection context, file references, ESC key config, remote development, WSL), Chrome integration (browser automation, console debugging, form filling, data extraction, GIF recording, site permissions, native messaging host), and computer use (macOS CLI, per-app approval, app permission tiers, screen control, safety guardrails). Load when discussing Claude Code Desktop app, VS Code extension, JetBrains plugin, Chrome browser automation, computer use, IDE integration, diff view, app preview, PR monitoring, parallel sessions, worktrees, connectors, SSH sessions, remote sessions, Dispatch, launch.json, VS Code settings, IDE MCP server, @browser, or any IDE/desktop-related topic for Claude Code.
user-invocable: false
---

# IDE & Desktop Integrations Documentation

This skill provides the complete official documentation for Claude Code's IDE and desktop integrations: the Desktop app, VS Code extension, JetBrains plugin, Chrome browser extension, and computer use.

## Quick Reference

### Surfaces Overview

| Surface | Platforms | Key features |
|:--------|:----------|:-------------|
| **Desktop app** | macOS, Windows | Diff view, app preview, PR monitoring, parallel sessions, computer use, Dispatch, connectors, SSH/remote |
| **VS Code extension** | macOS, Windows, Linux | Inline diffs, @-mentions, plan review, multiple tabs, plugin management, built-in IDE MCP server |
| **JetBrains plugin** | IntelliJ, PyCharm, WebStorm, GoLand, PhpStorm, Android Studio | Diff viewing, selection context, file references, diagnostic sharing |
| **Chrome extension** | Chrome, Edge | Browser automation, console reading, form filling, data extraction, GIF recording |
| **Computer use** | macOS (CLI), macOS + Windows (Desktop) | Native app control, screen interaction, per-app approval, GUI automation |

### Desktop App

#### Permission Modes

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Asks before editing files or running commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits, asks before terminal commands |
| Plan mode | `plan` | Analyzes and plans without modifying files |
| Auto | `auto` | Background safety checks, reduces prompts (Team/Enterprise/API, Sonnet 4.6+/Opus 4.6) |
| Bypass permissions | `bypassPermissions` | No prompts; enable in Settings; sandboxed environments only |

#### Desktop Tabs

| Tab | Purpose |
|:----|:--------|
| **Chat** | General conversation, no file access (like claude.ai) |
| **Cowork** | Autonomous background agent on a cloud VM |
| **Code** | Interactive coding assistant with local file access |

#### Environment Types

| Environment | Description |
|:------------|:-----------|
| Local | Runs on your machine with direct file access |
| Remote | Runs on Anthropic cloud infrastructure; continues if you close the app |
| SSH | Runs on a remote machine over SSH (your servers, cloud VMs, dev containers) |

#### Preview Server Configuration (`.claude/launch.json`)

| Field | Type | Description |
|:------|:-----|:-----------|
| `name` | string | Unique identifier for the server |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments for `runtimeExecutable` |
| `port` | number | Server port (default 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables |
| `autoPort` | boolean | `true` = find free port; `false` = fail if taken |
| `program` | string | Script to run with `node` directly |
| `args` | string[] | Arguments for `program` |
| `autoVerify` | boolean | Auto-verify changes after edits (default true, set at root level) |

#### Computer Use App Permission Tiers (Desktop)

| Tier | What Claude can do | Applies to |
|:-----|:-------------------|:-----------|
| View only | See app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, no typing | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

#### CLI Flag Equivalents in Desktop

| CLI | Desktop equivalent |
|:----|:-------------------|
| `--model sonnet` | Model dropdown next to send button |
| `--resume`, `--continue` | Click a session in the sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode in Settings |
| `--add-dir` | **+** button in remote sessions |

#### Enterprise Configuration Keys

| Key | Description |
|:----|:-----------|
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to prevent bypass mode |
| `disableAutoMode` | Set to `"disable"` to prevent Auto mode |
| `autoMode` | Customize auto mode classifier |

### VS Code Extension

#### Prerequisites

- VS Code 1.98.0 or higher
- Anthropic account (or third-party provider configured)

#### Extension Settings

| Setting | Default | Description |
|:--------|:--------|:-----------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | Launch in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter to send prompts |
| `enableNewConversationShortcut` | `true` | Enable Cmd/Ctrl+N for new conversation |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `disableLoginPrompt` | `false` | Skip authentication prompts |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto/Bypass modes to selector |
| `claudeProcessWrapper` | - | Executable path to launch Claude process |

#### VS Code Commands and Shortcuts

| Command | Shortcut (Mac / Win-Linux) | Description |
|:--------|:---------------------------|:-----------|
| Focus Input | `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| Open in New Tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | Open new conversation as editor tab |
| New Conversation | `Cmd+N` / `Ctrl+N` | Start new conversation (Claude focused) |
| Insert @-Mention | `Option+K` / `Alt+K` | Insert file reference (editor focused) |

#### Built-in IDE MCP Server

| Tool name | What it does | Writes? |
|:----------|:-------------|:--------|
| `mcp__ide__getDiagnostics` | Returns language-server diagnostics (errors/warnings) | No |
| `mcp__ide__executeCode` | Runs Python code in active Jupyter notebook kernel | Yes |

The server binds to `127.0.0.1` on a random high port with a fresh auth token per activation. Token stored at `~/.claude/ide/` with `0600` permissions.

#### URI Handler

```
vscode://anthropic.claude-code/open[?prompt=<url-encoded>&session=<id>]
```

Open with `open` (macOS), `xdg-open` (Linux), or `start` (Windows).

### JetBrains Plugin

#### Features

| Feature | Shortcut (Mac / Win-Linux) |
|:--------|:---------------------------|
| Quick launch | `Cmd+Esc` / `Ctrl+Esc` |
| File reference | `Cmd+Option+K` / `Alt+Ctrl+K` |
| Diff viewing | Automatic in IDE diff viewer |
| Selection context | Automatic from current selection/tab |
| Diagnostic sharing | Automatic (lint, syntax errors) |

#### Plugin Settings (Settings -> Tools -> Claude Code)

| Setting | Description |
|:--------|:-----------|
| Claude command | Custom command path (e.g., `claude`, `/usr/local/bin/claude`) |
| Enable Option+Enter for multi-line | macOS only; inserts new lines in prompts |
| Enable automatic updates | Auto-check and install plugin updates |

#### Special Configurations

| Configuration | Notes |
|:-------------|:------|
| Remote Development | Install plugin in remote host via Settings -> Plugin (Host) |
| WSL | May need terminal config, networking mode, and firewall adjustments |

### Chrome Integration (Beta)

#### Prerequisites

- Google Chrome or Microsoft Edge
- Claude in Chrome extension v1.0.36+
- Claude Code v2.0.73+
- Direct Anthropic plan (Pro, Max, Team, or Enterprise)

#### Capabilities

| Capability | Description |
|:-----------|:-----------|
| Live debugging | Read console errors and DOM state, fix code |
| Design verification | Build UI, open in browser to verify against mocks |
| Web app testing | Test forms, check regressions, verify user flows |
| Authenticated apps | Interact with Google Docs, Gmail, Notion via login state |
| Data extraction | Pull structured data from web pages |
| Task automation | Form filling, data entry, multi-site workflows |
| Session recording | Record interactions as GIFs |

#### CLI Usage

```bash
claude --chrome         # Start with Chrome enabled
/chrome                 # Enable/check status within a session
```

In VS Code, use `@browser` in the prompt box.

#### Native Messaging Host Paths (Chrome)

| OS | Path |
|:---|:-----|
| macOS | `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` |
| Linux | `~/.config/google-chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` |
| Windows | Registry: `HKCU\Software\Google\Chrome\NativeMessagingHosts\` |

#### Common Chrome Errors

| Error | Fix |
|:------|:----|
| "Browser extension is not connected" | Restart Chrome and Claude Code, run `/chrome` |
| "Extension not detected" | Install/enable in `chrome://extensions` |
| "No tab available" | Ask Claude to create a new tab |
| "Receiving end does not exist" | Run `/chrome` and select "Reconnect extension" |

### Computer Use (CLI)

#### Requirements

- macOS only (CLI); macOS + Windows (Desktop)
- Pro or Max plan
- Claude Code v2.1.85+
- Interactive session (not `-p` flag)

#### Enable

1. Run `/mcp` in an interactive session
2. Select `computer-use` and choose Enable
3. Grant macOS permissions: Accessibility + Screen Recording

#### Tool Priority Order

1. MCP server for the service (if available)
2. Bash (shell commands)
3. Chrome extension (browser work)
4. Computer use (native apps, simulators, GUI-only tools)

#### Safety Guardrails

| Guardrail | Description |
|:----------|:-----------|
| Per-app approval | Only approved apps per session |
| Sentinel warnings | Shell/filesystem/system-settings apps flagged |
| Terminal excluded | Claude never sees terminal in screenshots |
| Global escape | `Esc` key aborts from anywhere |
| Lock file | One session at a time |

#### CLI vs Desktop Computer Use

| Feature | Desktop | CLI |
|:--------|:--------|:----|
| Platforms | macOS and Windows | macOS only |
| Enable | Settings -> General toggle | Enable `computer-use` in `/mcp` |
| Denied apps list | Configurable in Settings | Not yet available |
| Auto-unhide toggle | Optional | Always on |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- Full Desktop reference: permission modes, diff view, app preview, PR monitoring, parallel sessions, computer use, Dispatch, connectors, SSH/remote, enterprise configuration, CLI comparison
- [Get Started with the Desktop App](references/claude-code-desktop-quickstart.md) -- Desktop quickstart: install, first session, tips for new users
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) -- VS Code extension: installation, prompt box, @-mentions, commands, settings, MCP server, checkpoints, plugins, git worktrees, third-party providers
- [JetBrains IDEs](references/claude-code-jetbrains.md) -- JetBrains plugin: installation, configuration, shortcuts, remote development, WSL, troubleshooting
- [Use Claude Code with Chrome](references/claude-code-chrome.md) -- Chrome integration: browser automation, debugging, form filling, data extraction, GIF recording, troubleshooting
- [Let Claude Use Your Computer from the CLI](references/claude-code-computer-use.md) -- Computer use in CLI: enable, per-app approval, safety, example workflows, troubleshooting

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get Started with the Desktop App: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude Use Your Computer from the CLI: https://code.claude.com/docs/en/computer-use.md
