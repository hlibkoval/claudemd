---
name: features-doc
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code's extended features: model configuration, fast mode, output styles, status line customization, checkpointing, remote control, scheduled tasks, voice dictation, channels, context window internals, prompt caching, prompt library, deep links, agent view, parallel agents, worktrees, and the features overview.

## Quick Reference

### Extension Layer Overview

| Feature | What it does | Loads |
|:--------|:-------------|:------|
| **CLAUDE.md** | Persistent context every session | Session start, always |
| **Skills** | Reusable knowledge and workflows | Descriptions at start; full content on use |
| **Code intelligence (LSP)** | Symbol navigation, live type errors | After file edits and on demand |
| **MCP** | Connect to external services | Tool names at start; schemas on demand |
| **Subagents** | Isolated workers with own context | On demand |
| **Agent teams** | Multiple coordinated sessions | On demand (experimental) |
| **Hooks** | Scripts triggered by lifecycle events | Zero cost unless hook returns output |
| **Plugins** | Package and distribute feature sets | Per plugin load |

### Decision Guide: Which Feature to Use?

| Trigger | Add |
|:--------|:----|
| Claude repeats a convention mistake | Add it to CLAUDE.md |
| You keep typing the same prompt | Save as a user-invocable skill |
| You paste the same playbook into chat repeatedly | Capture it as a skill |
| Claude can't see data in a browser tab | Connect that system as MCP |
| Claude reads many files to find a symbol | Install a code intelligence plugin |
| A side task floods your conversation | Route through a subagent |
| Something must happen every time without asking | Write a hook |
| Another repo needs the same setup | Package as a plugin |

### CLAUDE.md vs Skill vs Rules

| Aspect | CLAUDE.md | `.claude/rules/` | Skill |
|:-------|:----------|:-----------------|:------|
| Loads | Every session | Every session (or on file match) | On demand |
| Scope | Whole project | Can be path-scoped | Task-specific |
| Best for | Core conventions, build commands | Language/directory guidelines | Reference material, repeatable workflows |

Keep CLAUDE.md under 200 lines. Move reference content to skills or `.claude/rules/` files.

### Hook vs Skill

| Aspect | Hook | Skill |
|:-------|:-----|:------|
| Triggered by | Lifecycle events (PostToolUse, SessionStart…) | `/name` invocation or Claude matching description |
| Determinism | Always fires on its event | Claude interprets; outcome can vary |
| Context cost | Zero unless hook returns output | Descriptions load each session |
| Best for | Linting, blocking unsafe commands, logging | Reasoning-dependent workflows, reference material |

Put guardrails in hooks: an instruction in CLAUDE.md is a request; a `PreToolUse` hook that blocks is enforcement.

### Subagent vs Agent Team

| Aspect | Subagent | Agent team |
|:-------|:---------|:-----------|
| Context | Own window; results return to caller | Own window; fully independent |
| Communication | Reports to main agent only | Teammates message each other |
| Coordination | Main agent manages all work | Shared task list, self-coordinating |
| Best for | Focused tasks where only result matters | Complex work needing discussion |
| Token cost | Lower (results summarized back) | Higher (each teammate is separate instance) |

### Model Aliases

| Alias | Behavior |
|:------|:---------|
| `default` | Clears override, reverts to recommended model for account type |
| `best` | Most capable model (currently equivalent to `opus`) |
| `sonnet` | Latest Sonnet for daily coding tasks |
| `opus` | Latest Opus for complex reasoning |
| `haiku` | Fast, efficient model for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Uses Opus in plan mode, switches to Sonnet for execution |

**Default model by account type:**
- Max, Team Premium, Enterprise pay-as-you-go, API: Opus 4.8
- Claude Platform on AWS: Opus 4.7
- Pro, Team Standard, Enterprise subscription seats: Sonnet 4.6
- Bedrock, Vertex, Foundry: Sonnet 4.5

**Setting your model** (in priority order):
1. During session: `/model <alias|name>`
2. At startup: `claude --model <alias|name>`
3. Environment variable: `ANTHROPIC_MODEL=<alias|name>`
4. Settings file: `"model": "opus"`

### Effort Levels

| Level | When to use |
|:------|:------------|
| `low` | Short, scoped, latency-sensitive tasks not intelligence-sensitive |
| `medium` | Cost-sensitive work that can trade some intelligence |
| `high` | Balanced (default on Opus 4.8, Opus 4.6, Sonnet 4.6) |
| `xhigh` | Deeper reasoning at higher cost (default on Opus 4.7) |
| `max` | Demanding tasks; session-only |
| `ultracode` | Plans a dynamic workflow for each substantive task; session-only |

Use `ultrathink` anywhere in a prompt to request deeper reasoning for that turn without changing session effort. Use `/effort` to change, `--effort` flag at launch, or `CLAUDE_CODE_EFFORT_LEVEL` env var.

**Extended context (1M tokens):**

| Plan | Opus 1M | Sonnet 1M |
|:-----|:--------|:----------|
| Max, Team, Enterprise | Included | Usage credits required |
| Pro | Usage credits required | Usage credits required |
| API / pay-as-you-go | Full access | Full access |

Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`. Use `[1m]` suffix with model picker: `/model opus[1m]`.

### Fast Mode

- Toggle: `/fast` or set `"fastMode": true` in settings
- Requires Opus 4.8, 4.7, or 4.6; CLI only (not VS Code extension)
- Indicator: `↯` icon next to prompt when active
- Falls back to standard speed on rate limit or out-of-credits (icon turns gray)

| Model | Input (MTok) | Output (MTok) |
|:------|:-------------|:--------------|
| Opus 4.8 | $10 | $50 |
| Opus 4.7 / 4.6 | $30 | $150 |

Fast mode draws from usage credits, not subscription limits. Team/Enterprise requires admin enablement. Set `fastModePerSessionOptIn: true` in managed settings to reset each session.

### Output Styles

**Built-in styles:**
- `Default` — standard software engineering system prompt
- `Proactive` — executes immediately, minimizes confirmation pauses
- `Explanatory` — adds educational "Insights" between tasks
- `Learning` — collaborative mode, adds `TODO(human)` markers for you to implement

**Change style:** run `/config` and select Output style. Stored in `"outputStyle"` setting. Takes effect after `/clear` or new session.

**Custom output style frontmatter:**

| Field | Purpose | Default |
|:------|:--------|:--------|
| `name` | Style name if not the filename | Inherits from filename |
| `description` | Shown in `/config` picker | None |
| `keep-coding-instructions` | Keep built-in software engineering instructions | `false` |
| `force-for-plugin` | Auto-apply when plugin is enabled | `false` |

### Status Line

Configured via `statusLine` in settings:

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

Use `/statusline <description>` to generate a script automatically.

**Key JSON fields available to status line scripts (via stdin):**

| Field | Description |
|:------|:------------|
| `model.id`, `model.display_name` | Current model |
| `workspace.current_dir`, `workspace.project_dir` | Working directories |
| `workspace.git_worktree` | Git worktree name (if in one) |
| `workspace.repo.host/owner/name` | Repository identity from origin remote |
| `context_window.used_percentage` | Context usage (input only) |
| `context_window.context_window_size` | Max tokens (200000 or 1000000) |
| `cost.total_cost_usd` | Estimated session cost |
| `cost.total_duration_ms` | Total wall-clock time |
| `effort.level` | Current effort level |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit (Pro/Max subscribers only) |
| `rate_limits.seven_day.used_percentage` | 7-day rate limit (Pro/Max subscribers only) |
| `session_id`, `session_name` | Session identity |
| `vim.mode` | Current vim mode when vim mode is enabled |
| `pr.number`, `pr.url`, `pr.review_state` | Open PR for current branch |
| `worktree.name`, `worktree.branch` | Worktree info (only in `--worktree` sessions) |

Updates fire after each assistant message, `/compact`, permission mode change, or vim mode toggle. Set `refreshInterval` for time-based segments. Test with mock input via `echo '{...}' | ./statusline.sh`.

### Checkpointing

Every user prompt creates a checkpoint automatically (30-day retention). Rewind with `/rewind` or double `Esc` on empty input.

**Rewind actions:**
- **Restore code and conversation** — revert both to selected point
- **Restore conversation** — rewind messages, keep current code
- **Restore code** — revert files, keep conversation
- **Summarize from here** — compress selected message and forward into summary
- **Summarize up to here** — compress everything before selected message

Limitations: bash command changes not tracked; external file changes not tracked; not a replacement for git.

### Scheduled Tasks Comparison

| | Cloud (Routines) | Desktop | `/loop` (CLI) |
|:-|:----------------|:--------|:--------------|
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Persistent across restarts | Yes | Yes | Restored on `--resume` if unexpired |
| Local file access | No (fresh clone) | Yes | Yes |
| Min interval | 1 hour | 1 minute | 1 minute |

**`/loop` behavior:**
- `/loop 5m check the deploy` — fixed interval prompt
- `/loop check the deploy` — Claude picks the interval dynamically
- `/loop` — runs built-in maintenance prompt (continue unfinished work, tend to PR, cleanup)
- Custom default: create `.claude/loop.md` or `~/.claude/loop.md`
- Stop: press `Esc`; 7-day automatic expiry on recurring tasks
- Disable entirely: `CLAUDE_CODE_DISABLE_CRON=1`

**Routines (cloud):** managed at [claude.ai/code/routines](https://claude.ai/code/routines) or `/schedule` in CLI. Triggers: schedule, API call (HTTP POST with bearer token), or GitHub events. Run autonomously with no permission prompts.

### Remote Control

Connect [claude.ai/code](https://claude.ai/code) or the Claude mobile app to a local session. Requires claude.ai account (not API key), Pro/Max/Team/Enterprise plan.

| Mode | Command | Notes |
|:-----|:--------|:------|
| Server mode | `claude remote-control` | Stays running, accepts multiple connections |
| Interactive session | `claude --remote-control` | Normal session + remote access |
| From existing session | `/remote-control` | Carries over current conversation |

**Server mode flags:**

| Flag | Description |
|:-----|:------------|
| `--name "My Project"` | Custom session title |
| `--spawn same-dir\|worktree\|session` | How server creates sessions |
| `--capacity <N>` | Max concurrent sessions (default 32) |
| `--sandbox / --no-sandbox` | Filesystem/network isolation |

Enable for all sessions via `/config` → Enable Remote Control for all sessions.

### Voice Dictation

Enable with `/voice`. Requires claude.ai account, local microphone. Not available on API key, Bedrock, Vertex, Foundry, or in remote/SSH sessions.

| Command | Effect |
|:--------|:-------|
| `/voice` | Toggle on/off |
| `/voice hold` | Enable hold-to-record mode (default) |
| `/voice tap` | Enable tap-to-start, tap-to-send mode |
| `/voice off` | Disable |

Settings:
```json
{
  "voice": {
    "enabled": true,
    "mode": "tap",
    "autoSubmit": true
  }
}
```

Rebind the push-to-talk key in `~/.claude/keybindings.json` via the `voice:pushToTalk` action (default: `Space`). Set `"language"` in settings to change dictation language (defaults to English).

### Channels

Push events from Telegram, Discord, or iMessage into a running Claude Code session. Requires claude.ai account or Console API key; not available on Bedrock, Vertex, Foundry.

Start with `--channels` flag:
```bash
claude --channels plugin:telegram@claude-plugins-official
```

Official plugins (all require Bun): `telegram`, `discord`, `imessage`, `fakechat` (localhost demo).

**Security:** each plugin maintains a sender allowlist. Telegram/Discord use a pairing code flow; iMessage gates via self-chat and `/imessage:access allow <handle>`.

**Enterprise controls:**
- `channelsEnabled: true` — master switch (Team/Enterprise off by default)
- `allowedChannelPlugins` — allowlist of permitted plugins

### Deep Links

`claude-cli://` URLs that open Claude Code with a pre-filled prompt.

```
claude-cli://open?q=<url-encoded-prompt>&cwd=<absolute-path>
```

Parameters: `q` (prompt text, max 5000 chars), `cwd` (absolute working directory path). Requires Claude Code v2.1.91+. The prompt is populated but not sent until you press Enter.

### Agent View

`claude agents` opens a single screen for all background sessions.

| Key | Action |
|:----|:-------|
| Arrow keys | Navigate sessions |
| `Space` | Open peek panel (see recent output, type reply) |
| `Enter` in peek | Send reply without leaving agent view |
| `a` | Attach to full conversation |
| `Esc` | Return to shell (sessions keep running) |

Dispatch a new session by typing a prompt in the agent view input. Each dispatched session gets its own isolated worktree automatically.

### Parallel Agents Comparison

| Approach | Use when |
|:---------|:---------|
| **Subagents** | A side task would flood your context with results you won't reference again |
| **Agent view** (`claude agents`) | You have independent tasks and want to hand off and check status |
| **Agent teams** (experimental) | You want Claude to coordinate a group of workers |
| **Dynamic workflows** | Work too big for a few subagents, or needs results cross-checked |

### Worktrees

Start a session in an isolated git worktree:

```bash
claude --worktree feature-auth      # creates .claude/worktrees/feature-auth/
claude --worktree "#1234"           # branches from PR #1234
claude --worktree                   # auto-generates a name
```

Branches from `origin/HEAD` by default. Set `"worktree": { "baseRef": "head" }` in settings to branch from local `HEAD` instead. Add `.claude/worktrees/` to `.gitignore`.

### Prompt Caching

Cache is organized in layers; a change to an earlier layer invalidates everything after it:

| Layer | Content | Changes when |
|:------|:--------|:-------------|
| System prompt | Core instructions, tool definitions, output style | Tool set changes or Claude Code upgrades |
| Project context | CLAUDE.md, auto memory, unscoped rules | Session start, `/clear`, or `/compact` |
| Conversation | Messages, responses, tool results | Every turn |

**Actions that invalidate the cache:** switching models, changing effort level, adding/removing MCP servers, editing CLAUDE.md mid-session, running `/compact`, changing output style, changing the `--append-system-prompt` flag.

Pick your model and effort level at the top of a session. Disable caching: `DISABLE_PROMPT_CACHING=1`, or per-tier `DISABLE_PROMPT_CACHING_OPUS/SONNET/HAIKU`.

### Context Window: What Survives Compaction

| Mechanism | After /compact |
|:----------|:--------------|
| System prompt and output style | Unchanged (not in message history) |
| Project-root CLAUDE.md and unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | Lost until matching file is read again |
| Nested CLAUDE.md in subdirectories | Lost until file in subdirectory is read again |
| Invoked skill bodies | Re-injected, capped 5K tokens/skill, 25K total |
| Hooks | Not applicable (run as code, not context) |

Run `/context` for live context breakdown. Run `/memory` to check which CLAUDE.md files loaded.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code (Features Overview)](references/claude-code-features-overview.md) — when to use CLAUDE.md, skills, subagents, MCP, hooks, and plugins; feature layering and context cost comparison
- [Fast Mode](references/claude-code-fast-mode.md) — speed up Opus responses with `/fast`, pricing, requirements, per-session opt-in, rate limit behavior
- [Model Configuration](references/claude-code-model-config.md) — model aliases, effort levels, extended context, third-party provider pinning, model overrides, prompt caching config
- [Output Styles](references/claude-code-output-styles.md) — built-in styles, creating custom styles, frontmatter schema, how styles modify the system prompt
- [Customize Your Status Line](references/claude-code-statusline.md) — script setup, available JSON fields, full schema, examples in Bash/Python/Node.js, subagent status lines, troubleshooting
- [Checkpointing](references/claude-code-checkpointing.md) — automatic tracking, rewind menu actions, summarize options, limitations
- [Remote Control](references/claude-code-remote-control.md) — server/interactive/VS Code modes, connection security, mobile push notifications, limitations, troubleshooting
- [Scheduled Tasks (/loop)](references/claude-code-scheduled-tasks.md) — fixed-interval and dynamic `/loop`, one-time reminders, `CronCreate/List/Delete` tools, cron expression reference
- [Desktop Scheduled Tasks](references/claude-code-desktop-scheduled-tasks.md) — creating local tasks in the Desktop app, schedule options, permission mode, worktree toggle
- [Routines (Cloud)](references/claude-code-routines.md) — schedule/API/GitHub triggers, creating from web/Desktop/CLI, environment, connectors, usage limits
- [Voice Dictation](references/claude-code-voice-dictation.md) — hold and tap modes, language settings, rebinding the push-to-talk key, troubleshooting
- [Channels](references/claude-code-channels.md) — Telegram/Discord/iMessage setup, fakechat quickstart, security/allowlists, enterprise controls, comparison table
- [Channels Reference](references/claude-code-channels-reference.md) — building custom channel MCP servers, capability declaration, notification format, reply tools, permission relay
- [Context Window Explorer](references/claude-code-context-window.md) — interactive simulation of session loading; what survives compaction, how to check your own session
- [Prompt Caching](references/claude-code-prompt-caching.md) — cache layers, actions that invalidate the cache, cache lifetime, checking hit rate, disabling caching
- [Prompt Library](references/claude-code-prompt-library.md) — copy-paste prompts for common Claude Code tasks organized by SDLC phase and role
- [Deep Links](references/claude-code-deep-links.md) — `claude-cli://open` URL schema, parameters, embedding in runbooks and dashboards, platform registration
- [Agent View](references/claude-code-agent-view.md) — `claude agents` quick start, keyboard shortcuts, dispatching sessions, managing from shell, supervisor process
- [Run Agents in Parallel](references/claude-code-agents.md) — comparison of subagents/agent view/agent teams/dynamic workflows, choosing an approach, checking on running work
- [Worktrees](references/claude-code-worktrees.md) — `--worktree` flag, base branch selection, PR checkout, subagent isolation, `.worktreeinclude`, cleanup

## Sources

- Extend Claude Code (Features Overview): https://code.claude.com/docs/en/features-overview.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Customize Your Status Line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled Tasks (/loop): https://code.claude.com/docs/en/scheduled-tasks.md
- Desktop Scheduled Tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Routines (Cloud): https://code.claude.com/docs/en/routines.md
- Voice Dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels Reference: https://code.claude.com/docs/en/channels-reference.md
- Context Window Explorer: https://code.claude.com/docs/en/context-window.md
- Prompt Caching: https://code.claude.com/docs/en/prompt-caching.md
- Prompt Library: https://code.claude.com/docs/en/prompt-library.md
- Deep Links: https://code.claude.com/docs/en/deep-links.md
- Agent View: https://code.claude.com/docs/en/agent-view.md
- Run Agents in Parallel: https://code.claude.com/docs/en/agents.md
- Worktrees: https://code.claude.com/docs/en/worktrees.md
