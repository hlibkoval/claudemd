---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — built-in subagents, creating and configuring custom subagents, frontmatter fields, tool control, permission modes, hooks, persistent memory, forked subagents, invocation patterns, and example subagent definitions.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

### When to Use Subagents

| Use subagents when... | Use main conversation when... |
| :--- | :--- |
| Task produces verbose output you don't need in main context | Frequent back-and-forth or iterative refinement is needed |
| You want to enforce specific tool restrictions or permissions | Multiple phases share significant context |
| Work is self-contained and can return a summary | Making a quick, targeted change |
| Running parallel independent investigations | Latency matters (subagents start fresh) |

### Built-in Subagents

| Name | Model | Tools | Purpose |
| :--- | :--- | :--- | :--- |
| **Explore** | Haiku | Read-only (no Write/Edit) | File discovery, codebase exploration |
| **Plan** | Inherits | Read-only (no Write/Edit) | Research during plan mode |
| **General-purpose** | Inherits | All tools | Complex multi-step tasks |
| statusline-setup | Sonnet | — | Configures status line via `/statusline` |
| claude-code-guide | Haiku | — | Answers questions about Claude Code features |

### Subagent Scopes and Priority

| Location | Scope | Priority |
| :--- | :--- | :--- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin's `agents/` directory | Where plugin is enabled | 5 (lowest) |

### Supported Frontmatter Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier (lowercase letters and hyphens) |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools; inherits all if omitted |
| `disallowedTools` | No | Denylist of tools (removed from inherited or specified list) |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before stopping |
| `skills` | No | Skills to preload into context at startup |
| `mcpServers` | No | MCP servers available to this subagent |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | Set `true` to always run as a background task |
| `effort` | No | `low`, `medium`, `high`, `xhigh`, `max` — overrides session effort |
| `isolation` | No | `worktree` to run in a temporary git worktree |
| `color` | No | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `initialPrompt` | No | Auto-submitted first turn when agent runs as main session via `--agent` |

### Model Resolution Order

When Claude invokes a subagent, model is resolved in this order:
1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Tool Control

```yaml
# Allowlist (only these tools available)
tools: Read, Grep, Glob, Bash

# Denylist (inherit all except these)
disallowedTools: Write, Edit

# Restrict spawnable subagent types (for --agent sessions)
tools: Agent(worker, researcher), Read, Bash
```

If both `tools` and `disallowedTools` are set, `disallowedTools` is applied first, then `tools` is resolved against the remainder.

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits for paths in working directory |
| `auto` | Background classifier reviews commands |
| `dontAsk` | Auto-deny prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission prompts (use with caution) |
| `plan` | Read-only exploration |

If parent uses `bypassPermissions` or `acceptEdits`, these take precedence and cannot be overridden.

### Persistent Memory Scopes

| Scope | Location | Use when |
| :--- | :--- | :--- |
| `user` | `~/.claude/agent-memory/<name>/` | Knowledge applies across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via version control |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not checked into version control |

When memory is enabled, the first 200 lines or 25KB of `MEMORY.md` is injected into the system prompt.

### Invocation Patterns

| Pattern | Syntax | Effect |
| :--- | :--- | :--- |
| Natural language | `Use the code-reviewer subagent to...` | Claude decides whether to delegate |
| @-mention | `@"code-reviewer (agent)" look at...` | Guarantees specific subagent runs |
| Session-wide | `claude --agent code-reviewer` | Whole session uses subagent's system prompt |
| Session default | Set `"agent": "code-reviewer"` in `.claude/settings.json` | Persists across sessions |

### Foreground vs. Background

- **Foreground**: blocks main conversation; permission prompts surface interactively
- **Background**: runs concurrently; auto-denies any prompt that would require user input
- Press **Ctrl+B** to background a running task
- Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable all background tasks

### Hooks in Subagent Frontmatter

| Event | When it fires |
| :--- | :--- |
| `PreToolUse` | Before the subagent uses a tool |
| `PostToolUse` | After the subagent uses a tool |
| `Stop` | When the subagent finishes (converted to `SubagentStop` at runtime) |

Project-level hooks in `settings.json` respond to `SubagentStart` and `SubagentStop` events. Both support matchers to target specific agent types by name.

### Forked Subagents (Experimental)

Enable with `CLAUDE_CODE_FORK_SUBAGENT=1` (requires v2.1.117+).

A fork inherits the full conversation history instead of starting fresh.

| | Fork | Named subagent |
| :--- | :--- | :--- |
| Context | Full conversation history | Fresh context |
| System prompt & tools | Same as main session | From definition file |
| Model | Same as main session | From `model` field |
| Prompt cache | Shared with main session | Separate cache |

Start a fork manually: `/fork draft unit tests for the parser changes so far`

### Transcript Storage

Subagent transcripts are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`. Cleaned up after `cleanupPeriodDays` (default: 30 days).

### CLI Flag for Session-Based Subagents

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer.",
    "prompt": "You are a senior code reviewer.",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

### Disabling Specific Subagents

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or via CLI: `claude --disallowedTools "Agent(Explore)"`

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — built-in subagents, quickstart, frontmatter fields, tool control, permission modes, hooks, memory, forked subagents, invocation, and examples

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
