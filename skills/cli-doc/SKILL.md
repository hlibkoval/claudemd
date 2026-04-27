---
name: cli-doc
description: Complete official documentation for the Claude Code CLI — launch commands, all CLI flags, in-session slash commands, keyboard shortcuts, interactive mode features, keybinding customization, terminal configuration, and the built-in tools reference.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface.

## Quick Reference

### CLI launch commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start with initial prompt |
| `claude -p "query"` | Print mode (non-interactive, then exit) |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install or reinstall the native binary |
| `claude auth login` | Sign in (use `--console` for API key billing) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status (JSON; `--text` for human-readable) |
| `claude agents` | List configured subagents |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude remote-control` | Start Remote Control server |
| `claude setup-token` | Generate a long-lived OAuth token for CI |

### Key CLI flags

| Flag | Description |
| :--- | :--- |
| `--print`, `-p` | Non-interactive print mode |
| `--continue`, `-c` | Load most recent conversation |
| `--resume`, `-r` | Resume by session ID or name |
| `--model` | Set model (`sonnet`, `opus`, or full model ID) |
| `--permission-mode` | Start in a permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--output-format` | Print mode output: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Spending cap in USD (print mode only) |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append to system prompt from file |
| `--allowedTools` | Tools that execute without permission prompt |
| `--disallowedTools` | Tools removed from the model's context |
| `--tools` | Restrict available built-in tools |
| `--add-dir` | Add additional working directories |
| `--mcp-config` | Load MCP servers from JSON file or string |
| `--bare` | Minimal mode — skip hooks, skills, plugins, MCP, memory, CLAUDE.md |
| `--worktree`, `-w` | Start in an isolated git worktree |
| `--tmux` | Create a tmux session for the worktree |
| `--effort` | Session effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--name`, `-n` | Set a display name for the session |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a pull request |
| `--agents` | Define custom subagents dynamically via JSON |
| `--agent` | Specify an agent for the current session |
| `--plugin-dir` | Load plugins from a directory (session only) |
| `--verbose` | Show full turn-by-turn output |
| `--debug` | Enable debug mode with optional category filter |
| `--debug-file <path>` | Write debug logs to a file |
| `--json-schema` | Get validated JSON output matching a schema (print mode) |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves cache reuse) |
| `--no-session-persistence` | Do not save session to disk (print mode only) |
| `--version`, `-v` | Print version number |

### System prompt flags summary

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag. Prefer append flags to preserve Claude Code's built-in capabilities.

### In-session slash commands (selected)

| Command | Type | Purpose |
| :--- | :--- | :--- |
| `/add-dir <path>` | Built-in | Add a working directory for the session |
| `/agents` | Built-in | Manage agent configurations |
| `/batch <instruction>` | Skill | Orchestrate large-scale parallel changes |
| `/btw <question>` | Built-in | Ask a side question without adding to context |
| `/clear` | Built-in | Start new conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Built-in | Summarize conversation to free context |
| `/config` | Built-in | Open Settings interface (alias: `/settings`) |
| `/context` | Built-in | Visualize context usage |
| `/copy [N]` | Built-in | Copy last (or Nth) assistant response |
| `/debug [description]` | Skill | Enable debug logging and troubleshoot |
| `/diff` | Built-in | Interactive diff viewer |
| `/doctor` | Built-in | Diagnose installation and settings |
| `/effort [level]` | Built-in | Set model effort level |
| `/export [filename]` | Built-in | Export conversation as plain text |
| `/help` | Built-in | Show available commands |
| `/hooks` | Built-in | View hook configurations |
| `/init` | Built-in | Initialize project CLAUDE.md |
| `/keybindings` | Built-in | Open keybindings config file |
| `/loop [interval] [prompt]` | Skill | Run a prompt on a schedule |
| `/mcp` | Built-in | Manage MCP connections |
| `/memory` | Built-in | Edit CLAUDE.md files and auto-memory |
| `/model [model]` | Built-in | Select or change AI model |
| `/permissions` | Built-in | Manage tool permission rules |
| `/plan [description]` | Built-in | Enter plan mode |
| `/plugin` | Built-in | Manage plugins |
| `/recap` | Built-in | Generate one-line session summary |
| `/reload-plugins` | Built-in | Reload plugins without restarting |
| `/remote-control` | Built-in | Enable remote control from claude.ai |
| `/rename [name]` | Built-in | Rename the current session |
| `/resume [session]` | Built-in | Resume a conversation (alias: `/continue`) |
| `/review [PR]` | Built-in | Review a pull request locally |
| `/rewind` | Built-in | Rewind conversation/code to a previous point |
| `/schedule [description]` | Built-in | Create or manage routines |
| `/simplify [focus]` | Skill | Review and fix code quality issues |
| `/skills` | Built-in | List available skills |
| `/status` | Built-in | Open Settings Status tab |
| `/tasks` | Built-in | List and manage background tasks |
| `/theme` | Built-in | Change color theme |
| `/tui [default\|fullscreen]` | Built-in | Set terminal UI renderer |
| `/ultraplan <prompt>` | Built-in | Draft and execute plans via ultraplan |
| `/ultrareview [PR]` | Built-in | Deep multi-agent cloud code review |
| `/usage` | Built-in | Show session cost and plan limits |
| `/voice [hold\|tap\|off]` | Built-in | Toggle voice dictation |

MCP servers can expose prompts as commands using `/mcp__<server>__<prompt>` format.

### Keyboard shortcuts (general controls)

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open in external text editor |
| `Ctrl+L` | Clear prompt input and redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running task (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+X Ctrl+K` | Kill all background agents |
| `Shift+Tab` | Cycle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |
| `Esc Esc` | Rewind or summarize conversation |

### Multiline input methods

| Method | Shortcut | Notes |
| :--- | :--- | :--- |
| Quick escape | `\` + Enter | Works in all terminals |
| Control sequence | Ctrl+J | Works anywhere without config |
| Shift+Enter | Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal |
| Option key | Option+Enter | Requires Option as Meta on macOS |

### Quick input prefixes

| Prefix | Action |
| :--- | :--- |
| `/` | Command or skill |
| `!` | Run bash directly (adds output to context) |
| `@` | File path autocomplete |

### Built-in tools reference

| Tool | Permission Required | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawns a subagent with its own context |
| `AskUserQuestion` | No | Asks multiple-choice questions |
| `Bash` | Yes | Executes shell commands |
| `CronCreate` | No | Schedules a recurring or one-shot prompt |
| `CronDelete` | No | Cancels a scheduled task |
| `CronList` | No | Lists all scheduled tasks |
| `Edit` | Yes | Makes targeted edits to files |
| `EnterPlanMode` | No | Switches to plan mode |
| `ExitPlanMode` | Yes | Presents plan and exits plan mode |
| `EnterWorktree` | No | Creates/switches to an isolated git worktree |
| `ExitWorktree` | No | Exits a worktree session |
| `Glob` | No | Finds files by pattern |
| `Grep` | No | Searches file contents for patterns |
| `LSP` | No | Code intelligence (jump to definition, references, errors) |
| `Monitor` | Yes | Watches a command output and feeds lines to Claude |
| `NotebookEdit` | Yes | Modifies Jupyter notebook cells |
| `PowerShell` | Yes | Executes PowerShell commands (Windows / opt-in) |
| `Read` | No | Reads file contents |
| `Skill` | Yes | Executes a skill in the main conversation |
| `TaskCreate` | No | Creates a task in the task list |
| `TaskGet` | No | Retrieves full details for a task |
| `TaskList` | No | Lists all tasks with status |
| `TaskStop` | No | Kills a background task by ID |
| `TaskUpdate` | No | Updates task status, dependencies, or details |
| `TodoWrite` | No | Manages session task checklist (non-interactive / Agent SDK) |
| `ToolSearch` | No | Searches for and loads deferred tools |
| `WebFetch` | Yes | Fetches content from a URL |
| `WebSearch` | Yes | Performs web searches |
| `Write` | Yes | Creates or overwrites files |

Use tool names exactly as listed for permission rules, subagent tool lists, and hook matchers.

### Keybindings customization

Config file: `~/.claude/keybindings.json` (open with `/keybindings`, auto-reloads on save)

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

Available contexts: `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Scroll`, `Doctor`

Key action namespaces: `app:`, `chat:`, `history:`, `autocomplete:`, `confirm:`, `permission:`, `transcript:`, `historySearch:`, `task:`, `theme:`, `tabs:`, `attachments:`, `footer:`, `messageSelector:`, `diff:`, `modelPicker:`, `select:`, `plugin:`, `settings:`, `doctor:`, `voice:`, `scroll:`

Reserved (cannot rebind): `Ctrl+C`, `Ctrl+D`, `Ctrl+M`

Set an action to `null` to unbind it. Keystroke syntax uses `+` separator for modifiers: `ctrl`, `shift`, `alt`/`meta`, `cmd`.

### Terminal configuration quick fixes

| Symptom | Fix |
| :--- | :--- |
| Shift+Enter submits in VS Code / Cursor / Windsurf / Alacritty / Zed | Run `/terminal-setup` once |
| Option shortcuts do nothing on macOS | Enable "Option as Meta" in terminal settings |
| No sound/alert when Claude finishes | Configure a [Notification hook](/en/hooks-guide#get-notified-when-claude-needs-input) or enable iTerm2 notification forwarding |
| Running inside tmux | Add `allow-passthrough on`, `extended-keys on`, `terminal-features 'xterm*:extkeys'` to `~/.tmux.conf` |
| Display flickers or scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Vim keys in the prompt | Enable via `/config` → Editor mode or set `editorMode: "vim"` in settings |

### Bash tool behavior notes

- `cd` in the main session carries the working directory to later commands (within project/add-dir boundaries)
- Environment variables do not persist across Bash commands; use `CLAUDE_ENV_FILE` or a `SessionStart` hook
- Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to always start Bash in the project directory
- Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable background task functionality

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — all CLI commands and flags with examples
- [Commands](references/claude-code-commands.md) — complete in-session slash command reference
- [Interactive Mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, Vim mode, bash mode, background tasks, side questions
- [Keybindings](references/claude-code-keybindings.md) — customizing keyboard shortcuts via keybindings.json
- [Terminal Configuration](references/claude-code-terminal-config.md) — fixing Shift+Enter, Option key, tmux, themes, fullscreen, Vim mode
- [Tools Reference](references/claude-code-tools-reference.md) — built-in tools, permission requirements, Bash/LSP/Monitor/PowerShell behavior

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
