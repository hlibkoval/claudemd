---
name: ide-doc
description: Complete official documentation for Claude Code IDE and desktop integrations — VS Code extension, JetBrains plugin, Claude Desktop app, Chrome browser automation, and computer use from the CLI.
user-invocable: false
---

# IDE and Desktop Integration Documentation

This skill provides the complete official documentation for Claude Code IDE integrations, the desktop app, Chrome browser automation, and computer use.

## Quick Reference

### Surface Comparison

| Surface | Platform | Key entry point | Session isolation |
| :--- | :--- | :--- | :--- |
| VS Code extension | Windows, macOS, Linux | Spark icon / `Cmd+Shift+P` | Shared history with CLI |
| JetBrains plugin | Windows, macOS, Linux | `Cmd+Esc` / `Ctrl+Esc` | CLI session in IDE terminal |
| Claude Desktop — Code tab | macOS, Windows | Code tab in desktop app | Automatic Git worktrees |
| CLI (`claude`) | macOS, Linux, Windows | Terminal | `--worktree` flag |

### VS Code Extension — Key Settings

| Setting | Default | Description |
| :--- | :--- | :--- |
| `useTerminal` | `false` | Launch Claude in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | Starting permission mode: `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `preferredLocation` | `panel` | Where Claude opens: `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads or writes them |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter to send |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N to start a new conversation |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto and Bypass permissions modes to the selector |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `usePythonEnvironment` | `true` | Activate the workspace Python environment |

### VS Code Extension — Keyboard Shortcuts

| Command | Shortcut (Mac / Win-Linux) |
| :--- | :--- |
| Toggle focus editor ↔ Claude | `Cmd+Esc` / `Ctrl+Esc` |
| Open new conversation tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` |
| Insert @-mention reference | `Option+K` / `Alt+K` |
| New conversation (requires setting) | `Cmd+N` / `Ctrl+N` |

Add `"$schema": "https://json.schemastore.org/claude-code-settings.json"` to `~/.claude/settings.json` for autocomplete in VS Code.

Connect from an external terminal with `/ide` to activate VS Code integration (diff viewer, selection context, diagnostics).

### VS Code Extension vs. CLI

| Feature | CLI | VS Code Extension |
| :--- | :--- | :--- |
| Commands and skills | All | Subset (type `/` to see available) |
| MCP server config | Full | Partial (add via CLI; manage with `/mcp` in chat) |
| Checkpoints / rewind | Yes | Yes |
| `!` bash shortcut | Yes | No |
| Tab completion | Yes | No |

### Built-in IDE MCP Server (VS Code)

When the VS Code extension is active it runs a local MCP server named `ide` (hidden from `/mcp`):

| Tool | What it does | Writes? |
| :--- | :--- | :--- |
| `mcp__ide__getDiagnostics` | Returns language-server errors/warnings from the Problems panel | No |
| `mcp__ide__executeCode` | Runs Python code in the active Jupyter notebook kernel (always prompts) | Yes |

Server binds to `127.0.0.1` on a random high port. Auth token stored in `~/.claude/ide/` with `0600` permissions.

### JetBrains Plugin — Key Points

Supported IDEs: IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand.

| Feature | Detail |
| :--- | :--- |
| Quick launch | `Cmd+Esc` (Mac) / `Ctrl+Esc` (Win/Linux) |
| File reference | `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Win/Linux) — inserts `@src/auth.ts#L1-99` |
| Diff tool setting | `/config` → set diff tool to `auto` (IDE) or `terminal` |
| WSL2 fix | Add Windows Firewall rule for WSL2 subnet, or set `networkingMode=mirrored` in `.wslconfig` |
| Remote development | Install plugin on the **remote host** via Settings → Plugin (Host) |
| ESC key fix | Settings → Tools → Terminal → uncheck "Move focus to the editor with Escape" |
| Custom Claude command | Settings → Tools → Claude Code → "Claude command" field (e.g., for WSL: `wsl -d Ubuntu -- bash -lic "claude"`) |

Connect from external terminal: run `claude` then `/ide`.

### Claude Desktop — Permission Modes

| Mode | Settings key | Behavior |
| :--- | :--- | :--- |
| Ask permissions | `default` | Prompts before every edit or command |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits and common filesystem commands |
| Plan mode | `plan` | Explores and proposes a plan without editing source code |
| Auto | `auto` | Background safety checks; reduces prompts (Max/Team/Enterprise/API only) |
| Bypass permissions | `bypassPermissions` | No prompts — sandboxed containers only |

Auto mode requires Claude Sonnet 4.6, Opus 4.6, or Opus 4.7 on Team/Enterprise/API; Opus 4.7 on Max. Not available on Pro or third-party providers.

### Claude Desktop — Keyboard Shortcuts (macOS; Ctrl replaces Cmd on Windows)

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
| `Cmd+/` | Show all shortcuts |

### Claude Desktop — Session Environments

| Environment | Where Claude runs | Continues when app closed? |
| :--- | :--- | :--- |
| Local | Your machine | No |
| Remote | Anthropic cloud infrastructure | Yes |
| SSH | Remote machine you manage | Yes (on remote) |

Each local session gets an isolated Git worktree in `<project-root>/.claude/worktrees/` by default.

### Claude Desktop — Preview Server Configuration (`.claude/launch.json`)

```json
{
  "version": "0.0.1",
  "autoVerify": true,
  "configurations": [
    {
      "name": "web",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"],
      "port": 3000,
      "autoPort": true
    }
  ]
}
```

Key fields: `name`, `runtimeExecutable`, `runtimeArgs`, `port`, `cwd`, `env`, `autoPort`, `program`, `args`. Set `autoVerify: false` to disable automatic post-edit verification.

### Claude Desktop — Enterprise Managed Settings

| Key | Description |
| :--- | :--- |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to block Bypass permissions mode |
| `disableAutoMode` | Set to `"disable"` to remove Auto from the mode selector |
| `sshConfigs` | Pre-configure SSH connections for all users |
| `sshHostAllowlist` | Restrict SSH sessions to approved host patterns |
| `autoMode` | Customize what auto mode classifier trusts/blocks |

### Chrome Integration

Requirements: Claude in Chrome extension v1.0.36+, Claude Code v2.0.73+, direct Anthropic plan (not available via Bedrock/Vertex/Foundry).

Works with Google Chrome and Microsoft Edge (not Brave, Arc, or WSL).

| How to enable | Detail |
| :--- | :--- |
| CLI flag | `claude --chrome` |
| Within session | `/chrome` |
| Enable by default | `/chrome` → "Enabled by default" |
| VS Code extension | Available whenever Chrome extension is installed (no flag needed) |

Common use cases: live debugging (read console errors, fix code), UI testing, authenticated web apps, data extraction, form automation, GIF recording.

Error quick reference:

| Error | Fix |
| :--- | :--- |
| "Browser extension is not connected" | Restart Chrome and Claude Code, then `/chrome` to reconnect |
| "Extension not detected" | Install or enable extension in `chrome://extensions` |
| "Receiving end does not exist" | Service worker went idle — `/chrome` → "Reconnect extension" |

### Computer Use (CLI — macOS only)

Requirements: Pro or Max plan, Claude Code v2.1.85+, interactive session (not `-p` flag), macOS only. Desktop app supports macOS and Windows.

Enable: `/mcp` → select `computer-use` → Enable. Grant Accessibility and Screen Recording permissions.

| App category | Control level |
| :--- | :--- |
| Browsers, trading platforms | View only |
| Terminals, IDEs | Click only |
| Everything else | Full control (click, type, drag, shortcuts) |

Safety features: per-app approval each session, sentinel warnings for terminals/Finder/System Settings, terminal excluded from screenshots, `Esc` aborts anywhere, machine-wide lock (one session at a time).

CLI vs. Desktop differences:

| Feature | Desktop | CLI |
| :--- | :--- | :--- |
| Platform | macOS and Windows | macOS only |
| Enable | Settings > General toggle | `/mcp` → enable `computer-use` |
| Denied apps list | Configurable | Not yet available |
| Dispatch integration | Yes | Not applicable |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) — full desktop app reference: sessions, permission modes, diff view, preview servers, worktrees, parallel sessions, SSH, remote sessions, enterprise config, CLI comparison, and troubleshooting
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — install, first session, and orientation to Desktop features
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — extension install, prompt box features, @-mentions, session history, plugin management, Chrome automation, settings reference, IDE MCP server, checkpoints, and troubleshooting
- [JetBrains IDEs](references/claude-code-jetbrains.md) — plugin install, IDE integration features, configuration, WSL and remote development setup, and troubleshooting
- [Use Claude Code with Chrome](references/claude-code-chrome.md) — Chrome integration capabilities, setup, example workflows, and troubleshooting
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — CLI computer use setup, app approval flow, safety model, example workflows, and troubleshooting

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
