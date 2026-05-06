---
name: ide-doc
description: Complete official documentation for Claude Code IDE and desktop integrations — VS Code extension, JetBrains plugin, Claude Desktop app, Chrome browser integration, and computer use. Covers installation, permission modes, keyboard shortcuts, settings, session management, diff review, preview servers, worktrees, MCP, and enterprise configuration.
user-invocable: false
---

# IDE and Desktop Integration Documentation

This skill provides the complete official documentation for Claude Code IDE and desktop integrations.

## Quick Reference

### Surfaces Overview

| Surface | Platforms | How to launch |
| :--- | :--- | :--- |
| VS Code extension | VS Code, Cursor | Install from marketplace; Spark icon or Command Palette |
| JetBrains plugin | IntelliJ, PyCharm, WebStorm, GoLand, Android Studio, PhpStorm | Install from JetBrains marketplace; run `claude` in IDE terminal |
| Claude Desktop app | macOS, Windows (not Linux) | Download from claude.ai; click **Code** tab |
| CLI in any terminal | macOS, Linux, Windows | `claude` command; run `/ide` to connect to IDE |
| Chrome integration | Chrome, Edge (not Brave/Arc) | Install Claude in Chrome extension v1.0.36+; `claude --chrome` or `/chrome` |
| Computer use (CLI) | macOS only | Enable `computer-use` in `/mcp`; requires Pro/Max plan |

### VS Code Extension

**Requirements:** VS Code 1.98.0+; extension includes CLI.

**Opening Claude:** Spark icon in Editor Toolbar (requires file open), Activity Bar icon, Command Palette, or Status Bar.

**Key VS Code settings (`claudeCode.*`):**

| Setting | Default | Description |
| :--- | :--- | :--- |
| `useTerminal` | `false` | Launch in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | Starting permission mode: `default`, `plan`, `acceptEdits`, `bypassPermissions` |
| `preferredLocation` | `panel` | Where Claude opens: `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter to send |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N to start new conversation |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `usePythonEnvironment` | `true` | Activate workspace Python environment |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party provider setups) |
| `allowDangerouslySkipPermissions` | `false` | Add Auto and Bypass modes to mode selector |

**VS Code keyboard shortcuts:**

| Shortcut | Action |
| :--- | :--- |
| `Cmd/Ctrl+Esc` | Toggle focus between editor and Claude |
| `Cmd/Ctrl+Shift+Esc` | Open new conversation as editor tab |
| `Cmd/Ctrl+N` | New conversation (requires `enableNewConversationShortcut: true`) |
| `Option/Alt+K` | Insert @-mention reference for current file/selection |

**URI handler:** `vscode://anthropic.claude-code/open` — accepts `?prompt=...` and `?session=...` query params.

**Built-in IDE MCP server tools (visible to model):**

| Tool | What it does | Writes? |
| :--- | :--- | :--- |
| `mcp__ide__getDiagnostics` | Returns VS Code Problems panel diagnostics | No |
| `mcp__ide__executeCode` | Runs Python in active Jupyter notebook (always prompts first) | Yes |

### JetBrains Plugin

**Installation:** JetBrains Marketplace → "Claude Code Beta"; restart IDE.

**Key shortcuts:**

| Shortcut | Action |
| :--- | :--- |
| `Cmd+Esc` / `Ctrl+Esc` | Open Claude Code from editor |
| `Cmd+Option+K` / `Alt+Ctrl+K` | Insert file reference (e.g. `@src/auth.ts#L1-99`) |

**Plugin settings (Settings → Tools → Claude Code [Beta]):**

- **Claude command**: custom path (e.g. `claude`, `/usr/local/bin/claude`, `wsl -d Ubuntu -- bash -lic "claude"` for WSL)
- **Diff tool**: set to `auto` (show in IDE) or `terminal` via `/config`
- **Enable automatic updates**: auto-install plugin updates on restart

**Remote development:** install plugin on remote host, not local client (Settings → Plugin (Host)).

**WSL2 fix:** create firewall rule allowing WSL2 subnet, or add `networkingMode=mirrored` to `.wslconfig` (Windows 11 22H2+).

### Claude Desktop App

**Download:** macOS (Universal) or Windows x64/ARM64. Not available on Linux.

**Permission modes:**

| Mode | Settings key | Behavior |
| :--- | :--- | :--- |
| Ask permissions | `default` | Asks before editing files or running commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits and common filesystem commands |
| Plan mode | `plan` | Reads and plans without editing source code |
| Auto | `auto` | Executes all actions with background safety checks (research preview; Max/Team/Enterprise/API only) |
| Bypass permissions | `bypassPermissions` | No prompts; sandboxes only |

**Desktop keyboard shortcuts (macOS; use Ctrl in place of Cmd on Windows):**

| Shortcut | Action |
| :--- | :--- |
| `Cmd+N` | New session |
| `Cmd+W` | Close session |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next/previous session |
| `Cmd+Shift+D` | Toggle diff pane |
| `Cmd+Shift+P` | Toggle preview pane |
| `Ctrl+\`` | Toggle terminal pane |
| `Cmd+\` | Close focused pane |
| `Cmd+;` | Open side chat |
| `Ctrl+O` | Cycle view modes (Normal/Verbose/Summary) |
| `Cmd+Shift+M` | Open permission mode menu |
| `Cmd+Shift+I` | Open model menu |
| `Cmd+/` | Show all shortcuts |

**Session environments:**

| Environment | Description |
| :--- | :--- |
| Local | Runs on your machine; git worktrees for isolation |
| Remote | Anthropic cloud; continues when app is closed; supports multiple repos |
| SSH | Your own remote machines; Desktop auto-installs Claude Code |

**Preview server config (`.claude/launch.json`):**

Key fields per configuration entry: `name`, `runtimeExecutable`, `runtimeArgs`, `port`, `cwd`, `env`, `autoPort`, `program`, `args`. Top-level `autoVerify: false` to disable auto-verification.

**Managed settings keys (enterprise):**

| Key | Description |
| :--- | :--- |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to block bypass mode |
| `disableAutoMode` | Set to `"disable"` to remove Auto from mode selector |
| `autoMode` | Configure auto mode classifier trust rules |
| `sshConfigs` | Pre-distribute SSH connections to team members |

**CLI → Desktop flag equivalents:**

| CLI flag | Desktop equivalent |
| :--- | :--- |
| `--model` | Model dropdown next to send button |
| `--resume`, `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector |
| `--dangerously-skip-permissions` | Bypass permissions mode (via Settings) |
| `--verbose` | Verbose view mode in Transcript dropdown |

### Chrome Integration

**Requirements:** Claude in Chrome extension v1.0.36+; Claude Code v2.0.73+; Pro/Max/Team/Enterprise plan (direct Anthropic only, not third-party providers).

**Start:** `claude --chrome` or `/chrome` mid-session; `@browser <task>` in VS Code.

**Capabilities:** live console debugging, design verification, web app testing, authenticated app interaction, data extraction, form automation, GIF recording.

**Enable by default:** run `/chrome` → "Enabled by default" (note: increases context usage).

**Common errors:**

| Error | Fix |
| :--- | :--- |
| Extension not detected | Restart Chrome; run `/chrome` → "Reconnect extension" |
| Service worker idle | Run `/chrome` → "Reconnect extension" |
| Modal dialog blocking | Dismiss manually, then tell Claude to continue |

### Computer Use (CLI)

**Requirements:** macOS only; Pro or Max plan; Claude Code v2.1.85+; interactive session (not `-p` flag); direct Anthropic account.

**Enable:** `/mcp` → select `computer-use` → Enable. Grant macOS Accessibility and Screen Recording permissions.

**App control tiers:**

| Tier | Apps | Claude can do |
| :--- | :--- | :--- |
| View only | Browsers, trading platforms | Screenshots only |
| Click only | Terminals, IDEs | Click and scroll, no typing |
| Full control | Everything else | Click, type, drag, keyboard shortcuts |

**Stop at any time:** press `Esc` anywhere, or `Ctrl+C` in terminal.

**Safety:** per-app approval per session; terminal excluded from screenshots; machine-wide lock (one session at a time); `Esc` consumed to prevent prompt injection.

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) — full Desktop app reference: sessions, permission modes, diff view, preview servers, computer use, parallel sessions, SSH, remote sessions, enterprise configuration, and CLI comparison
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — install and first session walkthrough for Claude Desktop
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — VS Code extension installation, prompt box features, settings, keyboard shortcuts, MCP, git workflows, checkpoints, and troubleshooting
- [JetBrains IDEs](references/claude-code-jetbrains.md) — JetBrains plugin installation, configuration, WSL/remote development setup, and troubleshooting
- [Use Claude Code with Chrome](references/claude-code-chrome.md) — Chrome integration setup, example browser workflows, and troubleshooting
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — CLI computer use enable, app approvals, safety model, example workflows, and troubleshooting

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
