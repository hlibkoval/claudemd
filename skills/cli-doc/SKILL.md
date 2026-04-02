---
name: cli-doc
description: Complete documentation for the Claude Code command-line interface -- CLI commands and flags, built-in slash commands, interactive mode, keyboard shortcuts, keybindings customization, terminal configuration, and built-in tools reference. Covers launch commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude auto-mode, claude mcp, claude plugin, claude remote-control), CLI flags (--add-dir, --agent, --agents, --allowedTools, --append-system-prompt, --bare, --betas, --channels, --chrome, --continue, --dangerously-skip-permissions, --debug, --disable-slash-commands, --disallowedTools, --effort, --fallback-model, --fork-session, --from-pr, --ide, --init, --include-hook-events, --input-format, --json-schema, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --no-session-persistence, --output-format, --enable-auto-mode, --permission-mode, --permission-prompt-tool, --plugin-dir, --print, --remote, --remote-control, --resume, --session-id, --settings, --system-prompt, --system-prompt-file, --append-system-prompt-file, --strict-mcp-config, --teleport, --teammate-mode, --tmux, --tools, --verbose, --version, --worktree), system prompt flags, built-in slash commands (/add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /branch, /help, /hooks, /ide, /init, /insights, /install-github-app, /keybindings, /login, /mcp, /memory, /model, /passes, /permissions, /plan, /plugin, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /review, /rewind, /sandbox, /schedule, /security-review, /skills, /stats, /status, /statusline, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim, /voice), interactive mode keyboard shortcuts (Ctrl+C, Ctrl+D, Ctrl+G, Ctrl+L, Ctrl+O, Ctrl+R, Ctrl+V, Ctrl+B, Ctrl+T, Shift+Tab, Alt+P, Alt+T, Alt+O), text editing shortcuts (Ctrl+K, Ctrl+U, Ctrl+Y, Alt+Y, Alt+B, Alt+F), multiline input methods (backslash-Enter, Option+Enter, Shift+Enter, Ctrl+J), vim editor mode (navigation, editing, text objects, mode switching), command history and reverse search, background bash commands (Ctrl+B backgrounding), bash mode (prefix with !), prompt suggestions, side questions (/btw), task list (Ctrl+T), PR review status, customizable keybindings (~/.claude/keybindings.json, contexts, actions, keystroke syntax, chords, reserved shortcuts, vim mode interaction), terminal configuration (line breaks, Shift+Enter setup, notification setup, flicker reduction, large inputs, vim mode), built-in tools reference (Agent, AskUserQuestion, Bash, CronCreate, CronDelete, CronList, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, PowerShell, Read, ReadMcpResourceTool, SendMessage, Skill, TaskCreate, TaskGet, TaskList, TaskOutput, TaskStop, TaskUpdate, TeamCreate, TeamDelete, TodoWrite, ToolSearch, WebFetch, WebSearch, Write), Bash tool behavior (working directory persistence, environment variable non-persistence, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR, CLAUDE_ENV_FILE), LSP tool behavior (type errors, jump to definition, find references, code intelligence plugins), PowerShell tool (CLAUDE_CODE_USE_POWERSHELL_TOOL, defaultShell, shell selection for hooks and skills, preview limitations). Load when discussing CLI commands, CLI flags, slash commands, interactive mode, keyboard shortcuts, keybindings, terminal setup, built-in tools, tool permissions, vim mode, bash mode, background tasks, or any Claude Code command-line interface topic.
user-invocable: false
---

# CLI & Interactive Mode Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, built-in commands, interactive mode, keybindings, terminal configuration, and tools reference.

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
| `claude auth login` | Sign in (`--email`, `--sso`, `--console`) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List configured subagents |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins (alias: `claude plugins`) |
| `claude remote-control` | Start a Remote Control server |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `--add-dir` | Add additional working directories |
| `--agent` | Specify an agent for the session |
| `--allowedTools` | Tools that execute without permission prompts |
| `--append-system-prompt` | Append text to default system prompt |
| `--bare` | Minimal mode: skip auto-discovery for faster startup |
| `--chrome` | Enable Chrome browser integration |
| `--continue`, `-c` | Load most recent conversation |
| `--dangerously-skip-permissions` | Skip permission prompts |
| `--debug` | Enable debug mode with category filtering |
| `--disallowedTools` | Tools removed from model context |
| `--effort` | Set effort level: `low`, `medium`, `high`, `max` |
| `--enable-auto-mode` | Unlock auto mode in Shift+Tab cycle |
| `--fallback-model` | Fallback model when default is overloaded (print mode) |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a GitHub PR |
| `--json-schema` | Get validated JSON output matching schema (print mode) |
| `--max-budget-usd` | Maximum spend before stopping (print mode) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--mcp-config` | Load MCP servers from JSON files |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--name`, `-n` | Set session display name |
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--permission-mode` | Start in specific mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--plugin-dir` | Load plugins from a directory |
| `--print`, `-p` | Print response without interactive mode |
| `--remote` | Create a web session on claude.ai |
| `--remote-control`, `--rc` | Start with Remote Control enabled |
| `--resume`, `-r` | Resume a specific session by ID or name |
| `--settings` | Path to settings JSON file |
| `--system-prompt` | Replace entire system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--teleport` | Resume a web session locally |
| `--tools` | Restrict available tools (`""`, `"default"`, `"Bash,Edit,Read"`) |
| `--worktree`, `-w` | Start in an isolated git worktree |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. The append flags can combine with either.

### Built-in Slash Commands (Selected)

| Command | Purpose |
|:--------|:--------|
| `/add-dir <path>` | Add a working directory |
| `/btw <question>` | Side question without adding to history |
| `/clear` | Clear conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Compact conversation with optional focus |
| `/config` | Open settings interface (alias: `/settings`) |
| `/context` | Visualize context usage |
| `/copy [N]` | Copy assistant response to clipboard |
| `/cost` | Show token usage statistics |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings |
| `/effort [level]` | Set model effort level |
| `/export [filename]` | Export conversation as plain text |
| `/fast [on\|off]` | Toggle fast mode |
| `/branch [name]` | Branch the conversation (alias: `/fork`) |
| `/init` | Initialize project with CLAUDE.md |
| `/keybindings` | Open keybindings configuration |
| `/memory` | Edit CLAUDE.md memory files |
| `/model [model]` | Select or change model |
| `/permissions` | Manage tool permission rules (alias: `/allowed-tools`) |
| `/plan [description]` | Enter plan mode |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/rewind` | Rewind conversation/code (alias: `/checkpoint`) |
| `/sandbox` | Toggle sandbox mode |
| `/schedule [description]` | Manage Cloud scheduled tasks |
| `/security-review` | Analyze pending changes for vulnerabilities |
| `/skills` | List available skills |
| `/terminal-setup` | Configure terminal keybindings |
| `/vim` | Toggle Vim editing mode |
| `/voice` | Toggle push-to-talk voice dictation |

### Keyboard Shortcuts (Interactive Mode)

**General controls:**

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open in external text editor |
| `Ctrl+L` | Clear terminal screen |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Shift+Tab` | Cycle permission modes |
| `Alt+P` | Switch model |
| `Alt+T` | Toggle extended thinking |
| `Alt+O` | Toggle fast mode |
| `Esc Esc` | Rewind or summarize |

**Text editing:**

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete to start of line |
| `Ctrl+Y` | Paste deleted text |
| `Alt+Y` | Cycle paste history (after Ctrl+Y) |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

**Multiline input:**

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + Enter |
| macOS default | Option+Enter |
| Shift+Enter | Works natively in iTerm2, WezTerm, Ghostty, Kitty |
| Control sequence | Ctrl+J |

**Quick commands:** `/` for commands/skills, prefix with `!` for bash mode, `@` for file path autocomplete.

### Keybinding Customization

Config file: `~/.claude/keybindings.json` (open with `/keybindings`). Changes auto-detected without restart.

**Contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`

**Key global/chat actions:**

| Action | Default | Description |
|:-------|:--------|:------------|
| `app:interrupt` | Ctrl+C | Cancel current operation |
| `app:exit` | Ctrl+D | Exit Claude Code |
| `app:toggleTodos` | Ctrl+T | Toggle task list |
| `app:toggleTranscript` | Ctrl+O | Toggle verbose transcript |
| `chat:submit` | Enter | Submit message |
| `chat:cycleMode` | Shift+Tab | Cycle permission modes |
| `chat:modelPicker` | Cmd+P / Meta+P | Open model picker |
| `chat:externalEditor` | Ctrl+G, Ctrl+X Ctrl+E | Open in external editor |
| `chat:newline` | (unbound) | Insert newline without submitting |

**Reserved shortcuts** (cannot be rebound): Ctrl+C, Ctrl+D, Ctrl+M.

**Keystroke syntax:** Modifiers: `ctrl`, `alt`/`opt`, `shift`, `meta`/`cmd`. Chords: `ctrl+k ctrl+s`. Uppercase letter implies Shift (e.g., `K` = `shift+k`). Set action to `null` to unbind.

### Built-in Tools

| Tool | Description | Permission |
|:-----|:------------|:-----------|
| `Agent` | Spawns a subagent with its own context | No |
| `AskUserQuestion` | Asks multiple-choice questions | No |
| `Bash` | Executes shell commands | Yes |
| `CronCreate` / `CronDelete` / `CronList` | Session-scoped scheduled tasks | No |
| `Edit` | Targeted file edits | Yes |
| `EnterPlanMode` / `ExitPlanMode` | Design approach before coding | No / Yes |
| `EnterWorktree` / `ExitWorktree` | Isolated git worktree sessions | No |
| `Glob` | Find files by pattern | No |
| `Grep` | Search file contents | No |
| `ListMcpResourcesTool` / `ReadMcpResourceTool` | MCP resource access | No |
| `LSP` | Code intelligence (definitions, references, errors) | No |
| `NotebookEdit` | Modify Jupyter notebook cells | Yes |
| `PowerShell` | PowerShell commands on Windows (opt-in preview) | Yes |
| `Read` | Read file contents | No |
| `SendMessage` | Message agent team teammates | No |
| `Skill` | Execute a skill | Yes |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | Task management | No |
| `TodoWrite` | Session task checklist (non-interactive/SDK) | No |
| `ToolSearch` | Search and load deferred tools | No |
| `WebFetch` / `WebSearch` | Fetch URLs / web search | Yes |
| `Write` | Create or overwrite files | Yes |

**Bash tool behavior:**
- Working directory persists across commands
- Environment variables do not persist between commands
- Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to reset to project dir after each command
- Set `CLAUDE_ENV_FILE` to a shell script for persistent env vars

**LSP tool:** Requires a code intelligence plugin for your language. Provides jump-to-definition, find references, type errors/warnings after edits, symbol listing, call hierarchies.

**PowerShell tool:** Enable with `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. Auto-detects `pwsh.exe` (7+) or `powershell.exe` (5.1). Preview limitations: no auto mode, no profile loading, no sandboxing, Windows-only (not WSL).

### Terminal Configuration

- **Shift+Enter setup:** Run `/terminal-setup` for VS Code, Alacritty, Zed, Warp. Native in iTerm2, WezTerm, Ghostty, Kitty.
- **Option as Meta (macOS):** iTerm2: Profiles > Keys > "Esc+". Terminal.app: Profiles > Keyboard > "Use Option as Meta Key". VS Code: `terminal.integrated.macOptionIsMeta: true`.
- **Notifications:** Kitty and Ghostty work natively. iTerm2: enable "Notification Center Alerts" + "Send escape sequence-generated alerts". Tmux: `set -g allow-passthrough on`. Others: use notification hooks.
- **Reduce flicker:** Set `CLAUDE_CODE_NO_FLICKER=1` for fullscreen rendering.
- **Large inputs:** Avoid direct pasting; use file-based workflows instead.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) -- CLI commands, flags, and system prompt options
- [Built-in Commands](references/claude-code-commands.md) -- Complete list of slash commands available in interactive mode
- [Interactive Mode](references/claude-code-interactive-mode.md) -- Keyboard shortcuts, vim mode, command history, background tasks, bash mode, prompt suggestions, side questions, task list
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) -- Keybindings configuration file, contexts, actions, keystroke syntax, chords, reserved shortcuts
- [Terminal Configuration](references/claude-code-terminal-config.md) -- Line breaks, Shift+Enter setup, notifications, flicker reduction, vim mode
- [Tools Reference](references/claude-code-tools-reference.md) -- Built-in tools, permission requirements, Bash/LSP/PowerShell tool behavior

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Built-in Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
