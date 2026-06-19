---
name: sub-agents-doc
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents — specialized AI assistants that handle specific tasks in their own isolated context windows, keeping verbose output out of the main conversation.

## Quick Reference

### Built-in Subagents

| Agent | Model | Tools | When Claude uses it |
| :--- | :--- | :--- | :--- |
| `Explore` | Haiku | Read-only | Searching/analyzing codebases (skips CLAUDE.md and git status) |
| `Plan` | Inherits | Read-only | Codebase research during plan mode (skips CLAUDE.md and git status) |
| `general-purpose` | Inherits | All | Complex multi-step tasks requiring both exploration and modification |
| `statusline-setup` | Sonnet | — | When you run `/statusline` |
| `claude-code-guide` | Haiku | — | When you ask questions about Claude Code features |

Built-in subagents are always registered in interactive sessions. To disable all built-ins in non-interactive/SDK mode, set `CLAUDE_AGENT_SDK_DISABLE_BUILTIN_AGENTS=1`.

### Subagent Scope and Priority

| Location | Scope | Priority |
| :--- | :--- | :--- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin's `agents/` directory | Where plugin is enabled | 5 (lowest) |

When multiple subagents share the same `name`, the higher-priority location wins. Both `.claude/agents/` and `~/.claude/agents/` are scanned recursively — subdirectory paths do not affect agent identity (only the `name` frontmatter field matters). Keep `name` values unique within each scope.

### Supported Frontmatter Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier (lowercase letters and hyphens). Hooks receive this as `agent_type` |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools; inherits all if omitted. Use `Agent(worker, researcher)` syntax to restrict which subagents can be spawned |
| `disallowedTools` | No | Denylist applied before `tools` allowlist. `mcp__<server>` or `mcp__<server>__*` removes an entire MCP server |
| `model` | No | `sonnet`, `opus`, `haiku`, `fable`, a full model ID (e.g. `claude-opus-4-8`), or `inherit`. Defaults to `inherit` |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`. Ignored for plugin subagents |
| `maxTurns` | No | Maximum agentic turns before the subagent stops |
| `skills` | No | Skills to preload into the subagent's context at startup |
| `mcpServers` | No | MCP servers available to this subagent (inline or by reference). Ignored for plugin subagents |
| `hooks` | No | Lifecycle hooks scoped to this subagent. Ignored for plugin subagents |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as a background task. Default: `false` |
| `effort` | No | Effort level override: `low`, `medium`, `high`, `xhigh`, `max` |
| `isolation` | No | `worktree` to run in a temporary git worktree with an isolated copy of the repo |
| `color` | No | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan` |
| `initialPrompt` | No | Auto-submitted first user turn when agent runs as main session via `--agent` or the `agent` setting |

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter (Claude's choice at call time)
3. `model` frontmatter field in the subagent definition
4. Main conversation's model

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits in working directory |
| `auto` | Background classifier reviews commands |
| `dontAsk` | Auto-deny prompts (explicit allows still work) |
| `bypassPermissions` | Skip all permission prompts |
| `plan` | Read-only exploration (plan mode) |

If the parent uses `bypassPermissions` or `acceptEdits`, these take precedence and cannot be overridden. If the parent uses auto mode, subagent inherits it and frontmatter `permissionMode` is ignored.

### Persistent Memory Scopes

| Scope | Location | Use when |
| :--- | :--- | :--- |
| `user` | `~/.claude/agent-memory/<name>/` | Learnings should persist across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via version control |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not checked into version control |

When memory is enabled, the subagent's system prompt includes instructions to read/write the memory directory, plus the first 200 lines or 25 KB of `MEMORY.md`. Read, Write, and Edit tools are auto-enabled.

### Hooks in Subagent Frontmatter

| Event | Matcher input | When it fires |
| :--- | :--- | :--- |
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (converted to `SubagentStop` at runtime) |

All hook events are supported. `Stop` hooks in frontmatter are automatically converted to `SubagentStop` when the agent runs as a subagent.

### Project-Level Hooks for Subagent Events

| Event | Matcher input | When it fires |
| :--- | :--- | :--- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

Configure these in `settings.json` to respond to subagent lifecycle events.

### What Loads at Startup (Non-Fork Subagents)

| Content | Loads? | Exception |
| :--- | :--- | :--- |
| Agent's own system prompt | Always | — |
| CLAUDE.md files and memory hierarchy | Yes | Explore and Plan skip it |
| Git status snapshot | Yes | Explore and Plan skip it; also skipped when not a git repo |
| Preloaded skills (`skills` field) | Yes | Built-in agents don't preload skills |
| Parent conversation history | No | Only forks inherit this |

### Invoking Subagents Explicitly

| Method | Behavior |
| :--- | :--- |
| Natural language | Name the subagent; Claude decides whether to delegate |
| `@agent-<name>` mention | Guarantees the subagent runs for one task |
| `claude --agent <name>` | Entire session runs using that subagent's system prompt, tools, and model |
| `agent` setting in `.claude/settings.json` | Default agent for every session in a project |

For plugin subagents, use the scoped name: `@agent-my-plugin:code-reviewer` or `claude --agent my-plugin:review:security`.

### Foreground vs. Background

| Mode | Behavior |
| :--- | :--- |
| Foreground | Blocks main conversation; permission prompts surface to user |
| Background | Runs concurrently; auto-denies any tool call that would prompt |

Press **Ctrl+B** to background a running task. Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable all background tasks.

### Disable Specific Subagents

Add to `permissions.deny` in settings JSON:

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or use the CLI flag: `claude --disallowedTools "Agent(Explore)"`.

### Nested Subagents (v2.1.172+)

A subagent can spawn its own subagents (up to depth 5 below main). The subagent panel shows a `(+N)` count of descendants. Depth is fixed and not configurable. To prevent a subagent from spawning others, omit `Agent` from its `tools` list or add it to `disallowedTools`.

### Forked Subagents (v2.1.117+)

A fork inherits the entire conversation history instead of starting fresh.

|  | Fork | Named subagent |
| :--- | :--- | :--- |
| Context | Full conversation history | Fresh context |
| System prompt and tools | Same as main session | From definition file |
| Model | Same as main session | From `model` field |
| Prompt cache | Shared with main session | Separate cache |

Use `/fork <directive>` to start a fork explicitly. Control with `CLAUDE_CODE_FORK_SUBAGENT=1` (enable) or `=0` (disable). A fork cannot spawn another fork.

### Fork Panel Keys

| Key | Action |
| :--- | :--- |
| `↑` / `↓` | Move between rows |
| `Enter` | Open fork transcript and send follow-up messages |
| `x` | Dismiss a finished fork or stop a running one |
| `Esc` | Return focus to prompt input |

### Resuming Subagents

Each invocation creates a new instance, but you can resume a stopped subagent by asking Claude to continue the previous work. Resumed subagents retain full conversation history. Explore and Plan agents are one-shot and cannot be resumed. Resuming uses the `SendMessage` tool with the agent's ID (requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`).

Subagent transcripts are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl` and cleaned up after `cleanupPeriodDays` (default: 30 days).

### Common Patterns

| Pattern | Description |
| :--- | :--- |
| Isolate high-volume operations | Delegate test runs, log parsing, or doc fetching to keep verbose output out of main context |
| Parallel research | Spawn multiple subagents simultaneously for independent investigations |
| Chain subagents | Sequential subagent calls where each result feeds the next |

### When to Use Subagents vs. Main Conversation

| Use main conversation when... | Use subagents when... |
| :--- | :--- |
| Task needs frequent back-and-forth | Output would flood main context |
| Multiple phases share significant context | You want to enforce specific tool restrictions |
| Making a quick, targeted change | Work is self-contained and can return a summary |
| Latency matters (subagents start fresh) | You need isolated permissions or models |

### Subagent File Format

```
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. When invoked, analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```

Note: subagents load at session start. Direct disk edits require a session restart; `/agents`-created subagents take effect immediately.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — Built-in subagents, creating and configuring subagents, frontmatter reference, tool control, permission modes, persistent memory, hooks, forking, nested subagents, context management, example subagents

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
