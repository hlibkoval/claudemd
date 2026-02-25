---
name: ide
description: Reference documentation for Claude Code IDE integrations — Desktop app (visual diffs, live preview, PR monitoring, parallel sessions, connectors, remote/SSH environments), VS Code extension (inline diffs, @-mentions, keyboard shortcuts, plugins, Chrome automation), JetBrains plugin (IntelliJ, PyCharm, WebStorm, etc.), and Chrome browser extension for web app testing and automation.
user-invocable: false
---

# IDE Integrations Documentation

This skill provides the complete official documentation for using Claude Code in Desktop, VS Code, JetBrains IDEs, and Chrome.

## Quick Reference

### Platforms Overview

| Platform    | Interface    | Install                                            | Third-party providers | Linux |
|:------------|:-------------|:---------------------------------------------------|:----------------------|:------|
| Desktop app | GUI (Code tab) | Download from claude.ai                          | No                    | No    |
| VS Code     | Extension panel | Marketplace: `anthropic.claude-code`            | Yes (Bedrock, Vertex, Foundry) | Yes |
| JetBrains   | Terminal plugin | JetBrains Marketplace                           | Yes (via CLI)         | Yes   |
| Chrome      | Browser ext  | Chrome Web Store: `Claude in Chrome` (v1.0.36+)   | No                    | Yes   |

### Desktop Permission Modes

| Mode               | Settings key          | Behavior                                                  |
|:-------------------|:----------------------|:----------------------------------------------------------|
| Ask permissions    | `default`             | Asks before edits and commands                            |
| Auto accept edits  | `acceptEdits`         | Auto-accepts file edits, asks before terminal commands    |
| Plan mode          | `plan`                | Analyzes and plans without modifying files                |
| Bypass permissions | `bypassPermissions`   | No permission prompts (enable in Settings)                |

Remote sessions support Auto accept edits and Plan mode only. `dontAsk` is CLI-only.

### Desktop Environments

| Environment | Runs on                | Continues offline | Multi-repo |
|:------------|:-----------------------|:------------------|:-----------|
| Local       | Your machine           | No                | No         |
| Remote      | Anthropic cloud        | Yes               | Yes        |
| SSH         | Your remote machine    | No                | No         |

### launch.json (Preview Server Config)

```json
{
  "version": "0.0.1",
  "autoVerify": true,
  "configurations": [
    {
      "name": "my-app",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"],
      "port": 3000
    }
  ]
}
```

| Field               | Type     | Description                                          |
|:--------------------|:---------|:-----------------------------------------------------|
| `name`              | string   | Unique identifier for this server                    |
| `runtimeExecutable` | string   | Command to run (`npm`, `yarn`, `node`)               |
| `runtimeArgs`       | string[] | Arguments (e.g. `["run", "dev"]`)                    |
| `port`              | number   | Server port (default 3000)                           |
| `cwd`               | string   | Working directory relative to project root            |
| `env`               | object   | Additional environment variables                     |
| `autoPort`          | boolean  | `true` = auto-find free port; `false` = fail on conflict |
| `program`           | string   | Script to run with `node` (alternative to runtimeExecutable) |
| `args`              | string[] | Arguments passed to `program`                        |

### VS Code Extension Settings

| Setting                           | Default   | Description                                    |
|:----------------------------------|:----------|:-----------------------------------------------|
| `selectedModel`                   | `default` | Model for new conversations                    |
| `useTerminal`                     | `false`   | Launch in terminal mode instead of GUI panel   |
| `initialPermissionMode`           | `default` | `default`, `plan`, `acceptEdits`, `bypassPermissions` |
| `autosave`                        | `true`    | Auto-save files before Claude reads/writes     |
| `useCtrlEnterToSend`              | `false`   | Use Ctrl/Cmd+Enter instead of Enter to send    |
| `respectGitIgnore`                | `true`    | Exclude .gitignore patterns from searches      |
| `allowDangerouslySkipPermissions` | `false`   | Bypass all permission prompts                  |

### VS Code Keyboard Shortcuts

| Command                    | Mac                    | Windows/Linux            |
|:---------------------------|:-----------------------|:-------------------------|
| Focus Input (toggle)       | `Cmd+Esc`             | `Ctrl+Esc`               |
| Open in New Tab            | `Cmd+Shift+Esc`       | `Ctrl+Shift+Esc`         |
| New Conversation           | `Cmd+N`               | `Ctrl+N`                 |
| Insert @-Mention Reference | `Option+K`            | `Alt+K`                  |

### JetBrains Keyboard Shortcuts

| Action                  | Mac              | Windows/Linux      |
|:------------------------|:-----------------|:-------------------|
| Open Claude Code        | `Cmd+Esc`       | `Ctrl+Esc`         |
| Insert file reference   | `Cmd+Option+K`  | `Alt+Ctrl+K`       |

### JetBrains Supported IDEs

IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand.

### Chrome CLI Usage

```bash
claude --chrome           # Start with Chrome integration
/chrome                   # In-session: status, reconnect, permissions
```

Enable by default: run `/chrome` and select "Enabled by default". In VS Code, use `@browser` in the prompt box.

### CLI-to-Desktop Flag Equivalents

| CLI flag                          | Desktop equivalent                          |
|:----------------------------------|:--------------------------------------------|
| `--model sonnet`                  | Model dropdown (before session starts)      |
| `--resume`, `--continue`          | Click session in sidebar                    |
| `--permission-mode`               | Mode selector next to send button           |
| `--dangerously-skip-permissions`  | Bypass permissions mode (enable in Settings)|
| `--add-dir`                       | **+** button in remote sessions             |

### Desktop vs CLI Feature Comparison

| Feature              | CLI                     | Desktop                              |
|:---------------------|:------------------------|:-------------------------------------|
| Third-party providers| Bedrock, Vertex, Foundry| Not available                        |
| File attachments     | Not available           | Images, PDFs                         |
| Session isolation    | `--worktree` flag       | Automatic worktrees                  |
| Multiple sessions    | Separate terminals      | Sidebar tabs                         |
| Scripting            | `--print`, Agent SDK    | Not available                        |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) — visual diffs, live preview, PR monitoring, parallel sessions, connectors, SSH, remote environments, enterprise configuration
- [Desktop Quickstart](references/claude-code-desktop-quickstart.md) — installing the app and starting your first coding session
- [VS Code Extension](references/claude-code-vs-code.md) — installation, @-mentions, keyboard shortcuts, settings, plugins, Chrome automation, checkpoints, third-party providers
- [JetBrains Plugin](references/claude-code-jetbrains.md) — installation, configuration, diff viewing, selection context, remote development, WSL
- [Chrome Integration](references/claude-code-chrome.md) — browser automation, live debugging, form filling, data extraction, session recording, troubleshooting

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Desktop Quickstart: https://code.claude.com/docs/en/desktop-quickstart.md
- VS Code Extension: https://code.claude.com/docs/en/vs-code.md
- JetBrains Plugin: https://code.claude.com/docs/en/jetbrains.md
- Chrome Integration: https://code.claude.com/docs/en/chrome.md
