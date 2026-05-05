---
name: features-doc
description: Complete official documentation for Claude Code features — fast mode, model configuration and aliases, output styles, status line, checkpointing, remote control, scheduled tasks, voice dictation, channels, context window, fullscreen rendering, routines, deep links, and the features overview.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features.

## Quick Reference

### Fast Mode

Fast mode makes Opus 4.6 respond ~2.5x faster at a higher cost. Toggle with `/fast`.

| Mode | Input (MTok) | Output (MTok) |
| :--- | :--- | :--- |
| Fast mode (Opus 4.6) | $30 | $150 |

Key points:
- Requires Claude Code v2.1.36+, claude.ai subscription (not API key), and extra usage enabled
- Not available on Bedrock, Vertex AI, or Foundry
- Enable at session start for best cost efficiency (switching mid-session re-prices all cached tokens)
- Shows `↯` icon when active; falls back to standard Opus 4.6 on rate limit (icon turns gray)
- Teams/Enterprise: admin must enable via Console or Claude AI admin settings
- Persistent across sessions by default; set `fastModePerSessionOptIn: true` to require per-session opt-in

### Model Configuration

**Setting priority (highest to lowest):** `/model` command > `--model` flag > `ANTHROPIC_MODEL` env var > settings file

**Model aliases:**

| Alias | Behavior |
| :--- | :--- |
| `default` | Clears override, reverts to account default |
| `best` | Most capable model (currently = `opus`) |
| `sonnet` | Latest Sonnet (daily coding) |
| `opus` | Latest Opus (complex reasoning) |
| `haiku` | Fast/efficient model |
| `sonnet[1m]` | Sonnet with 1M token context |
| `opus[1m]` | Opus with 1M token context |
| `opusplan` | Opus for planning, auto-switches to Sonnet for execution |

**Default model by plan:**
- Max and Team Premium: Opus 4.7
- Pro, Team Standard, Enterprise, API: Sonnet 4.6
- Bedrock/Vertex/Foundry: Sonnet 4.5

**Effort levels** (set via `/effort`, `--effort`, `CLAUDE_CODE_EFFORT_LEVEL`, or settings `effortLevel`):

| Level | When to use |
| :--- | :--- |
| `low` | Short, latency-sensitive, not intelligence-sensitive |
| `medium` | Cost-sensitive, can trade some intelligence |
| `high` | Balanced; minimum for intelligence-sensitive work |
| `xhigh` | Best for most coding/agentic tasks (default on Opus 4.7) |
| `max` | Deepest reasoning; current session only |

Use `ultrathink` in a prompt for one-off deep reasoning without changing session effort.

**Extended context (1M tokens):**
- Opus 4.7, Opus 4.6, Sonnet 4.6 all support 1M context
- Max/Team/Enterprise: Opus 1M included; Sonnet 1M via extra usage
- Disable: `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`

**Env vars for alias resolution:**

| Variable | Controls |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | What `opus` alias resolves to |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | What `sonnet` alias resolves to |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | What `haiku` alias resolves to |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model used for subagents |

**Prompt caching control:**
- `DISABLE_PROMPT_CACHING=1` — disable for all models
- `DISABLE_PROMPT_CACHING_HAIKU/SONNET/OPUS=1` — disable per model tier

### Output Styles

Output styles modify the system prompt to change Claude's role, tone, and format.

**Built-in styles:**
- `Default` — software engineering assistant
- `Explanatory` — adds "Insights" explaining implementation choices
- `Learning` — adds Insights + asks you to write `TODO(human)` marked pieces yourself

**Set via:** `/config` > Output style, or `"outputStyle": "Explanatory"` in settings file. Takes effect next session (system prompt is set at session start for prompt caching).

**Custom output styles** — Markdown files with frontmatter:
- User-level: `~/.claude/output-styles/`
- Project-level: `.claude/output-styles/`
- Plugin: `output-styles/` in plugin directory

| Frontmatter | Purpose | Default |
| :--- | :--- | :--- |
| `name` | Display name | From filename |
| `description` | Shown in picker | None |
| `keep-coding-instructions` | Keep coding parts of default system prompt | `false` |

**vs CLAUDE.md:** Output styles modify the system prompt; CLAUDE.md adds a user message after it.
**vs Skills:** Output styles are always active once selected; skills load on demand.

### Status Line

A customizable bar at the bottom of Claude Code, running a shell script you configure.

**Configure in `~/.claude/settings.json`:**
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

Or use `/statusline show model and context percentage` to auto-generate.

**Key JSON fields available via stdin:**

| Field | Description |
| :--- | :--- |
| `model.display_name` | Current model name |
| `workspace.current_dir` | Working directory |
| `context_window.used_percentage` | Context used (0-100) |
| `context_window.context_window_size` | Max tokens (200K or 1M) |
| `cost.total_cost_usd` | Session cost estimate |
| `cost.total_duration_ms` | Total elapsed time ms |
| `effort.level` | Current effort level |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit % (Pro/Max) |
| `rate_limits.seven_day.used_percentage` | 7-day rate limit % (Pro/Max) |
| `session_id` | Unique session ID (use for cache keys) |
| `session_name` | Custom name (if set with `--name`) |
| `vim.mode` | Vim mode (`NORMAL`, `INSERT`, `VISUAL`) |
| `worktree.name/path/branch` | Worktree info (--worktree sessions only) |

Updates after each assistant message, permission mode change, or vim mode toggle (debounced 300ms).

**Subagent status line:** Use `subagentStatusLine` setting; receives `tasks` array, emits `{"id": "...", "content": "..."}` JSON lines.

### Checkpointing

Automatic tracking of file edits for rewind/recovery.

- Every user prompt creates a checkpoint
- Persists across sessions; cleaned up after 30 days
- Press `Esc` twice or run `/rewind` to open rewind menu

**Rewind actions:**
- **Restore code and conversation** — revert both
- **Restore conversation** — rewind messages, keep code
- **Restore code** — revert files, keep conversation
- **Summarize from here** — compress messages from selected point (no files changed)
- **Never mind** — cancel

**Limitations:** Bash command changes not tracked; external changes not tracked; not a replacement for git.

### Remote Control

Connect claude.ai or the Claude mobile app to a local Claude Code session.

**Requirements:** Pro/Max/Team/Enterprise subscription (not API key); claude.ai login; v2.1.51+. Team/Enterprise: admin must enable toggle.

**Start methods:**

| Command | Description |
| :--- | :--- |
| `claude remote-control` | Server mode: persistent process, multiple sessions |
| `claude --remote-control` | Interactive mode: local terminal + remote access |
| `/remote-control` | Enable from existing session |

**Server mode flags:**

| Flag | Description |
| :--- | :--- |
| `--name "title"` | Custom session title |
| `--spawn same-dir\|worktree\|session` | How new sessions are created |
| `--capacity N` | Max concurrent sessions (default 32) |
| `--sandbox` | Enable filesystem isolation |

**Connect from another device:** Open session URL, scan QR code (press spacebar in server mode), or browse claude.ai/code session list.

**Security:** All traffic via Anthropic API over TLS; outbound HTTPS only, no inbound ports opened.

**vs Claude Code on the web:** Remote Control runs on your machine (local files, MCP, tools available); web runs in Anthropic cloud.

### Scheduled Tasks (`/loop`)

Session-scoped scheduled tasks. Tasks live in the current conversation.

| What you provide | Result |
| :--- | :--- |
| `/loop 5m check the deploy` | Fixed interval |
| `/loop check the deploy` | Claude chooses interval dynamically |
| `/loop` | Built-in maintenance prompt (PR triage, cleanup) |

**Scheduling comparison:**

| | Cloud (Routines) | Desktop | `/loop` |
| :--- | :--- | :--- | :--- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires open session | No | No | Yes |
| Persistent | Yes | Yes | Restored on `--resume` if unexpired |
| Min interval | 1 hour | 1 minute | 1 minute |

**Cron tools:** `CronCreate`, `CronList`, `CronDelete`. Max 50 tasks per session.

**Key behaviors:**
- All times interpreted in local timezone
- Recurring tasks expire after 7 days automatically
- `Esc` stops a `/loop` waiting for next iteration
- Set `CLAUDE_CODE_DISABLE_CRON=1` to disable entirely

**`loop.md` for custom default prompt:**
- `.claude/loop.md` (project) takes precedence over `~/.claude/loop.md` (user)
- Replaces the built-in maintenance prompt when `/loop` is used with no prompt argument

### Voice Dictation

Speak prompts instead of typing. Transcription done server-side (not local).

**Requirements:** claude.ai account (not API key/Bedrock/Vertex/Foundry); local microphone; v2.1.69+. Not in remote environments or SSH sessions.

| Command | Effect |
| :--- | :--- |
| `/voice` | Toggle on/off, keep current mode |
| `/voice hold` | Enable hold-to-record (default) |
| `/voice tap` | Enable tap-to-record-and-send (v2.1.116+) |
| `/voice off` | Disable |

**Hold mode:** Hold `Space`, speak, release. Brief warmup (key-repeat detection). Set `"autoSubmit": true` to auto-send on release.

**Tap mode:** Tap `Space` to start, speak, tap again to send. No warmup. Auto-sends if transcript ≥ 3 words.

**Settings:**
```json
{ "voice": { "enabled": true, "mode": "tap" } }
```

**Language:** Controlled by `language` setting. Defaults to English. Supported: cs, da, nl, en, fr, de, el, hi, id, it, ja, ko, no, pl, pt, ru, es, sv, tr, uk.

**Rebind key** in `~/.claude/keybindings.json` — bind action `voice:pushToTalk` in `Chat` context. Use modifier combos (e.g., `meta+k`) to avoid hold-mode warmup.

### Channels (Research Preview)

Push events from external systems (Telegram, Discord, iMessage) into a running Claude Code session.

**Requirements:** claude.ai login; v2.1.80+; Team/Enterprise must enable via admin settings (`channelsEnabled: true`).

**Start with channels:**
```bash
claude --channels plugin:telegram@claude-plugins-official
```

**Supported channels (install via `/plugin install <name>@claude-plugins-official`):**
- `telegram` — requires Bun; configure with `/telegram:configure <token>`
- `discord` — requires Bun; configure with `/discord:configure <token>`
- `imessage` — macOS only; requires Full Disk Access; no token needed

**Security:** Sender allowlist gates all messages. Pair by sending any message to bot → bot returns code → `/telegram:access pair <code>` → `/telegram:access policy allowlist`.

**Enterprise controls:**

| Setting | Purpose |
| :--- | :--- |
| `channelsEnabled` | Master switch (must be `true`) |
| `allowedChannelPlugins` | Which plugins can register (replaces Anthropic default list) |

**How channels differ from other features:**
- Standard MCP: Claude queries it; nothing pushed to session
- Remote Control: you drive local session from another device
- Channels: external systems push events INTO your running session

### Context Window (Interactive Reference)

The `context-window.md` reference is an interactive simulation showing what loads when. Key facts:

- System prompt: ~4,200 tokens, always loaded first (hidden)
- CLAUDE.md files: loaded at session start, persist through compaction
- Skill descriptions: ~450 tokens at session start; full content loads on invocation; NOT re-injected after `/compact`
- MCP tool names: deferred by default; full schemas loaded on demand via tool search
- Subagent context: isolated, inherits system prompt + explicitly specified skills

### Fullscreen Rendering (Research Preview)

Flicker-free, flat-memory rendering mode using the terminal's alternate screen buffer.

**Enable:** `/tui fullscreen` (mid-session, keeps context) or `CLAUDE_CODE_NO_FLICKER=1`
**Disable:** `/tui default`

**Key differences from default rendering:**

| Feature | Default | Fullscreen |
| :--- | :--- | :--- |
| Scroll to search | `Cmd+F` / tmux search | `Ctrl+O` for transcript mode, then `/` |
| Text selection | Terminal native | In-app (auto-copies on release) |
| URL clicking | `Cmd`-click | Click directly |

**Mouse:** Click to expand tool output, click URLs/file paths to open, click-drag to select. Disable mouse capture: `CLAUDE_CODE_DISABLE_MOUSE=1`.

**Scroll shortcuts:** `PgUp`/`PgDn`, `Ctrl+Home`/`Ctrl+End` (or `Fn+arrows` on Mac). Set `CLAUDE_CODE_SCROLL_SPEED=3` to amplify wheel events.

**tmux:** Requires `set -g mouse on` in `~/.tmux.conf`. Incompatible with `tmux -CC` (iTerm2 integration mode).

### Routines (Research Preview)

Cloud-based scheduled automation on Anthropic infrastructure.

**Triggers:**
- **Scheduled** — hourly/nightly/weekly cadence or specific future time
- **API** — HTTP POST to per-routine endpoint with bearer token
- **GitHub** — repository events (pull_request, release, etc.)

**Create at:** claude.ai/code/routines, Desktop app (Routines > New routine > Remote), or CLI `/schedule`.

**vs Desktop scheduled tasks vs `/loop`:**
- Routines: cloud, survives machine off, no local file access (fresh clone), min 1h
- Desktop: local, requires machine on/app open, has local files, min 1m
- `/loop`: local, requires open session, min 1m

### Deep Links

Open Claude Code from a URL (`claude-cli://` scheme registered with OS).

**Format:** `claude-cli://open?q=<url-encoded-prompt>&cwd=<absolute-path>`

**Parameters:**

| Parameter | Description |
| :--- | :--- |
| `q` | URL-encoded prompt text (max 5,000 chars) |
| `cwd` | Absolute working directory path |

Prompt is pre-filled but NOT auto-submitted. Requires v2.1.91+.

**Note:** GitHub-rendered Markdown strips `claude-cli://` links (shows text only, no link).

### Features Overview

When to use each extension type:

| Feature | Loads | Best for |
| :--- | :--- | :--- |
| CLAUDE.md | Every session | Always-on rules and conventions |
| Skills | On demand | Reference docs, invocable workflows |
| MCP | Session start (deferred schemas) | External service connections |
| Subagents | When spawned | Context isolation, parallel work |
| Hooks | On trigger event | Guaranteed automation |
| Plugins | At install | Bundling and distributing feature sets |

**Feature layering:**
- CLAUDE.md: additive (all levels load simultaneously)
- Skills/subagents: override by name (managed > user > project)
- MCP servers: local > project > user
- Hooks: merge (all registered hooks fire)

## Full Documentation

For the complete official documentation, see the reference files:

- [Fast mode](references/claude-code-fast-mode.md) — toggle `/fast`, pricing, rate limits, org controls
- [Model configuration](references/claude-code-model-config.md) — aliases, effort levels, extended context, env vars, third-party pinning
- [Output styles](references/claude-code-output-styles.md) — built-in and custom styles, frontmatter, vs CLAUDE.md/skills/agents
- [Status line](references/claude-code-statusline.md) — setup, all available JSON fields, examples (git, cost, multi-line, links, rate limits, caching), subagent status line
- [Checkpointing](references/claude-code-checkpointing.md) — rewind menu, summarize vs restore, limitations
- [Features overview](references/claude-code-features-overview.md) — when to use each feature, layering, context costs
- [Remote control](references/claude-code-remote-control.md) — server mode, interactive mode, VS Code, security, mobile push notifications, troubleshooting
- [Scheduled tasks](references/claude-code-scheduled-tasks.md) — `/loop`, cron tools, jitter, expiry, loop.md customization
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) — Desktop Routines UI, schedule options, missed runs, permissions
- [Routines](references/claude-code-routines.md) — cloud automation, schedule/API/GitHub triggers, management
- [Voice dictation](references/claude-code-voice-dictation.md) — hold mode, tap mode, language, keybinding, troubleshooting
- [Channels](references/claude-code-channels.md) — Telegram/Discord/iMessage setup, security, enterprise controls, comparison table
- [Channels reference](references/claude-code-channels-reference.md) — building custom channels, MCP contract, notification format, reply tools, permission relay
- [Context window](references/claude-code-context-window.md) — interactive simulation of what loads when and at what token cost
- [Fullscreen rendering](references/claude-code-fullscreen.md) — enable, mouse support, scrolling, tmux, text selection
- [Deep links](references/claude-code-deep-links.md) — URL format, parameters, platform registration, examples

## Sources

- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Features overview: https://code.claude.com/docs/en/features-overview.md
- Remote control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Routines: https://code.claude.com/docs/en/routines.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Context window: https://code.claude.com/docs/en/context-window.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
- Deep links: https://code.claude.com/docs/en/deep-links.md
