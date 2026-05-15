---
name: cli-doc
description: Complete official documentation for Claude Code CLI — command-line flags, launch commands, slash commands, interactive mode shortcuts, Vim editing, keyboard shortcut customization, terminal configuration (Shift+Enter, Option key, tmux, fullscreen, themes), and built-in tools reference with permission rules.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code CLI, interactive mode, keybindings, terminal configuration, and built-in tools.

## Quick Reference

### Launch Commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive, then exit) |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>"` | Resume session by ID or name |
| `claude --bg "task"` | Start as background agent, return immediately |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in to Anthropic account |
| `claude auth status` | Show authentication status as JSON |
| `claude agents` | Open agent view for background sessions |
| `claude mcp` | Configure MCP servers |
| `claude plugin install <name>` | Install a plugin |

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `-p` / `--print` | Non-interactive print mode |
| `-c` / `--continue` | Continue most recent conversation |
| `-r` / `--resume` | Resume session by ID or name |
| `-n` / `--name` | Set display name for the session |
| `--model` | Set model (`sonnet`, `opus`, or full model ID) |
| `--effort` | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start mode: `default`, `acceptEdits`, `plan`, `auto`, `bypassPermissions` |
| `--add-dir` | Add additional working directories |
| `--tools` | Restrict which built-in tools Claude can use |
| `--allowedTools` | Tools that execute without prompting |
| `--disallowedTools` | Tools that cannot be used |
| `--system-prompt` | Replace the entire system prompt |
| `--append-system-prompt` | Append to the default system prompt |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Max API spend before stopping (print mode only) |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--worktree` / `-w` | Start in an isolated git worktree |
| `--plugin-dir` | Load a plugin from a local directory for this session |
| `--dangerously-skip-permissions` | Skip permission prompts (equivalent to `bypassPermissions` mode) |
| `--mcp-config` | Load MCP servers from JSON files |
| `--debug` | Enable debug mode with optional category filtering |

### System Prompt Flags

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can be combined with either replacement flag.

### Slash Commands (Selected)

| Command | Purpose |
| :--- | :--- |
| `/clear` | Start a new conversation (keeps previous for `/resume`) |
| `/compact [instructions]` | Summarize conversation to free context |
| `/context` | Visualize context window usage |
| `/plan [description]` | Enter plan mode |
| `/model` | Switch AI model |
| `/effort` | Adjust effort level interactively |
| `/permissions` | Manage allow/ask/deny rules |
| `/memory` | Edit CLAUDE.md memory files |
| `/resume` | Resume a previous conversation |
| `/diff` | Open interactive diff viewer |
| `/rewind` | Rewind code and conversation to a checkpoint |
| `/background` | Detach session to run as background agent |
| `/batch <instruction>` | [Skill] Parallel large-scale codebase changes |
| `/agents` | Manage subagent configurations |
| `/tasks` | List and manage background tasks |
| `/btw <question>` | Ask a side question without adding to history |
| `/simplify` | [Skill] Review recently changed files for quality |
| `/review [PR]` | Review a pull request |
| `/security-review` | Analyze pending changes for vulnerabilities |
| `/doctor` | Diagnose installation and settings |
| `/config` | Open Settings interface |
| `/skills` | List available skills |
| `/init` | Initialize project with CLAUDE.md |
| `/keybindings` | Open or create keybindings config |
| `/theme` | Change color theme |
| `/teleport` | Pull a web session into this terminal |
| `/remote-control` | Make session available for remote control |

Commands marked **[Skill]** are bundled skills that Claude can also invoke automatically.

### Interactive Mode Keyboard Shortcuts

#### General Controls

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit Claude Code session |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open in external editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running tasks |
| `Ctrl+T` | Toggle task list |
| `Esc` | Interrupt Claude (stop current response) |
| `Esc` + `Esc` | Rewind or summarize |
| `Shift+Tab` | Cycle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |

#### Multiline Input

| Method | Shortcut |
| :--- | :--- |
| Quick escape | `\` + `Enter` (works everywhere) |
| Control sequence | `Ctrl+J` (works everywhere) |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| Option+Enter | After enabling Option as Meta on macOS |

#### Quick Input Prefixes

| Prefix | Action |
| :--- | :--- |
| `/` at start | Command or skill |
| `!` at start | Shell mode (runs command directly) |
| `@` | File path mention / autocomplete |

### Vim Editor Mode

Enable via `/config` → Editor mode. Key mode-switching commands:

| Command | Action | From Mode |
| :--- | :--- | :--- |
| `Esc` | Enter NORMAL mode | INSERT, VISUAL |
| `i` / `I` | Insert before cursor / at line start | NORMAL |
| `a` / `A` | Insert after cursor / at line end | NORMAL |
| `v` / `V` | Character-wise / line-wise visual selection | NORMAL |

Navigation, editing, text objects, and visual mode commands are fully supported. See [interactive mode reference](references/claude-code-interactive-mode.md) for the complete Vim key table.

### Keybindings Configuration

Config file: `~/.claude/keybindings.json` (open with `/keybindings`)

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

Actions use `namespace:action` format. Set an action to `null` to unbind it. Changes apply without restarting.

**Key contexts:** `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Settings`, `Scroll`

**Key chat actions:** `chat:submit`, `chat:newline`, `chat:cancel`, `chat:cycleMode`, `chat:modelPicker`, `chat:externalEditor`, `chat:imagePaste`, `chat:fastMode`, `chat:thinkingToggle`

**Keystroke syntax:** modifiers (`ctrl`, `shift`, `alt`/`meta`, `cmd`) joined by `+`; chords separated by spaces (e.g. `ctrl+k ctrl+s`). Reserved: `Ctrl+C`, `Ctrl+D`, `Ctrl+M`.

### Terminal Configuration

| Issue | Fix |
| :--- | :--- |
| Shift+Enter submits in VS Code/Cursor/Alacritty/Zed | Run `/terminal-setup` once |
| Option key shortcuts do nothing on macOS | Enable Option as Meta in terminal settings |
| No notification when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` or add a Notification hook |
| Running inside tmux | Add `set -g allow-passthrough on`, `set -s extended-keys on`, `set -as terminal-features 'xterm*:extkeys'` to `~/.tmux.conf` |
| Display flickers or scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |

#### Custom Themes

Store in `~/.claude/themes/<slug>.json`:

```json
{
  "name": "Theme Name",
  "base": "dark",
  "overrides": {
    "claude": "#bd93f9",
    "error": "#ff5555",
    "success": "#50fa7b"
  }
}
```

`base` options: `dark`, `light`, `dark-daltonized`, `light-daltonized`, `dark-ansi`, `light-ansi`. Key override tokens: `claude`, `text`, `error`, `success`, `warning`, `promptBorder`, `planMode`, `diffAdded`, `diffRemoved`.

### Built-in Tools Reference

| Tool | Permission Required | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawns a subagent with its own context window |
| `AskUserQuestion` | No | Asks multiple-choice questions |
| `Bash` | Yes | Executes shell commands |
| `Edit` | Yes | Makes targeted string-replacement edits to files |
| `Write` | Yes | Creates or overwrites files |
| `Read` | No | Reads file contents with line numbers |
| `Glob` | No | Finds files by pattern (results sorted by mtime, capped at 100) |
| `Grep` | No | Searches file contents via ripgrep regex |
| `LSP` | No | Code intelligence (definitions, references, type errors) |
| `Monitor` | Yes | Watches a command in background and feeds output lines back |
| `WebFetch` | Yes | Fetches a URL, converts HTML to Markdown, extracts via prompt |
| `WebSearch` | Yes | Runs web search, returns titles and URLs (up to 8 backend queries) |
| `NotebookEdit` | Yes | Modifies Jupyter notebook cells by `cell_id` |
| `PowerShell` | Yes | Executes PowerShell natively (opt-in on Linux/macOS) |
| `Skill` | Yes | Executes a skill within the main conversation |
| `EnterPlanMode` | No | Switches to plan mode |
| `ExitPlanMode` | Yes | Presents plan for approval and exits plan mode |
| `EnterWorktree` | No | Creates or switches into an isolated git worktree |
| `PushNotification` | No | Sends desktop/phone notification (Anthropic-hosted only) |
| `TaskCreate`/`TaskGet`/`TaskList`/`TaskUpdate` | No | Manage session task list |
| `CronCreate`/`CronDelete`/`CronList` | No | Schedule recurring/one-shot prompts within session |

**Permission rule format:** `ToolName(specifier)` — e.g. `Bash(npm run *)`, `Read(~/secrets/**)`, `Edit(/src/**)`, `WebFetch(domain:example.com)`, `Skill(deploy *)`. Tools without a specifier (e.g. `WebSearch`) use bare names.

**Bash tool limits:** 2-minute default timeout (up to 10 min with `timeout` param), 30,000 char output limit. Override with `BASH_DEFAULT_TIMEOUT_MS`, `BASH_MAX_TIMEOUT_MS`, `BASH_MAX_OUTPUT_LENGTH`.

**Edit tool requirements:** Claude must have read the file in the current conversation; `old_string` must match exactly and appear exactly once (or use `replace_all: true`).

**Glob vs Grep:** Glob finds files by name pattern (ignores `.gitignore` by default); Grep searches file contents (respects `.gitignore`).

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — all CLI commands and flags with examples
- [Commands](references/claude-code-commands.md) — complete slash command reference including bundled skills
- [Interactive Mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, Vim mode, shell mode, command history, `/btw`, task list, session recap
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) — keybindings config file, all contexts and actions, keystroke syntax, unbinding, reserved shortcuts
- [Configure Your Terminal](references/claude-code-terminal-config.md) — Shift+Enter, Option key, notifications, tmux, fullscreen rendering, custom themes, Vim mode
- [Tools Reference](references/claude-code-tools-reference.md) — complete tool list, permission rule syntax, per-tool behavior details

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure Your Terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
