---
name: ide-doc
user-invocable: false
---

# IDE and Desktop Integration Documentation

This skill provides the complete official documentation for Claude Code IDE and desktop integrations: the desktop app, VS Code extension, JetBrains plugin, Chrome browser integration, and computer use from the CLI.

## Quick Reference

### Integration Surface Overview

| Surface | Platforms | How to open | Requires |
|:--------|:----------|:------------|:---------|
| **Desktop app** | macOS, Windows (not Linux) | Download from claude.ai/download, click Code tab | Pro/Max/Team/Enterprise |
| **VS Code extension** | VS Code, Cursor, VS Code forks | Install `anthropic.claude-code`, click Spark icon | VS Code 1.98.0+ |
| **JetBrains plugin** | IntelliJ, PyCharm, WebStorm, GoLand, etc. | Install from JetBrains Marketplace | Plugin + `claude` CLI |
| **Chrome integration** | Chrome, Edge (not Brave/Arc/WSL) | `claude --chrome` or `/chrome` in session | Claude in Chrome ext v1.0.36+, Claude Code v2.0.73+ |
| **Computer use (CLI)** | macOS only | Enable `computer-use` in `/mcp` | Pro/Max plan, Claude Code v2.1.85+ |

### Desktop App: Permission Modes

| Mode | Settings key | Behavior |
|:-----|:------------|:---------|
| **Ask permissions** | `default` | Asks before every edit or command |
| **Auto accept edits** | `acceptEdits` | Auto-accepts file edits and basic filesystem commands; still asks for other commands |
| **Plan mode** | `plan` | Reads and explores, proposes plan, does not edit source code |
| **Auto** | `auto` | Executes with background safety checks; requires Opus 4.6+/Sonnet 4.6; research preview |
| **Bypass permissions** | `bypassPermissions` | No prompts; equivalent to `--dangerously-skip-permissions`; enable in Settings |

### Desktop App: Keyboard Shortcuts

| Shortcut (macOS) | Shortcut (Windows) | Action |
|:-----------------|:-------------------|:-------|
| `Cmd+N` | `Ctrl+N` | New session |
| `Cmd+W` | `Ctrl+W` | Close session |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | same | Next/previous session |
| `Esc` | `Esc` | Stop Claude's response |
| `Cmd+Shift+D` | `Ctrl+Shift+D` | Toggle diff pane |
| `Cmd+Shift+P` | `Ctrl+Shift+P` | Toggle preview pane |
| `Ctrl+` `` ` `` | `Ctrl+` `` ` `` | Toggle terminal pane |
| `Cmd+\` | `Ctrl+\` | Close focused pane |
| `Cmd+;` | `Ctrl+;` | Open side chat |
| `Ctrl+O` | `Ctrl+O` | Cycle view modes (Normal/Verbose/Summary) |
| `Cmd+/` | `Ctrl+/` | Show all shortcuts |

### Desktop App: View Modes

| Mode | What it shows |
|:-----|:-------------|
| **Normal** | Tool calls collapsed into summaries, full text responses |
| **Verbose** | Every tool call, file read, and intermediate step |
| **Summary** | Only final responses and changes made |

### Desktop App: `.claude/launch.json` Fields

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique identifier for this server configuration |
| `runtimeExecutable` | string | Command to run (e.g. `npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments for `runtimeExecutable` (e.g. `["run", "dev"]`) |
| `port` | number | Port the server listens on (default: 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables (no secrets — file is committed) |
| `autoPort` | boolean | `true` = auto-pick free port; `false` = fail on conflict; omit = prompt once |
| `program` | string | Node.js script to run directly with `node` |
| `args` | string[] | Arguments for `program` (only when `program` is set) |
| `autoVerify` | boolean | Top-level field; `false` disables automatic screenshot verification after edits |

Use `runtimeExecutable` + `runtimeArgs` for package manager commands. Use `program` + `args` to run a Node.js script directly.

### Desktop App: SSH Config Fields (`sshConfigs`)

| Field | Required | Description |
|:------|:---------|:------------|
| `id` | Yes | Unique identifier |
| `name` | Yes | Display label in environment dropdown |
| `sshHost` | Yes | `user@hostname` or SSH config alias |
| `sshPort` | No | Defaults to 22 |
| `sshIdentityFile` | No | Path to private key; leave empty to use default |
| `startDirectory` | No | Initial working directory on remote machine |

### Desktop App: Enterprise Managed Settings Keys

| Key | Description |
|:----|:------------|
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to prevent bypass permissions mode |
| `disableAutoMode` | Set to `"disable"` to remove Auto from mode selector |
| `autoMode` | Customize auto mode classifier rules across the org |
| `sshConfigs` | Pre-configure SSH connections for all users |
| `sshHostAllowlist` | Restrict SSH sessions to approved hostnames (managed settings only) |
| `managedMcpServers` | Push MCP server configs to all users (third-party Desktop deployments only) |

### VS Code Extension Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `useTerminal` | `false` | Launch Claude in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | Starting permission mode: `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `preferredLocation` | `panel` | Where Claude opens: `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads or writes them |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter to send |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N to start a new conversation |
| `enableReopenClosedSessionShortcut` | `true` | Cmd/Ctrl+Shift+T reopens the last closed Claude session tab |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party provider setups) |
| `allowDangerouslySkipPermissions` | `false` | Adds Bypass permissions to mode selector; sandboxes only |

### VS Code Extension: Keyboard Shortcuts

| Shortcut (Mac) | Shortcut (Win/Linux) | Action |
|:---------------|:---------------------|:-------|
| `Cmd+Esc` | `Ctrl+Esc` | Toggle focus between editor and Claude panel |
| `Cmd+Shift+Esc` | `Ctrl+Shift+Esc` | Open new conversation in editor tab |
| `Cmd+Shift+T` | `Ctrl+Shift+T` | Reopen most recently closed Claude session tab |
| `Option+K` | `Alt+K` | Insert @-mention reference for current file + selection |

### VS Code Extension vs. CLI Feature Gaps

| Feature | CLI | VS Code Extension |
|:--------|:----|:-----------------|
| All commands and skills | Yes | Subset only (type `/` to see available) |
| MCP server config | Full | Partial (add via CLI; manage existing with `/mcp`) |
| Checkpoints | Yes | Yes |
| `!` bash shortcut | Yes | No |
| Tab completion | Yes | No |

### VS Code IDE MCP Server Tools (visible to model)

| Tool | What it does | Writes? |
|:-----|:------------|:--------|
| `mcp__ide__getDiagnostics` | Returns language-server diagnostics (Problems panel); optionally scoped to one file | No |
| `mcp__ide__executeCode` | Runs Python code in active Jupyter notebook kernel; always shows Quick Pick confirm first | Yes |

The IDE MCP server (`ide`) is hidden from `/mcp` — nothing to configure. The server binds to `127.0.0.1` on a random port with a fresh auth token each activation, stored in `~/.claude/ide/` with `0600` permissions.

### JetBrains Plugin: Key Features and Shortcuts

| Feature | Detail |
|:--------|:-------|
| Quick launch | `Cmd+Esc` (Mac) / `Ctrl+Esc` (Win/Linux) |
| File reference shortcut | `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Win/Linux) |
| Diff viewing | In IDE diff viewer instead of terminal |
| Selection context | Current selection/tab automatically shared; blocked by `Read` deny rules |
| Diagnostic sharing | Lint/syntax errors shared automatically |

Set diff tool via `/config` → set to `auto` (IDE diff) or `terminal`. For WSL users, set Claude command to `wsl -d Ubuntu -- bash -lic "claude"` in plugin settings.

### Chrome Integration

| Item | Detail |
|:-----|:-------|
| Enable in CLI | `claude --chrome` or run `/chrome` in session |
| Enable by default | Run `/chrome`, select "Enabled by default" |
| In VS Code | No flag needed; always available when Chrome extension is installed |
| Manage status | `/chrome` — check connection, reconnect, choose browser |
| Manage tool list | `/mcp` → select `claude-in-chrome` |

Chrome integration supports: live console debugging, design verification, web app testing, authenticated web app interaction, data extraction, form automation, session recording (GIF), and multi-site workflows. Claude opens new tabs and shares your browser's login state.

### Computer Use (CLI, macOS only)

| Item | Detail |
|:-----|:-------|
| Enable | `/mcp` → select `computer-use` → Enable |
| Stop at any time | Press `Esc` anywhere, or `Ctrl+C` in terminal |
| App approval | Per-session prompt; approvals last the session |
| Lock | Machine-wide; only one session at a time |
| Screenshots | Auto-downscaled before sending to model |

Computer use app permission tiers (fixed by category, cannot change):

| Tier | What Claude can do | Applies to |
|:-----|:------------------|:-----------|
| View only | See app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll; no typing or keyboard shortcuts | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

### Desktop vs. CLI: Computer Use Differences

| Feature | Desktop | CLI |
|:--------|:--------|:----|
| Platforms | macOS and Windows | macOS only |
| Enable | Settings > General toggle | Enable `computer-use` in `/mcp` |
| Denied apps list | Configurable in Settings | Not available |
| Dispatch integration | Dispatch-spawned sessions can use it | Not applicable |

### Desktop App: Environments

| Environment | Where Claude runs | Continues when app closed? |
|:------------|:-----------------|:--------------------------|
| Local | Your machine | No |
| Remote | Anthropic's cloud | Yes |
| SSH | Remote machine you manage | Yes (on remote host) |

Remote sessions support Auto accept edits and Plan mode only (not Ask permissions or Bypass).

### Desktop App: CLI Flag Equivalents

| CLI flag | Desktop equivalent |
|:---------|:------------------|
| `--model sonnet` | Model dropdown next to send button |
| `--resume`, `--continue` | Click a session in the sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (enable in Settings) |
| `--add-dir` | `+` button for additional repos in remote sessions |
| `--verbose` | Verbose view mode in Transcript view dropdown |
| `--print`, `--output-format` | Not available (Desktop is interactive only) |

### What's Not Available in Desktop

- Third-party providers (Bedrock, Foundry): use the CLI
- Linux: use the CLI
- Inline code autocomplete suggestions
- Agent teams (parallel Claude sessions messaging each other): use the CLI
- Terminal-dialog commands (`/permissions`, `/config`, `/agents`, `/doctor`): edit settings files directly or use the CLI

## Full Documentation

For the complete official documentation, see the reference files:

- [Desktop application](references/claude-code-desktop.md) — full Code tab reference: sessions, diff view, preview, pane layout, terminal, computer use, SSH, enterprise configuration, and CLI comparison
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — install, first session walkthrough, and quick tour of key features
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — extension install, prompt box, @-mentions, session history, plugin manager, IDE MCP server, settings reference, and CLI vs extension feature gaps
- [JetBrains IDEs](references/claude-code-jetbrains.md) — plugin install, features, configuration, WSL/remote development setup, and troubleshooting
- [Use Claude Code with Chrome](references/claude-code-chrome.md) — setup, capabilities, example workflows, troubleshooting, and native messaging host paths
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — enable computer use, per-session app approval, safety guardrails, example workflows, and CLI vs Desktop differences

## Sources

- Desktop application: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
