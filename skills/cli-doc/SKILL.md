---
name: cli-doc
description: Complete official documentation for the Claude Code CLI — launch commands, flags, interactive mode shortcuts, slash commands, keybindings customization, terminal configuration, and built-in tools reference.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface.

## Quick Reference

### Launch commands

| Command | Description |
| :------ | :---------- |
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive, then exit) |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (use `--console` for API billing) |
| `claude auth status` | Show auth status (use `--text` for human-readable) |
| `claude agents` | List configured subagents |
| `claude plugin` | Manage plugins |
| `claude mcp` | Configure MCP servers |
| `claude setup-token` | Generate a long-lived OAuth token for CI/scripts |
| `claude remote-control` | Start a Remote Control server |

### Key CLI flags

| Flag | Description |
| :--- | :---------- |
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Load most recent conversation |
| `-r`, `--resume` | Resume session by ID or name |
| `-n`, `--name` | Set display name for the session |
| `-w`, `--worktree` | Start in isolated git worktree |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--permission-mode` | Start in a permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--tools` | Restrict available tools (`""` to disable all, `"default"` for all) |
| `--allowedTools` | Tools that execute without prompting |
| `--disallowedTools` | Tools removed from context entirely |
| `--add-dir` | Add additional working directories |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Max dollar amount for API calls (print mode only) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, memory, CLAUDE.md |
| `--mcp-config` | Load MCP servers from JSON file or string |
| `--plugin-dir` | Load plugins from a directory for this session |
| `--agent` | Specify a subagent for the session |
| `--remote` | Create a new web session on claude.ai |
| `--teleport` | Resume a web session in your local terminal |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, `tmux` |
| `--fork-session` | Create new session ID when resuming (with `-r` or `-c`) |
| `--from-pr` | Resume sessions linked to a GitHub PR |
| `--debug` | Enable debug mode with optional category filter |
| `--verbose` | Show full turn-by-turn output |
| `--version`, `-v` | Print version number |

### System prompt flags

| Flag | Behavior |
| :--- | :------- |
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can be combined with either replacement flag. Prefer append flags to preserve Claude Code's built-in capabilities.

### Interactive mode keyboard shortcuts

**General controls:**

| Shortcut | Description |
| :------- | :---------- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit Claude Code |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open in external editor |
| `Ctrl+L` | Clear prompt input and redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running task (tmux users press twice) |
| `Ctrl+T` | Toggle task list |
| `Shift+Tab` | Cycle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |
| `Esc` + `Esc` | Rewind or summarize conversation |
| `Ctrl+V` / `Cmd+V` (iTerm2) | Paste image from clipboard |

**Text editing:**

| Shortcut | Description |
| :------- | :---------- |
| `Ctrl+A` | Move to start of line |
| `Ctrl+E` | Move to end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` / `Alt+F` | Word navigation (requires Option as Meta on macOS) |

**Multiline input:**

| Method | Shortcut |
| :----- | :------- |
| Quick escape | `\` + `Enter` (all terminals) |
| Control sequence | `Ctrl+J` (all terminals) |
| Option key | `Option+Enter` (macOS with Option as Meta) |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal; run `/terminal-setup` for VS Code/Cursor/Windsurf/Alacritty/Zed |

**Quick input prefixes:**

| Prefix | Description |
| :----- | :---------- |
| `/` | Command or skill |
| `!` | Bash mode — runs shell command and adds output to context |
| `@` | File path mention / autocomplete |

### Slash commands (selected)

| Command | Purpose |
| :------ | :------ |
| `/clear` | Start new conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Free up context by summarizing the conversation |
| `/resume [session]` | Resume a session by ID or name (alias: `/continue`) |
| `/branch [name]` | Create a branch of the conversation (alias: `/fork`) |
| `/rewind` | Rewind code/conversation to a previous point (aliases: `/checkpoint`, `/undo`) |
| `/model [model]` | Select or change the AI model |
| `/effort [level]` | Set effort level (`low`, `medium`, `high`, `xhigh`, `max`) |
| `/config` | Open Settings interface (alias: `/settings`) |
| `/permissions` | Manage tool permission rules (alias: `/allowed-tools`) |
| `/plan [description]` | Enter plan mode |
| `/memory` | Edit CLAUDE.md files, manage auto-memory |
| `/hooks` | View hook configurations |
| `/mcp` | Manage MCP server connections |
| `/plugin` | Manage plugins |
| `/skills` | List available skills |
| `/cost` | Show token usage statistics |
| `/context` | Visualize context usage |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/copy [N]` | Copy last assistant response to clipboard |
| `/export [filename]` | Export conversation as plain text |
| `/btw <question>` | Ask a side question without adding to conversation history |
| `/tasks` | List and manage background tasks |
| `/rename [name]` | Rename the current session |
| `/color [color]` | Set prompt bar color for session |
| `/doctor` | Diagnose Claude Code installation and settings |
| `/debug [description]` | Enable debug logging and troubleshoot |
| `/init` | Initialize project with a CLAUDE.md guide |
| `/terminal-setup` | Configure terminal keybindings (Shift+Enter etc.) |
| `/keybindings` | Open or create keybindings configuration file |
| `/recap` | Generate a one-line session summary on demand |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/batch <instruction>` | Orchestrate large-scale parallel codebase changes |
| `/autofix-pr [prompt]` | Spawn web session to auto-fix a PR's CI failures |
| `/loop [interval] [prompt]` | Run a prompt repeatedly on a schedule |
| `/simplify [focus]` | Review and fix recently changed files |
| `/voice [hold\|tap\|off]` | Toggle voice dictation |
| `/status` | Open Settings Status tab (works mid-response) |

Commands marked **[Skill]** in the full reference are bundled skills — they use the same mechanism as user-authored skills.

### Built-in tools

| Tool | Permission Required | Description |
| :--- | :------------------ | :---------- |
| `Agent` | No | Spawns a subagent with its own context |
| `AskUserQuestion` | No | Asks multiple-choice questions |
| `Bash` | Yes | Executes shell commands |
| `Edit` | Yes | Makes targeted edits to files |
| `Read` | No | Reads file contents |
| `Write` | Yes | Creates or overwrites files |
| `Glob` | No | Finds files by pattern |
| `Grep` | No | Searches file contents for patterns |
| `WebFetch` | Yes | Fetches content from a URL |
| `WebSearch` | Yes | Performs web searches |
| `Skill` | Yes | Executes a skill within the conversation |
| `Monitor` | Yes | Watches a process and reacts to output lines |
| `LSP` | No | Code intelligence via language servers |
| `NotebookEdit` | Yes | Modifies Jupyter notebook cells |
| `PowerShell` | Yes | Executes PowerShell commands (Windows/opt-in) |
| `EnterPlanMode` | No | Switches to plan mode |
| `ExitPlanMode` | Yes | Presents plan and exits plan mode |
| `EnterWorktree` | No | Creates/switches into git worktree |
| `ExitWorktree` | No | Exits worktree, returns to original directory |
| `TaskCreate` | No | Creates task in task list |
| `TaskList` | No | Lists all tasks |
| `TaskUpdate` | No | Updates task status/details |
| `TaskStop` | No | Kills a running background task |
| `CronCreate` | No | Schedules a recurring/one-shot prompt |
| `CronList` | No | Lists scheduled tasks |
| `CronDelete` | No | Cancels a scheduled task |
| `SendMessage` | No | Sends message to agent team teammate |
| `TeamCreate` | No | Creates an agent team |
| `TeamDelete` | No | Disbands an agent team |
| `TodoWrite` | No | Manages session checklist (non-interactive/Agent SDK) |
| `ToolSearch` | No | Searches for and loads deferred tools |
| `ListMcpResourcesTool` | No | Lists MCP server resources |
| `ReadMcpResourceTool` | No | Reads a specific MCP resource |

Bash tool notes: `cd` persists within the project directory. Environment variables do NOT persist between Bash calls. Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to disable working directory carry-over.

### Keybindings configuration

File: `~/.claude/keybindings.json` (open with `/keybindings`). Changes apply automatically without restarting.

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

Actions use `namespace:action` format (e.g., `chat:submit`, `app:toggleTodos`). Set an action to `null` to unbind. Reserved and non-rebindable: `Ctrl+C`, `Ctrl+D`, `Ctrl+M`.

Key contexts: `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `Settings`, `ThemePicker`, `Scroll`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Doctor`.

### Terminal configuration

| Issue | Fix |
| :---- | :-- |
| Shift+Enter submits instead of newline | Run `/terminal-setup` (VS Code/Cursor/Windsurf/Alacritty/Zed); tmux needs `extended-keys on` in `~/.tmux.conf` |
| Option-key shortcuts do nothing (macOS) | Enable Option as Meta in terminal settings |
| No bell/alert when Claude finishes | Add a `Notification` hook, or enable in Ghostty/Kitty/iTerm2 |
| Display flickers or scroll jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Running inside tmux | Add `set -g allow-passthrough on`, `set -s extended-keys on`, `set -as terminal-features 'xterm*:extkeys'` to `~/.tmux.conf` |

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — complete table of launch commands and all CLI flags with examples
- [Commands](references/claude-code-commands.md) — full list of slash commands available in interactive mode, including bundled skills and MCP prompts
- [Interactive mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, vim editor mode, command history, background bash, prompt suggestions, `/btw` side questions, task list, and session recap
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) — keybindings configuration file format, all contexts, all available actions with defaults, keystroke syntax, chords, and reserved shortcuts
- [Configure your terminal](references/claude-code-terminal-config.md) — Shift+Enter setup, Option key on macOS, terminal bell/notifications, tmux configuration, fullscreen rendering, and vim mode
- [Tools reference](references/claude-code-tools-reference.md) — complete tool table with permission requirements, Bash/LSP/Monitor/PowerShell tool behavior details

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure your terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
