---
name: ide-doc
description: Complete documentation for using Claude Code with IDEs and graphical surfaces — the Claude Desktop app (Code tab), the VS Code / Cursor extension, the JetBrains plugin, the Claude in Chrome browser extension, and computer-use controls. Covers installation, permission modes, diff review, preview servers, SSH and remote sessions, parallel worktree sessions, PR monitoring, plugin management in the GUI, keyboard shortcuts, CLI flag equivalents, and troubleshooting for each surface.
user-invocable: false
---

# IDE and Graphical Surfaces Documentation

This skill provides the complete official documentation for using Claude Code through graphical surfaces: the Claude Desktop app, VS Code / Cursor extension, JetBrains plugin, Chrome browser extension, and the computer-use screen-control capability.

## Quick Reference

### Surfaces at a glance

| Surface | Platforms | Install | Main entry point |
| --- | --- | --- | --- |
| **Desktop app** (Code tab) | macOS, Windows (x64, ARM64). No Linux. | Download from claude.com/download | Click **Code** tab |
| **VS Code extension** | VS Code 1.98.0+, Cursor | `vscode:extension/anthropic.claude-code` or Extensions view | Spark icon in Editor Toolbar, Activity Bar, or Status Bar |
| **JetBrains plugin** | IntelliJ, PyCharm, WebStorm, PhpStorm, GoLand, Android Studio | JetBrains Marketplace | Run `claude` in integrated terminal; `Cmd+Esc` / `Ctrl+Esc` |
| **Chrome (beta)** | Chrome, Edge (not Brave, Arc, WSL) | Chrome Web Store extension + Claude Code 2.0.73+ | `claude --chrome` or `/chrome` |
| **Computer use (CLI)** | macOS only, Pro/Max, v2.1.85+ | Enable `computer-use` server in `/mcp` | Interactive sessions only |
| **Computer use (Desktop)** | macOS and Windows, Pro/Max | Settings > General > Computer use | Requires Accessibility + Screen Recording (macOS) |

### Desktop app: permission modes

| Mode | Settings key | Behavior |
| --- | --- | --- |
| Ask permissions | `default` | Prompt before every edit / command. Recommended default. |
| Auto accept edits | `acceptEdits` | Auto-accept file edits and common fs commands; still prompts for other terminal commands. |
| Plan mode | `plan` | Explore only, propose a plan without editing source. |
| Auto | `auto` | Background safety classifier, fewer prompts. Research preview; Team/Enterprise/API plans; Sonnet 4.6 or Opus 4.6. |
| Bypass permissions | `bypassPermissions` | No prompts (equivalent to `--dangerously-skip-permissions`). Sandboxed environments only. Enterprise admins can disable. |

Remote sessions support **Auto accept edits** and **Plan mode** only. The `dontAsk` mode is CLI-only.

### Desktop environments

| Environment | Runs on | Notes |
| --- | --- | --- |
| **Local** | Your machine | Git required. Windows users must install Git for Windows. |
| **Remote** | Anthropic cloud | Continues when app closed. Supports multi-repo. Shares infra with Claude Code on the web. |
| **SSH** | Remote machine over SSH | Claude Code must be installed on the remote host. Supports permission modes, connectors, plugins, MCP. |

### Desktop: CLI flag equivalents

| CLI flag | Desktop equivalent |
| --- | --- |
| `--model sonnet` | Model dropdown (locked after session starts) |
| `--resume`, `--continue` | Click a session in the sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (enable in Settings) |
| `--add-dir` | **+** button next to repo pill (remote sessions) |
| `--allowedTools`, `--disallowedTools` | Not available |
| `--verbose` | Not available (check Console.app / Event Viewer) |
| `--print`, `--output-format` | Not available (Desktop is interactive only) |
| `ANTHROPIC_MODEL` env var | Model dropdown |
| `MAX_THINKING_TOKENS` env var | Local environment editor |

### Preview server config (`.claude/launch.json`)

| Field | Type | Description |
| --- | --- | --- |
| `name` | string | Unique identifier for the server |
| `runtimeExecutable` | string | Command (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Args to `runtimeExecutable`, e.g. `["run", "dev"]` |
| `port` | number | Listening port (default 3000) |
| `cwd` | string | Working dir relative to project root; supports `${workspaceFolder}` |
| `env` | object | Extra env vars. Never put secrets here — use the local environment editor instead. |
| `autoPort` | boolean | `true` = pick free port, `false` = fail on conflict, unset = ask |
| `program` | string | Standalone script to run with `node` |
| `args` | string[] | Args to `program` (only when `program` is set) |

Top-level `autoVerify` (default `true`) enables automatic post-edit verification via preview.

### Desktop: managed-settings keys

| Key | Description |
| --- | --- |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to block Bypass permissions mode. |
| `disableAutoMode` | Set to `"disable"` to block Auto mode. Also under `permissions`. |
| `autoMode` | Configure the auto-mode classifier (managed/user/local settings only; not `.claude/settings.json`). |

Remote managed settings (admin console) apply to CLI and IDE sessions only. For Desktop, use admin console controls (Code in desktop, Code in web, Remote Control, Disable Bypass).

### VS Code extension settings (selected)

| Setting | Default | Purpose |
| --- | --- | --- |
| `useTerminal` | `false` | Launch CLI-style interface instead of graphical panel |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter to send |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N for new conversation |
| `hideOnboarding` | `false` | Hide onboarding checklist |
| `respectGitIgnore` | `true` | Exclude gitignored files from searches |
| `usePythonEnvironment` | `true` | Activate workspace Python env (requires Python extension) |
| `environmentVariables` | `[]` | Per-extension env vars |
| `disableLoginPrompt` | `false` | Skip auth prompts for third-party providers |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto and Bypass modes to the mode selector |
| `claudeProcessWrapper` | — | Executable path to launch the Claude process |

Tip: Add `"$schema": "https://json.schemastore.org/claude-code-settings.json"` to `~/.claude/settings.json` for inline validation.

### VS Code: keyboard shortcuts

| Command | Shortcut | Description |
| --- | --- | --- |
| Focus Input | `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| Open in New Tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | New conversation as editor tab |
| New Conversation | `Cmd+N` / `Ctrl+N` | Requires Claude focus + `enableNewConversationShortcut` |
| Insert @-Mention Reference | `Option+K` / `Alt+K` | Insert `@file#L1-99` from current selection (editor focus) |
| Multi-line input | `Shift+Enter` | Add a newline without sending |

### VS Code URI handler

The extension registers `vscode://anthropic.claude-code/open` with optional query params:

| Param | Description |
| --- | --- |
| `prompt` | URL-encoded text to pre-fill in the prompt box (not auto-submitted) |
| `session` | Session ID to resume (must belong to the currently open workspace) |

### VS Code vs CLI feature matrix

| Feature | CLI | VS Code extension |
| --- | --- | --- |
| Commands and skills | All | Subset (type `/` to see) |
| MCP server config | Yes | Partial (add via CLI; manage with `/mcp`) |
| Checkpoints | Yes | Yes |
| Bash shortcut (leading exclamation mark) | Yes | No |
| Tab completion | Yes | No |

### VS Code built-in `ide` MCP server

Local-only, `127.0.0.1`, random high port, fresh per-activation auth token in `~/.claude/ide/` (0600 in 0700 dir). Two tools visible to the model:

| Tool | Purpose | Writes? |
| --- | --- | --- |
| `mcp__ide__getDiagnostics` | Return VS Code Problems-panel diagnostics (optionally scoped to one file) | No |
| `mcp__ide__executeCode` | Execute Python in the active Jupyter notebook's kernel, requires native Quick Pick confirmation | Yes |

`mcp__ide__executeCode` refuses when there's no active notebook, the Jupyter extension (`ms-toolsai.jupyter`) is missing, or the kernel isn't Python. The Quick Pick is separate from `PreToolUse` hooks.

### JetBrains features and shortcuts

| Action | Shortcut |
| --- | --- |
| Open Claude Code | `Cmd+Esc` / `Ctrl+Esc` |
| Insert file reference (`@File#L1-99`) | `Cmd+Option+K` / `Alt+Ctrl+K` |

Plugin settings live in **Settings > Tools > Claude Code (Beta)**: Claude command path, notification suppression, Option+Enter multi-line (macOS), automatic updates. For WSL use `wsl -d Ubuntu -- bash -lic "claude"`. Diff tool should be set to `auto` via `/config`. For JetBrains Remote Development, install the plugin on the **remote host**. To make `Esc` interrupt Claude, uncheck "Move focus to the editor with Escape" in **Settings > Tools > Terminal**.

### Chrome / Edge integration

- Enable once with `claude --chrome` or `/chrome` inside a session; "Enabled by default" avoids the flag (at the cost of extra context usage).
- Use `@browser` in the VS Code extension prompt box.
- Site permissions inherit from the Chrome extension.
- Run `/mcp` and select `claude-in-chrome` to list browser tools.
- Not supported: Brave, Arc, other Chromium forks, WSL, third-party providers (Bedrock / Vertex / Foundry).

Common errors:

| Error | Cause | Fix |
| --- | --- | --- |
| "Browser extension is not connected" | Native messaging host can't reach the extension | Restart Chrome and Claude Code; run `/chrome` |
| "Extension not detected" | Extension not installed or disabled | Enable in `chrome://extensions` |
| "No tab available" | Acted before a tab was ready | Ask Claude to create a new tab and retry |
| "Receiving end does not exist" | Extension service worker went idle | `/chrome` > "Reconnect extension" |

### Computer use: app tier permissions

| Tier | Claude can | Applies to |
| --- | --- | --- |
| View only | See in screenshots | Browsers, trading platforms |
| Click only | Click and scroll (no typing, no shortcuts) | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

Claude picks the most precise tool first (connector > Bash > Chrome > computer use). Screen control is reserved for native apps, simulators, hardware panels, and tools without an API.

Computer use in the CLI holds a machine-wide lock (one session at a time). Press `Esc` anywhere to abort. Terminal window is excluded from screenshots. Screenshots are downscaled automatically (Retina 3456x2234 to ~1372x887).

### Computer use: CLI vs Desktop

| Feature | Desktop | CLI |
| --- | --- | --- |
| Platforms | macOS and Windows | macOS only |
| Enable | Toggle in Settings > General | Enable `computer-use` in `/mcp` |
| Denied apps list | Configurable | Not yet available |
| Auto-unhide toggle | Optional | Always on |
| Dispatch integration | Yes | Not applicable |

## Full Documentation

For the complete official documentation, see the reference files:

- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — install, sign in, start your first Code session
- [Use Claude Code Desktop](references/claude-code-desktop.md) — permission modes, parallel sessions, diff view, preview servers, PR monitoring, connectors, SSH, environment config, enterprise management, CLI comparison, troubleshooting
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — extension install, prompt box, checkpoints, plugin manager, git workflows, third-party providers, `ide` MCP server, shortcuts, URI handler, troubleshooting
- [JetBrains IDEs](references/claude-code-jetbrains.md) — plugin install, supported IDEs, diff/diagnostics integration, WSL and remote development, ESC key configuration, troubleshooting
- [Use Claude Code with Chrome (beta)](references/claude-code-chrome.md) — browser automation capabilities, prerequisites, setup via `--chrome` / `/chrome`, example workflows, native messaging host paths, error reference
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — enable the `computer-use` MCP server, macOS permissions, per-session app approval, safety boundaries, example workflows, troubleshooting

## Sources

- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome (beta): https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
