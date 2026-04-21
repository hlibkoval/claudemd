---
name: ide-doc
description: Complete official documentation for Claude Code IDE and desktop integrations — the Claude Desktop app, VS Code extension, JetBrains plugin, Chrome browser integration, and computer use (CLI and Desktop).
user-invocable: false
---

# IDE & Desktop Integration Documentation

This skill provides the complete official documentation for Claude Code IDE and desktop integrations.

## Quick Reference

### Desktop App (macOS / Windows)

**Download:** macOS Universal DMG or Windows x64 Setup at claude.com/download. Linux is not supported.

**Requirements:** Pro, Max, Team, or Enterprise subscription. Git required on Windows.

The **Code** tab in the Claude Desktop app runs the same engine as the CLI with a graphical interface.

#### Session startup checklist

| Setting           | Options                                          |
| :---------------- | :----------------------------------------------- |
| Environment       | Local, Remote (cloud), SSH                       |
| Project folder    | Local path or (remote) multiple repos            |
| Model             | Sonnet, Opus, Haiku — changeable mid-session     |
| Permission mode   | Ask permissions, Auto accept edits, Plan, Auto, Bypass |

#### Permission modes

| Mode                   | Settings key        | Behavior                                                                 |
| :--------------------- | :------------------ | :----------------------------------------------------------------------- |
| Ask permissions        | `default`           | Asks before every file edit or command. Recommended for new users.       |
| Auto accept edits      | `acceptEdits`       | Auto-accepts file edits and common filesystem commands; asks for others. |
| Plan mode              | `plan`              | Reads and explores, then proposes a plan without editing source code.    |
| Auto                   | `auto`              | Background safety checks; reduced prompts. Research preview. Requires Sonnet 4.6, Opus 4.6, or Opus 4.7 on Team/Enterprise/API; Opus 4.7 only on Max. |
| Bypass permissions     | `bypassPermissions` | No prompts — equivalent to `--dangerously-skip-permissions`. Enable in Settings → Claude Code. Sandboxes only. |

#### Desktop keyboard shortcuts (macOS; use Ctrl in place of Cmd on Windows)

| Shortcut                              | Action                         |
| :------------------------------------ | :----------------------------- |
| `Cmd+N`                               | New session                    |
| `Cmd+W`                               | Close session                  |
| `Ctrl+Tab` / `Ctrl+Shift+Tab`         | Next / previous session        |
| `Esc`                                 | Stop Claude's response         |
| `Cmd+Shift+D`                         | Toggle diff pane               |
| `Cmd+Shift+P`                         | Toggle preview pane            |
| `Ctrl+\``                             | Toggle terminal pane           |
| `Cmd+\`                               | Close focused pane             |
| `Cmd+;`                               | Open side chat (`/btw`)        |
| `Ctrl+O`                              | Cycle view modes               |
| `Cmd+Shift+M`                         | Permission mode menu           |
| `Cmd+Shift+I`                         | Model menu                     |
| `Cmd+/`                               | Show all shortcuts             |

#### View modes (Transcript view dropdown)

| Mode    | Shows                                                       |
| :------ | :---------------------------------------------------------- |
| Normal  | Tool calls collapsed into summaries; full text responses    |
| Verbose | Every tool call, file read, and intermediate step           |
| Summary | Only Claude's final responses and the changes it made       |

#### Preview server config (`.claude/launch.json`)

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
      "autoPort": true
    }
  ]
}
```

Key `launch.json` fields:

| Field               | Type      | Description                                                              |
| :------------------ | :-------- | :----------------------------------------------------------------------- |
| `name`              | string    | Unique identifier for this server                                        |
| `runtimeExecutable` | string    | Command to run: `npm`, `yarn`, `node`, etc.                              |
| `runtimeArgs`       | string[]  | Arguments to `runtimeExecutable`, e.g. `["run", "dev"]`                 |
| `port`              | number    | Port your server listens on. Defaults to 3000.                           |
| `cwd`               | string    | Working directory relative to project root. Use `${workspaceFolder}`.   |
| `env`               | object    | Extra env vars as key-value pairs. Do not put secrets here.              |
| `autoPort`          | boolean   | `true` = pick a free port; `false` = fail if port taken; unset = ask.   |
| `program`           | string    | Node script to run directly (alternative to `runtimeExecutable`).       |
| `args`              | string[]  | Arguments to `program` (only used when `program` is set).               |
| `autoVerify`        | boolean   | Top-level field. Disable with `false` to skip auto-verification on edit. |

#### Environment types

| Environment | Where Claude runs                              | Notes                                        |
| :---------- | :--------------------------------------------- | :------------------------------------------- |
| Local       | Your machine                                   | Full access to files; terminal pane available |
| Remote      | Anthropic cloud                                | Continues after app close; multi-repo support |
| SSH         | Remote machine you manage                      | Claude Code must be installed on remote host  |

**SSH connection fields** (in managed settings `sshConfigs` array): `id`, `name`, `sshHost` (required); `sshPort`, `sshIdentityFile`, `startDirectory` (optional).

#### Enterprise managed settings keys

| Key                                        | Description                                                    |
| :----------------------------------------- | :------------------------------------------------------------- |
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to prevent Bypass permissions mode.         |
| `disableAutoMode`                          | Set to `"disable"` to remove Auto from the mode selector.      |
| `autoMode`                                 | Configure the auto mode classifier rules.                      |
| `sshConfigs`                               | Pre-configure SSH connections distributed to team members.     |

#### CLI flag equivalents in Desktop

| CLI flag / env var                    | Desktop equivalent                                      |
| :------------------------------------ | :------------------------------------------------------ |
| `--model sonnet`                      | Model dropdown next to send button                      |
| `--resume`, `--continue`             | Click a session in the sidebar                          |
| `--permission-mode`                   | Mode selector next to send button                       |
| `--dangerously-skip-permissions`      | Bypass permissions mode in Settings → Claude Code       |
| `--add-dir`                           | + button for multiple repos in remote sessions          |
| `--verbose`                           | Verbose view mode in Transcript view dropdown           |
| `MAX_THINKING_TOKENS`                 | Set in the local environment editor                     |

#### Feature comparison: CLI vs. Desktop

| Feature                 | CLI                              | Desktop                                         |
| :---------------------- | :------------------------------- | :---------------------------------------------- |
| Permission modes        | All, including `dontAsk`         | Ask, Auto accept edits, Plan, Auto, Bypass       |
| Third-party providers   | Bedrock, Vertex, Foundry         | Anthropic API by default; Vertex via enterprise  |
| MCP servers             | Settings files                   | Connectors UI (local/SSH) or settings files      |
| Plugins                 | `/plugin` command                | Plugin manager UI                               |
| File attachments        | Not available                    | Images, PDFs                                    |
| Session isolation       | `--worktree` flag                | Automatic worktrees                             |
| Computer use            | macOS only via `/mcp`            | macOS and Windows in Settings                   |
| Dispatch integration    | Not available                    | Dispatch badge in sidebar                       |
| Scripting/automation    | `--print`, Agent SDK             | Not available                                   |

---

### VS Code Extension

**Install:** search "Claude Code" in the Extensions view (`Cmd+Shift+X` / `Ctrl+Shift+X`) or use the direct link: `vscode:extension/anthropic.claude-code`. Requires VS Code 1.98.0+.

**Open Claude:** Spark icon in Editor Toolbar (requires a file open), Activity Bar, Status Bar (`✱ Claude Code`), or Command Palette (`Cmd+Shift+P` → "Claude Code").

**Permission modes:** Click the mode indicator at the bottom of the prompt box. Options: normal (ask), Plan mode (propose before executing), auto-accept. Set default in `claudeCode.initialPermissionMode`.

**@-mentions:** Type `@filename` (fuzzy match). Press `Option+K` / `Alt+K` to insert `@file#line-range` from current selection. Use `@terminal:name` for terminal output.

**Checkpoints (rewind):** Hover any message → rewind button:
- Fork conversation from here
- Rewind code to here
- Fork conversation and rewind code

#### VS Code extension settings

| Setting                           | Default   | Description                                                          |
| :-------------------------------- | :-------- | :------------------------------------------------------------------- |
| `useTerminal`                     | `false`   | Launch Claude in terminal mode instead of graphical panel            |
| `initialPermissionMode`           | `default` | Default permission mode: `default`, `plan`, `acceptEdits`, `bypassPermissions` |
| `preferredLocation`               | `panel`   | Where Claude opens: `sidebar` or `panel`                             |
| `autosave`                        | `true`    | Auto-save files before Claude reads or writes them                   |
| `useCtrlEnterToSend`              | `false`   | Use Ctrl/Cmd+Enter instead of Enter to send                          |
| `enableNewConversationShortcut`   | `false`   | Enable Cmd/Ctrl+N to start a new conversation                        |
| `hideOnboarding`                  | `false`   | Hide the onboarding checklist                                        |
| `respectGitIgnore`                | `true`    | Exclude .gitignore patterns from file searches                       |
| `usePythonEnvironment`            | `true`    | Activate workspace Python environment (requires Python extension)    |
| `disableLoginPrompt`              | `false`   | Skip auth prompts (for third-party provider setups)                  |
| `allowDangerouslySkipPermissions` | `false`   | Adds Auto and Bypass permissions to the mode selector                |

#### VS Code keyboard shortcuts

| Shortcut                                                  | Action                                      |
| :-------------------------------------------------------- | :------------------------------------------ |
| `Cmd+Esc` / `Ctrl+Esc`                                    | Toggle focus between editor and Claude      |
| `Cmd+Shift+Esc` / `Ctrl+Shift+Esc`                        | Open new conversation as editor tab         |
| `Option+K` / `Alt+K`                                      | Insert @-mention for current file/selection |
| `Cmd+N` / `Ctrl+N`                                        | New conversation (requires `enableNewConversationShortcut`) |

#### Built-in IDE MCP server

When the extension is active it runs a local MCP server (`ide`) on `127.0.0.1` with a random port and auth token. Two tools are visible to the model:

| Tool name                  | What it does                                                          | Writes? |
| :------------------------- | :-------------------------------------------------------------------- | :------ |
| `mcp__ide__getDiagnostics` | Returns language-server diagnostics from VS Code's Problems panel.    | No      |
| `mcp__ide__executeCode`    | Runs Python code in the active Jupyter notebook's kernel (always prompts first). | Yes |

#### Third-party providers in VS Code

1. Enable `claudeCode.disableLoginPrompt`.
2. Configure the provider in `~/.claude/settings.json` per the Bedrock, Vertex AI, or Foundry guide.

---

### JetBrains Plugin

**Supported IDEs:** IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand.

**Install:** [JetBrains Marketplace](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-). Restart IDE after install.

**Open Claude:** `Cmd+Esc` (Mac) / `Ctrl+Esc` (Windows/Linux), or click the Claude Code button in the UI.

**File reference shortcut:** `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Windows/Linux) — inserts `@File#L1-99` style references.

**Connect from external terminal:** run `/ide` inside Claude Code to link to the JetBrains IDE.

**Plugin settings:** Settings → Tools → Claude Code [Beta]
- `Claude command`: custom path, e.g. `/usr/local/bin/claude` or `wsl -d Ubuntu -- bash -lic "claude"`
- `Enable automatic updates`: auto-update plugin on restart
- `Enable using Option+Enter for multi-line prompts` (macOS only)

**Diff tool config:** run `/config` in Claude Code; set diff tool to `auto` (IDE viewer) or `terminal`.

**Remote Development:** install the plugin in the **remote host** via Settings → Plugin (Host), not the local client.

**WSL:** use `wsl -d <distro> -- bash -lic "claude"` as the Claude command.

---

### Chrome Integration (beta)

**Prerequisites:** Google Chrome or Microsoft Edge; Claude in Chrome extension v1.0.36+; Claude Code v2.0.73+; Pro, Max, Team, or Enterprise plan (direct Anthropic — not third-party providers).

**Enable in CLI:**
```bash
claude --chrome
```
Or run `/chrome` inside an existing session.

**Enable in VS Code:** available automatically when the Chrome extension is installed — type `@browser` in the prompt box.

**Enable by default:** run `/chrome` and select "Enabled by default" (note: increases context usage).

**Key capabilities:** live debugging (console errors, DOM state), design verification, web app testing, authenticated web app interaction, data extraction, task automation, session recording (GIF).

**Manage tools:** run `/mcp` and select `claude-in-chrome` to see all available browser tools.

**Common error messages:**

| Error                                | Fix                                                              |
| :----------------------------------- | :--------------------------------------------------------------- |
| "Browser extension is not connected" | Restart Chrome and Claude Code; run `/chrome` to reconnect       |
| "Extension not detected"             | Install/enable the extension in `chrome://extensions`            |
| "No tab available"                   | Ask Claude to create a new tab and retry                         |
| "Receiving end does not exist"       | Run `/chrome` → "Reconnect extension" (service worker went idle) |

---

### Computer Use

**Availability:**
- CLI: macOS only; Claude Code v2.1.85+; Pro or Max plan; direct Anthropic auth; interactive sessions only (no `-p` flag).
- Desktop: macOS and Windows; Pro or Max plan; not available on Team or Enterprise.

**Enable in CLI:**
1. Run `/mcp` in an interactive session.
2. Select `computer-use` → **Enable** (persists per project).
3. Grant macOS Accessibility and Screen Recording permissions.

**Enable in Desktop:** Settings → General → Computer use toggle. Then grant macOS Accessibility and Screen Recording permissions.

**App permission tiers (fixed, cannot be changed):**

| Tier         | What Claude can do                          | Applies to                  |
| :----------- | :------------------------------------------ | :-------------------------- |
| View only    | See the app in screenshots                  | Browsers, trading platforms |
| Click only   | Click and scroll, but not type              | Terminals, IDEs             |
| Full control | Click, type, drag, keyboard shortcuts       | Everything else             |

**Safety guardrails:**
- Per-app approval required each session (30 min in Dispatch-spawned sessions).
- Apps with broad reach (Terminal, Finder, System Settings) show sentinel warnings.
- Terminal window is excluded from screenshots to prevent prompt injection.
- `Esc` key aborts computer use from anywhere.
- Machine-wide lock: only one Claude Code session can use computer use at a time.

**Workflow:** Claude hides other visible apps while working; they are restored when the turn ends.

**CLI vs. Desktop differences:**

| Feature            | Desktop                              | CLI                          |
| :----------------- | :----------------------------------- | :--------------------------- |
| Platforms          | macOS and Windows                    | macOS only                   |
| Enable             | Toggle in Settings → General         | Enable `computer-use` in `/mcp` |
| Denied apps list   | Configurable in Settings             | Not yet available            |
| Auto-unhide toggle | Optional                             | Always on                    |

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) — full Desktop reference: permission modes, workspace layout, panes, preview servers, diff review, PR monitoring, computer use, session management, SSH sessions, enterprise configuration, CLI comparison, and troubleshooting.
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — install guide and first-session walkthrough for the Desktop app.
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — VS Code extension install, prompt box features, @-mentions, session history, plugin management, Chrome automation, checkpoints, MCP setup, git workflows, third-party providers, security, and troubleshooting.
- [JetBrains IDEs](references/claude-code-jetbrains.md) — JetBrains plugin install, configuration, remote development, WSL setup, and troubleshooting.
- [Use Claude Code with Chrome (beta)](references/claude-code-chrome.md) — Chrome integration setup, capabilities, example workflows, and troubleshooting.
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — computer use in the CLI: enabling, app approval, safety model, session flow, example workflows, and troubleshooting.

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome (beta): https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
