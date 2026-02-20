---
name: ide
description: Reference documentation for Claude Code IDE integrations — VS Code extension, JetBrains plugin, Desktop app (Code tab), and Chrome browser automation. Covers installation, keyboard shortcuts, permission modes, diff review, session management, plugin management, SSH/remote sessions, enterprise configuration, and troubleshooting for each surface.
user-invocable: false
---

# IDE Integration Documentation

This skill provides the complete official documentation for using Claude Code in VS Code, JetBrains IDEs, the Desktop app, and Chrome.

## Quick Reference

### Supported Surfaces

| Surface | Install | Key Feature |
|:--------|:--------|:------------|
| **VS Code** | Extension from Marketplace | Graphical panel with inline diffs, @-mentions, checkpoints |
| **JetBrains** | Plugin from JetBrains Marketplace | IDE diff viewer, diagnostic sharing, selection context |
| **Desktop app** | Standalone app (macOS, Windows) | Visual diff review, parallel sessions with worktree isolation, remote/SSH sessions |
| **Chrome** | Chrome extension + `--chrome` flag | Browser automation, live debugging, session recording |

### VS Code Keyboard Shortcuts

| Shortcut | Action |
|:---------|:-------|
| `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | Open new conversation tab |
| `Option+K` / `Alt+K` | Insert @-mention reference from selection |
| `Cmd+N` / `Ctrl+N` | New conversation (Claude focused) |
| `Cmd+Shift+P` / `Ctrl+Shift+P` | Command Palette (search "Claude Code") |
| `Shift+Enter` | Multi-line input (no send) |

### VS Code Extension Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | CLI mode instead of graphical panel |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Require Ctrl/Cmd+Enter to send |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from search |
| `disableLoginPrompt` | `false` | Skip auth prompts (third-party providers) |
| `allowDangerouslySkipPermissions` | `false` | Bypass all permission prompts |

### JetBrains Keyboard Shortcuts

| Shortcut | Action |
|:---------|:-------|
| `Cmd+Esc` / `Ctrl+Esc` | Open Claude Code |
| `Cmd+Option+K` / `Alt+Ctrl+K` | Insert file reference (@File#L1-99) |

### JetBrains Plugin Settings (Settings > Tools > Claude Code)

- **Claude command**: custom path (e.g., `/usr/local/bin/claude`, or `wsl -d Ubuntu -- bash -lic "claude"` for WSL)
- **Enable Option+Enter for multi-line prompts** (macOS only)
- **Enable automatic updates**

### Desktop App Permission Modes

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| **Ask** | `default` | Approval before each edit/command (default) |
| **Code** | `acceptEdits` | Auto-accepts file edits, asks for commands |
| **Plan** | `plan` | Analyzes and plans without modifying files |
| **Act** | `bypassPermissions` | No permission prompts (sandboxed environments only) |

### Desktop App Environments

| Environment | Description |
|:------------|:------------|
| **Local** | Runs on your machine with direct file access |
| **Remote** | Anthropic cloud infrastructure; continues when app is closed |
| **SSH** | Connect to remote machine (`user@hostname` or SSH config host) |

### Chrome Integration

- Start with `claude --chrome` or `/chrome` in-session
- Enable by default via `/chrome` > "Enabled by default"
- Requires Chrome/Edge + [Claude in Chrome extension](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) v1.0.36+
- Manage site permissions through Chrome extension settings
- VS Code: use `@browser` prefix in prompt box

### CLI-to-Desktop Bridge

| CLI Command / Flag | Desktop Equivalent |
|:-------------------|:-------------------|
| `--model sonnet` | Model dropdown next to send button |
| `--resume` / `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--add-dir` | **+** button in remote sessions |
| `/desktop` (in CLI) | Transfers CLI session to Desktop app |

### Feature Availability by Surface

| Feature | CLI | VS Code | Desktop | Chrome |
|:--------|:----|:--------|:--------|:-------|
| Third-party providers | Yes | Yes | No | N/A |
| File attachments | No | Yes | Yes | N/A |
| Session isolation (worktrees) | `--worktree` flag | Manual | Automatic | N/A |
| Checkpoints / rewind | Yes | Yes | Yes | N/A |
| Remote sessions | No | Resume only | Yes | N/A |
| Browser automation | `--chrome` | `@browser` | N/A | Core feature |
| ` ! ` bash shortcut | Yes | No | N/A | N/A |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) — permission modes, parallel sessions, diff review, connectors, SSH, enterprise configuration, CLI comparison
- [Get Started with Desktop](references/claude-code-desktop-quickstart.md) — installation, first session, and quickstart guide
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — extension installation, keyboard shortcuts, settings, plugin management, checkpoints, third-party providers
- [JetBrains IDEs](references/claude-code-jetbrains.md) — plugin installation, supported IDEs, configuration, remote development, WSL setup
- [Use Claude Code with Chrome](references/claude-code-chrome.md) — browser automation, capabilities, troubleshooting, example workflows

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get Started with Desktop: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
