---
name: cli-doc
description: Complete documentation for the Claude Code CLI -- command-line interface reference, built-in commands, interactive mode features, keyboard shortcuts, keybinding customization, terminal configuration, and built-in tools reference. Covers all CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude auto-mode, claude mcp, claude plugin, claude remote-control), all CLI flags (--add-dir, --agent, --agents, --allowedTools, --append-system-prompt, --bare, --betas, --channels, --chrome, --continue, --dangerously-skip-permissions, --debug, --disable-slash-commands, --disallowedTools, --effort, --fallback-model, --fork-session, --from-pr, --ide, --init, --input-format, --json-schema, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --no-session-persistence, --output-format, --enable-auto-mode, --permission-mode, --permission-prompt-tool, --plugin-dir, --print, --remote, --remote-control, --resume, --session-id, --setting-sources, --settings, --strict-mcp-config, --system-prompt, --system-prompt-file, --append-system-prompt-file, --teleport, --teammate-mode, --tmux, --tools, --verbose, --version, --worktree), system prompt flags (--system-prompt, --system-prompt-file, --append-system-prompt, --append-system-prompt-file), all built-in slash commands (/add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /branch, /help, /hooks, /ide, /init, /insights, /install-github-app, /install-slack-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /model, /passes, /permissions, /plan, /plugin, /powerup, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /review, /rewind, /sandbox, /schedule, /security-review, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim, /voice), interactive mode features (keyboard shortcuts, general controls, text editing, multiline input, quick commands, transcript viewer, voice input, command history, reverse search Ctrl+R, background bash commands, bash mode with prefix, prompt suggestions, side questions /btw, task list, PR review status), vim editor mode (mode switching, navigation, editing, text objects), customizable keybindings (keybindings.json, contexts Global/Chat/Autocomplete/Settings/Confirmation/Tabs/Help/Transcript/HistorySearch/Task/ThemePicker/Attachments/Footer/MessageSelector/DiffDialog/ModelPicker/Select/Plugin, all actions by namespace app/history/chat/autocomplete/confirm/permission/transcript/historySearch/task/theme/help/tabs/attachments/footer/messageSelector/diff/modelPicker/select/plugin/settings/voice, keystroke syntax modifiers/uppercase/chords/special keys, unbinding defaults, reserved shortcuts Ctrl+C/Ctrl+D/Ctrl+M, terminal conflicts, vim mode interaction, validation), terminal configuration (themes, line breaks, Shift+Enter setup, Option+Enter setup, notification setup terminal and hooks, tmux passthrough, reduce flicker CLAUDE_CODE_NO_FLICKER, handling large inputs, vim mode), all built-in tools (Agent, AskUserQuestion, Bash, CronCreate, CronDelete, CronList, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, PowerShell, Read, ReadMcpResourceTool, SendMessage, Skill, TaskCreate, TaskGet, TaskList, TaskOutput, TaskStop, TaskUpdate, TeamCreate, TeamDelete, TodoWrite, ToolSearch, WebFetch, WebSearch, Write), tool permission requirements, Bash tool behavior (working directory persistence, environment variable non-persistence, virtualenv/conda activation, CLAUDE_ENV_FILE, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR), LSP tool behavior (type errors, jump to definition, find references, code intelligence plugins), PowerShell tool (CLAUDE_CODE_USE_POWERSHELL_TOOL, shell selection in settings/hooks/skills, preview limitations). Load when discussing Claude Code CLI, command-line flags, slash commands, built-in commands, interactive mode, keyboard shortcuts, keybindings, terminal setup, vim mode, built-in tools, tool permissions, Bash tool, LSP tool, PowerShell tool, system prompt flags, print mode, background tasks, bash mode, prompt suggestions, /btw side questions, task list, PR review status, or any CLI-related topic for Claude Code.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface -- commands, flags, built-in slash commands, interactive mode features, keyboard shortcuts, customizable keybindings, terminal configuration, and the built-in tools reference.

## Quick Reference

### CLI Commands

| Command | Description | Example |
|:--------|:-----------|:--------|
| `claude` | Start interactive session | `claude` |
| `claude "query"` | Start with initial prompt | `claude "explain this project"` |
| `claude -p "query"` | Print mode (non-interactive) | `claude -p "explain this function"` |
| `cat file \| claude -p "query"` | Process piped content | `cat logs.txt \| claude -p "explain"` |
| `claude -c` | Continue most recent conversation | `claude -c` |
| `claude -r "<session>" "query"` | Resume session by ID or name | `claude -r "auth-refactor" "Finish this PR"` |
| `claude update` | Update to latest version | `claude update` |
| `claude auth login` | Sign in (use `--console` for API billing) | `claude auth login --console` |
| `claude auth logout` | Sign out | `claude auth logout` |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) | `claude auth status` |
| `claude agents` | List configured subagents | `claude agents` |
| `claude auto-mode defaults` | Print built-in auto mode rules as JSON | `claude auto-mode defaults > rules.json` |
| `claude mcp` | Configure MCP servers | `claude mcp` |
| `claude plugin` | Manage plugins (alias: `claude plugins`) | `claude plugin install code-review@claude-plugins-official` |
| `claude remote-control` | Start a Remote Control server | `claude remote-control --name "My Project"` |

### Key CLI Flags

| Flag | Description |
|:-----|:-----------|
| `--print`, `-p` | Non-interactive print mode |
| `--continue`, `-c` | Continue most recent conversation |
| `--resume`, `-r` | Resume session by ID or name |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Set effort level (`low`, `medium`, `high`, `max`) |
| `--permission-mode` | Start in a permission mode (`default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`) |
| `--enable-auto-mode` | Unlock auto mode in the Shift+Tab cycle |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, auto memory, CLAUDE.md |
| `--worktree`, `-w` | Start in an isolated git worktree |
| `--tmux` | Create tmux session for the worktree (requires `--worktree`) |
| `--add-dir` | Add additional working directories |
| `--name`, `-n` | Set session display name |
| `--remote` | Create a web session on claude.ai |
| `--remote-control`, `--rc` | Start interactive session with Remote Control enabled |
| `--teleport` | Resume a web session locally |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replace the entire default prompt |
| `--system-prompt-file` | Replace with file contents |
| `--append-system-prompt` | Append to the default prompt |
| `--append-system-prompt-file` | Append file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. The append flags can combine with either replacement flag.

### Print Mode Flags

| Flag | Description |
|:-----|:-----------|
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--input-format` | Input format: `text`, `stream-json` |
| `--json-schema` | Get validated JSON output matching a schema |
| `--max-turns` | Limit agentic turns (error on limit) |
| `--max-budget-usd` | Maximum dollar spend on API calls |
| `--fallback-model` | Auto-fallback model when default is overloaded |
| `--no-session-persistence` | Do not save session to disk |
| `--include-partial-messages` | Include partial streaming events (requires `stream-json`) |
| `--include-hook-events` | Include hook lifecycle events (requires `stream-json`) |

### Tool Control Flags

| Flag | Description |
|:-----|:-----------|
| `--allowedTools` | Tools that execute without permission prompts (pattern matching) |
| `--disallowedTools` | Tools removed from model context entirely |
| `--tools` | Restrict available built-in tools (`""` for none, `"default"` for all, or comma-separated names) |

### Built-in Slash Commands (Selected)

| Command | Purpose |
|:--------|:--------|
| `/clear` | Clear conversation history (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Compact conversation with optional focus |
| `/config` | Open settings interface (alias: `/settings`) |
| `/context` | Visualize current context usage |
| `/copy [N]` | Copy assistant response to clipboard |
| `/cost` | Show token usage statistics |
| `/diff` | Open interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings |
| `/effort [level]` | Set model effort level |
| `/export [filename]` | Export conversation as plain text |
| `/fast [on\|off]` | Toggle fast mode |
| `/branch [name]` | Branch conversation at this point (alias: `/fork`) |
| `/init` | Initialize project with CLAUDE.md |
| `/memory` | Edit CLAUDE.md memory files |
| `/model [model]` | Select or change AI model |
| `/permissions` | Manage tool permission rules (alias: `/allowed-tools`) |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/rename [name]` | Rename current session |
| `/resume [session]` | Resume a conversation (alias: `/continue`) |
| `/rewind` | Rewind conversation and/or code (alias: `/checkpoint`) |
| `/sandbox` | Toggle sandbox mode |
| `/schedule [description]` | Create/manage Cloud scheduled tasks |
| `/security-review` | Analyze branch changes for security vulnerabilities |
| `/skills` | List available skills |
| `/status` | Show version, model, account, connectivity |
| `/vim` | Toggle vim editing mode |
| `/voice` | Toggle push-to-talk voice dictation |

### Interactive Mode Keyboard Shortcuts

**General controls:**

| Shortcut | Description |
|:---------|:-----------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open in external text editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Shift+Tab` / `Alt+M` | Cycle permission modes |
| `Alt+P` | Switch model |
| `Alt+T` | Toggle extended thinking |
| `Alt+O` | Toggle fast mode |
| `Esc Esc` | Rewind or summarize |

**Text editing:**

| Shortcut | Description |
|:---------|:-----------|
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+Y` | Paste deleted text |
| `Alt+Y` | Cycle paste history (after Ctrl+Y) |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

**Multiline input:**

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + `Enter` |
| macOS default | `Option+Enter` |
| Shift+Enter | Works in iTerm2, WezTerm, Ghostty, Kitty; run `/terminal-setup` for others |
| Control sequence | `Ctrl+J` |

**Quick commands:**

| Prefix | Description |
|:-------|:-----------|
| `/` | Slash command or skill |
| `` ` `` | Bash mode (run shell commands directly) |
| `@` | File path autocomplete |

Note: the bash mode prefix is the exclamation mark character.

### Customizable Keybindings

Config file: `~/.claude/keybindings.json` (open with `/keybindings`). Changes auto-apply without restart.

**Contexts:** Global, Chat, Autocomplete, Settings, Confirmation, Tabs, Help, Transcript, HistorySearch, Task, ThemePicker, Attachments, Footer, MessageSelector, DiffDialog, ModelPicker, Select, Plugin

**Key Chat actions:**

| Action | Default | Description |
|:-------|:--------|:-----------|
| `chat:submit` | Enter | Submit message |
| `chat:newline` | (unbound) | Insert newline without submitting |
| `chat:cycleMode` | Shift+Tab | Cycle permission modes |
| `chat:modelPicker` | Cmd+P / Meta+P | Open model picker |
| `chat:externalEditor` | Ctrl+G, Ctrl+X Ctrl+E | Open in external editor |
| `chat:imagePaste` | Ctrl+V | Paste image |
| `chat:stash` | Ctrl+S | Stash current prompt |

**Keystroke syntax:** Modifiers with `+` separator (`ctrl+k`, `shift+tab`, `meta+p`). Chords as space-separated sequences (`ctrl+k ctrl+s`). Uppercase letter implies Shift (e.g., `K` = `shift+k`). Set action to `null` to unbind.

**Reserved shortcuts (cannot rebind):** Ctrl+C, Ctrl+D, Ctrl+M

### Built-in Tools

| Tool | Description | Permission |
|:-----|:-----------|:-----------|
| `Agent` | Spawn a subagent with its own context | No |
| `AskUserQuestion` | Ask multiple-choice questions | No |
| `Bash` | Execute shell commands | Yes |
| `CronCreate` | Schedule recurring prompts (session-scoped) | No |
| `CronDelete` | Cancel a scheduled task | No |
| `CronList` | List scheduled tasks | No |
| `Edit` | Targeted file edits | Yes |
| `EnterPlanMode` | Switch to plan mode | No |
| `EnterWorktree` | Create and enter git worktree | No |
| `ExitPlanMode` | Present plan and exit plan mode | Yes |
| `ExitWorktree` | Exit worktree, return to original dir | No |
| `Glob` | Find files by pattern | No |
| `Grep` | Search file contents by pattern | No |
| `ListMcpResourcesTool` | List MCP server resources | No |
| `LSP` | Code intelligence (definitions, references, type errors) | No |
| `NotebookEdit` | Modify Jupyter notebook cells | Yes |
| `PowerShell` | Execute PowerShell on Windows (opt-in preview) | Yes |
| `Read` | Read file contents | No |
| `ReadMcpResourceTool` | Read a specific MCP resource by URI | No |
| `SendMessage` | Message agent team teammate or resume subagent | No |
| `Skill` | Execute a skill in the main conversation | Yes |
| `TaskCreate` | Create a task in the task list | No |
| `TaskGet` | Get full details for a task | No |
| `TaskList` | List all tasks with status | No |
| `TaskOutput` | (Deprecated) Retrieve background task output; prefer `Read` | No |
| `TaskStop` | Kill a running background task | No |
| `TaskUpdate` | Update task status, dependencies, or delete | No |
| `TeamCreate` | Create an agent team (experimental) | No |
| `TeamDelete` | Disband an agent team | No |
| `TodoWrite` | Manage session task checklist (non-interactive/SDK) | No |
| `ToolSearch` | Search and load deferred tools | No |
| `WebFetch` | Fetch content from a URL | Yes |
| `WebSearch` | Perform web searches | Yes |
| `Write` | Create or overwrite files | Yes |

### Bash Tool Behavior

- Each command runs in a separate process
- Working directory persists across commands
- Environment variables do not persist (use `CLAUDE_ENV_FILE` or a SessionStart hook)
- Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to reset to project dir after each command
- Activate virtualenv/conda before launching Claude Code

### LSP Tool Behavior

Provides code intelligence from a running language server: jump to definition, find references, type info, symbol lists, implementations, call hierarchies. Auto-reports type errors after each file edit. Requires a code intelligence plugin for your language.

### PowerShell Tool (Windows, Opt-in Preview)

Enable with `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. Auto-detects `pwsh.exe` (7+) with fallback to `powershell.exe` (5.1). Bash tool remains alongside. Additional settings: `"defaultShell": "powershell"` for interactive commands, `"shell": "powershell"` on individual hooks, `shell: powershell` in skill frontmatter.

**Preview limitations:** No auto mode support, no profile loading, no sandboxing, native Windows only (not WSL), Git Bash still required to start Claude Code.

### Terminal Configuration

**Line breaks:** `\` + Enter (any terminal), Ctrl+J (any terminal), Shift+Enter (iTerm2/WezTerm/Ghostty/Kitty natively; `/terminal-setup` for others), Option+Enter (macOS with Option as Meta)

**Notifications:** Kitty and Ghostty support desktop notifications natively. iTerm2 requires enabling Notification Center Alerts and escape sequence alerts. For tmux, set `set -g allow-passthrough on`. Other terminals need notification hooks.

**Reduce flicker:** Set `CLAUDE_CODE_NO_FLICKER=1` for fullscreen rendering (flat memory, mouse support).

**Option as Meta (macOS):**
- iTerm2: Settings > Profiles > Keys > Left/Right Option key to "Esc+"
- Terminal.app: Settings > Profiles > Keyboard > "Use Option as Meta Key"
- VS Code: `"terminal.integrated.macOptionIsMeta": true`

### Vim Mode

Enable with `/vim` or `/config`. Set `"editorMode": "vim"` in `~/.claude.json` to persist.

**Supported:** Mode switching (Esc, i/I, a/A, o/O), navigation (h/j/k/l, w/e/b, 0/$, gg/G, f/F/t/T with ;/, repeat), editing (x, d/c/y with motions, p/P, >>/<<, J, . repeat), text objects (iw/aw, iW/aW, i"/a", i'/a', i(/a(, i[/a[, i{/a{).

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) -- All CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude auto-mode, claude mcp, claude plugin, claude remote-control), all CLI flags (--add-dir through --worktree), system prompt flags (--system-prompt, --system-prompt-file, --append-system-prompt, --append-system-prompt-file)
- [Built-in Commands](references/claude-code-commands.md) -- Complete list of slash commands available in interactive mode (/add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /branch, /help, /hooks, /ide, /init, /insights, /install-github-app, /install-slack-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /model, /passes, /permissions, /plan, /plugin, /powerup, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /review, /rewind, /sandbox, /schedule, /security-review, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim, /voice), MCP prompts
- [Interactive Mode](references/claude-code-interactive-mode.md) -- Keyboard shortcuts (general controls, text editing, multiline input, quick commands, transcript viewer, voice input), vim editor mode (mode switching, navigation, editing, text objects), command history and reverse search (Ctrl+R), background bash commands, bash mode with prefix, prompt suggestions, side questions (/btw), task list, PR review status
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) -- Keybindings configuration file (bindings array, contexts, actions), all available actions by namespace (app, history, chat, autocomplete, confirm, permission, transcript, historySearch, task, theme, help, tabs, attachments, footer, messageSelector, diff, modelPicker, select, plugin, settings, voice), keystroke syntax (modifiers, uppercase, chords, special keys), unbinding defaults, reserved shortcuts, terminal conflicts, vim mode interaction, validation
- [Optimize Your Terminal Setup](references/claude-code-terminal-config.md) -- Themes, line breaks (Shift+Enter, Option+Enter, Ctrl+J), notification setup (terminal and hooks, tmux passthrough), reduce flicker (CLAUDE_CODE_NO_FLICKER), handling large inputs, vim mode configuration
- [Tools Reference](references/claude-code-tools-reference.md) -- All built-in tools with permission requirements, Bash tool behavior (working directory persistence, environment variables, CLAUDE_ENV_FILE), LSP tool behavior (code intelligence, auto error reporting), PowerShell tool (opt-in preview, CLAUDE_CODE_USE_POWERSHELL_TOOL, shell selection, limitations)

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Built-in Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Optimize Your Terminal Setup: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
