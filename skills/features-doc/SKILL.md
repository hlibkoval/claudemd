---
name: features-doc
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features — parallel agents, UI capabilities, model configuration, output styles, scheduling, voice, deep links, and more.

## Quick Reference

### Parallel Agents — Approach Comparison

| Approach | Coordinator | Workers talk? | File isolation | Use when |
|---|---|---|---|---|
| Subagents | Claude (in-session) | No (report back) | Optional (worktrees) | Side task would flood main context |
| Agent view (`claude agents`) | You | No | Auto worktrees | Multiple independent tasks, check back later |
| Agent teams | Claude (lead agent) | Yes (task list + messages) | Partition manually | Claude should split, assign, supervise |
| Dynamic workflows | Script | Results cross-checked | Per-subagent | 500+ files, codebase-wide audits, verified research |

Check running work: `claude agents` (background sessions) | `/agents` (in-session subagents) | `/tasks` (background bash) | `/workflows` (dynamic workflows)

### Worktrees

| CLI | Effect |
|---|---|
| `claude --worktree <name>` | Create `.claude/worktrees/<name>/` on branch `worktree-<name>`, start Claude there |
| `claude --worktree` | Auto-generate name (e.g. `bright-running-fox`) |
| `claude --worktree "#1234"` | Branch from GitHub PR #1234 |

- **Base branch**: defaults to `origin/HEAD`; set `worktree.baseRef: "head"` in settings to branch from local HEAD
- **Copy gitignored files**: add `.worktreeinclude` (gitignore syntax) at repo root — matched+gitignored files are copied into each new worktree
- **Subagent isolation**: ask Claude to "use worktrees for agents", or set `isolation: worktree` in custom subagent frontmatter
- **Cleanup**: auto-removed when no changes; prompted when commits/changes exist; `-p` runs are never auto-cleaned

### Agent View

| Key / Command | Action |
|---|---|
| `claude agents` | Open agent view (all background sessions) |
| `n` | Dispatch new session |
| `Enter` | Attach to selected session |
| `p` | Open peek panel (read-only preview) |
| `Esc` | Exit peek / detach |
| `s` | Stop selected session |
| `?` | Show help |

- Sessions auto-get their own worktrees; commits are pushed to a branch named for the session
- Supervisor process keeps sessions running when terminal closes
- Status: `waiting` (needs input) | `running` | `done` | `error`

### Model Configuration

| Alias | Model |
|---|---|
| `default` | Current recommended default |
| `best` | Best available (currently Opus 4.8) |
| `sonnet` | Sonnet 4.7 |
| `opus` | Opus 4.7 |
| `haiku` | Haiku 3.5 |
| `sonnet[1m]` | Sonnet 4.7, 1M-token context |
| `opus[1m]` | Opus 4.7, 1M-token context |
| `opusplan` | Opus 4.8, planning-optimized |

**Effort levels** (for extended thinking): `low` | `medium` | `high` | `xhigh` | `max` | `ultracode`

**Env vars**: `ANTHROPIC_DEFAULT_CHAT_MODEL`, `ANTHROPIC_DEFAULT_BACKGROUND_MODEL`

Set per-session with `/model <alias>` or globally in settings.

### Fast Mode

- Toggle: `/fast`
- Up to 2.5x faster on Opus; uses Opus 4.8 / 4.7 / 4.6
- Increased cost: ~$10/$50 per MTok input/output (Opus 4.8)
- Extended thinking is reduced or disabled in fast mode

### Prompt Caching

**Cache layers** (outer → inner): system prompt → project context (CLAUDE.md) → conversation turns

**Actions that invalidate cache**:
- Model switch, effort level change
- MCP server connect/disconnect
- Compaction
- Claude Code upgrade

**Cache lifetime**: 5 minutes (default); 1-hour extended cache available

Cost savings: cached tokens billed at reduced rate; shown in `/costs`

### Output Styles

| Style | Behavior |
|---|---|
| Default | Balanced responses |
| Proactive | Surfaces related issues without being asked |
| Explanatory | Explains reasoning and decisions |
| Learning | Teaches concepts alongside completing tasks |

- Switch: `/style <name>` or set in settings
- Custom styles: Markdown file with `keep-coding-instructions: true` frontmatter to preserve coding behavior

### Checkpointing

- **Save checkpoint**: Esc+Esc mid-turn, or checkpoint is auto-saved at each turn boundary
- **Rewind**: `/rewind` — pick a past checkpoint; choose Restore (roll back) or Summarize (compact to that point)
- **Limitation**: bash command side effects (file writes, installs) are not reversed on restore

### Context Window Visualization

- Command: `/context` — interactive breakdown of what's loaded
- Shows: system prompt, CLAUDE.md files, open files, conversation turns, tool results
- What survives compaction: CLAUDE.md content, explicitly pinned files, recent turns

### Scheduled Tasks (`/loop`)

| Tool | Use |
|---|---|
| `CronCreate` | Create repeating task with interval or cron expression |
| `CronList` | List active tasks for this session |
| `CronDelete` | Remove a task |

- `/loop` alone runs maintenance prompt (reads `loop.md` if present)
- Tasks are session-scoped; expire after 7 days
- Dynamic interval: task can set its own next-run time
- Fixed interval: set in `CronCreate` call

### Routines (Cloud-Scheduled)

- Managed at `claude.ai/code/routines`
- **Triggers**: schedule (cron), API, GitHub event
- **CLI**: `/schedule` to create from current session
- **Connectors**: Slack, GitHub, Jira, Linear, etc.
- **Environments**: secrets, env vars set per routine
- Distinct from `/loop` (session-scoped) and desktop scheduled tasks

### Desktop Scheduled Tasks

- Set in Desktop app → Routines page
- Run locally (not cloud); persist across restarts
- Comparison: local tasks vs cloud routines vs `/loop`

### Deep Links

**URL format**: `claude-cli://open?q=<encoded-prompt>&cwd=<path>&repo=<owner/name>`

| Parameter | Description |
|---|---|
| `q` | URL-encoded prompt text (max 5,000 chars); `%0A` for newlines |
| `cwd` | Absolute path; takes precedence over `repo` |
| `repo` | GitHub `owner/name` slug; resolves to most-recently-used local clone |

- Prompt is pre-filled but NOT sent until user presses Enter
- Handler registered automatically on first interactive `claude` session
- Disable: set `disableDeepLinkRegistration: "disable"` in settings.json
- VS Code variant: `vscode://anthropic.claude-code/open`

**Platform handler locations**:
- macOS: `~/Applications/Claude Code URL Handler.app`
- Linux: `~/.local/share/applications/claude-code-url-handler.desktop`
- Windows: `HKEY_CURRENT_USER\Software\Classes\claude-cli`

### Remote Control

| Command | Effect |
|---|---|
| `claude remote-control` | Start server; connect from claude.ai/code or mobile |
| `claude --remote-control` | Launch session immediately in remote-control mode |
| `/remote-control` | Toggle in active session |
| `--spawn` | Server mode: keep alive, spawn sessions on demand |

- Connects to Claude mobile app or claude.ai/code
- Push notifications when Claude needs input
- Session visible in agent view while remote-controlled

### Voice Dictation

| Mode | How to use |
|---|---|
| Hold mode | Hold Space to record; release to transcribe |
| Tap mode | Tap Space to start; tap again to stop |

- Activate: `/voice`
- Requires Claude.ai account
- Option `autoSubmit: true` — sends transcription without confirmation
- Rebind push-to-talk: `voice:pushToTalk` in keybindings

### Status Line

- Setting: `statusLine` in settings.json — command whose stdout populates the status bar
- Input (via stdin): JSON with fields `model`, `context`, `cost`, `git`, `rateLimit`
- Command: `/statusline` to reload
- Supports multi-line output and ANSI colors
- `subagentStatusLine` for subagent status bars

### Fullscreen TUI

- Command: `/tui fullscreen` — full alternate-screen rendering
- `CLAUDE_CODE_NO_FLICKER=1` — disables screen clearing (reduces flicker on some terminals)
- Mouse support enabled in fullscreen mode
- `Ctrl+O` — transcript mode (scrollable history)

### Channels (Push Events into Sessions)

| Channel type | Description |
|---|---|
| Telegram | Bot-based; messages routed to active session |
| Discord | Webhook or bot integration |
| iMessage | macOS only; AppleScript bridge |
| fakechat | Testing/dev; simulates channel messages locally |

- CLI flag: `--channels` to enable
- Enterprise controls: `channelsEnabled`, `allowedChannelPlugins` in managed settings
- MCP servers expose `claude/channel` capability; include notification format, reply tools, sender gating

### Prompt Library

50+ categorized prompts organized by SDLC phase:

| Phase | Coverage |
|---|---|
| Discover | Codebase exploration, architecture mapping, dependency analysis |
| Design | API design, schema planning, refactoring strategies |
| Build | TDD, code generation, debugging, PR review |
| Ship | CI/CD, release notes, deployment checklists |
| Operate | Incident response, monitoring, runbook automation |

Full library: `skills/features-doc/references/claude-code-prompt-library.md`

### Extension Architecture (When to Use What)

| Layer | What it is | Use when |
|---|---|---|
| CLAUDE.md | Persistent instructions in the repo | Always-on rules, project conventions |
| Skills | Reusable prompt templates | Repeatable multi-step workflows |
| Subagents | Delegated in-session workers | Isolate noisy side tasks |
| Hooks | Scripts triggered by Claude events | Enforce guardrails, log, auto-format |
| MCP | External tools/data sources | Connect Claude to services/APIs |
| Plugins | Bundles of skills + subagents | Distribute packaged capabilities |

## Full Documentation

For the complete official documentation, see the reference files:

- [Extension Overview](references/claude-code-extension-overview.md) — when to use CLAUDE.md vs Skills vs Subagents vs Hooks vs MCP vs Plugins; layering guide
- [Run Agents in Parallel](references/claude-code-agents.md) — subagents, agent view, agent teams, dynamic workflows comparison table
- [Agent View](references/claude-code-agent-view.md) — dispatch/monitor background sessions with `claude agents`; keyboard shortcuts; supervisor process
- [Run Parallel Sessions with Worktrees](references/claude-code-worktrees.md) — `--worktree` flag; `.worktreeinclude`; subagent isolation; cleanup rules
- [Channels](references/claude-code-channels.md) — push Telegram/Discord/iMessage events into running sessions; enterprise controls
- [Channels Reference](references/claude-code-channels-reference.md) — building MCP servers with `claude/channel` capability; notification format; reply tools; sender gating
- [Checkpointing](references/claude-code-checkpointing.md) — `/rewind`, Esc+Esc, restore vs summarize options; bash-command limitation
- [Context Window](references/claude-code-context-window.md) — interactive visualization; what loads when; what survives compaction
- [Deep Links](references/claude-code-deep-links.md) — `claude-cli://open` URL scheme; parameters; platform registration; troubleshooting
- [Desktop Scheduled Tasks](references/claude-code-desktop-scheduled-tasks.md) — Desktop app Routines page; local vs cloud vs `/loop` comparison
- [Fast Mode](references/claude-code-fast-mode.md) — `/fast` toggle; speed vs cost trade-offs; Opus 4.8/4.7/4.6 support
- [Fullscreen Rendering](references/claude-code-fullscreen-rendering.md) — `/tui fullscreen`; `CLAUDE_CODE_NO_FLICKER`; alternate screen buffer; mouse support
- [Model Configuration](references/claude-code-model-configuration.md) — model aliases; effort levels; extended thinking; extended context; env vars
- [Output Styles](references/claude-code-output-styles.md) — Default/Proactive/Explanatory/Learning built-ins; custom styles; `keep-coding-instructions`
- [Prompt Caching](references/claude-code-prompt-caching.md) — cache layers; invalidation actions; lifetime; cost savings
- [Prompt Library](references/claude-code-prompt-library.md) — 50+ prompts organized by SDLC phase (Discover/Design/Build/Ship/Operate)
- [Remote Control](references/claude-code-remote-control.md) — `claude remote-control`; server mode (`--spawn`); connect from claude.ai/code or mobile; push notifications
- [Routines](references/claude-code-routines.md) — cloud-scheduled tasks; schedule/API/GitHub triggers; `/schedule` CLI; connectors; environments
- [Scheduled Tasks (`/loop`)](references/claude-code-scheduled-tasks.md) — session-scoped cron; `CronCreate/CronList/CronDelete`; `loop.md`; 7-day expiry
- [Status Line](references/claude-code-statusline.md) — `statusLine` setting; JSON stdin fields; `/statusline` command; multi-line; ANSI colors
- [Voice Dictation](references/claude-code-voice-dictation.md) — `/voice`; hold mode vs tap mode; `autoSubmit`; keybinding configuration

## Sources

- Extension Overview: https://code.claude.com/docs/en/extension-overview.md
- Run Agents in Parallel: https://code.claude.com/docs/en/agents.md
- Agent View: https://code.claude.com/docs/en/agent-view.md
- Run Parallel Sessions with Worktrees: https://code.claude.com/docs/en/worktrees.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels Reference: https://code.claude.com/docs/en/channels-reference.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Context Window: https://code.claude.com/docs/en/context-window.md
- Deep Links: https://code.claude.com/docs/en/deep-links.md
- Desktop Scheduled Tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Fullscreen Rendering: https://code.claude.com/docs/en/fullscreen-rendering.md
- Model Configuration: https://code.claude.com/docs/en/model-configuration.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Prompt Caching: https://code.claude.com/docs/en/prompt-caching.md
- Prompt Library: https://code.claude.com/docs/en/prompt-library.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Routines: https://code.claude.com/docs/en/routines.md
- Scheduled Tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Voice Dictation: https://code.claude.com/docs/en/voice-dictation.md
