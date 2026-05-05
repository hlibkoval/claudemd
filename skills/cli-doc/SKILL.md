---
name: cli-doc
description: Complete official documentation for the Claude Code CLI — commands, flags, slash commands, interactive mode shortcuts, vim editor mode, keyboard shortcut customization, terminal configuration, and built-in tools reference.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code CLI.

## Quick Reference

### CLI Commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive, SDK usage) |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install or reinstall the native binary |
| `claude auth login/logout/status` | Manage authentication |
| `claude agents` | List configured subagents |
| `claude auto-mode defaults` | Print auto mode classifier rules as JSON |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude remote-control` | Start a Remote Control server |
| `claude setup-token` | Generate a long-lived OAuth token for CI/scripts |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `--print`, `-p` | Non-interactive print mode |
| `--continue`, `-c` | Load most recent conversation |
| `--resume`, `-r` | Resume session by ID or name |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--permission-mode` | Start in a mode: `default`, `acceptEdits`, `plan`, `auto`, `bypassPermissions` |
| `--output-format` | Print mode output: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Spending cap in dollars (print mode only) |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--allowedTools` | Tools that run without permission prompts |
| `--disallowedTools` | Tools removed from context entirely |
| `--tools` | Restrict which built-in tools are available |
| `--add-dir` | Add additional working directories |
| `--mcp-config` | Load MCP servers from JSON files |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--worktree`, `-w` | Start in an isolated git worktree |
| `--name`, `-n` | Set display name for the session |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--debug` | Enable debug mode with optional category filter |
| `--verbose` | Show full turn-by-turn output |
| `--plugin-dir` | Load plugins from a directory for this session |
| `--no-session-persistence` | Disable session save to disk (print mode only) |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message for better caching |
| `--fork-session` | Create a new session ID when resuming |
| `--from-pr` | Resume sessions linked to a pull request |

### System Prompt Flags

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag.

### Slash Commands (Session)

Key built-in commands available inside a session:

| Command | Purpose |
| :--- | :--- |
| `/add-dir <path>` | Add a working directory for file access |
| `/btw <question>` | Ask a side question without adding to conversation |
| `/clear` | Start new conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Summarize conversation to free context |
| `/config` | Open settings interface (alias: `/settings`) |
| `/context` | Visualize context usage |
| `/copy [N]` | Copy last (or Nth) assistant response to clipboard |
| `/debug [description]` | Enable debug logging and troubleshoot |
| `/diff` | Open interactive diff viewer |
| `/doctor` | Diagnose installation and settings |
| `/effort [level]` | Set model effort level |
| `/export [filename]` | Export conversation as plain text |
| `/help` | Show help and available commands |
| `/hooks` | View hook configurations |
| `/init` | Initialize project with CLAUDE.md guide |
| `/keybindings` | Open keybindings configuration file |
| `/memory` | Edit CLAUDE.md files and manage auto-memory |
| `/model [model]` | Select or change AI model |
| `/permissions` | Manage allow/ask/deny rules (alias: `/allowed-tools`) |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/recap` | Generate one-line session summary on demand |
| `/reload-plugins` | Reload all active plugins without restarting |
| `/remote-control` | Enable remote control from claude.ai (alias: `/rc`) |
| `/rename [name]` | Rename the current session |
| `/resume [session]` | Resume conversation by ID or name (alias: `/continue`) |
| `/rewind` | Rewind to a previous point (aliases: `/checkpoint`, `/undo`) |
| `/skills` | List available skills |
| `/status` | Open settings Status tab |
| `/tasks` | List and manage background tasks |
| `/theme` | Change color theme |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/usage` | Show session cost and plan usage (aliases: `/cost`, `/stats`) |
| `/voice [hold\|tap\|off]` | Toggle voice dictation |

Commands marked **[Skill]** in the full reference (like `/batch`, `/debug`, `/loop`, `/simplify`) are bundled skills that use the same mechanism as user-authored skills.

### Interactive Mode Keyboard Shortcuts

#### General Controls

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open in external editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running tasks |
| `Ctrl+T` | Toggle task list |
| `Shift+Tab` | Cycle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |
| `Esc+Esc` | Rewind or summarize |

#### Text Editing

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+A` / `Ctrl+E` | Move to start/end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

#### Multiline Input

| Method | Shortcut |
| :--- | :--- |
| Quick escape | `\` + `Enter` |
| Option key (macOS) | `Option+Enter` |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal |
| Control sequence | `Ctrl+J` (works everywhere) |

#### Quick Input Prefixes

| Prefix | Effect |
| :--- | :--- |
| `/` at start | Command or skill |
| `!` at start | Shell mode (run command, output added to context) |
| `@` | Trigger file path autocomplete |

### Built-in Tools

| Tool | Permission Required | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawns a subagent with its own context window |
| `AskUserQuestion` | No | Asks multiple-choice questions |
| `Bash` | Yes | Executes shell commands |
| `CronCreate/Delete/List` | No | Schedule recurring or one-shot prompts |
| `Edit` | Yes | Makes targeted file edits |
| `EnterPlanMode` / `ExitPlanMode` | No / Yes | Plan mode control |
| `Glob` | No | Finds files by pattern |
| `Grep` | No | Searches file contents |
| `LSP` | No | Code intelligence (jump to def, find refs, errors) |
| `Monitor` | Yes | Watch background command output and react |
| `NotebookEdit` | Yes | Modifies Jupyter notebook cells |
| `PowerShell` | Yes | Executes PowerShell commands natively |
| `Read` | No | Reads file contents |
| `Skill` | Yes | Executes a skill within the conversation |
| `TaskCreate/Get/List/Update/Stop` | No | Task list management |
| `TodoWrite` | No | Session task checklist (non-interactive/SDK) |
| `ToolSearch` | No | Finds and loads deferred tools |
| `WebFetch` | Yes | Fetches URL content |
| `WebSearch` | Yes | Performs web searches |
| `Write` | Yes | Creates or overwrites files |

**Bash tool notes:** `cd` persists within the project directory. Environment variables do not persist between commands. Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to disable working directory carry-over.

### Keybindings Configuration

File: `~/.claude/keybindings.json` (open with `/keybindings`)

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

Actions use `namespace:action` format (e.g., `chat:submit`, `app:toggleTodos`). Set to `null` to unbind. Changes apply without restarting.

**Contexts:** `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Settings`, `Select`, `Plugin`, `Scroll`, `Doctor`, and more.

**Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, Caps Lock.

### Terminal Configuration

| Issue | Fix |
| :--- | :--- |
| Shift+Enter submits (VS Code, Cursor, Zed, Alacritty, Windsurf) | Run `/terminal-setup` once |
| Option shortcuts do nothing on macOS | Enable Option as Meta in terminal settings |
| No notification when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` or use a Notification hook |
| Flicker or scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| tmux breaks Shift+Enter and notifications | Add `allow-passthrough on`, `extended-keys on`, `terminal-features 'xterm*:extkeys'` to `~/.tmux.conf` |

**Custom themes:** Create JSON files in `~/.claude/themes/`. Fields: `name`, `base` (one of `dark`, `light`, `dark-daltonized`, `light-daltonized`, `dark-ansi`, `light-ansi`), `overrides` (map of color token names to values). Select via `/theme`.

### Vim Editor Mode

Enable via `/config` → Editor mode or set `editorMode: "vim"` in settings.

Key mode-switching commands: `Esc` (to NORMAL), `i`/`a`/`o` (to INSERT), `v`/`V` (to VISUAL). Enter still submits in INSERT mode — use `Ctrl+J` or `o`/`O` in NORMAL for newlines.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — All CLI commands and flags with examples
- [Commands](references/claude-code-commands.md) — Full slash command reference including bundled skills
- [Interactive Mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, vim mode, background tasks, session features
- [Keybindings](references/claude-code-keybindings.md) — Customizing keyboard shortcuts via keybindings.json
- [Terminal Configuration](references/claude-code-terminal-config.md) — Fixing Shift+Enter, Option keys, notifications, tmux, themes, fullscreen
- [Tools Reference](references/claude-code-tools-reference.md) — All built-in tools with permission requirements and behavior notes

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
