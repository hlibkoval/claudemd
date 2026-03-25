---
name: features-doc
description: Complete documentation for Claude Code features and capabilities -- model configuration (model aliases default/sonnet/opus/haiku/sonnet[1m]/opus[1m]/opusplan, /model command, --model flag, ANTHROPIC_MODEL env var, model settings, availableModels restriction, modelOverrides for Bedrock/Vertex/Foundry ARN mapping, ANTHROPIC_DEFAULT_OPUS_MODEL/SONNET_MODEL/HAIKU_MODEL env vars, ANTHROPIC_CUSTOM_MODEL_OPTION for /model picker, prompt caching config DISABLE_PROMPT_CACHING), effort levels (low/medium/high/max with /effort command --effort flag CLAUDE_CODE_EFFORT_LEVEL env var effortLevel setting, adaptive reasoning, MAX_THINKING_TOKENS, CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING), extended 1M context window (opus[1m] sonnet[1m] aliases, plan availability, CLAUDE_CODE_DISABLE_1M_CONTEXT), fast mode (2.5x faster Opus 4.6 at $30/150 MTok, /fast toggle, fastMode setting, fastModePerSessionOptIn, extra usage required, rate limit fallback, research preview, CLAUDE_CODE_DISABLE_FAST_MODE), output styles (Default/Explanatory/Learning built-in styles, custom output style Markdown files with frontmatter name/description/keep-coding-instructions, ~/.claude/output-styles and .claude/output-styles paths, /config to change, outputStyle setting, system prompt modification), status line (/statusline command, statusLine setting with type command and command/padding fields, JSON stdin data with model/workspace/cost/context_window/rate_limits/session_id/vim/agent/worktree fields, ANSI colors, OSC 8 clickable links, multi-line output, context window fields current_usage/used_percentage/remaining_percentage, examples for context bar/git status/cost tracking), checkpointing (automatic edit tracking, Esc+Esc or /rewind to open menu, restore code and conversation/restore conversation/restore code/summarize from here actions, session-level recovery, bash/external changes not tracked), Remote Control (continue local sessions from any device, claude remote-control server mode with --name/--spawn/--capacity/--verbose/--sandbox flags, claude --remote-control or --rc interactive mode, /remote-control or /rc from existing session, connect via URL/QR code/session list, enable for all sessions via /config, HTTPS outbound-only security, vs Claude Code on the web comparison, troubleshooting), scheduled tasks (session-scoped /loop skill with interval syntax s/m/h/d, one-time reminders in natural language, CronCreate/CronList/CronDelete tools, cron expression reference, jitter/three-day expiry, CLAUDE_CODE_DISABLE_CRON, vs cloud/Desktop scheduled tasks comparison), web scheduled tasks (cloud recurring tasks on Anthropic infrastructure, create via web/Desktop/CLI /schedule command, frequency options hourly/daily/weekdays/weekly, repository selection with claude/ branch prefix, cloud environment with network/env vars/setup script, connectors, run management, /schedule list/update/run CLI commands), voice dictation (/voice toggle, hold Space push-to-talk with warmup, voiceEnabled setting, 20 supported languages, rebind push-to-talk key in keybindings.json, coding vocabulary recognition, claude.ai account required), channels (research preview, push events into running session from MCP server, Telegram/Discord/iMessage/fakechat plugins, --channels flag, channelsEnabled enterprise setting, sender allowlists, pairing flow, two-way chat bridge, webhook receiver, /plugin install for channel plugins, --dangerously-load-development-channels for testing, vs web sessions/Slack/MCP/Remote Control comparison), channels reference (build custom channel MCP servers, claude/channel capability declaration, notifications/claude/channel event format with content/meta params, reply tool with MCP ListToolsRequestSchema/CallToolRequestSchema, sender gating/allowlist, permission relay with claude/channel/permission capability and permission_request/permission notifications with request_id/tool_name/description/input_preview fields, verdict allow/deny format, package as plugin), extensibility overview (CLAUDE.md/Skills/MCP/Subagents/Agent teams/Hooks/Plugins feature comparison, feature-to-goal matching table, Skill vs Subagent vs CLAUDE.md vs Rules vs Agent team vs MCP comparisons, feature layering and override rules, context costs by feature, context loading lifecycle). Load when discussing Claude Code model configuration, /model, model aliases, opusplan, effort levels, /effort, extended context, 1M context, fast mode, /fast, output styles, custom output styles, /config output style, status line, /statusline, statusLine setting, checkpointing, /rewind, Esc+Esc, rewind, restore code, summarize conversation, Remote Control, remote-control, --rc, /rc, remote sessions from phone, continue session from another device, scheduled tasks, /loop, cron, reminders, CronCreate, web scheduled tasks, /schedule, cloud tasks, recurring tasks, voice dictation, /voice, push-to-talk, speech-to-text, channels, --channels, Telegram channel, Discord channel, iMessage channel, channel reference, build channel, webhook receiver, channel MCP server, permission relay, feature comparison, extend Claude Code, extensibility overview, context costs, feature layering, or any Claude Code feature configuration topic.
user-invocable: false
---

# Features & Capabilities Documentation

This skill provides the complete official documentation for Claude Code features including model configuration, fast mode, output styles, status line, checkpointing, Remote Control, scheduled tasks, voice dictation, channels, and the extensibility overview.

## Quick Reference

### Model Configuration

**Model aliases** (always point to latest version):

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended model for your account type |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast, efficient Haiku for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus during plan mode, Sonnet for execution |

**Setting the model** (in priority order):

| Method | Example |
|:-------|:--------|
| During session | `/model sonnet` |
| At startup | `claude --model opus` |
| Environment variable | `ANTHROPIC_MODEL=opus` |
| Settings file | `"model": "opus"` |

**Restrict models** (managed/policy settings): `"availableModels": ["sonnet", "haiku"]` -- users cannot switch to models not in the list. The `default` option remains available regardless.

**Override model IDs** (third-party providers):

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for `opus` alias / `opusplan` plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` alias / `opusplan` execution |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for `haiku` alias / background tasks |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |

**`modelOverrides` setting**: maps individual Anthropic model IDs to provider-specific strings (Bedrock ARNs, Vertex version names, Foundry deployment names) for governance and routing per version.

**Custom model option**: `ANTHROPIC_CUSTOM_MODEL_OPTION="my-gateway/model-id"` adds a single entry to the `/model` picker (with optional `_NAME` and `_DESCRIPTION` suffixes).

**Prompt caching**: `DISABLE_PROMPT_CACHING=1` disables globally; per-model: `DISABLE_PROMPT_CACHING_HAIKU`, `DISABLE_PROMPT_CACHING_SONNET`, `DISABLE_PROMPT_CACHING_OPUS`.

### Effort Levels

Control adaptive reasoning depth. Lower effort is faster and cheaper; higher effort provides deeper reasoning.

| Level | Behavior | Persists |
|:------|:---------|:---------|
| `low` | Minimal thinking | Yes |
| `medium` | Balanced (Opus default for Max/Team) | Yes |
| `high` | Deep reasoning | Yes |
| `max` | Deepest, no token cap (Opus 4.6 only) | No (current session) |

**Setting effort** (in priority order): `CLAUDE_CODE_EFFORT_LEVEL` env var > `/effort <level>` or `/model` slider > `effortLevel` setting > model default. Skill/subagent frontmatter `effort` field overrides session level.

Disable adaptive reasoning: `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1` (reverts to fixed budget via `MAX_THINKING_TOKENS`).

### Extended Context (1M Tokens)

| Plan | Opus 4.6 1M | Sonnet 4.6 1M |
|:-----|:------------|:--------------|
| Max, Team, Enterprise | Included | Extra usage |
| Pro | Extra usage | Extra usage |
| API / pay-as-you-go | Full access | Full access |

Use `/model opus[1m]` or `/model sonnet[1m]`. Append `[1m]` to full model names too. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

### Fast Mode

2.5x faster Opus 4.6 at higher cost. Same model quality, lower latency.

| Detail | Value |
|:-------|:------|
| Toggle | `/fast` in CLI or VS Code |
| Pricing | $30 / $150 per MTok (input/output) |
| Persist setting | `"fastMode": true` in settings |
| Per-session opt-in | `"fastModePerSessionOptIn": true` (managed setting, resets each session) |
| Availability | Subscription plans + Console (not Bedrock/Vertex/Foundry) |
| Billing | Extra usage only, bypasses plan rate limits |
| Rate limit fallback | Auto-falls back to standard Opus; gray icon indicates cooldown |
| Disable entirely | `CLAUDE_CODE_DISABLE_FAST_MODE=1` |

Best for interactive work (rapid iteration, live debugging). Standard mode better for autonomous tasks, batch processing, cost-sensitive workloads.

### Output Styles

Modify Claude Code's system prompt to adapt behavior.

**Built-in styles:**

| Style | Behavior |
|:------|:---------|
| Default | Standard software engineering system prompt |
| Explanatory | Shares educational "Insights" while coding |
| Learning | Collaborative mode with `TODO(human)` markers for you to implement |

**Change style:** `/config` > Output style, or set `"outputStyle": "Explanatory"` in settings. Takes effect next session.

**Custom styles:** Markdown files in `~/.claude/output-styles/` (user) or `.claude/output-styles/` (project):

| Frontmatter | Purpose | Default |
|:------------|:--------|:--------|
| `name` | Display name | File name |
| `description` | Shown in `/config` picker | None |
| `keep-coding-instructions` | Keep coding parts of system prompt | `false` |

Custom styles exclude coding instructions by default. Set `keep-coding-instructions: true` to keep them.

### Status Line

Customizable bar at the bottom of Claude Code. Runs a shell script that receives JSON session data on stdin.

**Setup:**
- `/statusline show model name and context percentage` (auto-generates script)
- Or manually: set `"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}` in settings

**Available JSON data fields:**

| Field | Description |
|:------|:------------|
| `model.id`, `model.display_name` | Current model |
| `workspace.current_dir`, `workspace.project_dir` | Directories |
| `cost.total_cost_usd` | Session cost in USD |
| `cost.total_duration_ms`, `cost.total_api_duration_ms` | Timing |
| `cost.total_lines_added`, `cost.total_lines_removed` | Code changes |
| `context_window.used_percentage`, `context_window.remaining_percentage` | Context usage |
| `context_window.context_window_size` | Max tokens (200k or 1M) |
| `context_window.current_usage` | Last API call tokens (null before first call) |
| `rate_limits.five_hour.used_percentage`, `rate_limits.seven_day.used_percentage` | Rate limit usage |
| `session_id`, `transcript_path`, `version` | Session metadata |
| `output_style.name`, `vim.mode`, `agent.name` | State info |
| `worktree.name`, `worktree.path`, `worktree.branch` | Worktree info (when active) |

Updates after each assistant message, debounced at 300ms. Supports ANSI colors, multi-line output, and OSC 8 clickable links.

### Checkpointing

Automatic tracking of Claude's file edits for quick undo/rewind.

**Access:** Press `Esc` twice or run `/rewind` to open the rewind menu.

| Action | Effect |
|:-------|:-------|
| Restore code and conversation | Revert both to selected point |
| Restore conversation | Rewind messages, keep current code |
| Restore code | Revert files, keep conversation |
| Summarize from here | Compress messages from selected point forward into summary |

Checkpoints persist across sessions (cleaned after 30 days). Each user prompt creates a checkpoint. Bash command changes and external edits are not tracked. Complements but does not replace Git.

### Remote Control

Continue local Claude Code sessions from phone, tablet, or any browser via claude.ai/code or the Claude mobile app. Claude runs locally; remote devices are a window into that local session.

**Start methods:**

| Method | Command |
|:-------|:--------|
| Server mode | `claude remote-control` (dedicated server, waits for connections) |
| Interactive | `claude --remote-control` or `claude --rc` (full terminal + remote) |
| Existing session | `/remote-control` or `/rc` (carries over conversation) |

**Server mode flags:** `--name`, `--spawn same-dir\|worktree`, `--capacity <N>`, `--verbose`, `--sandbox`/`--no-sandbox`

**Connect:** Open session URL in browser, scan QR code, or find in claude.ai/code session list. Enable for all sessions via `/config`.

**Requirements:** Pro/Max/Team/Enterprise subscription (not API keys). Team/Enterprise admins must enable Remote Control toggle. Outbound HTTPS only, no inbound ports opened.

### Scheduled Tasks (Session-Scoped)

Session-scoped scheduling with `/loop` and natural language reminders. Tasks live in the current process and are gone when you exit.

**`/loop` syntax:**

| Form | Example | Interval |
|:-----|:--------|:---------|
| Leading token | `/loop 30m check the build` | Every 30 minutes |
| Trailing clause | `/loop check the build every 2 hours` | Every 2 hours |
| No interval | `/loop check the build` | Default: every 10 minutes |

Units: `s` (seconds, rounded up to 1m), `m` (minutes), `h` (hours), `d` (days).

**One-time reminders:** Natural language, e.g., `remind me at 3pm to push the release branch` or `in 45 minutes, check whether the integration tests passed`.

**Tools:** `CronCreate` (schedule), `CronList` (list), `CronDelete` (cancel by 8-char ID). Max 50 tasks per session.

**Behavior:** Fires between turns (waits if Claude is busy). Local timezone. Jitter: recurring tasks up to 10% of period late (capped 15 min); one-shot tasks up to 90s early at :00/:30. Three-day auto-expiry for recurring tasks.

Disable: `CLAUDE_CODE_DISABLE_CRON=1`.

### Web Scheduled Tasks (Cloud)

Recurring tasks on Anthropic-managed infrastructure. Run without your machine. Available to Pro, Max, Team, Enterprise.

**Create via:** claude.ai/code/scheduled (web), Desktop app Schedule page, or `/schedule` in CLI.

| Frequency | Description |
|:----------|:------------|
| Hourly | Every hour |
| Daily | Once per day (default 9:00 AM local) |
| Weekdays | Daily except Saturday/Sunday |
| Weekly | Once per week on chosen day/time |

Each run clones selected repos (default branch), runs in a cloud environment with configurable network access, env vars, and setup script. Claude pushes changes to `claude/`-prefixed branches. Include MCP connectors for external service access.

Manage: task detail page (Run now, pause/resume, edit, delete) or `/schedule list\|update\|run` in CLI.

### Scheduling Options Comparison

|  | Cloud | Desktop | `/loop` |
|:-|:------|:--------|:--------|
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Persistent | Yes | Yes | No (session-scoped) |
| Access to local files | No (fresh clone) | Yes | Yes |
| Minimum interval | 1 hour | 1 minute | 1 minute |

### Voice Dictation

Push-to-talk speech-to-text for prompt input. Enable with `/voice`. Requires claude.ai account and local microphone.

| Setting | Details |
|:--------|:--------|
| Toggle | `/voice` (persists across sessions) |
| Push-to-talk key | `Space` (hold to record, release to stop) |
| Rebind key | `~/.claude/keybindings.json` with `voice:pushToTalk` binding |
| Language | Uses `language` setting; defaults to English; 20 languages supported |
| Setting | `"voiceEnabled": true` in settings |

Modifier combos (e.g., `meta+k`) skip warmup delay and start recording immediately. Transcription tuned for coding vocabulary (regex, OAuth, JSON, localhost). Project name and git branch auto-added as hints.

### Channels

Push events from external systems (chat apps, webhooks, CI) into a running Claude Code session via MCP server plugins.

**Supported channels (research preview):** Telegram, Discord, iMessage, fakechat (localhost demo).

**Setup pattern:**
1. Install plugin: `/plugin install telegram@claude-plugins-official`
2. Configure credentials: `/telegram:configure <token>`
3. Restart with channel: `claude --channels plugin:telegram@claude-plugins-official`
4. Pair your account (Telegram/Discord) or text yourself (iMessage)

**Enterprise:** `channelsEnabled` in managed settings. Off by default for Team/Enterprise until admin enables.

**Security:** Sender allowlist per channel. Only paired/allowed IDs can push messages. Gate on sender identity, not room/chat.

### Channel Architecture (Building Custom)

A channel is an MCP server declaring `claude/channel` capability that emits `notifications/claude/channel` events.

| Capability | Purpose |
|:-----------|:--------|
| `claude/channel: {}` | Required. Registers notification listener |
| `claude/channel/permission: {}` | Optional. Enables permission relay |
| `tools: {}` | Two-way only. Exposes reply tool |

**Notification params:** `content` (event body as string) and `meta` (key-value attributes on the `<channel>` tag; keys must be identifiers with letters/digits/underscores only).

**Permission relay:** Server receives `notifications/claude/channel/permission_request` with `request_id`, `tool_name`, `description`, `input_preview`. Sends verdict back as `notifications/claude/channel/permission` with `request_id` and `behavior` (`allow`/`deny`).

Test custom channels: `claude --dangerously-load-development-channels server:<name>`.

### Extensibility Overview

| Feature | What it does | When to use |
|:--------|:-------------|:------------|
| CLAUDE.md | Persistent context every session | Project conventions, "always do X" rules |
| Skill | Instructions/knowledge/workflows on demand | Reference docs, repeatable tasks |
| Subagent | Isolated execution, returns summary | Context isolation, parallel tasks |
| Agent teams | Coordinate multiple independent sessions | Parallel research, competing hypotheses |
| MCP | Connect to external services | External data or actions |
| Hook | Deterministic script on events | Predictable automation, no LLM |
| Plugin | Bundle and distribute features | Reuse across repos, share with others |

**Feature layering:** CLAUDE.md files are additive (all levels contribute). Skills and subagents override by name (managed > user > project). MCP servers override by name (local > project > user). Hooks merge (all fire for matching events).

**Context costs:** CLAUDE.md loads every request. Skill descriptions load every request, full content on use. MCP tool definitions load every request. Subagents are isolated. Hooks cost zero unless returning context.

### Remote Access Approaches Comparison

| Approach | Trigger | Runs on | Best for |
|:---------|:--------|:--------|:---------|
| Dispatch | Mobile app task | Your machine (Desktop) | Delegating while away |
| Remote Control | Drive from browser/app | Your machine (CLI/VS Code) | Steering in-progress work |
| Channels | External events (chat, webhooks) | Your machine (CLI) | Reacting to CI failures, chat |
| Slack | @Claude in team channel | Anthropic cloud | PRs and reviews from team chat |
| Scheduled tasks | Set a schedule | CLI, Desktop, or cloud | Recurring automation |

## Full Documentation

For the complete official documentation, see the reference files:

- [Model configuration](references/claude-code-model-config.md) -- model aliases (default/sonnet/opus/haiku/sonnet[1m]/opus[1m]/opusplan), setting models via /model, --model, ANTHROPIC_MODEL, settings file, availableModels restriction, default model behavior by plan, opusplan hybrid mode, effort levels (low/medium/high/max with /effort, --effort, env var, settings, frontmatter), extended 1M context window by plan, ANTHROPIC_DEFAULT_*_MODEL env vars for third-party providers, modelOverrides for per-version provider ID mapping, ANTHROPIC_CUSTOM_MODEL_OPTION for /model picker, prompt caching configuration
- [Fast mode](references/claude-code-fast-mode.md) -- 2.5x faster Opus 4.6 at $30/150 MTok pricing, /fast toggle, fastMode setting, per-session opt-in with fastModePerSessionOptIn, extra usage billing, requirements (not Bedrock/Vertex/Foundry), admin enablement for Teams/Enterprise, rate limit fallback to standard Opus, research preview status, CLAUDE_CODE_DISABLE_FAST_MODE, fast mode vs effort level comparison
- [Output styles](references/claude-code-output-styles.md) -- built-in styles (Default/Explanatory/Learning), system prompt modification, custom output style Markdown files with name/description/keep-coding-instructions frontmatter, user and project output-styles directories, /config to change, outputStyle setting, comparison with CLAUDE.md and --append-system-prompt and Agents and Skills
- [Status line](references/claude-code-statusline.md) -- /statusline command for auto-generation, manual statusLine setting with type/command/padding, JSON stdin data schema (model, workspace, cost, context_window with current_usage/used_percentage/remaining_percentage, rate_limits, session_id, transcript_path, version, output_style, vim, agent, worktree), context window fields, ANSI colors, OSC 8 clickable links, multi-line output, update timing, examples (context bar, git status with colors, cost tracking, multi-line, Windows PowerShell), available data fields reference
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic edit tracking per user prompt, Esc+Esc or /rewind menu, restore code and conversation / restore conversation / restore code / summarize from here actions, persist across sessions, bash command and external changes not tracked, session-level recovery complementing Git
- [Remote Control](references/claude-code-remote-control.md) -- continue local sessions from phone/tablet/browser, claude remote-control server mode with --name/--spawn/--capacity/--verbose/--sandbox flags, claude --remote-control/--rc interactive mode, /remote-control or /rc from existing session, connect via URL/QR code/session list, enable for all sessions, HTTPS outbound-only security, requirements (subscription plans, Team/Enterprise admin toggle), vs Claude Code on the web, troubleshooting, comparison with Dispatch/Channels/Slack/Scheduled tasks
- [Scheduled tasks](references/claude-code-scheduled-tasks.md) -- session-scoped /loop skill with interval syntax, one-time reminders via natural language, CronCreate/CronList/CronDelete tools, cron expression reference, jitter and three-day expiry, CLAUDE_CODE_DISABLE_CRON, comparison with cloud and Desktop scheduling
- [Web scheduled tasks](references/claude-code-web-scheduled-tasks.md) -- cloud recurring tasks on Anthropic infrastructure, create via web/Desktop/CLI /schedule, frequency options (hourly/daily/weekdays/weekly), repository selection and branch permissions, cloud environment with network/env vars/setup scripts, MCP connectors, run management, /schedule CLI commands
- [Voice dictation](references/claude-code-voice-dictation.md) -- /voice toggle, hold Space push-to-talk with warmup, voiceEnabled setting, 20 supported languages, rebind push-to-talk in keybindings.json, coding vocabulary recognition, claude.ai account and local microphone required, troubleshooting
- [Channels](references/claude-code-channels.md) -- push events from Telegram/Discord/iMessage/fakechat into running session, --channels flag, plugin install and configure workflow, sender allowlists and pairing, channelsEnabled enterprise setting, --dangerously-load-development-channels for testing, vs web sessions/Slack/MCP/Remote Control comparison, research preview
- [Channels reference](references/claude-code-channels-reference.md) -- build custom channel MCP servers, claude/channel capability declaration, notifications/claude/channel event format with content/meta, reply tool via MCP SDK ListToolsRequestSchema/CallToolRequestSchema, sender gating, permission relay with claude/channel/permission capability and request_id/tool_name/description/input_preview fields, verdict allow/deny, webhook receiver walkthrough, package as plugin
- [Extend Claude Code](references/claude-code-features-overview.md) -- extensibility overview with CLAUDE.md/Skills/MCP/Subagents/Agent teams/Hooks/Plugins feature comparison, feature-to-goal matching table, detailed comparisons (Skill vs Subagent, CLAUDE.md vs Skill, CLAUDE.md vs Rules vs Skills, Subagent vs Agent team, MCP vs Skill), feature layering and override rules, combination patterns, context costs by feature, context loading lifecycle

## Sources

- Model configuration: https://code.claude.com/docs/en/model-config.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Extend Claude Code: https://code.claude.com/docs/en/features-overview.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Web scheduled tasks: https://code.claude.com/docs/en/web-scheduled-tasks.md
