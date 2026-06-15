---
name: ide-doc
description: IDE and desktop integrations for Claude Code — Desktop app, VS Code extension, JetBrains plugin, Chrome browser integration, and computer use from the CLI and Desktop.
user-invocable: false
---

# IDE and Desktop Integration Documentation

This skill provides the complete official documentation for Claude Code IDE and desktop integrations: the Desktop app (macOS/Windows), the VS Code extension, JetBrains IDEs, Chrome browser integration, and computer use.

## Quick Reference

### Integration Surfaces at a Glance

| Surface | Platform | How to install | Requires CLI? |
|---|---|---|---|
| **Desktop app — Code tab** | macOS, Windows | Download from claude.com/download | No (bundled) |
| **VS Code extension** | macOS, Windows, Linux | Install from VS Code Marketplace | No (bundled); separate CLI for terminal |
| **JetBrains plugin** | macOS, Windows, Linux | JetBrains Marketplace | Yes (runs `claude` in integrated terminal) |
| **Chrome integration** | macOS, Windows, Linux | Claude in Chrome extension (v1.0.36+) | Yes (CLI v2.0.73+) or VS Code extension |
| **Computer use (CLI)** | macOS only | Enable `computer-use` in `/mcp` | Yes |
| **Computer use (Desktop)** | macOS, Windows | Toggle in Settings → General | No |

---

### Desktop App — Permission Modes

| Mode | Settings key | Behavior |
|---|---|---|
| **Ask permissions** | `default` | Asks before editing files or running commands |
| **Auto accept edits** | `acceptEdits` | Auto-accepts file edits and common filesystem commands; still asks for other terminal commands |
| **Plan mode** | `plan` | Reads and explores; proposes a plan without editing source code |
| **Auto** | `auto` | Executes all actions with background safety checks; requires Opus 4.6+ or Sonnet 4.6 |
| **Bypass permissions** | `bypassPermissions` | No permission prompts except forced ask rules; use only in sandboxed environments |

Auto mode requires Claude Opus 4.6+ or Sonnet 4.6. Not available on Team/Enterprise plans by default; requires `CLAUDE_CODE_ENABLE_AUTO_MODE` on Vertex AI.

---

### Desktop App — Keyboard Shortcuts

| Shortcut (macOS) | Action |
|---|---|
| `Cmd+N` | New session |
| `Cmd+W` | Close session |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next / previous session |
| `Esc` | Stop Claude's response |
| `Cmd+Shift+D` | Toggle diff pane |
| `Cmd+Shift+P` | Toggle preview pane |
| `Ctrl+\`` | Toggle terminal pane |
| `Cmd+\` | Close focused pane |
| `Cmd+;` | Open side chat |
| `Ctrl+O` | Cycle view modes |
| `Cmd+Shift+M` | Open permission mode menu |
| `Cmd+Shift+I` | Open model menu |

On Windows, use `Ctrl` in place of `Cmd` (except session cycling and terminal toggle, which use `Ctrl` on all platforms).

---

### Desktop App — View Modes

| Mode | Shows |
|---|---|
| **Normal** | Tool calls collapsed into summaries, full text responses |
| **Verbose** | Every tool call, file read, and intermediate step |
| **Summary** | Only Claude's final responses and changes made |

Switch via the **Transcript view** dropdown or press `Ctrl+O`.

---

### Desktop App — Environment Options

| Environment | Where Claude runs | Continues when app closed? |
|---|---|---|
| **Local** | Your machine, direct file access | No |
| **Remote** | Anthropic's cloud infrastructure | Yes |
| **SSH** | Remote machine over SSH | Depends on remote |

SSH sessions support permission modes, connectors, plugins, and MCP servers. The remote machine must run Linux or macOS. Desktop installs Claude Code automatically on first connect.

---

### Desktop App — `.claude/launch.json` (Preview Server)

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

| Field | Type | Description |
|---|---|---|
| `name` | string | Unique identifier for this server |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments to `runtimeExecutable` |
| `port` | number | Port your server listens on (default: 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables (no secrets here) |
| `autoPort` | boolean | `true` = find free port; `false` = fail on conflict; unset = ask |
| `program` | string | Node.js script to run directly (alternative to `runtimeExecutable`) |
| `args` | string[] | Arguments for `program` |
| `autoVerify` | boolean | Auto-verify changes after every edit (top-level field, default true) |

---

### Desktop App — Managed Settings Keys

| Key | Description |
|---|---|
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to prevent Bypass permissions mode |
| `disableAutoMode` | Set to `"disable"` to prevent Auto mode |
| `autoMode` | Customize auto mode classifier rules |
| `sshConfigs` | Pre-configure SSH connections for all users |
| `sshHostAllowlist` | Restrict SSH sessions to approved host patterns |
| `managedMcpServers` | Push MCP server configs to all users (third-party Desktop deployments only) |

---

### Desktop App — CLI Equivalents

| CLI flag | Desktop equivalent |
|---|---|
| `--model sonnet` | Model dropdown next to send button |
| `--resume`, `--continue` | Click a session in the sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (Settings → Claude Code) |
| `--add-dir` | Add multiple repos with **+** button in cloud sessions |
| `--verbose` | Verbose view mode in Transcript view dropdown |
| `MAX_THINKING_TOKENS` | Set in local environment editor |

---

### VS Code Extension — Key Settings

| Setting | Default | Description |
|---|---|---|
| `useTerminal` | `false` | Launch Claude in terminal mode |
| `initialPermissionMode` | `default` | Approval mode for new conversations: `default`, `plan`, `acceptEdits`, `bypassPermissions` |
| `preferredLocation` | `panel` | Where Claude opens: `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads or writes them |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter to send |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N for new conversation |
| `allowDangerouslySkipPermissions` | `false` | Adds Bypass permissions to mode selector |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party provider setups) |

Add `"$schema": "https://json.schemastore.org/claude-code-settings.json"` to `settings.json` for autocomplete.

---

### VS Code Extension — Shortcuts

| Shortcut | Action |
|---|---|
| `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | Open new conversation as editor tab |
| `Cmd+N` / `Ctrl+N` | New conversation (requires `enableNewConversationShortcut: true`) |
| `Cmd+Shift+T` / `Ctrl+Shift+T` | Reopen most recently closed Claude session tab |
| `Option+K` / `Alt+K` | Insert @-mention reference for current selection |

On macOS Tahoe+, system Game Overlay may intercept `Cmd+Esc` — disable via System Settings → Keyboard → Keyboard Shortcuts → Game Controllers.

---

### VS Code Extension — CLI Feature Comparison

| Feature | CLI | VS Code Extension |
|---|---|---|
| Commands and skills | All | Subset (type `/` to see available) |
| MCP server config | Yes | Partial (add via CLI; manage with `/mcp` in panel) |
| Checkpoints / rewind | Yes | Yes |
| Bang (`!`) bash shortcut | Yes | No |
| Tab completion | Yes | No |

Extension and CLI share conversation history. Resume an extension session in CLI with `claude --resume`.

---

### VS Code Extension — Built-in IDE MCP Server

The extension runs a local MCP server named `ide` for CLI integration. It exposes two tools visible to the model:

| Tool | What it does | Writes? |
|---|---|---|
| `mcp__ide__getDiagnostics` | Returns language-server diagnostics (VS Code Problems panel), optionally scoped to one file | No |
| `mcp__ide__executeCode` | Runs Python code in the active Jupyter notebook kernel; always prompts user to confirm | Yes |

The server binds to `127.0.0.1` on a random port. A fresh auth token is written to `~/.claude/ide/` with `0600` permissions on each activation.

---

### JetBrains Plugin — Quick Setup

1. Install the Claude Code CLI (`claude`) — the plugin does not bundle it
2. Install the [Claude Code plugin](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-) from JetBrains Marketplace
3. Restart the IDE (may need to restart multiple times)
4. Run `claude` from the integrated terminal, or use `Cmd+Esc` / `Ctrl+Esc` to launch

For remote development, install the plugin in the **remote host** via Settings → Plugin (Host), not the local client.

**JetBrains shortcuts:**

| Shortcut | Action |
|---|---|
| `Cmd+Esc` / `Ctrl+Esc` | Open Claude Code from editor |
| `Cmd+Option+K` / `Alt+Ctrl+K` | Insert file reference (e.g., `@src/auth.ts#L1-99`) |

---

### Chrome Integration

Enable from CLI: `claude --chrome` or run `/chrome` inside a session.  
Enable from VS Code: type `@browser` in the prompt box.

| Capability | Example prompt |
|---|---|
| Live debugging | `Open localhost:3000 and check the console for errors` |
| Design verification | `Build the UI from this mockup and open it in the browser to verify` |
| Web app testing | `Test the login form validation` |
| Authenticated apps | Work with Google Docs, Gmail, Notion without API connectors |
| Data extraction | `Extract product listings and save as CSV` |
| Session recording | `Record a GIF showing the checkout flow` |

**Prerequisites:** Google Chrome or Microsoft Edge, Claude in Chrome extension v1.0.36+, Claude Code v2.0.73+, direct Anthropic plan (Pro/Max/Team/Enterprise). Not available through Bedrock, Vertex AI, or Foundry.

---

### Computer Use

| Feature | Desktop app | CLI |
|---|---|---|
| Platforms | macOS, Windows | macOS only |
| Enable | Settings → General → Computer use toggle | Enable `computer-use` in `/mcp` |
| Plans | Pro or Max only (not Team or Enterprise) | Pro or Max only (not Team or Enterprise) |
| Denied apps list | Configurable in Settings | Not available |
| Per-app approvals | Per session (30 min for Dispatch-spawned sessions) | Per session |

**App control tiers (fixed, cannot be changed):**

| Tier | What Claude can do | Applies to |
|---|---|---|
| View only | See app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, but not type or use keyboard shortcuts | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

**Tool priority order (Claude tries in this order):**
1. MCP server / connector for the service
2. Bash (if the task is a shell command)
3. Claude in Chrome (if the task is browser work)
4. Computer use (everything else)

**Safety guardrails:**
- Per-app approval required each session
- Terminal excluded from screenshots (Claude never sees its own output)
- `Esc` key aborts computer use globally; the key press is consumed to prevent prompt injection
- Machine-wide lock prevents two sessions controlling the screen simultaneously

---

### Shared Config (Desktop and CLI)

Desktop and CLI both read:
- `CLAUDE.md` and `CLAUDE.local.md` in your project
- MCP servers in `~/.claude.json` or `.mcp.json`
- Hooks and skills defined in settings
- `~/.claude/settings.json` permission rules and allowed tools

Desktop also reads `claude_desktop_config.json` MCP servers into Code tab sessions. The standalone CLI does not read this file — use `claude mcp add-from-claude-desktop` to import those servers into `~/.claude.json`.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Desktop application](references/claude-code-desktop.md) — Full reference for the Code tab: permission modes, workspace panes, diff view, preview servers, sessions, SSH, enterprise configuration, and CLI comparison
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — Installation walkthrough and first session guide for macOS and Windows
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — VS Code extension: installation, prompt box, @-mentions, checkpoints, MCP, plugins, settings, and the built-in IDE MCP server
- [JetBrains IDEs](references/claude-code-jetbrains.md) — JetBrains plugin: installation, usage, WSL configuration, and troubleshooting for IntelliJ, PyCharm, WebStorm, and more
- [Use Claude Code with Chrome](references/claude-code-chrome.md) — Chrome browser integration: capabilities, setup, example workflows, and troubleshooting
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — CLI computer use: enabling the `computer-use` MCP server, app approvals, safety guardrails, and example workflows

## Sources

- Desktop application: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
