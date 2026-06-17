---
name: cli-doc
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface: launch commands, flags, in-session slash commands, keyboard shortcuts, keybindings customization, terminal configuration, and built-in tools reference.

## Quick Reference

### Starting and controlling a session

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start with an initial prompt |
| `claude -p "query"` | Non-interactive (print) mode — run query and exit |
| `cat file \| claude -p "query"` | Pipe content to Claude |
| `claude -c` | Resume most recent session in current directory |
| `claude -r "<id-or-name>"` | Resume a specific session |
| `claude --bg "task"` | Start a background agent session |
| `claude update` | Update to latest version |
| `claude install [version]` | Install or reinstall the native binary |

### Key CLI flags

| Flag | Description |
| :--- | :--- |
| `--print` / `-p` | Non-interactive mode |
| `--model <alias\|id>` | Set model (`sonnet`, `opus`, `haiku`, `fable`, or full ID) |
| `--effort <level>` | Set effort: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode <mode>` | `default`, `acceptEdits`, `plan`, `auto`, `bypassPermissions` |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--continue` / `-c` | Resume most recent session |
| `--resume` / `-r` | Resume session by ID or name (or open picker) |
| `--name` / `-n <name>` | Name this session |
| `--worktree` / `-w <name>` | Start in an isolated git worktree |
| `--bare` | Skip hooks, skills, plugins, MCP, memory, CLAUDE.md |
| `--safe-mode` | Disable all customizations for troubleshooting |
| `--output-format <fmt>` | `text`, `json`, or `stream-json` (print mode) |
| `--verbose` | Show full turn-by-turn output |
| `--add-dir <path>` | Add additional working directories |
| `--mcp-config <file>` | Load MCP servers from a JSON file |
| `--plugin-dir <path>` | Load a plugin for this session |
| `--settings <file\|json>` | Override settings for this session |
| `--agent <name>` | Use a specific subagent for the session |
| `--bg` | Start as a background agent |
| `--tools <list>` | Restrict which built-in tools Claude can use |
| `--allowedTools <list>` | Tools that run without prompting |
| `--disallowedTools <list>` | Tools to deny or remove |
| `--max-turns <n>` | Limit agentic turns (print mode) |
| `--max-budget-usd <n>` | Max API spend (print mode) |
| `--debug` | Enable debug mode |
| `--safe-mode` | Disable all customizations for troubleshooting |
| `--version` / `-v` | Show version |

### System prompt flags

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt <text>` | Replace entire default system prompt |
| `--system-prompt-file <path>` | Replace with file contents |
| `--append-system-prompt <text>` | Append to default prompt |
| `--append-system-prompt-file <path>` | Append file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag.

### Background session management commands

| Command | Description |
| :--- | :--- |
| `claude agents [--json]` | Open agent view; `--json` for JSON list |
| `claude attach <id>` | Attach to a background session |
| `claude logs <id>` | Print recent output from a background session |
| `claude stop <id>` | Stop a background session |
| `claude respawn <id>` | Restart a background session |
| `claude rm <id>` | Remove a background session from the list |
| `claude daemon status` | Check the background supervisor state |
| `claude daemon stop --any` | Stop the background supervisor |

### Auth and utility commands

| Command | Description |
| :--- | :--- |
| `claude auth login` | Sign in (use `--console` for API key billing, `--sso` for SSO) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude setup-token` | Generate a long-lived OAuth token for CI |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude auto-mode defaults` | Print auto mode classifier rules |
| `claude remote-control` | Start a Remote Control server session |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

---

### In-session slash commands (selected)

| Command | Description |
| :--- | :--- |
| `/clear [name]` | Start fresh; previous conversation stays in `/resume`. Aliases: `/reset`, `/new` |
| `/compact [instructions]` | Summarize conversation to free context |
| `/context [all]` | Visualize context usage |
| `/model [model]` | Switch model |
| `/effort [level]` | Set effort level |
| `/plan [description]` | Enter plan mode |
| `/diff` | Open interactive diff viewer |
| `/resume [session]` | Resume a conversation |
| `/branch [name]` | Branch the current conversation |
| `/fork <directive>` | Spawn a background subagent with the current conversation |
| `/background [prompt]` | Detach session to run as a background agent |
| `/bg` | Alias for `/background` |
| `/batch <instruction>` | Orchestrate large-scale parallel changes (skill) |
| `/compact [instructions]` | Summarize conversation to free context |
| `/code-review [level] [--fix] [--comment]` | Review diff for bugs and cleanups (skill) |
| `/simplify [target]` | Review and apply cleanup-only fixes (skill, v2.1.154+) |
| `/review [PR]` | Review a pull request locally |
| `/security-review` | Analyze pending changes for security vulnerabilities |
| `/btw <question>` | Side question without adding to conversation history |
| `/add-dir <path>` | Add a working directory for file access |
| `/init` | Create a starter CLAUDE.md |
| `/memory` | Edit CLAUDE.md files and auto-memory |
| `/permissions` | Manage allow/ask/deny rules |
| `/hooks` | View hook configurations |
| `/mcp` | Manage MCP connections |
| `/agents` | Manage subagent configurations |
| `/tasks` | View background tasks |
| `/rewind` | Roll back code and conversation to a checkpoint. Aliases: `/checkpoint`, `/undo` |
| `/reload-plugins [--force]` | Reload plugins without restarting |
| `/reload-skills` | Re-scan skills on disk (v2.1.152+) |
| `/skills` | List available skills |
| `/keybindings` | Open keybindings config file |
| `/config` | Open Settings interface. Alias: `/settings` |
| `/theme` | Change color theme |
| `/usage` | Show session cost and usage stats. Aliases: `/cost`, `/stats` |
| `/debug [description]` | Enable debug logging and troubleshoot (skill) |
| `/doctor` | Diagnose Claude Code installation |
| `/feedback` | Report a bug or share session |
| `/exit` | Exit Claude Code. Alias: `/quit` |

Commands marked **(skill)** are bundled skills — prompt-based, not built-in commands.

---

### Keyboard shortcuts (general controls)

| Shortcut | Action |
| :--- | :--- |
| `Ctrl+C` | Interrupt, or clear input |
| `Ctrl+D` | Exit Claude Code |
| `Esc` | Interrupt Claude (stop current response mid-turn) |
| `Esc` + `Esc` | Clear input draft (or open rewind menu when empty) |
| `Shift+Tab` | Cycle permission modes |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse history search |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open prompt in external text editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+B` | Background running task (press twice in tmux) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+X Ctrl+K` | Stop all background subagents (confirm with double press) |
| `Ctrl+V` / `Cmd+V` | Paste image from clipboard |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |

### Keyboard shortcuts (text editing)

| Shortcut | Action |
| :--- | :--- |
| `Ctrl+A` | Move to start of line |
| `Ctrl+E` | Move to end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` | Move cursor back one word |
| `Alt+F` | Move cursor forward one word |

### Multiline input

| Method | Shortcut |
| :--- | :--- |
| Quick escape | `\` + `Enter` (all terminals) |
| Control sequence | `Ctrl+J` (all terminals) |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| VS Code / Cursor / Zed | Run `/terminal-setup` once |

---

### Keybindings customization

Config file: `~/.claude/keybindings.json` (open with `/keybindings`)

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "ctrl+e": "chat:externalEditor",
        "ctrl+u": null
      }
    }
  ]
}
```

Set an action to `null` to unbind a shortcut. Changes are hot-reloaded without restart.

**Available contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Scroll`, `Doctor`

**Key action examples:**

| Action | Default | Context |
| :--- | :--- | :--- |
| `app:interrupt` | Ctrl+C | Global |
| `app:exit` | Ctrl+D | Global |
| `app:toggleTodos` | Ctrl+T | Global |
| `app:toggleTranscript` | Ctrl+O | Global |
| `chat:submit` | Enter | Chat |
| `chat:newline` | Ctrl+J | Chat |
| `chat:cycleMode` | Shift+Tab | Chat |
| `chat:modelPicker` | Meta+P | Chat |
| `chat:externalEditor` | Ctrl+G, Ctrl+X Ctrl+E | Chat |
| `chat:imagePaste` | Ctrl+V | Chat |
| `task:background` | Ctrl+B | Task |
| `history:search` | Ctrl+R | (history) |

**Reserved shortcuts (cannot rebind):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, Caps Lock

**Terminal multiplexer conflicts:** `Ctrl+B` (tmux prefix — press twice), `Ctrl+A` (GNU screen), `Ctrl+Z` (suspend)

**Keystroke syntax:** use `+` separator for modifiers: `ctrl`, `shift`, `alt`/`meta`, `cmd`. Chords are space-separated sequences: `ctrl+k ctrl+s`.

---

### Terminal configuration

| Issue | Fix |
| :--- | :--- |
| Shift+Enter submits instead of newline | Run `/terminal-setup` (VS Code, Cursor, Zed, Alacritty); or use `Ctrl+J` everywhere |
| Option-key shortcuts do nothing (macOS) | Enable Option as Meta in terminal settings (see below) |
| No bell/notification when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` in settings, or add a Notification hook |
| Display flickers or scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Vim keys in prompt | Enable via `/config` → Editor mode |

**Option as Meta on macOS:**
- iTerm2: Settings → Profiles → Keys → set Left/Right Option key to "Esc+"
- Apple Terminal: Settings → Profiles → Keyboard → "Use Option as Meta Key"
- VS Code: `"terminal.integrated.macOptionIsMeta": true`

**tmux config** (`~/.tmux.conf`):
```bash
set -g allow-passthrough on
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'
```

**Custom themes:** stored as JSON in `~/.claude/themes/`. Select **New custom theme…** in `/theme`. Key fields: `name`, `base` (preset to extend), `overrides` (map of color tokens to values). Claude Code hot-reloads when files change.

---

### Built-in tools reference

| Tool | Permission | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawn a subagent with its own context window |
| `AskUserQuestion` | No | Ask multiple-choice questions |
| `Bash` | Yes | Execute shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Schedule recurring or one-shot prompts |
| `Edit` | Yes | Exact string replacement in files |
| `EnterPlanMode` / `ExitPlanMode` | No / Yes | Switch to/from plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Create/exit git worktrees |
| `Glob` | No | Find files by pattern |
| `Grep` | No | Search file contents (ripgrep syntax) |
| `LSP` | No | Code intelligence (requires a code-intelligence plugin) |
| `Monitor` | Yes | Watch a background process and react to output (v2.1.98+) |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `PowerShell` | Yes | Execute PowerShell commands |
| `PushNotification` | No | Send desktop or phone push notification |
| `Read` | No | Read file contents |
| `RemoteTrigger` | No | Create/run Routines on claude.ai |
| `SendMessage` | No | Message an agent team teammate or resume a subagent |
| `Skill` | Yes | Execute a skill in the main conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Manage task list |
| `ToolSearch` | No | Search and load deferred MCP tools |
| `WebFetch` | Yes | Fetch and extract content from a URL |
| `WebSearch` | Yes | Run a web search query |
| `Workflow` | Yes | Run a dynamic workflow |
| `Write` | Yes | Create or overwrite files |

**Permission rule formats:**

| Rule | Applies to |
| :--- | :--- |
| `Bash(npm run *)` | Bash, Monitor — command pattern |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP — path pattern |
| `Edit(/src/**)` | Edit, Write, NotebookEdit — path pattern |
| `WebFetch(domain:example.com)` | WebFetch — domain matching |
| `Agent(Explore)` | Agent — subagent type matching |
| `Skill(deploy *)` | Skill — skill name matching |
| `WebSearch` | WebSearch — no specifier |

**Bash tool notes:** `cd` within the project directory persists to later Bash calls. Environment variables do not persist across calls. Default timeout: 2 minutes (up to 10 min with `timeout` param). Default output limit: 30,000 chars.

**Edit tool notes:** Claude must have read the file in the current conversation before editing, and `old_string` must match exactly once (or use `replace_all: true`).

**Glob tool notes:** Results sorted by modification time, capped at 100. Does not respect `.gitignore` by default.

**Grep tool notes:** Uses ripgrep syntax. Respects `.gitignore`. Three output modes: `files_with_matches` (default), `content`, `count`.

**WebFetch tool notes:** Converts HTML to Markdown via a small model. Responses cached 15 minutes. Does not follow cross-host redirects automatically.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — All CLI commands and flags, system prompt flags
- [Commands](references/claude-code-commands.md) — Complete in-session slash command reference, MCP prompts
- [Interactive mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, Vim editor mode, command history, shell mode, prompt suggestions, /btw, task list, session recap, PR review status
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) — Keybindings config file, all contexts and actions, keystroke syntax, unbinding, reserved shortcuts, vim mode interaction
- [Configure your terminal for Claude Code](references/claude-code-terminal-config.md) — Multiline input, Option key setup, notifications, tmux config, fullscreen rendering, custom themes
- [Tools reference](references/claude-code-tools-reference.md) — All built-in tools, permission rules, per-tool behavior (Bash, Edit, Glob, Grep, Read, Write, WebFetch, WebSearch, NotebookEdit, Monitor, PowerShell, LSP, Agent)

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure your terminal for Claude Code: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
