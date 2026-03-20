---
name: sub-agents-doc
description: Complete documentation for Claude Code subagents -- specialized AI assistants that handle specific tasks in isolated context windows. Covers built-in subagents (Explore, Plan, general-purpose, Bash, statusline-setup, Claude Code Guide), creating custom subagents via /agents command or markdown files, subagent scopes and priority (CLI --agents, project .claude/agents/, user ~/.claude/agents/, plugin agents/), all supported frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, effort, isolation), tool control and Agent(agent_type) restrictions, MCP server scoping, permission modes (default, acceptEdits, dontAsk, bypassPermissions, plan), persistent memory (user, project, local scopes), subagent hooks (PreToolUse, PostToolUse, Stop in frontmatter; SubagentStart, SubagentStop in settings.json), automatic and explicit delegation (@-mention, --agent flag, agent setting), foreground vs background subagents (Ctrl+B), resuming subagents (SendMessage with agent ID), auto-compaction, disabling subagents via permissions.deny, example subagents (code-reviewer, debugger, data-scientist, db-reader with hook validation), and choosing between subagents, main conversation, skills, and /btw. Load when discussing subagents, Agent tool, /agents command, claude --agent, delegating tasks, subagent configuration, subagent tools, subagent permissions, subagent hooks, SubagentStart, SubagentStop, agent memory, background tasks, Explore agent, Plan agent, general-purpose agent, or Agent(agent_type) restrictions.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for creating and using subagents in Claude Code.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Claude delegates tasks to subagents based on their `description` field.

Subagents work within a single session. For multiple agents working in parallel with inter-agent communication, use agent teams instead.

### Built-in Subagents

| Subagent | Model | Tools | Purpose |
|:---------|:------|:------|:--------|
| **Explore** | Haiku | Read-only | File discovery, code search, codebase exploration |
| **Plan** | Inherits | Read-only | Codebase research during plan mode |
| **General-purpose** | Inherits | All | Complex research, multi-step operations, code modifications |
| **Bash** | Inherits | -- | Running terminal commands in a separate context |
| **statusline-setup** | Sonnet | -- | Configuring status line via `/statusline` |
| **Claude Code Guide** | Haiku | -- | Answering questions about Claude Code features |

Explore supports thoroughness levels: **quick**, **medium**, or **very thorough**.

### Subagent Scope and Priority

| Location | Scope | Priority |
|:---------|:------|:---------|
| `--agents` CLI flag (JSON) | Current session only | 1 (highest) |
| `.claude/agents/` | Current project | 2 |
| `~/.claude/agents/` | All your projects | 3 |
| Plugin `agents/` directory | Where plugin is enabled | 4 (lowest) |

When multiple subagents share the same name, the higher-priority location wins.

### Subagent File Format

Markdown files with YAML frontmatter. The body becomes the system prompt.

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```

### Supported Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier (lowercase letters and hyphens) |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools; inherits all if omitted |
| `disallowedTools` | No | Tools to deny (removed from inherited/specified list) |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before the subagent stops |
| `skills` | No | Skills to inject into the subagent's context at startup |
| `mcpServers` | No | MCP servers scoped to this subagent (inline definition or string reference) |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as a background task (default: `false`) |
| `effort` | No | Effort level override: `low`, `medium`, `high`, `max` (Opus 4.6 only) |
| `isolation` | No | Set to `worktree` for an isolated git worktree copy |

Plugin subagents do not support `hooks`, `mcpServers`, or `permissionMode` (fields are ignored).

### Model Options

| Value | Behavior |
|:------|:---------|
| `sonnet` / `opus` / `haiku` | Use the named model alias |
| Full model ID (e.g., `claude-opus-4-6`) | Specific model version |
| `inherit` | Same model as main conversation (default) |

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip permission prompts (use with caution) |
| `plan` | Plan mode (read-only exploration) |

If the parent uses `bypassPermissions`, it takes precedence and cannot be overridden.

### Tool Control

**Allowlist/denylist:**

```yaml
tools: Read, Grep, Glob, Bash
disallowedTools: Write, Edit
```

**Restrict which subagents an agent can spawn** (when running as main thread with `claude --agent`):

```yaml
tools: Agent(worker, researcher), Read, Bash
```

Only named subagent types can be spawned. Omitting `Agent` entirely prevents all subagent spawning. This restriction only applies to agents running as the main thread; subagents cannot spawn other subagents regardless.

**Disable specific subagents** via settings:

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or via CLI: `claude --disallowedTools "Agent(Explore)"`

### MCP Server Scoping

Inline definitions connect when the subagent starts and disconnect when it finishes. String references share the parent session's connection.

```yaml
mcpServers:
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  - github
```

### Persistent Memory

| Scope | Location | Use when |
|:------|:---------|:---------|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via VCS |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not checked in |

When enabled, the subagent's system prompt includes the first 200 lines of `MEMORY.md` from its memory directory. Read, Write, and Edit tools are automatically enabled.

### Hooks

**In subagent frontmatter** (run while that subagent is active):

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (converted to `SubagentStop` at runtime) |

**In settings.json** (project-level subagent lifecycle events):

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Invoking Subagents

| Method | Description |
|:-------|:------------|
| Automatic delegation | Claude decides based on task and subagent descriptions |
| Natural language | Name the subagent in your prompt |
| @-mention | `@"code-reviewer (agent)"` guarantees that subagent runs |
| `--agent` flag | Whole session uses that subagent's config: `claude --agent code-reviewer` |
| `agent` setting | Default agent for every session in a project |

Plugin subagents use scoped names: `@agent-<plugin-name>:<agent-name>` or `claude --agent <plugin-name>:<agent-name>`.

### Foreground vs Background

| Mode | Behavior |
|:-----|:---------|
| **Foreground** | Blocks main conversation; permission prompts pass through |
| **Background** | Runs concurrently; permissions pre-approved at launch; auto-denies unapproved |

Press **Ctrl+B** to background a running task. Disable background tasks with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

### Resuming Subagents

Each invocation creates a new instance, but you can resume a previous one. Claude uses `SendMessage` with the agent's ID. Resumed subagents retain their full conversation history. If a stopped subagent receives a `SendMessage`, it auto-resumes in the background.

Transcripts are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`. Subagent transcripts are unaffected by main conversation compaction and persist within their session. Automatic cleanup based on `cleanupPeriodDays` (default: 30 days).

### Auto-Compaction

Subagents compact at approximately 95% capacity by default. Set `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` to a lower percentage for earlier compaction.

### When to Use Subagents vs Alternatives

| Use case | Recommendation |
|:---------|:---------------|
| Verbose output you want isolated | Subagent |
| Enforce specific tool restrictions | Subagent |
| Self-contained task returning a summary | Subagent |
| Frequent back-and-forth or iterative refinement | Main conversation |
| Quick targeted change | Main conversation |
| Reusable prompts in main conversation context | Skills |
| Quick question using existing context (no tools) | `/btw` |
| Multiple agents with inter-agent communication | Agent teams |

Subagents cannot spawn other subagents. For nested delegation, chain subagents from the main conversation or use skills.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) -- built-in subagents (Explore, Plan, general-purpose), quickstart with /agents command, subagent scopes and priority (CLI, project, user, plugin), file format and supported frontmatter fields, model selection, tool control (allowlist, denylist, Agent(agent_type) restrictions), MCP server scoping, permission modes, preloading skills, persistent memory (user/project/local scopes), conditional rules with PreToolUse hooks, disabling subagents via permissions.deny, hooks in frontmatter and settings.json (SubagentStart, SubagentStop), automatic and explicit delegation (@-mention, --agent flag, agent setting), foreground vs background execution, common patterns (isolate high-volume operations, parallel research, chaining), choosing between subagents and alternatives, resuming subagents, auto-compaction, example subagents (code-reviewer, debugger, data-scientist, db-reader with hook validation)

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
