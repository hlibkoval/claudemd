---
name: cli-doc
description: Complete official documentation for the Claude Code CLI — commands, flags, interactive mode shortcuts, keybindings customization, terminal configuration, and the full tools reference.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, keybindings, terminal setup, and built-in tools.

## Quick Reference

### CLI commands

| Command | Description |
| :-- | :-- |
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive), then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation |
| `claude -r "<id-or-name>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (`--console` for API billing, `--sso` to force SSO) |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List configured subagents |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude remote-control` | Start a Remote Control server |
| `claude setup-token` | Generate long-lived OAuth token for CI |

### Key CLI flags

| Flag | Purpose |
| :-- | :-- |
| `-p` / `--print` | Non-interactive print mode |
| `-c` / `--continue` | Continue most recent conversation |
| `-r` / `--resume` | Resume session by ID or name |
| `-n` / `--name` | Set session display name |
| `-w` / `--worktree` | Start in isolated git worktree |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--allowedTools` | Tools that skip permission prompts |
| `--disallowedTools` | Tools removed from context |
| `--tools` | Restrict available tools (e.g. `"Bash,Edit,Read"`) |
| `--add-dir` | Add additional working directories |
| `--agent` | Specify agent for session |
| `--agents` | Define subagents dynamically via JSON |
| `--mcp-config` | Load MCP servers from JSON files |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` |
| `--input-format` | Input format for print mode: `text`, `stream-json` |
| `--json-schema` | Validated JSON output matching a schema (print mode) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Spend cap per session (print mode) |
| `--fallback-model` | Fallback when primary model overloaded (print mode) |
| `--chrome` / `--no-chrome` | Enable/disable Chrome browser integration |
| `--remote` | Create web session on claude.ai |
| `--remote-control` / `--rc` | Interactive session with Remote Control |
| `--teleport` | Resume a web session locally |
| `--tmux` | Create tmux session for worktree |
| `--debug` | Debug mode with optional category filter |
| `--verbose` | Full turn-by-turn output |
| `-v` / `--version` | Print version number |

### System prompt flags

| Flag | Behavior |
| :-- | :-- |
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either.

### Interactive mode shortcuts

#### General controls

| Shortcut | Action |
| :-- | :-- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open in external text editor |
| `Ctrl+L` | Clear input and redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks |
| `Ctrl+T` | Toggle task list |
| `Shift+Tab` | Cycle permission modes |
| `Alt+P` | Switch model |
| `Alt+T` | Toggle extended thinking |
| `Alt+O` | Toggle fast mode |
| `Esc Esc` | Rewind or summarize |

#### Quick input prefixes

| Prefix | Action |
| :-- | :-- |
| `/` | Slash command or skill |
| `` ` `` (preceded by !) | Bash mode (run shell command directly) |
| `@` | File path autocomplete |

#### Multiline input

| Method | Shortcut |
| :-- | :-- |
| Quick escape | `\` + `Enter` |
| macOS default | `Option+Enter` |
| Shift+Enter | Works natively in iTerm2, WezTerm, Ghostty, Kitty; run `/terminal-setup` for VS Code, Alacritty, Zed, Warp |
| Line feed | `Ctrl+J` |

### Vim mode summary

Enable via `/config` > Editor mode. Supports: mode switching (`Esc`, `i`/`I`, `a`/`A`, `o`/`O`), navigation (`h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f`/`F`/`t`/`T`), editing (`x`, `dd`/`D`, `dw`/`de`/`db`, `cc`/`C`, `.`), yank/paste (`yy`/`Y`, `yw`/`ye`/`yb`, `p`/`P`), text objects (`iw`/`aw`, `i"`/`a"`, `i(`/`a(`, etc.), indentation (`>>`/`<<`), join (`J`).

### Commands (slash commands)

Type `/` in a session to see all available commands. Key built-in commands:

| Command | Purpose |
| :-- | :-- |
| `/clear` | New conversation (aliases: `/reset`, `/new`) |
| `/compact` | Summarize conversation to free context |
| `/config` | Open settings (alias: `/settings`) |
| `/model` | Change AI model |
| `/effort` | Set effort level |
| `/permissions` | Manage tool allow/deny rules |
| `/resume` | Resume a session (alias: `/continue`) |
| `/diff` | Interactive diff viewer |
| `/rewind` | Rewind conversation/code (aliases: `/checkpoint`, `/undo`) |
| `/copy` | Copy last response to clipboard |
| `/cost` | Show token usage stats |
| `/export` | Export conversation as text |
| `/context` | Visualize context usage |
| `/memory` | Edit CLAUDE.md and auto memory |
| `/hooks` | View hook configurations |
| `/mcp` | Manage MCP connections |
| `/plugin` | Manage plugins |
| `/skills` | List available skills |
| `/doctor` | Diagnose installation |
| `/voice` | Toggle push-to-talk dictation |
| `/theme` | Change color theme |
| `/btw` | Side question without adding to context |
| `/plan` | Enter plan mode |
| `/branch` | Branch conversation (alias: `/fork`) |
| `/review` | Review a PR locally |
| `/sandbox` | Toggle sandbox mode |

Key bundled **skills** (prompt-based, also auto-activate when relevant):

| Skill command | Purpose |
| :-- | :-- |
| `/batch` | Parallel multi-agent codebase changes |
| `/simplify` | Review changed code for reuse/quality |
| `/fewer-permission-prompts` | Auto-generate allowlist from transcripts |
| `/loop` | Run prompt on recurring interval |
| `/debug` | Enable debug logging and troubleshoot |
| `/claude-api` | Load Claude API reference material |

### Keybindings customization

Customize shortcuts in `~/.claude/keybindings.json` (run `/keybindings` to open). Changes hot-reload.

**Config structure**: `{ "bindings": [{ "context": "<Context>", "bindings": { "<keystroke>": "<action>" } }] }`

| Context | Description |
| :-- | :-- |
| `Global` | Applies everywhere |
| `Chat` | Main chat input |
| `Autocomplete` | Autocomplete menu open |
| `Confirmation` | Permission/confirmation dialogs |
| `Transcript` | Transcript viewer |
| `HistorySearch` | History search (Ctrl+R) |
| `Task` | Background task running |
| `Scroll` | Fullscreen scrolling |
| `Settings`, `Tabs`, `Help`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Doctor` | Context-specific UI |

**Keystroke syntax**: modifiers with `+` (`ctrl+k`, `shift+tab`, `meta+p`). Uppercase letter implies Shift (`K` = `shift+k`). Chords: `ctrl+k ctrl+s`. Set action to `null` to unbind.

**Reserved**: `Ctrl+C`, `Ctrl+D`, `Ctrl+M` cannot be rebound.

### Terminal configuration tips

- **Shift+Enter**: works natively in iTerm2, WezTerm, Ghostty, Kitty. Run `/terminal-setup` for VS Code, Alacritty, Zed, Warp. In tmux, enable `set -s extended-keys on`.
- **Option as Meta** (macOS): required for `Alt+B`, `Alt+F`, `Alt+Y`, `Alt+M`, `Alt+P`, `Alt+T`. Configure in iTerm2 (Profiles > Keys > "Esc+"), Terminal.app (Profiles > Keyboard > "Use Option as Meta Key"), or VS Code (`terminal.integrated.macOptionIsMeta`).
- **Notifications**: Kitty and Ghostty work natively. iTerm2: enable "Notification Center Alerts" and "Send escape sequence-generated alerts". In tmux: `set -g allow-passthrough on`.
- **Reduce flicker**: use `/tui fullscreen` for alt-screen rendering.
- **Large inputs**: avoid direct pasting; use file-based workflows instead.

### Built-in tools reference

| Tool | Permission | Description |
| :-- | :-- | :-- |
| `Agent` | No | Spawn subagent with own context |
| `AskUserQuestion` | No | Ask multiple-choice questions |
| `Bash` | Yes | Execute shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Schedule and manage recurring prompts |
| `Edit` | Yes | Targeted file edits |
| `EnterPlanMode` / `ExitPlanMode` | No / Yes | Plan mode entry and exit |
| `EnterWorktree` / `ExitWorktree` | No | Git worktree management |
| `Glob` | No | Pattern-based file search |
| `Grep` | No | Content pattern search |
| `LSP` | No | Code intelligence (definitions, references, type errors) |
| `Monitor` | Yes | Background process watching |
| `NotebookEdit` | Yes | Modify Jupyter cells |
| `PowerShell` | Yes | Native PowerShell commands |
| `Read` | No | Read file contents |
| `Skill` | Yes | Execute a skill |
| `SendMessage` | No | Message agent team teammate |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Manage background tasks |
| `TeamCreate` / `TeamDelete` | No | Agent team lifecycle |
| `TodoWrite` | No | Session task checklist (non-interactive / SDK) |
| `ToolSearch` | No | Search and load deferred tools |
| `WebFetch` | Yes | Fetch URL content |
| `WebSearch` | Yes | Web search |
| `Write` | Yes | Create or overwrite files |

**Bash tool**: each command runs in a separate process. `cd` persists across commands within the project directory. Environment variables do NOT persist. Activate virtualenvs before launching Claude Code.

**Monitor tool** (v2.1.98+): watches background processes (logs, CI jobs, file changes) and feeds output lines back to Claude mid-conversation. Uses Bash permission rules. Not available on Bedrock, Vertex, or Foundry.

**PowerShell tool**: opt-in via `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. Auto-detected on Windows; requires `pwsh` on Linux/macOS. Configurable per hook (`"shell": "powershell"`) and skill (`shell: powershell`).

**LSP tool**: inactive until a code intelligence plugin is installed.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — complete list of CLI commands and flags, system prompt flag details
- [Commands](references/claude-code-commands.md) — full reference for all slash commands available in interactive sessions, including built-in commands and bundled skills
- [Interactive mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, Vim mode, command history, reverse search, background tasks, bash mode, prompt suggestions, side questions, task list, session recap, PR review status
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) — keybindings.json format, all contexts, all available actions with defaults, keystroke syntax, chords, reserved shortcuts, terminal conflicts, vim mode interaction
- [Optimize your terminal setup](references/claude-code-terminal-config.md) — Shift+Enter configuration, Option as Meta, notifications, tmux passthrough, Vim mode, handling large inputs
- [Tools reference](references/claude-code-tools-reference.md) — every built-in tool with permission requirements, Bash/LSP/Monitor/PowerShell tool behavior details

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Optimize your terminal setup: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
