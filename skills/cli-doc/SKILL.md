---
name: cli-doc
description: Complete documentation for the Claude Code CLI — command-line commands and flags, interactive mode keyboard shortcuts, built-in slash commands, vim mode, bash mode, multiline input, keybinding customization, terminal configuration, background tasks, and prompt suggestions. Load when discussing CLI usage, flags, keyboard shortcuts, keybindings, terminal setup, or interactive features.
user-invocable: false
---

# CLI & Interactive Mode Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, keybindings, and terminal configuration.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start with initial prompt |
| `claude -p "query"` | Print mode (non-interactive), then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation |
| `claude -r <session> "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (`--email`, `--sso` flags) |
| `claude auth status` | Show auth status (JSON; `--text` for readable) |
| `claude agents` | List configured subagents |
| `claude mcp` | Configure MCP servers |
| `claude remote-control` | Start Remote Control session |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Continue most recent conversation |
| `-r`, `--resume` | Resume session by ID or name |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--permission-mode` | Start in permission mode (`plan`, `default`, etc.) |
| `--allowedTools` | Tools that skip permission prompts |
| `--disallowedTools` | Tools removed from context entirely |
| `--tools` | Restrict available tools (`""`, `"default"`, `"Bash,Edit,Read"`) |
| `--add-dir` | Add extra working directories |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Spending cap (print mode) |
| `--mcp-config` | Load MCP servers from JSON |
| `--plugin-dir` | Load plugins from directory |
| `--agent` | Specify agent for session |
| `--agents` | Define subagents via JSON |
| `-w`, `--worktree` | Start in isolated git worktree |
| `--json-schema` | Validated JSON output (print mode) |
| `--chrome` / `--no-chrome` | Enable/disable Chrome integration |
| `--debug` | Debug mode with category filtering |
| `--verbose` | Verbose logging |

### System Prompt Flags

| Flag | Behavior | Modes |
|:-----|:---------|:------|
| `--system-prompt` | Replaces entire default prompt | Interactive + Print |
| `--system-prompt-file` | Replaces with file contents | Print only |
| `--append-system-prompt` | Appends to default prompt | Interactive + Print |
| `--append-system-prompt-file` | Appends file contents | Print only |

### Essential Keyboard Shortcuts

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit Claude Code |
| `Ctrl+L` | Clear terminal screen |
| `Ctrl+B` | Background running tasks |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+G` | Open in external text editor |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+T` | Toggle task list |
| `Ctrl+V` | Paste image from clipboard |
| `Shift+Tab` | Toggle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Esc` + `Esc` | Rewind or summarize |

### Multiline Input

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + `Enter` |
| macOS | `Option+Enter` |
| Shift+Enter | Works in iTerm2, WezTerm, Ghostty, Kitty |
| Control sequence | `Ctrl+J` |

### Quick Input Prefixes

| Prefix | Effect |
|:-------|:-------|
| `/` | Invoke command or skill |
| ` ! ` (exclamation) | Run bash command directly |
| `@` | File path autocomplete |

### Keybinding Customization

File: `~/.claude/keybindings.json` (open with `/keybindings`). Changes auto-detected, no restart needed.

Key contexts: `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Tabs`, `Task`, `HistorySearch`, `Transcript`, `Settings`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`.

Keystroke syntax: `ctrl+k`, `shift+tab`, `meta+p`, `ctrl+shift+c`. Chords: `ctrl+k ctrl+s`. Set action to `null` to unbind. Reserved (cannot rebind): `Ctrl+C`, `Ctrl+D`.

### Terminal Configuration Tips

- **Shift+Enter**: Run `/terminal-setup` to configure in VS Code, Alacritty, Zed, Warp
- **Option as Meta** (macOS): iTerm2 Settings > Profiles > Keys > "Esc+"; Terminal.app Settings > Profiles > Keyboard > "Use Option as Meta Key"
- **Notifications**: Kitty/Ghostty work natively; iTerm2 needs "Notification Center Alerts" enabled; use notification hooks for other terminals
- **Large inputs**: Use file-based workflows instead of pasting
- **Vim mode**: Toggle with `/vim` or via `/config`

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) -- all CLI commands, flags, agents flag format, and system prompt flag details
- [Interactive mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts, built-in commands, vim mode, command history, background tasks, bash mode, prompt suggestions, task list, and PR review status
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) -- keybindings.json format, contexts, all available actions with defaults, keystroke syntax, vim mode interaction, and validation
- [Terminal configuration](references/claude-code-terminal-config.md) -- terminal themes, line break setup, notification configuration, large input handling, and vim mode overview

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Terminal configuration: https://code.claude.com/docs/en/terminal-config.md
