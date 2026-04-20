---
name: cli-doc
description: Complete official documentation for Claude Code CLI — commands, flags, interactive mode shortcuts, keybindings, terminal setup, and built-in tools reference.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface.

## Quick Reference

### CLI commands

| Command | Description |
| :------ | :---------- |
| `claude` | Start interactive session |
| `claude "query"` | Start with initial prompt |
| `claude -p "query"` | Print mode (non-interactive, then exit) |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (use `--console` for API billing, `--sso` for SSO) |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List configured subagents |
| `claude plugin` | Manage plugins |
| `claude mcp` | Configure MCP servers |
| `claude remote-control` | Start Remote Control server |
| `claude setup-token` | Generate long-lived OAuth token for CI |

### Key CLI flags

| Flag | Description |
| :--- | :---------- |
| `-p`, `--print` | Non-interactive (print) mode |
| `-c`, `--continue` | Load most recent conversation |
| `-r`, `--resume` | Resume session by ID or name |
| `-n`, `--name` | Set display name for the session |
| `-w`, `--worktree` | Start in isolated git worktree |
| `--add-dir` | Add additional working directories |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--permission-mode` | Start in `default`, `acceptEdits`, `plan`, `auto`, or `bypassPermissions` |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--output-format` | Print mode output: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Spending cap for API calls (print mode only) |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--tools` | Restrict available built-in tools |
| `--allowedTools` | Tools that run without permission prompts |
| `--disallowedTools` | Tools removed from model context |
| `--mcp-config` | Load MCP servers from JSON file |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--plugin-dir` | Load plugins from a directory (session only) |
| `--debug` | Enable debug mode with optional category filter |
| `--debug-file <path>` | Write debug logs to file |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a GitHub PR |
| `--json-schema` | Validate output against JSON Schema (print mode) |
| `--agents` | Define custom subagents dynamically via JSON |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves cache reuse) |
| `--tmux` | Create tmux session for worktree (requires `--worktree`) |
| `--remote` | Create new web session on claude.ai |
| `--teleport` | Resume a web session in local terminal |

### System prompt flags

| Flag | Behavior |
| :--- | :------- |
| `--system-prompt` | Replace entire default prompt |
| `--system-prompt-file` | Replace with file contents |
| `--append-system-prompt` | Append to default prompt |
| `--append-system-prompt-file` | Append file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag. Prefer append flags to preserve built-in capabilities.

### Slash commands (in-session)

Key built-in commands (type `/` in session to browse all):

| Command | Purpose |
| :------ | :------ |
| `/clear` | New conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Summarize conversation to free context |
| `/resume [session]` | Resume conversation by ID or name |
| `/branch [name]` | Fork current conversation (alias: `/fork`) |
| `/model [model]` | Change AI model |
| `/effort [level]` | Set effort level (interactive slider without arg) |
| `/permissions` | Manage allow/ask/deny rules (alias: `/allowed-tools`) |
| `/plan [description]` | Enter plan mode |
| `/config` | Open settings interface (alias: `/settings`) |
| `/cost` | Show token usage statistics |
| `/context` | Visualize context usage |
| `/memory` | Edit CLAUDE.md memory files |
| `/hooks` | View hook configurations |
| `/diff` | Interactive diff viewer |
| `/rewind` | Rewind conversation/code to previous point |
| `/copy [N]` | Copy last N assistant response(s) to clipboard |
| `/export [filename]` | Export conversation as plain text |
| `/recap` | Generate one-line session summary |
| `/rename [name]` | Rename current session |
| `/btw <question>` | Ask side question without affecting conversation |
| `/doctor` | Diagnose installation and settings |
| `/skills` | List available skills |
| `/plugin` | Manage plugins |
| `/mcp` | Manage MCP server connections |
| `/debug [description]` | Enable debug logging for session |
| `/init` | Initialize project with CLAUDE.md |
| `/terminal-setup` | Configure terminal keybindings |
| `/keybindings` | Open keybindings config file |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/theme` | Change color theme |
| `/status` | Show version, model, account, connectivity |
| `/tasks` | List and manage background tasks |
| `/schedule [description]` | Create/manage routines |

**Bundled skill commands** (prefixed `[Skill]`): `/batch`, `/debug`, `/simplify`, `/loop`, `/fewer-permission-prompts`, `/claude-api`

### Interactive keyboard shortcuts

#### General controls

| Shortcut | Description |
| :------- | :---------- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open in external editor |
| `Ctrl+L` | Clear prompt input and redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running task (tmux users press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+X Ctrl+K` | Kill all background agents (confirm within 3s) |
| `Shift+Tab` | Cycle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |
| `Esc Esc` | Rewind or summarize |

#### Text editing shortcuts

| Shortcut | Description |
| :------- | :---------- |
| `Ctrl+A` | Move to start of line |
| `Ctrl+E` | Move to end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` / `Alt+F` | Move back/forward one word |

#### Multiline input

| Method | Shortcut |
| :----- | :------- |
| Quick escape | `\` + `Enter` (all terminals) |
| macOS default | `Option+Enter` |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty; run `/terminal-setup` for VS Code/Warp/Alacritty |
| Control sequence | `Ctrl+J` |

#### Quick prefixes

| Prefix | Effect |
| :----- | :----- |
| `/` | Command or skill |
| `!` | Bash mode (run directly, output added to context) |
| `@` | File path autocomplete |

### Built-in tools

| Tool | Permission Required | Description |
| :--- | :------------------ | :---------- |
| `Agent` | No | Spawn a subagent with its own context window |
| `AskUserQuestion` | No | Ask multiple-choice questions |
| `Bash` | Yes | Execute shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Schedule recurring or one-shot prompts |
| `Edit` | Yes | Make targeted edits to files |
| `EnterPlanMode` / `ExitPlanMode` | No/Yes | Switch to/from plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Create/exit isolated git worktrees |
| `Glob` | No | Find files by pattern |
| `Grep` | No | Search file contents |
| `LSP` | No | Code intelligence (jump to def, find refs, type errors) |
| `Monitor` | Yes | Watch background output and react to changes |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `PowerShell` | Yes | Execute PowerShell commands (opt-in) |
| `Read` | No | Read file contents |
| `Skill` | Yes | Execute a skill in the main conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Manage background tasks |
| `TodoWrite` | No | Session task checklist (non-interactive/Agent SDK) |
| `ToolSearch` | No | Search and load deferred MCP tools |
| `WebFetch` | Yes | Fetch content from a URL |
| `WebSearch` | Yes | Perform web searches |
| `Write` | Yes | Create or overwrite files |

### Keybindings configuration

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

Actions follow `namespace:action` format (e.g., `chat:submit`, `app:toggleTodos`). Set to `null` to unbind. Reserved shortcuts that cannot be rebound: `Ctrl+C`, `Ctrl+D`, `Ctrl+M`.

Key contexts: `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `Settings`, `Task`, `Scroll`, `Plugin`.

### Terminal setup notes

- **Shift+Enter in tmux**: add `set -s extended-keys on` and `set -as terminal-features 'xterm*:extkeys'` to `~/.tmux.conf`
- **Option as Meta (macOS)**: iTerm2 → Profiles → Keys → "Esc+"; Terminal.app → Profiles → Keyboard → "Use Option as Meta Key"
- **Notifications**: Kitty and Ghostty work natively; iTerm2 needs "Notification Center Alerts" enabled; tmux needs `set -g allow-passthrough on`
- **Large inputs**: use file-based workflows instead of direct pasting; VS Code terminal prone to truncation

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — all CLI commands and flags with examples
- [Commands](references/claude-code-commands.md) — complete in-session slash command reference
- [Interactive mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, vim mode, background tasks, bash mode, prompt suggestions, /btw, task list, session recap
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) — keybindings config file format, all contexts and actions, keystroke syntax, chord bindings, unbinding
- [Terminal configuration](references/claude-code-terminal-config.md) — terminal setup, line breaks, notifications, Shift+Enter, vim mode, fullscreen rendering
- [Tools reference](references/claude-code-tools-reference.md) — all built-in tools, permission requirements, Bash/LSP/Monitor/PowerShell tool behavior

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Terminal configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
