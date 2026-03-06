---
name: ide-doc
description: Complete documentation for Claude Code IDE integrations and surfaces — Desktop app (Code tab, sessions, diff review, preview servers, PR monitoring, auto-fix/auto-merge, connectors, SSH, remote sessions, enterprise config, device management), VS Code extension (installation, commands, keyboard shortcuts, settings, @-mentions, permission modes, plan review, checkpoints, plugins, Chrome browser automation, terminal mode, git worktrees, third-party providers), JetBrains plugin (IntelliJ, PyCharm, WebStorm, diff viewing, selection context, remote development, WSL), and Chrome extension (browser automation, live debugging, session recording, form filling, data extraction, site permissions, native messaging). Load when discussing Desktop app, VS Code extension, JetBrains plugin, Chrome integration, IDE setup, permission modes in Desktop, preview servers, launch.json configuration, diff review, session management, or the /chrome and /ide commands.
user-invocable: false
---

# IDE Integrations Documentation

This skill provides the complete official documentation for Claude Code's IDE integrations: Desktop app, VS Code extension, JetBrains plugin, and Chrome browser extension.

## Quick Reference

Claude Code is available across four surfaces beyond the CLI: the Desktop app (Code tab), a VS Code extension, a JetBrains plugin, and a Chrome browser extension for automation.

### Surface Comparison

| Surface | Platforms | Auth | Third-party providers | Key differentiators |
|:--------|:----------|:-----|:----------------------|:--------------------|
| Desktop (Code tab) | macOS, Windows | Anthropic account (Pro/Max/Teams/Enterprise) | No | Visual diff review, live preview, PR monitoring, remote sessions, connectors, parallel worktree sessions |
| VS Code extension | macOS, Windows, Linux | Anthropic or third-party | Bedrock, Vertex, Foundry | Inline diffs, @-mentions with line ranges, multiple tabs, checkpoints, terminal mode, Chrome automation |
| JetBrains plugin | macOS, Windows, Linux | Anthropic or third-party | Bedrock, Vertex, Foundry | IDE diff viewer, selection context, diagnostic sharing, file reference shortcuts |
| Chrome extension | macOS, Windows, Linux | Anthropic (Pro/Max/Teams/Enterprise) | No | Browser automation, live debugging, DOM inspection, session recording as GIF |

### Desktop App

#### Permission Modes

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Asks before editing files or running commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits, asks before commands |
| Plan mode | `plan` | Analyzes and plans without modifying files |
| Bypass permissions | `bypassPermissions` | No prompts; enable in Settings; enterprise admins can disable |

The `dontAsk` mode is CLI-only and not available in Desktop.

#### Environment Types

| Environment | Description |
|:------------|:------------|
| Local | Runs on your machine with direct file access |
| Remote | Runs on Anthropic cloud; continues when app is closed |
| SSH | Runs on a remote machine you manage over SSH |

#### Preview Server Configuration (`launch.json`)

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (e.g., `npm`, `yarn`) |
| `runtimeArgs` | string[] | Arguments (e.g., `["run", "dev"]`) |
| `port` | number | Server port (default: 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables |
| `autoPort` | boolean | `true`: find free port; `false`: fail on conflict; unset: ask |
| `program` | string | Node.js script to run directly (alternative to `runtimeExecutable`) |
| `args` | string[] | Arguments passed to `program` |
| `autoVerify` | boolean | Auto-verify changes after edits (default: `true`; set at top level) |

#### Session Features

- Parallel sessions with automatic Git worktree isolation (stored in `.claude/worktrees/`)
- Remote sessions for long-running tasks (continue when app is closed)
- Multi-repo support in remote sessions
- "Continue in" menu to move sessions to web or IDE
- CI status bar with auto-fix and auto-merge toggles for PRs
- Diff view with inline comments (Cmd+Enter / Ctrl+Enter to submit)
- Code review via "Review code" button in diff toolbar

#### Connectors

Available for local and SSH sessions. Connect external services (GitHub, Slack, Linear, Notion, Google Calendar) via the + button > Connectors. Connectors are MCP servers with a graphical setup flow. For unlisted integrations, add MCP servers manually.

#### CLI Flag Equivalents in Desktop

| CLI flag | Desktop equivalent |
|:---------|:-------------------|
| `--model sonnet` | Model dropdown next to send button |
| `--resume`, `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (Settings) |
| `--add-dir` | + button in remote sessions |

#### Enterprise Configuration

- Admin console: enable/disable Code tab, disable Bypass permissions, disable remote sessions
- Managed settings: `disableBypassPermissionsMode`, `allowManagedPermissionRulesOnly`, `allowManagedHooksOnly`
- Device management: macOS via MDM (`com.anthropic.Claude`); Windows via registry (`SOFTWARE\Policies\Claude`)
- SSO: SAML and OIDC support for enterprise orgs

### VS Code Extension

#### Requirements

- VS Code 1.98.0 or higher
- Anthropic account or third-party provider credentials

#### Key Commands and Shortcuts

| Command | Shortcut (Mac / Win-Linux) | Description |
|:--------|:---------------------------|:------------|
| Focus Input | Cmd+Esc / Ctrl+Esc | Toggle focus between editor and Claude |
| Open in New Tab | Cmd+Shift+Esc / Ctrl+Shift+Esc | New conversation as editor tab |
| New Conversation | Cmd+N / Ctrl+N | Start new conversation (Claude focused) |
| Insert @-Mention | Option+K / Alt+K | Insert file reference with line numbers |

#### Extension Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | Use terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter to send instead of Enter |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from searches |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party providers) |
| `allowDangerouslySkipPermissions` | `false` | Bypass all permission prompts |

#### Features

- @-mentions with fuzzy matching and line ranges (`@auth.js`, `@file.ts#5-10`)
- `@terminal:name` to reference terminal output
- @browser for Chrome automation (requires Chrome extension 1.0.36+)
- Plan mode with full markdown document for inline comments
- Checkpoints: fork conversation, rewind code, or both (hover message for rewind button)
- Resume remote sessions from claude.ai via Past Conversations > Remote tab
- Plugin management via `/plugins` in prompt box
- MCP server management via `/mcp` in prompt box
- Drag panel to sidebar, editor area, or secondary sidebar

### JetBrains Plugin

#### Supported IDEs

IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand

#### Features

| Feature | Shortcut (Mac / Win-Linux) |
|:--------|:---------------------------|
| Open Claude Code | Cmd+Esc / Ctrl+Esc |
| Insert file reference | Cmd+Option+K / Alt+Ctrl+K |
| Diff viewing | Automatic (IDE diff viewer) |
| Selection context | Automatic |
| Diagnostic sharing | Automatic |

#### Plugin Settings (Settings > Tools > Claude Code)

- **Claude command**: custom command path (e.g., `/usr/local/bin/claude`)
- **Option+Enter for multi-line**: macOS only
- **Automatic updates**: check for plugin updates

#### Special Configurations

- **Remote Development**: install plugin on remote host via Settings > Plugin (Host)
- **WSL**: may need terminal config, networking mode, and firewall adjustments; set command to `wsl -d Ubuntu -- bash -lic "claude"`
- **ESC key**: if ESC does not interrupt, go to Settings > Tools > Terminal and uncheck "Move focus to the editor with Escape"

### Chrome Extension

#### Requirements

- Google Chrome or Microsoft Edge
- Claude in Chrome extension (version 1.0.36+)
- Claude Code 2.0.73+
- Direct Anthropic plan (not available via third-party providers)

#### Getting Started

```
claude --chrome           # start with Chrome enabled
/chrome                   # enable/check status within a session
```

In VS Code, type `@browser` in the prompt box followed by your task.

To enable Chrome by default in the CLI, run `/chrome` and select "Enabled by default".

#### Capabilities

- Live debugging (console errors, DOM state)
- Design verification against mockups
- Web app testing (forms, visual regressions, user flows)
- Authenticated web app interaction (Google Docs, Gmail, Notion)
- Data extraction from web pages
- Task automation (form filling, multi-site workflows)
- Session recording as GIF

#### Site Permissions

Managed via the Chrome extension settings. Controls which sites Claude can browse, click, and type on.

#### Native Messaging Host Paths

**Chrome:**
- macOS: `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Linux: `~/.config/google-chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Windows: `HKCU\Software\Google\Chrome\NativeMessagingHosts\` registry

**Edge:**
- macOS: `~/Library/Application Support/Microsoft Edge/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Linux: `~/.config/microsoft-edge/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Windows: `HKCU\Software\Microsoft\Edge\NativeMessagingHosts\` registry

### Shared Configuration

Desktop and CLI share configuration files. VS Code extension and CLI share conversation history and settings.

| Config | Shared across |
|:-------|:-------------|
| CLAUDE.md / CLAUDE.local.md | Desktop, CLI, VS Code, JetBrains |
| MCP servers (`~/.claude.json`, `.mcp.json`) | Desktop, CLI, VS Code, JetBrains |
| Hooks and skills | Desktop, CLI, VS Code, JetBrains |
| Settings (`~/.claude.json`, `~/.claude/settings.json`) | Desktop, CLI, VS Code, JetBrains |
| Conversation history | CLI and VS Code (resume with `claude --resume`) |

MCP servers configured in `claude_desktop_config.json` (Desktop chat app) are separate from Claude Code and do not appear in the Code tab.

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- full Desktop reference: sessions, diff review, preview servers, PR monitoring, connectors, plugins, SSH, remote sessions, enterprise config, CLI comparison, troubleshooting
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) -- installation, first session walkthrough, environment and model selection, permission modes, next steps
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) -- extension setup, commands, shortcuts, settings, @-mentions, plan review, checkpoints, plugins, Chrome automation, MCP, git workflows, third-party providers, troubleshooting
- [JetBrains IDEs](references/claude-code-jetbrains.md) -- plugin installation, features, configuration, remote development, WSL setup, troubleshooting
- [Use Claude Code with Chrome](references/claude-code-chrome.md) -- Chrome extension setup, browser automation capabilities, example workflows, site permissions, native messaging, troubleshooting

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
