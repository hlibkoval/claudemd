---
name: cli-doc
description: Complete documentation for Claude Code CLI -- covering the CLI reference (all commands like claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude auto-mode, claude mcp, claude plugin, claude remote-control, and all flags including --add-dir, --agent, --agents, --allowedTools, --append-system-prompt, --bare, --betas, --channels, --chrome, --continue, --dangerously-skip-permissions, --debug, --disallowedTools, --effort, --fallback-model, --fork-session, --from-pr, --ide, --init, --input-format, --json-schema, --maintenance, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --no-session-persistence, --output-format, --enable-auto-mode, --permission-mode, --permission-prompt-tool, --plugin-dir, --print, --remote, --remote-control, --resume, --session-id, --setting-sources, --settings, --strict-mcp-config, --system-prompt, --system-prompt-file, --append-system-prompt-file, --teleport, --teammate-mode, --tools, --verbose, --version, --worktree, --tmux, system prompt flags), built-in commands (complete list of slash commands including /add-dir /agents /btw /chrome /clear /color /compact /config /context /copy /cost /desktop /diff /doctor /effort /exit /export /extra-usage /fast /feedback /branch /help /hooks /ide /init /insights /install-github-app /install-slack-app /keybindings /login /logout /mcp /memory /mobile /model /passes /permissions /plan /plugin /pr-comments /privacy-settings /release-notes /reload-plugins /remote-control /remote-env /rename /resume /rewind /sandbox /schedule /security-review /skills /stats /status /statusline /stickers /tasks /terminal-setup /theme /upgrade /usage /vim /voice, MCP prompts), interactive mode (keyboard shortcuts for general controls Ctrl+C/Ctrl+D/Ctrl+G/Ctrl+L/Ctrl+O/Ctrl+R/Ctrl+V/Ctrl+B/Ctrl+T/Shift+Tab/Alt+P/Alt+T/Alt+O, text editing Ctrl+K/Ctrl+U/Ctrl+Y/Alt+Y/Alt+B/Alt+F, multiline input methods, quick commands / ! @, vim editor mode with mode switching/navigation/editing/text objects, command history with Ctrl+R reverse search, background bash commands with Ctrl+B, bash mode with ! prefix, prompt suggestions, side questions with /btw, task list Ctrl+T, PR review status, transcript viewer Ctrl+E), keybindings (keybindings.json configuration at ~/.claude/keybindings.json, contexts Global/Chat/Autocomplete/Settings/Confirmation/Tabs/Help/Transcript/HistorySearch/Task/ThemePicker/Attachments/Footer/MessageSelector/DiffDialog/ModelPicker/Select/Plugin, all actions organized by namespace app/history/chat/autocomplete/confirm/permission/transcript/historySearch/task/theme/help/tabs/attachments/footer/messageSelector/diff/modelPicker/select/plugin/settings/voice, keystroke syntax with modifiers ctrl/alt/shift/meta and chords and special keys, unbinding defaults with null, reserved shortcuts Ctrl+C/Ctrl+D/Ctrl+M, terminal conflicts Ctrl+B/Ctrl+A/Ctrl+Z, vim mode interaction, validation with /doctor), terminal configuration (themes and appearance, line breaks and Shift+Enter setup for VS Code/Alacritty/Zed/Warp via /terminal-setup, Option+Enter setup for Terminal.app/iTerm2/VS Code, notification setup for Kitty/Ghostty/iTerm2 with tmux passthrough, notification hooks, handling large inputs, vim mode configuration), and tools reference (complete list of all built-in tools Agent/AskUserQuestion/Bash/CronCreate/CronDelete/CronList/Edit/EnterPlanMode/EnterWorktree/ExitPlanMode/ExitWorktree/Glob/Grep/ListMcpResourcesTool/LSP/NotebookEdit/PowerShell/Read/ReadMcpResourceTool/Skill/TaskCreate/TaskGet/TaskList/TaskOutput/TaskStop/TaskUpdate/TodoWrite/ToolSearch/WebFetch/WebSearch/Write with permission requirements, Bash tool behavior with working directory persistence and environment variable handling and CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR and CLAUDE_ENV_FILE, PowerShell tool opt-in preview with CLAUDE_CODE_USE_POWERSHELL_TOOL and shell selection in settings/hooks/skills and preview limitations). Load when discussing Claude Code CLI usage, command-line flags, slash commands, built-in commands, interactive mode, keyboard shortcuts, keybindings, vim mode, terminal setup, terminal configuration, Shift+Enter, notification setup, tools reference, tool permissions, Bash tool, PowerShell tool, background tasks, bash mode, prompt suggestions, /btw side questions, task list, PR review status, transcript viewer, command history, multiline input, system prompt flags, or any CLI-related topic for Claude Code.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for Claude Code's command-line interface -- covering the CLI reference, built-in commands, interactive mode, keybindings, terminal configuration, and tools reference.

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
| `claude auth login` | Sign in (use `--console` for API billing) |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List configured subagents |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins (alias: `claude plugins`) |
| `claude remote-control` | Start Remote Control server |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Continue most recent conversation |
| `-r`, `--resume` | Resume specific session by ID or name |
| `-n`, `--name` | Set session display name |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `max` |
| `--bare` | Minimal mode, skip auto-discovery for faster startup |
| `--add-dir` | Add additional working directories |
| `--agent` | Specify agent for session |
| `--agents` | Define custom subagents via JSON |
| `--allowedTools` | Tools that skip permission prompts |
| `--disallowedTools` | Tools removed from model context |
| `--tools` | Restrict available built-in tools |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append file contents to prompt |
| `--mcp-config` | Load MCP servers from JSON |
| `--strict-mcp-config` | Only use MCP from `--mcp-config` |
| `--plugin-dir` | Load plugins from directory |
| `--permission-mode` | Begin in specified permission mode |
| `--enable-auto-mode` | Unlock auto mode in Shift+Tab cycle |
| `--dangerously-skip-permissions` | Skip permission prompts |
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--input-format` | Input format: `text`, `stream-json` |
| `--json-schema` | Get validated JSON output matching schema |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Max API spend before stopping (print mode) |
| `--fallback-model` | Fallback model when default overloaded |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--tmux` | Create tmux session for worktree |
| `--remote` | Create web session on claude.ai |
| `--remote-control`, `--rc` | Interactive session with Remote Control |
| `--teleport` | Resume web session locally |
| `--chrome` | Enable Chrome browser integration |
| `--from-pr` | Resume sessions linked to a GitHub PR |
| `--debug` | Debug mode with optional category filter |
| `--verbose` | Full turn-by-turn output |
| `-v`, `--version` | Show version |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either.

### Built-in Slash Commands (Highlights)

| Command | Purpose |
|:--------|:--------|
| `/clear` | Clear conversation history (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Compact conversation with optional focus |
| `/config` | Open settings interface (alias: `/settings`) |
| `/context` | Visualize context usage |
| `/copy [N]` | Copy assistant response to clipboard |
| `/cost` | Show token usage statistics |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings |
| `/effort [level]` | Set model effort level |
| `/export [filename]` | Export conversation as plain text |
| `/fast [on\|off]` | Toggle fast mode |
| `/branch [name]` | Branch conversation (alias: `/fork`) |
| `/init` | Initialize project with CLAUDE.md |
| `/memory` | Edit CLAUDE.md memory files |
| `/model [model]` | Select or change AI model |
| `/permissions` | View or update permissions (alias: `/allowed-tools`) |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/resume [session]` | Resume conversation (alias: `/continue`) |
| `/rewind` | Rewind conversation/code (alias: `/checkpoint`) |
| `/schedule [description]` | Create cloud scheduled tasks |
| `/skills` | List available skills |
| `/vim` | Toggle vim editing mode |
| `/voice` | Toggle push-to-talk voice dictation |
| `/btw <question>` | Side question without adding to conversation |
| `/color [color]` | Set prompt bar color for session |
| `/rename [name]` | Rename session and show on prompt bar |

### Keyboard Shortcuts

**General controls:**

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open in external text editor |
| `Ctrl+L` | Clear terminal screen |
| `Ctrl+O` | Toggle verbose output / transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` / `Cmd+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Shift+Tab` | Cycle permission modes |
| `Alt+P` | Switch model |
| `Alt+T` | Toggle extended thinking |
| `Alt+O` | Toggle fast mode |
| `Esc Esc` | Rewind or summarize |

**Text editing:**

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete to start of line |
| `Ctrl+Y` | Paste deleted text |
| `Alt+Y` | Cycle paste history (after Ctrl+Y) |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

**Multiline input:**

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + Enter |
| macOS default | Option+Enter |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty |
| Control sequence | Ctrl+J |

**Quick commands:** `/` for commands/skills, `!` for bash mode, `@` for file path mention.

### Keybindings Configuration

File: `~/.claude/keybindings.json` (create/open with `/keybindings`). Changes auto-detected without restart.

**Contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`

**Key actions by namespace:**

| Action | Default | Description |
|:-------|:--------|:------------|
| `app:interrupt` | Ctrl+C | Cancel operation |
| `app:exit` | Ctrl+D | Exit Claude Code |
| `app:toggleTodos` | Ctrl+T | Toggle task list |
| `app:toggleTranscript` | Ctrl+O | Toggle verbose transcript |
| `chat:submit` | Enter | Submit message |
| `chat:newline` | (unbound) | Insert newline |
| `chat:cycleMode` | Shift+Tab | Cycle permission modes |
| `chat:modelPicker` | Cmd+P / Meta+P | Open model picker |
| `chat:externalEditor` | Ctrl+G | Open in editor |
| `chat:imagePaste` | Ctrl+V | Paste image |
| `voice:pushToTalk` | Space (hold) | Dictate prompt |

**Keystroke syntax:** Modifiers with `+` (`ctrl+k`, `shift+tab`, `meta+p`). Chords separated by spaces (`ctrl+k ctrl+s`). Uppercase letter implies Shift (`K` = `shift+k`).

**Reserved (cannot rebind):** Ctrl+C, Ctrl+D, Ctrl+M (identical to Enter).

**Unbind:** Set action to `null` in config.

### Tools Reference

| Tool | Description | Permission |
|:-----|:------------|:-----------|
| `Agent` | Spawn subagent with own context | No |
| `AskUserQuestion` | Ask multiple-choice questions | No |
| `Bash` | Execute shell commands | Yes |
| `CronCreate/Delete/List` | Manage scheduled tasks in session | No |
| `Edit` | Targeted file edits | Yes |
| `EnterPlanMode` | Switch to plan mode | No |
| `EnterWorktree/ExitWorktree` | Manage git worktrees | No |
| `ExitPlanMode` | Present plan for approval | Yes |
| `Glob` | Find files by pattern | No |
| `Grep` | Search file contents | No |
| `ListMcpResourcesTool` | List MCP resources | No |
| `LSP` | Code intelligence via language servers | No |
| `NotebookEdit` | Modify Jupyter cells | Yes |
| `PowerShell` | Execute PowerShell (Windows, opt-in) | Yes |
| `Read` | Read file contents | No |
| `ReadMcpResourceTool` | Read MCP resource by URI | No |
| `Skill` | Execute a skill | Yes |
| `TaskCreate/Get/List/Update/Stop` | Manage task list | No |
| `TodoWrite` | Session task checklist (non-interactive) | No |
| `ToolSearch` | Search and load deferred tools | No |
| `WebFetch` | Fetch URL content | Yes |
| `WebSearch` | Perform web searches | Yes |
| `Write` | Create or overwrite files | Yes |

**Bash tool behavior:** Working directory persists across commands. Environment variables do NOT persist. Activate virtualenvs before launching Claude Code. Use `CLAUDE_ENV_FILE` or a SessionStart hook for persistent env vars. Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to reset cwd after each command.

**PowerShell tool (Windows, opt-in):** Enable with `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. Auto-detects `pwsh.exe` (7+) with fallback to `powershell.exe` (5.1). Additional settings: `"defaultShell": "powershell"` in settings.json, `"shell": "powershell"` on hooks, `shell: powershell` in skill frontmatter. Preview limitations: no auto mode, no profiles, no sandboxing, Windows-only (not WSL), Git Bash still required to start.

### Terminal Configuration

**Shift+Enter setup:** Native in iTerm2, WezTerm, Ghostty, Kitty. For VS Code, Alacritty, Zed, Warp: run `/terminal-setup`.

**Option as Meta (macOS):** Required for Alt+key shortcuts.
- iTerm2: Settings > Profiles > Keys > Left/Right Option = "Esc+"
- Terminal.app: Settings > Profiles > Keyboard > "Use Option as Meta Key"
- VS Code: `"terminal.integrated.macOptionIsMeta": true`

**Notifications:** Kitty and Ghostty work natively. iTerm2: Settings > Profiles > Terminal > enable "Notification Center Alerts" > Filter > check "Send escape sequence-generated alerts". tmux requires `set -g allow-passthrough on`. Other terminals: use notification hooks.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) -- All CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude auto-mode, claude mcp, claude plugin, claude remote-control) and all flags (--add-dir, --agent, --agents, --allowedTools, --append-system-prompt, --bare, --betas, --channels, --chrome, --continue, --dangerously-skip-permissions, --debug, --disallowedTools, --effort, --fallback-model, --fork-session, --from-pr, --ide, --init, --input-format, --json-schema, --maintenance, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --output-format, --enable-auto-mode, --permission-mode, --plugin-dir, --print, --remote, --resume, --session-id, --settings, --system-prompt, --teleport, --teammate-mode, --tools, --verbose, --version, --worktree, --tmux), system prompt flags
- [Built-in Commands](references/claude-code-commands.md) -- Complete list of slash commands (/add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /branch, /help, /hooks, /ide, /init, /insights, /install-github-app, /install-slack-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /model, /passes, /permissions, /plan, /plugin, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /rewind, /sandbox, /schedule, /security-review, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim, /voice), MCP prompts
- [Interactive Mode](references/claude-code-interactive-mode.md) -- Keyboard shortcuts (general controls, text editing, multiline input, quick commands, transcript viewer, voice input), vim editor mode (mode switching, navigation, editing, text objects), command history with Ctrl+R reverse search, background bash commands with Ctrl+B, bash mode with ! prefix, prompt suggestions, side questions with /btw, task list, PR review status
- [Keybindings](references/claude-code-keybindings.md) -- Keybindings.json configuration, all contexts (Global, Chat, Autocomplete, Settings, Confirmation, Tabs, Help, Transcript, HistorySearch, Task, ThemePicker, Attachments, Footer, MessageSelector, DiffDialog, ModelPicker, Select, Plugin), all actions by namespace, keystroke syntax (modifiers, uppercase, chords, special keys), unbinding defaults, reserved shortcuts, terminal conflicts, vim mode interaction, validation
- [Terminal Configuration](references/claude-code-terminal-config.md) -- Themes and appearance, line breaks and Shift+Enter setup for various terminals via /terminal-setup, Option+Enter setup for Terminal.app/iTerm2/VS Code, notification setup for Kitty/Ghostty/iTerm2 with tmux passthrough, notification hooks, handling large inputs, vim mode configuration
- [Tools Reference](references/claude-code-tools-reference.md) -- Complete list of all built-in tools with permission requirements (Agent, AskUserQuestion, Bash, CronCreate/Delete/List, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, PowerShell, Read, ReadMcpResourceTool, Skill, TaskCreate/Get/List/Output/Stop/Update, TodoWrite, ToolSearch, WebFetch, WebSearch, Write), Bash tool behavior (working directory persistence, environment variables, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR, CLAUDE_ENV_FILE), PowerShell tool opt-in preview (CLAUDE_CODE_USE_POWERSHELL_TOOL, shell selection, limitations)

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Built-in Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
