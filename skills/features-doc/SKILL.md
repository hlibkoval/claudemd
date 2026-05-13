---
name: features-doc
description: Complete official documentation for Claude Code features — features overview (when to use CLAUDE.md vs skills vs subagents vs MCP vs hooks), fast mode, model configuration and aliases, effort levels, output styles, status line, checkpointing and rewind, remote control, scheduled tasks (/loop, desktop, routines), voice dictation, channels (Telegram/Discord/iMessage), channels reference (building MCP channel servers), context window visualization, fullscreen rendering, deep links, agent view, parallel agents, and worktrees.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features.

## Quick Reference

### Feature Selection Guide

| Feature | What it does | When to use it |
| :--- | :--- | :--- |
| **CLAUDE.md** | Persistent context loaded every session | Project conventions, "always do X" rules |
| **Skills** | Instructions, knowledge, and workflows Claude can use | Reusable content, reference docs, repeatable tasks |
| **Subagents** | Isolated execution context returning summarized results | Context isolation, parallel tasks, specialized workers |
| **Agent teams** | Coordinate multiple independent Claude Code sessions | Parallel research, competing hypotheses, new feature development |
| **MCP** | Connect to external services | External data or actions (database, Slack, browser) |
| **Hooks** | Script/HTTP/prompt/subagent triggered by lifecycle events | Automation that must run on every matching event |
| **Plugins** | Bundle skills, hooks, MCP servers into one installable unit | Reuse across repos or distribute to others |

### Context Cost by Feature

| Feature | When it loads | Context cost |
| :--- | :--- | :--- |
| **CLAUDE.md** | Session start | Every request |
| **Skills** | Descriptions at start, full content when used | Low until used; zero for `disable-model-invocation: true` |
| **MCP servers** | Tool names at start, schemas on demand | Low until tool is used |
| **Subagents** | When spawned | Isolated from main session |
| **Hooks** | On trigger | Zero unless hook returns output |

### What Survives Compaction

| Mechanism | After compaction |
| :--- | :--- |
| System prompt and output style | Unchanged |
| Project-root CLAUDE.md and unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | Lost until matching file is read again |
| Nested CLAUDE.md in subdirectories | Lost until file in subdirectory is read again |
| Invoked skill bodies | Re-injected, capped at 5,000 tokens/skill, 25,000 tokens total |

---

### Fast Mode

Toggle fast mode with `/fast` or set `"fastMode": true` in user settings.

| Setting | Value |
| :--- | :--- |
| Speed improvement | 2.5x faster |
| Pricing | $30/$150 MTok (input/output) |
| Default model | Opus 4.6 (Opus 4.7 via `CLAUDE_CODE_ENABLE_OPUS_4_7_FAST_MODE=1`) |
| Opus 4.7 becomes default | May 14, 2026 |
| Requires | Claude Code v2.1.36+; extra usage enabled; not on Bedrock/Vertex/Foundry |
| Icon when active | `↯` in prompt |
| Rate limit fallback | Auto-falls back to standard speed; icon turns gray |

Per-session opt-in (Team/Enterprise): set `"fastModePerSessionOptIn": true` in managed settings.

Disable entirely: set `CLAUDE_CODE_DISABLE_FAST_MODE=1`.

---

### Model Configuration

**Model aliases:**

| Alias | Resolves to |
| :--- | :--- |
| `default` | Clears any override; uses recommended model for account type |
| `best` | Most capable available (currently equivalent to `opus`) |
| `sonnet` | Latest Sonnet for daily coding |
| `opus` | Latest Opus for complex reasoning |
| `haiku` | Fast, efficient model for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context |
| `opus[1m]` | Opus with 1M token context |
| `opusplan` | Opus for plan mode, Sonnet for execution |

**Default model by account type:**
- Max and Team Premium: Opus 4.7
- Pro, Team Standard, Enterprise, Anthropic API: Sonnet 4.6
- Bedrock, Vertex, Foundry: Sonnet 4.5

**Setting model (priority order):**
1. `/model <alias>` during session
2. `claude --model <alias>` at startup
3. `ANTHROPIC_MODEL=<alias>` env var
4. `"model"` field in settings file

**Effort levels** (Opus 4.7, Opus 4.6, Sonnet 4.6):

| Level | When to use |
| :--- | :--- |
| `low` | Latency-sensitive, not intelligence-sensitive |
| `medium` | Cost-sensitive, can trade some intelligence |
| `high` | Balance of tokens and intelligence |
| `xhigh` | Best for most coding/agentic tasks (default on Opus 4.7) |
| `max` | Deepest reasoning; session-only unless set via `CLAUDE_CODE_EFFORT_LEVEL` |

Set effort: `/effort <level>`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL` env var, or `effortLevel` in settings. Use `ultrathink` anywhere in a prompt for one-off deep reasoning without changing session effort.

**1M context availability:**
- Max, Team, Enterprise: Opus included; Sonnet requires extra usage
- Pro: both require extra usage
- API and pay-as-you-go: full access

Disable 1M context: `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

**Env vars for model alias overrides:**

| Variable | Controls |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model used for `opus` alias |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model used for `sonnet` alias |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model used for `haiku` alias |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model used for subagents |

---

### Output Styles

Configure with `/config` → Output style, or set `"outputStyle"` in settings.

| Style | Behavior |
| :--- | :--- |
| **Default** | Standard software engineering assistant |
| **Proactive** | Executes immediately, makes assumptions, prefers action |
| **Explanatory** | Adds educational "Insights" while helping |
| **Learning** | Collaborative; adds `TODO(human)` markers for you to implement |

Custom styles: Markdown files with frontmatter in `~/.claude/output-styles/` (user), `.claude/output-styles/` (project), or plugin `output-styles/` directory.

Custom style frontmatter fields:

| Field | Description | Default |
| :--- | :--- | :--- |
| `name` | Style name | File name |
| `description` | Shown in `/config` picker | None |
| `keep-coding-instructions` | Preserve coding parts of system prompt | `false` |
| `force-for-plugin` | Auto-apply when plugin is enabled | `false` |

---

### Status Line

Configure in `~/.claude/settings.json`:

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

Use `/statusline <description>` to auto-generate a script.

**Available JSON data fields (sent to your script via stdin):**

| Field | Description |
| :--- | :--- |
| `model.id`, `model.display_name` | Current model |
| `workspace.current_dir`, `workspace.project_dir` | Directories |
| `context_window.used_percentage`, `context_window.remaining_percentage` | Context usage |
| `context_window.context_window_size` | Max size (200000 or 1000000) |
| `cost.total_cost_usd`, `cost.total_duration_ms` | Session cost and duration |
| `effort.level` | Current effort level |
| `rate_limits.five_hour.used_percentage`, `rate_limits.seven_day.used_percentage` | Rate limit usage (Pro/Max only) |
| `session_id`, `session_name` | Session identifiers |
| `vim.mode` | Vim mode state (when enabled) |
| `worktree.name`, `worktree.branch`, `worktree.path` | Worktree info (in `--worktree` sessions) |

Updates fire after each assistant message, after `/compact`, on permission mode change, on vim mode toggle. Debounced at 300ms. Use `refreshInterval` for time-based data.

---

### Checkpointing

Checkpoints capture file state before each user prompt automatically.

**Rewind menu:** Press `Esc` twice or run `/rewind`.

| Action | What it does |
| :--- | :--- |
| Restore code and conversation | Revert both to selected point |
| Restore conversation | Rewind messages, keep current code |
| Restore code | Revert files, keep conversation |
| Summarize from here | Compress conversation from this point forward; frees context |
| Never mind | Return without changes |

- Checkpoints persist across sessions (30-day cleanup)
- Bash command side effects (rm, mv, cp) are NOT tracked
- External changes and other sessions' edits are NOT tracked
- Use Git for permanent history; checkpoints are for quick session-level undo

---

### Remote Control

Connect claude.ai/code or the Claude mobile app to a local CLI session. Requires claude.ai subscription (not API keys).

**Start modes:**

| Command | Behavior |
| :--- | :--- |
| `claude remote-control` | Server mode: runs in terminal, waits for connections |
| `claude --remote-control` | Interactive session with remote control enabled |
| `/remote-control` | Enable in existing session |

**Server mode flags:**

| Flag | Description |
| :--- | :--- |
| `--name "title"` | Custom session title |
| `--spawn same-dir\|worktree\|session` | How server creates sessions |
| `--capacity <N>` | Max concurrent sessions (default 32) |
| `--sandbox` / `--no-sandbox` | Enable/disable sandboxing |

**Connect:** Open session URL, scan QR code (press spacebar in server mode), or find in claude.ai/code session list.

Enable for all sessions: `/config` → Enable Remote Control for all sessions.

**Push notifications:** Requires Claude Code v2.1.110+. Enable in `/config` → Push when Claude decides. Install Claude mobile app and sign in with same account.

Remote Control vs Claude Code on the web: Remote Control executes on your machine (local files, MCP, tools available); web runs on Anthropic cloud.

---

### Scheduled Tasks

Three scheduling options compared:

| | Cloud (Routines) | Desktop | `/loop` |
| :--- | :--- | :--- | :--- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Persistent | Yes | Yes | Restored on `--resume` if unexpired |
| Min interval | 1 hour | 1 minute | 1 minute |

**`/loop` usage:**

| Input | Behavior |
| :--- | :--- |
| `/loop 5m check the deploy` | Fixed interval with your prompt |
| `/loop check the deploy` | Claude chooses interval dynamically |
| `/loop` | Built-in maintenance prompt (continue work, tend PR, cleanup) |

Stop a `/loop`: press `Esc`. Session-scoped; tasks expire after 7 days. Disable: `CLAUDE_CODE_DISABLE_CRON=1`.

Customize default prompt: create `.claude/loop.md` (project) or `~/.claude/loop.md` (user). Content beyond 25,000 bytes is truncated.

**Cron expression reference:**

| Example | Meaning |
| :--- | :--- |
| `*/5 * * * *` | Every 5 minutes |
| `0 9 * * *` | Daily at 9am local |
| `0 9 * * 1-5` | Weekdays at 9am |

**Desktop scheduled tasks:** Created via Routines sidebar in Desktop app, or by describing in a session. Local tasks run with full file access but only while the app is open. Catch-up: one missed run fires on wake.

**Routines (cloud):** Created at claude.ai/code/routines or via `/schedule` CLI. Triggers: Schedule (min 1 hour), API (HTTP POST with bearer token), GitHub (pull_request or release events). Results appear as sessions on claude.ai/code.

---

### Voice Dictation

Enable: `/voice` (hold mode), `/voice tap` (tap mode), `/voice off` to disable.

| Mode | Behavior |
| :--- | :--- |
| Hold | Hold Space to record; releases finalize transcript |
| Tap | Tap Space to start, tap again to send (auto-submits when 3+ words) |

Requires: Claude.ai account (not API key), local microphone. Not available in remote environments or VS Code Remote.

`autoSubmit: true` in settings auto-submits on key release in hold mode.

Language: uses `language` setting; defaults to English. Supports 20 languages (cs, da, nl, en, fr, de, el, hi, id, it, ja, ko, no, pl, pt, ru, es, sv, tr, uk).

Rebind key: set `voice:pushToTalk` in `~/.claude/keybindings.json` (Chat context).

---

### Channels

Push events from external services into a running session. Requires Claude Code v2.1.80+, claude.ai account or Console API key. Not available on Bedrock/Vertex/Foundry.

Enable for session: `claude --channels plugin:<name>@<marketplace>`

**Supported channels:** Telegram, Discord, iMessage (via official plugins; require Bun).

Security: each channel maintains a sender allowlist; pair by sending a message to your bot and running `/<channel>:access pair <code>`.

**Building a custom channel (MCP server):**

Required capability: `capabilities.experimental['claude/channel']: {}`
Event method: `notifications/claude/channel` with `content` (string) and optional `meta` (key-value attributes).
Two-way: add `capabilities.tools: {}` and expose a reply tool.
Permission relay: add `capabilities.experimental['claude/channel/permission']: {}` to forward tool approval prompts; send back `notifications/claude/channel/permission` with `request_id` and `behavior: 'allow'|'deny'`.

Test custom channels: `claude --dangerously-load-development-channels server:<name>`.

Enterprise controls: `channelsEnabled` (master switch) and `allowedChannelPlugins` in managed settings.

---

### Fullscreen Rendering

Flicker-free alternative renderer using terminal alternate screen buffer.

Enable: `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1`. Disable: `/tui default`.

**What changes:**
- Input box stays fixed at the bottom
- Mouse support: click to expand tool results, click URLs/paths to open, click-and-drag to select, scroll with mouse wheel
- Conversation lives in alternate screen (not native scrollback)
- To search: `Ctrl+o` for transcript mode, then `/` to search or `[` to write to native scrollback

**Scroll shortcuts:**

| Shortcut | Action |
| :--- | :--- |
| `PgUp` / `PgDn` | Scroll half screen |
| `Ctrl+Home` | Jump to start |
| `Ctrl+End` | Jump to end, resume auto-follow |
| Mouse wheel | Scroll a few lines |

Adjust scroll speed: `/scroll-speed` or `CLAUDE_CODE_SCROLL_SPEED=3`.

Disable mouse capture only: `CLAUDE_CODE_DISABLE_MOUSE=1`.

Transcript mode (`Ctrl+o`): less-style navigation with `/` search, `[` to write to scrollback, `v` to open in `$EDITOR`.

---

### Deep Links

`claude-cli://` URLs that open a local Claude Code session with a pre-filled prompt.

**URL format:**
```
claude-cli://open?repo=owner/name&q=URL-encoded+prompt
```

Parameters:

| Parameter | Description |
| :--- | :--- |
| `q` | Prompt text (URL-encoded; max 5,000 characters) |
| `cwd` | Absolute working directory path |
| `repo` | GitHub `owner/name` slug (resolves to most-recently-used local clone) |

`cwd` takes precedence over `repo` when both are provided.

Registered automatically on first interactive `claude` session. Registration locations:
- macOS: `~/Applications/Claude Code URL Handler.app`
- Linux: `~/.local/share/applications/claude-code-url-handler.desktop`
- Windows: `HKEY_CURRENT_USER\Software\Classes\claude-cli`

Disable registration: `"disableDeepLinkRegistration": "disable"` in settings.

Note: GitHub-rendered Markdown strips `claude-cli://` links. Use code blocks as a workaround.

VS Code tab variant: `vscode://anthropic.claude-code/open`

---

### Agent View

One screen for all background sessions. Open with `claude agents`.

**Session states:**

| State | Icon | Meaning |
| :--- | :--- | :--- |
| Working | Animated | Claude is actively running tools |
| Needs input | Yellow | Waiting on question or permission |
| Idle | Dimmed | Ready for next prompt |
| Completed | Green | Task finished successfully |
| Failed | Red | Task ended with error |
| Stopped | Grey | Stopped with `Ctrl+X` or `claude stop` |

**Key keyboard shortcuts:**

| Shortcut | Action |
| :--- | :--- |
| `Space` | Open/close peek panel |
| `Enter` | Attach to session (or dispatch if text in input) |
| `←` | Detach and return to agent view |
| `Ctrl+X` | Stop session; again within 2s to delete |
| `Ctrl+R` | Rename session |
| `Ctrl+T` | Pin/unpin session |
| `?` | Show all shortcuts |

**Dispatch:** Type prompt in bottom input + `Enter`. Starts new background session.

Every background session is automatically moved to an isolated git worktree before editing files.

Start from shell: `claude --bg "<prompt>"`. Attach: `claude attach <id>`. Stop: `claude stop <id>`.

Background an existing session: `/bg` or press `←` on empty prompt.

Supervisor process: runs separately from your terminal; sessions persist after closing agent view.

Disable: `"disableAgentView": true` in settings or `CLAUDE_CODE_DISABLE_AGENT_VIEW`.

Requires Claude Code v2.1.139+.

---

### Parallel Agents Comparison

| Approach | What it gives you | Use when |
| :--- | :--- | :--- |
| **Subagents** | Delegated workers inside one session; return summary | Side task would flood main conversation |
| **Agent view** | Dispatch and monitor background sessions (`claude agents`) | Several independent tasks; check back later |
| **Agent teams** | Multi-session coordination with shared task list (experimental) | Claude-managed workers that need to collaborate |
| **Worktrees** | Separate git checkouts so parallel sessions don't collide | Running several sessions editing overlapping files |
| **`/batch`** | One large change split into 5–30 worktree-isolated subagents | Repo-wide migration or mechanical refactor |

---

### Worktrees

Start Claude in an isolated git worktree:

```bash
claude --worktree feature-auth
claude --worktree "#1234"   # from PR number
claude --worktree            # auto-generated name
```

Default location: `.claude/worktrees/<name>/` on branch `worktree-<name>`.

Base ref: defaults to `origin/HEAD`. Set `"worktree.baseRef": "head"` in settings to branch from local HEAD.

Copy gitignored files into worktrees: add `.worktreeinclude` to project root (uses `.gitignore` syntax).

Cleanup on session exit:
- No changes: worktree and branch removed automatically
- Changes exist: Claude prompts to keep or remove
- Non-interactive (`-p`): no auto-cleanup; use `git worktree remove`

Subagent isolation: set `isolation: worktree` in subagent frontmatter, or ask Claude "use worktrees for your agents".

Non-git VCS: configure `WorktreeCreate` and `WorktreeRemove` hooks to replace default git behavior.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code (features overview)](references/claude-code-features-overview.md) — when to use CLAUDE.md vs skills vs subagents vs MCP vs hooks, feature layering, context costs
- [Fast mode](references/claude-code-fast-mode.md) — toggle, Opus 4.7 opt-in, pricing, rate limits, admin controls
- [Model configuration](references/claude-code-model-config.md) — aliases, effort levels, extended context, extended thinking, env vars, third-party deployments, modelOverrides, prompt caching
- [Output styles](references/claude-code-output-styles.md) — built-in styles, custom style files, frontmatter, comparison with CLAUDE.md and agents
- [Status line](references/claude-code-statusline.md) — setup, available data fields, examples (context bar, git status, cost tracking, multi-line, clickable links, rate limits, caching), subagent status line
- [Checkpointing](references/claude-code-checkpointing.md) — automatic tracking, rewind menu, summarize from here, limitations
- [Remote Control](references/claude-code-remote-control.md) — start modes (server, interactive, existing session, VS Code), mobile push notifications, security, troubleshooting
- [Scheduled tasks (/loop)](references/claude-code-scheduled-tasks.md) — /loop syntax, built-in maintenance prompt, loop.md customization, cron reference, one-time reminders, task management
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) — create in Routines sidebar, schedule options, permissions, missed run behavior, manage tasks
- [Routines (cloud)](references/claude-code-routines.md) — create via web or /schedule CLI, trigger types (schedule/API/GitHub), connectors, environments, usage limits
- [Voice dictation](references/claude-code-voice-dictation.md) — hold vs tap mode, language settings, key rebinding, troubleshooting
- [Channels](references/claude-code-channels.md) — Telegram/Discord/iMessage setup, fakechat quickstart, security/allowlists, enterprise controls
- [Channels reference](references/claude-code-channels-reference.md) — building channel MCP servers, notification format, reply tools, sender gating, permission relay protocol
- [Context window](references/claude-code-context-window.md) — interactive timeline of what loads and when, what survives compaction, checking your session
- [Fullscreen rendering](references/claude-code-fullscreen.md) — enable/disable, mouse support, scrolling, transcript mode/search, tmux caveats
- [Deep links](references/claude-code-deep-links.md) — URL format, cwd vs repo parameters, registration, troubleshooting
- [Agent view](references/claude-code-agent-view.md) — session states, peek/reply, attach/detach, dispatch, keyboard shortcuts, supervisor process
- [Run agents in parallel](references/claude-code-agents.md) — comparison of subagents/agent view/agent teams/worktrees//batch
- [Worktrees](references/claude-code-worktrees.md) — --worktree flag, base branch, .worktreeinclude, subagent isolation, cleanup, non-git VCS

## Sources

- Extend Claude Code (features overview): https://code.claude.com/docs/en/features-overview.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks (/loop): https://code.claude.com/docs/en/scheduled-tasks.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Routines (cloud): https://code.claude.com/docs/en/routines.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Context window: https://code.claude.com/docs/en/context-window.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
- Deep links: https://code.claude.com/docs/en/deep-links.md
- Agent view: https://code.claude.com/docs/en/agent-view.md
- Run agents in parallel: https://code.claude.com/docs/en/agents.md
- Worktrees: https://code.claude.com/docs/en/worktrees.md
