---
name: ide-doc
description: Complete official documentation for Claude Code IDE and desktop integrations — VS Code extension, JetBrains plugin, Claude Desktop app, Chrome browser integration, and computer use from the CLI and desktop.
user-invocable: false
---

# IDE and Desktop Integrations Documentation

This skill provides the complete official documentation for Claude Code IDE integrations and desktop surfaces.

## Quick Reference

### Supported Surfaces

| Surface | Install / Enable | Notes |
| :--- | :--- | :--- |
| VS Code extension | Extensions view → search "Claude Code" | Includes CLI; requires VS Code 1.98.0+ |
| Cursor extension | Extensions view → search "Claude Code" | Same extension as VS Code |
| JetBrains plugin | JetBrains Marketplace → "Claude Code Beta" | IntelliJ, PyCharm, WebStorm, GoLand, etc. |
| Claude Desktop (Code tab) | claude.ai download (macOS / Windows) | No Linux; requires Pro/Max/Team/Enterprise |
| Chrome integration | `--chrome` flag or `/chrome` in CLI | Requires Claude in Chrome extension v1.0.36+ |
| Computer use (CLI) | Enable `computer-use` in `/mcp` | macOS only, Pro/Max plan, Claude Code v2.1.85+ |
| Computer use (Desktop) | Settings → General → Computer use toggle | macOS and Windows |

---

### VS Code Extension

**Open Claude Code panel:**

| Method | How |
| :--- | :--- |
| Editor toolbar Spark icon | Click icon in top-right corner (file must be open) |
| Activity Bar | Spark icon in left sidebar |
| Status Bar | Click "* Claude Code" in bottom-right |
| Command Palette | `Cmd+Shift+P` → "Claude Code" |

**Key shortcuts (VS Code extension):**

| Shortcut | Action |
| :--- | :--- |
| `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | Open new conversation as editor tab |
| `Option+K` / `Alt+K` | Insert @-mention reference for current selection |
| `Cmd+N` / `Ctrl+N` | New conversation (requires `enableNewConversationShortcut: true`) |

**Extension settings (VS Code → Extensions → Claude Code):**

| Setting | Default | Description |
| :--- | :--- | :--- |
| `useTerminal` | `false` | Use CLI-style terminal instead of graphical panel |
| `initialPermissionMode` | `default` | Starting permission mode: `default`, `plan`, `acceptEdits`, `bypassPermissions` |
| `preferredLocation` | `panel` | Where Claude opens: `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter to send instead of Enter |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N for new conversation |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `usePythonEnvironment` | `true` | Activate workspace Python environment |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto mode and Bypass permissions to mode selector |

**Built-in IDE MCP server (hidden from `/mcp`):**

| Tool | What it does | Writes? |
| :--- | :--- | :--- |
| `mcp__ide__getDiagnostics` | Returns VS Code language-server errors/warnings | No |
| `mcp__ide__executeCode` | Runs Python code in active Jupyter notebook kernel (always prompts) | Yes |

The server binds to `127.0.0.1` on a random port with a fresh auth token per activation, stored in `~/.claude/ide/` (permissions `0600`/`0700`).

**URI handler for external launch:**
```
vscode://anthropic.claude-code/open?prompt=<url-encoded-text>&session=<session-id>
```

**Checkpoints (VS Code extension):**
- Hover any message → rewind button → Fork conversation, Rewind code, or Fork + Rewind

---

### JetBrains Plugin

**Key shortcuts:**

| Shortcut | Action |
| :--- | :--- |
| `Cmd+Esc` / `Ctrl+Esc` | Open Claude Code from editor |
| `Cmd+Option+K` / `Alt+Ctrl+K` | Insert file reference (e.g., `@src/auth.ts#L1-99`) |

**From external terminal — connect to IDE:**
```text
/ide
```

**Plugin settings (Settings → Tools → Claude Code):**
- `Claude command`: custom path, e.g., `claude`, `/usr/local/bin/claude`, `wsl -d Ubuntu -- bash -lic "claude"`
- Diff tool: `auto` (IDE viewer) or `terminal`
- ESC key fix: Settings → Tools → Terminal → uncheck "Move focus to editor with Escape"

**Remote Development:** install plugin in remote host via Settings → Plugin (Host), not local client.

**WSL2 fix for "No available IDEs detected":** Add Windows Firewall rule for WSL2 subnet, or set `networkingMode=mirrored` in `.wslconfig` (Windows 11 22H2+).

---

### Claude Desktop App (Code Tab)

**Download:** macOS (Universal) or Windows x64/ARM64 at claude.ai/download. Not available on Linux — use CLI.

**Session setup (before first message):**
- Environment: **Local** / **Remote** (cloud, continues without app) / **SSH** (remote machine)
- Project folder (multiple repos supported in Remote via the **+** button)
- Model (changeable mid-session)
- Permission mode (changeable mid-session)

**Permission modes:**

| Mode | Settings key | Behavior |
| :--- | :--- | :--- |
| Ask permissions | `default` | Asks before each edit or command |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits and common filesystem commands |
| Plan mode | `plan` | Reads/explores only; proposes plan without editing |
| Auto | `auto` | Background safety checks, reduced prompts. Research preview: Max (Opus 4.7 required), Team/Enterprise/API (Sonnet 4.6, Opus 4.6, or Opus 4.7 required). Not on Pro or third-party providers. |
| Bypass permissions | `bypassPermissions` | No prompts; enable in Settings. Enterprise can disable. |

**Desktop keyboard shortcuts (macOS / use Ctrl on Windows):**

| Shortcut | Action |
| :--- | :--- |
| `Cmd+N` | New session |
| `Cmd+W` | Close session |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next/previous session |
| `Cmd+Shift+D` | Toggle diff pane |
| `Cmd+Shift+P` | Toggle preview pane |
| `Ctrl+`` ` `` | Toggle terminal pane |
| `Cmd+\` | Close focused pane |
| `Cmd+;` | Open side chat |
| `Ctrl+O` | Cycle view modes (Normal / Verbose / Summary) |
| `Cmd+Shift+M` | Open permission mode menu |
| `Cmd+/` | Show all shortcuts |

**Panes available:** chat, diff, preview, terminal, file editor, plan, tasks, subagent. Drag by header to reposition; drag edges to resize.

**Preview server config (`.claude/launch.json`):**

```json
{
  "version": "0.0.1",
  "autoVerify": true,
  "configurations": [
    {
      "name": "web",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"],
      "port": 3000,
      "cwd": "apps/web",
      "env": { "NODE_ENV": "development" },
      "autoPort": true
    }
  ]
}
```

`autoPort`: `true` = pick free port, `false` = fail if busy, omit = ask once and save.
`autoVerify`: when `true` (default), Claude automatically takes screenshots and verifies changes after every edit.
Use `runtimeExecutable`+`runtimeArgs` for package managers; use `program`+`args` to run a Node.js script directly with `node`.

**PR monitoring:** requires `gh` CLI authenticated. Auto-fix (fix failing CI) and Auto-merge (squash merge) toggles in CI status bar.

**Session worktrees** stored in `<project-root>/.claude/worktrees/`. Use `.worktreeinclude` to copy gitignored files (e.g., `.env`) into worktrees.

**Side chat:** `Cmd+;` or `/btw` — uses session context without adding to main thread. Available in local and SSH sessions.

**Tasks pane:** shows background work in the current session (subagents, background shell commands). Open from Views menu.

**Continue in another surface:** VS Code icon → bottom-right of session toolbar → "Claude Code on the Web" or "Your IDE".

**Dispatch integration:** tasks can be sent from the Claude Cowork tab. Dispatch-spawned sessions appear in the sidebar with a "Dispatch" badge. Requires Pro or Max plan (not Team/Enterprise).

**SSH sessions:** environment dropdown → Add SSH connection. Fields: Name, SSH Host (`user@hostname`), SSH Port (default 22), Identity File. Desktop installs Claude Code on remote automatically. Remote must be Linux or macOS.

**Pre-configure SSH for teams** via `sshConfigs` in managed settings.

**Local environment variables:** environment dropdown → hover Local → gear icon. Stored encrypted on machine. Also available via `env` key in `~/.claude/settings.json` (Claude sessions only, not dev servers).

**Extended thinking / adaptive reasoning:**
- Enabled by default. Set `MAX_THINKING_TOKENS=0` to disable thinking.
- Opus 4.6 / Sonnet 4.6: set `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1` for fixed budget mode.
- Opus 4.7: always uses adaptive reasoning, no fixed-budget mode.

**Enterprise managed settings keys:**

| Key | Description |
| :--- | :--- |
| `permissions.disableBypassPermissionsMode` | Set `"disable"` to block bypass mode |
| `disableAutoMode` | Set `"disable"` to remove Auto from mode selector |
| `autoMode` | Customize auto mode classifier rules |
| `sshConfigs` | Pre-configure SSH connections for team |

**CLI flag equivalents in Desktop:**

| CLI flag | Desktop equivalent |
| :--- | :--- |
| `--model` | Model dropdown next to send button |
| `--resume` / `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector |
| `--dangerously-skip-permissions` | Bypass permissions mode (enable in Settings) |
| `--verbose` | Verbose view mode in Transcript view dropdown |
| `MAX_THINKING_TOKENS` | Local environment editor |

**Not available in Desktop:** Linux, third-party providers (Bedrock/Foundry), inline code suggestions, agent teams (`--print`/Agent SDK scripting).

---

### Chrome Integration

**Requirements:** Google Chrome or Microsoft Edge; Claude in Chrome extension v1.0.36+; Claude Code v2.0.73+; direct Anthropic plan (Pro/Max/Team/Enterprise). Not available on Brave, Arc, or WSL.

**Enable:**
```bash
claude --chrome        # start with Chrome
# or inside a session:
/chrome                # enable / reconnect / check status
```

Enable by default: run `/chrome` → "Enabled by default".

**Example usage (VS Code extension):**
```text
@browser go to localhost:3000 and check the console for errors
```

**Capabilities:** live debugging (console errors, DOM), design verification, web app testing, authenticated web apps (Google Docs, Gmail, Notion, etc.), data extraction, form automation, multi-site workflows, GIF session recording.

**Troubleshooting — native messaging host config file paths:**

| Browser / OS | Path |
| :--- | :--- |
| Chrome macOS | `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` |
| Chrome Linux | `~/.config/google-chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` |
| Edge macOS | `~/Library/Application Support/Microsoft Edge/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` |

**Common errors:**

| Error | Fix |
| :--- | :--- |
| "Browser extension is not connected" | Restart Chrome and Claude Code, run `/chrome` to reconnect |
| "Extension not detected" | Install/enable extension in `chrome://extensions` |
| "Receiving end does not exist" | Run `/chrome` → "Reconnect extension" (service worker went idle) |

---

### Computer Use (CLI)

**Requirements:** macOS only; Pro or Max plan; Claude Code v2.1.85+; interactive session (not `-p` flag); authenticated via claude.ai (not third-party providers).

**Enable:** In interactive session run `/mcp` → select `computer-use` → Enable. Grant macOS Accessibility and Screen Recording permissions.

**App permission tiers (same for CLI and Desktop):**

| Tier | What Claude can do | Applies to |
| :--- | :--- | :--- |
| View only | See in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, no typing | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

**Safety features:** per-app approval per session, sentinel warnings for shell/filesystem/system-settings apps, terminal excluded from screenshots, `Esc` key aborts immediately, machine-wide lock (one session at a time). Screenshots downscaled automatically (no need to lower display resolution).

**CLI vs Desktop differences:**

| Feature | Desktop | CLI |
| :--- | :--- | :--- |
| Platforms | macOS and Windows | macOS only |
| Enable | Settings → General toggle | `/mcp` → enable `computer-use` |
| Denied apps list | Configurable in Settings | Not available |
| Auto-unhide toggle | Optional | Always on |
| Dispatch integration | Dispatch-spawned sessions can use computer use | Not applicable |

**Troubleshoot `computer-use` not in `/mcp`:** must be macOS, Claude Code v2.1.85+, Pro/Max plan, authenticated via claude.ai (not third-party provider), interactive session.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) — full Desktop reference: permission modes, preview servers, diff view, PR monitoring, parallel sessions, SSH, computer use, enterprise config, CLI comparison
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — install guide and first-session walkthrough for the Desktop Code tab
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — extension install, panel layout, shortcuts, settings, MCP, checkpoints, built-in IDE MCP server details
- [JetBrains IDEs](references/claude-code-jetbrains.md) — plugin install, shortcuts, settings, remote development, WSL2 config, troubleshooting
- [Use Claude Code with Chrome](references/claude-code-chrome.md) — Chrome extension setup, CLI and VS Code usage, example workflows, troubleshooting
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — CLI computer use setup, app approval flow, safety guardrails, example workflows

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
