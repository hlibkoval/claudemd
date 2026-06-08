---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — built-in agents, creating and configuring custom subagents, frontmatter fields, tool access, permission modes, persistent memory, hooks, forked subagents, invocation patterns, and common usage patterns.
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

### Built-in Subagents

| Agent | Model | Tools | Purpose |
| :--- | :--- | :--- | :--- |
| **Explore** | Haiku | Read-only | File discovery, code search, codebase exploration |
| **Plan** | Inherits | Read-only | Codebase research during plan mode |
| **General-purpose** | Inherits | All tools | Complex multi-step tasks requiring exploration and modification |
| **statusline-setup** | Sonnet | — | `/statusline` configuration |
| **claude-code-guide** | Haiku | — | Claude Code feature questions |

Explore and Plan skip CLAUDE.md and git status to keep research fast. All other subagents load both.

### Subagent Scope and Priority

| Location | Scope | Priority |
| :--- | :--- | :--- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin's `agents/` directory | Where plugin is enabled | 5 (lowest) |

When multiple subagents share the same name, the higher-priority location wins.

### Frontmatter Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier using lowercase letters and hyphens |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools the subagent can use; inherits all if omitted |
| `disallowedTools` | No | Tools to deny from inherited or specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, a full model ID, or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum number of agentic turns before the subagent stops |
| `skills` | No | Skills to preload into the subagent's context at startup |
| `mcpServers` | No | MCP servers available to this subagent (ignored for plugin subagents) |
| `hooks` | No | Lifecycle hooks scoped to this subagent (ignored for plugin subagents) |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as a background task; default `false` |
| `effort` | No | Effort override: `low`, `medium`, `high`, `xhigh`, `max` |
| `isolation` | No | `worktree` to run in a temporary git worktree |
| `color` | No | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `initialPrompt` | No | Auto-submitted as first user turn when agent runs as main session via `--agent` |

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits and common filesystem commands in working directory |
| `auto` | Background classifier reviews commands and protected-directory writes |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission prompts (use with caution) |
| `plan` | Plan mode (read-only exploration) |

If the parent uses `bypassPermissions` or `acceptEdits`, that takes precedence. If the parent uses `auto`, the subagent inherits it and any frontmatter `permissionMode` is ignored.

### Persistent Memory Scopes

| Scope | Location | Use when |
| :--- | :--- | :--- |
| `user` | `~/.claude/agent-memory/<name>/` | Learnings apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via version control |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not checked into version control |

Memory injects the first 200 lines or 25KB of `MEMORY.md` into the subagent's system prompt at startup.

### What Loads at Startup (Non-Fork Subagent)

| Loaded | Notes |
| :--- | :--- |
| System prompt | Agent's own prompt + environment details (not the full Claude Code system prompt) |
| Task message | Delegation prompt Claude writes when handing off the task |
| CLAUDE.md and memory | Full memory hierarchy — skipped by Explore and Plan only |
| Git status | Snapshot from session start — skipped by Explore and Plan |
| Preloaded skills | Skills listed in the `skills` field |

### Hooks in Subagent Frontmatter

All hook events are supported. Most common:

| Event | When it fires |
| :--- | :--- |
| `PreToolUse` | Before the subagent uses a tool |
| `PostToolUse` | After the subagent uses a tool |
| `Stop` | When the subagent finishes (converted to `SubagentStop` at runtime) |

### Project-Level Subagent Lifecycle Hooks (settings.json)

| Event | Matcher input | When it fires |
| :--- | :--- | :--- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Invocation Patterns

| Pattern | How | Guarantees |
| :--- | :--- | :--- |
| Natural language | Name the subagent in your prompt | Claude decides whether to delegate |
| @-mention | `@"agent-name (agent)"` | That subagent runs for one task |
| `--agent` flag | `claude --agent code-reviewer` | Whole session uses that subagent's system prompt |
| `agent` setting | `{ "agent": "code-reviewer" }` in `.claude/settings.json` | Default for every session in the project |

### Disable Specific Subagents

Add to `permissions.deny` in `settings.json`:

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or via CLI: `claude --disallowedTools "Agent(Explore)"`

### Forked Subagents

A fork inherits the entire current conversation instead of starting fresh. Available via `/fork <directive>` (enabled by default in v2.1.161+) or by setting `CLAUDE_CODE_FORK_SUBAGENT=1`.

| | Fork | Named subagent |
| :--- | :--- | :--- |
| Context | Full conversation history | Fresh context |
| System prompt | Same as main session | From definition file |
| Model | Same as main session | From `model` field |
| Prompt cache | Shared with main session | Separate cache |

A fork cannot spawn further forks.

### Foreground vs. Background Subagents

- **Foreground**: blocks main conversation until complete; permission prompts pass through interactively
- **Background**: runs concurrently; auto-denies tool calls that would prompt
- Press **Ctrl+B** to background a running task
- Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable all background tasks

### When to Use Subagents vs. Main Conversation

Use **subagents** when the task produces verbose output you don't need in your main context, enforces specific tool restrictions, or is self-contained and can return a summary.

Use the **main conversation** when the task needs frequent back-and-forth, multiple phases share significant context, you're making a quick change, or latency matters.

Consider **Skills** instead when you want reusable prompts or workflows that run in the main conversation context rather than isolated subagent context.

### Subagent Transcript Storage

- Stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`
- Cleaned up after `cleanupPeriodDays` (default: 30 days)
- Persist independently of main conversation compaction
- Resumable within the same session (requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` for the `SendMessage` tool)

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — built-in subagents, creating and configuring custom subagents, all frontmatter fields, model selection, tool access, permission modes, persistent memory, hooks, invocation patterns, forked subagents, common patterns, and example subagent definitions

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
