---
name: cli-doc
description: Complete official documentation for the Claude Code CLI — all launch commands, CLI flags, in-session slash commands, keyboard shortcuts, Vim editor mode, keybindings configuration, terminal setup, and tools reference. Covers print mode, permission modes, session management, output formats, system prompt flags, background sessions, and per-tool behavior (Bash, Edit, Glob, Grep, Read, Write, WebFetch, WebSearch, Monitor, NotebookEdit, LSP, Agent).
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code CLI, commands, interactive mode, keybindings, terminal configuration, and tools.

## Quick Reference

### CLI Commands (Launch-time)

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session |
| `claude "query"` | Start with initial prompt |
| `claude -p "query"` | Print mode — query and exit (SDK/scripted use) |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install or reinstall binary (`stable`, `latest`, or version like `2.1.118`) |
| `claude auth login` | Sign in (use `--console` for API billing, `--sso` for SSO) |
| `claude auth logout` | Sign out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | Open agent view; `--json` for scripting |
| `claude attach <id>` | Attach to a background session |
| `claude daemon status` | Inspect background-session supervisor state |
| `claude logs <id>` | Print recent output from a background session |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude remote-control` | Start a Remote Control server session |
| `claude respawn <id>` | Restart a background session with conversation intact |
| `claude rm <id>` | Remove a background session from the list |
| `claude setup-token` | Generate a long-lived OAuth token for CI/scripts |
| `claude stop <id>` | Stop a background session |
| `claude ultrareview [target]` | Run ultrareview non-interactively; `--json`, `--timeout` |

### Key CLI Flags

| Flag | Description |
| :--- | :--- |
| `--print`, `-p` | Non-interactive print mode |
| `--continue`, `-c` | Load most recent conversation in current directory |
| `--resume`, `-r` | Resume session by ID/name, or open picker |
| `--model` | Set model (`sonnet`, `opus`, or full name) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--permission-mode` | Start in a permission mode: `default`, `acceptEdits`, `plan`, `auto`, `bypassPermissions` |
| `--output-format` | `text`, `json`, or `stream-json` (print mode only) |
| `--add-dir` | Add additional working directories |
| `--allowedTools` | Pre-approve tools without prompting |
| `--disallowedTools` | Deny specific tools or tool patterns |
| `--tools` | Restrict available tools (`""` = none, `"default"` = all) |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append to default prompt from file |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Maximum API spend before stopping (print mode) |
| `--bg` | Start as background agent, return immediately |
| `--worktree`, `-w` | Start in an isolated git worktree |
| `--name`, `-n` | Set display name for the session |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--mcp-config` | Load MCP servers from JSON file or string |
| `--plugin-dir` | Load a plugin from a directory or zip archive |
| `--settings` | Path to settings JSON file or inline JSON string |
| `--debug` | Enable debug mode (optional category filter) |
| `--verbose` | Show full turn-by-turn output |
| `--version`, `-v` | Output version number |

### System Prompt Flags Summary

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag.

### In-Session Commands

Commands are typed at the `/ ` prompt. `[Skill]` entries are bundled skills.

| Command | Purpose |
| :--- | :--- |
| `/add-dir <path>` | Add a working directory for this session |
| `/background [prompt]` | Detach session to run as background agent |
| `/batch <instruction>` | **[Skill]** Orchestrate large-scale parallel changes across a codebase |
| `/branch [name]` | Fork the current conversation |
| `/btw <question>` | Ask a side question without adding to conversation history |
| `/clear [name]` | Start new conversation, keeping old in `/resume` |
| `/code-review [level] [--comment] [target]` | **[Skill]** Review diff for correctness bugs |
| `/compact [instructions]` | Summarize conversation to free context |
| `/config` | Open settings interface |
| `/context [all]` | Visualize context usage |
| `/debug [description]` | **[Skill]** Enable debug logging, read session log |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose Claude Code installation |
| `/effort [level\|auto]` | Set model effort level |
| `/export [filename]` | Export conversation as plain text |
| `/feedback` | Submit feedback or report a bug |
| `/goal [condition\|clear]` | Set a goal: Claude keeps working until condition is met |
| `/hooks` | View hook configurations |
| `/init` | Initialize project CLAUDE.md |
| `/keybindings` | Open or create keybindings config file |
| `/loop [interval] [prompt]` | **[Skill]** Run a prompt repeatedly on an interval |
| `/mcp` | Manage MCP server connections |
| `/memory` | Edit CLAUDE.md memory files |
| `/model [model]` | Set AI model for this session |
| `/permissions` | Manage allow/ask/deny rules for tool permissions |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/recap` | Generate one-line session summary |
| `/remote-control` | Enable Remote Control from claude.ai |
| `/rename [name]` | Rename the current session |
| `/resume [session]` | Resume a conversation by ID or name |
| `/review [PR]` | Review a pull request locally |
| `/rewind` | Rewind conversation/code to a previous checkpoint |
| `/run` | **[Skill]** Launch and drive your app to confirm a change |
| `/run-skill-generator` | **[Skill]** Teach `/run` and `/verify` how to launch your app |
| `/schedule [description]` | Create/list cloud-hosted routines |
| `/security-review` | Analyze pending changes for security vulnerabilities |
| `/skills` | List available skills |
| `/status` | Show version, model, account, connectivity |
| `/tasks` | List and manage background tasks |
| `/teleport` | Pull a web session into this terminal |
| `/theme [color]` | Change color theme |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/ultraplan <prompt>` | Draft a plan in an ultraplan session |
| `/ultrareview [PR]` | Deep multi-agent cloud code review |
| `/usage` | Show session cost, plan usage, activity stats |
| `/verify` | **[Skill]** Confirm a code change works by running the app |
| `/voice [hold\|tap\|off]` | Toggle voice dictation |

### Keyboard Shortcuts

#### General Controls

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+C` | Interrupt or clear input |
| `Ctrl+D` | Exit Claude Code |
| `Esc` | Interrupt Claude (stop current response) |
| `Esc` + `Esc` | Clear input draft, or open rewind menu when empty |
| `Shift+Tab` | Cycle permission modes (`default` → `acceptEdits` → `plan` → ...) |
| `Option+P` / `Alt+P` | Switch model |
| `Option+T` / `Alt+T` | Toggle extended thinking |
| `Option+O` / `Alt+O` | Toggle fast mode |
| `Ctrl+O` | Toggle transcript viewer |
| `Ctrl+R` | Reverse search command history |
| `Ctrl+B` | Background running task |
| `Ctrl+T` | Toggle task list |
| `Ctrl+G` / `Ctrl+X Ctrl+E` | Open prompt in external editor |
| `Ctrl+V` / `Alt+V` | Paste image from clipboard |
| `Ctrl+X Ctrl+K` | Kill all running background subagents |

#### Text Editing

| Shortcut | Description |
| :--- | :--- |
| `Ctrl+A` / `Ctrl+E` | Move cursor to start/end of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+U` | Delete from cursor to line start |
| `Ctrl+W` | Delete previous word |
| `Ctrl+Y` | Paste deleted text |
| `Alt+B` / `Alt+F` | Move cursor back/forward one word |

#### Multiline Input

| Method | Shortcut |
| :--- | :--- |
| Quick escape | `\` then `Enter` (works everywhere) |
| Control sequence | `Ctrl+J` (works everywhere) |
| Shift+Enter | Native in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal, Windows Terminal |
| Option+Enter | After enabling Option as Meta on macOS |

#### Quick Input Prefixes

| Prefix | Effect |
| :--- | :--- |
| `/` at start | Command or skill |
| `!` at start | Shell mode — run command directly |
| `@` | File path autocomplete |

### Vim Editor Mode

Enable via `/config` → Editor mode or set `editorMode: "vim"` in settings.

#### Mode Switching

| Key | Action |
| :--- | :--- |
| `Esc` | Enter NORMAL mode |
| `i`, `a`, `I`, `A` | Insert before/after cursor / at start/end of line |
| `o`, `O` | Open line below/above |
| `v`, `V` | Start character/line-wise visual selection |

#### Navigation (NORMAL mode)

`h/j/k/l` — move; `w/e/b` — word; `0/$` — line start/end; `gg/G` — input start/end; `f{c}/F{c}` — jump to char; `;/,` — repeat f/F/t/T motion.

#### Editing (NORMAL mode)

`x` — delete char; `dd`/`D` — delete line/to end; `cc`/`C` — change line/to end; `yy` — yank line; `p`/`P` — paste after/before; `u` — undo; `.` — repeat last change; `J` — join lines.

#### Text Objects

`iw`/`aw` — inner/around word; `i"`/`a"` — quotes; `i(`/`a(` — parens; `i[`/`a[` — brackets; `i{`/`a{` — braces.

### Keybindings Configuration

File: `~/.claude/keybindings.json` (run `/keybindings` to open/create). Changes apply live without restarting.

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

Actions use `namespace:action` format. Set to `null` to unbind. Chords are space-separated: `ctrl+k ctrl+s`.

#### Key Contexts

`Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Scroll`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Tabs`, `Footer`, `MessageSelector`, `Doctor`, `Attachments`, `Help`

#### Important Actions

| Action | Default | Description |
| :--- | :--- | :--- |
| `chat:submit` | Enter | Submit message |
| `chat:newline` | Ctrl+J | Insert newline without submitting |
| `chat:cycleMode` | Shift+Tab | Cycle permission modes |
| `chat:externalEditor` | Ctrl+G | Open in external editor |
| `chat:cancel` | Escape | Cancel input |
| `app:interrupt` | Ctrl+C | Cancel current operation |
| `app:exit` | Ctrl+D | Exit Claude Code |
| `app:toggleTodos` | Ctrl+T | Toggle task list |
| `app:toggleTranscript` | Ctrl+O | Toggle transcript viewer |
| `transcript:exit` | q, Ctrl+C, Esc | Exit transcript view |

Reserved (cannot be rebound): `Ctrl+C`, `Ctrl+D`, `Ctrl+M`, `Caps Lock`.

### Terminal Configuration

| Issue | Fix |
| :--- | :--- |
| Shift+Enter submits instead of newline | Run `/terminal-setup` in VS Code/Cursor/Windsurf/Alacritty/Zed; or use `Ctrl+J`/`\`+Enter everywhere |
| Option-key shortcuts do nothing on macOS | Enable "Option as Meta" in terminal settings (iTerm2: Settings → Profiles → Keys; Apple Terminal: Settings → Profiles → Keyboard; VS Code: `"terminal.integrated.macOptionIsMeta": true`) |
| No notification when Claude finishes | Set `preferredNotifChannel: "terminal_bell"` in settings, or configure a Notification hook |
| tmux: Shift+Enter or notifications broken | Add to `~/.tmux.conf`: `set -g allow-passthrough on`, `set -s extended-keys on`, `set -as terminal-features 'xterm*:extkeys'` |
| Display flickers / scrollback jumps | Run `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Vim keys in prompt | Enable via `/config` → Editor mode |

Custom themes live in `~/.claude/themes/<slug>.json` with fields `name`, `base` (preset to extend), and `overrides` (map of color token names to values). Select **New custom theme...** in `/theme` to create interactively.

### Tools Reference

| Tool | Permission Required | Description |
| :--- | :--- | :--- |
| `Agent` | No | Spawn a subagent with its own context |
| `AskUserQuestion` | No | Ask multiple-choice questions |
| `Bash` | Yes | Execute shell commands |
| `CronCreate/Delete/List` | No | Schedule recurring prompts in session |
| `Edit` | Yes | Targeted file edits (exact string replacement) |
| `EnterPlanMode` / `ExitPlanMode` | No / Yes | Switch into/out of plan mode |
| `Glob` | No | Find files by name pattern |
| `Grep` | No | Search file contents (ripgrep, respects .gitignore) |
| `LSP` | No | Code intelligence (definitions, references, type errors) |
| `Monitor` | Yes | Watch something in background, react to changes |
| `NotebookEdit` | Yes | Modify Jupyter notebook cells |
| `PowerShell` | Yes | Execute PowerShell commands natively |
| `Read` | No | Read file contents with line numbers |
| `Skill` | Yes | Execute a skill in the main conversation |
| `WebFetch` | Yes | Fetch URL content, converted to Markdown |
| `WebSearch` | Yes | Web search (returns titles + URLs, no page content) |
| `Write` | Yes | Create or overwrite a file |

#### Tool Permission Rule Syntax

| Rule format | Applies to |
| :--- | :--- |
| `Bash(npm run *)` | Bash, Monitor — command pattern |
| `Read(~/secrets/**)` | Read, Grep, Glob, LSP — path pattern |
| `Edit(/src/**)` | Edit, Write, NotebookEdit — path pattern |
| `WebFetch(domain:example.com)` | WebFetch — domain matching |
| `Skill(deploy *)` | Skill — skill name matching |
| `Agent(Explore)` | Agent — subagent type matching |
| `WebSearch` | WebSearch — no specifier |

#### Key Tool Behaviors

**Bash**: `cd` persists within project/added dirs; env vars do not persist across calls. Default timeout 2 min (up to 10 min with `timeout` param). Output capped at 30,000 chars (raise with `BASH_MAX_OUTPUT_LENGTH`).

**Edit**: Requires reading the file first. `old_string` must be unique or use `replace_all: true`. Exact match only — no fuzzy matching.

**Glob**: Pattern `**/*.js` recursive; sorted by mtime, capped at 100 files. Does NOT respect `.gitignore` by default (set `CLAUDE_CODE_GLOB_NO_IGNORE=false` to enable).

**Grep**: Respects `.gitignore`. Uses ripgrep syntax. Output modes: `files_with_matches` (default), `content`, `count`.

**Read**: Returns paginated content with line numbers. Handles images, PDFs (up to 20 pages/request), and `.ipynb` notebooks.

**WebFetch**: Lossy — uses a small model to extract from Markdown-converted HTML. Results cached 15 min. Redirects to different hosts return the redirect URL rather than following automatically.

**Write**: Requires reading the file first if overwriting an existing file.

**Monitor**: Requires v2.1.98+. Not available on Bedrock, Vertex, or Foundry.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — all launch commands, all flags, system prompt flags
- [Commands](references/claude-code-commands.md) — complete in-session command list with descriptions
- [Interactive mode](references/claude-code-interactive-mode.md) — keyboard shortcuts, Vim editor mode, command history, shell mode, side questions, task list, session recap
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) — keybindings file format, all contexts, all actions, keystroke syntax, chord bindings, reserved shortcuts
- [Configure your terminal](references/claude-code-terminal-config.md) — multiline input, Option key setup, notifications, tmux config, fullscreen rendering, custom themes
- [Tools reference](references/claude-code-tools-reference.md) — every tool, permission requirements, per-tool behavior, permission rule syntax

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Configure your terminal: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
