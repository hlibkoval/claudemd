---
name: sub-agents
description: Reference documentation for Claude Code subagents — creating custom subagents, built-in subagents (Explore, Plan, general-purpose), configuring frontmatter fields, tool restrictions, permission modes, persistent memory, hooks, model selection, background/foreground execution, resuming subagents, and example subagent definitions. Use when creating or configuring subagents, delegating tasks, restricting tool access, or comparing subagents to agent teams.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for creating and using custom subagents in Claude Code.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Claude delegates tasks to subagents based on their `description` field.

### Built-in Subagents

| Subagent        | Model   | Tools      | Purpose                                |
|:----------------|:--------|:-----------|:---------------------------------------|
| Explore         | Haiku   | Read-only  | File discovery, code search, codebase exploration |
| Plan            | Inherit | Read-only  | Codebase research for plan mode        |
| General-purpose | Inherit | All        | Complex multi-step tasks requiring exploration and action |
| Bash            | Inherit | —          | Running terminal commands in separate context |
| Claude Code Guide | Haiku | —          | Answering questions about Claude Code features |

### Subagent File Locations (by priority)

| Location                     | Scope               | Priority    |
|:-----------------------------|:---------------------|:------------|
| `--agents` CLI flag (JSON)   | Current session      | 1 (highest) |
| `.claude/agents/`            | Current project      | 2           |
| `~/.claude/agents/`          | All your projects    | 3           |
| Plugin `agents/` directory   | Where plugin enabled | 4 (lowest)  |

### Frontmatter Fields

| Field             | Required | Description                                                          |
|:------------------|:---------|:---------------------------------------------------------------------|
| `name`            | Yes      | Unique identifier (lowercase, hyphens)                               |
| `description`     | Yes      | When Claude should delegate to this subagent                         |
| `tools`           | No       | Allowed tools (inherits all if omitted)                              |
| `disallowedTools` | No       | Tools to deny (removed from inherited/specified list)                |
| `model`           | No       | `sonnet`, `opus`, `haiku`, or `inherit` (default: `inherit`)        |
| `permissionMode`  | No       | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns`        | No       | Max agentic turns before the subagent stops                          |
| `skills`          | No       | Skills to inject into subagent context at startup                    |
| `mcpServers`      | No       | MCP servers available to this subagent                               |
| `hooks`           | No       | Lifecycle hooks scoped to this subagent                              |
| `memory`          | No       | Persistent memory scope: `user`, `project`, or `local`              |
| `background`      | No       | `true` to always run as background task (default: `false`)          |
| `isolation`       | No       | `worktree` to run in temporary git worktree (auto-cleaned if no changes) |

### Subagent File Format

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze the code and provide
specific, actionable feedback on quality and best practices.
```

Frontmatter = configuration. Body = system prompt (subagents receive only this, not the full Claude Code system prompt).

### Permission Modes

| Mode                | Behavior                                                  |
|:--------------------|:----------------------------------------------------------|
| `default`           | Standard permission checking with prompts                 |
| `acceptEdits`       | Auto-accept file edits                                    |
| `dontAsk`           | Auto-deny prompts (explicitly allowed tools still work)   |
| `bypassPermissions` | Skip all permission checks                                |
| `plan`              | Plan mode (read-only exploration)                         |

If parent uses `bypassPermissions`, it takes precedence and cannot be overridden.

### Persistent Memory Scopes

| Scope     | Location                                      | Use when                                         |
|:----------|:----------------------------------------------|:-------------------------------------------------|
| `user`    | `~/.claude/agent-memory/<name>/`              | Learnings should apply across all projects       |
| `project` | `.claude/agent-memory/<name>/`                | Knowledge is project-specific, shareable via VCS |
| `local`   | `.claude/agent-memory-local/<name>/`          | Project-specific, not checked into VCS           |

### Restricting Subagent Spawning

When running as main thread with `claude --agent`, use `Task(agent_type)` in `tools` to allowlist which subagents can be spawned:

```yaml
tools: Task(worker, researcher), Read, Bash
```

Omit `Task` entirely to prevent spawning any subagents. Use `Task` without parentheses to allow all.

### Disabling Subagents

Add to `permissions.deny` in settings or use `--disallowedTools`:

```json
{ "permissions": { "deny": ["Task(Explore)", "Task(my-agent)"] } }
```

### Foreground vs. Background

- **Foreground**: blocks main conversation; permission prompts pass through to user
- **Background**: runs concurrently; permissions pre-approved at launch; MCP tools unavailable
- Press **Ctrl+B** to background a running subagent
- Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable background tasks entirely

### Hooks in Subagent Frontmatter

| Event         | Matcher input | When it fires                          |
|:--------------|:--------------|:---------------------------------------|
| `PreToolUse`  | Tool name     | Before the subagent uses a tool        |
| `PostToolUse` | Tool name     | After the subagent uses a tool         |
| `Stop`        | (none)        | When the subagent finishes             |

### Project-Level Subagent Hooks (in settings.json)

| Event           | Matcher input   | When it fires                    |
|:----------------|:----------------|:---------------------------------|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop`  | Agent type name | When a subagent completes        |

### CLI-Defined Subagents

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

Accepts the same fields as file-based frontmatter; use `prompt` for the system prompt.

### Key Constraints

- Subagents **cannot** spawn other subagents
- Subagents **do not** inherit skills from the parent conversation (use `skills` field to inject explicitly)
- Subagents are loaded at session start; use `/agents` to reload without restart
- Resumed subagents retain full conversation history
- Transcripts stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`

## Full Documentation

For the complete official documentation, see the reference files:

- [Custom Subagents](references/claude-code-sub-agents.md) — full guide including built-in subagents, creating custom subagents, frontmatter reference, tool restrictions, permission modes, persistent memory, hooks, background execution, resuming, and example subagent definitions

## Sources

- Custom Subagents: https://code.claude.com/docs/en/sub-agents.md
