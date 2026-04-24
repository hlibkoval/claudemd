---
name: features-doc
description: Complete official documentation for Claude Code features — extension overview, model configuration, fast mode, output styles, checkpointing, context window, status line, voice dictation, fullscreen rendering, remote control, channels, scheduling options (session /loop, Desktop, cloud routines).
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features and extensions.

## Quick Reference

### Extension overview

| Feature | What it does | Loads |
| :--- | :--- | :--- |
| **CLAUDE.md** | Persistent context every session | Every session, automatically |
| **Skills** | Reusable knowledge and workflows | Descriptions at start; full content on demand |
| **MCP** | Connect Claude to external services | Tool names at start; schemas deferred |
| **Subagents** | Isolated workers returning summaries | On demand, fresh context |
| **Agent teams** | Independent sessions with shared tasks | Experimental; disabled by default |
| **Hooks** | Scripts/HTTP/LLM on lifecycle events | Fire at events; zero context cost |
| **Plugins** | Packaged bundles of the above | When plugin is enabled |

**When to add each:**

| Trigger | Add |
| :--- | :--- |
| Claude gets a convention wrong twice | CLAUDE.md |
| You keep typing the same prompt | User-invocable skill |
| Side task floods conversation | Subagent |
| Need something every time without asking | Hook |
| Second repo needs the same setup | Plugin |

### Model configuration

| Alias | Resolves to |
| :--- | :--- |
| `best` / `opus` | Latest Opus (Anthropic API: Opus 4.7) |
| `sonnet` | Latest Sonnet (Anthropic API: Sonnet 4.6) |
| `haiku` | Fast Haiku model |
| `opusplan` | Opus in plan mode, Sonnet in execution |
| `opus[1m]` / `sonnet[1m]` | 1M token context window variant |
| `default` | Clears override; reverts to account default |

**Default model by plan:** Max/Team Premium → Opus 4.7; Pro/Team Standard/Enterprise/API → Sonnet 4.6; Bedrock/Vertex/Foundry → Sonnet 4.5.

**Set model:** `/model <alias>` in session, `--model` at startup, `ANTHROPIC_MODEL` env var, or `model` field in settings.

**Effort levels** (Opus 4.7: `low`/`medium`/`high`/`xhigh`/`max`; Opus 4.6 & Sonnet 4.6: `low`/`medium`/`high`/`max`):

| Level | Use when |
| :--- | :--- |
| `low` | Short, latency-sensitive, not intelligence-sensitive |
| `medium` | Cost-sensitive, can trade some intelligence |
| `high` | Balanced; minimum for intelligence-sensitive work |
| `xhigh` | Best for most coding/agentic tasks (Opus 4.7 default) |
| `max` | Demanding tasks; session-only (or via env var) |

Set via `/effort`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL`, or `effortLevel` in settings.

**Key env vars for model control:**

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Override the `opus` alias |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Override the `sonnet` alias |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Override the `haiku` alias / background tasks |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching globally |

### Fast mode

Fast mode makes Opus 4.6 **2.5x faster** at higher cost. Not available for Opus 4.7 or other models.

| | |
| :--- | :--- |
| **Toggle** | `/fast` in session, or `"fastMode": true` in settings |
| **Pricing** | $30/$150 per MTok input/output (extra usage only) |
| **Indicator** | `↯` icon next to prompt |
| **Plans** | Pro/Max/Team/Enterprise via extra usage; not on Bedrock/Vertex/Foundry |
| **Enterprise** | Off by default; admin must enable at claude.ai/admin-settings/claude-code |
| **Per-session opt-in** | Set `"fastModePerSessionOptIn": true` in managed settings |
| **Rate limit fallback** | Auto-falls back to standard Opus 4.6; `↯` turns gray |

Best for: rapid iteration, live debugging. Use standard mode for long autonomous tasks or batch processing.

### Output styles

Output styles modify the system prompt to change Claude's role, tone, and format.

| Style | Effect |
| :--- | :--- |
| **Default** | Standard software engineering assistant |
| **Explanatory** | Adds educational "Insights" between tasks |
| **Learning** | Collaborative mode; adds `TODO(human)` markers for you to implement |
| **Custom** | Markdown file with frontmatter in `~/.claude/output-styles/` or `.claude/output-styles/` |

Set via `/config` → Output style, or `"outputStyle": "Explanatory"` in settings. Takes effect next session (keeps system prompt stable for caching).

**Custom style frontmatter fields:** `name`, `description`, `keep-coding-instructions` (default: false).

### Checkpointing

Automatic session-level undo for file edits made through Claude's tools.

| Action | How |
| :--- | :--- |
| Open rewind menu | Press `Esc` twice, or run `/rewind` |
| Restore code + conversation | Select from list, choose option |
| Summarize from a point | Compresses messages from that point forward |
| Session retention | 30 days (configurable) |

**Limitations:** bash command file changes are not tracked; external changes not tracked; not a replacement for git.

### Context window

**What loads at session start (before you type):** system prompt, auto memory (MEMORY.md), env info, MCP tool names (deferred schemas), skill descriptions, CLAUDE.md files.

**What survives compaction (`/compact`):**

| Mechanism | After compaction |
| :--- | :--- |
| System prompt / output style | Unchanged |
| Project-root CLAUDE.md / unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | Lost until matching file read again |
| Nested CLAUDE.md in subdirectories | Lost until matching file read again |
| Invoked skill bodies | Re-injected, capped at 5K tokens/skill, 25K total |
| Hooks | N/A — run as code, not context |

Run `/context` for live breakdown; `/memory` to check which CLAUDE.md and memory files loaded.

### Status line

A customizable bar at the bottom that runs a shell script receiving JSON session data on stdin.

**Setup:** `/statusline show model and context percentage` (auto-generates script), or add to `~/.claude/settings.json`:
```json
{"statusLine": {"type": "command", "command": "~/.claude/statusline.sh", "padding": 2}}
```

**Key JSON fields available:**

| Field | Description |
| :--- | :--- |
| `model.display_name` | Current model |
| `workspace.current_dir` | Working directory |
| `context_window.used_percentage` | Context usage % |
| `cost.total_cost_usd` | Estimated session cost |
| `cost.total_duration_ms` | Elapsed session time |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit usage (Pro/Max only) |
| `session_id` | Stable per-session ID (use for cache keys) |
| `vim.mode` | Vim mode when enabled |

Updates fire after each assistant message, permission mode change, or vim mode toggle (debounced 300ms). Use `refreshInterval` (seconds) for time-based data. Script runs locally, zero API tokens.

### Voice dictation

Speak prompts instead of typing. Audio streamed to Anthropic for transcription (not local).

| Command | Effect |
| :--- | :--- |
| `/voice` | Toggle on/off, keep current mode |
| `/voice hold` | Hold Space to record (default) |
| `/voice tap` | Tap Space to start, tap again to send |
| `/voice off` | Disable |

**Requirements:** Claude.ai account (no API key/Bedrock/Vertex/Foundry); local mic access; not available in SSH/web sessions. Settings: `{"voice": {"enabled": true, "mode": "tap"}}`.

**Rebind:** set `voice:pushToTalk` in `~/.claude/keybindings.json` (use modifier combos like `meta+k` for hold mode to avoid warmup).

**Languages:** 20 supported (cs, da, nl, en, fr, de, el, hi, id, it, ja, ko, no, pl, pt, ru, es, sv, tr, uk). Set via `language` setting.

### Fullscreen rendering

Eliminates flicker, flat memory in long sessions, adds mouse support. Uses terminal alternate screen buffer.

| | |
| :--- | :--- |
| **Enable** | `/tui fullscreen` in session, or `CLAUDE_CODE_NO_FLICKER=1` |
| **Disable** | `/tui default`, or unset env var |
| **Mouse actions** | Click input to position cursor; click collapsed tool results to expand; click-drag to select (auto-copies); scroll wheel |
| **Scroll shortcuts** | `PgUp`/`PgDn`, `Ctrl+Home` (top), `Ctrl+End` (bottom/resume auto-follow) |
| **Search** | `Ctrl+o` → transcript mode → `/` to search, `[` to write to scrollback |
| **Disable mouse only** | `CLAUDE_CODE_DISABLE_MOUSE=1` (keeps flicker-free rendering) |
| **Scroll speed** | `CLAUDE_CODE_SCROLL_SPEED=3` |

Not compatible with `tmux -CC` (iTerm2 integration mode). Enable `set -g mouse on` in tmux for wheel scrolling.

### Remote Control

Connect claude.ai/code or Claude mobile app to a local CLI session.

| Mode | Command |
| :--- | :--- |
| Server mode (persistent, multi-session) | `claude remote-control [--name "..."] [--spawn worktree]` |
| Interactive with remote enabled | `claude --remote-control` |
| From existing session | `/remote-control` or `/rc` |

**Connect from another device:** open the session URL, scan the QR code (press Space in server mode), or find it in the session list at claude.ai/code.

**Key flags for server mode:** `--spawn same-dir|worktree|session`, `--capacity N` (default 32), `--sandbox`.

**Push notifications:** requires Claude mobile app + same account + `/config` → Enable push notifications (v2.1.110+).

**Requirements:** Pro/Max/Team/Enterprise; claude.ai OAuth (no API key); v2.1.51+. Team/Enterprise: admin must enable at claude.ai/admin-settings/claude-code.

### Channels (research preview)

Push events from external systems (Telegram, Discord, iMessage, webhooks) into a running CLI session.

**Supported channels** (require Bun, install via `/plugin install <name>@claude-plugins-official`):

| Channel | Notes |
| :--- | :--- |
| Telegram | BotFather token; pair with `/telegram:access pair <code>` |
| Discord | Bot token + Message Content Intent; pair with `/discord:access pair <code>` |
| iMessage | macOS only; Full Disk Access required; self-messages bypass pairing |
| fakechat | localhost demo, no setup; `http://localhost:8787` |

**Start with channels:** `claude --channels plugin:<name>@claude-plugins-official`

**Security:** sender allowlist gates all inbound messages. Pair to add your ID, then `/telegram:access policy allowlist`.

**Enterprise controls:** `channelsEnabled` master switch; `allowedChannelPlugins` to restrict which plugins can register.

**Build your own channel:** MCP server with `capabilities.experimental['claude/channel']: {}`, emit `notifications/claude/channel` with `{content, meta}`. Two-way: add a `reply` tool. Permission relay: add `claude/channel/permission` capability.

### Scheduling options

Three ways to run prompts automatically:

| | Cloud (Routines) | Desktop tasks | Session `/loop` |
| :--- | :--- | :--- | :--- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Persistent | Yes | Yes | `--resume` if unexpired |
| Local file access | No (fresh clone) | Yes | Yes |
| Min interval | 1 hour | 1 minute | 1 minute |

**Session scheduling (`/loop`):**

| Usage | Effect |
| :--- | :--- |
| `/loop 5m check the deploy` | Fixed interval cron |
| `/loop check the deploy` | Claude chooses interval dynamically |
| `/loop` | Built-in maintenance prompt (PR tending, cleanup) |

One-time reminders: natural language, e.g. `remind me at 3pm to push the release branch`. Manage with `what scheduled tasks do I have?` / `cancel the deploy check job`. Max 50 tasks per session; 7-day expiry on recurring tasks.

**Desktop scheduled tasks:** Create via Schedule page in Desktop app → New task → New local task. Frequencies: Manual, Hourly, Daily, Weekdays, Weekly. Permission mode per task; missed runs get one catch-up on wake.

**Cloud Routines:** Create at claude.ai/code/routines or `/schedule`. Triggers: schedule (hourly/daily/weekdays/weekly/cron/one-off), API (POST to `/fire` endpoint with bearer token), GitHub events (PR, Release). Runs on cloud infrastructure autonomously.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code](references/claude-code-features-overview.md) — overview of all extension features with comparison tables and when to use each
- [Model configuration](references/claude-code-model-config.md) — model aliases, effort levels, extended context, env vars, third-party provider pinning
- [Fast mode](references/claude-code-fast-mode.md) — 2.5x faster Opus 4.6, pricing, toggle, rate limits, enterprise controls
- [Output styles](references/claude-code-output-styles.md) — built-in and custom styles, frontmatter, comparison with CLAUDE.md and agents
- [Checkpointing](references/claude-code-checkpointing.md) — automatic file edit tracking, rewind/summarize menu, limitations
- [Explore the context window](references/claude-code-context-window.md) — interactive simulation of context loading, compaction survival table
- [Status line](references/claude-code-statusline.md) — setup, all available JSON fields, Bash/Python/Node examples, subagent status line
- [Voice dictation](references/claude-code-voice-dictation.md) — hold/tap modes, language support, keybinding, troubleshooting
- [Fullscreen rendering](references/claude-code-fullscreen.md) — alternate screen buffer, mouse support, transcript mode, tmux notes
- [Remote Control](references/claude-code-remote-control.md) — server mode, interactive mode, VS Code, mobile push notifications, troubleshooting
- [Channels](references/claude-code-channels.md) — Telegram/Discord/iMessage setup, fakechat quickstart, security, enterprise controls
- [Channels reference](references/claude-code-channels-reference.md) — build your own channel: capability contract, notification format, reply tool, permission relay
- [Run prompts on a schedule](references/claude-code-scheduled-tasks.md) — `/loop`, CronCreate/List/Delete tools, jitter, 7-day expiry, cron syntax
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) — Desktop app local tasks, frequencies, missed runs, permissions
- [Automate work with routines](references/claude-code-routines.md) — cloud routines, schedule/API/GitHub triggers, connectors, usage limits

## Sources

- Extend Claude Code: https://code.claude.com/docs/en/features-overview.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Explore the context window: https://code.claude.com/docs/en/context-window.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Run prompts on a schedule: https://code.claude.com/docs/en/scheduled-tasks.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Automate work with routines: https://code.claude.com/docs/en/routines.md
