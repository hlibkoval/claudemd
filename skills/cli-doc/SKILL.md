---
name: cli-doc
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface: startup flags, in-session commands, keyboard shortcuts, keybinding customization, terminal configuration, and built-in tools.

## Quick Reference

### Core CLI Invocations

| Invocation | Description |
|:-----------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode: run query and exit (non-interactive) |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<name>"` | Resume session by ID or name |
| `claude --bg "task"` | Start session as background agent, return immediately |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in to Anthropic account |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `-p`, `--print` | Non-interactive print mode; exits after one response |
| `-c`, `--continue` | Load most recent conversation in current directory |
| `-r`, `--resume` | Resume specific session by ID or name |
| `-n`, `--name` | Set display name for session |
| `-w`, `--worktree` | Start in an isolated git worktree |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in a permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--output-format` | Print mode output format: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Dollar spending cap (print mode only) |
| `--allowedTools` | Tools that execute without prompting |
| `--disallowedTools` | Tools to deny or remove from context |
| `--tools` | Restrict which built-in tools are available |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append text to default system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append file contents to default system prompt |
| `--add-dir` | Add additional working directories for file access |
| `--plugin-dir` | Load a plugin from a directory or `.zip` for this session |
| `--mcp-config` | Load MCP servers from JSON file |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--bg` | Start as background agent, return immediately |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--debug` | Enable debug mode with optional category filter |
| `--verbose` | Verbose logging, full turn-by-turn output |
| `--settings` | Path or inline JSON to override settings for this session |
| `--init-only` | Run Setup and SessionStart hooks, then exit |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves prompt cache reuse) |

### System Prompt Flags Summary

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either.

### Background Session Commands

| Command | Description |
|:--------|:------------|
| `claude agents` | Open agent view to monitor/dispatch background sessions |
| `claude attach <id>` | Attach to a background session in this terminal |
| `claude logs <id>` | Print recent output from a background session |
| `claude stop <id>` | Stop a background session |
| `claude rm <id>` | Remove a background session from the list |
| `claude respawn <id>` | Restart a session with conversation intact |
| `claude daemon status` | Print supervisor state for diagnostics |
| `claude daemon stop --any` | Stop the background-session supervisor |

### Other CLI Subcommands

| Command | Description |
|:--------|:------------|
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins (alias: `claude plugins`) |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude remote-control` | Start a Remote Control server |
| `claude setup-token` | Generate long-lived OAuth token for CI/scripts |
| `claude auto-mode defaults` | Print auto mode classifier rules as JSON |
| `claude ultrareview [target]` | Run ultrareview non-interactively |
| `claude auth status` | Show auth status (JSON; `--text` for human-readable) |
| `claude install [version]` | Install/reinstall native binary at specific version |

---

### In-Session Commands (slash commands)

Type `/` in Claude Code to see all available commands. Key commands:

| Category | Commands |
|:---------|:---------|
| **Session** | `/clear`, `/compact [instructions]`, `/context`, `/resume`, `/branch`, `/fork`, `/rewind` |
| **Model/Mode** | `/model`, `/effort`, `/plan`, `/fast`, `/permission-mode` |
| **Memory/Config** | `/memory`, `/config`, `/hooks`, `/permissions`, `/init` |
| **Parallelism** | `/agents`, `/tasks`, `/background`, `/batch` |
| **Code quality** | `/code-review`, `/simplify`, `/review`, `/security-review` |
| **Utilities** | `/diff`, `/copy`, `/export`, `/usage`, `/btw`, `/recap` |
| **Plugins/MCP** | `/plugin`, `/mcp`, `/reload-plugins`, `/reload-skills` |
| **Navigation** | `/skills`, `/keybindings`, `/theme`, `/tui`, `/diff` |
| **Session meta** | `/rename`, `/stop`, `/exit`, `/feedback`, `/doctor` |
| **Web/Remote** | `/teleport`, `/remote-control`, `/autofix-pr`, `/remote-env` |
| **Workflows** | `/ultraplan`, `/ultrareview`, `/code-review ultra`, `/deep-research` |

MCP server prompts appear as `/mcp__<server>__<prompt>` commands.

---

### Keyboard Shortcuts — General Controls

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Interrupt operation or clear input |
| `Ctrl+D` | Exit Claude Code |
| `Esc` | Interrupt Claude mid-response |
| `Esc` `Esc` | Clear input draft (if text present) or open rewind menu (if empty) |
| `Shift+Tab` | Cycle permission modes (`default` → `acceptEdits` → `plan` → …) |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse history search |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open prompt in external editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+B` | Background running task (tmux users: press twice) |
| `Ctrl+T` | Toggle task list |
| `Alt+P` / `Option+P` | Switch model |
| `Alt+T` / `Option+T` | Toggle extended thinking |
| `Alt+O` / `Option+O` | Toggle fast mode |

### Keyboard Shortcuts — Text Editing

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+A` / `Ctrl+E` | Move cursor to start/end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

### Multiline Input Methods

| Method | Shortcut |
|:-------|:---------|
| Backslash + Enter | Works in all terminals |
| `Ctrl+J` | Works in any terminal |
| `Shift+Enter` | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| `Option+Enter` | After enabling Option as Meta on macOS |

For VS Code, Cursor, Alacritty, Zed: run `/terminal-setup` once to enable `Shift+Enter`.

---

### Keybindings Customization

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

Set a binding to `null` to unbind it. Changes apply automatically without restarting.

**Key contexts:** `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `Select`, `Plugin`, `Settings`, `Scroll` (fullscreen), `DiffDialog`, `ModelPicker`

**Action format:** `namespace:action` — e.g., `chat:submit`, `app:toggleTodos`, `transcript:exit`

**Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, `Caps Lock`

**Chord syntax:** space-separated keystrokes, e.g., `"ctrl+k ctrl+s"`

---

### Terminal Configuration

| Symptom | Fix |
|:--------|:----|
| `Shift+Enter` submits instead of newline (VS Code, Cursor, Alacritty, Zed) | Run `/terminal-setup` once in the host terminal |
| Option-key shortcuts do nothing on macOS (iTerm2) | Settings → Profiles → Keys → set Option key to "Esc+" |
| Option-key shortcuts do nothing on macOS (Apple Terminal) | Settings → Profiles → Keyboard → check "Use Option as Meta Key" |
| Option-key shortcuts do nothing on macOS (VS Code) | Add `"terminal.integrated.macOptionIsMeta": true` to settings |
| No notification when Claude finishes | Set `preferredNotifChannel` to `"terminal_bell"` in settings, or configure a Notification hook |
| Display flickers / scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Running inside tmux | Add `set -g allow-passthrough on`, `set -s extended-keys on`, `set -as terminal-features 'xterm*:extkeys'` to `~/.tmux.conf` |

**Custom themes:** Stored in `~/.claude/themes/<name>.json`. Fields: `name`, `base` (built-in preset), `overrides` (color token map). Create interactively via `/theme` → New custom theme.

---

### Built-in Tools Reference

| Tool | Permission | Description |
|:-----|:-----------|:------------|
| `Agent` | No | Spawns a subagent with its own context window |
| `AskUserQuestion` | No | Asks multiple-choice questions |
| `Bash` | Yes | Executes shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Manage scheduled tasks in-session |
| `Edit` | Yes | Makes targeted string replacements in files |
| `EnterPlanMode` / `ExitPlanMode` | No/Yes | Switch to/from plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Create/exit isolated git worktrees |
| `Glob` | No | Find files by pattern (sorted by mtime, capped at 100) |
| `Grep` | No | Search file contents via ripgrep regex |
| `LSP` | No | Code intelligence (definitions, references, type errors) |
| `Monitor` | Yes | Watch a background process and react to each output line |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells by `cell_id` |
| `PowerShell` | Yes | Execute PowerShell natively (Windows; opt-in on Linux/macOS) |
| `PushNotification` | No | Send desktop/phone notification |
| `Read` | No | Read file contents (supports images, PDFs, notebooks) |
| `RemoteTrigger` | No | Create/run Routines on claude.ai |
| `Skill` | Yes | Execute a skill in the main conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Manage session task checklist |
| `ToolSearch` | No | Load deferred tools (used with MCP tool search) |
| `WebFetch` | Yes | Fetch URL, extract content via small model, return Markdown |
| `WebSearch` | Yes | Search via Anthropic's web search backend |
| `Workflow` | Yes | Run a dynamic workflow script across many subagents |
| `Write` | Yes | Create or overwrite files (requires prior Read for existing files) |

**Permission rule formats:**

| Rule | Applies to |
|:-----|:-----------|
| `Bash(npm run *)` | Bash, Monitor |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP |
| `Edit(/src/**)` | Edit, Write, NotebookEdit |
| `WebFetch(domain:example.com)` | WebFetch |
| `Skill(deploy *)` | Skill |
| `Agent(Explore)` | Agent |
| `WebSearch` | WebSearch (no specifier) |

**Bash tool notes:** Commands run in separate processes; `cd` persists within project dir; env vars do not persist. Default timeout: 2 min (max 10 min). Default output limit: 30,000 chars.

**Edit tool notes:** Requires prior Read in current conversation; `old_string` must appear exactly once (or use `replace_all: true`).

**Grep tool notes:** Built on ripgrep syntax; respects `.gitignore`; output modes: `files_with_matches` (default), `content`, `count`.

**WebFetch tool notes:** Extracts content via a small model—results are lossy. Caches for 15 min. Does not follow cross-host redirects automatically.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — All CLI commands and flags, system prompt flag guide
- [Commands](references/claude-code-commands.md) — Complete in-session slash command reference, workflow tips
- [Interactive Mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, vim editor mode, command history, background tasks, shell mode, prompt suggestions, `/btw`, task list, session recap
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) — Keybindings config file format, all contexts and actions, chord syntax, unbinding, reserved shortcuts
- [Configure Your Terminal](references/claude-code-terminal-config.md) — Shift+Enter setup, Option key on macOS, terminal bell/notification, tmux config, fullscreen rendering, custom themes
- [Tools Reference](references/claude-code-tools-reference.md) — All built-in tools, permission rule syntax, per-tool behavior details

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure Your Terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
