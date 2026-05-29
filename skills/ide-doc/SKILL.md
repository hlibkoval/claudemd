---
name: ide-doc
user-invocable: false
---

# IDE and Desktop Integration Documentation

This skill provides the complete official documentation for using Claude Code in IDEs (VS Code, JetBrains), the Desktop app, Chrome browser integration, and computer use.

## Quick Reference

### IDE Support Matrix

| Surface | Install / Enable | Key shortcut |
|:--------|:----------------|:-------------|
| **VS Code extension** | Extensions view → search "Claude Code" | `Cmd/Ctrl+Esc` — toggle focus |
| **Cursor / Windsurf / Kiro** | Same extension, search in Extensions view | Same |
| **Open VSX (other forks)** | [open-vsx.org](https://open-vsx.org/extension/Anthropic/claude-code) | Same |
| **JetBrains IDEs** | [JetBrains Marketplace](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-) | `Cmd+Esc` / `Ctrl+Esc` |
| **Claude Desktop app** | Download .dmg (macOS) or .exe (Windows) | `Cmd/Ctrl+N` — new session |
| **Chrome integration** | Claude in Chrome extension v1.0.36+; `claude --chrome` | `/chrome` — manage connection |
| **Computer use (CLI)** | Enable `computer-use` in `/mcp` | `Esc` — stop at any time |

### VS Code Extension — Key Settings

| Setting | Default | Description |
|:--------|:--------|:------------|
| `useTerminal` | `false` | Launch in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` (right) or `panel` (new tab) |
| `autosave` | `true` | Auto-save files before Claude reads or writes them |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter to send |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N for new conversation |
| `enableReopenClosedSessionShortcut` | `true` | Cmd/Ctrl+Shift+T reopens closed Claude session tab |
| `allowDangerouslySkipPermissions` | `false` | Adds Bypass permissions to mode selector |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party providers) |

Add `"$schema": "https://json.schemastore.org/claude-code-settings.json"` to `~/.claude/settings.json` for autocomplete.

### VS Code Keyboard Shortcuts

| Shortcut (Mac / Win+Linux) | Command |
|:--------------------------|:--------|
| `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | Open new conversation in editor tab |
| `Cmd+N` / `Ctrl+N` | New conversation (requires `enableNewConversationShortcut: true`) |
| `Cmd+Shift+T` / `Ctrl+Shift+T` | Reopen most recently closed Claude session tab |
| `Option+K` / `Alt+K` | Insert @-mention reference for current file/selection |

Open a new VS Code tab from external tools via the URI handler: `vscode://anthropic.claude-code/open?prompt=<url-encoded-text>&session=<id>`

### VS Code Extension vs. CLI Feature Comparison

| Feature | CLI | VS Code Extension |
|:--------|:----|:-----------------|
| Commands and skills | All | Subset (type `/` to see available) |
| MCP server config | Yes | Partial (`claude mcp add` in terminal; `/mcp` to manage) |
| Checkpoints (rewind) | Yes | Yes |
| `!` bash shortcut | Yes | No |
| Tab completion | Yes | No |

**Checkpoint rewind options** (hover any message): Fork conversation from here · Rewind code to here · Fork conversation and rewind code.

**Built-in IDE MCP server** (`ide`): hidden from `/mcp`, exposes two model-visible tools:

| Tool | What it does | Writes? |
|:-----|:-------------|:--------|
| `mcp__ide__getDiagnostics` | Returns VS Code Problems panel diagnostics, optionally scoped to one file | No |
| `mcp__ide__executeCode` | Runs Python in the active Jupyter notebook's kernel (always shows a Quick Pick confirmation) | Yes |

To exclude a sensitive file from selection/open-file context sharing, add a `Read` deny rule for its path.

### JetBrains Plugin — Quick Ref

| Feature | Details |
|:--------|:--------|
| Supported IDEs | IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand |
| Quick launch | `Cmd+Esc` (Mac) / `Ctrl+Esc` (Windows/Linux) |
| File reference shortcut | `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Linux/Windows) → inserts `@src/auth.ts#L1-99` |
| Diff tool setting | `/config` → set diff tool to `auto` (IDE viewer) or `terminal` |
| Custom Claude command | Settings → Tools → Claude Code [Beta] → Claude command |
| Remote Development | Install plugin in the **remote host**, not the local client |
| WSL2 fix | Add Windows Firewall rule for WSL2 subnet, or set `networkingMode=mirrored` in `.wslconfig` |

### Desktop App — Environments

| Environment | Description |
|:------------|:------------|
| **Local** | Runs on your machine; direct file access |
| **Remote** | Anthropic cloud; continues if app is closed; supports multiple repos |
| **SSH** | Remote machine you manage; Desktop auto-installs Claude Code on first connect |

### Desktop App — Permission Modes

| Mode | Settings key | Behavior |
|:-----|:------------|:---------|
| Ask permissions | `default` | Claude asks before every file edit or command |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits + safe filesystem commands |
| Plan mode | `plan` | Reads and explores, then proposes a plan without editing |
| Auto | `auto` | Model classifier approves/denies; research preview (Opus 4.6+, Sonnet 4.6+; Anthropic API only) |
| Bypass permissions | `bypassPermissions` | No prompts; only for sandboxed containers/VMs |

### Desktop App — Keyboard Shortcuts

| Shortcut | Action |
|:---------|:-------|
| `Cmd/Ctrl+N` | New session |
| `Cmd/Ctrl+W` | Close session |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next / previous session |
| `Esc` | Stop Claude's response |
| `Cmd+Shift+D` | Toggle diff pane |
| `Cmd+Shift+P` | Toggle preview pane |
| `Ctrl+`` ` `` ` | Toggle terminal pane |
| `Cmd+;` / `Ctrl+;` | Open side chat |
| `Ctrl+O` | Cycle view modes (Normal / Verbose / Summary) |
| `Cmd+Shift+M` | Open permission mode menu |
| `Cmd+/` | Show all keyboard shortcuts |

### Desktop App — Preview Server Config (`launch.json`)

Key fields for `.claude/launch.json`:

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique identifier for this server |
| `runtimeExecutable` | string | Command to run (e.g., `npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments (e.g., `["run", "dev"]`) |
| `port` | number | Port your server listens on; defaults to 3000 |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables (no secrets — file is committed) |
| `autoPort` | boolean | `true` = find free port; `false` = fail if port taken; unset = ask once |
| `program` | string | Node.js script to run directly (alternative to `runtimeExecutable`) |
| `autoVerify` | boolean | Top-level; disable auto-verify with `false` (default: on) |

Set `"autoVerify": false` at the top level to disable automatic screenshot-and-verify after edits.

### Desktop App — Enterprise / Managed Settings

| Key | Description |
|:----|:------------|
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to block bypass permissions mode |
| `disableAutoMode` | Set to `"disable"` to remove Auto from the mode selector |
| `sshConfigs` | Pre-distribute SSH connections to team members |
| `sshHostAllowlist` | Restrict SSH to approved hostnames (managed settings only) |
| `managedMcpServers` | Push MCP server configs to users (third-party Desktop deployments only) |

**Device management:** macOS via `com.anthropic.Claude` preference domain (Jamf/Kandji); Windows via registry at `SOFTWARE\Policies\Claude`.

### Chrome Integration

| Item | Detail |
|:-----|:-------|
| Prerequisites | Claude in Chrome extension ≥ v1.0.36; Claude Code ≥ v2.0.73; Pro/Max/Team/Enterprise plan |
| Supported browsers | Google Chrome, Microsoft Edge (not Brave, Arc, or WSL) |
| Enable for one session | `claude --chrome` flag |
| Enable inside session | `/chrome` |
| Enable by default | `/chrome` → "Enabled by default" |
| VS Code usage | Type `@browser` in the prompt box |
| Capabilities | Live debugging, design verification, form automation, data extraction, session recording (GIF) |
| Login/CAPTCHA | Claude pauses and asks you to handle manually |

### Computer Use (CLI)

| Item | Detail |
|:-----|:-------|
| Platform | macOS only in CLI; macOS + Windows in Desktop |
| Plan required | Pro or Max (not Team or Enterprise) |
| Minimum version | Claude Code v2.1.85+ |
| Enable | `/mcp` → select `computer-use` → Enable |
| macOS permissions | Accessibility + Screen Recording (grant both; may require restart) |
| Stop anytime | Press `Esc` — releases lock, unhides apps |
| App control tiers | Browsers/trading platforms: view only · Terminals/IDEs: click only · Everything else: full control |
| One session at a time | Machine-wide lock; another session must finish first |
| Screenshots | Auto-downscaled before sending to model |

## Full Documentation

For the complete official documentation, see the reference files:

- [Desktop App](references/claude-code-desktop.md) — Full reference: sessions, permission modes, diff view, preview servers, workspace layout, computer use, SSH, enterprise configuration, and CLI comparison
- [Desktop Quickstart](references/claude-code-desktop-quickstart.md) — Install and start your first session; key features overview
- [VS Code Extension](references/claude-code-vs-code.md) — Install, sign in, prompt box features, @-mentions, session history, plugin management, keyboard shortcuts, URI handler, settings reference, extension vs CLI comparison
- [JetBrains IDEs](references/claude-code-jetbrains.md) — Install, usage, configuration, remote development, WSL2 setup, and troubleshooting
- [Chrome Integration](references/claude-code-chrome.md) — Setup, capabilities, example workflows, site permissions, and troubleshooting
- [Computer Use (CLI)](references/claude-code-computer-use.md) — Enable via `/mcp`, app approval flow, safety model, example workflows, CLI vs Desktop differences

## Sources

- Desktop App: https://code.claude.com/docs/en/desktop.md
- Desktop Quickstart: https://code.claude.com/docs/en/desktop-quickstart.md
- VS Code Extension: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Chrome Integration: https://code.claude.com/docs/en/chrome.md
- Computer Use (CLI): https://code.claude.com/docs/en/computer-use.md
