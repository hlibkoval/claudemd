---
name: features
description: Reference documentation for Claude Code features — model configuration, fast mode, output styles, status line customization, and checkpointing. Use when switching models, configuring effort levels, enabling fast mode, creating custom output styles, setting up status lines, or understanding checkpoint/rewind behavior.
user-invocable: false
---

# Claude Code Features

This skill covers Claude Code's configurable features: model selection, fast mode, output styles, status line, and checkpointing.

## Model Configuration

### Model Aliases

| Alias        | Resolves to                                  | Use case                          |
|:-------------|:---------------------------------------------|:----------------------------------|
| `default`    | Opus 4.6 (Max/Teams/Pro), Sonnet 4.5 (API)  | Recommended default               |
| `sonnet`     | Latest Sonnet (currently 4.5)                | Daily coding tasks                 |
| `opus`       | Latest Opus (currently 4.6)                  | Complex reasoning                  |
| `haiku`      | Latest Haiku                                 | Simple, fast tasks                 |
| `sonnet[1m]` | Sonnet with 1M context window                | Long sessions                      |
| `opusplan`   | Opus for planning, Sonnet for execution      | Hybrid reasoning + implementation  |

### Setting the Model

Priority (highest first): `/model` in session > `claude --model` at startup > `ANTHROPIC_MODEL` env var > `model` in settings.

### Effort Level

Controls Opus 4.6 adaptive reasoning depth. Set via `/model` slider, `CLAUDE_CODE_EFFORT_LEVEL=low|medium|high`, or `effortLevel` in settings.

| Level    | Behavior                                       |
|:---------|:-----------------------------------------------|
| `low`    | Faster, cheaper, less thinking                 |
| `medium` | Balanced                                       |
| `high`   | Default. Deeper reasoning for complex problems |

### Restricting Models (Admin)

Set `availableModels` in managed/policy settings to restrict user model choices. The Default option always remains available regardless.

### Environment Variables

| Variable                         | Description                               |
|:---------------------------------|:------------------------------------------|
| `ANTHROPIC_MODEL`                | Model override                            |
| `ANTHROPIC_DEFAULT_OPUS_MODEL`   | Model name for `opus` / `opusplan` plan   |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model name for `sonnet` / `opusplan` exec |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL`  | Model name for `haiku` / background tasks |
| `CLAUDE_CODE_SUBAGENT_MODEL`     | Model for subagents                       |
| `DISABLE_PROMPT_CACHING`         | `1` to disable all prompt caching         |

## Fast Mode

Fast mode is a high-speed Opus 4.6 configuration: same model, same quality, 2.5x faster, higher cost per token. Toggle with `/fast` or set `"fastMode": true` in settings.

### Pricing

| Mode                           | Input (MTok) | Output (MTok) |
|:-------------------------------|:-------------|:--------------|
| Fast mode on Opus 4.6 (<200K)  | $30          | $150          |
| Fast mode on Opus 4.6 (>200K)  | $60          | $225          |

### Requirements

- Extra usage must be enabled (billed directly, not against plan usage)
- Not available on Bedrock, Vertex AI, or Azure Foundry
- Teams/Enterprise: admin must explicitly enable fast mode

### Fast Mode vs Effort Level

| Setting            | Effect                                            |
|:-------------------|:--------------------------------------------------|
| **Fast mode**      | Same quality, lower latency, higher cost          |
| **Lower effort**   | Less thinking, faster, potentially lower quality  |

Both can be combined for maximum speed on straightforward tasks.

### Rate Limits

When fast mode rate limit is hit, it falls back to standard Opus 4.6 automatically. The `↯` icon turns gray during cooldown, re-enables when cooldown expires.

## Output Styles

Output styles modify Claude Code's system prompt to adapt it for different use cases.

### Built-in Styles

| Style           | Behavior                                                          |
|:----------------|:------------------------------------------------------------------|
| **Default**     | Standard software engineering mode                                |
| **Explanatory** | Adds educational "Insights" about implementation choices          |
| **Learning**    | Collaborative mode with `TODO(human)` markers for you to implement |

Switch with `/output-style` (menu) or `/output-style <name>` (direct). Saved in `.claude/settings.local.json`.

### Custom Output Styles

Create a markdown file at `~/.claude/output-styles/` (user) or `.claude/output-styles/` (project):

```markdown
---
name: My Custom Style
description: Brief description for the UI
keep-coding-instructions: false
---
Your custom system prompt instructions here...
```

Output styles **replace** parts of the system prompt. CLAUDE.md and `--append-system-prompt` **add** to it.

## Status Line

A customizable bar at the bottom of Claude Code that runs any shell script. Receives JSON session data on stdin, displays whatever the script prints.

### Setup

Use `/statusline <description>` to auto-generate, or manually create a script and add to settings:

```json
{ "statusLine": { "type": "command", "command": "~/.claude/statusline.sh" } }
```

### Available Data Fields

| Field                                 | Description                          |
|:--------------------------------------|:-------------------------------------|
| `model.id`, `model.display_name`      | Current model                        |
| `workspace.current_dir`               | Working directory                    |
| `workspace.project_dir`               | Launch directory                     |
| `cost.total_cost_usd`                 | Session cost in USD                  |
| `cost.total_duration_ms`              | Wall-clock time since session start  |
| `context_window.used_percentage`      | Context usage percentage             |
| `context_window.context_window_size`  | Max context size (200K or 1M)        |
| `session_id`                          | Session identifier                   |
| `vim.mode`                            | Vim mode (if enabled)                |
| `output_style.name`                   | Active output style                  |

### Behavior

- Runs after each assistant message, debounced at 300ms
- Supports multiple lines, ANSI colors, and OSC 8 clickable links
- Does not consume API tokens
- Cache expensive operations (e.g., `git status`) to a temp file with a TTL

## Checkpointing

Automatically tracks file edits, letting you rewind to previous states.

### Usage

Press `Esc` twice or use `/rewind` to open the rewind menu. Actions:

| Action                            | Effect                                           |
|:----------------------------------|:-------------------------------------------------|
| **Restore code and conversation** | Revert both to the selected point                |
| **Restore conversation**          | Rewind messages, keep current code               |
| **Restore code**                  | Revert files, keep conversation                  |
| **Summarize from here**           | Compress messages from this point into a summary |

### Limitations

- Bash command file changes (rm, mv, cp) are **not** tracked
- External/manual file edits are not captured
- Not a replacement for Git — checkpoints are session-level "local undo"

## Full Documentation

- [Model Configuration](references/claude-code-model-config.md)
- [Fast Mode](references/claude-code-fast-mode.md)
- [Output Styles](references/claude-code-output-styles.md)
- [Status Line](references/claude-code-statusline.md)
- [Checkpointing](references/claude-code-checkpointing.md)
- [Features Overview (Extensibility)](references/claude-code-features-overview.md)

## Sources

- Model Configuration: https://code.claude.com/docs/en/model-config.md
- Fast Mode: https://code.claude.com/docs/en/fast-mode.md
- Output Styles: https://code.claude.com/docs/en/output-styles.md
- Status Line: https://code.claude.com/docs/en/statusline.md
- Checkpointing: https://code.claude.com/docs/en/checkpointing.md
- Features Overview: https://code.claude.com/docs/en/features.md
