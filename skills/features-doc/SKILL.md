---
name: features-doc
description: Complete official documentation for Claude Code features — fast mode, model configuration (aliases, effort levels, extended context), output styles, status line, checkpointing/rewind, remote control, scheduled tasks (/loop, Desktop, Routines), voice dictation, channels (Telegram/Discord/iMessage), context window, fullscreen rendering, deep links, agent view, and parallel agents overview.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code's built-in features, including model configuration, UI enhancements, automation tools, and multi-agent capabilities.

## Quick Reference

### Extension Features Overview

| Feature | What it does | When to use it |
| :--- | :--- | :--- |
| **CLAUDE.md** | Persistent context loaded every session | "Always do X" project conventions |
| **Skills** | Instructions/workflows Claude can use | Reusable reference docs, repeatable tasks |
| **Subagents** | Isolated execution, returns summary | Context isolation, parallel tasks |
| **Agent teams** | Multiple independent sessions coordinated | Complex parallel work with peer messaging |
| **MCP** | Connect to external services | External data or actions |
| **Hooks** | Scripts triggered by lifecycle events | Automation that must run every time |
| **Plugins** | Packaging layer for the above | Share setups across repos |

**Feature load order:** CLAUDE.md files are additive; skills override by name (managed > user > project); MCP servers override by name (local > project > user); hooks merge (all registered hooks fire).

### Fast Mode

| Item | Value |
| :--- | :--- |
| **Toggle** | `/fast` in CLI or VS Code extension; or `"fastMode": true` in user settings |
| **Speed** | 2.5× faster than standard Opus |
| **Pricing** | $30 input / $150 output per MTok |
| **Availability** | Opus 4.7 (default in v2.1.142+) and Opus 4.6; not available on Sonnet/Haiku or Bedrock/Vertex/Foundry |
| **Plans** | All subscription plans (Pro/Max/Team/Enterprise) and Console; uses usage credits only |
| **Indicator** | `↯` icon next to prompt while active |
| **Per-session opt-in** | Set `"fastModePerSessionOptIn": true` in managed settings to reset fast mode each session |
| **Rate limits** | Shared pool for Opus 4.7 and 4.6; falls back to standard speed on limit hit |
| **Disable org-wide** | `CLAUDE_CODE_DISABLE_FAST_MODE=1` |

### Model Configuration

#### Model Aliases

| Alias | Behavior |
| :--- | :--- |
| `default` | Clears override; reverts to recommended model for account type |
| `best` | Most capable available (currently `opus`) |
| `sonnet` | Latest Sonnet (daily coding tasks) |
| `opus` | Latest Opus (complex reasoning) |
| `haiku` | Fast and efficient (simple tasks) |
| `sonnet[1m]` | Sonnet with 1M token context |
| `opus[1m]` | Opus with 1M token context |
| `opusplan` | Uses `opus` in plan mode, switches to `sonnet` for execution |

On Anthropic API and Claude Platform on AWS: `opus` = Opus 4.7, `sonnet` = Sonnet 4.6. On Bedrock/Vertex/Foundry: `opus` = Opus 4.6, `sonnet` = Sonnet 4.5.

#### Setting Priority

1. `/model <alias>` during session (saved to user settings)
2. `--model <alias>` at startup (session-only)
3. `ANTHROPIC_MODEL=<alias>` environment variable (session-only)
4. `model` field in settings file

#### Effort Levels

| Level | When to use |
| :--- | :--- |
| `low` | Latency-sensitive, simple tasks |
| `medium` | Cost-sensitive, acceptable quality trade-off |
| `high` | Minimum for intelligence-sensitive work |
| `xhigh` | Best for most coding/agentic tasks (default on Opus 4.7) |
| `max` | Demanding tasks; session-only (cannot be saved to settings) |

Set with `/effort <level>`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL` env var, or `effortLevel` in settings. Include `ultrathink` in a prompt for deeper reasoning on that turn without changing the session effort setting.

#### Extended Context (1M tokens)

| Plan | Opus 1M | Sonnet 1M |
| :--- | :--- | :--- |
| Max/Team/Enterprise | Included | Usage credits required |
| Pro | Usage credits required | Usage credits required |
| API / pay-as-you-go | Full access | Full access |

Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`. Use `[1m]` suffix: `/model opus[1m]`.

#### Default Model by Plan

| Plan | Default |
| :--- | :--- |
| Max and Team Premium | Opus 4.7 |
| Pro, Team Standard, Enterprise, Anthropic API | Sonnet 4.6 |
| Bedrock, Vertex, Foundry | Sonnet 4.5 |

#### Model Env Variables

| Variable | Effect |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for `opus` alias and `opusplan` in plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` alias and `opusplan` in execute mode |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for `haiku` alias and background functionality |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Override model for all subagents |

### Output Styles

| Style | Behavior |
| :--- | :--- |
| **Default** | Standard software engineering mode |
| **Proactive** | Execute immediately, make assumptions, prefer action over planning |
| **Explanatory** | Adds "Insights" between task completion steps |
| **Learning** | Collaborative mode; adds `TODO(human)` markers for user-implemented pieces |

Change with `/config` → Output style, or set `"outputStyle": "<name>"` in settings. Changes take effect on the next session start (kept stable during a session for prompt caching).

**Custom output styles** — Markdown files in `~/.claude/output-styles/`, `.claude/output-styles/`, or managed policy directory.

| Frontmatter | Purpose | Default |
| :--- | :--- | :--- |
| `name` | Style name (if not filename) | From filename |
| `description` | Shown in `/config` picker | None |
| `keep-coding-instructions` | Keep Claude's built-in software engineering instructions | `false` |
| `force-for-plugin` | Auto-apply when plugin is enabled | `false` |

### Status Line

**Setup:** Add to `~/.claude/settings.json`:
```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2,
    "refreshInterval": 10
  }
}
```

Or use `/statusline <description>` and Claude generates the script automatically.

**Key available JSON fields (sent to script via stdin):**

| Field | Description |
| :--- | :--- |
| `model.id`, `model.display_name` | Current model |
| `workspace.current_dir`, `workspace.project_dir` | Working directories |
| `context_window.used_percentage` | % of context used |
| `context_window.context_window_size` | Max tokens (200000 or 1000000) |
| `cost.total_cost_usd` | Estimated session cost |
| `cost.total_duration_ms` | Session elapsed time (ms) |
| `effort.level` | Current effort level (when supported) |
| `rate_limits.five_hour.used_percentage` | 5-hour limit usage (Pro/Max only) |
| `rate_limits.seven_day.used_percentage` | 7-day limit usage (Pro/Max only) |
| `session_id` | Stable session identifier (use for cache keys) |
| `vim.mode` | Current vim mode (when vim mode enabled) |
| `worktree.name`, `worktree.branch` | Worktree info (during `--worktree` sessions) |

**Subagent status line:** Use `subagentStatusLine` setting to customize per-agent rows in the agent panel. Script receives `tasks` array on stdin and outputs `{"id": "<task-id>", "content": "<row>"}` per line.

**Tips:** Cache slow operations (git status) keyed on `session_id`. Updates run after each assistant message, after `/compact`, on permission mode change, and on vim mode toggle (debounced 300ms). Requires workspace trust acceptance.

### Checkpointing and Rewind

Checkpoints are created automatically before each file edit. Access via `Esc Esc` (double-Esc) or `/rewind`.

**Rewind actions:**

| Action | Effect |
| :--- | :--- |
| Restore code and conversation | Reverts both to selected point |
| Restore conversation | Rewinds chat; keeps current files |
| Restore code | Reverts files; keeps conversation |
| Summarize from here | Compresses selected message and everything after into summary |
| Summarize up to here | Compresses everything before selected message; stays at end |

Checkpoints persist across sessions (auto-cleaned after 30 days by default). Does **not** track files modified by bash commands or edits from other sessions.

### Remote Control

Connects claude.ai/code or the Claude mobile app to a local Claude Code session — Claude runs on your machine, not in the cloud.

**Requirements:** Pro/Max/Team/Enterprise subscription (not API keys); Team/Enterprise requires admin to enable the Remote Control toggle.

| Mode | Command |
| :--- | :--- |
| Server mode (multi-session) | `claude remote-control` |
| Interactive with remote enabled | `claude --remote-control` or `claude --rc` |
| From existing session | `/remote-control` or `/rc` |
| Enable for all sessions | `/config` → Enable Remote Control for all sessions |

**Server mode flags:**

| Flag | Description |
| :--- | :--- |
| `--name "<title>"` | Custom session title |
| `--spawn same-dir` | All sessions share cwd (default) |
| `--spawn worktree` | Each session gets its own git worktree |
| `--spawn session` | Single-session mode |
| `--capacity <N>` | Max concurrent sessions (default 32) |

Press `Space` to show QR code. Sessions survive network drops and laptop sleep. Push notifications available via Claude mobile app (requires v2.1.110+).

**Troubleshooting errors:**
- "requires a claude.ai subscription" → run `claude auth login`
- "disabled by your organization's policy" → admin needs to enable the Remote Control toggle at claude.ai/admin-settings/claude-code
- "Remote credentials fetch failed" → run with `--verbose`

### Scheduled Tasks

Three scheduling options:

| | Cloud Routines | Desktop Tasks | `/loop` |
| :--- | :--- | :--- | :--- |
| **Runs on** | Anthropic cloud | Your machine | Your machine |
| **Requires machine on** | No | Yes | Yes |
| **Requires open session** | No | No | Yes |
| **Persists across restarts** | Yes | Yes | Restored on `--resume` if unexpired |
| **Local file access** | No (fresh clone) | Yes | Yes |
| **Min interval** | 1 hour | 1 minute | 1 minute |

#### `/loop` (Session-scoped)

| Input | Effect |
| :--- | :--- |
| `/loop 5m check the deploy` | Fixed-interval polling |
| `/loop check the deploy` | Claude chooses interval dynamically |
| `/loop` | Built-in maintenance prompt (PR tending, cleanup) |

Stop a running loop with `Esc`. Tasks expire after 7 days. Session can hold up to 50 scheduled tasks. Cron tools: `CronCreate`, `CronList`, `CronDelete`.

Customize bare `/loop` with `loop.md` at `.claude/loop.md` (project) or `~/.claude/loop.md` (user). Disable scheduling entirely with `CLAUDE_CODE_DISABLE_CRON=1`.

**Cron expression examples:**

| Expression | Meaning |
| :--- | :--- |
| `*/5 * * * *` | Every 5 minutes |
| `0 9 * * *` | Daily at 9am local |
| `0 9 * * 1-5` | Weekdays at 9am local |

#### Desktop Scheduled Tasks

Created from the Routines sidebar in Claude Code Desktop (choose **Local**). Schedule options: Manual, Hourly, Daily, Weekdays, Weekly. Each task gets its own permission mode. Enable worktree toggle to isolate each run. Missed runs: one catch-up run for most recently missed time on wake. Edit prompt on disk at `~/.claude/scheduled-tasks/<task-name>/SKILL.md`.

#### Cloud Routines

Created at claude.ai/code/routines, from Desktop (choose **Remote**), or via `/schedule` in CLI. Triggers: scheduled (hourly/nightly/weekly/one-time), API (HTTP POST to per-routine endpoint), or GitHub events (PR opened, release, etc.). Runs autonomously with no permission prompts. Belongs to individual claude.ai account; counted against daily run allowance. Admins can disable via the Routines toggle at claude.ai/admin-settings/claude-code.

### Voice Dictation

**Requirements:** Claude.ai account authentication (not API key or Bedrock/Vertex/Foundry); local microphone access; requires Claude Code v2.1.69+ (tap mode v2.1.116+).

| Command | Effect |
| :--- | :--- |
| `/voice` | Toggle on/off (keeps current mode) |
| `/voice hold` | Enable hold-to-record mode (default) |
| `/voice tap` | Enable tap-to-record-and-send mode |
| `/voice off` | Disable |

**Hold mode:** Hold `Space` to record; release to insert transcript. Brief warmup delay before recording starts. Set `"autoSubmit": true` to send automatically on release (3+ words). **Tap mode:** Tap once to start, tap again to send (auto-submits on 3+ words; stops after 15s silence or 2 min total).

Settings persist across sessions. Rebind dictation key via `voice:pushToTalk` action in `~/.claude/keybindings.json`. Dictation language follows the `language` setting (defaults to English).

### Channels

Push events from Telegram, Discord, iMessage, or custom MCP servers into a running Claude Code session. Requires Claude Code v2.1.80+, Anthropic auth (not Bedrock/Vertex/Foundry). Team/Enterprise must enable via admin settings.

**Start with channels enabled:**
```bash
claude --channels plugin:telegram@claude-plugins-official
```

**Supported channels (require Bun):** Telegram, Discord, iMessage, fakechat (localhost demo).

**Setup pattern (Telegram/Discord):**
1. Install plugin: `/plugin install telegram@claude-plugins-official`
2. Configure token: `/telegram:configure <token>`
3. Restart with `--channels`
4. Pair account: `/telegram:access pair <code>`
5. Lock down: `/telegram:access policy allowlist`

**iMessage:** Reads `~/Library/Messages/chat.db` directly; needs Full Disk Access. Self-messages bypass access control. Add others with `/imessage:access allow +15551234567`.

**Enterprise settings:**

| Setting | Purpose |
| :--- | :--- |
| `channelsEnabled` | Master switch; required for Team/Enterprise |
| `allowedChannelPlugins` | Restrict which plugins can register as channels |

### Fullscreen Rendering

Eliminates flicker, adds mouse support, keeps memory flat in long sessions. Uses terminal alternate screen buffer.

**Enable:** `/tui fullscreen` (or `CLAUDE_CODE_NO_FLICKER=1`). **Disable:** `/tui default`.

**Mouse support:** Click to position cursor; click collapsed tool result to expand; click URL/file path to open; click-and-drag to select (auto-copies to clipboard); scroll with mouse wheel.

**Transcript mode** (`Ctrl+o`): `less`-style search with `/`, `n`/`N` for next/prev match. Press `[` to write full conversation to terminal scrollback; `v` to open in `$VISUAL`.

**Scroll shortcuts:** `PgUp`/`PgDn`, `Ctrl+Home` (jump to start), `Ctrl+End` (jump to bottom + resume auto-follow). Tune scroll speed with `CLAUDE_CODE_SCROLL_SPEED=3` or `/scroll-speed` command.

**Disable mouse capture only:** `CLAUDE_CODE_DISABLE_MOUSE=1` keeps flicker-free rendering while restoring native text selection.

### Deep Links

Open Claude Code in a terminal from a URL. Format: `claude-cli://open?<params>`

| Parameter | Description |
| :--- | :--- |
| `q` | URL-encoded prompt text (max 5,000 chars) |
| `cwd` | Absolute path for working directory |
| `repo` | GitHub `owner/name` slug (resolves to most recently used local clone) |

If both `cwd` and `repo` are passed, `cwd` takes precedence. Requires Claude Code v2.1.91+.

**Registration:** Automatic on first interactive session. Disable with `"disableDeepLinkRegistration": "disable"` in settings.

**Note:** GitHub-rendered Markdown strips `claude-cli://` links (shows only label text). Use code blocks on GitHub to display the URL for copy-paste.

**VS Code tab:** Use `vscode://anthropic.claude-code/open` instead of `claude-cli://` to open a VS Code editor tab.

### Agent View

Unified dashboard for background sessions. Open with `claude agents`.

**Key commands:**

| Command | Purpose |
| :--- | :--- |
| `claude agents` | Open agent view |
| `claude agents --cwd <path>` | Scope to sessions in a directory |
| `claude --bg "<prompt>"` | Start a session directly in background |
| `claude attach <id>` | Attach to a session |
| `claude logs <id>` | Show recent output |
| `claude stop <id>` / `claude kill <id>` | Stop a session |
| `claude rm <id>` | Remove session and transcript |
| `claude respawn <id>` | Restart session with conversation intact |
| `claude daemon status` | Show supervisor process state |

**In-session commands:**
- `/bg` or `/background` — move current session to background
- `←` on empty prompt — background current session and open agent view

**Session state icons:**

| State | Icon | Meaning |
| :--- | :--- | :--- |
| Working | Animated | Actively running tools |
| Needs input | Yellow | Waiting on question/permission |
| Idle | Dimmed | Ready for next prompt |
| Completed | Green | Finished successfully |
| Failed | Red | Ended with error |
| Stopped | Grey | Manually stopped |

**Process icons:** `✻`/`✽` = process alive; `∙` = process exited (will restart on attach); `✢` = `/loop` session sleeping.

**File isolation:** Background sessions automatically move into isolated git worktrees under `.claude/worktrees/` before editing files. Disable with `worktree.bgIsolation: "none"` in project settings.

**Agent view keyboard shortcuts:**

| Shortcut | Action |
| :--- | :--- |
| `Space` | Peek at selected session |
| `Enter` / `→` | Attach to selected session |
| `←` | Detach and return to agent view |
| `Ctrl+T` | Pin/unpin session |
| `Ctrl+R` | Rename session |
| `Ctrl+X` (twice) | Stop then delete session |
| `Ctrl+S` | Toggle grouping (state vs. directory) |
| `?` | Show all shortcuts |

**Filtering:** `a:<name>` by agent name; `s:<state>` by state; `#<number>` or PR URL by pull request.

Disable agent view entirely: `"disableAgentView": true` in settings or `CLAUDE_CODE_DISABLE_AGENT_VIEW=1`.

### Parallel Agents Comparison

| Approach | Coordination | Communication | File isolation | Use when |
| :--- | :--- | :--- | :--- | :--- |
| **Subagents** | Main session delegates | Reports result back | Optional per-worktree | Side task would flood main context |
| **Agent view** | You dispatch and monitor | You see state; step in when needed | Auto worktree per session | Several independent tasks to hand off |
| **Agent teams** | Lead Claude coordinates | Teammates message each other | None (partition manually) | Complex parallel work needing peer sync |
| **`/batch`** | Planned by Claude | Pull requests per piece | Worktree per subagent | Repo-wide migration or mechanical refactor |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code (features overview)](references/claude-code-features-overview.md) — when to use CLAUDE.md vs skills vs subagents vs MCP vs hooks vs plugins; context costs by feature; how features layer
- [Fast mode](references/claude-code-fast-mode.md) — `/fast` toggle, pricing, requirements, per-session opt-in, rate limit fallback
- [Model configuration](references/claude-code-model-config.md) — model aliases, effort levels, extended context, third-party deployment pinning, `availableModels`, `modelOverrides`, prompt caching config
- [Output styles](references/claude-code-output-styles.md) — built-in styles, custom style creation, frontmatter reference, comparison with CLAUDE.md and agents
- [Status line](references/claude-code-statusline.md) — setup, available JSON fields, Bash/Python/Node examples, subagent status line, Windows config, troubleshooting
- [Checkpointing](references/claude-code-checkpointing.md) — automatic tracking, rewind menu, restore vs. summarize, limitations
- [Remote Control](references/claude-code-remote-control.md) — modes, flags, connecting from another device, mobile push notifications, security model, troubleshooting
- [Scheduled tasks (/loop)](references/claude-code-scheduled-tasks.md) — `/loop` syntax, fixed vs. dynamic intervals, maintenance prompt, `loop.md` customization, cron reference, jitter and 7-day expiry
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) — creating tasks in Desktop app, schedule options, missed runs, permissions, task management
- [Routines (cloud scheduling)](references/claude-code-routines.md) — create from web/Desktop/CLI, schedule/API/GitHub triggers, managing runs, usage limits
- [Voice dictation](references/claude-code-voice-dictation.md) — hold and tap modes, language support, rebinding the dictation key, troubleshooting
- [Channels](references/claude-code-channels.md) — Telegram/Discord/iMessage setup, fakechat quickstart, security/allowlists, enterprise controls
- [Channels reference](references/claude-code-channels-reference.md) — building a custom channel MCP server, notification format, reply tool, sender gating, permission relay
- [Context window explorer](references/claude-code-context-window.md) — interactive breakdown of what loads at session start and when
- [Fullscreen rendering](references/claude-code-fullscreen.md) — enable/disable, mouse support, scroll shortcuts, transcript mode, tmux caveats
- [Deep links](references/claude-code-deep-links.md) — `claude-cli://open` URL format, parameters, embedding in runbooks, platform registration
- [Agent view](references/claude-code-agent-view.md) — dispatching, monitoring, peek/reply, attaching, file isolation, shell commands, supervisor process
- [Run agents in parallel](references/claude-code-agents.md) — comparison of subagents, agent view, agent teams, worktrees, and `/batch`
- [Worktrees](references/claude-code-worktrees.md) — `--worktree` flag, base branch config, `.worktreeinclude`, subagent isolation, cleanup

## Sources

- Extend Claude Code (features overview): https://code.claude.com/docs/en/features-overview.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks (/loop): https://code.claude.com/docs/en/scheduled-tasks.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Routines (cloud scheduling): https://code.claude.com/docs/en/routines.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Context window explorer: https://code.claude.com/docs/en/context-window.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
- Deep links: https://code.claude.com/docs/en/deep-links.md
- Agent view: https://code.claude.com/docs/en/agent-view.md
- Run agents in parallel: https://code.claude.com/docs/en/agents.md
- Worktrees: https://code.claude.com/docs/en/worktrees.md
