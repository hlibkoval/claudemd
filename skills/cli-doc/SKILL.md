---
name: cli-doc
description: Complete official documentation for Claude Code CLI — all commands, flags, slash commands, interactive keyboard shortcuts, keybindings configuration, terminal setup, tools reference, and permission requirements.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface.

## Quick Reference

### CLI Commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode: query and exit (non-interactive) |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall native binary (`stable`, `latest`, or version) |
| `claude auth login` | Sign in (use `--console` for API billing) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List configured subagents |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local project state |
| `claude remote-control` | Start a Remote Control server |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Load most recent conversation |
| `-r`, `--resume` | Resume session by ID or name |
| `-n`, `--name` | Set display name for session |
| `-w`, `--worktree` | Start in isolated git worktree |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in a permission mode: `default`, `acceptEdits`, `plan`, `auto`, `bypassPermissions` |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--bare` | Minimal mode: no hooks, skills, plugins, MCP, CLAUDE.md |
| `--add-dir` | Add additional working directories |
| `--tools` | Restrict which built-in tools are available |
| `--allowedTools` | Tools that run without permission prompts |
| `--disallowedTools` | Tools removed from model's context |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append system prompt from file |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Max spend on API calls (print mode only) |
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--input-format` | Input format: `text`, `stream-json` |
| `--mcp-config` | Load MCP servers from JSON |
| `--plugin-dir` | Load plugin from directory or `.zip` for this session |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a pull request |
| `--debug` | Enable debug mode (optional category filter) |
| `--verbose` | Enable verbose turn-by-turn logging |
| `--agent` | Specify an agent for the session |
| `--agents` | Define custom subagents via JSON |
| `--chrome` | Enable Chrome browser integration |
| `--remote` | Create a web session on claude.ai |
| `--remote-control`, `--rc` | Enable Remote Control in interactive session |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, `tmux` |
| `--tmux` | Create tmux session for worktree |
| `--teleport` | Resume a web session in local terminal |
| `--setting-sources` | Comma-separated sources: `user`, `project`, `local` |
| `--settings` | Path to settings JSON file or inline JSON string |
| `--json-schema` | Validated JSON output matching a schema (print mode) |
| `--init` | Run Setup hooks with `init` matcher before session |
| `--init-only` | Run Setup and SessionStart hooks then exit |
| `--include-hook-events` | Include hook events in `stream-json` output |
| `--version`, `-v` | Output version number |

### System Prompt Flags

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag. Prefer append flags to preserve built-in capabilities.

### Slash Commands (In-Session)

| Command | Type | Purpose |
| :--- | :--- | :--- |
| `/add-dir <path>` | Built-in | Add working directory for file access |
| `/agents` | Built-in | Manage agent configurations |
| `/autofix-pr [prompt]` | Built-in | Spawn web session to auto-fix PR CI/review |
| `/batch <instruction>` | Skill | Orchestrate large-scale parallel codebase changes |
| `/branch [name]` | Built-in | Branch/fork conversation at this point |
| `/btw <question>` | Built-in | Ask side question without adding to conversation |
| `/clear` | Built-in | Start new conversation; aliases: `/reset`, `/new` |
| `/compact [instructions]` | Built-in | Summarize conversation to free context |
| `/config` | Built-in | Open settings interface; alias: `/settings` |
| `/context` | Built-in | Visualize context usage |
| `/copy [N]` | Built-in | Copy last (or Nth) assistant response to clipboard |
| `/debug [description]` | Skill | Enable debug logging and troubleshoot |
| `/diff` | Built-in | Open interactive diff viewer |
| `/doctor` | Built-in | Diagnose Claude Code installation |
| `/effort [level\|auto]` | Built-in | Set model effort level |
| `/exit` | Built-in | Exit CLI; alias: `/quit` |
| `/export [filename]` | Built-in | Export conversation as plain text |
| `/fast [on\|off]` | Built-in | Toggle fast mode |
| `/feedback` | Built-in | Submit feedback; alias: `/bug` |
| `/fewer-permission-prompts` | Skill | Scan transcripts and add allowlist to reduce prompts |
| `/focus` | Built-in | Toggle focus view (fullscreen only) |
| `/help` | Built-in | Show help and available commands |
| `/hooks` | Built-in | View hook configurations |
| `/ide` | Built-in | Manage IDE integrations |
| `/init` | Built-in | Initialize project with CLAUDE.md |
| `/insights` | Built-in | Generate report analyzing your sessions |
| `/install-github-app` | Built-in | Set up Claude GitHub Actions |
| `/keybindings` | Built-in | Open/create keybindings config |
| `/loop [interval] [prompt]` | Skill | Run prompt repeatedly; alias: `/proactive` |
| `/mcp` | Built-in | Manage MCP server connections |
| `/memory` | Built-in | Edit CLAUDE.md files, manage auto-memory |
| `/model [model]` | Built-in | Select or change the AI model |
| `/permissions` | Built-in | Manage allow/ask/deny tool rules; alias: `/allowed-tools` |
| `/plan [description]` | Built-in | Enter plan mode |
| `/plugin` | Built-in | Manage plugins |
| `/recap` | Built-in | Generate one-line session summary |
| `/release-notes` | Built-in | View changelog in interactive picker |
| `/reload-plugins` | Built-in | Reload all active plugins |
| `/remote-control` | Built-in | Enable remote control from claude.ai; alias: `/rc` |
| `/rename [name]` | Built-in | Rename current session |
| `/resume [session]` | Built-in | Resume conversation by ID or name; alias: `/continue` |
| `/review [PR]` | Built-in | Review a pull request locally |
| `/rewind` | Built-in | Rewind conversation/code to previous point; aliases: `/checkpoint`, `/undo` |
| `/sandbox` | Built-in | Toggle sandbox mode |
| `/schedule [description]` | Built-in | Create/manage routines; alias: `/routines` |
| `/security-review` | Built-in | Analyze branch changes for security issues |
| `/simplify [focus]` | Skill | Review changed files for quality/efficiency then fix |
| `/skills` | Built-in | List available skills |
| `/status` | Built-in | Open settings (Status tab) |
| `/statusline` | Built-in | Configure status line |
| `/tasks` | Built-in | List and manage background tasks; alias: `/bashes` |
| `/team-onboarding` | Built-in | Generate team onboarding guide |
| `/teleport` | Built-in | Pull web session into terminal; alias: `/tp` |
| `/terminal-setup` | Built-in | Configure terminal keybindings (VS Code, Cursor, etc.) |
| `/theme` | Built-in | Change color theme |
| `/tui [default\|fullscreen]` | Built-in | Set terminal UI renderer |
| `/ultraplan <prompt>` | Built-in | Draft plan in ultraplan session |
| `/ultrareview [PR]` | Built-in | Deep multi-agent cloud code review |
| `/usage` | Built-in | Show session cost and plan usage; aliases: `/cost`, `/stats` |
| `/voice [hold\|tap\|off]` | Built-in | Toggle voice dictation |
| `/web-setup` | Built-in | Connect GitHub to Claude Code on the web |

MCP server prompts appear as `/mcp__<server>__<prompt>` commands.

### Keyboard Shortcuts (Interactive Mode)

#### General Controls

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit session |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open prompt in external editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` / `Cmd+V` | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (press twice in tmux) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+X Ctrl+K` | Kill all background agents (confirm within 3s) |
| `Shift+Tab` | Cycle permission modes |
| `Esc` + `Esc` | Rewind or summarize conversation |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |

#### Text Editing

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+A` | Move to start of current line |
| `Ctrl+E` | Move to end of current line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+Y` | Cycle paste history (after `Ctrl+Y`) |
| `Alt+B` | Move cursor back one word |
| `Alt+F` | Move cursor forward one word |

#### Multiline Input Methods

| Method | Shortcut | Works In |
| :--- | :--- | :--- |
| Quick escape | `\` + `Enter` | All terminals |
| Control sequence | `Ctrl+J` | All terminals |
| Shift+Enter (native) | `Shift+Enter` | iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| Shift+Enter (setup) | `Shift+Enter` | VS Code, Cursor, Windsurf, Alacritty, Zed — run `/terminal-setup` first |
| Option key | `Option+Enter` | macOS with Option-as-Meta enabled |

#### Quick Prefixes

| Prefix | Action |
| :--- | :--- |
| `/` at start | Command or skill |
| `!` at start | Shell mode — runs directly, adds output to context |
| `@` | File path autocomplete |

### Built-in Tools Reference

| Tool | Permission | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawn subagent with separate context window |
| `AskUserQuestion` | No | Ask multiple-choice questions |
| `Bash` | Yes | Execute shell commands |
| `CronCreate` | No | Schedule recurring/one-shot prompt in session |
| `CronDelete` | No | Cancel a scheduled task |
| `CronList` | No | List scheduled tasks |
| `Edit` | Yes | Make targeted edits to files |
| `EnterPlanMode` | No | Switch to plan mode |
| `EnterWorktree` | No | Create/switch into isolated git worktree |
| `ExitPlanMode` | Yes | Present plan for approval and exit plan mode |
| `ExitWorktree` | No | Exit worktree and return to original directory |
| `Glob` | No | Find files by pattern |
| `Grep` | No | Search file contents for patterns |
| `LSP` | No | Code intelligence: definitions, references, errors |
| `Monitor` | Yes | Watch output in background and react to changes |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `PowerShell` | Yes | Execute PowerShell commands natively |
| `Read` | No | Read file contents |
| `Skill` | Yes | Execute a skill in the main conversation |
| `TaskCreate` | No | Create task in task list |
| `TaskGet` | No | Retrieve task details |
| `TaskList` | No | List all tasks with status |
| `TaskStop` | No | Kill a running background task |
| `TaskUpdate` | No | Update task status or details |
| `TodoWrite` | No | Manage session task checklist (non-interactive/Agent SDK) |
| `ToolSearch` | No | Search and load deferred tools |
| `WebFetch` | Yes | Fetch content from a URL |
| `WebSearch` | Yes | Perform web searches |
| `Write` | Yes | Create or overwrite files |

### Keybindings Configuration

File: `~/.claude/keybindings.json` (open with `/keybindings`)

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

Actions use `namespace:action` format (e.g., `chat:submit`, `app:toggleTodos`). Set to `null` to unbind. Changes apply without restarting.

#### Keybinding Contexts

`Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Scroll`, `Doctor`

#### Reserved Shortcuts (Cannot Rebind)

`Ctrl+C` (interrupt), `Ctrl+D` (exit), `Ctrl+M` (same as Enter), `Caps Lock`

### Terminal Configuration

| Issue | Solution |
| :--- | :--- |
| Shift+Enter submits instead of newline | Use `Ctrl+J` or `\`+Enter always; run `/terminal-setup` for VS Code/Cursor/Windsurf/Alacritty/Zed |
| Option key shortcuts do nothing (macOS) | Enable Option-as-Meta in terminal settings |
| No notification when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` or use Notification hook |
| Running inside tmux | Add passthrough and extended-keys to `~/.tmux.conf` |
| Display flickers or scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Want Vim keys in prompt | Enable via `/config` → Editor mode |

**tmux config required in `~/.tmux.conf`:**
```
set -g allow-passthrough on
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'
```

**Custom themes** stored in `~/.claude/themes/<slug>.json` with `name`, `base` (dark/light/daltonized/ansi), and `overrides` (color token map). Reloaded live during sessions.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — All CLI commands and flags with examples
- [Commands](references/claude-code-commands.md) — Complete in-session slash command reference
- [Interactive Mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, Vim mode, shell mode, and interactive features
- [Keybindings](references/claude-code-keybindings.md) — Customizing keyboard shortcuts via keybindings.json
- [Terminal Configuration](references/claude-code-terminal-config.md) — Shift+Enter setup, Option key, tmux, themes, fullscreen, Vim mode
- [Tools Reference](references/claude-code-tools-reference.md) — All built-in tools with permission requirements and behavior notes

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
