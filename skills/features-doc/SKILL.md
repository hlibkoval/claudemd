---
name: features-doc
description: Complete official documentation for Claude Code features — extension overview (CLAUDE.md vs skills vs hooks vs MCP), model config, output styles, status line, checkpointing/rewind, remote control, scheduled tasks (/loop, desktop, cloud routines), voice dictation, channels (Telegram/Discord/iMessage), channels reference (building MCP channel servers), context window explorer, fullscreen rendering, deep links, and fast mode.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code's features, extension model, and configuration options.

## Quick Reference

### Extension Model Overview

| Feature | What it does | When to use it |
| :--- | :--- | :--- |
| **CLAUDE.md** | Persistent context loaded every conversation | Project conventions, "always do X" rules |
| **Skill** | Instructions, knowledge, and workflows Claude can use | Reusable content, reference docs, repeatable tasks |
| **Subagent** | Isolated execution context that returns summarized results | Context isolation, parallel tasks, specialized workers |
| **MCP** | Connect to external services | External data or actions |
| **Hook** | Script, HTTP request, prompt, or subagent triggered by events | Automation that must run on every matching event |
| **Plugin** | Bundle and distribute skills, hooks, subagents, MCP servers | Reuse across repos or share with others |

**CLAUDE.md vs Skill**: CLAUDE.md loads every session automatically; skills load on demand. Keep CLAUDE.md under 200 lines.

**Hook vs Skill**: Hooks always fire on their event — guaranteed enforcement. Skills are Claude-interpreted — use for workflows needing reasoning.

**Feature layering**: CLAUDE.md is additive (all levels merge); skills and subagents override by name (managed > user > project); hooks merge (all registered hooks fire).

### Context Cost by Feature

| Feature | When it loads | Context cost |
| :--- | :--- | :--- |
| CLAUDE.md | Session start | Every request |
| Skills | Session start (descriptions) + when used (full content) | Low until invoked |
| MCP servers | Session start (names) + on demand (schemas) | Low until used |
| Subagents | When spawned | Isolated (separate context window) |
| Hooks | On trigger | Zero unless hook returns output |

Set `disable-model-invocation: true` on a skill to hide it from Claude's auto-loading — zero cost until you invoke it manually.

### Model Configuration

| Alias | Behavior |
| :--- | :--- |
| `default` | Clears override; reverts to recommended model for your account |
| `best` | Most capable available (currently Opus) |
| `opus` | Latest Opus (Opus 4.7 on Anthropic API; Opus 4.6 on Bedrock/Vertex/Foundry) |
| `sonnet` | Latest Sonnet (Sonnet 4.6 on Anthropic API; Sonnet 4.5 on Bedrock/Vertex/Foundry) |
| `haiku` | Fast and efficient model |
| `opus[1m]` / `sonnet[1m]` | 1 million token context window variants |
| `opusplan` | Opus during plan mode, then Sonnet for execution |

**Set model**: `/model <alias>` (in session), `--model <alias>` (at startup), `ANTHROPIC_MODEL=<alias>`, or `model` field in settings.

**Effort levels** (Opus 4.7: `low/medium/high/xhigh/max`; Opus 4.6 / Sonnet 4.6: `low/medium/high/max`):
- `/effort <level>` or `--effort <level>` at startup
- Default: `xhigh` on Opus 4.7, `high` on Opus 4.6/Sonnet 4.6
- Use `ultrathink` in prompt for one-off deep reasoning without changing effort level

**Extended context** (1M tokens):
- Max, Team, Enterprise: Opus automatically upgraded, Sonnet requires extra usage
- Pro: requires extra usage for both
- Disable: `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`

**Extended thinking** (reasoning tokens):
- Toggle: `Option+T` (macOS) / `Alt+T` (Windows/Linux)
- Set default: `/config` → thinking mode, saved as `alwaysThinkingEnabled`
- Disable: `MAX_THINKING_TOKENS=0`

### Fast Mode

Fast mode makes Opus 4.6 run 2.5x faster at higher cost ($30/$150 per MTok input/output).

| Toggle | Method |
| :--- | :--- |
| Enable/disable | `/fast` |
| Persist across sessions | Default — stays on until toggled off |
| Per-session only (admin) | Set `fastModePerSessionOptIn: true` in managed settings |

- Not available on Bedrock, Vertex, or Azure Foundry
- Requires extra usage enabled; billed directly to extra usage from first token
- Rate limit exceeded: auto-falls back to standard Opus 4.6; gray `↯` icon = cooldown
- Team/Enterprise: admin must enable at claude.ai/admin-settings/claude-code

### Output Styles

Output styles modify Claude's system prompt (role, tone, format) without changing capabilities.

| Built-in style | Description |
| :--- | :--- |
| `Default` | Standard software engineering assistant |
| `Explanatory` | Adds "Insights" sections explaining implementation choices |
| `Learning` | Collaborative mode; adds `TODO(human)` markers for you to implement |

**Change**: `/config` → Output style, or set `outputStyle` field in settings.

**Custom styles**: Markdown files with frontmatter (`name`, `description`, `keep-coding-instructions`, `force-for-plugin`) saved to `~/.claude/output-styles`, `.claude/output-styles`, or plugin `output-styles/` directory.

Output styles take effect at the next session start (set in system prompt).

### Status Line

A customizable shell-script-powered bar at the bottom of Claude Code.

**Setup**: `/statusline show model and context percentage` (auto-generates script + settings), or manually:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2,
    "refreshInterval": 5
  }
}
```

**Key available data fields** (piped as JSON to script stdin):

| Field | Description |
| :--- | :--- |
| `model.display_name` | Current model name |
| `context_window.used_percentage` | % of context window used |
| `context_window.context_window_size` | Max tokens (200000 or 1000000) |
| `cost.total_cost_usd` | Estimated session cost |
| `cost.total_duration_ms` | Session elapsed time (ms) |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit usage % |
| `rate_limits.seven_day.used_percentage` | 7-day rate limit usage % |
| `workspace.current_dir` | Current working directory |
| `effort.level` | Current effort level |
| `vim.mode` | Vim mode (when enabled) |
| `worktree.name` / `worktree.branch` | Worktree info (when in `--worktree` session) |

Script output can include multiple lines, ANSI colors, and OSC 8 hyperlinks (clickable URLs).

### Checkpointing / Rewind

Claude Code automatically creates a checkpoint before each file edit. To rewind:

- Press `Esc` + `Esc` or run `/rewind`
- Select a prior prompt from the scrollable list
- Choose action:
  - **Restore code and conversation** — reverts both
  - **Restore conversation** — rewinds messages, keeps current code
  - **Restore code** — reverts files, keeps conversation
  - **Summarize from here** — compresses conversation from this point, like `/compact` but targeted

Checkpoints persist across sessions (cleaned up after 30 days). Bash command file changes are NOT tracked — only direct file edits via Claude's tools.

### Remote Control

Control a local Claude Code session from claude.ai/code or the Claude mobile app.

**Start methods**:

| Method | Command |
| :--- | :--- |
| Server mode (dedicated) | `claude remote-control` |
| Interactive + remote | `claude --remote-control` or `claude --rc` |
| From existing session | `/remote-control` or `/rc` |
| VS Code | `/remote-control` in prompt box |

**Server mode flags**: `--name`, `--spawn same-dir|worktree|session`, `--capacity <N>`, `--sandbox`

**Connect**: open session URL in browser, scan QR code, or find session in claude.ai/code session list.

**Push notifications**: install Claude mobile app, sign in, allow notifications, enable in `/config`.

Requirements: Pro/Max/Team/Enterprise plan, claude.ai OAuth (not API key). Team/Enterprise: admin must enable at claude.ai/admin-settings/claude-code.

### Scheduling Options Comparison

| | Cloud (Routines) | Desktop | `/loop` (CLI) |
| :--- | :--- | :--- | :--- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Persistent across restarts | Yes | Yes | Restored on `--resume` if unexpired |
| Access to local files | No (fresh clone) | Yes | Yes |
| Minimum interval | 1 hour | 1 minute | 1 minute |

### Scheduled Tasks (`/loop`)

`/loop` runs prompts on repeat within the current session.

| Usage | Behavior |
| :--- | :--- |
| `/loop 5m check the deploy` | Fixed interval, your prompt |
| `/loop check the deploy` | Claude chooses interval dynamically |
| `/loop` | Built-in maintenance prompt at dynamic interval |
| `/loop 15m` | Built-in maintenance at fixed interval |

- Stop a loop: press `Esc`
- Customize default loop prompt: create `.claude/loop.md` (project) or `~/.claude/loop.md` (user)
- One-time reminders: describe in natural language ("remind me at 3pm to push the release branch")
- Session cap: 50 tasks; 7-day expiry for recurring tasks
- Disable scheduler: `CLAUDE_CODE_DISABLE_CRON=1`

Cron expression format: `minute hour day-of-month month day-of-week` (5-field standard).

### Desktop Scheduled Tasks

Create in Desktop app: Routines → New routine → Local.

| Field | Description |
| :--- | :--- |
| Name | Unique identifier (converted to kebab-case folder name) |
| Instructions | Prompt + permission mode + model selection |
| Schedule | Manual / Hourly / Daily / Weekdays / Weekly (or describe custom interval to Claude) |
| Folder | Working directory (must be trusted) |

Tasks only run while Desktop app is open and computer is awake. Missed runs: one catch-up run for the most recent missed time on wake.

Edit task prompt on disk: `~/.claude/scheduled-tasks/<task-name>/SKILL.md`.

### Cloud Routines

Routines run on Anthropic-managed infrastructure regardless of machine state.

**Triggers**:
- **Schedule**: hourly/daily/weekdays/weekly or custom cron (`/schedule update` for cron expressions); minimum 1 hour
- **API**: POST to per-routine endpoint with bearer token: `curl -X POST https://api.anthropic.com/v1/claude_code/routines/<id>/fire -H "Authorization: Bearer <token>" -d '{"text": "context"}'`
- **GitHub events**: pull_request (opened/closed/labeled/etc.) or release (created/published/etc.) with optional filters

Create from web at claude.ai/code/routines, from Desktop app (Routines → New routine → Remote), or CLI with `/schedule`.

Routines run autonomously (no permission prompts). Push access restricted to `claude/` prefixed branches by default; enable "Allow unrestricted branch pushes" per repo.

### Voice Dictation

Speak prompts in the CLI; audio transcribed live into the prompt input.

| Command | Effect |
| :--- | :--- |
| `/voice` | Toggle on/off, keep current mode |
| `/voice hold` | Hold Space to record (push-to-talk) |
| `/voice tap` | Tap Space to start, tap again to send |
| `/voice off` | Disable |

Requirements: claude.ai account (not API key, Bedrock, Vertex, or Foundry); local microphone access; v2.1.69+.

**Hold mode**: hold Space → warmup → live waveform → release to finalize. Set `"autoSubmit": true` to send on release.

**Tap mode** (v2.1.116+): tap Space with empty input to start recording; tap again to stop and auto-submit (if transcript ≥ 3 words).

**Language**: set `language` in settings (uses same setting as Claude's response language). Supported: cs, da, nl, en, fr, de, el, hi, id, it, ja, ko, no, pl, pt, ru, es, sv, tr, uk.

**Rebind key**: edit `~/.claude/keybindings.json`, bind `voice:pushToTalk` in `Chat` context.

### Channels (Telegram / Discord / iMessage)

Channels push external events into a running Claude Code session via MCP servers.

**Install a channel**:
```
/plugin install telegram@claude-plugins-official
/plugin install discord@claude-plugins-official
/plugin install imessage@claude-plugins-official
/plugin install fakechat@claude-plugins-official  # demo, localhost
```

**Run with channel**:
```bash
claude --channels plugin:telegram@claude-plugins-official
```

**Security**: sender allowlist gates all inbound messages. Pair Telegram/Discord by DMing your bot and running `/telegram:access pair <code>` then `/telegram:access policy allowlist`. iMessage auto-allows your own Apple ID; add others with `/imessage:access allow +15551234567`.

Enterprise settings:

| Setting | Purpose |
| :--- | :--- |
| `channelsEnabled` | Master on/off switch |
| `allowedChannelPlugins` | Restrict which plugins can register as channels |

Channels require Claude Code v2.1.80+, claude.ai or Console API key authentication (not Bedrock/Vertex/Foundry). Team/Enterprise: admin must enable.

### Channels Reference (Building Custom Channels)

A channel is an MCP server with the `claude/channel` capability that pushes `notifications/claude/channel` events.

**Minimal server setup**:
```ts
const mcp = new Server(
  { name: 'my-channel', version: '0.0.1' },
  {
    capabilities: { experimental: { 'claude/channel': {} } },
    instructions: 'Events arrive as <channel source="my-channel" ...>.',
  }
)
await mcp.connect(new StdioServerTransport())
```

**Push an event**:
```ts
await mcp.notification({
  method: 'notifications/claude/channel',
  params: { content: 'build failed', meta: { severity: 'high' } },
})
```

**Two-way (reply tool)**: add `tools: {}` capability + `ListToolsRequestSchema`/`CallToolRequestSchema` handlers + instructions telling Claude to use the reply tool.

**Permission relay**: declare `'claude/channel/permission': {}` capability; handle `notifications/claude/channel/permission_request`; respond with `notifications/claude/channel/permission` (`{ request_id, behavior: 'allow'|'deny' }`).

Test with: `claude --dangerously-load-development-channels server:yourserver`

### Fullscreen Rendering

Flicker-free, memory-stable rendering using the terminal alternate screen buffer (like `vim`).

**Enable**: `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1`

**Disable**: `/tui default` or `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1`

Key differences from classic rendering:

| Classic | Fullscreen |
| :--- | :--- |
| `Cmd+f` / tmux search | `Ctrl+o` → `/` to search |
| Native click-drag selection | In-app click-drag, auto-copies on release |
| `Cmd`-click URLs | Click URLs directly |

Scroll shortcuts: `PgUp`/`PgDn`, `Ctrl+Home`/`Ctrl+End`, mouse wheel.

`Ctrl+o`: toggle transcript mode (less-style navigation + search).

Mouse capture: disable with `CLAUDE_CODE_DISABLE_MOUSE=1` to keep native text selection while retaining flicker-free rendering.

Scroll speed: `CLAUDE_CODE_SCROLL_SPEED=3` (1–20).

### Deep Links

`claude-cli://` URL scheme opens Claude Code in a new terminal from any link.

**URL format**:
```
claude-cli://open?repo=owner/name&q=URL-encoded+prompt
```

| Parameter | Description |
| :--- | :--- |
| `q` | Prompt text (URL-encoded, max 5000 chars, `%0A` for newlines) |
| `cwd` | Absolute working directory path |
| `repo` | GitHub `owner/name` slug (resolves to most-recently-used local clone) |

`cwd` takes precedence over `repo` if both are present.

The prompt is pre-filled but NOT sent until you press Enter. A banner shows the external launch source.

**Shell invocation**:
```bash
open "claude-cli://open?repo=acme/payments&q=review%20open%20PRs"       # macOS
xdg-open "claude-cli://open?..."                                         # Linux
Start-Process "claude-cli://open?..."                                    # Windows PowerShell
```

Handler registered automatically on first interactive session. To disable: set `disableDeepLinkRegistration: "disable"` in settings.

Note: GitHub Markdown strips `claude-cli://` URLs — use a code block as workaround.

### Context Window Explorer

The interactive context window visualization at `/en/context-window` shows what loads and when during a simulated session.

**What survives `/compact`**:

| Mechanism | After compaction |
| :--- | :--- |
| System prompt + output style | Unchanged |
| Project-root CLAUDE.md + unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | Lost until matching file read again |
| Nested CLAUDE.md in subdirectories | Lost until file in subdirectory read again |
| Invoked skill bodies | Re-injected, capped at 5,000 tokens/skill, 25,000 total |
| Hooks | N/A (run as code, not context) |

Check live context: `/context` (breakdown by category). Check loaded CLAUDE.md files: `/memory`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code (features overview)](references/claude-code-features-overview.md) — when to use CLAUDE.md vs skills vs subagents vs agent teams vs MCP vs hooks; feature layering; context costs
- [Model configuration](references/claude-code-model-config.md) — model aliases, effort levels, extended thinking, 1M context, environment variables, third-party provider pinning, prompt caching
- [Output styles](references/claude-code-output-styles.md) — built-in styles, custom style authoring, frontmatter fields, comparison to CLAUDE.md and subagents
- [Status line](references/claude-code-statusline.md) — setup, available data fields, full JSON schema, example scripts (Bash/Python/Node.js), multi-line display, caching, Windows config
- [Checkpointing](references/claude-code-checkpointing.md) — automatic tracking, rewind menu, restore vs. summarize options, limitations
- [Remote Control](references/claude-code-remote-control.md) — server mode, interactive mode, VS Code, connecting from mobile/browser, push notifications, security, troubleshooting
- [Run prompts on a schedule (/loop)](references/claude-code-scheduled-tasks.md) — /loop syntax, fixed vs dynamic intervals, maintenance prompt, loop.md customization, one-time reminders, cron reference
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) — creating tasks in Desktop app, schedule options, permissions, missed runs, managing tasks
- [Cloud routines](references/claude-code-routines.md) — creating routines, schedule/API/GitHub triggers, connector configuration, network access, usage limits
- [Voice dictation](references/claude-code-voice-dictation.md) — hold mode, tap mode, language settings, rebinding dictation key, troubleshooting
- [Channels (Telegram/Discord/iMessage)](references/claude-code-channels.md) — supported channels setup, fakechat quickstart, security/pairing, enterprise controls
- [Channels reference (building channels)](references/claude-code-channels-reference.md) — capability declaration, notification format, reply tools, sender gating, permission relay, packaging as plugin
- [Context window explorer](references/claude-code-context-window.md) — interactive visualization, what loads when, compaction survival table
- [Fullscreen rendering](references/claude-code-fullscreen.md) — enable/disable, mouse usage, scroll shortcuts, transcript mode, tmux caveats, native text selection
- [Deep links](references/claude-code-deep-links.md) — URL format, cwd vs repo parameters, shell invocation, registration, troubleshooting
- [Fast mode](references/claude-code-fast-mode.md) — toggling, pricing, cost tradeoffs, requirements, per-session opt-in, rate limit fallback

## Sources

- Extend Claude Code (features overview): https://code.claude.com/docs/en/features-overview.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Run prompts on a schedule (/loop): https://code.claude.com/docs/en/scheduled-tasks.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Cloud routines: https://code.claude.com/docs/en/routines.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels (Telegram/Discord/iMessage): https://code.claude.com/docs/en/channels.md
- Channels reference (building channels): https://code.claude.com/docs/en/channels-reference.md
- Context window explorer: https://code.claude.com/docs/en/context-window.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
- Deep links: https://code.claude.com/docs/en/deep-links.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
