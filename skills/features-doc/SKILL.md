---
name: features-doc
description: Complete documentation for Claude Code features -- model configuration (aliases default/sonnet/opus/haiku/sonnet[1m]/opus[1m]/opusplan, /model command, availableModels restriction, ANTHROPIC_DEFAULT_OPUS_MODEL/SONNET/HAIKU env vars, modelOverrides for third-party provider ID mapping, ANTHROPIC_CUSTOM_MODEL_OPTION, prompt caching with DISABLE_PROMPT_CACHING), effort levels (low/medium/high/max, /effort command, --effort flag, CLAUDE_CODE_EFFORT_LEVEL, effortLevel setting, "ultrathink" trigger, skill/subagent frontmatter effort, CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING), extended context (1M token window, opus[1m]/sonnet[1m] aliases, CLAUDE_CODE_DISABLE_1M_CONTEXT, plan availability), fast mode (/fast toggle, fastMode setting, 2.5x speed at $30/150 MTok pricing, extra usage required, fastModePerSessionOptIn, CLAUDE_CODE_DISABLE_FAST_MODE, rate limit fallback), output styles (Default/Explanatory/Learning built-ins, custom output styles in ~/.claude/output-styles or .claude/output-styles, outputStyle setting, keep-coding-instructions frontmatter), status line (statusLine setting, /statusline command, custom shell scripts receiving JSON stdin with model/context/cost/git/rate_limits/worktree fields, ANSI colors, multi-line output, padding), checkpointing (automatic edit tracking, Esc+Esc or /rewind to restore code/conversation/both or summarize, checkpoint persistence), voice dictation (/voice toggle, voiceEnabled setting, hold Space push-to-talk, voice:pushToTalk keybinding, dictation language, coding vocabulary recognition), remote control (claude remote-control server mode, --remote-control flag, /remote-control command, claude.ai/code and mobile app connection, --spawn worktree/same-dir, --capacity, QR code pairing, always-on via /config), channels (push events from Telegram/Discord/iMessage into running session, --channels flag, channel plugins, channelsEnabled/allowedChannelPlugins enterprise settings, sender allowlists, two-way chat bridges), channels reference (building custom channels, claude/channel MCP capability, notifications/claude/channel events, reply tools, sender gating, permission relay, webhook receiver pattern, --dangerously-load-development-channels), scheduled tasks (/loop for recurring prompts with interval syntax, CronCreate/CronList/CronDelete tools, one-time reminders, session-scoped 3-day expiry, CLAUDE_CODE_DISABLE_CRON), cloud scheduled tasks (web UI at claude.ai/code/scheduled, /schedule CLI command, hourly/daily/weekdays/weekly frequencies, repository branch permissions, cloud environments, MCP connectors per task), context window exploration (interactive simulation of context loading, system prompt/auto memory/env info/MCP tools/skill descriptions/CLAUDE.md at startup, file reads as context cost, rules loading on file access, hooks as zero-cost, subagent isolation, /compact behavior), fullscreen rendering (CLAUDE_CODE_NO_FLICKER=1, alternate screen buffer, mouse support for click/drag/scroll/URL, Ctrl+o transcript mode with /search and [scrollback, CLAUDE_CODE_DISABLE_MOUSE, CLAUDE_CODE_SCROLL_SPEED, tmux compatibility), extensibility overview (CLAUDE.md vs Skills vs Subagents vs Agent teams vs MCP vs Hooks vs Plugins comparison, context costs by feature, feature layering and combination patterns). Load when discussing model configuration, model aliases, /model, availableModels, modelOverrides, effort levels, /effort, ultrathink, extended context, 1M context, fast mode, /fast, output styles, Explanatory mode, Learning mode, custom output styles, status line, /statusline, statusLine setting, checkpointing, /rewind, Esc Esc, voice dictation, /voice, push-to-talk, remote control, /remote-control, /rc, channels, Telegram channel, Discord channel, iMessage channel, --channels, channel plugins, scheduled tasks, /loop, /schedule, cloud scheduled tasks, web scheduled tasks, context window, context loading, fullscreen rendering, no-flicker mode, CLAUDE_CODE_NO_FLICKER, or any Claude Code feature configuration topic.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features including model configuration, effort levels, fast mode, output styles, status line, checkpointing, voice dictation, remote control, channels, scheduled tasks, context window exploration, and fullscreen rendering.

## Quick Reference

### Model Configuration

| Alias | Resolves to |
|:------|:------------|
| `default` | Opus 4.6 (Max/Team Premium) or Sonnet 4.6 (Pro/Team Standard) |
| `sonnet` | Latest Sonnet (currently 4.6) |
| `opus` | Latest Opus (currently 4.6) |
| `haiku` | Fast and efficient Haiku |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus for planning, Sonnet for execution |

**Setting the model (priority order):** `/model <alias>` in session > `claude --model <alias>` at startup > `ANTHROPIC_MODEL` env var > `model` field in settings.

**Restricting models (enterprise):** Set `availableModels` in managed/policy settings. `Default` always remains available regardless.

**Pinning for third-party providers:** Set `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL` to provider-specific model IDs. Append `[1m]` for extended context. Use companion `_NAME`, `_DESCRIPTION`, `_SUPPORTED_CAPABILITIES` suffixes to customize display and declare capabilities (`effort`, `max_effort`, `thinking`, `adaptive_thinking`, `interleaved_thinking`).

**modelOverrides setting:** Maps Anthropic model IDs to provider-specific IDs (e.g., Bedrock ARNs) in settings. Keys must be Anthropic model IDs. Overrides replace built-in IDs in the `/model` picker. Works alongside `availableModels`.

**Custom model option:** `ANTHROPIC_CUSTOM_MODEL_OPTION` adds a single entry to `/model` picker without replacing built-ins. Optional `_NAME` and `_DESCRIPTION` suffixes.

**Prompt caching:** `DISABLE_PROMPT_CACHING=1` disables globally. Per-model: `DISABLE_PROMPT_CACHING_HAIKU`, `_SONNET`, `_OPUS`.

### Effort Levels

| Level | Behavior |
|:------|:---------|
| `low` | Faster, cheaper, less thinking |
| `medium` | Default for Opus 4.6 and Sonnet 4.6 |
| `high` | Deeper reasoning |
| `max` | Deepest reasoning, Opus 4.6 only, does not persist across sessions |

**Setting effort:** `/effort <level>` command, left/right arrows in `/model`, `--effort` CLI flag, `CLAUDE_CODE_EFFORT_LEVEL` env var (highest precedence), `effortLevel` in settings, `effort` in skill/subagent frontmatter.

**Tip:** Include "ultrathink" in a prompt for one-off high effort without changing session setting. Disable adaptive reasoning with `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1`.

### Extended Context (1M Tokens)

| Plan | Opus 4.6 1M | Sonnet 4.6 1M |
|:-----|:------------|:--------------|
| Max, Team, Enterprise | Included | Extra usage |
| Pro | Extra usage | Extra usage |
| API / pay-as-you-go | Full access | Full access |

Use `/model opus[1m]` or `/model sonnet[1m]`. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`. Standard pricing applies (no premium beyond 200K).

### Fast Mode

Toggle with `/fast`. Opus 4.6 only, 2.5x faster at $30/$150 per MTok (input/output). Requires extra usage enabled. Not available on Bedrock/Vertex/Foundry.

| Setting | Purpose |
|:--------|:--------|
| `fastMode: true` | Enable in settings |
| `fastModePerSessionOptIn: true` | Managed setting: reset fast mode each session |
| `CLAUDE_CODE_DISABLE_FAST_MODE=1` | Disable entirely |

When rate-limited, auto-falls back to standard Opus (gray icon). Re-enables when cooldown expires. Enable at session start for best cost efficiency.

### Output Styles

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Adds educational "Insights" between tasks |
| **Learning** | Collaborative mode with `TODO(human)` markers for you to implement |
| **Custom** | Markdown files in `~/.claude/output-styles/` or `.claude/output-styles/` |

Set via `/config` > Output style, or `outputStyle` field in settings. Changes take effect next session.

**Custom output style frontmatter:** `name`, `description`, `keep-coding-instructions` (default false -- when false, removes coding-specific system prompt).

### Status Line

Configure with `/statusline <description>` (auto-generates script) or manually set `statusLine` in settings:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

Script receives JSON on stdin with fields: `model.id`, `model.display_name`, `workspace.current_dir`, `workspace.project_dir`, `cost.total_cost_usd`, `cost.total_duration_ms`, `context_window.used_percentage`, `context_window.context_window_size`, `rate_limits.five_hour.used_percentage`, `rate_limits.seven_day.used_percentage`, `session_id`, `version`, `output_style.name`, `vim.mode`, `agent.name`, `worktree.*`. Supports ANSI colors and multiple lines.

### Checkpointing

Automatic tracking of all file edits by Claude's tools. Press **Esc+Esc** or use `/rewind` to open the rewind menu:

- **Restore code and conversation** -- revert both to that point
- **Restore conversation** -- rewind messages, keep current code
- **Restore code** -- revert files, keep conversation
- **Summarize from here** -- compress messages from that point forward (like targeted `/compact`)

Checkpoints persist across sessions (30-day cleanup). Bash command changes and external edits are not tracked.

### Voice Dictation

Enable with `/voice` or `voiceEnabled: true` in settings. Hold Space to record (push-to-talk). Speech transcribed live into prompt input. Requires claude.ai account and local microphone.

- Coding vocabulary recognized (regex, OAuth, JSON, localhost)
- Project name and git branch used as recognition hints
- Dictation language follows the `language` setting (20 languages supported)
- Rebind push-to-talk via `voice:pushToTalk` in keybindings.json (modifier combos skip warmup)

### Remote Control

Continue local sessions from any device via claude.ai/code or Claude mobile app.

| Mode | Command | Behavior |
|:-----|:--------|:---------|
| Server mode | `claude remote-control` | Dedicated server, waits for remote connections |
| Interactive | `claude --remote-control` (or `--rc`) | Full interactive session + remote access |
| From session | `/remote-control` (or `/rc`) | Enable on existing session |

**Flags:** `--name`, `--spawn same-dir|worktree`, `--capacity <N>`, `--verbose`, `--sandbox|--no-sandbox`.

Always-on: set "Enable Remote Control for all sessions" to true in `/config`.

Available on Pro/Max/Team/Enterprise (claude.ai auth required). Team/Enterprise: admin must enable Remote Control toggle.

### Channels

Push events from external systems into a running Claude Code session via MCP-based channel plugins.

| Channel | Setup |
|:--------|:------|
| Telegram | Create bot via BotFather, `/plugin install telegram@claude-plugins-official`, configure token, pair |
| Discord | Create bot in Developer Portal, `/plugin install discord@claude-plugins-official`, configure token, pair |
| iMessage | macOS only, `/plugin install imessage@claude-plugins-official`, text yourself to start |
| Fakechat | Localhost demo, `/plugin install fakechat@claude-plugins-official` |

Launch with `--channels plugin:<name>@<marketplace>`. Sender allowlists protect against unauthorized messages.

**Enterprise:** `channelsEnabled: true` in managed settings to enable. `allowedChannelPlugins` to restrict which plugins can register. Channels are off by default for Team/Enterprise.

**Building custom channels:** Declare `claude/channel` capability in MCP server, emit `notifications/claude/channel` events. Optional reply tools for two-way communication. Test with `--dangerously-load-development-channels server:<name>`.

### Scheduled Tasks

| Type | Scope | Persistence | Command |
|:-----|:------|:------------|:--------|
| **Session (/loop)** | Current session | Gone on exit (3-day max) | `/loop 5m check the build` |
| **Cloud** | Anthropic infrastructure | Survives restarts | `/schedule` or claude.ai/code/scheduled |
| **Desktop** | Local machine | Survives restarts | Desktop app Schedule page |

**Session tasks (/loop):** Interval syntax `5m`, `2h`, `30s`. Default 10 minutes. Fires between your turns. Tools: `CronCreate`, `CronList`, `CronDelete`. Disable with `CLAUDE_CODE_DISABLE_CRON=1`.

**Cloud tasks:** Create at claude.ai/code/scheduled, via `/schedule`, or Desktop app. Frequencies: hourly, daily, weekdays, weekly (minimum 1 hour). Each run clones repos from default branch, pushes to `claude/`-prefixed branches by default. Supports MCP connectors and cloud environments.

### Context Window Loading

At session start (automatic): system prompt (~4200 tokens) > auto memory > environment info > MCP tool names (deferred) > skill descriptions > ~/.claude/CLAUDE.md > project CLAUDE.md.

During work: file reads (main cost), path-scoped rules (auto-load on file access), skill content (on invocation), hook output (via additionalContext only).

Subagents get isolated context (own system prompt + CLAUDE.md + specified skills). Their file reads do not consume main session context.

### Fullscreen Rendering

Enable with `CLAUDE_CODE_NO_FLICKER=1`. Alternate screen buffer (like vim), flat memory usage, mouse support.

| Feature | Details |
|:--------|:--------|
| Mouse click | Position cursor, expand/collapse tool output, open URLs/file paths |
| Mouse drag | Select text (auto-copies on release) |
| Mouse wheel | Scroll conversation |
| `PgUp`/`PgDn` | Half-screen scroll |
| `Ctrl+Home`/`Ctrl+End` | Jump to start/end |
| `Ctrl+o` | Transcript mode with `/` search, `[` for native scrollback |

**Options:** `CLAUDE_CODE_DISABLE_MOUSE=1` to keep flicker-free rendering without mouse capture. `CLAUDE_CODE_SCROLL_SPEED=3` to adjust wheel speed.

**tmux:** Requires `set -g mouse on`. Incompatible with iTerm2 `tmux -CC` integration mode.

### Extensibility Overview

| Feature | Loads | Context cost | Best for |
|:--------|:------|:-------------|:---------|
| **CLAUDE.md** | Session start, always | Every request | "Always do X" rules |
| **Skills** | Descriptions at start, full on use | Low until used | Reference docs, workflows |
| **MCP servers** | Tool names at start | Low until tool used | External services |
| **Subagents** | When spawned | Isolated | Parallel tasks, context isolation |
| **Hooks** | On trigger | Zero (runs externally) | Deterministic automation |
| **Plugins** | Bundles skills/hooks/MCP | Varies | Distribution and reuse |

## Full Documentation

For the complete official documentation, see the reference files:

- [Model configuration](references/claude-code-model-config.md) -- model aliases (default/sonnet/opus/haiku/sonnet[1m]/opus[1m]/opusplan), setting model via /model, --model, ANTHROPIC_MODEL, and settings, availableModels restriction for enterprise, default model behavior by plan, opusplan hybrid mode, effort levels (low/medium/high/max, /effort, --effort, CLAUDE_CODE_EFFORT_LEVEL, effortLevel, skill/subagent frontmatter effort, ultrathink, CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING), extended context (1M tokens, plan availability, CLAUDE_CODE_DISABLE_1M_CONTEXT, [1m] suffix), checking current model, ANTHROPIC_CUSTOM_MODEL_OPTION, model environment variables (ANTHROPIC_DEFAULT_OPUS/SONNET/HAIKU_MODEL, CLAUDE_CODE_SUBAGENT_MODEL), pinning for third-party providers with _NAME/_DESCRIPTION/_SUPPORTED_CAPABILITIES, modelOverrides setting for per-version ID mapping, prompt caching configuration (DISABLE_PROMPT_CACHING and per-model variants)
- [Fast mode](references/claude-code-fast-mode.md) -- /fast toggle, 2.5x speed for Opus 4.6, $30/$150 MTok pricing, extra usage requirement, fastMode and fastModePerSessionOptIn settings, CLAUDE_CODE_DISABLE_FAST_MODE, rate limit fallback behavior, fast mode vs effort level comparison, enterprise enablement
- [Output styles](references/claude-code-output-styles.md) -- built-in styles (Default/Explanatory/Learning), custom output styles in markdown with frontmatter (name/description/keep-coding-instructions), /config menu and outputStyle setting, comparison to CLAUDE.md, --append-system-prompt, agents, and skills
- [Status line](references/claude-code-statusline.md) -- /statusline command, manual statusLine setting configuration, full JSON data schema (model, workspace, cost, context_window, rate_limits, session_id, version, output_style, vim, agent, worktree fields), ANSI colors, multi-line output, clickable links, examples (git status, context bar, cost tracking), Windows configuration
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic edit tracking, Esc+Esc and /rewind menu, restore code/conversation/both and summarize options, checkpoint persistence, limitations (bash commands and external changes not tracked)
- [Extend Claude Code (features overview)](references/claude-code-features-overview.md) -- extensibility overview comparing CLAUDE.md, Skills, Subagents, Agent teams, MCP, Hooks, and Plugins, feature comparison tables (Skill vs Subagent, CLAUDE.md vs Skill, CLAUDE.md vs Rules vs Skills, Subagent vs Agent team, MCP vs Skill), feature layering and combination patterns, context costs by feature type, context loading timeline
- [Remote Control](references/claude-code-remote-control.md) -- claude remote-control server mode, --remote-control/--rc interactive flag, /remote-control command, connecting from claude.ai/code and mobile app, server mode flags (--name/--spawn/--capacity/--verbose/--sandbox), always-on config, connection security (outbound HTTPS only), comparison to Claude Code on the web, troubleshooting guide
- [Scheduled tasks (session-scoped)](references/claude-code-scheduled-tasks.md) -- /loop skill with interval syntax, one-time reminders, CronCreate/CronList/CronDelete tools, jitter behavior, 3-day expiry, cron expression reference, CLAUDE_CODE_DISABLE_CRON, comparison of scheduling options (cloud vs Desktop vs /loop)
- [Voice dictation](references/claude-code-voice-dictation.md) -- /voice toggle, voiceEnabled setting, Space push-to-talk with hold detection, voice:pushToTalk keybinding, dictation language (20 supported languages), coding vocabulary recognition, requirements (claude.ai auth, local microphone), troubleshooting
- [Channels](references/claude-code-channels.md) -- push events into running sessions, Telegram/Discord/iMessage channel setup, fakechat demo, --channels flag, sender allowlists and pairing, channelsEnabled and allowedChannelPlugins enterprise settings, comparison to web sessions/Slack/MCP/Remote Control
- [Channels reference](references/claude-code-channels-reference.md) -- building custom channel MCP servers, claude/channel capability declaration, notification format, reply tools for two-way communication, sender gating, permission relay, webhook receiver example, --dangerously-load-development-channels testing, server constructor options
- [Cloud scheduled tasks](references/claude-code-web-scheduled-tasks.md) -- web UI at claude.ai/code/scheduled, /schedule CLI command, Desktop app creation, frequency options (hourly/daily/weekdays/weekly, 1-hour minimum), repository and branch permissions (claude/ prefix default), cloud environments, MCP connectors per task, managing and editing tasks
- [Context window exploration](references/claude-code-context-window.md) -- interactive simulation of context loading during a session, startup items (system prompt, auto memory, environment info, MCP tools, skill descriptions, CLAUDE.md files), file reads as primary context cost, path-scoped rules auto-loading, hook output via additionalContext, subagent isolation, /compact behavior and what survives it
- [Fullscreen rendering](references/claude-code-fullscreen.md) -- CLAUDE_CODE_NO_FLICKER=1, alternate screen buffer, mouse support (click/drag/scroll/URL opening), keyboard scrolling (PgUp/PgDn/Ctrl+Home/Ctrl+End), Ctrl+o transcript mode with / search and [ scrollback export, CLAUDE_CODE_DISABLE_MOUSE, CLAUDE_CODE_SCROLL_SPEED, tmux compatibility, copy-on-select behavior

## Sources

- Model configuration: https://code.claude.com/docs/en/model-config.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Extend Claude Code: https://code.claude.com/docs/en/features-overview.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Cloud scheduled tasks: https://code.claude.com/docs/en/web-scheduled-tasks.md
- Context window: https://code.claude.com/docs/en/context-window.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
