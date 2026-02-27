---
name: features
description: Reference documentation for Claude Code features -- fast mode, model configuration and aliases, output styles, status line customization, checkpointing and rewind, remote control, and the features overview comparing CLAUDE.md, skills, subagents, MCP, hooks, and plugins. Use when configuring models, toggling fast mode, setting effort level, customizing the status bar, rewinding conversation state, or enabling remote access from another device.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code features and configuration options.

## Quick Reference

### Fast Mode

Fast mode makes Claude Opus 4.6 run 2.5x faster at a higher per-token cost. Toggle with `/fast` or set `"fastMode": true` in settings.

| Mode                            | Input (MTok) | Output (MTok) |
|:--------------------------------|:-------------|:--------------|
| Fast mode Opus 4.6 (<200K ctx) | $30          | $150          |
| Fast mode Opus 4.6 (>200K ctx) | $60          | $225          |

- Fast mode is NOT a different model — same Opus 4.6, different API config
- Enable at session start for best cost efficiency (mid-session switch re-prices the full context)
- Falls back to standard Opus 4.6 automatically on rate limit; `↯` icon turns gray
- Not available on Bedrock, Vertex AI, or Foundry; requires extra usage enabled
- Disable org-wide: `CLAUDE_CODE_DISABLE_FAST_MODE=1`

### Model Configuration

Set the model via `/model`, `--model` flag, `ANTHROPIC_MODEL` env var, or `"model"` in settings (priority in that order).

| Alias        | Behavior                                                              |
|:-------------|:----------------------------------------------------------------------|
| `default`    | Recommended model for your account tier                               |
| `sonnet`     | Latest Sonnet (currently Sonnet 4.6) — daily coding tasks             |
| `opus`       | Latest Opus (currently Opus 4.6) — complex reasoning                  |
| `haiku`      | Fast, efficient Haiku — simple tasks and background use               |
| `sonnet[1m]` | Sonnet with 1M token context window                                   |
| `opusplan`   | Opus during plan mode, Sonnet during execution                        |

**Default model by plan:** Max/Team Premium → Opus 4.6; Pro/Team Standard → Sonnet 4.6.

**Effort level** (Opus 4.6 only): low / medium / high (default). Controls adaptive reasoning depth.
- In `/model`: use arrow keys on the effort slider
- Env var: `CLAUDE_CODE_EFFORT_LEVEL=low|medium|high`
- Settings: `"effortLevel": "low"`

**Extended context (1M tokens, beta):** use `[1m]` suffix with any alias or full model name.
- Standard rates up to 200K tokens, long-context pricing above that
- Disable: `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`

**Model env vars for alias pinning:**

| Variable                         | Alias it pins        |
|:---------------------------------|:---------------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL`   | `opus`, `opusplan` (plan mode) |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `sonnet`, `opusplan` (exec)    |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL`  | `haiku`, background tasks      |
| `CLAUDE_CODE_SUBAGENT_MODEL`     | subagents                      |

### Output Styles

Output styles modify Claude's system prompt to change tone and behavior.

| Style           | Description                                                           |
|:----------------|:----------------------------------------------------------------------|
| `default`       | Standard software engineering assistant                               |
| `explanatory`   | Adds "Insights" between tasks — explains implementation choices       |
| `learning`      | Collaborative mode: shares Insights + adds `TODO(human)` markers      |
| Custom `.md`    | Your own style file at `~/.claude/output-styles/` or `.claude/output-styles/` |

Switch style: `/output-style [style]` or via `/config`. Persists in `.claude/settings.local.json`.

Custom style frontmatter:

| Field                    | Purpose                                              | Default              |
|:-------------------------|:-----------------------------------------------------|:---------------------|
| `name`                   | Display name                                         | Inherits file name   |
| `description`            | Shown in `/output-style` UI                          | None                 |
| `keep-coding-instructions` | Retain coding-specific system prompt instructions  | false                |

### Status Line

The status line is a shell script that receives JSON session data on stdin and prints a display string.

**Configure in settings:**
```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

Or use `/statusline show model name and context percentage with a progress bar` to auto-generate.

**Key JSON fields available to your script:**

| Field                             | Description                          |
|:----------------------------------|:-------------------------------------|
| `.model.display_name`             | Current model name                   |
| `.context_window.used_percentage` | Percent of context window used       |
| `.session_cost_usd`               | Cumulative session cost              |
| `.working_directory`              | Current working directory            |

### Checkpointing

Claude Code automatically checkpoints before each file edit. Access via `Esc Esc` or `/rewind`.

| Rewind action              | Effect                                                       |
|:---------------------------|:-------------------------------------------------------------|
| Restore code + conversation | Reverts both file changes and conversation history          |
| Restore conversation        | Rewinds conversation, keeps current code                    |
| Restore code                | Reverts file changes, keeps conversation                    |
| Summarize from here         | Compresses conversation from selected point; files unchanged |

- Checkpoints persist across sessions (cleaned up after 30 days)
- Does NOT track files modified by bash commands (`rm`, `mv`, `cp`, etc.)
- Not a replacement for Git — complements it as a "local undo"

### Remote Control

Continue a local Claude Code session from any browser or the Claude mobile app.

```bash
# Start a new Remote Control session
claude remote-control

# From an existing session
/remote-control   # or /rc
```

- Session runs locally; only the interface is remote
- Displays a URL and QR code to connect from another device
- Enable for all sessions via `/config` → "Enable Remote Control for all sessions"
- Requires Max plan; outbound HTTPS only, no inbound ports opened
- One remote connection per Claude Code instance

### Features Overview — When to Use What

| Feature      | Loads                     | Use when                                           |
|:-------------|:--------------------------|:---------------------------------------------------|
| CLAUDE.md    | Every session (always-on) | Project conventions, "always do X" rules           |
| Skills       | On demand                 | Reference docs, reusable workflows (`/deploy`)     |
| Subagents    | When spawned              | Context isolation, parallel tasks, large searches  |
| Agent teams  | Independent sessions      | Parallel work requiring peer-to-peer coordination  |
| MCP          | Session start             | External services, databases, browser control      |
| Hooks        | On trigger (external)     | Deterministic automation, linting, logging         |
| Plugins      | When enabled              | Bundling + distributing skills/hooks/MCP together  |

## Full Documentation

For the complete official documentation, see the reference files:

- [Features Overview](references/claude-code-features-overview.md) — when to use CLAUDE.md, skills, subagents, agent teams, MCP, hooks, and plugins; how features layer and combine; context cost by feature
- [Fast Mode](references/claude-code-fast-mode.md) — toggling fast mode, pricing, requirements, rate limit fallback behavior
- [Model Configuration](references/claude-code-model-config.md) — model aliases, setting models, effort levels, extended context, prompt caching, enterprise model restrictions
- [Output Styles](references/claude-code-output-styles.md) — built-in styles, creating custom styles, how they differ from CLAUDE.md and agents
- [Status Line](references/claude-code-statusline.md) — setup, available JSON data fields, multi-line display, ready-to-use examples
- [Checkpointing](references/claude-code-checkpointing.md) — automatic tracking, rewind and summarize actions, limitations
- [Remote Control](references/claude-code-remote-control.md) — starting sessions, connecting from devices, security model, comparison with Claude Code on the web

## Sources

- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Remote Control: https://code.claude.com/docs/en/remote-control.md
