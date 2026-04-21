---
name: cli-doc
description: Complete official documentation for the Claude Code CLI — command-line flags, session commands, interactive keyboard shortcuts, keybindings customization, terminal configuration, and built-in tools reference.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, keybindings, terminal configuration, and tools.

## Quick Reference

### CLI commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode: run query and exit (SDK/scripted use) |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in to Anthropic account |
| `claude auth logout` | Log out |
| `claude auth status` | Show authentication status (JSON; `--text` for human-readable) |
| `claude agents` | List configured subagents |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude remote-control` | Start a Remote Control server |
| `claude setup-token` | Generate a long-lived OAuth token for CI |

### Key CLI flags

| Flag | Description |
| :--- | :--- |
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Continue most recent conversation |
| `-r`, `--resume` | Resume session by ID or name (or show picker) |
| `-n`, `--name` | Set a display name for the session |
| `-w`, `--worktree` | Start in an isolated git worktree |
| `--model` | Set model (`sonnet`, `opus`, or full model ID) |
| `--permission-mode` | Start in a specific permission mode (`default`, `acceptEdits`, `plan`, `auto`, `bypassPermissions`) |
| `--system-prompt` | Replace entire system prompt with custom text |
| `--append-system-prompt` | Append text to default system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append file contents to system prompt |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns in print mode |
| `--max-budget-usd` | Max spend per print-mode call |
| `--allowedTools` | Tools that run without permission prompts |
| `--disallowedTools` | Tools removed from model context |
| `--tools` | Restrict built-in tools (`""` = none, `"default"` = all) |
| `--add-dir` | Add additional working directories |
| `--mcp-config` | Load MCP servers from JSON file or string |
| `--plugin-dir` | Load plugins from a local directory (session only) |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--debug` | Enable debug mode (optional category filter) |
| `--verbose` | Show full turn-by-turn output |
| `--fork-session` | Create new session ID when resuming |
| `--no-session-persistence` | Disable session persistence (print mode) |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves prompt-cache reuse) |
| `--agents` | Define custom subagents dynamically via JSON |
| `--agent` | Specify an agent for the current session |

### System prompt flags summary

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag. Prefer append flags to preserve Claude Code's built-in capabilities.

### Session commands (type `/` in interactive mode)

Selected key commands — type `/` to see the full list:

| Command | Purpose |
| :--- | :--- |
| `/clear` | Start new conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Summarize conversation to free up context |
| `/resume [session]` | Resume a conversation (alias: `/continue`) |
| `/branch [name]` | Fork conversation at current point (alias: `/fork`) |
| `/rename [name]` | Rename current session |
| `/model [model]` | Switch model |
| `/effort [level]` | Set effort level |
| `/plan [description]` | Enter plan mode |
| `/permissions` | Manage allow/ask/deny rules (alias: `/allowed-tools`) |
| `/config` | Open settings UI (alias: `/settings`) |
| `/context` | Visualize context usage |
| `/memory` | Edit CLAUDE.md files and manage auto-memory |
| `/diff` | Interactive diff viewer |
| `/rewind` | Rewind code/conversation (aliases: `/checkpoint`, `/undo`) |
| `/copy [N]` | Copy last (or Nth-last) assistant response |
| `/export [filename]` | Export conversation as plain text |
| `/cost` | Show token usage statistics |
| `/btw <question>` | Ask side question without adding to context |
| `/status` | Open Settings (Status tab) |
| `/doctor` | Diagnose installation and settings |
| `/skills` | List available skills |
| `/hooks` | View hook configurations |
| `/mcp` | Manage MCP server connections |
| `/plugin` | Manage plugins |
| `/reload-plugins` | Reload plugins without restarting |
| `/keybindings` | Open/create keybindings config file |
| `/terminal-setup` | Configure Shift+Enter in terminals that need it |
| `/init` | Initialize project CLAUDE.md |
| `/help` | Show help and available commands |
| `/exit` | Exit CLI (alias: `/quit`) |

Skill-backed commands (marked **[Skill]** in the full reference): `/batch`, `/debug`, `/fewer-permission-prompts`, `/loop`, `/simplify`, `/claude-api`.

### Interactive keyboard shortcuts

#### General controls

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit Claude Code |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open prompt in external editor |
| `Ctrl+L` | Clear prompt input and redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse-search command history |
| `Ctrl+B` | Background running task (press twice in tmux) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+X Ctrl+K` | Kill all background agents |
| `Shift+Tab` | Cycle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |
| `Esc` + `Esc` | Rewind or summarize |

#### Multiline input

| Method | Shortcut |
| :--- | :--- |
| Universal | `\` + `Enter` |
| Universal | `Ctrl+J` |
| macOS (Option as Meta) | `Option+Enter` |
| Native (iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal) | `Shift+Enter` |
| VS Code/Cursor/Windsurf/Alacritty/Zed | `Shift+Enter` after running `/terminal-setup` |

#### Quick input prefixes

| Prefix | Behavior |
| :--- | :--- |
| `/` | Command or skill |
| `!` | Bash mode (runs command directly, output added to context) |
| `@` | File path autocomplete |

### Keybindings customization

Config file: `~/.claude/keybindings.json` (run `/keybindings` to open/create it). Changes apply without restart.

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

Actions use `namespace:action` format (e.g., `chat:submit`, `app:toggleTodos`). Set an action to `null` to unbind it.

Key contexts: `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `Settings`, `Select`, `Plugin`, `Scroll`.

Reserved shortcuts that cannot be rebound: `Ctrl+C`, `Ctrl+D`, `Ctrl+M`.

### Terminal configuration

| Symptom | Fix |
| :--- | :--- |
| Shift+Enter submits instead of newline | Run `/terminal-setup` (VS Code, Cursor, Windsurf, Alacritty, Zed); no setup needed in iTerm2, Ghostty, Kitty, WezTerm, Warp, Apple Terminal |
| Option shortcuts do nothing (macOS) | Enable "Option as Meta" in terminal settings |
| No bell when Claude finishes | Configure Notification hook in `~/.claude/settings.json` |
| Running inside tmux | Add `set -g allow-passthrough on`, `set -s extended-keys on`, `set -as terminal-features 'xterm*:extkeys'` to `~/.tmux.conf` |
| Display flickers/scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |

### Built-in tools reference

| Tool | Permission Required | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawns a subagent with its own context window |
| `AskUserQuestion` | No | Asks multiple-choice questions |
| `Bash` | Yes | Executes shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Schedule recurring/one-shot prompts |
| `Edit` | Yes | Makes targeted edits to files |
| `EnterPlanMode` / `ExitPlanMode` | No/Yes | Plan mode switching |
| `EnterWorktree` / `ExitWorktree` | No | Isolated git worktree management |
| `Glob` | No | Finds files by pattern |
| `Grep` | No | Searches file contents |
| `LSP` | No | Code intelligence (requires language server plugin) |
| `Monitor` | Yes | Watches a command in the background and feeds output to Claude |
| `NotebookEdit` | Yes | Modifies Jupyter notebook cells |
| `PowerShell` | Yes | Executes PowerShell (opt-in; native on Windows rollout) |
| `Read` | No | Reads file contents |
| `Skill` | Yes | Executes a skill within the main conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Task list management (interactive sessions) |
| `TodoWrite` | No | Session task checklist (non-interactive/Agent SDK) |
| `ToolSearch` | No | Searches and loads deferred MCP tools |
| `WebFetch` | Yes | Fetches content from a URL |
| `WebSearch` | Yes | Performs web searches |
| `Write` | Yes | Creates or overwrites files |

Tools are restricted per session via `--tools`, `--allowedTools`, `--disallowedTools`, or permission settings. Use `/mcp` to see current MCP tool names.

**Bash tool notes:** `cd` carries over within the project directory; environment variables do not persist across commands. Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to disable `cd` carry-over.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — complete CLI commands and all flags with examples
- [Commands](references/claude-code-commands.md) — all `/`-commands available in interactive sessions, including bundled skill commands
- [Interactive mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, Vim editor mode, bash mode, prompt suggestions, `/btw` side questions, task list, session recap, PR review status
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) — keybindings config format, all contexts, all actions, keystroke syntax, unbinding, reserved shortcuts, terminal conflicts, vim mode interaction
- [Configure your terminal](references/claude-code-terminal-config.md) — Shift+Enter setup, Option key on macOS, terminal bell/notifications, tmux configuration, fullscreen rendering, Vim mode
- [Tools reference](references/claude-code-tools-reference.md) — complete built-in tools table, Bash/LSP/Monitor/PowerShell tool behavior details

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure your terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
