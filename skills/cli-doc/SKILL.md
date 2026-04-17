---
name: cli-doc
description: Complete official documentation for the Claude Code CLI — launch commands, flags, slash commands, interactive mode shortcuts, keybindings customization, terminal configuration, Vim mode, built-in tools reference, and bash/background task behavior.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, keyboard shortcuts, keybindings, terminal configuration, and built-in tools.

## Quick Reference

### CLI commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive), then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation |
| `claude -r <session> "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (`--email`, `--sso`, `--console` options) |
| `claude auth status` | Show auth status as JSON (`--text` for readable) |
| `claude agents` | List configured subagents |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude remote-control` | Start Remote Control server |
| `claude setup-token` | Generate long-lived OAuth token for CI |

### Key CLI flags

| Flag | Description |
| :--- | :--- |
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Continue most recent conversation |
| `-r`, `--resume` | Resume session by ID or name |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--permission-mode` | `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--allowedTools` | Tools that execute without permission prompts |
| `--disallowedTools` | Tools removed from context entirely |
| `--tools` | Restrict which built-in tools are available |
| `--bare` | Skip hooks, skills, plugins, MCP, memory, CLAUDE.md |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Spending cap (print mode only) |
| `--output-format` | `text`, `json`, `stream-json` |
| `--input-format` | `text`, `stream-json` |
| `--json-schema` | Validated JSON output matching a schema |
| `--mcp-config` | Load MCP servers from JSON file |
| `--add-dir` | Add working directories for file access |
| `--worktree`, `-w` | Start in an isolated git worktree |
| `--effort` | `low`, `medium`, `high`, `xhigh`, `max` |
| `--chrome` / `--no-chrome` | Enable/disable Chrome browser integration |
| `--agent` | Specify agent for the session |
| `--fallback-model` | Auto-fallback model when overloaded (print mode) |
| `--name`, `-n` | Set session display name |
| `--remote` | Start web session on claude.ai |
| `--teleport` | Resume a web session locally |
| `--debug` | Enable debug mode (optional category filter) |

### System prompt flags

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either.

### Slash commands (selected)

| Command | Purpose |
| :--- | :--- |
| `/clear` | Start new conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Compact conversation with optional focus |
| `/config` | Open settings interface (alias: `/settings`) |
| `/context` | Visualize current context usage |
| `/cost` | Show token usage statistics |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/effort [level]` | Set model effort level |
| `/fast [on\|off]` | Toggle fast mode |
| `/model [model]` | Select or change the AI model |
| `/permissions` | Manage tool permission rules |
| `/plan [description]` | Enter plan mode |
| `/resume [session]` | Resume a conversation |
| `/rewind` | Rewind conversation and/or code (aliases: `/checkpoint`, `/undo`) |
| `/review [PR]` | Review a pull request locally |
| `/batch <instruction>` | [Skill] Orchestrate parallel codebase changes |
| `/loop [interval] [prompt]` | [Skill] Run prompt on recurring interval |
| `/simplify [focus]` | [Skill] Review changed files for quality issues |
| `/btw <question>` | Side question without adding to context |
| `/copy [N]` | Copy last response to clipboard |
| `/export [filename]` | Export conversation as text |
| `/voice` | Toggle push-to-talk voice dictation |

### Interactive mode keyboard shortcuts

**General controls:**

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open in external text editor |
| `Ctrl+L` | Clear input and redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks |
| `Ctrl+T` | Toggle task list |
| `Shift+Tab` / `Alt+M` | Cycle permission modes |
| `Alt+P` | Switch model |
| `Alt+T` | Toggle extended thinking |
| `Alt+O` | Toggle fast mode |
| `Esc Esc` | Rewind or summarize |

**Multiline input:**

| Method | Shortcut |
| :--- | :--- |
| Quick escape | `\` + `Enter` |
| macOS default | `Option+Enter` |
| Native support | `Shift+Enter` (iTerm2, WezTerm, Ghostty, Kitty) |
| Line feed | `Ctrl+J` |

**Quick prefixes:**

| Prefix | Action |
| :--- | :--- |
| `/` | Command or skill |
| `!` | Bash mode (run shell commands directly) |
| `@` | File path mention with autocomplete |

### Keybindings customization

Configuration file: `~/.claude/keybindings.json`. Run `/keybindings` to create or open it. Changes apply without restarting.

**Binding contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Scroll`, `Doctor`

**Key chat actions:**

| Action | Default |
| :--- | :--- |
| `chat:submit` | `Enter` |
| `chat:newline` | `Ctrl+J` |
| `chat:cycleMode` | `Shift+Tab` |
| `chat:modelPicker` | `Cmd+P` / `Meta+P` |
| `chat:externalEditor` | `Ctrl+G`, `Ctrl+X Ctrl+E` |
| `chat:imagePaste` | `Ctrl+V` |
| `chat:fastMode` | `Meta+O` |
| `chat:thinkingToggle` | `Cmd+T` / `Meta+T` |

**Keystroke syntax:** Modifiers joined with `+` (`ctrl+k`, `shift+tab`). Chords separated by spaces (`ctrl+k ctrl+s`). Uppercase letter implies Shift (`K` = `shift+k`). Set action to `null` to unbind.

**Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`

### Terminal configuration

- **Shift+Enter**: Works natively in iTerm2, WezTerm, Ghostty, Kitty. Run `/terminal-setup` for VS Code, Alacritty, Zed, Warp
- **tmux Shift+Enter**: Add `set -s extended-keys on` and `set -as terminal-features 'xterm*:extkeys'` to `~/.tmux.conf`
- **macOS Option-as-Meta**: Required for `Alt+B`, `Alt+F`, `Alt+Y`, `Alt+M`, `Alt+P`, `Alt+T` shortcuts. Configure in iTerm2 (Profiles > Keys > "Esc+"), Terminal.app (Profiles > Keyboard > "Use Option as Meta Key"), or VS Code (`terminal.integrated.macOptionIsMeta: true`)
- **Notifications**: Kitty and Ghostty work natively. iTerm2: enable Notification Center Alerts + escape sequence alerts. tmux: `set -g allow-passthrough on`
- **Vim mode**: Enable via `/config` > Editor mode. Supports mode switching, navigation, editing, yank/paste, text objects, indentation

### Built-in tools

| Tool | Permission | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawn subagent with own context |
| `Bash` | Yes | Execute shell commands |
| `Edit` | Yes | Targeted file edits |
| `Write` | Yes | Create or overwrite files |
| `Read` | No | Read file contents |
| `Glob` | No | Find files by pattern |
| `Grep` | No | Search file contents |
| `LSP` | No | Code intelligence (definitions, references, errors) |
| `Monitor` | Yes | Background watch with live notifications |
| `WebFetch` | Yes | Fetch URL content |
| `WebSearch` | Yes | Perform web searches |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `Skill` | Yes | Execute a skill |
| `EnterPlanMode` | No | Switch to plan mode |
| `ExitPlanMode` | Yes | Present plan and exit plan mode |
| `EnterWorktree` | No | Create/enter isolated git worktree |
| `ExitWorktree` | No | Return from worktree |
| `CronCreate` | No | Schedule recurring prompt |
| `ToolSearch` | No | Search and load deferred tools |
| `PowerShell` | Yes | Native PowerShell commands |

**Bash tool behavior**: Each command runs in a separate process. `cd` persists within project boundaries. Environment variables do not persist between commands. Use `CLAUDE_ENV_FILE` for persistent env vars.

**Monitor tool**: Runs a background watch script, delivers each output line to Claude. Uses same permission rules as Bash. Not available on Bedrock, Vertex AI, or Foundry.

**LSP tool**: Requires a code intelligence plugin. Provides jump-to-definition, find references, type info, workspace symbols, call hierarchies. Auto-reports errors after file edits.

**PowerShell tool**: Enable with `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. On Windows, auto-detects `pwsh.exe` (7+) with fallback to `powershell.exe` (5.1).

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — all CLI commands, flags, system prompt flags, and examples
- [Commands](references/claude-code-commands.md) — complete slash command reference with descriptions and usage
- [Interactive mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, Vim mode, command history, background tasks, bash mode, prompt suggestions, side questions, task list, session recap, and PR review status
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) — keybindings.json format, contexts, all available actions with defaults, keystroke syntax, chords, unbinding, reserved keys, Vim mode interaction, and validation
- [Terminal configuration](references/claude-code-terminal-config.md) — Shift+Enter setup, Option-as-Meta, notifications, tmux passthrough, flicker reduction, large input handling, and Vim mode
- [Tools reference](references/claude-code-tools-reference.md) — complete built-in tools table with permission requirements, Bash/LSP/Monitor/PowerShell tool behavior details

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Terminal configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
