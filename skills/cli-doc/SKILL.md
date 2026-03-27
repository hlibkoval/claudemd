---
name: cli-doc
description: Complete documentation for the Claude Code CLI -- command-line flags, built-in slash commands, interactive mode features, keyboard shortcuts, keybinding customization, terminal configuration, and the tools reference. Covers all launch-time flags (--print/-p, --continue/-c, --resume/-r, --model, --system-prompt, --append-system-prompt, --bare, --dangerously-skip-permissions, --permission-mode, --allowedTools, --disallowedTools, --tools, --mcp-config, --json-schema, --output-format, --input-format, --max-turns, --max-budget-usd, --effort, --worktree/-w, --add-dir, --agent, --agents, --remote, --remote-control, --teleport, --chrome, --plugin-dir, --settings, --debug, --verbose, --name/-n, --from-pr, --fork-session, --session-id, --channels, --enable-auto-mode, --fallback-model, --bare), all slash commands (/compact, /clear, /config, /model, /permissions, /diff, /export, /resume, /rewind, /plan, /vim, /effort, /init, /memory, /mcp, /plugin, /agents, /hooks, /skills, /btw, /copy, /context, /cost, /usage, /doctor, /branch, /color, /schedule, /security-review, /pr-comments, /remote-control, /statusline, /voice, /stats, /insights, /tasks, /sandbox), interactive mode features (keyboard shortcuts, multiline input, Vim editor mode, command history, reverse search, background bash commands, bash mode with prefix, prompt suggestions, /btw side questions, task list, PR review status), custom keybindings (keybindings.json configuration, contexts, actions, keystroke syntax, chords, reserved shortcuts, vim mode interaction), terminal setup (Shift+Enter configuration, Option as Meta key, notifications, large input handling), and the built-in tools reference table (Agent, Bash, Edit, Read, Write, Glob, Grep, WebFetch, WebSearch, NotebookEdit, Skill, EnterWorktree, ExitWorktree, LSP, PowerShell, TodoWrite, TaskCreate/TaskList/TaskUpdate/TaskGet/TaskStop, CronCreate/CronList/CronDelete, EnterPlanMode, ExitPlanMode, ToolSearch, AskUserQuestion, ListMcpResourcesTool, ReadMcpResourceTool). Load when discussing Claude Code CLI flags, command-line options, slash commands, built-in commands, keyboard shortcuts, keybindings, interactive mode, vim mode, terminal configuration, terminal setup, Shift+Enter, multiline input, background tasks, bash mode, prompt suggestions, /btw, tools reference, tool permissions, Bash tool behavior, PowerShell tool, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR, CLAUDE_ENV_FILE, or any CLI usage topic for Claude Code.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface -- covering launch flags, built-in commands, interactive mode, keybinding customization, terminal configuration, and the tools reference.

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
| `claude auth login` | Sign in (`--email`, `--sso`, `--console` options) |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List configured subagents |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins (alias: `claude plugins`) |
| `claude remote-control` | Start a Remote Control server |

### Key CLI Flags

**Session control:**

| Flag | Purpose |
|:-----|:--------|
| `--continue`, `-c` | Continue most recent conversation |
| `--resume`, `-r` | Resume by ID or name, or show picker |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a GitHub PR |
| `--name`, `-n` | Set display name for the session |
| `--session-id` | Use a specific UUID |

**Model and behavior:**

| Flag | Purpose |
|:-----|:--------|
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Set effort level (`low`, `medium`, `high`, `max`) |
| `--fallback-model` | Fallback model when default is overloaded (print mode) |
| `--enable-auto-mode` | Unlock auto mode in `Shift+Tab` cycle |

**System prompt:**

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replace entire default prompt |
| `--system-prompt-file` | Replace with file contents |
| `--append-system-prompt` | Append to default prompt |
| `--append-system-prompt-file` | Append file contents to default |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either. Prefer append for most use cases to preserve built-in capabilities.

**Output and format (print mode):**

| Flag | Purpose |
|:-----|:--------|
| `--print`, `-p` | Non-interactive print mode |
| `--output-format` | `text`, `json`, or `stream-json` |
| `--input-format` | `text` or `stream-json` |
| `--json-schema` | Validated JSON output matching a schema |
| `--max-turns` | Limit agentic turns |
| `--max-budget-usd` | Spending cap for API calls |
| `--no-session-persistence` | Do not save session to disk |
| `--include-partial-messages` | Include partial streaming events |

**Tools and permissions:**

| Flag | Purpose |
|:-----|:--------|
| `--allowedTools` | Tools that skip permission prompts |
| `--disallowedTools` | Tools removed from context entirely |
| `--tools` | Restrict available built-in tools |
| `--permission-mode` | Start in a specific permission mode |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--allow-dangerously-skip-permissions` | Enable bypass as composable option |
| `--permission-prompt-tool` | MCP tool for permission prompts in non-interactive mode |

**Environment and integration:**

| Flag | Purpose |
|:-----|:--------|
| `--add-dir` | Add extra working directories |
| `--agent` | Specify agent for session |
| `--agents` | Define subagents via JSON |
| `--mcp-config` | Load MCP servers from JSON files |
| `--strict-mcp-config` | Only use MCP from `--mcp-config` |
| `--plugin-dir` | Load plugins from directory |
| `--settings` | Load additional settings JSON |
| `--setting-sources` | Comma-separated sources (`user`, `project`, `local`) |
| `--chrome` / `--no-chrome` | Enable/disable Chrome integration |
| `--ide` | Auto-connect to IDE on startup |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--bare` | Minimal mode: skip auto-discovery for faster start |
| `--remote` | Create web session on claude.ai |
| `--remote-control`, `--rc` | Interactive session with Remote Control |
| `--teleport` | Resume web session in local terminal |
| `--teammate-mode` | Agent team display (`auto`, `in-process`, `tmux`) |
| `--channels` | MCP channel notifications to listen for |
| `--debug` | Debug mode with category filtering |
| `--verbose` | Verbose logging |
| `--init` / `--init-only` | Run initialization hooks (with or without session) |
| `--maintenance` | Run maintenance hooks and exit |
| `--betas` | Beta headers for API requests |
| `--disable-slash-commands` | Disable all skills and commands |

### Built-in Slash Commands

| Command | Purpose |
|:--------|:--------|
| `/add-dir <path>` | Add working directory to session |
| `/agents` | Manage agent configurations |
| `/btw <question>` | Quick side question (no context added) |
| `/branch [name]` | Branch conversation (alias: `/fork`) |
| `/chrome` | Configure Chrome settings |
| `/clear` | Clear conversation (aliases: `/reset`, `/new`) |
| `/color [color]` | Set prompt bar color |
| `/compact [instructions]` | Compact conversation with optional focus |
| `/config` | Open Settings (alias: `/settings`) |
| `/context` | Visualize context usage |
| `/copy [N]` | Copy assistant response to clipboard |
| `/cost` | Show token usage |
| `/desktop` | Continue in Desktop app (alias: `/app`) |
| `/diff` | Interactive diff viewer |
| `/doctor` | Diagnose installation |
| `/effort [level]` | Set effort level (`low`/`medium`/`high`/`max`/`auto`) |
| `/exit` | Exit CLI (alias: `/quit`) |
| `/export [file]` | Export conversation as text |
| `/extra-usage` | Configure extra usage for rate limits |
| `/fast [on\|off]` | Toggle fast mode |
| `/feedback` | Submit feedback (alias: `/bug`) |
| `/help` | Show help |
| `/hooks` | View hook configurations |
| `/ide` | Manage IDE integrations |
| `/init` | Initialize project with CLAUDE.md |
| `/insights` | Analyze session patterns |
| `/install-github-app` | Set up Claude GitHub Actions |
| `/install-slack-app` | Install Claude Slack app |
| `/keybindings` | Open keybindings config file |
| `/login` / `/logout` | Sign in/out |
| `/mcp` | Manage MCP connections |
| `/memory` | Edit CLAUDE.md and auto-memory |
| `/model [model]` | Select/change model |
| `/passes` | Share free week (eligible accounts) |
| `/permissions` | View/update permissions (alias: `/allowed-tools`) |
| `/plan [desc]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/privacy-settings` | Privacy settings (Pro/Max only) |
| `/release-notes` | View changelog |
| `/reload-plugins` | Reload active plugins |
| `/remote-control` | Enable Remote Control (alias: `/rc`) |
| `/remote-env` | Configure remote environment |
| `/rename [name]` | Rename session |
| `/resume [session]` | Resume conversation (alias: `/continue`) |
| `/rewind` | Rewind conversation/code (alias: `/checkpoint`) |
| `/sandbox` | Toggle sandbox mode |
| `/schedule [desc]` | Create/manage scheduled tasks |
| `/security-review` | Analyze branch changes for vulnerabilities |
| `/skills` | List available skills |
| `/stats` | Visualize usage and streaks |
| `/status` | Show version, model, account info |
| `/statusline` | Configure status line |
| `/stickers` | Order Claude Code stickers |
| `/tasks` | List/manage background tasks |
| `/terminal-setup` | Configure terminal keybindings |
| `/theme` | Change color theme |
| `/upgrade` | Open plan upgrade page |
| `/usage` | Show plan usage and rate limits |
| `/vim` | Toggle Vim/Normal editing |
| `/voice` | Toggle push-to-talk voice dictation |

### Keyboard Shortcuts (Interactive Mode)

**General controls:**

| Shortcut | Action |
|:---------|:-------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open in external text editor |
| `Ctrl+L` | Clear terminal screen (keeps history) |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` / `Cmd+V` / `Alt+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Shift+Tab` | Cycle permission modes |
| `Alt+P` | Switch model |
| `Alt+T` | Toggle extended thinking |
| `Alt+O` | Toggle fast mode |
| `Esc+Esc` | Rewind or summarize |

**Multiline input:**

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + `Enter` |
| macOS default | `Option+Enter` |
| Shift+Enter | Works natively in iTerm2, WezTerm, Ghostty, Kitty |
| Control sequence | `Ctrl+J` |

For other terminals (VS Code, Alacritty, Zed, Warp), run `/terminal-setup` to install the Shift+Enter binding.

**Quick prefixes:**

| Prefix | Purpose |
|:-------|:--------|
| `/` | Slash command or skill |
| `!` | Bash mode (run command directly) |
| `@` | File path autocomplete |

### Keybinding Customization

Configuration file: `~/.claude/keybindings.json` (open with `/keybindings`). Changes auto-apply without restart.

**Contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`

**Key actions (namespace:action format):**

| Action | Default | Description |
|:-------|:--------|:------------|
| `app:interrupt` | Ctrl+C | Cancel operation |
| `app:exit` | Ctrl+D | Exit |
| `app:toggleTodos` | Ctrl+T | Toggle task list |
| `app:toggleTranscript` | Ctrl+O | Toggle verbose |
| `chat:submit` | Enter | Submit message |
| `chat:cycleMode` | Shift+Tab | Cycle permission modes |
| `chat:modelPicker` | Cmd+P | Open model picker |
| `chat:externalEditor` | Ctrl+G | Open external editor |
| `chat:imagePaste` | Ctrl+V | Paste image |

Set an action to `null` to unbind. Chords use space-separated keys (e.g., `ctrl+k ctrl+s`).

**Keystroke syntax:** modifiers joined with `+` (`ctrl`, `alt`/`opt`, `shift`, `meta`/`cmd`). Standalone uppercase letter implies Shift (e.g., `K` = `shift+k`). Special keys: `escape`, `enter`, `tab`, `space`, `up`, `down`, `left`, `right`, `backspace`, `delete`.

**Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`

**Terminal conflicts:** `Ctrl+B` (tmux prefix), `Ctrl+A` (screen prefix), `Ctrl+Z` (SIGTSTP)

### Terminal Configuration

**Option as Meta key (macOS):** required for `Alt+B`, `Alt+F`, `Alt+Y`, `Alt+M`, `Alt+P` shortcuts.

| Terminal | Setting |
|:---------|:--------|
| iTerm2 | Profiles > Keys > Left/Right Option = "Esc+" |
| Terminal.app | Profiles > Keyboard > "Use Option as Meta Key" |
| VS Code | `terminal.integrated.macOptionIsMeta: true` |

**Notifications:** Kitty and Ghostty work without config. iTerm2 requires enabling "Notification Center Alerts" and "Send escape sequence-generated alerts". For tmux, set `allow-passthrough on`. Other terminals: use notification hooks.

### Tools Reference

| Tool | Description | Permission |
|:-----|:------------|:-----------|
| `Agent` | Spawn subagent with own context | No |
| `AskUserQuestion` | Ask multiple-choice questions | No |
| `Bash` | Execute shell commands | Yes |
| `CronCreate` / `CronList` / `CronDelete` | Session-scoped scheduled tasks | No |
| `Edit` | Targeted file edits | Yes |
| `EnterPlanMode` / `ExitPlanMode` | Design approach before coding | No / Yes |
| `EnterWorktree` / `ExitWorktree` | Git worktree isolation | No |
| `Glob` | Find files by pattern | No |
| `Grep` | Search file contents | No |
| `ListMcpResourcesTool` / `ReadMcpResourceTool` | MCP resource access | No |
| `LSP` | Code intelligence via language servers | No |
| `NotebookEdit` | Modify Jupyter notebook cells | Yes |
| `PowerShell` | PowerShell commands on Windows (opt-in) | Yes |
| `Read` | Read file contents | No |
| `Skill` | Execute a skill | Yes |
| `TaskCreate` / `TaskList` / `TaskUpdate` / `TaskGet` / `TaskStop` | Task list management | No |
| `TodoWrite` | Session task checklist (non-interactive/Agent SDK) | No |
| `ToolSearch` | Search/load deferred tools | No |
| `WebFetch` | Fetch URL content | Yes |
| `WebSearch` | Perform web searches | Yes |
| `Write` | Create or overwrite files | Yes |

**Bash tool behavior:** each command runs in a separate process. Working directory persists; environment variables do not. Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to reset to project dir after each command. Use `CLAUDE_ENV_FILE` or a SessionStart hook for persistent env vars.

**PowerShell tool (Windows, opt-in):** enable with `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. Auto-detects `pwsh.exe` (7+) with fallback to `powershell.exe` (5.1). Additional settings: `defaultShell: "powershell"` for interactive commands, `shell: "powershell"` on hooks, `shell: powershell` in skill frontmatter.

### Interactive Mode Features

**Background bash commands:** long-running commands can run asynchronously. Press `Ctrl+B` to background a running command, or prompt Claude to run in background. Output written to file, auto-cleaned on exit, terminated if output exceeds 5GB. Disable with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

**Bash mode (`!` prefix):** run commands directly, output added to conversation context. Supports Tab autocomplete from previous commands. Exit with `Escape`, `Backspace`, or `Ctrl+U` on empty prompt.

**Prompt suggestions:** context-aware suggestions appear after responses, based on git history and conversation. Press `Tab` to accept, `Enter` to accept and submit. Disable with `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false`.

**/btw side questions:** quick ephemeral questions with full conversation visibility but no tool access. Available while Claude is working. Single response, low cost (reuses prompt cache). Dismiss with `Space`, `Enter`, or `Escape`.

**Task list:** tracks multi-step work progress. Toggle with `Ctrl+T`. Persists across compactions. Share across sessions with `CLAUDE_CODE_TASK_LIST_ID`.

**PR review status:** clickable PR link in footer with colored underline (green=approved, yellow=pending, red=changes requested, gray=draft, purple=merged). Updates every 60 seconds. Requires `gh` CLI.

**Vim mode:** enable with `/vim` or set `editorMode: "vim"` in `~/.claude.json`. Supports mode switching, HJKL navigation, word/line motions, f/F/t/T character jumps, delete/change/yank operators, text objects, indent, join, dot-repeat.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) -- all CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude auto-mode, claude mcp, claude plugin, claude remote-control) and all launch-time flags with descriptions, examples, and system prompt flag behavior
- [Built-in commands](references/claude-code-commands.md) -- complete table of slash commands available in interactive mode (/add-dir, /agents, /btw, /branch, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /help, /hooks, /ide, /init, /insights, /install-github-app, /install-slack-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /model, /passes, /permissions, /plan, /plugin, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /review, /rewind, /sandbox, /schedule, /security-review, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim, /voice), MCP prompts as commands
- [Interactive mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts (general controls, text editing, theme/display, multiline input, quick commands, transcript viewer, voice input), built-in commands overview, Vim editor mode (mode switching, navigation, editing, text objects), command history and reverse search, background bash commands, bash mode with prefix, prompt suggestions, /btw side questions, task list, PR review status
- [Keybinding customization](references/claude-code-keybindings.md) -- keybindings.json configuration format, contexts (Global, Chat, Autocomplete, Settings, Confirmation, Tabs, Help, Transcript, HistorySearch, Task, ThemePicker, Attachments, Footer, MessageSelector, DiffDialog, ModelPicker, Select, Plugin), all available actions by namespace (app, history, chat, autocomplete, confirm, permission, transcript, historySearch, task, theme, help, tabs, attachments, footer, messageSelector, diff, modelPicker, select, plugin, settings, voice), keystroke syntax (modifiers, uppercase letters, chords, special keys), unbinding defaults, reserved shortcuts, terminal conflicts, vim mode interaction, validation
- [Terminal configuration](references/claude-code-terminal-config.md) -- themes and appearance, line break setup (Shift+Enter for various terminals, Option+Enter for iTerm2/Terminal.app/VS Code), /terminal-setup command, notification setup (iTerm2, Kitty, Ghostty, tmux passthrough, notification hooks), handling large inputs, Vim mode configuration
- [Tools reference](references/claude-code-tools-reference.md) -- complete tools table with permission requirements (Agent, AskUserQuestion, Bash, CronCreate/CronList/CronDelete, Edit, EnterPlanMode, ExitPlanMode, EnterWorktree, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, PowerShell, Read, ReadMcpResourceTool, Skill, TaskCreate/TaskGet/TaskList/TaskOutput/TaskStop/TaskUpdate, TodoWrite, ToolSearch, WebFetch, WebSearch, Write), Bash tool behavior (working directory persistence, env var non-persistence, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR, CLAUDE_ENV_FILE, SessionStart hook), PowerShell tool (opt-in with CLAUDE_CODE_USE_POWERSHELL_TOOL, auto-detection, defaultShell/hook shell/skill shell settings, preview limitations)

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Built-in commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybinding customization: https://code.claude.com/docs/en/keybindings.md
- Terminal configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
