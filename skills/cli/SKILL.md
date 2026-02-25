---
name: cli
description: Reference documentation for Claude Code CLI — command-line commands, flags, system prompt customization, interactive mode shortcuts, keybindings configuration, slash commands, vim mode, bash mode, background tasks, terminal setup, multiline input, and session management.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, keyboard shortcuts, and terminal configuration.

## Quick Reference

### CLI Commands

| Command                         | Description                              |
|:--------------------------------|:-----------------------------------------|
| `claude`                        | Start interactive REPL                   |
| `claude "query"`                | Start REPL with initial prompt           |
| `claude -p "query"`             | Run query in print mode, then exit       |
| `cat file \| claude -p "query"` | Process piped content                    |
| `claude -c`                     | Continue most recent conversation        |
| `claude -c -p "query"`          | Continue via SDK                         |
| `claude -r "session" "query"`   | Resume session by ID or name             |
| `claude update`                 | Update to latest version                 |
| `claude auth login`             | Sign in (supports `--email`, `--sso`)    |
| `claude auth status`            | Show auth status as JSON (`--text` for human-readable) |
| `claude agents`                 | List configured subagents                |
| `claude mcp`                    | Configure MCP servers                    |
| `claude remote-control`         | Start a Remote Control session           |

### Key CLI Flags

| Flag                          | Description                                                        |
|:------------------------------|:-------------------------------------------------------------------|
| `-p`, `--print`               | Print response without interactive mode                            |
| `-c`, `--continue`            | Continue most recent conversation                                  |
| `-r`, `--resume`              | Resume specific session by ID or name                              |
| `--model`                     | Set model (`sonnet`, `opus`, or full name)                         |
| `--system-prompt`             | Replace entire system prompt                                       |
| `--append-system-prompt`      | Append to default system prompt                                    |
| `--max-turns`                 | Limit agentic turns (print mode only)                              |
| `--max-budget-usd`            | Maximum dollar spend (print mode only)                             |
| `--output-format`             | Output format: `text`, `json`, `stream-json`                       |
| `--allowedTools`              | Tools that execute without permission prompts                      |
| `--disallowedTools`           | Tools removed from model context entirely                          |
| `--tools`                     | Restrict available tools (`""` = none, `"default"` = all)          |
| `--permission-mode`           | Start in a permission mode (e.g. `plan`)                           |
| `--dangerously-skip-permissions` | Skip all permission prompts                                     |
| `--mcp-config`                | Load MCP servers from JSON file(s)                                 |
| `--plugin-dir`                | Load plugins from directory                                        |
| `--agents`                    | Define custom subagents via JSON                                   |
| `--add-dir`                   | Add extra working directories                                      |
| `-w`, `--worktree`            | Start in an isolated git worktree                                  |
| `--json-schema`               | Get validated JSON output matching a schema                        |
| `--verbose`                   | Show full turn-by-turn output                                      |
| `--debug`                     | Enable debug mode with optional category filtering                 |

### System Prompt Flags

| Flag                          | Behavior         | Modes               |
|:------------------------------|:-----------------|:---------------------|
| `--system-prompt`             | Replaces default | Interactive + Print  |
| `--system-prompt-file`        | Replaces (file)  | Print only           |
| `--append-system-prompt`      | Appends          | Interactive + Print  |
| `--append-system-prompt-file` | Appends (file)   | Print only           |

Replace flags and append flags can be combined. The two replace flags are mutually exclusive.

### Built-in Slash Commands

| Command                   | Purpose                                         |
|:--------------------------|:------------------------------------------------|
| `/clear`                  | Clear conversation history                      |
| `/compact [instructions]` | Compact conversation with optional focus        |
| `/config`                 | Open Settings (Config tab)                      |
| `/context`                | Visualize current context usage                 |
| `/cost`                   | Show token usage statistics                     |
| `/doctor`                 | Check installation health                       |
| `/export [filename]`      | Export conversation to file or clipboard         |
| `/init`                   | Initialize project with CLAUDE.md               |
| `/memory`                 | Edit CLAUDE.md memory files                     |
| `/model`                  | Select or change AI model                       |
| `/permissions`            | View or update permissions                      |
| `/plan`                   | Enter plan mode                                 |
| `/rename <name>`          | Rename current session                          |
| `/resume [session]`       | Resume a conversation                           |
| `/rewind`                 | Rewind conversation and/or code                 |
| `/theme`                  | Change color theme                              |
| `/vim`                    | Enable vim-style editing                        |
| `/tasks`                  | List and manage background tasks                |

### General Keyboard Shortcuts

| Shortcut   | Description                               |
|:-----------|:------------------------------------------|
| `Ctrl+C`   | Cancel current input or generation        |
| `Ctrl+D`   | Exit session                              |
| `Ctrl+G`   | Open in external text editor              |
| `Ctrl+L`   | Clear terminal screen                     |
| `Ctrl+O`   | Toggle verbose output                     |
| `Ctrl+R`   | Reverse search command history            |
| `Ctrl+B`   | Background running tasks (tmux: twice)    |
| `Ctrl+T`   | Toggle task list                          |
| `Shift+Tab`| Cycle permission modes                    |
| `Alt+P`    | Switch model                              |
| `Alt+T`    | Toggle extended thinking                  |
| `Esc Esc`  | Rewind or summarize                       |

### Multiline Input

| Method        | Shortcut        | Notes                                     |
|:--------------|:----------------|:------------------------------------------|
| Quick escape  | `\` + `Enter`   | Works in all terminals                    |
| macOS default | `Option+Enter`  | Default on macOS                          |
| Shift+Enter   | `Shift+Enter`   | Native in iTerm2, WezTerm, Ghostty, Kitty |
| Control seq   | `Ctrl+J`        | Line feed character                       |

Run `/terminal-setup` to configure Shift+Enter for VS Code, Alacritty, Zed, and Warp.

### Quick Input Prefixes

| Prefix | Description                                      |
|:-------|:-------------------------------------------------|
| `/`    | Slash command or skill                           |
| ` ! `  | Bash mode -- run shell commands directly         |
| `@`    | File path mention with autocomplete              |

### Custom Keybindings

Configure `~/.claude/keybindings.json` (or run `/keybindings`) with context-scoped binding blocks. Changes apply without restart.

Key contexts: `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Tabs`, `HistorySearch`, `Task`, `ThemePicker`.

Actions follow `namespace:action` format (e.g. `chat:submit`, `app:toggleTodos`). Set an action to `null` to unbind. Reserved shortcuts (`Ctrl+C`, `Ctrl+D`) cannot be rebound.

### Terminal Notifications

Kitty and Ghostty support desktop notifications natively. iTerm2 requires enabling "Notification Center Alerts" in Settings > Profiles > Terminal. For other terminals, use notification hooks.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) -- commands, flags, --agents format, system prompt flags
- [Interactive Mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts, slash commands, vim mode, bash mode, background tasks, command history, prompt suggestions, task list, PR review status
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) -- keybindings.json format, contexts, all available actions, keystroke syntax, chords, vim mode interaction
- [Terminal Configuration](references/claude-code-terminal-config.md) -- themes, line breaks, Shift+Enter setup, notifications, vim mode, large input handling

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
