---
name: features-doc
description: Complete documentation for Claude Code features -- model configuration (model aliases default/sonnet/opus/haiku/opusplan/sonnet[1m], model selection priority, availableModels allowlist, modelOverrides for Bedrock/Vertex/Foundry, effort levels low/medium/high, adaptive reasoning, extended 1M context, prompt caching configuration, environment variables ANTHROPIC_MODEL/ANTHROPIC_DEFAULT_OPUS_MODEL/ANTHROPIC_DEFAULT_SONNET_MODEL/ANTHROPIC_DEFAULT_HAIKU_MODEL/CLAUDE_CODE_SUBAGENT_MODEL), fast mode (2.5x faster Opus 4.6, /fast toggle, pricing, per-session opt-in, rate limit fallback, research preview), output styles (Default/Explanatory/Learning, custom output styles with frontmatter, keep-coding-instructions, system prompt modification), status line (customizable bottom bar, /statusline command, JSON session data on stdin, available data fields for model/cost/context/git/worktree, ANSI colors, OSC 8 links, multi-line output, caching patterns, Windows PowerShell support), checkpointing (automatic edit tracking, Esc+Esc or /rewind, restore code/conversation/both, summarize from checkpoint, session-level recovery), features overview (extension system comparison table: CLAUDE.md vs Skills vs Subagents vs MCP vs Hooks vs Plugins, context loading and costs, feature layering and combining), remote control (continue local sessions from phone/tablet/browser, claude remote-control, /remote-control or /rc, QR code, session URL, local execution with remote UI, auto-reconnect), scheduled tasks (/loop for recurring prompts, one-time reminders, CronCreate/CronList/CronDelete tools, interval syntax, jitter, 3-day expiry, session-scoped, cron expressions). Load when discussing Claude Code model selection, model aliases, opusplan, effort levels, adaptive reasoning, fast mode, output styles, status line, statusline configuration, checkpointing, rewind, features overview, extension comparison, context costs, remote control, remote sessions, scheduled tasks, /loop, cron, or any Claude Code feature configuration.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features including model configuration, fast mode, output styles, status line, checkpointing, features overview, remote control, and scheduled tasks.

## Quick Reference

### Model Configuration

#### Model Aliases

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended model based on account type |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast Haiku for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opusplan` | Opus for planning, Sonnet for execution |

Aliases always resolve to the latest version. Pin with full model name (e.g., `claude-opus-4-6`) or environment variables.

#### Model Selection Priority

1. During session: `/model <alias|name>`
2. At startup: `claude --model <alias|name>`
3. Environment variable: `ANTHROPIC_MODEL=<alias|name>`
4. Settings file: `"model": "opus"`

#### Default Model by Account Type

| Account | Default |
|:--------|:--------|
| Max, Team Premium | Opus 4.6 |
| Pro, Team Standard | Sonnet 4.6 |
| Enterprise | Opus available but not default |

#### availableModels Allowlist

Set in managed/policy settings to restrict model selection. The `default` option always remains available.

```json
{ "availableModels": ["sonnet", "haiku"] }
```

When set at multiple levels, arrays are merged and deduplicated.

#### modelOverrides

Maps Anthropic model IDs to provider-specific strings (Bedrock ARNs, Vertex version names, Foundry deployment names):

```json
{
  "modelOverrides": {
    "claude-opus-4-6": "arn:aws:bedrock:us-east-2:123456789012:...",
    "claude-sonnet-4-6": "arn:aws:bedrock:us-east-2:123456789012:..."
  }
}
```

Keys must be Anthropic model IDs. Overrides replace built-in IDs in the `/model` picker. Direct values via `ANTHROPIC_MODEL` or `--model` bypass overrides.

#### Effort Levels

Three levels: **low**, **medium**, **high**. Opus 4.6 defaults to medium for Max/Team subscribers.

| Setting method | How |
|:---------------|:----|
| `/model` picker | Left/right arrow keys for effort slider |
| Environment variable | `CLAUDE_CODE_EFFORT_LEVEL=low\|medium\|high` |
| Settings file | `"effortLevel": "low"` |

Supported on Opus 4.6 and Sonnet 4.6. Set `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1` to revert to fixed thinking budget (`MAX_THINKING_TOKENS`).

#### Extended Context (1M)

Opus 4.6 and Sonnet 4.6 support 1M token context (beta). Standard rates up to 200K tokens; beyond 200K, long-context pricing applies. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

Use `[1m]` suffix: `/model sonnet[1m]` or `/model claude-sonnet-4-6[1m]`.

#### Model Environment Variables

| Variable | Description |
|:---------|:------------|
| `ANTHROPIC_MODEL` | Override model selection |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model ID for `opus` alias |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model ID for `sonnet` alias |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model ID for `haiku` alias |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |

#### Prompt Caching Environment Variables

| Variable | Description |
|:---------|:------------|
| `DISABLE_PROMPT_CACHING` | `1` to disable all caching (overrides per-model) |
| `DISABLE_PROMPT_CACHING_HAIKU` | `1` to disable for Haiku only |
| `DISABLE_PROMPT_CACHING_SONNET` | `1` to disable for Sonnet only |
| `DISABLE_PROMPT_CACHING_OPUS` | `1` to disable for Opus only |

---

### Fast Mode

2.5x faster Opus 4.6 at higher cost. Same model quality, different API configuration. Research preview.

| Detail | Value |
|:-------|:------|
| Toggle | `/fast` (Tab to toggle) or `"fastMode": true` in settings |
| Indicator | `↯` icon next to prompt (gray during cooldown) |
| Pricing (<200K) | $30/MTok input, $150/MTok output |
| Pricing (>200K) | $60/MTok input, $225/MTok output |
| Availability | Subscription plans (Pro/Max/Team/Enterprise) + Console, extra usage only |
| Not available on | Bedrock, Vertex AI, Foundry |

Fast mode persists across sessions by default. Admins can require per-session opt-in with `"fastModePerSessionOptIn": true` in managed settings. Disable entirely with `CLAUDE_CODE_DISABLE_FAST_MODE=1`.

**Rate limits:** Separate from standard Opus. On limit hit, auto-falls back to standard Opus (gray `↯`), re-enables when cooldown expires.

**Fast mode vs effort level:** Fast mode gives same quality at lower latency and higher cost. Lower effort gives less thinking time and potentially lower quality. Both can be combined.

---

### Output Styles

Modify Claude Code's system prompt to adapt behavior for different use cases.

#### Built-in Styles

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Shares educational "Insights" while coding |
| **Learning** | Collaborative mode with `TODO(human)` markers for you to implement |

#### Changing Style

- `/config` > Output style (saved to `.claude/settings.local.json`)
- Or edit `"outputStyle": "Explanatory"` in settings directly
- Changes take effect at next session start

#### Custom Output Styles

Markdown files with frontmatter in `~/.claude/output-styles` (user) or `.claude/output-styles` (project).

| Frontmatter | Purpose | Default |
|:------------|:--------|:--------|
| `name` | Display name | File name |
| `description` | Shown in `/config` picker | None |
| `keep-coding-instructions` | Keep coding parts of default system prompt | `false` |

Custom styles exclude coding instructions unless `keep-coding-instructions` is true. All styles exclude conciseness instructions.

---

### Status Line

Customizable bar at the bottom of Claude Code. Runs a shell script that receives JSON session data on stdin and prints output.

#### Setup

- `/statusline <description>` -- auto-generates script and updates settings
- Manual: set `"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}` in settings
- Optional `"padding": 2` for extra horizontal spacing

#### Available Data Fields

| Field | Description |
|:------|:------------|
| `model.id`, `model.display_name` | Current model |
| `cwd`, `workspace.current_dir` | Working directory |
| `workspace.project_dir` | Launch directory |
| `cost.total_cost_usd` | Session cost in USD |
| `cost.total_duration_ms` | Wall-clock time since session start |
| `cost.total_api_duration_ms` | Time waiting for API |
| `cost.total_lines_added`, `cost.total_lines_removed` | Lines changed |
| `context_window.total_input_tokens`, `.total_output_tokens` | Cumulative token counts |
| `context_window.context_window_size` | Max context (200K or 1M) |
| `context_window.used_percentage` | Pre-calculated usage % |
| `context_window.remaining_percentage` | Pre-calculated remaining % |
| `context_window.current_usage` | Last API call token breakdown |
| `exceeds_200k_tokens` | Whether last response exceeded 200K |
| `session_id` | Session identifier |
| `transcript_path` | Path to transcript file |
| `version` | Claude Code version |
| `output_style.name` | Current output style |
| `vim.mode` | Vim mode (if enabled) |
| `agent.name` | Agent name (if --agent) |
| `worktree.*` | Worktree name, path, branch, original_cwd, original_branch |

#### Key Behaviors

- Updates after each assistant message, permission mode change, or vim mode toggle (300ms debounce)
- Supports multiple lines (each print/echo = separate row)
- Supports ANSI colors and OSC 8 clickable links
- Does not consume API tokens
- Cache slow operations (e.g., git) to temp files with TTL
- `disableAllHooks: true` also disables the status line
- Windows: runs through Git Bash, can invoke PowerShell

---

### Checkpointing

Automatic tracking of Claude's file edits for session-level recovery.

| Feature | Details |
|:--------|:--------|
| Access | `Esc` + `Esc` or `/rewind` |
| Scope | Every user prompt creates a checkpoint |
| Persistence | Across sessions; cleaned up after 30 days (configurable) |

#### Rewind Actions

| Action | Effect |
|:-------|:-------|
| **Restore code and conversation** | Revert both to selected point |
| **Restore conversation** | Rewind messages, keep current code |
| **Restore code** | Revert files, keep conversation |
| **Summarize from here** | Compress messages from point forward into summary |

Summarize keeps early context intact and only compresses later messages. Original messages preserved in transcript. For branching instead of summarizing, use fork: `claude --continue --fork-session`.

#### Limitations

- Bash command file changes (rm, mv, cp) not tracked
- External/concurrent session changes normally not captured
- Not a replacement for git -- checkpoints are session-level undo

---

### Features Overview (Extension System)

#### Feature Comparison

| Feature | What it does | When to use |
|:--------|:-------------|:------------|
| **CLAUDE.md** | Persistent context every session | Project conventions, "always do X" rules |
| **Skill** | Instructions/knowledge/workflows | Reusable content, reference docs, repeatable tasks |
| **Subagent** | Isolated execution context | Context isolation, parallel tasks |
| **Agent teams** | Coordinate multiple sessions | Parallel research, competing hypotheses |
| **MCP** | Connect to external services | External data or actions |
| **Hook** | Deterministic script on events | Predictable automation, no LLM |

**Plugins** bundle skills, hooks, subagents, and MCP into installable units.

#### Context Cost by Feature

| Feature | When it loads | Context cost |
|:--------|:-------------|:-------------|
| CLAUDE.md | Session start | Every request |
| Skills | Start (descriptions) + when used (full) | Low until used |
| MCP servers | Session start (tool definitions) | Every request |
| Subagents | When spawned | Isolated |
| Hooks | On trigger | Zero (unless returns context) |

#### Feature Layering

- **CLAUDE.md**: additive (all levels contribute)
- **Skills/subagents**: override by name (priority: managed > user > project)
- **MCP servers**: override by name (local > project > user)
- **Hooks**: merge (all matching hooks fire)

---

### Remote Control

Continue local Claude Code sessions from phone, tablet, or any browser via claude.ai/code or Claude mobile app.

| Detail | Value |
|:-------|:------|
| Start new | `claude remote-control [--name "title"]` |
| From existing session | `/remote-control` or `/rc` |
| Connect | Open session URL, scan QR code (spacebar to show), or find in claude.ai/code session list |
| Enable for all sessions | `/config` > Enable Remote Control |
| Requirements | Subscription plan + `/login` auth + workspace trust |

Flags for `claude remote-control`: `--name`, `--verbose`, `--sandbox` / `--no-sandbox`.

**Key properties:** Session runs locally (filesystem, MCP, tools stay available). Conversation syncs across all connected devices. Auto-reconnects on network recovery. One remote session per Claude Code instance.

**Limitations:** Terminal must stay open; extended network outage (~10 min) times out.

---

### Scheduled Tasks

Session-scoped recurring prompts and one-time reminders using cron.

#### /loop

```
/loop 5m check if the deployment finished
/loop check the build every 2 hours
/loop 20m /review-pr 1234
```

Supported units: `s` (seconds), `m` (minutes), `h` (hours), `d` (days). Default interval: 10 minutes.

#### One-Time Reminders

```
remind me at 3pm to push the release branch
in 45 minutes, check whether the integration tests passed
```

#### Cron Tools

| Tool | Purpose |
|:-----|:--------|
| `CronCreate` | Schedule task (5-field cron, prompt, recur flag) |
| `CronList` | List tasks with IDs, schedules, prompts |
| `CronDelete` | Cancel by 8-character ID |

Max 50 tasks per session.

#### Key Behaviors

- Tasks fire between turns (low priority), not mid-response
- All times in local timezone
- Recurring tasks: jitter up to 10% of period (max 15 min)
- One-shot tasks at :00/:30: jitter up to 90 seconds early
- Recurring tasks auto-expire after 3 days
- No persistence across restarts; no catch-up for missed fires
- Disable with `CLAUDE_CODE_DISABLE_CRON=1`

#### Cron Expression Format

5-field: `minute hour day-of-month month day-of-week`. Supports `*`, single values, steps (`*/15`), ranges (`1-5`), lists (`1,15,30`). Day-of-week: 0 or 7 = Sunday. No extended syntax (L, W, ?, name aliases).

## Full Documentation

For the complete official documentation, see the reference files:

- [Model configuration](references/claude-code-model-config.md) -- model aliases, setting/restricting models, opusplan, effort levels, extended context, environment variables, modelOverrides, prompt caching
- [Fast mode](references/claude-code-fast-mode.md) -- toggling fast mode, pricing, when to use, requirements, per-session opt-in, rate limits, research preview
- [Output styles](references/claude-code-output-styles.md) -- built-in styles, custom output style creation, frontmatter options, comparison with CLAUDE.md/agents/skills
- [Status line](references/claude-code-statusline.md) -- setup, /statusline command, JSON data schema, available fields, examples (context bar, git status, cost tracking, multi-line, clickable links, caching), Windows support, troubleshooting
- [Checkpointing](references/claude-code-checkpointing.md) -- how checkpoints work, rewind/restore/summarize actions, limitations
- [Features overview](references/claude-code-features-overview.md) -- extension system comparison (CLAUDE.md vs Skills vs Subagents vs MCP vs Hooks vs Plugins), context costs, feature layering and combining
- [Remote control](references/claude-code-remote-control.md) -- starting remote sessions, connecting from other devices, connection security, comparison with Claude Code on the web
- [Scheduled tasks](references/claude-code-scheduled-tasks.md) -- /loop skill, one-time reminders, CronCreate/CronList/CronDelete, cron expressions, jitter, expiry, limitations

## Sources

- Model configuration: https://code.claude.com/docs/en/model-config.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Features overview: https://code.claude.com/docs/en/features-overview.md
- Remote control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks: https://code.claude.com/docs/en/scheduled-tasks.md
