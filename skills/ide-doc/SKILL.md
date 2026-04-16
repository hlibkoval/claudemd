---
name: ide-doc
description: Complete official documentation for Claude Code's IDE and surface integrations — the Claude Desktop app (Code tab), VS Code / Cursor extension, JetBrains plugin, Claude in Chrome browser automation, and computer use for GUI control on macOS and Windows.
user-invocable: false
---

# IDE Integrations Documentation

This skill provides the complete official documentation for using Claude Code outside the terminal: the Claude Desktop app, the VS Code/Cursor extension, the JetBrains plugin, the Chrome browser integration, and computer use for controlling native GUI apps.

## Quick Reference

### Surfaces at a glance

| Surface | Platforms | Install | Best for |
|---|---|---|---|
| **Claude Desktop (Code tab)** | macOS, Windows | [claude.com/download](https://claude.com/download) | Parallel sessions, diff review, live preview, PR monitoring |
| **VS Code / Cursor extension** | macOS, Windows, Linux | Marketplace: `anthropic.claude-code` (VS Code 1.98+) | Native graphical panel alongside your editor |
| **JetBrains plugin** | IntelliJ, PyCharm, WebStorm, PhpStorm, GoLand, Android Studio | [JetBrains marketplace](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-) | CLI with IDE diff viewer, selection sharing, diagnostics |
| **Claude in Chrome (beta)** | Chrome, Edge (not Brave/Arc/WSL) | Chrome Web Store extension v1.0.36+ | Browser automation, web-app testing |
| **Computer use (CLI)** | macOS only, Pro/Max | `/mcp` → enable `computer-use` | Native apps, simulators, GUI-only tools |
| **Computer use (Desktop)** | macOS and Windows, Pro/Max | Settings → General → Computer use toggle | Same, via graphical settings |

### Claude Desktop: the Code tab

Before sending your first message, configure: **Environment** (Local / Remote / SSH), **Project folder**, **Model**, and **Permission mode**.

| Permission mode | Settings key | Behavior |
|---|---|---|
| Ask permissions | `default` | Asks before every edit or command (default for new users) |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits and safe filesystem commands |
| Plan mode | `plan` | Reads and explores, proposes a plan, no source edits |
| Auto | `auto` | Classifier-gated autonomy (Team/Enterprise/API, Sonnet/Opus 4.6) |
| Bypass permissions | `bypassPermissions` | No prompts (sandboxes only; enable in Settings) |

Remote sessions support only Auto accept edits and Plan mode.

#### Core Desktop features

| Feature | Description |
|---|---|
| Parallel sessions | Each gets its own Git worktree in `<project>/.claude/worktrees/<name>` |
| Side chat | Read session context without polluting the main thread (`Cmd+;` / `Ctrl+;` or `/btw`) |
| Diff view | Click the `+12 -1` indicator; comment on lines, submit with `Cmd+Enter` / `Ctrl+Enter` |
| Review code | Button in diff view asks Claude to evaluate its own diffs |
| Live preview | Embedded browser; auto-verify after edits; dev server config in `.claude/launch.json` |
| PR monitoring | Auto-fix failing CI and/or Auto-merge via toggles in the CI status bar (needs `gh`) |
| Panes | Chat, diff, preview, terminal, file, plan, tasks, subagent — drag to arrange |
| Integrated terminal | `Ctrl+` `` ` `` — shares session's working directory and env |
| Dispatch | Send a task from your phone via the Cowork tab; Code sessions appear with a **Dispatch** badge |
| Continue in | Send to Claude Code on the Web, or open in another IDE |

#### Desktop keyboard shortcuts (Code tab, macOS — use `Ctrl` on Windows)

| Shortcut | Action |
|---|---|
| `Cmd+/` | Show all shortcuts |
| `Cmd+N` / `Cmd+W` | New / close session |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Cycle sessions |
| `Esc` | Stop Claude |
| `Cmd+Shift+D` / `Cmd+Shift+P` | Toggle diff / preview pane |
| `Cmd+Shift+S` | Select element in preview |
| `Ctrl+` `` ` `` | Toggle terminal pane |
| `Cmd+\` | Close focused pane |
| `Cmd+;` | Open side chat |
| `Ctrl+O` | Cycle transcript view modes (Normal / Verbose / Summary) |
| `Cmd+Shift+M` / `Cmd+Shift+I` / `Cmd+Shift+E` | Open permission / model / effort menu |

#### Preview server config (`.claude/launch.json`)

| Field | Purpose |
|---|---|
| `name` | Unique identifier |
| `runtimeExecutable` / `runtimeArgs` | e.g. `"npm"` + `["run", "dev"]` |
| `port` | Default 3000 |
| `cwd` | Defaults to project root; `${workspaceFolder}` for explicit root |
| `env` | Non-secret env vars (file is committed) |
| `autoPort` | `true` finds free port, `false` fails on conflict, unset prompts |
| `program` / `args` | Run a standalone script with `node` |

Set top-level `"autoVerify": false` to disable auto-verification after edits.

#### CLI → Desktop flag equivalents

| CLI | Desktop |
|---|---|
| `--model sonnet` | Model dropdown next to send button |
| `--resume`, `--continue` | Click a session in the sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (enable in Settings) |
| `--add-dir` | **+** button on remote sessions to add repos |
| `--verbose` | Verbose view mode in Transcript view dropdown |
| `--print`, `--output-format` | Not available — Desktop is interactive only |
| `--allowedTools` / `--disallowedTools` | Not available |

Use `/desktop` in the CLI to save the current session and open it in the desktop app (macOS/Windows).

#### Desktop enterprise managed settings

| Key | Effect |
|---|---|
| `permissions.disableBypassPermissionsMode` | `"disable"` prevents Bypass permissions |
| `disableAutoMode` | `"disable"` hides Auto from mode selector |
| `autoMode` | Customize auto-mode classifier (user / local / managed only — not project `settings.json`) |

### VS Code / Cursor extension

Open with the Spark icon (Editor Toolbar with a file open, Activity Bar always, or Status Bar `Claude Code`). Drag the panel to Secondary sidebar, Primary sidebar, or Editor area.

#### VS Code commands and shortcuts

| Command | Shortcut |
|---|---|
| Focus Input (toggle editor ↔ Claude) | `Cmd+Esc` / `Ctrl+Esc` |
| Open in New Tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` |
| New Conversation (needs setting enabled, Claude focused) | `Cmd+N` / `Ctrl+N` |
| Insert @-Mention Reference (editor focused) | `Option+K` / `Alt+K` |

#### VS Code extension settings (VS Code settings → Extensions → Claude Code)

| Setting | Default | Purpose |
|---|---|---|
| `useTerminal` | `false` | Launch in terminal mode instead of panel |
| `initialPermissionMode` | `default` | `default` / `plan` / `acceptEdits` / `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` or `panel` |
| `autosave` | `true` | Save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Require Ctrl/Cmd+Enter |
| `enableNewConversationShortcut` | `false` | Enable `Cmd/Ctrl+N` shortcut |
| `respectGitIgnore` | `true` | Exclude gitignored files |
| `usePythonEnvironment` | `true` | Activate workspace Python env |
| `environmentVariables` | `[]` | Env vars for the Claude process |
| `disableLoginPrompt` | `false` | Skip auth prompt (third-party providers) |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto and Bypass to mode selector |
| `claudeProcessWrapper` | — | Custom executable path |

#### VS Code vs. CLI

| Feature | CLI | VS Code extension |
|---|---|---|
| Commands/skills | All | Subset — type `/` to see |
| MCP | Full config | Manage via `/mcp`; add servers via CLI |
| Checkpoints | Yes | Yes (hover message → rewind button) |
| Bash shortcut (leading bang) | Yes | No |
| Tab completion | Yes | No |

URI handler: `vscode://anthropic.claude-code/open?prompt=...&session=...` opens a tab from external tools.

#### The built-in `ide` MCP server

Auto-connects when the extension is active; binds to `127.0.0.1` on a random port with a token in `~/.claude/ide/` (0600/0700). Two model-visible tools:

| Tool | What it does | Writes? |
|---|---|---|
| `mcp__ide__getDiagnostics` | Returns VS Code Problems panel errors/warnings | No |
| `mcp__ide__executeCode` | Runs Python in the active Jupyter notebook kernel (always shows Quick Pick confirmation) | Yes |

### JetBrains plugin

| Feature | How |
|---|---|
| Launch | `Cmd+Esc` / `Ctrl+Esc`, or click the Claude Code button |
| File reference | `Cmd+Option+K` / `Alt+Ctrl+K` inserts `@File#L1-99` |
| Diff display | Set `/config` diff tool to `auto` for IDE viewer, `terminal` otherwise |
| External terminal | Run `/ide` inside Claude Code to connect |
| WSL | Set Claude command to `wsl -d Ubuntu -- bash -lic "claude"` |
| ESC fix | Settings → Tools → Terminal: uncheck "Move focus to the editor with Escape" |
| Remote Development | Plugin must be installed on the remote host via Settings → Plugin (Host) |

### Claude in Chrome (beta)

Requirements: Chrome or Edge, Claude in Chrome extension v1.0.36+, Claude Code v2.0.73+, direct Anthropic plan (no third-party providers).

| Task | Command |
|---|---|
| Launch with Chrome tools | `claude --chrome` |
| Enable in an existing session | `/chrome` |
| Enable by default | `/chrome` → "Enabled by default" (increases context usage) |
| Inspect available tools | `/mcp` → `claude-in-chrome` |
| VS Code usage | `@browser` in the prompt box |

Claude shares your Chrome login state; pauses on logins/CAPTCHAs. Site permissions inherit from the extension.

### Computer use (CLI, macOS)

Pro/Max only, interactive sessions only (not `-p`), Claude Code v2.1.85+.

1. `/mcp` → select `computer-use` → Enable.
2. Grant macOS **Accessibility** and **Screen Recording** permissions; restart Claude Code if prompted.
3. Per-session per-app approval prompts appear as Claude encounters new apps.

| App tier | Examples | What Claude can do |
|---|---|---|
| View only | Browsers, trading platforms | See screenshots only |
| Click only | Terminals, IDEs | Click and scroll; no typing/keyboard shortcuts |
| Full control | Everything else | Click, type, drag, keyboard shortcuts |

Extra warnings flag apps with broad reach (shell-equivalent for terminals/IDEs, filesystem for Finder, system settings for System Settings).

Ongoing behavior: one session at a time (machine-wide lock), other apps hidden while working, terminal excluded from screenshots, `Esc` anywhere aborts and releases the lock. Screenshots auto-downscale (e.g., 3456×2234 → ~1372×887).

#### CLI vs. Desktop computer use

| Feature | Desktop | CLI |
|---|---|---|
| Platforms | macOS and Windows | macOS only |
| Enable | Settings → General toggle | `/mcp` → enable `computer-use` |
| Denied apps list | Configurable | Not yet available |
| Auto-unhide on finish | Optional toggle | Always on |
| Dispatch-spawned sessions | Supported | Not applicable |

### Shared config across surfaces

CLAUDE.md, `~/.claude/settings.json`, `~/.claude.json`, `.mcp.json`, hooks, skills, and plugins apply to CLI, Desktop, VS Code, and JetBrains. MCP servers configured for the Claude Desktop **chat** app (`claude_desktop_config.json`) are NOT shared with the Code tab.

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) — Full reference for the Desktop Code tab: sessions, permission modes, diff view, PR monitoring, workspace panes, computer use, remote/SSH sessions, plugins, preview config, enterprise settings, CLI comparison, and troubleshooting.
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — Quickstart for installing Claude Desktop and running your first Code session (tabs, environment selection, first prompt, reviewing changes).
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — VS Code / Cursor extension: install, prompt-box features, @-mentions, plan review, past conversations, extension settings, plugin manager, URI handler, checkpoints, the `ide` MCP server, and CLI comparison.
- [JetBrains IDEs](references/claude-code-jetbrains.md) — JetBrains plugin for IntelliJ, PyCharm, WebStorm, and other IDEs: features, installation, plugin settings, WSL and Remote Development notes, and troubleshooting.
- [Use Claude Code with Chrome (beta)](references/claude-code-chrome.md) — Connect Claude Code to Chrome or Edge for live debugging, UI testing, authenticated web apps, data extraction, and session recording.
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — Computer use in the CLI on macOS: enablement, per-app approval, app tiers, safety guardrails, example workflows, and Desktop differences.

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
