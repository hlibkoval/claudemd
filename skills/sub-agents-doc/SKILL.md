---
name: sub-agents-doc
description: Complete documentation for Claude Code subagents — built-in agents (Explore, Plan, general-purpose), creating custom subagents, frontmatter fields, tool restrictions, permission modes, model selection, persistent memory, hooks in subagents, background/foreground execution, resuming subagents, auto-compaction, and example subagent definitions. Load when discussing subagent configuration, delegation, agent isolation, or the /agents command.
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents (custom and built-in).

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Claude delegates tasks to subagents based on their `description` field. Subagents cannot spawn other subagents.

### Built-in Subagents

| Agent | Model | Tools | Purpose |
|:------|:------|:------|:--------|
| Explore | Haiku | Read-only | File discovery, code search, codebase exploration |
| Plan | Inherits | Read-only | Codebase research for planning (plan mode) |
| general-purpose | Inherits | All | Complex research, multi-step ops, code modifications |
| Bash | Inherits | Terminal | Running commands in separate context |
| Claude Code Guide | Haiku | — | Answering questions about Claude Code features |

### Subagent Scope & Priority

| Location | Scope | Priority |
|:---------|:------|:---------|
| `--agents` CLI flag (JSON) | Current session only | 1 (highest) |
| `.claude/agents/` | Current project | 2 |
| `~/.claude/agents/` | All your projects | 3 |
| Plugin `agents/` directory | Where plugin is enabled | 4 (lowest) |

When multiple subagents share the same name, the higher-priority location wins.

### Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier (lowercase letters + hyphens) |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools; inherits all if omitted |
| `disallowedTools` | No | Tools to deny (removed from inherited/specified list) |
| `model` | No | `sonnet`, `opus`, `haiku`, or `inherit` (default: `inherit`) |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | No | Max agentic turns before the subagent stops |
| `skills` | No | Skills to inject into subagent context at startup |
| `mcpServers` | No | MCP servers available to this subagent |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as background task (default: `false`) |
| `isolation` | No | `worktree` for isolated git worktree copy |

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits |
| `dontAsk` | Auto-deny prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission checks |
| `plan` | Plan mode (read-only exploration) |

### Persistent Memory Scopes

| Scope | Location | Use when |
|:------|:---------|:---------|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via VCS |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not committed |

### Restricting Spawnable Subagents

Use `Agent(type1, type2)` in `tools` to allowlist which subagents an agent (running via `claude --agent`) can spawn. Omitting `Agent` entirely prevents spawning any subagents. Use `permissions.deny` with `Agent(name)` to block specific subagents.

### Foreground vs Background

| Mode | Behavior |
|:-----|:---------|
| Foreground | Blocks main conversation; permission prompts pass through |
| Background | Runs concurrently; permissions pre-approved before launch; clarifying questions fail |

Press **Ctrl+B** to background a running task. Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable.

### Subagent Hooks

**In frontmatter** (run while subagent is active): `PreToolUse`, `PostToolUse`, `Stop` (auto-converted to `SubagentStop`).

**In settings.json** (main session): `SubagentStart` and `SubagentStop` events with matcher on agent type name.

### Key Patterns

- **Isolate high-volume operations**: delegate tests/logs to subagent, get summary back
- **Parallel research**: spawn multiple subagents for independent investigations
- **Chain subagents**: sequential delegation where each returns results for the next
- **Resume subagents**: ask Claude to continue previous subagent work (retains full history)

### CLI Usage

```bash
# Define session-only subagents via JSON
claude --agents '{"name": {"description": "...", "prompt": "...", "tools": [...]}}'

# List all configured subagents
claude agents

# Disable a specific subagent
claude --disallowedTools "Agent(Explore)"
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) -- built-in subagents, creating custom subagents, frontmatter fields, tool control, permission modes, memory, hooks, foreground/background execution, resuming, auto-compaction, and example definitions

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
