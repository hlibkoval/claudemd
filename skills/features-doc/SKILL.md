---
name: features-doc
user-invocable: false
---

# Claude Code Features Documentation

Reference for Claude Code's extended feature set: model configuration, output rendering, scheduling, remote access, parallel sessions, prompt caching, and more. Use this when answering questions about configuring models, controlling the UI, scheduling tasks, running sessions in parallel, or understanding how the context window and cache work.

## Quick Reference

### Feature Overview: When to Use What

| Feature | What it does | Use when |
| :--- | :--- | :--- |
| CLAUDE.md | Project instructions loaded every session | Project-wide conventions, persistent context |
| Skills | Reusable slash commands | Repeating a multi-step task |
| MCP servers | Give Claude new tools | Connecting external data sources |
| Subagents | Delegate tasks in-session | Side task would flood main conversation |
| Hooks | Automate on events | Running formatters, validators after edits |
| Plugins | Bundle skills + MCP + hooks | Distributing a reusable capability |

Context cost comparison: CLAUDE.md loads always; Skills load on invocation; Subagents have their own context; MCP deferred by default.

### Model Configuration

**Model aliases** (use in `/model`, `--model`, `ANTHROPIC_MODEL`, or settings):

| Alias | Resolves to |
| :--- | :--- |
| `default` | Current default |
| `best` | Highest-capability available |
| `fable` | Latest Fable model |
| `sonnet` | Latest Sonnet |
| `opus` | Latest Opus |
| `haiku` | Latest Haiku |
| `sonnet[1m]` / `opus[1m]` | 1M-token context variant |
| `opusplan` | Opus in plan mode, Sonnet in execute |

**Effort levels** (set with `/effort` or `--effort`): `low`, `medium`, `high`, `xhigh`, `max`, `ultracode` (session-only, not a model level).

**Priority order for model setting**: CLI flag > `/model` command > `ANTHROPIC_MODEL` env var > settings file.

**Fallback model**: `--fallback-model <alias>` or `fallbackModel` setting (array). Automatic fallback from Fable 5 on safety classifier triggers.

**Enterprise controls**: `availableModels`, `enforceAvailableModels`, `modelOverrides`, `_SUPPORTED_CAPABILITIES`.

**Per-model env vars**: `ANTHROPIC_DEFAULT_FABLE_MODEL`, `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL`, `CLAUDE_CODE_SUBAGENT_MODEL`.

### Fast Mode

| Detail | Value |
| :--- | :--- |
| What it does | Opus up to 2.5x faster at higher cost |
| Enable | `/fast` command or `"fastMode": true` in settings |
| Disable | `CLAUDE_CODE_DISABLE_FAST_MODE=1` |
| Supported models | Opus 4.8, 4.7, 4.6 only (not Sonnet/Haiku) |
| Provider | Anthropic API/subscription only |
| Rate limit | Auto-fallback to standard on limit hit (icon turns gray) |
| Per-session opt-in | `fastModePerSessionOptIn: true` (Team/Enterprise) |

Pricing: $10/$50 MTok input/output (Opus 4.8); $30/$150 MTok (Opus 4.7/4.6).

### Advisor Tool

Pair main model with a stronger advisor that Claude consults at decision points (before committing to approach, when stuck, before declaring done). Requires Anthropic API only; v2.1.98+.

| Main model | Accepted advisors |
| :--- | :--- |
| Haiku 4.5 | Fable, Opus, Sonnet |
| Sonnet 4.6 | Fable, Opus, Sonnet |
| Opus 4.6+ | Fable, Opus at or above main version |
| Fable 5 (v2.1.170+) | Fable only |

Enable: `/advisor <model>`, `"advisorModel": "opus"` in settings, or `--advisor opus` flag.
Disable: `/advisor off` or `CLAUDE_CODE_DISABLE_ADVISOR_TOOL=1`.
Note: toggling advisor does NOT invalidate prompt cache.

Common pairings: Sonnet+Opus (routine work with planning escalation), Sonnet+Fable (Fable guidance without full Fable cost), Opus+Opus (independent second opinion).

### Output Styles

Built-in styles: `Default`, `Proactive`, `Explanatory`, `Learning`.

Change via `/config` → Output style; saved to `.claude/settings.local.json`.

Custom style file locations: `~/.claude/output-styles/`, `.claude/output-styles/`, or managed policy.

Custom style frontmatter fields:
- `name` (required)
- `description`
- `keep-coding-instructions` (default `false`)
- `force-for-plugin` (forces style when plugin is active)

Note: output style is part of the system prompt layer and loads once at session start. Changes via `/config` mid-session don't apply until `/clear` or restart.

### Statusline

Configure a custom shell script that receives JSON on stdin and prints output shown in the status bar.

Settings key: `statusLine: { type: "command", command: "...", padding: N, refreshInterval: N, hideVimModeIndicator: bool }`.

Use `/statusline` command to auto-generate a statusline script.

Key JSON fields available on stdin:

| Field group | Available fields |
| :--- | :--- |
| Model | `model.id`, `model.display_name` |
| Cost | `cost.session_total`, `cost.current_turn` |
| Context | `context_window.tokens_used`, `context_window.tokens_remaining`, `context_window.percent_used` |
| Effort | `effort.level` |
| Rate limits | `rate_limits.*` |
| Session | `session_id`, `session_name`, `transcript_path` |
| PR | `pr.number`, `pr.title`, `pr.url` |
| Worktree | `worktree.branch`, `worktree.path` |
| Vim | `vim.mode` |

`subagentStatusLine` setting for agent panel rows. `COLUMNS`/`LINES` env vars available (v2.1.153+). `/scroll-speed` to adjust scroll speed interactively.

### Checkpointing and Rewind

- Auto-tracks file edits; one checkpoint per user prompt; persists 30 days.
- Open rewind menu: `/rewind` command or double-Esc.
- Actions available: Restore code and conversation / Restore conversation only / Restore code only / Summarize from here / Summarize up to here.
- Limitations: bash command side-effects NOT tracked; external file changes NOT tracked; not a replacement for git.

### Context Window

What loads before you type: system prompt, auto memory, env info, MCP tools, skill descriptions, CLAUDE.md files.

What survives `/compact`:

| Content | After compaction |
| :--- | :--- |
| System prompt | Unchanged |
| Project-root CLAUDE.md | Re-injected |
| Auto memory | Re-injected |
| Path-scoped rules | Lost until file re-read |
| Nested CLAUDE.md | Lost until file re-read |
| Invoked skill bodies | Re-injected (capped 5K/skill, 25K total) |

Use `/context` for live breakdown; `/memory` to check loaded files.

### Prompt Caching

Cache is organized in layers (stable → changing):

| Layer | Content | Invalidated when |
| :--- | :--- | :--- |
| System prompt | Core instructions, tool definitions, output style | Tool set changes or Claude Code upgrades |
| Project context | CLAUDE.md, auto memory, unscoped rules | Session start, `/clear`, `/compact` |
| Conversation | Messages, responses, tool results | Every turn |

**Actions that invalidate cache**: switching models, changing effort level, enabling fast mode (first time), connecting/disconnecting MCP server (if not deferred), enabling/disabling plugin with MCP, denying an entire built-in tool, `/compact`, upgrading Claude Code.

**Actions that keep cache**: editing repo files, editing CLAUDE.md mid-session, changing output style, changing permission mode (except opusplan), invoking skills/commands, `/recap`, `/rewind`, spawning subagents.

**Cache TTL**:
- Subscription: 1-hour TTL (automatically)
- API key/Bedrock/Vertex: 5-minute TTL by default; opt into 1h with `ENABLE_PROMPT_CACHING_1H=1`
- Force 5m: `FORCE_PROMPT_CACHING_5M=1`

**Disable caching**: `DISABLE_PROMPT_CACHING=1` (or per-model variant: `DISABLE_PROMPT_CACHING_HAIKU`, `DISABLE_PROMPT_CACHING_SONNET`, `DISABLE_PROMPT_CACHING_OPUS`, `DISABLE_PROMPT_CACHING_FABLE`).

Monitor: check `cache_creation_input_tokens` and `cache_read_input_tokens` in statusline or via OpenTelemetry.

### Fullscreen Rendering

Enable: `/tui fullscreen` or `CLAUDE_CODE_NO_FLICKER=1`. Disable: `/tui default` or `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1`.

What changes: input box stays fixed at bottom; memory stays flat regardless of conversation length; uses alternate screen buffer.

Mouse support:
- Click to position cursor in input
- Click suggestions in command/file lists
- Click collapsed tool results to expand
- Cmd/Ctrl+click URLs or file paths to open
- Click-drag to select text (auto-copies on release)
- Mouse wheel to scroll

Scroll shortcuts: PgUp/PgDn (half screen), Ctrl+Home (top), Ctrl+End (bottom + resume auto-follow). MacBook: Fn+arrows.

Transcript mode: `Ctrl+O` to toggle. In transcript mode: `/` to search, `n`/`N` for next/prev match, `[` to dump to native scrollback, `v` to open in `$EDITOR`.

Disable mouse capture only: `CLAUDE_CODE_DISABLE_MOUSE=1`. Scroll speed: `CLAUDE_CODE_SCROLL_SPEED=3` (1-20, fractional OK). Disable wheel acceleration: `wheelScrollAccelerationEnabled: false` (v2.1.174+).

Note: background sessions (agent view, `claude attach`) always use fullscreen rendering.

### Remote Control

Connect claude.ai web or Claude mobile app to a local CLI session.

| Start method | Command |
| :--- | :--- |
| Server mode | `claude remote-control` |
| Interactive mode | `claude --remote-control` |
| From existing session | `/remote-control` |

Spawn modes (via `--spawn`): `same-dir`, `worktree`, `session`. `--capacity N` for concurrent connections.

Connection: outbound HTTPS only, no inbound ports; TLS transport.

Push notifications: `/config` → Push when Claude decides / Push when actions required.

Suppress notifications when at machine: `CLAUDE_CLIENT_PRESENCE_FILE` env var.

Enterprise: disabled by default; admin enables at claude.ai/admin-settings/claude-code.

Limitations: local process must keep running; one remote session per interactive process.

### Voice Dictation

Requires claude.ai account (audio transcribed server-side). Enable: `/voice`. Modes: `/voice hold` (push-to-talk with Space), `/voice tap` (tap to start, tap again to send), `/voice off`.

Settings: `{ "voice": { "enabled": true, "mode": "tap" } }`. Keybinding: `voice:pushToTalk` in `~/.claude/keybindings.json`. Language: `language` setting; 20 supported languages.

### Artifacts

Live interactive web pages published to a private URL on claude.ai. Team/Enterprise only; requires `/login` and Anthropic API.

| Requirement | Detail |
| :--- | :--- |
| Plan | Team (on by default) or Enterprise (admin enables) |
| Auth | `/login` required; API key sessions cannot publish |
| Provider | Anthropic only (not Bedrock/Vertex/Foundry) |
| CLI | Claude Code CLI or Desktop app v1.13576.0+ |

Create: ask Claude directly or let it decide. Permission prompt before first publish. `Ctrl+]` to reopen latest artifact. `CLAUDE_CODE_ARTIFACT_AUTO_OPEN=0` to prevent auto-browser-open.

Update: ask Claude to revise; republishes to same URL. To update from different session, give Claude the artifact URL.

Share: Share control in page header; org-only visibility; no external sharing.

Page constraints: no external requests (CSP), no backend, single page only, `.html`/`.htm`/`.md` source, 16 MiB max.

Disable: `"disableArtifact": true` in settings, `CLAUDE_CODE_DISABLE_ARTIFACT=1`, or add `Artifact` to `permissions.deny`.

Admin: retention policy, audit log (`claude_artifact_*` events), Compliance API (`GET/DELETE /v1/compliance/code/artifacts`).

### Channels (Research Preview, v2.1.80+)

Push events into a running session from an MCP server. Available platforms: Telegram, Discord, iMessage (all via plugin, requires Bun).

Start: `claude --channels plugin:<name>@<marketplace>`.

Security: sender allowlist; pairing code flow for Telegram/Discord. Gate on sender identity (`message.from.id`), not room/chat ID.

Enterprise: `channelsEnabled` master switch; `allowedChannelPlugins` to restrict plugins.

**Building a custom channel** (MCP server):
- Declare `capabilities.experimental['claude/channel']: {}` in Server constructor
- Emit `notifications/claude/channel` events with `{ content: string, meta: Record<string, string> }`
- `meta` keys become `<channel>` tag attributes; content becomes tag body
- `claude/channel/permission: {}` capability opts into permission relay
- `capabilities.tools: {}` enables reply tools for two-way channels

Permission relay: Claude Code sends `notifications/claude/channel/permission_request` with `request_id`, `tool_name`, `description`, `input_preview`. Channel responds with `notifications/claude/channel/permission` with `request_id` and `behavior: "allow" | "deny"`.

Test with `--dangerously-load-development-channels server:<name>` during research preview.

### Scheduling

Three scheduling approaches:

| | Cloud (Routines) | Desktop tasks | `/loop` in CLI |
| :--- | :--- | :--- | :--- |
| Runs on | Anthropic cloud | Your machine | Your machine |
| Requires machine on | No | Yes | Yes |
| Requires open session | No | No | Yes |
| Access to local files | No (fresh clone) | Yes | Yes |
| Minimum interval | 1 hour | 1 minute | 1 minute |

**Routines** (cloud): trigger via Schedule, API (HTTP POST), or GitHub events (PR, Release). Create at claude.ai/code/routines, Desktop app, or `/schedule` CLI. Commands: `/schedule list`, `/schedule update`, `/schedule run`. Branch push: `claude/` prefix default; enable unrestricted per-repo. Admin: Routines toggle at claude.ai/admin-settings/claude-code.

**Desktop scheduled tasks**: create from Routines sidebar → New routine → Local. Fields: Name, Description, Instructions, Schedule. Schedules: Manual, Hourly, Daily, Weekdays, Weekly. Catch-up: one run for most recently missed time (7-day window). Enable worktree isolation per task. Task files at `~/.claude/scheduled-tasks/<task-name>/SKILL.md`. `update_scheduled_task` MCP tool lets tasks reschedule themselves.

**`/loop` skill**: `/loop 5m <prompt>` (fixed interval), `/loop <prompt>` (Claude chooses), `/loop` (built-in maintenance). Customize default prompt with `loop.md` at `.claude/loop.md` or `~/.claude/loop.md`. Cron via `CronCreate`/`CronList`/`CronDelete` tools (up to 50 per session). Disable: `CLAUDE_CODE_DISABLE_CRON=1`.

### Deep Links

URL scheme: `claude-cli://open` — opens a new local terminal session.

| Parameter | Description |
| :--- | :--- |
| `q` | Prompt text (URL-encoded, max 5000 chars, `%0A` for newlines) |
| `cwd` | Absolute path (takes precedence over `repo`) |
| `repo` | GitHub `owner/name` slug (resolves to most recent local clone) |

Registration: automatic on first interactive session. Platform locations:
- macOS: `~/Applications/Claude Code URL Handler.app`
- Linux: `~/.local/share/applications/claude-code-url-handler.desktop`
- Windows: `HKEY_CURRENT_USER\Software\Classes\claude-cli`

Security: prompt shown as "Prompt from an external link"; not sent until Enter pressed.

VS Code alternative: `vscode://anthropic.claude-code/open` for editor tab.

Disable registration: `disableDeepLinkRegistration: "disable"` in settings.

GitHub Markdown strips `claude-cli://` scheme — use code blocks as workaround.

### Parallel Sessions and Agents

| Approach | Who coordinates | File isolation | Use when |
| :--- | :--- | :--- | :--- |
| Subagents | Claude (inside one session) | Optional (worktrees) | Side task would flood main conversation |
| Agent view | You (via `claude agents`) | Auto worktree | Multiple independent tasks to hand off |
| Agent teams | Claude (lead + teammates) | None (partition manually) | Claude should split project into pieces |
| Dynamic workflows | Script | Per-subagent | 500-file migrations, cross-checked research |

Check running work: `claude agents` (background sessions), `/agents` (current session subagents), `/tasks` (background tasks), `/workflows` (dynamic workflows).

### Agent View (Research Preview, v2.1.139+)

Launch: `claude agents`. Keyboard shortcuts:

| Key | Action |
| :--- | :--- |
| Up/Down | Navigate session list |
| Enter / Right | Attach to session |
| Space | Peek without attaching |
| Left | Detach (or send to background on empty prompt) |
| Ctrl+T | Pin session |
| Ctrl+R | Rename session |
| Ctrl+X | Stop/delete session |

Session states: Working (animated), Needs input (yellow), Idle (dimmed), Completed (green), Failed (red), Stopped (grey).

Icon shapes: `✻`/`✽` (process alive), `∙` (process exited, can restart), `✢` (/loop sleeping).

Dispatch: type prompt at bottom; prefix with agent name, `@repo`, `/command`, or `!` for shell command.

Background via `/bg` from session; `claude --bg "<prompt>"` to dispatch from shell.

CLI commands: `claude attach <id>`, `claude logs <id>`, `claude stop <id>`, `claude rm <id>`.

File isolation: auto git worktree under `.claude/worktrees/`. Disable: `worktree.bgIsolation: "none"`.

Supervisor process: separate from terminal; auto-starts; reconnects after sleep; auto-restarts. State: `~/.claude/daemon.log`, `~/.claude/daemon/roster.json`, `~/.claude/jobs/<id>/`.

Disable agent view: `CLAUDE_CODE_DISABLE_AGENT_VIEW=1` or `disableAgentView: true`.

### Worktrees

Create isolated git worktree session: `claude --worktree <name>` (or `-w <name>`). Omit name for auto-generated name.

Worktrees placed at `.claude/worktrees/<name>/` on new branch `worktree-<name>`. Add `.claude/worktrees/` to `.gitignore`.

**Base branch**: default is `origin/HEAD`. Set `worktree.baseRef: "head"` to branch from local HEAD. Branch from PR: `claude --worktree "#1234"`.

**Copy gitignored files**: add `.worktreeinclude` (gitignore syntax) to project root — only copies files that are also gitignored.

**Subagent worktrees**: ask Claude to "use worktrees for your agents" or add `isolation: worktree` to custom subagent frontmatter.

**Cleanup**: no changes → auto-removed. With changes → prompted to keep/remove. Non-interactive (`-p`) → not auto-cleaned; use `git worktree remove`. Subagent/background worktrees auto-cleaned after `cleanupPeriodDays` (if no uncommitted changes/untracked files/unpushed commits).

**Non-git VCS**: configure `WorktreeCreate` and `WorktreeRemove` hooks to replace default git behavior.

### Prompt Library

Interactive catalog of copy-paste prompts at the `/prompt-library` docs page. Organized by SDLC phase (Discover, Design, Build, Ship, Operate) and category. Filter by role tags (pm, design, docs, marketing, security, ops).

Prompt patterns that work well:
- Describe outcome, not steps
- Give Claude a way to check its own work (ask for "run, test, compare")
- Point at a reference file/pattern to follow
- State measurable targets
- Give the artifact directly (paste errors, logs, screenshots, or `@`-mention files)
- State the answer format

## Full Documentation

- **[claude-code-features-overview.md](references/claude-code-features-overview.md)** — When to use CLAUDE.md vs Skills vs MCP vs Subagents vs Hooks vs Plugins; layering rules; feature comparison and context cost tables.

- **[claude-code-model-config.md](references/claude-code-model-config.md)** — Model aliases, effort levels, extended context, fallback chains, enterprise model controls, per-model env vars, prompt caching config.

- **[claude-code-fast-mode.md](references/claude-code-fast-mode.md)** — Opus fast mode: pricing, supported models, rate limit handling, per-session opt-in, and how to enable/disable.

- **[claude-code-advisor.md](references/claude-code-advisor.md)** — Advisor tool: model pairings, enable/disable, when Claude consults it, cost, and comparison with opusplan/subagents.

- **[claude-code-output-styles.md](references/claude-code-output-styles.md)** — Built-in and custom output styles, frontmatter fields, scope and session behavior.

- **[claude-code-statusline.md](references/claude-code-statusline.md)** — Custom statusline script, JSON fields, `subagentStatusLine`, scroll speed settings.

- **[claude-code-checkpointing.md](references/claude-code-checkpointing.md)** — Auto file checkpointing, `/rewind` menu, restore actions, and limitations.

- **[claude-code-context-window.md](references/claude-code-context-window.md)** — What loads before first message, what survives compaction, `/context` and `/memory` commands.

- **[claude-code-prompt-caching.md](references/claude-code-prompt-caching.md)** — Cache layers, actions that invalidate/preserve cache, TTL configuration, subagent cache behavior, how to disable.

- **[claude-code-fullscreen.md](references/claude-code-fullscreen.md)** — Alternate-screen rendering mode: mouse support, scroll shortcuts, transcript mode, tmux caveats, disable options.

- **[claude-code-remote-control.md](references/claude-code-remote-control.md)** — Connect mobile/web to local CLI; spawn modes; push notifications; enterprise controls.

- **[claude-code-voice-dictation.md](references/claude-code-voice-dictation.md)** — Voice input modes, settings, keybindings, supported languages.

- **[claude-code-artifacts.md](references/claude-code-artifacts.md)** — Publish interactive HTML pages to private URLs; availability requirements; page constraints; org admin controls.

- **[claude-code-channels.md](references/claude-code-channels.md)** — Use Telegram/Discord/iMessage channels; enterprise controls; research preview setup.

- **[claude-code-channels-reference.md](references/claude-code-channels-reference.md)** — Build custom MCP channel servers: capability declaration, notification format, reply tools, sender gating, permission relay.

- **[claude-code-scheduled-tasks.md](references/claude-code-scheduled-tasks.md)** — `/loop` skill for session-scoped scheduling; cron tools; `loop.md` customization.

- **[claude-code-desktop-scheduled-tasks.md](references/claude-code-desktop-scheduled-tasks.md)** — Desktop app local scheduled tasks: create, configure, manage, permissions, missed-run behavior.

- **[claude-code-routines.md](references/claude-code-routines.md)** — Cloud routines: schedule/API/GitHub triggers, create via web UI or CLI, branch push config, admin controls.

- **[claude-code-deep-links.md](references/claude-code-deep-links.md)** — `claude-cli://open` URL scheme: parameters, registration, platform locations, VS Code variant, troubleshooting.

- **[claude-code-agents.md](references/claude-code-agents.md)** — Overview of parallelism approaches: subagents, agent view, agent teams, dynamic workflows; how to check running work.

- **[claude-code-agent-view.md](references/claude-code-agent-view.md)** — Agent view UI: session states, keyboard shortcuts, dispatch syntax, file isolation, supervisor process, CLI commands.

- **[claude-code-worktrees.md](references/claude-code-worktrees.md)** — Git worktree isolation: `--worktree` flag, base branch config, `.worktreeinclude`, subagent isolation, cleanup, non-git VCS hooks.

- **[claude-code-prompt-library.md](references/claude-code-prompt-library.md)** — Interactive prompt catalog organized by SDLC phase; prompting patterns that work; sources.

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
- https://code.claude.com/docs/en/advisor.md
- https://code.claude.com/docs/en/artifacts.md
