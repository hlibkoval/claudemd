---
name: ide-doc
user-invocable: false
---

# IDE and Desktop Integration Documentation

This skill provides the complete official documentation for Claude Code IDE and desktop integrations — the Claude Code Desktop app (macOS/Windows), VS Code extension, JetBrains plugin, Chrome browser integration, and computer use from the CLI.

## Quick Reference

### Integration Surface Overview

| Surface | Platform | Prerequisites | Key distinction |
| :--- | :--- | :--- | :--- |
| **Desktop app (Code tab)** | macOS, Windows | Pro/Max/Team/Enterprise subscription | Full GUI with parallel sessions, diff view, preview pane |
| **VS Code extension** | Any OS with VS Code 1.98.0+ | Paid subscription or Console account | Graphical panel inside VS Code; bundles its own CLI copy |
| **JetBrains plugin** | IntelliJ, PyCharm, WebStorm, Android Studio, GoLand, PhpStorm | CLI installed separately + plugin | Runs `claude` in IDE's integrated terminal |
| **Chrome integration** | Chrome or Edge (beta) | Claude in Chrome extension v1.0.36+; Claude Code v2.0.73+; direct Anthropic plan | Browser automation: console logs, DOM, forms, authenticated apps |
| **Computer use (CLI)** | macOS only (CLI); macOS + Windows (Desktop) | Pro or Max plan; Claude Code v2.1.85+; interactive session | Screen control for GUI-only apps, simulators, native apps |

### Desktop App: Permission Modes

| Mode | Settings key | Behavior |
| :--- | :--- | :--- |
| **Ask permissions** | `default` | Claude asks before editing files or running commands |
| **Auto accept edits** | `acceptEdits` | Auto-accepts file edits and common filesystem commands; still asks before other terminal commands |
| **Plan mode** | `plan` | Reads and explores but proposes a plan without editing source code |
| **Auto** | `auto` | Executes all actions with background safety checks. Requires Opus 4.6+ or Sonnet 4.6; research preview |
| **Bypass permissions** | `bypassPermissions` | No permission prompts (except forced ask rules). Enable in Settings → Claude Code. Enterprise admins can disable. |

`dontAsk` mode is CLI-only.

### Desktop App: Keyboard Shortcuts

| Shortcut (macOS) | Action |
| :--- | :--- |
| `Cmd+/` | Show keyboard shortcuts |
| `Cmd+N` | New session |
| `Cmd+W` | Close session |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next / previous session |
| `Esc` | Stop Claude's response |
| `Cmd+Shift+D` | Toggle diff pane |
| `Cmd+Shift+P` | Toggle preview pane |
| `Ctrl+`` ` `` ` | Toggle terminal pane |
| `Cmd+\` | Close focused pane |
| `Cmd+;` | Open side chat |
| `Ctrl+O` | Cycle view modes (Normal / Verbose / Summary) |
| `Cmd+Shift+M` | Open permission mode menu |
| `Cmd+Shift+I` | Open model menu |
| `Cmd+Shift+E` | Open effort menu |

On Windows, use `Ctrl` in place of `Cmd` (except session cycling and terminal toggle, which always use `Ctrl`).

### Desktop App: Session Environments

| Environment | Description | Notes |
| :--- | :--- | :--- |
| **Local** | Runs on your machine with direct file access | macOS, Windows. Git required on Windows. |
| **Remote** | Anthropic-hosted cloud; continues even when app is closed | Multiple repos supported; no Bypass permissions mode |
| **SSH** | Claude runs on a remote machine via SSH | Linux or macOS remote; Desktop auto-installs CLI on first connect |

### Desktop App: Launch.json Configuration Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments to `runtimeExecutable` |
| `port` | number | Port your server listens on (default 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional env vars (no secrets; use local env editor instead) |
| `autoPort` | boolean | `true` finds a free port; `false` fails on conflict; omit to prompt |
| `program` | string | Script to run with `node` directly |
| `args` | string[] | Arguments to `program` |
| `autoVerify` | boolean | Top-level field; set `false` to disable auto-verification after edits |

### Desktop App: CLI Flag Equivalents

| CLI flag | Desktop equivalent |
| :--- | :--- |
| `--model` | Model dropdown next to send button |
| `--resume`, `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector |
| `--dangerously-skip-permissions` | Bypass permissions mode (Settings → Claude Code) |
| `--add-dir` | + button in cloud sessions |
| `--verbose` | Verbose view mode |
| `--print`, `--output-format` | Not available (Desktop is interactive only) |

### Desktop App: Managed Settings Keys

| Key | Description |
| :--- | :--- |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to block Bypass permissions mode |
| `disableAutoMode` | Set to `"disable"` to remove Auto from mode selector |
| `autoMode` | Customize classifier trust/block rules organization-wide |
| `sshConfigs` | Pre-configure SSH connections for team members |
| `sshHostAllowlist` | Restrict SSH sessions to approved host patterns; empty array disables SSH |
| `managedMcpServers` | Push MCP server configs to users (3P deployments only) |

### Desktop App: Computer Use App Permission Tiers

| Tier | What Claude can do | Applies to |
| :--- | :--- | :--- |
| View only | See app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, not type or keyboard shortcuts | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

### VS Code Extension: Settings

| Setting | Default | Description |
| :--- | :--- | :--- |
| `useTerminal` | `false` | Launch Claude in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | Default permission mode for new conversations |
| `preferredLocation` | `panel` | `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads or writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter to send instead of Enter |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N for new conversation |
| `enableReopenClosedSessionShortcut` | `true` | Cmd/Ctrl+Shift+T to reopen closed Claude session |
| `hideOnboarding` | `false` | Hide the onboarding checklist |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `usePythonEnvironment` | `true` | Activate workspace Python environment |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party provider setups) |
| `allowDangerouslySkipPermissions` | `false` | Add Bypass permissions to mode selector |

### VS Code Extension: Keyboard Shortcuts

| Shortcut (macOS) | Action |
| :--- | :--- |
| `Cmd+Esc` | Toggle focus between editor and Claude |
| `Cmd+Shift+Esc` | Open new conversation as editor tab |
| `Cmd+N` | New conversation (requires `enableNewConversationShortcut: true`) |
| `Cmd+Shift+T` | Reopen most recently closed Claude session tab |
| `Option+K` | Insert @-mention reference to current file/selection |

### VS Code Extension: Built-in IDE MCP Server Tools

| Tool | Writes? | Description |
| :--- | :--- | :--- |
| `mcp__ide__getDiagnostics` | No | Returns language-server diagnostics from VS Code Problems panel |
| `mcp__ide__executeCode` | Yes | Runs Python code in the active Jupyter notebook kernel (always prompts for confirmation) |

### VS Code Extension: URI Handler

Open a new Claude Code tab from external tooling via `vscode://anthropic.claude-code/open`.

| Parameter | Description |
| :--- | :--- |
| `prompt` | URL-encoded text to pre-fill in the prompt box |
| `session` | Session ID to resume instead of starting a new conversation |

### VS Code Extension vs CLI Feature Comparison

| Feature | CLI | VS Code Extension |
| :--- | :--- | :--- |
| Commands and skills | All | Subset (type `/` to see available) |
| MCP server config | Full | Partial (add via CLI; manage existing with `/mcp`) |
| Checkpoints | Yes | Yes |
| `!` bash shortcut | Yes | No |
| Tab completion | Yes | No |

### JetBrains Plugin: Key Details

- Requires the CLI to be installed separately (does not bundle it)
- Quick launch: `Cmd+Esc` (Mac) / `Ctrl+Esc` (Windows/Linux)
- File reference: `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Linux/Windows) inserts `@src/file.ts#L1-99`
- Diff tool setting: `auto` shows diffs in IDE viewer; `terminal` keeps them in terminal
- Remote development: install the plugin on the **remote host**, not the local client
- WSL2 issue fix: add a Windows Firewall inbound rule allowing WSL2 subnet traffic, or switch to `networkingMode=mirrored` in `.wslconfig` (Windows 11 22H2+)
- Connect an external terminal to JetBrains: run `/ide` in Claude Code

### Chrome Integration: Capabilities and Setup

- Start with `claude --chrome` or run `/chrome` inside a session
- Enable by default: run `/chrome` and select "Enabled by default"
- Capabilities: live debugging (console logs, DOM), design verification, web app testing, authenticated app interaction (Google Docs, Gmail, Notion), data extraction, form automation, multi-site workflows, GIF recording
- Limitations: Chrome and Edge only (not Brave, Arc); no WSL support; not available via third-party providers

### Computer Use (CLI): Key Details

- Enable: run `/mcp` in an interactive session and enable the `computer-use` server
- macOS only in the CLI; macOS and Windows in the Desktop app
- Requires Accessibility and Screen Recording permissions on macOS
- Holds a machine-wide lock while active (one session at a time)
- Terminal window is excluded from screenshots (Claude cannot see its own terminal output)
- Stop: press `Esc` anywhere or `Ctrl+C` in the terminal
- App approvals last for the current session
- Per-session per-app approval required; tier-based access (view-only for browsers/trading platforms, click-only for terminals/IDEs, full control for everything else)

## Full Documentation

For the complete official documentation, see the reference files:

- [Desktop application](references/claude-code-desktop.md) — Full reference for the Code tab: sessions, permission modes, diff view, preview pane, parallel sessions, SSH, cloud, computer use, enterprise configuration, CLI comparison, troubleshooting
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — Installation walkthrough, first session steps, and feature tour
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — Extension install, graphical panel, @-mentions, checkpoints, plugin manager, Chrome browser integration, MCP, third-party providers, IDE MCP server internals, troubleshooting
- [JetBrains IDEs](references/claude-code-jetbrains.md) — Plugin install, diff viewing, selection context, file references, WSL2 configuration, remote development, troubleshooting
- [Use Claude Code with Chrome (beta)](references/claude-code-chrome.md) — Setup, capabilities, example workflows (debugging, form filling, data extraction, GIF recording), troubleshooting
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — Enable computer use MCP server, per-app approval flow, safety guardrails, example workflows, differences from Desktop, troubleshooting

## Sources

- Desktop application: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome (beta): https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
