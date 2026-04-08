---
name: cli-doc
description: Complete documentation for the Claude Code CLI -- commands, flags, interactive mode, keybindings, terminal configuration, and built-in tools. Covers CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude auto-mode, claude mcp, claude plugin, claude remote-control), all CLI flags (--add-dir, --agent, --agents, --allowedTools, --append-system-prompt, --bare, --chrome, --continue, --dangerously-skip-permissions, --debug, --disable-slash-commands, --disallowedTools, --effort, --enable-auto-mode, --fallback-model, --fork-session, --from-pr, --ide, --init, --input-format, --json-schema, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --no-session-persistence, --output-format, --permission-mode, --permission-prompt-tool, --plugin-dir, --print, --remote, --remote-control, --resume, --session-id, --settings, --system-prompt, --system-prompt-file, --append-system-prompt-file, --strict-mcp-config, --teleport, --teammate-mode, --tmux, --tools, --verbose, --version, --worktree), system prompt customization flags, built-in slash commands (/add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /fast, /feedback, /branch, /help, /hooks, /ide, /init, /insights, /install-github-app, /keybindings, /login, /logout, /mcp, /memory, /model, /passes, /permissions, /plan, /plugin, /powerup, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /review, /rewind, /sandbox, /schedule, /security-review, /setup-bedrock, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /ultraplan, /upgrade, /usage, /vim, /voice), interactive mode (keyboard shortcuts, Ctrl+C, Ctrl+D, Ctrl+G, Ctrl+L, Ctrl+O, Ctrl+R, Ctrl+V, Ctrl+B, Ctrl+T, Shift+Tab, Alt+P, Alt+T, Alt+O, text editing, multiline input, quick commands, bash mode, prompt suggestions, /btw side questions, task list, PR review status, vim mode, command history, reverse search, background bash commands, transcript viewer), customizable keybindings (keybindings.json, contexts, actions, keystroke syntax, modifiers, chords, special keys, unbinding, reserved shortcuts, terminal conflicts, vim mode interaction), terminal configuration (themes, line breaks, Shift+Enter setup, Option+Enter, notification setup, notification hooks, tmux passthrough, flicker reduction, fullscreen rendering, large inputs, vim mode), built-in tools reference (Agent, AskUserQuestion, Bash, CronCreate, CronDelete, CronList, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, PowerShell, Read, ReadMcpResourceTool, SendMessage, Skill, TaskCreate, TaskGet, TaskList, TaskOutput, TaskStop, TaskUpdate, TeamCreate, TeamDelete, TodoWrite, ToolSearch, WebFetch, WebSearch, Write), Bash tool behavior, LSP tool behavior, PowerShell tool preview. Load when discussing CLI usage, command-line flags, slash commands, interactive mode, keyboard shortcuts, keybindings, terminal setup, built-in tools, tool permissions, or any CLI-related topic for Claude Code.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, including CLI commands and flags, built-in slash commands, interactive mode, keyboard shortcuts, customizable keybindings, terminal configuration, and built-in tools.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:-----------|
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive), then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (`--email`, `--sso`, `--console` flags) |
| `claude auth logout` | Log out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List all configured subagents |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins (alias: `claude plugins`) |
| `claude remote-control` | Start a Remote Control server |

### Key CLI Flags

| Flag | Description |
|:-----|:-----------|
| `--print`, `-p` | Non-interactive print mode |
| `--continue`, `-c` | Continue most recent conversation |
| `--resume`, `-r` | Resume session by ID or name |
| `--model` | Set model (`sonnet`, `opus`, or full model ID) |
| `--effort` | Set effort level (`low`, `medium`, `high`, `max`) |
| `--permission-mode` | Start in a specific mode (`default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`) |
| `--enable-auto-mode` | Unlock auto mode in the Shift+Tab cycle |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, memory, CLAUDE.md |
| `--worktree`, `-w` | Run in an isolated git worktree |
| `--tmux` | Create tmux session for the worktree (requires `--worktree`) |
| `--add-dir` | Add additional working directories |
| `--agent` | Specify agent for the session |
| `--agents` | Define subagents dynamically via JSON |
| `--tools` | Restrict available tools (`""` to disable all, `"default"` for all, or tool names) |
| `--allowedTools` | Tools that execute without permission prompts |
| `--disallowedTools` | Tools removed from model context entirely |
| `--mcp-config` | Load MCP servers from JSON files |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config` |
| `--plugin-dir` | Load plugins from a directory |
| `--name`, `-n` | Set a display name for the session |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to the default system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append file contents to default prompt |
| `--output-format` | Output format for print mode (`text`, `json`, `stream-json`) |
| `--input-format` | Input format for print mode (`text`, `stream-json`) |
| `--json-schema` | Get validated JSON output matching a schema (print mode) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Maximum dollar spend (print mode) |
| `--no-session-persistence` | Don't save session to disk (print mode) |
| `--fallback-model` | Fallback model when default is overloaded (print mode) |
| `--remote` | Create a new web session on claude.ai |
| `--remote-control`, `--rc` | Start interactive session with Remote Control enabled |
| `--teleport` | Resume a web session in local terminal |
| `--chrome` / `--no-chrome` | Enable/disable Chrome browser integration |
| `--debug` | Enable debug mode with optional category filtering |
| `--verbose` | Enable verbose logging |
| `--version`, `-v` | Output version number |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag. Prefer append flags to preserve built-in capabilities.

### Built-in Slash Commands (Selected)

| Command | Purpose |
|:--------|:--------|
| `/clear` | Clear conversation history (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Compact conversation with optional focus instructions |
| `/config` | Open settings interface (alias: `/settings`) |
| `/context` | Visualize current context usage |
| `/copy [N]` | Copy last assistant response to clipboard |
| `/cost` | Show token usage statistics |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/effort [level]` | Set model effort level (`low`, `medium`, `high`, `max`, `auto`) |
| `/export [filename]` | Export conversation as plain text |
| `/fast [on\|off]` | Toggle fast mode |
| `/branch [name]` | Branch the conversation (alias: `/fork`) |
| `/init` | Initialize project with CLAUDE.md |
| `/memory` | Edit CLAUDE.md memory files |
| `/model [model]` | Select or change AI model |
| `/permissions` | Manage tool permission rules (alias: `/allowed-tools`) |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/rename [name]` | Rename current session |
| `/resume [session]` | Resume conversation (alias: `/continue`) |
| `/rewind` | Rewind conversation and/or code (alias: `/checkpoint`) |
| `/schedule [description]` | Create/manage Cloud scheduled tasks |
| `/skills` | List available skills |
| `/status` | Show version, model, account, connectivity |
| `/tasks` | List and manage background tasks (alias: `/bashes`) |
| `/theme` | Change color theme |
| `/ultraplan <prompt>` | Draft and review a plan in the browser |
| `/voice` | Toggle push-to-talk voice dictation |
| `/btw <question>` | Ask a side question without adding to conversation |
| `/add-dir <path>` | Add a working directory for the session |
| `/color [color]` | Set prompt bar color for the session |
| `/doctor` | Diagnose installation and settings |

### Interactive Mode Keyboard Shortcuts

**General controls:**

| Shortcut | Description |
|:---------|:-----------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit Claude Code session |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open in external text editor |
| `Ctrl+L` | Clear prompt input |
| `Ctrl+O` | Toggle verbose output / transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` / `Cmd+V` / `Alt+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Shift+Tab` | Cycle permission modes |
| `Alt+P` | Switch model |
| `Alt+T` | Toggle extended thinking |
| `Alt+O` | Toggle fast mode |
| `Esc Esc` | Rewind or summarize |

**Text editing:**

| Shortcut | Description |
|:---------|:-----------|
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+Y` | Paste deleted text |
| `Alt+Y` | Cycle paste history (after Ctrl+Y) |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

**Multiline input:**

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + Enter |
| macOS default | Option+Enter |
| Shift+Enter | Works in iTerm2, WezTerm, Ghostty, Kitty; run `/terminal-setup` for others |
| Control sequence | Ctrl+J |
| Paste mode | Paste directly (for code blocks, logs) |

**Quick commands:**

| Prefix | Description |
|:-------|:-----------|
| `/` | Slash command or skill |
| `!` | Bash mode -- run shell commands directly |
| `@` | File path mention with autocomplete |

### Bash Mode

Prefix input with `!` to run shell commands directly without Claude interpreting them. Output is added to conversation context. Supports `Ctrl+B` backgrounding and history-based Tab autocomplete.

### Side Questions (/btw)

`/btw <question>` asks a quick question with full conversation visibility but no tool access. Works while Claude is processing. Ephemeral -- never enters conversation history. Low cost (reuses prompt cache).

### Task List

Press `Ctrl+T` to toggle. Shows up to 10 tasks. Persists across compactions. Share across sessions with `CLAUDE_CODE_TASK_LIST_ID=<name>`.

### Prompt Suggestions

Grayed-out suggestions appear after responses. Press Tab/Right to accept, Enter to accept and submit. Disable with `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false`.

### PR Review Status

Colored PR link in footer when on a branch with an open PR (green=approved, yellow=pending, red=changes requested, gray=draft, purple=merged). Requires `gh` CLI. Updates every 60 seconds.

### Customizable Keybindings

Configuration file: `~/.claude/keybindings.json` (open with `/keybindings`). Changes auto-detected without restart.

**Contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`

**Key actions (namespace:action format):**

| Action | Default | Context |
|:-------|:--------|:--------|
| `app:interrupt` | Ctrl+C | Global |
| `app:exit` | Ctrl+D | Global |
| `app:toggleTodos` | Ctrl+T | Global |
| `app:toggleTranscript` | Ctrl+O | Global |
| `chat:submit` | Enter | Chat |
| `chat:cycleMode` | Shift+Tab | Chat |
| `chat:modelPicker` | Cmd+P / Meta+P | Chat |
| `chat:thinkingToggle` | Cmd+T / Meta+T | Chat |
| `chat:fastMode` | Meta+O | Chat |
| `chat:externalEditor` | Ctrl+G, Ctrl+X Ctrl+E | Chat |
| `chat:imagePaste` | Ctrl+V | Chat |
| `chat:newline` | (unbound) | Chat |
| `history:search` | Ctrl+R | -- |
| `task:background` | Ctrl+B | Task |
| `voice:pushToTalk` | Space (hold) | Chat (voice enabled) |

**Keystroke syntax:** modifiers with `+` separator (`ctrl`, `alt`/`opt`, `shift`, `meta`/`cmd`). Chords as space-separated sequences (`ctrl+k ctrl+s`). Uppercase letter implies Shift (e.g., `K` = `shift+k`).

**Reserved (cannot rebind):** Ctrl+C, Ctrl+D, Ctrl+M (same as Enter).

**Unbind:** set action to `null` in the bindings object.

### Terminal Configuration

**Line breaks:** `\` + Enter (any terminal), Ctrl+J, Option+Enter (macOS with Meta configured), Shift+Enter (iTerm2/WezTerm/Ghostty/Kitty natively; `/terminal-setup` for others).

**Option as Meta (macOS):** iTerm2: Profiles > Keys > "Esc+". Terminal.app: Profiles > Keyboard > "Use Option as Meta Key". VS Code: `"terminal.integrated.macOptionIsMeta": true`.

**Notifications:** Kitty/Ghostty work natively. iTerm2: enable "Notification Center Alerts" + "Send escape sequence-generated alerts". tmux: `set -g allow-passthrough on`. Other terminals: use notification hooks.

**Reduce flicker:** `CLAUDE_CODE_NO_FLICKER=1` for fullscreen rendering.

**Vim mode:** Enable via `/config` > Editor mode. Supports mode switching (i/I/a/A/o/O/Esc), navigation (h/j/k/l, w/e/b, 0/$, gg/G, f/F/t/T), editing (x, dd/D, dw/de/db, cc/C, cw/ce/cb, yy/Y, p/P, >>/<<, J, .), and text objects (iw/aw, iW/aW, i"/a", i'/a', i(/a(, i[/a[, i\{/a\{).

### Built-in Tools

| Tool | Permission | Description |
|:-----|:-----------|:-----------|
| `Agent` | No | Spawn a subagent with its own context window |
| `AskUserQuestion` | No | Ask multiple-choice questions |
| `Bash` | Yes | Execute shell commands |
| `CronCreate` | No | Schedule recurring/one-shot prompts in session |
| `CronDelete` | No | Cancel a scheduled task |
| `CronList` | No | List scheduled tasks |
| `Edit` | Yes | Make targeted file edits |
| `EnterPlanMode` | No | Switch to plan mode |
| `EnterWorktree` | No | Create and switch to a git worktree |
| `ExitPlanMode` | Yes | Present plan and exit plan mode |
| `ExitWorktree` | No | Exit worktree, return to original directory |
| `Glob` | No | Find files by pattern matching |
| `Grep` | No | Search for patterns in file contents |
| `ListMcpResourcesTool` | No | List MCP server resources |
| `LSP` | No | Code intelligence (definitions, references, errors) |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `PowerShell` | Yes | Execute PowerShell commands (Windows, opt-in preview) |
| `Read` | No | Read file contents |
| `ReadMcpResourceTool` | No | Read a specific MCP resource by URI |
| `SendMessage` | No | Send message to agent team teammate or resume subagent |
| `Skill` | Yes | Execute a skill in the main conversation |
| `TaskCreate` | No | Create a task in the task list |
| `TaskGet` | No | Retrieve task details |
| `TaskList` | No | List all tasks |
| `TaskStop` | No | Kill a running background task |
| `TaskUpdate` | No | Update task status/details |
| `TeamCreate` | No | Create an agent team |
| `TeamDelete` | No | Disband an agent team |
| `TodoWrite` | No | Manage session task checklist (non-interactive/Agent SDK) |
| `ToolSearch` | No | Search for and load deferred tools |
| `WebFetch` | Yes | Fetch content from a URL |
| `WebSearch` | Yes | Perform web searches |
| `Write` | Yes | Create or overwrite files |

**Bash tool:** Each command runs in a separate process. Working directory persists; environment variables do not. Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to reset to project dir after each command. Use `CLAUDE_ENV_FILE` or a SessionStart hook for persistent env vars.

**LSP tool:** Provides jump-to-definition, find references, type info, symbol listing, implementations, and call hierarchies. Requires a code intelligence plugin. Auto-reports errors after file edits.

**PowerShell tool (Windows preview):** Enable with `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. Auto-detects `pwsh.exe` (7+) or `powershell.exe` (5.1). Use `"defaultShell": "powershell"` in settings for interactive `!` commands. Known limitations: no auto mode, no profiles, no sandboxing, native Windows only.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) -- CLI commands, all flags, and system prompt customization
- [Built-in Commands](references/claude-code-commands.md) -- Complete list of slash commands available in interactive mode
- [Interactive Mode](references/claude-code-interactive-mode.md) -- Keyboard shortcuts, Vim mode, command history, bash mode, prompt suggestions, side questions, task list, and PR review status
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) -- Keybindings configuration file, contexts, actions, keystroke syntax, and reserved shortcuts
- [Terminal Configuration](references/claude-code-terminal-config.md) -- Line breaks, Shift+Enter setup, notifications, flicker reduction, Vim mode, and large input handling
- [Tools Reference](references/claude-code-tools-reference.md) -- Built-in tools, permission requirements, Bash/LSP/PowerShell tool behavior

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Built-in Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
