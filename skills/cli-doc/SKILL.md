---
name: cli-doc
description: Complete documentation for Claude Code CLI and interactive mode — CLI commands, flags (print, resume, model, system-prompt, agents, worktree, permissions, MCP config, tools), interactive keyboard shortcuts, slash commands, vim mode, multiline input, background tasks, bash mode, command history, reverse search, task list, PR review status, prompt suggestions, custom keybindings (contexts, actions, chords, vim interaction), and terminal configuration (line breaks, notifications, themes). Load when discussing CLI usage, flags, keyboard shortcuts, interactive features, keybindings, or terminal setup.
user-invocable: false
---

# CLI & Interactive Mode Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode features, custom keybindings, and terminal configuration.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive), then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation |
| `claude -c -p "query"` | Continue via SDK (non-interactive) |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (`--email`, `--sso` flags) |
| `claude auth logout` | Log out |
| `claude auth status` | Auth status as JSON (`--text` for human-readable) |
| `claude agents` | List all configured subagents |
| `claude mcp` | Configure MCP servers |
| `claude remote-control` | Start remote control session |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Continue most recent conversation |
| `-r`, `--resume` | Resume session by ID/name or open picker |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--fallback-model` | Fallback model when default is overloaded (print mode) |
| `--system-prompt` | Replace entire system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt` | Append to default system prompt |
| `--append-system-prompt-file` | Append from file to default prompt |
| `--agent` | Specify agent for session |
| `--agents` | Define subagents via JSON |
| `--add-dir` | Add extra working directories |
| `-w`, `--worktree` | Run in isolated git worktree |
| `--permission-mode` | Set permission mode (`plan`, `default`, etc.) |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--allowedTools` | Tools that skip permission prompts |
| `--disallowedTools` | Tools removed from model context |
| `--tools` | Restrict available built-in tools |
| `--mcp-config` | Load MCP servers from JSON file |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config` |
| `--plugin-dir` | Load plugins from directory |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Spending limit (print mode) |
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--input-format` | Input format: `text`, `stream-json` |
| `--json-schema` | Validated JSON output matching schema (print mode) |
| `--verbose` | Full turn-by-turn output |
| `--debug` | Debug mode with category filtering |
| `--chrome` / `--no-chrome` | Enable/disable Chrome integration |
| `--ide` | Auto-connect to IDE on startup |
| `--remote` | Create web session on claude.ai |
| `--teleport` | Resume web session locally |
| `--session-id` | Use specific UUID for conversation |
| `--fork-session` | Fork when resuming (new session ID) |
| `--from-pr` | Resume sessions linked to a GitHub PR |
| `--setting-sources` | Comma-separated setting sources to load |
| `--settings` | Path to additional settings JSON |
| `--betas` | Beta headers for API requests |
| `--init` / `--init-only` | Run initialization hooks (and optionally exit) |
| `--maintenance` | Run maintenance hooks and exit |
| `--no-session-persistence` | Don't save session to disk (print mode) |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, `tmux` |
| `--disable-slash-commands` | Disable all skills and commands |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt (recommended) |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either.

### `--agents` JSON Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `description` | Yes | When the subagent should be invoked |
| `prompt` | Yes | System prompt for the subagent |
| `tools` | No | Allowlist of tools (inherits all if omitted) |
| `disallowedTools` | No | Tools to deny |
| `model` | No | `sonnet`, `opus`, `haiku`, or `inherit` (default) |
| `skills` | No | Skills to preload |
| `mcpServers` | No | MCP servers for this subagent |
| `maxTurns` | No | Max agentic turns |

### Interactive Keyboard Shortcuts

#### General Controls

| Shortcut | Action |
|:---------|:-------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+F` | Kill all background agents (press twice to confirm) |
| `Ctrl+G` | Open prompt in external text editor |
| `Ctrl+L` | Clear terminal screen |
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
| Quick escape | `\` + Enter |
| macOS default | Option+Enter |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty; run `/terminal-setup` for others |
| Control sequence | `Ctrl+J` |

#### Quick Prefixes

| Prefix | Purpose |
|:-------|:--------|
| `/` | Slash commands and skills |
| `!` | Bash mode (run shell commands directly) |
| `@` | File path autocomplete |

### Built-in Slash Commands (Selected)

| Command | Purpose |
|:--------|:--------|
| `/clear` | Clear conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Compact conversation with optional focus |
| `/config` | Open settings (alias: `/settings`) |
| `/context` | Visualize context usage |
| `/copy` | Copy last response to clipboard |
| `/cost` | Show token usage statistics |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings |
| `/export [filename]` | Export conversation as text |
| `/fast [on\|off]` | Toggle fast mode |
| `/fork [name]` | Fork conversation |
| `/help` | Show help and commands |
| `/hooks` | Manage hook configurations |
| `/init` | Initialize CLAUDE.md |
| `/keybindings` | Open keybindings config file |
| `/memory` | Edit CLAUDE.md memory files |
| `/model [model]` | Select or change AI model |
| `/output-style [style]` | Switch output styles (Default, Explanatory, Learning) |
| `/permissions` | View/update permissions (alias: `/allowed-tools`) |
| `/plan` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/release-notes` | View changelog |
| `/resume [session]` | Resume conversation (alias: `/continue`) |
| `/review` | Review a pull request |
| `/rewind` | Rewind conversation/code (alias: `/checkpoint`) |
| `/sandbox` | Toggle sandbox mode |
| `/skills` | List available skills |
| `/terminal-setup` | Configure terminal keybindings |
| `/theme` | Change color theme |
| `/vim` | Toggle vim editing mode |

### Vim Mode Quick Reference

Enable with `/vim` or via `/config`. Supports mode switching (`i`/`I`/`a`/`A`/`o`/`O`/`Esc`), navigation (`h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f`/`F`/`t`/`T` with `;`/`,` repeat), editing (`x`, `dd`/`D`, `dw`/`de`/`db`, `cc`/`C`, `cw`/`ce`/`cb`, `.`), yank/paste (`yy`/`Y`, `yw`/`ye`/`yb`, `p`/`P`), text objects (`iw`/`aw`, `iW`/`aW`, `i"`/`a"`, `i'`/`a'`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`), and indentation (`>>`/`<<`/`J`).

### Custom Keybindings

Config file: `~/.claude/keybindings.json` (auto-detected on save, no restart needed). Run `/keybindings` to create or open.

#### Binding Contexts

| Context | Description |
|:--------|:------------|
| `Global` | Everywhere in the app |
| `Chat` | Main chat input |
| `Autocomplete` | Autocomplete menu open |
| `Settings` | Settings menu |
| `Confirmation` | Permission/confirmation dialogs |
| `Tabs` | Tab navigation |
| `Help` | Help menu visible |
| `Transcript` | Transcript viewer |
| `HistorySearch` | History search (Ctrl+R) |
| `Task` | Background task running |
| `ThemePicker` | Theme picker |
| `Attachments` | Attachment bar |
| `Footer` | Footer indicators |
| `MessageSelector` | Rewind/summarize message selection |
| `DiffDialog` | Diff viewer |
| `ModelPicker` | Model picker |
| `Select` | Generic select/list |
| `Plugin` | Plugin dialog |

#### Key Chat Actions

| Action | Default | Description |
|:-------|:--------|:------------|
| `chat:submit` | Enter | Submit message |
| `chat:cancel` | Escape | Cancel input |
| `chat:cycleMode` | Shift+Tab | Cycle permission modes |
| `chat:modelPicker` | Cmd+P / Meta+P | Open model picker |
| `chat:thinkingToggle` | Cmd+T / Meta+T | Toggle extended thinking |
| `chat:externalEditor` | Ctrl+G | Open in external editor |
| `chat:imagePaste` | Ctrl+V | Paste image |
| `chat:stash` | Ctrl+S | Stash current prompt |

#### Keystroke Syntax

- Modifiers: `ctrl`, `alt`/`opt`, `shift`, `meta`/`cmd` with `+` separator
- Chords: space-separated sequences (`ctrl+k ctrl+s`)
- Uppercase letter alone implies Shift (`K` = `shift+k`)
- Set action to `null` to unbind a default shortcut
- Reserved (cannot rebind): `Ctrl+C`, `Ctrl+D`

### Terminal Configuration

- **Line breaks**: `\`+Enter (all terminals), Option+Enter (macOS), Shift+Enter (iTerm2/WezTerm/Ghostty/Kitty natively; `/terminal-setup` for others), `Ctrl+J`
- **Notifications**: Kitty and Ghostty support desktop notifications natively. iTerm2 requires enabling "Notification Center Alerts" and "Send escape sequence-generated alerts". Other terminals: use notification hooks.
- **Option as Meta (macOS)**: iTerm2: Profiles > Keys > "Esc+"; Terminal.app: Profiles > Keyboard > "Use Option as Meta Key"; VS Code: Profiles > Keys > "Esc+"
- **Large inputs**: Avoid direct paste of very long content; use file-based workflows instead
- **Theme matching**: Use `/config` to match Claude Code theme to your terminal
- **Status line**: Configure with `/statusline` for contextual info (model, directory, git branch)

### Background Tasks & Bash Mode

- **Background**: Prompt Claude to run in background, or press `Ctrl+B` on a running command. Output buffered with unique task IDs.
- **Bash mode**: Prefix with `!` to run shell commands directly (e.g., `! npm test`). Output added to conversation context. Supports Tab autocomplete from previous commands. Disable background tasks with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

### Task List & PR Status

- **Task list**: `Ctrl+T` to toggle. Shows up to 10 tasks. Persists across compactions. Use `CLAUDE_CODE_TASK_LIST_ID` for shared lists across sessions. Revert to TODO list with `CLAUDE_CODE_ENABLE_TASKS=false`.
- **PR review status**: Colored underline on PR link in footer (green=approved, yellow=pending, red=changes requested, gray=draft, purple=merged). Updates every 60s. Requires `gh` CLI.

### Prompt Suggestions

Grayed-out suggestions appear based on git history and conversation. Press Tab to accept, Enter to accept and submit. Disable with `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false`.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) -- commands, flags, `--agents` JSON format, system prompt flags, output formats
- [Interactive mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts, slash commands, vim mode, command history, background tasks, bash mode, task list, PR status, prompt suggestions
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) -- keybindings.json format, contexts, actions, keystroke syntax, chords, unbinding, reserved shortcuts, vim mode interaction
- [Optimize your terminal setup](references/claude-code-terminal-config.md) -- line breaks, Shift+Enter setup, Option as Meta, notifications, large inputs, vim mode

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Optimize your terminal setup: https://code.claude.com/docs/en/terminal-config.md
