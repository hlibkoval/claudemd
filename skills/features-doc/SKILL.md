---
name: features-doc
description: Complete documentation for Claude Code features and configuration — model configuration (aliases, effort levels, extended context, opusplan, availableModels, prompt caching), fast mode (toggling, pricing, rate limits, per-session opt-in), output styles (built-in styles, custom styles, frontmatter, keep-coding-instructions), status line (setup, /statusline command, JSON data fields, script examples, ANSI colors, OSC 8 links, caching, multi-line, Windows), checkpointing (rewind, restore, summarize, /rewind menu, limitations), remote control (setup, connection, QR code, /remote-control, /rc, security), and features overview (extension comparison table, context costs, feature layering). Load when discussing model selection, /model, /fast, effort levels, opusplan, output styles, /output-style, status line, /statusline, checkpointing, /rewind, undo, restore, remote control, /remote-control, or the extensibility overview.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features and configuration options.

## Quick Reference

### Model Configuration

#### Model Aliases

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended model for your account type |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast and efficient Haiku for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opusplan` | Opus for planning, Sonnet for execution |

#### Setting the Model

| Method | Priority | Example |
|:-------|:---------|:--------|
| During session | 1 (highest) | `/model sonnet` |
| At startup | 2 | `claude --model opus` |
| Environment variable | 3 | `ANTHROPIC_MODEL=opus` |
| Settings file | 4 (lowest) | `"model": "opus"` |

#### Default Model by Account Type

| Account | Default |
|:--------|:--------|
| Max / Team Premium | Opus 4.6 |
| Pro / Team Standard | Sonnet 4.6 |
| Enterprise | Opus 4.6 available but not the default |

#### Effort Levels

Three levels: **low**, **medium**, **high**. Opus 4.6 defaults to medium for Max and Team subscribers.

| Method | How to set |
|:-------|:-----------|
| `/model` menu | Left/right arrow keys to adjust slider |
| Environment variable | `CLAUDE_CODE_EFFORT_LEVEL=low\|medium\|high` |
| Settings file | `"effortLevel": "low\|medium\|high"` |

To disable adaptive reasoning: `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1` (reverts to fixed budget via `MAX_THINKING_TOKENS`).

#### Extended Context (1M)

Opus 4.6 and Sonnet 4.6 support 1M token context windows. Standard rates apply up to 200K tokens; beyond 200K, long-context pricing applies. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

Use `[1m]` suffix: `/model sonnet[1m]` or `/model claude-sonnet-4-6[1m]`.

#### Restrict Model Selection

Set `availableModels` in managed/policy settings to limit which models users can switch to:

```json
{ "availableModels": ["sonnet", "haiku"] }
```

The Default model always remains available regardless of this setting.

#### Model Environment Variables

| Variable | Controls |
|:---------|:---------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for `opus` / `opusplan` plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` / `opusplan` execution mode |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for `haiku` / background functionality |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |

#### Prompt Caching Control

| Variable | Effect |
|:---------|:-------|
| `DISABLE_PROMPT_CACHING` | `1` to disable for all models (overrides per-model) |
| `DISABLE_PROMPT_CACHING_HAIKU` | `1` to disable for Haiku only |
| `DISABLE_PROMPT_CACHING_SONNET` | `1` to disable for Sonnet only |
| `DISABLE_PROMPT_CACHING_OPUS` | `1` to disable for Opus only |

### Fast Mode

Fast mode is a high-speed configuration for Opus 4.6 -- 2.5x faster at higher cost. Same model quality and capabilities, just faster responses.

| Action | How |
|:-------|:----|
| Toggle on/off | `/fast` (persists across sessions by default) |
| Set in settings | `"fastMode": true` |
| Disable entirely | `CLAUDE_CODE_DISABLE_FAST_MODE=1` |

#### Fast Mode Pricing

| Mode | Input (MTok) | Output (MTok) |
|:-----|:-------------|:--------------|
| Fast mode on Opus 4.6 (<200K) | $30 | $150 |
| Fast mode on Opus 4.6 (>200K) | $60 | $225 |

Requirements: extra usage enabled, not available on Bedrock/Vertex/Foundry. For Teams/Enterprise: admin must explicitly enable fast mode.

#### Per-Session Opt-In

Set `"fastModePerSessionOptIn": true` in managed settings to require users to re-enable fast mode each session (resets on session start).

#### Rate Limit Behavior

When the fast mode rate limit is hit: automatic fallback to standard Opus 4.6, the lightning icon turns gray, and fast mode re-enables when cooldown expires.

### Output Styles

Output styles modify Claude Code's system prompt to adapt behavior for different use cases.

#### Built-in Styles

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Provides educational "Insights" while coding |
| **Learning** | Collaborative learn-by-doing mode with `TODO(human)` markers |

#### Changing Style

- `/output-style` -- opens selection menu
- `/output-style explanatory` -- switches directly
- Edit `outputStyle` in settings file

#### Custom Output Style Frontmatter

| Field | Purpose | Default |
|:------|:--------|:--------|
| `name` | Display name | Inherits from file name |
| `description` | UI description | None |
| `keep-coding-instructions` | Keep coding-related system prompt parts | `false` |

Custom styles are Markdown files saved to `~/.claude/output-styles` (user) or `.claude/output-styles` (project).

### Status Line

A customizable bar at the bottom of Claude Code that runs any shell script, receiving JSON session data on stdin.

#### Setup

| Method | Description |
|:-------|:------------|
| `/statusline <description>` | Auto-generates a script from natural language |
| Manual | Create script, add `statusLine` config to settings |

#### Settings Configuration

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

#### Available JSON Data Fields

| Field | Description |
|:------|:------------|
| `model.id`, `model.display_name` | Current model |
| `cwd`, `workspace.current_dir` | Current working directory |
| `workspace.project_dir` | Directory where Claude Code was launched |
| `cost.total_cost_usd` | Session cost in USD |
| `cost.total_duration_ms` | Wall-clock time since session start |
| `cost.total_api_duration_ms` | Time waiting for API responses |
| `cost.total_lines_added`, `cost.total_lines_removed` | Lines of code changed |
| `context_window.context_window_size` | Max context window (200K or 1M) |
| `context_window.used_percentage` | Pre-calculated context usage % |
| `context_window.remaining_percentage` | Pre-calculated context remaining % |
| `context_window.total_input_tokens` | Cumulative input tokens |
| `context_window.total_output_tokens` | Cumulative output tokens |
| `context_window.current_usage` | Token counts from last API call |
| `exceeds_200k_tokens` | Whether last response exceeded 200K tokens |
| `session_id` | Unique session identifier |
| `transcript_path` | Path to conversation transcript |
| `version` | Claude Code version |
| `output_style.name` | Current output style |
| `vim.mode` | Vim mode (`NORMAL`/`INSERT`) when enabled |
| `agent.name` | Agent name (when using `--agent`) |
| `worktree.name`, `worktree.path`, `worktree.branch` | Worktree info (when active) |

The `context_window.current_usage` object contains `input_tokens`, `output_tokens`, `cache_creation_input_tokens`, and `cache_read_input_tokens`. It is `null` before the first API call.

#### Script Output Capabilities

- **Multiple lines**: each print/echo creates a separate row
- **Colors**: ANSI escape codes (e.g., `\033[32m` for green)
- **Links**: OSC 8 escape sequences for clickable text (terminal support required)

Updates run after each assistant message, permission mode change, or vim mode toggle. Debounced at 300ms.

### Checkpointing

Claude Code automatically captures the state of your code before each edit, creating a safety net for undoing changes.

#### Rewind Menu

Open with `Esc` + `Esc` (double-press) or `/rewind`. Actions available:

| Action | Effect |
|:-------|:-------|
| **Restore code and conversation** | Revert both to the selected point |
| **Restore conversation** | Rewind messages, keep current code |
| **Restore code** | Revert files, keep conversation |
| **Summarize from here** | Compress conversation from this point forward |

After restoring or summarizing, the original prompt is restored to the input field for re-sending or editing.

#### Summarize vs Restore

Summarize keeps the session and compresses context (similar to `/compact` but targeted). Messages before the selected point stay intact; messages from that point onward are replaced with a summary. No files on disk are changed.

#### Limitations

- Bash command changes are not tracked (only direct file editing tools are tracked)
- External changes outside Claude Code are not captured
- Not a replacement for version control -- complements git

### Remote Control

Continue a local Claude Code session from your phone, tablet, or any browser via claude.ai/code or the Claude mobile app. The session runs locally on your machine.

#### Starting

| Method | Command |
|:-------|:--------|
| New session | `claude remote-control` |
| Existing session | `/remote-control` or `/rc` |

Flags for `claude remote-control`: `--name "title"`, `--verbose`, `--sandbox` / `--no-sandbox`.

#### Connecting

- Open the session URL displayed in the terminal
- Scan the QR code (press spacebar to toggle)
- Find the session in claude.ai/code or the Claude app

#### Enable for All Sessions

In `/config`, set **Enable Remote Control for all sessions** to `true`.

#### Requirements

- Pro, Max, Team, or Enterprise plan (Team/Enterprise admins must enable Claude Code)
- Signed in via `/login`
- Workspace trust accepted

#### Limitations

- One remote session per Claude Code instance
- Terminal must stay open (local process)
- Extended network outage (~10 min) causes session timeout

### Features Overview (Extensibility)

The features overview doc describes how CLAUDE.md, Skills, MCP, Subagents, Agent teams, Hooks, and Plugins relate to each other.

#### Feature Comparison

| Feature | What it does | When to use it |
|:--------|:-------------|:---------------|
| **CLAUDE.md** | Persistent context every session | Project conventions, "always do X" rules |
| **Skill** | Instructions and workflows | Reusable content, reference docs, repeatable tasks |
| **Subagent** | Isolated execution context | Context isolation, parallel tasks |
| **Agent teams** | Multiple independent sessions | Parallel research, collaboration |
| **MCP** | Connect to external services | External data or actions |
| **Hook** | Deterministic script on events | Predictable automation |

#### Context Cost by Feature

| Feature | When it loads | Context cost |
|:--------|:-------------|:-------------|
| CLAUDE.md | Session start | Every request |
| Skills | Session start (descriptions) + when used | Low (descriptions only until used) |
| MCP servers | Session start | Every request (tool definitions) |
| Subagents | When spawned | Isolated from main session |
| Hooks | On trigger | Zero (runs externally) |

#### Feature Layering Rules

- **CLAUDE.md**: additive -- all levels contribute simultaneously
- **Skills/Subagents**: override by name based on priority
- **MCP servers**: override by name (local > project > user)
- **Hooks**: merge -- all registered hooks fire for matching events

## Full Documentation

For the complete official documentation, see the reference files:

- [Model configuration](references/claude-code-model-config.md) -- model aliases, setting models, availableModels, opusplan, effort levels, extended context, environment variables, third-party provider pinning, prompt caching
- [Fast mode](references/claude-code-fast-mode.md) -- toggling, pricing, cost tradeoff, when to use, requirements, admin enablement, per-session opt-in, rate limits
- [Output styles](references/claude-code-output-styles.md) -- built-in styles, how styles modify the system prompt, changing styles, custom style creation, frontmatter, comparisons to CLAUDE.md and agents
- [Status line](references/claude-code-statusline.md) -- setup via /statusline or manual config, JSON data schema, context window fields, script examples (context bar, git status, cost tracking, multi-line, clickable links, caching, Windows), troubleshooting
- [Checkpointing](references/claude-code-checkpointing.md) -- how checkpoints work, rewind menu, restore vs summarize, common use cases, limitations
- [Features overview](references/claude-code-features-overview.md) -- extension comparison table, feature layering, context costs, combining features, CLAUDE.md vs skills vs rules
- [Remote control](references/claude-code-remote-control.md) -- starting sessions, connecting from other devices, requirements, security, comparison to Claude Code on the web, limitations

## Sources

- Model configuration: https://code.claude.com/docs/en/model-config.md
- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Features overview: https://code.claude.com/docs/en/features-overview.md
- Remote control: https://code.claude.com/docs/en/remote-control.md
