---
name: features-doc
description: Complete official documentation for Claude Code features — extension overview (CLAUDE.md, skills, MCP, subagents, hooks, plugins), model configuration and aliases, fast mode, effort levels, output styles, status line customization, checkpointing and rewind, remote control, scheduled tasks, routines, channels, voice dictation, fullscreen rendering, and the interactive context window explorer.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features.

## Quick Reference

### Extension overview

| Feature | What it does | Best for |
| :--- | :--- | :--- |
| **CLAUDE.md** | Persistent context loaded every session | Project conventions, "always do X" rules |
| **Skills** | Instructions, knowledge, and workflows Claude can use | Reusable content, reference docs, repeatable tasks |
| **Subagents** | Isolated execution context that returns summarized results | Context isolation, parallel tasks, specialized workers |
| **Agent teams** | Coordinate multiple independent Claude Code sessions | Parallel research, competing hypotheses, new feature dev |
| **MCP** | Connect to external services | External data or actions |
| **Hooks** | Script/HTTP/prompt/subagent triggered by lifecycle events | Automation that must run on every matching event |
| **Plugins** | Package and distribute skills, hooks, subagents, MCP servers | Reuse across repos, distribution to others |

**Build your setup over time:**

| Trigger | Add |
| :--- | :--- |
| Claude gets a convention wrong twice | Add it to CLAUDE.md |
| You keep typing the same prompt | Save it as a user-invocable skill |
| You paste the same procedure repeatedly | Capture it as a skill |
| You keep copying data from a browser tab | Connect that system as an MCP server |
| A side task floods your conversation | Route it through a subagent |
| Something should happen every time without asking | Write a hook |
| A second repository needs the same setup | Package it as a plugin |

### Context cost by feature

| Feature | When it loads | Context cost |
| :--- | :--- | :--- |
| **CLAUDE.md** | Session start (full content) | Every request |
| **Skills** | Descriptions at start; full content when used | Low (descriptions only until invoked) |
| **MCP servers** | Tool names at start; schemas on demand | Low until a tool is used |
| **Subagents** | When spawned (fresh isolated context) | Isolated from main session |
| **Hooks** | On trigger (runs externally) | Zero unless hook returns output |

Set `disable-model-invocation: true` in a skill's frontmatter to reduce context cost to zero until you invoke it manually.

### Model aliases

| Alias | Behavior |
| :--- | :--- |
| `default` | Clears any model override; reverts to account default |
| `best` | Most capable available model (currently equivalent to `opus`) |
| `sonnet` | Latest Sonnet model for daily coding tasks |
| `opus` | Latest Opus model for complex reasoning tasks |
| `haiku` | Fast, efficient Haiku model for simple tasks |
| `sonnet[1m]` | Sonnet with 1 million token context window |
| `opus[1m]` | Opus with 1 million token context window |
| `opusplan` | Uses `opus` in plan mode, switches to `sonnet` for execution |

On Anthropic API: `opus` = Opus 4.7, `sonnet` = Sonnet 4.6. On Bedrock/Vertex/Foundry: `opus` = Opus 4.6, `sonnet` = Sonnet 4.5.

**Set model:** `/model <alias|name>`, `--model <alias|name>`, `ANTHROPIC_MODEL=<alias|name>`, or `model` key in settings.

**Default model per account type:**
- Max, Team Premium: Opus 4.7
- Pro, Team Standard, Enterprise, Anthropic API: Sonnet 4.6
- Bedrock, Vertex, Foundry: Sonnet 4.5

### Effort levels

Supported on Opus 4.7, Opus 4.6, and Sonnet 4.6. Set via `/effort`, `--effort`, `CLAUDE_CODE_EFFORT_LEVEL`, or `effortLevel` in settings.

| Level | When to use |
| :--- | :--- |
| `low` | Latency-sensitive, scoped, non-intelligence-sensitive tasks |
| `medium` | Cost-sensitive work that can trade off some intelligence |
| `high` | Intelligence-sensitive work; minimum for agentic tasks |
| `xhigh` | Best results for most coding/agentic tasks (default on Opus 4.7) |
| `max` | Demanding tasks; may show diminishing returns; session-only |

Opus 4.7 supports `low`, `medium`, `high`, `xhigh`, `max`. Opus 4.6 and Sonnet 4.6 support `low`, `medium`, `high`, `max`.

### Fast mode

Fast mode makes Opus 4.6 responses 2.5x faster at higher token cost ($30/$150 per MTok input/output). Toggle with `/fast`.

- Available on Pro/Max/Team/Enterprise and Console (not Bedrock/Vertex/Foundry)
- Billed as extra usage from the first token (not included in subscription limits)
- Team/Enterprise: admin must enable it first
- Persists across sessions by default; set `fastModePerSessionOptIn: true` in managed settings to require opt-in each session
- Falls back to standard Opus 4.6 on rate limit

### Extended context (1M token)

Opus 4.7, Opus 4.6, and Sonnet 4.6 support 1M token context. Use `/model opus[1m]`, `/model sonnet[1m]`, or append `[1m]` to a full model name.

| Plan | Opus 1M | Sonnet 1M |
| :--- | :--- | :--- |
| Max, Team, Enterprise | Included | Requires extra usage |
| Pro | Requires extra usage | Requires extra usage |
| API and pay-as-you-go | Full access | Full access |

### Output styles

Change how Claude responds (role, tone, format) without changing capabilities.

| Style | Description |
| :--- | :--- |
| `Default` | Standard software engineering system prompt |
| `Explanatory` | Adds "Insights" between tasks to explain implementation choices |
| `Learning` | Collaborative mode; adds `TODO(human)` markers for you to implement |
| Custom | Markdown file with frontmatter (`name`, `description`, `keep-coding-instructions`) |

Change via `/config` → Output style, or set `outputStyle` in settings. Custom styles stored at `~/.claude/output-styles/` (user) or `.claude/output-styles/` (project).

### Status line

Shell script that receives JSON session data via stdin and prints to stdout. Configure in `~/.claude/settings.json`:

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

Use `/statusline <description>` to generate a script automatically.

**Key status line JSON fields:**

| Field | Description |
| :--- | :--- |
| `model.display_name` | Current model name |
| `context_window.used_percentage` | Context usage percentage |
| `context_window.context_window_size` | Max tokens (200000 or 1000000) |
| `cost.total_cost_usd` | Estimated session cost |
| `cost.total_duration_ms` | Total session wall-clock time |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit usage (Pro/Max only) |
| `rate_limits.seven_day.used_percentage` | 7-day rate limit usage (Pro/Max only) |
| `effort.level` | Current effort level |
| `session_id` | Unique session identifier (use for caching) |
| `vim.mode` | Current vim mode (when vim mode enabled) |
| `worktree.name` / `worktree.branch` | Worktree info (during `--worktree` sessions) |

`used_percentage` is calculated from input-only tokens: `input_tokens + cache_creation_input_tokens + cache_read_input_tokens`.

### Checkpointing and rewind

Claude Code automatically captures state before each file edit.

- Every user prompt creates a checkpoint
- Checkpoints persist across sessions (cleaned up after 30 days)
- Press `Esc Esc` or run `/rewind` to open the rewind menu

**Rewind actions:**
- **Restore code and conversation**: revert both to selected point
- **Restore conversation**: rewind conversation, keep current code
- **Restore code**: revert file changes, keep conversation
- **Summarize from here**: compress conversation from this point forward (like targeted `/compact`)
- **Never mind**: cancel

Limitations: bash command file changes are not tracked; external changes not tracked; not a replacement for git.

### Remote Control

Connect claude.ai/code or the Claude mobile app to a local Claude Code session.

**Start a session:**
- `claude remote-control` — server mode (handles multiple concurrent connections)
- `claude --remote-control` / `claude --rc` — interactive session with remote enabled
- `/remote-control` or `/rc` — from existing session

**Server mode flags:**

| Flag | Description |
| :--- | :--- |
| `--name "My Project"` | Custom session title |
| `--spawn same-dir\|worktree\|session` | How new connections create sessions |
| `--capacity <N>` | Max concurrent sessions (default 32) |
| `--sandbox` / `--no-sandbox` | Enable/disable sandboxing |

- Requires claude.ai subscription (not API keys); not available on Bedrock/Vertex/Foundry
- Claude runs locally; web/mobile is just a window into the local session
- Enable for all sessions: `/config` → Enable Remote Control for all sessions

### Scheduled tasks (session-scoped `/loop`)

Run prompts automatically on a schedule within the current session.

| Command | Behavior |
| :--- | :--- |
| `/loop 5m check the deploy` | Fixed interval with your prompt |
| `/loop check the deploy` | Dynamic interval chosen by Claude each iteration |
| `/loop` | Built-in maintenance prompt (continue work, PR triage, cleanup) |
| `/loop 15m` | Built-in maintenance prompt on fixed schedule |

- Session-scoped: tasks stop when session ends; restored on `--resume` if unexpired
- Max 50 tasks per session; 7-day expiry for recurring tasks
- Stop a loop with `Esc` (for `/loop`-created tasks)
- Set `CLAUDE_CODE_DISABLE_CRON=1` to disable the scheduler

**Underlying tools:** `CronCreate`, `CronList`, `CronDelete`

**Cron expression format:** `minute hour day-of-month month day-of-week`

### Desktop scheduled tasks

Run from the Claude Code Desktop app via **Routines → New routine → Local**.

| Option | Details |
| :--- | :--- |
| Schedule presets | Manual, Hourly, Daily, Weekdays, Weekly |
| Minimum interval | 1 minute |
| Catch-up runs | One run on wake for most recently missed time (up to 7 days back) |
| Worktree option | Give each run its own isolated git worktree |

Tasks only run while the Desktop app is open and the computer is awake.

### Routines (cloud-scheduled)

Saved Claude Code configurations that run on Anthropic-managed cloud infrastructure.

| Trigger type | How it fires |
| :--- | :--- |
| **Schedule** | Recurring cadence (hourly/daily/weekdays/weekly) or one-off timestamp |
| **API** | HTTP POST to per-routine endpoint with bearer token |
| **GitHub** | Repository events (pull_request, release) |

Create at [claude.ai/code/routines](https://claude.ai/code/routines) or with `/schedule` in CLI.

- Minimum schedule interval: 1 hour
- Runs autonomously (no permission prompts)
- Branches pushed by routines are `claude/`-prefixed by default (unless unrestricted pushes enabled)
- API trigger: `POST` to `/v1/claude_code/routines/<id>/fire` with `Authorization: Bearer <token>`

**Compare scheduling options:**

| | Cloud (Routines) | Desktop | /loop |
| :--- | :--- | :--- | :--- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Access to local files | No | Yes | Yes |
| Minimum interval | 1 hour | 1 minute | 1 minute |

### Channels

MCP servers that push events into a running Claude Code session. Supported: Telegram, Discord, iMessage, fakechat (demo).

```bash
# Start with a channel enabled
claude --channels plugin:telegram@claude-plugins-official
```

**Enterprise controls:**
- `channelsEnabled`: master switch (off by default for Team/Enterprise)
- `allowedChannelPlugins`: restrict which plugins can register

**Build a custom channel:**
1. Declare `capabilities: { experimental: { 'claude/channel': {} } }` in MCP server
2. Emit `notifications/claude/channel` events with `content` (string) and optional `meta` (key-value attributes)
3. Optional: expose a reply tool for two-way channels
4. Optional: declare `claude/channel/permission: {}` to relay permission prompts remotely

### Voice dictation

Speak prompts instead of typing. Requires claude.ai account (not API key/Bedrock/Vertex/Foundry).

| Command | Effect |
| :--- | :--- |
| `/voice` | Toggle on/off (keeps current mode) |
| `/voice hold` | Enable hold-to-record mode (default) |
| `/voice tap` | Enable tap-to-record-and-send mode |
| `/voice off` | Disable |

- Hold mode: hold `Space` to record, release to insert transcript
- Tap mode: tap `Space` to start, tap again to stop and auto-send (if 3+ words)
- Language follows the `language` setting; defaults to English
- Rebind via `voice:pushToTalk` in `~/.claude/keybindings.json`
- Set `"autoSubmit": true` in voice settings to auto-send on key release (hold mode)

### Fullscreen rendering

Alternative rendering path using the terminal's alternate screen buffer.

- Enable: `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1`
- Disable: `/tui default`
- Features: flicker-free, flat memory in long sessions, mouse support, stable input box

**Key controls:**

| Action | Keys |
| :--- | :--- |
| Scroll up/down | `PgUp` / `PgDn` |
| Jump to start | `Ctrl+Home` |
| Jump to bottom | `Ctrl+End` |
| Toggle transcript mode | `Ctrl+o` |
| Search in transcript | `/` (in transcript mode) |
| Write to terminal scrollback | `[` (in transcript mode) |
| Clear conversation | `Ctrl+L` twice |

Set `CLAUDE_CODE_DISABLE_MOUSE=1` to disable mouse capture while keeping flicker-free rendering.

### Context window explorer

Interactive simulation at [context-window doc](references/claude-code-context-window.md) showing what loads into context and when.

**What survives `/compact`:**

| Mechanism | After compaction |
| :--- | :--- |
| System prompt and output style | Unchanged |
| Project-root CLAUDE.md and unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | Lost until matching file re-read |
| Nested CLAUDE.md in subdirectories | Lost until file in that dir re-read |
| Invoked skill bodies | Re-injected (capped at 5K tokens/skill, 25K total) |
| Hooks | Not applicable (run as code, not context) |

Run `/context` for a live breakdown of your actual context usage. Run `/memory` to check which CLAUDE.md and memory files loaded at startup.

## Full Documentation

For the complete official documentation, see the reference files:

- [Features Overview](references/claude-code-features-overview.md) — when to use CLAUDE.md vs skills vs subagents vs agent teams vs MCP vs hooks vs plugins; feature comparison tables; context cost by feature; how features layer
- [Fast Mode](references/claude-code-fast-mode.md) — toggling fast mode, pricing, when to use, requirements, per-session opt-in, rate limit fallback
- [Model Configuration](references/claude-code-model-config.md) — model aliases, setting your model, restricting model selection, opusplan, effort levels, extended context (1M), environment variables for model overrides, third-party deployment pinning
- [Output Styles](references/claude-code-output-styles.md) — built-in styles (Default, Explanatory, Learning), custom output styles, frontmatter fields, comparison with CLAUDE.md and agents
- [Status Line](references/claude-code-statusline.md) — configuration, available JSON data fields, examples (context bar, git status, cost tracking, multi-line, rate limits, caching), troubleshooting
- [Checkpointing](references/claude-code-checkpointing.md) — how checkpoints work, rewind menu actions, restore vs summarize, limitations
- [Remote Control](references/claude-code-remote-control.md) — server mode, interactive mode, connecting from another device, mobile push notifications, comparison table vs web/Slack/channels, troubleshooting
- [Scheduled Tasks (/loop)](references/claude-code-scheduled-tasks.md) — /loop usage, fixed vs dynamic intervals, built-in maintenance prompt, loop.md customization, one-time reminders, cron expression reference
- [Desktop Scheduled Tasks](references/claude-code-desktop-scheduled-tasks.md) — creating tasks, schedule options, permissions, managing and editing tasks
- [Routines](references/claude-code-routines.md) — schedule/API/GitHub triggers, creating from web/CLI, managing runs, connector and environment configuration, usage limits
- [Channels](references/claude-code-channels.md) — Telegram/Discord/iMessage setup, fakechat quickstart, security and sender allowlists, enterprise controls
- [Channels Reference](references/claude-code-channels-reference.md) — building custom channels, notification format, reply tools, sender gating, permission relay, packaging as a plugin
- [Voice Dictation](references/claude-code-voice-dictation.md) — hold mode, tap mode, language settings, rebinding the dictation key, troubleshooting
- [Fullscreen Rendering](references/claude-code-fullscreen.md) — enabling, mouse support, scrolling, transcript mode, tmux usage, keeping native text selection
- [Context Window Explorer](references/claude-code-context-window.md) — interactive timeline of what loads into context; compaction survival table

## Sources

- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled Tasks (/loop): https://code.claude.com/docs/en/scheduled-tasks.md
- Desktop Scheduled Tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Routines: https://code.claude.com/docs/en/routines.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels Reference: https://code.claude.com/docs/en/channels-reference.md
- Voice Dictation: https://code.claude.com/docs/en/voice-dictation.md
- Fullscreen Rendering: https://code.claude.com/docs/en/fullscreen.md
- Context Window Explorer: https://code.claude.com/docs/en/context-window.md
