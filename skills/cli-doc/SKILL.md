---
name: cli-doc
description: Complete documentation for the Claude Code CLI -- covering the CLI reference (all launch commands like claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude auto-mode, claude mcp, claude plugin, claude remote-control, and all CLI flags including --add-dir, --agent, --agents, --allowedTools, --append-system-prompt, --bare, --betas, --channels, --chrome, --continue, --dangerously-skip-permissions, --debug, --disallowedTools, --effort, --fallback-model, --fork-session, --from-pr, --ide, --init, --input-format, --json-schema, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --no-session-persistence, --output-format, --enable-auto-mode, --permission-mode, --permission-prompt-tool, --plugin-dir, --print, --remote, --remote-control, --resume, --session-id, --setting-sources, --settings, --strict-mcp-config, --system-prompt, --system-prompt-file, --append-system-prompt-file, --teleport, --teammate-mode, --tools, --verbose, --version, --worktree, --tmux, system prompt flags), built-in commands (all slash commands /add-dir /agents /btw /chrome /clear /color /compact /config /context /copy /cost /desktop /diff /doctor /effort /exit /export /extra-usage /fast /feedback /branch /help /hooks /ide /init /insights /install-github-app /install-slack-app /keybindings /login /logout /mcp /memory /mobile /model /passes /permissions /plan /plugin /pr-comments /privacy-settings /release-notes /reload-plugins /remote-control /remote-env /rename /resume /rewind /sandbox /schedule /security-review /skills /stats /status /statusline /stickers /tasks /terminal-setup /theme /upgrade /usage /vim /voice, MCP prompts), interactive mode (keyboard shortcuts general controls Ctrl+C Ctrl+D Ctrl+G Ctrl+L Ctrl+O Ctrl+R Ctrl+V Ctrl+B Ctrl+T Shift+Tab Alt+P Alt+T Alt+O, text editing Ctrl+K Ctrl+U Ctrl+Y Alt+Y Alt+B Alt+F, multiline input Shift+Enter Option+Enter backslash-Enter Ctrl+J, quick commands / and @ prefixes, transcript viewer Ctrl+E, voice input Space push-to-talk, vim editor mode with mode switching navigation editing text objects, command history reverse search Ctrl+R, background bash commands Ctrl+B backgrounding, bash mode with prefix, prompt suggestions Tab to accept, side questions /btw, task list Ctrl+T, PR review status), keybindings (keybindings.json configuration, contexts Global Chat Autocomplete Settings Confirmation Tabs Help Transcript HistorySearch Task ThemePicker Attachments Footer MessageSelector DiffDialog ModelPicker Select Plugin, all available actions app/history/chat/autocomplete/confirm/permission/transcript/historySearch/task/theme/help/tabs/attachments/footer/messageSelector/diff/modelPicker/select/plugin/settings/voice, keystroke syntax modifiers chords uppercase special keys, unbinding defaults, reserved shortcuts Ctrl+C Ctrl+D Ctrl+M, terminal conflicts Ctrl+B Ctrl+A Ctrl+Z, vim mode interaction), terminal configuration (themes line breaks Shift+Enter Option+Enter /terminal-setup, notification setup terminal notifications iTerm2 Kitty Ghostty tmux passthrough, notification hooks, handling large inputs, vim mode), and tools reference (all built-in tools Agent AskUserQuestion Bash CronCreate CronDelete CronList Edit EnterPlanMode EnterWorktree ExitPlanMode ExitWorktree Glob Grep ListMcpResourcesTool LSP NotebookEdit PowerShell Read ReadMcpResourceTool Skill TaskCreate TaskGet TaskList TaskOutput TaskStop TaskUpdate TodoWrite ToolSearch WebFetch WebSearch Write with permission requirements, Bash tool behavior working directory and env persistence CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR CLAUDE_ENV_FILE, PowerShell tool opt-in with CLAUDE_CODE_USE_POWERSHELL_TOOL defaultShell shell settings preview limitations). Load when discussing Claude Code CLI, command-line flags, CLI reference, launch commands, slash commands, built-in commands, interactive mode, keyboard shortcuts, keybindings, keybindings.json, terminal configuration, terminal setup, Shift+Enter, vim mode, tools reference, built-in tools, tool permissions, Bash tool, PowerShell tool, background tasks, bash mode, prompt suggestions, /btw side questions, task list, PR review status, system prompt flags, print mode, output format, stream-json, bare mode, permission modes from CLI, auto mode, worktree flag, tmux flag, or any CLI-related topic for Claude Code.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface -- covering launch commands and flags, built-in slash commands, interactive mode shortcuts, keybinding customization, terminal configuration, and the full tools reference.

## Quick Reference

### CLI Launch Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive), then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation |
| `claude -r <session> "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (`--email`, `--sso`, `--console`) |
| `claude auth status` | Show auth status as JSON (`--text` for readable) |
| `claude agents` | List configured subagents |
| `claude auto-mode defaults` | Print built-in auto mode rules as JSON |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins (alias: `plugins`) |
| `claude remote-control` | Start Remote Control server |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Continue most recent conversation |
| `-r`, `--resume` | Resume specific session by ID or name |
| `-n`, `--name` | Set session display name |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `max` |
| `--bare` | Minimal mode, skip auto-discovery for faster start |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--allowedTools` | Tools that skip permission prompts |
| `--disallowedTools` | Tools removed from model context |
| `--tools` | Restrict available built-in tools |
| `--permission-mode` | Begin in specified permission mode |
| `--enable-auto-mode` | Unlock auto mode in Shift+Tab cycle |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--mcp-config` | Load MCP servers from JSON files |
| `--plugin-dir` | Load plugins from directory |
| `--add-dir` | Add additional working directories |
| `--agent` | Specify agent for session |
| `--agents` | Define subagents dynamically via JSON |
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--json-schema` | Get validated JSON output matching schema |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Max dollar spend (print mode) |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--tmux` | Create tmux session for worktree |
| `--remote` | Create web session on claude.ai |
| `--remote-control`, `--rc` | Enable Remote Control in interactive session |
| `--teleport` | Resume web session locally |
| `--chrome` / `--no-chrome` | Enable/disable Chrome integration |
| `--ide` | Auto-connect to IDE on startup |
| `--verbose` | Full turn-by-turn output |
| `--debug` | Debug mode with category filtering |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag. Prefer append flags for most use cases.

### Built-in Commands (Slash Commands)

**Session management:** `/clear` (alias `/reset`, `/new`), `/resume` (alias `/continue`), `/rename`, `/branch` (alias `/fork`), `/exit` (alias `/quit`), `/rewind` (alias `/checkpoint`)

**Model and mode:** `/model`, `/effort`, `/fast`, `/plan`, `/vim`, `/compact`

**Information:** `/help`, `/cost`, `/usage`, `/status`, `/stats`, `/context`, `/diff`, `/doctor`, `/insights`, `/release-notes`

**Configuration:** `/config` (alias `/settings`), `/permissions` (alias `/allowed-tools`), `/memory`, `/hooks`, `/keybindings`, `/color`, `/theme`, `/statusline`, `/terminal-setup`, `/sandbox`, `/privacy-settings`

**Integration:** `/mcp`, `/ide`, `/plugin`, `/reload-plugins`, `/chrome`, `/install-github-app`, `/install-slack-app`

**Output and sharing:** `/copy`, `/export`, `/desktop` (alias `/app`), `/mobile` (alias `/ios`, `/android`)

**Communication:** `/btw` (side question), `/voice`, `/pr-comments`, `/feedback` (alias `/bug`), `/remote-control` (alias `/rc`), `/remote-env`

**Tasks and scheduling:** `/tasks`, `/schedule`, `/security-review`

**Other:** `/add-dir`, `/agents`, `/extra-usage`, `/stickers`, `/skills`, `/passes`, `/upgrade`, `/login`, `/logout`, `/init`

### Keyboard Shortcuts

**General controls:**

| Shortcut | Action |
|:---------|:-------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+L` | Clear terminal screen |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open in external editor |
| `Shift+Tab` | Cycle permission modes |
| `Alt+P` | Switch model |
| `Alt+T` | Toggle extended thinking |
| `Alt+O` | Toggle fast mode |
| `Esc Esc` | Rewind or summarize |

**Multiline input:**

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + Enter |
| macOS default | Option+Enter |
| Shift+Enter | Works natively in iTerm2, WezTerm, Ghostty, Kitty |
| Control sequence | Ctrl+J |

**Quick commands:** `/` at start for commands/skills, `` ` `` at start for bash mode, `@` for file path autocomplete.

### Keybinding Customization

Config file: `~/.claude/keybindings.json` (open with `/keybindings`). Changes auto-apply without restart.

**Contexts:** Global, Chat, Autocomplete, Settings, Confirmation, Tabs, Help, Transcript, HistorySearch, Task, ThemePicker, Attachments, Footer, MessageSelector, DiffDialog, ModelPicker, Select, Plugin

**Key actions:**

| Action | Default | Context |
|:-------|:--------|:--------|
| `chat:submit` | Enter | Chat |
| `chat:newline` | (unbound) | Chat |
| `chat:cycleMode` | Shift+Tab | Chat |
| `chat:modelPicker` | Cmd+P / Meta+P | Chat |
| `chat:externalEditor` | Ctrl+G, Ctrl+X Ctrl+E | Chat |
| `app:interrupt` | Ctrl+C | Global |
| `app:exit` | Ctrl+D | Global |
| `app:toggleTodos` | Ctrl+T | Global |
| `app:toggleTranscript` | Ctrl+O | Global |
| `task:background` | Ctrl+B | Task |

**Keystroke syntax:** Modifiers (`ctrl`, `alt`/`opt`, `shift`, `meta`/`cmd`) joined with `+`. Chords separated by spaces (e.g., `ctrl+k ctrl+s`). Uppercase letter implies Shift (e.g., `K` = `shift+k`).

**Reserved (cannot rebind):** Ctrl+C, Ctrl+D, Ctrl+M

Unbind with `null`: `"ctrl+s": null`

### Built-in Tools

| Tool | Permission | Description |
|:-----|:-----------|:------------|
| `Agent` | No | Spawn subagent with isolated context |
| `AskUserQuestion` | No | Ask multiple-choice questions |
| `Bash` | Yes | Execute shell commands |
| `CronCreate` | No | Schedule recurring prompt in session |
| `CronDelete` | No | Cancel scheduled task |
| `CronList` | No | List scheduled tasks |
| `Edit` | Yes | Targeted file edits |
| `EnterPlanMode` | No | Switch to plan mode |
| `EnterWorktree` | No | Create isolated git worktree |
| `ExitPlanMode` | Yes | Present plan and exit plan mode |
| `ExitWorktree` | No | Exit worktree session |
| `Glob` | No | Find files by pattern |
| `Grep` | No | Search file contents |
| `ListMcpResourcesTool` | No | List MCP resources |
| `LSP` | No | Code intelligence via language servers |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `PowerShell` | Yes | Execute PowerShell (Windows, opt-in) |
| `Read` | No | Read file contents |
| `ReadMcpResourceTool` | No | Read MCP resource by URI |
| `Skill` | Yes | Execute a skill |
| `TaskCreate` | No | Create task in task list |
| `TaskGet` | No | Get task details |
| `TaskList` | No | List all tasks |
| `TaskOutput` | No | (Deprecated) Get background task output |
| `TaskStop` | No | Kill background task |
| `TaskUpdate` | No | Update task status/details |
| `TodoWrite` | No | Manage session checklist (non-interactive) |
| `ToolSearch` | No | Search and load deferred tools |
| `WebFetch` | Yes | Fetch URL content |
| `WebSearch` | Yes | Web search |
| `Write` | Yes | Create or overwrite files |

### Bash Tool Behavior

- Each command runs in a separate process
- Working directory persists across commands
- Environment variables do NOT persist across commands
- Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to reset to project dir after each command
- Set `CLAUDE_ENV_FILE` to a shell script for persistent env vars
- Activate virtualenv/conda before launching Claude Code

### PowerShell Tool (Windows, Opt-in Preview)

Enable with `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. Auto-detects `pwsh.exe` (7+) with fallback to `powershell.exe` (5.1). Bash tool remains available alongside.

Related settings: `"defaultShell": "powershell"` for interactive commands, `"shell": "powershell"` on individual hooks, `shell: powershell` in skill frontmatter.

**Limitations:** No auto mode support, no profile loading, no sandboxing, native Windows only (not WSL), Git Bash still required to start Claude Code.

### Terminal Configuration

**Shift+Enter setup:** Works natively in iTerm2, WezTerm, Ghostty, Kitty. Run `/terminal-setup` for VS Code, Alacritty, Zed, Warp.

**Notifications:** Kitty and Ghostty work without config. iTerm2 requires enabling "Notification Center Alerts" and "Send escape sequence-generated alerts". For tmux: `set -g allow-passthrough on`.

**Option as Meta (macOS):** Required for Alt key shortcuts. iTerm2: Profiles > Keys > "Esc+". Terminal.app: Profiles > Keyboard > "Use Option as Meta Key". VS Code: `terminal.integrated.macOptionIsMeta: true`.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) -- All launch commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude auto-mode, claude mcp, claude plugin, claude remote-control) and complete CLI flags table with descriptions and examples, system prompt flags behavior and mutual exclusivity rules
- [Built-in Commands](references/claude-code-commands.md) -- Complete table of all slash commands available in interactive mode with descriptions, MCP prompts as commands format
- [Interactive Mode](references/claude-code-interactive-mode.md) -- Keyboard shortcuts (general controls, text editing, theme/display, multiline input, quick commands, transcript viewer, voice input), vim editor mode (mode switching, navigation, editing, text objects), command history and reverse search, background bash commands and Ctrl+B backgrounding, bash mode with prefix, prompt suggestions, side questions with /btw, task list, PR review status
- [Keybindings](references/claude-code-keybindings.md) -- Keybindings.json configuration format, all contexts and their available actions (app, history, chat, autocomplete, confirmation, permission, transcript, historySearch, task, theme, help, tabs, attachments, footer, messageSelector, diff, modelPicker, select, plugin, settings, voice), keystroke syntax (modifiers, chords, uppercase, special keys), unbinding defaults, reserved shortcuts, terminal conflicts, vim mode interaction, validation
- [Terminal Configuration](references/claude-code-terminal-config.md) -- Terminal themes, line break configuration (Shift+Enter, Option+Enter, /terminal-setup), notification setup (terminal notifications for iTerm2/Kitty/Ghostty, tmux passthrough, notification hooks), handling large inputs, vim mode configuration
- [Tools Reference](references/claude-code-tools-reference.md) -- Complete table of all built-in tools with descriptions and permission requirements, Bash tool behavior (working directory persistence, env var non-persistence, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR, CLAUDE_ENV_FILE), PowerShell tool opt-in preview (CLAUDE_CODE_USE_POWERSHELL_TOOL, shell selection in settings/hooks/skills, preview limitations)

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Built-in Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
