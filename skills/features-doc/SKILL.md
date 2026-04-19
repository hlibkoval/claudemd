---
name: features-doc
description: Complete official documentation for Claude Code features — model configuration, fast mode, output styles, checkpointing, remote control, scheduled tasks, routines, channels, voice dictation, status line customization, context window mechanics, fullscreen rendering, and the features overview comparing CLAUDE.md, skills, hooks, MCP, subagents, and plugins.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features and configuration options.

## Quick Reference

### Model configuration

| Alias | Resolves to |
| :--- | :--- |
| `default` | Clears override; reverts to recommended model for your plan |
| `best` | Most capable model (currently `opus`) |
| `sonnet` | Latest Sonnet (Sonnet 4.6 on Anthropic API; Sonnet 4.5 on Bedrock/Vertex/Foundry) |
| `opus` | Latest Opus (Opus 4.7 on Anthropic API; Opus 4.6 on Bedrock/Vertex/Foundry) |
| `haiku` | Fast and efficient Haiku |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus for plan mode, Sonnet for execution |

Set model via `/model`, `--model`, `ANTHROPIC_MODEL` env var, or `model` in settings. Priority: session > startup flag > env var > settings.

**Default model by plan**: Max/Team Premium = Opus 4.7; Pro/Team Standard/Enterprise/API = Sonnet 4.6; Bedrock/Vertex/Foundry = Sonnet 4.5.

**Restrict models**: set `availableModels` in managed/policy settings (e.g., `["sonnet", "haiku"]`). Combine with `model` and `ANTHROPIC_DEFAULT_*_MODEL` env vars for full control.

### Effort levels

| Level | When to use |
| :--- | :--- |
| `low` | Short, scoped, latency-sensitive tasks |
| `medium` | Cost-sensitive work that can trade off some intelligence |
| `high` | Balances token usage and intelligence |
| `xhigh` | Best results for most coding/agentic tasks (default on Opus 4.7) |
| `max` | Demanding tasks; session-only unless set via env var |

Set via `/effort`, `/model` slider, `--effort`, `CLAUDE_CODE_EFFORT_LEVEL`, or `effortLevel` in settings. Supported on Opus 4.7 (`low`-`max`), Opus 4.6, and Sonnet 4.6 (`low`-`high`, `max`).

### Extended context (1M tokens)

Opus 4.7, Opus 4.6, and Sonnet 4.6 support 1M context. On Max/Team/Enterprise, Opus auto-upgrades to 1M. Use `opus[1m]` or `sonnet[1m]` aliases. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

### Fast mode

Toggle with `/fast`. Uses Opus 4.6 at 2.5x speed with higher pricing ($30/$150 MTok). Available on all subscription plans via extra usage only. Not available on Bedrock/Vertex/Foundry.

| Behavior | Detail |
| :--- | :--- |
| Enable/disable | `/fast` toggle or `"fastMode": true` in settings |
| Persistence | Persists across sessions by default; admins can set `fastModePerSessionOptIn: true` |
| Rate limit fallback | Auto-falls back to standard Opus 4.6; re-enables after cooldown |
| Indicator | `↯` icon next to prompt (gray during cooldown) |

### Output styles

| Style | Behavior |
| :--- | :--- |
| `Default` | Standard software engineering system prompt |
| `Explanatory` | Educational "Insights" between coding tasks |
| `Learning` | Collaborative mode with `TODO(human)` markers |
| Custom | Markdown files in `~/.claude/output-styles` or `.claude/output-styles` |

Set via `/config > Output style` or `"outputStyle"` in settings. Custom styles use frontmatter: `name`, `description`, `keep-coding-instructions` (default `false`).

### Checkpointing

Automatic tracking of Claude's file edits. Rewind with `Esc` + `Esc` or `/rewind`.

| Action | Effect |
| :--- | :--- |
| Restore code and conversation | Revert both to selected point |
| Restore conversation | Rewind messages, keep current code |
| Restore code | Revert files, keep conversation |
| Summarize from here | Compress conversation from selected point forward |

Limitations: bash command changes not tracked; external changes not tracked; not a replacement for version control.

### Remote Control

Continue local CLI/VS Code sessions from any browser or mobile device via `claude.ai/code`.

| Invocation | Command |
| :--- | :--- |
| Server mode | `claude remote-control` |
| Interactive session | `claude --remote-control` or `claude --rc` |
| Existing session | `/remote-control` or `/rc` |
| VS Code | `/remote-control` in prompt box |

Available on Pro/Max/Team/Enterprise (Team/Enterprise: admin must enable toggle). Not available with API keys or third-party providers. Session runs locally; web/mobile is a window into it.

### Scheduling overview

| Option | Runs on | Requires machine | Requires open session | Min interval |
| :--- | :--- | :--- | :--- | :--- |
| [Routines](/en/routines) (cloud) | Anthropic cloud | No | No | 1 hour |
| [Desktop tasks](/en/desktop-scheduled-tasks) | Your machine | Yes | No | 1 minute |
| [`/loop`](/en/scheduled-tasks) | Your machine | Yes | Yes | 1 minute |

### /loop quick reference

| Input | Behavior |
| :--- | :--- |
| `/loop 5m <prompt>` | Fixed interval with your prompt |
| `/loop <prompt>` | Claude picks interval dynamically (1m-1h) |
| `/loop` | Built-in maintenance prompt (or `loop.md` if exists) |

Stop with `Esc`. Tasks expire after 7 days. Cron tools: `CronCreate`, `CronList`, `CronDelete`. Disable with `CLAUDE_CODE_DISABLE_CRON=1`.

### Routines (cloud scheduling)

Saved Claude Code configurations running on Anthropic cloud. Triggers: scheduled, API (HTTP POST), GitHub events (pull_request, release). Created at `claude.ai/code/routines`, via `/schedule` in CLI, or Desktop app. Requires Claude Code on the web enabled.

### Desktop scheduled tasks

Recurring tasks in Claude Code Desktop. Local tasks run on your machine with local file access. Remote tasks run on Anthropic cloud. Created via Schedule page in Desktop sidebar. Missed runs: one catch-up run for the most recently missed time (last 7 days).

### Channels

MCP servers that push events into running sessions. Research preview; requires claude.ai login.

| Channel | Setup |
| :--- | :--- |
| Telegram | `/plugin install telegram@claude-plugins-official`, configure bot token, `--channels` flag |
| Discord | `/plugin install discord@claude-plugins-official`, configure bot token, `--channels` flag |
| iMessage | `/plugin install imessage@claude-plugins-official`, macOS only, no bot token needed |
| Custom | Build with `@modelcontextprotocol/sdk`, declare `claude/channel` capability |

Security: sender allowlist per channel. Enterprise: `channelsEnabled` and `allowedChannelPlugins` in managed settings.

### Voice dictation

Push-to-talk dictation via `/voice`. Hold `Space` to record (rebindable). Requires claude.ai account; audio streamed to Anthropic servers. Supports 20 languages. Set language in `/config` or `language` setting.

### Status line

Customizable bar at bottom of CLI. Runs a shell script receiving JSON session data on stdin.

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

Key JSON fields: `model.display_name`, `workspace.current_dir`, `cost.total_cost_usd`, `context_window.used_percentage`, `rate_limits.five_hour.used_percentage`. Set up via `/statusline <description>` or manually.

### Context window mechanics

| What loads | When | Context cost |
| :--- | :--- | :--- |
| System prompt | Session start | Every request |
| CLAUDE.md | Session start | Every request |
| Auto memory (MEMORY.md) | Session start | Every request |
| Skill descriptions | Session start | Low (every request) |
| MCP tool names | Session start | Low until used |
| Skills (full content) | When invoked | Only when active |
| Subagents | When spawned | Isolated from main |
| Hooks | On trigger | Zero (external) |

After `/compact`: system prompt, CLAUDE.md, auto memory re-injected. Path-scoped rules and nested CLAUDE.md lost until matching files read again. Invoked skill bodies re-injected (capped at 5K tokens/skill, 25K total).

### Fullscreen rendering

Opt-in flicker-free rendering mode. Enable with `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1`.

| Feature | Detail |
| :--- | :--- |
| Mouse support | Click to expand tool output, select text, click URLs |
| Scrolling | `PgUp`/`PgDn`, `Ctrl+Home`/`Ctrl+End`, mouse wheel |
| Search | `Ctrl+o` for transcript mode, `/` to search |
| Focus mode | `/focus` for minimal view (last prompt + summary + response) |
| Disable mouse | `CLAUDE_CODE_DISABLE_MOUSE=1` |
| Scroll speed | `CLAUDE_CODE_SCROLL_SPEED=3` |

### Features comparison

| Feature | What it does | When to use |
| :--- | :--- | :--- |
| CLAUDE.md | Persistent context every session | Project conventions, "always do X" rules |
| Skill | Reusable knowledge and workflows | Reference docs, repeatable tasks |
| Subagent | Isolated execution context | Context isolation, parallel tasks |
| Agent teams | Multiple independent sessions | Parallel research, competing hypotheses |
| MCP | Connect to external services | External data or actions |
| Hook | Deterministic script on events | Automation without LLM involvement |

### Model environment variables

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Pin the opus alias to a specific model |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Pin the sonnet alias |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Pin the haiku alias |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |
| `ANTHROPIC_CUSTOM_MODEL_OPTION` | Add custom entry to `/model` picker |
| `DISABLE_PROMPT_CACHING` | Set to `1` to disable prompt caching |

### Prompt caching

| Variable | Effect |
| :--- | :--- |
| `DISABLE_PROMPT_CACHING` | Disable for all models |
| `DISABLE_PROMPT_CACHING_HAIKU` | Disable for Haiku only |
| `DISABLE_PROMPT_CACHING_SONNET` | Disable for Sonnet only |
| `DISABLE_PROMPT_CACHING_OPUS` | Disable for Opus only |

## Full Documentation

For the complete official documentation, see the reference files:

- [Features overview](references/claude-code-features-overview.md) -- when to use CLAUDE.md, skills, subagents, hooks, MCP, and plugins; feature comparison tables; context cost by feature; how features layer and combine
- [Model configuration](references/claude-code-model-config.md) -- model aliases, setting models, effort levels, extended context, opusplan, model restrictions, pinning models for third-party providers, modelOverrides, prompt caching configuration
- [Fast mode](references/claude-code-fast-mode.md) -- toggling fast mode, cost tradeoff, requirements, per-session opt-in, rate limit handling
- [Output styles](references/claude-code-output-styles.md) -- built-in styles, custom output style creation, frontmatter fields, comparisons to CLAUDE.md and agents
- [Status line](references/claude-code-statusline.md) -- configuration, available JSON fields, script examples (context bar, git status, cost tracking, multi-line, clickable links, rate limits, caching), subagent status lines, troubleshooting
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic tracking, rewind and summarize, restore vs summarize, limitations
- [Remote Control](references/claude-code-remote-control.md) -- server mode, interactive session, VS Code, connection security, mobile push notifications, comparison to Claude Code on the web
- [Scheduled tasks](references/claude-code-scheduled-tasks.md) -- /loop command, fixed and dynamic intervals, built-in maintenance prompt, loop.md customization, one-time reminders, cron expression reference, jitter and expiry
- [Routines](references/claude-code-routines.md) -- cloud-based scheduled automation, schedule/API/GitHub triggers, connectors, environments, usage limits
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) -- creating tasks in Desktop app, frequency options, missed runs, permissions for scheduled tasks
- [Voice dictation](references/claude-code-voice-dictation.md) -- enabling voice, recording prompts, language support, push-to-talk rebinding, troubleshooting
- [Channels](references/claude-code-channels.md) -- Telegram, Discord, iMessage setup; sender allowlists; enterprise controls; comparison to other remote features
- [Channels reference](references/claude-code-channels-reference.md) -- building custom channels, MCP server contract, notification format, reply tools, sender gating, permission relay
- [Context window](references/claude-code-context-window.md) -- interactive context window simulation, what loads when, what survives compaction, context checking commands
- [Fullscreen rendering](references/claude-code-fullscreen.md) -- enabling fullscreen, mouse support, scrolling, transcript mode, search, tmux usage, disabling mouse capture

## Sources

- Features overview: https://code.claude.com/docs/en/features-overview.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Routines: https://code.claude.com/docs/en/routines.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Context window: https://code.claude.com/docs/en/context-window.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
