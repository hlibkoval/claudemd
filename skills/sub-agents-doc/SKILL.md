---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — creating custom subagents, frontmatter configuration fields, tool access, permission modes, persistent memory, hooks, forked subagents, invocation patterns, and example subagent definitions.
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Use them to keep verbose output out of the main conversation, enforce tool restrictions, or reuse a workflow configuration.

### Built-in subagents

| Subagent | Model | Tools | When used |
| :--- | :--- | :--- | :--- |
| Explore | Haiku | Read-only | File discovery and codebase search |
| Plan | Inherits | Read-only | Research during plan mode |
| General-purpose | Inherits | All | Complex multi-step tasks requiring exploration + action |
| statusline-setup | Sonnet | — | Running `/statusline` |
| Claude Code Guide | Haiku | — | Questions about Claude Code features |

### Subagent scopes and priority

| Location | Scope | Priority |
| :--- | :--- | :--- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin `agents/` directory | Where plugin is enabled | 5 (lowest) |

When multiple subagents share the same name, the higher-priority location wins.

### Supported frontmatter fields

Only `name` and `description` are required.

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier; lowercase letters and hyphens |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools the subagent can use; inherits all if omitted |
| `disallowedTools` | No | Denylist removed from inherited or specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, a full model ID, or `inherit` (default) |
| `permissionMode` | No | Permission mode override (see table below) |
| `maxTurns` | No | Maximum agentic turns before stopping |
| `skills` | No | Skills to preload into the subagent's context at startup |
| `mcpServers` | No | MCP servers scoped to this subagent (inline definitions or references) |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as a background task (default: `false`) |
| `effort` | No | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `isolation` | No | `worktree` — run in a temporary git worktree |
| `color` | No | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `initialPrompt` | No | Auto-submitted first user turn when agent runs as main session via `--agent` |

### Model resolution order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Permission modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits and common filesystem commands |
| `auto` | Background classifier reviews commands and protected writes |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission prompts |
| `plan` | Plan mode (read-only exploration) |

If the parent uses `bypassPermissions` or `acceptEdits`, it takes precedence and cannot be overridden.

### Tool access

```yaml
# Allowlist: subagent can only use these tools
tools: Read, Grep, Glob, Bash

# Denylist: inherit all tools except these
disallowedTools: Write, Edit

# Restrict which subagents can be spawned (for --agent sessions)
tools: Agent(worker, researcher), Read, Bash
```

If both `tools` and `disallowedTools` are set, `disallowedTools` is applied first.

### Persistent memory scopes

| Scope | Location | Use when |
| :--- | :--- | :--- |
| `user` | `~/.claude/agent-memory/<name>/` | Learnings apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via version control |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not checked into version control |

When enabled, the subagent gets Read/Write/Edit tools automatically and its system prompt includes the first 200 lines or 25KB of `MEMORY.md`.

### Invocation patterns

```text
# Natural language — Claude decides whether to delegate
Use the code-reviewer subagent to review recent changes

# @-mention — guarantees that subagent runs for one task
@"code-reviewer (agent)" look at the auth changes

# Run entire session as a subagent
claude --agent code-reviewer

# Set as session default in .claude/settings.json
{ "agent": "code-reviewer" }
```

### Foreground vs background

- **Foreground** — blocks main conversation; permission prompts and `AskUserQuestion` pass through.
- **Background** — runs concurrently; permissions are pre-approved before launch, then auto-denied if not in the pre-approved set. Press **Ctrl+B** to background a running task.

Disable all background tasks: set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

### Hooks for subagents

**In subagent frontmatter** (active only while that subagent runs):

| Event | Matcher | When |
| :--- | :--- | :--- |
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (converted to `SubagentStop`) |

**In `settings.json`** (main session lifecycle events):

| Event | Matcher | When |
| :--- | :--- | :--- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Disabling specific subagents

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or via CLI: `claude --disallowedTools "Agent(Explore)"`.

### Forked subagents (experimental)

Requires Claude Code v2.1.117+ and `CLAUDE_CODE_FORK_SUBAGENT=1`.

A fork inherits the entire conversation history, system prompt, tools, and model from the main session. Use `/fork <directive>` to spawn one. Forks always run in the background and cannot spawn further forks.

| | Fork | Named subagent |
| :--- | :--- | :--- |
| Context | Full conversation history | Fresh context |
| System prompt / tools | Same as main session | From definition file |
| Model | Same as main session | From `model` field |
| Permissions | Prompts surface in terminal | Pre-approved before launch |
| Prompt cache | Shared with main session | Separate cache |

Fork panel keys: `↑`/`↓` move between rows, `Enter` opens transcript, `x` stops/dismisses, `Esc` returns focus.

### When to use subagents vs alternatives

| Situation | Use |
| :--- | :--- |
| Verbose output to isolate | Subagent |
| Enforce specific tool restrictions | Subagent |
| Self-contained task returning a summary | Subagent |
| Frequent back-and-forth or iterative work | Main conversation |
| Reusable prompt/workflow in main context | Skill |
| Quick in-context question, no tool access | `/btw` |
| Sustained parallelism exceeding context | Agent teams |

Note: subagents cannot spawn other subagents.

### CLI commands

```bash
# Launch with subagent definitions for the session
claude --agents '{"code-reviewer": {"description": "...", "prompt": "...", "tools": ["Read"]}}'

# List all configured subagents
claude agents

# Manage via interactive UI
/agents
```

### Subagent transcript locations

```
~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl
```

Auto-compaction triggers at ~95% capacity (override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`). Transcripts are cleaned up after `cleanupPeriodDays` (default: 30 days).

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — full guide covering built-in subagents, creating subagents via `/agents` or manually, all frontmatter fields, model selection, tool access, permission modes, MCP server scoping, skills preloading, persistent memory, hooks, forked subagents, invocation patterns, foreground/background execution, context management, and example definitions

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
