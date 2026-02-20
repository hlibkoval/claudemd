---
name: cli
description: Reference documentation for Claude Code CLI — command-line flags, interactive mode shortcuts, built-in slash commands, keybinding customization, vim mode, terminal configuration, multiline input, background tasks, bash mode, and session management. Use when looking up CLI flags, keyboard shortcuts, slash commands, keybinding configuration, or terminal setup.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, keybinding customization, and terminal configuration.

## Quick Reference

### CLI Commands

| Command                         | Description                                           |
|:--------------------------------|:------------------------------------------------------|
| `claude`                        | Start interactive REPL                                |
| `claude "query"`                | Start REPL with initial prompt                        |
| `claude -p "query"`             | Run in print/SDK mode, then exit                      |
| `cat file \| claude -p "query"` | Process piped content                                 |
| `claude -c`                     | Continue most recent conversation in current directory |
| `claude -c -p "query"`          | Continue via SDK                                      |
| `claude -r "<session>" "query"` | Resume session by ID or name                          |
| `claude update`                 | Update to latest version                              |
| `claude mcp`                    | Configure MCP servers                                 |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `-p`, `--print` | Print mode (non-interactive SDK mode) |
| `-c`, `--continue` | Continue most recent conversation |
| `-r`, `--resume` | Resume session by ID or name |
| `-w`, `--worktree` | Start in isolated git worktree |
| `-v`, `--version` | Output version number |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--add-dir` | Add additional working directories |
| `--allowedTools` | Tools that execute without permission prompts |
| `--disallowedTools` | Tools removed from model context |
| `--tools` | Restrict available built-in tools |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--system-prompt-file` | Replace prompt from file (print mode only) |
| `--append-system-prompt-file` | Append from file (print mode only) |
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--input-format` | Input format: `text`, `stream-json` |
| `--json-schema` | Validate JSON output against schema (print mode) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Max dollar spend (print mode) |
| `--mcp-config` | Load MCP servers from JSON file |
| `--strict-mcp-config` | Use only `--mcp-config` servers |
| `--permission-mode` | Start in a permission mode (e.g. `plan`) |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--agent` | Specify agent for current session |
| `--agents` | Define custom subagents via JSON |
| `--plugin-dir` | Load plugins from directory |
| `--remote` | Create a web session on claude.ai |
| `--teleport` | Resume a web session locally |
| `--chrome` / `--no-chrome` | Enable/disable Chrome integration |
| `--verbose` | Verbose logging |
| `--debug` | Debug mode with optional category filter |

### System Prompt Flags

| Flag | Behavior | Modes |
|:-----|:---------|:------|
| `--system-prompt` | **Replaces** entire default prompt | Interactive + Print |
| `--system-prompt-file` | **Replaces** with file contents | Print only |
| `--append-system-prompt` | **Appends** to default prompt | Interactive + Print |
| `--append-system-prompt-file` | **Appends** file contents | Print only |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either.

### Essential Keyboard Shortcuts

| Shortcut | Action |
|:---------|:-------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit Claude Code |
| `Ctrl+L` | Clear terminal screen |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+G` | Open prompt in external text editor |
| `Ctrl+T` | Toggle task list |
| `Shift+Tab` | Cycle permission modes |
| `Alt+P` | Switch model |
| `Alt+T` | Toggle extended thinking |
| `Esc Esc` | Rewind or summarize |

### Multiline Input

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + `Enter` |
| macOS default | `Option+Enter` |
| iTerm2/WezTerm/Ghostty/Kitty | `Shift+Enter` (native) |
| Other terminals | `Shift+Enter` (run `/terminal-setup`) |
| Control sequence | `Ctrl+J` |

### Quick Input Prefixes

| Prefix | Action |
|:-------|:-------|
| `/` | Slash command or skill |
| ` !` | Bash mode (run command directly) |
| `@` | File path autocomplete |

### Common Built-in Commands

| Command | Purpose |
|:--------|:--------|
| `/clear` | Clear conversation history |
| `/compact [instructions]` | Compact conversation |
| `/config` | Open settings |
| `/context` | Visualize context usage |
| `/cost` | Show token usage |
| `/model` | Select or change model |
| `/permissions` | View or update permissions |
| `/plan` | Enter plan mode |
| `/resume [session]` | Resume a session |
| `/rewind` | Rewind conversation and/or code |
| `/tasks` | List and manage background tasks |
| `/vim` | Enable vim mode |
| `/theme` | Change color theme |
| `/terminal-setup` | Configure Shift+Enter for your terminal |
| `/keybindings` | Open keybinding config file |

### Keybinding Customization

Config file: `~/.claude/keybindings.json`. Changes auto-detected without restart.

Key contexts: `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Task`, `HistorySearch`, `Transcript`, `ThemePicker`, `Tabs`, `Footer`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Settings`.

Actions use `namespace:action` format (e.g. `chat:submit`, `app:toggleTodos`). Set an action to `null` to unbind. Reserved shortcuts (`Ctrl+C`, `Ctrl+D`) cannot be rebound.

### Option as Meta Key (macOS)

Required for `Alt+B`, `Alt+F`, `Alt+Y`, `Alt+M`, `Alt+P` shortcuts:

| Terminal | Setting |
|:---------|:--------|
| iTerm2 | Settings > Profiles > Keys > Left/Right Option key = "Esc+" |
| Terminal.app | Settings > Profiles > Keyboard > "Use Option as Meta Key" |
| VS Code | Settings > Profiles > Keys > Left/Right Option key = "Esc+" |

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — complete list of CLI commands, flags, system prompt flags, and the `--agents` JSON format
- [Interactive Mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, built-in commands, vim mode, command history, background tasks, bash mode, prompt suggestions, task list, and PR review status
- [Keybindings](references/claude-code-keybindings.md) — customizable keybinding configuration, all available contexts and actions, keystroke syntax, chords, vim mode interaction, and validation
- [Terminal Configuration](references/claude-code-terminal-config.md) — terminal setup, Shift+Enter configuration, notification hooks, themes, vim mode, and handling large inputs

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
