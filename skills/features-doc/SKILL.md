---
name: features-doc
description: Complete official documentation for Claude Code features — fast mode, model configuration, output styles, status line, checkpointing, remote control, scheduled tasks, voice dictation, channels, context window, fullscreen rendering, routines, deep links, agent view, parallel agents, and worktrees.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code's core features and capabilities.

## Quick Reference

### Fast Mode

Fast mode makes Claude Opus 4.6 respond **2.5x faster** at higher per-token cost.

| Toggle | Persist | Pricing |
| :--- | :--- | :--- |
| `/fast` or `"fastMode": true` in settings | On by default across sessions | $30/$150 MTok input/output |

- Only available on Opus 4.6 (not Opus 4.7 or other models)
- Requires extra usage enabled; not available on Bedrock/Vertex/Foundry
- Team/Enterprise: admin must enable at claude.ai/admin-settings/claude-code
- Rate limit hit: falls back to standard Opus 4.6 automatically; `↯` icon turns gray
- Admin can require per-session opt-in with `"fastModePerSessionOptIn": true`

### Model Configuration

**Model aliases:**

| Alias | Resolves to |
| :--- | :--- |
| `default` | Clears override; uses recommended for account type |
| `best` / `opus` | Latest Opus (4.7 on API/Claude Platform on AWS, 4.6 on Bedrock/Vertex/Foundry) |
| `sonnet` | Latest Sonnet (4.6 on API, 4.5 on Bedrock/Vertex/Foundry) |
| `haiku` | Latest Haiku; also used for background tasks |
| `opusplan` | Opus during plan mode, switches to Sonnet for execution |
| `sonnet[1m]` / `opus[1m]` | 1M token context window variants |

**Setting priority (highest to lowest):** `/model` during session → `--model` flag → `ANTHROPIC_MODEL` env var → settings file

**Effort levels** (`/effort` command or `effortLevel` in settings):

| Level | When to use |
| :--- | :--- |
| `low` | Short, latency-sensitive, not intelligence-sensitive tasks |
| `medium` | Cost-sensitive work, trading some intelligence |
| `high` | Balance of token usage and intelligence; minimum for sensitive work |
| `xhigh` | Best results for most coding/agentic tasks (default on Opus 4.7) |
| `max` | Deepest reasoning; session-only unless set via env var |

- Include `ultrathink` in a prompt for one-off deep reasoning without changing effort
- Extended context (1M tokens): included for Opus on Max/Team/Enterprise; extra usage otherwise

**Key environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Pin opus alias to a specific version |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Pin sonnet alias |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Pin haiku alias |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model used for subagents |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching globally |

**Third-party deployments:** Use `ANTHROPIC_DEFAULT_OPUS_MODEL_SUPPORTED_CAPABILITIES` to declare capabilities (`effort`, `xhigh_effort`, `thinking`, `adaptive_thinking`, `interleaved_thinking`). Use `modelOverrides` in settings to map Anthropic model IDs to provider-specific ARNs/names.

### Output Styles

Output styles modify the system prompt to change Claude's tone and format.

**Built-in styles:**

| Style | Behavior |
| :--- | :--- |
| Default | Standard software engineering assistant |
| Proactive | Executes immediately with fewer clarifying questions |
| Explanatory | Adds "Insights" sections explaining implementation choices |
| Learning | Adds Insights + `TODO(human)` markers for you to implement |

- Set via `/config` → Output style, or `"outputStyle": "Explanatory"` in settings
- Changes take effect next session (applied at session start for prompt caching)
- Custom styles: Markdown files with YAML frontmatter in `~/.claude/output-styles/`, `.claude/output-styles/`, or plugin `output-styles/` directory

**Custom style frontmatter:**

| Field | Purpose | Default |
| :--- | :--- | :--- |
| `name` | Style name | File name |
| `description` | Shown in `/config` picker | None |
| `keep-coding-instructions` | Keep coding-specific system prompt parts | false |
| `force-for-plugin` | Auto-apply when plugin is enabled | false |

### Status Line

A customizable bar at the bottom of the Claude Code CLI driven by a shell script.

**Setup:** `/statusline show model and context` (generates script + updates settings), or manually:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2,
    "refreshInterval": 5,
    "hideVimModeIndicator": false
  }
}
```

**Key available JSON fields (piped to stdin):**

| Field | Description |
| :--- | :--- |
| `model.display_name` | Current model name |
| `context_window.used_percentage` | % of context used |
| `context_window.context_window_size` | Max tokens (200K or 1M) |
| `cost.total_cost_usd` | Estimated session cost |
| `cost.total_duration_ms` | Total session time |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit usage (Pro/Max only) |
| `rate_limits.seven_day.used_percentage` | 7-day rate limit usage (Pro/Max only) |
| `effort.level` | Current effort level |
| `session_id` | Stable session identifier (use for caching) |
| `worktree.name` / `worktree.branch` | Worktree info (if in `--worktree` session) |
| `vim.mode` | Vim mode (if vim mode enabled) |

- Updates: after each assistant message, after `/compact`, on permission mode change, on vim mode toggle
- `subagentStatusLine`: separate setting to customize subagent panel rows
- Requires workspace trust; disabled if `disableAllHooks: true`

### Checkpointing

Automatic session-level file-change tracking with rewind capability.

- Every user prompt creates a checkpoint; persists across sessions for 30 days
- **Rewind menu:** `Esc`+`Esc` or `/rewind` → select a past prompt, then:
  - **Restore code and conversation**: full revert
  - **Restore conversation**: keep current files, revert conversation
  - **Restore code**: keep conversation, revert files
  - **Summarize from here**: compress conversation from that point (keeps files intact)
- Summarize is targeted `/compact`: keeps early context, compresses later turns
- **Limitations:** bash command file changes not tracked; external edits not tracked; not a git replacement

### Remote Control

Continue a local Claude Code session from any browser or the Claude mobile app.

- Requires claude.ai subscription (Pro/Max/Team/Enterprise), not API keys
- Team/Enterprise: admin must enable in admin settings
- Session runs locally; only messages route through Anthropic API

**Start modes:**

| Command | Effect |
| :--- | :--- |
| `claude remote-control` | Server mode: waits for connections, can handle multiple sessions |
| `claude --remote-control` | Interactive session with remote control enabled |
| `/remote-control` or `/rc` | Enable from inside an existing session |

**Server mode flags:**

| Flag | Description |
| :--- | :--- |
| `--spawn same-dir` | All sessions share current directory (default) |
| `--spawn worktree` | Each session gets its own git worktree |
| `--spawn session` | Single-session mode |
| `--capacity N` | Max concurrent sessions (default 32) |

- Connect from: session URL, QR code (press spacebar to show), or claude.ai/code session list
- Enable for all sessions: `/config` → Enable Remote Control for all sessions
- Push notifications: requires Claude mobile app with same account + `/config` → Push when Claude decides

### Scheduled Tasks (Session-Scoped `/loop`)

Run prompts on a recurring schedule within the current session.

| Command | Behavior |
| :--- | :--- |
| `/loop 5m check the deploy` | Fixed-interval prompt |
| `/loop check the deploy` | Claude chooses interval dynamically |
| `/loop` | Built-in maintenance prompt (dynamic interval) |
| `/loop 15m` | Built-in maintenance on fixed schedule |

- Customize default with `.claude/loop.md` (project) or `~/.claude/loop.md` (user)
- Stop: press `Esc` (clears pending wakeup)
- Max 50 scheduled tasks per session; expire after 7 days
- One-shot reminders: plain language, e.g. "remind me at 3pm to push the release branch"
- Disable: `CLAUDE_CODE_DISABLE_CRON=1`

**Scheduling options comparison:**

| | Cloud Routines | Desktop Scheduled | `/loop` |
| :--- | :--- | :--- | :--- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Min interval | 1 hour | 1 minute | 1 minute |

### Voice Dictation

Speak prompts instead of typing; transcribed live into the input.

- Requires claude.ai account (not API key, Bedrock, Vertex, or Foundry)
- Not available in remote environments (web sessions, SSH)
- Enable: `/voice` (toggle), `/voice hold`, `/voice tap`, `/voice off`
- Settings: `{"voice": {"enabled": true, "mode": "tap"}}`

**Modes:**

| Mode | Behavior |
| :--- | :--- |
| Hold | Hold Space to record, release to finalize (warmup period) |
| Tap | Tap Space to start, tap again to send (no warmup; auto-sends if 3+ words) |

- Rebind via `~/.claude/keybindings.json` with action `voice:pushToTalk`
- Language: set via `language` setting (e.g. `"language": "japanese"`)
- `"autoSubmit": true` in voice settings sends on release (hold mode)

### Channels

Push events from external systems (Telegram, Discord, iMessage) into a running session.

- Research preview; requires Claude Code v2.1.80+
- Requires Anthropic auth (claude.ai or Console API key); not Bedrock/Vertex/Foundry
- Team/Enterprise: admin must enable `channelsEnabled`

**Start with channel:** `claude --channels plugin:telegram@claude-plugins-official`

**Official channel plugins (require Bun):** `telegram`, `discord`, `imessage`, `fakechat` (demo)

- Install: `/plugin install telegram@claude-plugins-official`
- All channels use sender allowlists; bootstrap via pairing code
- Claude sees inbound as `<channel source="...">content</channel>` tags

**Building a custom channel (MCP server):** Declare `capabilities.experimental['claude/channel']: {}`, emit `notifications/claude/channel` notifications with `{content, meta}`. Add `capabilities.experimental['claude/channel/permission']: {}` for permission relay.

**Enterprise controls:**

| Setting | Purpose |
| :--- | :--- |
| `channelsEnabled` | Master switch (Team/Enterprise: off by default) |
| `allowedChannelPlugins` | Restrict which plugins can register |

### Context Window Explorer

Interactive tool accessible at the context window documentation page showing what loads and when.

**What survives `/compact`:**

| Mechanism | After compaction |
| :--- | :--- |
| System prompt + output style | Unchanged (not in message history) |
| Project-root CLAUDE.md + unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Path-scoped rules | Lost until matching file read again |
| Nested CLAUDE.md in subdirectories | Lost until file in subdirectory read again |
| Invoked skill bodies | Re-injected, capped at 5K tokens/skill, 25K total |
| Hooks | N/A (run as code, not context) |

- Check live context: `/context` for breakdown; `/memory` for loaded CLAUDE.md files

### Fullscreen Rendering

Flicker-free alternate screen buffer rendering with mouse support.

- Research preview; requires Claude Code v2.1.89+
- Enable: `/tui fullscreen` (mid-session) or `CLAUDE_CODE_NO_FLICKER=1`
- Disable: `/tui default` or `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1`

**Key shortcuts:**

| Shortcut | Action |
| :--- | :--- |
| `PgUp` / `PgDn` | Scroll half a screen |
| `Ctrl+Home` / `Ctrl+End` | Jump to start / resume auto-follow |
| `Ctrl+o` | Toggle transcript mode (search with `/`, `n`/`N` for next/prev match) |
| `Ctrl+L` twice | Clear conversation (`/clear`) |
| `[` in transcript mode | Write to terminal scrollback for native search |

- Mouse: click to expand tool results, click-drag to select (auto-copies), wheel scroll
- Disable mouse capture (keep rendering): `CLAUDE_CODE_DISABLE_MOUSE=1`
- Adjust scroll speed: `/scroll-speed` or `CLAUDE_CODE_SCROLL_SPEED=3`
- Works in tmux (add `set -g mouse on`); incompatible with `tmux -CC`

### Desktop Scheduled Tasks

Local tasks run by the Claude Code Desktop app on a recurring schedule.

- Created via Routines sidebar → New routine → Local
- Run while Desktop app is open and computer is awake
- Fields: Name, Description, Instructions (with permission mode + model pickers), Schedule, Folder
- Enable worktree isolation per task for file safety
- Schedules: Manual, Hourly, Daily, Weekdays, Weekly (or ask Claude for custom intervals)
- Missed runs: one catch-up run on wake for most recently missed time
- Edit on disk: `~/.claude/scheduled-tasks/<task-name>/SKILL.md`
- Keep computer awake: Settings → Desktop app → General → Keep computer awake

### Routines (Cloud)

Saved Claude Code configurations that run autonomously on Anthropic-managed cloud infrastructure.

- Available on Pro/Max/Team/Enterprise with Claude Code on the web enabled
- Create at claude.ai/code/routines or via `/schedule` in CLI
- Team/Enterprise admins can disable via Routines toggle in admin settings

**Trigger types:**

| Trigger | How |
| :--- | :--- |
| Schedule | Hourly/daily/weekdays/weekly presets; custom cron via `/schedule update` (min 1 hour) |
| API | HTTP POST to per-routine endpoint with bearer token |
| GitHub | PR or release events with filters (author, title, labels, is draft, etc.) |

**API trigger:** `POST /v1/claude_code/routines/<id>/fire` with `Authorization: Bearer <token>` and optional `{"text": "context"}` body. Returns `claude_code_session_id` and URL.

**Supported GitHub events:** `pull_request` (opened/closed/labeled/etc.), `release`

- Routines run autonomously (no permission prompts); push to `claude/`-prefixed branches by default
- Enable unrestricted branch pushes per repository in routine settings
- Usage: draws subscription usage + daily run cap per account

### Deep Links

`claude-cli://` URLs that open Claude Code in a terminal with a pre-filled prompt.

- Requires Claude Code v2.1.91+
- Auto-registered on first interactive session (macOS, Linux, Windows)

**URL format:** `claude-cli://open?q=<url-encoded-prompt>&cwd=<absolute-path>&repo=<owner/name>`

| Parameter | Description |
| :--- | :--- |
| `q` | Prompt text (URL-encoded, max 5000 chars, `%0A` for newlines) |
| `cwd` | Absolute working directory path |
| `repo` | GitHub `owner/name` slug (resolves to most recently used local clone) |

- `cwd` takes precedence over `repo` if both provided
- Prompt is pre-filled but not sent until you press Enter
- GitHub-rendered Markdown strips `claude-cli://` links (put in code blocks as workaround)
- Disable registration: `"disableDeepLinkRegistration": "disable"` in settings
- VS Code extension uses `vscode://anthropic.claude-code/open` instead

### Agent View

One screen to dispatch and monitor background Claude Code sessions.

- Research preview; requires Claude Code v2.1.139+
- Open: `claude agents`; sessions keep running when you exit

**Session states:**

| Indicator | State | Meaning |
| :--- | :--- | :--- |
| Animated | Working | Actively running tools or generating |
| Yellow | Needs input | Waiting for permission decision or answer |
| Dimmed | Idle | Waiting but not blocked |
| Green | Completed | Task finished |
| Red | Failed | Ended with error |
| Grey | Stopped | Stopped with `Ctrl+X` or `claude stop` |

**Icon shapes:** `✻`/`✽` = process alive; `∙` = process exited (restarts on attach); `✢` = `/loop` sleeping

**Key shortcuts:**

| Shortcut | Action |
| :--- | :--- |
| `Space` | Open/close peek panel |
| `Enter` or `→` | Attach to session |
| `←` on empty prompt | Detach back to agent view |
| `Ctrl+X` (×2) | Stop then delete session |
| `Ctrl+T` | Pin/unpin session |
| `Ctrl+S` | Toggle grouping (state vs directory) |
| `Alt+1`–`Alt+9` | Attach to Nth session in group |

**Dispatch:** type prompt + Enter; prefix `@<repo>` for different directory; prefix `@<agent-name>` or first word matching agent name to use custom subagent

**Shell commands:**

| Command | Purpose |
| :--- | :--- |
| `claude --bg "<prompt>"` | Start background session |
| `claude attach <id>` | Attach to session |
| `claude logs <id>` | Show recent output |
| `claude stop <id>` | Stop session |
| `claude respawn --all` | Restart all stopped sessions |

- Background sessions auto-move to git worktrees when editing files
- Disable: `"disableAgentView": true` or `CLAUDE_CODE_DISABLE_AGENT_VIEW=1`

### Running Agents in Parallel

| Approach | Use when |
| :--- | :--- |
| Subagents | Side task would flood main context; delegate and get summary back |
| Agent view | Multiple independent tasks to hand off and monitor |
| Agent teams | Claude should plan, assign, and supervise workers (experimental) |
| Worktrees | Parallel sessions or subagents edit overlapping files |
| `/batch` | Repo-wide migration as 5–30 worktree-isolated subagents |

### Worktrees

Isolated git working directories for parallel Claude Code sessions.

```bash
claude --worktree feature-auth     # creates .claude/worktrees/feature-auth/ on branch worktree-feature-auth
claude --worktree                   # auto-generates name
claude --worktree "#1234"           # branch from PR 1234
```

- Default base: `origin/HEAD`; change with `"worktree": {"baseRef": "head"}` in settings
- Copy gitignored files (e.g. `.env`) into worktrees via `.worktreeinclude` file at project root
- Subagent isolation: ask Claude to "use worktrees for agents" or set `isolation: worktree` in subagent frontmatter
- Cleanup: no changes → auto-removed; changes → prompted; use `git worktree remove <path>` manually
- Non-git VCS: configure `WorktreeCreate` and `WorktreeRemove` hooks

## Full Documentation

For the complete official documentation, see the reference files:

- [Fast mode](references/claude-code-fast-mode.md) — toggle Opus 4.6 fast mode, cost tradeoffs, rate limits, admin controls
- [Model configuration](references/claude-code-model-config.md) — model aliases, effort levels, extended context, third-party pinning, prompt caching
- [Output styles](references/claude-code-output-styles.md) — built-in styles, custom style files, frontmatter reference
- [Customize your status line](references/claude-code-statusline.md) — setup, available JSON fields, Bash/Python/Node.js examples, subagent status line
- [Checkpointing](references/claude-code-checkpointing.md) — automatic tracking, rewind menu, summarize, limitations
- [Remote Control](references/claude-code-remote-control.md) — setup, server mode flags, mobile push notifications, troubleshooting
- [Run prompts on a schedule](references/claude-code-scheduled-tasks.md) — /loop, fixed and dynamic intervals, CronCreate/List/Delete tools, loop.md
- [Voice dictation](references/claude-code-voice-dictation.md) — hold and tap modes, language settings, keybinding, troubleshooting
- [Channels](references/claude-code-channels.md) — Telegram/Discord/iMessage setup, security, enterprise controls
- [Channels reference](references/claude-code-channels-reference.md) — build a custom channel: server options, notification format, reply tool, permission relay
- [Explore the context window](references/claude-code-context-window.md) — interactive timeline, what survives compaction, context cost by feature
- [Fullscreen rendering](references/claude-code-fullscreen.md) — enable, mouse support, scrolling, transcript mode, tmux notes, troubleshooting
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) — create, schedule options, permissions, missed runs, manage
- [Routines](references/claude-code-routines.md) — schedule/API/GitHub triggers, creating from web/CLI, environments, connectors, usage limits
- [Deep links](references/claude-code-deep-links.md) — URL format, cwd vs repo, shell usage, registration, troubleshooting
- [Agent view](references/claude-code-agent-view.md) — session states, peek/reply, attach/detach, dispatch, shell commands, supervisor process
- [Run agents in parallel](references/claude-code-agents.md) — comparison table: subagents vs agent view vs agent teams vs worktrees vs /batch
- [Worktrees](references/claude-code-worktrees.md) — --worktree flag, .worktreeinclude, subagent isolation, cleanup, non-git VCS hooks
- [Features overview](references/claude-code-features-overview.md) — when to use CLAUDE.md vs skills vs MCP vs subagents vs hooks vs plugins; context costs by feature

## Sources

- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Customize your status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Run prompts on a schedule: https://code.claude.com/docs/en/scheduled-tasks.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Explore the context window: https://code.claude.com/docs/en/context-window.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Routines: https://code.claude.com/docs/en/routines.md
- Deep links: https://code.claude.com/docs/en/deep-links.md
- Agent view: https://code.claude.com/docs/en/agent-view.md
- Run agents in parallel: https://code.claude.com/docs/en/agents.md
- Worktrees: https://code.claude.com/docs/en/worktrees.md
- Features overview: https://code.claude.com/docs/en/features-overview.md
