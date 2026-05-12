---
name: ide-doc
description: Complete official documentation for Claude Code IDE and desktop integrations — VS Code extension, JetBrains plugin, Claude Desktop app (including quickstart), Chrome browser integration, and computer use.
user-invocable: false
---

# IDE & Desktop Integration Documentation

This skill provides the complete official documentation for Claude Code IDE integrations, the desktop app, browser automation, and computer use.

## Quick Reference

### VS Code Extension

**Requirements:** VS Code 1.98.0+, Anthropic account (or third-party provider)

**Install:** `Cmd+Shift+X` → search "Claude Code" → Install. Also works in Cursor, Windsurf, Kiro, and other VS Code forks (search in Extensions or install from Open VSX registry).

**Open Claude:** Spark icon in the Editor Toolbar (requires an open file), Activity Bar icon, Command Palette (`Cmd+Shift+P` / `Ctrl+Shift+P`), or Status Bar "✱ Claude Code".

**Permission modes** (switch via mode indicator at bottom of prompt box):

| Mode | Setting key | Behavior |
| :--- | :--- | :--- |
| Normal (Ask) | `default` | Asks before each action |
| Plan | `plan` | Describes plan, waits for approval |
| Auto accept edits | `acceptEdits` | Edits without asking |
| Auto | `auto` | Background safety checks, fewer prompts |
| Bypass permissions | `bypassPermissions` | No prompts — sandboxes only |

**Key VS Code shortcuts:**

| Shortcut | Action |
| :--- | :--- |
| `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | Open new conversation as editor tab |
| `Option+K` / `Alt+K` | Insert @-mention reference for current selection |
| `Cmd+Shift+T` / `Ctrl+Shift+T` | Reopen most recently closed Claude session tab |
| `Cmd+N` / `Ctrl+N` | New conversation (requires `enableNewConversationShortcut: true`) |

**@-mentions:** type `@` + filename for fuzzy file matching; trailing `/` for folders. Selected text is auto-shared with Claude.

**Extension settings** (VS Code → Extensions → Claude Code):

| Setting | Default | Description |
| :--- | :--- | :--- |
| `useTerminal` | `false` | Launch in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | Default permission mode for new conversations |
| `preferredLocation` | `panel` | Where Claude opens: `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N for new conversation |
| `enableReopenClosedSessionShortcut` | `true` | Cmd/Ctrl+Shift+T to reopen last closed session |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from searches |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto mode and Bypass permissions to mode selector |

**URI handler:** `vscode://anthropic.claude-code/open` — opens a new Claude Code tab from scripts, aliases, or bookmarklets. Optional query params: `prompt` (URL-encoded pre-fill text) and `session` (session ID to resume).

**IDE MCP server (built-in):** runs locally on `127.0.0.1`, random port, per-activation auth token. Two model-visible tools:
- `mcp__ide__getDiagnostics` — language-server errors/warnings from VS Code Problems panel
- `mcp__ide__executeCode` — runs Python in active Jupyter notebook (always requires Quick Pick confirmation)

**Extension vs CLI feature comparison:**

| Feature | CLI | VS Code Extension |
| :--- | :--- | :--- |
| Commands and skills | All | Subset (type `/`) |
| MCP server config | Yes | Partial (add via CLI; manage with `/mcp`) |
| Checkpoints | Yes | Yes |
| `!` bash shortcut | Yes | No |
| Tab completion | Yes | No |

**Checkpoints (VS Code):** hover any message → rewind button → Fork from here, Rewind code, or Fork + rewind.

**Third-party providers:** check **Disable Login Prompt** in settings, then configure Bedrock/Vertex/Foundry in `~/.claude/settings.json`.

### JetBrains Plugin

**Supported IDEs:** IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand

**Install:** JetBrains Marketplace → search "Claude Code"

**Key features:**
- Quick launch: `Cmd+Esc` (Mac) or `Ctrl+Esc` (Windows/Linux)
- File reference shortcut: `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Linux/Windows) → inserts `@src/file.ts#L1-99`
- Diff viewing in IDE diff viewer
- Auto-shares current selection/tab with Claude
- Diagnostic (lint/syntax) errors shared automatically

**Plugin settings** (Settings → Tools → Claude Code [Beta]):
- **Claude command**: custom path, e.g., `wsl -d Ubuntu -- bash -lic "claude"` for WSL
- **Diff tool**: `auto` (IDE viewer) or `terminal`
- **Enable automatic updates**: auto-install plugin updates on restart

**Remote Development:** install plugin on the **remote host** (Settings → Plugin (Host)), not the local client.

**WSL2 issues ("No available IDEs detected"):** WSL2 NAT networking blocks the connection. Fix options:
1. Add a Windows Firewall rule to allow WSL2 subnet traffic (recommended)
2. Switch to mirrored networking in `.wslconfig`: `networkingMode=mirrored` (requires Windows 11 22H2+)

**External terminal:** run `/ide` inside Claude Code to connect to the JetBrains IDE.

### Claude Desktop App (Code Tab)

**Platforms:** macOS (Universal), Windows x64/ARM64. Not available on Linux — use the CLI instead.

**Requirements:** Pro, Max, Team, or Enterprise subscription. Windows requires Git for Windows.

**Session setup (configure before first message):**
- **Environment:** Local, Remote (Anthropic cloud), or SSH
- **Project folder:** select the working directory
- **Model:** pick from dropdown (can change during session)
- **Permission mode:** choose autonomy level (can change during session)

**Permission modes:**

| Mode | Setting key | Behavior |
| :--- | :--- | :--- |
| Ask permissions | `default` | Asks before editing files or running commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits + common filesystem commands; still asks for other terminal commands |
| Plan mode | `plan` | Explores and proposes a plan; no source code edits |
| Auto | `auto` | Background safety checks. Requires Max/Team/Enterprise/API plan + specific models |
| Bypass permissions | `bypassPermissions` | No prompts — sandboxed containers only |

Auto mode availability: Max plan → Opus 4.7; Team/Enterprise/API → Sonnet 4.6, Opus 4.6, or Opus 4.7. Not available on Pro or third-party providers.

**Pane layout:** drag any pane by its header to reposition. Available panes: chat, diff, preview, terminal, file editor, plan, tasks, subagent. Open panes from the Views menu.

**Keyboard shortcuts (Code tab):**

| Shortcut | Action |
| :--- | :--- |
| `Cmd+N` / `Ctrl+N` | New session |
| `Cmd+W` / `Ctrl+W` | Close session |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next/previous session |
| `Cmd+Shift+D` | Toggle diff pane |
| `Cmd+Shift+P` | Toggle preview pane |
| `Ctrl+\`` | Toggle terminal pane |
| `Cmd+\` | Close focused pane |
| `Cmd+;` / `Ctrl+;` | Open side chat |
| `Ctrl+O` | Cycle view modes (Normal/Verbose/Summary) |
| `Cmd+Shift+M` | Open permission mode menu |
| `Esc` | Stop Claude's response |

**Preview server configuration** (`.claude/launch.json`):

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

Key `launch.json` fields: `name`, `runtimeExecutable`, `runtimeArgs`, `port` (default 3000), `cwd`, `env`, `autoPort` (`true`=auto-find free port, `false`=fail if taken), `program` (for `node script.js` style), `args`.

**Parallel sessions:** each session gets its own Git worktree (stored in `<project-root>/.claude/worktrees/`). Press `Ctrl+Tab` to cycle. Hold `Cmd`/`Ctrl` and click a sidebar session to view two side by side.

**Side chat:** `Cmd+;` or `/btw` — asks a question using session context without affecting the main conversation.

**View modes** (Transcript view dropdown or `Ctrl+O`):
- Normal: tool calls collapsed into summaries
- Verbose: every tool call and file read
- Summary: only Claude's final responses and changes

**PR monitoring:** after opening a PR, CI status bar appears. Toggle Auto-fix (Claude fixes failing checks) and Auto-merge (squash merge when all checks pass). Requires `gh` CLI installed and authenticated.

**Diff review:** click `+12 -1` indicator → file-by-file diff → click any line to comment → `Cmd+Enter`/`Ctrl+Enter` to submit all comments. Click "Review code" for Claude to self-evaluate the diffs.

**Remote sessions:** continue even when the app is closed. Supports multiple repositories (add with `+` button). Monitor from claude.ai/code or Claude iOS app.

**SSH sessions:** add via environment dropdown → "+ Add SSH connection". Requires `user@hostname`, port (default 22), optional identity file. Remote must run Linux or macOS; Desktop auto-installs Claude Code on first connect.

**Enterprise managed settings keys:**

| Key | Description |
| :--- | :--- |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to prevent Bypass permissions mode |
| `disableAutoMode` | Set to `"disable"` to remove Auto from mode selector |
| `sshConfigs` | Pre-configure SSH connections (users cannot edit/delete managed entries) |
| `sshHostAllowlist` | Restrict SSH to matching hostname patterns; `[]` disables SSH entirely |

**CLI flag equivalents (Desktop):**

| CLI flag | Desktop equivalent |
| :--- | :--- |
| `--model` | Model dropdown |
| `--resume`, `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector |
| `--dangerously-skip-permissions` | Bypass permissions mode (Settings → Claude Code) |
| `--verbose` | Verbose view mode |

**Shared config with CLI:** `CLAUDE.md`, MCP servers (`~/.claude.json`/`.mcp.json`), hooks, skills, and settings (`~/.claude/settings.json`) are all shared. The Desktop chat app's `claude_desktop_config.json` is separate from Claude Code.

**Move CLI session to Desktop:** run `/desktop` in the terminal.

### Chrome Browser Integration (Beta)

**Requirements:** Claude Code 2.0.73+, Claude in Chrome extension 1.0.36+, Pro/Max/Team/Enterprise plan (direct Anthropic — not Bedrock/Vertex/Foundry). Works with Google Chrome and Microsoft Edge; not Brave, Arc, or WSL.

**Enable:** `claude --chrome` flag, or run `/chrome` inside a session. Enable by default via `/chrome` → "Enabled by default".

**Use in VS Code:** type `@browser` in the prompt box.

**Capabilities:** live debugging (console errors + DOM), design verification, web app testing, authenticated site interaction, data extraction, form automation, multi-site workflows, session recording (GIF).

**Common workflow example:**
```
@browser go to localhost:3000 and check the console for errors
```

**Troubleshooting:**
- "Chrome extension not detected": check `chrome://extensions`, restart Chrome after first enable (native messaging host is installed on first use)
- "Receiving end does not exist": extension service worker went idle → `/chrome` → "Reconnect extension"
- Connection drops in long sessions: reconnect via `/chrome`

**Native messaging host file locations (Chrome):**
- macOS: `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
- Linux: `~/.config/google-chrome/NativeMessagingHosts/...`
- Windows: `HKCU\Software\Google\Chrome\NativeMessagingHosts\`

### Computer Use

**Availability:**
- **CLI:** macOS only, Pro/Max plan, Claude Code v2.1.85+, interactive sessions only (not `-p` flag). Not available with third-party providers.
- **Desktop:** macOS and Windows, Pro or Max plan. Not available on Team or Enterprise.

**Enable in CLI:** `/mcp` → select `computer-use` → Enable. Grant macOS Accessibility and Screen Recording permissions when prompted (restart Claude Code if required after Screen Recording).

**Enable in Desktop:** Settings → General → Computer use toggle. Grant Accessibility and Screen Recording on macOS.

**App approval:** first time Claude needs an app in a session, a prompt appears. Approve or deny. Approvals last for the current session (30 min in Dispatch-spawned sessions).

**App control tiers:**

| Tier | What Claude can do | Applies to |
| :--- | :--- | :--- |
| View only | Screenshots only | Browsers, trading platforms |
| Click only | Click and scroll, no typing | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

**How it works:**
- Holds a machine-wide lock (one session at a time)
- Other apps hidden while Claude works; restored when Claude finishes
- Screenshots downscaled automatically (no resolution change needed)
- Terminal excluded from screenshots so Claude never sees its own output
- Press `Esc` anywhere to abort; `Ctrl+C` in terminal also works

**Tool precedence** (Claude tries most precise first): MCP server → Bash → Chrome → computer use.

**Safety guardrails:** per-app approval, sentinel warnings for shell/filesystem/system settings access, global Esc escape, machine-wide lock file.

**CLI vs Desktop differences:**

| Feature | Desktop | CLI |
| :--- | :--- | :--- |
| Platforms | macOS and Windows | macOS only |
| Enable | Toggle in Settings | Enable `computer-use` in `/mcp` |
| Denied apps list | Configurable | Not available |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) — full desktop app reference: sessions, permission modes, diff review, preview servers, computer use, parallel sessions, SSH, enterprise configuration, and CLI comparison
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — installation, first session walkthrough, and next steps
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — extension installation, prompt box, @-mentions, shortcuts, settings, IDE MCP server, plugins, git integration, and troubleshooting
- [JetBrains IDEs](references/claude-code-jetbrains.md) — plugin installation, features, configuration, WSL2 setup, and troubleshooting
- [Use Claude Code with Chrome](references/claude-code-chrome.md) — Chrome integration setup, capabilities, example workflows, and troubleshooting
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — computer use setup, app approval, safety, example workflows, and CLI vs Desktop differences

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
