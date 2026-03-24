---
name: ide-doc
description: Complete documentation for Claude Code IDE integrations -- Desktop app (Code tab, visual diff review, live app preview, computer use, PR monitoring with auto-fix/auto-merge, parallel sessions with Git worktree isolation, Dispatch integration, scheduled tasks, connectors, SSH/remote/local environments, enterprise configuration, device management policies, launch.json preview server configuration, permission modes in Desktop), VS Code extension (installation, graphical panel, prompt box features, @-mentions with fuzzy matching and line ranges, permission modes including plan/auto-accept/bypass, plugin management UI, Chrome browser automation via @browser, commands and keyboard shortcuts, extension settings like selectedModel/useTerminal/initialPermissionMode/preferredLocation/autosave/useCtrlEnterToSend, multiple conversations in tabs/windows, resume past and remote sessions, terminal mode, checkpoints with fork/rewind, CLI integration via /ide, @terminal references, built-in IDE MCP server with getDiagnostics and executeCode tools, Jupyter notebook execution with Quick Pick confirmation, third-party provider setup, git worktrees), JetBrains plugin (IntelliJ, PyCharm, WebStorm, GoLand, PhpStorm, Android Studio, quick launch Cmd+Esc, diff viewing, selection context, file reference shortcuts Cmd+Option+K, diagnostic sharing, marketplace installation, plugin settings including custom Claude command, ESC key configuration, remote development host-side installation, WSL configuration), Chrome integration (beta, browser automation from CLI or VS Code, --chrome flag, /chrome command, site permissions, live debugging, design verification, web app testing, authenticated web apps, data extraction, task automation, GIF session recording, native messaging host configuration, Chrome and Edge support, troubleshooting connection drops and service worker idle). Load when discussing Claude Code Desktop app, Code tab, VS Code extension, JetBrains plugin, Chrome integration, IDE integration, desktop quickstart, visual diff review, live preview, computer use, PR monitoring, auto-merge, parallel sessions, worktrees in Desktop, Dispatch, scheduled tasks in Desktop, connectors, SSH sessions, remote sessions, launch.json, preview servers, autoVerify, enterprise desktop configuration, device management, MDM deployment, VS Code commands, VS Code settings, @-mentions, plan mode in VS Code, checkpoints, rewind, IDE MCP server, getDiagnostics, executeCode, Jupyter execution, IntelliJ plugin, PyCharm plugin, WebStorm plugin, browser automation, @browser, --chrome flag, /chrome command, or any IDE/editor integration topic for Claude Code.
user-invocable: false
---

# IDE Integrations Documentation

This skill provides the complete official documentation for Claude Code IDE integrations: the Desktop app (Code tab), VS Code extension, JetBrains plugin, and Chrome browser integration.

## Quick Reference

### Platform Overview

| Integration | Type | Platforms | Key capability |
|:------------|:-----|:----------|:---------------|
| Desktop app (Code tab) | Standalone app | macOS, Windows | Visual diff review, live preview, computer use, PR monitoring, parallel sessions, scheduled tasks, Dispatch |
| VS Code extension | IDE extension | macOS, Windows, Linux | Graphical panel, @-mentions, plan review, checkpoints, plugin manager, Chrome automation |
| JetBrains plugin | IDE plugin | All JetBrains IDEs | Diff viewing, selection context, diagnostic sharing |
| Chrome integration | Browser extension | Chrome, Edge | Browser automation, live debugging, form filling, data extraction, GIF recording |

### Desktop App (Code Tab)

The Code tab in the Claude Desktop app provides a graphical interface for Claude Code with features not available in the CLI.

**Three tabs in Desktop:** Chat (general conversation, no file access), Cowork (autonomous background agent in cloud VM), Code (interactive coding with local file access).

**Desktop-exclusive features:**

| Feature | Description |
|:--------|:------------|
| Visual diff review | Side-by-side diffs with inline comments; submit all comments with Cmd/Ctrl+Enter |
| Live app preview | Embedded browser for dev servers; auto-verify changes after edits |
| Computer use | Control apps and screen on macOS (Pro/Max plans, research preview) |
| PR monitoring | CI status bar with auto-fix and auto-merge toggles (requires `gh` CLI) |
| Parallel sessions | Sidebar tabs with automatic Git worktree isolation |
| Dispatch | Sessions spawned from Cowork tab or phone (Pro/Max plans) |
| Scheduled tasks | Local and remote recurring tasks with configurable frequency |
| Connectors | GUI setup for GitHub, Slack, Linear, Notion, and more |
| SSH sessions | Connect to remote machines via SSH host configuration |
| Remote sessions | Run on Anthropic cloud; continue when app is closed |
| Continue in | Move session to web or open in IDE |

**Permission modes in Desktop:**

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Asks before edits and commands (recommended for new users) |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits; asks for terminal commands |
| Plan mode | `plan` | Analyzes and plans without modifying files |
| Bypass permissions | `bypassPermissions` | No prompts; enable in Settings; enterprise admins can disable |

Note: `dontAsk` mode is CLI-only. Remote sessions support Auto accept edits and Plan mode only.

**Preview server configuration (`.claude/launch.json`):**

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (e.g., `npm`, `yarn`) |
| `runtimeArgs` | string[] | Arguments (e.g., `["run", "dev"]`) |
| `port` | number | Server port (default: 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables |
| `autoPort` | boolean | `true`: find free port; `false`: fail on conflict; unset: ask |
| `program` | string | Script to run with `node` directly |
| `args` | string[] | Arguments for `program` |
| `autoVerify` | boolean | Top-level field; auto-verify changes after edits (default: true) |

**Computer use access tiers:**

| Tier | Capabilities | Applies to |
|:-----|:-------------|:-----------|
| View only | See the app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, no typing | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

**Scheduled tasks frequency options:** Manual, Hourly (with up to 10min offset), Daily, Weekdays, Weekly. Local tasks require app open and computer awake. Missed runs: one catch-up run for most recently missed time on wake.

**CLI flag equivalents in Desktop:**

| CLI flag | Desktop equivalent |
|:---------|:-------------------|
| `--model sonnet` | Model dropdown next to send button |
| `--resume` / `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions in Settings |
| `--add-dir` | **+** button for repos in remote sessions |

**Enterprise configuration:** Admin console controls (Code in desktop, Code in web, Remote Control, Bypass permissions). Managed settings via managed-settings.json or admin console. Device management via MDM (macOS `com.anthropic.Claude`) or registry (Windows `SOFTWARE\Policies\Claude`).

### VS Code Extension

**Prerequisites:** VS Code 1.98.0+, Anthropic account (or third-party provider configured).

**Install:** Search "Claude Code" in Extensions view, or use direct links for VS Code and Cursor.

**Opening Claude Code in VS Code:**

| Method | How |
|:-------|:----|
| Editor Toolbar | Spark icon in top-right (requires file open) |
| Activity Bar | Spark icon in left sidebar (always visible) |
| Command Palette | `Cmd+Shift+P` / `Ctrl+Shift+P`, type "Claude Code" |
| Status Bar | Click "Claude Code" in bottom-right corner |

**Prompt box features:** Permission mode selector, `/` command menu (models, thinking, usage, remote-control, MCP, hooks, memory, permissions, plugins), context usage indicator, extended thinking toggle, multi-line input with Shift+Enter.

**@-mentions:** Type `@` + filename for fuzzy-matched file references. Trailing slash for folders. `@file.ts#5-10` for line ranges. `Option+K` / `Alt+K` inserts reference from current selection. `@terminal:name` references terminal output. Hold Shift while dragging files to attach.

**Key VS Code commands and shortcuts:**

| Command | Shortcut | Description |
|:--------|:---------|:------------|
| Focus Input | `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| Open in New Tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | New conversation as editor tab |
| New Conversation | `Cmd+N` / `Ctrl+N` | Start new conversation (Claude focused) |
| Insert @-Mention | `Option+K` / `Alt+K` | Reference current file and selection (editor focused) |

**Extension settings:**

| Setting | Default | Description |
|:--------|:--------|:------------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | Launch in terminal mode instead of panel |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Ctrl/Cmd+Enter to send instead of Enter |
| `enableNewConversationShortcut` | `true` | Enable Cmd/Ctrl+N shortcut |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from searches |
| `disableLoginPrompt` | `false` | Skip auth prompts (third-party providers) |
| `allowDangerouslySkipPermissions` | `false` | Enable bypass permissions mode |
| `claudeProcessWrapper` | - | Executable path to launch Claude process |

**Checkpoints (rewind):** Hover any message for rewind button with three options: Fork conversation from here, Rewind code to here, Fork conversation and rewind code.

**Built-in IDE MCP server:** Runs on `127.0.0.1` with random port and per-activation auth token. Two model-visible tools:

| Tool | Description | Writes? |
|:-----|:------------|:--------|
| `mcp__ide__getDiagnostics` | Returns VS Code Problems panel diagnostics, optionally scoped to one file | No |
| `mcp__ide__executeCode` | Runs Python in active Jupyter notebook kernel (Quick Pick confirmation required) | Yes |

**Plugin management:** Type `/plugins` to open graphical plugin manager. Install/enable/disable plugins. Manage marketplaces. Three installation scopes: user, project, local.

**CLI in VS Code:** Run `claude` in integrated terminal. Use `/ide` from external terminal to connect. Share conversation history with `claude --resume`.

### JetBrains Plugin

**Supported IDEs:** IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand.

**Features:**

| Feature | Shortcut |
|:--------|:---------|
| Quick launch | `Cmd+Esc` (Mac) / `Ctrl+Esc` (Windows/Linux) |
| File reference | `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Windows/Linux) |
| Diff viewing | IDE diff viewer integration |
| Selection context | Auto-shared with Claude Code |
| Diagnostic sharing | Auto-shared lint/syntax errors |

**Installation:** Install from [JetBrains Marketplace](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-), restart IDE.

**Plugin settings (Settings > Tools > Claude Code):** Custom Claude command path, suppress command-not-found notifications, Option+Enter for multi-line prompts (macOS), automatic updates.

**Remote Development:** Plugin must be installed on the remote host via Settings > Plugin (Host).

**WSL:** May need terminal configuration, networking mode adjustments, and firewall settings. Set Claude command to `wsl -d Ubuntu -- bash -lic "claude"`.

**ESC key fix:** Settings > Tools > Terminal: uncheck "Move focus to the editor with Escape" or delete the "Switch focus to Editor" shortcut.

### Chrome Integration (Beta)

**Supported browsers:** Google Chrome, Microsoft Edge. Not supported: Brave, Arc, other Chromium browsers, WSL.

**Prerequisites:** Chrome or Edge, Claude in Chrome extension v1.0.36+, Claude Code v2.0.73+, direct Anthropic plan. Not available through third-party providers.

**Getting started:** `claude --chrome` or `/chrome` within a session. In VS Code: type `@browser` in prompt box.

**Enable by default:** Run `/chrome` and select "Enabled by default". In VS Code, Chrome is auto-available when extension is installed.

**Capabilities:** Live debugging (console errors + DOM), design verification, web app testing, authenticated web app interaction, data extraction, task automation, GIF session recording.

**Native messaging host paths (Chrome):**

| Platform | Path |
|:---------|:-----|
| macOS | `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` |
| Linux | `~/.config/google-chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` |
| Windows | `HKCU\Software\Google\Chrome\NativeMessagingHosts\` registry |

**Common errors:**

| Error | Fix |
|:------|:----|
| "Browser extension is not connected" | Restart Chrome and Claude Code, run `/chrome` to reconnect |
| "Extension not detected" | Install/enable in `chrome://extensions` |
| "No tab available" | Ask Claude to create a new tab |
| "Receiving end does not exist" | Run `/chrome` > "Reconnect extension" (service worker went idle) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- full Desktop app reference including Code tab overview, session startup (environment/folder/model/permission mode), prompt box usage, @-mentions and file attachments, permission modes (Ask/Auto accept edits/Plan/Bypass), live app preview with auto-verify and launch.json configuration, visual diff review with inline comments, code review, PR monitoring with auto-fix and auto-merge, computer use (macOS research preview with accessibility/screen recording permissions, app permission tiers, Dispatch integration), parallel sessions with Git worktree isolation, remote sessions on Anthropic cloud, Continue in (web/IDE), Dispatch sessions from phone, connectors for external tools, skills and plugins, scheduled tasks (local and remote, frequency options, missed runs catch-up, permissions), environment configuration (local/remote/SSH), enterprise configuration (admin console, managed settings, device management, authentication/SSO, data handling, deployment), CLI comparison (flag equivalents, shared config, feature matrix), troubleshooting (auth errors, blank screen, session failures, Git/Git LFS, Windows issues)
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) -- installation guide for macOS and Windows, sign-in and Code tab setup, first session walkthrough (choose environment and folder, pick model, send prompt, review and accept changes), next steps overview (interrupt and steer, add context with @mentions and attachments, use skills, review diffs, adjust permission modes, add plugins, preview app, track PRs, scheduled tasks, parallel sessions and remote work), CLI comparison
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) -- VS Code extension installation and setup, graphical panel with Spark icon locations (Editor Toolbar, Activity Bar, Command Palette, Status Bar), prompt box features (permission modes, command menu, context indicator, extended thinking, multi-line input), @-mentions with fuzzy matching and line ranges, resume past and remote conversations, customization (panel positioning, multiple conversations, terminal mode), plugin management UI, Chrome browser automation via @browser, all VS Code commands and shortcuts, extension settings reference, CLI vs extension feature comparison, checkpoints (fork/rewind), CLI integration (/ide command, claude --resume, @terminal references), MCP server management, built-in IDE MCP server (getDiagnostics, executeCode with Jupyter Quick Pick), git workflows (commits, PRs, worktrees), third-party provider setup, security considerations, troubleshooting
- [JetBrains IDEs](references/claude-code-jetbrains.md) -- JetBrains plugin for IntelliJ, PyCharm, WebStorm, GoLand, PhpStorm, Android Studio, features (quick launch, diff viewing, selection context, file references, diagnostic sharing), marketplace installation, plugin settings (custom Claude command, multi-line prompts, automatic updates), ESC key configuration, remote development (host-side installation), WSL configuration, troubleshooting (plugin not working, IDE not detected, command not found), security considerations
- [Use Claude Code with Chrome](references/claude-code-chrome.md) -- Chrome browser integration (beta), capabilities (live debugging, design verification, web app testing, authenticated apps, data extraction, task automation, GIF recording), prerequisites (Chrome/Edge, extension v1.0.36+, Claude Code v2.0.73+), CLI setup (--chrome flag, /chrome command), VS Code setup (@browser), enable by default, site permissions, example workflows (test local apps, debug console, automate forms, draft in Google Docs, extract data, multi-site workflows, record demos), troubleshooting (extension not detected, native messaging host paths for Chrome/Edge on macOS/Linux/Windows, browser not responding, connection drops, Windows named pipe conflicts, common error messages)

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
