---
name: ide-doc
description: Complete official documentation for Claude Code IDE and surface integrations — Desktop app (macOS/Windows), VS Code extension, JetBrains plugin, Chrome browser extension, computer use (CLI and Desktop), and Desktop changelog. Covers installation, permission modes, parallel sessions, diff view, preview servers, SSH sessions, computer use setup and safety, Chrome automation, keyboard shortcuts, enterprise configuration, and troubleshooting.
user-invocable: false
---

# IDE and Surface Integrations Documentation

This skill provides the complete official documentation for Claude Code's IDE integrations and graphical surfaces.

## Quick Reference

### Surfaces at a Glance

| Surface | Platforms | How to get it |
| :--- | :--- | :--- |
| **Desktop app** | macOS, Windows (not Linux) | Download from claude.ai/download |
| **VS Code extension** | VS Code, Cursor, Windsurf, Kiro | `Cmd/Ctrl+Shift+X` → "Claude Code"; or Open VSX |
| **JetBrains plugin** | IntelliJ, PyCharm, WebStorm, Android Studio, GoLand, PhpStorm | JetBrains Marketplace |
| **Chrome integration** | Chrome, Edge (beta; not Brave/Arc/WSL) | Claude in Chrome extension v1.0.36+ + Claude Code v2.0.73+ |
| **Computer use (CLI)** | macOS only (Pro/Max plan, v2.1.85+) | Enable `computer-use` server via `/mcp` |
| **Computer use (Desktop)** | macOS and Windows (Pro/Max plan) | Settings → General → Computer use toggle |

---

### Desktop App

#### Session Environments

| Environment | Where it runs | Persists when app closed? |
| :--- | :--- | :--- |
| **Local** | Your machine | No |
| **Remote** | Anthropic cloud | Yes |
| **SSH** | Remote machine over SSH | No |

#### Permission Modes

| Mode | Settings key | Behavior |
| :--- | :--- | :--- |
| **Ask permissions** | `default` | Asks before every file edit or command |
| **Auto accept edits** | `acceptEdits` | Auto-accepts file edits and common filesystem commands |
| **Plan mode** | `plan` | Proposes a plan without editing source code |
| **Auto** | `auto` | Background safety checks; reduces prompts. Requires Sonnet 4.6, Opus 4.6, or Opus 4.7 via Anthropic API |
| **Bypass permissions** | `bypassPermissions` | No prompts. Enable in Settings → Claude Code. Admins can disable. |

#### Keyboard Shortcuts (Desktop Code Tab)

| Shortcut (macOS) | Action |
| :--- | :--- |
| `Cmd+/` | Show keyboard shortcuts |
| `Cmd+N` | New session |
| `Cmd+W` | Close session |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next/previous session |
| `Esc` | Stop Claude's response |
| `Cmd+Shift+D` | Toggle diff pane |
| `Cmd+Shift+P` | Toggle preview pane |
| `Ctrl+\`` | Toggle terminal pane |
| `Cmd+\` | Close focused pane |
| `Cmd+;` | Open side chat |
| `Ctrl+O` | Cycle view modes |

#### View Modes

| Mode | Shows |
| :--- | :--- |
| **Normal** | Tool calls collapsed into summaries, full text responses |
| **Verbose** | Every tool call, file read, and intermediate step |
| **Summary** | Only Claude's final responses and changes made |

#### Preview Server `launch.json` Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique identifier for this server |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments to `runtimeExecutable` |
| `port` | number | Port to listen on (default 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Environment variables as key-value pairs |
| `autoPort` | boolean | `true` = find free port; `false` = fail if busy; omitted = ask |
| `program` | string | Node script to run directly (alternative to `runtimeExecutable`) |
| `args` | string[] | Arguments to `program` |
| `autoVerify` | boolean | Top-level flag; `false` disables auto-verification after edits |

#### Computer Use App Permission Tiers (Desktop)

| Tier | What Claude can do | Applies to |
| :--- | :--- | :--- |
| View only | See app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, no typing | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

#### SSH Config Fields (`sshConfigs` in managed settings)

| Field | Required | Description |
| :--- | :--- | :--- |
| `id` | Yes | Unique identifier |
| `name` | Yes | Display label |
| `sshHost` | Yes | `user@hostname` or SSH config alias |
| `sshPort` | No | Defaults to 22 |
| `sshIdentityFile` | No | Path to private key |
| `startDirectory` | No | Initial working directory on remote |

#### CLI Flag Equivalents in Desktop

| CLI flag | Desktop equivalent |
| :--- | :--- |
| `--model sonnet` | Model dropdown next to send button |
| `--resume`, `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (enable in Settings) |
| `--verbose` | Verbose view mode in Transcript view dropdown |
| `--print`, `--output-format` | Not available (Desktop is interactive only) |

---

### VS Code Extension

#### Extension Settings

| Setting | Default | Description |
| :--- | :--- | :--- |
| `useTerminal` | `false` | Launch Claude in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | Default permission mode for new conversations |
| `preferredLocation` | `panel` | Where Claude opens: `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter to send |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N for new conversation |
| `enableReopenClosedSessionShortcut` | `true` | Cmd/Ctrl+Shift+T reopens last closed Claude session tab |
| `hideOnboarding` | `false` | Hide the onboarding checklist |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `usePythonEnvironment` | `true` | Activate workspace Python env (requires Python extension) |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party provider setups) |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto mode and Bypass permissions to mode selector |

#### VS Code Keyboard Shortcuts

| Command | Shortcut (macOS) | Description |
| :--- | :--- | :--- |
| Focus Input | `Cmd+Esc` | Toggle focus between editor and Claude |
| Open in New Tab | `Cmd+Shift+Esc` | Open new conversation as editor tab |
| New Conversation | `Cmd+N` | Requires `enableNewConversationShortcut: true` |
| Reopen Closed Session | `Cmd+Shift+T` | Reopen most recently closed Claude session tab |
| Insert @-Mention Reference | `Option+K` | Insert file + line range reference (editor must be focused) |

#### IDE MCP Server Tools (VS Code)

| Tool name | What it does | Writes? |
| :--- | :--- | :--- |
| `mcp__ide__getDiagnostics` | Returns language-server diagnostics (Problems panel) | No |
| `mcp__ide__executeCode` | Runs Python code in active Jupyter notebook kernel (always prompts) | Yes |

#### CLI vs. VS Code Extension Feature Comparison

| Feature | CLI | VS Code Extension |
| :--- | :--- | :--- |
| Commands and skills | All | Subset (type `/` to see available) |
| MCP server config | Full | Partial (add via CLI; manage via `/mcp`) |
| Checkpoints / rewind | Yes | Yes |
| `!` bash shortcut | Yes | No |
| Tab completion | Yes | No |

---

### JetBrains Plugin

#### Key Features

- Quick launch: `Cmd+Esc` (Mac) / `Ctrl+Esc` (Windows/Linux) to open Claude Code from the editor
- Diff viewing in IDE diff viewer (set diff tool to `auto` via `/config`)
- Automatic selection context sharing with Claude (blocked by `Read` deny rules)
- File reference shortcut: `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Linux/Windows) for `@src/file.ts#L1-99` format
- Automatic diagnostic (lint/syntax error) sharing

#### Plugin Settings Path

Settings → Tools → Claude Code [Beta]

| Setting | Notes |
| :--- | :--- |
| Claude command | Custom path, e.g. `claude`, `/usr/local/bin/claude`, or `npx @anthropic-ai/claude-code` |
| WSL command format | `wsl -d Ubuntu -- bash -lic "claude"` |
| Enable automatic updates | Applied on restart |
| ESC key fix | Settings → Tools → Terminal → uncheck "Move focus to the editor with Escape" |

#### Remote Development

Must install the plugin on the **remote host** (Settings → Plugin (Host)), not the local client.

#### WSL2 + JetBrains ("No available IDEs detected")

Option A — Add Windows Firewall rule to allow WSL2 subnet:
```powershell
New-NetFirewallRule -DisplayName "Allow WSL2 Internal Traffic" -Direction Inbound -Protocol TCP -Action Allow -RemoteAddress 172.21.0.0/16 -LocalAddress 172.21.0.0/16
```

Option B — Switch to mirrored networking (Windows 11 22H2+): add `networkingMode=mirrored` to `.wslconfig`, then `wsl --shutdown`.

---

### Chrome Integration

#### Prerequisites

- Google Chrome or Microsoft Edge (not Brave, Arc, or other Chromium; not WSL)
- Claude in Chrome extension v1.0.36+ (Chrome Web Store)
- Claude Code v2.0.73+
- Direct Anthropic plan (Pro, Max, Team, or Enterprise) — not available via Bedrock/Vertex/Foundry

#### Usage

```bash
claude --chrome          # Start with Chrome enabled
```

Or run `/chrome` inside an existing session to connect, check status, or reconnect. Run `/mcp` → `claude-in-chrome` to see all available browser tools.

To enable Chrome by default: run `/chrome` → "Enabled by default". Note: increases context usage since browser tools always load.

#### Chrome Integration Common Errors

| Error | Cause | Fix |
| :--- | :--- | :--- |
| "Browser extension is not connected" | Native messaging host can't reach extension | Restart Chrome and Claude Code, run `/chrome` to reconnect |
| "Extension not detected" | Extension not installed or disabled | Install/enable in `chrome://extensions` |
| "No tab available" | Claude acted before a tab was ready | Ask Claude to create a new tab and retry |
| "Receiving end does not exist" | Extension service worker went idle | Run `/chrome` → "Reconnect extension" |

#### Native Messaging Host Config File Locations

| Browser | macOS | Linux |
| :--- | :--- | :--- |
| Chrome | `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` | `~/.config/google-chrome/NativeMessagingHosts/…` |
| Edge | `~/Library/Application Support/Microsoft Edge/NativeMessagingHosts/…` | `~/.config/microsoft-edge/NativeMessagingHosts/…` |

---

### Computer Use

#### When Claude Uses Computer Use vs. Other Tools

Claude tries the most precise tool first, in this order:
1. MCP server (if configured for the service)
2. Bash (if task is a shell command)
3. Claude in Chrome (if task is browser work and Chrome is set up)
4. Computer use (last resort — native apps, simulators, GUI-only tools)

#### Differences: CLI vs. Desktop Computer Use

| Feature | Desktop | CLI |
| :--- | :--- | :--- |
| Platforms | macOS and Windows | macOS only |
| Enable | Settings → General → Computer use toggle | Enable `computer-use` in `/mcp` |
| Denied apps list | Configurable in Settings | Not yet available |
| Auto-unhide toggle | Optional | Always on |
| Requirements | Pro or Max plan | Pro or Max plan, Claude Code v2.1.85+, interactive session (no `-p` flag) |

#### Safety Guardrails (Computer Use)

- Per-app approval required each session (Desktop: 30-min expiry for Dispatch-spawned sessions)
- Apps with broad reach (terminals, Finder, System Settings) show extra warning before approval
- Terminal excluded from screenshots — Claude never sees its own output
- Press `Esc` anywhere to abort immediately; lock is released and hidden apps are restored
- Machine-wide lock: only one Claude session can use computer use at a time

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Desktop application](references/claude-code-desktop.md) — permission modes, parallel sessions, diff view, preview servers, SSH sessions, computer use, enterprise configuration, CLI comparison
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — install, first session walkthrough, key features overview
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — extension install, prompt box, @-mentions, plugin manager, Chrome integration, settings reference, built-in IDE MCP server, CLI comparison
- [JetBrains IDEs](references/claude-code-jetbrains.md) — plugin install, features, configuration, WSL2 troubleshooting, remote development
- [Use Claude Code with Chrome (beta)](references/claude-code-chrome.md) — setup, capabilities, example workflows, troubleshooting
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — enable via `/mcp`, app approvals, safety, CLI vs. Desktop differences
- [Desktop changelog](references/claude-code-desktop-changelog.md) — release notes for Desktop app versions

## Sources

- Desktop application: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome (beta): https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
- Desktop changelog: https://code.claude.com/docs/en/desktop-changelog.md
