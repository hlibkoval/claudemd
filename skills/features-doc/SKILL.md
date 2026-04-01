---
name: features-doc
description: Complete documentation for Claude Code features -- features overview (extension architecture with CLAUDE.md/Skills/MCP/Subagents/Agent teams/Hooks/Plugins, feature comparison tables, context costs, loading behavior), fast mode (toggle /fast, Opus 4.6 2.5x speed, $30/150 MTok pricing, per-session opt-in fastModePerSessionOptIn, rate limit fallback, extra usage required, Teams/Enterprise admin enablement), model configuration (aliases default/sonnet/opus/haiku/sonnet[1m]/opus[1m]/opusplan, /model command, --model flag, ANTHROPIC_MODEL env, availableModels restriction, default model per plan tier, opusplan hybrid plan/execute, effort levels low/medium/high/max with /effort and effortLevel setting and CLAUDE_CODE_EFFORT_LEVEL env, extended 1M context, modelOverrides for third-party deployments, ANTHROPIC_DEFAULT_OPUS_MODEL/SONNET/HAIKU env vars, prompt caching config DISABLE_PROMPT_CACHING, custom model option ANTHROPIC_CUSTOM_MODEL_OPTION, pinned model display _NAME/_DESCRIPTION/_SUPPORTED_CAPABILITIES), output styles (Default/Explanatory/Learning built-in styles, custom output styles in ~/.claude/output-styles or .claude/output-styles, frontmatter name/description/keep-coding-instructions, system prompt modification), status line (custom shell script status bar, /statusline command, statusLine setting type/command/padding, JSON session data on stdin with model/cost/context_window/rate_limits/git/vim/worktree fields, ANSI colors, multi-line output, clickable links, context window fields current_usage, Windows PowerShell support), checkpointing (automatic edit tracking, Esc+Esc or /rewind to open rewind menu, restore code/conversation/both, summarize from here for targeted context compression, 30-day cleanup, bash changes not tracked, not a git replacement), remote control (continue local sessions from phone/tablet/browser, /remote-control or --remote-control or claude remote-control server mode, --name/--spawn/--capacity/--verbose/--sandbox flags, QR code pairing, session URL, outbound HTTPS only, no inbound ports, Team/Enterprise admin toggle, vs Claude Code on the web), scheduled tasks (/loop bundled skill for recurring prompts, interval syntax 5m/2h/leading/trailing, CronCreate/CronList/CronDelete tools, one-time reminders, session-scoped 3-day expiry, jitter, CLAUDE_CODE_DISABLE_CRON, compare cloud vs Desktop vs /loop), voice dictation (/voice toggle, hold Space push-to-talk, rebindable to modifier combo via keybindings.json voice:pushToTalk, streaming transcription, coding vocabulary recognition, 20 supported languages, requires Claude.ai account, local microphone access, voiceEnabled setting), channels (push events into running session from Telegram/Discord/iMessage, channel plugins, --channels flag, sender allowlists, pairing codes, channelsEnabled and allowedChannelPlugins managed settings, research preview, two-way chat bridge, webhook receiver), channels reference (build custom MCP channel servers, claude/channel capability, notifications/claude/channel events, reply tools, sender gating, permission relay, webhook example), web scheduled tasks (cloud scheduled tasks at claude.ai/code/scheduled, /schedule command, hourly/daily/weekdays/weekly frequency, repositories with claude/ branch prefix, connectors, cloud environments, Run now, pause/resume), context window (interactive simulation of context filling, system prompt 4200 tokens, auto memory, environment info, MCP tools deferred, skill descriptions, CLAUDE.md loading, file read costs, compaction behavior), fullscreen rendering (CLAUDE_CODE_NO_FLICKER=1, alternate screen buffer, mouse support click/drag/scroll/URL, Ctrl+o transcript mode with /search and less-style navigation, PgUp/PgDn scrolling, CLAUDE_CODE_SCROLL_SPEED, CLAUDE_CODE_DISABLE_MOUSE=1, tmux compatibility, copy on select, research preview). Load when discussing Claude Code features, fast mode, /fast, model configuration, /model, model aliases, opusplan, effort level, /effort, extended context, 1M context, output styles, /config output style, Explanatory mode, Learning mode, status line, /statusline, statusLine setting, checkpointing, /rewind, rewind, undo changes, remote control, /remote-control, --remote-control, remote sessions, phone access, mobile access, scheduled tasks, /loop, cron, /schedule, cloud scheduled tasks, web scheduled tasks, voice dictation, /voice, push-to-talk, speech-to-text, channels, --channels, Telegram channel, Discord channel, iMessage channel, channel reference, build a channel, webhook receiver, context window explorer, fullscreen rendering, no-flicker mode, CLAUDE_CODE_NO_FLICKER, features overview, extension comparison, CLAUDE.md vs skills, skill vs subagent, MCP vs skill, context costs, or any Claude Code feature configuration topic.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features -- model configuration, fast mode, output styles, status line, checkpointing, remote control, scheduled tasks, voice dictation, channels, context window, fullscreen rendering, and the features overview.

## Quick Reference

### Model Aliases

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended model for your account type (Max/Team Premium = Opus 4.6; Pro/Team Standard = Sonnet 4.6) |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast and efficient Haiku |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus for plan mode, Sonnet for execution |

**Setting model:** `/model <alias>` in session, `claude --model <alias>`, `ANTHROPIC_MODEL` env var, or `model` in settings.

**Restrict models:** Set `availableModels` in managed/policy settings. Combine with `model` and `ANTHROPIC_DEFAULT_*_MODEL` env vars for full control.

### Effort Levels

| Level | Behavior |
|:------|:---------|
| `low` | Less thinking, faster, potentially lower quality |
| `medium` | Default for Opus 4.6 and Sonnet 4.6; recommended for most tasks |
| `high` | Deeper reasoning for complex problems |
| `max` | Deepest reasoning, no token constraint; Opus 4.6 only, does not persist |

**Setting effort:** `/effort <level>`, arrow keys in `/model`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL` env var, `effortLevel` in settings, or `effort` in skill/subagent frontmatter. Say "ultrathink" in a prompt for one-off high effort.

### Extended Context (1M Tokens)

| Plan | Opus 4.6 1M | Sonnet 4.6 1M |
|:-----|:------------|:--------------|
| Max, Team, Enterprise | Included | Extra usage required |
| Pro | Extra usage required | Extra usage required |
| API / pay-as-you-go | Full access | Full access |

Use `/model opus[1m]` or `/model sonnet[1m]`. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

### Fast Mode

Toggle with `/fast`. Opus 4.6 at 2.5x speed, pricing $30/150 MTok (flat across full 1M context).

| Requirement | Details |
|:------------|:--------|
| Plans | Pro/Max/Team/Enterprise subscriptions and Console API |
| Extra usage | Must be enabled; fast mode billed directly to extra usage |
| Teams/Enterprise | Admin must enable in Console or Claude AI admin settings |
| Not available | Bedrock, Vertex AI, Foundry |

**Per-session opt-in:** Set `fastModePerSessionOptIn: true` in managed settings to reset fast mode each session. **Rate limits:** Falls back to standard Opus 4.6 on limit hit; `↯` icon turns gray during cooldown. **Disable entirely:** `CLAUDE_CODE_DISABLE_FAST_MODE=1`.

### Output Styles

| Style | Behavior |
|:------|:---------|
| Default | Standard software engineering system prompt |
| Explanatory | Educational "Insights" between coding help |
| Learning | Collaborative mode with `TODO(human)` markers for you to implement |
| Custom | Markdown files in `~/.claude/output-styles/` or `.claude/output-styles/` |

**Custom frontmatter:** `name`, `description`, `keep-coding-instructions` (default false). Set via `/config` > Output style, or `outputStyle` in settings. Changes take effect next session.

### Checkpointing

Automatic edit tracking with every user prompt. Access with `Esc` + `Esc` or `/rewind`.

| Action | Effect |
|:-------|:-------|
| Restore code and conversation | Revert both to selected point |
| Restore conversation | Rewind messages, keep current code |
| Restore code | Revert files, keep conversation |
| Summarize from here | Compress selected point onward into summary (no file changes) |

Limitations: bash command changes not tracked, external changes not tracked, not a replacement for git. Checkpoints persist across sessions, cleaned up after 30 days.

### Remote Control

Continue a local CLI or VS Code session from phone, tablet, or browser via claude.ai/code or Claude mobile app.

| Start method | Command |
|:-------------|:--------|
| Server mode | `claude remote-control` (dedicated server, waits for connections) |
| Interactive | `claude --remote-control` or `claude --rc` |
| Existing session | `/remote-control` or `/rc` |

**Server mode flags:** `--name`, `--spawn <same-dir|worktree>`, `--capacity <N>`, `--verbose`, `--sandbox`/`--no-sandbox`.

**Requirements:** Subscription plan (Pro/Max/Team/Enterprise), claude.ai OAuth login, workspace trust accepted. Team/Enterprise: admin must enable Remote Control toggle. **Security:** Outbound HTTPS only, no inbound ports. **Enable for all sessions:** `/config` > Enable Remote Control for all sessions.

### Scheduled Tasks

**Three scheduling options:**

| Feature | Runs on | Persistent | Requires open session |
|:--------|:--------|:-----------|:---------------------|
| Cloud (`/schedule`) | Anthropic cloud | Yes | No |
| Desktop | Your machine | Yes | No |
| `/loop` | Your machine | No (session-scoped) | Yes |

**`/loop` syntax:** `/loop 5m <prompt>`, `/loop <prompt> every 2h`, `/loop <prompt>` (default 10m). Units: `s`, `m`, `h`, `d`. Can loop over commands: `/loop 20m /review-pr 1234`.

**Cron tools:** `CronCreate` (schedule), `CronList` (list), `CronDelete` (cancel by ID). Max 50 tasks per session, 3-day auto-expiry.

**Cloud scheduled tasks:** Create at claude.ai/code/scheduled, Desktop > Schedule > New remote task, or `/schedule` in CLI. Frequencies: hourly, daily, weekdays, weekly (minimum 1h). Repos cloned each run, pushes to `claude/`-prefixed branches by default. Supports connectors and cloud environments.

**Disable:** `CLAUDE_CODE_DISABLE_CRON=1`.

### Voice Dictation

Enable with `/voice`. Hold Space (default push-to-talk key) to record; release to finalize. Transcription tuned for coding vocabulary.

| Setting | Details |
|:--------|:--------|
| Persist | Stays on across sessions; `voiceEnabled: true` in settings |
| Language | Uses `language` setting; defaults to English; 20 languages supported |
| Rebind key | Set `voice:pushToTalk` in `~/.claude/keybindings.json`; use modifier combo (e.g., `meta+k`) to skip warmup |
| Requirements | Claude.ai account, local microphone, not available on Bedrock/Vertex/Foundry/API keys |

### Channels

Push events into a running session from external platforms. Research preview requiring claude.ai login and v2.1.80+.

| Channel | Setup |
|:--------|:------|
| Telegram | Create bot via BotFather, `/plugin install telegram@claude-plugins-official`, `/telegram:configure <token>`, restart with `--channels` |
| Discord | Create bot in Developer Portal, enable Message Content Intent, `/plugin install discord@claude-plugins-official`, `/discord:configure <token>`, restart with `--channels` |
| iMessage | macOS only, reads Messages DB directly, `/plugin install imessage@claude-plugins-official`, restart with `--channels` |
| Fakechat | Localhost demo, `/plugin install fakechat@claude-plugins-official`, restart with `--channels` |

**Security:** Sender allowlists via pairing codes. **Enterprise:** `channelsEnabled` (master switch, off by default for Team/Enterprise) and `allowedChannelPlugins` in managed settings.

**Build custom channels:** Declare `claude/channel` capability in MCP server, emit `notifications/claude/channel` events, connect via stdio. See channels reference for full contract.

### Status Line

Custom shell-script status bar. Configure with `/statusline <description>` or manually in settings:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

Script receives JSON on stdin with fields: `model.id`, `model.display_name`, `workspace.current_dir`, `workspace.project_dir`, `cost.total_cost_usd`, `cost.total_duration_ms`, `context_window.used_percentage`, `context_window.remaining_percentage`, `context_window.current_usage.*`, `rate_limits.five_hour.*`, `rate_limits.seven_day.*`, `session_id`, `version`, `vim.mode`, `agent.name`, `worktree.*`. Supports ANSI colors, multi-line output, and OSC 8 clickable links.

### Fullscreen Rendering

Opt-in flicker-free rendering mode. Enable with `CLAUDE_CODE_NO_FLICKER=1`. Research preview.

| Feature | Details |
|:--------|:--------|
| Rendering | Alternate screen buffer, only visible messages rendered, flat memory |
| Mouse | Click to position cursor, expand/collapse tool output, open URLs, drag to select text |
| Scrolling | PgUp/PgDn (half screen), Ctrl+Home/Ctrl+End, mouse wheel |
| Search | `Ctrl+o` for transcript mode, then `/` to search, `n`/`N` for matches |
| Native scrollback | `Ctrl+o` then `[` to write conversation to native scrollback |
| Disable mouse | `CLAUDE_CODE_DISABLE_MOUSE=1` (keeps flicker-free rendering) |
| Scroll speed | `CLAUDE_CODE_SCROLL_SPEED=<1-20>` |
| tmux | Requires `set -g mouse on`; incompatible with `tmux -CC` |

### Features Overview: Extension Comparison

| Feature | What it does | When to use |
|:--------|:-------------|:------------|
| CLAUDE.md | Persistent context every session | "Always do X" rules, conventions |
| Skill | Reusable knowledge and workflows | Reference docs, repeatable tasks (`/<name>`) |
| Subagent | Isolated execution, returns summary | Context isolation, parallel tasks |
| Agent teams | Coordinate multiple independent sessions | Parallel research, competing hypotheses |
| MCP | Connect to external services | Database queries, Slack, browser control |
| Hook | Deterministic script on events | Predictable automation, no LLM |
| Plugin | Bundle and distribute features | Reuse across repos, marketplace distribution |

### Context Cost by Feature

| Feature | When it loads | Context cost |
|:--------|:-------------|:-------------|
| CLAUDE.md | Session start | Every request |
| Skills | Start (descriptions) + when used (full) | Low until used |
| MCP servers | Session start (names only) | Low until tool used |
| Subagents | When spawned | Isolated from main session |
| Hooks | On trigger | Zero (runs externally) |

### Model Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_MODEL` | Set model at startup |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Pin opus alias to specific model ID |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Pin sonnet alias to specific model ID |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Pin haiku alias to specific model ID |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |
| `CLAUDE_CODE_EFFORT_LEVEL` | Override effort level (takes precedence over all other methods) |
| `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` | Set to `1` to revert to fixed thinking budget |
| `DISABLE_PROMPT_CACHING` | Set to `1` to disable prompt caching globally |
| `DISABLE_PROMPT_CACHING_OPUS` / `_SONNET` / `_HAIKU` | Disable prompt caching per model tier |
| `ANTHROPIC_CUSTOM_MODEL_OPTION` | Add custom entry to `/model` picker |

## Full Documentation

For the complete official documentation, see the reference files:

- [Features Overview](references/claude-code-features-overview.md) -- extension architecture, feature comparison tables, context costs, loading behavior
- [Fast Mode](references/claude-code-fast-mode.md) -- toggle, pricing, requirements, per-session opt-in, rate limits
- [Model Configuration](references/claude-code-model-config.md) -- aliases, effort levels, extended context, model overrides, environment variables
- [Output Styles](references/claude-code-output-styles.md) -- built-in and custom output styles, frontmatter, system prompt behavior
- [Status Line](references/claude-code-statusline.md) -- custom status bar setup, JSON data fields, examples
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic edit tracking, rewind, restore, summarize
- [Remote Control](references/claude-code-remote-control.md) -- continue local sessions from phone/tablet/browser
- [Scheduled Tasks](references/claude-code-scheduled-tasks.md) -- /loop, cron tools, session-scoped scheduling
- [Voice Dictation](references/claude-code-voice-dictation.md) -- push-to-talk, language support, keybinding
- [Channels](references/claude-code-channels.md) -- push events from Telegram, Discord, iMessage into a session
- [Channels Reference](references/claude-code-channels-reference.md) -- build custom channel MCP servers
- [Web Scheduled Tasks](references/claude-code-web-scheduled-tasks.md) -- cloud scheduled tasks on Anthropic infrastructure
- [Context Window](references/claude-code-context-window.md) -- interactive simulation of context window filling
- [Fullscreen Rendering](references/claude-code-fullscreen.md) -- flicker-free alternate screen buffer rendering with mouse support

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
