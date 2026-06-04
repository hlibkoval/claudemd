---
name: ide-doc
user-invocable: false
---

# IDE and Desktop Documentation

This skill provides the complete official documentation for using Claude Code in graphical environments: the Claude Desktop app (Code tab), the VS Code extension, JetBrains IDEs, Chrome browser integration, and computer use from both the Desktop app and the CLI.

## Quick Reference

### Surface Overview

| Surface | Platforms | Key strength |
|:--------|:----------|:-------------|
| **Desktop app (Code tab)** | macOS, Windows | Parallel sessions, visual diff review, PR monitoring, pane layout |
| **VS Code extension** | macOS, Windows, Linux | Inline diffs, @-mentions with line ranges, checkpoints, graphical plugin manager |
| **JetBrains plugin** | All JetBrains IDEs | Diff viewer, selection context, diagnostic sharing |
| **Chrome integration** | Chrome, Edge (beta) | Browser automation, console debugging, form filling, data extraction |
| **Computer use (Desktop)** | macOS, Windows | Screen control for native apps, requires Pro or Max plan |
| **Computer use (CLI)** | macOS only | Same engine, enabled via `/mcp` → `computer-use` |

### Desktop App: Permission Modes

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| **Ask permissions** | `default` | Claude asks before editing files or running commands |
| **Auto accept edits** | `acceptEdits` | Auto-accepts file edits and common filesystem commands |
| **Plan mode** | `plan` | Reads and explores but proposes plan without editing code |
| **Auto** | `auto` | Background safety checks; requires Opus 4.6+ or Sonnet 4.6; research preview |
| **Bypass permissions** | `bypassPermissions` | No prompts; only use in sandboxed containers or VMs |

Remote sessions support Auto accept edits and Plan mode only. `dontAsk` mode is CLI-only.

### Desktop App: Keyboard Shortcuts (macOS / Windows with Ctrl)

| Shortcut | Action |
|:---------|:-------|
| `Cmd /` | Show keyboard shortcuts |
| `Cmd N` | New session |
| `Cmd W` | Close session |
| `Ctrl Tab` / `Ctrl Shift Tab` | Next or previous session |
| `Esc` | Stop Claude's response |
| `Cmd Shift D` | Toggle diff pane |
| `Cmd Shift P` | Toggle preview pane |
| `Ctrl ` ` ` | Toggle terminal pane |
| `Cmd \` | Close focused pane |
| `Cmd ;` | Open side chat |
| `Ctrl O` | Cycle view modes (Normal / Verbose / Summary) |
| `Cmd Shift M` | Open permission mode menu |
| `Cmd Shift I` | Open model menu |
| `Cmd Shift E` | Open effort menu |

### Desktop App: launch.json Configuration Fields

File location: `.claude/launch.json` in project root.

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique identifier for the server |
| `runtimeExecutable` | string | Command to run, e.g., `npm`, `yarn`, `node` |
| `runtimeArgs` | string[] | Arguments to `runtimeExecutable`, e.g., `["run", "dev"]` |
| `port` | number | Port the server listens on (default 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables (no secrets — committed to repo) |
| `autoPort` | boolean | `true` = auto-pick free port; `false` = fail if port taken; unset = prompt |
| `program` | string | Script to run with `node` directly |
| `args` | string[] | Arguments to `program` (only when `program` is set) |
| `autoVerify` | boolean | Top-level field; `false` disables auto-verification after edits |

### Desktop App: Environment Types

| Type | Where it runs | Persists when app closes? |
|:-----|:--------------|:--------------------------|
| **Local** | Your machine | N/A |
| **Remote** | Anthropic cloud | Yes |
| **SSH** | Remote machine you manage | N/A |

SSH fields (in `sshConfigs` or Settings dialog): `id`, `name`, `sshHost` (required); `sshPort`, `sshIdentityFile`, `startDirectory` (optional).

### Desktop App: Managed Settings Keys

| Key | Description |
|:----|:------------|
| `permissions.disableBypassPermissionsMode` | Set `"disable"` to block Bypass permissions mode |
| `disableAutoMode` | Set `"disable"` to remove Auto from the mode selector |
| `autoMode` | Configure Auto mode classifier trust/block rules |
| `sshConfigs` | Pre-configure SSH connections (users cannot edit managed entries) |
| `sshHostAllowlist` | Restrict SSH to hostname patterns; `[]` disables SSH entirely |
| `managedMcpServers` | Push MCP configs to all users (third-party deployments only) |

### Desktop App: Computer Use App Permission Tiers

| Tier | What Claude can do | Applies to |
|:-----|:-------------------|:-----------|
| **View only** | Screenshots only | Browsers, trading platforms |
| **Click only** | Click and scroll, no typing | Terminals, IDEs |
| **Full control** | Click, type, drag, keyboard shortcuts | Everything else |

Computer use requires Pro or Max plan. Not available on Team or Enterprise plans.

### VS Code Extension Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `useTerminal` | `false` | Launch Claude in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | Default mode: `default`, `plan`, `acceptEdits`, `bypassPermissions` |
| `preferredLocation` | `panel` | Where Claude opens: `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads or writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter to send |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N for new conversation |
| `enableReopenClosedSessionShortcut` | `true` | Use Cmd/Ctrl+Shift+T to reopen closed Claude tab |
| `hideOnboarding` | `false` | Hide onboarding checklist |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `usePythonEnvironment` | `true` | Activate workspace Python environment |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party provider setups) |
| `allowDangerouslySkipPermissions` | `false` | Adds Bypass permissions to mode selector (sandboxes only) |

Add `"$schema": "https://json.schemastore.org/claude-code-settings.json"` to `settings.json` for autocomplete.

### VS Code Extension: Commands and Shortcuts

| Command | Shortcut | Description |
|:--------|:---------|:------------|
| Focus Input | `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| Open in New Tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | Open new conversation as editor tab |
| New Conversation | `Cmd+N` / `Ctrl+N` | Start new conversation (requires `enableNewConversationShortcut`) |
| Reopen Closed Session | `Cmd+Shift+T` / `Ctrl+Shift+T` | Reopen most recently closed Claude tab |
| Insert @-Mention Reference | `Option+K` / `Alt+K` | Insert reference to current file and selection |

URI handler to open Claude from external tools: `vscode://anthropic.claude-code/open?prompt=<url-encoded-text>&session=<id>`

### VS Code: Built-in IDE MCP Server (hidden)

The extension runs a local MCP server named `ide` (not shown in `/mcp`). Two tools exposed to the model:

| Tool | What it does | Writes? |
|:-----|:-------------|:--------|
| `mcp__ide__getDiagnostics` | Returns VS Code language-server diagnostics (Problems panel) | No |
| `mcp__ide__executeCode` | Runs Python in active Jupyter notebook (always shows Quick Pick confirmation) | Yes |

The server binds to `127.0.0.1` on a random port; auth token stored at `~/.claude/ide/` with `0600` permissions.

### VS Code vs. CLI Feature Comparison

| Feature | CLI | VS Code Extension |
|:--------|:----|:------------------|
| Commands and skills | All | Subset (type `/` to see available) |
| MCP server config | Full | Add via CLI; manage existing with `/mcp` in panel |
| Checkpoints (rewind) | Yes | Yes |
| Bash `!` shortcut | Yes | No |
| Tab completion | Yes | No |

### JetBrains Plugin: Quick Reference

| Item | Detail |
|:-----|:-------|
| Supported IDEs | IntelliJ, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand |
| Open Claude | `Cmd+Esc` (Mac) or `Ctrl+Esc` (Windows/Linux) |
| File reference shortcut | `Cmd+Option+K` (Mac) or `Alt+Ctrl+K` (Linux/Windows) |
| Connect external terminal | Run `/ide` inside Claude Code |
| Diff tool config | `/config` → set diff tool to `auto` or `terminal` |
| Remote Development | Install plugin on the **remote host** via Settings → Plugin (Host) |

WSL2 "No available IDEs detected": caused by NAT networking. Fix: add a Windows Firewall inbound rule for the WSL2 subnet, or set `networkingMode=mirrored` in `.wslconfig` (Windows 11 22H2+).

### Chrome Integration

- CLI flag: `claude --chrome` or enable via `/chrome` in session
- Enable by default: run `/chrome` → "Enabled by default"
- Requirements: Claude Code v2.0.73+, Chrome extension v1.0.36+, Pro/Max/Team/Enterprise plan, direct Anthropic API (not Bedrock/Vertex/Foundry)
- Supported browsers: Google Chrome, Microsoft Edge (not Brave, Arc, or other Chromium forks; not WSL)
- Use `@browser` in VS Code extension prompt box

Capabilities: live console debugging, design verification, web app testing, authenticated app interaction (Google Docs, Notion, Gmail), data extraction, form automation, session recording as GIF.

### Computer Use: CLI vs. Desktop

| Feature | Desktop | CLI |
|:--------|:--------|:----|
| Platforms | macOS and Windows | macOS only |
| Enable | Settings > General → Computer use toggle | Enable `computer-use` in `/mcp` |
| Denied apps list | Configurable in Settings | Not yet available |
| Auto-unhide when done | Optional | Always on |
| Stop | `Esc` key anywhere | `Esc` or `Ctrl+C` in terminal |

CLI computer use requires Claude Code v2.1.85+, interactive session (not `-p` flag), Pro or Max plan, and authentication through claude.ai (not third-party providers).

### Desktop App: CLI Flag Equivalents

| CLI flag | Desktop equivalent |
|:---------|:-------------------|
| `--model sonnet` | Model dropdown next to send button |
| `--resume`, `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (Settings → Claude Code) |
| `--add-dir` | Add repos with `+` button in remote sessions |
| `--verbose` | Verbose view mode in Transcript view dropdown |
| `--print`, `--output-format` | Not available in Desktop |

Shared config between Desktop and CLI: CLAUDE.md files, MCP servers, hooks, skills, settings files.

## Full Documentation

For the complete official documentation, see the reference files:

- [Desktop Application](references/claude-code-desktop.md) — Full reference for the Code tab: sessions, permission modes, pane layout, diff view, PR monitoring, app preview, computer use, SSH, enterprise configuration, and CLI comparison
- [Get Started with the Desktop App](references/claude-code-desktop-quickstart.md) — Installation walkthrough, first session setup, and next steps
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — Extension install, panel usage, @-mentions, checkpoints, plugin manager, Chrome integration, MCP setup, IDE MCP server internals, third-party providers
- [JetBrains IDEs](references/claude-code-jetbrains.md) — Plugin installation, diff viewer, selection context, WSL2 and remote development configuration
- [Use Claude Code with Chrome](references/claude-code-chrome.md) — Setup, capabilities, example workflows, troubleshooting native messaging host
- [Computer Use from the CLI](references/claude-code-computer-use.md) — Enabling computer use, per-session app approvals, safety model, example workflows

## Sources

- Desktop Application: https://code.claude.com/docs/en/desktop.md
- Get Started with the Desktop App: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Computer Use from the CLI: https://code.claude.com/docs/en/computer-use.md
