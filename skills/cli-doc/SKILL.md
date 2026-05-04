---
name: cli-doc
description: Complete official documentation for the Claude Code CLI — launch commands, flags, in-session slash commands, interactive keyboard shortcuts, Vim editing mode, keybindings customization, terminal configuration, and built-in tools reference.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive session controls, keyboard shortcuts, keybindings, terminal configuration, and built-in tools.

## Quick Reference

### Launch Commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Non-interactive print mode (SDK/headless) |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install or reinstall native binary (`stable`, `latest`, or version like `2.1.118`) |
| `claude auth login` | Sign in (`--email`, `--sso`, `--console` flags available) |
| `claude auth logout` | Sign out |
| `claude auth status` | Auth status as JSON (`--text` for human-readable) |
| `claude agents` | List configured subagents |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |
| `claude mcp` | Manage MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local state for a project |
| `claude remote-control` | Start a Remote Control server |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `--print`, `-p` | Non-interactive print mode |
| `--continue`, `-c` | Load most recent conversation |
| `--resume`, `-r` | Resume session by ID or name |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--permission-mode` | Start in `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, or `bypassPermissions` |
| `--output-format` | `text`, `json`, or `stream-json` (print mode) |
| `--input-format` | `text` or `stream-json` (print mode) |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append file contents to default system prompt |
| `--allowedTools` | Tools that run without permission prompts |
| `--disallowedTools` | Tools removed from Claude's context |
| `--tools` | Restrict which built-in tools Claude can use |
| `--add-dir` | Add additional working directories for file access |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Maximum spend in dollars (print mode) |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, memory, CLAUDE.md |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--name`, `-n` | Set display name for session |
| `--mcp-config` | Load MCP servers from JSON file or string |
| `--plugin-dir` | Load plugins from directory (session only) |
| `--dangerously-skip-permissions` | Bypass permission prompts (alias: `--permission-mode bypassPermissions`) |
| `--debug` | Enable debug mode with optional category filtering |
| `--verbose` | Enable verbose turn-by-turn logging |
| `--version`, `-v` | Output version number |
| `--fork-session` | Create new session ID instead of reusing (with `--resume`/`--continue`) |
| `--from-pr` | Resume sessions linked to a pull request |
| `--remote` | Create new web session on claude.ai |
| `--teleport` | Resume a web session in local terminal |
| `--json-schema` | Get validated JSON output matching a JSON Schema (print mode) |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message for cache reuse |
| `--no-session-persistence` | Do not save session to disk (print mode) |
| `--teammate-mode` | Set agent team display: `auto`, `in-process`, or `tmux` |
| `--setting-sources` | Comma-separated list: `user`, `project`, `local` |
| `--settings` | Path to settings JSON file or JSON string |

### System Prompt Flags Summary

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive; append flags can be combined with either.

### In-Session Slash Commands

Selected important commands (type `/` to see all):

| Command | Purpose |
| :--- | :--- |
| `/add-dir <path>` | Add working directory for file access this session |
| `/agents` | Manage agent configurations |
| `/autofix-pr [prompt]` | Spawn a web session to auto-fix a PR's CI failures / review comments |
| `/batch <instruction>` | Orchestrate large-scale parallel changes across a codebase |
| `/branch [name]` | Branch (fork) the current conversation |
| `/btw <question>` | Ask a quick side question without adding to conversation history |
| `/clear` | Start new conversation with empty context (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Summarize conversation to free context |
| `/config` | Open Settings interface (alias: `/settings`) |
| `/context` | Visualize context usage with optimization suggestions |
| `/copy [N]` | Copy last (or Nth) assistant response to clipboard |
| `/debug [description]` | Enable debug logging and analyze session debug log |
| `/diff` | Open interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings; press `f` to auto-fix |
| `/effort [level\|auto]` | Set model effort level interactively or by name |
| `/export [filename]` | Export conversation as plain text |
| `/fast [on\|off]` | Toggle fast mode |
| `/fewer-permission-prompts` | Scan transcripts and add allowlist to reduce prompts |
| `/help` | Show help and available commands |
| `/hooks` | View hook configurations |
| `/init` | Initialize project with a CLAUDE.md guide |
| `/keybindings` | Open or create keybindings config file |
| `/memory` | Edit CLAUDE.md files and manage auto-memory |
| `/model [model]` | Select or change AI model |
| `/permissions` | Manage allow/ask/deny rules (alias: `/allowed-tools`) |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/recap` | Generate one-line session summary on demand |
| `/reload-plugins` | Reload plugins without restarting |
| `/remote-control` | Enable remote control from claude.ai (alias: `/rc`) |
| `/rename [name]` | Rename the current session |
| `/resume [session]` | Resume a conversation by ID or name (alias: `/continue`) |
| `/review [PR]` | Review a pull request locally |
| `/rewind` | Rewind conversation/code to previous point (aliases: `/checkpoint`, `/undo`) |
| `/sandbox` | Toggle sandbox mode |
| `/schedule [description]` | Create/update/list routines (alias: `/routines`) |
| `/security-review` | Analyze pending changes for security issues |
| `/simplify [focus]` | Review changed files and fix quality/efficiency issues |
| `/skills` | List available skills |
| `/status` | Open Settings (Status tab) — works while Claude is responding |
| `/tasks` | List and manage background tasks (alias: `/bashes`) |
| `/teleport` | Pull a web session into local terminal (alias: `/tp`) |
| `/terminal-setup` | Configure terminal keybindings for Shift+Enter etc. |
| `/theme` | Change color theme |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/ultraplan <prompt>` | Draft a plan in an ultraplan session |
| `/ultrareview [PR]` | Run deep multi-agent code review in cloud sandbox |
| `/usage` | Show session cost, plan limits, and activity stats (aliases: `/cost`, `/stats`) |
| `/voice [hold\|tap\|off]` | Toggle voice dictation |
| `/web-setup` | Connect GitHub account to Claude Code on the web |

Commands marked **[Skill]** in the full reference (like `/batch`, `/debug`, `/simplify`, `/loop`, `/fewer-permission-prompts`, `/claude-api`) are bundled skills — prompts handed to Claude rather than built-in CLI behavior.

MCP prompts appear as `/mcp__<server>__<prompt>` and are dynamically discovered.

### General Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit Claude Code |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open prompt in external editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` / `Cmd+V` (iTerm2) / `Alt+V` (Win) | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (tmux users: press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+X Ctrl+K` | Kill all background agents (press twice within 3s) |
| `Shift+Tab` | Cycle permission modes (`default` → `acceptEdits` → `plan` → `auto` → ...) |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |
| `Esc` + `Esc` | Rewind or summarize |

### Text Editing Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Ctrl+A` | Move to start of line |
| `Ctrl+E` | Move to end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+Y` (after `Ctrl+Y`) | Cycle paste history |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

### Multiline Input

| Method | Shortcut |
| :--- | :--- |
| Quick escape | `\` + Enter (all terminals) |
| Option key (macOS) | `Option+Enter` (requires Option as Meta) |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal |
| Control sequence | `Ctrl+J` (any terminal) |

For VS Code, Cursor, Windsurf, Alacritty, and Zed: run `/terminal-setup` once.

### Vim Editor Mode

Enable via `/config` → Editor mode or `"editorMode": "vim"` in settings.

| Mode command | Action |
| :--- | :--- |
| `Esc` | Enter NORMAL mode |
| `i`/`I`/`a`/`A` | Insert before/beginning/after/end |
| `v`/`V` | Character-wise/line-wise visual selection |

NORMAL mode navigation: `h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`, `gg`/`G`, `f{char}`/`F{char}`.

NORMAL mode editing: `x`, `dd`, `D`, `cc`, `C`, `yy`, `p`, `P`, `u`, `.`, `J`.

Text objects: `iw`/`aw`, `i"`/`a"`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`.

### Custom Keybindings

Config file: `~/.claude/keybindings.json` (run `/keybindings` to open/create). Changes apply live without restart.

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

Actions use `namespace:action` format. Set to `null` to unbind. Key contexts: `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Settings`, `Select`, `Plugin`, `Scroll`, `Doctor`, `Footer`, `DiffDialog`, `ModelPicker`, `Tabs`, `Attachments`, `MessageSelector`.

Key chat actions: `chat:submit` (Enter), `chat:newline` (Ctrl+J), `chat:cycleMode` (Shift+Tab), `chat:externalEditor` (Ctrl+G), `chat:cancel` (Escape), `chat:modelPicker` (Meta+P), `chat:fastMode` (Meta+O), `chat:thinkingToggle` (Meta+T).

Reserved (cannot rebind): `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, Caps Lock.

### Terminal Configuration

| Symptom | Fix |
| :--- | :--- |
| Shift+Enter submits (VS Code/Alacritty/Zed/Cursor/Windsurf) | Run `/terminal-setup` |
| Shift+Enter submits inside tmux | Add tmux passthrough config (see below) |
| Option shortcuts do nothing (macOS) | Enable "Option as Meta" in terminal settings |
| No alert when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` or add Notification hook |
| Display flickers / scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |

**tmux config** (`~/.tmux.conf`):
```
set -g allow-passthrough on
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'
```

**Custom theme** (`~/.claude/themes/<name>.json`):
```json
{ "name": "My Theme", "base": "dark", "overrides": { "claude": "#bd93f9", "error": "#ff5555" } }
```
Base options: `dark`, `light`, `dark-daltonized`, `light-daltonized`, `dark-ansi`, `light-ansi`.

### Built-in Tools Reference

| Tool | Permission Required | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawns a subagent |
| `AskUserQuestion` | No | Asks multiple-choice questions |
| `Bash` | Yes | Executes shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Schedule/manage recurring prompts |
| `Edit` | Yes | Makes targeted file edits |
| `EnterPlanMode` / `ExitPlanMode` | No/Yes | Switch in/out of plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Create/exit git worktrees |
| `Glob` | No | Finds files by pattern |
| `Grep` | No | Searches file contents |
| `LSP` | No | Code intelligence (jump to def, find refs, type errors) |
| `Monitor` | Yes | Background watch that feeds output lines back to Claude |
| `NotebookEdit` | Yes | Modifies Jupyter notebook cells |
| `PowerShell` | Yes | Executes PowerShell commands (Windows; opt-in on Linux/macOS) |
| `Read` | No | Reads file contents |
| `Skill` | Yes | Executes a skill within the conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Task list management |
| `TodoWrite` | No | Session task checklist (non-interactive / Agent SDK) |
| `ToolSearch` | No | Loads deferred MCP tools on demand |
| `WebFetch` | Yes | Fetches URL content |
| `WebSearch` | Yes | Performs web searches |
| `Write` | Yes | Creates or overwrites files |
| `SendMessage` | No | Sends message to agent team teammate (requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) |

**Bash tool notes:**
- `cd` within project directory carries over between Bash calls; resets if outside project
- Environment variables do NOT persist between Bash calls
- Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to disable directory carry-over

**Monitor tool notes:** Requires v2.1.98+. Not available on Bedrock, Vertex AI, or Foundry. Uses same permission rules as Bash.

**PowerShell tool:** Enable with `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. On Windows without Git Bash, enabled automatically. `"defaultShell": "powershell"` routes interactive `!` commands through PowerShell.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — all launch commands and CLI flags, system prompt flag behavior
- [Commands](references/claude-code-commands.md) — complete slash command reference, MCP prompts, bundled skills vs built-in commands
- [Interactive Mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, Vim editor mode, command history, shell mode, background tasks, `/btw` side questions, task list, session recap
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) — keybindings.json format, all contexts, all actions with defaults, keystroke syntax, chord bindings, reserved shortcuts
- [Configure Your Terminal](references/claude-code-terminal-config.md) — Shift+Enter setup, Option key on macOS, tmux config, notifications, fullscreen rendering, custom themes, paste behavior, Vim mode
- [Tools Reference](references/claude-code-tools-reference.md) — complete tool list with permission requirements, Bash/LSP/Monitor/PowerShell tool details

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure Your Terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
