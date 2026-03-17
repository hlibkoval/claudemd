---
name: features-doc
description: Complete documentation for Claude Code features -- features overview (extension layer with CLAUDE.md/Skills/MCP/Subagents/Agent teams/Hooks/Plugins, feature comparison table, context costs per feature, how features load and layer), fast mode (2.5x faster Opus 4.6 toggle with /fast, pricing $30/150 MTok, rate limit fallback, per-session opt-in with fastModePerSessionOptIn, research preview), model configuration (model aliases default/sonnet/opus/haiku/sonnet[1m]/opus[1m]/opusplan, setting model via /model or --model or ANTHROPIC_MODEL or settings, availableModels restriction, opusplan hybrid mode, effort levels low/medium/high/max with /effort, extended 1M context, prompt caching configuration, modelOverrides for third-party deployments, pinning model versions for Bedrock/Vertex/Foundry), output styles (built-in Default/Explanatory/Learning styles, custom output styles with frontmatter, keep-coding-instructions, system prompt modification, /config to change style), status line (custom shell-script status bar, /statusline command, statusLine settings with type/command/padding, JSON session data on stdin with model/workspace/cost/context_window/vim/agent/worktree fields, ANSI colors, multi-line output, examples for context bar/git status/cost tracking), checkpointing (automatic edit tracking, Esc+Esc or /rewind to open rewind menu, restore code/conversation/both, summarize from a point, limitations with bash commands and external changes), remote control (continue local sessions from any device, claude remote-control server mode with --spawn/--capacity, claude --remote-control or /remote-control, connection via URL/QR/session list, enable for all sessions via /config, HTTPS-only outbound connection), scheduled tasks (/loop bundled skill for recurring prompts with interval syntax s/m/h/d, one-time reminders in natural language, CronCreate/CronList/CronDelete tools, session-scoped 3-day expiry, jitter, CLAUDE_CODE_DISABLE_CRON=1). Load when discussing Claude Code features, fast mode, /fast, model configuration, model aliases, opusplan, effort levels, /effort, /model, output styles, custom output styles, status line, /statusline, statusLine settings, checkpointing, /rewind, undo changes, restore code, remote control, /remote-control, remote sessions, scheduled tasks, /loop, cron, reminders, extending Claude Code, feature comparison, context costs, or how features layer.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features: the features overview (extension layer), fast mode, model configuration, output styles, status line, checkpointing, remote control, and scheduled tasks.

## Quick Reference

### Extension Layer Overview

Claude Code's extension layer lets you customize what Claude knows, connect it to external services, and automate workflows. Extensions plug into different parts of the agentic loop.

| Feature | What it does | When to use it |
|:--------|:-------------|:---------------|
| **CLAUDE.md** | Persistent context loaded every conversation | Project conventions, "always do X" rules |
| **Skill** | Instructions, knowledge, and workflows Claude can use | Reusable content, reference docs, repeatable tasks |
| **Subagent** | Isolated execution context that returns summarized results | Context isolation, parallel tasks, specialized workers |
| **Agent teams** | Coordinate multiple independent Claude Code sessions | Parallel research, new feature development, debugging |
| **MCP** | Connect to external services | External data or actions |
| **Hook** | Deterministic script that runs on events | Predictable automation, no LLM involved |
| **Plugins** | Bundle skills, hooks, subagents, and MCP servers | Reuse across repos, distribute to others |

#### Context Cost by Feature

| Feature | When it loads | Context cost |
|:--------|:-------------|:-------------|
| **CLAUDE.md** | Session start | Every request |
| **Skills** | Session start + when used | Low (descriptions every request) |
| **MCP servers** | Session start | Every request |
| **Subagents** | When spawned | Isolated from main session |
| **Hooks** | On trigger | Zero (runs externally) |

#### How Features Layer

- **CLAUDE.md files**: additive (all levels contribute)
- **Skills and subagents**: override by name (priority: managed > user > project)
- **MCP servers**: override by name (local > project > user)
- **Hooks**: merge (all registered hooks fire for matching events)

### Fast Mode

Fast mode is a high-speed configuration for Claude Opus 4.6 -- 2.5x faster at higher cost per token. Same model quality and capabilities, just faster responses. Research preview.

| Detail | Value |
|:-------|:------|
| Toggle | `/fast` (Tab to toggle on/off) |
| Pricing | $30/150 MTok (input/output) |
| Persistent setting | `"fastMode": true` in user settings |
| Indicator | `lightning` icon next to prompt when active |
| Rate limit behavior | Falls back to standard Opus 4.6 automatically |
| Disable env var | `CLAUDE_CODE_DISABLE_FAST_MODE=1` |

Requirements: not available on Bedrock/Vertex/Foundry. Extra usage must be enabled. Teams/Enterprise admins must explicitly enable. Fast mode usage is billed directly to extra usage from the first token.

Per-session opt-in: set `"fastModePerSessionOptIn": true` in managed settings to reset fast mode at session start.

### Model Configuration

#### Model Aliases

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended model based on account type |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast and efficient Haiku for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus during plan mode, Sonnet for execution |

#### Setting the Model (priority order)

1. `/model <alias|name>` during session
2. `claude --model <alias|name>` at startup
3. `ANTHROPIC_MODEL=<alias|name>` environment variable
4. `model` field in settings file

#### Effort Levels

| Level | Behavior |
|:------|:---------|
| `low` | Faster, cheaper, less reasoning |
| `medium` | Default for Opus 4.6 on Max/Team |
| `high` | Deeper reasoning for complex tasks |
| `max` | Deepest reasoning, no token cap (Opus 4.6 only, session-scoped) |

Set via: `/effort <level>`, `/model` (arrow keys), `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL` env var, or `effortLevel` in settings.

Disable adaptive reasoning: `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1`.

#### Extended Context (1M tokens)

Opus 4.6 and Sonnet 4.6 support 1M token context. On Max/Team/Enterprise, Opus gets 1M automatically. Use `[1m]` suffix with aliases or full model names: `/model opus[1m]`. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

#### Model Environment Variables

| Variable | Maps to |
|:---------|:--------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `opus` alias, `opusplan` in plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `sonnet` alias, `opusplan` in execution mode |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `haiku` alias, background functionality |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Subagent model |

#### availableModels Restriction

Set `availableModels` in managed/policy settings to restrict model selection. The `default` model always remains available regardless.

#### modelOverrides

Maps Anthropic model IDs to provider-specific strings (e.g., Bedrock ARNs) for governance and routing. Set in settings file.

#### Prompt Caching

| Variable | Effect |
|:---------|:-------|
| `DISABLE_PROMPT_CACHING` | Disable for all models |
| `DISABLE_PROMPT_CACHING_HAIKU` | Disable for Haiku only |
| `DISABLE_PROMPT_CACHING_SONNET` | Disable for Sonnet only |
| `DISABLE_PROMPT_CACHING_OPUS` | Disable for Opus only |

### Output Styles

Output styles modify Claude Code's system prompt to adapt it for different use cases.

#### Built-in Styles

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Provides educational "Insights" while coding |
| **Learning** | Collaborative learn-by-doing mode with `TODO(human)` markers |

Change style: `/config` > Output style, or set `outputStyle` in settings. Changes take effect on next session start.

#### Custom Output Styles

Custom styles are Markdown files with frontmatter saved at `~/.claude/output-styles` (user) or `.claude/output-styles` (project).

| Frontmatter | Purpose | Default |
|:------------|:--------|:--------|
| `name` | Display name | File name |
| `description` | Description shown in `/config` picker | None |
| `keep-coding-instructions` | Keep coding-related system prompt parts | `false` |

Custom output styles exclude coding instructions by default (unless `keep-coding-instructions` is true) and exclude concise-output instructions.

### Status Line

The status line is a customizable bar at the bottom of Claude Code that runs a shell script you configure. It receives JSON session data on stdin and displays whatever the script prints.

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

Use `/statusline <description>` to auto-generate a script, or manually create one.

#### Available JSON Data Fields

| Field | Description |
|:------|:------------|
| `model.id`, `model.display_name` | Current model ID and name |
| `workspace.current_dir`, `workspace.project_dir` | Working dir and launch dir |
| `cost.total_cost_usd` | Session cost in USD |
| `cost.total_duration_ms` | Wall-clock time since session start |
| `cost.total_api_duration_ms` | Time spent waiting for API responses |
| `cost.total_lines_added`, `cost.total_lines_removed` | Lines changed |
| `context_window.used_percentage` | Pre-calculated context usage percentage |
| `context_window.remaining_percentage` | Pre-calculated context remaining |
| `context_window.context_window_size` | Max context window size (200K or 1M) |
| `context_window.current_usage` | Token counts from last API call |
| `exceeds_200k_tokens` | Whether total tokens exceed 200K threshold |
| `session_id` | Unique session identifier |
| `version` | Claude Code version |
| `output_style.name` | Current output style |
| `vim.mode` | Vim mode (NORMAL/INSERT) when enabled |
| `agent.name` | Agent name when using --agent |
| `worktree.name`, `worktree.path`, `worktree.branch` | Worktree info when active |

Updates after each assistant message, permission mode change, or vim mode toggle. Debounced at 300ms.

### Checkpointing

Claude Code automatically tracks file edits, allowing you to rewind to previous states.

- Every user prompt creates a new checkpoint
- Checkpoints persist across sessions (cleaned up after 30 days)
- Open rewind menu: press `Esc` twice or use `/rewind`

#### Rewind Actions

| Action | Effect |
|:-------|:-------|
| **Restore code and conversation** | Revert both code and conversation to that point |
| **Restore conversation** | Rewind to that message, keep current code |
| **Restore code** | Revert file changes, keep the conversation |
| **Summarize from here** | Compress conversation from this point forward into a summary |

Summarize keeps you in the same session and compresses context (unlike fork which creates a new session).

Limitations: bash command changes not tracked, external changes not tracked, not a replacement for git.

### Remote Control

Continue a local Claude Code session from your phone, tablet, or any browser. Your local environment stays available -- filesystem, MCP servers, tools, and project configuration.

#### Starting Remote Control

| Method | Command |
|:-------|:--------|
| Server mode | `claude remote-control` |
| Interactive session | `claude --remote-control` (or `--rc`) |
| Existing session | `/remote-control` (or `/rc`) |

Server mode flags: `--name`, `--spawn <same-dir|worktree>`, `--capacity <N>`, `--verbose`, `--sandbox`/`--no-sandbox`.

Connect from another device via session URL, QR code (press spacebar in server mode), or session list at claude.ai/code.

Enable for all sessions: `/config` > Enable Remote Control for all sessions.

Requirements: Pro/Max/Team/Enterprise plan. Teams/Enterprise admins must enable Claude Code in admin settings. API keys not supported. v2.1.51+.

Connection: outbound HTTPS only (no inbound ports). All traffic over TLS through Anthropic API.

### Scheduled Tasks

Session-scoped scheduling for recurring prompts and one-time reminders.

#### /loop (Recurring)

```
/loop 5m check if the deployment finished
/loop check the build every 2 hours
/loop 20m /review-pr 1234
```

| Interval form | Example | Parsed |
|:-------------|:--------|:-------|
| Leading token | `/loop 30m check the build` | Every 30 minutes |
| Trailing `every` clause | `/loop check the build every 2h` | Every 2 hours |
| No interval | `/loop check the build` | Every 10 minutes (default) |

Units: `s` (seconds), `m` (minutes), `h` (hours), `d` (days). Seconds rounded up to nearest minute.

#### One-time Reminders

Use natural language: `remind me at 3pm to push the release branch` or `in 45 minutes, check the integration tests`.

#### Underlying Tools

| Tool | Purpose |
|:-----|:--------|
| `CronCreate` | Schedule a new task (cron expression + prompt + recur flag) |
| `CronList` | List all scheduled tasks with IDs, schedules, prompts |
| `CronDelete` | Cancel a task by 8-character ID |

Limits: max 50 tasks per session. Recurring tasks expire after 3 days. Tasks only fire while Claude Code is running and idle. No persistence across restarts. Disable with `CLAUDE_CODE_DISABLE_CRON=1`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code (features overview)](references/claude-code-features-overview.md) -- extension layer overview (CLAUDE.md/Skills/MCP/Subagents/Agent teams/Hooks/Plugins), feature comparison table (what it does/when to use/examples), comparing similar features (Skill vs Subagent, CLAUDE.md vs Skill, CLAUDE.md vs Rules vs Skills, Subagent vs Agent team, MCP vs Skill), how features layer (additive/override/merge), combining features (Skill+MCP, Skill+Subagent, CLAUDE.md+Skills, Hook+MCP), context costs per feature, how features load (CLAUDE.md/Skills/MCP/Subagents/Hooks loading behavior)
- [Fast mode](references/claude-code-fast-mode.md) -- 2.5x faster Opus 4.6 toggle (/fast), pricing ($30/150 MTok), cost tradeoff (mid-conversation switching costs more), when to use (rapid iteration vs long autonomous tasks), fast mode vs effort level comparison, requirements (extra usage, admin enablement for Teams/Enterprise), per-session opt-in (fastModePerSessionOptIn), rate limit fallback behavior, research preview status
- [Model configuration](references/claude-code-model-config.md) -- model aliases (default/sonnet/opus/haiku/sonnet[1m]/opus[1m]/opusplan), setting models (session/startup/env/settings), availableModels restriction and merge behavior, default model by plan tier, opusplan hybrid mode, effort levels (low/medium/high/max with /effort and settings), extended 1M context (availability by plan, [1m] suffix, disable flag), model environment variables (ANTHROPIC_DEFAULT_*_MODEL, CLAUDE_CODE_SUBAGENT_MODEL), pinning models for third-party deployments (Bedrock/Vertex/Foundry), modelOverrides for per-version ID mapping, prompt caching configuration (global and per-model disable flags)
- [Output styles](references/claude-code-output-styles.md) -- built-in styles (Default/Explanatory/Learning), how output styles modify the system prompt, changing style via /config or outputStyle setting, creating custom output styles (Markdown with frontmatter), frontmatter fields (name/description/keep-coding-instructions), comparison to CLAUDE.md/--append-system-prompt/Agents/Skills
- [Status line](references/claude-code-statusline.md) -- customizable status bar at bottom of Claude Code, /statusline command for auto-generation, manual configuration (statusLine settings with type/command/padding), step-by-step build walkthrough, how status lines work (update timing, debouncing, output capabilities), complete JSON data fields (model/workspace/cost/context_window/session/vim/agent/worktree), context window fields (cumulative vs current usage), examples (context window progress bar, git status with colors, cost/duration tracking, multi-line display, clickable links), Windows configuration (PowerShell/Git Bash), troubleshooting
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic edit tracking per user prompt, rewind menu (Esc+Esc or /rewind), restore options (code and conversation, conversation only, code only), summarize from a point (compress conversation while keeping early context), common use cases (exploring alternatives, recovering from mistakes, freeing context), limitations (bash changes not tracked, external changes not tracked, not a git replacement)
- [Remote Control](references/claude-code-remote-control.md) -- continue local sessions from phone/tablet/browser, server mode (claude remote-control with --name/--spawn/--capacity/--verbose/--sandbox), interactive mode (claude --remote-control/--rc), existing session (/remote-control or /rc), connecting from another device (URL/QR code/session list), enable for all sessions via /config, connection security (outbound HTTPS only, TLS through Anthropic API), Remote Control vs Claude Code on the web, limitations (one session per process outside server mode, terminal must stay open, network timeout)
- [Scheduled tasks](references/claude-code-scheduled-tasks.md) -- /loop bundled skill for recurring prompts (interval syntax with leading/trailing/default forms, units s/m/h/d, loop over commands), one-time reminders (natural language scheduling), underlying tools (CronCreate/CronList/CronDelete), how tasks run (low-priority between turns, local timezone, jitter for recurring/one-shot), three-day expiry, cron expression reference (5-field format, examples), disable with CLAUDE_CODE_DISABLE_CRON=1, limitations (session-scoped, no catch-up, no persistence)

## Sources

- Extend Claude Code (features overview): https://code.claude.com/docs/en/features-overview.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks: https://code.claude.com/docs/en/scheduled-tasks.md
