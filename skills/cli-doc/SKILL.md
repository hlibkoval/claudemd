---
name: cli-doc
description: Complete documentation for the Claude Code CLI -- command-line interface reference (all CLI commands and flags), built-in slash commands (/clear, /compact, /config, /diff, /effort, /fork, /memory, /model, /permissions, /plan, /resume, /rewind, /vim, and many more), interactive mode (keyboard shortcuts, multiline input, vim editor mode, command history, reverse search, background bash commands, bash mode with ! prefix, prompt suggestions, /btw side questions, task list, PR review status), customizable keybindings (keybindings.json, contexts, actions, keystroke syntax, chords, vim mode interaction, reserved shortcuts, terminal conflicts), terminal configuration (themes, line breaks, Shift+Enter setup, notification setup, handling large inputs, vim mode), and tools reference (all built-in tools with permission requirements, Bash tool behavior). Load when discussing Claude Code CLI flags, command-line options, slash commands, built-in commands, keyboard shortcuts, keybindings, interactive mode, vim mode, multiline input, terminal setup, terminal configuration, background tasks, bash mode, prompt suggestions, /btw, side questions, task list, tools reference, tool permissions, Bash tool, Edit tool, Write tool, Read tool, Agent tool, Glob tool, Grep tool, WebFetch, WebSearch, --print, -p flag, --model, --resume, --continue, --system-prompt, --append-system-prompt, --dangerously-skip-permissions, --allowedTools, --disallowedTools, --output-format, --max-turns, --worktree, --add-dir, --effort, --agents flag, --mcp-config, --tools, or any other CLI usage question.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, built-in commands, interactive mode, keybindings, terminal configuration, and tools reference.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Non-interactive (print) mode, then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -c -p "query"` | Continue via print mode |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (supports `--email`, `--sso`) |
| `claude auth logout` | Sign out |
| `claude auth status` | Authentication status (JSON; `--text` for human-readable) |
| `claude agents` | List configured subagents |
| `claude mcp` | Configure MCP servers |
| `claude remote-control` | Start remote control server |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `--print`, `-p` | Non-interactive print mode |
| `--continue`, `-c` | Continue most recent conversation |
| `--resume`, `-r` | Resume session by ID or name |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Effort level: `low`, `medium`, `high`, `max` |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append file contents to prompt |
| `--allowedTools` | Tools that skip permission prompts |
| `--disallowedTools` | Tools removed from model context |
| `--tools` | Restrict available built-in tools |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--permission-mode` | Start in a permission mode (e.g., `plan`) |
| `--output-format` | Print mode output: `text`, `json`, `stream-json` |
| `--input-format` | Print mode input: `text`, `stream-json` |
| `--json-schema` | Validated JSON output matching a schema (print mode) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Maximum API spend (print mode) |
| `--fallback-model` | Fallback model when default is overloaded (print mode) |
| `--add-dir` | Add additional working directories |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--name`, `-n` | Set session display name |
| `--mcp-config` | Load MCP servers from JSON |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config` |
| `--agent` | Specify agent for session |
| `--agents` | Define subagents via JSON |
| `--chrome` / `--no-chrome` | Enable/disable Chrome integration |
| `--plugin-dir` | Load plugins from directory |
| `--debug` | Debug mode with optional category filter |
| `--verbose` | Verbose logging |
| `--remote` | Start web session on claude.ai |
| `--remote-control`, `--rc` | Enable remote control in interactive session |
| `--teleport` | Resume web session locally |
| `--settings` | Load settings from JSON file or string |
| `--setting-sources` | Setting sources to load: `user`, `project`, `local` |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a GitHub PR |
| `--ide` | Auto-connect to IDE on startup |
| `--init` / `--init-only` | Run init hooks (with or without interactive session) |
| `--maintenance` | Run maintenance hooks and exit |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, `tmux` |
| `--version`, `-v` | Show version |

System prompt flags: `--system-prompt` and `--system-prompt-file` are mutually exclusive. The append flags can combine with either replacement flag. Most use cases should use append flags to preserve built-in capabilities.

### Built-in Slash Commands

| Command | Purpose |
|:--------|:--------|
| `/clear` | Clear conversation history (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Compact conversation with optional focus |
| `/config` | Open settings UI (alias: `/settings`) |
| `/context` | Visualize current context usage |
| `/copy` | Copy last response to clipboard |
| `/cost` | Show token usage statistics |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings |
| `/effort [level]` | Set effort level (`low`/`medium`/`high`/`max`/`auto`) |
| `/exit` | Exit (alias: `/quit`) |
| `/export [filename]` | Export conversation as plain text |
| `/fast [on\|off]` | Toggle fast mode |
| `/fork [name]` | Fork current conversation |
| `/help` | Show help and commands |
| `/init` | Initialize project with CLAUDE.md |
| `/model [model]` | Select or change model |
| `/memory` | Edit CLAUDE.md files, manage auto-memory |
| `/permissions` | View or update permissions (alias: `/allowed-tools`) |
| `/plan` | Enter plan mode |
| `/resume [session]` | Resume conversation (alias: `/continue`) |
| `/rewind` | Rewind conversation/code (alias: `/checkpoint`) |
| `/vim` | Toggle Vim/Normal editing modes |
| `/add-dir <path>` | Add working directory to session |
| `/agents` | Manage agent configurations |
| `/btw <question>` | Side question without adding to conversation |
| `/chrome` | Configure Chrome integration |
| `/color [color]` | Set prompt bar color |
| `/desktop` | Continue session in Desktop app (alias: `/app`) |
| `/feedback [report]` | Submit feedback (alias: `/bug`) |
| `/hooks` | View hook configurations |
| `/ide` | Manage IDE integrations |
| `/insights` | Analyze Claude Code session patterns |
| `/install-github-app` | Set up Claude GitHub Actions |
| `/install-slack-app` | Install Claude Slack app |
| `/keybindings` | Open keybindings config file |
| `/login` / `/logout` | Sign in/out |
| `/mcp` | Manage MCP servers and OAuth |
| `/mobile` | QR code for mobile app (aliases: `/ios`, `/android`) |
| `/plugin` | Manage plugins |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/release-notes` | View changelog |
| `/reload-plugins` | Reload active plugins |
| `/remote-control` | Enable remote control (alias: `/rc`) |
| `/rename [name]` | Rename current session |
| `/sandbox` | Toggle sandbox mode |
| `/security-review` | Analyze pending changes for vulnerabilities |
| `/skills` | List available skills |
| `/stats` | Visualize usage, sessions, streaks |
| `/status` | Show version, model, account, connectivity |
| `/statusline` | Configure status line |
| `/tasks` | List and manage background tasks |
| `/terminal-setup` | Configure terminal keybindings |
| `/theme` | Change color theme |
| `/usage` | Show plan usage and rate limits |

MCP servers can expose prompts as commands using `/mcp__<server>__<prompt>` format.

### Keyboard Shortcuts (Interactive Mode)

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
| `Ctrl+G` | Open in default text editor |
| `Ctrl+V` / `Cmd+V` / `Alt+V` | Paste image from clipboard |
| `Ctrl+F` | Kill all background agents (press twice to confirm) |
| `Shift+Tab` or `Alt+M` | Toggle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Esc Esc` | Rewind or summarize |

**Text editing:** `Ctrl+K` (delete to end), `Ctrl+U` (delete line), `Ctrl+Y` (paste deleted), `Alt+B`/`Alt+F` (word navigation), `Alt+Y` (cycle paste history).

**Multiline input:** `\` + Enter (all terminals), `Option+Enter` (macOS), `Shift+Enter` (iTerm2/WezTerm/Ghostty/Kitty natively; run `/terminal-setup` for VS Code/Alacritty/Zed/Warp), `Ctrl+J` (line feed).

**Quick commands:** `/` at start for commands/skills, `!` at start for bash mode, `@` for file path autocomplete.

### Bash Mode (! Prefix)

Run shell commands directly by prefixing with `!`. Adds command and output to conversation context. Supports `Ctrl+B` backgrounding and Tab autocomplete from previous commands.

### Prompt Suggestions

Grayed-out suggestions appear based on git history and conversation context. Press Tab to accept, Enter to accept and submit, or start typing to dismiss. Reuses prompt cache so additional cost is minimal.

### Side Questions (/btw)

Ask quick questions without adding to conversation history. Available while Claude is working. No tool access -- answers only from current context. Low cost via prompt cache reuse.

### Task List

Claude creates task lists for complex work. Toggle with `Ctrl+T`. Tasks persist across compactions. Share across sessions with `CLAUDE_CODE_TASK_LIST_ID`.

### PR Review Status

Displays clickable PR link in footer with colored underline: green (approved), yellow (pending), red (changes requested), gray (draft), purple (merged). Requires `gh` CLI.

### Custom Keybindings

Configure in `~/.claude/keybindings.json` (open with `/keybindings`). Changes auto-detected without restart.

**Structure:** Object with `bindings` array. Each block specifies a `context` and a map of keystrokes to actions.

**Contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`.

**Key actions by context:**

| Context | Notable actions |
|:--------|:----------------|
| Global | `app:interrupt`, `app:exit`, `app:toggleTodos`, `app:toggleTranscript` |
| Chat | `chat:submit`, `chat:cancel`, `chat:cycleMode`, `chat:modelPicker`, `chat:thinkingToggle`, `chat:externalEditor`, `chat:stash`, `chat:imagePaste` |
| Confirmation | `confirm:yes`, `confirm:no`, `confirm:cycleMode`, `confirm:toggleExplanation` |

**Keystroke syntax:** Modifiers with `+` (`ctrl+k`, `shift+tab`, `meta+p`). Uppercase letter implies Shift (`K` = `shift+k`). Chords with spaces (`ctrl+k ctrl+s`). Special keys: `escape`, `enter`, `tab`, `space`, arrows, `backspace`, `delete`.

**Unbind:** Set action to `null`. **Reserved:** `Ctrl+C` and `Ctrl+D` cannot be rebound.

To set action to null, assign `null` in the bindings map.

### Vim Editor Mode

Enable with `/vim` or via `/config`. Supports mode switching (`Esc`, `i`/`I`, `a`/`A`, `o`/`O`), navigation (`h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f`/`F`/`t`/`T` with `;`/`,`), editing (`x`, `dd`/`D`, `dw`/`de`/`db`, `cc`/`C`, `cw`/`ce`/`cb`, `.` repeat), yank/paste (`yy`/`Y`, `yw`/`ye`/`yb`, `p`/`P`), text objects (`iw`/`aw`, `iW`/`aW`, `i"`/`a"`, `i'`/`a'`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`), indentation (`>>`/`<<`), and line join (`J`).

### Terminal Configuration

**Option as Meta (macOS):** Required for Alt key shortcuts. iTerm2: Profiles > Keys > Left/Right Option = "Esc+". Terminal.app: Profiles > Keyboard > "Use Option as Meta Key".

**Notifications:** Kitty and Ghostty support desktop notifications natively. iTerm2: enable in Profiles > Terminal > Notification Center Alerts. Other terminals: use notification hooks.

**Large inputs:** Avoid direct pasting of very long content. Use file-based workflows instead. VS Code terminal is especially prone to truncation.

### Built-in Tools

| Tool | Permission | Description |
|:-----|:-----------|:------------|
| `Agent` | No | Spawn subagent with own context |
| `AskUserQuestion` | No | Ask multiple-choice questions |
| `Bash` | Yes | Execute shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Manage scheduled tasks within session |
| `Edit` | Yes | Targeted file edits |
| `EnterPlanMode` / `ExitPlanMode` | No / Yes | Plan mode transitions |
| `EnterWorktree` / `ExitWorktree` | No | Git worktree management |
| `Glob` | No | File pattern matching |
| `Grep` | No | Search file contents |
| `ListMcpResourcesTool` / `ReadMcpResourceTool` | No | MCP resource access |
| `LSP` | No | Code intelligence via language servers |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `Read` | No | Read file contents |
| `Skill` | Yes | Execute a skill |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskOutput` / `TaskStop` | No | Task management |
| `TodoWrite` | No | Session task checklist (non-interactive / Agent SDK) |
| `ToolSearch` | No | Search and load deferred MCP tools |
| `WebFetch` | Yes | Fetch URL content |
| `WebSearch` | Yes | Web search |
| `Write` | Yes | Create or overwrite files |

**Bash tool behavior:** Each command runs in a separate process. Working directory persists; environment variables do not. Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to reset to project dir after each command. Use `CLAUDE_ENV_FILE` or a SessionStart hook for persistent env vars.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) -- all CLI commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude mcp, claude remote-control), all CLI flags (--model, --print, --continue, --resume, --system-prompt, --append-system-prompt, --allowedTools, --disallowedTools, --tools, --output-format, --input-format, --json-schema, --max-turns, --max-budget-usd, --worktree, --add-dir, --effort, --agent, --agents, --mcp-config, --plugin-dir, --debug, --verbose, --remote, --teleport, --settings, --permission-mode, --dangerously-skip-permissions, and more), system prompt flag behavior and mutual exclusivity
- [Built-in commands](references/claude-code-commands.md) -- complete list of slash commands (/clear, /compact, /config, /context, /copy, /cost, /diff, /doctor, /effort, /exit, /export, /fast, /fork, /help, /hooks, /ide, /init, /insights, /keybindings, /login, /logout, /mcp, /memory, /model, /permissions, /plan, /plugin, /pr-comments, /release-notes, /reload-plugins, /remote-control, /rename, /resume, /rewind, /sandbox, /security-review, /skills, /stats, /status, /statusline, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim, and more), MCP prompts as commands
- [Interactive mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts (general controls, text editing, theme/display, multiline input), vim editor mode (mode switching, navigation, editing, text objects), command history and reverse search (Ctrl+R), background bash commands and Ctrl+B, bash mode with ! prefix, prompt suggestions, side questions with /btw, task list, PR review status
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) -- keybindings.json configuration, binding contexts (Global, Chat, Autocomplete, Settings, Confirmation, Tabs, Help, Transcript, HistorySearch, Task, ThemePicker, Attachments, Footer, MessageSelector, DiffDialog, ModelPicker, Select, Plugin), all available actions per context, keystroke syntax (modifiers, uppercase, chords, special keys), unbinding defaults, reserved shortcuts, terminal conflicts, vim mode interaction, validation
- [Terminal configuration](references/claude-code-terminal-config.md) -- themes and appearance, line break methods and Shift+Enter setup, Option as Meta key configuration (iTerm2, Terminal.app, VS Code), notification setup (terminal notifications, notification hooks), handling large inputs, vim mode overview
- [Tools reference](references/claude-code-tools-reference.md) -- all built-in tools (Agent, AskUserQuestion, Bash, CronCreate/Delete/List, Edit, EnterPlanMode, ExitPlanMode, EnterWorktree, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, Read, ReadMcpResourceTool, Skill, TaskCreate/Get/List/Update/Output/Stop, TodoWrite, ToolSearch, WebFetch, WebSearch, Write) with permission requirements, Bash tool persistence behavior, environment variable handling

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Built-in commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Terminal configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
