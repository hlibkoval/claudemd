---
name: ide-doc
description: Complete official documentation for Claude Code IDE and desktop integrations — Claude Code Desktop app (macOS/Windows), Desktop quickstart, VS Code extension, JetBrains plugin, Chrome browser integration, computer use (CLI and Desktop), and the Desktop changelog.
user-invocable: false
---

# IDE and Desktop Integration Documentation

This skill provides the complete official documentation for Claude Code IDE integrations and the Desktop app.

## Quick Reference

### Surfaces Overview

| Surface | Platform | Install / Start |
| :--- | :--- | :--- |
| **Claude Code Desktop** | macOS, Windows | Download at claude.ai/download → Code tab |
| **VS Code extension** | VS Code, Cursor, Windsurf, Kiro | Extensions view → search "Claude Code" |
| **JetBrains plugin** | IntelliJ, PyCharm, WebStorm, etc. | JetBrains Marketplace → "Claude Code Beta" |
| **Chrome integration** | Chrome, Edge (not Brave/Arc) | `--chrome` flag or `/chrome` in CLI |
| **Computer use (CLI)** | macOS only | Enable `computer-use` in `/mcp` |
| **Computer use (Desktop)** | macOS and Windows | Settings → General → Computer use toggle |

---

### Desktop App

**Tabs:** Chat (general), Cowork (background agent), Code (interactive coding, local files)

**Session environments:**

| Environment | Where Claude runs |
| :--- | :--- |
| **Local** | Your machine, direct file access |
| **Remote** | Anthropic cloud; continues if you close the app |
| **SSH** | Remote machine via SSH (Linux/macOS); Desktop installs Claude Code automatically |

**Permission modes:**

| Mode | Settings key | Behavior |
| :--- | :--- | :--- |
| Ask permissions | `default` | Claude asks before file edits or commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits and common filesystem commands |
| Plan mode | `plan` | Claude reads and proposes a plan; no edits until approved |
| Auto | `auto` | Background safety checks; Pro/Max/Team/Enterprise; requires Sonnet 4.6+ or Opus 4.7 |
| Bypass permissions | `bypassPermissions` | No prompts; sandboxes only |

**Desktop keyboard shortcuts (macOS; use Ctrl on Windows):**

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
| `Cmd+/` | Show all shortcuts |

**Panes:** chat, diff, preview, terminal, file editor, plan, tasks, subagent (drag to reposition, drag edges to resize)

**Preview / launch.json fields:**

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments to `runtimeExecutable` |
| `port` | number | Listening port (default 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Extra environment variables (no secrets) |
| `autoPort` | boolean | Auto-find free port on conflict |
| `program` | string | Node.js script to run directly |
| `args` | string[] | Args for `program` |
| `autoVerify` | boolean | Root-level; auto-verify after edits (default true) |

**Enterprise managed settings keys:**

| Key | Description |
| :--- | :--- |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to prevent Bypass mode |
| `disableAutoMode` | Set to `"disable"` to remove Auto mode |
| `sshConfigs` | Pre-configure SSH connections (read-only for users) |
| `sshHostAllowlist` | Restrict Desktop SSH to approved hostnames (managed only) |
| `managedMcpServers` | Push MCP configs to all users (3P deployments only) |

**CLI flag equivalents in Desktop:**

| CLI flag | Desktop equivalent |
| :--- | :--- |
| `--model` | Model dropdown next to send button |
| `--resume`, `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector |
| `--dangerously-skip-permissions` | Bypass permissions (Settings → Claude Code) |
| `--add-dir` | + button in remote sessions |
| `--verbose` | Verbose view mode |

---

### VS Code Extension

**Requirements:** VS Code 1.98.0+, Anthropic account (or third-party provider)

**Opening Claude:**
- Spark icon in Editor Toolbar (top-right, requires a file open)
- Activity Bar Spark icon (always visible)
- Command Palette: `Cmd+Shift+P` → "Claude Code"
- Status Bar: "✱ Claude Code" (bottom-right)

**VS Code keyboard shortcuts:**

| Command | Shortcut | Description |
| :--- | :--- | :--- |
| Focus Input | `Cmd+Esc` / `Ctrl+Esc` | Toggle focus editor ↔ Claude |
| Open in New Tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | New conversation as editor tab |
| New Conversation | `Cmd+N` / `Ctrl+N` | Requires `enableNewConversationShortcut: true` |
| Reopen Closed Session | `Cmd+Shift+T` / `Ctrl+Shift+T` | Reopen most recently closed Claude tab |
| Insert @-Mention Reference | `Option+K` / `Alt+K` | Insert file + line reference |

**Extension settings:**

| Setting | Default | Description |
| :--- | :--- | :--- |
| `useTerminal` | `false` | Launch in terminal mode instead of panel |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter to send |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N for new conversation |
| `enableReopenClosedSessionShortcut` | `true` | Enable Cmd/Ctrl+Shift+T |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from searches |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto mode and Bypass permissions to mode selector |

**Built-in IDE MCP server (hidden from /mcp):**

| Tool | Writes? | Description |
| :--- | :--- | :--- |
| `mcp__ide__getDiagnostics` | No | Language-server diagnostics (Problems panel) |
| `mcp__ide__executeCode` | Yes | Run Python in active Jupyter notebook (always prompts user) |

**URI handler:** `vscode://anthropic.claude-code/open` — optional `?prompt=<url-encoded>` and `?session=<id>` params

**Feature comparison (extension vs CLI):**

| Feature | CLI | VS Code Extension |
| :--- | :--- | :--- |
| Commands and skills | All | Subset (type `/` to see available) |
| MCP server config | Yes | Partial (add via CLI; manage with `/mcp` in panel) |
| Checkpoints / rewind | Yes | Yes |
| `!` bash shortcut | Yes | No |
| Tab completion | Yes | No |

---

### JetBrains Plugin

**Supported IDEs:** IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand

**Key shortcuts:**

| Shortcut | Action |
| :--- | :--- |
| `Cmd+Esc` (Mac) / `Ctrl+Esc` (Win/Linux) | Open Claude Code from editor |
| `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Win/Linux) | Insert file reference (`@src/auth.ts#L1-99`) |

**Features:** diff in IDE viewer, selection/tab context auto-shared, diagnostic (lint/syntax) errors auto-shared

**Usage from external terminal:** run `/ide` to connect to the JetBrains IDE

**WSL2 fix:** allow WSL2 subnet in Windows Firewall, or switch to mirrored networking in `.wslconfig` (`networkingMode=mirrored`; requires Windows 11 22H2+)

**Remote development:** install plugin on remote host via Settings → Plugin (Host), not local client

---

### Chrome Integration (beta)

**Requirements:** Chrome or Edge (not Brave/Arc), Claude in Chrome extension v1.0.36+, Claude Code v2.0.73+, direct Anthropic plan (Pro/Max/Team/Enterprise)

**CLI start:**
```bash
claude --chrome
```
Or enable inside a session: `/chrome`

**VS Code:** type `@browser` in prompt box followed by your task

**Capabilities:** live debugging (console/DOM), design verification, web app testing, authenticated-app automation, data extraction, form filling, multi-site workflows, GIF recording

**Enable by default:** run `/chrome` → "Enabled by default" (increases context usage)

**Common errors:**

| Error | Cause | Fix |
| :--- | :--- | :--- |
| "Browser extension is not connected" | Native messaging host unreachable | Restart Chrome + Claude Code; run `/chrome` |
| "Extension not detected" | Extension not installed/enabled | Install or enable in `chrome://extensions` |
| "No tab available" | Tab not ready | Ask Claude to create a new tab and retry |
| "Receiving end does not exist" | Service worker went idle | Run `/chrome` → "Reconnect extension" |

---

### Computer Use

**CLI (macOS only):** enable the `computer-use` MCP server via `/mcp` → select `computer-use` → Enable; requires Claude Code v2.1.85+, Pro or Max plan, interactive session

**Desktop (macOS + Windows):** Settings → General → Computer use toggle; macOS also needs Accessibility + Screen Recording permissions

**App permission tiers (both surfaces):**

| Tier | What Claude can do | Applies to |
| :--- | :--- | :--- |
| View only | See app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, no typing | Terminals, IDEs |
| Full control | Click, type, drag, shortcuts | Everything else |

**CLI vs Desktop differences:**

| Feature | Desktop | CLI |
| :--- | :--- | :--- |
| Platforms | macOS + Windows | macOS only |
| Enable | Settings toggle | `/mcp` → `computer-use` |
| Denied apps list | Configurable in Settings | Not available |
| Auto-unhide toggle | Optional | Always on |

**Safety:** per-app approval required each session; terminal excluded from screenshots; `Esc` key aborts globally; machine-wide lock (one session at a time)

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) — full Desktop reference: sessions, permission modes, diff view, preview servers, computer use, parallel sessions, SSH, enterprise configuration, CLI comparison
- [Get started with the Desktop app](references/claude-code-desktop-quickstart.md) — install, first session walkthrough, key features to try next
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — installation, extension settings, keyboard shortcuts, plugins, Chrome automation, IDE MCP server, checkpoints, third-party providers
- [JetBrains IDEs](references/claude-code-jetbrains.md) — installation, features, plugin settings, ESC key config, WSL2 setup, remote development
- [Use Claude Code with Chrome (beta)](references/claude-code-chrome.md) — capabilities, prerequisites, setup, example workflows, troubleshooting
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — enabling the MCP server, app approvals, safety model, example workflows, differences from Desktop
- [Desktop changelog](references/claude-code-desktop-changelog.md) — Desktop app release notes by version

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the Desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome (beta): https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
- Desktop changelog: https://code.claude.com/docs/en/desktop-changelog.md
