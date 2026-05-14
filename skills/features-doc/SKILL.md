---
name: features-doc
description: Complete official documentation for Claude Code features — features overview, agent view, agents/parallel execution, channels (push events into sessions), channels reference (building custom channels), checkpointing/rewind, context window explorer, deep links, desktop scheduled tasks, fast mode, fullscreen rendering, model configuration, output styles, remote control, routines (cloud automation), scheduled tasks (/loop), status line, voice dictation, and worktrees.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features spanning parallelism, automation, UI, and configuration.

## Quick Reference

### Feature Overview — When to Use What

| Feature | What it does | When to use it |
| :--- | :--- | :--- |
| **CLAUDE.md** | Persistent context loaded every session | Project conventions, "always do X" rules |
| **Skill** | Instructions, knowledge, and workflows | Reusable content, repeatable tasks |
| **Subagent** | Isolated execution context | Context isolation, parallel tasks |
| **Agent teams** | Coordinate multiple independent sessions | Parallel research, competing hypotheses |
| **MCP** | Connect to external services | External data or actions |
| **Hook** | Script triggered by lifecycle events | Automation that must run every time |
| **Plugin** | Bundle and distribute feature sets | Reuse across repos, share with others |

**Context costs at a glance:**

| Feature | When it loads | Context cost |
| :--- | :--- | :--- |
| CLAUDE.md | Session start | Every request |
| Skills | Session start + when used | Low (descriptions at start) |
| MCP servers | Session start | Low until a tool is used |
| Subagents | When spawned | Isolated from main session |
| Hooks | On trigger | Zero unless hook returns output |

### Parallel Execution — Choose an Approach

| Approach | What it gives you | Use it when |
| :--- | :--- | :--- |
| Subagents | Delegated workers inside one session | Side task would flood main conversation |
| Agent view (`claude agents`) | One screen to dispatch/monitor background sessions | Several independent tasks, check status at a glance |
| Agent teams | Multiple coordinated sessions with shared task list | Claude splits a project and keeps workers in sync |
| Worktrees (`--worktree`) | Separate git checkouts so sessions never touch each other's files | Running parallel sessions that edit overlapping files |
| `/batch` | 5–30 worktree-isolated subagents, each opens a PR | Repo-wide migration or mechanical refactor |

**Check on running work:**
- `claude agents` — agent view: all background sessions
- `/agents` — panel for subagents in the current session
- `/tasks` — background tasks in the current session

### Agent View (`claude agents`)

**Keyboard shortcuts:**

| Shortcut | Action |
| :--- | :--- |
| `Space` | Open/close peek panel |
| `Enter` / `→` | Attach to selected session |
| `←` (empty prompt) | Detach and return to agent view |
| `Ctrl+X` | Stop session; press again within 2s to delete |
| `Ctrl+T` | Pin/unpin session |
| `Ctrl+R` | Rename session |
| `Ctrl+S` | Toggle grouping (state vs. directory) |
| `?` | Show all shortcuts |

**Session state icons:**

| State | Icon | Meaning |
| :--- | :--- | :--- |
| Working | Animated | Claude is actively running tools |
| Needs input | Yellow | Waiting on a question or permission |
| Idle | Dimmed | Ready for next prompt |
| Completed | Green | Task finished successfully |
| Failed | Red | Task ended with an error |
| Stopped | Grey | Stopped with Ctrl+X or `claude stop` |

**Shell commands:**
```bash
claude agents               # Open agent view
claude --bg "task..."       # Start background session
claude attach <id>          # Attach to session in terminal
claude logs <id>            # Print recent output
claude stop <id>            # Stop a session
claude respawn <id>         # Restart stopped session
claude respawn --all        # Restart every stopped session
claude rm <id>              # Remove session and clean up worktree
```

**Dispatch filters:** `a:<agent>`, `s:<state>` (e.g. `s:working`), `#<PR-number>`

### Checkpointing / Rewind

Press `Esc` twice or run `/rewind` to open the rewind menu.

**Actions from rewind menu:**
- **Restore code and conversation** — revert both to the selected point
- **Restore conversation** — rewind conversation, keep current code
- **Restore code** — revert file changes, keep conversation
- **Summarize from here** — compress from this point forward (like targeted `/compact`)
- **Never mind** — return without changes

**Limitations:** Only tracks files modified by Claude's file editing tools (not bash commands or external changes). Not a replacement for git.

### Channels (Push Events into Sessions)

Install a channel plugin, then start Claude with `--channels`:

```bash
# Install a supported channel
/plugin install telegram@claude-plugins-official
/plugin install discord@claude-plugins-official
/plugin install fakechat@claude-plugins-official  # localhost demo

# Start with channels enabled
claude --channels plugin:telegram@claude-plugins-official
claude --channels plugin:fakechat@claude-plugins-official

# Multiple channels (space-separated)
claude --channels plugin:telegram@claude-plugins-official plugin:discord@claude-plugins-official
```

**Pairing (Telegram/Discord):** Send any message to your bot → bot replies with code → run `/telegram:access pair <code>` → set allowlist policy.

**iMessage:** Send a message to yourself to bypass access control automatically. Add others with `/imessage:access allow +15551234567`.

**Enterprise settings:**

| Setting | Purpose |
| :--- | :--- |
| `channelsEnabled` | Master switch (Team/Enterprise: blocked until enabled) |
| `allowedChannelPlugins` | Restrict which plugins can register as channels |

**Test custom channels during research preview:**
```bash
claude --dangerously-load-development-channels server:webhook
claude --dangerously-load-development-channels plugin:yourplugin@yourmarketplace
```

### Deep Links (`claude-cli://`)

```text
claude-cli://open                          # Open in home directory
claude-cli://open?repo=owner/name          # Open in last-used local clone
claude-cli://open?cwd=/abs/path            # Open in specific directory
claude-cli://open?repo=owner/name&q=URL-encoded+prompt
```

**Parameters:**

| Parameter | Description |
| :--- | :--- |
| `q` | URL-encoded prompt text (max 5,000 chars, `%0A` for newlines) |
| `cwd` | Absolute working directory path |
| `repo` | `owner/name` slug — resolves to most recently used local clone |

`cwd` takes precedence over `repo` if both are provided.

**Open from shell:**
```bash
open "claude-cli://open?repo=acme/app&q=review%20open%20PRs"   # macOS
xdg-open "claude-cli://open?..."                                # Linux
Start-Process "claude-cli://open?..."                           # PowerShell
```

**Note:** GitHub-rendered Markdown strips `claude-cli://` links — use a code block instead.

Disable registration: set `disableDeepLinkRegistration: "disable"` in settings.

### Desktop Scheduled Tasks

**Scheduling options comparison:**

| | Cloud (Routines) | Desktop | `/loop` |
| :--- | :--- | :--- | :--- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Access to local files | No (fresh clone) | Yes | Yes |
| Minimum interval | 1 hour | 1 minute | 1 minute |

**Create:** Click **Routines** → **New routine** → **Local** in the Desktop app.

**Schedule options:** Manual, Hourly, Daily, Weekdays, Weekly. For custom intervals, ask Claude in plain language: "schedule a task to run every 6 hours."

**Task file location:** `~/.claude/scheduled-tasks/<task-name>/SKILL.md`

### Fast Mode

Toggle: `/fast` (or set `"fastMode": true` in user settings)

- Makes Claude Opus 2.5x faster at higher cost per token
- Pricing: $30/$150 MTok (input/output) for both Opus 4.6 and 4.7
- Available on subscription plans (Pro/Max/Team/Enterprise) via extra usage only
- Not available on Bedrock, Vertex AI, or Azure Foundry

**Opus 4.7 fast mode:** Set `CLAUDE_CODE_ENABLE_OPUS_4_7_FAST_MODE=1` (becomes default on 2026-05-14).

**Rate limits:** Fast mode has separate rate limits from standard Opus. On hitting the limit, falls back to standard speed automatically (icon turns gray). Re-enables when cooldown expires.

**Admin setting:** `fastModePerSessionOptIn: true` resets fast mode each session.

### Fullscreen Rendering

Enable: `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1`
Disable: `/tui default`

**What changes vs. classic renderer:**

| Classic | Fullscreen |
| :--- | :--- |
| `Cmd+f` to search | `Ctrl+o` for transcript mode, then `/` to search |
| Terminal click-and-drag to copy | In-app selection, auto-copies on mouse release |
| `Cmd`-click to open URL | Click the URL directly |

**Scroll shortcuts:** `PgUp`/`PgDn`, `Ctrl+Home` (jump to start), `Ctrl+End` (jump to bottom + resume auto-follow)

**Transcript mode (`Ctrl+o`):** `less`-style search with `/`, `n`/`N` for next/prev match, `[` to write to native scrollback, `v` to open in `$EDITOR`.

**Mouse:** Set `CLAUDE_CODE_DISABLE_MOUSE=1` to keep flicker-free rendering but use native terminal selection.

**Scroll speed:** Set `CLAUDE_CODE_SCROLL_SPEED=3` (1–20) or run `/scroll-speed`.

### Model Configuration

**Model aliases:**

| Alias | Behavior |
| :--- | :--- |
| `default` | Clears override, uses recommended model for account type |
| `best` | Most capable available (currently `opus`) |
| `sonnet` | Latest Sonnet (Sonnet 4.6 on Anthropic API) |
| `opus` | Latest Opus (Opus 4.7 on Anthropic API) |
| `haiku` | Fast and efficient Haiku model |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opus[1m]` | Opus with 1M token context window |
| `opusplan` | Opus during plan mode, Sonnet during execution |

**Set model (priority order):**
1. During session: `/model <alias|name>` or `/model` to open picker
2. At startup: `claude --model <alias|name>`
3. Environment: `ANTHROPIC_MODEL=<alias|name>`
4. Settings: `"model": "opus"` in settings file

**Effort levels** (Opus 4.7: `low`, `medium`, `high`, `xhigh`, `max`; Opus 4.6/Sonnet 4.6: `low`, `medium`, `high`, `max`):
- Set with `/effort`, `--effort` flag, `CLAUDE_CODE_EFFORT_LEVEL`, or `effortLevel` in settings
- Default: `xhigh` on Opus 4.7, `high` on Opus 4.6/Sonnet 4.6
- Include `ultrathink` in a prompt for one-off deep reasoning on that turn

**Extended context (1M tokens):**
- Max/Team/Enterprise: Opus 1M included; Sonnet 1M needs extra usage
- Pro: both require extra usage
- Disable: `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`

**Key env vars:**

| Variable | Description |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model name for `opus` alias |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model name for `sonnet` alias |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model name for `haiku` alias |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |
| `DISABLE_PROMPT_CACHING` | Set to `1` to disable prompt caching |

### Output Styles

**Built-in styles:**
- **Default** — standard software engineering assistant
- **Proactive** — executes immediately, makes reasonable assumptions, minimizes check-ins
- **Explanatory** — adds "Insights" between steps to explain implementation choices
- **Learning** — collaborative mode with `TODO(human)` markers for you to implement

**Change:** `/config` → **Output style**, or set `"outputStyle": "Explanatory"` in settings.

Output styles modify the system prompt; changes take effect at the next session start.

**Create a custom output style:**
```markdown
---
name: Diagrams first
description: Lead every explanation with a diagram
keep-coding-instructions: true
---

When explaining code, architecture, or data flow, start with a Mermaid diagram...
```

Save to `~/.claude/output-styles/` (user), `.claude/output-styles/` (project), or managed policy dir.

**Frontmatter fields:**

| Field | Description | Default |
| :--- | :--- | :--- |
| `name` | Style name (if not file name) | Inherits from file name |
| `description` | Shown in `/config` picker | None |
| `keep-coding-instructions` | Keep built-in SE instructions | `false` |
| `force-for-plugin` | Auto-apply when plugin is enabled | `false` |

### Remote Control

Start from CLI:
```bash
claude remote-control           # Server mode — waits for connections
claude remote-control --name "My Project"
claude remote-control --spawn worktree   # Each connection gets its own worktree
claude --remote-control         # Interactive session with Remote Control enabled
claude --remote-control "Name"  # Interactive session with custom name
```

From inside a session: `/remote-control` or `/rc`

**Connect from another device:** Open the session URL in a browser, scan the QR code, or find it at [claude.ai/code](https://claude.ai/code).

**Enable for all sessions:** `/config` → **Enable Remote Control for all sessions**.

**Requirements:** Pro/Max/Team/Enterprise plan, claude.ai OAuth (not API key), workspace trust accepted. Team/Enterprise: admin must enable Remote Control toggle.

**Limitations:** Local process must stay running; no inbound ports opened; one remote session per interactive process (use server mode for multiple).

**Mobile push notifications:** Install Claude app, sign in with same account, accept notifications, run `/config` → **Push when Claude decides**. Requires v2.1.110+.

### Routines (Cloud Automation)

Create at [claude.ai/code/routines](https://claude.ai/code/routines) or from CLI with `/schedule`.

**Trigger types:**
- **Scheduled** — recurring cadence (hourly, daily, weekdays, weekly) or one-off timestamp
- **API** — HTTP POST to per-routine endpoint with bearer token
- **GitHub** — pull request or release events on a connected repository

**API trigger example:**
```bash
curl -X POST https://api.anthropic.com/v1/claude_code/routines/trig_01.../fire \
  -H "Authorization: Bearer sk-ant-oat01-xxxxx" \
  -H "anthropic-beta: experimental-cc-routine-2026-04-01" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{"text": "optional context passed to Claude"}'
```

**GitHub trigger supported events:** `pull_request` (opened, closed, assigned, labeled, synchronized) and `release` (created, published, edited, deleted).

**CLI commands:**
```bash
/schedule daily PR review at 9am   # Create scheduled routine
/schedule list                      # List all routines
/schedule update                    # Change a routine
/schedule run                       # Trigger immediately
```

Routines run autonomously (no permission prompts). Scope connectors/repos to what the routine actually needs. One-off runs don't count against the daily routine cap.

### Scheduled Tasks (`/loop`)

**`/loop` behavior by input:**

| What you provide | What happens |
| :--- | :--- |
| Interval + prompt: `/loop 5m check the deploy` | Fixed cron schedule |
| Prompt only: `/loop check the deploy` | Claude chooses interval dynamically |
| Nothing: `/loop` | Built-in maintenance prompt at dynamic interval |

**Supported interval units:** `s` (seconds), `m` (minutes), `h` (hours), `d` (days)

**One-shot reminders:**
```text
remind me at 3pm to push the release branch
in 45 minutes, check whether the integration tests passed
```

**Custom default loop:** Create `.claude/loop.md` (project) or `~/.claude/loop.md` (user) — plain Markdown, used as the default `/loop` prompt.

**Cron expression examples:**

| Expression | Meaning |
| :--- | :--- |
| `*/5 * * * *` | Every 5 minutes |
| `0 9 * * *` | Every day at 9am local |
| `0 9 * * 1-5` | Weekdays at 9am local |

Tasks expire automatically 7 days after creation. Max 50 tasks per session. Disable with `CLAUDE_CODE_DISABLE_CRON=1`.

### Status Line

Configure in `~/.claude/settings.json`:

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

Generate with: `/statusline show model name and context percentage with a progress bar`

**Key JSON fields available to your script (via stdin):**

| Field | Description |
| :--- | :--- |
| `model.display_name` | Current model name |
| `workspace.current_dir` | Current working directory |
| `context_window.used_percentage` | % of context window used |
| `context_window.context_window_size` | Max tokens (200K or 1M) |
| `cost.total_cost_usd` | Estimated session cost |
| `cost.total_duration_ms` | Elapsed wall-clock time |
| `effort.level` | Current effort level |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit % used |
| `rate_limits.seven_day.used_percentage` | 7-day rate limit % used |
| `vim.mode` | Current vim mode (when enabled) |
| `worktree.name` | Active worktree name (if `--worktree`) |

Updates after each assistant message, after `/compact`, on permission mode change, and on vim mode toggle. Use `refreshInterval` for time-based or background-sourced data.

**Tips:**
- Use `session_id` (not `$$`) as cache key for per-session temp files
- Test with: `echo '{"model":{"display_name":"Opus"},...}' | ./statusline.sh`
- Subagent status lines: `subagentStatusLine` setting, input includes `tasks` array

### Voice Dictation

Enable: `/voice` (hold mode default) or `/voice tap` (tap-to-send mode)

**Modes:**

| Mode | How it works |
| :--- | :--- |
| Hold (`/voice hold`) | Hold Space to record, release to insert transcript |
| Tap (`/voice tap`) | Tap Space to start, tap again to send (auto-sends if 3+ words) |

Persist in settings: `{"voice": {"enabled": true, "mode": "tap"}}`

**Requirements:** Claude.ai account (not API key), local microphone access. Not available on web sessions, SSH, or Bedrock/Vertex/Foundry.

**Dictation language:** Uses the `language` setting. Set in `/config` or `{"language": "japanese"}` in settings.

**Rebind key:** In `~/.claude/keybindings.json`, bind `voice:pushToTalk` in context `Chat`. Use modifier combos (e.g. `meta+k`) to avoid hold-detection warmup.

**Supported languages (20):** Czech, Danish, Dutch, English, French, German, Greek, Hindi, Indonesian, Italian, Japanese, Korean, Norwegian, Polish, Portuguese, Russian, Spanish, Swedish, Turkish, Ukrainian.

### Worktrees

**Start a session in an isolated worktree:**
```bash
claude --worktree feature-auth    # Creates .claude/worktrees/feature-auth/
claude --worktree "#1234"          # Branch from PR #1234
claude --worktree                  # Auto-generate name (e.g. bright-running-fox)
```

**Base branch behavior:** Default branches from `origin/HEAD`. Set `"worktree": {"baseRef": "head"}` in settings to always branch from local HEAD.

**Copy gitignored files into worktrees:** Create `.worktreeinclude` at project root (uses `.gitignore` syntax):
```text
.env
.env.local
config/secrets.json
```

**Subagent isolation:** Set `isolation: worktree` in subagent frontmatter, or ask Claude to "use worktrees for your agents".

**Cleanup:** No uncommitted changes → auto-removed on exit. With changes → Claude prompts to keep or remove. Add `.claude/worktrees/` to `.gitignore`.

**Manual git worktree commands:**
```bash
git worktree add ../project-feature -b feature-a  # New branch
git worktree add ../project-bugfix bugfix-123       # Existing branch
git worktree list
git worktree remove ../project-feature
```

**Non-git VCS:** Configure `WorktreeCreate` and `WorktreeRemove` hooks in settings.

### Context Window Explorer

Interactive simulation at: see [references/claude-code-context-window.md](references/claude-code-context-window.md)

**What survives `/compact`:**

| Mechanism | After compaction |
| :--- | :--- |
| System prompt and output style | Unchanged |
| Project-root CLAUDE.md and unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | Lost until matching file is read again |
| Nested CLAUDE.md in subdirectories | Lost until file in that directory is read again |
| Invoked skill bodies | Re-injected, capped at 5K tokens/skill, 25K total |
| Hooks | Not applicable (run as code, not context) |

Check live context: `/context` for breakdown with optimization suggestions. `/memory` to check which CLAUDE.md and auto memory files loaded.

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code (features overview)](references/claude-code-features-overview.md) — when to use CLAUDE.md, skills, subagents, agent teams, MCP, hooks, and plugins; context costs; feature layering
- [Run agents in parallel](references/claude-code-agents.md) — comparing subagents, agent view, agent teams, worktrees, and /batch
- [Manage multiple agents with agent view](references/claude-code-agent-view.md) — dispatching and monitoring background sessions, keyboard shortcuts, session state, shell commands
- [Push events into a session with channels](references/claude-code-channels.md) — Telegram, Discord, iMessage setup; quickstart with fakechat; security allowlists; enterprise controls
- [Channels reference](references/claude-code-channels-reference.md) — building custom channel MCP servers, webhook receivers, reply tools, sender gating, permission relay
- [Checkpointing](references/claude-code-checkpointing.md) — automatic tracking, rewind menu, restore vs. summarize, limitations
- [Explore the context window](references/claude-code-context-window.md) — interactive simulation, what loads automatically, what survives compaction
- [Launch sessions from links](references/claude-code-deep-links.md) — claude-cli:// URL scheme, parameters, platform registration, troubleshooting
- [Schedule recurring tasks in Claude Code Desktop](references/claude-code-desktop-scheduled-tasks.md) — local scheduled tasks, schedule options, missed runs, permissions
- [Speed up responses with fast mode](references/claude-code-fast-mode.md) — toggling, Opus 4.7 fast mode, cost tradeoff, rate limits
- [Fullscreen rendering](references/claude-code-fullscreen.md) — enabling, mouse support, scroll shortcuts, transcript mode, tmux notes
- [Model configuration](references/claude-code-model-config.md) — aliases, setting model, effort levels, extended context, env vars, third-party deployments
- [Output styles](references/claude-code-output-styles.md) — built-in styles, creating custom styles, frontmatter fields
- [Continue local sessions from any device with Remote Control](references/claude-code-remote-control.md) — server mode, interactive mode, connecting from another device, mobile push notifications
- [Automate work with routines](references/claude-code-routines.md) — schedule/API/GitHub triggers, creating routines, managing runs, usage limits
- [Run prompts on a schedule](references/claude-code-scheduled-tasks.md) — /loop, fixed vs. dynamic intervals, one-shot reminders, loop.md customization
- [Customize your status line](references/claude-code-statusline.md) — setup, available JSON fields, examples (context bar, git status, cost tracking, multi-line, clickable links, caching)
- [Voice dictation](references/claude-code-voice-dictation.md) — hold mode, tap mode, language settings, rebinding keys, troubleshooting
- [Run parallel sessions with worktrees](references/claude-code-worktrees.md) — --worktree flag, base branch, .worktreeinclude, subagent isolation, cleanup, non-git VCS

## Sources

- Extend Claude Code (features overview): https://code.claude.com/docs/en/features-overview.md
- Run agents in parallel: https://code.claude.com/docs/en/agents.md
- Manage multiple agents with agent view: https://code.claude.com/docs/en/agent-view.md
- Push events into a session with channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Explore the context window: https://code.claude.com/docs/en/context-window.md
- Launch sessions from links: https://code.claude.com/docs/en/deep-links.md
- Schedule recurring tasks in Claude Code Desktop: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Speed up responses with fast mode: https://code.claude.com/docs/en/fast-mode.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Continue local sessions from any device with Remote Control: https://code.claude.com/docs/en/remote-control.md
- Automate work with routines: https://code.claude.com/docs/en/routines.md
- Run prompts on a schedule: https://code.claude.com/docs/en/scheduled-tasks.md
- Customize your status line: https://code.claude.com/docs/en/statusline.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Run parallel sessions with worktrees: https://code.claude.com/docs/en/worktrees.md
