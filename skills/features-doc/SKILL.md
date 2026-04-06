---
name: features-doc
description: Complete documentation for Claude Code features -- features overview (extension points, context costs, feature layering), fast mode (toggle, pricing, rate limits, per-session opt-in), model configuration (aliases, effort levels, extended context, availableModels, modelOverrides, prompt caching, custom model options), output styles (built-in styles, custom styles, frontmatter, keep-coding-instructions), status line (custom scripts, JSON data fields, ANSI colors, multi-line, clickable links, context window fields, rate limits), checkpointing (rewind, restore, summarize, Esc+Esc, /rewind), remote control (server mode, interactive mode, /remote-control, QR code, connection security, spawn worktree, capacity), scheduled tasks (/loop, CronCreate, CronList, CronDelete, jitter, seven-day expiry, CLAUDE_CODE_DISABLE_CRON), voice dictation (/voice, push-to-talk, dictation languages, rebind key), channels (Telegram, Discord, iMessage, fakechat, sender allowlists, channelsEnabled, allowedChannelPlugins, --channels flag), channels reference (channel contract, notification format, reply tools, sender gating, permission relay, webhook receiver, MCP SDK), cloud scheduled tasks (/schedule, frequency options, repositories, connectors, environments), Desktop scheduled tasks (local tasks, remote tasks, missed runs, catch-up behavior, permissions), context window explorer (startup loading, context costs, compaction, subagent isolation), and fullscreen rendering (CLAUDE_CODE_NO_FLICKER, alternate screen buffer, mouse support, scroll, search, tmux, CLAUDE_CODE_DISABLE_MOUSE). Load when discussing Claude Code features, fast mode, /fast, model configuration, /model, model aliases, opusplan, effort levels, /effort, extended context, 1M context, availableModels, modelOverrides, output styles, /config, status line, /statusline, checkpointing, /rewind, rewind, remote control, /remote-control, /rc, scheduled tasks, /loop, /schedule, CronCreate, voice dictation, /voice, push-to-talk, channels, --channels, Telegram channel, Discord channel, iMessage channel, channel reference, channel contract, webhook receiver, permission relay, cloud scheduled tasks, Desktop scheduled tasks, context window, context costs, fullscreen rendering, CLAUDE_CODE_NO_FLICKER, or any features-related topic for Claude Code.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features -- the extension layer, model configuration, UI customization, session management, remote access, scheduling, voice input, event channels, and rendering options.

## Quick Reference

### Features Overview

| Feature | What it does | When to use it |
|:--------|:------------|:---------------|
| **CLAUDE.md** | Persistent context loaded every conversation | Project conventions, "always do X" rules |
| **Skill** | Instructions, knowledge, and workflows | Reusable content, reference docs, repeatable tasks |
| **Subagent** | Isolated execution context returning summaries | Context isolation, parallel tasks, specialized workers |
| **Agent teams** | Coordinate multiple independent sessions | Parallel research, competing hypotheses |
| **MCP** | Connect to external services | External data or actions |
| **Hook** | Deterministic script on events | Predictable automation, no LLM involved |
| **Plugin** | Bundle skills, hooks, subagents, MCP | Reuse across repos, distribute to others |

### Context Cost by Feature

| Feature | When it loads | Context cost |
|:--------|:-------------|:-------------|
| CLAUDE.md | Session start | Every request |
| Skills | Session start + when used | Low (descriptions every request) |
| MCP servers | Session start | Low until tool is used |
| Subagents | When spawned | Isolated from main session |
| Hooks | On trigger | Zero (unless hook returns context) |

### Fast Mode

| Setting | Value |
|:--------|:------|
| Toggle | `/fast` (Tab to confirm) or `"fastMode": true` in settings |
| Pricing | $30 input / $150 output per MTok (Opus 4.6) |
| Speed | 2.5x faster than standard Opus 4.6 |
| Availability | Pro/Max/Team/Enterprise subscriptions and Console (extra usage only) |
| Rate limit behavior | Auto-fallback to standard Opus 4.6 during cooldown |
| Per-session opt-in | `"fastModePerSessionOptIn": true` in managed settings |
| Disable entirely | `CLAUDE_CODE_DISABLE_FAST_MODE=1` |
| Indicator | `\u21AF` icon next to prompt while active |

### Model Configuration

| Alias | Behavior |
|:------|:---------|
| `default` | Clears override, reverts to recommended model for account type |
| `best` | Most capable model (currently equivalent to `opus`) |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast and efficient Haiku |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus during plan mode, Sonnet for execution |

**Setting the model (priority order):** `/model` during session > `claude --model` at startup > `ANTHROPIC_MODEL` env var > `model` in settings

**Default model by plan:** Max/Team Premium = Opus 4.6, Pro/Team Standard = Sonnet 4.6

### Effort Levels

| Level | Behavior |
|:------|:---------|
| `low` | Faster, cheaper, less thinking |
| `medium` | Default for Opus 4.6 and Sonnet 4.6 |
| `high` | Deeper reasoning for complex problems |
| `max` | Deepest reasoning, Opus 4.6 only, does not persist across sessions |

**Setting effort:** `/effort <level>`, arrow keys in `/model`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL` env var, `effortLevel` in settings, or `effort` in skill/subagent frontmatter

**One-off deep reasoning:** include "ultrathink" in your prompt for high effort on that turn

### Extended Context (1M Tokens)

| Plan | Opus 4.6 1M | Sonnet 4.6 1M |
|:-----|:------------|:--------------|
| Max, Team, Enterprise | Included | Extra usage required |
| Pro | Extra usage required | Extra usage required |
| API / pay-as-you-go | Full access | Full access |

Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`. Use `[1m]` suffix: `/model opus[1m]`, `/model sonnet[1m]`.

### Model Restriction (Enterprise)

```json
{
  "availableModels": ["sonnet", "haiku"],
  "model": "claude-sonnet-4-5",
  "env": {
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "claude-sonnet-4-5"
  }
}
```

### Model Environment Variables

| Variable | Description |
|:---------|:-----------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for `opus` alias and `opusplan` in plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` alias and `opusplan` in execution |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for `haiku` alias and background functionality |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |
| `ANTHROPIC_CUSTOM_MODEL_OPTION` | Add custom entry to `/model` picker |
| `DISABLE_PROMPT_CACHING` | Set to `1` to disable prompt caching for all models |

### Output Styles

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Adds educational "Insights" between tasks |
| **Learning** | Collaborative mode with `TODO(human)` markers for you to implement |

**Custom output styles:** Markdown files with frontmatter in `~/.claude/output-styles` (user) or `.claude/output-styles` (project).

| Frontmatter | Purpose | Default |
|:------------|:--------|:--------|
| `name` | Display name | File name |
| `description` | Shown in `/config` picker | None |
| `keep-coding-instructions` | Keep coding parts of system prompt | `false` |

Set via `/config` > Output style, or `"outputStyle": "Explanatory"` in settings.

### Status Line

Configure in settings with `"statusLine": { "type": "command", "command": "~/.claude/statusline.sh" }`.

Use `/statusline <description>` to auto-generate a script.

**Key JSON fields on stdin:**

| Field | Description |
|:------|:-----------|
| `model.id`, `model.display_name` | Current model |
| `cost.total_cost_usd` | Session cost in USD |
| `context_window.used_percentage` | Context window usage % |
| `context_window.remaining_percentage` | Context window remaining % |
| `context_window.context_window_size` | Max tokens (200K or 1M) |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit consumed % |
| `session_id`, `session_name` | Session identifiers |
| `vim.mode` | Current vim mode if enabled |
| `worktree.name`, `worktree.path` | Active worktree info |

**Output features:** multiple lines, ANSI colors, OSC 8 clickable links. Updates after each assistant message, debounced at 300ms.

### Checkpointing

| Action | How |
|:-------|:----|
| Open rewind menu | `Esc` + `Esc` or `/rewind` |
| Restore code and conversation | Revert both to selected point |
| Restore conversation only | Rewind messages, keep current code |
| Restore code only | Revert files, keep conversation |
| Summarize from here | Compress messages from that point forward into a summary |

**Limitations:** bash command file changes not tracked, external changes not tracked, not a replacement for git.

### Remote Control

| Mode | Command | Description |
|:-----|:--------|:-----------|
| Server mode | `claude remote-control` | Dedicated server waiting for remote connections |
| Interactive | `claude --remote-control` or `claude --rc` | Full interactive session with remote access |
| Existing session | `/remote-control` or `/rc` | Enable remote on a running session |

**Server mode flags:** `--name`, `--spawn <same-dir\|worktree>`, `--capacity <N>`, `--verbose`, `--sandbox`/`--no-sandbox`, `--remote-control-session-name-prefix`

**Enable for all sessions:** `/config` > Enable Remote Control for all sessions > `true`

**Requirements:** Pro/Max/Team/Enterprise subscription, claude.ai OAuth login, workspace trust accepted. Team/Enterprise requires admin to enable the Remote Control toggle.

### Scheduled Tasks (Session-scoped /loop)

| Syntax | Example | Interval |
|:-------|:--------|:---------|
| Leading token | `/loop 30m check the build` | Every 30 minutes |
| Trailing clause | `/loop check the build every 2 hours` | Every 2 hours |
| No interval | `/loop check the build` | Default: every 10 minutes |

**Units:** `s` (seconds, rounded up to 1m), `m` (minutes), `h` (hours), `d` (days)

**Tools:** `CronCreate` (schedule), `CronList` (list), `CronDelete` (cancel by ID). Max 50 tasks per session. 7-day auto-expiry for recurring tasks.

**One-time reminders:** natural language like "remind me at 3pm to push the release branch"

**Disable:** `CLAUDE_CODE_DISABLE_CRON=1`

### Scheduling Options Comparison

| | Cloud | Desktop | `/loop` |
|:--|:------|:--------|:--------|
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Persistent across restarts | Yes | Yes | No |
| Access to local files | No (fresh clone) | Yes | Yes |
| Minimum interval | 1 hour | 1 minute | 1 minute |

### Voice Dictation

| Setting | Value |
|:--------|:------|
| Toggle | `/voice` or `"voiceEnabled": true` in settings |
| Default push-to-talk key | `Space` (hold to record) |
| Rebind key | `~/.claude/keybindings.json`, action `voice:pushToTalk` in `Chat` context |
| Language | Uses `language` setting, defaults to English |
| Requirements | Claude.ai account, local microphone access |
| Supported languages | cs, da, de, el, en, es, fr, hi, id, it, ja, ko, nl, no, pl, pt, ru, sv, tr, uk |

### Channels

Channels push events from external systems into a running Claude Code session via MCP servers.

| Channel | Setup |
|:--------|:------|
| Telegram | `/plugin install telegram@claude-plugins-official`, configure with `/telegram:configure <token>` |
| Discord | `/plugin install discord@claude-plugins-official`, configure with `/discord:configure <token>` |
| iMessage | `/plugin install imessage@claude-plugins-official`, macOS only, reads Messages database |
| fakechat | `/plugin install fakechat@claude-plugins-official`, localhost demo at port 8787 |

**Start with channels:** `claude --channels plugin:<name>@<marketplace>`

**Enterprise controls:**

| Setting | Purpose |
|:--------|:--------|
| `channelsEnabled` | Master switch, must be `true` for any channel |
| `allowedChannelPlugins` | Restrict which plugins can register |

**Channel contract (for building custom channels):**
- Declare `capabilities.experimental['claude/channel']` in MCP Server constructor
- Emit `notifications/claude/channel` with `content` (string) and optional `meta` (Record<string, string>)
- Optional: expose a reply tool via `capabilities.tools` for two-way channels
- Optional: declare `claude/channel/permission` capability for permission relay
- Gate inbound messages on sender allowlist to prevent prompt injection

### Cloud Scheduled Tasks

Create via [claude.ai/code/scheduled](https://claude.ai/code/scheduled), Desktop app Schedule page, or `/schedule` in CLI.

| Frequency | Description |
|:----------|:-----------|
| Hourly | Every hour |
| Daily | Once per day at specified time (default 9:00 AM local) |
| Weekdays | Daily but skips Saturday/Sunday |
| Weekly | Once per week on specified day/time |

Branches default to `claude/` prefix only. Enable "Allow unrestricted branch pushes" per repository to remove this restriction. Tasks use MCP connectors and cloud environments.

### Desktop Scheduled Tasks

Local tasks run on your machine when the Desktop app is open. Each task gets a fixed stagger delay up to 10 minutes. Missed runs get one catch-up run on wake (most recent missed time only, within 7 days).

**Task file location:** `~/.claude/scheduled-tasks/<task-name>/SKILL.md`

**Prevent sleep:** Settings > Desktop app > General > Keep computer awake

### Context Window Explorer

The context window fills in phases: system prompt (~4,200 tokens), auto memory, environment info, MCP tools (deferred), skill descriptions, CLAUDE.md files, then user prompts and tool results. File reads dominate context usage. Path-scoped rules in `.claude/rules/` load only when matching files are accessed. Subagents get isolated context windows.

### Fullscreen Rendering

| Setting | Value |
|:--------|:------|
| Enable | `CLAUDE_CODE_NO_FLICKER=1` |
| Disable mouse capture | `CLAUDE_CODE_DISABLE_MOUSE=1` |
| Scroll speed | `CLAUDE_CODE_SCROLL_SPEED=<1-20>` (default 1) |

**Navigation:** `PgUp`/`PgDn` (half screen), `Ctrl+Home`/`Ctrl+End` (top/bottom), mouse wheel

**Search:** `Ctrl+o` for transcript mode, then `/` to search, `n`/`N` for next/prev match, `[` to write to native scrollback for `Cmd+f`, `v` to open in editor

**Mouse features:** click to position cursor, click collapsed tool results to expand, click URLs/file paths to open, click-and-drag to select (auto-copy on release)

**tmux:** requires `set -g mouse on`. Incompatible with iTerm2 `tmux -CC` integration mode.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code (Features Overview)](references/claude-code-features-overview.md) -- Extension points, feature comparison, context costs, how features layer and combine
- [Speed Up Responses with Fast Mode](references/claude-code-fast-mode.md) -- Toggle fast mode, pricing, rate limits, per-session opt-in, requirements
- [Model Configuration](references/claude-code-model-config.md) -- Model aliases, effort levels, extended context, availableModels, modelOverrides, environment variables, prompt caching
- [Output Styles](references/claude-code-output-styles.md) -- Built-in styles, custom style creation, frontmatter options, comparisons to CLAUDE.md and agents
- [Customize Your Status Line](references/claude-code-statusline.md) -- Status line setup, JSON data fields, ANSI colors, multi-line output, clickable links, examples
- [Checkpointing](references/claude-code-checkpointing.md) -- Rewind, restore, summarize, automatic tracking, limitations
- [Remote Control](references/claude-code-remote-control.md) -- Server mode, interactive mode, connection security, spawn/worktree, troubleshooting
- [Run Prompts on a Schedule](references/claude-code-scheduled-tasks.md) -- /loop, CronCreate/CronList/CronDelete, intervals, jitter, one-time reminders
- [Voice Dictation](references/claude-code-voice-dictation.md) -- Push-to-talk, dictation languages, rebind key, troubleshooting
- [Push Events into a Running Session with Channels](references/claude-code-channels.md) -- Telegram, Discord, iMessage setup, sender allowlists, enterprise controls
- [Channels Reference](references/claude-code-channels-reference.md) -- Build custom channels, notification format, reply tools, sender gating, permission relay
- [Schedule Tasks on the Web](references/claude-code-web-scheduled-tasks.md) -- Cloud scheduled tasks, frequency options, repositories, connectors, environments
- [Schedule Recurring Tasks in Desktop](references/claude-code-desktop-scheduled-tasks.md) -- Local tasks, missed runs, catch-up, permissions, task management
- [Explore the Context Window](references/claude-code-context-window.md) -- Interactive simulation of context window loading, costs, and compaction
- [Fullscreen Rendering](references/claude-code-fullscreen.md) -- Flicker-free rendering, mouse support, scrolling, search, tmux compatibility

## Sources

- Extend Claude Code: https://code.claude.com/docs/en/features-overview.md
- Speed Up Responses with Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Customize Your Status Line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Run Prompts on a Schedule: https://code.claude.com/docs/en/scheduled-tasks.md
- Voice Dictation: https://code.claude.com/docs/en/voice-dictation.md
- Push Events with Channels: https://code.claude.com/docs/en/channels.md
- Channels Reference: https://code.claude.com/docs/en/channels-reference.md
- Schedule Tasks on the Web: https://code.claude.com/docs/en/web-scheduled-tasks.md
- Schedule Recurring Tasks in Desktop: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Explore the Context Window: https://code.claude.com/docs/en/context-window.md
- Fullscreen Rendering: https://code.claude.com/docs/en/fullscreen.md
