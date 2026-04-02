---
name: sub-agents-doc
description: Complete documentation for Claude Code subagents -- creating, configuring, and managing specialized AI subagents that run in their own context window. Covers built-in subagents (Explore, Plan, general-purpose), subagent file format (YAML frontmatter + Markdown body), all frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, effort, isolation, color, initialPrompt), scoping (managed settings, --agents CLI flag, .claude/agents/, ~/.claude/agents/, plugin agents/), priority hierarchy, model resolution order (CLAUDE_CODE_SUBAGENT_MODEL > per-invocation > frontmatter > main conversation), tool control (allowlist via tools, denylist via disallowedTools, Agent(type) spawning restrictions), permission modes (default, acceptEdits, auto, dontAsk, bypassPermissions, plan), persistent memory (user, project, local scopes), hooks in frontmatter (PreToolUse, PostToolUse, Stop), project-level hooks (SubagentStart, SubagentStop), foreground vs background execution, explicit invocation (natural language, @-mention, --agent flag, agent setting), resuming subagents (SendMessage with agent ID), auto-compaction, transcript storage, the /agents interactive command, and example subagents (code-reviewer, debugger, data-scientist, db-reader with validation hooks). Load when discussing subagents, custom agents, Agent tool, /agents command, agent delegation, agent memory, agent isolation, agent hooks, agent teams delegation, --agent flag, agent frontmatter, or any subagent-related topic for Claude Code.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for creating and using specialized subagents in Claude Code.

## Quick Reference

### Built-in Subagents

| Subagent | Model | Tools | Purpose |
|:---------|:------|:------|:--------|
| Explore | Haiku | Read-only | File discovery, code search, codebase exploration |
| Plan | Inherits | Read-only | Codebase research for planning (used in plan mode) |
| General-purpose | Inherits | All | Complex research, multi-step operations, code modifications |
| statusline-setup | Sonnet | -- | Configures status line via `/statusline` |
| Claude Code Guide | Haiku | -- | Answers questions about Claude Code features |

### Subagent File Format

```markdown
---
name: my-agent
description: When Claude should delegate to this agent
tools: Read, Grep, Glob, Bash
model: sonnet
---

System prompt in Markdown goes here.
```

### Supported Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier (lowercase letters and hyphens) |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools; inherits all if omitted |
| `disallowedTools` | No | Tools to deny (removed from inherited or specified list) |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default: `inherit`) |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before the subagent stops |
| `skills` | No | Skills injected into context at startup (full content, not just available) |
| `mcpServers` | No | MCP servers: inline definitions or string references to existing servers |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as a background task (default: `false`) |
| `effort` | No | `low`, `medium`, `high`, `max` (Opus 4.6 only); overrides session level |
| `isolation` | No | `worktree` for isolated git worktree (auto-cleaned if no changes) |
| `color` | No | `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan` |
| `initialPrompt` | No | Auto-submitted first user turn when running as main agent via `--agent` |

### Subagent Scope and Priority

| Location | Scope | Priority |
|:---------|:------|:---------|
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag (JSON) | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin `agents/` directory | Where plugin is enabled | 5 (lowest) |

Higher-priority definitions override lower ones when names match. Plugin subagents do **not** support `hooks`, `mcpServers`, or `permissionMode` fields.

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter (set by Claude when delegating)
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Tool Control

- **Allowlist** (`tools`): Only these tools are available
- **Denylist** (`disallowedTools`): Remove specific tools from the inherited set
- If both are set, `disallowedTools` is applied first, then `tools` resolves against the remaining pool
- **Restrict spawning** with `Agent(worker, researcher)` in `tools` to limit which subagent types can be spawned (only applies to agents running as main thread via `--agent`)
- Omit `Agent` from `tools` entirely to prevent spawning any subagents

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits |
| `auto` | AI classifier evaluates each tool call |
| `dontAsk` | Auto-deny prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip permission prompts (use with caution) |
| `plan` | Plan mode (read-only exploration) |

Parent `bypassPermissions` takes precedence; parent `auto` mode is inherited and cannot be overridden.

### Persistent Memory

| Scope | Location | Use When |
|:------|:---------|:---------|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via VCS |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not checked in |

When enabled: system prompt includes memory instructions + first 200 lines or 25KB of `MEMORY.md`; Read, Write, Edit tools are auto-enabled.

### Hooks

**In subagent frontmatter** (run only while that subagent is active):

| Event | Matcher Input | When |
|:------|:--------------|:-----|
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (converted to `SubagentStop`) |

**In settings.json** (project-level, main session):

| Event | Matcher Input | When |
|:------|:--------------|:-----|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Invoking Subagents

| Method | Behavior |
|:-------|:---------|
| Natural language ("Use the code-reviewer subagent...") | Claude decides whether to delegate |
| @-mention (`@"code-reviewer (agent)"`) | Guarantees that subagent runs for one task |
| `claude --agent <name>` | Entire session uses subagent's prompt, tools, and model |
| `agent` in `.claude/settings.json` | Default agent for every session in a project |

### Foreground vs Background

- **Foreground**: Blocks main conversation; permission prompts pass through to user
- **Background**: Runs concurrently; permissions pre-approved at launch; auto-denies unapproved tools; clarifying questions fail but subagent continues
- Press **Ctrl+B** to background a running task
- Disable with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`

### Resuming Subagents

- Ask Claude to continue previous work; it uses `SendMessage` with the agent ID
- Requires agent teams enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)
- Resumed subagents retain full conversation history
- If a stopped subagent receives a `SendMessage`, it auto-resumes in the background
- Transcripts stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`

### Disabling Subagents

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or via CLI: `claude --disallowedTools "Agent(Explore)"`

### Key Constraints

- Subagents **cannot spawn other subagents** (no nesting)
- Subagents receive only their system prompt + basic environment details, not the full Claude Code system prompt
- Subagents loaded at session start; restart or use `/agents` to load new ones
- Auto-compaction triggers at ~95% capacity (override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`)
- Transcripts cleaned up based on `cleanupPeriodDays` setting (default: 30 days)

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) -- Full guide covering built-in subagents, configuration, tool control, permission modes, persistent memory, hooks, invocation patterns, foreground/background execution, and example subagents

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
