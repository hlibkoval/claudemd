---
name: cli-doc
description: Complete official documentation for Claude Code CLI — all CLI commands (claude agents, attach, auth, daemon, install, logs, plugin, project, remote-control, respawn, rm, setup-token, stop, ultrareview, update), all CLI flags (--add-dir, --agent, --bg, --bare, --effort, --model, --permission-mode, --output-format, --print, --resume, --worktree, and 60+ more), all slash commands (/batch, /branch, /btw, /clear, /compact, /config, /diff, /effort, /goal, /hooks, /model, /permissions, /plan, /rewind, /skills, /tasks, /teleport, /ultrareview, /usage, and 90+ more), keyboard shortcuts and vim editor mode, terminal configuration (Shift+Enter, Option key, tmux, fullscreen rendering, custom themes, color tokens), all built-in tools (Agent, Bash, Edit, Glob, Grep, LSP, Monitor, NotebookEdit, PowerShell, Read, WebFetch, WebSearch, Write, and 20+ more), and keybindings customization (contexts, actions, keystroke syntax, chords).
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code CLI — commands, flags, slash commands, keyboard shortcuts, terminal configuration, tools, and keybindings.

## Quick Reference

### CLI Commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive, then exit) |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude --bg "task"` | Start as background agent |
| `claude update` | Update to latest version |
| `claude install [version]` | Install or reinstall binary (`stable`, `latest`, or version number) |
| `claude auth login` | Sign in. Flags: `--email`, `--sso`, `--console` |
| `claude auth logout` | Log out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | Open agent view. Flags: `--cwd`, `--json`, `--permission-mode`, `--model`, `--effort` |
| `claude attach <id>` | Attach to a background session |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |
| `claude daemon status` | Print supervisor state and diagnostics |
| `claude logs <id>` | Print recent output from a background session |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins (alias: `claude plugins`) |
| `claude project purge [path]` | Delete all local state for a project. Flags: `--dry-run`, `-y`, `-i`, `--all` |
| `claude remote-control` | Start a Remote Control server |
| `claude respawn <id>` | Restart a background session with conversation intact. `--all` restarts every running session |
| `claude rm <id>` | Remove a background session from the list |
| `claude setup-token` | Generate a long-lived OAuth token for CI/scripts |
| `claude stop <id>` | Stop a background session (alias: `claude kill`) |
| `claude ultrareview [target]` | Run ultrareview non-interactively. Flags: `--json`, `--timeout <minutes>` |

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `-p`, `--print` | Print mode: query and exit |
| `-c`, `--continue` | Load most recent conversation |
| `-r`, `--resume` | Resume session by ID or name |
| `-n`, `--name` | Set display name for the session |
| `-w`, `--worktree` | Start in an isolated git worktree |
| `--bg` | Start as background agent |
| `--model` | Set model (`sonnet`, `opus`, or full model ID) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, or `bypassPermissions` |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` |
| `--input-format` | Input format for print mode: `text`, `stream-json` |
| `--add-dir` | Add additional working directories |
| `--agent` | Specify an agent for the session |
| `--agents` | Define custom subagents dynamically via JSON |
| `--allowedTools` | Tools that run without prompting |
| `--disallowedTools` | Deny rules; bare tool name removes it from context |
| `--append-system-prompt` | Append custom text to the system prompt |
| `--append-system-prompt-file` | Append file contents to the system prompt |
| `--system-prompt` | Replace entire system prompt |
| `--system-prompt-file` | Replace system prompt with file contents |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--dangerously-skip-permissions` | Skip permission prompts (equivalent to `bypassPermissions`) |
| `--debug` | Enable debug mode with optional category filter |
| `--debug-file <path>` | Write debug logs to a file |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves cache reuse) |
| `--fallback-model` | Fallback model when default is overloaded (print mode / background only) |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a PR |
| `--init` | Run Setup hooks with `init` matcher before session (print mode only) |
| `--init-only` | Run Setup and SessionStart hooks, then exit |
| `--json-schema` | Validate output against JSON Schema (print mode, structured outputs) |
| `--maintenance` | Run Setup hooks with `maintenance` matcher (print mode only) |
| `--max-budget-usd` | Max spend on API calls before stopping (print mode) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--mcp-config` | Load MCP servers from JSON files or strings |
| `--no-session-persistence` | Disable session saving to disk (print mode only) |
| `--plugin-dir` | Load a plugin from a directory or `.zip` for this session |
| `--plugin-url` | Fetch a plugin `.zip` from a URL for this session |
| `--remote` | Create a new web session on claude.ai |
| `--remote-control`, `--rc` | Start session with Remote Control enabled |
| `--settings` | Path to a settings JSON file or inline JSON |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config` |
| `--teammate-mode` | Set agent team display: `auto`, `in-process`, or `tmux` |
| `--tmux` | Create a tmux session for the worktree (requires `--worktree`) |
| `--tools` | Restrict built-in tools: `""` for none, `"default"` for all, or list |
| `--verbose` | Enable verbose logging |
| `-v`, `--version` | Output version number |

### System Prompt Flags

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags combine with either replacement flag. Use append when Claude should remain a coding assistant plus your rules; use replacement when the identity differs entirely.

### Slash Commands (Session)

Type `/` in a session to see all available commands. Entries marked **[Skill]** are bundled skills — prompts handed to Claude.

| Command | Purpose |
| :--- | :--- |
| `/add-dir <path>` | Add working directory for file access |
| `/agents` | Manage agent configurations |
| `/autofix-pr [prompt]` | Spawn web session to auto-fix PR CI failures and review comments |
| `/background [prompt]` | Detach session to run as background agent (alias: `/bg`) |
| `/batch <instruction>` | **[Skill]** Orchestrate large-scale codebase changes across parallel worktrees |
| `/branch [name]` | Branch conversation (alias: `/fork`) |
| `/btw <question>` | Quick side question without adding to conversation history |
| `/clear [name]` | Start new conversation (aliases: `/reset`, `/new`) |
| `/code-review [effort] [--comment] [target]` | **[Skill]** Review diff for correctness bugs |
| `/color [color\|default]` | Set prompt bar color |
| `/compact [instructions]` | Summarize conversation to free context |
| `/config` | Open settings interface (alias: `/settings`) |
| `/context [all]` | Visualize context usage |
| `/copy [N]` | Copy last assistant response to clipboard |
| `/debug [description]` | **[Skill]** Enable debug logging and troubleshoot |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings |
| `/effort [level\|auto]` | Set model effort level |
| `/exit` | Exit the CLI (alias: `/quit`) |
| `/export [filename]` | Export conversation as plain text |
| `/fast [on\|off]` | Toggle fast mode |
| `/feedback [report]` | Submit feedback or bug report (aliases: `/bug`, `/share`) |
| `/fewer-permission-prompts` | **[Skill]** Scan transcripts and add allowlist to reduce prompts |
| `/focus` | Toggle focus view (fullscreen only) |
| `/goal [condition\|clear]` | Set a persistent goal Claude works toward |
| `/help` | Show help and available commands |
| `/hooks` | View hook configurations |
| `/init` | Initialize project with CLAUDE.md |
| `/insights` | Generate usage analysis report |
| `/install-github-app` | Set up Claude GitHub Actions app |
| `/keybindings` | Open or create keybindings config file |
| `/login` / `/logout` | Sign in / out |
| `/loop [interval] [prompt]` | **[Skill]** Run a prompt repeatedly (alias: `/proactive`) |
| `/mcp` | Manage MCP server connections |
| `/memory` | Edit CLAUDE.md memory files and auto-memory |
| `/model [model]` | Set AI model for session |
| `/permissions` | Manage allow/ask/deny rules (alias: `/allowed-tools`) |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/recap` | Generate one-line session summary on demand |
| `/reload-plugins` | Reload active plugins without restarting |
| `/remote-control` | Enable remote control from claude.ai (alias: `/rc`) |
| `/rename [name]` | Rename session and show on prompt bar |
| `/resume [session]` | Resume conversation (alias: `/continue`) |
| `/review [PR]` | Review a pull request locally |
| `/rewind` | Rewind code and conversation to checkpoint (aliases: `/checkpoint`, `/undo`) |
| `/run` | **[Skill]** Launch and drive app to verify a change |
| `/run-skill-generator` | **[Skill]** Teach `/run` and `/verify` how to launch your project |
| `/sandbox` | Toggle sandbox mode |
| `/schedule [description]` | Create/manage routines (alias: `/routines`) |
| `/security-review` | Analyze pending branch changes for security vulnerabilities |
| `/skills` | List available skills |
| `/status` | Open Settings status tab |
| `/statusline` | Configure the status line |
| `/stop` | Stop current background session |
| `/tasks` | List and manage background tasks |
| `/team-onboarding` | Generate team onboarding guide from usage history |
| `/teleport` | Pull a web session into this terminal (alias: `/tp`) |
| `/terminal-setup` | Configure terminal keybindings for Shift+Enter etc. |
| `/theme` | Change color theme |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/ultraplan <prompt>` | Draft plan in ultraplan session |
| `/ultrareview [PR]` | Deep multi-agent code review in cloud sandbox |
| `/usage` | Show session cost and plan usage (aliases: `/cost`, `/stats`) |
| `/verify` | **[Skill]** Confirm a code change works by running the app |
| `/vim` | Removed in v2.1.92; use `/config` → Editor mode |
| `/voice [hold\|tap\|off]` | Toggle voice dictation |
| `/web-setup` | Connect GitHub to Claude Code on the web |

### Keyboard Shortcuts

#### General Controls

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Interrupt or clear input |
| `Ctrl+D` | Exit session |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open prompt in external editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running task (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+X Ctrl+K` | Kill all background subagents (press twice within 3s) |
| `Esc` | Interrupt Claude mid-turn |
| `Esc` + `Esc` | Clear input draft, or open rewind menu |
| `Shift+Tab` | Cycle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |
| `Ctrl+V` / `Cmd+V` | Paste image from clipboard |

#### Text Editing

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+A` / `Ctrl+E` | Move to start/end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+Y` | Cycle paste history (after `Ctrl+Y`) |
| `Alt+B` / `Alt+F` | Move back/forward one word |

#### Multiline Input

| Method | Shortcut |
| :--- | :--- |
| Works everywhere | `\` + `Enter` or `Ctrl+J` |
| Most terminals | `Shift+Enter` (run `/terminal-setup` for VS Code/Cursor/Zed) |
| macOS Option key | `Option+Enter` (requires Option as Meta) |

#### Quick Commands

| Shortcut | Description |
| :--- | :--- |
| `/` at start | Command or skill |
| `!` at start | Shell mode (runs directly, output added to context) |
| `@` | File path autocomplete |

### Vim Editor Mode

Enable via `/config` → Editor mode or `"editorMode": "vim"` in settings.

Key vim behaviors: `i`/`I`/`a`/`A`/`o`/`O` enter INSERT, `v`/`V` enter VISUAL, `Esc` returns to NORMAL. NORMAL navigation: `hjkl`, `w`/`e`/`b`, `0`/`$`, `gg`/`G`, `f{char}`/`F{char}`. NORMAL editing: `x`/`dd`/`D`, `cc`/`C`, `yy`/`p`, `u` undo, `.` repeat. Text objects: `iw`/`aw`, `i"`/`a"`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`. Enter still submits in INSERT mode.

### Terminal Configuration

| Issue | Solution |
| :--- | :--- |
| Shift+Enter submits | Run `/terminal-setup` (VS Code, Cursor, Windsurf, Zed); tmux needs `extend-keys on` in config |
| Option key shortcuts do nothing (macOS) | Enable "Use Option as Meta Key" in terminal: iTerm2 → Keys → "Esc+"; Apple Terminal → Keyboard; VS Code → `macOptionIsMeta: true` |
| No notification when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` or configure a Notification hook |
| Display flickers / scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Want vim keys in prompt | `/config` → Editor mode, or `"editorMode": "vim"` in settings |

**tmux config** (add to `~/.tmux.conf`):
```
set -g allow-passthrough on
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'
```

**Custom themes**: JSON files in `~/.claude/themes/`. Fields: `name`, `base` (dark/light/dark-daltonized/light-daltonized/dark-ansi/light-ansi), `overrides` (map of color token names to color values). Key tokens: `claude` (brand accent), `text`, `error`, `success`, `warning`, `promptBorder`, `planMode`, `diffAdded`, `diffRemoved`, `userMessageBackground`. Create interactively with `/theme` → New custom theme.

### Built-in Tools

| Tool | Permission | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawns a subagent with its own context window |
| `AskUserQuestion` | No | Asks multiple-choice questions |
| `Bash` | Yes | Executes shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Manage scheduled tasks within session |
| `Edit` | Yes | Makes targeted string-replacement edits to files |
| `EnterPlanMode` / `ExitPlanMode` | No/Yes | Switch into/out of plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Create/switch/exit git worktrees |
| `Glob` | No | Finds files by pattern (capped at 100, sorted by mtime) |
| `Grep` | No | Searches file contents via ripgrep regex; respects `.gitignore` |
| `LSP` | No | Code intelligence (definitions, references, type info) — needs plugin |
| `Monitor` | Yes | Background watch + line-by-line reaction (v2.1.98+) |
| `NotebookEdit` | Yes | Modifies Jupyter notebook cells (`replace`/`insert`/`delete`) |
| `PowerShell` | Yes | Executes PowerShell natively (opt-in on non-Windows) |
| `PushNotification` | No | Desktop/phone notification (Anthropic-hosted only) |
| `Read` | No | Reads files with line numbers; handles images, PDFs, notebooks |
| `RemoteTrigger` | No | Creates/runs Routines on claude.ai (Pro/Max/Team/Enterprise) |
| `Skill` | Yes | Executes a skill within the main conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Manage session task list |
| `WebFetch` | Yes | Fetches URL, converts to Markdown, runs extraction prompt against it |
| `WebSearch` | Yes | Searches Anthropic web search backend; does not fetch pages |
| `Write` | Yes | Creates or overwrites files (requires prior read of existing files) |

#### Key Tool Behaviors

**Bash**: `cd` carries over within project/additional dirs; env vars do not persist; sources shell startup files. Default timeout: 2 min (up to 10 min). Output truncated at 30,000 chars (configurable via `BASH_MAX_OUTPUT_LENGTH`).

**Edit**: Requires read-before-edit; `old_string` must match exactly once; `replace_all: true` replaces all occurrences. `cat`/`head`/`tail`/`sed -n 'X,Yp'` in Bash also satisfy read requirement.

**Glob**: Does NOT respect `.gitignore` by default (unlike Grep). Set `CLAUDE_CODE_GLOB_NO_IGNORE=false` to enable `.gitignore` filtering.

**Grep**: Uses ripgrep regex (not POSIX). Modes: `files_with_matches` (default), `content`, `count`. Respects `.gitignore`.

**WebFetch**: Lossy by design — HTML converted to Markdown and extraction prompt applied. Caches 15 min. HTTP auto-upgraded to HTTPS. Does not follow cross-host redirects (returns a note, then Claude fetches the new URL).

**Write**: Cannot overwrite existing file without a prior read in the current conversation.

### Permission Rule Format for Tools

| Rule | Applies to |
| :--- | :--- |
| `Bash(npm run *)` | Bash, Monitor |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP |
| `Edit(/src/**)` | Edit, Write, NotebookEdit |
| `Skill(deploy *)` | Skill |
| `Agent(Explore)` | Agent |
| `WebFetch(domain:example.com)` | WebFetch |
| `WebSearch` | WebSearch (no specifier) |

An `Edit(...)` allow rule also grants read access to the same path.

### Keybindings Customization

Config file: `~/.claude/keybindings.json`. Run `/keybindings` to open it. Changes auto-apply without restarting.

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

Set an action to `null` to unbind it. Actions use `namespace:action` format.

**Key contexts**: `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Select`, `Plugin`, `Settings`, `Scroll`, `DiffDialog`, `ModelPicker`, `Footer`

**Key actions**: `app:interrupt` (Ctrl+C), `app:exit` (Ctrl+D), `app:toggleTodos` (Ctrl+T), `app:toggleTranscript` (Ctrl+O), `chat:submit` (Enter), `chat:newline` (Ctrl+J), `chat:cycleMode` (Shift+Tab), `chat:externalEditor` (Ctrl+G), `chat:cancel` (Escape), `chat:modelPicker` (Meta+P), `chat:thinkingToggle` (Meta+T), `history:search` (Ctrl+R)

**Reserved** (cannot rebind): `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, `Caps Lock`

**Chords**: space-separated sequences, e.g. `ctrl+k ctrl+s`. Unbind all chords on a prefix before using that prefix as a single key.

**Modifier syntax**: `ctrl`, `shift`, `alt`/`meta`/`opt`, `cmd`/`super`. Standalone uppercase letter implies Shift (e.g. `K` = `shift+k`).

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — all CLI commands and flags, system prompt flags, piped usage
- [Commands](references/claude-code-commands.md) — all slash commands including bundled skills, command discovery, MCP prompts
- [Interactive mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, vim editor mode, command history, background bash, shell mode, prompt suggestions, /btw side questions, task list, session recap, PR review status
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) — keybindings config format, all contexts, all actions with defaults, keystroke syntax, chords, unbinding, reserved shortcuts
- [Configure your terminal](references/claude-code-terminal-config.md) — Shift+Enter setup, Option key on macOS, tmux config, notifications, fullscreen rendering, custom themes with color token reference, vim mode
- [Tools reference](references/claude-code-tools-reference.md) — all built-in tools with permission requirements, per-tool behavior details (Bash, Edit, Glob, Grep, LSP, Monitor, NotebookEdit, PowerShell, Read, WebFetch, WebSearch, Write), permission rule format

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure your terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
