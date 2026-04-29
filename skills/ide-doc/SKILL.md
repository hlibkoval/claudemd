---
name: ide-doc
description: Complete official documentation for Claude Code IDE and desktop integrations — VS Code extension, JetBrains plugin, Claude Desktop app (quickstart and full reference), Chrome browser integration, and CLI computer use. Covers installation, permission modes, keyboard shortcuts, settings, session management, diff review, app preview, SSH sessions, and enterprise configuration.
user-invocable: false
---

# IDE and Desktop Integrations Documentation

This skill provides the complete official documentation for Claude Code IDE integrations and desktop interfaces.

## Quick Reference

### Available Surfaces

| Surface | Platform | Key entry point |
| :--- | :--- | :--- |
| VS Code extension | VS Code / Cursor | Install from marketplace; Spark icon in editor toolbar |
| JetBrains plugin | IntelliJ, PyCharm, WebStorm, GoLand, etc. | JetBrains Marketplace; run `claude` in integrated terminal |
| Claude Desktop app | macOS, Windows (no Linux) | Download from claude.ai; Code tab |
| Chrome integration | Chrome, Edge (beta) | `claude --chrome` or `/chrome` in CLI; `@browser` in VS Code |
| Computer use (CLI) | macOS only (Pro/Max) | Enable `computer-use` via `/mcp` |

---

### VS Code Extension

**Prerequisites:** VS Code 1.98.0+, Anthropic account.

**Install:** Search "Claude Code" in Extensions (`Cmd+Shift+X` / `Ctrl+Shift+X`) or open `vscode:extension/anthropic.claude-code`.

**Key shortcuts:**

| Command | Shortcut (Mac / Win-Linux) | Description |
| :--- | :--- | :--- |
| Focus Input | `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| Open in New Tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | New conversation as editor tab |
| Insert @-Mention | `Option+K` / `Alt+K` | Reference current file + selection |
| New Conversation | `Cmd+N` / `Ctrl+N` | Requires `enableNewConversationShortcut: true` and Claude focused |

**Extension settings (`Extensions → Claude Code`):**

| Setting | Default | Description |
| :--- | :--- | :--- |
| `useTerminal` | `false` | Launch Claude in terminal instead of graphical panel |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` (right) or `panel` (new tab) |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter to send |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N for new conversation |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `usePythonEnvironment` | `true` | Activate workspace Python environment |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party providers) |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto mode and Bypass permissions to selector |

**Built-in IDE MCP server (`ide`):**

| Tool | Writes? | What it does |
| :--- | :--- | :--- |
| `mcp__ide__getDiagnostics` | No | Returns language-server diagnostics from the Problems panel |
| `mcp__ide__executeCode` | Yes | Runs Python in the active Jupyter notebook kernel (always prompts) |

**VS Code vs CLI feature comparison:**

| Feature | CLI | VS Code Extension |
| :--- | :--- | :--- |
| Commands and skills | All | Subset (type `/` to see available) |
| MCP server config | Yes | Partial (add via CLI; manage with `/mcp` in panel) |
| Checkpoints | Yes | Yes |
| `!` bash shortcut | Yes | No |
| Tab completion | Yes | No |

---

### JetBrains Plugin

**Install:** [JetBrains Marketplace](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-). Restart IDE after install.

**Key features:**
- Quick launch: `Cmd+Esc` (Mac) / `Ctrl+Esc` (Win/Linux)
- File reference shortcut: `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Win/Linux) — inserts `@src/auth.ts#L1-99` style references
- Diff viewer integration, selection context sharing, diagnostic sharing

**Plugin settings (`Settings → Tools → Claude Code [Beta]`):**
- **Claude command**: custom path (e.g. `claude`, `/usr/local/bin/claude`, or `wsl -d Ubuntu -- bash -lic "claude"` for WSL)
- **Enable automatic updates**: check for and install plugin updates on restart
- **ESC key fix**: `Settings → Tools → Terminal` → uncheck "Move focus to the editor with Escape" to allow ESC to interrupt Claude

**WSL2 fix (if "No available IDEs detected"):** Add firewall rule allowing WSL2 subnet, or set `networkingMode=mirrored` in `.wslconfig` (requires Windows 11 22H2+).

**Remote Development:** Install plugin on the **remote host** via `Settings → Plugin (Host)`, not local client.

---

### Claude Desktop App

**Download:** macOS (Universal) or Windows x64/ARM64 from claude.ai. Linux is not supported.

**Tabs:** Chat (general), Cowork (Dispatch/agentic), **Code** (software development — this doc).

**Permission modes:**

| Mode | Settings key | Behavior |
| :--- | :--- | :--- |
| Ask permissions | `default` | Claude asks before each edit or command |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits + safe filesystem commands |
| Plan mode | `plan` | Claude proposes plan; no edits until you approve |
| Auto | `auto` | Background safety checks; reduced prompts (Max/Team/Enterprise/API; not Pro) |
| Bypass permissions | `bypassPermissions` | No prompts; use only in sandboxed VMs |

**Keyboard shortcuts (macOS; use Ctrl on Windows):**

| Shortcut | Action |
| :--- | :--- |
| `Cmd /` | Show all keyboard shortcuts |
| `Cmd N` | New session |
| `Cmd W` | Close session |
| `Ctrl Tab` / `Ctrl Shift Tab` | Next / previous session |
| `Esc` | Stop Claude's response |
| `Cmd Shift D` | Toggle diff pane |
| `Cmd Shift P` | Toggle preview pane |
| `Ctrl` `` ` `` | Toggle terminal pane |
| `Cmd \` | Close focused pane |
| `Cmd ;` | Open side chat |
| `Ctrl O` | Cycle view modes (Normal / Verbose / Summary) |
| `Cmd Shift M` | Permission mode menu |
| `Cmd Shift I` | Model menu |

**Environments:** Local, Remote (Anthropic-hosted cloud, continues when app closed), SSH (remote machines you manage).

**Sessions:** Each session has its own Git worktree in `<project-root>/.claude/worktrees/`. Use `Cmd+N` to open parallel sessions. Auto-archive after PR merge is configurable.

**Preview server config (`.claude/launch.json`):**

```json
{
  "version": "0.0.1",
  "autoVerify": true,
  "configurations": [
    {
      "name": "web",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"],
      "port": 3000
    }
  ]
}
```

Key `configurations` fields: `name`, `runtimeExecutable`, `runtimeArgs`, `port`, `cwd`, `env`, `autoPort`, `program`, `args`.

**Enterprise managed settings keys:**

| Key | Description |
| :--- | :--- |
| `permissions.disableBypassPermissionsMode` | Set `"disable"` to block bypass mode |
| `disableAutoMode` | Set `"disable"` to block Auto mode |
| `autoMode` | Customize auto mode classifier rules |
| `sshConfigs` | Pre-configure SSH connections for teams |

**SSH config fields:** `id` (required), `name` (required), `sshHost` (required), `sshPort`, `sshIdentityFile`, `startDirectory`.

**CLI flag equivalents in Desktop:**

| CLI flag | Desktop equivalent |
| :--- | :--- |
| `--model` | Model dropdown |
| `--resume`, `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector |
| `--dangerously-skip-permissions` | Bypass permissions mode via Settings |
| `--verbose` | Verbose view mode in Transcript dropdown |
| `--print`, `--output-format` | Not available (Desktop is interactive only) |

---

### Chrome Integration (Beta)

**Requires:** Chrome or Edge, Claude in Chrome extension v1.0.36+, Claude Code v2.0.73+, direct Anthropic plan.

**Enable in CLI:** `claude --chrome` or `/chrome` in session. Enable by default via `/chrome → "Enabled by default"`.

**Enable in VS Code:** Type `@browser` in prompt box — no extra flag needed.

**Capabilities:** Live debugging (console errors, DOM), design verification, form filling, data extraction, multi-site workflows, session GIF recording, authenticated web app access.

**Common troubleshooting:**

| Error | Fix |
| :--- | :--- |
| "Browser extension is not connected" | Restart Chrome and Claude Code, run `/chrome` to reconnect |
| "Extension not detected" | Install/enable extension in `chrome://extensions` |
| "Receiving end does not exist" | Run `/chrome → Reconnect extension` (service worker went idle) |
| "No tab available" | Ask Claude to create a new tab and retry |

---

### Computer Use (CLI, macOS)

**Requires:** Claude Code v2.1.85+, macOS, Pro or Max plan, interactive session (not `-p` flag), direct Anthropic account.

**Enable:** In session run `/mcp`, select `computer-use`, choose **Enable**. Grant macOS Accessibility + Screen Recording permissions.

**App permission tiers (fixed by category):**

| Tier | What Claude can do | Applies to |
| :--- | :--- | :--- |
| View only | See app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll (no typing) | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

**Safety features:** Per-app approval per session, terminal excluded from screenshots, `Esc` aborts from anywhere, global machine-wide lock (one session at a time).

**CLI vs Desktop differences:**

| Feature | Desktop | CLI |
| :--- | :--- | :--- |
| Platforms | macOS + Windows | macOS only |
| Enable | Settings toggle | `/mcp → computer-use` |
| Denied apps list | Configurable | Not available |
| Dispatch integration | Yes | No |

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code Desktop Quickstart](references/claude-code-desktop-quickstart.md) — install, first session, permission modes overview, next steps for new users
- [Claude Code Desktop (full reference)](references/claude-code-desktop.md) — sessions, workspace panes, diff view, PR monitoring, app preview, side chats, parallel sessions, SSH, remote sessions, connectors, plugins, enterprise configuration, CLI comparison, troubleshooting
- [VS Code Extension](references/claude-code-vs-code.md) — install, get started, prompt box, @-mentions, session history, remote sessions, customization, plugin management, Chrome browser automation, keyboard shortcuts, URI handler, settings reference, IDE MCP server, troubleshooting
- [JetBrains IDEs](references/claude-code-jetbrains.md) — supported IDEs, features, install, usage from IDE and external terminals, plugin settings, ESC key fix, WSL and Remote Development configuration, troubleshooting
- [Chrome Integration](references/claude-code-chrome.md) — capabilities, prerequisites, CLI and VS Code setup, example workflows, site permissions, troubleshooting
- [Computer Use (CLI)](references/claude-code-computer-use.md) — enable, app approval flow, permission tiers, safety guardrails, example workflows, differences from Desktop, troubleshooting

## Sources

- Claude Code Desktop Quickstart: https://code.claude.com/docs/en/desktop-quickstart.md
- Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- VS Code Extension: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Chrome Integration: https://code.claude.com/docs/en/chrome.md
- Computer Use (CLI): https://code.claude.com/docs/en/computer-use.md
