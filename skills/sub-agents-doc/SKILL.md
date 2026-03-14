---
name: sub-agents-doc
description: Complete documentation for Claude Code subagents — creating and configuring custom subagents that run in isolated context windows with custom system prompts, tool restrictions, model selection, and independent permissions. Covers built-in subagents (Explore, Plan, General-purpose, Bash, Claude Code Guide), creating subagents (/agents command, manual Markdown files, --agents CLI JSON flag), subagent scopes and priority (CLI > project > user > plugin), all frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, isolation), tool control (allowlists, Agent(agent_type) restrictions, disallowedTools denylists), permission modes (default, acceptEdits, dontAsk, bypassPermissions, plan), scoped MCP servers (inline definitions, string references), preloading skills into subagents, persistent memory (user/project/local scopes, MEMORY.md), hooks in subagent frontmatter (PreToolUse, PostToolUse, Stop), project-level hooks for subagent events (SubagentStart, SubagentStop), disabling subagents via permissions.deny, foreground vs background execution, Ctrl+B backgrounding, resuming subagents, auto-compaction, common patterns (isolating high-volume operations, parallel research, chaining subagents), choosing subagents vs main conversation, example subagents (code-reviewer, debugger, data-scientist, db-reader with PreToolUse validation). Load when discussing Claude Code subagents, creating subagents, /agents command, subagent configuration, subagent frontmatter, subagent tools, subagent permissions, subagent models, subagent hooks, subagent MCP servers, subagent skills, subagent memory, Agent tool, Task tool, background tasks, foreground tasks, resuming subagents, subagent scopes, subagent isolation, worktree isolation, or delegating tasks to subagents.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for creating and using custom subagents in Claude Code.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Claude delegates tasks to subagents based on their description field.

Subagents cannot spawn other subagents. For multi-agent parallelism with inter-agent communication, see agent teams instead.

### Built-in Subagents

| Subagent | Model | Tools | Purpose |
|:---------|:------|:------|:--------|
| **Explore** | Haiku | Read-only (no Write/Edit) | File discovery, code search, codebase exploration |
| **Plan** | Inherits | Read-only (no Write/Edit) | Codebase research for plan mode |
| **General-purpose** | Inherits | All tools | Complex research, multi-step operations, code modifications |
| **Bash** | Inherits | Terminal commands | Running commands in separate context |
| **Claude Code Guide** | Haiku | -- | Questions about Claude Code features |

Explore uses thoroughness levels: **quick**, **medium**, or **very thorough**.

### Subagent Scopes and Priority

| Location | Scope | Priority |
|:---------|:------|:---------|
| `--agents` CLI flag | Current session only | 1 (highest) |
| `.claude/agents/` | Current project | 2 |
| `~/.claude/agents/` | All your projects | 3 |
| Plugin `agents/` directory | Where plugin is enabled | 4 (lowest) |

When multiple subagents share the same name, higher-priority location wins.

### Subagent File Format

Markdown files with YAML frontmatter for configuration, followed by the system prompt body:

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze code and provide specific,
actionable feedback on quality, security, and best practices.
```

Subagents receive only their system prompt (plus basic environment details like working directory), not the full Claude Code system prompt.

### Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier, lowercase letters and hyphens |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Tool allowlist; inherits all tools if omitted |
| `disallowedTools` | No | Tools to deny, removed from inherited or specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID (e.g., `claude-opus-4-6`), or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before the subagent stops |
| `skills` | No | Skills to inject into subagent context at startup |
| `mcpServers` | No | MCP servers available to this subagent (inline or by reference) |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as a background task (default: `false`) |
| `isolation` | No | `worktree` to run in a temporary git worktree |

### Tool Control

**Allowlist** -- specify permitted tools in `tools` field (comma-separated in YAML or list):

```yaml
tools: Read, Grep, Glob, Bash
```

**Denylist** -- block specific tools with `disallowedTools`:

```yaml
disallowedTools: Write, Edit
```

**Agent spawning restrictions** -- use `Agent(agent_type)` syntax to control which subagent types an agent running as main thread (`claude --agent`) can spawn:

```yaml
tools: Agent(worker, researcher), Read, Bash
```

`Agent` without parentheses allows spawning any subagent. Omitting `Agent` entirely prevents spawning subagents. This restriction only applies to agents running as main thread; subagents cannot spawn other subagents regardless.

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission checks (use with caution) |
| `plan` | Read-only exploration mode |

If the parent uses `bypassPermissions`, it takes precedence and cannot be overridden.

### MCP Servers in Subagents

Give subagents access to MCP servers via the `mcpServers` field. Entries can be inline definitions or string references to already-configured servers:

```yaml
mcpServers:
  # Inline: scoped to this subagent only
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  # Reference: reuses an already-configured server
  - github
```

Inline servers connect when the subagent starts and disconnect when it finishes. To keep MCP tool descriptions out of the main conversation context, define them inline here rather than in `.mcp.json`.

### Preloading Skills

The `skills` field injects full skill content into the subagent's context at startup. Subagents do not inherit skills from the parent conversation -- list them explicitly:

```yaml
skills:
  - api-conventions
  - error-handling-patterns
```

### Persistent Memory

The `memory` field gives the subagent a persistent directory that survives across conversations:

| Scope | Location | Use when |
|:------|:---------|:---------|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings should apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Knowledge is project-specific, shareable via VCS |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not checked into VCS |

When memory is enabled, the subagent's system prompt includes the first 200 lines of `MEMORY.md` from the memory directory, plus instructions for reading and writing memory files. Read, Write, and Edit tools are automatically enabled.

### Hooks in Subagent Frontmatter

Define hooks directly in frontmatter that run only while the subagent is active:

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (converted to `SubagentStop` at runtime) |

### Project-Level Subagent Hooks

Configure in `settings.json` to respond to subagent lifecycle events in the main session:

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Disabling Subagents

Add to `permissions.deny` in settings or use the `--disallowedTools` CLI flag:

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

### Foreground vs Background

| Mode | Behavior |
|:-----|:---------|
| **Foreground** | Blocks main conversation; permission prompts pass through to user |
| **Background** | Runs concurrently; permissions pre-approved at launch, unapproved operations auto-denied |

Press **Ctrl+B** to background a running task. Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable background functionality.

Background subagents that fail due to missing permissions can be resumed in the foreground.

### Resuming Subagents

Each invocation creates a new instance with fresh context. To continue existing work, ask Claude to resume a previous subagent. Resumed subagents retain full conversation history.

Transcripts are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`. They persist independently of main conversation compaction and are cleaned up based on `cleanupPeriodDays` (default: 30 days).

### Auto-Compaction

Subagents support automatic compaction at approximately 95% capacity. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (e.g., `50` for earlier compaction).

### CLI-Defined Subagents

Pass subagents as JSON with `--agents` for session-only use:

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

Accepts the same fields as file-based frontmatter. Use `prompt` for the system prompt (equivalent to the markdown body in file-based subagents).

### Common Patterns

| Pattern | Description |
|:--------|:------------|
| **Isolate high-volume operations** | Delegate tests, log processing, doc fetching to subagents to keep main context clean |
| **Parallel research** | Spawn multiple subagents for independent investigations simultaneously |
| **Chain subagents** | Use subagents in sequence, passing results from one to the next |

### When to Use Subagents vs Main Conversation

**Use main conversation** when: frequent back-and-forth needed, multiple phases share significant context, making quick targeted changes, or latency matters.

**Use subagents** when: task produces verbose output you do not need in main context, you want specific tool restrictions or permissions, work is self-contained and can return a summary.

**Use skills** instead when you want reusable prompts that run in the main conversation context. Use **/btw** for quick questions that need full context but no tools.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) -- built-in subagents (Explore, Plan, General-purpose), quickstart with /agents command, subagent scopes and priority (CLI/project/user/plugin), writing subagent files (frontmatter fields, system prompt body), model selection, tool control (allowlists, disallowedTools, Agent(agent_type) restrictions), MCP server scoping (inline and reference), permission modes, preloading skills, persistent memory (user/project/local scopes), hooks in frontmatter (PreToolUse, PostToolUse, Stop), project-level hooks (SubagentStart, SubagentStop), disabling subagents, automatic delegation, foreground vs background execution, resuming subagents, auto-compaction, common patterns (parallel research, chaining, isolating operations), choosing subagents vs main conversation, example subagents (code-reviewer, debugger, data-scientist, db-reader with PreToolUse hook validation)

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
