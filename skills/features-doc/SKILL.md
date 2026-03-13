---
name: features-doc
description: Complete documentation for Claude Code features -- fast mode (toggling, pricing, cost tradeoffs, rate limits, per-session opt-in), model configuration (aliases like default/sonnet/opus/haiku/opusplan/sonnet[1m], setting models via CLI/env/settings, restricting models with availableModels, effort levels low/medium/high, extended 1M context, modelOverrides for third-party deployments, prompt caching env vars), output styles (built-in Default/Explanatory/Learning, custom output style files with frontmatter, keep-coding-instructions, comparisons to CLAUDE.md and agents and skills), status line (custom shell scripts, JSON session data on stdin, available fields like model/cost/context_window/git/vim/worktree, ANSI colors, multi-line output, /statusline command, Windows support), checkpointing (automatic edit tracking, Esc+Esc rewind menu, restore code/conversation/both, summarize from here, /rewind command, limitations), extending Claude Code (features overview with CLAUDE.md/skills/MCP/subagents/agent-teams/hooks/plugins, feature comparison tables, context costs, loading behavior, combining features), Remote Control (continue local sessions from phone/tablet/browser, claude remote-control, /remote-control or /rc, QR code, session URL, connection security), and scheduled tasks (/loop for recurring prompts, one-time reminders, CronCreate/CronList/CronDelete tools, cron expressions, jitter, 3-day expiry, session-scoped). Load when discussing fast mode, model selection, model aliases, opusplan, effort level, extended context, 1M context, output styles, status line, statusline, checkpointing, rewind, extending Claude Code, features overview, Remote Control, scheduled tasks, /loop, cron scheduling, or any Claude Code feature configuration.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features including fast mode, model configuration, output styles, status line, checkpointing, extensibility overview, Remote Control, and scheduled tasks.

## Quick Reference

### Fast Mode

Toggle fast mode with `/fast` or set `"fastMode": true` in settings. Fast mode makes Opus 4.6 responses 2.5x faster at higher per-token cost. It is not a different model -- same quality, lower latency.

| Mode | Input (MTok) | Output (MTok) |
|:-----|:-------------|:--------------|
| Fast mode on Opus 4.6 (<200K) | $30 | $150 |
| Fast mode on Opus 4.6 (>200K) | $60 | $225 |

Key details:
- Available on all subscription plans (Pro/Max/Team/Enterprise) and Console, via extra usage only
- Enable from start of session for best cost efficiency (mid-session switch reprices entire context)
- Rate limit fallback: auto-falls back to standard Opus 4.6, grey icon indicates cooldown
- Teams/Enterprise: admin must enable first; disabled by default
- Disable entirely: `CLAUDE_CODE_DISABLE_FAST_MODE=1`
- Per-session opt-in: set `fastModePerSessionOptIn: true` in managed settings to reset each session

### Model Configuration

#### Model Aliases

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended model based on account type |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast Haiku for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opusplan` | Opus during plan mode, Sonnet for execution |

#### Setting the Model (priority order)

1. During session: `/model <alias|name>`
2. At startup: `claude --model <alias|name>`
3. Environment variable: `ANTHROPIC_MODEL=<alias|name>`
4. Settings file: `"model": "<alias|name>"`

#### Default Model by Account Type

| Account | Default |
|:--------|:--------|
| Max, Team Premium | Opus 4.6 |
| Pro, Team Standard | Sonnet 4.6 |
| Enterprise | Opus 4.6 available but not default |

#### Restrict Model Selection

Set `availableModels` in managed/policy settings to restrict which models users can select. The `Default` option always remains available regardless.

```json
{ "availableModels": ["sonnet", "haiku"] }
```

#### Effort Level

Three levels: **low**, **medium**, **high**. Opus 4.6 defaults to medium for Max/Team subscribers.

| Setting method | How |
|:---------------|:----|
| In `/model` | Left/right arrow keys for effort slider |
| Environment variable | `CLAUDE_CODE_EFFORT_LEVEL=low\|medium\|high` |
| Settings | `"effortLevel": "low\|medium\|high"` |

Disable adaptive reasoning: `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1` (reverts to fixed budget via `MAX_THINKING_TOKENS`).

#### Extended Context (1M)

Opus 4.6 and Sonnet 4.6 support 1M token context. Standard rates apply up to 200K tokens; beyond that, long-context pricing kicks in.

- Append `[1m]` to any alias or model name: `/model sonnet[1m]`
- Disable: `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`
- Requires extra usage enabled for subscribers

#### Model Environment Variables

| Variable | Controls |
|:---------|:---------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `opus` alias and `opusplan` in plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `sonnet` alias and `opusplan` in execution mode |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `haiku` alias and background functionality |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |

#### Model Overrides for Third-Party Providers

Use `modelOverrides` in settings to map Anthropic model IDs to provider-specific IDs (Bedrock ARNs, Vertex names, Foundry deployments):

```json
{
  "modelOverrides": {
    "claude-opus-4-6": "arn:aws:bedrock:us-east-2:...:application-inference-profile/opus-prod",
    "claude-sonnet-4-6": "arn:aws:bedrock:us-east-2:...:application-inference-profile/sonnet-prod"
  }
}
```

#### Prompt Caching Environment Variables

| Variable | Effect |
|:---------|:-------|
| `DISABLE_PROMPT_CACHING` | Disable for all models (overrides per-model) |
| `DISABLE_PROMPT_CACHING_HAIKU` | Disable for Haiku only |
| `DISABLE_PROMPT_CACHING_SONNET` | Disable for Sonnet only |
| `DISABLE_PROMPT_CACHING_OPUS` | Disable for Opus only |

### Output Styles

Output styles modify Claude Code's system prompt to adapt it for different use cases.

#### Built-in Styles

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Adds educational "Insights" between coding tasks |
| **Learning** | Collaborative mode with `TODO(human)` markers for you to implement |

#### Changing Styles

- Run `/config` and select **Output style**
- Or set `"outputStyle": "Explanatory"` in settings
- Changes take effect on next session start (for prompt caching stability)

#### Custom Output Styles

Save Markdown files with frontmatter to `~/.claude/output-styles/` (user) or `.claude/output-styles/` (project):

| Frontmatter | Purpose | Default |
|:------------|:--------|:--------|
| `name` | Display name | File name |
| `description` | Shown in `/config` picker | None |
| `keep-coding-instructions` | Keep coding parts of system prompt | `false` |

Custom styles exclude default coding instructions unless `keep-coding-instructions: true`.

### Status Line

A customizable bar at the bottom of Claude Code that runs a shell script receiving JSON session data on stdin.

#### Setup

- Quick: `/statusline show model name and context percentage with a progress bar`
- Manual: set `statusLine` in settings:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

#### Key Available Data Fields

| Field | Description |
|:------|:------------|
| `model.id`, `model.display_name` | Current model |
| `workspace.current_dir`, `workspace.project_dir` | Directories |
| `cost.total_cost_usd` | Session cost in USD |
| `cost.total_duration_ms` | Wall-clock time since session start |
| `cost.total_lines_added`, `cost.total_lines_removed` | Lines changed |
| `context_window.used_percentage` | Context usage percentage |
| `context_window.context_window_size` | Max context (200K or 1M) |
| `context_window.current_usage.*` | Tokens from last API call |
| `session_id` | Session identifier |
| `vim.mode` | Vim mode (if enabled) |
| `worktree.name`, `worktree.path` | Active worktree info |
| `output_style.name` | Current output style |

Scripts can output multiple lines, ANSI colors, and OSC 8 clickable links. Updates run after each assistant message, debounced at 300ms. Does not consume API tokens.

### Checkpointing

Automatic tracking of Claude's file edits for quick undo/rewind.

#### How It Works

- Every user prompt creates a checkpoint
- Checkpoints persist across sessions (cleaned up after 30 days)
- Only tracks direct file edits via Claude's tools (not bash commands or external changes)

#### Rewind Menu

Open with **Esc + Esc** or `/rewind`. Actions available:

| Action | Effect |
|:-------|:-------|
| **Restore code and conversation** | Revert both to that point |
| **Restore conversation** | Rewind messages, keep current code |
| **Restore code** | Revert files, keep conversation |
| **Summarize from here** | Compress subsequent messages into a summary (frees context) |

Summarize differs from restore: it replaces messages with a compact summary while keeping files unchanged. Original messages are preserved in the transcript for reference. Similar to `/compact` but targeted at a specific point.

### Extending Claude Code (Features Overview)

Overview of all extension points and when to use each.

| Feature | What it does | When to use |
|:--------|:-------------|:------------|
| **CLAUDE.md** | Persistent context every session | Project conventions, "always do X" rules |
| **Skill** | Instructions, knowledge, workflows | Reusable content, reference docs, repeatable tasks |
| **Subagent** | Isolated execution context | Context isolation, parallel tasks |
| **Agent teams** | Multiple independent sessions | Parallel research, competing hypotheses |
| **MCP** | External service connections | Database queries, Slack, browser control |
| **Hook** | Deterministic script on events | Linting after edits, logging |
| **Plugin** | Packages skills/hooks/MCP/agents | Cross-repo reuse, distribution |

#### Context Cost by Feature

| Feature | Loads | Context cost |
|:--------|:------|:-------------|
| CLAUDE.md | Session start | Every request |
| Skills | Descriptions at start, full on use | Low until used |
| MCP | Session start | Every request (tool search caps at 10%) |
| Subagents | When spawned | Isolated |
| Hooks | On trigger | Zero (unless returning output) |

#### Feature Layering

- **CLAUDE.md**: additive across all levels
- **Skills/Subagents**: override by name (priority: managed > user > project)
- **MCP servers**: override by name (local > project > user)
- **Hooks**: merge (all fire for matching events)

### Remote Control

Continue a local Claude Code session from your phone, tablet, or any browser.

#### Starting a Session

| Method | Command |
|:-------|:--------|
| New session | `claude remote-control` (with optional `--name "My Project"`) |
| From existing session | `/remote-control` or `/rc` (with optional name argument) |

Flags for `claude remote-control`: `--name`, `--verbose`, `--sandbox`/`--no-sandbox`.

#### Connecting from Another Device

- Open the session URL displayed in terminal
- Scan the QR code (press spacebar to toggle in `claude remote-control`)
- Find the session in [claude.ai/code](https://claude.ai/code) or Claude app (green dot = online)

#### Key Properties

- Session runs locally -- full filesystem, MCP servers, and project config stay available
- Conversation syncs across all connected devices
- Auto-reconnects after sleep or network drops
- Enable for all sessions via `/config` > **Enable Remote Control for all sessions**
- One remote session per Claude Code instance
- All traffic over HTTPS through Anthropic API (no inbound ports)

### Scheduled Tasks

Session-scoped recurring and one-time prompts using `/loop` and cron tools.

#### /loop Command

```
/loop 5m check if the deployment finished and tell me what happened
/loop check the build every 2 hours
/loop 20m /review-pr 1234
```

Interval syntax: `s` (seconds), `m` (minutes), `h` (hours), `d` (days). Default: 10 minutes. Seconds rounded up to nearest minute.

#### One-Time Reminders

Natural language scheduling:
```
remind me at 3pm to push the release branch
in 45 minutes, check whether the integration tests passed
```

#### Cron Tools

| Tool | Purpose |
|:-----|:--------|
| `CronCreate` | Schedule new task (5-field cron expression) |
| `CronList` | List all tasks with IDs, schedules, prompts |
| `CronDelete` | Cancel task by 8-character ID |

#### Behavior

- Tasks fire between user turns (wait if Claude is busy)
- All times in local timezone
- Jitter: recurring up to 10% of period (max 15 min); one-shot up to 90s
- 3-day auto-expiry for recurring tasks
- Max 50 tasks per session
- Session-scoped only (lost on exit, no persistence)
- Disable: `CLAUDE_CODE_DISABLE_CRON=1`

For durable scheduling, use Desktop scheduled tasks or GitHub Actions.

## Full Documentation

For the complete official documentation, see the reference files:

- [Speed up responses with fast mode](references/claude-code-fast-mode.md) -- toggling fast mode, pricing table, cost tradeoffs (mid-session switching), when to use fast mode vs effort level, requirements (extra usage, admin enablement), per-session opt-in with `fastModePerSessionOptIn`, rate limit fallback behavior, research preview status
- [Model configuration](references/claude-code-model-config.md) -- model aliases (default/sonnet/opus/haiku/opusplan/sonnet[1m]), setting models (CLI/env/settings), restricting selection with `availableModels`, default model by account type, `opusplan` hybrid behavior, effort levels (low/medium/high), extended 1M context window, environment variables for alias overrides, `modelOverrides` for third-party providers, prompt caching configuration
- [Output styles](references/claude-code-output-styles.md) -- built-in styles (Default/Explanatory/Learning), how output styles modify the system prompt, changing styles via `/config` or settings, creating custom output style files with frontmatter, comparisons to CLAUDE.md, agents, and skills
- [Customize your status line](references/claude-code-statusline.md) -- setup via `/statusline` command or manual config, JSON data schema (model, workspace, cost, context_window, vim, worktree, agent fields), ANSI colors and OSC 8 links, multi-line output, examples (context bars, git status, cost tracking), Windows configuration
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic edit tracking, rewind menu (Esc+Esc or /rewind), restore code/conversation/both, summarize from a point, limitations (bash commands not tracked, external changes not tracked, not a git replacement)
- [Extend Claude Code](references/claude-code-features-overview.md) -- features overview comparing CLAUDE.md/skills/subagents/agent-teams/MCP/hooks/plugins, feature comparison tabs (skill vs subagent, CLAUDE.md vs skill, etc.), context costs and loading behavior, feature layering and merging rules, combining features patterns
- [Remote Control](references/claude-code-remote-control.md) -- starting sessions (`claude remote-control`, `/remote-control`), connecting from phone/tablet/browser, session URL and QR code, enabling for all sessions, connection security (HTTPS, no inbound ports), comparison to Claude Code on the web, limitations
- [Run prompts on a schedule](references/claude-code-scheduled-tasks.md) -- `/loop` command with interval syntax, one-time reminders, CronCreate/CronList/CronDelete tools, cron expression reference, jitter behavior, 3-day auto-expiry, session-scoped limitations, disabling with `CLAUDE_CODE_DISABLE_CRON`

## Sources

- Speed up responses with fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Customize your status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Extend Claude Code: https://code.claude.com/docs/en/features-overview.md
- Continue local sessions with Remote Control: https://code.claude.com/docs/en/remote-control.md
- Run prompts on a schedule: https://code.claude.com/docs/en/scheduled-tasks.md
