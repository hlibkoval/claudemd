---
name: cli
description: Reference documentation for the Claude Code CLI -- command-line commands, flags, system prompt customization, interactive mode shortcuts, built-in slash commands, vim mode, keybinding customization, terminal configuration, multiline input, background tasks, bash mode, and prompt suggestions.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, keybindings, and terminal configuration.

## Quick Reference

### CLI Commands

| Command                         | Description                                 |
|:--------------------------------|:--------------------------------------------|
| `claude`                        | Start interactive REPL                      |
| `claude "query"`                | Start REPL with initial prompt              |
| `claude -p "query"`             | Run query via SDK, then exit                |
| `cat file \| claude -p "query"` | Process piped content                       |
| `claude -c`                     | Continue most recent conversation           |
| `claude -r "<session>" "query"` | Resume session by ID or name                |
| `claude update`                 | Update to latest version                    |
| `claude auth login`             | Sign in (supports `--email`, `--sso`)       |
| `claude auth status`            | Show auth status as JSON (`--text` for human-readable) |
| `claude agents`                 | List all configured subagents               |
| `claude mcp`                    | Configure MCP servers                       |
| `claude remote-control`         | Start a Remote Control session              |

### Key CLI Flags

| Flag                          | Description                                                         |
|:------------------------------|:--------------------------------------------------------------------|
| `--print`, `-p`               | Non-interactive mode; print response and exit                       |
| `--continue`, `-c`            | Continue most recent conversation                                   |
| `--resume`, `-r`              | Resume session by ID/name or show picker                            |
| `--model`                     | Set model (`sonnet`, `opus`, or full name)                          |
| `--system-prompt`             | Replace entire system prompt                                        |
| `--append-system-prompt`      | Append to default system prompt                                     |
| `--output-format`             | Output format: `text`, `json`, `stream-json`                        |
| `--max-turns`                 | Limit agentic turns (print mode only)                               |
| `--max-budget-usd`            | Maximum dollar spend before stopping                                |
| `--allowedTools`              | Tools that skip permission prompts                                  |
| `--disallowedTools`           | Tools removed from model context                                    |
| `--tools`                     | Restrict available tools (`""` = none, `"default"` = all)           |
| `--permission-mode`           | Start in specific permission mode (e.g. `plan`)                     |
| `--dangerously-skip-permissions` | Skip all permission prompts                                      |
| `--add-dir`                   | Add additional working directories                                  |
| `--agent`                     | Specify agent for the session                                       |
| `--agents`                    | Define custom subagents via JSON                                    |
| `--mcp-config`                | Load MCP servers from JSON file                                     |
| `--plugin-dir`                | Load plugins from directory                                         |
| `--worktree`, `-w`            | Start in isolated git worktree                                      |
| `--json-schema`               | Get validated JSON output matching a schema (print mode)            |
| `--verbose`                   | Show full turn-by-turn output                                       |
| `--debug`                     | Enable debug mode with optional category filter                     |
| `--chrome` / `--no-chrome`    | Enable/disable Chrome browser integration                           |
| `--remote`                    | Create a new web session on claude.ai                               |
| `--teleport`                  | Resume a web session in local terminal                              |
| `--from-pr`                   | Resume sessions linked to a GitHub PR                               |

### System Prompt Flags

| Flag                          | Behavior          | Modes               |
|:------------------------------|:------------------|:---------------------|
| `--system-prompt`             | Replaces default  | Interactive + Print  |
| `--system-prompt-file`        | Replaces (file)   | Print only           |
| `--append-system-prompt`      | Appends to default| Interactive + Print  |
| `--append-system-prompt-file` | Appends (file)    | Print only           |

Replace flags are mutually exclusive. Append flags can combine with either.

### Built-in Slash Commands

| Command                   | Purpose                                         |
|:--------------------------|:------------------------------------------------|
| `/clear`                  | Clear conversation history                      |
| `/compact [instructions]` | Compact conversation with optional focus        |
| `/config`                 | Open Settings (Config tab)                      |
| `/context`                | Visualize current context usage                 |
| `/cost`                   | Show token usage statistics                     |
| `/debug [description]`    | Troubleshoot session via debug log              |
| `/doctor`                 | Check installation health                       |
| `/export [filename]`      | Export conversation to file or clipboard         |
| `/init`                   | Initialize project with CLAUDE.md               |
| `/memory`                 | Edit CLAUDE.md memory files                     |
| `/model`                  | Select/change AI model                          |
| `/permissions`            | View or update permissions                      |
| `/plan`                   | Enter plan mode                                 |
| `/rename <name>`          | Rename current session                          |
| `/resume [session]`       | Resume a conversation                           |
| `/rewind`                 | Rewind conversation and/or code                 |
| `/copy`                   | Copy last response to clipboard                 |
| `/tasks`                  | List and manage background tasks                |
| `/theme`                  | Change color theme                              |
| `/usage`                  | Show plan usage limits (subscription only)      |

### Essential Keyboard Shortcuts

| Shortcut        | Description                                  |
|:----------------|:---------------------------------------------|
| `Ctrl+C`        | Cancel current input or generation           |
| `Ctrl+D`        | Exit session                                 |
| `Ctrl+L`        | Clear terminal screen                        |
| `Ctrl+O`        | Toggle verbose output                        |
| `Ctrl+R`        | Reverse search command history               |
| `Ctrl+B`        | Background running tasks                     |
| `Ctrl+T`        | Toggle task list                             |
| `Ctrl+G`        | Open in external text editor                 |
| `Shift+Tab`     | Toggle permission modes                      |
| `Alt+P`         | Switch model                                 |
| `Alt+T`         | Toggle extended thinking                     |
| `Esc Esc`       | Rewind or summarize                          |

### Multiline Input

| Method         | How                              |
|:---------------|:---------------------------------|
| Quick escape   | `\` + `Enter`                    |
| macOS default  | `Option+Enter`                   |
| iTerm2/Ghostty | `Shift+Enter` (native support)   |
| Other terminals| Run `/terminal-setup` first      |
| Control seq    | `Ctrl+J`                         |

### Quick Prefixes

| Prefix | Effect                                    |
|:-------|:------------------------------------------|
| `/`    | Slash command or skill invocation         |
| ` ` (exclamation) | Bash mode -- run shell command directly   |
| `@`    | File path autocomplete                    |

### Keybinding Customization

Configure via `/keybindings` which creates `~/.claude/keybindings.json`. Changes apply without restart. Structure:

```json
{
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

Key contexts: `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Tabs`, `HistorySearch`, `Task`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Settings`.

Reserved (cannot rebind): `Ctrl+C`, `Ctrl+D`.

### Terminal Configuration Tips

- **Notifications**: Kitty/Ghostty work natively; iTerm2 requires enabling "Notification Center Alerts"; use hooks for other terminals
- **Option as Meta (macOS)**: Required for `Alt+` shortcuts. iTerm2: Profiles > Keys > "Esc+"; Terminal.app: Profiles > Keyboard > "Use Option as Meta Key"
- **Large inputs**: Avoid direct pasting; use file-based workflows instead
- **Vim mode**: Enable with `/vim` or via `/config`; supports motions, text objects, yank/paste

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) -- complete list of commands, flags, system prompt flags, and the `--agents` JSON format
- [Interactive Mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts, built-in commands, vim mode, command history, background tasks, bash mode, prompt suggestions, task list, PR review status
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) -- keybindings.json format, all contexts and actions, keystroke syntax, chords, vim mode interaction, validation
- [Optimize Your Terminal Setup](references/claude-code-terminal-config.md) -- themes, line breaks, Shift+Enter setup, notifications, large inputs, vim mode

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Optimize Your Terminal Setup: https://code.claude.com/docs/en/terminal-config.md
