---
name: sub-agents-doc
description: Complete documentation for Claude Code subagents — specialized AI assistants that handle specific tasks in their own context window with custom system prompts, tool restrictions, and independent permissions. Covers built-in subagents (Explore, Plan, General-purpose, Bash, statusline-setup, Claude Code Guide), creating custom subagents via /agents command or manually as Markdown files with YAML frontmatter, subagent scopes and priority (--agents CLI flag, .claude/agents/, ~/.claude/agents/, plugin agents/), all supported frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, effort, isolation), tool control (allowlist via tools, denylist via disallowedTools, Agent(agent_type) restrictions), MCP server scoping (inline definitions and named references), permission modes (default, acceptEdits, dontAsk, bypassPermissions, plan), preloading skills into subagents, persistent memory (user/project/local scope, MEMORY.md, cross-session learning), hooks in subagent frontmatter (PreToolUse, PostToolUse, Stop) and project-level hooks (SubagentStart, SubagentStop), automatic and explicit delegation (@-mention, natural language, --agent flag), foreground vs background execution (Ctrl+B to background), resuming subagents (SendMessage with agent ID, transcript persistence), auto-compaction, disabling subagents via permissions.deny or --disallowedTools, example subagents (code-reviewer, debugger, data-scientist, db-reader with PreToolUse validation hook), choosing between subagents and main conversation, and common patterns (isolating high-volume operations, parallel research, chaining subagents). Load when discussing subagents, custom agents, agent delegation, Agent tool, /agents command, --agent flag, agent frontmatter fields, agent tool restrictions, agent permission modes, agent memory, agent hooks, spawning subagents, background agents, foreground agents, resuming agents, agent isolation, agent worktrees, agent MCP servers, agent skills preloading, or configuring specialized AI assistants in Claude Code.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code subagents -- specialized AI assistants that handle specific tasks in their own context window.

## Quick Reference

Subagents are isolated AI assistants with custom system prompts, specific tool access, and independent permissions. When Claude encounters a matching task, it delegates to the subagent, which works independently and returns results. Each subagent runs in its own context window, preserving the main conversation's context.

Key benefits: preserve context, enforce tool constraints, reuse configurations across projects, specialize behavior with focused prompts, control costs by routing to faster models.

### Built-in Subagents

| Subagent | Model | Tools | Purpose |
|:---------|:------|:------|:--------|
| **Explore** | Haiku | Read-only | File discovery, code search, codebase exploration. Thoroughness levels: quick, medium, very thorough |
| **Plan** | Inherits | Read-only | Codebase research during plan mode |
| **General-purpose** | Inherits | All tools | Complex research, multi-step operations, code modifications |
| **Bash** | Inherits | Terminal | Running terminal commands in a separate context |
| **statusline-setup** | Sonnet | -- | Configuring the status line (via `/statusline`) |
| **Claude Code Guide** | Haiku | -- | Answering questions about Claude Code features |

### Subagent Scopes and Priority

| Location | Scope | Priority |
|:---------|:------|:---------|
| `--agents` CLI flag (JSON) | Current session only | 1 (highest) |
| `.claude/agents/` | Current project | 2 |
| `~/.claude/agents/` | All your projects | 3 |
| Plugin `agents/` directory | Where plugin is enabled | 4 (lowest) |

When multiple subagents share the same name, the higher-priority location wins.

### Subagent File Format

Markdown files with YAML frontmatter for configuration, body becomes the system prompt:

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze code and provide
specific, actionable feedback on quality and security.
```

Subagents receive only this system prompt (plus basic environment details), not the full Claude Code system prompt.

### Supported Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier (lowercase letters and hyphens) |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools; inherits all if omitted |
| `disallowedTools` | No | Denylist; removed from inherited or specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, a full model ID (e.g. `claude-opus-4-6`), or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before stopping |
| `skills` | No | Skills to inject into context at startup (full content, not just available) |
| `mcpServers` | No | MCP servers: named references or inline definitions |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as background task (default: `false`) |
| `effort` | No | Override session effort level: `low`, `medium`, `high`, `max` (Opus 4.6 only) |
| `isolation` | No | Set to `worktree` for a temporary git worktree (auto-cleaned if no changes) |

Plugin subagents do not support `hooks`, `mcpServers`, or `permissionMode` (ignored when loading from a plugin).

### Tool Control

**Allowlist** -- only these tools are available:
```yaml
tools: Read, Grep, Glob, Bash
```

**Denylist** -- inherit everything except these:
```yaml
disallowedTools: Write, Edit
```

If both are set, `disallowedTools` is applied first, then `tools` is resolved against the remaining pool.

**Restrict spawnable subagents** (only for agents running as main thread via `--agent`):
```yaml
tools: Agent(worker, researcher), Read, Bash
```

Omitting `Agent` entirely prevents spawning any subagents. Subagents cannot spawn other subagents.

### MCP Server Scoping

```yaml
mcpServers:
  # Inline definition: scoped to this subagent only
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  # Reference by name: reuses already-configured server
  - github
```

Inline definitions connect when the subagent starts and disconnect when it finishes. Defining MCP servers inline keeps their tool descriptions out of the main conversation context.

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip permission prompts (use with caution) |
| `plan` | Plan mode (read-only exploration) |

If the parent uses `bypassPermissions`, it takes precedence and cannot be overridden.

### Persistent Memory

| Scope | Location | Use when |
|:------|:---------|:---------|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via VCS |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not checked into VCS |

When enabled: system prompt includes memory instructions, first 200 lines of `MEMORY.md` are auto-loaded, Read/Write/Edit tools are automatically enabled for memory management.

### Hooks in Subagents

**In subagent frontmatter** (scoped to that subagent's lifecycle):

| Event | Matcher | When it fires |
|:------|:--------|:--------------|
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (converted to `SubagentStop` at runtime) |

**In settings.json** (project-level subagent lifecycle hooks):

| Event | Matcher | When it fires |
|:------|:--------|:--------------|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Invoking Subagents

| Method | Description |
|:-------|:------------|
| **Automatic** | Claude delegates based on task and subagent `description` |
| **Natural language** | Name the subagent in your prompt |
| **@-mention** | Type `@` and pick from typeahead; guarantees that subagent runs |
| **`--agent` flag** | Entire session uses that subagent's prompt, tools, and model |
| **`agent` setting** | Set in `.claude/settings.json` for default per project |

@-mention format: `@"code-reviewer (agent)"` for local, `@agent-<plugin-name>:<agent-name>` for plugin subagents.

### Foreground vs Background

| Mode | Behavior |
|:-----|:---------|
| **Foreground** | Blocks main conversation; permission prompts and questions pass through |
| **Background** | Runs concurrently; permissions pre-approved at launch; auto-denies unapproved; clarifying questions fail but subagent continues |

Switch a running task to background: press **Ctrl+B**. Disable background tasks: set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

### Resuming Subagents

Each invocation creates a new instance with fresh context. To continue an existing subagent, ask Claude to resume it. Claude uses the `SendMessage` tool with the agent's ID. Resumed subagents retain their full conversation history.

Subagent transcripts: stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`. Transcripts persist independently of main conversation compaction.

### Disabling Subagents

Via `permissions.deny` in settings:
```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Via CLI flag:
```bash
claude --disallowedTools "Agent(Explore)"
```

### CLI-Defined Subagents

Pass JSON via `--agents` for session-only subagents:
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

Supports all frontmatter fields; use `prompt` for the system prompt.

### When to Use Subagents vs Main Conversation

**Use the main conversation when:**
- Task needs frequent back-and-forth or iterative refinement
- Multiple phases share significant context
- Making a quick, targeted change
- Latency matters (subagents start fresh)

**Use subagents when:**
- Task produces verbose output you do not need in main context
- You want to enforce specific tool restrictions or permissions
- Work is self-contained and can return a summary

Consider Skills for reusable prompts running in main context. Use `/btw` for quick questions with full context but no tools. Use Agent Teams for sustained parallelism or cross-agent communication.

### Auto-Compaction

Subagents support automatic compaction (triggers at ~95% capacity by default). Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (e.g., `50`).

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) -- built-in subagents (Explore, Plan, General-purpose), creating subagents via /agents command or manually, subagent scopes and priority, supported frontmatter fields, tool control (allowlist/denylist, Agent(agent_type) restrictions), MCP server scoping, permission modes, preloading skills, persistent memory (user/project/local scope), hooks in subagent frontmatter and project-level SubagentStart/SubagentStop hooks, automatic and explicit delegation (@-mention, natural language, --agent flag), foreground vs background execution, resuming subagents, auto-compaction, disabling subagents, example subagents (code-reviewer, debugger, data-scientist, db-reader with validation hook), common patterns (isolating high-volume operations, parallel research, chaining subagents)

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
