---
name: features-doc
description: Complete official documentation for Claude Code features — fast mode, model configuration, output styles, status line, checkpointing, remote control, scheduled tasks, voice dictation, channels, context window, fullscreen rendering, routines, deep links, agent view, parallel agents, worktrees, and the features overview.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features.

## Quick Reference

### Feature Overview: Extension Points

| Feature | What it does | When to use it |
| :--- | :--- | :--- |
| **CLAUDE.md** | Persistent context loaded every session | Project conventions, "always do X" rules |
| **Skills** | Instructions, knowledge, and workflows Claude can use | Reusable content, reference docs, repeatable tasks |
| **Subagents** | Isolated execution returning a summary | Context isolation, parallel tasks |
| **Agent teams** | Coordinated independent sessions | Parallel research, competing hypotheses (experimental) |
| **MCP** | Connect to external services | External data or actions |
| **Hooks** | Script/HTTP/prompt/subagent on lifecycle events | Automation that must run on every matching event |
| **Plugins** | Bundle skills, hooks, MCP into one installable unit | Reuse setup across repos or distribute to others |

Context costs: CLAUDE.md (every request), Skills (descriptions at start, content on use), MCP (deferred until used), Subagents (isolated), Hooks (zero unless they return output).

### Model Configuration

**Model aliases:**

| Alias | Behavior |
| :--- | :--- |
| `default` | Clears override, reverts to recommended model for account type |
| `best` | Most capable available (currently Opus) |
| `sonnet` | Latest Sonnet for daily coding tasks |
| `opus` | Latest Opus for complex reasoning |
| `haiku` | Fast, efficient Haiku for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus for plan mode, switches to Sonnet for execution |

**Default model by plan:** Max/Team Premium → Opus 4.7; Pro/Team Standard/Enterprise/API → Sonnet 4.6; Bedrock/Vertex/Foundry → Sonnet 4.5.

**Set model** (priority order): `/model <alias>` in session → `--model` at startup → `ANTHROPIC_MODEL` env var → `model` in settings file.

**Effort levels** (Opus 4.7: `low`/`medium`/`high`/`xhigh`/`max`; Opus 4.6 and Sonnet 4.6: `low`/`medium`/`high`/`max`):

| Level | When to use |
| :--- | :--- |
| `low` | Latency-sensitive, not intelligence-sensitive |
| `medium` | Cost-sensitive, can trade off some intelligence |
| `high` | Balance token usage and intelligence |
| `xhigh` | Best for most coding and agentic tasks (Opus 4.7 default) |
| `max` | Demanding tasks; test before adopting broadly |

Set effort via `/effort`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL`, `effortLevel` in settings, or `effort:` in skill/subagent frontmatter.

Use `ultrathink` in a prompt for one-off deep reasoning without changing the session effort level.

**Extended context (1M tokens):** Included for Max/Team/Enterprise on Opus; requires extra usage for Sonnet and Pro. Use `[1m]` suffix: `/model opus[1m]`.

**Env vars for model aliases:** `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL`, `CLAUDE_CODE_SUBAGENT_MODEL`.

**Extended thinking:** Toggle `Option+T` (macOS) or `Alt+T` (Win/Linux); set global default via `/config`; disable with `MAX_THINKING_TOKENS=0`.

### Fast Mode

Fast mode makes Claude Opus 2.5x faster at higher cost per token.

| Mode | Input (MTok) | Output (MTok) |
| :--- | :--- | :--- |
| Fast mode (Opus 4.6 or 4.7) | $30 | $150 |

- Toggle: `/fast` or `"fastMode": true` in settings. Shows `↯` icon when active.
- Default model: Opus 4.6. Set `CLAUDE_CODE_ENABLE_OPUS_4_7_FAST_MODE=1` for Opus 4.7 (becomes default on 2026-05-14).
- Requires extra usage enabled; not available on Bedrock/Vertex/Foundry.
- Rate limits: Opus 4.6 and 4.7 share the same fast mode pool; falls back to standard speed on limit.
- Org controls: `fastModePerSessionOptIn: true` in managed settings forces per-session opt-in. Disable entirely with `CLAUDE_CODE_DISABLE_FAST_MODE=1`.
- Requires Claude Code v2.1.36+.

### Output Styles

Modify the system prompt to change role, tone, and response format.

**Built-in styles:** `Default`, `Proactive` (acts without asking), `Explanatory` (adds Insights), `Learning` (collaborative, adds `TODO(human)` markers).

**Custom output style file format:**

```markdown
---
name: My Style
description: What it does
keep-coding-instructions: true
---
Instructions added to the system prompt.
```

- Save at `~/.claude/output-styles/` (user), `.claude/output-styles/` (project), or managed policy directory.
- Set via `/config` > Output style or `outputStyle` in settings.
- Takes effect on next session start (not mid-conversation).
- Plugins can ship output styles with `force-for-plugin: true` to apply automatically.

### Status Line

A shell script that runs on every assistant message, receiving JSON on stdin and printing one or more lines to display.

**Settings config:**

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

Use `/statusline <description>` to have Claude generate a script automatically.

**Key JSON fields available to the script:**

| Field | Description |
| :--- | :--- |
| `model.id`, `model.display_name` | Current model |
| `workspace.current_dir`, `workspace.project_dir` | Working dirs |
| `workspace.git_worktree` | Git worktree name (if in a linked worktree) |
| `cost.total_cost_usd` | Estimated session cost |
| `cost.total_duration_ms` | Total wall-clock time |
| `context_window.used_percentage` | Context usage % |
| `context_window.context_window_size` | Max context (200K or 1M) |
| `effort.level` | Current effort level |
| `thinking.enabled` | Extended thinking on/off |
| `rate_limits.five_hour.used_percentage` | 5-hour limit usage (Pro/Max only) |
| `rate_limits.seven_day.used_percentage` | 7-day limit usage |
| `session_id`, `session_name` | Session identifiers |
| `output_style.name` | Active output style |
| `vim.mode` | Vim mode (if enabled) |
| `worktree.name`, `worktree.branch` | Worktree info (--worktree sessions only) |

Updates after each assistant message, after `/compact`, on permission mode change, on vim mode toggle. Debounced at 300ms.

Set `subagentStatusLine` to customize per-subagent row formatting in agent view.

### Checkpointing

Claude Code automatically tracks file edits before each prompt.

- Every user prompt creates a checkpoint; persists across sessions; auto-cleaned after 30 days.
- Open rewind menu: `Esc Esc` or `/rewind`.

**Rewind actions:**

| Action | Effect |
| :--- | :--- |
| Restore code and conversation | Revert both files and conversation |
| Restore conversation | Rewind conversation, keep current code |
| Restore code | Revert files, keep conversation |
| Summarize from here | Compress conversation from selected point forward |
| Summarize up to here | Compress conversation before selected point |

Note: bash command file changes (rm, mv, cp) and external edits are NOT tracked. Use git for permanent version history.

### Remote Control

Continue a local session from any device via claude.ai/code or the Claude mobile app.

**Start modes:**

| Mode | Command | Use |
| :--- | :--- | :--- |
| Server mode | `claude remote-control` | Persistent server, multiple connections |
| Interactive | `claude --remote-control` | Full local session + remote access |
| From existing session | `/remote-control` | Add remote access to current session |

**Server mode flags:** `--name`, `--spawn same-dir|worktree|session`, `--capacity <N>`, `--verbose`, `--sandbox`.

**Connect from another device:** Open the session URL, scan the QR code (press spacebar to show), or find the session in claude.ai/code or the Claude mobile app.

- Enable for all sessions: `/config` > Enable Remote Control for all sessions.
- Requires claude.ai subscription (Pro/Max/Team/Enterprise); not available with API keys.
- Mobile push notifications: requires Claude Code v2.1.110+; enable via `/config` > Push when Claude decides.
- Requires Claude Code v2.1.51+.

**Remote vs web:** Remote Control runs on your machine (local files/MCP/tools stay available). Claude Code on the web runs on Anthropic cloud.

### Scheduled Tasks (In-Session)

`/loop` runs a prompt on a schedule within the current session.

| What you provide | Example | What happens |
| :--- | :--- | :--- |
| Interval + prompt | `/loop 5m check the deploy` | Prompt runs on fixed schedule |
| Prompt only | `/loop check the deploy` | Claude chooses interval dynamically |
| Nothing | `/loop` | Built-in maintenance prompt (continue work, tend PR, cleanup) |

- Supported units: `s`, `m`, `h`, `d`. Cron granularity is 1 minute.
- Session-scoped: tasks stop on new conversation; `--resume` restores unexpired tasks.
- Seven-day expiry on recurring tasks; auto-deletes one-shot tasks after firing.
- Stop a loop: press `Esc` while waiting.
- Customize default loop prompt: `.claude/loop.md` (project) or `~/.claude/loop.md` (user).
- Disable: `CLAUDE_CODE_DISABLE_CRON=1`.
- Max 50 scheduled tasks per session.
- Tools: `CronCreate`, `CronList`, `CronDelete`.

**Cron expression examples:** `*/5 * * * *` (every 5m), `0 9 * * 1-5` (weekdays 9am), `0 9 * * *` (daily 9am local).

### Desktop Scheduled Tasks

Scheduled tasks in Claude Code Desktop run on your machine while the app is open.

| Setting | Cloud Routines | Desktop Tasks | /loop |
| :--- | :--- | :--- | :--- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Min interval | 1 hour | 1 minute | 1 minute |
| Local file access | No | Yes | Yes |

Create via Routines sidebar > New routine > Local. Task file stored at `~/.claude/scheduled-tasks/<task-name>/SKILL.md`.

### Voice Dictation

Speak prompts instead of typing them in the Claude Code CLI.

- Enable: `/voice` (toggle). Modes: `/voice hold` (hold Space), `/voice tap` (tap to start/send).
- Requires claude.ai account authentication (not API key); local microphone access required.
- Persists across sessions; disable with `/voice off` or `"voice": {"enabled": false}` in settings.
- Transcription vocabulary includes coding terms, project name, and git branch automatically.
- Change language: `"language": "japanese"` in settings (default: English).
- Rebind key: set `voice:pushToTalk` in `~/.claude/keybindings.json`.
- Supported languages: cs, da, nl, en, fr, de, el, hi, id, it, ja, ko, no, pl, pt, ru, es, sv, tr, uk.
- Requires Claude Code v2.1.69+; tap mode requires v2.1.116+.

### Channels

Push events from Telegram, Discord, iMessage, or custom webhooks into a running Claude Code session.

- Channels are MCP servers with `capabilities.experimental['claude/channel']: {}`.
- Start with channels: `claude --channels plugin:telegram@claude-plugins-official`.
- Supported: Telegram, Discord, iMessage, fakechat (localhost demo).
- All require Bun to be installed; install plugins with `/plugin install <name>@claude-plugins-official`.
- Security: every channel uses a sender allowlist; pair with `/telegram:access pair <code>` or similar.
- Enterprise controls: `channelsEnabled` (master switch), `allowedChannelPlugins` (restrict which plugins).
- Research preview; requires claude.ai auth or Console API key; not available on Bedrock/Vertex/Foundry.
- Requires Claude Code v2.1.80+.

**Channel event format in Claude's context:**

```
<channel source="webhook" severity="high" run_id="1234">
build failed on main: https://ci.example.com/run/1234
</channel>
```

**Permission relay:** Declare `capabilities.experimental['claude/channel/permission']: {}` to forward tool approval prompts to remote channel. Reply `yes <id>` or `no <id>`.

### Context Window

What loads into context before and during a session:

| Mechanism | Loads when | After /compact |
| :--- | :--- | :--- |
| System prompt and output style | Session start | Unchanged |
| CLAUDE.md (project root) | Session start | Re-injected from disk |
| Auto memory | Session start | Re-injected from disk |
| Rules with `paths:` | Matching file is read | Lost until matching file read again |
| Nested CLAUDE.md | File in that subdirectory read | Lost until matching file read again |
| Skill descriptions | Session start | Not re-injected (only invoked skill bodies) |
| MCP tool names | Session start, schemas deferred | Reloaded |
| Invoked skill bodies | When invoked | Re-injected (capped 5K/skill, 25K total) |
| Hooks | On trigger | Not applicable (code, not context) |

Run `/context` for live context usage breakdown. Run `/memory` to check loaded CLAUDE.md and auto memory files.

### Fullscreen Rendering

Alternative rendering mode using the terminal's alternate screen buffer (like vim/htop).

- Enable: `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1`.
- Disable: `/tui default` or `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1`.
- Benefits: no flicker, flat memory in long conversations, mouse support.

**Key capabilities:**
- Click collapsed tool result to expand/collapse.
- Click URLs/file paths to open.
- Click-and-drag to select; auto-copies to clipboard on release.
- `Ctrl+O`: toggle transcript mode (search with `/`, write to scrollback with `[`, open in editor with `v`).
- `PgUp`/`PgDn` or `Fn+↑/↓` to scroll; `Ctrl+Home`/`Ctrl+End` to jump to start/end.
- Set scroll speed: `CLAUDE_CODE_SCROLL_SPEED=3` or `/scroll-speed`.
- Disable mouse capture only: `CLAUDE_CODE_DISABLE_MOUSE=1`.
- `Ctrl+L` twice to `/clear`.
- Research preview; requires v2.1.89+.

### Routines (Cloud Scheduled Tasks)

Routines run on Anthropic-managed cloud infrastructure on a schedule, API call, or GitHub event.

**Trigger types:**

| Trigger | How to configure |
| :--- | :--- |
| Schedule | Hourly/daily/weekdays/weekly presets; `/schedule update` for custom cron (min 1 hour) |
| API | POST to per-routine endpoint with bearer token; optional `text` payload |
| GitHub | On `pull_request` or `release` events; filter by author, title, branch, labels, draft, merged |

- Create: `claude.ai/code/routines` or `/schedule` in CLI.
- API trigger: POST to `https://api.anthropic.com/v1/claude_code/routines/<id>/fire` with `Authorization: Bearer <token>` and `anthropic-beta: experimental-cc-routine-2026-04-01`.
- Runs run against a fresh clone of specified repositories; Claude creates `claude/`-prefixed branches by default.
- All connected MCP connectors included by default; remove unneeded ones.
- One-off runs: not counted against daily routine cap.
- Research preview; behavior, limits, and API surface may change.

### Deep Links

`claude-cli://` URLs that open Claude Code in a new terminal with a pre-filled prompt.

**Link format:**

```
claude-cli://open?repo=owner/name&q=URL-encoded+prompt+text
```

| Parameter | Description |
| :--- | :--- |
| `q` | Prompt text (URL-encoded, max 5,000 chars, `%0A` for newlines) |
| `cwd` | Absolute working directory path |
| `repo` | GitHub `owner/name` slug (resolves to most recently used local clone) |

- If both `cwd` and `repo` are set, `cwd` takes precedence.
- A banner shows the link source; prompt is not sent until you press Enter.
- Registered automatically on first interactive session; disable with `disableDeepLinkRegistration: "disable"` in settings.
- GitHub Markdown strips `claude-cli://` from rendered links (only `http/https` allowed).
- VS Code extension: `vscode://anthropic.claude-code/open` opens a tab instead of terminal.
- Requires Claude Code v2.1.91+.

### Agent View

`claude agents` — one screen for all background sessions.

**Session states:**

| State | Icon | Meaning |
| :--- | :--- | :--- |
| Working | Animated | Claude is running tools or generating a response |
| Needs input | Yellow | Waiting on a question or permission decision |
| Idle | Dimmed | Ready for next prompt |
| Completed | Green | Task finished successfully |
| Failed | Red | Task ended with an error |
| Stopped | Grey | Stopped with Ctrl+X or `claude stop` |

**Key keyboard shortcuts:**

| Shortcut | Action |
| :--- | :--- |
| `Space` | Open/close peek panel |
| `Enter` or `→` | Attach to session |
| `←` (empty prompt) | Background current session, open agent view |
| `Ctrl+X` | Stop session; again within 2s to delete |
| `Ctrl+T` | Pin/unpin session |
| `Ctrl+R` | Rename session |
| `Ctrl+S` | Toggle grouping (state vs directory) |
| `?` | Show all shortcuts |

**Dispatch from agent view:** Type prompt + Enter. Prefix with agent name or `@<agent-name>` to use a custom subagent; `@<repo>` to target a different repo.

**Shell commands:** `claude --bg "<prompt>"`, `claude attach <id>`, `claude logs <id>`, `claude stop <id>`, `claude respawn <id>`, `claude rm <id>`.

**File isolation:** Background sessions auto-move into an isolated git worktree under `.claude/worktrees/` before editing files.

**Settings:** `disableAgentView: true` or `CLAUDE_CODE_DISABLE_AGENT_VIEW` to turn off entirely.

- Research preview; requires v2.1.139+.

### Parallel Agents Comparison

| Approach | Coordinates | Workers talk? | File isolation |
| :--- | :--- | :--- | :--- |
| Subagents | You (inside session) | Back to main only | Per-subagent worktree optional |
| Agent view | You (from agent view) | Back to you only | Auto worktree per session |
| Agent teams | Claude (lead + teammates) | Directly with each other | None (partition files manually) |
| Worktrees | You | None | Yes (separate git checkout) |
| `/batch` | Claude | None | Yes (worktree per subagent) |

### Worktrees

Separate git checkouts so parallel sessions never touch each other's files.

- Start: `claude --worktree <name>` (or `-w`). Creates `.claude/worktrees/<name>/` on branch `worktree-<name>`.
- Default base: `origin/HEAD`. Set `worktree.baseRef: "head"` in settings to branch from local HEAD instead.
- Branch from a PR: `claude --worktree "#1234"`.
- Copy gitignored files into worktrees: add `.worktreeinclude` file at project root (gitignore syntax).
- Isolate subagents: set `isolation: worktree` in subagent frontmatter.
- Clean up: automatic on exit if no uncommitted changes; or `git worktree remove <path>`.
- Non-git VCS: configure `WorktreeCreate` and `WorktreeRemove` hooks.
- Add `.claude/worktrees/` to `.gitignore`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Features overview](references/claude-code-features-overview.md) — when to use CLAUDE.md vs skills vs subagents vs agent teams vs MCP vs hooks; context costs by feature; how features layer and combine
- [Fast mode](references/claude-code-fast-mode.md) — toggle, Opus 4.7 opt-in, pricing, rate limits, per-session opt-in, requirements
- [Model configuration](references/claude-code-model-config.md) — model aliases, effort levels, extended thinking, extended context, env vars, third-party pinning, `modelOverrides`, prompt caching config
- [Output styles](references/claude-code-output-styles.md) — built-in styles, creating custom styles, frontmatter fields, how styles affect the system prompt
- [Status line](references/claude-code-statusline.md) — setup, available JSON data fields, example scripts (context bar, git status, cost tracking, multi-line, rate limits, caching), subagent status line, troubleshooting
- [Checkpointing](references/claude-code-checkpointing.md) — automatic tracking, rewind menu actions, summarize options, limitations
- [Remote Control](references/claude-code-remote-control.md) — server mode, interactive mode, VS Code, connecting from another device, security model, mobile push notifications, troubleshooting
- [Scheduled tasks (in-session)](references/claude-code-scheduled-tasks.md) — /loop modes, one-time reminders, CronCreate/List/Delete tools, cron expression reference, jitter, seven-day expiry
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) — creating tasks, schedule options, permissions, catch-up runs, managing tasks
- [Voice dictation](references/claude-code-voice-dictation.md) — hold mode, tap mode, language settings, rebinding, troubleshooting
- [Channels](references/claude-code-channels.md) — Telegram/Discord/iMessage setup, fakechat quickstart, security/allowlists, enterprise controls
- [Channels reference](references/claude-code-channels-reference.md) — building a custom channel, webhook receiver example, server options, notification format, reply tool, sender gating, permission relay
- [Context window](references/claude-code-context-window.md) — interactive simulation, what loads when, what survives compaction, /context and /memory commands
- [Fullscreen rendering](references/claude-code-fullscreen.md) — enable/disable, mouse support, scrolling, transcript mode, tmux usage, native text selection
- [Routines](references/claude-code-routines.md) — create from web/CLI, schedule/API/GitHub triggers, managing runs, connector and environment config, usage limits
- [Deep links](references/claude-code-deep-links.md) — URL format, cwd vs repo parameters, shell usage, handler registration, troubleshooting
- [Agent view](references/claude-code-agent-view.md) — monitoring sessions, peek/reply, attach/detach, dispatching, shell commands, supervisor process, file isolation
- [Run agents in parallel](references/claude-code-agents.md) — comparing subagents vs agent view vs agent teams vs worktrees vs /batch
- [Worktrees](references/claude-code-worktrees.md) — --worktree flag, base branch config, .worktreeinclude, subagent isolation, cleanup, non-git VCS hooks

## Sources

- Features overview: https://code.claude.com/docs/en/features-overview.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks (in-session): https://code.claude.com/docs/en/scheduled-tasks.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Context window: https://code.claude.com/docs/en/context-window.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
- Routines: https://code.claude.com/docs/en/routines.md
- Deep links: https://code.claude.com/docs/en/deep-links.md
- Agent view: https://code.claude.com/docs/en/agent-view.md
- Run agents in parallel: https://code.claude.com/docs/en/agents.md
- Worktrees: https://code.claude.com/docs/en/worktrees.md
