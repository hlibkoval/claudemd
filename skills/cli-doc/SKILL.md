---
name: cli-doc
description: Complete documentation for the Claude Code CLI interface, interactive mode, built-in commands, keybindings, terminal configuration, and tools reference. Covers CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude mcp, claude remote-control), all CLI flags (--add-dir, --agent, --agents, --allowedTools, --append-system-prompt, --append-system-prompt-file, --bare, --betas, --channels, --chrome, --continue, --dangerously-skip-permissions, --allow-dangerously-skip-permissions, --dangerously-load-development-channels, --debug, --disable-slash-commands, --disallowedTools, --effort, --fallback-model, --fork-session, --from-pr, --ide, --init, --init-only, --include-partial-messages, --input-format, --json-schema, --maintenance, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --no-chrome, --no-session-persistence, --output-format, --permission-mode, --permission-prompt-tool, --plugin-dir, --print, --remote, --remote-control, --resume, --session-id, --setting-sources, --settings, --strict-mcp-config, --system-prompt, --system-prompt-file, --teleport, --teammate-mode, --tools, --verbose, --version, --worktree), system prompt flags (replace vs append, mutual exclusivity), built-in slash commands (/add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /branch, /help, /hooks, /ide, /init, /insights, /install-github-app, /install-slack-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /model, /passes, /permissions, /plan, /plugin, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /review, /rewind, /sandbox, /security-review, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim, /voice), interactive mode features (keyboard shortcuts, Ctrl+C/D/G/L/O/R/V/B/T/F, Esc+Esc, Shift+Tab, Option+P, Option+T, text editing Ctrl+K/U/Y, Alt+Y/B/F, multiline input with backslash-Enter/Option+Enter/Shift+Enter/Ctrl+J, quick commands with / and prefix-exclamation and @, voice input with hold-Space), Vim mode (mode switching, navigation, editing, text objects, full keybinding set), command history and Ctrl+R reverse search, background bash commands (Ctrl+B backgrounding, TaskOutput retrieval, 5GB limit, CLAUDE_CODE_DISABLE_BACKGROUND_TASKS), bash mode with prefix-exclamation (history autocomplete with Tab), prompt suggestions (Tab to accept, Enter to accept-and-submit, CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION), side questions with /btw (no tool access, ephemeral overlay, available while Claude is working, reuses prompt cache), task list (Ctrl+T toggle, CLAUDE_CODE_TASK_LIST_ID for shared lists, persists across compactions), PR review status (colored underline: green approved, yellow pending, red changes-requested, gray draft, purple merged, requires gh CLI), customizable keybindings (~/.claude/keybindings.json, /keybindings command, binding blocks by context, contexts: Global/Chat/Autocomplete/Settings/Confirmation/Tabs/Help/Transcript/HistorySearch/Task/ThemePicker/Attachments/Footer/MessageSelector/DiffDialog/ModelPicker/Select/Plugin, action namespaces: app/history/chat/autocomplete/confirm/permission/transcript/historySearch/task/theme/help/tabs/attachments/footer/messageSelector/diff/modelPicker/select/plugin/settings/voice, keystroke syntax with modifiers and chords and special keys, unbinding with null, reserved shortcuts Ctrl+C/Ctrl+D, terminal conflicts with tmux/screen/SIGTSTP, vim mode interaction), terminal configuration (themes with /config and /statusline, line breaks with Shift+Enter and /terminal-setup, notification setup for iTerm2/Kitty/Ghostty and tmux passthrough, notification hooks, handling large inputs, Vim mode setup), tools reference (Agent, AskUserQuestion, Bash, CronCreate/Delete/List, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, Read, ReadMcpResourceTool, Skill, TaskCreate/Get/List/Output/Stop/Update, TodoWrite, ToolSearch, WebFetch, WebSearch, Write, permission requirements for each tool), Bash tool behavior (working directory persists, env vars do not persist, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR, CLAUDE_ENV_FILE, virtualenv/conda activation). Load when discussing CLI flags, CLI commands, slash commands, built-in commands, keyboard shortcuts, keybindings, interactive mode, Vim mode, terminal setup, tools reference, tool permissions, Bash tool behavior, background tasks, prompt suggestions, /btw side questions, task list, PR review status, multiline input, command history, reverse search, system prompt flags, output format, print mode, non-interactive mode, session management flags, voice input, channels, or any Claude Code CLI interface question.
user-invocable: false
---

# CLI & Interactive Mode Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive session features, built-in commands, customizable keybindings, terminal configuration, and the tools Claude Code can use.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Non-interactive (print) mode -- query and exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -c -p "query"` | Continue in non-interactive mode |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (use `--email`, `--sso`, `--console` flags) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON (exit 0 if logged in, 1 if not; `--text` for human-readable) |
| `claude agents` | List all configured subagents by source |
| `claude mcp` | Configure MCP servers |
| `claude remote-control` | Start Remote Control server |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `--add-dir` | Add additional working directories |
| `--agent` | Specify an agent for the session |
| `--agents` | Define subagents dynamically via JSON |
| `--allowedTools` | Tools that execute without permission prompts (pattern matching supported) |
| `--append-system-prompt` | Append text to default system prompt |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md; sets `CLAUDE_CODE_SIMPLE` |
| `--channels` | (Research preview) MCP servers whose channel notifications to listen for |
| `--chrome` / `--no-chrome` | Enable/disable Chrome browser integration |
| `--continue`, `-c` | Load most recent conversation |
| `--dangerously-skip-permissions` | Skip permission prompts |
| `--debug` | Debug mode with optional category filter (e.g., `"api,hooks"`) |
| `--disallowedTools` | Remove tools from context entirely |
| `--effort` | Set effort level: `low`, `medium`, `high`, `max` (Opus 4.6 only) |
| `--fallback-model` | Automatic fallback model when default is overloaded (print mode) |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a GitHub PR |
| `--json-schema` | Get validated JSON output matching a schema (print mode) |
| `--max-budget-usd` | Maximum spend before stopping (print mode) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--mcp-config` | Load MCP servers from JSON files |
| `--model` | Set model (alias: `sonnet`, `opus`, or full name) |
| `--name`, `-n` | Set session display name |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` |
| `--permission-mode` | Start in a specific permission mode |
| `--plugin-dir` | Load plugins from directory |
| `--print`, `-p` | Non-interactive print mode |
| `--remote` | Create web session on claude.ai |
| `--remote-control`, `--rc` | Interactive session with Remote Control enabled |
| `--resume`, `-r` | Resume session by ID/name or show picker |
| `--setting-sources` | Comma-separated setting sources: `user`, `project`, `local` |
| `--settings` | Load settings from JSON file or string |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config` |
| `--system-prompt` | Replace entire system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--teleport` | Resume web session locally |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, `tmux` |
| `--tools` | Restrict available tools (e.g., `"Bash,Edit,Read"`, `""` for none) |
| `--verbose` | Verbose logging with full turn-by-turn output |
| `--version`, `-v` | Show version number |
| `--worktree`, `-w` | Start in isolated git worktree |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag. For most use cases, prefer append to preserve built-in capabilities.

### Built-in Slash Commands

| Command | Purpose |
|:--------|:--------|
| `/add-dir <path>` | Add working directory to session |
| `/agents` | Manage agent configurations |
| `/btw <question>` | Side question without adding to conversation |
| `/chrome` | Configure Chrome integration |
| `/clear` | Clear conversation history (aliases: `/reset`, `/new`) |
| `/color [color]` | Set prompt bar color |
| `/compact [instructions]` | Compact conversation with optional focus |
| `/config` | Open Settings interface (alias: `/settings`) |
| `/context` | Visualize context usage as colored grid |
| `/copy [N]` | Copy last (or Nth) assistant response to clipboard |
| `/cost` | Show token usage statistics |
| `/desktop` | Continue session in Desktop app (alias: `/app`) |
| `/diff` | Interactive diff viewer for uncommitted/per-turn changes |
| `/doctor` | Diagnose installation and settings |
| `/effort [level]` | Set effort level (persists for low/medium/high; max is session-only) |
| `/exit` | Exit CLI (alias: `/quit`) |
| `/export [filename]` | Export conversation as plain text |
| `/extra-usage` | Configure extra usage for rate limits |
| `/fast [on\|off]` | Toggle fast mode |
| `/feedback [report]` | Submit feedback (alias: `/bug`) |
| `/branch [name]` | Branch conversation at current point (alias: `/fork`) |
| `/help` | Show help and commands |
| `/hooks` | View hook configurations |
| `/ide` | Manage IDE integrations |
| `/init` | Initialize project with CLAUDE.md |
| `/insights` | Generate session analysis report |
| `/install-github-app` | Set up Claude GitHub Actions |
| `/install-slack-app` | Install Claude Slack app |
| `/keybindings` | Open keybindings configuration file |
| `/login` / `/logout` | Sign in/out |
| `/mcp` | Manage MCP servers and OAuth |
| `/memory` | Edit CLAUDE.md, toggle auto-memory |
| `/mobile` | QR code for mobile app (aliases: `/ios`, `/android`) |
| `/model [model]` | Select/change model; arrows adjust effort |
| `/passes` | Share free week of Claude Code |
| `/permissions` | View/update permissions (alias: `/allowed-tools`) |
| `/plan` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/privacy-settings` | View/update privacy settings (Pro/Max only) |
| `/release-notes` | View changelog |
| `/reload-plugins` | Reload all active plugins |
| `/remote-control` | Enable remote control (alias: `/rc`) |
| `/remote-env` | Configure remote environment for web sessions |
| `/rename [name]` | Rename session (auto-generates if no name given) |
| `/resume [session]` | Resume conversation (alias: `/continue`) |
| `/rewind` | Rewind conversation/code to previous point (alias: `/checkpoint`) |
| `/sandbox` | Toggle sandbox mode |
| `/security-review` | Analyze branch changes for security vulnerabilities |
| `/skills` | List available skills |
| `/stats` | Visualize daily usage and session history |
| `/status` | Show version, model, account, connectivity |
| `/statusline` | Configure status line display |
| `/stickers` | Order Claude Code stickers |
| `/tasks` | List and manage background tasks |
| `/terminal-setup` | Configure terminal keybindings |
| `/theme` | Change color theme |
| `/upgrade` | Open upgrade page |
| `/usage` | Show plan usage and rate limits |
| `/vim` | Toggle Vim editing mode |
| `/voice` | Toggle push-to-talk voice dictation |

MCP servers can expose prompts as commands using `/mcp__<server>__<prompt>` format.

### Keyboard Shortcuts

**General controls:**

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+F` | Kill all background agents (press twice to confirm) |
| `Ctrl+G` | Open in default text editor |
| `Ctrl+L` | Clear terminal screen (keeps history) |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` / `Cmd+V` / `Alt+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Esc+Esc` | Rewind or summarize |
| `Shift+Tab` / `Alt+M` | Toggle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |

**Text editing:** `Ctrl+K` (delete to EOL), `Ctrl+U` (delete line), `Ctrl+Y` (paste deleted), `Alt+Y` (cycle paste history), `Alt+B/F` (word navigation).

**Multiline input:** `\` + Enter (all terminals), `Option+Enter` (macOS default), `Shift+Enter` (iTerm2/WezTerm/Ghostty/Kitty natively; `/terminal-setup` for others), `Ctrl+J` (line feed).

**Quick commands:** `/` for commands/skills, `!` for bash mode, `@` for file path autocomplete. Hold `Space` for push-to-talk voice input.

### Vim Mode

Enable with `/vim` or `/config`. Set permanently via `editorMode: "vim"` in `~/.claude.json`.

**Modes:** `Esc` to NORMAL; `i`/`I`, `a`/`A`, `o`/`O` to INSERT.

**Navigation (NORMAL):** `h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f`/`F`/`t`/`T` with `;`/`,` repeat.

**Editing (NORMAL):** `x`, `dd`/`D`, `dw`/`de`/`db`, `cc`/`C`, `cw`/`ce`/`cb`, `yy`/`Y`, `yw`/`ye`/`yb`, `p`/`P`, `>>`/`<<`, `J`, `.` (repeat).

**Text objects:** `iw`/`aw`, `iW`/`aW`, `i"`/`a"`, `i'`/`a'`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`.

### Background Bash Commands

Run commands in the background by prompting Claude or pressing `Ctrl+B` on a running command. Output is buffered and retrievable via `TaskOutput`. Auto-terminated at 5GB. Disable with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

Bash mode (`!` prefix) runs commands directly without Claude interpretation, adds output to conversation context, and supports `Tab` autocomplete from previous commands.

### Prompt Suggestions

Grayed-out suggestions appear based on git history (first turn) or conversation context (subsequent turns). Press `Tab` to accept or `Enter` to accept and submit. Disable with `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false`.

### Side Questions (/btw)

Ask quick questions without adding to conversation history. Answers from current context only (no tool access). Available while Claude is working. Reuses prompt cache for minimal cost.

### Task List

Claude creates task lists for multi-step work. `Ctrl+T` toggles visibility. Persists across compactions. Share across sessions with `CLAUDE_CODE_TASK_LIST_ID=<name>`.

### PR Review Status

Clickable PR link in footer with colored underline (green = approved, yellow = pending, red = changes requested, gray = draft, purple = merged). Requires `gh` CLI. Updates every 60 seconds.

### Customizable Keybindings

Configure in `~/.claude/keybindings.json` (open with `/keybindings`). Changes auto-detected without restart.

**Binding contexts:** Global, Chat, Autocomplete, Settings, Confirmation, Tabs, Help, Transcript, HistorySearch, Task, ThemePicker, Attachments, Footer, MessageSelector, DiffDialog, ModelPicker, Select, Plugin.

**Action format:** `namespace:action` (e.g., `chat:submit`, `app:toggleTodos`).

**Keystroke syntax:** Modifiers with `+` (`ctrl+k`, `shift+tab`, `meta+p`, `ctrl+shift+c`). Uppercase letter alone implies Shift (`K` = `shift+k`). Chords separated by spaces (`ctrl+k ctrl+s`). Unbind with `null`.

**Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`. **Terminal conflicts:** `Ctrl+B` (tmux), `Ctrl+A` (screen), `Ctrl+Z` (SIGTSTP).

### Terminal Configuration

**Line breaks:** Shift+Enter works natively in iTerm2, WezTerm, Ghostty, Kitty. Run `/terminal-setup` for VS Code, Alacritty, Zed, Warp. Option+Enter requires "Use Option as Meta Key" in terminal settings.

**Notifications:** iTerm2 requires enabling "Notification Center Alerts" and "Send escape sequence-generated alerts". Kitty and Ghostty work without setup. Tmux requires `set -g allow-passthrough on`. Use notification hooks for other terminals.

**Large inputs:** Avoid direct pasting of very long content; use file-based workflows instead. VS Code terminal is especially prone to truncation.

### Tools Reference

| Tool | Description | Permission |
|:-----|:------------|:-----------|
| `Agent` | Spawn subagent with own context window | No |
| `AskUserQuestion` | Multiple-choice questions for requirements | No |
| `Bash` | Execute shell commands | Yes |
| `CronCreate`/`Delete`/`List` | Schedule recurring/one-shot prompts in session | No |
| `Edit` | Targeted file edits | Yes |
| `EnterPlanMode`/`ExitPlanMode` | Switch to/from plan mode | No / Yes |
| `EnterWorktree`/`ExitWorktree` | Create/exit isolated git worktree | No |
| `Glob` | Find files by pattern | No |
| `Grep` | Search file contents | No |
| `ListMcpResourcesTool` | List MCP server resources | No |
| `LSP` | Code intelligence (type errors, go-to-definition, references, symbols) | No |
| `NotebookEdit` | Modify Jupyter notebook cells | Yes |
| `Read` | Read file contents | No |
| `ReadMcpResourceTool` | Read MCP resource by URI | No |
| `Skill` | Execute a skill in main conversation | Yes |
| `TaskCreate`/`Get`/`List`/`Output`/`Stop`/`Update` | Manage background tasks and task list | No |
| `TodoWrite` | Session task checklist (non-interactive/Agent SDK) | No |
| `ToolSearch` | Search/load deferred tools (MCP tool search) | No |
| `WebFetch` | Fetch URL content | Yes |
| `WebSearch` | Web search | Yes |
| `Write` | Create or overwrite files | Yes |

### Bash Tool Behavior

- Working directory persists across commands (reset with `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1`)
- Environment variables do not persist between commands
- Activate virtualenv/conda before launching Claude Code
- Use `CLAUDE_ENV_FILE` or a `SessionStart` hook to persist env vars across Bash commands

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) -- all CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth login/logout/status, claude agents, claude mcp, claude remote-control), complete CLI flags table (--add-dir, --agent, --agents, --allow-dangerously-skip-permissions, --allowedTools, --append-system-prompt, --append-system-prompt-file, --bare, --betas, --channels, --chrome, --continue, --dangerously-load-development-channels, --dangerously-skip-permissions, --debug, --disable-slash-commands, --disallowedTools, --effort, --fallback-model, --fork-session, --from-pr, --ide, --init, --init-only, --include-partial-messages, --input-format, --json-schema, --maintenance, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --no-chrome, --no-session-persistence, --output-format, --permission-mode, --permission-prompt-tool, --plugin-dir, --print, --remote, --remote-control, --resume, --session-id, --setting-sources, --settings, --strict-mcp-config, --system-prompt, --system-prompt-file, --teleport, --teammate-mode, --tools, --verbose, --version, --worktree), system prompt flags (replace vs append, mutual exclusivity rules)
- [Built-in commands](references/claude-code-commands.md) -- complete table of slash commands (/add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /branch, /help, /hooks, /ide, /init, /insights, /install-github-app, /install-slack-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /model, /passes, /permissions, /plan, /plugin, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /review, /rewind, /sandbox, /security-review, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim, /voice), command aliases, argument syntax, MCP prompts as commands
- [Interactive mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts (general controls, text editing, theme/display, multiline input, quick commands, voice input), Vim editor mode (mode switching, navigation, editing, text objects), command history and Ctrl+R reverse search, background bash commands (Ctrl+B backgrounding, TaskOutput, 5GB limit, CLAUDE_CODE_DISABLE_BACKGROUND_TASKS), bash mode with prefix-exclamation (Tab autocomplete from previous commands), prompt suggestions (Tab/Enter to accept, CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION), side questions with /btw (ephemeral overlay, no tool access, available during Claude's turns, prompt cache reuse), task list (Ctrl+T toggle, CLAUDE_CODE_TASK_LIST_ID for shared lists), PR review status (colored underline by state, gh CLI requirement)
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) -- keybindings.json configuration format, binding contexts (Global, Chat, Autocomplete, Settings, Confirmation, Tabs, Help, Transcript, HistorySearch, Task, ThemePicker, Attachments, Footer, MessageSelector, DiffDialog, ModelPicker, Select, Plugin), available actions by namespace (app, history, chat, autocomplete, confirm, permission, transcript, historySearch, task, theme, help, tabs, attachments, footer, messageSelector, diff, modelPicker, select, plugin, settings, voice), keystroke syntax (modifiers, uppercase letters, chords, special keys), unbinding with null, reserved shortcuts (Ctrl+C, Ctrl+D), terminal conflicts (tmux, screen, SIGTSTP), vim mode interaction, validation and /doctor
- [Optimize your terminal setup](references/claude-code-terminal-config.md) -- themes and /config, custom status line with /statusline, line break methods (backslash-Enter, Shift+Enter, Option+Enter, /terminal-setup for VS Code/Alacritty/Zed/Warp), Option as Meta configuration (Terminal.app, iTerm2, VS Code), notification setup (iTerm2 Notification Center Alerts, Kitty/Ghostty native, tmux passthrough with allow-passthrough, notification hooks for other terminals), handling large inputs (file-based workflows, VS Code truncation), Vim mode setup and supported subset
- [Tools reference](references/claude-code-tools-reference.md) -- complete tool list with permission requirements (Agent, AskUserQuestion, Bash, CronCreate/Delete/List, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, Read, ReadMcpResourceTool, Skill, TaskCreate/Get/List/Output/Stop/Update, TodoWrite, ToolSearch, WebFetch, WebSearch, Write), Bash tool behavior (working directory persistence, env var non-persistence, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR, CLAUDE_ENV_FILE, virtualenv/conda activation)

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Built-in commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Optimize your terminal setup: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
