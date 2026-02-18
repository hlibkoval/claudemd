---
name: cli
description: Reference for Claude Code CLI flags, built-in commands, keyboard shortcuts, keybindings, terminal configuration, vim mode, and interactive features. Use when invoking Claude from the command line, customizing shortcuts, configuring terminal behavior, or using interactive session features.
user-invocable: false
---

# CLI & Interactive Mode

This skill covers the Claude Code command-line interface, interactive session features, keyboard shortcuts, keybindings, and terminal configuration.

## CLI Commands

| Command                         | Description                                           |
|:--------------------------------|:------------------------------------------------------|
| `claude`                        | Start interactive REPL                                |
| `claude "query"`                | Start REPL with initial prompt                        |
| `claude -p "query"`             | Run in print (non-interactive) mode, then exit        |
| `cat file \| claude -p "query"` | Process piped content                                |
| `claude -c`                     | Continue most recent conversation in current directory|
| `claude -r "<session>" "query"` | Resume session by ID or name                          |
| `claude update`                 | Update to latest version                              |
| `claude mcp`                    | Configure MCP servers                                 |

## Key CLI Flags

| Flag                             | Description                                                      |
|:---------------------------------|:-----------------------------------------------------------------|
| `--print`, `-p`                  | Non-interactive print mode                                       |
| `--continue`, `-c`              | Load most recent conversation                                    |
| `--resume`, `-r`                | Resume session by ID/name or show picker                         |
| `--model`                        | Set model (`sonnet`, `opus`, or full name)                       |
| `--add-dir`                      | Add additional working directories                               |
| `--system-prompt`                | Replace entire system prompt                                     |
| `--append-system-prompt`         | Append to default system prompt                                  |
| `--system-prompt-file`           | Replace system prompt from file (print mode only)                |
| `--append-system-prompt-file`    | Append system prompt from file (print mode only)                 |
| `--allowedTools`                 | Tools that skip permission prompts                               |
| `--disallowedTools`              | Tools removed from model context                                 |
| `--tools`                        | Restrict available built-in tools                                |
| `--permission-mode`              | Start in a specific permission mode (e.g. `plan`)                |
| `--dangerously-skip-permissions` | Skip all permission prompts                                      |
| `--output-format`                | Output format for print mode: `text`, `json`, `stream-json`     |
| `--input-format`                 | Input format for print mode: `text`, `stream-json`               |
| `--json-schema`                  | Validated JSON output matching a schema (print mode only)        |
| `--max-turns`                    | Limit agentic turns (print mode only)                            |
| `--max-budget-usd`               | Maximum API spend before stopping (print mode only)              |
| `--fallback-model`               | Fallback model when default is overloaded (print mode only)      |
| `--mcp-config`                   | Load MCP servers from JSON file                                  |
| `--strict-mcp-config`            | Only use MCP from `--mcp-config`, ignore others                  |
| `--agents`                       | Define custom subagents via JSON                                 |
| `--agent`                        | Specify an agent for the session                                 |
| `--plugin-dir`                   | Load plugins from directory                                      |
| `--chrome` / `--no-chrome`       | Enable/disable Chrome browser integration                        |
| `--remote`                       | Create a web session on claude.ai                                |
| `--teleport`                     | Resume a web session locally                                     |
| `--verbose`                      | Verbose logging (full turn-by-turn output)                       |
| `--debug`                        | Debug mode with optional category filter                         |

### `--agents` JSON Format

| Field             | Required | Description                                               |
|:------------------|:---------|:----------------------------------------------------------|
| `description`     | Yes      | When to invoke the subagent                               |
| `prompt`          | Yes      | System prompt for the subagent                            |
| `tools`           | No       | Array of allowed tools (inherits all if omitted)          |
| `disallowedTools` | No       | Array of denied tools                                     |
| `model`           | No       | `sonnet`, `opus`, `haiku`, or `inherit` (default)         |
| `skills`          | No       | Array of skill names to preload                           |
| `mcpServers`      | No       | Array of MCP servers for this subagent                    |
| `maxTurns`        | No       | Maximum agentic turns                                     |

## Built-in Commands (Slash Commands)

| Command                   | Purpose                                              |
|:--------------------------|:-----------------------------------------------------|
| `/clear`                  | Clear conversation history                           |
| `/compact [instructions]` | Compact conversation with optional focus             |
| `/config`                 | Open Settings interface                              |
| `/context`                | Visualize context usage as colored grid              |
| `/cost`                   | Show token usage statistics                          |
| `/debug [description]`    | Troubleshoot current session                         |
| `/doctor`                 | Check installation health                            |
| `/export [filename]`      | Export conversation to file or clipboard              |
| `/init`                   | Initialize project with CLAUDE.md                    |
| `/mcp`                    | Manage MCP server connections                        |
| `/memory`                 | Edit CLAUDE.md memory files                          |
| `/model`                  | Select/change AI model (arrows adjust effort)        |
| `/permissions`            | View or update permissions                           |
| `/plan`                   | Enter plan mode from prompt                          |
| `/rename <name>`          | Rename current session                               |
| `/resume [session]`       | Resume conversation or open session picker            |
| `/rewind`                 | Rewind conversation and/or code                      |
| `/stats`                  | Visualize daily usage, streaks, model preferences    |
| `/tasks`                  | List and manage background tasks                     |
| `/theme`                  | Change color theme                                   |
| `/vim`                    | Toggle vim-style editing                             |
| `/keybindings`            | Open keybindings config file                         |
| `/terminal-setup`         | Configure Shift+Enter for your terminal              |

## Keyboard Shortcuts

### General Controls

| Shortcut       | Action                          |
|:---------------|:--------------------------------|
| `Ctrl+C`       | Cancel current input/generation |
| `Ctrl+D`       | Exit Claude Code                |
| `Ctrl+G`       | Open in external text editor    |
| `Ctrl+L`       | Clear terminal screen           |
| `Ctrl+O`       | Toggle verbose output           |
| `Ctrl+R`       | Reverse search command history  |
| `Ctrl+V`       | Paste image from clipboard      |
| `Ctrl+B`       | Background running tasks        |
| `Ctrl+T`       | Toggle task list                |
| `Shift+Tab`    | Cycle permission modes          |
| `Alt+P`        | Switch model                    |
| `Alt+T`        | Toggle extended thinking        |
| `Esc Esc`      | Rewind or summarize             |

### Quick Prefixes

| Prefix | Action                    |
|:-------|:--------------------------|
| `/`    | Slash command or skill    |
| `!`    | Bash mode (direct shell)  |
| `@`    | File path autocomplete    |

### Multiline Input

| Method       | Shortcut      | Terminals                                |
|:-------------|:--------------|:-----------------------------------------|
| Quick escape | `\` + Enter   | All                                      |
| Shift+Enter  | `Shift+Enter` | iTerm2, WezTerm, Ghostty, Kitty natively |
| Option+Enter | `Option+Enter`| macOS default                            |
| Control seq  | `Ctrl+J`      | All                                      |

## Custom Keybindings

Configure via `~/.claude/keybindings.json` (open with `/keybindings`). Changes auto-reload.

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

**Contexts:** `Global`, `Chat`, `Autocomplete`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Settings`.

**Reserved (cannot rebind):** `Ctrl+C`, `Ctrl+D`.

Set an action to `null` to unbind. Use `namespace:action` format (e.g. `chat:submit`, `app:toggleTodos`).

## Terminal Configuration

- **Themes:** Match Claude Code theme to terminal via `/config`.
- **Shift+Enter:** Run `/terminal-setup` to configure for VS Code, Alacritty, Zed, Warp.
- **Option as Meta (macOS):** Required for Alt-key shortcuts. Set in iTerm2 (Settings > Profiles > Keys > "Esc+") or Terminal.app (Settings > Profiles > Keyboard > "Use Option as Meta Key").
- **Notifications:** iTerm2: Preferences > Profiles > Terminal > enable "Silence bell" + filter alerts. Or use custom notification hooks.
- **Vim mode:** Enable with `/vim` or `/config`. Supports mode switching, motions, text objects, yank/paste, and dot-repeat.
- **Large inputs:** Avoid pasting long content directly; write to file and ask Claude to read it.

## Interactive Features

- **Background tasks:** Press `Ctrl+B` during a running command, or prompt Claude to run in background. Tracked by task ID; output retrieved via TaskOutput tool. Disable with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.
- **Bash mode (`!`):** Prefix input with `!` to run shell commands directly, adding output to conversation context. Supports Tab autocomplete from previous `!` commands.
- **Prompt suggestions:** Auto-generated follow-up suggestions after Claude responds. Accept with Tab or Enter. Disable with `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false`.
- **Task list:** `Ctrl+T` to toggle. Persists across compactions. Share across sessions via `CLAUDE_CODE_TASK_LIST_ID=name`.
- **PR review status:** Shows clickable PR link in footer with colored underline (green=approved, yellow=pending, red=changes requested). Requires `gh` CLI.
- **Command history:** Per-directory. Navigate with Up/Down. Search with `Ctrl+R`.

## Full Documentation

- [CLI Reference](references/claude-code-cli-reference.md) -- all commands, flags, and --agents format
- [Interactive Mode](references/claude-code-interactive-mode.md) -- shortcuts, slash commands, vim mode, bash mode, task list
- [Terminal Configuration](references/claude-code-terminal-config.md) -- themes, line breaks, notifications, vim mode setup
- [Keybindings](references/claude-code-keybindings.md) -- custom keybindings config, all contexts and actions

## Sources

- CLI Reference: https://code.claude.com/docs/en/cli-reference.md
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode.md
- Terminal Configuration: https://code.claude.com/docs/en/terminal-config.md
- Keybindings: https://code.claude.com/docs/en/keybindings.md
