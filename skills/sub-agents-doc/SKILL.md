---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — built-in agents, creating and configuring custom subagents, frontmatter fields, tool access, permission modes, hooks, persistent memory, forked subagents, invocation patterns, and example subagents.
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

### What Subagents Are For

Subagents run isolated tasks in their own context window so verbose output (test logs, search results, fetched docs) stays out of your main conversation. Each subagent has its own system prompt, tool access, and permission mode.

### Built-in Subagents

| Agent | Model | Tools | Purpose |
| :--- | :--- | :--- | :--- |
| **Explore** | Haiku | Read-only | Fast codebase search; skips CLAUDE.md and git status |
| **Plan** | Inherits | Read-only | Research for plan mode; skips CLAUDE.md and git status |
| **General-purpose** | Inherits | All | Complex multi-step tasks requiring exploration and action |
| **statusline-setup** | Sonnet | — | Invoked by `/statusline` |
| **claude-code-guide** | Haiku | — | Answers questions about Claude Code features |

### Subagent Scopes and Priority

| Location | Scope | Priority |
| :--- | :--- | :--- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin `agents/` directory | Where plugin is enabled | 5 (lowest) |

When names collide, higher priority wins. Check project subagents into version control for team sharing.

### Frontmatter Fields

Only `name` and `description` are required.

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique lowercase-and-hyphens identifier |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools; inherits all if omitted |
| `disallowedTools` | No | Denylist removed from inherited/specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Max agentic turns before the subagent stops |
| `skills` | No | Skills to preload into the subagent's context at startup |
| `mcpServers` | No | MCP servers scoped to this subagent (ignored for plugin subagents) |
| `hooks` | No | Lifecycle hooks scoped to this subagent (ignored for plugin subagents) |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as a background task |
| `effort` | No | `low`, `medium`, `high`, `xhigh`, or `max` |
| `isolation` | No | `worktree` to run in a temporary git worktree |
| `color` | No | `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan` |
| `initialPrompt` | No | Auto-submitted first user turn when running as main session agent |

Plugin subagents ignore `hooks`, `mcpServers`, and `permissionMode` for security reasons.

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits for working directory paths |
| `auto` | Background classifier reviews commands before approval |
| `dontAsk` | Auto-deny prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission prompts (use with caution) |
| `plan` | Read-only exploration mode |

If the parent session uses `bypassPermissions` or `acceptEdits`, subagent cannot override. If parent uses auto mode, subagent inherits it and `permissionMode` frontmatter is ignored.

### Persistent Memory Scopes

| Scope | Location | Use when |
| :--- | :--- | :--- |
| `user` | `~/.claude/agent-memory/<name>/` | Knowledge applies across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via version control |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not checked in |

When memory is enabled, the subagent's system prompt includes instructions for the memory directory plus the first 200 lines or 25KB of `MEMORY.md`. Read, Write, and Edit tools are auto-enabled.

### Tools Not Available to Subagents

Even if listed in `tools`, these are unavailable to subagents:

- `Agent`
- `AskUserQuestion`
- `EnterPlanMode`
- `ExitPlanMode` (unless `permissionMode: plan`)
- `ScheduleWakeup`
- `WaitForMcpServers`

### Restrict Which Subagents Can Be Spawned

Use `Agent(agent_type)` syntax in the `tools` field of an agent running as the main thread via `--agent`:

```yaml
tools: Agent(worker, researcher), Read, Bash
```

This is an allowlist: only named types can be spawned. Use `Agent` without parentheses to allow all. Omit `Agent` entirely to block spawning. Note: In v2.1.63 the Task tool was renamed to Agent; `Task(...)` still works as an alias.

### Hooks for Subagents

**Frontmatter hooks** run only while the subagent is active. Supported events:

| Event | Matcher input | When it fires |
| :--- | :--- | :--- |
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (auto-converted to `SubagentStop`) |

**Session-level hooks** in `settings.json` respond to subagent lifecycle:

| Event | Matcher input | When it fires |
| :--- | :--- | :--- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Invoking Subagents

| Method | How |
| :--- | :--- |
| Natural language | Name the subagent; Claude decides whether to delegate |
| @-mention | `@"code-reviewer (agent)"` — guarantees that subagent runs for one task |
| Session-wide | `claude --agent code-reviewer` — main thread uses that definition |
| Setting | `"agent": "code-reviewer"` in `.claude/settings.json` |

Plugin subagents appear in the typeahead as `my-plugin:code-reviewer`. Manual mention syntax: `@agent-<name>` for local, `@agent-my-plugin:code-reviewer` for plugins.

### Foreground vs. Background

- **Foreground**: blocks main conversation; permission prompts are passed through.
- **Background**: runs concurrently; auto-denies any tool call that would prompt. Press **Ctrl+B** to background a running task, or ask Claude to "run this in the background."

Disable all background tasks: `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

### What Loads at Subagent Startup

| Item | Loads? |
| :--- | :--- |
| Subagent's own system prompt | Yes |
| Full Claude Code system prompt | No |
| CLAUDE.md files at all levels | Yes (except Explore and Plan) |
| Git status snapshot | Yes (except Explore and Plan; or when disabled) |
| Parent conversation history | No (except forks) |
| Skills listed in `skills` field | Yes |

### Forked Subagents (Experimental)

Enable with `CLAUDE_CODE_FORK_SUBAGENT=1` (requires v2.1.117+). A fork inherits the full conversation history, system prompt, tools, and model of the main session. Every subagent spawn becomes a background task; `/fork <directive>` spawns a fork explicitly.

| | Fork | Named subagent |
| :--- | :--- | :--- |
| Context | Full conversation history | Fresh context |
| System prompt & tools | Same as main session | From definition file |
| Model | Same as main session | From `model` field |
| Permissions | Surfaces in terminal | Auto-denied (background) |
| Prompt cache | Shared with main session | Separate cache |

Fork panel keys: Up/Down to move rows, Enter to open transcript, `x` to stop/dismiss, Esc to return focus.

### Disabling Specific Subagents

Add to `permissions.deny` in settings.json:
```json
{ "permissions": { "deny": ["Agent(Explore)", "Agent(my-custom-agent)"] } }
```

Or via CLI: `claude --disallowedTools "Agent(Explore)"`

### Common Patterns

| Pattern | When to use |
| :--- | :--- |
| **Isolate high-volume ops** | Run tests/log analysis in subagent; only summary returns to main context |
| **Parallel research** | Spawn multiple subagents for independent investigations simultaneously |
| **Chain subagents** | Use output of one subagent as input to the next for multi-step workflows |

### When to Use Subagents vs. Main Conversation

Use **subagents** when the task produces verbose output, needs specific tool restrictions, or is self-contained.  
Use the **main conversation** for iterative tasks, shared-context phases, quick changes, or when latency matters.  
Use **Skills** for reusable prompts that run in the main conversation context.  
Use `/btw` for quick questions that don't need tool access and whose answer can be discarded.

### Subagent Transcript Storage

Stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`. Cleaned up after `cleanupPeriodDays` (default 30 days). Resume a stopped subagent by asking Claude to continue the previous work (requires agent teams enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`).

### Auto-Compaction

Triggers at ~95% context capacity by default. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (e.g., `50`). Compaction events are logged to the subagent transcript with `type: "system"`, `subtype: "compact_boundary"`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — built-in agents, creating and configuring subagents, frontmatter fields, tool access, permission modes, MCP server scoping, hooks, persistent memory, fork mode, invocation patterns, example subagents

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
