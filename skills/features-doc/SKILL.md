---
name: features-doc
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features — model configuration, fast mode, output styles, status line, checkpointing, remote control, scheduled tasks, voice dictation, channels, worktrees, artifacts, the advisor tool, and more.

## Quick Reference

### Extension Feature Overview

| Feature | What it does | When to use it |
| :--- | :--- | :--- |
| **CLAUDE.md** | Persistent context loaded every conversation | Project conventions, "always do X" rules |
| **Skill** | Instructions, knowledge, and workflows Claude can use | Reusable content, reference docs, repeatable tasks |
| **Subagent** | Isolated execution context that returns summarized results | Context isolation, parallel tasks, specialized workers |
| **Agent teams** | Coordinate multiple independent Claude Code sessions | Parallel research, new feature development |
| **MCP** | Connect to external services | External data or actions |
| **Hook** | Script, HTTP request, prompt, or subagent triggered by events | Automation that must run on every matching event |
| **Artifact** | Publish session output as a private interactive web page | Output easier to see than to read as text |

### Model Configuration

#### Model Aliases

| Alias | Behavior |
| :--- | :--- |
| `default` | Clears any override, reverts to recommended model for your account type |
| `best` | Uses Fable 5 where available, otherwise latest Opus |
| `fable` | Claude Fable 5 for hardest and longest-running tasks |
| `sonnet` | Latest Sonnet for daily coding tasks |
| `opus` | Latest Opus for complex reasoning tasks |
| `haiku` | Fast and efficient Haiku for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus in plan mode, then switches to Sonnet for execution |

**Setting model** (priority order): `/model <alias>` during session → `claude --model <alias>` at startup → `ANTHROPIC_MODEL` env var → `model` field in settings.

**Default model by account type:**
- Max, Team Premium, Enterprise pay-as-you-go, API → Opus 4.8
- Claude Platform on AWS → Opus 4.7
- Pro, Team Standard, Enterprise subscription seats → Sonnet 4.6
- Bedrock, Vertex, Foundry → Sonnet 4.5

#### Effort Levels

| Level | When to use |
| :--- | :--- |
| `low` | Short, scoped, latency-sensitive tasks |
| `medium` | Cost-sensitive work that can trade off intelligence |
| `high` | Balances token usage and intelligence (default on most models) |
| `xhigh` | Deeper reasoning at higher token spend (default on Opus 4.7) |
| `max` | Demanding tasks; session-only, test before adopting broadly |
| `ultracode` | Plans a dynamic workflow for each substantive task; session-only |

Set via `/effort <level>`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL` env var, or `effortLevel` setting. Include `ultrathink` in a prompt for one-off deeper reasoning without changing session effort.

#### Fallback Model Chains

Configure with `--fallback-model sonnet,haiku` (session) or `"fallbackModel": ["claude-sonnet-4-6"]` in settings. Activated by overload/unavailability only — not by auth, billing, or rate-limit errors.

#### Extended Context (1M tokens)

- Max, Team, Enterprise: Opus auto-upgraded to 1M (included in subscription)
- Pro/API: available with usage credits; requires `opus[1m]` or `sonnet[1m]` alias
- Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`

#### Model Environment Variables

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_FABLE_MODEL` | Override for `fable` alias |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Override for `opus` alias |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Override for `sonnet` alias |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Override for `haiku` alias |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for all subagents and agent teams |

### Fast Mode

Fast mode is a high-speed configuration for Claude Opus — up to 2.5x faster at a higher cost per token.

| Model | Fast mode input (MTok) | Fast mode output (MTok) |
| :--- | :--- | :--- |
| Opus 4.8 | $10 | $50 |
| Opus 4.7 / Opus 4.6 | $30 | $150 |

- Toggle with `/fast` or set `"fastMode": true` in user settings
- Requires Claude Code v2.1.36+; Anthropic API or subscription only (not Bedrock/Vertex/Foundry)
- Requires usage credits; draws from usage credits even if plan allowance remains
- Team/Enterprise: admin must enable at claude.ai/admin-settings/claude-code
- Per-session opt-in: admins can set `"fastModePerSessionOptIn": true` in managed settings
- Rate limit shared across Opus 4.8, 4.7, 4.6; auto falls back to standard speed on cooldown
- Enable at session start for best cost efficiency (switching mid-conversation reprices the full context)

### Output Styles

Output styles modify Claude's system prompt to change role, tone, and response format.

**Built-in styles:**
- **Default**: standard software engineering instructions
- **Proactive**: executes immediately, makes assumptions, prefers action over planning
- **Explanatory**: provides educational "Insights" while coding
- **Learning**: collaborative mode with `TODO(human)` markers for you to implement

**Custom output styles** — stored in `.claude/output-styles/` (project) or `~/.claude/output-styles/` (user):

| Frontmatter | Purpose | Default |
| :--- | :--- | :--- |
| `name` | Style name | Inherits from filename |
| `description` | Shown in `/config` picker | None |
| `keep-coding-instructions` | Keep built-in software engineering instructions | `false` |
| `force-for-plugin` | Auto-apply style when plugin is enabled | `false` |

Set via `/config` → Output style. Saved as `outputStyle` in settings. Takes effect after `/clear` or a new session.

### Status Line

A customizable bar at the bottom of Claude Code that runs any shell script you configure.

**Setup:**
1. Use `/statusline <description>` to have Claude generate and configure a script automatically
2. Or set manually in `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2,
    "refreshInterval": 30
  }
}
```

**Key available data fields (JSON via stdin):**

| Field | Description |
| :--- | :--- |
| `model.id`, `model.display_name` | Current model |
| `workspace.current_dir`, `workspace.project_dir` | Working directories |
| `workspace.repo.host/owner/name` | Git remote identity |
| `cost.total_cost_usd` | Estimated session cost |
| `cost.total_duration_ms` | Total elapsed time |
| `context_window.used_percentage` | Context usage (input only) |
| `context_window.context_window_size` | 200000 or 1000000 |
| `effort.level` | Current effort level |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit usage (Claude.ai subscribers) |
| `rate_limits.seven_day.used_percentage` | 7-day rate limit usage (Claude.ai subscribers) |
| `session_id`, `session_name` | Session identifiers |
| `vim.mode` | Vim mode (when enabled) |
| `pr.number`, `pr.url`, `pr.review_state` | Open PR for current branch |
| `worktree.name`, `worktree.branch` | Worktree info (during `--worktree` sessions) |
| `output_style.name` | Current output style |

Read `COLUMNS` and `LINES` env vars for terminal dimensions (v2.1.153+). Updates fire after each assistant message, `/compact`, permission mode change, or vim mode toggle. Use `session_id` (not `$$`) as cache key for stable per-session caching.

**Subagent status line:** configure `subagentStatusLine` with same structure; receives `tasks` array and writes one JSON line per row: `{"id": "<task id>", "content": "<row body>"}`.

### Checkpointing

Automatically tracks file edits before each edit so you can undo and rewind.

**Rewind menu** — press `Esc` twice (when prompt is empty) or run `/rewind`:

| Action | Effect |
| :--- | :--- |
| Restore code and conversation | Reverts both to selected point |
| Restore conversation | Rewinds messages, keeps current code |
| Restore code | Reverts file changes, keeps conversation |
| Summarize from here | Compresses messages from selected point forward |
| Summarize up to here | Compresses messages before selected point |

**Limitations:** bash-command file modifications not tracked; external changes not tracked; not a replacement for git.

### Remote Control

Connect claude.ai/code or the Claude mobile app to a Claude Code session running on your machine.

**Start modes:**
- `claude remote-control` — server mode; stays running and waits for connections
- `claude --remote-control` or `claude --rc` — interactive session with Remote Control enabled
- `/remote-control` or `/rc` in an existing session — carries over conversation history

**Server mode flags:**

| Flag | Description |
| :--- | :--- |
| `--name "My Project"` | Custom session title |
| `--spawn same-dir\|worktree\|session` | How each on-demand session is created |
| `--capacity <N>` | Max concurrent sessions (default 32) |
| `--sandbox` / `--no-sandbox` | Enable/disable filesystem sandboxing |

**Requirements:** Pro/Max/Team/Enterprise subscription (not API keys); claude.ai OAuth login; v2.1.51+. Team/Enterprise: admin must enable the Remote Control toggle.

**Mobile push notifications:** configure via `/config`; requires Claude mobile app signed in with the same account.

**Security:** outbound HTTPS only, no inbound ports; traffic routes through Anthropic API over TLS.

### Scheduled Tasks

#### In-session scheduling with /loop

| Command | Effect |
| :--- | :--- |
| `/loop 5m check the deploy` | Fixed-interval prompt |
| `/loop check the deploy` | Dynamically chosen interval (Claude adapts) |
| `/loop` | Built-in maintenance prompt (continue work, tend PR, cleanup) |
| `/loop 15m` | Built-in maintenance on fixed schedule |

**Customizing the default prompt:** create `.claude/loop.md` (project) or `~/.claude/loop.md` (user). Edits take effect on the next iteration.

**Cron tools (used by Claude internally):** `CronCreate`, `CronList`, `CronDelete`. Max 50 tasks per session.

**Jitter:** recurring tasks fire up to 30 min late; one-shot tasks at :00/:30 fire up to 90s early.

**Seven-day expiry:** recurring tasks auto-expire 7 days after creation.

Disable entirely: `CLAUDE_CODE_DISABLE_CRON=1`.

#### Desktop scheduled tasks

Local tasks in the Desktop app: click **Routines** → **New routine** → **Local**.

Schedule options: Manual, Hourly, Daily, Weekdays, Weekly. Enable worktree toggle for isolated git checkout per run. Tasks only run while the Desktop app is open. Missed runs: one catch-up run on wake for the most recently missed time.

#### Cloud routines

Remote routines at claude.ai/code/routines run on Anthropic-managed infrastructure; persist when machine is off.

Trigger types: **Scheduled** (cron-like), **API** (HTTP POST to per-routine endpoint with bearer token), **GitHub** (PR, release, etc.).

### Voice Dictation

Speak prompts in the Claude Code CLI. Requires claude.ai account (not API key); not available on Bedrock/Vertex/Foundry or in remote/SSH environments.

**Enable:** `/voice` to toggle; `/voice hold` or `/voice tap` for specific mode; `/voice off` to disable.

**Hold mode** (default): hold Space to record, release to insert transcript. Brief warmup during key-repeat detection. Set `"autoSubmit": true` to send automatically on release.

**Tap mode** (v2.1.116+): tap once to start, tap again to stop and auto-send (if transcript is ≥3 words).

**Language:** uses the `language` setting; supported languages include en, es, fr, de, ja, ko, zh, and many others.

**Rebind:** `voice:pushToTalk` action in `Chat` context via `~/.claude/keybindings.json`. Default: Space.

### Channels

Push events from external systems (Telegram, Discord, iMessage, webhooks) into a running Claude Code session. Requires v2.1.80+, claude.ai or Console API auth.

**Start with channels:** `claude --channels plugin:telegram@claude-plugins-official`

**Supported plugins (via claude-plugins-official):** `telegram`, `discord`, `imessage`, `fakechat` (localhost demo).

**Install:** `/plugin install telegram@claude-plugins-official` → configure → restart with `--channels`.

**Security:** sender allowlist per channel; pair via code exchange for Telegram/Discord; iMessage self-chat bypasses gate.

**Enterprise:** `channelsEnabled` (master switch) and `allowedChannelPlugins` in managed settings.

**Build your own:** MCP server over stdio; declare `claude/channel` capability; emit `notifications/claude/channel` events; optionally expose a reply tool.

### Worktrees

Each session gets its own git working directory so parallel sessions never conflict.

```bash
claude --worktree feature-auth   # creates .claude/worktrees/feature-auth/ on branch worktree-feature-auth
claude --worktree                # auto-generates name
claude --worktree "#1234"        # branches from PR #1234
```

**Base branch:** defaults to `origin/HEAD` (remote default branch). Set `"worktree": {"baseRef": "head"}` in settings to branch from local HEAD.

**Copy gitignored files:** `.worktreeinclude` file in project root (gitignore syntax); only gitignored files matching patterns are copied.

**Subagent isolation:** `context: worktree` in subagent frontmatter spawns the subagent in its own worktree.

**Cleanup:** `/worktrees` lists active worktrees; select one to enter or delete. Add `.claude/worktrees/` to `.gitignore`.

### Agent View

One screen to dispatch and monitor multiple background Claude Code sessions (`claude agents`).

- Dispatch new sessions from the input at the bottom; each prompt starts a new independent session
- Session states: **Needs input**, **Working**, **Completed** — pinned and needs-input rows appear first
- `Space` on a row: open peek panel to see recent output or question; type reply and press Enter
- `Enter` or `→`: attach to full conversation; `←` on empty prompt: detach and return to table
- `/bg` inside any session: move it into agent view as a background session
- Filter by project: `claude agents --cwd ~/projects/my-app`
- Each background session uses subscription quota independently

Requires v2.1.139+; research preview.

### Prompt Caching

Claude Code manages prompt caching automatically. Cache is organized in layers:

| Layer | Content | Invalidated when |
| :--- | :--- | :--- |
| System prompt | Core instructions, tool definitions, output style | Tool set changes or Claude Code upgrades |
| Project context | CLAUDE.md, auto memory, unscoped rules | Session starts, `/clear`, `/compact` |
| Conversation | Messages, responses, tool results | Every turn |

**Cache-invalidating actions** (cause one slower/more expensive turn):
- Switching models (`/model`)
- Changing effort level (`/effort`) — shows confirmation dialog
- Turning on fast mode
- Connecting/disconnecting an MCP server
- Enabling/disabling a plugin
- Denying an entire tool
- Running `/compact`
- Upgrading Claude Code

**Cache lifetime:** 5 minutes (standard) extended to 1 hour when usage crosses a threshold. Disable with `DISABLE_PROMPT_CACHING=1` (or per-model variants like `DISABLE_PROMPT_CACHING_OPUS=1`).

### Advisor Tool

Pair a main model with a stronger advisor model Claude consults at key moments.

**Enable:** `/advisor opus` (saves to `advisorModel` setting), `--advisor opus` flag (session-only), or `"advisorModel": "opus"` in settings.

**Accepted pairings:**

| Main model | Accepted advisors |
| :--- | :--- |
| Haiku 4.5 | Fable, Opus, Sonnet |
| Sonnet 4.6 | Fable, Opus, Sonnet |
| Opus 4.6 or later | Fable, Opus at same or higher version |
| Fable 5 | Fable only |

Requires Anthropic API; not available on Bedrock/Vertex/Foundry. Experimental; requires v2.1.98+.

### Artifacts

Live, interactive web pages published from a session to a private URL on claude.ai.

- Team/Enterprise plans only; requires `/login` with claude.ai account
- Create: ask Claude directly ("make an artifact that…") or Claude publishes on its own
- URL is permanent and updates in place as Claude republishes
- Press `Ctrl+]` to reopen the most recent artifact from the terminal
- Set `CLAUDE_CODE_ARTIFACT_AUTO_OPEN=0` to suppress auto-open

**Constraints:** one self-contained HTML/Markdown page; no backend, no API calls at view time, no multi-route apps.

### Deep Links (`claude-cli://`)

Open Claude Code in a new terminal window from any link.

```
claude-cli://open?repo=owner/name&q=URL-encoded+prompt
```

| Parameter | Description |
| :--- | :--- |
| `q` | Prompt text (URL-encoded; max 5,000 characters) |
| `cwd` | Absolute local path for working directory |
| `repo` | GitHub `owner/name` slug (resolves to local clone) |

Prompt is pre-filled but not sent until you press Enter. A warning `Prompt from an external link` stays visible until sent. Requires v2.1.91+. Note: GitHub-rendered Markdown strips `claude-cli://` scheme from links.

### Fullscreen Rendering

Flicker-free rendering on the terminal's alternate screen buffer. Research preview; opt-in.

**Enable:** `/tui fullscreen` (mid-session) or `CLAUDE_CODE_NO_FLICKER=1` env var.

**Key behaviors vs. default:**
- Input box stays fixed at bottom
- Memory stays flat regardless of conversation length
- `Ctrl+o` toggles transcript mode for search and review
- Mouse support: click to expand tool results, drag to select text, scroll with wheel
- `PgUp`/`PgDn`/`Ctrl+Home`/`Ctrl+End` for scrolling
- `[` in transcript mode: write conversation to terminal scrollback for native search

**Disable mouse capture while keeping flicker-free:** `CLAUDE_CODE_DISABLE_MOUSE=1`.

**Scroll speed:** `CLAUDE_CODE_SCROLL_SPEED=3` or `/scroll-speed` command.

**Revert:** `/tui default` or `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1`.

### Context Window Explorer

`features-overview.md` includes an interactive simulation (rendered as a web page) showing what loads at session start and when rules/hooks fire. See the reference file for the full data.

### Prompt Library

`claude-code-prompt-library.md` contains copy-paste prompts tagged by task type and SDLC phase (discover, plan, build, review, operate). Organized categories include: Onboard, Understand, Plan, Build, Review, and more.

## Full Documentation

For the complete official documentation, see the reference files:

- [Features overview](references/claude-code-features-overview.md) — Extension features compared: CLAUDE.md, skills, subagents, agent teams, MCP, hooks, plugins, artifacts; when to use each and how they layer
- [Fast mode](references/claude-code-fast-mode.md) — Toggle, pricing, requirements, per-session opt-in, rate limit fallback behavior
- [Model configuration](references/claude-code-model-config.md) — Aliases, Fable 5, effort levels, fallback chains, extended context, model env vars, `availableModels`, `modelOverrides`, prompt caching config
- [Output styles](references/claude-code-output-styles.md) — Built-in styles, creating custom styles, frontmatter reference
- [Status line](references/claude-code-statusline.md) — Setup, all available JSON fields, multi-language examples, subagent status line, troubleshooting
- [Checkpointing](references/claude-code-checkpointing.md) — Rewind menu, restore vs. summarize, limitations
- [Remote control](references/claude-code-remote-control.md) — Server mode, interactive mode, VS Code, mobile push notifications, security, limitations
- [Scheduled tasks (in-session)](references/claude-code-scheduled-tasks.md) — `/loop`, cron tools, jitter, expiry, `loop.md` customization
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) — Local tasks in Desktop app, schedule options, missed runs, permissions
- [Routines (cloud)](references/claude-code-routines.md) — Scheduled, API-triggered, and GitHub-triggered cloud routines; connectors; usage limits
- [Voice dictation](references/claude-code-voice-dictation.md) — Hold and tap modes, language settings, rebinding, troubleshooting
- [Channels](references/claude-code-channels.md) — Telegram, Discord, iMessage setup; quickstart with fakechat; security; enterprise controls
- [Channels reference](references/claude-code-channels-reference.md) — Building your own channel: capability declaration, notification format, reply tool, sender gating, permission relay
- [Context window explorer](references/claude-code-context-window.md) — Interactive simulation of what loads at startup and when
- [Fullscreen rendering](references/claude-code-fullscreen.md) — Enable, mouse support, scroll shortcuts, transcript mode, tmux notes, troubleshooting
- [Worktrees](references/claude-code-worktrees.md) — `--worktree` flag, base branch, `.worktreeinclude`, subagent isolation, non-git VCS hooks
- [Agent view](references/claude-code-agent-view.md) — Dispatch, peek, attach, keyboard shortcuts, background session hosting
- [Run agents in parallel](references/claude-code-agents.md) — Comparison of subagents, agent view, agent teams, dynamic workflows, worktrees
- [Prompt caching](references/claude-code-prompt-caching.md) — Cache layers, invalidating actions, lifetime, checking cache performance
- [Prompt library](references/claude-code-prompt-library.md) — Copy-paste prompts by task type and SDLC phase
- [Advisor tool](references/claude-code-advisor.md) — Supported pairings, enable/disable, billing
- [Artifacts](references/claude-code-artifacts.md) — Create, update, share, page constraints, availability, organization management

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
- Context window: https://code.claude.com/docs/en/context-window.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
- Routines: https://code.claude.com/docs/en/routines.md
- Deep links: https://code.claude.com/docs/en/deep-links.md
- Agent view: https://code.claude.com/docs/en/agent-view.md
- Run agents in parallel: https://code.claude.com/docs/en/agents.md
- Worktrees: https://code.claude.com/docs/en/worktrees.md
- Prompt caching: https://code.claude.com/docs/en/prompt-caching.md
- Prompt library: https://code.claude.com/docs/en/prompt-library.md
- Advisor tool: https://code.claude.com/docs/en/advisor.md
- Artifacts: https://code.claude.com/docs/en/artifacts.md
