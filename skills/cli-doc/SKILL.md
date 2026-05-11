---
name: cli-doc
description: Complete official documentation for the Claude Code CLI — launch commands, flags, in-session slash commands, keyboard shortcuts, interactive mode features, keybinding customization, terminal configuration, and built-in tools reference.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, including launch flags, in-session commands, keyboard shortcuts, interactive features, keybindings, terminal setup, and the built-in tools reference.

## Quick Reference

### Launching Claude Code

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start with initial prompt |
| `claude -p "query"` | Non-interactive (print) mode; exit after response |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation |
| `claude -r "<session>"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall binary (`stable`, `latest`, or `2.x.y`) |
| `claude auth login` | Sign in (use `--console` for API key billing) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | List configured subagents grouped by source |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local state for a project (`--dry-run`, `-y`, `--all`) |
| `claude remote-control` | Start a Remote Control server |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `claude ultrareview [target]` | Run ultrareview non-interactively (`--json`, `--timeout`) |

Mistyped subcommands show a suggestion (`Did you mean claude update?`) and exit without starting a session.

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `-p` / `--print` | Non-interactive mode; required for scripting |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--model <name>` | Set model (`sonnet`, `opus`, or full model ID) |
| `--effort <level>` | Set effort: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode <mode>` | Start in: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--allowedTools` | Tools that run without prompting (permission rule syntax) |
| `--disallowedTools` | Tools removed from the model's context entirely |
| `--tools` | Restrict built-in tools: `""` disables all, `"Bash,Edit,Read"` limits |
| `--add-dir <path>` | Add additional working directories for file access |
| `--output-format` | `text`, `json`, or `stream-json` (print mode only) |
| `--input-format` | Input format for print mode: `text` or `stream-json` |
| `--json-schema` | Validated JSON output matching a schema (print mode only) |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Cap API spend (print mode only) |
| `--continue` / `-c` | Load most recent conversation |
| `--resume` / `-r` | Resume by session ID or name; shows picker if omitted |
| `--fork-session` | Create new session ID when resuming (use with `--resume` or `--continue`) |
| `--from-pr` | Resume sessions linked to a PR (number, GitHub, GitLab, or Bitbucket URL) |
| `--name` / `-n` | Set display name for the session |
| `--session-id` | Use a specific UUID for the conversation |
| `--worktree` / `-w` | Start in an isolated git worktree |
| `--tmux` | Create a tmux session for the worktree (requires `--worktree`) |
| `--agent` | Specify an agent for the current session |
| `--agents` | Define custom subagents dynamically via JSON |
| `--system-prompt` | Replace the entire default system prompt |
| `--append-system-prompt` | Append to the default system prompt |
| `--system-prompt-file` | Replace system prompt with file contents |
| `--append-system-prompt-file` | Append file contents to default system prompt |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to the first user message (improves cache reuse, print mode only) |
| `--mcp-config` | Load MCP servers from a JSON file or string |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config`, ignore all other configs |
| `--plugin-dir` | Load a plugin from a directory or `.zip` for this session |
| `--plugin-url` | Fetch a plugin `.zip` from a URL for this session |
| `--dangerously-skip-permissions` | Skip all permission prompts (`bypassPermissions` mode) |
| `--allow-dangerously-skip-permissions` | Add `bypassPermissions` to the Shift+Tab cycle without starting in it |
| `--settings` | Path or inline JSON that overrides settings for this session |
| `--setting-sources` | Comma-separated sources to load: `user`, `project`, `local` |
| `--debug` | Enable debug mode (optional category filter like `"api,mcp"` or `"!statsig"`) |
| `--debug-file <path>` | Write debug logs to a file; implicitly enables debug mode |
| `--verbose` | Show full turn-by-turn output |
| `--version` / `-v` | Print version number |
| `--init` | Run Setup hooks with `init` matcher before session (print mode only) |
| `--init-only` | Run Setup and SessionStart hooks, then exit |
| `--maintenance` | Run Setup hooks with `maintenance` matcher before session (print mode only) |
| `--fallback-model` | Fallback model when default is overloaded (print mode only) |
| `--include-hook-events` | Include hook lifecycle events in output (requires `--output-format stream-json`) |
| `--include-partial-messages` | Include partial streaming events (requires `--print` and `--output-format stream-json`) |
| `--replay-user-messages` | Re-emit user messages from stdin on stdout (requires stream-json for both) |
| `--no-session-persistence` | Disable saving sessions to disk (print mode only) |
| `--remote` | Create a new web session on claude.ai |
| `--teleport` | Pull a web session into this terminal |
| `--remote-control` / `--rc` | Start interactive session with Remote Control enabled |
| `--remote-control-session-name-prefix` | Prefix for auto-generated Remote Control session names |
| `--ide` | Auto-connect to IDE on startup |
| `--teammate-mode` | How agent team teammates display: `auto`, `in-process`, or `tmux` |
| `--chrome` | Enable Chrome browser integration |
| `--no-chrome` | Disable Chrome browser integration for this session |
| `--channels` | MCP servers whose channel notifications Claude should listen for |
| `--betas` | Beta headers for API requests (API key users only) |

### System Prompt Flags

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive; append flags can combine with either. Prefer append flags to preserve built-in capabilities.

---

### In-Session Commands (Slash Commands)

Type `/` to see all available commands. Commands marked **[Skill]** are bundled skills (prompt-based, Claude-invocable).

| Command | Purpose |
| :--- | :--- |
| `/add-dir <path>` | Add a working directory for file access |
| `/agents` | Manage agent configurations |
| `/autofix-pr [prompt]` | Spawn a web session that watches the current branch PR and pushes fixes |
| `/batch <instruction>` | **[Skill]** Orchestrate large-scale parallel changes across a codebase |
| `/branch [name]` | Fork current conversation into a branch (alias: `/fork`) |
| `/btw <question>` | Ask a side question without adding to context |
| `/chrome` | Configure Claude in Chrome settings |
| `/claude-api [migrate\|managed-agents-onboard]` | **[Skill]** Load Claude API reference; migrate model versions |
| `/clear [name]` | Start a new conversation (previous stays in `/resume`; aliases: `/reset`, `/new`) |
| `/color [color\|default]` | Set prompt bar color for the session |
| `/compact [instructions]` | Summarize conversation to free context |
| `/config` | Open Settings (theme, model, editor mode, etc.; alias: `/settings`) |
| `/context [all]` | Visualize context usage and optimization tips |
| `/copy [N]` | Copy last (or Nth-last) assistant response to clipboard |
| `/debug [description]` | **[Skill]** Enable debug logging and troubleshoot issues |
| `/desktop` | Continue session in Claude Code Desktop app (macOS/Windows; alias: `/app`) |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose installation and settings issues |
| `/effort [level\|auto]` | Set model effort (`low`–`max`); arrow slider when no arg |
| `/export [filename]` | Export conversation as plain text |
| `/fast [on\|off]` | Toggle fast mode |
| `/feedback [report]` | Submit feedback (alias: `/bug`) |
| `/fewer-permission-prompts` | **[Skill]** Add allowlist to reduce permission prompts |
| `/focus` | Toggle focus view (fullscreen only) |
| `/heapdump` | Write heap snapshot for diagnosing high memory usage |
| `/hooks` | View hook configurations |
| `/ide` | Manage IDE integrations |
| `/init` | Generate `CLAUDE.md` for the project |
| `/insights` | Generate report analyzing Claude Code sessions |
| `/install-github-app` | Set up Claude GitHub Actions for a repo |
| `/install-slack-app` | Install the Claude Slack app |
| `/keybindings` | Open/create `~/.claude/keybindings.json` |
| `/loop [interval] [prompt]` | **[Skill]** Run a prompt repeatedly (alias: `/proactive`) |
| `/mcp` | Manage MCP server connections |
| `/memory` | Edit CLAUDE.md files and auto-memory settings |
| `/mobile` | Show QR code for Claude mobile app (aliases: `/ios`, `/android`) |
| `/model [model]` | Switch model mid-session |
| `/permissions` | Manage allow/ask/deny rules for tools (alias: `/allowed-tools`) |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/powerup` | Discover features through interactive lessons |
| `/privacy-settings` | View and update privacy settings (Pro/Max only) |
| `/radio` | Open Claude FM lo-fi radio |
| `/recap` | Generate one-line session summary on demand |
| `/release-notes` | View changelog in interactive version picker |
| `/reload-plugins` | Reload all active plugins without restarting |
| `/remote-control` | Enable remote control from claude.ai (alias: `/rc`) |
| `/remote-env` | Configure default remote environment for web sessions |
| `/rename [name]` | Rename the current session |
| `/resume [session]` | Resume a conversation by ID or name (alias: `/continue`) |
| `/review [PR]` | Review a pull request locally |
| `/rewind` | Roll back conversation and/or code (aliases: `/undo`, `/checkpoint`) |
| `/sandbox` | Toggle sandbox mode |
| `/schedule [description]` | Create/manage routines on cloud infrastructure (alias: `/routines`) |
| `/security-review` | Analyze pending branch changes for vulnerabilities |
| `/setup-bedrock` | Configure Amazon Bedrock authentication (when `CLAUDE_CODE_USE_BEDROCK=1`) |
| `/setup-vertex` | Configure Google Vertex AI authentication (when `CLAUDE_CODE_USE_VERTEX=1`) |
| `/simplify [focus]` | **[Skill]** Review and fix recent files for quality and efficiency |
| `/skills` | List available skills |
| `/status` | Show version, model, account, connectivity |
| `/statusline` | Configure the status line |
| `/tasks` | List and manage background tasks (alias: `/bashes`) |
| `/team-onboarding` | Generate team onboarding guide from usage history |
| `/teleport` | Pull a web session into this terminal (alias: `/tp`) |
| `/terminal-setup` | Configure terminal keybindings (VS Code, Cursor, Windsurf, Alacritty, Zed) |
| `/theme` | Change color theme |
| `/tui [default\|fullscreen]` | Switch terminal UI renderer |
| `/ultraplan <prompt>` | Draft a plan in an ultraplan session |
| `/ultrareview [PR]` | Run deep multi-agent code review in a cloud sandbox |
| `/upgrade` | Open upgrade page to switch plan tier |
| `/usage` | Show session cost, plan limits, and activity stats (aliases: `/cost`, `/stats`) |
| `/voice [hold\|tap\|off]` | Toggle voice dictation |
| `/web-setup` | Connect GitHub account to Claude Code on the web |

---

### Keyboard Shortcuts

#### General Controls

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Cancel current input or generation |
| `Ctrl+X Ctrl+K` | Kill all background agents (press twice within 3 seconds) |
| `Ctrl+D` | Exit session |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open in external editor |
| `Ctrl+L` | Redraw screen |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse-search command history |
| `Ctrl+B` | Background running task (tmux: press twice) |
| `Ctrl+T` | Toggle task list |
| `Ctrl+V` / `Cmd+V` (iTerm2) / `Alt+V` | Paste image from clipboard |
| `Shift+Tab` | Cycle permission modes |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking (v2.1.132+ works without Meta config on macOS) |
| `Option+O` / `Alt+O` | Toggle fast mode |
| `Esc` + `Esc` | Rewind or summarize |

#### Text Editing

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+A` / `Ctrl+E` | Move cursor to start/end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+Y` (after `Ctrl+Y`) | Cycle paste history (requires Option as Meta on macOS) |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

#### Multiline Input Methods

| Method | Shortcut |
| :--- | :--- |
| Quick escape | `\` + `Enter` (all terminals) |
| Control sequence | `Ctrl+J` (all terminals) |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| Shift+Enter (configured) | VS Code, Cursor, Windsurf, Alacritty, Zed: run `/terminal-setup` once |

#### Quick Command Prefixes

| Prefix | Behavior |
| :--- | :--- |
| `/` at start | Invoke a command or skill |
| `!` at start | Shell mode — run directly, add output to context |
| `@` | Trigger file path autocomplete |

#### Transcript Viewer Shortcuts (Ctrl+O to open)

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+E` | Toggle show all content |
| `[` | Write conversation to terminal scrollback (fullscreen only) |
| `v` | Open conversation in `$EDITOR` (fullscreen only) |
| `q`, `Ctrl+C`, `Esc` | Exit transcript view |

---

### Vim Editor Mode

Enable via `/config` → Editor mode (or set `editorMode: "vim"` in `settings.json`).

**Mode switching:** `Esc` → NORMAL; `i`/`a`/`o` → INSERT; `v`/`V` → VISUAL

**NORMAL mode highlights:**

| Command | Action |
| :--- | :--- |
| `h`/`j`/`k`/`l` | Move; `j`/`k` navigate history at boundary |
| `w`/`e`/`b` | Word navigation |
| `0`/`$`/`^` | Line start/end/first non-blank |
| `gg`/`G` | Beginning/end of input |
| `f{char}`/`t{char}` | Jump to/before next character occurrence |
| `dd`/`cc`/`yy` | Delete/change/yank line |
| `dw`/`cw`/`yw` | Delete/change/yank word |
| `p`/`P` | Paste after/before cursor |
| `u` | Undo; `.` repeat last change |
| `iw`/`aw`, `i"`/`a"` | Text objects (inner/around word, quotes, brackets, etc.) |

Note: `Enter` still submits in INSERT mode (unlike standard Vim). Use `o`/`O` in NORMAL mode or `Ctrl+J` to insert a newline.

---

### Keybinding Customization

Config file: `~/.claude/keybindings.json` (run `/keybindings` to open/create). Changes apply without restart.

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

Set a binding to `null` to unbind it. Actions use `namespace:action` format (e.g., `chat:submit`, `app:toggleTodos`).

**All contexts:** `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Scroll`, `Doctor`, `Settings`, `Tabs`, `Help`

**Key app/chat actions:**

| Action | Default | Description |
| :--- | :--- | :--- |
| `app:interrupt` | Ctrl+C | Cancel |
| `app:exit` | Ctrl+D | Exit |
| `app:toggleTodos` | Ctrl+T | Toggle task list |
| `app:toggleTranscript` | Ctrl+O | Toggle transcript |
| `chat:submit` | Enter | Submit message |
| `chat:newline` | Ctrl+J | Insert newline |
| `chat:cycleMode` | Shift+Tab | Cycle permission modes |
| `chat:externalEditor` | Ctrl+G, Ctrl+X Ctrl+E | Open external editor |
| `chat:modelPicker` | Meta+P | Open model picker |
| `chat:fastMode` | Meta+O | Toggle fast mode |
| `chat:thinkingToggle` | Meta+T | Toggle extended thinking |
| `chat:imagePaste` | Ctrl+V | Paste image |
| `chat:killAgents` | Ctrl+X Ctrl+K | Kill all background agents |
| `chat:stash` | Ctrl+S | Stash current prompt |
| `settings:search` | / | Enter search mode in Settings |
| `doctor:fix` | F | Fix reported issues in /doctor |
| `plugin:toggle` | Space | Toggle plugin selection |
| `plugin:install` | I | Install selected plugin |

**Keystroke syntax:** modifiers `ctrl`, `shift`, `alt`/`meta`, `cmd`; chords separated by space (`ctrl+k ctrl+s`); standalone uppercase implies Shift.

**Reserved (cannot be rebound):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, `Caps Lock`

**Terminal conflicts:** `Ctrl+B` (tmux prefix — press twice), `Ctrl+A` (GNU screen), `Ctrl+Z` (Unix suspend)

---

### Terminal Configuration

**Shift+Enter for newlines:**

| Terminal | Action needed |
| :--- | :--- |
| Ghostty, Kitty, iTerm2, WezTerm, Warp, Apple Terminal, Windows Terminal | Works without setup |
| VS Code, Cursor, Windsurf, Alacritty, Zed | Run `/terminal-setup` once |
| gnome-terminal, JetBrains IDEs | Not available; use `Ctrl+J` or `\` then Enter |

**tmux configuration** (`~/.tmux.conf`):
```
set -g allow-passthrough on
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'
```
Then run `tmux source-file ~/.tmux.conf`. Also required for Shift+Enter when running inside tmux even if the outer terminal supports it.

**Option key on macOS (required for Alt+B, Alt+F, Alt+Y, Alt+M, Alt+P shortcuts):**
- iTerm2: Settings → Profiles → Keys → set Left/Right Option to "Esc+"
- Apple Terminal: Settings → Profiles → Keyboard → "Use Option as Meta Key"
- VS Code: `"terminal.integrated.macOptionIsMeta": true`

**Notifications:** Set `preferredNotifChannel: "terminal_bell"` in settings, or configure a Notification hook for custom sounds. Desktop notifications reach remote machines over SSH.

**Fullscreen rendering** (fixes flickering/scrollback jumps): run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1`. Adds mouse scrolling; use `PageUp`/`PageDown` or `Ctrl+Home`/`Ctrl+End` to navigate.

**Custom themes:** JSON files in `~/.claude/themes/` with fields `name`, `base` (one of `dark`, `light`, `dark-daltonized`, `light-daltonized`, `dark-ansi`, `light-ansi`), and `overrides` (color token map). Run `/theme` → New custom theme. Key color tokens: `claude` (brand accent), `text`, `error`, `success`, `warning`, `promptBorder`, `planMode`, `diffAdded`, `diffRemoved`. Colors accept `#rrggbb`, `rgb(r,g,b)`, `ansi256(n)`, or `ansi:<name>`.

---

### Built-in Tools Reference

Tools Claude Code can use — names used in permission rules, hook matchers, and subagent configs:

| Tool | Permission | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawn a subagent with its own context window |
| `AskUserQuestion` | No | Ask multiple-choice questions |
| `Bash` | Yes | Execute shell commands |
| `CronCreate` / `CronDelete` / `CronList` | No | Schedule recurring or one-shot prompts in the session |
| `Edit` | Yes | Make targeted file edits |
| `EnterPlanMode` | No | Switch to plan mode |
| `ExitPlanMode` | Yes | Present plan for approval and exit plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Create/exit isolated git worktrees (not available to subagents) |
| `Glob` | No | Find files by pattern |
| `Grep` | No | Search file contents |
| `ListMcpResourcesTool` | No | List resources exposed by connected MCP servers |
| `LSP` | No | Code intelligence (jump to def, find refs, type errors — requires a code intelligence plugin) |
| `Monitor` | Yes | Watch a process; feed output lines to Claude (requires v2.1.98+) |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `PowerShell` | Yes | Execute PowerShell commands (Windows; opt-in elsewhere) |
| `Read` | No | Read file contents |
| `ReadMcpResourceTool` | No | Read a specific MCP resource by URI |
| `SendMessage` | No | Send message to agent team teammate or resume a subagent |
| `ShareOnboardingGuide` | Yes | Upload `ONBOARDING.md` and return a share link (Pro/Max/Team/Enterprise) |
| `Skill` | Yes | Execute a skill within the conversation |
| `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` / `TaskStop` | No | Manage background tasks |
| `TeamCreate` / `TeamDelete` | No | Create/disband agent teams (requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) |
| `TodoWrite` | No | Manage session task checklist (non-interactive/Agent SDK only) |
| `ToolSearch` | No | Search for and load deferred tools when tool search is enabled |
| `WebFetch` | Yes | Fetch content from a URL |
| `WebSearch` | Yes | Perform web searches |
| `Write` | Yes | Create or overwrite files |

**Bash tool notes:** `cd` persists within the project directory; environment variables do not persist. Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to disable directory carry-over. Activate virtualenv before launching Claude Code; use `CLAUDE_ENV_FILE` or a SessionStart hook for persistent env vars.

**LSP tool:** Inactive until a code intelligence plugin is installed. Reports type errors after each edit automatically.

**Monitor tool:** Requires v2.1.98+. Not available on Bedrock, Vertex, or Foundry. Not available when `DISABLE_TELEMETRY` or `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` is set. Uses Bash permission rules.

**PowerShell tool:** On Windows, enable/disable with `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`/`0`. On Linux/macOS, requires `pwsh` (PowerShell 7+). Use `"defaultShell": "powershell"` in settings for interactive `!` commands.

---

### Interactive Mode Features

- **Prompt suggestions:** Grayed-out suggestions based on git history and conversation. Press Tab or Right arrow to accept; start typing to dismiss. Disable with `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false` or in `/config`.
- **`/btw` side questions:** Ephemeral overlay; full context visibility, no tool access, no history impact. Available while Claude is working. No follow-up turns.
- **Task list:** `Ctrl+T` to toggle; appears in status area; persists across compactions. Share across sessions with `CLAUDE_CODE_TASK_LIST_ID=<name>`.
- **Session recap:** Auto-generated after 3+ minutes away with 3+ turns; run `/recap` on demand; disable in `/config`.
- **Background bash:** `Ctrl+B` to background a Bash command mid-execution. Output written to file; Claude retrieves with Read. Disable all backgrounding with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.
- **Shell mode (`!` prefix):** Runs directly; adds output to context; supports Tab autocomplete from history; `Ctrl+B` to background; pasting text starting with `!` auto-enters shell mode.
- **Transcript viewer (`Ctrl+O`):** Shows detailed tool usage. `Ctrl+E` toggles show-all; `[` dumps to scrollback (fullscreen); `v` opens in `$EDITOR` (fullscreen).
- **PR review status:** Clickable PR link in footer with color-coded review state (green=approved, yellow=pending, red=changes requested, gray=draft, purple=merged). Updates every 60 seconds. Requires `gh` CLI.
- **Reverse search (`Ctrl+R`):** Searches across all projects by default; `Ctrl+S` cycles scope (session → project → all); `Tab`/`Esc` to accept; `Enter` to accept and execute.
- **Large paste:** Content over 10,000 characters collapses to `[Pasted text]` placeholder; full content sent on submit.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — launch commands, all CLI flags, system prompt flags
- [Commands](references/claude-code-commands.md) — complete in-session slash command reference
- [Interactive mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, Vim mode, history, background tasks, shell mode, side questions, task list
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) — keybindings.json format, all contexts, all actions, chord syntax, reserved keys
- [Configure your terminal](references/claude-code-terminal-config.md) — Shift+Enter, Option key, tmux, notifications, fullscreen, custom themes
- [Tools reference](references/claude-code-tools-reference.md) — built-in tools table, permission requirements, Bash/LSP/Monitor/PowerShell behavior

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure your terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
