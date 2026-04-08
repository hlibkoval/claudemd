---
name: ide-doc
description: Complete documentation for using Claude Code across IDE surfaces -- Desktop app (macOS/Windows), VS Code extension, JetBrains plugin, Chrome browser integration, and computer use. Covers Desktop quickstart (install, Code tab, sessions, diff view, permission modes, PR monitoring, auto-fix, auto-merge, preview servers, launch.json, connectors, plugins, scheduled tasks, SSH sessions, remote sessions, Dispatch, worktrees, enterprise configuration, MDM policies), VS Code extension (install, prompt box, @-mentions, permission modes, plan mode, auto-accept, command palette, keyboard shortcuts, URI handler, settings, plugins, checkpoints, IDE MCP server, getDiagnostics, executeCode, Jupyter, terminal mode, resume remote sessions), JetBrains plugin (IntelliJ, PyCharm, WebStorm, GoLand, PhpStorm, Android Studio, diff viewing, selection context, file references, diagnostics, plugin settings, ESC key, remote development, WSL), Chrome integration (browser automation, @browser, live debugging, design verification, console logs, form filling, data extraction, GIF recording, site permissions, native messaging host, reconnect), and computer use (macOS screen control, app permissions, per-app approval, Accessibility, Screen Recording, view-only/click-only/full-control tiers, lock file, escape to stop). Load when discussing Claude Code Desktop, VS Code extension, JetBrains plugin, Chrome browser integration, computer use, IDE integration, diff view, permission modes, preview servers, launch.json, SSH sessions, remote sessions, worktrees, connectors, Dispatch, @-mentions, checkpoints, IDE MCP server, mcp__ide__getDiagnostics, mcp__ide__executeCode, Jupyter, app permissions, native messaging host, or any IDE/surface-related topic for Claude Code.
user-invocable: false
---

# IDE & Surface Documentation

This skill provides the complete official documentation for using Claude Code across all IDE surfaces: the Desktop app, VS Code extension, JetBrains plugin, Chrome browser integration, and computer use.

## Quick Reference

### Surface Comparison

| Surface | Platforms | Install method | Key differentiator |
|:--------|:----------|:---------------|:-------------------|
| Desktop app | macOS, Windows | Download from claude.ai | Visual diff review, PR monitoring, preview, Dispatch, scheduled tasks |
| VS Code extension | macOS, Windows, Linux | Marketplace (`anthropic.claude-code`) | Native IDE integration, inline diffs, @-mentions with line ranges |
| JetBrains plugin | macOS, Windows, Linux | JetBrains Marketplace | Diff viewing, selection context, diagnostic sharing |
| Chrome integration | macOS, Windows, Linux | Chrome Web Store (`claude-in-chrome`) | Browser automation, console reading, form filling |
| Computer use | macOS (CLI), macOS + Windows (Desktop) | Built-in MCP server | Native app control, screen interaction, GUI automation |

### Desktop App

#### Tabs

| Tab | Purpose |
|:----|:--------|
| Chat | General conversation, no file access (like claude.ai) |
| Cowork | Autonomous background agent on cloud VM (includes Dispatch) |
| Code | Interactive coding assistant with local file access |

#### Permission Modes

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Asks before editing files or running commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits, asks before terminal commands |
| Plan mode | `plan` | Analyzes and plans without modifying files |
| Auto | `auto` | Background safety checks, reduced prompts (Team/Enterprise/API, Sonnet 4.6+/Opus 4.6+) |
| Bypass permissions | `bypassPermissions` | No prompts, equivalent to `--dangerously-skip-permissions` (sandboxed environments only) |

#### Environment Types

| Environment | Description |
|:------------|:-----------|
| Local | Runs on your machine with direct file access |
| Remote | Runs on Anthropic cloud, persists when app closes |
| SSH | Connects to remote machine you manage over SSH |

#### Preview Server Configuration (`.claude/launch.json`)

| Field | Type | Description |
|:------|:-----|:-----------|
| `name` | string | Unique identifier for the server |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments for runtimeExecutable |
| `port` | number | Server port (default: 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables |
| `autoPort` | boolean | `true` = find free port; `false` = fail on conflict |
| `program` | string | Script to run with `node` directly |
| `args` | string[] | Arguments for `program` |
| `autoVerify` | boolean | Auto-verify changes after edits (default: true, set at top level) |

#### Desktop CLI Flag Equivalents

| CLI flag | Desktop equivalent |
|:---------|:-------------------|
| `--model sonnet` | Model dropdown next to send button |
| `--resume`, `--continue` | Click session in sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (Settings) |
| `--add-dir` | **+** button in remote sessions |
| `/desktop` | CLI command to move session to Desktop |

#### Enterprise Configuration

| Mechanism | Purpose |
|:----------|:--------|
| Admin console | Enable/disable Code tab, web sessions, Remote Control, Bypass mode |
| `permissions.disableBypassPermissionsMode` | Prevent Bypass mode in managed settings |
| `disableAutoMode` | Remove Auto mode from selector |
| MDM (macOS) | `com.anthropic.Claude` preference domain |
| Group Policy (Windows) | Registry at `SOFTWARE\Policies\Claude` |

### VS Code Extension

#### Requirements

- VS Code 1.98.0 or higher
- Anthropic account (Pro, Max, Team, or Enterprise)

#### Keyboard Shortcuts

| Command | Shortcut (Mac) | Shortcut (Win/Linux) |
|:--------|:---------------|:---------------------|
| Focus Input (toggle) | `Cmd+Esc` | `Ctrl+Esc` |
| Open in New Tab | `Cmd+Shift+Esc` | `Ctrl+Shift+Esc` |
| New Conversation | `Cmd+N` | `Ctrl+N` |
| Insert @-Mention | `Option+K` | `Alt+K` |

#### Extension Settings

| Setting | Default | Description |
|:--------|:--------|:-----------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | Launch in terminal mode instead of panel |
| `initialPermissionMode` | `default` | Default permission mode (`default`, `plan`, `acceptEdits`, `bypassPermissions`) |
| `preferredLocation` | `panel` | Where Claude opens (`sidebar` or `panel`) |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from searches |
| `disableLoginPrompt` | `false` | Skip auth prompts (third-party providers) |
| `allowDangerouslySkipPermissions` | `false` | Add Auto/Bypass modes to selector |
| `claudeProcessWrapper` | -- | Executable path to launch the Claude process |

#### URI Handler

Open Claude Code tabs from external tools via `vscode://anthropic.claude-code/open`:

| Parameter | Description |
|:----------|:-----------|
| `prompt` | URL-encoded text to pre-fill in prompt box (not auto-submitted) |
| `session` | Session ID to resume (falls back to new conversation if not found) |

#### Built-in IDE MCP Server

The extension runs a local MCP server (`ide`) on `127.0.0.1` with random port and per-activation auth token.

| Tool name | What it does | Writes? |
|:----------|:-------------|:--------|
| `mcp__ide__getDiagnostics` | Returns language-server diagnostics (errors/warnings from Problems panel) | No |
| `mcp__ide__executeCode` | Runs Python code in active Jupyter notebook kernel (requires user confirmation) | Yes |

#### VS Code vs CLI Feature Differences

| Feature | CLI | VS Code Extension |
|:--------|:----|:------------------|
| Commands and skills | All | Subset (type `/` to see) |
| MCP server config | Yes | Partial (add via CLI, manage with `/mcp`) |
| Checkpoints | Yes | Yes |
| `!` bash shortcut | Yes | No |
| Tab completion | Yes | No |

### JetBrains Plugin

#### Supported IDEs

IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand

#### Keyboard Shortcuts

| Action | Mac | Windows/Linux |
|:-------|:----|:--------------|
| Open Claude Code | `Cmd+Esc` | `Ctrl+Esc` |
| Insert file reference | `Cmd+Option+K` | `Alt+Ctrl+K` |

#### Plugin Settings (Settings > Tools > Claude Code)

| Setting | Description |
|:--------|:-----------|
| Claude command | Custom path to `claude` executable |
| Suppress notification | Skip "command not found" notifications |
| Option+Enter for multi-line | macOS only, insert new lines in prompts |
| Automatic updates | Auto-check and install plugin updates |

#### Special Configurations

- **Remote Development**: install plugin in remote host via Settings > Plugin (Host)
- **WSL**: may need terminal, networking, and firewall configuration
- **ESC key**: if ESC doesn't interrupt, uncheck "Move focus to the editor with Escape" in Settings > Tools > Terminal

### Chrome Integration (Beta)

#### Requirements

- Google Chrome or Microsoft Edge
- Claude in Chrome extension v1.0.36+
- Claude Code v2.0.73+
- Direct Anthropic plan (not third-party providers)

#### Capabilities

| Capability | Description |
|:-----------|:-----------|
| Live debugging | Read console errors/DOM, fix code |
| Design verification | Build UI, verify in browser |
| Web app testing | Form validation, visual regressions, user flows |
| Authenticated apps | Google Docs, Gmail, Notion via existing login |
| Data extraction | Pull structured data from pages |
| Task automation | Form filling, multi-site workflows |
| GIF recording | Record browser interactions |

#### CLI Usage

```
claude --chrome         # Start with Chrome enabled
/chrome                 # Enable/check status within session
```

In VS Code, use `@browser` in the prompt box.

#### Native Messaging Host Paths (Chrome)

| Platform | Path |
|:---------|:-----|
| macOS | `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` |
| Linux | `~/.config/google-chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` |
| Windows | Registry: `HKCU\Software\Google\Chrome\NativeMessagingHosts\` |

#### Common Errors

| Error | Fix |
|:------|:----|
| "Browser extension is not connected" | Restart Chrome and Claude Code, run `/chrome` to reconnect |
| "Extension not detected" | Install/enable extension in `chrome://extensions` |
| "No tab available" | Ask Claude to create a new tab and retry |
| "Receiving end does not exist" | Run `/chrome` > "Reconnect extension" (service worker went idle) |

### Computer Use

#### Requirements

- Pro or Max plan (not Team or Enterprise)
- macOS (CLI) or macOS + Windows (Desktop)
- Claude Code v2.1.85+ (CLI)
- Interactive session (not `-p` flag)

#### Enable

| Surface | Method |
|:--------|:-------|
| CLI | `/mcp` > enable `computer-use` server |
| Desktop | Settings > General > Computer use toggle |
| macOS | Also grant Accessibility + Screen Recording permissions |

#### App Permission Tiers

| Tier | What Claude can do | Applies to |
|:-----|:-------------------|:-----------|
| View only | See app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, no typing | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

#### Safety Guardrails

- Per-app approval each session (30 min in Dispatch sessions)
- Sentinel warnings for shell/filesystem/settings access
- Terminal excluded from screenshots
- Global `Esc` key abort
- Machine-wide lock (one session at a time)

#### CLI vs Desktop Differences

| Feature | Desktop | CLI |
|:--------|:--------|:----|
| Platforms | macOS and Windows | macOS only |
| Enable | Settings > General toggle | `/mcp` > enable `computer-use` |
| Denied apps list | Configurable in Settings | Not yet available |
| Auto-unhide | Optional toggle | Always on |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- Full Desktop reference: permission modes, sessions, worktrees, diff view, preview servers, computer use, connectors, plugins, SSH, remote, Dispatch, enterprise config, troubleshooting
- [Get started with the Desktop app](references/claude-code-desktop-quickstart.md) -- Desktop quickstart: install, Code tab, first session, review changes
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) -- VS Code extension: install, prompt box, @-mentions, keyboard shortcuts, settings, plugins, checkpoints, IDE MCP server, git workflows, third-party providers, troubleshooting
- [JetBrains IDEs](references/claude-code-jetbrains.md) -- JetBrains plugin: supported IDEs, installation, configuration, remote development, WSL, troubleshooting
- [Use Claude Code with Chrome](references/claude-code-chrome.md) -- Chrome integration: browser automation, capabilities, example workflows, site permissions, troubleshooting
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) -- Computer use in CLI: enable, app approval, permission tiers, safety, example workflows, troubleshooting

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the Desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
