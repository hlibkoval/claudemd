---
name: sub-agents-doc
description: Reference documentation for Claude Code subagents -- creating and configuring specialized AI assistants with custom system prompts, tool restrictions, permission modes, model selection, persistent memory, lifecycle hooks, foreground/background execution, and patterns for delegation, context isolation, parallel research, and chaining.
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Claude delegates tasks automatically based on each subagent's description.

### Built-in Subagents

| Agent             | Model    | Tools       | Purpose                                          |
|:------------------|:---------|:------------|:-------------------------------------------------|
| `Explore`         | Haiku    | Read-only   | Codebase search and analysis (quick/medium/very thorough) |
| `Plan`            | Inherits | Read-only   | Codebase research during plan mode               |
| `general-purpose` | Inherits | All         | Complex multi-step research and modification     |
| `Bash`            | Inherits | Bash        | Running terminal commands in separate context    |
| `statusline-setup`| Sonnet   | --          | Configures status line when you run `/statusline` |
| `Claude Code Guide`| Haiku   | --          | Answers questions about Claude Code features     |

### Subagent File Format

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze code and provide
specific, actionable feedback on quality, security, and best practices.
```

### Frontmatter Fields

| Field             | Required | Description                                                                             |
|:------------------|:---------|:----------------------------------------------------------------------------------------|
| `name`            | Yes      | Unique identifier (lowercase, hyphens)                                                  |
| `description`     | Yes      | When Claude should delegate to this subagent                                            |
| `tools`           | No       | Allowlist of tools the subagent can use (inherits all if omitted)                       |
| `disallowedTools` | No       | Denylist of tools to remove from inherited or specified list                            |
| `model`           | No       | `sonnet`, `opus`, `haiku`, or `inherit` (default: `inherit`)                            |
| `permissionMode`  | No       | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan`                    |
| `maxTurns`        | No       | Maximum agentic turns before the subagent stops                                         |
| `skills`          | No       | Skills to inject into subagent context at startup (full content, not just availability) |
| `mcpServers`      | No       | MCP servers available to this subagent (by name or inline config)                       |
| `hooks`           | No       | Lifecycle hooks scoped to this subagent                                                 |
| `memory`          | No       | Persistent memory scope: `user`, `project`, or `local`                                 |
| `background`      | No       | `true` to always run as a background task (default: `false`)                            |
| `isolation`       | No       | `worktree` to run in a temporary git worktree (auto-cleaned up if no changes)           |

### Subagent Locations (Priority Order)

| Location                     | Scope                   | Priority    |
|:-----------------------------|:------------------------|:------------|
| `--agents` CLI flag          | Current session only    | 1 (highest) |
| `.claude/agents/`            | Current project         | 2           |
| `~/.claude/agents/`          | All your projects       | 3           |
| Plugin's `agents/` directory | Where plugin is enabled | 4 (lowest)  |

### Permission Modes

| Mode                | Behavior                                                           |
|:--------------------|:-------------------------------------------------------------------|
| `default`           | Standard permission checking with prompts                          |
| `acceptEdits`       | Auto-accept file edits                                             |
| `dontAsk`           | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission checks (use with caution)                      |
| `plan`              | Plan mode (read-only exploration)                                  |

### Persistent Memory Scopes

| Scope     | Location                                      | Use when                                       |
|:----------|:----------------------------------------------|:-----------------------------------------------|
| `user`    | `~/.claude/agent-memory/<name>/`              | Learnings should apply across all projects     |
| `project` | `.claude/agent-memory/<name>/`                | Knowledge is project-specific and shareable    |
| `local`   | `.claude/agent-memory-local/<name>/`          | Knowledge is project-specific, not committed   |

When enabled: subagent gets a memory directory, first 200 lines of `MEMORY.md` are injected at startup, and Read/Write/Edit tools are automatically enabled.

### Hook Events for Subagents

In subagent frontmatter:

| Event         | When it fires                                           |
|:--------------|:--------------------------------------------------------|
| `PreToolUse`  | Before the subagent uses a tool                         |
| `PostToolUse` | After the subagent uses a tool                          |
| `Stop`        | When subagent finishes (converted to `SubagentStop`)    |

In `settings.json` (main session):

| Event           | When it fires                      |
|:----------------|:-----------------------------------|
| `SubagentStart` | When a subagent begins execution   |
| `SubagentStop`  | When a subagent completes          |

### Disabling Subagents

```json
{
  "permissions": {
    "deny": ["Task(Explore)", "Task(my-custom-agent)"]
  }
}
```

Or via CLI: `claude --disallowedTools "Task(Explore)"`

### CLI-Defined Subagents (Session-Only)

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer...",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

### Restricting Spawnable Subagents (for `--agent` main threads)

```yaml
tools: Task(worker, researcher), Read, Bash  # allowlist specific agents
tools: Task, Read, Bash                       # allow any subagent
# Omit Task entirely to forbid spawning any subagent
```

### Key Constraints

- Subagents cannot spawn other subagents (no nesting)
- Subagent transcripts stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`
- Auto-compaction triggers at ~95% context capacity (override with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`)
- Manage with `/agents` command; list via `claude agents`

## Full Documentation

For the complete official documentation, see the reference files:

- [Create Custom Subagents](references/claude-code-sub-agents.md) — built-in subagents, configuration options, tool control, permission modes, hooks, persistent memory, foreground/background execution, resuming subagents, and example subagents

## Sources

- Create Custom Subagents: https://code.claude.com/docs/en/sub-agents.md
