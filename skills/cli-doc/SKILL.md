---
name: cli-doc
description: Complete documentation for the Claude Code CLI -- command-line interface reference (all CLI commands and flags including --print, --continue, --resume, --model, --bare, --system-prompt, --append-system-prompt, --allowedTools, --disallowedTools, --tools, --mcp-config, --json-schema, --output-format, --max-turns, --max-budget-usd, --effort, --worktree, --agents, --agent, --remote, --remote-control, --teleport, --channels, --permission-mode, --dangerously-skip-permissions, --settings, --plugin-dir, --from-pr, --fork-session, --chrome, --debug, --verbose, system prompt flags), built-in slash commands (/clear, /compact, /config, /diff, /effort, /export, /branch, /help, /init, /model, /permissions, /plan, /pr-comments, /resume, /rewind, /schedule, /skills, /vim, /voice, /btw, /agents, /chrome, /color, /context, /copy, /cost, /desktop, /doctor, /exit, /extra-usage, /fast, /feedback, /hooks, /ide, /install-github-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /passes, /plugin, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /sandbox, /security-review, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /upgrade, /usage, /install-slack-app, /insights), interactive mode (keyboard shortcuts for general controls, text editing, theme/display, multiline input, quick commands, voice input, Vim editor mode with navigation/editing/text objects, command history and Ctrl+R reverse search, background bash commands, bash mode with !, prompt suggestions, /btw side questions, task list with Ctrl+T, PR review status), customizable keybindings (~/.claude/keybindings.json, contexts like Global/Chat/Autocomplete/Confirmation/Tabs/Help/Transcript/HistorySearch/Task/ThemePicker/Attachments/Footer/MessageSelector/DiffDialog/ModelPicker/Select/Plugin/Settings, all available actions and defaults, keystroke syntax with modifiers/chords/special keys, unbinding defaults, reserved shortcuts Ctrl+C/Ctrl+D, terminal conflicts, vim mode interaction, validation), terminal configuration (themes, line breaks and Shift+Enter setup, Option+Enter setup, notification setup for iTerm2/Kitty/Ghostty/tmux passthrough, notification hooks, handling large inputs, vim mode setup), tools reference (Agent, AskUserQuestion, Bash, CronCreate/Delete/List, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, Read, ReadMcpResourceTool, Skill, TaskCreate/Get/List/Output/Stop/Update, TodoWrite, ToolSearch, WebFetch, WebSearch, Write, permission requirements, Bash tool behavior with working directory persistence and environment variable non-persistence, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR, CLAUDE_ENV_FILE). Load when discussing CLI flags, command-line usage, claude commands, print mode, headless flags, slash commands, built-in commands, keyboard shortcuts, keybindings, interactive mode, vim mode, terminal setup, terminal configuration, Shift+Enter, notification setup, tools reference, tool permissions, Bash tool behavior, background tasks, bash mode, prompt suggestions, /btw side questions, task list, PR review status, command history, reverse search, multiline input, system prompt flags, or any CLI/terminal/interactive usage topic for Claude Code.
user-invocable: false
---

# CLI & Interactive Mode Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, built-in commands, interactive mode, keybindings, terminal configuration, and tools reference.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start with initial prompt |
| `claude -p "query"` | Print mode (non-interactive), then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation |
| `claude -c -p "query"` | Continue in print mode |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (use `--console` for API billing) |
| `claude auth logout` | Log out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List configured subagents |
| `claude mcp` | Configure MCP servers |
| `claude remote-control` | Start Remote Control server |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Continue most recent conversation |
| `-r`, `--resume` | Resume session by ID or name |
| `-n`, `--name` | Set session display name |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Set effort level (`low`, `medium`, `high`, `max`) |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append system prompt from file |
| `--allowedTools` | Tools that skip permission prompts |
| `--disallowedTools` | Tools removed from model context |
| `--tools` | Restrict which built-in tools are available |
| `--mcp-config` | Load MCP servers from JSON file(s) |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config` |
| `--output-format` | Print mode output: `text`, `json`, `stream-json` |
| `--input-format` | Print mode input: `text`, `stream-json` |
| `--json-schema` | Validated JSON output matching a schema (print mode) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Maximum API spend (print mode) |
| `--fallback-model` | Fallback model when default is overloaded (print mode) |
| `--permission-mode` | Start in a permission mode (`plan`, etc.) |
| `--dangerously-skip-permissions` | Skip permission prompts |
| `--permission-prompt-tool` | MCP tool for permission prompts in non-interactive mode |
| `--add-dir` | Add additional working directories |
| `--agent` | Specify agent for current session |
| `--agents` | Define subagents dynamically via JSON |
| `--plugin-dir` | Load plugins from directory |
| `--settings` | Load settings from JSON file or string |
| `--setting-sources` | Comma-separated setting sources (`user`, `project`, `local`) |
| `--chrome` / `--no-chrome` | Enable/disable Chrome integration |
| `--remote` | Create web session on claude.ai |
| `--remote-control`, `--rc` | Interactive session with Remote Control |
| `--teleport` | Resume web session locally |
| `--channels` | MCP channel notifications to listen for |
| `--from-pr` | Resume sessions linked to a GitHub PR |
| `--fork-session` | Create new session ID when resuming |
| `--session-id` | Use specific UUID for conversation |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, `tmux` |
| `--ide` | Auto-connect to IDE on startup |
| `--init` / `--init-only` | Run initialization hooks (and optionally exit) |
| `--maintenance` | Run maintenance hooks and exit |
| `--debug` | Debug mode with optional category filter |
| `--verbose` | Verbose logging with full turn-by-turn output |
| `-v`, `--version` | Print version |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag.

### Built-in Slash Commands (Selected)

| Command | Purpose |
|:--------|:--------|
| `/clear` | Clear conversation history (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Compact conversation with optional focus |
| `/config` | Open settings interface (alias: `/settings`) |
| `/context` | Visualize context usage as colored grid |
| `/copy [N]` | Copy last assistant response to clipboard |
| `/cost` | Show token usage statistics |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings |
| `/effort [level]` | Set model effort level (`low`/`medium`/`high`/`max`/`auto`) |
| `/export [filename]` | Export conversation as plain text |
| `/branch [name]` | Branch conversation at this point (alias: `/fork`) |
| `/model [model]` | Select or change AI model |
| `/permissions` | View/update permissions (alias: `/allowed-tools`) |
| `/plan` | Enter plan mode from the prompt |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/resume [session]` | Resume conversation (alias: `/continue`) |
| `/rewind` | Rewind conversation/code (alias: `/checkpoint`) |
| `/schedule [description]` | Create/manage Cloud scheduled tasks |
| `/btw <question>` | Side question without adding to conversation |
| `/vim` | Toggle Vim editing mode |
| `/voice` | Toggle push-to-talk voice dictation |
| `/add-dir <path>` | Add working directory to session |
| `/agents` | Manage agent configurations |
| `/chrome` | Configure Chrome settings |
| `/color [color]` | Set prompt bar color |
| `/desktop` | Continue session in Desktop app (alias: `/app`) |
| `/fast [on\|off]` | Toggle fast mode |
| `/feedback` | Submit feedback (alias: `/bug`) |
| `/hooks` | View hook configurations |
| `/ide` | Manage IDE integrations |
| `/init` | Initialize project CLAUDE.md |
| `/insights` | Analyze session patterns |
| `/keybindings` | Open keybindings config file |
| `/login` / `/logout` | Sign in/out |
| `/mcp` | Manage MCP servers |
| `/memory` | Edit CLAUDE.md, toggle auto-memory |
| `/mobile` | QR code for mobile app (aliases: `/ios`, `/android`) |
| `/plugin` | Manage plugins |
| `/remote-control` | Enable Remote Control (alias: `/rc`) |
| `/rename [name]` | Rename current session |
| `/sandbox` | Toggle sandbox mode |
| `/security-review` | Analyze branch changes for vulnerabilities |
| `/skills` | List available skills |
| `/stats` | Visualize usage, streaks, model preferences |
| `/status` | Show version, model, account, connectivity |
| `/statusline` | Configure status line |
| `/tasks` | List/manage background tasks |
| `/terminal-setup` | Configure terminal keybindings |
| `/theme` | Change color theme |
| `/usage` | Show plan usage and rate limits |

### Keyboard Shortcuts (Interactive Mode)

**General controls:**

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` | Open in default text editor |
| `Ctrl+L` | Clear terminal screen |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` / `Cmd+V` / `Alt+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Shift+Tab` / `Alt+M` | Toggle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Esc` + `Esc` | Rewind or summarize |

**Multiline input:**

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + `Enter` |
| macOS default | `Option+Enter` |
| Shift+Enter | Works natively in iTerm2, WezTerm, Ghostty, Kitty |
| Control sequence | `Ctrl+J` |

**Quick commands:** `/` for commands/skills, `` ` `` for bash mode, `@` for file path autocomplete.

### Tools Reference

| Tool | Permission | Description |
|:-----|:-----------|:------------|
| `Agent` | No | Spawns subagent with own context window |
| `AskUserQuestion` | No | Asks multiple-choice questions |
| `Bash` | Yes | Executes shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Manage scheduled tasks within session |
| `Edit` | Yes | Makes targeted edits to files |
| `EnterPlanMode` | No | Switches to plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Create/exit isolated git worktrees |
| `ExitPlanMode` | Yes | Presents plan for approval |
| `Glob` | No | Finds files by pattern |
| `Grep` | No | Searches file contents |
| `ListMcpResourcesTool` / `ReadMcpResourceTool` | No | List/read MCP resources |
| `LSP` | No | Code intelligence via language servers |
| `NotebookEdit` | Yes | Modifies Jupyter notebook cells |
| `Read` | No | Reads file contents |
| `Skill` | Yes | Executes a skill in main conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskOutput` / `TaskStop` | No | Manage background tasks and task list |
| `TodoWrite` | No | Session task checklist (non-interactive/Agent SDK) |
| `ToolSearch` | No | Searches for and loads deferred tools |
| `WebFetch` | Yes | Fetches content from URL |
| `WebSearch` | Yes | Performs web searches |
| `Write` | Yes | Creates or overwrites files |

**Bash tool behavior:** Working directory persists across commands. Environment variables do not persist. Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to reset to project directory after each command. Use `CLAUDE_ENV_FILE` or a SessionStart hook to persist env vars.

### Custom Keybindings

Config file: `~/.claude/keybindings.json` (open with `/keybindings`). Changes auto-detected without restart.

**Contexts:** Global, Chat, Autocomplete, Settings, Confirmation, Tabs, Help, Transcript, HistorySearch, Task, ThemePicker, Attachments, Footer, MessageSelector, DiffDialog, ModelPicker, Select, Plugin.

**Key actions (with defaults):**

| Action | Default | Context |
|:-------|:--------|:--------|
| `app:interrupt` | Ctrl+C | Global |
| `app:exit` | Ctrl+D | Global |
| `app:toggleTodos` | Ctrl+T | Global |
| `app:toggleTranscript` | Ctrl+O | Global |
| `chat:submit` | Enter | Chat |
| `chat:cycleMode` | Shift+Tab | Chat |
| `chat:modelPicker` | Cmd+P / Meta+P | Chat |
| `chat:thinkingToggle` | Cmd+T / Meta+T | Chat |
| `chat:externalEditor` | Ctrl+G | Chat |
| `chat:stash` | Ctrl+S | Chat |
| `chat:imagePaste` | Ctrl+V | Chat |
| `history:search` | Ctrl+R | Chat |
| `task:background` | Ctrl+B | Task |

**Keystroke syntax:** Modifiers with `+` (`ctrl+k`, `shift+tab`, `meta+p`). Uppercase letter implies Shift (`K` = `shift+k`). Chords separated by spaces (`ctrl+k ctrl+s`). Set action to `null` to unbind.

**Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`.

### Terminal Configuration

**Shift+Enter setup:** Works natively in iTerm2, WezTerm, Ghostty, Kitty. For VS Code, Alacritty, Zed, Warp: run `/terminal-setup`.

**Option as Meta (macOS):** Required for Alt-key shortcuts.
- iTerm2: Settings > Profiles > Keys > set Option to "Esc+"
- Terminal.app: Settings > Profiles > Keyboard > check "Use Option as Meta Key"
- VS Code: set `terminal.integrated.macOptionIsMeta: true`

**Notifications:** Kitty and Ghostty work natively. iTerm2: enable Notification Center Alerts and check "Send escape sequence-generated alerts". For tmux: `set -g allow-passthrough on`. Other terminals: use notification hooks.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) -- all CLI commands and flags, system prompt flags, examples
- [Built-in commands](references/claude-code-commands.md) -- complete list of slash commands with descriptions, MCP prompts
- [Interactive mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts, Vim editor mode (mode switching, navigation, editing, text objects), command history, Ctrl+R reverse search, background bash commands, bash mode, prompt suggestions, /btw side questions, task list, PR review status
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) -- keybindings.json structure, all contexts and available actions with defaults, keystroke syntax (modifiers, chords, special keys, uppercase letters), unbinding, reserved shortcuts, terminal conflicts, vim mode interaction, validation
- [Terminal configuration](references/claude-code-terminal-config.md) -- themes, line breaks and Shift+Enter/Option+Enter setup, notification setup (iTerm2, Kitty, Ghostty, tmux passthrough), handling large inputs, vim mode
- [Tools reference](references/claude-code-tools-reference.md) -- all built-in tools with permission requirements, Bash tool behavior (working directory persistence, env var non-persistence, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR, CLAUDE_ENV_FILE)

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Built-in commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Terminal configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
