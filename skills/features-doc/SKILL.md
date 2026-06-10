---
name: features-doc
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features including model configuration, output styles, parallel agents, checkpointing, voice, channels, scheduled tasks, worktrees, prompt caching, and more.

## Quick Reference

### Model Configuration

| Alias | Resolves to |
|---|---|
| `default` | Current default model |
| `best` | Highest-capability available (Fable 5 if access, else Opus) |
| `fable` | Fable 5 (requires access + v2.1.170+) |
| `opus` | Latest Claude Opus |
| `sonnet` | Latest Claude Sonnet |
| `haiku` | Latest Claude Haiku |
| `sonnet[1m]` / `opus[1m]` | Extended-context variants (1M token window) |
| `opusplan` | Opus for plan mode, Sonnet for execution |

**Effort levels** (set with `/effort` or `--effort`): `low`, `medium`, `high`, `xhigh`, `max`, `ultracode`

**Fast mode** (Opus only): `/fast` toggle; up to 2.5x faster at higher per-token cost. Opt in per-session with `fastModePerSessionOptIn: true`.

**Environment variables for model pinning**: `ANTHROPIC_MODEL`, `ANTHROPIC_SMALL_FAST_MODEL`

### Advisor Tool

Pair a main model with a stronger advisor model. Claude decides when to call it.

| Main model | Accepted advisors |
|---|---|
| Haiku 4.5 | Fable, Opus, Sonnet |
| Sonnet 4.6 | Fable, Opus, Sonnet |
| Opus 4.6+ | Fable, Opus at or above main version |
| Fable 5 | Fable only |

Enable: `/advisor opus`, `--advisor opus`, or `"advisorModel": "opus"` in settings. Disable: `/advisor off`. Requires Anthropic API (not Bedrock/Vertex/Foundry), v2.1.98+.

### Output Styles

| Style | Behavior |
|---|---|
| Default | Balanced responses |
| Proactive | Claude suggests next steps and improvements unprompted |
| Explanatory | Explains reasoning at each step |
| Learning | Teaching-focused with context and explanation |

Custom styles: Markdown files in `output-styles/` directory. Frontmatter `keep-coding-instructions: true` to preserve code output format. Use `force-for-plugin: true` in plugin styles.

### Checkpointing

Automatic per-prompt checkpoints. Restore via `/rewind` or double Esc.

Restore options: code + conversation, code only, conversation only, summarize from/up-to here. 30-day retention.

### Worktrees

| Flag/Setting | Purpose |
|---|---|
| `--worktree <name>` / `-w <name>` | Create isolated git worktree and start session in it |
| `--worktree` (no name) | Auto-generate worktree name |
| `worktree.baseRef: "head"` | Branch from local HEAD instead of origin/HEAD |
| `--worktree "#1234"` | Branch from PR number |
| `isolation: worktree` | Custom subagent frontmatter for per-agent worktrees |

`.worktreeinclude` file (gitignore syntax) copies matched gitignored files (like `.env`) into new worktrees. Worktrees created at `.claude/worktrees/<name>/`.

Cleanup: empty worktrees auto-removed on exit; worktrees with changes prompt keep/remove. `WorktreeCreate`/`WorktreeRemove` hooks for non-git VCS.

### Parallel Agents Overview

| Approach | Coordination | Use when |
|---|---|---|
| Subagents | Claude delegates inside one session | Side tasks that would flood main conversation |
| Agent view (`claude agents`) | You dispatch and monitor background sessions | Independent tasks to hand off |
| Agent teams | Claude leads and manages workers (experimental) | Claude splits project, assigns, supervises |
| Dynamic workflows | Script holds the plan, many subagents | 500-file migrations, codebase audits, cross-checked research |

Check running work: `claude agents` → agent view; `/agents` → subagent panel; `/tasks` → background tasks; `/workflows` → workflow runs.

### Agent View

`claude agents` opens the agent view dashboard. Session states: Working / Needs input / Idle / Completed / Failed / Stopped.

Background sessions: `claude --bg "prompt"`. Each background session gets its own worktree. Attach with `claude agents` then select session.

Shell management: `claude agents shell list`, `claude agents shell attach <id>`, `claude agents shell stop <id>`.

### Prompt Caching

Cache layers: system prompt → project context → conversation turns. TTL: 5 minutes default, 1 hour on subscription.

**Actions that invalidate cache** (restart from scratch):
- Model switch, effort change, fast mode enable
- MCP server connect/disconnect
- Plugin enable/disable
- Tool added to deny list
- Compaction, upgrade

**Actions that keep cache**:
- `/advisor` toggle, file edits, new turns, adding tools to allow list (non-deny)

Disable: `DISABLE_PROMPT_CACHING=1` (API) or `DISABLE_PROMPT_CACHING_SUBSCRIPTION=1` (subscription).

### Channels (MCP Push Events)

MCP servers that push events into running sessions. Built-in channels: Telegram, Discord, iMessage.

Enable: `--channels` flag or `channelsEnabled: true`. Restrict to specific plugins: `allowedChannelPlugins`. Sender allowlist and pairing for security.

Custom channel MCP servers: declare `claude/channel` capability; emit `notifications/claude/channel` events; permission relay via `claude/channel/permission`. Dev flag: `--dangerously-load-development-channels`.

### Scheduled Tasks (CLI)

`/loop` bundled skill: fixed interval, dynamic interval (Claude chooses), built-in maintenance prompt. Customize with `loop.md`. One-time reminders supported.

CronCreate/CronList/CronDelete tools. 7-day expiry. Disable: `CLAUDE_CODE_DISABLE_CRON=1`.

### Scheduled Tasks (Desktop)

Presets: Manual, Hourly, Daily, Weekdays, Weekly. Runs while app is open; catch-up runs on wake. Each task stored as SKILL.md at `~/.claude/scheduled-tasks/<name>/`. Configure via `update_scheduled_task` MCP tool.

### Remote Control

Continue local sessions from phone/browser.

| Mode | Behavior |
|---|---|
| `same-dir` | Resume most recent session in current directory |
| `worktree` | Create a new worktree for the remote session |
| `session` | Resume a specific session by ID |

Start server: `claude remote-control` or `claude --remote-control`. Toggle in session: `/remote-control`. Requires Claude.ai account. Push notifications on mobile.

### Voice Dictation

`/voice` — hold Space (hold mode) or `/voice tap` (tap mode). 20 supported languages. Rebind push-to-talk: `voice:pushToTalk` in `keybindings.json`. Requires Claude.ai account and local microphone.

### Statusline

Custom status bar via shell script. Configure with `/statusline` or `subagentStatusLine` setting.

Available JSON fields: `model`, `context_window`, `cost`, `rate_limits`, `workspace`, `vim`, `pr`, `worktree`, `session_id`, `subagent_count`, `background_task_count`, `is_plan_mode`, `connection_status`.

### Deep Links

URL scheme: `claude-cli://open?q=<prompt>&cwd=<dir>&repo=<owner/repo>`

VS Code variant: `vscode://anthropic.claude-code/open`. Disable registration: `disableDeepLinkRegistration: true`.

### Fullscreen / TUI Mode

`/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1`. Uses alternate screen buffer. Mouse support: click, drag, scroll wheel. `Ctrl+O` for transcript mode (less-style search). `PgUp`/`PgDn` scroll. `CLAUDE_CODE_SCROLL_SPEED` env var. Note: tmux may require `set -g mouse on`.

### Cloud Routines

Scheduled sessions on Anthropic's infrastructure. Create at claude.ai/code/routines or via `/schedule`.

Trigger types: schedule, API (HTTP POST with bearer token), GitHub webhook (pull_request, release events). Daily run cap applies. Requires Claude Code on the web.

### Context Window

Context loads at startup: CLAUDE.md files, skills, memory, MCP tool definitions. Grows during work with tool call results and responses. Subagents get isolated context. Use `/context` command to view breakdown.

What survives compaction: CLAUDE.md content, active skills, explicit memory, current file edits (but not raw tool output history).

### Features Overview

Extension layers ranked by context cost (low to high): CLAUDE.md → Skills → Subagents → Agent teams. MCP, Hooks, and Plugins add capabilities orthogonally.

## Full Documentation

- [Features Overview](references/claude-code-features-overview.md) — Extension layer comparison, feature tables, context costs by feature
- [Fast Mode](references/claude-code-fast-mode.md) — Faster Opus execution at higher per-token cost, pricing, opt-in settings
- [Model Configuration](references/claude-code-model-config.md) — Model aliases, effort levels, extended context, Fable 5, fallback chains, env vars
- [Output Styles](references/claude-code-output-styles.md) — Built-in styles, custom Markdown styles, plugin style enforcement
- [Statusline](references/claude-code-statusline.md) — Custom status bar via script, available JSON fields, examples
- [Checkpointing](references/claude-code-checkpointing.md) — Automatic per-prompt checkpoints, /rewind, restore options, retention
- [Remote Control](references/claude-code-remote-control.md) — Continue local sessions remotely, server modes, push notifications
- [Scheduled Tasks (CLI)](references/claude-code-scheduled-tasks.md) — /loop skill, CronCreate/List/Delete tools, intervals, 7-day expiry
- [Voice Dictation](references/claude-code-voice-dictation.md) — /voice command, hold/tap modes, languages, keybinding
- [Channels](references/claude-code-channels.md) — MCP push events into sessions, Telegram/Discord/iMessage, sender allowlist
- [Channels Reference](references/claude-code-channels-reference.md) — Build custom channel MCP servers, capability declaration, permission relay
- [Desktop Scheduled Tasks](references/claude-code-desktop-scheduled-tasks.md) — Desktop app presets, catch-up runs, task SKILL.md on disk
- [Context Window](references/claude-code-context-window.md) — What loads at startup, what survives compaction, /context command
- [Fullscreen / TUI Mode](references/claude-code-fullscreen.md) — Alternate screen buffer, mouse support, transcript mode, tmux caveats
- [Cloud Routines](references/claude-code-routines.md) — Schedule/API/GitHub triggers, cloud infrastructure, run caps
- [Deep Links](references/claude-code-deep-links.md) — claude-cli://open URL scheme, parameters, VS Code variant, disable setting
- [Agent View](references/claude-code-agent-view.md) — claude agents dashboard, session states, background sessions, shell management
- [Run Agents in Parallel](references/claude-code-agents.md) — Subagents vs agent view vs agent teams vs dynamic workflows comparison
- [Worktrees](references/claude-code-worktrees.md) — --worktree flag, .worktreeinclude, subagent isolation, non-git VCS hooks, cleanup
- [Prompt Caching](references/claude-code-prompt-caching.md) — Cache layers, TTL, cache-invalidating vs cache-preserving actions
- [Prompt Library](references/claude-code-prompt-library.md) — 50+ copy-paste prompts tagged by SDLC phase and role
- [Advisor Tool](references/claude-code-advisor.md) — Pair main model with stronger advisor, model pairings, billing, requirements

## Sources

- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Statusline: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled Tasks (CLI): https://code.claude.com/docs/en/scheduled-tasks.md
- Voice Dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels Reference: https://code.claude.com/docs/en/channels-reference.md
- Desktop Scheduled Tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Context Window: https://code.claude.com/docs/en/context-window.md
- Fullscreen / TUI Mode: https://code.claude.com/docs/en/fullscreen.md
- Cloud Routines: https://code.claude.com/docs/en/routines.md
- Deep Links: https://code.claude.com/docs/en/deep-links.md
- Agent View: https://code.claude.com/docs/en/agent-view.md
- Run Agents in Parallel: https://code.claude.com/docs/en/agents.md
- Worktrees: https://code.claude.com/docs/en/worktrees.md
- Prompt Caching: https://code.claude.com/docs/en/prompt-caching.md
- Prompt Library: https://code.claude.com/docs/en/prompt-library.md
- Advisor Tool: https://code.claude.com/docs/en/advisor.md
