---
name: cli-doc
description: Complete official documentation for Claude Code CLI — launch commands, flags, interactive-mode keyboard shortcuts, slash commands, keybindings configuration, terminal setup, and built-in tools reference.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, covering how to launch and configure sessions, all interactive-mode shortcuts and slash commands, keybindings customization, terminal configuration, and the full built-in tools reference.

## Quick Reference

### CLI commands (launch-time)

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive, SDK-style) |
| `claude -c` | Continue most recent conversation |
| `claude -r "<name>"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall binary (`stable`, `latest`, or version number) |
| `claude auth login` | Sign in (`--console` for API billing, `--sso` for SSO) |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List configured subagents |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude remote-control` | Start a Remote Control server |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

### Key CLI flags

| Flag | Description |
| :--- | :--- |
| `--print`, `-p` | Non-interactive print mode |
| `--continue`, `-c` | Resume most recent conversation |
| `--resume`, `-r` | Resume session by ID or name |
| `--name`, `-n` | Set a session display name |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in a permission mode: `default`, `acceptEdits`, `plan`, `auto`, `bypassPermissions` |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--tools` | Restrict available tools (`""` = none, `"default"` = all) |
| `--allowedTools` | Tools that run without prompting |
| `--disallowedTools` | Tools to remove entirely |
| `--add-dir` | Grant file access to additional directories |
| `--bare` | Minimal mode — skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--max-turns` | Limit agentic turns in print mode |
| `--max-budget-usd` | Spending cap in print mode |
| `--worktree`, `-w` | Start in an isolated git worktree |
| `--mcp-config` | Load MCP servers from a JSON file |
| `--plugin-dir` | Load plugins from a directory for this session |
| `--debug` | Enable debug mode with optional category filter |
| `--dangerously-skip-permissions` | Skip all permission prompts |

### System prompt flag behavior

| Flag | Effect |
| :--- | :--- |
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag. Prefer append flags to preserve built-in capabilities.

---

### Interactive-mode keyboard shortcuts

#### General controls

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open in external editor |
| `Ctrl+L` | Clear prompt input and redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse-search command history |
| `Ctrl+B` | Background running task (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Shift+Tab` | Cycle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |
| `Esc Esc` | Rewind or summarize |

#### Text editing

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+A` / `Ctrl+E` | Move cursor to line start/end |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

#### Multiline input methods

| Method | Shortcut |
| :--- | :--- |
| Quick escape | `\` + Enter |
| Option key (macOS, requires Meta) | `Option+Enter` |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal |
| Control sequence | `Ctrl+J` (works everywhere) |

#### Quick-entry prefixes

| Prefix | Description |
| :--- | :--- |
| `/` at start | Open command/skill menu |
| `!` at start | Shell mode — run command directly, add output to context |
| `@` | Trigger file-path autocomplete |

---

### Slash commands (selected)

| Command | Description |
| :--- | :--- |
| `/add-dir <path>` | Add a working directory for file access |
| `/btw <question>` | Side question without adding to conversation |
| `/clear` | New conversation (previous stays in `/resume`) |
| `/compact [instructions]` | Summarize conversation to free context |
| `/config` | Open settings interface |
| `/context` | Visualize context usage |
| `/copy [N]` | Copy last (or Nth) response to clipboard |
| `/debug` | Enable debug logging mid-session |
| `/diff` | Open interactive diff viewer |
| `/doctor` | Diagnose installation |
| `/effort [level]` | Change effort level live |
| `/exit` | Exit Claude Code |
| `/export` | Export conversation as plain text |
| `/hooks` | View hook configurations |
| `/init` | Initialize CLAUDE.md for project |
| `/keybindings` | Open or create keybindings file |
| `/memory` | Edit CLAUDE.md files, manage auto-memory |
| `/model` | Change model |
| `/permissions` | Manage allow/ask/deny rules |
| `/plan [description]` | Enter plan mode |
| `/recap` | Generate session summary on demand |
| `/reload-plugins` | Reload active plugins |
| `/remote-control` | Enable remote control for this session |
| `/rename [name]` | Rename current session |
| `/resume [session]` | Resume a previous conversation |
| `/rewind` | Rewind conversation/code to a checkpoint |
| `/skills` | List available skills |
| `/status` | Show version, model, account (works mid-response) |
| `/tasks` | List and manage background tasks |
| `/terminal-setup` | Configure Shift+Enter and other bindings in terminal |
| `/theme` | Change color theme |
| `/usage` | Show session cost and plan usage |
| `/vim` | (Removed v2.1.92; use `/config` → Editor mode) |

Commands marked **[Skill]** (`/batch`, `/debug`, `/loop`, `/simplify`, etc.) are bundled skills that hand a prompt to Claude rather than built-in coded behavior. Availability depends on plan, platform, and environment.

---

### Keybindings configuration

File: `~/.claude/keybindings.json` — opened/created with `/keybindings`.

Changes are detected and applied live without restarting.

**Contexts** (where bindings apply): `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Tabs`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Select`, `Plugin`, `Scroll`, `Doctor`, and more.

**Action format:** `namespace:action` — e.g., `chat:submit`, `app:toggleTodos`.

**Key syntax examples:**

| Syntax | Meaning |
| :--- | :--- |
| `ctrl+k` | Ctrl + K |
| `shift+tab` | Shift + Tab |
| `meta+p` | Option+P on macOS, Alt+P elsewhere |
| `ctrl+x ctrl+e` | Chord sequence |
| `K` (uppercase alone) | Shift+K (vim-style) |

**Unbind** a shortcut by setting it to `null`. **Reserved** (cannot be rebound): `Ctrl+C`, `Ctrl+D`, `Ctrl+M`.

---

### Terminal configuration quick-fixes

| Symptom | Fix |
| :--- | :--- |
| Shift+Enter submits | Run `/terminal-setup` (VS Code, Cursor, Windsurf, Alacritty, Zed); or add tmux passthrough config |
| Option shortcuts do nothing (macOS) | Enable "Option as Meta" in terminal settings; or set `"terminal.integrated.macOptionIsMeta": true` in VS Code |
| No bell/notification | Set up a Notification hook in `settings.json`, or enable in iTerm2 Settings |
| Display flickers / scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |

**tmux config** (add to `~/.tmux.conf`):
```
set -g allow-passthrough on
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'
```

**Custom themes** live in `~/.claude/themes/<slug>.json` with optional `name`, `base`, and `overrides` fields. Claude Code hot-reloads them on change.

---

### Built-in tools reference

| Tool | Permission Required | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawn a subagent |
| `AskUserQuestion` | No | Ask multiple-choice questions |
| `Bash` | Yes | Execute shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Schedule recurring tasks |
| `Edit` | Yes | Make targeted file edits |
| `EnterPlanMode` / `ExitPlanMode` | No / Yes | Switch to/from plan mode |
| `Glob` | No | Find files by pattern |
| `Grep` | No | Search file contents |
| `LSP` | No | Code intelligence (requires language server plugin) |
| `Monitor` | Yes | Watch background output and react (v2.1.98+) |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `PowerShell` | Yes | Execute PowerShell commands (Windows native or opt-in) |
| `Read` | No | Read file contents |
| `Skill` | Yes | Execute a skill |
| `TaskCreate` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Manage task list |
| `WebFetch` | Yes | Fetch URL content |
| `WebSearch` | Yes | Perform web searches |
| `Write` | Yes | Create or overwrite files |

Use tool names verbatim in permission rules, subagent tool lists, and hook matchers.

**Bash tool notes:**
- `cd` within main session persists across Bash commands (within allowed directories).
- Environment variables do not persist between commands.
- Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to always reset to the project directory.

**Monitor tool notes:** Follows Bash permission rules. Not available on Bedrock, Vertex AI, or Microsoft Foundry.

**PowerShell tool notes:** On Windows, enable with `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. On Linux/macOS, requires `pwsh` (PowerShell 7+) on PATH.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — all CLI commands and flags
- [Commands](references/claude-code-commands.md) — complete slash-command reference
- [Interactive Mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, Vim mode, shell mode, background tasks, session features
- [Keybindings](references/claude-code-keybindings.md) — keybindings file format, all contexts, all actions, keystroke syntax
- [Terminal Configuration](references/claude-code-terminal-config.md) — multiline input, Option key, notifications, tmux, themes, fullscreen, Vim mode
- [Tools Reference](references/claude-code-tools-reference.md) — all built-in tools with permission requirements and behavioral notes

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
