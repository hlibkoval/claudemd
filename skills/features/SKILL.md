---
name: features
description: Reference documentation for Claude Code features — model configuration (aliases, effort levels, extended context, opusplan), fast mode (toggling, pricing, rate limits), output styles (built-in and custom), checkpointing (rewind, restore, summarize), status line (customization, JSON data fields, scripting examples), and the features overview (extension comparison, context costs, layering).
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features including model configuration, fast mode, output styles, checkpointing, and status line customization.

## Quick Reference

### Model Aliases

| Alias        | Behavior                                                                  |
|:-------------|:--------------------------------------------------------------------------|
| `default`    | Recommended model for your account type                                   |
| `sonnet`     | Latest Sonnet (currently Sonnet 4.6)                                      |
| `opus`       | Latest Opus (currently Opus 4.6)                                          |
| `haiku`      | Fast, efficient Haiku for simple tasks                                    |
| `sonnet[1m]` | Sonnet with 1M token context window                                       |
| `opusplan`   | Opus for planning, Sonnet for execution                                   |

Set model via: `/model <alias>`, `claude --model <alias>`, `ANTHROPIC_MODEL=<alias>`, or `model` in settings.

### Model Environment Variables

| Variable                         | Controls                                  |
|:---------------------------------|:------------------------------------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL`   | Model for `opus` / `opusplan` plan mode   |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` / `opusplan` execution |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL`  | Model for `haiku` / background tasks      |
| `CLAUDE_CODE_SUBAGENT_MODEL`     | Model for subagents                       |

### Effort Levels

Three levels: **low**, **medium**, **high** (default). Set via `/model` slider, `CLAUDE_CODE_EFFORT_LEVEL`, or `effortLevel` in settings. Supported on Opus 4.6.

### Extended Context (1M Tokens)

Append `[1m]` to any alias or model name: `/model sonnet[1m]`. Standard rates apply until 200K tokens; beyond that, long-context pricing kicks in. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

### Fast Mode

Toggle with `/fast`. Same Opus 4.6 model, 2.5x faster, higher cost. Requires extra usage enabled.

| Mode                            | Input (MTok) | Output (MTok) |
|:--------------------------------|:-------------|:--------------|
| Fast mode Opus 4.6 (<200K)      | $30          | $150          |
| Fast mode Opus 4.6 (>200K)      | $60          | $225          |

Rate limit fallback: automatically drops to standard Opus 4.6 on cooldown.

### Output Styles

| Style         | Behavior                                                       |
|:--------------|:---------------------------------------------------------------|
| Default       | Standard software engineering system prompt                    |
| Explanatory   | Adds educational "Insights" while coding                       |
| Learning      | Collaborative mode with `TODO(human)` markers for you to code |
| Custom        | Your own `.md` file in `~/.claude/output-styles` or `.claude/output-styles` |

Switch with `/output-style [style]`. Custom styles modify the system prompt and support frontmatter: `name`, `description`, `keep-coding-instructions` (default false).

### Checkpointing

Every user prompt creates a checkpoint. Access via `Esc` + `Esc` or `/rewind`.

| Action                       | Effect                                              |
|:-----------------------------|:----------------------------------------------------|
| Restore code and conversation| Revert both to that point                           |
| Restore conversation         | Rewind messages, keep current code                  |
| Restore code                 | Revert files, keep conversation                     |
| Summarize from here          | Compress messages from that point into a summary    |

Limitations: bash command changes and external edits are not tracked.

### Status Line

Customizable bar at the bottom. Configure in settings with `statusLine`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

Use `/statusline <description>` to auto-generate a script. Script receives JSON on stdin with fields: `model.display_name`, `context_window.used_percentage`, `cost.total_cost_usd`, `cost.total_duration_ms`, `workspace.current_dir`, `session_id`, `version`, `vim.mode`, and more.

### Extension Feature Comparison

| Feature      | Loads when           | Context cost                          |
|:-------------|:---------------------|:--------------------------------------|
| CLAUDE.md    | Session start        | Every request (full content)          |
| Skills       | Start + on use       | Low (descriptions only until invoked) |
| MCP servers  | Session start        | Every request (tool definitions)      |
| Subagents    | On demand            | Isolated from main session            |
| Hooks        | On trigger           | Zero (runs externally)                |

### Prompt Caching

| Variable                        | Description                              |
|:--------------------------------|:-----------------------------------------|
| `DISABLE_PROMPT_CACHING`        | Disable for all models                   |
| `DISABLE_PROMPT_CACHING_HAIKU`  | Disable for Haiku only                   |
| `DISABLE_PROMPT_CACHING_SONNET` | Disable for Sonnet only                  |
| `DISABLE_PROMPT_CACHING_OPUS`   | Disable for Opus only                    |

### Admin Controls

- `availableModels`: restrict which models users can select (array, merged across levels)
- `model`: set explicit model override in managed/policy settings

## Full Documentation

For the complete official documentation, see the reference files:

- [Features Overview](references/claude-code-features-overview.md) -- extension comparison (CLAUDE.md, Skills, MCP, Subagents, Hooks, Plugins), context costs, feature layering, and combining features
- [Model Configuration](references/claude-code-model-config.md) -- model aliases, setting models, effort levels, extended context, opusplan, environment variables, prompt caching, third-party provider pinning
- [Fast Mode](references/claude-code-fast-mode.md) -- toggling fast mode, pricing, cost tradeoffs, requirements, rate limits, research preview status
- [Output Styles](references/claude-code-output-styles.md) -- built-in styles (Default, Explanatory, Learning), creating custom styles, frontmatter options, comparison with CLAUDE.md and agents
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic tracking, rewind/restore/summarize actions, limitations, use cases
- [Status Line](references/claude-code-statusline.md) -- setup, available JSON data fields, scripting examples (Bash/Python/Node.js), caching, troubleshooting

## Sources

- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Status Line: https://code.claude.com/docs/en/statusline.md
