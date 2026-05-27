---
name: cli-doc
description: Complete official documentation for the Claude Code CLI — launch commands, flags (--model, --effort, --permission-mode, --print, --bg, --worktree, --add-dir, --bare, --system-prompt, --agents, --plugin-dir, etc.), session management (resume, continue, fork, background), all slash commands and bundled skills, interactive mode keyboard shortcuts, Vim editor mode, command history, background bash tasks, shell mode, keybindings configuration (contexts, actions, keystroke syntax, unbinding), terminal configuration (Shift+Enter, Option key, tmux, themes, fullscreen), and the full tools reference (Bash, Edit, Read, Write, Glob, Grep, Agent, WebFetch, WebSearch, Monitor, NotebookEdit, LSP, PowerShell, and more).
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for Claude Code's command-line interface, interactive mode, keybindings, terminal configuration, and built-in tools.

## Quick Reference

### Launch Commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start with initial prompt |
| `claude -p "query"` | Print mode (non-interactive, then exit) |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<id or name>" "query"` | Resume session by ID or name |
| `claude --bg "task"` | Start session as background agent, return immediately |
| `claude agents` | Open agent view for monitoring background sessions |
| `claude attach <id>` | Attach to a background session |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (use `--console` for API billing) |
| `claude auth status` | Show auth status (JSON; `--text` for human-readable) |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude remote-control` | Start Remote Control server |
| `claude ultrareview [target]` | Deep multi-agent code review (non-interactive) |

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `--model` | Set model (`sonnet`, `opus`, `haiku`, or full ID) |
| `--effort` | Set effort: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `-p` / `--print` | Non-interactive print mode |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` |
| `--bg` | Start as background agent |
| `--worktree` / `-w` | Start in isolated git worktree |
| `--add-dir` | Add additional working directories (grants file access) |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--continue` / `-c` | Load most recent conversation in current directory |
| `--resume` / `-r` | Resume session by ID or name |
| `--fork-session` | Create new session ID when resuming (use with `--resume`/`--continue`) |
| `--name` / `-n` | Set display name for the session |
| `--agent` | Specify a subagent for the whole session |
| `--agents` | Define custom subagents dynamically via JSON |
| `--plugin-dir` | Load a plugin from a directory or `.zip` for this session |
| `--plugin-url` | Fetch a plugin `.zip` from URL for this session |
| `--system-prompt` | Replace entire system prompt with custom text |
| `--system-prompt-file` | Replace system prompt from a file |
| `--append-system-prompt` | Append text to the default system prompt |
| `--append-system-prompt-file` | Append file contents to the default system prompt |
| `--allowedTools` | Tools that run without permission prompts |
| `--disallowedTools` | Deny rules (bare name removes tool; scoped rule limits calls) |
| `--tools` | Restrict available built-in tools |
| `--mcp-config` | Load MCP servers from JSON files |
| `--max-turns` | Limit agentic turns in print mode |
| `--max-budget-usd` | Spending limit for print mode API calls |
| `--dangerously-skip-permissions` | Skip all permission prompts (= `bypassPermissions`) |
| `--debug` | Enable debug mode with optional category filter |
| `--verbose` | Show full turn-by-turn output |
| `--json-schema` | Get validated JSON matching a schema (print mode, structured outputs) |
| `--remote` | Create a new web session on claude.ai |
| `--remote-control` / `--rc` | Start interactive session with Remote Control enabled |
| `--teleport` | Resume a web session in your local terminal |
| `--chrome` | Enable Chrome browser integration |
| `--tmux` | Create a tmux session for the worktree (requires `--worktree`) |
| `--from-pr` | Resume sessions linked to a specific pull request |
| `--init` | Run Setup hooks with `init` matcher before session (print mode) |
| `--init-only` | Run Setup and SessionStart hooks, then exit |
| `--teammate-mode` | Set agent team display: `auto`, `in-process`, or `tmux` |
| `--fallback-model` | Fallback model when default is overloaded (print mode / background) |
| `--setting-sources` | Comma-separated setting sources: `user`, `project`, `local` |
| `--settings` | Path to settings JSON or inline JSON string |
| `--session-id` | Use a specific UUID for the conversation |
| `--no-session-persistence` | Don't save session to disk (print mode only) |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves cache reuse) |
| `-v` / `--version` | Output version number |

### System Prompt Flags

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either. Use append when Claude should remain a coding assistant; use replace when the surface or identity differs fundamentally.

### Slash Commands (Selected)

Commands typed with `/` inside a session. Marked **[Skill]** entries are bundled skills — prompt-based, not coded into CLI.

| Command | Purpose |
| :--- | :--- |
| `/add-dir <path>` | Add working directory for file access |
| `/background [prompt]` | Detach session to run as background agent |
| `/batch <instruction>` | **[Skill]** Orchestrate large-scale parallel changes |
| `/branch [name]` | Create a branch of the current conversation |
| `/btw <question>` | Quick side question without adding to history |
| `/clear [name]` | Start new conversation, keeping previous accessible via `/resume` |
| `/code-review [effort] [--comment] [target]` | **[Skill]** Review diff for correctness bugs |
| `/compact [instructions]` | Summarize conversation to free context |
| `/config` | Open Settings interface |
| `/context [all]` | Visualize context window usage |
| `/copy [N]` | Copy last (or Nth-latest) assistant response |
| `/debug [description]` | **[Skill]** Enable debug logging and analyze session log |
| `/diff` | Open interactive diff viewer |
| `/doctor` | Diagnose installation and settings |
| `/effort [level\|auto]` | Set model effort level |
| `/exit` | Exit (in attached background session: detach only) |
| `/export [filename]` | Export conversation as plain text |
| `/fast [on\|off]` | Toggle fast mode |
| `/goal [condition\|clear]` | Set a goal Claude works toward across turns |
| `/hooks` | View hook configurations |
| `/init` | Initialize `CLAUDE.md` for the project |
| `/keybindings` | Open/create keybindings configuration file |
| `/loop [interval] [prompt]` | **[Skill]** Run a prompt repeatedly on an interval |
| `/mcp` | Manage MCP server connections |
| `/memory` | Edit CLAUDE.md memory files |
| `/model [model]` | Set AI model for current session |
| `/permissions` | Manage allow/ask/deny rules interactively |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/recap` | Generate one-line session summary on demand |
| `/reload-plugins` | Reload active plugins without restarting |
| `/remote-control` | Enable Remote Control for this session |
| `/rename [name]` | Rename current session |
| `/resume [session]` | Resume conversation by ID or name |
| `/review [PR]` | Review a pull request locally |
| `/rewind` | Rewind conversation/code to a previous checkpoint |
| `/run` | **[Skill]** Launch and drive the project app |
| `/schedule [description]` | Create/list/run cloud Routines |
| `/security-review` | Analyze changes for security vulnerabilities |
| `/skills` | List available skills |
| `/stop` | Stop the current background session |
| `/tasks` | List and manage background tasks |
| `/teleport` | Pull a web session into this terminal |
| `/theme` | Change color theme |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/ultraplan <prompt>` | Draft a plan in an ultraplan session |
| `/ultrareview [PR]` | Deep multi-agent cloud code review |
| `/usage` | Show session cost, plan usage, and activity stats |
| `/verify` | **[Skill]** Confirm a change works by running the app |

### Interactive Mode Keyboard Shortcuts

#### General Controls

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Interrupt running operation, or clear input |
| `Ctrl+D` | Exit Claude Code |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open prompt in external text editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running task (tmux users press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+X Ctrl+K` | Kill all running background subagents (press twice to confirm) |
| `Esc` | Interrupt Claude (stops current response) |
| `Esc` + `Esc` | Clear input draft (or open rewind menu when input is empty) |
| `Shift+Tab` | Cycle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |

#### Text Editing

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+A` / `Ctrl+E` | Move cursor to start/end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word (requires Option as Meta on macOS) |

#### Multiline Input

| Method | Shortcut |
| :--- | :--- |
| Quick escape | `\` + `Enter` (all terminals) |
| Control sequence | `Ctrl+J` (any terminal) |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| Shift+Enter (VS Code etc.) | Run `/terminal-setup` once |

#### Quick Input Prefixes

| Prefix | Behavior |
| :--- | :--- |
| `/` | Command or skill |
| `!` | Shell mode (run directly, output added to context) |
| `@` | File path autocomplete |

### Vim Editor Mode

Enable via `/config` → Editor mode. Key bindings:

| Category | Keys |
| :--- | :--- |
| Mode switch | `Esc` (→ NORMAL), `i`/`I`/`a`/`A`/`o`/`O` (→ INSERT), `v`/`V` (→ VISUAL) |
| Navigation | `h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f{c}`/`F{c}` |
| Edit (NORMAL) | `x` delete char, `dd`/`D` delete line/end, `cc`/`C` change, `yy`/`Y` yank, `p`/`P` paste, `u` undo |
| Text objects | `iw`/`aw`, `i"`/`a"`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{` |
| Visual ops | `d`/`y`/`c`, `>`/`<` indent, `~`/`u`/`U` case |

Enter still submits in INSERT mode. Use `o`/`O` (NORMAL) or `Ctrl+J` for newlines.

### Keybindings Configuration

File: `~/.claude/keybindings.json` (run `/keybindings` to create/open). Changes auto-detected without restart.

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

**Key contexts:** `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Select`, `Plugin`, `Settings`, `Scroll`, `DiffDialog`, `ModelPicker`, `Footer`, `Doctor`

**Selected actions:**

| Action | Default | Context |
| :--- | :--- | :--- |
| `app:interrupt` | Ctrl+C | Global |
| `app:exit` | Ctrl+D | Global |
| `app:toggleTodos` | Ctrl+T | Global |
| `app:toggleTranscript` | Ctrl+O | Global |
| `chat:submit` | Enter | Chat |
| `chat:newline` | Ctrl+J | Chat |
| `chat:cycleMode` | Shift+Tab | Chat |
| `chat:externalEditor` | Ctrl+G, Ctrl+X Ctrl+E | Chat |
| `chat:modelPicker` | Meta+P | Chat |
| `chat:fastMode` | Meta+O | Chat |
| `chat:thinkingToggle` | Meta+T | Chat |
| `chat:killAgents` | Ctrl+X Ctrl+K | Chat |
| `task:background` | Ctrl+B | Task |
| `transcript:exit` | q, Ctrl+C, Escape | Transcript |
| `transcript:toggleShowAll` | Ctrl+E | Transcript |
| `history:search` | Ctrl+R | — |
| `historySearch:cycleScope` | Ctrl+S | HistorySearch |
| `voice:pushToTalk` | Space | Chat (voice enabled) |

**Keystroke syntax:** `ctrl+k`, `shift+tab`, `meta+p`, `ctrl+x ctrl+s` (chord). Uppercase implies Shift (e.g. `K` = `shift+k`). Set action to `null` to unbind.

**Reserved (cannot rebind):** Ctrl+C, Ctrl+D, Ctrl+M, Caps Lock.

**Terminal conflicts:** Ctrl+B (tmux prefix), Ctrl+A (GNU screen), Ctrl+Z (SIGTSTP).

### Terminal Configuration

| Symptom | Fix |
| :--- | :--- |
| Shift+Enter submits instead of newline | Run `/terminal-setup` (VS Code, Cursor, Windsurf, Alacritty, Zed) or add tmux config |
| Option shortcuts do nothing on macOS | Enable Option as Meta in terminal settings |
| No notification when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` or configure a Notification hook |
| Display flickers or scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |

**tmux config** (`~/.tmux.conf`):
```
set -g allow-passthrough on
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'
```

**Custom themes** (`~/.claude/themes/<slug>.json`): fields `name`, `base` (dark/light/dark-daltonized/light-daltonized/dark-ansi/light-ansi), `overrides` (color token map). Color values: `#rrggbb`, `rgb(r,g,b)`, `ansi256(n)`, `ansi:<name>`. Key tokens: `claude`, `text`, `success`, `error`, `warning`, `planMode`, `autoAccept`, `diffAdded`, `diffRemoved`, `userMessageBackground`.

### Built-in Tools Reference

| Tool | Permission | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawns a subagent in its own context window |
| `AskUserQuestion` | No | Asks multiple-choice questions for clarification |
| `Bash` | Yes | Executes shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Session-scoped scheduled tasks |
| `Edit` | Yes | Targeted exact-string replacement in files |
| `EnterPlanMode` / `ExitPlanMode` | No/Yes | Switch to/from plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Create/exit isolated git worktrees |
| `Glob` | No | Find files by name pattern (100-file cap) |
| `Grep` | No | Search file contents (ripgrep regex, respects .gitignore) |
| `LSP` | No | Code intelligence (definitions, references, diagnostics) — requires a code intelligence plugin |
| `Monitor` | Yes | Watch a command in background and react to output lines |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells by `cell_id` |
| `PowerShell` | Yes | Execute PowerShell commands (opt-in on Linux/macOS, opt-out on Windows) |
| `PushNotification` | No | Send desktop/phone notification |
| `Read` | No | Read file contents (also images, PDFs, .ipynb) |
| `Skill` | Yes | Execute a skill in the main conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Manage session task checklist |
| `ToolSearch` | No | Search and load deferred MCP tools |
| `WebFetch` | Yes | Fetch URL content, converted to Markdown via extraction model |
| `WebSearch` | Yes | Run web search, returns titles + URLs (not page content) |
| `Write` | Yes | Create or overwrite a file |

**Permission rule formats:**

| Format | Applies to |
| :--- | :--- |
| `Bash(npm run *)` | Bash, Monitor (command pattern) |
| `PowerShell(Get-ChildItem *)` | PowerShell |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP (path pattern) |
| `Edit(/src/**)` | Edit, Write, NotebookEdit (path pattern) |
| `Skill(deploy *)` | Skill (skill name pattern) |
| `Agent(Explore)` | Agent (subagent type) |
| `WebFetch(domain:example.com)` | WebFetch (domain) |
| `WebSearch` | WebSearch (bare name only) |

**Tool behavior notes:**
- **Bash**: `cd` inside a session carries over within project/add-dir boundaries; env vars do not persist. Default timeout: 2 min (max 10 min). Output cap: 30,000 chars.
- **Edit**: requires read-before-edit in current conversation; `old_string` must be unique (or use `replace_all`).
- **Glob**: does not respect `.gitignore` by default (set `CLAUDE_CODE_GLOB_NO_IGNORE=false` to change). Results capped at 100.
- **Grep**: uses ripgrep regex. Modes: `files_with_matches` (default), `content`, `count`. Respects `.gitignore`.
- **WebFetch**: lossy — runs extraction prompt on page; responses cached 15 min; auto-upgrades HTTP to HTTPS.
- **WebSearch**: up to 8 backend searches per call; use `allowed_domains`/`blocked_domains` (not both).
- **Monitor**: requires v2.1.98+; not available on Bedrock/Vertex/Foundry.
- **NotebookEdit**: modes `replace` (default), `insert`, `delete`. Uses `Edit(...)` path rules.
- **Write**: existing files must be read before overwriting.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — all launch commands, every CLI flag, system prompt flags
- [Commands](references/claude-code-commands.md) — every slash command and bundled skill with full descriptions
- [Interactive mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, Vim editor mode, command history, background bash, shell mode, prompt suggestions, /btw, task list, session recap, PR review status
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) — configuration file format, all contexts, all actions with defaults, keystroke syntax, unbinding, reserved shortcuts, vim mode interaction
- [Configure your terminal](references/claude-code-terminal-config.md) — multiline input, Option key on macOS, terminal bell/notifications, tmux config, color themes, fullscreen rendering, Vim mode
- [Tools reference](references/claude-code-tools-reference.md) — all built-in tools, permission rule formats, per-tool behavior details (Bash, Edit, Glob, Grep, LSP, Monitor, NotebookEdit, PowerShell, Read, WebFetch, WebSearch, Write)

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure your terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
