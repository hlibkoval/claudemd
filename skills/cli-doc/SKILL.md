---
name: cli-doc
description: Complete reference for the Claude Code CLI — launch commands, flags, slash commands, keyboard shortcuts, keybindings, terminal configuration, and built-in tools.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, interactive mode, keyboard shortcuts, keybindings, terminal configuration, and built-in tools.

## Quick Reference

### CLI Launch Commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode — run query and exit (non-interactive) |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<name>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install or reinstall native binary (`stable`, `latest`, or version like `2.1.118`) |
| `claude auth login` | Sign in (`--console` for API key billing, `--sso` for SSO) |
| `claude auth logout` | Log out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | Open agent view for background sessions (`--json` for scripting) |
| `claude attach <id>` | Attach to a background session |
| `claude stop <id>` | Stop a background session |
| `claude rm <id>` | Remove a background session from the list |
| `claude logs <id>` | Print recent output from a background session |
| `claude respawn <id>` | Restart a background session with conversation intact |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude setup-token` | Generate a long-lived OAuth token for CI/scripts |
| `claude daemon status` | Show background supervisor state |
| `claude daemon stop --any` | Stop the background supervisor |
| `claude ultrareview [target]` | Run ultrareview non-interactively |
| `claude remote-control` | Start a Remote Control server session |

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Resume most recent conversation |
| `-r`, `--resume` | Resume by ID or name, or open picker |
| `-n`, `--name` | Set session display name |
| `-w`, `--worktree` | Start in an isolated git worktree |
| `--model` | Set model (`sonnet`, `opus`, `haiku`, `fable`, or full model ID) |
| `--effort` | Set effort level (`low`, `medium`, `high`, `xhigh`, `max`) |
| `--permission-mode` | Start in a permission mode (`default`, `acceptEdits`, `plan`, `auto`, `bypassPermissions`) |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--output-format` | Print mode output format (`text`, `json`, `stream-json`) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Budget cap in dollars (print mode) |
| `--allowedTools` | Tools that run without prompting |
| `--disallowedTools` | Deny rules; bare tool name removes it from context entirely |
| `--tools` | Restrict which built-in tools are available |
| `--add-dir` | Add additional working directories |
| `--bg` | Start as background agent and return immediately |
| `--mcp-config` | Load MCP servers from JSON file or string |
| `--plugin-dir` | Load a plugin from a directory or `.zip` for this session |
| `--settings` | Path to a settings file or inline JSON |
| `--system-prompt` | Replace entire default system prompt |
| `--append-system-prompt` | Append text to the default system prompt |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--safe-mode` | Disable all customizations for troubleshooting |
| `--verbose` | Show full turn-by-turn output |
| `--debug` | Enable debug mode with optional category filter |
| `--init-only` | Run Setup and SessionStart hooks then exit |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--fallback-model` | Comma-separated fallback model chain |
| `--advisor <model>` | Enable server-side advisor tool |
| `--remote` | Create a web session on claude.ai |
| `--teleport` | Resume a web session in local terminal |

### System Prompt Flags

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either. Use append flags to keep Claude Code's default identity; use replace flags when running a non-coding agent in a pipeline.

---

### Slash Commands (Inside Sessions)

Type `/` in a session to list all available commands. Key commands by workflow phase:

**Setup:** `/init`, `/memory`, `/mcp`, `/agents`, `/permissions`

**During a task:** `/plan`, `/model`, `/effort`, `/context`, `/compact`, `/btw`

**Parallel work:** `/agents`, `/tasks`, `/background`, `/batch`, `/fork`

**Before shipping:** `/diff`, `/code-review`, `/review`, `/security-review`

**Between sessions:** `/clear`, `/resume`, `/branch`, `/teleport`, `/remote-control`

**When something's wrong:** `/rewind`, `/doctor`, `/debug`, `/feedback`

| Command | Purpose |
| :--- | :--- |
| `/add-dir <path>` | Add a working directory for this session |
| `/agents` | Manage subagent configurations |
| `/background [prompt]` | Detach session to run as background agent |
| `/batch <instruction>` | [Skill] Parallel large-scale codebase changes in isolated worktrees |
| `/branch [name]` | Fork the conversation to try a different direction |
| `/btw <question>` | Ask a side question without adding to conversation history |
| `/cd <path>` | Move session to a new working directory |
| `/clear [name]` | Start fresh; previous conversation stays in `/resume` |
| `/code-review [level] [--fix] [--comment] [target]` | [Skill] Review diff for bugs and cleanup |
| `/compact [instructions]` | Summarize conversation to free context |
| `/config` | Open settings interface (alias: `/settings`) |
| `/context [all]` | Visualize context window usage |
| `/copy [N]` | Copy last assistant response to clipboard |
| `/debug [description]` | [Skill] Enable debug logging and troubleshoot |
| `/deep-research <question>` | [Workflow] Fan-out web research and cited report |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings |
| `/effort [level\|auto]` | Adjust model effort level interactively |
| `/exit` | Exit CLI (alias: `/quit`) |
| `/export [filename]` | Export conversation as plain text |
| `/fast [on\|off]` | Toggle fast mode |
| `/feedback [report]` | Submit feedback or bug report |
| `/fork <directive>` | Spawn forked background subagent that inherits full conversation |
| `/goal [condition\|clear]` | Set a completion condition Claude works toward |
| `/heapdump` | Write heap snapshot for diagnosing high memory usage |
| `/help` | Show help and commands |
| `/hooks` | View hook configurations |
| `/init` | Initialize CLAUDE.md for the project |
| `/keybindings` | Open keyboard shortcuts config file |
| `/loop [interval] [prompt]` | [Skill] Run a prompt repeatedly |
| `/mcp` | Manage MCP server connections |
| `/memory` | Edit CLAUDE.md files and manage auto-memory |
| `/model [model]` | Switch model; arrows adjust effort |
| `/permissions` | Manage allow/ask/deny tool rules (alias: `/allowed-tools`) |
| `/plan [description]` | Enter plan mode |
| `/plugin [subcommand]` | Manage plugins |
| `/recap` | Generate one-line session summary on demand |
| `/reload-plugins [--force]` | Reload all active plugins |
| `/reload-skills` | Re-scan skill directories |
| `/remote-control` | Enable remote control from claude.ai (alias: `/rc`) |
| `/rename [name]` | Rename the current session |
| `/resume [session]` | Resume a conversation by ID or name |
| `/review [PR]` | Review a pull request locally |
| `/rewind` | Rewind conversation and/or code to a checkpoint |
| `/run` | [Skill] Launch and drive the project's app |
| `/schedule [description]` | Create/manage cloud-hosted routines |
| `/security-review` | Analyze branch changes for security vulnerabilities |
| `/simplify [target]` | [Skill] Review and apply code cleanup fixes |
| `/skills` | List available skills |
| `/status` | Open Settings (Status tab) |
| `/stop` | Stop current background session |
| `/tasks` | View and manage background tasks |
| `/teleport` | Pull a web session into local terminal |
| `/terminal-setup` | Configure terminal keybindings (VS Code, Alacritty, Zed, etc.) |
| `/theme` | Change color theme |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/ultraplan <prompt>` | Draft a plan on the web and execute locally or remotely |
| `/ultrareview [PR]` | Deep multi-agent cloud code review (alias for `/code-review ultra`) |
| `/usage` | Show session cost and activity stats |
| `/verify` | [Skill] Confirm a change works in the running app |
| `/vim` | Removed in v2.1.92 — use `/config` → Editor mode |
| `/voice [hold\|tap\|off]` | Toggle voice dictation |
| `/workflows` | Open workflow progress view |

---

### Keyboard Shortcuts (Interactive Mode)

#### General Controls

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Interrupt or clear input |
| `Ctrl+D` | Exit Claude Code |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open prompt in external text editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+V` (or `Alt+V` on WSL) | Paste image from clipboard |
| `Ctrl+B` | Background running tasks |
| `Ctrl+T` | Toggle task list |
| `Ctrl+X Ctrl+K` | Stop all running background subagents |
| `Esc` | Interrupt Claude (stop current response) |
| `Esc Esc` | Clear input draft (saves to history) or open rewind menu if input is empty |
| `Shift+Tab` | Cycle permission modes (`default` → `acceptEdits` → `plan` → `auto` → ...) |
| `Option+P` / `Alt+P` | Switch model without clearing prompt |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |

#### Text Editing

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+A` | Move cursor to start of current line |
| `Ctrl+E` | Move cursor to end of current line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+Y` | Cycle paste history (after `Ctrl+Y`) |
| `Alt+B` | Move cursor back one word |
| `Alt+F` | Move cursor forward one word |

#### Multiline Input

| Method | Shortcut |
| :--- | :--- |
| Quick escape | `\` then `Enter` — works in all terminals |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| Control sequence | `Ctrl+J` — works in any terminal |
| Option key | `Option+Enter` after enabling Option as Meta on macOS |

#### Quick Input Prefixes

| Prefix | Effect |
| :--- | :--- |
| `/` at start | Open command/skill menu |
| `!` at start | Shell mode — run command directly, output added to conversation |
| `@` | Trigger file path autocomplete |

#### Command History (Ctrl+R search)

1. Press `Ctrl+R` to activate reverse search
2. Type to filter; `Ctrl+R` again cycles older matches
3. `Ctrl+S` cycles scope: session → project → all projects
4. `Tab` or `Esc` to accept and keep editing; `Enter` to accept and execute
5. `Ctrl+C` cancels and restores original input

---

### Vim Editor Mode

Enable via `/config` → Editor mode or set `"editorMode": "vim"` in `~/.claude/settings.json`.

#### Mode Switching

| Key | Action | From |
| :--- | :--- | :--- |
| `Esc` | Enter NORMAL mode | INSERT, VISUAL |
| `i` / `I` | Insert before cursor / at line start | NORMAL |
| `a` / `A` | Insert after cursor / at line end | NORMAL |
| `o` / `O` | Open line below / above | NORMAL |
| `v` / `V` | Character-wise / line-wise visual selection | NORMAL |

#### NORMAL Mode Navigation

| Key | Action |
| :--- | :--- |
| `h`/`j`/`k`/`l` | Left/down/up/right |
| `w` / `e` / `b` | Next word / end of word / previous word |
| `0` / `$` / `^` | Line start / end / first non-blank |
| `gg` / `G` | Beginning / end of input |
| `f{char}` / `F{char}` | Jump to next/previous char occurrence |
| `/` | Open history search (same as `Ctrl+R`) |

#### NORMAL Mode Editing

| Key | Action |
| :--- | :--- |
| `x` | Delete character |
| `dd` / `D` | Delete line / to end of line |
| `cc` / `C` | Change line / to end of line |
| `yy` / `Y` | Yank line |
| `p` / `P` | Paste after / before cursor |
| `u` | Undo |
| `.` | Repeat last change |

---

### Keybindings Configuration

File: `~/.claude/keybindings.json` (open with `/keybindings`). Changes apply live without restart.

Structure: a `bindings` array of context blocks. Each block maps keystrokes to action strings, or `null` to unbind.

| Context | Scope |
| :--- | :--- |
| `Global` | Everywhere |
| `Chat` | Main chat input |
| `Autocomplete` | Autocomplete menu |
| `Confirmation` | Permission dialogs |
| `Transcript` | Transcript viewer |
| `HistorySearch` | `Ctrl+R` search mode |
| `Task` | Background task running |
| `ThemePicker` | Theme picker dialog |
| `DiffDialog` | Diff viewer |
| `ModelPicker` | Model picker |
| `Select` | Generic list/select |
| `Settings` | Settings menu |
| `Scroll` | Fullscreen conversation scrolling |

Key action reference (selected):

| Action | Default | Context |
| :--- | :--- | :--- |
| `app:interrupt` | `Ctrl+C` | Global |
| `app:exit` | `Ctrl+D` | Global |
| `app:toggleTodos` | `Ctrl+T` | Global |
| `app:toggleTranscript` | `Ctrl+O` | Global |
| `chat:submit` | `Enter` | Chat |
| `chat:newline` | `Ctrl+J` | Chat |
| `chat:cycleMode` | `Shift+Tab` | Chat |
| `chat:modelPicker` | `Meta+P` | Chat |
| `chat:thinkingToggle` | `Meta+T` | Chat |
| `chat:fastMode` | `Meta+O` | Chat |
| `chat:externalEditor` | `Ctrl+G`, `Ctrl+X Ctrl+E` | Chat |
| `chat:imagePaste` | `Ctrl+V` | Chat |
| `task:background` | `Ctrl+B` | Task |
| `transcript:exit` | `q`, `Ctrl+C`, `Esc` | Transcript |
| `history:search` | `Ctrl+R` | Global |

Keystroke syntax: `ctrl+k`, `shift+tab`, `meta+p`, `ctrl+k ctrl+s` (chord). Set to `null` to unbind. Reserved (cannot rebind): `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, `Caps Lock`.

---

### Terminal Configuration

| Symptom | Fix |
| :--- | :--- |
| Shift+Enter submits instead of newline | Run `/terminal-setup` in VS Code/Cursor/Alacritty/Zed; or use `Ctrl+J` everywhere |
| Option key shortcuts do nothing on macOS | Enable "Option as Meta": iTerm2 → Profiles → Keys → `Esc+`; Apple Terminal → Keyboard → "Use Option as Meta Key"; VS Code → `"terminal.integrated.macOptionIsMeta": true` |
| No notification when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` in settings, or configure a Notification hook |
| Running inside tmux | Add to `~/.tmux.conf`: `set -g allow-passthrough on`, `set -s extended-keys on`, `set -as terminal-features 'xterm*:extkeys'` |
| Flicker or scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Vim keys in the prompt | `/config` → Editor mode → vim, or `"editorMode": "vim"` in settings.json |

**Custom themes:** JSON files in `~/.claude/themes/`. Fields: `name`, `base` (dark/light/dark-daltonized/etc.), `overrides` (token map). Run `/theme` → "New custom theme…" to create interactively. Changes reload live.

---

### Built-in Tools Reference

Tools are used by Claude automatically. Reference tool names in permission rules, hook matchers, and subagent definitions.

| Tool | Description | Permission Required |
| :--- | :--- | :--- |
| `Agent` | Spawns a subagent with its own context window | No |
| `AskUserQuestion` | Asks multiple-choice clarifying questions | No |
| `Bash` | Executes shell commands | Yes |
| `CronCreate` / `CronDelete` / `CronList` | Schedule/cancel/list session-scoped tasks | No |
| `Edit` | Targeted file edits via exact string replacement | Yes |
| `EnterPlanMode` / `ExitPlanMode` | Switch to/from plan mode | No / Yes |
| `EnterWorktree` / `ExitWorktree` | Create or switch into a git worktree | No |
| `Glob` | Find files by name pattern | No |
| `Grep` | Search file contents with ripgrep | No |
| `LSP` | Code intelligence (jump to def, find refs, type info) | No |
| `Monitor` | Watch a command in background and react to output | Yes |
| `NotebookEdit` | Modify Jupyter notebook cells | Yes |
| `PowerShell` | Execute PowerShell commands natively | Yes |
| `PushNotification` | Send desktop or phone notification | No |
| `Read` | Read file contents with line numbers | No |
| `RemoteTrigger` | Create/manage cloud Routines | No |
| `Skill` | Execute a skill within the main conversation | Yes |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | Manage session task checklist | No |
| `WebFetch` | Fetch and extract content from a URL | Yes |
| `WebSearch` | Perform web searches | Yes |
| `Workflow` | Run a dynamic workflow script | Yes |
| `Write` | Create or overwrite files | Yes |

**Permission rule formats:**

| Rule | Applies to | Example |
| :--- | :--- | :--- |
| `Bash(npm run *)` | Bash, Monitor | Allow matching commands |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP | Path pattern |
| `Edit(/src/**)` | Edit, Write, NotebookEdit | Path pattern |
| `WebFetch(domain:example.com)` | WebFetch | Domain match |
| `Agent(Explore)` | Agent | Subagent type |
| `Skill(deploy *)` | Skill | Skill name |
| `WebSearch` | WebSearch | No specifier |

**Bash tool:** 2-minute default timeout (up to 10 minutes with `timeout` param); 30,000-char output limit (up to 150,000 with `BASH_MAX_OUTPUT_LENGTH`). `cd` in main session persists within project dir. Env vars do not persist across commands.

**Edit tool:** Requires read-before-edit; `old_string` must be unique and match exactly. `replace_all: true` to replace all occurrences.

**Glob:** Results sorted by modification time, capped at 100 files. Does not respect `.gitignore` by default.

**Grep:** Built on ripgrep. Output modes: `files_with_matches` (default), `content`, `count`. Respects `.gitignore`.

**WebFetch:** Converts HTML to Markdown; extraction is lossy. Caches 15 minutes. Does not follow cross-host redirects automatically.

**Monitor tool:** Requires Claude Code v2.1.98+. Uses Bash permission rules. Not available on Bedrock, Vertex, or Foundry.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — All CLI commands and flags, including system prompt flags
- [Commands Reference](references/claude-code-commands.md) — Every slash command inside sessions, with bundled skills and workflows marked
- [Interactive Mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, Vim editor mode, command history, background bash, shell mode, prompt suggestions, `/btw`, task list, session recap
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) — Keybindings file format, all contexts and actions, keystroke syntax, reserved shortcuts
- [Configure Your Terminal](references/claude-code-terminal-config.md) — Shift+Enter, Option key, terminal bell, tmux, fullscreen rendering, custom themes, Vim keybindings
- [Tools Reference](references/claude-code-tools-reference.md) — Every built-in tool with permission requirements, rule formats, and per-tool behavior details

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands Reference: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure Your Terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
