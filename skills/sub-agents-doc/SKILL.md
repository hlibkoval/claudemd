---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — built-in subagents (Explore, Plan, general-purpose), creating and configuring custom subagents (all frontmatter fields), subagent scopes and priority, model selection, tool access (allowlist/denylist/Agent type restrictions), permission modes, MCP server scoping, skills preloading, persistent memory, hooks in subagent frontmatter, SubagentStart/SubagentStop events, invoking subagents (natural language, @-mention, --agent flag), foreground vs background execution, fork mode, context management (what loads at startup, resuming subagents, auto-compaction), and usage patterns.
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

### What Subagents Are

Subagents are specialized AI assistants that run in their own isolated context window with a custom system prompt, specific tool access, and independent permissions. Use one when a side task would flood your main conversation with output you won't need again; the subagent does the work in its own context and returns only a summary.

### Built-In Subagents

| Name | Model | Tools | Purpose |
| :--- | :--- | :--- | :--- |
| **Explore** | Haiku | Read-only | Fast codebase search and analysis. Skips CLAUDE.md and git status |
| **Plan** | Inherits | Read-only | Codebase research during plan mode. Skips CLAUDE.md and git status |
| **general-purpose** | Inherits | All | Complex multi-step tasks requiring exploration and modification |
| statusline-setup | Sonnet | — | Invoked by `/statusline` command |
| claude-code-guide | Haiku | — | Answers questions about Claude Code features |

### Subagent Scopes and Priority

| Location | Scope | Priority |
| :--- | :--- | :--- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin `agents/` directory | Where plugin is enabled | 5 (lowest) |

When the same name appears in multiple scopes, the higher-priority location wins. Directories are scanned recursively; identity comes from the `name` frontmatter field, not the filename or folder path.

### Supported Frontmatter Fields

Only `name` and `description` are required.

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier (lowercase, hyphens). Received as `agent_type` in hooks |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools. Inherits all if omitted. Use `Agent(name)` syntax to restrict spawning |
| `disallowedTools` | No | Denylist applied before `tools` resolution |
| `model` | No | `sonnet`, `opus`, `haiku`, a full model ID, or `inherit`. Defaults to `inherit` |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`. Ignored for plugin subagents |
| `maxTurns` | No | Maximum agentic turns before the subagent stops |
| `skills` | No | Skills to preload into context at startup (full content injected) |
| `mcpServers` | No | MCP servers for this subagent. Inline definitions connect/disconnect with the subagent. Ignored for plugin subagents |
| `hooks` | No | Lifecycle hooks scoped to this subagent. Ignored for plugin subagents |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as a background task. Default: `false` |
| `effort` | No | Overrides session effort: `low`, `medium`, `high`, `xhigh`, `max` |
| `isolation` | No | `worktree` — run in a temporary isolated git worktree |
| `color` | No | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `initialPrompt` | No | Auto-submitted first turn when agent runs as main session (via `--agent`). Commands and skills are processed |

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter Claude passes
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits and filesystem commands in working directory |
| `auto` | Background classifier reviews commands and protected-directory writes |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission prompts (use with caution) |
| `plan` | Read-only exploration mode |

If the parent uses `bypassPermissions` or `acceptEdits`, these take precedence and cannot be overridden. If the parent uses `auto` mode, the subagent inherits it and any `permissionMode` in frontmatter is ignored.

### Persistent Memory Scopes

| Scope | Location | Use when |
| :--- | :--- | :--- |
| `user` | `~/.claude/agent-memory/<name>/` | Knowledge applies across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via version control |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not checked in |

When memory is enabled, Read/Write/Edit tools are automatically enabled, and the first 200 lines or 25 KB of `MEMORY.md` in the memory directory is included in the system prompt.

### Tool Access Patterns

```yaml
# Allowlist (only these tools)
tools: Read, Grep, Glob, Bash

# Denylist (everything except these)
disallowedTools: Write, Edit

# Restrict which subagent types can be spawned (for --agent sessions)
tools: Agent(worker, researcher), Read, Bash

# Allow spawning any subagent
tools: Agent, Read, Bash
```

If both `tools` and `disallowedTools` are set, `disallowedTools` is applied first; a tool listed in both is removed.

### Invoking Subagents

| Method | How | Effect |
| :--- | :--- | :--- |
| Natural language | Name the subagent in your prompt | Claude decides whether to delegate |
| @-mention | `@"code-reviewer (agent)"` | Guarantees that specific subagent runs |
| `--agent` flag | `claude --agent code-reviewer` | Whole session uses the subagent's system prompt, tools, and model |
| `agent` setting | `{ "agent": "code-reviewer" }` in `.claude/settings.json` | Default for every session in the project |

### Foreground vs Background

| Mode | Behavior |
| :--- | :--- |
| Foreground | Blocks main conversation; permission prompts pass through interactively |
| Background | Runs concurrently; auto-denies tool calls that would prompt; use Ctrl+B to background a running task |

Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable all background task functionality.

### What Loads at Subagent Startup

A non-fork subagent's initial context contains:

- **System prompt**: the agent's own markdown body (not the full Claude Code system prompt)
- **Task message**: the delegation prompt Claude writes
- **CLAUDE.md and memory**: full memory hierarchy, except Explore and Plan skip this
- **Git status**: snapshot from parent session start, except Explore and Plan skip this
- **Preloaded skills**: full content of skills listed in the `skills` field

### Hooks for Subagents

**In subagent frontmatter** (fires only while that subagent is active):

| Event | When it fires |
| :--- | :--- |
| `PreToolUse` | Before the subagent uses a tool |
| `PostToolUse` | After the subagent uses a tool |
| `Stop` | When the subagent finishes (converted to `SubagentStop` at runtime) |

**In `settings.json`** (fires in the main session):

| Event | Matcher input | When it fires |
| :--- | :--- | :--- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Fork Mode (Experimental)

Requires `CLAUDE_CODE_FORK_SUBAGENT=1` (v2.1.117+). A fork inherits the entire conversation instead of starting fresh — same system prompt, tools, model, and message history. Use `/fork <directive>` to start one manually.

| | Fork | Named subagent |
| :--- | :--- | :--- |
| Context | Full conversation history | Fresh context |
| System prompt | Same as main session | From definition file |
| Model | Same as main session | From `model` field |
| Prompt cache | Shared with main session | Separate cache |

When fork mode is enabled, Claude uses forks instead of general-purpose for unspecified tasks, and all subagent spawns run in the background.

### Subagent Transcripts

Stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`. Persist independently of the main conversation. Cleaned up after `cleanupPeriodDays` (default: 30 days).

### Disabling Specific Subagents

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or via CLI: `claude --disallowedTools "Agent(Explore)"`

### Common Usage Patterns

- **Isolate high-volume operations**: delegate test runs, log processing, or doc fetching so verbose output stays out of your main context
- **Parallel research**: spawn multiple subagents to investigate independent areas simultaneously
- **Chain subagents**: use subagents in sequence, each returning results Claude passes to the next
- **Use main conversation** when: frequent back-and-forth, shared context across phases, quick targeted changes, or latency matters

### When to Use Subagents vs Alternatives

| Use | When |
| :--- | :--- |
| Subagents | Self-contained work, verbose output, tool restrictions needed |
| Main conversation | Iterative refinement, shared context, quick changes |
| Skills | Reusable prompts/workflows in the main context (not isolated) |
| `/btw` | Quick side question with no tool access; discarded after answering |
| Agent teams | Sustained parallelism, tasks exceeding context window |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — built-in subagents, quickstart via /agents command, all frontmatter fields, model selection, tool access, permission modes, MCP scoping, skills preloading, persistent memory, hooks, foreground/background execution, fork mode, context management, resuming subagents, auto-compaction, example subagent definitions

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
