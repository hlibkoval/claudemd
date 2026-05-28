---
name: cli-doc
user-invocable: false
---

# CLI & Interactive Mode Documentation

This skill provides the complete official documentation for the Claude Code CLI, built-in commands, interactive mode, keyboard shortcuts, keybindings configuration, terminal setup, and tools reference.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode (query then exit) |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude --bg "task"` | Start as background agent |
| `claude agents` | Open agent view / monitor background sessions |
| `claude attach <id>` | Attach to a background session |
| `claude stop <id>` | Stop a background session |
| `claude logs <id>` | Print output from a background session |
| `claude rm <id>` | Remove a background session from the list |
| `claude respawn <id>` | Restart a background session with conversation intact |
| `claude auth login` | Sign in (use `--console` for API billing) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON |
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall a specific version |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local state for a project |
| `claude setup-token` | Generate a long-lived OAuth token for CI |
| `claude daemon status` | Show supervisor state and diagnostics |
| `claude auto-mode defaults` | Print auto-mode classifier rules as JSON |
| `claude remote-control` | Start a Remote Control server |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `-p`, `--print` | Print mode: query then exit |
| `-c`, `--continue` | Resume most recent conversation |
| `-r`, `--resume` | Resume session by ID or name |
| `-n`, `--name` | Set a display name for the session |
| `--model` | Set model (e.g. `claude-sonnet-4-6`, `sonnet`, `opus`) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in a permission mode: `default`, `acceptEdits`, `plan`, `auto`, `bypassPermissions` |
| `--dangerously-skip-permissions` | Skip permission prompts (bypassPermissions mode) |
| `--add-dir` | Add additional working directories |
| `--tools` | Restrict which built-in tools are available |
| `--allowedTools` | Tools that run without permission prompts |
| `--disallowedTools` | Deny rules for tools |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append file contents to default system prompt |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Spending cap in dollars (print mode only) |
| `--mcp-config` | Load MCP servers from JSON files |
| `--plugin-dir` | Load a plugin from a directory or zip for this session |
| `--settings` | Path to settings JSON or inline JSON string |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--bg` | Start as a background agent |
| `--worktree`, `-w` | Start in an isolated git worktree |
| `--verbose` | Show full turn-by-turn output |
| `--debug` | Enable debug mode with optional category filtering |
| `--debug-file <path>` | Write debug logs to a file |
| `--version`, `-v` | Show version number |
| `--init-only` | Run Setup and SessionStart hooks then exit |
| `--from-pr` | Resume sessions linked to a pull request |
| `--fork-session` | Create new session ID when resuming |
| `--remote` | Create a web session on claude.ai |
| `--teleport` | Resume a web session in local terminal |
| `--json-schema` | Validate output against JSON Schema (print mode) |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves prompt cache reuse) |
| `--fallback-model` | Fallback model when primary is unavailable (print mode / background) |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag. Use append flags when Claude should remain a coding assistant with extra rules; use replacement when the identity or permission model differs entirely.

### Commands (in-session)

Type `/` to list all commands or filter by typing letters. Commands only activate at the start of a message.

**Context & conversation:**

| Command | Purpose |
|:--------|:--------|
| `/clear [name]` | Start fresh conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Summarize conversation to free context |
| `/context [all]` | Visualize context usage |
| `/btw <question>` | Side question that doesn't enter conversation history |
| `/rewind` | Roll back code and conversation to a checkpoint (aliases: `/checkpoint`, `/undo`) |
| `/branch [name]` | Fork conversation at this point (alias: `/fork`) |
| `/resume [session]` | Resume a conversation (alias: `/continue`) |
| `/export [filename]` | Export conversation as plain text |
| `/copy [N]` | Copy last (or Nth) assistant response to clipboard |
| `/recap` | Generate one-line session summary |

**Models & mode:**

| Command | Purpose |
|:--------|:--------|
| `/model [model]` | Set AI model for this session |
| `/effort [level\|auto]` | Set effort level (interactive slider without arg) |
| `/plan [description]` | Enter plan mode |
| `/fast [on\|off]` | Toggle fast mode |
| `/permission-mode` | — use `Shift+Tab` to cycle modes interactively |

**Parallel work:**

| Command | Purpose |
|:--------|:--------|
| `/agents` | Manage subagent configurations |
| `/tasks` | List/manage background tasks (alias: `/bashes`) |
| `/background [prompt]` | Detach session to run as background agent (alias: `/bg`) |
| `/batch <instruction>` | **[Skill]** Parallel large-scale changes across codebase |
| `/goal [condition\|clear]` | Set a goal Claude works toward autonomously |

**Review & quality:**

| Command | Purpose |
|:--------|:--------|
| `/diff` | Interactive diff viewer (current and per-turn diffs) |
| `/code-review [level] [--fix] [--comment] [target]` | **[Skill]** Review diff; `ultra` for cloud review |
| `/review [PR]` | Review a pull request locally |
| `/security-review` | Analyze branch changes for security vulnerabilities |

**Configuration:**

| Command | Purpose |
|:--------|:--------|
| `/config` | Open Settings (alias: `/settings`) |
| `/permissions` | Manage allow/ask/deny tool permission rules |
| `/memory` | Edit CLAUDE.md files and manage auto-memory |
| `/hooks` | View hook configurations |
| `/mcp` | Manage MCP server connections |
| `/keybindings` | Open/create keybindings config file |
| `/theme` | Change color theme |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/statusline` | Configure the status line |

**Session management:**

| Command | Purpose |
|:--------|:--------|
| `/rename [name]` | Rename session and show on prompt bar |
| `/add-dir <path>` | Add working directory for file access this session |
| `/reload-skills` | Re-scan skills/commands without restarting |
| `/reload-plugins` | Reload all active plugins without restarting |
| `/remote-control` | Make session available for Remote Control (alias: `/rc`) |
| `/teleport` | Pull a web session into this terminal (alias: `/tp`) |

**Bundled skills (invoked as commands):**

| Command | Purpose |
|:--------|:--------|
| `/batch <instruction>` | Parallel large-scale codebase changes in worktrees |
| `/debug [description]` | Enable debug logging and analyze the session log |
| `/fewer-permission-prompts` | Build a permission allowlist from transcript history |
| `/loop [interval] [prompt]` | Run a prompt repeatedly on a schedule |
| `/run` | Launch app and observe a change working |
| `/verify` | Confirm a code change works by running the app |
| `/run-skill-generator` | Teach `/run`/`/verify` how to build your app |
| `/code-review [options]` | Review diff; apply with `--fix`, post comments with `--comment` |

### Interactive Mode Keyboard Shortcuts

**General controls:**

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Interrupt or clear input |
| `Ctrl+D` | Exit session |
| `Esc` | Interrupt Claude (stop current response) |
| `Esc` + `Esc` | Clear input draft or open rewind menu |
| `Shift+Tab` | Cycle permission modes |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse history search |
| `Ctrl+L` | Redraw screen |
| `Ctrl+B` | Background running task |
| `Ctrl+T` | Toggle task list |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open in external editor |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |
| `Ctrl+V` / `Alt+V` | Paste image from clipboard |

**Text editing:**

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+A` / `Ctrl+E` | Move cursor to start/end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

**Multiline input:**

| Method | Shortcut |
|:-------|:---------|
| Works everywhere | `\` + `Enter` or `Ctrl+J` |
| Most terminals natively | `Shift+Enter` |
| With Option as Meta | `Option+Enter` |

**Quick input prefixes:**

| Prefix | Action |
|:-------|:-------|
| `/` at start | Command or skill |
| `!` at start | Shell mode (run directly, adds output to context) |
| `@` | File path autocomplete |

### Keybindings Configuration

Config file: `~/.claude/keybindings.json` (run `/keybindings` to open or create it). Changes are auto-detected without restarting.

**File structure:**

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

**Contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Scroll`, `Doctor`

**Key action groups:**

| Namespace | Key actions (examples) |
|:----------|:----------------------|
| `app:` | `interrupt`, `exit`, `redraw`, `toggleTodos`, `toggleTranscript` |
| `chat:` | `submit`, `cancel`, `newline`, `cycleMode`, `externalEditor`, `modelPicker`, `fastMode`, `thinkingToggle`, `imagePaste`, `stash`, `killAgents` |
| `history:` | `search`, `previous`, `next` |
| `autocomplete:` | `accept`, `dismiss`, `previous`, `next` |
| `transcript:` | `toggleShowAll`, `exit` |
| `scroll:` | `lineUp`, `lineDown`, `pageUp`, `pageDown`, `top`, `bottom`, `fullPageUp`, `fullPageDown` |
| `selection:` | `copy`, `clear`, `extendLeft`, `extendRight`, `extendUp`, `extendDown` |
| `diff:` | `dismiss`, `previousSource`, `nextSource`, `previousFile`, `nextFile`, `viewDetails` |

**Keystroke syntax:** `ctrl+k`, `shift+tab`, `meta+p`, `ctrl+shift+c`. Chords: `ctrl+k ctrl+s`. Uppercase implies Shift for vim-style bindings. Set to `null` to unbind.

**Reserved (cannot be rebound):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, `Caps Lock`

**Terminal conflicts:** `Ctrl+B` (tmux prefix — press twice), `Ctrl+A` (GNU screen), `Ctrl+Z` (SIGTSTP)

### Vim Editor Mode

Enable via `/config` → Editor mode or set `editorMode: "vim"` in settings. Enter still submits in INSERT mode; use `o`/`O` or `Ctrl+J` for a newline.

**Mode switching:** `Esc` → NORMAL, `i`/`I`/`a`/`A`/`o`/`O` → INSERT, `v`/`V` → VISUAL

**NORMAL mode navigation:** `hjkl`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f{char}`/`F{char}`

**NORMAL mode editing:** `x` (delete char), `dd` (delete line), `cc` (change line), `yy` (yank), `p`/`P` (paste), `u` (undo), `.` (repeat)

**Text objects (with `d`, `c`, `y`):** `iw`/`aw`, `i"`/`a"`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`

### Terminal Configuration

**Shift+Enter for newlines:**

| Terminal | Setup needed |
|:---------|:-------------|
| Ghostty, Kitty, iTerm2, WezTerm, Warp, Apple Terminal, Windows Terminal | None |
| VS Code, Cursor, Windsurf, Alacritty, Zed | Run `/terminal-setup` once |
| gnome-terminal, JetBrains IDEs | Not available; use `Ctrl+J` or `\` + Enter |

**Option key on macOS:** Enable "Option as Meta" in your terminal (iTerm2: Settings → Profiles → Keys → Esc+; Apple Terminal: Settings → Profiles → Keyboard → "Use Option as Meta Key"; VS Code: `"terminal.integrated.macOptionIsMeta": true`).

**tmux configuration** (add to `~/.tmux.conf`):
```
set -g allow-passthrough on
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'
```

**Fullscreen rendering:** Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` to fix flicker/scroll issues and enable mouse support.

**Custom themes:** JSON files in `~/.claude/themes/`. Fields: `name`, `base` (dark/light/dark-daltonized/light-daltonized/dark-ansi/light-ansi), `overrides` (color token map). Key tokens: `claude`, `text`, `error`, `success`, `warning`, `promptBorder`, `planMode`, `diffAdded`, `diffRemoved`, `userMessageBackground`.

**Notifications:** Set `preferredNotifChannel: "terminal_bell"` in settings, or configure a Notification hook for custom sounds.

### Tools Reference

Built-in tools Claude can use. Tool names are the exact strings for permission rules, hooks, and subagent configs.

| Tool | Permission? | Description |
|:-----|:-----------|:------------|
| `Agent` | No | Spawns a subagent with its own context window |
| `AskUserQuestion` | No | Asks multiple-choice questions |
| `Bash` | Yes | Executes shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Schedule/cancel/list session-scoped tasks |
| `Edit` | Yes | Targeted string replacement in files |
| `EnterPlanMode` / `ExitPlanMode` | No / Yes | Switch to/from plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Create/exit isolated git worktrees |
| `Glob` | No | Find files by name pattern (up to 100 results, sorted by mtime) |
| `Grep` | No | Search file contents (ripgrep syntax) |
| `LSP` | No | Code intelligence via language servers |
| `Monitor` | Yes | Watch a background process and react to output lines |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells by cell_id |
| `PowerShell` | Yes | Execute PowerShell commands (Windows primary or opt-in) |
| `PushNotification` | No | Send desktop/phone push notification |
| `Read` | No | Read file contents with line numbers |
| `RemoteTrigger` | No | Create/run Routines on claude.ai |
| `Skill` | Yes | Execute a skill within the main conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Manage session task checklist |
| `ToolSearch` | No | Search for and load deferred tools |
| `WebFetch` | Yes | Fetch a URL and extract content (15-min cache) |
| `WebSearch` | Yes | Search the web (up to 8 backend searches per call) |
| `Write` | Yes | Create or overwrite files (must have read file first if it exists) |

**Permission rule format:**

| Rule | Applies to | Notes |
|:-----|:-----------|:------|
| `Bash(npm run *)` | Bash, Monitor | Command pattern matching |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP | Path pattern matching |
| `Edit(/src/**)` | Edit, Write, NotebookEdit | Path pattern matching |
| `Skill(deploy *)` | Skill | Skill name matching |
| `Agent(Explore)` | Agent | Subagent type matching |
| `WebFetch(domain:example.com)` | WebFetch | Domain matching |
| `WebSearch` | WebSearch | No specifier; allow/deny as whole |

An `Edit(...)` allow rule also grants read access to the same path.

**Bash tool behavior:**
- `cd` carries over within project directory; resets if outside. Disable with `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1`
- Environment variables do not persist across commands
- Default timeout: 2 minutes (up to 10 min per command). Override: `BASH_DEFAULT_TIMEOUT_MS`, `BASH_MAX_TIMEOUT_MS`
- Output limit: 30,000 chars (override: `BASH_MAX_OUTPUT_LENGTH`, ceiling 150,000)

**Edit tool behavior:** Exact string replacement. Requires read-before-edit (or `cat`/`head`/`tail`/`sed -n` in Bash on single file). `old_string` must match exactly and appear exactly once (or use `replace_all: true`).

**Glob tool behavior:** Respects gitignore by default is off (finds all files including gitignored). Set `CLAUDE_CODE_GLOB_NO_IGNORE=false` to respect `.gitignore`. Results capped at 100.

**Grep tool behavior:** Uses ripgrep syntax. Output modes: `files_with_matches` (default), `content`, `count`. Respects `.gitignore`. Set `multiline: true` for cross-line matches.

**WebFetch tool behavior:** Fetches URL, converts HTML to Markdown via small fast model (lossy extraction). HTTP auto-upgraded to HTTPS. Redirects to different host return a note instead of following. 15-minute response cache.

**WebSearch tool behavior:** Returns titles and URLs; does not fetch pages. Up to 8 backend searches per call. Supports `allowed_domains` or `blocked_domains` (not both). Not configurable; use MCP for different providers.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — Complete CLI commands and flags, system prompt flag behavior
- [Commands](references/claude-code-commands.md) — All in-session commands including bundled skills
- [Interactive Mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, Vim mode, command history, background tasks, shell mode, prompt suggestions, /btw, task list, session recap
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) — Keybindings config file, all contexts and actions, keystroke syntax, chords, reserved shortcuts
- [Configure Your Terminal](references/claude-code-terminal-config.md) — Shift+Enter setup, Option key on macOS, tmux config, fullscreen rendering, custom themes, notifications
- [Tools Reference](references/claude-code-tools-reference.md) — All built-in tools, permission rule syntax, per-tool behavior details

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure Your Terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
