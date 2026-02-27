---
name: ide-doc
description: Reference documentation for Claude Code IDE and desktop integrations -- the Claude Desktop app (Code tab, permission modes, parallel sessions, diff view, preview servers, connectors, SSH/remote sessions, enterprise config), VS Code extension (installation, prompt box, @-mentions, plugin management, settings, CLI vs extension feature comparison), JetBrains plugin (supported IDEs, diff viewing, selection context, /ide command), and Chrome browser integration (automation, debugging, form filling, data extraction).
user-invocable: false
---

# IDE and Desktop Integration Documentation

This skill provides the complete official documentation for Claude Code IDE and desktop integrations.

## Quick Reference

Claude Code is available as a Desktop app, VS Code extension, JetBrains plugin, and with Chrome browser integration.

### Surface Comparison

| Surface       | Platform         | Key Differentiators                                                     |
|:--------------|:-----------------|:------------------------------------------------------------------------|
| Desktop app   | macOS, Windows   | Visual diff, live preview, parallel sessions, connectors UI, remote sessions |
| VS Code extension | Any VS Code  | Inline diffs, @-mentions with line ranges, checkpoints, plugin manager UI |
| JetBrains plugin | IntelliJ, PyCharm, WebStorm, Android Studio, PhpStorm, GoLand | IDE diff viewer, diagnostic sharing, selection context |
| Chrome integration | Chrome, Edge | Browser automation, console log access, form filling, data extraction |

### Desktop Permission Modes

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Asks before editing files or running commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits, asks before commands |
| Plan mode | `plan` | Maps plan without touching files or running commands |
| Bypass permissions | `bypassPermissions` | No prompts; requires opt-in in Settings |

The `dontAsk` mode is CLI-only.

### Desktop Session Environments

| Environment | Description |
|:------------|:------------|
| Local | Runs on your machine, inherits shell environment |
| Remote | Anthropic-hosted cloud, continues without the app open |
| SSH | Remote machine you control (`user@host` or SSH config alias) |

Remote sessions support Auto accept edits and Plan mode. Ask permissions and Bypass permissions are not available for remote sessions.

### Desktop `launch.json` (Preview Servers)

Stored at `.claude/launch.json` in the project root:

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

Key `configurations` fields: `name`, `runtimeExecutable`, `runtimeArgs`, `port` (default 3000), `cwd`, `env`, `autoPort`, `program`, `args`.

Use `runtimeExecutable` + `runtimeArgs` for package managers; use `program` to run a Node.js script directly with `node`.

`autoPort`: `true` = find free port, `false` = fail if port taken, unset = ask once and save answer.

### VS Code Extension Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | Launch in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` (right) or `panel` (new tab) |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter |
| `allowDangerouslySkipPermissions` | `false` | Bypass all permission prompts |

### VS Code Keyboard Shortcuts

| Command | Shortcut (Mac / Win-Linux) |
|:--------|:--------------------------|
| Toggle focus editor/Claude | `Cmd+Esc` / `Ctrl+Esc` |
| Open in new tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` |
| New conversation | `Cmd+N` / `Ctrl+N` (Claude focused) |
| Insert @-mention reference | `Option+K` / `Alt+K` (editor focused) |

### VS Code vs CLI Feature Gaps

| Feature | CLI | VS Code Extension |
|:--------|:----|:-----------------|
| All built-in commands | Yes | Subset (type `/` to see) |
| MCP server config | Yes | Via CLI only |
| Checkpoints (rewind) | Yes | Yes |
| `!` bash shortcut | Yes | No |
| Tab completion | Yes | No |

### JetBrains Plugin Shortcuts

| Action | Mac | Windows/Linux |
|:-------|:----|:--------------|
| Open Claude Code | `Cmd+Esc` | `Ctrl+Esc` |
| Insert file reference | `Cmd+Option+K` | `Alt+Ctrl+K` |

Connect an external terminal to JetBrains with `/ide` inside Claude Code.

For Remote Development, install the plugin on the remote host via Settings → Plugin (Host).

### Chrome Integration

Start with `claude --chrome` or run `/chrome` in an existing session. Use `@browser` in VS Code prompt box.

Capabilities: live debugging, console log access, form filling, data extraction, authenticated web app interaction (shares browser login state), multi-site workflows, session GIF recording.

Supported: Google Chrome and Microsoft Edge only. Not supported: Brave, Arc, WSL.

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- permission modes, diff view, PR monitoring, parallel sessions, preview servers, connectors, SSH/remote sessions, enterprise configuration, CLI comparison
- [Desktop Quickstart](references/claude-code-desktop-quickstart.md) -- installation, first session, key features overview
- [VS Code Extension](references/claude-code-vs-code.md) -- installation, prompt box, @-mentions, plugin management, CLI integration, third-party providers, settings reference
- [JetBrains Plugin](references/claude-code-jetbrains.md) -- supported IDEs, features, installation, configuration, WSL and remote development
- [Chrome Integration](references/claude-code-chrome.md) -- capabilities, prerequisites, CLI and VS Code usage, example workflows, troubleshooting

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Desktop Quickstart: https://code.claude.com/docs/en/desktop-quickstart.md
- VS Code Extension: https://code.claude.com/docs/en/vs-code.md
- JetBrains Plugin: https://code.claude.com/docs/en/jetbrains.md
- Chrome Integration: https://code.claude.com/docs/en/chrome.md
