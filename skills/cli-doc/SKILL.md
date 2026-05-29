---
name: cli-doc
user-invocable: false
---

# CLI & Interactive Mode Documentation

This skill provides the complete official documentation for the Claude Code command-line interface: CLI commands and flags, slash commands, interactive mode keyboard shortcuts, keybindings customization, terminal configuration, and the built-in tools reference.

## Quick Reference

### CLI Entry Points

| Command | Description | Example |
|:--------|:------------|:--------|
| `claude` | Start interactive session | `claude` |
| `claude "query"` | Start session with initial prompt | `claude "explain this project"` |
| `claude -p "query"` | Print mode (non-interactive, then exit) | `claude -p "fix the bug"` |
| `claude -c` | Continue most recent conversation | `claude -c` |
| `claude -r "<name>"` | Resume session by ID or name | `claude -r "auth-refactor"` |
| `claude --bg "query"` | Start as background session | `claude --bg "investigate flaky test"` |
| `claude update` | Update to latest version | `claude update` |
| `claude auth login` | Sign in to Anthropic account | `claude auth login --console` |
| `claude auth status` | Show auth status | `claude auth status` |
| `claude agents` | Open agent view | `claude agents --json` |
| `claude plugin` | Manage plugins | `claude plugin install <name>@<marketplace>` |
| `claude mcp` | Configure MCP servers | — |
| `claude project purge [path]` | Delete all local state for a project | `claude project purge ~/work/repo --dry-run` |
| `claude setup-token` | Generate long-lived OAuth token for CI | `claude setup-token` |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `-p` / `--print` | Non-interactive print mode |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--allowedTools` | Tools that run without a permission prompt |
| `--disallowedTools` | Tools to remove from Claude's context |
| `--tools` | Restrict available tools (`""` to disable all) |
| `--append-system-prompt` | Append text to default system prompt |
| `--system-prompt` | Replace entire system prompt |
| `--output-format` | `text`, `json`, or `stream-json` (print mode only) |
| `--max-turns` | Cap agentic turns (print mode only) |
| `--max-budget-usd` | Cap spend before stopping (print mode only) |
| `--add-dir` | Add additional working directories |
| `--bare` | Skip hooks, skills, plugins, MCP, CLAUDE.md (faster scripted calls) |
| `--continue` / `-c` | Resume most recent conversation |
| `--resume` / `-r` | Resume by ID/name, or open session picker |
| `--name` / `-n` | Set display name for session |
| `--worktree` / `-w` | Start in an isolated git worktree |
| `--bg` | Start as a background agent |
| `--plugin-dir` | Load plugin from directory or `.zip` for this session |
| `--settings` | Path or inline JSON to override settings |
| `--mcp-config` | Load MCP servers from JSON file |
| `--verbose` | Enable verbose turn-by-turn output |
| `--debug` | Enable debug mode |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. The append flags can be combined with either replacement flag.

### Key Slash Commands (Inside a Session)

| Command | Purpose |
|:--------|:--------|
| `/clear` | Start new conversation (previous stays in `/resume`) |
| `/compact [instructions]` | Summarize conversation to free context |
| `/context` | Visualize context usage |
| `/model [model]` | Switch model |
| `/effort [level]` | Set effort level |
| `/plan [description]` | Enter plan mode |
| `/permissions` | Manage allow/ask/deny rules |
| `/memory` | Edit CLAUDE.md files and auto-memory |
| `/resume [session]` | Resume a conversation by ID or name |
| `/branch [name]` | Fork conversation at this point |
| `/rewind` | Rewind code and conversation to a previous point |
| `/diff` | Interactive diff viewer |
| `/code-review [level] [--fix]` | Review diff for bugs and cleanups |
| `/simplify [target]` | Review changed code for cleanup, apply fixes |
| `/init` | Initialize project CLAUDE.md |
| `/mcp` | Manage MCP server connections |
| `/agents` | Manage agent configurations |
| `/tasks` | List and manage background tasks |
| `/background [prompt]` | Detach session to run as background agent |
| `/skills` | List available skills |
| `/debug [description]` | Enable debug logging, troubleshoot issues |
| `/btw <question>` | Ask a side question without adding to history |
| `/config` | Open Settings interface |
| `/status` | Show version, model, account, connectivity |
| `/usage` | Show session cost and usage stats |
| `/rename [name]` | Rename current session |
| `/exit` / `/quit` | Exit the CLI |
| `/help` | Show help and available commands |

Bundled skill commands: `/batch`, `/code-review`, `/debug`, `/deep-research`, `/fewer-permission-prompts`, `/loop`, `/run`, `/run-skill-generator`, `/simplify`, `/verify`

Bundled workflow commands: `/deep-research`

### Interactive Mode Keyboard Shortcuts

#### General Controls

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Interrupt, or clear input |
| `Ctrl+D` | Exit Claude Code |
| `Esc` | Stop current response |
| `Esc` + `Esc` | Clear input draft, or open rewind menu |
| `Shift+Tab` | Cycle permission modes |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running task |
| `Ctrl+T` | Toggle task list |
| `Ctrl+L` | Redraw screen |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open in external editor |
| `Option+P` (macOS) / `Alt+P` | Switch model |
| `Option+T` (macOS) / `Alt+T` | Toggle extended thinking |
| `Option+O` (macOS) / `Alt+O` | Toggle fast mode |

#### Text Editing

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+A` / `Ctrl+E` | Move cursor to start/end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

#### Multiline Input

| Method | Shortcut |
|:-------|:---------|
| `\` + Enter | Works in all terminals |
| `Shift+Enter` | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| `Ctrl+J` | Works in any terminal |

For VS Code, Cursor, Windsurf, Alacritty, and Zed: run `/terminal-setup` once.

#### Quick Prefix Shortcuts

| Prefix | Action |
|:-------|:-------|
| `/` at start | Command or skill |
| `!` at start | Shell mode — run commands directly |
| `@` | File path autocomplete |

### Built-in Tools Reference

| Tool | Permission | Description |
|:-----|:-----------|:------------|
| `Agent` | No | Spawns a subagent with its own context window |
| `Bash` | Yes | Executes shell commands |
| `Edit` | Yes | Targeted string replacement in files |
| `Write` | Yes | Creates or overwrites files |
| `Read` | No | Reads file contents with line numbers |
| `Glob` | No | Finds files by name pattern |
| `Grep` | No | Searches file contents with regex (ripgrep) |
| `WebFetch` | Yes | Fetches a URL, converts HTML to Markdown |
| `WebSearch` | Yes | Runs a web search query |
| `Monitor` | Yes | Watches a background script, reacts to each output line |
| `NotebookEdit` | Yes | Modifies Jupyter notebook cells |
| `LSP` | No | Code intelligence (definitions, references, type errors) |
| `PowerShell` | Yes | Executes PowerShell commands natively |
| `Skill` | Yes | Executes a skill in the main conversation |
| `AskUserQuestion` | No | Asks multiple-choice questions |
| `TaskCreate`/`TaskUpdate`/`TaskList`/`TaskGet`/`TaskStop` | No | Task checklist management |
| `CronCreate`/`CronDelete`/`CronList` | No | Session-scoped scheduled tasks |
| `EnterPlanMode`/`ExitPlanMode` | No/Yes | Switch to/from plan mode |
| `EnterWorktree`/`ExitWorktree` | No | Create/exit isolated git worktrees |
| `PushNotification` | No | Sends desktop/phone notification |

#### Tool Permission Rule Format

| Rule | Applies to | Effect |
|:-----|:-----------|:-------|
| `Bash(npm run *)` | Bash, Monitor | Allow/deny matching commands |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP | Allow/deny by path |
| `Edit(/src/**)` | Edit, Write, NotebookEdit | Allow/deny by path |
| `WebFetch(domain:example.com)` | WebFetch | Allow/deny by domain |
| `Skill(deploy *)` | Skill | Allow/deny by skill name |
| `Agent(Explore)` | Agent | Allow/deny by subagent type |

#### Bash Tool Limits

| Limit | Default | Override |
|:------|:--------|:---------|
| Timeout | 2 minutes | `BASH_DEFAULT_TIMEOUT_MS` / `BASH_MAX_TIMEOUT_MS` |
| Max output length | 30,000 chars | `BASH_MAX_OUTPUT_LENGTH` (hard ceiling 150,000) |

### Keybindings

Keybindings file: `~/.claude/keybindings.json`. Run `/keybindings` to create or open it. Changes apply without restarting.

```json
{
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

**Key contexts:** `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `Scroll`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Settings`

**Key action examples:** `chat:submit`, `chat:newline`, `chat:cycleMode`, `chat:externalEditor`, `app:toggleTodos`, `app:toggleTranscript`, `history:search`

Set an action to `null` to unbind it. Reserved shortcuts that cannot be rebound: `Ctrl+C`, `Ctrl+D`, `Ctrl+M`.

**Keystroke syntax:** `ctrl+k`, `shift+tab`, `meta+p`, `ctrl+shift+c`, chord: `ctrl+k ctrl+s`

### Terminal Configuration

| Symptom | Solution |
|:--------|:---------|
| Shift+Enter submits (VS Code, Cursor, etc.) | Run `/terminal-setup` once |
| Option-key shortcuts do nothing on macOS | Enable Option as Meta in terminal settings |
| No sound when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` or use a Notification hook |
| Display flickers / scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Vim keys in prompt | Enable via `/config` → Editor mode |

**tmux configuration** (add to `~/.tmux.conf`):
```
set -g allow-passthrough on
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'
```

**Custom themes:** stored in `~/.claude/themes/<slug>.json`. Fields: `name`, `base` (`dark`, `light`, `dark-daltonized`, etc.), `overrides` (map of color token names to values). Select via `/theme`.

### Vim Editor Mode

Enable via `/config` → Editor mode. Key modes: INSERT, NORMAL, VISUAL.

NORMAL mode navigation: `h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`, `gg`/`G`, `f{char}`/`t{char}`.

NORMAL mode editing: `x` (delete char), `dd` (delete line), `cc` (change line), `yy` (yank), `p`/`P` (paste), `u` (undo), `.` (repeat).

Text objects (with `d`/`c`/`y`): `iw`/`aw`, `i"`/`a"`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`.

Enter submits in INSERT mode. Use `o`/`O` in NORMAL mode or `Ctrl+J` to insert a newline.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — All CLI commands and flags, system prompt flags
- [Commands](references/claude-code-commands.md) — Complete slash command reference, bundled skills and workflows
- [Interactive Mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, Vim editor mode, command history, background tasks, shell mode, prompt suggestions, `/btw` side questions, task list, session recap
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) — Keybindings file format, contexts, all available actions, keystroke syntax, unbinding, reserved shortcuts
- [Configure Your Terminal](references/claude-code-terminal-config.md) — Multiline input, Option key on macOS, terminal bell/notifications, tmux setup, custom themes, fullscreen rendering, Vim mode
- [Tools Reference](references/claude-code-tools-reference.md) — All built-in tools, permission rule syntax, per-tool behavior details (Bash, Edit, Glob, Grep, LSP, Monitor, NotebookEdit, PowerShell, Read, WebFetch, WebSearch, Write)

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure Your Terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
