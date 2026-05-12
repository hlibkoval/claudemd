---
name: cli-doc
description: Complete official documentation for the Claude Code CLI — commands, flags, interactive mode shortcuts, vim editing, keyboard shortcut customization, terminal configuration, and built-in tools reference.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, keybindings, terminal configuration, and tools reference.

## Quick Reference

### Core CLI Commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Non-interactive (print) mode, then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall native binary (stable, latest, or version) |
| `claude auth login` | Sign in (use `--console` for API billing) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON |
| `claude agents` | Open agent view / list subagents when piped |
| `claude attach <id>` | Attach to a background session |
| `claude logs <id>` | Print recent output from background session |
| `claude stop <id>` | Stop a background session |
| `claude respawn <id>` | Restart stopped background session |
| `claude rm <id>` | Remove background session from list |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete local Claude Code state for a project |
| `claude remote-control` | Start Remote Control server |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `claude ultrareview [target]` | Run ultrareview non-interactively |
| `claude auto-mode defaults` | Print auto mode classifier rules as JSON |

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `-p`, `--print` | Non-interactive mode |
| `-c`, `--continue` | Load most recent conversation |
| `-r`, `--resume` | Resume session by ID or name |
| `-n`, `--name` | Set display name for session |
| `-w`, `--worktree` | Start in isolated git worktree |
| `--bg` | Start as background agent |
| `--model` | Set model (alias or full name) |
| `--permission-mode` | Start in mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--allowedTools` | Tools that run without permission prompts |
| `--disallowedTools` | Tools removed from model context |
| `--tools` | Restrict available built-in tools |
| `--add-dir` | Add additional working directories |
| `--output-format` | `text`, `json`, `stream-json` (print mode) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Max spend on API calls (print mode) |
| `--effort` | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--system-prompt-file` | Replace prompt from file |
| `--append-system-prompt-file` | Append from file |
| `--mcp-config` | Load MCP servers from JSON |
| `--plugin-dir` | Load plugin from directory or .zip |
| `--debug` | Enable debug mode |
| `--verbose` | Enable verbose logging |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--from-pr` | Resume sessions linked to a PR |
| `--remote` | Create new web session on claude.ai |
| `--teleport` | Resume a web session in local terminal |
| `--json-schema` | Validated JSON output via schema (print mode) |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves caching) |

### System Prompt Flags

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag. Prefer append flags to preserve built-in capabilities.

---

### In-Session Commands (Slash Commands)

Type `/` to see all available commands. Selected highlights:

| Command | Purpose |
| :--- | :--- |
| `/add-dir <path>` | Add working directory for this session |
| `/agents` | Manage subagent configurations |
| `/background [prompt]` | Detach session to run as background agent |
| `/batch <instruction>` | Orchestrate large-scale parallel changes |
| `/branch [name]` | Create a branch of the current conversation |
| `/btw <question>` | Ask a side question without adding to history |
| `/clear [name]` | Start new conversation; keep previous in `/resume` |
| `/compact [instructions]` | Summarize conversation to free context |
| `/config` | Open settings interface |
| `/context [all]` | Visualize context usage |
| `/copy [N]` | Copy last assistant response to clipboard |
| `/debug` | Enable debug logging for this session |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose and verify Claude Code installation |
| `/effort [level\|auto]` | Set model effort level |
| `/feedback` | Submit feedback about Claude Code |
| `/goal [condition\|clear]` | Set persistent goal across turns |
| `/help` | Show help and available commands |
| `/hooks` | View hook configurations |
| `/init` | Initialize project with a CLAUDE.md |
| `/keybindings` | Open/create keybindings config file |
| `/memory` | Edit CLAUDE.md files and manage auto-memory |
| `/mcp` | Manage MCP server connections |
| `/model [model]` | Select or change AI model |
| `/permissions` | Manage allow/ask/deny rules |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/recap` | Generate one-line session summary |
| `/remote-control` | Make session available for remote control |
| `/rename [name]` | Rename current session |
| `/resume [session]` | Resume conversation by ID or name |
| `/review [PR]` | Review a pull request |
| `/rewind` | Rewind conversation/code to previous point |
| `/schedule` | Create/manage routines on cloud infrastructure |
| `/security-review` | Analyze pending changes for security issues |
| `/simplify [focus]` | Review recently changed files for quality |
| `/skills` | List available skills |
| `/status` | Open Settings (Status tab) |
| `/tasks` | List and manage background tasks |
| `/teleport` | Pull a web session into terminal |
| `/theme` | Change color theme |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/ultrareview [PR]` | Deep multi-agent cloud code review |
| `/usage` | Show session cost and plan usage |

Bundled skills (marked `[Skill]`): `/batch`, `/debug`, `/fewer-permission-prompts`, `/loop`, `/simplify`, `/claude-api`

---

### Interactive Mode Keyboard Shortcuts

#### General Controls

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit Claude Code session |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open in external text editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` / `Cmd+V` / `Alt+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks |
| `Ctrl+T` | Toggle task list |
| `Esc` | Interrupt Claude (stop current response) |
| `Esc` + `Esc` | Rewind or summarize |
| `Shift+Tab` | Cycle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |

#### Text Editing

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+A` | Move cursor to start of line |
| `Ctrl+E` | Move cursor to end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` | Move cursor back one word |
| `Alt+F` | Move cursor forward one word |

#### Multiline Input Methods

| Method | Shortcut |
| :--- | :--- |
| Quick escape | `\` + `Enter` (all terminals) |
| Control sequence | `Ctrl+J` (any terminal) |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| Shift+Enter (setup needed) | VS Code, Cursor, Windsurf, Alacritty, Zed: run `/terminal-setup` once |

#### Quick Input Prefixes

| Prefix | Behavior |
| :--- | :--- |
| `/` | Command or skill menu |
| `!` | Shell mode — run command directly |
| `@` | File path autocomplete |

---

### Vim Editor Mode

Enable via `/config` → Editor mode, or set `editorMode: "vim"` in settings.

#### Mode Switching

| Command | Action | From Mode |
| :--- | :--- | :--- |
| `Esc` | Enter NORMAL mode | INSERT, VISUAL |
| `i` / `a` / `A` | Insert before/after cursor / end of line | NORMAL |
| `I` | Insert at beginning of line | NORMAL |
| `o` / `O` | Open line below/above | NORMAL |
| `v` / `V` | Character-wise / line-wise visual selection | NORMAL |

#### Key Navigation & Editing (NORMAL mode)

| Command | Action |
| :--- | :--- |
| `h`/`j`/`k`/`l` | Move left/down/up/right |
| `w`/`e`/`b` | Next word / end of word / previous word |
| `0` / `$` | Beginning / end of line |
| `gg` / `G` | Beginning / end of input |
| `f{char}` / `F{char}` | Jump to next/prev occurrence of char |
| `dd` / `D` | Delete line / to end of line |
| `cc` / `C` | Change line / to end of line |
| `yy` / `p` / `P` | Yank line / paste after / paste before |
| `u` | Undo |
| `.` | Repeat last change |
| `iw`/`aw`, `i"`/`a"`, `i(`/`a(` | Text objects (inner/around) |

---

### Keybindings Customization

Config file: `~/.claude/keybindings.json` (open with `/keybindings`). Changes apply without restart.

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

#### Available Contexts

`Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Scroll`, `Doctor`

#### Key Action Reference

| Context | Action | Default |
| :--- | :--- | :--- |
| Global | `app:interrupt` | Ctrl+C |
| Global | `app:exit` | Ctrl+D |
| Global | `app:toggleTodos` | Ctrl+T |
| Global | `app:toggleTranscript` | Ctrl+O |
| Chat | `chat:submit` | Enter |
| Chat | `chat:newline` | Ctrl+J |
| Chat | `chat:cycleMode` | Shift+Tab |
| Chat | `chat:externalEditor` | Ctrl+G |
| Chat | `chat:modelPicker` | Meta+P |
| Chat | `chat:thinkingToggle` | Meta+T |
| Chat | `chat:fastMode` | Meta+O |
| Chat | `chat:imagePaste` | Ctrl+V |
| Transcript | `transcript:toggleShowAll` | Ctrl+E |
| Transcript | `transcript:exit` | q, Ctrl+C, Esc |

Set an action to `null` to unbind it. Reserved shortcuts (cannot rebind): `Ctrl+C`, `Ctrl+D`, `Ctrl+M`.

#### Keystroke Syntax

- Modifiers: `ctrl`, `shift`, `alt`/`meta`, `cmd`/`super`
- Chords: `ctrl+k ctrl+s` (space-separated sequence)
- Special: `escape`, `enter`, `tab`, `space`, `up`, `down`, `left`, `right`, `backspace`, `delete`
- Uppercase letter implies Shift: `K` = `shift+k`

---

### Terminal Configuration

| Issue | Fix |
| :--- | :--- |
| Shift+Enter submits instead of newline (VS Code, Zed, etc.) | Run `/terminal-setup` once |
| Option-key shortcuts do nothing on macOS | Enable "Use Option as Meta Key" in terminal settings |
| No notification when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` in settings, or use a Notification hook |
| Display flickers / scrollback jumps | Switch to fullscreen: `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Running inside tmux | Add `set -g allow-passthrough on`, `set -s extended-keys on`, `set -as terminal-features 'xterm*:extkeys'` to `~/.tmux.conf` |

**Custom themes**: JSON files in `~/.claude/themes/`. Fields: `name` (string), `base` (preset), `overrides` (color token map). Color values accept `#rrggbb`, `rgb(r,g,b)`, `ansi256(n)`, or `ansi:<name>`.

---

### Built-in Tools Reference

| Tool | Description | Permission |
| :--- | :--- | :--- |
| `Agent` | Spawns a subagent in a separate context window | No |
| `AskUserQuestion` | Asks multiple-choice questions | No |
| `Bash` | Executes shell commands | Yes |
| `CronCreate` / `CronDelete` / `CronList` | Schedule/manage session-scoped tasks | No |
| `Edit` | Makes targeted exact-string-replacement edits | Yes |
| `EnterPlanMode` / `ExitPlanMode` | Switch to/from plan mode | No / Yes |
| `Glob` | Finds files by name pattern | No |
| `Grep` | Searches file contents (ripgrep-powered) | No |
| `LSP` | Code intelligence via language servers | No |
| `Monitor` | Watch a background command, react to output | Yes |
| `NotebookEdit` | Modifies Jupyter notebook cells | Yes |
| `PowerShell` | Executes PowerShell commands natively | Yes |
| `Read` | Reads file contents with line numbers | No |
| `Skill` | Executes a skill within the main conversation | Yes |
| `WebFetch` | Fetches URL content, converts to Markdown | Yes |
| `WebSearch` | Runs web searches via Anthropic backend | Yes |
| `Write` | Creates or overwrites files | Yes |
| `TodoWrite` | Manages session task checklist (non-interactive) | No |
| `Monitor` | Watch a background command, react to output (v2.1.98+) | Yes |

#### Permission Rule Syntax for Tools

| Rule Format | Applies To |
| :--- | :--- |
| `Bash(npm run *)` | Bash, Monitor — command pattern |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP — path pattern |
| `Edit(/src/**)` | Edit, Write, NotebookEdit — path pattern |
| `Skill(deploy *)` | Skill — skill name matching |
| `Agent(Explore)` | Agent — subagent type matching |
| `WebFetch(domain:example.com)` | WebFetch — domain matching |
| `WebSearch` | WebSearch — no specifier |

#### Key Tool Behaviors

**Bash**: `cd` persists within project/additional dirs; env vars don't persist across commands. Default timeout: 2 min (up to 10 min). Output capped at 30,000 chars (raise with `BASH_MAX_OUTPUT_LENGTH`).

**Edit**: Requires read-before-edit; `old_string` must be unique and exact. `cat path` and `sed -n 'X,Yp' path` also satisfy read requirement.

**Glob**: Sorted by modification time, capped at 100 files. Does NOT respect `.gitignore` by default (set `CLAUDE_CODE_GLOB_NO_IGNORE=false` to change).

**Grep**: Respects `.gitignore`. Uses ripgrep regex. Output modes: `files_with_matches` (default), `content`, `count`.

**WebFetch**: Converts HTML to Markdown via a fast model. Results cached 15 min. Redirects to different hosts return the target URL rather than following automatically. First call to a new domain prompts for permission.

**WebSearch**: Runs query, returns titles/URLs (does not fetch pages). Scope with `allowed_domains` or `blocked_domains`.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — all commands, flags, and system prompt flag details
- [Commands](references/claude-code-commands.md) — complete list of in-session slash commands and bundled skills
- [Interactive Mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, vim mode, command history, shell mode, task list, session recap
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) — keybindings config file, contexts, actions, keystroke syntax, reserved shortcuts
- [Configure Your Terminal](references/claude-code-terminal-config.md) — Shift+Enter setup, Option key, notifications, tmux, fullscreen, themes, vim mode
- [Tools Reference](references/claude-code-tools-reference.md) — complete tool list, permission rule syntax, per-tool behavior details

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure Your Terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
