---
name: features-doc
description: Complete official documentation for Claude Code features — extension overview (CLAUDE.md, skills, subagents, MCP, hooks, plugins), fast mode, model configuration, output styles, status line, checkpointing, remote control, scheduled tasks, voice dictation, channels, desktop scheduled tasks, context window visualization, fullscreen rendering, routines, and deep links.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features.

## Quick Reference

### Extension Features Overview

| Feature | What it does | Loads |
| :--- | :--- | :--- |
| **CLAUDE.md** | Persistent context every session | Always, at start |
| **Skills** | Reusable knowledge and workflows | Descriptions at start; full content when used |
| **Subagents** | Isolated workers with own context window | On spawn |
| **Agent teams** | Multiple independent sessions coordinating | On spawn |
| **MCP** | Connect to external services | Tool names at start; schemas on demand |
| **Hooks** | Scripts/requests on lifecycle events | On trigger; zero context unless output returned |
| **Plugins** | Bundle and distribute feature sets | When installed |

### When to add each feature

| Trigger | Add |
| :--- | :--- |
| Claude gets a convention wrong twice | Add to CLAUDE.md |
| You keep typing the same prompt | Save as a user-invocable skill |
| A side task floods your conversation | Route through a subagent |
| You keep copying data from a browser tab | Connect as MCP server |
| You want something to happen every time | Write a hook |
| A second repository needs the same setup | Package as a plugin |

### Feature Layering / Priority

| Feature | Priority order |
| :--- | :--- |
| CLAUDE.md | Additive — all levels load simultaneously; conflicts resolved by specificity |
| Skills / subagents | Override by name: managed > user > project (skills); managed > CLI > project > user > plugin (subagents) |
| MCP servers | Override by name: local > project > user |
| Hooks | Merge — all registered hooks fire regardless of source |

### Context Cost by Feature

| Feature | When loads | Context cost |
| :--- | :--- | :--- |
| CLAUDE.md | Session start | Every request |
| Skills | Descriptions at start; full content when used | Low (descriptions every request) |
| MCP servers | Tool names at start; schemas on demand | Low until used |
| Subagents | When spawned | Isolated from main session |
| Hooks | On trigger | Zero unless hook returns output |

Set `disable-model-invocation: true` in a skill's frontmatter to hide it from Claude until manually invoked — zero context cost.

### What survives /compact

| Mechanism | After compaction |
| :--- | :--- |
| System prompt and output style | Unchanged |
| Project-root CLAUDE.md and unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | Lost until a matching file is read again |
| Nested CLAUDE.md in subdirectories | Lost until a file in that subdirectory is read again |
| Invoked skill bodies | Re-injected, capped at 5,000 tokens per skill / 25,000 total; oldest dropped first |
| Hooks | Not applicable (run as code, not context) |

---

### Fast Mode

Toggle fast mode for 2.5x faster Opus 4.6 responses at higher cost.

| Setting | Value |
| :--- | :--- |
| Toggle | `/fast` or `"fastMode": true` in settings |
| Pricing | $30/$150 MTok (input/output) |
| Indicator | Small `↯` icon next to prompt |
| Rate limit fallback | Auto-falls back to standard Opus 4.6; icon turns gray |
| Available on | Pro/Max/Team/Enterprise (subscription plans) and Console; NOT on Bedrock/Vertex/Foundry |
| Team/Enterprise | Disabled by default; admin must enable |
| Per-session opt-in | `fastModePerSessionOptIn: true` in managed settings |
| Env disable | `CLAUDE_CODE_DISABLE_FAST_MODE=1` |

Fast mode vs effort level: fast mode = same quality, lower latency, higher cost. Lower effort = less thinking, faster, potentially lower quality.

---

### Model Configuration

| Alias | Model used |
| :--- | :--- |
| `default` | Clears override; reverts to recommended for account type |
| `best` / `opus` | Latest Opus (Opus 4.7 on Anthropic API) |
| `sonnet` | Latest Sonnet (Sonnet 4.6 on Anthropic API) |
| `haiku` | Fast Haiku model |
| `sonnet[1m]` / `opus[1m]` | 1M token context window variant |
| `opusplan` | Opus for plan mode, switches to Sonnet for execution |

**Default model by account type:**
- Max and Team Premium: Opus 4.7
- Pro, Team Standard, Enterprise, Anthropic API: Sonnet 4.6
- Bedrock, Vertex, Foundry: Sonnet 4.5

**Set model priority:** `/model <alias>` > `--model` flag > `ANTHROPIC_MODEL` env var > settings file.

**Effort levels (Opus 4.7):** `low`, `medium`, `high`, `xhigh`, `max`
**Effort levels (Opus 4.6, Sonnet 4.6):** `low`, `medium`, `high`, `max`

Default: `xhigh` on Opus 4.7, `high` on Opus 4.6 / Sonnet 4.6 (as of v2.1.117).

Use `ultrathink` anywhere in a prompt for deeper one-off reasoning without changing effort setting.

**Extended context (1M tokens):**
- Max, Team, Enterprise: Opus 1M included; Sonnet 1M via extra usage
- Pro: both via extra usage
- API: full access

**Key env vars:**
| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model name for `opus` alias |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model name for `sonnet` alias |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model name for `haiku` alias |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |
| `ANTHROPIC_CUSTOM_MODEL_OPTION` | Add one custom entry to `/model` picker |
| `CLAUDE_CODE_DISABLE_1M_CONTEXT=1` | Disable 1M context variants |

---

### Output Styles

Modify how Claude responds (role, tone, format) without changing capabilities.

| Style | Description |
| :--- | :--- |
| `Default` | Standard software engineering mode |
| `Explanatory` | Adds educational "Insights" between tasks |
| `Learning` | Collaborative; adds `TODO(human)` markers for you to implement |

**Change:** `/config` > Output style, or set `"outputStyle": "Explanatory"` in settings.
**Location:** `~/.claude/output-styles/` (user) or `.claude/output-styles/` (project).
**Frontmatter fields:** `name`, `description`, `keep-coding-instructions` (default false).

Output styles modify the system prompt at session start; changes take effect next session.

---

### Status Line

Customizable bar at the bottom that runs a shell script receiving JSON session data.

**Config:**
```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2,
    "refreshInterval": 5,
    "hideVimModeIndicator": false
  }
}
```

**Key JSON fields available to script:**

| Field | Description |
| :--- | :--- |
| `model.display_name` | Current model |
| `workspace.current_dir` | Working directory |
| `context_window.used_percentage` | % of context used |
| `context_window.context_window_size` | Max tokens (200k or 1M) |
| `cost.total_cost_usd` | Estimated session cost |
| `cost.total_duration_ms` | Wall-clock session time |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit % (Pro/Max only) |
| `rate_limits.seven_day.used_percentage` | 7-day rate limit % (Pro/Max only) |
| `effort.level` | Current effort level |
| `vim.mode` | Vim mode when enabled |
| `session_id` | Stable session ID (use for caching) |
| `session_name` | Custom name if set |

**Generate via `/statusline show model name and context percentage with a progress bar`.**

---

### Checkpointing

Automatic tracking of file edits; rewind to any prior state.

| Action | How |
| :--- | :--- |
| Open rewind menu | `Esc` + `Esc` or `/rewind` |
| Restore code + conversation | Select prompt, choose action |
| Restore code only | Keep conversation, revert files |
| Restore conversation only | Keep files, rewind chat |
| Summarize from here | Compress conversation forward; preserves original in transcript |

**Limitations:** Bash command file changes not tracked. External file changes not tracked. Cleans up after 30 days. Not a replacement for git.

---

### Remote Control

Connect claude.ai or Claude mobile app to a running local Claude Code session.

| Mode | Command |
| :--- | :--- |
| Server mode (wait for connections) | `claude remote-control` |
| Interactive + remote | `claude --remote-control` or `claude --rc` |
| From existing session | `/remote-control` or `/rc` |

**Connect:** open session URL, scan QR code (press spacebar in server mode), or find in claude.ai/code session list.

**Spawn modes (`--spawn`):** `same-dir` (default), `worktree` (isolated git worktree per session), `session` (single session only).

**Requirements:** Pro/Max/Team/Enterprise (not API keys); claude.ai OAuth auth; Claude Code v2.1.51+.
**Team/Enterprise:** admin must enable Remote Control toggle in admin settings.

**Push notifications:** install Claude mobile app, sign in, allow notifications, enable in `/config`.

---

### Scheduled Tasks (/loop)

Session-scoped scheduling; tasks stop when session ends (restored on `--resume` if unexpired within 7 days).

| Usage | Behavior |
| :--- | :--- |
| `/loop 5m check the deploy` | Fixed interval with your prompt |
| `/loop check the deploy` | Dynamic interval Claude chooses |
| `/loop` | Built-in maintenance prompt (continue work, tend PR, cleanup) |
| `/loop 15m` | Maintenance prompt on fixed schedule |

**One-time reminders:** describe in natural language — "remind me at 3pm to push the release branch".

**Cron expression reference:**
| Expression | Meaning |
| :--- | :--- |
| `*/5 * * * *` | Every 5 minutes |
| `0 9 * * *` | Daily at 9am local |
| `0 9 * * 1-5` | Weekdays at 9am local |

**Limits:** max 50 tasks per session; recurring tasks expire after 7 days; `Esc` stops a `/loop` (not other tasks).

**Disable:** `CLAUDE_CODE_DISABLE_CRON=1`.

**Custom default prompt:** `.claude/loop.md` (project) or `~/.claude/loop.md` (user).

---

### Desktop Scheduled Tasks

Local tasks that run while the Desktop app is open (not cloud-based).

| Schedule | Options |
| :--- | :--- |
| Manual | Run only on "Run now" |
| Hourly/Daily/Weekdays/Weekly | Built-in presets |
| Custom intervals | Ask Claude in any session |

**Create:** Routines sidebar > New routine > Local, OR describe in any session.

**Storage:** `~/.claude/scheduled-tasks/<task-name>/SKILL.md` (prompt as body; frontmatter has `name`, `description`).

**Missed runs:** on wake, runs one catch-up for the most recently missed time (discards older).

**Scheduling comparison:**

| | Cloud (Routines) | Desktop | /loop |
| :--- | :--- | :--- | :--- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Access to local files | No (fresh clone) | Yes | Yes |
| Minimum interval | 1 hour | 1 minute | 1 minute |

---

### Routines (Cloud Scheduled Tasks)

Run on Anthropic-managed infrastructure; survive laptop closure.

**Triggers:** Schedule (min 1 hour interval), API (HTTP POST), GitHub events (PR/release).

**Create:** claude.ai/code/routines, Desktop Routines sidebar (Remote), or `/schedule` in CLI.

**API trigger example:**
```bash
curl -X POST https://api.anthropic.com/v1/claude_code/routines/<trig_id>/fire \
  -H "Authorization: Bearer <token>" \
  -H "anthropic-beta: experimental-cc-routine-2026-04-01" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"text": "Optional run-specific context"}'
```

**GitHub trigger events:** `pull_request` (opened/closed/labeled/etc.), `release` (created/published/etc.).

**Branch permissions:** By default only `claude/`-prefixed branches. Enable "Allow unrestricted branch pushes" per repo for full access.

**Usage:** counts against daily routine run cap + subscription usage. One-off runs exempt from daily cap.

---

### Channels (Research Preview)

Push events from external systems into a running local Claude Code session.

**Requirements:** Claude Code v2.1.80+; claude.ai or Console API key auth; NOT on Bedrock/Vertex/Foundry. Team/Enterprise: admin must enable.

**Supported channels (research preview):** Telegram, Discord, iMessage, fakechat (localhost demo).

**Install a channel:**
```
/plugin install telegram@claude-plugins-official
```
**Start with channel enabled:**
```bash
claude --channels plugin:telegram@claude-plugins-official
```

**Security:** sender allowlist per channel. Telegram/Discord: pair via bot code. iMessage: text yourself (auto-allowed); add others with `/imessage:access allow +15551234567`.

**Enterprise settings:**
| Setting | Purpose |
| :--- | :--- |
| `channelsEnabled` | Master switch (required for Team/Enterprise) |
| `allowedChannelPlugins` | Restrict which plugins can register |

**Custom channels:** implement MCP server that declares `claude/channel` capability and emits `notifications/claude/channel` events.

---

### Context Window (Interactive Visualization)

The `/en/context-window` page provides an interactive simulation showing what loads when during a session.

**What loads automatically before your first prompt:**
- System prompt (~4,200 tokens)
- Auto memory / MEMORY.md (first 200 lines or 25KB)
- Environment info (working dir, platform, shell, git status)
- MCP tool names (deferred — schemas load on demand)
- Skill descriptions (unless `disable-model-invocation: true`)
- All CLAUDE.md files (user, project, managed)

**Run `/context`** for live breakdown with optimization suggestions.
**Run `/memory`** to see which CLAUDE.md and auto memory files loaded.

---

### Fullscreen Rendering (Research Preview)

Alternative CLI rendering using terminal alternate screen buffer (like vim/htop).

**Enable:** `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1 claude`.
**Disable:** `/tui default` or unset env var.

**Benefits:** eliminates flicker, flat memory in long conversations, mouse support.

**Mouse actions:**
- Click in prompt: position cursor
- Click collapsed tool result: expand/collapse
- Click URL or file path: open it
- Click and drag: select text (auto-copies to clipboard)

**Scrolling shortcuts:**
| Key | Action |
| :--- | :--- |
| `PgUp` / `PgDn` | Scroll half-screen |
| `Ctrl+Home` | Jump to start |
| `Ctrl+End` | Jump to latest (re-enable auto-follow) |

**Transcript mode:** `Ctrl+O` — enables `/` search, `[` to write to scrollback, `v` to open in `$EDITOR`.

**Env vars:**
| Var | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_NO_FLICKER=1` | Enable fullscreen |
| `CLAUDE_CODE_DISABLE_MOUSE=1` | Keep flicker-free but disable mouse capture |
| `CLAUDE_CODE_SCROLL_SPEED=3` | Multiply scroll distance (1-20) |

---

### Deep Links

Open Claude Code from a URL with a pre-filled prompt and working directory.

**URL format:** `claude-cli://open?repo=owner/name&q=URL-encoded+prompt`

| Parameter | Description |
| :--- | :--- |
| `q` | URL-encoded prompt text (max 5,000 chars; `%0A` for line breaks) |
| `cwd` | Absolute path for working directory |
| `repo` | GitHub `owner/name` slug (resolves to most recently used local clone) |

If both `cwd` and `repo` are provided, `cwd` takes precedence.

**Requirements:** Claude Code v2.1.91+. Registered automatically on first interactive session.

**Registration locations:**
| Platform | Location |
| :--- | :--- |
| macOS | `~/Applications/Claude Code URL Handler.app` |
| Linux | `~/.local/share/applications/claude-code-url-handler.desktop` |
| Windows | `HKEY_CURRENT_USER\Software\Classes\claude-cli` |

**Open from shell:**
```bash
# macOS
open "claude-cli://open?repo=acme/payments&q=review%20open%20PRs"
# Linux
xdg-open "claude-cli://open?repo=acme/payments&q=review%20open%20PRs"
```

**Disable registration:** set `disableDeepLinkRegistration: "disable"` in settings.json.

**Note:** GitHub Markdown strips `claude-cli://` links. Put the URL in a code block as a workaround.

**VS Code alternative:** `vscode://anthropic.claude-code/open` opens a VS Code tab instead of terminal.

---

### Voice Dictation

Speak prompts instead of typing; transcribed live into the prompt input.

**Requirements:** Claude.ai account (not API key, Bedrock, Vertex, Foundry); Claude Code v2.1.69+. Tap mode requires v2.1.116+.

| Command | Effect |
| :--- | :--- |
| `/voice` | Toggle on/off (keep current mode) |
| `/voice hold` | Push-to-talk mode (default) |
| `/voice tap` | Tap once to start, tap again to send |
| `/voice off` | Disable |

**Hold mode:** hold `Space` to record; warmup period before recording starts. Release to insert transcript.
**Tap mode:** tap `Space` (only when prompt is empty) to start; tap again to stop and auto-submit if 3+ words.

**Settings:**
```json
{
  "voice": {
    "enabled": true,
    "mode": "tap",
    "autoSubmit": true
  }
}
```

**Language:** uses `language` setting (e.g., `"language": "japanese"`). Supports 20 languages.

**Rebind key:** `voice:pushToTalk` action in `~/.claude/keybindings.json`. Default: `Space`.

**Linux fallback:** uses `arecord` or `rec` (SoX) if native module unavailable.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code (Features Overview)](references/claude-code-features-overview.md) — when to use CLAUDE.md vs skills vs subagents vs agent teams vs MCP vs hooks vs plugins, context cost by feature, how features layer, combine features
- [Fast Mode](references/claude-code-fast-mode.md) — toggle fast mode, cost tradeoff, when to use, rate limits, admin controls
- [Model Configuration](references/claude-code-model-config.md) — model aliases, setting model, effort levels, extended thinking, extended context, env vars, pin models for third-party deployments, prompt caching
- [Output Styles](references/claude-code-output-styles.md) — built-in styles (Default/Explanatory/Learning), custom output style files, frontmatter, comparisons to CLAUDE.md and agents
- [Status Line](references/claude-code-statusline.md) — full JSON schema, all available fields, example scripts (Bash/Python/Node.js), multi-line, git status, cost tracking, clickable links, rate limits, caching, Windows config, subagent status lines, troubleshooting
- [Checkpointing](references/claude-code-checkpointing.md) — automatic tracking, rewind menu, restore vs summarize, limitations
- [Remote Control](references/claude-code-remote-control.md) — server mode, interactive mode, spawn modes, connect from another device, push notifications, security model, troubleshooting
- [Scheduled Tasks (/loop)](references/claude-code-scheduled-tasks.md) — /loop usage, fixed vs dynamic intervals, maintenance prompt, loop.md customization, one-time reminders, managing tasks, cron reference, seven-day expiry, disable flag
- [Desktop Scheduled Tasks](references/claude-code-desktop-scheduled-tasks.md) — create tasks, schedule options, missed runs, permissions, manage tasks, compare scheduling options
- [Routines](references/claude-code-routines.md) — create routines, schedule/API/GitHub triggers, manage runs, repositories and branch permissions, connectors, environments, usage and limits
- [Channels](references/claude-code-channels.md) — Telegram/Discord/iMessage setup, fakechat quickstart, security/allowlists, enterprise controls, how channels compare to other features
- [Channels Reference](references/claude-code-channels-reference.md) — build a custom channel, MCP server contract, capability declaration, notification format, reply tool, sender gating, permission relay
- [Context Window](references/claude-code-context-window.md) — interactive visualization of session context loading, what survives compaction, token costs per category
- [Fullscreen Rendering](references/claude-code-fullscreen.md) — enable/disable, mouse support, scrolling, transcript mode, search, tmux usage, disable mouse capture, troubleshooting
- [Deep Links](references/claude-code-deep-links.md) — URL format, parameters, cwd vs repo, examples, registration platforms, VS Code tab alternative, troubleshooting
- [Voice Dictation](references/claude-code-voice-dictation.md) — requirements, hold mode, tap mode, dictation language, rebind key, troubleshooting

## Sources

- Extend Claude Code (Features Overview): https://code.claude.com/docs/en/features-overview.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled Tasks (/loop): https://code.claude.com/docs/en/scheduled-tasks.md
- Desktop Scheduled Tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Routines: https://code.claude.com/docs/en/routines.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels Reference: https://code.claude.com/docs/en/channels-reference.md
- Context Window: https://code.claude.com/docs/en/context-window.md
- Fullscreen Rendering: https://code.claude.com/docs/en/fullscreen.md
- Deep Links: https://code.claude.com/docs/en/deep-links.md
- Voice Dictation: https://code.claude.com/docs/en/voice-dictation.md
