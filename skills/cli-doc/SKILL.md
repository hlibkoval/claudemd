---
name: cli-doc
user-invocable: false
---

# CLI & Interactive Mode Documentation

This skill provides the complete official documentation for the Claude Code CLI: launch commands, flags, in-session commands, interactive keyboard shortcuts, keybinding customization, terminal configuration, and built-in tools.

## Quick Reference

### CLI Commands

| Command | Description |
|:--------|:------------|
| `claude` | Start interactive session |
| `claude "query"` | Start session with initial prompt |
| `claude -p "query"` | Print mode (query then exit) |
| `claude -c` | Continue most recent conversation |
| `claude -r "<name>"` | Resume session by ID or name |
| `claude --bg "task"` | Start as background agent |
| `claude update` | Update to latest version |
| `claude auth login` | Sign in (use `--console` for API billing) |
| `claude auth status` | Show auth status (exits 0 if logged in) |
| `claude agents` | Open agent view; `--json` for scripting |
| `claude attach <id>` | Attach to a background session |
| `claude daemon status` | Show supervisor state |
| `claude daemon stop --any` | Stop supervisor and its sessions |
| `claude logs <id>` | Print recent output from a background session |
| `claude stop <id>` / `claude kill <id>` | Stop a background session |
| `claude rm <id>` | Remove session from list (transcript kept) |
| `claude respawn <id>` | Restart a session with conversation intact |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude remote-control` | Start a Remote Control server |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

### Key CLI Flags

| Flag | Description |
|:-----|:------------|
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Load most recent conversation |
| `-r`, `--resume` | Resume by ID or name (picker if no arg) |
| `-n`, `--name` | Set session display name |
| `-w`, `--worktree` | Start in an isolated git worktree |
| `--bg` | Background agent; returns session ID immediately |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in: `default`, `acceptEdits`, `plan`, `auto`, `bypassPermissions` |
| `--allowedTools` | Tools that run without permission prompts |
| `--disallowedTools` | Tools to deny or remove from context |
| `--tools` | Restrict which built-in tools are available |
| `--output-format` | `text`, `json`, `stream-json` (print mode) |
| `--max-turns` | Limit agentic turns (print mode) |
| `--max-budget-usd` | Max spend in dollars (print mode) |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--system-prompt-file` | Replace prompt with file contents |
| `--append-system-prompt-file` | Append file contents to default prompt |
| `--add-dir` | Add additional working directories |
| `--mcp-config` | Load MCP servers from JSON file |
| `--plugin-dir` | Load plugin from directory or zip (session only) |
| `--settings` | Path to settings JSON or inline JSON string |
| `--debug` | Enable debug mode with optional category filter |
| `--verbose` | Show full turn-by-turn output |
| `--agent` | Specify subagent for the session |
| `--init` | Run Setup hooks with `init` matcher (print mode) |
| `--init-only` | Run Setup and SessionStart hooks, then exit |
| `--remote` | Create a new web session on claude.ai |
| `--teleport` | Resume a web session in local terminal |

### System Prompt Flags

| Flag | Behavior |
|:-----|:---------|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag. Use append flags when Claude should remain a coding assistant with extra rules; use replacement when the surface or identity differs entirely.

### In-Session Commands (Selected)

| Command | Description |
|:--------|:------------|
| `/clear [name]` | New conversation (old one stays in `/resume`) |
| `/compact [instructions]` | Summarize conversation to free context |
| `/context [all]` | Visualize context usage |
| `/model [model]` | Switch model and save as default |
| `/effort [level]` | Set effort level (`low`–`max`, `ultracode`) |
| `/plan [description]` | Enter plan mode |
| `/permissions` | Manage allow/ask/deny rules |
| `/memory` | Edit CLAUDE.md files, manage auto-memory |
| `/agents` | Manage subagent configurations |
| `/tasks` | List and manage background tasks |
| `/diff` | Interactive diff viewer |
| `/code-review [level] [--fix] [--comment]` | Review diff for bugs and cleanups |
| `/simplify [target]` | Cleanup-only review with auto-fix |
| `/review [PR]` | Review a pull request locally |
| `/security-review` | Analyze branch changes for security issues |
| `/rewind` | Roll back code and conversation to a checkpoint |
| `/branch [name]` | Fork the current conversation |
| `/resume [session]` | Resume a session by ID or name |
| `/btw <question>` | Ask a side question (ephemeral, no context impact) |
| `/background [prompt]` | Detach session as background agent |
| `/batch <instruction>` | Orchestrate large codebase changes in parallel |
| `/goal [condition]` | Keep working until condition is met |
| `/loop [interval] [prompt]` | Run a prompt repeatedly on a schedule |
| `/schedule [description]` | Create/manage cloud-hosted routines |
| `/teleport` | Pull a web session into local terminal |
| `/remote-control` | Enable remote control from claude.ai |
| `/compact` | Summarize conversation to free context |
| `/hooks` | View hook configurations |
| `/keybindings` | Open keybindings config file |
| `/theme` | Change color theme |
| `/config` | Open settings interface |
| `/status` | Show version, model, account, connectivity |
| `/usage` | Show session cost and plan usage |
| `/doctor` | Diagnose installation issues |
| `/skills` | List available skills |
| `/reload-skills` | Re-scan skill directories without restarting |
| `/reload-plugins` | Reload active plugins without restarting |
| `/init` | Generate a starter CLAUDE.md |
| `/mcp` | Manage MCP server connections |
| `/plugin` | Manage plugins |

Bundled **[Skill]** commands: `/batch`, `/claude-api`, `/code-review`, `/debug`, `/fewer-permission-prompts`, `/loop`, `/run`, `/run-skill-generator`, `/simplify`, `/verify`.  
Bundled **[Workflow]** commands: `/deep-research`.

### Interactive Keyboard Shortcuts

**General controls:**

| Shortcut | Description |
|:---------|:------------|
| `Ctrl+C` | Interrupt or clear input |
| `Ctrl+D` | Exit Claude Code |
| `Esc` | Interrupt Claude (stop current response) |
| `Esc` + `Esc` | Clear input draft / open rewind menu |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running task |
| `Ctrl+T` | Toggle task list |
| `Ctrl+L` | Redraw screen |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open in external editor |
| `Shift+Tab` | Cycle permission modes |
| `Alt+P` / `Option+P` | Switch model |
| `Alt+T` / `Option+T` | Toggle extended thinking |
| `Alt+O` / `Option+O` | Toggle fast mode |
| `Ctrl+V` / `Alt+V` | Paste image from clipboard |

**Multiline input:**

| Method | Shortcut |
|:-------|:---------|
| Works everywhere | `\` + Enter, `Ctrl+J` |
| Most terminals | `Shift+Enter` (native) |
| Needs `/terminal-setup` | VS Code, Cursor, Alacritty, Zed |
| Not available | gnome-terminal, JetBrains IDEs |

**Shell mode:** prefix input with `!` to run shell commands directly without Claude.

**File mention:** type `@` to trigger file path autocomplete.

### Vim Editor Mode

Enable via `/config` → Editor mode or `"editorMode": "vim"` in settings.

| Category | Key examples |
|:---------|:------------|
| Mode switching | `Esc` → NORMAL, `i/I/a/A/o/O` → INSERT, `v/V` → VISUAL |
| Navigation | `h/j/k/l`, `w/e/b`, `0/$`, `gg/G`, `f{char}` |
| Editing | `x`, `dd`, `cc`, `yy`, `p/P`, `u`, `.` |
| Text objects | `iw/aw`, `i"/a"`, `i(/a(`, `i{/a{`, `i[/a[` |
| Submit | Enter (even in INSERT mode) |

### Keybindings Configuration

File: `~/.claude/keybindings.json` (run `/keybindings` to create/open).

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

**Key contexts:** `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Transcript`, `Task`, `Scroll`, `DiffDialog`, `ModelPicker`, `Settings`, `Select`, `Plugin`, `Doctor`.

**Action format:** `namespace:action` — e.g. `chat:submit`, `app:toggleTodos`.

**Reserved (cannot be rebound):** `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, `Caps Lock`.

Set an action to `null` to unbind it. Chord sequences are space-separated (e.g. `ctrl+k ctrl+s`).

### Built-in Tools

| Tool | Permission | Description |
|:-----|:-----------|:------------|
| `Agent` | No | Spawns a subagent with its own context |
| `AskUserQuestion` | No | Multiple-choice prompts for clarification |
| `Bash` | Yes | Shell commands (2-min timeout default; 30K char output default) |
| `CronCreate/Delete/List` | No | Schedule recurring or one-shot prompts in the session |
| `Edit` | Yes | Exact string replacement in files (read-before-edit required) |
| `EnterPlanMode` / `ExitPlanMode` | No/Yes | Switch into plan mode |
| `EnterWorktree` / `ExitWorktree` | No | Create/exit isolated git worktree |
| `Glob` | No | Find files by name pattern (mod-time sorted, max 100 results) |
| `Grep` | No | Search file contents via ripgrep regex |
| `LSP` | No | Code intelligence (needs language plugin) |
| `Monitor` | Yes | Watch background command output, react per line |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells by cell_id |
| `PowerShell` | Yes | Native PowerShell (Windows primary; opt-in on others) |
| `PushNotification` | No | Desktop + phone push notification |
| `Read` | No | Read files (images, PDFs, notebooks supported) |
| `Skill` | Yes | Execute a skill in the main conversation |
| `TaskCreate/Get/List/Update/Stop` | No | Manage session task list |
| `WebFetch` | Yes | Fetch URL, extract via small model (cached 15 min) |
| `WebSearch` | Yes | Search via Anthropic backend (up to 8 internal searches) |
| `Workflow` | Yes | Run a dynamic multi-subagent workflow |
| `Write` | Yes | Create or overwrite files (read-before-write for existing files) |

**Permission rule formats:**

| Format | Applies to |
|:-------|:-----------|
| `Bash(npm run *)` | Bash, Monitor |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP |
| `Edit(/src/**)` | Edit, Write, NotebookEdit |
| `Skill(deploy *)` | Skill |
| `Agent(Explore)` | Agent |
| `WebFetch(domain:example.com)` | WebFetch |
| `WebSearch` | WebSearch (no specifier) |

An `Edit(...)` allow rule also grants read access to the same path.

### Terminal Configuration

| Issue | Solution |
|:------|:---------|
| Shift+Enter submits (VS Code / Cursor / Zed) | Run `/terminal-setup` once |
| Option shortcuts do nothing (macOS) | Enable Option as Meta in terminal settings |
| No sound when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` in settings |
| Inside tmux (Shift+Enter / notifications broken) | Add `allow-passthrough on`, `extended-keys on` to `~/.tmux.conf` |
| Display flickers / scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Want Vim keys | `/config` → Editor mode or `"editorMode": "vim"` in settings |

Custom themes live in `~/.claude/themes/<name>.json`. Fields: `name`, `base` (dark/light/daltonized/ansi), `overrides` (map of color tokens to values). Claude Code watches the directory and reloads on change.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI Reference](references/claude-code-cli-reference.md) — All CLI commands and flags, system prompt flag guide, print-mode options
- [Commands](references/claude-code-commands.md) — Full in-session command list with descriptions, MCP prompts
- [Interactive Mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, Vim editor mode, command history, background bash, shell mode, prompt suggestions, `/btw`, task list, session recap, PR review status
- [Customize Keyboard Shortcuts](references/claude-code-keybindings.md) — Keybinding config format, all contexts and actions, keystroke syntax, chords, unbinding, reserved shortcuts
- [Configure Your Terminal](references/claude-code-terminal-config.md) — Shift+Enter setup, Option key on macOS, terminal bell/notifications, tmux config, fullscreen rendering, custom themes
- [Tools Reference](references/claude-code-tools-reference.md) — All built-in tools, permission rule syntax, per-tool behavior (Bash, Edit, Glob, Grep, LSP, Monitor, NotebookEdit, Read, WebFetch, WebSearch, Write)

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize Keyboard Shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure Your Terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools Reference: https://code.claude.com/docs/en/tools-reference.md
