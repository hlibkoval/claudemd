---
name: features-doc
user-invocable: false
---

# Features Documentation

This skill covers Claude Code's extended feature set: model configuration, fast mode, output styles, status line, checkpointing, agent parallelism approaches, agent view, worktrees, channels, scheduling (session loops, desktop tasks, cloud routines), remote control, voice dictation, prompt caching, fullscreen rendering, context window management, deep links, and the prompt library.

## Quick Reference

### Extension Features Overview

| Feature | What it does | When to use it |
|:--------|:-------------|:---------------|
| **CLAUDE.md** | Persistent context loaded every conversation | Project conventions, "always do X" rules |
| **Skills** | Instructions, knowledge, and workflows Claude can use | Reusable content, reference docs, repeatable tasks |
| **Subagents** | Isolated execution context that returns summarized results | Context isolation, parallel tasks, specialized workers |
| **Agent teams** | Coordinate multiple independent Claude Code sessions | Parallel research, feature development, competing hypotheses |
| **Code intelligence** | Language-server navigation and diagnostics | Typed languages, large codebases where grep is slow |
| **MCP** | Connect to external services | External data or actions |
| **Hooks** | Script/HTTP/prompt/subagent triggered by events | Automation that must run on every matching event |
| **Plugins** | Bundle skills, hooks, subagents, MCP into one installable unit | Reuse across repos, distribute via marketplace |

### Agent Parallelism Approaches

| Approach | Coordinator | Workers communicate? | File isolation |
|:---------|:-----------|:--------------------|:--------------|
| **Subagents** | Claude (inside one session) | Return results to parent only | Optional (worktrees) |
| **Agent view** (`claude agents`) | You (hand off, check back) | No | Auto worktree per session |
| **Agent teams** | Claude (lead assigns, supervises) | Shared task list + peer messaging | No — partition files manually |
| **Dynamic workflows** | Script (not Claude's turn-by-turn judgment) | Script coordinates | Per-subagent worktrees |

### Agent View (`claude agents`)

| Action | How |
|:-------|:----|
| Open agent view | `claude agents` or `/agents` (from session) |
| Launch session in background | `claude --bg "your task"` |
| Dispatch from agent view | `n` — new session, `d` — dispatch to existing |
| Peek at running session | `p` |
| Attach to session | `Enter` or `a` |
| Stop session | `s` |
| Session states | `●` running, `◐` waiting for you, `○` idle, `✓` done, `✗` failed |

### Worktrees

| Concept | Detail |
|:--------|:-------|
| Start in new worktree | `claude --worktree <name>` or `-w <name>` |
| Default location | `.claude/worktrees/<name>/` |
| Default branch | `worktree-<name>` |
| Base branch default | `origin/HEAD` (clean remote state) |
| Branch from local HEAD | Set `worktree.baseRef: "head"` in settings |
| Branch from a PR | `claude --worktree "#1234"` |
| Copy gitignored files in | List patterns in `.worktreeinclude` at project root |
| Subagent isolation | `isolation: worktree` in subagent frontmatter |
| Non-git VCS | Configure `WorktreeCreate`/`WorktreeRemove` hooks |
| Gitignore worktrees dir | Add `.claude/worktrees/` to `.gitignore` |

### Model Configuration

#### Model Aliases

| Alias | Resolves to |
|:------|:-----------|
| `default` | Current default model |
| `best` | Highest-capability model available |
| `sonnet` | Latest Sonnet |
| `opus` | Latest Opus |
| `haiku` | Latest Haiku |
| `sonnet[1m]` | Sonnet with 1M context window |
| `opus[1m]` | Opus with 1M context window |
| `opusplan` | Opus in plan mode |

Switch models: `/model` picker, `modelOverrides` in settings, or env vars for alias pinning.

#### Effort Levels

| Level | Description |
|:------|:-----------|
| `low` | Minimal thinking, fastest |
| `medium` | Balanced |
| `high` | Extended thinking |
| `xhigh` | More extended thinking |
| `max` | Maximum thinking budget |
| `ultracode` | Optimized for large coding tasks |

Set via `/effort`, settings, or `--effort` CLI flag. Extended thinking available on supporting models.

### Fast Mode

| Item | Detail |
|:-----|:-------|
| Toggle | `/fast` command while in a session |
| Effect | Up to 2.5× faster responses with Opus models |
| Opus 4.8 pricing | $10 input / $50 output per MTok |
| Opus 4.7/4.6 pricing | $30 input / $150 output per MTok |
| Requirement | Usage credits (not subscription) |
| Setting | `fastModePerSessionOptIn: true` to default on |

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
