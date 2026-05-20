---
name: cli-doc
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, including commands, flags, keyboard shortcuts, keybindings, terminal configuration, and built-in tools.

## Quick Reference

### CLI launch commands

| Command | Description |
| :------ | :---------- |
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Non-interactive (print) mode — query and exit |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude --bg "task"` | Start as a background agent, return immediately |
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall native binary (`stable`, `latest`, or version) |
| `claude auth login` | Sign in (`--console` for API billing, `--sso` for SSO) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | Open agent view for background sessions (`--json` for scripting) |
| `claude attach <id>` | Attach to a background session |
| `claude stop <id>` | Stop a background session (also `claude kill`) |
| `claude rm <id>` | Remove a background session from the list |
| `claude logs <id>` | Print recent output from a background session |
| `claude respawn <id>` | Restart a background session with conversation intact |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude setup-token` | Generate a long-lived OAuth token for CI/scripts |
| `claude remote-control` | Start a Remote Control server |
| `claude ultrareview [target]` | Run ultrareview non-interactively |
| `claude daemon status` | Print supervisor state for diagnostics |
| `claude auto-mode defaults` | Print auto mode classifier rules as JSON |

### Key CLI flags

| Flag | Description |
| :--- | :---------- |
| `-p`, `--print` | Non-interactive (print) mode |
| `-c`, `--continue` | Load most recent conversation in current directory |
| `-r`, `--resume` | Resume session by ID or name, or open picker |
| `-n`, `--name` | Set display name for the session |
| `-w`, `--worktree` | Start in an isolated git worktree |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in a permission mode: `default`, `acceptEdits`, `plan`, `auto`, `bypassPermissions` |
| `--add-dir` | Add additional working directories |
| `--tools` | Restrict which built-in tools are available |
| `--allowedTools` | Tools that execute without permission prompts |
| `--disallowedTools` | Deny rules for tool calls |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append text to the default system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append file contents to default system prompt |
| `--mcp-config` | Load MCP servers from JSON files or strings |
| `--settings` | Path to a settings JSON file or inline JSON string |
| `--plugin-dir` | Load a plugin from a directory or `.zip` archive |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns in print mode |
| `--max-budget-usd` | Spending cap for print mode API calls |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--debug` | Enable debug mode (optionally filter categories) |
| `--verbose` | Show full turn-by-turn output |
| `--version`, `-v` | Output the version number |

### System prompt flags summary

| Flag | Behavior |
| :--- | :------- |
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags combine with either replacement flag. Use replacement flags when the agent identity differs from Claude Code's; use append flags to add project-specific rules while preserving the default identity.

### In-session commands (key selection)

Commands are typed at the prompt. Type `/` to see all available commands, `/` followed by letters to filter.

| Command | Purpose |
| :------ | :------ |
| `/clear` | Start a new conversation (previous stays in `/resume`) |
| `/compact [instructions]` | Summarize context to free up window space |
| `/context [all]` | Visualize context usage as a colored grid |
| `/plan [description]` | Enter plan mode |
| `/model [model]` | Set model for current session |
| `/effort [level]` | Set effort level interactively |
| `/permissions` | Manage allow/ask/deny rules interactively |
| `/diff` | Open interactive diff viewer |
| `/resume [session]` | Resume a conversation by ID or name |
| `/branch [name]` | Branch the current conversation |
| `/rewind` | Rewind conversation/code to a previous point |
| `/memory` | Edit CLAUDE.md files and manage auto-memory |
| `/mcp` | Manage MCP server connections |
| `/agents` | Manage subagent configurations |
| `/tasks` | List and manage background tasks |
| `/background [prompt]` | Detach session to run as a background agent |
| `/batch <instruction>` | **[Skill]** Parallel large-scale codebase changes |
| `/btw <question>` | Ask a quick side question without adding to history |
| `/goal [condition]` | Set a goal for Claude to work toward across turns |
| `/init` | Initialize project with a CLAUDE.md guide |
| `/simplify [focus]` | **[Skill]** Review and fix code quality in recent files |
| `/review [PR]` | Review a pull request locally |
| `/security-review` | Analyze pending changes for security issues |
| `/run` | **[Skill]** Launch and drive project's app |
| `/verify` | **[Skill]** Confirm a code change works in the running app |
| `/debug [description]` | **[Skill]** Enable debug logging and troubleshoot issues |
| `/config` | Open settings interface (alias: `/settings`) |
| `/theme` | Change color theme |
| `/keybindings` | Open/create keybindings configuration file |
| `/status` | Show version, model, account, connectivity |
| `/usage` | Show session cost and plan usage (aliases: `/cost`, `/stats`) |
| `/doctor` | Diagnose Claude Code installation and settings |
| `/help` | Show help and available commands |
| `/exit` | Exit the CLI (alias: `/quit`) |
| `/schedule` | Create/manage routines on cloud infrastructure |
| `/ultraplan <prompt>` | Draft a plan in an ultraplan session |
| `/ultrareview [PR]` | Deep multi-agent code review in cloud sandbox |
| `/teleport` | Pull a web session into this terminal |
| `/remote-control` | Enable remote control from claude.ai |
| `/voice [hold\|tap\|off]` | Toggle voice dictation |
| `/skills` | List available skills |
| `/copy [N]` | Copy last assistant response to clipboard |
| `/export [filename]` | Export conversation as plain text |
| `/recap` | Generate a one-line session summary on demand |

### Keyboard shortcuts — general controls

| Shortcut | Description |
| :------- | :---------- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+D` | Exit Claude Code session |
| `Esc` | Interrupt Claude (stop response mid-turn) |
| `Esc` + `Esc` | Rewind or summarize |
| `Shift+Tab` | Cycle permission modes |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+L` | Redraw screen |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open in default text editor |
| `Ctrl+B` | Background running tasks |
| `Ctrl+T` | Toggle task list |
| `Ctrl+V` | Paste image from clipboard |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |

### Multiline input methods

| Method | Shortcut | Works in |
| :----- | :------- | :------- |
| Quick escape | `\` + `Enter` | All terminals |
| Control sequence | `Ctrl+J` | All terminals |
| Shift+Enter | `Shift+Enter` | iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal (native); VS Code/Cursor/Alacritty/Zed after `/terminal-setup` |

### Shell mode and quick prefixes

| Prefix | Effect |
| :----- | :----- |
| `/` at prompt start | Command or skill |
| `!` at prompt start | Shell mode — run directly, output added to context |
| `@` | File path mention / autocomplete trigger |

### Vim editor mode highlights

Enable via `/config` → Editor mode or set `editorMode: "vim"` in settings.

**Mode switching:** `Esc` → NORMAL, `i`/`a`/`o` → INSERT, `v`/`V` → VISUAL

**Navigation (NORMAL):** `h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`, `gg`/`G`, `f{char}`/`t{char}`

**Editing (NORMAL):** `dd`, `cc`, `yy`, `p`/`P`, `u` (undo), `.` (repeat), `J` (join), `>>`/`<<`

**Text objects:** `iw`/`aw`, `i"`/`a"`, `i(`/`a(`, `i{`/`a{`

Note: Enter still submits in INSERT mode; use `Ctrl+J` or `o`/`O` in NORMAL mode for newlines.

### Keybindings configuration

File: `~/.claude/keybindings.json` (open with `/keybindings`; changes apply without restart)

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

**Contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Select`, `Scroll`, `DiffDialog`, `ModelPicker`, `Plugin`, `Doctor`, `Footer`, `MessageSelector`, `Tabs`, `Attachments`, `Help`

**Key actions (namespace:action):** `chat:submit`, `chat:newline`, `chat:cycleMode`, `chat:externalEditor`, `chat:imagePaste`, `app:toggleTodos`, `app:toggleTranscript`, `app:interrupt`, `app:exit`, `transcript:exit`, `transcript:toggleShowAll`, `history:search`, `task:background`, `voice:pushToTalk`

Set an action to `null` to unbind it. Chords use space-separated sequences: `ctrl+k ctrl+s`.

**Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, `Caps Lock`

**Terminal conflicts:** `Ctrl+B` (tmux prefix, press twice), `Ctrl+A` (screen prefix), `Ctrl+Z` (SIGTSTP)

### Terminal configuration

| Symptom / Goal | Fix |
| :------------- | :-- |
| Shift+Enter submits instead of newlines | Run `/terminal-setup` in VS Code/Cursor/Alacritty/Zed; for tmux add `extended-keys` config |
| Option key shortcuts do nothing (macOS) | Enable "Use Option as Meta Key" in terminal settings |
| No sound when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` or add a Notification hook |
| Display flickers or scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Paste drops characters (VS Code terminal) | Prefer file-based workflows for large inputs |

**tmux required config** (`~/.tmux.conf`):
```
set -g allow-passthrough on
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'
```

**Custom themes:** stored as JSON in `~/.claude/themes/<slug>.json`. Fields: `name`, `base` (dark/light/dark-daltonized/light-daltonized/dark-ansi/light-ansi), `overrides` (map of color token names to values). Tokens include `claude`, `text`, `success`, `error`, `warning`, `diffAdded`, `diffRemoved`, `promptBorder`, `planMode`, and more. Selected via `/theme`.

### Built-in tools reference

| Tool | Description | Permission Required |
| :--- | :---------- | :------------------ |
| `Agent` | Spawns a subagent in its own context window | No |
| `AskUserQuestion` | Asks multiple-choice questions for clarification | No |
| `Bash` | Executes shell commands | Yes |
| `Edit` | Makes targeted exact-string edits to files | Yes |
| `Write` | Creates or overwrites files | Yes |
| `Read` | Reads file contents with line numbers | No |
| `Glob` | Finds files by name pattern | No |
| `Grep` | Searches file contents (ripgrep regex) | No |
| `LSP` | Code intelligence via language servers | No |
| `Monitor` | Watches a command in background, feeds output lines back | Yes |
| `WebFetch` | Fetches URL, converts HTML to Markdown, extracts with prompt | Yes |
| `WebSearch` | Runs web search, returns titles/URLs | Yes |
| `NotebookEdit` | Modifies Jupyter notebook cells by cell_id | Yes |
| `PowerShell` | Executes PowerShell commands natively | Yes |
| `EnterPlanMode` / `ExitPlanMode` | Switch into/out of plan mode | No / Yes |
| `EnterWorktree` / `ExitWorktree` | Create/switch git worktrees | No |
| `Skill` | Executes a skill within the main conversation | Yes |
| `CronCreate` / `CronDelete` / `CronList` | Schedule recurring/one-shot prompts | No |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | Task list management | No |
| `PushNotification` | Sends desktop or phone push notification | No |
| `RemoteTrigger` | Creates/runs Routines on claude.ai | No |
| `SendMessage` | Sends message to agent team teammate | No |
| `ToolSearch` | Loads deferred tools when tool search is enabled | No |

### Tool permission rule formats

| Rule format | Applies to | Details |
| :---------- | :--------- | :------ |
| `Bash(npm run *)` | Bash, Monitor | Command pattern matching |
| `PowerShell(Get-ChildItem *)` | PowerShell | Command pattern matching |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP | Path pattern matching |
| `Edit(/src/**)` | Edit, Write, NotebookEdit | Path pattern matching |
| `Skill(deploy *)` | Skill | Skill name matching |
| `Agent(Explore)` | Agent | Subagent type matching |
| `WebFetch(domain:example.com)` | WebFetch | Domain matching |
| `WebSearch` | WebSearch | No specifier |

An `Edit(...)` allow rule also grants read access to the same path.

### Bash tool limits

| Limit | Default | Override |
| :---- | :------ | :------- |
| Timeout per command | 2 minutes (Claude can request up to 10 min) | `BASH_DEFAULT_TIMEOUT_MS`, `BASH_MAX_TIMEOUT_MS` |
| Output length | 30,000 characters (hard ceiling: 150,000) | `BASH_MAX_OUTPUT_LENGTH` |

Environment variables do not persist across Bash commands. Working directory changes persist within project or `--add-dir` directories; set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to disable.

### Key tool behaviors

**Edit tool:** exact string replacement; requires prior `Read` of the file; `old_string` must appear exactly once (or use `replace_all: true`).

**Write tool:** creates or overwrites entire file; requires prior `Read` of existing files.

**Glob vs Grep:** Glob finds files by name pattern (does not respect `.gitignore` by default); Grep searches file contents using ripgrep regex (respects `.gitignore`).

**WebFetch:** lossy by design — uses a small model to extract content from pages. Cached for 15 minutes. Prompts on first access to a new domain in default/acceptEdits modes.

**Monitor tool:** requires v2.1.98+. Uses same permission rules as Bash. Not available on Bedrock, Vertex, or Foundry, or when `DISABLE_TELEMETRY` is set.

**Read tool:** handles images (visual content), PDFs (up to 20 pages at a time for long PDFs), and Jupyter notebooks in addition to plain text.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — complete list of CLI commands and flags, system prompt flag guidance
- [Commands](references/claude-code-commands.md) — all in-session commands including bundled skills
- [Interactive Mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, vim editor mode, command history, background tasks, shell mode, side questions, task list, session recap
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) — keybindings file format, all contexts, all actions, keystroke syntax, unbinding, reserved shortcuts
- [Terminal Configuration](references/claude-code-terminal-config.md) — Shift+Enter setup, Option key on macOS, notifications, tmux config, fullscreen rendering, custom themes
- [Tools Reference](references/claude-code-tools-reference.md) — all built-in tools, permission rule syntax, per-tool behavior details

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
