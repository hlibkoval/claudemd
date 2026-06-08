---
name: features-doc
description: >
  Claude Code features reference: model configuration, effort levels, fast mode,
  output styles, statusline, checkpointing, remote control, scheduled tasks,
  voice dictation, channels, context window, fullscreen rendering, deep links,
  agent view, parallel agent strategies, worktrees, prompt caching, and the
  prompt library. Covers extension types (CLAUDE.md vs Skills vs Subagents vs
  MCP vs Hooks vs Plugins) and when to use each.
user-invocable: false
---

# Claude Code Features

Background knowledge on Claude Code's feature set — model tuning, UI options, session management, scheduling, multi-agent coordination, and cost optimization.

## Quick Reference

### Extension Type Comparison

| Extension   | Lives in      | Loaded by     | Best for                                          |
|:------------|:--------------|:--------------|:--------------------------------------------------|
| CLAUDE.md   | File          | Always        | Project context, persistent instructions          |
| Skills      | Directory     | On demand     | Reusable workflows, slash commands                |
| Subagents   | Directory     | On demand     | Specialist agents with isolated context           |
| MCP         | Config        | Session start | External tools and data sources                   |
| Hooks       | Config        | On event      | Automated actions triggered by Claude's actions   |
| Plugins     | Directory     | Session start | Bundled configuration for teams/orgs              |

### Model Aliases

| Alias      | Description                                              |
|:-----------|:---------------------------------------------------------|
| `default`  | Current default model                                    |
| `best`     | Best available model (currently Opus 4.8)                |
| `sonnet`   | Sonnet family                                            |
| `opus`     | Opus family                                              |
| `haiku`    | Haiku family (fast, economical)                          |
| `opusplan` | Opus for planning phases only                            |
| `[1m]`     | Extended 1M-token context variant                        |

### Effort Levels

| Level       | Description                                        |
|:------------|:---------------------------------------------------|
| `low`       | Minimal thinking; fastest and cheapest             |
| `medium`    | Balanced (default)                                 |
| `high`      | More reasoning steps                               |
| `xhigh`     | Extended thinking                                  |
| `max`       | Maximum reasoning budget                           |
| `ultracode` | Code-optimized max effort                          |

Set via `/effort <level>`, `--effort` flag, or `effort` frontmatter in skills.

### Fast Mode

- Toggle: `/fast` or `--fast` flag
- Available on: Opus models only
- Pricing: $10/MTok input, $50/MTok output (Opus 4.8)
- Falls back to standard when rate-limited
- Incompatible with prompt caching (invalidates cache on toggle)

### Output Styles

| Style         | Behavior                                              |
|:--------------|:------------------------------------------------------|
| Default       | Concise, action-focused                               |
| Proactive     | Surfaces issues and suggestions proactively           |
| Explanatory   | Explains reasoning and decisions                      |
| Learning      | Teaches concepts alongside completing tasks           |
| Custom        | Loaded from a Markdown file you specify               |

Change with `/config` or `outputStyle` setting. Custom styles: set `outputStyle` to a file path.

### Statusline Data Fields

Available fields in the JSON object passed to statusline shell scripts:

| Field              | Description                              |
|:-------------------|:-----------------------------------------|
| `model`            | Active model name                        |
| `cwd`              | Current working directory                |
| `cost`             | Accumulated session cost                 |
| `context_window`   | Tokens used / total available            |
| `rate_limits`      | Current rate limit state                 |
| `pr`               | Active pull request info                 |
| `worktree`         | Active worktree name                     |
| `session_id`       | Current session identifier               |
| `effort`           | Current effort level                     |

Configure with `statusLine` setting pointing to a shell script that reads stdin JSON and outputs a string.

### Checkpointing

- Auto-checkpoint created before every prompt
- Restore: `/rewind` or double-Esc
- Options on restore: rewind (restore files) or summarize (keep files, update context)
- Limitation: bash command side-effects are not tracked
- Stored per-session; cleared on session end

### Remote Control

| Method          | How                                          |
|:----------------|:---------------------------------------------|
| CLI start       | `claude remote-control`                      |
| CLI attach      | `claude --remote-control`                    |
| In-session      | `/remote-control`                            |
| Connect         | Browser URL, QR code, or Claude mobile app   |

Runs the session locally; remote device sends messages. Mobile push notifications supported.

### Scheduling Options

| Approach                | Trigger          | Where it runs | Command / Config             |
|:------------------------|:-----------------|:--------------|:-----------------------------|
| `/loop` (in-session)    | Fixed/dynamic    | Local machine | `/loop <interval> <prompt>`  |
| Desktop tasks           | Schedule/manual  | Local machine | Desktop app Routines page    |
| Cloud routines          | Schedule/API/GH  | Anthropic cloud | `claude.ai/code/routines`   |

`/loop` supports custom intervals and a `loop.md` file for the maintenance prompt. Uses `CronCreate`/`CronList`/`CronDelete` tools. Cron jobs expire after 7 days.

Desktop tasks require the machine to be on; cloud routines run in Anthropic's cloud and support GitHub event triggers.

### Voice Dictation

- Toggle: `/voice`
- Modes: hold (hold Space to record) or tap (tap Space to start/stop)
- Default key: Space (configurable)
- Language: configurable via settings
- Requires: claude.ai account

### Channels

Channels let external services push events into an active Claude Code session.

| Approach         | Description                                          |
|:-----------------|:-----------------------------------------------------|
| Telegram plugin  | Ready-made Telegram bot integration                  |
| Discord plugin   | Ready-made Discord integration                       |
| iMessage plugin  | Ready-made iMessage integration                      |
| Custom channel   | MCP server implementing `claude/channel` capability  |

Enable with `--channels` flag or `channelsEnabled` enterprise setting. Configure sender allowlists per channel. Custom channel MCP servers handle notification format and reply tools.

### Context Window

What survives auto-compaction:

| Content                    | Survives compaction |
|:---------------------------|:--------------------|
| Recent messages            | Yes (recent window) |
| Skill instructions         | Yes (up to 5k tok each, 25k total) |
| CLAUDE.md                  | Yes                 |
| Tool results / file reads  | No (summarized)     |
| Bash output                | No (summarized)     |

Use `/compact` to manually trigger compaction with optional focus instructions.

### Prompt Caching

Cache invalidation triggers (any of these busts the cache):

- Model switch
- Effort level change
- Fast mode toggle
- MCP server changes
- Auto-compaction
- Claude Code upgrade

Cache TTL: 5 minutes (standard) or 1 hour (extended, when supported). Disable with `DISABLE_PROMPT_CACHE=1` or `ANTHROPIC_PROMPT_CACHING_ENABLED=false`.

### Worktrees

| Command / Setting                     | Effect                                          |
|:--------------------------------------|:------------------------------------------------|
| `claude --worktree <name>`            | Create isolated worktree, start Claude in it    |
| `claude --worktree`                   | Auto-named worktree                             |
| `claude --worktree "#1234"`           | Worktree from PR number                         |
| `worktree.baseRef: "head"`            | Branch from local HEAD instead of origin/HEAD   |
| `.worktreeinclude`                    | List gitignored files to copy into worktrees    |
| `isolation: worktree` (subagent)      | Each subagent gets its own worktree             |

Worktrees live at `.claude/worktrees/<name>/`. Add to `.gitignore`.

### Parallel Agent Approaches

| Approach          | Coordinator | Workers communicate | File isolation      |
|:------------------|:------------|:--------------------|:--------------------|
| Subagents         | Claude      | No (report to parent) | Optional worktrees |
| Agent view        | You         | No (report to you)  | Auto worktree       |
| Agent teams       | Claude lead | Yes (shared task list) | Manual partition  |
| Dynamic workflows | Script      | No                  | Per-subagent        |

`claude agents` opens agent view. `/agents` manages subagents in current session. `/tasks` lists background tasks. `/workflows` shows workflow runs.

### Agent View

| Action         | How                                              |
|:---------------|:-------------------------------------------------|
| Open           | `claude agents`                                  |
| Dispatch       | Type a task in agent view                        |
| Background     | `claude --bg "task"`                             |
| Attach         | Select session in agent view                     |
| Peek           | View output without attaching                    |

Each background session runs in its own worktree automatically. Requires a supervisor process.

### Deep Links

Format: `claude-cli://open?q=<prompt>&cwd=<path>` or `&repo=<path>`

- Registered when Claude Code starts a session
- Max URL length: 5000 characters
- `q`: prompt text
- `cwd`: working directory
- `repo`: repository path (alternative to cwd)

### Prompt Library

Curated prompts organized by SDLC phase:

| Phase     | Examples                                              |
|:----------|:------------------------------------------------------|
| Discover  | Codebase exploration, architecture review             |
| Design    | API design, schema planning, spec writing             |
| Build     | Feature implementation, refactoring, debugging        |
| Ship      | PR review, test writing, release notes                |
| Operate   | Monitoring setup, incident response, runbooks         |

Filterable by tag and role. Access at `claude.ai/code/prompts` or via the desktop app.

## Full Documentation

- [Features Overview](references/claude-code-features-overview.md) — Extension type comparison (CLAUDE.md vs Skills vs Subagents vs MCP vs Hooks vs Plugins), layering, and context costs
- [Model Configuration](references/claude-code-model-config.md) — Model aliases, effort levels, extended context, env vars for model pinning
- [Fast Mode](references/claude-code-fast-mode.md) — `/fast` toggle, Opus-only availability, pricing, rate limit fallback
- [Output Styles](references/claude-code-output-styles.md) — Built-in styles, custom style files, `/config` usage
- [Statusline](references/claude-code-statusline.md) — Shell script integration, JSON data fields, `statusLine` setting
- [Checkpointing](references/claude-code-checkpointing.md) — Auto-checkpoints, `/rewind`, restore vs summarize, limitations
- [Remote Control](references/claude-code-remote-control.md) — `claude remote-control`, browser/QR/app connection, mobile notifications
- [Scheduled Tasks (in-session)](references/claude-code-scheduled-tasks.md) — `/loop` skill, intervals, `loop.md`, cron tools, 7-day expiry
- [Desktop Scheduled Tasks](references/claude-code-desktop-scheduled-tasks.md) — Desktop app Routines page, local tasks, schedule options, worktree toggle
- [Cloud Routines](references/claude-code-routines.md) — `claude.ai/code/routines`, schedule/API/GitHub triggers, connectors, environments
- [Voice Dictation](references/claude-code-voice-dictation.md) — `/voice` toggle, hold vs tap mode, language, account requirements
- [Channels](references/claude-code-channels.md) — Telegram/Discord/iMessage plugins, `--channels` flag, sender allowlists
- [Channels Reference](references/claude-code-channels-reference.md) — Building custom channels: MCP `claude/channel` capability, notification format, reply tools
- [Context Window](references/claude-code-context-window.md) — What survives compaction, `/compact` strategies, context loading timeline
- [Fullscreen Rendering](references/claude-code-fullscreen.md) — `/tui fullscreen`, `CLAUDE_CODE_NO_FLICKER=1`, mouse support, `Ctrl+O` transcript mode
- [Deep Links](references/claude-code-deep-links.md) — `claude-cli://open` URL scheme, parameters, character limit
- [Agent View](references/claude-code-agent-view.md) — `claude agents`, dispatch/monitor/attach/peek, background sessions, worktree isolation
- [Run Agents in Parallel](references/claude-code-agents.md) — Subagents vs agent view vs agent teams vs dynamic workflows comparison
- [Worktrees](references/claude-code-worktrees.md) — `--worktree` flag, `.worktreeinclude`, subagent isolation, base branch config, cleanup
- [Prompt Caching](references/claude-code-prompt-caching.md) — Prefix matching, cache invalidation triggers, TTL, disable env vars
- [Prompt Library](references/claude-code-prompt-library.md) — Curated prompts by SDLC phase, prompt patterns, filtering

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
