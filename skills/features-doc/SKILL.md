---
name: features-doc
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features: model configuration, fast mode, output styles, status line, checkpointing, remote control, scheduled tasks, voice dictation, channels, context window management, fullscreen rendering, routines, deep links, agent view, parallel agents, worktrees, prompt caching, and the prompt library.

## Quick Reference

### Feature Categories at a Glance

| Feature | What it does | Key entry point |
|:--------|:-------------|:----------------|
| Fast mode | Use a smaller model for low-complexity turns | `/fast` toggle or `--fast` flag |
| Model config | Set which model Claude uses and effort level | `/model`, `ANTHROPIC_MODEL` env var |
| Output styles | Control response formatting and verbosity | `/output-style` or frontmatter |
| Status line | Show live session metrics in your terminal | `CLAUDE_STATUS_LINE` env var |
| Checkpointing | Snapshot and restore file state mid-session | `/rewind` or double-Esc |
| Remote control | Drive Claude from another process or script | `claude remote-control` |
| Scheduled tasks | Run Claude on a cron schedule | `/loop`, Desktop tasks, or Routines |
| Voice dictation | Dictate prompts instead of typing | `/voice` toggle |
| Channels | Push events to external apps (Telegram, etc.) | `--channels` flag + plugin |
| Context window | Monitor and manage token usage | `/context` command |
| Fullscreen | Render in an alternate screen buffer | `/tui fullscreen` |
| Routines | Cloud-hosted scheduled sessions | `/schedule` or API/GitHub triggers |
| Deep links | Open Claude from URLs or scripts | `claude-cli://open?q=...` |
| Agent view | Monitor and dispatch background sessions | `claude agents` |
| Parallel agents | Run multiple agents at once | Subagents, agent view, agent teams |
| Worktrees | Isolate sessions in separate git checkouts | `claude --worktree <name>` |
| Prompt caching | Reuse cached prefixes across turns | Automatic; configured by TTL |
| Prompt library | Pre-built prompts for SDLC phases | `/library` or natural language |

### Model Aliases

| Alias | Resolves to |
|:------|:------------|
| `default` | Current default model |
| `best` | Highest-capability model available |
| `sonnet` | Latest Claude Sonnet |
| `opus` | Latest Claude Opus |
| `haiku` | Latest Claude Haiku |
| `sonnet[1m]` | Sonnet with 1M-token context |
| `opus[1m]` | Opus with 1M-token context |
| `opusplan` | Opus optimized for planning |

Set with `/model <alias>` or the `ANTHROPIC_MODEL` environment variable.

### Effort Levels

| Level | Description |
|:------|:------------|
| `low` | Quick, low-token responses |
| `medium` | Balanced speed and quality |
| `high` | Default for most tasks |
| `xhigh` | Extended thinking enabled |
| `max` | Maximum thinking budget |
| `ultracode` | Specialized for large code tasks |

Set with `/effort <level>` or `--effort` CLI flag.

### Output Styles

| Style | Description |
|:------|:------------|
| `concise` | Short answers, fewer explanations |
| `normal` | Default conversational style |
| `detailed` | Full explanations and context |
| `auto` | Adapts to task complexity |
| Custom | Define via SKILL.md or CLAUDE.md frontmatter |

Toggle with `/output-style` or set `outputStyle` in settings.

### Fast Mode

Fast mode routes qualifying turns to a smaller, faster model. It is toggled per-session and does not change the configured model permanently.

| Command | Effect |
|:--------|:-------|
| `/fast` | Toggle fast mode on/off |
| `--fast` | Start session with fast mode enabled |
| `Ctrl+F` | Keyboard shortcut to toggle (interactive mode) |

Fast mode activates automatically for simple turns when `autoFast` is enabled in settings. Turns that create files, run code, or involve complex reasoning bypass fast mode automatically.

### Status Line Configuration

Set `CLAUDE_STATUS_LINE` to a format string. Data is injected from a JSON object Claude writes to `$CLAUDE_STATUS_JSON_PATH`.

Key JSON data fields:

| Field | Description |
|:------|:------------|
| `model` | Active model name |
| `effort` | Current effort level |
| `tokens_used` | Tokens consumed this turn |
| `tokens_total` | Cumulative session tokens |
| `cost_usd` | Estimated cost in USD |
| `turn` | Turn number |
| `fast_mode` | Whether fast mode is active |
| `session_id` | Current session identifier |

Shell scripts can poll `$CLAUDE_STATUS_JSON_PATH` to render a live status display in tmux, Starship, or similar tools.

### Checkpointing Actions

Checkpoints are automatic snapshots of all file state taken before each turn.

| Action | How to invoke |
|:-------|:-------------|
| View checkpoint list | `/rewind` |
| Restore a checkpoint | `/rewind` then select, or double-Esc |
| Restore and keep conversation | Choose "restore files only" |
| Restore and trim conversation | Choose "restore files and conversation" |
| Disable checkpointing | `"checkpointing": false` in settings |

Checkpoints are stored in `.claude/checkpoints/` and auto-purged after `cleanupPeriodDays`.

### Remote Control

Remote control lets an external process send prompts to a running Claude session.

| Start mode | Command |
|:-----------|:--------|
| Start listener | `claude remote-control` or `claude --remote-control` |
| Enable in session | `/remote-control` command |

The socket path is printed when the listener starts. Send JSON payloads to submit prompts, inject context, or read session output. Useful for driving Claude from test harnesses, CI scripts, or other tools.

### Scheduling Options Comparison

| Approach | Where it runs | Persistence | Trigger |
|:---------|:-------------|:------------|:--------|
| `/loop` | Local machine | Until you stop it | Cron expression or interval |
| Desktop scheduled tasks | Local machine | System task scheduler | Time-based |
| Routines | Anthropic cloud | Always-on | Schedule, API call, or GitHub event |

**`/loop` / CronCreate commands:**

| Command | Action |
|:--------|:-------|
| `/loop <expr> <prompt>` | Schedule a repeating task |
| `CronCreate` tool | Create a cron job programmatically |
| `CronList` tool | List active cron jobs |
| `CronDelete` tool | Remove a cron job |

Cron jobs expire after 7 days unless renewed.

**Routines** run in Anthropic's infrastructure; access via `/schedule`, the Routines API, or GitHub event webhooks.

### Voice Dictation Modes

| Mode | How it works |
|:-----|:------------|
| Hold mode | Hold a key, speak, release to submit |
| Tap mode | Tap to start, tap again to submit |

| Command | Action |
|:--------|:-------|
| `/voice` | Toggle voice dictation on/off |
| `/voice hold` | Switch to hold mode |
| `/voice tap` | Switch to tap mode |

Voice dictation uses the system microphone and requires OS-level microphone permission. Transcription runs locally by default.

### Channels

Channels let Claude push events to external messaging apps via MCP.

| Step | Detail |
|:-----|:-------|
| Install plugin | e.g., `claudemd-telegram`, `claudemd-discord`, `claudemd-imessage` |
| Start session | Pass `--channels` flag or enable in settings |
| Receive events | Claude sends turn completions, errors, and custom events to the channel |

The MCP server handles authentication and message formatting. Multiple channels can be active simultaneously.

### Context Window Management

| Command / Feature | Description |
|:-----------------|:------------|
| `/context` | Show current token usage breakdown |
| `/compact` | Summarize and compress conversation history |
| Auto-compact | Triggers when context nears limit (configurable threshold) |
| `maxContextTokens` | Setting to cap context before auto-compact fires |

Context usage shown as: system prompt + conversation + tool results + pending response.

### Fullscreen Rendering

| Command | Action |
|:--------|:-------|
| `/tui fullscreen` | Enter alternate screen buffer (fullscreen mode) |
| `Ctrl+O` | Toggle transcript overlay while in fullscreen |
| `q` or `Esc` | Exit fullscreen and return to normal terminal |

Fullscreen mode renders Claude's output in a full-terminal TUI. Useful on small screens or when you want to separate Claude's output from your terminal history.

### Routines

Routines are cloud-hosted Claude sessions that run on a schedule without a local machine.

| Trigger type | How to set up |
|:-------------|:-------------|
| Schedule | `/schedule <cron> <prompt>` or Routines API |
| API call | POST to your routine's endpoint |
| GitHub event | Connect via GitHub webhook in Routines settings |

Routines persist state across runs, can read/write to connected repositories, and support the same tools as interactive sessions.

### Deep Links

Deep links open Claude from a URL, script, or browser.

| Parameter | Description |
|:----------|:------------|
| `q` | Prompt text to pre-fill |
| `cwd` | Working directory to open Claude in |
| `repo` | Repository URL or path to clone/open |

Example: `claude-cli://open?q=explain+this+code&cwd=/home/user/project`

Deep links can be embedded in documentation, issue trackers, or shell aliases to launch targeted Claude sessions.

### Agent View

`claude agents` opens a monitoring interface for all background sessions.

| Column / State | Description |
|:--------------|:------------|
| `running` | Session is actively processing |
| `waiting` | Session is idle, waiting for input |
| `done` | Session has completed |
| `error` | Session ended with an error |

| Key | Action |
|:----|:-------|
| `Enter` | Attach to selected session |
| `n` | Dispatch a new background session |
| `s` | Stop selected session |
| `d` | Delete (remove) completed session |
| `r` | Refresh session list |
| `q` | Quit agent view |

Agent view automatically moves each dispatched session into its own worktree.

### Parallel Agents Comparison

| Approach | Coordinates | Workers communicate | File isolation |
|:---------|:-----------|:-------------------|:---------------|
| Subagents | Claude (in-session) | Report back to parent | Optional worktree per subagent |
| Agent view | You (via `claude agents`) | Only through you | Automatic worktree per session |
| Agent teams | Claude (lead + teammates) | Shared task list + messaging | No auto-isolation; partition files manually |
| Dynamic workflows | Script / workflow definition | Via workflow state | Subagent worktrees |

### Worktrees Quick Reference

| Command | Action |
|:--------|:-------|
| `claude --worktree <name>` | Create worktree and start Claude in it |
| `claude --worktree` | Create worktree with generated name |
| `claude --worktree "#1234"` | Create worktree from PR #1234 |
| `git worktree list` | List all worktrees |
| `git worktree remove <path>` | Remove a worktree manually |

| Setting | Values | Description |
|:--------|:-------|:------------|
| `worktree.baseRef` | `"fresh"` (default) or `"head"` | Branch new worktrees from `origin/HEAD` or local `HEAD` |

Add `.worktreeinclude` to project root to copy gitignored files (like `.env`) into new worktrees. Uses `.gitignore` syntax.

Cleanup behavior: worktrees with no changes are removed automatically on exit; those with commits or changes prompt you to keep or discard.

### Prompt Caching

Caching reuses a computed prefix from a previous turn instead of reprocessing it.

| Cache hits when | Cache misses when |
|:----------------|:-----------------|
| System prompt is identical | System prompt changes |
| Conversation prefix matches | New turn inserts text before cached point |
| Skills / CLAUDE.md unchanged | Skills reload or CLAUDE.md changes |
| Tool definitions unchanged | Tool list changes |

| Context | Cache TTL |
|:--------|:---------|
| Claude.ai subscription | 1 hour |
| Anthropic API | 5 minutes |

Prompt caching is automatic. Cost savings are shown in `/context` output. Cache breakpoints are set at the end of the system prompt and after every 1,024 tokens of conversation prefix.

### Prompt Library

The prompt library provides pre-built prompts organized by SDLC phase and task category. Access with `/library` or by describing the task you want.

| Phase | Example categories |
|:------|:------------------|
| Plan | Requirements, architecture, estimation |
| Build | Implement feature, write tests, refactor |
| Review | Code review, security audit, dependency audit |
| Deploy | Release notes, deployment checklist |
| Maintain | Bug triage, incident response, documentation |

Prompts can be parameterized and combined with skills for repeatable workflows.

## Full Documentation

For the complete official documentation, see the reference files:

- [Fast Mode](references/claude-code-fast-mode.md) — Enabling fast mode, auto-fast routing, keyboard shortcut, and settings
- [Model Configuration](references/claude-code-model-config.md) — Model aliases, effort levels, per-session overrides, and environment variables
- [Output Styles](references/claude-code-output-styles.md) — Built-in styles, custom style definitions, frontmatter configuration, and per-session overrides
- [Status Line](references/claude-code-statusline.md) — Format string syntax, JSON data fields, shell integration examples, and tmux/Starship setup
- [Checkpointing](references/claude-code-checkpointing.md) — Automatic snapshots, `/rewind` restore options, storage location, and cleanup settings
- [Features Overview](references/claude-code-features-overview.md) — High-level comparison of Claude Code capability areas and where each feature fits
- [Remote Control](references/claude-code-remote-control.md) — Socket protocol, start modes, JSON payload schema, and scripting examples
- [Scheduled Tasks](references/claude-code-scheduled-tasks.md) — `/loop` syntax, CronCreate/CronList/CronDelete tools, expiry, and task management
- [Voice Dictation](references/claude-code-voice-dictation.md) — Hold mode vs tap mode, `/voice` commands, microphone permissions, and transcription options
- [Channels](references/claude-code-channels.md) — Channel setup, `--channels` flag, plugin list, and event types
- [Channels Reference](references/claude-code-channels-reference.md) — MCP channel protocol, event schema, plugin configuration, and authentication
- [Desktop Scheduled Tasks](references/claude-code-desktop-scheduled-tasks.md) — Desktop app task scheduler, local cron integration, and task management UI
- [Context Window](references/claude-code-context-window.md) — Token usage display, `/compact` command, auto-compact threshold, and `maxContextTokens` setting
- [Fullscreen](references/claude-code-fullscreen.md) — `/tui fullscreen` command, alternate screen buffer, transcript overlay, and exit controls
- [Routines](references/claude-code-routines.md) — Cloud-hosted sessions, schedule/API/GitHub triggers, `/schedule` CLI, and state persistence
- [Deep Links](references/claude-code-deep-links.md) — URL scheme, query parameters, browser and script usage, and examples
- [Agent View](references/claude-code-agent-view.md) — `claude agents` interface, session states, keyboard shortcuts, dispatching, and file isolation
- [Run Agents in Parallel](references/claude-code-agents.md) — Comparison of subagents, agent view, agent teams, and dynamic workflows
- [Run Parallel Sessions with Worktrees](references/claude-code-worktrees.md) — `--worktree` flag, base branch selection, `.worktreeinclude`, subagent isolation, cleanup, and non-git VCS hooks
- [Prompt Caching](references/claude-code-prompt-caching.md) — Cache prefix mechanics, TTL by context, invalidation triggers, and cost reporting
- [Prompt Library](references/claude-code-prompt-library.md) — SDLC phases, prompt categories, parameterization, and workflow integration

## Sources

- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled Tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Voice Dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels Reference: https://code.claude.com/docs/en/channels-reference.md
- Desktop Scheduled Tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Context Window: https://code.claude.com/docs/en/context-window.md
- Fullscreen: https://code.claude.com/docs/en/fullscreen.md
- Routines: https://code.claude.com/docs/en/routines.md
- Deep Links: https://code.claude.com/docs/en/deep-links.md
- Agent View: https://code.claude.com/docs/en/agent-view.md
- Run Agents in Parallel: https://code.claude.com/docs/en/agents.md
- Run Parallel Sessions with Worktrees: https://code.claude.com/docs/en/worktrees.md
- Prompt Caching: https://code.claude.com/docs/en/prompt-caching.md
- Prompt Library: https://code.claude.com/docs/en/prompt-library.md
