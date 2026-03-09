---
name: ide-doc
description: Complete documentation for Claude Code IDE and GUI integrations -- Desktop app (sessions, diff review, app preview, PR monitoring, scheduled tasks, connectors, enterprise config, SSH, remote sessions), VS Code extension (installation, panel, @-mentions, commands, shortcuts, plugins, settings, checkpoints, Chrome browser automation), JetBrains plugin (IntelliJ, PyCharm, WebStorm, diff viewing, selection context), and Chrome browser extension (live debugging, form automation, data extraction, GIF recording). Load when discussing Desktop app features, VS Code extension setup, JetBrains plugin, Chrome integration, IDE shortcuts, diff review, app preview, permission modes in GUI, scheduled tasks, connectors, or any non-CLI Claude Code interface.
user-invocable: false
---

# IDE & GUI Integrations Documentation

This skill provides the complete official documentation for using Claude Code through graphical interfaces: the Desktop app, the VS Code extension, the JetBrains plugin, and the Chrome browser extension.

## Quick Reference

Claude Code can be used through four GUI surfaces beyond the CLI:

| Surface | Platforms | Key capabilities |
|:--------|:----------|:-----------------|
| Desktop app | macOS, Windows | Visual diff review, app preview, PR monitoring, parallel sessions with worktrees, scheduled tasks, connectors, remote/SSH sessions |
| VS Code extension | VS Code, Cursor | Inline diffs, @-mentions with line ranges, plan review, multiple tabs, checkpoints, plugin management, Chrome automation |
| JetBrains plugin | IntelliJ, PyCharm, WebStorm, GoLand, PhpStorm, Android Studio | Diff viewing in IDE, selection context sharing, file reference shortcuts, diagnostic sharing |
| Chrome extension | Chrome, Edge | Live debugging, form automation, data extraction, GIF recording, authenticated web app interaction |

### Desktop App

#### Session Configuration

| Setting | Options |
|:--------|:--------|
| Environment | Local, Remote (Anthropic cloud), SSH |
| Model | Sonnet, Opus, Haiku (locked after session starts) |
| Permission mode | Ask permissions, Auto accept edits, Plan mode, Bypass permissions |
| Project folder | Local directory or multiple repos (remote) |

#### Permission Modes

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Asks before editing files or running commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits, asks before terminal commands |
| Plan mode | `plan` | Analyzes and plans without modifying files |
| Bypass permissions | `bypassPermissions` | No permission prompts (requires Settings toggle; enterprise admins can disable) |

#### Desktop-Exclusive Features

| Feature | Description |
|:--------|:------------|
| Visual diff review | File-by-file diff with inline comments; submit with Cmd/Ctrl+Enter |
| Code review | Click "Review code" in diff view; Claude flags compile errors, logic errors, security issues |
| App preview | Embedded browser for dev server; auto-verify checks changes after edits |
| PR monitoring | CI status bar with auto-fix and auto-merge toggles (requires `gh` CLI) |
| Parallel sessions | Each session gets its own Git worktree; stored in `.claude/worktrees/` |
| Scheduled tasks | Recurring sessions (manual, hourly, daily, weekdays, weekly); runs locally |
| Connectors | GUI for adding MCP integrations (Slack, GitHub, Linear, Notion, etc.) |
| Remote sessions | Cloud-hosted; continue after closing app; supports multiple repos |
| SSH sessions | Connect to remote machines; requires Claude Code installed on host |
| Continue in | Move session to Claude Code on the Web or open in IDE |

#### Preview Server Configuration (`.claude/launch.json`)

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments (e.g., `["run", "dev"]`) |
| `port` | number | Server port (default: 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables |
| `autoPort` | boolean | `true`: auto-find free port; `false`: fail on conflict |
| `program` | string | Node.js script to run directly |
| `args` | string[] | Arguments for `program` |
| `autoVerify` | boolean | Top-level; auto-verify changes after edits (default: true) |

#### Scheduled Tasks

| Field | Description |
|:------|:------------|
| Name | Unique identifier (kebab-case) |
| Prompt | Instructions sent to Claude |
| Frequency | Manual, Hourly, Daily, Weekdays, Weekly |
| Storage | `~/.claude/scheduled-tasks/<task-name>/SKILL.md` |

Missed runs: on wake/launch, Desktop runs one catch-up run for the most recently missed time in the last 7 days. Tasks get a fixed delay of up to 10 minutes to stagger API traffic.

#### CLI to Desktop Mapping

| CLI flag | Desktop equivalent |
|:---------|:-------------------|
| `--model sonnet` | Model dropdown next to send button |
| `--resume` / `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (Settings toggle) |
| `--add-dir` | **+** button in remote sessions |
| `/desktop` (CLI command) | Moves CLI session into Desktop app |

#### Enterprise Configuration

| Control | Scope |
|:--------|:------|
| Admin console | Enable/disable Code tab, disable Bypass mode, disable remote sessions |
| Managed settings | `disableBypassPermissionsMode`, `allowManagedPermissionRulesOnly`, `allowManagedHooksOnly` |
| MDM (macOS) | `com.anthropic.Claude` preference domain |
| Group Policy (Windows) | `SOFTWARE\Policies\Claude` registry |

### VS Code Extension

#### Prerequisites

- VS Code 1.98.0+ (also works with Cursor)
- Anthropic account (or third-party provider with login prompt disabled)

#### Opening Claude Code

| Method | How |
|:-------|:----|
| Editor Toolbar | Spark icon in top-right (requires file open) |
| Activity Bar | Spark icon in left sidebar |
| Command Palette | Cmd/Ctrl+Shift+P, type "Claude Code" |
| Status Bar | Click "Claude Code" in bottom-right |

#### VS Code Commands and Shortcuts

| Command | Shortcut | Description |
|:--------|:---------|:------------|
| Focus Input | Cmd+Esc / Ctrl+Esc | Toggle focus between editor and Claude |
| Open in New Tab | Cmd+Shift+Esc / Ctrl+Shift+Esc | New conversation as editor tab |
| New Conversation | Cmd+N / Ctrl+N | Start new conversation (Claude focused) |
| Insert @-Mention | Option+K / Alt+K | Insert file reference with line numbers |

#### VS Code Extension Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | Use terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter to send |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from searches |
| `allowDangerouslySkipPermissions` | `false` | Bypass all permission prompts |
| `claudeProcessWrapper` | - | Custom executable to launch Claude |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party providers) |

#### Prompt Box Features

- **Permission modes**: click mode indicator to switch (normal, Plan, auto-accept)
- **Command menu**: type `/` for model switching, extended thinking, MCP, hooks, memory, plugins
- **Context indicator**: shows context window usage; auto-compacts when needed
- **@-mentions**: `@filename` for files, `@src/components/` for folders (fuzzy matching)
- **Selection context**: selected text auto-visible; Option+K / Alt+K inserts @-mention with line range
- **Multi-line**: Shift+Enter for new lines
- **Terminal output**: `@terminal:name` to reference terminal output
- **Chrome automation**: `@browser` followed by task description

#### Checkpoints (Rewind)

Hover over any message to reveal the rewind button with three options:
- **Fork conversation from here**: new branch, keep code changes
- **Rewind code to here**: revert files, keep conversation history
- **Fork conversation and rewind code**: new branch and revert files

#### Plugin Management

Type `/plugins` to open the plugin manager. Install plugins for user, project, or local scope. Manage marketplaces in the Marketplaces tab.

#### CLI vs Extension Feature Comparison

| Feature | CLI | VS Code Extension |
|:--------|:----|:------------------|
| Commands and skills | All | Subset (type `/` to see) |
| MCP server config | Full | Partial (add via CLI; manage with `/mcp`) |
| Checkpoints | Yes | Yes |
| Bash shortcut (prefix with `!`) | Yes | No |
| Tab completion | Yes | No |

### JetBrains Plugin

#### Supported IDEs

IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand

#### Features

| Feature | Shortcut |
|:--------|:---------|
| Quick launch | Cmd+Esc (Mac) / Ctrl+Esc (Win/Linux) |
| File reference | Cmd+Option+K (Mac) / Alt+Ctrl+K (Win/Linux) |
| Diff viewing | Displayed in IDE diff viewer |
| Selection context | Current selection/tab auto-shared |
| Diagnostic sharing | Lint/syntax errors auto-shared |

#### Plugin Settings (Settings > Tools > Claude Code)

| Setting | Description |
|:--------|:------------|
| Claude command | Custom path (e.g., `/usr/local/bin/claude`; WSL: `wsl -d Ubuntu -- bash -lic "claude"`) |
| Option+Enter for multi-line | macOS only; toggle if Option key captured unexpectedly |
| Automatic updates | Auto-check and install plugin updates |

#### Special Configurations

- **Remote Development**: install plugin in remote host via Settings > Plugin (Host)
- **WSL**: may require terminal config, networking mode, and firewall adjustments

### Chrome Browser Extension

#### Prerequisites

- Chrome or Edge browser
- Claude in Chrome extension v1.0.36+
- Claude Code v2.0.73+
- Direct Anthropic plan (not available through third-party providers)

#### Activation

| Method | How |
|:-------|:----|
| CLI flag | `claude --chrome` |
| In-session | `/chrome` command |
| Default | Run `/chrome` and select "Enabled by default" |
| VS Code | `@browser` in prompt box (auto-available with extension installed) |

#### Capabilities

| Capability | Description |
|:-----------|:------------|
| Live debugging | Read console errors/DOM, then fix code |
| Design verification | Build UI, open in browser, verify against mockup |
| Web app testing | Form validation, visual regression, user flows |
| Authenticated apps | Interact with Google Docs, Gmail, Notion (uses browser login state) |
| Data extraction | Pull structured data from pages, save locally |
| Task automation | Data entry, form filling, multi-site workflows |
| GIF recording | Record browser interactions as shareable GIFs |

#### Troubleshooting

| Error | Fix |
|:------|:----|
| Extension not detected | Restart Chrome and Claude Code; run `/chrome` > Reconnect |
| Browser not responding | Dismiss modal dialogs; create new tab; restart extension |
| Connection drops | Run `/chrome` > "Reconnect extension" |
| Named pipe conflicts (Windows) | Restart Claude Code; close other sessions |

Native messaging host config locations:
- macOS Chrome: `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- macOS Edge: `~/Library/Application Support/Microsoft Edge/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Linux Chrome: `~/.config/google-chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- full Desktop reference: sessions, permission modes, diff review, app preview, PR monitoring, parallel sessions, remote/SSH sessions, connectors, plugins, scheduled tasks, enterprise configuration, CLI comparison, troubleshooting
- [Get started with the Desktop app](references/claude-code-desktop-quickstart.md) -- installation, first session, quickstart guide for the Desktop Code tab
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) -- extension installation, prompt box, @-mentions, commands and shortcuts, settings, checkpoints, plugin management, Chrome automation, git workflows, third-party providers, troubleshooting
- [JetBrains IDEs](references/claude-code-jetbrains.md) -- plugin installation, features, configuration, remote development, WSL setup, troubleshooting
- [Use Claude Code with Chrome](references/claude-code-chrome.md) -- Chrome extension setup, browser automation capabilities, example workflows, site permissions, troubleshooting

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the Desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
