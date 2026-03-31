---
name: cli-doc
description: Complete documentation for Claude Code CLI -- covering the CLI reference (all commands like claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude auto-mode, claude mcp, claude plugin, claude remote-control), all CLI flags (--add-dir, --agent, --agents, --allowedTools, --append-system-prompt, --append-system-prompt-file, --bare, --betas, --channels, --chrome, --continue, --dangerously-skip-permissions, --debug, --disable-slash-commands, --disallowedTools, --effort, --fallback-model, --fork-session, --from-pr, --ide, --init, --input-format, --json-schema, --maintenance, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --no-chrome, --no-session-persistence, --output-format, --enable-auto-mode, --permission-mode, --permission-prompt-tool, --plugin-dir, --print, --remote, --remote-control, --resume, --session-id, --setting-sources, --settings, --strict-mcp-config, --system-prompt, --system-prompt-file, --teleport, --teammate-mode, --tools, --verbose, --version, --worktree, --tmux), system prompt flags (--system-prompt vs --append-system-prompt behavior), built-in slash commands (complete /command reference including /add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /branch, /help, /hooks, /ide, /init, /insights, /install-github-app, /install-slack-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /model, /passes, /permissions, /plan, /plugin, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /rewind, /sandbox, /schedule, /security-review, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim, /voice), interactive mode (keyboard shortcuts for general controls/text editing/multiline input/quick commands, vim editor mode with all motions/operators/text objects, command history with reverse search Ctrl+R, background bash commands with Ctrl+B, bash mode with prefix, prompt suggestions, side questions /btw, task list Ctrl+T, PR review status in footer), keybindings customization (~/.claude/keybindings.json with bindings array, contexts Global/Chat/Autocomplete/Settings/Confirmation/Tabs/Help/Transcript/HistorySearch/Task/ThemePicker/Attachments/Footer/MessageSelector/DiffDialog/ModelPicker/Select/Plugin/Settings, all actions like app:interrupt/chat:submit/chat:cycleMode/chat:modelPicker/chat:externalEditor/voice:pushToTalk, keystroke syntax modifiers/chords/special keys, unbinding with null, reserved shortcuts Ctrl+C/Ctrl+D/Ctrl+M, terminal conflicts Ctrl+B/Ctrl+A/Ctrl+Z, vim mode interaction, validation with /doctor), terminal configuration (themes, line breaks Shift+Enter setup, notification setup for iTerm2/Kitty/Ghostty with tmux passthrough, notification hooks, reduce flicker with CLAUDE_CODE_NO_FLICKER, handling large inputs, vim mode setup), tools reference (all built-in tools Agent/AskUserQuestion/Bash/CronCreate/CronDelete/CronList/Edit/EnterPlanMode/EnterWorktree/ExitPlanMode/ExitWorktree/Glob/Grep/ListMcpResourcesTool/LSP/NotebookEdit/PowerShell/Read/ReadMcpResourceTool/Skill/TaskCreate/TaskGet/TaskList/TaskOutput/TaskStop/TaskUpdate/TodoWrite/ToolSearch/WebFetch/WebSearch/Write with permission requirements, Bash tool behavior with working directory persistence and env var non-persistence and CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR and CLAUDE_ENV_FILE, PowerShell tool opt-in preview with CLAUDE_CODE_USE_POWERSHELL_TOOL and defaultShell/shell settings and preview limitations). Load when discussing Claude Code CLI commands, CLI flags, slash commands, keyboard shortcuts, interactive mode, keybindings customization, terminal setup, vim mode, command history, background tasks, bash mode, prompt suggestions, side questions /btw, task list, tools reference, built-in tools, Bash tool, PowerShell tool, permission requirements for tools, system prompt flags, print mode, output format, or any CLI-related topic for Claude Code.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface -- covering CLI commands and flags, built-in slash commands, interactive mode features, keyboard shortcuts, keybinding customization, terminal configuration, and the built-in tools reference.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode: query and exit (SDK/headless use) |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -c -p "query"` | Continue via SDK (print mode) |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (`--email`, `--sso`, `--console` options) |
| `claude auth logout` | Log out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List all configured subagents |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins (alias: `claude plugins`) |
| `claude remote-control` | Start Remote Control server |

### Key CLI Flags

**Session management:**

| Flag | Description |
|:-----|:------------|
| `--continue`, `-c` | Load most recent conversation |
| `--resume`, `-r` | Resume specific session by ID or name |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a GitHub PR |
| `--name`, `-n` | Set session display name |
| `--session-id` | Use specific session UUID |

**Model and execution:**

| Flag | Description |
|:-----|:------------|
| `--model` | Set model (alias like `sonnet`/`opus` or full name) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `max` (Opus 4.6 only) |
| `--print`, `-p` | Print mode -- query and exit |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Maximum spend before stopping (print mode) |
| `--fallback-model` | Auto-fallback when default model overloaded (print mode) |
| `--json-schema` | Get validated JSON output matching a schema (print mode) |
| `--output-format` | Output format: `text`, `json`, `stream-json` (print mode) |
| `--input-format` | Input format: `text`, `stream-json` (print mode) |

**Permissions and tools:**

| Flag | Description |
|:-----|:------------|
| `--permission-mode` | Start in mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--enable-auto-mode` | Unlock auto mode in Shift+Tab cycle |
| `--dangerously-skip-permissions` | Skip permission prompts (equivalent to `--permission-mode bypassPermissions`) |
| `--allow-dangerously-skip-permissions` | Add `bypassPermissions` to cycle without starting in it |
| `--allowedTools` | Tools that execute without permission prompting |
| `--disallowedTools` | Tools removed from model context entirely |
| `--tools` | Restrict available built-in tools (`""` for none, `"default"` for all) |
| `--permission-prompt-tool` | MCP tool to handle permission prompts non-interactively |

**System prompt:**

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag. For most use cases, use append to preserve built-in capabilities.

**Configuration and environment:**

| Flag | Description |
|:-----|:------------|
| `--add-dir` | Add additional working directories |
| `--agent` | Specify agent for current session |
| `--agents` | Define custom subagents via JSON |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, memory, CLAUDE.md |
| `--mcp-config` | Load MCP servers from JSON files |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config` |
| `--plugin-dir` | Load plugins from directory (repeatable) |
| `--settings` | Path to additional settings JSON |
| `--setting-sources` | Comma-separated sources: `user`, `project`, `local` |
| `--debug` | Debug mode with optional category filter (e.g., `"api,hooks"`) |
| `--verbose` | Full turn-by-turn output |
| `--disable-slash-commands` | Disable all skills and commands |

**Remote and collaboration:**

| Flag | Description |
|:-----|:------------|
| `--remote` | Create web session on claude.ai |
| `--remote-control`, `--rc` | Start session with Remote Control enabled |
| `--teleport` | Resume web session in local terminal |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--tmux` | Create tmux session for worktree |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, `tmux` |
| `--ide` | Auto-connect to IDE on startup |
| `--chrome` / `--no-chrome` | Enable/disable Chrome browser integration |
| `--channels` | MCP channel notifications to listen for |

### Built-in Slash Commands (Highlights)

| Command | Purpose |
|:--------|:--------|
| `/clear` | Clear conversation history and free context (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Compact conversation with optional focus |
| `/config` | Open settings interface (alias: `/settings`) |
| `/context` | Visualize current context usage as colored grid |
| `/copy [N]` | Copy assistant response to clipboard (interactive picker for code blocks) |
| `/cost` | Show token usage statistics |
| `/diff` | Interactive diff viewer for uncommitted and per-turn changes |
| `/doctor` | Diagnose installation and settings |
| `/effort [level]` | Set effort level (`low`/`medium`/`high`/`max`/`auto`) |
| `/export [filename]` | Export conversation as plain text |
| `/model [model]` | Select or change model (left/right for effort) |
| `/plan [description]` | Enter plan mode directly |
| `/permissions` | View or update permissions (alias: `/allowed-tools`) |
| `/resume [session]` | Resume conversation by ID/name or open picker (alias: `/continue`) |
| `/rewind` | Rewind conversation and/or code (alias: `/checkpoint`) |
| `/btw <question>` | Side question without adding to conversation |
| `/memory` | Edit CLAUDE.md, manage auto-memory |
| `/mcp` | Manage MCP server connections |
| `/plugin` | Manage plugins |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/remote-control` | Make session available for remote control (alias: `/rc`) |
| `/schedule [description]` | Create/manage Cloud scheduled tasks |
| `/security-review` | Analyze pending changes for security vulnerabilities |
| `/vim` | Toggle vim/normal editing modes |
| `/voice` | Toggle push-to-talk voice dictation |
| `/color [color]` | Set prompt bar color for session |
| `/rename [name]` | Rename session and show on prompt bar |
| `/statusline` | Configure status line |

### Keyboard Shortcuts

**General controls:**

| Shortcut | Action |
|:---------|:-------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+L` | Clear terminal screen (keeps history) |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open in external text editor |
| `Ctrl+V` / `Cmd+V` / `Alt+V` | Paste image from clipboard |
| `Shift+Tab` | Cycle permission modes |
| `Alt+P` / `Option+P` | Switch model |
| `Alt+T` / `Option+T` | Toggle extended thinking |
| `Alt+O` / `Option+O` | Toggle fast mode |
| `Esc Esc` | Rewind or summarize |

**Multiline input:**

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + `Enter` (all terminals) |
| macOS default | `Option+Enter` |
| Shift+Enter | Works natively in iTerm2, WezTerm, Ghostty, Kitty; run `/terminal-setup` for others |
| Control sequence | `Ctrl+J` |

**Quick commands:** `/` at start for commands/skills, `!` at start for bash mode, `@` for file path autocomplete.

### Keybinding Customization

Config file: `~/.claude/keybindings.json` (create/open with `/keybindings`). Changes auto-detected without restart.

**Structure:**

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

**Contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`

**Key actions:**

| Action | Default | Context |
|:-------|:--------|:--------|
| `app:interrupt` | Ctrl+C | Global |
| `app:exit` | Ctrl+D | Global |
| `app:toggleTodos` | Ctrl+T | Global |
| `app:toggleTranscript` | Ctrl+O | Global |
| `chat:submit` | Enter | Chat |
| `chat:cycleMode` | Shift+Tab | Chat |
| `chat:modelPicker` | Cmd+P / Meta+P | Chat |
| `chat:externalEditor` | Ctrl+G, Ctrl+X Ctrl+E | Chat |
| `chat:newline` | (unbound) | Chat |
| `voice:pushToTalk` | Space (hold) | Chat (voice enabled) |

Unbind with `null`. Chords use space-separated keys (e.g., `ctrl+k ctrl+s`). Uppercase letter alone implies Shift (e.g., `K` = `shift+k`).

**Reserved (cannot rebind):** Ctrl+C, Ctrl+D, Ctrl+M (identical to Enter in terminals).

### Built-in Tools Reference

| Tool | Permission | Description |
|:-----|:-----------|:------------|
| `Agent` | No | Spawn subagent with own context window |
| `AskUserQuestion` | No | Ask multiple-choice questions |
| `Bash` | Yes | Execute shell commands |
| `CronCreate` | No | Schedule recurring/one-shot prompt in session |
| `CronDelete` | No | Cancel scheduled task by ID |
| `CronList` | No | List scheduled tasks |
| `Edit` | Yes | Targeted edits to files |
| `EnterPlanMode` | No | Switch to plan mode |
| `EnterWorktree` | No | Create isolated git worktree |
| `ExitPlanMode` | Yes | Present plan for approval |
| `ExitWorktree` | No | Exit worktree session |
| `Glob` | No | Find files by pattern |
| `Grep` | No | Search file contents |
| `ListMcpResourcesTool` | No | List MCP resources |
| `LSP` | No | Code intelligence via language servers |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `PowerShell` | Yes | Execute PowerShell commands (Windows, opt-in) |
| `Read` | No | Read file contents |
| `ReadMcpResourceTool` | No | Read MCP resource by URI |
| `Skill` | Yes | Execute a skill |
| `TaskCreate` | No | Create task in task list |
| `TaskGet` | No | Get task details |
| `TaskList` | No | List all tasks |
| `TaskOutput` | No | (Deprecated) Get background task output; prefer `Read` |
| `TaskStop` | No | Kill running background task |
| `TaskUpdate` | No | Update task status/details |
| `TodoWrite` | No | Manage task checklist (non-interactive/Agent SDK mode) |
| `ToolSearch` | No | Search and load deferred tools |
| `WebFetch` | Yes | Fetch content from URL |
| `WebSearch` | Yes | Perform web search |
| `Write` | Yes | Create or overwrite files |

### Bash Tool Behavior

- Working directory persists across commands. Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to reset to project dir each time.
- Environment variables do NOT persist between commands. Use `CLAUDE_ENV_FILE` to point to a shell script, or a SessionStart hook to populate it.
- Activate virtualenv/conda before launching Claude Code.

### PowerShell Tool (Windows, Opt-in Preview)

Enable with `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. Auto-detects `pwsh.exe` (7+) with fallback to `powershell.exe` (5.1). Bash tool remains available alongside.

Additional settings: `"defaultShell": "powershell"` in settings.json routes `!` commands through PowerShell. `"shell": "powershell"` on hooks runs that hook in PowerShell. `shell: powershell` in skill frontmatter runs inline commands in PowerShell.

Preview limitations: no auto mode support, profiles not loaded, no sandboxing, native Windows only (not WSL), Git Bash still required to start Claude Code.

### Terminal Configuration

**Shift+Enter setup:** Run `/terminal-setup` for VS Code, Alacritty, Zed, Warp. Works natively in iTerm2, WezTerm, Ghostty, Kitty.

**Option as Meta (macOS):** Required for Alt shortcuts (Alt+B, Alt+F, Alt+Y, Alt+M, Alt+P).
- iTerm2: Settings > Profiles > Keys > Left/Right Option = "Esc+"
- Terminal.app: Settings > Profiles > Keyboard > "Use Option as Meta Key"
- VS Code: `"terminal.integrated.macOptionIsMeta": true`

**Notifications:** Kitty and Ghostty work without config. iTerm2: enable "Notification Center Alerts" and "Send escape sequence-generated alerts". For tmux: `set -g allow-passthrough on`. Other terminals: use notification hooks.

**Reduce flicker:** `CLAUDE_CODE_NO_FLICKER=1` enables fullscreen rendering with flat memory usage and mouse support.

### Interactive Features

**Background bash commands:** Press `Ctrl+B` to background running commands. Output written to file, retrievable via Read tool. Auto-cleaned on exit, terminated if output exceeds 5GB. Disable with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

**Bash mode (`!` prefix):** Run shell commands directly without Claude interpretation. Adds output to conversation context. Supports `Ctrl+B` backgrounding and history-based Tab autocomplete.

**Prompt suggestions:** Grayed-out suggestions based on git history and conversation. Press Tab to accept, Enter to accept and submit. Disable with `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false`.

**Side questions (`/btw`):** Quick questions answered from current context only, no tool access, ephemeral overlay. Works while Claude is processing. Low cost (reuses prompt cache).

**Task list:** Complex work tracked in status area. Toggle with `Ctrl+T`. Persists across compactions. Share across sessions with `CLAUDE_CODE_TASK_LIST_ID=name`.

**PR review status:** Clickable PR link in footer with colored underline (green=approved, yellow=pending, red=changes requested, gray=draft, purple=merged). Requires `gh` CLI.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) -- All CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth login/logout/status, claude agents, claude auto-mode defaults, claude mcp, claude plugin, claude remote-control), complete CLI flags table (--add-dir, --agent, --agents, --allow-dangerously-skip-permissions, --allowedTools, --append-system-prompt, --append-system-prompt-file, --bare, --betas, --channels, --chrome, --continue, --dangerously-load-development-channels, --dangerously-skip-permissions, --debug, --disable-slash-commands, --disallowedTools, --effort, --enable-auto-mode, --fallback-model, --fork-session, --from-pr, --ide, --init, --init-only, --include-partial-messages, --input-format, --json-schema, --maintenance, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --no-chrome, --no-session-persistence, --output-format, --permission-mode, --permission-prompt-tool, --plugin-dir, --print, --remote, --remote-control, --resume, --session-id, --setting-sources, --settings, --strict-mcp-config, --system-prompt, --system-prompt-file, --teleport, --teammate-mode, --tools, --verbose, --version, --worktree, --tmux), system prompt flags behavior (replace vs append, mutual exclusivity)
- [Built-in Commands](references/claude-code-commands.md) -- Complete reference for all slash commands (/add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /branch, /help, /hooks, /ide, /init, /insights, /install-github-app, /install-slack-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /model, /passes, /permissions, /plan, /plugin, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /review, /rewind, /sandbox, /schedule, /security-review, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim, /voice), MCP prompts as commands (/mcp__server__prompt format)
- [Interactive Mode](references/claude-code-interactive-mode.md) -- Keyboard shortcuts (general controls, text editing, multiline input, quick commands, transcript viewer, voice input), vim editor mode (mode switching, navigation, editing, text objects), command history (per-directory storage, reverse search Ctrl+R), background bash commands (Ctrl+B backgrounding, output handling, 5GB limit, CLAUDE_CODE_DISABLE_BACKGROUND_TASKS), bash mode (exclamation prefix, Tab autocomplete from history), prompt suggestions (git-based, Tab/Enter to accept, CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION), side questions /btw (ephemeral, no tool access, works during processing), task list (Ctrl+T toggle, CLAUDE_CODE_TASK_LIST_ID for shared lists), PR review status (footer link, colored underline states, gh CLI required)
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) -- Keybindings configuration file (~/.claude/keybindings.json), binding blocks by context (Global, Chat, Autocomplete, Settings, Confirmation, Tabs, Help, Transcript, HistorySearch, Task, ThemePicker, Attachments, Footer, MessageSelector, DiffDialog, ModelPicker, Select, Plugin, Settings), all available actions by namespace (app, history, chat, autocomplete, confirm, permission, transcript, historySearch, task, theme, help, tabs, attachments, footer, messageSelector, diff, modelPicker, select, plugin, settings, voice), keystroke syntax (modifiers, uppercase letters, chords, special keys), unbinding with null, reserved shortcuts (Ctrl+C, Ctrl+D, Ctrl+M), terminal conflicts (Ctrl+B tmux, Ctrl+A screen, Ctrl+Z suspend), vim mode interaction, validation with /doctor
- [Optimize Your Terminal Setup](references/claude-code-terminal-config.md) -- Themes and appearance (/config), line breaks (Shift+Enter setup for various terminals, /terminal-setup, Option+Enter for macOS), notification setup (iTerm2, Kitty, Ghostty, tmux passthrough, notification hooks), reduce flicker (CLAUDE_CODE_NO_FLICKER fullscreen rendering), handling large inputs, vim mode (/vim, /config, editorMode setting)
- [Tools Reference](references/claude-code-tools-reference.md) -- Complete built-in tools list with permission requirements (Agent, AskUserQuestion, Bash, CronCreate, CronDelete, CronList, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, PowerShell, Read, ReadMcpResourceTool, Skill, TaskCreate, TaskGet, TaskList, TaskOutput, TaskStop, TaskUpdate, TodoWrite, ToolSearch, WebFetch, WebSearch, Write), Bash tool behavior (working directory persistence, env var non-persistence, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR, CLAUDE_ENV_FILE, SessionStart hook), PowerShell tool (CLAUDE_CODE_USE_POWERSHELL_TOOL opt-in, auto-detection pwsh.exe/powershell.exe, defaultShell/shell settings, preview limitations)

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Built-in Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Optimize Your Terminal Setup: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
