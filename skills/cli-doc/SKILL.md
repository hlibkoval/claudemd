---
name: cli-doc
description: Complete documentation for Claude Code CLI and interactive mode -- CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude mcp, claude remote-control), CLI flags (--model, --print, --continue, --resume, --system-prompt, --append-system-prompt, --allowedTools, --disallowedTools, --tools, --permission-mode, --dangerously-skip-permissions, --output-format, --json-schema, --max-turns, --max-budget-usd, --mcp-config, --agents, --agent, --worktree, --add-dir, --debug, --verbose, --chrome, --remote, --teleport, --plugin-dir, --settings, --fallback-model, --fork-session, --from-pr, --ide, --init, --session-id), system prompt flags (--system-prompt, --system-prompt-file, --append-system-prompt, --append-system-prompt-file), interactive mode features (keyboard shortcuts, multiline input, vim mode, command history, reverse search, background bash commands, bash mode, prompt suggestions, side questions with /btw, task list, PR review status), built-in slash commands (/clear, /compact, /config, /cost, /diff, /doctor, /export, /fork, /help, /hooks, /init, /keybindings, /memory, /model, /permissions, /plan, /pr-comments, /resume, /rewind, /skills, /status, /theme, /vim, and more), customizable keybindings (contexts, actions, keystroke syntax, chords, vim mode interaction, reserved shortcuts, terminal conflicts), terminal configuration (line breaks, Shift+Enter setup, notifications, large inputs). Load when discussing Claude Code CLI usage, command-line flags, interactive shortcuts, slash commands, keybindings, vim mode, terminal setup, bash mode, background tasks, multiline input, system prompt customization, or the /terminal-setup command.
user-invocable: false
---

# CLI & Interactive Mode Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive session features, keybindings, and terminal configuration.

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
| `claude auth login` | Sign in (supports `--email` and `--sso`) |
| `claude auth logout` | Log out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List all configured subagents |
| `claude mcp` | Configure MCP servers |
| `claude remote-control` | Start a Remote Control session |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `--print`, `-p` | Non-interactive mode |
| `--continue`, `-c` | Resume most recent conversation |
| `--resume`, `-r` | Resume specific session by ID or name |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--json-schema` | Get validated JSON output matching a schema (print mode) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Maximum dollar spend (print mode) |
| `--fallback-model` | Fallback model when default is overloaded (print mode) |
| `--system-prompt` | Replace entire system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt` | Append to default system prompt |
| `--append-system-prompt-file` | Append file contents to default prompt |
| `--allowedTools` | Tools that execute without permission prompts |
| `--disallowedTools` | Tools removed from context entirely |
| `--tools` | Restrict available built-in tools (`""` for none, `"default"` for all) |
| `--permission-mode` | Start in a specific permission mode |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--mcp-config` | Load MCP servers from JSON file or string |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config` |
| `--agents` | Define custom subagents via JSON |
| `--agent` | Specify an agent for the session |
| `--worktree`, `-w` | Start in an isolated git worktree |
| `--add-dir` | Add additional working directories |
| `--plugin-dir` | Load plugins from directories |
| `--settings` | Load additional settings from file or JSON string |
| `--setting-sources` | Comma-separated setting sources to load |
| `--chrome` / `--no-chrome` | Enable/disable Chrome browser integration |
| `--remote` | Create a web session on claude.ai |
| `--teleport` | Resume a web session locally |
| `--ide` | Auto-connect to IDE on startup |
| `--init` / `--init-only` | Run initialization hooks (with or without session) |
| `--maintenance` | Run maintenance hooks and exit |
| `--session-id` | Use a specific UUID for the conversation |
| `--fork-session` | Fork instead of reuse when resuming |
| `--from-pr` | Resume sessions linked to a GitHub PR |
| `--debug` | Debug mode with optional category filtering |
| `--verbose` | Full turn-by-turn output |
| `--no-session-persistence` | Don't save session to disk (print mode) |
| `--input-format` | Input format for print mode (`text`, `stream-json`) |
| `--include-partial-messages` | Include partial streaming events (print mode) |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, `tmux` |
| `--betas` | Beta headers for API requests (API key users) |
| `--disable-slash-commands` | Disable all skills and commands for the session |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | **Replaces** entire default prompt |
| `--system-prompt-file` | **Replaces** with file contents |
| `--append-system-prompt` | **Appends** to default prompt |
| `--append-system-prompt-file` | **Appends** file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. The append flags can combine with either replacement flag. For most use cases, the append variants are recommended since they preserve built-in capabilities.

### --agents Flag Format

Each subagent definition accepts:

| Field | Required | Description |
|:------|:---------|:------------|
| `description` | Yes | When the subagent should be invoked |
| `prompt` | Yes | System prompt for the subagent |
| `tools` | No | Array of allowed tools (inherits all if omitted) |
| `disallowedTools` | No | Array of denied tools |
| `model` | No | `sonnet`, `opus`, `haiku`, or `inherit` (default) |
| `skills` | No | Array of skill names to preload |
| `mcpServers` | No | Array of MCP servers for this subagent |
| `maxTurns` | No | Maximum agentic turns |

### Interactive Keyboard Shortcuts

#### General Controls

| Shortcut | Description |
|:---------|:------------|
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
| `Esc Esc` | Rewind or summarize |
| `Shift+Tab` | Toggle permission modes |
| `Alt+P` | Switch model |
| `Alt+T` | Toggle extended thinking |

#### Quick Input Prefixes

| Prefix | Description |
|:-------|:------------|
| `/` | Slash command or skill |
| ` ` (exclamation) | Bash mode -- run shell commands directly |
| `@` | File path autocomplete |

#### Multiline Input

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + `Enter` |
| macOS default | `Option+Enter` |
| iTerm2/WezTerm/Ghostty/Kitty | `Shift+Enter` (native) |
| Other terminals | Run `/terminal-setup` for `Shift+Enter` |
| Control sequence | `Ctrl+J` |

### Built-in Slash Commands (Selected)

| Command | Purpose |
|:--------|:--------|
| `/clear` | Clear conversation (aliases: `/reset`, `/new`) |
| `/compact [focus]` | Compact conversation with optional focus |
| `/config` | Open settings interface (alias: `/settings`) |
| `/context` | Visualize current context usage |
| `/copy` | Copy last response to clipboard |
| `/cost` | Show token usage statistics |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings |
| `/export [file]` | Export conversation as text |
| `/fork [name]` | Fork conversation at current point |
| `/help` | Show help and commands |
| `/init` | Initialize project with CLAUDE.md |
| `/keybindings` | Open keybindings config file |
| `/memory` | Edit CLAUDE.md files and auto memory |
| `/model [model]` | Change AI model (arrows adjust effort level) |
| `/output-style [style]` | Switch output styles (Default, Explanatory, Learning) |
| `/permissions` | View/update permissions (alias: `/allowed-tools`) |
| `/plan` | Enter plan mode |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/resume [session]` | Resume a conversation (alias: `/continue`) |
| `/rewind` | Rewind conversation/code (alias: `/checkpoint`) |
| `/skills` | List available skills |
| `/status` | Show version, model, account info |
| `/theme` | Change color theme |
| `/vim` | Toggle vim editing mode |
| `/btw <question>` | Side question without adding to history |

### Vim Mode Summary

Enable with `/vim` or `/config`. Supports mode switching (`Esc`/`i`/`I`/`a`/`A`/`o`/`O`), navigation (`h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f`/`F`/`t`/`T`), editing (`x`, `dd`/`D`, `dw`/`de`/`db`, `cc`/`C`/`cw`/`ce`/`cb`, `yy`/`Y`/`yw`/`ye`/`yb`, `p`/`P`, `>>`/`<<`, `J`, `.`), and text objects (`iw`/`aw`, `i"`/`a"`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`).

### Customizable Keybindings

Configuration file: `~/.claude/keybindings.json` (open with `/keybindings`). Changes auto-reload.

#### Keybinding Contexts

| Context | Description |
|:--------|:------------|
| `Global` | Everywhere in the app |
| `Chat` | Main chat input |
| `Autocomplete` | Autocomplete menu open |
| `Confirmation` | Permission/confirmation dialogs |
| `Tabs` | Tab navigation |
| `HistorySearch` | History search mode |
| `Task` | Background task running |
| `ThemePicker` | Theme picker dialog |
| `Attachments` | Image/attachment bar |
| `Footer` | Footer indicator navigation |
| `MessageSelector` | Rewind/summarize dialog |
| `DiffDialog` | Diff viewer |
| `ModelPicker` | Model picker effort level |
| `Select` | Generic select/list |
| `Plugin` | Plugin dialog |
| `Settings` | Settings menu |
| `Help` | Help menu |
| `Transcript` | Transcript viewer |

#### Keystroke Syntax

- **Modifiers**: `ctrl`, `alt`/`opt`/`option`, `shift`, `meta`/`cmd`/`command` joined with `+`
- **Uppercase letters**: standalone `K` implies `shift+k`; with modifiers (`ctrl+K`) does not imply shift
- **Chords**: space-separated sequences (`ctrl+k ctrl+s`)
- **Special keys**: `escape`/`esc`, `enter`/`return`, `tab`, `space`, `up`/`down`/`left`/`right`, `backspace`, `delete`
- **Unbind**: set action to `null`
- **Reserved** (cannot rebind): `Ctrl+C`, `Ctrl+D`

#### Terminal Conflicts

| Shortcut | Conflict |
|:---------|:---------|
| `Ctrl+B` | tmux prefix (press twice) |
| `Ctrl+A` | GNU screen prefix |
| `Ctrl+Z` | Unix process suspend (SIGTSTP) |

### Terminal Configuration

- **Line breaks**: `\` + Enter (all terminals), `Shift+Enter` (native in iTerm2/WezTerm/Ghostty/Kitty, `/terminal-setup` for others), `Option+Enter` (macOS with Option-as-Meta)
- **Notifications**: Native in Kitty/Ghostty; iTerm2 requires enabling Notification Center Alerts; other terminals use notification hooks
- **Option as Meta (macOS)**: iTerm2: Profiles > Keys > "Esc+"; Terminal.app: Profiles > Keyboard > "Use Option as Meta Key"
- **Large inputs**: Prefer file-based workflows over direct pasting; VS Code terminal is prone to truncating long pastes

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) -- CLI commands, all CLI flags with descriptions and examples, --agents flag format, system prompt flags (replace vs append)
- [Interactive mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts, built-in slash commands, vim editor mode, command history, reverse search, background bash commands, bash mode, prompt suggestions, side questions with /btw, task list, PR review status
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) -- keybindings.json configuration, contexts, all available actions by namespace, keystroke syntax (modifiers, chords, special keys), unbinding defaults, reserved shortcuts, terminal conflicts, vim mode interaction
- [Terminal configuration](references/claude-code-terminal-config.md) -- terminal themes, line break setup, Shift+Enter configuration, notification setup, Option as Meta on macOS, handling large inputs, vim mode overview

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Optimize your terminal setup: https://code.claude.com/docs/en/terminal-config.md
