---
name: features-doc
description: Complete official documentation for Claude Code features — fast mode, model configuration and aliases, output styles, status line, checkpointing and rewind, remote control, scheduled tasks and /loop, voice dictation, channels (Telegram/Discord/iMessage), channels reference for building custom channels, desktop scheduled tasks, context window visualization, fullscreen TUI rendering, routines (cloud automation), deep links, agent view, running agents in parallel, and git worktrees for session isolation.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features.

## Quick Reference

### Fast Mode

| Setting | Value |
| :--- | :--- |
| Toggle | `/fast` or `"fastMode": true` in user settings |
| Models | Opus 4.6 (default), Opus 4.7 (set `CLAUDE_CODE_ENABLE_OPUS_4_7_FAST_MODE=1`) |
| Speed | 2.5x faster than standard Opus |
| Price | $30/$150 MTok input/output (same for both Opus versions) |
| Indicator | `↯` icon next to prompt |
| Requires | Extra usage enabled; not available on Bedrock/Vertex/Foundry |
| Per-session opt-in | `"fastModePerSessionOptIn": true` in managed settings |
| Disable org-wide | Set `CLAUDE_CODE_DISABLE_FAST_MODE=1` |
| Rate limit fallback | Automatically falls back to standard speed; `↯` turns gray |

Switching from Opus 4.7 fast mode off stays on Opus 4.7 (does not revert to previous model). Use `/model` to change models.

### Model Configuration

**Model aliases:**

| Alias | Resolves to |
| :--- | :--- |
| `default` | Clears override; system default for account tier |
| `best` | Most capable model (currently `opus`) |
| `sonnet` | Latest Sonnet; Anthropic/AWS = Sonnet 4.6, Bedrock/Vertex/Foundry = Sonnet 4.5 |
| `opus` | Latest Opus; Anthropic/AWS = Opus 4.7, Bedrock/Vertex/Foundry = Opus 4.6 |
| `haiku` | Fast/efficient Haiku |
| `sonnet[1m]` | Sonnet with 1M token context |
| `opus[1m]` | Opus with 1M token context |
| `opusplan` | Opus in plan mode, Sonnet in execution mode |

**Setting model (priority order):**
1. `/model <alias|name>` during session
2. `claude --model <alias|name>` at startup
3. `ANTHROPIC_MODEL=<alias|name>` env var
4. `"model"` field in settings file

**1M token context:**

| Plan | Opus 1M | Sonnet 1M |
| :--- | :--- | :--- |
| Max/Team/Enterprise | Included | Requires extra usage |
| Pro | Requires extra usage | Requires extra usage |
| API/pay-as-you-go | Full access | Full access |

Disable: `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`

**Effort levels** (for Opus 4.7, 4.6, Sonnet 4.6):

| Level | When to use |
| :--- | :--- |
| `low` | Latency-sensitive, not intelligence-sensitive |
| `medium` | Cost-sensitive, accepts some intelligence trade-off |
| `high` | Intelligence-sensitive work, or to reduce spend vs `xhigh` |
| `xhigh` | Best for most coding/agentic tasks (default on Opus 4.7) |
| `max` | Demanding tasks; session-only, not saved to settings |

Set via: `/effort`, `/effort <level>`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL`, `effortLevel` in settings, or skill/subagent frontmatter `effort` field.

Include `ultrathink` in a prompt for one-off deep reasoning without changing the session effort level.

**Extended thinking:** toggle with `Option+T` (macOS) / `Alt+T` (Windows/Linux), or set `alwaysThinkingEnabled` via `/config`. Set `MAX_THINKING_TOKENS=0` to disable regardless of effort.

**Model alias env vars:**

| Env var | Controls |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | What `opus` and `opusplan` (plan phase) resolve to |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | What `sonnet` and `opusplan` (execution) resolve to |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | What `haiku` and background tasks resolve to |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |

`availableModels` in managed settings restricts the `/model` picker. Combine with `model` and `ANTHROPIC_DEFAULT_*_MODEL` for full control.

**Third-party provider pinning:** Set `ANTHROPIC_DEFAULT_OPUS_MODEL` (etc.) to provider-specific IDs. Append `[1m]` to enable 1M context. Use `_NAME`, `_DESCRIPTION`, `_SUPPORTED_CAPABILITIES` companions for display and feature detection.

Capability values for `_SUPPORTED_CAPABILITIES`: `effort`, `xhigh_effort`, `max_effort`, `thinking`, `adaptive_thinking`, `interleaved_thinking`

**Prompt caching env vars:** `DISABLE_PROMPT_CACHING`, `DISABLE_PROMPT_CACHING_HAIKU`, `DISABLE_PROMPT_CACHING_SONNET`, `DISABLE_PROMPT_CACHING_OPUS`

### Output Styles

**Built-in styles:**

| Style | Description |
| :--- | :--- |
| Default | Standard software engineering system prompt |
| Proactive | Executes immediately, minimal pauses; does not change permission mode |
| Explanatory | Adds educational "Insights" between coding steps |
| Learning | Adds "Insights" plus `TODO(human)` markers for collaborative learning |

Set via `/config` → Output style, or `"outputStyle": "<name>"` in settings. Takes effect on next session start.

**Custom output style frontmatter:**

| Field | Description |
| :--- | :--- |
| `name` | Style name (defaults to filename) |
| `description` | Shown in `/config` picker |
| `keep-coding-instructions` | Keep Claude's built-in coding behavior (default `false`) |
| `force-for-plugin` | Auto-apply when plugin is enabled, overrides user `outputStyle` |

File locations: `~/.claude/output-styles/` (user), `.claude/output-styles/` (project), or in managed settings dir. Plugins can ship output styles in `output-styles/`.

### Status Line

Config in settings (`~/.claude/settings.json` or project settings):
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

Use `/statusline <description>` to generate a script automatically.

**Key JSON fields available in stdin:**

| Field | Description |
| :--- | :--- |
| `model.display_name` | Current model name |
| `workspace.current_dir` | Working directory |
| `workspace.project_dir` | Launch directory (may differ if cwd changed) |
| `workspace.added_dirs` | Dirs added via `/add-dir` |
| `workspace.git_worktree` | Git worktree name (if in a linked worktree) |
| `cost.total_cost_usd` | Estimated session cost |
| `cost.total_duration_ms` | Total elapsed time |
| `context_window.used_percentage` | Context usage percentage |
| `context_window.context_window_size` | Max context (200K or 1M) |
| `effort.level` | Current effort level |
| `rate_limits.five_hour.used_percentage` | 5h rate limit usage (Pro/Max only) |
| `rate_limits.seven_day.used_percentage` | 7d rate limit usage (Pro/Max only) |
| `session_id` | Unique session ID (use as cache key) |
| `vim.mode` | Vim mode state when vim mode is on |
| `worktree.name` | Active worktree name (only in `--worktree` sessions) |
| `output_style.name` | Current output style |

Updates after each assistant message, after `/compact`, on permission mode/vim mode change. Debounced at 300ms. Use `refreshInterval` for time-based or subagent-idle updates.

Subagent status line: `"subagentStatusLine"` setting — command receives `tasks` array, outputs `{"id": "...", "content": "..."}` lines.

### Checkpointing and Rewind

**Automatic:** Claude Code tracks file edits before each edit. Every user prompt creates a checkpoint. Persists 30 days (configurable).

**To rewind:** Press `Esc` twice or run `/rewind`. Choose from:

| Action | Effect |
| :--- | :--- |
| Restore code and conversation | Revert both files and conversation |
| Restore conversation | Rewind conversation, keep current files |
| Restore code | Revert files, keep conversation |
| Summarize from here | Compress this message and everything after into a summary |
| Summarize up to here | Compress everything before this message into a summary |
| Never mind | Cancel |

**Limitations:** Only tracks edits from Claude's file tools (not Bash commands, external changes, or other sessions). Not a replacement for git.

### Remote Control

Runs Claude locally; remote devices control via `claude.ai/code` or Claude mobile app. Available on Pro/Max/Team/Enterprise (requires admin enable for Team/Enterprise).

**Start modes:**

| Mode | Command | Use case |
| :--- | :--- | :--- |
| Server | `claude remote-control` | Waits for remote connections; supports multiple sessions |
| Interactive | `claude --remote-control` or `claude --rc` | Full local session also accessible remotely |
| From existing session | `/remote-control` or `/rc` | Continue current session remotely |
| VS Code | `/remote-control` in prompt box | Banner shows connection status |

**Server mode flags:** `--name`, `--spawn same-dir|worktree|session`, `--capacity <N>`, `--verbose`, `--sandbox`/`--no-sandbox`. Press `w` at runtime to toggle between `same-dir` and `worktree`.

Connect from another device via session URL, QR code (press `Space` to toggle), or session list at `claude.ai/code`. Remote sessions show a computer icon with green dot when online.

Enable for all sessions via `/config` → Enable Remote Control for all sessions.

**Push notifications:** Requires Claude mobile app, same account. Enable via `/config` → Push when Claude decides. Requires v2.1.110+.

**Comparison of remote approaches:**

| Feature | Trigger | Claude runs on |
| :--- | :--- | :--- |
| Remote Control | Drive running session from web/mobile | Your machine |
| Channels | Push from chat app or webhook | Your machine |
| Scheduled tasks | Set a schedule | CLI/Desktop/Cloud |

### Scheduled Tasks (`/loop`)

**Three behaviors:**

| Input | Example | Result |
| :--- | :--- | :--- |
| Interval + prompt | `/loop 5m check deploy` | Fixed cron schedule |
| Prompt only | `/loop check deploy` | Claude picks interval dynamically |
| Nothing (or interval only) | `/loop` | Built-in maintenance prompt |

Supported interval units: `s`, `m`, `h`, `d`. Intervals rounded to cron granularity.

**Maintenance prompt scope** (bare `/loop`): continue unfinished work, tend to open PRs (comments, CI, conflicts), cleanup passes. Override with `.claude/loop.md` (project) or `~/.claude/loop.md` (user).

**Cron management tools:** `CronCreate`, `CronList`, `CronDelete`. Session can hold up to 50 tasks. 7-day expiry on recurring tasks.

**Jitter:** Recurring tasks fire up to 30 min after scheduled time (or half the interval). One-shot tasks at `:00` or `:30` fire up to 90s early. Use non-round minute (e.g. `3 9 * * *`) to avoid jitter.

**Stop `/loop`:** Press `Esc` (only for `/loop`-created tasks). Tasks created via natural language remain.

Disable scheduler: `CLAUDE_CODE_DISABLE_CRON=1`

**Cron expressions:** 5-field (`minute hour day-of-month month day-of-week`). Supports `*`, single values, steps (`*/15`), ranges (`1-5`), lists (`1,15,30`).

**Scheduling comparison:**

| | Cloud (Routines) | Desktop | `/loop` |
| :--- | :--- | :--- | :--- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Persistent | Yes | Yes | Restored on `--resume` if unexpired |
| Local files | No (fresh clone) | Yes | Yes |
| Min interval | 1 hour | 1 minute | 1 minute |

### Voice Dictation

Enable: `/voice` (toggle), `/voice hold`, `/voice tap`, `/voice off`. Requires claude.ai account (not available with API keys, Bedrock, Vertex, Foundry). Requires v2.1.69+. Tap mode requires v2.1.116+.

**Hold mode (default):** Hold `Space` to record; brief warmup period. Release to stop and insert transcript at cursor. `"autoSubmit": true` in voice settings to auto-send on release.

**Tap mode:** Tap `Space` to start recording (only when prompt is empty), tap again to stop and auto-send (if transcript ≥ 3 words). 15-second silence timeout, 2-minute max.

Settings:
```json
{
  "voice": { "enabled": true, "mode": "tap" }
}
```

Dictation language follows `language` setting. Rebind `voice:pushToTalk` in `~/.claude/keybindings.json` (context: `"Chat"`). Use modifier combinations (e.g. `meta+k`) to avoid hold-detection warmup.

Supported languages: cs, da, nl, en, fr, de, el, hi, id, it, ja, ko, no, pl, pt, ru, es, sv, tr, uk.

### Channels

Push events from external systems into a running Claude Code session. Claude reacts while you're away. Available in research preview (v2.1.80+); requires claude.ai or Console API key; not available on Bedrock/Vertex/Foundry.

**Supported channel plugins** (require Bun): Telegram, Discord, iMessage, fakechat (demo).

Install: `/plugin install <name>@claude-plugins-official`. Enable per session: `claude --channels plugin:<name>@claude-plugins-official`.

**Security:** Each approved channel plugin maintains a sender allowlist. Telegram/Discord use pairing codes to bootstrap. iMessage: self-messages bypass gate; add others with `/imessage:access allow <handle>`.

**Enterprise controls:**

| Setting | Purpose |
| :--- | :--- |
| `channelsEnabled` | Master switch (Team/Enterprise: off by default) |
| `allowedChannelPlugins` | Restrict which plugins can register (array of `{marketplace, plugin}`) |

### Channels Reference (Building Custom Channels)

A channel is an MCP server declaring `capabilities.experimental['claude/channel']`. It emits `notifications/claude/channel` events with `content` (string) and optional `meta` (object with string values; each becomes a `<channel>` tag attribute).

Events arrive in Claude's context as:
```
<channel source="your-server" key1="val1">content here</channel>
```

**Server constructor options:**

| Field | Type | Description |
| :--- | :--- | :--- |
| `capabilities.experimental['claude/channel']` | `{}` | Required; registers notification listener |
| `capabilities.experimental['claude/channel/permission']` | `{}` | Optional; enables permission relay |
| `capabilities.tools` | `{}` | Required for two-way channels (reply tool) |
| `instructions` | `string` | Added to Claude's system prompt |

**Test during preview:** `claude --dangerously-load-development-channels server:<name>` or `plugin:<name>@<marketplace>`.

**Permission relay:** When declared, Claude Code forwards tool approval prompts to your channel. Inbound `notifications/claude/channel/permission_request` carries `request_id`, `tool_name`, `description`, `input_preview`. Reply with `notifications/claude/channel/permission` carrying `request_id` and `behavior: "allow"|"deny"`.

Gate on sender identity (not room/chat ID) before emitting notifications to prevent prompt injection.

### Desktop Scheduled Tasks

Available in the Desktop app under Routines → New routine → Local.

| Schedule option | Description |
| :--- | :--- |
| Manual | Only runs when you click Run now |
| Hourly | Every hour |
| Daily | Time picker, defaults 9:00 AM |
| Weekdays | Daily except weekends |
| Weekly | Day + time picker |

Tasks run while Desktop app is open and machine is awake. On wake, one catch-up run fires for the most recently missed time (within 7 days). Tasks use their own permission mode; use Run now to pre-approve tools.

Edit task file: `~/.claude/scheduled-tasks/<task-name>/SKILL.md`. Tasks can self-update via `update_scheduled_task` MCP tool.

Enable worktree isolation per task via the worktree toggle when creating.

### Context Window

Key context loading order:
1. System prompt (~4,200 tokens, invisible)
2. Auto memory/MEMORY.md (first 200 lines or 25KB)
3. Environment info (cwd, platform, etc.)
4. MCP tool names (schemas deferred via tool search)
5. Skill descriptions (all model-invocable skills; not re-injected after `/compact`)
6. `~/.claude/CLAUDE.md` (user-level)
7. Project CLAUDE.md
8. Your prompts and Claude's work accumulate from there

**What survives `/compact`:**

| Mechanism | After compaction |
| :--- | :--- |
| System prompt and output style | Unchanged |
| Project-root CLAUDE.md and unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | Lost until matching file is read again |
| Nested CLAUDE.md in subdirectories | Lost until file in that dir is read again |
| Invoked skill bodies | Re-injected; capped at 5K tokens/skill, 25K total; oldest dropped first |

Check live context: `/context`. Check memory files: `/memory`.

### Fullscreen TUI Rendering

Enable with `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1`. Disable with `/tui default` or `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1`. Requires v2.1.89+.

Benefits: eliminates flicker, flat memory in long conversations, mouse support, input stays fixed at bottom.

**Mouse actions:**
- Click in prompt → position cursor
- Click collapsed tool result → expand/collapse
- Click URL/file path → open
- Click and drag → select text (copies on release)
- Mouse wheel → scroll

**Scroll shortcuts:**

| Shortcut | Action |
| :--- | :--- |
| `PgUp`/`PgDn` | Scroll half screen |
| `Ctrl+Home` | Jump to start |
| `Ctrl+End` | Jump to latest, resume auto-follow |

**Search/transcript mode:** `Ctrl+O` toggles transcript mode with `less`-style navigation (`/` to search, `n`/`N` for next/prev match). Press `[` to write conversation to terminal scrollback. Press `v` to open in `$EDITOR`.

Adjust scroll speed: `CLAUDE_CODE_SCROLL_SPEED=3` or `/scroll-speed` command.

Disable mouse capture only: `CLAUDE_CODE_DISABLE_MOUSE=1`

tmux: requires `set -g mouse on`. Incompatible with `tmux -CC` integration mode.

Auto-follow: scrolling up pauses it. Disable entirely via `/config` → Auto-scroll.

Clear conversation: `Ctrl+L` twice within 2 seconds (or double `Cmd+K` on macOS).

### Routines (Cloud Automation)

Saved Claude Code configs (prompt + repos + connectors) that run on Anthropic-managed cloud. Three trigger types: scheduled, API, or GitHub events. Available on Pro/Max/Team/Enterprise with Claude Code on the web enabled.

Manage at `claude.ai/code/routines` or via `/schedule` in CLI.

**Trigger types:**

| Type | Setup | Use case |
| :--- | :--- | :--- |
| Schedule | Pick preset or cron via `/schedule update` (min 1 hour) | Recurring maintenance |
| API | POST to per-routine endpoint with bearer token | Alert systems, deploy pipelines |
| GitHub | PR or Release events with optional filters | Automated code review |

**API trigger:** `POST` to endpoint with `Authorization: Bearer <token>` header. Optional `text` field for run-specific context. Returns session ID and URL. Beta header: `anthropic-beta: experimental-cc-routine-2026-04-01`.

**GitHub filter fields for PRs:** Author, Title, Body, Base branch, Head branch, Labels, Is draft, Is merged. Operators: equals, contains, starts with, is one of, is not one of, matches regex.

**Branch permissions:** By default Claude only pushes to `claude/`-prefixed branches. Enable "Allow unrestricted branch pushes" per repo for full access.

**One-off runs:** Don't count against daily routine cap. Created with natural language like `/schedule tomorrow at 9am, summarize merged PRs`.

Routines belong to individual accounts. Connectors = claude.ai integrations (not local `claude mcp add` servers). Default environment uses Trusted network access (approved registries/APIs only).

### Deep Links

`claude-cli://` custom URL scheme opens Claude Code in a new terminal window with optional directory and pre-filled prompt.

**URL format:** `claude-cli://open?q=<encoded-prompt>&cwd=<abs-path>&repo=<owner/name>`

| Parameter | Description |
| :--- | :--- |
| `q` | URL-encoded prompt text (max 5,000 chars; `%0A` for newlines) |
| `cwd` | Absolute path working directory (takes precedence over `repo`) |
| `repo` | GitHub `owner/name` slug; resolves to most recently used local clone |

`repo` only resolves to paths where you've already run `claude` once. Link opens in the same state the clone is in (does not switch branches).

Prompt is populated but not sent until user presses Enter. A banner shows the link launched the session.

**Registration:** Automatic on first interactive session. Location:
- macOS: `~/Applications/Claude Code URL Handler.app`
- Linux: `~/.local/share/applications/claude-code-url-handler.desktop`
- Windows: `HKEY_CURRENT_USER\Software\Classes\claude-cli`

Disable: `"disableDeepLinkRegistration": "disable"` in settings.

Note: GitHub Markdown strips `claude-cli://` schemes; put links in code blocks on GitHub.

VS Code uses `vscode://anthropic.claude-code/open` instead (opens an editor tab).

### Agent View (`claude agents`)

One screen for all background sessions. Research preview; requires v2.1.139+.

**Open:** `claude agents` (shows all projects) or `claude agents --cwd <path>` (scope to directory).

**Session state icons:**

| State | Icon | Meaning |
| :--- | :--- | :--- |
| Working | Animated | Actively running tools or generating |
| Needs input | Yellow | Waiting on a question or permission |
| Idle | Dimmed | Ready for next prompt |
| Completed | Green | Task finished |
| Failed | Red | Ended with error |
| Stopped | Grey | Stopped with `Ctrl+X` or `claude stop` |

**Process shape:**
- `✻` / animated `✽` — process alive, responds immediately
- `∙` — process exited; restarts from saved state when you interact
- `✢` — `/loop` session sleeping between iterations

**Key shortcuts:**

| Shortcut | Action |
| :--- | :--- |
| `Space` | Open/close peek panel |
| `Enter` / `→` | Attach to session |
| `←` (empty prompt) | Detach and return to agent view |
| `Ctrl+X` | Stop session; press again within 2s to delete |
| `Ctrl+T` | Pin/unpin session |
| `Ctrl+R` | Rename session |
| `Ctrl+S` | Toggle grouping (state vs directory) |
| `?` | Show all shortcuts |

**Dispatch from CLI:** `claude --bg "<prompt>"`, optionally with `--agent`, `--name`, `--model`.

**File isolation:** Each background session auto-moves to an isolated git worktree under `.claude/worktrees/` before editing. Outside git repos, no isolation.

**Shell commands:**

| Command | Purpose |
| :--- | :--- |
| `claude agents` | Open agent view |
| `claude attach <id>` | Attach in this terminal |
| `claude logs <id>` | Show recent output |
| `claude stop <id>` | Stop a session |
| `claude respawn <id>` | Restart stopped session |
| `claude respawn --all` | Restart all stopped sessions |
| `claude rm <id>` | Remove session (cleans up worktree if no uncommitted changes) |

**Supervisor process:** Runs background sessions independently of any terminal. Auto-starts; survives Claude Code updates. State in `~/.claude/daemon.log`, `~/.claude/daemon/roster.json`, `~/.claude/jobs/<id>/`.

Disable: `"disableAgentView": true` in settings or `CLAUDE_CODE_DISABLE_AGENT_VIEW=1`.

### Running Agents in Parallel

| Approach | Use it when |
| :--- | :--- |
| Subagents | Side task would flood main conversation; only result matters |
| Agent view | Multiple independent tasks; hand off and check back at a glance |
| Agent teams | Claude should plan, assign, and supervise workers (experimental) |
| Worktrees | Parallel sessions or subagents edit overlapping files |
| `/batch` | Repo-wide migration; splits into 5–30 worktree-isolated subagents |

**Check running work:**
- Background sessions: `claude agents` (agent view)
- Subagents in current session: `/agents` (Running tab)
- Background tasks in current session: `/tasks`

### Worktrees

Create an isolated git worktree session: `claude --worktree <name>` or `claude -w <name>`. Creates `.claude/worktrees/<name>/` on branch `worktree-<name>`. Omit name for auto-generated one.

**Base branch:**
- Default: `origin/HEAD` (remote default branch)
- Local HEAD: set `"worktree": {"baseRef": "head"}` in settings
- Specific PR: `claude --worktree "#1234"` (fetches `pull/1234/head`)
- Custom: configure `WorktreeCreate` hook

**Copy gitignored files:** `.worktreeinclude` in project root (`.gitignore` syntax). Only copies gitignored files matching a pattern.

**Cleanup:**
- No changes: worktree and branch removed automatically
- Changes present: Claude prompts to keep or remove
- Non-interactive (`-p`): not auto-cleaned; use `git worktree remove`

Subagent worktrees older than `cleanupPeriodDays` (with no changes) are swept at startup.

**Non-git VCS:** Configure `WorktreeCreate` and `WorktreeRemove` hooks to replace default git behavior.

**Isolate subagents:** Set `isolation: worktree` in subagent frontmatter, or ask Claude to "use worktrees for your agents".

## Full Documentation

For the complete official documentation, see the reference files:

- [Features overview](references/claude-code-features-overview.md) — when to use CLAUDE.md vs skills vs subagents vs MCP vs hooks vs plugins
- [Fast mode](references/claude-code-fast-mode.md) — 2.5x faster Opus, toggling, cost tradeoff, requirements, per-session opt-in
- [Model configuration](references/claude-code-model-config.md) — model aliases, effort levels, extended thinking, 1M context, third-party pinning
- [Output styles](references/claude-code-output-styles.md) — built-in styles, creating custom styles, frontmatter fields
- [Status line](references/claude-code-statusline.md) — configuring a custom status bar, available JSON fields, examples
- [Checkpointing](references/claude-code-checkpointing.md) — automatic tracking, rewind and summarize options, limitations
- [Remote control](references/claude-code-remote-control.md) — server mode, interactive mode, mobile app, push notifications
- [Scheduled tasks](references/claude-code-scheduled-tasks.md) — `/loop` command, cron tools, maintenance prompt, loop.md customization
- [Voice dictation](references/claude-code-voice-dictation.md) — hold mode, tap mode, language settings, keybinding customization
- [Channels](references/claude-code-channels.md) — Telegram/Discord/iMessage setup, security allowlists, enterprise controls
- [Channels reference](references/claude-code-channels-reference.md) — building custom channel MCP servers, webhook receiver example, reply tools, permission relay
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) — Routines UI, schedule options, permissions, missed runs
- [Context window](references/claude-code-context-window.md) — interactive visualization, what loads when, what survives compaction
- [Fullscreen rendering](references/claude-code-fullscreen.md) — flicker-free TUI, mouse support, scroll shortcuts, transcript mode, tmux notes
- [Routines](references/claude-code-routines.md) — cloud automation, schedule/API/GitHub triggers, connectors, network access, usage limits
- [Deep links](references/claude-code-deep-links.md) — `claude-cli://` URL scheme, URL parameters, platform registration
- [Agent view](references/claude-code-agent-view.md) — `claude agents`, monitoring background sessions, dispatch, keyboard shortcuts, supervisor process
- [Run agents in parallel](references/claude-code-agents.md) — comparison of subagents vs agent view vs agent teams vs worktrees vs `/batch`
- [Worktrees](references/claude-code-worktrees.md) — `--worktree` flag, base branch, `.worktreeinclude`, cleanup, non-git VCS hooks

## Sources

- Features overview: https://code.claude.com/docs/en/features-overview.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Context window: https://code.claude.com/docs/en/context-window.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
- Routines: https://code.claude.com/docs/en/routines.md
- Deep links: https://code.claude.com/docs/en/deep-links.md
- Agent view: https://code.claude.com/docs/en/agent-view.md
- Run agents in parallel: https://code.claude.com/docs/en/agents.md
- Worktrees: https://code.claude.com/docs/en/worktrees.md
