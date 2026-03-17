---
name: cli-doc
description: Complete documentation for the Claude Code CLI and interactive terminal -- CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude mcp, claude remote-control), CLI flags (--add-dir, --agent, --agents, --allowedTools, --append-system-prompt, --chrome, --continue, --dangerously-skip-permissions, --debug, --disallowedTools, --effort, --fallback-model, --fork-session, --from-pr, --ide, --init, --input-format, --json-schema, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --no-chrome, --no-session-persistence, --output-format, --permission-mode, --permission-prompt-tool, --plugin-dir, --print, --remote, --remote-control, --resume, --session-id, --setting-sources, --settings, --strict-mcp-config, --system-prompt, --system-prompt-file, --append-system-prompt-file, --teleport, --teammate-mode, --tools, --verbose, --version, --worktree), system prompt flags, built-in commands (/add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /fork, /help, /hooks, /ide, /init, /insights, /install-github-app, /install-slack-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /model, /passes, /permissions, /plan, /plugin, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /review, /rewind, /sandbox, /security-review, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim), interactive mode (keyboard shortcuts, text editing, multiline input, quick commands, vim mode, command history, Ctrl+R reverse search, background bash commands, bash mode with exclamation prefix, prompt suggestions, /btw side questions, task list, PR review status), keybindings customization (keybindings.json, contexts, actions, keystroke syntax, modifiers, chords, special keys, unbinding, reserved shortcuts, terminal conflicts, vim mode interaction, validation), terminal configuration (themes, line breaks, Shift+Enter setup, Option+Enter, notification setup, handling large inputs, vim mode), tools reference (Agent, AskUserQuestion, Bash, CronCreate, CronDelete, CronList, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, Read, ReadMcpResourceTool, Skill, TaskCreate, TaskGet, TaskList, TaskOutput, TaskStop, TaskUpdate, TodoWrite, ToolSearch, WebFetch, WebSearch, Write, permission requirements, Bash tool behavior). Load when discussing CLI flags, CLI commands, claude command-line options, built-in commands, slash commands reference, interactive mode, keyboard shortcuts, keybindings, vim mode, terminal configuration, terminal setup, Shift+Enter, line breaks, tools reference, tool permissions, Bash tool, background tasks, prompt suggestions, /btw, side questions, task list, PR review status, system prompt flags, --print mode, --output-format, --model, --effort, --worktree, --remote, --mcp-config, --tools, --allowedTools, --disallowedTools, keybindings.json, notification setup, or bash mode.
user-invocable: false
---

# CLI & Interactive Mode Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, built-in commands, interactive mode features, keybinding customization, terminal configuration, and tools reference.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive, then exit) |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r <session> "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (`--email`, `--sso` flags available) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List configured subagents |
| `claude mcp` | Configure MCP servers |
| `claude remote-control` | Start Remote Control server |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `--print`, `-p` | Non-interactive print mode |
| `--continue`, `-c` | Continue most recent conversation |
| `--resume`, `-r` | Resume specific session by ID or name |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Effort level: `low`, `medium`, `high`, `max` (Opus 4.6 only) |
| `--worktree`, `-w` | Start in an isolated git worktree |
| `--add-dir` | Add additional working directories |
| `--agent` | Specify an agent for the session |
| `--agents` | Define custom subagents via JSON |
| `--tools` | Restrict available tools (`""` for none, `"default"` for all, or tool names) |
| `--allowedTools` | Tools that skip permission prompts |
| `--disallowedTools` | Tools removed from context entirely |
| `--mcp-config` | Load MCP servers from JSON files |
| `--strict-mcp-config` | Only use MCP from `--mcp-config`, ignore other configs |
| `--output-format` | Print mode output: `text`, `json`, `stream-json` |
| `--input-format` | Print mode input: `text`, `stream-json` |
| `--json-schema` | Validated JSON output matching a schema (print mode) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Spending cap for API calls (print mode) |
| `--fallback-model` | Fallback model when default is overloaded (print mode) |
| `--permission-mode` | Start in a permission mode (`plan`, etc.) |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--name`, `-n` | Set session display name |
| `--from-pr` | Resume sessions linked to a GitHub PR |
| `--fork-session` | Fork when resuming instead of reusing session |
| `--remote` | Start a web session on claude.ai |
| `--remote-control`, `--rc` | Interactive session with Remote Control enabled |
| `--teleport` | Resume a web session locally |
| `--chrome` / `--no-chrome` | Enable/disable Chrome integration |
| `--ide` | Auto-connect to IDE on startup |
| `--plugin-dir` | Load plugins from a directory |
| `--debug` | Debug mode with optional category filter |
| `--verbose` | Verbose logging (full turn-by-turn output) |
| `--version`, `-v` | Show version |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replace entire default prompt |
| `--system-prompt-file` | Replace with file contents |
| `--append-system-prompt` | Append to default prompt |
| `--append-system-prompt-file` | Append file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag. For most use cases, prefer append flags to preserve built-in capabilities.

### Built-in Commands (Selection)

| Command | Purpose |
|:--------|:--------|
| `/clear` | Clear conversation history (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Compact conversation with optional focus |
| `/config` | Open Settings interface (alias: `/settings`) |
| `/context` | Visualize context usage as a colored grid |
| `/cost` | Show token usage statistics |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/effort [level]` | Set effort level (`low`/`medium`/`high`/`max`/`auto`) |
| `/export [filename]` | Export conversation as plain text |
| `/fork [name]` | Fork the current conversation |
| `/model [model]` | Switch AI model |
| `/memory` | Edit CLAUDE.md files, toggle auto memory |
| `/permissions` | View or update permissions (alias: `/allowed-tools`) |
| `/plan` | Enter plan mode |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/rename [name]` | Rename current session |
| `/resume [session]` | Resume a conversation (alias: `/continue`) |
| `/rewind` | Rewind conversation/code to a previous point (alias: `/checkpoint`) |
| `/skills` | List available skills |
| `/vim` | Toggle between Vim and Normal editing modes |
| `/btw <question>` | Side question without adding to conversation |

Type `/` to see all commands. Some commands depend on platform, plan, or environment. Bundled skills like `/simplify`, `/batch`, `/debug` also appear in the `/` menu.

### Keyboard Shortcuts (Interactive Mode)

**General controls:**

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` | Open prompt in external text editor |
| `Ctrl+L` | Clear terminal screen (keeps history) |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+F` | Kill all background agents (press twice to confirm) |
| `Shift+Tab` | Toggle permission modes |
| `Alt+P` | Switch model |
| `Alt+T` | Toggle extended thinking |
| `Esc Esc` | Rewind or summarize |

**Multiline input:**

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + `Enter` (all terminals) |
| macOS default | `Option+Enter` |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty; run `/terminal-setup` for others |
| Control sequence | `Ctrl+J` |

**Quick commands:** `/` for commands/skills, `!` for bash mode, `@` for file path mention.

### Keybindings Customization

Configure via `/keybindings` which creates `~/.claude/keybindings.json`. Changes auto-reload without restart.

**Contexts:** Global, Chat, Autocomplete, Settings, Confirmation, Tabs, Help, Transcript, HistorySearch, Task, ThemePicker, Attachments, Footer, MessageSelector, DiffDialog, ModelPicker, Select, Plugin.

**Keystroke syntax:** modifiers with `+` separator (`ctrl`, `alt`/`opt`, `shift`, `meta`/`cmd`). Chords use spaces (`ctrl+k ctrl+s`). Uppercase letter implies Shift (e.g., `K` = `shift+k`).

**Reserved (cannot rebind):** `Ctrl+C` (interrupt), `Ctrl+D` (exit).

**Unbind:** set action to `null` in the keybindings file.

### Terminal Configuration

- **Line breaks**: `\` + Enter (universal), Shift+Enter (native in iTerm2/WezTerm/Ghostty/Kitty; `/terminal-setup` for VS Code/Alacritty/Zed/Warp), Option+Enter (macOS with Option as Meta)
- **Notifications**: Native in Kitty, Ghostty. iTerm2 needs Settings > Profiles > Terminal > Notification Center Alerts. Others: use notification hooks
- **Vim mode**: enable with `/vim` or `/config`. Supports mode switching, navigation (h/j/k/l, w/e/b, 0/$, gg/G, f/F/t/T), editing (x, d, c, y, p, >>, <<, J, .), text objects (iw/aw, iW/aW, i"/a", etc.)
- **Large inputs**: avoid direct paste; use file-based workflows

### Tools Reference

| Tool | Permission | Description |
|:-----|:-----------|:------------|
| `Agent` | No | Spawn a subagent with its own context |
| `AskUserQuestion` | No | Ask multiple-choice questions |
| `Bash` | Yes | Execute shell commands |
| `CronCreate` | No | Schedule recurring/one-shot prompts |
| `CronDelete` | No | Cancel a scheduled task |
| `CronList` | No | List scheduled tasks |
| `Edit` | Yes | Targeted file edits |
| `EnterPlanMode` | No | Switch to plan mode |
| `EnterWorktree` | No | Create/switch to git worktree |
| `ExitPlanMode` | Yes | Present plan and exit plan mode |
| `ExitWorktree` | No | Exit worktree session |
| `Glob` | No | Find files by pattern |
| `Grep` | No | Search file contents |
| `ListMcpResourcesTool` | No | List MCP resources |
| `LSP` | No | Code intelligence (type errors, navigation, symbols) |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `Read` | No | Read file contents |
| `ReadMcpResourceTool` | No | Read MCP resource by URI |
| `Skill` | Yes | Execute a skill |
| `TaskCreate` | No | Create a task in the task list |
| `TaskGet` | No | Get task details |
| `TaskList` | No | List all tasks |
| `TaskOutput` | No | Get background task output |
| `TaskStop` | No | Kill a background task |
| `TaskUpdate` | No | Update task status/details |
| `TodoWrite` | No | Manage task checklist (non-interactive/SDK) |
| `ToolSearch` | No | Search deferred tools |
| `WebFetch` | Yes | Fetch URL content |
| `WebSearch` | Yes | Perform web searches |
| `Write` | Yes | Create or overwrite files |

**Bash tool behavior:** each command runs in a separate process. Working directory persists across commands. Environment variables do not persist. Activate virtualenvs before launching Claude Code. Use `CLAUDE_ENV_FILE` or a SessionStart hook for persistent env vars.

### Background Tasks & Bash Mode

- **Background tasks**: press `Ctrl+B` during a running command, or ask Claude to run in background. Output retrieved via `TaskOutput`. Auto-cleaned on exit. Disable with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`
- **Bash mode** (`!` prefix): runs shell commands directly without Claude interpretation. Adds output to conversation context. Supports Tab autocomplete from previous `!` commands. Exit with Escape, Backspace, or `Ctrl+U` on empty prompt

### Prompt Suggestions

After Claude responds, grayed-out follow-up suggestions appear based on conversation history and recent git activity. Press Tab to accept or Enter to accept and submit. Disable with `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false` or via `/config`.

### Task List

Claude creates task lists for multi-step work. Toggle with `Ctrl+T`. Shows up to 10 tasks. Persists across compactions. Share across sessions with `CLAUDE_CODE_TASK_LIST_ID=name`.

### PR Review Status

When a branch has an open PR, a clickable link appears in the footer with colored underline: green (approved), yellow (pending), red (changes requested), gray (draft), purple (merged). Requires `gh` CLI.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) -- CLI commands (start session, print mode, piped input, continue, resume, update, auth login/logout/status, agents, mcp, remote-control), complete CLI flags table (--add-dir, --agent, --agents, --allow-dangerously-skip-permissions, --allowedTools, --append-system-prompt, --append-system-prompt-file, --betas, --chrome, --continue, --dangerously-skip-permissions, --debug, --disable-slash-commands, --disallowedTools, --effort, --fallback-model, --fork-session, --from-pr, --ide, --init, --init-only, --include-partial-messages, --input-format, --json-schema, --maintenance, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --no-chrome, --no-session-persistence, --output-format, --permission-mode, --permission-prompt-tool, --plugin-dir, --print, --remote, --remote-control, --resume, --session-id, --setting-sources, --settings, --strict-mcp-config, --system-prompt, --system-prompt-file, --teleport, --teammate-mode, --tools, --verbose, --version, --worktree), system prompt flags (replace vs append, mutual exclusivity)
- [Built-in commands](references/claude-code-commands.md) -- complete list of slash commands (/add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /fork, /help, /hooks, /ide, /init, /insights, /install-github-app, /install-slack-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /model, /passes, /permissions, /plan, /plugin, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /review, /rewind, /sandbox, /security-review, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim), MCP prompts
- [Interactive mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts (general controls, text editing, theme/display, multiline input, quick commands), built-in commands overview, vim editor mode (mode switching, navigation, editing, text objects), command history (reverse search with Ctrl+R), background bash commands (backgrounding, Ctrl+B, bash mode with exclamation prefix, Tab autocomplete), prompt suggestions (configuration, cost), side questions with /btw, task list (Ctrl+T toggle, CLAUDE_CODE_TASK_LIST_ID), PR review status
- [Keybindings customization](references/claude-code-keybindings.md) -- keybindings.json structure, contexts (Global, Chat, Autocomplete, Settings, Confirmation, Tabs, Help, Transcript, HistorySearch, Task, ThemePicker, Attachments, Footer, MessageSelector, DiffDialog, ModelPicker, Select, Plugin), complete actions reference (app, history, chat, autocomplete, confirmation, permission, transcript, historySearch, task, theme, help, tabs, attachments, footer, messageSelector, diff, modelPicker, select, plugin, settings actions), keystroke syntax (modifiers, uppercase letters, chords, special keys), unbinding defaults, reserved shortcuts, terminal conflicts, vim mode interaction, validation
- [Terminal configuration](references/claude-code-terminal-config.md) -- themes and appearance, line breaks (quick escape, Shift+Enter, Option+Enter setup for Terminal.app/iTerm2/VS Code), /terminal-setup command, notification setup (terminal notifications for Kitty/Ghostty/iTerm2, notification hooks), handling large inputs, vim mode overview
- [Tools reference](references/claude-code-tools-reference.md) -- complete tool list with permission requirements (Agent, AskUserQuestion, Bash, CronCreate, CronDelete, CronList, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, Read, ReadMcpResourceTool, Skill, TaskCreate, TaskGet, TaskList, TaskOutput, TaskStop, TaskUpdate, TodoWrite, ToolSearch, WebFetch, WebSearch, Write), Bash tool behavior (process isolation, working directory persistence, environment variable handling, CLAUDE_ENV_FILE, SessionStart hook)

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Built-in commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings customization: https://code.claude.com/docs/en/keybindings.md
- Terminal configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
