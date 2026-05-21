---
name: features-doc
user-invocable: false
---

# Features Documentation

Claude Code features span parallel work, scheduling, model configuration, UI controls, and automation. Use these references to understand what is available and how to configure it.

## Quick Reference

### Extension Overview

| Feature | What it does | Cost to context |
|---|---|---|
| CLAUDE.md | Project instructions loaded every session | Low (cached) |
| Skills | Reusable agent specialists loaded on demand | Low (cached) |
| MCP | External tools and data sources | Medium (tool schemas) |
| Hooks | Shell commands run on lifecycle events | Negligible |
| Subagents | Delegated workers inside one session | None (own context) |
| Plugins | Bundles of CLAUDE.md + Skills + MCP + Hooks | Sum of parts |
| Agent teams | Coordinated multi-session workers | None (own contexts) |

### Model Aliases

| Alias | Maps to |
|---|---|
| `default` | Current recommended model |
| `best` | Highest capability available |
| `opus` | Claude Opus |
| `sonnet` | Claude Sonnet |
| `haiku` | Claude Haiku |
| `sonnet[1m]` | Sonnet with 1M context |
| `opus[1m]` | Opus with 1M context |
| `opusplan` | Opus optimized for planning |

### Effort Levels

| Level | Use case |
|---|---|
| `low` | Simple lookups, fast answers |
| `medium` | Standard tasks |
| `high` | Complex reasoning |
| `xhigh` | Very demanding tasks |
| `max` | Maximum effort |

### Fast Mode

| Setting | Value |
|---|---|
| Toggle | `/fast` in session |
| Speed | ~2.5x faster than standard Opus |
| Pricing | $30/$150 per MTok (input/output) |
| Requires | Usage credits |
| Not available | Bedrock, Vertex, Foundry |
| Setting | `fastModePerSessionOptIn` |
| Indicator | `↯` icon in status |

### Parallel Work Approaches

| Approach | Coordinates | Workers communicate | File isolation |
|---|---|---|---|
| Subagents | Claude (auto) | Return summary to parent | Optional (worktree) |
| Agent view | You | Report to you only | Auto worktree when editing |
| Agent teams | Claude (lead) | Shared task list + messaging | Manual partitioning |
| Worktrees | You | No | Yes (separate checkouts) |
| `/batch` | Claude (auto) | No | Yes (one worktree each) |

### Scheduling Options

| Method | Scope | Persistence | Trigger |
|---|---|---|---|
| `/loop [interval] [prompt]` | Session-scoped | 7-day expiry | Timer |
| Desktop scheduled tasks | Desktop app | Until deleted | Manual/Hourly/Daily/Weekdays/Weekly |
| Cloud routines | Anthropic cloud | Until deleted | Schedule, API, or GitHub event |

### Session Features

| Feature | Command/Key | Notes |
|---|---|---|
| Checkpointing | `/rewind` (Esc twice) | Restores code + conversation; 30-day cleanup |
| Context window | `/context` | Interactive visualization |
| Memory | `/memory` | Manage what survives compaction |
| Voice dictation | `/voice` | Hold Space (hold mode) or `/voice tap` |
| Fast mode | `/fast` | Toggle per session |
| Output style | `/output-style <name>` | Takes effect after `/clear` or new session |
| Remote control | `/remote-control` | Connect claude.ai or mobile app to local session |

### UI Features

| Feature | How to enable | Notes |
|---|---|---|
| Fullscreen TUI | `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1` | Alternate screen buffer |
| Transcript mode | `Ctrl+o` | In fullscreen; scrollable output |
| Mouse support | On by default in fullscreen | Disable with `CLAUDE_CODE_DISABLE_MOUSE=1` |
| Status line | `statusLine.command` in settings | Script receives JSON via stdin |
| Status line config | `/statusline` | Natural language configuration |

### Worktrees

| Task | Command/Setting |
|---|---|
| Start Claude in worktree | `claude --worktree <name>` |
| Start with auto-generated name | `claude --worktree` |
| Default location | `.claude/worktrees/<name>/` |
| Branch from remote HEAD | `worktree.baseRef: "fresh"` (default) |
| Branch from local HEAD | `worktree.baseRef: "head"` |
| Branch from PR | `claude --worktree "#1234"` |
| Copy gitignored files | `.worktreeinclude` in project root |
| Subagent isolation | `isolation: worktree` in subagent frontmatter |
| Non-git VCS | `WorktreeCreate` / `WorktreeRemove` hooks |

### Agent View Commands

| Command | Action |
|---|---|
| `claude agents` | Open agent view |
| `claude attach <id>` | Attach to a session |
| `claude logs <id>` | Stream logs from a session |
| `claude stop <id>` | Stop a running session |
| `claude rm <id>` | Remove a completed session |

### Session States (Agent View)

| State | Meaning |
|---|---|
| Working | Actively running |
| Needs input | Waiting for your response |
| Idle | Paused, awaiting a prompt |
| Completed | Finished successfully |
| Failed | Ended with an error |
| Stopped | Manually stopped |

### Channels

| Item | Detail |
|---|---|
| Purpose | Push events from Telegram, Discord, iMessage into a running session |
| Enable | `--channels` flag or `channelsEnabled` setting |
| Status | Research preview |
| Enterprise control | `allowedChannelPlugins` |
| MCP capability | `claude/channel` |
| Notification method | `notifications/claude/channel` |

### Remote Control

| Mode | How |
|---|---|
| Server mode | `claude remote-control` |
| Interactive mode | `claude --remote-control` |
| From session | `/remote-control` |
| Spawn modes | `same-dir`, `worktree`, `session` |
| Clients | claude.ai/code, Claude mobile app |
| Team/Enterprise | Requires admin toggle |

### Cloud Routines

| Trigger type | Details |
|---|---|
| Schedule | Set via claude.ai/code/routines or `/schedule` CLI |
| API | POST with bearer token |
| GitHub event | `pull_request`, `release` |
| Runs on | Anthropic cloud (autonomous) |
| Limit | Daily run cap applies |

### Deep Links

| Parameter | Purpose |
|---|---|
| `q` | Pre-fill prompt text |
| `cwd` | Set working directory |
| `repo` | Open a repository |
| CLI scheme | `claude-cli://open` |
| VS Code scheme | `vscode://anthropic.claude-code/open` |

### Prompt Caching — Cache-Invalidating Actions

| Action | Effect |
|---|---|
| Switch model | Full cache miss |
| Connect/disconnect MCP | Full cache miss |
| Deny a tool | Full cache miss |
| Compaction | Full cache miss |
| Claude Code upgrade | Full cache miss |

### Output Styles Frontmatter

| Field | Purpose |
|---|---|
| `name` | Style identifier |
| `description` | Shown in style picker |
| `keep-coding-instructions` | Preserve default coding behavior |
| `force-for-plugin` | Auto-apply when plugin is active |

### Status Line Fields (stdin JSON)

| Field | Content |
|---|---|
| `model` | Active model name |
| `workspace` | Current workspace path |
| `cost` | Session cost so far |
| `context_window` | Tokens used / available |
| `rate_limits` | Current rate limit status |
| `vim` | Vim mode state |
| `pr` | Current PR info |
| `worktree` | Active worktree name |

## Full Documentation

- [features-overview](references/claude-code-features-overview.md) — Comparison table of all extension mechanisms (CLAUDE.md, Skills, MCP, Hooks, Subagents, Plugins, Agent teams) with context cost and layering behavior
- [agents](references/claude-code-agents.md) — Compare Subagents, Agent view, Agent teams, Worktrees, and /batch for parallel work; guidance on choosing an approach
- [agent-view](references/claude-code-agent-view.md) — Dispatch and monitor background sessions with `claude agents`; session states; shell commands; keyboard shortcuts
- [channels](references/claude-code-channels.md) — Push events from Telegram, Discord, or iMessage into a running session; enterprise controls; research preview
- [channels-reference](references/claude-code-channels-reference.md) — Build custom MCP channel servers: `claude/channel` capability, notification format, reply tools, permission relay
- [checkpointing](references/claude-code-checkpointing.md) — Automatic per-prompt checkpoints; `/rewind` to restore code and conversation; 30-day cleanup
- [context-window](references/claude-code-context-window.md) — Interactive context window visualization; what survives compaction; `/context` and `/memory` commands
- [deep-links](references/claude-code-deep-links.md) — `claude-cli://open` URL scheme with `q`, `cwd`, `repo` parameters; VS Code deep link format
- [desktop-scheduled-tasks](references/claude-code-desktop-scheduled-tasks.md) — Desktop app scheduled tasks with Manual/Hourly/Daily/Weekdays/Weekly cadences; catch-up runs
- [fast-mode](references/claude-code-fast-mode.md) — `/fast` toggle for ~2.5x faster Opus; pricing, eligibility, and `fastModePerSessionOptIn` setting
- [fullscreen](references/claude-code-fullscreen.md) — `/tui fullscreen` and `CLAUDE_CODE_NO_FLICKER=1`; alternate screen buffer; `Ctrl+o` transcript mode; mouse support
- [model-config](references/claude-code-model-config.md) — Model aliases (`default`, `best`, `opus`, etc.); effort levels; extended context 1M; env vars; `modelOverrides` for third-party providers
- [output-styles](references/claude-code-output-styles.md) — Built-in styles (Default, Proactive, Explanatory, Learning); custom styles via `output-styles/` dirs; frontmatter fields
- [prompt-caching](references/claude-code-prompt-caching.md) — How prefix matching works; 3-layer cache structure; cache-invalidating vs cache-preserving actions; TTL details
- [prompt-library](references/claude-code-prompt-library.md) — ~50 prompts organized by SDLC phase (Discover/Design/Build/Ship/Operate); prompt patterns
- [remote-control](references/claude-code-remote-control.md) — Connect claude.ai or Claude mobile app to a local session; server mode, interactive mode, spawn options
- [routines](references/claude-code-routines.md) — Cloud routines triggered by schedule, API POST, or GitHub events; create via web or `/schedule`; runs on Anthropic cloud
- [scheduled-tasks](references/claude-code-scheduled-tasks.md) — Session-scoped scheduling with `/loop`; CronCreate/CronList/CronDelete tools; 7-day expiry; `loop.md` default
- [statusline](references/claude-code-statusline.md) — `statusLine.command` setting; script receives JSON via stdin; available fields; `/statusline` natural language config; `refreshInterval`
- [voice-dictation](references/claude-code-voice-dictation.md) — `/voice` to enable; hold Space (hold mode) or `/voice tap`; requires claude.ai account; supported languages
- [worktrees](references/claude-code-worktrees.md) — `--worktree` flag; default location; `worktree.baseRef`; PR checkout; `.worktreeinclude`; subagent isolation; non-git VCS hooks

## Sources

- https://code.claude.com/docs/en/features-overview
- https://code.claude.com/docs/en/agents
- https://code.claude.com/docs/en/agent-view
- https://code.claude.com/docs/en/channels
- https://code.claude.com/docs/en/channels-reference
- https://code.claude.com/docs/en/checkpointing
- https://code.claude.com/docs/en/context-window
- https://code.claude.com/docs/en/deep-links
- https://code.claude.com/docs/en/desktop-scheduled-tasks
- https://code.claude.com/docs/en/fast-mode
- https://code.claude.com/docs/en/fullscreen
- https://code.claude.com/docs/en/model-config
- https://code.claude.com/docs/en/output-styles
- https://code.claude.com/docs/en/prompt-caching
- https://code.claude.com/docs/en/prompt-library
- https://code.claude.com/docs/en/remote-control
- https://code.claude.com/docs/en/routines
- https://code.claude.com/docs/en/scheduled-tasks
- https://code.claude.com/docs/en/statusline
- https://code.claude.com/docs/en/voice-dictation
- https://code.claude.com/docs/en/worktrees
