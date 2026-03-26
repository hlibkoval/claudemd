---
name: sub-agents-doc
description: Complete documentation for Claude Code subagents -- creating, configuring, and managing specialized AI subagents for task-specific workflows. Covers built-in subagents (Explore with Haiku read-only, Plan for plan mode research, General-purpose with all tools, plus Bash/statusline-setup/Claude Code Guide helpers), creating subagents (/agents interactive command, manual Markdown files with YAML frontmatter, --agents CLI JSON flag, plugin agents), subagent scopes and priority (--agents CLI highest > .claude/agents/ project > ~/.claude/agents/ user > plugin agents/ lowest), frontmatter fields (name, description required; tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, effort, isolation, initialPrompt), model selection (sonnet/opus/haiku aliases, full model IDs, inherit default, CLAUDE_CODE_SUBAGENT_MODEL env var override, resolution order: env var > per-invocation > frontmatter > parent model), tool control (tools allowlist, disallowedTools denylist, Agent(agent_type) to restrict spawnable subagents, disallowedTools applied first), scoped MCP servers (inline definitions or string references in mcpServers field, servers connected/disconnected with subagent lifecycle), permission modes (default, acceptEdits, dontAsk, bypassPermissions, plan; parent bypassPermissions takes precedence, auto mode inheritance), preloading skills (skills field injects full content at startup, subagents do not inherit parent skills), persistent memory (memory field with user/project/local scopes, ~/.claude/agent-memory/ or .claude/agent-memory/ or .claude/agent-memory-local/, MEMORY.md auto-included first 200 lines, Read/Write/Edit auto-enabled), hooks in frontmatter (PreToolUse, PostToolUse, Stop converted to SubagentStop), project-level hooks (SubagentStart/SubagentStop events in settings.json with matcher on agent type name), background field for always-background execution, effort field (low/medium/high/max), isolation worktree mode, initialPrompt for --agent sessions, automatic delegation (Claude matches task to description), explicit invocation (natural language naming, @-mention via typeahead @"name (agent)", session-wide --agent flag or agent setting in .claude/settings.json), foreground vs background execution (Ctrl+B to background, CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1 to disable), common patterns (isolate high-volume operations, parallel research, chaining subagents), resume subagents (SendMessage with agent ID, transcripts at ~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl), auto-compaction (95% default, CLAUDE_AUTOCOMPACT_PCT_OVERRIDE), disabling subagents (permissions.deny with Agent(name) format, --disallowedTools CLI flag), plugin subagent restrictions (no hooks/mcpServers/permissionMode from plugins). Load when discussing subagents, sub-agents, Agent tool, Task tool, /agents command, claude --agent, agent delegation, subagent configuration, subagent tools, subagent permissions, subagent memory, subagent hooks, SubagentStart, SubagentStop, background agents, agent isolation, agent worktree, Explore agent, Plan agent, General-purpose agent, CLAUDE_CODE_SUBAGENT_MODEL, or any subagent-related topic for Claude Code.
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents -- specialized AI assistants that handle specific types of tasks within their own context window.

## Quick Reference

Subagents are specialized AI assistants that run in isolated context with custom system prompts, specific tool access, and independent permissions. Claude automatically delegates tasks to matching subagents based on their description.

### Built-in Subagents

| Subagent | Model | Tools | Purpose |
|:---------|:------|:------|:--------|
| **Explore** | Haiku | Read-only (no Write/Edit) | File discovery, code search, codebase exploration |
| **Plan** | Inherits | Read-only (no Write/Edit) | Codebase research for plan mode |
| **General-purpose** | Inherits | All tools | Complex research, multi-step operations, code modifications |
| **Bash** | Inherits | -- | Running terminal commands in a separate context |
| **statusline-setup** | Sonnet | -- | When you run `/statusline` to configure your status line |
| **Claude Code Guide** | Haiku | -- | When you ask questions about Claude Code features |

Explore uses three thoroughness levels: **quick** (targeted lookups), **medium** (balanced), **very thorough** (comprehensive analysis).

### Creating Subagents

| Method | Description |
|:-------|:------------|
| `/agents` command | Interactive creation with guided setup or Claude generation |
| Manual Markdown file | Create `.md` file with YAML frontmatter in agents directory |
| `--agents` CLI flag | JSON definition for current session only (not saved to disk) |
| Plugin `agents/` directory | Distributed via plugins |
| `claude agents` | List all configured subagents from CLI (non-interactive) |

### Subagent Scopes and Priority

| Location | Scope | Priority |
|:---------|:------|:---------|
| `--agents` CLI flag | Current session | 1 (highest) |
| `.claude/agents/` | Current project | 2 |
| `~/.claude/agents/` | All your projects | 3 |
| Plugin `agents/` directory | Where plugin is enabled | 4 (lowest) |

When multiple subagents share the same name, the higher-priority location wins.

### Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier (lowercase letters and hyphens) |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools; inherits all if omitted |
| `disallowedTools` | No | Denylist of tools; removed from inherited/specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before the subagent stops |
| `skills` | No | Skills to inject into subagent context at startup |
| `mcpServers` | No | MCP servers available to this subagent (inline or by name) |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | Set `true` to always run as background task (default: `false`) |
| `effort` | No | Effort level: `low`, `medium`, `high`, `max` (Opus 4.6 only) |
| `isolation` | No | Set `worktree` for isolated git worktree copy |
| `initialPrompt` | No | Auto-submitted first user turn when running as main session agent |

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable (if set)
2. Per-invocation `model` parameter (passed by Claude at runtime)
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Tool Control

**Allowlist** -- use `tools` to exclusively permit specific tools:
```yaml
tools: Read, Grep, Glob, Bash
```

**Denylist** -- use `disallowedTools` to block specific tools while inheriting others:
```yaml
disallowedTools: Write, Edit
```

If both are set, `disallowedTools` is applied first, then `tools` is resolved against the remaining pool.

**Restrict spawnable subagents** -- use `Agent(agent_type)` in `tools` for `--agent` sessions:
```yaml
tools: Agent(worker, researcher), Read, Bash
```

Use `Agent` without parentheses to allow spawning any subagent. Omit `Agent` entirely to prevent spawning. This only applies to agents running as the main thread with `claude --agent`.

### Scoped MCP Servers

Define MCP servers scoped to a subagent using the `mcpServers` field:

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

Inline servers connect when the subagent starts and disconnect when it finishes. String references share the parent session's connection.

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip permission prompts |
| `plan` | Plan mode (read-only exploration) |

If the parent uses `bypassPermissions`, it takes precedence and cannot be overridden. If the parent uses auto mode, the subagent inherits it and `permissionMode` in frontmatter is ignored.

### Persistent Memory

| Scope | Location | Use when |
|:------|:---------|:---------|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via VCS |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not checked into VCS |

When memory is enabled, the first 200 lines of `MEMORY.md` in the memory directory are included in the system prompt. Read, Write, and Edit tools are automatically enabled.

### Hooks

**In subagent frontmatter** (runs only while that subagent is active):

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (converted to `SubagentStop`) |

**In settings.json** (runs in the main session):

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Invoking Subagents

| Method | Behavior |
|:-------|:---------|
| Automatic delegation | Claude matches task to subagent description |
| Natural language | Name the subagent in your prompt |
| @-mention | `@"code-reviewer (agent)"` guarantees that subagent runs |
| `--agent <name>` CLI flag | Entire session uses subagent's prompt, tools, and model |
| `agent` setting in `.claude/settings.json` | Default agent for every session in a project |

For plugin subagents, use `<plugin-name>:<agent-name>` format (e.g., `claude --agent myplugin:my-agent`).

### Foreground vs Background

| Mode | Permission prompts | Clarifying questions | How to trigger |
|:-----|:-------------------|:---------------------|:---------------|
| **Foreground** | Passed through to user | Passed through to user | Default for most tasks |
| **Background** | Pre-approved before launch; auto-denied after | Fail (subagent continues) | "run in background", Ctrl+B, or `background: true` |

Disable all background tasks with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

### Resuming Subagents

Claude uses `SendMessage` with the agent ID to resume a stopped subagent. Transcripts are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`. Transcripts persist independently of main conversation compaction and are cleaned up after `cleanupPeriodDays` (default: 30).

### Auto-Compaction

Subagents auto-compact at approximately 95% capacity by default. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (e.g., `50` for 50%).

### Disabling Subagents

Add to `permissions.deny` in settings:
```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or use CLI: `claude --disallowedTools "Agent(Explore)"`

### Plugin Subagent Restrictions

Plugin subagents do **not** support `hooks`, `mcpServers`, or `permissionMode` frontmatter fields. These fields are ignored when loading agents from a plugin. Copy the agent file into `.claude/agents/` or `~/.claude/agents/` if you need these features.

### Key Constraints

- Subagents cannot spawn other subagents
- Subagents receive only their system prompt (plus basic environment details), not the full Claude Code system prompt
- Subagents do not inherit skills from the parent conversation; list them explicitly in the `skills` field
- Subagents are loaded at session start; manually added files require a session restart or `/agents` to load immediately

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) -- Complete guide to subagents: built-in subagents (Explore, Plan, General-purpose, Bash, statusline-setup, Claude Code Guide), quickstart with /agents command, subagent scopes and priority (CLI > project > user > plugin), writing subagent Markdown files with YAML frontmatter, all frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, effort, isolation, initialPrompt), model selection and resolution order (env var > per-invocation > frontmatter > parent), tool control (allowlist/denylist, Agent(type) for restricting spawnable agents), scoped MCP servers (inline and reference), permission modes (default/acceptEdits/dontAsk/bypassPermissions/plan, parent precedence), preloading skills, persistent memory (user/project/local scopes, MEMORY.md), hooks in frontmatter (PreToolUse/PostToolUse/Stop) and in settings.json (SubagentStart/SubagentStop), automatic and explicit delegation (natural language, @-mention, --agent flag, agent setting), foreground vs background execution (Ctrl+B, CLAUDE_CODE_DISABLE_BACKGROUND_TASKS), common patterns (isolating high-volume operations, parallel research, chaining), choosing between subagents and main conversation, resuming subagents (SendMessage with agent ID, transcript persistence), auto-compaction (CLAUDE_AUTOCOMPACT_PCT_OVERRIDE), disabling subagents (permissions.deny, --disallowedTools), plugin subagent restrictions, example subagents (code-reviewer, debugger, data-scientist, db-reader with PreToolUse hook validation)

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
