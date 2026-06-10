---
name: cli-doc
user-invocable: false
---

# CLI & Interactive Mode Documentation

This skill provides the complete official documentation for the Claude Code CLI, slash commands, interactive mode, keyboard shortcuts, terminal configuration, and built-in tools.

## Quick Reference

### CLI Commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start with initial prompt |
| `claude -p "query"` | Print mode (non-interactive, exits after response) |
| `claude -c` | Continue most recent conversation |
| `claude -r "<name>"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (use `--console` for API billing) |
| `claude agents` | Open agent view for background sessions |
| `claude --bg "task"` | Start session as background agent |
| `claude attach <id>` | Attach to a background session |
| `claude stop/rm/logs <id>` | Stop, remove, or print logs for a background session |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local state for a project |
| `claude remote-control` | Start Remote Control server |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `-p` / `--print` | Non-interactive print mode |
| `-c` / `--continue` | Load most recent conversation |
| `-r` / `--resume` | Resume session by ID or name |
| `-n` / `--name` | Set session display name |
| `-w` / `--worktree` | Start in isolated git worktree |
| `--model` | Set model (`sonnet`, `opus`, `haiku`, `fable`, or full ID) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in a permission mode: `default`, `acceptEdits`, `plan`, `auto`, `bypassPermissions` |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--add-dir` | Add extra working directory for file access |
| `--allowedTools` | Tools that run without permission prompts |
| `--disallowedTools` | Tools to deny or remove from context |
| `--tools` | Restrict which built-in tools are available |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--system-prompt-file` | Replace system prompt with file contents |
| `--append-system-prompt-file` | Append file contents to default prompt |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Max API spend before stopping (print mode only) |
| `--mcp-config` | Load MCP servers from JSON file or string |
| `--plugin-dir` | Load plugin from directory or zip for this session |
| `--settings` | Path to settings JSON or inline JSON string |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--safe-mode` | Disable all customizations for troubleshooting |
| `--bg` | Start as background agent |
| `--verbose` | Show full turn-by-turn output |
| `--debug` | Enable debug mode with optional category filter |

### System Prompt Flags Summary

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag.

### Slash Commands (Key Selections)

| Command | Description |
| :--- | :--- |
| `/clear [name]` | Start fresh conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Summarize conversation to free context |
| `/context [all]` | Visualize context window usage |
| `/model [model]` | Switch AI model |
| `/effort [level]` | Set effort level |
| `/plan [description]` | Enter plan mode |
| `/diff` | Interactive diff viewer |
| `/code-review [level] [--fix] [--comment]` | Review diff for bugs and cleanups |
| `/simplify [target]` | Cleanup-only review that applies fixes |
| `/rewind` | Roll back code and conversation to a checkpoint |
| `/resume [session]` | Resume previous conversation |
| `/branch [name]` | Fork conversation at current point |
| `/fork <directive>` | Spawn background subagent with full conversation context |
| `/background [prompt]` | Detach session as background agent (alias: `/bg`) |
| `/batch <instruction>` | Orchestrate large-scale parallel codebase changes |
| `/memory` | Edit CLAUDE.md memory files |
| `/permissions` | Manage allow/ask/deny tool rules |
| `/hooks` | View hook configurations |
| `/skills` | List available skills |
| `/agents` | Manage subagent configurations |
| `/tasks` | View background tasks |
| `/btw <question>` | Side question without adding to conversation history |
| `/goal [condition]` | Set a goal Claude works toward across turns |
| `/rename [name]` | Rename current session |
| `/init` | Initialize CLAUDE.md for project |
| `/doctor` | Diagnose installation and settings |
| `/debug [description]` | Enable debug logging and analyze session log |
| `/config` | Open settings interface (alias: `/settings`) |
| `/keybindings` | Open keyboard shortcuts file |
| `/theme` | Change color theme |
| `/usage` | Show session cost and plan limits (aliases: `/cost`, `/stats`) |
| `/export [filename]` | Export conversation as plain text |
| `/copy [N]` | Copy last assistant response to clipboard |
| `/review [PR]` | Review a pull request locally |
| `/security-review` | Analyze pending changes for security vulnerabilities |
| `/schedule [description]` | Create/manage routines on cloud infrastructure |
| `/teleport` | Pull a web session into this terminal |
| `/remote-control` | Enable remote control from claude.ai (alias: `/rc`) |
| `/tui [default\|fullscreen]` | Switch terminal UI renderer |
| `/cd <path>` | Move session to new working directory (v2.1.169+) |
| `/add-dir <path>` | Add working directory for file access |
| `/reload-plugins [--force]` | Reload active plugins without restarting |
| `/reload-skills` | Re-scan skill directories (v2.1.152+) |
| `/deep-research <question>` | Fan-out web research workflow |
| `/ultraplan <prompt>` | Draft a plan in ultraplan session |
| `/ultrareview [PR]` | Deep multi-agent cloud code review |
| `/autofix-pr [prompt]` | Spawn cloud session to auto-fix PR CI failures |

Commands marked **[Skill]** are bundled prompt-based skills; commands marked **[Workflow]** fan out across multiple subagents. Type `/` to see all available commands filtered by your platform and plan.

### Interactive Mode Keyboard Shortcuts

**General controls:**

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Interrupt or clear input |
| `Ctrl+D` | Exit Claude Code |
| `Esc` | Interrupt current response |
| `Esc Esc` | Clear input draft, or open rewind menu |
| `Shift+Tab` | Cycle permission modes |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse history search |
| `Ctrl+B` | Background running tasks |
| `Ctrl+T` | Toggle task list |
| `Ctrl+V` | Paste image from clipboard |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open prompt in external editor |
| `Ctrl+L` | Redraw screen |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |

**Text editing (readline-style):**

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+A` / `Ctrl+E` | Move cursor to start/end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

**Multiline input:**

| Method | Shortcut |
| :--- | :--- |
| Works everywhere | `\` + Enter, or `Ctrl+J` |
| Native in most terminals | `Shift+Enter` |
| After Option-as-Meta enabled | `Option+Enter` (macOS) |

**Shell mode:** prefix input with `!` to run shell commands directly without Claude interpreting them. Output is added to conversation context.

**Prompt suggestions:** after Claude responds, grayed-out suggestions appear. Press Tab or Right arrow to accept.

### Keybindings Configuration

Config file: `~/.claude/keybindings.json` (open with `/keybindings`)

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

**Key contexts:** `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `Select`, `Scroll` (fullscreen only), `DiffDialog`, `ModelPicker`, `ThemePicker`, `Plugin`, `Settings`, `Doctor`, `Help`, `Tabs`, `Footer`, `Attachments`, `MessageSelector`

**Action format:** `namespace:action` (e.g., `chat:submit`, `app:toggleTodos`). Set to `null` to unbind. Changes are applied live without restart.

**Reserved shortcuts (cannot be rebound):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, Caps Lock

### Terminal Configuration

| Issue | Solution |
| :--- | :--- |
| Shift+Enter submits instead of newline | Run `/terminal-setup` (VS Code, Cursor, Alacritty, Zed); works natively in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| Option shortcuts do nothing on macOS | Enable "Use Option as Meta Key" in terminal settings |
| No notification when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` in settings, or configure Notification hook |
| Display flickers or scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Running inside tmux | Add `set -g allow-passthrough on`, `set -s extended-keys on`, `set -as terminal-features 'xterm*:extkeys'` to `~/.tmux.conf` |

**Custom themes:** place `.json` files in `~/.claude/themes/`. Fields: `name` (string), `base` (dark/light/dark-daltonized/light-daltonized/dark-ansi/light-ansi), `overrides` (map of color tokens). Select **New custom theme…** in `/theme` to create interactively.

### Built-in Tools Reference

| Tool | Permission Required | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawns a subagent with its own context window |
| `Bash` | Yes | Executes shell commands |
| `Edit` | Yes | Exact string replacement in files |
| `Write` | Yes | Creates or overwrites files |
| `Read` | No | Reads file contents (supports images, PDFs, notebooks) |
| `Glob` | No | Finds files by name pattern |
| `Grep` | No | Searches file contents (ripgrep-based) |
| `LSP` | No | Code intelligence via language servers |
| `WebFetch` | Yes | Fetches URL content, converts HTML to Markdown |
| `WebSearch` | Yes | Runs web search queries |
| `Monitor` | Yes | Watches a command output in background (v2.1.98+) |
| `NotebookEdit` | Yes | Modifies Jupyter notebook cells by cell_id |
| `PowerShell` | Yes | Executes PowerShell commands natively |
| `EnterPlanMode` / `ExitPlanMode` | No / Yes | Switches to/from plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Creates/exits isolated git worktree |
| `Skill` | Yes | Executes a skill within the main conversation |
| `TaskCreate/Get/List/Update/Stop` | No | Session task checklist management |
| `CronCreate/Delete/List` | No | Scheduled tasks within session |
| `PushNotification` | No | Sends desktop/phone notification |
| `RemoteTrigger` | No | Creates/manages cloud Routines |
| `SendMessage` | No | Messages agent team teammate (experimental) |
| `ToolSearch` | No | Searches deferred tools when tool search is enabled |
| `Workflow` | Yes | Runs a dynamic workflow across subagents |

**Tool permission rule formats:**

| Rule | Applies to |
| :--- | :--- |
| `Bash(npm run *)` | Bash, Monitor (command pattern) |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP (path pattern) |
| `Edit(/src/**)` | Edit, Write, NotebookEdit (path pattern) |
| `WebFetch(domain:example.com)` | WebFetch (domain matching) |
| `Skill(deploy *)` | Skill (name matching) |
| `Agent(Explore)` | Agent (subagent type matching) |
| `WebSearch` | WebSearch (no specifier) |

**Key tool behaviors:**
- **Edit**: requires read-before-edit; `old_string` must be exact and unique
- **Bash**: working directory persists within project; env vars do not persist; 2-minute timeout (max 10 min); 30,000 char output limit
- **Glob**: does not respect `.gitignore` by default; results capped at 100 files
- **Grep**: respects `.gitignore`; uses ripgrep regex syntax; three output modes: `files_with_matches`, `content`, `count`
- **WebFetch**: fetches URL, converts HTML to Markdown via extraction model; results cached 15 min; redirects to different hosts are not auto-followed
- **Monitor**: uses Bash permission rules; not available on Bedrock, Vertex, or Foundry
- **Write**: requires read-before-write for existing files; use Edit for partial changes

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — Complete reference for all CLI commands and flags
- [Commands](references/claude-code-commands.md) — All slash commands available in Claude Code sessions
- [Interactive Mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, Vim mode, shell mode, command history, and interactive features
- [Keybindings](references/claude-code-keybindings.md) — Customizing keyboard shortcuts via keybindings.json
- [Terminal Configuration](references/claude-code-terminal-config.md) — Shift+Enter setup, Option key, tmux, custom themes, fullscreen rendering
- [Tools Reference](references/claude-code-tools-reference.md) — All built-in tools, permission rules, and per-tool behavior details

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
