---
name: ide-doc
description: Complete documentation for Claude Code IDE integrations -- Desktop app (Code tab with visual diff review, live app preview, PR monitoring with auto-fix/auto-merge, parallel sessions with Git worktree isolation, scheduled tasks, connectors, SSH/remote/local environments, permission modes, enterprise configuration, device management policies, .claude/launch.json preview server config with autoVerify/autoPort/cwd/env fields), VS Code extension (installation, prompt box with permission modes and /commands, @-mentions with fuzzy matching and line ranges, plan review, multiple conversations in tabs/windows, terminal mode toggle, plugin management UI, Chrome browser automation via @browser, VS Code commands and keyboard shortcuts, extension settings like selectedModel/useTerminal/initialPermissionMode/preferredLocation/autosave, built-in IDE MCP server with getDiagnostics and executeCode tools, checkpoints with fork/rewind options, resuming remote sessions from claude.ai, third-party provider setup, security considerations), JetBrains plugin (IntelliJ/PyCharm/WebStorm/GoLand/PhpStorm/Android Studio, quick launch Cmd+Esc, diff viewing, selection context, file reference shortcuts Cmd+Option+K, diagnostic sharing, marketplace installation, /ide command for external terminals, plugin settings with custom claude command, ESC key configuration, remote development host-side install, WSL configuration), and Chrome extension integration (beta, browser automation from CLI with --chrome flag or /chrome command, live debugging, design verification, web app testing, authenticated web app interaction, data extraction, task automation, GIF recording, site-level permissions, native messaging host configuration, troubleshooting connection issues). Load when discussing Claude Code Desktop, Desktop app, Code tab, VS Code extension, JetBrains plugin, IntelliJ, PyCharm, WebStorm, IDE integration, diff view, app preview, PR monitoring, auto-fix, auto-merge, parallel sessions, worktrees, scheduled tasks, connectors, SSH sessions, remote sessions, permission modes, launch.json, preview servers, autoVerify, @-mentions, plan mode, plugin management, Chrome automation, @browser, IDE MCP server, getDiagnostics, executeCode, checkpoints, extension settings, selectedModel, useTerminal, initialPermissionMode, /ide command, diagnostic sharing, file references, enterprise configuration, device management, MDM, or browser extension.
user-invocable: false
---

# IDE Integration Documentation

This skill provides the complete official documentation for using Claude Code across Desktop, VS Code, JetBrains IDEs, and Chrome browser integration.

## Quick Reference

Claude Code runs in four IDE surfaces: the **Desktop app** (graphical Code tab), the **VS Code extension**, **JetBrains plugin**, and **Chrome browser** integration. All share the same underlying engine, configuration (CLAUDE.md, settings, MCP servers, hooks, skills), and conversation history.

### Desktop App (Code Tab)

The Desktop app provides a full graphical interface for Claude Code with features not available in the CLI.

#### Session Setup

Configure four things before sending your first message:

| Setting | Options |
|:--------|:--------|
| Environment | Local (your machine), Remote (Anthropic cloud), SSH (your remote server) |
| Project folder | Select the folder/repo Claude works in |
| Model | Sonnet, Opus, or Haiku (locked once session starts) |
| Permission mode | Ask permissions, Auto accept edits, Plan mode, Bypass permissions |

#### Permission Modes

| Mode | Key | Behavior |
|:-----|:----|:---------|
| Ask permissions | `default` | Asks before editing files or running commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits, asks before terminal commands |
| Plan mode | `plan` | Analyzes code and creates a plan without modifying anything |
| Bypass permissions | `bypassPermissions` | No permission prompts (enable in Settings; enterprise-restrictable) |

The `dontAsk` mode is CLI-only.

#### Live App Preview

Claude can start dev servers and verify changes in an embedded browser. Preview configuration lives in `.claude/launch.json`:

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

**Configuration fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique identifier for this server |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments passed to the executable |
| `port` | number | Server port (default: 3000) |
| `cwd` | string | Working directory relative to project root; supports `${workspaceFolder}` |
| `env` | object | Additional environment variables (key-value pairs) |
| `autoPort` | boolean | `true` = find free port; `false` = fail on conflict; unset = ask |
| `program` | string | Script to run with `node` (alternative to runtimeExecutable) |
| `args` | string[] | Arguments for `program` |

Top-level `autoVerify` (default: `true`) makes Claude auto-verify changes after every edit.

#### PR Monitoring

After opening a PR, a CI status bar appears with toggles:
- **Auto-fix**: Claude reads failure output and iterates on fixes
- **Auto-merge**: Claude squash-merges once all checks pass (requires GitHub repo setting enabled)

Requires `gh` CLI installed and authenticated.

#### Parallel Sessions and Worktrees

Click **+ New session** in the sidebar. Each session gets its own Git worktree at `<project-root>/.claude/worktrees/`. Configurable worktree location and branch prefix in Settings.

#### Scheduled Tasks

Recurring tasks that start new local sessions automatically.

| Field | Description |
|:------|:------------|
| Name | Kebab-case identifier (folder name on disk) |
| Description | Short summary in task list |
| Prompt | Instructions sent to Claude each run |
| Frequency | Manual, Hourly, Daily, Weekdays, or Weekly |

Tasks run locally (app must be open, computer awake). Missed runs get one catch-up run on wake (most recent missed time, within 7 days). Each task has its own permission mode. Task files at `~/.claude/scheduled-tasks/<task-name>/SKILL.md`.

#### SSH Sessions

Connect to remote machines: click environment dropdown, select **+ Add SSH connection**. Provide name, SSH host (`user@hostname` or `~/.ssh/config` entry), port, and identity file. Claude Code must be installed on the remote machine.

#### Continue in Another Surface

From the VS Code icon in the session toolbar: **Claude Code on the Web** (pushes branch, generates summary, creates remote session) or **Your IDE** (opens project in supported IDE).

#### Enterprise Configuration

| Control | Scope |
|:--------|:------|
| Admin console | Enable/disable Code tab, disable Bypass permissions, disable web sessions |
| Managed settings | `disableBypassPermissionsMode`, `allowManagedPermissionRulesOnly`, `allowManagedHooksOnly` |
| Device management | macOS MDM (`com.anthropic.Claude`), Windows registry (`SOFTWARE\Policies\Claude`) |

#### CLI Flag Equivalents in Desktop

| CLI Flag | Desktop Equivalent |
|:---------|:-------------------|
| `--model sonnet` | Model dropdown next to send button |
| `--resume`, `--continue` | Click a session in the sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (Settings) |
| `--add-dir` | **+** button in remote sessions |
| `--allowedTools`, `--disallowedTools` | Not available |
| `--verbose` | Not available (use Console.app / Event Viewer) |
| `--print`, `--output-format` | Not available (Desktop is interactive only) |

#### Desktop Troubleshooting

| Issue | Fix |
|:------|:----|
| 403 / auth errors | Sign out and back in; verify paid subscription |
| Blank/stuck screen | Restart app; check for pending updates |
| "Failed to load session" | Folder may not exist; check Git LFS; check permissions |
| Tools not found (`npm`, `node`) | Verify in terminal; check shell PATH; restart app |
| Git required (Windows) | Install Git for Windows, restart app |

---

### VS Code Extension

The recommended graphical interface for Claude Code in VS Code (1.98.0+). Also works with Cursor.

#### Opening Claude Code

| Method | Description |
|:-------|:------------|
| Editor Toolbar | Spark icon in top-right corner (requires file open) |
| Activity Bar | Spark icon in left sidebar (always visible) |
| Command Palette | `Cmd+Shift+P` / `Ctrl+Shift+P`, type "Claude Code" |
| Status Bar | Click "Claude Code" in bottom-right corner |

#### Keyboard Shortcuts

| Command | Shortcut | Description |
|:--------|:---------|:------------|
| Focus Input | `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| Open in New Tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | Open new conversation as editor tab |
| New Conversation | `Cmd+N` / `Ctrl+N` | Start new conversation (Claude focused) |
| Insert @-Mention | `Option+K` / `Alt+K` | Insert file reference with line numbers (editor focused) |

#### Prompt Box Features

- **Permission modes**: click mode indicator at bottom (normal, Plan, auto-accept)
- **Command menu**: type `/` for models, extended thinking, `/usage`, `/remote-control`, MCP, hooks, plugins
- **Context indicator**: shows context window usage; auto-compacts or use `/compact`
- **Extended thinking**: toggle via `/` command menu
- **Multi-line input**: `Shift+Enter` for new line

#### @-Mentions and File References

Type `@` followed by filename for fuzzy matching. Supports folders (trailing slash), line ranges (`@app.ts#5-10`), and specific PDF pages. `Shift+drag` files into prompt box to attach. Claude auto-sees selected text; press `Option+K`/`Alt+K` to insert reference. Terminal output via `@terminal:name`.

#### Extension Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | CLI mode instead of graphical panel |
| `initialPermissionMode` | `default` | Default approval mode (`default`, `plan`, `acceptEdits`, `bypassPermissions`) |
| `preferredLocation` | `panel` | Where Claude opens: `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Ctrl/Cmd+Enter to send instead of Enter |
| `enableNewConversationShortcut` | `true` | Enable Cmd/Ctrl+N shortcut |
| `hideOnboarding` | `false` | Hide the onboarding checklist |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from searches |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party providers) |
| `allowDangerouslySkipPermissions` | `false` | Enable bypass permissions mode |
| `claudeProcessWrapper` | - | Custom executable for launching Claude |

#### Built-in IDE MCP Server

The extension runs a local MCP server named `ide` on `127.0.0.1` (random high port, fresh auth token per activation, `~/.claude/ide/` lock file with `0600` permissions).

| Tool | Description | Writes? |
|:-----|:------------|:--------|
| `mcp__ide__getDiagnostics` | Returns VS Code Problems panel diagnostics, optionally scoped to one file | No |
| `mcp__ide__executeCode` | Runs Python in active Jupyter notebook kernel (Quick Pick confirmation required) | Yes |

Other tools are internal RPC (diffs, selections, saves) and hidden from the model. If using a `PreToolUse` hook allowlist, you need to know the `ide` server exists.

#### Checkpoints

Hover over any message for rewind options:
- **Fork conversation from here**: new branch, keep code changes
- **Rewind code to here**: revert files, keep conversation history
- **Fork conversation and rewind code**: new branch and revert files

#### Resuming Remote Sessions

Click **Past Conversations** dropdown, select **Remote** tab to see sessions from claude.ai. Only web sessions started with a GitHub repository appear. History is downloaded locally; changes are not synced back.

#### Plugin Management

Type `/plugins` to open the graphical plugin manager. Install plugins with scope choice (user, project, local). Manage marketplaces in the Marketplaces tab.

#### Chrome Browser Automation in VS Code

Type `@browser` in the prompt box followed by the task. Requires Claude in Chrome extension v1.0.36+. Claude opens new tabs and shares your browser login state.

#### Third-Party Providers in VS Code

1. Enable **Disable Login Prompt** setting
2. Configure provider in `~/.claude/settings.json` (Bedrock, Vertex, or Foundry)

#### VS Code vs CLI Feature Comparison

| Feature | CLI | VS Code Extension |
|:--------|:----|:------------------|
| Commands and skills | All | Subset (type `/` to see) |
| MCP server config | Yes | Partial (add via CLI, manage with `/mcp`) |
| Checkpoints | Yes | Yes |
| Bash shortcut (`!`) | Yes | No |
| Tab completion | Yes | No |

---

### JetBrains Plugin

Works with IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand.

#### Features

| Feature | Shortcut |
|:--------|:---------|
| Quick launch | `Cmd+Esc` (Mac) / `Ctrl+Esc` (Windows/Linux) |
| Insert file reference | `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Windows/Linux) |
| Diff viewing | Changes displayed in IDE diff viewer |
| Selection context | Current selection/tab auto-shared with Claude |
| Diagnostic sharing | Lint/syntax errors auto-shared |

#### Installation

Install from [JetBrains Marketplace](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-) and restart IDE. Requires Claude Code CLI installed separately.

#### Usage

- **From IDE terminal**: run `claude` in integrated terminal
- **From external terminal**: run `claude`, then `/ide` to connect to JetBrains

#### Plugin Settings (Settings > Tools > Claude Code)

| Setting | Description |
|:--------|:------------|
| Claude command | Custom command path (e.g., `/usr/local/bin/claude`) |
| Suppress command-not-found notification | Skip "command not found" alerts |
| Option+Enter for multi-line (macOS) | Use Option+Enter for new lines in prompts |
| Automatic updates | Check for and install plugin updates |

**WSL users**: set claude command to `wsl -d Ubuntu -- bash -lic "claude"`.

#### ESC Key Fix

If ESC doesn't interrupt Claude in JetBrains terminals: Settings > Tools > Terminal > uncheck "Move focus to the editor with Escape" or delete the "Switch focus to Editor" keybinding.

#### Special Configurations

- **Remote Development**: install plugin in the remote host via Settings > Plugin (Host)
- **WSL**: may require terminal, networking, and firewall adjustments

---

### Chrome Extension Integration (Beta)

Connect Claude Code to Chrome/Edge for browser automation. Requires Claude in Chrome extension v1.0.36+ and Claude Code v2.0.73+.

#### Getting Started (CLI)

```bash
claude --chrome
```

Or enable mid-session with `/chrome`. Enable by default via `/chrome` > "Enabled by default".

#### Capabilities

| Capability | Description |
|:-----------|:------------|
| Live debugging | Read console errors/DOM state, fix code |
| Design verification | Build UI, verify in browser against mockups |
| Web app testing | Form validation, visual regressions, user flows |
| Authenticated apps | Interact with Google Docs, Gmail, Notion (uses your login state) |
| Data extraction | Pull structured info from pages, save locally |
| Task automation | Form filling, multi-site workflows |
| Session recording | Record interactions as GIF |

#### Site Permissions

Inherited from Chrome extension settings. Manage which sites Claude can browse, click, and type on.

#### Native Messaging Host Paths

**Chrome:**

| OS | Path |
|:---|:-----|
| macOS | `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` |
| Linux | `~/.config/google-chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` |
| Windows | Registry: `HKCU\Software\Google\Chrome\NativeMessagingHosts\` |

**Edge:**

| OS | Path |
|:---|:-----|
| macOS | `~/Library/Application Support/Microsoft Edge/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` |
| Linux | `~/.config/microsoft-edge/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` |
| Windows | Registry: `HKCU\Software\Microsoft\Edge\NativeMessagingHosts\` |

#### Chrome Troubleshooting

| Error | Fix |
|:------|:----|
| "Browser extension is not connected" | Restart Chrome and Claude Code, run `/chrome` to reconnect |
| "Extension not detected" | Install/enable extension in `chrome://extensions` |
| "No tab available" | Ask Claude to create a new tab and retry |
| "Receiving end does not exist" | Run `/chrome` > "Reconnect extension" (service worker went idle) |
| Browser not responding | Dismiss any modal dialogs (alert/confirm/prompt) blocking the page |

Not supported: Brave, Arc, or other Chromium browsers. WSL not supported.

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- full Desktop app reference covering session setup (environment/folder/model/permission mode), working with code (prompt box, file context with @-mentions and attachments, permission modes with Ask/Auto accept/Plan/Bypass), live app preview (embedded browser, auto-verify, .claude/launch.json configuration fields, port conflicts with autoPort, multi-server and Node.js script examples), diff view (inline comments, Cmd+Enter to submit), code review (Review code button, high-signal issues only), PR monitoring (auto-fix and auto-merge toggles, gh CLI requirement), parallel sessions (sidebar, Git worktree isolation, worktree location/branch prefix settings), remote sessions (Anthropic cloud, multiple repos, continue on close), Continue in (web handoff, IDE handoff), connectors (Google Calendar/Slack/GitHub/Linear/Notion, MCP servers under the hood), skills (/ commands, plugin skills), plugins (browser UI, scopes), scheduled tasks (frequency options, missed runs catch-up, permissions, task management on disk), environment configuration (local shell inheritance, remote cloud, SSH connections), enterprise configuration (admin console, managed settings, device management MDM/group policy, SSO, data handling, deployment), CLI comparison (flag equivalents, shared config, feature comparison table), troubleshooting (version check, 403 errors, blank screen, failed session, tools not found, Git/LFS errors, MCP on Windows, app won't quit, Cowork on Intel Macs)
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) -- installation (macOS/Windows download, sign in, open Code tab), first session walkthrough (choose environment and folder, choose model, send prompt, review and accept changes), next steps (interrupt and steer, give context, use skills, review changes, permission modes, plugins, preview, PR tracking, scheduled tasks, parallel sessions), CLI comparison
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) -- prerequisites (VS Code 1.98.0+), installation (VS Code and Cursor links), getting started (open panel via Spark icon/Activity Bar/Command Palette/Status Bar, onboarding checklist, send prompt, review changes), prompt box (permission modes, command menu, context indicator, extended thinking, multi-line), @-mentions and file references (fuzzy matching, line ranges, PDF pages, selected text, Shift+drag attachments, terminal output), resume past conversations (keyword search, rename/remove), resume remote sessions from claude.ai (Remote tab), customization (panel positioning, multiple conversations in tabs/windows, terminal mode), plugin management (/plugins, install scopes, marketplace management), Chrome browser automation (@browser, extension requirement), VS Code commands and shortcuts table, extension settings (selectedModel, useTerminal, initialPermissionMode, preferredLocation, autosave, useCtrlEnterToSend, environmentVariables, disableLoginPrompt, allowDangerouslySkipPermissions, claudeProcessWrapper), VS Code vs CLI comparison (commands, MCP, checkpoints, bash shortcut, tab completion), checkpoints (fork/rewind/both), run CLI in VS Code (/ide, --resume), terminal output in prompts (@terminal:name), MCP server management (claude mcp add, /mcp dialog), Git workflows (commits, PRs, worktrees), third-party providers (disable login, configure Bedrock/Vertex/Foundry), security (data privacy, auto-edit risks, Restricted Mode), built-in IDE MCP server (127.0.0.1 random port, auth token, getDiagnostics and executeCode tools, Jupyter Quick Pick confirmation, PreToolUse hook awareness), troubleshooting (install issues, spark icon, unresponsive), uninstall
- [JetBrains IDEs](references/claude-code-jetbrains.md) -- supported IDEs (IntelliJ/PyCharm/Android Studio/WebStorm/PhpStorm/GoLand), features (quick launch Cmd+Esc, diff viewing, selection context, file references Cmd+Option+K, diagnostic sharing), marketplace installation, usage from IDE terminal and external terminals (/ide command), configuration (diff tool auto, plugin settings with custom command, ESC key fix for terminal focus), special configurations (Remote Development host-side install, WSL networking/firewall), troubleshooting (plugin not working, IDE not detected, command not found), security considerations (auto-edit risks with IDE config files)
- [Use Claude Code with Chrome](references/claude-code-chrome.md) -- beta status (Chrome and Edge only, no Brave/Arc/WSL), capabilities (live debugging, design verification, web app testing, authenticated apps, data extraction, task automation, GIF recording), prerequisites (Chrome/Edge, extension v1.0.36+, Claude Code v2.0.73+, direct Anthropic plan), CLI setup (--chrome flag, /chrome command, enable by default), VS Code setup (@browser), site permissions (inherited from extension), example workflows (test local app, debug console, automate forms, draft in Google Docs, extract data, multi-site, record GIF), troubleshooting (extension not detected with native messaging host paths for Chrome/Edge on macOS/Linux/Windows, browser not responding from modal dialogs, connection drops from idle service worker, Windows named pipe conflicts, common error messages table)

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
