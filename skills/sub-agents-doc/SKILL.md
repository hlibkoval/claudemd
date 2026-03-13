---
name: sub-agents-doc
description: Complete documentation for Claude Code custom subagents -- creating subagents (markdown files with YAML frontmatter, `/agents` command, `--agents` CLI flag), subagent scopes (CLI/project/user/plugin with priority), built-in subagents (Explore, Plan, general-purpose, Bash, statusline-setup, Claude Code Guide), frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, isolation), tool control (allowlists, denylists, `Agent(type)` syntax for restricting spawnable subagents), scoped MCP servers (inline definitions, string references), permission modes (default, acceptEdits, dontAsk, bypassPermissions, plan), preloading skills into subagents, persistent memory (user/project/local scopes), hooks in subagent frontmatter (PreToolUse, PostToolUse, Stop), project-level hooks (SubagentStart, SubagentStop), disabling subagents via `permissions.deny`, foreground vs background execution, resuming subagents, auto-compaction, git worktree isolation, example subagents (code-reviewer, debugger, data-scientist, db-reader with hook validation). Load when discussing Claude Code subagents, custom agents, agent delegation, the `/agents` command, `--agents` flag, agent tool restrictions, agent memory, agent hooks, spawning subagents, background tasks, or agent configuration.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for creating and using custom subagents in Claude Code.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Claude delegates to subagents based on their `description` field. Subagents cannot spawn other subagents.

### Built-in Subagents

| Subagent | Model | Tools | Purpose |
|:---------|:------|:------|:--------|
| **Explore** | Haiku | Read-only | File discovery, code search, codebase exploration. Thoroughness levels: quick, medium, very thorough |
| **Plan** | Inherits | Read-only | Codebase research for plan mode |
| **general-purpose** | Inherits | All tools | Complex research, multi-step operations, code modifications |
| **Bash** | Inherits | Bash | Running terminal commands in separate context |
| **statusline-setup** | Sonnet | -- | Configuring status line via `/statusline` |
| **Claude Code Guide** | Haiku | -- | Answering Claude Code feature questions |

### Subagent Scopes (Priority Order)

| Location | Scope | Priority |
|:---------|:------|:---------|
| `--agents` CLI flag (JSON) | Current session only | 1 (highest) |
| `.claude/agents/` | Current project | 2 |
| `~/.claude/agents/` | All your projects | 3 |
| Plugin `agents/` directory | Where plugin is enabled | 4 (lowest) |

When multiple subagents share the same name, the higher-priority location wins.

### Subagent File Format

```markdown
---
name: my-agent
description: When Claude should delegate to this subagent
tools: Read, Glob, Grep
model: sonnet
---

System prompt in Markdown. This is the only prompt the subagent receives
(plus basic environment details like working directory).
```

Subagents are loaded at session start. Manually added files require a restart or `/agents` to load immediately.

### Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier (lowercase letters and hyphens) |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowed tools (inherits all if omitted) |
| `disallowedTools` | No | Tools to deny (removed from inherited/specified list) |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID (e.g. `claude-opus-4-6`), or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before subagent stops |
| `skills` | No | Skills to inject into subagent context at startup (full content, not just available for invocation) |
| `mcpServers` | No | MCP servers: string references to existing servers, or inline definitions |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as background task (default: `false`) |
| `isolation` | No | `worktree` to run in a temporary git worktree (auto-cleaned if no changes) |

### CLI-Defined Subagents

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer.",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

The `--agents` flag accepts JSON with the same frontmatter fields. Use `prompt` for the system prompt (equivalent to the markdown body in file-based subagents).

### Restricting Spawnable Subagents

When an agent runs as the main thread with `claude --agent`, use `Agent(type)` syntax in the `tools` field to restrict which subagents it can spawn:

```yaml
tools: Agent(worker, researcher), Read, Bash
```

This is an allowlist -- only `worker` and `researcher` can be spawned. Use `Agent` without parentheses to allow any subagent. Omit `Agent` entirely to prevent spawning any subagents. This only applies to agents running as the main thread; subagents themselves cannot spawn other subagents.

### Scoped MCP Servers

```yaml
mcpServers:
  # Inline definition: scoped to this subagent only
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  # Reference by name: reuses an already-configured server
  - github
```

Inline definitions connect when the subagent starts and disconnect when it finishes. Defining MCP servers inline keeps their tool descriptions out of the main conversation context.

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission checks (use with caution) |
| `plan` | Plan mode (read-only exploration) |

If the parent uses `bypassPermissions`, it takes precedence and cannot be overridden.

### Persistent Memory

| Scope | Location | Use when |
|:------|:---------|:---------|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings should apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Knowledge is project-specific, shareable via VCS |
| `local` | `.claude/agent-memory-local/<name>/` | Knowledge is project-specific, not checked in |

When memory is enabled, the subagent's system prompt includes the first 200 lines of `MEMORY.md` from the memory directory, plus instructions for reading/writing memory files. Read, Write, and Edit tools are automatically enabled.

### Hooks

**In subagent frontmatter** (run only while that subagent is active):

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (converted to `SubagentStop` at runtime) |

**In settings.json** (run in the main session):

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Foreground vs Background Execution

- **Foreground**: Blocks the main conversation. Permission prompts and clarifying questions pass through to the user.
- **Background**: Runs concurrently. Permissions are collected upfront before launch; anything not pre-approved is auto-denied. Press **Ctrl+B** to background a running task.

Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable background tasks entirely.

### Resuming Subagents

Ask Claude to continue a previous subagent's work to resume with full conversation history instead of starting fresh. Transcripts are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl` and persist independently of main conversation compaction. Cleaned up based on `cleanupPeriodDays` (default: 30 days).

### Disabling Subagents

Add to `permissions.deny` in settings or use the CLI flag:

```json
{ "permissions": { "deny": ["Agent(Explore)", "Agent(my-custom-agent)"] } }
```

```bash
claude --disallowedTools "Agent(Explore)"
```

### When to Use Subagents vs Main Conversation

**Use the main conversation** when: frequent back-and-forth is needed, multiple phases share context, making a quick targeted change, or latency matters.

**Use subagents** when: the task produces verbose output you don't need in main context, you want specific tool restrictions or permissions, or the work is self-contained and can return a summary.

Consider Skills for reusable prompts in the main conversation context. Use `/btw` for quick questions with full context but no tool access. Use Agent Teams when you need sustained parallelism or exceed the context window.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) -- built-in subagents (Explore, Plan, general-purpose), quickstart with `/agents` command, subagent scopes and priority, writing subagent files, frontmatter fields, `--agents` CLI flag for session-scoped agents, model selection, tool control (allowlists, denylists, `Agent(type)` syntax), scoped MCP servers, permission modes, preloading skills, persistent memory (user/project/local), hooks in frontmatter and settings.json (PreToolUse, PostToolUse, Stop, SubagentStart, SubagentStop), disabling subagents, foreground vs background execution, resuming subagents, auto-compaction, common patterns (isolating high-volume operations, parallel research, chaining subagents), example subagents (code-reviewer, debugger, data-scientist, db-reader with hook validation)

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
