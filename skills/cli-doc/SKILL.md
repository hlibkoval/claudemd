---
name: cli-doc
description: Complete documentation for Claude Code CLI and interactive features -- CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude mcp, claude plugin, claude remote-control), CLI flags (--model, --print, --continue, --resume, --bare, --permission-mode, --system-prompt, --append-system-prompt, --allowedTools, --disallowedTools, --tools, --json-schema, --max-turns, --max-budget-usd, --output-format, --input-format, --worktree, --add-dir, --agent, --agents, --effort, --mcp-config, --chrome, --remote, --remote-control, --teleport, --tmux, --agent-teams), built-in slash commands (/clear, /compact, /config, /cost, /diff, /effort, /export, /model, /permissions, /plan, /resume, /rewind, /vim, /btw, /schedule, /remote-control, /plugin, /agents, /hooks, /memory, /init, /pr-comments, /branch), interactive mode (keyboard shortcuts, Ctrl+C, Ctrl+B, Ctrl+O, Ctrl+R, Ctrl+T, Shift+Tab, multiline input, Shift+Enter, bash mode with prefix, prompt suggestions, /btw side questions, task list, PR review status, command history, reverse search, vim mode), keybindings customization (~/.claude/keybindings.json, contexts, actions, keystroke syntax, chords, unbinding, reserved shortcuts), terminal configuration (line breaks, notification setup, Shift+Enter setup, /terminal-setup, Option as Meta, vim mode, reduce flicker), and tools reference (Agent, Bash, Edit, Read, Write, Glob, Grep, WebFetch, WebSearch, Skill, LSP, NotebookEdit, PowerShell, SendMessage, TeamCreate, TeamDelete, TodoWrite, ToolSearch, CronCreate, EnterPlanMode, EnterWorktree, TaskCreate/Update/List/Get/Stop, permission requirements, Bash tool behavior, LSP tool behavior, PowerShell tool preview). Load when discussing CLI usage, flags, commands, interactive shortcuts, keybindings, terminal setup, tools, slash commands, vim mode, multiline input, bash mode, background tasks, prompt suggestions, or any Claude Code interface and tool topic.
user-invocable: false
---

# CLI & Interactive Mode Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, built-in commands, interactive mode features, keybinding customization, terminal configuration, and built-in tools.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:-----------|
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive), then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "session" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (`--email`, `--sso`, `--console` flags) |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List configured subagents |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins (alias: `claude plugins`) |
| `claude remote-control` | Start Remote Control server |

### Key CLI Flags

| Flag | Description |
|:-----|:-----------|
| `--print`, `-p` | Non-interactive print mode |
| `--continue`, `-c` | Continue most recent conversation |
| `--resume`, `-r` | Resume session by ID or name |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `max` |
| `--permission-mode` | Start in a mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--bare` | Minimal mode, skip auto-discovery for faster startup |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--allowedTools` | Tools that execute without permission prompts |
| `--disallowedTools` | Tools removed from model context |
| `--tools` | Restrict which built-in tools are available |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Spending cap (print mode only) |
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--input-format` | Input format: `text`, `stream-json` |
| `--json-schema` | Get validated JSON output matching a schema |
| `--mcp-config` | Load MCP servers from JSON file(s) |
| `--add-dir` | Add additional working directories |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--tmux` | Create tmux session for worktree |
| `--agent` | Specify agent for session |
| `--agents` | Define custom subagents via JSON |
| `--agent-teams` | Enable experimental agent teams |
| `--chrome` / `--no-chrome` | Enable/disable Chrome browser integration |
| `--remote` | Create web session on claude.ai |
| `--remote-control`, `--rc` | Start session with Remote Control enabled |
| `--teleport` | Resume web session in local terminal |
| `--name`, `-n` | Set session display name |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a GitHub PR |
| `--verbose` | Enable verbose logging |
| `--debug` | Enable debug mode with optional category filter |
| `--plugin-dir` | Load plugins from a directory |
| `--settings` | Load additional settings from file or JSON string |
| `--fallback-model` | Auto-fallback model when default is overloaded |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either.

### Built-in Slash Commands (Selected)

| Command | Purpose |
|:--------|:--------|
| `/clear` | Clear conversation history (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Compact conversation with optional focus |
| `/config` | Open settings interface (alias: `/settings`) |
| `/context` | Visualize context usage as colored grid |
| `/copy [N]` | Copy assistant response to clipboard |
| `/cost` | Show token usage statistics |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/effort [level]` | Set model effort (`low`/`medium`/`high`/`max`/`auto`) |
| `/export [filename]` | Export conversation as plain text |
| `/fast [on\|off]` | Toggle fast mode |
| `/branch [name]` | Branch conversation (alias: `/fork`) |
| `/model [model]` | Change AI model |
| `/permissions` | View/update permissions (alias: `/allowed-tools`) |
| `/plan [description]` | Enter plan mode |
| `/resume [session]` | Resume conversation (alias: `/continue`) |
| `/rewind` | Rewind conversation/code (alias: `/checkpoint`) |
| `/vim` | Toggle vim editing mode |
| `/btw <question>` | Side question without adding to conversation |
| `/add-dir <path>` | Add working directory for session |
| `/agents` | Manage agent configurations |
| `/chrome` | Configure Chrome settings |
| `/hooks` | View hook configurations |
| `/init` | Initialize project with CLAUDE.md |
| `/memory` | Edit CLAUDE.md memory files |
| `/mcp` | Manage MCP connections |
| `/plugin` | Manage plugins |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/schedule [description]` | Manage Cloud scheduled tasks |
| `/remote-control` | Enable remote control (alias: `/rc`) |
| `/rename [name]` | Rename session |
| `/sandbox` | Toggle sandbox mode |
| `/security-review` | Analyze branch changes for security issues |
| `/skills` | List available skills |
| `/voice` | Toggle push-to-talk voice dictation |

### Keyboard Shortcuts (Interactive Mode)

**General controls:**

| Shortcut | Description |
|:---------|:-----------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+L` | Clear terminal screen |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+T` | Toggle task list |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open in external text editor |
| `Ctrl+V` / `Cmd+V` / `Alt+V` | Paste image from clipboard |
| `Shift+Tab` / `Alt+M` | Cycle permission modes |
| `Alt+P` | Switch model |
| `Alt+T` | Toggle extended thinking |
| `Alt+O` | Toggle fast mode |
| `Esc` + `Esc` | Rewind or summarize |

**Multiline input:**

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + `Enter` |
| macOS default | `Option+Enter` |
| Shift+Enter | Works natively in iTerm2, WezTerm, Ghostty, Kitty |
| Line feed | `Ctrl+J` |

**Quick commands:** `/` for commands/skills, `!` for bash mode, `@` for file path mention.

**Text editing:** `Ctrl+K` (delete to EOL), `Ctrl+U` (delete to start), `Ctrl+Y` (paste deleted), `Alt+B`/`Alt+F` (word navigation).

### Keybindings Customization

Configuration file: `~/.claude/keybindings.json` (open with `/keybindings`). Changes auto-detected without restart.

**Contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`.

**Key actions by context:**

| Context | Actions |
|:--------|:--------|
| Global | `app:interrupt` (Ctrl+C), `app:exit` (Ctrl+D), `app:toggleTodos` (Ctrl+T), `app:toggleTranscript` (Ctrl+O) |
| Chat | `chat:submit` (Enter), `chat:cancel` (Esc), `chat:cycleMode` (Shift+Tab), `chat:modelPicker` (Cmd/Meta+P), `chat:fastMode` (Meta+O), `chat:thinkingToggle` (Cmd/Meta+T), `chat:externalEditor` (Ctrl+G), `chat:imagePaste` (Ctrl+V), `chat:newline` (unbound) |
| Confirmation | `confirm:yes` (Y/Enter), `confirm:no` (N/Esc), `confirm:cycleMode` (Shift+Tab) |

**Keystroke syntax:** Modifiers with `+` (`ctrl+k`, `shift+tab`, `meta+p`). Chords with space (`ctrl+k ctrl+s`). Uppercase letter implies Shift (standalone only). Set action to `null` to unbind.

**Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`.

### Terminal Configuration

**Shift+Enter setup:** Run `/terminal-setup` for VS Code, Alacritty, Zed, Warp. Works natively in iTerm2, WezTerm, Ghostty, Kitty.

**Option as Meta (macOS):** iTerm2: Profiles > Keys > "Esc+". Terminal.app: Profiles > Keyboard > "Use Option as Meta Key". VS Code: `terminal.integrated.macOptionIsMeta: true`.

**Notifications:** Kitty and Ghostty support desktop notifications natively. iTerm2: enable Notification Center Alerts + "Send escape sequence-generated alerts". tmux: set `allow-passthrough on`. Other terminals: use notification hooks.

**Reduce flicker:** Set `CLAUDE_CODE_NO_FLICKER=1` for fullscreen rendering.

### Built-in Tools Reference

| Tool | Permission | Description |
|:-----|:-----------|:-----------|
| `Agent` | No | Spawn subagent with own context window |
| `AskUserQuestion` | No | Ask multiple-choice questions |
| `Bash` | Yes | Execute shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Schedule/manage recurring prompts in session |
| `Edit` | Yes | Make targeted file edits |
| `EnterPlanMode` | No | Switch to plan mode |
| `ExitPlanMode` | Yes | Present plan and exit plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Manage git worktree sessions |
| `Glob` | No | Find files by pattern |
| `Grep` | No | Search file contents |
| `ListMcpResourcesTool` / `ReadMcpResourceTool` | No | List/read MCP resources |
| `LSP` | No | Code intelligence (definitions, references, errors) |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `PowerShell` | Yes | Execute PowerShell on Windows (opt-in preview) |
| `Read` | No | Read file contents |
| `SendMessage` | No | Message agent team teammate or resume subagent |
| `Skill` | Yes | Execute a skill |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Manage background tasks |
| `TeamCreate` / `TeamDelete` | No | Create/disband agent teams |
| `TodoWrite` | No | Manage task checklist (non-interactive/SDK mode) |
| `ToolSearch` | No | Search and load deferred tools |
| `WebFetch` | Yes | Fetch content from URL |
| `WebSearch` | Yes | Perform web searches |
| `Write` | Yes | Create or overwrite files |

**Bash tool behavior:** Each command runs in a separate process. Working directory persists; environment variables do not. Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to reset cwd after each command. Use `CLAUDE_ENV_FILE` for persistent env vars.

**LSP tool:** Provides jump-to-definition, find-references, type info, symbol listing, call hierarchies. Requires a code intelligence plugin for your language.

**PowerShell tool (Windows, opt-in):** Enable with `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. Auto-detects `pwsh.exe` (7+) or `powershell.exe` (5.1). Bash tool remains available alongside. Preview limitations: no auto mode, no profiles, no sandboxing, native Windows only.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) -- All CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude mcp, claude plugin, claude remote-control) and flags (--model, --print, --bare, --permission-mode, --system-prompt, --append-system-prompt, --allowedTools, --disallowedTools, --tools, --json-schema, --max-turns, --max-budget-usd, --output-format, --worktree, --agent, --agents, --effort, --mcp-config, --chrome, --remote, --teleport, --tmux, --agent-teams), system prompt flag combinations
- [Built-in Commands](references/claude-code-commands.md) -- Complete list of slash commands (/clear, /compact, /config, /cost, /diff, /effort, /export, /model, /permissions, /plan, /resume, /rewind, /vim, /btw, /schedule, /branch, /plugin, /agents, /hooks, /memory, /init, /pr-comments, /remote-control, /security-review, /skills, /voice, and more), MCP prompts
- [Interactive Mode](references/claude-code-interactive-mode.md) -- Keyboard shortcuts, multiline input methods, vim editor mode (navigation, editing, text objects), command history and reverse search, background bash commands, bash mode with prefix, prompt suggestions, /btw side questions, task list, PR review status
- [Keybindings](references/claude-code-keybindings.md) -- Customizable keyboard shortcuts via ~/.claude/keybindings.json, all contexts (Global, Chat, Autocomplete, Confirmation, Transcript, etc.), all available actions by namespace, keystroke syntax (modifiers, chords, uppercase), unbinding defaults, reserved shortcuts, terminal conflicts, vim mode interaction
- [Terminal Configuration](references/claude-code-terminal-config.md) -- Shift+Enter setup, Option as Meta configuration for macOS terminals, notification setup (terminal and hooks), tmux passthrough, reduce flicker with CLAUDE_CODE_NO_FLICKER, vim mode configuration, handling large inputs
- [Tools Reference](references/claude-code-tools-reference.md) -- All built-in tools with permission requirements, Bash tool persistence behavior, LSP tool capabilities and setup, PowerShell tool (opt-in Windows preview with enable/config/limitations), checking available tools at runtime

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Built-in Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
