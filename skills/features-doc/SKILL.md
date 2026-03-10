---
name: features-doc
description: Complete documentation for Claude Code features -- extensibility overview (CLAUDE.md, Skills, Subagents, Agent teams, MCP, Hooks, Plugins), context costs and loading behavior, feature comparison tables, model configuration (aliases, availableModels, opusplan, effort levels, extended 1M context, prompt caching, model pinning for third-party providers), fast mode (toggling, cost tradeoff, rate limits, per-session opt-in), output styles (built-in Default/Explanatory/Learning, custom output style files, frontmatter options, keep-coding-instructions), status line customization (configuration, JSON session data schema, available fields, ANSI colors, multi-line display, clickable links, Windows support), checkpointing (automatic tracking, rewind/restore/summarize via Esc+Esc or /rewind), Remote Control (continue local sessions from browser/phone, session URL/QR code, connection security), and scheduled tasks (/loop, CronCreate/CronList/CronDelete tools, cron expressions, jitter, 3-day expiry, one-time reminders). Load when discussing model selection, fast mode, output styles, status line, checkpointing, rewind, Remote Control, scheduled tasks, /loop, or feature comparison.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features including extensibility, model configuration, fast mode, output styles, status line, checkpointing, Remote Control, and scheduled tasks.

## Quick Reference

### Extensibility Overview

Claude Code's extension layer adds capabilities beyond its built-in tools. Extensions plug into different parts of the agentic loop.

| Feature | What it does | When to use it |
|:--------|:-------------|:---------------|
| **CLAUDE.md** | Persistent context loaded every session | Project conventions, "always do X" rules |
| **Skill** | Instructions, knowledge, and workflows | Reusable content, reference docs, repeatable tasks |
| **Subagent** | Isolated execution context returning summaries | Context isolation, parallel tasks, specialized workers |
| **Agent teams** | Coordinate multiple independent sessions | Parallel research, new feature development, competing hypotheses |
| **MCP** | Connect to external services | External data or actions (database, Slack, browser) |
| **Hook** | Deterministic script on lifecycle events | Predictable automation, no LLM involved |
| **Plugin** | Package and distribute feature bundles | Reuse across repos, distribute via marketplace |

#### Context Cost by Feature

| Feature | When it loads | Context cost |
|:--------|:-------------|:-------------|
| CLAUDE.md | Session start | Every request (full content) |
| Skills | Descriptions at start, full on use | Low (descriptions every request) |
| MCP servers | Session start | Every request (tool definitions) |
| Subagents | When spawned | Isolated from main session |
| Hooks | On trigger | Zero (runs externally) |

#### Feature Layering

- **CLAUDE.md files**: additive (all levels contribute)
- **Skills and subagents**: override by name (priority-based)
- **MCP servers**: override by name (local > project > user)
- **Hooks**: merge (all registered hooks fire)

### Model Configuration

#### Model Aliases

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended model based on account type |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast/efficient Haiku for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opusplan` | Opus for planning, Sonnet for execution |

#### Setting the Model (priority order)

1. `/model <alias\|name>` -- during session
2. `claude --model <alias\|name>` -- at startup
3. `ANTHROPIC_MODEL=<alias\|name>` -- environment variable
4. `"model"` field in settings file

#### Default Model by Account Type

| Account type | Default model |
|:-------------|:-------------|
| Max, Team Premium | Opus 4.6 |
| Pro, Team Standard | Sonnet 4.6 |
| Enterprise | Opus 4.6 available but not default |

#### Effort Levels

Three levels: **low**, **medium**, **high**. Opus 4.6 defaults to medium for Max and Team subscribers.

| Setting method | How |
|:---------------|:----|
| `/model` | Left/right arrow keys for effort slider |
| Environment variable | `CLAUDE_CODE_EFFORT_LEVEL=low\|medium\|high` |
| Settings | `effortLevel` field |

Disable adaptive reasoning: set `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1` to revert to fixed thinking budget via `MAX_THINKING_TOKENS`.

#### Extended Context (1M tokens)

- Available for API/pay-as-you-go, and subscribers with extra usage enabled
- Standard rates up to 200K tokens; beyond 200K uses long-context pricing
- Disable: `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`
- Use `[1m]` suffix: `/model sonnet[1m]` or `/model claude-sonnet-4-6[1m]`

#### Restrict Model Selection

Use `availableModels` in managed/policy settings to restrict which models users can select:

```json
{
  "model": "sonnet",
  "availableModels": ["sonnet", "haiku"]
}
```

The `default` option is not affected by `availableModels` -- it always remains available.

#### Model Environment Variables

| Variable | Description |
|:---------|:------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for `opus` / `opusplan` plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` / `opusplan` execution mode |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for `haiku` / background functionality |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |

#### Prompt Caching

| Variable | Description |
|:---------|:------------|
| `DISABLE_PROMPT_CACHING` | `1` to disable for all models (takes precedence) |
| `DISABLE_PROMPT_CACHING_HAIKU` | `1` to disable for Haiku only |
| `DISABLE_PROMPT_CACHING_SONNET` | `1` to disable for Sonnet only |
| `DISABLE_PROMPT_CACHING_OPUS` | `1` to disable for Opus only |

### Fast Mode

Fast mode is a high-speed configuration for Opus 4.6 (2.5x faster, higher cost). Toggle with `/fast`. Not a different model -- same quality, lower latency.

#### Fast Mode Pricing

| Mode | Input (MTok) | Output (MTok) |
|:-----|:-------------|:-------------|
| Fast mode on Opus 4.6 (<200K) | $30 | $150 |
| Fast mode on Opus 4.6 (>200K) | $60 | $225 |

Compatible with 1M extended context window. Switching mid-conversation incurs full uncached input token price.

#### Requirements

- Not available on Bedrock, Vertex AI, or Foundry
- Extra usage must be enabled (billed directly, not from plan quota)
- Teams/Enterprise: admin must enable fast mode first

#### Fast Mode vs Effort Level

| Setting | Effect |
|:--------|:-------|
| Fast mode | Same quality, lower latency, higher cost |
| Lower effort level | Less thinking, faster, potentially lower quality |

Can combine both for maximum speed on straightforward tasks.

#### Per-Session Opt-In

Admins can set `"fastModePerSessionOptIn": true` in managed settings to require users to re-enable fast mode each session. Disable entirely with `CLAUDE_CODE_DISABLE_FAST_MODE=1`.

#### Rate Limits

When fast mode rate limit is hit: auto-fallback to standard Opus 4.6, gray icon indicates cooldown, auto-re-enables when cooldown expires.

### Output Styles

Output styles modify Claude Code's system prompt to adapt it for different use cases.

#### Built-in Styles

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Adds educational "Insights" between tasks |
| **Learning** | Learn-by-doing mode with `TODO(human)` markers for you to implement |

#### Changing Styles

- `/output-style` -- interactive menu
- `/output-style explanatory` -- switch directly
- Saved in `.claude/settings.local.json` as `outputStyle` field

#### Custom Output Styles

Markdown files with frontmatter, stored in `~/.claude/output-styles` (user) or `.claude/output-styles` (project).

| Frontmatter | Purpose | Default |
|:------------|:--------|:--------|
| `name` | Display name | File name |
| `description` | UI description | None |
| `keep-coding-instructions` | Keep coding-related system prompt | `false` |

Custom styles exclude coding instructions by default (unless `keep-coding-instructions: true`).

### Status Line

Customizable bar at the bottom of Claude Code that runs a shell script receiving JSON session data on stdin.

#### Configuration

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

Set in user settings (`~/.claude/settings.json`) or project settings. Use `/statusline <description>` to auto-generate. `padding` adds horizontal spacing (default 0).

#### Available JSON Data Fields

| Field | Description |
|:------|:------------|
| `model.id`, `model.display_name` | Current model |
| `cwd`, `workspace.current_dir` | Current working directory |
| `workspace.project_dir` | Launch directory |
| `cost.total_cost_usd` | Session cost in USD |
| `cost.total_duration_ms` | Wall-clock time since session start |
| `cost.total_api_duration_ms` | Time waiting for API responses |
| `cost.total_lines_added`, `cost.total_lines_removed` | Lines of code changed |
| `context_window.total_input_tokens`, `context_window.total_output_tokens` | Cumulative token counts |
| `context_window.context_window_size` | Max context (200000 or 1000000) |
| `context_window.used_percentage` | Pre-calculated context usage % |
| `context_window.remaining_percentage` | Pre-calculated context remaining % |
| `context_window.current_usage` | Token counts from last API call (null before first call) |
| `exceeds_200k_tokens` | Whether last response exceeded 200K tokens |
| `session_id` | Session identifier |
| `transcript_path` | Path to conversation transcript |
| `version` | Claude Code version |
| `output_style.name` | Current output style |
| `vim.mode` | Vim mode (`NORMAL`/`INSERT`) when enabled |
| `agent.name` | Agent name when running with `--agent` |
| `worktree.name`, `worktree.path`, `worktree.branch` | Active worktree info |

Updates after each assistant message, debounced at 300ms. Supports ANSI colors, multiple lines, and OSC 8 clickable links.

### Checkpointing

Claude Code automatically tracks file edits for undo/rewind capability.

- Every user prompt creates a checkpoint
- Checkpoints persist across sessions (cleaned up after 30 days)
- Only direct file edits tracked (not bash commands or external changes)

#### Rewind Menu

Press **Esc + Esc** or use `/rewind` to open the rewind menu. Actions:

| Action | Effect |
|:-------|:-------|
| **Restore code and conversation** | Revert both to selected point |
| **Restore conversation** | Rewind messages, keep current code |
| **Restore code** | Revert files, keep conversation |
| **Summarize from here** | Compress messages from this point forward into summary |

Summarize keeps early context intact and only compresses later messages. Original messages preserved in transcript. For branching off instead of compressing, use `claude --continue --fork-session`.

### Remote Control

Continue a local Claude Code session from browser, phone, or tablet. The session runs locally; web/mobile interfaces are just a window into it.

#### Starting a Session

| Method | Command |
|:-------|:--------|
| New session | `claude remote-control` |
| From existing session | `/remote-control` or `/rc` |
| Custom name | `claude remote-control --name "My Project"` |
| Enable for all sessions | `/config` > Enable Remote Control for all sessions |

Flags: `--name`, `--verbose`, `--sandbox` / `--no-sandbox`

#### Connecting

- Open the session URL displayed in terminal
- Scan the QR code (press spacebar in `claude remote-control` to toggle)
- Find the session in [claude.ai/code](https://claude.ai/code) or Claude mobile app

#### Requirements

- Pro, Max, Team, or Enterprise plan (Team/Enterprise admins must enable Claude Code)
- Signed in via `/login`
- Workspace trust accepted

#### Limitations

- One remote session per Claude Code instance
- Terminal must stay open
- Network outage >10 minutes causes timeout

### Scheduled Tasks

Session-scoped recurring or one-time prompts using cron. Tasks only fire while Claude Code is running and idle.

#### /loop Command

```
/loop 5m check if the deployment finished
/loop check the build every 2 hours
/loop 20m /review-pr 1234
```

| Interval form | Example | Result |
|:-------------|:--------|:-------|
| Leading token | `/loop 30m check the build` | Every 30 minutes |
| Trailing `every` clause | `/loop check the build every 2 hours` | Every 2 hours |
| No interval | `/loop check the build` | Default: every 10 minutes |

Units: `s` (seconds), `m` (minutes), `h` (hours), `d` (days). Seconds rounded up to nearest minute (cron granularity).

#### Cron Tools

| Tool | Purpose |
|:-----|:--------|
| `CronCreate` | Schedule a task (5-field cron expression, prompt, recur flag) |
| `CronList` | List all scheduled tasks with IDs |
| `CronDelete` | Cancel a task by ID |

#### One-Time Reminders

Use natural language: `remind me at 3pm to push the release branch` or `in 45 minutes, check the integration tests`.

#### Behavior

- Fires between turns (not mid-response); waits if Claude is busy
- All times in local timezone
- Jitter: recurring tasks up to 10% of period late (max 15 min); one-shot tasks up to 90s early
- Recurring tasks auto-expire after 3 days
- Max 50 tasks per session
- No catch-up for missed fires
- Disable: `CLAUDE_CODE_DISABLE_CRON=1`

#### Cron Expression Reference

Standard 5-field format: `minute hour day-of-month month day-of-week`. Supports `*`, single values, steps (`*/15`), ranges (`1-5`), comma lists. Day-of-week: `0`/`7` = Sunday. Extended syntax (`L`, `W`, `?`, name aliases) not supported.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code (features overview)](references/claude-code-features-overview.md) -- extensibility overview, feature comparison tables, context costs and loading behavior, feature layering and combination patterns
- [Fast mode](references/claude-code-fast-mode.md) -- toggling fast mode, cost tradeoff and pricing, when to use it, requirements, per-session opt-in, rate limit behavior
- [Model configuration](references/claude-code-model-config.md) -- model aliases, setting and restricting models, opusplan, effort levels, extended 1M context, model environment variables, prompt caching configuration
- [Output styles](references/claude-code-output-styles.md) -- built-in styles (Default, Explanatory, Learning), creating custom output styles, frontmatter options, comparison to CLAUDE.md and agents
- [Status line](references/claude-code-statusline.md) -- setup and configuration, JSON session data schema, available fields, ANSI colors, multi-line display, clickable links, Windows support, example scripts
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic edit tracking, rewind and restore, summarize from a point, limitations (bash/external changes not tracked)
- [Remote Control](references/claude-code-remote-control.md) -- continuing local sessions from browser/phone, starting and connecting to sessions, connection security, comparison to Claude Code on the web
- [Scheduled tasks](references/claude-code-scheduled-tasks.md) -- /loop command, CronCreate/CronList/CronDelete tools, interval syntax, one-time reminders, jitter, 3-day expiry, cron expression reference

## Sources

- Extend Claude Code (features overview): https://code.claude.com/docs/en/features-overview.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks: https://code.claude.com/docs/en/scheduled-tasks.md
