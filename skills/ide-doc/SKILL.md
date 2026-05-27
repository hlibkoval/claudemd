---
name: ide-doc
description: Complete official documentation for Claude Code IDE integrations — VS Code extension (install, keyboard shortcuts, settings, checkpoints, plugin management, built-in IDE MCP server), JetBrains plugin (IntelliJ, PyCharm, WebStorm, GoLand; diff viewing, selection context, WSL), Claude Desktop app (sessions, permission modes, diff view, preview servers, computer use, parallel sessions, SSH, enterprise config), Chrome browser integration (browser automation, console debugging, form filling), and computer use from the CLI (macOS screen control, per-app approval, safety guardrails).
user-invocable: false
---

# IDE and Surface Integration Documentation

This skill provides the complete official documentation for Claude Code's IDE and surface integrations.

## Quick Reference

### Surface Overview

| Surface | Platform | Key Strength |
| :--- | :--- | :--- |
| **VS Code extension** | VS Code, Cursor, Windsurf, Kiro | Graphical panel, inline diffs, checkpoints, @-mentions with line ranges |
| **JetBrains plugin** | IntelliJ, PyCharm, WebStorm, GoLand, etc. | IDE diff viewer, diagnostic sharing, quick-launch shortcut |
| **Claude Desktop (Code tab)** | macOS, Windows (no Linux) | Parallel sessions, visual diff, app preview, computer use, GitHub PR monitoring |
| **Chrome integration** | Chrome, Edge (beta) | Browser automation, console debug, form filling, authenticated web apps |
| **Computer use (CLI)** | macOS only (Pro/Max, v2.1.85+) | Screen control for native apps, iOS Simulator, GUI-only tools |

### VS Code Extension

**Install:** search "Claude Code" in Extensions (`Cmd/Ctrl+Shift+X`), or install for [VS Code](vscode:extension/anthropic.claude-code) / [Cursor](cursor:extension/anthropic.claude-code). Also on Open VSX for Windsurf/Kiro.

**Requirements:** VS Code 1.98.0+, Anthropic account.

**Key keyboard shortcuts:**

| Shortcut (Mac / Win-Linux) | Action |
| :--- | :--- |
| `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | Open new conversation as editor tab |
| `Option+K` / `Alt+K` | Insert @-mention reference for current file/selection |
| `Cmd+N` / `Ctrl+N` | New conversation (requires `enableNewConversationShortcut: true`) |
| `Cmd+Shift+T` / `Ctrl+Shift+T` | Reopen most-recently-closed Claude session tab |

**Permission modes:** `default` (ask each time) | `plan` (describe then wait for approval) | `acceptEdits` (auto-accept edits) | `bypassPermissions` (no prompts — sandboxes only).

**Extension settings (VS Code → Extensions → Claude Code):**

| Setting | Default | Notes |
| :--- | :--- | :--- |
| `useTerminal` | `false` | Launch in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | Starting permission mode for new conversations |
| `preferredLocation` | `panel` | `sidebar` or `panel` |
| `autosave` | `true` | Auto-save before Claude reads/writes files |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter to send |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N for new conversation |
| `enableReopenClosedSessionShortcut` | `true` | Cmd/Ctrl+Shift+T reopens last Claude session tab |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto mode and Bypass to mode selector |
| `disableLoginPrompt` | `false` | Skip auth prompts (third-party provider setups) |
| `usePythonEnvironment` | `true` | Activate workspace Python env (requires Python ext) |

**Checkpoints (rewind):** hover any message to reveal rewind button. Options: Fork conversation from here | Rewind code to here | Fork conversation and rewind code.

**Built-in IDE MCP server (`ide`):** auto-connects when extension is active. Hidden from `/mcp`. Exposes two tools to the model:

| Tool | What it does | Writes? |
| :--- | :--- | :--- |
| `mcp__ide__getDiagnostics` | Language-server errors/warnings (Problems panel), optionally scoped to one file | No |
| `mcp__ide__executeCode` | Run Python in the active Jupyter notebook kernel — always shows a Quick Pick confirmation first | Yes |

Security: binds to `127.0.0.1` on a random port; fresh auth token per activation stored in `~/.claude/ide/` (0600 / 0700).

**Plugin management:** type `/plugins` in the prompt box to open the graphical plugin manager. Install scopes: user (all projects), project (shared), local (repo-only).

**Launch a tab from external tools:** `vscode://anthropic.claude-code/open` URI handler. Optional query params: `prompt` (URL-encoded text to pre-fill) and `session` (session ID to resume).

**VS Code extension vs. CLI feature gaps:**

| Feature | CLI | VS Code Extension |
| :--- | :--- | :--- |
| All commands/skills | Yes | Subset (see `/` menu) |
| MCP server config | Full | Add via CLI; manage via `/mcp` |
| Checkpoints | Yes | Yes |
| `!` bash shortcut | Yes | No |
| Tab completion | Yes | No |

### JetBrains Plugin

**Supported IDEs:** IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand.

**Install:** [JetBrains Marketplace](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-). Restart IDE after install. For Remote Development, install on the **remote host** (Settings → Plugin (Host)).

**Features:** quick-launch `Cmd+Esc` / `Ctrl+Esc`; IDE diff viewer; selection/tab context auto-shared; `Cmd+Option+K` / `Alt+Ctrl+K` for file references (`@src/auth.ts#L1-99`); diagnostic sharing.

**Diff tool setting:** run `claude` → `/config` → set diff tool to `auto` (IDE) or `terminal`.

**Plugin settings (Settings → Tools → Claude Code [Beta]):**
- **Claude command:** custom path, e.g. `/usr/local/bin/claude` or `npx @anthropic-ai/claude-code`
- WSL users: `wsl -d Ubuntu -- bash -lic "claude"`
- **Enable automatic updates:** check for/install updates on restart

**ESC key fix:** Settings → Tools → Terminal → uncheck "Move focus to the editor with Escape" (or delete the "Switch focus to Editor" keybinding).

**WSL2 connectivity fix:**
1. Get WSL2 IP: `hostname -I`
2. Add firewall rule in PowerShell (Admin): `New-NetFirewallRule -DisplayName "Allow WSL2 Internal Traffic" -Direction Inbound -Protocol TCP -Action Allow -RemoteAddress <subnet> -LocalAddress <subnet>`
3. Alternative: set `networkingMode=mirrored` in `.wslconfig` (Windows 11 22H2+)

### Claude Desktop App (Code Tab)

**Platforms:** macOS (universal), Windows x64/ARM64. Not available on Linux — use CLI instead.

**Requirements:** Pro, Max, Team, or Enterprise subscription.

**Session setup:** choose Environment (Local / Remote / SSH) + Project folder + Model + Permission mode before sending first message.

**Permission modes:**

| Mode | Settings key | Behavior |
| :--- | :--- | :--- |
| Ask permissions | `default` | Ask before every edit or command |
| Auto accept edits | `acceptEdits` | Auto-accept file edits and common fs commands |
| Plan mode | `plan` | Explore and propose; no source edits until approved |
| Auto | `auto` | Background safety checks; requires Sonnet 4.6/Opus 4.6/4.7 |
| Bypass permissions | `bypassPermissions` | No prompts — sandboxed VMs only |

**Keyboard shortcuts (macOS; use Ctrl instead of Cmd on Windows):**

| Shortcut | Action |
| :--- | :--- |
| `Cmd /` | Show all shortcuts |
| `Cmd N` | New session |
| `Cmd W` | Close session |
| `Ctrl Tab` / `Ctrl Shift Tab` | Next/previous session |
| `Cmd Shift D` | Toggle diff pane |
| `Cmd Shift P` | Toggle preview pane |
| `Ctrl \`` | Toggle terminal pane |
| `Cmd \` | Close focused pane |
| `Cmd ;` | Open side chat |
| `Ctrl O` | Cycle view modes (Normal / Verbose / Summary) |
| `Cmd Shift M` | Open permission mode menu |
| `Cmd Shift I` | Open model menu |
| `Esc` | Stop Claude's response |

**Diff view:** click `+12 -1` indicator → file list left, changes right. Click any line to comment. Submit all comments: `Cmd+Enter` (Mac) / `Ctrl+Enter` (Win). Click **Review code** for Claude to leave inline review comments.

**PR monitoring:** after opening a PR, CI status bar appears. **Auto-fix** toggle: Claude reads failures and iterates. **Auto-merge** toggle: merges once all checks pass (squash; requires GitHub repo setting). Requires `gh` CLI.

**Preview servers (`.claude/launch.json`):**

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

Key fields: `name`, `runtimeExecutable`, `runtimeArgs`, `port` (default 3000), `cwd`, `env`, `autoPort` (true/false/unset), `program` (node script), `args`. Use `program` for standalone Node scripts; use `runtimeExecutable` for package-manager commands. `autoVerify: false` disables automatic post-edit verification.

**Parallel sessions:** each session gets its own Git worktree under `.claude/worktrees/`. Press `Cmd+N` to add a session. Hold `Cmd` and click a sidebar session to split view. Worktree location and branch prefix configurable in Settings → Claude Code.

**Side chat:** `Cmd+;` or `/btw` — reads main thread context but adds nothing back.

**Remote sessions:** run on Anthropic cloud; continue after app closes. Multi-repo: click `+` next to repo pill. Monitor from claude.ai/code or Claude iOS app.

**SSH sessions:** add via environment dropdown → "+ Add SSH connection". Fields: Name, SSH Host (`user@hostname`), SSH Port (default 22), Identity File. Desktop installs Claude Code on remote automatically. Remote must run Linux or macOS.

**Environment variables (local):** open environment dropdown → hover Local → gear icon → local environment editor (encrypted, applies to sessions and preview servers). Or add to `env` key in `~/.claude/settings.json` (Claude sessions only, not dev servers).

**Continue in another surface:** VS Code icon in session toolbar → "Claude Code on the Web" (push branch + summary, start remote session) or "Your IDE" (open project in installed editor).

### Chrome Integration (Beta)

**Requirements:** Chrome or Edge browser; Claude in Chrome extension v1.0.36+; Claude Code v2.0.73+; Pro/Max/Team/Enterprise plan via Anthropic (not third-party providers).

**CLI usage:**
```text
claude --chrome
```
Or enable from within a session: `/chrome`. Run `/chrome` to check status, manage permissions, reconnect.

**VS Code:** use `@browser` in the prompt box followed by what you want Claude to do — no flag needed when Chrome extension is installed.

**Enable by default:** run `/chrome` → select "Enabled by default". Note: increases context usage.

**Capabilities:** live console debug, DOM inspection, form filling, data extraction, multi-site workflows, GIF session recording, authenticated web app interaction (inherits your browser login state).

**Common error messages:**

| Error | Fix |
| :--- | :--- |
| "Browser extension is not connected" | Restart Chrome and Claude Code, run `/chrome` to reconnect |
| "Extension not detected" | Install/enable extension in `chrome://extensions` |
| "No tab available" | Ask Claude to create a new tab and retry |
| "Receiving end does not exist" | Run `/chrome` → "Reconnect extension" (service worker went idle) |

### Computer Use (CLI, macOS only)

**Requirements:** macOS; Pro or Max plan; Claude Code v2.1.85+; interactive session (not `-p` flag); not available with third-party providers.

**Enable:** run `/mcp` in an interactive session → select `computer-use` → **Enable** (persists per project). Grant macOS Accessibility and Screen Recording permissions when prompted.

**Per-session app approval:** first time Claude needs an app, a terminal prompt appears. Choose **Allow for this session** or **Deny**. Approvals last the session.

**App control tiers:**

| Tier | What Claude can do | Applies to |
| :--- | :--- | :--- |
| View only | See app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll; no typing | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

**Safety guardrails:** per-app approval; sentinel warnings for terminals/Finder/System Settings; terminal excluded from screenshots; global `Esc` to abort; machine-wide lock (one session at a time).

**Stop:** press `Esc` anywhere or `Ctrl+C` in terminal. macOS notification appears when Claude starts and finishes.

**CLI vs Desktop differences:**

| Feature | Desktop | CLI |
| :--- | :--- | :--- |
| Platforms | macOS and Windows | macOS only |
| Enable | Settings > General toggle | `/mcp` → enable `computer-use` |
| Denied apps list | Configurable in Settings | Not yet available |
| Auto-unhide | Optional toggle | Always on |

### Enterprise Configuration (Desktop)

**Admin console controls:** enable/disable Code in Desktop, Code on Web, Remote Control; disable Bypass permissions mode.

**Managed settings keys:**

| Key | Description |
| :--- | :--- |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to block Bypass mode |
| `disableAutoMode` | Set to `"disable"` to remove Auto from mode selector |
| `autoMode` | Customize auto mode classifier rules organization-wide |
| `sshConfigs` | Pre-configure SSH connections for all users (managed, non-editable) |
| `sshHostAllowlist` | Restrict SSH sessions to approved host patterns; `[]` disables SSH |
| `managedMcpServers` | Push MCP server configs to all users (third-party deployments only) |

**Device management:** macOS via `com.anthropic.Claude` preference domain (Jamf, Kandji); Windows via registry at `SOFTWARE\Policies\Claude`.

**SSH host allowlist patterns:** case-insensitive; `*` matches any host; `*.example.com` matches domain and subdomains; otherwise exact match. Read from managed settings only.

## Full Documentation

For the complete official documentation, see the reference files:

- [Desktop application](references/claude-code-desktop.md) — full reference for the Code tab: sessions, permission modes, diff view, PR monitoring, preview servers, computer use, parallel sessions, SSH, enterprise config, CLI comparison
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — install, first session walkthrough, quick feature tour
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — install, panel usage, @-mentions, plugin management, Chrome integration, built-in IDE MCP server, extension settings, checkpoints, CLI comparison
- [JetBrains IDEs](references/claude-code-jetbrains.md) — plugin install, features, configuration, WSL2 fix, troubleshooting
- [Use Claude Code with Chrome](references/claude-code-chrome.md) — capabilities, prerequisites, CLI and VS Code usage, example workflows, troubleshooting
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — enable, per-app approval, app tiers, safety, CLI vs Desktop differences, troubleshooting

## Sources

- Desktop application: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
