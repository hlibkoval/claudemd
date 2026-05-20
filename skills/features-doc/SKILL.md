---
name: features-doc
user-invocable: false
---

# Claude Code Features Documentation

This skill provides the complete official documentation for Claude Code features: the extension model overview, parallel agents, agent view, channels, checkpointing, context window, deep links, desktop scheduled tasks, fast mode, fullscreen rendering, model configuration, output styles, prompt caching, remote control, routines, session-scoped scheduling, status line, voice dictation, and worktrees.

## Quick Reference

### Extension model: match features to your goal

| Feature | What it does | When to use it |
| :--- | :--- | :--- |
| **CLAUDE.md** | Persistent context every session | "Always do X" rules, conventions |
| **Skill** | Instructions and workflows Claude uses | Reference docs, repeatable tasks |
| **Subagent** | Isolated worker, returns summary | Context isolation, parallel tasks |
| **Agent teams** | Multiple sessions with shared task list | Parallel research, competing hypotheses |
| **Code intelligence** | LSP navigation and diagnostics | Typed languages, large codebases |
| **MCP** | Connect to external services | External data or actions |
| **Hook** | Script/prompt/subagent on lifecycle event | Automation that must fire every time |
| **Plugin** | Bundle and distribute features | Reuse setup across repos |

### Context cost by feature

| Feature | When it loads | Context cost |
| :--- | :--- | :--- |
| CLAUDE.md | Session start | Full content every request |
| Skills | Session start + when used | Low (descriptions at start) |
| MCP servers | Session start | Low until tool is used |
| Subagents | When spawned | Isolated from main session |
| Hooks | On trigger | Zero unless hook returns output |

### Parallel agents comparison

| Approach | Use it when |
| :--- | :--- |
| **Subagents** | Side task would flood main context with unreferenced output |
| **Agent view** (`claude agents`) | Several independent tasks; check status, step in when needed |
| **Agent teams** | Claude should plan, assign, and supervise workers (experimental) |
| **Worktrees** | Parallel sessions edit overlapping files |
| **`/batch`** | Repo-wide migration you can describe in one instruction |

### Agent view (`claude agents`) — key info

- Requires Claude Code v2.1.139+; research preview
- Sessions grouped as: Needs input / Working / Ready for review / Completed
- Session state icons: animated (Working), yellow (Needs input), green (Completed), red (Failed), grey (Stopped)
- Process state: `✻`/`✽` = alive; `∙` = exited but resumable; `✢` = `/loop` sleeping between iterations
- Each background session moves into an isolated git worktree before editing files
- Disable with `disableAgentView: true` or `CLAUDE_CODE_DISABLE_AGENT_VIEW`

| Shortcut | Action |
| :--- | :--- |
| `Space` | Open/close peek panel |
| `Enter` / `→` | Attach to session |
| `←` (empty prompt) | Detach and return to agent view |
| `Ctrl+X` (×2 within 2s) | Stop then delete session |
| `Ctrl+T` | Pin session |
| `Ctrl+R` | Rename session |
| `Ctrl+S` | Toggle grouping (state / directory) |
| `?` | Show all shortcuts |

### Channels (push events into a session)

- Requires Claude Code v2.1.80+; research preview; not available on Bedrock/Vertex/Foundry
- Enable per session: `claude --channels plugin:<name>@<marketplace>`
- Supported plugins: `telegram`, `discord`, `imessage`, `fakechat` (demo) from `claude-plugins-official`
- MCP server declares `capabilities.experimental['claude/channel']` to register as a channel
- Events arrive as `<channel source="…" …>body</channel>` tags in Claude's context
- Two-way channels expose a reply MCP tool; permission relay requires `claude/channel/permission` capability
- Enterprise: `channelsEnabled` (master switch) and `allowedChannelPlugins` in managed settings

| Setting | Default (Team/Enterprise) |
| :--- | :--- |
| `channelsEnabled` | Blocked until admin enables |
| `allowedChannelPlugins` | Anthropic-maintained allowlist |

### Checkpointing and rewind

- Every user prompt creates a checkpoint automatically
- Checkpoints persist across sessions; cleaned up after 30 days
- `Esc`+`Esc` or `/rewind` opens the rewind menu
- Rewind actions: Restore code+conversation | Restore conversation | Restore code | Summarize from here | Summarize up to here
- **Not tracked**: file changes from Bash commands, external edits from other sessions
- Not a replacement for git — think "local undo" vs "permanent history"

### Context window — what survives `/compact`

| Mechanism | After compaction |
| :--- | :--- |
| System prompt and output style | Unchanged |
| Project-root CLAUDE.md and unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | Lost until matching file is read again |
| Nested CLAUDE.md in subdirectories | Lost until file in that subdirectory is read again |
| Invoked skill bodies | Re-injected, capped at 5K tokens/skill, 25K total |
| Hooks | Not applicable (run as code, not context) |

### Deep links (`claude-cli://`)

- Requires Claude Code v2.1.91+
- Format: `claude-cli://open?q=<url-encoded-prompt>&cwd=<abs-path>` or `&repo=<owner/name>`
- `cwd` takes precedence over `repo` when both are provided
- `q` max 5,000 characters; `repo` resolves to last-used local clone
- Prompt is pre-filled but NOT sent until user presses Enter
- GitHub-rendered Markdown strips `claude-cli://` links — use code blocks as workaround
- VS Code uses `vscode://anthropic.claude-code/open` instead

| Platform | Handler location |
| :--- | :--- |
| macOS | `~/Applications/Claude Code URL Handler.app` |
| Linux | `~/.local/share/applications/claude-code-url-handler.desktop` |
| Windows | `HKEY_CURRENT_USER\Software\Classes\claude-cli` |

### Scheduling options comparison

| | Cloud (Routines) | Desktop tasks | `/loop` |
| :--- | :--- | :--- | :--- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Access to local files | No (fresh clone) | Yes | Yes |
| Minimum interval | 1 hour | 1 minute | 1 minute |

### Desktop scheduled tasks (local)

- Create via Routines sidebar → New routine → Local
- Fires only while Desktop app is open and machine is awake
- Missed runs: one catch-up run on wake for runs missed in last 7 days
- On-disk config: `~/.claude/scheduled-tasks/<task-name>/SKILL.md`
- Enable "Keep computer awake" in Settings to prevent sleep-skipped runs

### Routines (cloud, `claude.ai/code/routines`)

- Trigger types: **Schedule** (recurring or one-off), **API** (HTTP POST with bearer token), **GitHub** (PR or release events)
- Runs autonomously — no permission prompts during a run
- Branches created by routine are prefixed `claude/` by default
- `/schedule` in CLI creates scheduled routines; API/GitHub triggers require web UI
- GitHub triggers require Claude GitHub App installed on the repo
- One-off runs do NOT count against the daily routine run cap

### `/loop` session-scoped scheduling

- `/loop 5m <prompt>` — fixed interval
- `/loop <prompt>` — Claude picks interval dynamically
- `/loop` — built-in maintenance prompt (continue work, tend PR, cleanup)
- `.claude/loop.md` or `~/.claude/loop.md` replaces built-in default prompt
- Tasks expire after 7 days; `Esc` stops a waiting loop
- Disable: `CLAUDE_CODE_DISABLE_CRON=1`

### Fast mode

- Requires Claude Code v2.1.36+; research preview
- `/fast` to toggle; `fastMode: true` in user settings to persist
- 2.5× faster Opus at higher cost; only available on Opus 4.7 and 4.6
- Pricing: $30/$150 MTok (input/output); flat across full 1M token window
- NOT available on Bedrock, Vertex AI, or Azure Foundry
- Requires usage credits turned on; Team/Enterprise admins must enable it
- Falls back to standard speed on rate limit; `↯` icon goes grey during cooldown
- `fastModePerSessionOptIn: true` in managed settings resets fast mode each session

### Model configuration

| Alias | Resolves to |
| :--- | :--- |
| `default` | Subscription-tier default |
| `best` | Latest Opus |
| `sonnet` | Latest Sonnet |
| `opus` | Latest Opus |
| `haiku` | Latest Haiku |
| `sonnet[1m]` | Sonnet with 1M token context |
| `opus[1m]` | Opus with 1M token context |
| `opusplan` | Opus in plan mode → Sonnet in execution |

**Effort levels** (Opus 4.7): `low`, `medium`, `high`, `xhigh` (default), `max`  
**Effort levels** (Opus 4.6, Sonnet 4.6): `low`, `medium`, `high`, `max`

Set model: `/model <alias>`, `--model`, `ANTHROPIC_MODEL`, or `model` in settings.  
Set effort: `/effort <level>`, `--effort`, `CLAUDE_CODE_EFFORT_LEVEL`, or `effortLevel` in settings.

Include `ultrathink` in your prompt for deeper one-off reasoning without changing the effort setting.

**Extended context (1M tokens)**:
- Max/Team/Enterprise: Opus included; Sonnet requires usage credits
- Pro: both require usage credits
- Disable: `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`

### Output styles

| Style | Behavior |
| :--- | :--- |
| Default | Standard software engineering mode |
| Proactive | Execute immediately, assume rather than pause |
| Explanatory | Adds "Insights" between task steps |
| Learning | Adds "Insights" + `TODO(human)` markers for user contribution |
| Custom | Your Markdown file in `~/.claude/output-styles/` or `.claude/output-styles/` |

Custom style frontmatter: `name`, `description`, `keep-coding-instructions` (bool), `force-for-plugin` (bool).  
Change via `/config → Output style`; takes effect after `/clear` or new session.

### Prompt caching — cache-invalidating actions

| Action | Effect |
| :--- | :--- |
| Switch model (`/model`) | Entire cache invalidated (keyed by model) |
| Connect/disconnect MCP server | System prompt layer invalidated |
| Add bare tool deny rule (`Bash`, `WebFetch`) | System prompt layer invalidated |
| `/compact` | Conversation layer replaced with summary |
| Upgrade Claude Code | System prompt updated on restart |

**Cache TTL**: 5 min by default; 1 hour on Claude subscriptions (not on usage credits). Force 5 min: `FORCE_PROMPT_CACHING_5M=1`. Force 1 hour: `ENABLE_PROMPT_CACHING_1H=1`.  
Disable caching: `DISABLE_PROMPT_CACHING=1` (or per-model variants `_HAIKU`, `_SONNET`, `_OPUS`).

### Remote Control

- Requires Claude Code v2.1.51+; research preview; Pro/Max/Team/Enterprise only (not API keys)
- Start: `claude remote-control` (server mode), `claude --remote-control`, or `/remote-control` in session
- Connect: session URL, QR code, or `claude.ai/code` session list
- Session runs locally; web/mobile is a window into your local session
- `--spawn worktree` gives each remote connection its own git worktree
- Push notifications: requires Claude app + `/config → Push when Claude decides`
- Team/Enterprise: admin must enable via Remote Control toggle in Claude Code admin settings
- Disable with `disableRemoteControl` in managed settings

### Fullscreen rendering

- Requires Claude Code v2.1.89+; opt-in research preview
- Enable: `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1`
- Disable mouse capture: `CLAUDE_CODE_DISABLE_MOUSE=1`
- Classic renderer: `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1`

| Shortcut | Action |
| :--- | :--- |
| `Ctrl+O` | Toggle transcript mode |
| `PgUp` / `PgDn` | Scroll up/down |
| `Ctrl+Home` / `Ctrl+End` | Jump to start/bottom |
| `[` (in transcript mode) | Write conversation to native scrollback |
| `v` (in transcript mode) | Open in `$EDITOR` |
| `/focus` | Condensed view (last prompt + summaries + response) |

### Status line configuration

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

Key JSON fields available in stdin:

| Field | Description |
| :--- | :--- |
| `model.display_name` | Current model |
| `workspace.current_dir` | Working directory |
| `context_window.used_percentage` | % of context used |
| `context_window.current_usage` | Per-component token counts (input, output, cache) |
| `cost.total_cost_usd` | Estimated session cost |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit usage (Pro/Max) |
| `rate_limits.seven_day.used_percentage` | 7-day rate limit usage (Pro/Max) |
| `pr.number`, `pr.url`, `pr.review_state` | Open PR for current branch |
| `effort.level` | Current effort level |
| `vim.mode` | Vim mode (when vim mode is enabled) |

Use `/statusline <description>` to have Claude generate a script automatically.

### Voice dictation

- Requires Claude Code v2.1.69+; requires claude.ai account (not API key/Bedrock/Vertex)
- Enable: `/voice` (hold mode default), `/voice tap` (tap-to-record-and-send), `/voice off`
- Persist in settings: `{"voice": {"enabled": true, "mode": "tap"}}`
- Default key: `Space`; rebind via `voice:pushToTalk` in `~/.claude/keybindings.json`
- Language: follows `language` setting; defaults to English
- Hold mode: hold key → speak → release to insert; `autoSubmit: true` to auto-send
- Tap mode: tap → speak → tap again → auto-submits if ≥3 words
- Not available in remote environments or SSH sessions

### Worktrees

- `claude --worktree <name>` creates `.claude/worktrees/<name>/` on branch `worktree-<name>`
- Branch from: `origin/HEAD` (default) or local `HEAD` (`worktree.baseRef: "head"` in settings)
- Branch from PR: `claude --worktree "#1234"` or full PR URL
- `.worktreeinclude` — `.gitignore`-syntax file listing gitignored files to copy into worktrees
- `isolation: worktree` in subagent frontmatter runs each subagent in its own worktree
- Clean up: `git worktree remove <path>`; add `.claude/worktrees/` to `.gitignore`
- Non-git VCS: configure `WorktreeCreate`/`WorktreeRemove` hooks

| Setting | Value | Effect |
| :--- | :--- | :--- |
| `worktree.baseRef` | `"fresh"` (default) or `"head"` | Branch from remote or local HEAD |
| `worktree.bgIsolation` | `"none"` | Disable auto-worktree for background sessions |

## Full Documentation

For the complete official documentation, see the reference files:

- [Features Overview](references/claude-code-features-overview.md) — extension model: CLAUDE.md, skills, subagents, agent teams, MCP, hooks, plugins; feature comparison tables and layering rules
- [Run Agents in Parallel](references/claude-code-agents.md) — compare subagents, agent view, agent teams, worktrees, and `/batch`; when to use each
- [Agent View](references/claude-code-agent-view.md) — `claude agents` UI: dispatching, monitoring, peeking, keyboard shortcuts, worktree isolation, supervisor process
- [Channels](references/claude-code-channels.md) — install and use Telegram, Discord, iMessage, fakechat; security, enterprise controls
- [Channels Reference](references/claude-code-channels-reference.md) — build a custom channel MCP server; notification format, reply tools, sender gating, permission relay
- [Checkpointing](references/claude-code-checkpointing.md) — automatic checkpoint tracking, rewind menu, summarize options, limitations
- [Context Window](references/claude-code-context-window.md) — interactive timeline of what loads into context and when; what survives compaction
- [Deep Links](references/claude-code-deep-links.md) — `claude-cli://` URL scheme; parameters, platform registration, troubleshooting
- [Desktop Scheduled Tasks](references/claude-code-desktop-scheduled-tasks.md) — local scheduled tasks in Claude Code Desktop; schedule options, permissions, missed runs
- [Fast Mode](references/claude-code-fast-mode.md) — 2.5× faster Opus; pricing, toggle, rate limit fallback, org controls
- [Fullscreen Rendering](references/claude-code-fullscreen.md) — flicker-free alternate screen; mouse support, transcript mode, tmux usage
- [Model Configuration](references/claude-code-model-config.md) — model aliases, effort levels, extended context, thinking, third-party pinning, `modelOverrides`
- [Output Styles](references/claude-code-output-styles.md) — built-in styles, custom style files, frontmatter, system prompt effects
- [Prompt Caching](references/claude-code-prompt-caching.md) — cache structure, invalidating actions, TTL, cache scope, checking performance
- [Remote Control](references/claude-code-remote-control.md) — `claude remote-control`; connect from phone/browser, server mode, push notifications, security
- [Routines](references/claude-code-routines.md) — cloud scheduled tasks; schedule/API/GitHub triggers, connectors, environments, usage limits
- [Scheduled Tasks (`/loop`)](references/claude-code-scheduled-tasks.md) — session-scoped scheduling; fixed interval, dynamic interval, one-time reminders, `loop.md`
- [Status Line](references/claude-code-statusline.md) — custom shell script status bar; JSON input fields, examples in Bash/Python/Node.js
- [Voice Dictation](references/claude-code-voice-dictation.md) — hold-to-record and tap-to-record; language, keybinding, troubleshooting
- [Worktrees](references/claude-code-worktrees.md) — `--worktree` flag, `.worktreeinclude`, subagent isolation, cleanup, non-git VCS hooks

## Sources

- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Run Agents in Parallel: https://code.claude.com/docs/en/agents.md
- Agent View: https://code.claude.com/docs/en/agent-view.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels Reference: https://code.claude.com/docs/en/channels-reference.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Context Window: https://code.claude.com/docs/en/context-window.md
- Deep Links: https://code.claude.com/docs/en/deep-links.md
- Desktop Scheduled Tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Fullscreen Rendering: https://code.claude.com/docs/en/fullscreen.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Prompt Caching: https://code.claude.com/docs/en/prompt-caching.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Routines: https://code.claude.com/docs/en/routines.md
- Scheduled Tasks (`/loop`): https://code.claude.com/docs/en/scheduled-tasks.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Voice Dictation: https://code.claude.com/docs/en/voice-dictation.md
- Worktrees: https://code.claude.com/docs/en/worktrees.md
