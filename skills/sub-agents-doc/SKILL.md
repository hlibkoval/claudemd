---
name: sub-agents-doc
description: Complete documentation for Claude Code subagents -- creating, configuring, and managing specialized AI subagents that run in isolated context windows. Covers built-in subagents (Explore, Plan, general-purpose), custom subagent creation via /agents command or Markdown files, all frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, effort, isolation, color, initialPrompt), subagent scopes and priority (managed, CLI, project, user, plugin), model resolution order, tool control (allowlist, denylist, Agent(type) restrictions), permission modes, MCP server scoping, persistent memory (user/project/local), hooks in subagent frontmatter and settings.json (PreToolUse, PostToolUse, SubagentStart, SubagentStop), foreground vs background execution, invocation patterns (natural language, @-mention, --agent flag), resuming subagents, auto-compaction, context management, and example subagents (code-reviewer, debugger, data-scientist, db-reader with hook validation). Load when discussing subagents, custom agents, Agent tool, /agents command, agent delegation, agent teams vs subagents, subagent tools, subagent permissions, subagent hooks, subagent memory, background tasks, --agent flag, agent isolation, worktree isolation, or any subagent-related topic for Claude Code.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code subagents -- specialized AI assistants that handle specific tasks in isolated context windows with custom system prompts, tool access, and permissions.

## Quick Reference

### Built-in Subagents

| Subagent | Model | Tools | Purpose |
|:---------|:------|:------|:--------|
| Explore | Haiku | Read-only (no Write/Edit) | File discovery, code search, codebase exploration |
| Plan | Inherited | Read-only (no Write/Edit) | Codebase research for planning mode |
| General-purpose | Inherited | All tools | Complex research, multi-step operations, code modifications |
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
|:------|:---------|:-----------|
| `name` | Yes | Unique identifier (lowercase letters and hyphens) |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools. Inherits all if omitted |
| `disallowedTools` | No | Tools to deny (removed from inherited or specified list) |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | No | Maximum agentic turns before subagent stops |
| `skills` | No | Skills injected into subagent context at startup |
| `mcpServers` | No | MCP servers: inline definitions or string references |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as background task (default: `false`) |
| `effort` | No | `low`, `medium`, `high`, `max` (Opus 4.6 only). Default: inherits |
| `isolation` | No | `worktree` for git worktree isolation (auto-cleaned if no changes) |
| `color` | No | `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `initialPrompt` | No | Auto-submitted first turn when running as main agent via `--agent` |

### Subagent Scopes (Priority Order)

| Priority | Location | Scope |
|:---------|:---------|:------|
| 1 (highest) | Managed settings | Organization-wide |
| 2 | `--agents` CLI flag | Current session only |
| 3 | `.claude/agents/` | Current project |
| 4 | `~/.claude/agents/` | All your projects |
| 5 (lowest) | Plugin `agents/` directory | Where plugin is enabled |

When multiple subagents share the same name, the higher-priority location wins.

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Tool Control

**Allowlist** (`tools`): Only listed tools are available.

**Denylist** (`disallowedTools`): Listed tools removed from inherited set.

If both are set, `disallowedTools` is applied first, then `tools` resolved against the remaining pool.

**Restrict spawnable subagents** (main agent only): `tools: Agent(worker, researcher), Read, Bash` -- only `worker` and `researcher` can be spawned. `Agent` without parentheses allows all. Omitting `Agent` entirely prevents spawning.

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits except in protected directories |
| `auto` | Background classifier reviews commands and protected-directory writes |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip permission prompts (use with caution) |
| `plan` | Plan mode (read-only exploration) |

Parent `bypassPermissions` takes precedence. Parent `auto` mode forces subagent into auto mode.

### Persistent Memory

| Scope | Location | Use when |
|:------|:---------|:---------|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Knowledge is project-specific, shareable via VCS |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not checked into VCS |

When enabled: system prompt includes memory instructions, first 200 lines / 25KB of `MEMORY.md` is auto-included, Read/Write/Edit tools auto-enabled.

### Foreground vs Background Execution

| Mode | Permissions | Clarifying questions | How to trigger |
|:-----|:-----------|:--------------------|:---------------|
| Foreground | Interactive prompts passed through | Supported | Default behavior |
| Background | Pre-approved upfront, auto-deny others | Fail (subagent continues) | Ask Claude, press Ctrl+B, or set `background: true` |

Disable background tasks: `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`

### Invocation Patterns

| Pattern | Behavior |
|:--------|:---------|
| Natural language: "Use the code-reviewer subagent to..." | Claude decides whether to delegate |
| @-mention: `@"code-reviewer (agent)" ...` | Guarantees subagent runs for one task |
| `claude --agent code-reviewer` | Entire session uses subagent's config |
| `"agent": "code-reviewer"` in `.claude/settings.json` | Default agent for every session in project |

Plugin subagents: `claude --agent <plugin-name>:<agent-name>`

### Hooks for Subagents

**In subagent frontmatter** (run only while subagent is active):

| Event | Matcher | When |
|:------|:--------|:-----|
| `PreToolUse` | Tool name | Before subagent uses a tool |
| `PostToolUse` | Tool name | After subagent uses a tool |
| `Stop` | (none) | When subagent finishes (converted to `SubagentStop`) |

**In settings.json** (main session events):

| Event | Matcher | When |
|:------|:--------|:-----|
| `SubagentStart` | Agent type name | When a subagent begins |
| `SubagentStop` | Agent type name | When a subagent completes |

### MCP Server Scoping

```yaml
mcpServers:
  # Inline: scoped to subagent only, not visible in main conversation
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  # Reference: reuses already-configured server
  - github
```

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

### Disabling Subagents

Add to `permissions.deny` in settings: `"Agent(Explore)"`, `"Agent(my-custom-agent)"`

Or via CLI: `claude --disallowedTools "Agent(Explore)"`

### Plugin Subagent Restrictions

Plugin subagents do NOT support `hooks`, `mcpServers`, or `permissionMode` frontmatter fields (ignored when loading). Copy agent file to `.claude/agents/` or `~/.claude/agents/` if needed.

### Subagent Context Management

- Subagents cannot spawn other subagents
- Resume subagents by asking Claude to continue previous work (uses `SendMessage` with agent ID when agent teams enabled)
- Transcripts stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`
- Auto-compaction at ~95% capacity (override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`)
- Main conversation compaction does not affect subagent transcripts
- Transcripts cleaned up per `cleanupPeriodDays` setting (default: 30 days)

### Key Design Guidelines

- Design focused subagents that excel at one specific task
- Write detailed descriptions so Claude knows when to delegate
- Limit tool access to only necessary permissions
- Check project subagents into version control for team sharing
- Use subagents for verbose output, enforced restrictions, or self-contained work
- Use main conversation for iterative refinement, shared context, or quick changes
- Use `/btw` for quick questions (sees full context, no tools, answer discarded)

## Full Documentation

For the complete official documentation, see the reference files:

- [Create Custom Subagents](references/claude-code-sub-agents.md) -- Built-in subagents, creating custom subagents, configuration options, tool control, permission modes, hooks, memory, invocation patterns, and example subagents

## Sources

- Create Custom Subagents: https://code.claude.com/docs/en/sub-agents.md
