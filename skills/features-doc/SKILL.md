---
name: features-doc
description: Complete documentation for Claude Code features — extensibility overview (CLAUDE.md, Skills, MCP, Subagents, Agent teams, Hooks, Plugins and how they layer/combine), fast mode (toggle, pricing, rate limits, per-session opt-in), model configuration (aliases, effort levels, extended 1M context, availableModels restriction, opusplan, prompt caching env vars), output styles (built-in styles, custom style creation, frontmatter options), status line customization (setup, available JSON data fields, script examples), checkpointing (automatic tracking, rewind/summarize, limitations), and Remote Control (starting sessions, connecting from other devices, security model). Load when discussing feature comparisons, model selection, effort tuning, fast mode, output styles, status line, checkpoints, rewind, or remote control sessions.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features including the extensibility overview, fast mode, model configuration, output styles, status line, checkpointing, and Remote Control.

## Quick Reference

### Extensibility Overview

Features plug into different parts of the agentic loop:

| Feature | What it does | When to use it |
|:--------|:-------------|:---------------|
| **CLAUDE.md** | Persistent context loaded every session | Project conventions, "always do X" rules |
| **Skill** | Instructions, knowledge, and workflows | Reusable content, reference docs, repeatable tasks |
| **Subagent** | Isolated execution context returning summaries | Context isolation, parallel tasks, specialized workers |
| **Agent teams** | Coordinate multiple independent sessions | Parallel research, competing hypotheses, new features |
| **MCP** | Connect to external services | External data or actions (DB, Slack, browser) |
| **Hook** | Deterministic script on events | Predictable automation, no LLM involved |
| **Plugin** | Package and distribute feature bundles | Reuse across repos, distribute via marketplaces |

#### Context Cost by Feature

| Feature | When it loads | Context cost |
|:--------|:-------------|:-------------|
| CLAUDE.md | Session start | Every request |
| Skills | Descriptions at start, full on use | Low (descriptions only)\* |
| MCP servers | Session start | Every request (tool schemas) |
| Subagents | When spawned | Isolated from main session |
| Hooks | On trigger | Zero (runs externally) |

\*Set `disable-model-invocation: true` to reduce cost to zero until manually invoked.

#### Feature Layering

- **CLAUDE.md** files are additive (all levels contribute)
- **Skills/subagents** override by name (priority: managed > user > project)
- **MCP servers** override by name (local > project > user)
- **Hooks** merge (all fire for matching events)

### Fast Mode

Fast mode is a high-speed configuration for Opus 4.6 -- same model, 2.5x faster, higher cost per token. Toggle with `/fast`.

| Mode | Input (MTok) | Output (MTok) |
|:-----|:-------------|:--------------|
| Fast mode (<200K) | $30 | $150 |
| Fast mode (>200K) | $60 | $225 |

- Available on subscription plans (Pro/Max/Team/Enterprise) and Console
- Billed as extra usage from the first token (not from plan quota)
- Compatible with the 1M extended context window
- Switching mid-conversation incurs full uncached input pricing for the entire context

#### Fast Mode vs Effort Level

| Setting | Effect |
|:--------|:-------|
| Fast mode | Same quality, lower latency, higher cost |
| Lower effort level | Less thinking, faster, potentially lower quality on complex tasks |

Both can be combined for maximum speed on straightforward tasks.

#### Requirements & Controls

- Not available on Bedrock, Vertex AI, or Foundry
- Extra usage must be enabled on the account
- Disabled by default for Teams/Enterprise (admin must enable)
- Disable entirely: `CLAUDE_CODE_DISABLE_FAST_MODE=1`
- Per-session opt-in: set `fastModePerSessionOptIn: true` in managed settings
- Rate limit fallback: automatically falls back to standard Opus 4.6, indicated by gray lightning icon

### Model Configuration

#### Model Aliases

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended model based on account type |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast/efficient Haiku for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opusplan` | Opus for planning, Sonnet for execution |

#### Setting the Model (priority order)

1. `/model <alias|name>` during session
2. `claude --model <alias|name>` at startup
3. `ANTHROPIC_MODEL=<alias|name>` env var
4. `model` field in settings file

#### Default Model by Account Type

| Account type | Default model |
|:-------------|:-------------|
| Max, Team Premium | Opus 4.6 |
| Pro, Team Standard | Sonnet 4.6 |
| Enterprise | Opus available but not default |

#### Effort Levels

Three levels: **low**, **medium**, **high**. Opus 4.6 defaults to medium for Max/Team subscribers.

Set via:
- `/model` left/right arrows for the effort slider
- `CLAUDE_CODE_EFFORT_LEVEL=low|medium|high`
- `effortLevel` in settings file

Disable adaptive reasoning: `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1` (reverts to fixed budget via `MAX_THINKING_TOKENS`).

#### Extended Context (1M)

Available for Opus 4.6 and Sonnet 4.6. Standard rates apply up to 200K tokens; beyond 200K, long-context pricing kicks in (billed as extra usage for subscribers).

Disable: `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`

Use `[1m]` suffix: `/model sonnet[1m]` or `/model claude-sonnet-4-6[1m]`

#### Restrict Model Selection

Set `availableModels` in managed/policy settings to restrict which models users can select. The `default` option always remains available regardless of this setting.

#### Model Environment Variables

| Variable | Controls |
|:---------|:---------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for `opus` / `opusplan` plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` / `opusplan` exec mode |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for `haiku` / background tasks |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |

#### Prompt Caching Environment Variables

| Variable | Description |
|:---------|:------------|
| `DISABLE_PROMPT_CACHING` | Disable for all models (overrides per-model) |
| `DISABLE_PROMPT_CACHING_HAIKU` | Disable for Haiku only |
| `DISABLE_PROMPT_CACHING_SONNET` | Disable for Sonnet only |
| `DISABLE_PROMPT_CACHING_OPUS` | Disable for Opus only |

### Output Styles

Output styles modify Claude Code's system prompt to adapt it for different use cases.

#### Built-in Styles

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Provides educational "Insights" between tasks |
| **Learning** | Collaborative mode with `TODO(human)` markers for you to implement |

Switch with `/output-style` or `/output-style <name>`. Saved in `.claude/settings.local.json` (`outputStyle` field).

#### Custom Output Styles

Markdown files with frontmatter, placed in `~/.claude/output-styles` (user) or `.claude/output-styles` (project).

| Frontmatter | Purpose | Default |
|:------------|:--------|:--------|
| `name` | Display name | File name |
| `description` | Description shown in `/output-style` UI | None |
| `keep-coding-instructions` | Keep default coding instructions in system prompt | `false` |

#### Key Differences

- **Output styles vs CLAUDE.md**: Styles modify the system prompt; CLAUDE.md adds user-level context after it
- **Output styles vs `--append-system-prompt`**: Styles replace default prompt sections; the flag appends to the prompt
- **Output styles vs Agents**: Styles affect the main loop's system prompt only; agents run in isolated context with custom tools/model

### Status Line

A customizable bar at the bottom of Claude Code that runs a shell script receiving JSON session data on stdin.

#### Setup

Use `/statusline <description>` for auto-generation, or manually configure in settings:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

#### Key Available Data Fields

| Field | Description |
|:------|:------------|
| `model.id`, `model.display_name` | Current model |
| `cwd`, `workspace.current_dir` | Working directory |
| `workspace.project_dir` | Launch directory |
| `cost.total_cost_usd` | Session cost in USD |
| `cost.total_duration_ms` | Wall-clock session time |
| `context_window.used_percentage` | Context usage % |
| `context_window.remaining_percentage` | Context remaining % |
| `context_window.context_window_size` | Max tokens (200K or 1M) |
| `session_id` | Session identifier |
| `vim.mode` | Vim mode (if enabled) |
| `agent.name` | Agent name (if running with `--agent`) |
| `worktree.name` | Worktree name (if in `--worktree` session) |

Updates after each assistant message, debounced at 300ms. Does not consume API tokens.

Supports: multiple lines, ANSI colors, OSC 8 clickable links.

### Checkpointing

Automatic tracking of Claude's file edits for quick undo/rewind.

- Every user prompt creates a checkpoint
- Checkpoints persist across sessions (cleaned up after 30 days)
- Access with `Esc` + `Esc` or `/rewind`

#### Rewind Actions

| Action | Effect |
|:-------|:-------|
| Restore code and conversation | Revert both to selected point |
| Restore conversation | Rewind messages, keep current code |
| Restore code | Revert files, keep conversation |
| Summarize from here | Compress messages from this point forward |

**Summarize** differs from restore: it replaces messages with a compact summary without changing files on disk. Original messages remain in the transcript for reference.

#### Limitations

- Bash command file changes (rm, mv, cp) are **not** tracked
- External changes outside Claude Code are normally not captured
- Not a replacement for Git -- checkpoints are session-level "local undo"

### Remote Control

Continue local Claude Code sessions from any device via claude.ai/code or the Claude mobile app (iOS/Android). The session runs on your local machine; the remote interface is just a window into it.

#### Starting a Session

```bash
# New Remote Control session
claude remote-control

# With a custom name
claude remote-control --name "My Project"

# From an existing session
/remote-control
# or /rc
```

Flags for `claude remote-control`: `--name`, `--verbose`, `--sandbox` / `--no-sandbox`

#### Connecting

- Open the session URL displayed in the terminal
- Scan the QR code (press spacebar to toggle)
- Find the session by name in claude.ai/code or the Claude app

Enable for all sessions: `/config` > "Enable Remote Control for all sessions"

#### Requirements

- Max plan required (Pro coming soon); API keys not supported
- Must be authenticated via `/login`
- Workspace trust must be accepted

#### Remote Control vs Claude Code on the Web

| Aspect | Remote Control | Claude Code on the web |
|:-------|:---------------|:-----------------------|
| Execution | Your local machine | Anthropic cloud infrastructure |
| Local tools/MCP | Available | Not available |
| Use when | Continuing local work from another device | Starting fresh without local setup |

#### Limitations

- One remote session per Claude Code instance
- Terminal must stay open (process exit ends the session)
- Extended network outage (~10 min) causes timeout and exit

## Full Documentation

For the complete official documentation, see the reference files:

- [Extend Claude Code (features overview)](references/claude-code-features-overview.md) -- extensibility overview, feature comparison, context costs, layering, and combining features
- [Speed up responses with fast mode](references/claude-code-fast-mode.md) -- toggling fast mode, pricing, requirements, per-session opt-in, rate limit behavior
- [Model configuration](references/claude-code-model-config.md) -- model aliases, setting models, effort levels, extended context, availableModels, environment variables, prompt caching
- [Output styles](references/claude-code-output-styles.md) -- built-in styles, custom style creation, frontmatter options, comparisons to related features
- [Customize your status line](references/claude-code-statusline.md) -- setup, available JSON data fields, script examples for context bars, git status, cost tracking
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic tracking, rewind/summarize actions, limitations
- [Remote Control](references/claude-code-remote-control.md) -- starting sessions, connecting from other devices, security, comparison to Claude Code on the web

## Sources

- Extend Claude Code (features overview): https://code.claude.com/docs/en/features-overview.md
- Speed up responses with fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Customize your status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
