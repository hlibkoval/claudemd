---
name: features-doc
description: Reference documentation for Claude Code features — fast mode, model configuration and aliases (opusplan, sonnet, opus, haiku), effort levels, extended 1M context, output styles, status line customization, checkpointing and rewind, remote control sessions, and the features overview comparing CLAUDE.md, skills, subagents, hooks, MCP, and plugins. Load when discussing model selection, fast mode toggling, effort levels, output style creation, status line scripts, checkpoint rewinding, remote control, or choosing between extension features.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features including model configuration, fast mode, output styles, status line, checkpointing, remote control, and the features overview.

## Quick Reference

### Model Aliases

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended model for your account type (Max/Team Premium: Opus 4.6; Pro/Team Standard: Sonnet 4.6) |
| `sonnet` | Latest Sonnet model (currently Sonnet 4.6) |
| `opus` | Latest Opus model (currently Opus 4.6) |
| `haiku` | Fast, efficient Haiku model for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opusplan` | Opus during plan mode, auto-switches to Sonnet for execution |

Set model: `/model <alias>`, `claude --model <alias>`, `ANTHROPIC_MODEL=<alias>`, or `"model"` in settings.

### Effort Levels

Three levels: **low**, **medium**, **high** (default). Controls Opus 4.6 adaptive reasoning.

Set via: `/model` slider, `CLAUDE_CODE_EFFORT_LEVEL=low|medium|high`, or `"effortLevel"` in settings. Disable adaptive reasoning: `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1`.

### Model Environment Variables

| Variable | Controls |
|:---------|:---------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model for `opus` / `opusplan` in plan mode |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model for `sonnet` / `opusplan` in execution |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model for `haiku` / background functionality |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |

### Fast Mode

Toggle with `/fast`. Same Opus 4.6 model, 2.5x faster, higher cost. Persists across sessions by default.

| Mode | Input (MTok) | Output (MTok) |
|:-----|:-------------|:--------------|
| Fast (<200K) | $30 | $150 |
| Fast (>200K) | $60 | $225 |

Requirements: extra usage enabled, not available on Bedrock/Vertex/Foundry. Admin enablement required for Teams/Enterprise. Disable: `CLAUDE_CODE_DISABLE_FAST_MODE=1`. Per-session opt-in: `"fastModePerSessionOptIn": true` in managed settings. Rate limit fallback: auto-falls back to standard Opus with gray indicator.

### Output Styles

Built-in styles: **Default** (software engineering), **Explanatory** (adds educational insights), **Learning** (collaborative, adds `TODO(human)` markers).

Switch: `/output-style [style]` or via `/config`. Saved in `.claude/settings.local.json`.

Custom output styles: Markdown files in `~/.claude/output-styles/` or `.claude/output-styles/` with frontmatter:

| Field | Purpose | Default |
|:------|:--------|:--------|
| `name` | Display name | File name |
| `description` | UI description | None |
| `keep-coding-instructions` | Keep coding system prompt parts | `false` |

### Status Line

Customizable bar at bottom of Claude Code. Runs a shell script receiving JSON session data on stdin.

Configure in settings:
```json
{ "statusLine": { "type": "command", "command": "~/.claude/statusline.sh", "padding": 2 } }
```

Quick setup: `/statusline show model name and context percentage`.

Key JSON fields available: `model.display_name`, `context_window.used_percentage`, `cost.total_cost_usd`, `cost.total_duration_ms`, `workspace.current_dir`, `session_id`, `vim.mode`, `output_style.name`.

### Checkpointing

Automatic tracking of Claude's file edits. Rewind with `Esc Esc` or `/rewind`.

Rewind actions: **Restore code and conversation**, **Restore conversation** (keep code), **Restore code** (keep conversation), **Summarize from here** (compress context), **Never mind**.

Limitations: bash command changes not tracked, external changes not tracked, not a replacement for Git.

### Remote Control

Continue local sessions from any device via claude.ai/code or Claude mobile app. Session runs locally; web/mobile is just a window.

Start: `claude remote-control` (new session) or `/remote-control` (existing session). Connect via session URL, QR code, or session list.

Requirements: Max plan (Pro coming soon), `/login` auth, workspace trust accepted. Enable for all sessions via `/config`.

### Extension Features Comparison

| Feature | What it does | When to use |
|:--------|:-------------|:------------|
| **CLAUDE.md** | Persistent context every session | "Always do X" rules, conventions |
| **Skill** | On-demand knowledge and workflows | Reference docs, repeatable tasks |
| **Subagent** | Isolated execution, returns summary | Context isolation, parallel tasks |
| **Agent teams** | Multiple independent sessions | Parallel research, competing hypotheses |
| **MCP** | External service connections | Database queries, Slack, browser |
| **Hook** | Deterministic script on events | Linting after edits, no LLM needed |

Context loading: CLAUDE.md and MCP load at session start (every request). Skill descriptions load at start, full content on invoke. Subagents get isolated context. Hooks run externally (zero context cost).

## Full Documentation

For the complete official documentation, see the reference files:

- [Features Overview](references/claude-code-features-overview.md) -- when to use CLAUDE.md, skills, subagents, hooks, MCP, and plugins; feature comparison tables; context costs; how features layer and combine
- [Fast Mode](references/claude-code-fast-mode.md) -- toggling fast mode, cost tradeoffs, requirements, per-session opt-in, rate limit behavior, fast mode vs effort level
- [Model Configuration](references/claude-code-model-config.md) -- model aliases, setting models, restrict model selection, opusplan, effort levels, extended 1M context, environment variables, prompt caching
- [Output Styles](references/claude-code-output-styles.md) -- built-in styles, custom output style creation, frontmatter fields, comparison to CLAUDE.md, agents, and skills
- [Status Line](references/claude-code-statusline.md) -- setup via command or manual config, JSON data schema, ANSI colors, multi-line output, clickable links, example scripts
- [Checkpointing](references/claude-code-checkpointing.md) -- automatic edit tracking, rewind and summarize, restore options, limitations with bash commands
- [Remote Control](references/claude-code-remote-control.md) -- starting remote sessions, connecting from other devices, connection security, comparison to Claude Code on the web

## Sources

- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
