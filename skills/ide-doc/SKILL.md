---
name: ide-doc
description: Complete official documentation for Claude Code IDE and desktop integrations — Claude Code Desktop (macOS/Windows), VS Code extension, JetBrains plugin, Claude in Chrome browser extension, and computer use (CLI and Desktop).
user-invocable: false
---

# IDE and Desktop Integration Documentation

This skill provides the complete official documentation for Claude Code integrations with desktop apps, IDEs, browsers, and computer use.

## Quick Reference

### Claude Code Desktop — Overview

Available on macOS and Windows (not Linux — use the CLI instead). Requires a Pro, Max, Team, or Enterprise subscription.

**Three tabs:**

| Tab | Purpose |
| :--- | :--- |
| Chat | General conversation (no file access) |
| Cowork | Autonomous background agent in a cloud VM |
| Code | Interactive coding assistant with file access |

**Session environments:**

| Environment | Behavior |
| :--- | :--- |
| Local | Runs on your machine with direct file access |
| Remote | Runs on Anthropic's cloud; continues when app is closed |
| SSH | Runs on a remote machine you manage over SSH |

### Desktop — Permission Modes

| Mode | Settings key | Behavior |
| :--- | :--- | :--- |
| Ask permissions | `default` | Asks before editing files or running commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits and safe FS commands; still asks before other terminal commands |
| Plan mode | `plan` | Reads and explores; proposes plan without editing source code |
| Auto | `auto` | Executes all actions with background safety checks; research preview (Max/Team/Enterprise/API plans, specific models required) |
| Bypass permissions | `bypassPermissions` | No permission prompts; equivalent to `--dangerously-skip-permissions`; must be enabled in Settings |

Auto mode is not available on Pro plans or third-party providers. On Team/Enterprise/API it requires Claude Sonnet 4.6, Opus 4.6, or Opus 4.7. On Max it requires Opus 4.7.

### Desktop — Keyboard Shortcuts

| Shortcut (macOS) | Action |
| :--- | :--- |
| `Cmd+N` | New session |
| `Cmd+W` | Close session |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next/previous session |
| `Esc` | Stop Claude's response |
| `Cmd+Shift+D` | Toggle diff pane |
| `Cmd+Shift+P` | Toggle preview pane |
| `Ctrl+`` ` `` ` | Toggle terminal pane |
| `Cmd+;` | Open side chat |
| `Ctrl+O` | Cycle view modes |
| `Cmd+Shift+M` | Permission mode menu |
| `Cmd+Shift+I` | Model menu |

Use `Ctrl` instead of `Cmd` on Windows for most shortcuts.

### Desktop — View Modes

| Mode | Shows |
| :--- | :--- |
| Normal | Tool calls collapsed into summaries, full text responses |
| Verbose | Every tool call, file read, and intermediate step |
| Summary | Only final responses and changes made |

### Desktop — Preview Server Config (`.claude/launch.json`)

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

**Configuration fields:**

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (e.g. `npm`, `yarn`) |
| `runtimeArgs` | string[] | Arguments to `runtimeExecutable` |
| `port` | number | Port the server listens on (default: 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables |
| `autoPort` | boolean | `true` = find free port; `false` = fail if taken |
| `program` | string | Node.js script to run directly |
| `args` | string[] | Arguments to `program` |

Use `runtimeExecutable`+`runtimeArgs` for package manager commands. Use `program` for standalone Node.js scripts.

### Desktop — SSH Connection Config

Add `sshConfigs` to managed settings to pre-configure connections for a team:

```json
{
  "sshConfigs": [
    {
      "id": "shared-dev-vm",
      "name": "Shared Dev VM",
      "sshHost": "user@dev.example.com",
      "sshPort": 22,
      "sshIdentityFile": "~/.ssh/id_ed25519",
      "startDirectory": "~/projects"
    }
  ]
}
```

Required fields: `id`, `name`, `sshHost`. Optional: `sshPort`, `sshIdentityFile`, `startDirectory`.

### Desktop — Managed Settings Keys

| Key | Description |
| :--- | :--- |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to block Bypass permissions mode |
| `disableAutoMode` | Set to `"disable"` to remove Auto mode from the selector |
| `autoMode` | Customize classifier rules for auto mode across your org |
| `sshConfigs` | Pre-configure SSH connections for all users |

### Desktop — CLI Flag Equivalents

| CLI Flag | Desktop Equivalent |
| :--- | :--- |
| `--model` | Model dropdown next to the send button |
| `--resume`, `--continue` | Click a session in the sidebar |
| `--permission-mode` | Mode selector next to the send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (enable in Settings) |
| `--add-dir` | Add multiple repos with `+` in remote sessions |
| `--verbose` | Verbose view mode in Transcript view dropdown |
| `--print`, `--output-format` | Not available (Desktop is interactive only) |

### Desktop — Worktrees

Each local session gets an isolated Git worktree. Stored at `<project-root>/.claude/worktrees/` by default. Configurable in Settings → Claude Code.

To copy gitignored files (e.g. `.env`) into new worktrees, create a `.worktreeinclude` file in your project root.

Auto-archive sessions when their PR merges: enable **Auto-archive after PR merge or close** in Settings → Claude Code.

### VS Code Extension — Installation

- **VS Code**: press `Cmd+Shift+X` (Mac) / `Ctrl+Shift+X` (Windows/Linux), search "Claude Code", click Install
- **Cursor**: install from `cursor:extension/anthropic.claude-code`
- **Other forks**: search in Extensions view or install from [Open VSX registry](https://open-vsx.org/extension/Anthropic/claude-code)
- Requires VS Code 1.98.0 or higher

### VS Code Extension — Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | Open new conversation as editor tab |
| `Option+K` / `Alt+K` | Insert @-mention reference for current selection |
| `Cmd+N` / `Ctrl+N` | New conversation (requires `enableNewConversationShortcut: true`) |

### VS Code Extension Settings

| Setting | Default | Description |
| :--- | :--- | :--- |
| `useTerminal` | `false` | Launch Claude in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | Default permission mode for new conversations |
| `preferredLocation` | `panel` | Where Claude opens: `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads or writes them |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter to send |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N to start a new conversation |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `usePythonEnvironment` | `true` | Activate workspace Python environment |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto and Bypass permissions to the mode selector |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party provider setups) |

### VS Code Extension — Built-in IDE MCP Server

The extension runs a local MCP server named `ide` (hidden from `/mcp`) that the CLI connects to automatically. It binds to `127.0.0.1` on a random port with a per-activation auth token stored in `~/.claude/ide/` (0600 permissions).

Two tools visible to the model:

| Tool | What it does | Writes? |
| :--- | :--- | :--- |
| `mcp__ide__getDiagnostics` | Returns language-server diagnostics (VS Code Problems panel) | No |
| `mcp__ide__executeCode` | Runs Python code in the active Jupyter notebook kernel (confirms with Quick Pick before running) | Yes |

### VS Code Extension — URI Handler

Open a new Claude Code tab from external tooling:

```
vscode://anthropic.claude-code/open
```

Optional query parameters: `prompt` (URL-encoded pre-fill text) and `session` (session ID to resume).

### JetBrains — Supported IDEs

IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand.

**Install:** [Claude Code plugin](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-) from JetBrains Marketplace. Restart IDE after installing.

### JetBrains — Key Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Cmd+Esc` (Mac) / `Ctrl+Esc` (Win/Linux) | Open Claude Code from editor |
| `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Win/Linux) | Insert file reference (e.g. `@src/auth.ts#L1-99`) |

### JetBrains — Usage

- Run `claude` from the IDE's integrated terminal for full integration
- Run `/ide` from an external terminal to connect to the JetBrains IDE
- Configure diff tool: `/config` → set diff tool to `auto` (show in IDE) or `terminal`

### JetBrains — WSL2 Fix

If you see "No available IDEs detected" with WSL2, WSL2's NAT networking blocks the connection. Fix: create a Windows Firewall inbound rule allowing TCP from the WSL2 subnet.

Alternative: add `networkingMode=mirrored` to `.wslconfig` (requires Windows 11 22H2+).

### Claude in Chrome — Prerequisites

- Google Chrome or Microsoft Edge (not Brave, Arc, or other Chromium browsers; not WSL)
- [Claude in Chrome extension](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) v1.0.36+
- Claude Code v2.0.73+
- Direct Anthropic plan (Pro, Max, Team, or Enterprise) — not available via Bedrock/Vertex/Foundry

### Claude in Chrome — Usage

```bash
claude --chrome        # Start with Chrome integration
```

Or run `/chrome` inside an existing session to enable/connect/manage permissions.

In VS Code: type `@browser` in the prompt box followed by your task.

### Claude in Chrome — Capabilities

Live debugging (console errors, DOM), design verification, web app testing, authenticated web app interaction (Google Docs, Gmail, Notion, etc.), data extraction, task automation, session recording as GIF.

### Computer Use (CLI) — Requirements

- macOS only (for CLI; Desktop supports macOS and Windows)
- Pro or Max plan
- Claude Code v2.1.85+
- Interactive session (not available with `-p` flag)
- Not available via third-party providers (Bedrock/Vertex/Foundry)

### Computer Use — Enable in CLI

1. In an interactive session, run `/mcp`
2. Select `computer-use` and choose **Enable** (persists per project)
3. Grant macOS Accessibility and Screen Recording permissions when prompted

### Computer Use — App Permission Tiers

| Tier | What Claude can do | Applies to |
| :--- | :--- | :--- |
| View only | See app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, but not type | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

### Computer Use — CLI vs Desktop Differences

| Feature | Desktop | CLI |
| :--- | :--- | :--- |
| Platforms | macOS and Windows | macOS only |
| Enable | Toggle in Settings > General | Enable `computer-use` in `/mcp` |
| Denied apps list | Configurable in Settings | Not yet available |
| Auto-unhide toggle | Optional | Always on |

### Computer Use — Safety

- Per-app approval required each session (30-minute expiry for Dispatch-spawned sessions)
- Terminal excluded from screenshots (Claude cannot see its own output)
- `Esc` key aborts computer use from anywhere and releases the lock
- Only one session can control the machine at a time (machine-wide lock)
- Apps with broad reach (terminals, Finder, System Settings) show extra warnings before approval

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) — sessions, permission modes, diff view, preview servers, computer use, parallel sessions, SSH, enterprise configuration, and CLI comparison
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — installation walkthrough and first session guide for macOS and Windows
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — extension installation, prompt box, @-mentions, plugin management, MCP, git workflows, third-party providers, and the built-in IDE MCP server
- [JetBrains IDEs](references/claude-code-jetbrains.md) — plugin installation, usage, configuration, remote development, WSL2 setup, and troubleshooting
- [Use Claude Code with Chrome (beta)](references/claude-code-chrome.md) — capabilities, prerequisites, CLI and VS Code usage, example workflows, and troubleshooting
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — enabling computer use, per-app approvals, safety guardrails, example workflows, and CLI vs Desktop differences

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome (beta): https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
