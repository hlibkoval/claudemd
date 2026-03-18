---
name: cli-doc
description: Complete documentation for the Claude Code CLI -- launch commands (claude, claude -p, claude -c, claude -r, claude update, claude auth, claude agents, claude mcp, claude remote-control), all CLI flags (--add-dir, --agent, --agents, --allowedTools, --disallowedTools, --tools, --append-system-prompt, --system-prompt, --system-prompt-file, --append-system-prompt-file, --chrome, --no-chrome, --continue, --resume, --dangerously-skip-permissions, --debug, --effort, --fallback-model, --fork-session, --from-pr, --ide, --init, --input-format, --output-format, --json-schema, --max-budget-usd, --max-turns, --mcp-config, --strict-mcp-config, --model, --name, --no-session-persistence, --permission-mode, --permission-prompt-tool, --plugin-dir, --print, --remote, --remote-control, --session-id, --setting-sources, --settings, --teleport, --teammate-mode, --verbose, --version, --worktree), built-in slash commands (/add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /branch, /help, /hooks, /ide, /init, /insights, /install-github-app, /install-slack-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /model, /passes, /permissions, /plan, /plugin, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /review, /rewind, /sandbox, /security-review, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim, /voice), interactive mode (keyboard shortcuts general/text-editing/theme/multiline/quick-commands/voice, vim mode switching/navigation/editing/text-objects, command history, reverse search Ctrl+R, background bash commands Ctrl+B, bash mode with prefix, prompt suggestions, side questions /btw, task list Ctrl+T, PR review status), customizable keybindings (~/.claude/keybindings.json, contexts Global/Chat/Autocomplete/Settings/Confirmation/Tabs/Help/Transcript/HistorySearch/Task/ThemePicker/Attachments/Footer/MessageSelector/DiffDialog/ModelPicker/Select/Plugin, actions app/history/chat/autocomplete/confirm/permission/transcript/historySearch/task/theme/help/tabs/attachments/footer/messageSelector/diff/modelPicker/select/plugin/settings/voice, keystroke syntax modifiers/uppercase/chords/special-keys, unbinding, reserved shortcuts, terminal conflicts, vim mode interaction, validation), terminal configuration (themes, line breaks Shift+Enter/Option+Enter setup, notification setup iTerm2/Kitty/Ghostty/hooks, handling large inputs, vim mode subset), tools reference (Agent, AskUserQuestion, Bash, CronCreate/Delete/List, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, Read, ReadMcpResourceTool, Skill, TaskCreate/Get/List/Output/Stop/Update, TodoWrite, ToolSearch, WebFetch, WebSearch, Write, permission requirements, Bash tool behavior working directory/env persistence). Load when discussing Claude Code CLI flags, CLI reference, launch commands, slash commands, built-in commands, interactive mode, keyboard shortcuts, keybindings, vim mode, terminal configuration, Shift+Enter setup, notification setup, tools reference, tool permissions, Bash tool behavior, background tasks, bash mode, prompt suggestions, /btw side questions, task list, PR review status, command history, reverse search, multiline input, system prompt flags, --print mode, --output-format, --model, --effort, --permission-mode, --dangerously-skip-permissions, --allowedTools, --disallowedTools, --tools, --mcp-config, --worktree, --remote, --teleport, --remote-control, keybindings.json, keybinding contexts, keybinding actions, keystroke syntax, terminal setup, or any CLI/terminal/interactive usage topic.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface -- launch commands, CLI flags, built-in slash commands, interactive mode features, customizable keybindings, terminal configuration, and the tools reference.

## Quick Reference

### Launch Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Non-interactive (print) mode, then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -c -p "query"` | Continue via SDK |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (`--email`, `--sso` flags available) |
| `claude auth logout` | Log out |
| `claude auth status` | Auth status as JSON (`--text` for human-readable; exit 0 if logged in) |
| `claude agents` | List all configured subagents |
| `claude mcp` | Configure MCP servers |
| `claude remote-control` | Start a Remote Control server (no local interactive session) |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `--print`, `-p` | Non-interactive mode; print response and exit |
| `--continue`, `-c` | Load most recent conversation in current directory |
| `--resume`, `-r` | Resume specific session by ID or name |
| `--model` | Set model (`sonnet`, `opus`, or full model name) |
| `--effort` | Effort level: `low`, `medium`, `high`, `max` (Opus 4.6 only) |
| `--permission-mode` | Begin in a permission mode (`plan`, etc.) |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--allowedTools` | Tools that execute without prompting |
| `--disallowedTools` | Tools removed from model context entirely |
| `--tools` | Restrict available tools (`""` none, `"default"` all, or tool names) |
| `--add-dir` | Add additional working directories |
| `--agent` | Specify agent for session |
| `--agents` | Define custom subagents via JSON |
| `--mcp-config` | Load MCP servers from JSON files or strings |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config` |
| `--plugin-dir` | Load plugins from a directory |
| `--chrome` / `--no-chrome` | Enable/disable Chrome browser integration |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--remote` | Create web session on claude.ai |
| `--remote-control`, `--rc` | Interactive session with Remote Control enabled |
| `--teleport` | Resume web session in local terminal |
| `--name`, `-n` | Set session display name |
| `--output-format` | Print mode output: `text`, `json`, `stream-json` |
| `--input-format` | Print mode input: `text`, `stream-json` |
| `--json-schema` | Validated JSON output matching schema (print mode) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Max API spend before stopping (print mode) |
| `--fallback-model` | Auto-fallback when default model overloaded (print mode) |
| `--system-prompt` | Replace entire system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt` | Append to default system prompt |
| `--append-system-prompt-file` | Append file contents to default prompt |
| `--debug` | Debug mode with optional category filter |
| `--verbose` | Full turn-by-turn output |
| `--version`, `-v` | Show version |

System prompt flags: `--system-prompt` and `--system-prompt-file` are mutually exclusive. The append flags can be combined with either. Prefer append flags to preserve built-in capabilities.

### Built-in Slash Commands (Selected)

| Command | Purpose |
|:--------|:--------|
| `/clear` | Clear conversation history (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Compact conversation with optional focus |
| `/config` | Open settings interface (alias: `/settings`) |
| `/context` | Visualize context usage as colored grid |
| `/copy [N]` | Copy last response to clipboard |
| `/cost` | Show token usage statistics |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/effort [level]` | Set effort level (`low`/`medium`/`high`/`max`/`auto`) |
| `/export [filename]` | Export conversation as plain text |
| `/model [model]` | Select or change model |
| `/permissions` | View/update permissions (alias: `/allowed-tools`) |
| `/plan` | Enter plan mode |
| `/resume [session]` | Resume conversation by ID/name |
| `/rewind` | Rewind conversation/code to previous point (alias: `/checkpoint`) |
| `/branch [name]` | Branch conversation at this point (alias: `/fork`) |
| `/btw <question>` | Side question without adding to history |
| `/memory` | Edit CLAUDE.md files, toggle auto-memory |
| `/mcp` | Manage MCP server connections |
| `/plugin` | Manage plugins |
| `/pr-comments [PR]` | Fetch GitHub PR comments |
| `/skills` | List available skills |
| `/vim` | Toggle Vim/Normal editing modes |
| `/voice` | Toggle push-to-talk voice dictation |
| `/fast [on\|off]` | Toggle fast mode |
| `/init` | Initialize project CLAUDE.md |
| `/keybindings` | Open keybindings config file |
| `/terminal-setup` | Configure terminal keybindings |
| `/doctor` | Diagnose installation/settings |
| `/sandbox` | Toggle sandbox mode |

MCP servers can also expose prompts as `/mcp__<server>__<prompt>` commands.

### Keyboard Shortcuts

#### General Controls

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` | Open prompt in external text editor |
| `Ctrl+L` | Clear terminal screen (keeps history) |
| `Ctrl+O` | Toggle verbose output |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` / `Cmd+V` / `Alt+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Shift+Tab` / `Alt+M` | Toggle permission modes |
| `Alt+P` / `Option+P` | Switch model |
| `Alt+T` / `Option+T` | Toggle extended thinking |
| `Esc Esc` | Rewind or summarize |

#### Multiline Input

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + `Enter` |
| macOS default | `Option+Enter` |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty; run `/terminal-setup` for others |
| Control sequence | `Ctrl+J` |

#### Quick Prefixes

| Prefix | Description |
|:-------|:------------|
| `/` | Slash command or skill |
| ` ` (exclamation mark) | Bash mode -- run command directly |
| `@` | File path autocomplete |

### Vim Mode

Enable with `/vim` or `/config`. Supports mode switching (`Esc`/`i`/`I`/`a`/`A`/`o`/`O`), navigation (`h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f`/`F`/`t`/`T` with `;`/`,`), editing (`x`, `dd`/`D`, `dw`/`de`/`db`, `cc`/`C`, `cw`/`ce`/`cb`, `.`), yank/paste (`yy`/`Y`, `yw`/`ye`/`yb`, `p`/`P`), text objects (`iw`/`aw`, `iW`/`aW`, `i"`/`a"`, `i'`/`a'`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`), indentation (`>>`/`<<`), and join (`J`).

### Customizable Keybindings

Config file: `~/.claude/keybindings.json` (open with `/keybindings`). Changes auto-detected without restart.

**Contexts:** Global, Chat, Autocomplete, Settings, Confirmation, Tabs, Help, Transcript, HistorySearch, Task, ThemePicker, Attachments, Footer, MessageSelector, DiffDialog, ModelPicker, Select, Plugin.

**Keystroke syntax:** Modifiers with `+` (`ctrl+k`, `shift+tab`, `meta+p`, `ctrl+shift+c`). Standalone uppercase implies Shift (`K` = `shift+k`). Chords separated by spaces (`ctrl+k ctrl+s`). Special keys: `escape`/`esc`, `enter`/`return`, `tab`, `space`, `up`/`down`/`left`/`right`, `backspace`, `delete`.

**Unbind:** set action to `null`. **Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`. **Terminal conflicts:** `Ctrl+B` (tmux), `Ctrl+A` (screen), `Ctrl+Z` (SIGTSTP).

### Background Tasks & Bash Mode

**Background tasks:** Claude can run commands asynchronously via the Bash tool's `run_in_background` parameter, or press `Ctrl+B` to background a running command. Output retrieved via TaskOutput. Auto-cleanup on exit. 5GB output limit. Disable with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

**Bash mode (`!` prefix):** Run shell commands directly. Output added to conversation context. Supports `Ctrl+B` backgrounding, history-based Tab autocomplete, and real-time output.

### Terminal Configuration

**Line breaks:** `\` + Enter (all terminals), `Option+Enter` (macOS), `Shift+Enter` (iTerm2/WezTerm/Ghostty/Kitty natively; run `/terminal-setup` for VS Code/Alacritty/Zed/Warp).

**Option as Meta (macOS):** iTerm2: Profiles > Keys > Left/Right Option = "Esc+". Terminal.app: Profiles > Keyboard > "Use Option as Meta Key". VS Code: `terminal.integrated.macOptionIsMeta: true`.

**Notifications:** Kitty/Ghostty natively supported. iTerm2: Profiles > Terminal > "Notification Center Alerts" > Filter > enable "Send escape sequence-generated alerts". Others: use notification hooks.

### Tools Reference

| Tool | Permission | Description |
|:-----|:-----------|:------------|
| `Agent` | No | Spawn subagent with own context window |
| `AskUserQuestion` | No | Ask multiple-choice questions |
| `Bash` | Yes | Execute shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Schedule/cancel/list recurring prompts |
| `Edit` | Yes | Targeted file edits |
| `EnterPlanMode` / `ExitPlanMode` | No / Yes | Switch to/from plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Create/exit isolated git worktree |
| `Glob` | No | Find files by pattern |
| `Grep` | No | Search file contents |
| `ListMcpResourcesTool` / `ReadMcpResourceTool` | No | List/read MCP resources |
| `LSP` | No | Code intelligence (type errors, go-to-definition, find references) |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `Read` | No | Read file contents |
| `Skill` | Yes | Execute a skill |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskOutput` / `TaskStop` / `TaskUpdate` | No | Manage tasks and background task output |
| `TodoWrite` | No | Session task checklist (non-interactive/Agent SDK) |
| `ToolSearch` | No | Search/load deferred tools |
| `WebFetch` | Yes | Fetch URL content |
| `WebSearch` | Yes | Perform web searches |
| `Write` | Yes | Create or overwrite files |

**Bash tool behavior:** Each command runs in a separate process. Working directory persists across commands. Environment variables do not persist (use `CLAUDE_ENV_FILE` or SessionStart hook). Activate virtualenv/conda before launching Claude Code.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) -- all launch commands (claude, claude -p, piped input, claude -c, claude -r, claude update, claude auth login/logout/status, claude agents, claude mcp, claude remote-control), all CLI flags (--add-dir, --agent, --agents, --allow-dangerously-skip-permissions, --allowedTools, --append-system-prompt, --append-system-prompt-file, --betas, --chrome, --continue, --dangerously-skip-permissions, --debug, --disable-slash-commands, --disallowedTools, --effort, --fallback-model, --fork-session, --from-pr, --ide, --init, --init-only, --include-partial-messages, --input-format, --json-schema, --maintenance, --max-budget-usd, --max-turns, --mcp-config, --model, --name, --no-chrome, --no-session-persistence, --output-format, --permission-mode, --permission-prompt-tool, --plugin-dir, --print, --remote, --remote-control, --resume, --session-id, --setting-sources, --settings, --strict-mcp-config, --system-prompt, --system-prompt-file, --teleport, --teammate-mode, --tools, --verbose, --version, --worktree), system prompt flags (replace vs append, mutual exclusivity)
- [Built-in commands](references/claude-code-commands.md) -- complete list of slash commands (/add-dir, /agents, /btw, /chrome, /clear, /color, /compact, /config, /context, /copy, /cost, /desktop, /diff, /doctor, /effort, /exit, /export, /extra-usage, /fast, /feedback, /branch, /help, /hooks, /ide, /init, /insights, /install-github-app, /install-slack-app, /keybindings, /login, /logout, /mcp, /memory, /mobile, /model, /passes, /permissions, /plan, /plugin, /pr-comments, /privacy-settings, /release-notes, /reload-plugins, /remote-control, /remote-env, /rename, /resume, /review, /rewind, /sandbox, /security-review, /skills, /stats, /status, /statusline, /stickers, /tasks, /terminal-setup, /theme, /upgrade, /usage, /vim, /voice), MCP prompts as commands
- [Interactive mode](references/claude-code-interactive-mode.md) -- keyboard shortcuts (general controls, text editing, theme/display, multiline input, quick commands, voice input), built-in commands overview, vim editor mode (mode switching, navigation, editing, text objects), command history and reverse search (Ctrl+R), background bash commands (Ctrl+B backgrounding, output buffering, common use cases), bash mode with exclamation prefix, prompt suggestions (Tab accept, cost model), side questions with /btw (ephemeral, no tools, available while working), task list (Ctrl+T toggle, persistence across compactions), PR review status (colored underline, gh CLI requirement)
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) -- keybindings.json configuration file structure, contexts (Global, Chat, Autocomplete, Settings, Confirmation, Tabs, Help, Transcript, HistorySearch, Task, ThemePicker, Attachments, Footer, MessageSelector, DiffDialog, ModelPicker, Select, Plugin), all available actions by namespace (app, history, chat, autocomplete, confirm, permission, transcript, historySearch, task, theme, help, tabs, attachments, footer, messageSelector, diff, modelPicker, select, plugin, settings, voice), keystroke syntax (modifiers, uppercase letters, chords, special keys), unbinding defaults, reserved shortcuts (Ctrl+C, Ctrl+D), terminal multiplexer conflicts, vim mode interaction, validation and /doctor
- [Terminal configuration](references/claude-code-terminal-config.md) -- themes and appearance, line break methods (quick escape, Shift+Enter native terminals, /terminal-setup for others, Option+Enter macOS setup for Terminal.app/iTerm2/VS Code), notification setup (iTerm2 configuration, Kitty/Ghostty native support, notification hooks), handling large inputs, vim mode supported subset
- [Tools reference](references/claude-code-tools-reference.md) -- complete tool list with permission requirements (Agent, AskUserQuestion, Bash, CronCreate/Delete/List, Edit, EnterPlanMode, EnterWorktree, ExitPlanMode, ExitWorktree, Glob, Grep, ListMcpResourcesTool, LSP, NotebookEdit, Read, ReadMcpResourceTool, Skill, TaskCreate/Get/List/Output/Stop/Update, TodoWrite, ToolSearch, WebFetch, WebSearch, Write), Bash tool behavior (separate processes, working directory persistence, environment variable non-persistence, CLAUDE_ENV_FILE, SessionStart hooks)

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Built-in commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Terminal configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
