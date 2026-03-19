---
name: cli-doc
description: Complete documentation for the Claude Code CLI and interactive interface -- CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude mcp, claude remote-control), CLI flags (--add-dir, --agent, --agents, --allowedTools, --disallowedTools, --append-system-prompt, --system-prompt, --system-prompt-file, --model, --effort, --print, --output-format, --input-format, --json-schema, --max-turns, --max-budget-usd, --continue, --resume, --fork-session, --from-pr, --name, --session-id, --permission-mode, --dangerously-skip-permissions, --mcp-config, --strict-mcp-config, --tools, --chrome, --no-chrome, --plugin-dir, --remote, --remote-control, --teleport, --worktree, --debug, --verbose, --betas, --ide, --init, --maintenance, --setting-sources, --settings, --teammate-mode, --fallback-model, --no-session-persistence, --include-partial-messages, --disable-slash-commands), system prompt flags (--system-prompt, --system-prompt-file, --append-system-prompt, --append-system-prompt-file), built-in commands (/add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /branch, /help, /hooks, /ide, /init, /insights, /install-github-app, /install-slack-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /model, /passes, /permissions, /plan, /plugin, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /review, /rewind, /sandbox, /security-review, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim, /voice), MCP prompts (/mcp__server__prompt), interactive mode (keyboard shortcuts, Ctrl+C/D/G/L/O/R/V/B/T, Shift+Tab, Alt+P/T, text editing Ctrl+K/U/Y, multiline input, Vim editor mode with NORMAL/INSERT modes, navigation h/j/k/l/w/e/b, editing dd/dw/cc/cw/yy/p, text objects iw/aw, command history, Ctrl+R reverse search, background bash commands, Ctrl+B backgrounding, bash mode with exclamation prefix, prompt suggestions, /btw side questions, task list Ctrl+T, PR review status), customizable keybindings (~/.claude/keybindings.json, /keybindings command, binding contexts Global/Chat/Autocomplete/Settings/Confirmation/Tabs/Help/Transcript/HistorySearch/Task/ThemePicker/Attachments/Footer/MessageSelector/DiffDialog/ModelPicker/Select/Plugin, available actions app/history/chat/autocomplete/confirm/permission/transcript/historySearch/task/theme/help/tabs/attachments/footer/messageSelector/diff/modelPicker/select/plugin/settings/voice, keystroke syntax with modifiers ctrl/alt/shift/meta, chords, special keys, unbinding with null, reserved shortcuts Ctrl+C/Ctrl+D, terminal conflicts Ctrl+B/Ctrl+A/Ctrl+Z, vim mode interaction, validation), terminal configuration (themes, line breaks Shift+Enter setup, /terminal-setup, Option as Meta for iTerm2/Terminal.app/VS Code, notification setup for Kitty/Ghostty/iTerm2, notification hooks, handling large inputs, Vim mode subset), tools reference (Agent, AskUserQuestion, Bash, CronCreate/Delete/List, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, Read, ReadMcpResourceTool, Skill, TaskCreate/Get/List/Output/Stop/Update, TodoWrite, ToolSearch, WebFetch, WebSearch, Write, permission requirements, Bash tool behavior with working directory persistence and env var non-persistence, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR, CLAUDE_ENV_FILE). Load when discussing Claude Code CLI flags, claude commands, CLI reference, interactive mode, keyboard shortcuts, keybindings, built-in commands, slash commands, vim mode, multiline input, background tasks, bash mode, prompt suggestions, /btw side questions, terminal setup, terminal configuration, notification setup, tools reference, tool names, tool permissions, Bash tool behavior, system prompt flags, --print mode, --output-format, --json-schema, --max-turns, --model flag, --effort flag, --permission-mode, --mcp-config, --tools flag, --worktree flag, --remote flag, session management, --resume, --continue, --fork-session, --from-pr, custom keybindings, keybindings.json, binding contexts, keystroke syntax, command history, reverse search, task list, PR review status, or Claude Code terminal and CLI usage.
user-invocable: false
---

# CLI & Interactive Mode Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, built-in commands, interactive mode features, keyboard customization, terminal configuration, and the tools reference.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive), then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation |
| `claude -c -p "query"` | Continue in print mode |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (`--email`, `--sso`, `--console` flags) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List all configured subagents |
| `claude mcp` | Configure MCP servers |
| `claude remote-control` | Start a Remote Control server |

### Key CLI Flags

**Session management:**

| Flag | Purpose |
|:-----|:--------|
| `--continue`, `-c` | Resume most recent conversation |
| `--resume`, `-r` | Resume by session ID or name |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a GitHub PR |
| `--name`, `-n` | Set session display name |
| `--session-id` | Use a specific UUID for the conversation |

**Output and format (print mode):**

| Flag | Purpose |
|:-----|:--------|
| `--print`, `-p` | Non-interactive mode |
| `--output-format` | `text`, `json`, or `stream-json` |
| `--input-format` | `text` or `stream-json` |
| `--json-schema` | Get validated JSON matching a schema |
| `--include-partial-messages` | Include partial streaming events |
| `--no-session-persistence` | Do not save session to disk |

**Model and behavior:**

| Flag | Purpose |
|:-----|:--------|
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | `low`, `medium`, `high`, `max` (Opus 4.6 only) |
| `--fallback-model` | Auto-fallback when default model overloaded |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Maximum dollar spend (print mode) |

**System prompt:**

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replace entire default prompt |
| `--system-prompt-file` | Replace with file contents |
| `--append-system-prompt` | Append to default prompt |
| `--append-system-prompt-file` | Append file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either.

**Permissions and tools:**

| Flag | Purpose |
|:-----|:--------|
| `--permission-mode` | Begin in a specific permission mode (e.g., `plan`) |
| `--dangerously-skip-permissions` | Skip permission prompts |
| `--allowedTools` | Tools that execute without prompting |
| `--disallowedTools` | Tools removed from context entirely |
| `--tools` | Restrict available built-in tools (`""` for none, `"default"` for all) |

**MCP and plugins:**

| Flag | Purpose |
|:-----|:--------|
| `--mcp-config` | Load MCP servers from JSON files |
| `--strict-mcp-config` | Only use servers from `--mcp-config` |
| `--plugin-dir` | Load plugins from directory |

**Other flags:**

| Flag | Purpose |
|:-----|:--------|
| `--add-dir` | Add additional working directories |
| `--agent` | Specify an agent for the session |
| `--agents` | Define subagents dynamically via JSON |
| `--chrome` / `--no-chrome` | Enable/disable Chrome browser integration |
| `--remote` | Create a web session on claude.ai |
| `--remote-control`, `--rc` | Enable remote control from claude.ai |
| `--teleport` | Resume a web session locally |
| `--worktree`, `-w` | Start in an isolated git worktree |
| `--ide` | Auto-connect to IDE on startup |
| `--init` / `--init-only` | Run initialization hooks (optionally exit after) |
| `--maintenance` | Run maintenance hooks and exit |
| `--debug` | Debug mode with category filtering |
| `--verbose` | Verbose logging with full turn-by-turn output |
| `--betas` | Beta headers for API requests |
| `--settings` | Load settings from JSON file or string |
| `--setting-sources` | Choose which setting sources to load |
| `--teammate-mode` | Agent team display mode (`auto`, `in-process`, `tmux`) |
| `--disable-slash-commands` | Disable all skills and commands |
| `--version`, `-v` | Output version number |

### Built-in Commands

Type `/` to see all commands or `/` + letters to filter. Some commands are platform- or plan-dependent.

**Session and navigation:**

| Command | Purpose |
|:--------|:--------|
| `/clear` | Clear conversation history (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Compact conversation with optional focus |
| `/resume [session]` | Resume by ID or name (alias: `/continue`) |
| `/branch [name]` | Branch conversation at this point (alias: `/fork`) |
| `/rewind` | Rewind conversation and/or code (alias: `/checkpoint`) |
| `/exit` | Exit CLI (alias: `/quit`) |
| `/rename [name]` | Rename session; auto-generates if no name given |

**Model and mode:**

| Command | Purpose |
|:--------|:--------|
| `/model [model]` | Select or change model; arrows adjust effort |
| `/effort [level]` | Set effort (`low`/`medium`/`high`/`max`/`auto`) |
| `/fast [on\|off]` | Toggle fast mode |
| `/plan` | Enter plan mode |
| `/vim` | Toggle Vim/Normal editing modes |

**Configuration:**

| Command | Purpose |
|:--------|:--------|
| `/config` | Open Settings interface (alias: `/settings`) |
| `/permissions` | View/update permissions (alias: `/allowed-tools`) |
| `/memory` | Edit CLAUDE.md files, toggle auto-memory |
| `/keybindings` | Open keybindings configuration file |
| `/init` | Initialize project with CLAUDE.md |
| `/theme` | Change color theme |
| `/color [color]` | Set prompt bar color for session |
| `/statusline` | Configure status line |
| `/terminal-setup` | Configure terminal keybindings |

**Information and diagnostics:**

| Command | Purpose |
|:--------|:--------|
| `/help` | Show help and commands |
| `/context` | Visualize context usage |
| `/cost` | Show token usage |
| `/usage` | Show plan limits and rate limit status |
| `/status` | Show version, model, account, connectivity |
| `/stats` | Visualize daily usage, streaks, model preferences |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings |
| `/release-notes` | View changelog |
| `/insights` | Generate usage analysis report |

**Integrations:**

| Command | Purpose |
|:--------|:--------|
| `/mcp` | Manage MCP server connections |
| `/plugin` | Manage plugins |
| `/reload-plugins` | Reload all active plugins |
| `/chrome` | Configure Chrome integration |
| `/ide` | Manage IDE integrations |
| `/agents` | Manage agent configurations |
| `/hooks` | View hook configurations |
| `/skills` | List available skills |
| `/install-github-app` | Set up Claude GitHub Actions |
| `/install-slack-app` | Install Claude Slack app |

**Other:**

| Command | Purpose |
|:--------|:--------|
| `/btw <question>` | Quick side question (no history impact) |
| `/copy [N]` | Copy last response to clipboard |
| `/export [filename]` | Export conversation as text |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/security-review` | Analyze branch changes for vulnerabilities |
| `/add-dir <path>` | Add working directory |
| `/sandbox` | Toggle sandbox mode |
| `/remote-control` | Enable remote control (alias: `/rc`) |
| `/remote-env` | Configure default remote environment |
| `/desktop` | Continue session in Desktop app (alias: `/app`) |
| `/voice` | Toggle push-to-talk voice dictation |
| `/tasks` | List and manage background tasks |
| `/login` / `/logout` | Sign in/out |
| `/feedback` | Submit feedback (alias: `/bug`) |
| `/extra-usage` | Configure extra usage for rate limits |
| `/upgrade` | Open upgrade page |
| `/privacy-settings` | View privacy settings (Pro/Max only) |
| `/mobile` | QR code for mobile app (aliases: `/ios`, `/android`) |
| `/passes` | Share free week of Claude Code |
| `/stickers` | Order stickers |

MCP servers can also expose prompts as `/mcp__<server>__<prompt>` commands.

### Keyboard Shortcuts

**General controls:**

| Shortcut | Action |
|:---------|:-------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` | Open in default text editor |
| `Ctrl+L` | Clear terminal screen |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+F` | Kill all background agents (press twice to confirm) |
| `Shift+Tab` / `Alt+M` | Toggle permission modes |
| `Alt+P` | Switch model |
| `Alt+T` | Toggle extended thinking |
| `Esc+Esc` | Rewind or summarize |

**Text editing:**

| Shortcut | Action |
|:---------|:-------|
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete entire line |
| `Ctrl+Y` | Paste deleted text |
| `Alt+Y` | Cycle paste history (after `Ctrl+Y`) |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

**Multiline input:**

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + `Enter` |
| macOS default | `Option+Enter` |
| Shift+Enter | Works in iTerm2, WezTerm, Ghostty, Kitty natively |
| Control sequence | `Ctrl+J` |

Run `/terminal-setup` for Shift+Enter support in VS Code, Alacritty, Zed, Warp.

**Quick prefixes:**

| Prefix | Effect |
|:-------|:-------|
| `/` | Command or skill |
| `!` | Bash mode (run shell command directly) |
| `@` | File path autocomplete |

**Voice:** Hold `Space` for push-to-talk dictation (when enabled).

### Vim Editor Mode

Enable with `/vim` or via `/config`. Supports mode switching (`Esc` to NORMAL, `i`/`I`/`a`/`A`/`o`/`O` to INSERT), navigation (`h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f`/`F`/`t`/`T` with `;`/`,`), editing (`x`, `dd`/`D`, `dw`/`de`/`db`, `cc`/`C`, `cw`/`ce`/`cb`, `.`), yank/paste (`yy`/`Y`, `yw`/`ye`/`yb`, `p`/`P`), text objects (`iw`/`aw`, `iW`/`aW`, `i"`/`a"`, `i'`/`a'`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`), indentation (`>>`/`<<`), and line join (`J`).

### Interactive Features

**Background bash commands:** Prompt Claude to run in background, or press `Ctrl+B` to background a running command. Output buffered via TaskOutput tool. Auto-terminated at 5GB. Disable with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

**Bash mode (`!` prefix):** Run shell commands directly without Claude interpreting them. Adds output to conversation context. Supports Tab autocomplete from previous `!` commands.

**Prompt suggestions:** Grayed-out suggestions appear based on git history and conversation. Press `Tab` to accept, `Enter` to accept and submit. Disable with `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false`.

**Side questions (`/btw`):** Ask quick questions without adding to history. Runs independently while Claude works. No tool access; answers from context only. Press `Space`, `Enter`, or `Escape` to dismiss.

**Task list:** Claude creates task lists for multi-step work. Toggle with `Ctrl+T`. Tasks persist across compactions. Share across sessions with `CLAUDE_CODE_TASK_LIST_ID`.

**PR review status:** Clickable PR link in footer with colored underline (green=approved, yellow=pending, red=changes requested, gray=draft, purple=merged). Requires `gh` CLI.

**Command history:** Per working directory. Resets on `/clear`. Navigate with Up/Down. `Ctrl+R` for reverse search.

### Custom Keybindings

Configure at `~/.claude/keybindings.json` (open with `/keybindings`). Changes auto-detected without restart.

**Binding contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`.

**Key actions (namespace:action format):**

| Namespace | Key actions |
|:----------|:------------|
| `app` | `interrupt`, `exit`, `toggleTodos`, `toggleTranscript` |
| `chat` | `cancel`, `cycleMode`, `modelPicker`, `thinkingToggle`, `submit`, `undo`, `externalEditor`, `stash`, `imagePaste` |
| `history` | `search`, `previous`, `next` |
| `autocomplete` | `accept`, `dismiss`, `previous`, `next` |
| `confirm` | `yes`, `no`, `previous`, `next`, `nextField`, `previousField`, `cycleMode`, `toggleExplanation` |
| `permission` | `toggleDebug` |
| `voice` | `pushToTalk` |

**Keystroke syntax:** Modifiers with `+` (`ctrl+k`, `shift+tab`, `meta+p`). Standalone uppercase implies Shift (`K` = `shift+k`). Chords separated by spaces (`ctrl+k ctrl+s`). Special keys: `escape`, `enter`, `tab`, `space`, `up`/`down`/`left`/`right`, `backspace`, `delete`.

**Unbind:** Set action to `null`. **Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`. **Terminal conflicts:** `Ctrl+B` (tmux), `Ctrl+A` (screen), `Ctrl+Z` (suspend).

Vim mode and keybindings operate independently: Vim handles text-level input, keybindings handle component-level actions.

### Terminal Configuration

**Option as Meta (macOS):** Required for Alt-key shortcuts.

| Terminal | Setting |
|:---------|:--------|
| iTerm2 | Profiles > Keys > Left/Right Option key: "Esc+" |
| Terminal.app | Profiles > Keyboard > "Use Option as Meta Key" |
| VS Code | `terminal.integrated.macOptionIsMeta: true` |

**Notifications:** Kitty and Ghostty work natively. iTerm2: enable in Profiles > Terminal > Notification Center Alerts > filter for escape-sequence alerts. Other terminals: use notification hooks.

**Large inputs:** Avoid direct pasting of very long content; use file-based workflows instead.

### Tools Reference

| Tool | Permission | Description |
|:-----|:-----------|:------------|
| `Agent` | No | Spawn a subagent with its own context |
| `AskUserQuestion` | No | Ask multiple-choice questions |
| `Bash` | Yes | Execute shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Manage in-session scheduled tasks |
| `Edit` | Yes | Make targeted file edits |
| `EnterPlanMode` | No | Switch to plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Manage git worktree sessions |
| `ExitPlanMode` | Yes | Present plan and exit plan mode |
| `Glob` | No | Find files by pattern |
| `Grep` | No | Search file contents |
| `ListMcpResourcesTool` / `ReadMcpResourceTool` | No | List/read MCP resources |
| `LSP` | No | Code intelligence via language servers |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `Read` | No | Read file contents |
| `Skill` | Yes | Execute a skill in the conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskOutput` / `TaskStop` / `TaskUpdate` | No | Manage tasks and background processes |
| `TodoWrite` | No | Manage task checklist (non-interactive/Agent SDK) |
| `ToolSearch` | No | Search and load deferred tools |
| `WebFetch` | Yes | Fetch content from a URL |
| `WebSearch` | Yes | Perform web searches |
| `Write` | Yes | Create or overwrite files |

**Bash tool behavior:** Each command runs in a separate process. Working directory persists across commands. Environment variables do not persist. Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to reset cwd after each command. Use `CLAUDE_ENV_FILE` or a SessionStart hook to persist env vars.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) -- CLI commands table (claude, claude -p, piped input, claude -c, claude -r, claude update, claude auth login/logout/status, claude agents, claude mcp, claude remote-control), complete CLI flags table (--add-dir, --agent, --agents, --allow-dangerously-skip-permissions, --allowedTools, --append-system-prompt, --append-system-prompt-file, --betas, --chrome, --continue, --dangerously-skip-permissions, --debug, --disable-slash-commands, --disallowedTools, --effort, --fallback-model, --fork-session, --from-pr, --ide, --init, --init-only, --include-partial-messages, --input-format, --json-schema, --maintenance, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --no-chrome, --no-session-persistence, --output-format, --permission-mode, --permission-prompt-tool, --plugin-dir, --print, --remote, --remote-control, --resume, --session-id, --setting-sources, --settings, --strict-mcp-config, --system-prompt, --system-prompt-file, --teleport, --teammate-mode, --tools, --verbose, --version, --worktree), system prompt flags section (replace vs append, mutual exclusivity rules)
- [Built-in commands](references/claude-code-commands.md) -- complete command table (/add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /branch, /help, /hooks, /ide, /init, /insights, /install-github-app, /install-slack-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /model, /passes, /permissions, /plan, /plugin, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /review, /rewind, /sandbox, /security-review, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim, /voice), MCP prompts as commands, command aliases
- [Interactive mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts (general controls, text editing, theme/display, multiline input, quick commands, voice input), built-in commands overview, Vim editor mode (mode switching, NORMAL mode navigation/editing/text objects), command history (per-directory storage, Ctrl+R reverse search), background bash commands (backgrounding with Ctrl+B, TaskOutput, CLAUDE_CODE_DISABLE_BACKGROUND_TASKS), bash mode with exclamation prefix (Tab autocomplete), prompt suggestions (Tab/Enter to accept, CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION), /btw side questions (ephemeral overlay, no tool access, works while Claude is busy), task list (Ctrl+T toggle, CLAUDE_CODE_TASK_LIST_ID), PR review status (colored underline states, gh CLI requirement)
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) -- keybindings.json configuration (bindings array, context blocks), all binding contexts (Global, Chat, Autocomplete, Settings, Confirmation, Tabs, Help, Transcript, HistorySearch, Task, ThemePicker, Attachments, Footer, MessageSelector, DiffDialog, ModelPicker, Select, Plugin), all available actions by namespace (app, history, chat, autocomplete, confirm, permission, transcript, historySearch, task, theme, help, tabs, attachments, footer, messageSelector, diff, modelPicker, select, plugin, settings, voice), keystroke syntax (modifiers, uppercase letters, chords, special keys), unbinding with null, reserved shortcuts (Ctrl+C, Ctrl+D), terminal conflicts (tmux Ctrl+B, screen Ctrl+A, SIGTSTP Ctrl+Z), vim mode interaction, validation and /doctor
- [Terminal configuration](references/claude-code-terminal-config.md) -- themes and appearance, line breaks (Shift+Enter setup, /terminal-setup for VS Code/Alacritty/Zed/Warp), Option as Meta configuration (iTerm2, Terminal.app, VS Code), notification setup (Kitty, Ghostty, iTerm2, notification hooks), handling large inputs, Vim mode subset overview
- [Tools reference](references/claude-code-tools-reference.md) -- complete tools table (Agent, AskUserQuestion, Bash, CronCreate/Delete/List, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, Read, ReadMcpResourceTool, Skill, TaskCreate/Get/List/Output/Stop/Update, TodoWrite, ToolSearch, WebFetch, WebSearch, Write) with permission requirements, Bash tool behavior (separate processes, cwd persistence, env var non-persistence, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR, CLAUDE_ENV_FILE, SessionStart hook)

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Built-in commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Terminal configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
