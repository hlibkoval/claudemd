---
name: features-doc
user-invocable: false
description: >
  Complete reference for Claude Code features: fast mode, model configuration,
  output styles, statusline, checkpointing, remote control, scheduled tasks,
  voice dictation, channels, context window, fullscreen rendering, routines,
  deep links, agent view, parallel agents, git worktrees, prompt caching, and
  the prompt library. Load this skill when the user asks about any of these
  built-in capabilities.
---

This skill covers the full breadth of Claude Code's built-in features — from
performance options like fast mode and model selection to automation primitives
like routines and scheduled tasks, to UI extensions like the statusline,
fullscreen mode, and voice dictation.

## Quick Reference

### Fast Mode

| Item | Value |
|:-----|:------|
| Toggle | `/fast` or `↯` indicator in statusline |
| Supported model | Claude Opus only |
| Speed gain | Up to 2.5× faster |
| Pricing (Opus 4.8) | $10 / $50 per MTok input/output |
| Pricing (Opus 4.7 / 4.6) | $30 / $150 per MTok |
| Requirement | Usage credits (not API key billing) |
| Setting | `fastModePerSessionOptIn` |

### Model Configuration

| Alias | Resolves to |
|:------|:------------|
| `default` | Current default model |
| `best` | Highest-capability available |
| `sonnet` | Latest Sonnet |
| `opus` | Latest Opus |
| `haiku` | Latest Haiku |
| `sonnet[1m]` | Sonnet with 1M-token context |
| `opus[1m]` | Opus with 1M-token context |
| `opusplan` | Opus in plan mode |

Change with `/model <alias>`. Effort levels: `low`, `medium`, `high`, `xhigh`, `max`, `ultracode`. Extended context (1M tokens) available for supported aliases. Configure via `availableModels`, `modelOverrides`, or environment variables.

### Output Styles

| Style | Behavior |
|:------|:---------|
| Default | Balanced prose and code |
| Proactive | Suggests next steps unprompted |
| Explanatory | Adds rationale and context |
| Learning | Explains concepts as it works |
| Custom | Markdown file in `~/.claude/output-styles/` or `.claude/output-styles/` |

Change with `/config`. Custom styles use YAML frontmatter fields in the style file.

### Statusline

Supply a shell script that reads JSON from stdin and outputs a status string. Set via `/statusline`. Available JSON fields include model, session ID, cost, token counts, git branch, running agents, and more. Configure `subagentStatusLine`, `refreshInterval`, and respect `COLUMNS`/`LINES` env vars.

### Checkpointing

Claude automatically tracks file edits throughout a session. Rewind with `/rewind` or double-Esc. On rewind, choose to restore files, summarize changes, or both. Limitation: bash command side-effects are not tracked.

### Remote Control

| Method | Command |
|:-------|:--------|
| CLI flag | `claude --remote-control` |
| Slash command | `/remote-control` |
| Subcommand | `claude remote-control` |

Server mode (`--spawn`) options: same directory, new worktree, or new session. Connect from browser or mobile. Mobile push notifications supported. Requires claude.ai subscription.

### Scheduled Tasks (In-Session Loops)

| Invocation | Behavior |
|:-----------|:---------|
| `/loop <interval> <prompt>` | Repeat prompt on interval |
| `/loop <prompt>` | Run prompt once (scheduled) |
| `/loop` | Maintenance loop using `loop.md` |

Tools: `CronCreate`, `CronList`, `CronDelete`. Loops expire after 7 days. Customize with `loop.md`. Disable entirely with `CLAUDE_CODE_DISABLE_CRON=1`.

### Voice Dictation

| Item | Detail |
|:-----|:-------|
| Command | `/voice` |
| Modes | Hold-to-talk and tap-to-toggle |
| Requirement | Claude.ai account |
| Languages | 20 supported |
| Push-to-talk binding | `voice:pushToTalk` (default: Space) |
| Auto-submit | `autoSubmit` setting |
| Privacy | Audio streamed to Anthropic for transcription |

### Channels

Push external events into a Claude Code session using `--channels`. Supported: Telegram, Discord, iMessage, fakechat. Sender allowlists configured via pairing. Org-level settings: `channelsEnabled`, `allowedChannelPlugins`. Research preview.

**Custom channel protocol (channels-reference):** Implement `claude/channel` MCP capability. Notifications use `notifications/claude/channel` format. Reply tool pattern for responding. Sender gating via `claude/channel/permission`. Enable dev channels with `--dangerously-load-development-channels`.

### Desktop Scheduled Tasks (Routines UI)

Manage local vs remote recurring tasks in the Desktop Routines page. Schedule options: Manual, Hourly, Daily, Weekdays, Weekly. Catch-up runs on missed schedules. Per-task permission mode. Programmatic updates via `update_scheduled_task` MCP tool.

### Context Window Visualization

| Item | Detail |
|:-----|:-------|
| Command | `/context` |
| View | Interactive breakdown of context layers |
| Compact | `/compact` |
| Memory | `/memory` |

What survives compaction: system prompt, CLAUDE.md, auto memory, path-scoped rules, skill bodies (up to 5,000 tokens each, 25,000 combined).

### Fullscreen / TUI Mode

| Item | Detail |
|:-----|:-------|
| Command | `/tui fullscreen` |
| Env var alternative | `CLAUDE_CODE_NO_FLICKER=1` |
| Mouse support | Yes (disable with `CLAUDE_CODE_DISABLE_MOUSE=1`) |
| Transcript mode | `Ctrl+O` |
| Search in transcript | `/` |
| Scroll speed | `CLAUDE_CODE_SCROLL_SPEED` |
| Status | Research preview |

Uses alternate screen buffer for flicker-free rendering.

### Routines (Cloud Automation)

Cloud-hosted automation running on Anthropic infrastructure. Create at claude.ai/code/routines or via `/schedule` CLI.

| Trigger | Details |
|:--------|:--------|
| Scheduled | Cron-like schedule; daily cap applies |
| API | HTTP POST with bearer token |
| GitHub | PR and Release events from connected repos |

### Deep Links

URL scheme: `claude-cli://open`. Parameters:

| Parameter | Description |
|:----------|:------------|
| `q` | Prompt text (max 5,000 characters) |
| `cwd` | Absolute working directory path |
| `repo` | GitHub owner/name slug |

Requires OS-level URL handler registration. Terminal app detection automatic.

### Agent View (`claude agents`)

Background session management dashboard opened with `claude agents`.

| Key | Action |
|:----|:-------|
| Space | Peek at session output |
| Enter or → | Attach to session |
| ← | Detach |

Start background sessions with `claude --bg` or `/bg` command. Sessions run in git worktrees under `.claude/worktrees/`. Shell jobs via `! command` syntax. Managed by supervisor process.

### Parallel Agents Comparison

| Approach | Coordinator | Workers talk? | File isolation |
|:---------|:------------|:--------------|:---------------|
| Subagents | Claude (inline) | No — report to parent | Optional worktree |
| Agent view | You | No | Auto worktree |
| Agent teams | Claude (lead) | Yes (task list + messages) | Manual partitioning |
| Dynamic workflows | Script | Via script | Per-workflow |

Check running work: `claude agents` (background sessions), `/agents` (in-session subagents), `/tasks` (background tasks), `/workflows` (dynamic workflow runs).

### Worktrees

| Item | Detail |
|:-----|:-------|
| Flag | `--worktree <name>` or `-w <name>` |
| Auto-name | Omit name for generated slug |
| Default location | `.claude/worktrees/<name>/` |
| Branch name | `worktree-<name>` |
| Base branch | `origin/HEAD` (or `"head"` via `worktree.baseRef`) |
| PR checkout | `claude --worktree "#1234"` |

Copy gitignored files into worktrees via `.worktreeinclude` (gitignore syntax). Subagent isolation: `isolation: worktree` in subagent frontmatter. Non-git VCS: configure `WorktreeCreate` / `WorktreeRemove` hooks.

Cleanup: empty worktrees removed automatically; non-empty prompt to keep/remove. Non-interactive (`-p`) worktrees require manual `git worktree remove`.

### Prompt Caching

Cache layers (invalidation order): system prompt → project context → conversation.

| Action that invalidates cache | Notes |
|:------------------------------|:------|
| Model switch | Full invalidation |
| Effort level change | Full invalidation |
| Fast mode enable | Full invalidation |
| MCP server change | Full invalidation |
| Plugin change | Full invalidation |
| Tool denial | Full invalidation |
| Compaction | Conversation layer reset |
| Upgrade | Full invalidation |

Default TTL: 5 minutes. Extended TTL: 1 hour with claude.ai subscription via `ENABLE_PROMPT_CACHING_1H=1`. Disable with `DISABLE_PROMPT_CACHING` env vars.

### Prompt Library

50+ prompts organized by SDLC phase and category:

| Phase | Categories |
|:------|:-----------|
| Discover | Onboard, Understand |
| Design | Plan, Prototype |
| Build | Implement, Test, Refactor |
| Ship | Review, Steer, Git, Release |
| Operate | Debug, Incident, Data, Automate |

Filterable by tags and roles. Includes a prompt patterns guide. See reference for full prompt catalog.

### Features Overview (Extension Layer)

| Layer | Purpose |
|:------|:--------|
| CLAUDE.md | Project instructions baked into context |
| Skills | Reusable slash-command workflows |
| Code intelligence | Language-aware analysis |
| MCP | External tools and data sources |
| Subagents | Delegated tasks in isolated context |
| Agent teams | Multi-session coordinated work |
| Hooks | Lifecycle event automation |
| Plugins | Packaged extensions distributed as directories |

## Full Documentation

- [features/fast-mode](references/claude-code-fast-mode.md) — Fast mode for Opus: toggle, speed, pricing, and settings
- [features/model-config](references/claude-code-model-config.md) — Model aliases, `/model` command, effort levels, extended context, and env vars
- [features/output-styles](references/claude-code-output-styles.md) — Built-in styles, custom style files, frontmatter fields, and `/config`
- [features/statusline](references/claude-code-statusline.md) — Shell script interface, JSON field reference, and configuration options
- [features/checkpointing](references/claude-code-checkpointing.md) — Auto file tracking, `/rewind`, restore options, and limitations
- [features/features-overview](references/claude-code-features-overview.md) — Extension layer guide with comparison tables and context cost breakdown
- [features/remote-control](references/claude-code-remote-control.md) — Remote access modes, `--spawn` options, mobile notifications, and subscription requirements
- [features/scheduled-tasks](references/claude-code-scheduled-tasks.md) — `/loop` variants, CronCreate/List/Delete tools, expiry, and `loop.md`
- [features/voice-dictation](references/claude-code-voice-dictation.md) — `/voice` command, modes, language support, and privacy details
- [features/channels](references/claude-code-channels.md) — Supported channel types, pairing, sender allowlists, and org settings
- [features/channels-reference](references/claude-code-channels-reference.md) — Custom channel MCP protocol, notification format, reply pattern, and permission relay
- [features/desktop-scheduled-tasks](references/claude-code-desktop-scheduled-tasks.md) — Desktop Routines UI, schedule options, catch-up runs, and MCP tool
- [features/context-window](references/claude-code-context-window.md) — Context visualization, compaction survival table, and `/context` / `/compact` / `/memory`
- [features/fullscreen](references/claude-code-fullscreen.md) — TUI fullscreen mode, mouse support, transcript mode, and scroll settings
- [features/routines](references/claude-code-routines.md) — Cloud automation triggers (scheduled, API, GitHub), daily cap, and `/schedule` CLI
- [features/deep-links](references/claude-code-deep-links.md) — `claude-cli://open` URL scheme, parameters, and OS handler registration
- [features/agent-view](references/claude-code-agent-view.md) — `claude agents` dashboard, session states, keybindings, and worktree isolation
- [features/agents](references/claude-code-agents.md) — Parallel agent comparison table and guidance on choosing an approach
- [features/worktrees](references/claude-code-worktrees.md) — `--worktree` flag, `.worktreeinclude`, subagent isolation, cleanup, and non-git VCS hooks
- [features/prompt-caching](references/claude-code-prompt-caching.md) — Cache layers, invalidation actions, TTL options, and env vars
- [features/prompt-library](references/claude-code-prompt-library.md) — 50+ SDLC prompts organized by phase and category with prompt patterns guide

## Sources

- https://code.claude.com/docs/en/fast-mode.md
- https://code.claude.com/docs/en/model-config.md
- https://code.claude.com/docs/en/output-styles.md
- https://code.claude.com/docs/en/statusline.md
- https://code.claude.com/docs/en/checkpointing.md
- https://code.claude.com/docs/en/features-overview.md
- https://code.claude.com/docs/en/remote-control.md
- https://code.claude.com/docs/en/scheduled-tasks.md
- https://code.claude.com/docs/en/voice-dictation.md
- https://code.claude.com/docs/en/channels.md
- https://code.claude.com/docs/en/channels-reference.md
- https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- https://code.claude.com/docs/en/context-window.md
- https://code.claude.com/docs/en/fullscreen.md
- https://code.claude.com/docs/en/routines.md
- https://code.claude.com/docs/en/deep-links.md
- https://code.claude.com/docs/en/agent-view.md
- https://code.claude.com/docs/en/agents.md
- https://code.claude.com/docs/en/worktrees.md
- https://code.claude.com/docs/en/prompt-caching.md
- https://code.claude.com/docs/en/prompt-library.md
