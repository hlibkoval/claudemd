---
name: ide-doc
user-invocable: false
---

# IDE & Desktop Documentation

This skill provides the complete official documentation for using Claude Code in IDEs and the desktop application, including VS Code, JetBrains, the Claude Desktop app, Chrome browser integration, and computer use.

## Quick Reference

### Supported Surfaces

| Surface | How to access | Key install step |
| :--- | :--- | :--- |
| **VS Code extension** | Install from VS Code Marketplace (search "Claude Code") or `vscode:extension/anthropic.claude-code` | Requires VS Code 1.98.0+ |
| **Cursor / Windsurf / Kiro** | Search "Claude Code" in Extensions, or Open VSX registry | Same extension as VS Code |
| **JetBrains IDEs** | [JetBrains Marketplace plugin](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-) | Restart IDE after install |
| **Claude Desktop app** | Download at claude.ai/download (macOS + Windows only; not Linux) | Click the **Code** tab after sign-in |
| **Chrome browser** | Install [Claude in Chrome extension](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) v1.0.36+ | Use `claude --chrome` in CLI or `@browser` in VS Code |

---

### VS Code Extension — Key Settings

| Setting | Default | Description |
| :--- | :--- | :--- |
| `useTerminal` | `false` | Launch Claude in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | Starting permission mode: `default`, `plan`, `acceptEdits`, `bypassPermissions` |
| `preferredLocation` | `panel` | Where Claude opens: `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter to send |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N for new conversation |
| `enableReopenClosedSessionShortcut` | `true` | Cmd/Ctrl+Shift+T reopens last closed session tab |
| `hideOnboarding` | `false` | Hide the onboarding checklist |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto mode and Bypass permissions to mode selector |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party provider setups) |

### VS Code Extension — Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Cmd/Ctrl+Esc` | Toggle focus between editor and Claude |
| `Cmd/Ctrl+Shift+Esc` | Open new conversation in a new tab |
| `Cmd/Ctrl+N` | New conversation (requires `enableNewConversationShortcut: true`) |
| `Cmd/Ctrl+Shift+T` | Reopen most recently closed Claude session tab |
| `Option/Alt+K` | Insert @-mention reference for current file + selection |

### VS Code Extension vs. CLI

| Feature | CLI | VS Code Extension |
| :--- | :--- | :--- |
| Commands and skills | All | Subset (type `/` to see available) |
| MCP server config | Yes | Partial (add via CLI; manage with `/mcp` in panel) |
| Checkpoints (rewind) | Yes | Yes |
| Bash `!` shortcut | Yes | No |
| Tab completion | Yes | No |

**Checkpoint rewind options** (hover any message to reveal): Fork conversation from here, Rewind code to here, Fork conversation and rewind code.

### VS Code URI Handler

Open Claude Code tab from scripts or bookmarks:

```
vscode://anthropic.claude-code/open
vscode://anthropic.claude-code/open?prompt=review%20my%20changes
vscode://anthropic.claude-code/open?session=<session-id>
```

### Built-in IDE MCP Server (VS Code)

When the extension is active, it runs a local MCP server named `ide` (hidden from `/mcp`). Two tools are visible to the model:

| Tool | What it does | Writes? |
| :--- | :--- | :--- |
| `mcp__ide__getDiagnostics` | Returns language-server diagnostics (errors/warnings panel), optionally scoped to one file | No |
| `mcp__ide__executeCode` | Runs Python in active Jupyter notebook kernel — always prompts via Quick Pick | Yes |

The server binds to `127.0.0.1` on a random high port with a fresh auth token per activation, stored in `~/.claude/ide/` with `0600` permissions.

---

### JetBrains Plugin — Key Features

| Feature | Shortcut / Command |
| :--- | :--- |
| Open Claude Code | `Cmd+Esc` (Mac) / `Ctrl+Esc` (Win/Linux) |
| Insert file reference | `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Win/Linux) |
| Diff view | Shown in IDE diff viewer (set diff tool to `auto` in `/config`) |
| Connect from external terminal | Run `/ide` inside Claude Code |

**Plugin settings** (Settings → Tools → Claude Code [Beta]):
- **Claude command**: custom path, e.g. `/usr/local/bin/claude` or `wsl -d Ubuntu -- bash -lic "claude"`
- **Enable automatic updates**: auto-install plugin updates on restart
- **ESC key fix**: Settings → Tools → Terminal → uncheck "Move focus to the editor with Escape"

**Remote Development**: install the plugin on the **remote host** (Settings → Plugin (Host)), not the local client.

**WSL2 fix** (when "No available IDEs detected"): allow WSL2 traffic through Windows Firewall, or add `networkingMode=mirrored` to `.wslconfig` (Windows 11 22H2+ only).

---

### Claude Desktop App — Permission Modes

| Mode | Settings key | Behavior |
| :--- | :--- | :--- |
| Ask permissions | `default` | Claude asks before editing files or running commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits and common filesystem commands; still asks for other terminal commands |
| Plan mode | `plan` | Reads and explores, then proposes a plan without editing source code |
| Auto | `auto` | Executes all actions with background safety checks (Max/Team/Enterprise/API; requires Sonnet 4.6+) |
| Bypass permissions | `bypassPermissions` | No permission prompts; enable in Settings → Claude Code |

Auto mode requires: Max, Team, Enterprise, or API plan. Not available on Pro or third-party providers. On Team/Enterprise/API: Sonnet 4.6, Opus 4.6, or Opus 4.7. On Max: Opus 4.7.

### Claude Desktop App — Session Types

| Environment | Where Claude runs | Notes |
| :--- | :--- | :--- |
| Local | Your machine | Full access to files; terminal and file pane available |
| Remote | Anthropic cloud | Continues when app is closed; supports multiple repos |
| SSH | Remote machine over SSH | Desktop installs Claude Code on remote automatically |

### Claude Desktop App — Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Cmd/Ctrl+N` | New session |
| `Cmd/Ctrl+W` | Close session |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next / previous session |
| `Esc` | Stop Claude's response |
| `Cmd/Ctrl+Shift+D` | Toggle diff pane |
| `Cmd/Ctrl+Shift+P` | Toggle preview pane |
| `Ctrl+\`` | Toggle terminal pane |
| `Cmd/Ctrl+\` | Close focused pane |
| `Cmd/Ctrl+;` | Open side chat |
| `Ctrl+O` | Cycle view modes (Normal / Verbose / Summary) |
| `Cmd/Ctrl+Shift+M` | Open permission mode menu |
| `Cmd/Ctrl+/` | Show all keyboard shortcuts |

### Preview Server Config (`.claude/launch.json`)

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
      "autoPort": true,
      "cwd": "apps/web",
      "env": { "NODE_ENV": "development" }
    }
  ]
}
```

Key `configurations` fields: `name`, `runtimeExecutable`, `runtimeArgs`, `port`, `autoPort` (`true`=find free port, `false`=fail, unset=ask), `cwd`, `env`, `program` (run Node script directly), `args`.

Set `"autoVerify": false` to disable Claude's automatic screenshot-and-verify cycle after edits.

### Desktop — Enterprise Managed Settings Keys

| Key | Description |
| :--- | :--- |
| `permissions.disableBypassPermissionsMode` | Set `"disable"` to prevent bypass permissions mode |
| `disableAutoMode` | Set `"disable"` to remove Auto from mode selector |
| `sshConfigs` | Pre-configure SSH connections distributed to all users |
| `sshHostAllowlist` | Restrict SSH sessions to approved host patterns |
| `managedMcpServers` | Push MCP servers to all users (3P deployments only) |

---

### Computer Use

| Surface | Platforms | How to enable |
| :--- | :--- | :--- |
| CLI | macOS only | Enable `computer-use` MCP server via `/mcp`, grant Accessibility + Screen Recording |
| Desktop app | macOS and Windows | Toggle in Settings → General → Computer use |

Requires Pro or Max plan. Not available on Team or Enterprise. Requires interactive session (not `-p` flag in CLI). Not available with third-party providers (Bedrock, Vertex, Foundry).

**App permission tiers** (fixed by category):

| Tier | What Claude can do | Applies to |
| :--- | :--- | :--- |
| View only | See the app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, no typing | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

Pressing `Esc` anywhere aborts computer use immediately. One session holds the computer-use lock at a time.

---

### Chrome Integration

Requirements: Claude in Chrome extension v1.0.36+, Claude Code v2.0.73+, Pro/Max/Team/Enterprise plan, direct Anthropic account.

```bash
claude --chrome     # start with Chrome enabled
# or in-session:
/chrome             # check status, reconnect, set default
```

In VS Code: type `@browser` in the prompt box.

Capabilities: live debugging (console + DOM), design verification, web app testing, authenticated app interaction (Google Docs, Gmail, Notion), data extraction, task automation, GIF recording.

Not available on: Brave, Arc, other Chromium browsers, WSL.

---

### Desktop CLI Equivalents

| CLI flag | Desktop equivalent |
| :--- | :--- |
| `--model sonnet` | Model dropdown next to send button |
| `--resume` / `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector |
| `--dangerously-skip-permissions` | Bypass permissions mode (Settings → Claude Code) |
| `--add-dir` | + button for additional repos in remote sessions |
| `--verbose` | Verbose view mode in Transcript view dropdown |
| `--print` / `--output-format` | Not available (Desktop is interactive only) |

Desktop and CLI share: CLAUDE.md files, MCP servers (`~/.claude.json` / `.mcp.json`), hooks, skills, settings (`~/.claude/settings.json`).

## Full Documentation

For the complete official documentation, see the reference files:

- [Desktop application](references/claude-code-desktop.md) — full reference for the Code tab: sessions, diff view, preview, computer use, SSH, enterprise config, CLI comparison
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — install and first session walkthrough
- [Desktop changelog](references/claude-code-desktop-changelog.md) — release notes for Claude Code Desktop by app version
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — VS Code extension setup, settings, shortcuts, plugin management, IDE MCP server details
- [JetBrains IDEs](references/claude-code-jetbrains.md) — plugin install, features, WSL/remote dev configuration, troubleshooting
- [Use Claude Code with Chrome](references/claude-code-chrome.md) — browser integration setup, capabilities, example workflows, troubleshooting
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — CLI computer use setup, app permissions, safety model, workflow examples

## Sources

- Desktop application: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
- Desktop changelog: https://code.claude.com/docs/en/desktop-changelog.md
