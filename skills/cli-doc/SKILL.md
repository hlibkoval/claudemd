---
name: cli-doc
description: Complete documentation for the Claude Code CLI -- launch commands, flags, built-in slash commands, interactive mode shortcuts, keybindings customization, terminal configuration, and tools reference. Covers all CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude auto-mode, claude mcp, claude plugin, claude remote-control), all CLI flags (--add-dir, --agent, --agents, --allowedTools, --append-system-prompt, --bare, --chrome, --continue, --dangerously-skip-permissions, --debug, --effort, --fallback-model, --fork-session, --from-pr, --init, --input-format, --json-schema, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --output-format, --permission-mode, --plugin-dir, --print, --remote, --remote-control, --resume, --session-id, --settings, --system-prompt, --system-prompt-file, --append-system-prompt-file, --teleport, --tools, --verbose, --version, --worktree, --tmux, --enable-auto-mode, --bare, --channels, --betas, --disallowedTools, --strict-mcp-config, --teammate-mode, --setting-sources, --no-session-persistence), all built-in slash commands (/add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /branch, /help, /hooks, /ide, /init, /insights, /install-github-app, /install-slack-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /model, /passes, /permissions, /plan, /plugin, /powerup, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /rewind, /sandbox, /schedule, /security-review, /setup-bedrock, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /ultraplan, /upgrade, /usage, /voice), keyboard shortcuts (Ctrl+C, Ctrl+D, Ctrl+G, Ctrl+L, Ctrl+O, Ctrl+R, Ctrl+V, Ctrl+B, Ctrl+T, Shift+Tab, Alt+P, Alt+T, Alt+O, Ctrl+K, Ctrl+U, Ctrl+Y, Alt+Y, Alt+B, Alt+F), multiline input methods, vim editor mode (mode switching, navigation, editing, text objects), command history and reverse search, background bash commands, bash mode (prefix !), prompt suggestions, side questions (/btw), task list (Ctrl+T), PR review status, keybindings customization (~/.claude/keybindings.json, contexts, actions, keystroke syntax, chords, unbinding, reserved shortcuts, terminal conflicts, vim mode interaction), terminal configuration (themes, line breaks, Shift+Enter setup, Option+Enter setup, notifications, flicker reduction, large inputs, vim mode), and built-in tools reference (Agent, AskUserQuestion, Bash, CronCreate, CronDelete, CronList, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, PowerShell, Read, ReadMcpResourceTool, SendMessage, Skill, TaskCreate, TaskGet, TaskList, TaskOutput, TaskStop, TaskUpdate, TeamCreate, TeamDelete, TodoWrite, ToolSearch, WebFetch, WebSearch, Write), Bash tool behavior, LSP tool behavior, and PowerShell tool. Load when discussing CLI commands, CLI flags, slash commands, built-in commands, keyboard shortcuts, keybindings, interactive mode, terminal setup, terminal config, vim mode, tools reference, built-in tools, Bash tool, LSP tool, PowerShell tool, background tasks, bash mode, prompt suggestions, /btw side questions, task list, command history, reverse search, multiline input, permission modes, system prompt flags, or any CLI-related topic for Claude Code.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface -- launch commands, flags, built-in slash commands, interactive mode, keybindings, terminal configuration, and tools reference.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:-----------|
| `claude` | Start interactive session |
| `claude "query"` | Start with initial prompt |
| `claude -p "query"` | Print mode (non-interactive), then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation |
| `claude -c -p "query"` | Continue via print mode |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (`--email`, `--sso`, `--console`) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List configured subagents |
| `claude auto-mode defaults` | Print built-in auto mode rules as JSON |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins (alias: `claude plugins`) |
| `claude remote-control` | Start Remote Control server |

### Key CLI Flags

| Flag | Description |
|:-----|:-----------|
| `--print`, `-p` | Non-interactive print mode |
| `--continue`, `-c` | Continue most recent conversation |
| `--resume`, `-r` | Resume session by ID or name |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Set effort level (`low`, `medium`, `high`, `max`) |
| `--permission-mode` | Set mode (`default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`) |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append file contents to default prompt |
| `--bare` | Minimal mode, skip auto-discovery for faster start |
| `--add-dir` | Add additional working directories |
| `--agent` | Specify agent for current session |
| `--agents` | Define custom subagents via JSON |
| `--allowedTools` | Tools that skip permission prompts |
| `--disallowedTools` | Tools removed from model context |
| `--tools` | Restrict which built-in tools are available |
| `--mcp-config` | Load MCP servers from JSON files |
| `--strict-mcp-config` | Only use MCP from `--mcp-config` |
| `--plugin-dir` | Load plugins from directory |
| `--name`, `-n` | Set session display name |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--tmux` | Create tmux session for worktree |
| `--remote` | Create web session on claude.ai |
| `--remote-control`, `--rc` | Start with Remote Control enabled |
| `--teleport` | Resume web session in local terminal |
| `--chrome` | Enable Chrome browser integration |
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--input-format` | Input format: `text`, `stream-json` |
| `--json-schema` | Get validated JSON output matching schema |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Max spend before stopping (print mode) |
| `--fallback-model` | Auto-fallback when default overloaded (print mode) |
| `--debug` | Enable debug mode with optional category filter |
| `--verbose` | Verbose logging |
| `--version`, `-v` | Show version |
| `--init` | Run init hooks and start interactive mode |
| `--init-only` | Run init hooks and exit |
| `--enable-auto-mode` | Unlock auto mode in Shift+Tab cycle |
| `--channels` | MCP channel notifications to listen for |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, `tmux` |
| `--settings` | Load settings from JSON file or string |
| `--setting-sources` | Comma-separated setting sources to load |
| `--session-id` | Use specific UUID for session |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a PR |
| `--no-session-persistence` | Disable session save to disk (print mode) |
| `--dangerously-skip-permissions` | Skip permission prompts |
| `--allow-dangerously-skip-permissions` | Add bypass to Shift+Tab cycle |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either.

### Built-in Slash Commands (selected)

| Command | Purpose |
|:--------|:--------|
| `/clear` | Clear conversation history (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Compact conversation with optional focus |
| `/config` | Open settings interface (alias: `/settings`) |
| `/context` | Visualize current context usage |
| `/copy [N]` | Copy last assistant response to clipboard |
| `/cost` | Show token usage statistics |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings |
| `/effort [level]` | Set model effort level |
| `/export [filename]` | Export conversation as plain text |
| `/fast [on\|off]` | Toggle fast mode |
| `/branch [name]` | Branch conversation (alias: `/fork`) |
| `/init` | Initialize project with CLAUDE.md |
| `/keybindings` | Open keybindings config file |
| `/memory` | Edit CLAUDE.md memory files |
| `/model [model]` | Select or change AI model |
| `/permissions` | Manage tool permission rules (alias: `/allowed-tools`) |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/rename [name]` | Rename current session |
| `/resume [session]` | Resume conversation (alias: `/continue`) |
| `/rewind` | Rewind conversation/code (alias: `/checkpoint`) |
| `/sandbox` | Toggle sandbox mode |
| `/schedule [desc]` | Create/manage Cloud scheduled tasks |
| `/security-review` | Analyze branch changes for security issues |
| `/skills` | List available skills |
| `/status` | Show version, model, account, connectivity |
| `/theme` | Change color theme |
| `/ultraplan <prompt>` | Draft plan in ultraplan session |
| `/voice` | Toggle push-to-talk voice dictation |
| `/btw <question>` | Side question without adding to conversation |
| `/add-dir <path>` | Add working directory for file access |
| `/color [color]` | Set prompt bar color |
| `/desktop` | Continue in Desktop app (alias: `/app`) |
| `/remote-control` | Enable remote control (alias: `/rc`) |

### Keyboard Shortcuts

**General controls:**

| Shortcut | Action |
|:---------|:-------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open in external text editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` / `Cmd+V` / `Alt+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Shift+Tab` / `Alt+M` | Cycle permission modes |
| `Alt+P` | Switch model |
| `Alt+T` | Toggle extended thinking |
| `Alt+O` | Toggle fast mode |
| `Esc+Esc` | Rewind or summarize |

**Text editing:**

| Shortcut | Action |
|:---------|:-------|
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete to start of line |
| `Ctrl+Y` | Paste deleted text |
| `Alt+Y` | Cycle paste history |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

**Multiline input:**

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + `Enter` |
| macOS default | `Option+Enter` |
| Shift+Enter | Works in iTerm2, WezTerm, Ghostty, Kitty |
| Control sequence | `Ctrl+J` |

**Quick prefixes:**

| Prefix | Action |
|:-------|:-------|
| `/` | Command or skill |
| ` ` (with `!`) | Bash mode -- run shell commands directly |
| `@` | File path autocomplete |

### Keybindings Customization

Config file: `~/.claude/keybindings.json` (open with `/keybindings`)

**Contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`

**Key actions (selected):**

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
| `chat:imagePaste` | Ctrl+V | Chat |
| `chat:newline` | (unbound) | Chat |
| `voice:pushToTalk` | Space (hold) | Chat |

**Keystroke syntax:** Modifiers with `+` (`ctrl+k`, `shift+tab`, `meta+p`, `ctrl+shift+c`). Chords as space-separated sequences (`ctrl+k ctrl+s`). Uppercase letter implies Shift (`K` = `shift+k`).

**Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`

**Unbind:** Set action to `null`

### Built-in Tools

| Tool | Description | Permission |
|:-----|:-----------|:-----------|
| `Agent` | Spawn subagent with own context | No |
| `AskUserQuestion` | Ask multiple-choice questions | No |
| `Bash` | Execute shell commands | Yes |
| `CronCreate` | Schedule recurring prompt in session | No |
| `CronDelete` | Cancel scheduled task | No |
| `CronList` | List scheduled tasks | No |
| `Edit` | Targeted file edits | Yes |
| `EnterPlanMode` | Switch to plan mode | No |
| `EnterWorktree` | Create and enter git worktree | No |
| `ExitPlanMode` | Present plan and exit plan mode | Yes |
| `ExitWorktree` | Exit worktree session | No |
| `Glob` | Find files by pattern | No |
| `Grep` | Search file contents | No |
| `ListMcpResourcesTool` | List MCP resources | No |
| `LSP` | Code intelligence (definitions, references, errors) | No |
| `NotebookEdit` | Modify Jupyter notebook cells | Yes |
| `PowerShell` | Execute PowerShell on Windows (opt-in) | Yes |
| `Read` | Read file contents | No |
| `ReadMcpResourceTool` | Read MCP resource by URI | No |
| `SendMessage` | Message agent team teammate | No |
| `Skill` | Execute a skill | Yes |
| `TaskCreate` | Create task in task list | No |
| `TaskGet` | Get task details | No |
| `TaskList` | List all tasks | No |
| `TaskOutput` | (Deprecated) Get background task output | No |
| `TaskStop` | Kill running background task | No |
| `TaskUpdate` | Update task status/details | No |
| `TeamCreate` | Create agent team | No |
| `TeamDelete` | Disband agent team | No |
| `TodoWrite` | Manage session task checklist (non-interactive) | No |
| `ToolSearch` | Search/load deferred tools | No |
| `WebFetch` | Fetch content from URL | Yes |
| `WebSearch` | Perform web search | Yes |
| `Write` | Create or overwrite files | Yes |

**Bash tool:** Each command runs in separate process. Working directory persists; env vars do not. Use `CLAUDE_ENV_FILE` for persistent env vars.

**LSP tool:** Auto-reports type errors after edits. Supports jump-to-definition, find references, type info, symbol lists, implementations, call hierarchies. Requires a code intelligence plugin.

**PowerShell tool:** Opt-in with `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. Auto-detects `pwsh.exe` (7+) or `powershell.exe` (5.1). Windows only. Auto mode not yet supported.

### Terminal Configuration

**Line breaks:** `\` + Enter (all terminals), `Ctrl+J` (all terminals), `Shift+Enter` (iTerm2/WezTerm/Ghostty/Kitty natively; `/terminal-setup` for others), `Option+Enter` (macOS)

**Option as Meta (macOS):** iTerm2: Settings > Profiles > Keys > "Esc+". Terminal.app: Settings > Profiles > Keyboard > "Use Option as Meta Key". VS Code: `"terminal.integrated.macOptionIsMeta": true`

**Notifications:** Kitty/Ghostty support natively. iTerm2: Settings > Profiles > Terminal > "Notification Center Alerts" > "Send escape sequence-generated alerts". tmux: `set -g allow-passthrough on`. Other terminals: use notification hooks.

**Reduce flicker:** `CLAUDE_CODE_NO_FLICKER=1` for fullscreen rendering.

**Vim mode:** Enable via `/config` > Editor mode or set `editorMode: "vim"` in `~/.claude.json`. Supports mode switching, `hjkl` navigation, `w`/`e`/`b` word motion, `f`/`F`/`t`/`T` char search, `d`/`c`/`y` operators with text objects (`iw`, `aw`, `i"`, `a(`, etc.), `p`/`P` paste, `>>`/`<<` indent, `J` join, `.` repeat.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) -- All CLI commands and flags with examples
- [Built-in Commands](references/claude-code-commands.md) -- Complete list of slash commands available in interactive mode
- [Interactive Mode](references/claude-code-interactive-mode.md) -- Keyboard shortcuts, vim mode, command history, background tasks, bash mode, prompt suggestions, side questions, task list
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) -- Keybindings configuration file format, contexts, actions, keystroke syntax, chords, unbinding
- [Terminal Configuration](references/claude-code-terminal-config.md) -- Line breaks, Shift+Enter setup, notifications, flicker reduction, vim mode setup
- [Tools Reference](references/claude-code-tools-reference.md) -- Built-in tools, permission requirements, Bash/LSP/PowerShell tool behavior

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Built-in Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
