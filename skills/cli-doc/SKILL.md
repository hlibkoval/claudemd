---
name: cli-doc
description: Complete official documentation for the Claude Code CLI — commands, flags, slash commands, interactive mode keyboard shortcuts, keybindings configuration, terminal setup, and built-in tools reference.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, slash commands, keybindings, terminal configuration, and tools.

## Quick Reference

### Starting Claude Code

| Command | Description |
| :------ | :---------- |
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Non-interactive print mode (Agent SDK) |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude --bg "task"` | Start as background agent, return immediately |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in to Anthropic account |

### Key CLI Flags

| Flag | Description |
| :--- | :---------- |
| `-p`, `--print` | Print mode — non-interactive, exits after response |
| `-c`, `--continue` | Continue most recent conversation |
| `-r`, `--resume` | Resume specific session by ID or name |
| `-n`, `--name` | Set display name for the session |
| `--model` | Set model for this session (e.g., `claude-sonnet-4-6`) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in: `default`, `acceptEdits`, `plan`, `auto`, `bypassPermissions` |
| `--output-format` | Print mode output: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Spending cap in print mode |
| `--add-dir` | Add additional working directories |
| `--allowedTools` | Tools that run without permission prompts |
| `--disallowedTools` | Tools removed from model context entirely |
| `--tools` | Restrict which built-in tools are available |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append text to default system prompt |
| `--mcp-config` | Load MCP servers from JSON file or string |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--bg` | Start as background agent |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--plugin-dir` | Load plugin from directory or .zip for this session |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--debug` | Enable debug mode with optional category filter |

### System Prompt Flags

| Flag | Behavior |
| :--- | :------- |
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag.

### Session Management Commands

| Command | Description |
| :------ | :---------- |
| `claude agents` | Open agent view / list subagents (piped) |
| `claude attach <id>` | Attach to background session |
| `claude logs <id>` | Print output from background session |
| `claude stop <id>` | Stop a background session |
| `claude respawn <id>` | Restart stopped session with conversation intact |
| `claude rm <id>` | Remove background session from list |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude remote-control` | Start Remote Control server |

### Slash Commands (in-session)

**Session management:**

| Command | Description |
| :------ | :---------- |
| `/clear [name]` | Start new conversation (preserves previous in `/resume`) |
| `/compact [instructions]` | Summarize conversation to free context |
| `/resume [session]` | Resume a previous conversation |
| `/branch [name]` | Fork the current conversation |
| `/rename [name]` | Rename the current session |
| `/export [filename]` | Export conversation as plain text |
| `/rewind` | Rewind conversation/code to a previous checkpoint |

**Task and context:**

| Command | Description |
| :------ | :---------- |
| `/context [all]` | Visualize context usage with optimization hints |
| `/tasks` | List and manage background tasks |
| `/background [prompt]` | Detach session to run as background agent |
| `/batch <instruction>` | Orchestrate large-scale codebase changes in parallel |
| `/btw <question>` | Ask a side question without adding to conversation history |
| `/goal [condition]` | Set a goal Claude works toward across turns |
| `/plan [description]` | Enter plan mode |

**Model and settings:**

| Command | Description |
| :------ | :---------- |
| `/model [model]` | Switch the AI model |
| `/effort [level]` | Set effort level interactively |
| `/config` | Open settings interface |
| `/permissions` | Manage tool permission allow/ask/deny rules |
| `/theme` | Change color theme |

**Code review:**

| Command | Description |
| :------ | :---------- |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/review [PR]` | Review a pull request |
| `/security-review` | Analyze pending changes for security issues |
| `/simplify [focus]` | Review and fix recently changed files |

**Diagnostics:**

| Command | Description |
| :------ | :---------- |
| `/doctor` | Diagnose Claude Code installation and settings |
| `/debug [description]` | Enable debug logging and troubleshoot issues |
| `/usage` | Show session cost, plan limits, and stats |
| `/status` | Show version, model, account, and connectivity |
| `/feedback` | Submit feedback or report a bug |

**Skills (bundled):**

| Command | Description |
| :------ | :---------- |
| `/batch <instruction>` | Parallel large-scale codebase changes in isolated worktrees |
| `/loop [interval] [prompt]` | Run a prompt repeatedly on a schedule |
| `/simplify [focus]` | Review changed files for quality/efficiency, then fix |
| `/debug [description]` | Enable debug logging, analyze issues |
| `/fewer-permission-prompts` | Scan transcripts and add permission allowlist |

### Interactive Mode Keyboard Shortcuts

**General controls:**

| Shortcut | Description |
| :------- | :---------- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit Claude Code |
| `Esc` | Interrupt Claude (stops current response, keeps work done) |
| `Esc Esc` | Rewind or summarize conversation |
| `Shift+Tab` | Cycle permission modes (`default` → `acceptEdits` → `plan` → ...) |
| `Option+P` / `Alt+P` | Switch model without clearing prompt |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open prompt in external editor |
| `Ctrl+B` | Background running task (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+L` | Redraw screen |

**Text editing:**

| Shortcut | Description |
| :------- | :---------- |
| `Ctrl+A` | Move to start of line |
| `Ctrl+E` | Move to end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

**Multiline input methods:**

| Method | Shortcut | Notes |
| :----- | :------- | :---- |
| Quick escape | `\` + `Enter` | Works in all terminals |
| Control sequence | `Ctrl+J` | Works everywhere without config |
| Shift+Enter | `Shift+Enter` | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| Option key | `Option+Enter` | macOS after enabling Option as Meta |

**Quick input prefixes:**

| Prefix | Description |
| :----- | :---------- |
| `/` | Command or skill |
| `!` | Shell mode — run command directly, add output to context |
| `@` | File path autocomplete |

### Keybindings Configuration

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

Actions use `namespace:action` format. Set to `null` to unbind. Changes apply without restart.

**Key contexts:** `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Scroll`, `Settings`, `Select`, `Plugin`, `Doctor`

**Key chat actions:** `chat:submit`, `chat:newline`, `chat:cancel`, `chat:cycleMode`, `chat:modelPicker`, `chat:fastMode`, `chat:thinkingToggle`, `chat:externalEditor`, `chat:imagePaste`

**Keystroke syntax:** `ctrl+k`, `shift+tab`, `meta+p`, `ctrl+shift+c`. Chords: `ctrl+k ctrl+s`. Set uppercase letter alone for Shift (`K` = `shift+k`).

**Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, Caps Lock.

### Built-in Tools Reference

| Tool | Permission Required | Description |
| :--- | :------------------ | :---------- |
| `Agent` | No | Spawns a subagent with its own context window |
| `AskUserQuestion` | No | Asks multiple-choice questions |
| `Bash` | Yes | Executes shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Manage scheduled tasks |
| `Edit` | Yes | Exact string replacement in files |
| `EnterPlanMode` / `ExitPlanMode` | No / Yes | Switch into/out of plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Create/exit isolated git worktrees |
| `Glob` | No | Find files by pattern (supports `**`) |
| `Grep` | No | Search file contents with ripgrep regex |
| `LSP` | No | Code intelligence: definitions, references, type info |
| `Monitor` | Yes | Watch a command in background and react to output |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells by `cell_id` |
| `PowerShell` | Yes | Execute PowerShell commands natively |
| `PushNotification` | No | Send desktop/phone push notification |
| `Read` | No | Read file contents with line numbers |
| `Skill` | Yes | Execute a skill within the conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Manage background tasks |
| `TodoWrite` | No | Session task checklist (legacy; prefer Task tools) |
| `ToolSearch` | No | Load deferred MCP tools on demand |
| `WebFetch` | Yes | Fetch URL, convert to Markdown, run extraction prompt |
| `WebSearch` | Yes | Search the web, returns titles and URLs |
| `Write` | Yes | Create or overwrite a file |

**Tool permission rule formats:**

| Rule | Applies to |
| :--- | :--------- |
| `Bash(npm run *)` | Bash, Monitor — command pattern |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP — path pattern |
| `Edit(/src/**)` | Edit, Write, NotebookEdit — path pattern |
| `WebFetch(domain:example.com)` | WebFetch — domain match |
| `Skill(deploy *)` | Skill — name pattern |
| `Agent(Explore)` | Agent — subagent type |
| `WebSearch` | WebSearch — no specifier |

### Terminal Configuration

**Multiline (Shift+Enter) support:**

| Terminal | Setup needed |
| :------- | :----------- |
| Ghostty, Kitty, iTerm2, WezTerm, Warp, Apple Terminal, Windows Terminal | None |
| VS Code, Cursor, Windsurf, Alacritty, Zed | Run `/terminal-setup` once |
| gnome-terminal, JetBrains IDEs | Not available; use `Ctrl+J` or `\` then Enter |

**tmux config** (`~/.tmux.conf`):
```bash
set -g allow-passthrough on
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'
```

**Option key as Meta on macOS:**
- iTerm2: Settings → Profiles → Keys → set Option key to "Esc+"
- Apple Terminal: Settings → Profiles → Keyboard → "Use Option as Meta Key"
- VS Code: `"terminal.integrated.macOptionIsMeta": true`

**Fullscreen rendering** (reduces flicker, adds mouse support):
```bash
CLAUDE_CODE_NO_FLICKER=1 claude  # or /tui fullscreen in-session
```

**Custom themes:** JSON files in `~/.claude/themes/`. Fields: `name`, `base` (`dark`/`light`/etc.), `overrides` (color token map). Use `/theme` → "New custom theme..." to create interactively.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — all CLI commands and flags
- [Commands](references/claude-code-commands.md) — complete slash command reference
- [Interactive Mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, vim mode, shell mode, task list
- [Keybindings](references/claude-code-keybindings.md) — customize keyboard shortcuts via config file
- [Terminal Configuration](references/claude-code-terminal-config.md) — Shift+Enter, Option key, tmux, themes, fullscreen
- [Tools Reference](references/claude-code-tools-reference.md) — built-in tools, permission rules, and per-tool behavior

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
