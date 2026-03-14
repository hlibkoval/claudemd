---
name: features-doc
description: Complete documentation for Claude Code features and configuration -- extensibility overview (CLAUDE.md, skills, MCP, subagents, agent teams, hooks, plugins, when to use which, feature comparison tables, context cost by feature, how features load and layer), model configuration (model aliases default/sonnet/opus/haiku/opusplan/sonnet[1m]/opus[1m], setting models via /model or --model or env vars or settings, availableModels restrictions, modelOverrides for Bedrock/Vertex/Foundry, effort levels low/medium/high/max/auto, extended 1M context window, prompt caching config), fast mode (2.5x faster Opus 4.6, /fast toggle, pricing $30/$150 MTok, per-session opt-in fastModePerSessionOptIn, rate limit fallback, extra usage requirement, Teams/Enterprise admin enablement), output styles (Default/Explanatory/Learning built-in styles, custom output style .md files with frontmatter, keep-coding-instructions, ~/.claude/output-styles and .claude/output-styles, /config selection, outputStyle setting), status line (/statusline command, statusLine setting with type/command/padding, JSON session data on stdin, available fields model/cost/context_window/workspace/git/vim/agent/worktree, script examples for context bars/git status/cost tracking/multi-line/clickable links, ANSI colors, Windows PowerShell config), checkpointing (automatic edit tracking, Esc+Esc or /rewind to open rewind menu, restore code/conversation/both, summarize from here, checkpoint persistence across sessions, limitations bash/external changes not tracked), Remote Control (claude remote-control server mode, claude --remote-control or /remote-control, --name/--spawn/--capacity/--sandbox flags, connect via URL/QR code/session list, claude.ai/code and mobile app, /mobile for app download, enable for all sessions via /config, connection security outbound HTTPS only, vs Claude Code on the web), scheduled tasks (/loop skill for recurring prompts, interval syntax s/m/h/d, one-time reminders in natural language, CronCreate/CronList/CronDelete tools, session-scoped 3-day expiry, jitter, cron expression reference, CLAUDE_CODE_DISABLE_CRON). Load when discussing Claude Code features overview, extensibility, model selection, model aliases, /model command, opusplan, effort levels, fast mode, /fast, output styles, custom output styles, status line, /statusline, statusLine setting, checkpointing, /rewind, undo changes, Remote Control, remote-control, /rc, scheduled tasks, /loop, cron jobs, reminders, context window configuration, 1M context, model configuration, prompt caching, or comparing when to use CLAUDE.md vs skills vs MCP vs hooks vs subagents vs agent teams.
user-invocable: false
---

# Features & Configuration Documentation

This skill provides the complete official documentation for Claude Code features and configuration: the extensibility overview, model configuration, fast mode, output styles, status line, checkpointing, Remote Control, and scheduled tasks.

## Quick Reference

### Extensibility Overview

Claude Code's extension layer adds capabilities beyond its built-in tools.

| Feature | What it does | When to use it |
|:--------|:-------------|:---------------|
| **CLAUDE.md** | Persistent context loaded every session | Project conventions, "always do X" rules |
| **Skill** | Instructions, knowledge, workflows Claude can use | Reusable content, reference docs, repeatable tasks |
| **Subagent** | Isolated execution context returning summaries | Context isolation, parallel tasks, specialized workers |
| **Agent team** | Coordinate multiple independent sessions | Parallel research, competing hypotheses, multi-piece features |
| **MCP** | Connect to external services and tools | External data or actions (databases, Slack, browsers) |
| **Hook** | Deterministic script on lifecycle events | Predictable automation, no LLM involved |
| **Plugin** | Package and distribute bundles of the above | Sharing across repos/teams via marketplaces |

#### How Features Layer

- **CLAUDE.md**: additive -- all levels contribute, more specific wins on conflict
- **Skills/subagents**: override by name with priority (managed > user > project)
- **MCP servers**: override by name (local > project > user)
- **Hooks**: merge -- all registered hooks fire for matching events

#### Context Cost by Feature

| Feature | When it loads | Context cost |
|:--------|:-------------|:-------------|
| **CLAUDE.md** | Session start | Every request (keep under ~500 lines) |
| **Skills** | Descriptions at start, full on use | Low until used |
| **MCP servers** | Session start | Every request (tool search caps at 10%) |
| **Subagents** | When spawned | Isolated from main session |
| **Hooks** | On trigger | Zero (runs externally) |

### Model Configuration

#### Model Aliases

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended for account type (Max/Team Premium: Opus 4.6, Pro/Team Standard: Sonnet 4.6) |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast/efficient Haiku for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus during plan mode, Sonnet for execution |

#### Setting the Model

1. During session: `/model <alias or name>`
2. At startup: `claude --model <alias or name>`
3. Environment variable: `ANTHROPIC_MODEL=<alias or name>`
4. Settings file: `"model": "opus"`

#### Restrict Models (Enterprise)

`availableModels` in managed/policy settings restricts which models users can select. The Default model always remains available.

```json
{ "availableModels": ["sonnet", "haiku"] }
```

#### Model Environment Variables

| Variable | Controls |
|:---------|:---------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for `opus` alias / opusplan plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` alias / opusplan execution |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for `haiku` alias / background tasks |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |

#### Model Overrides (Third-Party Providers)

`modelOverrides` in settings maps Anthropic model IDs to provider-specific strings (Bedrock ARNs, Vertex/Foundry deployment names):

```json
{
  "modelOverrides": {
    "claude-opus-4-6": "arn:aws:bedrock:us-east-2:123456789012:...",
    "claude-sonnet-4-6": "arn:aws:bedrock:us-east-2:123456789012:..."
  }
}
```

#### Effort Levels

Control adaptive reasoning depth. Persists across sessions (except `max`).

| Level | Effect |
|:------|:-------|
| `low` | Faster, cheaper, less thinking |
| `medium` | Default for Opus 4.6 on Max/Team |
| `high` | Deeper reasoning |
| `max` | Deepest reasoning, no token constraint (Opus 4.6 only, session-scoped) |

Set via: `/effort <level>`, effort slider in `/model`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL` env var, or `effortLevel` in settings.

#### Extended Context (1M Tokens)

Opus 4.6 and Sonnet 4.6 support 1M token context. On Max/Team/Enterprise, Opus auto-upgrades to 1M. Enable with `/model opus[1m]` or append `[1m]` to model names. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

#### Prompt Caching

Automatic by default. Disable with environment variables:

| Variable | Scope |
|:---------|:------|
| `DISABLE_PROMPT_CACHING` | All models (overrides per-model) |
| `DISABLE_PROMPT_CACHING_HAIKU` | Haiku only |
| `DISABLE_PROMPT_CACHING_SONNET` | Sonnet only |
| `DISABLE_PROMPT_CACHING_OPUS` | Opus only |

### Fast Mode

2.5x faster Opus 4.6 responses at higher per-token cost. Same model quality.

- Toggle: `/fast` (persists across sessions by default)
- Pricing: $30/$150 MTok (input/output) under 200K; $60/$225 MTok over 200K
- Requires extra usage enabled; billed directly to extra usage from first token
- Teams/Enterprise: admin must explicitly enable in Console or Claude AI admin settings
- Rate limit fallback: auto-falls back to standard Opus (gray icon), re-enables after cooldown
- Per-session opt-in: set `fastModePerSessionOptIn: true` in managed settings to reset each session
- Disable entirely: `CLAUDE_CODE_DISABLE_FAST_MODE=1`

Fast mode vs effort level: fast mode lowers latency at higher cost; lower effort reduces thinking time and may lower quality. They can be combined.

### Output Styles

Modify Claude Code's system prompt to adapt behavior beyond software engineering.

#### Built-in Styles

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Provides educational "Insights" while coding |
| **Learning** | Collaborative mode with `TODO(human)` markers for you to implement |

#### Configuration

Select via `/config` > Output style, or set `outputStyle` in settings. Takes effect on next session start.

#### Custom Output Styles

Markdown files with frontmatter saved to `~/.claude/output-styles/` (user) or `.claude/output-styles/` (project).

| Frontmatter | Purpose | Default |
|:------------|:--------|:--------|
| `name` | Display name | File name |
| `description` | Shown in /config picker | None |
| `keep-coding-instructions` | Keep coding parts of system prompt | `false` |

Custom styles exclude coding instructions unless `keep-coding-instructions: true`. All styles exclude efficient-output instructions.

### Status Line

Customizable bar at the bottom of Claude Code running any shell script. Receives JSON session data on stdin.

#### Setup

- Automatic: `/statusline <description>` generates a script and updates settings
- Manual: set `statusLine` in settings with `type: "command"` and `command: "<script path or inline command>"`
- Optional `padding` field adds horizontal spacing (default: 0)
- Remove: `/statusline delete` or remove `statusLine` from settings

#### Available Data Fields

| Field | Description |
|:------|:------------|
| `model.id`, `model.display_name` | Current model |
| `cwd`, `workspace.current_dir` | Current working directory |
| `workspace.project_dir` | Launch directory |
| `cost.total_cost_usd` | Session cost in USD |
| `cost.total_duration_ms` | Wall-clock time since session start |
| `cost.total_api_duration_ms` | Time waiting for API |
| `cost.total_lines_added/removed` | Lines of code changed |
| `context_window.used_percentage` | Context usage percent |
| `context_window.remaining_percentage` | Context remaining percent |
| `context_window.context_window_size` | Max tokens (200K or 1M) |
| `context_window.current_usage.*` | Per-call token breakdown |
| `exceeds_200k_tokens` | Whether last response exceeded 200K |
| `session_id` | Session identifier |
| `transcript_path` | Path to transcript file |
| `version` | Claude Code version |
| `output_style.name` | Active output style |
| `vim.mode` | Vim mode (NORMAL/INSERT), if enabled |
| `agent.name` | Agent name, if running with --agent |
| `worktree.*` | Worktree name/path/branch, if active |

Scripts can output multiple lines, ANSI colors, and OSC 8 clickable links. Updates after each assistant message, debounced at 300ms. Does not consume API tokens.

### Checkpointing

Automatic tracking of Claude's file edits for quick undo/rewind.

- Every user prompt creates a checkpoint; persists across sessions (cleaned after 30 days)
- Open rewind menu: press `Esc` twice or use `/rewind`
- Actions: **Restore code and conversation**, **Restore conversation** (keep code), **Restore code** (keep conversation), **Summarize from here** (compress messages, free context space)
- Summarize keeps the session and compresses context; use fork (`claude --continue --fork-session`) to branch off preserving the original session

#### Limitations

- Bash command file changes (rm, mv, cp) are NOT tracked
- External/concurrent-session changes normally not captured
- Not a replacement for Git -- checkpoints are session-level "local undo"

### Remote Control

Continue local Claude Code sessions from any device via claude.ai/code or the Claude mobile app. Your local environment (filesystem, MCP, tools) stays available.

#### Starting a Session

| Method | Command |
|:-------|:--------|
| Server mode | `claude remote-control` (dedicated server, no local typing) |
| Interactive | `claude --remote-control` or `claude --rc` (full local + remote) |
| Existing session | `/remote-control` or `/rc` |

Server mode flags: `--name`, `--spawn <same-dir or worktree>`, `--capacity <N>`, `--verbose`, `--sandbox`/`--no-sandbox`.

#### Connecting

- Open session URL displayed in terminal
- Scan QR code (press spacebar in server mode to toggle)
- Find session in claude.ai/code or Claude app session list (green dot = online)
- Enable for all sessions via `/config`

#### Key Properties

- Outbound HTTPS only, no inbound ports
- Auto-reconnects after sleep/network drops
- Session ends if terminal closes or network drops for ~10 minutes
- One remote session per interactive process (use server mode with `--spawn` for multiple)

### Scheduled Tasks

Session-scoped recurring and one-time prompts via `/loop` and natural language reminders.

#### /loop (Recurring)

```
/loop 5m check if the deployment finished
/loop check the build every 2 hours
/loop 20m /review-pr 1234
```

Interval units: `s` (seconds, rounded to minutes), `m`, `h`, `d`. Default: every 10 minutes.

#### One-Time Reminders

```
remind me at 3pm to push the release branch
in 45 minutes, check whether tests passed
```

#### Management

Ask Claude naturally ("what scheduled tasks do I have?", "cancel the deploy check") or use tools directly:

| Tool | Purpose |
|:-----|:--------|
| `CronCreate` | Schedule new task (cron expression + prompt) |
| `CronList` | List all tasks with IDs, schedules, prompts |
| `CronDelete` | Cancel a task by 8-char ID |

#### Behavior

- Fires between turns (low priority), not during Claude's response
- Local timezone for all cron expressions
- Jitter: recurring up to 10% late (capped 15min); one-shot up to 90s early at :00/:30
- 3-day auto-expiry for recurring tasks
- Max 50 tasks per session
- Session-scoped only -- no persistence across restarts
- Disable: `CLAUDE_CODE_DISABLE_CRON=1`

For durable scheduling, use Desktop scheduled tasks or GitHub Actions with `schedule` triggers.

## Full Documentation

For the complete official documentation, see the reference files:

- [Features overview](references/claude-code-features-overview.md) -- extensibility overview, feature comparison tables (skill vs subagent, CLAUDE.md vs skill, CLAUDE.md vs rules vs skills, subagent vs agent team, MCP vs skill), how features layer and combine, context cost by feature, how each feature loads (CLAUDE.md/skills/MCP/subagents/hooks)
- [Model configuration](references/claude-code-model-config.md) -- model aliases and names, setting models (/model, --model, env vars, settings), availableModels restrictions, default model behavior by plan, opusplan hybrid mode, effort levels (low/medium/high/max/auto), extended 1M context window availability by plan, model environment variables, pinning models for Bedrock/Vertex/Foundry, modelOverrides setting, prompt caching configuration
- [Fast mode](references/claude-code-fast-mode.md) -- toggling fast mode, pricing tables, cost tradeoffs of mid-session switching, when to use fast vs standard, fast mode vs effort level, requirements (extra usage, admin enablement), per-session opt-in (fastModePerSessionOptIn), rate limit fallback behavior, research preview status
- [Output styles](references/claude-code-output-styles.md) -- built-in styles (Default, Explanatory, Learning), how output styles modify the system prompt, /config selection, outputStyle setting, custom output style markdown files with frontmatter (name, description, keep-coding-instructions), user and project style directories, comparison with CLAUDE.md and --append-system-prompt and agents and skills
- [Status line](references/claude-code-statusline.md) -- /statusline command, manual configuration (statusLine setting with type/command/padding), build a status line step by step, how status lines work (update triggers, debouncing, multiple lines, ANSI colors, OSC 8 links), full JSON data schema (model, workspace, cost, context_window, vim, agent, worktree fields), context window field details, ready-to-use examples (context bar, git status with colors, cost tracking, multi-line display, clickable links, Windows PowerShell/Git Bash)
- [Checkpointing](references/claude-code-checkpointing.md) -- how checkpoints work (automatic tracking, persistence), rewind menu (Esc+Esc or /rewind), restore vs summarize actions, common use cases, limitations (bash/external changes not tracked, not a git replacement)
- [Remote Control](references/claude-code-remote-control.md) -- requirements (subscription plans, authentication, workspace trust), starting sessions (server mode, interactive mode, from existing session), server mode flags (--name, --spawn, --capacity, --verbose, --sandbox), connecting from another device (URL, QR code, session list), enabling for all sessions, connection and security model, Remote Control vs Claude Code on the web, limitations
- [Scheduled tasks](references/claude-code-scheduled-tasks.md) -- /loop skill for recurring prompts (interval syntax, looping over commands), one-time reminders in natural language, CronCreate/CronList/CronDelete tools, how tasks run (priority, local timezone, jitter, 3-day expiry), cron expression reference, CLAUDE_CODE_DISABLE_CRON, session-scoped limitations, alternatives for durable scheduling

## Sources

- Features overview: https://code.claude.com/docs/en/features-overview.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks: https://code.claude.com/docs/en/scheduled-tasks.md
