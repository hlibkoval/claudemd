---
name: ide-doc
description: Complete documentation for Claude Code IDE integrations -- Desktop app (visual diff review, live preview with launch.json, PR monitoring with auto-fix/auto-merge, parallel sessions with Git worktrees, scheduled tasks with frequency/missed runs/permissions, SSH sessions, remote/cloud sessions, connectors, plugins, permission modes, enterprise MDM/SSO/managed settings, CLI flag equivalents, environment configuration), VS Code extension (installation, prompt box with permission modes and @-mentions, resume remote sessions, extension settings like selectedModel/useTerminal/initialPermissionMode/autosave, commands and keyboard shortcuts, checkpoints/rewind, terminal mode, MCP via /mcp, plugins via /plugins, Chrome browser automation with @browser, third-party providers, git worktrees), JetBrains plugin (IntelliJ/PyCharm/WebStorm/GoLand/PhpStorm/Android Studio, diff viewing, selection context, file reference shortcuts, plugin settings, ESC key config, remote development, WSL), Chrome browser integration (--chrome flag, /chrome command, browser automation capabilities, site permissions, GIF recording, native messaging host paths, troubleshooting). Load when discussing Desktop app, VS Code extension, JetBrains plugin, Chrome integration, IDE setup, diff view, live preview, launch.json, PR monitoring, auto-fix, auto-merge, scheduled tasks, SSH sessions, connectors, permission modes in Desktop, enterprise desktop config, MDM, VS Code settings, @-mentions in VS Code, checkpoints, terminal mode, MCP in VS Code, plugins UI, Chrome automation, @browser, or any IDE-specific Claude Code question.
user-invocable: false
---

# IDE Integrations Documentation

This skill provides the complete official documentation for using Claude Code across Desktop, VS Code, JetBrains IDEs, and Chrome browser integration.

## Quick Reference

### Surface Comparison

| Feature | Desktop | VS Code Extension | JetBrains Plugin | CLI |
|:--------|:--------|:------------------|:-----------------|:----|
| Diff review | Visual diff with inline comments | Side-by-side diffs | IDE diff viewer | Terminal diffs |
| Live preview | Embedded browser | N/A | N/A | N/A |
| PR monitoring | Auto-fix + auto-merge | N/A | N/A | Manual |
| Parallel sessions | Sidebar + auto worktrees | Multiple tabs/windows | N/A | Separate terminals |
| Scheduled tasks | Built-in UI | N/A | N/A | Cron / CI |
| File attachments | Images, PDFs | Images, PDFs (drag/shift-drag) | N/A | N/A |
| @-mentions | With autocomplete | With fuzzy matching | N/A | Text-based |
| Plugins | Plugin manager UI | `/plugins` command | N/A | `/plugin` command |
| Permission modes | Ask, Auto accept, Plan, Bypass | Ask, Auto accept, Plan, Bypass | N/A (CLI modes) | All including `dontAsk` |
| Third-party providers | Not available | Bedrock, Vertex, Foundry | N/A (CLI) | Bedrock, Vertex, Foundry |
| Chrome automation | N/A | `@browser` | N/A | `--chrome` flag |
| Connectors | GitHub, Slack, Linear, etc. | N/A | N/A | N/A |
| SSH sessions | Built-in | N/A | N/A | N/A |
| Remote/cloud sessions | Built-in | Resume remote sessions | N/A | `--remote` flag |

### Desktop App

#### Platform Support

| Platform | Status |
|:---------|:-------|
| macOS (Apple Silicon) | Full support (Chat, Code, Cowork tabs) |
| macOS (Intel) | Chat + Code tabs only (no Cowork) |
| Windows (x64) | Full support |
| Windows (ARM64) | Full support |
| Linux | Not supported |

#### Desktop Tabs

| Tab | Description |
|:----|:------------|
| Chat | General conversation, no file access (same as claude.ai) |
| Cowork | Autonomous background agent on cloud VM |
| Code | Interactive coding assistant with local file access |

#### Permission Modes

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Asks before each edit/command |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits, asks for commands |
| Plan mode | `plan` | Analyzes and plans without modifying files |
| Bypass permissions | `bypassPermissions` | No prompts (requires Settings toggle, enterprise can disable) |

Remote sessions support Auto accept edits and Plan mode only.

#### Preview Server Configuration (`launch.json`)

Located at `.claude/launch.json`. Supports JSON with comments.

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments for the command |
| `port` | number | Server port (default: 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables |
| `autoPort` | boolean | `true`: pick free port; `false`: fail on conflict; omit: ask |
| `program` | string | Script to run with `node` directly |
| `args` | string[] | Arguments for `program` |
| `autoVerify` | boolean | Auto-verify changes after edits (default: true, set at top level) |

#### Scheduled Tasks

| Field | Description |
|:------|:------------|
| Name | Kebab-case identifier, used as folder name |
| Description | Short summary in the task list |
| Prompt | Instructions sent to Claude each run |
| Frequency | Manual, Hourly, Daily, Weekdays, Weekly |

Stored on disk at `~/.claude/scheduled-tasks/<task-name>/SKILL.md`.

**Missed run behavior:** On wake/app start, checks last 7 days, runs one catch-up for the most recently missed time.

#### SSH Session Setup

| Field | Description |
|:------|:------------|
| Name | Friendly label |
| SSH Host | `user@hostname` or SSH config host |
| SSH Port | Default 22 |
| Identity File | Path to private key (e.g., `~/.ssh/id_rsa`) |

Claude Code must be installed on the remote machine.

#### CLI-to-Desktop Flag Equivalents

| CLI flag | Desktop equivalent |
|:---------|:-------------------|
| `--model sonnet` | Model dropdown next to send button |
| `--resume`, `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (Settings) |
| `--add-dir` | **+** button in remote sessions |
| `--allowedTools`, `--disallowedTools` | Not available |
| `--print`, `--output-format` | Not available (interactive only) |

#### Desktop-to-CLI Handoff

Use `/desktop` in the CLI to move a session into the Desktop app (macOS and Windows only).

#### Enterprise Configuration

| Control | Mechanism |
|:--------|:----------|
| Enable/disable Code tab | Admin console |
| Disable Bypass permissions | Admin console + managed settings (`disableBypassPermissionsMode`) |
| Disable remote sessions | Admin console |
| MDM (macOS) | `com.anthropic.Claude` preference domain (Jamf, Kandji) |
| MDM (Windows) | Registry `SOFTWARE\Policies\Claude` |
| SSO | SAML / OIDC via admin settings |

### VS Code Extension

#### Prerequisites

- VS Code 1.98.0 or higher
- Anthropic account (or third-party provider config)

#### Installation

- [Install for VS Code](vscode:extension/anthropic.claude-code)
- [Install for Cursor](cursor:extension/anthropic.claude-code)

#### Keyboard Shortcuts

| Command | Shortcut (Mac) | Shortcut (Win/Linux) |
|:--------|:---------------|:---------------------|
| Focus Input (toggle editor/Claude) | `Cmd+Esc` | `Ctrl+Esc` |
| Open in New Tab | `Cmd+Shift+Esc` | `Ctrl+Shift+Esc` |
| New Conversation | `Cmd+N` (Claude focused) | `Ctrl+N` (Claude focused) |
| Insert @-Mention Reference | `Option+K` (editor focused) | `Alt+K` (editor focused) |

#### Extension Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | Launch in terminal mode instead of panel |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter to send |
| `enableNewConversationShortcut` | `true` | Enable Cmd/Ctrl+N for new conversation |
| `hideOnboarding` | `false` | Hide onboarding checklist |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from searches |
| `disableLoginPrompt` | `false` | Skip auth prompts (third-party providers) |
| `allowDangerouslySkipPermissions` | `false` | Bypass all permission prompts |
| `claudeProcessWrapper` | - | Executable path to launch Claude process |

#### Checkpoints (Rewind)

Hover over any message to reveal the rewind button with three options:

- **Fork conversation from here** -- new branch, keep code changes
- **Rewind code to here** -- revert files, keep conversation history
- **Fork conversation and rewind code** -- new branch and revert files

#### Resume Remote Sessions

Click **Past Conversations** dropdown, switch to **Remote** tab to see sessions from claude.ai. Only web sessions with a GitHub repository appear. Requires Claude.ai Subscription sign-in.

#### Chrome Automation in VS Code

Type `@browser` in the prompt box. Requires [Claude in Chrome extension](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) v1.0.36+.

#### CLI Feature Gaps in Extension

| Feature | CLI | Extension |
|:--------|:----|:----------|
| Commands/skills | All | Subset (type `/` to see) |
| MCP server config | Yes | Partial (add via CLI, manage via `/mcp`) |
| Bash shortcut (`!`) | Yes | No |
| Tab completion | Yes | No |

### JetBrains Plugin

#### Supported IDEs

IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand.

#### Features

| Feature | Shortcut (Mac) | Shortcut (Win/Linux) |
|:--------|:---------------|:---------------------|
| Open Claude Code | `Cmd+Esc` | `Ctrl+Esc` |
| Insert file reference | `Cmd+Option+K` | `Alt+Ctrl+K` |

Also provides: IDE diff viewer integration, selection context sharing, diagnostic sharing (lint/syntax errors).

#### Plugin Settings (Settings > Tools > Claude Code)

| Setting | Description |
|:--------|:------------|
| Claude command | Custom command path (e.g., `/usr/local/bin/claude`) |
| Suppress notification | Skip "command not found" notifications |
| Option+Enter for multi-line | macOS only, enables multi-line prompts |
| Automatic updates | Check/install plugin updates on restart |

#### Special Configurations

- **Remote Development**: install plugin on the remote host via **Settings > Plugin (Host)**
- **WSL**: may need terminal, networking, and firewall config adjustments
- **ESC key**: if ESC doesn't interrupt, go to Settings > Tools > Terminal and uncheck "Move focus to the editor with Escape"

### Chrome Integration (Beta)

#### Prerequisites

- Google Chrome or Microsoft Edge
- [Claude in Chrome extension](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) v1.0.36+
- Claude Code v2.0.73+
- Direct Anthropic plan (not available through Bedrock/Vertex/Foundry)

#### Enabling Chrome

| Method | Description |
|:-------|:------------|
| CLI flag | `claude --chrome` |
| In-session | `/chrome` command |
| Default | `/chrome` then select "Enabled by default" |
| VS Code | Automatic when Chrome extension is installed |

#### Capabilities

Live debugging, design verification, web app testing, authenticated web app interaction, data extraction, task automation, GIF session recording.

#### Native Messaging Host Paths

**Chrome:**
- macOS: `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Linux: `~/.config/google-chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Windows: Registry `HKCU\Software\Google\Chrome\NativeMessagingHosts\`

**Edge:**
- macOS: `~/Library/Application Support/Microsoft Edge/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Linux: `~/.config/microsoft-edge/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Windows: Registry `HKCU\Software\Microsoft\Edge\NativeMessagingHosts\`

#### Common Errors

| Error | Fix |
|:------|:----|
| "Browser extension is not connected" | Restart Chrome and Claude Code, run `/chrome` to reconnect |
| "Extension not detected" | Install/enable extension in `chrome://extensions` |
| "No tab available" | Ask Claude to create a new tab and retry |
| "Receiving end does not exist" | Run `/chrome` and select "Reconnect extension" |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- visual diff review with inline comments, live preview with launch.json configuration, PR monitoring with auto-fix and auto-merge, parallel sessions with Git worktrees, scheduled tasks (frequency, missed runs, permissions, on-disk storage), SSH sessions, remote/cloud sessions, connectors (GitHub/Slack/Linear), plugins manager, permission modes, environment configuration (local/remote/SSH), enterprise configuration (admin console, managed settings, MDM, SSO, deployment), CLI flag equivalents, feature comparison, troubleshooting
- [Desktop App Quickstart](references/claude-code-desktop-quickstart.md) -- installation (macOS/Windows), first session walkthrough, Code/Chat/Cowork tabs overview, environment selection (Local/Remote/SSH), model selection, permission review flow, next steps guide
- [VS Code Extension](references/claude-code-vs-code.md) -- installation for VS Code and Cursor, prompt box features (permission modes, @-mentions, context indicator, extended thinking, multi-line input), resume remote sessions, customize workflow (panel placement, multiple conversations, terminal mode), plugin management, Chrome browser automation, commands and keyboard shortcuts, extension settings, CLI comparison, checkpoints/rewind, MCP server management, git workflows, third-party provider configuration, security considerations, troubleshooting
- [JetBrains Plugin](references/claude-code-jetbrains.md) -- supported IDEs (IntelliJ/PyCharm/WebStorm/GoLand/PhpStorm/Android Studio), features (quick launch, diff viewing, selection context, file references, diagnostic sharing), installation, plugin settings, ESC key configuration, remote development setup, WSL configuration, troubleshooting
- [Chrome Integration](references/claude-code-chrome.md) -- prerequisites, CLI setup with --chrome flag, /chrome command, enable by default, VS Code @browser integration, capabilities (live debugging, design verification, web app testing, form automation, data extraction, GIF recording), site permissions, example workflows, native messaging host paths, troubleshooting (extension not detected, browser not responding, connection drops, Windows issues)

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Desktop App Quickstart: https://code.claude.com/docs/en/desktop-quickstart.md
- VS Code Extension: https://code.claude.com/docs/en/vs-code.md
- JetBrains Plugin: https://code.claude.com/docs/en/jetbrains.md
- Chrome Integration: https://code.claude.com/docs/en/chrome.md
