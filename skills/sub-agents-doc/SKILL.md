---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — built-in subagents (Explore, Plan, general-purpose), creating and configuring custom subagents (frontmatter fields, tool access, permission modes, model selection, hooks, persistent memory, skills preloading, MCP server scoping), invoking subagents (automatic delegation, @-mention, --agent flag, session-wide), foreground vs background execution, fork mode, context management, and subagent scope (project, user, CLI, managed, plugin).
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

### What Subagents Are

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Claude delegates tasks to them automatically based on their `description` field. Use subagents to keep verbose output out of your main context, enforce tool restrictions, and reuse configurations across projects.

Subagents cannot spawn other subagents. For sustained parallelism, see [agent teams](/en/agent-teams).

### Built-in Subagents

| Agent | Model | Tools | When used |
| :--- | :--- | :--- | :--- |
| `Explore` | Haiku | Read-only | File discovery, codebase search; skips CLAUDE.md and git status |
| `Plan` | Inherited | Read-only | Research during plan mode; skips CLAUDE.md and git status |
| `general-purpose` | Inherited | All | Complex multi-step tasks requiring exploration and modification |
| `statusline-setup` | Sonnet | — | When you run `/statusline` |
| `claude-code-guide` | Haiku | — | When you ask about Claude Code features |

### Subagent File Format

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze code and provide specific, actionable feedback.
```

### Supported Frontmatter Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier (lowercase, hyphens). Hooks receive this as `agent_type` |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools. Inherits all if omitted. Use `Agent(name)` to restrict spawnable subagents |
| `disallowedTools` | No | Denylist removed from inherited or specified list. Applied before `tools` |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`. Ignored for plugin subagents |
| `maxTurns` | No | Maximum agentic turns before the subagent stops |
| `skills` | No | Skills to preload into context at startup (full content injected) |
| `mcpServers` | No | MCP servers scoped to this subagent (inline definitions or name references). Ignored for plugin subagents |
| `hooks` | No | Lifecycle hooks scoped to this subagent. Ignored for plugin subagents |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as a background task (default: `false`) |
| `effort` | No | Override session effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `isolation` | No | `worktree` to run in a temporary git worktree (isolated copy of the repo) |
| `color` | No | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `initialPrompt` | No | Auto-submitted first user turn when the agent runs as main session (via `--agent` or `agent` setting) |

### Subagent Scope & Priority

| Location | Scope | Priority |
| :--- | :--- | :--- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin `agents/` directory | Where plugin is enabled | 5 (lowest) |

When multiple subagents share the same name, higher priority wins. Directories are scanned recursively — subdirectory structure doesn't affect identity, only the `name` field does.

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter (Claude-provided)
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits and common filesystem commands |
| `auto` | Background classifier reviews commands |
| `dontAsk` | Auto-deny permission prompts (allowed tools still work) |
| `bypassPermissions` | Skip all permission prompts (use with caution) |
| `plan` | Read-only exploration |

If the parent uses `bypassPermissions` or `acceptEdits`, it takes precedence over the subagent's setting. If the parent uses auto mode, the subagent inherits it.

### Persistent Memory Scopes

| Scope | Location | Use when |
| :--- | :--- | :--- |
| `user` | `~/.claude/agent-memory/<name>/` | Knowledge should apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Knowledge is project-specific and shareable via version control |
| `local` | `.claude/agent-memory-local/<name>/` | Knowledge is project-specific but should not be committed |

When memory is enabled, the first 200 lines or 25KB of `MEMORY.md` is injected into the subagent's system prompt, and Read/Write/Edit tools are automatically enabled.

### Unavailable Tools in Subagents

These tools always depend on the main session UI and cannot be used by subagents even when listed:

- `Agent`, `AskUserQuestion`, `EnterPlanMode`, `ExitPlanMode` (unless permissionMode is `plan`), `ScheduleWakeup`, `WaitForMcpServers`

### Invoking Subagents

| Method | How |
| :--- | :--- |
| Natural language | Name the subagent in your prompt; Claude decides whether to delegate |
| @-mention | Type `@` and pick from typeahead (e.g. `@"code-reviewer (agent)"`); guarantees that subagent runs |
| `--agent <name>` CLI flag | Whole session uses that subagent's system prompt, tools, and model |
| `agent` setting in `.claude/settings.json` | Default for every session in a project |

For plugin subagents: pass scoped name like `--agent my-plugin:security-reviewer` or `@agent-my-plugin:code-reviewer`.

### Disabling Specific Subagents

Add to `permissions.deny` in `settings.json`:

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or with the CLI: `claude --disallowedTools "Agent(Explore)"`

### Subagent Context at Startup

A non-fork subagent starts with:

- **System prompt**: agent's own prompt (not the full Claude Code system prompt)
- **Task message**: delegation prompt Claude writes
- **CLAUDE.md and memory**: full hierarchy (except Explore and Plan, which skip it)
- **Git status**: snapshot from parent session start (except Explore and Plan)
- **Preloaded skills**: full content of skills listed in `skills` field

### Foreground vs Background

| Mode | Behavior |
| :--- | :--- |
| Foreground | Blocks main conversation; permission prompts surface interactively |
| Background | Runs concurrently; auto-denies any tool call that would prompt |

Switch a running task to background with `Ctrl+B`. Disable all background tasks with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

### Project-Level Hooks for Subagent Events

Configured in `settings.json` to fire in the main session:

| Event | Matcher | When it fires |
| :--- | :--- | :--- |
| `SubagentStart` | Agent type name | When a subagent begins |
| `SubagentStop` | Agent type name | When a subagent completes |

### Fork Mode

Forks are experimental (requires v2.1.117+). Enable with `CLAUDE_CODE_FORK_SUBAGENT=1`.

A fork inherits the full conversation history instead of starting fresh — same system prompt, tools, model, and message history. Fork's tool calls stay isolated; only the final result returns to your main context.

With fork mode enabled:
- Claude uses forks wherever it would otherwise use the general-purpose subagent
- Every subagent spawn runs in the background
- `/fork <directive>` spawns a fork

| | Fork | Named subagent |
| :--- | :--- | :--- |
| Context | Full conversation history | Fresh context |
| System prompt | Same as main session | From definition file |
| Prompt cache | Shared with main session | Separate cache |
| Permissions | Prompts surface in terminal | Auto-denied when in background |

### Fork Panel Keys

| Key | Action |
| :--- | :--- |
| `↑` / `↓` | Move between rows |
| `Enter` | Open fork transcript and send follow-ups |
| `x` | Dismiss finished fork or stop running one |
| `Esc` | Return focus to prompt input |

### Common Patterns

- **Isolate verbose output**: delegate test runs, log processing, doc fetching to subagents — only the summary returns
- **Parallel research**: spawn multiple subagents for independent investigations, Claude synthesizes results
- **Chain subagents**: "Use the code-reviewer to find issues, then use the optimizer to fix them"

### When to Use Subagents vs Main Conversation

Use **subagents** when the task produces verbose output, requires specific tool restrictions, or is self-contained with a clear result.

Use the **main conversation** when the task needs frequent back-and-forth, shares significant context across phases, or latency matters.

Use **Skills** instead when you want reusable prompts running in the main conversation context (not isolated).

Use `/btw` for quick side questions — it sees full context but has no tools and its answer is discarded.

### CLI-Defined Subagents (`--agents`)

Pass JSON at launch for session-only subagents (not saved to disk):

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

The `--agents` flag accepts the same fields as file-based subagents, using `prompt` for the system prompt body.

### Restricting Spawnable Subagents (`Agent(name)`)

When an agent runs as the main thread via `claude --agent`:

```yaml
tools: Agent(worker, researcher), Read, Bash
```

Only `worker` and `researcher` can be spawned. Omit `Agent` entirely to block all subagent spawning. Use `Agent` without parentheses to allow any.

Note: `Agent(name)` in a subagent's `tools` has no effect — subagents cannot spawn other subagents.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — built-in subagents, quickstart, all frontmatter fields, model selection, tool control, MCP scoping, permission modes, skills preloading, persistent memory, hooks, invoking subagents, foreground/background, fork mode, example subagents

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
