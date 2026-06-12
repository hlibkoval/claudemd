---
name: cli-doc
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code CLI — launch commands, flags, in-session commands, keyboard shortcuts, keybinding customization, terminal configuration, and the full built-in tools reference.

## Quick Reference

### Launch Commands

| Command | Description |
| :------ | :---------- |
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode: run query and exit (Agent SDK) |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall binary (`stable`, `latest`, or version like `2.1.118`) |
| `claude auth login` | Sign in (`--console` for API billing, `--sso` for SSO) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | Open agent view to monitor background sessions |
| `claude attach <id>` | Attach to a background session |
| `claude bg <id>` | Start session as background agent |
| `claude stop <id>` | Stop a background session |
| `claude logs <id>` | Print recent output from a background session |
| `claude respawn <id>` | Restart a background session with conversation intact |
| `claude rm <id>` | Remove a background session from the list |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins (alias: `claude plugins`) |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude remote-control` | Start a Remote Control server |
| `claude setup-token` | Generate a long-lived OAuth token for CI/scripts |
| `claude daemon status` | Print background-session supervisor state |
| `claude daemon stop --any` | Stop the supervisor and its sessions |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

### Key CLI Flags

| Flag | Description |
| :--- | :---------- |
| `--print`, `-p` | Print mode (non-interactive; see Agent SDK docs) |
| `--continue`, `-c` | Load most recent conversation in current directory |
| `--resume`, `-r` | Resume session by ID or name (or open picker) |
| `--name`, `-n` | Set display name for the session |
| `--model` | Set model (`sonnet`, `opus`, `haiku`, `fable`, or full model ID) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--output-format` | Print mode output format: `text`, `json`, `stream-json` |
| `--input-format` | Print mode input format: `text`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Max API spend before stopping (print mode only) |
| `--allowedTools` | Tools that run without permission prompts |
| `--disallowedTools` | Deny rules for tools |
| `--tools` | Restrict which built-in tools Claude can use |
| `--system-prompt` | Replace the entire default system prompt |
| `--system-prompt-file` | Replace with file contents |
| `--append-system-prompt` | Append text to the default prompt |
| `--append-system-prompt-file` | Append file contents to the default prompt |
| `--mcp-config` | Load MCP servers from JSON files or strings |
| `--add-dir` | Add additional working directories |
| `--plugin-dir` | Load a plugin from directory or zip for this session |
| `--plugin-url` | Fetch a plugin zip from URL for this session |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--bg` | Start as a background agent (returns immediately) |
| `--bare` | Minimal mode: skip auto-discovery of hooks, skills, plugins, MCP, etc. |
| `--safe-mode` | Start with all customizations disabled for troubleshooting |
| `--debug` | Enable debug mode with optional category filtering |
| `--debug-file <path>` | Write debug logs to a file |
| `--verbose` | Enable verbose logging (full turn-by-turn output) |
| `--advisor <model>` | Enable server-side advisor tool (`opus`, `sonnet`, `fable`, or full model ID) |
| `--fallback-model` | Comma-separated fallback model chain |
| `--fork-session` | When resuming, create a new session ID |
| `--from-pr` | Resume sessions linked to a specific PR |
| `--agent` | Specify an agent for the current session |
| `--agents` | Define custom subagents dynamically via JSON |
| `--remote` | Create a new web session on claude.ai |
| `--teleport` | Resume a web session in your local terminal |
| `--chrome` | Enable Chrome browser integration |
| `--teammate-mode` | Set agent team display: `auto`, `in-process`, or `tmux` |
| `--json-schema` | Get validated JSON output matching a JSON Schema (print mode) |
| `--exclude-dynamic-system-prompt-sections` | Improve prompt-cache reuse across users/machines |
| `--settings` | Path to settings JSON file or inline JSON string |
| `--version`, `-v` | Output version number |

### System Prompt Flags

| Flag | Behavior |
| :--- | :------- |
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag.

### Built-in Tools

| Tool | Permission Required | Description |
| :--- | :------------------ | :---------- |
| `Agent` | No | Spawns a subagent with its own context window |
| `AskUserQuestion` | No | Asks multiple-choice questions |
| `Bash` | Yes | Executes shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Schedule recurring or one-shot prompts in session |
| `Edit` | Yes | Makes targeted edits to files (exact string replacement) |
| `EnterPlanMode` / `ExitPlanMode` | No / Yes | Switch to/from plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Create/switch isolated git worktrees |
| `Glob` | No | Finds files by name pattern |
| `Grep` | No | Searches file contents (ripgrep-based) |
| `LSP` | No | Code intelligence via language servers |
| `Monitor` | Yes | Watch something in the background, react to output |
| `NotebookEdit` | Yes | Modifies Jupyter notebook cells |
| `PowerShell` | Yes | Executes PowerShell commands natively |
| `PushNotification` | No | Sends desktop/phone notification |
| `Read` | No | Reads file contents (with images, PDFs, notebooks) |
| `Skill` | Yes | Executes a skill within the main conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Task list management |
| `WebFetch` | Yes | Fetches URL content (converts to Markdown, extracts with small model) |
| `WebSearch` | Yes | Searches via Anthropic web search backend |
| `Workflow` | Yes | Runs a dynamic workflow orchestrating subagents |
| `Write` | Yes | Creates or overwrites files |
| `SendMessage` | No | Sends message to agent team teammate (experimental) |

Permission rule formats: `Bash(npm run *)`, `Edit(/src/**)`, `Read(~/secrets/**)`, `WebFetch(domain:example.com)`, `Skill(deploy *)`, `Agent(Explore)`.

### In-Session Commands (Key Selection)

Type `/` to see all commands. Selected highlights:

| Command | Description |
| :------ | :---------- |
| `/clear [name]` | Start new conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Summarize conversation to free context |
| `/context [all]` | Visualize context usage |
| `/model [model]` | Switch AI model |
| `/effort [level]` | Set effort level (`low`–`max`, `ultracode`) |
| `/plan [description]` | Enter plan mode |
| `/permissions` | Manage allow/ask/deny rules |
| `/memory` | Edit CLAUDE.md files, manage auto-memory |
| `/resume [session]` | Resume a conversation by ID or name |
| `/branch [name]` | Fork the conversation at this point |
| `/fork <directive>` | Spawn a forked background subagent |
| `/rewind` | Rewind conversation/code to a previous point |
| `/diff` | Interactive diff viewer |
| `/code-review [level] [--fix] [--comment]` | Review diff for bugs and cleanups |
| `/simplify [target]` | Cleanup-only review, applies fixes |
| `/security-review` | Analyze pending changes for security vulnerabilities |
| `/background [prompt]` | Detach session to run as background agent |
| `/tasks` | View/manage background tasks |
| `/btw <question>` | Ask a side question without adding to history |
| `/batch <instruction>` | Orchestrate large-scale changes in parallel |
| `/add-dir <path>` | Add a working directory for this session |
| `/cd <path>` | Move session to a new working directory (v2.1.169+) |
| `/init` | Initialize project with a CLAUDE.md guide |
| `/config` | Open Settings interface (alias: `/settings`) |
| `/theme` | Change color theme |
| `/keybindings` | Open keyboard shortcuts file |
| `/hooks` | View hook configurations |
| `/mcp` | Manage MCP server connections |
| `/agents` | Manage agent configurations |
| `/skills` | List available skills |
| `/plugin [subcommand]` | Manage plugins |
| `/doctor` | Diagnose Claude Code installation |
| `/debug [description]` | Enable debug logging and troubleshoot |
| `/usage` | Show session cost, plan usage, activity stats |
| `/copy [N]` | Copy last assistant response to clipboard |
| `/export [filename]` | Export conversation as plain text |
| `/recall` | Generate a one-line session summary |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/goal [condition\|clear]` | Set a goal Claude works toward across turns |
| `/loop [interval] [prompt]` | Run a prompt repeatedly (alias: `/proactive`) |
| `/ultraplan <prompt>` | Draft a plan, review in browser, then execute |
| `/teleport` | Pull a web session into this terminal |
| `/remote-control` | Enable remote control from claude.ai |
| `/schedule [description]` | Create/manage routines on cloud infrastructure |

### Keyboard Shortcuts

**General controls:**

| Shortcut | Description |
| :------- | :---------- |
| `Ctrl+C` | Interrupt or clear input |
| `Ctrl+D` | Exit Claude Code |
| `Esc` | Interrupt Claude (stop current response mid-turn) |
| `Esc` + `Esc` | Clear input draft, or open rewind menu |
| `Shift+Tab` | Cycle permission modes |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running tasks |
| `Ctrl+T` | Toggle task list |
| `Ctrl+L` | Redraw screen |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open prompt in external editor |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |

**Multiline input:**

| Method | Shortcut |
| :----- | :------- |
| Quick escape | `\` + `Enter` (works everywhere) |
| Control sequence | `Ctrl+J` (works everywhere) |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| VS Code / Cursor / Alacritty / Zed | Run `/terminal-setup` once |

**Transcript viewer (Ctrl+O to open):**

| Shortcut | Description |
| :------- | :---------- |
| `Ctrl+E` | Toggle show all content |
| `{` / `}` | Jump to previous/next user prompt (fullscreen only) |
| `[` | Write conversation to terminal scrollback (fullscreen only) |
| `q`, `Ctrl+C`, `Esc` | Exit transcript view |

### Custom Keybindings

File: `~/.claude/keybindings.json`. Open with `/keybindings`.

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

Actions follow `namespace:action` format (e.g., `chat:submit`, `app:toggleTodos`). Set to `null` to unbind. Changes apply without restarting. Reserved shortcuts (`Ctrl+C`, `Ctrl+D`, `Ctrl+M`, `Caps Lock`) cannot be rebound.

**Available contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Scroll`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Doctor`

### Terminal Configuration

| Symptom | Fix |
| :------ | :-- |
| Shift+Enter submits instead of newlines in VS Code/Cursor/Alacritty/Zed | Run `/terminal-setup` once |
| Option key shortcuts do nothing on macOS | Enable "Use Option as Meta Key" in terminal settings |
| No sound when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` in settings, or configure a Notification hook |
| Flickering display or scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Running inside tmux | Add to `~/.tmux.conf`: `set -g allow-passthrough on` + `set -s extended-keys on` + `set -as terminal-features 'xterm*:extkeys'` |

**Custom themes:** JSON files in `~/.claude/themes/`. Create interactively with `/theme` → "New custom theme…". Fields: `name`, `base` (dark/light/daltonized/ansi), `overrides` (color token map). Color values: `#rrggbb`, `rgb(r,g,b)`, `ansi256(n)`, or `ansi:<name>`.

### Key Tool Behaviors

**Bash:** `cd` persists within project directory. Environment variables do not persist across calls. Default timeout: 2 minutes (up to 10 with `timeout` param). Default output limit: 30,000 characters (raise with `BASH_MAX_OUTPUT_LENGTH`, ceiling 150,000).

**Edit:** Performs exact string replacement. Requires read-before-edit. `old_string` must appear exactly once (or use `replace_all: true`).

**Glob:** Supports `**` recursive matching. Results capped at 100 files. Does not respect `.gitignore` by default.

**Grep:** Built on ripgrep. Output modes: `files_with_matches` (default), `content`, `count`. Respects `.gitignore`.

**WebFetch:** Converts HTML to Markdown via small model extraction. HTTP auto-upgraded to HTTPS. Responses cached 15 minutes. Does not follow cross-host redirects (returns redirect info instead).

**Write:** Creates or overwrites entire file. Must have read existing file before overwriting. Use Edit for partial changes.

**NotebookEdit:** Targets cells by `cell_id`. Modes: `replace` (default), `insert`, `delete`.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — All CLI commands and flags
- [Commands](references/claude-code-commands.md) — All in-session slash commands
- [Interactive Mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, Vim mode, command history, background tasks, shell mode
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) — Keybinding configuration file, all actions, contexts, keystroke syntax
- [Terminal Configuration](references/claude-code-terminal-config.md) — Multiline input, Option key, notifications, tmux, fullscreen rendering, custom themes, Vim mode
- [Tools Reference](references/claude-code-tools-reference.md) — All built-in tools, permission rules, and per-tool behavior details

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
