---
name: features
description: Reference documentation for Claude Code features — fast mode, model configuration (aliases, effort levels, extended context, opusplan), output styles, status line customization, checkpointing and rewind, the features/extensibility overview, and remote control. Covers /fast, /model, /output-style, /statusline, /rewind, /remote-control commands and their configuration.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features and configuration options.

## Quick Reference

### Model Configuration

| Alias          | Behavior                                                                  |
|:---------------|:--------------------------------------------------------------------------|
| `default`      | Recommended model for your account type                                   |
| `sonnet`       | Latest Sonnet (currently Sonnet 4.6) for daily coding                     |
| `opus`         | Latest Opus (currently Opus 4.6) for complex reasoning                    |
| `haiku`        | Fast, efficient Haiku for simple tasks                                    |
| `sonnet[1m]`   | Sonnet with 1M token context window                                       |
| `opusplan`     | Opus for planning, Sonnet for execution (automatic switching)             |

**Setting the model** (in priority order):

1. `/model <alias|name>` during session
2. `claude --model <alias|name>` at startup
3. `ANTHROPIC_MODEL=<alias|name>` environment variable
4. `"model"` field in settings file

**Effort levels** (Opus 4.6 only): `low`, `medium`, `high` (default). Set via `/model` slider, `CLAUDE_CODE_EFFORT_LEVEL` env var, or `effortLevel` in settings.

**Enterprise model restriction**: use `availableModels` in managed settings to limit which models users can select.

### Model Environment Variables

| Variable                         | Controls                                          |
|:---------------------------------|:--------------------------------------------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL`   | Model for `opus` / `opusplan` plan mode           |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` / `opusplan` execution mode    |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL`  | Model for `haiku` / background functionality      |
| `CLAUDE_CODE_SUBAGENT_MODEL`     | Model for subagents                               |
| `DISABLE_PROMPT_CACHING`         | `1` = disable caching for all models              |

### Fast Mode

Toggle with `/fast`. Same Opus 4.6 model, 2.5x faster, higher cost per token. Persists across sessions.

| Mode                        | Input (MTok) | Output (MTok) |
|:----------------------------|:-------------|:--------------|
| Fast Opus 4.6 (<200K)      | $30          | $150          |
| Fast Opus 4.6 (>200K)      | $60          | $225          |

**Requirements**: extra usage enabled, not available on Bedrock/Vertex/Foundry. Admin must enable for Teams/Enterprise.

**Rate limits**: falls back to standard Opus automatically on limit; ` ↯` icon turns gray during cooldown.

### Output Styles

Change with `/output-style [style]` or via `/config`. Saved in `.claude/settings.local.json`.

| Style           | Behavior                                                              |
|:----------------|:----------------------------------------------------------------------|
| **Default**     | Standard system prompt for software engineering                       |
| **Explanatory** | Adds educational "Insights" while helping with tasks                  |
| **Learning**    | Collaborative mode; adds `TODO(human)` markers for you to implement   |
| **Custom**      | Markdown files in `~/.claude/output-styles/` or `.claude/output-styles/` |

Custom style frontmatter: `name`, `description`, `keep-coding-instructions` (default: false).

### Checkpointing

Automatically tracks file edits; rewind with `Esc Esc` or `/rewind`.

| Action                         | Effect                                                   |
|:-------------------------------|:---------------------------------------------------------|
| **Restore code and conversation** | Revert both code and conversation to that point        |
| **Restore conversation**       | Rewind messages, keep current code                       |
| **Restore code**               | Revert files, keep conversation                          |
| **Summarize from here**        | Compress conversation from that point forward            |

**Limitations**: bash command changes not tracked; external changes not tracked; not a replacement for Git.

### Status Line

Customizable bar at the bottom running any shell script. Configure via `/statusline` or manually in settings.

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

Script receives JSON on stdin with fields: `model.display_name`, `context_window.used_percentage`, `workspace.current_dir`, `session.id`, `costs`, and more.

### Remote Control

Continue local sessions from any device via `claude.ai/code` or the Claude mobile app.

| Command                | Effect                                                 |
|:-----------------------|:-------------------------------------------------------|
| `claude remote-control`| Start new remote session from terminal                 |
| `/remote-control` (or `/rc`) | Enable remote control on existing session        |

**Requirements**: Pro or Max plan, signed in via `/login`, workspace trust accepted.

Session runs locally; web/mobile is just a window into it. Supports `--verbose`, `--sandbox`, `--no-sandbox` flags.

### Extension Feature Comparison

| Feature         | What it does                                         | When to use it                            |
|:----------------|:-----------------------------------------------------|:------------------------------------------|
| **CLAUDE.md**   | Persistent context every session                     | Project conventions, "always do X" rules  |
| **Skill**       | Reusable knowledge and workflows                     | Reference docs, repeatable tasks          |
| **Subagent**    | Isolated execution context                           | Context isolation, parallel tasks         |
| **Agent teams** | Coordinate multiple independent sessions             | Parallel research, competing hypotheses   |
| **MCP**         | Connect to external services                         | External data or actions                  |
| **Hook**        | Deterministic script on events                       | Automation without LLM involvement        |
| **Plugin**      | Package skills, hooks, subagents, MCP together       | Reuse across repos, distribute to others  |

## Full Documentation

For the complete official documentation, see the reference files:

- [Features Overview](references/claude-code-features-overview.md) -- extensibility guide comparing CLAUDE.md, skills, subagents, agent teams, MCP, hooks, and plugins
- [Model Configuration](references/claude-code-model-config.md) -- model aliases, effort levels, extended context, environment variables, prompt caching
- [Fast Mode](references/claude-code-fast-mode.md) -- toggling fast mode, pricing, requirements, rate limit behavior
- [Output Styles](references/claude-code-output-styles.md) -- built-in and custom output styles, frontmatter fields
- [Checkpointing](references/claude-code-checkpointing.md) -- rewind, restore, summarize, limitations
- [Status Line](references/claude-code-statusline.md) -- setup, JSON data fields, ANSI styling, multi-line examples
- [Remote Control](references/claude-code-remote-control.md) -- setup, connection, security, comparison with Claude Code on the web

## Sources

- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
