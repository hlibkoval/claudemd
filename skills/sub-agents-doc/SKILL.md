---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — built-in agents, creating and configuring custom subagents, frontmatter fields, model selection, tool control, permission modes, persistent memory, hooks, forking, invocation patterns, context management, and example subagents.
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

### What Are Subagents?

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Use them when a side task would flood your main conversation with output you won't reference again — the subagent does the work and returns only the summary.

Subagents cannot spawn other subagents. For nested delegation, chain subagents from the main conversation or use Skills.

### Built-in Subagents

| Agent | Model | Tools | Purpose |
| :--- | :--- | :--- | :--- |
| **Explore** | Haiku | Read-only | File discovery, code search — skips CLAUDE.md and git status |
| **Plan** | Inherits | Read-only | Codebase research during plan mode — skips CLAUDE.md and git status |
| **General-purpose** | Inherits | All | Complex multi-step tasks requiring both exploration and action |
| **statusline-setup** | Sonnet | — | Configure status line via `/statusline` |
| **claude-code-guide** | Haiku | — | Answer questions about Claude Code features |

### Subagent Scope and Priority

| Location | Scope | Priority |
| :--- | :--- | :--- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin's `agents/` directory | Where plugin is enabled | 5 (lowest) |

When multiple subagents share the same name, the higher-priority location wins. Subagents created through `/agents` take effect immediately; file edits require a session restart.

### Frontmatter Fields

Only `name` and `description` are required.

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier (lowercase letters and hyphens) |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools; inherits all if omitted |
| `disallowedTools` | No | Denylist of tools removed from inherited or specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, a full model ID, or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before the subagent stops |
| `skills` | No | Skills to preload into context at startup |
| `mcpServers` | No | MCP servers available to this subagent (inline or by reference name) |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | Set `true` to always run as a background task (default: `false`) |
| `effort` | No | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `isolation` | No | Set `worktree` to run in an isolated git worktree |
| `color` | No | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `initialPrompt` | No | Auto-submitted as first user turn when agent runs as main session |

Plugin subagents do not support `hooks`, `mcpServers`, or `permissionMode` — those fields are ignored.

### Model Resolution Order

When Claude invokes a subagent, the model is resolved in this order:
1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Tool Control

**Allowlist** (`tools`): only listed tools are available.
**Denylist** (`disallowedTools`): listed tools are removed from inherited or specified set.
If both are set, `disallowedTools` is applied first; a tool in both is removed.

To restrict which subagents an agent-as-main-thread can spawn, use `Agent(worker, researcher)` syntax in `tools`. Omitting `Agent` entirely prevents spawning any subagents.

To deny specific subagents session-wide, add to `settings.json`:
```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits for paths in working directory or `additionalDirectories` |
| `auto` | Background classifier reviews commands and protected-directory writes |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission prompts (use with caution) |
| `plan` | Read-only exploration |

If parent uses `bypassPermissions` or `acceptEdits`, it takes precedence and cannot be overridden by the subagent.

### Persistent Memory Scopes

| Scope | Location | Use when |
| :--- | :--- | :--- |
| `user` | `~/.claude/agent-memory/<name>/` | Learnings should apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Knowledge is project-specific and shareable via version control |
| `local` | `.claude/agent-memory-local/<name>/` | Knowledge is project-specific but should not be checked in |

When memory is enabled: the system prompt includes instructions for reading/writing to the memory directory, plus the first 200 lines or 25KB of `MEMORY.md`. Read, Write, and Edit tools are automatically enabled.

### Hooks for Subagents

**Hooks in subagent frontmatter** (run only while that subagent is active):

| Event | When it fires |
| :--- | :--- |
| `PreToolUse` | Before the subagent uses a tool |
| `PostToolUse` | After the subagent uses a tool |
| `Stop` | When the subagent finishes (converted to `SubagentStop` at runtime) |

**Project-level hooks in `settings.json`** (respond to subagent lifecycle in main session):

| Event | Matcher input | When it fires |
| :--- | :--- | :--- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Invocation Patterns

| Pattern | How |
| :--- | :--- |
| Natural language | Name the subagent in your prompt; Claude decides whether to delegate |
| @-mention | `@"code-reviewer (agent)"` — guarantees that subagent runs |
| Session-wide | `claude --agent code-reviewer` — whole session uses that agent's system prompt and tools |
| Project default | Set `"agent": "code-reviewer"` in `.claude/settings.json` |

CLI flag overrides the `agent` setting when both are present.

### Foreground vs. Background Subagents

- **Foreground**: blocks main conversation until complete; permission prompts surface to you
- **Background**: runs concurrently; auto-denies tool calls that would prompt

Press **Ctrl+B** to background a running task. Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable all background task functionality.

### What Loads at Subagent Startup

| Content | Loads? | Notes |
| :--- | :--- | :--- |
| Agent's own system prompt | Yes | From markdown body or `prompt` field |
| Task delegation message | Yes | Written by Claude when handing off |
| CLAUDE.md and memory hierarchy | Yes | Except Explore and Plan — they skip it |
| Git status snapshot | Yes | Except Explore and Plan — they skip it |
| Preloaded skills (`skills` field) | Yes | Full content injected at startup |
| Parent conversation history | No | Only forks inherit parent history |

### Fork Mode (Experimental)

Requires Claude Code v2.1.117+ and `CLAUDE_CODE_FORK_SUBAGENT=1`.

A fork inherits the entire parent conversation instead of starting fresh. Use it when a named subagent would need too much background to be useful.

| | Fork | Named subagent |
| :--- | :--- | :--- |
| Context | Full conversation history | Fresh context |
| System prompt and tools | Same as main session | From definition file |
| Model | Same as main session | From `model` field |
| Prompt cache | Shared with main session | Separate cache |

Enable fork mode with `/fork <directive>` in the session. When fork mode is enabled, every subagent spawn runs in the background. A fork cannot spawn further forks.

**Fork panel keys:**

| Key | Action |
| :--- | :--- |
| `↑` / `↓` | Move between rows |
| `Enter` | Open fork's transcript and send follow-up messages |
| `x` | Dismiss finished fork or stop a running one |
| `Esc` | Return focus to prompt input |

### Resuming Subagents

Each invocation creates a new instance. To continue an existing subagent's work, ask Claude to resume it. Resumed subagents retain full conversation history. Requires agent teams enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`).

Subagent transcripts are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl` and cleaned up per `cleanupPeriodDays` (default: 30 days).

### Auto-Compaction

Subagents auto-compact at approximately 95% context capacity (same as main conversation). Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`. Compaction events are logged in subagent transcript files as `compact_boundary` system messages.

### When to Use Subagents vs. Alternatives

| Situation | Use |
| :--- | :--- |
| Task produces verbose output you don't need in main context | Subagent |
| Work is self-contained and can return a summary | Subagent |
| Enforce specific tool restrictions or permissions | Subagent |
| Frequent back-and-forth or iterative refinement needed | Main conversation |
| Reusable prompt/workflow in main conversation context | Skills |
| Quick question with no tool access needed | `/btw` |
| Sustained parallelism or context-window-exceeding tasks | Agent teams |

### CLI Flag for Session-Defined Subagents

Pass JSON with `--agents` to define subagents for a single session (not saved to disk):

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

Accepts the same fields as file-based subagent frontmatter (`prompt` maps to the markdown body).

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — built-in subagents, quickstart, configuration, scope and priority, frontmatter fields, model selection, tool control, permission modes, skills preloading, persistent memory, hooks, invocation patterns, foreground/background, context management, fork mode, example subagents

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
