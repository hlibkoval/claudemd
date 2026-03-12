---
name: cli-doc
description: Complete documentation for Claude Code CLI -- CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude mcp, claude remote-control), CLI flags (--model, --print, --continue, --resume, --system-prompt, --append-system-prompt, --allowedTools, --disallowedTools, --tools, --agents, --mcp-config, --json-schema, --output-format, --input-format, --max-turns, --max-budget-usd, --permission-mode, --dangerously-skip-permissions, --plugin-dir, --worktree, --add-dir, --debug, --verbose, --chrome, --remote, --teleport, --fallback-model, --settings, --setting-sources, --betas, --agent, --fork-session, --from-pr, --ide, --init, --maintenance, --session-id, --no-session-persistence, --teammate-mode), system prompt flags (--system-prompt, --system-prompt-file, --append-system-prompt, --append-system-prompt-file), --agents JSON format (description, prompt, tools, disallowedTools, model, skills, mcpServers, maxTurns), interactive mode keyboard shortcuts (Ctrl+C, Ctrl+D, Ctrl+L, Ctrl+O, Ctrl+R, Ctrl+B, Ctrl+T, Ctrl+G, Ctrl+V, Shift+Tab, Alt+P, Alt+T), text editing shortcuts (Ctrl+K, Ctrl+U, Ctrl+Y, Alt+Y, Alt+B, Alt+F), multiline input methods (backslash-Enter, Option+Enter, Shift+Enter, Ctrl+J, paste), built-in slash commands (/clear, /compact, /config, /context, /copy, /cost, /diff, /doctor, /export, /fork, /help, /hooks, /init, /keybindings, /login, /logout, /mcp, /memory, /model, /permissions, /plan, /plugin, /pr-comments, /release-notes, /remote-control, /rename, /resume, /rewind, /sandbox, /security-review, /skills, /stats, /status, /terminal-setup, /theme, /vim, /btw, /fast, /tasks, /feedback, /ide, /desktop, /insights, /statusline, /stickers, /upgrade, /usage, /extra-usage, /add-dir, /agents, /chrome, /exit, /fork, /install-github-app, /install-slack-app, /mobile, /passes, /privacy-settings, /reload-plugins, /remote-env, /review), quick commands (/ for commands, ! for bash, @ for file mention), vim editor mode (mode switching, navigation, editing, text objects), command history and reverse search (Ctrl+R), background bash commands (Ctrl+B, TaskOutput, async execution), bash mode (! prefix), prompt suggestions, side questions (/btw), task list (Ctrl+T), PR review status, customizable keybindings (~/.claude/keybindings.json), keybinding contexts (Global, Chat, Autocomplete, Settings, Confirmation, Tabs, Help, Transcript, HistorySearch, Task, ThemePicker, Attachments, Footer, MessageSelector, DiffDialog, ModelPicker, Select, Plugin), keybinding actions (app, history, chat, autocomplete, confirm, permission, transcript, historySearch, task, theme, help, tabs, attachments, footer, messageSelector, diff, modelPicker, select, plugin, settings), keystroke syntax (modifiers, uppercase, chords, special keys), reserved shortcuts, terminal conflicts, vim mode interaction, terminal configuration (themes, line breaks, Shift+Enter setup, Option+Enter setup, notification setup, handling large inputs, vim mode). Load when discussing Claude Code CLI usage, command-line flags, interactive mode, keyboard shortcuts, slash commands, vim mode, keybindings, terminal setup, multiline input, bash mode, background tasks, prompt suggestions, side questions, task list, PR status, or any CLI/terminal interaction with Claude Code.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, keyboard shortcuts, customizable keybindings, and terminal configuration.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Non-interactive (print) mode, then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -c -p "query"` | Continue via SDK |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (supports `--email`, `--sso`) |
| `claude auth logout` | Log out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List configured subagents by source |
| `claude mcp` | Configure MCP servers |
| `claude remote-control` | Start a Remote Control session |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `--print`, `-p` | Non-interactive mode |
| `--continue`, `-c` | Resume most recent conversation |
| `--resume`, `-r` | Resume by session ID or name |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--input-format` | Input format: `text`, `stream-json` |
| `--json-schema` | Validated JSON output matching a schema (print mode) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Maximum API spend (print mode) |
| `--fallback-model` | Fallback model when default is overloaded (print mode) |
| `--system-prompt` | Replace entire system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt` | Append to default system prompt |
| `--append-system-prompt-file` | Append file contents to default prompt |
| `--allowedTools` | Tools that skip permission prompts |
| `--disallowedTools` | Tools removed from model context |
| `--tools` | Restrict available built-in tools |
| `--agents` | Define custom subagents via JSON |
| `--agent` | Specify agent for the session |
| `--mcp-config` | Load MCP servers from JSON file/string |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config` |
| `--permission-mode` | Start in a permission mode (`plan`, etc.) |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--allow-dangerously-skip-permissions` | Enable bypass option without activating |
| `--permission-prompt-tool` | MCP tool for non-interactive permission handling |
| `--plugin-dir` | Load plugins from directory (repeatable) |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--add-dir` | Add additional working directories |
| `--chrome` / `--no-chrome` | Enable/disable Chrome integration |
| `--remote` | Create web session on claude.ai |
| `--teleport` | Resume web session in local terminal |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, `tmux` |
| `--settings` | Load additional settings from file or JSON string |
| `--setting-sources` | Comma-separated setting sources: `user`, `project`, `local` |
| `--debug` | Debug mode with optional category filtering |
| `--verbose` | Full turn-by-turn output |
| `--session-id` | Use specific session UUID |
| `--no-session-persistence` | Disable session saving (print mode) |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a GitHub PR |
| `--ide` | Auto-connect to IDE on startup |
| `--init` / `--init-only` | Run initialization hooks (with/without interactive mode) |
| `--maintenance` | Run maintenance hooks and exit |
| `--betas` | Beta headers for API requests |
| `--disable-slash-commands` | Disable all skills and commands |
| `--include-partial-messages` | Include partial streaming events |
| `--version`, `-v` | Show version number |

### --agents JSON Format

| Field | Required | Description |
|:------|:---------|:------------|
| `description` | Yes | When to invoke the subagent |
| `prompt` | Yes | System prompt for the subagent |
| `tools` | No | Array of allowed tools |
| `disallowedTools` | No | Array of denied tools |
| `model` | No | `sonnet`, `opus`, `haiku`, or `inherit` |
| `skills` | No | Array of skill names to preload |
| `mcpServers` | No | Array of MCP servers |
| `maxTurns` | No | Maximum agentic turns |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either.

### Interactive Keyboard Shortcuts

#### General Controls

| Shortcut | Action |
|:---------|:-------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+F` | Kill all background agents (press twice to confirm) |
| `Ctrl+D` | Exit session |
| `Ctrl+G` | Open in default text editor |
| `Ctrl+L` | Clear terminal screen (keeps history) |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` / `Cmd+V` / `Alt+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Esc Esc` | Rewind or summarize |
| `Shift+Tab` / `Alt+M` | Toggle permission modes |
| `Alt+P` / `Option+P` | Switch model |
| `Alt+T` / `Option+T` | Toggle extended thinking |

#### Text Editing

| Shortcut | Action |
|:---------|:-------|
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete entire line |
| `Ctrl+Y` | Paste deleted text |
| `Alt+Y` | Cycle paste history (after `Ctrl+Y`) |
| `Alt+B` | Move cursor back one word |
| `Alt+F` | Move cursor forward one word |

#### Multiline Input

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + `Enter` |
| macOS default | `Option+Enter` |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty |
| Control sequence | `Ctrl+J` |
| Paste mode | Paste directly |

Run `/terminal-setup` to configure Shift+Enter for VS Code, Alacritty, Zed, and Warp.

#### Quick Commands

| Prefix | Action |
|:-------|:-------|
| `/` | Slash command or skill |
| `!` | Bash mode (run command directly) |
| `@` | File path autocomplete |

### Built-in Slash Commands (selected)

| Command | Purpose |
|:--------|:--------|
| `/clear` | Clear conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Compact conversation with optional focus |
| `/config` | Open settings (alias: `/settings`) |
| `/context` | Visualize context usage |
| `/copy` | Copy last response to clipboard |
| `/cost` | Show token usage stats |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings |
| `/export [filename]` | Export conversation as text |
| `/fork [name]` | Fork conversation at this point |
| `/model [model]` | Select or change model |
| `/permissions` | View/update permissions (alias: `/allowed-tools`) |
| `/plan` | Enter plan mode |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/rename [name]` | Rename session |
| `/resume [session]` | Resume conversation (alias: `/continue`) |
| `/rewind` | Rewind conversation/code (alias: `/checkpoint`) |
| `/vim` | Toggle vim editing mode |
| `/btw <question>` | Side question without adding to conversation |
| `/fast [on\|off]` | Toggle fast mode |
| `/tasks` | List and manage background tasks |
| `/memory` | Edit CLAUDE.md memory files |
| `/hooks` | Manage hook configurations |
| `/mcp` | Manage MCP server connections |
| `/plugin` | Manage plugins |
| `/skills` | List available skills |
| `/theme` | Change color theme |
| `/keybindings` | Open keybindings config file |
| `/terminal-setup` | Configure terminal keybindings |
| `/desktop` | Continue session in Desktop app (alias: `/app`) |
| `/remote-control` | Make session available for remote control (alias: `/rc`) |
| `/security-review` | Analyze pending changes for vulnerabilities |
| `/insights` | Generate session analysis report |
| `/statusline` | Configure status line |
| `/stats` | Visualize usage, streaks, and preferences |

### Vim Editor Mode

Enable with `/vim` or `/config`. Supports mode switching (`Esc`, `i`/`I`, `a`/`A`, `o`/`O`), navigation (`h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f`/`F`/`t`/`T` with `;`/`,` repeat), editing (`x`, `dd`/`D`, `dw`/`de`/`db`, `cc`/`C`, `cw`/`ce`/`cb`, `.` repeat), yank/paste (`yy`/`Y`, `yw`/`ye`/`yb`, `p`/`P`), text objects (`iw`/`aw`, `iW`/`aW`, `i"`/`a"`, `i'`/`a'`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`), indentation (`>>`/`<<`), and join (`J`).

### Background Bash Commands

Press `Ctrl+B` to move a running command to the background (tmux users press twice). Claude can also run commands in the background proactively. Output is buffered and retrievable via `TaskOutput`. Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable.

Bash mode (`!` prefix) runs commands directly without Claude interpretation, adding output to conversation context. Supports `Tab` autocomplete from previous commands.

### Prompt Suggestions

Grayed-out suggestions appear based on git history and conversation context. Press `Tab` to accept, `Enter` to accept and submit. Disable with `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false`.

### Side Questions (`/btw`)

Ask a quick question without adding to conversation history. Has full visibility into current context but no tool access. Works while Claude is processing. Low cost (reuses prompt cache).

### Task List

Claude creates a task list for multi-step work (visible in terminal status area). Toggle with `Ctrl+T`. Share across sessions with `CLAUDE_CODE_TASK_LIST_ID`. Revert to previous TODO list with `CLAUDE_CODE_ENABLE_TASKS=false`.

### PR Review Status

Clickable PR link in footer with colored underline: green (approved), yellow (pending), red (changes requested), gray (draft), purple (merged). Updates every 60 seconds. Requires `gh` CLI.

### Customizable Keybindings

Configure in `~/.claude/keybindings.json` (open with `/keybindings`). Changes apply without restart.

#### Binding Contexts

`Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`

#### Key Action Namespaces

| Namespace | Example actions |
|:----------|:---------------|
| `app` | `interrupt`, `exit`, `toggleTodos`, `toggleTranscript` |
| `chat` | `submit`, `cancel`, `cycleMode`, `modelPicker`, `thinkingToggle`, `externalEditor`, `imagePaste`, `stash` |
| `history` | `search`, `previous`, `next` |
| `autocomplete` | `accept`, `dismiss`, `previous`, `next` |
| `confirm` | `yes`, `no`, `cycleMode`, `toggleExplanation` |
| `permission` | `toggleDebug` |
| `transcript` | `toggleShowAll`, `exit` |
| `historySearch` | `next`, `accept`, `cancel`, `execute` |
| `task` | `background` |
| `theme` | `toggleSyntaxHighlighting` |
| `diff` | `dismiss`, `previousSource`, `nextSource`, `previousFile`, `nextFile`, `viewDetails` |
| `select` | `next`, `previous`, `accept`, `cancel` |
| `settings` | `search`, `retry` |

#### Keystroke Syntax

Modifiers: `ctrl`, `alt`/`opt`/`option`, `shift`, `meta`/`cmd`/`command`, combined with `+`. Uppercase letter implies Shift (e.g., `K` = `shift+k`). Chords separated by spaces (e.g., `ctrl+k ctrl+s`). Special keys: `escape`/`esc`, `enter`/`return`, `tab`, `space`, `up`/`down`/`left`/`right`, `backspace`, `delete`.

Set an action to `null` to unbind a default shortcut. Reserved (cannot rebind): `Ctrl+C`, `Ctrl+D`.

### Terminal Configuration

- **Themes**: Use `/config` to match Claude Code's theme to your terminal. Configure a custom status line with `/statusline`.
- **Shift+Enter**: Native in iTerm2, WezTerm, Ghostty, Kitty. Run `/terminal-setup` for VS Code, Alacritty, Zed, Warp.
- **Option as Meta** (macOS): Required for Alt-key shortcuts. iTerm2: Profiles > Keys > set Option to "Esc+". Terminal.app: Profiles > Keyboard > "Use Option as Meta Key".
- **Notifications**: Native in Kitty and Ghostty. iTerm2: Profiles > Terminal > enable "Notification Center Alerts" + "Send escape sequence-generated alerts". Other terminals: use notification hooks.
- **Large inputs**: Prefer file-based workflows over direct pasting. VS Code terminal is prone to truncation.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) -- CLI commands, all CLI flags with examples, --agents JSON format, system prompt flags and usage guidance
- [Interactive mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts, built-in slash commands, vim editor mode, command history, reverse search, background bash commands, bash mode, prompt suggestions, side questions (/btw), task list, PR review status
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) -- keybindings.json configuration, binding contexts, all available actions by namespace, keystroke syntax (modifiers, chords, special keys), unbinding defaults, reserved shortcuts, terminal conflicts, vim mode interaction, validation
- [Optimize your terminal setup](references/claude-code-terminal-config.md) -- terminal themes, line break configuration, Shift+Enter and Option+Enter setup, notification setup (iTerm2, Kitty, Ghostty, hooks), handling large inputs, vim mode

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Optimize your terminal setup: https://code.claude.com/docs/en/terminal-config.md
