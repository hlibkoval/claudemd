---
name: features-doc
description: Complete documentation for Claude Code features beyond core coding. Covers fast mode (toggle, pricing, cost tradeoff, effort level vs fast mode), model configuration (aliases, availableModels, model pinning, opusplan, default model, ANTHROPIC_MODEL, /model command), output styles (built-in Default/Explanatory/Learning, custom output styles, keep-coding-instructions, outputStyle setting), status line (/statusline command, custom shell scripts, JSON session data, padding, multi-line, Windows), checkpointing (rewind, /rewind, Esc+Esc, restore code/conversation, summarize, session-scoped), context window (interactive simulation, startup loading, system prompt, CLAUDE.md, MCP tools, skills, auto memory, compact), remote control (continue local sessions from phone/browser, server mode, --remote-control, /rc, QR code, spawn modes, capacity), scheduled tasks (/loop, cron, interval syntax, session-scoped scheduling), cloud scheduled tasks (web scheduled tasks, recurring prompts, Anthropic cloud, /schedule, connectors, task prompt), desktop scheduled tasks (local tasks, remote tasks, frequency options, worktree toggle, catch-up behavior), voice dictation (/voice, push-to-talk, Space hold, speech-to-text, dictation language, modifier rebind), channels (push events into session, Telegram, Discord, iMessage, fakechat, channel plugins, two-way channels, sender allowlists), channels reference (build MCP channel server, capability declaration, notification events, reply tools, sender gating, permission relay, webhook receiver), fullscreen rendering (CLAUDE_CODE_NO_FLICKER, alternate screen buffer, flicker-free, mouse support, stable memory, search, copy on select), features overview (extension comparison table, CLAUDE.md vs skill vs rules, skill vs subagent, MCP vs hook, plugin packaging). Load when discussing Claude Code features, fast mode, /fast, model config, model aliases, opusplan, output styles, statusline, /statusline, checkpointing, /rewind, context window, remote control, /rc, scheduled tasks, /loop, /schedule, voice dictation, /voice, channels, fullscreen, CLAUDE_CODE_NO_FLICKER, or any Claude Code feature configuration topic.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features beyond core coding capabilities.

## Quick Reference

### Fast Mode

| Setting | Value |
|:--------|:------|
| Toggle | `/fast` (Tab to confirm) or `"fastMode": true` in settings |
| Pricing | $30/150 MTok (input/output) — flat across 1M context |
| Speed | ~2.5x faster than standard Opus 4.6 |
| Model | Same Opus 4.6, different API configuration |
| Availability | Pro/Max/Team/Enterprise and Console (extra usage only on subscriptions) |
| Persistence | Persists across sessions by default; admins can require per-session opt-in |
| Indicator | `↯` icon next to prompt |

Fast mode vs effort level: fast mode changes API configuration for speed at higher cost; effort level (`/config` or `--effort`) controls reasoning depth at reduced quality.

### Model Configuration

| Alias | Resolves to |
|:------|:------------|
| `default` | Clears override, reverts to account-tier default |
| `best` | Most capable model (currently `opus`) |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast Haiku for simple tasks |
| `sonnet[1m]` / `opus[1m]` | 1M token context window variants |
| `opusplan` | Opus for planning, Sonnet for execution |

Setting priority: `/model` > `--model` flag > `ANTHROPIC_MODEL` env > settings file `"model"` field.

Restrict models: `availableModels` in managed/policy settings. Pin alias targets with `ANTHROPIC_DEFAULT_SONNET_MODEL` / `ANTHROPIC_DEFAULT_OPUS_MODEL` / `ANTHROPIC_DEFAULT_HAIKU_MODEL`.

### Output Styles

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Adds educational "Insights" between coding tasks |
| **Learning** | Collaborative mode with `TODO(human)` markers for you to implement |
| **Custom** | Markdown file with frontmatter; set via `outputStyle` in settings or `/config` |

Custom styles: create `.md` file with `name`/`description` frontmatter. Set `keep-coding-instructions: true` to retain coding instructions. Changes take effect next session.

### Status Line

| Field | Description |
|:------|:------------|
| `statusLine.type` | `"command"` |
| `statusLine.command` | Path to script or inline shell command |
| `statusLine.padding` | Extra horizontal spacing (default: `0`) |

Setup: `/statusline <description>` auto-generates script. Receives JSON session data on stdin with fields: `model`, `context_window.used_percentage`, `context_window.used_tokens`, `context_window.max_tokens`, `session.cost`, `session.duration_ms`, `session.message_count`, `git.branch`, `git.dirty_files`.

### Checkpointing

| Action | How |
|:-------|:----|
| Open rewind menu | `Esc` + `Esc` or `/rewind` |
| Restore code and conversation | Revert both to selected point |
| Restore conversation only | Rewind messages, keep current code |
| Restore code only | Revert files, keep conversation |
| Summarize from here | Compress selected point onward into summary |

Checkpoints persist across sessions; auto-cleaned after 30 days. Bash command changes and external edits are not tracked.

### Context Window

Startup loading order: system prompt (4.2K tokens) > auto memory/MEMORY.md (680) > environment info (280) > MCP tools deferred (120) > skill descriptions (450) > `~/.claude/CLAUDE.md` (320) > project CLAUDE.md (1.8K) > `.claude/rules/` > first user message.

### Remote Control

| Mode | Command | Description |
|:-----|:--------|:------------|
| Server | `claude remote-control` | Dedicated server waiting for remote connections |
| Interactive | `claude --remote-control` or `--rc` | Normal session + remote access |
| In-session | `/remote-control` or `/rc` | Enable on existing session |

Flags: `--name`, `--spawn <same-dir|worktree>`, `--capacity <N>`, `--verbose`, `--sandbox`/`--no-sandbox`. Available on Pro/Max/Team/Enterprise (admin must enable on Team/Enterprise).

### Scheduled Tasks

| Type | Scope | Persistence | Runs on |
|:-----|:------|:------------|:--------|
| `/loop` | Session | No (gone on exit) | Your machine |
| Desktop (local) | Durable | Yes | Your machine |
| Cloud (web) | Durable | Yes | Anthropic cloud |

`/loop` syntax: `/loop 5m <prompt>`, `/loop <prompt> every 2h`, `/loop <prompt>` (defaults to 10m). Units: `s`, `m`, `h`, `d`.

Cloud tasks: create via [claude.ai/code/scheduled](https://claude.ai/code/scheduled), Desktop app, or `/schedule` in CLI. Minimum interval: 1 hour.

Desktop tasks: local tasks (access local files, machine must be on) or remote tasks (cloud infrastructure, fresh clone). Minimum interval: 1 minute.

### Voice Dictation

| Setting | Value |
|:--------|:------|
| Toggle | `/voice` or `"voiceEnabled": true` in settings |
| Push-to-talk | Hold `Space` (brief warmup) or modifier combo for instant start |
| Rebind key | `"voicePushToTalkKeys"` in settings (e.g., `"meta+k"`) |
| Language | Set via `/config` > Dictation language |
| Requires | Claude.ai auth, local microphone (not available in remote/SSH environments) |

### Channels

| Channel | Type | Setup |
|:--------|:-----|:------|
| Telegram | Two-way chat | `/plugin install telegram@claude-plugins-official` then `/telegram:configure <token>` |
| Discord | Two-way chat | `/plugin install discord@claude-plugins-official` then `/discord:configure <token>` |
| iMessage | Two-way chat | `/plugin install imessage@claude-plugins-official` then `/imessage:configure` |
| fakechat | Demo | `/plugin install fakechat@claude-plugins-official` |

Channels push events into running sessions via MCP `notifications/claude/channel`. Require `claude/channel` capability declaration. Research preview, requires v2.1.80+, claude.ai login. Team/Enterprise must explicitly enable.

Building custom channels: declare `claude/channel` capability, emit `notifications/claude/channel`, connect over stdio. Expose reply tool for two-way. Gate senders to prevent prompt injection. Relay permission prompts for remote approval.

### Fullscreen Rendering

| Setting | Value |
|:--------|:------|
| Enable | `CLAUDE_CODE_NO_FLICKER=1 claude` or export in shell profile |
| Search | `Ctrl+o` then `/` |
| Write to scrollback | `Ctrl+o` then `[` |
| Mouse | Click to expand tool results, click URLs/paths to open, drag to select, wheel to scroll |
| Copy | Auto-copies on mouse release (toggle in `/config`); `Ctrl+Shift+c` manual copy |
| Disable mouse only | `"fullscreenMouse": false` in settings |

Renders on alternate screen buffer. Fixed input at bottom. Constant memory regardless of conversation length.

### Features Overview

| Feature | What it does | When to use |
|:--------|:------------|:------------|
| CLAUDE.md | Persistent context every session | Project conventions, "always do X" rules |
| Skill | Reusable knowledge and workflows | Reference docs, repeatable tasks |
| Subagent | Isolated execution context | Context isolation, parallel work |
| Agent teams | Multiple independent sessions | Parallel research, competing hypotheses |
| MCP | Connect to external services | External data or actions |
| Hook | Deterministic script on events | Predictable automation, no LLM |
| Plugin | Package and distribute extensions | Cross-repo reuse, marketplace distribution |

## Full Documentation

For the complete official documentation, see the reference files:

- [Features Overview](references/claude-code-features-overview.md) — Extension comparison and feature selection guide
- [Fast Mode](references/claude-code-fast-mode.md) — Toggle, pricing, cost tradeoffs, and when to use fast mode
- [Model Configuration](references/claude-code-model-config.md) — Model aliases, setting priority, availableModels, model pinning
- [Output Styles](references/claude-code-output-styles.md) — Built-in and custom output styles for non-engineering use cases
- [Status Line](references/claude-code-statusline.md) — Custom status bar with shell scripts and JSON session data
- [Checkpointing](references/claude-code-checkpointing.md) — Rewind, restore, and summarize session state
- [Context Window](references/claude-code-context-window.md) — Interactive simulation of context window loading
- [Remote Control](references/claude-code-remote-control.md) — Continue local sessions from phone, tablet, or browser
- [Scheduled Tasks](references/claude-code-scheduled-tasks.md) — /loop and cron scheduling within sessions
- [Cloud Scheduled Tasks](references/claude-code-web-scheduled-tasks.md) — Recurring prompts on Anthropic cloud infrastructure
- [Desktop Scheduled Tasks](references/claude-code-desktop-scheduled-tasks.md) — Local and remote recurring tasks in Desktop app
- [Voice Dictation](references/claude-code-voice-dictation.md) — Push-to-talk speech input for prompts
- [Channels](references/claude-code-channels.md) — Push events into sessions via Telegram, Discord, iMessage
- [Channels Reference](references/claude-code-channels-reference.md) — Build custom MCP channel servers
- [Fullscreen Rendering](references/claude-code-fullscreen.md) — Flicker-free alternate screen buffer rendering

## Sources

- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Context Window: https://code.claude.com/docs/en/context-window.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled Tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Cloud Scheduled Tasks: https://code.claude.com/docs/en/web-scheduled-tasks.md
- Desktop Scheduled Tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Voice Dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels Reference: https://code.claude.com/docs/en/channels-reference.md
- Fullscreen Rendering: https://code.claude.com/docs/en/fullscreen.md
