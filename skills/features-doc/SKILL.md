---
name: features-doc
description: Complete official documentation for Claude Code's built-in features — model selection, fast mode, effort levels, extended context, output styles, checkpointing, context window management, status line, voice dictation, fullscreen rendering, remote control, channels, routines, scheduled tasks, deep links, and the features-overview guide for choosing between CLAUDE.md, skills, hooks, MCP, subagents, and plugins.
user-invocable: false
---

# Claude Code Features Documentation

This skill provides the complete official documentation for Claude Code's built-in features and extension model.

## Quick Reference

### Features Overview — When to Use What

| Feature | What it does | When to use |
| :--- | :--- | :--- |
| **CLAUDE.md** | Persistent context every session | Project conventions, "always do X" rules |
| **Skills** | Reusable knowledge and workflows | Reference docs, repeatable tasks, invocable with `/name` |
| **MCP** | Connect to external services | Query a DB, post to Slack, browser control |
| **Subagents** | Isolated execution, returns summary | Context isolation, parallel tasks |
| **Agent teams** | Multiple independent sessions | Parallel research, competing hypotheses |
| **Hooks** | Fire on lifecycle events | Automation that must run every time |
| **Plugins** | Package and distribute features | Reuse across repos, share with others |

**Feature loading costs:**

| Feature | When it loads | Context cost |
| :--- | :--- | :--- |
| CLAUDE.md | Session start | Every request |
| Skills | Session start (descriptions) + on use | Low until used |
| MCP servers | Session start (names); schemas deferred | Low until tool used |
| Subagents | When spawned | Isolated from main session |
| Hooks | On trigger event | Zero unless hook returns output |

### Model Configuration

**Model aliases:**

| Alias | Behavior |
| :--- | :--- |
| `default` | Clears override, reverts to recommended model for account type |
| `best` | Most capable available (currently Opus) |
| `sonnet` | Latest Sonnet for daily coding |
| `opus` | Latest Opus for complex reasoning |
| `haiku` | Fast, efficient for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context |
| `opus[1m]` | Opus with 1M token context |
| `opusplan` | Opus for plan mode, Sonnet for execution |

**Set model** (priority order):
1. `/model <alias|name>` during session
2. `claude --model <alias|name>` at startup
3. `ANTHROPIC_MODEL=<alias|name>` env var
4. `model` field in settings file

**Effort levels** (Opus 4.7: `low/medium/high/xhigh/max`; Opus 4.6 / Sonnet 4.6: `low/medium/high/max`):

| Level | When to use |
| :--- | :--- |
| `low` | Short, scoped, latency-sensitive tasks |
| `medium` | Cost-sensitive work, some intelligence tradeoff |
| `high` | Minimum for intelligence-sensitive work |
| `xhigh` | Best for most coding/agentic tasks (default on Opus 4.7) |
| `max` | Deep reasoning, current session only |

Set with `/effort <level>`, `--effort` flag, or `effortLevel` in settings.  
Use `ultrathink` in a prompt for one-off deep reasoning without changing the session level.

**Extended context (1M token window):**
- Max, Team, Enterprise: Opus included; Sonnet requires extra usage
- Pro / API: extra usage for both
- Disable: `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`

**Key env vars:**

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Override `opus` alias resolution |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Override `sonnet` alias resolution |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Override `haiku` alias / background use |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching globally |

### Fast Mode

- Toggle: `/fast` or set `"fastMode": true` in user settings
- Effect: 2.5x faster Opus 4.6 at higher cost ($30/$150 MTok input/output)
- Availability: Pro/Max/Team/Enterprise via extra usage; not on Bedrock/Vertex/Foundry
- Status indicator: `↯` icon next to prompt when active
- Rate limit fallback: auto-falls back to standard Opus 4.6 when limit hit

**Admin controls (Team/Enterprise):**
- Enable: Claude Code preferences in Console or Admin Settings
- Per-session opt-in: `"fastModePerSessionOptIn": true` in managed settings
- Disable entirely: `CLAUDE_CODE_DISABLE_FAST_MODE=1`

### Checkpointing

- Automatic: captures file state before each edit (every prompt = new checkpoint)
- Access: press `Esc` twice or use `/rewind` to open the scrollable rewind menu
- Actions from rewind menu: restore code+conversation, restore conversation only, restore code only, summarize from here, or cancel
- Persists across sessions; cleaned up after 30 days (configurable)

**Limitations:** bash command changes not tracked (only file editing tool changes); external changes not tracked; not a replacement for git.

**Summarize vs restore:** "Summarize from here" compresses selected message forward into a summary without reverting files — like a targeted `/compact`. "Restore" options revert state.

### Context Window

**What loads at session start (before first prompt):**

| Item | Tokens (approx.) |
| :--- | :--- |
| System prompt | ~4,200 |
| Auto memory (MEMORY.md) | ~680 |
| Environment info | ~280 |
| MCP tool names (deferred) | ~120 |
| Skill descriptions | ~450 |
| `~/.claude/CLAUDE.md` | ~320 |
| Project CLAUDE.md | ~1,800 |

**What survives `/compact`:**

| Mechanism | After compaction |
| :--- | :--- |
| System prompt + output style | Unchanged |
| Project-root CLAUDE.md + unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | Lost until matching file read again |
| Nested CLAUDE.md in subdirectories | Lost until matching file read again |
| Invoked skill bodies | Re-injected, capped at 5K tokens/skill, 25K total |
| Hooks | Not applicable |

Run `/context` for live breakdown. Run `/memory` to see loaded CLAUDE.md and memory files.

### Output Styles

Built-in styles: `Default` (software engineering), `Explanatory` (educational insights), `Learning` (collaborative learn-by-doing with `TODO(human)` markers).

Change: `/config` → Output style, or set `outputStyle` in settings. Takes effect next session (system prompt stability).

**Custom output style frontmatter:**

| Field | Purpose | Default |
| :--- | :--- | :--- |
| `name` | Style name | File name |
| `description` | Shown in `/config` picker | None |
| `keep-coding-instructions` | Keep coding-specific system prompt | `false` |

Save at `~/.claude/output-styles/` (user) or `.claude/output-styles/` (project).

### Status Line

Configure a shell-script-based status bar via the `statusLine` setting. Script receives JSON on stdin, prints text to stdout.

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

Or use `/statusline show model name and context percentage` to auto-generate.

**Key JSON fields available to status line scripts:**

| Field | Description |
| :--- | :--- |
| `model.display_name` | Current model name |
| `workspace.current_dir` | Working directory |
| `context_window.used_percentage` | % of context used |
| `cost.total_cost_usd` | Estimated session cost |
| `cost.total_duration_ms` | Wall-clock time (ms) |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit % used |
| `rate_limits.seven_day.used_percentage` | 7-day rate limit % used |
| `effort.level` | Current effort level |
| `session_id` | Stable session identifier (use for caching) |
| `vim.mode` | Vim mode when enabled |
| `worktree.name` | Worktree name (when in `--worktree` session) |

### Voice Dictation

Enable: `/voice` (hold mode default) or `/voice tap` (tap-to-record-and-send).

| Command | Effect |
| :--- | :--- |
| `/voice` | Toggle on/off, keep current mode |
| `/voice hold` | Enable hold-to-record (push-to-talk with Space) |
| `/voice tap` | Enable tap-to-start/tap-to-send |
| `/voice off` | Disable |

- Requires Claude.ai account authentication (not API key/Bedrock/Vertex/Foundry)
- Transcription is cloud-based; not available in SSH or remote environments
- Language follows `language` setting; defaults to English
- Rebind key: `voice:pushToTalk` action in `~/.claude/keybindings.json`
- `"autoSubmit": true` in voice settings auto-sends on release (hold mode)

### Fullscreen Rendering

Enable: `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1`.

Benefits: eliminates flicker, flat memory in long conversations, mouse support, input box stays fixed at bottom.

**Key shortcuts in fullscreen mode:**

| Shortcut | Action |
| :--- | :--- |
| `PgUp` / `PgDn` | Scroll up/down half screen |
| `Ctrl+Home` / `Ctrl+End` | Jump to start / latest message |
| `Ctrl+O` | Toggle transcript mode (search with `/`) |
| `[` (in transcript mode) | Write conversation to terminal scrollback |
| `Ctrl+L` twice | Clear conversation (`/clear`) |

Disable mouse capture while keeping flicker-free rendering: `CLAUDE_CODE_DISABLE_MOUSE=1`.

### Remote Control

Start a session accessible from browser or mobile:

```bash
claude remote-control           # Server mode (waits for connections)
claude --remote-control         # Interactive + remote
# or inside a session:
/remote-control
```

- Requires Claude.ai subscription (Pro/Max/Team/Enterprise); not API keys
- Session runs locally; claude.ai/code or Claude mobile app is just a window into it
- Enables full local environment access: filesystem, MCP, tools, file path autocomplete with `@`
- Connects with QR code (press spacebar for QR in server mode) or session URL list

**Server mode flags:**

| Flag | Description |
| :--- | :--- |
| `--name "title"` | Custom session title |
| `--spawn <mode>` | `same-dir` (default), `worktree`, or `session` (single) |
| `--capacity <N>` | Max concurrent sessions (default 32) |
| `--sandbox` | Enable filesystem/network isolation |

Push notifications: install Claude mobile app, sign in with same account, enable in `/config` → "Push when Claude decides".

### Channels (Research Preview)

Push external events into a running Claude Code session via MCP servers.

Supported plugins (install via `/plugin install <name>@claude-plugins-official`):
- **Telegram**, **Discord**, **iMessage**, **fakechat** (localhost demo)

Enable per session: `claude --channels plugin:<name>@<marketplace>`

**Security:** sender allowlist (pair with `/telegram:access pair <code>` etc.), policy via allowlist. Being in `.mcp.json` is not enough — must also be named in `--channels`.

**Enterprise controls:**

| Setting | Effect |
| :--- | :--- |
| `channelsEnabled` | Master switch; off by default for Team/Enterprise |
| `allowedChannelPlugins` | Array of `{marketplace, plugin}` objects replacing Anthropic default list |

**Build a custom channel:** MCP server declaring `capabilities.experimental["claude/channel"]: {}`, emitting `notifications/claude/channel` notifications. Test with `--dangerously-load-development-channels server:<name>`.

### Routines (Research Preview)

Cloud-scheduled automation running on Anthropic infrastructure (not your machine).

Create at [claude.ai/code/routines](https://claude.ai/code/routines) or with `/schedule` in CLI.

**Trigger types:**

| Type | Description |
| :--- | :--- |
| Schedule | Recurring (hourly/daily/weekdays/weekly) or one-off timestamp |
| API | HTTP POST to per-routine endpoint with bearer token |
| GitHub | Pull request or release events, with optional filters |

**GitHub PR filters:** author, title, body, base branch, head branch, labels, is draft, is merged. Use `contains` for substring matching; `matches regex` tests full field value.

Fire a routine via API:
```bash
curl -X POST https://api.anthropic.com/v1/claude_code/routines/<id>/fire \
  -H "Authorization: Bearer <token>" \
  -H "anthropic-beta: experimental-cc-routine-2026-04-01" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"text": "optional context"}'
```

- Minimum schedule interval: 1 hour
- Daily cap on routine runs per account; one-off runs exempt from cap
- Routines run autonomously (no permission prompts)

### Scheduled Tasks (Session-Scoped `/loop`)

Run prompts on a recurring schedule within the current session.

| Command | Behavior |
| :--- | :--- |
| `/loop 5m check the deploy` | Fixed interval + prompt |
| `/loop check the deploy` | Claude chooses dynamic interval |
| `/loop` | Built-in maintenance prompt (continues PR work, CI, cleanup) |

- Tasks session-scoped; restored on `--resume`/`--continue` if within 7-day expiry
- Max 50 tasks per session
- One-shot reminder: describe in natural language ("remind me at 3pm to push the release branch")
- Stop a loop: press `Esc`; or ask Claude to cancel by name

**Cron reference:**

| Expression | Meaning |
| :--- | :--- |
| `*/5 * * * *` | Every 5 minutes |
| `0 * * * *` | Every hour |
| `0 9 * * *` | Daily at 9am local |
| `0 9 * * 1-5` | Weekdays at 9am local |

Disable entirely: `CLAUDE_CODE_DISABLE_CRON=1`.

### Desktop Scheduled Tasks

Local scheduled tasks that run while the Desktop app is open (not cloud).

Create: Desktop app → Routines → New routine → Local. Fields: name, description, instructions (includes permission mode + model picker), schedule, and working folder.

Schedule options: Manual, Hourly, Daily (9am default), Weekdays, Weekly. For custom intervals, ask Claude in a session.

- Missed runs: one catch-up run on wake for the most recent missed time (last 7 days)
- Each task has its own permission mode; stalls in Ask mode until you approve
- Edit prompt on disk: `~/.claude/scheduled-tasks/<task-name>/SKILL.md`

**Scheduling comparison:**

| | Cloud Routines | Desktop Tasks | `/loop` |
| :--- | :--- | :--- | :--- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Machine must be on | No | Yes | Yes |
| Session must be open | No | No | Yes |
| Minimum interval | 1 hour | 1 minute | 1 minute |
| Local file access | No (fresh clone) | Yes | Yes |

### Deep Links

Open Claude Code from a URL: `claude-cli://open?repo=owner/name&q=URL-encoded-prompt`

| Parameter | Description |
| :--- | :--- |
| `q` | Pre-fill prompt text (URL-encoded, max 5,000 chars) |
| `cwd` | Absolute working directory path |
| `repo` | GitHub `owner/name` slug (resolves to most-recently-used local clone) |

- `cwd` takes precedence over `repo` if both provided
- Handler auto-registered on first interactive session
- GitHub Markdown strips `claude-cli://` links (use a code block workaround)
- Disable registration: `disableDeepLinkRegistration: "disable"` in settings

**Open from shell:**
```bash
# macOS
open "claude-cli://open?repo=acme/payments&q=review%20open%20PRs"
# Linux
xdg-open "claude-cli://open?repo=acme/payments&q=review%20open%20PRs"
```

VS Code extension uses `vscode://anthropic.claude-code/open` instead.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code (Features Overview)](references/claude-code-features-overview.md) — when to use CLAUDE.md vs skills vs subagents vs MCP vs hooks vs plugins, feature layering, context costs
- [Model Configuration](references/claude-code-model-config.md) — model aliases, effort levels, extended context, opusplan, extended thinking, pin models for Bedrock/Vertex/Foundry, prompt caching config
- [Fast Mode](references/claude-code-fast-mode.md) — toggle, pricing, requirements, per-session opt-in, rate limit fallback
- [Checkpointing](references/claude-code-checkpointing.md) — automatic tracking, rewind menu, summarize vs restore, limitations
- [Explore the Context Window](references/claude-code-context-window.md) — interactive timeline, what loads at startup, what survives compaction
- [Output Styles](references/claude-code-output-styles.md) — built-in styles (Default, Explanatory, Learning), custom styles, frontmatter, comparison to CLAUDE.md and agents
- [Customize Your Status Line](references/claude-code-statusline.md) — setup, available JSON fields, examples in Bash/Python/Node, Windows config, subagent status lines
- [Voice Dictation](references/claude-code-voice-dictation.md) — hold and tap modes, language config, keybinding, requirements and troubleshooting
- [Fullscreen Rendering](references/claude-code-fullscreen.md) — enable, mouse support, scrolling shortcuts, transcript mode, tmux usage
- [Remote Control](references/claude-code-remote-control.md) — server mode, interactive mode, connecting from another device, push notifications, troubleshooting
- [Channels](references/claude-code-channels.md) — Telegram/Discord/iMessage setup, fakechat quickstart, security, enterprise controls
- [Channels Reference](references/claude-code-channels-reference.md) — build a custom channel: capability declaration, notification format, reply tools, sender gating, permission relay
- [Routines](references/claude-code-routines.md) — create routines, schedule/API/GitHub triggers, manage runs, usage limits
- [Run Prompts on a Schedule (/loop)](references/claude-code-scheduled-tasks.md) — /loop usage, fixed vs dynamic intervals, one-time reminders, cron reference
- [Desktop Scheduled Tasks](references/claude-code-desktop-scheduled-tasks.md) — local Desktop app scheduling, schedule options, missed runs, permissions
- [Deep Links](references/claude-code-deep-links.md) — URL format, parameters, registration, troubleshooting

## Sources

- Extend Claude Code (Features Overview): https://code.claude.com/docs/en/features-overview.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Explore the Context Window: https://code.claude.com/docs/en/context-window.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Customize Your Status Line: https://code.claude.com/docs/en/statusline.md
- Voice Dictation: https://code.claude.com/docs/en/voice-dictation.md
- Fullscreen Rendering: https://code.claude.com/docs/en/fullscreen.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels Reference: https://code.claude.com/docs/en/channels-reference.md
- Routines: https://code.claude.com/docs/en/routines.md
- Run Prompts on a Schedule (/loop): https://code.claude.com/docs/en/scheduled-tasks.md
- Desktop Scheduled Tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Deep Links: https://code.claude.com/docs/en/deep-links.md
