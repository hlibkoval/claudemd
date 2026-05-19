---
name: ide-doc
description: Complete official documentation for Claude Code IDE integrations and interfaces — Desktop app (sessions, permission modes, diff view, computer use, parallel sessions, SSH, enterprise config), Desktop quickstart, VS Code extension (setup, @-mentions, checkpoints, plugin manager, settings, built-in IDE MCP server), JetBrains plugin (supported IDEs, installation, WSL config), Chrome integration (browser automation capabilities, setup, CLI flags), and computer use from the CLI (enabling, app permissions, safety).
user-invocable: false
---

# IDE and Interface Documentation

This skill provides the complete official documentation for Claude Code's graphical interfaces and IDE integrations: the Desktop app, VS Code extension, JetBrains plugin, Chrome integration, and CLI computer use.

## Quick Reference

### Desktop App Overview

Available on macOS and Windows (not Linux — use the CLI). Requires a Pro, Max, Team, or Enterprise subscription. Download at [claude.ai/api/desktop](https://claude.ai/api/desktop/darwin/universal/dmg/latest/redirect).

The Desktop app has three tabs: **Chat**, **Cowork**, and **Code**. The **Code** tab is the Claude Code interface — each conversation is a **session** with its own context, folder, and code changes.

### Desktop Permission Modes

| Mode | Settings key | Behavior |
| :--- | :--- | :--- |
| **Ask permissions** | `default` | Asks before editing files or running commands. Shows diffs for review. |
| **Auto accept edits** | `acceptEdits` | Auto-accepts file edits and common FS commands (mkdir, touch, mv); asks before other terminal commands. |
| **Plan mode** | `plan` | Reads and explores, then proposes a plan without editing source code. |
| **Auto** | `auto` | Executes all actions with background safety checks. Research preview. Requires Max/Team/Enterprise/API plan plus specific model versions. |
| **Bypass permissions** | `bypassPermissions` | No prompts — equivalent to `--dangerously-skip-permissions`. Enable in Settings → Claude Code. Enterprise admins can disable this. |

Remote sessions support Auto accept edits and Plan mode only. Auto mode requires Claude Sonnet 4.6, Opus 4.6, or Opus 4.7 on Team/Enterprise/API plans; Opus 4.7 on Max.

### Desktop Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Cmd/Ctrl` `/` | Show keyboard shortcuts |
| `Cmd/Ctrl` `N` | New session |
| `Cmd/Ctrl` `W` | Close session |
| `Ctrl` `Tab` / `Ctrl` `Shift` `Tab` | Next or previous session |
| `Esc` | Stop Claude's response |
| `Cmd/Ctrl` `Shift` `D` | Toggle diff pane |
| `Cmd/Ctrl` `Shift` `P` | Toggle preview pane |
| `Ctrl` `` ` `` | Toggle terminal pane |
| `Cmd/Ctrl` `\` | Close focused pane |
| `Cmd/Ctrl` `;` | Open side chat |
| `Ctrl` `O` | Cycle view modes |
| `Cmd/Ctrl` `Shift` `M` | Open permission mode menu |
| `Cmd/Ctrl` `Shift` `I` | Open model menu |

### Desktop Environments

| Environment | Where code runs | Notes |
| :--- | :--- | :--- |
| **Local** | Your machine | Full shell, files, tools. Desktop may not inherit all shell env vars — use the env editor in prompt box. |
| **Remote** | Anthropic cloud infrastructure | Continues even if app is closed. Multiple repos supported. No local config (user CLAUDE.md, user MCP servers, etc.). |
| **SSH** | Your remote machine | Add via environment dropdown. Supports permission modes, connectors, plugins, MCP servers. Remote must run Linux or macOS. |

### Desktop session.json Preview Server Config

Stored at `.claude/launch.json` in your project root.

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique identifier for this server |
| `runtimeExecutable` | string | Command to run: `npm`, `yarn`, `node` |
| `runtimeArgs` | string[] | Arguments: `["run", "dev"]` |
| `port` | number | Port to listen on (default: 3000) |
| `cwd` | string | Working dir relative to project root |
| `env` | object | Environment variables (no secrets — use the local env editor) |
| `autoPort` | boolean | `true`: find free port; `false`: fail if port taken; unset: ask once |
| `program` | string | Script to run directly with `node` |
| `args` | string[] | Arguments to `program` |

`autoVerify` at the top level (default `true`): Claude auto-screenshots and checks after every edit. Disable per-project with `"autoVerify": false`.

### Desktop Enterprise Managed Settings Keys

| Key | Description |
| :--- | :--- |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to prevent Bypass permissions mode |
| `disableAutoMode` | Set to `"disable"` to remove Auto from the mode selector |
| `autoMode` | Customize Auto mode classifier trust/block rules org-wide |
| `sshConfigs` | Pre-configure SSH connections for team members (read-only to users) |
| `sshHostAllowlist` | Restrict SSH sessions to hosts matching these patterns; `[]` disables SSH entirely |
| `managedMcpServers` | Push MCP server configs to all users (third-party deployments only) |

`sshHostAllowlist` patterns: `*` matches any host; `*.example.com` matches example.com and any subdomain; anything else is exact. Case-insensitive. Only read from managed settings.

### Desktop vs. CLI Feature Comparison

| Feature | CLI | Desktop |
| :--- | :--- | :--- |
| Permission modes | All including `dontAsk` | Ask, Auto accept, Plan, Auto, Bypass via Settings |
| Third-party providers | Bedrock, Vertex, Foundry | Anthropic API (Enterprise can configure Vertex/gateway) |
| MCP servers | Settings files | Connectors UI (local/SSH) or settings files |
| Session isolation | `--worktree` flag | Automatic worktrees |
| File attachments | Not available | Images, PDFs |
| Computer use | macOS via `/mcp` | macOS and Windows via Settings |
| Scripting | `--print`, Agent SDK | Not available |
| Linux | Yes | No |

### Desktop CLI Flag Equivalents

| CLI flag | Desktop equivalent |
| :--- | :--- |
| `--model` | Model dropdown next to send button |
| `--resume`, `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode in Settings |
| `--add-dir` | + button in remote sessions |
| `--verbose` | Verbose view mode in Transcript view dropdown |
| `--print`, `--output-format` | Not available — Desktop is interactive only |

### Computer Use (Desktop and CLI)

Computer use lets Claude open apps, click, type, and see your screen. It is a research preview on macOS and Windows (Desktop) and macOS only (CLI). Requires Pro or Max plan. Not available on Team or Enterprise plans.

App control tiers (fixed, not configurable):

| Tier | Apps | What Claude can do |
| :--- | :--- | :--- |
| View only | Browsers, trading platforms | Screenshots only |
| Click only | Terminals, IDEs | Click and scroll; no typing or keyboard shortcuts |
| Full control | Everything else | Click, type, drag, keyboard shortcuts |

Approvals are per session (30 minutes in Dispatch-spawned sessions).

**CLI setup:** Run `/mcp`, find `computer-use`, select **Enable**. Then grant macOS Accessibility and Screen Recording permissions.

**Desktop setup:** Settings → General → Computer use toggle. On macOS, also grant Accessibility and Screen Recording.

**Safety:** Only one session can hold the computer use lock at a time. Press `Esc` anywhere to abort. Terminal window is excluded from screenshots. Prompt injection from on-screen content is flagged.

### VS Code Extension

Install: search "Claude Code" in Extensions view (`Cmd+Shift+X` / `Ctrl+Shift+X`), or use [vscode:extension/anthropic.claude-code](vscode:extension/anthropic.claude-code). Minimum VS Code version: 1.98.0.

**Open Claude:** Spark icon in Editor Toolbar (requires file open), Activity Bar Spark icon, Status Bar "✱ Claude Code", or Command Palette.

**Prompt box features:**
- Permission modes: click mode indicator; options include `default`, `plan`, `acceptEdits`, `bypassPermissions`
- Type `/` for command menu: attach files, switch models, toggle extended thinking, `/usage`, `/remote-control`, MCP, hooks, memory, permissions, plugins
- `@filename` for file references with fuzzy matching; `@src/folder/` for folders (trailing slash)
- `Option+K` / `Alt+K` to insert @-mention of current selection (e.g. `@app.ts#5-10`)
- `@terminal:name` to include terminal output in a prompt
- `@browser` + task for Chrome browser actions (requires Claude in Chrome extension v1.0.36+)

**VS Code extension settings:**

| Setting | Default | Description |
| :--- | :--- | :--- |
| `useTerminal` | `false` | Launch in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | Default permission mode for new conversations |
| `preferredLocation` | `panel` | `sidebar` or `panel` (new tab) |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N for new conversation |
| `enableReopenClosedSessionShortcut` | `true` | Cmd/Ctrl+Shift+T to reopen last closed Claude tab |
| `allowDangerouslySkipPermissions` | `false` | Add Auto mode and Bypass permissions to mode selector |

**VS Code keyboard shortcuts:**

| Shortcut | Action |
| :--- | :--- |
| `Cmd/Ctrl+Esc` | Toggle focus between editor and Claude |
| `Cmd/Ctrl+Shift+Esc` | Open new conversation as editor tab |
| `Cmd/Ctrl+N` | New conversation (requires `enableNewConversationShortcut: true` and Claude focused) |
| `Option+K` / `Alt+K` | Insert @-mention reference (editor must be focused) |

**Checkpoints (VS Code only):** Hover any message to reveal the rewind button. Options: Fork conversation from here, Rewind code to here, or Fork conversation and rewind code.

**Built-in IDE MCP server:** The extension runs a local MCP server named `ide` on `127.0.0.1`. It exposes two model-visible tools:
- `mcp__ide__getDiagnostics` — returns language-server diagnostics (read-only)
- `mcp__ide__executeCode` — runs Python in the active Jupyter notebook (always requires explicit Quick Pick confirmation; cannot run silently)

The server is authenticated with a per-session random token stored at `~/.claude/ide/` with `0600` permissions.

**Open VS Code tab from other tools:** URI handler at `vscode://anthropic.claude-code/open`. Optional query params: `prompt` (URL-encoded text to pre-fill) and `session` (session ID to resume).

### JetBrains Plugin

Supported IDEs: IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand.

Install from [JetBrains Marketplace](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-). Restart IDE after install.

| Feature | Details |
| :--- | :--- |
| Quick launch | `Cmd+Esc` (Mac) / `Ctrl+Esc` (Windows/Linux) |
| File reference shortcut | `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Windows/Linux) — inserts `@src/auth.ts#L1-99` |
| Diff viewing | Displayed in IDE diff viewer (not terminal) |
| Selection context | Current selection/tab shared automatically; blocked by `Read` deny rules |
| Diagnostic sharing | Lint/syntax errors shared automatically |

**Connect external terminal:** run `/ide` inside any Claude Code session to connect to JetBrains IDE.

**Diff tool config:** run `/config` and set diff tool to `auto` (IDE) or `terminal`.

**Plugin settings** (Settings → Tools → Claude Code [Beta]): custom Claude command path, auto-updates, Option+Enter for multi-line.

**WSL2 fix:** WSL2's NAT networking blocks the IDE connection. Options: (1) Create Windows Firewall rule allowing WSL2 subnet traffic; (2) Set `networkingMode=mirrored` in `.wslconfig` (Windows 11 22H2+).

**Remote Development:** install the plugin on the remote host via Settings → Plugin (Host), not the local client.

### Chrome Integration

Connects Claude Code to the Chrome browser via the [Claude in Chrome extension](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn). Works with Google Chrome and Microsoft Edge. Not supported on Brave, Arc, or other Chromium browsers. Not available on WSL.

Requires: Claude Code v2.0.73+, Chrome extension v1.0.36+, direct Anthropic plan (not available on Bedrock/Vertex/Foundry).

**CLI usage:** `claude --chrome` to start a session with Chrome. Or run `/chrome` inside an existing session. Run `/chrome` → "Enabled by default" to avoid passing the flag each time.

**VS Code usage:** type `@browser` followed by the task in the prompt box. No extra flag needed.

**Capabilities:** live console error debugging, design verification, web app testing, authenticated web app interaction, data extraction, form automation, multi-site workflows, GIF session recording.

**Claude opens new tabs** and shares your browser's login state. Pauses at login pages and CAPTCHAs. Browser actions run in a visible window.

**Chrome extension not detected fix:**
1. Verify extension installed and enabled in `chrome://extensions`
2. Restart Chrome (native messaging host config is read at Chrome startup)
3. Run `/chrome` → "Reconnect extension"

Native messaging host config locations:
- Chrome/macOS: `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Edge/macOS: `~/Library/Application Support/Microsoft Edge/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`

**Common Chrome errors:**

| Error | Fix |
| :--- | :--- |
| "Browser extension is not connected" | Restart Chrome and Claude Code; run `/chrome` to reconnect |
| "Extension not detected" | Install or enable in `chrome://extensions` |
| "Receiving end does not exist" | Run `/chrome` → "Reconnect extension" (service worker went idle) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Desktop application](references/claude-code-desktop.md) — session setup, permission modes, diff view, code review, PR monitoring, workspace panes, keyboard shortcuts, computer use, session management, parallel sessions, side chats, connectors, skills, plugins, preview servers, SSH sessions, enterprise configuration, CLI comparison, troubleshooting
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — install, first session walkthrough, next steps, CLI comparison
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — install, get started, prompt box, @-mentions, session history, resuming remote sessions, plugin manager, Chrome automation, VS Code commands, settings reference, extension vs. CLI comparison, checkpoints, MCP, git worktrees, third-party providers, built-in IDE MCP server, troubleshooting
- [JetBrains IDEs](references/claude-code-jetbrains.md) — supported IDEs, features, installation, usage, plugin settings, ESC key config, remote development, WSL2 configuration, troubleshooting
- [Use Claude Code with Chrome (beta)](references/claude-code-chrome.md) — capabilities, prerequisites, CLI and VS Code setup, example workflows, troubleshooting
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — enable via `/mcp`, per-session app approval, control tiers, one-session lock, safety guardrails, example workflows, CLI vs. Desktop differences, troubleshooting
- [Desktop changelog](references/claude-code-desktop-changelog.md) — release notes for Claude Code Desktop by version

## Sources

- Desktop application: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome (beta): https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
- Desktop changelog: https://code.claude.com/docs/en/desktop-changelog.md
