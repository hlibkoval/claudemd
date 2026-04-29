---
name: cli-doc
description: Complete official documentation for Claude Code CLI — launch commands, flags, in-session slash commands, interactive keyboard shortcuts, Vim editor mode, keybindings configuration, terminal setup, and built-in tools reference.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, commands, flags, interactive mode, keybindings, terminal configuration, and available tools.

## Quick Reference

### Launch commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive, then exit) |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install or reinstall native binary |
| `claude auth login` | Sign in to Anthropic account |
| `claude auth logout` | Sign out from account |
| `claude auth status` | Show authentication status |
| `claude agents` | List all configured subagents |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude remote-control` | Start Remote Control server |
| `claude setup-token` | Generate long-lived OAuth token for CI/scripts |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

### Key CLI flags

| Flag | Description | Example |
| :--- | :--- | :--- |
| `--print`, `-p` | Non-interactive print mode | `claude -p "query"` |
| `--continue`, `-c` | Load most recent conversation | `claude -c` |
| `--resume`, `-r` | Resume session by ID or name | `claude -r abc123` |
| `--name`, `-n` | Set display name for session | `claude -n "my-work"` |
| `--model` | Set model (alias `sonnet`/`opus` or full name) | `claude --model sonnet` |
| `--effort` | Set effort level (low, medium, high, xhigh, max) | `claude --effort high` |
| `--permission-mode` | Start mode: default, acceptEdits, plan, auto, bypassPermissions | `claude --permission-mode auto` |
| `--dangerously-skip-permissions` | Skip all permission prompts | `claude --dangerously-skip-permissions` |
| `--allowedTools` | Tools that execute without prompting | `--allowedTools "Read" "Bash(git *)"` |
| `--disallowedTools` | Tools removed from model's context | `--disallowedTools "Edit" "Bash(rm *)"` |
| `--add-dir` | Add additional working directories | `claude --add-dir ../libs ../apps` |
| `--chrome` | Enable Chrome browser integration | `claude --chrome` |
| `--ide` | Auto-connect to available IDE | `claude --ide` |
| `--bare` | Minimal mode: skip auto-discovery | `claude --bare -p "query"` |
| `--debug` | Enable debug mode with optional filtering | `claude --debug "api,mcp"` |
| `--system-prompt` | Replace entire system prompt | `claude --system-prompt "You are a Python expert"` |
| `--append-system-prompt` | Append custom text to system prompt | `claude --append-system-prompt "Always use TypeScript"` |
| `--json-schema` | Get validated JSON output matching schema | `claude -p --json-schema '{"type":"object"...'` |
| `--max-turns` | Limit agentic turns (print mode only) | `claude -p --max-turns 3 "query"` |
| `--mcp-config` | Load MCP servers from JSON files | `claude --mcp-config ./mcp.json` |

### In-session commands (common)

| Command | Purpose |
| :--- | :--- |
| `/help` | Show help and available commands |
| `/exit` | Exit the CLI (aliases: `/quit`) |
| `/model [model]` | Select or change AI model |
| `/effort [level]` | Set effort level with interactive slider |
| `/resume [session]` | Resume a conversation |
| `/branch` | Create a conversation branch (alias: `/fork`) |
| `/clear` | Start new conversation with empty context (aliases: `/reset`, `/new`) |
| `/compact` | Free up context by summarizing |
| `/plan [description]` | Enter plan mode |
| `/diff` | Open interactive diff viewer |
| `/permissions` | Manage tool permission rules (alias: `/allowed-tools`) |
| `/config` | Open Settings interface (alias: `/settings`) |
| `/keybindings` | Open or create keybindings configuration |
| `/theme` | Change color theme |
| `/copy [N]` | Copy last response to clipboard |
| `/export [filename]` | Export conversation as plain text |
| `/usage` | Show session cost and plan usage (aliases: `/cost`, `/stats`) |

### Keyboard shortcuts (main)

| Shortcut | Description | Context |
| :--- | :--- | :--- |
| `Ctrl+C` | Cancel current input or generation | Standard interrupt |
| `Ctrl+D` | Exit Claude Code session | EOF signal |
| `Ctrl+L` | Clear prompt and redraw screen | Display recovery |
| `Ctrl+O` | Toggle transcript viewer | Show detailed tool usage |
| `Ctrl+R` | Reverse search command history | Search previous commands |
| `Shift+Tab` or `Alt+M` | Cycle permission modes | Change permission behavior |
| `Option+P` / `Alt+P` | Switch model | Model selection |
| `Option+T` / `Alt+T` | Toggle extended thinking | Thinking mode control |
| `Option+O` / `Alt+O` | Toggle fast mode | Enable/disable fast mode |
| `Escape + Escape` | Rewind or summarize | Conversation control |
| `Ctrl+A` | Move cursor to start of line | Text editing |
| `Ctrl+E` | Move cursor to end of line | Text editing |
| `Ctrl+K` | Delete to end of line | Text editing |
| `Ctrl+U` | Delete from cursor to line start | Text editing |
| `Ctrl+W` | Delete previous word | Text editing |
| `Ctrl+Y` | Paste deleted text | Text editing |

### Multiline input methods

| Method | Shortcut | Terminal support |
| :--- | :--- | :--- |
| Quick escape | `\` + `Enter` | All terminals |
| Control sequence | `Ctrl+J` | All terminals (no setup needed) |
| Option key | `Option+Enter` | macOS (after enabling Option as Meta) |
| Shift+Enter | `Shift+Enter` | iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal; VS Code/Cursor/Windsurf/Alacritty/Zed (run `/terminal-setup`) |

### Permission modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Permission prompt for each tool use |
| `acceptEdits` | Auto-accept file edits, prompt for others |
| `plan` | Plan-only mode, no tool execution |
| `auto` | Classifier-based permissions |
| `bypassPermissions` | Skip all permission checks |

### Built-in tools (for permission rules)

| Tool | Description | Requires Permission |
| :--- | :--- | :--- |
| `Bash` | Execute shell commands | Yes |
| `Edit` | Make targeted file edits | Yes |
| `Read` | Read file contents | No |
| `Write` | Create or overwrite files | Yes |
| `Glob` | Find files by pattern | No |
| `Grep` | Search patterns in files | No |
| `LSP` | Code intelligence (definitions, references, type info) | No |
| `Monitor` | Watch and react to log/file changes | Yes |
| `Skill` | Execute a skill | Yes |
| `Agent` | Spawn subagent | No |
| `WebFetch` | Fetch content from URL | Yes |
| `WebSearch` | Perform web searches | Yes |
| `NotebookEdit` | Modify Jupyter notebook cells | Yes |

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — complete reference for all launch commands and CLI flags with examples
- [Commands](references/claude-code-commands.md) — detailed reference for all in-session commands including `/model`, `/permissions`, `/diff`, `/loop`, `/batch`, and skill-based commands
- [Interactive mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, input modes, multiline input, transcript viewer, voice input, and interactive features
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) — keybindings configuration file schema, contexts, and available actions for customizing behavior
- [Configure your terminal for Claude Code](references/claude-code-terminal-config.md) — Shift+Enter setup, Option key configuration on macOS, terminal bell/notifications, tmux setup, fullscreen rendering, and Vim keybindings
- [Tools reference](references/claude-code-tools-reference.md) — complete reference for all tools available to Claude Code, permission requirements, Bash behavior, LSP tool, Monitor tool, and PowerShell tool

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure your terminal for Claude Code: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
