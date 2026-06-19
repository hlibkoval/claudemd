---
name: features-doc
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features — model configuration, fast mode, output styles, status line, checkpointing, voice dictation, remote control, scheduled tasks, channels, agent view, worktrees, prompt caching, artifacts, advisor, deep links, routines, fullscreen TUI, prompt library, and the extension overview.

## Quick Reference

### Extension Features Overview

| Feature | What it does | Best for |
| :--- | :--- | :--- |
| **CLAUDE.md** | Persistent context loaded every session | Project conventions, "always do X" rules |
| **Skills** | Instructions, knowledge, workflows Claude can use | Reusable content, reference docs, repeatable tasks |
| **Subagents** | Isolated execution context returning summary | Context isolation, parallel tasks |
| **Agent teams** | Coordinate multiple independent Claude Code sessions | Parallel research, competing hypotheses |
| **Code intelligence** | Language-server navigation and diagnostics | Typed languages, large codebases |
| **MCP** | Connect to external services | External data or actions |
| **Hooks** | Script/HTTP/prompt/subagent triggered by events | Automation that must run on every matching event |
| **Artifacts** | Publish session output as private interactive web page | Output to see or share visually |
| **Plugins** | Bundle skills, hooks, subagents, MCP into one installable unit | Reuse setup across repos, distribute to others |

Feature layering: CLAUDE.md additive; skills/subagents/MCP override by name; hooks merge across all sources.

### Model Aliases

| Alias | Resolves to |
| :--- | :--- |
| `default` | Current default model |
| `best` | Highest-capability available model |
| `fable` | Latest Fable 5 |
| `sonnet` | Latest Sonnet |
| `opus` | Latest Opus |
| `haiku` | Latest Haiku |
| `sonnet[1m]` | Sonnet with 1M context |
| `opus[1m]` | Opus with 1M context |
| `opusplan` | Opus for plan mode, then switches to Sonnet for execution |

### Effort Levels by Model

| Model | Supported levels | Default |
| :--- | :--- | :--- |
| Fable 5 | low / medium / high / xhigh / max | high |
| Opus 4.8 | low / medium / high / xhigh / max | high |
| Opus 4.7 | low / medium / high / xhigh / max | xhigh |
| Opus 4.6 | low / medium / high / max | high |
| Sonnet 4.6 | low / medium / high / max | high |

`ultracode`: sends `xhigh` + orchestrates dynamic workflows; session-only (not saved to settings).
`ultrathink` keyword in prompt triggers one-off deep reasoning.

### Extended Context (1M tokens)

| Models | Availability |
| :--- | :--- |
| Fable 5, Opus 4.8, Opus 4.7 | Always 1M on Anthropic API |
| Sonnet 4.6 / Opus 4.6 with `[1m]` alias | Max, Team, or Enterprise plan |

### Model Environment Variables

| Env var | Controls |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_FABLE_MODEL` | Default Fable model ID |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Default Opus model ID |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Default Sonnet model ID |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Default Haiku model ID |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Default model for spawned subagents |

### Fast Mode (Opus)

| Property | Detail |
| :--- | :--- |
| Toggle | `/fast` command (saved per-session if `fastModePerSessionOptIn: true`) |
| Speed | Up to 2.5x faster than standard Opus |
| Pricing (Opus 4.8) | $10 / $50 per MTok input / output |
| Pricing (Opus 4.7 / 4.6) | $30 / $150 per MTok input / output |
| Rate limits | Separate from standard; auto-fallback to standard on limit |
| Indicator | `↯` icon in status |
| Requirements | v2.1.36+; Anthropic API only; usage credits required |

### Output Styles

| Style | Description |
| :--- | :--- |
| Default | Balanced, task-focused |
| Proactive | Surfaces related observations unprompted |
| Explanatory | Adds context and reasoning |
| Learning | Teaches as it works |

Custom styles: markdown files in `~/.claude/output-styles/` or `.claude/output-styles/`. Frontmatter fields: `name`, `description`, `keep-coding-instructions`, `force-for-plugin`. Change via `/config` → Output style; saved to `outputStyle` setting; takes effect after `/clear` or new session.

### Status Line

Config fields in settings:

| Field | Description |
| :--- | :--- |
| `statusLine.type` | Must be `"command"` |
| `statusLine.command` | Shell script path; reads JSON from stdin, prints to stdout |
| `statusLine.padding` | Optional padding |
| `statusLine.refreshInterval` | Optional refresh interval |
| `statusLine.hideVimModeIndicator` | Hide default vim mode indicator |
| `subagentStatusLine` | Script for agent panel rows |

Key JSON input fields: `model.id/display_name`, `workspace.current_dir/project_dir/added_dirs/git_worktree/repo`, `cost.*`, `context_window.*`, `effort.level`, `thinking.enabled`, `rate_limits.*`, `session_id/name`, `vim.mode`, `pr.*`, `worktree.*`

Use `/statusline` command for auto-generation. Updates after each assistant message, after `/compact`, on permission mode change, on vim mode toggle.

### Checkpointing / Rewind

| Item | Detail |
| :--- | :--- |
| Tracking | Automatic; every user prompt creates a checkpoint |
| Open rewind menu | `/rewind` or double-Esc |
| Options | Restore code and conversation / Restore conversation only / Restore code only / Summarize from here / Summarize up to here |
| Not tracked | Bash command changes; external file changes |

### Voice Dictation

| Command | Behavior |
| :--- | :--- |
| `/voice` | Enable with default mode |
| `/voice hold` | Hold Space to record; release to send |
| `/voice tap` | Tap once to start, tap again to send (v2.1.116+) |
| `/voice off` | Disable |

Requirements: claude.ai account; streams audio to Anthropic servers; not available on Bedrock/Vertex/Foundry or HIPAA orgs. Language set via `language` setting. Dictation key bound to `voice:pushToTalk` in Chat context; rebind in `~/.claude/keybindings.json`.

### Remote Control

| Mode | How to start |
| :--- | :--- |
| Server mode | `claude remote-control` |
| Interactive + remote | `claude --remote-control` |
| From existing session | `/remote-control` |

Flags: `--name`, `--spawn (same-dir/worktree/session)`, `--capacity`, `--verbose`, `--sandbox`. Push notifications available via Claude mobile app (enable in `/config`). Requires claude.ai subscription (Pro/Max/Team/Enterprise); not API key.

### Scheduled Tasks (CLI — `/loop`)

| Configuration | Effect |
| :--- | :--- |
| Interval + prompt | Fixed schedule loop |
| Prompt only | Dynamic interval (Claude decides next run time) |
| Nothing | Built-in maintenance prompt |

Cron tools: `CronCreate`, `CronList`, `CronDelete`. Session-scoped; up to 50 tasks; 7-day expiry. Custom maintenance prompt: `.claude/loop.md` (project) or `~/.claude/loop.md` (user). Disable entirely: `CLAUDE_CODE_DISABLE_CRON=1`.

### Desktop Scheduled Tasks (Routines page)

| Property | Detail |
| :--- | :--- |
| Location | Routines page in desktop app |
| Task types | Local (machine) or Remote (cloud) |
| Schedule options | Manual, Hourly, Daily, Weekdays, Weekly |
| Missed runs | One catch-up run on wake |
| Self-rescheduling | `update_scheduled_task` MCP tool |

### Cloud Routines

| Trigger type | Detail |
| :--- | :--- |
| Schedule | Min 1 hour interval; create at `claude.ai/code/routines` or `/schedule` CLI |
| API | HTTP POST with bearer token |
| GitHub events | PR or Release events |

Runs autonomously (no permission prompts); branches from `claude/` prefix by default. Shell commands: `/schedule list`, `/schedule update`, `/schedule run`. Research preview; requires Pro/Max/Team/Enterprise with Claude Code on the web enabled.

### Channels

Channels let external services push events into a running Claude Code session via MCP.

| Supported channels | Requirement |
| :--- | :--- |
| Telegram, Discord, iMessage | Official plugins; requires Bun |

Enable per session: `--channels plugin:name@marketplace`. Enterprise controls: `channelsEnabled`, `allowedChannelPlugins` in managed settings. Research preview; requires v2.1.80+.

Custom channel MCP capability declaration: `capabilities.experimental['claude/channel']`. Emit `notifications/claude/channel` with `content` (string) and `meta` (Record<string,string>). Permission relay uses `notifications/claude/channel/permission_request` / `notifications/claude/channel/permission` with `{request_id, behavior: 'allow'|'deny'}`.

### Agent View

| Command | Action |
| :--- | :--- |
| `claude agents` | Open agent view (v2.1.139+) |
| `claude attach <id>` | Attach to a session |
| `claude logs <id>` | View session logs |
| `claude stop <id>` | Stop a session |
| `claude rm <id>` | Remove a session |
| `claude daemon status` | Check supervisor daemon |

State icons: working / needs input / idle / completed / failed / stopped. Navigation: `Space` peek, `Enter`/`→` attach, `←` detach. Background sessions run in supervisor process with auto-worktree isolation. Launch flags: `--cwd`, `--model`, `--permission-mode`, `--effort`, `--agent`.

### Parallel Agent Approaches

| Approach | Isolation | Coordination | Best for |
| :--- | :--- | :--- | :--- |
| Subagents | Own context window, returns summary | Main agent manages all | Focused tasks, context isolation |
| Agent view | Own session, background | Manual via dispatch | Long-running background sessions |
| Agent teams | Own session, fully independent | Shared task list, peer messaging | Complex parallel research (experimental) |
| Dynamic workflows | Own context per subagent | Script-driven orchestration | Many-subagent parallel patterns |

### Worktrees

| Flag / Setting | Effect |
| :--- | :--- |
| `--worktree <name>` or `-w <name>` | Create worktree at `.claude/worktrees/<name>/` on branch `worktree-<name>` |
| `--worktree "#1234"` | Branch from GitHub PR #1234 |
| `--worktree` (no name) | Auto-generate name |
| `worktree.baseRef: "fresh"` | Branch from `origin/HEAD` (default) |
| `worktree.baseRef: "head"` | Branch from local `HEAD` |
| `isolation: worktree` in subagent frontmatter | Give subagent its own worktree |

`.worktreeinclude`: gitignore-syntax file at project root listing gitignored files to copy into each new worktree (e.g., `.env`, `config/secrets.json`).

Cleanup: auto-removed if no changes; prompt if uncommitted changes or new commits exist. Add `.claude/worktrees/` to `.gitignore`.

### Prompt Caching

Cache layers: system prompt → project context → conversation.

**Actions that invalidate the cache:**

| Action | Invalidates |
| :--- | :--- |
| Switch models | Yes |
| Change effort level | Yes |
| Enable/disable fast mode | Yes |
| Connect/disconnect MCP server | Yes |
| Enable/disable plugin (with MCP) | Yes |
| Deny entire tool | Yes |
| Compact conversation | Yes |
| Upgrade Claude Code | Yes |

**Actions that preserve the cache:** edit files, edit CLAUDE.md mid-session, change output style, change permission mode, invoke skills, run `/recap`, rewind conversation, spawn subagent, toggle advisor.

TTL: 1 hour on claude.ai subscription; 5 minutes on API key (opt-in 1h with `ENABLE_PROMPT_CACHING_1H=1`). Check via statusline `current_usage.cache_creation_input_tokens` and `cache_read_input_tokens`.

### Artifacts

| Property | Detail |
| :--- | :--- |
| What | Private interactive web page published to claude.ai |
| Plans required | Team or Enterprise; Anthropic API only |
| Auth required | `/login` (claude.ai subscription); not API key |
| Reopen last artifact | `Ctrl+]` |
| Sharing | Within org only; viewers must be signed in to the same org |
| Versions | Each publish creates a new version; pick version in Share control |
| Source file types | `.html`, `.htm`, `.md` |
| Size limit | 16 MiB rendered |
| Disable (user) | `disableArtifact: true` in settings or `CLAUDE_CODE_DISABLE_ARTIFACT=1` |
| Auto-open | `CLAUDE_CODE_ARTIFACT_AUTO_OPEN=0` to disable |

CSP constraints: no external requests; no backend; single page only. Compliance API endpoints: `GET /v1/compliance/code/artifacts`, `GET /v1/compliance/code/artifacts/{id}/versions/{vid}`, `DELETE /v1/compliance/code/artifacts/{id}`.

### Advisor Tool

The advisor lets Claude consult a stronger second model at decision points mid-task.

**Accepted advisor pairings:**

| Main model | Accepted advisors |
| :--- | :--- |
| Haiku 4.5 | Fable, Opus, Sonnet |
| Sonnet 4.6 | Fable, Opus, Sonnet |
| Opus 4.6+ | Fable, Opus at or above main model's version |
| Fable 5 | Fable only |

Enable: `/advisor opus` (or `sonnet`/`fable`); `advisorModel` setting; `--advisor` flag. During a consultation the transcript shows `Advising` line; press `Ctrl+O` to expand guidance. `/advisor off` to disable. `CLAUDE_CODE_DISABLE_ADVISOR_TOOL=1` to disable entirely. Requires v2.1.98+; Anthropic API only.

### Deep Links

| Property | Detail |
| :--- | :--- |
| URL scheme | `claude-cli://open` |
| Minimum version | v2.1.91+ |
| Parameters | `q` (URL-encoded prompt, max 5000 chars), `cwd` (absolute path), `repo` (owner/name slug) |
| VS Code variant | `vscode://anthropic.claude-code/open` |
| Disable | `disableDeepLinkRegistration: "disable"` in settings |

Registered automatically on first interactive session. User-level only.

### Fullscreen TUI

| Item | Detail |
| :--- | :--- |
| Enable | `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1` |
| Minimum version | v2.1.89+ (research preview) |
| Transcript mode | `Ctrl+O` to open; `/` to search; `[` to write to scrollback; `v` to open in editor |
| Scroll | `PgUp`/`PgDn`, `Ctrl+Home`/`Ctrl+End` |
| Scroll speed | `CLAUDE_CODE_SCROLL_SPEED` env var |
| Mouse | Click-to-position, click-to-expand tool results, click-and-drag selection, URL clicking (Cmd/Ctrl+click) |

### Context Window Survival After Compaction

| Content | Survives compaction? |
| :--- | :--- |
| System prompt | Yes (unchanged) |
| Project-root CLAUDE.md | Yes (re-injected) |
| Auto memory | Yes (re-injected) |
| Invoked skill bodies | Yes (re-injected, capped at 5K/25K tokens) |
| Path-scoped rules | No (lost until re-triggered) |
| Nested CLAUDE.md | No (lost until re-triggered) |

Use `/context` for live breakdown; `/memory` to check loaded files.

### Prompt Library

50+ prompts organized by SDLC phase (Discover / Design / Build / Ship / Operate) and role (PM / Design / Docs / Marketing / Security / Ops). Interactive React component with search, tag filter, slot-filling, and copy button. Available at the claude.ai prompt library.

Five "start here" prompts; patterns: describe outcome not steps, give Claude a way to check its own work, point at a reference, state a measurable target, give an artifact, say how you want the answer.

## Full Documentation

For the complete official documentation, see the reference files:

- [Features overview](references/claude-code-features-overview.md) — Extension layer overview: CLAUDE.md, Skills, MCP, Subagents, Hooks, Plugins; feature comparison and context cost tables; how features load and layer
- [Model configuration](references/claude-code-model-config.md) — Model aliases, effort levels, ultracode, ultrathink, 1M context, opusplan, availableModels, fallback chains, enterprise model controls, env vars
- [Fast mode](references/claude-code-fast-mode.md) — Opus fast mode: toggle, speed, pricing, rate limits, auto-fallback, fastModePerSessionOptIn
- [Output styles](references/claude-code-output-styles.md) — Built-in styles, custom style files, frontmatter fields, how to change styles
- [Status line](references/claude-code-statusline.md) — Shell script config, all JSON input fields, subagentStatusLine, /statusline command
- [Checkpointing](references/claude-code-checkpointing.md) — Automatic file-edit tracking, /rewind menu options, what is and isn't tracked
- [Voice dictation](references/claude-code-voice-dictation.md) — /voice commands, hold vs tap modes, requirements, language setting, keybinding
- [Remote control](references/claude-code-remote-control.md) — Connect claude.ai or mobile app to local session, spawn modes, push notifications
- [Scheduled tasks (CLI)](references/claude-code-scheduled-tasks.md) — /loop skill, CronCreate/CronList/CronDelete tools, loop.md customization
- [Desktop scheduled tasks](references/claude-code-desktop-scheduled-tasks.md) — Routines page in desktop app, local vs remote tasks, schedule options, missed-run handling
- [Cloud routines](references/claude-code-routines.md) — Anthropic-hosted routines, schedule/API/GitHub triggers, /schedule commands
- [Channels](references/claude-code-channels.md) — MCP server push events into Claude Code, supported channels (Telegram/Discord/iMessage), enterprise controls
- [Channels reference](references/claude-code-channels-reference.md) — Build custom channel MCP servers: capabilities, notification format, permission relay schema
- [Context window](references/claude-code-context-window.md) — Interactive simulation, what survives compaction, /context and /memory commands
- [Fullscreen TUI](references/claude-code-fullscreen.md) — /tui fullscreen, transcript mode, mouse support, scroll controls
- [Agent view](references/claude-code-agent-view.md) — `claude agents` command, session state icons, attach/detach navigation, background sessions, CLI commands
- [Parallel agents overview](references/claude-code-agents.md) — Comparison of subagents, agent view, agent teams, dynamic workflows, and worktrees
- [Worktrees](references/claude-code-worktrees.md) — --worktree flag, PR branching, .worktreeinclude, subagent isolation, baseRef setting, cleanup behavior
- [Prompt caching](references/claude-code-prompt-caching.md) — Cache layers, actions that invalidate vs preserve cache, TTL, how to check cache performance
- [Prompt library](references/claude-code-prompt-library.md) — 50+ prompts by SDLC phase and role, prompting patterns
- [Advisor tool](references/claude-code-advisor.md) — /advisor command, accepted model pairings, when Claude consults advisor, cost, requirements
- [Artifacts](references/claude-code-artifacts.md) — Publish session output as private web pages, sharing, versions, page constraints, Compliance API, org management
- [Deep links](references/claude-code-deep-links.md) — claude-cli://open URL scheme, parameters, VS Code variant, registration

## Sources

- Features overview: https://code.claude.com/docs/en/features-overview.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Voice dictation: https://code.claude.com/docs/en/voice-dictation.md
- Remote control: https://code.claude.com/docs/en/remote-control.md
- Scheduled tasks (CLI): https://code.claude.com/docs/en/scheduled-tasks.md
- Desktop scheduled tasks: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
- Cloud routines: https://code.claude.com/docs/en/routines.md
- Channels: https://code.claude.com/docs/en/channels.md
- Channels reference: https://code.claude.com/docs/en/channels-reference.md
- Context window: https://code.claude.com/docs/en/context-window.md
- Fullscreen TUI: https://code.claude.com/docs/en/fullscreen.md
- Agent view: https://code.claude.com/docs/en/agent-view.md
- Parallel agents overview: https://code.claude.com/docs/en/agents.md
- Worktrees: https://code.claude.com/docs/en/worktrees.md
- Prompt caching: https://code.claude.com/docs/en/prompt-caching.md
- Prompt library: https://code.claude.com/docs/en/prompt-library.md
- Advisor tool: https://code.claude.com/docs/en/advisor.md
- Artifacts: https://code.claude.com/docs/en/artifacts.md
- Deep links: https://code.claude.com/docs/en/deep-links.md
