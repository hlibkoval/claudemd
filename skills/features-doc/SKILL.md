---
name: features-doc
description: Complete documentation for Claude Code features — model configuration (aliases, effort levels, extended 1M context, opusplan, availableModels, prompt caching), fast mode (toggling, cost tradeoff, rate limits, per-session opt-in), output styles (built-in styles, custom styles, frontmatter, keep-coding-instructions), status line customization (setup, JSON data fields, ANSI colors, multi-line, caching, examples), checkpointing (rewind, restore, summarize, /rewind menu), remote control (starting sessions, connecting from other devices, enabling for all sessions, security), scheduled tasks (/loop, cron scheduling, one-time reminders, CronCreate/CronList/CronDelete, jitter, 3-day expiry), and the extensibility features overview (CLAUDE.md vs skills vs subagents vs MCP vs hooks vs plugins, context costs, feature layering). Load when discussing model selection, switching models, /model command, fast mode, /fast, effort levels, 1M context, output styles, /output-style, status line, /statusline, checkpoints, /rewind, remote control, /remote-control, scheduled tasks, /loop, cron, or the features overview.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features including model configuration, fast mode, output styles, status line, checkpointing, remote control, scheduled tasks, and the extensibility features overview.

## Quick Reference

### Model Configuration

#### Model Aliases

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended model for your account type |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast, efficient Haiku for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opusplan` | Opus for planning, Sonnet for execution |

Aliases always resolve to the latest version. Pin with full model name (e.g. `claude-opus-4-6`) or environment variables.

#### Setting Your Model (priority order)

1. During session: `/model <alias|name>`
2. At startup: `claude --model <alias|name>`
3. Environment variable: `ANTHROPIC_MODEL=<alias|name>`
4. Settings file: `"model": "<alias|name>"`

#### Default Model by Account Type

| Account | Default |
|:--------|:--------|
| Max and Team Premium | Opus 4.6 |
| Pro and Team Standard | Sonnet 4.6 |
| Enterprise | Opus 4.6 available but not default |

#### Effort Levels

Three levels: **low**, **medium**, **high**. Opus 4.6 defaults to medium for Max/Team subscribers.

| Method | How to set |
|:-------|:-----------|
| `/model` dialog | Left/right arrow keys on effort slider |
| Environment variable | `CLAUDE_CODE_EFFORT_LEVEL=low\|medium\|high` |
| Settings file | `"effortLevel": "low\|medium\|high"` |

Disable adaptive reasoning: `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1` (reverts to fixed budget via `MAX_THINKING_TOKENS`).

#### Extended Context (1M tokens)

Available for Opus 4.6 and Sonnet 4.6. Standard rates apply up to 200K tokens; beyond that, long-context pricing kicks in. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`. Use the `[1m]` suffix: `/model sonnet[1m]`.

#### Restrict Model Selection (`availableModels`)

Set in managed/policy settings to limit which models users can switch to. The `default` model always remains available regardless of this setting.

#### Model Environment Variables

| Variable | Description |
|:---------|:------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for `opus` / `opusplan` plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` / `opusplan` execution mode |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for `haiku` / background functionality |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |

#### Prompt Caching Control

| Variable | Description |
|:---------|:------------|
| `DISABLE_PROMPT_CACHING` | `1` to disable for all models |
| `DISABLE_PROMPT_CACHING_HAIKU` | `1` to disable for Haiku only |
| `DISABLE_PROMPT_CACHING_SONNET` | `1` to disable for Sonnet only |
| `DISABLE_PROMPT_CACHING_OPUS` | `1` to disable for Opus only |

### Fast Mode

Fast mode is a high-speed Opus 4.6 configuration (2.5x faster, higher cost). Same model, same quality -- just faster responses. Toggle with `/fast`. The `↯` icon appears when active.

#### Fast Mode Pricing

| Mode | Input (MTok) | Output (MTok) |
|:-----|:-------------|:--------------|
| Fast mode (<200K) | $30 | $150 |
| Fast mode (>200K) | $60 | $225 |

Compatible with 1M extended context. Enable at session start for best cost efficiency -- switching mid-conversation pays full uncached input price for existing context.

#### Requirements

- Not available on Bedrock, Vertex AI, or Foundry
- Extra usage must be enabled (billed directly to extra usage from the first token)
- Teams/Enterprise: admin must explicitly enable fast mode

#### Rate Limit Behavior

When fast mode rate limit is hit: automatically falls back to standard Opus 4.6, `↯` icon turns gray, re-enables when cooldown expires.

#### Per-Session Opt-In

Set `"fastModePerSessionOptIn": true` in managed settings to require users to enable fast mode each session. Disable entirely with `CLAUDE_CODE_DISABLE_FAST_MODE=1`.

### Output Styles

Output styles modify Claude Code's system prompt to adapt it for different use cases.

#### Built-in Styles

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Provides educational "Insights" while coding |
| **Learning** | Collaborative learn-by-doing; adds `TODO(human)` markers for you to implement |

#### Switching Styles

- `/output-style` -- interactive menu
- `/output-style <style>` -- switch directly (e.g. `/output-style explanatory`)
- Settings: edit `outputStyle` field in settings file

Saved to `.claude/settings.local.json` (local project level).

#### Custom Output Styles

Markdown files with frontmatter, placed in `~/.claude/output-styles` (user) or `.claude/output-styles` (project).

| Frontmatter | Purpose | Default |
|:------------|:--------|:--------|
| `name` | Display name | File name |
| `description` | Shown in `/output-style` UI | None |
| `keep-coding-instructions` | Keep coding parts of system prompt | `false` |

Custom styles exclude coding instructions by default (unlike built-in styles). All styles exclude concise-output instructions and add periodic adherence reminders.

### Status Line

A customizable bar at the bottom of Claude Code that runs a shell script and displays its output. Receives JSON session data on stdin.

#### Setup

- `/statusline <description>` -- Claude generates and configures the script automatically
- Manual: set `statusLine` in settings with `"type": "command"` and `"command": "<path-or-inline>"`
- Optional `"padding"` field adds extra horizontal spacing (default: 0)

#### Available JSON Data Fields

| Field | Description |
|:------|:------------|
| `model.id`, `model.display_name` | Current model info |
| `cwd`, `workspace.current_dir` | Current working directory |
| `workspace.project_dir` | Launch directory |
| `cost.total_cost_usd` | Session cost in USD |
| `cost.total_duration_ms` | Wall-clock time since session start |
| `cost.total_api_duration_ms` | Time waiting for API responses |
| `cost.total_lines_added/removed` | Lines of code changed |
| `context_window.used_percentage` | Context window usage (input tokens only) |
| `context_window.remaining_percentage` | Context window remaining |
| `context_window.context_window_size` | Max context size (200K or 1M) |
| `context_window.current_usage` | Token counts from last API call (null before first call) |
| `exceeds_200k_tokens` | Whether last response exceeded 200K total tokens |
| `session_id` | Unique session identifier |
| `transcript_path` | Path to conversation transcript |
| `version` | Claude Code version |
| `output_style.name` | Current output style |
| `vim.mode` | Vim mode (`NORMAL`/`INSERT`), if enabled |
| `agent.name` | Agent name, if running with `--agent` |
| `worktree.*` | Worktree info (name, path, branch), if in worktree session |

#### Update Behavior

Runs after each assistant message, permission mode change, or vim mode toggle. Debounced at 300ms. Supports multiple output lines, ANSI colors, and OSC 8 clickable links. Does not consume API tokens.

### Checkpointing

Automatic tracking of Claude's file edits for quick undo and rewind.

#### How It Works

- Every user prompt creates a checkpoint
- Persists across sessions (cleaned up after 30 days, configurable)
- Only tracks direct file edits via Claude's tools (not bash commands or external changes)

#### Rewind Menu

Open with `Esc` + `Esc` or `/rewind`. Actions at any checkpoint:

| Action | Effect |
|:-------|:-------|
| **Restore code and conversation** | Revert both to that point |
| **Restore conversation** | Rewind messages, keep current code |
| **Restore code** | Revert files, keep conversation |
| **Summarize from here** | Compress subsequent messages into a summary (frees context, keeps early messages intact) |

Original prompt is restored to input field after restore or summarize.

### Remote Control

Continue a local Claude Code session from any device via claude.ai/code or the Claude mobile app. The session runs locally; remote devices are just a view into it.

#### Starting a Session

- New session: `claude remote-control` (flags: `--name`, `--verbose`, `--sandbox`/`--no-sandbox`)
- From existing session: `/remote-control` or `/rc` (optionally pass a name)

#### Connecting

- Open the session URL displayed in terminal
- Scan the QR code (press spacebar to toggle in `claude remote-control`)
- Find the session by name in claude.ai/code or the Claude app

#### Enable for All Sessions

Run `/config` and set **Enable Remote Control for all sessions** to `true`.

#### Key Properties

- Outbound HTTPS only; never opens inbound ports
- All traffic over TLS through Anthropic API
- One remote session per Claude Code instance
- Auto-reconnects after network drops; times out after ~10 minutes of continuous network outage

### Scheduled Tasks

Session-scoped scheduling for recurring prompts, polling, and one-time reminders. Tasks only fire while Claude Code is running and idle.

#### /loop (Recurring Prompts)

```
/loop 5m check if the deployment finished
/loop check the build every 2 hours
/loop 20m /review-pr 1234
```

Default interval: 10 minutes. Supported units: `s`, `m`, `h`, `d`. Seconds rounded up to nearest minute (cron granularity).

#### One-Time Reminders

Natural language scheduling:

```
remind me at 3pm to push the release branch
in 45 minutes, check whether the integration tests passed
```

#### Management Tools

| Tool | Purpose |
|:-----|:--------|
| `CronCreate` | Schedule a new task (cron expression + prompt + recurrence flag) |
| `CronList` | List all tasks with IDs, schedules, and prompts |
| `CronDelete` | Cancel a task by its 8-character ID |

Max 50 tasks per session. All times in local timezone.

#### Behavior

- Fires between user turns (waits if Claude is busy)
- Jitter: recurring tasks up to 10% of period late (max 15 min); one-shot tasks up to 90s early at :00/:30
- Recurring tasks auto-expire after 3 days
- No persistence across restarts; no catch-up for missed fires

Disable entirely: `CLAUDE_CODE_DISABLE_CRON=1`.

### Features Overview (Extensibility)

#### Feature Comparison

| Feature | What it does | When to use it |
|:--------|:-------------|:---------------|
| **CLAUDE.md** | Persistent context every session | Project conventions, "always do X" rules |
| **Skill** | Instructions, knowledge, workflows | Reusable content, reference docs, repeatable tasks |
| **Subagent** | Isolated execution context | Context isolation, parallel tasks |
| **Agent teams** | Coordinate multiple sessions | Parallel research, competing hypotheses |
| **MCP** | External service connections | External data or actions |
| **Hook** | Deterministic event-triggered scripts | Predictable automation, no LLM involved |

Plugins bundle skills, hooks, subagents, and MCP servers into installable units.

#### Context Cost by Feature

| Feature | When loaded | Cost |
|:--------|:-----------|:-----|
| CLAUDE.md | Session start | Every request |
| Skills | Descriptions at start, full on use | Low (descriptions per request) |
| MCP servers | Session start | Every request (tool search caps at 10%) |
| Subagents | When spawned | Isolated from main session |
| Hooks | On trigger | Zero (external execution) |

#### Feature Layering

- **CLAUDE.md**: additive across all levels; more specific takes precedence
- **Skills/subagents**: override by name with priority (managed > user > project)
- **MCP servers**: override by name (local > project > user)
- **Hooks**: merge; all registered hooks fire for matching events

## Full Documentation

For the complete official documentation, see the reference files:

- [Model configuration](references/claude-code-model-config.md) -- model aliases, setting models, restricting selection, opusplan, effort levels, extended 1M context, environment variables, prompt caching
- [Fast mode](references/claude-code-fast-mode.md) -- toggling, cost tradeoff, when to use, requirements, per-session opt-in, rate limits
- [Output styles](references/claude-code-output-styles.md) -- built-in styles, custom styles, frontmatter options, comparisons to CLAUDE.md and agents
- [Status line](references/claude-code-statusline.md) -- setup, /statusline command, JSON data fields, context window details, examples (progress bars, git status, cost tracking, multi-line, clickable links, caching, Windows)
- [Checkpointing](references/claude-code-checkpointing.md) -- how checkpoints work, rewind menu, restore vs summarize, limitations
- [Extensibility features overview](references/claude-code-features-overview.md) -- feature comparison table, CLAUDE.md vs skill vs subagent vs MCP vs hook, context costs, feature layering, combination patterns
- [Remote control](references/claude-code-remote-control.md) -- starting sessions, connecting from other devices, enabling for all sessions, connection security, comparison to Claude Code on the web
- [Scheduled tasks](references/claude-code-scheduled-tasks.md) -- /loop syntax, one-time reminders, CronCreate/CronList/CronDelete tools, jitter, 3-day expiry, cron expression reference

## Sources

- Model configuration: https://code.claude.com/docs/en/model-config.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Extensibility features overview: https://code.claude.com/docs/en/features-overview.md
- Remote control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks: https://code.claude.com/docs/en/scheduled-tasks.md
