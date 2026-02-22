---
name: cli
description: Reference documentation for the Claude Code CLI — command-line commands, flags, interactive mode shortcuts, keybindings customization, built-in slash commands, vim mode, bash mode, background tasks, multiline input, terminal configuration, and session management.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, keybindings, and terminal configuration.

## Quick Reference

### CLI Commands

| Command                         | Description                                |
|:--------------------------------|:-------------------------------------------|
| `claude`                        | Start interactive REPL                     |
| `claude "query"`                | Start REPL with initial prompt             |
| `claude -p "query"`             | Run query, print response, exit            |
| `cat file \| claude -p "query"` | Process piped content                      |
| `claude -c`                     | Continue most recent conversation          |
| `claude -c -p "query"`          | Continue via SDK (non-interactive)         |
| `claude -r "name" "query"`      | Resume session by ID or name               |
| `claude update`                 | Update to latest version                   |
| `claude agents`                 | List all configured subagents              |
| `claude mcp`                    | Configure MCP servers                      |

### Key CLI Flags

| Flag                                   | Description                                                                    |
|:---------------------------------------|:-------------------------------------------------------------------------------|
| `--model`                              | Set model (`sonnet`, `opus`, or full name)                                     |
| `--print`, `-p`                        | Non-interactive mode (print and exit)                                          |
| `--continue`, `-c`                     | Continue most recent conversation                                              |
| `--resume`, `-r`                       | Resume session by ID or name                                                   |
| `--add-dir`                            | Add additional working directories                                             |
| `--system-prompt`                      | Replace entire system prompt (interactive + print)                             |
| `--append-system-prompt`               | Append to default system prompt (interactive + print)                          |
| `--system-prompt-file`                 | Replace system prompt from file (print only)                                   |
| `--append-system-prompt-file`          | Append from file (print only)                                                  |
| `--allowedTools`                       | Tools that skip permission prompts                                             |
| `--disallowedTools`                    | Tools removed from context entirely                                            |
| `--tools`                              | Restrict available tools (`""`, `"default"`, `"Bash,Edit,Read"`)               |
| `--permission-mode`                    | Start in permission mode (`plan`, etc.)                                        |
| `--dangerously-skip-permissions`       | Skip all permission prompts                                                    |
| `--output-format`                      | Output format: `text`, `json`, `stream-json` (print mode)                      |
| `--json-schema`                        | Validated JSON output matching schema (print mode)                             |
| `--max-turns`                          | Limit agentic turns (print mode)                                               |
| `--max-budget-usd`                     | Maximum spend before stopping (print mode)                                     |
| `--mcp-config`                         | Load MCP servers from JSON file                                                |
| `--agents`                             | Define custom subagents via JSON                                               |
| `--worktree`, `-w`                     | Start in isolated git worktree                                                 |
| `--plugin-dir`                         | Load plugins from directory                                                    |
| `--remote`                             | Create web session on claude.ai                                                |
| `--teleport`                           | Resume a web session locally                                                   |
| `--verbose`                            | Show full turn-by-turn output                                                  |
| `--chrome` / `--no-chrome`             | Enable/disable Chrome browser integration                                      |

### Built-in Slash Commands

| Command                   | Purpose                                      |
|:--------------------------|:---------------------------------------------|
| `/clear`                  | Clear conversation history                   |
| `/compact [instructions]` | Compact conversation with optional focus     |
| `/config`                 | Open settings interface                      |
| `/context`                | Visualize context usage                      |
| `/cost`                   | Show token usage statistics                  |
| `/debug [description]`    | Troubleshoot session via debug log           |
| `/doctor`                 | Check installation health                    |
| `/export [filename]`      | Export conversation to file or clipboard      |
| `/init`                   | Initialize project with CLAUDE.md            |
| `/memory`                 | Edit CLAUDE.md memory files                  |
| `/model`                  | Select or change AI model                    |
| `/permissions`            | View or update permissions                   |
| `/plan`                   | Enter plan mode                              |
| `/rename <name>`          | Rename current session                       |
| `/resume [session]`       | Resume conversation or open session picker   |
| `/rewind`                 | Rewind conversation and/or code              |
| `/theme`                  | Change color theme                           |
| `/vim`                    | Toggle vim editing mode                      |

### General Keyboard Shortcuts

| Shortcut     | Description                          |
|:-------------|:-------------------------------------|
| `Ctrl+C`     | Cancel current input or generation   |
| `Ctrl+D`     | Exit Claude Code                     |
| `Ctrl+G`     | Open in default text editor          |
| `Ctrl+L`     | Clear terminal screen                |
| `Ctrl+O`     | Toggle verbose output                |
| `Ctrl+R`     | Reverse search command history       |
| `Ctrl+B`     | Background running task              |
| `Ctrl+T`     | Toggle task list                     |
| `Shift+Tab`  | Cycle permission modes               |
| `Alt+P`      | Switch model                         |
| `Alt+T`      | Toggle extended thinking             |
| `Esc Esc`    | Rewind / summarize                   |

### Quick Input Prefixes

| Prefix       | Description                                  |
|:-------------|:---------------------------------------------|
| `/`          | Slash command or skill                       |
| `!`          | Bash mode (run shell command directly)       |
| `@`          | File path autocomplete                       |

### Multiline Input

| Method         | Shortcut         | Notes                                        |
|:---------------|:-----------------|:---------------------------------------------|
| Quick escape   | `\` + `Enter`    | Works in all terminals                       |
| macOS          | `Option+Enter`   | Default on macOS                             |
| Shift+Enter    | `Shift+Enter`    | Native in iTerm2, WezTerm, Ghostty, Kitty    |
| Control seq    | `Ctrl+J`         | Line feed character                          |

Run `/terminal-setup` to configure Shift+Enter in VS Code, Alacritty, Zed, and Warp.

### Keybindings Customization

Configure via `~/.claude/keybindings.json` (run `/keybindings` to create/open). Changes apply without restart.

| Context           | Description                       |
|:------------------|:----------------------------------|
| `Global`          | Applies everywhere                |
| `Chat`            | Main chat input                   |
| `Autocomplete`    | Autocomplete menu open            |
| `Confirmation`    | Permission dialogs                |
| `HistorySearch`   | Ctrl+R search mode                |
| `Task`            | Background task running           |
| `ThemePicker`     | Theme picker dialog               |
| `DiffDialog`      | Diff viewer navigation            |

Actions use `namespace:action` format (e.g., `chat:submit`, `app:toggleTodos`). Set to `null` to unbind. Reserved: `Ctrl+C`, `Ctrl+D`.

### Terminal Configuration

**Option as Meta (macOS)** -- required for `Alt+` shortcuts:
- iTerm2: Settings > Profiles > Keys > Set Option key to "Esc+"
- Terminal.app: Settings > Profiles > Keyboard > Check "Use Option as Meta Key"
- VS Code: Settings > Profiles > Keys > Set Option key to "Esc+"

**Notifications (iTerm 2):** Preferences > Profiles > Terminal > Enable "Silence bell" and set filter alerts.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) -- commands, flags, system prompt flags, `--agents` format
- [Interactive Mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts, slash commands, vim mode, bash mode, background tasks, task list, PR review status
- [Keybindings](references/claude-code-keybindings.md) -- customizable keyboard shortcuts, contexts, actions, keystroke syntax, chord sequences
- [Terminal Configuration](references/claude-code-terminal-config.md) -- line breaks, Shift+Enter setup, notifications, vim mode, handling large inputs

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
