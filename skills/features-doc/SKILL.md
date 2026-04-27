---
name: features-doc
description: Complete official documentation for Claude Code features — the extension layer overview (CLAUDE.md vs skills vs hooks vs MCP vs subagents), model configuration and aliases, fast mode, output styles, status line, checkpointing, context window, remote control, channels, scheduled tasks, routines, fullscreen rendering, and voice dictation.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features.

## Quick Reference

### Extension layer overview

Each extension plugs into a different part of the agentic loop:

| Feature | What it does | When to add it |
| :--- | :--- | :--- |
| **CLAUDE.md** | Persistent context loaded every conversation | Claude gets a convention wrong twice |
| **Skill** | Reusable knowledge, reference docs, invocable workflows | You keep typing the same prompt to start a task |
| **Subagent** | Isolated worker with its own context | A side task floods your conversation with output |
| **Agent team** | Coordinate multiple independent sessions | Complex parallel research or feature work |
| **MCP** | Connect to external services and tools | You keep copying data from a tab Claude can't see |
| **Hook** | Script/HTTP/prompt triggered by lifecycle events | Something must happen every time without asking |
| **Plugin** | Package and distribute the above | A second repository needs the same setup |

### Feature context costs

| Feature | When it loads | Context cost |
| :--- | :--- | :--- |
| CLAUDE.md | Session start | Full content every request |
| Skills | Descriptions at start; full content on use | Low (descriptions only, until invoked) |
| Skills (`disable-model-invocation: true`) | Only when you invoke with `/name` | Zero until invoked |
| MCP servers | Tool names at start; schemas on demand | Low until a tool is used |
| Subagents | On demand (own isolated context) | Isolated from main session |
| Hooks | On trigger event | Zero unless hook returns output |

### Survival after `/compact`

| Mechanism | After compaction |
| :--- | :--- |
| System prompt and output style | Unchanged |
| Project-root CLAUDE.md and unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | Lost until a matching file is read again |
| Nested CLAUDE.md in subdirectories | Lost until a file in that subdirectory is read again |
| Invoked skill bodies | Re-injected, capped at 5,000 tokens/skill, 25,000 total |
| Hooks | Not applicable — hooks run as code, not context |

### Model aliases

| Alias | Resolves to |
| :--- | :--- |
| `default` | Clears override; reverts to subscription default |
| `best` | Most capable available (currently `opus`) |
| `sonnet` | Latest Sonnet (Sonnet 4.6 on Anthropic API) |
| `opus` | Latest Opus (Opus 4.7 on Anthropic API) |
| `haiku` | Fast, efficient Haiku |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus in plan mode, then auto-switches to Sonnet for execution |

Model selection priority: `/model` during session > `--model` flag > `ANTHROPIC_MODEL` env var > settings file.

### Effort levels

Supported on Opus 4.7, Opus 4.6, and Sonnet 4.6. Set with `/effort <level>` or `--effort` flag.

| Level | When to use |
| :--- | :--- |
| `low` | Short, scoped, latency-sensitive, not intelligence-sensitive |
| `medium` | Cost-sensitive work trading some intelligence |
| `high` | Balanced; minimum for intelligence-sensitive work |
| `xhigh` | Best for most coding and agentic tasks; default on Opus 4.7 |
| `max` | Demanding tasks; session-only; may show diminishing returns |

Default: `xhigh` on Opus 4.7, `high` on Opus 4.6 and Sonnet 4.6.

### Model env vars

| Variable | Controls |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for `opus` alias and `opusplan` plan phase |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` alias and `opusplan` execution phase |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for `haiku` alias and background tasks |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model used by subagents |

### Fast mode

Toggle with `/fast` or set `"fastMode": true` in user settings. Requires Opus 4.6; automatically switches to it.

- **2.5x faster** responses at higher per-token cost
- Pricing: **$30/$150 per MTok** (input/output)
- Available on subscription plans (Pro/Max/Team/Enterprise) and Console via extra usage only
- Rate limit separate from standard Opus 4.6; auto-falls back to standard on limit hit
- Admins: enable at claude.ai admin settings; set `fastModePerSessionOptIn: true` to require per-session opt-in

### Output styles

Output styles modify the system prompt to change role, tone, and format. Set via `/config` → Output style, or `"outputStyle": "..."` in settings.

| Style | Description |
| :--- | :--- |
| `Default` | Standard software engineering prompt |
| `Explanatory` | Adds "Insights" between coding tasks |
| `Learning` | Collaborative mode with `TODO(human)` markers |
| Custom | Markdown file in `~/.claude/output-styles/` or `.claude/output-styles/` |

Custom style frontmatter: `name`, `description`, `keep-coding-instructions` (default `false` — removes coding instructions).

### Checkpointing

Claude Code automatically checkpoints before each file edit. Rewind with **Esc+Esc** or `/rewind`.

| Rewind action | What it does |
| :--- | :--- |
| Restore code and conversation | Reverts both to selected point |
| Restore conversation | Rewinds message history; keeps current code |
| Restore code | Reverts files; keeps conversation |
| Summarize from here | Compresses messages from selected point forward; files unchanged |

Limitations: bash command file changes are not tracked; external changes are not tracked; not a replacement for git.

### Status line

A customizable shell-script bar at the bottom of the CLI. Configure via `/statusline <description>` or manually in settings:

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

Key JSON fields available on stdin: `model.display_name`, `workspace.current_dir`, `context_window.used_percentage`, `cost.total_cost_usd`, `cost.total_duration_ms`, `rate_limits.five_hour.used_percentage`, `rate_limits.seven_day.used_percentage`, `session_id`, `vim.mode`, `effort.level`.

### Fullscreen rendering

Opt-in alternative rendering that eliminates flicker and adds mouse support. Toggle with `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1`.

Key behaviors: input box stays fixed at bottom; mouse click to expand tool results, click URLs, click-drag to select text; `Ctrl+o` enters transcript mode with `/` search.

Incompatible with iTerm2 tmux integration mode (`tmux -CC`). Disable mouse capture only: `CLAUDE_CODE_DISABLE_MOUSE=1`.

### Voice dictation

Speak prompts instead of typing. Requires claude.ai account (not API key); not available in SSH/remote environments.

| Command | Effect |
| :--- | :--- |
| `/voice` | Toggle on/off (keeps current mode) |
| `/voice hold` | Hold Space to record; release to stop |
| `/voice tap` | Tap Space to start; tap again to send |
| `/voice off` | Disable |

Setting: `{"voice": {"enabled": true, "mode": "tap"}}`. Rebind key via `~/.claude/keybindings.json`, action `voice:pushToTalk` in `Chat` context.

### Channels (research preview)

Push events from external systems into a running Claude Code session. Requires v2.1.80+, claude.ai login.

Supported platforms: **Telegram**, **Discord**, **iMessage** (via official plugins), **fakechat** (localhost demo).

Install: `/plugin install <platform>@claude-plugins-official`, then `claude --channels plugin:<platform>@claude-plugins-official`

Enterprise: off by default; enable with `channelsEnabled: true` in managed settings. Restrict which plugins with `allowedChannelPlugins`.

**Build a custom channel**: an MCP server that declares `capabilities.experimental['claude/channel']: {}` and emits `notifications/claude/channel` events. For two-way channels, expose a reply MCP tool and add `capabilities.tools: {}`. Use `--dangerously-load-development-channels server:<name>` during development.

**Permission relay**: declare `capabilities.experimental['claude/channel/permission']: {}` to forward tool approval prompts to a remote device. Verdicts: `yes <id>` or `no <id>` matching the `request_id` field.

### Remote Control (research preview)

Connect claude.ai/code or the Claude mobile app to a locally running session. Runs entirely on your machine.

```bash
claude remote-control          # server mode (waits for connections)
claude --remote-control        # interactive session with RC enabled
# or in-session:
/remote-control
```

Requires claude.ai subscription (not API key). On Team/Enterprise, admin must enable the Remote Control toggle.

Spawn modes: `same-dir` (default), `worktree` (isolated git worktree per connection), `session` (single session only).

### Scheduling comparison

| | Cloud routines | Desktop scheduled tasks | `/loop` |
| :--- | :--- | :--- | :--- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Persistent | Yes | Yes | Restored on `--resume` if unexpired |
| Local file access | No (fresh clone) | Yes | Yes |
| Minimum interval | 1 hour | 1 minute | 1 minute |

### Scheduled tasks (`/loop`)

Session-scoped scheduling. Tasks expire after 7 days.

| Usage | Effect |
| :--- | :--- |
| `/loop 5m check the deploy` | Fixed-interval prompt |
| `/loop check the deploy` | Dynamic interval (Claude chooses) |
| `/loop` | Built-in maintenance prompt (continue work, tend PRs, cleanup) |

One-time reminders: describe in natural language, e.g. "remind me at 3pm to push the release branch".

Disable: `CLAUDE_CODE_DISABLE_CRON=1`.

### Desktop scheduled tasks

Created from the Desktop app's Routines page (New routine → Local). Fields: Name, Description, Instructions (with permission mode and model pickers), Schedule, working folder.

Schedules: Manual, Hourly, Daily, Weekdays, Weekly. For custom intervals, ask Claude in any Desktop session. Tasks only run while the app is open; missed runs get one catch-up run on wake.

Manage tasks: `/manage-tasks` or ask Claude ("pause my dependency-audit task"). Task files live at `~/.claude/scheduled-tasks/<task-name>/SKILL.md`.

### Routines (cloud, research preview)

Create at [claude.ai/code/routines](https://claude.ai/code/routines) or with `/schedule` in CLI.

Trigger types:

| Trigger | How |
| :--- | :--- |
| **Schedule** | Hourly/daily/weekdays/weekly presets or custom cron via `/schedule update` |
| **API** | HTTP POST to per-routine endpoint with bearer token |
| **GitHub** | PR or Release events with optional filters (author, title, labels, branch, draft/merged state) |

API trigger example:
```bash
curl -X POST https://api.anthropic.com/v1/claude_code/routines/<trig_id>/fire \
  -H "Authorization: Bearer <token>" \
  -H "anthropic-beta: experimental-cc-routine-2026-04-01" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"text": "optional run-specific context"}'
```

Response includes `claude_code_session_url` to watch the run.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code](references/claude-code-features-overview.md) — extension layer overview, when to use each feature, context costs, how features layer and combine
- [Model configuration](references/claude-code-model-config.md) — model aliases, effort levels, extended context (1M), env vars for pinning models, third-party provider config, prompt caching
- [Speed up responses with fast mode](references/claude-code-fast-mode.md) — toggling fast mode, cost tradeoffs, per-session opt-in, rate limit fallback
- [Output styles](references/claude-code-output-styles.md) — built-in styles (Default, Explanatory, Learning), custom output style files, comparison to CLAUDE.md and agents
- [Checkpointing](references/claude-code-checkpointing.md) — how automatic checkpointing works, rewind menu options, summarize from here, limitations
- [Explore the context window](references/claude-code-context-window.md) — interactive timeline of what loads when, what survives compaction, checking your session with `/context`
- [Customize your status line](references/claude-code-statusline.md) — setup, available JSON data fields, examples in Bash/Python/Node.js (context bar, git status, cost tracking, multi-line, clickable links, rate limits, caching), subagent status lines
- [Fullscreen rendering](references/claude-code-fullscreen.md) — enabling, mouse support, scroll shortcuts, transcript mode and search, tmux caveats, disabling mouse capture
- [Voice dictation](references/claude-code-voice-dictation.md) — hold mode, tap mode, supported languages, rebinding the dictation key, troubleshooting
- [Push events with channels](references/claude-code-channels.md) — Telegram, Discord, iMessage setup, fakechat quickstart, security/allowlists, enterprise controls, how channels compare to other features
- [Channels reference](references/claude-code-channels-reference.md) — building a custom channel, server options, notification format, reply tools, sender gating, permission relay, packaging as a plugin
- [Remote Control](references/claude-code-remote-control.md) — server mode, interactive session, in-session `/remote-control`, connecting from another device, security, mobile push notifications, limitations
- [Run prompts on a schedule](references/claude-code-scheduled-tasks.md) — `/loop` usage, dynamic vs fixed intervals, built-in maintenance prompt, loop.md customization, cron expression reference, one-time reminders, managing tasks
- [Schedule recurring tasks in Claude Code Desktop](references/claude-code-desktop-scheduled-tasks.md) — create/configure/manage local scheduled tasks, permissions, missed runs, worktree toggle
- [Automate work with routines](references/claude-code-routines.md) — creating routines, schedule/API/GitHub triggers, managing runs, usage limits

## Sources

- Extend Claude Code: https://code.claude.com/docs/en/features-overview.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Speed up responses with fast mode: https://code.claude.com/docs/en/fast-mode.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Explore the context window: https://code.claude.com/docs/en/context-window.md
- Customize your status line: https://code.claude.com/docs/en/statusline.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Push events with channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Run prompts on a schedule: https://code.claude.com/docs/en/scheduled-tasks.md
- Schedule recurring tasks in Claude Code Desktop: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Automate work with routines: https://code.claude.com/docs/en/routines.md
