---
name: cli
description: Reference documentation for the Claude Code CLI — command-line flags, interactive mode shortcuts, built-in slash commands, vim editor mode, keybinding customization, and terminal configuration. Use when asking about CLI flags, keyboard shortcuts, slash commands, vim mode, keybindings.json, terminal setup, or how to run Claude Code non-interactively.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, keyboard shortcuts, and terminal configuration.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive REPL |
| `claude "query"` | Start REPL with initial prompt |
| `claude -p "query"` | Print mode (non-interactive, then exit) |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude mcp` | Configure MCP servers |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Continue most recent conversation |
| `-r`, `--resume` | Resume session by ID or name |
| `--model` | Set model (`sonnet`, `opus`, or full model ID) |
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Spending cap in dollars (print mode only) |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--allowedTools` | Tools that run without permission prompts |
| `--disallowedTools` | Tools to remove from model context |
| `--tools` | Restrict which built-in tools are available |
| `--permission-mode` | Start in a specific permission mode |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--add-dir` | Add additional working directories |
| `--agents` | Define custom subagents via JSON |
| `--plugin-dir` | Load plugins from a directory |
| `--mcp-config` | Load MCP servers from JSON file |
| `--debug` | Enable debug mode (optional category filter) |
| `--verbose` | Enable verbose turn-by-turn logging |
| `--no-session-persistence` | Do not save session to disk |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a GitHub PR |
| `--remote` | Create a new web session on claude.ai |
| `--teleport` | Resume a web session in local terminal |
| `--ide` | Connect to IDE on startup |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, `tmux` |
| `--setting-sources` | Comma-separated sources: `user`, `project`, `local` |
| `--json-schema` | Validated JSON output matching a schema (print mode) |

### System Prompt Flags

| Flag | Behavior | Modes |
|:-----|:---------|:------|
| `--system-prompt` | Replaces entire default prompt | Interactive + Print |
| `--system-prompt-file` | Replaces with file contents | Print only |
| `--append-system-prompt` | Appends to default prompt | Interactive + Print |
| `--append-system-prompt-file` | Appends file contents to default | Print only |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag.

### Interactive Keyboard Shortcuts

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit Claude Code |
| `Ctrl+L` | Clear terminal screen (keeps history) |
| `Ctrl+G` | Open in external text editor |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+V` / `Cmd+V` | Paste image from clipboard |
| `Shift+Tab` | Cycle permission modes (Auto-Accept / Plan / Normal) |
| `Esc` + `Esc` | Rewind or summarize conversation |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Up/Down` | Navigate command history |

### Quick Input Prefixes

| Prefix | Behavior |
|:-------|:---------|
| `/` | Invoke a command or skill |
| `!` | Bash mode — run shell command directly |
| `@` | File path autocomplete |

### Built-in Slash Commands

| Command | Purpose |
|:--------|:--------|
| `/clear` | Clear conversation history |
| `/compact [instructions]` | Compact conversation |
| `/config` | Open Settings (Config tab) |
| `/context` | Visualize context window usage |
| `/cost` | Show token usage statistics |
| `/debug` | Troubleshoot current session |
| `/doctor` | Check Claude Code installation health |
| `/export [filename]` | Export conversation |
| `/help` | Get usage help |
| `/init` | Initialize project CLAUDE.md |
| `/mcp` | Manage MCP server connections |
| `/memory` | Edit CLAUDE.md memory files |
| `/model` | Select or change the AI model |
| `/permissions` | View or update permissions |
| `/plan` | Enter plan mode |
| `/rename <name>` | Rename current session |
| `/resume [session]` | Resume a conversation |
| `/rewind` | Rewind conversation/code |
| `/stats` | Visualize usage and session history |
| `/tasks` | List and manage background tasks |
| `/theme` | Change color theme |
| `/todos` | List current TODO items |
| `/usage` | Show plan usage limits (subscription only) |
| `/vim` | Enable vim editor mode |

### Multiline Input

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + `Enter` (all terminals) |
| macOS default | `Option+Enter` |
| Native support | `Shift+Enter` (iTerm2, WezTerm, Ghostty, Kitty) |
| Other terminals | Run `/terminal-setup` to install binding |

### Keybindings Customization

Edit `~/.claude/keybindings.json` (run `/keybindings` to open). Changes apply automatically without restart.

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

Actions use `namespace:action` format (e.g., `chat:submit`, `app:toggleTodos`). Set a binding to `null` to unbind it. Reserved (non-rebindable): `Ctrl+C`, `Ctrl+D`.

Available contexts: `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Settings`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Tabs`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`.

### macOS Option Key Setup (for Alt shortcuts)

Configure Option as Meta in your terminal to enable `Alt+B`, `Alt+F`, `Alt+Y`, `Alt+P`, `Alt+T`:

- **iTerm2**: Settings > Profiles > Keys > Left/Right Option key = "Esc+"
- **Terminal.app**: Settings > Profiles > Keyboard > "Use Option as Meta Key"
- **VS Code**: Settings > Profiles > Keys > Left/Right Option key = "Esc+"

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — all CLI commands, flags, `--agents` JSON format, and system prompt flags
- [Interactive Mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, built-in commands, vim mode, bash mode, background tasks, prompt suggestions, task list, PR review status
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) — keybindings.json format, all contexts, all actions with defaults, keystroke syntax, vim mode interaction
- [Terminal Configuration](references/claude-code-terminal-config.md) — theme setup, line breaks, Shift+Enter, Option+Enter, notifications, large inputs, vim mode

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
