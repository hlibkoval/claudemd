---
name: features-doc
description: Complete official documentation for Claude Code features — features overview (when to use CLAUDE.md vs skills vs hooks vs MCP vs subagents), fast mode, model configuration, output styles, status line, checkpointing, remote control, scheduled tasks, voice dictation, channels, routines, context window, and fullscreen rendering.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features and configuration options.

## Quick Reference

### Extension Feature Comparison

| Feature | What it does | When to use it |
| :--- | :--- | :--- |
| **CLAUDE.md** | Persistent context loaded every conversation | Project conventions, "always do X" rules |
| **Skill** | Instructions, knowledge, and workflows | Reusable content, reference docs, repeatable tasks |
| **Subagent** | Isolated execution that returns summarized results | Context isolation, parallel tasks, research |
| **Agent teams** | Coordinate multiple independent sessions | Parallel work needing discussion and collaboration |
| **MCP** | Connect to external services | External data or actions (databases, Slack, browser) |
| **Hook** | Script/HTTP/prompt/subagent triggered by lifecycle events | Automation that must run every time |
| **Plugin** | Package and distribute skills, hooks, MCP servers | Reuse setup across repos or distribute to others |

### Context Cost by Feature

| Feature | When it loads | Context cost |
| :--- | :--- | :--- |
| **CLAUDE.md** | Session start | Every request (full content) |
| **Skills** | Start + on use | Low (descriptions at start, full content when used) |
| **MCP servers** | Session start | Low (tool names deferred until needed) |
| **Subagents** | When spawned | Isolated from main session |
| **Hooks** | On trigger | Zero unless hook returns output |

### Layering: When the Same Feature Exists at Multiple Levels

| Feature | Behavior |
| :--- | :--- |
| **CLAUDE.md** | Additive — all levels contribute content simultaneously |
| **Skills / Subagents** | Override by name — one definition wins by priority |
| **MCP servers** | Override by name — local > project > user |
| **Hooks** | Merge — all registered hooks fire for matching events |

---

### Fast Mode

| Setting | Value |
| :--- | :--- |
| Toggle | `/fast` (or `"fastMode": true` in settings) |
| Model | Opus 4.6 only (not available on Opus 4.7 or Bedrock/Vertex/Foundry) |
| Speed | 2.5x faster than standard Opus 4.6 |
| Pricing | $30/$150 MTok (input/output) — billed to extra usage |
| Indicator | `↯` icon next to prompt when active |
| Rate limit fallback | Auto-falls back to standard Opus 4.6; icon turns gray |

Per-session opt-in (admin setting): `"fastModePerSessionOptIn": true` — resets fast mode each new session.

---

### Model Configuration

**Model aliases:**

| Alias | Behavior |
| :--- | :--- |
| `default` | Clears override, reverts to recommended model for account type |
| `best` | Most capable model (currently `opus`) |
| `sonnet` | Latest Sonnet for daily coding |
| `opus` | Latest Opus for complex reasoning |
| `haiku` | Fast and efficient for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus for plan mode, switches to Sonnet for execution |

**Set model (priority order):** `/model <alias>` during session → `--model` at startup → `ANTHROPIC_MODEL` env var → `model` in settings.

**Effort levels** (Opus 4.7: `low/medium/high/xhigh/max`; Opus 4.6 + Sonnet 4.6: `low/medium/high/max`):

| Level | When to use |
| :--- | :--- |
| `low` | Short, scoped, latency-sensitive tasks |
| `medium` | Cost-sensitive work trading off some intelligence |
| `high` | Intelligence-sensitive work, or to reduce cost vs. `xhigh` |
| `xhigh` | Best results for coding and agentic tasks (default on Opus 4.7) |
| `max` | Demanding tasks; may show diminishing returns |

Set effort: `/effort <level>`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL`, or `effortLevel` in settings.

Use `ultrathink` anywhere in a prompt for one-off deep reasoning on that turn.

**Extended context (1M tokens):** On Max/Team/Enterprise, Opus is automatically upgraded. Use `sonnet[1m]`/`opus[1m]` aliases or append `[1m]` to a model name.

**Key env vars:**

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Override `opus` alias resolution |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Override `sonnet` alias resolution |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Override `haiku` alias + background tasks |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |
| `DISABLE_PROMPT_CACHING` | Set `1` to disable for all models |

---

### Output Styles

| Style | What it does |
| :--- | :--- |
| **Default** | Standard software engineering assistant |
| **Explanatory** | Adds "Insights" explaining implementation choices and patterns |
| **Learning** | Collaborative mode: shares insights and adds `TODO(human)` markers for you to implement |
| **Custom** | Any Markdown file with frontmatter placed in `~/.claude/output-styles`, `.claude/output-styles`, or via plugin |

Change style: `/config` → Output style. Saved to `.claude/settings.local.json`. Takes effect on next session.

**Custom output style frontmatter fields:**

| Field | Description |
| :--- | :--- |
| `name` | Display name |
| `description` | Shown in `/config` picker |
| `keep-coding-instructions` | Keep coding-specific system prompt parts (default: `false`) |
| `force-for-plugin` | Auto-apply when plugin is enabled (default: `false`) |

---

### Status Line

Configure at `~/.claude/settings.json` under `statusLine`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2,
    "refreshInterval": 5,
    "hideVimModeIndicator": false
  }
}
```

Use `/statusline <natural language description>` to have Claude generate and configure the script automatically.

**Key JSON fields available in stdin:**

| Field | Description |
| :--- | :--- |
| `model.display_name` | Current model name |
| `workspace.current_dir` | Current working directory |
| `context_window.used_percentage` | Percentage of context used |
| `context_window.context_window_size` | Max context (200000 or 1000000) |
| `cost.total_cost_usd` | Estimated session cost |
| `cost.total_duration_ms` | Session wall-clock time |
| `effort.level` | Current effort level |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit usage (Pro/Max) |
| `rate_limits.seven_day.used_percentage` | 7-day rate limit usage (Pro/Max) |
| `session_id` | Session identifier (use for caching) |
| `vim.mode` | Vim mode when enabled |
| `worktree.name` | Worktree name (worktree sessions only) |

---

### Checkpointing / Rewind

- Every user prompt creates a checkpoint automatically; persists across sessions for 30 days
- Press `Esc` twice or run `/rewind` to open the rewind menu

**Rewind actions:**

| Action | Effect |
| :--- | :--- |
| Restore code and conversation | Revert both to selected point |
| Restore conversation | Rewind conversation, keep current code |
| Restore code | Revert files, keep conversation |
| Summarize from here | Compress selected message forward into summary (frees context) |

**Limitations:** Only tracks file edits from Claude's file-editing tools (not bash commands or external changes). Not a replacement for git.

---

### Remote Control

Connect claude.ai/code or Claude mobile app to a local Claude Code session.

**Start a remote session:**

| Method | Command |
| :--- | :--- |
| Server mode (multi-session) | `claude remote-control` |
| Interactive session | `claude --remote-control` or `claude --rc` |
| From existing session | `/remote-control` or `/rc` |

**Server mode flags:**

| Flag | Description |
| :--- | :--- |
| `--name "..."` | Custom session title |
| `--spawn <mode>` | `same-dir` (default), `worktree`, or `session` |
| `--capacity <N>` | Max concurrent sessions (default: 32) |
| `--sandbox` | Enable filesystem/network sandboxing |

**Requirements:** claude.ai subscription (Pro/Max/Team/Enterprise); API keys not supported. Team/Enterprise requires admin to enable the Remote Control toggle.

---

### Scheduled Tasks (CLI `/loop`)

Session-scoped tasks — live in current conversation, stop on new session. Resume with `--resume` or `--continue` restores unexpired tasks.

| What you provide | Behavior |
| :--- | :--- |
| `/loop 5m check the deploy` | Fixed schedule |
| `/loop check the deploy` | Claude dynamically chooses interval |
| `/loop` | Built-in maintenance prompt (continues unfinished work, tends PR, runs cleanup) |

**Customize default prompt:** create `.claude/loop.md` (project) or `~/.claude/loop.md` (user). File content replaces the built-in maintenance prompt.

**One-time reminders:** describe in natural language — "remind me at 3pm to push the release branch"

**Scheduling comparison:**

| Option | Runs on | Requires machine on | Requires open session |
| :--- | :--- | :--- | :--- |
| Cloud (Routines) | Anthropic cloud | No | No |
| Desktop scheduled tasks | Your machine | Yes | No |
| `/loop` | Your machine | Yes | Yes |

Disable: `CLAUDE_CODE_DISABLE_CRON=1`

---

### Desktop Scheduled Tasks

Create from Desktop app: **Routines** sidebar → **New routine** → **Local**.

- Runs a fresh session at scheduled time; appears under **Scheduled** in sidebar
- Runs only while Desktop app is open and computer is awake
- Missed runs: one catch-up run on next wake (for runs missed in last 7 days)
- Each task has its own permission mode; use **Run now** to pre-approve tool permissions

**Schedule options:** Manual, Hourly, Daily (9am default), Weekdays, Weekly, or ask Claude for custom intervals.

---

### Routines (Cloud Scheduled Tasks)

Saved Claude Code configuration (prompt + repos + connectors) running on Anthropic-managed cloud infrastructure.

**Trigger types:**

| Trigger | Description |
| :--- | :--- |
| **Scheduled** | Recurring cadence or one-off at a specific time (min 1 hour) |
| **API** | HTTP POST to per-routine endpoint with bearer token |
| **GitHub** | React to PR or release events; filterable by author, title, labels, branch, draft state |

Create at `claude.ai/code/routines` or from CLI with `/schedule`.

**API trigger endpoint:**
```bash
curl -X POST https://api.anthropic.com/v1/claude_code/routines/<id>/fire \
  -H "Authorization: Bearer <token>" \
  -H "anthropic-beta: experimental-cc-routine-2026-04-01" \
  -d '{"text": "optional context"}'
```

---

### Voice Dictation

Requires claude.ai authentication (not API key/Bedrock/Vertex/Foundry). Audio processed server-side, not locally.

| Command | Effect |
| :--- | :--- |
| `/voice` | Toggle on/off (keeps current mode) |
| `/voice hold` | Enable hold-to-record mode (default) |
| `/voice tap` | Enable tap-to-record-and-send mode |
| `/voice off` | Disable |

- **Hold mode:** hold `Space` to record; release to insert transcript. Warmup delay before recording activates.
- **Tap mode:** tap `Space` to start, tap again to stop and send (auto-submits if 3+ words). No warmup.
- Set `"autoSubmit": true` in `voice` settings to auto-send on release in hold mode.
- Rebind dictation key via `voice:pushToTalk` in `~/.claude/keybindings.json`.
- Language follows `language` setting; supports 20 languages.

---

### Channels

Push events from external systems (Telegram, Discord, iMessage, webhooks) into a running Claude Code session via MCP server plugins.

**Start with channels enabled:**
```bash
claude --channels plugin:telegram@claude-plugins-official
```

**Supported channels:** Telegram, Discord, iMessage (requires Bun). Demo: `fakechat@claude-plugins-official`.

**Setup flow:** install plugin → configure token → restart with `--channels` → pair account → set `allowlist` policy.

**Enterprise controls:**

| Setting | Purpose |
| :--- | :--- |
| `channelsEnabled` | Master switch (required for Team/Enterprise) |
| `allowedChannelPlugins` | Which plugins can register (replaces Anthropic default list when set) |

**Build custom channel:** MCP server declaring `capabilities.experimental['claude/channel']: {}`. Emit `notifications/claude/channel` events with `content` + optional `meta` attributes.

---

### Fullscreen Rendering (TUI)

Flicker-free rendering on alternate screen buffer (like vim/htop). Fixes scroll jumps and memory growth in long sessions.

Enable: `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1 claude`

**What changes:**
- Input box stays fixed at bottom
- Constant memory regardless of conversation length
- Mouse support: click to position cursor, click to expand tool output, click URLs/paths, drag to select

**Key shortcuts in fullscreen mode:**

| Shortcut | Action |
| :--- | :--- |
| `PgUp` / `PgDn` | Scroll up/down half screen |
| `Ctrl+Home` / `Ctrl+End` | Jump to start / jump to bottom + resume auto-follow |
| `Ctrl+o` | Toggle transcript mode (search with `/`, write to scrollback with `[`) |
| `Ctrl+L` twice | Clear conversation |

To disable mouse capture while keeping flicker-free rendering: `CLAUDE_CODE_DISABLE_MOUSE=1`

Disable fullscreen: `/tui default` or `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1`

---

### Context Window (What Loads When)

| What loads | When | Survives `/compact` |
| :--- | :--- | :--- |
| System prompt + output style | Session start | Yes (not message history) |
| Project-root CLAUDE.md + unscoped rules | Session start | Yes (re-injected from disk) |
| Auto memory | Session start | Yes (re-injected from disk) |
| Skill descriptions | Session start | No (not re-injected after compact) |
| Path-scoped rules / nested CLAUDE.md | When matching file is read | No (reload when file read again) |
| Invoked skill bodies | When invoked | Yes (up to 5K tokens/skill, 25K total) |
| MCP tool names | Session start | Yes |
| Hooks | On trigger (external) | N/A |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code (features overview)](references/claude-code-features-overview.md) — when to use CLAUDE.md vs skills vs hooks vs MCP vs subagents, context costs, feature layering, and combination patterns
- [Fast mode](references/claude-code-fast-mode.md) — toggling fast mode, cost tradeoffs, per-session opt-in, rate limit fallback, requirements
- [Model configuration](references/claude-code-model-config.md) — model aliases, effort levels, extended context, environment variables, third-party provider pinning, prompt caching
- [Output styles](references/claude-code-output-styles.md) — built-in styles, custom style files, frontmatter reference, comparison with CLAUDE.md and agents
- [Status line](references/claude-code-statusline.md) — setup, available JSON data fields, example scripts (context bar, git status, cost tracking, multi-line, rate limits, caching), subagent status line
- [Checkpointing](references/claude-code-checkpointing.md) — automatic tracking, rewind menu actions, summarize vs restore, limitations
- [Remote Control](references/claude-code-remote-control.md) — server mode, interactive mode, connecting from another device, push notifications, security model
- [Scheduled tasks (/loop)](references/claude-code-scheduled-tasks.md) — fixed vs dynamic intervals, built-in maintenance prompt, loop.md customization, cron reference, one-time reminders
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) — creating tasks, schedule options, permissions, missed runs, managing tasks
- [Routines (cloud scheduled tasks)](references/claude-code-routines.md) — schedule/API/GitHub triggers, create from web or CLI, environments, connectors, usage limits
- [Voice dictation](references/claude-code-voice-dictation.md) — hold mode, tap mode, language settings, key rebinding, troubleshooting
- [Channels](references/claude-code-channels.md) — Telegram/Discord/iMessage setup, quickstart with fakechat, security/sender allowlists, enterprise controls
- [Channels reference](references/claude-code-channels-reference.md) — building custom channel MCP servers, notification format, reply tools, sender gating, permission relay
- [Context window explorer](references/claude-code-context-window.md) — what loads at each phase, what survives compaction, checking your session
- [Fullscreen rendering](references/claude-code-fullscreen.md) — enabling, mouse support, scrolling shortcuts, transcript mode, tmux caveats

## Sources

- Extend Claude Code (features overview): https://code.claude.com/docs/en/features-overview.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks (/loop): https://code.claude.com/docs/en/scheduled-tasks.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Routines (cloud scheduled tasks): https://code.claude.com/docs/en/routines.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Context window explorer: https://code.claude.com/docs/en/context-window.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
- Deep links: https://code.claude.com/docs/en/deep-links.md
