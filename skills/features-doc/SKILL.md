---
name: features-doc
user-invocable: false
---

# Claude Code Features Documentation

This skill provides the complete official documentation for Claude Code's productivity and configuration features, including model settings, fast mode, output styles, status line, checkpointing, remote control, scheduled tasks, voice dictation, channels, prompt caching, context window, worktrees, and routines.

## Quick Reference

### Features Overview: Extension Layer at a Glance

| Feature | What it does | When to use |
|:--------|:-------------|:------------|
| **CLAUDE.md** | Persistent context loaded every session | Project conventions, "always do X" rules |
| **Skills** | Reusable knowledge and invocable workflows | Reference docs, repeatable tasks, `/command` workflows |
| **Subagents** | Isolated workers returning summaries | Context isolation, parallel tasks |
| **Agent teams** | Coordinate multiple independent sessions | Parallel research, competing hypotheses |
| **MCP** | Connect to external services | Databases, Slack, browser control |
| **Hooks** | Scripts triggered by lifecycle events | Automation that fires on every matching event |
| **Plugins** | Package and distribute feature sets | Reuse setup across repos, share with others |

Context costs: CLAUDE.md loads full content every request; skills load descriptions at start, full content on use; MCP tools load names at start, schemas on demand; hooks cost zero unless they return output.

### Model Configuration (`/model`)

| Alias | Resolves to |
|:------|:------------|
| `default` | Clears override, reverts to recommended model for account type |
| `best` | Most capable available (currently `opus`) |
| `sonnet` | Latest Sonnet for daily coding tasks |
| `opus` | Latest Opus for complex reasoning |
| `haiku` | Fast and efficient for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus during plan mode, switches to Sonnet for execution |

**Setting priority (highest to lowest):** `/model` during session → `--model` flag → `ANTHROPIC_MODEL` env var → `model` in settings file.

As of v2.1.144, `/model` applies to the current session only. Press `d` in the picker to save as default.

**Default model by account type:**

| Plan | Default |
|:-----|:--------|
| Max / Team Premium | Opus 4.7 |
| Pro, Team Standard, Enterprise, API | Sonnet 4.6 |
| Bedrock, Vertex, Foundry | Sonnet 4.5 |

### Effort Levels (`/effort`)

| Level | When to use |
|:------|:------------|
| `low` | Short, scoped, latency-sensitive tasks |
| `medium` | Cost-sensitive work trading off some quality |
| `high` | Balanced; minimum for intelligence-sensitive work |
| `xhigh` | Best results for most coding and agentic tasks (Opus 4.7 default) |
| `max` | Deep reasoning, current session only |

Supported on Opus 4.7, Opus 4.6, Sonnet 4.6. Include `ultrathink` in a prompt for one-off deep reasoning without changing the session effort level.

### Fast Mode (`/fast`)

- Makes Opus **2.5x faster** at higher per-token cost
- Pricing: $30/$150 per MTok input/output (flat across full 1M token context)
- Toggle: `/fast` or set `"fastMode": true` in settings
- Indicator: `↯` icon in prompt when active
- Available on Opus 4.7 and Opus 4.6 only; not on Sonnet/Haiku
- Requires usage credits; not available on Bedrock, Vertex AI, or Azure Foundry
- Falls back to standard speed automatically when rate limit or credits hit
- Admin setting `fastModePerSessionOptIn: true` resets fast mode at each new session

### Extended Context (1M tokens)

| Plan | Opus 1M | Sonnet 1M |
|:-----|:--------|:----------|
| Max, Team, Enterprise | Included | Requires usage credits |
| Pro | Requires usage credits | Requires usage credits |
| API / pay-as-you-go | Full access | Full access |

Use `[1m]` suffix: `/model opus[1m]`, `/model sonnet[1m]`, or append to full model name.

### Output Styles (`/config` → Output style)

| Style | Description |
|:------|:------------|
| **Default** | Standard software engineering system prompt |
| **Proactive** | Execute immediately, minimal confirmation pauses |
| **Explanatory** | Add educational "Insights" while coding |
| **Learning** | Collaborative mode with `TODO(human)` markers for your contribution |

Custom styles: Markdown file in `~/.claude/output-styles/` (user), `.claude/output-styles/` (project), or managed policy directory. Key frontmatter fields:

| Field | Purpose | Default |
|:------|:--------|:--------|
| `name` | Style name if different from filename | Filename |
| `description` | Shown in `/config` picker | None |
| `keep-coding-instructions` | Keep built-in software engineering instructions | `false` |
| `force-for-plugin` | Auto-apply this style when plugin is enabled | `false` |

Output style is part of the system prompt; changes take effect after `/clear` or new session.

### Status Line Configuration

Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2,
    "refreshInterval": 30
  }
}
```

Or use `/statusline <description>` to have Claude generate a script automatically.

Key JSON fields available to status line scripts (received via stdin):

| Field | Description |
|:------|:------------|
| `model.display_name` | Current model name |
| `workspace.current_dir` | Current working directory |
| `workspace.repo.host/owner/name` | Git remote identity |
| `context_window.used_percentage` | Context window usage % |
| `context_window.context_window_size` | Max context (200000 or 1000000) |
| `cost.total_cost_usd` | Estimated session cost |
| `cost.total_duration_ms` | Total wall-clock time (ms) |
| `effort.level` | Current reasoning effort level |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit usage % |
| `rate_limits.seven_day.used_percentage` | 7-day rate limit usage % |
| `pr.number`, `pr.url`, `pr.review_state` | Open PR for current branch |
| `vim.mode` | Vim mode when vim mode is enabled |
| `session_id`, `session_name` | Session identity |

Subagent status line: use `subagentStatusLine` setting. Script receives all subagent rows as JSON on stdin; emit one JSON line per row: `{"id": "<task id>", "content": "<row body>"}`.

Updates fire after each assistant message, after `/compact`, on permission mode change, or vim mode toggle. Use `refreshInterval` (min: 1 second) for time-based or idle updates.

### Checkpointing and Rewind

Every user prompt creates a checkpoint. Access via `/rewind` or double-`Esc` (when input is empty).

| Rewind action | What it does |
|:-------------|:-------------|
| **Restore code and conversation** | Revert both code and conversation to selected point |
| **Restore conversation** | Rewind conversation, keep current code |
| **Restore code** | Revert file changes, keep conversation |
| **Summarize from here** | Compress conversation from selected point forward |
| **Summarize up to here** | Compress conversation before selected point |

Limitations: only tracks edits made through Claude's file tools (not Bash commands), persists 30 days, not a replacement for git version control.

### Remote Control

Continue a local session from phone, tablet, or any browser.

**Start options:**

| Method | How |
|:-------|:----|
| Server mode | `claude remote-control` |
| Interactive session | `claude --remote-control` or `claude --rc` |
| From existing session | `/remote-control` or `/rc` |
| VS Code | `/remote-control` in prompt box |

Key `claude remote-control` flags: `--name`, `--spawn same-dir|worktree|session`, `--capacity <N>`, `--verbose`, `--sandbox`.

To enable for all sessions: `/config` → "Enable Remote Control for all sessions".

**Requirements:** Pro/Max/Team/Enterprise plans; claude.ai OAuth (not API key); Team/Enterprise needs admin to enable toggle at claude.ai admin settings.

### Scheduled Tasks

Three scheduling approaches:

| Option | Runs on | Requires open session | Minimum interval |
|:-------|:--------|:---------------------|:-----------------|
| `/loop` in session | Your machine | Yes | 1 minute |
| Desktop scheduled tasks | Your machine | No | 1 minute |
| Routines (cloud) | Anthropic cloud | No | 1 hour |

**`/loop` command:**

| Invocation | Behavior |
|:-----------|:---------|
| `/loop 5m check the deploy` | Fixed-interval prompt |
| `/loop check the deploy` | Claude chooses interval dynamically |
| `/loop` | Built-in maintenance prompt at dynamic interval |

Tasks are session-scoped (survive `--resume` if unexpired). Max 50 tasks per session. Recurring tasks expire 7 days after creation. Disable with `CLAUDE_CODE_DISABLE_CRON=1`.

**Cron expression syntax (5-field):** `minute hour day-of-month month day-of-week`. Standard wildcards, ranges, steps, and comma lists supported.

**Desktop scheduled tasks:** Create via Routines sidebar → New routine → Local. Supports Manual, Hourly, Daily, Weekdays, Weekly schedules. Missed runs: one catch-up run on wake for most recently missed time. Tasks self-modify via `update_scheduled_task` MCP tool.

**Routines (cloud):** Create at claude.ai/code/routines or via `/schedule`. Triggers: schedule (hourly/daily/weekdays/weekly or cron), API (POST to per-routine endpoint with bearer token), GitHub events (pull_request or release). One-off runs don't count against daily cap.

### Voice Dictation (`/voice`)

| Command | Effect |
|:--------|:-------|
| `/voice` | Toggle on/off, keep current mode |
| `/voice hold` | Enable hold-to-record mode |
| `/voice tap` | Enable tap-to-record-and-send mode |
| `/voice off` | Disable |

- Streams audio to Anthropic servers; requires claude.ai account (not API key)
- Not available in remote/SSH/web sessions
- Language set via `language` setting in `/config` or settings file
- Rebind key via `voice:pushToTalk` action in `~/.claude/keybindings.json` (default: Space)
- Settings persistence: `{ "voice": { "enabled": true, "mode": "tap" } }`
- Hold mode: warmup delay before recording; use modifier key (e.g., `meta+k`) to skip warmup
- Tap mode: tap to start, tap again to send (auto-submits if 3+ words)

### Channels

Push events from Telegram, Discord, iMessage, or custom webhooks into a running session.

**Quick start:** `claude --channels plugin:fakechat@claude-plugins-official`

Supported out of the box: Telegram, Discord, iMessage (macOS only), fakechat (localhost demo).

Setup pattern for each: install plugin → configure token → restart with `--channels plugin:<name>@claude-plugins-official` → pair account.

Enterprise controls: `channelsEnabled` (master switch) and `allowedChannelPlugins` in managed settings. Pro/Max users skip org checks.

**Custom channel server (MCP):** Declare `capabilities.experimental['claude/channel']: {}` in the MCP `Server` constructor. Emit `notifications/claude/channel` events with `{ content, meta }` params. Optionally expose a reply tool (`capabilities.tools: {}`) for two-way communication. Add `capabilities.experimental['claude/channel/permission']: {}` for permission relay (forward tool approval prompts to remote channel).

**Notification format:** `content` becomes body of `<channel>` tag; each `meta` key becomes a tag attribute. Events arrive as: `<channel source="server-name" key="val">content</channel>`.

Test custom channels with `--dangerously-load-development-channels server:<name>`.

### Prompt Caching

Cache is organized by layer (stable → changing):

| Layer | Content | Invalidated by |
|:------|:--------|:---------------|
| System prompt | Core instructions, tool definitions, output style | MCP connect/disconnect, upgrade |
| Project context | CLAUDE.md, auto memory, unscoped rules | Session start, `/clear`, `/compact` |
| Conversation | Messages, tool results | Every turn |

**Actions that invalidate the cache:** switching models, changing effort level, MCP server connect/disconnect, denying an entire tool (bare `Bash` or `Bash(*)`), `/compact`, Claude Code upgrade.

**Actions that keep the cache:** editing repo files, editing CLAUDE.md mid-session (change takes effect on restart), changing output style mid-session (takes effect on restart), changing permission mode (except `opusplan` plan-mode toggle), invoking skills/commands, `/recap`, `/rewind`.

**TTL:** Claude subscription → 1-hour TTL automatic; API key/Bedrock/Vertex → 5-minute TTL (opt into 1h with `ENABLE_PROMPT_CACHING_1H=1`). Force 5-minute with `FORCE_PROMPT_CACHING_5M=1`.

**Cache performance tokens:** `cache_creation_input_tokens` (written to cache), `cache_read_input_tokens` (served from cache at ~10% standard input rate).

**Disable:** `DISABLE_PROMPT_CACHING=1` (all), or `DISABLE_PROMPT_CACHING_HAIKU/SONNET/OPUS=1`.

### Context Window and What Survives Compaction

What loads at startup (before first prompt): system prompt, auto memory (MEMORY.md), environment info, MCP tool names (schemas deferred), skill descriptions, CLAUDE.md files.

| Mechanism | After `/compact` |
|:----------|:----------------|
| System prompt and output style | Unchanged (not in message history) |
| Project-root CLAUDE.md and unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | Lost until matching file is re-read |
| Nested CLAUDE.md in subdirectories | Lost until file in that dir is re-read |
| Invoked skill bodies | Re-injected (capped 5K/skill, 25K total; oldest dropped first) |
| Hooks | Not applicable (run as code, not context) |

Check live context: `/context`. Check loaded CLAUDE.md: `/memory`.

### Worktrees (`--worktree`)

Run parallel isolated sessions in separate git working directories.

```bash
claude --worktree feature-auth   # creates .claude/worktrees/feature-auth/ on branch worktree-feature-auth
claude --worktree "#1234"         # branches from PR #1234
claude --worktree                 # auto-generated name
```

Settings for base branch: `worktree.baseRef: "fresh"` (default, branches from `origin/HEAD`) or `"head"` (branches from local HEAD, carries unpushed commits).

Copy gitignored files (e.g., `.env`) into new worktrees: add `.worktreeinclude` file with `.gitignore` syntax patterns at project root. Only files that match AND are gitignored are copied.

Subagent isolation: ask Claude to "use worktrees for your agents", or set `isolation: worktree` in custom subagent frontmatter.

Cleanup on exit: auto-removes worktree if no changes; prompts to keep or remove if changes exist. Non-interactive (`-p`) runs: clean up manually with `git worktree remove`.

Non-git VCS: configure `WorktreeCreate` and `WorktreeRemove` hooks.

### Prompt Library

The prompt library at the features-overview doc provides copy-paste prompts organized by SDLC phase (Discover, Design, Build, Ship, Operate) and role (dev, PM, design, docs, marketing, security, ops). Key patterns that make prompts effective:

- Describe the outcome, not the steps
- Give Claude a way to self-verify (`run it`, `compare it`, `confirm it`)
- Point at an existing reference for consistency
- State a measurable target for performance/coverage goals
- Give the artifact directly (paste errors, logs, screenshots, or use `@file`)
- Say how you want the answer (format, length, audience)

## Full Documentation

For the complete official documentation, see the reference files:

- [Features Overview](references/claude-code-features-overview.md) — Extension layer guide: CLAUDE.md vs skills vs MCP vs subagents vs hooks vs plugins, context costs, and how features layer
- [Model Configuration](references/claude-code-model-config.md) — Model aliases, `/model` picker, effort levels, extended thinking, 1M context, third-party deployment pinning, prompt caching config
- [Fast Mode](references/claude-code-fast-mode.md) — Speed up Opus 2.5x with `/fast`, pricing, rate limits, per-session opt-in
- [Output Styles](references/claude-code-output-styles.md) — Built-in styles, creating custom styles, frontmatter reference, how styles modify the system prompt
- [Status Line](references/claude-code-statusline.md) — Shell-script status bar with full JSON schema, example scripts (context bar, git status, cost tracking, multi-line, rate limits, clickable links), subagent status line
- [Checkpointing](references/claude-code-checkpointing.md) — Automatic tracking, rewind menu, restore vs summarize, limitations
- [Remote Control](references/claude-code-remote-control.md) — Continue local sessions from phone/browser, server mode flags, push notifications, security model, troubleshooting
- [Scheduled Tasks](references/claude-code-scheduled-tasks.md) — `/loop` command, fixed vs dynamic intervals, built-in maintenance prompt, `loop.md` customization, cron reference, session-scoped limitations
- [Desktop Scheduled Tasks](references/claude-code-desktop-scheduled-tasks.md) — Desktop Routines UI, schedule options, missed runs, permission modes, task management
- [Routines (Cloud)](references/claude-code-routines.md) — Scheduled, API-triggered, and GitHub-event-triggered cloud automation; creating routines; connectors; network access; usage limits
- [Voice Dictation](references/claude-code-voice-dictation.md) — Hold and tap modes, language settings, keybinding customization, troubleshooting
- [Channels](references/claude-code-channels.md) — Telegram, Discord, iMessage, fakechat quickstart, security allowlists, enterprise controls, comparison to other remote features
- [Channels Reference](references/claude-code-channels-reference.md) — Build custom MCP channel servers: capability declaration, notification format, reply tools, sender gating, permission relay
- [Context Window](references/claude-code-context-window.md) — Interactive timeline of what loads and when, what survives compaction table, how to check your own session
- [Prompt Caching](references/claude-code-prompt-caching.md) — Cache layers, actions that invalidate/keep the cache, TTL options, cache scope, subagent caching, disabling caching
- [Prompt Library](references/claude-code-prompt-library.md) — 50+ copy-paste prompts by SDLC phase and role, prompting pattern explanations
- [Worktrees](references/claude-code-worktrees.md) — `--worktree` flag, base branch settings, `.worktreeinclude`, subagent isolation, cleanup, non-git VCS hooks

## Sources

- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled Tasks (/loop): https://code.claude.com/docs/en/scheduled-tasks.md
- Desktop Scheduled Tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Routines (Cloud): https://code.claude.com/docs/en/routines.md
- Voice Dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels Reference: https://code.claude.com/docs/en/channels-reference.md
- Context Window: https://code.claude.com/docs/en/context-window.md
- Prompt Caching: https://code.claude.com/docs/en/prompt-caching.md
- Prompt Library: https://code.claude.com/docs/en/prompt-library.md
- Worktrees: https://code.claude.com/docs/en/worktrees.md
