---
name: cli-doc
user-invocable: false
---

# CLI & Interactive Mode Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, slash commands, interactive mode, keyboard shortcuts, keybindings customization, terminal configuration, and built-in tools.

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
| `claude agents` | Open agent view to monitor background sessions (`--json` for scripting) |
| `claude attach <id>` | Attach to a background session |
| `claude stop <id>` | Stop a background session (alias: `claude kill`) |
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
| `--allow-dangerously-skip-permissions` | Add `bypassPermissions` to the Shift+Tab cycle without starting in it |
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
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config`; ignore all others |
| `--add-dir` | Add additional working directories |
| `--plugin-dir` | Load a plugin from directory or zip for this session |
| `--plugin-url` | Fetch a plugin zip from URL for this session |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--tmux` | Create a tmux session for the worktree (use with `--worktree`) |
| `--bg` | Start as a background agent (returns immediately) |
| `--exec` | Run a shell command as a PTY-backed background job (use with `--bg`) |
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
| `--remote-control`, `--rc` | Start interactive session with Remote Control enabled |
| `--teleport` | Resume a web session in your local terminal |
| `--chrome` | Enable Chrome browser integration |
| `--no-chrome` | Disable Chrome browser integration for this session |
| `--teammate-mode` | Set agent team display: `auto`, `in-process`, or `tmux` |
| `--json-schema` | Get validated JSON output matching a JSON Schema (print mode) |
| `--exclude-dynamic-system-prompt-sections` | Improve prompt-cache reuse across users/machines |
| `--include-hook-events` | Include hook lifecycle events in output stream (requires `stream-json`) |
| `--include-partial-messages` | Include partial streaming events (requires `stream-json`) |
| `--prompt-suggestions` | Emit predicted next user prompt after each turn (requires `stream-json`) |
| `--replay-user-messages` | Re-emit user messages from stdin on stdout |
| `--no-session-persistence` | Disable session saving (print mode only) |
| `--session-id` | Use a specific session UUID |
| `--setting-sources` | Comma-separated list: `user`, `project`, `local` |
| `--settings` | Path to settings JSON file or inline JSON string |
| `--init` | Run Setup hooks with `init` matcher before session (print mode) |
| `--init-only` | Run Setup and SessionStart hooks, then exit |
| `--maintenance` | Run Setup hooks with `maintenance` matcher (print mode) |
| `--disable-slash-commands` | Disable all skills and commands for this session |
| `--ide` | Automatically connect to IDE on startup |
| `--version`, `-v` | Output version number |

### System Prompt Flags

| Flag | Behavior |
| :--- | :------- |
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag. Use append when Claude should remain a coding assistant with extra rules; use replace when the surface or identity differs entirely from Claude Code's default.

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
| `Monitor` | Yes | Watch something in the background, react to output (v2.1.98+) |
| `NotebookEdit` | Yes | Modifies Jupyter notebook cells |
| `PowerShell` | Yes | Executes PowerShell commands natively |
| `PushNotification` | No | Sends desktop/phone notification |
| `Read` | No | Reads file contents (with images, PDFs, notebooks) |
| `RemoteTrigger` | No | Creates/runs Routines on claude.ai (Pro/Max/Team/Enterprise) |
| `SendMessage` | No | Sends message to agent team teammate (experimental; requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) |
| `Skill` | Yes | Executes a skill within the main conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Task list management |
| `ToolSearch` | No | Searches for and loads deferred tools when tool search is enabled |
| `WaitForMcpServers` | No | Waits for MCP servers still connecting in background |
| `WebFetch` | Yes | Fetches URL content (converts to Markdown, extracts with small model) |
| `WebSearch` | Yes | Searches via Anthropic web search backend |
| `Workflow` | Yes | Runs a dynamic workflow orchestrating subagents |
| `Write` | Yes | Creates or overwrites files |

### Tool Permission Rule Formats

| Rule format | Applies to | Notes |
| :---------- | :--------- | :---- |
| `Bash(npm run *)` | Bash, Monitor | Command pattern matching |
| `PowerShell(Get-ChildItem *)` | PowerShell | Command pattern matching |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP | Path pattern matching |
| `Edit(/src/**)` | Edit, Write, NotebookEdit | Path pattern; also grants Read for same path |
| `Skill(deploy *)` | Skill | Skill name matching |
| `Agent(Explore)` | Agent | Subagent type matching |
| `WebFetch(domain:example.com)` | WebFetch | Domain matching |
| `WebSearch` | WebSearch | No specifier; allow or deny the whole tool |

Used in: `permissions.allow`/`permissions.deny` in settings, `--allowedTools`/`--disallowedTools` flags, subagent `tools`/`disallowedTools` frontmatter, skill `allowed-tools` frontmatter, and hook `if` field.

### In-Session Commands (Key Selection)

Type `/` to see all available commands. Highlights by workflow phase:

**Session & Context Management:**

| Command | Description |
| :------ | :---------- |
| `/clear [name]` | Start new conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Summarize conversation to free context |
| `/context [all]` | Visualize context usage |
| `/resume [session]` | Resume a conversation by ID or name (alias: `/continue`) |
| `/branch [name]` | Fork the conversation at this point |
| `/fork <directive>` | Spawn a forked background subagent (v2.1.161+) |
| `/rewind` | Rewind conversation/code to a previous point (aliases: `/checkpoint`, `/undo`) |
| `/export [filename]` | Export conversation as plain text |
| `/recap` | Generate a one-line session summary |
| `/background [prompt]` | Detach session to run as background agent (alias: `/bg`) |
| `/stop` | Stop the current background session |
| `/btw <question>` | Ask a side question without adding to history |
| `/add-dir <path>` | Add a working directory for this session |
| `/cd <path>` | Move session to a new working directory (v2.1.169+) |

**Code & Task Work:**

| Command | Description |
| :------ | :---------- |
| `/plan [description]` | Enter plan mode |
| `/model [model]` | Switch AI model |
| `/effort [level\|auto]` | Set effort level (`low`–`max`, `ultracode`) |
| `/diff` | Interactive diff viewer |
| `/tasks` | View/manage background tasks (alias: `/bashes`) |
| `/goal [condition\|clear]` | Set a goal Claude works toward across turns |
| `/batch <instruction>` | **[Skill]** Orchestrate large-scale parallel codebase changes |
| `/run` | **[Skill]** Launch and drive your project's app (v2.1.145+) |
| `/verify` | **[Skill]** Confirm a code change works in the running app (v2.1.145+) |
| `/loop [interval] [prompt]` | **[Skill]** Run a prompt on a schedule (alias: `/proactive`) |

**Code Review:**

| Command | Description |
| :------ | :---------- |
| `/code-review [level] [--fix] [--comment] [target]` | **[Skill]** Review diff for bugs and cleanups |
| `/simplify [target]` | **[Skill]** Cleanup-only review, applies fixes (v2.1.154+) |
| `/review [PR]` | Review a pull request locally |
| `/security-review` | Analyze pending changes for security vulnerabilities |
| `/code-review ultra` | Deep multi-agent cloud code review (alias: `/ultrareview`) |

**Configuration:**

| Command | Description |
| :------ | :---------- |
| `/config` | Open Settings interface (alias: `/settings`) |
| `/theme` | Change color theme |
| `/permissions` | Manage allow/ask/deny rules (alias: `/allowed-tools`) |
| `/memory` | Edit CLAUDE.md files, manage auto-memory |
| `/mcp` | Manage MCP server connections |
| `/keybindings` | Open keyboard shortcuts file |
| `/hooks` | View hook configurations |
| `/agents` | Manage agent configurations |
| `/skills` | List available skills |
| `/plugin [subcommand]` | Manage plugins |
| `/init` | Initialize project with a CLAUDE.md guide |
| `/terminal-setup` | Configure terminal keybindings |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/statusline` | Configure status line |
| `/color [color\|default]` | Set prompt bar color for this session |

**Diagnostics:**

| Command | Description |
| :------ | :---------- |
| `/doctor` | Diagnose Claude Code installation |
| `/debug [description]` | **[Skill]** Enable debug logging and troubleshoot |
| `/usage` | Show session cost, plan usage, activity stats (aliases: `/cost`, `/stats`) |
| `/help` | Show help and available commands |
| `/status` | Show version, model, account, connectivity |
| `/release-notes` | View changelog |
| `/feedback [report]` | Report a bug or share session (aliases: `/bug`, `/share`) |

**Remote & Cloud:**

| Command | Description |
| :------ | :---------- |
| `/remote-control` | Enable remote control from claude.ai (alias: `/rc`) |
| `/teleport` | Pull a web session into this terminal (alias: `/tp`) |
| `/desktop` | Continue session in Claude Code Desktop app (alias: `/app`) |
| `/schedule [description]` | Create/manage routines on cloud infrastructure (alias: `/routines`) |
| `/ultraplan <prompt>` | Draft a plan, review in browser, then execute |
| `/autofix-pr [prompt]` | Watch PR and push fixes when CI fails or reviewers comment |
| `/web-setup` | Connect GitHub account to Claude Code on the web |

**Other Notable Commands:**

| Command | Description |
| :------ | :---------- |
| `/copy [N]` | Copy last response to clipboard; pick code blocks interactively |
| `/deep-research <question>` | **[Workflow]** Fan out web searches and synthesize a cited report |
| `/install-github-app` | Set up Claude GitHub Actions for a repo |
| `/workflows` | Watch, pause, resume running and completed workflows |
| `/reload-plugins [--force]` | Reload active plugins without restarting |
| `/reload-skills` | Re-scan skill directories without restarting (v2.1.152+) |
| `/run-skill-generator` | **[Skill]** Teach `/run` and `/verify` about your project |
| `/fewer-permission-prompts` | **[Skill]** Add allowlist entries to reduce permission prompts |
| `/team-onboarding` | Generate a team onboarding guide from session history |
| `/voice [hold\|tap\|off]` | Toggle voice dictation |

### Keyboard Shortcuts

**General Controls:**

| Shortcut | Description |
| :------- | :---------- |
| `Ctrl+C` | Interrupt or clear input |
| `Ctrl+D` | Exit Claude Code |
| `Esc` | Interrupt Claude (stop response mid-turn) |
| `Esc` + `Esc` | Clear input draft, or open rewind menu |
| `Shift+Tab` | Cycle permission modes |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running tasks (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+L` | Redraw screen |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open prompt in external editor |
| `Ctrl+V` | Paste image from clipboard |
| `Ctrl+X Ctrl+K` | Kill all running background subagents |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |

**Text Editing:**

| Shortcut | Description |
| :------- | :---------- |
| `Ctrl+A` | Move cursor to start of line |
| `Ctrl+E` | Move cursor to end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` | Move cursor back one word (needs Option as Meta on macOS) |
| `Alt+F` | Move cursor forward one word (needs Option as Meta on macOS) |

**Multiline Input:**

| Method | Shortcut |
| :----- | :------- |
| Quick escape | `\` then Enter — works in all terminals |
| Control sequence | `Ctrl+J` — works in any terminal |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| VS Code / Cursor / Alacritty / Zed | Run `/terminal-setup` once |

**Quick Input Prefixes:**

| Prefix | Action |
| :----- | :----- |
| `/` at start | Command or skill |
| `!` at start | Shell mode (run commands directly, adds output to context) |
| `@` | Trigger file path autocomplete |

**Transcript Viewer (Ctrl+O to open):**

| Shortcut | Description |
| :------- | :---------- |
| `Ctrl+E` | Toggle show all content |
| `{` / `}` | Jump to previous/next user prompt (fullscreen only) |
| `[` | Write conversation to terminal scrollback (fullscreen only) |
| `v` | Open conversation in `$VISUAL`/`$EDITOR` (fullscreen only) |
| `q`, `Ctrl+C`, `Esc` | Exit transcript view |

### Vim Editor Mode

Enable via `/config` → Editor mode, or set `editorMode: "vim"` in settings.

**Mode Switching:**

| Command | Action |
| :------ | :----- |
| `Esc` | Enter NORMAL mode |
| `i` / `I` | Insert before cursor / at line start |
| `a` / `A` | Insert after cursor / at line end |
| `o` / `O` | Open line below / above |
| `v` / `V` | Start character-wise / line-wise visual selection |

**Navigation (NORMAL mode):** `h/j/k/l`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f{char}`/`t{char}`. In NORMAL mode, `/` opens history search (same as `Ctrl+R`).

**Editing (NORMAL mode):** `x`, `dd`/`D`, `cc`/`C`, `dw`/`cw`/`yw`, `yy`, `p`/`P`, `u` (undo), `.` (repeat), `J` (join lines).

**Text Objects:** `iw`/`aw`, `iW`/`aW`, `i"`/`a"`, `i'`/`a'`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`.

Enter still submits in INSERT mode. Use `Ctrl+J` or `O`/`o` in NORMAL mode to insert a newline.

### Custom Keybindings

Config file: `~/.claude/keybindings.json` (open with `/keybindings`). Changes apply without restarting.

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

Set to `null` to unbind. Actions follow `namespace:action` format.

**Available Contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Scroll`, `Doctor`

**Key Actions:**

| Action | Default | Description |
| :----- | :------ | :---------- |
| `app:interrupt` | Ctrl+C | Cancel current operation |
| `app:exit` | Ctrl+D | Exit Claude Code |
| `app:toggleTodos` | Ctrl+T | Toggle task list |
| `app:toggleTranscript` | Ctrl+O | Toggle transcript viewer |
| `chat:submit` | Enter | Submit message |
| `chat:newline` | Ctrl+J | Insert newline without submitting |
| `chat:cancel` | Escape | Cancel current input |
| `chat:cycleMode` | Shift+Tab | Cycle permission modes |
| `chat:externalEditor` | Ctrl+G / Ctrl+X Ctrl+E | Open in external editor |
| `chat:imagePaste` | Ctrl+V | Paste image from clipboard |
| `chat:killAgents` | Ctrl+X Ctrl+K | Kill all running background subagents |
| `task:background` | Ctrl+B / Ctrl+X Ctrl+B | Background current task |
| `history:search` | Ctrl+R | Open history search |
| `transcript:toggleShowAll` | Ctrl+E | Toggle show all content |
| `transcript:exit` | q / Ctrl+C / Escape | Exit transcript view |

**Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, `Caps Lock`

**Terminal Multiplexer Conflicts:** `Ctrl+B` (tmux prefix), `Ctrl+A` (GNU screen), `Ctrl+Z` (SIGTSTP)

### Terminal Configuration

**Shift+Enter Support:**

| Terminal | Shift+Enter for newline |
| :------- | :---------------------- |
| Ghostty, Kitty, iTerm2, WezTerm, Warp, Apple Terminal, Windows Terminal | Works without setup |
| VS Code, Cursor, Devin Desktop, Alacritty, Zed | Run `/terminal-setup` once |
| gnome-terminal, JetBrains IDEs | Not available; use `Ctrl+J` or `\` then Enter |

**Option/Alt Key on macOS:**

| Terminal | Setting |
| :------- | :------ |
| iTerm2 | Settings → Profiles → Keys → General → set Left/Right Option to "Esc+" |
| Apple Terminal | Settings → Profiles → Keyboard → check "Use Option as Meta Key" |
| VS Code | `"terminal.integrated.macOptionIsMeta": true` |

**tmux Configuration (`~/.tmux.conf`):**

```
set -g allow-passthrough on
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'
```

Run `tmux source-file ~/.tmux.conf` to apply.

**Fullscreen Rendering:** Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1`. Draws to alt-screen; scroll with mouse or PageUp instead of terminal scrollback.

**Notifications:** Set `preferredNotifChannel: "terminal_bell"` in settings for a terminal bell. Configure a Notification hook to run a custom command. Ghostty, Kitty, and iTerm2 send desktop notifications by default.

**Custom Themes:** JSON files in `~/.claude/themes/<slug>.json`. Create interactively with `/theme` → "New custom theme…" (v2.1.118+).

| Field | Description |
| :---- | :---------- |
| `name` | Display label |
| `base` | Starting preset: `dark`, `light`, `dark-daltonized`, `light-daltonized`, `dark-ansi`, `light-ansi` |
| `overrides` | Map of color token names to values |

Color values: `#rrggbb`, `#rgb`, `rgb(r,g,b)`, `ansi256(n)`, `ansi:<name>`. Key tokens: `claude` (brand accent), `text`, `error`, `success`, `warning`, `promptBorder`, `planMode`, `diffAdded`, `diffRemoved`, `userMessageBackground` (fullscreen only).

### Key Tool Behaviors

**Bash:**
- `cd` changes persist within project directory and added dirs; outside, directory resets.
- Environment variables do not persist across Bash calls.
- Shell startup files (`~/.zshrc`, `~/.bashrc`, `~/.profile`) are sourced once at session start.
- Default timeout: 2 minutes (Claude can request up to 10). Override with `BASH_DEFAULT_TIMEOUT_MS` / `BASH_MAX_TIMEOUT_MS`.
- Default output limit: 30,000 characters. Excess saved to file. Override with `BASH_MAX_OUTPUT_LENGTH` (ceiling 150,000).

**Edit:** Exact string replacement only — no regex or fuzzy matching. Requires read-before-edit. `old_string` must appear exactly once (or use `replace_all: true`). Bash commands `cat`, `head`, `tail`, `sed -n`, `grep`, `egrep`, `fgrep` on a single file also satisfy read requirement.

**Glob:** Supports `**` for recursive matching. Results capped at 100 files. Does not respect `.gitignore` by default (unlike Grep).

**Grep:** Built on ripgrep. Output modes: `files_with_matches` (default), `content`, `count`. Respects `.gitignore`. Supports `glob` and `type` scoping and `multiline` mode.

**WebFetch:** Converts HTML to Markdown via small model extraction (lossy). HTTP auto-upgraded to HTTPS. Responses cached 15 minutes. Does not follow cross-host redirects — returns redirect info so Claude can issue a second call. Prompts on first visit to each new domain except preapproved documentation domains.

**Write:** Creates or overwrites entire file. Must have read existing file before overwriting. Use Edit for partial changes.

**NotebookEdit:** Targets cells by `cell_id`. Modes: `replace` (default), `insert`, `delete`. Uses `Edit(...)` path format for permission rules.

**Monitor (v2.1.98+):** Runs a watch script in the background; feeds each output line to Claude. Uses same permission rules as Bash. Not available on Bedrock, Vertex, or Foundry, or when `DISABLE_TELEMETRY` / `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` is set.

**LSP:** Inactive until a code intelligence plugin is installed. Provides jump-to-definition, find references, type info, symbol search, and call hierarchies after file edits.

### /btw Side Questions

`/btw <question>` asks a quick question that never enters conversation history. Runs independently even while Claude is processing. No tool access — uses only what is already in context. Press `f` in the overlay to fork into a new session with full tool access.

### Session Features

- **Command History:** Per working directory; searches all projects by default. `Ctrl+R` opens interactive search; `Ctrl+S` cycles scope (session → project → all). `!` history expansion is disabled.
- **Prompt Suggestions:** Grayed-out predictions after each turn. Press Tab or Right arrow to accept. Disable with `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false`.
- **Task List:** Ctrl+T to toggle; up to 5 tasks shown at a time. Shared across sessions with `CLAUDE_CODE_TASK_LIST_ID=my-project claude`.
- **Session Recap:** Auto one-line recap after 3+ minutes away and 3+ turns. Run `/recap` on demand.
- **PR Review Status:** Clickable colored PR link in footer when on a branch with an open PR. Requires `gh` CLI.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — All CLI commands and flags, system prompt flags
- [Commands](references/claude-code-commands.md) — All in-session slash commands, bundled skills and workflows
- [Interactive Mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, Vim mode, command history, background tasks, shell mode, `/btw`, task list, session recap, PR review status
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) — Keybinding config file format, all contexts and actions, keystroke syntax, chords, unbinding, reserved shortcuts
- [Configure Your Terminal](references/claude-code-terminal-config.md) — Multiline input, Option key setup, notifications, tmux, fullscreen rendering, custom themes, Vim mode
- [Tools Reference](references/claude-code-tools-reference.md) — Complete tool list with permission requirements, per-tool behavior details, permission rule syntax

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure Your Terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
