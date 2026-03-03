---
name: features-doc
description: Reference documentation for Claude Code features — fast mode, model configuration and aliases, effort levels, extended context (1M tokens), output styles, status line customization, checkpointing and rewind, extensibility overview, and Remote Control for continuing local sessions from any device. Load when discussing model selection, fast mode, effort levels, output styles, status line, checkpoints, rewind, or remote control.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features including model configuration, fast mode, output styles, status line, checkpointing, extensibility overview, and Remote Control.

## Quick Reference

### Model Aliases

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended model for your account type (Max/Team Premium = Opus; Pro/Team Standard = Sonnet) |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast, efficient Haiku for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opusplan` | Opus for plan mode, Sonnet for execution |

Set model: `/model <alias>`, `claude --model <alias>`, `ANTHROPIC_MODEL=<alias>`, or `"model"` in settings.

### Model Environment Variables

| Variable | Description |
|:---------|:------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for `opus` alias / `opusplan` plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` alias / `opusplan` execution |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for `haiku` alias / background tasks |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |

### Effort Levels

Three levels: **low**, **medium**, **high** (default). Controls Opus 4.6 adaptive reasoning depth.

Set via: effort slider in `/model`, `CLAUDE_CODE_EFFORT_LEVEL=low|medium|high`, or `"effortLevel"` in settings. Disable adaptive reasoning with `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1`.

### Fast Mode

Toggle with `/fast`. Same Opus 4.6, 2.5x faster, higher cost. Persists across sessions by default.

| Mode | Input (MTok) | Output (MTok) |
|:-----|:-------------|:--------------|
| Fast (<200K context) | $30 | $150 |
| Fast (>200K context) | $60 | $225 |

Requirements: not available on Bedrock/Vertex/Foundry; extra usage must be enabled; Teams/Enterprise need admin enablement. Falls back to standard mode on rate limit (gray indicator). Admins can set `"fastModePerSessionOptIn": true` to reset each session.

### Extended Context (1M tokens)

Opus 4.6 and Sonnet 4.6 support 1M token context windows. Standard rates up to 200K, then long-context pricing. Enable with `/model sonnet[1m]` or append `[1m]` to model names. Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

### Output Styles

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering system prompt |
| **Explanatory** | Adds educational "Insights" alongside coding help |
| **Learning** | Collaborative learn-by-doing with `TODO(human)` markers |

Switch with `/output-style [style]`. Custom styles are `.md` files in `~/.claude/output-styles/` or `.claude/output-styles/` with frontmatter (`name`, `description`, `keep-coding-instructions`). Custom styles replace coding instructions unless `keep-coding-instructions: true`.

### Status Line

Customizable bar at bottom of Claude Code. Runs a shell script that receives JSON session data on stdin.

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

Use `/statusline <description>` to auto-generate a script. Available data includes model name, context usage, costs, session info, and git status.

### Checkpointing

Automatic tracking of file edits (not bash commands). Each prompt creates a checkpoint. Access with **Esc+Esc** or `/rewind`.

| Action | Effect |
|:-------|:-------|
| Restore code and conversation | Revert both to selected point |
| Restore conversation | Rewind messages, keep current code |
| Restore code | Revert files, keep conversation |
| Summarize from here | Compress messages from selected point forward |

Limitations: bash command changes and external edits not tracked. Not a replacement for version control.

### Remote Control

Continue local sessions from phone, tablet, or browser via `claude.ai/code` or Claude mobile app. Session runs locally; web/mobile is a window into it.

```bash
claude remote-control          # new session
/remote-control                # from existing session (alias: /rc)
```

Requires Max plan (Pro coming soon). One remote session at a time. Auto-reconnects after sleep/network drops. Flags: `--verbose`, `--sandbox`/`--no-sandbox`.

### Extensibility Overview

| Feature | What it does | When to use |
|:--------|:-------------|:------------|
| **CLAUDE.md** | Persistent context every session | "Always do X" rules, project conventions |
| **Skills** | On-demand knowledge and workflows | Reference docs, repeatable tasks |
| **Subagents** | Isolated execution, returns summary | Parallel tasks, context isolation |
| **Agent teams** | Coordinate multiple sessions | Complex parallel collaboration |
| **MCP** | Connect to external services | Database queries, Slack, browser control |
| **Hooks** | Deterministic scripts on events | Linting after edits, logging |
| **Plugins** | Bundle and distribute features | Multi-project reuse, marketplace sharing |

## Full Documentation

For the complete official documentation, see the reference files:

- [Fast mode](references/claude-code-fast-mode.md) -- toggle, pricing, cost tradeoff, requirements, per-session opt-in, rate limit behavior
- [Model configuration](references/claude-code-model-config.md) -- model aliases, setting models, effort levels, extended context, prompt caching, environment variables
- [Output styles](references/claude-code-output-styles.md) -- built-in and custom output styles, frontmatter fields, comparisons to CLAUDE.md/agents/skills
- [Status line](references/claude-code-statusline.md) -- setup, available data fields, JSON schema, examples for git status, cost tracking, progress bars
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic tracking, rewind menu, restore vs summarize, limitations
- [Extend Claude Code](references/claude-code-features-overview.md) -- extensibility overview comparing CLAUDE.md, skills, subagents, agent teams, MCP, hooks, plugins
- [Remote Control](references/claude-code-remote-control.md) -- setup, connection, security, comparison to Claude Code on the web, limitations

## Sources

- Fast mode: https://code.claude.com/docs/en/fast-mode.md
- Model configuration: https://code.claude.com/docs/en/model-config.md
- Output styles: https://code.claude.com/docs/en/output-styles.md
- Status line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Extend Claude Code: https://code.claude.com/docs/en/features-overview.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
