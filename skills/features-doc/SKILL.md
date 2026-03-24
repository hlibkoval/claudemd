---
name: features-doc
description: Complete documentation for Claude Code features -- fast mode (toggle with /fast, 2.5x faster Opus 4.6 at $30/150 MTok, auto-fallback on rate limit, per-session opt-in with fastModePerSessionOptIn, CLAUDE_CODE_DISABLE_FAST_MODE), model configuration (aliases default/sonnet/opus/haiku/sonnet[1m]/opus[1m]/opusplan, /model command, --model flag, ANTHROPIC_MODEL env var, settings model field, availableModels allowlist, modelOverrides for provider-specific IDs, ANTHROPIC_DEFAULT_OPUS_MODEL/SONNET/HAIKU, CLAUDE_CODE_SUBAGENT_MODEL, effort levels low/medium/high/max/auto via /effort or --effort or effortLevel setting or CLAUDE_CODE_EFFORT_LEVEL, extended 1M context window, CLAUDE_CODE_DISABLE_1M_CONTEXT, CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING, ANTHROPIC_CUSTOM_MODEL_OPTION, prompt caching config DISABLE_PROMPT_CACHING), output styles (Default/Explanatory/Learning built-in styles, custom output styles as markdown files in ~/.claude/output-styles or .claude/output-styles, outputStyle setting, keep-coding-instructions frontmatter, /config to change), status line (statusLine setting with type command, /statusline command for generation, available JSON data fields model/cwd/cost/context_window/rate_limits/session_id/vim/agent/worktree, ANSI colors, OSC 8 clickable links, multi-line output, padding option, caching patterns), checkpointing (automatic edit tracking, Esc+Esc or /rewind to open menu, restore code/conversation/both or summarize from point, 30-day retention, bash and external changes not tracked), features overview (CLAUDE.md, Skills, MCP, Subagents, Agent teams, Hooks, Plugins, Marketplaces, context costs and loading, feature comparison tables), remote control (continue local sessions from phone/tablet/browser, claude remote-control server mode with --spawn/--capacity/--name, --remote-control or /remote-control for interactive sessions, QR codes, auto-reconnect, HTTPS outbound only), session-scoped scheduled tasks (/loop bundled skill with interval syntax, CronCreate/CronList/CronDelete tools, one-time reminders, 3-day expiry, jitter, CLAUDE_CODE_DISABLE_CRON), cloud scheduled tasks (web UI at claude.ai/code/scheduled, /schedule CLI, hourly/daily/weekdays/weekly frequencies, repository and branch permissions, connectors, environments), voice dictation (/voice toggle, hold Space push-to-talk, 20 supported languages, rebindable key via keybindings.json, voiceEnabled setting), channels (push events from Telegram/Discord/webhooks into sessions, --channels flag, plugin install, pairing and sender allowlists, channelsEnabled enterprise setting, research preview), channels reference (MCP server with claude/channel capability, notifications/claude/channel events, content and meta params, reply tools, sender gating, permission relay with claude/channel/permission capability, --dangerously-load-development-channels for testing). Load when discussing fast mode, /fast, model selection, model aliases, opusplan, effort levels, /effort, extended context, 1M context, output styles, status line, statusline, checkpointing, /rewind, features overview, extending Claude Code, remote control, /remote-control, scheduled tasks, /loop, /schedule, cloud scheduled tasks, voice dictation, /voice, push-to-talk, channels, Telegram channel, Discord channel, channel reference, building channels, webhook receiver, permission relay, model configuration, model overrides, availableModels, prompt caching, or any Claude Code feature topic.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features including fast mode, model configuration, output styles, status line, checkpointing, remote control, scheduled tasks, voice dictation, and channels.

## Quick Reference

### Fast Mode

Toggle with `/fast` for 2.5x faster Opus 4.6 responses at higher cost. Not a different model -- same quality, lower latency.

| Setting | Value |
|:--------|:------|
| Pricing | $30/150 MTok (input/output) |
| Toggle | `/fast` or `"fastMode": true` in settings |
| Availability | All subscription plans (Pro/Max/Team/Enterprise) and Console |
| Billing | Always billed to extra usage, never to plan quota |
| Rate limit fallback | Auto-falls back to standard Opus 4.6 with gray icon |
| Admin disable | `CLAUDE_CODE_DISABLE_FAST_MODE=1` or disable in admin panel |
| Per-session opt-in | `"fastModePerSessionOptIn": true` in managed settings |
| Indicator | Small `↯` icon next to prompt while active |
| Requires | Extra usage enabled, v2.1.36+, not available on Bedrock/Vertex/Foundry |

### Model Configuration

#### Model Aliases

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended model based on account type |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast Haiku for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context |
| `opus[1m]` | Opus with 1M token context |
| `opusplan` | Opus for planning, Sonnet for execution |

#### Setting the Model (priority order)

1. `/model <alias|name>` during session
2. `claude --model <alias|name>` at startup
3. `ANTHROPIC_MODEL=<alias|name>` env var
4. `"model": "<alias|name>"` in settings

#### Default Model per Plan

| Plan | Default |
|:-----|:--------|
| Max, Team Premium | Opus 4.6 |
| Pro, Team Standard | Sonnet 4.6 |
| Enterprise | Opus 4.6 available but not default |

#### Effort Levels

| Level | Behavior |
|:------|:---------|
| `low` | Less thinking, faster, cheaper |
| `medium` | Default for Opus on Max/Team |
| `high` | Deeper reasoning |
| `max` | Deepest reasoning, Opus 4.6 only, current session only |
| `auto` | Reset to model default |

Set via: `/effort <level>`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL` env var, `effortLevel` in settings, or `effort` in skill/subagent frontmatter. Env var takes highest precedence.

#### Extended Context (1M)

| Plan | Opus 1M | Sonnet 1M |
|:-----|:--------|:----------|
| Max, Team, Enterprise | Included | Requires extra usage |
| Pro | Requires extra usage | Requires extra usage |
| API / pay-as-you-go | Full access | Full access |

Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`. Use `/model opus[1m]` or `/model sonnet[1m]`.

#### Model Environment Variables

| Variable | Description |
|:---------|:------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for `opus` alias / `opusplan` plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` alias / `opusplan` execution |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for `haiku` alias / background tasks |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |
| `ANTHROPIC_CUSTOM_MODEL_OPTION` | Add custom entry to /model picker |
| `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` | Set to `1` to revert to fixed thinking budget |

#### Enterprise Model Controls

- `availableModels` in managed settings restricts user model choices
- `modelOverrides` maps Anthropic model IDs to provider-specific IDs (ARNs, deployment names)
- Both work together: allowlist evaluated against Anthropic ID, not override value

#### Prompt Caching

| Variable | Description |
|:---------|:------------|
| `DISABLE_PROMPT_CACHING` | Set `1` to disable for all models |
| `DISABLE_PROMPT_CACHING_HAIKU` | Set `1` for Haiku only |
| `DISABLE_PROMPT_CACHING_SONNET` | Set `1` for Sonnet only |
| `DISABLE_PROMPT_CACHING_OPUS` | Set `1` for Opus only |

### Output Styles

Built-in styles that modify Claude Code's system prompt:

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Adds educational "Insights" while coding |
| **Learning** | Collaborative mode with `TODO(human)` markers for you to implement |

Custom styles are markdown files with frontmatter stored in `~/.claude/output-styles/` (user) or `.claude/output-styles/` (project). Set via `/config` > Output style, or `"outputStyle": "StyleName"` in settings. Changes take effect on next session start.

| Frontmatter | Purpose | Default |
|:------------|:--------|:--------|
| `name` | Display name | File name |
| `description` | Shown in /config picker | None |
| `keep-coding-instructions` | Keep coding parts of system prompt | false |

### Status Line

Custom bar at bottom of Claude Code running any shell script. Configure in settings:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

Generate with `/statusline <description>`. Disable with `/statusline delete` or remove from settings.

#### Available JSON Data Fields

| Field | Description |
|:------|:------------|
| `model.id`, `model.display_name` | Current model |
| `cwd`, `workspace.current_dir`, `workspace.project_dir` | Directories |
| `cost.total_cost_usd` | Session cost in USD |
| `cost.total_duration_ms`, `cost.total_api_duration_ms` | Timing |
| `cost.total_lines_added`, `cost.total_lines_removed` | Code changes |
| `context_window.used_percentage`, `context_window.remaining_percentage` | Context usage |
| `context_window.context_window_size` | Max tokens (200K or 1M) |
| `context_window.current_usage.*` | Per-call token breakdown |
| `exceeds_200k_tokens` | Boolean threshold indicator |
| `rate_limits.five_hour.*`, `rate_limits.seven_day.*` | Rate limit usage and reset times |
| `session_id`, `transcript_path`, `version` | Session metadata |
| `output_style.name` | Current output style |
| `vim.mode` | Vim mode (when enabled) |
| `agent.name` | Agent name (when using --agent) |
| `worktree.name`, `worktree.path`, `worktree.branch` | Worktree info (when active) |

Script runs after each assistant message, debounced at 300ms. Supports ANSI colors, OSC 8 clickable links, and multiple output lines.

### Checkpointing

Automatic tracking of Claude's file edits for quick undo/rewind.

| Feature | Detail |
|:--------|:-------|
| Trigger | Every user prompt creates a checkpoint |
| Access | `Esc` + `Esc` or `/rewind` |
| Persistence | Across sessions, cleaned after 30 days |
| Actions | Restore code + conversation, restore conversation only, restore code only, summarize from point |

Limitations: bash command changes and external edits not tracked. Not a replacement for git.

### Features Overview (Extend Claude Code)

Extension features and when to use them:

| Feature | What it does | When to use |
|:--------|:-------------|:------------|
| **CLAUDE.md** | Persistent context every session | "Always do X" rules, conventions |
| **Skills** | Reusable knowledge and workflows | Reference docs, repeatable tasks |
| **Subagents** | Isolated execution, summarized results | Context isolation, parallel work |
| **Agent teams** | Multiple independent sessions | Parallel research, competing hypotheses |
| **MCP** | External service connections | Database queries, Slack, browser |
| **Hooks** | Deterministic scripts on events | ESLint after edits, auto-format |
| **Plugins** | Package and distribute features | Cross-repo reuse, distribution |

Context cost by feature: CLAUDE.md loads every request; skill descriptions load at start, full content on use; MCP tool definitions load at start (with Tool Search); subagents are isolated; hooks cost zero unless returning context.

### Remote Control

Continue local sessions from phone, tablet, or browser via claude.ai/code or Claude mobile app. Everything runs locally.

| Mode | Command | Description |
|:-----|:--------|:------------|
| Server mode | `claude remote-control` | Dedicated server waiting for connections |
| Interactive | `claude --remote-control` or `claude --rc` | Normal session with remote access |
| Existing session | `/remote-control` or `/rc` | Enable on running session |
| All sessions | `/config` > Enable Remote Control | Auto-enable for every session |

Server mode flags: `--name`, `--spawn <same-dir|worktree>`, `--capacity <N>`, `--verbose`, `--sandbox`/`--no-sandbox`.

Requirements: Pro/Max/Team/Enterprise subscription (no API keys), claude.ai OAuth login, v2.1.51+. Team/Enterprise must enable admin toggle.

### Session-Scoped Scheduled Tasks

Schedule recurring prompts within a session using `/loop` or natural language.

| Feature | Detail |
|:--------|:-------|
| `/loop 5m <prompt>` | Recurring prompt every 5 minutes |
| `/loop <prompt>` | Default: every 10 minutes |
| One-time | "remind me at 3pm to push the release" |
| Tools | `CronCreate`, `CronList`, `CronDelete` |
| Expiry | Recurring tasks auto-expire after 3 days |
| Disable | `CLAUDE_CODE_DISABLE_CRON=1` |

Interval units: `s` (seconds, rounded up to 1m), `m` (minutes), `h` (hours), `d` (days). Session-scoped only -- stops when you exit.

### Cloud Scheduled Tasks

Recurring tasks on Anthropic-managed infrastructure. Run without your machine.

| Feature | Detail |
|:--------|:-------|
| Create | Web: claude.ai/code/scheduled, Desktop: Schedule page, CLI: `/schedule` |
| Frequencies | Hourly, Daily (default 9am), Weekdays, Weekly |
| Repositories | Cloned fresh each run, `claude/`-prefixed branches by default |
| Connectors | MCP connectors included by default per task |
| Environments | Network access, env vars, setup scripts |
| Manage | `/schedule list`, `/schedule update`, `/schedule run` |

### Scheduling Options Comparison

| Feature | Cloud | Desktop | /loop |
|:--------|:------|:--------|:------|
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Persistent | Yes | Yes | No |
| Local file access | No | Yes | Yes |
| Minimum interval | 1 hour | 1 minute | 1 minute |

### Voice Dictation

Hold-to-speak voice input for prompts. Requires claude.ai account login, local mic, v2.1.69+.

| Setting | Detail |
|:--------|:-------|
| Toggle | `/voice` or `"voiceEnabled": true` in settings |
| Default key | Hold `Space` (brief warmup due to key-repeat detection) |
| Rebind | Set `voice:pushToTalk` in `~/.claude/keybindings.json` |
| Language | Uses `language` setting; defaults to English; 20 languages supported |
| Coding vocabulary | Tuned for dev terms (regex, OAuth, JSON, localhost) |

Modifier combos (e.g., `meta+k`) skip warmup and start recording on first keypress.

### Channels

Push events from Telegram, Discord, webhooks, or custom sources into a running Claude Code session.

| Feature | Detail |
|:--------|:-------|
| Enable | `--channels plugin:<name>@<marketplace>` at startup |
| Supported | Telegram, Discord, fakechat (demo) |
| Install | `/plugin install <channel>@claude-plugins-official` |
| Pairing | Send DM to bot, get code, run `/<channel>:access pair <code>` |
| Security | Sender allowlist per channel plugin |
| Enterprise | `channelsEnabled` in managed settings (off by default for Team/Enterprise) |
| Status | Research preview, requires v2.1.80+, claude.ai login |

### Channels Reference (Building Custom Channels)

A channel is an MCP server declaring the `claude/channel` capability that pushes `notifications/claude/channel` events.

| Server Option | Description |
|:--------------|:------------|
| `capabilities.experimental['claude/channel']` | Required `{}` -- registers notification listener |
| `capabilities.experimental['claude/channel/permission']` | Optional `{}` -- enables permission relay |
| `capabilities.tools` | Optional `{}` -- enables reply tools for two-way channels |
| `instructions` | System prompt text describing event format and reply behavior |

Notification params: `content` (string body) and `meta` (Record<string, string> tag attributes). Gate inbound messages on sender identity before emitting. For permission relay, handle `notifications/claude/channel/permission_request` (fields: `request_id`, `tool_name`, `description`, `input_preview`) and emit `notifications/claude/channel/permission` with `request_id` and `behavior` (`allow`/`deny`).

Test custom channels with `--dangerously-load-development-channels server:<name>`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Speed up responses with fast mode](references/claude-code-fast-mode.md) -- toggle fast mode, cost tradeoff ($30/150 MTok), fast mode vs effort level, requirements (extra usage, admin enablement), per-session opt-in (fastModePerSessionOptIn), rate limit fallback behavior, research preview status
- [Model configuration](references/claude-code-model-config.md) -- model aliases (default, sonnet, opus, haiku, sonnet[1m], opus[1m], opusplan), setting models via /model, --model, ANTHROPIC_MODEL, settings, availableModels enterprise allowlist, modelOverrides for provider-specific IDs, default model per plan, opusplan hybrid behavior, effort levels (low/medium/high/max/auto) via /effort and env vars, extended 1M context window availability per plan, ANTHROPIC_DEFAULT_OPUS/SONNET/HAIKU_MODEL, CLAUDE_CODE_SUBAGENT_MODEL, ANTHROPIC_CUSTOM_MODEL_OPTION, prompt caching config (DISABLE_PROMPT_CACHING), third-party deployment pinning
- [Output styles](references/claude-code-output-styles.md) -- built-in styles (Default, Explanatory, Learning), custom output styles as markdown with frontmatter (name, description, keep-coding-instructions), storage in ~/.claude/output-styles or .claude/output-styles, outputStyle setting, /config picker, comparison to CLAUDE.md, subagents, and skills
- [Customize your status line](references/claude-code-statusline.md) -- /statusline command, manual configuration (statusLine setting with type command), available JSON data fields (model, workspace, cost, context_window, rate_limits, session_id, vim, agent, worktree), ANSI color codes, OSC 8 clickable links, multi-line output, padding, caching patterns, examples (context bar, git status, cost tracking, rate limits), Windows configuration, Python/Node.js/Bash examples
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic edit tracking, Esc+Esc and /rewind menu, restore code/conversation/both, summarize from point (targeted /compact), limitations (bash and external changes not tracked), 30-day retention
- [Extend Claude Code](references/claude-code-features-overview.md) -- feature comparison table (CLAUDE.md, Skills, Subagents, Agent teams, MCP, Hooks, Plugins, Marketplaces), when to use each, feature layering and precedence, context cost by feature, loading strategies, combining features (Skill+MCP, Skill+Subagent, CLAUDE.md+Skills, Hook+MCP)
- [Continue local sessions from any device with Remote Control](references/claude-code-remote-control.md) -- server mode (claude remote-control with --name, --spawn, --capacity), interactive mode (--remote-control/--rc), /remote-control for existing sessions, QR codes, connection security (outbound HTTPS only), vs Claude Code on the web, auto-reconnect, Team/Enterprise admin toggle, troubleshooting
- [Run prompts on a schedule](references/claude-code-scheduled-tasks.md) -- /loop bundled skill with interval syntax (s/m/h/d), one-time reminders via natural language, CronCreate/CronList/CronDelete tools, 5-field cron expressions, jitter, 3-day expiry, CLAUDE_CODE_DISABLE_CRON, comparison of cloud vs Desktop vs /loop scheduling
- [Voice dictation](references/claude-code-voice-dictation.md) -- /voice toggle, hold Space push-to-talk with warmup, rebind to modifier combo via keybindings.json, 20 supported languages, voiceEnabled setting, coding vocabulary tuning, microphone requirements, troubleshooting
- [Push events into a running session with channels](references/claude-code-channels.md) -- Telegram and Discord setup, fakechat quickstart, --channels flag, plugin install and pairing, sender allowlists, channelsEnabled enterprise setting, security model, comparison to web sessions/Slack/MCP/Remote Control, research preview status
- [Channels reference](references/claude-code-channels-reference.md) -- building custom channels as MCP servers, claude/channel capability, notification format (content, meta), reply tools, sender gating, permission relay (claude/channel/permission capability, request fields, verdict format), --dangerously-load-development-channels, webhook receiver walkthrough, full TypeScript examples
- [Schedule tasks on the web](references/claude-code-web-scheduled-tasks.md) -- cloud scheduled tasks on Anthropic infrastructure, web UI at claude.ai/code/scheduled, /schedule CLI, frequency options (hourly/daily/weekdays/weekly), repository and branch permissions, connectors, environments, managing and editing tasks, comparison of scheduling options

## Sources

- Speed up responses with fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Customize your status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Extend Claude Code: https://code.claude.com/docs/en/features-overview.md
- Continue local sessions from any device with Remote Control: https://code.claude.com/docs/en/remote-control.md
- Run prompts on a schedule: https://code.claude.com/docs/en/scheduled-tasks.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Push events into a running session with channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Schedule tasks on the web: https://code.claude.com/docs/en/web-scheduled-tasks.md
