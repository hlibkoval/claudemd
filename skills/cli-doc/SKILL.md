---
name: cli-doc
description: Complete official documentation for the Claude Code CLI — launch commands, flags, in-session slash commands, keyboard shortcuts, keybindings customization, terminal configuration, and built-in tools reference.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface.

## Quick Reference

### Launch commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode (SDK): run query and exit |
| `cat file \| claude -p "query"` | Process piped content in print mode |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -c -p "query"` | Continue most recent conversation in print mode |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall binary (`stable`, `latest`, or version like `2.1.118`) |
| `claude auth login` | Sign in (use `--console` for API key billing, `--sso` for SSO) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List configured subagents |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins (alias: `claude plugins`) |
| `claude remote-control` | Start Remote Control server (no local session) |
| `claude setup-token` | Generate long-lived OAuth token for CI/scripts |

### Key CLI flags

| Flag | Description |
| :--- | :--- |
| `-p`, `--print` | Print mode: non-interactive, outputs response and exits |
| `-c`, `--continue` | Load most recent conversation in current directory |
| `-r`, `--resume` | Resume session by ID or name (or show interactive picker) |
| `-n`, `--name` | Set display name for the session |
| `-w`, `--worktree` | Start in an isolated git worktree |
| `--model` | Set model (`sonnet`, `opus`, or full model name) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in a permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--dangerously-skip-permissions` | Skip all permission prompts (equivalent to `bypassPermissions`) |
| `--tools` | Restrict which built-in tools are available (`""` for none, `"Bash,Edit,Read"`) |
| `--allowedTools` | Tools that execute without permission prompts |
| `--disallowedTools` | Tools removed from model context entirely |
| `--add-dir` | Add additional working directories for file access |
| `--output-format` | Print mode output format: `text`, `json`, `stream-json` |
| `--input-format` | Print mode input format: `text`, `stream-json` |
| `--max-turns` | Limit agentic turns in print mode |
| `--max-budget-usd` | Spending cap for API calls in print mode |
| `--system-prompt` | Replace entire default system prompt |
| `--system-prompt-file` | Replace system prompt from a file |
| `--append-system-prompt` | Append text to default system prompt |
| `--append-system-prompt-file` | Append file contents to default system prompt |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, memory, CLAUDE.md |
| `--mcp-config` | Load MCP servers from JSON file or string |
| `--plugin-dir` | Load plugins from a directory for this session |
| `--settings` | Path to settings JSON file or inline JSON string |
| `--agents` | Define custom subagents dynamically via JSON |
| `--agent` | Specify a named agent for the session |
| `--fork-session` | Create new session ID when resuming (instead of reusing original) |
| `--from-pr` | Resume sessions linked to a specific GitHub PR (number or URL) |
| `--remote` | Create a new web session on claude.ai with task description |
| `--remote-control`, `--rc` | Start interactive session with Remote Control enabled |
| `--tmux` | Create a tmux session for the worktree (requires `--worktree`) |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, or `tmux` |
| `--debug` | Enable debug mode with optional category filter |
| `--debug-file <path>` | Write debug logs to a file |
| `--verbose` | Verbose logging (full turn-by-turn output) |
| `--version`, `-v` | Print version number |
| `--json-schema` | Structured output matching a JSON Schema (print mode only) |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves prompt cache reuse) |
| `--no-session-persistence` | Disable saving session to disk (print mode only) |
| `--fallback-model` | Auto-fallback model when default is overloaded (print mode only) |
| `--chrome` / `--no-chrome` | Enable/disable Chrome browser integration |
| `--ide` | Auto-connect to IDE on startup |
| `--init` / `--init-only` | Run initialization hooks (with or without starting a session) |
| `--maintenance` | Run maintenance hooks then start interactive mode |

### System prompt flags summary

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either. Prefer append flags to preserve Claude Code's built-in capabilities.

### In-session slash commands (selected)

| Command | Purpose |
| :--- | :--- |
| `/add-dir <path>` | Add a working directory for this session |
| `/clear` | New conversation with empty context (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Summarize conversation to free context |
| `/config` | Open settings UI (alias: `/settings`) |
| `/context` | Visualize context usage with optimization suggestions |
| `/copy [N]` | Copy last (or Nth-last) assistant response to clipboard |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings; press `f` to auto-fix |
| `/effort [level\|auto]` | Set model effort level mid-session |
| `/exit` | Exit CLI (alias: `/quit`) |
| `/export [filename]` | Export conversation as plain text |
| `/help` | Show available commands |
| `/hooks` | View hook configurations |
| `/init` | Initialize project with CLAUDE.md guide |
| `/keybindings` | Open or create keybindings config file |
| `/mcp` | Manage MCP server connections and OAuth |
| `/memory` | Edit CLAUDE.md files, toggle auto-memory |
| `/model [model]` | Select/change AI model |
| `/permissions` | Manage allow/ask/deny tool permission rules (alias: `/allowed-tools`) |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/recap` | Generate one-line session summary on demand |
| `/reload-plugins` | Reload active plugins without restarting |
| `/remote-control` | Enable remote control from claude.ai (alias: `/rc`) |
| `/rename [name]` | Rename current session |
| `/resume [session]` | Resume conversation by ID/name (alias: `/continue`) |
| `/rewind` | Rewind conversation/code to previous point (aliases: `/checkpoint`, `/undo`) |
| `/review [PR]` | Review a pull request locally |
| `/schedule [description]` | Create/manage routines (alias: `/routines`) |
| `/skills` | List available skills |
| `/status` | Show version, model, account, connectivity |
| `/tasks` | List and manage background tasks (alias: `/bashes`) |
| `/theme` | Change color theme |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/usage` | Show session cost, plan limits, activity (aliases: `/cost`, `/stats`) |
| `/branch [name]` | Create conversation branch at current point (alias: `/fork`) |
| `/btw <question>` | Ask side question without adding to conversation history |
| `/batch <instruction>` | [Skill] Orchestrate large-scale parallel codebase changes |
| `/debug [description]` | [Skill] Enable debug logging and troubleshoot |
| `/loop [interval] [prompt]` | [Skill] Run prompt repeatedly on a schedule |
| `/simplify [focus]` | [Skill] Review and fix code quality issues |
| `/fewer-permission-prompts` | [Skill] Auto-generate allowlist to reduce prompts |

MCP prompts appear as `/mcp__<server>__<prompt>` commands.

### Keyboard shortcuts (interactive mode)

| Shortcut | Action |
| :--- | :--- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit Claude Code |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+L` | Clear prompt input and redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+B` | Background current bash command/agent |
| `Ctrl+T` | Toggle task list |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open prompt in external editor |
| `Ctrl+X Ctrl+K` | Kill all background agents (confirm with second press) |
| `Shift+Tab` | Cycle permission modes (default → acceptEdits → plan → …) |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |
| `Esc + Esc` | Rewind or summarize conversation |
| `Up/Down arrows` | Navigate command history (or move cursor in multiline) |

**Multiline input:** `\` + Enter (all terminals), `Ctrl+J` (any terminal), `Shift+Enter` (most terminals), `Option+Enter` (macOS with Option as Meta).

**Quick prefixes:** `/` for commands/skills, `!` for direct bash, `@` for file path autocomplete.

### Keybindings customization

Config file: `~/.claude/keybindings.json` (run `/keybindings` to create/open). Changes apply live without restart.

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

Actions use `namespace:action` format (e.g., `chat:submit`, `app:toggleTodos`). Set a binding to `null` to unbind it.

**Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`

**Key contexts:** `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `Settings`, `ThemePicker`, `Select`, `Plugin`, `Scroll`, `Doctor`, and more.

### Terminal configuration

| Issue | Fix |
| :--- | :--- |
| Shift+Enter submits instead of newline | Run `/terminal-setup` (VS Code, Cursor, Windsurf, Alacritty, Zed); works natively in Ghostty, Kitty, iTerm2, WezTerm, Warp, Apple Terminal |
| Option-key shortcuts do nothing (macOS) | iTerm2: Profiles → Keys → set Option key to "Esc+"; Apple Terminal: Profiles → Keyboard → "Use Option as Meta Key"; VS Code: `"terminal.integrated.macOptionIsMeta": true` |
| No notification when Claude finishes | Desktop notifications: Ghostty, Kitty (auto), iTerm2 (enable in Settings → Profiles → Terminal); others: use a Notification hook |
| Running inside tmux | Add to `~/.tmux.conf`: `set -g allow-passthrough on`, `set -s extended-keys on`, `set -as terminal-features 'xterm*:extkeys'` |
| Display flickers / scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |

**Custom themes:** JSON files in `~/.claude/themes/`. Fields: `name`, `base` (preset: `dark`, `light`, `dark-daltonized`, etc.), `overrides` (color token map). Color values: `#rrggbb`, `rgb(r,g,b)`, `ansi256(n)`, or `ansi:<name>`.

### Built-in tools

| Tool | Permission Required | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawns a subagent with its own context |
| `AskUserQuestion` | No | Asks multiple-choice clarifying questions |
| `Bash` | Yes | Executes shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Manages scheduled tasks in the session |
| `Edit` | Yes | Makes targeted edits to files |
| `EnterPlanMode` / `ExitPlanMode` | No / Yes | Plan mode management |
| `EnterWorktree` / `ExitWorktree` | No | Git worktree management (not in subagents) |
| `Glob` | No | Finds files by pattern |
| `Grep` | No | Searches file contents |
| `LSP` | No | Code intelligence (requires code intelligence plugin) |
| `Monitor` | Yes | Watches a background command, feeds output lines back to Claude |
| `NotebookEdit` | Yes | Modifies Jupyter notebook cells |
| `PowerShell` | Yes | Executes PowerShell commands (opt-in; Windows rolling out) |
| `Read` | No | Reads file contents |
| `Skill` | Yes | Executes a skill in the main conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Task list management |
| `TodoWrite` | No | Session task checklist (non-interactive / Agent SDK) |
| `ToolSearch` | No | Loads deferred MCP tool definitions |
| `WebFetch` | Yes | Fetches content from a URL |
| `WebSearch` | Yes | Performs web searches |
| `Write` | Yes | Creates or overwrites files |
| `SendMessage` | No | Sends messages to agent team teammates (requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) |

**Bash tool notes:** `cd` within a session carries over to later Bash calls if the new directory is inside the project or an added directory. Environment variables do NOT persist between commands. Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to disable working directory carry-over.

**Monitor tool notes:** Requires v2.1.98+. Not available on Amazon Bedrock, Google Vertex AI, or Microsoft Foundry. Not available when `DISABLE_TELEMETRY` or `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` is set.

**PowerShell tool:** Enable with `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. `defaultShell: "powershell"` in settings routes `!` commands through PowerShell. Requires PowerShell 7+ on Linux/macOS/WSL.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — all launch commands and CLI flags with examples
- [Commands](references/claude-code-commands.md) — complete in-session slash command reference, including bundled skills and MCP prompts
- [Interactive mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, vim editor mode, background bash, prompt suggestions, /btw side questions, task list, session recap, PR review status
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) — keybindings config format, all contexts and actions, keystroke syntax, unbinding, reserved shortcuts, terminal conflicts
- [Configure your terminal](references/claude-code-terminal-config.md) — Shift+Enter, Option key shortcuts, terminal bells/notifications, tmux setup, fullscreen rendering, custom themes, Vim mode
- [Tools reference](references/claude-code-tools-reference.md) — complete tool list with permission requirements, Bash/LSP/Monitor/PowerShell tool behavior details

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure your terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
