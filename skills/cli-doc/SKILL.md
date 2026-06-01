---
name: cli-doc
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, including CLI commands and flags, slash commands, interactive mode shortcuts, keybindings customization, terminal configuration, and the built-in tools reference.

## Quick Reference

### CLI Entry Points

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode: run query and exit (non-interactive) |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install or reinstall native binary (`stable`, `latest`, or version number) |
| `claude auth login` | Sign in (use `--console` for API/Anthropic Console billing) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON |
| `claude agents` | Open agent view for background sessions |
| `claude attach <id>` | Attach to a background session |
| `claude logs <id>` | Print output from a background session |
| `claude stop <id>` | Stop a background session |
| `claude rm <id>` | Remove a background session |
| `claude respawn <id>` | Restart a background session with its conversation intact |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude remote-control` | Start a Remote Control server |
| `claude setup-token` | Generate a long-lived OAuth token for CI/scripts |
| `claude ultrareview [target]` | Run ultrareview non-interactively |
| `claude daemon status` | Print background supervisor state |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `-p`, `--print` | Print mode: non-interactive, exits after response |
| `-c`, `--continue` | Continue most recent conversation |
| `-r`, `--resume` | Resume session by ID or name |
| `-n`, `--name` | Set display name for the session |
| `-w`, `--worktree` | Start Claude in an isolated git worktree |
| `--bg` | Start session as background agent |
| `--model` | Set model (`sonnet`, `opus`, or full model ID) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Begin in a mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--output-format` | Print mode output format: `text`, `json`, `stream-json` |
| `--input-format` | Print mode input format: `text`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Max API spend in dollars (print mode only) |
| `--tools` | Restrict which built-in tools are available (`""` to disable all) |
| `--allowedTools` | Tools that execute without permission prompts |
| `--disallowedTools` | Deny rules for tools |
| `--add-dir` | Add additional working directories |
| `--mcp-config` | Load MCP servers from JSON file or string |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append text to the default system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append file contents to default system prompt |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--settings` | Path to settings JSON or inline JSON string |
| `--plugin-dir` | Load a plugin from a local directory or zip (repeatable) |
| `--plugin-url` | Fetch a plugin zip from a URL (repeatable) |
| `--init-only` | Run Setup and SessionStart hooks then exit |
| `--verbose` | Show full turn-by-turn output |
| `--debug` | Enable debug mode (optional category filter) |
| `--debug-file <path>` | Write debug logs to a specific file |
| `--remote` | Create a new web session on claude.ai |
| `--teleport` | Resume a web session in local terminal |
| `--fork-session` | When resuming, create a new session ID |
| `--fallback-model` | Auto-fallback model when default is unavailable (print/background only) |
| `--from-pr` | Resume sessions linked to a specific pull request |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message for better prompt cache reuse |
| `--json-schema` | Get validated JSON output matching a schema (print mode only) |
| `--agent` | Specify an agent for the current session |
| `--agents` | Define custom subagents dynamically via JSON |
| `--teammate-mode` | Set agent team display: `auto`, `in-process`, or `tmux` |
| `--chrome` | Enable Chrome browser integration |
| `--ide` | Auto-connect to IDE on startup |
| `--exec` | Run a shell command as a background job instead of a Claude session (use with `--bg`) |
| `--prompt-suggestions` | Emit prompt suggestions after each turn (requires print mode + `stream-json` + `--verbose`) |
| `--remote-control`, `--rc` | Start interactive session with Remote Control enabled |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can be combined with either replacement flag. Use append flags when Claude should remain a coding assistant; use replacement flags for non-coding pipelines where the default identity does not fit.

### Slash Commands (In-Session)

Type `/` to see all commands; type `/` followed by letters to filter. Commands are only recognized at the start of a message.

| Command | Type | Purpose |
|:--------|:-----|:--------|
| `/add-dir <path>` | Built-in | Add a working directory for the session |
| `/agents` | Built-in | Manage subagent configurations |
| `/autofix-pr [prompt]` | Built-in | Spawn a web session to auto-fix PR CI failures and review comments |
| `/background [prompt]` | Built-in | Detach session to run as background agent |
| `/batch <instruction>` | Skill | Orchestrate large-scale parallel codebase changes |
| `/branch [name]` | Built-in | Fork the current conversation at this point |
| `/btw <question>` | Built-in | Side question — ephemeral, not added to conversation history |
| `/clear [name]` | Built-in | Start fresh conversation (previous stays in `/resume`) |
| `/code-review [level] [--fix] [--comment] [target]` | Skill | Review diff for bugs and cleanups; `--fix` applies findings; `ultra` runs cloud review |
| `/color [color]` | Built-in | Set prompt bar color for the session |
| `/compact [instructions]` | Built-in | Summarize context to free up token space |
| `/config` | Built-in | Open Settings interface |
| `/context [all]` | Built-in | Visualize context usage as a colored grid |
| `/copy [N]` | Built-in | Copy last assistant response to clipboard |
| `/debug [description]` | Skill | Enable debug logging and troubleshoot issues |
| `/deep-research <question>` | Workflow | Fan-out web searches and synthesize a cited report |
| `/diff` | Built-in | Interactive diff viewer for uncommitted changes |
| `/doctor` | Built-in | Diagnose installation and settings issues |
| `/effort [level\|auto]` | Built-in | Set model effort level interactively |
| `/exit` | Built-in | Exit CLI (detaches if in a background session) |
| `/export [filename]` | Built-in | Export conversation as plain text |
| `/fast [on\|off]` | Built-in | Toggle fast mode |
| `/feedback` | Built-in | Submit feedback or report a bug |
| `/fewer-permission-prompts` | Skill | Add permission allowlist to reduce prompts |
| `/focus` | Built-in | Toggle focus view (last prompt + final response only) |
| `/goal [condition\|clear]` | Built-in | Set a completion goal; Claude works until condition is met |
| `/help` | Built-in | Show help and available commands |
| `/hooks` | Built-in | View hook configurations |
| `/init` | Built-in | Initialize project CLAUDE.md |
| `/insights` | Built-in | Generate report analyzing Claude Code sessions |
| `/keybindings` | Built-in | Open or create keybindings config file |
| `/loop [interval] [prompt]` | Skill | Run a prompt repeatedly on a schedule |
| `/mcp` | Built-in | Manage MCP server connections and OAuth |
| `/memory` | Built-in | Edit CLAUDE.md files and manage auto-memory |
| `/model [model]` | Built-in | Switch AI model and save as default |
| `/permissions` | Built-in | Manage allow/ask/deny permission rules |
| `/plan [description]` | Built-in | Enter plan mode |
| `/plugin` | Built-in | Manage plugins |
| `/recap` | Built-in | Generate a one-line session summary on demand |
| `/reload-plugins` | Built-in | Reload all active plugins without restarting |
| `/reload-skills` | Built-in | Re-scan skill directories for changes during the session |
| `/remote-control` | Built-in | Enable remote control from claude.ai |
| `/rename [name]` | Built-in | Rename current session |
| `/resume [session]` | Built-in | Resume a conversation by ID or name |
| `/review [PR]` | Built-in | Review a pull request locally |
| `/rewind` | Built-in | Roll back conversation/code to a checkpoint |
| `/run` | Skill | Launch app to verify a change in the running app |
| `/run-skill-generator` | Skill | Teach `/run` and `/verify` how to build and launch your project |
| `/schedule [description]` | Built-in | Create/manage routines on claude.ai infrastructure |
| `/security-review` | Built-in | Analyze pending changes for security vulnerabilities |
| `/simplify [target]` | Skill | Review changed code for cleanup opportunities, apply fixes |
| `/skills` | Built-in | List available skills |
| `/status` | Built-in | Show version, model, account, and connectivity |
| `/tasks` | Built-in | List and manage background tasks |
| `/team-onboarding` | Built-in | Generate a team onboarding guide from usage history |
| `/teleport` | Built-in | Pull a web session into this terminal |
| `/terminal-setup` | Built-in | Configure terminal keybindings (VS Code, Cursor, etc.) |
| `/theme` | Built-in | Change color theme |
| `/tui [default\|fullscreen]` | Built-in | Set terminal UI renderer |
| `/ultraplan <prompt>` | Built-in | Draft a plan, review in browser, execute |
| `/ultrareview [PR]` | Built-in | Deep multi-agent cloud code review |
| `/usage` | Built-in | Show session cost and plan usage stats |
| `/verify` | Skill | Confirm a change works by running the app |
| `/voice [hold\|tap\|off]` | Built-in | Toggle voice dictation |
| `/workflows` | Built-in | Watch/manage running workflows |

### Interactive Mode Keyboard Shortcuts

#### General Controls

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Interrupt operation or clear input |
| `Ctrl+D` | Exit session |
| `Esc` | Stop current response (keeps work done so far) |
| `Esc` + `Esc` | Clear input draft, or open rewind menu when input is empty |
| `Shift+Tab` | Cycle permission modes |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running tasks (tmux users press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+L` | Redraw screen |
| `Ctrl+X Ctrl+K` | Kill all running background subagents (press twice to confirm) |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open prompt in external editor |
| `Ctrl+V` / `Cmd+V` (iTerm2) / `Alt+V` (Windows) | Paste image from clipboard |
| `Option+P` (macOS) / `Alt+P` | Switch model without clearing prompt |
| `Option+T` (macOS) / `Alt+T` | Toggle extended thinking |
| `Option+O` (macOS) / `Alt+O` | Toggle fast mode |

#### Text Editing

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+A` | Move cursor to start of current line |
| `Ctrl+E` | Move cursor to end of current line |
| `Ctrl+K` | Delete to end of line (stores for paste) |
| `Ctrl+U` | Delete from cursor to line start (stores for paste) |
| `Ctrl+W` | Delete previous word (stores for paste) |
| `Ctrl+Y` | Paste deleted text |
| `Alt+Y` (after `Ctrl+Y`) | Cycle paste history |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

#### Multiline Input

| Method | Shortcut |
|:-------|:---------|
| Quick escape | `\` + `Enter` — works in all terminals |
| Control sequence | `Ctrl+J` — works in any terminal |
| Shift+Enter (native) | iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| Shift+Enter (setup) | VS Code, Cursor, Windsurf, Alacritty, Zed — run `/terminal-setup` once |

#### Transcript Viewer (toggled with `Ctrl+O`)

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+E` | Toggle show all content |
| `{` / `}` | Jump to previous/next user prompt (fullscreen only) |
| `[` | Write conversation to terminal scrollback (fullscreen only) |
| `v` | Open conversation in `$VISUAL`/`$EDITOR` (fullscreen only) |
| `q`, `Ctrl+C`, `Esc` | Exit transcript view |

#### Quick Command Prefixes

| Prefix | Action |
|:-------|:-------|
| `/` at start | Command or skill |
| `!` at start | Shell mode — run commands directly, adds output to context |
| `@` | File path autocomplete |

### Vim Editor Mode

Enable via `/config` → Editor mode (or set `editorMode: "vim"` in settings).

| Category | Commands |
|:---------|:---------|
| Mode switching | `i`/`I`/`a`/`A`/`o`/`O` → INSERT; `v`/`V` → VISUAL; `Esc` → NORMAL |
| Navigation | `h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f{char}`, `t{char}`, `;`/`,` |
| Editing | `x`, `dd`/`D`, `cc`/`C`, `yy`/`Y`, `p`/`P`, `u`, `.`, `J`, `>>`/`<<` |
| Text objects | `iw`/`aw`, `iW`/`aW`, `i"`/`a"`, `i'`/`a'`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{` |

Enter submits in INSERT mode. Use `o`/`O` in NORMAL mode or `Ctrl+J` to insert a newline without submitting.

### Keybindings Configuration

File: `~/.claude/keybindings.json` (open with `/keybindings`). Changes apply without restarting.

```json
{
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

**Contexts:** `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Settings`, `Scroll`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Footer`, `MessageSelector`, `Attachments`, `Doctor`, `Help`, `Tabs`

**Key actions by namespace:**

| Namespace | Example actions |
|:----------|:----------------|
| `app:` | `app:interrupt`, `app:exit`, `app:toggleTodos`, `app:toggleTranscript`, `app:redraw` |
| `chat:` | `chat:submit`, `chat:newline`, `chat:cycleMode`, `chat:externalEditor`, `chat:imagePaste`, `chat:modelPicker`, `chat:fastMode`, `chat:thinkingToggle`, `chat:killAgents`, `chat:stash`, `chat:undo` |
| `history:` | `history:search`, `history:previous`, `history:next` |
| `transcript:` | `transcript:toggleShowAll`, `transcript:exit` |
| `scroll:` | `scroll:pageUp`, `scroll:pageDown`, `scroll:top`, `scroll:bottom`, `scroll:lineUp`, `scroll:lineDown` |
| `diff:` | `diff:dismiss`, `diff:previousFile`, `diff:nextFile`, `diff:viewDetails`, `diff:previousSource`, `diff:nextSource` |
| `confirm:` | `confirm:yes`, `confirm:no`, `confirm:toggle`, `confirm:cycleMode`, `confirm:toggleExplanation` |
| `voice:` | `voice:pushToTalk` |
| `selection:` | `selection:copy`, `selection:extendLeft`, `selection:extendRight`, `selection:extendUp`, `selection:extendDown` |

Set an action to `null` to unbind it. Unbinding chord prefixes: unbind all chords on a prefix, then the prefix can be used as a standalone binding.

**Keystroke syntax:** `ctrl+k`, `shift+tab`, `meta+p`, `ctrl+shift+c`; chord: `ctrl+k ctrl+s`; uppercase implies Shift (`K` = `shift+k`)

**Reserved** (cannot rebind): `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, Caps Lock

**Terminal conflicts:** `Ctrl+B` (tmux prefix), `Ctrl+A` (GNU screen), `Ctrl+Z` (SIGTSTP)

### Built-in Tools Reference

| Tool | Permission? | Description |
|:-----|:------------|:------------|
| `Agent` | No | Spawn a subagent with its own context window |
| `AskUserQuestion` | No | Ask multiple-choice questions for clarification |
| `Bash` | Yes | Execute shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Schedule recurring or one-shot prompts in-session |
| `Edit` | Yes | Targeted exact-string replacement in files |
| `EnterPlanMode` / `ExitPlanMode` | No / Yes | Switch in/out of plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Create/exit isolated git worktrees |
| `Glob` | No | Find files by name pattern (up to 100, sorted by modification time) |
| `Grep` | No | Search file contents with ripgrep regex |
| `LSP` | No | Code intelligence (requires language server plugin) |
| `Monitor` | Yes | Watch a command's output and react to changes (v2.1.98+) |
| `NotebookEdit` | Yes | Edit Jupyter notebook cells by `cell_id` |
| `PowerShell` | Yes | Execute PowerShell commands (Windows / opt-in elsewhere) |
| `PushNotification` | No | Send desktop/phone notification |
| `Read` | No | Read file contents (also images, PDFs, Jupyter notebooks) |
| `RemoteTrigger` | No | Create/run Routines on claude.ai |
| `ScheduleWakeup` | No | Reschedule next iteration of a self-paced loop |
| `SendMessage` | No | Send message to agent team teammate (experimental) |
| `Skill` | Yes | Execute a skill in the main conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Manage session task list |
| `ToolSearch` | No | Search for and load deferred tools (when tool search enabled) |
| `WaitForMcpServers` | No | Wait for MCP servers still connecting in background |
| `WebFetch` | Yes | Fetch a URL and extract content via a summarizing prompt |
| `WebSearch` | Yes | Search the web, returns titles and URLs |
| `Workflow` | Yes | Run a dynamic multi-subagent workflow |
| `Write` | Yes | Create or overwrite a file |

#### Key Tool Behaviors

**Bash:** `cd` persists within project/additional directories; env vars do not persist. Default timeout 2 min (max 10 min), output cap 30,000 chars (hard ceiling 150,000). Override with `BASH_DEFAULT_TIMEOUT_MS`, `BASH_MAX_TIMEOUT_MS`, `BASH_MAX_OUTPUT_LENGTH`.

**Edit:** Requires reading the file first in the conversation. `old_string` must match exactly and appear exactly once (or use `replace_all: true`).

**Glob:** Does not respect `.gitignore` by default (set `CLAUDE_CODE_GLOB_NO_IGNORE=false` to enable). Results sorted by modification time, capped at 100.

**Grep:** Uses ripgrep regex syntax. Respects `.gitignore`. Output modes: `files_with_matches` (default), `content`, `count`. Scope with `glob` or `type` parameters; set `multiline: true` for cross-line matching.

**WebFetch:** Converts HTML to Markdown via a summarizing model — lossy by design. Cached 15 min. Does not auto-follow cross-host redirects. HTTP upgraded to HTTPS.

**WebSearch:** Up to 8 internal backend searches per call. Does not fetch pages — Claude follows up with WebFetch to read results. Not available on Amazon Bedrock.

**Monitor:** Not available on Bedrock, Vertex, Foundry, or when `DISABLE_TELEMETRY`/`CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` is set.

**Write:** Must have read the target file at least once in the conversation before overwriting an existing file.

#### Permission Rule Format

| Rule | Applies to |
|:-----|:-----------|
| `Bash(npm run *)` | Bash, Monitor |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP |
| `Edit(/src/**)` | Edit, Write, NotebookEdit |
| `WebFetch(domain:example.com)` | WebFetch |
| `Skill(deploy *)` | Skill |
| `Agent(Explore)` | Agent |
| `WebSearch` | WebSearch (no specifier) |

An `Edit(...)` allow rule also grants read access to the same path.

### Terminal Configuration

| Symptom | Fix |
|:--------|:----|
| Shift+Enter submits instead of newline | Run `/terminal-setup` (VS Code, Cursor, Windsurf, Alacritty, Zed) |
| Option shortcuts do nothing on macOS | Enable "Use Option as Meta Key" in terminal settings |
| No notification when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` in settings, or use a Notification hook |
| Display flickers / scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| tmux: Shift+Enter or notifications broken | Add lines below to `~/.tmux.conf`, then `tmux source-file ~/.tmux.conf` |

**tmux configuration:**
```
set -g allow-passthrough on
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'
```

**Custom themes:** stored in `~/.claude/themes/<slug>.json`. Fields: `name` (display label), `base` (`dark`, `light`, `dark-daltonized`, `light-daltonized`, `dark-ansi`, `light-ansi`), `overrides` (map of color tokens to values). Color formats: `#rrggbb`, `#rgb`, `rgb(r,g,b)`, `ansi256(n)`, `ansi:<name>`. Select via `/theme`.

Key color token groups: text/accent (`claude`, `text`, `inactive`, `subtle`), status (`success`, `error`, `warning`), mode indicators (`promptBorder`, `planMode`, `autoAccept`, `bashBorder`), diff (`diffAdded`, `diffRemoved`, `diffAddedWord`, `diffRemovedWord`), fullscreen (`userMessageBackground`, `selectionBg`).

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — All CLI commands and flags, system prompt flag details
- [Commands](references/claude-code-commands.md) — Complete slash command reference, bundled skills and workflows
- [Interactive Mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, Vim editor mode, command history, background tasks, shell mode, prompt suggestions, `/btw` side questions, task list, session recap, PR review status
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) — Keybindings file format, all contexts and actions, keystroke syntax, unbinding, reserved shortcuts, vim mode interaction
- [Configure Your Terminal](references/claude-code-terminal-config.md) — Multiline input, Option key on macOS, notifications, tmux setup, custom themes and color tokens, fullscreen rendering, Vim mode
- [Tools Reference](references/claude-code-tools-reference.md) — All built-in tools with permission requirements and per-tool behavior (Bash, Edit, Glob, Grep, LSP, Monitor, NotebookEdit, PowerShell, Read, WebFetch, WebSearch, Write)

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure Your Terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
