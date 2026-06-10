---
name: ide-doc
user-invocable: false
---

# IDE and Desktop Documentation

This skill provides the complete official documentation for Claude Code IDE integrations and the Desktop app, including VS Code, JetBrains, Chrome browser automation, computer use from the CLI, and the Claude Desktop app.

## Quick Reference

### Desktop App (Code Tab)

Available on macOS and Windows (not Linux — use the CLI there).

**Permission modes:**

| Mode | Settings key | Behavior |
|------|-------------|----------|
| Ask permissions | `default` | Claude asks before editing files or running commands |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits and common filesystem commands |
| Plan mode | `plan` | Claude reads and proposes a plan without editing source code |
| Auto | `auto` | Executes all actions with background safety checks; requires Opus 4.6+/Sonnet 4.6+ |
| Bypass permissions | `bypassPermissions` | No permission prompts; enable in Settings → Claude Code |

`dontAsk` mode is CLI-only.

**Environments:**

| Environment | Description |
|-------------|-------------|
| Local | Runs on your machine with direct file access |
| Remote | Anthropic-hosted cloud; continues when app is closed |
| SSH | Runs on a remote machine you connect to over SSH |

**Keyboard shortcuts (macOS — use Ctrl in place of Cmd on Windows):**

| Shortcut | Action |
|----------|--------|
| `Cmd /` | Show keyboard shortcuts |
| `Cmd N` | New session |
| `Cmd W` | Close session |
| `Ctrl Tab` / `Ctrl Shift Tab` | Next / previous session |
| `Esc` | Stop Claude's response |
| `Cmd Shift D` | Toggle diff pane |
| `Cmd Shift P` | Toggle preview pane |
| `Ctrl \`` | Toggle terminal pane |
| `Cmd \` | Close focused pane |
| `Cmd ;` | Open side chat |
| `Ctrl O` | Cycle view modes |
| `Cmd Shift M` | Open permission mode menu |
| `Cmd Shift I` | Open model menu |

**View modes:**

| Mode | What it shows |
|------|---------------|
| Normal | Tool calls collapsed, full text responses |
| Verbose | Every tool call, file read, and intermediate step |
| Summary | Only Claude's final responses and changes made |

**launch.json configuration fields** (`.claude/launch.json`):

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Unique identifier for the server |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments to `runtimeExecutable` |
| `port` | number | Port the server listens on (default: 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Additional environment variables |
| `autoPort` | boolean | `true` = pick free port; `false` = fail on conflict |
| `program` | string | Node.js script to run directly |
| `args` | string[] | Arguments to `program` |
| `autoVerify` | boolean | Auto-verify changes after edits (top-level field; default: true) |

**SSH settings.json fields** for pre-configured team connections:

| Field | Required | Description |
|-------|----------|-------------|
| `id` | yes | Unique identifier |
| `name` | yes | Display name |
| `sshHost` | yes | `user@hostname` or SSH config alias |
| `sshPort` | no | Defaults to 22 |
| `sshIdentityFile` | no | Path to private key |
| `startDirectory` | no | Starting directory on remote host |

**Managed settings keys (enterprise):**

| Key | Description |
|-----|-------------|
| `permissions.disableBypassPermissionsMode` | `"disable"` to prevent bypass permissions mode |
| `disableAutoMode` | `"disable"` to remove Auto from the mode selector |
| `autoMode` | Customize auto mode classifier |
| `sshConfigs` | Pre-configure team SSH connections |
| `sshHostAllowlist` | Restrict SSH hosts by pattern (`*`, `*.example.com`) |
| `managedMcpServers` | Push MCP configs to all users (3P Desktop deployments only) |

---

### VS Code Extension

**Install:** Search "Claude Code" in the Extensions view, or use `Cmd+Shift+X` / `Ctrl+Shift+X`.

**Extension settings (`Extensions → Claude Code`):**

| Setting | Default | Description |
|---------|---------|-------------|
| `useTerminal` | `false` | Launch in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` (right) or `panel` (new tab) |
| `autosave` | `true` | Auto-save files before Claude reads/writes them |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter to send instead of Enter |
| `enableNewConversationShortcut` | `false` | Cmd/Ctrl+N to start new conversation |
| `enableReopenClosedSessionShortcut` | `true` | Cmd/Ctrl+Shift+T reopens last closed session tab |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `usePythonEnvironment` | `true` | Activate workspace Python env (requires Python extension) |
| `allowDangerouslySkipPermissions` | `false` | Adds Bypass permissions to mode selector |

**VS Code keyboard shortcuts:**

| Shortcut | Action |
|----------|--------|
| `Cmd/Ctrl Esc` | Toggle focus between editor and Claude |
| `Cmd/Ctrl Shift Esc` | Open new conversation as editor tab |
| `Cmd/Ctrl N` | New conversation (requires `enableNewConversationShortcut: true`) |
| `Cmd/Ctrl Shift T` | Reopen most recently closed Claude session tab |
| `Option/Alt K` | Insert @-mention reference for current file and selection |

**URI handler:** `vscode://anthropic.claude-code/open` — opens a new Claude Code tab. Query params: `prompt` (URL-encoded text) and `session` (session ID to resume).

**Built-in IDE MCP server tools (visible to model):**

| Tool | What it does | Writes? |
|------|-------------|---------|
| `mcp__ide__getDiagnostics` | Returns VS Code Problems panel diagnostics | No |
| `mcp__ide__executeCode` | Runs Python code in active Jupyter notebook (always prompts first) | Yes |

**Checkpoint rewind options (hover any message):**
- Fork conversation from here (keep code changes)
- Rewind code to here (keep full conversation)
- Fork conversation and rewind code

---

### JetBrains Plugin

**Supported IDEs:** IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand.

**Install:** JetBrains Marketplace → search "Claude Code".

**Shortcuts:**

| Shortcut | Action |
|----------|--------|
| `Cmd Esc` (Mac) / `Ctrl Esc` (Win/Linux) | Open Claude Code from editor |
| `Cmd Option K` (Mac) / `Alt Ctrl K` (Win/Linux) | Insert file reference |

**Plugin settings** (`Settings → Tools → Claude Code [Beta]`):
- **Claude command**: custom path, e.g. `claude`, `/usr/local/bin/claude`, or `npx @anthropic-ai/claude-code`
- For WSL: `wsl -d Ubuntu -- bash -lic "claude"`
- **Enable automatic updates**: check for and install plugin updates on restart

**Remote development:** Install the plugin in the remote host via `Settings → Plugin (Host)`, not the local client.

**WSL2 fix (NAT networking causes "No available IDEs detected"):** Either add a Windows Firewall rule allowing the WSL2 subnet, or switch WSL2 to mirrored networking (`networkingMode=mirrored` in `.wslconfig`; requires Windows 11 22H2+).

---

### Chrome Integration

**Requirements:**
- Google Chrome or Microsoft Edge
- Claude in Chrome extension v1.0.36+
- Claude Code v2.0.73+
- Pro, Max, Team, or Enterprise plan (direct Anthropic — not available on Bedrock/Vertex/Foundry)

**CLI usage:**
- Start with `claude --chrome` or enable mid-session with `/chrome`
- Enable by default: run `/chrome` → "Enabled by default"
- Check status / reconnect: run `/chrome`

**VS Code usage:** Type `@browser` followed by the task.

**Capabilities:** live console debugging, UI testing, form automation, authenticated web app interaction (uses your browser login state), data extraction, multi-site workflows, GIF recording.

**Common errors:**

| Error | Fix |
|-------|-----|
| "Browser extension is not connected" | Restart Chrome and Claude Code, then `/chrome` to reconnect |
| "Extension not detected" | Install/enable extension in `chrome://extensions` |
| "Receiving end does not exist" | `/chrome` → "Reconnect extension" (service worker went idle) |

---

### Computer Use (CLI)

**Requirements:** macOS only (Windows: use Desktop app), Pro or Max plan, Claude Code v2.1.85+, interactive session (not `-p` flag), authenticated via claude.ai (not third-party providers).

**Enable:** run `/mcp` in a session → select `computer-use` → Enable. Then grant macOS Accessibility and Screen Recording permissions.

**App permission tiers (fixed, cannot be changed):**

| Tier | What Claude can do | Applies to |
|------|-------------------|------------|
| View only | See app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, no typing or keyboard shortcuts | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

**Safety features:** per-app approval per session, sentinel warnings for broad-reach apps (shell/filesystem/system settings access), terminal excluded from screenshots, global Esc to abort, single-session lock.

**Stop computer use:** press `Esc` anywhere or `Ctrl+C` in the terminal.

**CLI vs Desktop differences:**

| Feature | Desktop | CLI |
|---------|---------|-----|
| Platforms | macOS + Windows | macOS only |
| Enable | Settings > General toggle | `/mcp` → enable `computer-use` |
| Denied apps list | Configurable | Not yet available |
| Auto-unhide toggle | Optional | Always on |

---

### CLI vs Desktop Feature Comparison

| Feature | CLI | Desktop |
|---------|-----|---------|
| Permission modes | All including `dontAsk` | Ask, Auto accept edits, Plan, Auto, Bypass |
| Third-party providers | Bedrock, Vertex AI, Foundry | Anthropic API (enterprise: Vertex AI / gateway) |
| MCP servers | Settings files | Connectors UI (local/SSH) or settings files |
| Plugins | `/plugin` command | Plugin manager UI |
| Session isolation | `--worktree` flag | Automatic worktrees |
| Multiple sessions | Separate terminals | Sidebar tabs |
| Recurring tasks | Cron / CI | Scheduled tasks |
| Computer use | `/mcp` on macOS | macOS + Windows via Settings |
| Scripting/automation | `--print`, Agent SDK | Not available |
| Dispatch integration | Not available | Dispatch sessions in sidebar |

**Desktop-only features not in CLI:** parallel session sidebar, drag-and-drop pane layout, visual diff review, live app preview, PR monitoring with auto-merge, scheduled tasks, Dispatch integration, computer use on Windows.

**CLI-only features not in Desktop:** `dontAsk` permission mode, `--print`/`--output-format`, agent teams (parallel sessions messaging each other), terminal dialog commands (`/permissions`, `/config`, `/agents`, `/doctor`), Linux support.

## Full Documentation

For the complete official documentation, see the reference files:

- [Desktop Application](references/claude-code-desktop.md) — Full reference for the Claude Desktop app Code tab: sessions, permission modes, diff view, PR monitoring, workspace layout, computer use, environment configuration, SSH, enterprise settings, and CLI comparison
- [Get Started with the Desktop App](references/claude-code-desktop-quickstart.md) — Installation walkthrough and first session guide for the Desktop app
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — VS Code extension installation, features, settings, checkpoints, MCP, Chrome integration, and third-party provider setup
- [JetBrains IDEs](references/claude-code-jetbrains.md) — JetBrains plugin installation, configuration, WSL2 setup, and troubleshooting
- [Use Claude Code with Chrome](references/claude-code-chrome.md) — Chrome browser integration for web automation, debugging, and data extraction
- [Let Claude Use Your Computer from the CLI](references/claude-code-computer-use.md) — Computer use via the CLI on macOS: enabling, app permissions, safety, and example workflows

## Sources

- Desktop Application: https://code.claude.com/docs/en/desktop.md
- Get Started with the Desktop App: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome: https://code.claude.com/docs/en/chrome.md
- Let Claude Use Your Computer from the CLI: https://code.claude.com/docs/en/computer-use.md
