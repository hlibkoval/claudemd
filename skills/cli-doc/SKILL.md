---
name: cli-doc
description: Complete official documentation for the Claude Code CLI — launch commands, flags, in-session slash commands, interactive keyboard shortcuts, Vim editing mode, keybindings customization, terminal configuration, and built-in tools reference.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface.

## Quick Reference

### CLI Launch Commands

| Command | Description |
| :------ | :---------- |
| `claude` | Start interactive session |
| `claude "query"` | Start with initial prompt |
| `claude -p "query"` | Print mode (non-interactive, then exit) |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall binary (`stable`, `latest`, or version number) |
| `claude auth login` | Sign in (`--console` for API billing, `--sso` for SSO) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | Open agent view; piped: lists subagents |
| `claude attach <id>` | Attach to background session |
| `claude logs <id>` | Print output from background session |
| `claude stop <id>` | Stop background session (alias: `kill`) |
| `claude rm <id>` | Remove background session from list |
| `claude respawn <id>` | Restart stopped session (`--all` for every stopped) |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins (alias: `plugins`) |
| `claude project purge [path]` | Delete all local state for a project (`--dry-run`, `-y`, `--all`) |
| `claude remote-control` | Start Remote Control server (`--name`) |
| `claude setup-token` | Generate long-lived OAuth token for CI/scripts |
| `claude ultrareview [target]` | Run ultrareview non-interactively (`--json`, `--timeout`) |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |

### Key CLI Flags

| Flag | Description |
| :--- | :---------- |
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Load most recent conversation |
| `-r`, `--resume` | Resume session by ID or name |
| `-n`, `--name` | Set display name for session |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in a permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--add-dir` | Add additional working directories |
| `--bg` | Start as background agent, return immediately |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--worktree`, `-w` | Start in an isolated git worktree |
| `--tools` | Restrict available built-in tools (`""` = none, `"default"` = all) |
| `--allowedTools` | Tools that run without permission prompts |
| `--disallowedTools` | Tools removed from model context entirely |
| `--output-format` | Print mode output format: `text`, `json`, `stream-json` |
| `--input-format` | Print mode input format: `text`, `stream-json` |
| `--max-turns` | Limit agentic turns in print mode |
| `--max-budget-usd` | Max dollar spend in print mode |
| `--system-prompt` | Replace entire system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt` | Append text to default system prompt |
| `--append-system-prompt-file` | Append file to default system prompt |
| `--mcp-config` | Load MCP servers from JSON files |
| `--plugin-dir` | Load plugin from directory or `.zip` for this session |
| `--plugin-url` | Fetch plugin `.zip` from URL for this session |
| `--debug` | Enable debug mode (optional category filter: `"api,hooks"`) |
| `--debug-file <path>` | Write debug logs to file |
| `--init` | Run Setup hooks with `init` matcher before session (`-p` only) |
| `--init-only` | Run Setup and SessionStart hooks, then exit |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a pull request |
| `--remote` | Create a new web session on claude.ai |
| `--teleport` | Resume a web session in your local terminal |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, `tmux` |
| `--tmux` | Create a tmux session for the worktree |
| `--verbose` | Enable verbose turn-by-turn logging |
| `--version`, `-v` | Output version number |

### System Prompt Flag Decision Guide

| Flag | Behavior | Use when |
| :--- | :------- | :------- |
| `--system-prompt` | Replaces entire default prompt | Non-coding pipeline, different identity |
| `--system-prompt-file` | Replaces with file contents | Same, but prompt is in a file |
| `--append-system-prompt` | Appends to default prompt | Adding rules while keeping coding assistant identity |
| `--append-system-prompt-file` | Appends file to default prompt | Same, but extra rules are in a file |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either.

### In-Session Commands (Slash Commands)

Selected important commands — full list is in `references/claude-code-commands.md`:

| Command | Type | Description |
| :------ | :--- | :---------- |
| `/clear [name]` | Built-in | Start new conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Built-in | Summarize conversation to free context |
| `/context [all]` | Built-in | Visualize context usage |
| `/plan [description]` | Built-in | Enter plan mode |
| `/model [model]` | Built-in | Select/change AI model |
| `/effort [level]` | Built-in | Set effort level |
| `/diff` | Built-in | Open interactive diff viewer |
| `/review [PR]` | Built-in | Review a pull request locally |
| `/rewind` | Built-in | Rewind conversation and/or code (aliases: `/checkpoint`, `/undo`) |
| `/resume [session]` | Built-in | Resume a previous conversation |
| `/branch [name]` | Built-in | Branch current conversation (alias: `/fork`) |
| `/background [prompt]` | Built-in | Detach session to run as background agent (alias: `/bg`) |
| `/batch <instruction>` | Skill | Orchestrate large-scale parallel changes |
| `/btw <question>` | Built-in | Ask side question without adding to context |
| `/memory` | Built-in | Edit CLAUDE.md, manage auto-memory |
| `/permissions` | Built-in | Manage allow/ask/deny rules (alias: `/allowed-tools`) |
| `/hooks` | Built-in | View hook configurations |
| `/agents` | Built-in | Manage subagent configurations |
| `/tasks` | Built-in | List and manage background tasks |
| `/mcp` | Built-in | Manage MCP server connections |
| `/plugin` | Built-in | Manage plugins |
| `/skills` | Built-in | List available skills |
| `/config` | Built-in | Open settings interface (alias: `/settings`) |
| `/theme` | Built-in | Change color theme |
| `/keybindings` | Built-in | Open keybindings configuration file |
| `/init` | Built-in | Initialize CLAUDE.md |
| `/debug [description]` | Skill | Enable debug logging and troubleshoot |
| `/doctor` | Built-in | Diagnose installation issues |
| `/feedback` | Built-in | Submit feedback (alias: `/bug`) |
| `/usage` | Built-in | Show session cost and plan limits (aliases: `/cost`, `/stats`) |
| `/simplify [focus]` | Skill | Review recent files for quality/efficiency issues |
| `/security-review` | Built-in | Analyze pending changes for security issues |
| `/add-dir <path>` | Built-in | Add working directory for current session |
| `/goal [condition]` | Built-in | Set autonomous goal; Claude works until condition is met |
| `/rename [name]` | Built-in | Rename current session |
| `/copy [N]` | Built-in | Copy last assistant response to clipboard |
| `/export [filename]` | Built-in | Export conversation as plain text |
| `/recap` | Built-in | Generate one-line session summary |
| `/status` | Built-in | Show version, model, account info |
| `/tui [default\|fullscreen]` | Built-in | Set terminal UI renderer |
| `/voice [hold\|tap\|off]` | Built-in | Toggle voice dictation |

MCP prompts appear as `/mcp__<server>__<prompt>` commands.

### Interactive Keyboard Shortcuts

**General controls:**

| Shortcut | Description |
| :------- | :---------- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit Claude Code |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open in external text editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running tasks |
| `Ctrl+T` | Toggle task list |
| `Esc` | Interrupt current response/tool call |
| `Esc` + `Esc` | Rewind/summarize conversation |
| `Shift+Tab` | Cycle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |

**Text editing:**

| Shortcut | Description |
| :------- | :---------- |
| `Ctrl+A` | Move to start of line |
| `Ctrl+E` | Move to end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` | Move cursor back one word |
| `Alt+F` | Move cursor forward one word |

**Multiline input methods:**

| Method | Shortcut |
| :----- | :------- |
| `\` + Enter | Works in all terminals |
| `Ctrl+J` | Works in any terminal |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| Option+Enter | After enabling Option as Meta on macOS |

**Quick command prefixes:**

| Prefix | Description |
| :----- | :---------- |
| `/` at start | Command or skill |
| `!` at start | Shell mode — run commands directly |
| `@` | File path autocomplete |

### Vim Editor Mode

Enable via `/config` → Editor mode. Key navigation (NORMAL mode only):

| Command | Action |
| :------ | :----- |
| `h`/`j`/`k`/`l` | Move left/down/up/right |
| `w`/`e`/`b` | Next word / end of word / previous word |
| `0` / `$` | Beginning / end of line |
| `gg` / `G` | Beginning / end of input |
| `f{char}` / `F{char}` | Jump to next/previous occurrence of char |
| `i`, `a`, `o`, `O` | Enter INSERT mode |
| `v` / `V` | Character-wise / line-wise visual selection |
| `dd` / `D` | Delete line / delete to end |
| `cc` / `C` | Change line / change to end |
| `yy` / `p` | Yank line / paste after |
| `u` | Undo |
| `.` | Repeat last change |

Text objects: `iw`/`aw` (word), `i"`/`a"` (quotes), `i(`/`a(` (parens), `i{`/`a{` (braces).

### Keybindings Customization

Config file: `~/.claude/keybindings.json` (open with `/keybindings`). Changes apply live without restart.

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

Set a binding to `null` to unbind it. Key contexts include: `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `Settings`, `Select`, `Scroll`, `Plugin`, and more.

Key action namespaces: `app:`, `chat:`, `history:`, `autocomplete:`, `confirm:`, `transcript:`, `historySearch:`, `task:`, `scroll:`, `selection:`, and others.

**Reserved shortcuts** (cannot be rebound): `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, Caps Lock.

**Terminal conflicts**: `Ctrl+B` (tmux prefix), `Ctrl+A` (GNU screen), `Ctrl+Z` (SIGTSTP).

### Terminal Configuration

| Problem | Fix |
| :------ | :-- |
| Shift+Enter submits instead of newline | Run `/terminal-setup` in VS Code/Cursor/Windsurf/Alacritty/Zed; for gnome-terminal/JetBrains use `Ctrl+J` |
| Option/Alt shortcuts do nothing on macOS | Enable "Use Option as Meta Key" in terminal settings |
| No bell/notification when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` in settings, or add a Notification hook |
| Flicker or scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Running inside tmux | Add `set -g allow-passthrough on`, `set -s extended-keys on`, `set -as terminal-features 'xterm*:extkeys'` to `~/.tmux.conf` |

**Custom themes:** JSON files in `~/.claude/themes/`. Fields: `name`, `base` (dark/light/dark-daltonized/light-daltonized/dark-ansi/light-ansi), `overrides` (color token map). Create interactively via `/theme` → New custom theme.

### Built-in Tools Reference

| Tool | Description | Permission Required |
| :--- | :---------- | :------------------ |
| `Agent` | Spawns a subagent in a separate context window | No |
| `AskUserQuestion` | Asks multiple-choice questions | No |
| `Bash` | Executes shell commands | Yes |
| `Edit` | Targeted file edits (exact string replacement) | Yes |
| `Glob` | Find files by pattern | No |
| `Grep` | Search file contents (ripgrep syntax) | No |
| `LSP` | Code intelligence via language servers | No |
| `Monitor` | Watch a command in background, react to output | Yes |
| `NotebookEdit` | Modify Jupyter notebook cells | Yes |
| `PowerShell` | Execute PowerShell commands (Windows/opt-in) | Yes |
| `Read` | Read file contents with line numbers | No |
| `Skill` | Execute a skill | Yes |
| `WebFetch` | Fetch URL and extract content | Yes |
| `WebSearch` | Search the web (Anthropic backend) | Yes |
| `Write` | Create or overwrite files | Yes |
| `TodoWrite` | Manage session task checklist (legacy) | No |
| `TaskCreate`/`TaskList`/`TaskUpdate`/`TaskGet`/`TaskStop` | Task management | No |
| `CronCreate`/`CronDelete`/`CronList` | Schedule recurring prompts in session | No |
| `EnterPlanMode` / `ExitPlanMode` | Switch to/from plan mode | No / Yes |
| `EnterWorktree` / `ExitWorktree` | Create/exit git worktrees | No |

**Permission rule syntax:** `ToolName(specifier)` — e.g., `Bash(git *)`, `Edit(/src/**)`, `Read(~/secrets/**)`, `WebFetch(domain:example.com)`, `Skill(deploy *)`.

**Bash tool notes:**
- `cd` persists within project/additional directories; resets if outside
- Environment variables do NOT persist between commands
- Default timeout: 2 minutes (up to 10 min per command); output cap: 30,000 chars
- Override: `BASH_DEFAULT_TIMEOUT_MS`, `BASH_MAX_TIMEOUT_MS`, `BASH_MAX_OUTPUT_LENGTH`

**Edit tool notes:**
- Requires read-before-edit; `old_string` must be unique
- `cat` and `sed -n` via Bash also satisfy the read requirement

**Grep tool notes:** Uses ripgrep syntax. Output modes: `files_with_matches` (default), `content`, `count`. Respects `.gitignore`.

**WebFetch tool notes:** Extracts content via a small model; results are lossy. Caches 15 min. Automatically upgrades HTTP to HTTPS. Does not follow cross-host redirects (returns redirect info instead).

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — all launch commands and flags, system prompt flags
- [Commands](references/claude-code-commands.md) — complete in-session slash command reference
- [Interactive mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, Vim mode, command history, shell mode, prompt suggestions, `/btw`, task list, session recap
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) — keybindings file format, all contexts and actions, chord syntax, unbinding, reserved shortcuts
- [Configure your terminal](references/claude-code-terminal-config.md) — Shift+Enter, Option key, notifications, tmux, fullscreen rendering, custom themes, Vim mode
- [Tools reference](references/claude-code-tools-reference.md) — full per-tool behavior, permission rule syntax, Bash/Edit/Glob/Grep/LSP/Monitor/WebFetch/WebSearch/Write details

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure your terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
