---
name: ide-doc
description: Complete documentation for Claude Code IDE integrations and the Desktop app -- Desktop app (Code tab with visual diff review, live app preview with launch.json and autoVerify, GitHub PR monitoring with auto-fix and auto-merge, parallel sessions with automatic git worktree isolation, scheduled tasks with frequency options and missed-run catch-up, connectors for GitHub/Slack/Linear/Notion, permission modes Ask/AutoAcceptEdits/Plan/BypassPermissions, @mention files and attachments, context compaction, session management with sidebar/filter/rename, remote sessions on Anthropic cloud with multi-repo support, SSH sessions to remote machines, Continue-in menu to move sessions to web or IDE, enterprise configuration with admin console/managed settings/MDM/SSO, launch.json configuration fields name/runtimeExecutable/runtimeArgs/port/cwd/env/autoPort/program/args, CLI comparison table and shared configuration), VS Code extension (install for VS Code and Cursor, Spark icon in Editor Toolbar/Activity Bar/Status Bar/Command Palette, prompt box with permission modes/command menu/context indicator/extended thinking/multi-line input, @-mentions with fuzzy matching and @file#L1-99 line ranges and @terminal:name, resume local and remote sessions, panel positioning in sidebar/editor area, multiple conversations in tabs/windows, terminal mode toggle, plugin management with /plugins and install scopes, Chrome browser automation with @browser, VS Code commands and shortcuts Cmd+Esc/Cmd+Shift+Esc/Cmd+N/Option+K, extension settings selectedModel/useTerminal/initialPermissionMode/preferredLocation/autosave/useCtrlEnterToSend/claudeProcessWrapper, IDE MCP server with getDiagnostics and executeCode tools and Jupyter Quick Pick confirmation, checkpoints with fork/rewind/fork+rewind, CLI in VS Code with /ide and --resume, third-party providers Bedrock/Vertex/Foundry, security considerations for auto-edit mode), JetBrains plugin (IntelliJ/PyCharm/WebStorm/GoLand/PhpStorm/Android Studio, Cmd+Esc quick launch, diff viewing, selection context, Cmd+Option+K file references, diagnostic sharing, marketplace installation, /ide for external terminals, plugin settings with custom Claude command, ESC key configuration, remote development host-side installation, WSL configuration), Chrome extension integration (beta for Chrome and Edge, live debugging with console errors, design verification from Figma mocks, web app testing, authenticated web app interaction, data extraction, task automation, session recording as GIF, --chrome flag and /chrome command, site permissions inherited from extension, native messaging host configuration, troubleshooting extension-not-detected/browser-not-responding/connection-drops/Windows named pipes). Load when discussing Claude Code Desktop app, VS Code extension, JetBrains plugin, Chrome browser integration, IDE setup, IDE MCP server, getDiagnostics, executeCode, Jupyter execution, diff viewing, app preview, launch.json, PR monitoring, auto-fix CI, auto-merge, scheduled tasks, connectors, permission modes in Desktop, session management, remote sessions, SSH sessions, Continue-in, enterprise Desktop configuration, MDM policies, worktree sessions, panel positioning, @-mentions in VS Code, terminal mode, plugin management UI, @browser, Spark icon, checkpoints in VS Code, third-party providers in extension, Chrome automation, browser debugging, or any IDE integration topic.
user-invocable: false
---

# IDE Integrations Documentation

This skill provides the complete official documentation for using Claude Code in IDE environments -- the Desktop app, VS Code extension, JetBrains plugin, and Chrome browser integration.

## Quick Reference

Claude Code runs in four IDE surfaces beyond the CLI: the Desktop app (graphical, standalone), the VS Code extension (embedded in the editor), the JetBrains plugin (IntelliJ family), and the Chrome extension (browser automation). All share the same underlying engine, CLAUDE.md files, MCP servers, hooks, skills, and settings.

### Desktop App

The Code tab in the Claude Desktop app provides a full graphical interface for Claude Code without requiring a terminal. The app has three tabs: Chat (general conversation), Cowork (autonomous background agent on cloud VM), and Code (interactive coding with local file access).

#### Desktop-Only Features

| Feature | Description |
|:--------|:------------|
| Visual diff review | Click `+12 -1` indicator to review changes file by file; click lines to comment; Cmd/Ctrl+Enter to submit all comments; click Review code for Claude self-review |
| Live app preview | Embedded browser for dev servers; auto-verify takes screenshots and fixes issues after every edit |
| PR monitoring | CI status bar with auto-fix (reads failures and iterates) and auto-merge (squash merge when checks pass); requires `gh` CLI |
| Parallel sessions | Sidebar tabs with automatic git worktree isolation per session; configurable worktree location and branch prefix |
| Scheduled tasks | Recurring sessions (manual/hourly/daily/weekdays/weekly) with missed-run catch-up |
| Connectors | GUI for GitHub, Slack, Linear, Notion, Google Calendar, and more (local and SSH sessions only) |
| Remote sessions | Run on Anthropic cloud; continue when app is closed; multi-repo support |
| SSH sessions | Connect to remote machines, cloud VMs, dev containers |
| Continue-in | Move a session to Claude Code on the Web or open in IDE |
| File attachments | Drag/drop images, PDFs, and files into the prompt |

#### Permission Modes

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Asks before each edit/command (recommended for new users) |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits; still asks for terminal commands |
| Plan mode | `plan` | Analyzes code and creates plan without modifying anything |
| Bypass permissions | `bypassPermissions` | No prompts; enable in Settings; enterprise admins can disable |

The `dontAsk` mode is CLI-only. Remote sessions support Auto accept edits and Plan mode only.

#### Preview Server Configuration (launch.json)

Located at `.claude/launch.json` in the project root. Claude auto-detects setup; edit manually or via Preview dropdown.

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments (e.g., `["run", "dev"]`) |
| `port` | number | Server port (default: 3000) |
| `cwd` | string | Working directory relative to project root; use `${workspaceFolder}` for root |
| `env` | object | Additional environment variables (do not put secrets here) |
| `autoPort` | boolean | `true` = find free port; `false` = fail on conflict; unset = ask |
| `program` | string | Script to run with `node` directly (alternative to runtimeExecutable) |
| `args` | string[] | Arguments for `program` |

Top-level `"autoVerify": false` disables automatic verification after edits. When disabled, preview tools remain available on demand.

Use `runtimeExecutable` with `runtimeArgs` for package manager commands (e.g., `npm run dev`). Use `program` for standalone Node.js scripts (e.g., `server.js`).

#### Scheduled Tasks

| Field | Description |
|:------|:------------|
| Name | Kebab-case identifier, used as folder name; must be unique |
| Description | Short summary in task list |
| Prompt | Instructions sent to Claude; includes model, permission mode, folder, worktree controls |
| Frequency | Manual, Hourly (+stagger offset), Daily (time picker), Weekdays, Weekly (day+time picker) |

Tasks run locally (app must be open, computer awake). Each task gets a fixed delay of up to 10 minutes to stagger API traffic. Missed runs: on wake/launch, one catch-up run for the most recently missed time in the last 7 days. Task prompts live at `~/.claude/scheduled-tasks/<task-name>/SKILL.md`. Enable "Keep computer awake" in Settings to prevent idle-sleep (closing lid still sleeps).

To avoid permission stalls, click "Run now" after creating a task, approve tools with "always allow", then future runs auto-approve.

#### Enterprise Configuration

| Mechanism | Controls |
|:----------|:---------|
| Admin console | Code in desktop, Code in web, Remote Control, Disable bypass permissions |
| Managed settings | `disableBypassPermissionsMode`, `allowManagedPermissionRulesOnly`, `allowManagedHooksOnly` |
| MDM (macOS) | `com.anthropic.Claude` preference domain via Jamf/Kandji |
| Group policy (Windows) | `SOFTWARE\Policies\Claude` registry |
| Deployment | macOS: DMG via MDM; Windows: MSIX or EXE with silent install |

#### CLI Flag Equivalents in Desktop

| CLI flag | Desktop equivalent |
|:---------|:-------------------|
| `--model sonnet` | Model dropdown next to send button |
| `--resume`, `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (enable in Settings) |
| `--add-dir` | **+** button in remote sessions for multi-repo |
| `ANTHROPIC_MODEL` env var | Model dropdown next to send button |
| `MAX_THINKING_TOKENS` env var | Set in shell profile; applies to local sessions |

Not available in Desktop: `--allowedTools`, `--disallowedTools`, `--verbose`, `--print`, `--output-format`, third-party providers, Linux, agent teams, inline code suggestions.

Use `/desktop` in the CLI to migrate a session to the Desktop app (macOS/Windows only).

### VS Code Extension

#### Installation and Access

- Install from VS Code Marketplace or Cursor: search "Claude Code" or use `Cmd+Shift+X`
- Requires VS Code 1.98.0+
- Includes the CLI (accessible from integrated terminal)

#### Opening Claude Code

| Method | How |
|:-------|:----|
| Editor Toolbar | Spark icon in top-right corner (requires file open) |
| Activity Bar | Spark icon in left sidebar (always visible; shows sessions list) |
| Command Palette | `Cmd+Shift+P` then "Claude Code" |
| Status Bar | Click "Claude Code" in bottom-right corner (works with no file open) |

#### VS Code Keyboard Shortcuts

| Command | Shortcut (Mac / Win-Linux) | Description |
|:--------|:---------------------------|:------------|
| Focus Input | `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| Open in New Tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | New conversation as editor tab |
| New Conversation | `Cmd+N` / `Ctrl+N` | Start new conversation (Claude focused) |
| Insert @-Mention | `Option+K` / `Alt+K` | Insert file path + line numbers (editor focused) |

#### Prompt Box Features

| Feature | Details |
|:--------|:--------|
| Permission modes | Click mode indicator; Plan mode opens plan as full markdown doc for inline comments |
| Command menu | Type `/` for models, thinking, MCP, hooks, memory, plugins, `/usage`, `/remote-control` |
| Context indicator | Shows context window usage; auto-compacts or use `/compact` |
| Extended thinking | Toggle via command menu; deeper reasoning for complex problems |
| Multi-line input | `Shift+Enter` for new lines without sending |

#### @-Mentions and File References

Type `@` followed by filename for fuzzy-matched file references. Supports `@file#L5-10` line ranges, `@dir/` for folders, `@terminal:name` for terminal output. Selected text in the editor is automatically visible to Claude. Press `Option+K`/`Alt+K` to insert an @-mention from selection. Hold `Shift` while dragging files to attach them. For large PDFs, ask Claude to read specific pages.

#### Resume Conversations

Click the dropdown at top of the panel for conversation history. Search by keyword or browse by time. Hover to rename or remove sessions. Remote tab shows sessions from claude.ai (requires Claude.ai Subscription login; only web sessions with a GitHub repo appear).

#### Extension Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | CLI-style interface instead of panel |
| `initialPermissionMode` | `default` | Default approval mode |
| `preferredLocation` | `panel` | Where Claude opens: `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Ctrl/Cmd+Enter instead of Enter to send |
| `enableNewConversationShortcut` | `true` | Enable Cmd/Ctrl+N shortcut |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `allowDangerouslySkipPermissions` | `false` | Bypass all permission prompts (use with caution) |
| `claudeProcessWrapper` | - | Executable path to launch Claude process |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party providers) |
| `hideOnboarding` | `false` | Hide the onboarding checklist |
| `environmentVariables` | `[]` | Set environment variables for the Claude process |

#### IDE MCP Server

The VS Code extension runs a local MCP server named `ide` that the CLI connects to automatically. Hidden from `/mcp`.

| Detail | Value |
|:-------|:------|
| Transport | `127.0.0.1` on random high port; not reachable from other machines |
| Auth | Fresh random token per activation; lock file at `~/.claude/ide/` with `0600` permissions in `0700` directory |

**Tools exposed to the model:**

| Tool | What it does | Writes? |
|:-----|:-------------|:--------|
| `mcp__ide__getDiagnostics` | Returns language-server diagnostics (errors/warnings from Problems panel); optionally scoped to one file | No |
| `mcp__ide__executeCode` | Runs Python code in active Jupyter notebook kernel; requires Quick Pick confirmation | Yes |

`executeCode` inserts a cell at the end, scrolls to it, and shows Execute/Cancel picker. Refuses when no active notebook, no Jupyter extension (`ms-toolsai.jupyter`), or non-Python kernel. Quick Pick confirmation is separate from `PreToolUse` hooks -- an allowlist entry lets Claude propose running a cell, but the Quick Pick is what lets it actually run.

#### Checkpoints (Rewind)

Hover over any message to reveal rewind options:

| Option | Effect |
|:-------|:-------|
| Fork conversation from here | New conversation branch; code changes intact |
| Rewind code to here | Revert file changes to this point; keep conversation |
| Fork conversation and rewind code | Both: new branch + revert files |

#### Plugin Management

Type `/plugins` to open the plugin manager. Install plugins with three scopes: for you (user, all projects), for this project (shared with collaborators), locally (only you, only this repo). Manage marketplaces in the Marketplaces tab. Plugin configuration is shared between extension and CLI.

#### Chrome Integration in VS Code

Type `@browser` in the prompt box followed by the task. Requires Claude in Chrome extension v1.0.36+. Access specific browser tools via the attachment menu.

#### Third-Party Providers (VS Code)

1. Enable `disableLoginPrompt` in VS Code settings
2. Configure provider in `~/.claude/settings.json` (Bedrock, Vertex, or Foundry)

#### CLI vs Extension Feature Comparison

| Feature | CLI | VS Code Extension |
|:--------|:----|:------------------|
| Commands and skills | All | Subset (type `/` to see) |
| MCP server config | Yes | Partial (add via CLI; manage with `/mcp`) |
| Checkpoints | Yes | Yes |
| Bash shortcut (`!`) | Yes | No |
| Tab completion | Yes | No |

### JetBrains Plugin

#### Supported IDEs

IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand (and most other JetBrains IDEs).

#### Features

| Feature | Shortcut (Mac / Win-Linux) |
|:--------|:---------------------------|
| Quick launch | `Cmd+Esc` / `Ctrl+Esc` |
| File reference insert | `Cmd+Option+K` / `Alt+Ctrl+K` |
| Diff viewing | Displayed in IDE diff viewer |
| Selection context | Current selection/tab auto-shared |
| Diagnostic sharing | Lint/syntax errors auto-shared |

#### Installation

Install from [JetBrains Marketplace](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-). Restart IDE after installation. Run `claude` from the integrated terminal; use `/ide` from external terminals.

#### Configuration

**Plugin settings** at Settings -> Tools -> Claude Code [Beta]:
- Custom Claude command (e.g., `claude`, `/usr/local/bin/claude`, `npx @anthropic/claude`)
- For WSL: `wsl -d Ubuntu -- bash -lic "claude"` (replace `Ubuntu` with your distro name)
- Enable Option+Enter for multi-line prompts (macOS)
- Enable automatic updates

**ESC key fix:** Settings -> Tools -> Terminal -> uncheck "Move focus to the editor with Escape" or delete the "Switch focus to Editor" shortcut.

#### Special Configurations

| Scenario | Requirement |
|:---------|:------------|
| Remote Development | Install plugin on remote host via Settings -> Plugin (Host), not local client |
| WSL | Additional terminal, networking, and firewall configuration needed |

### Chrome Extension Integration (Beta)

Chrome integration connects Claude Code to your browser for automation, testing, and debugging. Works with Google Chrome and Microsoft Edge (not Brave, Arc, or other Chromium browsers). Not supported on WSL. Not available through third-party providers.

#### Capabilities

| Capability | Description |
|:-----------|:------------|
| Live debugging | Read console errors/DOM state, then fix the code |
| Design verification | Build UI from Figma mock, verify in browser |
| Web app testing | Form validation, visual regressions, user flows |
| Authenticated apps | Interact with Google Docs, Gmail, Notion (uses your login state) |
| Data extraction | Pull structured data from pages, save as CSV/JSON |
| Task automation | Form filling, data entry, multi-site workflows |
| Session recording | Record interactions as GIFs |

#### Prerequisites

- Google Chrome or Microsoft Edge
- [Claude in Chrome extension](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) v1.0.36+
- Claude Code v2.0.73+
- Direct Anthropic plan (Pro, Max, Teams, or Enterprise)

#### Usage

| Method | Command |
|:-------|:--------|
| CLI launch | `claude --chrome` |
| In-session enable | `/chrome` |
| VS Code | `@browser` in prompt box |
| Enable by default | `/chrome` -> "Enabled by default" |

Enabling by default increases context usage since browser tools are always loaded. Site permissions are managed in the Chrome extension settings. Run `/mcp` and select `claude-in-chrome` to see available browser tools.

#### Troubleshooting Chrome

| Issue | Fix |
|:------|:----|
| Extension not detected | Verify in `chrome://extensions`; restart Chrome and Claude Code; run `/chrome` -> Reconnect |
| Browser not responding | Dismiss any modal dialogs blocking the page; create new tab; restart extension |
| Connection drops | Run `/chrome` -> "Reconnect extension" (service worker went idle) |
| Windows named pipe conflicts | Restart Claude Code; close other Chrome sessions |

Native messaging host config locations:
- macOS Chrome: `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- macOS Edge: `~/Library/Application Support/Microsoft Edge/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Linux Chrome: `~/.config/google-chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Linux Edge: `~/.config/microsoft-edge/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Windows: check `HKCU\Software\Google\Chrome\NativeMessagingHosts\` or `HKCU\Software\Microsoft\Edge\NativeMessagingHosts\` in Registry

### Shared Configuration Across All Surfaces

All graphical interfaces (Desktop, VS Code, JetBrains, CLI) share:
- CLAUDE.md files
- MCP servers (`~/.claude.json` or `.mcp.json`)
- Hooks and skills
- Settings (`~/.claude/settings.json`)
- Models (Sonnet, Opus, Haiku)

Note: MCP servers in `claude_desktop_config.json` (Desktop chat app) are separate from Claude Code MCP servers. Configure Claude Code MCP servers in `~/.claude.json` or your project's `.mcp.json`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- full Desktop app reference covering session startup (environment/folder/model/permission mode), prompt box and @mentions and attachments, permission modes (Ask/AutoAcceptEdits/Plan/BypassPermissions with settings keys), live app preview with autoVerify and launch.json configuration (fields: name/runtimeExecutable/runtimeArgs/port/cwd/env/autoPort/program/args, port conflict handling, program vs runtimeExecutable, examples for Next.js/monorepo/Node.js), diff view with inline comments and Review code, PR monitoring with auto-fix and auto-merge (requires gh CLI), parallel sessions with automatic git worktree isolation and sidebar management and configurable worktree location and branch prefix, remote sessions on Anthropic cloud with multi-repo support, Continue-in menu (web and IDE), connectors for external tools, skills and plugins UI, scheduled tasks (frequency options manual/hourly/daily/weekdays/weekly, stagger offset, missed-run catch-up within 7 days, permissions and always-allow, task management and SKILL.md on disk, keep-computer-awake setting), environment configuration (local sessions inherit shell vars, remote sessions continue in background, SSH sessions with host/port/identity configuration), enterprise configuration (admin console controls, managed settings, MDM policies for macOS and Windows, SSO, data handling, deployment), CLI comparison (flag equivalents table, /desktop command, shared configuration including CLAUDE.md/MCP/hooks/skills/settings, feature comparison table, Desktop-only and CLI-only features), troubleshooting (403 errors, blank screen, failed sessions, missing tools, Git/Git LFS, MCP on Windows, app quit, ARM64, Intel Mac Cowork limitation, branch-not-found for remote sessions)
- [Get started with the Desktop app](references/claude-code-desktop-quickstart.md) -- installation (macOS/Windows download links, sign in, open Code tab, no Node.js required), three tabs (Chat/Cowork/Code), first session walkthrough (choose environment Local/Remote/SSH, choose folder, choose model, send prompt, review and accept changes with diff view), next steps (interrupt and steer, give context with @mentions and attachments, skills and slash commands, diff review with comments and Review code, permission modes, plugins, preview, PR monitoring, scheduled tasks, parallel sessions and remote sessions and Continue-in), CLI comparison
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) -- installation (VS Code 1.98.0+, Cursor support), getting started (Spark icon locations including Editor Toolbar/Activity Bar/Command Palette/Status Bar, onboarding checklist, send prompt, review changes), prompt box features (permission modes with Plan mode markdown document, command menu with /, context indicator, extended thinking, multi-line input), @-mentions with fuzzy matching and line ranges and @terminal:name and selection visibility toggle and PDF page ranges, resume past conversations (local with search/rename/remove, remote from claude.ai with Remote tab), customize workflow (panel positioning in sidebar/editor area, multiple conversations in tabs/windows with status dots, terminal mode toggle), plugin management (/plugins, install scopes user/project/local, marketplace management), Chrome browser automation (@browser and attachment menu), VS Code commands and shortcuts table (Focus Input/Open in New Tab/New Conversation/Insert @-Mention), extension settings (selectedModel, useTerminal, initialPermissionMode, preferredLocation, autosave, useCtrlEnterToSend, enableNewConversationShortcut, hideOnboarding, respectGitIgnore, environmentVariables, allowDangerouslySkipPermissions, claudeProcessWrapper, disableLoginPrompt), feature comparison between extension and CLI (commands, MCP config, checkpoints, bash shortcut, tab completion), checkpoints (fork/rewind/fork+rewind), CLI in VS Code (/ide, --resume), @terminal:name references, background process monitoring, MCP server management (/mcp and CLI add), IDE MCP server (transport on 127.0.0.1 random port, auth token with 0600 permissions, getDiagnostics and executeCode tools, Jupyter Quick Pick confirmation separate from PreToolUse hooks), git integration (commits, PRs, worktrees with --worktree flag), third-party providers setup (disableLoginPrompt then configure in settings.json for Bedrock/Vertex/Foundry), security notes for auto-edit mode and Restricted Mode, troubleshooting (install failures, Spark icon missing, no response), uninstall with data cleanup
- [JetBrains IDEs](references/claude-code-jetbrains.md) -- supported IDEs (IntelliJ/PyCharm/Android Studio/WebStorm/PhpStorm/GoLand), features (Cmd+Esc quick launch, diff viewing in IDE, selection context, Cmd+Option+K file references, diagnostic sharing), marketplace installation, usage from IDE terminal and external terminals with /ide, configuration (Claude command path, diff tool auto-detect), plugin settings (custom command, suppress not-found notifications, Option+Enter multi-line, automatic updates), ESC key terminal fix, remote development (install on host not local client), WSL configuration (command format, networking, firewall), troubleshooting (plugin not working, IDE not detected, command not found), security considerations for auto-edit mode
- [Use Claude Code with Chrome](references/claude-code-chrome.md) -- beta status (Chrome and Edge, not Brave/Arc/WSL, not via third-party providers), capabilities (live debugging, design verification, web app testing, authenticated apps, data extraction, task automation, GIF recording), prerequisites (Chrome/Edge, extension v1.0.36+, Claude Code v2.0.73+, direct Anthropic plan), CLI setup with --chrome and /chrome, VS Code with @browser, enable by default (increases context usage), site permissions management, example workflows (test local app, debug console, automate forms, draft in Google Docs, extract data, multi-site workflows, record demo GIF), troubleshooting (extension not detected with native messaging host paths for Chrome/Edge on macOS/Linux/Windows, browser not responding from modal dialogs, connection drops from idle service worker, Windows named pipe conflicts, common error messages table)

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the Desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
