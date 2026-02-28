---
name: cli-doc
description: Complete reference for the Claude Code command-line interface — CLI commands, flags, system prompt customization, interactive mode shortcuts, built-in slash commands, vim mode, keybinding customization, background tasks, terminal configuration, and multiline input. Load when discussing CLI usage, flags, keyboard shortcuts, or terminal setup.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, keybindings, and terminal configuration.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive), then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (`--email`, `--sso` options) |
| `claude auth status` | Show auth status (JSON; `--text` for human-readable) |
| `claude agents` | List all configured subagents |
| `claude mcp` | Configure MCP servers |
| `claude remote-control` | Start a Remote Control session |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Continue most recent conversation |
| `-r`, `--resume` | Resume session by ID or name |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Spending cap (print mode) |
| `--allowedTools` | Auto-approve specific tools |
| `--disallowedTools` | Remove tools from context |
| `--tools` | Restrict available tools (` `` "" `` ` = none, `"default"` = all) |
| `--add-dir` | Add extra working directories |
| `--mcp-config` | Load MCP servers from JSON file |
| `--plugin-dir` | Load plugins from directory |
| `--permission-mode` | Start in a permission mode (`plan`, etc.) |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--json-schema` | Validated JSON output matching schema (print mode) |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--verbose` | Verbose logging |
| `--debug` | Debug mode with category filtering |

### System Prompt Flags

| Flag | Behavior | Modes |
|:-----|:---------|:------|
| `--system-prompt` | Replaces entire default prompt | Interactive + Print |
| `--system-prompt-file` | Replaces with file contents | Print only |
| `--append-system-prompt` | Appends to default prompt | Interactive + Print |
| `--append-system-prompt-file` | Appends file contents | Print only |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either.

### Essential Keyboard Shortcuts

| Shortcut | Action |
|:---------|:-------|
| `Ctrl+C` | Cancel current input/generation |
| `Ctrl+D` | Exit session |
| `Ctrl+L` | Clear terminal screen |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search history |
| `Ctrl+B` | Background running task |
| `Ctrl+T` | Toggle task list |
| `Esc Esc` | Rewind or summarize |
| `Shift+Tab` | Toggle permission modes |
| `Alt+P` | Switch model |
| `Alt+T` | Toggle extended thinking |

### Multiline Input

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + Enter |
| macOS | Option+Enter |
| iTerm2/WezTerm/Ghostty/Kitty | Shift+Enter (native) |
| Other terminals | Run `/terminal-setup` for Shift+Enter |
| Control sequence | Ctrl+J |

### Built-in Slash Commands

| Command | Purpose |
|:--------|:--------|
| `/clear` | Clear conversation history |
| `/compact` | Compact conversation (optional focus instructions) |
| `/config` | Open Settings interface |
| `/context` | Visualize context usage |
| `/cost` | Show token usage statistics |
| `/model` | Select or change AI model |
| `/memory` | Edit CLAUDE.md memory files |
| `/permissions` | View or update permissions |
| `/resume` | Resume a conversation |
| `/rewind` | Rewind conversation and/or code |
| `/theme` | Change color theme |
| `/vim` | Enable vim-style editing |
| `/copy` | Copy last response to clipboard |
| `/tasks` | List background tasks |
| `/teleport` | Resume remote session from claude.ai |
| `/desktop` | Hand off to Desktop app |

### Quick Input Prefixes

| Prefix | Effect |
|:-------|:-------|
| `/` | Invoke command or skill |
| ` ! ` | Bash mode (run shell command directly) |
| `@` | File path autocomplete |

### Keybinding Customization

Configure via `/keybindings` which creates `~/.claude/keybindings.json`. Changes are auto-detected without restart.

Contexts: `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Settings`.

Reserved (cannot be rebound): `Ctrl+C`, `Ctrl+D`.

### Terminal Configuration

- **Themes**: Use `/config` to match Claude Code theme to your terminal
- **Notifications**: Kitty/Ghostty work natively; iTerm2 requires enabling "Notification Center Alerts" and "Send escape sequence-generated alerts"
- **Option as Meta (macOS)**: iTerm2 and VS Code set Left/Right Option to "Esc+"; Terminal.app check "Use Option as Meta Key"
- **Large inputs**: Prefer file-based workflows over direct pasting

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) -- complete list of CLI commands, flags, the `--agents` JSON format, and system prompt flag details
- [Interactive Mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts, built-in commands, vim mode, command history, background tasks, bash mode, prompt suggestions, task list, and PR review status
- [Keybindings](references/claude-code-keybindings.md) -- customizable keyboard shortcuts, contexts, available actions, keystroke syntax, chords, vim mode interaction, and validation
- [Terminal Configuration](references/claude-code-terminal-config.md) -- terminal themes, line break setup, notification configuration, large input handling, and vim mode overview

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
