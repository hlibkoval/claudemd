---
name: cli-doc
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, including CLI commands and flags, in-session commands, interactive mode keyboard shortcuts, keybindings customization, terminal configuration, and built-in tools.

## Quick Reference

### CLI Commands (launch-time)

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode (query and exit) |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude --bg "task"` | Start as background agent |
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall binary (`stable`, `latest`, or version number) |
| `claude auth login` | Sign in (use `--console` for API key billing) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON |
| `claude agents` | Open agent view for background sessions |
| `claude attach <id>` | Attach to a background session |
| `claude stop <id>` | Stop a background session |
| `claude logs <id>` | Print recent output from a background session |
| `claude rm <id>` | Remove a background session from list |
| `claude respawn <id>` | Restart a background session |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude remote-control` | Start Remote Control server |
| `claude daemon status` | Print supervisor state for diagnostics |
| `claude daemon stop --any` | Stop the background-session supervisor |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `-p`, `--print` | Print mode: query and exit (non-interactive) |
| `-c`, `--continue` | Load most recent conversation |
| `-r`, `--resume` | Resume session by ID, name, or picker |
| `-n`, `--name` | Set display name for the session |
| `-w`, `--worktree` | Start in an isolated git worktree |
| `--model` | Set model (`sonnet`, `opus`, `haiku`, `fable`, or full ID) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, or `bypassPermissions` |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--allow-dangerously-skip-permissions` | Add `bypassPermissions` to Shift+Tab cycle without starting in it |
| `--allowedTools` | Tools that run without prompting |
| `--disallowedTools` | Tools to deny or remove from context |
| `--tools` | Restrict which built-in tools are available |
| `--add-dir` | Add additional working directories |
| `--mcp-config` | Load MCP servers from JSON file or string |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config` |
| `--settings` | Path to settings JSON or inline JSON string |
| `--system-prompt` | Replace the entire default system prompt |
| `--system-prompt-file` | Load replacement system prompt from file |
| `--append-system-prompt` | Append text to default system prompt |
| `--append-system-prompt-file` | Append file contents to default system prompt |
| `--output-format` | Output format: `text`, `json`, `stream-json` |
| `--input-format` | Input format: `text`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Maximum API spend before stopping (print mode) |
| `--verbose` | Show full turn-by-turn output |
| `--bare` | Skip hooks, skills, plugins, MCP, CLAUDE.md for fast scripted calls |
| `--safe-mode` | Start with all customizations disabled for troubleshooting |
| `--bg` | Start as background agent |
| `--plugin-dir` | Load a plugin from directory or zip for this session |
| `--plugin-url` | Fetch a plugin zip from URL for this session |
| `--advisor <model>` | Enable the server-side advisor tool (`opus`, `sonnet`, `fable`) |
| `--remote` | Create a new web session on claude.ai |
| `--teleport` | Resume a web session in local terminal |
| `--remote-control`, `--rc` | Enable Remote Control for the session |
| `--chrome` | Enable Chrome browser integration |
| `--worktree`, `-w` | Start in an isolated git worktree |
| `--tmux` | Create tmux session for the worktree |
| `--from-pr` | Resume sessions linked to a pull request |
| `--fork-session` | Create new session ID instead of reusing original on resume |
| `--fallback-model` | Comma-separated fallback model chain |
| `--teammate-mode` | Set agent team display: `in-process`, `auto`, or `tmux` |
| `--effort` | Set effort level for session |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves cache reuse) |
| `--no-session-persistence` | Do not save session to disk (print mode) |
| `--init` | Run Setup hooks with `init` matcher before session |
| `--init-only` | Run Setup and SessionStart hooks, then exit |
| `--include-hook-events` | Include hook events in stream-json output |
| `--json-schema` | Get validated JSON output matching a schema (print mode) |
| `--debug` | Enable debug mode with optional category filter |
| `--debug-file <path>` | Write debug logs to a file |
| `-v`, `--version` | Print version number |

### System Prompt Flags

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Use append flags when Claude should remain a coding assistant with extra rules; use replacement flags when the identity differs entirely from Claude Code's defaults.

### In-Session Commands (slash commands)

Type `/` to see all available commands. Key commands by workflow phase:

**Setup:** `/init`, `/memory`, `/mcp`, `/agents`, `/permissions`

**During a task:** `/plan`, `/model`, `/effort`, `/context`, `/compact`, `/btw`

**Parallel work:** `/agents`, `/tasks`, `/background`, `/batch`, `/fork`

**Before shipping:** `/diff`, `/code-review [--fix] [--comment]`, `/review`, `/security-review`

**Between sessions:** `/clear`, `/resume`, `/branch`, `/teleport`, `/remote-control`

**Troubleshooting:** `/rewind`, `/doctor`, `/debug`, `/feedback`

Selected commands:

| Command | Purpose |
| :--- | :--- |
| `/add-dir <path>` | Add working directory for file access |
| `/advisor [model\|off]` | Enable/disable advisor tool |
| `/background [prompt]` | Detach session as background agent |
| `/batch <instruction>` | Orchestrate large-scale parallel changes |
| `/branch [name]` | Fork conversation at current point |
| `/btw <question>` | Ask a side question without polluting context |
| `/cd <path>` | Move session to a new working directory |
| `/clear [name]` | Start new conversation, keep project memory |
| `/code-review [effort] [--fix] [--comment]` | Review diff for bugs and cleanups |
| `/compact [instructions]` | Summarize conversation to free context |
| `/config [key=value]` | Open settings or set a value directly |
| `/context [all]` | Visualize context usage |
| `/copy [N]` | Copy last (or Nth) assistant response |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings |
| `/effort [level\|auto]` | Set model effort level |
| `/export [filename]` | Export conversation as plain text |
| `/fork <directive>` | Spawn forked subagent that inherits conversation |
| `/goal [condition\|clear]` | Set a goal; Claude works until condition is met |
| `/hooks` | View hook configurations |
| `/init` | Initialize project CLAUDE.md |
| `/keybindings` | Open keybindings config file |
| `/loop [interval] [prompt]` | Run a prompt repeatedly |
| `/mcp` | Manage MCP server connections |
| `/memory` | Edit CLAUDE.md, manage auto-memory |
| `/model [model]` | Switch AI model |
| `/permissions` | Manage allow/ask/deny rules |
| `/plan [description]` | Enter plan mode |
| `/plugin [subcommand]` | Manage plugins |
| `/recap` | Generate one-line session summary |
| `/reload-plugins [--force]` | Reload active plugins |
| `/reload-skills` | Re-scan skill directories |
| `/remote-control` | Enable Remote Control from claude.ai |
| `/rename [name]` | Rename current session |
| `/resume [session]` | Resume conversation by ID/name or picker |
| `/review [PR]` | Review a pull request locally |
| `/rewind` | Rewind conversation/code to a previous point |
| `/schedule [description]` | Create/manage routines on cloud infrastructure |
| `/security-review` | Review pending changes for security issues |
| `/simplify [target]` | Review changed code for cleanup and apply fixes |
| `/skills` | List available skills |
| `/stop` | Stop the current background session |
| `/tasks` | View/manage background tasks |
| `/teleport` | Pull a web session into local terminal |
| `/theme` | Change color theme |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/ultraplan <prompt>` | Draft a plan and optionally execute remotely |
| `/usage` | Show session cost and plan usage limits |
| `/workflows` | Watch running/completed workflows |

### Interactive Mode Keyboard Shortcuts

**General controls:**

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Interrupt, or clear input |
| `Ctrl+D` | Exit Claude Code |
| `Esc` | Interrupt Claude mid-response |
| `Esc` + `Esc` | Clear input draft, or open rewind menu |
| `Shift+Tab` | Cycle permission modes |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+B` | Background running tasks |
| `Ctrl+T` | Toggle task list |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open in external editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+V` (or `Alt+V` on WSL) | Paste image from clipboard |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |
| `Ctrl+X Ctrl+K` | Stop all background subagents |

**Text editing:**

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
| Works everywhere | `\` + `Enter` or `Ctrl+J` |
| Most modern terminals | `Shift+Enter` (native) |
| VS Code / Cursor / Alacritty / Zed | Run `/terminal-setup` once |
| macOS Option key | `Option+Enter` (requires Option as Meta) |

**Quick input prefixes:**

| Prefix | Behavior |
| :--- | :--- |
| `/` | Command or skill |
| `!` | Shell mode — run directly and add output to session |
| `@` | File path autocomplete |

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

Set an action to `null` to unbind it. Changes apply live without restart.

**Contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Scroll`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Doctor`, and more.

**Key action categories:** `app:*`, `chat:*`, `history:*`, `autocomplete:*`, `confirm:*`, `transcript:*`, `historySearch:*`, `task:*`, `scroll:*`, `selection:*`, `modelPicker:*`, `voice:*`, `plugin:*`, `settings:*`.

Reserved shortcuts (cannot be rebound): `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, `Caps Lock`.

Terminal multiplexer conflicts: `Ctrl+B` (tmux prefix — press twice), `Ctrl+A` (screen prefix), `Ctrl+Z` (SIGTSTP).

### Terminal Configuration

| Symptom | Fix |
| :--- | :--- |
| Shift+Enter submits instead of newline | Run `/terminal-setup` in VS Code/Cursor/Alacritty/Zed; or add `set -s extended-keys on` for tmux |
| Option-key shortcuts do nothing (macOS) | Enable "Use Option as Meta Key" in terminal settings |
| No bell/notification when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` in settings, or add a Notification hook |
| Display flickers or scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| tmux breaks Shift+Enter and notifications | Add `set -g allow-passthrough on`, `set -s extended-keys on`, `set -as terminal-features 'xterm*:extkeys'` to `~/.tmux.conf` |

**Custom themes:** JSON files in `~/.claude/themes/`. Fields: `name` (string), `base` (preset name), `overrides` (map of color token → color value). Tokens include `claude`, `text`, `error`, `success`, `warning`, `planMode`, `diffAdded`, `diffRemoved`, and more. Select **New custom theme…** in `/theme` to create one interactively.

### Built-in Tools Reference

| Tool | Permission Required | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawn a subagent in a separate context window |
| `Artifact` | Yes | Publish HTML/Markdown as a private interactive page on claude.ai |
| `AskUserQuestion` | No | Ask multiple-choice questions to gather requirements |
| `Bash` | Yes | Execute shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Schedule recurring or one-shot prompts within the session |
| `Edit` | Yes | Make targeted string-replacement edits to files |
| `EnterPlanMode` | No | Switch to plan mode |
| `ExitPlanMode` | Yes | Present plan for approval and exit plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Create and switch into isolated git worktrees |
| `Glob` | No | Find files by name pattern |
| `Grep` | No | Search file contents with ripgrep regex |
| `LSP` | No | Code intelligence: definitions, references, type errors |
| `Monitor` | Yes | Watch a command in background and react to each output line |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `PowerShell` | Yes | Execute PowerShell commands natively |
| `PushNotification` | No | Send desktop or phone push notification |
| `Read` | No | Read file contents (also handles images, PDFs, notebooks) |
| `RemoteTrigger` | No | Create/run Routines on claude.ai |
| `Skill` | Yes | Execute a skill within the main conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Manage session task checklist |
| `ToolSearch` | No | Search for and load deferred tools (when tool search is enabled) |
| `WebFetch` | Yes | Fetch URL, convert HTML to Markdown, extract with a prompt |
| `WebSearch` | Yes | Search with Anthropic's backend; does not fetch pages |
| `Workflow` | Yes | Run a dynamic workflow script across many subagents |
| `Write` | Yes | Create or overwrite files |

**Permission rule syntax** for tools in `allow`/`deny` lists:

| Rule format | Applies to |
| :--- | :--- |
| `Bash(npm run *)` | Bash, Monitor — command pattern |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP — path pattern |
| `Edit(/src/**)` | Edit, Write, NotebookEdit — path pattern |
| `WebFetch(domain:example.com)` | WebFetch — domain matching |
| `Skill(deploy *)` | Skill — skill name matching |
| `Agent(Explore)` | Agent — subagent type matching |
| `WebSearch` | WebSearch — bare name only |

**Bash tool notes:**
- `cd` persists across Bash calls when staying inside the project or additional directories.
- Environment variables do not persist between commands.
- Default timeout: 2 minutes (up to 10 min via `timeout` parameter). Output limit: 30,000 characters.
- Set `run_in_background: true` for long-running processes.

**Edit tool:** Performs exact string replacement. Requires a prior `Read` of the file. `old_string` must appear exactly once (or use `replace_all: true`).

**Glob tool:** Results sorted by modification time, capped at 100 files. Does not respect `.gitignore` by default (set `CLAUDE_CODE_GLOB_NO_IGNORE=false` to change).

**Grep tool:** Built on ripgrep. Output modes: `files_with_matches` (default), `content`, `count`. Respects `.gitignore`.

**WebFetch tool:** Converts HTML to Markdown via a small model. Lossy by design. Caches responses for 15 minutes. HTTP auto-upgrades to HTTPS. Redirects to different hosts are not auto-followed.

**WebSearch tool:** Issues up to 8 backend searches per call. Does not fetch pages — Claude follows up with WebFetch. Available on Claude API and Microsoft Foundry; not on Amazon Bedrock.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — complete CLI commands and flags reference
- [Commands](references/claude-code-commands.md) — all in-session slash commands
- [Interactive Mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, Vim mode, shell mode, task list, session recap
- [Keybindings](references/claude-code-keybindings.md) — customize keyboard shortcuts via `~/.claude/keybindings.json`
- [Terminal Configuration](references/claude-code-terminal-config.md) — Shift+Enter, Option key, tmux, fullscreen rendering, custom themes
- [Tools Reference](references/claude-code-tools-reference.md) — all built-in tools, permission rules, and per-tool behavior

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
