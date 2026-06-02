---
name: ide-doc
user-invocable: false
---

# IDE and Desktop Integration Documentation

This skill provides the complete official documentation for using Claude Code across graphical interfaces: the Claude Desktop app (Code tab), the VS Code extension, JetBrains IDEs, Chrome browser integration, and computer use.

## Quick Reference

### Surface Comparison

| Surface | Platforms | Entry point | Best for |
|:--------|:----------|:------------|:---------|
| **Claude Desktop (Code tab)** | macOS, Windows | Download from claude.ai | Parallel sessions, visual diff, app preview, PR monitoring |
| **VS Code extension** | Any VS Code fork | `Cmd+Shift+X` → search "Claude Code" | In-editor graphical chat, checkpoints, multi-tab |
| **JetBrains plugin** | IntelliJ, PyCharm, WebStorm, GoLand, Android Studio, PhpStorm | JetBrains Marketplace | Terminal-based CLI with IDE diff viewer integration |
| **Chrome integration** | Chrome, Edge (beta) | `claude --chrome` or `/chrome` | Browser automation, live debugging, form filling |
| **Computer use (CLI)** | macOS only (Pro/Max) | Enable `computer-use` in `/mcp` | Native GUI apps, simulators, no-API tools |
| **Computer use (Desktop)** | macOS, Windows (Pro/Max) | Settings → General → Computer use toggle | Same as CLI, plus Dispatch sessions |

### Desktop App: Permission Modes

| Mode | Settings key | Behavior |
|:-----|:------------|:---------|
| Ask permissions | `default` | Claude asks before every edit or command — recommended for new users |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits and common filesystem commands; asks before other terminal commands |
| Plan mode | `plan` | Claude explores and proposes a plan without editing source code |
| Auto | `auto` | Executes with background safety checks (Opus 4.6+ or Sonnet 4.6; Anthropic API only) |
| Bypass permissions | `bypassPermissions` | No prompts — use only in sandboxed containers or VMs |

### Desktop App: Keyboard Shortcuts (macOS; use Ctrl on Windows)

| Shortcut | Action |
|:---------|:-------|
| `Cmd /` | Show all keyboard shortcuts |
| `Cmd N` | New session |
| `Cmd W` | Close session |
| `Ctrl Tab` / `Ctrl Shift Tab` | Cycle sessions |
| `Esc` | Stop Claude's response |
| `Cmd Shift D` | Toggle diff pane |
| `Cmd Shift P` | Toggle preview pane |
| `Ctrl` `` ` `` | Toggle terminal pane |
| `Cmd \` | Close focused pane |
| `Cmd ;` | Open side chat |
| `Ctrl O` | Cycle view modes |
| `Cmd Shift M` | Permission mode menu |
| `Cmd Shift I` | Model menu |

### Desktop App: View Modes

| Mode | What it shows |
|:-----|:-------------|
| Normal | Tool calls collapsed into summaries, full text responses |
| Verbose | Every tool call, file read, and intermediate step |
| Summary | Only final responses and changes made |

### Desktop App: Preview Server (.claude/launch.json) Fields

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (e.g., `npm`, `yarn`) |
| `runtimeArgs` | string[] | Arguments (e.g., `["run", "dev"]`) |
| `port` | number | Port to listen on (default: 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables (no secrets) |
| `autoPort` | boolean | `true` = pick free port; `false` = fail on conflict; unset = ask |
| `program` | string | Node.js script to run directly (alternative to `runtimeExecutable`) |
| `args` | string[] | Arguments for `program` |
| `autoVerify` | boolean | Root-level; disable auto-verify after edits (default: `true`) |

### Desktop App: Environment Modes

| Environment | Where Claude runs | Continues when app is closed |
|:------------|:------------------|:------------------------------|
| Local | Your machine | No |
| Remote | Anthropic cloud infrastructure | Yes |
| SSH | Remote machine you control | Depends on session |

### Desktop App: Managed Settings Keys

| Key | Description |
|:----|:------------|
| `permissions.disableBypassPermissionsMode` | Set `"disable"` to prevent bypass permissions mode |
| `disableAutoMode` | Set `"disable"` to remove Auto from mode selector |
| `autoMode` | Customize auto mode classifier rules org-wide |
| `sshConfigs` | Pre-configure SSH connections for team members |
| `sshHostAllowlist` | Restrict SSH sessions to approved host patterns |
| `managedMcpServers` | Push MCP server configs to all users (3P Desktop only) |

### Desktop App: CLI Flag Equivalents

| CLI flag | Desktop equivalent |
|:---------|:------------------|
| `--model` | Model dropdown next to send button |
| `--resume` / `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (enable in Settings → Claude Code) |
| `--verbose` | Verbose view mode in Transcript view dropdown |

### VS Code Extension: Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `useTerminal` | `false` | Launch Claude in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | Default mode for new conversations |
| `preferredLocation` | `panel` | Where Claude opens: `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads or writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter to send |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N for new conversation |
| `enableReopenClosedSessionShortcut` | `true` | Cmd/Ctrl+Shift+T reopens last Claude session tab |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `usePythonEnvironment` | `true` | Activate workspace Python environment (requires Python extension) |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party provider setups) |
| `allowDangerouslySkipPermissions` | `false` | Adds Bypass permissions to mode selector |
| `claudeProcessWrapper` | — | Custom executable to launch the Claude process |

### VS Code Extension: Keyboard Shortcuts

| Command | Shortcut | Description |
|:--------|:---------|:------------|
| Focus Input | `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| Open in New Tab | `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | New conversation as editor tab |
| New Conversation | `Cmd+N` / `Ctrl+N` | Start new conversation (requires `enableNewConversationShortcut: true`) |
| Reopen Closed Session | `Cmd+Shift+T` / `Ctrl+Shift+T` | Reopen last closed Claude session tab |
| Insert @-Mention Reference | `Option+K` / `Alt+K` | Insert reference to current file and selection |

### VS Code Extension: Built-in IDE MCP Server Tools

The `ide` server runs locally whenever the extension is active, bound to `127.0.0.1` on a random port with a per-activation auth token. It exposes two model-visible tools:

| Tool name | What it does | Writes? |
|:----------|:-------------|:--------|
| `mcp__ide__getDiagnostics` | Returns language-server diagnostics from the Problems panel (optionally scoped to one file) | No |
| `mcp__ide__executeCode` | Runs Python in the active Jupyter notebook's kernel — always shows a Quick Pick confirmation before executing | Yes |

### VS Code Extension vs. CLI Feature Comparison

| Feature | CLI | VS Code Extension |
|:--------|:----|:------------------|
| Commands and skills | All | Subset (type `/` to see) |
| MCP server config | Full | Partial (add via CLI; manage with `/mcp`) |
| Checkpoints | Yes | Yes |
| Bash shortcut (an exclamation mark followed by a command) | Yes | No |
| Tab completion | Yes | No |

### VS Code Checkpoint Options

Hover over any message to reveal the rewind button. Three options:

| Option | Effect |
|:-------|:-------|
| Fork conversation from here | New conversation branch; code changes intact |
| Rewind code to here | Revert file changes to this point; keep full conversation history |
| Fork conversation and rewind code | New branch and revert file changes to this point |

### VS Code URI Handler

Open a new Claude Code tab from external tools: `vscode://anthropic.claude-code/open`

| Query parameter | Description |
|:----------------|:------------|
| `prompt` | URL-encoded text to pre-fill in the prompt box |
| `session` | Session ID to resume instead of starting a new conversation |

### JetBrains Plugin: Key Features

| Feature | Details |
|:--------|:--------|
| Quick launch | `Cmd+Esc` (Mac) / `Ctrl+Esc` (Windows/Linux) opens Claude Code directly |
| Diff viewing | Code changes shown in the IDE diff viewer instead of terminal |
| Selection context | Current selection or tab shared automatically with Claude |
| File reference shortcut | `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Windows/Linux) inserts `@src/auth.ts#L1-99` |
| Diagnostic sharing | Lint and syntax errors auto-shared as you work |

### JetBrains Plugin: Plugin Settings (Settings → Tools → Claude Code)

| Setting | Description |
|:--------|:------------|
| Claude command | Custom command (e.g., `claude`, `/usr/local/bin/claude`, `npx @anthropic-ai/claude-code`) |
| Enable automatic updates | Auto-check and install plugin updates on restart |
| Enable Option+Enter for multi-line prompts | macOS only; inserts newlines in prompts without sending |

WSL tip: set Claude command to `wsl -d Ubuntu -- bash -lic "claude"` (replace `Ubuntu` with your distro name).

For Remote Development: install the plugin on the **remote host** via Settings → Plugin (Host), not the local client.

### Chrome Integration: Capabilities

| Capability | Description |
|:-----------|:------------|
| Live debugging | Read console errors and DOM state directly, then fix the code |
| Design verification | Build UI from a mockup, open in browser to verify it matches |
| Web app testing | Test form validation, visual regressions, user flows |
| Authenticated web apps | Google Docs, Gmail, Notion — uses your existing browser login state |
| Data extraction | Pull structured data from pages and save locally |
| Task automation | Automate data entry, form filling, multi-site workflows |
| Session recording | Record browser interactions as GIFs |

Requirements: Chrome or Edge; Claude in Chrome extension v1.0.36+; Claude Code v2.0.73+; direct Anthropic plan (Pro/Max/Team/Enterprise). Not available via Bedrock, Vertex, or Foundry.

CLI usage: `claude --chrome` to start, or run `/chrome` from within a session. Enable by default via `/chrome` → "Enabled by default" (increases context usage).

In VS Code: use `@browser` in the prompt box — no extra flag needed once the Chrome extension is installed.

### Computer Use: Platform Differences

| Feature | Desktop | CLI |
|:--------|:--------|:----|
| Platforms | macOS and Windows | macOS only |
| Requirements | Pro or Max plan | Pro or Max plan; Claude Code v2.1.85+; interactive session |
| Enable | Settings → General → Computer use toggle | Enable `computer-use` in `/mcp` |
| Denied apps list | Configurable in Settings | Not yet available |
| Auto-unhide on finish | Optional toggle | Always on |
| Dispatch integration | Supported | Not applicable |

### Computer Use: App Control Tiers

| Tier | What Claude can do | Applies to |
|:-----|:-------------------|:-----------|
| View only | See the app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, but not type or use keyboard shortcuts | Terminals, IDEs |
| Full control | Click, type, drag, and use keyboard shortcuts | Everything else |

Approvals are per-session. In Desktop, they last the whole session (30 minutes in Dispatch-spawned sessions). Press `Esc` anywhere to abort computer use and restore hidden windows.

### Tool Priority Order (Claude tries most precise tool first)

1. Connector or MCP server for the service
2. Bash (for shell commands)
3. Claude in Chrome (for browser tasks, when set up)
4. Computer use (for native apps, simulators, GUI-only tools)

## Full Documentation

For the complete official documentation, see the reference files:

- [Desktop application](references/claude-code-desktop.md) — Full reference for the Code tab: sessions, permission modes, diff view, app preview, PR monitoring, workspace layout, SSH sessions, computer use, enterprise configuration, CLI comparison
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — Install, first session, and overview of key desktop features
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — Install, graphical panel usage, @-mentions, session history, plugin management, settings, IDE MCP server, checkpoints, third-party providers, troubleshooting
- [JetBrains IDEs](references/claude-code-jetbrains.md) — Plugin install, features, settings, WSL2/remote development configuration, troubleshooting
- [Use Claude Code with Chrome (beta)](references/claude-code-chrome.md) — Browser automation setup, capabilities, example workflows, site permissions, troubleshooting
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — Enable via `/mcp`, per-session app approval, safety model, example workflows, differences from Desktop

## Sources

- Desktop application: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome (beta): https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
