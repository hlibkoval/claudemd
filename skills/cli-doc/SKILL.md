---
name: cli-doc
description: Complete official documentation for the Claude Code CLI — launch commands, all flags, slash commands (built-in and bundled skills), interactive mode keyboard shortcuts, Vim editor mode, keybindings customization, terminal configuration (Shift+Enter, Option key, tmux, themes, fullscreen), and the built-in tools reference (Bash, Edit, Read, Glob, Grep, Agent, Monitor, WebFetch, WebSearch, Write, LSP, NotebookEdit, PowerShell, and more).
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, keyboard shortcuts, terminal configuration, and built-in tools.

## Quick Reference

### Launch Commands

| Command | Description | Example |
| :--- | :--- | :--- |
| `claude` | Start interactive session | `claude` |
| `claude "query"` | Start interactive session with initial prompt | `claude "explain this project"` |
| `claude -p "query"` | Non-interactive (print mode), then exit | `claude -p "explain this function"` |
| `cat file \| claude -p "query"` | Process piped content | `cat logs.txt \| claude -p "explain"` |
| `claude -c` | Continue most recent conversation | `claude -c` |
| `claude -r "<session>" "query"` | Resume session by ID or name | `claude -r "auth-refactor" "Finish this PR"` |
| `claude update` | Update to latest version | `claude update` |
| `claude install [version]` | Install/reinstall native binary (`stable`, `latest`, or version number) | `claude install stable` |
| `claude auth login` | Sign in (`--email`, `--sso`, `--console` flags available) | `claude auth login --console` |
| `claude auth logout` | Sign out | `claude auth logout` |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) | `claude auth status` |
| `claude agents` | Open agent view for background sessions | `claude agents --cwd ~/projects/my-app` |
| `claude attach <id>` | Attach to a background session | `claude attach 7c5dcf5d` |
| `claude bg <id>` | Start session as background agent | `claude --bg "investigate the flaky test"` |
| `claude daemon status` | Print supervisor state and worker count | `claude daemon status` |
| `claude logs <id>` | Print recent output from a background session | `claude logs 7c5dcf5d` |
| `claude mcp` | Configure MCP servers | — |
| `claude plugin` | Manage plugins (alias: `claude plugins`) | `claude plugin install code-review@claude-plugins-official` |
| `claude project purge [path]` | Delete all local Claude Code state for a project (`--dry-run`, `-y`, `--all`) | `claude project purge ~/work/repo --dry-run` |
| `claude remote-control` | Start Remote Control server | `claude remote-control --name "My Project"` |
| `claude respawn <id>` | Restart a background session with conversation intact | `claude respawn 7c5dcf5d` |
| `claude rm <id>` | Remove a background session from the list | `claude rm 7c5dcf5d` |
| `claude setup-token` | Generate long-lived OAuth token for CI | `claude setup-token` |
| `claude stop <id>` | Stop a background session (alias: `claude kill`) | `claude stop 7c5dcf5d` |
| `claude ultrareview [target]` | Run ultrareview non-interactively (`--json`, `--timeout <minutes>`) | `claude ultrareview 1234 --json` |

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `--add-dir` | Add additional working directories (`claude --add-dir ../apps ../lib`) |
| `--agent` | Specify an agent for the current session |
| `--agents` | Define custom subagents dynamically via JSON |
| `--allowedTools` | Tools that run without permission prompts |
| `--append-system-prompt` | Append text to the default system prompt |
| `--append-system-prompt-file` | Load appended system prompt from a file |
| `--bare` | Skip hooks, skills, plugins, MCP, CLAUDE.md — faster for scripts |
| `--bg` | Start session as a background agent and return immediately |
| `--continue`, `-c` | Load most recent conversation in the current directory |
| `--dangerously-skip-permissions` | Skip permission prompts (equivalent to `--permission-mode bypassPermissions`) |
| `--debug` | Enable debug mode with optional category filtering |
| `--debug-file <path>` | Write debug logs to a specific file |
| `--disallowedTools` | Remove tools from the model's context |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves cache reuse) |
| `--fallback-model` | Fallback model when primary is overloaded (print mode and background only) |
| `--fork-session` | Create new session ID when resuming (use with `--resume`/`--continue`) |
| `--from-pr` | Resume sessions linked to a pull request (PR number, GitHub/GitLab/Bitbucket URL) |
| `--json-schema` | Get validated JSON output matching a schema (print mode only) |
| `--max-budget-usd` | Maximum spend limit in dollars (print mode only) |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--mcp-config` | Load MCP servers from JSON files or strings |
| `--model` | Set model: alias (`sonnet`, `opus`) or full name |
| `--name`, `-n` | Set display name for the session |
| `--no-session-persistence` | Disable session saving to disk (print mode only) |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` |
| `--permission-mode` | Start in a permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--permission-prompt-tool` | MCP tool to handle permission prompts in non-interactive mode |
| `--plugin-dir` | Load a plugin from a directory or `.zip` archive |
| `--plugin-url` | Fetch a plugin `.zip` from a URL |
| `--print`, `-p` | Print response without interactive mode |
| `--remote` | Create a new web session on claude.ai with the provided task |
| `--remote-control`, `--rc` | Start interactive session with Remote Control enabled |
| `--resume`, `-r` | Resume a session by ID or name |
| `--session-id` | Use a specific session ID (must be a valid UUID) |
| `--settings` | Path to settings JSON file or inline JSON string |
| `--system-prompt` | Replace entire system prompt with custom text |
| `--system-prompt-file` | Load system prompt from a file (replaces default) |
| `--teleport` | Resume a web session in your local terminal |
| `--teammate-mode` | Set agent team display: `auto`, `in-process`, `tmux` |
| `--tmux` | Create a tmux session for a worktree (use with `--worktree`) |
| `--tools` | Restrict built-in tools: `""` disables all, `"default"` enables all |
| `--verbose` | Enable verbose logging (turn-by-turn output) |
| `--version`, `-v` | Output the version number |
| `--worktree`, `-w` | Start Claude in an isolated git worktree |

### System Prompt Flags

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags combine with either replacement flag. Use append when Claude should remain a coding assistant; use replace when the identity differs fundamentally (e.g., a non-coding pipeline agent).

### Slash Commands

Commands are entered with `/` at the start of a message. Type `/` to see all available commands, or `/` followed by letters to filter.

**Session management**

| Command | Purpose |
| :--- | :--- |
| `/clear [name]` | Start new conversation (aliases: `/reset`, `/new`) |
| `/resume [session]` | Resume a session by ID or name (alias: `/continue`) |
| `/branch [name]` | Branch conversation at this point (alias: `/fork`) |
| `/compact [instructions]` | Summarize conversation to free up context |
| `/context [all]` | Visualize context usage |
| `/rewind` | Rewind code and/or conversation to a previous checkpoint (aliases: `/checkpoint`, `/undo`) |
| `/rename [name]` | Rename the current session |
| `/export [filename]` | Export conversation as plain text |
| `/background [prompt]` | Detach session to run as background agent (alias: `/bg`) |

**Model and settings**

| Command | Purpose |
| :--- | :--- |
| `/model [model]` | Select or change the AI model |
| `/effort [level\|auto]` | Set effort level (`low`, `medium`, `high`, `xhigh`, `max`) |
| `/config` | Open Settings interface (alias: `/settings`) |
| `/fast [on\|off]` | Toggle fast mode |
| `/permissions` | Manage allow, ask, and deny rules (alias: `/allowed-tools`) |

**Workflow and parallel work**

| Command | Purpose |
| :--- | :--- |
| `/plan [description]` | Enter plan mode |
| `/batch <instruction>` | **[Skill]** Orchestrate large-scale parallel changes across a codebase |
| `/agents` | Manage agent configurations |
| `/tasks` | List and manage background tasks (alias: `/bashes`) |
| `/diff` | Open interactive diff viewer |
| `/review [PR]` | Review a pull request locally |
| `/ultrareview [PR]` | Run deep multi-agent cloud review |
| `/ultraplan <prompt>` | Draft a plan, review in browser, execute remotely |
| `/simplify [focus]` | **[Skill]** Review recently changed files and apply quality fixes |
| `/security-review` | Analyze pending changes for security vulnerabilities |
| `/btw <question>` | Ask a side question without adding to conversation history |

**Integrations**

| Command | Purpose |
| :--- | :--- |
| `/mcp` | Manage MCP server connections and OAuth |
| `/memory` | Edit CLAUDE.md files and manage auto-memory |
| `/hooks` | View hook configurations |
| `/ide` | Manage IDE integrations |
| `/plugin` | Manage plugins |
| `/keybindings` | Open or create keybindings config file |

**Utilities**

| Command | Purpose |
| :--- | :--- |
| `/help` | Show help and available commands |
| `/doctor` | Diagnose installation and settings |
| `/debug [description]` | **[Skill]** Enable debug logging and troubleshoot |
| `/copy [N]` | Copy last (or Nth) assistant response to clipboard |
| `/usage` | Show session cost, plan usage, and stats (aliases: `/cost`, `/stats`) |
| `/init` | Initialize project with a CLAUDE.md guide |
| `/status` | Open Settings interface on the Status tab |
| `/feedback [report]` | Submit feedback (alias: `/bug`) |
| `/exit` | Exit the CLI (alias: `/quit`) |
| `/voice [hold\|tap\|off]` | Toggle voice dictation |
| `/teleport` | Pull a web session into this terminal (alias: `/tp`) |
| `/remote-control` | Make session available for remote control (alias: `/rc`) |
| `/schedule [description]` | Create/manage routines on Anthropic cloud (alias: `/routines`) |
| `/goal [condition\|clear]` | Set a goal; Claude keeps working until the condition is met |
| `/background [prompt]` | Detach to background (alias: `/bg`) |
| `/autofix-pr [prompt]` | Spawn web session to watch and fix CI failures on a PR |
| `/loop [interval] [prompt]` | **[Skill]** Run a prompt repeatedly on an interval |
| `/web-setup` | Connect GitHub account to Claude Code on the web |
| `/add-dir <path>` | Add a working directory for file access in current session |
| `/batch <instruction>` | **[Skill]** Large-scale parallel codebase changes |
| `/fewer-permission-prompts` | **[Skill]** Scan transcripts and build an allowlist to reduce permission prompts |

### Interactive Mode — Keyboard Shortcuts

#### General Controls

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit Claude Code |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open prompt in external text editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running tasks (tmux users press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+X Ctrl+K` | Kill all running background subagents (press twice to confirm) |
| `Ctrl+V` / `Cmd+V` (iTerm2) / `Alt+V` (Windows) | Paste image from clipboard |
| `Esc` | Interrupt Claude mid-turn |
| `Esc` + `Esc` | Rewind or summarize conversation |
| `Shift+Tab` | Cycle permission modes (`default` → `acceptEdits` → `plan` → ...) |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |

#### Text Editing

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+A` | Move cursor to start of current line |
| `Ctrl+E` | Move cursor to end of current line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` | Move cursor back one word |
| `Alt+F` | Move cursor forward one word |

#### Multiline Input

| Method | Shortcut |
| :--- | :--- |
| Works everywhere | `\` + `Enter` or `Ctrl+J` |
| Most terminals (native) | `Shift+Enter` |
| macOS Option as Meta | `Option+Enter` |
| VS Code, Cursor, Windsurf, Alacritty, Zed | Run `/terminal-setup` once |

#### Quick Prefixes

| Prefix | Function |
| :--- | :--- |
| `/` at start | Command or skill |
| `!` at start | Shell mode — runs commands directly, adds output to context |
| `@` | File path autocomplete |

### Vim Editor Mode

Enable via `/config` → Editor mode (or set `"editorMode": "vim"` in settings).

| Mode | Key | Action |
| :--- | :--- | :--- |
| INSERT/VISUAL → NORMAL | `Esc` | Enter NORMAL mode |
| NORMAL → INSERT | `i`, `a`, `o`, `O`, `I`, `A` | Various insert positions |
| NORMAL → VISUAL | `v` (char), `V` (line) | Start visual selection |

Navigation (NORMAL): `hjkl`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f{char}`/`t{char}`.

Editing (NORMAL): `x` (delete char), `dd`/`D`, `cc`/`C`, `yy`/`Y`, `p`/`P`, `u` (undo), `.` (repeat).

Text objects: `iw`/`aw`, `i"`/`a"`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`.

### Keybindings Customization

Config file: `~/.claude/keybindings.json` (run `/keybindings` to open or create it). Changes apply without restarting.

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

**Contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Scroll`, `Select`, `Plugin`, `Doctor`, and more.

**Key action groups:**

| Namespace | Example actions |
| :--- | :--- |
| `app:` | `app:interrupt`, `app:exit`, `app:toggleTodos`, `app:toggleTranscript` |
| `chat:` | `chat:submit`, `chat:cancel`, `chat:newline`, `chat:cycleMode`, `chat:modelPicker`, `chat:fastMode`, `chat:thinkingToggle`, `chat:externalEditor`, `chat:imagePaste` |
| `history:` | `history:search`, `history:previous`, `history:next` |
| `transcript:` | `transcript:toggleShowAll`, `transcript:exit` |
| `scroll:` | `scroll:lineUp/Down`, `scroll:pageUp/Down`, `scroll:top`, `scroll:bottom` |
| `selection:` | `selection:copy`, `selection:extendLeft/Right/Up/Down` |

**Reserved shortcuts (cannot be rebound):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, Caps Lock.

**Terminal conflicts:** `Ctrl+B` (tmux prefix — press twice), `Ctrl+A` (GNU screen prefix), `Ctrl+Z` (process suspend).

Keystroke syntax: `ctrl+k`, `shift+tab`, `meta+p`, `ctrl+shift+c`. Chords: `ctrl+k ctrl+s`. Set `"context"` to apply bindings only where needed.

### Terminal Configuration

| Issue | Fix |
| :--- | :--- |
| Shift+Enter submits instead of newline | Run `/terminal-setup` in VS Code, Cursor, Windsurf, Alacritty, Zed; or configure tmux (see below) |
| Option key shortcuts do nothing (macOS) | iTerm2: Settings → Profiles → Keys → set Option key to "Esc+"; Apple Terminal: Settings → Profiles → Keyboard → "Use Option as Meta Key"; VS Code: `"terminal.integrated.macOptionIsMeta": true` |
| No sound/alert when Claude finishes | Set `preferredNotifChannel` to `"terminal_bell"`, or configure a Notification hook |
| Running inside tmux | Add to `~/.tmux.conf`: `set -g allow-passthrough on`, `set -s extended-keys on`, `set -as terminal-features 'xterm*:extkeys'` |
| Display flickers or scrollback jumps | Switch to fullscreen: `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Vim keys in prompt | Enable via `/config` → Editor mode |

**Custom themes:** JSON files in `~/.claude/themes/`. Fields: `name`, `base` (`dark`, `light`, `dark-daltonized`, etc.), `overrides` (map of color token → value). Color values: `#rrggbb`, `rgb(r,g,b)`, `ansi256(n)`, `ansi:<name>`. Run `/theme` → "New custom theme…" to create interactively.

### Built-in Tools

| Tool | Permission Required | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawns a subagent with its own context window |
| `AskUserQuestion` | No | Asks multiple-choice questions for requirements/clarification |
| `Bash` | Yes | Executes shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Schedule recurring/one-shot prompts within session |
| `Edit` | Yes | Makes targeted exact-string replacements in files |
| `EnterPlanMode` / `ExitPlanMode` | No/Yes | Switch to/from plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Create or switch into an isolated git worktree |
| `Glob` | No | Find files by name pattern |
| `Grep` | No | Search file contents with ripgrep regex |
| `LSP` | No | Code intelligence: jump to definition, find references, type errors |
| `Monitor` | Yes | Watch a command in background and react to each output line |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `PowerShell` | Yes | Execute PowerShell commands natively |
| `PushNotification` | No | Send desktop/phone push notification |
| `Read` | No | Read file contents with line numbers |
| `RemoteTrigger` | No | Create/run Routines on claude.ai |
| `Skill` | Yes | Execute a skill within the main conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Manage background tasks |
| `ToolSearch` | No | Search for and load deferred MCP tools |
| `WebFetch` | Yes | Fetch a URL and extract content via prompt (15-minute cache) |
| `WebSearch` | Yes | Run web searches via Anthropic's search backend |
| `Write` | Yes | Create or overwrite files (must have read existing files first) |

**Tool permission rule formats:**

| Rule | Applies to |
| :--- | :--- |
| `Bash(npm run *)` | Bash, Monitor — command prefix matching |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP — path matching |
| `Edit(/src/**)` | Edit, Write, NotebookEdit — path matching |
| `WebFetch(domain:example.com)` | WebFetch — domain matching |
| `Skill(deploy *)` | Skill — name matching |
| `Agent(Explore)` | Agent — subagent type matching |
| `WebSearch` | WebSearch — bare name only |

**Key tool behaviors:**

- **Bash:** `cd` persists within working directories; env vars do not. Default timeout: 2 minutes (max 10). Output cap: 30,000 chars (max 150,000 with `BASH_MAX_OUTPUT_LENGTH`).
- **Edit:** exact string match, no regex, must read file first, `old_string` must be unique (or use `replace_all: true`).
- **Glob:** sorted by modification time, capped at 100 results, does not respect `.gitignore` by default.
- **Grep:** built on ripgrep, respects `.gitignore`, output modes: `files_with_matches`, `content`, `count`.
- **WebFetch:** converts HTML to Markdown via a small model (lossy); caches 15 minutes; does not follow cross-host redirects automatically.
- **Monitor:** requires v2.1.98+; not available on Bedrock/Vertex/Foundry; uses Bash permission rules.
- **Read:** handles images (PNG/JPG), PDFs (up to 20 pages at a time), and Jupyter notebooks (`.ipynb`).

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — complete list of CLI commands and all flags, including system prompt flag guidance
- [Commands](references/claude-code-commands.md) — all slash commands (built-in and bundled skills), organized by workflow stage
- [Interactive mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, Vim editor mode, command history, shell mode, prompt suggestions, side questions, task list, session recap
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) — keybindings file format, all contexts, all actions with defaults, keystroke syntax, chords, unbinding, reserved shortcuts
- [Configure your terminal](references/claude-code-terminal-config.md) — multiline input setup, Option key on macOS, terminal bell notifications, tmux config, fullscreen rendering, custom themes, Vim mode
- [Tools reference](references/claude-code-tools-reference.md) — complete tool list with permission requirements, permission rule formats, and per-tool behavior details

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure your terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
