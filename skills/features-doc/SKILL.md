---
name: features-doc
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features: fast mode, model configuration, output styles, status line, checkpointing, remote control, scheduled tasks, voice dictation, channels, context window explorer, fullscreen rendering, routines, deep links, agent view, parallel agents, worktrees, prompt caching, and the prompt library.

## Quick Reference

### Features Overview — Extension Types

| Extension type | What it does | Best for |
|:--------------|:-------------|:---------|
| CLAUDE.md | Project context loaded at session start | Rules, stack info, commands |
| Skills | Background doc knowledge auto-loaded from plugins | Reference, procedures |
| Code intelligence | Real-time code context (uses `@` mentions) | Code lookup |
| MCP servers | External tools Claude can call | APIs, databases, services |
| Subagents | Delegate side tasks with isolated context | Parallel research/work |
| Agent teams | Multi-session coordination (experimental) | Large multi-part projects |
| Hooks | Event-driven automation scripts | CI, validation, side effects |
| Plugins | Packages of hooks + skills + agents | Reusable cross-project tooling |

### Fast Mode

| Item | Detail |
|:-----|:-------|
| What it does | Speeds up Opus 4 responses (up to 2.5x) at higher cost |
| Pricing: Opus 4.8 | $10 / $50 per MTok input / output |
| Pricing: Opus 4.7 / 4.6 | $30 / $150 per MTok input / output |
| Toggle | `/fast` command in session |
| Requirements | Usage credits (not subscription); separate rate limits |
| Availability | Opus models only |

### Model Configuration

**Model aliases:**

| Alias | Description |
|:------|:------------|
| `default` | Current session default |
| `best` | Best available model |
| `sonnet` | Claude Sonnet |
| `opus` | Claude Opus |
| `haiku` | Claude Haiku |
| `sonnet[1m]` | Sonnet with 1M-token context |
| `opus[1m]` | Opus with 1M-token context |
| `opusplan` | Opus for planning phase |

**Effort levels:**

| Level | Description |
|:------|:------------|
| `low` | Minimal thinking |
| `medium` | Balanced |
| `high` | More careful reasoning |
| `xhigh` | Extra careful reasoning |
| `max` | Maximum thinking budget |
| `ultracode` | Specialized coding effort |

**Extended context:** `sonnet[1m]` / `opus[1m]` enable 1M-token context windows. Set model via `ANTHROPIC_MODEL` env var; override small model with `ANTHROPIC_SMALL_FAST_MODEL`.

### Output Styles

**Built-in styles:**

| Style | Description |
|:------|:------------|
| Default | Standard Claude Code behavior |
| Proactive | More initiative, less waiting for confirmation |
| Explanatory | Narrates steps and reasoning |
| Learning | Teaches concepts alongside completing tasks |

**Custom styles:** place `.md` files in `~/.claude/output-styles/` (global) or `.claude/output-styles/` (project).

**Custom style frontmatter fields:**

| Field | Description |
|:------|:------------|
| `name` | Display name for the style |
| `description` | Short description |
| `keep-coding-instructions` | If `true`, preserve default coding behavior |
| `force-for-plugin` | Plugin name that auto-activates this style |

### Status Line

Configure a custom status bar that runs shell commands receiving JSON on stdin.

**Settings:**

| Field | Description |
|:------|:------------|
| `statusLine.type` | Set to `"command"` |
| `statusLine.command` | Shell command to run |
| `statusLine.padding` | Padding in characters (optional) |
| `statusLine.refreshInterval` | Refresh rate in ms (optional) |
| `statusLine.hideVimModeIndicator` | Hide vim mode indicator (optional) |

**Available JSON input fields:**

| Field | Description |
|:------|:------------|
| `model` | Current model alias |
| `workspace` | Project directory path |
| `cost` | Session cost so far |
| `context_window` | Context window usage info |
| `effort` | Current effort level |
| `thinking` | Whether thinking mode is on |
| `rate_limits` | Rate limit status |
| `vim` | Vim mode state |
| `pr` | Current PR info (if any) |
| `worktree` | Worktree name (if in one) |

### Checkpointing / Rewind

Claude automatically tracks file edits as checkpoints. Open the rewind menu with `/rewind` or double-Esc.

**Rewind actions:**

| Action | What it does |
|:-------|:-------------|
| Restore code + conversation | Revert both files and conversation to checkpoint |
| Restore conversation | Revert conversation only; files unchanged |
| Restore code | Revert files only; conversation unchanged |
| Summarize from here | Compact conversation starting at this point |
| Summarize up to here | Compact conversation up to this point |

**Limitations:** Bash command side-effects are not tracked. Changes made by external tools or processes outside Claude are not tracked.

### Remote Control

Connect a claude.ai/code web session or Claude mobile app to your local CLI session.

**Start remote control:**

| Method | Command |
|:-------|:--------|
| From CLI | `claude remote-control` or `claude --remote-control` |
| From within session | `/remote-control` command |

**Server mode spawn options (`--spawn`):**

| Option | Effect |
|:-------|:-------|
| `same-dir` | Opens new session in same working directory |
| `worktree` | Opens new session in a fresh worktree |
| `session` | Resumes a named session |

### Scheduled Tasks (`/loop`)

The `/loop` command runs recurring tasks during a session.

**Interval modes:**

| Mode | Syntax | Description |
|:-----|:-------|:------------|
| Fixed interval | `/loop every 5m <task>` | Run every N minutes/hours |
| Dynamic interval | `/loop <task>` (Claude decides timing) | Claude picks interval |
| Bare (no args) | `/loop` | Built-in session maintenance prompt |

**Cron tools Claude can use:**

| Tool | Description |
|:-----|:------------|
| `CronCreate` | Create a new scheduled task |
| `CronList` | List all scheduled tasks |
| `CronDelete` | Delete a scheduled task |

Session-scoped; expire after 7 days; max 50 tasks per session.

### Desktop Scheduled Tasks

Local scheduled tasks in the desktop app (machine must be awake to run).

**Schedule options:**

| Option | Description |
|:-------|:------------|
| Manual | Run on demand only |
| Hourly | Every hour |
| Daily | Once per day |
| Weekdays | Monday–Friday |
| Weekly | Once per week |

Missed runs: one catch-up run for the most recently missed time; earlier missed runs are skipped.

### Voice Dictation

Speak to Claude instead of typing.

**Modes:**

| Mode | How it works |
|:-----|:------------|
| Hold mode (push-to-talk) | Hold Space to record; release to submit |
| Tap mode | Tap to start recording; tap again to stop |

**Settings:**

| Setting | Values |
|:--------|:-------|
| `voice.enabled` | `true` / `false` |
| `voice.mode` | `"hold"` / `"tap"` |
| Rebind push-to-talk key | Via `voice:pushToTalk` keybinding |

**Requirements:** Claude.ai account required. Not available on Bedrock, Vertex AI, or API key authentication.

### Channels

Push events into a running Claude session from external services.

**Supported platforms:** Telegram, Discord, iMessage.

**Start with a channel:**
```
claude --channels plugin:<name>@marketplace
```

**Enterprise controls:**

| Setting | Description |
|:--------|:------------|
| `channelsEnabled` | Enable/disable channels feature-wide |
| `allowedChannelPlugins` | Allowlist of permitted channel plugin names |

**Building custom channel MCP servers:** implement the `claude/channel` capability; emit `notifications/claude/channel` events; provide reply tools; use `claude/channel/permission` for permission relay. Sender gating restricts which senders can push events.

### Context Window Explorer

Interactive visualization of how context is used and what survives compaction.

**What survives context compaction:**

| Survives | Does not survive |
|:---------|:----------------|
| Conversation summary | Detailed tool outputs |
| Final file states | Intermediate edits |
| User instructions | Search results no longer needed |
| Task context | Redundant reasoning steps |

**Context management strategies:** use `/compact` to manually compact; keep CLAUDE.md concise; use subagents for large search operations that would flood the main context.

### Fullscreen Rendering

Renders Claude Code in an alternate screen buffer (like vim or htop).

**Enable:**

| Method | Detail |
|:-------|:-------|
| Command | `/tui fullscreen` |
| Environment variable | `CLAUDE_CODE_NO_FLICKER=1` |

**Shortcuts in fullscreen mode:**

| Key | Action |
|:----|:-------|
| `Ctrl+O` | Toggle transcript mode |
| Mouse support | Enabled automatically |
| Scroll shortcuts | Available for navigating output |

### Routines

Cloud-based automation running on Anthropic-managed infrastructure.

**Trigger types:**

| Trigger | Description |
|:--------|:------------|
| Scheduled | Cron-style schedule |
| API (`/fire` endpoint) | HTTP POST to trigger on demand |
| GitHub PR | Fires on pull request events |
| GitHub Release | Fires on release events |

**Create routines:** via web at `claude.ai/code/routines` or from CLI with `/schedule`.

### Deep Links

Open Claude Code sessions from URLs or other apps using the `claude-cli://open` scheme.

**URL parameters:**

| Parameter | Description |
|:----------|:------------|
| `q` | Initial prompt to send |
| `cwd` | Working directory to open |
| `repo` | Repository URL to clone and open |

The URL handler is registered automatically on first interactive session. Platform support varies.

### Agent View (`claude agents`)

One-screen dashboard for all background sessions.

**Session states:**

| State | Description |
|:------|:------------|
| Working | Actively running |
| Needs input | Waiting for user response |
| Idle | Paused, no pending work |
| Completed | Finished successfully |
| Failed | Ended with an error |
| Stopped | Manually stopped |

**Keyboard shortcuts:**

| Key | Action |
|:----|:-------|
| Space | Peek at session output |
| Enter or → | Attach to session (take over) |
| ← | Detach from session |

Agent view is opened with `claude agents` (separate from `/agents` inside a session).

### Parallel Agents — Approach Comparison

| Approach | Who coordinates | Inter-agent comms | File isolation |
|:---------|:----------------|:-----------------|:--------------|
| Subagents | Claude, in current session | Results returned to parent | Optional (worktrees) |
| Agent view | You (hand off, check back) | None | Automatic worktrees |
| Agent teams | Claude (lead + teammates) | Shared task list + messages | Manual partitioning |
| Dynamic workflows | Script (not Claude's turn) | Cross-check results | Via script |

**Monitor commands:**

| Command | What it shows |
|:--------|:-------------|
| `claude agents` | All background sessions (agent view) |
| `/agents` | Running subagents + subagent library |
| `/tasks` | Background tasks in current session |
| `/workflows` | Dynamic workflow runs and phases |

### Worktrees

Isolate parallel Claude sessions in separate git checkouts.

**CLI usage:**

| Command | Effect |
|:--------|:-------|
| `claude --worktree feature-auth` | Create worktree named `feature-auth` |
| `claude --worktree` (no name) | Auto-generate a worktree name |
| `claude --worktree "#1234"` | Branch from GitHub PR #1234 |

Worktrees are created under `.claude/worktrees/<name>/` on branch `worktree-<name>`.

**Base branch settings (`worktree.baseRef`):**

| Value | Effect |
|:------|:-------|
| `"fresh"` (default) | Branch from `origin/HEAD` |
| `"head"` | Branch from local `HEAD` (carries unpushed commits) |

**`.worktreeinclude` file:** place at project root; uses `.gitignore` syntax; copies matching gitignored files (e.g., `.env`) into new worktrees automatically.

**Subagent isolation:** add `isolation: worktree` to custom subagent frontmatter, or ask Claude to "use worktrees for your agents."

**Cleanup rules:**
- No changes: worktree and branch removed automatically
- Changes exist: Claude prompts to keep or remove
- Non-interactive (`-p`): no auto-cleanup; use `git worktree remove` manually
- Subagent worktrees: auto-removed after `cleanupPeriodDays` if no uncommitted changes

### Prompt Caching

**Cache is invalidated by:**

| Action | Invalidates cache |
|:-------|:-----------------|
| Switch model | Yes |
| Change effort level | Yes |
| Enable fast mode | Yes |
| Connect/disconnect MCP server | Yes |
| Enable/disable plugin | Yes |
| Deny a tool | Yes |
| Context compaction | Yes |
| Upgrade Claude Code | Yes |

**Cache is preserved by:**

| Action | Preserves cache |
|:-------|:----------------|
| Edit files | Yes |
| Edit CLAUDE.md mid-session | Yes |
| Change output style | Yes |
| Change permission mode | Yes |

**TTL:**

| Auth type | Cache TTL |
|:----------|:---------|
| Subscription | 1 hour |
| API key | 5 minutes |
| API key (override) | Set `ENABLE_PROMPT_CACHING_1H=1` for 1 hour |

### Prompt Library

Interactive library of copy-paste prompts organized by task, role, and SDLC phase.

**Categories:**

| Category | Focus |
|:---------|:------|
| Discover | Exploring and understanding codebases |
| Design | Architecture, planning, and API design |
| Build | Writing and implementing code |
| Ship | Testing, reviewing, and deploying |
| Operate | Monitoring, debugging, and maintaining |

Access the prompt library from within Claude Code for filtered, copy-ready prompts tagged by use case.

## Full Documentation

For the complete official documentation, see the reference files:

- [Features overview](references/claude-code-features-overview.md) — Extension types (CLAUDE.md, skills, MCP, subagents, hooks, plugins), feature comparison table, context costs
- [Fast mode](references/claude-code-fast-mode.md) — Faster Opus responses, pricing tiers, toggling with `/fast`, requirements
- [Model configuration](references/claude-code-model-config.md) — Model aliases, effort levels, extended context windows, environment variable overrides
- [Output styles](references/claude-code-output-styles.md) — Built-in styles, creating custom styles, frontmatter fields, plugin force-activation
- [Status line](references/claude-code-statusline.md) — Custom status bar via shell commands, JSON input fields, refresh configuration
- [Checkpointing](references/claude-code-checkpointing.md) — Automatic file edit tracking, rewind menu, restore actions, limitations
- [Remote control](references/claude-code-remote-control.md) — Connect web/mobile to local CLI, server mode, spawn options
- [Scheduled tasks](references/claude-code-scheduled-tasks.md) — `/loop` command, fixed/dynamic intervals, CronCreate/List/Delete tools
- [Voice dictation](references/claude-code-voice-dictation.md) — Hold and tap modes, requirements, settings, keybinding customization
- [Channels](references/claude-code-channels.md) — Push events from Telegram/Discord/iMessage, enterprise controls
- [Channels reference](references/claude-code-channels-reference.md) — Building custom channel MCP servers, capability schema, reply tools, sender gating
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) — Local desktop app scheduling, schedule options, missed-run behavior
- [Context window explorer](references/claude-code-context-window.md) — Interactive context simulation, what survives compaction, context management strategies
- [Fullscreen rendering](references/claude-code-fullscreen.md) — Alternate screen buffer mode, enable methods, mouse support, shortcuts
- [Routines](references/claude-code-routines.md) — Cloud-based automation, trigger types (schedule/API/GitHub), creation and management
- [Deep links](references/claude-code-deep-links.md) — `claude-cli://open` URL scheme, parameters, platform support
- [Agent view](references/claude-code-agent-view.md) — `claude agents` dashboard, session states, keyboard shortcuts, dispatch
- [Run agents in parallel](references/claude-code-agents.md) — Comparison of subagents, agent view, agent teams, dynamic workflows; monitoring commands
- [Worktrees](references/claude-code-worktrees.md) — `--worktree` flag, base branch config, `.worktreeinclude`, subagent isolation, cleanup rules
- [Prompt caching](references/claude-code-prompt-caching.md) — What invalidates vs preserves the cache, TTL by auth type
- [Prompt library](references/claude-code-prompt-library.md) — Interactive prompt library, categories, filtering by task/role/SDLC phase

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
- Context window explorer: https://code.claude.com/docs/en/context-window.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
- Routines: https://code.claude.com/docs/en/routines.md
- Deep links: https://code.claude.com/docs/en/deep-links.md
- Agent view: https://code.claude.com/docs/en/agent-view.md
- Run agents in parallel: https://code.claude.com/docs/en/agents.md
- Worktrees: https://code.claude.com/docs/en/worktrees.md
- Prompt caching: https://code.claude.com/docs/en/prompt-caching.md
- Prompt library: https://code.claude.com/docs/en/prompt-library.md
