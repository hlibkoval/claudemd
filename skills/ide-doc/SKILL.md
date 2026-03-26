---
name: ide-doc
description: Complete documentation for Claude Code IDE and desktop integrations -- Desktop app (Code tab with visual diff review, live app preview, computer use on macOS, GitHub PR monitoring with auto-fix/auto-merge, parallel sessions with Git worktree isolation, Dispatch integration, scheduled tasks with local/remote/cloud options, connectors for GitHub/Slack/Linear/Notion, SSH sessions, remote cloud sessions, permission modes default/acceptEdits/plan/auto/bypassPermissions, .claude/launch.json preview server configuration with autoVerify/autoPort/runtimeExecutable/program fields, enterprise configuration with admin console/managed settings/MDM policies, CLI comparison and shared configuration), Desktop quickstart (install macOS/Windows, Code/Chat/Cowork tabs, first session workflow with environment/folder/model/permission mode selection, @mention files and attachments, skills and plugins), VS Code extension (install for VS Code and Cursor, graphical chat panel, permission modes default/plan/acceptEdits/auto, @-mention files with fuzzy matching and line ranges, Option+K/Alt+K for selection references, @terminal:name for terminal output, past conversation history with Local/Remote tabs, resume remote sessions from claude.ai, multiple conversations via Open in New Tab/New Window, terminal mode toggle, plugin management with /plugins, Chrome browser automation with @browser, URI handler vscode://anthropic.claude-code/open with prompt/session parameters, extension settings selectedModel/useTerminal/initialPermissionMode/preferredLocation/autosave/useCtrlEnterToSend/respectGitIgnore/environmentVariables/disableLoginPrompt/allowDangerouslySkipPermissions/claudeProcessWrapper, VS Code commands Cmd+Esc/Ctrl+Esc focus toggle and Cmd+Shift+Esc/Ctrl+Shift+Esc new tab, checkpoints with fork/rewind options, built-in IDE MCP server with mcp__ide__getDiagnostics and mcp__ide__executeCode tools, third-party provider setup for Bedrock/Vertex/Foundry, git worktrees with -w flag), JetBrains plugin (IntelliJ/PyCharm/WebStorm/GoLand/PhpStorm/Android Studio, Cmd+Esc/Ctrl+Esc quick launch, diff viewing, selection context, Cmd+Option+K/Alt+Ctrl+K file references, diagnostic sharing, marketplace installation, /ide command for external terminals, plugin settings claude command path/Option+Enter multi-line/automatic updates, ESC key configuration, remote development host installation, WSL configuration), Chrome extension (beta for Chrome and Edge, --chrome flag or /chrome command, @browser in VS Code, browser automation capabilities including live debugging/design verification/web app testing/authenticated apps/data extraction/task automation/GIF recording, site permissions from Chrome extension, native messaging host configuration paths, troubleshooting extension detection/browser response/connection drops/Windows named pipe conflicts). Load when discussing Claude Code Desktop app, Code tab, desktop quickstart, VS Code extension, JetBrains plugin, Chrome browser integration, IDE integration, diff view, app preview, computer use, PR monitoring, parallel sessions, worktrees, scheduled tasks, connectors, SSH sessions, remote sessions, Dispatch, permission modes in desktop, launch.json, preview servers, autoVerify, enterprise desktop configuration, MDM policies, VS Code settings, @-mentions in VS Code, checkpoints, IDE MCP server, mcp__ide__getDiagnostics, mcp__ide__executeCode, /ide command, @browser, --chrome flag, Chrome automation, or any IDE/desktop integration topic for Claude Code.
user-invocable: false
---

# IDE & Desktop Documentation

This skill provides the complete official documentation for Claude Code IDE and desktop integrations -- the Desktop app, VS Code extension, JetBrains plugin, and Chrome browser integration.

## Quick Reference

### Platform Overview

| Surface | Platform | Install method | Key capability |
|:--------|:---------|:---------------|:---------------|
| **Desktop app** | macOS, Windows | DMG / EXE download | Visual diff review, app preview, computer use, PR monitoring, scheduled tasks |
| **VS Code extension** | VS Code 1.98+, Cursor | Marketplace (`anthropic.claude-code`) | Graphical chat panel, inline diffs, @-mentions, checkpoints |
| **JetBrains plugin** | IntelliJ, PyCharm, WebStorm, GoLand, PhpStorm, Android Studio | JetBrains Marketplace | Diff viewing, selection context, diagnostic sharing |
| **Chrome extension** | Chrome, Edge | Chrome Web Store (`claude`) | Browser automation, live debugging, data extraction |

### Desktop App

#### Tabs

| Tab | Purpose | File access |
|:----|:--------|:------------|
| **Chat** | General conversation (like claude.ai) | No |
| **Cowork** | Autonomous background agent on cloud VM | Cloud clone |
| **Code** | Interactive coding assistant | Local files |

#### Permission Modes

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Asks before editing files or running commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits, asks for terminal commands |
| Plan mode | `plan` | Analyzes and plans without modifying files |
| Auto | `auto` | Background safety checks, reduced prompts (Team plans, Sonnet 4.6/Opus 4.6) |
| Bypass permissions | `bypassPermissions` | No prompts; sandboxed environments only |

#### Environment Types

| Type | Runs on | Continues when app closed | Local file access |
|:-----|:--------|:--------------------------|:------------------|
| **Local** | Your machine | No | Yes |
| **Remote** | Anthropic cloud | Yes | No (fresh clone) |
| **SSH** | Your remote machine | No | Yes (remote files) |

#### Preview Server Configuration (`.claude/launch.json`)

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments (e.g., `["run", "dev"]`) |
| `port` | number | Server port (default 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables |
| `autoPort` | boolean | `true`: find free port; `false`: fail on conflict; unset: ask |
| `program` | string | Script to run with `node` |
| `args` | string[] | Arguments for `program` |
| `autoVerify` | boolean | Auto-verify changes after edits (default `true`) |

#### Scheduled Tasks Comparison

| Feature | Cloud | Desktop (local) | `/loop` (CLI) |
|:--------|:------|:----------------|:--------------|
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Persistent across restarts | Yes | Yes | No |
| Access to local files | No | Yes | Yes |
| Minimum interval | 1 hour | 1 minute | 1 minute |

#### Computer Use (macOS, Pro/Max only)

Access tiers by app category:

| Tier | Capability | Applies to |
|:-----|:-----------|:-----------|
| View only | Screenshots only | Browsers, trading platforms |
| Click only | Click and scroll, no typing | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

Requires Accessibility and Screen Recording macOS permissions.

#### Enterprise Configuration

| Control | Scope |
|:--------|:------|
| Admin console | Code in desktop, Code in web, Remote Control, Bypass permissions |
| `permissions.disableBypassPermissionsMode` | Managed settings |
| `disableAutoMode` | Managed settings |
| `autoMode` | User settings, `.claude/settings.local.json`, managed settings |
| MDM (macOS) | `com.anthropic.Claude` preference domain |
| Group Policy (Windows) | `SOFTWARE\Policies\Claude` registry |

#### CLI Flag Equivalents in Desktop

| CLI flag | Desktop equivalent |
|:---------|:-------------------|
| `--model sonnet` | Model dropdown next to send button |
| `--resume`, `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (Settings) |
| `--add-dir` | **+** button in remote sessions |

### VS Code Extension

#### Key Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | Terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, `auto`, or `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Ctrl/Cmd+Enter to send instead of Enter |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from searches |
| `disableLoginPrompt` | `false` | Skip auth prompts (third-party providers) |
| `allowDangerouslySkipPermissions` | `false` | Show Auto and Bypass in mode selector |
| `claudeProcessWrapper` | - | Executable path to launch Claude process |

#### Keyboard Shortcuts

| Command | Shortcut (Mac / Win+Linux) | Description |
|:--------|:---------------------------|:------------|
| Focus Input | `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| Open in New Tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | New conversation as editor tab |
| New Conversation | `Cmd+N` / `Ctrl+N` | Start new conversation (Claude focused) |
| Insert @-Mention | `Option+K` / `Alt+K` | Insert file + selection reference (editor focused) |

#### Built-in IDE MCP Server

| Tool | What it does | Writes |
|:-----|:-------------|:-------|
| `mcp__ide__getDiagnostics` | Returns VS Code Problems panel errors/warnings | No |
| `mcp__ide__executeCode` | Runs Python in active Jupyter notebook kernel | Yes (with Quick Pick confirmation) |

The server binds to `127.0.0.1` on a random port with a fresh auth token per activation, stored in `~/.claude/ide/` with `0600` permissions.

#### URI Handler

```
vscode://anthropic.claude-code/open?prompt=<url-encoded>&session=<id>
```

Open with `open` (macOS), `xdg-open` (Linux), or `start` (Windows).

#### Checkpoint Actions

| Action | Effect |
|:-------|:-------|
| Fork conversation from here | New branch, keeps code changes |
| Rewind code to here | Revert files, keep conversation |
| Fork conversation and rewind code | New branch and revert files |

### JetBrains Plugin

#### Supported IDEs

IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand

#### Key Shortcuts

| Action | Mac | Windows/Linux |
|:-------|:----|:--------------|
| Open Claude Code | `Cmd+Esc` | `Ctrl+Esc` |
| Insert file reference | `Cmd+Option+K` | `Alt+Ctrl+K` |

#### Plugin Settings (Settings > Tools > Claude Code)

| Setting | Description |
|:--------|:------------|
| Claude command | Custom command path (e.g., `claude`, `/usr/local/bin/claude`) |
| Suppress notification | Skip "command not found" notifications |
| Enable Option+Enter | Multi-line prompts in terminal (macOS) |
| Enable automatic updates | Auto-check and install updates |

WSL users: set Claude command to `wsl -d Ubuntu -- bash -lic "claude"`.

Remote Development: install the plugin on the remote host via Settings > Plugin (Host).

### Chrome Integration (Beta)

#### Setup

1. Install [Claude in Chrome extension](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) v1.0.36+
2. Start Claude Code with `--chrome` flag, or run `/chrome` in session
3. Enable by default: run `/chrome` and select "Enabled by default"
4. In VS Code: use `@browser` in prompt (no flag needed)

#### Capabilities

| Capability | Example |
|:-----------|:--------|
| Live debugging | Read console errors, fix causing code |
| Design verification | Build UI, open browser to verify |
| Web app testing | Test form validation, user flows |
| Authenticated apps | Interact with Google Docs, Gmail, Notion |
| Data extraction | Pull structured data, save as CSV |
| Task automation | Form filling, multi-site workflows |
| Session recording | Record interactions as GIF |

#### Supported Browsers

Chrome, Microsoft Edge. Not supported: Brave, Arc, other Chromium browsers. WSL not supported.

#### Native Messaging Host Paths

| Browser | macOS | Linux |
|:--------|:------|:------|
| Chrome | `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/` | `~/.config/google-chrome/NativeMessagingHosts/` |
| Edge | `~/Library/Application Support/Microsoft Edge/NativeMessagingHosts/` | `~/.config/microsoft-edge/NativeMessagingHosts/` |

Windows: check `HKCU\Software\Google\Chrome\NativeMessagingHosts\` or `HKCU\Software\Microsoft\Edge\NativeMessagingHosts\` in Registry.

#### Troubleshooting

| Issue | Fix |
|:------|:----|
| Extension not detected | Restart Chrome and Claude Code, run `/chrome` to reconnect |
| Browser not responding | Dismiss any modal dialog, ask Claude to create new tab |
| Connection drops | Run `/chrome` > "Reconnect extension" |
| Named pipe conflicts (Windows) | Restart Claude Code, close other sessions |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- full desktop app reference covering permission modes (default/acceptEdits/plan/auto/bypassPermissions), visual diff review with inline comments, live app preview with autoVerify, computer use on macOS (view-only/click-only/full-control tiers, Accessibility and Screen Recording permissions, Dispatch integration), GitHub PR monitoring with auto-fix and auto-merge, parallel sessions with Git worktree isolation, remote cloud sessions, SSH sessions, connectors for external tools (GitHub/Slack/Linear/Notion), skills and plugins in desktop, preview server configuration (.claude/launch.json with runtimeExecutable/runtimeArgs/port/cwd/env/autoPort/program/args fields, autoVerify setting, port conflict handling), scheduled tasks (local vs remote, frequency options hourly/daily/weekdays/weekly/manual, missed run catch-up, task permissions, SKILL.md on disk), environment configuration (local/remote/SSH), enterprise configuration (admin console controls, managed settings disableBypassPermissionsMode/disableAutoMode/autoMode, MDM policies for macOS com.anthropic.Claude and Windows SOFTWARE\Policies\Claude, SSO, deployment), CLI comparison (flag equivalents, shared configuration via CLAUDE.md/MCP/.claude settings, feature matrix), troubleshooting (403 errors, blank screen, failed sessions, Git/Git LFS errors, MCP on Windows)
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) -- desktop quickstart covering installation (macOS DMG, Windows EXE, no Linux), sign-in, Code tab activation, Chat/Cowork/Code tabs overview, first session workflow (choose environment Local/Remote/SSH, select folder, choose model, send prompt, review and accept changes with diff view), next steps (interrupt and steer, @mention files and attachments, skills via / commands, diff review with +12 -1 indicator and inline comments, permission mode adjustment, plugins via + button, app preview, PR monitoring with auto-fix/auto-merge, scheduled tasks, parallel sessions with sidebar, Continue in another surface, CLI comparison)
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) -- VS Code extension reference covering installation (VS Code 1.98+, Cursor support), graphical panel with Spark icon (Editor Toolbar, Activity Bar, Command Palette, Status Bar), prompt box features (permission modes, / command menu, context indicator, extended thinking, multi-line with Shift+Enter), @-mention files with fuzzy matching and line ranges (Option+K/Alt+K for selection references, Shift+drag attachments), past conversation history with Local/Remote tabs (resume remote sessions from claude.ai), panel customization (secondary sidebar, primary sidebar, editor area), multiple conversations (Open in New Tab/New Window, colored dot status indicators), terminal mode toggle (useTerminal setting), plugin management (/plugins with Install/Marketplaces tabs, scope selection), Chrome browser automation (@browser, Claude in Chrome extension), VS Code commands and shortcuts (Cmd+Esc/Ctrl+Esc focus toggle, Cmd+Shift+Esc/Ctrl+Shift+Esc new tab, Cmd+N/Ctrl+N new conversation, Option+K/Alt+K @-mention), URI handler (vscode://anthropic.claude-code/open with prompt/session parameters), extension settings (selectedModel, useTerminal, initialPermissionMode, preferredLocation, autosave, useCtrlEnterToSend, respectGitIgnore, disableLoginPrompt, allowDangerouslySkipPermissions, claudeProcessWrapper), CLI comparison (feature matrix, checkpoints fork/rewind, terminal CLI, --resume shared history, @terminal:name references), built-in IDE MCP server (mcp__ide__getDiagnostics and mcp__ide__executeCode tools, 127.0.0.1 binding, auth token in ~/.claude/ide/, Jupyter Quick Pick confirmation), git integration (commits, PRs, worktrees with -w flag), third-party provider setup (Bedrock/Vertex/Foundry via disableLoginPrompt + settings.json), security considerations, troubleshooting
- [JetBrains IDEs](references/claude-code-jetbrains.md) -- JetBrains plugin reference covering supported IDEs (IntelliJ, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand), features (Cmd+Esc/Ctrl+Esc quick launch, diff viewing, selection context sharing, Cmd+Option+K/Alt+Ctrl+K file references, diagnostic sharing), marketplace installation, usage from IDE terminal and external terminals (/ide command), plugin settings (claude command path, suppress notifications, Option+Enter multi-line, automatic updates), ESC key configuration for JetBrains terminals, WSL configuration (terminal/networking/firewall), remote development (install on remote host), troubleshooting (plugin not working, IDE not detected, command not found), security considerations for auto-edit mode
- [Use Claude Code with Chrome](references/claude-code-chrome.md) -- Chrome integration (beta) covering capabilities (live debugging, design verification, web app testing, authenticated web apps, data extraction, task automation, GIF session recording), prerequisites (Chrome or Edge browser, Claude in Chrome extension v1.0.36+, Claude Code v2.0.73+, direct Anthropic plan), CLI setup (--chrome flag, /chrome command, enable by default), VS Code setup (@browser in prompt), site permissions from Chrome extension, example workflows (test local app, debug console, automate forms, draft in Google Docs, extract data, multi-site workflows, record demo GIF), troubleshooting (extension not detected with native messaging host paths for Chrome/Edge on macOS/Linux/Windows, browser not responding due to modal dialogs, connection drops from idle service worker, Windows named pipe conflicts), common error messages table

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
