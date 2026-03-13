---
name: cli-doc
description: Complete documentation for Claude Code's command-line interface, interactive mode, keyboard shortcuts, and terminal configuration -- CLI commands (`claude`, `claude -p`, `claude -c`, `claude -r`, `claude update`, `claude auth`, `claude agents`, `claude mcp`, `claude remote-control`), CLI flags (`--model`, `--allowedTools`, `--disallowedTools`, `--tools`, `--permission-mode`, `--output-format`, `--json-schema`, `--system-prompt`, `--append-system-prompt`, `--agents`, `--mcp-config`, `--worktree`, `--add-dir`, `--dangerously-skip-permissions`, `--max-turns`, `--max-budget-usd`, `--fallback-model`, `--debug`, `--verbose`, `--chrome`, `--remote`, `--teleport`, `--from-pr`, `--plugin-dir`), system prompt flags, `--agents` JSON format, interactive keyboard shortcuts (Ctrl+C/D/L/O/R/B/T/G, Esc+Esc rewind, Shift+Tab mode toggle, Alt+P model switch, Alt+T thinking toggle), text editing shortcuts, multiline input methods, built-in slash commands (`/clear`, `/compact`, `/config`, `/context`, `/cost`, `/diff`, `/export`, `/fast`, `/fork`, `/init`, `/memory`, `/model`, `/permissions`, `/plan`, `/pr-comments`, `/resume`, `/rewind`, `/skills`, `/vim`, `/btw`), vim editor mode (mode switching, navigation, editing, text objects), command history and reverse search (Ctrl+R), background bash commands (Ctrl+B), bash mode (`!` prefix), prompt suggestions, side questions (`/btw`), task list (Ctrl+T), PR review status, customizable keybindings (`~/.claude/keybindings.json`, contexts, actions, keystroke syntax, chords, unbinding, reserved shortcuts, terminal conflicts, vim mode interaction), terminal configuration (themes, line breaks, Shift+Enter setup, Option+Enter, notifications, handling large inputs, vim mode). Load when discussing CLI commands, CLI flags, interactive mode, keyboard shortcuts, slash commands, built-in commands, keybindings, terminal setup, vim mode, multiline input, background tasks, bash mode, command history, or terminal configuration for Claude Code.
user-invocable: false
---

# CLI & Interactive Mode Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode features, customizable keybindings, and terminal configuration.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Non-interactive (print) mode, then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -c -p "query"` | Continue via print mode |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (supports `--email` and `--sso`) |
| `claude auth logout` | Sign out |
| `claude auth status` | Authentication status (JSON; use `--text` for human-readable) |
| `claude agents` | List all configured subagents |
| `claude mcp` | Configure MCP servers |
| `claude remote-control` | Start a Remote Control session |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `--model` | Set model (alias `sonnet`, `opus`, or full ID) |
| `--print`, `-p` | Non-interactive mode |
| `--continue`, `-c` | Continue most recent conversation |
| `--resume`, `-r` | Resume specific session by ID or name |
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--json-schema` | Validated JSON output matching a schema (print mode) |
| `--allowedTools` | Tools that execute without permission prompts |
| `--disallowedTools` | Tools removed from model context entirely |
| `--tools` | Restrict which built-in tools are available |
| `--permission-mode` | Start in a specific permission mode (e.g., `plan`) |
| `--system-prompt` | Replace the entire system prompt |
| `--system-prompt-file` | Replace system prompt from a file |
| `--append-system-prompt` | Append to the default system prompt |
| `--append-system-prompt-file` | Append file contents to the default prompt |
| `--agents` | Define custom subagents via JSON |
| `--agent` | Specify an agent for the session |
| `--mcp-config` | Load MCP servers from JSON files |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config` |
| `--add-dir` | Add additional working directories |
| `--worktree`, `-w` | Start in an isolated git worktree |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Spending cap (print mode) |
| `--fallback-model` | Auto-fallback when default model overloaded (print mode) |
| `--remote` | Create a new web session on claude.ai |
| `--teleport` | Resume a web session in local terminal |
| `--from-pr` | Resume sessions linked to a GitHub PR |
| `--chrome` / `--no-chrome` | Enable/disable Chrome browser integration |
| `--plugin-dir` | Load plugins from directories |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--debug` | Debug mode with optional category filter |
| `--verbose` | Verbose logging |
| `--version`, `-v` | Show version |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | **Replaces** the entire default prompt |
| `--system-prompt-file` | **Replaces** with file contents |
| `--append-system-prompt` | **Appends** to the default prompt |
| `--append-system-prompt-file` | **Appends** file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. The append flags can combine with either replacement flag. For most use cases, `--append-system-prompt` is recommended since it preserves Claude Code defaults.

### --agents JSON Format

Each subagent requires a unique key name with an object containing:

| Field | Required | Description |
|:------|:---------|:------------|
| `description` | Yes | When the subagent should be invoked |
| `prompt` | Yes | System prompt for the subagent |
| `tools` | No | Array of allowed tools (inherits all if omitted) |
| `disallowedTools` | No | Array of tools to deny |
| `model` | No | Model alias or full ID (default: `inherit`) |
| `skills` | No | Array of skill names to preload |
| `mcpServers` | No | Array of MCP server names or `{name: config}` objects |
| `maxTurns` | No | Maximum agentic turns |

### Interactive Keyboard Shortcuts

#### General Controls

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit Claude Code |
| `Ctrl+L` | Clear terminal screen (keeps history) |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+G` | Open in default text editor |
| `Ctrl+F` | Kill all background agents (press twice to confirm) |
| `Ctrl+V` / `Cmd+V` / `Alt+V` | Paste image from clipboard |
| `Esc` + `Esc` | Rewind or summarize |
| `Shift+Tab` | Toggle permission modes |
| `Alt+P` / `Option+P` | Switch model |
| `Alt+T` / `Option+T` | Toggle extended thinking |

#### Multiline Input

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + `Enter` |
| macOS default | `Option+Enter` |
| Shift+Enter | Works natively in iTerm2, WezTerm, Ghostty, Kitty |
| Control sequence | `Ctrl+J` |
| Paste mode | Paste directly |

Run `/terminal-setup` to configure Shift+Enter for VS Code, Alacritty, Zed, Warp.

#### Quick Prefixes

| Prefix | Description |
|:-------|:------------|
| `/` | Slash command or skill |
| `!` | Bash mode (run command directly) |
| `@` | File path mention with autocomplete |

### Built-in Slash Commands (Selected)

| Command | Purpose |
|:--------|:--------|
| `/clear` | Clear conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Compact conversation with optional focus |
| `/config` | Open settings interface (alias: `/settings`) |
| `/context` | Visualize current context usage |
| `/copy` | Copy last response to clipboard |
| `/cost` | Show token usage statistics |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings |
| `/export [filename]` | Export conversation as plain text |
| `/fast [on\|off]` | Toggle fast mode |
| `/fork [name]` | Fork current conversation |
| `/init` | Initialize project with CLAUDE.md |
| `/memory` | Edit CLAUDE.md memory files |
| `/model [model]` | Select or change AI model |
| `/permissions` | View or update permissions (alias: `/allowed-tools`) |
| `/plan` | Enter plan mode |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/resume [session]` | Resume a conversation (alias: `/continue`) |
| `/rewind` | Rewind conversation/code to a previous point (alias: `/checkpoint`) |
| `/skills` | List available skills |
| `/vim` | Toggle vim editing mode |
| `/btw <question>` | Side question without adding to conversation |
| `/keybindings` | Open keybindings configuration file |
| `/remote-control` | Start remote control session (alias: `/rc`) |
| `/terminal-setup` | Configure terminal keybindings |
| `/theme` | Change color theme |

Type `/` to see all available commands. Some commands depend on platform, plan, or environment.

### Vim Editor Mode

Enable with `/vim` or via `/config`. Supports mode switching (`Esc`, `i`/`I`, `a`/`A`, `o`/`O`), navigation (`h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f`/`F`/`t`/`T` with `;`/`,` repeat), editing (`x`, `dd`/`D`, `dw`/`de`/`db`, `cc`/`C`, `cw`/`ce`/`cb`, `p`/`P`, `>>`/`<<`, `J`, `.` repeat), yank (`yy`/`Y`, `yw`/`ye`/`yb`), and text objects (`iw`/`aw`, `iW`/`aW`, `i"`/`a"`, `i'`/`a'`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`).

### Background Tasks & Bash Mode

- Background long-running commands with `Ctrl+B` or by prompting Claude to run in the background
- Use `!` prefix for direct bash execution without Claude interpretation (output added to conversation context)
- Bash mode supports Tab autocomplete from previous `!` commands in the current project
- Disable background tasks with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`

### Command History

- Per-directory input history; resets on `/clear`
- `Ctrl+R` opens reverse search: type to filter, `Ctrl+R` to cycle, `Tab`/`Esc` to accept, `Enter` to accept and execute, `Ctrl+C` to cancel
- `Up`/`Down` arrows navigate history

### Prompt Suggestions

Grayed-out suggestions appear based on git history and conversation context. Press `Tab` to accept, `Enter` to accept and submit, or start typing to dismiss. Disable with `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false`.

### Side Questions (`/btw`)

Quick ephemeral questions with full conversation visibility but no tool access. Works while Claude is processing. Answer dismissed with Space/Enter/Escape. Does not enter conversation history.

### Task List

Claude creates a task list for complex multi-step work. Toggle visibility with `Ctrl+T`. Share across sessions with `CLAUDE_CODE_TASK_LIST_ID=<name>`.

### PR Review Status

When a branch has an open PR, a clickable link appears in the footer with a colored underline indicating review state (green=approved, yellow=pending, red=changes requested, gray=draft, purple=merged). Requires `gh` CLI.

### Customizable Keybindings

Configure in `~/.claude/keybindings.json` (open with `/keybindings`). Changes auto-detected without restart.

#### Keybinding Contexts

`Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`

#### Key Actions

| Context | Action | Default |
|:--------|:-------|:--------|
| Global | `app:interrupt` | Ctrl+C |
| Global | `app:exit` | Ctrl+D |
| Global | `app:toggleTodos` | Ctrl+T |
| Global | `app:toggleTranscript` | Ctrl+O |
| Chat | `chat:submit` | Enter |
| Chat | `chat:cycleMode` | Shift+Tab |
| Chat | `chat:modelPicker` | Cmd+P / Meta+P |
| Chat | `chat:thinkingToggle` | Cmd+T / Meta+T |
| Chat | `chat:externalEditor` | Ctrl+G |
| Chat | `chat:imagePaste` | Ctrl+V |
| Task | `task:background` | Ctrl+B |

#### Keystroke Syntax

- Modifiers: `ctrl`, `alt`/`opt`, `shift`, `meta`/`cmd` joined with `+`
- Standalone uppercase letter implies Shift (e.g., `K` = `shift+k`)
- Chords: space-separated sequences (e.g., `ctrl+k ctrl+s`)
- Special keys: `escape`, `enter`, `tab`, `space`, `up`, `down`, `left`, `right`, `backspace`, `delete`
- Set action to `null` to unbind a default shortcut

#### Reserved & Conflicting Shortcuts

| Shortcut | Note |
|:---------|:-----|
| `Ctrl+C` | Reserved (interrupt) |
| `Ctrl+D` | Reserved (exit) |
| `Ctrl+B` | Conflicts with tmux prefix |
| `Ctrl+A` | Conflicts with GNU screen prefix |
| `Ctrl+Z` | Unix process suspend |

### Terminal Configuration

- Match Claude Code theme to terminal via `/config`; configure a custom status line via `/statusline`
- Shift+Enter works natively in iTerm2, WezTerm, Ghostty, Kitty; run `/terminal-setup` for VS Code, Alacritty, Zed, Warp
- Option as Meta key required for Alt shortcuts on macOS: iTerm2 (Profiles > Keys > "Esc+"), Terminal.app (Profiles > Keyboard > "Use Option as Meta Key")
- Notifications: Kitty and Ghostty work without setup; iTerm2 needs Profiles > Terminal > "Notification Center Alerts" enabled; other terminals use notification hooks
- Large inputs: prefer file-based workflows over direct pasting; VS Code terminal is prone to truncating long pastes

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) -- all CLI commands (`claude`, `claude -p`, `claude -c`, `claude -r`, `claude update`, `claude auth`, `claude agents`, `claude mcp`, `claude remote-control`), all CLI flags with descriptions and examples, `--agents` JSON format, system prompt flags (`--system-prompt`, `--system-prompt-file`, `--append-system-prompt`, `--append-system-prompt-file`)
- [Interactive mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts (general controls, text editing, theme, multiline input), quick commands (`/`, `!`, `@`), built-in slash commands, vim editor mode (mode switching, navigation, editing, text objects), command history and reverse search, background bash commands, bash mode (`!` prefix), prompt suggestions, side questions (`/btw`), task list, PR review status
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) -- `~/.claude/keybindings.json` format, binding contexts, all available actions by context, keystroke syntax (modifiers, uppercase letters, chords, special keys), unbinding defaults, reserved shortcuts, terminal conflicts, vim mode interaction, validation
- [Optimize your terminal setup](references/claude-code-terminal-config.md) -- themes and appearance, line break methods, Shift+Enter and Option+Enter setup, notification configuration (terminal and hooks), handling large inputs, vim mode setup

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Optimize your terminal setup: https://code.claude.com/docs/en/terminal-config.md
