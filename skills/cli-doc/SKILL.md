---
name: cli-doc
description: Complete official documentation for the Claude Code CLI — commands, flags, slash commands, interactive-mode keyboard shortcuts, Vim editor mode, keybindings configuration, terminal setup, and built-in tools reference.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, keybindings, terminal configuration, and built-in tools.

## Quick Reference

### CLI Commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive, then exit) |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall binary (`stable`, `latest`, or version number) |
| `claude auth login` | Sign in (`--console` for API billing, `--sso` for SSO) |
| `claude auth logout` | Log out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List configured subagents |
| `claude auto-mode defaults` | Print auto mode classifier rules as JSON |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude remote-control` | Start Remote Control server |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Continue most recent conversation |
| `-r`, `--resume` | Resume session by ID or name |
| `-n`, `--name` | Set display name for session |
| `-w`, `--worktree` | Start in isolated git worktree |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Set effort level (`low`, `medium`, `high`, `xhigh`, `max`) |
| `--permission-mode` | Start in a permission mode (`default`, `acceptEdits`, `plan`, `auto`, `bypassPermissions`) |
| `--add-dir` | Add additional working directories |
| `--tools` | Restrict available built-in tools |
| `--allowedTools` | Tools that execute without permission prompts |
| `--disallowedTools` | Tools removed from model context entirely |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append text to default system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append file contents to default system prompt |
| `--output-format` | Print mode output format: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Cap API spend in dollars (print mode) |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--mcp-config` | Load MCP servers from JSON file or string |
| `--plugin-dir` | Load plugin from directory or `.zip` for this session |
| `--dangerously-skip-permissions` | Skip permission prompts (same as `bypassPermissions` mode) |
| `--debug` | Enable debug mode (optional category filter) |
| `--debug-file <path>` | Write debug logs to file |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a pull request |
| `--remote` | Create new web session on claude.ai |
| `--remote-control`, `--rc` | Start interactive session with Remote Control enabled |
| `--tmux` | Create tmux session for worktree (use with `--worktree`) |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, `tmux` |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message for cache reuse |
| `--no-session-persistence` | Disable session saves (print mode) |
| `--session-id` | Use specific UUID for session |
| `--setting-sources` | Comma-separated settings to load: `user`, `project`, `local` |
| `--init-only` | Run Setup and SessionStart hooks, then exit |
| `--include-hook-events` | Include hook lifecycle events in output stream |
| `--json-schema` | Validated JSON output matching a schema (print mode) |
| `-v`, `--version` | Print version |

### System Prompt Flags Summary

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag. Prefer append flags to preserve built-in capabilities.

---

### Slash Commands (In-Session)

Selected built-in commands. Type `/` in a session to see all available commands. Items marked **[Skill]** are bundled skills.

| Command | Purpose |
| :--- | :--- |
| `/add-dir <path>` | Add working directory for file access this session |
| `/agents` | Manage agent configurations |
| `/autofix-pr [prompt]` | Spawn web session to auto-fix PR CI/review issues |
| `/batch <instruction>` | **[Skill]** Orchestrate large-scale parallel codebase changes |
| `/branch [name]` | Branch (fork) current conversation. Alias: `/fork` |
| `/btw <question>` | Ask a side question without adding to conversation history |
| `/clear` | Start new conversation with empty context. Aliases: `/reset`, `/new` |
| `/compact [instructions]` | Summarize conversation to free context |
| `/config` | Open Settings interface. Alias: `/settings` |
| `/context` | Visualize context usage |
| `/copy [N]` | Copy last (or Nth-latest) assistant response to clipboard |
| `/debug [description]` | **[Skill]** Enable debug logging and troubleshoot |
| `/diff` | Open interactive diff viewer |
| `/doctor` | Diagnose installation and settings |
| `/effort [level\|auto]` | Set effort level interactively or by name |
| `/exit` | Exit the CLI. Alias: `/quit` |
| `/export [filename]` | Export conversation as plain text |
| `/fast [on\|off]` | Toggle fast mode |
| `/focus` | Toggle focus view (fullscreen mode only) |
| `/help` | Show help and available commands |
| `/hooks` | View hook configurations |
| `/init` | Initialize project with CLAUDE.md |
| `/insights` | Generate session analysis report |
| `/keybindings` | Open or create keybindings config file |
| `/loop [interval] [prompt]` | **[Skill]** Run prompt repeatedly on a schedule. Alias: `/proactive` |
| `/mcp` | Manage MCP server connections |
| `/memory` | Edit CLAUDE.md files, manage auto-memory |
| `/model [model]` | Select or change model |
| `/permissions` | Manage allow/ask/deny rules. Alias: `/allowed-tools` |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/recap` | Generate one-line session summary on demand |
| `/reload-plugins` | Reload active plugins without restarting |
| `/remote-control` | Enable remote control from claude.ai. Alias: `/rc` |
| `/rename [name]` | Rename current session |
| `/resume [session]` | Resume conversation by ID or name. Alias: `/continue` |
| `/review [PR]` | Review a pull request |
| `/rewind` | Rewind conversation/code to a previous point. Aliases: `/checkpoint`, `/undo` |
| `/schedule [description]` | Create/manage routines. Alias: `/routines` |
| `/security-review` | Analyze pending changes for security vulnerabilities |
| `/simplify [focus]` | **[Skill]** Review changed files for quality and fix issues |
| `/skills` | List available skills |
| `/status` | Show version, model, account, connectivity |
| `/statusline` | Configure Claude Code status line |
| `/tasks` | List and manage background tasks. Alias: `/bashes` |
| `/team-onboarding` | Generate team onboarding guide from usage history |
| `/teleport` | Pull a web session into this terminal. Alias: `/tp` |
| `/terminal-setup` | Configure terminal keybindings for Shift+Enter etc. |
| `/theme` | Change color theme |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/ultraplan <prompt>` | Draft a plan in ultraplan session |
| `/ultrareview [PR]` | Run deep multi-agent code review in cloud sandbox |
| `/usage` | Show session cost, plan limits, activity stats. Aliases: `/cost`, `/stats` |
| `/voice [hold\|tap\|off]` | Toggle voice dictation |

MCP servers can expose prompts as commands using `/mcp__<server>__<prompt>` format.

---

### Interactive Mode Keyboard Shortcuts

#### General Controls

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit Claude Code session |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open prompt in external editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` / `Cmd+V` / `Alt+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (tmux users: press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+X Ctrl+K` | Kill all background agents (press twice to confirm) |
| `Shift+Tab` | Cycle permission modes (`default` → `acceptEdits` → `plan` → ...) |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |
| `Esc` + `Esc` | Rewind or summarize |

#### Text Editing

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+A` | Move to start of current line |
| `Ctrl+E` | Move to end of current line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` | Move cursor back one word |
| `Alt+F` | Move cursor forward one word |

#### Multiline Input

| Method | Shortcut |
| :--- | :--- |
| Quick escape | `\` + `Enter` (all terminals) |
| Option key | `Option+Enter` (macOS with Option as Meta) |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal |
| Control sequence | `Ctrl+J` (any terminal) |

#### Quick Prefixes

| Prefix | Description |
| :--- | :--- |
| `/` at start | Command or skill |
| `!` at start | Shell mode — run command directly |
| `@` | File path autocomplete |

---

### Keybindings Configuration

File: `~/.claude/keybindings.json` (open with `/keybindings`).

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "ctrl+e": "chat:externalEditor",
        "ctrl+u": null
      }
    }
  ]
}
```

Set a binding to `null` to unbind it. Changes apply automatically without restarting.

#### Contexts

`Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Scroll`, `Doctor`

#### Key Action Reference (Selected)

| Action | Default | Description |
| :--- | :--- | :--- |
| `app:interrupt` | Ctrl+C | Cancel current operation |
| `app:exit` | Ctrl+D | Exit Claude Code |
| `app:toggleTodos` | Ctrl+T | Toggle task list |
| `app:toggleTranscript` | Ctrl+O | Toggle verbose transcript |
| `chat:submit` | Enter | Submit message |
| `chat:newline` | Ctrl+J | Insert newline without submitting |
| `chat:cycleMode` | Shift+Tab | Cycle permission modes |
| `chat:modelPicker` | Meta+P | Open model picker |
| `chat:thinkingToggle` | Meta+T | Toggle extended thinking |
| `chat:fastMode` | Meta+O | Toggle fast mode |
| `chat:externalEditor` | Ctrl+G, Ctrl+X Ctrl+E | Open in external editor |
| `chat:killAgents` | Ctrl+X Ctrl+K | Kill all background agents |
| `history:search` | Ctrl+R | Open history search |
| `task:background` | Ctrl+B | Background current task |
| `transcript:exit` | q, Ctrl+C, Escape | Exit transcript view |

#### Reserved (Cannot Rebind)

`Ctrl+C`, `Ctrl+D`, `Ctrl+M`, Caps Lock

#### Terminal Conflicts

| Shortcut | Conflict |
| :--- | :--- |
| `Ctrl+B` | tmux prefix (press twice to send) |
| `Ctrl+A` | GNU screen prefix |
| `Ctrl+Z` | Unix process suspend (SIGTSTP) |

---

### Terminal Configuration

| Issue | Fix |
| :--- | :--- |
| Shift+Enter submits instead of newline | Run `/terminal-setup` (VS Code, Cursor, Windsurf, Alacritty, Zed); use `Ctrl+J` or `\`+Enter everywhere |
| Option shortcuts do nothing on macOS | Enable "Use Option as Meta Key" in terminal settings |
| No bell when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` in settings, or add a `Notification` hook |
| Running inside tmux | Add to `~/.tmux.conf`: `set -g allow-passthrough on`, `set -s extended-keys on`, `set -as terminal-features 'xterm*:extkeys'` |
| Display flickers / scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |

**Custom themes** are JSON files in `~/.claude/themes/`. Fields: `name` (string), `base` (preset name), `overrides` (color token map). Select "New custom theme..." in `/theme` to create one interactively.

---

### Built-in Tools Reference

| Tool | Description | Permission Required |
| :--- | :--- | :--- |
| `Agent` | Spawns a subagent with its own context window | No |
| `AskUserQuestion` | Asks multiple-choice questions to gather requirements | No |
| `Bash` | Executes shell commands | Yes |
| `CronCreate` | Schedules a recurring or one-shot prompt in the session | No |
| `CronDelete` | Cancels a scheduled task by ID | No |
| `CronList` | Lists all scheduled tasks in the session | No |
| `Edit` | Makes targeted edits to specific files | Yes |
| `EnterPlanMode` | Switches to plan mode | No |
| `EnterWorktree` | Creates/switches to an isolated git worktree | No |
| `ExitPlanMode` | Presents plan for approval and exits plan mode | Yes |
| `ExitWorktree` | Exits worktree and returns to original directory | No |
| `Glob` | Finds files based on pattern matching | No |
| `Grep` | Searches for patterns in file contents | No |
| `LSP` | Code intelligence: jump to definition, find references, type errors | No |
| `Monitor` | Runs command in background, feeds each output line back to Claude | Yes |
| `NotebookEdit` | Modifies Jupyter notebook cells | Yes |
| `PowerShell` | Executes PowerShell commands natively | Yes |
| `Read` | Reads file contents | No |
| `Skill` | Executes a skill within the main conversation | Yes |
| `TaskCreate` | Creates a task in the task list | No |
| `TaskGet` | Retrieves full details for a specific task | No |
| `TaskList` | Lists all tasks with current status | No |
| `TaskStop` | Kills a running background task by ID | No |
| `TaskUpdate` | Updates task status, dependencies, or deletes tasks | No |
| `TodoWrite` | Manages session task checklist (non-interactive/Agent SDK) | No |
| `ToolSearch` | Searches for and loads deferred tools (when tool search enabled) | No |
| `WebFetch` | Fetches content from a URL | Yes |
| `WebSearch` | Performs web searches | Yes |
| `Write` | Creates or overwrites files | Yes |

**Bash tool notes:**
- `cd` in main session carries over across Bash calls (within project/added dirs). Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to disable.
- Environment variables do NOT persist between Bash calls.
- Use `CLAUDE_ENV_FILE` or a `SessionStart` hook to persist env vars across calls.

**Monitor tool:** Requires v2.1.98+. Not available on Bedrock, Vertex AI, or Foundry. Uses same permission rules as Bash.

**PowerShell tool:** On Windows (auto-enabled without Git Bash). On Linux/macOS: opt-in via `CLAUDE_CODE_USE_POWERSHELL_TOOL=1` (requires `pwsh` on PATH).

**LSP tool:** Inactive until a code intelligence plugin is installed for your language.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — all CLI commands and flags, including system prompt flags
- [Commands](references/claude-code-commands.md) — complete in-session slash command reference, MCP prompts
- [Interactive mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, Vim editor mode, command history, background bash, shell mode, prompt suggestions, side questions, task list, session recap, PR review status
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) — keybindings.json schema, contexts, all actions, keystroke syntax, chord bindings, unbinding, reserved shortcuts, Vim interaction
- [Configure your terminal](references/claude-code-terminal-config.md) — Shift+Enter, Option key on macOS, terminal bell, tmux setup, fullscreen rendering, custom themes, Vim keybindings
- [Tools reference](references/claude-code-tools-reference.md) — all built-in tools, permission requirements, Bash/LSP/Monitor/PowerShell tool behavior details

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure your terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
