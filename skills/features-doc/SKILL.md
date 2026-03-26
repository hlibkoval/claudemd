---
name: features-doc
description: Complete documentation for Claude Code features -- fast mode (2.5x faster Opus 4.6 via /fast toggle, $30/150 MTok pricing, extra usage required, fastModePerSessionOptIn, rate limit fallback to standard), model configuration (model aliases default/sonnet/opus/haiku/sonnet[1m]/opus[1m]/opusplan, /model and --model and ANTHROPIC_MODEL, availableModels restriction, opusplan hybrid plan/execute, effort levels low/medium/high/max with /effort and --effort and CLAUDE_CODE_EFFORT_LEVEL and effortLevel setting, adaptive reasoning, extended context 1M tokens with [1m] suffix, ANTHROPIC_DEFAULT_OPUS/SONNET/HAIKU_MODEL env vars for third-party pinning, _NAME/_DESCRIPTION/_SUPPORTED_CAPABILITIES suffixes, modelOverrides setting, prompt caching DISABLE_PROMPT_CACHING vars, ANTHROPIC_CUSTOM_MODEL_OPTION), output styles (Default/Explanatory/Learning built-in, custom styles in ~/.claude/output-styles or .claude/output-styles, outputStyle setting, keep-coding-instructions frontmatter, system prompt modification), status line (statusLine setting with type command and command path, /statusline command, JSON session data on stdin with model/cost/context_window/rate_limits/vim/agent/worktree fields, jq parsing, ANSI colors, multi-line output, padding option, updates after assistant messages debounced 300ms), checkpointing (automatic edit tracking per prompt, Esc+Esc or /rewind to open rewind menu, restore code/conversation/both or summarize from point, 30-day cleanup, bash and external changes not tracked), features overview (extension layer -- CLAUDE.md persistent context, skills on-demand knowledge, MCP external connections, subagents isolated workers, agent teams parallel sessions, hooks deterministic scripts, plugins packaging layer, context cost comparison), remote control (continue local sessions from claude.ai/code or mobile app, claude remote-control server mode with --name/--spawn/--capacity/--verbose/--sandbox flags, claude --remote-control interactive mode, /remote-control from existing session, QR code pairing, /mobile for app download, outbound HTTPS only no inbound ports, TLS transport), scheduled tasks (/loop bundled skill for recurring prompts with interval syntax s/m/h/d, CronCreate/CronList/CronDelete tools, session-scoped 3-day expiry, one-time reminders in natural language, cron expression reference, CLAUDE_CODE_DISABLE_CRON, jitter on fire times), voice dictation (/voice toggle, hold Space push-to-talk with warmup, modifier rebind via keybindings.json for instant recording, streaming transcription tuned for coding vocabulary, 20 supported languages via language setting, voiceEnabled setting, requires claude.ai auth and local microphone), channels (push events into running session via MCP server, Telegram/Discord/iMessage plugins, --channels flag, sender allowlists and pairing, channelsEnabled and allowedChannelPlugins enterprise controls, research preview), channels reference (build custom channel MCP servers, claude/channel capability declaration, notifications/claude/channel events with content and meta params, reply tool for two-way channels, permission relay with claude/channel/permission capability, --dangerously-load-development-channels for testing), web scheduled tasks (cloud scheduled tasks on Anthropic infrastructure, /schedule command, claude.ai/code/scheduled web UI, frequency hourly/daily/weekdays/weekly, repository cloning with claude/ branch prefix, cloud environments with network/env vars/setup scripts, MCP connectors per task). Load when discussing fast mode, /fast, model configuration, /model, model aliases, opusplan, effort levels, /effort, extended context, 1M context, output styles, /config output style, status line, /statusline, statusLine setting, checkpointing, /rewind, checkpoint restore, features overview, extension comparison, remote control, /remote-control, /rc, scheduled tasks, /loop, /schedule, cron scheduling, voice dictation, /voice, push-to-talk, channels, --channels, channel plugins, Telegram bot, Discord bot, iMessage channel, web scheduled tasks, cloud tasks, or any Claude Code feature configuration topic.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features -- fast mode, model configuration, output styles, status line, checkpointing, extension overview, remote control, scheduled tasks, voice dictation, channels, and web scheduled tasks.

## Quick Reference

### Fast Mode

Toggle with `/fast` for 2.5x faster Opus 4.6 responses at higher cost. Not a different model -- same quality, different API configuration.

| Setting | Value |
|:--------|:------|
| Toggle | `/fast` command or `"fastMode": true` in settings |
| Pricing | $30 input / $150 output per MTok (flat across 1M context) |
| Availability | Pro/Max/Team/Enterprise subscriptions and Console (extra usage only) |
| Indicator | `↯` icon next to prompt while active |
| Rate limit fallback | Auto-falls back to standard Opus 4.6, `↯` turns gray during cooldown |
| Per-session reset | `"fastModePerSessionOptIn": true` in managed settings |
| Disable entirely | `CLAUDE_CODE_DISABLE_FAST_MODE=1` |

Not available on Bedrock, Vertex AI, or Foundry. Teams/Enterprise: admin must enable in Claude Code preferences.

### Model Configuration

#### Model Aliases

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended model for your account type (Opus on Max/Team Premium, Sonnet on Pro/Team Standard) |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast Haiku for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus for planning, Sonnet for execution |

#### Setting the Model

| Method | Priority | Example |
|:-------|:---------|:--------|
| During session | 1 (highest) | `/model sonnet` |
| At startup | 2 | `claude --model opus` |
| Environment variable | 3 | `ANTHROPIC_MODEL=opus` |
| Settings file | 4 (lowest) | `"model": "opus"` in settings |

#### Effort Levels

| Level | Behavior | Persists |
|:------|:---------|:---------|
| `low` | Less thinking, faster | Yes |
| `medium` | Default balance | Yes |
| `high` | Deeper reasoning | Yes |
| `max` | Deepest reasoning, no token spending constraint (Opus 4.6 only) | No (session only) |

Set via `/effort <level>`, `--effort <level>`, `CLAUDE_CODE_EFFORT_LEVEL`, `effortLevel` in settings, or skill/subagent `effort` frontmatter. Use "ultrathink" in a prompt for one-off high effort.

#### Extended Context (1M Tokens)

| Plan | Opus 4.6 1M | Sonnet 4.6 1M |
|:-----|:------------|:--------------|
| Max, Team, Enterprise | Included | Extra usage |
| Pro | Extra usage | Extra usage |
| API/pay-as-you-go | Full access | Full access |

Use `/model opus[1m]` or `/model sonnet[1m]`. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

#### Model Pinning for Third-Party Providers

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Pin Opus alias to specific model ID |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Pin Sonnet alias to specific model ID |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Pin Haiku alias to specific model ID |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Pin subagent model |
| `ANTHROPIC_CUSTOM_MODEL_OPTION` | Add custom entry to `/model` picker |

Add `_NAME`, `_DESCRIPTION`, `_SUPPORTED_CAPABILITIES` suffixes to customize display and declare capabilities (`effort`, `max_effort`, `thinking`, `adaptive_thinking`, `interleaved_thinking`).

Use `modelOverrides` setting to map individual model IDs to provider-specific strings (e.g., Bedrock ARNs). Use `availableModels` in managed settings to restrict which models users can select.

#### Prompt Caching

| Variable | Effect |
|:---------|:-------|
| `DISABLE_PROMPT_CACHING` | Disable for all models |
| `DISABLE_PROMPT_CACHING_HAIKU` | Disable for Haiku only |
| `DISABLE_PROMPT_CACHING_SONNET` | Disable for Sonnet only |
| `DISABLE_PROMPT_CACHING_OPUS` | Disable for Opus only |

### Output Styles

Built-in styles modify Claude Code's system prompt:

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Provides educational "Insights" between tasks |
| **Learning** | Collaborative learn-by-doing mode with `TODO(human)` markers |

Change via `/config` > Output style, or set `"outputStyle": "Explanatory"` in settings. Custom styles: markdown files with frontmatter (`name`, `description`, `keep-coding-instructions`) in `~/.claude/output-styles` (user) or `.claude/output-styles` (project). Changes take effect on next session start.

### Status Line

Custom shell-script-driven status bar at the bottom of Claude Code. Configure with `/statusline <description>` or manually in settings:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

Script receives JSON on stdin with fields: `model.id`, `model.display_name`, `cwd`, `workspace.current_dir`, `workspace.project_dir`, `cost.total_cost_usd`, `cost.total_duration_ms`, `cost.total_api_duration_ms`, `cost.total_lines_added`, `cost.total_lines_removed`, `context_window.used_percentage`, `context_window.remaining_percentage`, `context_window.context_window_size`, `context_window.current_usage.*`, `exceeds_200k_tokens`, `rate_limits.five_hour.*`, `rate_limits.seven_day.*`, `session_id`, `transcript_path`, `version`, `output_style.name`, `vim.mode`, `agent.name`, `worktree.*`.

Updates after each assistant message (debounced 300ms). Supports ANSI colors, multi-line output, and OSC 8 clickable links. Does not consume API tokens.

### Checkpointing

Automatically tracks file edits per prompt. Access via `Esc` + `Esc` or `/rewind`:

| Action | Effect |
|:-------|:-------|
| Restore code and conversation | Revert both to selected point |
| Restore conversation | Rewind messages, keep current code |
| Restore code | Revert files, keep conversation |
| Summarize from here | Compress messages from point forward into summary |

Checkpoints persist across sessions (30-day cleanup). Bash command changes and external edits are not tracked. Not a replacement for git.

### Features Overview (Extension Layer)

| Feature | What it does | When to use |
|:--------|:-------------|:------------|
| CLAUDE.md | Persistent context every session | Project conventions, "always do X" rules |
| Skill | On-demand knowledge and workflows | Reference docs, repeatable tasks with `/<name>` |
| MCP | Connect to external services | Databases, Slack, browser control |
| Subagent | Isolated execution context | Context isolation, parallel tasks |
| Agent teams | Coordinate multiple sessions | Parallel research, competing hypotheses |
| Hook | Deterministic script on events | Linting after edit, logging |
| Plugin | Package and distribute features | Reuse across repos, distribute via marketplace |

Features layer: CLAUDE.md additive, skills/subagents override by name, MCP overrides by name (local > project > user), hooks merge (all fire).

### Remote Control

Continue local sessions from claude.ai/code or Claude mobile app. Session runs locally; web/mobile is a window into it.

| Method | Command |
|:-------|:--------|
| Server mode | `claude remote-control` (with `--name`, `--spawn same-dir/worktree`, `--capacity <N>`, `--verbose`, `--sandbox/--no-sandbox`) |
| Interactive + remote | `claude --remote-control` or `claude --rc` |
| From existing session | `/remote-control` or `/rc` |
| Enable for all sessions | `/config` > Enable Remote Control for all sessions |

Connect via session URL, QR code (press spacebar in server mode), or find in session list at claude.ai/code. Outbound HTTPS only, no inbound ports. Available on Pro/Max/Team/Enterprise (admin must enable on Team/Enterprise). Not available with API keys or third-party providers.

### Scheduled Tasks (Session-Scoped)

`/loop` schedules recurring prompts within a session. Tasks are session-scoped and gone when you exit.

```
/loop 5m check if the deployment finished
/loop 20m /review-pr 1234
```

| Interval syntax | Example | Parsed |
|:----------------|:--------|:-------|
| Leading token | `/loop 30m check the build` | Every 30 minutes |
| Trailing `every` | `/loop check the build every 2 hours` | Every 2 hours |
| No interval | `/loop check the build` | Every 10 minutes (default) |

Units: `s` (seconds, rounded up to 1min), `m` (minutes), `h` (hours), `d` (days). One-time reminders via natural language ("remind me at 3pm to push the release branch"). Tasks fire between turns (low priority), 3-day auto-expiry, local timezone, deterministic jitter. Disable: `CLAUDE_CODE_DISABLE_CRON=1`.

### Web Scheduled Tasks (Cloud)

Run prompts on Anthropic-managed infrastructure. Tasks persist across restarts; no machine needed.

| Method | How |
|:-------|:----|
| Web | claude.ai/code/scheduled > New scheduled task |
| Desktop | Schedule page > New task > New remote task |
| CLI | `/schedule` or `/schedule daily PR review at 9am` |

| Frequency | Description |
|:----------|:------------|
| Hourly | Every hour |
| Daily | Once/day at specified time (default 9 AM local) |
| Weekdays | Daily, skipping Saturday and Sunday |
| Weekly | Once/week on specified day and time |

Each run clones repos (default branch), creates `claude/`-prefixed branches, uses cloud environments (network/env vars/setup scripts), and includes MCP connectors. Manage with `/schedule list`, `/schedule update`, `/schedule run`.

### Voice Dictation

Hold-to-speak input. Enable with `/voice`, persists across sessions.

| Setting | Value |
|:--------|:------|
| Toggle | `/voice` or `"voiceEnabled": true` in settings |
| Default key | Hold `Space` (brief warmup from key-repeat detection) |
| Instant recording | Rebind to modifier combo (e.g., `meta+k`) in `~/.claude/keybindings.json` |
| Language | Uses `language` setting; defaults to English; 20 languages supported |
| Requirements | Claude.ai auth, local microphone (no SSH/remote), v2.1.69+ |

Transcription tuned for coding vocabulary. Project name and git branch added as recognition hints. Text inserted at cursor position; mix voice and typing freely.

### Channels

Push events from external systems (Telegram, Discord, iMessage) into a running session via MCP servers.

| Channel | Setup |
|:--------|:------|
| Telegram | `/plugin install telegram@claude-plugins-official`, configure token, `--channels plugin:telegram@claude-plugins-official` |
| Discord | `/plugin install discord@claude-plugins-official`, configure token, `--channels plugin:discord@claude-plugins-official` |
| iMessage | `/plugin install imessage@claude-plugins-official`, grant Full Disk Access, `--channels plugin:imessage@claude-plugins-official` |
| fakechat (demo) | `/plugin install fakechat@claude-plugins-official`, localhost:8787 web UI |

Security: sender allowlists with pairing codes (Telegram/Discord) or handle-based access (iMessage). Enterprise: `channelsEnabled` master switch, `allowedChannelPlugins` to restrict which plugins can register. Research preview; requires Bun runtime.

#### Building Custom Channels

MCP servers declaring `claude/channel` capability. Emit `notifications/claude/channel` with `content` (string body) and `meta` (Record<string, string> attributes). Two-way channels expose a reply tool via standard MCP `tools` capability. Permission relay via `claude/channel/permission` capability. Test with `--dangerously-load-development-channels server:<name>`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Fast Mode](references/claude-code-fast-mode.md) -- Toggle 2.5x faster Opus 4.6 responses with /fast, pricing, requirements, per-session opt-in, rate limit fallback
- [Model Configuration](references/claude-code-model-config.md) -- Model aliases, /model command, effort levels, extended context, third-party provider pinning, modelOverrides, availableModels, prompt caching
- [Output Styles](references/claude-code-output-styles.md) -- Built-in styles (Default/Explanatory/Learning), custom output style files, outputStyle setting, keep-coding-instructions
- [Status Line](references/claude-code-statusline.md) -- Custom status bar configuration, /statusline command, JSON session data schema, examples with jq/Python/Node, ANSI colors, multi-line output
- [Checkpointing](references/claude-code-checkpointing.md) -- Automatic edit tracking, Esc+Esc and /rewind menu, restore code/conversation/both, summarize from point, limitations
- [Features Overview](references/claude-code-features-overview.md) -- Extension layer comparison (CLAUDE.md, skills, MCP, subagents, agent teams, hooks, plugins), context costs, feature layering and combination patterns
- [Remote Control](references/claude-code-remote-control.md) -- Continue local sessions from claude.ai/code or mobile, server mode and interactive mode, QR pairing, connection security, comparison with Claude Code on the web
- [Scheduled Tasks](references/claude-code-scheduled-tasks.md) -- /loop for session-scoped recurring prompts, interval syntax, CronCreate/CronList/CronDelete tools, one-time reminders, cron expressions, jitter, 3-day expiry
- [Voice Dictation](references/claude-code-voice-dictation.md) -- Push-to-talk with /voice, hold Space recording, modifier rebind, streaming transcription, 20 supported languages, troubleshooting
- [Channels](references/claude-code-channels.md) -- Push events into sessions via Telegram/Discord/iMessage plugins, sender allowlists, enterprise controls, comparison with other remote features
- [Channels Reference](references/claude-code-channels-reference.md) -- Build custom channel MCP servers, claude/channel capability, notification format, reply tools, permission relay, server options
- [Web Scheduled Tasks](references/claude-code-web-scheduled-tasks.md) -- Cloud scheduled tasks on Anthropic infrastructure, /schedule CLI, web UI, frequency options, repository and branch permissions, environments, connectors

## Sources

- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled Tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Voice Dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels Reference: https://code.claude.com/docs/en/channels-reference.md
- Web Scheduled Tasks: https://code.claude.com/docs/en/web-scheduled-tasks.md
