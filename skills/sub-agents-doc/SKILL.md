---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — built-in subagents, creating custom subagents, frontmatter fields, model selection, tool restrictions, permission modes, hooks, persistent memory, forked subagents, invocation patterns, and example subagent definitions.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

### Built-in Subagents

| Agent | Model | Tools | Purpose |
| :--- | :--- | :--- | :--- |
| Explore | Haiku | Read-only | File discovery, code search, codebase exploration |
| Plan | Inherits | Read-only | Codebase research during plan mode |
| General-purpose | Inherits | All | Complex multi-step tasks requiring exploration and action |
| statusline-setup | Sonnet | — | Configures status line when `/statusline` is run |
| claude-code-guide | Haiku | — | Answers questions about Claude Code features |

### Subagent Scopes and Priority

| Location | Scope | Priority |
| :--- | :--- | :--- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin's `agents/` directory | Where plugin is enabled | 5 (lowest) |

Higher-priority location wins when multiple subagents share the same name.

### Subagent Frontmatter Fields

Only `name` and `description` are required. All others are optional.

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier (lowercase letters and hyphens) |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools (inherits all if omitted) |
| `disallowedTools` | No | Denylist of tools removed from inherited/specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | No | Max agentic turns before stopping |
| `skills` | No | Skills to inject into subagent context at startup |
| `mcpServers` | No | MCP servers available to the subagent (ignored for plugin subagents) |
| `hooks` | No | Lifecycle hooks scoped to this subagent (ignored for plugin subagents) |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as a background task (default: `false`) |
| `effort` | No | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `isolation` | No | `worktree` to run in a temporary git worktree |
| `color` | No | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `initialPrompt` | No | Auto-submitted first user turn when agent runs as main session |

### Model Resolution Order

When Claude invokes a subagent, model is resolved in this order:

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable (if set)
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits and common filesystem commands |
| `auto` | Background classifier reviews commands and protected writes |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission prompts (use with caution) |
| `plan` | Plan mode (read-only exploration) |

If parent uses `bypassPermissions` or `acceptEdits`, this takes precedence and cannot be overridden.

### Tool Control Patterns

```yaml
# Allowlist: only these tools
tools: Read, Grep, Glob, Bash

# Denylist: inherit all except these
disallowedTools: Write, Edit

# Restrict which subagents can be spawned (for --agent main thread only)
tools: Agent(worker, researcher), Read, Bash

# Allow spawning any subagent
tools: Agent, Read, Bash
```

If both `tools` and `disallowedTools` are set, `disallowedTools` is applied first, then `tools` resolves against the remaining pool.

### Persistent Memory Scopes

| Scope | Location | Use when |
| :--- | :--- | :--- |
| `user` | `~/.claude/agent-memory/<agent-name>/` | Knowledge applies across all projects |
| `project` | `.claude/agent-memory/<agent-name>/` | Project-specific, shareable via version control |
| `local` | `.claude/agent-memory-local/<agent-name>/` | Project-specific, not checked into version control |

When memory is enabled, the subagent's system prompt includes the first 200 lines or 25KB of `MEMORY.md`, and Read/Write/Edit tools are automatically enabled.

### Hook Events for Subagents

**In subagent frontmatter** (runs while subagent is active):

| Event | Matcher input | When it fires |
| :--- | :--- | :--- |
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (becomes `SubagentStop` at runtime) |

**In `settings.json`** (project-level, responds to lifecycle events in main session):

| Event | Matcher input | When it fires |
| :--- | :--- | :--- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Invoking Subagents

```text
# Natural language (Claude decides whether to delegate)
Use the code-reviewer subagent to review my changes

# @-mention (guarantees delegation for one task)
@"code-reviewer (agent)" look at the auth changes

# Plugin subagent @-mention
@agent-<plugin-name>:<agent-name>

# Run whole session as a subagent
claude --agent code-reviewer
claude --agent <plugin-name>:<agent-name>

# Set default agent in project settings
{ "agent": "code-reviewer" }
```

### Forked Subagents (Experimental)

Enable with `CLAUDE_CODE_FORK_SUBAGENT=1`. Requires Claude Code v2.1.117+.

| | Fork | Named subagent |
| :--- | :--- | :--- |
| Context | Full conversation history | Fresh context with the prompt you pass |
| System prompt / tools | Same as main session | From the subagent's definition file |
| Model | Same as main session | From the subagent's `model` field |
| Prompt cache | Shared with main session | Separate cache |

Start a fork with `/fork <directive>`. Fork panel keyboard controls:

| Key | Action |
| :--- | :--- |
| Up / Down | Move between rows |
| Enter | Open transcript and send follow-up messages |
| x | Dismiss finished fork or stop running one |
| Esc | Return focus to prompt input |

### Disable Specific Subagents

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or via CLI: `claude --disallowedTools "Agent(Explore)"`

### CLI Commands

```bash
# List all configured subagents
claude agents

# Manage subagents interactively
/agents

# Disable background tasks
CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1
```

### Subagent Transcript Location

Stored at: `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`

Cleaned up based on `cleanupPeriodDays` setting (default: 30 days).

### Auto-compaction

Triggers at ~95% capacity by default. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (e.g., `50` for 50%).

### Plugin Subagent Restrictions

Plugin subagents do NOT support: `hooks`, `mcpServers`, or `permissionMode`. These fields are ignored when loading agents from a plugin.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — built-in subagents, quickstart, all frontmatter fields, model selection, tool/permission control, hooks, memory, forked subagents, invocation patterns, common patterns, and example subagent definitions

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
