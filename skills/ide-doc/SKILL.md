---
name: ide-doc
description: Complete official documentation for Claude Code IDE and desktop integrations — desktop app (macOS/Windows), VS Code extension, JetBrains plugin, Chrome browser integration, and computer use from the CLI. Use when working with the desktop Code tab, VS Code/JetBrains setup, browser automation, computer use, SSH sessions, permission modes, preview servers, worktrees, Dispatch, or enterprise desktop configuration.
user-invocable: false
---

# IDE and Desktop Integration Documentation

This skill provides the complete official documentation for Claude Code IDE and desktop surface integrations.

## Quick Reference

### Surfaces at a glance

| Surface | Platform | How to open |
| :--- | :--- | :--- |
| **Desktop app — Code tab** | macOS, Windows | Download from claude.ai/download; click Code tab |
| **VS Code extension** | Any (VS Code 1.98+) | Install `anthropic.claude-code` from Marketplace |
| **JetBrains plugin** | IntelliJ, PyCharm, WebStorm, etc. | Install from JetBrains Marketplace |
| **Chrome integration** | Chrome, Edge (beta) | `--chrome` flag or `/chrome`; requires Claude in Chrome extension |
| **Computer use (CLI)** | macOS only | Enable `computer-use` MCP server via `/mcp` |
| **Computer use (Desktop)** | macOS and Windows | Toggle in Settings → General |

---

### Desktop app: permission modes

| Mode | Settings key | Behavior |
| :--- | :--- | :--- |
| **Ask permissions** | `default` | Asks before file edits and commands |
| **Auto accept edits** | `acceptEdits` | Auto-accepts file edits; still asks for other commands |
| **Plan mode** | `plan` | Reads and proposes; no source edits |
| **Auto** | `auto` | Executes with background safety checks (research preview; requires Opus 4.6+ or Sonnet 4.6) |
| **Bypass permissions** | `bypassPermissions` | No prompts except forced ask rules; use only in sandboxed VMs |

### Desktop app: keyboard shortcuts (macOS — use Ctrl in place of Cmd on Windows)

| Shortcut | Action |
| :--- | :--- |
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

### Desktop app: transcript view modes

| Mode | What it shows |
| :--- | :--- |
| **Normal** | Tool calls collapsed; full text responses |
| **Verbose** | Every tool call, file read, and intermediate step |
| **Summary** | Only Claude's final responses and changed files |

### Desktop app: environment options

| Environment | Where it runs | Notes |
| :--- | :--- | :--- |
| **Local** | Your machine | Full file access; terminal available |
| **Remote** | Anthropic cloud | Continues after closing app; multi-repo support |
| **SSH** | Remote machine you manage | Installs CLI on first connect; Linux or macOS required |

### Desktop app: `.claude/launch.json` configuration fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (e.g., `npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments to `runtimeExecutable` (e.g., `["run", "dev"]`) |
| `port` | number | Port the server listens on (default: 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional env vars as key-value pairs (no secrets) |
| `autoPort` | boolean | `true` = find free port; `false` = error on conflict; omit = ask |
| `program` | string | Script to run directly with `node` |
| `args` | string[] | Arguments to `program` (only when `program` is set) |
| `autoVerify` | boolean | Top-level key; `false` to disable auto-verification after edits |

Use `runtimeExecutable` + `runtimeArgs` for package manager commands; use `program` for running a Node.js script directly with `node`.

### Desktop app: managed settings keys

| Key | Description |
| :--- | :--- |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to prevent bypass permissions mode |
| `disableAutoMode` | Set to `"disable"` to remove Auto from the mode selector |
| `autoMode` | Customize auto mode classifier trust/block rules |
| `sshConfigs` | Pre-configure SSH connections for users |
| `sshHostAllowlist` | Restrict SSH to approved host patterns; empty array disables SSH |
| `managedMcpServers` | Push MCP configs to all users (third-party Desktop deployments only) |

### Desktop app: CLI flag equivalents

| CLI flag | Desktop equivalent |
| :--- | :--- |
| `--model` | Model dropdown next to send button |
| `--resume`, `--continue` | Click a session in the sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (enable in Settings → Claude Code) |
| `--add-dir` | Add repos with **+** button in cloud sessions |
| `--verbose` | Verbose view mode in Transcript view dropdown |
| `--print`, `--output-format` | Not available (Desktop is interactive only) |

---

### VS Code extension: key settings

| Setting | Default | Description |
| :--- | :--- | :--- |
| `useTerminal` | `false` | Launch in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | Default mode: `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` (right) or `panel` (new tab) |
| `autosave` | `true` | Auto-save files before Claude reads or writes them |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter to send |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N for new conversation |
| `enableReopenClosedSessionShortcut` | `true` | Cmd/Ctrl+Shift+T reopens last closed Claude tab |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party provider setups) |
| `allowDangerouslySkipPermissions` | `false` | Adds Bypass permissions to mode selector |

### VS Code extension: shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Cmd/Ctrl Esc` | Toggle focus between editor and Claude |
| `Cmd/Ctrl Shift Esc` | Open new conversation as editor tab |
| `Option/Alt K` | Insert @-mention reference for current selection |
| `Cmd/Ctrl Shift T` | Reopen last closed Claude session tab |
| `Cmd/Ctrl N` | New conversation (requires `enableNewConversationShortcut: true`) |

### VS Code extension: built-in IDE MCP server tools

| Tool name | What it does | Writes? |
| :--- | :--- | :--- |
| `mcp__ide__getDiagnostics` | Returns language-server diagnostics (VS Code Problems panel) | No |
| `mcp__ide__executeCode` | Runs Python in the active Jupyter notebook's kernel (always prompts) | Yes |

The IDE MCP server is named `ide` and is hidden from `/mcp` — no configuration needed. If using a `PreToolUse` allowlist hook, include these tool names.

### VS Code extension: URI handler

Open a new Claude Code tab from external tooling via `vscode://anthropic.claude-code/open`.

| Parameter | Description |
| :--- | :--- |
| `prompt` | URL-encoded text to pre-fill in the prompt box |
| `session` | Session ID to resume instead of starting new |

---

### JetBrains plugin: key shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Cmd Esc` (Mac) / `Ctrl Esc` (Win/Linux) | Open Claude Code from editor |
| `Cmd Option K` (Mac) / `Alt Ctrl K` (Win/Linux) | Insert file reference (e.g., `@src/auth.ts#L1-99`) |

### JetBrains plugin: general settings (Settings → Tools → Claude Code)

| Setting | Notes |
| :--- | :--- |
| **Claude command** | Custom path (e.g., `/usr/local/bin/claude`); for WSL: `wsl -d Ubuntu -- bash -lic "claude"` |
| **Enable automatic updates** | Auto-install plugin updates on restart |
| **Enable Option+Enter for multi-line** | macOS only; insert newlines in prompts |

For remote development, install the plugin on the **remote host** (Settings → Plugin (Host)), not the local client.

---

### Chrome integration: capabilities

| Task | Example prompt |
| :--- | :--- |
| Live debugging | Read console errors; fix code that caused them |
| Design verification | Build UI from mock; open in browser to verify |
| Web app testing | Test form validation; verify user flows |
| Data extraction | Pull structured data from pages; save as CSV |
| Task automation | Automate form filling, data entry, multi-site workflows |
| Session recording | Record browser interactions as GIFs |

**CLI**: start with `claude --chrome` or enable in-session with `/chrome`. Use `@browser <task>` in VS Code.

**Limitations**: beta; Chrome and Edge only (not Brave, Arc, or WSL).

---

### Computer use: tool selection order

Claude always tries the most precise tool first:
1. MCP server for the service (most precise)
2. Bash (shell commands)
3. Claude in Chrome (browser tasks)
4. Computer use (everything else — slowest, broadest)

### Computer use: app permission tiers (both CLI and Desktop)

| Tier | What Claude can do | Applies to |
| :--- | :--- | :--- |
| **View only** | See app in screenshots | Browsers, trading platforms |
| **Click only** | Click and scroll; no typing or keyboard shortcuts | Terminals, IDEs |
| **Full control** | Click, type, drag, use keyboard shortcuts | Everything else |

### Computer use: CLI vs Desktop differences

| Feature | Desktop | CLI |
| :--- | :--- | :--- |
| Platforms | macOS and Windows | macOS only |
| Enable | Toggle in Settings → General | Enable `computer-use` server via `/mcp` |
| Denied apps list | Configurable in Settings | Not available |
| Auto-unhide windows | Optional toggle | Always on |
| Dispatch integration | Dispatch-spawned sessions can use it | Not applicable |

**CLI requirements**: Claude Code v2.1.85+, Pro or Max plan, interactive session (not `-p` flag), authenticated via claude.ai (not third-party providers).

---

### Worktrees (parallel sessions)

Sessions in the Desktop app use Git worktrees for isolation. Stored at `<project-root>/.claude/worktrees/` by default (configurable in Settings → Claude Code → Worktree location). To include gitignored files (e.g., `.env`) in new worktrees, create a `.worktreeinclude` file at the project root.

### Side chat

Press `Cmd+;` (macOS) / `Ctrl+;` (Windows) or type `/btw` to open a side chat that uses session context without adding to the main conversation thread.

### Continue in another surface (Desktop)

From the VS Code icon in the session toolbar:
- **Claude Code on the Web**: pushes branch, generates summary, creates cloud session with full context. Requires a clean working tree.
- **Your IDE**: opens project in a supported IDE at the current working directory.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Desktop application](references/claude-code-desktop.md) — Complete reference for the Code tab: sessions, permission modes, diff view, PR monitoring, app preview, pane layout, SSH, computer use, enterprise configuration, and CLI comparison
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — Installation walkthrough and first-session guide for macOS and Windows
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — Extension install, prompting, @-mentions, checkpoints, MCP setup, plugin manager, URI handler, third-party providers, and the built-in IDE MCP server
- [JetBrains IDEs](references/claude-code-jetbrains.md) — Plugin install, diff viewing, selection context, WSL/remote development configuration
- [Use Claude Code with Chrome (beta)](references/claude-code-chrome.md) — Browser automation setup, example workflows, permissions, and troubleshooting
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — CLI computer use setup, app approval flow, safety guardrails, example workflows

## Sources

- Desktop application: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome (beta): https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
