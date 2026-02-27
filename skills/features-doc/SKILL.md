---
name: features-doc
description: Reference documentation for Claude Code features including fast mode, model configuration (aliases, effort levels, extended context, opusplan), output styles, status line customization, checkpointing and rewind, the features overview (extension comparison table), and Remote Control for continuing local sessions from other devices.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features: fast mode, model configuration, output styles, status line, checkpointing, the features/extensions overview, and Remote Control.

## Quick Reference

### Model Aliases

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended model for your account type (Max/Team Premium = Opus 4.6, Pro/Team Standard = Sonnet 4.6) |
| `sonnet` | Latest Sonnet model (currently Sonnet 4.6) |
| `opus` | Latest Opus model (currently Opus 4.6) |
| `haiku` | Fast, efficient Haiku model for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opusplan` | Opus for plan mode, Sonnet for execution |

Set model: `/model <alias>`, `claude --model <alias>`, `ANTHROPIC_MODEL=<alias>`, or `model` in settings.

### Effort Levels

| Level | Behavior |
|:------|:---------|
| `low` | Faster, cheaper, less reasoning |
| `medium` | Balanced |
| `high` (default) | Deepest reasoning for complex tasks |

Set via `/model` slider, `CLAUDE_CODE_EFFORT_LEVEL`, or `effortLevel` in settings. Supported on Opus 4.6.

### Fast Mode

Toggle with `/fast`. Same Opus 4.6 model, 2.5x faster, higher cost. Persists across sessions by default.

| Mode | Input (MTok) | Output (MTok) |
|:-----|:-------------|:--------------|
| Fast mode (<200K) | $30 | $150 |
| Fast mode (>200K) | $60 | $225 |

Requirements: not available on third-party cloud providers (Bedrock/Vertex/Foundry), extra usage must be enabled, admin enablement needed for Teams/Enterprise. Falls back to standard Opus on rate limit (gray icon). Disable: `CLAUDE_CODE_DISABLE_FAST_MODE=1`.

### Model Environment Variables

| Variable | Controls |
|:---------|:---------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for `opus` alias / `opusplan` plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` alias / `opusplan` execution |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for `haiku` alias / background tasks |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |

### Output Styles

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Adds educational "Insights" while coding |
| **Learning** | Collaborative mode with `TODO(human)` markers for you to implement |
| **Custom** | Your own `.md` file in `~/.claude/output-styles` or `.claude/output-styles` |

Switch with `/output-style [style]` or via `/config`. Custom styles modify the system prompt; use `keep-coding-instructions: true` in frontmatter to retain coding instructions.

### Checkpointing

Automatic tracking of all file edits made by Claude's editing tools. Press `Esc` + `Esc` or use `/rewind` to open the rewind menu.

| Action | Effect |
|:-------|:-------|
| Restore code and conversation | Revert both to selected point |
| Restore conversation | Rewind messages, keep current code |
| Restore code | Revert files, keep conversation |
| Summarize from here | Compress messages from selected point into a summary |

Limitations: bash command changes and external edits are not tracked. Not a replacement for git.

### Status Line

Customizable bar at the bottom of Claude Code. Configure via `/statusline` or add `statusLine` to settings:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

Key JSON fields available to your script (via stdin):

| Field | Description |
|:------|:------------|
| `model.id`, `model.display_name` | Current model |
| `context_window.used_percentage` | Context usage % |
| `cost.total_cost_usd` | Session cost |
| `cost.total_duration_ms` | Session wall-clock time |
| `workspace.current_dir` | Working directory |
| `session_id` | Session identifier |

### Remote Control

Continue local CLI sessions from any device via claude.ai/code or the Claude mobile app. Session runs locally; the web/mobile interface is a window into it.

Start: `claude remote-control` (new session) or `/remote-control` (existing session). Connect via session URL, QR code, or find in session list. Enable for all sessions via `/config`.

Requirements: Max plan (Pro coming soon), signed in via `/login`, workspace trust accepted. One remote session per Claude Code instance. Terminal must stay open.

### Extension Feature Comparison

| Feature | What it does | When to use |
|:--------|:-------------|:------------|
| **CLAUDE.md** | Persistent context every session | "Always do X" rules |
| **Skill** | On-demand knowledge and workflows | Reference docs, repeatable tasks |
| **Subagent** | Isolated execution context | Context isolation, parallel tasks |
| **Agent teams** | Multiple independent sessions | Parallel research, competing hypotheses |
| **MCP** | External service connections | Database queries, Slack, browser |
| **Hook** | Deterministic script on events | Linting, logging, no LLM involved |
| **Plugin** | Packaging layer for all above | Multi-repo reuse, distribution |

### Context Cost by Feature

| Feature | When it loads | Context cost |
|:--------|:-------------|:-------------|
| CLAUDE.md | Session start | Every request |
| Skills | Start (descriptions) + when used | Low until used |
| MCP servers | Session start | Every request |
| Subagents | When spawned | Isolated |
| Hooks | On trigger | Zero (unless returning output) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Features Overview](references/claude-code-features-overview.md) -- extension comparison (CLAUDE.md vs Skills vs MCP vs Subagents vs Hooks vs Plugins), feature layering, context costs
- [Fast Mode](references/claude-code-fast-mode.md) -- toggling, pricing, requirements, per-session opt-in, rate limit behavior
- [Model Configuration](references/claude-code-model-config.md) -- model aliases, setting models, effort levels, extended 1M context, environment variables, prompt caching
- [Output Styles](references/claude-code-output-styles.md) -- built-in styles, custom output style creation, frontmatter options
- [Status Line](references/claude-code-statusline.md) -- setup, available JSON data fields, ANSI colors, multi-line output, examples
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic tracking, rewind menu, restore vs summarize, limitations
- [Remote Control](references/claude-code-remote-control.md) -- starting sessions, connecting from other devices, security, comparison with Claude Code on the web

## Sources

- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
