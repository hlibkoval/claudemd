---
name: cli-doc
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for Claude Code's command-line interface, slash commands, interactive mode, keyboard shortcuts, terminal configuration, and built-in tools.

## Quick Reference

### Core CLI Commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode: query then exit (non-interactive) |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>"` | Resume session by ID or name |
| `claude update` / `claude install [version]` | Update or reinstall the binary |
| `claude auth login/logout/status` | Manage authentication |
| `claude agents` | Open agent view for background sessions |
| `claude attach <id>` | Attach to a background session |
| `claude stop/rm/logs/respawn <id>` | Manage background sessions |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude remote-control` | Start Remote Control server |
| `claude ultrareview [target]` | Run ultrareview non-interactively |
| `claude daemon status/stop` | Manage background supervisor |
| `claude setup-token` | Generate long-lived OAuth token for CI |

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Load most recent conversation |
| `-r`, `--resume` | Resume session by ID or name |
| `-n`, `--name` | Set display name for the session |
| `-w`, `--worktree` | Start in an isolated git worktree |
| `--model` | Set model (`sonnet`, `opus`, `haiku`, `fable`, or full ID) |
| `--effort` | Set effort level (`low`, `medium`, `high`, `xhigh`, `max`) |
| `--permission-mode` | Start in `default`, `acceptEdits`, `plan`, `auto`, or `bypassPermissions` |
| `--dangerously-skip-permissions` | Skip all permission prompts |
| `--bg` | Start as background agent and return immediately |
| `--bare` | Minimal mode — skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--safe-mode` | Start with all customizations disabled for troubleshooting |
| `--add-dir` | Add additional working directories |
| `--mcp-config` | Load MCP servers from JSON file or string |
| `--plugin-dir` | Load plugin from directory or .zip for this session |
| `--tools` | Restrict which built-in tools Claude can use |
| `--allowedTools` | Tools that execute without prompting |
| `--disallowedTools` | Deny rules for tools |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Maximum spend on API calls (print mode only) |
| `--system-prompt` | Replace entire default system prompt |
| `--append-system-prompt` | Append text to default system prompt |
| `--verbose` | Enable verbose logging |
| `--debug` | Enable debug mode with optional category filtering |
| `--advisor <model>` | Enable server-side advisor tool |
| `--remote` | Create new web session on claude.ai |
| `--teleport` | Resume a web session in local terminal |
| `--from-pr` | Resume sessions linked to a pull request |
| `--fallback-model` | Comma-separated fallback model chain |

### System Prompt Flags

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag.

### Slash Commands (in-session)

**Session management:**

| Command | Purpose |
| :--- | :--- |
| `/clear [name]` | Start fresh conversation (aliases: `/reset`, `/new`) |
| `/compact [instructions]` | Summarize conversation to free context |
| `/context [all]` | Visualize context usage |
| `/resume [session]` | Resume a previous conversation (alias: `/continue`) |
| `/branch [name]` | Fork conversation at this point |
| `/fork <directive>` | Spawn forked background subagent with full context |
| `/rewind` | Roll back code and conversation to checkpoint (aliases: `/checkpoint`, `/undo`) |
| `/rename [name]` | Rename the current session |
| `/export [filename]` | Export conversation as plain text |

**Model and mode:**

| Command | Purpose |
| :--- | :--- |
| `/model [model]` | Switch model and save as default |
| `/effort [level\|auto]` | Set effort level (`low`–`max`, `ultracode`) |
| `/plan [description]` | Enter plan mode |
| `/fast [on\|off]` | Toggle fast mode |
| `/config [key=value]` | Open settings or set a setting directly (alias: `/settings`) |

**Context and memory:**

| Command | Purpose |
| :--- | :--- |
| `/memory` | Edit CLAUDE.md files, manage auto-memory |
| `/add-dir <path>` | Add working directory for this session |
| `/cd <path>` | Move session to a new working directory |
| `/btw <question>` | Ask a side question without adding to conversation |

**Code quality and review:**

| Command | Purpose |
| :--- | :--- |
| `/diff` | Open interactive diff viewer |
| `/code-review [effort] [--fix] [--comment] [target]` | Review diff for bugs and cleanups |
| `/simplify [target]` | Cleanup-only review, applies fixes |
| `/review [PR]` | Review a pull request locally |
| `/security-review` | Analyze pending changes for security issues |

**Agents and parallel work:**

| Command | Purpose |
| :--- | :--- |
| `/agents` | Manage agent configurations |
| `/background [prompt]` | Detach session to run as background agent (alias: `/bg`) |
| `/batch <instruction>` | Orchestrate large codebase changes in parallel |
| `/tasks` | View and manage background tasks (alias: `/bashes`) |
| `/goal [condition\|clear]` | Set a multi-turn goal for Claude to work toward |
| `/loop [interval] [prompt]` | Run prompt repeatedly (alias: `/proactive`) |

**Debugging and diagnostics:**

| Command | Purpose |
| :--- | :--- |
| `/doctor` | Diagnose installation and settings |
| `/debug [description]` | Enable debug logging and troubleshoot |
| `/hooks` | View hook configurations |
| `/usage` | Show session cost and plan usage (aliases: `/cost`, `/stats`) |
| `/status` | Show version, model, account, connectivity |

**Tools and integrations:**

| Command | Purpose |
| :--- | :--- |
| `/mcp [reconnect\|enable\|disable]` | Manage MCP server connections |
| `/plugin [subcommand]` | Manage plugins |
| `/permissions` | Manage tool permission rules (alias: `/allowed-tools`) |
| `/keybindings` | Open keyboard shortcuts file |
| `/skills` | List available skills |
| `/init` | Initialize project with CLAUDE.md |

**Web and remote:**

| Command | Purpose |
| :--- | :--- |
| `/teleport` | Pull a web session into this terminal (alias: `/tp`) |
| `/remote-control` | Make session available for remote control (alias: `/rc`) |
| `/autofix-pr [prompt]` | Spawn cloud session to watch and fix PRs |
| `/schedule [description]` | Create/manage cloud routines (alias: `/routines`) |

Bundled skills are marked **[Skill]** in the full commands reference. `/batch`, `/code-review`, `/debug`, `/loop`, `/run`, `/run-skill-generator`, `/simplify`, `/verify`, `/claude-api`, and `/fewer-permission-prompts` are bundled skills.

Bundled workflows are marked **[Workflow]**: `/deep-research`.

### Interactive Mode — Keyboard Shortcuts

**General controls:**

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Interrupt or clear input |
| `Ctrl+D` | Exit Claude Code |
| `Esc` | Interrupt Claude mid-turn |
| `Esc Esc` | Clear input draft, or open rewind menu when input is empty |
| `Shift+Tab` | Cycle permission modes (`default` → `acceptEdits` → `plan` → `auto` → …) |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+T` | Toggle task list |
| `Ctrl+B` | Background running task (press twice for tmux) |
| `Ctrl+L` | Redraw screen |
| `Ctrl+G` or `Ctrl+X Ctrl+E` | Open in external editor |
| `Ctrl+V` / `Cmd+V` | Paste image from clipboard |
| `Option+P` / `Alt+P` | Switch model without clearing prompt |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |

**Multiline input methods:**

| Method | Shortcut |
| :--- | :--- |
| Quick escape | `\` then Enter (works everywhere) |
| Control sequence | `Ctrl+J` (works everywhere) |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| Option+Enter | After enabling Option as Meta on macOS |

**Quick prefixes:**

| Prefix | Action |
| :--- | :--- |
| `/` at start | Command or skill |
| `!` at start | Shell mode — run command directly |
| `@` | File path autocomplete |

**Transcript viewer (open with `Ctrl+O`):**

| Key | Action |
| :--- | :--- |
| `Ctrl+E` | Toggle show all content |
| `{` / `}` | Jump to previous/next user prompt (fullscreen only) |
| `[` | Write conversation to terminal scrollback (fullscreen only) |
| `v` | Open conversation in `$VISUAL`/`$EDITOR` (fullscreen only) |
| `q`, `Ctrl+C`, `Esc` | Exit transcript view |

### Keyboard Shortcuts Customization (`~/.claude/keybindings.json`)

Run `/keybindings` to create or open the file. Changes apply without restart.

**File structure:**

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

Set a binding to `null` to unbind a default shortcut.

**Key contexts:** `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Select`, `Plugin`, `Scroll`, `Doctor`, `DiffDialog`, `ModelPicker`, `Tabs`, `Attachments`, `Footer`, `MessageSelector`

**Selected actions by context:**

| Context | Action | Default |
| :--- | :--- | :--- |
| `Global` | `app:interrupt` | Ctrl+C |
| `Global` | `app:exit` | Ctrl+D |
| `Global` | `app:toggleTodos` | Ctrl+T |
| `Global` | `app:toggleTranscript` | Ctrl+O |
| `Chat` | `chat:submit` | Enter |
| `Chat` | `chat:newline` | Ctrl+J |
| `Chat` | `chat:cycleMode` | Shift+Tab |
| `Chat` | `chat:modelPicker` | Meta+P |
| `Chat` | `chat:thinkingToggle` | Meta+T |
| `Chat` | `chat:fastMode` | Meta+O |
| `Chat` | `chat:externalEditor` | Ctrl+G, Ctrl+X Ctrl+E |
| `Chat` | `chat:killAgents` | Ctrl+X Ctrl+K |
| `Transcript` | `transcript:toggleShowAll` | Ctrl+E |
| `Transcript` | `transcript:exit` | q, Ctrl+C, Escape |
| `Task` | `task:background` | Ctrl+B |

**Reserved shortcuts (cannot be rebound):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, `Caps Lock`

**Terminal conflicts:** `Ctrl+B` (tmux prefix), `Ctrl+A` (GNU screen), `Ctrl+Z` (SIGTSTP)

### Terminal Configuration

**Shift+Enter support:**

| Terminal | Shift+Enter for newline |
| :--- | :--- |
| Ghostty, Kitty, iTerm2, WezTerm, Warp, Apple Terminal, Windows Terminal | Works without setup |
| VS Code, Cursor, Devin Desktop, Alacritty, Zed | Run `/terminal-setup` once |
| gnome-terminal, JetBrains IDEs | Not available; use `Ctrl+J` or `\` then Enter |

**Option key on macOS** (required for `Alt+*` shortcuts):
- **iTerm2**: Settings → Profiles → Keys → General → Left/Right Option = "Esc+"
- **Apple Terminal**: Settings → Profiles → Keyboard → "Use Option as Meta Key"
- **VS Code**: `"terminal.integrated.macOptionIsMeta": true`

**tmux configuration** (`~/.tmux.conf`):

```
set -g allow-passthrough on
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'
```

**Fullscreen rendering** (eliminates flicker): run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1`. Use `/scroll-speed` to adjust mouse wheel speed.

**Custom themes**: stored in `~/.claude/themes/<name>.json`. Fields: `name`, `base` (dark/light/dark-daltonized/light-ansi/etc.), `overrides` (map of color token names to values). Run `/theme` → "New custom theme…" to create interactively.

**Notifications**: set `preferredNotifChannel` to `"terminal_bell"` for terminals that don't get desktop notifications. For custom sounds, add a `Notification` hook in settings.

### Built-in Tools Reference

| Tool | Permission Required | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawns a subagent in a separate context window |
| `Artifact` | Yes | Publishes HTML/Markdown as a private interactive page on claude.ai |
| `AskUserQuestion` | No | Asks multiple-choice questions for requirements/clarification |
| `Bash` | Yes | Executes shell commands |
| `CronCreate/Delete/List` | No | Schedule recurring or one-shot prompts in the session |
| `Edit` | Yes | Makes targeted string-replacement edits to files |
| `EnterPlanMode` | No | Switches to plan mode |
| `ExitPlanMode` | Yes | Presents plan and exits plan mode |
| `EnterWorktree` | No | Creates/switches to an isolated git worktree |
| `Glob` | No | Finds files by name pattern |
| `Grep` | No | Searches file contents for patterns (built on ripgrep) |
| `LSP` | No | Code intelligence via language servers |
| `Monitor` | Yes | Runs a command in the background and feeds output lines to Claude |
| `NotebookEdit` | Yes | Modifies Jupyter notebook cells |
| `PowerShell` | Yes | Executes PowerShell commands natively |
| `Read` | No | Reads file contents (supports images, PDFs, Jupyter notebooks) |
| `Skill` | Yes | Executes a skill within the main conversation |
| `TaskCreate/Get/List/Update/Stop` | No | Manage the session task list |
| `WebFetch` | Yes | Fetches and extracts content from a URL |
| `WebSearch` | Yes | Runs a web search query |
| `Write` | Yes | Creates or overwrites files |
| `Workflow` | Yes | Runs a dynamic workflow orchestrating background subagents |

**Permission rule formats:**

| Rule format | Applies to | Details |
| :--- | :--- | :--- |
| `Bash(npm run *)` | Bash, Monitor | Command pattern matching |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP | Path pattern matching |
| `Edit(/src/**)` | Edit, Write, NotebookEdit | Path pattern matching |
| `Skill(deploy *)` | Skill | Skill name matching |
| `Agent(Explore)` | Agent | Subagent type matching |
| `WebFetch(domain:example.com)` | WebFetch | Domain matching |
| `WebSearch` | WebSearch | No specifier; allow or deny whole tool |

**Bash tool notes:**
- `cd` carries over within project or `--add-dir` directories; environment variables do not persist
- Default timeout: 2 minutes (Claude can request up to 10 minutes); output cap: 30,000 characters

**Edit tool notes:**
- Exact string replacement only (no regex/fuzzy)
- Requires read-before-edit; `old_string` must appear exactly once (or use `replace_all: true`)

**Glob tool notes:**
- Results capped at 100 files sorted by modification time
- Does not respect `.gitignore` by default (set `CLAUDE_CODE_GLOB_NO_IGNORE=false` to change)

**Grep tool notes:**
- Uses ripgrep regex syntax; respects `.gitignore`
- Output modes: `files_with_matches` (default), `content`, `count`

**WebFetch tool notes:**
- Fetches page, converts HTML to Markdown, runs extraction prompt through small model
- Responses cached 15 minutes; redirects to different hosts are not auto-followed

**Monitor tool notes (v2.1.98+):**
- Not available on Amazon Bedrock, Vertex AI, or Foundry; also blocked when `DISABLE_TELEMETRY` is set
- Uses same permission rules as Bash

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — All CLI commands and flags, system prompt flag guidance
- [Commands](references/claude-code-commands.md) — All slash commands with arguments and descriptions; MCP prompts
- [Interactive mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, Vim editor mode, command history, background bash, shell mode, prompt suggestions, `/btw` side questions, task list, session recap
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) — Keybindings file format, all contexts and actions with defaults, keystroke syntax, unbinding, reserved shortcuts, terminal conflicts, Vim mode interaction, validation
- [Configure your terminal](references/claude-code-terminal-config.md) — Multiline input setup, Option key on macOS, terminal bell/notifications, tmux config, custom themes, fullscreen rendering, large paste handling, Vim mode
- [Tools reference](references/claude-code-tools-reference.md) — Per-tool descriptions, permission requirements, rule formats, behavior details for Agent, Bash, Edit, Glob, Grep, LSP, Monitor, NotebookEdit, PowerShell, Read, WebFetch, WebSearch, Write

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure your terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
