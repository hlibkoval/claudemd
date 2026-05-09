---
name: cli-doc
description: Complete official documentation for the Claude Code CLI — launch commands, all CLI flags, slash commands reference, interactive mode keyboard shortcuts, Vim editor mode, keybindings configuration, terminal setup, and the built-in tools reference.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, keybindings, terminal configuration, and built-in tools.

## Quick Reference

### Launch Commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode — query and exit (non-interactive) |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install or reinstall native binary |
| `claude auth login` | Sign in to Anthropic account |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status (JSON; `--text` for readable) |
| `claude agents` | List configured subagents |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local project state |
| `claude remote-control` | Start Remote Control server |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Continue most recent conversation |
| `-r`, `--resume` | Resume session by ID or name |
| `-n`, `--name` | Set display name for session |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--permission-mode` | Start in `default`, `acceptEdits`, `plan`, `auto`, or `bypassPermissions` |
| `--add-dir` | Add additional working directories |
| `--output-format` | Print mode output: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Spending cap in dollars (print mode only) |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append system prompt from file |
| `--tools` | Restrict available tools (`""` = none, `"Bash,Edit,Read"`) |
| `--allowedTools` | Tools that run without permission prompts |
| `--disallowedTools` | Tools removed from model context |
| `--bare` | Minimal mode — skips hooks, skills, plugins, MCP |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--plugin-dir` | Load plugin from directory or zip |
| `--mcp-config` | Load MCP servers from JSON |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--debug` | Enable debug mode (optional category filter) |
| `--verbose` | Enable verbose turn-by-turn output |
| `--version`, `-v` | Show version number |

### System Prompt Flags

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag. Prefer append flags to preserve Claude's built-in capabilities.

### Slash Commands (Key Selection)

| Command | Purpose |
| :--- | :--- |
| `/add-dir <path>` | Add working directory for current session |
| `/batch <instruction>` | Parallel large-scale codebase changes (Skill) |
| `/btw <question>` | Side question without adding to conversation |
| `/clear` | Start new conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Summarize conversation to free context |
| `/config` | Open settings UI (alias: `/settings`) |
| `/context` | Visualize context usage |
| `/copy [N]` | Copy last assistant response to clipboard |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings |
| `/effort [level]` | Set model effort level |
| `/exit` | Exit the CLI (alias: `/quit`) |
| `/help` | Show help and commands |
| `/hooks` | View hook configurations |
| `/init` | Initialize `CLAUDE.md` |
| `/keybindings` | Open keybindings config file |
| `/memory` | Edit CLAUDE.md memory files |
| `/mcp` | Manage MCP server connections |
| `/model [model]` | Select or change the AI model |
| `/permissions` | Manage allow/ask/deny tool rules (alias: `/allowed-tools`) |
| `/plan [description]` | Enter plan mode |
| `/recap` | Generate session summary on demand |
| `/reload-plugins` | Reload active plugins without restarting |
| `/remote-control` | Make session available for remote control (alias: `/rc`) |
| `/rename [name]` | Rename current session |
| `/resume [session]` | Resume conversation by ID or name (alias: `/continue`) |
| `/review [PR]` | Review a pull request |
| `/rewind` | Rewind to a previous checkpoint (aliases: `/checkpoint`, `/undo`) |
| `/skills` | List available skills |
| `/status` | Show version, model, account, connectivity |
| `/tasks` | List and manage background tasks |
| `/theme` | Change color theme |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/usage` | Show session cost and plan usage (aliases: `/cost`, `/stats`) |
| `/voice [hold\|tap\|off]` | Toggle voice dictation |

Commands marked **Skill** use the skill mechanism. MCP servers can add `/mcp__<server>__<prompt>` commands dynamically.

### Keyboard Shortcuts

#### General Controls

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open in external editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running task |
| `Ctrl+T` | Toggle task list |
| `Ctrl+X Ctrl+K` | Kill all background agents |
| `Shift+Tab` | Cycle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |

#### Text Editing

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+A` | Move to start of line |
| `Ctrl+E` | Move to end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete to start of line |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

#### Multiline Input

| Method | Shortcut |
| :--- | :--- |
| Quick escape | `\` + `Enter` (all terminals) |
| Control sequence | `Ctrl+J` (all terminals) |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| VS Code / Cursor / Zed | Run `/terminal-setup` once |

#### Quick Prefixes

| Prefix | Effect |
| :--- | :--- |
| `/` at start | Open command/skill menu |
| `!` at start | Shell mode — run directly |
| `@` | File path autocomplete |

### Built-in Tools

| Tool | Permission Required | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawn a subagent |
| `AskUserQuestion` | No | Ask multiple-choice questions |
| `Bash` | Yes | Execute shell commands |
| `CronCreate` | No | Schedule recurring/one-shot prompts |
| `CronDelete` | No | Cancel a scheduled task |
| `CronList` | No | List scheduled tasks |
| `Edit` | Yes | Targeted file edits |
| `EnterPlanMode` | No | Switch to plan mode |
| `EnterWorktree` | No | Create/enter isolated git worktree |
| `ExitPlanMode` | Yes | Present plan and exit plan mode |
| `ExitWorktree` | No | Exit worktree and return to original dir |
| `Glob` | No | Find files by pattern |
| `Grep` | No | Search file contents |
| `LSP` | No | Code intelligence (definitions, refs, types) |
| `Monitor` | Yes | Watch background output and react (v2.1.98+) |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `PowerShell` | Yes | Execute PowerShell commands |
| `Read` | No | Read file contents |
| `Skill` | Yes | Execute a skill |
| `TaskCreate/Get/List/Update` | No | Manage task list (interactive sessions) |
| `TodoWrite` | No | Manage task checklist (headless/SDK) |
| `WebFetch` | Yes | Fetch content from URL |
| `WebSearch` | Yes | Perform web searches |
| `Write` | Yes | Create or overwrite files |

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

Key contexts: `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `Select`, `Scroll`

Action format: `namespace:action` (e.g. `chat:submit`, `app:toggleTodos`). Set to `null` to unbind. Changes apply live without restart.

Reserved (cannot be rebound): `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, `Caps Lock`

### Terminal Configuration

| Issue | Fix |
| :--- | :--- |
| Shift+Enter submits (VS Code / Cursor / Zed) | Run `/terminal-setup` once |
| Option shortcuts do nothing on macOS | Enable Option as Meta in terminal settings |
| No alert when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` in settings, or use a Notification hook |
| Running inside tmux | Add `set -g allow-passthrough on`, `set -s extended-keys on`, `set -as terminal-features 'xterm*:extkeys'` to `~/.tmux.conf` |
| Display flickers / scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Vim keys in prompt | `/config` → Editor mode, or set `editorMode: "vim"` in settings |

Custom themes: JSON files in `~/.claude/themes/<slug>.json`. Fields: `name`, `base` (dark/light/etc.), `overrides` (color token map).

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — all CLI commands and flags
- [Commands](references/claude-code-commands.md) — complete slash commands reference
- [Interactive Mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, Vim mode, shell mode, background tasks
- [Keybindings](references/claude-code-keybindings.md) — keybindings config file, contexts, actions, keystroke syntax
- [Terminal Configuration](references/claude-code-terminal-config.md) — Shift+Enter, Option key, tmux, themes, fullscreen mode
- [Tools Reference](references/claude-code-tools-reference.md) — built-in tools, Bash behavior, LSP, Monitor, PowerShell

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
