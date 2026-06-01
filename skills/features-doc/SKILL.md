---
name: features-doc
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features beyond the core agentic loop: extension architecture, agent orchestration, UI capabilities, model configuration, scheduling, remote access, and performance tuning.

## Quick Reference

### Extension Selection Guide

| Feature | What it is | Best for |
|:--------|:-----------|:---------|
| CLAUDE.md | Persistent instructions loaded into every session | Rules, project setup, always-on context |
| Skills | Reusable slash commands that run in your conversation | Repeatable workflows invoked on demand |
| Subagents | Delegated workers in their own context | Side tasks that would flood the main conversation |
| MCP | Tool plugins exposed to Claude | Persistent capabilities (DB access, APIs, search) |
| Hooks | Shell/HTTP/LLM handlers at lifecycle points | Automated side-effects, validation, formatting |
| Plugins | Packaged bundles of the above | Shareable multi-project extensions |

### Context Cost by Feature

| Feature | Context cost |
|:--------|:-------------|
| CLAUDE.md (project) | All tokens, every turn |
| CLAUDE.md (user) | All tokens, every turn |
| Skills (non-active) | Zero |
| Skills (active/expanded) | Skill content tokens |
| Subagent results | Summary returned to parent only |
| MCP tool results | Tool output tokens |
| Hooks | Zero (run out-of-band) |

---

### Parallel Agents Overview

| Approach | Who coordinates | Workers talk? | File isolation |
|:---------|:---------------|:--------------|:---------------|
| Subagents | Claude (inside one session) | No | Optional (`isolation: worktree`) |
| Agent view (`claude agents`) | You | No | Automatic worktrees |
| Agent teams | Claude (lead + teammates) | Yes (shared task list) | Manual partitioning |
| Dynamic workflows | Script | Via workflow logic | Per-subagent worktrees |

**Check running work:**

| Command | What it shows |
|:--------|:-------------|
| `claude agents` | All background sessions and their state |
| `/agents` | Running subagents + custom subagent library |
| `/tasks` | Items running in the background of current session |
| `/workflows` | Running/completed dynamic workflow runs |

---

### Agent View (`claude agents`) — Session States and Shortcuts

| State | Meaning |
|:------|:--------|
| Running | Actively working |
| Waiting for input | Needs your response |
| Paused | Temporarily suspended |
| Complete | Finished successfully |
| Error | Exited with error |

**Keyboard shortcuts:**

| Key | Action |
|:----|:-------|
| `↑ / ↓` | Navigate sessions |
| `Enter` | Attach to session |
| `n` | New session |
| `d` | Dispatch task |
| `p` | Pause/resume |
| `s` | Stop session |
| `q` | Quit agent view |
| `?` | Help |

---

### Worktrees

**Start Claude in a worktree:**

```bash
claude --worktree feature-auth        # named worktree, branch worktree-feature-auth
claude --worktree "#1234"             # from PR #1234
claude --worktree                     # auto-generated name
```

| Concept | Detail |
|:--------|:-------|
| Default location | `.claude/worktrees/<name>/` |
| Default branch | `worktree-<name>` |
| Base branch default | `origin/HEAD` (clean remote state) |
| Branch from local HEAD | Set `worktree.baseRef: "head"` in settings |
| Copy gitignored files | List patterns in `.worktreeinclude` at project root |
| Subagent isolation | `isolation: worktree` in subagent frontmatter |
| Non-git VCS | Configure `WorktreeCreate`/`WorktreeRemove` hooks |
| Gitignore worktrees dir | Add `.claude/worktrees/` to `.gitignore` |

**Cleanup:** Worktrees with no uncommitted changes, untracked files, or new commits are removed automatically on exit. Subagent/background worktrees older than `cleanupPeriodDays` (with no local changes) are swept automatically. `--worktree` sessions are never auto-swept. Non-interactive (`-p`) sessions require manual `git worktree remove`.

---

### Model Configuration

**Model aliases:**

| Alias | Resolves to |
|:------|:------------|
| `default` | Current default model |
| `best` | Best available model |
| `opus` | Latest Opus |
| `sonnet` | Latest Sonnet |
| `haiku` | Latest Haiku |
| `sonnet[1m]` | Sonnet with 1M context |
| `opus[1m]` | Opus with 1M context |
| `opusplan` | Opus with extended thinking |

**Effort levels:**

| Level | Description |
|:------|:------------|
| `low` | Fastest, least thorough |
| `medium` | Balanced |
| `high` | More thorough |
| `xhigh` | Very thorough |
| `max` | Maximum effort |
| `ultracode` | Max effort optimized for coding |

**Environment variable overrides:**

| Variable | Effect |
|:---------|:-------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Override the Opus alias |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Override the Sonnet alias |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Override the Haiku alias |

`modelOverrides` in settings lets you pin specific model IDs for different roles (main, subagent, background).

---

### Fast Mode

| Item | Detail |
|:-----|:-------|
| Toggle | `/fast` in session |
| Supported models | Opus 4.8, 4.7, 4.6 |
| Pricing (Opus 4.8) | $10/MTok input, $50/MTok output |
| Requirements | Usage credits; Team/Enterprise requires admin enablement |
| Rate limit behavior | Falls back to standard mode if rate limit hit |

---

### Output Styles

**Built-in styles:**

| Name | Description |
|:-----|:------------|
| Default | Standard Claude Code output |
| Proactive | More initiative, less asking for confirmation |
| Explanatory | More explanation of decisions |
| Learning | Teaching-oriented explanations |

**Custom styles:** Markdown files with optional frontmatter (`name`, `description`, `keep-coding-instructions`, `force-for-plugin`). Change via `/config`. Plugins can ship styles in `output-styles/`.

---

### Status Line

Configure `statusLine` in settings:

```json
{
  "statusLine": {
    "type": "command",
    "command": "/path/to/script.sh",
    "padding": 1,
    "refreshInterval": 5000,
    "hideVimModeIndicator": false
  }
}
```

Script receives JSON on stdin; output replaces the status bar. `subagentStatusLine` configures the same for subagents. Toggle with `/statusline`.

---

### Checkpointing

| Action | How |
|:-------|:----|
| Open rewind panel | Double-Esc or `/rewind` |
| Restore code only | Select checkpoint → Restore Code |
| Restore conversation only | Select checkpoint → Restore Conversation |
| Restore both | Select checkpoint → Restore Both |
| Summarize from here | Select checkpoint → Summarize From Here |
| Summarize up to here | Select checkpoint → Summarize Up To Here |

Checkpoints are stored for 30 days. Bash command side-effects are not tracked (file edits are).

---

### Prompt Caching

**Cache layers (in order):**
1. System prompt + tools
2. Project context (CLAUDE.md files)
3. Conversation history

**Actions that invalidate the cache:**

| Action | Effect |
|:-------|:-------|
| Switch model | Full cache miss |
| Change effort level | Full cache miss |
| Connect/disconnect MCP server | Full cache miss |
| Add/remove deny-tool rule | Full cache miss |
| Compact conversation | Cache rebuilt from compact summary |
| Upgrade Claude Code | Cache rebuilt |

Cache TTL: 5 minutes (short-lived) or 1 hour (extended, when eligible). Disable with `DISABLE_PROMPT_CACHING=1`.

---

### Scheduling Options Comparison

| Method | Where | Trigger | Persistent? |
|:-------|:------|:--------|:------------|
| `/loop` | CLI, session-scoped | Interval (`/loop 5m <prompt>`) | No |
| Desktop Routines | Desktop app | Manual/Hourly/Daily/Weekdays/Weekly | Yes (local) |
| Cloud Routines | `claude.ai/code/routines` | Schedule / API call / GitHub event | Yes (cloud) |
| `/schedule` | CLI | One-shot; `CronCreate` tool for recurring | Until session end (7-day expiry) |

**`/loop` details:** Hold-to-record prompt; `CronCreate`/`CronList`/`CronDelete` tools; customize with `loop.md`; disable with `CLAUDE_CODE_DISABLE_CRON=1`.

**Cloud Routine triggers:**

| Trigger | Details |
|:--------|:--------|
| Schedule | Cron-style schedule |
| API (`/fire`) | HTTP endpoint call |
| GitHub `pull_request` | Runs on PR open/update |
| GitHub `release` | Runs on release publish |

---

### Remote Control

| Mode | Description |
|:-----|:------------|
| `claude remote-control` | Start a server that accepts connections from a remote Claude Code |
| `claude --remote-control` | Connect to an existing remote-control server |
| `/remote-control` | Toggle remote-control mode in session |

`--spawn` options: `same-dir` (default), `worktree`, `session`. Connect via URL, QR code, or session list. Supports mobile push notifications.

---

### Channels (Push Notifications)

| Platform | Setup |
|:---------|:------|
| Telegram | Connect via `/channel` in session |
| Discord | Connect via `/channel` in session |
| iMessage | Connect via `/channel` in session |

Use `--channels` CLI flag to enable channels at launch. Enterprise controls: `channelsEnabled` (allow/block), `allowedChannelPlugins` (allowlist specific channel plugins).

**Custom channel MCP servers:** Declare `claude/channel` capability in server config; implement `send_notification` and optional reply tools; Claude Code strips channel output before the model sees it.

---

### Voice Dictation

| Mode | How to trigger |
|:-----|:--------------|
| Tap mode | `/voice tap` — click mic, speak, auto-submits |
| Hold mode | `/voice hold` or `/voice` — hold Space to record, release to submit |
| Push-to-talk keybinding | `voice:pushToTalk` in keybindings config |

Requires claude.ai account. `autoSubmit` setting controls whether tap mode auto-submits. Works best with `CLAUDE_CODE_NO_FLICKER=1` for terminal rendering stability.

---

### Fullscreen / TUI Mode

| Method | Command |
|:-------|:--------|
| Toggle fullscreen | `/tui fullscreen` |
| Env var (no-flicker) | `CLAUDE_CODE_NO_FLICKER=1` |
| Transcript mode | `Ctrl+O` |
| Search transcript | `/` |
| Write to scrollback | `[` |

Fullscreen uses the alternate screen buffer with mouse support enabled.

---

### Context Window Management

Commands: `/context` (view usage), `/memory` (manage persistent context).

**What survives compaction:**

| Survives | Does not survive |
|:---------|:----------------|
| CLAUDE.md content | Raw tool outputs |
| Key decisions and summaries | Intermediate file contents |
| Final file states | Search result lists |
| Conversation arc | Verbose logs |

---

### Deep Links

| Parameter | Required | Description |
|:----------|:---------|:------------|
| `q` | No | Initial prompt |
| `cwd` | No | Working directory |
| `repo` | No | Repository path |

**CLI URL scheme:** `claude-cli://open?q=...&cwd=...`

**VS Code URL scheme:** `vscode://anthropic.claude-code/open?q=...`

Register URL scheme: run `claude` once after installation or use the in-app registration prompt.

---

### Prompt Library

50+ prompts organized by SDLC phase:

| Phase | Example categories |
|:------|:------------------|
| Discover | Explore codebase, understand architecture |
| Design | Plan features, review designs |
| Build | Implement, refactor, write tests |
| Ship | Code review, PR description, changelog |
| Operate | Debug, monitor, incident response |

---

## Full Documentation

- [Features Overview](references/claude-code-features-overview.md) — Extension selection guide (CLAUDE.md vs Skills vs Subagents vs MCP vs Hooks vs Plugins), context cost table, layering rules
- [Run Agents in Parallel](references/claude-code-agents.md) — Compare subagents, agent view, agent teams, and dynamic workflows; /batch; worktrees as isolation layer
- [Agent View](references/claude-code-agent-view.md) — `claude agents` command, session states, keyboard shortcuts, dispatch, file isolation via worktrees, supervisor process
- [Worktrees](references/claude-code-worktrees.md) — `--worktree` flag, base branch config, `.worktreeinclude`, subagent isolation, cleanup rules, non-git VCS hooks
- [Channels](references/claude-code-channels.md) — Push events from Telegram/Discord/iMessage into running sessions; `--channels` flag; enterprise controls
- [Channels Reference](references/claude-code-channels-reference.md) — Build custom channel MCP servers; `claude/channel` capability; notification format; reply tools; permission relay
- [Remote Control](references/claude-code-remote-control.md) — `claude remote-control` server mode, `--remote-control` client, `/remote-control` command, `--spawn` options, mobile push
- [Checkpointing](references/claude-code-checkpointing.md) — `/rewind` (double-Esc), restore code/conversation/both, summarize from/up to here, 30-day cleanup, limitations
- [Model Configuration](references/claude-code-model-config.md) — Model aliases, effort levels, extended thinking, 1M context, `modelOverrides`, env var overrides
- [Fast Mode](references/claude-code-fast-mode.md) — `/fast` toggle, supported Opus models, pricing, usage credit requirement, rate limit fallback
- [Prompt Caching](references/claude-code-prompt-caching.md) — Cache layers, invalidation triggers, TTL (5-min vs 1-hour), `DISABLE_PROMPT_CACHING`
- [Scheduling — /loop](references/claude-code-scheduled-tasks.md) — Interval+prompt, `CronCreate`/`CronList`/`CronDelete` tools, `loop.md`, `CLAUDE_CODE_DISABLE_CRON`
- [Desktop Routines](references/claude-code-desktop-scheduled-tasks.md) — Desktop app Routines, Local vs Remote, schedule options, missed runs, permission management
- [Cloud Routines](references/claude-code-routines.md) — Cloud routines at `claude.ai/code/routines`, schedule/API/GitHub triggers, `/schedule` CLI, usage limits
- [Output Styles](references/claude-code-output-styles.md) — Built-in styles, custom Markdown style files, frontmatter fields, `/config` to change, plugin styles
- [Voice Dictation](references/claude-code-voice-dictation.md) — `/voice`, `/voice tap`, `/voice hold`, hold mode vs tap mode, push-to-talk keybinding
- [Fullscreen / TUI](references/claude-code-fullscreen.md) — `/tui fullscreen`, `CLAUDE_CODE_NO_FLICKER=1`, alternate screen buffer, mouse support, `Ctrl+O` transcript mode
- [Status Line](references/claude-code-statusline.md) — `statusLine` settings field, full stdin JSON schema, `/statusline` command, `subagentStatusLine`
- [Context Window](references/claude-code-context-window.md) — Interactive simulation, what survives compaction, `/context` and `/memory` commands
- [Deep Links](references/claude-code-deep-links.md) — `claude-cli://open` URL scheme, VS Code variant, URL parameters, registration
- [Prompt Library](references/claude-code-prompt-library.md) — 50+ prompts organized by SDLC phase (Discover/Design/Build/Ship/Operate), effective prompting patterns

## Sources

- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Run Agents in Parallel: https://code.claude.com/docs/en/agents.md
- Agent View: https://code.claude.com/docs/en/agent-view.md
- Worktrees: https://code.claude.com/docs/en/worktrees.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels Reference: https://code.claude.com/docs/en/channels-reference.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Prompt Caching: https://code.claude.com/docs/en/prompt-caching.md
- Scheduling — /loop: https://code.claude.com/docs/en/scheduled-tasks.md
- Desktop Routines: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Cloud Routines: https://code.claude.com/docs/en/routines.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Voice Dictation: https://code.claude.com/docs/en/voice-dictation.md
- Fullscreen / TUI: https://code.claude.com/docs/en/fullscreen.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Context Window: https://code.claude.com/docs/en/context-window.md
- Deep Links: https://code.claude.com/docs/en/deep-links.md
- Prompt Library: https://code.claude.com/docs/en/prompt-library.md
