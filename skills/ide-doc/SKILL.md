---
name: ide-doc
user-invocable: false
---

# IDE and Desktop Documentation

This skill provides the complete official documentation for Claude Code IDE integrations and desktop surfaces: the Desktop app, VS Code extension, JetBrains plugin, Chrome browser integration, and computer use from the CLI.

## Quick Reference

### Available Surfaces

| Surface | Platforms | How to enable |
|:--------|:----------|:--------------|
| **Desktop app** | macOS, Windows | Download from claude.ai/download; use the Code tab |
| **VS Code extension** | macOS, Windows, Linux | Install from VS Code Marketplace (`anthropic.claude-code`) |
| **JetBrains plugin** | IntelliJ, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand | Install from JetBrains Marketplace |
| **Chrome integration** | Chrome, Edge (beta) | Install Claude in Chrome extension v1.0.36+; use `--chrome` flag or `/chrome` |
| **Computer use (CLI)** | macOS only (CLI); macOS + Windows (Desktop) | Enable `computer-use` server via `/mcp` in CLI; toggle in Desktop Settings |

### Desktop App: Permission Modes

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| **Ask permissions** | `default` | Asks before editing files or running commands |
| **Auto accept edits** | `acceptEdits` | Auto-accepts file edits and common fs commands |
| **Plan mode** | `plan` | Reads and explores, proposes a plan, no source edits |
| **Auto** | `auto` | Executes with background safety checks; requires Opus 4.6/Sonnet 4.6+ |
| **Bypass permissions** | `bypassPermissions` | No prompts; equivalent to `--dangerously-skip-permissions` |

Remote sessions support Auto accept edits and Plan mode only. `dontAsk` mode is CLI-only.

### Desktop App: Keyboard Shortcuts (macOS / Windows)

| Shortcut | Action |
|:---------|:-------|
| `Cmd/Ctrl N` | New session |
| `Cmd/Ctrl W` | Close session |
| `Ctrl Tab` / `Ctrl Shift Tab` | Next/previous session |
| `Esc` | Stop Claude's response |
| `Cmd/Ctrl Shift D` | Toggle diff pane |
| `Cmd/Ctrl Shift P` | Toggle preview pane |
| `Ctrl` backtick | Toggle terminal pane |
| `Cmd/Ctrl ;` | Open side chat |
| `Ctrl O` | Cycle view modes |
| `Cmd/Ctrl Shift M` | Open permission mode menu |
| `Cmd/Ctrl Shift I` | Open model menu |
| `Cmd/Ctrl /` | Show keyboard shortcuts |

### Desktop App: View Modes

| Mode | Shows |
|:-----|:------|
| **Normal** | Tool calls collapsed into summaries, full text responses |
| **Verbose** | Every tool call, file read, and intermediate step |
| **Summary** | Only Claude's final responses and changes made |

### Desktop App: Session Environments

| Environment | Where Claude runs | Notes |
|:------------|:------------------|:------|
| **Local** | Your machine | Direct file access |
| **Remote** | Anthropic cloud | Continues even if app is closed; multi-repo support |
| **SSH** | Remote machine you connect to | Desktop auto-installs Claude Code on first connect |

### Desktop App: `.claude/launch.json` Fields

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique identifier for this server config |
| `runtimeExecutable` | string | Command to run: `npm`, `yarn`, `node`, etc. |
| `runtimeArgs` | string[] | Arguments to `runtimeExecutable` (e.g., `["run", "dev"]`) |
| `port` | number | Port the server listens on (default 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Extra environment variables as key-value pairs |
| `autoPort` | boolean | `true` = find free port; `false` = fail if busy; unset = prompt |
| `program` | string | Node.js script to run directly (alternative to `runtimeExecutable`) |
| `args` | string[] | Arguments passed to `program` |
| `autoVerify` | boolean | Top-level field; default `true`. Set `false` to disable auto-verification |

Use `runtimeExecutable`+`runtimeArgs` for package manager commands. Use `program` to run a Node.js script directly with `node`.

### Desktop App: Managed Settings Keys

| Key | Description |
|:----|:------------|
| `permissions.disableBypassPermissionsMode` | Set `"disable"` to prevent bypass permissions mode |
| `disableAutoMode` | Set `"disable"` to remove Auto from the mode selector |
| `autoMode` | Customize auto mode classifier rules org-wide |
| `sshConfigs` | Pre-distribute SSH connections to team members |
| `sshHostAllowlist` | Restrict SSH sessions to approved host patterns |
| `managedMcpServers` | Push MCP server configs to all users (3P deployments only) |

`sshHostAllowlist` is read from managed settings only; ignored in user/project settings.

### Desktop App: CLI Flag Equivalents

| CLI flag | Desktop equivalent |
|:---------|:-------------------|
| `--model` | Model dropdown next to send button |
| `--resume`, `--continue` | Click a session in the sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (enable in Settings) |
| `--add-dir` | `+` button to add repos in remote sessions |
| `--verbose` | Verbose view mode in Transcript view dropdown |
| `MAX_THINKING_TOKENS` | Set in local environment editor |

### Desktop App: What's Not Available

- Third-party providers (Bedrock, Foundry) — use CLI; enterprise can configure Vertex AI
- Linux — use CLI
- Inline code suggestions / autocomplete
- Agent teams (parallel sessions messaging each other) — use CLI
- Terminal-dialog commands (`/permissions`, `/config`, `/agents`, `/doctor`) — edit settings files directly

### VS Code Extension: Key Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `useTerminal` | `false` | Use CLI panel instead of graphical panel |
| `initialPermissionMode` | `default` | Starting permission mode: `default`, `plan`, `acceptEdits`, `bypassPermissions` |
| `preferredLocation` | `panel` | Where Claude opens: `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter to send |
| `enableNewConversationShortcut` | `false` | Cmd/Ctrl+N to start new conversation |
| `enableReopenClosedSessionShortcut` | `true` | Cmd/Ctrl+Shift+T to reopen last closed session tab |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party provider setups) |
| `allowDangerouslySkipPermissions` | `false` | Add Bypass permissions to mode selector |

### VS Code Extension: Shortcuts

| Shortcut | Action |
|:---------|:-------|
| `Cmd/Ctrl Esc` | Toggle focus between editor and Claude |
| `Cmd/Ctrl Shift Esc` | Open new conversation as editor tab |
| `Option/Alt K` | Insert @-mention reference for current selection |
| `Cmd/Ctrl Shift T` | Reopen most recently closed Claude session tab |
| `Cmd/Ctrl N` | New conversation (requires `enableNewConversationShortcut: true`) |

On macOS Tahoe+, `Cmd+Esc` may be intercepted by the system Game Overlay — disable in System Settings → Keyboard → Game Controllers.

### VS Code Extension: URI Handler

Open a new Claude Code tab from any script or browser:

```
vscode://anthropic.claude-code/open
```

Optional query params: `prompt` (URL-encoded text to pre-fill) and `session` (session ID to resume).

### VS Code Extension: Built-in IDE MCP Server

The extension runs a local MCP server named `ide` that exposes two tools to Claude:

| Tool | What it does | Writes? |
|:-----|:-------------|:--------|
| `mcp__ide__getDiagnostics` | Returns language-server errors/warnings from VS Code Problems panel | No |
| `mcp__ide__executeCode` | Runs Python in active Jupyter notebook kernel (always asks first) | Yes |

The server binds to `127.0.0.1` on a random port with a per-activation auth token. It is hidden from `/mcp` and only relevant if you use `PreToolUse` hooks to allowlist MCP tools.

### VS Code Extension: Checkpoint Rewind Options

| Option | Effect |
|:-------|:-------|
| Fork conversation from here | New branch from this message; code changes intact |
| Rewind code to here | Revert file changes to this point; full history kept |
| Fork conversation and rewind code | New branch + revert file changes |

### VS Code vs. CLI Feature Comparison

| Feature | CLI | VS Code Extension |
|:--------|:----|:------------------|
| Commands and skills | All | Subset (type `/` to see) |
| MCP server config | Full | Add via CLI; manage existing via `/mcp` |
| Checkpoints | Yes | Yes |
| `!` bash shortcut | Yes | No |
| Tab completion | Yes | No |

### JetBrains: Key Shortcuts

| Shortcut | Action |
|:---------|:-------|
| `Cmd Esc` (Mac) / `Ctrl Esc` (Win/Linux) | Open Claude Code from editor |
| `Cmd Option K` (Mac) / `Alt Ctrl K` (Win/Linux) | Insert file reference (`@src/auth.ts#L1-99`) |

Configure via **Settings → Tools → Claude Code [Beta]**. For remote development, install the plugin in the remote host via **Settings → Plugin (Host)**.

### JetBrains: WSL2 "No available IDEs detected"

Two fixes: add a Windows Firewall rule to allow WSL2 traffic (`New-NetFirewallRule` in PowerShell as Admin), or switch WSL2 to mirrored networking by adding `networkingMode=mirrored` to `.wslconfig` (requires Windows 11 22H2+).

### Chrome Integration

Start with `--chrome` flag or run `/chrome` in an active session. Requires:
- Claude in Chrome extension v1.0.36+
- Claude Code v2.0.73+
- Pro, Max, Team, or Enterprise plan (direct Anthropic; not available via Bedrock/Vertex/Foundry)

In VS Code, use `@browser` mention in the prompt box. Chrome integration is not supported on Brave, Arc, or WSL.

### Chrome Integration: Common Errors

| Error | Cause | Fix |
|:------|:------|:----|
| "Browser extension is not connected" | Native messaging host unreachable | Restart Chrome + Claude Code, then `/chrome` to reconnect |
| "Extension not detected" | Extension not installed or disabled | Install/enable in `chrome://extensions` |
| "No tab available" | Claude acted before tab was ready | Ask Claude to create a new tab and retry |
| "Receiving end does not exist" | Extension service worker went idle | Run `/chrome` → "Reconnect extension" |

### Computer Use (CLI)

Enable via `/mcp` → select `computer-use` → **Enable**. Requires:
- macOS only (for CLI; Desktop supports macOS + Windows)
- Claude Code v2.1.85+
- Pro or Max plan
- Direct Anthropic auth (not Bedrock/Vertex/Foundry)
- Interactive session (not available with `-p` flag)

Press `Esc` or `Ctrl+C` at any time to stop and restore hidden windows.

### Computer Use: App Control Tiers

| Tier | What Claude can do | Applies to |
|:-----|:-------------------|:-----------|
| View only | See the app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, no typing or keyboard shortcuts | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

### Computer Use: CLI vs. Desktop Differences

| Feature | Desktop | CLI |
|:--------|:--------|:----|
| Platforms | macOS and Windows | macOS only |
| Enable | Toggle in Settings → General | Enable `computer-use` in `/mcp` |
| Denied apps list | Configurable in Settings | Not yet available |
| Auto-unhide toggle | Optional | Always on |

## Full Documentation

For the complete official documentation, see the reference files:

- [Desktop Application](references/claude-code-desktop.md) — Permission modes, diff view, preview servers, session management, parallel sessions, SSH sessions, computer use, enterprise configuration, CLI comparison, troubleshooting
- [Get Started with the Desktop App](references/claude-code-desktop-quickstart.md) — Installation walkthrough, first session steps, overview of desktop features
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — Extension installation, prompt box features, @-mentions, session history, plugin management, settings reference, built-in IDE MCP server, checkpoints, third-party provider setup
- [JetBrains IDEs](references/claude-code-jetbrains.md) — Supported IDEs, installation, shortcuts, plugin settings, remote development, WSL2 configuration, troubleshooting
- [Use Claude Code with Chrome](references/claude-code-chrome.md) — Setup, capabilities, example workflows (debugging, form filling, data extraction, multi-site tasks), troubleshooting
- [Let Claude Use Your Computer from the CLI](references/claude-code-computer-use.md) — Enabling computer use, per-session app approval, safety guardrails, example workflows, CLI vs. Desktop differences, troubleshooting

## Sources

- Desktop Application: https://code.claude.com/docs/en/desktop.md
- Get Started with the Desktop App: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude Use Your Computer from the CLI: https://code.claude.com/docs/en/computer-use.md
