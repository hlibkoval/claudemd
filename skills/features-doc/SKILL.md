---
name: features-doc
description: Complete official documentation for Claude Code features — extension overview, model config, fast mode, output styles, status line, checkpointing, context window, remote control, voice dictation, channels, scheduled tasks, routines, desktop tasks, deep links, and fullscreen rendering.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features and extensions.

## Quick Reference

### Extension Overview: When to Use Each Feature

| Feature | What it does | When to use it |
| :--- | :--- | :--- |
| **CLAUDE.md** | Persistent context loaded every conversation | Project conventions, "always do X" rules |
| **Skill** | Instructions, knowledge, and workflows | Reusable content, reference docs, repeatable tasks |
| **Subagent** | Isolated worker with its own context | Context isolation, parallel tasks, large file reads |
| **Agent team** | Multiple independent Claude Code sessions | Parallel research, competing hypotheses, collaboration |
| **MCP** | Connect to external services | External data or actions |
| **Hook** | Script/HTTP/prompt triggered by events | Automation that must run on every matching event |
| **Plugin** | Packaging layer for all the above | Reuse across repos, distribute to others |

### Feature Loading: Context Cost

| Feature | When it loads | Context cost |
| :--- | :--- | :--- |
| **CLAUDE.md** | Session start | Every request (full content) |
| **Skills** | Session start (descriptions) + when used (full) | Low (descriptions only, until invoked) |
| **MCP servers** | Session start (tool names); schemas deferred | Low until a tool is used |
| **Subagents** | When spawned | Isolated from main session |
| **Hooks** | On trigger (runs externally) | Zero unless hook returns output |

What survives `/compact`:

| Mechanism | After compaction |
| :--- | :--- |
| System prompt and output style | Unchanged |
| Project-root CLAUDE.md and unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | Lost until matching file is read again |
| Invoked skill bodies | Re-injected, capped at 5,000 tokens/skill, 25,000 total |
| Hooks | Not applicable (run as code, not context) |

### Model Configuration

**Model aliases:**

| Alias | Behavior |
| :--- | :--- |
| `default` | Clears override; uses recommended model for account type |
| `best` | Most capable model (currently `opus`) |
| `sonnet` | Latest Sonnet for daily coding tasks |
| `opus` | Latest Opus for complex reasoning |
| `haiku` | Fast and efficient for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus in plan mode, Sonnet in execution mode |

**Setting priority:** `/model` in session > `--model` at startup > `ANTHROPIC_MODEL` env > `model` in settings file.

**Effort levels** (supported on Opus 4.7, Opus 4.6, Sonnet 4.6):

| Level | When to use |
| :--- | :--- |
| `low` | Latency-sensitive, non-intelligence-sensitive tasks |
| `medium` | Cost-sensitive work willing to trade some intelligence |
| `high` | Intelligence-sensitive work, minimum for complex tasks |
| `xhigh` | Best results for most coding and agentic tasks (default on Opus 4.7) |
| `max` | Demanding tasks; may show diminishing returns |

Set with `/effort`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL` env, or `effortLevel` in settings. Use `ultrathink` in a prompt for one-off deep reasoning without changing session effort.

**Key model env vars:**

| Variable | Effect |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Pins the `opus` alias to a specific model |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Pins the `sonnet` alias |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Pins the `haiku` alias / background model |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model used for subagents |
| `CLAUDE_CODE_DISABLE_1M_CONTEXT=1` | Disables 1M context window variants |

**Extended context (1M tokens):** Auto-upgraded for Opus on Max/Team/Enterprise. Pro requires extra usage. Use `[1m]` suffix with aliases (`opus[1m]`) or append to model IDs.

### Fast Mode

Fast mode makes Opus 4.6 approximately 2.5x faster at higher cost ($30/$150 per MTok input/output).

- Toggle: `/fast` command or `"fastMode": true` in user settings
- Visual indicator: `↯` icon next to prompt when active
- Requires: extra usage enabled, not available on Bedrock/Vertex/Foundry
- Rate limit fallback: auto-reverts to standard Opus 4.6, `↯` turns gray
- Per-session opt-in (admin): set `"fastModePerSessionOptIn": true` in managed settings
- Disable entirely: `CLAUDE_CODE_DISABLE_FAST_MODE=1`

### Output Styles

Output styles modify the system prompt to change tone and format, not capabilities.

**Built-in styles:**
- `Default` — standard software engineering assistant
- `Explanatory` — adds "Insights" between tasks to teach codebase patterns
- `Learning` — collaborative mode with `TODO(human)` markers for hands-on learning

**Custom styles:** Markdown files in `~/.claude/output-styles/` or `.claude/output-styles/`.

| Frontmatter | Purpose | Default |
| :--- | :--- | :--- |
| `name` | Style name | Filename |
| `description` | Shown in `/config` picker | None |
| `keep-coding-instructions` | Keep coding-related system prompt parts | false |

Change with `/config` → Output style, or set `outputStyle` in settings. Changes take effect next session.

**vs CLAUDE.md:** Output styles replace coding instructions; CLAUDE.md appends as a user message. **vs agents:** Output styles only affect system prompt; agents have their own model/tools. **vs skills:** Output styles are always-on formatting; skills are on-demand workflows.

### Status Line

A customizable bar at the bottom of the CLI that runs any shell script and displays its output.

**Configuration in settings.json:**
```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2,
    "refreshInterval": 30,
    "hideVimModeIndicator": false
  }
}
```

Or use `/statusline <description>` and Claude generates the script automatically.

**Available JSON fields (piped to script via stdin):**

| Field | Description |
| :--- | :--- |
| `model.id`, `model.display_name` | Current model |
| `workspace.current_dir`, `workspace.project_dir` | Directories |
| `workspace.added_dirs` | Dirs added via `/add-dir` |
| `context_window.used_percentage` | Context usage % |
| `context_window.context_window_size` | Max tokens (200K or 1M) |
| `cost.total_cost_usd` | Estimated session cost |
| `cost.total_duration_ms` | Wall-clock time ms |
| `effort.level` | Current reasoning effort |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit % (Pro/Max) |
| `rate_limits.seven_day.used_percentage` | 7-day rate limit % (Pro/Max) |
| `session_id`, `session_name` | Session identifiers |
| `vim.mode` | Vim mode (`NORMAL`, `INSERT`, etc.) |
| `worktree.name`, `worktree.branch` | Worktree info (--worktree sessions) |

Updates after each assistant message and after `/compact`. `disableAllHooks: true` also disables the status line.

**Subagent status line:** `subagentStatusLine` setting renders custom rows in the agent panel. Command receives all subagent tasks as JSON with an `id`/`content` output format.

### Checkpointing

Claude Code automatically captures code state before each file edit.

- Every user prompt creates a new checkpoint
- Checkpoints persist across sessions (cleaned up after 30 days)
- Open rewind menu: press `Esc` twice, or use `/rewind`

**Rewind actions:**
- **Restore code and conversation** — reverts both
- **Restore conversation** — rewinds conversation, keeps current code
- **Restore code** — reverts files, keeps conversation
- **Summarize from here** — compresses conversation from selected point forward (like targeted `/compact`)
- **Never mind** — cancel

**Limitations:** Bash command file modifications (rm, mv, cp) are not tracked. Only files edited via Claude's file editing tools are tracked. Not a replacement for git.

### Remote Control

Continue a local Claude Code session from any device via claude.ai/code or the Claude mobile app.

**Start modes:**

| Command | Effect |
| :--- | :--- |
| `claude remote-control` | Server mode — waits for connections, shows session URL/QR |
| `claude --remote-control` (or `--rc`) | Interactive session with remote access enabled |
| `/remote-control` (or `/rc`) in session | Adds remote access to existing session |

**Server mode flags:** `--name`, `--spawn [same-dir\|worktree\|session]`, `--capacity N`, `--verbose`, `--sandbox`.

**Connect from another device:** Open session URL, scan QR code (press spacebar to show), or find session by name in claude.ai/code or Claude mobile app → Code tab.

**Enable for all sessions:** `/config` → Enable Remote Control for all sessions.

**Security:** Outbound HTTPS only, no inbound ports. Multiple short-lived scoped credentials over TLS.

**Requirements:** Pro/Max/Team/Enterprise (not API keys). Team/Enterprise requires admin enablement at claude.ai/admin-settings/claude-code.

**Mobile push notifications:** Requires Claude Code v2.1.110+, Claude mobile app signed in with same account, `/config` → Push when Claude decides.

### Voice Dictation

Speak prompts instead of typing. Transcription is streamed live into the prompt input.

| Command | Effect |
| :--- | :--- |
| `/voice` | Toggle on/off, keep current mode |
| `/voice hold` | Enable hold-to-record mode (default) |
| `/voice tap` | Enable tap-to-record-and-send mode |
| `/voice off` | Disable |

**Hold mode:** Hold `Space` to record; release to finalize. Brief warmup period before recording activates.

**Tap mode:** Tap `Space` to start, speak, tap again to send (auto-submits if ≥3 words). Requires Claude Code v2.1.116+.

**Settings:**
```json
{
  "voice": {
    "enabled": true,
    "mode": "tap",
    "autoSubmit": true
  }
}
```

**Rebind dictation key:** `voice:pushToTalk` in `~/.claude/keybindings.json` (`Chat` context). Defaults to `Space`.

**Language:** Uses `language` setting. Defaults to English. Supported: cs, da, nl, en, fr, de, el, hi, id, it, ja, ko, no, pl, pt, ru, es, sv, tr, uk.

**Requirements:** Claude.ai account (not API key/Bedrock/Vertex). Local microphone access required (not SSH, not web). Linux fallback: `arecord` (ALSA) or `rec` (SoX).

### Channels (Research Preview)

Push events from external systems (Telegram, Discord, iMessage, webhooks) into a running Claude Code session.

**Start with channels:**
```bash
claude --channels plugin:telegram@claude-plugins-official
```

**Supported channels:** Telegram, Discord, iMessage, fakechat (localhost demo). All require [Bun](https://bun.sh).

**Setup flow:** Install plugin → Configure credentials → Restart with `--channels` → Pair account.

**Security:** Sender allowlist per channel. Pair via bot, then run `/<channel>:access policy allowlist`.

**Enterprise controls:**

| Setting | Purpose |
| :--- | :--- |
| `channelsEnabled` | Master switch (must be true for channels to deliver messages) |
| `allowedChannelPlugins` | Restrict which plugins can register as channels |

**Team/Enterprise:** Channels blocked by default until admin enables them at claude.ai/admin-settings/claude-code → Channels.

**Build a custom channel:** Implement an MCP server that declares `claude/channel` capability and emits `notifications/claude/channel` events. See channels-reference for full protocol.

### Scheduled Tasks (`/loop`)

Run prompts on a recurring schedule within a session.

| Invocation | Effect |
| :--- | :--- |
| `/loop 5m check the deploy` | Fixed schedule, your prompt |
| `/loop check the deploy` | Claude chooses interval dynamically |
| `/loop` | Built-in maintenance prompt (PR triage, cleanup) |
| `/loop 15m` | Built-in maintenance prompt on fixed schedule |

**Intervals:** `s`, `m`, `h`, `d` units. Cron has 1-minute granularity. Non-clean steps rounded to nearest.

**Custom default prompt:** Create `.claude/loop.md` (project) or `~/.claude/loop.md` (user).

**One-time reminders:** Natural language, e.g. `remind me at 3pm to push the release branch`.

**Tools under the hood:** `CronCreate`, `CronList`, `CronDelete`. Max 50 tasks per session.

**Jitter:** Recurring tasks fire up to 30 min after scheduled time. One-shot: up to 90s early.

**7-day expiry:** Recurring tasks auto-expire and delete. Restored on `--resume`/`--continue` if unexpired.

**Disable:** `CLAUDE_CODE_DISABLE_CRON=1`.

### Scheduling Options Comparison

|  | Cloud Routines | Desktop Scheduled Tasks | `/loop` |
| :--- | :--- | :--- | :--- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Persistent | Yes | Yes | Restored on `--resume` if unexpired |
| Local files | No (fresh clone) | Yes | Yes |
| Min interval | 1 hour | 1 minute | 1 minute |

### Routines (Cloud, Research Preview)

Saved Claude Code configurations that run on Anthropic-managed cloud infrastructure.

**Trigger types:**
- **Scheduled:** Hourly/daily/weekdays/weekly (presets) or custom cron. Min 1 hour. One-off also supported.
- **API:** POST to per-routine endpoint with bearer token. Returns session ID and URL.
- **GitHub:** Reacts to PR or Release events with optional filters (author, title, labels, draft status, etc.)

**Create:** claude.ai/code/routines, Desktop app → Routines → New routine → Remote, or `/schedule` in CLI.

**CLI commands:** `/schedule`, `/schedule list`, `/schedule update`, `/schedule run`.

**API trigger example:**
```bash
curl -X POST https://api.anthropic.com/v1/claude_code/routines/<id>/fire \
  -H "Authorization: Bearer <token>" \
  -H "anthropic-beta: experimental-cc-routine-2026-04-01" \
  -d '{"text": "Alert details here"}'
```

**GitHub event filters:** Author, title, body, base branch, head branch, labels, is draft, is merged. Regex operator tests full field value; use `.*term.*` for substring match.

**Permissions:** By default, Claude only pushes to `claude/`-prefixed branches. Enable "Allow unrestricted branch pushes" per repo to override.

**Routines are personal** — not shared with teammates, count against account's daily run allowance.

### Desktop Scheduled Tasks

Local scheduled tasks in the Claude Code Desktop app. Run on your machine with local file access.

**Create:** Desktop app → Routines → New routine → Local (vs Remote for cloud routines).

**Schedule options:** Manual, Hourly, Daily (+ time picker), Weekdays, Weekly (+ time + day), or custom via natural language.

**Runs:** Desktop checks every minute while app is open. Deterministic stagger delay per task. Desktop notification + new session in Sidebar → Scheduled.

**Missed runs:** On wake, runs one catch-up for most recently missed time. Older misses discarded.

**Permission mode:** Set per task. Click "Run now" after creating to pre-approve tools.

**Edit task file:** `~/.claude/scheduled-tasks/<task-name>/SKILL.md` (YAML frontmatter + body prompt).

### Deep Links

`claude-cli://` URLs that open Claude Code in a terminal with a pre-filled prompt.

**URL format:**
```
claude-cli://open?repo=owner/name&q=URL-encoded+prompt+text
claude-cli://open?cwd=/absolute/path&q=prompt
```

| Parameter | Description |
| :--- | :--- |
| `q` | URL-encoded prompt text (max 5,000 chars, `%0A` for newlines) |
| `cwd` | Absolute working directory path |
| `repo` | GitHub `owner/name` slug (resolves to most recently used local clone) |

**Registration:** Auto-registered on first interactive session. Locations:
- macOS: `~/Applications/Claude Code URL Handler.app`
- Linux: `~/.local/share/applications/claude-code-url-handler.desktop`
- Windows: `HKEY_CURRENT_USER\Software\Classes\claude-cli`

**Open from shell:** `open "claude-cli://..."` (macOS), `xdg-open "..."` (Linux), `Start-Process "..."` (PowerShell).

**Note:** GitHub-rendered Markdown strips `claude-cli://` scheme — links appear as plain text. Use code blocks as workaround.

**Disable:** Set `disableDeepLinkRegistration: "disable"` in settings.

**VS Code variant:** `vscode://anthropic.claude-code/open` opens a VS Code tab instead.

### Fullscreen Rendering (Research Preview)

Alternative rendering mode using the terminal's alternate screen buffer, like `vim` or `htop`.

**Benefits:** Eliminates flicker, flat memory usage in long conversations, adds mouse support.

**Enable:** `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1`.

**Disable:** `/tui default` or `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1`.

**Mouse support:**
- Click in prompt to position cursor
- Click collapsed tool result to expand
- Click URL/file path to open
- Click-drag to select (copies to clipboard on release)
- Scroll with mouse wheel

**Disable mouse only:** `CLAUDE_CODE_DISABLE_MOUSE=1` (keeps flicker-free rendering).

**Search/review:** `Ctrl+o` for transcript mode → `/` to search, `[` to write to scrollback, `v` to open in `$EDITOR`.

**Scroll shortcuts:**

| Shortcut | Action |
| :--- | :--- |
| `PgUp` / `PgDn` | Scroll half screen |
| `Ctrl+Home` | Jump to start |
| `Ctrl+End` | Jump to latest (resume auto-follow) |

**tmux:** Requires `set -g mouse on` in `~/.tmux.conf`. Incompatible with `tmux -CC` (iTerm2 integration mode).

**Scroll speed:** `CLAUDE_CODE_SCROLL_SPEED=3` (1-20, multiplier).

**Focus mode:** `/focus` shows only last prompt, one-line tool summaries, and final response.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code (features overview)](references/claude-code-features-overview.md) — when to use CLAUDE.md, skills, subagents, agent teams, MCP, hooks, and plugins; context cost comparison; feature layering
- [Model configuration](references/claude-code-model-config.md) — model aliases, effort levels, extended context, opusplan, extended thinking, pin models for third-party providers, prompt caching config
- [Fast mode](references/claude-code-fast-mode.md) — toggle, cost tradeoff, requirements, per-session opt-in, rate limit fallback
- [Output styles](references/claude-code-output-styles.md) — built-in styles (Default/Explanatory/Learning), creating custom styles, frontmatter reference
- [Customize your status line](references/claude-code-statusline.md) — setup, available JSON data fields, examples (context bar, git status, cost tracking, rate limits, clickable links, caching), subagent status line
- [Checkpointing](references/claude-code-checkpointing.md) — automatic tracking, rewind menu, restore vs summarize, limitations
- [Explore the context window](references/claude-code-context-window.md) — interactive simulation reference, what loads at startup, what survives compaction
- [Remote Control](references/claude-code-remote-control.md) — server mode, interactive session mode, mobile push notifications, troubleshooting, comparison with web sessions
- [Voice dictation](references/claude-code-voice-dictation.md) — hold mode, tap mode, language settings, rebinding the dictation key, troubleshooting
- [Channels](references/claude-code-channels.md) — Telegram/Discord/iMessage setup, fakechat quickstart, security allowlists, enterprise controls
- [Channels reference](references/claude-code-channels-reference.md) — build a custom channel: capability declaration, notification format, reply tools, sender gating, permission relay
- [Scheduled tasks (/loop)](references/claude-code-scheduled-tasks.md) — fixed vs dynamic intervals, built-in maintenance prompt, loop.md customization, one-time reminders, cron reference
- [Routines (cloud)](references/claude-code-routines.md) — create from web/CLI, schedule/API/GitHub triggers, branch permissions, connectors, usage limits
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) — create in Desktop app, schedule options, missed run handling, permission modes, task file editing
- [Deep links](references/claude-code-deep-links.md) — URL format, `cwd` vs `repo` params, registration per platform, shell invocation, troubleshooting
- [Fullscreen rendering](references/claude-code-fullscreen.md) — enable/disable, mouse support, scroll shortcuts, transcript mode search, tmux usage

## Sources

- Extend Claude Code (features overview): https://code.claude.com/docs/en/features-overview.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Customize your status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Explore the context window: https://code.claude.com/docs/en/context-window.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Explore the context window: https://code.claude.com/docs/en/context-window.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
- Routines: https://code.claude.com/docs/en/routines.md
- Scheduled tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Deep links: https://code.claude.com/docs/en/deep-links.md
