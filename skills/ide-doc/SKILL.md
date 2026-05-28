---
name: ide-doc
user-invocable: false
---

# IDE & Desktop Integration Documentation

This skill provides the complete official documentation for using Claude Code in IDEs and the desktop app, including VS Code, JetBrains, the Claude Desktop app, Chrome browser integration, and computer use.

## Quick Reference

### Surface Overview

| Surface | How to install | Platform |
|:--------|:---------------|:---------|
| **VS Code extension** | Search "Claude Code" in Extensions view or `Cmd/Ctrl+Shift+X` | macOS, Windows, Linux |
| **Cursor / Windsurf / Kiro** | Same extension, search in the editor's Extensions view | macOS, Windows, Linux |
| **JetBrains plugin** | JetBrains Marketplace → [Claude Code plugin](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-) | macOS, Windows, Linux |
| **Claude Desktop app** | Download `.dmg` (macOS) or `.exe` (Windows) from claude.ai | macOS, Windows only |
| **Chrome integration** | Install "Claude in Chrome" extension (v1.0.36+) from Chrome Web Store | Chrome, Edge |
| **Computer use (CLI)** | Enable `computer-use` server via `/mcp` | macOS only (CLI), macOS + Windows (Desktop) |

### VS Code Extension Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `useTerminal` | `false` | Launch Claude in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` (right) or `panel` (new tab) |
| `autosave` | `true` | Auto-save files before Claude reads or writes them |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter to send |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N to start a new conversation |
| `enableReopenClosedSessionShortcut` | `true` | Cmd/Ctrl+Shift+T to reopen most recently closed Claude tab |
| `hideOnboarding` | `false` | Hide the onboarding checklist |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `usePythonEnvironment` | `true` | Activate the workspace Python environment |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto mode and Bypass permissions to the mode selector |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party provider setups) |
| `claudeProcessWrapper` | — | Executable used to launch the Claude process |

### VS Code Keyboard Shortcuts

| Shortcut | Action |
|:---------|:-------|
| `Cmd/Ctrl+Esc` | Toggle focus between editor and Claude |
| `Cmd/Ctrl+Shift+Esc` | Open a new conversation as an editor tab |
| `Cmd/Ctrl+N` | New conversation (requires `enableNewConversationShortcut: true`) |
| `Cmd/Ctrl+Shift+T` | Reopen most recently closed Claude session tab |
| `Option/Alt+K` | Insert @-mention reference for current file + selection |

### VS Code URI Handler

Open a new tab from scripts or shell aliases:

```
vscode://anthropic.claude-code/open
vscode://anthropic.claude-code/open?prompt=<url-encoded-text>
vscode://anthropic.claude-code/open?session=<session-id>
```

### VS Code Extension vs. CLI Feature Comparison

| Feature | CLI | VS Code Extension |
|:--------|:----|:------------------|
| Commands and skills | All | Subset (type `/` to see available) |
| MCP server config | Yes | Partial (add via CLI; manage with `/mcp` in panel) |
| Checkpoints / rewind | Yes | Yes |
| Bash shortcut (`!`) | Yes | No |
| Tab completion | Yes | No |

### VS Code Built-in IDE MCP Server

The extension runs a local MCP server (`ide`) that the CLI connects to automatically. Two tools are visible to the model:

| Tool | What it does | Writes? |
|:-----|:-------------|:--------|
| `mcp__ide__getDiagnostics` | Returns language-server diagnostics (Problems panel), optionally scoped to one file | No |
| `mcp__ide__executeCode` | Runs Python in the active Jupyter notebook kernel; always prompts via Quick Pick before executing | Yes |

The server binds to `127.0.0.1` on a random high port with a fresh random auth token per activation. Token is stored in `~/.claude/ide/` with `0600` permissions.

### JetBrains Plugin — Key Features & Shortcuts

| Feature | Detail |
|:--------|:-------|
| Quick launch | `Cmd+Esc` (Mac) / `Ctrl+Esc` (Windows/Linux) |
| File reference shortcut | `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Linux/Windows) — inserts `@src/auth.ts#L1-99` |
| Diff viewing | Shown in IDE diff viewer instead of terminal |
| Selection context | Current selection auto-shared with Claude; blocked by `Read` deny rules |
| Diagnostic sharing | Lint/syntax errors auto-shared as you work |

JetBrains plugin settings: **Settings → Tools → Claude Code [Beta]**

- Set diff tool: `/config` → set diff tool to `auto` (IDE) or `terminal`
- Custom Claude command: e.g. `claude`, `/usr/local/bin/claude`, or `npx @anthropic-ai/claude-code`
- WSL: use `wsl -d Ubuntu -- bash -lic "claude"` as the Claude command

### Desktop App — Session Environments

| Environment | Where Claude runs | Continues when app closed? |
|:------------|:------------------|:--------------------------|
| **Local** | Your machine | No |
| **Remote** | Anthropic cloud infrastructure | Yes |
| **SSH** | Remote machine you manage | Depends on remote |

### Desktop App — Permission Modes

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Claude asks before each edit or command |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits; still asks for other terminal commands |
| Plan mode | `plan` | Explores then proposes a plan; no source edits |
| Auto | `auto` | Background safety checks; reduces prompts. Requires Sonnet 4.6, Opus 4.6, or Opus 4.7 |
| Bypass permissions | `bypassPermissions` | No prompts. Enable in Settings. Only use in sandboxed environments. |

### Desktop App — Keyboard Shortcuts (Code Tab, macOS)

| Shortcut | Action |
|:---------|:-------|
| `Cmd /` | Show keyboard shortcuts |
| `Cmd N` | New session |
| `Cmd W` | Close session |
| `Ctrl Tab` / `Ctrl Shift Tab` | Next / previous session |
| `Esc` | Stop Claude's response |
| `Cmd Shift D` | Toggle diff pane |
| `Cmd Shift P` | Toggle preview pane |
| `Ctrl \`` | Toggle terminal pane |
| `Cmd \` | Close focused pane |
| `Cmd ;` | Open side chat |
| `Ctrl O` | Cycle view modes (Normal / Verbose / Summary) |
| `Cmd Shift M` | Open permission mode menu |
| `Cmd Shift I` | Open model menu |

Use `Ctrl` in place of `Cmd` on Windows.

### Desktop App — `.claude/launch.json` (Preview Server Config)

```json
{
  "version": "0.0.1",
  "autoVerify": true,
  "configurations": [
    {
      "name": "my-app",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"],
      "port": 3000,
      "autoPort": true,
      "env": { "NODE_ENV": "development" }
    }
  ]
}
```

Key fields: `name`, `runtimeExecutable`, `runtimeArgs`, `port`, `cwd`, `env`, `autoPort` (`true` = auto-find free port, `false` = fail if taken), `program` (for `node` scripts), `args`.

`autoVerify: false` disables automatic post-edit verification. Default is on.

### Desktop App — Enterprise Managed Settings Keys

| Key | Description |
|:----|:------------|
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to prevent Bypass permissions mode |
| `disableAutoMode` | Set to `"disable"` to remove Auto mode from the selector |
| `sshConfigs` | Pre-configure SSH connections (array; users can select but not edit) |
| `sshHostAllowlist` | Restrict SSH to approved hostnames/patterns; empty array disables SSH |
| `managedMcpServers` | Push MCP server configs to all users (third-party deployments only) |

### Chrome Integration (Beta)

Requires Claude in Chrome extension v1.0.36+ and Claude Code v2.0.73+. Works with Google Chrome and Microsoft Edge. Not supported on Brave, Arc, or WSL.

| CLI usage | Description |
|:----------|:------------|
| `claude --chrome` | Launch with Chrome integration enabled |
| `/chrome` | Enable from within an existing session, check status, or reconnect |

In VS Code, use `@browser` in the prompt box followed by your task.

Capabilities: live console debugging, design verification, web app testing, authenticated web app interaction, data extraction, task automation, session recording (GIFs).

### Computer Use

| Surface | Platforms | How to enable |
|:--------|:----------|:--------------|
| CLI | macOS only | Enable `computer-use` server in `/mcp` |
| Desktop app | macOS and Windows | Toggle in Settings > General |

Requires Pro or Max plan. Not available on Team/Enterprise plans.

App control tiers (fixed, cannot be changed):

| Tier | What Claude can do | Applies to |
|:-----|:-------------------|:-----------|
| View only | See the app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, but not type | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

Safety: approvals are per-session (30 min for Dispatch-spawned sessions). Terminal is excluded from screenshots. Press `Esc` anywhere to abort (CLI) or stop the current action.

CLI: `computer-use` is a built-in MCP server; one session holds a machine-wide lock at a time.

### Desktop CLI Flag Equivalents

| CLI flag | Desktop equivalent |
|:---------|:-------------------|
| `--model sonnet` | Model dropdown next to send button |
| `--resume`, `--continue` | Click a session in the sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (Settings → Claude Code) |
| `--add-dir` | Add multiple repos with `+` button in remote sessions |
| `--verbose` | Verbose view mode (Transcript view dropdown) |
| `--print`, `--output-format` | Not available — Desktop is interactive only |

Desktop and CLI share: CLAUDE.md files, MCP servers in `~/.claude.json` / `.mcp.json`, hooks, skills, and `~/.claude/settings.json`. Note: MCP servers in `claude_desktop_config.json` (chat app) are separate from the Code tab.

## Full Documentation

For the complete official documentation, see the reference files:

- [Desktop App Reference](references/claude-code-desktop.md) — Full reference for the Code tab: sessions, permission modes, diff view, preview servers, SSH, enterprise config, and CLI comparison
- [Desktop App Quickstart](references/claude-code-desktop-quickstart.md) — Install and start your first session in the desktop app
- [VS Code Extension](references/claude-code-vs-code.md) — Install, configure, and use Claude Code in VS Code, Cursor, and other VS Code forks
- [JetBrains IDEs](references/claude-code-jetbrains.md) — Plugin installation, usage, and troubleshooting for IntelliJ, PyCharm, WebStorm, and others
- [Chrome Integration](references/claude-code-chrome.md) — Connect Claude Code to Chrome for browser automation, debugging, and web app testing
- [Computer Use (CLI)](references/claude-code-computer-use.md) — Enable computer use in the CLI to control apps and your screen on macOS

## Sources

- Desktop App Reference: https://code.claude.com/docs/en/desktop.md
- Desktop App Quickstart: https://code.claude.com/docs/en/desktop-quickstart.md
- VS Code Extension: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Chrome Integration: https://code.claude.com/docs/en/chrome.md
- Computer Use (CLI): https://code.claude.com/docs/en/computer-use.md
