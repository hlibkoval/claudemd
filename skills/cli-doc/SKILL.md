---
name: cli-doc
description: Claude Code CLI reference documentation covering commands, flags, interactive mode shortcuts, built-in slash commands, keyboard shortcut customization, and terminal configuration. Load this when answering questions about running claude from the command line, CLI flags, keybindings, or terminal setup.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, keyboard shortcuts, and terminal configuration.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode: run query and exit (non-interactive) |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (use `--email`, `--sso` flags) |
| `claude auth status` | Show auth status (JSON; `--text` for readable) |
| `claude agents` | List configured subagents |
| `claude remote-control` | Start a Remote Control session |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Continue most recent conversation |
| `-r`, `--resume` | Resume session by ID/name |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Spending cap in USD (print mode only) |
| `--permission-mode` | Start in a specific permission mode |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--allowedTools` | Tools that run without permission prompts |
| `--disallowedTools` | Tools to remove from model context entirely |
| `--tools` | Restrict which built-in tools are available |
| `--add-dir` | Add extra working directories |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--plugin-dir` | Load plugins from a directory (session only) |
| `--mcp-config` | Load MCP servers from JSON file |
| `--agents` | Define custom subagents inline via JSON |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--verbose` | Enable verbose logging |
| `--debug` | Debug mode with optional category filter |
| `--version`, `-v` | Output version number |

### System Prompt Flags

| Flag | Behavior | Modes |
|:-----|:---------|:------|
| `--system-prompt` | Replaces entire default prompt | Interactive + Print |
| `--system-prompt-file` | Replaces with file contents | Print only |
| `--append-system-prompt` | Appends to default prompt | Interactive + Print |
| `--append-system-prompt-file` | Appends file contents to default prompt | Print only |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag.

### Interactive Mode: Keyboard Shortcuts

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit Claude Code |
| `Ctrl+L` | Clear terminal screen (keeps history) |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+G` | Open prompt in external text editor |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+B` | Background current bash task |
| `Ctrl+T` | Toggle task list |
| `Ctrl+F` | Kill all background agents (press twice to confirm) |
| `Ctrl+V` / `Cmd+V` | Paste image from clipboard |
| `Shift+Tab` | Cycle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Esc` + `Esc` | Rewind/summarize conversation |

### Multiline Input

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + Enter (all terminals) |
| macOS default | `Option+Enter` |
| Works natively | `Shift+Enter` in iTerm2, WezTerm, Ghostty, Kitty |
| Other terminals | Run `/terminal-setup` to configure Shift+Enter |

### Quick Input Prefixes

| Prefix | Description |
|:-------|:------------|
| `/` | Invoke a built-in command or skill |
| `!` | Run a bash command directly (output added to context) |
| `@` | Trigger file path autocomplete |

### Built-in Slash Commands

| Command | Purpose |
|:--------|:--------|
| `/clear` | Clear conversation history |
| `/compact [instructions]` | Compact conversation |
| `/config` | Open Settings interface |
| `/context` | Visualize context usage |
| `/cost` | Show token usage statistics |
| `/debug` | Troubleshoot current session |
| `/doctor` | Check installation health |
| `/export [filename]` | Export conversation |
| `/help` | Get usage help |
| `/init` | Initialize project with CLAUDE.md |
| `/memory` | Edit CLAUDE.md memory files |
| `/model` | Select or change model |
| `/permissions` | View or update permissions |
| `/plan` | Enter plan mode |
| `/rename [name]` | Rename current session |
| `/resume [session]` | Resume a conversation |
| `/rewind` | Rewind conversation/code |
| `/stats` | Visualize usage and streaks |
| `/status` | View version, model, account info |
| `/theme` | Change color theme |
| `/todos` | List current TODO items |
| `/vim` | Enable vim editor mode |
| `/keybindings` | Create/open keybindings config |
| `/terminal-setup` | Configure terminal for Shift+Enter |

### Keybinding Customization

Configure `~/.claude/keybindings.json`. Changes apply live without restart.

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

Set an action to `null` to unbind it. Reserved shortcuts (`Ctrl+C`, `Ctrl+D`) cannot be rebound.

**Contexts:** `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Settings`, `Plugin`, and others.

**Key action examples:** `chat:submit`, `chat:cycleMode`, `app:toggleTodos`, `history:search`, `task:background`

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — all CLI commands, flags, system prompt options, and the `--agents` flag JSON format
- [Interactive Mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, built-in commands, vim mode, background tasks, prompt suggestions, task list
- [Keybindings](references/claude-code-keybindings.md) — full keybinding configuration reference with all contexts and available actions
- [Terminal Configuration](references/claude-code-terminal-config.md) — terminal setup, line breaks, notifications, vim mode, and large input handling

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
