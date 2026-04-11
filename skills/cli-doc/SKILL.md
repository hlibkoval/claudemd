---
name: cli-doc
description: Complete Claude Code CLI reference — commands, flags, slash commands, interactive keyboard shortcuts, keybindings configuration, terminal setup, and the built-in tools reference.
user-invocable: false
---

# CLI Documentation

This skill provides the complete official documentation for the Claude Code command-line interface, slash commands, interactive mode, keybindings, terminal configuration, and built-in tools.

## Quick Reference

### Top-level CLI commands

| Command | Description |
| :--- | :--- |
| `claude` | Start interactive session (optionally with an initial prompt) |
| `claude -p "query"` | Print-mode query via SDK, then exit |
| `claude -c` / `--continue` | Continue most recent conversation in current directory |
| `claude -r <id\|name>` / `--resume` | Resume a specific session by ID or name |
| `claude update` | Update Claude Code to latest version |
| `claude auth login` / `logout` / `status` | Manage authentication (`--sso`, `--console`, `--email`) |
| `claude agents` | List configured subagents grouped by source |
| `claude mcp` | Configure MCP servers |
| `claude plugin` (alias `plugins`) | Manage plugins |
| `claude remote-control` | Start a Remote Control server |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `claude auto-mode defaults` / `config` | Print built-in auto-mode rules or effective config |

### Commonly used CLI flags

| Flag | Purpose |
| :--- | :--- |
| `--add-dir <paths>` | Grant additional working directories |
| `--agent <name>` / `--agents <json>` | Pick or define subagents |
| `--allowedTools` / `--disallowedTools` | Tool permission pattern lists |
| `--tools "Bash,Edit,Read"` | Restrict built-in tools (`""` disables all, `default` = all) |
| `--permission-mode <mode>` | `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--dangerously-skip-permissions` | Same as `--permission-mode bypassPermissions` |
| `--allow-dangerously-skip-permissions` | Add bypass to Shift+Tab cycle without starting in it |
| `--enable-auto-mode` | Unlock auto mode in Shift+Tab cycle |
| `--model <alias\|id>` | `sonnet`, `opus`, or full model name |
| `--effort <level>` | `low`, `medium`, `high`, `max` (Opus 4.6 only) |
| `--fallback-model <name>` | Fallback model on overload (print mode only) |
| `--system-prompt` / `--system-prompt-file` | Replace the default system prompt |
| `--append-system-prompt` / `--append-system-prompt-file` | Append to the default system prompt |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine info to the first user message for cache reuse |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, memory, CLAUDE.md |
| `--mcp-config <path>` / `--strict-mcp-config` | Load MCP servers from JSON |
| `--plugin-dir <path>` | Load plugins from a directory (repeatable) |
| `--print` / `-p` | Non-interactive print mode |
| `--output-format <fmt>` | `text`, `json`, `stream-json` (print mode) |
| `--input-format <fmt>` | `text`, `stream-json` (print mode) |
| `--include-hook-events` / `--include-partial-messages` | Richer stream output (needs `stream-json`) |
| `--json-schema <schema>` | Validated structured output (print mode) |
| `--max-turns N` / `--max-budget-usd N` | Limit turns or spend (print mode) |
| `--session-id <uuid>` / `--name`, `-n` | Set session ID or display name |
| `--fork-session` | New session ID when resuming |
| `--from-pr <num\|url>` | Resume sessions linked to a PR |
| `--no-session-persistence` | Do not write session to disk (print mode) |
| `--permission-prompt-tool <name>` | MCP tool that handles prompts in non-interactive mode |
| `--setting-sources user,project,local` / `--settings <file\|json>` | Control settings loading |
| `--ide` / `--chrome` / `--no-chrome` | IDE / browser integrations |
| `--worktree <name>`, `-w` / `--tmux[=classic]` | Isolated git worktree (optionally in tmux) |
| `--teammate-mode <auto\|in-process\|tmux>` | Agent team display mode |
| `--init` / `--init-only` / `--maintenance` | Run init or maintenance hooks |
| `--debug [categories]` / `--debug-file <path>` | Debug logging |
| `--verbose` / `--version`, `-v` | Logging and version |
| `--disable-slash-commands` | Disable all skills and commands |
| `--betas <headers>` | Beta headers (API key users) |
| `--remote "task"` / `--teleport` / `--remote-control`, `--rc` | Claude Code on the web / Remote Control |
| `--channels ...` / `--dangerously-load-development-channels` | Research-preview channels |
| `--replay-user-messages` | Re-emit stream-json user messages |

`claude --help` does not list every flag; absence from `--help` does not mean a flag is unavailable.

### System prompt flags (interactive and non-interactive)

| Flag | Behavior |
| :--- | :--- |
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive; append flags can combine with either. Prefer append flags to preserve built-in capabilities.

### Slash commands (type `/` in a session)

Entries marked **[Skill]** are bundled skills that Claude can invoke automatically; the rest are built-in commands coded into the CLI. Availability depends on platform, plan, and environment.

**Session / context**: `/clear` (aliases `/reset`, `/new`), `/compact [instructions]`, `/context`, `/rewind` (alias `/checkpoint`), `/branch [name]` (alias `/fork`), `/resume [session]` (alias `/continue`), `/rename [name]`, `/export [file]`, `/copy [N]`, `/diff`, `/cost`, `/stats`, `/insights`, `/usage`, `/extra-usage`, `/tasks` (alias `/bashes`), `/btw <question>`, `/exit` (alias `/quit`)

**Configuration**: `/config` (alias `/settings`), `/status`, `/model [name]`, `/effort [low|medium|high|max|auto]`, `/fast [on|off]`, `/theme`, `/color [name|default]`, `/statusline`, `/keybindings`, `/terminal-setup`, `/permissions` (alias `/allowed-tools`), `/hooks`, `/memory`, `/init`, `/doctor`, `/sandbox`

**Tools and integrations**: `/agents`, `/skills`, `/plugin`, `/reload-plugins`, `/mcp`, `/ide`, `/chrome`, `/voice`, `/add-dir <path>`, `/install-github-app`, `/install-slack-app`, `/setup-bedrock`, `/setup-vertex`, `/web-setup`, `/remote-env`, `/desktop` (alias `/app`), `/mobile` (aliases `/ios`, `/android`), `/remote-control` (alias `/rc`), `/teleport` (alias `/tp`)

**Workflows and skills**: `/plan [description]`, `/batch <instruction>` [Skill], `/simplify [focus]` [Skill], `/loop [interval] [prompt]` [Skill], `/debug [description]` [Skill], `/claude-api` [Skill], `/schedule [description]`, `/ultraplan <prompt>`, `/autofix-pr [prompt]`, `/security-review`

**Account**: `/login`, `/logout`, `/privacy-settings`, `/upgrade`, `/passes`, `/stickers`, `/powerup`, `/feedback [report]` (alias `/bug`), `/help`, `/release-notes`

**Arguments**: `<arg>` is required, `[arg]` is optional. MCP prompts appear as `/mcp__<server>__<prompt>`. The `/review` command is deprecated (install the `code-review` plugin). `/pr-comments` and `/vim` were removed.

### Interactive keyboard shortcuts

**General**: Ctrl+C cancel, Ctrl+D exit, Ctrl+L clear input, Ctrl+O toggle transcript, Ctrl+R reverse history search, Ctrl+B background task (tmux: twice), Ctrl+T toggle task list, Ctrl+V paste image (Cmd+V in iTerm2, Alt+V on Windows), Ctrl+X Ctrl+K kill all background agents (twice within 3s to confirm), Ctrl+G or Ctrl+X Ctrl+E external editor, Esc+Esc rewind/summarize, Shift+Tab cycle permission modes, Option/Alt+P switch model, Option/Alt+T toggle extended thinking, Option/Alt+O toggle fast mode.

**Text editing (readline-style)**: Ctrl+K kill-to-end, Ctrl+U kill-to-start, Ctrl+Y paste killed text, Alt+Y cycle paste history, Alt+B / Alt+F word-back / word-forward. Option-as-Meta must be enabled in the terminal on macOS for Alt bindings.

**Multiline input**: `\` + Enter (all terminals), Option+Enter (macOS default), Shift+Enter (iTerm2, WezTerm, Ghostty, Kitty — others need `/terminal-setup`), Ctrl+J (line feed), or paste directly.

**Quick-command prefixes**: a leading `/` starts a command or skill, a leading `@` triggers file-path mentions, and a leading exclamation-mark character enters bash mode (runs a shell command and adds its output to the conversation; exit with Escape, Backspace, or Ctrl+U on empty prompt). History expansion using the exclamation-mark prefix is disabled by default.

**Transcript viewer (Ctrl+O)**: Ctrl+E toggle show-all, q / Ctrl+C / Esc exit.

**Voice**: hold Space for push-to-talk dictation (requires voice dictation enabled).

### Vim editor mode

Enable via `/config` → Editor mode or set `editorMode: "vim"` in `~/.claude.json`. Supports Esc/i/I/a/A/o/O, h/j/k/l, w/e/b, 0/$/^, gg/G, f/F/t/T with ;/,, x/dd/D, dw/de/db, cc/C, cw/ce/cb, yy/Y, yw/ye/yb, p/P, >>/<<, J, `.` repeat, and text objects (iw/aw, iW/aW, i"/a", i'/a', i(/a(, i[/a[, i{/a{). In NORMAL mode at input boundaries, j/k and arrows navigate history. Escape switches INSERT→NORMAL without firing `chat:cancel`.

### Keybindings configuration (`~/.claude/keybindings.json`)

Requires v2.1.18+. Run `/keybindings` to create or open the file. Structure:

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "bindings": [
    { "context": "Chat", "bindings": { "ctrl+e": "chat:externalEditor", "ctrl+u": null } }
  ]
}
```

Changes are hot-reloaded. Set an action to `null` to unbind a default. Unbinding every chord on a prefix frees that prefix for a single-key binding.

**Contexts**: `Global`, `Chat`, `Autocomplete`, `Settings`, `Confirmation`, `Tabs`, `Help`, `Transcript`, `HistorySearch`, `Task`, `ThemePicker`, `Attachments`, `Footer`, `MessageSelector`, `DiffDialog`, `ModelPicker`, `Select`, `Plugin`, `Scroll`.

**Action namespaces**: `app:*` (interrupt, exit, redraw, toggleTodos, toggleTranscript), `history:*`, `chat:*` (cancel, clearInput, killAgents, cycleMode, modelPicker, fastMode, thinkingToggle, submit, newline, undo, externalEditor, stash, imagePaste), `autocomplete:*`, `confirm:*` + `permission:toggleDebug`, `transcript:*`, `historySearch:*`, `task:background`, `theme:toggleSyntaxHighlighting`, `help:dismiss`, `tabs:*`, `attachments:*`, `footer:*`, `messageSelector:*`, `diff:*`, `modelPicker:*`, `select:*`, `plugin:*`, `settings:*`, `voice:pushToTalk`, `scroll:*` + `selection:copy`/`selection:clear`.

**Keystroke syntax**: modifiers `ctrl`, `alt`/`opt`/`option`, `shift`, `meta`/`cmd`/`command` joined with `+`. Chords are space-separated (`ctrl+k ctrl+s`). Standalone uppercase letters imply Shift (`K` = `shift+k`); uppercase with a modifier is stylistic only. Special keys: `escape`/`esc`, `enter`/`return`, `tab`, `space`, `up`/`down`/`left`/`right`, `backspace`, `delete`.

**Reserved (not rebindable)**: Ctrl+C (interrupt), Ctrl+D (exit), Ctrl+M (= Enter in terminals).

**Terminal conflicts**: Ctrl+B (tmux prefix), Ctrl+A (GNU screen), Ctrl+Z (SIGTSTP). `/doctor` surfaces keybinding warnings.

### Terminal configuration

- **Themes**: handled by the terminal; match via `/config`. Use a custom status line for in-Claude info.
- **Line breaks**: `\`+Enter (universal), Ctrl+J, Shift+Enter (native in iTerm2/WezTerm/Ghostty/Kitty), or `/terminal-setup` for VS Code, Alacritty, Zed, Warp.
- **Option+Enter on macOS**: Terminal.app → Use Option as Meta; iTerm2 → Left/Right Option = "Esc+"; VS Code → `"terminal.integrated.macOptionIsMeta": true`.
- **Notifications**: Kitty and Ghostty work out of the box; iTerm2 needs "Notification Center Alerts" + "Send escape sequence-generated alerts"; tmux requires `set -g allow-passthrough on`. For other terminals, use notification hooks.
- **Flicker / memory**: enable fullscreen rendering with `CLAUDE_CODE_NO_FLICKER=1`.
- **Large inputs**: avoid direct pasting; write to a file and ask Claude to read it (VS Code terminal truncates long pastes).

### Built-in tools reference

Tool names are the exact strings used in permission rules, subagent tool lists, and hook matchers. Add the name to `deny` in permission settings to disable it.

| Tool | Permission |
| :--- | :--- |
| `Agent`, `AskUserQuestion`, `EnterPlanMode`, `EnterWorktree`, `ExitWorktree`, `Glob`, `Grep`, `Read`, `LSP`, `ListMcpResourcesTool`, `ReadMcpResourceTool`, `CronCreate`, `CronDelete`, `CronList`, `SendMessage`, `TaskCreate`, `TaskGet`, `TaskList`, `TaskUpdate`, `TaskStop`, `TaskOutput` (deprecated), `TeamCreate`, `TeamDelete`, `TodoWrite`, `ToolSearch` | No |
| `Bash`, `Edit`, `Write`, `NotebookEdit`, `PowerShell`, `Monitor`, `Skill`, `ExitPlanMode`, `WebFetch`, `WebSearch` | Yes |

- **Bash**: each command runs in its own process. `cd` carries over in the main session as long as the target stays inside the project dir or an added working directory (set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to disable carry-over). Env vars do not persist between commands — use `CLAUDE_ENV_FILE` or a SessionStart hook. Subagents never inherit `cd` changes.
- **LSP**: gives Claude go-to-def, references, type info, symbols, implementations, and call hierarchies. Auto-reports type errors/warnings after each edit. Inactive until a code-intelligence plugin is installed.
- **Monitor** (v2.1.98+): watches a background script and feeds each output line back to Claude (log tailing, CI polling, directory watches). Uses Bash permission rules. Not available on Bedrock, Vertex AI, or Foundry.
- **PowerShell** (Windows opt-in preview): enable with `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. Auto-detects `pwsh.exe` then `powershell.exe`. Related settings: `defaultShell: "powershell"` (routes bash mode), `shell: "powershell"` on command hooks, `shell: powershell` in skill frontmatter. Preview limits: no auto mode, no profile loading, no sandboxing, native Windows only, Git Bash still required to start.
- **Custom tools**: connect an MCP server. For reusable prompt workflows, write a skill (runs through the existing `Skill` tool).

## Full Documentation

For the complete official documentation, see the reference files:

- [CLI reference](references/claude-code-cli-reference.md) — Every `claude` subcommand and flag with examples
- [Commands](references/claude-code-commands.md) — Full slash command catalog including bundled skills
- [Interactive mode](references/claude-code-interactive-mode.md) — Keyboard shortcuts, multiline input, bash mode, vim mode, task list, PR status, side questions
- [Customize keyboard shortcuts](references/claude-code-keybindings.md) — `keybindings.json` format, contexts, all available actions, keystroke syntax, reserved keys
- [Terminal configuration](references/claude-code-terminal-config.md) — Themes, line breaks, notifications, flicker/memory, large inputs, vim mode
- [Tools reference](references/claude-code-tools-reference.md) — Built-in tools, permissions, Bash/LSP/Monitor/PowerShell behavior

## Sources

- CLI reference: https://code.claude.com/docs/en/cli-reference.md
- Commands: https://code.claude.com/docs/en/commands.md
- Interactive mode: https://code.claude.com/docs/en/interactive-mode.md
- Customize keyboard shortcuts: https://code.claude.com/docs/en/keybindings.md
- Terminal configuration: https://code.claude.com/docs/en/terminal-config.md
- Tools reference: https://code.claude.com/docs/en/tools-reference.md
