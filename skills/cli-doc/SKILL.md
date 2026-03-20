---
name: cli-doc
description: Complete documentation for the Claude Code CLI and interactive mode -- CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude mcp, claude remote-control), CLI flags (--add-dir, --agent, --agents, --allowedTools, --disallowedTools, --append-system-prompt, --system-prompt, --system-prompt-file, --append-system-prompt-file, --betas, --channels, --chrome, --continue, --dangerously-skip-permissions, --debug, --disable-slash-commands, --effort, --fallback-model, --fork-session, --from-pr, --ide, --init, --input-format, --json-schema, --maintenance, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --no-chrome, --no-session-persistence, --output-format, --permission-mode, --permission-prompt-tool, --plugin-dir, --print, --remote, --remote-control, --resume, --session-id, --setting-sources, --settings, --strict-mcp-config, --teleport, --teammate-mode, --tools, --verbose, --version, --worktree), system prompt flags, built-in slash commands (/clear /compact /config /context /copy /cost /diff /doctor /effort /exit /export /fast /feedback /fork /help /hooks /ide /init /insights /install-github-app /keybindings /login /logout /mcp /memory /model /permissions /plan /plugin /pr-comments /privacy-settings /release-notes /reload-plugins /remote-control /rename /resume /rewind /sandbox /security-review /skills /stats /status /statusline /stickers /tasks /terminal-setup /theme /upgrade /usage /vim /voice /add-dir /agents /btw /chrome /color /desktop /extra-usage /mobile /passes), interactive mode (keyboard shortcuts, general controls Ctrl+C/D/G/L/O/R/V/B/T Esc+Esc Shift+Tab, text editing Ctrl+K/U/Y Alt+Y/B/F, multiline input Shift+Enter/Option+Enter/Ctrl+J/backslash+Enter, quick commands / and @ prefixes, voice input hold Space, vim mode switching/navigation/editing/text objects, command history and Ctrl+R reverse search, background bash commands Ctrl+B and bash mode with prefix, prompt suggestions, side questions /btw, task list Ctrl+T, PR review status), keybindings (keybindings.json configuration file, contexts Global/Chat/Autocomplete/Settings/Confirmation/Tabs/Help/Transcript/HistorySearch/Task/ThemePicker/Attachments/Footer/MessageSelector/DiffDialog/ModelPicker/Select/Plugin, available actions app/history/chat/autocomplete/confirm/permission/transcript/historySearch/task/theme/help/tabs/attachments/footer/messageSelector/diff/modelPicker/select/plugin/settings/voice, keystroke syntax modifiers/uppercase/chords/special keys, unbinding defaults, reserved shortcuts Ctrl+C/D, terminal conflicts Ctrl+B/A/Z, vim mode interaction, validation), terminal configuration (themes, line breaks Shift+Enter setup for VS Code/Alacritty/Zed/Warp, Option+Enter for iTerm2/Terminal.app, notification setup terminal and hooks, handling large inputs, vim mode subset), tools reference (Agent, AskUserQuestion, Bash, CronCreate/Delete/List, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, Read, ReadMcpResourceTool, Skill, TaskCreate/Get/List/Output/Stop/Update, TodoWrite, ToolSearch, WebFetch, WebSearch, Write, permission requirements, Bash tool behavior working directory persistence and env var non-persistence and CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR and CLAUDE_ENV_FILE). Load when discussing CLI flags, CLI commands, slash commands, built-in commands, interactive mode, keyboard shortcuts, keybindings, key bindings, terminal setup, vim mode, command history, background tasks, prompt suggestions, /btw side questions, task list, PR review status, tools reference, tool permissions, Bash tool behavior, multiline input, system prompt flags, voice input, notification setup, terminal configuration, line breaks, available tools, permission rules for tools, or any CLI usage question.
user-invocable: false
---

# CLI & Interactive Mode Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, built-in commands, interactive mode features, keybindings, terminal configuration, and available tools.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive), then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -c -p "query"` | Continue via print mode |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (`--email`, `--sso`, `--console` flags) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON (`--text` for readable output) |
| `claude agents` | List configured subagents |
| `claude mcp` | Configure MCP servers |
| `claude remote-control` | Start a Remote Control server |

### Key CLI Flags

| Flag | Purpose |
|:-----|:--------|
| `--add-dir` | Add additional working directories |
| `--agent` | Specify an agent for the session |
| `--agents` | Define custom subagents dynamically via JSON |
| `--allowedTools` | Tools that execute without prompting |
| `--disallowedTools` | Tools removed from model context |
| `--model` | Set model (alias `sonnet`/`opus` or full name) |
| `--effort` | Set effort level (`low`, `medium`, `high`, `max`) |
| `--print` / `-p` | Non-interactive print mode |
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Spending cap (print mode) |
| `--json-schema` | Validated JSON output matching a schema (print mode) |
| `--mcp-config` | Load MCP servers from JSON files |
| `--permission-mode` | Begin in a permission mode (`plan`, etc.) |
| `--worktree` / `-w` | Start in an isolated git worktree |
| `--continue` / `-c` | Load most recent conversation |
| `--resume` / `-r` | Resume session by ID or name |
| `--from-pr` | Resume sessions linked to a GitHub PR |
| `--name` / `-n` | Set session display name |
| `--remote` | Create a web session on claude.ai |
| `--remote-control` / `--rc` | Interactive session with Remote Control enabled |
| `--teleport` | Resume a web session locally |
| `--chrome` / `--no-chrome` | Enable/disable Chrome integration |
| `--plugin-dir` | Load plugins from a directory |
| `--tools` | Restrict available built-in tools |
| `--debug` | Enable debug mode with optional category filter |
| `--verbose` | Full turn-by-turn output |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replace entire default prompt |
| `--system-prompt-file` | Replace with file contents |
| `--append-system-prompt` | Append to the default prompt |
| `--append-system-prompt-file` | Append file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag. Use append flags for most cases to preserve built-in capabilities.

### Built-in Slash Commands

| Command | Purpose |
|:--------|:--------|
| `/add-dir <path>` | Add a working directory to the session |
| `/agents` | Manage agent configurations |
| `/btw <question>` | Side question without adding to conversation |
| `/chrome` | Configure Chrome integration |
| `/clear` | Clear conversation history (aliases: `/reset`, `/new`) |
| `/color [color]` | Set prompt bar color |
| `/compact [instructions]` | Compact conversation with optional focus |
| `/config` | Open Settings (alias: `/settings`) |
| `/context` | Visualize context usage |
| `/copy [N]` | Copy assistant response to clipboard |
| `/cost` | Show token usage statistics |
| `/desktop` | Continue session in Desktop app (alias: `/app`) |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings |
| `/effort [level]` | Set effort level (`low`/`medium`/`high`/`max`/`auto`) |
| `/exit` | Exit the CLI (alias: `/quit`) |
| `/export [filename]` | Export conversation as plain text |
| `/extra-usage` | Configure extra usage for rate limits |
| `/fast [on\|off]` | Toggle fast mode |
| `/feedback [report]` | Submit feedback (alias: `/bug`) |
| `/branch [name]` | Branch the conversation (alias: `/fork`) |
| `/help` | Show help and commands |
| `/hooks` | View hook configurations |
| `/ide` | Manage IDE integrations |
| `/init` | Initialize project CLAUDE.md |
| `/insights` | Generate session analysis report |
| `/install-github-app` | Set up GitHub Actions integration |
| `/install-slack-app` | Install Claude Slack app |
| `/keybindings` | Open keybindings configuration file |
| `/login` / `/logout` | Sign in/out |
| `/mcp` | Manage MCP server connections |
| `/memory` | Edit CLAUDE.md files, toggle auto memory |
| `/model [model]` | Select or change AI model |
| `/permissions` | View/update permissions (alias: `/allowed-tools`) |
| `/plan` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/release-notes` | View changelog |
| `/reload-plugins` | Reload active plugins |
| `/remote-control` | Enable Remote Control (alias: `/rc`) |
| `/rename [name]` | Rename current session |
| `/resume [session]` | Resume a conversation (alias: `/continue`) |
| `/rewind` | Rewind conversation/code (alias: `/checkpoint`) |
| `/sandbox` | Toggle sandbox mode |
| `/security-review` | Analyze changes for security vulnerabilities |
| `/skills` | List available skills |
| `/stats` | Visualize daily usage and session history |
| `/status` | Show version, model, account, connectivity |
| `/statusline` | Configure status line |
| `/tasks` | List and manage background tasks |
| `/terminal-setup` | Configure terminal keybindings |
| `/theme` | Change color theme |
| `/upgrade` | Open upgrade page |
| `/usage` | Show plan usage and rate limit status |
| `/vim` | Toggle Vim/Normal editing modes |
| `/voice` | Toggle push-to-talk voice dictation |

MCP servers can also expose prompts as `/mcp__<server>__<prompt>` commands.

### Keyboard Shortcuts

#### General Controls

| Shortcut | Action |
|:---------|:-------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` | Open in default text editor |
| `Ctrl+L` | Clear terminal screen (keeps history) |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` / `Cmd+V` / `Alt+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+F` | Kill all background agents (press twice to confirm) |
| `Esc+Esc` | Rewind or summarize |
| `Shift+Tab` / `Alt+M` | Toggle permission modes |
| `Alt+P` / `Option+P` | Switch model |
| `Alt+T` / `Option+T` | Toggle extended thinking |

#### Multiline Input

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + `Enter` (all terminals) |
| macOS default | `Option+Enter` |
| Shift+Enter | Works natively in iTerm2, WezTerm, Ghostty, Kitty |
| Control sequence | `Ctrl+J` |

Run `/terminal-setup` to configure Shift+Enter for VS Code, Alacritty, Zed, and Warp.

#### Quick Prefixes

| Prefix | Purpose |
|:-------|:--------|
| `/` | Slash commands and skills |
| `!` | Bash mode (run shell commands directly) |
| `@` | File path autocomplete |

### Vim Mode

Toggle with `/vim` or `/config`. Supports mode switching (`Esc`, `i`/`I`, `a`/`A`, `o`/`O`), navigation (`h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f`/`F`/`t`/`T` with `;`/`,`), editing (`x`, `dd`/`D`, `dw`/`de`/`db`, `cc`/`C`, `cw`/`ce`/`cb`, `.`), yank/paste (`yy`/`Y`, `yw`/`ye`/`yb`, `p`/`P`), text objects (`iw`/`aw`, `iW`/`aW`, `i"`/`a"`, `i'`/`a'`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`), indentation (`>>`/`<<`), join (`J`).

### Custom Keybindings

Edit `~/.claude/keybindings.json` (or run `/keybindings`). Changes auto-apply without restart.

| Field | Description |
|:------|:------------|
| `bindings` | Array of binding blocks by context |
| Each block | `context` (where bindings apply) + `bindings` map (keystroke -> action or `null` to unbind) |

**Contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`

**Key actions:** `app:interrupt` (Ctrl+C), `app:exit` (Ctrl+D), `app:toggleTodos` (Ctrl+T), `app:toggleTranscript` (Ctrl+O), `chat:submit` (Enter), `chat:cycleMode` (Shift+Tab), `chat:modelPicker` (Cmd+P), `chat:thinkingToggle` (Cmd+T), `chat:externalEditor` (Ctrl+G), `chat:imagePaste` (Ctrl+V), `task:background` (Ctrl+B), `voice:pushToTalk` (Space)

**Keystroke syntax:** modifiers with `+` (`ctrl+k`, `shift+tab`, `meta+p`), chords with space (`ctrl+k ctrl+s`), uppercase implies Shift (`K` = `shift+k`). Reserved: Ctrl+C and Ctrl+D cannot be rebound. Terminal conflicts: Ctrl+B (tmux), Ctrl+A (screen), Ctrl+Z (suspend).

### Interactive Features

| Feature | Description |
|:--------|:------------|
| **Background commands** | Prompt Claude to background, or press `Ctrl+B` during Bash execution. Output buffered, retrievable via TaskOutput. Auto-cleaned on exit. 5GB output limit. Disable with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` |
| **Bash mode (`!` prefix)** | Run shell commands directly; output added to conversation. Supports `Tab` autocomplete from `!` history |
| **Prompt suggestions** | Ghost text suggestions based on git history and conversation. `Tab` to accept, `Enter` to accept and submit. Disable with `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false` |
| **Side questions (`/btw`)** | Quick question with full conversation visibility but no tool access, no history impact, single response. Available while Claude is working |
| **Task list** | `Ctrl+T` to toggle. Up to 10 tasks visible. Persists across compactions. Shared via `CLAUDE_CODE_TASK_LIST_ID` |
| **PR review status** | Clickable PR link in footer (green=approved, yellow=pending, red=changes requested, gray=draft, purple=merged). Requires `gh` CLI |

### Terminal Configuration

| Topic | Details |
|:------|:--------|
| **Themes** | Match Claude Code theme to terminal via `/config`. Custom status line via `/statusline` |
| **Shift+Enter** | Native in iTerm2, WezTerm, Ghostty, Kitty. Run `/terminal-setup` for VS Code, Alacritty, Zed, Warp |
| **Option as Meta** | iTerm2: Profiles > Keys > "Esc+". Terminal.app: Profiles > Keyboard > "Use Option as Meta Key". VS Code: `terminal.integrated.macOptionIsMeta: true` |
| **Notifications** | Kitty/Ghostty: built-in. iTerm2: enable "Notification Center Alerts" + "Send escape sequence-generated alerts". Others: use Notification hooks |
| **Large inputs** | Avoid direct pasting; use file-based workflows. VS Code terminal truncates long pastes |

### Tools Reference

| Tool | Description | Permission |
|:-----|:------------|:-----------|
| `Agent` | Spawn subagent with own context | No |
| `AskUserQuestion` | Ask multiple-choice questions | No |
| `Bash` | Execute shell commands | Yes |
| `CronCreate` / `CronDelete` / `CronList` | Manage scheduled tasks | No |
| `Edit` | Targeted file edits | Yes |
| `EnterPlanMode` / `ExitPlanMode` | Switch to/from plan mode | No / Yes |
| `EnterWorktree` / `ExitWorktree` | Git worktree isolation | No |
| `Glob` | Find files by pattern | No |
| `Grep` | Search file contents | No |
| `ListMcpResourcesTool` / `ReadMcpResourceTool` | List/read MCP resources | No |
| `LSP` | Code intelligence (type errors, go-to-definition, references) | No |
| `NotebookEdit` | Modify Jupyter notebook cells | Yes |
| `Read` | Read file contents | No |
| `Skill` | Execute a skill | Yes |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskOutput` / `TaskStop` | Manage tasks and background processes | No |
| `TodoWrite` | Manage task checklist (non-interactive/Agent SDK) | No |
| `ToolSearch` | Search and load deferred tools | No |
| `WebFetch` | Fetch content from a URL | Yes |
| `WebSearch` | Perform web searches | Yes |
| `Write` | Create or overwrite files | Yes |

**Bash tool behavior:** Each command runs in a separate process. Working directory persists across commands (set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to reset). Environment variables do not persist across commands. Use `CLAUDE_ENV_FILE` or a `SessionStart` hook to make env vars persistent.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) -- CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth login/logout/status, claude agents, claude mcp, claude remote-control), CLI flags (--add-dir, --agent, --agents, --allow-dangerously-skip-permissions, --allowedTools, --append-system-prompt, --append-system-prompt-file, --betas, --channels, --chrome, --continue, --dangerously-load-development-channels, --dangerously-skip-permissions, --debug, --disable-slash-commands, --disallowedTools, --effort, --fallback-model, --fork-session, --from-pr, --ide, --init, --init-only, --include-partial-messages, --input-format, --json-schema, --maintenance, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --no-chrome, --no-session-persistence, --output-format, --permission-mode, --permission-prompt-tool, --plugin-dir, --print, --remote, --remote-control, --resume, --session-id, --setting-sources, --settings, --strict-mcp-config, --system-prompt, --system-prompt-file, --teleport, --teammate-mode, --tools, --verbose, --version, --worktree), system prompt flags (replace vs append, mutual exclusivity, combining append with replacement)
- [Built-in commands](references/claude-code-commands.md) -- slash commands (/add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /branch, /help, /hooks, /ide, /init, /insights, /install-github-app, /install-slack-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /model, /passes, /permissions, /plan, /plugin, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /review, /rewind, /sandbox, /security-review, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim, /voice), MCP prompts as commands
- [Interactive mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts (general controls, text editing, theme/display, multiline input, quick commands, voice input), Vim editor mode (mode switching, navigation, editing, text objects), command history and Ctrl+R reverse search, background bash commands (backgrounding behavior, Ctrl+B, common commands, bash mode with prefix), prompt suggestions (tab accept, enter accept and submit, disable with env var), side questions /btw (ephemeral, no tool access, available while working, low cost), task list (Ctrl+T toggle, persistence, CLAUDE_CODE_TASK_LIST_ID), PR review status (color-coded link in footer, gh CLI required)
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) -- keybindings.json configuration (bindings array, context + bindings map), contexts (Global, Chat, Autocomplete, Settings, Confirmation, Tabs, Help, Transcript, HistorySearch, Task, ThemePicker, Attachments, Footer, MessageSelector, DiffDialog, ModelPicker, Select, Plugin), available actions by namespace (app, history, chat, autocomplete, confirm, permission, transcript, historySearch, task, theme, help, tabs, attachments, footer, messageSelector, diff, modelPicker, select, plugin, settings, voice), keystroke syntax (modifiers, uppercase, chords, special keys), unbinding defaults, reserved shortcuts (Ctrl+C, Ctrl+D), terminal conflicts (Ctrl+B tmux, Ctrl+A screen, Ctrl+Z suspend), vim mode interaction, validation with /doctor
- [Optimize your terminal setup](references/claude-code-terminal-config.md) -- themes and appearance (/config, /statusline), line breaks (Shift+Enter for iTerm2/WezTerm/Ghostty/Kitty, /terminal-setup for VS Code/Alacritty/Zed/Warp, Option+Enter for macOS Terminal.app/iTerm2/VS Code), notification setup (terminal notifications for Kitty/Ghostty/iTerm2, notification hooks), handling large inputs (avoid pasting, file-based workflows, VS Code truncation), Vim mode subset
- [Tools reference](references/claude-code-tools-reference.md) -- all available tools (Agent, AskUserQuestion, Bash, CronCreate/Delete/List, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, Read, ReadMcpResourceTool, Skill, TaskCreate/Get/List/Output/Stop/Update, TodoWrite, ToolSearch, WebFetch, WebSearch, Write), permission requirements per tool, Bash tool behavior (working directory persistence, environment variable non-persistence, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR, CLAUDE_ENV_FILE, SessionStart hook)

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Built-in commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Optimize your terminal setup: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
