---
name: cli-doc
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, including CLI commands, flags, slash commands, keyboard shortcuts, keybindings customization, terminal configuration, and the built-in tools reference.

## Quick Reference

### CLI Commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive, then exit) |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (use `--console` for API billing) |
| `claude auth status` | Show auth status (`--text` for human-readable) |
| `claude agents` | List configured subagents |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude remote-control` | Start Remote Control server |
| `claude setup-token` | Generate long-lived OAuth token for CI |

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Load most recent conversation |
| `-r`, `--resume` | Resume session by ID or name |
| `-n`, `--name` | Set display name for the session |
| `-w`, `--worktree` | Start in isolated git worktree |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--permission-mode` | Start in a permission mode (`default`, `acceptEdits`, `plan`, `auto`, `bypassPermissions`) |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--output-format` | Output format for print mode (`text`, `json`, `stream-json`) |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Cap API spend in dollars (print mode only) |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--tools` | Restrict available built-in tools |
| `--allowedTools` | Tools that run without permission prompts |
| `--disallowedTools` | Tools removed from model's context |
| `--add-dir` | Add additional working directories |
| `--mcp-config` | Load MCP servers from JSON file |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP |
| `--plugin-dir` | Load plugins from directory (session only) |
| `--effort` | Set effort level (`low`, `medium`, `high`, `xhigh`, `max`) |
| `--debug` | Enable debug mode with optional category filter |
| `--verbose` | Show full turn-by-turn output |

### System Prompt Flags

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags combine with either.

### Built-in Slash Commands (selected)

| Command | Purpose |
| :--- | :--- |
| `/clear` | New conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Summarize context to free space |
| `/config` | Open settings UI (alias: `/settings`) |
| `/cost` | Show token usage statistics |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings |
| `/effort [level]` | Set model effort level |
| `/export [filename]` | Export conversation as plain text |
| `/hooks` | View hook configurations |
| `/memory` | Edit CLAUDE.md files and auto-memory |
| `/model [model]` | Select or change AI model |
| `/permissions` | Manage tool permission rules |
| `/plan [description]` | Enter plan mode |
| `/recap` | Generate one-line session summary |
| `/resume [session]` | Resume conversation by ID or name |
| `/rewind` | Rewind conversation/code to a previous point |
| `/skills` | List available skills |
| `/status` | Show version, model, account info |
| `/terminal-setup` | Configure Shift+Enter and other keybindings |
| `/theme` | Change color theme |
| `/btw <question>` | Side question without adding to conversation |
| `/branch [name]` | Fork conversation at current point |

**Bundled skill commands** (invoked as prompts, not built-in logic):

| Command | Purpose |
| :--- | :--- |
| `/batch <instruction>` | Parallel large-scale codebase changes |
| `/debug [description]` | Enable debug logging and analyze session log |
| `/fewer-permission-prompts` | Auto-add allowlist from transcript analysis |
| `/loop [interval] [prompt]` | Run prompt repeatedly on a schedule |
| `/simplify [focus]` | Multi-agent code quality review and fix |

### Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit Claude Code |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+L` | Clear prompt input, redraw screen |
| `Ctrl+B` | Background running task (press twice in tmux) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open prompt in external editor |
| `Shift+Tab` | Cycle permission modes |
| `Alt+P` / `Option+P` | Switch model |
| `Alt+T` / `Option+T` | Toggle extended thinking |
| `Esc` + `Esc` | Rewind/summarize conversation |
| `\` + `Enter` | Insert newline (all terminals) |
| `Ctrl+J` | Insert newline (all terminals) |
| `Shift+Enter` | Insert newline (most terminals natively) |
| `!` at start | Bash mode — run shell command directly |
| `@` | File path autocomplete |

### Multiline Input Methods

| Method | Shortcut | Notes |
| :--- | :--- | :--- |
| Quick escape | `\` + `Enter` | Works in all terminals |
| Control sequence | `Ctrl+J` | Works in any terminal |
| Shift+Enter | `Shift+Enter` | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal |
| Option key | `Option+Enter` | After enabling Option as Meta on macOS |

### Keybindings Customization

File: `~/.claude/keybindings.json` (open with `/keybindings`)

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

Key contexts: `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `Select`

Action format: `namespace:action` (e.g., `chat:submit`, `app:toggleTodos`)

Reserved (cannot rebind): `Ctrl+C`, `Ctrl+D`, `Ctrl+M`

### Built-in Tools

| Tool | Permission Required | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawn subagent with its own context |
| `Bash` | Yes | Execute shell commands |
| `Edit` | Yes | Make targeted file edits |
| `Glob` | No | Find files by pattern |
| `Grep` | No | Search file contents |
| `LSP` | No | Code intelligence (requires plugin) |
| `Monitor` | Yes | Watch command output in background |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `Read` | No | Read file contents |
| `Skill` | Yes | Execute a skill |
| `WebFetch` | Yes | Fetch URL content |
| `WebSearch` | Yes | Perform web searches |
| `Write` | Yes | Create or overwrite files |
| `PowerShell` | Yes | Execute PowerShell commands (opt-in) |
| `TodoWrite` | No | Manage session task checklist (non-interactive/SDK) |

### Terminal Configuration

| Issue | Fix |
| :--- | :--- |
| Shift+Enter submits (VS Code, Cursor, Zed, Alacritty, Windsurf) | Run `/terminal-setup` once |
| Option key shortcuts do nothing (macOS) | Enable Option as Meta in terminal settings |
| No notification when Claude finishes | Configure Notification hook; or enable in iTerm2/Ghostty/Kitty |
| Display flickers in scrollback | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Running inside tmux | Add `set -g allow-passthrough on`, `set -s extended-keys on`, `set -as terminal-features 'xterm*:extkeys'` to `~/.tmux.conf` |
| Vim keybindings in prompt | Enable via `/config` → Editor mode, or set `editorMode: "vim"` in `~/.claude.json` |

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — All CLI commands and flags
- [Commands](references/claude-code-commands.md) — Complete slash command reference including bundled skills
- [Interactive Mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, Vim mode, bash mode, side questions, task list, and session recap
- [Keybindings](references/claude-code-keybindings.md) — Customizing keyboard shortcuts via `~/.claude/keybindings.json`
- [Terminal Configuration](references/claude-code-terminal-config.md) — Shift+Enter, Option key, tmux, fullscreen rendering, Vim mode setup
- [Tools Reference](references/claude-code-tools-reference.md) — Built-in tools, permission requirements, Bash/LSP/Monitor/PowerShell behavior

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
