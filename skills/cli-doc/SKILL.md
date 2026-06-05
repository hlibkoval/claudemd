---
name: cli-doc
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code CLI: launch commands and flags, in-session slash commands, interactive mode keyboard shortcuts and features, keybinding customization, terminal configuration, and the built-in tools reference.

## Quick Reference

### Launch Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Non-interactive (print) mode — query and exit |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall native binary (`stable`, `latest`, or version like `2.1.118`) |
| `claude auth login` | Sign in; add `--console` for API key billing |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status (JSON; add `--text` for human-readable) |
| `claude agents` | Open agent view for parallel background sessions |
| `claude attach <id>` | Attach to a background session |
| `claude daemon status` | Show background supervisor state |
| `claude daemon stop --any` | Stop supervisor (add `--keep-workers` to preserve sessions) |
| `claude logs <id>` | Print recent output from a background session |
| `claude stop <id>` | Stop a background session (alias: `claude kill`) |
| `claude rm <id>` | Remove a session from the list (transcript kept) |
| `claude respawn <id>` | Restart a session with conversation intact |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude setup-token` | Generate long-lived OAuth token for CI/scripts |
| `claude remote-control` | Start Remote Control server |
| `claude ultrareview [target]` | Run ultrareview non-interactively |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins (alias: `claude plugins`) |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `-p`, `--print` | Print response without interactive mode |
| `-c`, `--continue` | Load most recent conversation |
| `-r`, `--resume` | Resume session by ID or name |
| `-n`, `--name` | Set display name for the session |
| `-w`, `--worktree` | Start in isolated git worktree |
| `--bg` | Start session as background agent |
| `--model` | Set model for session (`sonnet`, `opus`, or full name) |
| `--effort` | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--bare` | Minimal mode — skips hooks, skills, plugins, MCP, CLAUDE.md |
| `--add-dir` | Add additional working directories for file access |
| `--tools` | Restrict built-in tools (e.g., `"Bash,Edit,Read"` or `""` to disable all) |
| `--allowedTools` | Tools that run without permission prompts |
| `--disallowedTools` | Tools to deny or remove from context |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Max API spend before stopping (print mode only) |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append to system prompt from file |
| `--mcp-config` | Load MCP servers from JSON file or string |
| `--plugin-dir` | Load plugin from directory or `.zip` for this session |
| `--plugin-url` | Fetch plugin `.zip` from URL for this session |
| `--debug` | Enable debug logging (optionally filter: `"api,hooks"`) |
| `--verbose` | Show full turn-by-turn output |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--init-only` | Run Setup and SessionStart hooks then exit |
| `--remote` | Create new web session on claude.ai |
| `--teleport` | Resume a web session in local terminal |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a pull request |
| `--json-schema` | Validate output against JSON Schema (print mode) |
| `--fallback-model` | Fallback model when default is unavailable (print/bg only) |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message for cache reuse |
| `--agent` | Specify agent for the session |
| `--agents` | Define custom subagents dynamically via JSON |

### System Prompt Flags Summary

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default |

`--system-prompt` and `--system-prompt-file` are mutually exclusive; append flags can combine with either.

### Slash Commands Reference

Commands are only recognized at the start of a message. Type `/` to see all, or `/` + letters to filter.

| Command | Purpose |
|:--------|:--------|
| `/add-dir <path>` | Add working directory for the session |
| `/background [prompt]` | Detach session to run as background agent. Alias: `/bg` |
| `/batch <instruction>` | **[Skill]** Decompose large change into parallel subagent work in worktrees |
| `/branch [name]` | Create a conversation branch to try a different direction |
| `/btw <question>` | Ask side question without adding to conversation history |
| `/clear [name]` | Start new conversation, keeping previous in `/resume`. Aliases: `/reset`, `/new` |
| `/code-review [effort] [--fix] [--comment] [target]` | **[Skill]** Review diff for bugs and cleanups |
| `/compact [instructions]` | Summarize conversation to free up context |
| `/config` | Open Settings interface. Alias: `/settings` |
| `/context [all]` | Visualize context usage |
| `/copy [N]` | Copy last assistant response to clipboard |
| `/debug [description]` | **[Skill]** Enable debug logging and troubleshoot |
| `/diff` | Open interactive diff viewer |
| `/doctor` | Diagnose installation and settings |
| `/effort [level\|auto]` | Set model effort level (or interactive slider) |
| `/exit` | Exit CLI. Alias: `/quit` |
| `/export [filename]` | Export conversation as plain text |
| `/fast [on\|off]` | Toggle fast mode |
| `/feedback [report]` | Submit feedback or report bug. Aliases: `/bug`, `/share` |
| `/fork <directive>` | Spawn forked subagent inheriting full conversation |
| `/goal [condition\|clear]` | Set a condition Claude works toward across turns |
| `/hooks` | View hook configurations |
| `/init` | Initialize project with CLAUDE.md guide |
| `/keybindings` | Open keybindings configuration file |
| `/login` | Sign in |
| `/logout` | Sign out |
| `/loop [interval] [prompt]` | **[Skill]** Run prompt repeatedly. Alias: `/proactive` |
| `/mcp` | Manage MCP server connections |
| `/memory` | Edit CLAUDE.md files, enable/disable auto-memory |
| `/model [model]` | Switch AI model and save as default |
| `/permissions` | Manage allow/ask/deny rules. Alias: `/allowed-tools` |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/recap` | Generate one-line session summary |
| `/remote-control` | Enable Remote Control from claude.ai. Alias: `/rc` |
| `/rename [name]` | Rename current session |
| `/resume [session]` | Resume conversation by ID/name. Alias: `/continue` |
| `/review [PR]` | Review a pull request locally |
| `/rewind` | Rewind conversation and/or code. Aliases: `/checkpoint`, `/undo` |
| `/run` | **[Skill]** Launch and drive project app |
| `/sandbox` | Toggle sandbox mode |
| `/schedule [description]` | Create/manage routines on cloud infrastructure. Alias: `/routines` |
| `/security-review` | Analyze pending branch changes for vulnerabilities |
| `/simplify [target]` | **[Skill]** Review changed code for cleanups and apply fixes |
| `/skills` | List available skills |
| `/status` | Open Settings (Status tab) — works while Claude is responding |
| `/stop` | Stop current background session |
| `/tasks` | List and manage background tasks. Alias: `/bashes` |
| `/teleport` | Pull a web session into this terminal. Alias: `/tp` |
| `/terminal-setup` | Configure terminal keybindings (VS Code, Cursor, Alacritty, Zed) |
| `/theme` | Change color theme |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/ultraplan <prompt>` | Draft plan in ultraplan session |
| `/ultrareview [PR]` | Deep multi-agent cloud code review (alias for `/code-review ultra`) |
| `/usage` | Show session cost and plan usage. Aliases: `/cost`, `/stats` |
| `/verify` | **[Skill]** Confirm code change works by running the app |
| `/voice [hold\|tap\|off]` | Toggle voice dictation |
| `/workflows` | Watch, pause, resume running workflows |

### Keyboard Shortcuts

#### General Controls

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Interrupt running operation, or clear input |
| `Ctrl+D` | Exit Claude Code |
| `Esc` | Interrupt Claude (stops current response mid-turn) |
| `Esc` + `Esc` | Clear input draft (or open rewind menu when input is empty) |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+L` | Redraw screen |
| `Ctrl+B` | Background running tasks (tmux users press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+X Ctrl+K` | Kill all running background subagents (press twice within 3s) |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open prompt in external editor |
| `Shift+Tab` | Cycle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |
| `Ctrl+V` / `Alt+V` (WSL) | Paste image from clipboard |

#### Text Editing

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+A` | Move cursor to start of line |
| `Ctrl+E` | Move cursor to end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+Y` (after Ctrl+Y) | Cycle paste history |
| `Alt+B` | Move cursor back one word |
| `Alt+F` | Move cursor forward one word |

#### Multiline Input

| Method | Shortcut |
|:-------|:---------|
| Works everywhere | `\` then Enter; `Ctrl+J` |
| Native (most terminals) | `Shift+Enter` |
| After enabling Option as Meta (macOS) | `Option+Enter` |

#### Quick Input Prefixes

| Prefix | Effect |
|:-------|:-------|
| `/` at start | Invoke a command or skill |
| `!` at start | Shell mode — run command and add output to context |
| `@` | Trigger file path autocomplete |

### Keybindings Configuration

File: `~/.claude/keybindings.json` (run `/keybindings` to open/create)

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

Set an action to `null` to unbind. Changes apply without restart.

#### Key Binding Contexts

| Context | Description |
|:--------|:------------|
| `Global` | Everywhere in the app |
| `Chat` | Main chat input area |
| `Autocomplete` | Autocomplete menu open |
| `Confirmation` | Permission and confirmation dialogs |
| `Transcript` | Transcript viewer |
| `HistorySearch` | History search mode (`Ctrl+R`) |
| `Task` | Background task running |
| `Scroll` | Conversation scrolling in fullscreen mode |
| `DiffDialog` | Diff viewer |
| `ModelPicker` | Model picker |
| `Select` | Generic select/list components |
| `Settings` | Settings menu |
| `Plugin` | Plugin dialog |

#### Important Action Names

| Action | Default | Description |
|:-------|:--------|:------------|
| `chat:submit` | Enter | Submit message |
| `chat:newline` | Ctrl+J | Insert newline without submitting |
| `chat:cycleMode` | Shift+Tab | Cycle permission modes |
| `chat:externalEditor` | Ctrl+G | Open in external editor |
| `chat:imagePaste` | Ctrl+V | Paste image |
| `app:interrupt` | Ctrl+C | Cancel current operation |
| `app:exit` | Ctrl+D | Exit Claude Code |
| `app:toggleTodos` | Ctrl+T | Toggle task list |
| `app:toggleTranscript` | Ctrl+O | Toggle transcript viewer |
| `history:search` | Ctrl+R | Open history search |
| `transcript:exit` | q, Ctrl+C, Esc | Exit transcript view |

Reserved shortcuts that cannot be rebound: `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, `Caps Lock`.

### Terminal Configuration

| Issue | Fix |
|:------|:----|
| Shift+Enter submits (VS Code, Cursor, Alacritty, Zed) | Run `/terminal-setup` |
| Shift+Enter submits inside tmux | Add tmux config below |
| Option shortcuts do nothing on macOS (iTerm2) | Settings → Profiles → Keys → set Option to "Esc+" |
| Option shortcuts do nothing on macOS (Apple Terminal) | Settings → Profiles → Keyboard → "Use Option as Meta Key" |
| Option shortcuts do nothing on macOS (VS Code) | Set `"terminal.integrated.macOptionIsMeta": true` |
| No notification when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` in settings |
| Display flickers/scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Vim keys in prompt | `/config` → Editor mode → vim |

tmux configuration (`~/.tmux.conf`):
```
set -g allow-passthrough on
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'
```

Custom theme files live in `~/.claude/themes/<name>.json`. Fields: `name`, `base` (dark/light/dark-daltonized/light-daltonized/dark-ansi/light-ansi), `overrides` (map of color token names to values).

### Built-in Tools Reference

| Tool | Permission Required | Description |
|:-----|:-------------------|:------------|
| `Agent` | No | Spawns a subagent in its own context window |
| `AskUserQuestion` | No | Asks multiple-choice questions |
| `Bash` | Yes | Executes shell commands |
| `CronCreate` | No | Schedules recurring/one-shot prompt in session |
| `CronDelete` | No | Cancels a scheduled task by ID |
| `CronList` | No | Lists scheduled tasks |
| `Edit` | Yes | Makes targeted edits via exact string replacement |
| `EnterPlanMode` | No | Switches to plan mode |
| `ExitPlanMode` | Yes | Presents plan for approval and exits plan mode |
| `EnterWorktree` | No | Creates/switches into isolated git worktree |
| `ExitWorktree` | No | Exits a worktree session |
| `Glob` | No | Finds files by name pattern |
| `Grep` | No | Searches file contents (built on ripgrep) |
| `LSP` | No | Code intelligence via language servers |
| `Monitor` | Yes | Runs background command and feeds each output line back |
| `NotebookEdit` | Yes | Modifies Jupyter notebook cells |
| `PowerShell` | Yes | Executes PowerShell commands natively |
| `PushNotification` | No | Sends desktop/push notification |
| `Read` | No | Reads file contents with line numbers |
| `RemoteTrigger` | No | Creates/manages Routines on claude.ai |
| `Skill` | Yes | Executes a skill within the conversation |
| `TaskCreate` | No | Creates new task in task list |
| `TaskList` | No | Lists all tasks |
| `TaskUpdate` | No | Updates task status, dependencies, or deletes tasks |
| `TaskStop` | No | Kills a running background task |
| `ToolSearch` | No | Searches for and loads deferred tools |
| `WebFetch` | Yes | Fetches content from URL (converts HTML to Markdown) |
| `WebSearch` | Yes | Searches the web; returns titles and URLs |
| `Workflow` | Yes | Runs a dynamic workflow |
| `Write` | Yes | Creates or overwrites files |

#### Tool Permission Rule Formats

| Rule format | Applies to |
|:------------|:-----------|
| `Bash(npm run *)` | Bash, Monitor (command pattern) |
| `PowerShell(Get-ChildItem *)` | PowerShell (command pattern) |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP (path pattern) |
| `Edit(/src/**)` | Edit, Write, NotebookEdit (path pattern) |
| `Skill(deploy *)` | Skill (name pattern) |
| `Agent(Explore)` | Agent (subagent type) |
| `WebFetch(domain:example.com)` | WebFetch (domain) |
| `WebSearch` | WebSearch (bare name only) |

An `Edit(...)` allow rule also grants read access to the same path.

#### Key Tool Behavior Notes

- **Bash**: `cd` carries over within the project dir; env vars do not persist. Default timeout 2 min (up to 10 min). Output capped at 30,000 chars by default.
- **Edit**: requires read-before-edit; `old_string` must match exactly and appear exactly once (or use `replace_all: true`).
- **Glob**: sorted by modification time, capped at 100 results; does NOT respect `.gitignore` by default.
- **Grep**: respects `.gitignore`; uses ripgrep regex syntax. Output modes: `files_with_matches` (default), `content`, `count`.
- **WebFetch**: lossy — runs extraction prompt against Markdown-converted page. Cached 15 min. Redirects to new host are returned as text, not followed.
- **Monitor**: requires v2.1.98+; uses same permission rules as Bash; not available on Bedrock/Vertex/Foundry.
- **Write**: requires read-before-write for existing files.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — All CLI commands, flags, and system prompt flag details
- [Commands](references/claude-code-commands.md) — Complete slash command reference with workflow context
- [Interactive Mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, Vim mode, command history, background tasks, shell mode, `/btw`, task list, session recap
- [Keybindings](references/claude-code-keybindings.md) — Keybinding configuration file, all contexts, all actions, keystroke syntax, chords, unbinding
- [Terminal Configuration](references/claude-code-terminal-config.md) — Shift+Enter setup, Option key on macOS, terminal bell, tmux config, fullscreen rendering, custom themes
- [Tools Reference](references/claude-code-tools-reference.md) — Complete tool list, permission rules, per-tool behavior details

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
