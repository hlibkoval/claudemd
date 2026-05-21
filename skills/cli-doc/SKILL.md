---
name: cli-doc
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, including CLI commands and flags, in-session commands, interactive mode shortcuts, keyboard customization, terminal configuration, and the built-in tools reference.

## Quick Reference

### Starting a Session

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start with an initial prompt |
| `claude -p "query"` | Non-interactive print mode (SDK) |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation |
| `claude -r "<name>"` | Resume session by ID or name |
| `claude --bg "task"` | Start as background agent |

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `--print`, `-p` | Non-interactive mode; print response and exit |
| `--model` | Set model (e.g. `claude-sonnet-4-6`, `sonnet`, `opus`) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Begin in a mode: `default`, `acceptEdits`, `plan`, `auto`, `bypassPermissions` |
| `--output-format` | `text`, `json`, or `stream-json` (print mode) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Spending cap in dollars (print mode) |
| `--add-dir` | Add extra working directories for file access |
| `--system-prompt` | Replace entire default system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--tools` | Restrict which built-in tools are available |
| `--allowedTools` | Tools that skip permission prompts |
| `--disallowedTools` | Tools to deny |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--mcp-config` | Load MCP servers from a JSON file |
| `--plugin-dir` | Load a plugin from a directory or zip archive |
| `--resume`, `-r` | Resume a session by ID or name |
| `--continue`, `-c` | Load the most recent conversation |
| `--fork-session` | Create a new session ID when resuming |
| `--name`, `-n` | Set a display name for the session |
| `--worktree`, `-w` | Start in an isolated git worktree |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--verbose` | Show full turn-by-turn output |
| `--debug` | Enable debug mode |

### System Prompt Flags

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag.

### Top-Level Subcommands

| Command | Description |
| :--- | :--- |
| `claude auth login` | Sign in (use `--console` for API key billing) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth state as JSON |
| `claude update` | Update to latest version |
| `claude install [version]` | Install or reinstall the binary |
| `claude agents` | Open agent view (use `--json` for scripting) |
| `claude attach <id>` | Attach to a background session |
| `claude logs <id>` | Print output from a background session |
| `claude stop <id>` | Stop a background session |
| `claude rm <id>` | Remove a background session from the list |
| `claude respawn <id>` | Restart a session (use `--all` for all running) |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude setup-token` | Generate a long-lived OAuth token for CI |
| `claude remote-control` | Start a Remote Control server |
| `claude daemon status` | Print supervisor state and diagnostics |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

### In-Session Commands (Slash Commands)

Type `/` to see all available commands. Key commands by workflow stage:

**Setup:** `/init`, `/memory`, `/mcp`, `/agents`, `/permissions`

**During a task:** `/plan`, `/model`, `/effort`, `/compact`, `/context`, `/btw`

**Parallel work:** `/agents`, `/tasks`, `/background`, `/batch`

**Before shipping:** `/diff`, `/simplify`, `/review`, `/security-review`

**Between sessions:** `/clear`, `/resume`, `/branch`, `/teleport`, `/remote-control`

**Troubleshooting:** `/rewind`, `/doctor`, `/debug`, `/feedback`

#### Selected Command Reference

| Command | Purpose |
| :--- | :--- |
| `/clear [name]` | Start new conversation (preserves previous in `/resume`) |
| `/compact [instructions]` | Summarize conversation to free context |
| `/context [all]` | Visualize context window usage |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/effort [level]` | Set model effort level interactively |
| `/model [model]` | Set AI model for this session |
| `/plan [description]` | Enter plan mode |
| `/permissions` | Manage allow/ask/deny tool rules |
| `/resume [session]` | Resume a conversation by ID or name |
| `/rewind` | Roll back code and conversation to a checkpoint |
| `/btw <question>` | Ask a side question without adding to conversation history |
| `/background [prompt]` | Detach session to run as background agent |
| `/batch <instruction>` | Orchestrate large-scale parallel changes (Skill) |
| `/simplify [focus]` | Review and fix recently changed files (Skill) |
| `/run` | Launch and drive the project app (Skill, v2.1.145+) |
| `/verify` | Confirm a change works in the running app (Skill, v2.1.145+) |
| `/loop [interval] [prompt]` | Run a prompt repeatedly on a schedule (Skill) |
| `/goal [condition]` | Set a goal; Claude keeps working until it's met |
| `/copy [N]` | Copy last assistant response to clipboard |
| `/export [filename]` | Export conversation as plain text |
| `/usage` | Show session cost, plan limits, and activity stats |
| `/config` | Open settings interface |
| `/skills` | List available skills |

### Interactive Mode Keyboard Shortcuts

#### General Controls

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Interrupt or clear input |
| `Ctrl+D` | Exit Claude Code |
| `Esc` | Interrupt Claude (stop current response mid-turn) |
| `Esc` + `Esc` | Clear input draft, or open rewind menu when input is empty |
| `Shift+Tab` | Cycle permission modes (`default` → `acceptEdits` → `plan` → ...) |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+L` | Redraw screen |
| `Ctrl+B` | Background running tasks |
| `Ctrl+T` | Toggle task list |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open prompt in external text editor |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |

#### Text Editing

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+A` | Move cursor to start of line |
| `Ctrl+E` | Move cursor to end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

#### Multiline Input Methods

| Method | Shortcut |
| :--- | :--- |
| Universal | `\` + `Enter` or `Ctrl+J` |
| Most modern terminals | `Shift+Enter` (native) |
| After `/terminal-setup` | `Shift+Enter` in VS Code, Cursor, Windsurf, Alacritty, Zed |

#### Quick Prefixes

| Prefix | Effect |
| :--- | :--- |
| `/` | Command or skill |
| `!` | Shell mode: run command directly and add output to session |
| `@` | File path autocomplete |

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

Changes are applied automatically without restart. Set a binding to `null` to unbind it.

**Available contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Select`, `Plugin`, `Scroll`, `Doctor`, and more.

**Key action categories:** `app:*`, `chat:*`, `history:*`, `autocomplete:*`, `confirm:*`, `transcript:*`, `scroll:*`, `selection:*`, `voice:*`, `plugin:*`, `settings:*`

**Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`

### Terminal Configuration Quick Reference

| Symptom / Goal | Solution |
| :--- | :--- |
| Shift+Enter submits instead of newline | Run `/terminal-setup` in VS Code, Cursor, Windsurf, Alacritty, Zed; or use `Ctrl+J` in any terminal |
| Option key shortcuts do nothing (macOS) | Enable "Use Option as Meta Key" in terminal settings |
| No notification when Claude finishes | Set `preferredNotifChannel` to `"terminal_bell"`, or add a Notification hook |
| Display flickers or scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Vim keys in prompt | Enable via `/config` → Editor mode |
| tmux: Shift+Enter broken or no notifications | Add `set -g allow-passthrough on`, `set -s extended-keys on`, `set -as terminal-features 'xterm*:extkeys'` to `~/.tmux.conf` |

Custom themes: place JSON files in `~/.claude/themes/`. Each file has optional `name`, `base` (preset), and `overrides` (color token map) fields. Select via `/theme` → **New custom theme…**.

### Built-In Tools Reference

| Tool | Permission | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawns a subagent with its own context window |
| `AskUserQuestion` | No | Asks multiple-choice questions |
| `Bash` | Yes | Executes shell commands |
| `Edit` | Yes | Targeted exact-string file edits |
| `Write` | Yes | Creates or overwrites files |
| `Read` | No | Reads file contents (supports images, PDFs, notebooks) |
| `Glob` | No | Finds files by name pattern |
| `Grep` | No | Searches file contents (ripgrep regex) |
| `LSP` | No | Code intelligence (jump-to-def, find-refs, type errors) |
| `Monitor` | Yes | Watches a command in background; feeds each output line to Claude |
| `NotebookEdit` | Yes | Edits Jupyter notebook cells by `cell_id` |
| `PowerShell` | Yes | Executes PowerShell commands (Windows-primary; opt-in on Linux/macOS) |
| `WebFetch` | Yes | Fetches a URL and extracts content via a small model |
| `WebSearch` | Yes | Queries Anthropic's web search backend |
| `Skill` | Yes | Executes a skill in the main conversation |
| `TaskCreate/Get/List/Update/Stop` | No | Manages session task list |
| `CronCreate/Delete/List` | No | Schedules recurring or one-shot prompts |
| `EnterPlanMode` / `ExitPlanMode` | No/Yes | Plan mode control |
| `EnterWorktree` / `ExitWorktree` | No | Git worktree management |

#### Tool Permission Rule Formats

| Rule | Applies to |
| :--- | :--- |
| `Bash(npm run *)` | Bash, Monitor — command pattern |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP — path pattern |
| `Edit(/src/**)` | Edit, Write, NotebookEdit — path pattern |
| `WebFetch(domain:example.com)` | WebFetch — domain matching |
| `Skill(deploy *)` | Skill — name prefix matching |
| `Agent(Explore)` | Agent — subagent type matching |
| `WebSearch` | WebSearch — bare name only |

#### Bash Tool Limits

| Setting | Default | Override |
| :--- | :--- | :--- |
| Command timeout | 2 minutes (max 10 min per command) | `BASH_DEFAULT_TIMEOUT_MS`, `BASH_MAX_TIMEOUT_MS` |
| Output length | 30,000 chars (hard ceiling 150,000) | `BASH_MAX_OUTPUT_LENGTH` |

Environment variables do not persist between Bash calls. Working directory changes persist within the project directory (disable with `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1`).

#### Edit Tool Rules

1. Claude must have read the file in the current conversation before editing.
2. `old_string` must match exactly (whitespace-sensitive).
3. `old_string` must appear exactly once, or use `replace_all: true`.

#### WebFetch Behavior

- HTML responses are converted to Markdown via a small extraction model — lossy by design.
- HTTP URLs are upgraded to HTTPS automatically.
- Responses cached 15 minutes.
- Redirects to a different host are surfaced as text (not auto-followed).
- First access to a new domain prompts for permission (in `default`/`acceptEdits` modes).

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — complete CLI commands and flags including system prompt flags
- [Commands](references/claude-code-commands.md) — all in-session slash commands and bundled skills
- [Interactive Mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, vim editor mode, shell mode, background bash, side questions, task list, session recap
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) — keybindings file format, contexts, all available actions, keystroke syntax, chord bindings, reserved shortcuts
- [Configure your terminal](references/claude-code-terminal-config.md) — Shift+Enter, Option key, terminal bell, tmux passthrough, fullscreen rendering, custom themes, Vim mode
- [Tools Reference](references/claude-code-tools-reference.md) — every built-in tool, permission rule syntax, Bash/Edit/Glob/Grep/LSP/Monitor/WebFetch/WebSearch/Write behavior details

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure your terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
