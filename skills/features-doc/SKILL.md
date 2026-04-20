---
name: features-doc
description: Complete official documentation for Claude Code features — model configuration, model aliases, effort levels, fast mode, output styles, status line, checkpointing, remote control, scheduled tasks, channels, voice dictation, routines, fullscreen rendering, and context window internals.
user-invocable: false
---

# Claude Code Features Documentation

This skill provides the complete official documentation for Claude Code features covering model configuration, interface customization, session management, scheduling, remote access, and context window behavior.

## Quick Reference

### Model Aliases

| Alias         | Behavior                                                                              |
| :------------ | :------------------------------------------------------------------------------------ |
| `default`     | Clears any override; resolves to the recommended model for your account type          |
| `best`        | Most capable model (currently equivalent to `opus`)                                  |
| `sonnet`      | Latest Sonnet for daily coding tasks                                                  |
| `opus`        | Latest Opus for complex reasoning                                                     |
| `haiku`       | Fast and efficient for simple tasks                                                   |
| `sonnet[1m]`  | Sonnet with 1M token context window                                                   |
| `opus[1m]`    | Opus with 1M token context window                                                     |
| `opusplan`    | Opus in plan mode, switches to Sonnet for execution                                   |

Default model by plan: Max/Team Premium → Opus 4.7; Pro/Team Standard/Enterprise/API → Sonnet 4.6; Bedrock/Vertex/Foundry → Sonnet 4.5.

Set model via: `/model <alias>` in session · `--model <alias>` at startup · `ANTHROPIC_MODEL` env var · `model` field in settings.

### Effort Levels

Supported on Opus 4.7, Opus 4.6, Sonnet 4.6. Set via `/effort`, `--effort`, `CLAUDE_CODE_EFFORT_LEVEL`, or `effortLevel` in settings.

| Level    | Notes                                                                                  |
| :------- | :------------------------------------------------------------------------------------- |
| `low`    | Latency-sensitive tasks only                                                           |
| `medium` | Reduces token usage, trades some intelligence                                          |
| `high`   | Balanced; minimum for intelligence-sensitive work                                      |
| `xhigh`  | Best for most coding tasks; default on Opus 4.7 (not available on Opus 4.6/Sonnet 4.6)|
| `max`    | Deepest reasoning; current session only (unless set via env var)                       |

### Extended Context (1M tokens)

| Plan                      | Opus 1M              | Sonnet 1M            |
| :------------------------ | :------------------- | :------------------- |
| Max, Team, Enterprise     | Included             | Requires extra usage |
| Pro                       | Requires extra usage | Requires extra usage |
| API / pay-as-you-go       | Full access          | Full access          |

Enable with `[1m]` suffix: `/model opus[1m]`. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

### Model Environment Variables

| Variable                         | Purpose                                                        |
| :------------------------------- | :------------------------------------------------------------- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL`   | Model for `opus` alias and `opusplan` plan phase               |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` alias and `opusplan` execution phase        |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL`  | Model for `haiku` alias and background functionality           |
| `CLAUDE_CODE_SUBAGENT_MODEL`     | Model for subagents                                            |
| `ANTHROPIC_CUSTOM_MODEL_OPTION`  | Add a single custom entry to the `/model` picker               |

### Fast Mode (Opus 4.6 only, research preview)

- 2.5x faster, higher cost: $30/$150 per MTok input/output
- Toggle: `/fast` or `"fastMode": true` in settings
- Requires extra usage billing; not available on Bedrock/Vertex/Foundry
- Falls back automatically to standard Opus 4.6 on rate limit; `↯` icon shows status
- Team/Enterprise: admin must enable; use `fastModePerSessionOptIn: true` to require per-session opt-in

### Prompt Caching

| Variable                        | Purpose                               |
| :------------------------------ | :------------------------------------ |
| `DISABLE_PROMPT_CACHING`        | Disable caching for all models        |
| `DISABLE_PROMPT_CACHING_HAIKU`  | Disable caching for Haiku only        |
| `DISABLE_PROMPT_CACHING_SONNET` | Disable caching for Sonnet only       |
| `DISABLE_PROMPT_CACHING_OPUS`   | Disable caching for Opus only         |

### Output Styles

Change how Claude responds (tone, format, role) without changing its capabilities. Set via `/config` → Output style, or `outputStyle` in settings.

| Style         | Description                                                                |
| :------------ | :------------------------------------------------------------------------- |
| `Default`     | Standard software engineering assistant                                    |
| `Explanatory` | Adds "Insights" about implementation choices and patterns                  |
| `Learning`    | Asks you to implement small pieces; adds `TODO(human)` markers             |
| Custom        | Markdown file with frontmatter in `~/.claude/output-styles/` or `.claude/output-styles/` |

Custom style frontmatter fields: `name`, `description`, `keep-coding-instructions` (default: false).

### Status Line

Configurable bar at the bottom of the CLI. Runs a shell script that receives session JSON on stdin.

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2,
    "refreshInterval": 5
  }
}
```

Key available JSON fields: `model.id`, `model.display_name`, `workspace.current_dir`, `workspace.project_dir`, `cost.total_cost_usd`, `cost.total_duration_ms`, `context_window.used_percentage`, `context_window.context_window_size`, `rate_limits.five_hour.used_percentage`, `rate_limits.seven_day.used_percentage`, `session_id`, `session_name`, `vim.mode`, `worktree.*`.

Generate automatically: `/statusline show model name and context percentage with a progress bar`

### Checkpointing (Rewind)

Claude Code automatically tracks file edits before each prompt. Access via `Esc Esc` or `/rewind`.

Rewind options:
- **Restore code and conversation** — revert both
- **Restore conversation** — keep current code
- **Restore code** — keep conversation
- **Summarize from here** — compress conversation from this point (like targeted `/compact`)

Limitations: bash command file changes are not tracked; external edits not tracked; not a replacement for git.

### Scheduling Options Comparison

| Feature | Cloud (Routines) | Desktop scheduled tasks | `/loop` in-session |
| :------ | :--------------- | :---------------------- | :------------------ |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Access to local files | No (fresh clone) | Yes | Yes |
| Minimum interval | 1 hour | 1 minute | 1 minute |

### `/loop` Scheduled Tasks

| Invocation | Behavior |
| :--------- | :------- |
| `/loop 5m check the deploy` | Fixed schedule with your prompt |
| `/loop check the deploy` | Claude picks interval dynamically |
| `/loop` | Built-in maintenance prompt (continue work, tend to PRs, cleanup) |

- Cron tools: `CronCreate`, `CronList`, `CronDelete` (up to 50 tasks per session)
- Tasks expire after 7 days; restored on `--resume` if unexpired
- Disable: `CLAUDE_CODE_DISABLE_CRON=1`
- Custom default prompt: `.claude/loop.md` (project) or `~/.claude/loop.md` (user)

### Remote Control

Continue a local Claude Code session from another device (browser, phone, tablet).

```bash
claude remote-control              # server mode — multiple connections
claude --remote-control            # interactive session with remote enabled
# In session:
/remote-control                    # enable remote for current session
```

Server mode flags: `--name`, `--spawn same-dir|worktree|session`, `--capacity <N>`, `--sandbox`.

- Requires claude.ai subscription (Pro/Max/Team/Enterprise); not available with API keys
- Runs locally — filesystem, MCP servers, tools all stay local
- Push notifications available via Claude mobile app (iOS/Android) with `/config` → Push when Claude decides

### Channels (research preview)

Push events (webhooks, chat messages) into a running session from Telegram, Discord, or iMessage.

```bash
claude --channels plugin:telegram@claude-plugins-official
```

Install plugins via `/plugin install telegram@claude-plugins-official`. Pair with `/telegram:access pair <code>`.

Enterprise managed settings: `channelsEnabled` (master switch), `allowedChannelPlugins` (restrict which plugins).

### Voice Dictation

Hold `Space` to record. Speech appears in prompt input in real-time.

- Enable: `/voice` or `"voiceEnabled": true` in settings
- Requires claude.ai login (not API key or third-party providers)
- Rebind push-to-talk: `voice:pushToTalk` in `~/.claude/keybindings.json`
- Language: follows `language` setting (20 languages supported)
- Not available in remote environments (SSH, Claude Code on the web)

### Routines (cloud scheduled tasks, research preview)

Saved Claude Code configurations that run on Anthropic-managed infrastructure.

Trigger types: **Scheduled** (hourly minimum), **API** (HTTP POST to per-routine endpoint), **GitHub** (PR events, releases).

Manage at `claude.ai/code/routines` or via `/schedule` in CLI. Each run is a full cloud session with fresh repo clone.

### Fullscreen Rendering (research preview)

Eliminates flicker, flat memory in long sessions, adds mouse support. Uses alternate screen buffer.

```bash
/tui fullscreen          # enable
/tui default             # disable
CLAUDE_CODE_NO_FLICKER=1 claude   # via env var
```

Mouse support: click to expand tool results, click URLs/paths, click-drag to select (copies to clipboard). Disable mouse capture: `CLAUDE_CODE_DISABLE_MOUSE=1`.

Search in fullscreen: `Ctrl+o` → transcript mode → `/` to search, `[` to dump to scrollback.

### Context Window Loading Order (session start)

1. System prompt (~4,200 tokens, hidden)
2. Auto memory / MEMORY.md (~680 tokens, hidden)
3. Environment info (~280 tokens, hidden)
4. MCP tool names, deferred schemas (~120 tokens, hidden)
5. Skill descriptions (~450 tokens, hidden; not re-injected after `/compact`)
6. `~/.claude/CLAUDE.md` (~320 tokens, hidden)
7. Project CLAUDE.md (~1,800 tokens, hidden)

### What Survives `/compact`

| Mechanism | After compaction |
| :-------- | :--------------- |
| System prompt and output style | Unchanged (not message history) |
| Project-root CLAUDE.md and unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | Lost until matching file read again |
| Nested CLAUDE.md in subdirectories | Lost until file in that dir read again |
| Invoked skill bodies | Re-injected (capped: 5K tokens/skill, 25K total; oldest dropped first) |

### Feature Selection Guide

| Goal | Use |
| :--- | :-- |
| Always-on project conventions | CLAUDE.md |
| Reusable workflows or reference docs | Skills |
| External services and data | MCP |
| Parallel/isolated tasks | Subagents |
| Deterministic automation | Hooks |
| Recurring cloud automation | Routines |
| Continue local session from phone | Remote Control |
| React to chat messages or webhooks | Channels |
| Recurring in-session polling | `/loop` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Features Overview](references/claude-code-features-overview.md) — Extension layer guide: CLAUDE.md vs Skills vs MCP vs Subagents vs Hooks vs Plugins
- [Model Configuration](references/claude-code-model-config.md) — Model aliases, effort levels, extended context, env vars, third-party pinning
- [Fast Mode](references/claude-code-fast-mode.md) — 2.5x faster Opus 4.6 at higher cost; toggle, requirements, rate limits
- [Output Styles](references/claude-code-output-styles.md) — Built-in and custom styles, frontmatter, comparison to CLAUDE.md and agents
- [Status Line](references/claude-code-statusline.md) — Shell script configuration, available JSON fields, examples in Bash/Python/Node.js
- [Checkpointing](references/claude-code-checkpointing.md) — Automatic tracking, rewind menu, restore vs summarize, limitations
- [Remote Control](references/claude-code-remote-control.md) — Server mode, interactive mode, mobile push notifications, security model
- [Scheduled Tasks](references/claude-code-scheduled-tasks.md) — `/loop` usage, cron tools, one-time reminders, expiry, loop.md customization
- [Channels](references/claude-code-channels.md) — Telegram, Discord, iMessage setup; security allowlists; enterprise controls
- [Channels Reference](references/claude-code-channels-reference.md) — Build your own channel: MCP contract, notification format, reply tools, permission relay
- [Desktop Scheduled Tasks](references/claude-code-desktop-scheduled-tasks.md) — Local recurring tasks in the Desktop app; frequency options
- [Context Window](references/claude-code-context-window.md) — Interactive timeline of what loads when; compaction survival table
- [Fullscreen Rendering](references/claude-code-fullscreen.md) — Mouse support, scrolling shortcuts, transcript mode, tmux notes
- [Routines](references/claude-code-routines.md) — Cloud scheduled tasks: schedule/API/GitHub triggers, run management, limits
- [Voice Dictation](references/claude-code-voice-dictation.md) — Push-to-talk setup, language config, keybinding, troubleshooting

## Sources

- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled Tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels Reference: https://code.claude.com/docs/en/channels-reference.md
- Desktop Scheduled Tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Context Window: https://code.claude.com/docs/en/context-window.md
- Fullscreen Rendering: https://code.claude.com/docs/en/fullscreen.md
- Routines: https://code.claude.com/docs/en/routines.md
- Voice Dictation: https://code.claude.com/docs/en/voice-dictation.md
