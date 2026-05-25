---
name: features-doc
description: >
  Reference for Claude Code's extended feature set: fast mode, model aliases and
  effort levels, output styles, status line, checkpointing, remote control,
  scheduled tasks (/loop, Desktop Routines, cloud Routines), voice dictation,
  Telegram/Discord/iMessage channels, context window and prompt caching,
  deep links, agent view, parallel agent approaches, git worktrees, fullscreen
  TUI rendering, and the built-in prompt library.
user-invocable: false
---

# Claude Code Features

Claude Code extends its core coding assistant with a broad set of power-user and automation features. This skill covers every feature area across 21 reference docs: model and speed configuration, output and UX customization, session continuity, remote and scheduled automation, voice input, messaging channels, context management, parallel agent patterns, and discovery tooling.

## Quick Reference

### Feature Selection Guide

| Goal | Feature |
|------|---------|
| Faster/cheaper Opus responses | Fast mode (`/fast`) |
| Pin a specific model | `CLAUDE_MODEL` env var or `model` setting |
| Change response verbosity/style | Output styles |
| Show model/cost in shell prompt | Status line |
| Undo a bad edit without re-running | Checkpointing (`/rewind`) |
| Trigger Claude from a phone/script | Remote control |
| Run Claude on a schedule | `/loop`, Desktop scheduled tasks, or cloud Routines |
| Dictate prompts by voice | Voice dictation |
| Chat with Claude over Telegram/Discord | Channels |
| Inspect what's in the context window | `/context` command |
| Control prompt cache invalidation | Prompt caching |
| Open Claude from a browser link | Deep links |
| Manage background sessions visually | Agent view (`claude agents`) |
| Isolate parallel edits to separate branches | Worktrees (`--worktree`) |
| Run Claude full-screen in the terminal | Fullscreen TUI (`/tui fullscreen`) |
| Browse curated prompts by workflow phase | Prompt library |

### Model Aliases

| Alias | Resolves to |
|-------|------------|
| `default` | Current default model |
| `best` | Most capable available model |
| `sonnet` | Latest Claude Sonnet |
| `opus` | Latest Claude Opus |
| `haiku` | Latest Claude Haiku |
| `sonnet[1m]` | Sonnet with 1M-token extended context |
| `opus[1m]` | Opus with 1M-token extended context |
| `opusplan` | Opus with extended thinking enabled |

Set via `CLAUDE_MODEL` env var, `model` setting, or `--model` CLI flag. Override sub-model slots (subagents, background sessions, etc.) with `modelOverrides`.

### Effort Levels

| Level | Behavior |
|-------|---------|
| `low` | Minimal reasoning, fastest |
| `medium` | Balanced (default) |
| `high` | More thorough reasoning |
| `xhigh` | Extended thinking |
| `max` | Maximum available thinking budget |

Set per-session with `--effort <level>` or the `effort` setting.

### Fast Mode

- Activates the fast variant of Opus (~2.5x faster response time)
- Pricing: $30 input / $150 output per MTok (vs standard Opus rates)
- Toggle with `/fast` during a session; falls back gracefully on rate limits
- Enable by default with `fast: true` in settings; opt out per-session with `/fast off`

### Output Styles (Built-in)

| Style | Behavior |
|-------|---------|
| `Default` | Standard balanced responses |
| `Proactive` | Adds unsolicited suggestions and related notes |
| `Explanatory` | Verbose, educational, step-by-step commentary |
| `Learning` | Teaches concepts; adds quizzes and references |

Custom styles defined in plugin/skill frontmatter via `output-style`, `keep-coding-instructions`, and `force-for-plugin` fields.

### Status Line JSON Fields

| Field | Description |
|-------|------------|
| `model` | Active model name |
| `context_window` | Tokens used / total available |
| `cost` | Cumulative session cost |
| `rate_limits` | Current rate-limit headroom |
| `workspace` | Active workspace path |
| `vim` | Vim mode indicator |
| `pr` | Current PR branch/number |
| `worktree` | Active worktree name |

Configure the shell prompt integration by running the output of `claude --status-line-script` in your shell init. Use `subagentStatusLine` to show a different format inside subagent sessions.

### Checkpointing

Automatic checkpoint is saved before each prompt is executed.

| `/rewind` Option | Effect |
|-----------------|--------|
| Restore code | Roll back file edits; keep conversation |
| Restore conversation | Roll back conversation; keep file edits |
| Restore both | Full rollback to pre-prompt state |
| Summarize from here | Compact forward from this point |
| Summarize up to here | Compact up to this point |

Note: bash command side-effects (installed packages, server state) are not tracked by checkpointing.

### Scheduling Options Comparison

| Approach | Where | Trigger | Persistence |
|----------|-------|---------|-------------|
| `/loop` | CLI session | Fixed interval or dynamic | Session lifetime; 7-day expiry |
| Desktop Routines | Desktop app | Schedule or manual | Local; stored in `~/.claude/scheduled-tasks/` |
| Cloud Routines | Anthropic infra | Schedule / API `/fire` / GitHub events | Cloud; survives local machine off |

### Voice Dictation Modes

| Mode | Activation | Behavior |
|------|-----------|---------|
| Hold (push-to-talk) | Hold Space | Records while held; submits on release |
| Tap | Tap Space | Toggle record on/off; `autoSubmit` optional |

Start with `/voice`. Supports 20 languages. Rebind the key with `voice:pushToTalk` in keybindings settings.

### Channels Setup (Quick Path)

1. Install a channel plugin (Telegram, Discord, or iMessage)
2. Run `/channels connect` to pair the sender
3. Add sender ID to allowlist for security
4. Use `channelsEnabled` / `allowedChannelPlugins` in enterprise settings to restrict

### Prompt Cache Invalidation

**Invalidates cache:**
- Switching models
- Connecting/disconnecting an MCP server
- Denying a tool permission
- Running `/compact`
- Upgrading Claude Code

**Preserves cache:**
- Editing files mid-session
- Editing CLAUDE.md mid-session
- Changing output style
- Invoking a skill

TTL: 5 minutes by default; 1 hour on subscription plans. Set `ENABLE_PROMPT_CACHING_1H=1` env var to force 1-hour TTL.

### Agent Parallelism Comparison

| Approach | Coordination | File Isolation | Use When |
|----------|-------------|---------------|---------|
| Subagents | Parent session | Optional (worktree) | Side task floods main conversation |
| Agent view | You | Auto worktree | Independent tasks, check back later |
| Agent teams | Lead agent | Manual partitioning | Claude plans and assigns a project |
| Worktrees | You | Per worktree | Multiple sessions touching same files |
| `/batch` | Automatic | Per-worktree + PR | Repo-wide migration / mechanical refactor |

### Worktree Quick Reference

```bash
# Start session in new isolated worktree
claude --worktree feature-auth

# Branch from specific PR
claude --worktree "#1234"

# Let Claude generate a name
claude --worktree

# Subagent isolation (frontmatter)
# isolation: worktree
```

Base branch: `origin/HEAD` by default. Set `worktree.baseRef: "head"` to branch from local HEAD instead.

Copy gitignored files (e.g. `.env`) into new worktrees by listing them in `.worktreeinclude`.

### Agent View Commands

| Action | How |
|--------|-----|
| Open agent view | `claude agents` |
| Dispatch new session | `d` in agent view |
| Peek at session output | Arrow keys / Enter |
| Attach to session | `←` (left arrow) |
| Detach from session | `Ctrl+D` or `Ctrl+Z` |
| View session logs | `claude logs <id>` |
| Stop a session | `claude stop <id>` |
| Remove a session | `claude rm <id>` |

Background sessions automatically get their own worktree when they need to edit files (`worktree.bgIsolation` setting).

### Deep Link URL Parameters

Scheme: `claude-cli://open`

| Parameter | Description |
|-----------|------------|
| `q` | Prompt text to pre-fill |
| `cwd` | Working directory to open |
| `repo` | GitHub repo to clone and open |

### Fullscreen TUI

- Enter: `/tui fullscreen` or launch with `CLAUDE_CODE_NO_FLICKER=1`
- Mouse: click, drag, scroll wheel supported
- Disable mouse: `CLAUDE_CODE_DISABLE_MOUSE=1`
- Transcript mode: `Ctrl+O` (copies conversation as plain text)
- Search: `/` key
- Tmux note: mouse passthrough requires `set -g mouse on` in tmux config

### Context Window

- Load order: system prompt → memory files → CLAUDE.md hierarchy → skills → conversation history
- Use `/context` to inspect current token usage breakdown
- Use `/memory` to manage persistent memory entries
- After `/compact`, the summary survives; full history is replaced

### Prompt Library

50+ curated prompts organized by SDLC phase:

| Phase | Examples |
|-------|---------|
| Discover | Understand codebase, map dependencies, find bottlenecks |
| Design | Draft architecture, create API contracts, spec features |
| Build | Implement features, refactor, write tests |
| Ship | Review PRs, write changelogs, prepare releases |
| Operate | Debug incidents, monitor patterns, write runbooks |

Prompt patterns: describe the outcome (not steps), give a reference example, state a measurable target.

## Full Documentation

- **[features-overview](references/claude-code-features-overview.md)** — Extension layer taxonomy (CLAUDE.md, Skills, Subagents, MCP, Hooks, Plugins) with comparison tables and context-cost breakdown
- **[fast-mode](references/claude-code-fast-mode.md)** — Fast Opus variant: 2.5x speed, pricing, `/fast` toggle, settings, and rate-limit fallback
- **[model-config](references/claude-code-model-config.md)** — Model aliases, effort levels, extended context (1M), env vars, `modelOverrides`, `availableModels`
- **[output-styles](references/claude-code-output-styles.md)** — Four built-in styles, custom style frontmatter fields, `keep-coding-instructions`, `force-for-plugin`
- **[statusline](references/claude-code-statusline.md)** — Shell prompt integration, JSON data fields, `subagentStatusLine`, update triggers, example configs
- **[checkpointing](references/claude-code-checkpointing.md)** — Automatic per-prompt checkpoints, `/rewind` menu options, limitations (bash side-effects not tracked)
- **[remote-control](references/claude-code-remote-control.md)** — `claude remote-control` server mode, `--remote-control` flag, `/remote-control` command, spawn modes, mobile push notifications
- **[scheduled-tasks](references/claude-code-scheduled-tasks.md)** — `/loop` with fixed or dynamic intervals, built-in maintenance prompt, `loop.md` customization, CronCreate/List/Delete tools, 7-day expiry, jitter rules
- **[voice-dictation](references/claude-code-voice-dictation.md)** — Hold (push-to-talk) and tap modes, `/voice` command, 20 supported languages, keybinding config, `autoSubmit` setting
- **[channels](references/claude-code-channels.md)** — Telegram/Discord/iMessage plugin setup, `fakechat` quickstart, sender allowlist/pairing, enterprise controls
- **[channels-reference](references/claude-code-channels-reference.md)** — MCP server channel contract: `claude/channel` capability, notification format, reply tools, sender gating, permission relay
- **[desktop-scheduled-tasks](references/claude-code-desktop-scheduled-tasks.md)** — Desktop app Routines page, local schedule options, missed-run catch-up, permission management, task storage location
- **[context-window](references/claude-code-context-window.md)** — Context loading order, what survives compaction, `/context` and `/memory` commands
- **[fullscreen](references/claude-code-fullscreen.md)** — `/tui fullscreen`, `CLAUDE_CODE_NO_FLICKER`, mouse support, transcript mode (Ctrl+O), search, tmux caveats
- **[routines](references/claude-code-routines.md)** — Cloud Routines on Anthropic infra: schedule/API/GitHub triggers, `/schedule` CLI, `allowedChannelPlugins`, API `/fire` endpoint, GitHub event filters, daily run cap
- **[deep-links](references/claude-code-deep-links.md)** — `claude-cli://open` URL scheme, `q`/`cwd`/`repo` parameters, OS registration paths, terminal emulator detection
- **[agent-view](references/claude-code-agent-view.md)** — `claude agents` command, background sessions, supervisor process, state icons, peek panel, attach/detach, dispatch methods, shell commands, `worktree.bgIsolation`
- **[agents](references/claude-code-agents.md)** — Comparison of subagents vs agent view vs agent teams vs worktrees vs `/batch`; guidance on coordination and file conflicts
- **[worktrees](references/claude-code-worktrees.md)** — `--worktree`/`-w` flag, `.claude/worktrees/` location, base branch config, `.worktreeinclude`, subagent isolation, cleanup behavior, non-git VCS hooks
- **[prompt-caching](references/claude-code-prompt-caching.md)** — Cache invalidation vs cache-preserving actions, TTL (5 min / 1 hour), `ENABLE_PROMPT_CACHING_1H`, cache scope
- **[prompt-library](references/claude-code-prompt-library.md)** — 50+ prompts by SDLC phase (Discover/Design/Build/Ship/Operate), prompt writing patterns

## Sources

- https://code.claude.com/docs/en/fast-mode.md
- https://code.claude.com/docs/en/model-config.md
- https://code.claude.com/docs/en/output-styles.md
- https://code.claude.com/docs/en/statusline.md
- https://code.claude.com/docs/en/checkpointing.md
- https://code.claude.com/docs/en/features-overview.md
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
