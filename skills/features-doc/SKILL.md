---
name: features-doc
description: Complete documentation for Claude Code features -- fast mode (2.5x faster Opus 4.6, /fast toggle, $30/150 MTok pricing, extra usage billing, per-session opt-in with fastModePerSessionOptIn, rate limit fallback, research preview), model configuration (model aliases default/sonnet/opus/haiku/sonnet[1m]/opus[1m]/opusplan, /model and --model and ANTHROPIC_MODEL, availableModels restriction, modelOverrides for Bedrock/Vertex/Foundry ARNs, default model by plan tier, opusplan hybrid plan/execute, effort levels low/medium/high/max with /effort and --effort and CLAUDE_CODE_EFFORT_LEVEL and effortLevel setting and skill/subagent frontmatter, extended 1M context window with [1m] suffix and plan availability, ANTHROPIC_DEFAULT_OPUS_MODEL/SONNET_MODEL/HAIKU_MODEL for pinning, ANTHROPIC_CUSTOM_MODEL_OPTION for custom picker entries, prompt caching control with DISABLE_PROMPT_CACHING), output styles (Default/Explanatory/Learning built-in styles, custom output style markdown files with frontmatter name/description/keep-coding-instructions, system prompt modification, /config to change, outputStyle setting, user-level and project-level style files in .claude/output-styles), status line (customizable bottom bar running shell scripts, /statusline command for auto-generation, manual config with statusLine setting type/command/padding, JSON session data on stdin with model/workspace/cost/context_window/session_id/vim/agent/worktree fields, ANSI colors and OSC 8 clickable links, multi-line output, context window fields with token breakdowns, Windows PowerShell/Git Bash support), checkpointing (automatic file edit tracking, Esc+Esc or /rewind menu, restore code/conversation/both or summarize from checkpoint, session persistence for 30 days, bash command changes not tracked, not a replacement for git), features overview (extension layer with CLAUDE.md/Skills/MCP/Subagents/Agent teams/Hooks/Plugins, feature comparison tables Skill vs Subagent/CLAUDE.md vs Skill/CLAUDE.md vs Rules vs Skills/Subagent vs Agent team/MCP vs Skill, context costs by feature type, feature layering and combination patterns), remote control (continue local sessions from phone/tablet/browser via claude.ai/code and Claude mobile app, claude remote-control server mode with --name/--spawn/--capacity/--verbose/--sandbox flags, claude --remote-control or --rc for interactive mode, /remote-control from existing session, QR code pairing, session URL, enable for all sessions via /config, outbound HTTPS only with TLS security, vs Claude Code on the web comparison), scheduled tasks (session-scoped cron with /loop bundled skill, interval syntax s/m/h/d with leading/trailing/default parsing, loop over other commands, one-time reminders in natural language, CronCreate/CronList/CronDelete tools, jitter for recurring and one-shot tasks, 3-day auto-expiry, CLAUDE_CODE_DISABLE_CRON=1, cron expression reference), voice dictation (/voice toggle, hold Space push-to-talk with key-repeat warmup, voiceEnabled setting, streaming speech-to-text with coding vocabulary, 20 supported languages, rebind push-to-talk in keybindings.json with meta+k modifier combo, requires claude.ai account and local microphone), channels (push events into running sessions from MCP servers, Telegram and Discord plugins with bot creation/pairing/allowlist, fakechat localhost demo, --channels flag with plugin: prefix, channelsEnabled enterprise control, research preview with approved allowlist, --dangerously-load-development-channels for testing), channels reference (build custom channel MCP servers, claude/channel capability declaration, notifications/claude/channel events with content and meta params, reply tools for two-way channels with ListToolsRequestSchema/CallToolRequestSchema, sender gating with allowlist for prompt injection prevention, webhook receiver walkthrough, server options and notification format, package as plugin). Load when discussing fast mode, /fast, model configuration, model aliases, opusplan, effort level, /effort, extended context, 1M context, model pinning, output styles, Explanatory/Learning mode, custom output styles, status line, /statusline, statusline configuration, checkpointing, /rewind, restore conversation, features overview, extension comparison, remote control, /remote-control, --rc, scheduled tasks, /loop, cron, voice dictation, /voice, push-to-talk, channels, Telegram channel, Discord channel, channel reference, building channels, fakechat, availableModels, modelOverrides, or prompt caching configuration.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features including fast mode, model configuration, output styles, status line customization, checkpointing, the features/extensibility overview, remote control, scheduled tasks, voice dictation, and channels.

## Quick Reference

### Fast Mode

Toggle with `/fast` for 2.5x faster Opus 4.6 responses at higher cost. Not a different model -- same quality, different API configuration prioritizing speed.

| Detail | Value |
|:-------|:------|
| Pricing | $30/150 MTok (input/output) |
| Toggle | `/fast` or `"fastMode": true` in settings |
| Indicator | `↯` icon next to prompt (gray during cooldown) |
| Availability | Pro/Max/Team/Enterprise and Console; extra usage only for subscriptions |
| Rate limit behavior | Falls back to standard Opus 4.6 automatically, re-enables after cooldown |
| Version required | v2.1.36+ |

**Admin controls:** Teams/Enterprise must explicitly enable fast mode. Disable entirely with `CLAUDE_CODE_DISABLE_FAST_MODE=1`. Require per-session opt-in with `"fastModePerSessionOptIn": true` in managed settings.

**Cost tip:** Enable at session start rather than mid-conversation to avoid paying full uncached input price on existing context.

### Model Configuration

#### Model Aliases

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended model for your account type |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast, efficient Haiku for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus for planning, Sonnet for execution |

#### Setting Priority

1. `/model <alias\|name>` (during session)
2. `claude --model <alias\|name>` (at startup)
3. `ANTHROPIC_MODEL=<alias\|name>` (env var)
4. `model` field in settings file

#### Effort Levels

| Level | Behavior |
|:------|:---------|
| `low` | Less thinking, faster, potentially lower quality |
| `medium` | Default for Opus 4.6 on Max/Team |
| `high` | Deeper reasoning for complex problems |
| `max` | Deepest reasoning, no token constraint, Opus 4.6 only, session-only |

Set via: `/effort`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL` env var, `effortLevel` in settings, or `effort` in skill/subagent frontmatter.

#### Extended Context (1M)

Opus and Sonnet 4.6 support 1M token context. Max/Team/Enterprise get Opus 1M included. Use `[1m]` suffix: `/model opus[1m]`.

Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

#### Model Pinning Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Pin Opus alias to specific model ID |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Pin Sonnet alias to specific model ID |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Pin Haiku alias to specific model ID |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |

#### `availableModels` Restriction

Set in managed/policy settings to restrict which models users can select. The `default` model always remains available regardless.

#### `modelOverrides` Setting

Maps Anthropic model IDs to provider-specific strings (Bedrock ARNs, Vertex names, Foundry deployments) for per-version routing.

#### Custom Model Option

`ANTHROPIC_CUSTOM_MODEL_OPTION` adds a single custom entry to `/model` picker. Optional `_NAME` and `_DESCRIPTION` suffixed env vars for display.

#### Prompt Caching

| Variable | Effect |
|:---------|:-------|
| `DISABLE_PROMPT_CACHING` | Disable for all models (overrides per-model) |
| `DISABLE_PROMPT_CACHING_HAIKU` | Disable for Haiku only |
| `DISABLE_PROMPT_CACHING_SONNET` | Disable for Sonnet only |
| `DISABLE_PROMPT_CACHING_OPUS` | Disable for Opus only |

### Output Styles

Modify Claude Code's system prompt to adapt behavior beyond software engineering.

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Educational "Insights" while helping with engineering tasks |
| **Learning** | Collaborative learn-by-doing with `TODO(human)` markers |

**Custom styles:** Markdown files in `~/.claude/output-styles` (user) or `.claude/output-styles` (project) with frontmatter `name`, `description`, and `keep-coding-instructions` (default false).

Change via `/config` > Output style, or set `"outputStyle": "StyleName"` in settings. Takes effect on next session start.

### Status Line

Customizable bottom bar that runs any shell script, receiving JSON session data on stdin.

**Setup:** `/statusline <description>` auto-generates a script, or manually configure in settings:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

**Key JSON fields available:** `model.id`, `model.display_name`, `cwd`, `workspace.current_dir`, `workspace.project_dir`, `cost.total_cost_usd`, `cost.total_duration_ms`, `cost.total_lines_added`, `cost.total_lines_removed`, `context_window.used_percentage`, `context_window.remaining_percentage`, `context_window.context_window_size`, `context_window.current_usage.*`, `exceeds_200k_tokens`, `session_id`, `version`, `output_style.name`, `vim.mode`, `agent.name`, `worktree.name`, `worktree.path`.

**Output:** supports ANSI colors, OSC 8 clickable links, and multi-line output. Updates after each assistant message (300ms debounce). Does not consume API tokens.

### Checkpointing

Automatic tracking of file edits with rewind capability.

| Action | How |
|:-------|:----|
| Open rewind menu | `Esc+Esc` or `/rewind` |
| Restore code + conversation | Select checkpoint, choose "Restore code and conversation" |
| Restore conversation only | Rewind to message, keep current code |
| Restore code only | Revert files, keep conversation |
| Summarize from checkpoint | Compress conversation from selected point forward |

**Limitations:** bash command changes not tracked; external changes not tracked; checkpoints persist across sessions (30-day cleanup); not a replacement for git.

### Features Overview (Extensibility)

| Feature | What it does | When to use |
|:--------|:-------------|:------------|
| **CLAUDE.md** | Persistent context every session | "Always do X" rules, project conventions |
| **Skill** | On-demand knowledge and workflows | Reference docs, repeatable tasks with `/<name>` |
| **Subagent** | Isolated execution context | Context isolation, parallel tasks |
| **Agent teams** | Multiple independent sessions | Parallel research, competing hypotheses |
| **MCP** | External service connections | Database queries, Slack, browser control |
| **Hook** | Deterministic scripts on events | ESLint after edits, no LLM involved |
| **Plugin** | Packaging layer for distribution | Reuse across repos, share via marketplace |

**Context costs:** CLAUDE.md loads fully every request. Skills load descriptions at start, full content on use. MCP tool schemas load at start (tool search caps at 10% context). Subagents are isolated. Hooks have zero context cost.

### Remote Control

Continue local sessions from phone, tablet, or any browser via claude.ai/code or Claude mobile app.

| Mode | Command |
|:-----|:--------|
| Server mode | `claude remote-control` (dedicated server, `--name`, `--spawn`, `--capacity`) |
| Interactive + remote | `claude --remote-control` or `claude --rc` |
| From existing session | `/remote-control` or `/rc` |
| Enable for all sessions | `/config` > Enable Remote Control |

**Requirements:** Pro/Max/Team/Enterprise plan, claude.ai OAuth (not API keys), workspace trust accepted. v2.1.51+.

**Security:** outbound HTTPS only, no inbound ports, all traffic over TLS through Anthropic API.

**Spawn modes:** `--spawn same-dir` (default, shared working directory) or `--spawn worktree` (isolated git worktree per session).

### Scheduled Tasks

Session-scoped cron for recurring prompts, polling, and one-time reminders. Tasks only fire while Claude Code is running and idle.

| Method | Example |
|:-------|:--------|
| Recurring | `/loop 5m check if deployment finished` |
| One-time | `remind me at 3pm to push the release branch` |
| List tasks | `what scheduled tasks do I have?` |
| Cancel | `cancel the deploy check job` |

**Interval syntax:** `30m`, `2h`, `1d`; leading or trailing; default 10 minutes. Seconds rounded up to nearest minute.

**Tools:** `CronCreate` (schedule), `CronList` (list), `CronDelete` (cancel by 8-char ID). Max 50 tasks per session.

**Jitter:** recurring tasks fire up to 10% late (capped 15 min); one-shot at :00/:30 fire up to 90s early.

**Auto-expiry:** recurring tasks expire after 3 days. Disable scheduler with `CLAUDE_CODE_DISABLE_CRON=1`.

### Voice Dictation

Push-to-talk speech-to-text for prompt input. v2.1.69+.

| Setting | Details |
|:--------|:--------|
| Toggle | `/voice` or `"voiceEnabled": true` in settings |
| Push-to-talk key | Hold `Space` (default), rebind in `~/.claude/keybindings.json` |
| Language | Uses `language` setting, defaults to English; 20 languages supported |
| Requirements | claude.ai account, local microphone access (no remote/SSH) |

**Modifier binding tip:** rebind to `meta+k` for instant recording (no warmup delay from key-repeat detection).

Transcription is tuned for coding vocabulary. Project name and git branch are added as recognition hints.

### Channels

Push events into running sessions from MCP servers. Research preview, v2.1.80+.

| Channel | Setup |
|:--------|:------|
| **Telegram** | `/plugin install telegram@claude-plugins-official`, configure bot token, `--channels plugin:telegram@claude-plugins-official` |
| **Discord** | `/plugin install discord@claude-plugins-official`, configure bot token, `--channels plugin:discord@claude-plugins-official` |
| **Fakechat** | `/plugin install fakechat@claude-plugins-official`, localhost demo at `http://localhost:8787` |

**Security:** sender allowlist per channel; pair via bot DM + pairing code + `/access pair <code>` + `/access policy allowlist`.

**Enterprise:** controlled by `channelsEnabled` setting. Team/Enterprise disabled by default; admin enables via Claude Code admin settings.

### Channels Reference (Building Custom Channels)

Build an MCP server that pushes events into Claude Code sessions.

**Requirements:**
1. Declare `claude/channel` capability in server constructor
2. Emit `notifications/claude/channel` events with `content` (string) and optional `meta` (key-value attributes)
3. Connect over stdio transport

**Two-way channels:** add `tools: {}` capability, register `reply` tool with `ListToolsRequestSchema`/`CallToolRequestSchema` handlers, update `instructions` to tell Claude how to reply.

**Sender gating:** check sender against allowlist before emitting notifications to prevent prompt injection.

**Testing:** use `--dangerously-load-development-channels server:<name>` during research preview (custom channels not on approved allowlist).

## Full Documentation

For the complete official documentation, see the reference files:

- [Fast mode](references/claude-code-fast-mode.md) -- 2.5x faster Opus 4.6 responses, /fast toggle, $30/150 MTok pricing, extra usage billing (not counted against plan usage), rate limit fallback to standard Opus with gray icon and auto-re-enable, per-session opt-in with fastModePerSessionOptIn in managed settings, CLAUDE_CODE_DISABLE_FAST_MODE=1 to disable entirely, admin enablement for Teams/Enterprise via Console or Claude AI settings, cost tradeoff (mid-conversation switch pays full uncached input price), fast mode vs effort level comparison, research preview status
- [Model configuration](references/claude-code-model-config.md) -- model aliases (default/sonnet/opus/haiku/sonnet[1m]/opus[1m]/opusplan), setting priority (/model > --model > ANTHROPIC_MODEL > settings), availableModels restriction with merge behavior, default model by plan tier (Max/Team Premium = Opus, Pro/Team Standard = Sonnet), opusplan hybrid mode (Opus for planning, Sonnet for execution), effort levels (low/medium/high/max with /effort, --effort, CLAUDE_CODE_EFFORT_LEVEL, effortLevel setting, skill/subagent frontmatter, auto reset, CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING), extended 1M context window (plan availability table, [1m] suffix, CLAUDE_CODE_DISABLE_1M_CONTEXT), ANTHROPIC_DEFAULT_OPUS/SONNET/HAIKU_MODEL for pinning with Bedrock/Vertex/Foundry examples, CLAUDE_CODE_SUBAGENT_MODEL, ANTHROPIC_CUSTOM_MODEL_OPTION with _NAME/_DESCRIPTION, modelOverrides for per-version ARN/deployment routing, prompt caching configuration (DISABLE_PROMPT_CACHING and per-model variants)
- [Output styles](references/claude-code-output-styles.md) -- built-in styles (Default, Explanatory with Insights, Learning with TODO(human) markers), system prompt modification mechanics, /config selection saved to settings.local.json, outputStyle setting, custom styles as markdown files with frontmatter (name, description, keep-coding-instructions), user-level ~/.claude/output-styles and project-level .claude/output-styles, comparison vs CLAUDE.md vs --append-system-prompt vs Agents vs Skills
- [Status line configuration](references/claude-code-statusline.md) -- /statusline command for auto-generation, manual config with statusLine setting (type command, command path, padding), JSON session data on stdin (model, workspace, cost, context_window with token breakdowns and cache fields, exceeds_200k_tokens, session_id, transcript_path, version, output_style, vim mode, agent name, worktree fields), ANSI color codes and OSC 8 clickable links, multi-line output, 300ms debounce updates, context window fields (input_tokens, output_tokens, cache_creation_input_tokens, cache_read_input_tokens), Windows PowerShell and Git Bash support, ready-to-use examples (git status, cost tracking, progress bars, clickable links, multi-line)
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic file edit tracking, Esc+Esc or /rewind menu with scrollable prompt list, restore code and conversation / restore conversation / restore code / summarize from here / never mind, summarize vs restore behavior (compress messages, keep originals in transcript), session persistence (30-day cleanup configurable), bash command and external changes not tracked, common use cases (exploring alternatives, recovering from mistakes, iterating on features, freeing context space), not a replacement for version control
- [Features overview (Extend Claude Code)](references/claude-code-features-overview.md) -- extension layer overview (CLAUDE.md, Skills, MCP, Subagents, Agent teams, Hooks, Plugins, Marketplaces), feature comparison table with examples, detailed feature comparisons (Skill vs Subagent, CLAUDE.md vs Skill, CLAUDE.md vs Rules vs Skills, Subagent vs Agent team, MCP vs Skill), feature layering at multiple levels (additive CLAUDE.md, override-by-name Skills/MCP, merge Hooks), combination patterns (Skill+MCP, Skill+Subagent, CLAUDE.md+Skills, Hook+MCP), context costs by feature (loading strategy, what loads, cost per request), detailed loading behavior per feature type (CLAUDE.md at session start, Skills descriptions then full on use, MCP tool schemas with tool search at 10%, Subagents isolated, Hooks zero cost)
- [Remote Control](references/claude-code-remote-control.md) -- continue local sessions from phone/tablet/browser via claude.ai/code and Claude iOS/Android app, server mode (claude remote-control with --name/--spawn same-dir or worktree/--capacity/--verbose/--sandbox flags), interactive mode (claude --remote-control or --rc), from existing session (/remote-control or /rc), connect via session URL or QR code or session list, enable for all sessions via /config, session naming priority (--name > /rename > last message > first prompt), connection security (outbound HTTPS only, TLS, short-lived scoped credentials), vs Claude Code on the web (local vs cloud execution), limitations (one session per process outside server mode, terminal must stay open, 10-min network timeout), troubleshooting (not enabled, disabled by policy, credentials fetch failed)
- [Scheduled tasks](references/claude-code-scheduled-tasks.md) -- session-scoped cron with /loop bundled skill (interval syntax s/m/h/d, leading/trailing/default 10m, loop over commands), one-time reminders in natural language, CronCreate/CronList/CronDelete tools with 8-char IDs (max 50 per session), scheduler fires between turns at low priority, local timezone interpretation, jitter (recurring up to 10% capped 15min, one-shot at :00/:30 up to 90s early), 3-day auto-expiry for recurring tasks, CLAUDE_CODE_DISABLE_CRON=1, cron expression reference (5-field, wildcards, steps, ranges, lists, vixie-cron semantics), limitations (session-scoped only, no catch-up, no persistence across restarts)
- [Voice dictation](references/claude-code-voice-dictation.md) -- /voice toggle with voiceEnabled setting, hold Space push-to-talk with key-repeat warmup detection, rebind in ~/.claude/keybindings.json (meta+k for instant recording), streaming speech-to-text tuned for coding vocabulary (regex, OAuth, JSON, localhost), project name and git branch as recognition hints, 20 supported languages (set via language setting or /config), requires claude.ai account and local microphone (no remote/SSH/API key), cursor-position insertion for mixed voice+typing, macOS/Linux/Windows native audio module with Linux ALSA/SoX fallback, troubleshooting (microphone denied, no audio tool, wrong language, hold detection)
- [Channels](references/claude-code-channels.md) -- push events into running sessions from MCP servers, Telegram plugin (BotFather bot creation, /plugin install, /telegram:configure token, --channels plugin:telegram@claude-plugins-official, pairing flow with /telegram:access pair and policy allowlist), Discord plugin (Developer Portal bot, Message Content Intent, OAuth2 permissions, /plugin install, /discord:configure, pairing), fakechat localhost demo (quickstart walkthrough at localhost:8787), security (sender allowlist, pairing codes, --channels opt-in per session), enterprise controls (channelsEnabled setting, Team/Enterprise disabled by default, admin enablement), research preview (approved allowlist, --dangerously-load-development-channels for testing)
- [Channels reference](references/claude-code-channels-reference.md) -- build custom channel MCP servers, claude/channel capability declaration, notifications/claude/channel events with content and meta params, webhook receiver walkthrough (Bun HTTP server forwarding POSTs, .mcp.json registration, --dangerously-load-development-channels server: testing), server options (capabilities.experimental claude/channel, capabilities.tools for two-way, instructions for system prompt), notification format (content string, meta Record<string,string> as tag attributes), reply tool implementation (ListToolsRequestSchema/CallToolRequestSchema handlers, tool schema with chat_id/text), sender gating (allowlist before mcp.notification, gate on sender not room identity, pairing bootstrap flow), package as plugin for marketplace distribution

## Sources

- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line configuration: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Features overview: https://code.claude.com/docs/en/features-overview.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
