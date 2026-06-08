---
name: cli-doc
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code CLI: launch commands and flags, in-session slash commands, interactive mode keyboard shortcuts, keyboard shortcut customization, terminal configuration, and the built-in tools reference.

## Quick Reference

### Launch Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Non-interactive print mode; exits after response |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install or reinstall native binary (`stable`, `latest`, or version number) |
| `claude auth login` | Sign in (use `--console` for API key billing, `--sso` for SSO) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth state as JSON (`--text` for human-readable) |
| `claude agents` | Open agent view for background sessions |
| `claude attach <id>` | Attach to a background session |
| `claude daemon status` | Print background-session supervisor state |
| `claude daemon stop --any` | Stop the supervisor (add `--keep-workers` to leave sessions running) |
| `claude logs <id>` | Print recent output from a background session |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins (alias: `claude plugins`) |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude remote-control` | Start a Remote Control server |
| `claude respawn <id>` | Restart a background session with its conversation intact |
| `claude rm <id>` | Remove a background session from the list |
| `claude setup-token` | Generate a long-lived OAuth token for CI |
| `claude stop <id>` | Stop a background session (alias: `claude kill`) |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `-p` / `--print` | Non-interactive print mode |
| `-c` / `--continue` | Load most recent conversation |
| `-r` / `--resume` | Resume a session by ID or name |
| `-n` / `--name` | Set a display name for the session |
| `--model` | Set model (`sonnet`, `opus`, or full model ID) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in a permission mode: `default`, `acceptEdits`, `plan`, `auto`, `bypassPermissions` |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Spending cap in dollars (print mode only) |
| `--add-dir` | Add additional working directories |
| `--allowedTools` | Pre-approve tool calls (no permission prompt) |
| `--disallowedTools` | Remove tools from available pool |
| `--tools` | Restrict which built-in tools Claude can use |
| `--system-prompt` | Replace the entire system prompt |
| `--append-system-prompt` | Append to the default system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append to system prompt from file |
| `--mcp-config` | Load MCP servers from JSON files or strings |
| `--plugin-dir` | Load a plugin from a directory or `.zip` |
| `--plugin-url` | Fetch a plugin `.zip` from a URL |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--bg` | Start as a background agent; return immediately |
| `--agent` | Specify an agent for the current session |
| `--worktree` / `-w` | Start in an isolated git worktree |
| `--verbose` | Enable verbose logging (full turn-by-turn output) |
| `--debug` | Enable debug mode with optional category filter |
| `--dangerously-skip-permissions` | Skip permission prompts entirely |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can be combined with either replacement flag. Use append when Claude should still be a coding assistant; use replacement when the identity or permission model differs entirely.

### Key In-Session Commands

| Command | Purpose |
|:--------|:--------|
| `/clear [name]` | Start new conversation (keeps previous in `/resume`). Aliases: `/reset`, `/new` |
| `/compact [instructions]` | Summarize conversation to free up context |
| `/context [all]` | Visualize context usage |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/plan [description]` | Enter plan mode |
| `/effort [level]` | Adjust effort level interactively or by value |
| `/model [model]` | Switch model and save as default |
| `/permissions` | Manage allow/ask/deny rules. Alias: `/allowed-tools` |
| `/resume [session]` | Resume a conversation by ID or name. Alias: `/continue` |
| `/branch [name]` | Fork current conversation to a new branch |
| `/fork <directive>` | Spawn forked background subagent with full conversation context |
| `/background [prompt]` | Detach session as a background agent. Alias: `/bg` |
| `/rewind` | Rewind conversation and/or code to a checkpoint. Aliases: `/checkpoint`, `/undo` |
| `/btw <question>` | Ask a side question without adding to conversation history |
| `/agents` | Manage subagent configurations |
| `/tasks` | View and manage background tasks. Alias: `/bashes` |
| `/skills` | List available skills |
| `/memory` | Edit CLAUDE.md files and manage auto-memory |
| `/hooks` | View hook configurations |
| `/mcp` | Manage MCP server connections |
| `/config` | Open Settings interface. Alias: `/settings` |
| `/status` | Open Settings (Status tab) — works while Claude is responding |
| `/usage` | Show session cost and plan usage. Aliases: `/cost`, `/stats` |
| `/recap` | Generate a one-line summary of the current session |
| `/init` | Initialize project with a CLAUDE.md guide |
| `/doctor` | Diagnose installation and settings |
| `/debug [description]` | Enable debug logging and troubleshoot |
| `/keybindings` | Open keyboard shortcuts file |
| `/theme` | Change color theme |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/add-dir <path>` | Add a working directory for file access |
| `/rename [name]` | Rename the current session |
| `/copy [N]` | Copy last (or Nth-to-last) assistant response to clipboard |
| `/export [filename]` | Export conversation as plain text |
| `/reload-skills` | Re-scan skill directories (added in v2.1.152) |
| `/reload-plugins [--force]` | Reload all active plugins |
| `/code-review [level] [--fix] [--comment] [target]` | Review diff for correctness bugs and cleanups |
| `/simplify [target]` | Review changed code for cleanups and apply fixes |
| `/security-review` | Analyze pending changes for security vulnerabilities |
| `/review [PR]` | Review a pull request locally |
| `/batch <instruction>` | Orchestrate large-scale parallel changes |
| `/goal [condition\|clear]` | Set a goal Claude works toward across turns |
| `/loop [interval] [prompt]` | Run a prompt repeatedly on an interval |
| `/schedule [description]` | Create and manage cloud-hosted routines |
| `/teleport` | Pull a web session into the local terminal. Alias: `/tp` |
| `/remote-control` | Enable remote control from claude.ai. Alias: `/rc` |
| `/voice [hold\|tap\|off]` | Toggle voice dictation |
| `/workflows` | Watch, pause, resume, or save running workflows |

### Built-in Tools

| Tool | Permission | Description |
|:-----|:-----------|:------------|
| `Agent` | No | Spawns a subagent with its own context window |
| `Bash` | Yes | Executes shell commands |
| `Edit` | Yes | Makes targeted string-replacement edits to files |
| `Glob` | No | Finds files by name pattern |
| `Grep` | No | Searches file contents (built on ripgrep) |
| `LSP` | No | Code intelligence: definitions, references, type info |
| `Monitor` | Yes | Runs a background watcher and feeds output to Claude |
| `NotebookEdit` | Yes | Modifies Jupyter notebook cells |
| `PowerShell` | Yes | Executes PowerShell commands (Windows/opt-in) |
| `Read` | No | Reads file contents with line numbers |
| `Skill` | Yes | Executes a skill in the conversation |
| `WebFetch` | Yes | Fetches a URL and extracts content |
| `WebSearch` | Yes | Runs a web search query |
| `Write` | Yes | Creates or overwrites files |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Manage session task checklist |
| `CronCreate` / `CronDelete` / `CronList` | No | Schedule recurring or one-shot prompts |
| `EnterPlanMode` / `ExitPlanMode` | No/Yes | Switch in and out of plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Create and exit isolated git worktrees |
| `PushNotification` | No | Send desktop/phone notification |
| `Workflow` | Yes | Run a dynamic multi-agent workflow |

### Tool Permission Rule Format

| Rule format | Applies to |
|:------------|:-----------|
| `Bash(npm run *)` | Bash, Monitor — command pattern matching |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP — path pattern matching |
| `Edit(/src/**)` | Edit, Write, NotebookEdit — path pattern matching |
| `Skill(deploy *)` | Skill — skill name matching |
| `Agent(Explore)` | Agent — subagent type matching |
| `WebFetch(domain:example.com)` | WebFetch — domain matching |
| `WebSearch` | WebSearch — no specifier, allow/deny whole tool |

### Keyboard Shortcuts

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Interrupt or clear input |
| `Ctrl+D` | Exit Claude Code |
| `Esc` | Interrupt Claude (stops current response, keeps work done) |
| `Esc` + `Esc` | Clear input draft (with text) or open rewind menu (when empty) |
| `Shift+Tab` | Cycle permission modes (`default`, `acceptEdits`, `plan`, `auto`, ...) |
| `Option+P` / `Alt+P` | Switch model without clearing prompt |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running task (tmux users press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open prompt in external editor |
| `Ctrl+V` / `Alt+V` (WSL) | Paste image from clipboard |
| `Ctrl+X Ctrl+K` | Kill all running background subagents |
| `Up` / `Down` | Navigate command history (once cursor is at edge) |
| `\` + `Enter` | Insert newline without submitting (works everywhere) |
| `Ctrl+J` | Insert newline without submitting |
| `Shift+Enter` | Insert newline (native in most modern terminals; run `/terminal-setup` for VS Code/Alacritty/Zed) |

### Keybindings File

Located at `~/.claude/keybindings.json`. Open with `/keybindings`. Changes apply without restarting.

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

Key contexts: `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `Settings`, `Scroll`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Doctor`

Set an action to `null` to unbind it. Reserved shortcuts that cannot be rebound: `Ctrl+C`, `Ctrl+D`, `Ctrl+M`.

### Terminal Configuration

| Issue | Fix |
|:------|:----|
| Shift+Enter submits instead of newline (VS Code, Alacritty, Zed) | Run `/terminal-setup` once |
| Shift+Enter broken inside tmux | Add `set -g allow-passthrough on`, `set -s extended-keys on`, `set -as terminal-features 'xterm*:extkeys'` to `~/.tmux.conf` |
| Option key shortcuts do nothing (macOS) | Enable "Use Option as Meta Key" in terminal settings (iTerm2: Settings → Profiles → Keys; Apple Terminal: Settings → Profiles → Keyboard) |
| No notification when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` in settings, or configure a Notification hook |
| Display flickers / scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |

### Bash Tool Behavior Key Details

- `cd` persists within project/allowed directories; resets to project dir if it would land outside
- Environment variables do NOT persist between commands
- Default timeout: 2 minutes (Claude can request up to 10 min; override with `BASH_DEFAULT_TIMEOUT_MS` / `BASH_MAX_TIMEOUT_MS`)
- Default output cap: 30,000 characters (override with `BASH_MAX_OUTPUT_LENGTH`, max 150,000)
- Long-running commands can be backgrounded with `run_in_background: true`

### Edit Tool Behavior Key Details

- Exact string replacement only — no regex or fuzzy matching
- File must have been Read in the current conversation before editing
- `old_string` must appear exactly once (or use `replace_all: true`)
- Viewing via `cat`, `head`, `tail`, `sed -n`, `grep` also satisfies the read-before-edit check

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — Complete reference for CLI commands and flags, including system prompt flags
- [Commands Reference](references/claude-code-commands.md) — All in-session slash commands, including skills and workflow commands
- [Interactive Mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, vim editor mode, command history, background tasks, shell mode, and `/btw`
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) — Keybindings configuration file, contexts, all available actions, keystroke syntax, chords, and unbinding
- [Configure Your Terminal](references/claude-code-terminal-config.md) — Fix Shift+Enter, Option key shortcuts, terminal bell notifications, tmux config, fullscreen rendering, and custom themes
- [Tools Reference](references/claude-code-tools-reference.md) — All built-in tools, permission requirements, rule formats, and per-tool behavior details

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands Reference: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure Your Terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
