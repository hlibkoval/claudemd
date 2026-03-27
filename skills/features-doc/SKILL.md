---
name: features-doc
description: Complete documentation for Claude Code features -- model configuration (aliases default/sonnet/opus/haiku/sonnet[1m]/opus[1m]/opusplan, /model command, availableModels restriction, modelOverrides, ANTHROPIC_MODEL, ANTHROPIC_DEFAULT_OPUS_MODEL, ANTHROPIC_DEFAULT_SONNET_MODEL, ANTHROPIC_DEFAULT_HAIKU_MODEL, ANTHROPIC_CUSTOM_MODEL_OPTION, prompt caching DISABLE_PROMPT_CACHING), effort levels (low/medium/high/max, /effort command, CLAUDE_CODE_EFFORT_LEVEL, ultrathink, adaptive reasoning CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING), extended context (1M token context window, opus[1m]/sonnet[1m], CLAUDE_CODE_DISABLE_1M_CONTEXT), fast mode (/fast toggle, Opus 4.6 2.5x faster, $30/$150 MTok pricing, fastModePerSessionOptIn, CLAUDE_CODE_DISABLE_FAST_MODE, rate limit fallback), output styles (Default/Explanatory/Learning, custom output styles, /config, outputStyle setting, keep-coding-instructions frontmatter, ~/.claude/output-styles, .claude/output-styles), status line (/statusline command, custom shell script, JSON session data via stdin, model/cost/context_window/rate_limits/vim/agent/worktree fields, ANSI colors, multi-line, clickable OSC 8 links, Windows PowerShell/Git Bash), checkpointing (automatic file edit tracking, Esc+Esc or /rewind, restore code/conversation/both, summarize from here, session-level undo), features overview (extension comparison table -- CLAUDE.md vs Skills vs Subagents vs Agent teams vs MCP vs Hooks, context costs, feature loading and layering, combining features), Remote Control (claude remote-control, --remote-control/--rc flag, /remote-control command, server mode with --spawn/--capacity, QR code, claude.ai/code, Claude mobile app, connection security, Remote Control vs Claude Code on the web, Dispatch vs Channels vs Slack vs Scheduled tasks comparison), scheduled tasks (/loop command with interval syntax, CronCreate/CronList/CronDelete tools, session-scoped, one-time reminders, 3-day expiry, jitter, CLAUDE_CODE_DISABLE_CRON), cloud scheduled tasks (web-scheduled-tasks, /schedule command, claude.ai/code/scheduled, frequency options hourly/daily/weekdays/weekly, repositories and branch permissions, connectors, cloud environments), voice dictation (/voice toggle, hold Space push-to-talk, streaming speech-to-text, voiceEnabled setting, dictation language, rebind push-to-talk key in keybindings.json, coding vocabulary recognition), channels (push events into running session, Telegram/Discord/iMessage/fakechat, --channels flag, plugin installation, pairing/allowlist security, channelsEnabled/allowedChannelPlugins enterprise settings, research preview), channels reference (build custom channel MCP server, claude/channel capability, notifications/claude/channel, reply tools, sender gating, permission relay claude/channel/permission, webhook receiver example), context window explorer (interactive simulation of context loading -- system prompt, MEMORY.md, environment info, MCP tools, skill descriptions, CLAUDE.md, file reads, path-scoped rules, hooks, /compact). Load when discussing Claude Code model selection, model switching, model aliases, /model, opusplan, effort levels, /effort, ultrathink, adaptive reasoning, extended context, 1M context, fast mode, /fast, output styles, Explanatory mode, Learning mode, status line, /statusline, statusLine setting, checkpointing, /rewind, undo changes, restore code, features overview, extension comparison, Remote Control, remote-control, /rc, working from phone, claude.ai/code, scheduled tasks, /loop, cron, /schedule, cloud tasks, web scheduled tasks, voice dictation, /voice, push-to-talk, channels, Telegram channel, Discord channel, iMessage channel, fakechat, webhook receiver, channel reference, context window, context usage, or any Claude Code feature configuration topic.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features -- covering model configuration, effort levels, fast mode, output styles, status line, checkpointing, Remote Control, scheduled tasks, voice dictation, channels, and the context window explorer.

## Quick Reference

### Model Configuration

**Model aliases:**

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended model for your account type (Opus 4.6 for Max/Team Premium; Sonnet 4.6 for Pro/Team Standard) |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast Haiku for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus for plan mode, Sonnet for execution |

**Setting your model (priority order):**

1. `/model <alias|name>` during session
2. `claude --model <alias|name>` at startup
3. `ANTHROPIC_MODEL=<alias|name>` environment variable
4. `model` field in settings file

**Restrict model selection:** set `availableModels` in managed/policy settings to limit which models users can switch to. The `default` option always remains available regardless of `availableModels`.

**Override model IDs per version:** use `modelOverrides` in settings to map Anthropic model IDs to provider-specific strings (Bedrock ARNs, Vertex version names, Foundry deployment names).

**Custom model option:** set `ANTHROPIC_CUSTOM_MODEL_OPTION` to add a single custom entry to the `/model` picker without replacing built-in aliases.

**Model alias environment variables:**

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Pin Opus version (or opusplan plan mode) |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Pin Sonnet version (or opusplan execution) |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Pin Haiku version (or background functionality) |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |

For third-party providers, companion `_NAME`, `_DESCRIPTION`, and `_SUPPORTED_CAPABILITIES` suffixes customize display and declare features (`effort`, `max_effort`, `thinking`, `adaptive_thinking`, `interleaved_thinking`).

**Prompt caching:** enabled by default. Disable with `DISABLE_PROMPT_CACHING=1` (all models) or per-model: `DISABLE_PROMPT_CACHING_HAIKU`, `DISABLE_PROMPT_CACHING_SONNET`, `DISABLE_PROMPT_CACHING_OPUS`.

### Effort Levels

| Level | Behavior |
|:------|:---------|
| `low` | Faster, cheaper; less thinking time |
| `medium` | Default for Opus 4.6 and Sonnet 4.6; recommended for most coding tasks |
| `high` | Deeper reasoning for complex problems |
| `max` | Deepest reasoning, no token spending constraint; Opus 4.6 only; does not persist across sessions |

**Setting effort:**

| Method | Syntax |
|:-------|:-------|
| `/effort` command | `/effort low`, `/effort medium`, `/effort high`, `/effort max`, `/effort auto` |
| `/model` picker | Left/right arrow keys adjust effort slider |
| `--effort` flag | `claude --effort high` (single session) |
| Environment variable | `CLAUDE_CODE_EFFORT_LEVEL=low|medium|high|max|auto` (highest priority) |
| Settings file | `effortLevel` field |
| Skill/subagent frontmatter | `effort` field overrides session level |

For one-off deep reasoning, include "ultrathink" in your prompt to trigger high effort for that turn.

Disable adaptive reasoning: `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1` (reverts to fixed `MAX_THINKING_TOKENS` budget).

### Extended Context (1M Tokens)

Opus 4.6 and Sonnet 4.6 support 1M token context windows.

| Plan | Opus 4.6 1M | Sonnet 4.6 1M |
|:-----|:------------|:--------------|
| Max, Team, Enterprise | Included with subscription | Requires extra usage |
| Pro | Requires extra usage | Requires extra usage |
| API / pay-as-you-go | Full access | Full access |

Enable with `/model opus[1m]` or `/model sonnet[1m]`, or append `[1m]` to full model names. On Max/Team/Enterprise, Opus auto-upgrades to 1M with no config needed.

Disable: `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

### Fast Mode

Fast mode is a high-speed configuration for Opus 4.6, making it 2.5x faster at higher per-token cost. Toggle with `/fast`. Research preview.

| Mode | Input (MTok) | Output (MTok) |
|:-----|:-------------|:--------------|
| Fast mode on Opus 4.6 | $30 | $150 |

- Available to all subscription plans (Pro/Max/Team/Enterprise) and Console via extra usage only
- Switching mid-conversation pays full fast mode uncached input price for entire context
- Rate limit fallback: auto-falls back to standard Opus when limits hit; re-enables on cooldown
- Per-session opt-in: set `fastModePerSessionOptIn: true` in managed settings to reset each session
- Disable entirely: `CLAUDE_CODE_DISABLE_FAST_MODE=1`
- Teams/Enterprise: admin must enable in Console or Claude AI admin settings

### Output Styles

Output styles modify Claude Code's system prompt. Change via `/config` > Output style, or set `outputStyle` in settings.

| Style | Description |
|:------|:------------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Educational "Insights" between coding tasks |
| **Learning** | Collaborative mode with `TODO(human)` markers for you to implement |

**Custom output styles:** Markdown files with frontmatter in `~/.claude/output-styles` (user) or `.claude/output-styles` (project).

| Frontmatter | Purpose | Default |
|:------------|:--------|:--------|
| `name` | Display name | File name |
| `description` | Shown in `/config` picker | None |
| `keep-coding-instructions` | Keep coding-specific system prompt parts | false |

Changes take effect on next session start (system prompt is stable per session for caching).

### Status Line

Custom shell-script status bar at the bottom of Claude Code. Configure via `/statusline` (natural language) or manually.

**Settings:**
```
"statusLine": { "type": "command", "command": "~/.claude/statusline.sh", "padding": 2 }
```

**Available JSON data (via stdin):**

| Field | Description |
|:------|:------------|
| `model.id`, `model.display_name` | Current model |
| `cwd`, `workspace.current_dir`, `workspace.project_dir` | Directories |
| `cost.total_cost_usd` | Session cost in USD |
| `cost.total_duration_ms`, `cost.total_api_duration_ms` | Timing |
| `cost.total_lines_added`, `cost.total_lines_removed` | Lines changed |
| `context_window.used_percentage`, `context_window.remaining_percentage` | Context usage |
| `context_window.context_window_size` | Max context (200K or 1M) |
| `context_window.current_usage` | Token counts from last API call |
| `rate_limits.five_hour.used_percentage`, `rate_limits.seven_day.used_percentage` | Rate limit usage |
| `session_id`, `transcript_path`, `version` | Session metadata |
| `output_style.name`, `vim.mode`, `agent.name` | Active configuration |
| `worktree.name`, `worktree.path`, `worktree.branch` | Worktree info (when active) |

Updates after each assistant message (debounced 300ms). Supports ANSI colors, multiple lines, and OSC 8 clickable links.

### Checkpointing

Automatic file edit tracking with session-level undo.

- Every user prompt creates a checkpoint; persists across sessions
- Open with `Esc` + `Esc` or `/rewind`
- **Restore code and conversation**: revert both to that point
- **Restore conversation**: rewind messages, keep current code
- **Restore code**: revert files, keep conversation
- **Summarize from here**: compress conversation from that point (frees context; no file changes)

Limitations: bash command changes not tracked; external changes not tracked; not a replacement for Git.

### Remote Control

Continue local sessions from any device via claude.ai/code or Claude mobile app.

| Method | Command | Description |
|:-------|:--------|:------------|
| Server mode | `claude remote-control` | Dedicated server, multiple concurrent sessions |
| Interactive | `claude --remote-control` or `claude --rc` | Normal session with remote access |
| From existing session | `/remote-control` or `/rc` | Enable on running session |
| Always-on | `/config` > Enable Remote Control for all sessions | Auto-enable every session |

**Server mode flags:**

| Flag | Purpose |
|:-----|:--------|
| `--name "Title"` | Custom session title |
| `--spawn <mode>` | `same-dir` (default) or `worktree` for concurrent sessions |
| `--capacity <N>` | Max concurrent sessions (default 32) |
| `--verbose` | Detailed logs |
| `--sandbox` / `--no-sandbox` | Filesystem/network isolation |

Available on Pro/Max/Team/Enterprise (claude.ai auth required). Team/Enterprise: admin must enable in admin settings.

### Scheduling Options Comparison

|  | Cloud | Desktop | `/loop` |
|:-|:------|:--------|:--------|
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Persistent across restarts | Yes | Yes | No (session-scoped) |
| Access to local files | No (fresh clone) | Yes | Yes |
| Minimum interval | 1 hour | 1 minute | 1 minute |

### Session-Scoped Scheduled Tasks (/loop)

Quick recurring prompts within a session. Interval syntax: `/loop 5m check the build`, `/loop check the build every 2 hours`, or `/loop check the build` (defaults to 10 min).

Supported units: `s` (seconds), `m` (minutes), `h` (hours), `d` (days). Seconds rounded up to nearest minute.

Tools: `CronCreate`, `CronList`, `CronDelete`. One-time reminders via natural language. 3-day auto-expiry on recurring tasks. Disable: `CLAUDE_CODE_DISABLE_CRON=1`.

### Cloud Scheduled Tasks

Durable recurring work on Anthropic cloud infrastructure. Create at claude.ai/code/scheduled, Desktop app, or `/schedule` in CLI.

| Frequency | Description |
|:----------|:------------|
| Hourly | Every hour |
| Daily | Once per day at specified time (default 9am local) |
| Weekdays | Daily but skips Saturday/Sunday |
| Weekly | Once per week on specified day/time |

Each run clones repositories, starts from default branch, pushes to `claude/`-prefixed branches (unless unrestricted pushes enabled). Includes MCP connectors and configurable cloud environments.

### Voice Dictation

Hold-to-talk speech input. Toggle with `/voice`. Persists across sessions.

- Default key: `Space` (hold to record; brief warmup with key-repeat detection)
- Rebind in `~/.claude/keybindings.json` to a modifier combo (e.g., `meta+k`) for instant recording
- Requires claude.ai auth (not API key/Bedrock/Vertex/Foundry)
- Supports 20 languages (set via `language` setting or `/config`)
- Tuned for coding vocabulary; uses project name and git branch as recognition hints
- macOS native module; Linux falls back to `arecord` or `rec`

### Channels

Push events from external systems into a running Claude Code session via MCP servers.

**Supported channels (research preview):** Telegram, Discord, iMessage, fakechat (demo).

**Usage:** install as plugin, then start with `--channels plugin:<name>@<marketplace>`.

**Security:** sender allowlist per channel; pairing flow for Telegram/Discord; iMessage uses self-chat.

**Enterprise controls:**

| Setting | Purpose |
|:--------|:--------|
| `channelsEnabled` | Master switch (must be true for channels to work) |
| `allowedChannelPlugins` | Restrict which plugins can register |

**Building custom channels:** declare `claude/channel` capability in MCP server, emit `notifications/claude/channel` events. Two-way channels expose reply tools. Permission relay via `claude/channel/permission` capability.

### Choosing the Right Remote Approach

| Feature | Trigger | Claude runs on | Best for |
|:--------|:--------|:---------------|:---------|
| Dispatch | Mobile app task | Your machine (Desktop) | Delegating work while away |
| Remote Control | Drive from claude.ai/code or mobile | Your machine (CLI/VS Code) | Steering in-progress work |
| Channels | Push from chat app or webhook | Your machine (CLI) | Reacting to external events |
| Slack | @Claude in team channel | Anthropic cloud | PRs and reviews from team chat |
| Scheduled tasks | Cron schedule | CLI, Desktop, or cloud | Recurring automation |

## Full Documentation

For the complete official documentation, see the reference files:

- [Fast mode](references/claude-code-fast-mode.md) -- toggling fast mode (/fast, settings), cost tradeoff ($30/$150 MTok flat pricing, mid-conversation switch cost), when to use (interactive work vs autonomous tasks), fast mode vs effort level comparison, requirements (subscription plans, extra usage, admin enablement), per-session opt-in (fastModePerSessionOptIn), rate limit fallback behavior, research preview status
- [Model configuration](references/claude-code-model-config.md) -- model aliases (default/sonnet/opus/haiku/sonnet[1m]/opus[1m]/opusplan), setting models (/model, --model, ANTHROPIC_MODEL, settings file), availableModels restriction, default model behavior by plan, opusplan hybrid mode, effort levels (low/medium/high/max, /effort, ultrathink, CLAUDE_CODE_EFFORT_LEVEL, adaptive reasoning), extended context 1M tokens (plan availability, [1m] suffix, CLAUDE_CODE_DISABLE_1M_CONTEXT), custom model option (ANTHROPIC_CUSTOM_MODEL_OPTION), model alias environment variables, pinning models for third-party deployments, customizing display and capabilities (_NAME/_DESCRIPTION/_SUPPORTED_CAPABILITIES), modelOverrides per-version mapping, prompt caching configuration (DISABLE_PROMPT_CACHING)
- [Output styles](references/claude-code-output-styles.md) -- built-in styles (Default, Explanatory, Learning), how output styles modify the system prompt, /config selection, outputStyle setting, custom output style creation (Markdown with frontmatter), keep-coding-instructions frontmatter, comparisons to CLAUDE.md and --append-system-prompt and Agents and Skills
- [Status line configuration](references/claude-code-statusline.md) -- /statusline command, manual configuration (statusLine setting, command field, padding), step-by-step script creation, available JSON data fields (model, workspace, cost, context_window, rate_limits, session_id, transcript_path, version, output_style, vim, agent, worktree), context window fields breakdown, examples (context progress bar, git status with colors, cost tracking, multi-line, clickable links, rate limit), Windows configuration (PowerShell, Git Bash)
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic tracking of file edits, checkpoint creation per prompt, Esc+Esc and /rewind access, restore options (code and conversation, conversation only, code only), summarize from here (targeted context compression), limitations (bash changes not tracked, external changes not tracked, not a replacement for version control)
- [Features overview](references/claude-code-features-overview.md) -- extension layer overview, feature comparison table (CLAUDE.md, Skills, Subagents, Agent teams, MCP, Hooks), detailed comparisons (Skill vs Subagent, CLAUDE.md vs Skill, CLAUDE.md vs Rules vs Skills, Subagent vs Agent team, MCP vs Skill), feature layering (additive CLAUDE.md, name-override skills/subagents/MCP, merge hooks), combining features (Skill+MCP, Skill+Subagent, CLAUDE.md+Skills, Hook+MCP), context costs by feature, how features load (CLAUDE.md at start, Skills descriptions at start with full content on demand, MCP tool names at start with schemas deferred, Subagents isolated, Hooks zero cost)
- [Remote Control](references/claude-code-remote-control.md) -- server mode (claude remote-control, --name, --spawn same-dir/worktree, --capacity, --verbose, --sandbox), interactive session (--remote-control/--rc), from existing session (/remote-control, /rc), connecting from other devices (URL, QR code, claude.ai/code, Claude mobile app), enabling for all sessions, connection and security (outbound HTTPS only, TLS, short-lived credentials), Remote Control vs Claude Code on the web, limitations, troubleshooting, comparison table (Dispatch vs Remote Control vs Channels vs Slack vs Scheduled tasks)
- [Session-scoped scheduled tasks](references/claude-code-scheduled-tasks.md) -- /loop command with interval syntax (leading, trailing every, default 10m), loop over commands, one-time reminders in natural language, CronCreate/CronList/CronDelete tools, scheduling behavior (low-priority queue, local timezone, jitter for recurring and one-shot), 3-day auto-expiry, cron expression reference, CLAUDE_CODE_DISABLE_CRON, limitations (session-scoped, no catch-up, no persistence)
- [Cloud scheduled tasks](references/claude-code-web-scheduled-tasks.md) -- creating tasks (web at claude.ai/code/scheduled, Desktop app, /schedule CLI), prompt and model selection, repository selection and branch permissions (claude/ prefix default), cloud environments (network, env vars, setup script), frequency options (hourly/daily/weekdays/weekly), connectors, managing tasks (view runs, edit, pause, delete, /schedule list/update/run)
- [Voice dictation](references/claude-code-voice-dictation.md) -- /voice toggle, hold Space push-to-talk (warmup, key-repeat detection), streaming transcription tuned for coding vocabulary, cursor-position insertion, dictation language (20 supported languages via language setting), rebinding push-to-talk key in keybindings.json (modifier combos for instant recording), requirements (claude.ai auth, local microphone), troubleshooting
- [Channels](references/claude-code-channels.md) -- push events into running session via MCP, supported channels (Telegram, Discord, iMessage with setup steps), fakechat quickstart, security (sender allowlist, pairing flow), enterprise controls (channelsEnabled, allowedChannelPlugins managed settings), how channels compare to web sessions/Slack/MCP/Remote Control, research preview
- [Channels reference](references/claude-code-channels-reference.md) -- building custom channel MCP servers, claude/channel capability declaration, notification format (content, meta), expose reply tool (ListToolsRequestSchema, CallToolRequestSchema), gate inbound messages (sender allowlist), permission relay (claude/channel/permission capability, permission_request notification, request_id/tool_name/description/input_preview fields, allow/deny verdict), webhook receiver example, testing with --dangerously-load-development-channels
- [Context window explorer](references/claude-code-context-window.md) -- interactive simulation of context loading during a session (system prompt ~4200 tokens, MEMORY.md ~680, environment info ~280, MCP tools deferred ~120, skill descriptions ~450, CLAUDE.md files, user prompt, file reads, path-scoped rules, grep results, edits, hooks with additionalContext, /compact behavior, auto-compaction at 95%)

## Sources

- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line configuration: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Features overview: https://code.claude.com/docs/en/features-overview.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Session-scoped scheduled tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Cloud scheduled tasks: https://code.claude.com/docs/en/web-scheduled-tasks.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Context window explorer: https://code.claude.com/docs/en/context-window.md
