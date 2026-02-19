---
name: features
description: Reference documentation for Claude Code features including the extension overview (CLAUDE.md, Skills, MCP, Subagents, Agent Teams, Hooks, Plugins), model configuration and aliases, fast mode, output styles, checkpointing, and the status line. Use when asking about model selection, opusplan, effort levels, rewinding sessions, output style customization, or the status bar.
user-invocable: false
---

# Features Documentation

This skill provides the complete official documentation for Claude Code's core features and configuration options.

## Quick Reference

### Extension Overview

| Feature        | What it does                                          | Context cost              | Best for                                      |
|:---------------|:------------------------------------------------------|:--------------------------|:----------------------------------------------|
| **CLAUDE.md**  | Persistent context loaded every session               | Full content, every req   | "Always do X" rules, project conventions      |
| **Skills**     | Reusable knowledge and invocable workflows            | Low (descriptions at start) | Reference docs, repeatable tasks (`/deploy`) |
| **Subagents**  | Isolated workers returning summarized results         | Isolated from main        | Context isolation, parallel focused tasks     |
| **Agent teams**| Multiple independent sessions coordinating            | Each is a full instance   | Complex parallel work, competing hypotheses   |
| **MCP**        | Connect Claude to external services                   | Tool defs, every req      | Database queries, Slack, browser control      |
| **Hooks**      | Deterministic scripts on lifecycle events             | Zero                      | ESLint on edit, logging, side effects         |
| **Plugins**    | Bundle and distribute the above                       | —                         | Reuse setup across repos, share with others   |

### Feature Layering Priority

- **CLAUDE.md**: additive — all levels contribute simultaneously
- **Skills**: override by name — managed > user > project
- **Subagents**: managed > CLI flag > project > user > plugin
- **MCP**: local > project > user
- **Hooks**: merge — all registered hooks fire

### Model Aliases

| Alias         | Behavior                                                        |
|:--------------|:----------------------------------------------------------------|
| `default`     | Recommended model for your account type                         |
| `sonnet`      | Latest Sonnet (currently 4.6) for daily coding tasks            |
| `opus`        | Latest Opus (currently 4.6) for complex reasoning               |
| `haiku`       | Fast and efficient for simple tasks                             |
| `sonnet[1m]`  | Sonnet with 1M token context window                             |
| `opusplan`    | Opus during plan mode, switches to Sonnet for execution         |

### Setting the Model

```bash
# At startup
claude --model opus

# During session
/model sonnet
```

Or via settings: `{ "model": "opus" }`, or env var `ANTHROPIC_MODEL=<alias|name>`.

### Default Model by Account Type

| User type                        | Default model  |
|:---------------------------------|:---------------|
| Max, Team Premium, or Pro        | Opus 4.6       |
| Pay-as-you-go (API)              | Sonnet 4.5     |

### Effort Levels (Opus 4.6 only)

Controls adaptive reasoning depth: `low`, `medium`, `high` (default).

- In `/model`: use left/right arrow keys on the effort slider
- Env var: `CLAUDE_CODE_EFFORT_LEVEL=low|medium|high`
- Settings: `effortLevel` field

### Fast Mode

2.5x faster Opus 4.6 at higher cost. Not a different model — same quality, lower latency.

| Mode                        | Input (MTok) | Output (MTok) |
|:----------------------------|:-------------|:--------------|
| Fast mode Opus 4.6 (<200K)  | $30          | $150          |
| Fast mode Opus 4.6 (>200K)  | $60          | $225          |

Toggle: `/fast` or `"fastMode": true` in settings. Persists across sessions. Requires extra usage enabled. Not available on Bedrock, Vertex, or Azure.

Combine fast mode + low effort for maximum speed on straightforward tasks.

### Checkpointing

Every user prompt creates a checkpoint automatically. Checkpoints persist for 30 days.

Open rewind menu: press `Esc` twice or run `/rewind`. Options:

| Action                     | Effect                                                  |
|:---------------------------|:--------------------------------------------------------|
| Restore code and conversation | Revert both to the selected point                    |
| Restore conversation       | Rewind messages, keep current code                      |
| Restore code               | Revert file changes, keep conversation                  |
| Summarize from here        | Compress messages from this point forward (frees context)|

Note: checkpointing only tracks files edited via Claude's file tools. Bash command side-effects (rm, mv, cp) are not tracked.

### Output Styles

Modify Claude's system prompt to change its behavior and tone.

| Style           | Behavior                                                    |
|:----------------|:------------------------------------------------------------|
| `default`       | Standard software engineering mode                          |
| `explanatory`   | Adds "Insights" explaining implementation choices           |
| `learning`      | Interactive mode with `TODO(human)` markers for you to fill |

Switch: `/output-style [style]` or edit `outputStyle` in settings.

Custom styles are Markdown files in `~/.claude/output-styles` or `.claude/output-styles` with frontmatter:

```markdown
---
name: My Style
description: What it does
keep-coding-instructions: false
---
Your custom instructions here.
```

### Status Line

A customizable bar at the bottom of Claude Code powered by a shell script.

Configure in settings:
```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

Generate a script automatically: `/statusline show model name and context percentage with a progress bar`

The script receives JSON session data on stdin (context usage, cost, model, git info, etc.).

## Full Documentation

For the complete official documentation, see the reference files:

- [Features Overview](references/claude-code-features-overview.md) — when to use CLAUDE.md vs Skills vs MCP vs Subagents vs Agent Teams vs Hooks, context costs, layering
- [Model Configuration](references/claude-code-model-config.md) — model aliases, opusplan, effort levels, availableModels, extended context
- [Fast Mode](references/claude-code-fast-mode.md) — toggling fast mode, cost tradeoff, rate limit behavior, org admin setup
- [Output Styles](references/claude-code-output-styles.md) — built-in styles, custom styles, frontmatter, comparison with CLAUDE.md and agents
- [Checkpointing](references/claude-code-checkpointing.md) — automatic tracking, rewind menu, summarize, limitations
- [Status Line](references/claude-code-statusline.md) — setup, available data fields, examples

## Sources

- Features Overview: https://code.claude.com/docs/en/features-overview.md
- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Status Line: https://code.claude.com/docs/en/statusline.md
