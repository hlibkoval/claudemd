---
name: ide
description: Reference documentation for Claude Code IDE integrations — Desktop app (macOS/Windows), VS Code extension, JetBrains plugin, and Chrome browser extension. Covers installation, permission modes, session management, diff review, app preview, PR monitoring, connectors, plugins, SSH/remote sessions, keyboard shortcuts, extension settings, and troubleshooting.
user-invocable: false
---

# IDE Integrations Documentation

This skill provides the complete official documentation for using Claude Code across Desktop, VS Code, JetBrains IDEs, and Chrome.

## Quick Reference

### Surfaces Overview

| Surface | Platforms | Key capabilities |
|:--------|:----------|:-----------------|
| **Desktop app** | macOS, Windows | Visual diff review, live app preview, PR monitoring, parallel sessions with worktree isolation, connectors, remote sessions |
| **VS Code extension** | macOS, Windows, Linux | Inline diffs, @-mentions with line ranges, multiple conversation tabs, checkpoints, plugin manager UI |
| **JetBrains plugin** | IntelliJ, PyCharm, WebStorm, GoLand, PhpStorm, Android Studio | Diff viewing in IDE, selection context sharing, diagnostic sharing |
| **Chrome extension** | Chrome, Edge | Browser automation, console log reading, form filling, GIF recording, authenticated site access |

### Desktop Permission Modes

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Asks before editing files or running commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits, asks before commands |
| Plan mode | `plan` | Analyzes and plans without modifying files |
| Bypass permissions | `bypassPermissions` | No permission prompts (sandboxed environments only) |

### Desktop Environments

| Environment | Description |
|:------------|:------------|
| **Local** | Runs on your machine with direct file access |
| **Remote** | Runs on Anthropic cloud; continues if you close the app |
| **SSH** | Runs on a remote machine you connect to over SSH |

### Desktop Preview Server Config (`.claude/launch.json`)

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (e.g. `npm`, `yarn`) |
| `runtimeArgs` | string[] | Arguments (e.g. `["run", "dev"]`) |
| `port` | number | Server port (default 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables |
| `autoPort` | boolean | `true` = auto-find free port, `false` = fail on conflict |
| `program` | string | Script to run with `node` directly |
| `autoVerify` | boolean | Auto-verify changes after edits (default true, set at top level) |

### VS Code Extension Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | Launch in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `autosave` | `true` | Auto-save files before Claude reads/writes them |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter to send |
| `allowDangerouslySkipPermissions` | `false` | Bypass all permission prompts |

### VS Code Keyboard Shortcuts

| Command | Mac | Windows/Linux |
|:--------|:----|:--------------|
| Focus Input (toggle editor/Claude) | Cmd+Esc | Ctrl+Esc |
| Open in New Tab | Cmd+Shift+Esc | Ctrl+Shift+Esc |
| New Conversation | Cmd+N | Ctrl+N |
| Insert @-Mention Reference | Option+K | Alt+K |

### JetBrains Keyboard Shortcuts

| Command | Mac | Windows/Linux |
|:--------|:----|:--------------|
| Open Claude Code | Cmd+Esc | Ctrl+Esc |
| Insert file reference | Cmd+Option+K | Alt+Ctrl+K |

### Chrome Integration

Start with `--chrome` flag or run `/chrome` in an existing session. Requires the Claude in Chrome extension (v1.0.36+). Works with Chrome and Edge. Not available through third-party providers (Bedrock, Vertex, Foundry).

### Desktop vs CLI Feature Comparison

| Feature | CLI | Desktop |
|:--------|:----|:--------|
| Permission modes | All modes including `dontAsk` | Ask, Auto accept, Plan, Bypass |
| Third-party providers | Bedrock, Vertex, Foundry | Not available |
| MCP servers | Settings files | Connectors UI + settings files |
| File attachments | Not available | Images, PDFs |
| Session isolation | `--worktree` flag | Automatic worktrees |
| Scripting/automation | `--print`, Agent SDK | Not available |
| Linux support | Yes | Not available |

### VS Code Extension vs CLI

| Feature | CLI | VS Code Extension |
|:--------|:----|:------------------|
| Commands and skills | All | Subset (type `/` to see available) |
| MCP server config | Yes | No (configure via CLI, use in extension) |
| Checkpoints | Yes | Yes |
| Tab completion | Yes | No |

### Shared Configuration (Desktop + CLI)

Both surfaces read the same CLAUDE.md files, MCP server configs, hooks, skills, and settings files. MCP servers in `claude_desktop_config.json` (chat app) are separate from Claude Code.

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- permission modes, diff review, app preview, PR monitoring, parallel sessions, connectors, plugins, SSH/remote sessions, enterprise config, troubleshooting
- [Desktop Quickstart](references/claude-code-desktop-quickstart.md) -- installation, first session setup, getting started guide
- [VS Code Extension](references/claude-code-vs-code.md) -- installation, prompt box, @-mentions, keyboard shortcuts, extension settings, checkpoints, plugin management, Chrome integration, third-party providers, troubleshooting
- [JetBrains Plugin](references/claude-code-jetbrains.md) -- supported IDEs, installation, configuration, remote development, WSL setup, troubleshooting
- [Chrome Extension](references/claude-code-chrome.md) -- setup, browser automation capabilities, example workflows, site permissions, troubleshooting

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Desktop Quickstart: https://code.claude.com/docs/en/desktop-quickstart.md
- VS Code Extension: https://code.claude.com/docs/en/vs-code.md
- JetBrains Plugin: https://code.claude.com/docs/en/jetbrains.md
- Chrome Extension: https://code.claude.com/docs/en/chrome.md
