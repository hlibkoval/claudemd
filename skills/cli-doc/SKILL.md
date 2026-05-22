---
name: cli-doc
description: Complete official documentation for the Claude Code CLI — launch commands, all CLI flags, in-session slash commands, keyboard shortcuts, Vim editor mode, interactive features (/btw, task list, session recap, PR status), keybindings configuration (contexts, actions, keystroke syntax, chord bindings), terminal configuration (Shift+Enter, Option key, tmux, fullscreen rendering, custom themes), and the full built-in tools reference (Agent, Bash, Edit, Glob, Grep, LSP, Monitor, NotebookEdit, Read, WebFetch, WebSearch, Write, and more).
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code CLI, interactive mode, keybindings, terminal configuration, and built-in tools.

## Quick Reference

### CLI Launch Commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive, then exit) |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude --bg "query"` | Start as background agent, return immediately |
| `claude agents` | Open agent view for parallel background sessions |
| `claude attach <id>` | Attach to a background session |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (use `--console` for API key billing) |
| `claude auth status` | Show auth status (`--text` for human-readable) |
| `claude setup-token` | Generate long-lived OAuth token for CI/scripts |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude remote-control` | Start Remote Control server |

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `--print`, `-p` | Non-interactive print mode |
| `--continue`, `-c` | Load most recent conversation |
| `--resume`, `-r` | Resume session by ID or name |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, or `bypassPermissions` |
| `--dangerously-skip-permissions` | Skip all permission prompts (alias: `--permission-mode bypassPermissions`) |
| `--add-dir` | Add additional working directories |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--output-format` | Print mode output: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Max API spend before stopping (print mode only) |
| `--tools` | Restrict built-in tools (`""` disables all, `"default"` allows all) |
| `--allowedTools` | Tools that execute without prompting |
| `--disallowedTools` | Deny rules for tools |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append text to default system prompt |
| `--mcp-config` | Load MCP servers from JSON file |
| `--plugin-dir` | Load plugin from directory or `.zip` archive |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--name`, `-n` | Set a display name for the session |
| `--fork-session` | Create new session ID when resuming |
| `--no-session-persistence` | Do not save session to disk (print mode only) |
| `--debug` | Enable debug mode (optional category filter) |
| `--debug-file <path>` | Write debug logs to a file |
| `--version`, `-v` | Output version number |

### System Prompt Flags

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can be combined with either.

### In-Session Commands (Slash Commands)

Type `/` at the start of a message to access commands. Key commands:

| Command | Purpose |
| :--- | :--- |
| `/clear [name]` | New conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Summarize context to free space |
| `/context [all]` | Visualize context window usage |
| `/plan [description]` | Enter plan mode |
| `/model [model]` | Switch model for current session |
| `/effort [level\|auto]` | Adjust effort level interactively |
| `/permissions` | Manage allow/ask/deny rules (alias: `/allowed-tools`) |
| `/memory` | Edit CLAUDE.md files and auto-memory |
| `/resume [session]` | Resume a past conversation (alias: `/continue`) |
| `/branch [name]` | Fork the current conversation (alias: `/fork`) |
| `/rewind` | Roll back code and conversation (alias: `/checkpoint`, `/undo`) |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/btw <question>` | Side question without adding to history |
| `/background [prompt]` | Detach session to run as background agent (alias: `/bg`) |
| `/tasks` | List and manage background tasks (alias: `/bashes`) |
| `/agents` | Manage agent configurations |
| `/batch <instruction>` | Orchestrate large-scale parallel codebase changes |
| `/goal [condition\|clear]` | Set a persistent goal Claude works toward |
| `/init` | Initialize project with CLAUDE.md |
| `/hooks` | View configured hooks |
| `/mcp` | Manage MCP server connections |
| `/plugin` | Manage plugins |
| `/skills` | List available skills |
| `/code-review [effort] [--comment] [target]` | Review diff for correctness bugs |
| `/security-review` | Analyze pending changes for security vulnerabilities |
| `/review [PR]` | Review a pull request locally |
| `/ultrareview [PR]` | Deep multi-agent cloud-based code review |
| `/ultraplan <prompt>` | Draft a plan, review in browser, then execute |
| `/config` | Open settings interface (alias: `/settings`) |
| `/status` | Show version, model, account, connectivity |
| `/usage` | Session cost, plan limits, activity stats (aliases: `/cost`, `/stats`) |
| `/doctor` | Diagnose installation and settings |
| `/debug [description]` | Enable debug logging mid-session |
| `/export [filename]` | Export conversation as plain text |
| `/copy [N]` | Copy last (or Nth-latest) assistant response |
| `/rename [name]` | Rename current session |
| `/theme` | Change color theme |
| `/keybindings` | Open or create keybindings config file |
| `/terminal-setup` | Configure terminal keybindings (Shift+Enter, etc.) |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/help` | Show help and available commands |
| `/exit` | Exit the CLI (alias: `/quit`) |

Commands marked **[Skill]** in the full reference are bundled skills (prompt-based, not hardcoded). MCP prompts appear as `/mcp__<server>__<prompt>`.

### Keyboard Shortcuts — General Controls

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Interrupt or clear input |
| `Ctrl+D` | Exit session |
| `Esc` | Interrupt Claude (keeps work done so far) |
| `Esc` + `Esc` | Clear input draft, or open rewind menu when input is empty |
| `Shift+Tab` | Cycle permission modes (`default` → `acceptEdits` → `plan` → ...) |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+L` | Redraw screen |
| `Ctrl+B` | Background running task (tmux users press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open prompt in external editor |
| `Ctrl+V` / `Alt+V` (Windows) | Paste image from clipboard |
| `Option+P` / `Alt+P` | Switch model without clearing prompt |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |

### Keyboard Shortcuts — Text Editing

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+A` | Move to start of line |
| `Ctrl+E` | Move to end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` | Move cursor back one word |
| `Alt+F` | Move cursor forward one word |

### Multiline Input Methods

| Method | Shortcut |
| :--- | :--- |
| Quick escape | `\` then `Enter` (all terminals) |
| Control sequence | `Ctrl+J` (all terminals) |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| Option+Enter | After enabling Option as Meta on macOS |
| VS Code/Cursor/Alacritty/Zed | Run `/terminal-setup` once |

### Vim Editor Mode

Enable via `/config` → Editor mode or set `editorMode: "vim"` in settings.

**Mode switching:**

| Key | Action |
| :--- | :--- |
| `Esc` | Enter NORMAL mode |
| `i` / `I` | Insert before cursor / at line start |
| `a` / `A` | Insert after cursor / at line end |
| `v` / `V` | Character-wise / line-wise visual selection |

**Navigation (NORMAL):** `h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f{char}`/`F{char}`

**Editing (NORMAL):** `x`, `dd`/`D`, `cc`/`C`, `yy`/`Y`, `p`/`P`, `u` (undo), `.` (repeat), `>>` / `<<`

**Text objects:** `iw`/`aw`, `i"`/`a"`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`

### Keybindings Configuration

Config file: `~/.claude/keybindings.json` (run `/keybindings` to open/create). Changes auto-apply without restart.

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

Set an action to `null` to unbind it.

**Key contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Select`, `Plugin`, `Scroll`, `Doctor`, `Tabs`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Attachments`

**Key app/chat actions:**

| Action | Default |
| :--- | :--- |
| `app:interrupt` | Ctrl+C |
| `app:exit` | Ctrl+D |
| `app:toggleTodos` | Ctrl+T |
| `app:toggleTranscript` | Ctrl+O |
| `chat:submit` | Enter |
| `chat:newline` | Ctrl+J |
| `chat:cancel` | Escape |
| `chat:cycleMode` | Shift+Tab |
| `chat:externalEditor` | Ctrl+G, Ctrl+X Ctrl+E |
| `chat:modelPicker` | Meta+P |
| `chat:fastMode` | Meta+O |
| `chat:thinkingToggle` | Meta+T |
| `chat:imagePaste` | Ctrl+V |
| `transcript:exit` | q, Ctrl+C, Escape |
| `history:search` | Ctrl+R |

**Keystroke syntax:** `ctrl`, `shift`, `alt`/`meta`/`opt`, `cmd`/`super`. Chords are space-separated sequences (e.g. `ctrl+k ctrl+s`). Uppercase letter implies Shift (`K` = `shift+k`). Special keys: `escape`, `enter`, `tab`, `space`, arrow keys.

**Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, Caps Lock.

**Terminal conflicts:** `Ctrl+B` (tmux prefix — press twice), `Ctrl+A` (GNU screen), `Ctrl+Z` (SIGTSTP).

### Terminal Configuration

**Shift+Enter support:**

| Terminal | Shift+Enter status |
| :--- | :--- |
| Ghostty, Kitty, iTerm2, WezTerm, Warp, Apple Terminal, Windows Terminal | Works without setup |
| VS Code, Cursor, Windsurf, Alacritty, Zed | Run `/terminal-setup` once |
| gnome-terminal, JetBrains IDEs | Not available; use `Ctrl+J` or `\` + Enter |

**tmux configuration** (`~/.tmux.conf`):
```
set -g allow-passthrough on
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'
```

**Option key on macOS:** Enable "Use Option as Meta Key" in terminal settings (iTerm2: Settings → Profiles → Keys → set Left/Right Option to "Esc+"; Apple Terminal: Settings → Profiles → Keyboard → check option; VS Code: add `"terminal.integrated.macOptionIsMeta": true`).

**Fullscreen rendering:** Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` before launching. Fixes flickering and adds mouse scroll support.

**Custom themes:** Defined in `~/.claude/themes/<name>.json`. Fields: `name` (string), `base` (dark/light/dark-daltonized/light-daltonized/dark-ansi/light-ansi), `overrides` (color token map). Color values: `#rrggbb`, `rgb(r,g,b)`, `ansi256(n)`, `ansi:<name>`. Key tokens: `claude` (brand accent), `text`, `error`, `success`, `warning`, `promptBorder`, `planMode`, `diffAdded`, `diffRemoved`.

### Built-in Tools Reference

| Tool | Description | Permission Required |
| :--- | :--- | :--- |
| `Agent` | Spawns a subagent with separate context window | No |
| `AskUserQuestion` | Asks multiple-choice questions | No |
| `Bash` | Executes shell commands | Yes |
| `Edit` | Makes targeted edits to files (exact string replacement) | Yes |
| `EnterPlanMode` / `ExitPlanMode` | Switch to/from plan mode | No / Yes |
| `Glob` | Finds files by name pattern | No |
| `Grep` | Searches file contents (ripgrep, not POSIX) | No |
| `LSP` | Code intelligence (requires code intelligence plugin) | No |
| `Monitor` | Runs background command and feeds output lines to Claude | Yes |
| `NotebookEdit` | Modifies Jupyter notebook cells by `cell_id` | Yes |
| `PowerShell` | Executes PowerShell commands (Windows-primary) | Yes |
| `PushNotification` | Sends desktop/phone push notification | No |
| `Read` | Reads files with line numbers (also PDFs, images, notebooks) | No |
| `Skill` | Executes a skill within the main conversation | Yes |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | Manage session task list | No |
| `WebFetch` | Fetches URL, converts HTML to Markdown, extracts via prompt | Yes |
| `WebSearch` | Searches via Anthropic's backend, returns titles/URLs | Yes |
| `Write` | Creates or overwrites files (must have read existing file first) | Yes |

**Bash tool notes:**
- `cd` persists within project/additional directories; resets if outside bounds
- Environment variables do NOT persist across commands
- Default timeout: 2 min (up to 10 min with `timeout` param)
- Output cap: 30,000 chars by default; excess saved to file
- Long-running processes: use `run_in_background: true`

**Edit tool notes:**
- Exact string replacement (no regex or fuzzy matching)
- Must have read the file in current conversation before editing
- `old_string` must appear exactly once (or use `replace_all: true`)

**Permission rule format:** `ToolName(specifier)` — e.g. `Bash(npm run *)`, `Read(~/secrets/**)`, `Edit(/src/**)`, `WebFetch(domain:example.com)`, `Skill(deploy *)`, `Agent(Explore)`

**Tool availability:** Depends on provider, platform, and settings. Ask Claude "What tools do you have access to?" or run `/mcp` for MCP tool names.

### Interactive Features

**Shell mode:** Prefix your input with `!` to run shell commands directly without Claude interpreting them. Output is added to conversation context. Supports Tab autocomplete from previous `!` commands. Exit with Escape, Backspace, or `Ctrl+U` on an empty prompt.

**Side questions with /btw:** Ask a quick question without adding to conversation history. Available while Claude is working. No tool access. Single response only (no back-and-forth). Low cost (reuses prompt cache).

**Task list:** Appears in terminal status area for complex multi-step work. `Ctrl+T` to toggle. Share across sessions with `CLAUDE_CODE_TASK_LIST_ID=<name>`.

**Session recap:** One-line recap shown when returning after 3+ minutes away and session has 3+ turns. Run `/recap` on demand. Disable in `/config`.

**Prompt suggestions:** Grayed-out example command appears in prompt; press Tab or Right arrow to accept. Disable with `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false`.

**PR review status:** Colored underline on PR link in footer (green=approved, yellow=pending, red=changes requested, gray=draft). Requires `gh` CLI.

**Reverse history search (Ctrl+R):** Type to search, `Ctrl+R` for older matches, `Ctrl+S` to cycle scope (session/project/all), Tab/Esc to accept, Enter to execute, `Ctrl+C` to cancel.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — all launch commands and flags, system prompt flags, pipe/redirect usage
- [Commands](references/claude-code-commands.md) — complete in-session slash command reference, built-in vs. skill commands, MCP prompts
- [Interactive mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, Vim editor mode, command history, shell mode, background tasks, /btw, task list, session recap, PR status
- [Keybindings](references/claude-code-keybindings.md) — keybindings config file format, all contexts, all actions with defaults, keystroke syntax, chord bindings, unbinding, reserved shortcuts, vim mode interaction
- [Terminal configuration](references/claude-code-terminal-config.md) — Shift+Enter setup, Option key on macOS, terminal bell/notifications, tmux config, fullscreen rendering, custom themes, Vim mode setup
- [Tools reference](references/claude-code-tools-reference.md) — complete tool list with permission requirements, per-tool behavior (Bash, Edit, Glob, Grep, LSP, Monitor, NotebookEdit, PowerShell, Read, WebFetch, WebSearch, Write), permission rule syntax

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
