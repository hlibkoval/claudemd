---
name: features-doc
description: Complete official documentation for Claude Code features — checkpointing, scheduled tasks, output styles, fast mode, fullscreen TUI, voice dictation, remote control, routines, channels, model configuration, status line, and context window management.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features.

## Quick Reference

### Feature selection guide

| Goal | Feature | Context cost |
| :--- | :------- | :----------- |
| Project conventions / coding style | CLAUDE.md | Every request |
| Reusable content or tasks | Skill | Low |
| Isolation / parallel work | Subagent | Isolated window |
| External data or actions | MCP | Low until used |
| Predictable automation (no LLM) | Hook | Zero |

Layering patterns: Skill+MCP, Skill+Subagent, Hook+MCP, etc.

---

### Checkpointing

Every user prompt creates a checkpoint automatically. Checkpoints persist 30 days (configurable). Only file edits made through Claude are tracked — bash-executed changes and external edits are not.

**Access:** `Esc`+`Esc` or `/rewind`

**Rewind actions:**

| Action | Effect |
| :----- | :----- |
| Restore code + conversation | Full rollback |
| Restore conversation only | Keeps current files |
| Restore code only | Keeps current conversation |
| Summarize from point forward | Condenses history from checkpoint |

---

### Scheduled tasks

**Three modes:**

| Mode | Runs on | Machine required | Session required | Min interval |
| :--- | :------ | :--------------- | :--------------- | :----------- |
| Cloud (Routines) | Anthropic cloud | No | No | 1 hour |
| Desktop | Your machine | Yes | No | 1 minute |
| /loop | Your machine | Yes | Yes | 1 minute |

**Desktop task fields:** Name, Description, Prompt, Frequency (Manual / Hourly / Daily / Weekdays / Weekly)

**Missed runs:** catch-up up to 7 days; each task has its own permission mode.

**`/loop` syntax:**

| Input | Behavior |
| :---- | :------- |
| `interval + prompt` | Fixed schedule |
| `prompt only` | Claude picks interval (1m–1h) |
| _(nothing)_ | Built-in maintenance loop |

Custom default loop prompt: `.claude/loop.md` or `~/.claude/loop.md`

Cron: standard 5-field; jitter up to 10% or 15 minutes; recurring tasks auto-expire after 7 days. Press `Esc` to stop.

---

### Routines (cloud scheduled tasks)

**Triggers:**

| Trigger | Details |
| :------ | :------ |
| Schedule | Recurring on a set frequency |
| API | `POST https://api.anthropic.com/v1/claude_code/routines/{routine_id}/fire` with bearer token |
| GitHub PR events | opened / closed / assigned / labeled / synchronized / updated |
| GitHub Release events | created / published / edited / deleted |

**PR filters:** author, title, body, base branch, head branch, labels, is draft, is merged.

---

### Output styles

**Built-in styles:**

| Style | Behavior |
| :---- | :------- |
| Default | Standard responses |
| Explanatory | Adds "Insights" section |
| Learning | Collaborative with `TODO(human)` markers |

**Custom styles:** place markdown files with frontmatter in `~/.claude/output-styles/` or `.claude/output-styles/`

Frontmatter fields: `name`, `description`, `keep-coding-instructions` (default: `false`)

Change via `/config` > Output style or the `outputStyle` setting. Takes effect next session.

---

### Fast mode

Toggle: `/fast` or `"fastMode": true` in settings. Opus 4.6 only — 2.5x faster, higher cost.

**Pricing:** $30 input / $150 output per MTok

- Falls back to standard mode on rate limit
- Requires extra usage to be enabled
- Not available on Bedrock / Vertex / Foundry
- Disabled by default for Team and Enterprise plans

---

### Model configuration

**Aliases:**

| Alias | Model |
| :---- | :---- |
| `default` | Current default |
| `best` / `opus` | Opus |
| `sonnet` | Sonnet |
| `haiku` | Haiku |
| `sonnet[1m]` | Sonnet with 1M context |
| `opus[1m]` | Opus with 1M context |
| `opusplan` | Opus planning variant |

**Effort levels:** `low`, `medium`, `high`, `xhigh` (Opus 4.7 default), `max` (unlimited, session-only)

**Config priority:** `/model` command > `--model` flag > `ANTHROPIC_MODEL` env var > settings file

---

### Fullscreen TUI

Enable: `/tui fullscreen` or set env var `CLAUDE_CODE_NO_FLICKER=1`

Features: fixed input box, flat memory usage, alternate screen buffer.

**Mouse support:**

| Action | Effect |
| :----- | :----- |
| Click | Expand / collapse sections |
| Click URL or path | Open in browser / editor |
| Drag | Select text (auto-copies) |

Disable mouse: `CLAUDE_CODE_DISABLE_MOUSE=1`

**Navigation:**

| Key | Action |
| :-- | :----- |
| `PgUp` / `PgDn` | Scroll half-screen |
| `Ctrl+Home` / `Ctrl+End` | Jump to start / end |
| `Ctrl+o` | Transcript mode |
| `/` | Search |
| `[` | Export to scrollback |
| `v` | Open in `$EDITOR` |

---

### Voice dictation

Enable: `/voice` or add to settings:

```json
{ "voice": { "enabled": true, "mode": "tap" } }
```

**Modes:**

| Mode | Behavior |
| :--- | :------- |
| Hold (default) | Hold `Space` to record, release to finalize |
| Tap | Tap to start, tap to send |

Requirements: Claude.ai account, local microphone; 20 supported languages.

Auto-submit: `"autoSubmit": true`. Recording stops after 15s silence or 2 minutes total.

---

### Remote control

**Start:**

| Method | Command |
| :----- | :------ |
| Server mode | `claude remote-control` |
| Interactive mode | `claude --remote-control` |
| Existing session | `/remote-control` |

**Server flags:** `--name`, `--spawn` (same-dir / worktree / session), `--capacity N` (default 32)

**Connect:** browser URL, QR code, or claude.ai/code session list

- Local-only execution (MCP and tools available)
- Outbound HTTPS only — no inbound ports opened
- Network outage >10 minutes causes timeout
- Mobile push notifications require v2.1.110+

---

### Channels (notifications and chat bridges)

**Supported platforms:** Telegram, Discord, iMessage (macOS only), Fakechat (demo)

**Capabilities:** one-way (alerts) or two-way (chat bridges); supports permission relay and sender allowlisting.

**MCP server capability declaration:**

```json
{
  "capabilities": {
    "experimental": {
      "claude/channel": {}
    }
  }
}
```

Permission relay capability: `capabilities.experimental['claude/channel/permission']`

**Notification format:** `notifications/claude/channel` with `content` and `meta` params

**Permission request fields:** `request_id` (5 lowercase letters), `tool_name`, `description`, `input_preview`

---

### Status line

Config in `settings.json`:

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

**Available fields:**

| Field | Description |
| :---- | :---------- |
| `model.id` / `model.display_name` | Current model |
| `cwd` | Working directory |
| `workspace.current_dir` / `workspace.project_dir` | Workspace paths |
| `cost.total_cost_usd` / `cost.total_duration_ms` | Session cost and time |
| `context_window.used_percentage` / `remaining_percentage` / `context_window_size` | Context window stats |
| `rate_limits.five_hour.used_percentage` / `rate_limits.seven_day.used_percentage` | Rate limit usage |
| `session_id` | Current session ID |
| `git_worktree` | Git worktree path |

---

### Context window

**Auto-loaded at session start (approximate token costs):**

| Component | Tokens |
| :-------- | :----- |
| System prompt | ~4,200 |
| Auto memory | ~680 |
| Environment info | ~280 |
| MCP tools (deferred) | ~120 |
| Skill descriptions | ~450 |
| Global CLAUDE.md | ~320 |
| Project CLAUDE.md | ~1,800 |

**After `/compact`:** system prompt and output style unchanged; project CLAUDE.md, unscoped rules, and auto memory are re-injected; scoped rules are lost; invoked skill bodies are re-injected (capped at 5K per skill, 25K total); hooks are unaffected.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Features Overview](references/claude-code-features-overview.md) — when to use CLAUDE.md vs. skills vs. subagents vs. MCP vs. hooks, feature selection table, and layering patterns
- [Checkpointing](references/claude-code-checkpointing.md) — auto-tracking file edits, rewind actions, access methods, and limitations
- [Desktop Scheduled Tasks](references/claude-code-desktop-scheduled-tasks.md) — Desktop and /loop scheduling modes, task fields, missed runs, and permissions
- [Scheduled Tasks (/loop)](references/claude-code-scheduled-tasks.md) — /loop syntax, cron format, jitter, custom default prompts, and stopping tasks
- [Routines](references/claude-code-routines.md) — cloud-based scheduling with Schedule, API, and GitHub event triggers; PR filters; API reference
- [Output Styles](references/claude-code-output-styles.md) — built-in styles, custom style authoring, frontmatter fields, and configuration
- [Fast Mode](references/claude-code-fast-mode.md) — enabling fast mode, Opus 4.6 requirements, pricing, and fallback behavior
- [Model Configuration](references/claude-code-model-config.md) — model aliases, effort levels, and config priority order
- [Fullscreen TUI](references/claude-code-fullscreen.md) — enabling fullscreen, mouse support, navigation keybindings, and transcript mode
- [Voice Dictation](references/claude-code-voice-dictation.md) — enabling voice, hold vs. tap modes, auto-submit, and language support
- [Remote Control](references/claude-code-remote-control.md) — server and interactive modes, spawn options, connection methods, and network behavior
- [Channels](references/claude-code-channels.md) — supported platforms, one-way vs. two-way capabilities, permission relay, and sender allowlisting
- [Channels Reference](references/claude-code-channels-reference.md) — MCP capability declarations, notification format, and permission request fields
- [Status Line](references/claude-code-statusline.md) — configuration, refresh interval, and all available template fields
- [Context Window](references/claude-code-context-window.md) — token costs at startup, what survives /compact, and skill body injection caps

## Sources

- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Desktop Scheduled Tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Scheduled Tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Routines: https://code.claude.com/docs/en/routines.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Fullscreen TUI: https://code.claude.com/docs/en/fullscreen.md
- Voice Dictation: https://code.claude.com/docs/en/voice-dictation.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels Reference: https://code.claude.com/docs/en/channels-reference.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Context Window: https://code.claude.com/docs/en/context-window.md
