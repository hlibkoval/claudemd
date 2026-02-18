---
name: features
description: Reference documentation for Claude Code built-in features — model configuration, fast mode, output styles, status line customization, and checkpointing. Use when switching models, configuring effort levels, enabling fast mode, creating custom output styles, setting up status lines, or understanding checkpoint/rewind behavior.
user-invocable: false
---

# Claude Code Features Documentation

This skill provides the complete official documentation for Claude Code built-in features.

## Quick Reference

### Model Configuration

Priority order (highest first): `/model` in session > `claude --model` at startup > `ANTHROPIC_MODEL` env var > `model` in settings.

| Alias        | Resolves to                                   | Use case                          |
|:-------------|:----------------------------------------------|:----------------------------------|
| `default`    | Opus 4.6 (Max/Teams/Pro), Sonnet 4.5 (API)   | Recommended default               |
| `sonnet`     | Latest Sonnet (currently Sonnet 4.6)          | Daily coding tasks                |
| `opus`       | Latest Opus (currently Opus 4.6)              | Complex reasoning                 |
| `haiku`      | Latest Haiku                                  | Simple, fast tasks                |
| `sonnet[1m]` | Sonnet with 1M context window                 | Long sessions                     |
| `opusplan`   | Opus for planning, Sonnet for execution       | Hybrid reasoning + implementation |

**Effort level** (Opus 4.6 only): `low`, `medium`, `high` (default). Set via `/model` slider, `CLAUDE_CODE_EFFORT_LEVEL`, or `effortLevel` in settings.

| Variable                         | Description                               |
|:---------------------------------|:------------------------------------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL`   | Model name for `opus` / `opusplan` plan   |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model name for `sonnet` / `opusplan` exec |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL`  | Model name for `haiku` / background tasks |
| `CLAUDE_CODE_SUBAGENT_MODEL`     | Model for subagents                       |
| `DISABLE_PROMPT_CACHING`         | Set to `1` to disable all prompt caching  |

### Fast Mode

Toggle with `/fast` or set `"fastMode": true` in settings. Same Opus 4.6 quality, 2.5x faster, higher cost. Enable at session start — switching mid-conversation reprices the entire context at fast mode rates.

| Mode                           | Input (MTok) | Output (MTok) |
|:-------------------------------|:-------------|:--------------|
| Fast mode Opus 4.6 (<200K)     | $30          | $150          |
| Fast mode Opus 4.6 (>200K)     | $60          | $225          |

Requirements: extra usage enabled; not available on Bedrock, Vertex AI, or Azure Foundry; Teams/Enterprise admin must enable it. Falls back to standard Opus automatically on rate limit.

### Output Styles

Switch with `/output-style [name]` or edit `outputStyle` in settings (saved to `.claude/settings.local.json`).

| Style           | Behavior                                                          |
|:----------------|:------------------------------------------------------------------|
| `default`       | Standard software engineering mode                                |
| `explanatory`   | Adds educational "Insights" about implementation choices          |
| `learning`      | Collaborative mode; Claude adds `TODO(human)` markers for you     |
| Custom          | Markdown file in `~/.claude/output-styles/` or `.claude/output-styles/` |

Custom style frontmatter: `name`, `description`, `keep-coding-instructions` (default: `false`). Output styles **replace** parts of the system prompt; CLAUDE.md and `--append-system-prompt` **add** to it.

### Status Line

Configure in settings, or use `/statusline <description>` to auto-generate a script:

```json
{ "statusLine": { "type": "command", "command": "~/.claude/statusline.sh", "padding": 2 } }
```

Key JSON fields sent to the script via stdin:

| Field                               | Description                         |
|:------------------------------------|:------------------------------------|
| `model.display_name`                | Current model name                  |
| `workspace.current_dir`             | Current working directory           |
| `workspace.project_dir`             | Launch directory                    |
| `cost.total_cost_usd`               | Session cost in USD                 |
| `cost.total_duration_ms`            | Total elapsed session time (ms)     |
| `context_window.used_percentage`    | Context usage percentage            |
| `context_window.context_window_size`| Max context size (200K or 1M)       |
| `session_id`                        | Session identifier                  |
| `vim.mode`                          | Vim mode (`NORMAL`/`INSERT`)        |
| `output_style.name`                 | Active output style                 |

Runs after each assistant message, debounced at 300ms. Supports multiple lines, ANSI colors, and OSC 8 clickable links. Does not consume API tokens.

### Checkpointing

Every user prompt creates a checkpoint automatically. Persists across sessions; cleaned up after 30 days.

Open with `Esc Esc` or `/rewind`:

| Action                             | Effect                                                              |
|:-----------------------------------|:--------------------------------------------------------------------|
| **Restore code and conversation**  | Revert both files and chat history                                  |
| **Restore conversation**           | Rewind messages, keep current code                                  |
| **Restore code**                   | Revert files, keep conversation                                     |
| **Summarize from here**            | Compress messages from this point into a summary; no files changed  |

Limitations: bash command side-effects (rm, mv, cp) are not tracked. External/manual file edits are not captured. Not a replacement for Git.

## Full Documentation

For the complete official documentation, see the reference files:

- [Fast Mode](references/claude-code-fast-mode.md) — toggling fast mode, cost tradeoffs, rate limit fallback, and admin requirements
- [Model Configuration](references/claude-code-model-config.md) — model aliases, effort levels, extended context, env vars, prompt caching, and admin restrictions
- [Output Styles](references/claude-code-output-styles.md) — built-in styles, custom style authoring, and comparison with CLAUDE.md and agents
- [Status Line](references/claude-code-statusline.md) — setup, full JSON schema, examples (progress bars, git status, cost tracking, clickable links), and troubleshooting
- [Checkpointing](references/claude-code-checkpointing.md) — rewind menu actions, summarize vs restore, limitations, and common use cases
- [Features Overview](references/claude-code-features-overview.md) — how all Claude Code extension features compare: CLAUDE.md, skills, subagents, MCP, hooks, plugins, and context cost table

## Sources

- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Features Overview: https://code.claude.com/docs/en/features-overview.md
