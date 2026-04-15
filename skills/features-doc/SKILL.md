---
name: features-doc
description: Complete official documentation for miscellaneous Claude Code features — fast mode, model configuration and aliases, output styles, status line, checkpointing and rewind, scheduled tasks (loop, desktop, cloud routines), remote control, channels (event push from MCP), voice dictation, fullscreen rendering, the context window, and the high-level features overview.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code's user-facing features: speed and model controls, UI customization, session-state management, scheduling and automation, and event-driven integrations.

## Quick Reference

### Feature index

| Feature | Purpose | Trigger |
|---|---|---|
| Fast mode | 2.5x faster Opus 4.6 at higher cost per token | `/fast` (toggle), `fastMode: true` setting |
| Model config | Pick the model used for a session | `/model`, `--model`, `ANTHROPIC_MODEL`, `model` setting |
| Output styles | Adjust system prompt for tone, role, format | `/config` then Output style; `/output-style` |
| Status line | Custom shell-script-driven bottom bar | `/statusline`, `statusLine` setting |
| Checkpointing | Auto-snapshot file edits and conversation per turn | Esc Esc, `/rewind` |
| Features overview | When to use CLAUDE.md vs skills vs hooks vs MCP vs plugins | (reference doc) |
| Remote control | Drive a local session from web/mobile | `claude remote-control`, `/remote-control` |
| Scheduled tasks (`/loop`) | Re-run a prompt on an interval inside a session | `/loop [interval] [prompt]` |
| Voice dictation | Push-to-talk speech-to-text into the prompt | `/voice`, hold Space |
| Channels | MCP server pushes events into a running session | `/plugin install <channel>`, `claude/channel` capability |
| Channels reference | Build a channel MCP server (notification + reply contract) | (reference doc) |
| Desktop scheduled tasks | Local recurring tasks in the Claude Code Desktop app | Schedule page, **New task** |
| Routines | Cloud-hosted automation: schedule, API, and GitHub triggers | `/schedule`, claude.ai/code/routines |
| Context window | Interactive map of what fills the 200K context window | (reference doc) |
| Fullscreen rendering | Flicker-free alternate-screen UI with mouse support | `CLAUDE_CODE_NO_FLICKER=1` env var |

### Model aliases (model-config)

| Alias | Resolves to |
|---|---|
| `default` | Account's recommended model (clears overrides) |
| `best` | Most capable model (currently `opus`) |
| `sonnet` | Latest Sonnet (daily coding) |
| `opus` | Latest Opus (complex reasoning) |
| `haiku` | Fast and efficient |
| `sonnet[1m]` / `opus[1m]` | 1M-token context window variants |
| `opusplan` | Opus during plan mode, Sonnet for execution |

Precedence (highest first): `/model` in session > `--model` flag > `ANTHROPIC_MODEL` env > `model` in settings.

### Scheduled work: pick the right tool

| Need | Use |
|---|---|
| Polling / babysitting inside the current session | `/loop` (session-scoped, dies with session) |
| Recurring task on your machine, machine must be on | Desktop scheduled tasks (local) |
| Recurring or event-triggered work without your machine | Routines (cloud) |

Routine triggers: **Scheduled** (cron-like cadence, min 1 hour), **API** (HTTP POST with bearer token to per-routine endpoint), **GitHub** (PR/push/issue/workflow events). A single routine can combine multiple triggers. Manage at claude.ai/code/routines or via `/schedule` in the CLI.

### Checkpointing / rewind actions

Press Esc Esc or run `/rewind` to open the menu at any prior user prompt:

| Action | Effect |
|---|---|
| Restore code and conversation | Revert both to that point |
| Restore conversation | Rewind chat, keep current code |
| Restore code | Revert files, keep conversation |
| Summarize from here | Compact this point forward into a summary; no file changes |
| Never mind | Close menu |

Checkpoints persist across sessions and clean up with the session after 30 days (configurable). For branching off into a separate session, use `claude --continue --fork-session` instead.

### Status line config shape

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

The command receives JSON session data on stdin and prints the bar to stdout. `/statusline <description>` asks Claude to generate a script and wire it up automatically.

### Channels at a glance

A channel is an MCP server (stdio transport) that declares the `claude/channel` capability and emits `notifications/claude/channel` events. Built-in research-preview channels: Telegram, Discord, iMessage, plus `fakechat` for local demos. Two-way channels also expose a reply tool so Claude can send messages back; trusted channels can opt in to relay permission prompts. Requires claude.ai login (no API-key auth) and v2.1.80+. Team/Enterprise must enable the org toggle.

### Voice dictation

Run `/voice` to toggle. Hold Space to record (rebindable). Audio streams to Anthropic for transcription, so claude.ai login is required (Bedrock/Vertex/Foundry/API-key auth not supported). Needs local mic, so it does not work on web or SSH; WSL needs WSLg. Persists across sessions; can also set `voiceEnabled: true`.

### Fullscreen rendering

Set `CLAUDE_CODE_NO_FLICKER=1` (research preview, v2.1.89+) to switch to the alternate-screen rendering path. Eliminates flicker, keeps memory flat in long conversations, adds mouse support, fixes a fixed input box at the bottom. Conversation lives in the alternate buffer rather than terminal scrollback.

### Remote Control

`claude remote-control` (server mode) or `/remote-control` in the VS Code extension exposes a local session to claude.ai/code or the Claude mobile app. The session stays on your machine; the web/app are just a window into it. Reconnects automatically across sleep and network drops. Requires claude.ai auth (no API keys), workspace trust, v2.1.51+. Off by default on Team/Enterprise until an admin enables it.

## Full Documentation

For the complete official documentation, see the reference files:

- [Speed up responses with fast mode](references/claude-code-fast-mode.md) — Toggle Opus 4.6 fast mode with `/fast`; cost tradeoff, requirements, per-session opt-in, rate limit handling.
- [Model configuration](references/claude-code-model-config.md) — Model aliases (`opus`, `sonnet`, `haiku`, `opusplan`, `[1m]` variants), how to set the model, per-tool model overrides, environment variables.
- [Output styles](references/claude-code-output-styles.md) — Built-in Default, Explanatory, and Learning styles plus how to author custom output styles.
- [Customize your status line](references/claude-code-statusline.md) — `statusLine` configuration, JSON input schema, available data fields, ready-made examples for git, cost, and progress bars.
- [Checkpointing](references/claude-code-checkpointing.md) — Automatic per-turn snapshots, the rewind menu, restore vs. summarize, retention settings.
- [Extend Claude Code (features overview)](references/claude-code-features-overview.md) — Decision guide for choosing between CLAUDE.md, skills, subagents, agent teams, hooks, MCP, and plugins.
- [Remote Control](references/claude-code-remote-control.md) — Drive a local Claude Code session from web or mobile; setup, server/client modes, comparison with Claude Code on the web.
- [Run prompts on a schedule](references/claude-code-scheduled-tasks.md) — Session-scoped `/loop` for polling and reminders; comparison with Desktop tasks and Routines.
- [Voice dictation](references/claude-code-voice-dictation.md) — Push-to-talk dictation with `/voice`, microphone setup, language config, key rebinding.
- [Push events into a running session with channels](references/claude-code-channels.md) — Install Telegram, Discord, iMessage, or fakechat channel plugins; sender allowlists, enterprise controls, comparison with Slack and Remote Control.
- [Channels reference](references/claude-code-channels-reference.md) — Build your own channel MCP server: capability declaration, notification format, reply tools, sender gating, permission relay.
- [Schedule recurring tasks in Claude Code Desktop](references/claude-code-desktop-scheduled-tasks.md) — Local recurring tasks in the Desktop app, missed-run and catch-up behavior, local vs. remote task choice.
- [Explore the context window](references/claude-code-context-window.md) — Interactive simulation of how the 200K-token context window fills during a session, including auto-loaded items, file reads, rules, and hooks.
- [Fullscreen rendering](references/claude-code-fullscreen.md) — Opt-in `CLAUDE_CODE_NO_FLICKER=1` rendering mode using the alternate screen buffer; mouse support and constant memory in long sessions.
- [Automate work with routines](references/claude-code-routines.md) — Cloud-hosted automation: schedule, API, and GitHub triggers running on Anthropic-managed infrastructure; create/manage at claude.ai/code/routines or via `/schedule`.

## Sources

- Speed up responses with fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Customize your status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Extend Claude Code (features overview): https://code.claude.com/docs/en/features-overview.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Run prompts on a schedule: https://code.claude.com/docs/en/scheduled-tasks.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Push events into a running session with channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Schedule recurring tasks in Claude Code Desktop: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Explore the context window: https://code.claude.com/docs/en/context-window.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
- Automate work with routines: https://code.claude.com/docs/en/routines.md
