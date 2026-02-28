---
name: ide-doc
description: Complete documentation for Claude Code IDE integrations — Desktop app (visual diffs, app preview, PR monitoring, parallel sessions, remote sessions, connectors, enterprise config), VS Code extension (inline diffs, @-mentions, commands, shortcuts, plugins, checkpoints), JetBrains plugin (IntelliJ, PyCharm, WebStorm), and Chrome browser extension (browser automation, debugging, data extraction). Load when discussing IDE setup, Desktop app, VS Code extension, JetBrains plugin, Chrome integration, permission modes, preview servers, or launch.json configuration.
user-invocable: false
---

# IDE Integrations Documentation

This skill provides the complete official documentation for Claude Code IDE integrations: Desktop app, VS Code extension, JetBrains plugin, and Chrome browser extension.

## Quick Reference

Claude Code runs in four IDE surfaces: the Desktop app (macOS/Windows), VS Code extension, JetBrains plugin, and Chrome extension. All share configuration (CLAUDE.md, MCP servers, hooks, skills, settings).

### Platform Availability

| Surface | Platforms | Key differentiators |
|:--------|:----------|:-------------------|
| Desktop app | macOS, Windows | Visual diffs, app preview, PR monitoring, parallel sessions, remote sessions, connectors |
| VS Code extension | macOS, Windows, Linux | Inline diffs, @-mentions with line ranges, checkpoints, terminal mode, plugin manager UI |
| JetBrains plugin | macOS, Windows, Linux | IntelliJ, PyCharm, WebStorm, GoLand, PhpStorm, Android Studio |
| Chrome extension | macOS, Windows, Linux | Browser automation, console reading, form filling, data extraction, GIF recording |
| CLI | macOS, Windows, Linux | Scripting, automation, headless mode, agent teams, third-party providers |

### Desktop Permission Modes

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Asks before editing files or running commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits, asks before terminal commands |
| Plan mode | `plan` | Analyzes code and creates plan without modifying files |
| Bypass permissions | `bypassPermissions` | No permission prompts (enable in Settings; sandboxed environments only) |

Remote sessions support Auto accept edits and Plan mode only.

### Desktop Preview Server Config (`launch.json`)

Stored at `.claude/launch.json`. Supports JSON with comments.

| Field | Type | Description |
|:------|:-----|:-----------|
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments for runtimeExecutable |
| `port` | number | Server port (default: 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables |
| `autoPort` | boolean | `true` = find free port; `false` = fail on conflict; unset = ask |
| `program` | string | Script to run with `node` directly |
| `args` | string[] | Arguments for `program` |
| `autoVerify` | boolean | Auto-verify code changes after edits (default: `true`, set at top level) |

### VS Code Extension Shortcuts

| Command | Mac | Windows/Linux |
|:--------|:----|:-------------|
| Toggle focus (editor/Claude) | `Cmd+Esc` | `Ctrl+Esc` |
| Open in new tab | `Cmd+Shift+Esc` | `Ctrl+Shift+Esc` |
| New conversation | `Cmd+N` | `Ctrl+N` |
| Insert @-mention reference | `Option+K` | `Alt+K` |

### VS Code Extension Settings

| Setting | Default | Description |
|:--------|:--------|:-----------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | Terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Ctrl/Cmd+Enter to send instead of Enter |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party providers) |
| `allowDangerouslySkipPermissions` | `false` | Bypass all permission prompts |

### JetBrains Shortcuts

| Action | Mac | Windows/Linux |
|:-------|:----|:-------------|
| Open Claude Code | `Cmd+Esc` | `Ctrl+Esc` |
| Insert file reference | `Cmd+Option+K` | `Alt+Ctrl+K` |

### Chrome Extension

Start with `claude --chrome` or run `/chrome` in an existing session. In VS Code, use `@browser` in the prompt box.

| Capability | Example |
|:-----------|:--------|
| Live debugging | Read console errors, fix code |
| Design verification | Build UI, verify in browser |
| Web app testing | Test forms, check regressions |
| Authenticated apps | Interact with Google Docs, Gmail, Notion |
| Data extraction | Pull structured data from pages to CSV |
| Task automation | Form filling, multi-site workflows |
| Session recording | Record interactions as GIF |

Chrome integration requires Chrome extension v1.0.36+, Claude Code v2.0.73+, and a direct Anthropic plan.

### Feature Comparison: CLI vs Desktop

| Feature | CLI | Desktop |
|:--------|:----|:--------|
| Third-party providers | Bedrock, Vertex, Foundry | Not available |
| MCP servers | Settings files | Connectors UI + settings files |
| File attachments | Not available | Images, PDFs |
| Session isolation | `--worktree` flag | Automatic worktrees |
| Multiple sessions | Separate terminals | Sidebar tabs |
| Scripting/automation | `--print`, Agent SDK | Not available |
| Agent teams | Yes | Not available |
| Linux | Yes | Not available |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- full Desktop reference: permission modes, preview servers, diff review, PR monitoring, parallel sessions, remote sessions, SSH, connectors, plugins, enterprise configuration, troubleshooting
- [Desktop quickstart](references/claude-code-desktop-quickstart.md) -- installation guide, first session walkthrough, environment setup, next steps
- [VS Code extension](references/claude-code-vs-code.md) -- installation, prompt box, @-mentions, commands, shortcuts, settings, plugins, checkpoints, terminal mode, third-party providers, Chrome integration, troubleshooting
- [JetBrains plugin](references/claude-code-jetbrains.md) -- supported IDEs, installation, diff viewing, selection context, configuration, remote development, WSL setup, troubleshooting
- [Chrome extension](references/claude-code-chrome.md) -- browser automation, console debugging, form filling, data extraction, GIF recording, site permissions, troubleshooting

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Desktop quickstart: https://code.claude.com/docs/en/desktop-quickstart.md
- VS Code extension: https://code.claude.com/docs/en/vs-code.md
- JetBrains plugin: https://code.claude.com/docs/en/jetbrains.md
- Chrome extension: https://code.claude.com/docs/en/chrome.md
