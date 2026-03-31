---
name: ide-doc
description: Complete documentation for Claude Code IDE and desktop integrations -- Desktop app (Code tab with visual diff review, live app preview, computer use, PR monitoring with auto-fix/auto-merge, parallel sessions with Git worktree isolation, Dispatch integration, scheduled tasks, connectors, remote/SSH/local environments, enterprise MDM/SSO/managed settings), VS Code extension (install, graphical panel, @-mentions with fuzzy matching and line ranges, permission modes default/plan/acceptEdits/auto/bypassPermissions, resume conversations local and remote, multiple tabs/windows, terminal mode, plugins UI, Chrome browser automation via @browser, checkpoints with fork/rewind, IDE MCP server with getDiagnostics and executeCode, URI handler vscode://anthropic.claude-code/open, extension settings selectedModel/useTerminal/initialPermissionMode/preferredLocation/autosave/useCtrlEnterToSend/claudeProcessWrapper, git worktrees, third-party providers Bedrock/Vertex/Foundry), JetBrains plugin (IntelliJ/PyCharm/WebStorm/GoLand/PhpStorm/Android Studio, Cmd+Esc quick launch, diff viewing, selection context, file reference shortcuts Cmd+Option+K, diagnostic sharing, remote development host install, WSL configuration, ESC key fix), Chrome integration (Claude in Chrome extension, --chrome flag, /chrome command, browser automation capabilities live debugging/design verification/web app testing/authenticated apps/data extraction/task automation/GIF recording, site permissions, native messaging host paths, Edge support), and computer use from CLI (macOS research preview, enable via /mcp computer-use server, Accessibility and Screen Recording permissions, per-app session approval, app permission tiers view-only/click-only/full-control, machine-wide lock, Esc to stop, safety guardrails). Load when discussing Claude Code Desktop app, Code tab, desktop quickstart, VS Code extension, JetBrains plugin, IntelliJ plugin, Chrome integration, browser automation, @browser, computer use, screen control, diff view, app preview, launch.json, PR monitoring, auto-merge, auto-fix, parallel sessions, worktrees in desktop, scheduled tasks in desktop, Dispatch, connectors, SSH sessions, remote sessions, permission modes in desktop/IDE, enterprise desktop configuration, MDM policies, VS Code commands, extension settings, IDE MCP server, getDiagnostics, executeCode, checkpoints, terminal mode, @-mentions in VS Code, plugin management UI, URI handler, /desktop command, /ide command, computer-use MCP server, or any IDE/desktop integration topic for Claude Code.
user-invocable: false
---

# IDE and Desktop Integrations Documentation

This skill provides the complete official documentation for Claude Code's IDE and desktop integrations -- the Desktop app, VS Code extension, JetBrains plugin, Chrome browser integration, and computer use.

## Quick Reference

### Desktop App (Code Tab)

The Desktop app provides Claude Code through a graphical interface with three tabs: Chat (general conversation), Cowork (autonomous background agent), and Code (interactive coding with local file access).

**Starting a session -- configure before sending:**

| Setting | Options |
|:--------|:--------|
| Environment | Local (your machine), Remote (Anthropic cloud), SSH (your remote server) |
| Project folder | Select working directory; remote sessions support multiple repos |
| Model | Sonnet, Opus, Haiku -- locked once session starts |
| Permission mode | Changeable during session |

**Permission modes:**

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Asks before edits and commands (recommended for new users) |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits, asks before terminal commands |
| Plan mode | `plan` | Analyzes and plans without modifying files |
| Auto | `auto` | Background safety checks, reduces prompts. Team/Enterprise/API plans, Sonnet 4.6+ or Opus 4.6+ |
| Bypass permissions | `bypassPermissions` | No prompts. Enable in Settings. Only for sandboxed environments |

**Desktop-exclusive features:**

| Feature | Description |
|:--------|:------------|
| Visual diff review | Side-by-side diffs with inline commenting (Cmd/Ctrl+Enter to submit all comments) |
| Review code | Claude evaluates diffs for compile errors, logic errors, security vulnerabilities |
| Live app preview | Embedded browser for dev servers, auto-verify after edits, configured via `.claude/launch.json` |
| PR monitoring | CI status bar with auto-fix (fixes failing checks) and auto-merge (squash merge when checks pass) |
| Parallel sessions | Each session gets isolated Git worktree in `<project>/.claude/worktrees/` |
| Dispatch | Tasks from phone/Cowork tab spawn Code sessions with push notifications |
| Scheduled tasks | Local (machine, needs app open) or Remote (cloud, runs independently) |
| Connectors | Google Calendar, Slack, GitHub, Linear, Notion via + button |
| Computer use | macOS only, Pro/Max plan, control apps and screen |

**Preview server configuration (`.claude/launch.json`):**

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (npm, yarn, node) |
| `runtimeArgs` | string[] | Arguments for the command |
| `port` | number | Server port (default 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables |
| `autoPort` | boolean | true = find free port; false = fail on conflict; unset = ask |
| `program` | string | Node.js script to run directly |
| `autoVerify` | boolean | Top-level field; auto-verify changes after edits (default true) |

**Scheduled tasks frequency options:** Manual, Hourly (with stagger offset), Daily, Weekdays, Weekly. Custom intervals via natural language in a session.

**CLI to Desktop:** run `/desktop` in terminal to move session to Desktop app.

### VS Code Extension

**Installation:** search "Claude Code" in Extensions view or use `vscode:extension/anthropic.claude-code`. Also works with Cursor (`cursor:extension/anthropic.claude-code`). Requires VS Code 1.98.0+.

**Opening Claude Code:**

| Method | How |
|:-------|:----|
| Editor Toolbar | Spark icon top-right (requires file open) |
| Activity Bar | Spark icon in left sidebar |
| Command Palette | Cmd/Ctrl+Shift+P, type "Claude Code" |
| Status Bar | Click "Claude Code" bottom-right |

**Key shortcuts:**

| Command | Shortcut | Description |
|:--------|:---------|:------------|
| Focus Input | Cmd/Ctrl+Esc | Toggle focus between editor and Claude |
| Open in New Tab | Cmd/Ctrl+Shift+Esc | New conversation as editor tab |
| New Conversation | Cmd/Ctrl+N | Start new conversation (Claude focused) |
| Insert @-Mention | Option/Alt+K | Insert file reference with line numbers |

**@-mentions:** Type `@` + filename for fuzzy matching. Supports folders with trailing slash. Automatically sees selected text. `@terminal:name` references terminal output.

**URI handler:** `vscode://anthropic.claude-code/open` with optional `prompt` and `session` query parameters.

**Extension settings:**

| Setting | Default | Description |
|:--------|:--------|:------------|
| `selectedModel` | `default` | Model for new conversations |
| `useTerminal` | `false` | Terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | Default permission mode |
| `preferredLocation` | `panel` | Where Claude opens: `sidebar` or `panel` |
| `autosave` | `true` | Auto-save files before Claude reads/writes |
| `useCtrlEnterToSend` | `false` | Ctrl/Cmd+Enter to send instead of Enter |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from searches |
| `allowDangerouslySkipPermissions` | `false` | Show Auto and Bypass modes in selector |
| `claudeProcessWrapper` | - | Executable path to launch Claude process |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party providers) |

**Built-in IDE MCP server:** Runs automatically when extension is active. Binds to `127.0.0.1` on random port with per-activation auth token. Token stored in `~/.claude/ide/` with 0600 permissions.

| Tool | Description | Writes? |
|:-----|:------------|:--------|
| `mcp__ide__getDiagnostics` | Returns language-server diagnostics (errors/warnings from Problems panel) | No |
| `mcp__ide__executeCode` | Runs Python code in active Jupyter notebook kernel (with Quick Pick confirmation) | Yes |

**Checkpoints (rewind):** Hover any message for rewind button with three options: Fork conversation, Rewind code, Fork and rewind.

**Resume remote sessions:** Past Conversations dropdown has Local and Remote tabs. Remote tab shows sessions from claude.ai (GitHub-repo sessions only).

### JetBrains Plugin

**Supported IDEs:** IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand.

**Features:**

| Feature | Shortcut / Detail |
|:--------|:------------------|
| Quick launch | Cmd+Esc (Mac) / Ctrl+Esc (Win/Linux) |
| File references | Cmd+Option+K (Mac) / Alt+Ctrl+K (Win/Linux) |
| Diff viewing | Changes displayed in IDE diff viewer |
| Selection context | Current selection/tab automatically shared |
| Diagnostic sharing | IDE lint/syntax errors shared automatically |

**Plugin settings:** Settings > Tools > Claude Code. Configure custom command path, Option+Enter for multi-line, automatic updates.

**Remote Development:** Plugin must be installed on the remote host via Settings > Plugin (Host).

**WSL:** May need additional config for terminal, networking mode, and firewall settings.

### Chrome Integration (Beta)

**Requirements:** Chrome or Edge, Claude in Chrome extension v1.0.36+, Claude Code v2.0.73+, direct Anthropic plan. Not available via Bedrock/Vertex/Foundry.

**Enable:** `claude --chrome` or `/chrome` within a session. In VS Code, use `@browser` prefix. Enable by default via `/chrome` > "Enabled by default".

**Capabilities:** Live debugging, design verification, web app testing, authenticated app interaction, data extraction, task automation, GIF recording.

**Native messaging host paths (Chrome):**

| Platform | Path |
|:---------|:-----|
| macOS | `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` |
| Linux | `~/.config/google-chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json` |
| Windows | Registry `HKCU\Software\Google\Chrome\NativeMessagingHosts\` |

### Computer Use (CLI, macOS)

Research preview, Pro/Max plan, macOS only, Claude Code v2.1.85+, interactive sessions only.

**Enable:** `/mcp` > select `computer-use` > Enable. Grant Accessibility and Screen Recording macOS permissions.

**Per-app approval per session:**

| Tier | Capabilities | Applies to |
|:-----|:-------------|:-----------|
| View only | See app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, no typing | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

**Safety features:** Per-app approval, sentinel warnings for broad-access apps, terminal excluded from screenshots, global Esc to abort, machine-wide lock (one session at a time).

**CLI vs Desktop differences:** CLI enables via `/mcp`, Desktop via Settings toggle. Desktop has denied apps list and optional auto-unhide toggle. Dispatch sessions can use computer use in Desktop.

### Desktop vs CLI Feature Comparison

| Feature | CLI | Desktop |
|:--------|:----|:--------|
| Third-party providers | Bedrock, Vertex, Foundry | Not available |
| Linux | Yes | Not available (macOS/Windows only) |
| Agent teams | Yes | Not available |
| Scripting/automation | `--print`, Agent SDK | Not available |
| File attachments | Not available | Images, PDFs |
| Session isolation | `--worktree` flag | Automatic worktrees |
| Recurring tasks | Cron, CI pipelines | Scheduled tasks UI |
| Dispatch | Not available | Dispatch sessions |

### Enterprise Desktop Configuration

| Control | Method |
|:--------|:-------|
| Admin console | Enable/disable Code in desktop, Code in web, Remote Control, Bypass mode |
| Managed settings | `permissions.disableBypassPermissionsMode`, `disableAutoMode`, `autoMode` |
| MDM (macOS) | `com.anthropic.Claude` preference domain |
| Group policy (Win) | Registry `SOFTWARE\Policies\Claude` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) -- Desktop app full reference: Code tab overview, starting sessions (environment/folder/model/permission mode), working with code (prompt box, @mentions, file attachments), permission modes (Ask/Auto accept edits/Plan/Auto/Bypass), live app preview with auto-verify and launch.json configuration (fields, port conflicts, examples), diff view with inline commenting and code review, PR monitoring with auto-fix and auto-merge, computer use on macOS (enable, app permission tiers view-only/click-only/full-control, safety), session management (parallel sessions with worktrees, remote sessions, Continue in menu, Dispatch integration), extending Claude Code (connectors, skills, plugins, preview server config), scheduled tasks (local vs remote, frequency options, missed runs catch-up, permissions, management), environment configuration (local/remote/SSH sessions), enterprise configuration (admin console, managed settings, MDM/group policy, SSO, deployment), CLI comparison (flag equivalents, shared config, feature matrix), troubleshooting (403 errors, blank screen, session loading, Git/LFS, Windows issues)
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) -- Desktop quickstart: installation (macOS/Windows downloads), sign-in, opening Code tab, first session walkthrough (choose environment/folder/model, send prompt, review diffs), next steps (interrupt and steer, @mentions, skills, diff review, permission modes, plugins, preview, PR monitoring, scheduled tasks, parallel sessions)
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) -- VS Code extension: installation (VS Code and Cursor), getting started (open panel, send prompt, review changes), prompt box features (permission modes, command menu, context indicator, extended thinking, multi-line input), @-mentions with fuzzy matching and line ranges, resume conversations (local and remote from claude.ai), customization (panel positioning, multiple conversations, terminal mode), plugin management UI, Chrome browser automation via @browser, commands and shortcuts table, URI handler (vscode://anthropic.claude-code/open with prompt/session params), extension settings reference, CLI comparison (feature differences, checkpoints, run CLI in VS Code, switch between extension and CLI, terminal output references, MCP server config), built-in IDE MCP server (transport/auth, getDiagnostics and executeCode tools, Jupyter confirmation flow), git integration (commits, PRs, worktrees), third-party provider setup, security considerations, troubleshooting
- [JetBrains IDEs](references/claude-code-jetbrains.md) -- JetBrains plugin: supported IDEs (IntelliJ, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand), features (quick launch, diff viewing, selection context, file references, diagnostic sharing), installation from marketplace, usage (integrated terminal, external terminal with /ide), plugin settings (custom command, multi-line Option+Enter, auto-updates), ESC key configuration, remote development (host install), WSL configuration, troubleshooting (plugin not working, IDE not detected, command not found), security considerations
- [Use Claude Code with Chrome](references/claude-code-chrome.md) -- Chrome integration beta: capabilities (live debugging, design verification, web app testing, authenticated apps, data extraction, task automation, GIF recording), prerequisites (Chrome/Edge, extension v1.0.36+, direct Anthropic plan), CLI setup (--chrome flag, /chrome command), enable by default, site permissions, example workflows (test local app, debug console, automate forms, draft in Google Docs, extract data, multi-site workflows, record GIF), troubleshooting (extension not detected with native messaging host paths for Chrome/Edge on macOS/Linux/Windows, browser not responding, connection drops, Windows named pipe conflicts)
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) -- Computer use from CLI: macOS research preview (Pro/Max plan, v2.1.85+, interactive only), capabilities (build/validate native apps, E2E UI testing, debug visual issues, drive GUI-only tools), tool priority (MCP > Bash > Chrome > computer use), enable via /mcp computer-use server with Accessibility and Screen Recording permissions, per-app session approval with tiers (view-only/click-only/full-control), sentinel warnings for broad-access apps, machine-wide lock, app hiding during use, Esc to stop, safety guardrails (terminal excluded from screenshots, lock file), example workflows (validate native build, reproduce layout bug, test simulator), CLI vs Desktop differences, troubleshooting

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
