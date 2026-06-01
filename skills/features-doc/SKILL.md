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

### Output Styles

| Style | Description |
|:------|:-----------|
| Default | Standard Claude Code responses |
| Proactive | More suggestions and next steps |
| Explanatory | More reasoning and context |
| Learning | Pedagogical, teaches as it codes |
| Custom | Point `outputStyle` to a Markdown file |

Switch via `/config` → Output style, or set `outputStyle` in settings. Custom styles use `keep-coding-instructions` frontmatter to also apply built-in coding rules.

### Status Line

Configure `statusLine` in settings with `type: "command"`. Claude Code pipes JSON to the script on each update.

#### Status Line JSON Fields

| Field | Description |
|:------|:-----------|
| `model` | Current model name |
| `cwd` | Working directory |
| `context_window` | Tokens used / total |
| `cost` | Session cost so far |
| `rate_limits` | API rate limit state |
| `vim` | Vim mode state |
| `worktree` | Current worktree name if any |
| `pr` | Associated pull request if any |

Commands: `/statusline` to toggle; `subagentStatusLine` for subagent-specific command. `COLUMNS`/`LINES` env vars available in the script.

### Checkpointing

| Action | How |
|:-------|:----|
| Open rewind UI | Press Esc twice, or `/rewind` |
| Restore options | Code only, conversation only, or both |
| Summarize from here | Compacts context starting at a checkpoint |
| Summarize up to here | Compacts context up to the selected point |

Checkpoints are automatic; no configuration needed.

### Prompt Caching

#### Cache Layers (in order)

1. System prompt + tools
2. Project context (CLAUDE.md files)
3. Conversation history

#### Actions That Invalidate Cache

| Action | Effect |
|:-------|:-------|
| Switch model | Full cache miss |
| Change effort level | Full cache miss |
| Connect/disconnect MCP server | Full cache miss |
| Deny a tool | Full cache miss |
| Compact conversation | Cache rebuilt from compact summary |
| Upgrade Claude Code | Cache rebuilt |

Cache TTL defaults to 5 minutes. Extended to 1 hour with `ENABLE_PROMPT_CACHING_1H=1` or on subscription plans. Disable entirely with `DISABLE_PROMPT_CACHING=1`.

### Scheduling Comparison

| Approach | Runs where | Trigger | Use when |
|:---------|:----------|:--------|:---------|
| **Session loop** (`/loop`) | Local machine, in-session | Interval + prompt | Recurring tasks while session is active |
| **Desktop scheduled task** | Local machine | Time schedule | Tasks that need your machine to be on |
| **Cloud routine** | Anthropic cloud | Schedule, API, or GitHub | Tasks that run independently of your machine |

#### Session Loop (`/loop`)

| Mode | Syntax | Description |
|:-----|:-------|:-----------|
| Interval + prompt | `/loop 5m check the build` | Runs prompt every 5 minutes |
| Prompt only | `/loop check the build` | Claude sets the interval dynamically |
| Bare | `/loop` | Runs maintenance prompt (`loop.md`) |

Tools: `CronCreate`, `CronList`, `CronDelete`. Tasks expire after 7 days. Disable with `CLAUDE_CODE_DISABLE_CRON=1`.

#### Cloud Routines

Triggers: scheduled time, REST API call, or GitHub event. Runs at `claude.ai/code/routines`. Create via `/schedule` CLI command or Routines page. Subject to daily run cap. Currently in beta (`experimental-cc-routine-2026-04-01` header required for API).

### Remote Control

| Mode | How to start |
|:-----|:------------|
| Standalone server | `claude remote-control` or `claude --remote-control` |
| In-session toggle | `/remote-control` |
| With spawn options | `claude remote-control --spawn "your task"` |
| Connect from | claude.ai/code or Claude mobile app |

Requires claude.ai subscription. Supports mobile push notifications when Claude needs input.

### Channels

Push events from Telegram, Discord, or iMessage into a running Claude Code session.

| Item | Detail |
|:-----|:-------|
| Enable | `claude --channels` or configure channel plugin |
| Message flow | External message → channel MCP server → running session |
| Enterprise controls | `channelsEnabled`, `allowedChannelPlugins` settings |
| Custom channel servers | Implement `claude/channel` MCP capability + `notifications/claude/channel` events |
| Sender gating | Channel server controls which senders are allowed |

### Voice Dictation

| Item | Detail |
|:-----|:-------|
| Toggle | `/voice` command |
| Hold mode (default) | Hold Space to record, release to submit |
| Tap mode | `/voice tap`, tap Space to start/stop |
| Auto-submit | Configure `voice.autoSubmit` in settings |
| Keybinding | `voice.pushToTalk` in keybindings |
| Requirement | claude.ai account; audio streams to Anthropic servers |
| Supported languages | 20 languages |

### Fullscreen / TUI Rendering

| Item | Detail |
|:-----|:-------|
| Enable fullscreen | `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Uses | Alternate screen buffer (like vim/less) |
| Mouse support | Enabled by default in fullscreen mode |
| Disable mouse | `CLAUDE_CODE_DISABLE_MOUSE=1` |
| Transcript mode | `Ctrl+O` to toggle scrollable transcript overlay |

### Context Window Management

Commands: `/context` to inspect what's loaded, `/memory` to view memory files.

#### What Survives Compaction

| Content | Survives compact? |
|:--------|:-----------------|
| System prompt | Yes |
| CLAUDE.md files | Yes (reloaded) |
| Skill content | Yes (reloaded) |
| Conversation messages | No — replaced by summary |
| Tool results (large) | No |
| Inline file contents | No |

Context loads at startup: system prompt, all CLAUDE.md in hierarchy, active skills, MCP server tool schemas.

### Deep Links

URL scheme: `claude-cli://open`

| Parameter | Description |
|:----------|:-----------|
| `q` | Prompt text to pre-fill |
| `cwd` | Working directory to open in |
| `repo` | Repository to open (path or URL) |

Register deep links: automatic on macOS; Linux/Windows may require manual setup. Disable with `disableDeepLinkRegistration: true` in settings.

### Prompt Library

Interactive library of 50+ prompts organized by SDLC phase and category.

| Phase | Example categories |
|:------|:------------------|
| Discover | Explore codebase, understand architecture |
| Design | Plan features, review designs |
| Build | Implement, refactor, write tests |
| Ship | Code review, PR description, changelog |
| Operate | Debug, monitor, incident response |

Filterable by tag. Access via the prompt library UI.

## Full Documentation

- [Extend Claude Code (Features Overview)](references/claude-code-features-overview.md) — Extension types, feature comparison table, when to use each
- [Run agents in parallel](references/claude-code-agents.md) — Compare subagents, agent view, agent teams, and dynamic workflows
- [Agent view](references/claude-code-agent-view.md) — Background sessions, session states, keyboard shortcuts, dispatch options, supervisor process
- [Channels](references/claude-code-channels.md) — Push events from Telegram/Discord/iMessage into running sessions; enterprise controls
- [Channels reference](references/claude-code-channels-reference.md) — Build custom channel MCP servers; `claude/channel` capability; reply tools; sender gating
- [Checkpointing](references/claude-code-checkpointing.md) — `/rewind` UI, restore code/conversation/both, summarize from/up to a checkpoint
- [Context window](references/claude-code-context-window.md) — What loads at startup, what survives compaction, `/context` and `/memory` commands
- [Deep links](references/claude-code-deep-links.md) — `claude-cli://open` URL scheme, parameters, registration per platform
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) — Local machine scheduling, vs cloud routines vs `/loop`, missed runs, permissions
- [Fast mode](references/claude-code-fast-mode.md) — `/fast` toggle, up to 2.5× faster, Opus pricing, usage credit requirement
- [Fullscreen rendering](references/claude-code-fullscreen.md) — `/tui fullscreen`, alternate screen buffer, mouse support, `Ctrl+O` transcript mode
- [Model configuration](references/claude-code-model-config.md) — Model aliases, `/model` picker, effort levels, extended thinking, 1M context, `modelOverrides`
- [Output styles](references/claude-code-output-styles.md) — Built-in styles, custom Markdown-based styles, `keep-coding-instructions` frontmatter
- [Prompt caching](references/claude-code-prompt-caching.md) — Prefix matching, cache layers, invalidating actions, TTL, env var controls
- [Prompt library](references/claude-code-prompt-library.md) — 50+ prompts organized by SDLC phase, filterable by tag
- [Remote control](references/claude-code-remote-control.md) — `claude remote-control`, in-session toggle, connect from claude.ai/code or mobile app
- [Cloud routines](references/claude-code-routines.md) — Schedule/API/GitHub triggers, Anthropic-hosted, `/schedule` CLI, daily run cap
- [Session-scoped scheduling (`/loop`)](references/claude-code-scheduled-tasks.md) — Interval+prompt, prompt-only, bare mode; `CronCreate`/`CronList`/`CronDelete` tools
- [Status line](references/claude-code-statusline.md) — `statusLine` setting, JSON fields piped to script, `/statusline` command, examples
- [Voice dictation](references/claude-code-voice-dictation.md) — `/voice` toggle, hold mode vs tap mode, `voice.pushToTalk`, 20 languages
- [Worktrees](references/claude-code-worktrees.md) — `--worktree` flag, base branch selection, `.worktreeinclude`, subagent isolation, non-git VCS

## Sources

- Extend Claude Code (Features Overview): https://code.claude.com/docs/en/features-overview.md
- Run agents in parallel: https://code.claude.com/docs/en/agents.md
- Agent view: https://code.claude.com/docs/en/agent-view.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Context window: https://code.claude.com/docs/en/context-window.md
- Deep links: https://code.claude.com/docs/en/deep-links.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Fullscreen rendering: https://code.claude.com/docs/en/fullscreen.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Prompt caching: https://code.claude.com/docs/en/prompt-caching.md
- Prompt library: https://code.claude.com/docs/en/prompt-library.md
- Remote control: https://code.claude.com/docs/en/remote-control.md
- Cloud routines: https://code.claude.com/docs/en/routines.md
- Session-scoped scheduling: https://code.claude.com/docs/en/scheduled-tasks.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Worktrees: https://code.claude.com/docs/en/worktrees.md
