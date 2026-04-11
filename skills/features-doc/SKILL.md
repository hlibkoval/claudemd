---
name: features-doc
description: Complete official documentation for Claude Code features — fast mode, model configuration and effort levels, output styles, status line, checkpointing, remote control, scheduled tasks (CLI, Desktop, Cloud), voice dictation, channels (push events into a session), context window simulator, fullscreen rendering, and the extension-layer overview comparing CLAUDE.md, skills, subagents, MCP, hooks, and plugins.
user-invocable: false
---

# Claude Code Features Documentation

This skill provides the complete official documentation for Claude Code's user-facing features and extension layer: how to choose between CLAUDE.md/skills/subagents/MCP/hooks/plugins, plus the built-in capabilities (fast mode, model config, output styles, status line, checkpointing, remote control, scheduling, voice, channels, context, fullscreen).

## Quick Reference

### Extension layer: which feature to use

| Feature | What it does | When to use |
| --- | --- | --- |
| CLAUDE.md | Persistent context loaded every session | "Always do X" rules, conventions |
| Skill | Reusable instructions/workflows on demand | Reference material, repeatable tasks, `/name` workflows |
| Subagent | Isolated context; returns only summary | Parallel tasks, specialized workers, context isolation |
| Agent team | Independent Claude Code sessions that message each other | Parallel research with discussion |
| MCP | Connect to external services | Database queries, Slack, browsers |
| Hook | Deterministic script on lifecycle events | Linting after edit, logging, automation |
| Plugin | Bundles skills + hooks + subagents + MCP | Reuse setup across repos; distribute via marketplace |

Layering: CLAUDE.md is additive; skills/subagents override by name (managed > user > project); MCP overrides local > project > user; hooks merge.

### Fast mode (`/fast`)

- Toggles a high-speed API configuration for **Opus 4.6**: ~2.5x faster, same quality, higher cost (\$30/\$150 per MTok input/output).
- Enable with `/fast` (Tab to toggle), or `"fastMode": true` in user settings.
- Requires Claude Code v2.1.36+, extra usage enabled, and (Team/Enterprise) admin enablement.
- Not available on Bedrock, Vertex AI, or Foundry.
- Admin reset-per-session: `"fastModePerSessionOptIn": true` in managed settings.
- Disable entirely: `CLAUDE_CODE_DISABLE_FAST_MODE=1`.
- Rate-limit fallback: drops to standard Opus 4.6 (gray `↯` icon), auto-re-enables on cooldown.

### Model configuration

Aliases: `default`, `best`, `sonnet`, `opus`, `haiku`, `sonnet[1m]`, `opus[1m]`, `opusplan` (Opus in plan mode, Sonnet in execution).

Set via: `/model <alias>`, `claude --model <alias>`, `ANTHROPIC_MODEL` env var, or `"model"` in settings (priority in that order).

| Setting | Purpose |
| --- | --- |
| `availableModels` | Allowlist for `/model` picker (managed/policy for enforcement) |
| `modelOverrides` | Map Anthropic model IDs to Bedrock ARNs / Vertex versions / Foundry deployments |
| `ANTHROPIC_DEFAULT_{OPUS,SONNET,HAIKU}_MODEL` | Pin family alias to a specific model ID |
| `ANTHROPIC_CUSTOM_MODEL_OPTION` | Add a single custom entry to `/model` picker |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model used for subagents |

**Effort levels** (adaptive reasoning on Opus/Sonnet 4.6): `low`, `medium`, `high`, `max` (Opus 4.6 only, non-persistent).
- Set via `/effort <level>` or `/effort auto`, `--effort` flag, `effortLevel` setting, `CLAUDE_CODE_EFFORT_LEVEL` env, or `effort:` frontmatter on a skill/subagent.
- Say "ultrathink" in a prompt for one-shot high effort.
- Disable adaptive thinking: `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1`.

**1M context window**: use `opus[1m]`/`sonnet[1m]` aliases. Included on Max/Team/Enterprise for Opus; extra usage for others. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

**Prompt caching**: `DISABLE_PROMPT_CACHING`, `DISABLE_PROMPT_CACHING_{HAIKU,SONNET,OPUS}`.

### Output styles

Modify the system prompt to change role/tone/format while keeping core capabilities. Built-in: **Default**, **Explanatory** (adds "Insights"), **Learning** (adds `TODO(human)` markers).

- Set via `/config` or `"outputStyle": "Name"` in settings. Takes effect on next session start.
- Custom styles: markdown files in `~/.claude/output-styles/` or `.claude/output-styles/` (or plugin `output-styles/` dir).
- Frontmatter: `name`, `description`, `keep-coding-instructions` (default `false` — custom styles strip coding instructions unless this is true).

### Status line

Custom shell script at the bottom of the CLI. Receives JSON on stdin, prints to stdout.

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

- Generate one: `/statusline <description>`. Delete: `/statusline delete`.
- Updates after each assistant message, permission mode change, vim mode toggle (debounced 300ms). Use `refreshInterval` for time-based content.
- Available JSON fields include: `model.{id,display_name}`, `cwd`, `workspace.{current_dir,project_dir,added_dirs,git_worktree}`, `cost.{total_cost_usd,total_duration_ms,total_api_duration_ms,total_lines_added,total_lines_removed}`, `context_window.{total_input_tokens,total_output_tokens,context_window_size,used_percentage,remaining_percentage,current_usage}`, `exceeds_200k_tokens`, `rate_limits.{five_hour,seven_day}.{used_percentage,resets_at}`, `session_id`, `session_name`, `transcript_path`, `version`, `output_style.name`, `vim.mode`, `agent.name`, `worktree.{name,path,branch,original_cwd,original_branch}`.
- Supports multi-line output, ANSI colors, and OSC 8 clickable links. Runs locally — zero API tokens.

### Checkpointing

Automatic per-prompt snapshots of Claude's file edits.

- `Esc`+`Esc` or `/rewind` opens the rewind menu.
- Actions: **Restore code and conversation**, **Restore conversation**, **Restore code**, **Summarize from here** (compress conversation from that point into a summary, leaving disk untouched), **Never mind**.
- Persists across sessions; auto-cleaned after 30 days.
- **Not tracked**: bash-command file changes, external edits, files outside the session. Not a replacement for git.

### Remote Control

Drive a local Claude Code session from claude.ai/code or the Claude mobile app. Session runs on your machine; web/mobile is a window into it.

| Command | Mode |
| --- | --- |
| `claude remote-control` | Server mode (waits for remote connections) |
| `claude --remote-control` / `--rc` | Interactive session with remote enabled |
| `/remote-control` / `/rc` | Promote existing session to remote |

Server-mode flags: `--name`, `--remote-control-session-name-prefix`, `--spawn <same-dir|worktree|session>` (press `w` to toggle same-dir↔worktree), `--capacity <N>` (default 32), `--verbose`, `--sandbox`/`--no-sandbox`.

- Requires v2.1.51+, Pro/Max/Team/Enterprise (claude.ai login; not API keys, not Bedrock/Vertex/Foundry), workspace trust accepted.
- Team/Enterprise: admin toggle required in `claude.ai/admin-settings/claude-code`.
- Enable for every session: `/config` → "Enable Remote Control for all sessions".
- Press spacebar in server mode for a QR code. Use `/mobile` to get an app download QR.
- Limitations: one remote session per interactive process (unless server mode), process must keep running, ~10 min network outage ends the session, ultraplan disconnects it.

### Scheduled tasks — three options

| Option | Runs on | Persistent | Min interval |
| --- | --- | --- | --- |
| **Cloud** (`/schedule`, claude.ai/code/scheduled) | Anthropic cloud | Yes | 1 hour |
| **Desktop** (Schedule page) | Your machine | Yes | 1 minute |
| **`/loop`** (CLI) | Your machine | No (session-scoped) | 1 minute |

**`/loop`** forms (requires v2.1.72+):

| Input | Behavior |
| --- | --- |
| `/loop 5m check the deploy` | Fixed cron schedule |
| `/loop check the deploy` | Claude picks interval dynamically (1min–1hr), may use Monitor tool |
| `/loop` | Runs built-in maintenance prompt or project/user `loop.md` |
| `/loop 20m /review-pr 1234` | Re-run a packaged command |

- Units: `s`, `m`, `h`, `d`. Rounded to cron granularity.
- One-time reminders: natural language, e.g., "remind me at 3pm to push the release branch".
- Underlying tools: `CronCreate`, `CronList`, `CronDelete` (50 task limit; 8-char IDs).
- Jitter: recurring tasks up to 10% late (capped 15 min); `:00`/`:30` one-shots up to 90s early.
- Recurring tasks auto-expire after 7 days.
- `loop.md` default prompt: `.claude/loop.md` (project) > `~/.claude/loop.md` (user); max 25,000 bytes.
- Disable: `CLAUDE_CODE_DISABLE_CRON=1`.
- **Cloud tasks**: created via web, Desktop app, or `/schedule` CLI. Run in cloud environments with network/env-vars/setup-script config, pushes only to `claude/`-prefixed branches unless unrestricted is enabled. Frequencies: Hourly, Daily, Weekdays, Weekly.
- **Desktop tasks**: local or remote, appears in same grid. Fields: Name, Description, Prompt (with model/permission/worktree controls), Frequency. Manual/Hourly/Daily/Weekdays/Weekly. Optional per-run git worktree.

### Voice dictation

- Enable with `/voice` (requires v2.1.69+, claude.ai login — not API key/Bedrock/Vertex/Foundry).
- Default push-to-talk: hold `Space`. Rebind `voice:pushToTalk` (in `Chat` context) in `~/.claude/keybindings.json` — modifier combos like `meta+k` start recording on first keypress with no warmup.
- Persist with `"voiceEnabled": true`. Streams audio to Anthropic for transcription (not processed locally).
- Language follows `"language"` setting (BCP 47 code or name). Supported: cs, da, nl, en, fr, de, el, hi, id, it, ja, ko, no, pl, pt, ru, es, sv, tr, uk. Falls back to English.
- Transcription tuned for code vocabulary; project + git branch added as recognition hints.
- On Linux falls back to `arecord`/`rec` if native module fails.

### Channels — push events into a session

An MCP server that pushes `<channel>` events into a running session so Claude reacts to external activity (CI, chat, webhooks). Requires v2.1.80+, claude.ai login; research preview.

Enable per-session: `claude --channels plugin:<name>@<marketplace>` (space-separated list).

Supported preview plugins: **telegram**, **discord**, **imessage**, **fakechat** (localhost demo). Each installs via `/plugin install <name>@claude-plugins-official`.

| Plugin | Notes |
| --- | --- |
| Telegram | BotFather token → `/telegram:configure <token>` → pair via bot DM → `/telegram:access pair <code>` → `/telegram:access policy allowlist` |
| Discord | Bot token with Message Content Intent and required permissions → `/discord:configure` → `/discord:access pair` → allowlist |
| iMessage | macOS only; Full Disk Access to `~/Library/Messages/chat.db`; self-chat bypasses allowlist; add contacts with `/imessage:access allow <handle>` |
| fakechat | No auth; UI at `http://localhost:8787` |

Enterprise managed settings: `channelsEnabled: true` (master switch), `allowedChannelPlugins: [{marketplace, plugin}, ...]` (replaces Anthropic allowlist).

Security: per-plugin sender allowlist (pairing for Telegram/Discord; handle allow for iMessage); channel must be in `--channels` (being in `.mcp.json` alone is insufficient). Allowlist also gates [permission relay](references/claude-code-channels-reference.md#relay-permission-prompts) for remote tool approvals. For unattended runs without prompts, `--dangerously-skip-permissions`.

**Building a channel** (channels reference): an MCP server over stdio that (1) declares `experimental: { 'claude/channel': {} }` capability, (2) emits `notifications/claude/channel` events with `{content, meta}` — each `meta` key becomes a `<channel>` tag attribute, (3) optionally exposes a reply tool for two-way channels. Test custom channels with `--dangerously-load-development-channels`.

### Context window

`/en/context-window` is an interactive simulator showing what loads: system prompt, auto memory, environment info, MCP tool names (deferred, `ENABLE_TOOL_SEARCH=auto|false`), skill descriptions (not re-injected after `/compact`), `~/.claude/CLAUDE.md`, project CLAUDE.md, file reads, rules, hooks. Default max 200k tokens.

### Fullscreen rendering

Flicker-free alternate-screen rendering with mouse support and flat memory. Opt-in research preview (v2.1.89+).

- Enable: `CLAUDE_CODE_NO_FLICKER=1`. Export in shell profile to persist.
- Input box stays fixed at bottom; only visible messages kept in render tree.
- Mouse: click to position cursor, click collapsed tool results to expand, click URLs/file paths to open, click-and-drag to select (auto-copies on release; toggle Copy on select in `/config`; `Ctrl+Shift+c` manual).
- Scroll: `PgUp`/`PgDn` (half screen), `Ctrl+Home`/`Ctrl+End` (jump), mouse wheel. `CLAUDE_CODE_SCROLL_SPEED=N` (1–20).
- `Ctrl+o` cycles: prompt → transcript mode → focus view → prompt. Transcript mode gets less-style nav (`/`, `n`/`N`, `j`/`k`, `g`/`G`, `Ctrl+u`/`d`, `[` = dump into terminal scrollback, `v` = open in `$VISUAL`/`$EDITOR`, `Esc`/`q` exit).
- tmux: requires `set -g mouse on`. Incompatible with `tmux -CC` integration mode.
- Keep native selection: `CLAUDE_CODE_DISABLE_MOUSE=1` (retains flat memory, loses click-to-expand/URL/wheel).
- Disable: unset the env var or set to `0`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code (features overview)](references/claude-code-features-overview.md) — when to use CLAUDE.md/skills/subagents/MCP/hooks/plugins, with context cost table
- [Fast mode](references/claude-code-fast-mode.md) — `/fast` for high-speed Opus 4.6, pricing, admin controls, rate limits
- [Model configuration](references/claude-code-model-config.md) — aliases, `availableModels`, `modelOverrides`, effort levels, 1M context, pinning, prompt caching
- [Output styles](references/claude-code-output-styles.md) — built-in Default/Explanatory/Learning, custom style files and frontmatter
- [Status line](references/claude-code-statusline.md) — `statusLine` config, stdin JSON schema, examples and helpers
- [Checkpointing](references/claude-code-checkpointing.md) — `/rewind`, restore vs summarize, limitations
- [Remote Control](references/claude-code-remote-control.md) — `claude remote-control`, `--rc`, `/remote-control`, setup, security, troubleshooting
- [Scheduled tasks (CLI / `/loop`)](references/claude-code-scheduled-tasks.md) — `/loop`, cron tools, `loop.md`, one-shot reminders, jitter, 7-day expiry
- [Cloud scheduled tasks](references/claude-code-web-scheduled-tasks.md) — claude.ai/code/scheduled, repos, environments, connectors, `/schedule`
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) — local vs remote tasks, frequency, worktree toggle
- [Voice dictation](references/claude-code-voice-dictation.md) — `/voice`, push-to-talk, supported languages, rebinding
- [Channels](references/claude-code-channels.md) — push events via Telegram/Discord/iMessage/fakechat, pairing, security, enterprise controls
- [Channels reference](references/claude-code-channels-reference.md) — build your own MCP channel server, notification format, reply tools, sender gating, permission relay
- [Explore the context window](references/claude-code-context-window.md) — interactive simulation of what loads into context
- [Fullscreen rendering](references/claude-code-fullscreen.md) — `CLAUDE_CODE_NO_FLICKER`, mouse, scroll, transcript mode, tmux

## Sources

- Extend Claude Code: https://code.claude.com/docs/en/features-overview.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks (CLI): https://code.claude.com/docs/en/scheduled-tasks.md
- Web scheduled tasks: https://code.claude.com/docs/en/web-scheduled-tasks.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Context window: https://code.claude.com/docs/en/context-window.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
