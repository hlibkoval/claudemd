---
name: ide-doc
user-invocable: false
---

# IDE and Desktop Integration Documentation

This skill provides the complete official documentation for Claude Code's graphical interfaces: the Desktop app, VS Code extension, JetBrains plugin, Chrome browser integration, and computer use.

## Quick Reference

### Surface overview

| Surface | Platforms | Key entry point |
| :------ | :-------- | :-------------- |
| Desktop app — Code tab | macOS, Windows (not Linux) | Download from claude.ai/download; click Code tab |
| VS Code extension | VS Code, Cursor, Kiro, VSX forks | Install `anthropic.claude-code`; Spark icon in editor toolbar |
| JetBrains plugin | IntelliJ, PyCharm, WebStorm, GoLand, Android Studio, PhpStorm | Install from JetBrains Marketplace; run `claude` in integrated terminal |
| Claude in Chrome | Chrome and Edge (beta; not Brave/Arc/WSL) | Install Chrome extension v1.0.36+; use `--chrome` flag or `/chrome` |
| Computer use (CLI) | macOS only (CLI); macOS + Windows (Desktop) | Enable `computer-use` MCP server via `/mcp` (CLI) or Settings → General (Desktop) |

### Desktop app — permission modes

| Mode | Settings key | Behavior |
| :--- | :----------- | :------- |
| Ask permissions | `default` | Prompts before every file edit or command |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits and common FS commands; prompts for other terminal commands |
| Plan mode | `plan` | Reads/explores only; proposes plan without changing source |
| Auto | `auto` | Background safety checks; reduces prompts. Requires Opus 4.6+/Sonnet 4.6 (claude.ai); Opus 4.7/4.8 on Vertex AI |
| Bypass permissions | `bypassPermissions` | No prompts except forced ask rules. Enable in Settings → Claude Code. Sandboxed environments only. |

### Desktop app — keyboard shortcuts (macOS; use Ctrl in place of Cmd on Windows)

| Shortcut | Action |
| :------- | :----- |
| `Cmd+N` | New session |
| `Cmd+W` | Close session |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next/previous session |
| `Cmd+Shift+D` | Toggle diff pane |
| `Cmd+Shift+P` | Toggle preview pane |
| `Ctrl+`` ` `` ` | Toggle terminal pane |
| `Cmd+;` | Open side chat |
| `Ctrl+O` | Cycle transcript view modes (Normal/Verbose/Summary) |
| `Cmd+Shift+M` | Permission mode menu |
| `Cmd+Shift+I` | Model menu |
| `Cmd+/` | Show all keyboard shortcuts |
| `Esc` | Stop Claude's response |

### Desktop app — session environments

| Environment | Description |
| :---------- | :---------- |
| Local | Runs on your machine; full file and tool access |
| Remote (cloud) | Runs on Anthropic infrastructure; continues when app is closed; supports multiple repos |
| SSH | Runs on a remote machine; Desktop installs Claude Code there automatically; Linux/macOS remote only |

### Desktop app — `.claude/launch.json` (preview server config)

| Field | Type | Description |
| :---- | :--- | :---------- |
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (e.g., `npm`, `yarn`) |
| `runtimeArgs` | string[] | Arguments for the executable (e.g., `["run", "dev"]`) |
| `port` | number | Listen port; defaults to 3000 |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional env vars (no secrets — file is committed) |
| `autoPort` | boolean | `true` = pick free port; `false` = fail if port taken; omit = ask |
| `program` | string | Run a Node.js script directly (use instead of `runtimeExecutable`) |
| `args` | string[] | Arguments for `program` |
| `autoVerify` (top-level) | boolean | Auto-screenshots and checks after every edit; default `true` |

### Desktop app — enterprise managed settings keys

| Key | Description |
| :-- | :---------- |
| `permissions.disableBypassPermissionsMode` | `"disable"` prevents Bypass permissions mode |
| `disableAutoMode` | `"disable"` removes Auto from mode selector |
| `autoMode` | Customize classifier trust/block rules org-wide |
| `sshConfigs` | Pre-configure SSH connections; users cannot edit managed entries |
| `sshHostAllowlist` | Restrict SSH to matching hostnames; `[]` disables SSH sessions entirely |
| `managedMcpServers` | Push MCP server configs (third-party Desktop deployments only) |

### VS Code extension — extension settings

| Setting | Default | Description |
| :------ | :------ | :---------- |
| `useTerminal` | `false` | Launch in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | Starting permission mode: `default`, `plan`, `acceptEdits`, `bypassPermissions` |
| `preferredLocation` | `panel` | Where Claude opens: `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter to send instead of Enter |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N for new conversation |
| `enableReopenClosedSessionShortcut` | `true` | Cmd/Ctrl+Shift+T to reopen last closed Claude tab |
| `respectGitIgnore` | `true` | Exclude `.gitignore` patterns from file searches |
| `usePythonEnvironment` | `true` | Activate workspace Python environment (requires Python extension) |
| `allowDangerouslySkipPermissions` | `false` | Adds Bypass permissions to mode selector; sandboxes only |

### VS Code extension — keyboard shortcuts

| Shortcut | Action |
| :------- | :----- |
| `Cmd+Esc` / `Ctrl+Esc` | Toggle focus between editor and Claude |
| `Cmd+Shift+Esc` / `Ctrl+Shift+Esc` | Open new conversation as editor tab |
| `Option+K` / `Alt+K` | Insert @-mention reference for current selection |
| `Cmd+Shift+T` / `Ctrl+Shift+T` | Reopen most recently closed Claude session tab |

### VS Code extension — built-in IDE MCP tools (visible to model)

| Tool | Writes? | Description |
| :--- | :------ | :---------- |
| `mcp__ide__getDiagnostics` | No | Returns language-server errors/warnings (VS Code Problems panel) |
| `mcp__ide__executeCode` | Yes | Runs Python in active Jupyter notebook; always shows a confirmation Quick Pick first |

### JetBrains plugin — key shortcuts and settings

| Item | Value |
| :--- | :---- |
| Quick launch | `Cmd+Esc` (Mac) / `Ctrl+Esc` (Win/Linux) |
| File reference shortcut | `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Win/Linux) |
| Connect external terminal | Run `/ide` inside Claude Code |
| Diff tool setting | `/config` → set diff tool to `auto` (IDE) or `terminal` |
| Plugin settings path | Settings → Tools → Claude Code [Beta] |
| Remote development | Install plugin in the **remote host**, not local client |
| WSL2 fix | Allow WSL2 subnet in Windows Firewall, or set `networkingMode=mirrored` in `.wslconfig` |

### Chrome integration

| Item | Value |
| :--- | :---- |
| CLI flag | `claude --chrome` |
| Toggle in session | `/chrome` |
| Enable by default | Run `/chrome` → "Enabled by default" |
| Required extension version | Claude in Chrome v1.0.36+ |
| Required Claude Code version | v2.0.73+ |
| Supported browsers | Google Chrome and Microsoft Edge |
| Not supported | Brave, Arc, other Chromium browsers, WSL |
| Not available via | Third-party providers (Bedrock, Vertex AI, Foundry) |
| VS Code usage | Type `@browser` in the prompt box |

### Computer use

| Item | CLI | Desktop |
| :--- | :-- | :------ |
| Platforms | macOS only | macOS and Windows |
| Enable | Enable `computer-use` in `/mcp` | Settings → General → Computer use toggle |
| macOS permissions needed | Accessibility + Screen Recording | Same |
| App approval duration | Per session | Per session (30 min for Dispatch-spawned) |
| Denied apps list | Not yet available | Configurable in Settings |
| Abort | `Esc` or `Ctrl+C` | `Esc` or `Ctrl+C` |
| Required plan | Pro or Max (not Team/Enterprise) | Pro or Max (not Team/Enterprise) |
| Not available via | Third-party providers | N/A |

### Computer use — app control tiers (fixed; cannot be changed)

| Tier | What Claude can do | Applies to |
| :--- | :----------------- | :--------- |
| View only | See app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, no typing | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

### Desktop CLI flag equivalents

| CLI flag | Desktop equivalent |
| :------- | :----------------- |
| `--model` | Model dropdown next to send button |
| `--resume`, `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (enable in Settings → Claude Code) |
| `--add-dir` | Add repos with + button in cloud sessions |
| `--verbose` | Verbose view mode in Transcript view dropdown |
| `--print`, `--output-format` | Not available (Desktop is interactive only) |
| `MAX_THINKING_TOKENS` env var | Local environment editor in prompt box |

### Shared config (Desktop and CLI)

Desktop and CLI read the same files: `CLAUDE.md`/`CLAUDE.local.md`, MCP servers in `~/.claude.json`/`.mcp.json`, hooks, skills, and `~/.claude/settings.json`. The Desktop app also loads MCP servers from `claude_desktop_config.json`; the standalone CLI does not.

### Session worktrees (Desktop)

Each Desktop session gets its own Git worktree stored in `<project-root>/.claude/worktrees/` by default. Change the location in Settings → Claude Code → "Worktree location". Use `.worktreeinclude` in project root to copy gitignored files (e.g., `.env`) into new worktrees.

## Full Documentation

For the complete official documentation, see the reference files:

- [Desktop app reference](references/claude-code-desktop.md) — Full Desktop Code tab reference: sessions, permission modes, diff view, preview servers, workspace layout, computer use, enterprise configuration, CLI comparison
- [Desktop quickstart](references/claude-code-desktop-quickstart.md) — Install, first session walkthrough, and "now what" guide for new Desktop users
- [VS Code extension](references/claude-code-vs-code.md) — Installation, prompt box features, @-mentions, session history, plugin management, MCP, IDE MCP server internals, third-party providers, troubleshooting
- [JetBrains plugin](references/claude-code-jetbrains.md) — Installation, features, configuration, remote development, WSL2 setup, troubleshooting
- [Chrome integration](references/claude-code-chrome.md) — Setup, capabilities, example workflows (debugging, form fill, data extraction, GIF recording), troubleshooting
- [Computer use (CLI)](references/claude-code-computer-use.md) — Enable, approve apps, how screenshots/locking work, safety guardrails, example workflows, differences from Desktop

## Sources

- Desktop app reference: https://code.claude.com/docs/en/desktop.md
- Desktop quickstart: https://code.claude.com/docs/en/desktop-quickstart.md
- VS Code extension: https://code.claude.com/docs/en/vs-code.md
- JetBrains plugin: https://code.claude.com/docs/en/jetbrains.md
- Chrome integration: https://code.claude.com/docs/en/chrome.md
- Computer use (CLI): https://code.claude.com/docs/en/computer-use.md
