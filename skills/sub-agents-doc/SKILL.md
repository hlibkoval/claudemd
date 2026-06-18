---
name: sub-agents-doc
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents — specialized AI assistants that handle specific tasks in their own isolated context window, with custom system prompts, tool access, and permission modes.

## Quick Reference

### Built-in Subagents

| Agent | Model | Tools | Purpose |
| :--- | :--- | :--- | :--- |
| `Explore` | Haiku | Read-only | File discovery, code search, codebase exploration |
| `Plan` | Inherits | Read-only | Codebase research during plan mode |
| `general-purpose` | Inherits | All tools | Complex research, multi-step operations, code modifications |
| `statusline-setup` | Sonnet | — | Configures status line via `/statusline` |
| `claude-code-guide` | Haiku | — | Answers questions about Claude Code features |

Explore and Plan skip CLAUDE.md and git status. All other subagents load both.

### Subagent Scopes (Priority Order)

| Location | Scope | Priority |
| :--- | :--- | :--- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin `agents/` directory | Where plugin is enabled | 5 (lowest) |

When the same `name` is defined in multiple locations, the highest-priority location wins.

### Supported Frontmatter Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier (lowercase letters and hyphens). Received as `agent_type` in hooks |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools. Inherits all if omitted. Use `Agent(worker, researcher)` syntax to restrict which subagent types can be spawned |
| `disallowedTools` | No | Denylist of tools, removed from inherited or specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, `fable`, full model ID, or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`. Ignored for plugin subagents |
| `maxTurns` | No | Maximum agentic turns before the subagent stops |
| `skills` | No | Skills to preload into subagent context at startup (full content injected) |
| `mcpServers` | No | MCP servers available to this subagent. Ignored for plugin subagents |
| `hooks` | No | Lifecycle hooks scoped to this subagent. Ignored for plugin subagents |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as a background task (default: `false`) |
| `effort` | No | Effort level: `low`, `medium`, `high`, `xhigh`, `max`. Overrides session effort |
| `isolation` | No | `worktree` to run in a temporary git worktree (auto-cleaned if no changes made) |
| `color` | No | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan` |
| `initialPrompt` | No | Auto-submitted as first user turn when agent runs as main session via `--agent` |

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable (if set)
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits for paths in working directory or `additionalDirectories` |
| `auto` | Background classifier reviews commands and protected-directory writes |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip permission prompts entirely (use with caution) |
| `plan` | Plan mode (read-only exploration) |

If the parent uses `bypassPermissions` or `acceptEdits`, it takes precedence and cannot be overridden by the subagent.

### Tool Control Patterns

```yaml
# Allowlist: only these tools
tools: Read, Grep, Glob, Bash

# Denylist: inherit all except these
disallowedTools: Write, Edit

# MCP server pattern: remove all tools from one server
disallowedTools: mcp__github

# Restrict which subagent types can be spawned (main-thread agent only)
tools: Agent(worker, researcher), Read, Bash
```

If both `tools` and `disallowedTools` are set, `disallowedTools` is applied first, then `tools` is resolved against what remains.

### Persistent Memory Scopes

| Scope | Location | Use when |
| :--- | :--- | :--- |
| `user` | `~/.claude/agent-memory/<name>/` | Knowledge applies across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via version control |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not checked in |

When memory is enabled, the subagent's system prompt includes instructions for reading/writing the memory directory, and the first 200 lines or 25KB of `MEMORY.md` is injected at startup. `Read`, `Write`, and `Edit` are automatically enabled.

### Hooks in Subagent Frontmatter

| Event | When it fires |
| :--- | :--- |
| `PreToolUse` | Before the subagent uses a tool |
| `PostToolUse` | After the subagent uses a tool |
| `Stop` | When the subagent finishes (converted to `SubagentStop` at runtime) |

Project-level hooks in `settings.json` can respond to `SubagentStart` and `SubagentStop` events, using the agent type name as the matcher.

### Invoking Subagents

| Method | How |
| :--- | :--- |
| Natural language | Name the subagent in your prompt; Claude decides whether to delegate |
| @-mention | Type `@` and pick from typeahead — guarantees the subagent runs |
| Session-wide | `claude --agent <name>` — whole session uses that subagent's system prompt and tools |
| Project default | Set `"agent": "<name>"` in `.claude/settings.json` |

Plugin subagents use scoped names like `my-plugin:code-reviewer`; use `@agent-my-plugin:code-reviewer` to @-mention manually.

### Foreground vs. Background

| Mode | Behavior |
| :--- | :--- |
| Foreground | Blocks main conversation; permission prompts passed through |
| Background | Runs concurrently; auto-denies any tool call that would prompt |

Claude decides foreground vs. background based on the task. Press Ctrl+B to background a running task, or set `background: true` in the frontmatter. Disable background tasks with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

### Forked Subagents (`/fork`)

A fork inherits the full conversation history instead of starting fresh. Use when the subagent would need too much background to be useful as a named agent, or to try parallel approaches from the same starting point.

| | Fork | Named subagent |
| :--- | :--- | :--- |
| Context | Full conversation history | Fresh context with delegation prompt |
| System prompt | Same as main session | From the subagent's definition file |
| Model | Same as main session | From `model` frontmatter |
| Prompt cache | Shared with main session | Separate cache |

Start a fork with `/fork <directive>`. Forks always run in the background. A fork cannot spawn another fork.

Control fork mode with `CLAUDE_CODE_FORK_SUBAGENT=1` (enable) or `=0` (disable everywhere, including server-side rollout).

### Nested Subagents (v2.1.172+)

Subagents can spawn their own subagents. Depth is counted from the main conversation:

- **Foreground subagents**: can spawn at any depth (self-limiting since each level blocks its parent)
- **Background subagents**: capped at depth 5; agents at depth 5 do not receive the Agent tool

### What Loads at Startup (Non-Fork Subagents)

| Component | Loads? |
| :--- | :--- |
| Subagent's own system prompt | Always |
| Task message (Claude's delegation prompt) | Always |
| CLAUDE.md and memory hierarchy | Yes, except Explore and Plan |
| Git status snapshot | Yes, except Explore and Plan (also requires `includeGitInstructions: true`) |
| Preloaded skills (from `skills` field) | Yes, except built-in agents |
| Parent conversation history | No (only forks inherit this) |

### Disabling Subagents

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or via CLI: `claude --disallowedTools "Agent(Explore)"`

To block all subagents: deny the `Agent` tool in `permissions.deny`.

To disable built-in agents in non-interactive/SDK mode: set `CLAUDE_AGENT_SDK_DISABLE_BUILTIN_AGENTS=1`.

### Subagent Transcripts

Stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`. Cleaned up after `cleanupPeriodDays` (default: 30 days). Compaction events are logged in the transcript with `type: "system"`, `subtype: "compact_boundary"`.

### Common Patterns

| Pattern | Use |
| :--- | :--- |
| Isolate high-volume output | Delegate test runs, log processing, doc fetches to subagents; only summary returns |
| Parallel research | Spawn multiple subagents for independent investigations simultaneously |
| Chain subagents | Sequential workflow: reviewer finds issues → optimizer fixes them |

### When to Use Subagents vs. Main Conversation

Use **subagents** when the task produces verbose output, needs specific tool restrictions, or is self-contained and can return a summary.

Use the **main conversation** when you need frequent back-and-forth, multiple phases share context, or you're making a quick targeted change.

Use **Skills** instead when you want reusable prompts or workflows that run in the main conversation context.

Use `/btw` for quick side questions — it sees full context but has no tool access and the answer is not added to history.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — Complete guide: built-in subagents, creating and configuring custom subagents, frontmatter fields, tool control, permission modes, memory, hooks, invocation patterns, forks, nested subagents, context management, and example subagents

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
