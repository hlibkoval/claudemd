---
name: ide-doc
description: Complete official documentation for Claude Code IDE and desktop integrations — VS Code extension, JetBrains plugin, Claude Desktop app (Code tab), Chrome browser automation, and computer use from the CLI.
user-invocable: false
---

# IDE and Desktop Integration Documentation

This skill provides the complete official documentation for Claude Code's graphical interfaces and IDE integrations.

## Quick Reference

### VS Code Extension

**Requirements:** VS Code 1.98.0+, Anthropic account (or third-party provider config)

**Install:** `Cmd+Shift+X` → search "Claude Code" → Install, or direct link: `vscode:extension/anthropic.claude-code`

**Open Claude:** Spark icon in Editor Toolbar (top-right, requires a file open), Activity Bar (left sidebar), Status Bar (bottom-right `✱ Claude Code`), or Command Palette

**Key shortcuts:**

| Shortcut | Action |
| :--- | :--- |
| `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | Open new conversation as editor tab |
| `Option+K` / `Alt+K` | Insert @-mention reference for current selection |
| `Cmd+N` / `Ctrl+N` | New conversation (requires `enableNewConversationShortcut: true`) |
| `Cmd+Shift+P` / `Ctrl+Shift+P` | Command Palette → type "Claude Code" |

**Extension settings (`Extensions → Claude Code`):**

| Setting | Default | Description |
| :--- | :--- | :--- |
| `useTerminal` | `false` | Launch in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` (right) or `panel` (new tab) |
| `autosave` | `true` | Auto-save files before Claude reads or writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter to send |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N for new conversations |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `usePythonEnvironment` | `true` | Activate workspace Python environment |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party provider setups) |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto mode and Bypass permissions to mode selector |

**Claude Code settings (shared with CLI):** `~/.claude/settings.json` — add `"$schema": "https://json.schemastore.org/claude-code-settings.json"` for autocomplete

**@-mention files:** Type `@filename` for fuzzy match; trailing `/` for folders; select text then `Option+K`/`Alt+K` to insert reference like `@app.ts#5-10`

**Launch URI handler:** `vscode://anthropic.claude-code/open` — opens a new Claude Code tab from scripts or bookmarklets. Query params: `prompt=<url-encoded-text>`, `session=<session-id>`

**VS Code extension vs CLI:**

| Feature | CLI | VS Code Extension |
| :--- | :--- | :--- |
| Commands and skills | All | Subset (type `/` to see available) |
| MCP server config | Yes | Partial (`claude mcp add` to configure; `/mcp` to manage) |
| Checkpoints / rewind | Yes | Yes |
| `!` bash shortcut | Yes | No |
| Tab completion | Yes | No |

**Built-in IDE MCP server (hidden from `/mcp`):** Runs locally on `127.0.0.1`, random port, token-authenticated. Tools visible to the model:

| Tool | What it does | Writes? |
| :--- | :--- | :--- |
| `mcp__ide__getDiagnostics` | Returns VS Code Problems panel diagnostics, optionally scoped to one file | No |
| `mcp__ide__executeCode` | Runs Python in active Jupyter notebook kernel (always prompts via Quick Pick first) | Yes |

---

### JetBrains Plugin

**Supported IDEs:** IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand

**Install:** JetBrains Marketplace → search "Claude Code" (plugin ID: `27310`) → Install → restart IDE

**Key shortcuts:**

| Shortcut | Action |
| :--- | :--- |
| `Cmd+Esc` / `Ctrl+Esc` | Open Claude Code from editor |
| `Cmd+Option+K` / `Alt+Ctrl+K` | Insert file reference (e.g., `@src/auth.ts#L1-99`) |

**Features:** Diff viewing in IDE viewer, automatic selection/tab context sharing, diagnostic sharing (lint/syntax errors auto-sent to Claude)

**From external terminal:** Run `/ide` inside Claude Code to connect to your JetBrains IDE.

**Plugin settings (`Settings → Tools → Claude Code [Beta]`):**
- **Claude command**: custom path, e.g., `claude`, `/usr/local/bin/claude`, `npx @anthropic-ai/claude-code`
- **WSL:** set command to `wsl -d Ubuntu -- bash -lic "claude"`
- **ESC key fix:** `Settings → Tools → Terminal` → uncheck "Move focus to editor with Escape"
- **Remote Development:** install plugin in remote host via `Settings → Plugin (Host)`, not local client

**WSL2 networking fix (if "No available IDEs detected"):**
Option 1 — Firewall rule (recommended):
```powershell
New-NetFirewallRule -DisplayName "Allow WSL2 Internal Traffic" -Direction Inbound -Protocol TCP -Action Allow -RemoteAddress 172.21.0.0/16 -LocalAddress 172.21.0.0/16
```
Option 2 — Mirrored networking (Windows 11 22H2+): add `networkingMode=mirrored` to `.wslconfig`

---

### Claude Desktop App (Code Tab)

**Download:** macOS (Intel + Apple Silicon), Windows x64/ARM64 — not available on Linux (use CLI)

**Requirements:** Pro, Max, Team, or Enterprise subscription; Git for Windows (required for Code tab on Windows)

**Session setup (configure before first message):**
- **Environment:** Local / Remote / SSH
- **Project folder:** select working directory
- **Model:** dropdown next to send button (changeable mid-session)
- **Permission mode:** mode selector (changeable mid-session)

**Permission modes:**

| Mode | Settings key | Behavior |
| :--- | :--- | :--- |
| Ask permissions | `default` | Asks before every edit or command |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits and common fs commands; asks for other terminal commands |
| Plan mode | `plan` | Explores and proposes plan without editing source code |
| Auto | `auto` | Background safety checks; research preview on Max/Team/Enterprise/API plans |
| Bypass permissions | `bypassPermissions` | No prompts — sandboxes only |

**Desktop keyboard shortcuts (macOS; use Ctrl instead of Cmd on Windows):**

| Shortcut | Action |
| :--- | :--- |
| `Cmd+N` | New session |
| `Cmd+W` | Close session |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next / previous session |
| `Esc` | Stop Claude's response |
| `Cmd+Shift+D` | Toggle diff pane |
| `Cmd+Shift+P` | Toggle preview pane |
| `Ctrl+\`` | Toggle terminal pane |
| `Cmd+\` | Close focused pane |
| `Cmd+;` | Open side chat |
| `Ctrl+O` | Cycle view modes (Normal / Verbose / Summary) |
| `Cmd+Shift+M` | Open permission mode menu |
| `Cmd+Shift+I` | Open model menu |
| `Cmd+/` | Show all keyboard shortcuts |

**Panes:** Chat, diff, preview, terminal, file editor, plan, tasks, subagent — drag headers to reposition, drag edges to resize

**Preview server config (`.claude/launch.json`):**

```json
{
  "version": "0.0.1",
  "autoVerify": true,
  "configurations": [
    {
      "name": "my-app",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"],
      "port": 3000,
      "autoPort": true
    }
  ]
}
```

Config fields: `name`, `runtimeExecutable`, `runtimeArgs`, `port` (default 3000), `cwd`, `env`, `autoPort` (`true`=find free port, `false`=fail on conflict), `program` (Node script), `args`

**Session environments:**
- **Local:** direct file access; env vars via environment dropdown gear icon or `env` key in `~/.claude/settings.json`
- **Remote:** Anthropic-hosted cloud; continues if app closed; supports multi-repo; monitor at claude.ai/code or iOS app
- **SSH:** remote machine (Linux/macOS); Desktop installs Claude Code on first connect; supports permission modes, connectors, plugins, MCP

**SSH connection fields:** `name`, `sshHost` (required), `sshPort`, `sshIdentityFile`, `startDirectory`

**Pre-configure SSH for teams** (`sshConfigs` in managed settings):
```json
{
  "sshConfigs": [
    {
      "id": "shared-dev-vm",
      "name": "Shared Dev VM",
      "sshHost": "user@dev.example.com",
      "sshPort": 22,
      "sshIdentityFile": "~/.ssh/id_ed25519",
      "startDirectory": "~/projects"
    }
  ]
}
```

**Session features:**
- **Parallel sessions:** `Cmd+N` — each gets its own Git worktree in `<project>/.claude/worktrees/`
- **Side chat:** `Cmd+;` or `/btw` — asks a question using session context without adding to main thread
- **Diff view:** click `+12 -1` indicator; click lines to comment; `Cmd+Enter` to submit all comments
- **PR monitoring:** auto-fix failing CI, auto-merge (squash) once checks pass — requires `gh` CLI
- **Continue in:** move local session to web (remote) or open project in IDE

**Enterprise managed settings keys:**

| Key | Description |
| :--- | :--- |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to block Bypass permissions mode |
| `disableAutoMode` | Set to `"disable"` to remove Auto from mode selector |
| `autoMode` | Configure auto mode classifier trust/block rules |
| `sshConfigs` | Pre-configure SSH connections |

**CLI flag equivalents in Desktop:**

| CLI flag | Desktop equivalent |
| :--- | :--- |
| `--model` | Model dropdown |
| `--resume`, `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector |
| `--dangerously-skip-permissions` | Bypass permissions mode (Settings → Claude Code) |
| `--verbose` | Verbose view mode (Transcript view dropdown) |
| `/desktop` (in CLI) | Move CLI session to Desktop app |

**Computer use in Desktop:** macOS and Windows, Pro/Max plan only (not Team/Enterprise). Enable via `Settings > General`. Requires Accessibility + Screen Recording permissions on macOS. App permission tiers: browsers = view-only, terminals/IDEs = click-only, everything else = full control. Dispatch-spawned sessions: approvals expire after 30 min.

---

### Chrome Browser Automation

**Requirements:** Claude Code v2.0.73+, Claude in Chrome extension v1.0.36+ (Chrome or Edge), Pro/Max/Team/Enterprise plan (not third-party providers)

**CLI usage:**
```bash
claude --chrome          # Start with Chrome enabled
/chrome                  # Check status, reconnect, or enable by default
```

**VS Code usage:** type `@browser <task>` in prompt box (extension auto-detects Chrome extension)

**Capabilities:** live debugging (console errors + DOM), UI testing, form automation, authenticated web apps (uses your login state), data extraction, multi-site workflows, session recording as GIFs

**Limitations:** not available on Brave, Arc, or WSL; Claude opens new tabs (shares your browser's login state); pauses at login pages and CAPTCHAs

**Common error messages:**

| Error | Fix |
| :--- | :--- |
| "Browser extension is not connected" | Restart Chrome and Claude Code, then `/chrome` to reconnect |
| "Extension not detected" | Install or enable in `chrome://extensions` |
| "No tab available" | Ask Claude to create a new tab and retry |
| "Receiving end does not exist" | Run `/chrome` → "Reconnect extension" (service worker went idle) |

---

### Computer Use (CLI, macOS only)

**Requirements:** Claude Code v2.1.85+, Pro or Max plan, interactive session (not `-p` flag), macOS

**Enable:** run `/mcp` in session → select `computer-use` → Enable → grant Accessibility + Screen Recording permissions (persists per project)

**How it works:** Claude tries more precise tools first (MCP server → Bash → Chrome → computer use). Holds a machine-wide lock while active. Other apps are hidden during use; terminal is excluded from screenshots. Screenshots are downscaled automatically (no resolution change needed).

**Stop at any time:** press `Esc` anywhere, or `Ctrl+C` in terminal

**App permission tiers (same as Desktop):**

| Tier | What Claude can do | Applies to |
| :--- | :--- | :--- |
| View only | See in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, no typing | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

**CLI vs Desktop computer use:**

| Feature | Desktop | CLI |
| :--- | :--- | :--- |
| Platforms | macOS and Windows | macOS only |
| Enable | Settings > General toggle | `/mcp` → enable `computer-use` |
| Denied apps list | Configurable | Not available |
| Dispatch integration | Yes | N/A |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) — Code tab reference: sessions, permission modes, diff view, preview servers, parallel sessions, SSH, remote sessions, computer use, enterprise configuration, CLI comparison
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — Installation walkthrough, first session, and feature overview for Claude Desktop
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — VS Code extension installation, prompt box, @-mentions, settings, CLI comparison, built-in IDE MCP server, plugins, checkpoints, MCP setup
- [JetBrains IDEs](references/claude-code-jetbrains.md) — JetBrains plugin installation, features, WSL2 troubleshooting, remote development
- [Use Claude Code with Chrome](references/claude-code-chrome.md) — Chrome extension setup, browser automation capabilities, example workflows, troubleshooting
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — CLI computer use setup, app approval flow, safety guardrails, example workflows

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
