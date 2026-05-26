---
name: features-doc
description: Complete official documentation for Claude Code features — extension overview (CLAUDE.md, skills, MCP, subagents, hooks, plugins), model configuration and aliases, fast mode, effort levels, extended context, output styles, status line, checkpointing/rewind, remote control, scheduled tasks, routines, channels, voice dictation, fullscreen rendering, worktrees, agent view, prompt caching, deep links, and context window visualization.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code's features and configuration options.

## Quick Reference

### Extension Overview: Match Feature to Goal

| Feature | What it does | When to use it |
| :--- | :--- | :--- |
| **CLAUDE.md** | Persistent context loaded every session | Project conventions, "always do X" rules |
| **Skill** | Instructions, knowledge, workflows | Reusable reference docs, repeatable tasks triggered with `/name` |
| **Subagent** | Isolated worker, returns summary | Context isolation, parallel tasks, side work that would flood main session |
| **Agent teams** | Multiple coordinated sessions with shared task list | Complex parallel work needing inter-agent discussion |
| **Code intelligence** | Language-server navigation and diagnostics | Typed languages, large codebases |
| **MCP** | Connect to external services | External data or actions (databases, Slack, browser) |
| **Hook** | Script/HTTP/prompt/agent on lifecycle events | Automation that must run every time (lint, block unsafe cmds) |
| **Plugin** | Bundle skills, hooks, agents, MCP into one installable | Reuse setup across multiple repos or distribute to others |

Context costs: CLAUDE.md (always loaded); skills (descriptions at start, full content on use); MCP tool names at start, schemas deferred; hooks run externally — zero cost unless returning output; subagents isolated from main context.

### CLAUDE.md vs Skill vs Rules

| Aspect | CLAUDE.md | `.claude/rules/` | Skill |
| :--- | :--- | :--- | :--- |
| Loads | Every session | Every session (or on path match) | On demand |
| Scope | Whole project | Can be path-scoped | Task-specific |
| Best for | Core conventions, build commands | Language/directory guidelines | Reference material, workflows |

Rule of thumb: keep CLAUDE.md under 200 lines; move reference content to skills.

### Model Configuration

| Alias | Resolves to |
| :--- | :--- |
| `default` | Clears override; uses subscription default |
| `best` | Most capable model (currently Opus) |
| `sonnet` | Latest Sonnet (4.6 on Anthropic API; 4.5 on Bedrock/Vertex/Foundry) |
| `opus` | Latest Opus (4.7 on Anthropic API; 4.6 on Bedrock/Vertex/Foundry) |
| `haiku` | Fast, efficient Haiku |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus during plan mode, switches to Sonnet for execution |

Set model: `/model <alias>`, `--model` flag, `ANTHROPIC_MODEL` env var, or `model` in settings (lowest priority). As of v2.1.144, `/model` applies to current session only; press `d` in picker to save to user settings.

Default model by plan:
- Max and Team Premium: Opus 4.7
- Pro, Team Standard, Enterprise, API: Sonnet 4.6
- Bedrock, Vertex, Foundry: Sonnet 4.5

### Effort Levels

| Level | When to use |
| :--- | :--- |
| `low` | Latency-sensitive tasks, not intelligence-sensitive |
| `medium` | Cost-sensitive work, some quality trade-off acceptable |
| `high` | Minimum for intelligence-sensitive work |
| `xhigh` | Best for most coding and agentic tasks (default on Opus 4.7) |
| `max` | Demanding tasks; session-only, not saved to settings |

Set with `/effort <level>`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL`, or `effortLevel` in settings. Use `ultrathink` keyword in a prompt for one-off deep reasoning without changing effort level.

Supported models: Opus 4.7 (`low`/`medium`/`high`/`xhigh`/`max`); Opus 4.6 and Sonnet 4.6 (`low`/`medium`/`high`/`max`).

### Fast Mode

Fast mode makes Opus 2.5x faster at higher per-token cost ($30/$150 MTok input/output). Toggle with `/fast` or set `"fastMode": true` in settings. Requires Opus 4.7 or 4.6. Only available via Anthropic API/Console (not Bedrock, Vertex, Foundry). Requires usage credits on subscription plans. `↯` icon shows in prompt when active. Admin can set `fastModePerSessionOptIn: true` to require opt-in each session.

### Extended Context (1M)

Opus 4.7, 4.6, and Sonnet 4.6 support 1M token context. On Max/Team/Enterprise: Opus 1M included with subscription; Sonnet 1M requires usage credits. On Pro: both require usage credits. On API: full access. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`. Use `opus[1m]` or `claude-opus-4-7[1m]` alias.

### Output Styles

| Style | Effect |
| :--- | :--- |
| Default | Standard software engineering system prompt |
| Proactive | Executes immediately, makes assumptions, prefers action |
| Explanatory | Adds educational "Insights" alongside engineering help |
| Learning | Collaborative; adds `TODO(human)` markers for you to implement |

Set via `/config` → Output style. Saved to `.claude/settings.local.json`. Takes effect after `/clear` or new session. Custom styles: Markdown files in `~/.claude/output-styles` or `.claude/output-styles`. Frontmatter: `name`, `description`, `keep-coding-instructions` (default `false`), `force-for-plugin`.

### Status Line

Customizable bar at bottom of Claude Code. Configure in `~/.claude/settings.json`:

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

Script receives JSON on stdin. Key fields available: `model.display_name`, `workspace.current_dir`, `workspace.project_dir`, `workspace.repo.{host,owner,name}`, `cost.total_cost_usd`, `cost.total_duration_ms`, `context_window.used_percentage`, `context_window.context_window_size`, `effort.level`, `thinking.enabled`, `rate_limits.five_hour.used_percentage`, `rate_limits.seven_day.used_percentage`, `session_id`, `session_name`, `vim.mode`, `pr.number`, `pr.url`, `pr.review_state`, `worktree.*`. Updates after each assistant message, after `/compact`, on permission mode or vim mode change. Use `/statusline <description>` to auto-generate a script.

### Checkpointing and Rewind

Automatic: every user prompt creates a checkpoint. Persist across sessions, cleaned up after 30 days. Open rewind menu: `/rewind` or double-`Esc` with empty input.

Rewind options: Restore code and conversation | Restore conversation only | Restore code only | Summarize from here | Summarize up to here | Never mind.

Limitations: bash command changes not tracked (only file editing tool changes); external changes not tracked; not a replacement for git.

### Remote Control

Connect claude.ai/code or Claude mobile app (iOS/Android) to a local Claude Code session. Session runs locally; web/mobile is just a window. Start: `claude remote-control` (server mode), `claude --remote-control` (interactive), or `/remote-control` from existing session.

Server mode flags: `--name`, `--spawn <same-dir|worktree|session>`, `--capacity <N>`, `--verbose`, `--sandbox`.

Requires: claude.ai subscription (Pro/Max/Team/Enterprise); full OAuth login (not API keys); Claude Code v2.1.51+. Team/Enterprise: admin must enable Remote Control toggle.

Not available with Bedrock, Vertex, Foundry. Local process must stay running.

### Scheduled Tasks (Session-scoped `/loop`)

Session-scoped; stops when session closes. Restores on `--resume` if within 7-day expiry.

| `/loop` invocation | Behavior |
| :--- | :--- |
| `/loop 5m check the deploy` | Fixed interval, specific prompt |
| `/loop check the deploy` | Dynamic interval Claude chooses |
| `/loop` | Built-in maintenance prompt (continue work, tend PR, cleanup) |

One-time reminders: natural language, e.g. "remind me at 3pm to push the branch".
Manage: ask Claude naturally or use `CronCreate`/`CronList`/`CronDelete` tools. Max 50 tasks per session. All times in local timezone. 7-day expiry on recurring tasks. Disable: `CLAUDE_CODE_DISABLE_CRON=1`.

### Scheduling Options Comparison

| | Cloud Routines | Desktop Tasks | `/loop` |
| :--- | :--- | :--- | :--- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Min interval | 1 hour | 1 minute | 1 minute |
| Local file access | No (fresh clone) | Yes | Yes |

### Channels

Push events from external systems (Telegram, Discord, iMessage) into a running Claude Code session. Supported: Telegram, Discord, iMessage, fakechat (localhost demo). Install as plugins, run with `--channels plugin:<name>@<marketplace>`. All require Bun. Events only arrive while session is open. Security: sender allowlist per channel; pair your account via code.

Enterprise: `channelsEnabled` (must be `true`) and `allowedChannelPlugins` in managed settings. Channels require Claude Code v2.1.80+.

### Voice Dictation

Speak prompts instead of typing; speech transcribed live into input. Requires claude.ai account (not API key). Requires local mic access (not available in remote/SSH/web sessions). Enable: `/voice`. Modes: hold (`/voice hold`, default — hold Space to record) or tap (`/voice tap` — tap to start, tap to send). Set language via `language` setting (BCP 47 or name). Rebind key in `keybindings.json` under `voice:pushToTalk` action. Requires Claude Code v2.1.69+; tap mode v2.1.116+.

### Fullscreen Rendering

Alt-screen rendering, flicker-free, stable memory in long conversations, adds mouse support. Enable: `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1`. Conversation lives in alternate screen buffer; use `Ctrl+O` for transcript mode to search. Requires Claude Code v2.1.89+.

### Worktrees

Isolated git worktrees for parallel sessions: `claude --worktree <name>`. Creates checkout at `.claude/worktrees/<name>/` on branch `worktree-<name>`. Omit name for auto-generated. Branch from `origin/HEAD` by default; set `worktree.baseRef: "head"` to branch from local HEAD. Branch from a PR: `claude --worktree "#1234"`. Control what's copied in with `.worktreeinclude` file.

### Agent View

`claude agents` opens one screen for all background sessions. Dispatch new sessions (each prompt starts its own), peek/reply without leaving view, or attach for full conversation. State icons show: working, needs input, completed. Sessions persist while the supervisor process runs.

### Parallel Approaches Summary

| Approach | Best for |
| :--- | :--- |
| Subagents | Side task that would flood main context; only summary needed |
| Agent view | Independent tasks; hand off and check back |
| Agent teams | Complex parallel work with inter-agent coordination |
| Worktrees | Parallel sessions editing overlapping files |
| `/batch` | Repo-wide migrations as 5–30 isolated subagents each opening a PR |

### Prompt Caching

Claude Code manages caching automatically. Cache organized as: system prompt → project context (CLAUDE.md, auto memory, unscoped rules) → conversation. Cache invalidated by: model switch, effort level change, MCP server connect/disconnect, Claude Code upgrade, `/clear`, `/compact`, session start, changing output style.

Cache lifetime: 5 min default on Anthropic API; extendable to 1 hour (set `CLAUDE_CODE_LONG_CACHE_TTL=1` or `/config` → Extended prompt cache). Disable: `DISABLE_PROMPT_CACHING=1` (or per-tier: `_HAIKU`, `_SONNET`, `_OPUS`).

Check cache performance: run `/usage` and look at cache hit rate. Also visible in status line with `context_window.current_usage.cache_read_input_tokens`.

### Deep Links

`claude-cli://open` URL scheme. Opens Claude Code in a terminal window with prompt pre-filled (not auto-sent). Parameters: `q` (URL-encoded prompt, max 5,000 chars) and `cwd` (absolute path). Requires Claude Code v2.1.91+. Note: GitHub strips non-http(s) URLs in rendered Markdown.

### Context Window Visualization

Available at `references/claude-code-context-window.md`. Interactive timeline showing what loads into context and when: system prompt, auto memory, MCP tool names, skill descriptions, CLAUDE.md, path-scoped rules, file reads, hook output, subagent work, and `/compact` behavior.

What survives `/compact`:
- System prompt and output style: unchanged
- Project-root CLAUDE.md and unscoped rules: re-injected
- Auto memory: re-injected
- Path-scoped rules: lost until a matching file is read
- Nested CLAUDE.md: lost until a file in that subdirectory is read
- Invoked skill bodies: re-injected (capped at 5K/skill, 25K total; oldest dropped first)

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code (features overview)](references/claude-code-features-overview.md) — when to use CLAUDE.md, skills, MCP, subagents, hooks, plugins; context costs by feature; how features layer
- [Fast mode](references/claude-code-fast-mode.md) — toggle fast mode, cost tradeoff, per-session opt-in, rate limits
- [Model configuration](references/claude-code-model-config.md) — model aliases, effort levels, extended context, extended thinking, prompt caching configuration, third-party deployment pinning
- [Output styles](references/claude-code-output-styles.md) — built-in styles, custom output style files, frontmatter fields, system prompt interaction
- [Statusline](references/claude-code-statusline.md) — setup, available JSON fields, examples (context bar, git status, cost tracking, rate limits, multi-line, clickable links), subagent status line
- [Checkpointing](references/claude-code-checkpointing.md) — automatic tracking, rewind menu options, restore vs. summarize, limitations
- [Remote Control](references/claude-code-remote-control.md) — start modes, connecting from other devices, security, push notifications, limitations, troubleshooting
- [Scheduled tasks (/loop)](references/claude-code-scheduled-tasks.md) — /loop modes, one-time reminders, cron tools, jitter, 7-day expiry, loop.md customization
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) — create tasks in Desktop app, schedule options, worktree isolation
- [Routines (cloud)](references/claude-code-routines.md) — schedule/API/GitHub triggers, create from web/CLI/Desktop, run management
- [Channels](references/claude-code-channels.md) — Telegram/Discord/iMessage setup, fakechat quickstart, security/allowlists, enterprise controls
- [Channels reference](references/claude-code-channels-reference.md) — build a custom channel MCP server, capability declaration, notification format, reply tools, permission relay
- [Voice dictation](references/claude-code-voice-dictation.md) — hold and tap modes, language settings, keybinding, troubleshooting
- [Fullscreen rendering](references/claude-code-fullscreen.md) — enable, mouse support, search/review in alternate buffer
- [Worktrees](references/claude-code-worktrees.md) — --worktree flag, base branch, .worktreeinclude, subagent isolation, non-git VCS hooks
- [Run agents in parallel](references/claude-code-agents.md) — comparison of subagents, agent view, agent teams, worktrees, /batch
- [Agent view](references/claude-code-agent-view.md) — dispatch, monitor, peek/reply, attach/detach, keyboard shortcuts
- [Prompt caching](references/claude-code-prompt-caching.md) — cache organization, invalidation triggers, cache lifetime, disable options, check performance
- [Prompt library](references/claude-code-prompt-library.md) — copy-paste prompts tagged by task and role
- [Context window visualization](references/claude-code-context-window.md) — interactive timeline, what survives compaction, check your own session

## Sources

- Extend Claude Code (features overview): https://code.claude.com/docs/en/features-overview.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Statusline: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks (/loop): https://code.claude.com/docs/en/scheduled-tasks.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Routines (cloud): https://code.claude.com/docs/en/routines.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
- Worktrees: https://code.claude.com/docs/en/worktrees.md
- Run agents in parallel: https://code.claude.com/docs/en/agents.md
- Agent view: https://code.claude.com/docs/en/agent-view.md
- Prompt caching: https://code.claude.com/docs/en/prompt-caching.md
- Prompt library: https://code.claude.com/docs/en/prompt-library.md
- Context window visualization: https://code.claude.com/docs/en/context-window.md
