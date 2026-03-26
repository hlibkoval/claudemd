---
name: cli-doc
description: Complete documentation for Claude Code CLI -- command-line interface reference, flags, built-in commands, interactive mode, keyboard shortcuts, keybindings customization, terminal configuration, tools reference. Covers CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude mcp, claude plugin, claude remote-control), all CLI flags (--add-dir, --agent, --agents, --allowedTools, --append-system-prompt, --bare, --chrome, --continue, --dangerously-skip-permissions, --debug, --disable-slash-commands, --disallowedTools, --effort, --fallback-model, --fork-session, --from-pr, --ide, --init, --input-format, --json-schema, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --no-session-persistence, --output-format, --enable-auto-mode, --permission-mode, --permission-prompt-tool, --plugin-dir, --print, --remote, --remote-control, --resume, --session-id, --setting-sources, --settings, --strict-mcp-config, --system-prompt, --system-prompt-file, --append-system-prompt-file, --teleport, --teammate-mode, --tools, --verbose, --version, --worktree), system prompt flags (--system-prompt, --system-prompt-file, --append-system-prompt, --append-system-prompt-file), built-in slash commands (/add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /branch, /help, /hooks, /ide, /init, /insights, /install-github-app, /install-slack-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /model, /passes, /permissions, /plan, /plugin, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /review, /rewind, /sandbox, /schedule, /security-review, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim, /voice), keyboard shortcuts (Ctrl+C, Ctrl+D, Ctrl+G, Ctrl+L, Ctrl+O, Ctrl+R, Ctrl+V, Ctrl+B, Ctrl+T, Shift+Tab, Alt+P, Alt+T, Alt+O), text editing shortcuts (Ctrl+K, Ctrl+U, Ctrl+Y, Alt+Y, Alt+B, Alt+F), multiline input (backslash-Enter, Option+Enter, Shift+Enter, Ctrl+J), vim mode (mode switching, navigation, editing, text objects, yank/paste), command history (per-directory, Ctrl+R reverse search), bash mode (! prefix), prompt suggestions, /btw side questions, task list (Ctrl+T), PR review status, keybindings customization (~/.claude/keybindings.json, contexts, actions, chords, keystroke syntax, unbinding, reserved shortcuts, vim mode interaction), terminal configuration (themes, line breaks, Shift+Enter setup, notifications, vim mode, large inputs), tools reference (Agent, AskUserQuestion, Bash, CronCreate, CronDelete, CronList, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, PowerShell, Read, ReadMcpResourceTool, Skill, TaskCreate, TaskGet, TaskList, TaskOutput, TaskStop, TaskUpdate, TodoWrite, ToolSearch, WebFetch, WebSearch, Write), Bash tool behavior (working directory persistence, environment variable non-persistence, CLAUDE_ENV_FILE, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR), PowerShell tool (CLAUDE_CODE_USE_POWERSHELL_TOOL, defaultShell, shell field, preview limitations), background bash commands (Ctrl+B, task IDs, 5GB output limit, CLAUDE_CODE_DISABLE_BACKGROUND_TASKS). Load when discussing CLI commands, CLI flags, slash commands, built-in commands, keyboard shortcuts, keybindings, interactive mode, vim mode, terminal setup, tools reference, bash tool, PowerShell tool, background tasks, prompt suggestions, side questions, /btw, task list, PR review status, command history, multiline input, or any CLI/interactive-mode topic for Claude Code.
user-invocable: false
---

# CLI & Interactive Mode Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, built-in commands, interactive mode, keyboard shortcuts, keybindings customization, terminal configuration, and tools reference.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive), then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (`--email`, `--sso`, `--console` flags) |
| `claude auth logout` | Log out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List all configured subagents |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins (alias: `claude plugins`) |
| `claude remote-control` | Start Remote Control server |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `--add-dir` | Add additional working directories |
| `--agent` | Specify an agent for the session |
| `--agents` | Define custom subagents via JSON |
| `--allowedTools` | Tools that execute without permission prompts |
| `--append-system-prompt` | Append to default system prompt |
| `--bare` | Minimal mode: skip auto-discovery for faster startup |
| `--chrome` | Enable Chrome browser integration |
| `--continue`, `-c` | Continue most recent conversation |
| `--dangerously-skip-permissions` | Skip permission prompts |
| `--debug` | Debug mode with optional category filter |
| `--disallowedTools` | Tools removed from model context |
| `--effort` | Set effort level (`low`, `medium`, `high`, `max`) |
| `--enable-auto-mode` | Unlock auto mode in Shift+Tab cycle |
| `--fallback-model` | Fallback model when default is overloaded (print mode) |
| `--json-schema` | Get validated JSON output matching schema (print mode) |
| `--max-budget-usd` | Maximum dollar spend (print mode) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--mcp-config` | Load MCP servers from JSON files |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--name`, `-n` | Set session display name |
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--permission-mode` | Start in specified permission mode |
| `--plugin-dir` | Load plugins from directory |
| `--print`, `-p` | Non-interactive print mode |
| `--remote` | Create new web session on claude.ai |
| `--remote-control`, `--rc` | Interactive session with Remote Control |
| `--resume`, `-r` | Resume specific session by ID or name |
| `--system-prompt` | Replace entire system prompt |
| `--system-prompt-file` | Replace system prompt with file contents |
| `--tools` | Restrict available tools (`""` none, `"default"` all, or names) |
| `--worktree`, `-w` | Start in isolated git worktree |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either.

### Built-in Slash Commands

| Command | Purpose |
|:--------|:--------|
| `/add-dir <path>` | Add working directory to session |
| `/agents` | Manage agent configurations |
| `/btw <question>` | Side question without adding to conversation |
| `/chrome` | Configure Chrome settings |
| `/clear` | Clear conversation history (aliases: `/reset`, `/new`) |
| `/color [color]` | Set prompt bar color |
| `/compact [instructions]` | Compact conversation |
| `/config` | Open settings (alias: `/settings`) |
| `/context` | Visualize context usage |
| `/copy [N]` | Copy last response to clipboard |
| `/cost` | Show token usage |
| `/desktop` | Continue in Desktop app (alias: `/app`) |
| `/diff` | Interactive diff viewer |
| `/doctor` | Diagnose installation |
| `/effort [level]` | Set effort level |
| `/export [filename]` | Export conversation as text |
| `/fast [on\|off]` | Toggle fast mode |
| `/help` | Show help |
| `/hooks` | View hook configurations |
| `/init` | Initialize project CLAUDE.md |
| `/keybindings` | Open keybindings config |
| `/mcp` | Manage MCP servers |
| `/memory` | Edit CLAUDE.md memory files |
| `/model [model]` | Change model |
| `/permissions` | View/update permissions (alias: `/allowed-tools`) |
| `/plan [desc]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/release-notes` | View changelog |
| `/remote-control` | Enable remote control (alias: `/rc`) |
| `/rename [name]` | Rename session |
| `/resume [session]` | Resume conversation (alias: `/continue`) |
| `/rewind` | Rewind conversation/code (alias: `/checkpoint`) |
| `/sandbox` | Toggle sandbox mode |
| `/schedule [desc]` | Manage cloud scheduled tasks |
| `/security-review` | Analyze branch for security vulnerabilities |
| `/skills` | List available skills |
| `/stats` | Visualize usage and streaks |
| `/status` | Show version, model, account |
| `/statusline` | Configure status line |
| `/tasks` | List background tasks |
| `/terminal-setup` | Configure Shift+Enter for terminal |
| `/theme` | Change color theme |
| `/vim` | Toggle vim editing mode |
| `/voice` | Toggle voice dictation |

### Keyboard Shortcuts

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Cancel current input/generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open in external editor |
| `Ctrl+L` | Clear terminal screen |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search history |
| `Ctrl+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks |
| `Ctrl+T` | Toggle task list |
| `Shift+Tab` | Cycle permission modes |
| `Alt+P` | Switch model |
| `Alt+T` | Toggle extended thinking |
| `Alt+O` | Toggle fast mode |
| `Esc Esc` | Rewind or summarize |

### Multiline Input

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + `Enter` |
| macOS default | `Option+Enter` |
| Shift+Enter | Works in iTerm2, WezTerm, Ghostty, Kitty |
| Control sequence | `Ctrl+J` |

Run `/terminal-setup` for VS Code, Alacritty, Zed, and Warp.

### Keybindings Customization

File: `~/.claude/keybindings.json`. Run `/keybindings` to create/open. Changes auto-detected.

**Contexts**: Global, Chat, Autocomplete, Settings, Confirmation, Tabs, Help, Transcript, HistorySearch, Task, ThemePicker, Attachments, Footer, MessageSelector, DiffDialog, ModelPicker, Select, Plugin

**Key actions**: `chat:submit`, `chat:cancel`, `chat:cycleMode`, `chat:modelPicker`, `chat:fastMode`, `chat:thinkingToggle`, `chat:externalEditor`, `chat:stash`, `chat:imagePaste`, `app:interrupt`, `app:exit`, `app:toggleTodos`, `app:toggleTranscript`, `history:search`

**Reserved (cannot rebind)**: `Ctrl+C`, `Ctrl+D`, `Ctrl+M`

**Chord syntax**: `ctrl+k ctrl+s` (space-separated sequences)

### Tools Reference

| Tool | Permission | Description |
|:-----|:-----------|:------------|
| `Agent` | No | Spawn subagent with own context |
| `AskUserQuestion` | No | Ask multiple-choice questions |
| `Bash` | Yes | Execute shell commands |
| `CronCreate` | No | Schedule recurring prompt in session |
| `Edit` | Yes | Targeted file edits |
| `EnterPlanMode` | No | Switch to plan mode |
| `EnterWorktree` | No | Create isolated git worktree |
| `Glob` | No | Find files by pattern |
| `Grep` | No | Search file contents |
| `LSP` | No | Code intelligence via language servers |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `PowerShell` | Yes | PowerShell commands (Windows, opt-in) |
| `Read` | No | Read file contents |
| `Skill` | Yes | Execute a skill |
| `TaskCreate/Get/List/Update/Stop` | No | Manage background tasks |
| `TodoWrite` | No | Manage session task checklist |
| `ToolSearch` | No | Search/load deferred tools |
| `WebFetch` | Yes | Fetch URL content |
| `WebSearch` | Yes | Web searches |
| `Write` | Yes | Create or overwrite files |

### Bash Tool Behavior

- Working directory persists across commands
- Environment variables do NOT persist between commands
- Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to reset to project dir after each command
- Set `CLAUDE_ENV_FILE` to a shell script for persistent env vars

### PowerShell Tool (Windows, opt-in preview)

Enable: `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. Auto-detects `pwsh.exe` (7+) with fallback to `powershell.exe` (5.1). Limitations: no auto mode, no profile loading, no sandboxing, native Windows only.

### Background Tasks

- Press `Ctrl+B` to background a running command (tmux: press twice)
- Output written to file, retrieved via Read tool
- Auto-cleanup on exit, auto-terminate at 5GB output
- Disable: `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`

### Interactive Features

- **Bash mode**: Prefix with `!` to run shell commands directly
- **Side questions**: `/btw <question>` for quick answers without adding to context
- **Prompt suggestions**: Tab to accept, Enter to accept and submit; disable with `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false`
- **Task list**: `Ctrl+T` to toggle; share across sessions with `CLAUDE_CODE_TASK_LIST_ID`
- **PR review status**: Footer shows PR link with colored underline (green=approved, yellow=pending, red=changes requested)
- **Command history**: Per-directory, Ctrl+R for reverse search

### Vim Mode

Enable with `/vim` or `/config`. Supports: mode switching (`Esc`/`i`/`I`/`a`/`A`/`o`/`O`), navigation (`h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f`/`F`/`t`/`T`), editing (`x`, `dd`/`D`, `dw`/`de`/`db`, `cc`/`C`, `cw`/`ce`/`cb`), yank/paste (`yy`/`Y`, `p`/`P`), text objects (`iw`/`aw`, `i"`/`a"`, `i(`/`a(`, etc.), indentation (`>>`/`<<`), join (`J`), repeat (`.`).

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — Complete CLI commands table, all flags with descriptions and examples, system prompt flags
- [Built-in Commands](references/claude-code-commands.md) — All slash commands with descriptions, MCP prompts
- [Interactive Mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, text editing, multiline input, vim mode, command history, background tasks, bash mode, prompt suggestions, /btw side questions, task list, PR status
- [Keybindings](references/claude-code-keybindings.md) — Customizable keybindings config, all contexts and actions, keystroke syntax, chords, reserved shortcuts, vim interaction
- [Terminal Configuration](references/claude-code-terminal-config.md) — Themes, line breaks, Shift+Enter setup, notifications, vim mode, large inputs
- [Tools Reference](references/claude-code-tools-reference.md) — All built-in tools with permission requirements, Bash tool behavior, PowerShell tool

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Built-in Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
