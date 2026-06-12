---
name: features-doc
user-invocable: false
---

# Claude Code Features Documentation

Quick reference for Claude Code features: model configuration, fast mode, output styles, statusline, checkpointing, scheduling, voice dictation, remote control, worktrees, agent view, prompt caching, advisor tool, channels, deep links, and more.

## Quick Reference

### Model Aliases

| Alias | Resolves to |
|---|---|
| `default` | Current default model |
| `best` / `fable` | Fable 5 (hardest/longest tasks, requires access) |
| `opus` | Latest Opus |
| `sonnet` | Latest Sonnet |
| `haiku` | Latest Haiku |
| `opus[1m]` / `sonnet[1m]` | Extended context (1M tokens, plan-dependent) |
| `opusplan` | Opus for plan mode, Sonnet for execution |

Use `/model` to open picker. `availableModels` to restrict. `modelOverrides` for third-party APIs. `ANTHROPIC_DEFAULT_INTERACTIVE_MODEL` / `ANTHROPIC_DEFAULT_NONINTERACTIVE_MODEL` env vars.

### Effort Levels

| Level | Description |
|---|---|
| `low` | Fastest, lowest cost |
| `medium` | Balanced |
| `high` | More thorough |
| `xhigh` | Extended thinking |
| `max` | Maximum reasoning |

Use `/effort` to change. `ultracode` for session-only maximum. Changing effort level invalidates prompt cache.

### Fast Mode (Opus)

| Item | Detail |
|---|---|
| Speed | Up to 2.5x faster than standard Opus |
| Cost tradeoff | Higher cost per token |
| Toggle | `/fast` |
| Setting | `fastMode: true` |
| Per-session reset | `fastModePerSessionOptIn: true` |
| Disable | `CLAUDE_CODE_DISABLE_FAST_MODE=1` |
| Requires | Usage credits (not subscription-only) |
| Pricing (Opus 4.8) | $10 input / $50 output per MTok |
| Pricing (Opus 4.7/4.6) | $30 input / $150 output per MTok |

First time enabling fast mode per conversation invalidates prompt cache.

### Output Styles

| Style | Description |
|---|---|
| Default | Standard balanced output |
| Proactive | More initiative, less asking |
| Explanatory | More context and explanation |
| Learning | Educational with rationale |
| Custom | Markdown file in `output-styles/` dir |

Use `/config` to select. `outputStyle` setting. Takes effect after `/clear` or new session. Custom styles: frontmatter fields `name`, `description`, `keep-coding-instructions`, `force-for-plugin`.

### Statusline Configuration

| Setting | Description |
|---|---|
| `statusLine.type` | Set to `"command"` for custom script |
| `statusLine.command` | Shell command to run |
| `statusLine.padding` | Padding around output |
| `statusLine.refreshInterval` | How often to refresh (ms) |
| `statusLine.hideVimModeIndicator` | Boolean |
| `subagentStatusLine` | Separate command for subagent panel rows |

Use `/statusline` to auto-generate a starter script. Script reads JSON from stdin.

**Key JSON fields available to statusline scripts:**

| Field | Description |
|---|---|
| `model.display_name` | Current model name |
| `workspace.current_dir` | Working directory |
| `context_window.used_percentage` | Context usage % |
| `cost.total_cost_usd` | Session cost |
| `rate_limits.five_hour` | 5-hour rate limit status |
| `rate_limits.seven_day` | 7-day rate limit status |
| `effort.level` | Current effort level |
| `pr.number` / `pr.url` / `pr.review_state` | PR info |
| `worktree.*` | Worktree details |

### Checkpointing and Rewind

| Item | Detail |
|---|---|
| Trigger | Auto-checkpoint before each user prompt |
| Open menu | `/rewind` or double-Esc |
| Restore code+conversation | Full rewind |
| Restore conversation only | Keep file changes |
| Restore code only | Keep conversation |
| Summarize from here | Compact forward |
| Summarize up to here | Compact backward |
| Bash tracking | Does NOT track bash command side-effects |
| Persistence | Survives session close; cleaned up after 30 days |

### Context Window Lifecycle

What loads before your first message:

| Component | Approx tokens |
|---|---|
| System prompt | ~4,200 |
| Auto memory | ~680 |
| Environment info | ~280 |
| MCP tools (deferred) | ~120 |
| Skill descriptions | ~450 |
| CLAUDE.md (root) | ~320 base + content |

Post-compaction survival:

| Item | Survives compaction? |
|---|---|
| System prompt | Yes, reloaded |
| Root CLAUDE.md | Yes, reloaded |
| Path-scoped CLAUDE.md rules | No, lost until re-triggered |
| Nested CLAUDE.md files | No, lost until re-triggered |
| Skill bodies | Re-injected up to 5K/skill, 25K total |

Use `/context` for a live breakdown of what is in your current context window.

### Scheduling: CLI Loops

| Item | Detail |
|---|---|
| Command | `/loop [interval] [prompt]` |
| Fixed interval | `/loop 30m "run tests"` |
| Dynamic interval | Claude decides when to run again |
| Maintenance prompt | Customize via `loop.md` |
| Tools | `CronCreate`, `CronList`, `CronDelete` |
| Limit | 50 tasks maximum |
| Expiry | Recurring tasks expire after 7 days |
| Jitter | Applied automatically |
| Disable | `CLAUDE_CODE_DISABLE_CRON=1` |

### Scheduling: Desktop App Routines (Local)

| Item | Detail |
|---|---|
| Access | Routines page → New routine → Local |
| Fields | Name, Description, Instructions, Schedule |
| Presets | Manual / Hourly / Daily / Weekdays / Weekly |
| Worktree option | Per-task isolation toggle |
| Missed runs | One catch-up run on wake (within last 7 days) |
| Storage | `~/.claude/scheduled-tasks/<name>/SKILL.md` |
| Self-reschedule | `update_scheduled_task` MCP tool |

### Scheduling: Cloud Routines

| Item | Detail |
|---|---|
| Create | `claude.ai/code/routines` or `/schedule` CLI |
| Triggers | Schedule (min 1h), API (POST to `/fire`), GitHub events |
| GitHub events | PR opened/merged/closed, release published |
| Runs as | Autonomous (no permission prompts) |
| Branch prefix | `claude/` by default |
| CLI commands | `/schedule list`, `/schedule update`, `/schedule run` |
| Admin setting | `allowedChannelPlugins` |
| Status | Research preview |

### Voice Dictation

| Command | Action |
|---|---|
| `/voice` | Toggle voice on/off |
| `/voice hold` | Hold mode (hold Space to record) |
| `/voice tap` | Tap mode (tap once to start, again to send) |
| `/voice off` | Disable voice |

| Setting | Description |
|---|---|
| `autoSubmit: true` | Auto-send on release (hold mode) |
| `voice.pushToTalk` | Rebind push-to-talk key |

- 20 supported languages
- Requires claude.ai account (not API key)
- Not available in remote/SSH environments

### Remote Control

| Item | Detail |
|---|---|
| Start server | `claude remote-control` |
| Connect from session | `/remote-control` or `/rc` |
| Interactive flag | `claude --remote-control` |
| Connect from | claude.ai/code or Claude mobile app |
| Spawn modes | `--spawn same-dir`, `--spawn worktree`, `--spawn session` |
| Capacity | `--capacity N` (concurrent sessions) |
| Push notifications | Enable via `/config` |
| Network | Outbound HTTPS only, no inbound ports needed |
| Requires | claude.ai subscription |

### Agent View

| Item | Detail |
|---|---|
| Open | `claude agents` |
| Dispatch background session | `claude --bg "<prompt>"` |
| Peek at session | `Space` |
| Attach to session | `Enter` or `→` |
| Detach and return | `←` |

**Session states:**

| State | Meaning |
|---|---|
| Working | Actively running |
| Needs input | Waiting for your response |
| Idle | Paused, no pending work |
| Completed | Finished successfully |
| Failed | Exited with error |
| Stopped | Manually stopped |

**Shell commands:**

| Command | Action |
|---|---|
| `claude attach <id>` | Attach to a session |
| `claude logs <id>` | View session logs |
| `claude stop <id>` | Stop a session |
| `claude rm <id>` | Remove a session |
| `claude respawn <id>` | Restart a stopped session |

Settings: `--cwd` to scope view, `CLAUDE_CODE_DISABLE_AGENT_VIEW=1`, `disableAgentView` setting. File isolation via git worktrees. `worktree.bgIsolation: "none"` to disable. Research preview.

### Parallel Agents Comparison

| Approach | What it gives you | Coordination |
|---|---|---|
| Subagents | Delegated workers inside one session | Claude collects results |
| Agent view | Background independent sessions | You check back via `claude agents` |
| Agent teams | Coordinated multi-session with shared task list | Claude plans and assigns (experimental) |
| Dynamic workflows | Scripted many-subagent orchestration | Script holds the plan |

Check running work: `claude agents` (background), `/agents` (subagents in session), `/tasks` (background items in session), `/workflows` (dynamic workflow runs).

### Worktrees

| Item | Detail |
|---|---|
| Create and start | `claude --worktree <name>` or `-w <name>` |
| Auto-generated name | `claude --worktree` (omit name) |
| Location | `.claude/worktrees/<name>/` |
| Branch | `worktree-<name>` |
| From PR | `claude --worktree "#1234"` |
| Base setting | `worktree.baseRef: "head"` (use local HEAD instead of origin) |
| Copy gitignored files | `.worktreeinclude` file (gitignore syntax) |
| Subagent isolation | `isolation: worktree` in subagent frontmatter |
| Disable bg isolation | `worktree.bgIsolation: "none"` |
| Non-git VCS | `WorktreeCreate` / `WorktreeRemove` hooks |

Add `.claude/worktrees/` to `.gitignore` to keep them out of your main checkout status.

### Prompt Cache Invalidation

**Actions that INVALIDATE the cache:**

| Action | Effect |
|---|---|
| Switching models | Full cache bust |
| Changing effort level | Full cache bust |
| Enabling fast mode (first time per conversation) | Full cache bust |
| Connecting/disconnecting MCP server (if tools in prefix) | Cache bust |
| Enabling/disabling plugin (if MCP-backed) | Cache bust |
| Denying a tool call | Cache bust |
| `/compact` | Cache bust |
| Upgrading Claude Code | Cache bust |

**Actions that KEEP the cache:**

| Action |
|---|
| Editing files |
| Editing CLAUDE.md mid-session |
| Changing output style |
| Changing permission mode |
| Invoking skills |
| `/recap` |
| Rewinding |
| Toggling `/advisor` on or off |

**Cache TTL:**

| Mode | TTL |
|---|---|
| API (default) | 5 minutes |
| Subscription (auto) | 1 hour |
| Force 1-hour (API) | `ENABLE_PROMPT_CACHING_1H=1` |
| Force 5-minute (subscription) | `FORCE_PROMPT_CACHING_5M=1` |
| Disable entirely | `DISABLE_PROMPT_CACHING=1` |

### Advisor Tool

| Item | Detail |
|---|---|
| Set mid-session | `/advisor <model>` |
| Set in settings | `advisorModel: "opus"` |
| Set at launch | `--advisor opus` |
| Model aliases | `opus`, `sonnet`, `fable` |
| Turn off | `/advisor off` |
| Disable entirely | `CLAUDE_CODE_DISABLE_ADVISOR_TOOL=1` |
| Requires | Anthropic API only (not Bedrock / Vertex / Foundry) |
| Min version | Claude Code v2.1.98 (Fable: v2.1.170) |

**Accepted advisor pairings:**

| Main model | Accepted advisors |
|---|---|
| Haiku 4.5 | Sonnet, Opus, Fable |
| Sonnet 4.6 | Sonnet, Opus, Fable |
| Opus 4.6+ | Opus (at or above main version), Fable |
| Fable 5 | Fable only |

Advisor call shown as `Advising` in transcript. Press `Ctrl+O` to expand and read guidance. Does not invalidate prompt cache. Each call re-reads full conversation (not cached between calls).

### Channels (Push Events into Sessions)

| Item | Detail |
|---|---|
| Enable | `claude --channels plugin:<name>@<marketplace>` |
| Supported providers | Telegram, Discord, iMessage, fakechat |
| Security | Sender allowlist configured per channel |
| Admin setting | `channelsEnabled`, `allowedChannelPlugins` |
| Requires | Bun runtime |
| Status | Research preview |

**Build a custom channel (MCP server):**
- Set `capabilities.experimental['claude/channel']: {}` in Server constructor
- Emit `notifications/claude/channel` with `content` and `meta`
- For two-way: implement reply tool
- For permissions: `claude/channel/permission` capability, emit `notifications/claude/channel/permission_request`, receive `notifications/claude/channel/permission` verdict
- Development flag: `--dangerously-load-development-channels`

### Deep Links

| Item | Detail |
|---|---|
| URL scheme | `claude-cli://open` |
| `q` param | URL-encoded prompt (max 5000 chars) |
| `cwd` param | Absolute working directory path |
| `repo` param | GitHub `owner/name` slug |
| Registered | Automatically on first interactive session |
| macOS location | `~/Applications/Claude Code URL Handler.app` |
| Linux location | XDG desktop file |
| Windows location | HKCU registry |
| Disable registration | `disableDeepLinkRegistration: "disable"` |
| VS Code handler | `vscode://anthropic.claude-code/open` |

### Features Overview: Extension Layers

| Feature | When it activates |
|---|---|
| CLAUDE.md | Always loaded (project root), path-scoped on file access |
| Skills | On-demand, injected when relevant |
| Code intelligence (LSP) | On code file open/edit |
| MCP servers | On connection, tools deferred until needed |
| Subagents | When Claude delegates a subtask |
| Agent teams | When multi-session coordination is configured |
| Hooks | On specific lifecycle events |
| Plugins | When plugin is loaded |

### Prompt Library Patterns

The built-in prompt library contains 50 prompts organized by SDLC phase:

| Phase | Categories |
|---|---|
| Discover | Onboard, Understand |
| Design | Plan, Prototype |
| Build | Implement, Test, Refactor |
| Ship | Review, Steer, Git, Release |
| Operate | Debug, Incident, Data, Automate |

**Effective prompt patterns:**
- Describe the outcome, not the steps
- Give Claude a self-check mechanism ("verify by running X")
- Point at a reference implementation
- State a measurable target
- Provide the artifact directly (paste the file)
- Specify the exact output format needed

## Full Documentation

| File | Description |
|---|---|
| [claude-code-model-config.md](references/claude-code-model-config.md) | Model aliases, effort levels, opusplan, extended context, fallback chains, model restrictions |
| [claude-code-fast-mode.md](references/claude-code-fast-mode.md) | Fast mode for Opus: speed, pricing, settings, requirements |
| [claude-code-output-styles.md](references/claude-code-output-styles.md) | Built-in and custom output styles, frontmatter fields, activation |
| [claude-code-statusline.md](references/claude-code-statusline.md) | Statusline script setup, all available JSON fields, configuration settings |
| [claude-code-checkpointing.md](references/claude-code-checkpointing.md) | Rewind menu, restore actions, persistence, limitations |
| [claude-code-context-window.md](references/claude-code-context-window.md) | Context timeline, token costs per feature, post-compaction survival |
| [claude-code-features-overview.md](references/claude-code-features-overview.md) | All extension features, activation triggers, context cost table |
| [claude-code-remote-control.md](references/claude-code-remote-control.md) | Remote control server, mobile app connection, spawn modes, network requirements |
| [claude-code-scheduled-tasks.md](references/claude-code-scheduled-tasks.md) | `/loop` command, cron tools, task limits, expiry |
| [claude-code-voice-dictation.md](references/claude-code-voice-dictation.md) | Voice commands, hold/tap modes, language support, requirements |
| [claude-code-channels.md](references/claude-code-channels.md) | Push events into sessions, supported providers, security, admin settings |
| [claude-code-channels-reference.md](references/claude-code-channels-reference.md) | Build custom channels: MCP capabilities, events, permission relay protocol |
| [claude-code-desktop-scheduled-tasks.md](references/claude-code-desktop-scheduled-tasks.md) | Desktop app local routines, schedule presets, missed runs, self-rescheduling |
| [claude-code-routines.md](references/claude-code-routines.md) | Cloud routines on Anthropic infrastructure, triggers, GitHub events, autonomous runs |
| [claude-code-deep-links.md](references/claude-code-deep-links.md) | `claude-cli://open` URL scheme, parameters, platform registration, VS Code handler |
| [claude-code-agent-view.md](references/claude-code-agent-view.md) | Background sessions, session states, keyboard shortcuts, shell commands, worktree isolation |
| [claude-code-agents.md](references/claude-code-agents.md) | Parallelization approaches compared: subagents, agent view, agent teams, dynamic workflows |
| [claude-code-worktrees.md](references/claude-code-worktrees.md) | Worktree creation, base branch config, PR-based worktrees, `.worktreeinclude`, subagent isolation, non-git VCS hooks |
| [claude-code-prompt-caching.md](references/claude-code-prompt-caching.md) | Cache layers, invalidation triggers, actions that preserve cache, TTL settings |
| [claude-code-prompt-library.md](references/claude-code-prompt-library.md) | 50 built-in prompts by SDLC phase, role tags, effective prompt patterns |
| [claude-code-advisor.md](references/claude-code-advisor.md) | Advisor tool setup, model pairings, call timing, cost, cache impact, requirements |

## Sources

- https://code.claude.com/docs/model-config
- https://code.claude.com/docs/fast-mode
- https://code.claude.com/docs/output-styles
- https://code.claude.com/docs/statusline
- https://code.claude.com/docs/checkpointing
- https://code.claude.com/docs/features-overview
- https://code.claude.com/docs/remote-control
- https://code.claude.com/docs/scheduled-tasks
- https://code.claude.com/docs/voice-dictation
- https://code.claude.com/docs/channels
- https://code.claude.com/docs/channels-reference
- https://code.claude.com/docs/desktop-scheduled-tasks
- https://code.claude.com/docs/context-window
- https://code.claude.com/docs/fullscreen
- https://code.claude.com/docs/routines
- https://code.claude.com/docs/deep-links
- https://code.claude.com/docs/agent-view
- https://code.claude.com/docs/agents
- https://code.claude.com/docs/worktrees
- https://code.claude.com/docs/prompt-caching
- https://code.claude.com/docs/prompt-library
- https://code.claude.com/docs/advisor
