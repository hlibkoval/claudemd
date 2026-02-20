---
name: features
description: Reference documentation for Claude Code features — model configuration (aliases, effort levels, extended context, opusplan), fast mode (2.5x speed toggle), output styles (custom system prompts), status line customization, checkpointing (rewind/restore/summarize), and the extensibility overview (CLAUDE.md, skills, MCP, hooks, subagents, plugins comparison).
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features including model configuration, fast mode, output styles, status line customization, checkpointing, and the extensibility features overview.

## Quick Reference

### Model Configuration

#### Model Aliases

| Alias        | Behavior                                                                 |
|:-------------|:-------------------------------------------------------------------------|
| `default`    | Recommended model for your account type                                  |
| `sonnet`     | Latest Sonnet (currently Sonnet 4.6)                                     |
| `opus`       | Latest Opus (currently Opus 4.6)                                         |
| `haiku`      | Fast and efficient Haiku for simple tasks                                |
| `sonnet[1m]` | Sonnet with 1M token context window                                      |
| `opusplan`   | Opus for planning, Sonnet for execution                                  |

Pin to a specific version with full model name (e.g., `claude-opus-4-6`) or environment variables.

#### Setting the Model

1. **In session:** `/model <alias|name>`
2. **At startup:** `claude --model <alias|name>`
3. **Environment variable:** `ANTHROPIC_MODEL=<alias|name>`
4. **Settings file:** `"model": "opus"`

#### Effort Levels

Three levels: **low**, **medium**, **high** (default). Set via `/model` slider, `CLAUDE_CODE_EFFORT_LEVEL` env var, or `effortLevel` in settings. Supported on Opus 4.6.

#### Model Environment Variables

| Variable                         | Controls                                    |
|:---------------------------------|:--------------------------------------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL`   | Model for `opus` / `opusplan` plan mode     |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` / `opusplan` exec mode   |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL`  | Model for `haiku` / background tasks        |
| `CLAUDE_CODE_SUBAGENT_MODEL`     | Model for subagents                         |

#### Default Model by Account Type

| Account type          | Default model |
|:----------------------|:--------------|
| Max, Team, Pro        | Opus 4.6      |
| Pay-as-you-go (API)   | Sonnet 4.5    |

### Fast Mode

Toggle with `/fast`. Same Opus 4.6 model, 2.5x faster, higher cost. Persists across sessions.

| Mode                            | Input (MTok) | Output (MTok) |
|:--------------------------------|:-------------|:--------------|
| Fast mode Opus 4.6 (<200K)      | $30          | $150          |
| Fast mode Opus 4.6 (>200K)      | $60          | $225          |

- Requires extra usage enabled; billed directly to extra usage
- Rate limit fallback: auto-falls back to standard speed, `fast-mode` icon turns gray
- Teams/Enterprise: admin must enable fast mode first

### Output Styles

Change with `/output-style` or `/output-style [style]`. Saved in `.claude/settings.local.json`.

| Built-in Style  | Purpose                                                        |
|:----------------|:---------------------------------------------------------------|
| **Default**     | Standard software engineering system prompt                    |
| **Explanatory** | Adds educational "Insights" while coding                       |
| **Learning**    | Collaborative learn-by-doing, adds `TODO(human)` markers      |

Custom output styles are Markdown files with frontmatter, saved in `~/.claude/output-styles` (user) or `.claude/output-styles` (project).

| Frontmatter                | Purpose                                          | Default   |
|:---------------------------|:-------------------------------------------------|:----------|
| `name`                     | Display name                                     | File name |
| `description`              | Shown in `/output-style` UI                      | None      |
| `keep-coding-instructions` | Keep coding parts of default system prompt       | false     |

### Checkpointing

Every user prompt creates a checkpoint. Press `Esc` twice or use `/rewind` to open the rewind menu.

| Action                          | Effect                                              |
|:--------------------------------|:----------------------------------------------------|
| Restore code and conversation   | Revert both to that point                           |
| Restore conversation            | Rewind messages, keep current code                  |
| Restore code                    | Revert files, keep conversation                     |
| Summarize from here             | Compress subsequent messages into a summary         |

Limitations: bash command changes and external edits are not tracked. Not a replacement for Git.

### Status Line

Customizable bar at the bottom of Claude Code. Runs a shell script receiving JSON session data on stdin.

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

Use `/statusline <description>` to auto-generate a script, or manually create one. Key available JSON fields: `model.display_name`, `context_window.used_percentage`, `cost.total_cost_usd`, `cost.total_duration_ms`, `workspace.current_dir`, `session_id`, `vim.mode`.

### Extensibility Overview

| Feature         | What it does                              | When to use                              |
|:----------------|:------------------------------------------|:-----------------------------------------|
| **CLAUDE.md**   | Persistent context every session          | Project conventions, "always do X" rules |
| **Skill**       | On-demand knowledge and workflows         | Reusable content, reference docs, tasks  |
| **Subagent**    | Isolated execution, returns summaries     | Context isolation, parallel tasks        |
| **Agent teams** | Multiple independent sessions coordinated | Parallel research, competing hypotheses  |
| **MCP**         | Connect to external services              | External data or actions                 |
| **Hook**        | Deterministic script on events            | Predictable automation, no LLM involved  |

## Full Documentation

For the complete official documentation, see the reference files:

- [Features Overview](references/claude-code-features-overview.md) -- extensibility comparison (CLAUDE.md, skills, MCP, subagents, hooks, plugins), context costs, and how features layer
- [Model Configuration](references/claude-code-model-config.md) -- model aliases, effort levels, extended context, opusplan, environment variables, prompt caching
- [Fast Mode](references/claude-code-fast-mode.md) -- toggling fast mode, cost tradeoffs, requirements, rate limit behavior
- [Output Styles](references/claude-code-output-styles.md) -- built-in styles, custom output style creation, frontmatter options
- [Status Line](references/claude-code-statusline.md) -- setup, available JSON data, script examples (progress bars, git status, cost tracking, clickable links, caching)
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic tracking, rewind menu, restore vs summarize, limitations

## Sources

- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
