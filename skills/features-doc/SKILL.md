---
name: features-doc
user-invocable: false
---
# Features Documentation

This skill covers Claude Code's extended feature set: model configuration, performance modes, UI customization, session management, automation, parallel execution, and context management. Use it to answer questions about specific features, configuration options, commands, and how features interact.

## Quick Reference

### Model Configuration

| Alias | Model tier | Notes |
|-------|-----------|-------|
| `default` | Current default | Changes each release |
| `best` / `fable` | Fable 5 | Most capable; requires v2.1.170+ and Fable 5 access |
| `opus` | Opus | Strong reasoning |
| `sonnet` | Sonnet | Balanced speed/capability |
| `haiku` | Haiku | Fastest, lowest cost |
| `sonnet[1m]` / `opus[1m]` | Extended context | 1M token context window |
| `opusplan` | Opus for plan mode, Sonnet for execution | Hybrid cost/quality |

Set model: `/model <alias>` or `"model": "<alias>"` in settings.

**Effort levels:** `low` `medium` `high` `xhigh` `max` — plus `ultracode` for maximum output token allocation. Set via `/effort <level>`.

**Env vars:** `ANTHROPIC_DEFAULT_FABLE_MODEL`, `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL`, `CLAUDE_CODE_SUBAGENT_MODEL`

**Settings:** `availableModels` (list), `enforceAvailableModels` (bool), fallback model chains in settings.

### Fast Mode (Opus only)

- Up to 2.5× faster responses, higher token cost
- Toggle: `/fast` (in-session) or `fastModePerSessionOptIn: true` (per-session opt-in)
- Active indicator: `↯` icon in statusline
- Pricing: Opus 4.8 $10/$50 MTok; Opus 4.7/4.6 $30/$150 MTok
- Requires Anthropic API or subscription (not Bedrock/Vertex/Foundry)

### Advisor Tool

| Main model | Accepted advisors |
|-----------|------------------|
| Haiku 4.5 | Fable, Opus, Sonnet |
| Sonnet 4.6 | Fable, Opus, Sonnet |
| Opus 4.6+ | Fable, Opus (same or higher version) |
| Fable 5 | Fable only |

Enable: `/advisor opus`, `--advisor opus`, or `"advisorModel": "opus"` in settings.
Disable: `/advisor off` or `CLAUDE_CODE_DISABLE_ADVISOR_TOOL=1`
- Shows "Advising" in transcript; press `Ctrl+O` to expand guidance
- Does NOT invalidate prompt cache when toggled mid-session
- Each advisor call sends full conversation; no caching between advisor calls
- Requires v2.1.98+; Anthropic API only (not Bedrock/Vertex/Foundry)

### Output Styles

| Style | Behavior |
|-------|----------|
| Default | Balanced responses |
| Proactive | More initiative, fewer confirmations |
| Explanatory | Detailed rationale with each action |
| Learning | Teaching-oriented explanations |

Set: `/config` → Output style, or `"outputStyle": "<name>"` in settings.

**Custom styles:** Markdown file in `~/.claude/output-styles/` (global) or `.claude/output-styles/` (project).
Frontmatter fields: `name`, `description`, `keep-coding-instructions`, `force-for-plugin`.

### Status Line

Configure a shell script receiving JSON via stdin:
```json
{ "statusLine": { "type": "command", "command": "<your-script>" } }
```
Available JSON fields: `model`, `workspace`, `cost`, `context_window`, `effort`, `thinking`, `rate_limits`, `session_id`, `vim`, `pr`, `worktree`, and more.
Generate starter scripts: `/statusline`
Subagent panel rows: `subagentStatusLine` setting.

### Context Window

**Loads at startup:** system prompt, auto memory, environment info, MCP tool schemas, skill descriptions, CLAUDE.md files.

**Survives compaction:**

| Item | Survives? |
|------|-----------|
| System prompt + output style | Yes (unchanged) |
| Project-root CLAUDE.md | Yes (re-injected) |
| Auto memory | Yes (re-injected) |
| Invoked skill bodies | Yes (re-injected, capped 5K/skill, 25K total) |
| Path-scoped rules | No (lost until file re-read) |
| Nested CLAUDE.md files | No (lost until re-read) |

Commands: `/context` (visualization), `/memory` (manage memory).

### Prompt Caching

Cache layers (innermost to outermost): system prompt → project context (CLAUDE.md, memory, rules) → conversation.

**Invalidates cache:**
- Switching model or effort level
- Enabling fast mode (first time in session)
- Connecting/disconnecting MCP server
- Enabling/disabling plugin with MCP
- Denying entire tool, compacting, upgrading Claude Code

**Keeps cache intact:**
- Editing repo files, editing CLAUDE.md mid-session
- Changing output style or permission mode
- Invoking skills, `/recap`, `/rewind`
- Toggling `/advisor` on/off

TTL: 1 hour (subscriptions), 5 minutes (API).
Env vars: `ENABLE_PROMPT_CACHING_1H=1`, `DISABLE_PROMPT_CACHING`, `FORCE_PROMPT_CACHING_5M=1`

### Checkpointing and Rewind

- Auto-tracks file state before each edit (not bash commands)
- Open rewind menu: `/rewind` or double-Esc
- Options: Restore code+conversation | Restore conversation only | Restore code only | Summarize from here | Summarize up to here
- Not a replacement for git — bash-modified files are not tracked

### Voice Dictation

- Enable: `/voice` (hold Space to dictate by default)
- Tap mode: `/voice tap`
- Setting: `{"voice": {"enabled": true, "mode": "tap"}}`
- Keybinding: `voice:pushToTalk`
- Requires claude.ai account; streams audio to Anthropic servers
- Not available with API keys, Bedrock, Vertex, or Foundry

### Fullscreen TUI

- Enter: `/tui fullscreen` or set `CLAUDE_CODE_NO_FLICKER=1`
- Alternate screen buffer (like vim/htop); fixed input box at bottom
- Mouse support enabled; `Ctrl+O` for transcript mode
- Configure via `tui` key in settings.json

### Deep Links

- URL scheme: `claude-cli://open`
- Parameters: `dir` (working directory), `prompt` (pre-filled text)
- Prompt is shown but not sent until user presses Enter
- Requires v2.1.91+; GitHub strips non-http(s) schemes in markdown

### Remote Control

- Continue local sessions from any device
- Start server: `claude remote-control`
- Attach interactively: `claude --remote-control`
- From existing session: `/remote-control`
- Connect via URL, QR code, or claude.ai/code
- Supports mobile push notifications
- Requires claude.ai subscription (not API keys)

### Channels (Event-Driven Messaging)

Supported platforms: Telegram, Discord, iMessage.
Launch: `claude --channels plugin:telegram@claude-plugins-official`
- Configure sender allowlists for security
- Enterprise settings: `channelsEnabled`, `allowedChannelPlugins`
- Build custom channel MCP servers: declare `claude/channel` capability, emit `notifications/claude/channel` events

### Scheduled Tasks and Loops

**`/loop` skill:**
- `/loop 5m check deploy` — fixed interval
- `/loop check deploy` — dynamic interval (Claude decides timing)
- `/loop` — built-in maintenance prompt
- Underlying tools: `CronCreate`, `CronList`, `CronDelete`
- 7-day expiry; customize default with `loop.md` in project
- Disable: `CLAUDE_CODE_DISABLE_CRON=1`

**Desktop scheduled tasks (desktop app only):**
Routines page → New routine → Local. Fields: Name, Description, Instructions (with permission mode/model pickers), Schedule, Folder. Optionally enable worktree isolation. Runs while app is open and machine awake.

### Routines (Cloud-Hosted Automation)

Saved Claude Code configs running on Anthropic cloud infrastructure.

| Trigger | Details |
|---------|---------|
| Scheduled | Minimum 1-hour interval |
| API | POST to `/fire` endpoint |
| GitHub | PR or release events |

Create at claude.ai/code/routines or `/schedule` CLI.
Commands: `/schedule list`, `/schedule update`, `/schedule run`
Runs autonomously without permission prompts.

### Agent View

Open: `claude agents` command.

| State | Meaning |
|-------|---------|
| working (`✻`/`✽`) | Actively running |
| needs input | Waiting for user |
| idle (`∙`) | Process exited |
| sleeping (`✢`) | Loop between iterations |
| completed / failed / stopped | Terminal states |

Actions: Space (peek panel), Enter/→ (attach), ← (detach/background).
Labels: `PR #N` for sessions linked to a pull request.

From shell: `claude --bg "prompt"` launches background session.
From session: `/bg` or `←` to background current session.
Subcommands: `claude attach/logs/stop/rm/respawn <id>`
Each background session runs in its own worktree automatically.

### Parallel Execution Approaches

| Approach | Coordinator | File isolation | Use when |
|----------|-------------|---------------|----------|
| Subagents | Claude (inline) | Optional worktree per agent | Side task would flood main context |
| Agent view | You | Auto worktree per session | Independent tasks; hand off and check back |
| Agent teams | Claude (lead+workers) | Not automatic — partition files manually | Claude should split, assign, supervise |
| Dynamic workflows | Script | Per-subagent | Job too big for a handful of subagents |
| `/batch` skill | Claude | Worktree per subagent | 5–30 parallel PRs for one large change |

### Worktrees

Create isolated session: `claude --worktree <name>` (creates `.claude/worktrees/<name>/` on branch `worktree-<name>`)

| Option | Command/Setting |
|--------|----------------|
| Omit name (auto-generate) | `claude --worktree` |
| Branch from local HEAD | `"worktree": {"baseRef": "head"}` in settings |
| Branch from PR | `claude --worktree "#1234"` |
| Copy gitignored files | `.worktreeinclude` in project root |
| Isolate subagent | `isolation: worktree` in subagent frontmatter |
| Non-git VCS | `WorktreeCreate` / `WorktreeRemove` hooks |

Add `.claude/worktrees/` to `.gitignore` to keep untracked files out of main checkout.
Cleanup: automatic when no changes; prompted when changes exist.

### Prompt Library

~50 copy-paste prompts organized by SDLC phase:

| Phase | Categories |
|-------|-----------|
| Discover | Onboard, Understand |
| Design | Plan, Prototype |
| Build | Implement, Test, Refactor, Review |
| Ship | Steer, Git, Release |
| Operate | Debug, Incident, Data, Automate |

Key prompt patterns: describe outcome not steps · give Claude a way to check its work · point at a reference implementation · state a measurable target · hand over the artifact · say how you want the answer delivered.

## Full Documentation

- [claude-code-features-overview.md](references/claude-code-features-overview.md) — Overview of all Claude Code extension types with feature and context-cost comparison tables
- [claude-code-model-config.md](references/claude-code-model-config.md) — Model aliases, effort levels, extended context, `opusplan`, fallback chains, env vars, and settings
- [claude-code-fast-mode.md](references/claude-code-fast-mode.md) — Opus-only fast mode: enabling, pricing, and per-session opt-in
- [claude-code-advisor.md](references/claude-code-advisor.md) — Advisor tool: pairing rules, enable/disable, cost, prompt cache behavior, and comparison with related features
- [claude-code-output-styles.md](references/claude-code-output-styles.md) — Built-in and custom output styles, frontmatter fields, and setting location
- [claude-code-statusline.md](references/claude-code-statusline.md) — Status line shell script configuration, available JSON data fields, and subagent row setting
- [claude-code-context-window.md](references/claude-code-context-window.md) — Interactive context visualization, startup content, and what survives compaction
- [claude-code-prompt-caching.md](references/claude-code-prompt-caching.md) — Cache layer structure, what invalidates vs. keeps the cache, TTL, and env var overrides
- [claude-code-checkpointing.md](references/claude-code-checkpointing.md) — Automatic file checkpointing, rewind menu options, and limitations
- [claude-code-voice-dictation.md](references/claude-code-voice-dictation.md) — Voice dictation modes, keybindings, settings, and platform requirements
- [claude-code-fullscreen.md](references/claude-code-fullscreen.md) — Fullscreen TUI mode, mouse support, and transcript view
- [claude-code-deep-links.md](references/claude-code-deep-links.md) — `claude-cli://open` URL scheme parameters and version requirements
- [claude-code-remote-control.md](references/claude-code-remote-control.md) — Continuing local sessions from remote devices and push notifications
- [claude-code-channels.md](references/claude-code-channels.md) — Telegram/Discord/iMessage channel integration and enterprise settings
- [claude-code-channels-reference.md](references/claude-code-channels-reference.md) — Building custom channel MCP servers with the `claude/channel` capability
- [claude-code-scheduled-tasks.md](references/claude-code-scheduled-tasks.md) — `/loop` skill, cron tools, and disabling scheduled tasks
- [claude-code-desktop-scheduled-tasks.md](references/claude-code-desktop-scheduled-tasks.md) — Desktop app local routines: schedule, folder, and worktree isolation options
- [claude-code-routines.md](references/claude-code-routines.md) — Cloud-hosted routines: scheduled, API-triggered, and GitHub-triggered automation
- [claude-code-agent-view.md](references/claude-code-agent-view.md) — `claude agents` command, session states, keyboard navigation, and background session management
- [claude-code-agents.md](references/claude-code-agents.md) — Comparison of parallel approaches: subagents, agent view, agent teams, and dynamic workflows
- [claude-code-worktrees.md](references/claude-code-worktrees.md) — Worktree creation, base branch configuration, `.worktreeinclude`, subagent isolation, and cleanup
- [claude-code-prompt-library.md](references/claude-code-prompt-library.md) — Interactive ~50-prompt library organized by SDLC phase and effective prompting patterns

## Sources

- https://code.claude.com/docs/en/features-overview.md
- https://code.claude.com/docs/en/model-config.md
- https://code.claude.com/docs/en/fast-mode.md
- https://code.claude.com/docs/en/advisor.md
- https://code.claude.com/docs/en/output-styles.md
- https://code.claude.com/docs/en/statusline.md
- https://code.claude.com/docs/en/context-window.md
- https://code.claude.com/docs/en/prompt-caching.md
- https://code.claude.com/docs/en/checkpointing.md
- https://code.claude.com/docs/en/voice-dictation.md
- https://code.claude.com/docs/en/fullscreen.md
- https://code.claude.com/docs/en/deep-links.md
- https://code.claude.com/docs/en/remote-control.md
- https://code.claude.com/docs/en/channels.md
- https://code.claude.com/docs/en/channels-reference.md
- https://code.claude.com/docs/en/scheduled-tasks.md
- https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- https://code.claude.com/docs/en/routines.md
- https://code.claude.com/docs/en/agent-view.md
- https://code.claude.com/docs/en/agents.md
- https://code.claude.com/docs/en/worktrees.md
- https://code.claude.com/docs/en/prompt-library.md
