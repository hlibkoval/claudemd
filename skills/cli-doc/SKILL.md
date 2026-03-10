---
name: cli-doc
description: Complete documentation for the Claude Code CLI and interactive terminal experience -- CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude mcp, claude agents, claude remote-control), all CLI flags (--model, --print, --continue, --resume, --system-prompt, --append-system-prompt, --allowedTools, --disallowedTools, --tools, --agents, --json-schema, --output-format, --max-turns, --max-budget-usd, --permission-mode, --dangerously-skip-permissions, --mcp-config, --worktree, --add-dir, --plugin-dir, --chrome, --remote, --teleport, --debug, --verbose, --fallback-model, --agent), system prompt flags, --agents JSON format, interactive mode keyboard shortcuts, multiline input methods, built-in slash commands (/clear, /compact, /config, /cost, /diff, /model, /permissions, /resume, /vim, /theme, /tasks, /rewind, /fork, /export, /skills, /plan, etc.), vim editor mode, command history, reverse search (Ctrl+R), background bash commands, bash mode (! prefix), prompt suggestions, task list (Ctrl+T), PR review status, customizable keybindings (contexts, actions, keystroke syntax, chords, vim mode interaction, reserved shortcuts), terminal configuration (line breaks, Shift+Enter setup, notifications, themes, vim mode, large input handling). Load when discussing CLI usage, command-line flags, interactive shortcuts, slash commands, terminal setup, keybindings configuration, or vim mode in Claude Code.
user-invocable: false
---

# CLI & Interactive Mode Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive terminal features, keybindings, and terminal configuration.

## Quick Reference

### CLI Commands

| Command | Description | Example |
|:--------|:------------|:--------|
| `claude` | Start interactive session | `claude` |
| `claude "query"` | Start with initial prompt | `claude "explain this project"` |
| `claude -p "query"` | Non-interactive (SDK/scripting) | `claude -p "explain this function"` |
| `cat file \| claude -p "query"` | Process piped content | `cat logs.txt \| claude -p "explain"` |
| `claude -c` | Continue most recent conversation | `claude -c` |
| `claude -c -p "query"` | Continue via SDK | `claude -c -p "Check for type errors"` |
| `claude -r "<session>" "query"` | Resume session by ID or name | `claude -r "auth-refactor" "Finish this PR"` |
| `claude update` | Update to latest version | `claude update` |
| `claude auth login` | Sign in (`--email`, `--sso`) | `claude auth login --email user@example.com --sso` |
| `claude auth logout` | Sign out | `claude auth logout` |
| `claude auth status` | Auth status JSON (`--text` for human) | `claude auth status` |
| `claude agents` | List configured subagents | `claude agents` |
| `claude mcp` | Configure MCP servers | See mcp-doc skill |
| `claude remote-control` | Start remote control session | `claude remote-control` |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `--print`, `-p` | Non-interactive mode (exit after response) |
| `--continue`, `-c` | Continue most recent conversation |
| `--resume`, `-r` | Resume session by ID/name or show picker |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--input-format` | Input format: `text`, `stream-json` |
| `--json-schema` | Get validated JSON output matching a schema (print mode) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Spending cap (print mode) |
| `--fallback-model` | Auto-fallback when default model is overloaded (print mode) |
| `--system-prompt` | Replace entire system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt` | Append to default system prompt |
| `--append-system-prompt-file` | Append from file to default prompt |
| `--allowedTools` | Tools that skip permission prompts |
| `--disallowedTools` | Tools removed from model context |
| `--tools` | Restrict available built-in tools (`""`, `"default"`, `"Bash,Edit,Read"`) |
| `--agents` | Define subagents via JSON |
| `--agent` | Specify agent for session |
| `--permission-mode` | Start in a permission mode (`plan`, etc.) |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--allow-dangerously-skip-permissions` | Enable bypass without activating |
| `--mcp-config` | Load MCP servers from JSON files |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config` |
| `--add-dir` | Add additional working directories |
| `--plugin-dir` | Load plugins from directories |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--chrome` / `--no-chrome` | Enable/disable Chrome integration |
| `--remote` | Create web session on claude.ai |
| `--teleport` | Resume web session locally |
| `--ide` | Auto-connect to IDE on startup |
| `--debug` | Debug mode with category filtering |
| `--verbose` | Verbose logging |
| `--version`, `-v` | Show version |
| `--init` / `--init-only` | Run init hooks (with or without session) |
| `--maintenance` | Run maintenance hooks and exit |
| `--fork-session` | Fork when resuming (new session ID) |
| `--from-pr` | Resume sessions linked to a PR |
| `--session-id` | Use specific UUID for conversation |
| `--no-session-persistence` | Disable session saving (print mode) |
| `--setting-sources` | Comma-separated setting sources: `user`, `project`, `local` |
| `--settings` | Load settings from JSON file or string |
| `--betas` | Beta headers for API requests |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, `tmux` |
| `--disable-slash-commands` | Disable all skills and commands |
| `--include-partial-messages` | Include partial streaming events |

### System Prompt Flags

| Flag | Behavior | Recommended for |
|:-----|:---------|:----------------|
| `--system-prompt` | Replaces entire default prompt | Complete control |
| `--system-prompt-file` | Replaces with file contents | Team consistency |
| `--append-system-prompt` | Appends to default prompt | Most use cases (safest) |
| `--append-system-prompt-file` | Appends file to default prompt | Version-controlled additions |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either.

### --agents JSON Format

```json
{
  "agent-name": {
    "description": "When to invoke (required)",
    "prompt": "System prompt (required)",
    "tools": ["Read", "Edit", "Bash"],
    "disallowedTools": ["Write"],
    "model": "sonnet",
    "skills": ["my-skill"],
    "mcpServers": ["server-name"],
    "maxTurns": 10
  }
}
```

### Interactive Mode Keyboard Shortcuts

**General controls:**

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Cancel current input/generation |
| `Ctrl+D` | Exit Claude Code |
| `Ctrl+F` | Kill all background agents (press twice to confirm) |
| `Ctrl+G` | Open in external text editor |
| `Ctrl+L` | Clear terminal screen (keeps history) |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+V` / `Cmd+V` / `Alt+V` | Paste image from clipboard |
| `Esc Esc` | Rewind or summarize |
| `Shift+Tab` / `Alt+M` | Toggle permission modes |
| `Alt+P` / `Option+P` | Switch model |
| `Alt+T` / `Option+T` | Toggle extended thinking |

**Text editing:** `Ctrl+K` (delete to EOL), `Ctrl+U` (delete line), `Ctrl+Y` (paste deleted), `Alt+Y` (cycle paste history), `Alt+B`/`Alt+F` (word nav)

**Multiline input:** `\` + Enter (all terminals), `Option+Enter` (macOS), `Shift+Enter` (iTerm2/WezTerm/Ghostty/Kitty natively; run `/terminal-setup` for VS Code/Alacritty/Zed/Warp), `Ctrl+J` (line feed)

**Quick input prefixes:** `/` (slash command or skill), `!` (bash mode), `@` (file path mention)

### Built-in Slash Commands (Selected)

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
| `/model [model]` | Select/change model (left/right for effort) |
| `/permissions` | View/update permissions (alias: `/allowed-tools`) |
| `/plan` | Enter plan mode |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/rename [name]` | Rename session |
| `/resume [session]` | Resume conversation (alias: `/continue`) |
| `/rewind` | Rewind conversation/code (alias: `/checkpoint`) |
| `/skills` | List available skills |
| `/tasks` | List/manage background tasks |
| `/theme` | Change color theme |
| `/vim` | Toggle vim/normal editing |
| `/terminal-setup` | Configure terminal keybindings |
| `/keybindings` | Open keybindings config file |
| `/memory` | Edit CLAUDE.md and auto-memory |
| `/fast [on\|off]` | Toggle fast mode |
| `/output-style [style]` | Switch output style (Default/Explanatory/Learning) |
| `/statusline` | Configure status line |
| `/sandbox` | Toggle sandbox mode |

Full list: 50+ commands. Type `/` in Claude Code to see all available for your environment.

### Vim Editor Mode

Enable with `/vim` or `/config`. Supports mode switching (`i`/`I`/`a`/`A`/`o`/`O`/`Esc`), navigation (`h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f`/`F`/`t`/`T` with `;`/`,`), editing (`x`, `dd`/`D`, `dw`/`de`/`db`, `cc`/`C`, `cw`/`ce`/`cb`, `.`), yank/paste (`yy`/`Y`, `yw`/`ye`/`yb`, `p`/`P`), text objects (`iw`/`aw`, `iW`/`aW`, `i"`/`a"`, `i'`/`a'`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`), indentation (`>>`/`<<`), and join (`J`).

### Command History and Reverse Search

- Input history stored per working directory; resets on `/clear`
- Up/Down arrows to navigate history
- `Ctrl+R` for interactive reverse search: type to filter, `Ctrl+R` again to cycle, `Tab`/`Esc` to accept and edit, `Enter` to accept and execute, `Ctrl+C` to cancel

### Background Tasks and Bash Mode

- Prompt Claude to run commands in the background, or press `Ctrl+B` to background a running command
- `!` prefix runs bash commands directly without Claude interpretation; output added to context
- Bash mode supports `Tab` autocomplete from previous `!` commands
- Disable background tasks: `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`

### Prompt Suggestions

Auto-generated follow-up suggestions appear after Claude responds. Press `Tab` to accept, `Enter` to accept and submit. Disable: `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false` or toggle in `/config`.

### Task List

`Ctrl+T` toggles the task list for multi-step work. Tasks persist across compactions. Share across sessions: `CLAUDE_CODE_TASK_LIST_ID=my-project claude`. Revert to old TODO list: `CLAUDE_CODE_ENABLE_TASKS=false`.

### PR Review Status

Clickable PR link in footer with colored underline: green (approved), yellow (pending), red (changes requested), gray (draft), purple (merged). Requires `gh` CLI.

### Custom Keybindings

Configure at `~/.claude/keybindings.json` (open with `/keybindings`). Changes auto-apply without restart.

**Contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`

**Key actions:**

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
| Chat | `chat:stash` | Ctrl+S |
| Task | `task:background` | Ctrl+B |

**Keystroke syntax:** Modifiers with `+` (`ctrl+k`, `shift+tab`, `meta+p`, `ctrl+shift+c`). Uppercase letter implies Shift (`K` = `shift+k`). Chords separated by spaces (`ctrl+k ctrl+s`). Special keys: `escape`, `enter`, `tab`, `space`, `up`/`down`/`left`/`right`, `backspace`, `delete`.

**Unbind:** Set action to `null`. **Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`. **Terminal conflicts:** `Ctrl+B` (tmux), `Ctrl+A` (screen), `Ctrl+Z` (suspend).

### Terminal Configuration

- **Theme matching:** Use `/config` to match Claude Code theme to your terminal
- **Status line:** Configure with `/statusline`
- **Shift+Enter setup:** Run `/terminal-setup` for VS Code, Alacritty, Zed, Warp (native in iTerm2/WezTerm/Ghostty/Kitty)
- **Option as Meta (macOS):** iTerm2: Profiles > Keys > "Esc+"; Terminal.app: Profiles > Keyboard > "Use Option as Meta Key"
- **Notifications:** Native in Kitty/Ghostty; iTerm2 needs Terminal > "Notification Center Alerts" + "Send escape sequence-generated alerts"; other terminals use notification hooks
- **Large inputs:** Use file-based workflows; avoid pasting very long content (especially in VS Code terminal)

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) -- all CLI commands, flags, --agents JSON format, system prompt flags
- [Interactive mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts, built-in slash commands, vim editor mode, command history, reverse search, background tasks, bash mode, prompt suggestions, task list, PR review status
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) -- keybindings.json configuration, contexts, available actions, keystroke syntax, chords, unbinding, reserved shortcuts, vim mode interaction, validation
- [Optimize your terminal setup](references/claude-code-terminal-config.md) -- themes, line breaks, Shift+Enter setup, Option as Meta, notifications, large inputs, vim mode

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Optimize your terminal setup: https://code.claude.com/docs/en/terminal-config.md
