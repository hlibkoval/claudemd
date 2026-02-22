---
name: sub-agents
description: Reference documentation for Claude Code subagents — creating custom subagents, built-in subagents (Explore, Plan, general-purpose), frontmatter configuration, tool restrictions, permission modes, persistent memory, hooks, model selection, foreground/background execution, isolation via worktrees, resuming subagents, and example subagent definitions.
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for creating and managing Claude Code subagents.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Claude delegates tasks to subagents based on description matching.

### Built-in Subagents

| Subagent        | Model   | Tools      | Purpose                                         |
|:----------------|:--------|:-----------|:------------------------------------------------|
| Explore         | Haiku   | Read-only  | File discovery, code search, codebase exploration |
| Plan            | Inherit | Read-only  | Codebase research for planning mode             |
| General-purpose | Inherit | All        | Complex research, multi-step operations         |
| Bash            | Inherit | —          | Running terminal commands in separate context   |
| Claude Code Guide | Haiku | —          | Answering questions about Claude Code features  |

### Subagent Locations (priority order)

| Location                 | Scope              | Priority      | How to create                        |
|:-------------------------|:-------------------|:--------------|:-------------------------------------|
| `--agents` CLI flag      | Current session    | 1 (highest)   | Pass JSON when launching Claude Code |
| `.claude/agents/`        | Current project    | 2             | Interactive or manual                |
| `~/.claude/agents/`      | All your projects  | 3             | Interactive or manual                |
| Plugin `agents/` dir     | Where plugin is on | 4 (lowest)    | Installed with plugins               |

When multiple subagents share the same name, the higher-priority location wins.

### Supported Frontmatter Fields

| Field             | Required | Description                                                              |
|:------------------|:---------|:-------------------------------------------------------------------------|
| `name`            | Yes      | Unique identifier (lowercase, hyphens)                                   |
| `description`     | Yes      | When Claude should delegate to this subagent                             |
| `tools`           | No       | Tools the subagent can use (inherits all if omitted)                     |
| `disallowedTools` | No       | Tools to deny, removed from inherited or specified list                  |
| `model`           | No       | `sonnet`, `opus`, `haiku`, or `inherit` (default: `inherit`)             |
| `permissionMode`  | No       | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan`      |
| `maxTurns`        | No       | Maximum agentic turns before the subagent stops                          |
| `skills`          | No       | Skills to inject into subagent context at startup                        |
| `mcpServers`      | No       | MCP servers available to this subagent                                   |
| `hooks`           | No       | Lifecycle hooks scoped to this subagent                                  |
| `memory`          | No       | Persistent memory scope: `user`, `project`, or `local`                   |
| `background`      | No       | `true` to always run as background task (default: `false`)               |
| `isolation`       | No       | `worktree` to run in a temporary git worktree (auto-cleaned if no changes) |

### File Format

```yaml
---
name: my-agent
description: What this agent does and when to use it
tools: Read, Glob, Grep, Bash
model: sonnet
---

You are a specialist. System prompt body goes here as Markdown.
```

The frontmatter defines metadata; the body becomes the system prompt.

### Permission Modes

| Mode                | Behavior                                                    |
|:--------------------|:------------------------------------------------------------|
| `default`           | Standard permission checking with prompts                   |
| `acceptEdits`       | Auto-accept file edits                                      |
| `dontAsk`           | Auto-deny prompts (explicitly allowed tools still work)     |
| `bypassPermissions` | Skip all permission checks (use with caution)               |
| `plan`              | Read-only exploration mode                                  |

If the parent uses `bypassPermissions`, it takes precedence and cannot be overridden.

### Persistent Memory Scopes

| Scope     | Location                                      | Use when                                              |
|:----------|:----------------------------------------------|:------------------------------------------------------|
| `user`    | `~/.claude/agent-memory/<name>/`              | Learnings should apply across all projects            |
| `project` | `.claude/agent-memory/<name>/`                | Knowledge is project-specific and shareable via VCS   |
| `local`   | `.claude/agent-memory-local/<name>/`          | Project-specific but should not be checked in         |

When memory is enabled, the subagent's system prompt includes the first 200 lines of `MEMORY.md`, and Read/Write/Edit tools are automatically enabled.

### Tool Restriction Patterns

Restrict with an allowlist:
```yaml
tools: Read, Grep, Glob, Bash
```

Restrict with a denylist:
```yaml
disallowedTools: Write, Edit
```

Restrict which subagents can be spawned (main agent only, via `claude --agent`):
```yaml
tools: Task(worker, researcher), Read, Bash
```

### Disable Specific Subagents

In settings or via CLI:
```json
{ "permissions": { "deny": ["Task(Explore)", "Task(my-agent)"] } }
```
```bash
claude --disallowedTools "Task(Explore)"
```

### Hooks in Subagent Frontmatter

| Event         | Matcher input | When it fires                               |
|:--------------|:--------------|:--------------------------------------------|
| `PreToolUse`  | Tool name     | Before the subagent uses a tool             |
| `PostToolUse` | Tool name     | After the subagent uses a tool              |
| `Stop`        | (none)        | When the subagent finishes (becomes `SubagentStop`) |

### Project-Level Subagent Hooks (in settings.json)

| Event           | Matcher input   | When it fires                    |
|:----------------|:----------------|:---------------------------------|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop`  | Agent type name | When a subagent completes        |

### Foreground vs Background

- **Foreground**: blocks main conversation; permission prompts pass through to user.
- **Background**: runs concurrently; permissions pre-approved at launch; MCP tools unavailable.
- Press **Ctrl+B** to background a running task.
- Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable background tasks.

### Resuming Subagents

Ask Claude to continue previous work to resume with full context. Transcripts are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl` and persist independently of main conversation compaction.

### Key Constraints

- Subagents **cannot** spawn other subagents.
- Subagents do **not** inherit skills from the parent; use the `skills` field explicitly.
- Subagents receive only their system prompt plus basic environment details, not the full Claude Code system prompt.
- CLI-defined subagents (`--agents` flag) exist only for that session.

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

The JSON supports the same fields as file-based frontmatter, with `prompt` for the system prompt body.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create Custom Subagents](references/claude-code-sub-agents.md) -- built-in subagents, configuration, tool restrictions, permission modes, persistent memory, hooks, foreground/background execution, resuming, and example subagent definitions

## Sources

- Create Custom Subagents: https://code.claude.com/docs/en/sub-agents.md
