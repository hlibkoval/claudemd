---
name: ide-doc
user-invocable: false
---

# IDE & Desktop Documentation

This skill provides the complete official documentation for Claude Code's graphical interfaces: the Claude Desktop app (Code tab), the VS Code extension, JetBrains plugin, Chrome browser integration, and computer use.

## Quick Reference

### Interface Options

| Surface | Platforms | Best for |
|:--------|:----------|:---------|
| Claude Desktop app (Code tab) | macOS, Windows | Parallel sessions, visual diff review, app preview, scheduled tasks |
| VS Code extension | VS Code, Cursor, Windsurf, Kiro, VSX forks | Inline diffs, @-mentions, graphical panel in editor |
| JetBrains plugin | IntelliJ, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand | Terminal-driven with IDE diff viewer and selection sharing |
| CLI (terminal) | macOS, Linux, Windows | Scripting, automation, headless, all features |

### Desktop App: Code Tab

**Download:** macOS (Universal) or Windows (x64 / ARM64). Not available on Linux — use the CLI.

**Requirements:** Pro, Max, Team, or Enterprise subscription; Git (required on Windows; included on most Macs).

**Permission modes:**

| Mode | Settings key | Behavior |
|:-----|:-------------|:---------|
| Ask permissions | `default` | Prompts before every file edit or command |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits and common filesystem commands |
| Plan mode | `plan` | Explores and proposes a plan without editing source code |
| Auto | `auto` | All actions with background safety checks (research preview; requires Opus 4.6+ or Sonnet 4.6; Anthropic API only) |
| Bypass permissions | `bypassPermissions` | No prompts; enable in Settings → Claude Code; enterprise admins can disable |

**Keyboard shortcuts (macOS / Windows):**

| Shortcut | Action |
|:---------|:-------|
| `Cmd/Ctrl N` | New session |
| `Cmd/Ctrl W` | Close session |
| `Ctrl Tab` / `Ctrl Shift Tab` | Next / previous session |
| `Esc` | Stop Claude's response |
| `Cmd/Ctrl Shift D` | Toggle diff pane |
| `Cmd/Ctrl Shift P` | Toggle preview pane |
| `Ctrl` `` ` `` | Toggle terminal pane |
| `Cmd/Ctrl \` | Close focused pane |
| `Cmd/Ctrl ;` | Open side chat |
| `Ctrl O` | Cycle view modes (Normal / Verbose / Summary) |
| `Cmd/Ctrl Shift M` | Open permission mode menu |
| `Cmd/Ctrl /` | Show all shortcuts |

**Environment types:**

| Environment | Where Claude runs | Notes |
|:------------|:-----------------|:-------|
| Local | Your machine | Direct file access; terminal pane available |
| Remote | Anthropic cloud | Continues when app is closed; multiple repos supported |
| SSH | Your remote machine | Desktop auto-installs Claude Code on first connect |

**Preview server config (`.claude/launch.json`) fields:**

| Field | Type | Description |
|:------|:-----|:------------|
| `name` | string | Unique server identifier |
| `runtimeExecutable` | string | Command to run (`npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments to `runtimeExecutable` |
| `port` | number | Port the server listens on (default: 3000) |
| `cwd` | string | Working directory relative to project root |
| `env` | object | Extra environment variables (do not put secrets here) |
| `autoPort` | boolean | `true` = pick free port; `false` = fail if port busy; unset = ask |
| `program` | string | Node.js script to run directly (alternative to `runtimeExecutable`) |
| `args` | string[] | Arguments to `program` |
| `autoVerify` | boolean | Root-level field; disable with `false` to stop automatic post-edit verification |

**Enterprise managed settings keys:**

| Key | Description |
|:----|:------------|
| `permissions.disableBypassPermissionsMode` | Set to `"disable"` to prevent bypass permissions mode |
| `disableAutoMode` | Set to `"disable"` to remove Auto from the mode selector |
| `sshConfigs` | Pre-configure SSH connections (users cannot edit managed ones) |
| `sshHostAllowlist` | Restrict SSH sessions to matching host patterns; empty array disables SSH |
| `managedMcpServers` | Push MCP server configs to all users (third-party Desktop deployments only) |

**Coming from the CLI?** Desktop shares CLAUDE.md, MCP servers, hooks, skills, and settings with the CLI. Use `/desktop` in a CLI session to move it into Desktop. Not available with API key auth or on Bedrock/Vertex/Foundry.

**CLI flags → Desktop equivalents:**

| CLI flag | Desktop equivalent |
|:---------|:-------------------|
| `--model` | Model dropdown next to send button |
| `--resume`, `--continue` | Click a session in the sidebar |
| `--permission-mode` | Mode selector next to send button |
| `--dangerously-skip-permissions` | Bypass permissions mode (Settings → Claude Code) |
| `--verbose` | Verbose view mode in Transcript view dropdown |
| `--print`, `--output-format` | Not available (Desktop is interactive only) |

### VS Code Extension

**Requirements:** VS Code 1.98.0+. Also works in Cursor, Windsurf, Kiro, and other VSX forks.

**Install:** Extensions view (`Cmd/Ctrl+Shift+X`) → search "Claude Code" → Install. Or from [Open VSX](https://open-vsx.org/extension/Anthropic/claude-code) for non-Marketplace editors.

**Key shortcuts:**

| Command | Shortcut | Notes |
|:--------|:---------|:------|
| Focus Input (toggle editor ↔ Claude) | `Cmd/Ctrl+Esc` | macOS Tahoe: disable Game Overlay in System Settings → Keyboard |
| Open in New Tab | `Cmd/Ctrl+Shift+Esc` | |
| Insert @-Mention Reference | `Option/Alt+K` | Requires editor focused; inserts `@file.ts#5-10` |
| New Conversation | `Cmd/Ctrl+N` | Requires Claude focused + `enableNewConversationShortcut: true` |
| Reopen Closed Session | `Cmd/Ctrl+Shift+T` | Falls through to VS Code if last closed tab wasn't Claude |

**Extension settings (`Extensions → Claude Code`):**

| Setting | Default | Description |
|:--------|:--------|:------------|
| `useTerminal` | `false` | Launch Claude in terminal mode instead of graphical panel |
| `initialPermissionMode` | `default` | Starting permission mode: `default`, `plan`, `acceptEdits`, or `bypassPermissions` |
| `preferredLocation` | `panel` | `sidebar` (right) or `panel` (new tab) |
| `autosave` | `true` | Auto-save files before Claude reads or writes them |
| `useCtrlEnterToSend` | `false` | Use Ctrl/Cmd+Enter instead of Enter to send |
| `enableNewConversationShortcut` | `false` | Enable Cmd/Ctrl+N for new conversation |
| `enableReopenClosedSessionShortcut` | `true` | Cmd/Ctrl+Shift+T reopens last Claude session tab |
| `respectGitIgnore` | `true` | Exclude .gitignore patterns from file searches |
| `disableLoginPrompt` | `false` | Skip auth prompts (for third-party provider setups) |
| `allowDangerouslySkipPermissions` | `false` | Adds Bypass permissions to mode selector |

**URI handler:** `vscode://anthropic.claude-code/open` opens a new Claude Code tab from external tools. Optional query params: `prompt` (URL-encoded pre-fill text) and `session` (session ID to resume).

**Checkpoints (rewind):** Hover over a message → rewind button → choose Fork conversation, Rewind code, or Fork + rewind.

**Built-in IDE MCP server (`ide`):** Runs locally when the extension is active. Connects CLI to VS Code's diff viewer, selection context, and Jupyter execution. Two model-visible tools:

| Tool | What it does | Writes? |
|:-----|:-------------|:--------|
| `mcp__ide__getDiagnostics` | Returns language-server errors/warnings from the Problems panel | No |
| `mcp__ide__executeCode` | Runs Python in the active Jupyter notebook (always shows a Quick Pick confirm first) | Yes |

**VS Code extension vs. CLI feature gaps:**

| Feature | CLI | VS Code Extension |
|:--------|:----|:-----------------|
| All slash commands | Yes | Subset (type `/` to see) |
| MCP server config | Yes | Partial (`claude mcp add` via terminal; manage with `/mcp`) |
| Checkpoints | Yes | Yes |
| Bash shortcut (an exclamation mark followed by a backtick command) | Yes | No |
| Tab completion | Yes | No |

### JetBrains Plugin

**Supported IDEs:** IntelliJ IDEA, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand.

**Install:** JetBrains Marketplace → search "Claude Code" → Install → restart IDE.

**Key shortcuts:**

| Action | Shortcut |
|:-------|:---------|
| Open Claude Code | `Cmd+Esc` (Mac) / `Ctrl+Esc` (Win/Linux) |
| Insert file reference | `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Win/Linux) |

**Usage:**
- Run `claude` from the IDE's integrated terminal → all features active automatically
- From an external terminal: run `claude`, then type `/ide` to connect to the IDE

**Plugin settings (Settings → Tools → Claude Code [Beta]):**
- `Claude command`: custom path, e.g. `claude`, `/usr/local/bin/claude`, or `npx @anthropic-ai/claude-code`
- WSL users: set command to `wsl -d Ubuntu -- bash -lic "claude"`
- `Enable automatic updates`: check for and install plugin updates on restart

**Remote development:** Install the plugin in the remote host via Settings → Plugin (Host), not the local client.

**WSL2 + JetBrains "No available IDEs detected":** Caused by WSL2 NAT networking blocking the connection. Fix: create a Windows Firewall inbound rule allowing traffic on your WSL2 subnet, or add `networkingMode=mirrored` to `.wslconfig` (requires Windows 11 22H2+).

### Chrome Integration (beta)

**Requirements:** Google Chrome or Microsoft Edge; [Claude in Chrome extension](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) v1.0.36+; Claude Code v2.0.73+; Pro/Max/Team/Enterprise plan (not available through Bedrock/Vertex/Foundry).

**CLI usage:**
```bash
claude --chrome          # start with Chrome enabled
```
Or enable from within a session with `/chrome`. Run `/chrome` to check status, reconnect, or choose which browser to use.

**VS Code usage:** Type `@browser` in the prompt box, e.g. `@browser go to localhost:3000 and check the console`.

**Enable by default (CLI):** Run `/chrome` → "Enabled by default". Note: increases context usage since browser tools are always loaded.

**Capabilities:** live console debugging, UI verification, form automation, authenticated web app interaction, data extraction, multi-site workflows, session recording as GIF.

**Common errors:**

| Error | Fix |
|:------|:----|
| "Browser extension is not connected" | Restart Chrome and Claude Code, then `/chrome` → Reconnect |
| "Extension not detected" | Install or enable extension in `chrome://extensions` |
| "Receiving end does not exist" | Extension service worker went idle; `/chrome` → Reconnect |

### Computer Use

**Desktop app:** macOS and Windows. Toggle in Settings → General → Desktop app → Computer use. Requires macOS Accessibility + Screen Recording permissions.

**CLI:** macOS only. Enable the built-in `computer-use` MCP server via `/mcp`. Requires Claude Code v2.1.85+; Pro or Max plan; interactive session (not available with `-p`).

**App permission tiers (both surfaces):**

| Tier | What Claude can do | Applies to |
|:-----|:-------------------|:-----------|
| View only | See the app in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, not type | Terminals, IDEs |
| Full control | Click, type, drag, keyboard shortcuts | Everything else |

**Safety guardrails:** per-app approval each session; sentinel warnings for terminal/Finder/System Settings; terminal excluded from screenshots; global Esc to abort; machine-wide lock (one session at a time).

**CLI vs. Desktop differences:**

| Feature | Desktop | CLI |
|:--------|:--------|:----|
| Platforms | macOS and Windows | macOS only |
| Enable | Settings → General toggle | Enable `computer-use` in `/mcp` |
| Denied apps list | Configurable in Settings | Not yet available |
| Dispatch integration | Supported | Not applicable |

**Common use cases:** validate native builds, reproduce layout bugs, test iOS Simulator flows, drive GUI-only tools without API.

## Full Documentation

For the complete official documentation, see the reference files:

- [Desktop App (Code tab)](references/claude-code-desktop.md) — Session management, permission modes, diff view, preview servers, computer use, parallel sessions, SSH, enterprise config, and CLI comparison
- [Desktop Quickstart](references/claude-code-desktop-quickstart.md) — Install, first session, and key workflows overview
- [VS Code Extension](references/claude-code-vs-code.md) — Install, extension settings, shortcuts, plugin management, MCP, the built-in IDE server, and troubleshooting
- [JetBrains Plugin](references/claude-code-jetbrains.md) — Supported IDEs, install, shortcuts, plugin settings, WSL2, and remote development
- [Chrome Integration](references/claude-code-chrome.md) — Setup, capabilities, example workflows, permission management, and troubleshooting
- [Computer Use (CLI)](references/claude-code-computer-use.md) — Enable via `/mcp`, per-app approval, safety model, example workflows, and differences from Desktop

## Sources

- Desktop App: https://code.claude.com/docs/en/desktop.md
- Desktop Quickstart: https://code.claude.com/docs/en/desktop-quickstart.md
- VS Code Extension: https://code.claude.com/docs/en/vs-code.md
- JetBrains Plugin: https://code.claude.com/docs/en/jetbrains.md
- Chrome Integration: https://code.claude.com/docs/en/chrome.md
- Computer Use (CLI): https://code.claude.com/docs/en/computer-use.md
