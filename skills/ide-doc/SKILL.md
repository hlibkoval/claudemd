---
name: ide-doc
description: Complete documentation for Claude Code IDE and desktop integrations -- Desktop app (Code tab with visual diff review, live app preview, computer use, PR monitoring with auto-fix/auto-merge, parallel sessions with Git worktree isolation, Dispatch integration, scheduled tasks, connectors, SSH sessions, remote sessions, enterprise configuration with MDM/SSO/managed settings), VS Code extension (installation, prompt box with permission modes and @-mentions, inline diff review, checkpoints with fork/rewind, multiple conversations in tabs/windows, terminal mode, plugin management UI, Chrome browser automation via @browser, URI handler vscode://anthropic.claude-code/open, extension settings like selectedModel/useTerminal/initialPermissionMode/autosave, built-in IDE MCP server with getDiagnostics and executeCode tools, resume remote sessions from claude.ai), JetBrains plugin (IntelliJ/PyCharm/WebStorm/GoLand/PhpStorm/Android Studio, diff viewing, selection context sharing, diagnostic sharing, Cmd+Esc quick launch, @File#L1-99 references, remote development and WSL configuration), and Chrome integration (browser automation from CLI with --chrome flag or /chrome command, live debugging with console logs, design verification, web app testing, authenticated web apps, data extraction, form filling automation, session recording as GIF, site permissions, native messaging host setup, supported on Chrome and Edge). Load when discussing Claude Code Desktop app, VS Code extension, JetBrains plugin, IDE integration, Chrome browser automation, computer use, visual diff review, app preview, PR monitoring, parallel sessions, worktrees in Desktop, scheduled tasks in Desktop, connectors, SSH sessions, remote sessions, Dispatch, launch.json configuration, extension settings, IDE MCP server, getDiagnostics, executeCode, checkpoints, URI handler, or any IDE/desktop-related topic for Claude Code.
user-invocable: false
---

# IDE & Desktop Integration Documentation

This skill provides the complete official documentation for Claude Code IDE integrations -- covering the Desktop app, VS Code extension, JetBrains plugin, and Chrome browser automation.

## Quick Reference

### Desktop App (Code Tab)

The Desktop app provides a graphical interface for Claude Code with capabilities beyond the CLI.

**Desktop-exclusive features:**

| Feature | Description |
|:--------|:------------|
| **Visual diff review** | File-by-file diff viewer with inline comments; submit all comments with Cmd/Ctrl+Enter |
| **Live app preview** | Embedded browser for dev servers; auto-verify changes after edits |
| **Computer use** | Open apps and control your screen on macOS (Pro/Max plans, research preview) |
| **PR monitoring** | CI status bar with auto-fix for failing checks and auto-merge when all pass |
| **Parallel sessions** | Automatic Git worktree isolation per session; stored in `.claude/worktrees/` |
| **Dispatch** | Receive tasks from your phone via the Cowork tab; sessions appear with Dispatch badge |
| **Scheduled tasks** | Local or remote recurring tasks with configurable frequency and permissions |
| **Connectors** | GUI setup for Google Calendar, Slack, GitHub, Linear, Notion, and more |
| **SSH sessions** | Run Claude on remote machines with full plugin/connector/MCP support |
| **Remote sessions** | Run on Anthropic cloud; continue even if app is closed; multi-repo support |

**Permission modes:**

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Asks before editing files or running commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits; asks for commands |
| Plan mode | `plan` | Analyzes and plans without modifying files |
| Auto | `auto` | Background safety checks; Team plans, Sonnet 4.6 or Opus 4.6 required |
| Bypass permissions | `bypassPermissions` | No permission prompts; sandboxed environments only |

**Computer use tiers (macOS only):**

| Tier | Capabilities | Applies to |
|:-----|:-------------|:-----------|
| View only | See app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, no typing | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

Computer use requires enabling in Settings > Desktop app > General, plus macOS Accessibility and Screen Recording permissions.

**Preview server configuration (`.claude/launch.json`):**

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (e.g., `npm`, `yarn`) |
| `runtimeArgs` | string[] | Arguments (e.g., `["run", "dev"]`) |
| `port` | number | Server port (default: 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables |
| `autoPort` | boolean | `true`: find free port; `false`: fail on conflict |
| `program` | string | Node.js script to run directly |
| `args` | string[] | Arguments for `program` |
| `autoVerify` | boolean | Auto-verify changes after edits (top-level field, default: true) |

**Scheduled tasks frequency options:** Manual, Hourly (with stagger offset), Daily, Weekdays, Weekly. Custom intervals via natural language in any session. Missed runs trigger one catch-up run on wake (within 7 days).

**Environment options:**

| Environment | Description |
|:------------|:------------|
| Local | Runs on your machine with direct file access |
| Remote | Runs on Anthropic cloud; persists when app is closed |
| SSH | Connects to remote machine over SSH; Claude Code must be installed remotely |

**CLI flag equivalents:**

| CLI flag | Desktop equivalent |
|:---------|:-------------------|
| `--model sonnet` | Model dropdown next to send button |
| `--resume`, `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode in Settings |
| `--add-dir` | **+** button in remote sessions |

Desktop and CLI share configuration: CLAUDE.md, MCP servers, hooks, skills, and settings files.

### VS Code Extension

**Prerequisites:** VS Code 1.98.0+, Anthropic account.

**Install:** Search "Claude Code" in Extensions view or use `vscode:extension/anthropic.claude-code`. Also works in Cursor: `cursor:extension/anthropic.claude-code`.

**Opening Claude Code:**

| Method | Description |
|:-------|:------------|
| Editor Toolbar | Spark icon in top-right corner (requires a file open) |
| Activity Bar | Spark icon in left sidebar for sessions list |
| Command Palette | `Cmd+Shift+P` / `Ctrl+Shift+P`, type "Claude Code" |
| Status Bar | Click "Claude Code" in bottom-right corner |

**Key shortcuts:**

| Command | Shortcut | Description |
|:--------|:---------|:------------|
| Focus Input | `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| Open in New Tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | New conversation as editor tab |
| New Conversation | `Cmd+N` / `Ctrl+N` | Start new conversation (Claude focused) |
| Insert @-Mention | `Option+K` / `Alt+K` | Insert file + line reference (editor focused) |

**Prompt box features:**
- Permission modes: click mode indicator to switch (normal, Plan, auto-accept)
- Command menu: type `/` for models, thinking, usage, remote control, MCP, hooks, memory, plugins
- Context indicator: shows context window usage
- Extended thinking: toggle via `/` menu
- Multi-line input: `Shift+Enter`
- @-mentions: `@filename` with fuzzy matching; `@src/components/` for folders
- Shift+drag files to attach them

**Checkpoints (rewind):**

| Option | Behavior |
|:-------|:---------|
| Fork conversation from here | New branch keeping code changes |
| Rewind code to here | Revert files, keep conversation |
| Fork conversation and rewind code | New branch and revert files |

**Extension settings:**

| Setting | Default | Description |
|:--------|:--------|:------------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | CLI-style interface instead of graphical panel |
| `initialPermissionMode` | `default` | Starting mode: `default`, `plan`, `acceptEdits`, `auto`, `bypassPermissions` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter to send |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from searches |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto and Bypass to mode selector |
| `disableLoginPrompt` | `false` | Skip auth prompts (third-party providers) |

**URI handler:** `vscode://anthropic.claude-code/open` with optional `prompt` and `session` query parameters. Opens from shell aliases, bookmarklets, or scripts.

**Built-in IDE MCP server:** Runs automatically when extension is active. Binds to `127.0.0.1` on random high port with fresh random auth token per activation. Token stored in `~/.claude/ide/` with `0600` permissions.

| Tool | What it does | Writes? |
|:-----|:-------------|:--------|
| `mcp__ide__getDiagnostics` | Returns language-server diagnostics (errors/warnings from Problems panel) | No |
| `mcp__ide__executeCode` | Runs Python code in active Jupyter notebook kernel (with Quick Pick confirmation) | Yes |

**Resume remote sessions:** Past Conversations dropdown > Remote tab shows sessions from claude.ai (requires Claude.ai Subscription sign-in). Only web sessions started with a GitHub repository appear.

**Terminal references:** Use `@terminal:name` to include terminal output in prompts.

### JetBrains Plugin

**Supported IDEs:** IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand.

**Features:**

| Feature | Description |
|:--------|:------------|
| Quick launch | `Cmd+Esc` (Mac) / `Ctrl+Esc` (Windows/Linux) |
| Diff viewing | Code changes in IDE diff viewer |
| Selection context | Current selection/tab shared automatically |
| File references | `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Windows/Linux) for @File#L1-99 |
| Diagnostic sharing | IDE lint/syntax errors shared automatically |

**Install:** [JetBrains Marketplace](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-), restart IDE after install.

**Plugin settings** (Settings > Tools > Claude Code [Beta]):

| Setting | Purpose |
|:--------|:--------|
| Claude command | Custom path to `claude` (e.g., `/usr/local/bin/claude`, `npx @anthropic/claude`) |
| Suppress notification | Skip "command not found" notifications |
| Option+Enter for multi-line | macOS: Option+Enter inserts new lines in prompts |
| Automatic updates | Auto-check and install plugin updates |

**WSL users:** Set claude command to `wsl -d Ubuntu -- bash -lic "claude"` (replace `Ubuntu` with your distribution).

**Remote Development:** Install the plugin in the remote host via Settings > Plugin (Host), not on the local client.

**ESC key fix:** Settings > Tools > Terminal > uncheck "Move focus to the editor with Escape" or delete the "Switch focus to Editor" shortcut.

### Chrome Integration (Beta)

**Supported browsers:** Google Chrome, Microsoft Edge. Not supported: Brave, Arc, other Chromium browsers, WSL.

**Prerequisites:** Chrome or Edge browser, [Claude in Chrome extension](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) v1.0.36+, Claude Code v2.0.73+, direct Anthropic plan (not available through Bedrock/Vertex/Foundry).

**Enable:**
- CLI: `claude --chrome` or `/chrome` during session; set "Enabled by default" via `/chrome`
- VS Code: `@browser` in prompt box (available automatically when Chrome extension is installed)

**Capabilities:**

| Capability | Description |
|:-----------|:------------|
| Live debugging | Read console errors and DOM state, fix code |
| Design verification | Build UI, verify against Figma mocks |
| Web app testing | Form validation, visual regressions, user flows |
| Authenticated web apps | Interact with Google Docs, Gmail, Notion using browser login state |
| Data extraction | Pull structured data from pages, save as CSV |
| Form filling | Automate repetitive data entry |
| Multi-site workflows | Coordinate tasks across tabs |
| Session recording | Record interactions as GIF |

**Site permissions** are inherited from the Chrome extension settings.

**Native messaging host paths (Chrome):**
- macOS: `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Linux: `~/.config/google-chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Windows: Registry at `HKCU\Software\Google\Chrome\NativeMessagingHosts\`

**Troubleshooting:** Run `/chrome` and select "Reconnect extension" if connection drops. Restart Chrome after first-time setup to pick up native messaging host config. Dismiss JavaScript dialogs manually if browser commands stop working.

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- Full Desktop app reference: starting sessions, prompt box and context, permission modes (Ask/Auto accept edits/Plan/Auto/Bypass), preview with launch.json configuration (runtimeExecutable, runtimeArgs, port, cwd, env, autoPort, program, autoVerify), diff view with inline comments and code review, PR monitoring with auto-fix and auto-merge, computer use with app permission tiers (view-only/click-only/full-control) and macOS setup, parallel sessions with Git worktree isolation, remote sessions with multi-repo, continue-in-another-surface, Dispatch integration, connectors GUI, skills and plugins, scheduled tasks (local and remote, frequency options, missed runs catch-up, permissions), environment configuration (local/remote/SSH), enterprise configuration (admin console, managed settings, MDM policies, SSO, data handling, deployment), CLI comparison with flag equivalents and feature table, troubleshooting
- [Get Started with Desktop](references/claude-code-desktop-quickstart.md) -- Desktop app quickstart: installation (macOS, Windows), three tabs (Chat, Cowork, Code), first session walkthrough (environment and folder selection, model picker, prompt examples, review and accept changes), next steps (interrupt and steer, context with @mentions and attachments, skills, diff review, permission modes, plugins, preview, PR monitoring, scheduled tasks, parallel sessions), CLI comparison
- [VS Code Extension](references/claude-code-vs-code.md) -- Full VS Code extension reference: installation (VS Code and Cursor), getting started (Spark icon, Activity Bar, Command Palette, Status Bar, onboarding checklist), prompt box (permission modes, command menu, context indicator, extended thinking, multi-line input), @-mentions with fuzzy matching and line ranges, resume past conversations and remote sessions, customization (panel positioning, multiple conversations, terminal mode), plugin management (/plugins, install scopes, marketplace management), Chrome browser automation (@browser), commands and shortcuts table, URI handler (vscode://anthropic.claude-code/open with prompt and session params), extension settings table, CLI comparison (feature availability, checkpoints with fork/rewind options, terminal integration, @terminal references, MCP server setup with /mcp, git workflows, worktrees), third-party providers (Bedrock/Vertex/Foundry setup), built-in IDE MCP server (transport/auth, getDiagnostics and executeCode tools, Jupyter Quick Pick confirmation), security notes, troubleshooting
- [JetBrains Plugin](references/claude-code-jetbrains.md) -- JetBrains plugin reference: supported IDEs (IntelliJ, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand), features (quick launch, diff viewing, selection context, file references, diagnostic sharing), marketplace installation, usage from IDE terminal and external terminals with /ide command, configuration (Claude command path, ESC key fix, plugin settings), special configurations (remote development host installation, WSL setup), troubleshooting (plugin not working, IDE not detected, command not found), security considerations for auto-edit mode
- [Chrome Integration](references/claude-code-chrome.md) -- Chrome browser automation reference: capabilities (live debugging, design verification, web app testing, authenticated apps, data extraction, form filling, multi-site workflows, session recording as GIF), prerequisites (Chrome or Edge, Claude in Chrome extension v1.0.36+, Claude Code v2.0.73+, direct Anthropic plan), CLI setup (--chrome flag, /chrome command, enable by default), VS Code setup (@browser), example workflows, site permissions, troubleshooting (extension detection, native messaging host paths for Chrome and Edge on macOS/Linux/Windows, reconnection, Windows named pipe conflicts, common error messages table)

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get Started with Desktop: https://code.claude.com/docs/en/desktop-quickstart.md
- VS Code Extension: https://code.claude.com/docs/en/vs-code.md
- JetBrains Plugin: https://code.claude.com/docs/en/jetbrains.md
- Chrome Integration: https://code.claude.com/docs/en/chrome.md
