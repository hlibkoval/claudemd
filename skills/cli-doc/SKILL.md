---
name: cli-doc
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, including CLI commands and flags, in-session slash commands, interactive mode shortcuts, keyboard customization, terminal configuration, and the built-in tools reference.

## Quick Reference

### CLI Commands (launch-time)

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode: query and exit (SDK/scripting) |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install or reinstall the native binary |
| `claude auth login` | Sign in (use `--console` for API key billing) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status (JSON; `--text` for human-readable) |
| `claude agents` | Open agent view for background sessions |
| `claude attach <id>` | Attach to a background session |
| `claude daemon status` | Show supervisor state |
| `claude daemon stop --any` | Stop supervisor and sessions |
| `claude logs <id>` | Print recent output from a background session |
| `claude mcp` | Configure MCP servers |
| `claude mcp login <name>` | Run MCP server OAuth flow (v2.1.186+) |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude remote-control` | Start Remote Control server |
| `claude respawn <id>` | Restart a background session |
| `claude rm <id>` | Remove a background session from the list |
| `claude setup-token` | Generate a long-lived OAuth token for CI |
| `claude stop <id>` | Stop a background session |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `-p`, `--print` | Print mode — respond and exit (non-interactive) |
| `-c`, `--continue` | Load most recent conversation in current directory |
| `-r`, `--resume` | Resume session by ID or name |
| `-n`, `--name` | Set a display name for the session |
| `-w`, `--worktree` | Start in an isolated git worktree |
| `--model` | Set model (`sonnet`, `opus`, `haiku`, `fable`, or full ID) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, or `bypassPermissions` |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--add-dir` | Add additional working directories for file access |
| `--allowedTools` | Tools that execute without permission prompts |
| `--disallowedTools` | Deny rules for specific tools |
| `--tools` | Restrict which built-in tools are available |
| `--mcp-config` | Load MCP servers from JSON file or string |
| `--plugin-dir` | Load a plugin from a directory or `.zip` for this session |
| `--system-prompt` | Replace the entire default system prompt |
| `--append-system-prompt` | Append custom text to the default system prompt |
| `--system-prompt-file` | Replace system prompt from a file |
| `--append-system-prompt-file` | Append file contents to the default system prompt |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` |
| `--input-format` | Input format for print mode: `text`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Maximum dollar spend on API calls (print mode only) |
| `--verbose` | Show full turn-by-turn output |
| `--debug` | Enable debug mode with optional category filtering |
| `--debug-file <path>` | Write debug logs to a file |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--safe-mode` | Disable all customizations for troubleshooting (v2.1.169+) |
| `--bg` | Start session as background agent and return immediately |
| `--advisor <model>` | Enable advisor tool for this session (v2.1.98+) |
| `--agent` | Specify a named agent for this session |
| `--settings` | Path to settings JSON or inline JSON string |
| `--fallback-model` | Enable automatic fallback model(s) |
| `--fork-session` | Create a new session ID when resuming |
| `--from-pr` | Resume sessions linked to a pull request |
| `--remote` | Create a new web session on claude.ai |
| `--remote-control`, `--rc` | Enable Remote Control from claude.ai |
| `--teleport` | Resume a web session in local terminal |
| `--teammate-mode` | Set agent team display: `in-process`, `auto`, `tmux`, `iterm2` |
| `--no-session-persistence` | Disable session persistence (print mode only) |
| `--init` | Run Setup hooks with `init` matcher before session |
| `--init-only` | Run Setup and SessionStart hooks, then exit |
| `--ax-screen-reader` | Screen-reader friendly output (v2.1.181+) |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves cache reuse) |
| `-v`, `--version` | Output the version number |

### System Prompt Flags Summary

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can be combined with either replacement flag.

### Slash Commands (in-session)

| Command | Description |
| :--- | :--- |
| `/add-dir <path>` | Add a working directory for file access this session |
| `/advisor [model\|off]` | Enable/disable the advisor tool |
| `/agents` | Manage agent configurations |
| `/autofix-pr [prompt]` | Watch current branch PR and push fixes on CI failure |
| `/background [prompt]` | Detach session to run as background agent |
| `/batch <instruction>` | Orchestrate large parallel codebase changes (Skill) |
| `/branch [name]` | Create a branch of the conversation |
| `/btw <question>` | Ask a side question without adding to conversation |
| `/cd <path>` | Move session to a new working directory (v2.1.169+) |
| `/clear [name]` | Start new conversation with empty context |
| `/code-review [...args]` | Review diff for bugs and cleanups (Skill) |
| `/compact [instructions]` | Summarize conversation to free up context |
| `/config [key=value]` | Open Settings or set a setting directly |
| `/context [all]` | Visualize current context window usage |
| `/copy [N]` | Copy last assistant response to clipboard |
| `/debug [description]` | Enable debug logging and troubleshoot (Skill) |
| `/deep-research <question>` | Fan out web searches and synthesize a report (Workflow) |
| `/diff` | Open interactive diff viewer |
| `/doctor` | Diagnose Claude Code installation and settings |
| `/effort [level\|auto]` | Set model effort level |
| `/exit` | Exit the CLI |
| `/export [filename]` | Export current conversation as plain text |
| `/fast [on\|off]` | Toggle fast mode |
| `/feedback [report]` | Submit feedback or report a bug |
| `/fork <directive>` | Spawn a forked subagent with directive (v2.1.161+) |
| `/goal [condition\|clear]` | Set a goal Claude pursues until met |
| `/help` | Show help and available commands |
| `/hooks` | View hook configurations |
| `/init` | Initialize project with a CLAUDE.md |
| `/keybindings` | Open keyboard shortcuts file |
| `/login` / `/logout` | Sign in / sign out |
| `/mcp [...]` | Manage MCP server connections |
| `/memory` | Edit CLAUDE.md memory files and auto-memory |
| `/model [model]` | Switch the AI model |
| `/permissions` | Manage allow, ask, and deny rules |
| `/plan [description]` | Enter plan mode |
| `/plugin [subcommand]` | Manage plugins |
| `/recap` | Generate one-line summary of current session |
| `/remote-control` | Make session available for remote control |
| `/rename [name]` | Rename current session |
| `/resume [session]` | Resume a conversation by ID or name |
| `/review [PR]` | Review a GitHub pull request |
| `/rewind` | Rewind conversation and/or code to a previous point |
| `/run` | Launch and drive your project's app (Skill, v2.1.145+) |
| `/schedule [description]` | Create/manage routines on cloud infrastructure |
| `/security-review` | Analyze pending changes for security vulnerabilities |
| `/simplify [target]` | Review code for cleanup and apply fixes (Skill, v2.1.154+) |
| `/skills` | List available skills |
| `/status` | Open Settings Status tab |
| `/stop` | Stop the current background session |
| `/tasks` | View and manage background tasks |
| `/teleport` | Pull a cloud session into this terminal |
| `/theme` | Change the color theme |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/ultraplan <prompt>` | Draft a plan in an ultraplan session |
| `/ultrareview [PR]` | Run deep multi-agent code review in the cloud |
| `/usage` | Show session cost, plan limits, and activity stats |
| `/verify` | Confirm a change works in the running app (Skill, v2.1.145+) |
| `/voice [hold\|tap\|off]` | Toggle voice dictation |
| `/workflows` | View workflow progress |

### General Keyboard Shortcuts

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Interrupt or clear input |
| `Ctrl+D` | Exit Claude Code |
| `Esc` | Interrupt Claude (stop current response) |
| `Esc` + `Esc` | Clear input draft, or open rewind menu when input is empty |
| `Shift+Tab` | Cycle permission modes |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open prompt in external text editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+B` | Background running tasks |
| `Ctrl+T` | Toggle task list |
| `Ctrl+V` / `Alt+V` | Paste image from clipboard |
| `Ctrl+X Ctrl+K` | Stop all background subagents in this session |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |

### Text Editing Shortcuts

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+A` | Move cursor to start of current line |
| `Ctrl+E` | Move cursor to end of current line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

### Multiline Input Methods

| Method | Shortcut |
| :--- | :--- |
| Quick escape | `\` + `Enter` (works in all terminals) |
| Control sequence | `Ctrl+J` (works everywhere) |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| VS Code/Cursor/Alacritty/Zed | Run `/terminal-setup` once |

### Quick Input Prefixes

| Prefix | Description |
| :--- | :--- |
| `/` at start | Invoke a command or skill |
| `!` at start | Shell mode: run a shell command directly and add output to context |
| `@` | File path mention / autocomplete |

### Vim Mode Highlights

Enable via `/config` → Editor mode or set `editorMode: "vim"` in settings.

- NORMAL mode entry: `Esc`
- Navigation: `h/j/k/l`, `w/e/b`, `0`, `$`, `gg`, `G`, `f{char}`, `t{char}`
- Editing: `x`, `dd`, `D`, `cc`, `C`, `yy`, `p`, `P`, `u`, `.`
- Text objects with `d/c/y`: `iw/aw`, `i"/a"`, `i(/a(`, `i{/a{`
- Visual modes: `v` (character-wise), `V` (line-wise)

### Built-in Tools Reference

| Tool | Permission Required | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawns a subagent with its own context window |
| `Artifact` | Yes | Publishes HTML/Markdown as a private artifact on claude.ai |
| `AskUserQuestion` | No | Asks multiple-choice questions for clarification |
| `Bash` | Yes | Executes shell commands |
| `CronCreate` | No | Schedules a recurring or one-shot prompt in-session |
| `CronDelete` | No | Cancels a scheduled task by ID |
| `CronList` | No | Lists all scheduled tasks |
| `Edit` | Yes | Makes targeted exact-string edits to files |
| `EnterPlanMode` | No | Switches to plan mode |
| `EnterWorktree` | No | Creates/switches into a git worktree |
| `ExitPlanMode` | Yes | Presents plan for approval and exits plan mode |
| `ExitWorktree` | No | Exits a worktree session |
| `Glob` | No | Finds files by pattern (supports `**` recursion) |
| `Grep` | No | Searches file contents using ripgrep regex syntax |
| `LSP` | No | Code intelligence via language servers |
| `Monitor` | Yes | Watches a background process and reacts to output (v2.1.98+) |
| `NotebookEdit` | Yes | Modifies Jupyter notebook cells by `cell_id` |
| `PowerShell` | Yes | Executes PowerShell commands natively |
| `PushNotification` | No | Sends a desktop/phone push notification |
| `Read` | No | Reads file contents (supports images, PDFs, notebooks) |
| `RemoteTrigger` | No | Creates/manages Routines on claude.ai |
| `SendMessage` | No | Sends a message to an agent team teammate |
| `Skill` | Yes | Executes a skill within the main conversation |
| `TaskCreate` | No | Creates a task in the task list |
| `TaskGet` | No | Retrieves full details for a specific task |
| `TaskList` | No | Lists all tasks |
| `TaskStop` | No | Kills a running background task |
| `TaskUpdate` | No | Updates task status or deletes tasks |
| `ToolSearch` | No | Searches for and loads deferred tools |
| `WebFetch` | Yes | Fetches URL content, converts HTML to Markdown |
| `WebSearch` | Yes | Performs web searches via Anthropic backend |
| `Workflow` | Yes | Runs a dynamic workflow orchestrating many subagents |
| `Write` | Yes | Creates or overwrites files |

### Tool Permission Rule Syntax

| Rule format | Applies to | Details |
| :--- | :--- | :--- |
| `Bash(npm run *)` | Bash, Monitor | Command pattern matching |
| `PowerShell(Get-ChildItem *)` | PowerShell | Command pattern matching |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP | Path pattern matching |
| `Edit(/src/**)` | Edit, Write, NotebookEdit | Path pattern matching |
| `Skill(deploy *)` | Skill | Skill name matching |
| `Agent(Explore)` | Agent | Subagent type matching |
| `WebFetch(domain:example.com)` | WebFetch | Domain matching |
| `WebSearch` | WebSearch | No specifier; allow or deny whole tool |

### Bash Tool Key Limits

| Limit | Default | Override |
| :--- | :--- | :--- |
| Command timeout | 2 minutes (10 min max) | `BASH_DEFAULT_TIMEOUT_MS`, `BASH_MAX_TIMEOUT_MS` |
| Output length | 30,000 characters | `BASH_MAX_OUTPUT_LENGTH` (up to 150,000) |

### Keybindings Configuration

File: `~/.claude/keybindings.json` (open with `/keybindings`). Changes apply without restart.

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

Key contexts: `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Scroll`, `Settings`, `Select`, `Plugin`, `Doctor`

Key action format: `namespace:action` (e.g., `chat:submit`, `app:toggleTodos`). Set a binding to `null` to unbind it.

Reserved (cannot rebind): `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, Caps Lock.

### Terminal Configuration Quick Fixes

| Symptom | Fix |
| :--- | :--- |
| Shift+Enter submits instead of newline | Run `/terminal-setup` (VS Code, Cursor, Zed, Alacritty); use `Ctrl+J` universally |
| Option key shortcuts do nothing on macOS | Enable "Use Option as Meta Key" in terminal settings |
| No alert when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` or use a Notification hook |
| Display flickers or scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Running inside tmux | Add `set -g allow-passthrough on`, `set -s extended-keys on` to `~/.tmux.conf` |

### Custom Themes

Themes live in `~/.claude/themes/<slug>.json`. Select **New custom theme…** in `/theme` to create one interactively.

| Field | Description |
| :--- | :--- |
| `name` | Display label in `/theme` |
| `base` | Starting preset: `dark`, `light`, `dark-daltonized`, `light-daltonized`, `dark-ansi`, `light-ansi` |
| `overrides` | Map of color token names to color values (`#rrggbb`, `rgb()`, `ansi256(n)`, `ansi:<name>`) |

Key color tokens: `claude` (brand accent), `text`, `error`, `success`, `warning`, `promptBorder`, `planMode`, `diffAdded`, `diffRemoved`, `userMessageBackground`

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — All CLI commands and flags, system prompt flag details
- [Commands](references/claude-code-commands.md) — Complete slash command reference, MCP prompts
- [Interactive mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, Vim mode, command history, background tasks, shell mode, prompt suggestions, /btw, task list, session recap
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) — Keybindings config format, all contexts and actions, keystroke syntax, chords, unbinding, reserved shortcuts
- [Configure your terminal](references/claude-code-terminal-config.md) — Multiline input setup, Option key on macOS, terminal bell, tmux config, fullscreen rendering, custom themes, Vim keybindings
- [Tools reference](references/claude-code-tools-reference.md) — All built-in tools, permission rules, tool behavior details for Bash, Edit, Glob, Grep, Read, WebFetch, WebSearch, Monitor, NotebookEdit, Write

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure your terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
