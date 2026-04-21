---
name: features-doc
description: Claude Code features — fast mode, model config, effort levels, status line, checkpointing, remote control, scheduled tasks, routines, channels, voice dictation, fullscreen rendering, output styles, context window, and the extension layer overview.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features beyond core CLI and settings.

## Quick Reference

### Extension layer overview

| Feature | What it does | When to use it |
|---------|-------------|----------------|
| **CLAUDE.md** | Persistent context every session | "Always do X" rules, project conventions |
| **Skill** | Instructions/knowledge/workflows Claude can use | Reference docs, repeatable tasks |
| **Subagent** | Isolated worker with own context | Context isolation, parallel tasks |
| **Agent teams** | Coordinated independent sessions | Parallel research, competing hypotheses |
| **MCP** | Connect to external services | Database queries, Slack, browser control |
| **Hook** | Deterministic script on events | Automation with no LLM involved |

Feature layering when same name exists at multiple levels: managed > user > project (skills); local > project > user (MCP); all hooks merge.

---

### Fast mode (`/fast`)

| Item | Value |
|------|-------|
| Toggle | `/fast` or set `"fastMode": true` in settings |
| Model | Opus 4.6 only (switches to Opus 4.6 if on another model) |
| Speed | ~2.5× faster |
| Pricing | $30/$150 per MTok input/output (extra usage, not subscription) |
| Indicator | `↯` icon next to prompt |
| Rate limit fallback | Auto-falls back to standard Opus 4.6; `↯` turns gray |
| Per-session opt-in | `"fastModePerSessionOptIn": true` in managed settings |
| Disable org-wide | `CLAUDE_CODE_DISABLE_FAST_MODE=1` |
| Not available on | Bedrock, Vertex AI, Foundry |

Enabling mid-conversation re-charges full uncached input tokens at fast mode pricing — enable at session start for best cost efficiency.

---

### Model configuration

**Model aliases**

| Alias | Behavior |
|-------|----------|
| `default` | Clears override, reverts to recommended for account type |
| `best` / `opus` | Most capable; Opus 4.7 on Anthropic API |
| `sonnet` | Latest Sonnet; Sonnet 4.6 on Anthropic API |
| `haiku` | Fast, efficient Haiku |
| `opus[1m]` / `sonnet[1m]` | 1M token context window |
| `opusplan` | Opus during plan mode, Sonnet during execution |

**Default model by plan**

| Plan | Default |
|------|---------|
| Max, Team Premium | Opus 4.7 |
| Pro, Team Standard, Enterprise, API | Sonnet 4.6 |
| Bedrock, Vertex, Foundry | Sonnet 4.5 |

**Setting priority:** session `/model` → `--model` flag → `ANTHROPIC_MODEL` → settings file

**Effort levels** (Opus 4.7: `low`/`medium`/`high`/`xhigh`/`max`; Opus 4.6 & Sonnet 4.6: `low`/`medium`/`high`/`max`)

| Level | When to use |
|-------|-------------|
| `low` | Latency-sensitive, not intelligence-sensitive |
| `medium` | Cost-sensitive, can trade off some intelligence |
| `high` | Balances cost and intelligence |
| `xhigh` | Best for most coding tasks (Opus 4.7 default) |
| `max` | Deepest reasoning; current session only |

Set via: `/effort`, `/model` slider, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL`, `effortLevel` setting, or skill/subagent frontmatter.

**Extended context (1M tokens):** Max/Team/Enterprise: Opus included, Sonnet requires extra usage. Disable: `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

**Prompt caching env vars:** `DISABLE_PROMPT_CACHING`, `DISABLE_PROMPT_CACHING_HAIKU`, `DISABLE_PROMPT_CACHING_SONNET`, `DISABLE_PROMPT_CACHING_OPUS`

**Key model env vars:**
- `ANTHROPIC_DEFAULT_OPUS_MODEL` / `ANTHROPIC_DEFAULT_SONNET_MODEL` / `ANTHROPIC_DEFAULT_HAIKU_MODEL`
- `CLAUDE_CODE_SUBAGENT_MODEL`
- `ANTHROPIC_CUSTOM_MODEL_OPTION` (+ `_NAME`, `_DESCRIPTION`, `_SUPPORTED_CAPABILITIES`)
- `modelOverrides` in settings: maps Anthropic model IDs → provider-specific IDs

---

### Status line

Configure via `statusLine` in settings:

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

**Key JSON fields available on stdin:**

| Field | Description |
|-------|-------------|
| `model.id`, `model.display_name` | Current model |
| `workspace.current_dir`, `workspace.project_dir` | Directories |
| `workspace.added_dirs` | Extra dirs from `/add-dir` |
| `workspace.git_worktree` | Linked worktree name |
| `cost.total_cost_usd` | Estimated session cost |
| `cost.total_duration_ms` | Wall-clock time (ms) |
| `context_window.used_percentage` | % of context used |
| `context_window.context_window_size` | 200000 or 1000000 |
| `rate_limits.five_hour.used_percentage` | 5h rate limit % (Pro/Max) |
| `rate_limits.seven_day.used_percentage` | 7-day rate limit % (Pro/Max) |
| `session_id`, `session_name` | Session identifiers |
| `vim.mode` | `NORMAL` or `INSERT` (when vim mode on) |
| `worktree.name`, `worktree.branch` | Worktree info |

- Updates: after each assistant message, on permission mode change, on vim mode toggle (debounced 300ms)
- Use `/statusline <description>` to auto-generate a script
- `subagentStatusLine` setting for custom subagent row rendering
- Set `FORCE_HYPERLINK=1` for OSC 8 clickable links in non-detected terminals

---

### Checkpointing

- Automatic: tracks file edits before each tool use; every user prompt creates a checkpoint
- Persists 30 days (configurable); survives session resume
- Open rewind menu: press `Esc` twice or run `/rewind`

**Rewind actions:**

| Action | Effect |
|--------|--------|
| Restore code and conversation | Revert both to selected point |
| Restore conversation | Rewind messages, keep current code |
| Restore code | Revert files, keep conversation |
| Summarize from here | Compress selected message onward, free context |

- Does NOT track bash command file changes or external edits
- "Summarize from here" = targeted `/compact`; files on disk unchanged

---

### Remote Control

Start: `claude remote-control` (server mode), `claude --remote-control` (interactive), or `/remote-control` in session / VS Code.

**Server mode flags:**

| Flag | Description |
|------|-------------|
| `--name "My Project"` | Custom session title |
| `--spawn same-dir\|worktree\|session` | Session creation mode |
| `--capacity <N>` | Max concurrent sessions (default 32) |
| `--sandbox` / `--no-sandbox` | Filesystem isolation |
| `--verbose` | Detailed logs |

- Connects to `claude.ai/code` and Claude iOS/Android app
- Runs locally — filesystem, MCP, tools stay available
- Session title priority: `--name` → `/rename` → last message → hostname-based auto name
- Enable globally: `/config` → Enable Remote Control for all sessions
- Mobile push notifications: `/config` → Push when Claude decides (requires Claude app signed in)
- Not available on Bedrock/Vertex/Foundry; requires claude.ai OAuth

---

### Scheduled tasks (`/loop`, session-scoped)

| `/loop` form | Behavior |
|---|---|
| `/loop 5m check deploy` | Fixed-interval cron |
| `/loop check deploy` | Claude picks interval dynamically |
| `/loop` | Built-in maintenance prompt (PR, CI, cleanup) |

**Underlying tools:** `CronCreate`, `CronList`, `CronDelete`
- Session-scoped; up to 50 tasks; 7-day expiry on recurring tasks
- Cron format: `minute hour day-of-month month day-of-week`
- Jitter: recurring tasks up to 10% of period late (max 15m); one-shot at `:00`/`:30` up to 90s early
- Customize bare `/loop`: create `.claude/loop.md` or `~/.claude/loop.md`
- Disable: `CLAUDE_CODE_DISABLE_CRON=1`
- On resume (`--resume`/`--continue`): unexpired tasks are restored

---

### Routines (cloud-scheduled)

Cloud-executed sessions with three trigger types: **Schedule** (min 1 hour), **API** (`POST /fire` with bearer token), **GitHub** (PR or release events with filters).

| Scheduling | Cloud (Routines) | Desktop | /loop |
|------------|-----------------|---------|-------|
| Runs on | Anthropic cloud | Local machine | Local machine |
| Needs machine on | No | Yes | Yes |
| Needs open session | No | No | Yes |
| Min interval | 1 hour | 1 minute | 1 minute |
| Local file access | No (fresh clone) | Yes | Yes |

- Create: `claude.ai/code/routines` web UI or `/schedule` CLI
- Branches: Claude pushes to `claude/`-prefixed branches by default
- API fire: `POST https://api.anthropic.com/v1/claude_code/routines/<id>/fire` with `anthropic-beta: experimental-cc-routine-2026-04-01`
- GitHub filter fields: Author, Title, Body, Base/Head branch, Labels, Is draft, Is merged
- Plans: Pro, Max, Team, Enterprise with Claude Code on the web enabled

---

### Desktop scheduled tasks

- Create: Desktop app → Schedule → New task → New local task
- Frequency: Manual, Hourly, Daily, Weekdays, Weekly (or describe custom intervals to Claude)
- Missed runs: on wake, runs one catch-up for the most recently missed time (last 7 days)
- Stagger: up to 10 minutes offset per task (deterministic)
- Keep computer awake: Settings → Desktop app → General → Keep computer awake
- Worktree toggle: each run in own git worktree

---

### Channels (push events into sessions)

Channels push messages from external platforms (Telegram, Discord, iMessage) into a running session.

Install as plugin, then start with `--channels`:
```bash
claude --channels plugin:telegram@claude-plugins-official
```

- Requires claude.ai login; not available on API key / Bedrock / Vertex / Foundry
- Events arrive only while session is open
- Sender security: pairing codes + allowlist policy
- Team/Enterprise: admin must enable in Claude Code admin settings
- Build custom channel: see channels-reference

---

### Voice dictation

Enable: `/voice` (toggles on/off) or `"voiceEnabled": true` in settings.

- Push-to-talk: hold `Space` (brief warmup) — rebind via keybindings for instant activation
- Transcription: live preview (dimmed) while speaking, finalized on release
- Language: uses `language` setting; defaults to English
- Requires: claude.ai account (not API key); local microphone; not available over SSH or in web sessions
- Linux fallback: `arecord` (ALSA) or `rec` (SoX)
- Project/branch names added as recognition hints automatically

---

### Fullscreen rendering

Enable: `/tui fullscreen` (saves `tui` setting) or `CLAUDE_CODE_NO_FLICKER=1`

**What changes:**
- Input box fixed at bottom; only visible messages in render tree (flat memory)
- Lives in alternate screen buffer (like vim/htop)
- Native terminal scroll search replaced by `Ctrl+o` transcript mode then `/`

**Mouse actions:**
- Click input: position cursor
- Click collapsed tool result: expand/collapse
- Click URL/file path: open
- Click+drag: select text (auto-copies to clipboard on release)
- Scroll wheel: navigate conversation

**Scroll shortcuts:**

| Key | Action |
|-----|--------|
| `PgUp`/`PgDn` | Half screen |
| `Ctrl+Home` | Jump to start |
| `Ctrl+End` | Jump to latest, resume auto-follow |
| `Ctrl+o` | Toggle transcript mode |

- Search in transcript mode: `/` to find, `n`/`N` next/prev
- Disable mouse capture only: `CLAUDE_CODE_DISABLE_MOUSE=1`
- Scroll speed: `CLAUDE_CODE_SCROLL_SPEED=3` (1–20)
- Disable: `/tui default`

---

### Output styles

| Style | Description |
|-------|-------------|
| Default | Standard software engineer mode |
| Explanatory | Adds "Insights" between coding tasks |
| Learning | Insights + `TODO(human)` markers for you to implement |

Change: `/config` → Output style, or set `"outputStyle": "Explanatory"` in settings (takes effect next session).

Custom style: Markdown file with frontmatter (`name`, `description`, `keep-coding-instructions: true/false`) + instructions appended to system prompt.

---

### Context window

What loads before you type anything: system prompt → auto memory → environment info → MCP tool names (deferred) → skill descriptions → CLAUDE.md files.

**What survives `/compact`:**

| Mechanism | After compaction |
|-----------|-----------------|
| System prompt + output style | Unchanged |
| Project-root CLAUDE.md + unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Path-scoped rules (`paths:`) | Lost until matching file is read again |
| Nested CLAUDE.md in subdirectories | Lost until file in subdir is read |
| Invoked skill bodies | Re-injected (cap: 5,000 tokens/skill, 25,000 total; oldest dropped) |
| Hooks | N/A (run as code, not context) |
| Skill descriptions listing | NOT re-injected; only invoked skills preserved |

Check live usage: `/context`; check loaded memory: `/memory`.

---

## Full Documentation

- [claude-code-features-overview.md](references/claude-code-features-overview.md) — Extension layer: when to use CLAUDE.md vs skills vs subagents vs MCP vs hooks vs plugins
- [claude-code-fast-mode.md](references/claude-code-fast-mode.md) — Fast mode: 2.5× faster Opus 4.6 via `/fast`
- [claude-code-model-config.md](references/claude-code-model-config.md) — Model aliases, effort levels, 1M context, env vars, `modelOverrides`
- [claude-code-statusline.md](references/claude-code-statusline.md) — Custom status line: JSON data fields, script examples, subagent status line
- [claude-code-checkpointing.md](references/claude-code-checkpointing.md) — Checkpoint rewind, summarize-from-here, limitations
- [claude-code-remote-control.md](references/claude-code-remote-control.md) — Remote Control: continue local sessions from phone/browser
- [claude-code-scheduled-tasks.md](references/claude-code-scheduled-tasks.md) — `/loop`, CronCreate/List/Delete, loop.md customization
- [claude-code-routines.md](references/claude-code-routines.md) — Cloud-based routines: schedule, API trigger, GitHub trigger
- [claude-code-desktop-scheduled-tasks.md](references/claude-code-desktop-scheduled-tasks.md) — Desktop local scheduled tasks, frequency options, missed run behavior
- [claude-code-channels.md](references/claude-code-channels.md) — Channels: push Telegram/Discord/iMessage events into running sessions
- [claude-code-channels-reference.md](references/claude-code-channels-reference.md) — Channels developer reference: build custom channel plugins
- [claude-code-voice-dictation.md](references/claude-code-voice-dictation.md) — Voice dictation: push-to-talk `/voice` command
- [claude-code-output-styles.md](references/claude-code-output-styles.md) — Output styles: Default, Explanatory, Learning, custom styles
- [claude-code-context-window.md](references/claude-code-context-window.md) — Interactive context window visualization and compaction survival table
- [claude-code-fullscreen.md](references/claude-code-fullscreen.md) — Fullscreen rendering: `/tui fullscreen`, mouse support, transcript mode

## Sources

- Features overview: https://code.claude.com/docs/en/features-overview.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model config: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Context window: https://code.claude.com/docs/en/context-window.md
- Fullscreen: https://code.claude.com/docs/en/fullscreen.md
- Routines: https://code.claude.com/docs/en/routines.md
