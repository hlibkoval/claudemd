---
name: ide-doc
description: Complete official documentation for Claude Code IDE and desktop integrations — Desktop app, VS Code extension, JetBrains plugin, Chrome browser integration, and computer use (screen control).
user-invocable: false
---

# IDE & Desktop Integrations Documentation

This skill provides the complete official documentation for Claude Code IDE and desktop integrations.

## Quick Reference

### Integration surfaces at a glance

| Surface | Platforms | Install | Key strength |
| :--- | :--- | :--- | :--- |
| **Desktop app** | macOS, Windows | Download from claude.com | Parallel sessions with Git worktree isolation, drag-and-drop panes, visual diff review, live preview, PR monitoring, computer use, Dispatch |
| **VS Code extension** | macOS, Windows, Linux | Marketplace `anthropic.claude-code` | Native inline diffs, @-mentions with line ranges, plan review, multi-tab sessions |
| **JetBrains plugin** | macOS, Windows, Linux | JetBrains Marketplace | Diff viewing in IDE, selection context, diagnostic sharing |
| **Chrome integration** | macOS, Windows, Linux | Chrome Web Store extension + CLI `--chrome` | Browser automation, live debugging, form filling, data extraction |
| **Computer use** | CLI: macOS only; Desktop: macOS + Windows | Enable via `/mcp` (CLI) or Settings toggle (Desktop) | Native app control, GUI testing, screen interaction |

### Desktop app

#### Environment types

| Environment | Where it runs | Offline? | Notes |
| :--- | :--- | :--- | :--- |
| **Local** | Your machine | No | Full file access; may not inherit all shell env vars |
| **Remote** | Anthropic cloud | Continues if app closes | Same infra as Claude Code on the web; supports multi-repo |
| **SSH** | Your remote machine over SSH | No | Requires Claude Code installed on remote; Linux or macOS |

#### Permission modes (Desktop)

| Mode | Settings key | Behavior |
| :--- | :--- | :--- |
| Ask permissions | `default` | Asks before edits and commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits; asks for other commands |
| Plan mode | `plan` | Read-only exploration, proposes plan without editing |
| Auto | `auto` | Background safety checks; requires Sonnet 4.6+, Opus 4.6+, or Opus 4.7; research preview |
| Bypass permissions | `bypassPermissions` | No prompts; sandboxed containers only |

#### Keyboard shortcuts (Desktop, macOS; use Ctrl on Windows)

| Shortcut | Action |
| :--- | :--- |
| `Cmd` `N` | New session |
| `Cmd` `W` | Close session |
| `Ctrl` `Tab` / `Ctrl` `Shift` `Tab` | Cycle sessions |
| `Cmd` `Shift` `D` | Toggle diff pane |
| `Cmd` `Shift` `P` | Toggle preview pane |
| `Ctrl` `` ` `` | Toggle terminal |
| `Cmd` `\` | Close focused pane |
| `Cmd` `;` | Open side chat |
| `Ctrl` `O` | Cycle view modes (Normal / Verbose / Summary) |

#### Preview server config (`.claude/launch.json`)

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Args for the executable |
| `port` | number | Server port (default 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional env vars (no secrets) |
| `autoPort` | boolean | `true`: pick free port; `false`: fail on conflict |
| `program` | string | Script to run with `node` directly |
| `autoVerify` | boolean | Auto-screenshot and verify after edits (default true, set at top level) |

#### Enterprise configuration (Desktop)

- **Admin console**: toggle Code in desktop/web, Remote Control, bypass permissions mode
- **Managed settings keys**: `permissions.disableBypassPermissionsMode`, `disableAutoMode`, `autoMode`
- **Device management**: macOS via MDM (`com.anthropic.Claude`), Windows via registry (`SOFTWARE\Policies\Claude`)
- **Deployment**: macOS `.dmg` via MDM; Windows MSIX or `.exe` installer

### VS Code extension

#### Prerequisites and install

- VS Code 1.98.0+ (also works with Cursor)
- Install: Marketplace search "Claude Code" or `vscode:extension/anthropic.claude-code`
- Includes the CLI; no separate Node.js install needed

#### Key VS Code extension settings

| Setting | Default | Description |
| :--- | :--- | :--- |
| `useTerminal` | `false` | CLI-style interface instead of graphical panel |
| `initialPermissionMode` | `default` | Default mode for new conversations |
| `preferredLocation` | `panel` | Where Claude opens: `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `allowDangerouslySkipPermissions` | `false` | Adds Auto and Bypass modes to selector |
| `claudeProcessWrapper` | - | Executable path to launch Claude |

#### VS Code shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | Open in new tab |
| `Option+K` / `Alt+K` | Insert @-mention reference with line numbers |
| `Cmd+N` / `Ctrl+N` | New conversation (when Claude focused + setting enabled) |

#### Built-in IDE MCP server

- Auto-runs locally on `127.0.0.1` with random port and per-activation auth token
- Two model-visible tools: `mcp__ide__getDiagnostics` (read-only) and `mcp__ide__executeCode` (Jupyter; always prompts Execute/Cancel)
- Lock file at `~/.claude/ide/` with `0600` permissions

#### URI handler

```
vscode://anthropic.claude-code/open[?prompt=<url-encoded>&session=<id>]
```

Opens a new Claude Code tab in the focused VS Code window. Accepts optional `prompt` and `session` query params.

### JetBrains plugin

- Supports IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand
- Launch: `Cmd+Esc` / `Ctrl+Esc`, or run `claude` in integrated terminal
- External terminal: run `/ide` to connect to JetBrains
- Diff tool: `/config` then set to `auto` (IDE) or `terminal`
- WSL: set Claude command to `wsl -d Ubuntu -- bash -lic "claude"`
- Remote Development: install plugin in **remote host** via Settings > Plugin (Host)

### Chrome integration

- Requires Chrome or Edge + Claude in Chrome extension v1.0.36+ + Claude Code v2.0.73+
- CLI: `claude --chrome` or `/chrome` in session; VS Code: `@browser` in prompt box
- Capabilities: live debugging, design verification, web app testing, authenticated app interaction, data extraction, form automation, GIF recording
- Not available through third-party providers (Bedrock, Vertex, Foundry)
- Site permissions inherited from Chrome extension settings

### Computer use

- **What it does**: opens apps, clicks, types, scrolls, screenshots your actual desktop
- **CLI**: macOS only; enable `computer-use` MCP server via `/mcp`; requires Pro or Max plan
- **Desktop**: macOS and Windows; toggle in Settings > General
- **macOS permissions**: Accessibility + Screen Recording
- **App tiers**: browsers/trading = view-only; terminals/IDEs = click-only; everything else = full control
- **Safety**: per-app approval per session; terminal excluded from screenshots; global Esc abort; machine-wide lock (one session at a time)
- **Screenshots**: auto-downscaled (e.g. 3456x2234 Retina to ~1372x887)

### CLI vs Desktop feature comparison

| Feature | CLI | Desktop |
| :--- | :--- | :--- |
| Permission modes | All including `dontAsk` | All except `dontAsk` |
| Third-party providers | Bedrock, Vertex, Foundry | Anthropic API (Enterprise: Vertex + gateways) |
| Session isolation | `--worktree` flag | Automatic worktrees |
| Computer use | macOS only, via `/mcp` | macOS + Windows, via Settings |
| Scripting/automation | `--print`, Agent SDK | Not available |
| File attachments | Not available | Images, PDFs |
| Dispatch | Not available | Dispatch sessions in sidebar |
| Move CLI session to Desktop | `/desktop` command | - |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) — full Desktop reference: sessions, permission modes, workspace layout, terminal, file editor, preview servers, diff view, code review, PR monitoring, computer use, side chats, remote/SSH sessions, connectors, plugins, skills, enterprise config, CLI comparison, and troubleshooting.
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — installation walkthrough, first session guide, and next-steps overview for the Desktop app.
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — full VS Code extension reference: installation, prompt box, @-mentions, permission modes, plan review, checkpoints, plugins, Chrome automation, MCP servers, git workflows, settings, URI handler, terminal mode, and troubleshooting.
- [JetBrains IDEs](references/claude-code-jetbrains.md) — JetBrains plugin installation, IDE features (diff viewing, selection context, diagnostics), configuration, remote development, WSL setup, and troubleshooting.
- [Use Claude Code with Chrome](references/claude-code-chrome.md) — Chrome/Edge browser integration: setup, capabilities, example workflows (testing, debugging, form filling, data extraction, GIF recording), site permissions, and troubleshooting.
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — CLI computer use: enabling the MCP server, macOS permissions, per-app approval, safety guardrails, example workflows, Desktop vs CLI differences, and troubleshooting.

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
