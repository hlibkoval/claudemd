---
name: features-doc
description: Complete official documentation for Claude Code features — extension overview (CLAUDE.md vs skills vs MCP vs hooks), model configuration and aliases, fast mode, output styles, status line, checkpointing/rewind, remote control, scheduled tasks (/loop and routines), channels (Telegram/Discord/iMessage), voice dictation, fullscreen rendering, and context window visualization.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features and capabilities.

## Quick Reference

### Extension types overview

| Feature | What it does | When to use it |
| :--- | :--- | :--- |
| **CLAUDE.md** | Persistent context loaded every conversation | Project conventions, "always do X" rules |
| **Skill** | Instructions, knowledge, workflows Claude can use | Reusable content, reference docs, repeatable tasks |
| **Subagent** | Isolated execution context that returns summary | Context isolation, parallel tasks |
| **MCP** | Connect to external services | External data or actions |
| **Hook** | Script/HTTP/prompt triggered by lifecycle events | Automation that must run on every matching event |
| **Plugin** | Packages skills, hooks, MCP into installable unit | Share across repos, distribute via marketplace |

### Feature layering

- **CLAUDE.md files**: additive — all levels contribute simultaneously
- **Skills/subagents**: override by name (managed > user > project priority)
- **MCP servers**: override by name (local > project > user)
- **Hooks**: merge — all registered hooks fire for matching events

### Context costs by feature

| Feature | When it loads | Context cost |
| :--- | :--- | :--- |
| CLAUDE.md | Session start | Every request |
| Skills | Session start (descriptions) + when used | Low (descriptions only until invoked) |
| MCP servers | Session start (tool names deferred) | Low until a tool is used |
| Subagents | When spawned | Isolated from main session |
| Hooks | On trigger (runs externally) | Zero unless hook returns output |

Set `disable-model-invocation: true` in a skill's frontmatter to hide it from Claude entirely until manually invoked — reduces cost to zero.

### What survives compaction

| Mechanism | After /compact |
| :--- | :--- |
| System prompt and output style | Unchanged |
| Project-root CLAUDE.md and unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | Lost until matching file is read again |
| Nested CLAUDE.md in subdirectories | Lost until file in subdirectory is read again |
| Invoked skill bodies | Re-injected, capped at 5,000 tokens per skill / 25,000 total |
| Hooks | Not applicable (run as code, not context) |

### Model aliases

| Alias | Resolves to |
| :--- | :--- |
| `default` | Clears override, reverts to account-type recommended model |
| `best` | Most capable model (currently `opus`) |
| `sonnet` | Latest Sonnet (Sonnet 4.6 on Anthropic API) |
| `opus` | Latest Opus (Opus 4.7 on Anthropic API) |
| `haiku` | Fast, efficient Haiku model |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus during plan mode, Sonnet for execution |

Configure model via `/model <alias>`, `claude --model <alias>`, `ANTHROPIC_MODEL=<alias>`, or `model` in settings.

### Effort levels (adaptive reasoning)

| Level | Best for |
| :--- | :--- |
| `low` | Short, latency-sensitive, non-intelligence-sensitive tasks |
| `medium` | Cost-sensitive work trading off some intelligence |
| `high` | Intelligence-sensitive work, balanced token use |
| `xhigh` | Most coding and agentic tasks (Opus 4.7 default) |
| `max` | Demanding tasks; session-only, not persisted |

Set via `/effort <level>`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL`, or `effortLevel` in settings.

### Fast mode

Fast mode makes Opus 4.6 2.5x faster at higher cost ($30/$150 MTok). Toggle with `/fast`. Requires claude.ai login and extra usage enabled. Not available on Bedrock, Vertex AI, or Foundry. Falls back to standard Opus 4.6 when rate limit is hit (icon turns gray).

### Output styles

| Style | Purpose |
| :--- | :--- |
| **Default** | Standard software engineering assistant |
| **Explanatory** | Adds "Insights" between tasks to teach codebase patterns |
| **Learning** | Collaborative; adds `TODO(human)` markers for you to implement |
| **Custom** | Markdown file in `~/.claude/output-styles` or `.claude/output-styles` |

Change via `/config > Output style`. Set `outputStyle` in settings. Takes effect next session (system prompt stability).

Custom style frontmatter: `name`, `description`, `keep-coding-instructions` (false by default — custom styles disable coding instructions unless set to true).

### Status line

A shell script run as a status bar receiving JSON on stdin. Configure in settings:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2,
    "refreshInterval": 5
  }
}
```

Key JSON fields available to scripts: `model.display_name`, `workspace.current_dir`, `context_window.used_percentage`, `cost.total_cost_usd`, `cost.total_duration_ms`, `rate_limits.five_hour.used_percentage`, `rate_limits.seven_day.used_percentage`, `effort.level`, `session_id`, `vim.mode`.

Generate via `/statusline <description>`. Use `session_id` (not `$$`) as cache key for slow operations like `git status`.

### Checkpointing

Automatically captures file state before each edit. Access via `Esc` + `Esc` or `/rewind`.

| Action | Effect |
| :--- | :--- |
| Restore code and conversation | Revert both to selected point |
| Restore conversation | Rewind message history, keep current code |
| Restore code | Revert file changes, keep conversation |
| Summarize from here | Compress conversation from selected point forward |

Limitations: bash-command file changes not tracked; external changes not tracked; not a replacement for git.

### Remote Control

Connects claude.ai/code or the Claude mobile app to a local running session. Requires claude.ai login (not API key), Pro/Max/Team/Enterprise plan.

| Mode | Command |
| :--- | :--- |
| Server mode (dedicated) | `claude remote-control` |
| Interactive session with RC | `claude --remote-control` |
| From existing session | `/remote-control` or `/rc` |

Key flags: `--name "My Project"`, `--spawn same-dir|worktree|session`, `--capacity <N>`, `--sandbox`.

### Scheduling options comparison

| | Cloud (Routines) | Desktop scheduled tasks | /loop |
| :--- | :--- | :--- | :--- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Persistent across restarts | Yes | Yes | Restored on --resume if unexpired |
| Access to local files | No (fresh clone) | Yes | Yes |
| Minimum interval | 1 hour | 1 minute | 1 minute |

### /loop usage (session-scoped scheduling)

| What you provide | What happens |
| :--- | :--- |
| `/loop 5m check the deploy` | Runs prompt on fixed interval |
| `/loop check the deploy` | Runs prompt at Claude-chosen interval |
| `/loop` | Runs built-in maintenance prompt (PR care, unfinished work, cleanup) |

Tasks expire after 7 days. Session holds up to 50 tasks. Tools: `CronCreate`, `CronList`, `CronDelete`. Disable with `CLAUDE_CODE_DISABLE_CRON=1`.

### Routines (cloud-managed)

Saved Claude Code configuration (prompt + repos + connectors) that runs on Anthropic-managed infrastructure. Triggers: **Schedule** (hourly/daily/weekly/one-off), **API** (POST to per-routine endpoint with bearer token), **GitHub** (pull_request or release events with optional filters).

Create at claude.ai/code/routines or via `/schedule` in CLI. Manage: `/schedule list`, `/schedule update`, `/schedule run`.

### Channels (research preview)

Push events from external services into a running Claude Code session. Requires claude.ai login, v2.1.80+.

| Channel | Install command |
| :--- | :--- |
| Telegram | `/plugin install telegram@claude-plugins-official` |
| Discord | `/plugin install discord@claude-plugins-official` |
| iMessage | `/plugin install imessage@claude-plugins-official` |
| fakechat (demo) | `/plugin install fakechat@claude-plugins-official` |

Start with: `claude --channels plugin:<name>@claude-plugins-official`

Security: all channels use sender allowlists. Pair via: send any message to bot → bot returns code → `/telegram:access pair <code>` → `/telegram:access policy allowlist`.

**Building a custom channel**: MCP server with `capabilities.experimental['claude/channel']: {}`. Emit `notifications/claude/channel` with `content` (string) and optional `meta` (Record, each key becomes a `<channel>` tag attribute). For two-way: add `tools: {}` and a reply tool. For permission relay: add `capabilities.experimental['claude/channel/permission']: {}`.

### Voice dictation

Enable with `/voice` (hold mode) or `/voice tap` (tap mode). Requires claude.ai account, v2.1.69+, local microphone. Not available on Bedrock/Vertex/Foundry or in remote/SSH sessions.

| Command | Effect |
| :--- | :--- |
| `/voice` | Toggle on/off |
| `/voice hold` | Hold Space to record, release to insert |
| `/voice tap` | Tap Space to start, tap again to send |
| `/voice off` | Disable |

Settings key: `voice: { enabled: true, mode: "tap" }`. Rebind dictation key in `~/.claude/keybindings.json` (action: `voice:pushToTalk`, context: `Chat`).

### Fullscreen rendering (research preview)

Alternate rendering path: flicker-free, flat memory, mouse support. Requires v2.1.89+.

Enable: `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1`. Disable: `/tui default`.

| Feature | Shortcut |
| :--- | :--- |
| Toggle transcript mode | `Ctrl+o` |
| Search in transcript mode | `/` |
| Scroll up/down | `PgUp` / `PgDn` |
| Jump to bottom | `Ctrl+End` |
| Clear conversation | `Ctrl+L` twice |

Disable mouse capture while keeping flicker-free rendering: `CLAUDE_CODE_DISABLE_MOUSE=1`. Set scroll speed: `CLAUDE_CODE_SCROLL_SPEED=3`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code (features overview)](references/claude-code-features-overview.md) — when to use CLAUDE.md vs skills vs subagents vs MCP vs hooks vs plugins, feature layering, context costs, how each feature loads
- [Model configuration](references/claude-code-model-config.md) — model aliases, setting model, effort levels, extended context (1M), opusplan, restricting models for enterprise, environment variables for provider pinning
- [Fast mode](references/claude-code-fast-mode.md) — toggle with /fast, cost tradeoff, when to use it, rate limit fallback, enterprise controls
- [Output styles](references/claude-code-output-styles.md) — built-in styles (Default/Explanatory/Learning), creating custom styles, frontmatter reference
- [Customize your status line](references/claude-code-statusline.md) — setup, available JSON data fields, examples (context bar, git status, cost tracking, multi-line, clickable links, rate limits, caching)
- [Checkpointing](references/claude-code-checkpointing.md) — automatic tracking, rewind menu actions, summarize from here, limitations
- [Explore the context window](references/claude-code-context-window.md) — interactive simulation, what survives compaction table, checking actual session usage
- [Remote Control](references/claude-code-remote-control.md) — setup, server mode flags, connecting from other devices, mobile push notifications, troubleshooting
- [Run prompts on a schedule (/loop)](references/claude-code-scheduled-tasks.md) — /loop modes, one-time reminders, cron expression reference, task management tools
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) — local scheduling in Desktop app, schedule options, permissions, missed runs
- [Automate work with routines](references/claude-code-routines.md) — cloud routines, schedule/API/GitHub triggers, managing runs, usage limits
- [Channels](references/claude-code-channels.md) — Telegram/Discord/iMessage setup, fakechat quickstart, security/allowlists, enterprise controls
- [Channels reference](references/claude-code-channels-reference.md) — building custom channels, MCP server contract, notification format, reply tools, sender gating, permission relay
- [Voice dictation](references/claude-code-voice-dictation.md) — hold mode, tap mode, language support, rebinding dictation key, troubleshooting
- [Fullscreen rendering](references/claude-code-fullscreen.md) — enable/disable, mouse support, scroll shortcuts, transcript mode, tmux notes

## Sources

- Extend Claude Code (features overview): https://code.claude.com/docs/en/features-overview.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Customize your status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Explore the context window: https://code.claude.com/docs/en/context-window.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Run prompts on a schedule (/loop): https://code.claude.com/docs/en/scheduled-tasks.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Automate work with routines: https://code.claude.com/docs/en/routines.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
