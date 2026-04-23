---
name: ide-doc
description: Complete official documentation for Claude Code IDE and desktop integrations — VS Code extension, JetBrains plugin, Claude Desktop app, Chrome browser integration, and computer use from the CLI.
user-invocable: false
---

# IDE and Desktop Integration Documentation

This skill provides the complete official documentation for Claude Code IDE and desktop integrations.

## Quick Reference

### VS Code Extension

**Prerequisites**: VS Code 1.98.0+. Install via the Extensions view (`Cmd+Shift+X` / `Ctrl+Shift+X`) or directly at `vscode:extension/anthropic.claude-code`. Works in Cursor too.

**Open Claude**: Spark icon in the Editor Toolbar (top-right, requires a file open), Activity Bar (always visible), Command Palette (`Cmd+Shift+P` → "Claude Code"), or Status Bar (`✱ Claude Code`).

**Key VS Code shortcuts**:

| Command | Shortcut | Description |
| :--- | :--- | :--- |
| Focus Input | `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| Open in New Tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | New conversation as editor tab |
| Insert @-Mention | `Option+K` / `Alt+K` | Insert `@file.ts#L5-10` reference |
| New Conversation | `Cmd+N` / `Ctrl+N` | Requires Claude focused + `enableNewConversationShortcut: true` |

**Permission modes** (set default via `claudeCode.initialPermissionMode`):

| Mode | Key | Behavior |
| :--- | :--- | :--- |
| Normal | `default` | Asks permission before each action |
| Plan | `plan` | Describes plan, waits for approval before changes |
| Auto-accept edits | `acceptEdits` | Edits without asking; prompts for other actions |
| Bypass | `bypassPermissions` | No prompts (sandboxes only) |

**Key VS Code extension settings**:

| Setting | Default | Description |
| :--- | :--- | :--- |
| `useTerminal` | `false` | Launch Claude in terminal mode |
| `initialPermissionMode` | `default` | Default permission mode for new conversations |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter to send |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto mode and Bypass permissions to selector |

**CLI-only features not in VS Code extension**: `!` bash shortcut, tab completion, all `/` commands (only a subset available in the extension).

**Built-in IDE MCP server** (`ide`): runs locally, exposes two model-visible tools — `mcp__ide__getDiagnostics` (language-server errors/warnings) and `mcp__ide__executeCode` (run Python in active Jupyter notebook, always prompts before executing).

**Add MCP server from integrated terminal**:
```bash
claude mcp add --transport http github https://api.githubcopilot.com/mcp/ \
  --header "Authorization: Bearer YOUR_GITHUB_PAT"
```
Then manage with `/mcp` in the chat panel.

**Launch a new tab via URI** (from scripts, aliases, bookmarklets):
```bash
open "vscode://anthropic.claude-code/open?prompt=review%20my%20changes"
```
Optional params: `prompt` (pre-fill text) and `session` (session ID to resume).

**Checkpoints** (VS Code only): hover any message → rewind button → Fork conversation, Rewind code, or Fork + Rewind.

---

### JetBrains Plugin

**Supported IDEs**: IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand.

**Install**: JetBrains Marketplace → search "Claude Code Beta" → install → restart IDE. For remote development, install the plugin in the remote host via **Settings → Plugin (Host)**.

**Key shortcuts**:

| Shortcut | Action |
| :--- | :--- |
| `Cmd+Esc` / `Ctrl+Esc` | Open Claude Code from editor |
| `Cmd+Option+K` / `Alt+Ctrl+K` | Insert file reference (e.g., `@File#L1-99`) |

**Features**: diff viewing in IDE diff viewer, automatic selection/tab context sharing, diagnostic sharing (lint/syntax errors auto-shared as you work).

**Connect from external terminal**: run `claude`, then `/ide` to connect to the JetBrains IDE.

**Plugin settings** (`Settings → Tools → Claude Code [Beta]`):
- **Claude command**: custom path (e.g., `claude`, `/usr/local/bin/claude`, `npx @anthropic-ai/claude-code`)
- **WSL users**: set `wsl -d Ubuntu -- bash -lic "claude"` as the Claude command
- **Diff tool**: set to `auto` (show in IDE) or `terminal` via `/config`

**ESC key fix** (if ESC doesn't interrupt): Settings → Tools → Terminal → uncheck "Move focus to the editor with Escape" or delete the "Switch focus to Editor" shortcut.

---

### Claude Desktop App (Code Tab)

**Platforms**: macOS (Intel + Apple Silicon), Windows x64/ARM64. Linux is not supported.

**Requirements**: Pro, Max, Team, or Enterprise subscription. Git required on Windows for local sessions.

**Permission modes**:

| Mode | Settings key | Behavior |
| :--- | :--- | :--- |
| Ask permissions | `default` | Prompts before every edit/command |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits and common filesystem commands; still asks for other terminal commands |
| Plan mode | `plan` | Reads/explores, proposes plan, no source code edits |
| Auto | `auto` | Background safety checks, reduces prompts. Research preview; requires Sonnet 4.6+/Opus 4.6+ on Team/Enterprise/API, Opus 4.7+ on Max |
| Bypass permissions | `bypassPermissions` | No prompts (sandboxed containers/VMs only) |

**Desktop keyboard shortcuts** (Mac; use Ctrl in place of Cmd on Windows):

| Shortcut | Action |
| :--- | :--- |
| `Cmd /` | Show keyboard shortcuts |
| `Cmd N` | New session |
| `Cmd W` | Close session |
| `Ctrl Tab` / `Ctrl Shift Tab` | Next/previous session |
| `Ctrl `` ` `` ` | Toggle terminal pane |
| `Cmd Shift D` | Toggle diff pane |
| `Cmd Shift P` | Toggle preview pane |
| `Cmd ;` | Open side chat |
| `Ctrl O` | Cycle view modes |
| `Esc` | Stop Claude's response |

**View modes** (Transcript view dropdown):

| Mode | Shows |
| :--- | :--- |
| Normal | Tool calls collapsed to summaries, full text responses |
| Verbose | Every tool call, file read, and intermediate step |
| Summary | Only Claude's final responses and changes made |

**Parallel sessions**: each session gets an isolated Git worktree (`<project-root>/.claude/worktrees/`). Press `Cmd+N` to open a new session. Auto-archive after PR merge/close configurable in Settings.

**Side chat**: `Cmd+;` or `/btw` — ask a question using session context without adding to the main thread.

**Sessions**: Local (your machine), Remote (Anthropic cloud, continues if app is closed), SSH (remote machine, Claude Code must be installed there).

**Preview server config** (`.claude/launch.json`):

```json
{
  "version": "0.0.1",
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

Key `launch.json` fields: `name`, `runtimeExecutable`, `runtimeArgs`, `port` (default 3000), `cwd`, `env`, `autoPort`, `program`, `args`. Set `"autoVerify": false` to disable auto screenshot/verify after edits.

**PR monitoring**: requires `gh` CLI. Toggles for Auto-fix (fix failing CI) and Auto-merge (squash merge when checks pass).

**Managed settings** (enterprise):

| Key | Description |
| :--- | :--- |
| `permissions.disableBypassPermissionsMode` | Set `"disable"` to block bypass mode |
| `disableAutoMode` | Set `"disable"` to remove Auto from mode selector |
| `sshConfigs` | Pre-configure SSH connections for the team |
| `autoMode` | Configure auto mode classifier rules |

**CLI flag equivalents** for Desktop:

| CLI flag | Desktop equivalent |
| :--- | :--- |
| `--model` | Model dropdown next to send button |
| `--resume`, `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (Settings → Claude Code) |
| `--verbose` | Verbose view mode in Transcript view dropdown |
| `MAX_THINKING_TOKENS` env var | Local environment editor |

**Move CLI session to Desktop**: run `/desktop` in the terminal (macOS/Windows only).

**Shared config** between Desktop and CLI: `CLAUDE.md`, `~/.claude.json`, MCP servers in `~/.claude.json` or `.mcp.json`, hooks, skills, and `~/.claude/settings.json`.

---

### Chrome Integration (Beta)

**Requirements**: Google Chrome or Microsoft Edge, Claude in Chrome extension v1.0.36+, Claude Code v2.0.73+, direct Anthropic plan (Pro/Max/Team/Enterprise). Not available via Bedrock/Vertex/Foundry.

**Enable**: `claude --chrome` (or `/chrome` in an existing session). Select "Enabled by default" in `/chrome` to skip the flag.

**VS Code**: Chrome integration available automatically when the extension is installed — use `@browser` in the prompt box.

**Capabilities**: live debugging (console errors, DOM state), design verification, web app testing, authenticated app interaction (Google Docs, Gmail, Notion, etc.), data extraction, task automation, GIF session recording.

**Troubleshooting**: run `/chrome` → "Reconnect extension" if connection drops. Restart both Chrome and Claude Code if extension is not detected.

---

### Computer Use (CLI, macOS only)

**Requirements**: macOS, Pro or Max plan, Claude Code v2.1.85+, interactive session (not `-p` flag). Not available on Team/Enterprise, Linux, or Windows via CLI.

**Enable**: run `/mcp` → select `computer-use` → Enable. Grant Accessibility and Screen Recording permissions when prompted. Setting persists per project.

**App approval**: Claude prompts once per session per app. Approvals last the current session. Apps with broad reach (terminals, Finder, System Settings) show extra warnings.

**App access tiers** (fixed, cannot change):

| Tier | What Claude can do | Applies to |
| :--- | :--- | :--- |
| View only | See app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll (no typing/shortcuts) | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

**Session behavior**: one session holds a machine-wide lock; other sessions fail until lock is released. Other visible apps are hidden while Claude works; restored when done. Terminal window excluded from screenshots. Press `Esc` anywhere to abort.

**Desktop vs CLI computer use**:

| Feature | Desktop | CLI |
| :--- | :--- | :--- |
| Platforms | macOS + Windows | macOS only |
| Enable | Settings → General → Computer use toggle | `/mcp` → enable `computer-use` |
| Denied apps list | Configurable in Settings | Not available |
| Auto-unhide toggle | Optional | Always on |

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) — full reference for the desktop app: parallel sessions, workspace layout, permission modes, preview servers, computer use, PR monitoring, connectors, SSH sessions, enterprise configuration, CLI comparison, and troubleshooting
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — installation walkthrough and first-session guide for the Claude Desktop Code tab
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — installing the extension, prompt box features, @-mentions, shortcuts, extension settings, MCP setup, git workflows, IDE MCP server details, and troubleshooting
- [JetBrains IDEs](references/claude-code-jetbrains.md) — plugin installation, features, configuration, remote development, WSL setup, and troubleshooting
- [Use Claude Code with Chrome (beta)](references/claude-code-chrome.md) — Chrome integration capabilities, setup, example workflows, and troubleshooting
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — enabling computer use, app approval flow, safety model, example workflows, and CLI vs Desktop differences

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome (beta): https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
