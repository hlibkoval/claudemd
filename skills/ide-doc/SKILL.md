---
name: ide-doc
description: Complete official documentation for Claude Code IDE and desktop integrations — Desktop app (parallel sessions, worktrees, diff review, preview servers, computer use, connectors, enterprise config), VS Code extension (inline diffs, @-mentions, plan review, checkpoints, settings), JetBrains plugin, Chrome browser automation, and CLI computer use.
user-invocable: false
---

# IDE & Desktop Integrations Documentation

This skill provides the complete official documentation for Claude Code's IDE and desktop integrations.

## Quick Reference

### Surfaces overview

| Surface | Platforms | Key capabilities |
| :--- | :--- | :--- |
| **Desktop app** | macOS, Windows | Parallel sessions with Git worktree isolation, drag-and-drop pane layout, integrated terminal/file editor, diff review, live preview, computer use, PR monitoring, connectors, scheduled tasks |
| **VS Code extension** | macOS, Windows, Linux | Inline diff review, @-mentions with line ranges, plan review, checkpoints, multiple conversation tabs, terminal mode, plugin manager |
| **JetBrains plugin** | macOS, Windows, Linux | Diff viewing in IDE, selection context sharing, diagnostic sharing, file reference shortcuts |
| **Chrome extension** | Chrome, Edge | Browser automation, console reading, form filling, data extraction, session recording (GIF), site-level permissions |
| **Computer use (CLI)** | macOS only | Screen control from terminal, native app testing, GUI automation, per-app approval |

### Desktop app

#### Permission modes

| Mode | Settings key | Behavior |
| :--- | :--- | :--- |
| Ask permissions | `default` | Asks before editing files or running commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits, asks for terminal commands |
| Plan mode | `plan` | Reads and explores, then proposes a plan without editing |
| Auto | `auto` | Background safety checks, reduced prompts. Research preview. Requires Sonnet 4.6+/Opus 4.6+/Opus 4.7 |
| Bypass permissions | `bypassPermissions` | No permission prompts. Sandboxed environments only |

#### Session environments

| Environment | Where it runs | Key detail |
| :--- | :--- | :--- |
| Local | Your machine | Shell profile may not fully load from Dock/Finder; use local environment editor for env vars |
| Remote | Anthropic cloud | Continues after app close; no separate compute charges; supports multiple repos |
| SSH | Your remote machine | Requires Claude Code installed on remote; supports connectors, plugins, MCP |

#### Keyboard shortcuts (macOS; use Ctrl instead of Cmd on Windows)

| Shortcut | Action |
| :--- | :--- |
| `Cmd+N` | New session |
| `Cmd+W` | Close session |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next/previous session |
| `Cmd+Shift+D` | Toggle diff pane |
| `Cmd+Shift+P` | Toggle preview pane |
| `Cmd+;` | Open side chat |
| `Ctrl+` `` ` `` | Toggle terminal pane |
| `Cmd+\` | Close focused pane |
| `Ctrl+O` | Cycle view modes (Normal/Verbose/Summary) |
| `Cmd+Shift+M` | Permission mode menu |
| `Cmd+Shift+I` | Model menu |
| `Cmd+/` | Show all shortcuts |

#### Preview server configuration (`.claude/launch.json`)

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments (e.g. `["run", "dev"]`) |
| `port` | number | Listen port (default 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables |
| `autoPort` | boolean | `true`: auto-pick free port; `false`: fail on conflict |
| `program` | string | Script to run with `node` directly |
| `args` | string[] | Arguments for `program` |
| `autoVerify` | boolean | Auto-verify code changes after edits (default `true`; set at top level) |

#### PR monitoring features

- **Auto-fix**: automatically attempts to fix failing CI checks
- **Auto-merge**: merges PR once all checks pass (squash merge; requires GitHub repo setting)
- **Auto-archive**: archive session when PR merges or closes (enable in Settings)
- Requires `gh` CLI installed and authenticated

#### Computer use (Desktop)

- Research preview on macOS and Windows (Pro or Max plan)
- Off by default; enable in Settings > General
- macOS requires Accessibility + Screen Recording permissions
- Per-app approval per session; three tiers: view-only (browsers), click-only (terminals/IDEs), full control (everything else)
- Tool priority: connector > Bash > Chrome extension > computer use

#### Enterprise configuration

| Setting | Location | Description |
| :--- | :--- | :--- |
| Code in desktop / web | Admin console | Enable/disable Code tab and web sessions |
| Remote Control | Admin console | Enable/disable Remote Control |
| `permissions.disableBypassPermissionsMode` | Managed settings | Prevent bypass permissions mode |
| `disableAutoMode` | Managed settings | Remove Auto from mode selector |
| `autoMode` | Settings (not project) | Customize auto mode classifier rules |

Device management: macOS via `com.anthropic.Claude` preference domain (Jamf/Kandji); Windows via `SOFTWARE\Policies\Claude` registry.

### VS Code extension

#### Installation and requirements

- VS Code 1.98.0+ required
- Install from marketplace: search "Claude Code" or use `vscode:extension/anthropic.claude-code`
- Also works in Cursor: `cursor:extension/anthropic.claude-code`
- Includes CLI; no separate Node.js install needed for extension

#### Key shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | Open new tab |
| `Option+K` / `Alt+K` | Insert @-mention reference with file and line range |
| `Cmd+N` / `Ctrl+N` | New conversation (requires `enableNewConversationShortcut: true`) |

#### Extension settings

| Setting | Default | Description |
| :--- | :--- | :--- |
| `useTerminal` | `false` | CLI-style interface instead of graphical panel |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before read/write |
| `useCtrlEnterToSend` | `false` | Ctrl/Cmd+Enter to send instead of Enter |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto mode and Bypass permissions to mode selector |
| `claudeProcessWrapper` | - | Executable path to launch Claude process |

#### URI handler

Open a Claude Code tab from external tools: `vscode://anthropic.claude-code/open`

| Parameter | Description |
| :--- | :--- |
| `prompt` | URL-encoded text to pre-fill (not auto-submitted) |
| `session` | Session ID to resume |

#### Built-in IDE MCP server

- Runs on `127.0.0.1` with random port and per-activation auth token
- Two model-visible tools: `mcp__ide__getDiagnostics` (read-only), `mcp__ide__executeCode` (Jupyter; always prompts Execute/Cancel)
- Token stored in `~/.claude/ide/` with `0600` permissions

#### Checkpoints (rewind)

Three options on hover: Fork conversation from here, Rewind code to here, Fork conversation and rewind code.

### JetBrains plugin

- Supports IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand
- Install from JetBrains marketplace; restart IDE after install
- Quick launch: `Cmd+Esc` (Mac) / `Ctrl+Esc` (Windows/Linux)
- File references: `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Windows/Linux)
- Configure diff tool via `/config` (set to `auto` for IDE diffs)
- Plugin settings at **Settings > Tools > Claude Code [Beta]**: custom command, Option+Enter for multi-line, auto-updates
- Remote Development: install plugin in remote host via **Settings > Plugin (Host)**
- WSL: may need additional terminal/networking/firewall configuration

### Chrome integration

- Requires Claude in Chrome extension v1.0.36+ and Claude Code v2.0.73+
- Works with Google Chrome and Microsoft Edge (not Brave, Arc, or other Chromium)
- WSL not supported
- Start with `claude --chrome` or `/chrome` in session; VS Code uses `@browser`
- Enable by default via `/chrome` > "Enabled by default" (increases context usage)
- Site permissions managed in Chrome extension settings
- Capabilities: console reading, DOM inspection, form filling, data extraction, task automation, GIF recording
- Shares browser login state; pauses on login pages/CAPTCHAs

Native messaging host config paths:
- macOS Chrome: `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Linux Chrome: `~/.config/google-chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`

### Computer use (CLI)

- macOS only; Pro or Max plan; Claude Code v2.1.85+; interactive sessions only
- Enable via `/mcp` > `computer-use` > Enable (persists per project)
- Requires macOS Accessibility + Screen Recording permissions
- Machine-wide lock: one session at a time
- Apps hidden while Claude works; terminal excluded from screenshots
- Screenshots auto-downscaled (e.g. 3456x2234 to ~1372x887)
- Stop anytime with `Esc` or `Ctrl+C`

| Feature | Desktop | CLI |
| :--- | :--- | :--- |
| Platforms | macOS, Windows | macOS only |
| Enable | Settings > General | `/mcp` > `computer-use` |
| Denied apps list | Configurable | Not available |
| Auto-unhide toggle | Optional | Always on |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) — full Desktop app reference: sessions, permission modes, workspace layout, diff review, preview servers, computer use, PR monitoring, connectors, plugins, SSH, remote sessions, Dispatch, enterprise configuration, CLI comparison, and troubleshooting.
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — Desktop app installation, first session walkthrough, environment and model selection, reviewing changes, and next steps.
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — VS Code extension installation, @-mentions, permission modes, plan review, session history, plugin management, Chrome integration, commands and shortcuts, settings, IDE MCP server, checkpoints, third-party providers, and troubleshooting.
- [JetBrains IDEs](references/claude-code-jetbrains.md) — JetBrains plugin installation, supported IDEs, diff viewing, selection context, file references, diagnostics, remote development, WSL configuration, and troubleshooting.
- [Use Claude Code with Chrome](references/claude-code-chrome.md) — Chrome extension setup, browser automation capabilities, CLI and VS Code usage, site permissions, example workflows (testing, debugging, form filling, data extraction), and troubleshooting.
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — CLI computer use setup, macOS permissions, per-app approval tiers, screen control flow, safety guardrails, example workflows, and differences from Desktop.

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
