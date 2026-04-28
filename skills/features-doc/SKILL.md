---
name: features-doc
description: Complete official documentation for Claude Code features — extension overview (CLAUDE.md vs Skills vs MCP vs Hooks), checkpointing and rewind, context window loading and costs, fast mode, model configuration and aliases, output styles, status line customization, remote control, scheduled tasks (/loop), desktop scheduled tasks, cloud routines, channels (Telegram/Discord/iMessage), channels reference for building custom channel servers, fullscreen rendering, and voice dictation.
user-invocable: false
---

# Claude Code Features Documentation

This skill provides the complete official documentation for Claude Code features and extensions.

## Quick Reference

### Extension types and when to use them

| Feature | What it does | When to use it |
| :--- | :--- | :--- |
| **CLAUDE.md** | Persistent context, every session | Project conventions, "always do X" rules |
| **Skills** | Reusable knowledge and workflows | Reference material, repeatable tasks, `/name` commands |
| **MCP** | Connect to external services | External data or actions (databases, Slack, browsers) |
| **Subagents** | Isolated execution context | Context isolation, parallel tasks, specialized workers |
| **Agent teams** | Multiple independent sessions | Parallel research, competing hypotheses |
| **Hooks** | Script/HTTP/prompt on lifecycle events | Automation that must run on every matching event |
| **Plugins** | Package and distribute features | Reuse across repos, share with others |

### Choosing between similar features

| Question | Answer |
| :--- | :--- |
| Skill vs CLAUDE.md | Always-on → CLAUDE.md; on-demand or invocable → Skill |
| Skill vs Subagent | Reusable content → Skill; context isolation → Subagent |
| Hook vs Skill | Must fire deterministically → Hook; needs reasoning → Skill |
| MCP vs Skill | External service connection → MCP; how to use it → Skill |
| Remote Control vs Claude Code on the web | In-progress local work → Remote Control; fresh task → Web |

### Context costs by feature

| Feature | When it loads | Context cost |
| :--- | :--- | :--- |
| CLAUDE.md | Session start | Every request |
| Skills | Start (descriptions) + when used (full content) | Low; zero with `disable-model-invocation: true` |
| MCP servers | Session start (names); schemas on demand | Low until a tool is used |
| Subagents | When spawned | Isolated from main session |
| Hooks | On trigger (runs externally) | Zero unless hook returns output |

### What survives /compact

| Mechanism | After compaction |
| :--- | :--- |
| System prompt and output style | Unchanged |
| Project-root CLAUDE.md and unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | Lost until a matching file is read again |
| Nested CLAUDE.md in subdirectories | Lost until a file in that subdirectory is read again |
| Invoked skill bodies | Re-injected (capped at 5,000 tokens per skill, 25,000 total) |

### Checkpointing and rewind

- Automatically captures file state before each edit (tracks file editing tools only; Bash commands not tracked).
- Press `Esc` twice or use `/rewind` to open the rewind menu.
- Actions: **Restore code and conversation**, **Restore conversation**, **Restore code**, **Summarize from here**, **Never mind**.
- Checkpoints persist across sessions for 30 days (configurable).
- Not a replacement for git; use git for permanent history.

### Fast mode

- Toggles with `/fast` or `"fastMode": true` in settings.
- Applies to Opus 4.6 only — 2.5x faster at higher per-token cost ($30/$150 MTok input/output).
- Not available on Bedrock, Vertex AI, or Azure Foundry.
- Requires extra usage enabled; falls back to standard Opus 4.6 on rate limit.
- Admin setting `fastModePerSessionOptIn: true` resets fast mode each session.

### Model aliases

| Alias | Behavior |
| :--- | :--- |
| `default` | Clears override; reverts to recommended for your account |
| `best` | Most capable available (currently `opus`) |
| `sonnet` | Latest Sonnet (Sonnet 4.6 on Anthropic API) |
| `opus` | Latest Opus (Opus 4.7 on Anthropic API) |
| `haiku` | Fast, efficient Haiku |
| `sonnet[1m]` | Sonnet with 1M token context |
| `opus[1m]` | Opus with 1M token context |
| `opusplan` | Opus during plan mode, Sonnet for execution |

Set with `/model <alias>`, `--model <alias>`, `ANTHROPIC_MODEL=<alias>`, or `model` in settings (priority in that order).

### Effort levels (Opus 4.7, Opus 4.6, Sonnet 4.6)

| Level | When to use |
| :--- | :--- |
| `low` | Short, latency-sensitive, non-intelligence-sensitive tasks |
| `medium` | Cost-sensitive work with some quality trade-off |
| `high` | Balances token usage and intelligence (minimum for complex work) |
| `xhigh` | Best for most coding and agentic tasks; default on Opus 4.7 |
| `max` | Deepest reasoning; session-only; test before adopting broadly |

Set with `/effort <level>`, `--effort <level>`, `CLAUDE_CODE_EFFORT_LEVEL`, or `effortLevel` in settings.

### Output styles

- **Default**: software engineering tasks.
- **Explanatory**: adds "Insights" explaining implementation choices.
- **Learning**: collaborative mode with `TODO(human)` markers for you to implement.
- Custom: `.md` file with frontmatter (`name`, `description`, `keep-coding-instructions`) placed in `~/.claude/output-styles` or `.claude/output-styles`.
- Set via `/config` → Output style, or `outputStyle` in settings. Takes effect next session.

### Status line

Configure via `statusLine` in settings or generate with `/statusline <description>`:

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

Key JSON fields available to the script via stdin: `model.display_name`, `workspace.current_dir`, `context_window.used_percentage`, `cost.total_cost_usd`, `cost.total_duration_ms`, `rate_limits.five_hour.used_percentage`, `rate_limits.seven_day.used_percentage`, `session_id`, `effort.level`, `vim.mode`, `worktree.*`.

Use `session_id` (not `$$`) as the cache key for slow operations like `git status`.

### Remote Control

Start a remote session to continue local work from phone/browser:

| Command | Mode |
| :--- | :--- |
| `claude remote-control` | Server mode (waits for connections) |
| `claude --remote-control` | Interactive session with remote enabled |
| `/remote-control` | Enable from within an existing session |

- Requires claude.ai login; not available with API key or third-party providers.
- On Team/Enterprise, admin must enable the Remote Control toggle in admin settings.
- Push notifications: install Claude mobile app, sign in, enable "Push when Claude decides" in `/config`.

### Scheduling comparison

| | Cloud (Routines) | Desktop scheduled tasks | /loop (session) |
| :--- | :--- | :--- | :--- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Persistent | Yes | Yes | Restored on `--resume` if unexpired |
| Access to local files | No (fresh clone) | Yes | Yes |
| Min interval | 1 hour | 1 minute | 1 minute |

### /loop (session-scoped scheduling)

| Usage | Behavior |
| :--- | :--- |
| `/loop 5m <prompt>` | Fixed interval |
| `/loop <prompt>` | Claude chooses interval dynamically |
| `/loop` | Built-in maintenance prompt (continue work, tend PR, cleanup) |

- Session-scoped; tasks expire after 7 days.
- Stop a loop with `Esc`; manage with natural language ("list my scheduled tasks").
- Disable entirely with `CLAUDE_CODE_DISABLE_CRON=1`.

### Desktop scheduled tasks

- Create via Routines page in Desktop app → New routine → Local.
- Fields: Name, Description, Instructions (includes permission mode and model pickers), Schedule, Folder.
- Schedules: Manual, Hourly, Daily, Weekdays, Weekly; ask Claude for custom intervals.
- Only runs while Desktop app is open and computer is awake. Enable "Keep computer awake" in Settings.
- Missed runs: one catch-up run on wake (most recently missed only, within 7 days).
- Task files stored at `~/.claude/scheduled-tasks/<task-name>/SKILL.md`.

### Cloud Routines

- Triggers: **Schedule** (hourly/daily/weekdays/weekly/one-off), **API** (HTTP POST with bearer token), **GitHub** (pull_request, release events).
- Create at claude.ai/code/routines or with `/schedule <description>` in CLI.
- Runs autonomously, no permission prompts. Scope repos, connectors, and environments to what the routine needs.
- API trigger endpoint: `POST .../routines/<id>/fire` with `Authorization: Bearer <token>` and optional `{"text": "..."}` body.
- GitHub trigger: requires Claude GitHub App installed on repo. Supports `pull_request.*` and `release.*` events with filters.

### Channels (Telegram, Discord, iMessage, fakechat)

- Research preview; requires Claude Code v2.1.80+, claude.ai login.
- Push events from chat platforms or webhooks into a running local session.
- Install via `/plugin install <name>@claude-plugins-official`, then restart with `--channels plugin:<name>@claude-plugins-official`.
- Quickstart: `/plugin install fakechat@claude-plugins-official`, then `claude --channels plugin:fakechat@claude-plugins-official`.
- Security: sender allowlist required; pair your account with the bot before use.
- Team/Enterprise: admin must set `channelsEnabled: true`; optionally restrict with `allowedChannelPlugins`.

### Building custom channels

A channel is an MCP server that emits `notifications/claude/channel` events:

```ts
// Server constructor requires:
capabilities: { experimental: { 'claude/channel': {} } }
// Push events with:
mcp.notification({ method: 'notifications/claude/channel', params: { content: '...', meta: { key: 'val' } } })
```

- One-way channel: omit `capabilities.tools`. Two-way: add `tools: {}` and register a `reply` tool.
- Permission relay: add `'claude/channel/permission': {}` to capabilities; handle `notifications/claude/channel/permission_request` and emit `notifications/claude/channel/permission` verdict.
- Gate inbound on sender identity (not chat room ID) before emitting.
- Test with `--dangerously-load-development-channels server:<name>`.

### Fullscreen rendering

- Enable with `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1`. Disable with `/tui default`.
- Eliminates flicker, flat memory in long sessions, adds mouse support.
- Draws on alternate screen buffer (like vim/htop); conversation not in terminal scrollback.
- Search: `Ctrl+o` for transcript mode, then `/` to search or `[` to write to scrollback.
- Scroll shortcuts: `PgUp`/`PgDn`, `Ctrl+Home`/`Ctrl+End`, mouse wheel.
- Disable mouse capture while keeping rendering: `CLAUDE_CODE_DISABLE_MOUSE=1`.

### Voice dictation

- Enable with `/voice` (hold mode) or `/voice tap` (tap mode). Requires claude.ai account.
- Hold mode: hold `Space` to record, release to insert transcript. Brief warmup before recording starts.
- Tap mode: tap `Space` to start, tap again to send (auto-submits if transcript is 3+ words; prompt must be empty for first tap).
- Rebind the key via `~/.claude/keybindings.json` (`voice:pushToTalk` in `Chat` context).
- Language follows `language` setting; falls back to English if not in supported list.
- Not available on Bedrock, Vertex AI, Foundry, or in remote/SSH environments.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code](references/claude-code-features-overview.md) — overview of all extension types, when to use each, context costs, and how features layer and combine
- [Explore the context window](references/claude-code-context-window.md) — interactive simulation of context loading order, what survives compaction, and checking your own session
- [Checkpointing](references/claude-code-checkpointing.md) — automatic tracking, rewind menu, restore vs summarize, limitations
- [Speed up responses with fast mode](references/claude-code-fast-mode.md) — toggling fast mode, cost tradeoffs, rate limits, admin controls
- [Model configuration](references/claude-code-model-config.md) — model aliases, effort levels, extended context (1M), setting and restricting models, third-party provider pinning
- [Output styles](references/claude-code-output-styles.md) — built-in styles, creating custom styles, frontmatter reference
- [Customize your status line](references/claude-code-statusline.md) — setup, available JSON fields, examples (git status, costs, progress bar, clickable links, caching)
- [Continue local sessions with Remote Control](references/claude-code-remote-control.md) — start modes, connecting from another device, push notifications, troubleshooting
- [Run prompts on a schedule](references/claude-code-scheduled-tasks.md) — /loop, fixed vs dynamic intervals, one-time reminders, cron reference, session-scoped limits
- [Schedule recurring tasks in Claude Code Desktop](references/claude-code-desktop-scheduled-tasks.md) — create, schedule options, missed runs, permissions, managing tasks
- [Automate work with routines](references/claude-code-routines.md) — schedule/API/GitHub triggers, create from web or CLI, managing runs, usage limits
- [Push events with channels](references/claude-code-channels.md) — Telegram/Discord/iMessage/fakechat setup, security, enterprise controls, comparison with other remote features
- [Channels reference](references/claude-code-channels-reference.md) — building custom channel servers, notification format, reply tools, sender gating, permission relay
- [Fullscreen rendering](references/claude-code-fullscreen.md) — enabling, mouse support, scrolling, search, tmux notes
- [Voice dictation](references/claude-code-voice-dictation.md) — hold vs tap mode, language settings, rebinding the key, troubleshooting

## Sources

- Extend Claude Code: https://code.claude.com/docs/en/features-overview.md
- Explore the context window: https://code.claude.com/docs/en/context-window.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Speed up responses with fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Customize your status line: https://code.claude.com/docs/en/statusline.md
- Continue local sessions with Remote Control: https://code.claude.com/docs/en/remote-control.md
- Run prompts on a schedule: https://code.claude.com/docs/en/scheduled-tasks.md
- Schedule recurring tasks in Claude Code Desktop: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Automate work with routines: https://code.claude.com/docs/en/routines.md
- Push events with channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
