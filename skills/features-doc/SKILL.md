---
name: features-doc
description: Complete documentation for Claude Code features -- model configuration (aliases, effort levels, extended context, opusplan, availableModels, modelOverrides, prompt caching), fast mode (toggle, pricing, rate limits, per-session opt-in), output styles (built-in Default/Explanatory/Learning, custom styles, keep-coding-instructions), status line (custom shell scripts, JSON session data, available fields, multi-line, ANSI colors), checkpointing (automatic tracking, rewind, restore, summarize, Esc+Esc, /rewind), features overview (CLAUDE.md, skills, subagents, agent teams, MCP, hooks, plugins, context costs, feature layering), remote control (local sessions from any device, server mode, --remote-control, /remote-control, QR code, connection security), scheduled tasks (/loop, cron tools, CronCreate/CronList/CronDelete, interval syntax, one-time reminders, session-scoped), voice dictation (/voice, push-to-talk, Space key, language support, keybinding), channels (push events into sessions, Telegram, Discord, iMessage, fakechat, sender allowlists, enterprise controls, channelsEnabled, allowedChannelPlugins), channels reference (building custom channels, MCP server contract, claude/channel capability, notification format, reply tools, sender gating, permission relay), web scheduled tasks (cloud recurring tasks, frequency options, repositories, connectors, environments, /schedule command), context window exploration (interactive simulation, startup loading, token costs, compaction), and fullscreen rendering (CLAUDE_CODE_NO_FLICKER, alternate screen buffer, mouse support, scroll, search, transcript mode, tmux). Load when discussing Claude Code features, model selection, model aliases, effort levels, opusplan, fast mode, output styles, status line, statusline, checkpointing, rewind, features overview, extension comparison, remote control, scheduled tasks, /loop, cron, voice dictation, /voice, channels, Telegram channel, Discord channel, iMessage channel, web scheduled tasks, /schedule, context window, fullscreen rendering, no-flicker mode, or any Claude Code feature configuration topic.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features including model configuration, fast mode, output styles, status line, checkpointing, remote control, scheduled tasks, voice dictation, channels, context window, and fullscreen rendering.

## Quick Reference

### Model Configuration

**Model aliases:**

| Alias | Resolves To |
|:------|:------------|
| `default` | Clears override, reverts to recommended model for account type |
| `best` | Most capable model (currently `opus`) |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast, efficient Haiku model |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus for plan mode, Sonnet for execution |

**Setting order of priority:** `/model` in session > `claude --model` > `ANTHROPIC_MODEL` env var > settings file `model` field.

**Effort levels:** `low`, `medium` (default), `high`, `max` (Opus 4.6 only, non-persistent). Set via `/effort`, `/model` slider, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL` env var, settings `effortLevel`, or skill/subagent frontmatter `effort`.

**Restrict models:** Set `availableModels` in managed/policy settings. Combine with `model` and `ANTHROPIC_DEFAULT_*_MODEL` env vars for full control.

**Model override env vars:**

| Variable | Description |
|:---------|:------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for `opus` alias and `opusplan` plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` alias and `opusplan` execution |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for `haiku` alias and background functionality |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |

**Extended context (1M tokens):** Opus 4.6 and Sonnet 4.6. Max/Team/Enterprise get Opus 1M included. Use `[1m]` suffix: `/model opus[1m]`. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

**Prompt caching:** `DISABLE_PROMPT_CACHING=1` disables all; per-model: `DISABLE_PROMPT_CACHING_OPUS=1`, `DISABLE_PROMPT_CACHING_SONNET=1`, `DISABLE_PROMPT_CACHING_HAIKU=1`.

### Fast Mode

| Detail | Value |
|:-------|:------|
| Toggle | `/fast` (Tab to confirm) or `"fastMode": true` in settings |
| Pricing | $30 / $150 per MTok (input / output) |
| Speed | 2.5x faster Opus 4.6 |
| Indicator | `↯` icon next to prompt |
| Availability | Pro/Max/Team/Enterprise + Console; extra usage only |
| Fallback | Auto-falls back to standard Opus on rate limit; `↯` turns gray |

**Per-session opt-in:** Set `"fastModePerSessionOptIn": true` in managed settings to require `/fast` each session. Disable entirely with `CLAUDE_CODE_DISABLE_FAST_MODE=1`.

### Output Styles

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Adds educational "Insights" between coding tasks |
| **Learning** | Collaborative mode with `TODO(human)` markers for you to implement |

**Custom styles:** Markdown files in `~/.claude/output-styles` (user) or `.claude/output-styles` (project) with `name`, `description`, `keep-coding-instructions` frontmatter. Set via `/config` > Output style or `"outputStyle": "StyleName"` in settings.

### Status Line

Configure via `"statusLine": { "type": "command", "command": "~/.claude/statusline.sh" }` in settings, or use `/statusline <description>` to auto-generate.

**Key JSON fields available via stdin:**

| Field | Description |
|:------|:------------|
| `model.id`, `model.display_name` | Current model |
| `context_window.used_percentage` | Context usage % |
| `context_window.remaining_percentage` | Context remaining % |
| `cost.total_cost_usd` | Session cost |
| `cost.total_duration_ms` | Wall-clock time |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit % |
| `rate_limits.seven_day.used_percentage` | 7-day rate limit % |
| `workspace.current_dir`, `workspace.project_dir` | Directories |
| `session_id` | Session ID |
| `vim.mode` | Vim mode (NORMAL/INSERT) |
| `worktree.name`, `worktree.path` | Worktree info |

Supports ANSI colors, multiple lines, OSC 8 clickable links. Optional `"padding"` field for spacing.

### Checkpointing

- Automatic: every user prompt creates a checkpoint
- Access: `Esc` + `Esc` or `/rewind`
- Actions: **Restore code and conversation**, **Restore conversation**, **Restore code**, **Summarize from here**, **Never mind**
- Persists across sessions; cleaned up after 30 days
- Limitations: bash command changes and external edits not tracked

### Remote Control

Access local Claude Code sessions from any device via claude.ai/code or Claude mobile app.

| Mode | Command | Description |
|:-----|:--------|:------------|
| Server | `claude remote-control` | Dedicated server, multiple concurrent sessions |
| Interactive | `claude --remote-control` (or `--rc`) | Full interactive + remote |
| Existing session | `/remote-control` (or `/rc`) | Enable on running session |

**Server mode flags:** `--name`, `--spawn <same-dir|worktree>`, `--capacity <N>`, `--verbose`, `--sandbox`/`--no-sandbox`.

Available on Pro/Max/Team/Enterprise (Team/Enterprise requires admin enable). Requires claude.ai OAuth (not API keys).

### Scheduled Tasks

**Three scheduling options:**

| Option | Runs On | Persistent | Local Files |
|:-------|:--------|:-----------|:------------|
| Cloud (`/schedule`) | Anthropic cloud | Yes | No (fresh clone) |
| Desktop | Your machine | Yes | Yes |
| `/loop` | Your machine | No (session-scoped) | Yes |

**`/loop` syntax:** `/loop 5m <prompt>`, `/loop <prompt> every 2h`, `/loop <prompt>` (defaults 10m). Units: `s`, `m`, `h`, `d`.

**Cron tools:** `CronCreate` (5-field cron expression), `CronList`, `CronDelete`. Max 50 tasks per session. 7-day auto-expiry for recurring tasks.

**Web scheduled tasks:** Create at claude.ai/code/scheduled, via Desktop app, or `/schedule` in CLI. Frequencies: hourly, daily, weekdays, weekly. Minimum interval 1 hour. Supports repos, connectors, environments.

### Voice Dictation

| Detail | Value |
|:-------|:------|
| Toggle | `/voice` or `"voiceEnabled": true` in settings |
| Push-to-talk | Hold `Space` (default); rebindable via `voice:pushToTalk` in keybindings |
| Language | Uses `language` setting; defaults to English; 20 languages supported |
| Requirements | Claude.ai account, local microphone access, v2.1.69+ |

Transcription is tuned for coding vocabulary. Rebind to modifier combo (e.g., `meta+k`) to skip warmup.

### Channels

Push events from external systems into running Claude Code sessions via MCP servers.

| Channel | Setup |
|:--------|:------|
| Telegram | `/plugin install telegram@claude-plugins-official`, configure token, pair |
| Discord | `/plugin install discord@claude-plugins-official`, configure token, pair |
| iMessage | `/plugin install imessage@claude-plugins-official`, Full Disk Access on macOS |
| Fakechat | `/plugin install fakechat@claude-plugins-official`, localhost demo |

**Usage:** `claude --channels plugin:<name>@claude-plugins-official`

**Enterprise controls:** `channelsEnabled` (master switch, off by default for Team/Enterprise), `allowedChannelPlugins` (restrict approved plugins).

**Building custom channels:** Declare `claude/channel` capability in MCP server, emit `notifications/claude/channel` events, connect via stdio. Use `--dangerously-load-development-channels` for testing.

### Context Window

Interactive simulation showing how context fills during a session:

- **Startup:** system prompt (~4.2K tokens), auto memory (~680), env info (~280), MCP tools (~120 deferred), skill descriptions (~450), CLAUDE.md files (~2.1K total)
- **File reads** dominate context usage; be specific in prompts
- **Compaction** (`/compact`) summarizes conversation when context gets full; skill descriptions are not re-injected after compaction
- **Subagents** use isolated context; don't inherit conversation history

### Fullscreen Rendering

Enable with `CLAUDE_CODE_NO_FLICKER=1`. Requires v2.1.89+.

| Feature | Details |
|:--------|:--------|
| Rendering | Alternate screen buffer, no flicker, flat memory |
| Mouse | Click to expand tool output, position cursor, select text, open URLs |
| Scrolling | `PgUp`/`PgDn`, `Ctrl+Home`/`Ctrl+End`, mouse wheel |
| Search | `Ctrl+o` then `/` for less-style search; `n`/`N` for next/prev match |
| Native scrollback | `Ctrl+o` then `[` to write conversation to scrollback |
| Copy | Auto-copy on mouse release; toggle in `/config` |
| Disable mouse | `CLAUDE_CODE_DISABLE_MOUSE=1` (keeps flicker-free rendering) |
| Scroll speed | `CLAUDE_CODE_SCROLL_SPEED=3` for faster wheel scrolling |

### Features Overview (Extension Comparison)

| Feature | What It Does | When to Use |
|:--------|:-------------|:------------|
| CLAUDE.md | Persistent context every session | "Always do X" rules |
| Skill | Reusable knowledge and workflows | Reference docs, `/deploy` checklists |
| Subagent | Isolated execution context | Context isolation, parallel tasks |
| Agent teams | Coordinate multiple sessions | Parallel research, competing hypotheses |
| MCP | Connect to external services | Database queries, Slack, browser |
| Hook | Deterministic scripts on events | ESLint after edits, logging |
| Plugin | Package and distribute features | Cross-repo reuse, distribution |

**Feature loading:** CLAUDE.md (every request), Skills (descriptions at start, full on use), MCP (tool names at start, schemas on demand), Subagents (fresh context when spawned), Hooks (zero context cost).

**Feature layering:** CLAUDE.md is additive (all levels contribute), Skills/Subagents override by name (priority order), MCP overrides by name (local > project > user), Hooks merge (all fire).

## Full Documentation

For the complete official documentation, see the reference files:

- [Features Overview](references/claude-code-features-overview.md) -- Extension comparison: CLAUDE.md, skills, subagents, MCP, hooks, plugins, context costs
- [Fast Mode](references/claude-code-fast-mode.md) -- 2.5x faster Opus 4.6 responses, toggle, pricing, rate limits
- [Model Configuration](references/claude-code-model-config.md) -- Model aliases, effort levels, extended context, environment variables, enterprise controls
- [Output Styles](references/claude-code-output-styles.md) -- Built-in and custom output styles for adapting Claude Code behavior
- [Status Line](references/claude-code-statusline.md) -- Custom shell-script status bar with JSON session data
- [Checkpointing](references/claude-code-checkpointing.md) -- Automatic edit tracking, rewind, restore, and summarize
- [Remote Control](references/claude-code-remote-control.md) -- Continue local sessions from any device via claude.ai/code or mobile app
- [Scheduled Tasks](references/claude-code-scheduled-tasks.md) -- /loop, cron tools, and session-scoped scheduling
- [Voice Dictation](references/claude-code-voice-dictation.md) -- Push-to-talk voice input with coding vocabulary
- [Channels](references/claude-code-channels.md) -- Push events from Telegram, Discord, iMessage into sessions
- [Channels Reference](references/claude-code-channels-reference.md) -- Build custom channel MCP servers
- [Web Scheduled Tasks](references/claude-code-web-scheduled-tasks.md) -- Cloud-based recurring task automation
- [Context Window](references/claude-code-context-window.md) -- Interactive simulation of context window usage
- [Fullscreen Rendering](references/claude-code-fullscreen.md) -- Flicker-free alternate screen buffer with mouse support

## Sources

- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled Tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Voice Dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels Reference: https://code.claude.com/docs/en/channels-reference.md
- Web Scheduled Tasks: https://code.claude.com/docs/en/web-scheduled-tasks.md
- Context Window: https://code.claude.com/docs/en/context-window.md
- Fullscreen Rendering: https://code.claude.com/docs/en/fullscreen.md
