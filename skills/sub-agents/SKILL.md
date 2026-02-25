---
name: sub-agents
description: Reference documentation for Claude Code subagents -- creating custom subagents, built-in subagents (Explore, Plan, General-purpose), frontmatter configuration, tool restrictions, permission modes, model selection, persistent memory, hooks, skills injection, background/foreground execution, resuming subagents, context management, auto-compaction, and example subagent patterns.
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Claude delegates tasks to subagents based on their `description` field. Subagents cannot spawn other subagents.

### Built-in Subagents

| Agent             | Model    | Tools           | Purpose                                      |
|:------------------|:---------|:----------------|:---------------------------------------------|
| Explore           | Haiku    | Read-only       | Codebase search, file discovery, analysis    |
| Plan              | Inherits | Read-only       | Codebase research for plan mode              |
| General-purpose   | Inherits | All             | Complex multi-step tasks, code modifications |
| Bash              | Inherits | --              | Terminal commands in separate context         |
| statusline-setup  | Sonnet   | --              | Configuring status line via `/statusline`    |
| Claude Code Guide | Haiku    | --              | Answering questions about Claude Code        |

### Subagent Locations (Priority Order)

| Location                     | Scope                   | Priority    | How to create                        |
|:-----------------------------|:------------------------|:------------|:-------------------------------------|
| `--agents` CLI flag          | Current session         | 1 (highest) | Pass JSON when launching Claude Code |
| `.claude/agents/`            | Current project         | 2           | Interactive or manual                |
| `~/.claude/agents/`          | All your projects       | 3           | Interactive or manual                |
| Plugin's `agents/` directory | Where plugin is enabled | 4 (lowest)  | Installed with plugins               |

When multiple subagents share the same name, the higher-priority location wins.

### Frontmatter Fields

| Field             | Required | Description                                                                    |
|:------------------|:---------|:-------------------------------------------------------------------------------|
| `name`            | Yes      | Unique identifier (lowercase, hyphens)                                         |
| `description`     | Yes      | When Claude should delegate to this subagent                                   |
| `tools`           | No       | Allowlist of tools; inherits all if omitted                                    |
| `disallowedTools` | No       | Denylist of tools; removed from inherited/specified set                        |
| `model`           | No       | `sonnet`, `opus`, `haiku`, or `inherit` (default: `inherit`)                  |
| `permissionMode`  | No       | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan`           |
| `maxTurns`        | No       | Maximum agentic turns before stopping                                          |
| `skills`          | No       | Skills to inject into context at startup (full content, not just available)    |
| `mcpServers`      | No       | MCP servers: name reference or inline definition                               |
| `hooks`           | No       | Lifecycle hooks scoped to this subagent                                        |
| `memory`          | No       | Persistent memory scope: `user`, `project`, or `local`                        |
| `background`      | No       | `true` = always run as background task (default: `false`)                     |
| `isolation`       | No       | `worktree` = run in temporary git worktree with auto-cleanup                  |

### File Format

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze code and provide feedback.
```

The body becomes the system prompt. Subagents receive only this prompt (plus basic environment details), not the full Claude Code system prompt.

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

Use `prompt` for the system prompt (equivalent to the markdown body in file-based subagents).

### Tool Restriction: Spawnable Subagents

When running as main thread with `claude --agent`, use `Task(agent_type)` syntax to restrict which subagents can be spawned:

```yaml
tools: Task(worker, researcher), Read, Bash
```

Omitting `Task` entirely prevents spawning any subagents.

### Permission Modes

| Mode                | Behavior                                             |
|:--------------------|:-----------------------------------------------------|
| `default`           | Standard permission checking with prompts            |
| `acceptEdits`       | Auto-accept file edits                               |
| `dontAsk`           | Auto-deny prompts (explicitly allowed tools work)    |
| `bypassPermissions` | Skip all permission checks (use with caution)        |
| `plan`              | Plan mode (read-only exploration)                    |

If parent uses `bypassPermissions`, it takes precedence and cannot be overridden.

### Persistent Memory Scopes

| Scope     | Location                                      | Use when                                          |
|:----------|:----------------------------------------------|:--------------------------------------------------|
| `user`    | `~/.claude/agent-memory/<name>/`              | Learnings should persist across all projects      |
| `project` | `.claude/agent-memory/<name>/`                | Knowledge is project-specific and shareable via VCS |
| `local`   | `.claude/agent-memory-local/<name>/`          | Project-specific but not version-controlled       |

When memory is enabled, the subagent gets Read/Write/Edit tools and first 200 lines of `MEMORY.md` in its prompt.

### Hooks in Subagent Frontmatter

| Event         | Matcher input | When it fires                            |
|:--------------|:--------------|:-----------------------------------------|
| `PreToolUse`  | Tool name     | Before the subagent uses a tool          |
| `PostToolUse` | Tool name     | After the subagent uses a tool           |
| `Stop`        | (none)        | When the subagent finishes               |

`Stop` hooks in frontmatter are converted to `SubagentStop` events at runtime.

### Project-Level Subagent Hooks (settings.json)

| Event           | Matcher input   | When it fires                    |
|:----------------|:----------------|:---------------------------------|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop`  | Agent type name | When a subagent completes        |

### Foreground vs Background

- **Foreground**: blocks main conversation; permission prompts pass through
- **Background**: runs concurrently; permissions pre-approved at launch; auto-denies unapproved tools. Press Ctrl+B to background a running task. Resume failed background subagents in foreground with interactive prompts

Disable background tasks: set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

### Disabling Subagents

Add to `permissions.deny` in settings or use CLI flag:

```json
{ "permissions": { "deny": ["Task(Explore)", "Task(my-custom-agent)"] } }
```

```bash
claude --disallowedTools "Task(Explore)"
```

### Resuming Subagents

Ask Claude to continue previous work -- the resumed subagent retains its full conversation history. Transcripts are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create Custom Subagents](references/claude-code-sub-agents.md) -- built-in subagents, creating custom subagents, frontmatter fields, tool restrictions, permission modes, persistent memory, hooks, foreground/background execution, resuming, auto-compaction, and example subagent patterns

## Sources

- Create Custom Subagents: https://code.claude.com/docs/en/sub-agents.md
