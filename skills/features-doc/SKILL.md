---
name: features-doc
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features — model configuration, output styles, fast mode, parallel agents, worktrees, checkpointing, remote control, scheduling, voice, channels, prompt caching, the advisor tool, and more.

## Quick Reference

### Parallelization Approaches

| Approach | What it gives you | Use it when |
| :--- | :--- | :--- |
| Subagents | Delegated workers in one session; return summaries | Side tasks would flood the main conversation |
| Agent view (`claude agents`) | Dispatch and monitor background sessions | Several independent tasks; check back later |
| Agent teams | Coordinated sessions with shared task list (experimental, disabled by default) | Claude should split, assign, and supervise work |
| Dynamic workflows | Script-driven many-subagent orchestration | Job outgrows a handful of subagents; need cross-checking |

### Model Aliases

| Alias | Model |
| :--- | :--- |
| `default` / `sonnet` | Claude Sonnet 4.6 |
| `best` / `fable` | Fable 5 (most capable; not default) |
| `opus` | Claude Opus 4.8 |
| `haiku` | Claude Haiku 4.5 |
| `sonnet[1m]` / `opus[1m]` | 1M token context window variants |
| `opusplan` | Opus 4.8 for plan mode; switches to Sonnet for execution |

Set with `/model <alias>`, `--model`, `ANTHROPIC_MODEL` env var, or `"model"` in settings.

### Effort Levels

| Level | Notes |
| :--- | :--- |
| `low` / `medium` / `high` / `xhigh` / `max` / `ultracode` | Session-only; not persisted |
| Default on Fable 5, Opus 4.8, Opus 4.6, Sonnet 4.6 | `high` |
| Default on Opus 4.7 | `xhigh` |

### Fast Mode

Applies to Opus models only (Opus 4.8, 4.7, 4.6). Up to 2.5x faster at higher cost. Toggle with `/fast` or set `"fastMode": true` in settings. Requires usage credits; Team/Enterprise admins must enable it. Per-session opt-in: `"fastModePerSessionOptIn": true`.

| Model | Input | Output |
| :--- | :--- | :--- |
| Opus 4.8 (fast) | $10/MTok | $50/MTok |
| Opus 4.7/4.6 (fast) | $30/MTok | $150/MTok |

### Output Styles

| Style | Behavior |
| :--- | :--- |
| Default | Balanced responses |
| Proactive | More suggestions and next steps |
| Explanatory | Detailed explanations |
| Learning | Teaching-oriented with context |

Change via `/config` → Output style, or set `"outputStyle": "Explanatory"` in settings. Custom styles: Markdown file in `~/.claude/output-styles` or `.claude/output-styles`. Takes effect after `/clear` or new session.

### Advisor Tool

Pairs a stronger advisor model that Claude consults at decision points (before committing to an approach, on recurring errors, before declaring done). Requires v2.1.98+, Anthropic API only.

| Approach | When stronger model runs |
| :--- | :--- |
| Advisor tool | At decision points mid-task (Claude decides) |
| `opusplan` | During plan mode only |
| Subagent with `model` set | For the entire delegated subtask |
| `/model` switch | All subsequent turns |

Enable: `/advisor opus`, `--advisor opus`, or `"advisorModel": "opus"` in settings. Disable: `/advisor off`.

Accepted advisor pairings: Haiku/Sonnet main → Fable/Opus/Sonnet advisor; Opus main → Fable or Opus at same or higher version; Fable main → Fable only.

### Status Line Key Fields

Configure with `"statusLine": {"type": "command", "command": "..."}` in settings. Shell script receives JSON on stdin; prints display string. Use `/statusline` command for AI-generated setup.

Key JSON fields: `model.id`, `model.display_name`, `workspace.current_dir`, `workspace.project_dir`, `cost.total_cost_usd`, `context_window.used_percentage`, `effort.level`, `thinking.enabled`, `rate_limits.five_hour`, `rate_limits.seven_day`, `session_id`, `vim.mode`, `pr.number`, `worktree.*`

### Worktrees

| Operation | Command |
| :--- | :--- |
| Start Claude in new worktree | `claude --worktree <name>` or `-w` |
| Branch from PR | `claude --worktree "#1234"` |
| Auto-generate name | `claude --worktree` (no name) |
| Base branch config | `"worktree": {"baseRef": "head"}` in settings (default: `origin/HEAD`) |
| Copy gitignored files | `.worktreeinclude` file in project root |
| Subagent isolation | `isolation: worktree` in subagent frontmatter |
| Non-git VCS | `WorktreeCreate` / `WorktreeRemove` hooks |

Default location: `.claude/worktrees/<name>/` on branch `worktree-<name>`.

### Checkpointing

Automatic tracking of file edits before each user prompt. Open rewind menu with `/rewind` or double-Esc on empty prompt. Actions: Restore code and conversation, Restore conversation only, Restore code only, Summarize from here, Summarize up to here. Bash command changes and external changes are not tracked. 30-day cleanup (configurable).

### Prompt Caching

Cache layers: system prompt → project context (CLAUDE.md/memory/rules) → conversation.

**Invalidates cache:** switching models, changing effort level, turning on fast mode, connecting/disconnecting MCP server with non-deferred tools, enabling/disabling plugin with MCP servers, denying an entire tool, compacting, upgrading Claude Code.

**Preserves cache:** editing repo files, editing CLAUDE.md mid-session, changing output style, changing permission mode (except opusplan), invoking skills/commands, `/recap`, rewinding.

TTL: 1-hour on subscriptions (auto), 5-minute on API key (default). Set `ENABLE_PROMPT_CACHING_1H=1` to opt into 1-hour TTL on API. Subagents have their own cache with 5-minute TTL even on subscription.

### Scheduling Options

| | Cloud routines | Desktop scheduled tasks | `/loop` in session |
| :--- | :--- | :--- | :--- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Minimum interval | 1 hour | 1 minute | 1 minute |
| Access to local files | No (fresh clone) | Yes | Yes |

**Session-scoped (`/loop`):** interval+prompt, prompt-only (Claude picks interval), or neither (built-in maintenance). Max 50 tasks/session. Tools: `CronCreate`, `CronList`, `CronDelete`. 7-day expiry on recurring tasks.

**Desktop tasks:** Sidebar → Routines → New routine → Local. Presets: Manual, Hourly, Daily, Weekdays, Weekly. Missed runs: one catch-up run on wake.

**Cloud routines:** Create at claude.ai/code/routines or `/schedule`. Triggers: scheduled (min 1hr), API (HTTP POST), GitHub events.

### Remote Control

Continue local CLI sessions from claude.ai/code or Claude mobile app. Requires v2.1.51+, research preview.

| Mode | Command |
| :--- | :--- |
| Server mode | `claude remote-control` |
| Interactive with remote control | `claude --remote-control` |
| From existing session | `/remote-control` |

`--spawn` flag: `same-dir`, `worktree`, or `session`. Outbound HTTPS only; no inbound ports. Mobile push notifications require v2.1.110+.

### Voice Dictation

Enable: `/voice`, `/voice hold`, `/voice tap`, `/voice off`. Requires claude.ai account (not API key/Bedrock/Vertex/Foundry).

- **Hold mode:** hold Space, warmup then live transcription, release to finalize
- **Tap mode:** tap once to start, tap again to send (v2.1.116+)
- `"autoSubmit": true` in voice settings to auto-send on release
- Dictation language from `"language"` setting; 20 supported languages
- Rebind via `voice:pushToTalk` action in `~/.claude/keybindings.json`

### Deep Links

`claude-cli://open` URL scheme launches local Claude Code sessions.

| Parameter | Description |
| :--- | :--- |
| `q` | Prompt text (URL-encoded, max 5000 chars) |
| `cwd` | Absolute path (takes precedence over `repo`) |
| `repo` | GitHub `owner/name` slug |

Prompt is pre-filled but NOT auto-sent; shows "Prompt from an external link" warning. Handler registered automatically on first interactive session. VS Code uses `vscode://anthropic.claude-code/open` instead. GitHub-rendered Markdown strips `claude-cli://` — use code blocks. Disable: `"disableDeepLinkRegistration": "disable"` in settings.

### Channels (Research Preview)

MCP servers that push events into running Claude Code sessions. Requires v2.1.80+, Anthropic auth only. Supported: Telegram, Discord, iMessage (via official plugins).

Install: `/plugin install <channel>@claude-plugins-official`. Start: `claude --channels plugin:<name>@claude-plugins-official`. Enterprise: `channelsEnabled` and `allowedChannelPlugins` in managed settings.

**Building custom channels:**
- Declare `capabilities: { experimental: { 'claude/channel': {} } }` in MCP Server constructor
- Emit `notifications/claude/channel` with `content` (string) and optional `meta` (Record<string, string>)
- For two-way: add `capabilities.tools` and a reply tool
- For permission relay: add `capabilities.experimental['claude/channel/permission']` and handle `notifications/claude/channel/permission_request`
- Gate inbound on sender identity, not room/chat identity
- Test with `--dangerously-load-development-channels server:<name>`

### Fullscreen Rendering

Enable: `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1`. Mouse support: click to position cursor, expand tool results, click URLs, click-drag to select. Disable mouse: `CLAUDE_CODE_DISABLE_MOUSE=1`. Search: `Ctrl+O` for transcript mode. `/scroll-speed` command; `CLAUDE_CODE_SCROLL_SPEED` env var. Background sessions always use fullscreen.

### Context Window

What loads: system prompt, auto memory, environment info, MCP tools (deferred), skill descriptions, CLAUDE.md files, user prompts, file reads, path-scoped rules, hook output, subagent summaries.

What survives compaction: system prompt, project-root CLAUDE.md and unscoped rules, auto memory, invoked skill bodies (capped). Lost after compaction: path-scoped rules, nested CLAUDE.md (until re-triggered).

Use `/context` for live breakdown; `/memory` to check loaded files; `/compact focus on X` for targeted compaction.

### Features Overview — Extension Feature Comparison

| Feature | Primary purpose | When to use |
| :--- | :--- | :--- |
| CLAUDE.md | Project instructions | Conventions and context to load every session |
| Skills | Bundled prompts and context | Reusable tasks and domain knowledge |
| Subagents | Parallel workers | Isolate side tasks |
| Agent teams | Coordinated workers | Claude splits and assigns work |
| MCP | Tool connections | Connect Claude to external APIs/data |
| Hooks | Automation triggers | Automatic actions at lifecycle events |

### Prompt Library

Copy-paste prompts organized by SDLC phase and role. Available at code.claude.com/docs/en/prompt-library. Categories: Discover (Onboard, Understand), Design (Plan, Prototype), Build (Implement, Test, Refactor, Review, Steer), Ship (Git, Release), Operate (Debug, Incident, Data, Automate). Roles: developer, PM, design, docs, marketing, security, ops.

Key prompting patterns: describe the outcome not the steps; give it a way to self-verify; point at a reference; state a measurable target; give it the artifact; say how you want the answer.

## Full Documentation

For the complete official documentation, see the reference files:

- [Features overview](references/claude-code-features-overview.md) — Extension feature comparison table, context cost table, feature layering rules
- [Fast mode](references/claude-code-fast-mode.md) — Enable/disable, pricing, supported models, per-session opt-in
- [Model configuration](references/claude-code-model-config.md) — Model aliases, effort levels, extended context, fallback chains, enterprise controls
- [Output styles](references/claude-code-output-styles.md) — Built-in styles, custom styles, frontmatter fields, `force-for-plugin`
- [Status line](references/claude-code-statusline.md) — Configuration, full JSON field reference, subagent row rendering
- [Checkpointing](references/claude-code-checkpointing.md) — Rewind menu, restore actions, limitations
- [Remote control](references/claude-code-remote-control.md) — Server mode, flags, mobile push notifications, limitations
- [Scheduled tasks](references/claude-code-scheduled-tasks.md) — `/loop` skill, CronCreate/List/Delete tools, session-scoped scheduling
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) — Desktop app recurring tasks, schedule options, missed run handling, permission modes
- [Voice dictation](references/claude-code-voice-dictation.md) — Hold vs tap mode, auto-submit, language settings, rebinding
- [Channels](references/claude-code-channels.md) — Install and use Telegram/Discord/iMessage, enterprise controls, research preview
- [Channels reference](references/claude-code-channels-reference.md) — Build custom channel servers, notification format, reply tools, sender gating, permission relay
- [Context window](references/claude-code-context-window.md) — What loads, what survives compaction, `/context` and `/memory` commands
- [Fullscreen](references/claude-code-fullscreen.md) — Alternate screen buffer, mouse support, search, scroll speed
- [Routines](references/claude-code-routines.md) — Cloud-based automation, triggers (scheduled/API/GitHub), branch push policy
- [Deep links](references/claude-code-deep-links.md) — `claude-cli://open` URL scheme, parameters, platform registration
- [Agent view](references/claude-code-agent-view.md) — `claude agents` command, session states, peek panel, dispatch, file isolation
- [Run agents in parallel](references/claude-code-agents.md) — Comparison of subagents, agent view, agent teams, dynamic workflows
- [Worktrees](references/claude-code-worktrees.md) — `--worktree` flag, base branch, `.worktreeinclude`, subagent isolation, cleanup
- [Prompt caching](references/claude-code-prompt-caching.md) — Cache layers, what invalidates/preserves cache, TTL, subagent behavior
- [Prompt library](references/claude-code-prompt-library.md) — Copy-paste prompts by phase and role, prompting patterns
- [Advisor tool](references/claude-code-advisor.md) — Enable/configure, model pairings, cost, comparison with opusplan and subagents

## Sources

- Features overview: https://code.claude.com/docs/en/features-overview.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks: https://code.claude.com/docs/en/scheduled-tasks.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Context window: https://code.claude.com/docs/en/context-window.md
- Fullscreen: https://code.claude.com/docs/en/fullscreen.md
- Routines: https://code.claude.com/docs/en/routines.md
- Deep links: https://code.claude.com/docs/en/deep-links.md
- Agent view: https://code.claude.com/docs/en/agent-view.md
- Run agents in parallel: https://code.claude.com/docs/en/agents.md
- Worktrees: https://code.claude.com/docs/en/worktrees.md
- Prompt caching: https://code.claude.com/docs/en/prompt-caching.md
- Prompt library: https://code.claude.com/docs/en/prompt-library.md
- Advisor tool: https://code.claude.com/docs/en/advisor.md
