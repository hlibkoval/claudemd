---
name: sub-agents-doc
description: Complete documentation for Claude Code subagents — specialized AI assistants that handle specific tasks in isolated context windows. Covers built-in subagents (Explore, Plan, general-purpose, Bash, statusline-setup, Claude Code Guide), creating custom subagents (/agents command and manual file creation), subagent scopes (CLI --agents flag, project .claude/agents/, user ~/.claude/agents/, plugin agents/), frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, isolation), model selection (sonnet/opus/haiku/inherit/full ID), tool control (allowlist via tools, denylist via disallowedTools, Agent(type) restrictions), MCP server scoping (inline definitions, named references), permission modes (default, acceptEdits, dontAsk, bypassPermissions, plan), skill preloading, persistent memory (user/project/local scopes), conditional rules with PreToolUse hooks, disabling subagents via permissions.deny, subagent hooks (frontmatter hooks, SubagentStart/SubagentStop events), automatic delegation, explicit invocation (natural language, @-mention, --agent flag, agent setting), foreground vs background execution (Ctrl+B, CLAUDE_CODE_DISABLE_BACKGROUND_TASKS), common patterns (isolating high-volume operations, parallel research, chaining subagents), choosing between subagents and main conversation, resuming subagents (SendMessage, agent IDs, transcript persistence), auto-compaction (CLAUDE_AUTOCOMPACT_PCT_OVERRIDE), and example subagents (code-reviewer, debugger, data-scientist, db-reader with hook validation). Load when discussing subagents, custom agents, agent delegation, Agent tool, Task tool, --agent flag, /agents command, agent scopes, agent tools, agent permissions, agent hooks, SubagentStart, SubagentStop, agent memory, background tasks, agent isolation, worktree isolation, agent MCP servers, agent skills preloading, Explore agent, Plan agent, general-purpose agent, or creating specialized AI assistants in Claude Code.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Claude delegates tasks to subagents based on their description field. Subagents cannot spawn other subagents.

For multiple agents working in parallel and communicating with each other, use agent teams instead. Subagents work within a single session; agent teams coordinate across separate sessions.

### Built-in Subagents

| Subagent | Model | Tools | Purpose |
|:---------|:------|:------|:--------|
| **Explore** | Haiku | Read-only (no Write/Edit) | File discovery, code search, codebase exploration |
| **Plan** | Inherits | Read-only (no Write/Edit) | Codebase research for planning (used in plan mode) |
| **general-purpose** | Inherits | All tools | Complex research, multi-step operations, code modifications |
| **Bash** | Inherits | Terminal commands | Running terminal commands in a separate context |
| **statusline-setup** | Sonnet | -- | Configuring status line via `/statusline` |
| **Claude Code Guide** | Haiku | -- | Answering questions about Claude Code features |

Explore uses thoroughness levels: **quick** (targeted lookups), **medium** (balanced), **very thorough** (comprehensive analysis).

### Subagent Scopes (Priority Order)

| Location | Scope | Priority | How to create |
|:---------|:------|:---------|:--------------|
| `--agents` CLI flag | Current session only | 1 (highest) | Pass JSON when launching Claude Code |
| `.claude/agents/` | Current project | 2 | Interactive (`/agents`) or manual file |
| `~/.claude/agents/` | All your projects | 3 | Interactive (`/agents`) or manual file |
| Plugin `agents/` directory | Where plugin is enabled | 4 (lowest) | Installed with plugins |

When multiple subagents share the same name, the higher-priority location wins.

Plugin subagents do not support `hooks`, `mcpServers`, or `permissionMode` fields (ignored when loading from a plugin).

### Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier (lowercase letters and hyphens) |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Tools the subagent can use (inherits all if omitted) |
| `disallowedTools` | No | Tools to deny, removed from inherited or specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID (e.g., `claude-opus-4-6`), or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before the subagent stops |
| `skills` | No | Skills to inject into context at startup (full content, not just available for invocation) |
| `mcpServers` | No | MCP servers: named references to configured servers or inline definitions |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as a background task (default: `false`) |
| `isolation` | No | `worktree` to run in a temporary git worktree (auto-cleaned if no changes) |

### Tool Control

**Allowlist** (`tools`): specify exactly which tools the subagent can use.

**Denylist** (`disallowedTools`): remove specific tools from the inherited or specified set.

**Agent spawning restrictions** (`Agent(type)` in tools): when a subagent runs as the main thread via `claude --agent`, restrict which subagent types it can spawn. `Agent(worker, researcher)` allows only those two types. `Agent` without parentheses allows all. Omitting `Agent` entirely blocks all spawning. Only applies to `--agent` mode; subagents cannot spawn other subagents.

**Disabling subagents**: add `Agent(subagent-name)` to `permissions.deny` in settings or use `--disallowedTools "Agent(Explore)"`.

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip permission prompts (writes to .git, .claude, .vscode, .idea still prompt) |
| `plan` | Plan mode (read-only exploration) |

If the parent uses `bypassPermissions`, it takes precedence and cannot be overridden.

### MCP Server Scoping

Subagents can access MCP servers via the `mcpServers` field:

- **Inline definition**: full server config keyed by name, scoped to the subagent only (connected on start, disconnected on finish)
- **String reference**: reuses an already-configured server from the parent session

Inline definitions keep MCP tool descriptions out of the main conversation context.

### Persistent Memory

| Scope | Location | Use when |
|:------|:---------|:---------|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings should apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Knowledge is project-specific and shareable via VCS |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific but should not be checked in |

When enabled: the subagent's prompt includes memory directory instructions, the first 200 lines of `MEMORY.md` are injected, and Read/Write/Edit tools are automatically enabled.

### Subagent Hooks

**In frontmatter** (scoped to the subagent's execution):

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (converted to `SubagentStop` at runtime) |

**In settings.json** (main session lifecycle events):

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Invocation Methods

| Method | Behavior |
|:-------|:---------|
| **Natural language** | Name the subagent in your prompt; Claude decides whether to delegate |
| **@-mention** | `@"code-reviewer (agent)"` guarantees that subagent runs for one task |
| **Session-wide** | `claude --agent code-reviewer` or `"agent": "code-reviewer"` in settings; entire session uses the subagent's prompt, tools, and model |

Plugin subagents use scoped names: `@agent-<plugin-name>:<agent-name>` or `claude --agent <plugin-name>:<agent-name>`.

### Foreground vs Background

| Mode | Behavior |
|:-----|:---------|
| **Foreground** | Blocks main conversation; permission prompts and clarifying questions pass through |
| **Background** | Runs concurrently; permissions pre-approved before launch; auto-denies unapproved tools; clarifying questions fail but subagent continues |

Press **Ctrl+B** to background a running task. Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable background tasks entirely.

### Resuming Subagents

Each invocation creates a new instance with fresh context. To continue an existing subagent's work, ask Claude to resume it. Claude uses `SendMessage` with the agent's ID. Resumed subagents retain full conversation history.

Transcript files are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`. Transcripts persist independently of main conversation compaction and are cleaned up based on `cleanupPeriodDays` (default: 30 days).

### Auto-compaction

Subagents support automatic compaction at approximately 95% capacity. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (e.g., `50` for 50%).

### When to Use Subagents vs Main Conversation

**Use the main conversation** for: frequent back-and-forth, shared context across phases, quick targeted changes, latency-sensitive work.

**Use subagents** for: verbose output isolation, enforcing tool restrictions, self-contained tasks returning summaries.

**Use Skills** instead when you want reusable prompts running in the main conversation context. Use `/btw` for quick questions with full context but no tool access.

### CLI-Defined Subagents

Pass JSON via `--agents` for session-only subagents:

```bash
claude --agents '{"name": {"description": "...", "prompt": "...", "tools": [...], "model": "sonnet"}}'
```

Accepts the same fields as file-based frontmatter: `description`, `prompt`, `tools`, `disallowedTools`, `model`, `permissionMode`, `mcpServers`, `hooks`, `maxTurns`, `skills`, and `memory`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) -- built-in subagents (Explore, Plan, general-purpose, Bash, statusline-setup, Claude Code Guide), quickstart with /agents command, subagent scopes (CLI flag, project, user, plugin with priority), writing subagent files, frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, isolation), model selection, tool control (allowlist, denylist, Agent(type) spawning restrictions), MCP server scoping (inline and reference), permission modes, skill preloading, persistent memory (user/project/local), conditional rules with PreToolUse hooks, disabling subagents via permissions.deny, hooks in frontmatter (PreToolUse, PostToolUse, Stop) and settings.json (SubagentStart, SubagentStop), automatic delegation, explicit invocation (natural language, @-mention, --agent flag, agent setting), foreground vs background execution, common patterns (isolating operations, parallel research, chaining), choosing subagents vs main conversation, resuming subagents (SendMessage, transcript persistence), auto-compaction, example subagents (code-reviewer, debugger, data-scientist, db-reader with hook validation)

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
