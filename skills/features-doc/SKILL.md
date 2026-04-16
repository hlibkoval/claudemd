---
name: features-doc
description: Complete official documentation for Claude Code features — channels, checkpointing, context window, fast mode, fullscreen, model config, output styles, remote control, routines, scheduled tasks, desktop scheduled tasks, status line, voice dictation, and the features overview.
user-invocable: false
---

# Features Documentation

This skill collects the official documentation for Claude Code's user-facing features: how to customize the interface, automate work, manage context, and extend the agent.

## Quick Reference

### Feature index

| Feature | One-liner |
|---|---|
| **Channels** | Dedicated lanes for different kinds of work within a session |
| **Checkpointing** | Automatic rewindable snapshots of code + conversation (`/rewind`, Esc+Esc) |
| **Context window** | Inspect what fills Claude's context (`/context`) |
| **Desktop scheduled tasks** | Recurring tasks that run on your local machine |
| **Fast mode** | 2.5x faster Opus 4.6 at higher per-token cost (`/fast`) |
| **Fullscreen** | Expanded terminal UI for focused work |
| **Model config** | Switch models, adjust effort level (`/model`, `/effort`) |
| **Output styles** | Customize tone and formatting of Claude's responses |
| **Remote control** | Drive a CLI session from claude.ai/code in a browser |
| **Routines** | Cloud-run prompts with schedule, API, and GitHub triggers |
| **Scheduled tasks** | In-session recurring work via `/loop` |
| **Status line** | Custom shell-script bar showing model, cost, git, context |
| **Voice dictation** | Speak prompts instead of typing |

### Checkpointing

| Action | How |
|---|---|
| Open rewind menu | `Esc+Esc` or `/rewind` |
| Restore code + conversation | Menu option (full revert) |
| Restore conversation only | Keeps current code |
| Restore code only | Keeps conversation history |
| Summarize from here | AI-compresses selected message + later into a summary (frees context) |
| Retention | 30 days (configurable); persists across sessions |
| Not tracked | Bash-command file changes, external/concurrent edits |

### Fast mode

| Detail | Value |
|---|---|
| Toggle | `/fast` (persists across sessions by default) |
| Indicator | Small lightning icon next to prompt |
| Pricing | $30 input / $150 output per MTok (flat across 1M context) |
| Billing | Always charged to extra usage, never counts against plan |
| Requires | v2.1.36+, extra usage enabled; not on Bedrock/Vertex/Foundry |
| Per-session opt-in | Admin sets `fastModePerSessionOptIn: true` |
| Disable org-wide | `CLAUDE_CODE_DISABLE_FAST_MODE=1` |
| Rate-limit behavior | Auto-falls back to standard Opus 4.6; icon turns gray |

Fast mode and effort level are orthogonal: fast mode = same quality, lower latency, higher cost; lower effort = less thinking, faster, potentially lower quality. Combine for max speed.

### Routines (triggers)

| Trigger | Behavior |
|---|---|
| Schedule | Hourly / daily / weekdays / weekly presets; custom cron via `/schedule update` (min 1 hour) |
| API | POST to `/fire` endpoint with bearer token; optional `text` body for run-specific context |
| GitHub | Fires on `pull_request.*` or `release.*` events with filters (author, labels, branch, fork, etc.) |

| Creating / managing | Surface |
|---|---|
| Web UI | `claude.ai/code/routines` |
| CLI | `/schedule`, `/schedule list/update/run` (schedule triggers only) |
| Desktop app | New task > New remote task |

Runs autonomously as a cloud session: no permission prompts, can push only to `claude/`-prefixed branches unless unrestricted pushes enabled. API trigger ships under `experimental-cc-routine-2026-04-01` beta header.

### Scheduled-task options compared

| Option | Runs where | Best for |
|---|---|---|
| Routines | Anthropic cloud | Runs when laptop is off; schedule/API/GitHub triggers |
| Desktop scheduled tasks | Your machine (Desktop app) | Needs local file/tool access |
| `/loop` | Current CLI session | Quick polling; cancelled on session exit |

### Status line

Add to `~/.claude/settings.json`. The fastest path is the `/statusline` slash command, which generates the script.

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

| Config field | Purpose |
|---|---|
| `type` | Always `"command"` |
| `command` | Script path or inline shell command |
| `padding` | Extra horizontal spacing in characters (default 0) |
| `refreshInterval` | Re-run every N seconds (min 1); use for clocks/time-based data |

| Key JSON input fields | Description |
|---|---|
| `model.display_name` | Current model |
| `workspace.current_dir`, `workspace.project_dir` | Directories |
| `context_window.used_percentage` | Pre-calculated context % |
| `cost.total_cost_usd`, `cost.total_duration_ms` | Session cost + wall time |
| `rate_limits.five_hour.used_percentage` | Subscriber rate-limit usage |
| `session_id` | Stable ID for caching |
| `vim.mode`, `agent.name`, `worktree.*` | Conditional fields |

Updates fire after each assistant message, mode change, or vim toggle (300ms debounce). A separate `subagentStatusLine` customizes subagent panel rows.

### Context window management

| Action | Command |
|---|---|
| Inspect what's loaded | `/context` |
| Full-conversation summarize | `/compact <instructions>` |
| Targeted summarize from a message | `/rewind` > Summarize from here |
| Reset between tasks | `/clear` |
| Side question outside history | `/btw` |

### Routines: example use cases

| Trigger | Use case |
|---|---|
| Schedule | Nightly backlog grooming; weekly docs-drift sweep |
| API | Alert-triage on Sentry thresholds; post-deploy smoke tests |
| GitHub | Bespoke PR review on `pull_request.opened`; SDK port on merge |

## Full Documentation

For the complete official documentation, see the reference files:

- [Features overview](references/claude-code-features-overview.md) — How to extend Claude Code: comparing CLAUDE.md, skills, subagents, agent teams, MCP, hooks, and plugins; when to reach for each, and how they layer and combine.
- [Channels reference](references/claude-code-channels-reference.md) — Complete API reference for channels.
- [Channels](references/claude-code-channels.md) — Conceptual guide to channels: what they are and how to use them for different kinds of work.
- [Checkpointing](references/claude-code-checkpointing.md) — Automatic tracking of Claude's edits with rewind, restore, and summarize options.
- [Context window](references/claude-code-context-window.md) — Inspecting and understanding what fills Claude's context at any given time.
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) — Local recurring tasks that run on your machine via the Claude Code Desktop app.
- [Fast mode](references/claude-code-fast-mode.md) — 2.5x-faster Opus 4.6 toggle, cost tradeoff, rate-limit behavior, and admin controls.
- [Fullscreen](references/claude-code-fullscreen.md) — Expanded terminal UI for focused work.
- [Model config](references/claude-code-model-config.md) — Switching models, setting effort level, and adjusting reasoning budgets.
- [Output styles](references/claude-code-output-styles.md) — Customizing the tone and formatting of Claude's responses.
- [Remote control](references/claude-code-remote-control.md) — Drive a CLI session from a browser at claude.ai/code.
- [Routines](references/claude-code-routines.md) — Cloud-run saved prompts with schedule, API, and GitHub triggers.
- [Scheduled tasks](references/claude-code-scheduled-tasks.md) — `/loop` and in-session scheduling for polling and recurring work during an active session.
- [Status line](references/claude-code-statusline.md) — Configure a shell-script status bar; full JSON input schema and ready-to-use examples.
- [Voice dictation](references/claude-code-voice-dictation.md) — Speak prompts instead of typing.

## Sources

- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Channels: https://code.claude.com/docs/en/channels.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Context window: https://code.claude.com/docs/en/context-window.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Features overview: https://code.claude.com/docs/en/features-overview.md
- Fullscreen: https://code.claude.com/docs/en/fullscreen.md
- Model config: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Remote control: https://code.claude.com/docs/en/remote-control.md
- Routines: https://code.claude.com/docs/en/routines.md
- Scheduled tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
