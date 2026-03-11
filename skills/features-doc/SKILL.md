---
name: features-doc
description: Complete documentation for Claude Code features -- extensibility overview (CLAUDE.md, Skills, Subagents, Agent teams, MCP, Hooks, Plugins, and how they combine), model configuration (model aliases like default/sonnet/opus/haiku/opusplan, /model command, availableModels restriction, effort levels low/medium/high, extended 1M context, prompt caching, third-party model pinning), fast mode (2.5x faster Opus 4.6 via /fast, pricing, per-session opt-in, rate limit fallback), output styles (built-in Default/Explanatory/Learning styles, custom output style files with frontmatter, /output-style command, keep-coding-instructions), status line (custom shell-script status bar, /statusline command, JSON stdin data fields, jq examples, ANSI color support, multi-line output, Windows configuration), checkpointing (automatic edit tracking, Esc+Esc or /rewind to restore code/conversation/both, summarize from a checkpoint, limitations), remote control (continue local sessions from phone/tablet/browser via claude remote-control or /remote-control, QR code, connection security), and scheduled tasks (/loop for recurring prompts, one-time reminders, CronCreate/CronList/CronDelete tools, cron expressions, jitter, 3-day expiry, session-scoped). Load when discussing Claude Code features overview, extensibility architecture, model selection, model aliases, opusplan, effort level, fast mode, output styles, status line, statusline, checkpointing, rewind, remote control, scheduled tasks, /loop, cron scheduling, or how Claude Code features compare and combine.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features: the extensibility architecture, model configuration, fast mode, output styles, status line, checkpointing, remote control, and scheduled tasks.

## Quick Reference

### Extensibility Overview

Claude Code's extension layer adds features on top of the built-in agentic loop. Each extension plugs in at a different point.

| Feature | What it does | When to use |
|:--------|:-------------|:------------|
| **CLAUDE.md** | Persistent context loaded every session | Project conventions, "always do X" rules |
| **Skill** | Reusable knowledge and invocable workflows | Reference docs, repeatable tasks (`/<name>`) |
| **Subagent** | Isolated execution, returns summarized results | Context isolation, parallel tasks |
| **Agent team** | Multiple independent Claude Code sessions | Parallel research, competing hypotheses |
| **MCP** | Connect to external services and tools | External data or actions (database, Slack, browser) |
| **Hook** | Deterministic script on lifecycle events | Predictable automation (linting, logging) |
| **Plugin** | Package and distribute skills, hooks, MCP, subagents | Reuse across repos, share via marketplace |

**How features layer**: CLAUDE.md is additive (all levels contribute); Skills and subagents override by name (priority-based); MCP servers override by name (local > project > user); Hooks merge (all registered hooks fire).

**Context costs**: CLAUDE.md loads every request; Skill descriptions load at start, full content on use; MCP tool definitions load at start; Subagents run in isolated context; Hooks cost zero unless they return output.

### Model Configuration

#### Model Aliases

| Alias | Behavior |
|:------|:---------|
| `default` | Depends on account type (Max/Team Premium = Opus 4.6; Pro/Team Standard = Sonnet 4.6) |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast and efficient Haiku for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opusplan` | Opus during plan mode, then Sonnet for execution |

Aliases always point to the latest version. Pin with full model name (e.g., `claude-opus-4-6`) or env vars like `ANTHROPIC_DEFAULT_OPUS_MODEL`.

#### Setting the Model

1. During session: `/model <alias|name>`
2. At startup: `claude --model <alias|name>`
3. Environment variable: `ANTHROPIC_MODEL=<alias|name>`
4. Settings file: `"model": "<alias|name>"`

#### Restrict Model Selection

Use `availableModels` in managed/policy settings to restrict selectable models. The `default` option always remains available regardless of this list. Combine `model` + `availableModels` for full control.

#### Effort Level

Three levels: **low**, **medium**, **high**. Opus 4.6 defaults to medium for Max and Team subscribers. Set via `/model` slider, `CLAUDE_CODE_EFFORT_LEVEL` env var, or `effortLevel` in settings. Supported on Opus 4.6 and Sonnet 4.6.

To disable adaptive reasoning: `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1` (reverts to fixed budget via `MAX_THINKING_TOKENS`).

#### Extended Context (1M tokens)

Opus 4.6 and Sonnet 4.6 support 1M context (beta). Available for API/pay-as-you-go users and subscribers with extra usage enabled. Standard rates apply up to 200K; beyond 200K, long-context pricing applies. Use `[1m]` suffix: `/model sonnet[1m]`. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

#### Model Environment Variables

| Variable | Controls |
|:---------|:---------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for `opus` / `opusplan` plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` / `opusplan` execution |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for `haiku` / background tasks |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |

#### Prompt Caching

| Variable | Effect |
|:---------|:-------|
| `DISABLE_PROMPT_CACHING` | Disable for all models (overrides per-model) |
| `DISABLE_PROMPT_CACHING_HAIKU` | Disable for Haiku only |
| `DISABLE_PROMPT_CACHING_SONNET` | Disable for Sonnet only |
| `DISABLE_PROMPT_CACHING_OPUS` | Disable for Opus only |

### Fast Mode

Toggle with `/fast` for 2.5x faster Opus 4.6 at higher cost. Not a different model -- same quality, different API configuration prioritizing speed.

| Detail | Value |
|:-------|:------|
| Toggle | `/fast` (Tab) or `"fastMode": true` in settings |
| Indicator | `\u21af` icon next to prompt |
| Pricing (<200K) | $30 / $150 MTok (input/output) |
| Pricing (>200K) | $60 / $225 MTok (input/output) |
| Billing | Charged to extra usage from the first token |
| Plans | Pro, Max, Team, Enterprise (extra usage required) |
| Not available on | Bedrock, Vertex AI, Foundry |

**Per-session opt-in**: Admins can set `fastModePerSessionOptIn: true` in managed settings so fast mode resets each session. Disable entirely with `CLAUDE_CODE_DISABLE_FAST_MODE=1`.

**Rate limits**: When hit, fast mode falls back to standard Opus 4.6 automatically (gray icon). Re-enables when cooldown expires.

**Fast mode vs effort level**: Fast mode = same quality, lower latency, higher cost. Lower effort = less thinking, faster, potentially lower quality. Can combine both for maximum speed on straightforward tasks.

### Output Styles

Output styles modify Claude Code's system prompt to adapt it for different use cases.

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Adds educational "Insights" while coding |
| **Learning** | Collaborative learn-by-doing with `TODO(human)` markers |

Toggle with `/output-style` or `/output-style <name>`. Saved in `.claude/settings.local.json` (`outputStyle` field).

#### Custom Output Styles

Place Markdown files with frontmatter in `~/.claude/output-styles/` (user) or `.claude/output-styles/` (project).

| Frontmatter key | Purpose | Default |
|:----------------|:--------|:--------|
| `name` | Display name | File name |
| `description` | Description shown in `/output-style` UI | None |
| `keep-coding-instructions` | Keep coding-related system prompt parts | `false` |

Custom styles exclude coding instructions unless `keep-coding-instructions` is true. All styles exclude concise output instructions.

### Status Line

A customizable bar at the bottom of Claude Code. Runs a shell script that receives JSON session data on stdin and prints formatted output.

**Setup**: Use `/statusline <description>` for auto-configuration, or manually set `statusLine` in settings:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

**Key JSON fields available on stdin**:

| Field path | Description |
|:-----------|:------------|
| `.model.display_name` | Current model name |
| `.model.id` | Full model identifier |
| `.context_window.used_percentage` | Context usage as percentage |
| `.context_window.used_tokens` | Tokens used |
| `.context_window.total_tokens` | Total context capacity |
| `.session.cost_usd` | Session cost in USD |
| `.session.duration_seconds` | Session duration |
| `.session.id` | Session identifier |
| `.session.turn_count` | Number of conversation turns |
| `.workspace.current_dir` | Working directory path |
| `.workspace.git_branch` | Current git branch |

Supports ANSI escape codes for colors. Multi-line output (print multiple lines) is supported. Refresh interval is roughly every 2 seconds. Disable: remove `statusLine` from settings or `/statusline clear`.

### Checkpointing

Automatic tracking of Claude's file edits as you work.

- Every user prompt creates a new checkpoint
- Checkpoints persist across sessions (cleaned up after 30 days)
- Open with **Esc + Esc** or `/rewind`

**Actions from the rewind menu**:

| Action | Effect |
|:-------|:-------|
| Restore code and conversation | Revert both to selected point |
| Restore conversation | Rewind messages, keep current code |
| Restore code | Revert files, keep conversation |
| Summarize from here | Compress subsequent messages into a summary (frees context) |

**Limitations**: Bash command file changes (rm, mv, cp) are not tracked. External changes outside Claude Code are not tracked. Checkpoints complement git, not replace it.

### Remote Control

Continue a local Claude Code session from phone, tablet, or any browser via claude.ai/code or the Claude mobile app.

| Command | Description |
|:--------|:------------|
| `claude remote-control` | Start a new remote-control session |
| `claude remote-control --name "My Project"` | Start with custom session title |
| `/remote-control` or `/rc` | Enable remote control from an existing session |

**How it works**: Session runs locally (filesystem, MCP, tools all stay local). Web/mobile interface is just a window into the local session. Conversation stays in sync across all connected devices. Reconnects automatically after sleep/network drops.

**Requirements**: Pro/Max/Team/Enterprise plan, `/login` authentication, workspace trust accepted.

**Enable for all sessions**: `/config` > Enable Remote Control for all sessions.

**Security**: Outbound HTTPS only, no inbound ports. Traffic routes through Anthropic API over TLS with short-lived credentials.

**Limitations**: One remote session per Claude Code instance. Terminal must stay open. Network outage >10 min causes session timeout.

### Scheduled Tasks

Session-scoped scheduling for recurring prompts, polling, and reminders.

| Method | Example |
|:-------|:--------|
| `/loop` with interval | `/loop 5m check if the deployment finished` |
| `/loop` with trailing interval | `/loop check the build every 2 hours` |
| `/loop` no interval (default 10m) | `/loop check the build` |
| `/loop` with command | `/loop 20m /review-pr 1234` |
| Natural language reminder | `remind me at 3pm to push the release branch` |

**Interval units**: `s` (seconds, rounded to min), `m` (minutes), `h` (hours), `d` (days).

**Underlying tools**:

| Tool | Purpose |
|:-----|:--------|
| `CronCreate` | Schedule a task (5-field cron expression, prompt, recur/once) |
| `CronList` | List tasks with IDs, schedules, prompts |
| `CronDelete` | Cancel a task by 8-character ID |

**Behavior**: Tasks fire between turns (not mid-response). All times in local timezone. Recurring tasks expire after 3 days. Max 50 tasks per session. No persistence across restarts.

**Cron quick reference**: `minute hour day-of-month month day-of-week`. Supports `*`, single values, steps (`*/15`), ranges (`1-5`), comma lists.

**Disable**: `CLAUDE_CODE_DISABLE_CRON=1`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code (features overview)](references/claude-code-features-overview.md) -- extensibility architecture, feature comparison table, CLAUDE.md vs Skills vs Rules, Skill vs Subagent, Subagent vs Agent team, MCP vs Skill, how features layer, combination patterns, context costs by feature
- [Speed up responses with fast mode](references/claude-code-fast-mode.md) -- /fast toggle, pricing, cost tradeoffs, fast mode vs effort level, requirements, per-session opt-in, rate limit fallback, research preview status
- [Model configuration](references/claude-code-model-config.md) -- model aliases (default/sonnet/opus/haiku/opusplan), /model command, availableModels, default model behavior, effort levels, extended 1M context, model environment variables, third-party model pinning, prompt caching
- [Output styles](references/claude-code-output-styles.md) -- built-in styles (Default/Explanatory/Learning), custom output style files, frontmatter options, /output-style command, comparison with CLAUDE.md, agents, and skills
- [Customize your status line](references/claude-code-statusline.md) -- /statusline command, manual configuration, JSON data fields, jq-based scripts, ANSI colors, multi-line output, Windows PowerShell/Git Bash support, examples
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic edit tracking, Esc+Esc and /rewind, restore code/conversation/both, summarize from checkpoint, limitations (bash changes, external edits)
- [Continue local sessions with Remote Control](references/claude-code-remote-control.md) -- claude remote-control and /remote-control commands, connecting from other devices, QR code, always-on configuration, connection security, comparison with Claude Code on the web
- [Run prompts on a schedule](references/claude-code-scheduled-tasks.md) -- /loop skill, interval syntax, one-time reminders, CronCreate/CronList/CronDelete tools, cron expression reference, jitter, 3-day expiry, session-scoped limitations

## Sources

- Extend Claude Code: https://code.claude.com/docs/en/features-overview.md
- Speed up responses with fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Customize your status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Continue local sessions with Remote Control: https://code.claude.com/docs/en/remote-control.md
- Run prompts on a schedule: https://code.claude.com/docs/en/scheduled-tasks.md
