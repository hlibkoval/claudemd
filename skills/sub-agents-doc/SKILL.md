---
name: sub-agents-doc
description: Complete documentation for Claude Code subagents -- specialized AI assistants that handle specific tasks in their own context window with custom system prompts, tool restrictions, and independent permissions. Covers built-in subagents (Explore, Plan, general-purpose, Bash, statusline-setup, Claude Code Guide), creating subagents via /agents command or manually as markdown files, subagent scopes and priority (CLI --agents, project .claude/agents/, user ~/.claude/agents/, plugin agents/), full frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, isolation), model selection (sonnet/opus/haiku/inherit/full ID), tool control and Agent(type) spawn restrictions, scoping MCP servers to subagents, permission modes (default, acceptEdits, dontAsk, bypassPermissions, plan), preloading skills, persistent memory (user/project/local scopes), hooks in frontmatter (PreToolUse, PostToolUse, Stop) and project-level hooks (SubagentStart, SubagentStop), disabling subagents via permissions.deny, foreground vs background execution, resuming subagents, auto-compaction, common patterns (isolating high-volume operations, parallel research, chaining), and example subagents (code-reviewer, debugger, data-scientist, db-reader with PreToolUse validation). Load when discussing subagents, sub-agents, Agent tool, /agents command, delegating tasks, subagent configuration, subagent tools, subagent permissions, subagent hooks, subagent memory, background subagents, foreground subagents, resuming subagents, Explore agent, Plan agent, general-purpose agent, or Agent(type) restrictions.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for creating and using specialized subagents in Claude Code.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Claude delegates tasks to subagents based on their `description` field. Subagents cannot spawn other subagents.

### Built-in Subagents

| Subagent | Model | Tools | Purpose |
|:---------|:------|:------|:--------|
| **Explore** | Haiku | Read-only (no Write/Edit) | File discovery, code search, codebase exploration |
| **Plan** | Inherits | Read-only (no Write/Edit) | Codebase research during plan mode |
| **general-purpose** | Inherits | All tools | Complex research, multi-step operations, code modifications |
| **Bash** | Inherits | -- | Running terminal commands in a separate context |
| **statusline-setup** | Sonnet | -- | Configuring status line via `/statusline` |
| **Claude Code Guide** | Haiku | -- | Answering questions about Claude Code features |

Explore uses three thoroughness levels: **quick** (targeted lookups), **medium** (balanced), **very thorough** (comprehensive).

### Subagent Scopes and Priority

| Location | Scope | Priority |
|:---------|:------|:---------|
| `--agents` CLI flag (JSON) | Current session only | 1 (highest) |
| `.claude/agents/` | Current project | 2 |
| `~/.claude/agents/` | All your projects | 3 |
| Plugin `agents/` directory | Where plugin is enabled | 4 (lowest) |

When multiple subagents share the same name, the higher-priority location wins.

**Plugin subagent restrictions**: `hooks`, `mcpServers`, and `permissionMode` fields are ignored for security. Copy to `.claude/agents/` or `~/.claude/agents/` if needed.

### Subagent File Format

Markdown files with YAML frontmatter for configuration, body becomes the system prompt:

```yaml
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---
```

Subagents loaded at session start. Manually added files require session restart or `/agents` to reload.

### Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier (lowercase letters and hyphens) |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowed tools (inherits all if omitted) |
| `disallowedTools` | No | Tools to deny from inherited/specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default: `inherit`) |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before stopping |
| `skills` | No | Skills to inject into subagent context at startup |
| `mcpServers` | No | MCP servers: inline definitions or string references to configured servers |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as background task (default: `false`) |
| `isolation` | No | `worktree` to run in a temporary git worktree (auto-cleaned if no changes) |

### Model Selection

| Value | Behavior |
|:------|:---------|
| `sonnet`, `opus`, `haiku` | Model alias |
| Full model ID (e.g., `claude-opus-4-6`) | Same values as `--model` flag |
| `inherit` | Same model as main conversation |
| Omitted | Defaults to `inherit` |

### Tool Control

Use `tools` (allowlist) and `disallowedTools` (denylist) to restrict capabilities. Available tools are from the Claude Code internal tools reference, including MCP tools.

**Restrict which subagents can be spawned** (only for agents running as main thread with `claude --agent`):

| Syntax | Effect |
|:-------|:-------|
| `Agent(worker, researcher)` | Only allow spawning `worker` and `researcher` |
| `Agent` (no parentheses) | Allow spawning any subagent |
| `Agent` omitted from tools | Cannot spawn any subagents |

Subagents themselves cannot spawn other subagents, so `Agent(type)` has no effect in subagent definitions.

### Scoping MCP Servers

The `mcpServers` field accepts inline definitions (scoped to subagent lifecycle) or string references (sharing parent session connection):

```yaml
mcpServers:
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  - github
```

Inline servers connect when the subagent starts and disconnect when it finishes. Define inline to keep tool descriptions out of the main conversation context.

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission checks |
| `plan` | Plan mode (read-only exploration) |

If the parent uses `bypassPermissions`, it takes precedence and cannot be overridden.

### Preloading Skills

The `skills` field injects full skill content into the subagent's context at startup. Subagents do not inherit skills from the parent conversation; list them explicitly.

### Persistent Memory

| Scope | Location | Use when |
|:------|:---------|:---------|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings should apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Knowledge is project-specific and shareable via VCS |
| `local` | `.claude/agent-memory-local/<name>/` | Knowledge is project-specific but private |

When enabled: system prompt includes memory instructions, first 200 lines of MEMORY.md injected, Read/Write/Edit tools auto-enabled.

### Hooks

**In subagent frontmatter** (run only while that subagent is active):

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (converted to `SubagentStop` at runtime) |

**In settings.json** (project-level, main session):

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Disabling Subagents

Add to `permissions.deny` in settings or use `--disallowedTools`:

```json
{ "permissions": { "deny": ["Agent(Explore)", "Agent(my-custom-agent)"] } }
```

```bash
claude --disallowedTools "Agent(Explore)"
```

### Foreground vs Background Execution

| Mode | Behavior | Permissions |
|:-----|:---------|:------------|
| **Foreground** | Blocks main conversation; permission prompts passed through | Interactive |
| **Background** | Runs concurrently; permissions pre-approved before launch | Auto-deny anything not pre-approved |

Press **Ctrl+B** to background a running task. Disable background tasks with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

If a background subagent fails due to missing permissions, resume it in the foreground.

### Resuming Subagents

Each invocation creates a fresh instance. To continue existing work, ask Claude to resume:

```
Continue that code review and now analyze the authorization logic
```

Resumed subagents retain full conversation history. Transcripts stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`. Transcripts survive main conversation compaction and persist within their session.

### Auto-Compaction

Triggers at approximately 95% capacity by default. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (e.g., `50`).

### When to Use Subagents vs Main Conversation

**Use main conversation**: frequent back-and-forth, shared context across phases, quick targeted changes, latency-sensitive work.

**Use subagents**: verbose output you want isolated, enforcing tool/permission restrictions, self-contained work returning a summary.

**Alternatives**: Skills for reusable prompts in main context. `/btw` for quick questions with full context but no tools. Agent teams for sustained parallelism across independent sessions.

### CLI --agents Flag

Pass subagent definitions as JSON for session-only agents:

```bash
claude --agents '{ "code-reviewer": { "description": "...", "prompt": "...", "tools": ["Read", "Grep"], "model": "sonnet" } }'
```

Accepts the same fields as file frontmatter. Use `prompt` for the system prompt (equivalent to markdown body in file-based subagents).

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) -- built-in subagents (Explore, Plan, general-purpose, Bash, statusline-setup, Claude Code Guide), quickstart with /agents command, subagent scopes and priority (CLI flag, project, user, plugin), writing subagent markdown files, frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, isolation), model selection, tool control and Agent(type) spawn restrictions, scoping MCP servers, permission modes, preloading skills, persistent memory (user/project/local), conditional rules with PreToolUse hooks, disabling subagents, hooks in frontmatter and project-level hooks (SubagentStart, SubagentStop), automatic delegation, foreground and background execution, resuming subagents, auto-compaction, common patterns (isolating high-volume operations, parallel research, chaining subagents), choosing subagents vs main conversation, example subagents (code-reviewer, debugger, data-scientist, db-reader with query validation)

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
