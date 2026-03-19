---
name: features-doc
description: Complete documentation for Claude Code features and configuration -- extensibility overview (CLAUDE.md, Skills, MCP, Subagents, Agent teams, Hooks, Plugins feature comparison and layering), fast mode (2.5x faster Opus 4.6, /fast toggle, $30/150 MTok pricing, rate limit fallback, fastModePerSessionOptIn, extra usage billing), model configuration (model aliases default/sonnet/opus/haiku/sonnet[1m]/opus[1m]/opusplan, /model command, --model flag, ANTHROPIC_MODEL env, availableModels restriction, default model per plan, opusplan plan/execute split, effort levels low/medium/high/max with /effort and effortLevel setting, extended 1M context window with plan availability, ANTHROPIC_DEFAULT_OPUS_MODEL/SONNET_MODEL/HAIKU_MODEL env vars, modelOverrides for Bedrock/Vertex/Foundry ARN routing, ANTHROPIC_CUSTOM_MODEL_OPTION, prompt caching config DISABLE_PROMPT_CACHING), output styles (Default/Explanatory/Learning built-in styles, custom output style markdown files with frontmatter name/description/keep-coding-instructions, ~/.claude/output-styles and .claude/output-styles locations, /config selection, outputStyle setting, system prompt modification), status line (customizable shell script bar, JSON session data on stdin, statusLine settings with type/command/padding, /statusline command, available data fields model/workspace/cost/context_window/session_id/vim/agent/worktree, ANSI colors, multi-line output, OSC 8 clickable links, update timing, context window fields current_usage vs cumulative totals, Windows PowerShell/Git Bash support), checkpointing (automatic edit tracking, Esc+Esc or /rewind menu, restore code/conversation/both, summarize from here for targeted context compression, 30-day retention, bash and external changes not tracked), remote control (continue local sessions from phone/tablet/browser, claude remote-control server mode with --name/--spawn/--capacity/--sandbox flags, claude --remote-control interactive mode, /remote-control from existing session, QR code mobile access, connection security outbound HTTPS only, Remote Control vs Claude Code on the web, worktree spawn mode, enable for all sessions via /config), scheduled tasks (session-scoped /loop recurring prompts with interval syntax s/m/h/d, one-time reminders in natural language, CronCreate/CronList/CronDelete tools, 5-field cron expressions in local timezone, jitter for load balancing, 3-day auto-expiry, CLAUDE_CODE_DISABLE_CRON, 50 task limit), voice dictation (/voice toggle, hold Space push-to-talk, streaming speech-to-text, voiceEnabled setting, 20 supported languages, rebind push-to-talk in keybindings.json, modifier combos skip warmup, coding vocabulary tuning, Claude.ai account required, microphone access). Load when discussing Claude Code features overview, extensibility, feature comparison, fast mode, /fast, model configuration, /model, model aliases, opusplan, effort levels, /effort, extended context, 1M context, output styles, /config output style, custom output style, status line, /statusline, statusLine setting, checkpointing, /rewind, checkpoint restore, summarize from here, remote control, /remote-control, claude remote-control, scheduled tasks, /loop, cron, CronCreate, voice dictation, /voice, push-to-talk, speech-to-text, model selection, availableModels, modelOverrides, prompt caching, fast mode pricing, or any Claude Code feature configuration and customization.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features, configuration options, and customization.

## Quick Reference

Claude Code extends its core agentic loop through CLAUDE.md (persistent context), Skills (reusable knowledge/workflows), MCP (external services), Subagents (isolated workers), Agent teams (coordinated sessions), Hooks (deterministic scripts), and Plugins (packaging layer). Each feature loads at different points and has different context costs.

### Feature Selection Guide

| Feature | What it does | When to use it |
|:--------|:-------------|:---------------|
| **CLAUDE.md** | Persistent context loaded every session | Project conventions, "always do X" rules |
| **Skill** | Instructions, knowledge, and workflows | Reusable content, reference docs, repeatable tasks |
| **Subagent** | Isolated execution context | Context isolation, parallel tasks, specialized workers |
| **Agent team** | Coordinate multiple independent sessions | Parallel research, competing hypotheses, feature development |
| **MCP** | Connect to external services | External data or actions (databases, Slack, browsers) |
| **Hook** | Deterministic script on events | Predictable automation, no LLM involved |

### Context Cost by Feature

| Feature | When it loads | Context cost |
|:--------|:-------------|:-------------|
| CLAUDE.md | Session start | Every request |
| Skills | Descriptions at start, full on use | Low (descriptions every request) |
| MCP servers | Session start | Every request (tool definitions) |
| Subagents | When spawned | Isolated from main session |
| Hooks | On trigger | Zero (runs externally) |

### Feature Layering

Features at multiple levels follow different merge rules:

| Feature | Merge behavior |
|:--------|:---------------|
| CLAUDE.md | Additive (all levels contribute) |
| Skills/Subagents | Override by name (priority-based) |
| MCP servers | Override by name (local > project > user) |
| Hooks | Merge (all registered hooks fire) |

### Fast Mode

Toggle with `/fast`. Uses the same Opus 4.6 model with a speed-optimized API configuration (2.5x faster).

| Detail | Value |
|:-------|:------|
| Pricing | $30 input / $150 output per MTok (flat across full 1M context) |
| Toggle | `/fast` command or `"fastMode": true` in settings |
| Indicator | Lightning bolt icon next to prompt |
| Availability | Pro/Max/Team/Enterprise subscriptions and Console (extra usage only) |
| Rate limit behavior | Auto-falls back to standard Opus, re-enables after cooldown |
| Admin control | Enable in Console or Claude AI admin settings; `CLAUDE_CODE_DISABLE_FAST_MODE=1` to disable |
| Per-session opt-in | `"fastModePerSessionOptIn": true` in managed settings (resets each session) |

Fast mode vs effort level: fast mode gives same quality at lower latency and higher cost; lower effort level reduces thinking time with potentially lower quality. They can be combined.

### Model Configuration

**Model aliases:**

| Alias | Resolves to |
|:------|:------------|
| `default` | Depends on account type (Max/Team Premium = Opus; Pro/Team Standard = Sonnet) |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast Haiku model |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus for planning, Sonnet for execution |

**Setting your model (priority order):**

1. `/model <alias|name>` during session
2. `claude --model <alias|name>` at startup
3. `ANTHROPIC_MODEL=<alias|name>` env var
4. `"model"` field in settings file

**Effort levels:** `low`, `medium`, `high`, `max` (max is Opus-only, session-only). Set via `/effort`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL` env, or `"effortLevel"` setting. Opus 4.6 defaults to medium effort for Max and Team.

**Extended context (1M tokens):**

| Plan | Opus 1M | Sonnet 1M |
|:-----|:--------|:----------|
| Max, Team, Enterprise | Included | Extra usage required |
| Pro | Extra usage required | Extra usage required |
| API / pay-as-you-go | Full access | Full access |

Use `[1m]` suffix: `/model opus[1m]`, `/model sonnet[1m]`. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

**Model restriction:** `"availableModels": ["sonnet", "haiku"]` in managed/policy settings restricts which models users can select. Default model always remains available.

**Model environment variables:**

| Variable | Controls |
|:---------|:---------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for `opus` alias / `opusplan` plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` alias / `opusplan` execution |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for `haiku` alias and background tasks |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |
| `ANTHROPIC_CUSTOM_MODEL_OPTION` | Add custom entry to `/model` picker |

**`modelOverrides`** maps Anthropic model IDs to provider-specific strings (Bedrock ARNs, Vertex version names, Foundry deployment names) in settings. Useful for governance and cost allocation.

**Prompt caching control:** `DISABLE_PROMPT_CACHING=1` (all models), `DISABLE_PROMPT_CACHING_OPUS=1`, `DISABLE_PROMPT_CACHING_SONNET=1`, `DISABLE_PROMPT_CACHING_HAIKU=1`.

### Output Styles

Modify Claude Code's system prompt for different interaction modes.

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Adds educational "Insights" between tasks |
| **Learning** | Collaborative learn-by-doing mode with `TODO(human)` markers |

Select via `/config` > Output style, or set `"outputStyle": "Explanatory"` in settings. Changes take effect next session.

**Custom output styles:** markdown files in `~/.claude/output-styles/` (user) or `.claude/output-styles/` (project) with frontmatter:

| Field | Purpose | Default |
|:------|:--------|:--------|
| `name` | Display name | File name |
| `description` | Shown in `/config` picker | None |
| `keep-coding-instructions` | Keep default coding system prompt | `false` |

Custom styles exclude coding instructions by default (unlike CLAUDE.md or `--append-system-prompt` which add to the existing prompt).

### Status Line

Customizable shell script bar at the bottom of Claude Code. Configure via `/statusline` (natural language) or manually in settings:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

**Key JSON data fields available on stdin:**

| Field | Description |
|:------|:------------|
| `model.id`, `model.display_name` | Current model |
| `workspace.current_dir`, `workspace.project_dir` | Working and launch directories |
| `cost.total_cost_usd` | Session cost in USD |
| `cost.total_duration_ms`, `cost.total_api_duration_ms` | Wall-clock and API time |
| `cost.total_lines_added`, `cost.total_lines_removed` | Lines changed |
| `context_window.used_percentage` | Context usage percentage |
| `context_window.context_window_size` | Max tokens (200K or 1M) |
| `context_window.current_usage` | Last API call token breakdown |
| `session_id` | Unique session identifier |
| `vim.mode` | Vim mode (NORMAL/INSERT, when enabled) |
| `agent.name` | Agent name (when --agent active) |
| `worktree.*` | Worktree name, path, branch (when active) |

Updates after each assistant message (debounced at 300ms). Supports ANSI colors, multi-line output, and OSC 8 clickable links. Does not consume API tokens.

### Checkpointing

Automatic edit tracking with rewind capability. Every user prompt creates a checkpoint. Access via double-Esc or `/rewind`.

**Rewind actions:**

| Action | Effect |
|:-------|:-------|
| Restore code and conversation | Revert both to selected point |
| Restore conversation | Rewind messages, keep current code |
| Restore code | Revert files, keep conversation |
| Summarize from here | Compress messages from selected point forward (frees context) |

Checkpoints persist across sessions (30-day retention). Original prompt is restored into the input field after restore/summarize.

**Limitations:** bash command changes (rm, mv, cp) and external edits are not tracked. Checkpoints are session-level recovery, not a replacement for git.

### Remote Control

Continue local Claude Code sessions from phone, tablet, or any browser via claude.ai/code or the Claude mobile app.

| Start method | Command |
|:-------------|:--------|
| Server mode | `claude remote-control` |
| Interactive with RC | `claude --remote-control` (or `--rc`) |
| From existing session | `/remote-control` (or `/rc`) |

**Server mode flags:**

| Flag | Purpose |
|:-----|:--------|
| `--name "title"` | Custom session title |
| `--spawn <mode>` | `same-dir` (default) or `worktree` for concurrent sessions |
| `--capacity <N>` | Max concurrent sessions (default 32) |
| `--sandbox` / `--no-sandbox` | Filesystem/network isolation |

Connect via session URL, QR code (press spacebar), or find in claude.ai/code session list. All traffic goes through Anthropic API over TLS (outbound HTTPS only, no inbound ports).

**Requirements:** Pro/Max/Team/Enterprise plan, Claude.ai OAuth authentication, workspace trust accepted. Team/Enterprise requires admin enablement.

### Scheduled Tasks (Session-Scoped)

Run prompts on a schedule within the current session. Tasks are gone when the session exits.

**`/loop` syntax:**

| Form | Example | Interval |
|:-----|:--------|:---------|
| Leading token | `/loop 5m check build` | Every 5 minutes |
| Trailing clause | `/loop check build every 2h` | Every 2 hours |
| No interval | `/loop check build` | Default 10 minutes |

Units: `s` (seconds, rounded up to 1m), `m` (minutes), `h` (hours), `d` (days).

**One-time reminders:** natural language, e.g., "remind me at 3pm to push the release branch".

**Underlying tools:**

| Tool | Purpose |
|:-----|:--------|
| `CronCreate` | Schedule a task (5-field cron expression) |
| `CronList` | List scheduled tasks with IDs |
| `CronDelete` | Cancel a task by ID |

All times in local timezone. Recurring tasks have jitter (up to 10% of period, capped at 15min) and auto-expire after 3 days. Max 50 tasks per session. Disable with `CLAUDE_CODE_DISABLE_CRON=1`.

### Voice Dictation

Push-to-talk speech input for prompts. Enable with `/voice` or `"voiceEnabled": true` in settings.

| Detail | Value |
|:-------|:------|
| Default key | Hold `Space` |
| Rebind | `voice:pushToTalk` in `~/.claude/keybindings.json` |
| Language | Uses `language` setting; defaults to English; 20 languages supported |
| Requirements | Claude.ai account, local microphone access |

Modifier combos (e.g., `meta+k`) start recording immediately (no warmup). Speech is inserted at cursor position. Transcription is tuned for coding vocabulary and uses project/branch names as recognition hints.

Not available with API keys, Bedrock, Vertex, Foundry, or in remote environments (SSH, Claude Code on the web).

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code (features overview)](references/claude-code-features-overview.md) -- extensibility overview, feature comparison table (CLAUDE.md/Skill/Subagent/Agent team/MCP/Hook), detailed feature-vs-feature comparisons (Skill vs Subagent, CLAUDE.md vs Skill, CLAUDE.md vs Rules vs Skills, Subagent vs Agent team, MCP vs Skill), feature layering rules (additive/override/merge), combination patterns (Skill+MCP, Skill+Subagent, CLAUDE.md+Skills, Hook+MCP), context cost by feature, context loading timing (session start vs on-demand vs isolated), plugins as packaging layer
- [Speed up responses with fast mode](references/claude-code-fast-mode.md) -- /fast toggle, $30/150 MTok pricing (flat across 1M context), cost tradeoff when switching mid-conversation, fast mode vs effort level comparison, requirements (no third-party providers, extra usage required, admin enablement for Teams/Enterprise), CLAUDE_CODE_DISABLE_FAST_MODE env var, fastModePerSessionOptIn managed setting, rate limit fallback to standard Opus with gray icon and auto-re-enable, research preview status
- [Model configuration](references/claude-code-model-config.md) -- model aliases (default/sonnet/opus/haiku/sonnet[1m]/opus[1m]/opusplan), setting model (/model, --model, ANTHROPIC_MODEL, settings file with priority order), availableModels restriction with merge behavior, default model per plan type, opusplan plan/execute split, effort levels (low/medium/high/max with /effort command and settings), adaptive reasoning and CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING, extended 1M context window (plan availability table, [1m] suffix, CLAUDE_CODE_DISABLE_1M_CONTEXT), ANTHROPIC_CUSTOM_MODEL_OPTION for /model picker, model environment variables (ANTHROPIC_DEFAULT_OPUS/SONNET/HAIKU_MODEL, CLAUDE_CODE_SUBAGENT_MODEL), pinning models for Bedrock/Vertex/Foundry, modelOverrides for per-version ARN/deployment routing, prompt caching configuration (DISABLE_PROMPT_CACHING and per-model variants)
- [Output styles](references/claude-code-output-styles.md) -- built-in styles (Default, Explanatory with Insights, Learning with TODO(human) markers), system prompt modification behavior, /config selection and outputStyle setting, custom output style markdown files with frontmatter (name/description/keep-coding-instructions), user and project output-styles directories, comparison with CLAUDE.md and --append-system-prompt and Agents and Skills
- [Customize your status line](references/claude-code-statusline.md) -- /statusline command for natural-language generation, manual configuration (statusLine setting with type/command/padding), full JSON data schema (model, workspace, cost, context_window with current_usage and cumulative totals, session_id, vim, agent, worktree fields), ANSI color codes, OSC 8 clickable links, multi-line output, update timing (debounced 300ms, cancellation), context window percentage calculation (input tokens only), ready-to-use examples (context bar, git status with colors, cost tracking, multi-line, clickable links) in Bash/Python/Node.js, Windows PowerShell and Git Bash support
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic edit tracking per user prompt, Esc+Esc or /rewind to open rewind menu, restore options (code+conversation, conversation only, code only), summarize from here (targeted context compression preserving early messages), checkpoints persist across sessions (30-day configurable retention), limitations (bash commands and external changes not tracked, not a git replacement)
- [Continue local sessions with Remote Control](references/claude-code-remote-control.md) -- claude remote-control server mode (--name/--spawn/--capacity/--sandbox/--verbose flags, worktree spawn mode, QR code), claude --remote-control interactive mode, /remote-control from existing session, connect from browser or mobile app, enable for all sessions via /config, connection security (outbound HTTPS only, TLS, short-lived credentials), requirements (Pro/Max/Team/Enterprise, Claude.ai OAuth, workspace trust, admin enablement), Remote Control vs Claude Code on the web, troubleshooting (eligibility errors, policy errors, credential failures)
- [Run prompts on a schedule](references/claude-code-scheduled-tasks.md) -- /loop bundled skill (interval syntax s/m/h/d, leading/trailing/no interval forms, loop over other commands), one-time reminders in natural language, CronCreate/CronList/CronDelete tools, 5-field cron expression reference, local timezone interpretation, jitter (10% period for recurring, 90s for one-shot), 3-day auto-expiry, session-scoped (no persistence across restarts), 50 task limit, CLAUDE_CODE_DISABLE_CRON env var, comparison with Desktop scheduled tasks and GitHub Actions for durable scheduling
- [Voice dictation](references/claude-code-voice-dictation.md) -- /voice toggle, hold Space push-to-talk with warmup detection, modifier combo rebinding for instant recording, voiceEnabled setting, streaming speech-to-text, 20 supported dictation languages, language setting integration, keybindings.json voice:pushToTalk rebinding, coding vocabulary tuning (regex, OAuth, JSON, project/branch hints), requirements (Claude.ai account, local mic access, not in remote/SSH), macOS/Linux/Windows native audio with Linux fallback to arecord/SoX, troubleshooting (mic access, hold detection, wrong language)

## Sources

- Extend Claude Code (features overview): https://code.claude.com/docs/en/features-overview.md
- Speed up responses with fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Customize your status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Continue local sessions with Remote Control: https://code.claude.com/docs/en/remote-control.md
- Run prompts on a schedule: https://code.claude.com/docs/en/scheduled-tasks.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
