---
name: sub-agents-doc
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents — specialized AI assistants that handle specific tasks in their own isolated context windows, with custom system prompts, tool access, and permission modes.

## Quick Reference

### Built-in Subagents

| Agent | Model | Tools | When Claude uses it |
| :--- | :--- | :--- | :--- |
| `Explore` | Haiku | Read-only | Searching/understanding codebases without changes. Skips CLAUDE.md and git status |
| `Plan` | Inherits | Read-only | Codebase research during plan mode. Skips CLAUDE.md and git status |
| `general-purpose` | Inherits | All | Complex multi-step tasks requiring both exploration and action |
| `statusline-setup` | Sonnet | — | When you run `/statusline` |
| `claude-code-guide` | Haiku | — | When you ask questions about Claude Code features |

### Subagent File Format

```markdown
---
name: my-agent
description: When Claude should delegate to this subagent
tools: Read, Grep, Glob, Bash
model: sonnet
---

System prompt here.
```

### Supported Frontmatter Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique ID using lowercase letters and hyphens. Hooks receive this as `agent_type` |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools; inherits all if omitted. Use `Agent(worker, researcher)` to restrict spawnable subagent types |
| `disallowedTools` | No | Denylist of tools removed from inherited or specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, `fable`, a full model ID (e.g. `claude-opus-4-8`), or `inherit`. Defaults to `inherit` |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`. Ignored for plugin subagents |
| `maxTurns` | No | Maximum agentic turns before the subagent stops |
| `skills` | No | Skills to preload into context at startup (full content injected) |
| `mcpServers` | No | MCP servers available to this subagent. Ignored for plugin subagents |
| `hooks` | No | Lifecycle hooks scoped to this subagent. Ignored for plugin subagents |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as a background task. Default: `false` |
| `effort` | No | `low`, `medium`, `high`, `xhigh`, or `max`. Overrides session effort level |
| `isolation` | No | `worktree` to run in a temporary git worktree |
| `color` | No | `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan` |
| `initialPrompt` | No | Auto-submitted as first user turn when running as main session agent via `--agent` |

### Subagent Scopes and Priority

| Location | Scope | Priority |
| :--- | :--- | :--- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin's `agents/` directory | Where plugin is enabled | 5 (lowest) |

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits and common filesystem commands |
| `auto` | Background classifier reviews commands |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip permission prompts entirely (use with caution) |
| `plan` | Plan mode (read-only exploration) |

If the parent uses `bypassPermissions` or `acceptEdits`, the child cannot override those. If parent uses auto mode, child inherits it regardless of frontmatter.

### Persistent Memory Scopes

| Scope | Location | Use when |
| :--- | :--- | :--- |
| `user` | `~/.claude/agent-memory/<name>/` | Subagent should remember learnings across all projects |
| `project` | `.claude/agent-memory/<name>/` | Knowledge is project-specific and shareable via version control |
| `local` | `.claude/agent-memory-local/<name>/` | Knowledge is project-specific but should not be checked in |

When memory is enabled, first 200 lines or 25 KB of `MEMORY.md` is injected into the subagent's context. Read, Write, and Edit tools are automatically enabled.

### Hook Events for Subagents

**In subagent frontmatter** (run while that subagent is active):

| Event | When it fires |
| :--- | :--- |
| `PreToolUse` | Before the subagent uses a tool |
| `PostToolUse` | After the subagent uses a tool |
| `Stop` | When subagent finishes (converted to `SubagentStop` at runtime) |

**In `settings.json`** (run in the main session):

| Event | Matcher | When it fires |
| :--- | :--- | :--- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Invoking Subagents Explicitly

| Method | Syntax | Effect |
| :--- | :--- | :--- |
| Natural language | `Use the code-reviewer subagent to…` | Claude decides whether to delegate |
| @-mention | `@"code-reviewer (agent)" look at…` | Guarantees that subagent runs for one task |
| Session-wide | `claude --agent code-reviewer` | Whole session uses that subagent's system prompt, tools, model |
| Project default | `"agent": "code-reviewer"` in `.claude/settings.json` | Default for every session in the project |

Plugin subagents use scoped names in @-mentions: `@agent-my-plugin:code-reviewer`. For subagents in plugin subfolders: `@agent-my-plugin:review:security`.

### Tool Restriction Patterns

```yaml
# Allowlist — only these tools
tools: Read, Grep, Glob, Bash

# Denylist — everything except these
disallowedTools: Write, Edit

# MCP server-level pattern — remove all tools from one server
disallowedTools: mcp__github

# Restrict which subagent types can be spawned (main thread only)
tools: Agent(worker, researcher), Read, Bash
```

If both `tools` and `disallowedTools` are set, `disallowedTools` is applied first.

### CLI-Defined Subagents

Pass JSON via `--agents` for session-scoped definitions (not saved to disk). Supports all frontmatter fields plus `prompt` (equivalent to the markdown body):

```bash
claude --agents '{"code-reviewer": {"description": "…", "prompt": "…", "tools": ["Read", "Bash"], "model": "sonnet"}}'
```

### Forking the Current Conversation

A fork inherits the full conversation history instead of starting fresh. Start one with `/fork <directive>`. Requires Claude Code v2.1.117+; enabled by default from v2.1.161. Control with `CLAUDE_CODE_FORK_SUBAGENT=1` (enable) or `=0` (disable).

| | Fork | Named subagent |
| :--- | :--- | :--- |
| Context | Full conversation history | Fresh context with delegation prompt |
| System prompt / tools | Same as main session | From the subagent's definition file |
| Model | Same as main session | From subagent's `model` field |
| Prompt cache | Shared with main session | Separate cache |

Fork panel keyboard shortcuts:

| Key | Action |
| :--- | :--- |
| `↑` / `↓` | Move between rows |
| `Enter` | Open transcript and send follow-up messages |
| `x` | Dismiss finished fork or stop running one |
| `Esc` | Return focus to prompt input |

### Nested Subagents (v2.1.172+)

Subagents can spawn their own subagents. Maximum nesting depth is 5 levels below the main conversation. A fork cannot spawn another fork. To prevent a subagent from spawning others, omit `Agent` from its `tools` list.

### What Loads at Startup (non-fork)

| Content | Built-in Explore/Plan | All other subagents |
| :--- | :--- | :--- |
| Subagent's own system prompt | Yes | Yes |
| Task delegation message | Yes | Yes |
| CLAUDE.md and memory hierarchy | No | Yes |
| Git status snapshot | No | Yes |
| Preloaded skills (`skills` field) | No | Yes (if configured) |

### When to Use Subagents vs. Other Approaches

Use subagents when:
- The task produces verbose output you don't need in your main context
- You want to enforce specific tool restrictions or permissions
- The work is self-contained and can return a summary
- You want to run multiple independent investigations in parallel

Use the main conversation when:
- The task needs frequent back-and-forth
- Multiple phases share significant context
- You're making a quick, targeted change
- Latency matters (subagents start fresh)

Consider `/btw` for quick side questions — it sees full context but has no tool access and the answer is discarded. Consider Skills for reusable prompts/workflows that run in the main conversation context.

### Disable Specific Subagents

In `settings.json`:
```json
{"permissions": {"deny": ["Agent(Explore)", "Agent(my-custom-agent)"]}}
```

Via CLI:
```bash
claude --disallowedTools "Agent(Explore)"
```

To disable all built-in agents in non-interactive/SDK mode: `CLAUDE_AGENT_SDK_DISABLE_BUILTIN_AGENTS=1`.

### Subagent Transcripts

Stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`. Cleaned up after `cleanupPeriodDays` (default: 30 days). Persist independently from the main conversation. To resume a stopped subagent, ask Claude to continue its previous work — Claude uses `SendMessage` with the agent ID.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — Built-in subagents, file format, all frontmatter fields, tool/permission/model configuration, hooks, memory, forking, nested subagents, patterns, example agents

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
