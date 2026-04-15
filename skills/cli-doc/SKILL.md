---
name: cli-doc
description: Complete official Claude Code CLI documentation — launch commands and flags, slash commands, interactive mode shortcuts, keybindings config, terminal setup, and the built-in tools reference.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface: launch commands, flags, slash commands, interactive mode, keybindings, terminal setup, and tools.

## Quick Reference

### Top-level CLI commands

| Command | Purpose |
|---|---|
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Non-interactive (print) mode — query via SDK then exit |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude auth login / logout / status` | Manage authentication |
| `claude agents` | List configured subagents |
| `claude mcp` | Configure MCP servers |
| `claude plugin` (alias `plugins`) | Manage plugins |
| `claude remote-control` | Start a Remote Control server |
| `claude setup-token` | Generate a long-lived OAuth token for CI |

### Common launch flags

| Flag | Purpose |
|---|---|
| `-p`, `--print` | Non-interactive print mode |
| `-c`, `--continue` | Load most recent conversation |
| `-r`, `--resume` | Resume session by ID/name |
| `--session-id <uuid>` | Use explicit session UUID |
| `--fork-session` | Create new session ID when resuming |
| `--model <alias\|id>` | Override model (`sonnet`, `opus`, or full ID) |
| `--effort low\|medium\|high\|max` | Set model effort level for the session |
| `--fallback-model <model>` | Fallback when default model is overloaded (print mode) |
| `--permission-mode <mode>` | Start in `default`/`acceptEdits`/`plan`/`auto`/`dontAsk`/`bypassPermissions` |
| `--dangerously-skip-permissions` | Alias for `bypassPermissions` mode |
| `--allow-dangerously-skip-permissions` | Add `bypassPermissions` to `Shift+Tab` cycle |
| `--enable-auto-mode` | Unlock auto mode in the mode cycle |
| `--tools "Bash,Edit,Read"` | Restrict built-in tools available to Claude |
| `--allowedTools` / `--disallowedTools` | Permission rule patterns |
| `--add-dir <path>...` | Grant file access to extra directories |
| `--agent <name>` | Override default agent |
| `--agents '<json>'` | Define custom subagents dynamically |
| `--mcp-config <file>` | Load MCP servers from config |
| `--strict-mcp-config` | Only use `--mcp-config` servers |
| `--plugin-dir <dir>` | Load plugins from a directory |
| `--settings <file\|json>` | Override settings |
| `--setting-sources user,project,local` | Choose which setting sources to load |
| `--system-prompt` / `--system-prompt-file` | Replace system prompt |
| `--append-system-prompt` / `--append-system-prompt-file` | Append to system prompt |
| `--bare` | Minimal mode: skip hooks/skills/plugins/MCP/memory discovery |
| `--output-format text\|json\|stream-json` | Print-mode output format |
| `--input-format text\|stream-json` | Print-mode input format |
| `--include-partial-messages` | Stream partial messages (stream-json only) |
| `--include-hook-events` | Include hook events in stream |
| `--max-turns N` | Limit agentic turns (print mode) |
| `--max-budget-usd N` | Stop after spending limit (print mode) |
| `--no-session-persistence` | Disable session save/resume (print mode) |
| `--json-schema '<schema>'` | Validated structured-output schema (print mode) |
| `--verbose` | Full turn-by-turn output |
| `--debug [cats]` | Enable debug mode; optional category filter |
| `--debug-file <path>` | Write debug logs to file |
| `-w`, `--worktree [name]` | Start in an isolated git worktree |
| `--tmux` | Create tmux session (with `--worktree`) |
| `--ide` | Auto-connect to IDE on startup |
| `--chrome` / `--no-chrome` | Toggle Chrome browser integration |
| `--remote "task"` | Create a web session on claude.ai |
| `--remote-control`, `--rc [name]` | Enable Remote Control on session |
| `--teleport` | Resume a web session locally |
| `--from-pr <pr>` | Resume sessions linked to a GitHub PR |
| `-n`, `--name "<name>"` | Set session display name |
| `--teammate-mode auto\|in-process\|tmux` | Agent team display mode |
| `--channels <entries>` | MCP channel notifications to listen for |
| `--permission-prompt-tool <tool>` | MCP tool to handle permission prompts in non-interactive mode |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to improve cache reuse |
| `--init` / `--init-only` / `--maintenance` | Run init / maintenance hooks |
| `--disable-slash-commands` | Disable all skills/commands |
| `-v`, `--version` | Print version |

### System prompt flags

| Flag | Behavior |
|---|---|
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags combine with either. Prefer append flags to preserve built-in capabilities.

### Frequently used slash commands

Type `/` to filter all available commands. Commands marked **[Skill]** are bundled skills (auto-invocable too).

| Command | Purpose |
|---|---|
| `/help` | Show help and commands |
| `/clear` (`/reset`, `/new`) | Clear conversation, free context |
| `/compact [instructions]` | Compact conversation |
| `/context` | Visualize context usage |
| `/config` (`/settings`) | Open settings interface |
| `/status` | Version, model, account, connectivity |
| `/doctor` | Diagnose install; `f` to auto-fix |
| `/cost` | Show token usage statistics |
| `/stats` | Daily usage, history, streaks |
| `/usage` | Plan usage limits and rate limits |
| `/model [model]` | Switch model (arrows for effort) |
| `/effort low\|medium\|high\|max\|auto` | Set effort level |
| `/fast [on\|off]` | Toggle fast mode |
| `/permissions` (`/allowed-tools`) | Manage allow/ask/deny rules |
| `/sandbox` | Toggle sandbox mode |
| `/plan [description]` | Enter plan mode |
| `/rewind` (`/checkpoint`) | Rewind conversation/code |
| `/resume [session]` (`/continue`) | Resume a conversation |
| `/branch [name]` (`/fork`) | Branch the current conversation |
| `/rename [name]` | Rename session |
| `/memory` | Edit CLAUDE.md, manage auto-memory |
| `/hooks` | View hook configurations |
| `/agents` | Manage subagents |
| `/plugin` | Manage plugins |
| `/reload-plugins` | Reload active plugins |
| `/skills` | List skills |
| `/mcp` | Manage MCP servers |
| `/keybindings` | Open keybindings config |
| `/theme` | Change color theme |
| `/color [color\|default]` | Set prompt bar color |
| `/statusline` | Configure status line |
| `/voice` | Toggle voice dictation |
| `/remote-control` (`/rc`) | Enable remote control |
| `/teleport` (`/tp`) | Pull a web session into terminal |
| `/desktop` (`/app`) | Continue session in Desktop app |
| `/schedule [desc]` | Create/manage routines |
| `/diff` | Interactive diff viewer |
| `/export [file]` | Export conversation to text |
| `/copy [N]` | Copy response to clipboard |
| `/btw <question>` | Ask a side question |
| `/batch <instruction>` | **[Skill]** Large-scale parallel changes |
| `/simplify [focus]` | **[Skill]** Review recent changes and fix issues |
| `/loop [interval] [prompt]` (`/proactive`) | **[Skill]** Run a prompt on an interval |
| `/debug [desc]` | **[Skill]** Enable debug logging and analyze |
| `/claude-api` | **[Skill]** Load Claude API reference |
| `/security-review` | Analyze pending changes for vulnerabilities |
| `/release-notes` | Browse changelog |
| `/feedback` (`/bug`) | Submit feedback |
| `/exit` (`/quit`) | Exit CLI |

MCP prompts appear as `/mcp__<server>__<prompt>`.

### Interactive mode highlights

- Input modes: regular, Vim (toggled in `/config` → Editor mode), multi-line
- History search with Ctrl+R
- Side questions with `/btw`
- Fullscreen scroll mode, diff viewer, transcript viewer
- Tab completion for paths, slash commands, at-mentions

### Keybindings

Config file: `~/.claude/keybindings.json`. Open with `/keybindings`. Auto-reloaded on change.

Contexts: `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Scroll`, `Doctor`.

Action format: `namespace:action` (e.g. `chat:submit`, `app:toggleTodos`). Set a binding to `null` to unbind.

Example:

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "bindings": [
    { "context": "Chat", "bindings": { "ctrl+e": "chat:externalEditor", "ctrl+u": null } }
  ]
}
```

### Built-in tools

| Tool | Purpose |
|---|---|
| `Bash` | Shell command execution |
| `Read` | Read files, PDFs, images, notebooks |
| `Edit` | In-place file edits |
| `Write` | Create/overwrite files |
| `Glob` | File pattern matching |
| `Grep` | Ripgrep-backed content search |
| `WebFetch` / `WebSearch` | Fetch URLs / web search |
| `TodoWrite` | Task tracking |
| `NotebookEdit` | Edit Jupyter notebooks |
| `Agent` / `Task` | Spawn subagents |

Use `--tools "..."` to restrict which built-in tools are available. Use `--allowedTools` / `--disallowedTools` with permission rule patterns for finer control.

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — Complete reference for commands and flags (launch-time).
- [Commands](references/claude-code-commands.md) — Full list of built-in slash commands and bundled skills.
- [Interactive mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, input modes, history, and interactive features.
- [Keybindings](references/claude-code-keybindings.md) — Customize keyboard shortcuts via `~/.claude/keybindings.json`.
- [Terminal config](references/claude-code-terminal-config.md) — Terminal setup and Shift+Enter configuration.
- [Tools reference](references/claude-code-tools-reference.md) — Reference for built-in tools Claude can use.

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
- Terminal config: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
