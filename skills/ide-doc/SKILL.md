---
name: ide-doc
description: Complete official documentation for Claude Code IDE and desktop integrations — VS Code extension, JetBrains plugin, Claude Desktop app (sessions, diff view, preview, computer use, enterprise), Chrome browser automation, and CLI computer use on macOS.
user-invocable: false
---

# IDE and Desktop Integration Documentation

This skill provides the complete official documentation for Claude Code IDE and desktop integrations, including VS Code, JetBrains, the Claude Desktop app, Chrome browser automation, and computer use.

## Quick Reference

### Integration surfaces at a glance

| Surface | Platforms | Install / Enable |
| :--- | :--- | :--- |
| VS Code extension | VS Code, Cursor | Extensions marketplace → "Claude Code" |
| JetBrains plugin | IntelliJ, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand | JetBrains marketplace → "Claude Code Beta" |
| Claude Desktop app | macOS, Windows (no Linux) | claude.ai/download |
| Chrome integration | Chrome, Edge (not Brave/Arc, not WSL) | Claude in Chrome extension ≥ 1.0.36 + `--chrome` flag or `/chrome` |
| Computer use (CLI) | macOS only (Pro/Max plans) | `/mcp` → enable `computer-use` server |

---

### VS Code extension

**Requirements:** VS Code 1.98.0+, Anthropic account.

**Key shortcuts:**

| Command | Shortcut |
| :--- | :--- |
| Toggle focus editor ↔ Claude | `Cmd+Esc` / `Ctrl+Esc` |
| Open new conversation tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` |
| Insert @-mention reference | `Option+K` / `Alt+K` |
| New conversation (requires `enableNewConversationShortcut: true`) | `Cmd+N` / `Ctrl+N` |

**Permission modes** (set `claudeCode.initialPermissionMode`):

| Mode | Key | Behavior |
| :--- | :--- | :--- |
| Default | `default` | Asks before each action |
| Plan | `plan` | Proposes plan, waits for approval |
| Accept Edits | `acceptEdits` | Auto-accepts edits, asks for commands |
| Bypass | `bypassPermissions` | No prompts (sandboxes only) |

**Extension settings** (VS Code settings → Extensions → Claude Code):

| Setting | Default | Description |
| :--- | :--- | :--- |
| `useTerminal` | `false` | Launch in terminal mode instead of panel |
| `initialPermissionMode` | `default` | Default permission mode |
| `preferredLocation` | `panel` | `sidebar` or `panel` |
| `autosave` | `true` | Auto-save before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter to send |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N for new session |
| `respectGitIgnore` | `true` | Exclude .gitignore from file searches |
| `usePythonEnvironment` | `true` | Activate workspace Python environment |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto and Bypass modes to selector |

**Built-in IDE MCP server** (named `ide`, hidden from `/mcp`):

| Tool | Writes? | What it does |
| :--- | :--- | :--- |
| `mcp__ide__getDiagnostics` | No | Returns VS Code language-server errors/warnings |
| `mcp__ide__executeCode` | Yes | Runs Python in active Jupyter notebook (always prompts first) |

Transport: `127.0.0.1` random high port, fresh auth token per activation, stored in `~/.claude/ide/` (mode `0600`/`0700`).

**Open VS Code tab from external tooling:**
```
vscode://anthropic.claude-code/open?prompt=<url-encoded-text>&session=<session-id>
```

**Reference terminal output in prompts:** use `@terminal:name` where `name` is the terminal's title.

**Resume remote sessions from claude.ai:** requires Claude.ai Subscription sign-in. In the Claude Code panel, click Session history → Remote tab → select a session to download and continue locally. Only sessions started from a GitHub repository appear.

**Checkpoints (rewind):** hover any message to reveal the rewind button. Options: Fork conversation from here, Rewind code to here, or Fork conversation and rewind code.

**CLI feature parity gaps** (CLI has, extension lacks):
- All slash commands (extension shows a subset)
- `!` bash shortcut
- Tab completion

---

### JetBrains plugin

**Supported IDEs:** IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand.

**Key shortcuts:**

| Action | Mac | Linux/Windows |
| :--- | :--- | :--- |
| Open Claude Code | `Cmd+Esc` | `Ctrl+Esc` |
| Insert file reference | `Cmd+Option+K` | `Alt+Ctrl+K` |

**Connect from external terminal:** run `/ide` inside a Claude Code session.

**Plugin settings** (Settings → Tools → Claude Code [Beta]):

| Setting | Notes |
| :--- | :--- |
| Claude command | Custom path, e.g. `/usr/local/bin/claude` or `npx @anthropic-ai/claude-code` |
| WSL command | `wsl -d Ubuntu -- bash -lic "claude"` |
| Enable automatic updates | Applied on restart |
| Enable Option+Enter multi-line | macOS only; disable if Option key conflicts |

**Diff tool config:** run `/config` inside `claude`, set diff tool to `auto` (IDE viewer) or `terminal`.

**Remote Development:** install plugin on the **remote host** (Settings → Plugin (Host)), not local client.

**ESC key fix** (if ESC doesn't interrupt Claude): Settings → Tools → Terminal → uncheck "Move focus to the editor with Escape" or delete the "Switch focus to Editor" keybinding.

**Security note:** with auto-edit enabled, Claude can modify IDE config files that the IDE may execute automatically. Use manual approval mode with untrusted prompts.

---

### Claude Desktop app (Code tab)

**Requirements:** macOS or Windows; Pro, Max, Team, or Enterprise plan. Windows requires Git for Windows.

**Session environments:**

| Environment | Where it runs | Notes |
| :--- | :--- | :--- |
| Local | Your machine | Full file access; terminal pane available |
| Remote | Anthropic cloud | Continues when app closed; supports multi-repo |
| SSH | Remote machine via SSH | Desktop installs Claude Code automatically |

**Permission modes:**

| Mode | Key | Behavior |
| :--- | :--- | :--- |
| Ask permissions | `default` | Asks before edits and commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits; asks for other commands |
| Plan mode | `plan` | Explores, proposes plan, no code changes |
| Auto | `auto` | Background safety checks; research preview on Max/Team/Enterprise/API |
| Bypass permissions | `bypassPermissions` | No prompts; sandboxed environments only |

**Auto mode availability:** Max plans require Opus 4.7. Team, Enterprise, and API plans require Sonnet 4.6, Opus 4.6, or Opus 4.7. Not available on Pro or third-party providers.

**Keyboard shortcuts** (macOS; use Ctrl in place of Cmd on Windows except where noted):

| Shortcut | Action |
| :--- | :--- |
| `Cmd+/` | Show all shortcuts |
| `Cmd+N` | New session |
| `Cmd+W` | Close session |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next / previous session |
| `Esc` | Stop Claude's response |
| `Cmd+Shift+D` | Toggle diff pane |
| `Cmd+Shift+P` | Toggle preview pane |
| `Cmd+Shift+S` | Select an element in preview |
| `Ctrl+\`` | Toggle terminal pane |
| `Cmd+\` | Close focused pane |
| `Cmd+;` | Open side chat |
| `Ctrl+O` | Cycle view modes |
| `Cmd+Shift+M` | Open permission mode menu |
| `Cmd+Shift+I` | Open model menu |
| `Cmd+Shift+E` | Open effort menu |

**View modes** (Transcript view dropdown or `Ctrl+O`):

| Mode | Shows |
| :--- | :--- |
| Normal | Tool calls collapsed, full text responses |
| Verbose | Every tool call, file read, intermediate step |
| Summary | Final responses and changes only |

**Preview server config** (`.claude/launch.json`):

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command: `npm`, `yarn`, `node` |
| `runtimeArgs` | string[] | Args: `["run", "dev"]` |
| `port` | number | Port (default: 3000) |
| `cwd` | string | Working dir relative to project root |
| `env` | object | Environment variables (no secrets) |
| `autoPort` | boolean | Auto-find free port on conflict |
| `program` | string | Node script path (use instead of `runtimeExecutable`) |
| `args` | string[] | Args for `program` |
| `autoVerify` | boolean | Set `false` at top level to disable auto-verify |

**Session isolation:** each session gets its own Git worktree in `<project-root>/.claude/worktrees/` by default. Copy gitignored files (like `.env`) to worktrees via `.worktreeinclude`.

**Side chat:** press `Cmd+;` (macOS) or `Ctrl+;` (Windows), or type `/btw`, to ask a question using session context without adding it to the main conversation.

**Continue in another surface:** the VS Code icon in the session toolbar opens a "Continue in" menu to move a local session to Claude Code on the Web (remote) or open the project in your IDE.

**Move CLI session to Desktop:** run `/desktop` in the terminal (macOS/Windows only).

**Managed settings keys** (for enterprise managed settings file):

| Key | Description |
| :--- | :--- |
| `permissions.disableBypassPermissionsMode` | Set `"disable"` to block Bypass mode |
| `disableAutoMode` | Set `"disable"` to remove Auto from selector (also accepted under `permissions`) |
| `autoMode` | Customize auto mode classifier rules |
| `sshConfigs` | Pre-configure SSH connections for all users |

**Pre-configure SSH connections** (`sshConfigs` entry fields):

| Field | Required | Description |
| :--- | :--- | :--- |
| `id` | Yes | Unique identifier |
| `name` | Yes | Display label |
| `sshHost` | Yes | `user@hostname` or SSH config alias |
| `sshPort` | No | Defaults to 22 |
| `sshIdentityFile` | No | Path to private key |
| `startDirectory` | No | Remote directory to open |

**CLI flag equivalents in Desktop:**

| CLI flag | Desktop equivalent |
| :--- | :--- |
| `--model` | Model dropdown |
| `--resume` / `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector |
| `--dangerously-skip-permissions` | Bypass permissions via Settings |
| `--verbose` | Verbose view mode |
| `--print` / `--output-format` | Not available |

**Computer use in Desktop:** available on macOS and Windows (Pro/Max plans; not Team/Enterprise). Enable in Settings → General → Computer use toggle. Grant Accessibility and Screen Recording on macOS. App approvals last the full session (30 minutes for Dispatch-spawned sessions).

---

### Chrome browser integration

**Requirements:** Claude Code ≥ 2.0.73, Claude in Chrome extension ≥ 1.0.36, direct Anthropic plan (Pro/Max/Team/Enterprise). Not available with Bedrock/Vertex/Foundry.

**Enable:** `claude --chrome` or `/chrome` inside a session. Enable by default via `/chrome` → "Enabled by default".

**VS Code:** type `@browser` in the prompt box (no flag needed when extension is installed).

**Capabilities:**
- Live debugging (console errors, DOM state)
- Web app testing (form validation, visual regressions, user flows)
- Authenticated web app interaction (Google Docs, Gmail, Notion, etc.)
- Data extraction from web pages
- Task automation (form filling, multi-site workflows)
- Session recording as GIF

**Session behavior:** Claude opens new tabs, shares your browser login state, and pauses at login pages/CAPTCHAs for manual handling.

**Common errors:**

| Error | Fix |
| :--- | :--- |
| "Browser extension is not connected" | Restart Chrome and Claude Code, run `/chrome` to reconnect |
| "Extension not detected" | Install or enable extension in `chrome://extensions` |
| "Receiving end does not exist" | Service worker went idle — run `/chrome` → "Reconnect extension" |
| "No tab available" | Ask Claude to open a new tab and retry |

---

### Computer use (CLI, macOS only)

**Requirements:** Claude Code ≥ 2.1.85, Pro or Max plan, macOS, interactive session (not `-p` flag). Not available on Team/Enterprise.

**Enable:** `/mcp` → select `computer-use` → Enable. Then grant Accessibility and Screen Recording in System Settings.

**Per-session app approval:** Claude asks before controlling each app. Approvals last the session.

**App permission tiers** (same as Desktop):

| Tier | What Claude can do | Applies to |
| :--- | :--- | :--- |
| View only | See app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, no typing | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

**Safety mechanisms:**
- Per-app approval required each session
- Terminal excluded from screenshots (Claude never sees its own output)
- `Esc` key aborts immediately (consumed — cannot be injected)
- Machine-wide lock: only one session can use computer use at a time
- Screenshots downscaled automatically (no need to lower display resolution)

**Stop computer use:** press `Esc` anywhere or `Ctrl+C` in terminal.

**Key CLI vs Desktop differences:**

| Feature | Desktop | CLI |
| :--- | :--- | :--- |
| Platforms | macOS + Windows | macOS only |
| Enable | Settings toggle | `/mcp` → `computer-use` |
| Denied apps list | Configurable | Not available |
| Dispatch integration | Yes | Not applicable |

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) — full Desktop app reference: sessions, permission modes, diff view, preview servers, computer use, enterprise configuration, and CLI comparison
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — install guide and first-session walkthrough for the Desktop app
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — VS Code extension install, prompt box, @-mentions, checkpoints, MCP, git integration, settings, and built-in IDE MCP server
- [JetBrains IDEs](references/claude-code-jetbrains.md) — JetBrains plugin install, shortcuts, configuration, remote development, and WSL setup
- [Use Claude Code with Chrome](references/claude-code-chrome.md) — Chrome browser integration capabilities, setup, example workflows, and troubleshooting
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — CLI computer use setup, app approval flow, safety model, example workflows, and troubleshooting

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
