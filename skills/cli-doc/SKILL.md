---
name: cli-doc
description: Complete documentation for the Claude Code CLI and interactive terminal interface -- CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude auto-mode, claude mcp, claude remote-control), CLI flags (--add-dir, --agent, --agents, --allowedTools, --append-system-prompt, --append-system-prompt-file, --bare, --betas, --channels, --chrome, --continue, --dangerously-skip-permissions, --debug, --disable-slash-commands, --disallowedTools, --effort, --fallback-model, --fork-session, --from-pr, --ide, --init, --input-format, --json-schema, --maintenance, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --no-chrome, --no-session-persistence, --output-format, --enable-auto-mode, --permission-mode, --permission-prompt-tool, --plugin-dir, --print, --remote, --remote-control, --resume, --session-id, --setting-sources, --settings, --strict-mcp-config, --system-prompt, --system-prompt-file, --teleport, --teammate-mode, --tools, --verbose, --version, --worktree), system prompt flags (--system-prompt replaces, --append-system-prompt appends, mutual exclusivity rules), built-in slash commands (/add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /branch, /help, /hooks, /ide, /init, /insights, /install-github-app, /install-slack-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /model, /passes, /permissions, /plan, /plugin, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /review, /rewind, /sandbox, /schedule, /security-review, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim, /voice), interactive mode features (keyboard shortcuts, text editing shortcuts, multiline input methods, quick commands with / and @ prefixes, Vim editor mode with mode switching and navigation and editing and text objects, command history with reverse search Ctrl+R, background bash commands and Ctrl+B backgrounding, bash mode with prefix, prompt suggestions with Tab accept, /btw side questions, task list with Ctrl+T toggle, PR review status indicator), customizable keybindings (keybindings.json with bindings array, contexts: Global/Chat/Autocomplete/Settings/Confirmation/Tabs/Help/Transcript/HistorySearch/Task/ThemePicker/Attachments/Footer/MessageSelector/DiffDialog/ModelPicker/Select/Plugin, actions by namespace: app/history/chat/autocomplete/confirm/permission/transcript/historySearch/task/theme/help/tabs/attachments/footer/messageSelector/diff/modelPicker/select/plugin/settings/voice, keystroke syntax with modifiers and uppercase and chords and special keys, unbinding defaults with null, reserved shortcuts Ctrl+C/Ctrl+D/Ctrl+M, terminal conflicts with tmux and screen, Vim mode interaction), terminal configuration (themes and appearance, line break methods, Shift+Enter setup for various terminals, Option+Enter setup for macOS, notification setup for iTerm2/Kitty/Ghostty and tmux passthrough, notification hooks, handling large inputs, Vim mode), tools reference (Agent, AskUserQuestion, Bash, CronCreate, CronDelete, CronList, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, Read, ReadMcpResourceTool, Skill, TaskCreate, TaskGet, TaskList, TaskOutput, TaskStop, TaskUpdate, TodoWrite, ToolSearch, WebFetch, WebSearch, Write with permission requirements, Bash tool behavior with working directory persistence and environment variable non-persistence, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR, CLAUDE_ENV_FILE). Load when discussing Claude Code CLI, command-line flags, CLI reference, claude command, claude -p print mode, claude -c continue, claude -r resume, --model flag, --system-prompt, --append-system-prompt, --bare mode, --json-schema, --max-turns, --max-budget-usd, --output-format, --input-format, --dangerously-skip-permissions, --permission-mode, --allowedTools, --disallowedTools, --tools, --mcp-config, --plugin-dir, --add-dir, --effort flag, --worktree flag, --remote flag, --teleport, --enable-auto-mode, --agent flag, --agents flag, --fallback-model, --from-pr, built-in commands, slash commands, /compact, /clear, /config, /context, /cost, /diff, /effort, /export, /fast, /model, /permissions, /plan, /resume, /rewind, /sandbox, /terminal-setup, /vim, /voice, /btw, /schedule, /plugin, /memory, /init, /hooks, /agents, /mcp, /chrome, interactive mode, keyboard shortcuts, keybindings, Ctrl+C, Ctrl+D, Ctrl+B background, Ctrl+R history search, Ctrl+O verbose, Shift+Tab permission mode, multiline input, Shift+Enter, Vim mode, command history, bash mode, prompt suggestions, side questions, task list, PR review status, keybindings.json, custom keybindings, keybinding contexts, keybinding actions, terminal setup, terminal configuration, notification setup, tools reference, built-in tools, tool permissions, Bash tool, Edit tool, Write tool, Read tool, Glob tool, Grep tool, Agent tool, WebFetch tool, WebSearch tool, LSP tool, NotebookEdit tool, Skill tool, TodoWrite tool, TaskCreate, TaskOutput, background tasks, or any CLI/terminal/tools/commands topic for Claude Code.
user-invocable: false
---

# CLI & Interactive Mode Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, built-in commands, interactive mode features, customizable keybindings, terminal configuration, and built-in tools reference.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode: query then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -c -p "query"` | Continue via print mode |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (`--email`, `--sso`, `--console` flags) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON (`--text` for readable output) |
| `claude agents` | List configured subagents |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |
| `claude mcp` | Configure MCP servers |
| `claude remote-control` | Start Remote Control server |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `--print`, `-p` | Print mode (non-interactive), exit after response |
| `--continue`, `-c` | Continue most recent conversation |
| `--resume`, `-r` | Resume session by ID/name or open picker |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `max` (Opus 4.6 only) |
| `--output-format` | Print mode output: `text`, `json`, `stream-json` |
| `--input-format` | Print mode input: `text`, `stream-json` |
| `--json-schema` | Get validated JSON output matching a schema (print mode) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Maximum dollar spend before stopping (print mode) |
| `--fallback-model` | Fallback model when default is overloaded (print mode) |
| `--system-prompt` | Replace entire system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt` | Append to default system prompt |
| `--append-system-prompt-file` | Append file contents to default prompt |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--add-dir` | Add additional working directories |
| `--agent` | Specify agent for session |
| `--agents` | Define subagents dynamically via JSON |
| `--allowedTools` | Tools that execute without permission prompting |
| `--disallowedTools` | Tools removed from context entirely |
| `--tools` | Restrict available built-in tools (`""` for none, `"default"` for all) |
| `--mcp-config` | Load MCP servers from JSON files or strings |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config` |
| `--plugin-dir` | Load plugins from directory (repeatable) |
| `--permission-mode` | Begin in specified permission mode |
| `--enable-auto-mode` | Unlock auto mode in Shift+Tab cycle |
| `--dangerously-skip-permissions` | Skip permission prompts |
| `--allow-dangerously-skip-permissions` | Enable bypass as composable option |
| `--permission-prompt-tool` | MCP tool to handle permission prompts (non-interactive) |
| `--name`, `-n` | Set session display name |
| `--session-id` | Use specific UUID for conversation |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a GitHub PR |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--remote` | Create web session on claude.ai |
| `--remote-control`, `--rc` | Interactive session with Remote Control enabled |
| `--teleport` | Resume web session in local terminal |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, `tmux` |
| `--chrome` / `--no-chrome` | Enable/disable Chrome browser integration |
| `--ide` | Auto-connect to IDE on startup |
| `--channels` | MCP channel notifications to listen for |
| `--init` / `--init-only` | Run initialization hooks (and optionally exit) |
| `--maintenance` | Run maintenance hooks and exit |
| `--settings` | Load settings from JSON file or string |
| `--setting-sources` | Comma-separated setting sources: `user`, `project`, `local` |
| `--debug` | Debug mode with optional category filtering |
| `--verbose` | Verbose logging with full turn-by-turn output |
| `--version`, `-v` | Output version number |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. The append flags can combine with either replacement flag. For most cases, prefer append flags to preserve built-in capabilities.

### Built-in Slash Commands

| Command | Purpose |
|:--------|:--------|
| `/add-dir <path>` | Add working directory to session |
| `/agents` | Manage agent configurations |
| `/btw <question>` | Ask side question without adding to conversation |
| `/chrome` | Configure Chrome integration settings |
| `/clear` | Clear conversation history (aliases: `/reset`, `/new`) |
| `/color [color]` | Set prompt bar color for session |
| `/compact [instructions]` | Compact conversation with optional focus |
| `/config` | Open Settings interface (alias: `/settings`) |
| `/context` | Visualize context usage as colored grid |
| `/copy [N]` | Copy assistant response to clipboard |
| `/cost` | Show token usage statistics |
| `/desktop` | Continue session in Desktop app (alias: `/app`) |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings |
| `/effort [level]` | Set effort level (`low`/`medium`/`high`/`max`/`auto`) |
| `/exit` | Exit CLI (alias: `/quit`) |
| `/export [filename]` | Export conversation as plain text |
| `/extra-usage` | Configure extra usage for rate limits |
| `/fast [on\|off]` | Toggle fast mode |
| `/feedback [report]` | Submit feedback (alias: `/bug`) |
| `/branch [name]` | Branch conversation at this point (alias: `/fork`) |
| `/help` | Show help and available commands |
| `/hooks` | View hook configurations |
| `/ide` | Manage IDE integrations |
| `/init` | Initialize project with CLAUDE.md |
| `/insights` | Generate session analysis report |
| `/install-github-app` | Set up Claude GitHub Actions |
| `/install-slack-app` | Install Claude Slack app |
| `/keybindings` | Open keybindings configuration file |
| `/login` / `/logout` | Sign in/out of Anthropic account |
| `/mcp` | Manage MCP server connections |
| `/memory` | Edit CLAUDE.md memory files, toggle auto-memory |
| `/mobile` | QR code for mobile app (aliases: `/ios`, `/android`) |
| `/model [model]` | Select or change AI model |
| `/passes` | Share free week of Claude Code |
| `/permissions` | View/update permissions (alias: `/allowed-tools`) |
| `/plan` | Enter plan mode from prompt |
| `/plugin` | Manage plugins |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/privacy-settings` | View/update privacy settings (Pro/Max only) |
| `/release-notes` | View full changelog |
| `/reload-plugins` | Reload all active plugins |
| `/remote-control` | Enable Remote Control (alias: `/rc`) |
| `/remote-env` | Configure default remote environment |
| `/rename [name]` | Rename current session |
| `/resume [session]` | Resume conversation (alias: `/continue`) |
| `/rewind` | Rewind conversation/code (alias: `/checkpoint`) |
| `/sandbox` | Toggle sandbox mode |
| `/schedule [description]` | Create/manage Cloud scheduled tasks |
| `/security-review` | Analyze branch changes for security issues |
| `/skills` | List available skills |
| `/stats` | Visualize daily usage and session history |
| `/status` | Open Status tab showing version, model, account |
| `/statusline` | Configure status line |
| `/stickers` | Order Claude Code stickers |
| `/tasks` | List and manage background tasks |
| `/terminal-setup` | Configure terminal keybindings |
| `/theme` | Change color theme |
| `/upgrade` | Open upgrade page |
| `/usage` | Show plan usage and rate limit status |
| `/vim` | Toggle Vim/Normal editing mode |
| `/voice` | Toggle push-to-talk voice dictation |

MCP servers can also expose prompts as commands: `/mcp__<server>__<prompt>`.

### Keyboard Shortcuts (Interactive Mode)

**General controls:**

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+F` | Kill all background agents (press twice to confirm) |
| `Ctrl+D` | Exit session |
| `Ctrl+G` | Open prompt in default text editor |
| `Ctrl+L` | Clear terminal screen (keeps history) |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` / `Cmd+V` / `Alt+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Shift+Tab` / `Alt+M` | Cycle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Esc+Esc` | Rewind or summarize |
| `Up/Down` | Navigate command history |

**Text editing:**

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete entire line |
| `Ctrl+Y` | Paste deleted text |
| `Alt+Y` | Cycle paste history (after Ctrl+Y) |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

**Multiline input:**

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + `Enter` (all terminals) |
| macOS default | `Option+Enter` |
| Shift+Enter | Works natively in iTerm2, WezTerm, Ghostty, Kitty |
| Control sequence | `Ctrl+J` |
| Paste mode | Paste directly for code blocks |

Run `/terminal-setup` to configure Shift+Enter for VS Code, Alacritty, Zed, and Warp.

**Quick commands:**

| Prefix | Effect |
|:-------|:-------|
| `/` | Invoke command or skill |
| `!` | Bash mode: run command directly, output added to context |
| `@` | File path autocomplete |

**Voice input:** Hold `Space` for push-to-talk dictation (requires `/voice` enabled).

### Vim Editor Mode

Enable with `/vim` or permanently via `/config`. Set `editorMode` to `"vim"` in `~/.claude.json`.

**Mode switching:** `Esc` (to NORMAL), `i`/`I`/`a`/`A`/`o`/`O` (to INSERT)

**Navigation (NORMAL):** `h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f`/`F`/`t`/`T` with `;`/`,` repeat

**Editing (NORMAL):** `x`, `dd`/`D`, `dw`/`de`/`db`, `cc`/`C`, `cw`/`ce`/`cb`, `yy`/`Y`/`yw`/`ye`/`yb`, `p`/`P`, `>>`/`<<`, `J`, `.` (repeat)

**Text objects:** `iw`/`aw`, `iW`/`aW`, `i"`/`a"`, `i'`/`a'`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`

### Customizable Keybindings

Configure at `~/.claude/keybindings.json` (open with `/keybindings`). Changes auto-apply without restart.

**Contexts:**

| Context | Description |
|:--------|:------------|
| `Global` | Everywhere in the app |
| `Chat` | Main chat input area |
| `Autocomplete` | Autocomplete menu open |
| `Confirmation` | Permission/confirmation dialogs |
| `HistorySearch` | History search mode (Ctrl+R) |
| `Task` | Background task running |
| `DiffDialog` | Diff viewer navigation |
| `ModelPicker` | Model picker effort level |
| `Select` | Generic select/list components |
| `Plugin` | Plugin dialog |
| `Settings` | Settings menu |
| `Tabs` / `Help` / `Transcript` / `ThemePicker` / `Attachments` / `Footer` / `MessageSelector` | Specialized UI contexts |

**Key action namespaces:** `app:` (interrupt, exit, toggleTodos, toggleTranscript), `chat:` (submit, cancel, cycleMode, modelPicker, thinkingToggle, externalEditor, stash, imagePaste), `history:` (search, previous, next), `autocomplete:` (accept, dismiss, previous, next), `confirm:` (yes, no, cycleMode, toggleExplanation), `task:` (background), `diff:` (dismiss, previousSource, nextSource, previousFile, nextFile), `voice:` (pushToTalk).

**Keystroke syntax:** Modifiers with `+` (`ctrl`, `alt`/`opt`, `shift`, `meta`/`cmd`). Chords separated by spaces (`ctrl+k ctrl+s`). Standalone uppercase implies Shift (`K` = `shift+k`). Special keys: `escape`, `enter`, `tab`, `space`, `up`/`down`/`left`/`right`, `backspace`, `delete`.

**Unbind:** Set action to `null`. **Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`.

### Interactive Mode Features

**Command history:** Per working directory. Resets on `/clear`. Navigate with Up/Down. Reverse search with `Ctrl+R` (type query, `Ctrl+R` to cycle, `Tab`/`Esc` to accept, `Enter` to execute, `Ctrl+C` to cancel).

**Background bash commands:** Run commands asynchronously. Prompt Claude to background, or press `Ctrl+B` to move running command to background. Output buffered with unique task IDs. Auto-terminated at 5GB output. Disable with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

**Bash mode (`!` prefix):** Run shell commands directly without Claude interpretation. Output added to conversation context. Supports `Ctrl+B` backgrounding and history-based Tab autocomplete.

**Prompt suggestions:** Grayed-out example commands based on git history and conversation. Press `Tab` to accept, `Enter` to accept and submit. Disable with `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false`.

**Side questions (`/btw`):** Quick questions with full conversation visibility but no tool access. Ephemeral (not added to history). Available while Claude is working. Dismiss with `Space`/`Enter`/`Escape`.

**Task list:** Auto-created for complex multi-step work. Toggle with `Ctrl+T`. Shows up to 10 tasks. Persists across compactions. Share across sessions with `CLAUDE_CODE_TASK_LIST_ID`.

**PR review status:** Clickable PR link in footer with colored underline (green=approved, yellow=pending, red=changes requested, gray=draft, purple=merged). Requires `gh` CLI. Updates every 60 seconds.

### Terminal Configuration

**Notification setup:** Kitty and Ghostty support desktop notifications natively. iTerm2 requires enabling Notification Center Alerts and escape sequence alerts. tmux requires `set -g allow-passthrough on`. Other terminals use notification hooks.

**Option as Meta (macOS):** Required for `Alt` shortcuts.
- iTerm2: Settings > Profiles > Keys > Left/Right Option = "Esc+"
- Terminal.app: Settings > Profiles > Keyboard > "Use Option as Meta Key"
- VS Code: `terminal.integrated.macOptionIsMeta: true`

### Tools Reference

| Tool | Description | Permission |
|:-----|:------------|:-----------|
| `Agent` | Spawn subagent with own context window | No |
| `AskUserQuestion` | Ask multiple-choice questions | No |
| `Bash` | Execute shell commands | Yes |
| `CronCreate` / `CronDelete` / `CronList` | Manage scheduled tasks in session | No |
| `Edit` | Make targeted edits to files | Yes |
| `EnterPlanMode` / `ExitPlanMode` | Design approach before coding | No / Yes |
| `EnterWorktree` / `ExitWorktree` | Manage isolated git worktrees | No |
| `Glob` | Find files by pattern matching | No |
| `Grep` | Search patterns in file contents | No |
| `ListMcpResourcesTool` / `ReadMcpResourceTool` | MCP resource access | No |
| `LSP` | Code intelligence via language servers | No |
| `NotebookEdit` | Modify Jupyter notebook cells | Yes |
| `Read` | Read file contents | No |
| `Skill` | Execute a skill | Yes |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` / `TaskOutput` | Manage background tasks | No |
| `TodoWrite` | Session task checklist (non-interactive/Agent SDK) | No |
| `ToolSearch` | Search/load deferred tools (tool search mode) | No |
| `WebFetch` | Fetch content from URL | Yes |
| `WebSearch` | Perform web searches | Yes |
| `Write` | Create or overwrite files | Yes |

**Bash tool behavior:** Each command runs in a separate process. Working directory persists across commands. Environment variables do not persist. Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to reset to project directory after each command. Use `CLAUDE_ENV_FILE` for persistent env vars, or a SessionStart hook.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) -- complete reference for CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude auto-mode, claude mcp, claude remote-control) and all CLI flags (--add-dir, --agent, --agents, --allowedTools, --append-system-prompt, --bare, --betas, --channels, --chrome, --continue, --dangerously-skip-permissions, --debug, --disallowedTools, --effort, --fallback-model, --fork-session, --from-pr, --ide, --init, --input-format, --json-schema, --maintenance, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --no-chrome, --no-session-persistence, --output-format, --enable-auto-mode, --permission-mode, --permission-prompt-tool, --plugin-dir, --print, --remote, --remote-control, --resume, --session-id, --setting-sources, --settings, --strict-mcp-config, --system-prompt, --system-prompt-file, --teleport, --teammate-mode, --tools, --verbose, --version, --worktree), system prompt flags behavior and mutual exclusivity
- [Built-in commands](references/claude-code-commands.md) -- complete reference for all slash commands available in Claude Code interactive mode (/add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /branch, /help, /hooks, /ide, /init, /insights, /install-github-app, /install-slack-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /model, /passes, /permissions, /plan, /plugin, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /review, /rewind, /sandbox, /schedule, /security-review, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim, /voice), MCP prompts as commands
- [Interactive mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts (general controls, text editing, theme/display, multiline input, quick commands, voice input), built-in commands overview, Vim editor mode (mode switching, navigation, editing, text objects), command history and Ctrl+R reverse search, background bash commands and Ctrl+B backgrounding, bash mode with prefix, prompt suggestions, /btw side questions, task list with Ctrl+T, PR review status indicator
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) -- keybindings.json configuration file format, binding contexts (Global, Chat, Autocomplete, Settings, Confirmation, Tabs, Help, Transcript, HistorySearch, Task, ThemePicker, Attachments, Footer, MessageSelector, DiffDialog, ModelPicker, Select, Plugin), all available actions by namespace (app, history, chat, autocomplete, confirm, permission, transcript, historySearch, task, theme, help, tabs, attachments, footer, messageSelector, diff, modelPicker, select, plugin, settings, voice), keystroke syntax (modifiers, uppercase, chords, special keys), unbinding defaults, reserved shortcuts, terminal conflicts, Vim mode interaction, validation
- [Terminal configuration](references/claude-code-terminal-config.md) -- terminal themes and appearance, line break methods and Shift+Enter setup for various terminals, Option+Enter setup for macOS terminals, notification setup (iTerm2, Kitty, Ghostty, tmux passthrough, notification hooks), handling large inputs, Vim mode configuration
- [Tools reference](references/claude-code-tools-reference.md) -- complete list of built-in tools with descriptions and permission requirements (Agent, AskUserQuestion, Bash, CronCreate, CronDelete, CronList, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, Read, ReadMcpResourceTool, Skill, TaskCreate, TaskGet, TaskList, TaskOutput, TaskStop, TaskUpdate, TodoWrite, ToolSearch, WebFetch, WebSearch, Write), Bash tool behavior (working directory persistence, environment variable non-persistence, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR, CLAUDE_ENV_FILE)

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Built-in commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Terminal configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
