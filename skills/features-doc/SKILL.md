---
name: features-doc
description: Complete documentation for Claude Code features -- fast mode (toggle with /fast, Opus 4.6 2.5x speed at $30/$150 MTok, rate limit fallback, per-session opt-in, extra usage billing, admin enablement), model configuration (model aliases default/sonnet/opus/haiku/sonnet[1m]/opus[1m]/opusplan, setting model via /model or --model or ANTHROPIC_MODEL or settings, availableModels restriction, modelOverrides for Bedrock/Vertex/Foundry ARN mapping, effort levels low/medium/high/max with /effort and --effort and settings, extended 1M context with [1m] suffix, ANTHROPIC_DEFAULT_OPUS_MODEL/SONNET_MODEL/HAIKU_MODEL env vars, CLAUDE_CODE_SUBAGENT_MODEL, prompt caching DISABLE_PROMPT_CACHING env vars, pinning models for third-party deployments), output styles (Default/Explanatory/Learning built-in styles, custom output styles as markdown files with frontmatter, outputStyle setting, keep-coding-instructions, ~/.claude/output-styles or .claude/output-styles, comparison vs CLAUDE.md vs agents vs skills), status line (custom shell script status bar, statusLine setting, JSON session data on stdin, available fields model/contextWindow/costs/git/session, ANSI color support, multi-line output, ready-to-use examples for git/costs/progress bars, performance optimization), checkpointing (automatic edit tracking, Esc+Esc or /rewind to open menu, restore code/conversation/both, summarize from here for targeted compaction, session-level recovery, bash changes not tracked, 30-day cleanup), extensibility overview (CLAUDE.md/Skills/MCP/Subagents/Agent teams/Hooks/Plugins feature comparison, context cost by feature, when features load, combining features, feature layering/override rules), remote control (continue local sessions from phone/tablet/browser, claude remote-control server mode with --spawn/--capacity/--name, claude --remote-control or /remote-control, QR code for mobile, session URL, connection security, enable for all sessions via /config, vs Claude Code on the web), scheduled tasks (/loop bundled skill for recurring prompts, interval syntax s/m/h/d, loop over commands, one-time reminders in natural language, CronCreate/CronList/CronDelete tools, 5-field cron expressions in local timezone, jitter for recurring tasks, 3-day expiry, CLAUDE_CODE_DISABLE_CRON, session-scoped only), voice dictation (/voice toggle, hold Space push-to-talk, speech-to-text with coding vocabulary, 19 supported languages, rebind push-to-talk key in keybindings.json, requires Claude.ai account, local microphone access, macOS/Linux/Windows native module). Load when discussing fast mode, /fast, model configuration, model aliases, /model, opusplan, effort level, /effort, extended context, 1M context, output styles, /config output style, custom output styles, status line, statusLine setting, status bar, checkpointing, /rewind, restore code, summarize conversation, extending Claude Code, features overview, extensibility overview, remote control, /remote-control, /rc, claude remote-control, QR code, mobile access, scheduled tasks, /loop, cron, CronCreate, reminders, voice dictation, /voice, push-to-talk, speech-to-text, dictation language, ANTHROPIC_DEFAULT_OPUS_MODEL, ANTHROPIC_DEFAULT_SONNET_MODEL, availableModels, modelOverrides, prompt caching, DISABLE_PROMPT_CACHING, fastModePerSessionOptIn, keep-coding-instructions, or any Claude Code feature configuration topic.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features -- fast mode, model configuration, output styles, status line, checkpointing, extensibility overview, remote control, scheduled tasks, and voice dictation.

## Quick Reference

### Fast Mode

Toggle with `/fast` for 2.5x faster Opus 4.6 responses at higher cost. Not a different model -- same quality, faster API configuration.

| Detail | Value |
|:-------|:------|
| Toggle | `/fast` (Tab) or `"fastMode": true` in settings |
| Pricing | $30 / $150 per MTok (input / output) |
| Indicator | `↯` icon next to prompt (gray during cooldown) |
| Availability | Pro/Max/Team/Enterprise subscriptions and Console API |
| Billing | Always billed to extra usage, not plan quota |
| Min version | v2.1.36 |

**Admin controls:** Disabled by default for Teams/Enterprise -- admin must enable in Console or Claude AI admin settings. Set `fastModePerSessionOptIn: true` in managed settings to reset fast mode each session. Set `CLAUDE_CODE_DISABLE_FAST_MODE=1` to disable entirely.

**Rate limits:** On rate limit, auto-falls back to standard Opus 4.6 (gray `↯`), re-enables on cooldown expiry.

**Cost tip:** Enable at session start rather than mid-conversation to avoid paying full uncached input price for entire context.

### Model Configuration

#### Model Aliases

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended model for your account type |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast Haiku for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus for planning, Sonnet for execution |

#### Setting the Model (priority order)

1. `/model <alias|name>` during session
2. `claude --model <alias|name>` at startup
3. `ANTHROPIC_MODEL=<alias|name>` env var
4. `"model"` field in settings file

#### Default Model by Plan

| Plan | Default |
|:-----|:--------|
| Max, Team Premium | Opus 4.6 |
| Pro, Team Standard | Sonnet 4.6 |
| Enterprise | Opus 4.6 available, not default |

#### Effort Levels

| Level | Behavior |
|:------|:---------|
| `low` | Less thinking, faster, potentially lower quality |
| `medium` | Default for Opus on Max/Team |
| `high` | Deeper reasoning for complex problems |
| `max` | Deepest reasoning, no token constraint, Opus only, session-scoped |
| `auto` | Reset to model default |

Set via: `/effort <level>`, arrow keys in `/model`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL` env var, or `effortLevel` setting. Disable adaptive reasoning: `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1`.

#### Extended Context (1M)

Use `[1m]` suffix with aliases or full model names: `/model opus[1m]`, `/model sonnet[1m]`. Disable: `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

| Plan | Opus 1M | Sonnet 1M |
|:-----|:--------|:----------|
| Max, Team, Enterprise | Included | Extra usage |
| Pro | Extra usage | Extra usage |
| API / pay-as-you-go | Full access | Full access |

#### Model Environment Variables

| Variable | Controls |
|:---------|:---------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model ID for `opus` alias and `opusplan` plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model ID for `sonnet` alias and `opusplan` execution mode |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model ID for `haiku` alias and background functionality |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |

#### Model Restriction & Overrides

- `availableModels` in managed/policy settings restricts which models users can select. Default model always remains available.
- `modelOverrides` maps Anthropic model IDs to provider-specific IDs (Bedrock ARNs, Vertex version names, Foundry deployment names) for governance and routing.

#### Prompt Caching

| Variable | Effect |
|:---------|:-------|
| `DISABLE_PROMPT_CACHING` | `1` disables for all models (takes precedence) |
| `DISABLE_PROMPT_CACHING_HAIKU` | `1` disables for Haiku only |
| `DISABLE_PROMPT_CACHING_SONNET` | `1` disables for Sonnet only |
| `DISABLE_PROMPT_CACHING_OPUS` | `1` disables for Opus only |

### Output Styles

Modify Claude Code's system prompt to adapt behavior for different use cases.

#### Built-in Styles

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Adds educational "Insights" between coding tasks |
| **Learning** | Collaborative mode with `TODO(human)` markers for you to implement |

#### Custom Output Styles

Markdown files with frontmatter, stored at `~/.claude/output-styles/` (user) or `.claude/output-styles/` (project).

| Frontmatter | Purpose | Default |
|:------------|:--------|:--------|
| `name` | Display name | File name |
| `description` | Shown in `/config` picker | None |
| `keep-coding-instructions` | Keep coding-related system prompt parts | `false` |

Set via `/config` > Output style, or `"outputStyle": "StyleName"` in settings. Changes take effect on next session start.

**Key distinction:** Custom output styles exclude coding instructions by default (unlike CLAUDE.md which adds to the system prompt). Output styles modify the system prompt; CLAUDE.md adds a user message after it; `--append-system-prompt` appends to it.

### Status Line

Customizable bar at the bottom of Claude Code that runs any shell script. Set `statusLine` in settings to a command string. The command receives JSON session data on stdin and prints output to display.

#### Available Data Fields

| Category | Fields |
|:---------|:-------|
| Model | `model`, `effort` |
| Context | `contextWindow.used`, `contextWindow.total`, `contextWindow.percentage` |
| Costs | `costs.input`, `costs.output`, `costs.total`, `costs.currency` |
| Git | `git.branch`, `git.dirty`, `git.ahead`, `git.behind` |
| Session | `session.id`, `session.cwd`, `session.duration`, `session.turnCount` |

Supports ANSI colors, multi-line output (one line per `\n`), and Unicode. Scripts should complete in under 100ms. Performance-sensitive fields like git are cached.

### Checkpointing

Automatic edit tracking for quick session-level recovery.

| Action | How |
|:-------|:----|
| Open rewind menu | `Esc` + `Esc` or `/rewind` |
| Restore code and conversation | Select prompt, choose "Restore code and conversation" |
| Restore conversation only | Rewinds to that message, keeps current code |
| Restore code only | Reverts files, keeps conversation |
| Summarize from here | Compresses selected message onward into summary, frees context |

- Checkpoints persist across sessions (30-day default cleanup)
- Each user prompt creates a new checkpoint
- Bash command changes and external edits are NOT tracked
- Not a replacement for Git -- think of checkpoints as "local undo"

**Summarize vs restore:** Summarize keeps you in the same session and compresses context. Use fork (`claude --continue --fork-session`) to branch off while preserving the original session.

### Extensibility Overview

Features for extending Claude Code, organized by loading behavior.

| Feature | What it does | When to use |
|:--------|:-------------|:------------|
| CLAUDE.md | Persistent context every session | "Always do X" rules, conventions |
| Skill | Knowledge and workflows | Reusable content, reference docs, repeatable tasks |
| Subagent | Isolated execution context | Context isolation, parallel tasks |
| Agent team | Multiple independent sessions | Parallel research, competing hypotheses |
| MCP | External service connection | Database queries, Slack, browser control |
| Hook | Deterministic script on events | Linting after edits, logging |

**Context cost:** CLAUDE.md loads every request. Skill descriptions load every request (low cost), full content on use. MCP tool definitions load every request. Subagents are isolated. Hooks cost zero unless they return context.

**Layering rules:** CLAUDE.md is additive (all levels contribute). Skills/subagents override by name (priority-based). MCP servers override by name (local > project > user). Hooks merge (all fire).

### Remote Control

Continue a local Claude Code session from phone, tablet, or any browser via claude.ai/code or Claude mobile app. The session runs locally -- nothing moves to the cloud.

| Start method | Command |
|:-------------|:--------|
| Server mode | `claude remote-control` |
| Interactive with RC | `claude --remote-control` or `claude --rc` |
| From existing session | `/remote-control` or `/rc` |

Server mode flags: `--name`, `--spawn <same-dir|worktree>`, `--capacity <N>`, `--verbose`, `--sandbox`/`--no-sandbox`.

Enable for all sessions: `/config` > "Enable Remote Control for all sessions" > `true`.

**Requirements:** Pro/Max/Team/Enterprise subscription, Claude.ai authentication (no API keys), v2.1.51+, workspace trust accepted.

**Connection:** Outbound HTTPS only, no inbound ports. All traffic over TLS through Anthropic API with short-lived, scoped credentials.

**Limitations:** One remote session per interactive process (use server mode `--spawn` for multiple). Terminal must stay open. Extended network outage (~10 min) causes timeout.

### Scheduled Tasks (Session-Scoped)

Run prompts on a schedule within a Claude Code session. Tasks are session-scoped and gone when you exit.

#### /loop Quick Start

```
/loop 5m check if the deployment finished
/loop check the build every 2 hours
/loop 20m /review-pr 1234
```

Intervals: `s` (seconds, rounded to minutes), `m` (minutes), `h` (hours), `d` (days). Default: every 10 minutes.

#### One-Time Reminders

Use natural language: "remind me at 3pm to push the release branch" or "in 45 minutes, check the tests."

#### Underlying Tools

| Tool | Purpose |
|:-----|:--------|
| `CronCreate` | Schedule a task (5-field cron, prompt, recur/once) |
| `CronList` | List tasks with IDs, schedules, prompts |
| `CronDelete` | Cancel a task by 8-char ID |

**Behavior:** Tasks fire between user turns (not mid-response). All times in local timezone. Max 50 tasks per session. Recurring tasks auto-expire after 3 days. Disable: `CLAUDE_CODE_DISABLE_CRON=1`.

**Jitter:** Recurring tasks fire up to 10% of period late (capped at 15 min). One-shot top/bottom-of-hour tasks fire up to 90s early. Offset is deterministic per task ID.

For durable scheduling (survives restarts), use Desktop scheduled tasks or GitHub Actions.

### Voice Dictation

Hold a key to speak prompts instead of typing. Transcription is tuned for coding vocabulary.

| Detail | Value |
|:-------|:------|
| Toggle | `/voice` or `"voiceEnabled": true` in settings |
| Push-to-talk key | `Space` (default), rebind in `~/.claude/keybindings.json` |
| Keybinding action | `voice:pushToTalk` in `Chat` context |
| Min version | v2.1.69 |

**Requirements:** Claude.ai account authentication (not API keys or third-party providers). Local microphone access (not available in remote/SSH/Claude Code on the web). On Linux, falls back to `arecord` or `rec` if native module cannot load.

**Recording flow:** Hold Space (brief warmup, then live waveform) > speak > release to finalize. Transcript inserted at cursor. Mix typing and dictation freely.

**Modifier combo tip:** Rebind to a modifier like `meta+k` to skip the warmup and start recording on first keypress.

#### Supported Dictation Languages

cs, da, de, el, en, es, fr, hi, id, it, ja, ko, nl, no, pl, pt, ru, sv, tr, uk

Set via `language` setting in `/config` or settings file. If language is not supported, `/voice` warns and falls back to English for dictation.

## Full Documentation

For the complete official documentation, see the reference files:

- [Speed up responses with fast mode](references/claude-code-fast-mode.md) -- toggle fast mode with /fast, $30/$150 MTok pricing, cost tradeoff (enable at session start), when to use fast mode vs effort level, requirements (extra usage, admin enablement for Teams/Enterprise), per-session opt-in with fastModePerSessionOptIn, rate limit fallback to standard Opus, research preview status
- [Model configuration](references/claude-code-model-config.md) -- model aliases (default/sonnet/opus/haiku/sonnet[1m]/opus[1m]/opusplan), setting model priority (/model, --model, ANTHROPIC_MODEL, settings), restrict models with availableModels, default model by plan, opusplan hybrid mode, effort levels (low/medium/high/max/auto, /effort, --effort, settings, env var), extended 1M context (plan availability, [1m] suffix, disable flag), model environment variables (ANTHROPIC_DEFAULT_OPUS/SONNET/HAIKU_MODEL, CLAUDE_CODE_SUBAGENT_MODEL), pin models for third-party deployments, modelOverrides for Bedrock/Vertex/Foundry ARN mapping, prompt caching configuration (DISABLE_PROMPT_CACHING vars)
- [Output styles](references/claude-code-output-styles.md) -- built-in styles (Default/Explanatory/Learning), how output styles modify system prompt, change style via /config or outputStyle setting, create custom styles as markdown with frontmatter (name/description/keep-coding-instructions), store at ~/.claude/output-styles or .claude/output-styles, comparison vs CLAUDE.md vs --append-system-prompt vs Agents vs Skills
- [Customize your status line](references/claude-code-statusline.md) -- statusLine setting, shell script receives JSON on stdin, available data fields (model, contextWindow, costs, git, session), ANSI color support, multi-line output, ready-to-use examples (git status, cost tracking, progress bars, context bars), performance optimization, troubleshooting
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic edit tracking, Esc+Esc or /rewind menu, restore code/conversation/both, summarize from here (targeted compaction), common use cases, limitations (bash changes not tracked, external changes not tracked, not a replacement for version control), 30-day cleanup
- [Extend Claude Code](references/claude-code-features-overview.md) -- extensibility overview, feature comparison table (CLAUDE.md/Skills/Subagents/Agent teams/MCP/Hooks), compare similar features (Skill vs Subagent, CLAUDE.md vs Skill, CLAUDE.md vs Rules vs Skills, Subagent vs Agent team, MCP vs Skill), feature layering and override rules, combining features (Skill+MCP, Skill+Subagent, CLAUDE.md+Skills, Hook+MCP), context cost by feature, how features load (CLAUDE.md/Skills/MCP/Subagents/Hooks lifecycle)
- [Continue local sessions with Remote Control](references/claude-code-remote-control.md) -- start remote control (server mode, interactive, from existing session), server flags (--name, --spawn same-dir/worktree, --capacity, --verbose, --sandbox), connect from another device (URL, QR code, session list), enable for all sessions, connection security (outbound HTTPS only, TLS, short-lived credentials), vs Claude Code on the web, limitations (one session per process, terminal must stay open, network timeout)
- [Run prompts on a schedule](references/claude-code-scheduled-tasks.md) -- /loop for recurring prompts (interval syntax s/m/h/d, loop over commands), one-time reminders in natural language, CronCreate/CronList/CronDelete tools, how tasks run (fire between turns, local timezone), jitter for recurring and one-shot tasks, 3-day auto-expiry, cron expression reference (5-field format, examples), CLAUDE_CODE_DISABLE_CRON, session-scoped limitations
- [Voice dictation](references/claude-code-voice-dictation.md) -- /voice toggle, hold Space push-to-talk with warmup, live transcription tuned for coding vocabulary, insert at cursor, 19 supported dictation languages, language setting, rebind push-to-talk key in keybindings.json (voice:pushToTalk, modifier combo for instant recording), requirements (Claude.ai account, local microphone), native audio module with Linux fallback (arecord/rec), troubleshooting

## Sources

- Speed up responses with fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Customize your status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Extend Claude Code: https://code.claude.com/docs/en/features-overview.md
- Continue local sessions with Remote Control: https://code.claude.com/docs/en/remote-control.md
- Run prompts on a schedule: https://code.claude.com/docs/en/scheduled-tasks.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
