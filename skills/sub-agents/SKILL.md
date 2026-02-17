---
name: sub-agents
description: Reference documentation for creating and configuring Claude Code custom subagents. Use when creating agent markdown files, configuring agent frontmatter, choosing agent models, setting tool restrictions, defining permission modes, preloading skills into agents, enabling persistent memory, or writing agent hooks.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code custom subagents.

## Quick Reference

Subagents are specialized AI assistants defined as Markdown files with YAML frontmatter. Each runs in its own context window with a custom system prompt, specific tool access, and independent permissions.

### Agent File Format

```markdown
---
name: my-agent
description: When Claude should delegate to this agent
tools: Read, Grep, Glob, Bash
model: sonnet
---

System prompt goes here...
```

### Frontmatter Fields

| Field             | Required | Description                                                          |
|:------------------|:---------|:---------------------------------------------------------------------|
| `name`            | Yes      | Unique identifier (lowercase, hyphens)                               |
| `description`     | Yes      | When Claude should delegate to this subagent                         |
| `tools`           | No       | Tools the subagent can use. Inherits all if omitted                  |
| `disallowedTools` | No       | Tools to deny, removed from inherited/specified list                 |
| `model`           | No       | `sonnet`, `opus`, `haiku`, or `inherit` (default: `inherit`)        |
| `permissionMode`  | No       | `default`, `acceptEdits`, `dontAsk`, `delegate`, `bypassPermissions`, `plan` |
| `maxTurns`        | No       | Max agentic turns before stopping                                    |
| `skills`          | No       | Skills to preload into agent context at startup                      |
| `mcpServers`      | No       | MCP servers available to this subagent                               |
| `hooks`           | No       | Lifecycle hooks scoped to this subagent                              |
| `memory`          | No       | Persistent memory scope: `user`, `project`, or `local`               |

### Agent Scope Priority

| Location                     | Scope           | Priority    |
|:-----------------------------|:----------------|:------------|
| `--agents` CLI flag          | Current session | 1 (highest) |
| `.claude/agents/`            | Current project | 2           |
| `~/.claude/agents/`          | All projects    | 3           |
| Plugin `agents/` directory   | Plugin scope    | 4 (lowest)  |

### Built-in Agents

| Agent             | Model   | Tools     | Purpose                              |
|:------------------|:--------|:----------|:-------------------------------------|
| Explore           | Haiku   | Read-only | File discovery, codebase exploration |
| Plan              | Inherit | Read-only | Codebase research for planning       |
| general-purpose   | Inherit | All       | Complex multi-step tasks             |
| Bash              | Inherit | Bash      | Terminal commands in separate context |
| Claude Code Guide | Haiku   | Read-only | Questions about Claude Code features |

### Permission Modes

| Mode                | Behavior                                           |
|:--------------------|:---------------------------------------------------|
| `default`           | Standard permission checking with prompts          |
| `acceptEdits`       | Auto-accept file edits                             |
| `dontAsk`           | Auto-deny permission prompts                       |
| `delegate`          | Coordination-only for agent team leads             |
| `bypassPermissions` | Skip all permission checks                         |
| `plan`              | Plan mode (read-only exploration)                  |

### Memory Scopes

| Scope     | Location                                      | Use when                                   |
|:----------|:----------------------------------------------|:-------------------------------------------|
| `user`    | `~/.claude/agent-memory/<name>/`              | Learnings across all projects              |
| `project` | `.claude/agent-memory/<name>/`                | Project-specific, shareable via VCS        |
| `local`   | `.claude/agent-memory-local/<name>/`          | Project-specific, not checked in           |

## Full Documentation

For the complete official documentation with all examples and advanced patterns, see:

- [Claude Code Subagents](references/claude-code-sub-agents.md) — complete documentation including built-in agents, configuration, patterns, and example agents

## Sources

- Claude Code Subagents: https://code.claude.com/docs/en/sub-agents.md
