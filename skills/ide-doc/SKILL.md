---
name: ide-doc
description: Complete official documentation for Claude Code IDE integrations — Desktop app (macOS/Windows), VS Code extension, JetBrains plugin, Chrome browser automation, and computer use (screen control).
user-invocable: false
---

# IDE Integrations Documentation

This skill provides the complete official documentation for Claude Code IDE and surface integrations: Desktop app, VS Code extension, JetBrains plugin, Chrome browser automation, and computer use.

## Quick Reference

### Surfaces at a glance

| Surface | Platforms | Install | Key differentiator |
| :--- | :--- | :--- | :--- |
| **Desktop app** | macOS, Windows | [Download](https://claude.com/download) | Parallel sessions with Git worktree isolation, drag-and-drop pane layout, live preview, PR monitoring, computer use, Dispatch, scheduled tasks, connectors |
| **VS Code extension** | macOS, Windows, Linux | [Marketplace](vscode:extension/anthropic.claude-code) (also works in Cursor) | Inline diffs, @-mentions with line ranges, plan review, checkpoints, multiple tabs, built-in IDE MCP server |
| **JetBrains plugin** | macOS, Windows, Linux | [JetBrains Marketplace](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-) | Works with IntelliJ, PyCharm, WebStorm, GoLand, PhpStorm, Android Studio; diff viewing, selection context, diagnostic sharing |
| **Chrome extension** | macOS, Windows, Linux | [Chrome Web Store](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) (v1.0.36+; also works in Edge) | Browser automation from CLI or VS Code; shares login state; GIF recording |
| **Computer use** | macOS (CLI), macOS + Windows (Desktop) | Built-in MCP server (`computer-use`) | GUI control of native apps, simulators, and tools without APIs |

### Permission modes

All surfaces share the same mode set (with minor availability differences):

| Mode | Settings key | Behavior |
| :--- | :--- | :--- |
| **Ask permissions** | `default` | Asks before edits and commands. Not available in remote sessions. |
| **Auto accept edits** | `acceptEdits` | Auto-accepts file edits; asks for terminal commands. |
| **Plan mode** | `plan` | Read-only exploration, then proposes a plan. |
| **Auto** | `auto` | All actions with background safety checks. Research preview; plan/model restrictions apply. |
| **Bypass permissions** | `bypassPermissions` | No prompts. Use only in sandboxed environments. |
| **dontAsk** | `dontAsk` | CLI only. Pre-approved tool allowlist. |

### Desktop app

**Environments**: Local, Remote (Anthropic cloud, persists after close), SSH (your servers/VMs/devcontainers).

**Session isolation**: each session gets its own Git worktree under `<project-root>/.claude/worktrees/`. Configurable worktree location and branch prefix in Settings.

**Workspace panes** (drag to rearrange):

| Pane | Open with |
| :--- | :--- |
| Chat | Default |
| Diff | `Cmd+Shift+D` / stats indicator |
| Preview | `Cmd+Shift+P` / Preview dropdown |
| Terminal | `` Ctrl+` `` (local only) |
| File | Click a file path |
| Plan, Tasks, Subagent | Views menu |

**View modes** (cycle with `Ctrl+O`): Normal, Verbose, Summary.

**Preview servers**: configured in `.claude/launch.json`.

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Args for the executable |
| `port` | number | Server port (default 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Extra environment variables |
| `autoPort` | boolean | `true` = find free port; `false` = fail on conflict |
| `program` | string | Script to run with `node` directly |
| `args` | string[] | Args for `program` |
| `autoVerify` | boolean | Auto-verify changes after edits (default `true`, set at root level) |

**PR monitoring**: CI status bar with Auto-fix and Auto-merge toggles. Requires `gh` CLI. Auto-archive on PR merge/close available in Settings.

**Side chats**: `Cmd+;` / `Ctrl+;` or `/btw`. Reads main thread context without adding to it.

**Continue in**: move session to Claude Code on the Web or open project in an IDE.

**Connectors**: Google Calendar, Slack, GitHub, Linear, Notion, etc. via `+` button. MCP servers with graphical setup.

**Key Desktop shortcuts** (macOS; swap `Cmd` for `Ctrl` on Windows):

| Shortcut | Action |
| :--- | :--- |
| `Cmd+N` | New session |
| `Cmd+W` | Close session |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Cycle sessions |
| `Esc` | Stop response |
| `Cmd+Shift+D` | Toggle diff |
| `Cmd+Shift+P` | Toggle preview |
| `Cmd+;` | Side chat |
| `Ctrl+O` | Cycle view modes |
| `Cmd+Shift+M` | Permission mode menu |
| `Cmd+Shift+I` | Model menu |

### VS Code extension

**Prerequisites**: VS Code 1.98.0+, Anthropic account (or third-party provider with `disableLoginPrompt`).

**Open Claude**: Spark icon in Editor Toolbar, Activity Bar, Command Palette (`Cmd+Shift+P` > "Claude Code"), or Status Bar.

**Key shortcuts**:

| Shortcut | Action |
| :--- | :--- |
| `Cmd+Esc` / `Ctrl+Esc` | Toggle focus editor/Claude |
| `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | Open in new tab |
| `Option+K` / `Alt+K` | Insert @-mention with file + line range |
| `Cmd+N` / `Ctrl+N` | New conversation (requires `enableNewConversationShortcut`) |

**Extension settings** (in VS Code `Settings > Extensions > Claude Code`):

| Setting | Default | Effect |
| :--- | :--- | :--- |
| `useTerminal` | `false` | CLI mode instead of graphical panel |
| `initialPermissionMode` | `default` | Starting mode for new conversations |
| `preferredLocation` | `panel` | `sidebar` or `panel` (new tab) |
| `autosave` | `true` | Auto-save before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Ctrl/Cmd+Enter to send |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns |
| `allowDangerouslySkipPermissions` | `false` | Show Auto/Bypass modes in selector |
| `disableLoginPrompt` | `false` | Skip auth (third-party providers) |

**URI handler**: `vscode://anthropic.claude-code/open` with optional `prompt` and `session` query params.

**Built-in IDE MCP server**: local-only server on `127.0.0.1` (random port, auth token in `~/.claude/ide/`). Two model-visible tools: `mcp__ide__getDiagnostics` (read-only) and `mcp__ide__executeCode` (Jupyter cells, always asks via Quick Pick).

**Checkpoints**: hover any message to rewind -- fork conversation, rewind code, or both.

**Plugins**: `/plugins` opens graphical install/manage UI. Install scope: user, project, or local.

**Resume remote sessions**: Session history > Remote tab shows claude.ai web sessions.

### JetBrains plugin

**Supported IDEs**: IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand.

**Features**: quick launch (`Cmd+Esc` / `Ctrl+Esc`), IDE diff viewer, selection context, file reference shortcuts (`Cmd+Option+K` / `Alt+Ctrl+K`), diagnostic sharing.

**Plugin settings** (`Settings > Tools > Claude Code`): custom Claude command path, Option+Enter for multi-line, automatic updates.

**Remote Development**: install plugin in remote host via `Settings > Plugin (Host)`.

**WSL**: may need networking/firewall adjustments; see troubleshooting guide.

**Connect from external terminal**: run `claude` then `/ide`.

### Chrome integration

**Requirements**: Chrome or Edge, Claude in Chrome extension v1.0.36+, Claude Code v2.0.73+, direct Anthropic plan. Not available via third-party providers.

**CLI launch**: `claude --chrome` or `/chrome` during session. Enable by default via `/chrome` > "Enabled by default".

**VS Code**: type `@browser` in prompt box.

**Capabilities**: live debugging (console errors + DOM), design verification, web app testing, authenticated app interaction, data extraction, form automation, multi-site workflows, GIF recording.

**Site permissions**: managed in Chrome extension settings.

**Key troubleshooting**: if "Extension not detected", restart Chrome and run `/chrome` to reconnect. Native messaging host config at `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` (macOS).

### Computer use

**Availability**: Pro/Max plans only. CLI: macOS only (v2.1.85+, interactive sessions). Desktop: macOS + Windows.

**Enable (CLI)**: `/mcp` > enable `computer-use`. Grant Accessibility + Screen Recording on macOS.

**Enable (Desktop)**: `Settings > General > Computer use` toggle. Grant macOS permissions.

**Tool selection order** (most precise first): Connector > Bash > Chrome > Computer use.

**App permission tiers**:

| Tier | Can do | Applies to |
| :--- | :--- | :--- |
| View only | See in screenshots | Browsers, trading platforms |
| Click only | Click and scroll | Terminals, IDEs |
| Full control | Click, type, drag, shortcuts | Everything else |

**Safety guardrails**: per-app approval per session, sentinel warnings for shell/filesystem/settings apps, terminal excluded from screenshots, global Esc abort, machine-wide lock (one session at a time).

**CLI vs Desktop differences**:

| | Desktop | CLI |
| :--- | :--- | :--- |
| Platforms | macOS, Windows | macOS only |
| Enable | Settings toggle | `/mcp` > `computer-use` |
| Denied apps | Configurable | Not available |

### Enterprise configuration (Desktop)

**Admin console**: control Code in desktop, Code in web, Remote Control, bypass permissions mode.

**Managed settings keys**: `permissions.disableBypassPermissionsMode`, `disableAutoMode`, `autoMode`.

**Device management**: macOS via MDM (`com.anthropic.Claude`), Windows via registry (`SOFTWARE\Policies\Claude`).

**Deployment**: macOS `.dmg` via MDM, Windows MSIX or `.exe`.

### CLI vs Desktop feature comparison

| Feature | CLI | Desktop |
| :--- | :--- | :--- |
| Permission modes | All including `dontAsk` | All except `dontAsk` |
| Third-party providers | Bedrock, Vertex, Foundry | Anthropic API (enterprise: Vertex, gateways) |
| MCP servers | Settings files | Connectors UI + settings files |
| Session isolation | `--worktree` flag | Automatic worktrees |
| Computer use | macOS only via `/mcp` | macOS + Windows via Settings |
| Dispatch | Not available | Sidebar integration |
| Scripting | `--print`, Agent SDK | Not available |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) — full reference for the Desktop app: sessions, permission modes, workspace layout, preview servers, diff review, PR monitoring, side chats, computer use, Dispatch, connectors, plugins, environment configuration (local/remote/SSH), enterprise configuration, CLI comparison, and troubleshooting.
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — installation walkthrough, first session guide, and next-steps overview for the Desktop Code tab.
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — VS Code extension installation, prompt box features, @-mentions, session history, multiple conversations, plugin management, Chrome browser automation, commands/shortcuts, extension settings, IDE MCP server, checkpoints, third-party providers, and troubleshooting.
- [JetBrains IDEs](references/claude-code-jetbrains.md) — JetBrains plugin installation, supported IDEs, features (diff viewing, selection context, diagnostics), plugin settings, remote development, WSL configuration, and troubleshooting.
- [Use Claude Code with Chrome](references/claude-code-chrome.md) — Chrome/Edge browser automation setup, capabilities (debugging, testing, form filling, data extraction, GIF recording), site permissions, example workflows, and troubleshooting.
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — CLI computer use setup on macOS, per-app approval, screen control flow, safety guardrails, example workflows, and differences from Desktop.

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
