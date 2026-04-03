---
name: features-doc
description: Complete documentation for Claude Code features -- features overview (extension architecture, context costs, feature comparison), fast mode (toggle, pricing, rate limits, per-session opt-in), model configuration (aliases, effort levels, extended 1M context, availableModels, modelOverrides, opusplan, prompt caching, ANTHROPIC_DEFAULT_*_MODEL, custom model options), output styles (built-in styles, custom output style files, keep-coding-instructions), status line (custom shell scripts, JSON session data, available fields, context_window/cost/rate_limits/worktree data, ANSI colors, multi-line, clickable links, /statusline command), checkpointing (automatic tracking, rewind menu, Esc+Esc, /rewind, restore code/conversation, summarize from here, limitations), remote control (continue local sessions from phone/tablet/browser, server mode, --remote-control, /remote-control, QR code, connection security, spawn modes, capacity), scheduled tasks (/loop bundled skill, CronCreate/CronList/CronDelete tools, interval syntax, one-time reminders, cron expressions, 7-day expiry, jitter, CLAUDE_CODE_DISABLE_CRON), voice dictation (/voice, push-to-talk, Space hold, language support, keybinding rebind, transcription), channels (push events into sessions, Telegram/Discord/iMessage plugins, --channels flag, allowlists, pairing, channelsEnabled, allowedChannelPlugins, enterprise controls), channels reference (building custom channels, MCP server with claude/channel capability, notification format, reply tools, sender gating, permission relay, webhook receiver example), web scheduled tasks (cloud recurring tasks, /schedule command, frequency options, repositories, connectors, environments), context window explorer (interactive simulation of context loading, token costs per feature, startup sequence, compaction), and fullscreen rendering (CLAUDE_CODE_NO_FLICKER, alternate screen buffer, mouse support, scroll shortcuts, search with Ctrl+o, tmux compatibility, CLAUDE_CODE_DISABLE_MOUSE, CLAUDE_CODE_SCROLL_SPEED). Load when discussing Claude Code features, fast mode, /fast, model configuration, /model, model aliases, opus, sonnet, haiku, opusplan, effort levels, /effort, extended context, 1M context, availableModels, modelOverrides, output styles, /config output style, custom output styles, status line, /statusline, statusLine setting, checkpointing, /rewind, rewind menu, restore code, remote control, /remote-control, /rc, scheduled tasks, /loop, /schedule, cron, CronCreate, voice dictation, /voice, push-to-talk, channels, --channels, Telegram, Discord, iMessage, channel plugins, channelsEnabled, channels reference, building channels, webhook receiver, web scheduled tasks, cloud scheduled tasks, context window, context costs, fullscreen rendering, CLAUDE_CODE_NO_FLICKER, or any features-related topic for Claude Code.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features -- the extension architecture, model configuration, UI customization, session management, remote access, scheduling, voice input, event channels, and rendering options.

## Quick Reference

### Features Overview: Extension Architecture

| Feature | What it does | When to use it |
|:--------|:-------------|:---------------|
| **CLAUDE.md** | Persistent context loaded every session | Project conventions, "always do X" rules |
| **Skill** | Instructions, knowledge, and workflows | Reusable content, reference docs, repeatable tasks |
| **Subagent** | Isolated execution context returning summaries | Context isolation, parallel tasks, specialized workers |
| **Agent teams** | Coordinate multiple independent sessions | Parallel research, new feature development |
| **MCP** | Connect to external services | External data or actions |
| **Hook** | Deterministic script on events | Predictable automation, no LLM involved |
| **Plugin** | Bundles skills, hooks, subagents, MCP servers | Reuse setup across repos, distribute to others |

### Context Cost by Feature

| Feature | When it loads | Context cost |
|:--------|:-------------|:-------------|
| CLAUDE.md | Session start | Every request |
| Skills | Session start + when used | Low (descriptions every request) |
| MCP servers | Session start | Low until a tool is used |
| Subagents | When spawned | Isolated from main session |
| Hooks | On trigger | Zero (unless hook returns context) |

### Fast Mode

| Setting | Value |
|:--------|:------|
| Toggle | `/fast` command or `"fastMode": true` in settings |
| Pricing | $30 input / $150 output per MTok (Opus 4.6) |
| Availability | Pro/Max/Team/Enterprise (extra usage only), Console API |
| Not available on | Bedrock, Vertex AI, Foundry |
| Rate limit fallback | Auto-falls back to standard Opus 4.6, re-enables on cooldown |
| Per-session opt-in | `"fastModePerSessionOptIn": true` in managed settings |
| Disable entirely | `CLAUDE_CODE_DISABLE_FAST_MODE=1` |
| Indicator | `↯` icon next to prompt (gray during cooldown) |

### Model Configuration

#### Model Aliases

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

#### Setting the Model (Priority Order)

1. During session: `/model <alias|name>`
2. At startup: `claude --model <alias|name>`
3. Environment variable: `ANTHROPIC_MODEL=<alias|name>`
4. Settings file: `"model": "<alias|name>"`

#### Effort Levels

| Level | Behavior | Persistence |
|:------|:---------|:------------|
| `low` | Faster, cheaper, less thinking | Persists across sessions |
| `medium` | Default for Opus 4.6 and Sonnet 4.6 | Persists across sessions |
| `high` | Deeper reasoning | Persists across sessions |
| `max` | Deepest reasoning, no token constraint (Opus 4.6 only) | Does not persist (except via env var) |

Set with: `/effort`, `/model` slider, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL`, `effortLevel` in settings, or `effort` in skill/subagent frontmatter. Say "ultrathink" in prompt for one-off high effort.

#### Extended Context (1M Tokens)

| Plan | Opus 4.6 1M | Sonnet 4.6 1M |
|:-----|:------------|:--------------|
| Max, Team, Enterprise | Included | Requires extra usage |
| Pro | Requires extra usage | Requires extra usage |
| API / pay-as-you-go | Full access | Full access |

Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`. Use `/model opus[1m]` or `/model sonnet[1m]`.

#### Model Environment Variables

| Variable | Controls |
|:---------|:---------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for `opus` alias and opusplan plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` alias and opusplan execution |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for `haiku` alias and background tasks |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |
| `ANTHROPIC_CUSTOM_MODEL_OPTION` | Add custom entry to `/model` picker |

#### Restrict Models (Enterprise)

- `availableModels` in managed settings restricts which models users can select
- `modelOverrides` maps Anthropic model IDs to provider-specific IDs (ARNs, deployment names)
- Pinned model display: `ANTHROPIC_DEFAULT_OPUS_MODEL_NAME`, `_DESCRIPTION`, `_SUPPORTED_CAPABILITIES`

#### Prompt Caching

| Variable | Effect |
|:---------|:-------|
| `DISABLE_PROMPT_CACHING` | Disable for all models |
| `DISABLE_PROMPT_CACHING_HAIKU` | Disable for Haiku only |
| `DISABLE_PROMPT_CACHING_SONNET` | Disable for Sonnet only |
| `DISABLE_PROMPT_CACHING_OPUS` | Disable for Opus only |

### Output Styles

| Style | Description |
|:------|:-----------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Educational "Insights" between coding tasks |
| **Learning** | Collaborative mode with `TODO(human)` markers for you to implement |

Set via `/config` > Output style, or `"outputStyle": "StyleName"` in settings. Changes take effect on next session start.

**Custom output styles:** Markdown files with frontmatter in `~/.claude/output-styles` (user) or `.claude/output-styles` (project).

| Frontmatter | Purpose | Default |
|:------------|:--------|:--------|
| `name` | Display name | File name |
| `description` | Shown in `/config` picker | None |
| `keep-coding-instructions` | Keep coding parts of system prompt | `false` |

### Status Line

Configure with `"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}` in settings. Use `/statusline <description>` to auto-generate.

**Key JSON fields available on stdin:**

| Field | Description |
|:------|:-----------|
| `model.id`, `model.display_name` | Current model |
| `workspace.current_dir`, `workspace.project_dir` | Directories |
| `cost.total_cost_usd` | Session cost in USD |
| `cost.total_duration_ms` | Wall-clock time |
| `context_window.used_percentage` | Context usage % |
| `context_window.context_window_size` | Max tokens (200K or 1M) |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit % |
| `session_id`, `session_name` | Session identifiers |
| `vim.mode` | Vim mode (NORMAL/INSERT) |
| `worktree.name`, `worktree.path` | Active worktree info |

Updates after each assistant message, debounced at 300ms. Supports ANSI colors, multiple lines, and OSC 8 clickable links.

### Checkpointing

- **Automatic**: every user prompt creates a checkpoint; persists across sessions
- **Rewind**: press `Esc` + `Esc` or use `/rewind` to open rewind menu
- **Actions**: Restore code and conversation, Restore conversation only, Restore code only, Summarize from here
- **Summarize**: compresses selected message forward into a summary (keeps earlier messages intact, no file changes)
- **Limitations**: bash command file changes not tracked; external changes not tracked; not a replacement for Git

### Remote Control

| Method | Command | Description |
|:-------|:--------|:-----------|
| Server mode | `claude remote-control` | Dedicated server waiting for remote connections |
| Interactive | `claude --remote-control` (or `--rc`) | Normal session with remote access |
| From session | `/remote-control` (or `/rc`) | Enable on existing session |

**Server mode flags:** `--name`, `--spawn <same-dir|worktree>`, `--capacity <N>`, `--verbose`, `--sandbox`/`--no-sandbox`

- Available on Pro/Max/Team/Enterprise (Team/Enterprise: admin must enable)
- All traffic over TLS through Anthropic API; no inbound ports
- Enable for all sessions: `/config` > Enable Remote Control for all sessions

### Scheduled Tasks (CLI /loop)

| Feature | Detail |
|:--------|:-------|
| Toggle | `/loop <interval> <prompt>` |
| Default interval | 10 minutes |
| Interval units | `s` (seconds), `m` (minutes), `h` (hours), `d` (days) |
| Tools | `CronCreate`, `CronList`, `CronDelete` |
| Max tasks | 50 per session |
| Expiry | Recurring tasks expire after 7 days |
| Disable | `CLAUDE_CODE_DISABLE_CRON=1` |

Tasks are session-scoped (gone when session exits). One-time reminders via natural language ("remind me at 3pm to...").

### Web Scheduled Tasks (Cloud)

| Feature | Detail |
|:--------|:-------|
| Create | Web UI at claude.ai/code/scheduled, Desktop app, or `/schedule` in CLI |
| Frequencies | Hourly, Daily, Weekdays, Weekly (minimum 1 hour) |
| Runs on | Anthropic cloud (no machine needed) |
| Persistent | Yes, survives restarts |
| Repository access | Fresh clone each run; `claude/`-prefixed branches by default |
| Connectors | MCP connectors included by default |
| Environments | Control network access, env vars, setup scripts |

### Scheduling Options Comparison

| | Cloud | Desktop | `/loop` |
|:--|:------|:--------|:--------|
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Persistent | Yes | Yes | No |
| Local file access | No (fresh clone) | Yes | Yes |
| Min interval | 1 hour | 1 minute | 1 minute |

### Voice Dictation

| Setting | Detail |
|:--------|:-------|
| Toggle | `/voice` or `"voiceEnabled": true` |
| Default key | Hold `Space` (brief warmup for hold detection) |
| Rebind | `~/.claude/keybindings.json`, bind `voice:pushToTalk` in `Chat` context |
| Language | Uses `language` setting; defaults to English; 20 languages supported |
| Requirements | Claude.ai account (not API key/Bedrock/Vertex/Foundry), local mic access |
| Not available in | Remote environments (web, SSH); WSL1/Windows 10 |

### Channels

Push events from external sources (Telegram, Discord, iMessage, webhooks) into a running Claude Code session.

| Channel | Setup |
|:--------|:------|
| Telegram | Create bot via BotFather, `/plugin install telegram@claude-plugins-official`, configure token, `claude --channels plugin:telegram@claude-plugins-official` |
| Discord | Create bot in Developer Portal, `/plugin install discord@claude-plugins-official`, configure token, `claude --channels plugin:discord@claude-plugins-official` |
| iMessage | macOS only, Full Disk Access required, `/plugin install imessage@claude-plugins-official`, `claude --channels plugin:imessage@claude-plugins-official` |

**Enterprise controls:**

| Setting | Purpose |
|:--------|:--------|
| `channelsEnabled` | Master switch (must be `true`); off by default for Team/Enterprise |
| `allowedChannelPlugins` | Restrict which plugins can register as channels |

**Building custom channels:** MCP server declaring `claude/channel` capability, emit `notifications/claude/channel` with `content` and `meta` params. Optional: `tools: {}` for reply tool, `claude/channel/permission` for permission relay.

### Context Window Explorer

Interactive simulation showing how context fills during a session. Key startup items: system prompt (~4200 tokens), auto memory (~680), environment info (~280), MCP tools (deferred, ~120), skill descriptions (~450), CLAUDE.md files (~2120). File reads dominate usage. Subagents use isolated context. `/compact` replaces conversation with structured summary.

### Fullscreen Rendering

| Setting | Value |
|:--------|:------|
| Enable | `CLAUDE_CODE_NO_FLICKER=1` |
| Disable mouse | `CLAUDE_CODE_DISABLE_MOUSE=1` |
| Scroll speed | `CLAUDE_CODE_SCROLL_SPEED=<1-20>` |

**Key shortcuts:**

| Shortcut | Action |
|:---------|:-------|
| `PgUp`/`PgDn` | Scroll half screen |
| `Ctrl+Home`/`Ctrl+End` | Jump to start/end |
| `Ctrl+o` | Enter transcript mode |
| `Ctrl+o` then `/` | Search conversation |
| `Ctrl+o` then `[` | Write to native scrollback |
| `Ctrl+o` then `v` | Open in editor |

Mouse: click to position cursor, click collapsed tool results to expand, click URLs to open, click-drag to select text (auto-copies on release). Works in tmux (requires `set -g mouse on`). Incompatible with iTerm2 `tmux -CC` mode.

## Full Documentation

For the complete official documentation, see the reference files:

- [Features Overview](references/claude-code-features-overview.md) -- Extension architecture, feature comparison tables, context costs, how features layer and combine
- [Fast Mode](references/claude-code-fast-mode.md) -- Toggle, pricing, rate limits, per-session opt-in, requirements
- [Model Configuration](references/claude-code-model-config.md) -- Aliases, effort levels, extended context, availableModels, modelOverrides, environment variables, prompt caching
- [Output Styles](references/claude-code-output-styles.md) -- Built-in styles, custom output style files, frontmatter, comparisons to CLAUDE.md and agents
- [Status Line](references/claude-code-statusline.md) -- Custom status bar scripts, JSON data schema, examples with colors and progress bars
- [Checkpointing](references/claude-code-checkpointing.md) -- Automatic tracking, rewind menu, restore and summarize actions, limitations
- [Remote Control](references/claude-code-remote-control.md) -- Continue local sessions from phone/tablet/browser, server mode, connection security
- [Scheduled Tasks (CLI)](references/claude-code-scheduled-tasks.md) -- /loop skill, CronCreate/CronList/CronDelete, interval syntax, cron expressions
- [Voice Dictation](references/claude-code-voice-dictation.md) -- Push-to-talk, language support, keybinding rebind, troubleshooting
- [Channels](references/claude-code-channels.md) -- Push events into sessions from Telegram/Discord/iMessage, enterprise controls, security
- [Channels Reference](references/claude-code-channels-reference.md) -- Build custom channel MCP servers, notification format, reply tools, sender gating, permission relay
- [Web Scheduled Tasks](references/claude-code-web-scheduled-tasks.md) -- Cloud recurring tasks, frequency options, repositories, connectors, environments
- [Context Window Explorer](references/claude-code-context-window.md) -- Interactive simulation of context loading, token costs, startup sequence
- [Fullscreen Rendering](references/claude-code-fullscreen.md) -- Flicker-free rendering, mouse support, scrolling, search, tmux compatibility

## Sources

- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled Tasks (CLI): https://code.claude.com/docs/en/scheduled-tasks.md
- Voice Dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels Reference: https://code.claude.com/docs/en/channels-reference.md
- Web Scheduled Tasks: https://code.claude.com/docs/en/web-scheduled-tasks.md
- Context Window Explorer: https://code.claude.com/docs/en/context-window.md
- Fullscreen Rendering: https://code.claude.com/docs/en/fullscreen.md
