---
name: cli
description: Reference documentation for the Claude Code CLI — command-line commands and flags, interactive mode keyboard shortcuts, slash commands, vim mode, bash mode, multiline input, background tasks, keybinding customization, and terminal configuration. Covers all CLI flags including system prompt, output format, permission modes, MCP config, session management, and worktrees.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, keybindings, and terminal configuration.

## Quick Reference

### CLI Commands

| Command                         | Description                                    |
|:--------------------------------|:-----------------------------------------------|
| `claude`                        | Start interactive REPL                         |
| `claude "query"`                | Start REPL with initial prompt                 |
| `claude -p "query"`             | Print mode (non-interactive), then exit        |
| `cat file \| claude -p "query"` | Process piped content                          |
| `claude -c`                     | Continue most recent conversation              |
| `claude -c -p "query"`          | Continue via SDK                               |
| `claude -r "name" "query"`      | Resume session by ID or name                   |
| `claude update`                 | Update to latest version                       |
| `claude agents`                 | List all configured subagents                  |
| `claude mcp`                    | Configure MCP servers                          |

### Key CLI Flags

| Flag                                   | Description                                                        |
|:---------------------------------------|:-------------------------------------------------------------------|
| `--print`, `-p`                        | Non-interactive print mode                                         |
| `--continue`, `-c`                     | Continue most recent conversation                                  |
| `--resume`, `-r`                       | Resume session by ID or name                                       |
| `--model`                              | Set model (`sonnet`, `opus`, or full name)                         |
| `--system-prompt`                      | Replace entire system prompt                                       |
| `--append-system-prompt`               | Append to default system prompt                                    |
| `--system-prompt-file`                 | Replace system prompt from file (print mode only)                  |
| `--append-system-prompt-file`          | Append system prompt from file (print mode only)                   |
| `--output-format`                      | Output format: `text`, `json`, `stream-json`                       |
| `--input-format`                       | Input format: `text`, `stream-json`                                |
| `--json-schema`                        | Validated JSON output matching a schema (print mode only)          |
| `--max-turns`                          | Limit agentic turns (print mode only)                              |
| `--max-budget-usd`                     | Maximum API spend (print mode only)                                |
| `--permission-mode`                    | Start in a permission mode (`plan`, etc.)                          |
| `--dangerously-skip-permissions`       | Skip all permission prompts                                        |
| `--allowedTools`                       | Tools that execute without permission prompts                      |
| `--disallowedTools`                    | Tools removed from model context                                   |
| `--tools`                              | Restrict available built-in tools                                  |
| `--mcp-config`                         | Load MCP servers from JSON file                                    |
| `--strict-mcp-config`                  | Only use MCP servers from `--mcp-config`                           |
| `--add-dir`                            | Add additional working directories                                 |
| `--agents`                             | Define custom subagents via JSON                                   |
| `--agent`                              | Specify agent for session                                          |
| `--worktree`, `-w`                     | Start in isolated git worktree                                     |
| `--plugin-dir`                         | Load plugins from directory                                        |
| `--chrome` / `--no-chrome`             | Enable/disable Chrome browser integration                          |
| `--remote`                             | Create new web session on claude.ai                                |
| `--teleport`                           | Resume a web session locally                                       |
| `--verbose`                            | Enable verbose logging                                             |
| `--debug`                              | Enable debug mode with category filtering                          |
| `--version`, `-v`                      | Output version number                                              |

### System Prompt Flags

| Flag                          | Behavior          | Modes               |
|:------------------------------|:------------------|:---------------------|
| `--system-prompt`             | Replaces default  | Interactive + Print  |
| `--system-prompt-file`        | Replaces from file| Print only           |
| `--append-system-prompt`      | Appends to default| Interactive + Print  |
| `--append-system-prompt-file` | Appends from file | Print only           |

### General Keyboard Shortcuts

| Shortcut   | Description                          |
|:-----------|:-------------------------------------|
| `Ctrl+C`   | Cancel current input or generation   |
| `Ctrl+D`   | Exit session                         |
| `Ctrl+G`   | Open in external text editor         |
| `Ctrl+L`   | Clear terminal screen                |
| `Ctrl+O`   | Toggle verbose output                |
| `Ctrl+R`   | Reverse search command history       |
| `Ctrl+B`   | Background running tasks             |
| `Ctrl+T`   | Toggle task list                     |
| `Ctrl+V`   | Paste image from clipboard           |
| `Shift+Tab`| Toggle permission modes              |
| `Alt+P`    | Switch model                         |
| `Alt+T`    | Toggle extended thinking             |
| `Esc Esc`  | Rewind or summarize                  |

### Multiline Input

| Method          | Shortcut       | Notes                                           |
|:----------------|:---------------|:------------------------------------------------|
| Quick escape    | `\` + `Enter`  | Works in all terminals                          |
| macOS default   | `Option+Enter` | Default on macOS                                |
| Shift+Enter     | `Shift+Enter`  | Native in iTerm2, WezTerm, Ghostty, Kitty       |
| Control sequence| `Ctrl+J`       | Line feed character                             |
| Paste mode      | Paste directly | For code blocks, logs                           |

### Quick Input Prefixes

| Prefix       | Description                                          |
|:-------------|:-----------------------------------------------------|
| `/` at start | Invoke slash command or skill                        |
| `!` at start | Run bash command directly, output added to context   |
| `@`          | File path autocomplete                               |

### Common Slash Commands

| Command                   | Purpose                                      |
|:--------------------------|:---------------------------------------------|
| `/clear`                  | Clear conversation history                   |
| `/compact [instructions]` | Compact conversation                         |
| `/config`                 | Open settings interface                      |
| `/context`                | Visualize context usage                      |
| `/cost`                   | Show token usage statistics                  |
| `/doctor`                 | Check installation health                    |
| `/export [filename]`      | Export conversation                          |
| `/init`                   | Initialize project with CLAUDE.md            |
| `/memory`                 | Edit CLAUDE.md memory files                  |
| `/model`                  | Select or change AI model                    |
| `/permissions`            | View or update permissions                   |
| `/plan`                   | Enter plan mode                              |
| `/rename <name>`          | Rename session                               |
| `/resume [session]`       | Resume conversation                          |
| `/rewind`                 | Rewind conversation and/or code              |
| `/tasks`                  | List and manage background tasks             |
| `/theme`                  | Change color theme                           |
| `/vim`                    | Enable vim editing mode                      |

### Keybinding Customization

Keybindings are configured in `~/.claude/keybindings.json`. Run `/keybindings` to create or open the file. Changes are hot-reloaded.

**Binding contexts**: `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`

**Keystroke syntax**: `ctrl+k`, `shift+tab`, `meta+p`, `ctrl+shift+c`. Chords: `ctrl+k ctrl+s`. Set action to `null` to unbind. Reserved: `Ctrl+C`, `Ctrl+D`.

### Terminal Configuration

- **Shift+Enter**: Native in iTerm2, WezTerm, Ghostty, Kitty. Run `/terminal-setup` for VS Code, Alacritty, Zed, Warp.
- **Option as Meta** (macOS): iTerm2 Settings > Profiles > Keys > "Esc+"; Terminal.app Settings > Profiles > Keyboard > "Use Option as Meta Key"
- **Notifications**: Native in Kitty, Ghostty. iTerm2: Settings > Profiles > Terminal > enable "Notification Center Alerts". Others: use notification hooks.
- **Vim mode**: Enable with `/vim` or via `/config`. Supports mode switching, navigation, editing, yank/paste, text objects.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) -- complete list of CLI commands, flags, agents flag format, and system prompt customization
- [Interactive Mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts, slash commands, vim mode, bash mode, background tasks, prompt suggestions, task list, PR review status
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) -- keybindings.json format, all contexts and actions, keystroke syntax, chords, unbinding, reserved keys, vim mode interaction
- [Terminal Configuration](references/claude-code-terminal-config.md) -- themes, line breaks, Shift+Enter setup, notifications, large inputs, vim mode

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
