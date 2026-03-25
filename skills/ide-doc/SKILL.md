---
name: ide-doc
description: Complete documentation for Claude Code IDE integrations and desktop app -- Desktop app (Code tab with visual diff review, live app preview with auto-verify and launch.json configuration, computer use with app permission tiers view-only/click-only/full-control, PR monitoring with auto-fix and auto-merge, parallel sessions with automatic Git worktree isolation, Dispatch integration, scheduled tasks with local/remote/loop comparison and frequency options and missed-run catch-up, connectors for external tools, SSH sessions, remote cloud sessions with multi-repo support, continue-in-another-surface, enterprise configuration with admin console and managed settings and MDM policies and SSO, permission modes default/acceptEdits/plan/auto/bypassPermissions, environment configuration local/remote/SSH, CLI comparison table and shared configuration, troubleshooting 403 errors and blank screen and session loading and Git LFS), Desktop quickstart (install on macOS/Windows, Code tab setup, first session workflow with environment and folder and model selection, review and accept changes, skills and plugins, diff view, permission modes, preview, PR monitoring, scheduled tasks, parallel sessions), VS Code extension (install for VS Code and Cursor, prompt box with permission modes and command menu and context indicator and extended thinking and multi-line input, @-mentions with fuzzy matching and line ranges and folder trailing slash, resume past conversations and remote sessions from claude.ai, customize workflow with panel positioning and multiple conversations and terminal mode, manage plugins with /plugins and install scopes, Chrome browser automation with @browser, VS Code commands and shortcuts table with Focus Input Cmd+Esc and Open in New Tab Cmd+Shift+Esc and Insert @-Mention Option+K, extension settings table selectedModel/useTerminal/initialPermissionMode/preferredLocation/autosave/useCtrlEnterToSend/enableNewConversationShortcut/hideOnboarding/respectGitIgnore/environmentVariables/disableLoginPrompt/allowDangerouslySkipPermissions/claudeProcessWrapper, extension vs CLI feature comparison, checkpoints with fork and rewind, run CLI in VS Code with /ide command, include terminal output with @terminal:name, MCP server management with /mcp, git workflows with commits and PRs and worktrees, third-party providers Bedrock/Vertex/Foundry setup, built-in IDE MCP server with getDiagnostics and executeCode tools and Jupyter execution confirmation, security considerations, troubleshooting extension install and spark icon and unresponsive), JetBrains plugin (supported IDEs IntelliJ/PyCharm/Android Studio/WebStorm/PhpStorm/GoLand, features quick-launch Cmd+Esc diff-viewing selection-context file-references Cmd+Option+K diagnostic-sharing, marketplace installation, usage from IDE terminal and external terminals with /ide, plugin settings claude-command and Option+Enter and auto-updates, ESC key configuration, remote development plugin-on-host requirement, WSL configuration, troubleshooting plugin-not-working IDE-not-detected command-not-found, security considerations), Chrome extension beta (capabilities live-debugging design-verification web-app-testing authenticated-apps data-extraction task-automation session-recording-GIF, prerequisites Chrome/Edge and extension v1.0.36+ and Claude Code v2.0.73+, CLI setup with --chrome flag and /chrome command, enable by default, site permissions inherited from extension, example workflows test-local-app debug-console automate-forms draft-google-docs extract-data multi-site-workflows record-demo-GIF, troubleshooting extension-not-detected with native-messaging-host paths for Chrome/Edge on macOS/Linux/Windows and browser-not-responding and connection-drops and Windows-named-pipe-conflicts, common error messages table). Load when discussing Claude Code Desktop app, Code tab, desktop quickstart, VS Code extension, JetBrains plugin, IntelliJ, PyCharm, WebStorm, Chrome extension, browser automation, @browser, IDE integration, IDE MCP server, getDiagnostics, executeCode, Jupyter execution, visual diff review, diff view, live app preview, launch.json, preview configuration, autoVerify, computer use, app permissions, PR monitoring, auto-fix, auto-merge, parallel sessions, worktrees in desktop, Dispatch, scheduled tasks in desktop, connectors, SSH sessions, remote sessions, continue in another surface, enterprise desktop configuration, MDM policies, desktop permission modes, auto mode, bypass permissions, VS Code commands, VS Code shortcuts, VS Code settings, extension settings, terminal mode, @-mentions in VS Code, checkpoints, rewind, fork conversation, /ide command, @terminal, /mcp in VS Code, git worktrees, third-party providers in VS Code, Bedrock/Vertex/Foundry setup, Chrome --chrome flag, /chrome command, site permissions, native messaging host, JetBrains configuration, JetBrains remote development, WSL IDE setup, Claude Code in IDE, or any IDE and desktop app topic for Claude Code.
user-invocable: false
---

# IDE & Desktop App Documentation

This skill provides the complete official documentation for Claude Code's IDE integrations and the desktop app -- the Desktop app (Code tab), VS Code extension, JetBrains plugin, and Chrome browser extension.

## Quick Reference

### Surfaces Overview

| Surface | Install | Key differentiator |
|:--------|:--------|:-------------------|
| **Desktop app** (Code tab) | macOS `.dmg` / Windows `.exe` | Visual diff review, live preview, computer use, PR monitoring, scheduled tasks, Dispatch |
| **VS Code extension** | Marketplace: `anthropic.claude-code` | Native IDE panel, @-mentions with line ranges, checkpoints, IDE MCP server |
| **JetBrains plugin** | JetBrains Marketplace | Diff viewing, selection context, diagnostic sharing across IntelliJ/PyCharm/WebStorm/GoLand/PhpStorm/Android Studio |
| **Chrome extension** | Chrome Web Store (beta) | Browser automation, live debugging, form filling, GIF recording; works with Chrome and Edge |
| **CLI** | `npm install -g @anthropic-ai/claude-code` | Scripting, automation, `--print`, third-party providers, agent teams |

All surfaces share configuration: CLAUDE.md files, MCP servers, hooks, skills, settings, and plugins.

### Desktop App -- Permission Modes

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Asks before editing files or running commands (default) |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits; still asks before terminal commands |
| Plan mode | `plan` | Analyzes and plans without modifying files or running commands |
| Auto | `auto` | Background safety checks; Team plan + Sonnet 4.6/Opus 4.6 required |
| Bypass permissions | `bypassPermissions` | No prompts; sandboxed environments only |

The `dontAsk` mode is CLI-only.

### Desktop App -- Computer Use (macOS, Pro/Max only)

Computer use lets Claude open apps, control your screen, and interact with native GUIs. It is off by default; enable in Settings > Desktop app > General. Requires Accessibility and Screen Recording macOS permissions.

**App permission tiers** (fixed by app category):

| Tier | Capabilities | Applies to |
|:-----|:-------------|:-----------|
| View only | See in screenshots | Browsers, trading platforms |
| Click only | Click and scroll (no typing) | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

Claude prefers more precise tools first: connectors > Bash > Chrome extension > computer use.

### Desktop App -- Preview (launch.json)

Preview configuration lives in `.claude/launch.json`. Key fields per configuration entry:

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments (e.g., `["run", "dev"]`) |
| `port` | number | Server port (default 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables |
| `autoPort` | boolean | `true`: find free port; `false`: fail on conflict; unset: ask |
| `program` | string | Node.js script to run directly |
| `args` | string[] | Arguments for `program` |

Top-level `"autoVerify": false` disables automatic post-edit verification.

### Desktop App -- Scheduled Tasks

Three scheduling options compared:

| | Cloud | Desktop | `/loop` |
|:--|:------|:--------|:--------|
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Persistent across restarts | Yes | Yes | No |
| Access to local files | No (fresh clone) | Yes | Yes |
| Minimum interval | 1 hour | 1 minute | 1 minute |

**Frequency options**: Manual, Hourly (with staggered offset), Daily (default 9 AM), Weekdays, Weekly. Custom intervals via natural language in any session.

**Missed runs**: on app start or wake, one catch-up run for the most recently missed time in the last 7 days.

Task files live at `~/.claude/scheduled-tasks/<task-name>/SKILL.md` with YAML frontmatter.

### Desktop App -- PR Monitoring

After opening a PR, a CI status bar appears. Toggle **Auto-fix** (Claude fixes failing checks) and **Auto-merge** (squash merge when all checks pass). Requires `gh` CLI installed and authenticated. Auto-merge must be enabled in GitHub repo settings.

### Desktop App -- Sessions

- **Parallel sessions**: each gets its own Git worktree in `<project>/.claude/worktrees/`
- **Remote sessions**: run on Anthropic cloud; continue when app is closed; support multiple repos
- **SSH sessions**: run on remote machines; Claude Code must be installed on the host
- **Dispatch sessions**: spawned from Cowork tab or phone; appear with a Dispatch badge
- **Continue in**: move a local session to Claude Code on the Web, or open in an IDE

### Desktop App -- Enterprise Configuration

| Mechanism | Controls |
|:----------|:---------|
| Admin console | Code in desktop, Code in web, Remote Control, Bypass permissions |
| Managed settings | `permissions.disableBypassPermissionsMode`, `disableAutoMode`, `autoMode` classifier |
| MDM (macOS) | `com.anthropic.Claude` preference domain |
| Group Policy (Windows) | `SOFTWARE\Policies\Claude` |

### Desktop App -- CLI Comparison

| Feature | CLI | Desktop |
|:--------|:----|:--------|
| Third-party providers | Bedrock, Vertex, Foundry | Not available |
| Computer use | Not available | macOS with Pro/Max |
| Agent teams | Available | Not available |
| Scripting (`--print`) | Available | Not available |
| Session isolation | `--worktree` flag | Automatic worktrees |
| File attachments | Not available | Images, PDFs |
| Dispatch | Not available | Sidebar integration |
| Linux | Supported | Not supported |

Move a CLI session to Desktop with `/desktop`.

### VS Code Extension

**Prerequisites**: VS Code 1.98.0+, Anthropic account (or third-party provider configured).

**Install**: search "Claude Code" in Extensions view, or use `vscode:extension/anthropic.claude-code` (also works for Cursor via `cursor:extension/anthropic.claude-code`).

**Key shortcuts**:

| Command | Shortcut (Mac / Win-Linux) | Description |
|:--------|:---------------------------|:------------|
| Focus Input | `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| Open in New Tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | New conversation as editor tab |
| New Conversation | `Cmd+N` / `Ctrl+N` | Start fresh (Claude must be focused) |
| Insert @-Mention | `Option+K` / `Alt+K` | Insert file reference with line range |

**Prompt box features**: permission modes, `/` command menu, context indicator, extended thinking toggle, `Shift+Enter` for multi-line.

**@-mentions**: type `@` + filename for fuzzy matching; `@src/components/` (trailing slash) for folders; `@file.ts#5-10` for line ranges. `Option+K`/`Alt+K` inserts from current selection.

**Resume sessions**: dropdown at panel top; search by keyword; Local and Remote tabs (Remote shows claude.ai web sessions).

**Chrome automation**: `@browser` in prompt box; requires Claude in Chrome extension v1.0.36+.

**Plugins**: type `/plugins` to open manager; install with user/project/local scope.

### VS Code Extension -- Key Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | CLI-style terminal mode |
| `initialPermissionMode` | `default` | Starting permission mode |
| `preferredLocation` | `panel` | Where Claude opens: `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before read/write |
| `useCtrlEnterToSend` | `false` | Ctrl/Cmd+Enter to send instead of Enter |
| `allowDangerouslySkipPermissions` | `false` | Show Auto and Bypass in mode selector |
| `claudeProcessWrapper` | - | Executable path to launch Claude process |

Add `"$schema": "https://json.schemastore.org/claude-code-settings.json"` to `settings.json` for autocomplete.

### VS Code Extension -- Built-in IDE MCP Server

When the extension is active, a local MCP server runs on `127.0.0.1` (random port, per-activation auth token). Two tools are visible to the model:

| Tool | What it does | Writes? |
|:-----|:-------------|:--------|
| `mcp__ide__getDiagnostics` | Returns language-server diagnostics (errors/warnings from Problems panel) | No |
| `mcp__ide__executeCode` | Runs Python in the active Jupyter notebook kernel | Yes |

`executeCode` always shows a Quick Pick confirmation in VS Code before running. Requires `ms-toolsai.jupyter` extension and a Python kernel.

If using a `PreToolUse` hook to allowlist MCP tools, include these tool names.

### VS Code Extension -- Checkpoints

Hover any message to reveal the rewind button with three options:

- **Fork conversation from here**: new branch, keep all code changes
- **Rewind code to here**: revert files, keep conversation history
- **Fork conversation and rewind code**: new branch and revert files

### VS Code Extension vs CLI

| Feature | CLI | VS Code Extension |
|:--------|:----|:------------------|
| Commands and skills | All | Subset (type `/` to see available) |
| MCP server config | Yes | Partial (add via CLI; manage with `/mcp`) |
| Checkpoints | Yes | Yes |
| `!` bash shortcut | Yes | No |
| Tab completion | Yes | No |

Run `claude` in VS Code's integrated terminal for CLI features. Use `/ide` from an external terminal to connect to VS Code.

### JetBrains Plugin

**Supported IDEs**: IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand.

**Features**: quick launch (`Cmd+Esc`/`Ctrl+Esc`), diff viewing in IDE, selection context sharing, file references (`Cmd+Option+K`/`Alt+Ctrl+K` for `@File#L1-99`), diagnostic sharing.

**Install**: JetBrains Marketplace, then restart IDE.

**Plugin settings** (Settings > Tools > Claude Code [Beta]):

| Setting | Description |
|:--------|:------------|
| Claude command | Custom path (e.g., `claude`, `/usr/local/bin/claude`, `npx @anthropic/claude`) |
| Option+Enter for multi-line | macOS only; disable if Option key captured unexpectedly |
| Automatic updates | Check and install plugin updates on restart |

**WSL**: set command to `wsl -d Ubuntu -- bash -lic "claude"` (replace `Ubuntu` with your distro).

**Remote Development**: install plugin in the remote host via Settings > Plugin (Host).

**ESC key fix**: Settings > Tools > Terminal, uncheck "Move focus to the editor with Escape" or remove the shortcut.

### Chrome Extension (Beta)

**Supported browsers**: Google Chrome, Microsoft Edge. Not supported: Brave, Arc, other Chromium browsers, WSL.

**Prerequisites**: Chrome/Edge, Claude in Chrome extension v1.0.36+, Claude Code v2.0.73+, direct Anthropic plan. Not available through Bedrock/Vertex/Foundry.

**CLI usage**: `claude --chrome` or `/chrome` mid-session. Enable by default via `/chrome` > "Enabled by default".

**VS Code usage**: `@browser` in the prompt box.

**Capabilities**: live debugging, design verification, web app testing, authenticated web app interaction, data extraction, task automation, GIF recording.

**Site permissions**: inherited from the Chrome extension settings.

**Troubleshooting -- native messaging host paths**:

| OS | Chrome path | Edge path |
|:---|:------------|:----------|
| macOS | `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` | `~/Library/Application Support/Microsoft Edge/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` |
| Linux | `~/.config/google-chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` | `~/.config/microsoft-edge/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` |
| Windows | Registry: `HKCU\Software\Google\Chrome\NativeMessagingHosts\` | Registry: `HKCU\Software\Microsoft\Edge\NativeMessagingHosts\` |

**Common errors**:

| Error | Fix |
|:------|:----|
| "Browser extension is not connected" | Restart Chrome and Claude Code, run `/chrome` to reconnect |
| "Extension not detected" | Install/enable extension in `chrome://extensions` |
| "No tab available" | Ask Claude to create a new tab and retry |
| "Receiving end does not exist" | Run `/chrome` > "Reconnect extension" (service worker went idle) |

### Desktop Troubleshooting

| Issue | Resolution |
|:------|:-----------|
| 403 / auth errors in Code tab | Sign out and back in; verify paid subscription; quit app fully and reopen |
| Blank/stuck screen on launch | Restart app; check for pending updates |
| "Failed to load session" | Folder may not exist; Git LFS may be missing; try different folder |
| Tools not found (npm, node) | Verify in regular terminal; check shell profile PATH; restart app |
| Git required (Windows) | Install Git for Windows; restart app |
| MCP servers not working (Windows) | Check config; restart app; verify server process |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- full Desktop app reference covering working with code (prompt box, file context with @-mentions and attachments, permission modes default/acceptEdits/plan/auto/bypassPermissions with enterprise restrictions), preview with launch.json (configuration fields name/runtimeExecutable/runtimeArgs/port/cwd/env/autoPort/program/args, auto-verify, port conflicts, examples for Next.js/multiple servers/Node.js script), diff view (review file changes, inline comments, Review code for high-signal issues), PR monitoring (auto-fix failing CI, auto-merge with squash, gh CLI requirement), computer use (macOS Pro/Max only, enable in Settings, Accessibility and Screen Recording permissions, app permission tiers view-only/click-only/full-control, tool priority order connectors>Bash>Chrome>computer-use, denied apps and window hiding), session management (parallel sessions with Git worktrees, remote sessions with multi-repo, SSH sessions, continue-in-another-surface to web or IDE, Dispatch integration from Cowork tab and phone), extending Claude Code (connectors for external tools, skills with / commands, plugins with install scopes, preview server configuration), scheduled tasks (cloud vs desktop vs /loop comparison, local and remote tasks, frequency options manual/hourly/daily/weekdays/weekly, missed-run catch-up behavior, task permissions and saved approvals, manage tasks on disk at ~/.claude/scheduled-tasks/), environment configuration (local shell inheritance, remote background sessions, SSH connection setup with host/port/identity), enterprise configuration (admin console controls, managed settings disableBypassPermissionsMode/disableAutoMode/autoMode, MDM on macOS via com.anthropic.Claude, Group Policy on Windows via SOFTWARE\Policies\Claude, SSO/SAML/OIDC, deployment via MDM and MSIX), CLI comparison (flag equivalents, shared configuration CLAUDE.md/MCP/hooks/skills/settings, feature comparison table, /desktop command to transfer session), troubleshooting (version check, 403 auth errors, blank screen, failed to load session, tools not found, Git/Git LFS errors, MCP on Windows, app won't quit, Windows-specific issues, Intel Mac Cowork limitation, branch doesn't exist yet)
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) -- Desktop quickstart covering installation on macOS and Windows (download links, sign in, open Code tab, no Node.js required), first session workflow (choose Local/Remote/SSH environment, select folder, pick model, Code/Chat/Cowork tab overview), reviewing and accepting changes (diff view, accept/reject buttons), next steps (interrupt and steer, @filename context, skills with / commands, diff review with inline comments, permission modes, plugins, preview with dev servers, PR monitoring with auto-fix/auto-merge, scheduled tasks, parallel sessions with worktrees, remote sessions, continue in IDE/web), CLI comparison (same engine, shared config, /desktop command)
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) -- VS Code extension reference covering installation (VS Code 1.98.0+, install for VS Code and Cursor), getting started (Spark icon in Editor Toolbar/Activity Bar/Command Palette/Status Bar, onboarding checklist), prompt box (permission modes default/plan/acceptEdits/auto, / command menu, context indicator, extended thinking, multi-line with Shift+Enter), @-mentions (fuzzy matching, file and folder references, line ranges with Option+K/Alt+K, PDF page ranges, Shift+drag attachments), resume conversations (session history with search, Local and Remote tabs for claude.ai web sessions), customize workflow (panel positioning sidebar/editor/secondary sidebar, multiple conversations in tabs and windows, terminal mode toggle), manage plugins (/plugins command, install with user/project/local scope, marketplace management), Chrome browser automation (@browser, Claude in Chrome extension v1.0.36+), commands and shortcuts (Focus Input Cmd+Esc, Open in New Tab Cmd+Shift+Esc, New Conversation Cmd+N, Insert @-Mention Option+K, Open in Side Bar, Open in Terminal, Show Logs, Logout), extension settings table (selectedModel, useTerminal, initialPermissionMode, preferredLocation, autosave, useCtrlEnterToSend, enableNewConversationShortcut, hideOnboarding, respectGitIgnore, environmentVariables, disableLoginPrompt, allowDangerouslySkipPermissions, claudeProcessWrapper), extension vs CLI (commands subset, MCP partial, checkpoints yes, bash shortcut no, tab completion no), checkpoints (fork conversation, rewind code, fork and rewind), run CLI in VS Code (integrated terminal, /ide from external terminal, --resume to continue extension conversations), @terminal:name for terminal output, MCP servers (/mcp management, claude mcp add command), git workflows (commits, PRs, worktrees with --worktree flag), third-party providers (Bedrock/Vertex/Foundry via settings.json, disable login prompt), built-in IDE MCP server (127.0.0.1 random port with auth token, getDiagnostics for Problems panel, executeCode for Jupyter with Quick Pick confirmation, PreToolUse hook allowlisting), security (auto-edit risks, Restricted Mode, manual approval), troubleshooting (extension install, Spark icon visibility, Claude not responding, uninstall and data cleanup)
- [JetBrains IDEs](references/claude-code-jetbrains.md) -- JetBrains plugin reference covering supported IDEs (IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand), features (quick launch Cmd+Esc/Ctrl+Esc, diff viewing in IDE, selection context, file references Cmd+Option+K/Alt+Ctrl+K, diagnostic sharing), marketplace installation, usage from IDE terminal and external terminals with /ide command, plugin settings (Claude command custom path, Option+Enter multi-line macOS, auto-updates), ESC key configuration for JetBrains terminals, remote development (plugin on host requirement), WSL configuration (terminal/networking/firewall), troubleshooting (plugin not working, IDE not detected, command not found with npm verification), security considerations for auto-edit mode
- [Use Claude Code with Chrome (beta)](references/claude-code-chrome.md) -- Chrome extension reference covering capabilities (live debugging, design verification, web app testing, authenticated app interaction, data extraction, task automation, GIF session recording), prerequisites (Chrome/Edge, extension v1.0.36+, Claude Code v2.0.73+, direct Anthropic plan only), CLI setup (--chrome flag, /chrome command, enable by default), VS Code setup (@browser in prompt), site permissions (inherited from extension), example workflows (test local app, debug console, automate forms, draft in Google Docs, extract data, multi-site workflows, record demo GIF), troubleshooting (extension not detected with native messaging host paths for Chrome/Edge on macOS/Linux/Windows, browser not responding with modal dialog blocking, connection drops from idle service worker, Windows named pipe conflicts, common error messages table)

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome (beta): https://code.claude.com/docs/en/chrome.md
