---
name: features-doc
description: Complete documentation for Claude Code features and configuration -- extensibility overview (CLAUDE.md, Skills, MCP, Subagents, Agent teams, Hooks, Plugins), feature comparison tables (Skill vs Subagent, CLAUDE.md vs Skill, CLAUDE.md vs Rules vs Skills, Subagent vs Agent team, MCP vs Skill), context costs by feature, context loading lifecycle, feature layering and combination patterns (Skill+MCP, Skill+Subagent, CLAUDE.md+Skills, Hook+MCP), fast mode (2.5x speed Opus 4.6 with /fast toggle, $30/$150 MTok pricing, per-session opt-in with fastModePerSessionOptIn, rate limit fallback, extra usage required, research preview), model configuration (model aliases default/sonnet/opus/haiku/sonnet[1m]/opus[1m]/opusplan, /model command, --model flag, ANTHROPIC_MODEL env var, availableModels restriction with merge behavior, modelOverrides for Bedrock/Vertex/Foundry ARN mapping, effort levels low/medium/high/max/auto with /effort and --effort and CLAUDE_CODE_EFFORT_LEVEL and effortLevel setting and skill/subagent frontmatter effort field and adaptive reasoning and CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING, extended 1M context window with [1m] suffix and plan availability, opusplan hybrid plan/execute, ANTHROPIC_DEFAULT_OPUS_MODEL/ANTHROPIC_DEFAULT_SONNET_MODEL/ANTHROPIC_DEFAULT_HAIKU_MODEL/CLAUDE_CODE_SUBAGENT_MODEL env vars, ANTHROPIC_CUSTOM_MODEL_OPTION for custom /model entries, prompt caching with DISABLE_PROMPT_CACHING per-model), output styles (Default/Explanatory/Learning built-in styles, custom output style markdown files with frontmatter name/description/keep-coding-instructions, user ~/.claude/output-styles and project .claude/output-styles locations, system prompt modification, /config selection, outputStyle setting), status line (/statusline command with natural language, statusLine setting with type/command/padding, JSON session data on stdin including model/workspace/cost/context_window/rate_limits/vim/agent/worktree/output_style fields, ANSI colors, OSC 8 clickable links, multi-line output, script examples for context bars and git status and cost tracking), checkpointing (automatic edit tracking, Esc+Esc or /rewind menu, restore code/conversation/both, summarize from here for targeted context compression vs fork for branching, 30-day retention, bash and external changes not tracked), remote control (continue local sessions from any device via claude.ai/code or Claude mobile app, claude remote-control server mode with --name/--spawn same-dir or worktree/--capacity/--verbose/--sandbox flags, claude --remote-control interactive mode, /remote-control from existing session, QR code pairing, session URL, auto-reconnect, HTTPS-only outbound, Team/Enterprise admin toggle, enable for all sessions via /config), scheduled tasks (/loop skill for recurring prompts with interval syntax like 5m/2h with units s/m/h/d, CronCreate/CronList/CronDelete tools, one-time reminders in natural language, session-scoped with 3-day expiry, jitter for load balancing, CLAUDE_CODE_DISABLE_CRON=1 to disable, 5-field cron expressions in local timezone, max 50 tasks), voice dictation (/voice toggle with push-to-talk Space key, streaming speech-to-text, coding vocabulary recognition with project/branch hints, 20 supported languages, rebind push-to-talk via keybindings.json voice:pushToTalk in Chat context, voiceEnabled setting, requires claude.ai auth and local mic, macOS/Linux/Windows native module), channels (push events into running sessions from external sources, MCP-based channel servers, Telegram/Discord/fakechat plugins, --channels flag, two-way chat bridges with reply tools, sender allowlists and pairing flow, channelsEnabled enterprise control, permission relay for remote tool approval, research preview), channels reference (building custom channels, claude/channel MCP capability declaration, notifications/claude/channel event format with content/meta fields, Server constructor options with capabilities/instructions, reply tool exposure via MCP tools capability, sender gating against prompt injection, permission relay with claude/channel/permission capability and request_id/tool_name/description/input_preview fields and allow/deny verdicts, webhook receiver example, --dangerously-load-development-channels for testing, package as plugin). Load when discussing Claude Code features, fast mode, /fast, model configuration, /model, model aliases, opusplan, effort levels, /effort, adaptive reasoning, extended context, 1M context, output styles, /config output style, custom output styles, keep-coding-instructions, status line, /statusline, statusLine setting, status bar, checkpointing, /rewind, restore code, restore conversation, summarize context, remote control, /remote-control, /rc, claude remote-control, continue session from phone, scheduled tasks, /loop, cron, CronCreate, reminders, voice dictation, /voice, push-to-talk, speech-to-text, dictation, channels, --channels, Telegram channel, Discord channel, fakechat, channel reference, building channels, webhook receiver, permission relay, channel MCP server, feature comparison, context costs, feature layering, availableModels, modelOverrides, prompt caching, ANTHROPIC_DEFAULT_OPUS_MODEL, CLAUDE_CODE_SUBAGENT_MODEL, or extending Claude Code.
user-invocable: false
---

# Features & Configuration Documentation

This skill provides the complete official documentation for Claude Code features, configuration options, and the extensibility overview that maps each feature to its purpose.

## Quick Reference

Claude Code offers a range of features for customizing the model, interface, and workflow. The extensibility system maps each feature to a different part of the agentic loop: CLAUDE.md for persistent context, Skills for on-demand knowledge, MCP for external services, Subagents for isolated work, Hooks for deterministic automation, and Plugins for packaging.

### Feature-to-Purpose Map

| Feature | What it does | When to use it |
|:--------|:-------------|:---------------|
| **CLAUDE.md** | Persistent context loaded every session | Project conventions, "always do X" rules |
| **Skill** | On-demand knowledge and invocable workflows | Reference docs, repeatable tasks, `/deploy` checklists |
| **Subagent** | Isolated execution context returning summaries | Context isolation, parallel tasks, specialized workers |
| **Agent team** | Coordinate multiple independent sessions | Parallel research, competing hypotheses, multi-owner features |
| **MCP** | Connect to external services | Database queries, Slack, browser control |
| **Hook** | Deterministic script on lifecycle events | Auto-lint after edits, block protected files, notifications |
| **Plugin** | Bundle skills, hooks, subagents, MCP servers | Reuse across repos, distribute via marketplaces |

### Context Cost by Feature

| Feature | When it loads | Context cost |
|:--------|:--------------|:-------------|
| **CLAUDE.md** | Session start | Every request (full content) |
| **Skills** | Descriptions at start; full on use | Low until used |
| **MCP servers** | Session start | Every request (tool schemas) |
| **Subagents** | When spawned | Isolated from main session |
| **Hooks** | On trigger | Zero (runs externally) |

### Feature Layering

Features override or merge differently: CLAUDE.md files are additive across all levels. Skills and subagents override by name (managed > user > project). MCP servers override by name (local > project > user). Hooks merge -- all registered hooks fire for matching events.

### Fast Mode

| Setting | Value |
|:--------|:------|
| Toggle | `/fast` command or `"fastMode": true` in settings |
| Pricing | $30 input / $150 output per MTok (flat across 1M context) |
| Model | Same Opus 4.6, different API config prioritizing speed |
| Availability | Pro/Max/Team/Enterprise, extra usage only |
| Rate limit fallback | Automatic fallback to standard Opus 4.6 during cooldown |
| Per-session opt-in | `"fastModePerSessionOptIn": true` in managed settings |
| Disable entirely | `CLAUDE_CODE_DISABLE_FAST_MODE=1` env var |

Fast mode is 2.5x faster at higher cost. Enabling mid-conversation repays full fast-mode uncached input price for existing context. Best for rapid iteration and live debugging. Not a different model -- same quality, just faster.

### Model Configuration

**Model aliases:**

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended model for your account type |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast and efficient for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus for planning, Sonnet for execution |

**Setting the model (priority order):**

1. `/model <alias|name>` during session
2. `claude --model <alias|name>` at startup
3. `ANTHROPIC_MODEL=<alias|name>` env var
4. `model` field in settings file

**Effort levels:** `low`, `medium`, `high`, `max` (Opus only, current session only), `auto` (reset to model default). Set via `/effort`, `/model` slider, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL` env var, `effortLevel` setting, or skill/subagent frontmatter `effort` field. Env var takes precedence over all other methods. Frontmatter effort overrides session level but not the env var. Opus 4.6 defaults to medium for Max and Team. The current effort level is displayed next to the logo/spinner. Disable adaptive reasoning with `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1`.

**Extended context (1M tokens):** Available on Opus 4.6 and Sonnet 4.6. Use `[1m]` suffix with aliases or model names. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`. On Max/Team/Enterprise, Opus gets 1M automatically.

**Restrict models:** `availableModels` in managed/policy settings restricts which models users can select. The Default option is always available regardless. Use with `model` setting to control the exact model users run.

**Override model IDs:** `modelOverrides` maps Anthropic model IDs to provider-specific strings (Bedrock ARNs, Vertex version names, Foundry deployment names).

**Model environment variables:**

| Variable | Controls |
|:---------|:---------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `opus` alias and `opusplan` plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `sonnet` alias and `opusplan` execution |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `haiku` alias and background functionality |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Subagent model |
| `ANTHROPIC_CUSTOM_MODEL_OPTION` | Custom entry in `/model` picker |

**Prompt caching:** Disable globally with `DISABLE_PROMPT_CACHING=1`, or per-model with `DISABLE_PROMPT_CACHING_HAIKU`, `DISABLE_PROMPT_CACHING_SONNET`, `DISABLE_PROMPT_CACHING_OPUS`.

### Output Styles

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Shares educational "Insights" while coding |
| **Learning** | Collaborative mode with `TODO(human)` markers for you to implement |

Set via `/config` > Output style, or `"outputStyle": "Explanatory"` in settings. Changes apply on next session start.

**Custom output styles:** Markdown files in `~/.claude/output-styles/` (user) or `.claude/output-styles/` (project). Frontmatter fields: `name`, `description`, `keep-coding-instructions` (default false). Custom styles replace Claude Code's coding-specific system prompt unless `keep-coding-instructions` is true.

### Status Line

A customizable bar running any shell script. Configure with `/statusline <description>` or manually via `statusLine` setting with `type: "command"` and `command` pointing to a script.

**Available JSON input fields:**

| Field | Description |
|:------|:------------|
| `model.id`, `model.display_name` | Current model |
| `workspace.current_dir`, `workspace.project_dir` | Directories |
| `cost.total_cost_usd` | Session cost in USD |
| `cost.total_duration_ms`, `cost.total_api_duration_ms` | Timing |
| `cost.total_lines_added`, `cost.total_lines_removed` | Code changes |
| `context_window.used_percentage` | Context usage % |
| `context_window.context_window_size` | Max tokens (200K or 1M) |
| `context_window.current_usage` | Last API call token breakdown |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit usage |
| `rate_limits.seven_day.used_percentage` | 7-day rate limit usage |
| `vim.mode` | `NORMAL` or `INSERT` (when vim mode enabled) |
| `agent.name` | Agent name (when using `--agent`) |
| `worktree.*` | Worktree name, path, branch (during `--worktree` sessions) |
| `session_id`, `version`, `transcript_path` | Session metadata |

Supports ANSI colors, OSC 8 clickable links, multi-line output. Updates after each assistant message, debounced at 300ms. Optional `padding` field for horizontal spacing.

### Checkpointing

Automatic tracking of Claude's file edits. Access via `Esc+Esc` or `/rewind`.

| Action | Effect |
|:-------|:-------|
| **Restore code and conversation** | Revert both to selected point |
| **Restore conversation** | Rewind messages, keep current code |
| **Restore code** | Revert files, keep conversation |
| **Summarize from here** | Compress messages from that point forward into a summary |

Checkpoints persist across sessions (30-day retention, configurable). Does not track bash command file changes or external edits. Complements but does not replace git.

### Remote Control

Continue a local Claude Code session from any device via claude.ai/code or the Claude mobile app. Session runs locally -- filesystem, MCP servers, tools stay available.

| Mode | Command |
|:-----|:--------|
| Server mode | `claude remote-control` (dedicated server, `--spawn same-dir\|worktree`, `--capacity N`, `--name`) |
| Interactive | `claude --remote-control` (or `--rc`) |
| From existing session | `/remote-control` (or `/rc`) |

Requires claude.ai auth (not API keys). Team/Enterprise: admin must enable Remote Control toggle. HTTPS-only outbound, no inbound ports opened. Auto-reconnects after laptop sleep or network drops. Enable for all sessions via `/config`. Connect via session URL, QR code (spacebar to toggle in server mode), or session list at claude.ai/code. Server mode `--spawn worktree` gives each concurrent session its own git worktree; default `--spawn same-dir` shares the working directory. `--capacity` defaults to 32 concurrent sessions. 10-minute network timeout before session exits.

### Scheduled Tasks

Session-scoped cron jobs for recurring prompts or one-time reminders.

| Feature | Details |
|:--------|:--------|
| **`/loop`** | `/loop 5m check the build` -- recurring prompt with interval syntax (`s/m/h/d`) |
| **One-time** | `remind me at 3pm to push the release branch` -- natural language, auto-deletes |
| **Tools** | `CronCreate`, `CronList`, `CronDelete` (8-char task IDs) |
| **Limits** | 50 tasks per session, 3-day expiry for recurring tasks |
| **Timezone** | Local timezone for all cron expressions |
| **Disable** | `CLAUDE_CODE_DISABLE_CRON=1` |

Session-scoped only -- tasks disappear when Claude Code exits. No catch-up for missed fires. For durable scheduling, use Desktop scheduled tasks or GitHub Actions.

### Voice Dictation

Push-to-talk speech-to-text. Hold `Space` to record, release to finalize. Enable with `/voice`.

| Setting | Details |
|:--------|:--------|
| Toggle | `/voice` or `"voiceEnabled": true` in settings |
| Key | `Space` (default), rebind in `~/.claude/keybindings.json` via `voice:pushToTalk` |
| Language | Uses `language` setting; defaults to English; 20 languages supported |
| Requirements | Claude.ai auth, local microphone access |

Modifier combos (e.g., `meta+k`) skip warmup delay. Transcription tuned for coding vocabulary. Mix voice and typing in the same message.

### Channels

Push events from external systems into a running Claude Code session. Channels are MCP servers that emit `notifications/claude/channel` events.

| Channel | Setup |
|:--------|:------|
| **Telegram** | `/plugin install telegram@claude-plugins-official`, configure token, `--channels plugin:telegram@...` |
| **Discord** | `/plugin install discord@claude-plugins-official`, configure token, `--channels plugin:discord@...` |
| **Fakechat** | Localhost demo, no auth needed |

**Security:** Sender allowlists with pairing flow. Being in `.mcp.json` alone is not enough -- server must be named in `--channels`.

**Enterprise:** `channelsEnabled` setting controls availability. Off by default for Team/Enterprise until admin enables.

**Building custom channels:** Declare `claude/channel` in MCP `capabilities.experimental`. Emit `notifications/claude/channel` with `content` (string body) and optional `meta` (key-value attributes). Add `tools: {}` capability and a reply tool for two-way channels. Declare `claude/channel/permission` for permission relay (forwards tool approval prompts remotely with request ID verification). Gate senders to prevent prompt injection.

Research preview: custom channels require `--dangerously-load-development-channels` until added to the approved allowlist.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code (features overview)](references/claude-code-features-overview.md) -- extensibility overview, feature-to-goal mapping table, feature comparison tabs (Skill vs Subagent, CLAUDE.md vs Skill, CLAUDE.md vs Rules vs Skills, Subagent vs Agent team, MCP vs Skill), feature layering and override rules, combination patterns (Skill+MCP, Skill+Subagent, CLAUDE.md+Skills, Hook+MCP), context costs by feature, context loading lifecycle details
- [Fast mode](references/claude-code-fast-mode.md) -- 2.5x speed Opus 4.6, /fast toggle, fastMode setting, $30/$150 MTok pricing flat across 1M context, cost tradeoffs (mid-conversation switching costs full uncached input price), fast mode vs effort level comparison, when to use (rapid iteration, debugging) vs standard mode (long tasks, batch, CI), requirements (extra usage required, not Bedrock/Vertex/Foundry, admin enablement for Teams/Enterprise), per-session opt-in (fastModePerSessionOptIn), rate limit fallback with gray icon and auto re-enable, CLAUDE_CODE_DISABLE_FAST_MODE, research preview status
- [Model configuration](references/claude-code-model-config.md) -- model aliases (default/sonnet/opus/haiku/opusplan/[1m] variants), setting methods (/model, --model, ANTHROPIC_MODEL, settings file), availableModels restriction with merge behavior, default model per account type, opusplan hybrid mode, effort levels (low/medium/high/max/auto, /effort, /model slider, --effort, CLAUDE_CODE_EFFORT_LEVEL, effortLevel setting, skill/subagent frontmatter effort field, adaptive reasoning, CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING), extended 1M context (plan availability table, [1m] suffix, CLAUDE_CODE_DISABLE_1M_CONTEXT), ANTHROPIC_CUSTOM_MODEL_OPTION with optional _NAME and _DESCRIPTION, model environment variables, modelOverrides for third-party provider ARN/ID mapping, prompt caching configuration (DISABLE_PROMPT_CACHING, per-model disable)
- [Output styles](references/claude-code-output-styles.md) -- Default/Explanatory/Learning built-in styles, system prompt modification mechanics, /config selection, outputStyle setting, custom output style markdown files with frontmatter (name, description, keep-coding-instructions), user and project level locations, comparison to CLAUDE.md, --append-system-prompt, Agents, and Skills
- [Status line](references/claude-code-statusline.md) -- /statusline command with natural language, manual configuration (statusLine setting with type/command/padding), build step-by-step walkthrough, how status lines work (update debounced at 300ms after assistant messages), full JSON input schema (model.id/display_name, workspace.current_dir/project_dir, cost.total_cost_usd/total_duration_ms/total_api_duration_ms/total_lines_added/total_lines_removed, context_window with cumulative totals and current_usage breakdown and used_percentage/remaining_percentage, exceeds_200k_tokens, rate_limits.five_hour/seven_day with used_percentage/resets_at, session_id, transcript_path, version, output_style.name, vim.mode, agent.name, worktree.name/path/branch/original_cwd/original_branch), ANSI colors, OSC 8 clickable links, multi-line output, script examples in Bash/Python/Node.js (context progress bar, git status with colors, cost and duration tracking, multi-line layouts, clickable links), Windows PowerShell/Git Bash configuration
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic edit tracking per prompt, Esc+Esc and /rewind menu, four actions (restore code+conversation, restore conversation, restore code, summarize from here), summarize vs /compact (targeted compression keeping early context intact), fork vs summarize (branching vs compressing), persist across sessions with 30-day cleanup, limitations (bash commands not tracked, external changes not tracked, not a git replacement)
- [Remote Control](references/claude-code-remote-control.md) -- continue local sessions from any device, server mode (claude remote-control with --name/--spawn same-dir or worktree/--capacity default 32/--verbose/--sandbox flags), interactive mode (--remote-control/--rc), /remote-control from existing session, connect via URL/QR code/session list, session title priority, enable for all sessions via /config, HTTPS-only security with short-lived credentials, requirements (claude.ai auth, workspace trust), Team/Enterprise admin toggle, comparison to Claude Code on the web, limitations (one session per process, terminal must stay open, 10-minute network timeout), troubleshooting (not-yet-enabled, disabled-by-org, credentials-fetch-failed)
- [Scheduled tasks](references/claude-code-scheduled-tasks.md) -- /loop bundled skill with interval syntax (s/m/h/d units, leading/trailing/default 10m), loop over commands/skills, one-time reminders in natural language, CronCreate/CronList/CronDelete tools with 8-char task IDs, session-scoped execution (no persistence no catch-up), local timezone, low-priority firing between turns, jitter behavior (recurring up to 10% capped 15min, one-shot up to 90s early), 3-day expiry, 50-task limit, 5-field cron expression reference, CLAUDE_CODE_DISABLE_CRON, limitations
- [Voice dictation](references/claude-code-voice-dictation.md) -- /voice toggle, push-to-talk with Space (hold to record, release to finalize), rebind via keybindings.json voice:pushToTalk in Chat context, streaming transcription tuned for coding vocabulary with project/branch name hints, 20 supported languages, voiceEnabled setting, language setting, warmup delay (skip with modifier combos like meta+k), requirements (claude.ai auth, local mic, macOS/Linux/Windows native module with arecord/SoX fallback, no remote/SSH/WSL1), troubleshooting (API key auth, microphone denied, no audio tool on Linux, hold detection, wrong language)
- [Channels](references/claude-code-channels.md) -- push events into running sessions via channel MCP servers, research preview requiring v2.1.80+, Telegram/Discord/fakechat setup with plugin install and token configuration and pairing, --channels flag with plugin:name@marketplace syntax, quickstart with fakechat, sender allowlists and pairing flow, enterprise controls (channelsEnabled disabled by default on Team/Enterprise), one-way alerts vs two-way chat bridges, permission relay for remote tool approval, comparison to Claude Code on the web/Slack/MCP/Remote Control
- [Channels reference](references/claude-code-channels-reference.md) -- building custom channel MCP servers, claude/channel capability declaration, notifications/claude/channel event format (content string, meta Record with attribute keys), Server constructor options (capabilities with experimental claude/channel, instructions string for system prompt), webhook receiver walkthrough with Bun/HTTP, expose reply tool with ListToolsRequestSchema/CallToolRequestSchema, sender gating with allowlist against prompt injection, permission relay (claude/channel/permission capability requiring v2.1.81+, permission_request notification with request_id/tool_name/description/input_preview, permission verdict allow/deny), full two-way example with SSE and sender gating, --dangerously-load-development-channels for testing, packaging as plugin for marketplace

## Sources

- Extend Claude Code: https://code.claude.com/docs/en/features-overview.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
