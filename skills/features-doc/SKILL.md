---
name: features-doc
user-invocable: false
description: Official documentation for Claude Code features — model configuration, fast mode, output styles, status line, checkpointing, remote control, scheduled tasks, voice, channels, context window, fullscreen, routines, deep links, agent view, worktrees, prompt caching, advisor, and the prompt library.
---

# Claude Code Features Documentation

Complete reference for Claude Code features: model and effort configuration, fast mode, output styles, status line, checkpointing, remote control, scheduled tasks, voice dictation, channels, context window visualization, fullscreen/TUI, routines, deep links, agent view, worktrees, prompt caching, the advisor tool, and the prompt library.

## Quick Reference

### Feature Extension Overview

| Extension | What it adds | Scope |
|-----------|-------------|-------|
| CLAUDE.md | Standing instructions and project context | Per-repo, user-global, or system |
| Skills | Background knowledge Claude loads automatically | Plugin-scoped |
| MCP servers | New tools, resources, and prompts | Session-scoped |
| Subagents | Delegated workers in isolated context | Per-task |
| Hooks | Shell scripts that run on Claude's events | Per-repo or user-global |
| Plugins | Bundle of skills + MCP servers + hooks | Installed on demand |

Context cost (approximate): CLAUDE.md ~1-5K tokens; Skills ~1-25K tokens each; MCP tools ~100-500 tokens per server.

---

### Model Configuration

**Set model:** `/model`, `--model <alias>`, or `"model"` setting.

| Alias | Model |
|-------|-------|
| `default` | Sonnet 4.6 (current default) |
| `best` | Fable 5 (if access) or Opus 4.8 |
| `fable` | Fable 5 (requires org access + v2.1.170+) |
| `sonnet` | Latest Sonnet |
| `opus` | Latest Opus |
| `haiku` | Latest Haiku |
| `sonnet[1m]` | Sonnet with 1M-token context |
| `opus[1m]` | Opus with 1M-token context |
| `opusplan` | Opus for plan mode, Sonnet for execution |

**Effort levels** (control thinking budget):

| Model | Levels |
|-------|--------|
| Sonnet 4.6 | low / normal / high |
| Opus 4.8 | low / normal / high |
| Haiku 4.5 | low / normal |
| Fable 5 | low / normal / high |

Set effort: `/effort <level>` or `"effort"` setting.

**Automatic fallback:** If the configured model is unavailable (rate limited, no access), Claude Code falls back through a chain. Disable with `"automaticModelFallback": false`.

**Settings:**
- `availableModels`: restrict which models appear in `/model` picker
- `modelOverrides`: map alias to specific model ID
- `ANTHROPIC_DEFAULT_MODEL` / `ANTHROPIC_DEFAULT_EFFORT` env vars

---

### Fast Mode

Toggle: `/fast` mid-session, or `--fast` flag at launch, or `"fastMode": true` setting.

| | Details |
|--|---------|
| Pricing (Opus 4.8) | Input $10/MTok, Output $50/MTok (vs $30/$150 standard) |
| Pricing (Opus 4.7/4.6) | Input $30/MTok, Output $150/MTok (same as standard) |
| Requires | Usage credits (not subscription-only plans) |
| Per-session opt-in | `"fastModePerSessionOptIn": true` prompts user each session |
| Rate limit fallback | Falls back to standard Opus when fast quota exhausted |

Fast mode reduces latency and cost for Opus 4.8 by disabling extended thinking.

---

### Output Styles

**Built-in styles:**

| Style | Behavior |
|-------|----------|
| Default | Balanced explanations with code |
| Proactive | Acts first, explains minimally |
| Explanatory | Detailed reasoning for every step |
| Learning | Teaches concepts as it works |

**Set:** `/config` → Output Style, or `"outputStyle"` setting.

**Custom styles:** Markdown file with frontmatter:
```
---
name: My Style
description: Short description
keep-coding-instructions: true   # keep built-in code rules
force-for-plugin: plugin-name    # auto-apply for a plugin
---
[prose instructions]
```

**Locations:** `~/.claude/output-styles/` (user) or `.claude/output-styles/` (project).

---

### Status Line

Configure via `"statusLine"` setting or `/statusline` command.

```json
{
  "statusLine": {
    "type": "command",
    "command": "node ~/.claude/statusline.js",
    "padding": 1,
    "refreshInterval": 5000,
    "hideVimModeIndicator": false
  }
}
```

**Available JSON data fields (passed to command via stdin):**

| Category | Fields |
|----------|--------|
| Model | `model.id`, `model.display_name` |
| Workspace | `workspace.name`, `workspace.path`, `workspace.git_branch` |
| Cost | `cost.session_cost_usd`, `cost.total_cost_usd` |
| Context | `context_window.used_tokens`, `context_window.max_tokens`, `context_window.used_pct` |
| Effort | `effort.level` |
| Rate limits | `rate_limits.requests_remaining`, `rate_limits.tokens_remaining`, `rate_limits.reset_at` |
| PR | `pr.number`, `pr.title`, `pr.url`, `pr.state` |
| Worktree | `worktree.name`, `worktree.path`, `worktree.branch` |

`"subagentStatusLine"` sets a separate config for subagent sessions.

---

### Checkpointing and Rewind

**Trigger:** `/rewind` command or double-press Escape.

**Options presented:**

| Option | Effect |
|--------|--------|
| Restore code and conversation | Reverts both file edits and conversation to the chosen point |
| Restore conversation only | Reverts conversation; keeps current file state |
| Restore code only | Reverts file edits; keeps current conversation |
| Summarize from here | Compacts conversation starting from this checkpoint |
| Summarize up to here | Compacts everything before this checkpoint |

Note: Bash command side-effects (network calls, DB writes) are not tracked and cannot be rewound.

---

### Remote Control

**Start server:** `claude remote-control` (headless server mode).
**Connect from session:** `/remote-control` or `claude --remote-control` (interactive).
**VS Code:** Available via the Claude Code VS Code extension.

| Feature | Details |
|---------|---------|
| Spawn modes | `--spawn same-dir` / `--spawn worktree` / `--spawn session` |
| Connect | QR code or URL displayed at startup |
| Mobile push notifications | Supported; requires claude.ai subscription |
| Requirements | Active claude.ai subscription |

---

### Scheduled Tasks (CLI Loops)

**Start:** `/loop` with options:
- `/loop 30m "check build status"` — interval + prompt
- `/loop "run tests"` — prompt-only (uses default interval)
- `/loop` — bare (uses loop.md default prompt)

| Detail | Value |
|--------|-------|
| Tools used by Claude | `CronCreate`, `CronList`, `CronDelete` |
| Expiry | 7 days |
| Jitter | Small random offset to avoid thundering herd |
| Custom default prompt | `.claude/loop.md` or `~/.claude/loop.md` |
| Disable entirely | `CLAUDE_CODE_DISABLE_CRON=1` env var |

---

### Voice Dictation

**Commands:**

| Command | Behavior |
|---------|----------|
| `/voice` | Toggle voice mode on/off |
| `/voice hold` | Switch to hold mode |
| `/voice tap` | Switch to tap mode |
| `/voice off` | Turn off voice |

**Modes:**

| Mode | How to use |
|------|-----------|
| Hold | Hold Space to record; release to send |
| Tap | Tap once to start recording; tap again to send |

Set `"language"` in settings to hint the transcription language. Rebind push-to-talk key with `voice:pushToTalk` in keybindings. Requires a claude.ai account.

---

### Channels

Channels let external chat platforms (Telegram, Discord, iMessage) send messages to Claude Code.

**Install:** `claude --channels plugin:name@marketplace`

| Concept | Details |
|---------|---------|
| Sender allowlist | Only paired/allowed senders can interact |
| Pairing | First message from new sender triggers pairing flow |
| Managed settings | `channelsEnabled`, `allowedChannelPlugins` |
| Status | Research preview |
| Demo plugin | `fakechat` for local testing |

**Custom channel servers (MCP):** Set `capabilities.experimental['claude/channel']` in server config. Emit `notifications/claude/channel` events. Implement `reply` tool for two-way. Use `claude/channel/permission` capability to relay permission requests to the channel.

Test with `--dangerously-load-development-channels` flag.

---

### Desktop Scheduled Tasks

Configured via the Routines sidebar in the Claude Code desktop app (separate from CLI `/loop`).

| Schedule option | Behavior |
|----------------|---------|
| Manual | Run on demand only |
| Hourly | Every hour |
| Daily | Once per day |
| Weekdays | Mon–Fri at configured time |
| Weekly | Once per week |

- Catch-up runs: if a scheduled run was missed, runs once on next launch
- Permission mode: set per task (default, acceptEdits, bypassPermissions)
- Task files stored at: `~/.claude/scheduled-tasks/<name>/SKILL.md`

---

### Context Window

**Visualize:** `/context` command opens an interactive breakdown of what's loaded.

**What loads at startup:**

| Layer | Content |
|-------|---------|
| System prompt | Claude Code's built-in instructions (unchanged after /compact) |
| Project context | CLAUDE.md files, skills, MCP resources |
| Conversation | Full message history (truncated by /compact) |

**After `/compact` — what survives:**

| Item | Survives? |
|------|-----------|
| System prompt | Yes, unchanged |
| CLAUDE.md files | Yes, re-injected |
| Invoked skills | Yes, re-injected (up to 5K tokens each; up to 25K total) |
| Tool results | No (summarized) |
| Full message history | No (replaced by summary) |

**Other commands:**
- `/memory` — view and edit what Claude remembers from the session
- `/context` — detailed window visualization

---

### Fullscreen / TUI Mode

**Enter:** `/tui` command, or set `CLAUDE_CODE_NO_FLICKER=1` to always use alternate screen buffer.

| Feature | Details |
|---------|---------|
| Mouse support | Click, drag, scroll |
| Transcript mode | `Ctrl+O` — read-only transcript with search |
| Disable mouse | `CLAUDE_CODE_DISABLE_MOUSE=1` |
| Scroll speed | `CLAUDE_CODE_SCROLL_SPEED=<n>` or `/scroll-speed <n>` |

---

### Routines (Cloud-Scheduled Sessions)

Configure at `claude.ai/code/routines`. Runs autonomously in Anthropic's cloud (no permission prompts).

**Triggers:**

| Trigger | Details |
|---------|---------|
| Schedule | Cron-style; minimum 1-hour interval |
| API | POST to `/fire` endpoint with bearer token |
| GitHub | PR or Release events with optional filters (labels, branches, etc.) |

- Start from CLI: `/schedule` command
- Daily run cap applies
- Connectors: attach MCP servers to the routine

---

### Deep Links

Open Claude Code from a URL or another app.

**CLI format:** `claude-cli://open?q=<encoded-prompt>&cwd=<path>&repo=<name>`

| Parameter | Details |
|-----------|---------|
| `q` | URL-encoded prompt; max 5000 characters |
| `cwd` | Working directory path |
| `repo` | Repo name; resolves to most recently used local clone |

**VS Code format:** `vscode://anthropic.claude-code/open?q=...`

- Registered automatically on first interactive session
- Supported on macOS, Linux, and Windows

---

### Agent View

**Open:** `claude agents` (separate supervisor process).

**Session states:**

| State | Meaning |
|-------|---------|
| Working | Actively running |
| Needs input | Waiting for user response |
| Idle | Paused, awaiting next prompt |
| Completed | Finished successfully |
| Failed | Ended with an error |
| Stopped | Manually stopped |

**Key interactions:**

| Action | Key / Command |
|--------|--------------|
| Peek at session | Space |
| Attach to session | Enter or → |
| Background current session | `/bg` |
| Launch new background session | `claude --bg` |
| Spawn in worktree | `--spawn worktree` |
| JSON output | `claude agents --json` |

- Session state stored at: `~/.claude/jobs/`
- Shell commands in agent view: prefix with `!`
- `worktree.bgIsolation` setting: isolate background sessions in worktrees automatically

---

### Parallel Agents Overview

| Approach | Coordinator | Workers communicate? | File isolation |
|----------|-------------|---------------------|----------------|
| Subagents | Claude (in-session) | Report back to parent only | Optional worktrees |
| Agent view | You (via UI) | No — independent sessions | Auto worktrees per session |
| Agent teams | Claude (lead agent) | Yes — shared task list + messaging | Manual partitioning |
| Dynamic workflows | Script | Via script logic | Per-subagent worktrees |

**Commands:**
- `/agents` — subagent panel (Library + Running tabs)
- `claude agents` — agent view (background sessions)
- `/tasks` — list background tasks in current session
- `/workflows` — list dynamic workflow runs
- `/batch` — split large change into 5–30 worktree-isolated subagents with PRs

---

### Worktrees

**Create:** `claude --worktree <name>` or `-w <name>`. Creates `.claude/worktrees/<name>/` on branch `worktree-<name>`.

| Option | Details |
|--------|---------|
| Auto-name | Omit name; gets `bright-running-fox`-style name |
| Base branch | Default: `origin/HEAD`; set `worktree.baseRef: "head"` for local HEAD |
| From PR | `claude --worktree "#1234"` — fetches `pull/1234/head` |
| In-session | Ask Claude to "work in a worktree"; uses `EnterWorktree` tool |

**Copy gitignored files:** Add `.worktreeinclude` at project root (`.gitignore` syntax). Only gitignored files matching patterns are copied.

**Subagent isolation:** Set `isolation: worktree` in subagent frontmatter, or ask Claude to "use worktrees for your agents".

**Cleanup:**
- No changes → removed automatically (unless session is named)
- Changes exist → Claude prompts to keep or remove
- Non-interactive (`-p`) → not auto-cleaned; use `git worktree remove`
- Old subagent worktrees removed after `cleanupPeriodDays` if no uncommitted/untracked/unpushed work

**Non-git VCS:** Configure `WorktreeCreate` and `WorktreeRemove` hooks to replace default git logic.

---

### Prompt Caching

Cache has three layers: system prompt → project context → conversation history.

**Actions that INVALIDATE the cache:**

| Action | Effect |
|--------|--------|
| Switch model (`/model`) | Full cache bust |
| Change effort level | Full cache bust |
| Enable fast mode | Full cache bust |
| Connect/disconnect MCP server | Full cache bust |
| Enable/disable plugin with MCP | Full cache bust |
| Deny a tool | Full cache bust |
| `/compact` | Conversation layer reset |
| Upgrade Claude Code | May bust system prompt layer |

**Actions that KEEP the cache:**

| Action | Effect |
|--------|--------|
| Edit files | Cache preserved |
| Edit CLAUDE.md mid-session | Cache preserved (re-injected) |
| Change output style | Cache preserved |
| Change permission mode | Cache preserved |
| Add/remove skills or commands | Cache preserved |
| `/recap` | Cache preserved |
| `/rewind` | Conversation layer reset only |
| Spawn subagent | Cache preserved in parent |
| Toggle `/advisor` | Cache preserved |

**TTL:**
- Subscription plans: 1 hour
- API billing: 5 minutes
- Override: `ENABLE_PROMPT_CACHING_1H=1` (force 1hr), `FORCE_PROMPT_CACHING_5M=1` (force 5min)

---

### Advisor Tool

Pair a stronger advisor model that Claude consults at key decision points.

**Enable:** `/advisor <model>`, `--advisor <model>` flag, or `"advisorModel"` setting.

**Accepted pairings:**

| Main model | Accepted advisors |
|------------|------------------|
| Haiku 4.5 | Fable, Opus, Sonnet |
| Sonnet 4.6 | Fable, Opus, Sonnet |
| Opus 4.6 or later | Fable, Opus at same version or higher |
| Fable 5 (v2.1.170+) | Fable only |

**Common pairings:**

| Pairing | When to use |
|---------|------------|
| Sonnet + Opus | Routine work with strong planning at decision points |
| Sonnet + Fable | Fable 5 guidance without running Fable throughout |
| Haiku + Opus | Lowest cost main with strong planning |
| Opus + Opus | Independent second check on high-stakes tasks |
| Fable + Fable | Highest capability (v2.1.170+) |
| Sonnet + Sonnet | Lower-cost second opinion |

**Behavior:**
- Claude decides when to call it (before committing to approach, on recurring errors, before declaring done)
- Prompt Claude to consult: "consult the advisor before you continue"
- Transcript shows `Advising` line; press `Ctrl+O` to expand full guidance
- Cost: advisor tokens billed at advisor model's rates in addition to main model
- Toggling `/advisor` does NOT invalidate prompt cache
- Requires: Claude Code v2.1.98+, Anthropic API only (not Bedrock/Vertex/Foundry)

**Turn off:** `/advisor off` or select "No advisor" in picker. Disable entirely: `CLAUDE_CODE_DISABLE_ADVISOR_TOOL=1`.

---

### Prompt Library

A curated library of copy-paste prompts organized by SDLC phase. Key prompt patterns:

| Pattern | Example |
|---------|---------|
| Describe outcome, not steps | "Ensure all API errors surface to the user" not "Add try/catch blocks" |
| Give self-check | "Verify by running the test suite" |
| Point at reference | "Follow the pattern in `src/auth/login.ts`" |
| State measurable target | "Reduce p95 latency below 200ms" |
| Give artifact | "Output a migration script" |

Categories: Planning, Coding, Testing, Debugging, Refactoring, Documentation, Code Review, Deployment.

---

## Full Documentation

- [Features Overview](references/claude-code-features-overview.md) — How Claude Code features extend the base system; comparison of CLAUDE.md vs Skills vs MCP vs Subagents vs Hooks vs Plugins
- [Model Configuration](references/claude-code-model-config.md) — Model aliases, effort levels, Fable 5, automatic fallback, `opusplan`, extended context, settings and env vars
- [Fast Mode](references/claude-code-fast-mode.md) — `/fast` toggle, pricing tiers, per-session opt-in, rate limit fallback
- [Output Styles](references/claude-code-output-styles.md) — Built-in styles, custom style files, frontmatter fields, file locations
- [Status Line](references/claude-code-statusline.md) — `statusLine` config, available JSON data fields, `/statusline` command
- [Checkpointing](references/claude-code-checkpointing.md) — `/rewind`, double-Escape, restore options, limitations with bash side-effects
- [Remote Control](references/claude-code-remote-control.md) — `claude remote-control`, `--spawn` modes, QR/URL connect, mobile push notifications
- [Scheduled Tasks (Loops)](references/claude-code-scheduled-tasks.md) — `/loop`, CronCreate/CronList/CronDelete, 7-day expiry, custom default prompt
- [Voice Dictation](references/claude-code-voice-dictation.md) — `/voice`, hold vs tap mode, language setting, key rebinding
- [Channels](references/claude-code-channels.md) — Telegram/Discord/iMessage plugins, sender allowlist, `channelsEnabled` setting
- [Channels Reference](references/claude-code-channels-reference.md) — Build custom MCP channel servers, capabilities, permission relay
- [Desktop Scheduled Tasks](references/claude-code-desktop-scheduled-tasks.md) — Routines sidebar, schedule options, catch-up runs, permission mode
- [Context Window](references/claude-code-context-window.md) — `/context` visualization, what loads at startup, what survives `/compact`, `/memory`
- [Fullscreen / TUI](references/claude-code-fullscreen.md) — `/tui`, mouse support, transcript mode (`Ctrl+O`), scroll speed
- [Routines](references/claude-code-routines.md) — Cloud-scheduled sessions at claude.ai/code/routines; Schedule/API/GitHub triggers; `/schedule` command
- [Deep Links](references/claude-code-deep-links.md) — `claude-cli://open` URL scheme, parameters, VS Code variant
- [Agent View](references/claude-code-agent-view.md) — `claude agents`, session states, peek/attach, background sessions, `--spawn worktree`
- [Run Agents in Parallel](references/claude-code-agents.md) — Subagents vs Agent view vs Agent teams vs Dynamic workflows; `/agents`, `/tasks`, `/workflows`, `/batch`
- [Worktrees](references/claude-code-worktrees.md) — `--worktree` flag, `.worktreeinclude`, subagent isolation, base branch, cleanup, non-git VCS hooks
- [Prompt Caching](references/claude-code-prompt-caching.md) — Cache layers, invalidating vs preserving actions, TTL, env var overrides
- [Advisor Tool](references/claude-code-advisor.md) — `/advisor`, model pairings, billing, prompt cache behavior, requirements
- [Prompt Library](references/claude-code-prompt-library.md) — Copy-paste prompts by SDLC phase, prompt-writing patterns

## Sources

- https://code.claude.com/docs/en/features-overview.md
- https://code.claude.com/docs/en/model-config.md
- https://code.claude.com/docs/en/fast-mode.md
- https://code.claude.com/docs/en/output-styles.md
- https://code.claude.com/docs/en/statusline.md
- https://code.claude.com/docs/en/checkpointing.md
- https://code.claude.com/docs/en/remote-control.md
- https://code.claude.com/docs/en/scheduled-tasks.md
- https://code.claude.com/docs/en/voice-dictation.md
- https://code.claude.com/docs/en/channels.md
- https://code.claude.com/docs/en/channels-reference.md
- https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- https://code.claude.com/docs/en/context-window.md
- https://code.claude.com/docs/en/fullscreen.md
- https://code.claude.com/docs/en/routines.md
- https://code.claude.com/docs/en/deep-links.md
- https://code.claude.com/docs/en/agent-view.md
- https://code.claude.com/docs/en/agents.md
- https://code.claude.com/docs/en/worktrees.md
- https://code.claude.com/docs/en/prompt-caching.md
- https://code.claude.com/docs/en/prompt-library.md
- https://code.claude.com/docs/en/advisor.md
