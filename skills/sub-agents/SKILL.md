---
name: sub-agents
description: Reference documentation for Claude Code subagents — creating, configuring, and working with specialized AI subagents that run in isolated context windows. Use when creating custom subagents, configuring tools and permission modes, using the /agents command, setting up hooks for subagents, managing subagent memory, or understanding when to use subagents versus the main conversation.
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Claude automatically delegates tasks to subagents based on their description.

### Built-in Subagents

| Agent             | Model    | Tools        | Purpose                                              |
|:------------------|:---------|:-------------|:-----------------------------------------------------|
| Explore           | Haiku    | Read-only    | Codebase search and analysis (quick/medium/thorough) |
| Plan              | Inherit  | Read-only    | Codebase research during plan mode                   |
| General-purpose   | Inherit  | All          | Complex multi-step exploration and modification      |
| Bash              | Inherit  | —            | Terminal commands in separate context                |
| statusline-setup  | Sonnet   | —            | Configures status line via `/statusline`             |
| Claude Code Guide | Haiku    | —            | Answers questions about Claude Code features         |

### Subagent Scope (Priority Order)

| Location                     | Scope                   | Priority    |
|:-----------------------------|:------------------------|:------------|
| `--agents` CLI flag          | Current session only    | 1 (highest) |
| `.claude/agents/`            | Current project         | 2           |
| `~/.claude/agents/`          | All your projects       | 3           |
| Plugin's `agents/` directory | Where plugin is enabled | 4 (lowest)  |

### Frontmatter Fields

| Field            | Required | Description                                                                              |
|:-----------------|:---------|:-----------------------------------------------------------------------------------------|
| `name`           | Yes      | Unique identifier (lowercase, hyphens)                                                   |
| `description`    | Yes      | When Claude should delegate to this subagent                                             |
| `tools`          | No       | Allowlist of tools; inherits all if omitted. Use `Task(name)` to restrict spawnable agents |
| `disallowedTools`| No       | Denylist of tools, removed from inherited or specified list                              |
| `model`          | No       | `sonnet`, `opus`, `haiku`, or `inherit` (default: `inherit`)                             |
| `permissionMode` | No       | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan`                      |
| `maxTurns`       | No       | Maximum agentic turns before the subagent stops                                          |
| `skills`         | No       | Skills to inject into the subagent's context at startup (full content, not just available)|
| `mcpServers`     | No       | MCP servers available to this subagent (name reference or inline definition)             |
| `hooks`          | No       | Lifecycle hooks scoped to this subagent                                                  |
| `memory`         | No       | Persistent memory scope: `user`, `project`, or `local`                                  |

### Permission Modes

| Mode                | Behavior                                                           |
|:--------------------|:-------------------------------------------------------------------|
| `default`           | Standard permission checking with prompts                          |
| `acceptEdits`       | Auto-accept file edits                                             |
| `dontAsk`           | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission checks (use with caution)                      |
| `plan`              | Plan mode (read-only exploration)                                  |

### Persistent Memory Scopes

| Scope     | Location                                      | Use when                                                 |
|:----------|:----------------------------------------------|:---------------------------------------------------------|
| `user`    | `~/.claude/agent-memory/<name>/`              | Learnings should apply across all projects (recommended) |
| `project` | `.claude/agent-memory/<name>/`                | Project-specific, shareable via version control          |
| `local`   | `.claude/agent-memory-local/<name>/`          | Project-specific, not checked in                         |

### Hook Events for Subagents

| Event           | Where configured  | When it fires                         |
|:----------------|:------------------|:--------------------------------------|
| `PreToolUse`    | Subagent frontmatter | Before the subagent uses a tool    |
| `PostToolUse`   | Subagent frontmatter | After the subagent uses a tool     |
| `Stop`          | Subagent frontmatter | When subagent finishes (converted to `SubagentStop`) |
| `SubagentStart` | `settings.json`   | When any subagent begins execution    |
| `SubagentStop`  | `settings.json`   | When any subagent completes           |

### Disabling Subagents

Add to `settings.json` `permissions.deny`:

```json
{
  "permissions": {
    "deny": ["Task(Explore)", "Task(my-custom-agent)"]
  }
}
```

Or via CLI: `claude --disallowedTools "Task(Explore)"`

### Subagent File Format

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Grep, Glob, Bash
model: sonnet
---

You are a code reviewer. Analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```

### When to Use Subagents vs Main Conversation

Use **subagents** when the task produces verbose output, needs specific tool restrictions, or is self-contained with a summary return.

Use the **main conversation** when you need frequent back-and-forth, shared context across phases, quick targeted changes, or low latency.

Subagents **cannot spawn other subagents**. For nested delegation use skills or chain subagents from the main conversation.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create Custom Subagents](references/claude-code-sub-agents.md) — built-in subagents, creating custom subagents, all configuration options, working patterns, and example subagents

## Sources

- Create Custom Subagents: https://code.claude.com/docs/en/sub-agents.md
