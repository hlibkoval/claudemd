---
name: cli-doc
description: Complete official documentation for the Claude Code CLI — launch commands, all CLI flags, in-session slash commands, interactive mode keyboard shortcuts, vim editor mode, keybindings configuration, terminal setup, and the built-in tools reference.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, keyboard shortcuts, and built-in tools.

## Quick Reference

### CLI launch commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive, then exit) |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install or reinstall the native binary |
| `claude auth login` | Sign in (use `--console` for API billing) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON |
| `claude agents` | List configured subagents |
| `claude auto-mode defaults` | Print auto mode classifier rules as JSON |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude remote-control` | Start a Remote Control server (server mode) |
| `claude setup-token` | Generate a long-lived OAuth token for CI/scripts |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

### Key CLI flags

| Flag | Description |
| :--- | :--- |
| `--print`, `-p` | Non-interactive print mode |
| `--continue`, `-c` | Load most recent conversation |
| `--resume`, `-r` | Resume session by ID or name |
| `--name`, `-n` | Set display name for the session |
| `--worktree`, `-w` | Start in an isolated git worktree |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--permission-mode` | Start in a specific permission mode (`default`, `acceptEdits`, `plan`, `auto`, `bypassPermissions`) |
| `--dangerously-skip-permissions` | Bypass all permission prompts |
| `--output-format` | Output format for print mode (`text`, `json`, `stream-json`) |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Max spend on API calls (print mode only) |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append text to default system prompt |
| `--system-prompt-file` | Replace system prompt with file contents |
| `--append-system-prompt-file` | Append file contents to default system prompt |
| `--allowedTools` | Tools that execute without permission prompts |
| `--disallowedTools` | Tools removed from model's context |
| `--tools` | Restrict which built-in tools are available |
| `--add-dir` | Add additional working directories |
| `--mcp-config` | Load MCP servers from JSON file or string |
| `--plugin-dir` | Load plugins from a directory for this session |
| `--bare` | Minimal mode; skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--effort` | Set effort level (`low`, `medium`, `high`, `xhigh`, `max`) |
| `--debug` | Enable debug mode |
| `--debug-file <path>` | Write debug logs to a file |
| `--verbose` | Verbose logging, shows full turn-by-turn output |
| `--agent` | Specify agent for current session |
| `--agents` | Define custom subagents dynamically via JSON |
| `--fork-session` | Create new session ID instead of reusing on resume |
| `--from-pr` | Resume sessions linked to a pull request |
| `--session-id` | Use a specific UUID for the conversation |
| `--no-session-persistence` | Disable session persistence (print mode only) |
| `--json-schema` | Get validated JSON output matching a schema (print mode only) |
| `--init` | Run Setup hooks with `init` matcher before session |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message |
| `--remote` | Create a new web session on claude.ai |
| `--remote-control`, `--rc` | Start interactive session with Remote Control enabled |
| `--teleport` | Resume a web session in your local terminal |
| `--teammate-mode` | Set agent team display (`auto`, `in-process`, `tmux`) |
| `--tmux` | Create tmux session for worktree (requires `--worktree`) |
| `--chrome` | Enable Chrome browser integration |
| `--version`, `-v` | Output the version number |

### System prompt flags summary

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag.

### Slash commands (in-session)

Key built-in commands (type `/` to see all):

| Command | Purpose |
| :--- | :--- |
| `/add-dir <path>` | Add a working directory for this session |
| `/batch <instruction>` | Orchestrate large-scale parallel codebase changes (Skill) |
| `/branch [name]` | Fork conversation at this point; alias `/fork` |
| `/btw <question>` | Side question without affecting conversation history |
| `/clear` | Start new conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Summarize conversation to free up context |
| `/config` | Open settings interface (alias: `/settings`) |
| `/context` | Visualize context usage |
| `/copy [N]` | Copy last (or Nth) assistant response to clipboard |
| `/debug [description]` | Enable debug logging and troubleshoot (Skill) |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose Claude Code installation |
| `/effort [level\|auto]` | Set model effort level |
| `/exit` | Exit the CLI (alias: `/quit`) |
| `/export [filename]` | Export conversation as plain text |
| `/fewer-permission-prompts` | Scan transcripts and add allowlist to reduce prompts (Skill) |
| `/help` | Show help and available commands |
| `/hooks` | View hook configurations |
| `/init` | Initialize project with CLAUDE.md |
| `/keybindings` | Open or create keybindings config file |
| `/loop [interval] [prompt]` | Run a prompt repeatedly (Skill; alias: `/proactive`) |
| `/mcp` | Manage MCP server connections |
| `/memory` | Edit CLAUDE.md files, manage auto-memory |
| `/model [model]` | Select or change AI model |
| `/permissions` | Manage allow/ask/deny rules (alias: `/allowed-tools`) |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/recap` | Generate one-line session summary on demand |
| `/reload-plugins` | Reload all active plugins |
| `/remote-control` | Enable remote control for this session (alias: `/rc`) |
| `/rename [name]` | Rename current session |
| `/resume [session]` | Resume a conversation (alias: `/continue`) |
| `/review [PR]` | Review a pull request locally |
| `/rewind` | Rewind conversation/code to a previous point (aliases: `/checkpoint`, `/undo`) |
| `/schedule [description]` | Create/manage routines (alias: `/routines`) |
| `/security-review` | Analyze pending changes for security vulnerabilities |
| `/simplify [focus]` | Review and fix recently changed files (Skill) |
| `/skills` | List available skills |
| `/status` | Show version, model, account, connectivity |
| `/tasks` | List and manage background tasks (alias: `/bashes`) |
| `/teleport` | Pull a web session into this terminal (alias: `/tp`) |
| `/terminal-setup` | Configure terminal keybindings (VS Code, Cursor, Alacritty, Zed) |
| `/theme` | Change color theme |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/ultraplan <prompt>` | Draft and execute a plan via ultraplan session |
| `/ultrareview [PR]` | Deep multi-agent code review in cloud sandbox |
| `/usage` | Show session cost, plan limits, activity stats (aliases: `/cost`, `/stats`) |
| `/voice [hold\|tap\|off]` | Toggle voice dictation |

### Interactive mode keyboard shortcuts

#### General controls

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open prompt in external editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running task (tmux users press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+X Ctrl+K` | Kill all background agents (press twice within 3s to confirm) |
| `Shift+Tab` | Cycle permission modes (`default` → `acceptEdits` → `plan` → ...) |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |
| `Esc` + `Esc` | Rewind or summarize |

#### Text editing

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+A` / `Ctrl+E` | Move cursor to start / end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` / `Alt+F` | Move cursor back / forward one word |

#### Multiline input

| Method | Shortcut |
| :--- | :--- |
| Quick escape | `\` + `Enter` (all terminals) |
| Option key (macOS) | `Option+Enter` (requires Option as Meta) |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal |
| Control sequence | `Ctrl+J` (any terminal) |

#### Shell mode

Prefix input with `!` to run shell commands directly: `! git status`, `! npm test`.

### Vim editor mode

Enable via `/config` → Editor mode or set `"editorMode": "vim"` in settings.

**Mode switching**: `Esc` → NORMAL, `i`/`I`/`a`/`A`/`o`/`O` → INSERT, `v`/`V` → VISUAL

**NORMAL mode navigation**: `h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f{char}`/`F{char}`

**NORMAL mode editing**: `x` delete char, `dd` delete line, `cc` change line, `yy` yank line, `p`/`P` paste, `u` undo, `.` repeat

**Text objects**: `iw`/`aw` word, `i"`/`a"` quotes, `i(`/`a(` parens, `i{`/`a{` braces

### Keybindings configuration

Config file: `~/.claude/keybindings.json` (run `/keybindings` to open). Changes apply without restart.

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

Actions use `namespace:action` format. Key contexts: `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Select`, `Plugin`, `Settings`, `Scroll`.

Key actions: `app:interrupt` (Ctrl+C), `app:exit` (Ctrl+D), `chat:submit` (Enter), `chat:newline` (Ctrl+J), `chat:cycleMode` (Shift+Tab), `chat:modelPicker` (Meta+P), `chat:externalEditor` (Ctrl+G).

Set an action to `null` to unbind it. Reserved (cannot rebind): `Ctrl+C`, `Ctrl+D`, `Ctrl+M`.

### Terminal configuration

| Symptom | Fix |
| :--- | :--- |
| Shift+Enter submits instead of newline (VS Code, Cursor, Alacritty, Zed) | Run `/terminal-setup` once |
| Option shortcuts do nothing on macOS | Enable "Use Option as Meta Key" in terminal settings |
| No alert when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` or add Notification hook |
| Running inside tmux | Add `set -g allow-passthrough on`, `set -s extended-keys on`, `set -as terminal-features 'xterm*:extkeys'` to `~/.tmux.conf` |
| Display flickers / scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |

Custom themes: create JSON files in `~/.claude/themes/`. Fields: `name` (string), `base` (preset), `overrides` (color token map).

### Built-in tools reference

| Tool | Description | Permission Required |
| :--- | :--- | :--- |
| `Agent` | Spawns a subagent with its own context window | No |
| `AskUserQuestion` | Asks multiple-choice questions | No |
| `Bash` | Executes shell commands | Yes |
| `CronCreate` / `CronDelete` / `CronList` | Schedule recurring or one-shot prompts | No |
| `Edit` | Makes targeted edits to specific files | Yes |
| `EnterPlanMode` / `ExitPlanMode` | Switch to/from plan mode | No / Yes |
| `EnterWorktree` / `ExitWorktree` | Create and switch into git worktrees | No |
| `Glob` | Finds files by pattern | No |
| `Grep` | Searches file contents | No |
| `LSP` | Code intelligence (definitions, references, type errors) | No |
| `Monitor` | Runs a command in background and feeds output back to Claude | Yes |
| `NotebookEdit` | Modifies Jupyter notebook cells | Yes |
| `PowerShell` | Executes PowerShell commands natively | Yes |
| `Read` | Reads file contents | No |
| `Skill` | Executes a skill within the main conversation | Yes |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | Task list management | No |
| `TodoWrite` | Session task checklist (non-interactive / Agent SDK) | No |
| `ToolSearch` | Searches for and loads deferred tools | No |
| `WebFetch` | Fetches content from a URL | Yes |
| `WebSearch` | Performs web searches | Yes |
| `Write` | Creates or overwrites files | Yes |

**Bash tool notes**: `cd` carries over within project directories; environment variables do not persist between commands. Use `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to disable working directory carry-over.

**Monitor tool**: requires v2.1.98+. Not available on Bedrock, Vertex AI, or Microsoft Foundry.

**PowerShell tool**: enabled automatically on Windows without Git Bash; opt-in on Linux/macOS via `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — All CLI commands and flags with examples
- [Commands](references/claude-code-commands.md) — Complete slash command reference for in-session use
- [Interactive Mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, vim mode, background tasks, shell mode, session features
- [Keybindings](references/claude-code-keybindings.md) — Customize keyboard shortcuts via keybindings.json
- [Terminal Configuration](references/claude-code-terminal-config.md) — Fix Shift+Enter, Option keys, tmux, notifications, fullscreen rendering, custom themes
- [Tools Reference](references/claude-code-tools-reference.md) — Built-in tools, permission requirements, Bash/LSP/Monitor/PowerShell behavior

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
