---
name: features-doc
user-invocable: false
---

# Claude Code Features Documentation

This skill provides the complete official documentation for Claude Code features — model configuration, fast mode, output styles, status line, checkpointing, remote control, scheduled tasks, channels, context window, worktrees, agent view, prompt caching, and more.

## Quick Reference

### Model Aliases

| Alias | Resolves to |
| :---- | :---------- |
| `default` | Clears override; reverts to recommended model for account type |
| `best` | Fable 5 (if available), otherwise latest Opus |
| `fable` | Claude Fable 5 — longest, most capable sessions |
| `opus` | Latest Opus — complex reasoning |
| `sonnet` | Latest Sonnet — daily coding tasks |
| `haiku` | Fast/efficient Haiku — simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus for plan mode, Sonnet for execution |

Default model by account type: Max/Team/Enterprise pay-as-you-go/Anthropic API → Opus 4.8; Claude Platform on AWS → Opus 4.7; Pro/Team Standard/Enterprise seats → Sonnet 4.6; Bedrock/Vertex/Foundry → Sonnet 4.5.

Fable 5 is never the default — select it with `/model fable`. Requires v2.1.170+.

### Effort Levels

| Level | When to use |
| :---- | :---------- |
| `low` | Short, scoped, latency-sensitive tasks |
| `medium` | Cost-sensitive work; trades some intelligence |
| `high` | Default on Fable 5, Opus 4.8, Opus 4.6, Sonnet 4.6 |
| `xhigh` | Deeper reasoning; default on Opus 4.7 |
| `max` | Demanding tasks; session-only |
| `ultracode` | Plans dynamic workflow + `xhigh` per-message reasoning; session-only |

Set via `/effort`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL` env var, or `effortLevel` in settings. Use `ultrathink` in any prompt for one-off deeper reasoning without changing the session effort level.

### Model Configuration Priority

1. `/model <alias|name>` during session (saves as default from v2.1.153)
2. `claude --model <alias|name>` at startup
3. `ANTHROPIC_MODEL=<alias|name>` env var
4. `model` field in settings file

### Fallback Model Chains

```json
{ "fallbackModel": ["claude-sonnet-4-6", "claude-haiku-4-5"] }
```

Or `--fallback-model sonnet,haiku` for a single session. Used when primary model is overloaded or unavailable.

### Fast Mode

- Toggle with `/fast` or set `"fastMode": true` in user settings
- Supports Opus 4.8, Opus 4.7, Opus 4.6; not available on Sonnet/Haiku
- Pricing: Opus 4.8 = $10/$50 per MTok input/output; Opus 4.7 and 4.6 = $30/$150
- Uses usage credits (never counts against plan rate limits)
- Indicator: `↯` icon next to prompt; turns gray on cooldown
- Rate limits: shared pool across Opus 4.8, 4.7, and 4.6; auto-fallback to standard speed on limit
- Admin: enable in Console or claude.ai admin settings; `fastModePerSessionOptIn: true` to require opt-in each session
- Disable: `CLAUDE_CODE_DISABLE_FAST_MODE=1`

### Extended Context (1M tokens)

| Plan | Opus 1M | Sonnet 1M |
| :--- | :------ | :-------- |
| Max, Team, Enterprise | Included | Usage credits required |
| Pro | Usage credits required | Usage credits required |
| API / pay-as-you-go | Full access | Full access |

Use `[1m]` suffix: `/model opus[1m]` or `export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-8[1m]'`. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

### Output Styles

| Style | Description |
| :---- | :---------- |
| Default | Standard software engineering system prompt |
| Proactive | Executes immediately, makes assumptions, prefers action |
| Explanatory | Adds educational "Insights" alongside coding help |
| Learning | Collaborative; adds `TODO(human)` markers for you to implement |

Change via `/config` → Output style (saved to `.claude/settings.local.json`). Takes effect after `/clear` or new session. Create custom styles in `~/.claude/output-styles` or `.claude/output-styles` as Markdown files with frontmatter: `name`, `description`, `keep-coding-instructions` (bool), `force-for-plugin` (bool).

### Status Line Setup

Add to `~/.claude/settings.json`:
```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2,
    "refreshInterval": 10
  }
}
```

Or use `/statusline <description>` to auto-generate a script. The script receives JSON via stdin and prints display text to stdout.

### Status Line Key Data Fields

| Field | Description |
| :---- | :---------- |
| `model.display_name` | Current model name |
| `context_window.used_percentage` | % of context window used |
| `context_window.context_window_size` | Max tokens (200000 or 1000000) |
| `cost.total_cost_usd` | Estimated session cost |
| `cost.total_duration_ms` | Session wall-clock time (ms) |
| `workspace.current_dir` | Current working directory |
| `workspace.repo.host/owner/name` | Git remote identity |
| `workspace.git_worktree` | Active worktree name (if in one) |
| `effort.level` | Current effort level |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit usage (Pro/Max) |
| `rate_limits.seven_day.used_percentage` | 7-day rate limit usage (Pro/Max) |
| `pr.number`, `pr.url`, `pr.review_state` | Open PR for current branch |
| `session_id`, `session_name` | Session identifiers |
| `vim.mode` | Vim mode (if enabled) |

`COLUMNS`/`LINES` env vars give terminal dimensions inside the script (v2.1.153+). Updates trigger after each assistant message, `/compact`, permission mode change, or vim mode toggle. Subagent status lines: use `subagentStatusLine` setting (same structure as `statusLine`).

### Checkpointing and Rewind

- Automatic: checkpoint created at every user prompt
- Persist 30 days; survive session resumes
- Open rewind menu: `/rewind` or press `Esc` twice on empty input
- Actions: Restore code+conversation, Restore conversation only, Restore code only, Summarize from here, Summarize up to here
- Limitation: Bash command file changes are **not** tracked — only edits via Claude's file editing tools

### Scheduled Tasks Comparison

|  | Cloud (Routines) | Desktop | `/loop` in session |
| :- | :-------------- | :------ | :----------------- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Minimum interval | 1 hour | 1 minute | 1 minute |
| Local file access | No (cloned repo) | Yes | Yes |

### `/loop` Scheduled Tasks (CLI)

| Input | Behavior |
| :---- | :------- |
| `/loop 5m check the deploy` | Fixed interval + custom prompt |
| `/loop check the deploy` | Claude chooses interval dynamically |
| `/loop` | Built-in maintenance prompt (PR tending, bug hunts) |

Tasks are session-scoped; restored on `--resume`/`--continue` if < 7 days old. Max 50 tasks per session. Disable: `CLAUDE_CODE_DISABLE_CRON=1`. Custom default: `.claude/loop.md` (project) or `~/.claude/loop.md` (user).

### Cron Expression Reference

| Expression | Meaning |
| :--------- | :------ |
| `*/5 * * * *` | Every 5 minutes |
| `0 * * * *` | Every hour |
| `0 9 * * *` | Daily at 9am local |
| `0 9 * * 1-5` | Weekdays at 9am |

### Routines (Cloud)

Create at [claude.ai/code/routines](https://claude.ai/code/routines) or via `/schedule` in CLI.

Trigger types:
- **Schedule**: hourly/daily/weekdays/weekly; custom cron via `/schedule update`; one-off timestamps
- **API**: POST to per-routine endpoint with bearer token; optional `text` body field
- **GitHub**: PR events (opened/closed/labeled/synchronized), release events; filters available

API trigger example:
```bash
curl -X POST https://api.anthropic.com/v1/claude_code/routines/<id>/fire \
  -H "Authorization: Bearer <token>" \
  -H "anthropic-beta: experimental-cc-routine-2026-04-01" \
  -d '{"text": "alert context"}'
```

### Remote Control

Start methods:
- `claude remote-control` — server mode (multiple concurrent sessions)
- `claude --remote-control` — interactive session with remote enabled
- `/remote-control` — enable from inside an existing session

`--spawn` modes: `same-dir` (default), `worktree` (isolated per session), `session` (single session only).

Requirements: Pro/Max/Team/Enterprise subscription; claude.ai OAuth (not API key); workspace trust accepted.

### Channels (Push Events)

```bash
claude --channels plugin:telegram@claude-plugins-official
```

Supported: Telegram, Discord, iMessage. Install via `/plugin install <name>@claude-plugins-official`. Requires Bun and claude.ai auth.

Security: each channel maintains a sender allowlist; pair with `/telegram:access pair <code>` then `/telegram:access policy allowlist`.

Enterprise: `channelsEnabled: true` in managed settings; `allowedChannelPlugins` to restrict which plugins.

### Voice Dictation

Enable: `/voice` (toggle), `/voice hold`, `/voice tap`, `/voice off`.

Modes:
- **Hold mode**: hold Space to record, release to insert transcript
- **Tap mode**: tap once to start, tap again to send (auto-submits if ≥ 3 words)

Requirements: claude.ai account (not API key/Bedrock/Vertex/Foundry); local microphone; not available in remote/SSH environments.

Set in settings: `{"voice": {"enabled": true, "mode": "tap"}}`. Rebind push-to-talk via `voice:pushToTalk` action in `~/.claude/keybindings.json`.

### Worktrees

```bash
claude --worktree feature-auth          # creates .claude/worktrees/feature-auth/ on branch worktree-feature-auth
claude --worktree "#1234"               # branch from PR #1234
claude --worktree                       # auto-generated name
```

- Copy gitignored files via `.worktreeinclude` (`.gitignore` syntax)
- Subagent isolation: `isolation: worktree` in subagent frontmatter
- Base branch: defaults to `origin/HEAD`; set `worktree.baseRef: "head"` to use local HEAD
- Non-git VCS: use `WorktreeCreate`/`WorktreeRemove` hooks

### Agent View

```bash
claude agents              # open agent view
claude agents --cwd ~/project   # scope to one project
claude --bg "task prompt"  # dispatch background session
```

Key shortcuts:

| Shortcut | Action |
| :------- | :----- |
| `Space` | Open/close peek panel |
| `Enter` / `→` | Attach to session |
| `←` (empty prompt) | Background current session, open agent view |
| `Ctrl+T` | Pin session (keeps process alive while idle) |
| `Ctrl+X` twice | Stop then delete session |
| `Ctrl+R` | Rename session |
| `Alt+1`..`Alt+9` | Attach to session 1–9 in focused directory |
| `Ctrl+S` | Toggle grouping: by state vs. by directory |

Session states: Working (animated), Needs input (yellow), Idle (dimmed), Completed (green), Failed (red), Stopped (grey). Shape `✽`/`✻` = process alive; `∙` = process exited but resumes on demand; `✢` = `/loop` sleeping.

File isolation: each background session automatically moves into a git worktree under `.claude/worktrees/` before editing. Disable: `worktree.bgIsolation: "none"` in project settings.

Shell commands: `claude attach <id>`, `claude logs <id>`, `claude stop <id>`, `claude rm <id>`, `claude respawn <id>`, `claude daemon status`.

Run shell commands as background jobs from agent view by prefixing with `!`, or with `claude --bg --exec '<cmd>'`.

### Parallel Agents — Approach Comparison

| Approach | What it gives you | Use it when |
| :------- | :---------------- | :---------- |
| Subagents | Delegated workers inside one session | Side task would flood main conversation |
| Agent view | Dispatch/monitor background sessions | Independent tasks; check back later |
| Agent teams | Multi-session with shared task list + messaging | Claude coordinates a group of workers (experimental) |
| Dynamic workflows | Script-driven multi-subagent with cross-checking | Job too large for ad-hoc subagents; needs verification |

`/batch` skill: splits one large change into 5–30 worktree-isolated subagents each opening a PR.

### Prompt Caching

Cache is keyed by model + effort level + prefix content. Cache TTL: 1 hour on subscription (auto); 5 minutes on API key (set `ENABLE_PROMPT_CACHING_1H=1` to upgrade).

Actions that **invalidate** the cache: switching models, changing effort level, enabling fast mode (first time), connecting/disconnecting MCP servers (with prefix-loaded tools), enabling/disabling plugins with MCP servers, adding bare tool deny rules, running `/compact`, upgrading Claude Code.

Actions that **keep** the cache: editing files, editing CLAUDE.md mid-session, changing output style, changing permission mode, invoking skills/commands, running `/recap`, rewinding.

Cache performance fields in statusline `current_usage`: `cache_creation_input_tokens`, `cache_read_input_tokens`.

### Context Window — What Survives Compaction

| Mechanism | After `/compact` |
| :-------- | :--------------- |
| System prompt / output style | Unchanged |
| Project-root CLAUDE.md + unscoped rules | Re-injected |
| Auto memory | Re-injected |
| Rules with `paths:` frontmatter | Lost until matching file re-read |
| Nested CLAUDE.md in subdirectories | Lost until file in that dir re-read |
| Invoked skill bodies | Re-injected (capped at 5,000 tokens/skill, 25,000 total) |

### Fullscreen Rendering

Enable: `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1`. Draws on alternate screen buffer like `vim`.

Key features: mouse click-to-expand tool results, click-to-select text (auto-copies), URL/file-path clicking, `Ctrl+O` for transcript mode with `/` search. Disable mouse: `CLAUDE_CODE_DISABLE_MOUSE=1`. Background/attached sessions always use fullscreen rendering.

### Deep Links

```
claude-cli://open?repo=owner/name&q=URL-encoded%20prompt
claude-cli://open?cwd=/absolute/path&q=URL-encoded%20prompt
```

Parameters: `q` (prompt, max 5000 chars), `cwd` (absolute path), `repo` (GitHub owner/name slug). Opens a new terminal window with prompt pre-filled but not submitted. Requires v2.1.91+. Note: GitHub-rendered Markdown strips non-http/https schemes — put links in code blocks instead.

VS Code variant: `vscode://anthropic.claude-code/open` opens an editor tab.

### Advisor Tool

```bash
claude --advisor opus          # set for session
/advisor opus                  # set and save as default
```

Accepted pairings (advisor must be ≥ main model capability):

| Main | Accepted advisors |
| :--- | :---------------- |
| Haiku 4.5 | Fable, Opus, Sonnet |
| Sonnet 4.6 | Fable, Opus, Sonnet |
| Opus 4.6+ | Fable, Opus (at or above main version) |
| Fable 5 | Fable only |

Requires Anthropic API only (not Bedrock/Vertex/Foundry). Claude decides when to call it; consultation shown in transcript as "Advising" line expandable with `Ctrl+O`. Toggle does not invalidate prompt cache. Disable: `CLAUDE_CODE_DISABLE_ADVISOR_TOOL=1`.

### Extend Claude Code — Feature Selection Guide

| Goal | Use |
| :--- | :-- |
| Always-on project rules | CLAUDE.md |
| Reusable reference or workflow | Skill |
| Context isolation / parallel work | Subagent |
| Multiple coordinated sessions | Agent teams (experimental) |
| External service access | MCP |
| Automation on every event | Hook |
| Bundle + distribute features | Plugin |

Feature loading costs: CLAUDE.md = every request; skill descriptions = every request (full content on use); MCP tool names = session start; subagents = isolated context; hooks = zero unless they return output.

### Prompt Library Patterns

Key prompting patterns:
- Describe the **outcome**, not the steps
- Give Claude **a way to check its own work** (run, test, compare, verify)
- **Point at a reference** (existing file/pattern to match)
- **State the measurable target** (metric + threshold)
- **Give it the artifact** (paste errors, logs, screenshots; use `@` for files)
- **Say how you want the answer** (format, length, audience)

## Full Documentation

For the complete official documentation, see the reference files:

- [Features Overview](references/claude-code-features-overview.md) — When to use CLAUDE.md vs skills vs subagents vs hooks vs MCP vs plugins; context cost by feature; layering rules
- [Fast Mode](references/claude-code-fast-mode.md) — Toggle `/fast`, cost tradeoff, requirements, per-session opt-in, rate limit fallback
- [Model Configuration](references/claude-code-model-config.md) — Model aliases, Fable 5, effort levels, opusplan, fallback chains, extended context, environment variables, third-party provider pinning
- [Output Styles](references/claude-code-output-styles.md) — Built-in styles (Proactive/Explanatory/Learning), create custom styles, frontmatter fields, comparison with CLAUDE.md and skills
- [Status Line](references/claude-code-statusline.md) — Setup, all available JSON data fields, examples (context bar, git status, cost, multi-line, clickable links, rate limits, caching), subagent status line, troubleshooting
- [Checkpointing](references/claude-code-checkpointing.md) — Automatic tracking, rewind menu, restore vs. summarize, limitations (bash commands not tracked)
- [Remote Control](references/claude-code-remote-control.md) — Server mode, interactive session, VS Code, connect from phone/browser, security, mobile push notifications, troubleshooting
- [Scheduled Tasks (CLI)](references/claude-code-scheduled-tasks.md) — `/loop` variants, cron tools (CronCreate/CronList/CronDelete), jitter, 7-day expiry, loop.md customization
- [Desktop Scheduled Tasks](references/claude-code-desktop-scheduled-tasks.md) — Create via Desktop Routines page, schedule options, missed run catch-up, permission management
- [Routines (Cloud)](references/claude-code-routines.md) — Create from web/CLI, schedule/API/GitHub triggers, environments, network access, connectors, usage limits
- [Voice Dictation](references/claude-code-voice-dictation.md) — Hold/tap modes, supported languages, rebind push-to-talk, troubleshooting
- [Channels](references/claude-code-channels.md) — Telegram/Discord/iMessage setup, fakechat quickstart, security allowlists, enterprise controls
- [Channels Reference](references/claude-code-channels-reference.md) — Build custom channel plugins, capability declarations, notification format, reply tools, permission relay
- [Context Window](references/claude-code-context-window.md) — Interactive timeline, what survives compaction, manage context proactively
- [Fullscreen Rendering](references/claude-code-fullscreen.md) — Enable, mouse support, scrolling, transcript mode search, tmux caveats, native selection bypass
- [Deep Links](references/claude-code-deep-links.md) — `claude-cli://open` URL scheme, `q`/`cwd`/`repo` params, embed in runbooks, shell invocation, registration per platform
- [Agent View](references/claude-code-agent-view.md) — Dispatch/monitor/attach background sessions, peek panel, supervisor process, worktree isolation, shell management commands
- [Agents Overview](references/claude-code-agents.md) — Compare subagents/agent view/agent teams/dynamic workflows; choose an approach; check on running work
- [Worktrees](references/claude-code-worktrees.md) — `--worktree` flag, `.worktreeinclude`, subagent isolation, base branch config, cleanup, non-git VCS
- [Prompt Caching](references/claude-code-prompt-caching.md) — Cache structure/layers, actions that invalidate vs. keep cache, TTL options, cache scope, check performance
- [Prompt Library](references/claude-code-prompt-library.md) — Copy-paste prompts by task, prompting patterns, sources
- [Advisor Tool](references/claude-code-advisor.md) — Enable, model pairings, when Claude calls it, cost, comparison with opusplan/subagents

## Sources

- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled Tasks (CLI): https://code.claude.com/docs/en/scheduled-tasks.md
- Desktop Scheduled Tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Routines (Cloud): https://code.claude.com/docs/en/routines.md
- Voice Dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels Reference: https://code.claude.com/docs/en/channels-reference.md
- Context Window: https://code.claude.com/docs/en/context-window.md
- Fullscreen Rendering: https://code.claude.com/docs/en/fullscreen.md
- Deep Links: https://code.claude.com/docs/en/deep-links.md
- Agent View: https://code.claude.com/docs/en/agent-view.md
- Agents Overview: https://code.claude.com/docs/en/agents.md
- Worktrees: https://code.claude.com/docs/en/worktrees.md
- Prompt Caching: https://code.claude.com/docs/en/prompt-caching.md
- Prompt Library: https://code.claude.com/docs/en/prompt-library.md
- Advisor Tool: https://code.claude.com/docs/en/advisor.md
