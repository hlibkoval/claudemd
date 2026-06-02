---
name: cli-doc
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface: launch commands, CLI flags, in-session commands, keyboard shortcuts, keybinding customization, terminal configuration, and the built-in tools reference.

## Quick Reference

### CLI Launch Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode (non-interactive, then exit) |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install or reinstall native binary (`stable`, `latest`, or `2.1.x`) |
| `claude auth login` | Sign in (use `--console` for API billing, `--sso` for SSO) |
| `claude auth logout` | Log out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | Open agent view (`--json` for scripting) |
| `claude attach <id>` | Attach to a background session |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules |
| `claude daemon status` | Show background supervisor state |
| `claude daemon stop --any` | Stop supervisor and hosted sessions |
| `claude logs <id>` | Print output from a background session |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins (alias: `claude plugins`) |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude remote-control` | Start a Remote Control server |
| `claude respawn <id>` | Restart a background session with conversation intact |
| `claude rm <id>` | Remove a background session from the list |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `claude stop <id>` | Stop a background session (alias: `claude kill`) |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `--print`, `-p` | Non-interactive print mode |
| `--continue`, `-c` | Load most recent conversation |
| `--resume`, `-r` | Resume session by ID or name |
| `--model` | Set model (e.g., `sonnet`, `opus`, or full name) |
| `--permission-mode` | Start in a mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append text to default system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append file contents to default system prompt |
| `--output-format` | Print mode output format: `text`, `json`, `stream-json` |
| `--input-format` | Print mode input format: `text`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Dollar cap on API calls (print mode only) |
| `--allowedTools` | Tools that execute without permission prompt |
| `--disallowedTools` | Deny rules; bare tool name removes it from context |
| `--tools` | Restrict which built-in tools are available |
| `--add-dir` | Add additional working directories |
| `--bg` | Start session as background agent |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--name`, `-n` | Set session display name |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, memory, CLAUDE.md |
| `--verbose` | Enable verbose logging (full turn-by-turn output) |
| `--debug [categories]` | Enable debug mode with optional category filter |
| `--debug-file <path>` | Write debug logs to a file |
| `--mcp-config` | Load MCP servers from JSON file or string |
| `--plugin-dir` | Load plugin from directory or zip (session only) |
| `--plugin-url` | Fetch plugin zip from URL (session only) |
| `--settings` | Path to settings file or inline JSON string |
| `--agent` | Specify a named agent for the session |
| `--agents` | Define custom subagents dynamically via JSON |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a specific PR |
| `--exclude-dynamic-system-prompt-sections` | Improve prompt-cache reuse across users/machines |
| `--fallback-model` | Auto-fallback model when primary is unavailable (print/bg mode) |
| `--json-schema` | Validated structured output schema (print mode only) |
| `--no-session-persistence` | Disable session saving to disk (print mode only) |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, `tmux` |
| `--remote` | Create new web session on claude.ai |
| `--teleport` | Resume web session in local terminal |
| `--remote-control`, `--rc` | Enable Remote Control in interactive session |
| `--init` | Run Setup hooks with `init` matcher before session (print mode) |
| `--init-only` | Run Setup and SessionStart hooks, then exit |
| `--include-hook-events` | Include hook lifecycle events in output stream |
| `--prompt-suggestions` | Emit next-prompt suggestion after each turn |
| `--version`, `-v` | Output the version number |

### System Prompt Flags Summary

| Flag | Effect |
|:-----|:-------|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can be combined with either replacement flag. Use replacement when identity or permission model fundamentally differs; use append when Claude should remain a coding assistant with extra rules.

### In-Session Commands (Slash Commands)

Type `/` to see all available commands. Key built-in commands:

**Setup & Config**

| Command | Purpose |
|:--------|:--------|
| `/init` | Initialize project `CLAUDE.md` |
| `/memory` | Edit CLAUDE.md files, manage auto-memory |
| `/config` | Open settings interface (alias: `/settings`) |
| `/permissions` | Manage allow/ask/deny rules (alias: `/allowed-tools`) |
| `/mcp` | Manage MCP server connections |
| `/agents` | Manage agent configurations |
| `/model [model]` | Switch AI model |
| `/effort [level\|auto]` | Set effort level interactively |
| `/theme` | Change color theme |
| `/keybindings` | Open keybindings configuration file |

**During a Task**

| Command | Purpose |
|:--------|:--------|
| `/plan [desc]` | Enter plan mode |
| `/compact [instructions]` | Summarize context to free space |
| `/context [all]` | Visualize context window usage |
| `/btw <question>` | Ephemeral side question (no history) |
| `/goal [condition\|clear]` | Set autonomous goal; Claude works until met |
| `/tasks` | List and manage background tasks |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/fast [on\|off]` | Toggle fast mode |

**Parallel Work**

| Command | Purpose |
|:--------|:--------|
| `/background [prompt]` | Detach session as background agent (alias: `/bg`) |
| `/batch <instruction>` | Fan out codebase changes across worktrees (Skill) |

**Review & Shipping**

| Command | Purpose |
|:--------|:--------|
| `/code-review [level] [--fix] [--comment] [target]` | Review diff for bugs and cleanups (Skill) |
| `/simplify [target]` | Cleanup-only review with auto-fix (Skill) |
| `/security-review` | Analyze pending changes for security risks |
| `/review [PR]` | Review a pull request locally |
| `/ultrareview [PR]` | Deep multi-agent cloud code review (alias for `/code-review ultra`) |

**Between Sessions**

| Command | Purpose |
|:--------|:--------|
| `/clear [name]` | Start fresh; previous session stays in `/resume` |
| `/resume [session]` | Resume conversation by ID or name (alias: `/continue`) |
| `/branch [name]` | Fork conversation at current point (alias: `/fork`) |
| `/teleport` | Pull a web session into this terminal (alias: `/tp`) |
| `/remote-control` | Make session available from claude.ai (alias: `/rc`) |
| `/export [filename]` | Export conversation as plain text |

**Diagnosis & Info**

| Command | Purpose |
|:--------|:--------|
| `/rewind` | Roll back code/conversation to a checkpoint (aliases: `/checkpoint`, `/undo`) |
| `/doctor` | Diagnose Claude Code installation |
| `/debug [desc]` | Enable debug logging mid-session (Skill) |
| `/usage` | Show cost, plan limits, activity stats (aliases: `/cost`, `/stats`) |
| `/status` | Show version, model, account, connectivity |
| `/recap` | Generate one-line session summary |
| `/release-notes` | View changelog in interactive version picker |
| `/copy [N]` | Copy last assistant response to clipboard |
| `/rename [name]` | Rename current session |

**Other Notable Commands**

| Command | Purpose |
|:--------|:--------|
| `/add-dir <path>` | Add working directory for current session |
| `/loop [interval] [prompt]` | Run prompt on schedule (Skill) |
| `/schedule [desc]` | Create/manage routines on claude.ai (alias: `/routines`) |
| `/autofix-pr [prompt]` | Spawn web session to auto-fix CI failures and review comments |
| `/reload-plugins` | Reload active plugins without restarting |
| `/reload-skills` | Re-scan skill directories for newly added skills |
| `/tui [default\|fullscreen]` | Switch terminal UI renderer |
| `/color [color\|default]` | Set prompt bar color for current session |
| `/ultraplan <prompt>` | Draft plan in ultraplan session |
| `/workflows` | Open workflow progress view |
| `/skills` | List available skills |
| `/plugin` | Manage Claude Code plugins |
| `/exit` | Exit CLI (alias: `/quit`) |

**Bundled Skills**: `/batch`, `/claude-api`, `/code-review`, `/debug`, `/fewer-permission-prompts`, `/loop`, `/run`, `/run-skill-generator`, `/simplify`, `/verify`

**Bundled Workflows**: `/deep-research`

### Keyboard Shortcuts

#### General Controls

| Shortcut | Action |
|:---------|:-------|
| `Ctrl+C` | Interrupt or clear input |
| `Ctrl+D` | Exit session |
| `Esc` | Interrupt Claude mid-turn (keeps work done so far) |
| `Esc Esc` | Clear input draft, or open rewind menu when input empty |
| `Shift+Tab` | Cycle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse history search |
| `Ctrl+B` | Background running tasks (tmux users: press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open in external text editor |
| `Ctrl+V` / `Cmd+V` (iTerm2) / `Alt+V` (WSL) | Paste image from clipboard |
| `Ctrl+X Ctrl+K` | Kill all running background subagents |
| `Ctrl+L` | Force terminal redraw |

#### Text Editing

| Shortcut | Action |
|:---------|:-------|
| `Ctrl+A` | Move cursor to start of current line |
| `Ctrl+E` | Move cursor to end of current line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+Y` (after `Ctrl+Y`) | Cycle paste history |
| `Alt+B` | Move cursor back one word |
| `Alt+F` | Move cursor forward one word |

#### Multiline Input Methods

| Method | Shortcut | Notes |
|:-------|:---------|:------|
| Quick escape | `\` + `Enter` | Works in all terminals |
| Control sequence | `Ctrl+J` | Works anywhere without config |
| Shift+Enter | `Shift+Enter` | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| Option key | `Option+Enter` | Requires Option as Meta on macOS |

#### Quick Prefixes

| Prefix | Action |
|:-------|:-------|
| `/` at start | Command or skill |
| `!` at start | Shell mode (run command directly, adds output to context) |
| `@` | File path mention / autocomplete |

#### Transcript Viewer Shortcuts (Ctrl+O to open)

| Shortcut | Action |
|:---------|:-------|
| `?` | Toggle keyboard shortcut help (fullscreen only) |
| `{` / `}` | Jump to previous/next user prompt (fullscreen only) |
| `Ctrl+E` | Toggle show all content |
| `[` | Write conversation to terminal's native scrollback (fullscreen only) |
| `v` | Open conversation in `$VISUAL` or `$EDITOR` (fullscreen only) |
| `q`, `Ctrl+C`, `Esc` | Exit transcript view |

### Keybindings Configuration

Config file: `~/.claude/keybindings.json` (run `/keybindings` to open/create). Changes are hot-reloaded without restart.

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "$docs": "https://code.claude.com/docs/en/keybindings",
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

Set a binding to `null` to unbind it. Chords are space-separated: `ctrl+k ctrl+s`.

#### Available Contexts

`Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Scroll`, `Doctor`

#### Key Actions by Namespace

| Namespace | Notable Actions |
|:----------|:----------------|
| `app:` | `interrupt`, `exit`, `redraw`, `toggleTodos`, `toggleTranscript` |
| `chat:` | `submit`, `newline`, `cancel`, `clearInput`, `cycleMode`, `modelPicker`, `fastMode`, `thinkingToggle`, `externalEditor`, `imagePaste`, `killAgents` |
| `history:` | `search`, `previous`, `next` |
| `autocomplete:` | `accept`, `dismiss`, `previous`, `next` |
| `confirm:` | `yes`, `no`, `previous`, `next`, `toggle`, `cycleMode`, `toggleExplanation` |
| `transcript:` | `toggleShowAll`, `exit` |
| `historySearch:` | `next`, `accept`, `cancel`, `execute`, `cycleScope` |
| `task:` | `background` |
| `scroll:` / `selection:` | `lineUp`, `lineDown`, `pageUp`, `pageDown`, `top`, `bottom`, `copy`, `extendLeft`, `extendRight`, etc. |
| `diff:` | `dismiss`, `previousSource`, `nextSource`, `previousFile`, `nextFile`, `viewDetails` |
| `modelPicker:` | `decreaseEffort`, `increaseEffort`, `thisSessionOnly` |

Reserved (cannot rebind): `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, Caps Lock.

Terminal conflicts: `Ctrl+B` (tmux prefix), `Ctrl+A` (GNU screen prefix), `Ctrl+Z` (Unix suspend).

### Terminal Configuration

#### Shift+Enter Support

| Terminal | Status |
|:---------|:-------|
| Ghostty, Kitty, iTerm2, WezTerm, Warp, Apple Terminal, Windows Terminal | Works without setup |
| VS Code, Cursor, Windsurf, Alacritty, Zed | Run `/terminal-setup` once |
| gnome-terminal, JetBrains IDEs | Not available; use `Ctrl+J` or `\` then Enter |

#### Option Key on macOS

- **iTerm2**: Settings → Profiles → Keys → General → set Left/Right Option to "Esc+"
- **Apple Terminal**: Settings → Profiles → Keyboard → check "Use Option as Meta Key"
- **VS Code**: set `"terminal.integrated.macOptionIsMeta": true`

#### tmux Configuration (`~/.tmux.conf`)

```
set -g allow-passthrough on
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'
```

Run `tmux source-file ~/.tmux.conf` after editing.

#### Notifications

Set [`preferredNotifChannel`](/en/settings#available-settings) to `"terminal_bell"` for non-Ghostty/Kitty/iTerm2 terminals. Use a Notification hook for custom sounds or commands.

#### Fullscreen Rendering

Run `/tui fullscreen` to switch, or set `CLAUDE_CODE_NO_FLICKER=1` permanently. Eliminates flickering, adds mouse scroll/selection. Use `PageUp`/`PageDown` to scroll inside Claude Code.

#### Custom Themes

Stored in `~/.claude/themes/<slug>.json`. Fields: `name` (string), `base` (dark/light/dark-daltonized/light-daltonized/dark-ansi/light-ansi), `overrides` (color token map). Color values: `#rrggbb`, `rgb(r,g,b)`, `ansi256(n)`, `ansi:<name>`. Hot-reloaded when file changes.

#### Vim Mode

Enable via `/config` → Editor mode, or set `editorMode: "vim"` in `~/.claude/settings.json`.

### Built-in Tools Reference

| Tool | Permission | Description |
|:-----|:-----------|:------------|
| `Agent` | No | Spawns a subagent with its own context window |
| `AskUserQuestion` | No | Multiple-choice prompts for clarification |
| `Bash` | Yes | Execute shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Schedule recurring or one-shot prompts in the session |
| `Edit` | Yes | Exact string replacement in files |
| `EnterPlanMode` | No | Switch to plan mode |
| `ExitPlanMode` | Yes | Present plan for approval, exit plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Create/switch isolated git worktrees |
| `Glob` | No | Find files by name pattern |
| `Grep` | No | Search file contents (ripgrep-powered) |
| `LSP` | No | Code intelligence: definitions, references, type errors |
| `Monitor` | Yes | Watch background command, feed output lines to Claude |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `PowerShell` | Yes | Execute PowerShell commands natively |
| `PushNotification` | No | Send desktop/phone push notification |
| `Read` | No | Read files (images, PDFs, Jupyter notebooks supported) |
| `RemoteTrigger` | No | Create/run Routines on claude.ai |
| `Skill` | Yes | Execute a skill within the main conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Manage session task list |
| `WebFetch` | Yes | Fetch URL, convert HTML to Markdown, extract via LLM prompt |
| `WebSearch` | Yes | Web search; returns titles+URLs (follow up with WebFetch for content) |
| `Workflow` | Yes | Run a dynamic workflow (fan-out subagents) |
| `Write` | Yes | Create or overwrite files (full content) |

#### Tool Permission Rule Formats

| Rule | Applies To |
|:-----|:-----------|
| `Bash(npm run *)` | Bash, Monitor |
| `PowerShell(Get-ChildItem *)` | PowerShell |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP |
| `Edit(/src/**)` | Edit, Write, NotebookEdit |
| `Skill(deploy *)` | Skill |
| `Agent(Explore)` | Agent |
| `WebFetch(domain:example.com)` | WebFetch |
| `WebSearch` | WebSearch (no specifier) |

An `Edit(...)` allow rule also grants read access to the same path.

#### Key Tool Behaviors

- **Bash**: 2-min default timeout (up to 10 min via `timeout` param). 30,000-char output cap (env: `BASH_MAX_OUTPUT_LENGTH`, ceiling 150k). `cd` persists within allowed dirs; env vars do not persist across calls.
- **Edit**: `old_string` must match exactly and appear exactly once (or use `replace_all: true`). File must have been read in the current conversation first.
- **Write**: Must have read an existing file before overwriting it. No prior read required for new files.
- **Glob**: Results capped at 100 files, sorted by modification time. Does NOT respect `.gitignore` by default (set `CLAUDE_CODE_GLOB_NO_IGNORE=false` to change).
- **Grep**: Uses ripgrep regex (not POSIX). Respects `.gitignore`. Output modes: `files_with_matches` (default), `content`, `count`. Supports `multiline: true`.
- **WebFetch**: Lossy by design — extracts via LLM prompt. Cached 15 min. Auto-upgrades HTTP to HTTPS. Does not auto-follow cross-host redirects.
- **WebSearch**: Returns titles and URLs only. Up to 8 internal backend searches per call. Supports `allowed_domains` or `blocked_domains` (not both).
- **Monitor**: Requires Claude Code v2.1.98+. Not available on Bedrock, Vertex, or Foundry.
- **LSP**: Inactive until a code intelligence plugin is installed for your language.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — All CLI commands, flags, system prompt flags, background session management
- [Commands](references/claude-code-commands.md) — Complete in-session slash command listing, bundled skills and workflows, MCP prompt commands
- [Interactive Mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, Vim editor mode, command history, shell mode, prompt suggestions, /btw side questions, task list, PR review status
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) — Keybindings config format, all contexts and actions, keystroke syntax, chords, reserved shortcuts
- [Configure Your Terminal](references/claude-code-terminal-config.md) — Shift+Enter setup, Option key on macOS, tmux config, notifications, fullscreen rendering, custom themes, Vim mode
- [Tools Reference](references/claude-code-tools-reference.md) — All built-in tools, permission requirements, rule format syntax, per-tool behavior details

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure Your Terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
