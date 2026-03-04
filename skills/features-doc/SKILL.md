---
name: features-doc
description: Documentation for Claude Code features — extension overview (CLAUDE.md, Skills, MCP, Subagents, Hooks, Plugins), model configuration (aliases, effort levels, 1M context), fast mode, output styles, status line, checkpointing, and remote control. Load when discussing model selection, fast mode, output styles, status bars, checkpointing/rewind, or remote sessions.
user-invocable: false
---

# Claude Code Features Documentation

This skill covers the Claude Code extension layer and key runtime features: how to choose and configure extensions, model settings, fast mode, output styles, status line, checkpointing, and remote control.

## Extension Overview

| Feature | Loads | Best For |
|:--------|:------|:---------|
| **CLAUDE.md** | Every session | Always-on rules, project conventions |
| **Skills** | On demand | Reusable knowledge, invocable workflows |
| **MCP** | Session start | External services (database, Slack, browser) |
| **Subagents** | On demand | Context isolation, parallel focused tasks |
| **Agent teams** | On demand | Parallel sessions with peer-to-peer messaging |
| **Hooks** | On trigger | Deterministic automation without LLM |
| **Plugins** | Session start | Bundled distribution of the above |

### Context Cost

| Feature | Context cost |
|:--------|:-------------|
| CLAUDE.md | Full content every request |
| Skills | Descriptions every request; full content when used |
| MCP servers | Tool definitions every request (tool search caps at 10%) |
| Subagents | Isolated — don't bloat main session |
| Hooks | Zero unless hook returns output |

Tip: use `disable-model-invocation: true` in skill frontmatter to hide a skill until manually invoked (zero cost until then).

## Model Configuration

### Model Aliases

| Alias | Behavior |
|:------|:---------|
| `default` | Recommended model for your account tier |
| `sonnet` | Latest Sonnet (currently Sonnet 4.6) |
| `opus` | Latest Opus (currently Opus 4.6) |
| `haiku` | Fast/cheap model for simple tasks |
| `sonnet[1m]` | Sonnet with 1M token context window |
| `opusplan` | Opus during plan mode, Sonnet for execution |

### Setting the Model

```bash
# At startup
claude --model opus

# Mid-session
/model sonnet

# Permanently (settings.json)
{ "model": "opus" }

# Environment variable
ANTHROPIC_MODEL=sonnet
```

### Effort Levels

Three levels: **low**, **medium**, **high**. Supported on Opus 4.6 and Sonnet 4.6.

- Adjust via arrow keys in `/model` picker
- `CLAUDE_CODE_EFFORT_LEVEL=low|medium|high`
- `effortLevel` in settings file

### Extended Context (1M tokens)

Available on Opus 4.6 and Sonnet 4.6. Standard pricing up to 200K tokens; long-context pricing beyond 200K.

```bash
/model sonnet[1m]
/model claude-sonnet-4-6[1m]
```

Disable with `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`.

## Fast Mode

Fast mode makes Opus 4.6 **2.5x faster** at higher per-token cost. Same quality, lower latency.

| Toggle | How |
|:-------|:----|
| Enable/disable | `/fast` or Tab key |
| Persist in settings | `"fastMode": true` |
| Per-session reset (admins) | `"fastModePerSessionOptIn": true` |
| Disable entirely | `CLAUDE_CODE_DISABLE_FAST_MODE=1` |

- Active indicator: `↯` icon next to prompt
- Rate limited separately from standard Opus; auto-falls back on limit
- Requires extra usage enabled; not available on Bedrock/Vertex/Foundry
- Disabling fast mode keeps you on Opus 4.6 — use `/model` to switch away

### Fast mode vs effort level

| Setting | Effect |
|:--------|:-------|
| Fast mode | Same quality, lower latency, higher cost |
| Lower effort | Less thinking time, potentially lower quality |

Combine both for maximum speed on simple tasks.

## Output Styles

Output styles modify Claude's system prompt to change its response behavior.

### Built-in Styles

| Style | Behavior |
|:------|:---------|
| **Default** | Standard software engineering assistant |
| **Explanatory** | Adds educational "Insights" between responses |
| **Learning** | Collaborative; asks you to implement `TODO(human)` markers |

### Usage

```
/output-style                  # Open menu
/output-style explanatory      # Switch directly
```

Settings saved to `.claude/settings.local.json` (`outputStyle` field).

### Custom Output Styles

Place Markdown files with frontmatter in `~/.claude/output-styles` (user) or `.claude/output-styles` (project):

```markdown
---
name: My Custom Style
description: What this style does
keep-coding-instructions: false
---

[Your custom system prompt instructions here]
```

`keep-coding-instructions: true` preserves Claude's default coding instructions in the system prompt.

## Status Line

A shell script that receives JSON session data on stdin and prints a status bar at the bottom of Claude Code.

### Setup

```
/statusline show model name and context percentage
```

Or manually in settings:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

Key JSON fields: `model.display_name`, `context_window.used_percentage`, `workspace.current_dir`, `session.cost_usd`, `git.branch`.

## Checkpointing

Claude Code automatically saves a checkpoint before each file edit, enabling rewind without Git.

Open rewind menu with `Esc`+`Esc` or `/rewind`:

| Action | Effect |
|:-------|:-------|
| Restore code and conversation | Reverts both |
| Restore conversation | Rewinds messages, keeps current code |
| Restore code | Reverts files, keeps conversation |
| Summarize from here | Compresses conversation, preserves files |

Checkpoints persist across sessions (cleaned up after 30 days). Bash command file changes are NOT tracked.

## Remote Control

Continue a local Claude Code session from a browser or mobile device.

```bash
claude remote-control   # Start new remote session
/remote-control         # From existing session (/rc)
```

- Connects [claude.ai/code](https://claude.ai/code) or Claude mobile app to your local session
- Local environment (filesystem, MCP, tools) stays available remotely
- Press spacebar to display QR code for phone access
- Requires Max or Pro plan; outbound HTTPS only, no inbound ports

## Reference Files

- [claude-code-features-overview.md](references/claude-code-features-overview.md) — extension comparison, context costs
- [claude-code-model-config.md](references/claude-code-model-config.md) — aliases, effort levels, 1M context, env vars
- [claude-code-fast-mode.md](references/claude-code-fast-mode.md) — toggle, pricing, rate limits, org settings
- [claude-code-output-styles.md](references/claude-code-output-styles.md) — built-in styles, custom styles
- [claude-code-statusline.md](references/claude-code-statusline.md) — setup, JSON schema, examples
- [claude-code-checkpointing.md](references/claude-code-checkpointing.md) — rewind menu, restore options
- [claude-code-remote-control.md](references/claude-code-remote-control.md) — setup, security, limitations
