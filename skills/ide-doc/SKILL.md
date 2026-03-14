---
name: ide-doc
description: Complete documentation for Claude Code IDE and Desktop integrations -- Desktop app (Code tab GUI, visual diff review with inline comments, live app preview with auto-verify, GitHub PR monitoring with auto-fix/auto-merge, parallel sessions with Git worktree isolation, scheduled tasks with frequency options, connectors for GitHub/Slack/Linear/Notion, permission modes Ask/Auto-accept/Plan/Bypass, SSH sessions, remote cloud sessions, .claude/launch.json preview server config, enterprise MDM/managed settings, CLI flag equivalents), Desktop quickstart (install macOS/Windows, Code tab setup, first session walkthrough, @mentions, skills, plugins), VS Code extension (install for VS Code/Cursor, Spark icon, @-mentions with fuzzy matching, @file#L1-99 references, permission modes in prompt box, /commands menu, multiple conversations in tabs/windows, terminal mode toggle, plugin management /plugins, Chrome browser automation @browser, VS Code commands/shortcuts Cmd+Esc/Cmd+Shift+Esc/Option+K, extension settings selectedModel/useTerminal/initialPermissionMode/autosave, checkpoints fork/rewind, resume remote sessions from claude.ai, /ide for external terminals, @terminal:name references, MCP management /mcp, git worktrees --worktree flag, third-party providers Bedrock/Vertex/Foundry setup), JetBrains plugin (IntelliJ/PyCharm/WebStorm/GoLand/PhpStorm/Android Studio, Cmd+Esc quick launch, diff viewing, selection context, Cmd+Option+K file references, diagnostic sharing, plugin settings Claude command path, ESC key config, remote development host install, WSL configuration), Chrome integration beta (Claude in Chrome extension, --chrome flag, /chrome command, live debugging console errors, design verification, web app testing, authenticated web apps, data extraction, form automation, session recording GIFs, site permissions, native messaging host paths, troubleshooting). Load when discussing Claude Code Desktop app, Code tab, desktop diff view, app preview, launch.json, PR monitoring auto-fix auto-merge, parallel sessions worktrees, scheduled tasks, connectors, VS Code extension, Spark icon, @-mentions in VS Code, VS Code settings, checkpoints rewind fork, JetBrains plugin, IntelliJ PyCharm WebStorm, /ide command, Chrome browser integration, @browser, --chrome flag, /chrome, Claude in Chrome extension, browser automation, IDE setup, IDE integration, permission modes in Desktop, remote sessions, SSH sessions, enterprise desktop configuration, MDM policies, third-party providers in VS Code, resume remote sessions, or any Claude Code GUI/IDE/Desktop topic.
user-invocable: false
---

# IDE & Desktop Documentation

This skill provides the complete official documentation for Claude Code IDE integrations and the Desktop app -- the Desktop GUI (Code tab), VS Code extension, JetBrains plugin, and Chrome browser integration.

## Quick Reference

### Desktop App

The Desktop app provides a graphical interface for Claude Code via the **Code tab**. It supports macOS and Windows (not Linux). Requires a Pro, Max, Teams, or Enterprise subscription.

#### Key Capabilities

| Feature | Description |
|:--------|:------------|
| Visual diff review | Side-by-side diffs with inline comments; submit comments with Cmd/Ctrl+Enter |
| Live app preview | Embedded browser for dev servers; auto-verify after edits |
| PR monitoring | CI status polling via `gh` CLI; auto-fix failing checks, auto-merge on pass (squash) |
| Parallel sessions | Sidebar tabs, each in its own Git worktree (`.claude/worktrees/`) |
| Scheduled tasks | Recurring local sessions (manual/hourly/daily/weekdays/weekly) |
| Connectors | MCP-based integrations (GitHub, Slack, Linear, Notion, Calendar, etc.) |
| Remote sessions | Run on Anthropic cloud infrastructure; continue when app is closed |
| SSH sessions | Connect to remote machines; Claude Code must be installed on host |

#### Permission Modes

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Asks before each edit/command (default) |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits, asks for commands |
| Plan mode | `plan` | Analyzes and plans without modifying files |
| Bypass permissions | `bypassPermissions` | No prompts; enable in Settings; enterprise-disableable |

The `dontAsk` mode is CLI-only.

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
| `runtimeArgs` | string[] | Arguments for runtimeExecutable |
| `port` | number | Server port (default 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables |
| `autoPort` | boolean | `true`: auto-find free port; `false`: fail on conflict |
| `program` | string | Node.js script to run directly (alternative to runtimeExecutable) |
| `args` | string[] | Arguments for program |

#### Scheduled Tasks

Created via sidebar Schedule section or by asking Claude. Task config stored at `~/.claude/scheduled-tasks/<task-name>/SKILL.md`.

| Frequency | Behavior |
|:----------|:---------|
| Manual | On-demand only via Run now |
| Hourly | Every hour (with staggered offset up to 10 min) |
| Daily | At specified time (default 9:00 AM local) |
| Weekdays | Daily excluding Saturday/Sunday |
| Weekly | At specified time and day |

Tasks run locally; app must be open and computer awake. Missed runs: one catch-up run on wake (most recent missed time within 7 days).

#### CLI Flag Equivalents in Desktop

| CLI flag | Desktop equivalent |
|:---------|:-------------------|
| `--model sonnet` | Model dropdown next to send button |
| `--resume` / `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (enable in Settings) |
| `--add-dir` | **+** button in remote sessions |
| `/desktop` | CLI command to move session to Desktop |

#### Enterprise Configuration

- Admin console: enable/disable Code tab, disable Bypass mode, disable remote sessions
- Managed settings: `disableBypassPermissionsMode`, `allowManagedPermissionRulesOnly`, `allowManagedHooksOnly`
- MDM: macOS via `com.anthropic.Claude` preference domain; Windows via `SOFTWARE\Policies\Claude` registry
- Deployment: macOS via `.dmg` + MDM (Jamf/Kandji); Windows via MSIX or `.exe`

### VS Code Extension

Native graphical interface for Claude Code in VS Code (1.98.0+) and Cursor.

#### Install

- [Install for VS Code](vscode:extension/anthropic.claude-code) or [Cursor](cursor:extension/anthropic.claude-code)
- Or: Extensions view (`Cmd+Shift+X`) > search "Claude Code" > Install

#### Key Features

| Feature | Details |
|:--------|:--------|
| @-mentions | `@filename` with fuzzy matching; `@file.ts#5-10` for line ranges |
| Selection context | Highlighted text auto-shared; `Option+K` / `Alt+K` inserts @-mention |
| Permission modes | Normal, Plan, Auto-accept; set via prompt box or `claudeCode.initialPermissionMode` |
| `/` command menu | Attach files, switch models, toggle extended thinking, `/usage`, `/compact` |
| Multiple conversations | Open in New Tab (`Cmd+Shift+Esc`) or New Window |
| Terminal mode | Enable `claudeCode.useTerminal` for CLI-style interface |
| Plugin management | `/plugins` to install, enable, disable plugins with scope selection |
| Chrome automation | `@browser` to connect to Claude in Chrome extension |
| Checkpoints | Hover message for rewind: fork conversation, rewind code, or both |
| Remote session resume | Past Conversations > Remote tab for claude.ai web sessions |
| @terminal:name | Reference terminal output in prompts |

#### VS Code Commands & Shortcuts

| Command | Shortcut | Description |
|:--------|:---------|:------------|
| Focus Input | `Cmd+Esc` / `Ctrl+Esc` | Toggle focus editor <-> Claude |
| Open in New Tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | New conversation as editor tab |
| New Conversation | `Cmd+N` / `Ctrl+N` | Start new conversation (Claude focused) |
| Insert @-Mention | `Option+K` / `Alt+K` | Insert file+line reference (editor focused) |
| Show Logs | -- | View extension debug logs |

#### Extension Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | CLI-style interface instead of panel |
| `initialPermissionMode` | `default` | Default permission mode |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter to send |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from searches |
| `allowDangerouslySkipPermissions` | `false` | Enable bypass permissions |

#### CLI in VS Code

- Run `claude` in integrated terminal for full CLI access
- External terminal: run `/ide` to connect to VS Code
- Share history: `claude --resume` picks up extension conversations
- Git worktrees: `claude --worktree feature-auth` for isolated branches

#### Third-Party Providers in VS Code

1. Disable login prompt: check `claudeCode.disableLoginPrompt`
2. Configure provider in `~/.claude/settings.json` (Bedrock, Vertex AI, or Foundry)

### JetBrains Plugin

Works with IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand, and other JetBrains IDEs.

#### Install

Install [Claude Code plugin](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-) from JetBrains Marketplace. Restart IDE after installation.

#### Features & Shortcuts

| Feature | Shortcut | Details |
|:--------|:---------|:--------|
| Quick launch | `Cmd+Esc` / `Ctrl+Esc` | Open Claude Code from editor |
| File references | `Cmd+Option+K` / `Alt+Ctrl+K` | Insert @File#L1-99 references |
| Diff viewing | -- | Changes displayed in IDE diff viewer |
| Selection context | -- | Current selection/tab auto-shared |
| Diagnostic sharing | -- | Lint/syntax errors auto-shared |

#### Plugin Settings (Settings > Tools > Claude Code)

- **Claude command**: custom command path (e.g., `/usr/local/bin/claude`, `npx @anthropic/claude`)
- **WSL**: set `wsl -d Ubuntu -- bash -lic "claude"` as Claude command
- **Option+Enter**: toggle for multi-line prompts (macOS)
- **Auto-updates**: check for plugin updates automatically

#### Special Configurations

- **Remote Development**: install plugin on remote host via Settings > Plugin (Host)
- **WSL**: may need terminal config, networking, and firewall adjustments
- **ESC key**: if ESC does not interrupt, uncheck "Move focus to the editor with Escape" in Settings > Tools > Terminal

### Chrome Integration (Beta)

Browser automation via the Claude in Chrome extension. Works with Google Chrome and Microsoft Edge. Not supported on Brave, Arc, or WSL.

#### Prerequisites

- Chrome or Edge browser
- [Claude in Chrome extension](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) v1.0.36+
- Claude Code v2.0.73+
- Direct Anthropic plan (not available via Bedrock/Vertex/Foundry)

#### Setup

- CLI: `claude --chrome` or `/chrome` within a session
- VS Code: `@browser` in prompt box
- Enable by default: run `/chrome` and select "Enabled by default"

#### Capabilities

| Capability | Example |
|:-----------|:--------|
| Live debugging | Read console errors, fix code that caused them |
| Design verification | Build UI, open in browser to verify against mockup |
| Web app testing | Test forms, check visual regressions, verify user flows |
| Authenticated apps | Interact with Google Docs, Gmail, Notion (shares login state) |
| Data extraction | Pull structured data from pages, save as CSV |
| Form automation | Read local file, fill forms on web apps |
| Session recording | Record interactions as GIF files |

#### Native Messaging Host Paths

**Chrome:**
- macOS: `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Linux: `~/.config/google-chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`

**Edge:**
- macOS: `~/Library/Application Support/Microsoft Edge/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Linux: `~/.config/microsoft-edge/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`

#### Common Errors

| Error | Fix |
|:------|:----|
| "Browser extension is not connected" | Restart Chrome and Claude Code, run `/chrome` to reconnect |
| "Extension not detected" | Install/enable extension in `chrome://extensions` |
| "No tab available" | Ask Claude to create a new tab and retry |
| "Receiving end does not exist" | Run `/chrome` > "Reconnect extension" (service worker went idle) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- full Desktop app reference: session setup, permission modes (Ask/Auto-accept/Plan/Bypass), prompt box and @mentions, preview servers with .claude/launch.json config (fields, autoVerify, autoPort, examples), diff view with inline comments, code review, PR monitoring with auto-fix and auto-merge, parallel sessions with worktrees, remote cloud sessions, SSH sessions, connectors, skills, plugins, scheduled tasks (frequency options, missed runs, permissions), environment configuration (local/remote/SSH), enterprise configuration (admin console, managed settings, MDM policies, deployment), CLI comparison (flag equivalents, shared config, feature comparison), troubleshooting
- [Desktop Quickstart](references/claude-code-desktop-quickstart.md) -- install Desktop on macOS/Windows, Code tab setup, first session walkthrough (environment, folder, model, permissions), review changes with diff, tips for interrupt/steer, @mentions, skills, diff review, permission modes, plugins, preview, PR monitoring, scheduled tasks, parallel sessions, CLI comparison
- [VS Code Extension](references/claude-code-vs-code.md) -- install for VS Code/Cursor, Spark icon locations, prompt box features (permission modes, / command menu, context indicator, extended thinking, multi-line), @-mentions with fuzzy matching and line ranges, resume past conversations, resume remote sessions from claude.ai, panel positioning, multiple conversations, terminal mode, plugin management (/plugins with install/scope/marketplace), Chrome browser automation (@browser), VS Code commands and shortcuts table, extension settings table, CLI vs extension feature comparison, checkpoints (fork/rewind), CLI in VS Code (/ide, --resume), @terminal:name, MCP server management (/mcp), git worktrees, third-party provider setup, security considerations, troubleshooting
- [JetBrains Plugin](references/claude-code-jetbrains.md) -- supported IDEs list, features (quick launch, diff viewing, selection context, file references, diagnostics), marketplace installation, usage from IDE terminal and external terminals (/ide), plugin settings (Claude command, ESC key, Option+Enter, auto-updates, WSL command), remote development (install on host), WSL configuration, troubleshooting (plugin not working, IDE not detected, command not found), security considerations
- [Chrome Integration](references/claude-code-chrome.md) -- prerequisites (Chrome/Edge, extension version, Claude Code version, plan requirements), CLI setup (--chrome flag, /chrome command), VS Code setup (@browser), enable by default, site permissions, example workflows (test local app, debug console, automate forms, draft in Google Docs, extract data, multi-site workflows, record GIF), native messaging host paths (Chrome/Edge on macOS/Linux/Windows), troubleshooting (extension not detected, browser not responding, connection drops, Windows issues, common error messages)

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Desktop Quickstart: https://code.claude.com/docs/en/desktop-quickstart.md
- VS Code Extension: https://code.claude.com/docs/en/vs-code.md
- JetBrains Plugin: https://code.claude.com/docs/en/jetbrains.md
- Chrome Integration: https://code.claude.com/docs/en/chrome.md
