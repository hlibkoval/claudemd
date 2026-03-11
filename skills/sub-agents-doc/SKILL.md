---
name: sub-agents-doc
description: Complete documentation for Claude Code custom subagents -- creating subagents (YAML frontmatter + markdown body, /agents command, CLI --agents flag), built-in subagents (Explore, Plan, General-purpose, Bash, statusline-setup, Claude Code Guide), subagent scopes (CLI flag, project .claude/agents/, user ~/.claude/agents/, plugin agents/), frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, isolation), model selection (sonnet/opus/haiku/inherit), tool access control (allowlist, denylist, Agent(type) restrictions), permission modes (default, acceptEdits, dontAsk, bypassPermissions, plan), preloading skills into subagents, persistent memory (user/project/local scopes), hooks in subagent frontmatter (PreToolUse, PostToolUse, Stop), project-level SubagentStart/SubagentStop hooks, foreground vs background execution (Ctrl+B), resuming subagents, auto-compaction, disabling subagents via permissions.deny, common patterns (isolate high-volume operations, parallel research, chaining). Load when discussing subagents, custom agents, agent delegation, /agents command, agent configuration, Agent tool, or creating specialized AI assistants within Claude Code.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for creating and using custom subagents in Claude Code.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Claude delegates tasks to subagents based on their `description` field.

### Built-in Subagents

| Subagent | Model | Tools | Purpose |
|:---------|:------|:------|:--------|
| Explore | Haiku | Read-only | File discovery, code search, codebase exploration |
| Plan | Inherits | Read-only | Codebase research during plan mode |
| General-purpose | Inherits | All | Complex research, multi-step operations, code modifications |
| Bash | Inherits | Terminal | Running commands in separate context |
| statusline-setup | Sonnet | -- | Configuring status line via `/statusline` |
| Claude Code Guide | Haiku | -- | Answering questions about Claude Code features |

### Subagent Scopes (Priority Order)

| Location | Scope | Priority | Creation method |
|:---------|:------|:---------|:----------------|
| `--agents` CLI flag | Current session only | 1 (highest) | Pass JSON when launching Claude Code |
| `.claude/agents/` | Current project | 2 | Interactive (`/agents`) or manual file |
| `~/.claude/agents/` | All your projects | 3 | Interactive (`/agents`) or manual file |
| Plugin `agents/` dir | Where plugin is enabled | 4 (lowest) | Installed with plugins |

When multiple subagents share the same name, the higher-priority location wins.

### Subagent File Format

```markdown
---
name: my-agent
description: When Claude should delegate to this agent
tools: Read, Glob, Grep, Bash
model: sonnet
---

System prompt in markdown. This is the only prompt the subagent receives
(plus basic environment details like working directory).
```

### Supported Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier (lowercase letters and hyphens) |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowed tools (inherits all if omitted) |
| `disallowedTools` | No | Tools to deny (removed from inherited/specified list) |
| `model` | No | `sonnet`, `opus`, `haiku`, or `inherit` (default: `inherit`) |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before subagent stops |
| `skills` | No | Skills to inject into subagent context at startup |
| `mcpServers` | No | MCP servers available (by name or inline definition) |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as background task (default: `false`) |
| `isolation` | No | `worktree` to run in a temporary git worktree |

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission checks |
| `plan` | Plan mode (read-only exploration) |

If the parent uses `bypassPermissions`, it takes precedence and cannot be overridden.

### Tool Access Control

**Allowlist** -- specify only the tools the subagent can use:

```yaml
tools: Read, Grep, Glob, Bash
```

**Denylist** -- block specific tools while inheriting the rest:

```yaml
disallowedTools: Write, Edit
```

**Restrict which subagents an agent can spawn** (only applies to agents running as main thread via `claude --agent`):

```yaml
tools: Agent(worker, researcher), Read, Bash
```

Omitting `Agent` from the tools list entirely prevents spawning any subagents. Subagents themselves cannot spawn other subagents.

### Persistent Memory

| Scope | Location | Use when |
|:------|:---------|:---------|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings should apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Knowledge is project-specific, shareable via VCS |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific but not for version control |

When memory is enabled, the subagent's system prompt includes the first 200 lines of `MEMORY.md` from the memory directory, and Read/Write/Edit tools are automatically enabled.

### Hooks in Subagent Frontmatter

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (converted to `SubagentStop` at runtime) |

### Project-Level Subagent Lifecycle Hooks (in settings.json)

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Foreground vs Background Execution

- **Foreground** -- blocks the main conversation; permission prompts pass through to user.
- **Background** -- runs concurrently; permissions are pre-approved before launch; unapproved tools are auto-denied. Press **Ctrl+B** to background a running task.
- Disable background tasks: `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

### Resuming Subagents

Ask Claude to continue a previous subagent's work to retain full conversation history. Transcripts are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl` and persist independently of main conversation compaction.

### Disabling Subagents

Add to `permissions.deny` in settings or use the CLI flag:

```json
{ "permissions": { "deny": ["Agent(Explore)", "Agent(my-custom-agent)"] } }
```

```bash
claude --disallowedTools "Agent(Explore)"
```

### CLI --agents Flag

Define session-only subagents as JSON when launching Claude Code:

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

Accepts the same fields as file-based frontmatter, with `prompt` replacing the markdown body.

### Common Patterns

| Pattern | Description |
|:--------|:------------|
| Isolate high-volume operations | Delegate tests/logs/docs to subagent; only summary returns to main context |
| Parallel research | Spawn multiple subagents for independent investigations |
| Chain subagents | Use subagents in sequence, passing results between steps |

### When to Use Subagents vs Main Conversation

**Use main conversation** when the task needs frequent back-and-forth, shared context across phases, quick targeted changes, or low latency.

**Use subagents** when the task produces verbose output, needs specific tool restrictions, or is self-contained and can return a summary.

**Consider Skills** instead when you want reusable prompts running in the main conversation context rather than isolated subagent context.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) -- built-in subagents (Explore, Plan, General-purpose), creating subagents (/agents command, manual files, CLI --agents flag), scopes and priority, frontmatter fields, model selection, tool access control, permission modes, preloading skills, persistent memory, hooks (frontmatter and project-level), foreground/background execution, resuming, auto-compaction, disabling subagents, common patterns, example subagents

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
