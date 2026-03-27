---
name: sub-agents-doc
description: Complete documentation for Claude Code subagents (custom AI subagents) -- creating, configuring, and managing specialized subagents that run in isolated context windows with custom system prompts and tool access. Covers built-in subagents (Explore with Haiku for read-only codebase search, Plan for plan-mode research, General-purpose for complex multi-step tasks, Bash/statusline-setup/Claude Code Guide helpers), subagent file format (YAML frontmatter + Markdown system prompt), subagent scopes and priority (--agents CLI flag > .claude/agents/ project > ~/.claude/agents/ user > plugin agents/ directory), all supported frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, effort, isolation, initialPrompt), model resolution order (CLAUDE_CODE_SUBAGENT_MODEL env var > per-invocation > frontmatter > main conversation), tool control (allowlist with tools, denylist with disallowedTools, Agent(type) for restricting spawnable subagents), scoped MCP servers (inline definitions and string references), permission modes (default, acceptEdits, dontAsk, bypassPermissions, plan), preloading skills into subagents, persistent memory (user/project/local scopes with MEMORY.md), conditional rules with PreToolUse hooks, disabling subagents via permissions.deny or --disallowedTools, subagent-scoped hooks (PreToolUse, PostToolUse, Stop) and project-level hooks (SubagentStart, SubagentStop), automatic and explicit delegation (@-mention, natural language, --agent flag, agent setting), foreground vs background execution (Ctrl+B, CLAUDE_CODE_DISABLE_BACKGROUND_TASKS), common patterns (isolating high-volume operations, parallel research, chaining subagents), resuming subagents (SendMessage with agent ID), subagent transcript persistence and auto-compaction (CLAUDE_AUTOCOMPACT_PCT_OVERRIDE), example subagents (code-reviewer, debugger, data-scientist, db-reader with hook validation), and choosing between subagents vs main conversation vs skills vs /btw. Load when discussing Claude Code subagents, custom agents, agent delegation, Agent tool, Task tool, subagent configuration, agent frontmatter, --agents flag, --agent flag, .claude/agents/, ~/.claude/agents/, agent memory, agent-memory directory, subagent tools, subagent permissions, subagent hooks, SubagentStart, SubagentStop, subagent MCP servers, background tasks, foreground subagent, CLAUDE_CODE_SUBAGENT_MODEL, Agent(type), disallowedTools for agents, subagent isolation, worktree isolation, subagent skills, subagent model selection, subagent context management, resume subagent, SendMessage, agent transcripts, auto-compaction, /agents command, agent teams vs subagents, or any subagent-related topic for Claude Code.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for creating and using custom subagents in Claude Code -- specialized AI assistants that run in isolated context windows with custom system prompts, tool access, and independent permissions.

## Quick Reference

### Built-in Subagents

| Subagent | Model | Tools | Purpose |
|:---------|:------|:------|:--------|
| **Explore** | Haiku | Read-only (no Write/Edit) | File discovery, code search, codebase exploration; thoroughness levels: quick, medium, very thorough |
| **Plan** | Inherits | Read-only (no Write/Edit) | Codebase research for plan mode |
| **General-purpose** | Inherits | All tools | Complex research, multi-step operations, code modifications |
| **Bash** | Inherits | -- | Running terminal commands in a separate context |
| **statusline-setup** | Sonnet | -- | Configuring status line via `/statusline` |
| **Claude Code Guide** | Haiku | -- | Answering questions about Claude Code features |

### Subagent File Format

YAML frontmatter + Markdown body (system prompt):

```
---
name: my-agent
description: When Claude should delegate to this agent
tools: Read, Grep, Glob, Bash
model: sonnet
---

System prompt content goes here.
```

Subagents receive only this system prompt plus basic environment details -- not the full Claude Code system prompt.

### Subagent Scopes (Priority Order)

| Location | Scope | Priority |
|:---------|:------|:---------|
| `--agents` CLI flag (JSON) | Current session only | 1 (highest) |
| `.claude/agents/` | Current project | 2 |
| `~/.claude/agents/` | All your projects | 3 |
| Plugin `agents/` directory | Where plugin is enabled | 4 (lowest) |

When multiple subagents share the same name, the higher-priority location wins.

### Supported Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier (lowercase letters and hyphens) |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools; inherits all if omitted |
| `disallowedTools` | No | Denylist of tools removed from inherited/specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before stopping |
| `skills` | No | Skills to inject into context at startup (full content, not just availability) |
| `mcpServers` | No | MCP servers: inline definitions or string references to configured servers |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as background task (default: `false`) |
| `effort` | No | Override session effort: `low`, `medium`, `high`, `max` (Opus 4.6 only) |
| `isolation` | No | Set to `worktree` for isolated git worktree copy |
| `initialPrompt` | No | Auto-submitted first user turn when running as main session agent via `--agent` |

Plugin subagents do not support `hooks`, `mcpServers`, or `permissionMode` (ignored when loading from a plugin).

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable (if set)
2. Per-invocation `model` parameter (from Claude at delegation time)
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Tool Control

**Allowlist** -- only these tools available:
```yaml
tools: Read, Grep, Glob, Bash
```

**Denylist** -- inherit everything except these:
```yaml
disallowedTools: Write, Edit
```

If both set: `disallowedTools` applied first, then `tools` resolved against remaining pool.

**Restrict spawnable subagents** (for agents running as main thread via `--agent`):
```yaml
tools: Agent(worker, researcher), Read, Bash
```

Omitting `Agent` entirely prevents spawning any subagents. Subagents cannot spawn other subagents regardless of this setting.

### Scoped MCP Servers

```yaml
mcpServers:
  # Inline definition: connected when subagent starts, disconnected when it finishes
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  # Reference by name: reuses already-configured server
  - github
```

Inline definitions keep MCP tools out of the main conversation context entirely.

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip permission prompts (use with caution) |
| `plan` | Plan mode (read-only exploration) |

If parent uses `bypassPermissions`, it takes precedence and cannot be overridden. If parent uses auto mode, `permissionMode` in frontmatter is ignored.

### Persistent Memory

| Scope | Location | Use when |
|:------|:---------|:---------|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via VCS |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not in VCS |

When enabled: system prompt includes memory instructions, first 200 lines / 25KB of `MEMORY.md` is injected, Read/Write/Edit tools are auto-enabled.

### Hooks for Subagents

**In subagent frontmatter** (runs only while that subagent is active):

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (converted to `SubagentStop` at runtime) |

**In settings.json** (project-level, runs in main session):

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Invoking Subagents

| Method | Behavior |
|:-------|:---------|
| Natural language ("use the code-reviewer subagent") | Claude decides whether to delegate |
| @-mention (`@"code-reviewer (agent)"`) | Guarantees that subagent runs for one task |
| `--agent <name>` CLI flag | Entire session uses subagent's prompt, tools, model |
| `agent` setting in `.claude/settings.json` | Default agent for all sessions in project |

For plugin subagents: `@agent-<plugin-name>:<agent-name>` or `claude --agent <plugin-name>:<agent-name>`.

### Foreground vs Background Execution

| Mode | Behavior |
|:-----|:---------|
| **Foreground** | Blocks main conversation; permission prompts and questions passed through |
| **Background** | Runs concurrently; permissions pre-approved at launch; auto-denies unapproved tools; clarifying questions fail |

Background a running task with **Ctrl+B**. Disable all background tasks with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

### Resuming Subagents

Claude uses `SendMessage` with the agent's ID to resume a completed subagent with its full conversation history. Subagent transcripts stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`.

Transcripts persist independently of main conversation compaction. Cleanup follows `cleanupPeriodDays` setting (default: 30 days).

### Auto-Compaction

Subagents support automatic compaction at ~95% capacity by default. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (e.g., `50` for 50%).

### Disabling Subagents

Via settings:
```json
{ "permissions": { "deny": ["Agent(Explore)", "Agent(my-custom-agent)"] } }
```

Via CLI:
```
claude --disallowedTools "Agent(Explore)"
```

### When to Use Subagents vs Alternatives

| Use case | Best choice |
|:---------|:------------|
| Task produces verbose output you don't need in main context | Subagent |
| Need specific tool restrictions or permissions | Subagent |
| Self-contained work that can return a summary | Subagent |
| Frequent back-and-forth or iterative refinement | Main conversation |
| Multiple phases sharing significant context | Main conversation |
| Quick, targeted change where latency matters | Main conversation |
| Reusable prompts/workflows in main conversation context | Skills |
| Quick question about something already in context, no tools needed | `/btw` |
| Multiple agents working in parallel with cross-communication | Agent teams |

Subagents cannot spawn other subagents. For nested delegation, use skills or chain subagents from the main conversation.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) -- built-in subagents (Explore, Plan, General-purpose, Bash, statusline-setup, Claude Code Guide), quickstart with /agents command, subagent scopes and priority (CLI flag, project, user, plugin), file format with YAML frontmatter and Markdown system prompt, all supported frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, effort, isolation, initialPrompt), model resolution order, tool control (allowlist, denylist, Agent(type) for restricting spawnable subagents), scoped MCP servers (inline and reference), permission modes and inheritance, preloading skills, persistent memory (user/project/local scopes with MEMORY.md), conditional rules with PreToolUse hooks, disabling subagents via permissions.deny, hooks in subagent frontmatter (PreToolUse, PostToolUse, Stop) and project-level hooks (SubagentStart, SubagentStop), automatic and explicit delegation (natural language, @-mention, --agent, agent setting), foreground vs background execution, common patterns (isolating high-volume operations, parallel research, chaining), choosing between subagents and main conversation, resuming subagents with SendMessage, transcript persistence and auto-compaction, example subagents (code-reviewer, debugger, data-scientist, db-reader with hook validation)

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
