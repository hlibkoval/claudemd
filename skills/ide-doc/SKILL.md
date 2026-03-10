---
name: ide-doc
description: Complete documentation for Claude Code IDE integrations -- Desktop app (parallel sessions with Git worktrees, visual diff review, inline comments, live app preview with auto-verify, PR monitoring with auto-fix/auto-merge, permission modes, scheduled recurring tasks, connectors for GitHub/Slack/Linear/Notion, SSH sessions, remote cloud sessions, preview server configuration via launch.json, enterprise MDM/SSO/managed settings), VS Code extension (inline diffs, @-mentions with fuzzy matching, plan review, permission modes, multi-tab conversations, checkpoints with rewind/fork, plugin management UI, Chrome browser automation via @browser, terminal output references via @terminal, resume remote sessions from claude.ai, extension settings, CLI integration via /ide), JetBrains plugin (IntelliJ, PyCharm, WebStorm, GoLand, PhpStorm, Android Studio -- diff viewing, selection context, file reference shortcuts, ESC key config, remote development, WSL setup), and Chrome extension (browser automation, live debugging, design verification, web app testing, authenticated app interaction, data extraction, task automation, GIF session recording, site permissions). Load when discussing Claude Code in Desktop, VS Code, JetBrains, Chrome, IDE setup, IDE extensions, IDE plugins, desktop app features, diff view, app preview, session management, scheduled tasks, or any IDE-specific configuration.
user-invocable: false
---

# IDE Integrations Documentation

This skill provides the complete official documentation for using Claude Code across Desktop, VS Code, JetBrains IDEs, and Chrome.

## Quick Reference

Claude Code is available in four surfaces beyond the CLI: a standalone Desktop app, a VS Code extension, a JetBrains plugin, and a Chrome browser extension. All share the same underlying engine and configuration (CLAUDE.md, MCP servers, hooks, skills, settings).

### Surface Comparison

| Capability | Desktop | VS Code | JetBrains | Chrome |
|:-----------|:--------|:--------|:-----------|:-------|
| Visual diff review | Inline comments, Review code button | Side-by-side diff with accept/reject | IDE diff viewer | -- |
| App preview | Embedded browser with auto-verify | -- | -- | -- |
| PR monitoring | Auto-fix + auto-merge toggles | -- | -- | -- |
| Parallel sessions | Sidebar + automatic worktrees | New Tab / New Window | -- | -- |
| Scheduled tasks | Built-in scheduler (hourly/daily/weekly) | -- | -- | -- |
| Remote sessions | Cloud (Anthropic-hosted) + SSH | Resume remote sessions from claude.ai | -- | -- |
| Connectors | GitHub, Slack, Linear, Notion, etc. | -- | -- | -- |
| Plugins | Plugin manager UI | `/plugins` dialog | -- | -- |
| Permission modes | Ask, Auto accept, Plan, Bypass | Normal, Plan, Auto-accept, Bypass | -- | -- |
| Browser automation | -- | Via @browser (requires Chrome ext) | -- | Native |
| @-mentions | `@filename` | `@file`, `@file#L1-10`, `@terminal:name` | `@File#L1-99` via shortcut | -- |
| Checkpoints/rewind | -- | Fork / Rewind / Fork+Rewind | -- | -- |
| File attachments | Images, PDFs, drag-and-drop | Shift+drag files | -- | -- |
| Selection context | -- | Automatic (with eye toggle) | Automatic | -- |
| Diagnostics sharing | -- | Automatic | Automatic | -- |
| Third-party providers | Not available | Bedrock, Vertex, Foundry | Bedrock, Vertex, Foundry | -- |
| Platform | macOS, Windows | macOS, Windows, Linux | macOS, Windows, Linux | Chrome, Edge |

### Desktop App

**Requirements**: macOS (Intel + Apple Silicon) or Windows; Pro/Max/Teams/Enterprise subscription.

**Key features**:

- **Permission modes**: Ask permissions (default), Auto accept edits, Plan mode, Bypass permissions
- **Diff view**: click `+12 -1` indicator to review changes; click lines to comment; Cmd/Ctrl+Enter to submit all comments; "Review code" button for Claude self-review
- **App preview**: embedded browser in Preview dropdown; auto-verify on by default; configure in `.claude/launch.json`
- **PR monitoring**: CI status bar with Auto-fix and Auto-merge toggles (requires `gh` CLI)
- **Parallel sessions**: "+ New session" in sidebar; each gets its own Git worktree in `<project>/.claude/worktrees/`
- **Remote sessions**: select "Remote" environment; continues even if app is closed; supports multiple repos
- **SSH sessions**: environment dropdown > "+ Add SSH connection"; Claude Code must be installed on remote host
- **Connectors**: click "+" > Connectors for GitHub, Slack, Linear, Notion, Calendar, etc.
- **Scheduled tasks**: sidebar Schedule section; frequencies: Manual, Hourly, Daily, Weekdays, Weekly; catch-up runs on wake
- **Continue in**: move session to Claude Code on the Web or open in IDE
- **CLI bridge**: run `/desktop` in CLI to transfer session to Desktop app

#### launch.json Configuration Fields

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments for runtimeExecutable |
| `port` | number | Server port (default: 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables |
| `autoPort` | boolean | `true` = find free port; `false` = fail if occupied; unset = ask |
| `program` | string | Script to run with `node` directly |
| `args` | string[] | Arguments for `program` |
| `autoVerify` | boolean | Top-level field; auto-verify changes after edits (default: true) |

#### Desktop Permission Modes

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Asks before edits and commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits, asks for commands |
| Plan mode | `plan` | Analyzes and plans without modifying files |
| Bypass permissions | `bypassPermissions` | No prompts (requires Settings toggle; enterprise can disable) |

#### Scheduled Tasks

| Frequency | Behavior |
|:----------|:---------|
| Manual | On-demand only via "Run now" |
| Hourly | Every hour with staggered offset |
| Daily | At configured time (default 9:00 AM) |
| Weekdays | Daily but skips Saturday/Sunday |
| Weekly | At configured day and time |

Task files are stored at `~/.claude/scheduled-tasks/<task-name>/SKILL.md`. Missed runs get one catch-up run when app resumes (within 7-day window).

#### Enterprise Configuration

| Control | Method |
|:--------|:-------|
| Enable/disable Code tab | Admin console |
| Disable Bypass permissions | Admin console or `disableBypassPermissionsMode` in managed settings |
| Disable remote sessions | Admin console |
| Device management | macOS MDM (`com.anthropic.Claude`) or Windows registry (`SOFTWARE\Policies\Claude`) |
| SSO | SAML/OIDC via admin console |

#### CLI Flag Equivalents in Desktop

| CLI flag | Desktop equivalent |
|:---------|:-------------------|
| `--model sonnet` | Model dropdown next to send button |
| `--resume`, `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (enable in Settings) |
| `--add-dir` | "+" button in remote sessions for multiple repos |

### VS Code Extension

**Requirements**: VS Code 1.98.0+; also works with Cursor.

**Install**: [VS Code Marketplace](vscode:extension/anthropic.claude-code) or search "Claude Code" in Extensions.

#### Opening Claude Code

| Method | Details |
|:-------|:--------|
| Editor Toolbar | Spark icon in top-right (requires file open) |
| Activity Bar | Spark icon in left sidebar |
| Command Palette | `Cmd/Ctrl+Shift+P` > "Claude Code" |
| Status Bar | "Claude Code" in bottom-right corner |

#### Key Shortcuts

| Command | Mac | Windows/Linux |
|:--------|:----|:--------------|
| Focus Input (toggle editor/Claude) | `Cmd+Esc` | `Ctrl+Esc` |
| Open in New Tab | `Cmd+Shift+Esc` | `Ctrl+Shift+Esc` |
| New Conversation | `Cmd+N` | `Ctrl+N` |
| Insert @-Mention Reference | `Option+K` | `Alt+K` |

#### Extension Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | Launch in terminal mode |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before reads/writes |
| `useCtrlEnterToSend` | `false` | Require Ctrl/Cmd+Enter to send |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from searches |
| `allowDangerouslySkipPermissions` | `false` | Enable bypass mode |

#### Checkpoints (Rewind)

Hover over any message for rewind options:
- **Fork conversation from here**: new branch, keep code
- **Rewind code to here**: revert files, keep conversation
- **Fork conversation and rewind code**: both

#### Chrome Browser Automation in VS Code

Requires Claude in Chrome extension v1.0.36+. Type `@browser` followed by instructions. Opens new tabs sharing your login state.

#### Plugin Management

Type `/plugins` to open graphical plugin manager. Install scopes: user (all projects), project (shared), local (private to you + this repo).

#### Resume Remote Sessions

Past Conversations dropdown > Remote tab > select session from claude.ai. Requires Claude.ai Subscription login. Only web sessions started with a GitHub repo appear.

### JetBrains Plugin

**Supported IDEs**: IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand.

**Install**: [JetBrains Marketplace](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-) > restart IDE.

#### Key Shortcuts

| Action | Mac | Windows/Linux |
|:-------|:----|:--------------|
| Open Claude Code | `Cmd+Esc` | `Ctrl+Esc` |
| Insert file reference | `Cmd+Option+K` | `Alt+Ctrl+K` |

#### Plugin Settings (Settings > Tools > Claude Code)

| Setting | Description |
|:--------|:------------|
| Claude command | Custom path (`claude`, `/usr/local/bin/claude`, `npx @anthropic/claude`) |
| Enable Option+Enter for multiline | macOS only; Option+Enter inserts newlines |
| Enable automatic updates | Auto-check for plugin updates |

#### Special Configurations

- **Remote Development**: install plugin on remote host via Settings > Plugin (Host)
- **WSL**: may need terminal config, networking mode, and firewall adjustments
- **ESC key**: if ESC does not interrupt, go to Settings > Tools > Terminal and uncheck "Move focus to the editor with Escape"
- **External terminal**: run `/ide` inside Claude Code to connect to JetBrains

### Chrome Extension

**Requirements**: Google Chrome or Microsoft Edge; Claude in Chrome extension v1.0.36+; Claude Code v2.0.73+; direct Anthropic plan (not third-party providers).

**Supported browsers**: Chrome, Edge. Not supported: Brave, Arc, other Chromium browsers, WSL.

#### Capabilities

| Capability | Description |
|:-----------|:------------|
| Live debugging | Read console errors/DOM, fix code |
| Design verification | Build UI, verify in browser against mocks |
| Web app testing | Form validation, visual regressions, user flows |
| Authenticated apps | Interact with Google Docs, Gmail, Notion (shares login state) |
| Data extraction | Pull structured data from pages, save locally |
| Task automation | Form filling, data entry, multi-site workflows |
| Session recording | Record interactions as GIF |

#### CLI Usage

```
claude --chrome        # start with Chrome enabled
/chrome                # enable mid-session, check status, reconnect
```

Enable by default: run `/chrome` and select "Enabled by default". Increases context usage when always on.

#### Site Permissions

Inherited from Chrome extension settings. Manage in extension to control which sites Claude can browse, click, and type on.

#### Troubleshooting

| Issue | Fix |
|:------|:----|
| Extension not detected | Verify installed in `chrome://extensions`; restart Chrome + Claude Code; run `/chrome` > Reconnect |
| Browser not responding | Check for modal dialogs blocking page; create new tab; restart extension |
| Connection drops | Run `/chrome` > "Reconnect extension" (service worker went idle) |
| Named pipe conflicts (Windows) | Restart Claude Code; close other sessions using Chrome |

Native messaging host config locations:
- macOS Chrome: `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- macOS Edge: `~/Library/Application Support/Microsoft Edge/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Linux Chrome: `~/.config/google-chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Linux Edge: `~/.config/microsoft-edge/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Windows: check `HKCU\Software\Google\Chrome\NativeMessagingHosts\` or `HKCU\Software\Microsoft\Edge\NativeMessagingHosts\` in Registry

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- full Desktop app reference: permission modes, diff view, app preview, PR monitoring, parallel sessions with worktrees, remote/SSH sessions, connectors, plugins, scheduled tasks, launch.json configuration, enterprise MDM/SSO/managed settings, CLI comparison, troubleshooting
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) -- Desktop quickstart: installation (macOS/Windows), first session setup, environment selection, model picking, reviewing changes, interrupting, attaching files, skills, diff review, permission modes, plugins, app preview, PR tracking, scheduled tasks, parallel sessions
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) -- VS Code extension: installation, prompt box features, @-mentions, permission modes, conversation history, remote session resume, panel positioning, multi-tab conversations, plugin management, Chrome browser automation, commands/shortcuts, extension settings, checkpoints, CLI integration, MCP servers, git workflows, third-party providers, security, troubleshooting
- [JetBrains IDEs](references/claude-code-jetbrains.md) -- JetBrains plugin: supported IDEs, features, marketplace installation, IDE/external terminal usage, settings, ESC key config, remote development, WSL configuration, troubleshooting, security
- [Use Claude Code with Chrome](references/claude-code-chrome.md) -- Chrome extension: capabilities (debugging, testing, data extraction, automation, GIF recording), prerequisites, CLI/VS Code setup, site permissions, example workflows, troubleshooting (extension detection, connection drops, Windows issues)

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
