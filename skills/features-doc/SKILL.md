---
name: features-doc
description: Complete official documentation for Claude Code features — model configuration, fast mode, output styles, checkpointing, context window management, remote control, scheduled tasks, routines, channels, voice dictation, status line customization, and fullscreen rendering.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features and capabilities.

## Quick Reference

### Model configuration

| Alias | Resolves to |
| :--- | :--- |
| `default` | Clears override; reverts to recommended model for your account type |
| `best` | Most capable model (currently `opus`) |
| `sonnet` | Latest Sonnet (Sonnet 4.6 on Anthropic API; 4.5 on Bedrock/Vertex/Foundry) |
| `opus` | Latest Opus (Opus 4.7 on Anthropic API; 4.6 on Bedrock/Vertex/Foundry) |
| `haiku` | Fast Haiku for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus in plan mode, Sonnet in execution mode |

Set model: `/model <alias>`, `claude --model <alias>`, `ANTHROPIC_MODEL` env var, or `model` in settings.

#### Effort levels

| Level | When to use |
| :--- | :--- |
| `low` | Short, scoped, latency-sensitive tasks |
| `medium` | Cost-sensitive work that can trade off intelligence |
| `high` | Balanced; minimum for intelligence-sensitive work |
| `xhigh` | Best for most coding/agentic tasks (default on Opus 4.7) |
| `max` | Demanding tasks; current session only; may overthink |

Set effort: `/effort`, `/effort <level>`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL` env var, `effortLevel` in settings, or `effort` in skill/subagent frontmatter.

#### Model env vars

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for `opus` alias |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` alias |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for `haiku` alias |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |
| `ANTHROPIC_CUSTOM_MODEL_OPTION` | Add custom entry to `/model` picker |

### Fast mode

Toggle with `/fast`. Uses Opus 4.6 with 2.5x speed at higher cost ($30/$150 MTok input/output). Requires extra usage enabled. Falls back to standard Opus on rate limit. Persists across sessions unless `fastModePerSessionOptIn: true` is set. Not available on Bedrock/Vertex/Foundry or Opus 4.7.

### Output styles

| Style | Behavior |
| :--- | :--- |
| Default | Standard software engineering assistant |
| Explanatory | Adds educational "Insights" alongside coding |
| Learning | Collaborative learn-by-doing with `TODO(human)` markers |
| Custom | Markdown file in `~/.claude/output-styles/` or `.claude/output-styles/` |

Set via `/config` > Output style. Custom styles support `name`, `description`, and `keep-coding-instructions` frontmatter.

### Checkpointing

Every user prompt creates a checkpoint. Press `Esc` twice or use `/rewind` to open the rewind menu. Actions: restore code and conversation, restore conversation only, restore code only, or summarize from a point forward. Bash command changes and external edits are not tracked.

### Context window

What loads at startup: system prompt, auto memory (MEMORY.md), environment info, MCP tool names (deferred), skill descriptions, CLAUDE.md files (global + project).

| Mechanism | After compaction |
| :--- | :--- |
| System prompt, output style | Unchanged |
| Project-root CLAUDE.md, unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | Lost until matching file read again |
| Invoked skill bodies | Re-injected (capped 5K tokens/skill, 25K total) |
| Hooks | Not applicable (run externally) |

Check context: `/context` for live breakdown, `/memory` for loaded files.

### Remote Control

Drive a local session from claude.ai/code or Claude mobile app.

| Mode | Command | Description |
| :--- | :--- | :--- |
| Server mode | `claude remote-control` | Dedicated server, accepts multiple sessions |
| Interactive | `claude --remote-control` | Normal session + remote access |
| Existing session | `/remote-control` | Enable on current session |

Flags: `--name`, `--spawn` (`same-dir`/`worktree`/`session`), `--capacity <N>`, `--verbose`, `--sandbox`. Available on Pro/Max/Team/Enterprise (Team/Enterprise must enable in admin settings). Mobile push notifications available with `/config` > Push when Claude decides.

### Scheduled tasks (/loop)

| What you provide | Behavior |
| :--- | :--- |
| Interval + prompt | Fixed schedule (`/loop 5m check deploy`) |
| Prompt only | Claude-chosen interval (`/loop check CI`) |
| Nothing | Built-in maintenance prompt or custom `loop.md` |

Tasks are session-scoped (7-day expiry). Tools: `CronCreate`, `CronList`, `CronDelete`. Disable: `CLAUDE_CODE_DISABLE_CRON=1`.

### Desktop scheduled tasks

Create from Desktop app Schedule page. Fields: name, description, prompt, frequency (manual/hourly/daily/weekdays/weekly). Runs on your machine while app is open. Missed runs: one catch-up run on wake for most recent miss within 7 days. Task config on disk: `~/.claude/scheduled-tasks/<task-name>/SKILL.md`.

### Routines (cloud scheduled tasks)

Run on Anthropic cloud infrastructure. Triggers: scheduled (hourly/daily/weekly), API (HTTP POST), GitHub (PR/release events). Create at claude.ai/code/routines or via `/schedule` in CLI. Require Claude Code on the web enabled. Each run clones repo fresh. Pushes only to `claude/`-prefixed branches by default.

### Channels

Push events from external systems (Telegram, Discord, iMessage) into a running session via MCP servers.

| Setting | Purpose |
| :--- | :--- |
| `channelsEnabled` | Master switch (Team/Enterprise: off by default) |
| `allowedChannelPlugins` | Restrict which plugins can register |

Enable with `--channels plugin:<name>@<marketplace>`. Build custom channels using `@modelcontextprotocol/sdk` with `claude/channel` capability. Support one-way (alerts/webhooks) and two-way (chat bridges with reply tools). Permission relay available with `claude/channel/permission` capability. Research preview, requires v2.1.80+.

### Voice dictation

Enable with `/voice`. Hold Space (or custom key) to record. Transcribed live. Requires claude.ai auth (no API key/Bedrock/Vertex). Set language in `/config` or `language` setting. Rebind push-to-talk key in `~/.claude/keybindings.json`.

### Status line

Customizable bar running a shell script that receives JSON session data on stdin.

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

Generate with `/statusline <description>`. Key JSON fields: `model.display_name`, `context_window.used_percentage`, `cost.total_cost_usd`, `cost.total_duration_ms`, `rate_limits.five_hour.used_percentage`. Subagent status: `subagentStatusLine` setting.

### Fullscreen rendering

Enable with `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1`. Alternate screen buffer, no flicker, flat memory, mouse support. Research preview (v2.1.89+).

| Shortcut | Action |
| :--- | :--- |
| `PgUp`/`PgDn` | Scroll half screen |
| `Ctrl+Home`/`Ctrl+End` | Jump to start/end |
| `Ctrl+o` | Toggle transcript mode |
| `/` (transcript) | Search |
| `[` (transcript) | Write to native scrollback |

Disable mouse only: `CLAUDE_CODE_DISABLE_MOUSE=1`. `/focus` for minimal view.

### Extend Claude Code (features overview)

| Feature | When it loads | Context cost |
| :--- | :--- | :--- |
| CLAUDE.md | Session start | Every request |
| Skills | On demand | Low (descriptions every request) |
| MCP servers | Session start | Low until tool used |
| Subagents | When spawned | Isolated from main |
| Hooks | On trigger | Zero (runs externally) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Features overview](references/claude-code-features-overview.md) -- extension layer overview: CLAUDE.md, skills, MCP, subagents, hooks, plugins, and how they combine
- [Model configuration](references/claude-code-model-config.md) -- model aliases, effort levels, extended context, model pinning, prompt caching
- [Fast mode](references/claude-code-fast-mode.md) -- 2.5x speed Opus 4.6, pricing, rate limits, per-session opt-in
- [Output styles](references/claude-code-output-styles.md) -- built-in and custom output styles, frontmatter, comparison with CLAUDE.md and skills
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic edit tracking, rewind menu, restore vs summarize
- [Context window](references/claude-code-context-window.md) -- interactive simulation of context loading, compaction survival, token costs
- [Remote Control](references/claude-code-remote-control.md) -- drive local sessions from browser or mobile, server mode, push notifications
- [Scheduled tasks](references/claude-code-scheduled-tasks.md) -- /loop command, cron tools, one-time reminders, loop.md customization
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) -- recurring tasks in Desktop app, frequency options, missed run catch-up
- [Routines](references/claude-code-routines.md) -- cloud-hosted scheduled/API/GitHub-triggered automation
- [Channels](references/claude-code-channels.md) -- push events from Telegram, Discord, iMessage into sessions
- [Channels reference](references/claude-code-channels-reference.md) -- build custom channel MCP servers, notification format, reply tools, permission relay
- [Voice dictation](references/claude-code-voice-dictation.md) -- push-to-talk, supported languages, keybinding customization
- [Status line](references/claude-code-statusline.md) -- custom status bar, JSON data fields, script examples
- [Fullscreen rendering](references/claude-code-fullscreen.md) -- flicker-free alternate screen, mouse support, transcript mode

## Sources

- Features overview: https://code.claude.com/docs/en/features-overview.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Context window: https://code.claude.com/docs/en/context-window.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Routines: https://code.claude.com/docs/en/routines.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
