---
name: cli-doc
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface: launch commands, flags, in-session slash commands, keyboard shortcuts, keybindings configuration, terminal setup, and built-in tools reference.

## Quick Reference

### Launch Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode: query then exit (non-interactive) |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall native binary (`stable`, `latest`, or version number) |
| `claude auth login` | Sign in (`--console` for API billing, `--sso` for SSO) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | Open agent view for background sessions (`--json` for scripting) |
| `claude attach <id>` | Attach to a background session in this terminal |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |
| `claude daemon status` | Show background-session supervisor state |
| `claude daemon stop --any` | Stop supervisor and its sessions (`--keep-workers` to leave sessions running) |
| `claude logs <id>` | Print output from a background session |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local Claude Code state for a project (`--dry-run`, `--all`) |
| `claude remote-control` | Start a Remote Control server |
| `claude respawn <id>` | Restart a background session (`--all` to restart all) |
| `claude rm <id>` | Remove a background session from the list |
| `claude setup-token` | Generate long-lived OAuth token for CI/scripts |
| `claude stop <id>` | Stop a background session |
| `claude ultrareview [target]` | Run ultrareview non-interactively (`--json`, `--timeout`) |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `-p`, `--print` | Print mode (non-interactive); exit after response |
| `-c`, `--continue` | Load most recent conversation in current directory |
| `-r`, `--resume [session]` | Resume session by ID, name, or interactive picker |
| `-n`, `--name` | Set display name for session |
| `--model` | Set model (alias like `sonnet`/`opus` or full name) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Starting permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--dangerously-skip-permissions` | Equivalent to `--permission-mode bypassPermissions` |
| `--allow-dangerously-skip-permissions` | Add `bypassPermissions` to mode cycle without starting in it |
| `--tools` | Restrict available tools (e.g., `"Bash,Edit,Read"`); `""` to disable all |
| `--allowedTools` | Tools that run without permission prompts |
| `--disallowedTools` | Deny rules; bare tool name removes it from model context |
| `--add-dir` | Add additional working directories |
| `--mcp-config` | Load MCP servers from JSON file or string |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config`; ignore all other MCP config |
| `--plugin-dir` | Load plugin from directory or `.zip` for this session |
| `--plugin-url` | Fetch plugin `.zip` from URL for this session |
| `--output-format` | Print mode output format: `text`, `json`, `stream-json` |
| `--input-format` | Input format for print mode: `text`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Spending cap in dollars (print mode) |
| `--bg` | Start session as background agent and return immediately |
| `--exec` | Run a shell command as background job instead of Claude session (use with `--bg`) |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--tmux` | Create tmux session for worktree (requires `--worktree`) |
| `--settings` | Path to settings JSON or inline JSON string |
| `--setting-sources` | Comma-separated list of sources to load: `user`, `project`, `local` |
| `--system-prompt` | Replace entire system prompt |
| `--system-prompt-file` | Load system prompt from file |
| `--append-system-prompt` | Append text to default system prompt |
| `--append-system-prompt-file` | Append file contents to default system prompt |
| `--verbose` | Show full turn-by-turn output |
| `--debug` | Enable debug mode (optional category filter like `"api,hooks"` or `"!statsig"`) |
| `--debug-file <path>` | Write debug logs to file (implicitly enables debug mode) |
| `--fallback-model` | Auto-fallback to specified model when default unavailable (print mode / background) |
| `--fork-session` | When resuming, create new session ID instead of reusing original |
| `--from-pr` | Resume sessions linked to a specific pull request (number or URL) |
| `--remote` | Create new web session on claude.ai with provided task |
| `--remote-control`, `--rc` | Start interactive session with Remote Control enabled |
| `--teleport` | Resume a web session in local terminal |
| `--teammate-mode` | Set agent team display: `auto`, `in-process`, `tmux` |
| `--chrome` | Enable Chrome browser integration |
| `--no-chrome` | Disable Chrome browser integration |
| `--ide` | Automatically connect to IDE on startup |
| `--channels` | MCP server channel notifications to listen for |
| `--agent` | Specify an agent for the current session |
| `--agents` | Define custom subagents dynamically via JSON |
| `--json-schema` | Get validated JSON output matching a schema (print mode, structured outputs) |
| `--prompt-suggestions` | Emit predicted next prompt after each turn (requires stream-json + verbose) |
| `--no-session-persistence` | Disable session persistence (print mode only) |
| `--include-hook-events` | Include hook lifecycle events in output stream (requires stream-json) |
| `--include-partial-messages` | Include partial streaming events (requires stream-json) |
| `--replay-user-messages` | Re-emit user messages from stdin on stdout (requires stream-json both ways) |
| `--exclude-dynamic-system-prompt-sections` | Move machine-specific sections to first user message (improves cache reuse) |
| `--init` | Run Setup hooks with `init` matcher before session (print mode) |
| `--init-only` | Run Setup and SessionStart hooks, then exit |
| `--maintenance` | Run Setup hooks with `maintenance` matcher before session (print mode) |
| `--session-id` | Use a specific UUID as the session ID |
| `--disable-slash-commands` | Disable all skills and commands for this session |
| `--version`, `-v` | Print version number |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags combine with either replacement flag. Use append when Claude should remain a coding assistant with extra rules; use replacement when the surface or identity differs from Claude Code's defaults.

### Key In-Session Commands

| Command | Purpose |
|:--------|:--------|
| `/add-dir <path>` | Add working directory for file access this session |
| `/agents` | Manage subagent configurations |
| `/autofix-pr [prompt]` | Spawn web session to auto-fix PR CI failures and review comments |
| `/background [prompt]` | Detach session to run as background agent |
| `/batch <instruction>` | **[Skill]** Parallel large-scale codebase changes across worktrees |
| `/branch [name]` | Fork conversation at current point (switch into copy yourself) |
| `/btw <question>` | Ask side question without adding to context |
| `/clear [name]` | Start fresh; previous conversation stays resumable |
| `/code-review [level] [--fix] [--comment]` | **[Skill]** Review diff for bugs and cleanups; `ultra` for cloud review |
| `/compact [instructions]` | Summarize context to free up window |
| `/config` | Open settings interface |
| `/context [all]` | Visualize context usage |
| `/copy [N]` | Copy last (or Nth) assistant response |
| `/debug [description]` | **[Skill]** Enable debug logging mid-session |
| `/deep-research <question>` | **[Workflow]** Fan-out web research and synthesize cited report |
| `/desktop` | Continue session in Claude Code Desktop app |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings |
| `/effort [level\|auto]` | Adjust effort level interactively |
| `/exit` | Exit CLI (detaches if in background session) |
| `/export [filename]` | Export conversation as plain text |
| `/fast [on\|off]` | Toggle fast mode |
| `/feedback [report]` | Submit feedback or report a bug |
| `/focus` | Toggle focus view (last prompt, tool summary, final response) |
| `/fork <directive>` | Spawn background subagent with full conversation context |
| `/goal [condition\|clear]` | Set a goal Claude works toward across turns |
| `/help` | Show help and available commands |
| `/hooks` | View hook configurations |
| `/ide` | Manage IDE integrations |
| `/init` | Initialize project CLAUDE.md |
| `/insights` | Generate report analyzing your Claude Code sessions |
| `/install-github-app` | Set up Claude GitHub Actions app for a repository |
| `/keybindings` | Open keyboard shortcuts config file |
| `/login` / `/logout` | Sign in / sign out |
| `/loop [interval] [prompt]` | **[Skill]** Run prompt repeatedly on a schedule |
| `/mcp` | Manage MCP server connections and OAuth auth |
| `/memory` | Edit CLAUDE.md files, manage auto-memory |
| `/model [model]` | Switch model and save as default |
| `/permissions` | Manage allow/ask/deny rules |
| `/plan [description]` | Enter plan mode |
| `/plugin [subcommand]` | Manage plugins (list/install/enable/disable) |
| `/powerup` | Discover features through interactive lessons |
| `/radio` | Open Claude FM lo-fi radio |
| `/recap` | Generate one-line session summary on demand |
| `/reload-plugins [--force]` | Reload active plugins without restarting |
| `/reload-skills` | Re-scan skill directories without restarting |
| `/remote-control` | Make this session available for remote control from claude.ai |
| `/remote-env` | Choose default environment for cloud agents |
| `/rename [name]` | Rename current session |
| `/resume [session]` | Resume conversation by ID or name |
| `/review [PR]` | Review a pull request locally |
| `/rewind` | Roll back code and conversation to a checkpoint |
| `/run` | **[Skill]** Launch and drive your app to verify a change |
| `/run-skill-generator` | **[Skill]** Teach `/run` and `/verify` how to build/launch your app |
| `/sandbox` | Toggle sandbox mode |
| `/schedule [description]` | Create/update/list routines on Anthropic cloud infrastructure |
| `/scroll-speed` | Adjust mouse wheel scroll speed (fullscreen mode only) |
| `/security-review` | Analyze branch changes for security issues |
| `/simplify [target]` | **[Skill]** Apply cleanup-only review fixes (no bug hunting) |
| `/skills` | List available skills |
| `/status` | Open Settings (Status tab) showing version, model, account |
| `/statusline` | Configure the status line |
| `/stop` | Stop current background session (when attached) |
| `/tasks` | View and manage background tasks |
| `/team-onboarding` | Generate team onboarding guide from your session history |
| `/teleport` | Pull a web session into this terminal |
| `/terminal-setup` | Configure terminal keybindings for Shift+Enter |
| `/theme` | Change color theme |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/ultraplan <prompt>` | Draft plan in ultraplan session, review in browser |
| `/ultrareview [PR]` | Deep multi-agent cloud code review (alias for `/code-review ultra`) |
| `/usage` | Show session cost, limits, and activity stats |
| `/verify` | **[Skill]** Confirm a code change works by running the app |
| `/voice [hold\|tap\|off]` | Toggle voice dictation |
| `/web-setup` | Connect GitHub account to Claude Code on the web |
| `/workflows` | Watch/pause/resume running workflows |

Commands marked **[Skill]** are bundled skills — prompt-based workflows Claude can also auto-invoke when relevant. Commands marked **[Workflow]** run as dynamic multi-agent workflows in the background.

### Keyboard Shortcuts

**General controls:**

| Shortcut | Action |
|:---------|:-------|
| `Ctrl+C` | Interrupt or clear input |
| `Ctrl+D` | Exit session |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open in external editor |
| `Ctrl+L` | Force full terminal redraw |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` / `Alt+V` (Windows/WSL) | Paste image from clipboard |
| `Ctrl+B` | Background running tasks (press twice in tmux) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+X Ctrl+K` | Kill all running background subagents (confirm with second press) |
| `Esc` | Interrupt Claude (keeps work done so far) |
| `Esc` + `Esc` | Clear input draft or open rewind menu |
| `Shift+Tab` | Cycle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |

**Multiline input:**

| Method | Shortcut |
|:-------|:---------|
| Works everywhere | `\` + `Enter` or `Ctrl+J` |
| Most terminals | `Shift+Enter` (native or after `/terminal-setup`) |
| macOS with Option-as-Meta | `Option+Enter` |

**Quick input prefixes:**

| Prefix | Behavior |
|:-------|:---------|
| `/` at start | Command or skill |
| `!` at start | Shell mode — run command directly; adds output to context |
| `@` | Trigger file path autocomplete |

**Transcript viewer shortcuts (with `Ctrl+O`):**

| Shortcut | Action |
|:---------|:-------|
| `Ctrl+E` | Toggle show all content |
| `{` / `}` | Jump to previous/next user prompt (fullscreen) |
| `[` | Write conversation to terminal scrollback (fullscreen) |
| `v` | Open conversation in `$EDITOR` (fullscreen) |
| `q`, `Ctrl+C`, `Esc` | Exit transcript view |

### Vim Editor Mode

Enable via `/config` → Editor mode or set `editorMode: "vim"` in settings.

Key mode-switching commands: `Esc` → NORMAL, `i`/`I`/`a`/`A`/`o`/`O` → INSERT, `v`/`V` → VISUAL.

Navigation (NORMAL): `hjkl`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f{char}`/`F{char}`/`t{char}`/`T{char}`, `/` (opens history search).

Editing (NORMAL): `x`, `dd`/`D`, `cc`/`C`, `yy`/`Y`, `p`/`P`, `>>`/`<<`, `J`, `u`, `.` (repeat).

Text objects with `d`/`c`/`y`: `iw`/`aw`, `i"`/`a"`, `i(`/`a(`, `i{`/`a{`, `i[`/`a[`, etc.

Enter still submits in INSERT mode; use `Ctrl+J` or `o`/`O` in NORMAL mode for newlines.

### Keybindings Configuration

Config file: `~/.claude/keybindings.json` (open with `/keybindings`). Changes apply live without restart.

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

**Available contexts:** `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Settings`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Scroll` (fullscreen), `Doctor`.

**Key actions by context:**

| Context | Key actions |
|:--------|:------------|
| `Global` | `app:interrupt`, `app:exit`, `app:redraw`, `app:toggleTodos`, `app:toggleTranscript` |
| `Chat` | `chat:submit`, `chat:newline`, `chat:cancel`, `chat:clearInput`, `chat:cycleMode`, `chat:modelPicker`, `chat:fastMode`, `chat:thinkingToggle`, `chat:externalEditor`, `chat:stash`, `chat:imagePaste`, `chat:killAgents` |
| `Transcript` | `transcript:toggleShowAll`, `transcript:exit` |
| `Task` | `task:background` |
| `HistorySearch` | `historySearch:next`, `historySearch:accept`, `historySearch:cancel`, `historySearch:execute`, `historySearch:cycleScope` |
| `Scroll` | `scroll:lineUp/Down`, `scroll:pageUp/Down`, `scroll:top`, `scroll:bottom`, `selection:copy`, `selection:clear`, `selection:extend*` |

Set an action to `null` to unbind it. **Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, `Caps Lock`. **Terminal conflicts:** `Ctrl+B` (tmux prefix — press twice), `Ctrl+A` (screen prefix).

**Chord bindings:** space-separated keystrokes, e.g. `"ctrl+k ctrl+s"`. To rebind a prefix used by chords, first null-bind all chords sharing that prefix.

### Terminal Configuration

| Issue | Fix |
|:------|:----|
| Shift+Enter submits instead of newline (VS Code, Cursor, Zed, Alacritty) | Run `/terminal-setup` once |
| Shift+Enter in tmux | Add `set -g allow-passthrough on`, `set -s extended-keys on`, `set -as terminal-features 'xterm*:extkeys'` to `~/.tmux.conf` |
| Option-key shortcuts do nothing on macOS (iTerm2) | Settings → Profiles → Keys → set Left/Right Option to "Esc+" |
| Option-key shortcuts do nothing on macOS (VS Code) | Add `"terminal.integrated.macOptionIsMeta": true` to VS Code settings |
| Option-key shortcuts do nothing (Apple Terminal) | Settings → Profiles → Keyboard → check "Use Option as Meta Key" |
| No desktop notification when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` in settings, or configure a Notification hook |
| Display flicker / scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |

**Custom themes:** `/theme` → Select "New custom theme…" to create interactively, or create `~/.claude/themes/<slug>.json`. Fields: `name` (display label), `base` (preset: `dark`, `light`, `dark-daltonized`, `light-daltonized`, `dark-ansi`, `light-ansi`), `overrides` (map of color token names to `#rrggbb`, `rgb()`, `ansi256(n)`, or `ansi:<name>` values). Claude Code watches this directory and reloads live.

### Built-in Tools Reference

| Tool | Permission Required | Description |
|:-----|:-------------------|:------------|
| `Agent` | No | Spawns a subagent in its own context window |
| `AskUserQuestion` | No | Asks multiple-choice questions |
| `Bash` | Yes | Executes shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Manage session-scoped scheduled prompts |
| `Edit` | Yes | Targeted exact string replacement in files |
| `EnterPlanMode` / `ExitPlanMode` | No / Yes | Switch to/from plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Create/exit isolated git worktrees |
| `Glob` | No | Find files by name pattern (sorted by mtime, cap 100) |
| `Grep` | No | Search file contents (ripgrep-powered, respects `.gitignore`) |
| `LSP` | No | Code intelligence via language servers (requires plugin) |
| `Monitor` | Yes | Watch a command in background and feed output to Claude |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells by `cell_id` |
| `PowerShell` | Yes | Execute PowerShell commands (opt-in on Linux/macOS) |
| `PushNotification` | No | Send desktop/phone notification (Anthropic-hosted only) |
| `Read` | No | Read file contents with line numbers; handles images, PDFs, notebooks |
| `RemoteTrigger` | No | Create/update/run Routines on claude.ai (Pro/Max/Team/Enterprise) |
| `ScheduleWakeup` | No | Reschedule next iteration of a self-paced `/loop` |
| `SendMessage` | No | Send message to agent team teammate (requires experimental flag) |
| `Skill` | Yes | Execute a skill within the main conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Manage session task list |
| `TeamCreate` / `TeamDelete` | No | Create/disband agent teams (requires experimental flag) |
| `ToolSearch` | No | Search for and load deferred tools (when tool search is enabled) |
| `WaitForMcpServers` | No | Wait for connecting MCP servers (when tool search is disabled) |
| `WebFetch` | Yes | Fetch URL content (runs extraction prompt against page) |
| `WebSearch` | Yes | Run web search query (returns titles/URLs; use WebFetch to read pages) |
| `Workflow` | Yes | Run a dynamic workflow across many subagents |
| `Write` | Yes | Create or overwrite files |

**Permission rule formats:**

| Rule format | Applies to |
|:------------|:-----------|
| `Bash(npm run *)` | Bash, Monitor — command pattern matching |
| `PowerShell(Get-ChildItem *)` | PowerShell — command pattern matching |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP — path pattern |
| `Edit(/src/**)` | Edit, Write, NotebookEdit — path pattern |
| `WebFetch(domain:example.com)` | WebFetch — domain matching |
| `Skill(deploy *)` | Skill — name matching |
| `Agent(Explore)` | Agent — subagent type matching |
| `WebSearch` | WebSearch — no specifier, allow/deny whole tool |

An `Edit(...)` allow rule also grants read access to the same path.

**Bash tool notes:** `cd` carries over within project/additional dirs (disable with `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1`). Environment variables do not persist across commands. Timeout: 2 min default, up to 10 min with `timeout` param. Output cap: 30,000 chars default (raise with `BASH_MAX_OUTPUT_LENGTH`, hard ceiling 150,000).

**Edit tool notes:** Requires read-before-edit (file must not have changed since last read). `old_string` must match exactly and appear exactly once (or set `replace_all: true`). `cat`, `head`, `tail`, `sed -n 'X,Yp'`, `grep`/`egrep`/`fgrep` on a single file with no pipes also satisfy the read requirement.

**WebFetch notes:** Lossy by design — runs an extraction prompt against the page. HTTP auto-upgraded to HTTPS. Results cached 15 minutes. Does not follow cross-host redirects automatically (returns redirect info instead). First fetch to a new domain prompts for permission (except preapproved docs domains).

**Monitor tool notes:** Requires v2.1.98+. Not available on Bedrock, Vertex, or Foundry, or when `DISABLE_TELEMETRY` is set. Plugins can declare monitors that start automatically.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — All CLI commands and flags, system prompt flags, launch examples
- [Commands](references/claude-code-commands.md) — Complete in-session slash command reference, workflow categories, MCP prompts
- [Interactive mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, Vim editor mode, command history, shell mode, prompt suggestions, `/btw`, task list, session recap, PR review status
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) — Keybindings config file, all contexts, all available actions, keystroke syntax, chords, unbinding, reserved shortcuts
- [Configure your terminal](references/claude-code-terminal-config.md) — Shift+Enter setup, Option key on macOS, terminal bell/notifications, tmux config, fullscreen rendering, custom themes, color token reference
- [Tools reference](references/claude-code-tools-reference.md) — All built-in tools, permission rules, per-tool behavior details (Bash, Edit, Glob, Grep, LSP, Monitor, NotebookEdit, PowerShell, Read, WebFetch, WebSearch, Write)

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure your terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
