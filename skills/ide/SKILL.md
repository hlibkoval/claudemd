---
name: ide
description: Reference documentation for Claude Code IDE and desktop integrations — the Desktop app (macOS/Windows), VS Code extension, JetBrains plugin, and Chrome browser integration. Use when installing or configuring Claude Code in VS Code, JetBrains IDEs, the Desktop app, or Chrome; comparing Desktop vs CLI; setting permission modes; managing sessions; or troubleshooting IDE-specific issues.
user-invocable: false
---

# IDE & Desktop Documentation

This skill provides the complete official documentation for Claude Code IDE integrations and the Desktop app.

## Quick Reference

### Integration Options

| Surface       | Platform                           | Install method                                  |
|:--------------|:-----------------------------------|:------------------------------------------------|
| Desktop app   | macOS, Windows (no Linux)          | Download `.dmg` / `.exe` from claude.ai         |
| VS Code ext.  | VS Code 1.98+, Cursor              | Extensions view or `vscode:extension/anthropic.claude-code` |
| JetBrains     | IntelliJ, PyCharm, WebStorm, etc.  | JetBrains Marketplace plugin                    |
| Chrome        | Chrome, Edge (beta; no Brave/Arc)  | Chrome Web Store extension v1.0.36+             |

### Desktop Permission Modes

| Mode     | Settings key        | Behavior                                                          |
|:---------|:--------------------|:------------------------------------------------------------------|
| Ask      | `default`           | Prompts before each file edit or command (default, recommended)   |
| Code     | `acceptEdits`       | Auto-accepts file edits, still asks before terminal commands      |
| Plan     | `plan`              | Analyzes code and creates a plan; no file changes or commands     |
| Act      | `bypassPermissions` | No prompts; equivalent to `--dangerously-skip-permissions` in CLI |

Remote sessions support Code and Plan only. Act requires opt-in in Settings.

### Desktop Session Environments

| Environment | Where Claude runs                            | Notes                                  |
|:------------|:---------------------------------------------|:---------------------------------------|
| Local       | Your machine                                 | Shares shell env vars; Git needed for isolation |
| Remote      | Anthropic cloud                              | Continues if app is closed; no connectors |
| SSH         | Remote machine you manage                   | Claude must be installed on remote host |

Worktrees stored at `<project-root>/.claude/worktrees/` by default. Change in Settings → Claude Code.

### Desktop vs CLI Feature Comparison

| Feature                     | CLI                               | Desktop                                     |
|:----------------------------|:----------------------------------|:--------------------------------------------|
| Third-party providers       | Bedrock, Vertex, Foundry          | Not available (direct Anthropic API only)   |
| Linux support               | Yes                               | No                                          |
| Permission modes            | All incl. `dontAsk`               | Ask, Code, Plan, Act (via Settings)         |
| File attachments            | Not available                     | Images, PDFs                                |
| Session isolation           | Manual git worktrees              | Automatic worktrees                         |
| Multiple sessions           | Separate terminals                | Sidebar tabs                                |
| Scripting / headless        | `--print`, Agent SDK              | Not available                               |
| MCP servers                 | Settings files                    | Connectors UI + settings files              |

Move a CLI session to Desktop: run `/desktop` in the terminal (macOS/Windows only).
Move a Desktop session to CLI: use the "Continue in" menu in the session toolbar.

### VS Code Extension Settings

| Setting                           | Default   | Description                                                                 |
|:----------------------------------|:----------|:----------------------------------------------------------------------------|
| `selectedModel`                   | `default` | Model for new conversations                                                 |
| `initialPermissionMode`           | `default` | `default`, `plan`, `acceptEdits`, or `bypassPermissions`                    |
| `useTerminal`                     | `false`   | Launch in terminal mode instead of graphical panel                          |
| `preferredLocation`               | `panel`   | `sidebar` (right) or `panel` (new tab)                                      |
| `autosave`                        | `true`    | Auto-save files before Claude reads/writes                                  |
| `allowDangerouslySkipPermissions` | `false`   | Bypass all permission prompts (use with extreme caution)                    |

### VS Code Keyboard Shortcuts

| Command                   | Mac                     | Windows/Linux            |
|:--------------------------|:------------------------|:-------------------------|
| Toggle focus editor/Claude | `Cmd+Esc`              | `Ctrl+Esc`               |
| Open in new tab           | `Cmd+Shift+Esc`         | `Ctrl+Shift+Esc`         |
| New conversation          | `Cmd+N` (Claude focused)| `Ctrl+N` (Claude focused)|
| Insert @-mention ref      | `Option+K` (editor focused) | `Alt+K` (editor focused) |

Add `@` + filename to reference files. Select text in editor and Claude sees it automatically.

### JetBrains Plugin Key Info

| Shortcut / Command | Description                                                  |
|:-------------------|:-------------------------------------------------------------|
| `Cmd+Esc` / `Ctrl+Esc` | Quick launch Claude Code from editor                    |
| `Cmd+Option+K` / `Alt+Ctrl+K` | Insert file reference (e.g., `@File#L1-99`)    |
| `/ide`             | Connect an external terminal session to the JetBrains IDE   |

Settings at **Settings → Tools → Claude Code [Beta]**. For remote dev, install plugin on the remote host.

### Chrome Integration

Requires Claude Code v2.0.73+ and Chrome extension v1.0.36+. Not available via third-party providers.

```bash
# Enable Chrome for a session
claude --chrome

# Enable by default (run inside Claude)
/chrome  # then select "Enabled by default"
```

Example prompts:
```
@browser go to localhost:3000 and check the console for errors
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) — permission modes, parallel sessions, diff view, connectors, SSH, enterprise config, CLI comparison
- [Desktop Quickstart](references/claude-code-desktop-quickstart.md) — install, first session, and next steps for new users
- [VS Code Extension](references/claude-code-vs-code.md) — install, prompt box, @-mentions, shortcuts, settings, plugin management, third-party providers
- [JetBrains IDEs](references/claude-code-jetbrains.md) — install, usage, plugin settings, remote dev, WSL, troubleshooting
- [Chrome Integration](references/claude-code-chrome.md) — capabilities, prerequisites, CLI/VS Code usage, example workflows, troubleshooting

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Desktop Quickstart: https://code.claude.com/docs/en/desktop-quickstart.md
- VS Code Extension: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Chrome Integration: https://code.claude.com/docs/en/chrome.md
