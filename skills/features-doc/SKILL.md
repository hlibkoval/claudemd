---
name: features-doc
description: Complete official documentation for Claude Code features — fast mode, model configuration, output styles, status line, checkpointing, remote control, scheduled tasks, voice dictation, channels, fullscreen rendering, routines, deep links, agent view, parallel agents, worktrees, prompt caching, the prompt library, and the advisor tool. Use when answering questions about or working with any of these built-in Claude Code features or capabilities.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features, covering the extension layer, parallelism tools, UI enhancements, and model configuration options.

## Quick Reference

### Extension Layer Overview

| Feature | What it does | Where to learn more |
|---|---|---|
| CLAUDE.md | Project instructions loaded into every session | features-overview |
| Skills | Packaged prompts + reference docs Claude loads automatically | features-overview |
| MCP servers | Tool extensions that add capabilities to Claude | features-overview |
| Subagents | Delegated workers that handle side tasks in their own context | features-overview, agents |
| Agent teams | Multiple coordinated sessions with shared task lists (experimental) | features-overview, agents |
| Code intelligence | IDE integrations for linting, type info, inline diagnostics | features-overview |
| Hooks | Shell commands triggered on lifecycle events | features-overview |
| Plugins | Bundles of skills, hooks, and MCP servers | features-overview |

### Model Configuration

| Alias | Resolves to | Notes |
|---|---|---|
| `default` | Current default model | Changes with releases |
| `best` | Highest-capability available | Changes with releases |
| `fable` | Fable 5 | Requires Fable 5 access, v2.1.170+ |
| `sonnet` | Latest Sonnet | |
| `opus` | Latest Opus | |
| `haiku` | Latest Haiku | |
| `sonnet[1m]` | Sonnet with 1M context | Extended context add-on |
| `opus[1m]` | Opus with 1M context | Extended context add-on |
| `opusplan` | Opus for plan mode, Sonnet for execution | Split-model mode |

**Effort levels** (set with `/effort` or `--effort`): `low`, `medium`, `high`, `xhigh`, `max`, `ultracode`

**Set model**: `/model <alias>` or `--model <alias>` or `"model"` in settings

**Restrict available models**: `"availableModels": ["sonnet", "opus"]` in settings

### Fast Mode (Opus Only)

| Item | Detail |
|---|---|
| Toggle | `/fast` in session |
| Per-session opt-in setting | `"fastModePerSessionOptIn": true` |
| Speed benefit | Up to 2.5× faster for Opus |
| Pricing (Opus 4.8) | $10 input / $50 output per MTok (fast) vs standard rates |
| Pricing (Opus 4.7/4.6) | $30 input / $150 output per MTok (fast) |
| Cache impact | Enabling fast mode invalidates the prompt cache |

### Output Styles

| Style | Behavior |
|---|---|
| Default | Concise, code-focused |
| Proactive | Explains what it's about to do before doing it |
| Explanatory | Annotates code with inline comments |
| Learning | Teaches as it works |

**Change style**: `/config` → Output style

**Custom style**: Create a Markdown file with frontmatter `name`, `description`, optional `keep-coding-instructions: true`, optional `force-for-plugin: <plugin-name>`

### Status Line

**Enable**: `/statusline` or set `"statusLine": "<script-path>"` in settings

**Available JSON fields** (passed to script on each update):

| Field | Contains |
|---|---|
| `model` | Current model name |
| `workspace` | Workspace path |
| `cost` | Session cost so far |
| `context_window` | Tokens used / available |
| `effort` | Current effort level |
| `rate_limits` | Rate limit status |
| `vim` | Vim mode state |
| `pr` | Current PR info |
| `worktree` | Active worktree info |

Script reads JSON from stdin and prints text to stdout. Subagent status: `"subagentStatusLine"` setting.

### Checkpointing

| Action | How to trigger |
|---|---|
| Open rewind menu | `/rewind` or double-press Esc |
| Restore code + conversation | Choose in menu |
| Restore conversation only | Choose in menu |
| Restore code only | Choose in menu |
| Summarize from checkpoint | Choose in menu |
| Summarize up to checkpoint | Choose in menu |

Note: Bash command side-effects (file deletions via shell, etc.) are NOT tracked — only file edits Claude made directly.

### Remote Control

| Mode | Command | Notes |
|---|---|---|
| Server (headless) | `claude remote-control` | Listens for connections |
| Client flag | `claude --remote-control` or `claude --rc` | Connects to running server |
| In-session | `/remote-control` | Toggle during session |
| Spawn mode | `--spawn same-dir\|worktree\|session` | Controls new session isolation |

**Mobile push notifications**: configure via `/config` → Remote Control

**Requirement**: Subscription only (not API-key billing)

### Scheduled Tasks (Loops)

| Command form | Behavior |
|---|---|
| `/loop <interval> <prompt>` | Repeat prompt on interval |
| `/loop <prompt>` | Run prompt once on schedule |
| `/loop` (bare) | Opens interactive scheduler |

**CronCreate / CronList / CronDelete**: tools Claude can call to manage loops programmatically

**Expiry**: 7 days

**Customization**: `loop.md` file in project root

**Disable**: `CLAUDE_CODE_DISABLE_CRON=1`

### Voice Dictation

| Mode | Trigger | Behavior |
|---|---|---|
| Hold mode | Hold Space | Records while held, submits on release |
| Tap mode | Tap Space | Toggle record on/off |
| Off | — | Disable voice |

**Enable**: `/voice [hold|tap|off]`

**Options**: `autoSubmit` (auto-send after dictation), `language` (locale hint)

**Rebind**: set `voice:pushToTalk` in `keybindings.json`

### Channels (Inbound MCP Events)

| Item | Detail |
|---|---|
| What it does | MCP servers push events into running Claude sessions |
| Available plugins | Telegram, Discord, iMessage (and `fakechat` demo) |
| Enable | `--channels` flag at launch |
| Sender allowlists | Configured per-channel plugin |
| Disable all | `"channelsEnabled": false` in enterprise settings |
| Restrict plugins | `"allowedChannelPlugins": [...]` in enterprise settings |

**Custom channel** capability declaration: `claude/channel` in MCP manifest; emit with `notifications/claude/channel`; gate with `claude/channel/permission`

**Test locally**: `--dangerously-load-development-channels`

### Desktop Scheduled Tasks

| Type | Runs on |
|---|---|
| Local | Your machine (requires it to be on) |
| Remote | Anthropic cloud infrastructure |

**Schedules**: Manual, Hourly, Daily, Weekdays, Weekly

**Missed runs**: one catch-up run per wake (not backfill)

**Worktree toggle**: each task can run in an isolated worktree

**Update programmatically**: `update_scheduled_task` MCP tool

### Context Window

| Feature | Command |
|---|---|
| Show context usage | `/context` |
| Add memory | `/memory` |
| Trigger compaction | Automatic when near limit, or via compact action |

**Context loading by feature**: CLAUDE.md < Skills < MCP < conversation history

**What survives compaction**: CLAUDE.md, skills, MCP tools, project settings — conversation history is summarized

### Fullscreen / TUI

| Feature | How |
|---|---|
| Enter fullscreen | `/tui` or set `CLAUDE_CODE_NO_FLICKER=1` |
| Transcript view | Ctrl+O (less-style navigation: j/k, PgUp/PgDn, q) |
| Mouse support | Click to expand, click URL, drag to select |
| Scroll speed | `CLAUDE_CODE_SCROLL_SPEED=<n>` |
| Disable mouse | `CLAUDE_CODE_DISABLE_MOUSE=1` |

### Cloud Routines

| Trigger | How |
|---|---|
| Scheduled | `/schedule` command; minimum 1-hour interval |
| API | POST to `/fire` endpoint with bearer token |
| GitHub event | PR events, release events |

**Runs on**: Anthropic's infrastructure (not your machine)

**Limits**: daily cap + usage credits apply

### Deep Links

| Scheme | Use case |
|---|---|
| `claude-cli://open` | Open Claude Code from any app or browser |
| `vscode://anthropic.claude-code/open` | Open inside VS Code |

**Parameters**: `q` (prompt text, max 5000 chars), `cwd` (absolute path), `repo` (owner/name slug)

**Registration**: auto-registered on first interactive session

### Agent View

| Action | Key |
|---|---|
| Open agent view | `claude agents` |
| Peek at session | Space |
| Attach to session | Enter or → |
| Detach from session | ← |

**Session states**: working, needs input, idle, completed, failed, stopped

**Background launch**: `/bg <prompt>` or `claude --bg "<prompt>"`

**Worktree isolation**: each background session gets its own worktree automatically

**Disable**: `CLAUDE_CODE_DISABLE_AGENT_VIEW=1`

### Parallel Agents Comparison

| Approach | Coordinator | Workers communicate? | File isolation |
|---|---|---|---|
| Subagents | Claude (in-session) | Report back to parent only | Optional worktrees |
| Agent view | You (check back later) | No | Auto worktrees |
| Agent teams | Claude (lead assigns tasks) | Shared task list + messages | Manual file partitioning |
| Dynamic workflows | Script | No (results cross-checked by script) | Per-subagent worktrees |

**`/batch`**: skill that splits one large change into 5–30 worktree-isolated subagents, each opening a PR

### Worktrees

| Item | Detail |
|---|---|
| Create worktree session | `claude --worktree <name>` or `-w <name>` |
| Auto-name | Omit name: `claude --worktree` generates `bright-running-fox`-style names |
| Default location | `.claude/worktrees/<name>/` at repo root |
| Base branch | `origin/HEAD` by default; `"worktree.baseRef": "head"` to use local HEAD |
| Branch from PR | `claude --worktree "#1234"` |
| Copy gitignored files | List patterns in `.worktreeinclude` |
| Subagent isolation | `isolation: worktree` in custom subagent frontmatter |
| Non-git VCS | Configure `WorktreeCreate` and `WorktreeRemove` hooks |

**Cleanup**: auto-removed if no uncommitted changes/untracked files/new commits; otherwise Claude prompts

### Prompt Caching

**Actions that INVALIDATE the cache:**

| Action | Effect |
|---|---|
| Switch model | Full cache bust |
| Change effort level | Full cache bust |
| Enable fast mode | Full cache bust |
| Connect/disconnect MCP | Full cache bust |
| Enable/disable plugin | Full cache bust |
| Deny a tool | Full cache bust |
| `/compact` | Conversation cache replaced |
| Claude Code upgrade | System prompt may change |

**Actions that KEEP the cache:**

- Add/remove CLAUDE.md content that doesn't change the system prompt prefix
- Toggle `/advisor`
- Most settings that don't affect the model or tools

**TTL**: 5 minutes (standard) or 1 hour (extended, subscription)

**Disable**: `DISABLE_PROMPT_CACHING=1`

### Advisor Tool

| Item | Detail |
|---|---|
| Enable | `/advisor <model>`, `"advisorModel": "opus"` in settings, or `--advisor opus` flag |
| Disable | `/advisor off` or choose "No advisor" in picker |
| Disable entirely | `CLAUDE_CODE_DISABLE_ADVISOR_TOOL=1` |
| Requirement | Anthropic API only (not Bedrock/Vertex/Foundry), Claude Code v2.1.98+ |

**Accepted pairings:**

| Main model | Accepted advisors |
|---|---|
| Haiku 4.5 | Fable, Opus, Sonnet |
| Sonnet 4.6 | Fable, Opus, Sonnet |
| Opus 4.6+ | Fable, Opus at same version or higher |
| Fable 5 (v2.1.170+) | Fable only |

**When it runs**: Claude decides — typically before committing to an approach, when an error recurs, and before declaring done. Say "consult the advisor before continuing" to request it.

**Cache impact**: toggling `/advisor` does NOT invalidate the prompt cache.

---

## Full Documentation

- [features-overview](references/claude-code-features-overview.md) — Extension layer overview: CLAUDE.md, Skills, MCP, Subagents, Agent teams, Code intelligence, Hooks, Plugins; feature comparison tables; context costs by feature
- [fast-mode](references/claude-code-fast-mode.md) — `/fast` toggle for Opus; up to 2.5× faster; pricing tiers; `fastModePerSessionOptIn` setting
- [model-config](references/claude-code-model-config.md) — Model aliases; Fable 5 access; `/model` command; effort levels; fallback chains; extended context (1M tokens); `availableModels` restriction; env vars
- [output-styles](references/claude-code-output-styles.md) — Built-in styles (Default/Proactive/Explanatory/Learning); `/config` to change; custom output style via Markdown file with frontmatter
- [statusline](references/claude-code-statusline.md) — `/statusline` command; `statusLine` config; JSON data fields; script examples in Bash/Python/Node.js; `subagentStatusLine`
- [checkpointing](references/claude-code-checkpointing.md) — Automatic file-edit tracking; `/rewind` (or double Esc); restore/summarize actions; Bash command changes not tracked
- [remote-control](references/claude-code-remote-control.md) — `claude remote-control` server mode; `--remote-control`/`--rc` client flag; `/remote-control` in-session; `--spawn` modes; mobile push notifications; subscription-only
- [scheduled-tasks](references/claude-code-scheduled-tasks.md) — `/loop` command variants; CronCreate/CronList/CronDelete tools; 7-day expiry; `loop.md` customization; `CLAUDE_CODE_DISABLE_CRON=1`
- [voice-dictation](references/claude-code-voice-dictation.md) — `/voice [hold|tap|off]`; hold vs tap modes; `autoSubmit`; `language` option; rebind via `keybindings.json`
- [channels](references/claude-code-channels.md) — MCP servers pushing events into sessions; Telegram/Discord/iMessage plugins; `--channels` flag; sender allowlists; enterprise controls
- [channels-reference](references/claude-code-channels-reference.md) — Building custom channels; `claude/channel` capability; emit with `notifications/claude/channel`; reply tools; permission relay; `--dangerously-load-development-channels`
- [desktop-scheduled-tasks](references/claude-code-desktop-scheduled-tasks.md) — Desktop app Routines page; local vs remote tasks; worktree toggle; schedule options; missed-run catch-up; `update_scheduled_task` MCP tool
- [context-window](references/claude-code-context-window.md) — Context loading by feature; compaction survival; `/context` and `/memory` commands
- [fullscreen](references/claude-code-fullscreen.md) — `/tui` fullscreen; `CLAUDE_CODE_NO_FLICKER=1`; alternate screen buffer; mouse support; Ctrl+O transcript mode; scroll env vars
- [routines](references/claude-code-routines.md) — Cloud routines on Anthropic infrastructure; scheduled/API/GitHub event triggers; `/schedule` CLI command; daily cap + usage credits
- [deep-links](references/claude-code-deep-links.md) — `claude-cli://open` URL scheme; `q`/`cwd`/`repo` params; VS Code variant; auto-registration
- [agent-view](references/claude-code-agent-view.md) — `claude agents` command; background sessions; peek/attach/detach keys; state icons; `/bg` and `claude --bg`; auto worktree isolation; `CLAUDE_CODE_DISABLE_AGENT_VIEW`
- [agents](references/claude-code-agents.md) — Comparison of Subagents vs Agent view vs Agent teams vs Dynamic workflows; `/batch`; background bash commands; forked subagents; routines
- [worktrees](references/claude-code-worktrees.md) — `--worktree` flag; `.worktreeinclude`; subagent `isolation: worktree`; `WorktreeCreate`/`WorktreeRemove` hooks; `baseRef` setting; cleanup rules
- [prompt-caching](references/claude-code-prompt-caching.md) — Cache layers; actions that invalidate vs keep cache; TTL; `DISABLE_PROMPT_CACHING`
- [prompt-library](references/claude-code-prompt-library.md) — 50+ example prompts; patterns: describe outcome not steps, give Claude a way to check its own work, point at reference, state measurable targets
- [advisor](references/claude-code-advisor.md) — `/advisor` command; `advisorModel` setting; `--advisor` flag; accepted pairings; consultation timing; cost; cache impact; requirements

---

## Sources

- https://code.claude.com/docs/en/features-overview.md
- https://code.claude.com/docs/en/fast-mode.md
- https://code.claude.com/docs/en/model-config.md
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
